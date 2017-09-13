require 'test_helper'

class QuestionsIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        @admin_q = questions(:one)
        @this_teachers_q = questions(:two)
        @other_teacher_public_q = questions(:three)
        @other_teacher_private_q = questions(:four)
        setup_questions()
    end
    
    test "index questions as admin" do
        disable_images
        capybara_login(@admin_user)
        click_on("All Questions")

        assert_selector('a', :id => "edit_#{@admin_q.id}", :text => @admin_q.short_prompt)
        assert_selector('td', :id => "delete_#{@admin_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@this_teachers_q.id}", :text => @this_teachers_q.short_prompt)
        assert_selector('td', :id => "delete_#{@this_teachers_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_public_q.id}", :text => @other_teacher_public_q.short_prompt)
        assert_selector('td', :id => "delete_#{@other_teacher_public_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_private_q.id}", :text => @other_teacher_private_q.short_prompt)
        assert_selector('td', :id => "delete_#{@other_teacher_private_q.id}", :text => "Delete")
    end
    
    test "index questions as non admin" do
        disable_images
        capybara_login(@teacher_1)
        click_on("All Questions")
    
        assert_selector('a', :id => "edit_#{@admin_q.id}", :text => @admin_q.short_prompt)
        assert_selector('td', :id => "delete_#{@admin_q.id}", :text => "Delete", :count => 0)
        assert_selector('a', :id => "edit_#{@this_teachers_q.id}", :text => @this_teachers_q.short_prompt)
        assert_selector('td', :id => "delete_#{@this_teachers_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_public_q.id}", :text => @other_teacher_public_q.short_prompt)
        assert_selector('td', :id => "delete_#{@other_teacher_public_q.id}", :text => "Delete",:count => 0)
        assert_selector('a', :id => "edit_#{@other_teacher_private_q.id}", :text => @other_teacher_private_q.short_prompt, :count => 0)
        assert_selector('td', :id => "delete_#{@other_teacher_private_q.id}", :text => "Delete", :count => 0)
    end
    
    test "back button" do
        disable_images
        capybara_login(@teacher_1)
        click_on("All Questions")
        assert_selector("h1", :text => "All Questions")
        assert_not_on_teacher_page
        click_on("back_button")
        assert_on_teacher_page
    end
    
    test "delete question" do
        disable_images
        old_q_count = Question.count
        old_lab = @admin_q.label
        assert_not_nil old_lab
        lo = old_lab.label_objectives.first
        old_lab_quest_count = old_lab.questions.count
        lo.update(:quantity => old_lab_quest_count)
        
        capybara_login(@admin_user)
        click_on("All Questions")
        
        find("#delete_#{@admin_q.id}").click
        click_on("confirm_#{@admin_q.id}")
        
        lo.reload
        assert_equal old_q_count - 1, Question.count
        assert_equal old_lab_quest_count - 1, lo.quantity
    end
    
    test "deleting last question from label deletes label_objective" do
        disable_images
        this_lab = Label.find_by(:name => "Other_Label_Public")
        this_quest = this_lab.questions.first
        this_lab.label_objectives.create(:objective => Objective.first, :quantity => 1, :point_value => 1)
        old_lo_count = LabelObjective.count
        assert_equal 1, this_lab.label_objectives.count
        
        capybara_login(@admin_user)
        click_on("All Questions")
        
        fill_in "search_field", with: this_quest.prompt
        click_on("Search")
        find("#delete_#{this_quest.id}").click
        click_on("confirm_#{this_quest.id}")
        
        this_lab.reload
        assert_equal old_lo_count - 1, LabelObjective.count
        assert_equal 0, this_lab.label_objectives.count
    end
end