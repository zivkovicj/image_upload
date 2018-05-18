require 'test_helper'

class SeminarsScoresheetTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_seminars
        setup_objectives
        setup_scores
        
        @test_os = @objective_10.objective_students.find_by(:user => @student_2)
    end
    
    test "update score" do
        @test_os.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_os.id}][]", with: 8
        find("#save_scores_top").click
        
        @test_os.reload
        assert_equal 8, @test_os.points
        assert_equal 2, @test_os.teacher_granted_keys
        assert_equal 2, @test_os.dc_keys
    end
    
    test "give keys for perfect score" do
        @test_os.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_os.id}][]", with: 10
        find("#save_scores_top").click
        
        @test_os.reload
        assert_equal 10, @test_os.points
        assert_equal 0, @test_os.teacher_granted_keys
        assert_equal 0, @test_os.dc_keys
    end
    
    test "bad score data" do
        @test_os.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_os.id}][]", with: "a"
        find("#save_scores_top").click
        
        @test_os.reload
        assert_equal 2, @test_os.points
        assert_equal 2, @test_os.teacher_granted_keys
        assert_equal 2, @test_os.dc_keys
    end
end