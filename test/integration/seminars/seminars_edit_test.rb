require 'test_helper'

class SeminarsEditTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        setup_seminars
        
        @old_seminar_count = Seminar.count
        @old_st_count = SeminarTeacher.count
    end
    
    def due_date_array
        [["06/05/2019","06/06/2019","06/07/2019","06/08/2019"],
         ["06/09/2019","06/10/2019","06/11/2019","06/12/2019"],
         ["06/13/2019","06/14/2019","06/15/2019","06/16/2019"],
         ["06/17/2019","06/18/2019","06/19/2019","06/20/2019"]]
    end
    
    def set_score_for_random_student(seminar)
        test_student = seminar.students.limit(1).order("RANDOM()").first
        test_obj = seminar.objectives.limit(1).order("RANDOM()").first
        test_obj_stud = ObjectiveStudent
            .find_by(:user => test_student, :objective => test_obj)
        test_obj_stud.update(:points_this_term => 4)
        return test_obj_stud
    end
    
    test "add obj and preassign at once" do
        setup_objectives
        setup_scores
        
        @this_preassign = @assign_to_add.preassigns.first
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Objectives")
        
        check("check_#{@assign_to_add.id}")
        check("check_#{@this_preassign.id}")
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal 1, @seminar.objective_seminars.where(:objective => @assign_to_add).count
        assert_equal 1, @seminar.objective_seminars.where(:objective => @this_preassign).count
    end
    
    test "basic info autofill" do
        old_name = @seminar.name
        old_year = @seminar.school_year
        old_thresh = @seminar.consultantThreshold
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Basic Info")
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal old_name, @seminar.name
        assert_equal old_year, @seminar.school_year
        assert_equal old_thresh, @seminar.consultantThreshold
        
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "basic info change" do
        assert_not_equal 4, @seminar.school_year
        assert_not_equal 8, @seminar.consultantThreshold
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Basic Info")
        
        fill_in "seminar[name]", with: "Dangle"
        fill_in "seminar[default_buck_increment]", with: 9
        find("#school_year_1").select("3")  # Choose 3 for 5th grade
        choose("seminar_consultantThreshold_8")
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal "Dangle", @seminar.name
        assert_equal 4, @seminar.school_year
        assert_equal 8, @seminar.consultantThreshold
        assert_equal 9, @seminar.default_buck_increment
        
        assert_selector('div', :text => "Class Updated")
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end

    test "basic info blank name" do
        old_name = @seminar.name
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Basic Info")
        
        fill_in "seminar[name]", with: ""
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal old_name, @seminar.name
        
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "change term and reset grades" do
        assert_equal 1, @seminar.term
        setup_scores
        test_obj_stud = set_score_for_random_student(@seminar)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Grading Term")
        
        find("#seminar_term").select("3")  # Choose 5 for 5th grade
        check("reset")
        click_on("Update This Class")
        
        assert_equal 3, @seminar.reload.term
        assert_equal 1, @seminar_2.reload.term    # To make sure that only changes if the repeat choice is checked.
        assert_equal 0, test_obj_stud.reload.points_this_term
    end
    
    test "change term default" do
        assert_equal 1, @seminar.term
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Grading Term")
        
        click_on("Update This Class")
        
        assert_equal 2, @seminar.reload.term
    end
    
    test "change term do not reset grades" do
        setup_scores
        test_obj_stud = set_score_for_random_student(@seminar)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Grading Term")
        
        find("#seminar_term").select("3")  # Choose 5 for 5th grade
        click_on("Update This Class")
        
        assert_equal 4, test_obj_stud.reload.points_this_term
    end
    
    test "change term repeat" do
        assert_equal 1, @seminar.term
        assert_equal 1, @seminar_2.term
        assert_equal 1, @avcne_seminar.term
        
        setup_scores
        test_obj_stud_1 = set_score_for_random_student(@seminar)
        test_obj_stud_2 = set_score_for_random_student(@seminar_2)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Grading Term")
        
        find("#seminar_term").select("3")  # Choose 5 for 5th grade
        check("reset")
        check("repeat")
        click_on("Update This Class")
        
        assert_equal 3, @seminar.reload.term
        assert_equal 3, @seminar_2.reload.term
        assert_equal 1, @avcne_seminar.reload.term
        assert_equal 0, test_obj_stud_1.reload.points_this_term
        assert_equal 0, test_obj_stud_2.reload.points_this_term
    end
    
    
    test "objectives" do
        setup_objectives
        obj_array = [@objective_30, @objective_40, @objective_50, @own_assign, @assign_to_add]
        @this_preassign = @assign_to_add.preassigns.first
        @objective_zero_priority = objectives(:objective_zero_priority)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Objectives")
        
        obj_array.each do |obj|
            check("check_#{obj.id}")
        end
        uncheck("check_#{@objective_zero_priority.id}")
        
        click_on("Update This Class")
        
        @seminar.reload
        
        obj_array.each do |obj|
            assert @seminar.objectives.include?(obj)
        end
        assert_not @seminar.objectives.include?(@objective_zero_priority)
        assert @seminar.objectives.include?(@assign_to_add)
        assert_equal 1, @seminar.objective_seminars.where(:objective => @this_preassign).count
        assert @seminar.objectives.include?(@assign_to_add.preassigns.first)  
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assign_to_add.id)
        end
        
        assert_selector('div', :text => "Class Updated")
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "pretests" do
        setup_scores
        ObjectiveStudent.update_all(:pretest_keys => 0)
        @seminar.objective_seminars.update_all(:pretest => 0)
        @os_0 = @seminar.objective_seminars[0]
        @os_1 = @seminar.objective_seminars[1]
        @os_2 = @seminar.objective_seminars[2]
        @os_3 = @seminar.objective_seminars[3]
        @os_2.update(:pretest => 1)
        @os_3.update(:pretest => 1)
        first_student = @seminar.students.first
        second_student = @seminar.students.second
        obj_stud_0_0 = ObjectiveStudent.find_by(:objective => @os_0.objective, :user => first_student)
        obj_stud_0_1 = ObjectiveStudent.find_by(:objective => @os_1.objective, :user => first_student)
        obj_stud_0_2 = ObjectiveStudent.find_by(:objective => @os_2.objective, :user => first_student)
        obj_stud_0_3 = ObjectiveStudent.find_by(:objective => @os_3.objective, :user => first_student)
        obj_stud_1_1 = ObjectiveStudent.find_by(:objective => @os_3.objective, :user => second_student)
        obj_stud_0_0.update(:points_all_time => 3)
        obj_stud_0_1.update(:points_all_time => 3)
        obj_stud_0_2.update(:pretest_keys => 2, :points_all_time => 3)
        obj_stud_0_3.update(:pretest_keys => 2, :points_all_time => 3)
        obj_stud_1_1.update(:pretest_keys => 0, :points_all_time => 10)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Pretests")
        
        check("pretest_on_#{@os_1.objective.id}")
        uncheck("pretest_on_#{@os_3.objective.id}")
        
        click_on("Update This Class")
        
        assert_equal 0, @os_0.reload.pretest
        assert_equal 1, @os_1.reload.pretest
        assert_equal 1, @os_2.reload.pretest
        assert_equal 0, @os_3.reload.pretest
        
        # Give or take keys for added or removed pretests
        assert_equal 0, obj_stud_0_0.reload.pretest_keys
        assert_equal 2, obj_stud_0_1.reload.pretest_keys
        assert_equal 2, obj_stud_0_2.reload.pretest_keys
        assert_equal 0, obj_stud_0_3.reload.pretest_keys
        assert_equal 0, obj_stud_1_1.reload.pretest_keys    # Shouldn't give keys because the student already has a perfect score
        
        assert_selector('div', :text => "Class Updated")
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "priorities" do
        @os_0 = @seminar.objective_seminars[0]
        @os_1 = @seminar.objective_seminars[1]
        @seminar.objective_seminars.update_all(:priority => 2)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Priorities")
        
        choose("#{@os_0.id}_3")
        choose("#{@os_1.id}_0")
        
        click_on("Update This Class")
        
        @os_0.reload
        @os_1.reload
        assert_equal 3, @os_0.priority
        assert_equal 0, @os_1.priority
        
        assert_selector('div', :text => "Class Updated")
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "delete seminar" do
        capybara_login(@teacher_1)
        click_on("seminar_#{@seminar.id}")
        click_on("Basic Info")
        
        assert_no_selector('p', :id => "remove_#{@seminar.id}")
        assert_selector('p', :id => "delete_#{@seminar.id}")  #Counterpart.  This button should not exist if the class is shared.
        find("#delete_#{@seminar.id}").click
        click_on("confirm_#{@seminar.id}")
        
        assert_equal @old_seminar_count - 1, Seminar.count
    end
    
    test "no delete button for shared class" do
        capybara_login(@other_teacher)
        click_on("seminar_#{@avcne_seminar.id}")
        click_on("Basic Info")
        
        assert_selector('p', :id => "remove_#{@avcne_seminar.id}")   #Counterpart.  This button should not exist if the class is not shared.
        assert_no_selector('p', :id => "delete_#{@avcne_seminar.id}")
    end
    
    test "remove seminar" do
        assert @teacher_1.seminars.include?(@avcne_seminar)
        assert @avcne_seminar.teachers.include?(@teacher_1)
        
        capybara_login(@teacher_1)
        click_on("seminar_#{@avcne_seminar.id}")
        click_on("Basic Info")
        find("#remove_#{@avcne_seminar.id}").click
        find("#confirm_remove_#{@avcne_seminar.id}").click
        
        @teacher_1.reload
        assert_equal @old_st_count - 1, SeminarTeacher.count
        assert_not @teacher_1.seminars.include?(@avcne_seminar)
        assert_not @avcne_seminar.teachers.include?(@teacher_1)
    end
    
    test "some user can edit" do
        @avcne_seminar.teachers << @teacher_3
        @st_1 = @teacher_1.seminar_teachers.find_by(:seminar => @avcne_seminar)
        @st_2 = @other_teacher.seminar_teachers.find_by(:seminar => @avcne_seminar)
        @st_3 = @teacher_3.seminar_teachers.find_by(:seminar => @avcne_seminar)
        assert_not @st_1.can_edit
        assert @st_2.can_edit
        assert_not @st_3.can_edit
        
        capybara_login(@teacher_3)
        click_on("seminar_#{@avcne_seminar.id}")
        click_on("Basic Info")
        find("#remove_#{@avcne_seminar.id}").click
        find("#confirm_remove_#{@avcne_seminar.id}").click
        
        @st_1.reload
        @st_2.reload
        assert_not @st_1.can_edit
        assert @st_2.can_edit
        
        click_on("Log out")
        
        capybara_login(@other_teacher)
        click_on("seminar_#{@avcne_seminar.id}")
        click_on("Basic Info")
        find("#remove_#{@avcne_seminar.id}").click
        find("#confirm_remove_#{@avcne_seminar.id}").click
        
        @st_1.reload
        assert @st_1.can_edit
    end
    
    test "copy due dates" do
        skip
        @array_should_be = 
        [["09/05/2019","09/06/2019","09/07/2019","09/08/2019"],
         ["09/09/2019","09/10/2019","09/11/2019","09/12/2019"],
         ["09/13/2019","09/14/2019","09/15/2019","09/16/2019"],
         ["09/17/2019","09/18/2019","09/19/2019","09/20/2019"]]
        
        first_seminar = @teacher_1.first_seminar
        first_seminar.update(:checkpoint_due_dates => @array_should_be)
        second_seminar = @teacher_1.seminars.second
        assert_not_equal @array_should_be, second_seminar.checkpoint_due_dates
        
        capybara_login(@teacher_1)
        click_on("seminar_#{second_seminar.id}")
        click_on("Due Dates")
        click_on("Copy Due Dates from #{first_seminar.name}")
        
        assert_selector("h2", :text => "Edit #{second_seminar.name}")
        second_seminar.reload
        assert_equal @array_should_be, second_seminar.checkpoint_due_dates
    end
    
    test "no copy button for same class" do
        skip
        first_seminar = @teacher_1.first_seminar
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{first_seminar.id}")
        assert_no_text("Copy Due Dates from #{first_seminar.name}")
    end
end