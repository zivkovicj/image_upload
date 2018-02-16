require 'test_helper'

class ObjectivesFormTest < ActionDispatch::IntegrationTest
    
    include BuildPreReqLists
    include ObjectivesHelper
    
    
    def setup
        setup_users()
        setup_seminars
        setup_objectives()
        setup_labels()
        setup_questions()
        
        @old_objective_count = Objective.count
    end
    
    def submit_objective
        click_on('Create a New Objective')
    end
    
    test "new objective button from main user page" do
        capybara_login(@teacher_1)
        assert_on_teacher_page
        submit_objective
        assert_selector('h1', :text => 'New Objective', :visible => true)
        assert_not_on_teacher_page
    end
    
    test "user creates objective" do
        # Before Adding Objective
        oldPreconditionCount = Precondition.count
        capybara_login(@teacher_1)
        click_on('1st Period')
        submit_objective
        
        assert_selector('div', :id => "seminars_to_include")
        name = "009 Compare Unit Rates"
        fill_in "name", with: name
        check("check_#{@objective_20.id}")
        check('1st Period')
        choose('public_objective')
        submit_objective
        
        assert_text "Quantities and Point Values"
        assert_text name
        
        @new_objective = Objective.last
        assert_equal @old_objective_count + 1, Objective.count
        assert_equal name, @new_objective.name
        assert_equal @teacher_1, @new_objective.user
        assert_equal "public", @new_objective.extent
        assert_equal 2, @new_objective.objective_seminars.first.priority
        assert @new_objective.seminars.include?(@seminar)
        assert @seminar.objectives.include?(@new_objective)
        
        @newPrecondition = Precondition.last
        assert_equal oldPreconditionCount + 2, Precondition.count  # Because the pre-req had a pre-req
        assert_equal @new_objective.id, @newPrecondition.mainassign_id
        assert_equal @objective_20.id, @newPrecondition.preassign_id
        
        assert @seminar.objectives.include?(@new_objective)
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @new_objective.id)
        end
    end
    
    test "admin creates objective" do
        oldPreconditionCount = Precondition.count
        capybara_login(@admin_user)
        submit_objective

        name = "010 Destroy Unit Rates"
        fill_in "name", with: name
        check("check_#{@objective_20.id}")
        assert_no_selector('div', :id => "seminars_to_include")
        submit_objective
        
        @new_objective = Objective.last
        assert_equal @old_objective_count + 1, Objective.count
        assert_equal name, @new_objective.name
        assert_equal @admin_user, @new_objective.user
        assert_equal "private", @new_objective.extent
        assert_equal 0, @new_objective.objective_seminars.count
        assert_equal 0, @new_objective.labels.count
        
        @newPrecondition = Precondition.last
        assert_equal oldPreconditionCount + 2, Precondition.count  # Because the pre-req has a pre-req.
        assert_equal @new_objective.id, @newPrecondition.mainassign_id
        assert_equal @objective_20.id, @newPrecondition.preassign_id
    end
        
    test "add objective to seminar" do
        old_os_count = ObjectiveSeminar.count
        studToCheck = @seminar.students[11]
        
        assert_not @seminar.objectives.include?(@assign_to_add)
        assert_nil studToCheck.objective_students.find_by(:objective_id => @assign_to_add.id)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        
        check("check_#{@assign_to_add.id}")
        click_on('Update This Class')
        
        @seminar.reload
        
        # Adds two objectives because @assign_to_add has one preReq
        assert_equal old_os_count + 2, ObjectiveSeminar.count
        assert @seminar.objectives.include?(@assign_to_add)
        assert @seminar.objectives.include?(@assign_to_add.preassigns.first)
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assign_to_add.id)
        end
        
    end
    
    test "don't add prereq if seminar already has it" do
        @objective_80 = objectives(:objective_80)
        ObjectiveSeminar.create(:seminar_id => @seminar.id, :objective_id => @objective_80.id)
        old_os_count = ObjectiveSeminar.count
        assert @assign_to_add.preassigns.include?(@objective_80)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        check("check_#{@assign_to_add.id}")
        click_on('Update This Class')

        assert_equal old_os_count + 1, ObjectiveSeminar.count
        assert_equal 1, ObjectiveSeminar.where(:seminar_id => @seminar.id, :objective_id => @objective_80.id).count
    end
    
    test "scores for preReqs" do
        thisStudent = @seminar.students[11]
        assert_nil thisStudent.objective_students.find_by(:objective_id => @already_preassign_to_main.id)
        assert @main_objective.preassigns.include?(@already_preassign_to_main)
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        check("check_#{@main_objective.id}")
        click_on('Update This Class')
        
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @already_preassign_to_main.id)
        end
    end
    
    test "add seminar to objective" do
        assert_not @seminar.objectives.include?(@assign_to_add)
        studToCheck = @seminar.students[11]
        assert_nil studToCheck.objective_students.find_by(:objective_id => @assign_to_add.id)
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@assign_to_add.fullName)
        check(@seminar.name)
        
        click_on("Save Changes")
        
        assert @seminar.objectives.include?(@assign_to_add)
        
        @seminar.students.each do |student|
            assert_not_nil student.objective_students.find_by(:objective_id => @assign_to_add.id)
        end
    end
    
    test "teacher edits public objective" do
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@objective_20.fullName)
        check(@seminar.name)
        
        assert_text("You are viewing the details of this objective. You may not make any edits because it was created by another teacher.")
        assert_no_selector('input', :id => "name", :visible => true)
        assert_selector('li', :text => @objective_20.preassigns.first.short_name)
        assert_no_selector('input', :id => "#{@objective_20.name}", :visible => true)
    end
    
    test "view other teacher objective" do
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@objective_20.fullName)
        check(@seminar.name)
        
        assert_text("You are viewing the details of this objective. You may not make any edits because it was created by another teacher.")
        assert_no_selector('input', :id => "name", :visible => true)
        assert_selector('li', :text => @objective_20.preassigns.first.short_name)
        assert_no_selector('input', :id => "#{@objective_20.name}", :visible => true)
        assert_no_text("Save Changes")
    end
    
    test "user edits own objective" do
        assert_not @own_assign.preassigns.include?(@assign_to_add)
        assert_not @own_assign.labels.include?(@user_l)
        old_label_objective_count = LabelObjective.count
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@own_assign.fullName)
        assert_no_text("You may only edit an objective that you have created. You may use this window to choose which classes this objective is assigned to.")
        
        new_name = "Boobenfarten"
        fill_in "name", with: new_name
        check("check_#{@assign_to_add.id}")
        check("check_#{@user_l.id}")
        check("check_#{@admin_l.id}")
        click_on("Save Changes")
        
        @own_assign.reload
        label_objective_1 = @own_assign.label_objectives.find_by(:label => @user_l)
        label_objective_2 = @own_assign.label_objectives.find_by(:label => @admin_l)
        select('2', :from => "syl_#{label_objective_1.id}_quantity")
        select('3', :from => "syl_#{label_objective_2.id}_quantity")
        click_on("Update these quantities")
        
        @own_assign.reload
        label_objective_1.reload
        label_objective_2.reload
        assert_equal new_name, @own_assign.name
        assert @own_assign.preassigns.include?(@assign_to_add)
        assert @own_assign.labels.include?(@user_l)
        assert_equal old_label_objective_count + 2, LabelObjective.count
        assert_equal 2, label_objective_1.quantity
        assert_equal 3, label_objective_2.quantity
    end
    
    test "delete label_objective" do
        @own_assign.label_objectives.create(:label => @admin_l)
        @own_assign.label_objectives.create(:label => @user_l)
        label_objective_2 = @own_assign.label_objectives.find_by(:label => @admin_l)
        old_label_objective_count = LabelObjective.count
        old_label_count = @own_assign.labels.count
        assert_not_nil @own_assign.label_objectives.find_by(:label => @admin_l)
       
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@own_assign.fullName)
        uncheck("check_#{@admin_l.id}")
        click_on("Save Changes")
        
        assert_no_selector('input', :id => "syl_#{label_objective_2.id}_quantity")
        click_on("Update these quantities")
        
        @own_assign.reload
        assert_equal old_label_count - 1, @own_assign.labels.count
        assert_equal old_label_objective_count - 1, LabelObjective.count
    end
    
    test "empty name create" do
        capybara_login(@teacher_1)
        click_on('1st Period')
        submit_objective
        fill_in "name", with: ""
        submit_objective
        
        @new_objective = Objective.last
        assert_equal "Objective #{@old_objective_count}", @new_objective.name
        assert_equal @old_objective_count + 1, Objective.count
    end
    
    test "empty name update" do
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@own_assign.fullName)
        
        fill_in "name", with: ""
        click_on("Save Changes")
        
        @own_assign.reload
        assert_equal "Objective #{@old_objective_count}", @own_assign.name
    end
    
    test "add subpreassigns and supermainassigns" do
        oldPreconditionCount = Precondition.count
        
        assert @super_objective.preassigns.include?(@main_objective)
        assert @super_objective.preassigns.include?(@already_preassign_to_super)
        assert @main_objective.preassigns.include?(@already_preassign_to_main)
        assert_not @super_objective.preassigns.include?(@preassign)
        assert_not @super_objective.preassigns.include?(@sub_preassign)
        assert_not @main_objective.preassigns.include?(@preassign_to_add)
        assert_not @main_objective.preassigns.include?(@sub_preassign)
        assert_not @main_objective.preassigns.include?(@already_preassign_to_super)
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@main_objective.fullName)
        
        check("check_#{@preassign_to_add.id}")
        check("check_#{@already_preassign_to_super.id}")
        click_button("Save Changes")
        
        assert @main_objective.preassigns.include?(@already_preassign_to_super)
        assert @main_objective.preassigns.include?(@preassign_to_add)
        assert @main_objective.preassigns.include?(@sub_preassign)
        assert @super_objective.preassigns.include?(@preassign_to_add)
        assert @super_objective.preassigns.include?(@sub_preassign)
        assert_equal oldPreconditionCount + 5, Precondition.count #To make sure that Preconditions were not created that would be been redundant
    end
    
    test "add prereq and class at once" do
        @otherClass = seminars(:two)
        
        assert_not @otherClass.objectives.include?(@main_objective)
        assert_not @otherClass.objectives.include?(@preassign_to_add)
        assert_not @otherClass.objectives.include?(@sub_preassign)
        assert_not @otherClass.objectives.include?(@already_preassign_to_main)
        old_os_count = ObjectiveSeminar.count
        
        capybara_login(@teacher_1)
        click_on('All Objectives')
        click_on(@main_objective.fullName)
        
        check("check_#{@preassign_to_add.id}")
        check(@otherClass.name)
        click_button("Save Changes")
        
        assert @otherClass.objectives.include?(@main_objective)
        assert @otherClass.objectives.include?(@preassign_to_add)
        assert @otherClass.objectives.include?(@sub_preassign)
        assert @otherClass.objectives.include?(@already_preassign_to_main)
        assert_equal old_os_count + 4, ObjectiveSeminar.count
    end
   
    test "mainassigns shouldnt appear" do
        capybara_login(@admin_user)
        click_on('All Objectives')
        click_on(@objective_40.fullName)
        
        assert_no_selector('input', :id => "check_#{@own_assign.id}")
        assert_selector('input', :id => "check_#{@objective_30.id}")
    end
    
    test "but should appear for others" do
        capybara_login(@admin_user)
        click_on('All Objectives')
        click_on(@super_objective.fullName)
        
        assert_selector('input', :id => "check_#{@own_assign.id}")
    end
    
    test "teacher made no objectives" do
        visit('/')
        click_on('Log In')
        fill_in('username', :with => 'user-3@example.com')
        fill_in('Password', :with => 'password')
        click_on('Log In')
        
        submit_objective
        assert_text("Nothing here right now.")
    end
    
    test "teacher made objectives" do
        capybara_login(@teacher_1)
        click_on("New Objective")
        assert_no_text("Nothing here right now.")
    end
    
    test "objective with no label" do
        capybara_login(@teacher_1)
        click_on("New Objective")
        submit_objective
        
        assert_text(no_label_message)
        assert_no_text(quantity_instructions)
    end
    
    test "objective with label but not questions" do
        capybara_login(@teacher_1)
        click_on("New Objective")
        check("check_#{@user_l.id}")
        submit_objective
        
        assert_no_text(no_label_message)
        assert_text(quantity_instructions)
    end
    
    test "label with no questions" do
        @user_l.questions.destroy_all
        
        capybara_login(@teacher_1)
        click_on("New Objective")
        check("check_#{@user_l.id}")
        submit_objective
        
        @lo = @user_l.label_objectives.find_by(:objective => Objective.last)
        assert_text(no_questions_message)
        assert_no_selector('select', :id => "syl_#{@lo.id}_quantity")
    end
    
    test "label with questions" do
        capybara_login(@teacher_1)
        click_on("New Objective")
        check("check_#{@user_l.id}")
        submit_objective
        
        @lo = @user_l.label_objectives.find_by(:objective => Objective.last)
        assert_no_text(no_questions_message)
        assert_selector('select', :id => "syl_#{@lo.id}_quantity")
    end
    
end