class ReservationsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_reservation

  load_and_authorize_resource

  def destroy
    duped_reservation = @reservation.dup
    company = @reservation.company

    if @reservation.destroy
      client.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: duped_reservation.phone_number,
        body: "#{company.name} reservation from
               #{duped_reservation.reservation_date.strftime('%d %B, %H:%M %p')}
               was cancelled with the following message: #{params[:duped_reservation]}"
      )
    end

    redirect_to company_path(id: company_id)
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def client
    Twilio::REST::Client.new ENV['ACd2e04b1473ad8ed895b9f98ba38e46dc'], ENV['f9f789def220dc9c0e6d651afe67fed1']
  end
end
