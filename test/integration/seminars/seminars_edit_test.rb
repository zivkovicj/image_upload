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
        [["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"]]
    end
   
    test "edit seminar" do
        setup_objectives
        setup_scores
        obj_array = [@objective_30, @objective_40, @objective_50, @own_assign, @assign_to_add]
        @objective_zero_priority = objectives(:objective_zero_priority)
        @os_0 = @seminar.objective_seminars.find_by(:objective => @objective_30)
        @os_1 = @seminar.objective_seminars.find_by(:objective => @objective_40)
        @os_2 = @seminar.objective_seminars.find_by(:objective => @objective_50)
        @os_3 = @seminar.objective_seminars.find_by(:objective => @own_assign)
        @os_2.update(:pretest => 1)
        @os_3.update(:pretest => 1)
        obj_stud_1_0 = ObjectiveStudent.find_by(:user => @student_1, :objective => @os_0.objective)
        obj_stud_2_0 = ObjectiveStudent.find_by(:user => @student_2, :objective => @os_0.objective)
        obj_stud_1_1 = ObjectiveStudent.find_by(:user => @student_1, :objective => @os_1.objective)
        obj_stud_2_1 = ObjectiveStudent.find_by(:user => @student_2, :objective => @os_1.objective)
        obj_stud_1_2 = ObjectiveStudent.find_by(:user => @student_1, :objective => @os_2.objective)
        obj_stud_2_2 = ObjectiveStudent.find_by(:user => @student_2, :objective => @os_2.objective)
        obj_stud_1_3 = ObjectiveStudent.find_by(:user => @student_1, :objective => @os_3.objective)
        obj_stud_2_3 = ObjectiveStudent.find_by(:user => @student_2, :objective => @os_3.objective)
        
        set_specific_score(obj_stud_1_0.user, obj_stud_1_0.objective, 8)
        set_specific_score(obj_stud_2_0.user, obj_stud_2_0.objective, 8)
        set_specific_score(obj_stud_1_1.user, obj_stud_1_1.objective, 8)
        set_specific_score(obj_stud_2_1.user, obj_stud_2_1.objective, 8)
        obj_stud_1_2.update(:pretest_keys => 2)
        obj_stud_2_2.update(:pretest_keys => 2)
        obj_stud_1_3.update(:pretest_keys => 2)
        obj_stud_2_3.update(:pretest_keys => 2)
        set_specific_score(obj_stud_1_2.user, obj_stud_1_2.objective, 8)
        set_specific_score(obj_stud_2_2.user, obj_stud_2_2.objective, 8)
        set_specific_score(obj_stud_1_3.user, obj_stud_1_3.objective, 8)
        set_specific_score(obj_stud_2_3.user, obj_stud_2_3.objective, 8)
        
        assert_equal 2, @os_2.priority
        assert_equal 2, @os_3.priority
        assert @seminar.objectives.include?(@objective_zero_priority)
        assert_not @seminar.objectives.include?(@assign_to_add)
        studToCheck = @seminar.students[11]
        assert_nil studToCheck.objective_students.find_by(:objective_id => @assign_to_add.id)
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        
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
        assert @seminar.objectives.include?(@assign_to_add.preassigns.first)  
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assign_to_add.id)
        end

        fill_in "Name", with: "Macho Taco Period"
        find("#school_year_1").select("3")
        choose('8')
        check("pretest_on_#{@objective_30.id}")
        uncheck("pretest_on_#{@objective_50.id}")
        choose("#{@os_2.id}_3")
        choose("#{@os_3.id}_0")
        4.times do |n|
            4.times do |m|
                fill_in "seminar[checkpoint_due_dates][#{n}][#{m}]", with: due_date_array[n][m]
            end
        end
        fill_in "seminar[default_buck_increment]", with: "6"
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal "Macho Taco Period",  @seminar.name
        assert_equal 6, @seminar.default_buck_increment
        assert_equal 8, @seminar.consultantThreshold
        assert_equal 4, @seminar.school_year

        @os_0.reload
        @os_1.reload
        @os_2.reload
        @os_3.reload
    
        assert_equal due_date_array, @seminar.checkpoint_due_dates
        
        assert_equal 1, @os_0.pretest
        assert_equal 0, @os_1.pretest
        assert_equal 0, @os_2.pretest
        assert_equal 1, @os_3.pretest
        
        assert_equal 2, obj_stud_1_0.reload.pretest_keys
        assert_equal 2, obj_stud_2_0.reload.pretest_keys
        assert_equal 0, obj_stud_1_1.reload.pretest_keys
        assert_equal 0, obj_stud_2_1.reload.pretest_keys
        assert_equal 0, obj_stud_1_2.reload.pretest_keys
        assert_equal 0, obj_stud_2_2.reload.pretest_keys
        assert_equal 2, obj_stud_1_3.reload.pretest_keys
        assert_equal 2, obj_stud_2_3.reload.pretest_keys

        assert_equal 3, @os_2.priority
        assert_equal 0, @os_3.priority
        
        
        assert_selector('h2', :text => "Edit #{@seminar.name}")
    end
    
    test "delete seminar" do
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        
        assert_no_selector('p', :id => "remove_#{@seminar.id}")
        assert_selector('p', :id => "delete_#{@seminar.id}")  #Counterpart.  This button should not exist if the class is shared.
        find("#delete_#{@seminar.id}").click
        click_on("confirm_#{@seminar.id}")
        
        assert_equal @old_seminar_count - 1, Seminar.count
    end
    
    test "no delete button for shared class" do
        capybara_login(@other_teacher)
        click_on("edit_seminar_#{@avcne_seminar.id}")
        
        assert_selector('p', :id => "remove_#{@avcne_seminar.id}")   #Counterpart.  This button should not exist if the class is not shared.
        assert_no_selector('p', :id => "delete_#{@avcne_seminar.id}")
    end
    
    test "remove seminar" do
        assert @teacher_1.seminars.include?(@avcne_seminar)
        assert @avcne_seminar.teachers.include?(@teacher_1)
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@avcne_seminar.id}")
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
        click_on("edit_seminar_#{@avcne_seminar.id}")
        find("#remove_#{@avcne_seminar.id}").click
        find("#confirm_remove_#{@avcne_seminar.id}").click
        
        @st_1.reload
        @st_2.reload
        assert_not @st_1.can_edit
        assert @st_2.can_edit
        
        click_on("Log out")
        
        capybara_login(@other_teacher)
        click_on("edit_seminar_#{@avcne_seminar.id}")
        find("#remove_#{@avcne_seminar.id}").click
        find("#confirm_remove_#{@avcne_seminar.id}").click
        
        @st_1.reload
        assert @st_1.can_edit
    end
    
    test "copy due dates" do
        first_seminar = @teacher_1.first_seminar
        first_seminar.update(:checkpoint_due_dates => @array_should_be)
        second_seminar = @teacher_1.seminars.second
        assert_not_equal @array_should_be, second_seminar.checkpoint_due_dates
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{second_seminar.id}")
        click_on("Copy Due Dates from #{first_seminar.name}")
        
        assert_selector("h2", :text => "Edit #{second_seminar.name}")
        second_seminar.reload
        assert_equal @array_should_be, second_seminar.checkpoint_due_dates
    end
    
    test "no copy button for same class" do
        first_seminar = @teacher_1.first_seminar
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{first_seminar.id}")
        assert_no_text("Copy Due Dates from #{first_seminar.name}")
    end
end