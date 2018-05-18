class QuizzesController < ApplicationController
    
    def new
        @objective = Objective.find(params[:objective_id])
        if @objective.questions.count > 0
            @origin = params[:origin]
            @quiz = Quiz.create(:objective => @objective, :user => current_user, :progress => 1, :origin => @origin)
            take_a_key
            check_if_six
            build_the_quiz
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
        @student = @quiz.user
        @this_os = @objective.objective_students.find_by(:user => @student) 
        
        establish_offer_next_try
    end
    
    private
    
        def take_a_key
            this_os = @objective.objective_students.find_by(:user => current_user)
            old_keys = this_os.read_attribute(:"#{@origin}_keys")
            new_keys = old_keys - 1
            this_os.update(:"#{@origin}_keys" => new_keys)
        end
        
        def check_if_six
            quizzes_with_same_objective = current_user.quizzes.where(:objective => @objective).order(:created_at)
            if quizzes_with_same_objective.count > 5
               quizzes_with_same_objective.first.destroy
            end
        end
    
        def build_the_quiz
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
        end
    
        def establish_offer_next_try
            if @this_os.dc_keys > 0
                @offer_next_try = "dc"
            elsif @this_os.teacher_granted_keys > 0
                @offer_next_try = "teacher_granted"
            elsif @this_os.pretest_keys > 0
                @offer_next_try = "pretest"
            else
                @offer_next_try = "none"
            end
        end
    
    
end