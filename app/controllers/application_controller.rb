# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def home
    if current_user
      signed_in
    else
      redirect_to new_user_session_path
    end
  end

  def signed_in
    unless current_user.companies.empty?
      redirect_to company_path(current_user.companies.first)
    else
      redirect_to new_company_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up)
    devise_parameter_sanitizer.permit(:account_update)
  end
end
