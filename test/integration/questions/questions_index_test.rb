require 'test_helper'

class QuestionsIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        @admin     = users(:michael)
        @non_admin = users(:archer)
        @admin_q = questions(:one)
        @this_teachers_q = questions(:two)
        @other_teacher_public_q = questions(:three)
        @other_teacher_private_q = questions(:four)
        setup_questions()
    end
    
    test "index questions as admin" do
        capybara_admin_login()
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
        capybara_teacher_login()
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
        capybara_teacher_login()
        click_on("All Questions")
        assert_selector("h1", :text => "All Questions")
        assert_no_text("Desk-Consultant Facilitator Since:")
        click_on("back_button")
        assert_text("Desk-Consultant Facilitator Since:") 
    end
end