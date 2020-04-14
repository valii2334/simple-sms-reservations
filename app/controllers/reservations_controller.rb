class ReservationsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_reservation

  load_and_authorize_resource

  def destroy
    set_locale

    if @reservation.destroy
      client.messages.create(
        from: @reservation.company.name,
        to: "+#{@reservation.phone_number}",
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
end
