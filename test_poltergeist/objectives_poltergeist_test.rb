require 'test_helper'

class ObjectivesPoltergeistTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_objectives
        setup_labels
        setup_questions
        
        @old_objective_count = Objective.count
    end
    
    test "give objective quiz keys" do
        poltergeist_stuff
        setup_scores
        
        @test_os = @objective_10.objective_students.find_by(:user => @student_2)
        @test_os.update(:teacher_granted_keys => 2, :pretest_keys => 2)
        @last_student = @seminar.students.last
        assert_not_equal @student_2, @last_student
        @last_os = @objective_10.objective_students.find_by(:user => @last_student)
        @last_os.update(:teacher_granted_keys => 1)
        
        Student.all.each do |student|
            student.destroy unless student == @student_2 or student == @last_student
        end

        capybara_login(@teacher_1)
        click_on("All Objective")
        click_on(@objective_10.name)
        
        this_holder = ".key_holder_#{@test_os.id}"
        within(this_holder) do
            assert_selector('img', :count => 2) 
        end
        
        find("#whole_class_1_#{@seminar.id}").trigger('click')
        
        within(this_holder) do
            assert_selector('img', :count => 3) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 3, @test_os.teacher_granted_keys
        assert_equal 0, @test_os.pretest_keys  # If a student earns another type of key, take away any pretest keys
        
        sleep(1)
        @last_os.reload
        assert_equal 2, @last_os.teacher_granted_keys
        
        find(".add_key_2_#{@test_os.id}").click
        
        within(this_holder) do
            assert_selector('img', :count => 5) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 5, @test_os.teacher_granted_keys
        
        sleep(1)
        @last_os.reload
        assert_equal 2, @last_os.teacher_granted_keys
        
        find(".add_key_1_#{@test_os.id}").click
        
        within(this_holder) do
            assert_selector('img', :count => 6) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 6, @test_os.teacher_granted_keys
        
        find(".add_key_1_#{@test_os.id}").trigger('click')  # Check that it doesn't exceed the max
        
        within(this_holder) do
            assert_selector('img', :count => 6) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 6, @test_os.teacher_granted_keys
        
        find(this_holder).trigger('click')
        
        within(this_holder) do
            assert_selector('img', :count => 5) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 5, @test_os.teacher_granted_keys
    end
    
end