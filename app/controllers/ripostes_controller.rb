class RipostesController < ApplicationController
    
    def edit
        @riposte = Riposte.find(params[:id])
        @question = @riposte.question
    end
    
    def update
        @riposte = Riposte.find(params[:id])
        @question = @riposte.question
        @quiz = @riposte.quiz
        
        perc = 0
        n = params[:whichIsCorrect][:whichIsCorrect].to_i
        stud_answer = @question.read_attribute(:"choice_#{n}")
        @riposte.update(:stud_answer => stud_answer)
        perc = @riposte.poss if @question.correct_answers.include?(stud_answer)
        @riposte.update(:tally => perc)
        
        if @riposte == @quiz.ripostes.last
            redirect_to quiz_path(@quiz)
        else
            next_riposte = @quiz.ripostes.find_by(:position => @riposte.position + 1)
            redirect_to  edit_riposte_path(next_riposte)
        end
    end
    
end