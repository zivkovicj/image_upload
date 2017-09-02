module SetPermissions
    extend ActiveSupport::Concern
    
    include SessionsHelper
    
    def setPermissions(target)
      thisId = target.user_id
      if current_user.type == "Admin"
          @assignPermission = "admin"
      else
        if thisId == current_user.id
          @assignPermission = "thisUser"
        else
          @assignPermission = "other"
        end
      end

      if thisId == 0
        @createdLabel = "Mr. Z School"
      else
        @createdLabel = User.find(thisId).name_with_title
      end
    end
    
    
    
end