class CompaniesController < ApplicationController
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_company, only: [:edit, :show, :update]
  before_action :set_new_company, only: [:new]

  load_and_authorize_resource

  def new; end

  def edit; end

  def show; end

  def create
    @company = Company.new(company_params.merge(user_id: current_user.id))

    if @company.save
      render 'show'
    else
      render 'edit'
    end
  end

  def update
    if @company.update(company_params)
      render 'show'
    else
      render 'edit'
    end
  end

  private

  def set_new_company
    @company = Company.new
  end

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(
      :name,
      :code,
      :opening_time,
      :closing_time,
      :closed_saturday,
      :closed_sunday,
      :temporarily_closed,
      :temporarily_closed_message,
      :unit_of_time,
      :customers_per_unit_of_time,
      :opening_time_saturday,
      :closing_time_saturday,
      :opening_time_sunday,
      :closing_time_sunday,
      :reservation_message
    )
  end
end
