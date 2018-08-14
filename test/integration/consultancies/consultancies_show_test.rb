require 'test_helper'

class ConsultanciesShowTest < ActionDispatch::IntegrationTest
    
    include DeskConsultants
    include ConsultanciesHelper
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_scores
        setup_objectives
        
        @consultancy = @seminar.consultancies.create # Most tests rely on one consultancy already existing.
        @seminar.seminar_students.update_all(:created_at => "2017-07-16 03:10:54")
        @cThresh = @seminar.consultantThreshold
        @objective_zero_priority = objectives(:objective_zero_priority)
        
        @student_1 = users(:student_1)
        @student_2 = users(:student_2)
        @student_3 = users(:student_3)
        @student_4 = users(:student_4)
        @student_5 = users(:student_5)
        @student_6 = users(:student_6)
        @student_7 = users(:student_7)
        @student_8 = users(:student_8)
        @student_9 = users(:student_9)
        @student_10 = users(:student_10)
        @student_46 = users(:student_46)
        
        @ss_1 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_1.id)
        @ss_2 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_2.id)
        @ss_3 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_3.id)
        @ss_4 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_4.id)
        @ss_5 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_5.id)
        @ss_6 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_6.id)
        @ss_7 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_7.id)
        @ss_8 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_8.id)
        @ss_9 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_9.id)
        @ss_10 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_10.id)
        @ss_46 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_46.id)
        
        set_date_3 = Date.today - 100.days
        set_date_4 = Date.today - 120.days
        @seminar.seminar_students.update_all(:created_at => set_date_3)
        @ss_8.update(:created_at => set_date_4)
        
        # Scores
        set_all_scores(:user, @student_10, 10)
        set_all_scores(:user, @student_5, 10)
        set_all_scores(:user, @student_8, 2)
        set_specific_score(@student_9, @objective_10, 2)
        set_specific_score(@student_9, @objective_20, 2)
            
        # Requests
        @ss_5.update(:pref_request => 0)
        @ss_6.update(:learn_request => @objective_50.id)
        @ss_7.update(:teach_request => @objective_20.id, :pref_request => 2)
        @ss_9.update(:learn_request => @objective_20.id)
        @ss_10.update(:learn_request => @objective_40.id)
        @ss_46.update(:teach_request => @objective_zero_priority.id)
            
        # Priorities
        @own_assign.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 1)
        @objective_zero_priority.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 0) # To test that student who requested this doesn't get a group.
            
        @cThresh = @seminar.consultantThreshold
    end
    
    def method_setup
        @cThresh = @seminar.consultantThreshold
        @consultancy = Consultancy.create(:seminar => @seminar)
        @students = setup_present_students
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        @rank_by_consulting = setup_rank_by_consulting
        @need_hash = setup_need_hash
        @prof_list = setup_prof_list 
    end
    
    def contrived_setup
        @seminar = Seminar.create(:name => "Contrived Seminar")
        @seminar.teachers << @teacher_1
        @c_obj_1 = @seminar.objectives.create(:name => "Contrived Already Mastered Objective")
        @c_obj_2 = @seminar.objectives.create(:name => "Contrived Pre-Objective")
        @c_obj_3 = @seminar.objectives.create(:name => "Contrived Main-Objective")
        @c_obj_4 = @seminar.objectives.create(:name => "Learn Request for the Lone Student")
        @c_obj_5 = @seminar.objectives.create(:name => "Option for stud with no learn_request")
        @c_obj_3.preassigns << @c_obj_2
        @c_stud_1 = Student.create(:first_name => "A", :last_name => "B")
        @c_stud_2 = Student.create(:first_name => "C", :last_name => "D")
        @c_stud_3 = Student.create(:first_name => "E", :last_name => "F")
        @c_stud_4 = Student.create(:first_name => "G", :last_name => "H")
        @c_stud_5 = Student.create(:first_name => "I", :last_name => "J")
        @c_stud_6 = Student.create(:first_name => "K", :last_name => "L")
        @c_stud_7 = Student.create(:first_name => "M", :last_name => "N")
        @c_stud_8 = Student.create(:first_name => "O", :last_name => "P")
        @c_stud_9 = Student.create(:first_name => "Q", :last_name => "R")
        @c_stud_10 = Student.create(:first_name => "S", :last_name => "T")
        
        Student.all.each do |student|
            Objective.all.each do |objective|
                student.objective_students.find_or_create_by(:objective => objective)
                student.quizzes.create(:objective => objective, :total_score => 2, :origin => "teacher_granted")
            end
        end
        @seminar.students << @c_stud_1
        @seminar.students << @c_stud_2
        @seminar.students << @c_stud_3
        @seminar.students << @c_stud_4
        @seminar.students << @c_stud_5
        @seminar.students << @c_stud_6
        @seminar.students << @c_stud_7
        @seminar.students << @c_stud_8
        @seminar.students << @c_stud_9
        @seminar.students << @c_stud_10
    end
    
    def test_all_consultants
        @consultancy.teams.each do |team|
            if team.consultant.present?
                assert team.consultant.score_on(team.objective) >= @seminar.consultantThreshold
            end
        end
    end
    
    def test_all_apprentices
        @consultancy.teams.each do |team|
            team.users.each do |member|
                assert member.score_on(team.objective) <= @seminar.consultantThreshold unless member == team.consultant
            end
        end
    end
    
    test "show consultancy" do
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        @consultancy = @seminar.consultancies.order(:created_at).last
        assert_text(show_consultancy_headline(@consultancy))
    end
    
    test "show first consultancy" do
        @seminar.consultancies.destroy_all
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        assert_text("Mark Attendance Before Creating Desk-Consultants Groups")
    end
    
    test "simple create test" do
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        click_on("#{new_consultancy_button_text}")
        assert_text("Mark Attendance Before Creating Desk-Consultants Groups")
        click_on("Create Desk Consultants Groups")
        @consultancy = @seminar.consultancies.last
        assert_text(show_consultancy_headline(@consultancy))
    end
    
    test "delete from show page" do
        old_consultancy_count = Consultancy.count
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        find("#delete_#{@consultancy.id}").click
        click_on("confirm_#{@consultancy.id}")
        
        assert_text("All Arrangements")
        
        assert_equal old_consultancy_count - 1, Consultancy.count
    end
    
    test "setup_present_students" do
        @ss_2.update(:present => false)
        @ss_3.update(:present => true)
        @students = setup_present_students
        assert @students.include?(@student_1)
        assert_not @students.include?(@student_2)
    end
    
    test "rank by consulting" do
        set_date = Date.today - 80.days
        c1 = Consultancy.create(:seminar => @seminar, :created_at => set_date, :updated_at => set_date)
        t1 = c1.teams.create(:consultant => @student_1, :created_at => set_date, :updated_at => set_date)
        t1.users << @student_2
        t1.users << @student_3
        t3 = c1.teams.create(:consultant => @student_5, :created_at => set_date, :updated_at => set_date)
        t3.users << @student_6
        t3.users << @student_7
        
        set_date_2 = Date.today - 10.days
        c2 = Consultancy.create(:seminar => @seminar, :created_at => set_date_2, :updated_at => set_date_2)
        t2 = c2.teams.create(:consultant => @student_1, :created_at => set_date_2, :updated_at => set_date_2)
        t2.users << @student_2
        t2.users << @student_3
        
        @ss_1.update(:pref_request => 2)
        @ss_5.update(:pref_request => 0)
        @student_41 = @seminar.students.create(:first_name => "Marko", :last_name => "Zivkovic", :type => "Student", :password_digest => "password")
        
        assert_equal 13.2, @student_1.consultant_days(@seminar)
        assert_equal 0, @student_41.consultant_days(@seminar)
        assert_equal 63, @student_5.consultant_days(@seminar)
        
        @students = setup_present_students
        @rank_by_consulting = setup_rank_by_consulting

        assert_equal @student_41, @rank_by_consulting[-1]
        assert_equal @student_1, @rank_by_consulting[-2]
        assert_equal @student_5, @rank_by_consulting[-3]
    end
    
    test "rank objectives by need" do
        @objective_40.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        assert_equal @objective_40, @rank_objectives_by_need[0]
        
        @seminar.seminar_students.find_by(:user => @student_4).update(:learn_request => @objective_30.id)
        @objective_30.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        @objective_50.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 0)
        @seminar.seminar_students.find_by(:user => @student_5).update(:learn_request => @objective_20.id)
        @seminar.reload
        
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        assert_equal @objective_30, @rank_objectives_by_need[0]
        assert_equal @objective_40, @rank_objectives_by_need[1]
        assert_equal @objective_20, @rank_objectives_by_need[2]
        assert_not @rank_objectives_by_need.include?(@objective_50)
    end
    
    test "check if ready" do
        main_assign = objectives(:objective_60)
        pre_assign_1 = objectives(:objective_50)
        pre_assign_2 = objectives(:objective_40)
        
        set_specific_score(@student_1, pre_assign_1, 0)
        set_specific_score(@student_1, pre_assign_2, 0)
        this_obj_stud = @student_1.objective_students.find_by(:objective => main_assign)
        assert_not this_obj_stud.obj_ready?
        
        set_specific_score(@student_2, pre_assign_1, 10)
        set_specific_score(@student_2, pre_assign_2, 10)
        this_obj_stud = @student_2.objective_students.find_by(:objective => main_assign)
        assert this_obj_stud.obj_ready?
        
        set_specific_score(@student_3, pre_assign_1, 0)
        set_specific_score(@student_3, pre_assign_2, 10)
        this_obj_stud = @student_3.objective_students.find_by(:objective => main_assign)
        assert_not this_obj_stud.obj_ready?
    end
    
    test "prof list" do
        @students = setup_present_students
        @prof_list = setup_prof_list
        @prof_list.each_with_index do |stud, index|
            assert stud.quiz_stars_all_time(@seminar) <= @prof_list[index+1].quiz_stars_all_time(@seminar) if index < @prof_list.count - 1
        end
        assert @prof_list.first.quiz_stars_all_time(@seminar) < @prof_list.last.quiz_stars_all_time(@seminar)
    end
    
    test "choose consultants" do
        @objective_40.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        ObjectiveStudent.where(:objective => @objective_40).update_all(:points_all_time => 0)
        @objective_50.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        ObjectiveStudent.where(:objective => @objective_50).update_all(:points_all_time => 0)
        these_obj_studs = @seminar.obj_studs_for_seminar
        12.times do |n|
            these_obj_studs[n].update(:points_all_time => 3)
        end
        @student_4.seminar_students.find_by(:seminar => @seminar).update(:pref_request => 2)
        set_specific_score(@student_4, @objective_40, 7)
        set_specific_score(@student_9, @objective_50, 7)
        set_specific_score(@student_7, @objective_20, 8)
        set_specific_score(@student_7, @objective_40, 5)
        set_specific_score(@student_46, @objective_20, 7)
        set_specific_score(@student_1, @objective_20, 3)
        set_specific_score(@student_2, @objective_20, 3)
        set_specific_score(@student_6, @objective_20, 7)  # To ensure that he's qualified to consult at least one topic.
        set_specific_score(@student_7, @objective_50, 5)  # So she doesn't get taken because of the priority of the objectives
        set_date_1 = Date.yesterday
        
        c1 = Consultancy.create(:seminar => @seminar, :created_at => set_date_1, :updated_at => set_date_1)
        t1 = c1.teams.create(:consultant => @student_4, :created_at => set_date_1, :updated_at => set_date_1)
        t1.users << @student_2
        t1.users << @student_3
        
        method_setup
        assert_equal @student_7, @rank_by_consulting[0]
        assert_equal @student_8, @rank_by_consulting[1]
        assert_equal @student_6, @rank_by_consulting[2]
        assert_equal @student_46, @rank_by_consulting[3]
        
        # No teams before choose_consultants
        assert_equal 0, @consultancy.teams.count
        choose_consultants
        
        #Several teams exist
        assert @consultancy.teams.count > 1
        
        #Only consultants are placed so far
        @consultancy.users.each do |stud|
            assert_equal stud, stud.teams.find_by(:consultancy => @consultancy).consultant
        end
        
        # Priority #5 assignments are included first
        # Even takes @student_4, despite her request
        assert @consultancy.users.include?(@student_4)
        assert_equal @student_4, @rank_by_consulting.last
        assert_equal @objective_40, @student_4.teams.find_by(:consultancy => @consultancy).objective
        assert_equal 1, @consultancy.teams.where(:objective => @objective_40).count 
        assert_equal @objective_50, @student_9.teams.find_by(:consultancy => @consultancy).objective
        assert_equal 1, @consultancy.teams.where(:objective => @objective_50).count
        
        # First student in rank_by_consulting receives her teach_request
        assert_equal Objective.find(@ss_7.teach_request), @consultancy.teams.find_by(:consultant => @student_7).objective
        
        # Second student in rank_by_consulting gets skipped because she's unqualified
        assert_not @consultancy.users.include?(@rank_by_consulting[1])
        assert @consultancy.users.include?(@rank_by_consulting[2])
        
        # Student with no teach_request gets teach_options[0]
        second_team_consultant = @rank_by_consulting[2]
        assert_equal second_team_consultant.teach_options(@seminar, @rank_objectives_by_need)[0], @consultancy.teams.find_by(:consultant => second_team_consultant).objective
    
        # Student whose request has zero priority did not get that request
        # (This could happen if the priority was changed after the request was made)
        assert_not_nil @consultancy.teams.find_by(:consultant => @student_46)
        assert_not_equal Objective.find(@ss_46.teach_request), @consultancy.teams.find_by(:consultant => @student_46).objective
    
        test_all_consultants
    end
    
    test "deprioritize consultants who already have keys" do
        method_setup
        top_choice_consultant = @rank_by_consulting[0]
        second_choice_consultant = @rank_by_consulting[1]
        other_students = @seminar.students.select{|x| x != top_choice_consultant && x != second_choice_consultant}.take(3)
        
        top_choice_consultant.seminar_students.find_by(:seminar => @seminar).update(:teach_request => nil)
        @objective_40.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        other_students.each do |stud|
            set_specific_score(stud, @objective_40, 0)
        end
        set_specific_score(top_choice_consultant, @objective_40, 8)
        @objective_40.objective_students.find_by(:user => top_choice_consultant).update(:pretest_keys => 2)
        set_specific_score(second_choice_consultant, @objective_40, 8)
        
        choose_consultants
        
        assert_equal 0, @consultancy.teams.where(:consultant => top_choice_consultant, :objective => @objective_40).count
        assert_equal 1, @consultancy.teams.where(:consultant => second_choice_consultant, :objective => @objective_40).count
    end
    
    test "deprioritize consultants with 100 score" do
        method_setup
        top_choice_consultant = @rank_by_consulting[0]
        second_choice_consultant = @rank_by_consulting[1]
        
        @objective_40.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        @rank_by_consulting[2..4].each do |stud|
            set_specific_score(stud, @objective_40, 0)
        end
        @rank_by_consulting[5..@rank_by_consulting.count].each do |stud|
            set_specific_score(stud, @objective_40, 7)
        end
        set_specific_score(top_choice_consultant, @objective_40, 10)
        set_specific_score(second_choice_consultant, @objective_40, 8)
        
        choose_consultants
        
        assert_equal 0, @consultancy.teams.where(:consultant => top_choice_consultant, :objective => @objective_40).count
        assert_equal 1, @consultancy.teams.where(:consultant => second_choice_consultant, :objective => @objective_40).count
    end
    
    test "but assign 100 score consultant if needed" do
        method_setup
        top_choice_consultant = @rank_by_consulting[0]
        second_choice_consultant = @rank_by_consulting[1]
        
        @objective_40.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 5)
        @rank_by_consulting[2..@rank_by_consulting.count].each do |stud|
            set_specific_score(stud, @objective_40, 0)
        end
        set_specific_score(top_choice_consultant, @objective_40, 10)
        set_specific_score(second_choice_consultant, @objective_40, 8)
        
        choose_consultants
        
        assert_equal 1, @consultancy.teams.where(:consultant => top_choice_consultant, :objective => @objective_40).count
        assert_equal 1, @consultancy.teams.where(:consultant => second_choice_consultant, :objective => @objective_40).count
    end
    
    test "team has room" do
        c1 = Consultancy.create(:seminar => @seminar)
        t1 = c1.teams.create(:consultant => @student_1, :objective => @objective_10)
        t1.users << @student_1
        
        t2 = c1.teams.create(:consultant => @student_2, :objective => @objective_10)
        t2.users << @student_2
        
        t3 = c1.teams.create(:consultant => @student_3, :objective => @objective_20)
        t3.users << @student_3
        
        # True if all teams are empty
        assert t1.has_room
        assert t2.has_room
        assert t3.has_room
        
        # True if all smaller teams are studying different objectives
        t1.users << @student_4
        t2.users << @student_5
        assert t1.has_room
        assert t2.has_room
        assert t3.has_room
        
        # False if one team with the same objective has fewer members
        t1.users << @student_6
        assert_not t1.has_room
        assert t2.has_room
        
        # True if all teams are equal
        t2.users << @student_7
        assert t1.has_room
        assert t2.has_room
        
        # False if team has over three members
        t1.users << @student_8
        t2.users << @student_9
        assert_not t1.has_room
        assert_not t2.has_room
    end
    
    test "place apprentices by request" do
        @objective_20.objective_seminars.find_by(:seminar => @seminar).update(:priority => 5)
        set_specific_score(@student_1, @objective_20, 8)
        
        request_obj = Objective.find(@ss_6.learn_request)
        request_obj.objective_seminars.find_by(:seminar => @seminar).update(:priority => 5)
        set_specific_score(@student_2, request_obj, 8)
        
        method_setup
        choose_consultants  
        test_all_consultants  # This is tested earlier, but I also wanted to test consultants with a less-contrived setup.
        place_apprentices_by_requests
        test_all_apprentices
        
        # Students who had a request available received their request.
        assert request_obj, @student_6.teams.find_by(:consultancy => @consultancy).objective.id
        
        # Student not placed if she doesn't meet all pre-requisites for her request
        # (This could happen if the pre-reqs were changed after the request was made)
        assert @student_9.seminar_students.find_by(:seminar => @seminar).learn_request == @objective_20.id
        assert_not @student_9.objective_students.find_by(:objective => @objective_20).obj_ready?
        assert @consultancy.teams.where(:objective => @objective_20).count > 0
    end
    
    test "find placement" do
        contrived_setup
        
        set_specific_score(@c_stud_4, @c_obj_1, 9)
        set_specific_score(@c_stud_4, @c_obj_2, 2)
        set_specific_score(@c_stud_4, @c_obj_3, 2)
        
        set_specific_score(@c_stud_9, @c_obj_1, 2)
        set_specific_score(@c_stud_9, @c_obj_2, 2)
        set_specific_score(@c_stud_9, @c_obj_3, 2)
        
        set_specific_score(@c_stud_10, @c_obj_1, 9)
        set_specific_score(@c_stud_10, @c_obj_2, 9)
        set_specific_score(@c_stud_10, @c_obj_3, 2)
        
        t1 = @consultancy.teams.create(:consultant => @c_stud_1, :objective => @c_obj_1) # Student_4 scored too high on this objective
        t1.users << @c_stud_1
        # Pre-Objective isn't offered
        t2 = @consultancy.teams.create(:consultant => @c_stud_2, :objective => @c_obj_3) # Student_4 isn't ready for this objective
        t2.users << @c_stud_2
        t3 = @consultancy.teams.create(:consultant => @c_stud_3, :objective => @c_obj_2) # Student_4 could join this team, but it doesn't have room
        t3.users << @c_stud_3
        t3.users << @c_stud_5
        t3.users << @c_stud_6
        t3.users << @c_stud_7
        
        @students = setup_present_students 
        @need_hash = setup_need_hash
        assert_nil find_placement(@c_stud_4)
        
        assert_equal t1, find_placement(@c_stud_9)
        
        assert_equal t2, find_placement(@c_stud_10)
        
        # Now make a team available for @c_obj_2
        # Also adds student to that team
        t4 = @consultancy.teams.create(:consultant => @c_stud_8, :objective => @c_obj_2) 
        t4.users << @c_stud_8
        
        assert_equal 1, t4.users.count
        assert_equal t4, find_placement(@c_stud_4)
        assert_equal 2, t4.users.count
        assert t4.users.include?(@c_stud_4)
        test_all_apprentices
    end
    
    test "place apprentices by mastery" do
        method_setup
        choose_consultants
        #place_apprentices_by_requests
        
        # The method places some students
        old_count = @consultancy.users.count
        place_apprentices_by_mastery
        assert @consultancy.users.count > old_count
        
        # Unplaced students are proficent everywhere there's room
        unplaced_so_far = @students.select{|x| need_placement(x)}
        assert unplaced_so_far.count > 0   # Even with random scores, student_5 should still be unplaced
        assert_equal @consultancy.users.count + unplaced_so_far.count, @students.count
        teams_with_room = @consultancy.teams.select{|x| x.has_room}
        unplaced_so_far.each do |stud|
            teams_with_room.each do |team|
                obj_stud = stud.objective_students.find_by(:objective => team.objective)
                assert !obj_stud.obj_ready? || !obj_stud.obj_willing?(@cThresh)
            end
        end
        
        # All apprentices are non-proficient, but ready for the team's objective
        @consultancy.teams.each do |team|
            team.users.reject{|x| x == team.consultant}.each do |stud|
                assert stud.objective_students.find_by(:objective => team.objective).obj_ready_and_willing?(@cThresh)
            end
        end
        
        # No student placed more than once
        @seminar.students.each do |student|
            assert student.teams.where(:consultancy => @consultancy).count < 2
        end
        test_all_apprentices
    end
    
    test "check for lone students" do
        contrived_setup
        
        t1 = @consultancy.teams.create(:consultant => @c_stud_1, :objective => @c_obj_1)  # Home for the first student, who is placed in an existing group
        t1.users << @c_stud_1
        t1.users << @c_stud_4
        t2 = @consultancy.teams.create(:consultant => @c_stud_2, :objective => @c_obj_1)  # Home for the second student, who starts a new group with her learn_request
        t2.users << @c_stud_2
        t3 = @consultancy.teams.create(:consultant => @c_stud_3, :objective => @c_obj_2)  # Home for the fourth student, who starts a new group with her first learn_option
        t3.users << @c_stud_3
        
        # Singleton teams are deleted
        assert Team.all.select{|x| x.users.count == 1}.count > 1
        check_for_lone_students
        assert_equal 0, Team.all.select{|x| x.users.count == 1}.count
        test_all_apprentices
    end
    
    test "new place for lone students" do
        contrived_setup
        
        set_specific_score(@c_stud_10, @c_obj_1, 2)
        
        set_specific_score(@c_stud_9, @c_obj_1, 9)
        set_specific_score(@c_stud_9, @c_obj_2, 9)
        set_specific_score(@c_stud_9, @c_obj_3, 9)
        set_specific_score(@c_stud_9, @c_obj_4, 6)
        set_specific_score(@c_stud_9, @c_obj_5, 5)
        
        @c_stud_9.seminar_students.find_by(:seminar => @seminar).update(:learn_request => @c_obj_4.id)
        
        set_specific_score(@c_stud_8, @c_obj_1, 9)
        set_specific_score(@c_stud_8, @c_obj_2, 9)
        
        set_specific_score(@c_stud_7, @c_obj_1, 7)
        set_specific_score(@c_stud_7, @c_obj_2, 7)
        set_specific_score(@c_stud_7, @c_obj_3, 7)
        set_specific_score(@c_stud_7, @c_obj_4, 7)
        set_specific_score(@c_stud_7, @c_obj_5, 0)
        
        set_specific_score(@c_stud_6, @c_obj_1, 7)
        set_specific_score(@c_stud_6, @c_obj_2, 7)
        set_specific_score(@c_stud_6, @c_obj_3, 7)
        set_specific_score(@c_stud_6, @c_obj_4, 7)
        set_specific_score(@c_stud_6, @c_obj_5, 7)
        
        method_setup
        
        t1 = @consultancy.teams.create(:consultant => @c_stud_1, :objective => @c_obj_1)  # Home for the first student, who is placed in an existing group
        t1.users << @c_stud_1
        t1.users << @c_stud_4
        t2 = @consultancy.teams.create(:consultant => @c_stud_2, :objective => @c_obj_1)  # Home for the second student, who starts a new group with her learn_request
        t2.users << @c_stud_2
        t2.users << @c_stud_5
        t3 = @consultancy.teams.create(:consultant => @c_stud_3, :objective => @c_obj_2)  # Home for the fourth student, who starts a new group with her first learn_option
        t3.users << @c_stud_3
        
        assert_equal 3, @consultancy.teams.count
        new_place_for_lone_students
        
        # One student is placed in an existing group
        assert t1.users.include?(@c_stud_10)
        
        # Another student receives her learn_request
        assert @consultancy.teams.count > 3
        t4 =  @c_stud_9.teams.find_by(:consultancy => @consultancy)
        assert_equal @c_obj_4, t4.objective 
        
        # Third student is placed in that newly-created group
        assert t4.users.include?(@c_stud_8)
        
        # Fourth student starts a new group with her first learn option (Because she has no learn request.)
        t5 = @c_stud_7.teams.find_by(:consultancy => @consultancy)
        assert_equal @c_obj_5, t5.objective

        # Last student is still unplaced
        assert_not @consultancy.users.include?(@c_stud_6)
    end

    test "are some unplaced" do
        @student_10.seminar_students.find_by(:seminar => @seminar).update(:learn_request => nil)
        
        method_setup
        choose_consultants
        place_apprentices_by_requests
        place_apprentices_by_mastery
        check_for_lone_students
        new_place_for_lone_students
        are_some_unplaced
        
        assert_equal 1, @consultancy.teams.where(:bracket => 1).count
        unplaced_team = @consultancy.teams.find_by(:bracket => 1)
    
        assert unplaced_team.users.include?(@student_5)
        assert unplaced_team.users.include?(@student_10)
    end
    
    test "give dc keys" do
        method_setup
        choose_consultants
        place_apprentices_by_requests
        place_apprentices_by_mastery
        check_for_lone_students
        new_place_for_lone_students
        are_some_unplaced
        
        this_team = @consultancy.teams.select{|x| x.users.count > 1}.first
        test_stud = this_team.users.select{|x| x != this_team.consultant}.last
        test_obj_stud = test_stud.objective_students.find_by(:objective => this_team.objective)
        test_obj_stud.update(:pretest_keys => 2, :points_this_term => nil)
        
        this_consultant = @consultancy.teams.first.consultant
        consultant_obj_stud = this_consultant.objective_students.find_by(:objective => this_team.objective)
        consultant_obj_stud.update(:dc_keys => 0, :points_this_term => 10)
        
        give_dc_keys
        
        test_obj_stud.reload
        assert_equal 2, test_obj_stud.dc_keys
        assert_equal 0, test_obj_stud.pretest_keys
        
        consultant_obj_stud.reload
        assert_equal 0, consultant_obj_stud.dc_keys
    end
    
    test "destroy if date already" do
        consult_count = Consultancy.count
        
        Consultancy.create(:seminar => @seminar)
        assert_equal consult_count + 1, Consultancy.count
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        click_on("#{new_consultancy_button_text}")
        click_on("Create Desk Consultants Groups")
        assert_equal consult_count + 1, Consultancy.count
    end
    
    test "destroy oldest upon tenth" do
        @seminar.consultancies.create(:created_at => "2017-07-15 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-14 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-13 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-12 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-11 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-10 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-09 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-08 03:10:54")
        @seminar.consultancies.create(:created_at => "2017-07-07 03:10:54")
        
        assert_equal 10, @seminar.consultancies.count
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        click_on("#{new_consultancy_button_text}")
        click_on("Create Desk Consultants Groups")
        
        @seminar.reload
        assert_equal 10, @seminar.consultancies.count
    end
end