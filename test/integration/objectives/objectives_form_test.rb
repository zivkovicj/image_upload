require 'test_helper'

class ObjectivesFormTest < ActionDispatch::IntegrationTest
    
    include BuildPreReqLists
    
    def setup
        setup_users()
        setup_seminars
        setup_objectives()
        setup_labels()
        setup_questions()
        @objective_30 = objectives(:objective_30)
        @objective_40 = objectives(:objective_40)
        @objective_50 = objectives(:objective_50)
        @ownAssign = objectives(:objective_60)
        @assignToAdd = objectives(:objective_70)
        @subPreassign = objectives(:objective_100)
        @preassignToAdd = objectives(:objective_110)
        @alreadyPreassignedToMainMain = objectives(:objective_120)
        @alreadyPreassignedToSuper = objectives(:objective_130)
        @mainMainAssign = objectives(:objective_140)
        @superMainAssign = objectives(:objective_150)
        
    end
    
    test "new objective button from main user page" do
        capybara_login(@teacher_1)
        assert_on_teacher_page
        click_on("Create a New Objective")
        assert_selector('h1', :text => 'New Objective', :visible => true)
        assert_not_on_teacher_page
    end
    
    test "user creates objective" do
        # Before Adding Objective
        oldAssignCount = Objective.count
        oldPreconditionCount = Precondition.count
        preReqAssign = @seminar.objectives.second
        capybara_login(@teacher_1)
        click_on('1st Period')
        click_on('Create a New Objective')
        assert_selector('div', :id => "seminars_to_include")

        name = "009 Compare Unit Rates"
        fill_in "name", with: name
        check("check_#{preReqAssign.id}")
        check('1st Period')
        click_button('Create a New Objective')
        
        assert_text "Quantities and Point Values"
        assert_text name.downcase
        
        @newAssign = Objective.last
        assert_equal oldAssignCount + 1, Objective.count
        assert_equal "009 compare unit rates", @newAssign.name
        assert_equal @teacher_1, @newAssign.user
        assert_equal "public", @newAssign.extent
        assert_equal 2, @newAssign.objective_seminars.first.priority
        assert @newAssign.seminars.include?(@seminar)
        assert @seminar.objectives.include?(@newAssign)
        
        @newPrecondition = Precondition.last
        assert_equal oldPreconditionCount + 1, Precondition.count
        assert_equal @newAssign.id, @newPrecondition.mainassign_id
        assert_equal preReqAssign.id, @newPrecondition.preassign_id
        
        assert @seminar.objectives.include?(@newAssign)
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @newAssign.id)
        end
    end
    
    test "admin creates objective" do
        oldAssignCount = Objective.count
        oldPreconditionCount = Precondition.count
        preReqAssign = @seminar.objectives.second
        capybara_login(@admin_user)
        click_on('Create a New Objective')

        name = "010 Destroy Unit Rates"
        fill_in "name", with: name
        check("check_#{preReqAssign.id}")
        assert_no_selector('div', :id => "seminars_to_include")
        click_button('Create a New Objective')
        
        @newAssign = Objective.last
        assert_equal oldAssignCount + 1, Objective.count
        assert_equal name.downcase, @newAssign.name
        assert_equal @admin_user, @newAssign.user
        assert_equal "public", @newAssign.extent
        assert_equal 0, @newAssign.objective_seminars.count
        
        @newPrecondition = Precondition.last
        assert_equal oldPreconditionCount + 1, Precondition.count
        assert_equal @newAssign.id, @newPrecondition.mainassign_id
        assert_equal preReqAssign.id, @newPrecondition.preassign_id
    end
        
    test "add objective to seminar" do
        old_os_count = ObjectiveSeminar.count
        studToCheck = @seminar.students[11]
        
        assert_not @seminar.objectives.include?(@assignToAdd)
        assert_nil studToCheck.objective_students.find_by(:objective_id => @assignToAdd.id)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        
        check("check_#{@assignToAdd.id}")
        click_on('Update Class')
        
        assert_text("Edit #{@seminar.name} Priorities")
        
        @seminar.reload
        
        # Adds two objectives because @assignToAdd has one preReq
        assert_equal old_os_count + 2, ObjectiveSeminar.count
        assert @seminar.objectives.include?(@assignToAdd)
        assert @seminar.objectives.include?(@assignToAdd.preassigns.first)
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assignToAdd.id)
        end
        
    end
    
    test "don't add prereq if seminar already has it" do
        @objective_80 = objectives(:objective_80)
        ObjectiveSeminar.create(:seminar_id => @seminar.id, :objective_id => @objective_80.id)
        old_os_count = ObjectiveSeminar.count
        assert @assignToAdd.preassigns.include?(@objective_80)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        check("check_#{@assignToAdd.id}")
        click_on('Update Class')

        assert_equal old_os_count + 1, ObjectiveSeminar.count
        assert_equal 1, ObjectiveSeminar.where(:seminar_id => @seminar.id, :objective_id => @objective_80.id).count
    end
    
    test "scores for preReqs" do
        thisStudent = @seminar.students[11]
        assert_nil thisStudent.objective_students.find_by(:objective_id => @alreadyPreassignedToMainMain.id)
        assert @mainMainAssign.preassigns.include?(@alreadyPreassignedToMainMain)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        check("check_#{@mainMainAssign.id}")
        click_on('Update Class')
        
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @alreadyPreassignedToMainMain.id)
        end
    end
    
    test "add seminar to objective" do
        assert_not @seminar.objectives.include?(@assignToAdd)
        studToCheck = @seminar.students[11]
        assert_nil studToCheck.objective_students.find_by(:objective_id => @assignToAdd.id)
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@assignToAdd.fullName)
        check(@seminar.name)
        
        click_on("Save Changes")
        
        assert @seminar.objectives.include?(@assignToAdd)
        
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assignToAdd.id)
        end
    end
    
    test "teacher edits public objective" do
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@assignToAdd.fullName)
        check(@seminar.name)
        
        assert_text("You may only edit an objective that you have created. You may use this window to choose which classes this objective is assigned to.")
        assert_no_selector('input', :id => "name", :visible => true)
        assert_selector('li', :text => @assignToAdd.preassigns.first.shortName)
        assert_no_selector('input', :id => "#{@assignToAdd.name}", :visible => true)
    end
    
    test "edit other teacher objective" do
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@assignToAdd.fullName)
        check(@seminar.name)
        
        assert_text("You may only edit an objective that you have created. You may use this window to choose which classes this objective is assigned to.")
        assert_no_selector('input', :id => "name", :visible => true)
        assert_selector('li', :text => @assignToAdd.preassigns.first.shortName)
        assert_no_selector('input', :id => "#{@assignToAdd.name}", :visible => true)
    end
    
    test "user edits own objective" do
        assert_not @ownAssign.preassigns.include?(@assignToAdd)
        assert_not @ownAssign.labels.include?(@user_l)
        old_label_objective_count = LabelObjective.count
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@ownAssign.fullName)
        assert_no_text("You may only edit an objective that you have created. You may use this window to choose which classes this objective is assigned to.")
        
        new_name = "Boobenfarten"
        fill_in "name", with: new_name
        check("check_#{@assignToAdd.id}")
        check("check_#{@user_l.id}")
        check("check_#{@admin_l.id}")
        click_on("Save Changes")
        
        @ownAssign.reload
        label_objective_1 = @ownAssign.label_objectives.find_by(:label => @user_l)
        label_objective_2 = @ownAssign.label_objectives.find_by(:label => @admin_l)
        select('2', :from => "syl_#{label_objective_1.id}_quantity")
        select('3', :from => "syl_#{label_objective_2.id}_quantity")
        click_on("Update these quantities")
        
        @ownAssign.reload
        label_objective_1.reload
        label_objective_2.reload
        assert_equal new_name.downcase, @ownAssign.name
        assert @ownAssign.preassigns.include?(@assignToAdd)
        assert @ownAssign.labels.include?(@user_l)
        assert_equal old_label_objective_count + 2, LabelObjective.count
        assert_equal 2, label_objective_1.quantity
        assert_equal 3, label_objective_2.quantity
    end
    
    test "delete label_objective" do
        @ownAssign.label_objectives.create(:label => @admin_l)
        @ownAssign.label_objectives.create(:label => @user_l)
        label_objective_2 = @ownAssign.label_objectives.find_by(:label => @admin_l)
        old_label_objective_count = LabelObjective.count
        old_label_count = @ownAssign.labels.count
        assert_not_nil @ownAssign.label_objectives.find_by(:label => @admin_l)
       
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@ownAssign.fullName)
        uncheck("check_#{@admin_l.id}")
        click_on("Save Changes")
        
        assert_no_selector('input', :id => "syl_#{label_objective_2.id}_quantity")
        click_on("Update these quantities")
        
        @ownAssign.reload
        assert_equal old_label_count - 1, @ownAssign.labels.count
        assert_equal old_label_objective_count - 1, LabelObjective.count
    end
    
    test "objective name error" do
        oldName = @ownAssign.name
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@ownAssign.fullName)
        
        fill_in "name", with: ""
        click_on("Save Changes")
        
        @ownAssign.reload
        assert_equal oldName, @ownAssign.name
    end
    
    test "add subpreassigns and supermainassigns" do
        oldPreconditionCount = Precondition.count
        
        assert @superMainAssign.preassigns.include?(@mainMainAssign)
        assert @superMainAssign.preassigns.include?(@alreadyPreassignedToSuper)
        assert @mainMainAssign.preassigns.include?(@alreadyPreassignedToMainMain)
        assert_not @superMainAssign.preassigns.include?(@preassign)
        assert_not @superMainAssign.preassigns.include?(@subPreassign)
        assert_not @mainMainAssign.preassigns.include?(@preassignToAdd)
        assert_not @mainMainAssign.preassigns.include?(@subPreassign)
        assert_not @mainMainAssign.preassigns.include?(@alreadyPreassignedToSuper)
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@mainMainAssign.fullName)
        
        check("check_#{@preassignToAdd.id}")
        check("check_#{@alreadyPreassignedToSuper.id}")
        click_button("Save Changes")
        
        assert @mainMainAssign.preassigns.include?(@alreadyPreassignedToSuper)
        assert @mainMainAssign.preassigns.include?(@preassignToAdd)
        assert @mainMainAssign.preassigns.include?(@subPreassign)
        assert @superMainAssign.preassigns.include?(@preassignToAdd)
        assert @superMainAssign.preassigns.include?(@subPreassign)
        assert_equal oldPreconditionCount + 5, Precondition.count #To make sure that Preconditions were not created that would be been redundant
    end
    
    test "add prereq and class at once" do
        @otherClass = seminars(:two)
        
        assert_not @otherClass.objectives.include?(@mainMainAssign)
        assert_not @otherClass.objectives.include?(@preassignToAdd)
        assert_not @otherClass.objectives.include?(@subPreassign)
        assert_not @otherClass.objectives.include?(@alreadyPreassignedToMainMain)
        old_os_count = ObjectiveSeminar.count
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@mainMainAssign.fullName)
        
        check("check_#{@preassignToAdd.id}")
        check(@otherClass.name)
        click_button("Save Changes")
        
        assert @otherClass.objectives.include?(@mainMainAssign)
        assert @otherClass.objectives.include?(@preassignToAdd)
        assert @otherClass.objectives.include?(@subPreassign)
        assert @otherClass.objectives.include?(@alreadyPreassignedToMainMain)
        assert_equal old_os_count + 4, ObjectiveSeminar.count
    end
   
    test "mainassigns shouldnt appear" do
        capybara_login(@admin_user)
        click_on('All Objectives')
        click_on(@objective_40.fullName)
        
        assert_no_selector('input', :id => "check_#{@ownAssign.id}")
        assert_selector('input', :id => "check_#{@objective_30.id}")
    end
    
    test "but should appear for others" do
        capybara_login(@admin_user)
        click_on('All Objectives')
        click_on(@superMainAssign.fullName)
        
        assert_selector('input', :id => "check_#{@ownAssign.id}")
    end
    
    test "teacher made no objectives" do
        visit('/')
        click_on('Log In')
        fill_in('username', :with => 'user-3@example.com')
        fill_in('Password', :with => 'password')
        click_on('Log In')
        
        click_on("Create a New Objective")
        assert_text("Nothing here right now.")
    end
    
    test "teacher made objectives" do
        capybara_login(@teacher_1)
        click_on("New Objective")
        assert_no_text("Nothing here right now.")
    end
    
end