module BuildPreReqLists
    extend ActiveSupport::Concern
    
    include SessionsHelper
    
    def build_pre_req_list(target_assign)
      
      bad_ids = [target_assign.id]
      target_assign.mainassigns.each do |mainassign|
        bad_ids.push(mainassign.id)
      end
      
      objectives_list = (current_user.role == "admin" ? Objective.all : Objective.where("user_id = ? OR extent = ?", current_user.id, "public"))
      
      return objectives_list.where.not(:id => bad_ids).order(:name)
      
    end
    
end