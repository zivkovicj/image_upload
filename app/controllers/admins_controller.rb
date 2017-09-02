class AdminsController < ApplicationController


    def show
        @admin = User.find(params[:id])
    end
    
    def edit
        @admin = Admin.find(params[:id])
    end

    def update
        @admin = Admin.find(params[:id])
        if @admin.update_attributes(admin_params)
          flash[:success] = "Profile updated" 
          redirect_to current_user
        else
          render 'edit'
        end
    end
    
    
    def admin_params
      params.require(:admin).permit(:first_name, :last_name, :title, :email, :password, 
                                :password_confirmation, :current_class, :user_number)
    end

end