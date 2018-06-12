require 'test_helper'

class SeminarsScoresheetTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_objectives
        setup_scores
        
        @test_obj_stud = @objective_10.objective_students.find_by(:user => @student_2)
        School.all.update_all(:term => 1)
    end
    
    test "update points and current scores" do
        @test_obj_stud.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2, :current_scores => [2,0,nil,nil])
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_obj_stud.id}]", with: 8
        find("#save_scores_top").click
        
        @test_obj_stud.reload
        assert_equal [2,8,nil,nil], @test_obj_stud.current_scores
        assert_equal 8, @test_obj_stud.points
        assert_equal 2, @test_obj_stud.teacher_granted_keys
        assert_equal 2, @test_obj_stud.dc_keys
    end
    
    test "teacher can make score lower" do  # But quizzes cannot lower scores.  They can only raise them.
        @test_obj_stud.update(:points => 6, :teacher_granted_keys => 2, :dc_keys => 2, :current_scores => [6,5,nil,nil])
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_obj_stud.id}]", with: 4
        find("#save_scores_top").click
        
        @test_obj_stud.reload
        assert_equal [6,4,nil,nil], @test_obj_stud.current_scores
        assert_equal 4, @test_obj_stud.points
    end
    
    test "take keys for perfect score" do
        @test_obj_stud.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2, :current_scores => [nil,2,nil,nil])
        Student.where.not(:id => @student_2.id).destroy_all
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        fill_in "scores[#{@test_obj_stud.id}]", with: 10
        find("#save_scores_top").click
        
        @test_obj_stud.reload
        assert_equal [nil,10,nil,nil], @test_obj_stud.current_scores
        assert_equal 10, @test_obj_stud.points
        assert_equal 0, @test_obj_stud.teacher_granted_keys
        assert_equal 0, @test_obj_stud.dc_keys
    end
    
    test "bad score data" do
        @test_obj_stud.update(:points => 2, :teacher_granted_keys => 2, :dc_keys => 2, :current_scores => [2,2,nil,nil])
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        fill_in "scores[#{@test_obj_stud.id}]", with: "a"
        find("#save_scores_top").click
        
        @test_obj_stud.reload
        assert_equal [2,2,nil,nil], @test_obj_stud.current_scores
        assert_equal 2, @test_obj_stud.points
        assert_equal 2, @test_obj_stud.teacher_granted_keys
        assert_equal 2, @test_obj_stud.dc_keys
    end
end