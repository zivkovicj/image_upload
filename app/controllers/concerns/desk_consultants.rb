
module DeskConsultants
    extend ActiveSupport::Concern
    
    include TeachAndLearnOptions
    include SetObjectivesAndScores
    
    # Populate preList with all students who are present today
    def setup_present_students()
      stud_list = []
      @seminar.seminar_students.each do |ss|
        if ss.present
          student = @seminar.students.find(ss.user_id)
          stud_list.push(student)
        end
      end
      return stud_list
    end
    
    def setupProfList()
        # The main array that is actually used is profList, which sorts students
        # by their total scores
        @profList = @students.sort {|a,b| a.total_points <=> b.total_points}
    end
    
    # Rank students by their adjusted consultant points.
    def setupRankByConsulting()
        @rankByConsulting = @students.sort {|a,b| 
            a.appliedConsultPoints(@seminar) <=> 
            b.appliedConsultPoints(@seminar)}
    end
    
    
    # studentHash
    def setupStudentHash()
      @studentHash = Hash.new
      @students.each do |student|
        studId = student.id
        @studentHash[studId] = Hash.new
        @studentHash[studId][:firstPlusInit] = student.firstPlusInit
        this_ss = student.seminar_students.find_by(:seminar_id => @seminar.id)
        @studentHash[studId][:teach_request] = this_ss.teach_request
        @studentHash[studId][:learn_request] = this_ss.learn_request
        @studentHash[studId][:pref_request] = this_ss.pref_request
        @studentHash[studId][:appliedConsultPoints] = student.appliedConsultPoints(@seminar)
      end
    end          
    
    # scoreHash
    def setupScoreHash()
      @scoreHash = Hash.new
      @seminar.objectives.each do |objective|
        os = objective.objective_seminars.find_by(:seminar => @seminar)
        @scoreHash[objective.id] = Hash.new
        @scoreHash[objective.id][:priority] = os.priority
        @scoreHash[objective.id][:need] = objective.students_in_need(@seminar)
        @students.each do |student|
          @scoreHash[objective.id][student.id] = Hash.new
          thisScore = student.objective_students.find_by(:objective_id => objective.id)
          if thisScore
            @scoreHash[objective.id][student.id][:score] = thisScore.points
          else
            @scoreHash[objective.id][student.id][:score] = 0
          end
          
          @scoreHash[objective.id][student.id][:ready] = student.check_if_ready(objective)
        end
      end
    end
  
    # Establish a new consultant group
    def establish_new_group(stud, req, isConsult, bracket, blap)
      # Bracket 0 = normal
      # Bracket 1 = unplaced students
      # Bracket 2 = absent students
      new_team = @consultancy.teams.build(:objective => req, :bracket => bracket)
      new_team.consultant = stud if isConsult
      new_team.save
      new_team.users << stud
      @scoreHash[req.id][:need] -= 3
    end
    
    def need_placement(student)
      !@consultancy.users.include?(student)
    end
    
    # Choose the consultants
    def chooseConsultants ()
      classSize = @students.count
      @consultantsNeeded = (classSize/4.to_f).ceil
    
      def checkForFinalBreak()
        @consultancy.teams.count >= @consultantsNeeded ? true : false
      end
      
      # First look at the priority 3 objectives
      @seminar.objective_seminars.where(:priority => 3).each do |os|
        objective = os.objective
        @rankByConsulting.each do |student|
          if need_placement(student)
            if @scoreHash[objective.id][student.id][:score] >= @cThresh && @scoreHash[objective.id][:need] > 0
              establish_new_group(student, objective, 4, 0, 1)
              break
            end
          end
        end
        return if checkForFinalBreak()
      end
      
      # Then look at students in order of increasing consultant points 
      @rankByConsulting.each do |student|
        if need_placement(student)
          # See if student's consultant request will work.
          thisRequest = @studentHash[student.id][:teach_request]
          if @scoreHash[thisRequest]
            a = @scoreHash[thisRequest][:need] > 0
            b = @scoreHash[thisRequest][student.id][:score] >= @cThresh
            c = @scoreHash[thisRequest][:priority] > 0
            if a && b && c 
              establish_new_group(student, thisRequest, 4, 0, 2)
              next
            end
          end
          # If the request didn't work out, look at the student's teach_options
          @student_scores = student.objective_students.where(objective_id: @objectiveIds)
          @teach_options = teach_options(student, @seminar, 3)
          @teach_options.each do |objective|
            if @scoreHash[objective.id][:need] > 0
              establish_new_group(student, objective, 4, 0, 3)
              break
            end
          end
          return if checkForFinalBreak()
        end
      end
    end


    
    ## SORT APPRENTICES INTO CONSULTANT GROUPS ##

    # First, try to place apprentices into groups offering their learn Requests
    def placeApprenticesByRequests()
      @profList.each do |student|
        if need_placement(student)
          thisRequest = @studentHash[student.id][:learn_request]
          if @scoreHash[thisRequest]
            thisScore = @scoreHash[thisRequest][student.id][:score]
            if @scoreHash[thisRequest][:priority] > 0 && thisScore < 100 && @scoreHash[thisRequest][student.id][:ready]
              @consultancy.teams.each do |team|
                if (team.objective == thisRequest) && (team.has_room)
                  team.users << stud
                  break
                end
              end
            end
          end
        end
      end
    end
    
    # Most students probably won't be placed by their requests. 
    def placeApprenticesByMastery()
      @profList.each do |student|
        find_placement(student) if need_placement(student)
      end
    end
    
    
    # Method for looking for a placement for the student
    def find_placement(student)
      placed = nil
      @consultancy.teams.each do |team|
        if (team.has_room)
          this_assign_id = team.objective.id
          studentScore = @scoreHash[this_assign_id][student.id][:score] # Student's score for current objective
          # Note that the score can be >= the lowThresh to allow for zero. But
          # it must be < highThresh so that students with 100 don't get placed there
          if (studentScore < @cThresh) && @scoreHash[this_assign_id][student.id][:ready]
            team.users << student
            placed = this_assign_id
            break
          end
        end
      end
      return placed
    end
    
    def checkForLoneStudents()
      @consultancy.teams.each do |team|
        @consultancy.teams.delete(team) if team.users.count == 1
      end
    end
    
    def newPlaceForLoneStudents
      @profList.reverse.each do |student|
        if need_placement(student)
          # First, check whether lone student can be placed into an established group
          if find_placement(student) == nil
            # If not, try establish a new group for that student. This function is
            # smelly, but I'm doing it in this order so that other lone students
            # might also join this group.
            
            # Second, try the student's learn_request
            thisRequest = @studentHash[student.id][:learn_request]
            if @scoreHash[thisRequest] && @scoreHash[thisRequest][student.id][:score] < @cThresh && @scoreHash[thisRequest][student.id][:ready] && @scoreHash[thisRequest][:priority] > 0
              establish_new_group(student, thisRequest, 0, 0, 4)
            else
              # Last resort is to scan all objectives 
              @rankAssignsByNeed.each do |objective|
                if @scoreHash[objective.id][student.id][:score] < @cThresh && @scoreHash[objective.id][student.id][:ready]
                  establish_new_group(student, objective, 0, 0, 5)
                  break
                end
              end
            end
          end
        end
      end
    end
  
    def assignSGSections()
      # In the future, it might be cool to bring back this feature. Gives each
      # team member a number, which could correspond to different roles of the
      # activity.
      
      @consultancy.teams.each do |team|
        currAssign = 1
        rev[:group].each_with_index do |groupMember, index|
          if rev[:consultant][index] == 0
            rev[:consultant][index] = currAssign
            currAssign = currAssign + 1
          end
        end
      end
    end
    
    def areSomeUnplaced()
      @profList.each do |student|
        if need_placement(student)
          establish_new_group(student,nil,0,1,6)
        end
      end
    end
end