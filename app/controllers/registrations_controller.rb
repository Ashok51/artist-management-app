# frozen_string_literal: true

# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  protected

  def after_sign_up_path_for(_resource)
    reset_session
    flash[:notice] = 'Account created successfully. Please sign in.'
    new_user_session_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:first_name, :last_name, :phone,
               :date_of_birth, :gender, :address,
               :email, :password)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:first_name, :last_name, :phone,
               :date_of_birth, :gender, :address,
               :email, :password, :password_confirmation,
               :role, :current_password)
    end
  end
end
