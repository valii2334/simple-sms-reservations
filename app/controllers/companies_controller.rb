class CompaniesController < ApplicationController
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_company, only: [:edit, :show, :update]
  load_and_authorize_resource

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params.merge(user_id: current_user.id))

    if @company.save
      render 'show'
    else
      render 'edit'
    end
  end

  def edit; end

  def show; end

  def update
    if @company.update(company_params)
      render 'show'
    else
      render 'edit'
    end
  end

  private

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
      :unit_of_time,
      :customers_per_unit_of_time,
      :opening_time_saturday,
      :closing_time_saturday,
      :opening_time_sunday,
      :closing_time_sunday
    )
  end
end
