class ReservationsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_reservation, only: [:destroy]

  load_and_authorize_resource

  def create
    @reservation = Reservation.create(reservation_params)

    redirect_to company_path(
      id: @reservation.company_id,
      date: @reservation.reservation_date.to_datetime.strftime('%Q')
    )
  end

  def destroy
    set_locale

    if @reservation.destroy
      client.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: @reservation.phone_number,
        body: I18n.t('reservation.canceled',
                     company_name: @reservation.company.name,
                     reservation_date: @reservation.reservation_date.strftime('%d %B, %H:%M %p'),
                     cancel_message: params[:cancel_reservation_message]
                    )
      )
    end

    redirect_to company_path(id: @reservation.company_id)
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def set_locale
    case Phonelib.parse(@reservation.phone_number).country
    when 'RO'
      I18n.default_locale = :ro
    else
      I18n.default_locale = :en
    end
  end

  def client
    Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

  def reservation_params
    params.require(:reservation).permit(
      :reservation_date,
      :phone_number,
      :company_id,
      :details
    )
  end
end
