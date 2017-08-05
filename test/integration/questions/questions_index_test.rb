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
        capybara_login(@admin_user)
        click_on("All Questions")

        assert_selector('a', :id => "edit_#{@admin_q.id}", :text => @admin_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@admin_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@this_teachers_q.id}", :text => @this_teachers_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@this_teachers_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_public_q.id}", :text => @other_teacher_public_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@other_teacher_public_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_private_q.id}", :text => @other_teacher_private_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@other_teacher_private_q.id}", :text => "Delete")
    end
    
    test "index questions as non admin" do
        capybara_login(@teacher_1)
        click_on("All Questions")
    
        assert_selector('a', :id => "edit_#{@admin_q.id}", :text => @admin_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@admin_q.id}", :text => "Delete", :count => 0)
        assert_selector('a', :id => "edit_#{@this_teachers_q.id}", :text => @this_teachers_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@this_teachers_q.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_teacher_public_q.id}", :text => @other_teacher_public_q.shortPrompt)
        assert_selector('a', :id => "delete_#{@other_teacher_public_q.id}", :text => "Delete",:count => 0)
        assert_selector('a', :id => "edit_#{@other_teacher_private_q.id}", :text => @other_teacher_private_q.shortPrompt, :count => 0)
        assert_selector('a', :id => "delete_#{@other_teacher_private_q.id}", :text => "Delete", :count => 0)
    end
    
    test "back button" do
        capybara_login(@teacher_1)
        click_on("All Questions")
        assert_selector("h1", :text => "All Questions")
        assert_not_on_teacher_page
        click_on("back_button")
        assert_on_teacher_page
    end
end