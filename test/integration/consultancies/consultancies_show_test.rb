require 'test_helper'

class ConsultanciesShowTest < ActionDispatch::IntegrationTest
    
    include DeskConsultants
    include ConsultanciesHelper
    
    def setup
        setup_users()
        setup_seminars
        setup_scores()
        @cThresh = @seminar.consultantThreshold
        @student_1 = users(:student_1)
        @student_2 = users(:student_2)
        @student_3 = users(:student_3)
        @student_4 = users(:student_4)
        @student_5 = users(:student_5)
        @student_6 = users(:student_6)
        @student_7 = users(:student_7)
        
        @ss_1 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_1.id)
        @ss_2 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_2.id)
        @ss_3 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_3.id)
        @ss_4 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_4.id)
        @ss_5 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_5.id)
        @ss_6 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_6.id)
        @ss_7 = SeminarStudent.find_by(:seminar_id => @seminar.id, :user_id => @student_7.id)
        
        @objective_2 = @seminar.objectives[1]
        @objective_3 = @seminar.objectives[2]
        @objective_4 = @seminar.objectives[3]
        @objective_5 = @seminar.objectives[4]
        @objective_6 = @seminar.objectives[5]
        
        Precondition.create(:mainassign_id => @objective_2.id, :preassign_id => @objective_3.id)
        Precondition.create(:mainassign_id => @objective_2.id, :preassign_id => @objective_4.id)
        
        # Set some more realistic scores for the consultant algorithms
            @student_1.objective_students.find_by(:objective_id => @objective_2.id).update(:points => 25)
        
            @seminar.students[10..20].each do |student|
                score = student.objective_students.find_by(:objective_id => @objective_2.id)
                score.update(:points => 25)
            end
            
            @seminar.students[15..40].each do |student|
                score = student.objective_students.find_by(:objective_id => @objective_4.id)
                score.update(:points => 25)
            end
            @seminar.students[41..50].each do |student|
                score = student.objective_students.find_by(:objective_id => @objective_4.id)
                score.update(:points => 0)
            end
            
            @student_5.objective_students.each do |score|
                score.update(:points => 100)
            end
            
            # Teacher included one objective that no students have passed
            @seminar.students.each do |student|
                student.objective_students.find_by(:objective_id => @objective_6.id).update(:points => 0)
            end
            @objective_6.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 1)
            
        # Set some requests
            @ss_5.update(:pref_request => 0)
            @ss_6.update(:learn_request => @objective_4)
            @ss_7.update(:teach_request => @objective_4, :pref_request => 2)
            
        @teacher = @seminar.user
        @cThresh = @seminar.consultantThreshold
        @consultancy = Consultancy.create(:seminar => @seminar, :created_at => "2017-07-16 03:10:54")
    end
    
    def bonusSetup
        @students = setup_present_students()
        @objectives = @seminar.objectives.order(:name)
        @objectiveIds = @objectives.map(&:id)
        @scores = ObjectiveStudent.where(objective_id: @objectiveIds)
    end
    
    def targetStudentCount(target_student)
        msc = 0
        @consultancy.teams.each do |team|
            team.users.each do |student|
                if student.last_name == target_student.last_name
                    msc += 1
                end
            end
        end
        return msc
    end
    
    test "show" do
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
        @students = setup_present_students()
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
        
        set_date_3 = Date.today - 100.days
        @seminar.seminar_students.update_all(:created_at => set_date_3)
        @ss_1.update(:pref_request => 2)
        @ss_5.update(:pref_request => 0)
        @student_4 = @seminar.students.create(:first_name => "Marko", :last_name => "Zivkovic", :type => "Student", :password_digest => "password")
        
        assert_equal 13.2, @student_1.consultant_days(@seminar)
        assert_equal 0, @student_4.consultant_days(@seminar)
        assert_equal 63, @student_5.consultant_days(@seminar)
        
        @students = setup_present_students()
        @rank_by_consulting = setup_rank_by_consulting

        assert_equal @student_4, @rank_by_consulting[-1]
        assert_equal @student_1, @rank_by_consulting[-2]
        assert_equal @student_5, @rank_by_consulting[-3]
    end
    
    test "rank objectives by need" do
        @objective_4.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 3)
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        assert_equal @objective_4, @rank_objectives_by_need[0]
        
        @seminar.seminar_students.find_by(:user => @student_4).update(:learn_request => @objective_3.id)
        @objective_3.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 3)
        @objective_5.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 0)
        @seminar.seminar_students.find_by(:user => @student_5).update(:learn_request => @objective_2.id)
        @seminar.reload
        
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        assert_equal @objective_3, @rank_objectives_by_need[0]
        assert_equal @objective_4, @rank_objectives_by_need[1]
        assert_equal @objective_2, @rank_objectives_by_need[2]
        assert_not @rank_objectives_by_need.include?(@objective_5)
    end
    
    test "check_if_ready Test" do
        mainAssign = objectives(:objective_60)
        preAssign1 = objectives(:objective_50)
        preAssign2 = objectives(:objective_40)
        
        @student_1.objective_students.find_by(:objective_id => preAssign1.id).update(:points => 0)
        @student_1.objective_students.find_by(:objective_id => preAssign2.id).update(:points => 0)
        assert_not @student_1.check_if_ready(mainAssign)
        
        @student_2.objective_students.find_by(:objective_id => preAssign1.id).update(:points => 100)
        @student_2.objective_students.find_by(:objective_id => preAssign2.id).update(:points => 100)
        assert @student_2.check_if_ready(mainAssign)
        
        @student_3.objective_students.find_by(:objective_id => preAssign1.id).update(:points => 0)
        @student_3.objective_students.find_by(:objective_id => preAssign2.id).update(:points => 100)
        assert_not @student_3.check_if_ready(mainAssign)
    end
    
    test "check_for_lone_students" do
        @students = setup_present_students
        bonusSetup
        
        @rank_by_consulting = setup_rank_by_consulting
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        setupScoreHash
        setupProfList
        setupStudentHash
        @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
        chooseConsultants
        placeApprenticesByRequests
        placeApprenticesByMastery
        
        last_group = @consultancy.teams.last
        loneStudent = last_group.users.first
        last_group.users.delete_all
        last_group.users << loneStudent
        checkForLoneStudents
        
    end

    test "desk consultants methods" do
        bonusSetup()
        @rank_by_consulting = setup_rank_by_consulting
        
        # appliedConsultPoints
            #@ss_1.update(:pref_request => 0)
            #assert_equal 190, @student_1.appliedConsultPoints(@seminar)
            #@ss_1.update(:pref_request => 1)
            #assert_equal 150, @student_1.appliedConsultPoints(@seminar)
            #@ss_1.update(:pref_request => 2)
            #assert_equal 125, @student_1.appliedConsultPoints(@seminar)
        
        # "Students In Need"
            # Only 5 students are ready for @objective_2, even though
            # eleven students are deficient in that objective. Because it has a
            # pre-requisite which students are also deficient in.
            #assert_equal 5, @objective_2.students_in_need(@seminar)
            #@student_2.objective_students.find_by(:objective_id => @objective_2.id).update(:points => 25)
            #assert_equal 6, @objective_2.students_in_need(@seminar)
        
        # needHash
            ##assert_equal 6, @needHash[@objective_2.id]
            #assert_equal 0, @needHash[@objective_3.id]
            #assert_equal 34, @needHash[@objective_4.id]
            
        # scoreHash
            setupScoreHash()
            @assignId4 = @objective_4.id
            @studentId3 = @student_3.id
            assert_equal 25, @scoreHash[@assignId4][@studentId3][:score]
            assert_equal true, @scoreHash[@assignId4][@studentId3][:ready]
            
        # profList
            setupProfList()
            
        # consultantsList
            setupStudentHash()
            @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
            @rank_objectives_by_need = @seminar.rank_objectives_by_need
            chooseConsultants()
            
            # @student_1 was the first student in @rankByConsulting, but she only 
            # has a passing score in objectives that the class does not need.
            assert_equal @student_4, @consultancy.teams[0].consultant
            assert_equal @objective_2, @consultancy.teams[0].objective
            assert_not_nil @consultancy.teams[0].consultant
            
        # placeApprenticesByRequests
            placeApprenticesByRequests()
            assert @consultancy.users.include?(@student_6)
            
        # before placeApprenticesByMastery
            unplacedStudent = nil
            @profList.each do |student|
                if @consultancy.users.include?(student) 
                    unplacedStudent = student
                    break
                end
            end
            
        # during placedApprenticesByMastery
            placeApprenticesByMastery()
            assert @consultancy.users.include?(unplacedStudent)
            assert_not @consultancy.users.include?(@student_5)
            
        # before checkForLoneStudents()
            last_group = @consultancy.teams.last
            loneStudent = last_group.users.first
            last_group.users.delete_all
            last_group.users << loneStudent
            
        # checkForLoneStudents
            assert @consultancy.users.include?(loneStudent)
            oldLength = @consultancy.teams.count
            checkForLoneStudents()
            
            assert_equal oldLength - 1, @consultancy.teams.count
            assert_not @consultancy.users.include?(loneStudent)
        
        # newPlaceForLoneStudents()
            newPlaceForLoneStudents()
            assert @consultancy.users.include?(loneStudent)
            
        #assignSGSections
            # assignSGSections()
            #@consultants.each do |rev|
                #if rev[:group].length == 4
                    #assert_equal [4,1,2,3], rev[:consultant]
                #end
            #end
        
        # areSomeUnplaced()
            #areSomeUnplaced()
            #assert @someUnplaced.include?(@student_5)
    end
    
    test "each student placed only once" do
        @students = setup_present_students()
        setupStudentHash()
        set_objectives_and_scores(false)
        @rank_by_consulting = setup_rank_by_consulting
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
        
        setupScoreHash()
        setupProfList()
        chooseConsultants()
        placeApprenticesByRequests()
        placeApprenticesByMastery()
        checkForLoneStudents()
        newPlaceForLoneStudents()
        #assignSGSections()
        areSomeUnplaced()
        
        @seminar.students.each do |student|
            thisStudentCount = 0
            @consultancy.teams.each do |team|
                thisStudentCount += 1 if team.users.include?(student)
            end
            assert thisStudentCount == 1
        end
    end
    
    test "what if some scores are nil" do
        @seminar.students[7].objective_students[3].destroy
        @seminar.students[8].objective_students[2].update(:points => nil)
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        click_on("#{new_consultancy_button_text}")
        click_on("Create Desk Consultants Groups")
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