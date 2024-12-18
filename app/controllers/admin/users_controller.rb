module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      add_password_to_params

      if @user.save!
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        render :new, alert: 'Failed to create the user.'
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :phone, :date_of_birth, :gender, :address,
                               :email, :role)
    end

    def add_password_to_params
      generated_password = SecureRandom.hex(8)
      @user.password = generated_password
      @user.password_confirmation = generated_password
    end
  end
end
