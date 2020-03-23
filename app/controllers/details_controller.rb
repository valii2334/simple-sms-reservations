class DetailsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def how_it_works; end
end
