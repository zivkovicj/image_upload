class AdminsController < ApplicationController


    def show
        @admin = User.find(params[:id])
    end

end