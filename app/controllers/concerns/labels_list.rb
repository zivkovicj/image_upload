module LabelsList
    extend ActiveSupport::Concern
   
    def labels_to_offer
      labels_list = (current_user.role == "admin" ? Label.all : Label.where("user_id = ? OR extent = ?", current_user.id, "public"))
      return labels_list
    end
    
end