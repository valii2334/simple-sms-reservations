class ReservationsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_reservation

  load_and_authorize_resource

  def destroy
    company_id = @reservation.company.id
    reservation_phone_number = @reservation.phone_number

    if @reservation.destroy
      twiml = Twilio::TwiML::MessagingResponse.new do |r|
        r.message(
          from: ENV['TWILIO_NUMBER'],
          to: reservation_phone_number,
          body: params[:cancel_reservation_message]
        )
      end
    end

    redirect_to company_path(id: company_id)
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end
end
