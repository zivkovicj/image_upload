class RipostesController < ApplicationController
    
    def edit
        @riposte = Riposte.find(params[:id])
        @question = @riposte.question
    end
    
    def update
        @riposte = Riposte.find(params[:id])
        @question = @riposte.question
        @quiz = @riposte.quiz
        next_riposte_num = @riposte.position + 1
        
        perc = 0
        case @question.style
        when "multiple-choice"
            n = params[:whichIsCorrect][:whichIsCorrect].to_i
            stud_answer = @question.read_attribute(:"choice_#{n}")
            perc = @riposte.poss if @question.correct_answers.include?(stud_answer)
        when "fill-in"
            stud_answer = params[:stud_answer]
            @question.correct_answers.each do |correct_answer|
                if stud_answer.downcase.gsub(/\s+/, "") == correct_answer.downcase.gsub(/\s+/, "")
                    perc = @riposte.poss
                    break
                end
            end
        end
        
        @riposte.update(:stud_answer => stud_answer)
        @riposte.update(:tally => perc)
        @quiz.update(:progress => @riposte.position)
        
        if @riposte == @quiz.ripostes.last
            @student = @quiz.user
            @objective = @quiz.objective
            @this_obj_stud = @student.objective_students.find_by(:objective => @objective)
            set_total_score
            take_post_req_keys
            redirect_to quiz_path(@quiz)
        else
            next_riposte = @quiz.ripostes.find_by(:position => next_riposte_num)
            redirect_to  edit_riposte_path(next_riposte)
        end
    end

    private
    
        def set_total_score
            @old_stars = (@this_obj_stud == nil ? 0 : @this_obj_stud.points) 
        
            poss = 0
            stud_score = 0
            @quiz.ripostes.each do |riposte|
                poss += riposte.poss
                stud_score += (riposte.tally)
            end
            
            @new_total = ((stud_score * 100)/poss.to_f).round
            @these_stars = (@new_total/10.to_f).ceil
            added_stars = @these_stars - @old_stars
            added_stars_to_update = [0,added_stars].max
            @quiz.update(:total_score => @these_stars, :added_stars => added_stars_to_update)
            @this_obj_stud.update_scores(@these_stars, Seminar.find(current_user.current_class).term_for_seminar, @quiz.origin, false)
        end
        
        def take_post_req_keys
            if @this_obj_stud.points < 6 && @this_obj_stud.total_keys == 0
                @objective.mainassigns.each do |mainassign|
                    this_mainassign = mainassign.objective_students.find_by(:user => @student)
                    this_mainassign.update(:pretest_keys => 0) if this_mainassign
                end
            end
        end
    
end