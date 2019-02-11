module SetPermissions
    extend ActiveSupport::Concern
    
    include SessionsHelper
    
    def set_permissions(target)
      thisId = target.user_id
      if current_user.type == "Admin"
          @assign_permission = "admin"
      else
        if thisId == current_user.id
          @assign_permission = "this_user"
        else
          @assign_permission = "other"
        end
      end

      if thisId == 0
        @created_by = "Mr. Z School"
      else
        @created_by = User.find(thisId).full_name_with_title
      end
    end
    
    
    
end