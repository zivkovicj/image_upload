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
            redirect_to quiz_path(@quiz)
        else
            next_riposte = @quiz.ripostes.find_by(:position => next_riposte_num)
            redirect_to  edit_riposte_path(next_riposte)
        end
    end

    
end