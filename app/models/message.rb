# frozen_string_literal: true

require 'time_utils'

class Message
  include ::TimeUtils

  attr_accessor :sender,
                :reservation_date,
                :company_code,
                :additional_details

  def initialize(sender, text)
    @sender = sender
    @company_code, reservation_date, @additional_details = process_text(text)
    @reservation_date = process_date(reservation_date)
    set_locale
  end

  def perform
    return I18n.t 'message.company_not_found' if company_from_company_code.nil?
    return I18n.t 'message.wrong_format' if @reservation_date.nil?

    create_reservation
  end

  def process_text(text)
    store_code         = text.split(' ')[0]
    date_text          = text.split(' ')[1]
    time_text          = text.split(' ')[2]
    reservation_date   = [date_text, time_text].join(' ')
    additional_details = text.split(' ').drop(3).join(' ')

    [store_code, reservation_date, additional_details]
  end

  def process_date(reservation_date)
    datetime_from_text(reservation_date, company_from_company_code.try(:date_format) || 'DMY')
  end

  def company_from_company_code
    @company ||= Company.find_by(code: @company_code.downcase)
  end

  def create_reservation
    reservation = Reservation.new(
      reservation_date: @reservation_date,
      phone_number: @sender,
      company_id: company_from_company_code.id,
      details: additional_details
    )

    if reservation.save
      I18n.t 'reservation.created',
             company_name: company_from_company_code.name,
             reservation_date: day_month_hour_min(@reservation_date),
             reservation_message: company_from_company_code.reservation_message
    else
      reservation.errors.full_messages.join('.')
    end
  end

  def set_locale
    case Phonelib.parse(@sender).country
    when 'RO'
      I18n.default_locale = :ro
    else
      I18n.default_locale = :en
    end
  end
end
