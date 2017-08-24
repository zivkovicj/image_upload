require 'test_helper'

class ConsultanciesShowTest < ActionDispatch::IntegrationTest
    
    include DeskConsultants
    include RankObjectivesByNeed
    
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
    
    test "simple check for screen" do
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        click_on("Create Desk Consultants Groups")
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
    
    test "desk consultants methods" do
        # setup_present_students
            @ss_2.update(:present => false)
            @students = setup_present_students()
            assert @students.include?(@student_1)
            assert_not @students.include?(@student_2)
            
        bonusSetup()
        
        # appliedConsultPoints
            #@ss_1.update(:pref_request => 0)
            #assert_equal 190, @student_1.appliedConsultPoints(@seminar)
            #@ss_1.update(:pref_request => 1)
            #assert_equal 150, @student_1.appliedConsultPoints(@seminar)
            #@ss_1.update(:pref_request => 2)
            #assert_equal 125, @student_1.appliedConsultPoints(@seminar)
        
        # rankByConsulting
            setupRankByConsulting()
            #assert_equal @rankByConsulting[0], @student_1
            #assert_equal @rankByConsulting[1], @student_4
            #assert_equal @rankByConsulting[2], @student_3
        
        # "Students In Need"
            # Only 5 students are ready for @objective_2, even though
            # eleven students are deficient in that objective. Because it has a
            # pre-requisite which students are also deficient in.
            #assert_equal 5, @objective_2.students_in_need(@seminar)
            #@student_2.objective_students.find_by(:objective_id => @objective_2.id).update(:points => 25)
            #assert_equal 6, @objective_2.students_in_need(@seminar)
        
        # rankAssignsByNeed()
            @rankAssignsByNeed = rankAssignsByNeed(@seminar)
            assert_equal @objective_4, @rankAssignsByNeed[0]
            
            @objective_3.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 3)
            @objective_5.objective_seminars.find_by(:seminar_id => @seminar.id).update(:priority => 0)
            @seminar.reload
            
            @rankAssignsByNeed = rankAssignsByNeed(@seminar)
            assert_equal @objective_3, @rankAssignsByNeed[0]
            assert_equal @objective_4, @rankAssignsByNeed[1]
            assert_equal @objective_2, @rankAssignsByNeed[2]
            assert_not @rankAssignsByNeed.include?(@objective_5)
        
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
        setupRankByConsulting()
        @rankAssignsByNeed = rankAssignsByNeed(@seminar)
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
        click_on("Create Desk Consultants Groups")
    end
    
    test "destroy if date already" do
        consult_count = Consultancy.count
        
        Consultancy.create(:seminar => @seminar)
        assert_equal consult_count + 1, Consultancy.count
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
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
        click_on("Create Desk Consultants Groups")
        
        @seminar.reload
        assert_equal 10, @seminar.consultancies.count
    end
end