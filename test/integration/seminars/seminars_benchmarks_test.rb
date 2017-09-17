require 'test_helper'

class SeminarsBenchmarksTest < ActionDispatch::IntegrationTest
    
    include SeminarStudentsHelper
    
    def setup
        setup_users 
        setup_seminars
        setup_scores
    end
    
    test "set benchmarks" do
        stud_1_ss = @student_1.seminar_students.find_by(:seminar => @seminar)
        stud_2_ss = @student_2.seminar_students.find_by(:seminar => @seminar)
        stud_3_ss = @student_3.seminar_students.find_by(:seminar => @seminar)
        stud_1_ss.ss_benchmark_stars
        stud_2_ss.ss_benchmark_stars
        stud_3_ss.ss_benchmark_stars
        stud_1_old_bench = stud_1_ss.benchmark
        stud_2_old_bench = stud_2_ss.benchmark
        stud_3_old_bench = stud_3_ss.benchmark
        
        @student_2.objective_students.each do |os|
            os.update(:points => 10)
        end
        
        capybara_login(@teacher_1)
        click_on('1st Period')
        click_on('Set Benchmark Stars')
        
        uncheck("benchmark_#{@student_1.id}")
        click_on("Set Benchmark Stars for These Students")
        
        stud_1_ss.reload
        stud_2_ss.reload
        stud_3_ss.reload
        assert_equal stud_1_old_bench, stud_1_ss.benchmark
        assert_not_equal stud_2_old_bench, stud_2_ss.benchmark
        assert_equal stud_3_old_bench, stud_3_ss.benchmark   #student 3 didn't earn any new stars
    end
end