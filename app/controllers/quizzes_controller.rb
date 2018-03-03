class QuizzesController < ApplicationController
    
    def new
        @objective = Objective.find(params[:objective_id])
        if @objective.questions.count > 0
            @quiz = Quiz.create(:objective => @objective, :user => current_user, :progress => 1)
            quest_collect = []
            @objective.label_objectives.each do |lo|
                quant = lo.quantity
                label = lo.label
                label.questions.order("RANDOM()").limit(quant).each do |quest|
                    quest_collect.push([quest.id, lo.point_value])
                end
            end
            
            quest_collect.shuffle.each_with_index do |q_info, index|
                @quiz.ripostes.create(:question_id => q_info[0], :position => index+1, :poss => q_info[1]) 
            end
            redirect_to edit_riposte_path(@quiz.ripostes.first)
        else
            flash[:danger] = "This quiz doesn't have any questions. Please alert your teacher that you cannot take this quiz until some questions are added."
            @ss = SeminarStudent.find_by(:user => current_user, :seminar => current_user.current_class)
            redirect_to seminar_student_path(@ss)
        end
    end
    
    def edit
        @objective = Objective.find(params[:objective_id])
        @quiz = current_user.quizzes.find_by(:objective => @objective)
        current_question = @quiz.progress
        redirect_to edit_riposte_path(@quiz.ripostes[current_question])
    end
    
    def show
        @quiz = Quiz.find(params[:id])
        @objective = @quiz.objective
        
        student = current_user
        score = student.objective_students.find_by(:objective => @objective)
        @old_stars = (score == nil ? 0 : score.points) 
    
        poss = 0
        stud_score = 0
        @quiz.ripostes.each do |riposte|
            poss += riposte.poss
            stud_score += (riposte.tally)
        end
        
        @new_total = ((stud_score * 100)/poss.to_f).round
        @these_stars = num_of_stars(@new_total)
        @quiz.update(:total_score => @these_stars)
        @added_stars = @these_stars - @old_stars
        
        score.update(:points => @these_stars) if @added_stars > 0
    end
    
    def num_of_stars(input)
        (input/10.to_f).ceil
    end
    
end