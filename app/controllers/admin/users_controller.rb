# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[edit update destroy]

    def index
      @users = policy_scope(User)
    end

    def new
      @user = User.new
      authorize @user
    end

    def create
      @user = User.new(user_params)

      authorize @user

      add_password_to_params

      if @user.save!
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        render :new, alert: 'Failed to create the user.'
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        flash.now[:alert] = 'Failed to update the user.'
        render :edit
      end
    end

    def destroy
      authorize @user
      
      if @user.destroy
        redirect_to admin_users_path, notice: 'User was successfully deleted.'
      else
        redirect_to admin_users_path, alert: 'Failed to delete the user. Please try again.'
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

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: 'User not found.'
    end
  end
end
