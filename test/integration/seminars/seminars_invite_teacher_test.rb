require 'test_helper'

class SeminarsInviteTeacherTest < ActionDispatch::IntegrationTest
    
    include UsersHelper
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        
        @old_st_count = SeminarTeacher.count
    end
    
    def send_the_invite
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        find("#navribbon_shared_teachers").click
        find("#invite_teacher_#{@other_teacher.id}").click
         
        @st_2 = SeminarTeacher.find_by(:seminar => @seminar, :user => @other_teacher)
    end
    
    def send_another_invite
        click_on("other_class_edit_#{@seminar_2.id}")
        find("#navribbon_shared_teachers").click
        find("#invite_teacher_#{@other_teacher.id}").click
        
        @st_3 = SeminarTeacher.find_by(:seminar => @seminar_2, :user => @other_teacher)
    end
    
    test "send invites" do
        assert @teacher_1.school.teachers.include?(@other_teacher)
        assert_not SeminarTeacher.find_by(:seminar => @seminar, :user => @other_teacher)
        
        send_the_invite
        
        # This section makes sure that buttons don't appear for a teacher to invite herself or revoke her own editing privileges.
        assert_selector('a', "invite_teacher_#{@other_teacher.id}")
        assert_no_selector('a', :id => "invite_teacher_#{@teacher_1.id}")
        assert_selector('a', "stop_edit_privileges_#{@other_teacher.id}")
        assert_no_selector('a', :id => "stop_edit_privileges_#{@teacher_1.id}")
        
        # Can't invite unverified teacher
        assert_no_selector('a', :id => "invite_teacher_#{@unverified_teacher.id}")
        
        assert_selector('h1', :text => "Edit #{@seminar.name}")
        
        assert_equal @old_st_count + 1, SeminarTeacher.count
        assert_not @st_2.can_edit
        assert_not @st_2.accepted
    end
    
    test "invite and accept" do
        send_the_invite
        click_on("Log out")
        
        capybara_login(@other_teacher)
        find("#accept_invites").click
        click_on("accept_#{@st_2.id}")
        
        assert_text("Teacher Since:")
        
        @st_2.reload
        assert @st_2.accepted
        assert_not @st_2.can_edit
    end
    
    test "invite and decline" do
        send_the_invite
        click_on("Log out")
        
        capybara_login(@other_teacher)
        find("#accept_invites").click
        click_on("decline_#{@st_2.id}")
        
        assert_not SeminarTeacher.find_by(:seminar => @seminar, :user => @other_teacher)
        assert_equal @old_st_count, SeminarTeacher.count
    end
    
    test "more invites to accept" do
        send_the_invite
        send_another_invite
        click_on("Log out")
        
        capybara_login(@other_teacher)
        find("#accept_invites").click
        click_on("accept_#{@st_2.id}")
        
        assert_no_text("Teacher Since:")
        assert_selector("h1", :text => "Accept Invitations")
        
        click_on("accept_#{@st_3.id}")
        
        assert_text("Teacher Since:")
        assert_no_selector("h1", :text => "Accept Invitations")
    end
    
    test "more invites to decline" do
        send_the_invite
        send_another_invite
        click_on("Log out")
        
        capybara_login(@other_teacher)
        find("#accept_invites").click
        click_on("decline_#{@st_2.id}")
        
        assert_no_text("Teacher Since:")
        assert_selector("h1", :text => "Accept Invitations")
        
        click_on("decline_#{@st_3.id}")
        
        assert_text("Teacher Since:")
        assert_no_selector("h1", :text => "Accept Invitations")
    end
    
    test "cannot invite without edit privileges" do
        @teacher_3.update(:verified => 1)
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@avcne_seminar.id}")
        find("#navribbon_shared_teachers").click
        assert_no_selector('a', :id => "invite_teacher_#{@teacher_3.id}")
        
        click_on("other_class_edit_#{@seminar.id}")
        find("#navribbon_shared_teachers").click
        assert_selector('a', :id => "invite_teacher_#{@teacher_3.id}")
    end
    
    test "give edit privileges" do
        @st_2 = SeminarTeacher.create(:user => @other_teacher, :seminar => @seminar)
        assert_equal false, @st_2.can_edit
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        find("#navribbon_shared_teachers").click
        click_on("give_edit_privileges_#{@other_teacher.id}")
        
        assert_selector('h1', :text => "Edit #{@seminar.name}")
        
        @st_2.reload
        assert @st_2.can_edit
        
        find("#navribbon_shared_teachers").click
        click_on("stop_edit_privileges_#{@other_teacher.id}")
        
        assert_selector('h1', :text => "Edit #{@seminar.name}")
        
        @st_2.reload
        assert_not @st_2.can_edit
    end
    
end