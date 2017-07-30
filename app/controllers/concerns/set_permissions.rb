module SetPermissions
    extend ActiveSupport::Concern
    
    include SessionsHelper
    
    def setPermissions(target)
      thisId = target.user_id
      if current_user.role == "admin"
          @assignPermission = "admin"
      else
        if thisId == current_user.id
          @assignPermission = "thisUser"
        else
          @assignPermission = "other"
        end
      end

      if thisId == 0
        @createdLabel = "EM Education"
      else
        @createdLabel = User.find(thisId).nameWithTitle
      end
    end
    
    
    
end