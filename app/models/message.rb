# frozen_string_literal: true

require 'time_utils'

class Message
  include TimeUtils

  attr_accessor :sender,
                :text,
                :reservation_date,
                :company_code,
                :company,
                :additional_details

  def initialize(sender, text)
    @sender = sender
    @text   = text
    @company_code, @reservation_date, @additional_details = process_text
    set_locale
  end

  def perform
    return I18n.t 'message.wrong_format' if @company_code.nil? || @reservation_date.nil?
    return I18n.t 'message.company_not_found' if company_from_company_code.nil?

    create_reservation
  end

  def process_text
    store_code         = @text.split(' ')[0]
    date_text          = @text.split(' ')[1]
    time_text          = @text.split(' ')[2]
    reservation_date   = datetime_from_text(date_text, time_text)
    additional_details = @text.split(' ').drop(3).join(' ')

    [store_code, reservation_date, additional_details]
  rescue
    [nil, nil, nil]
  end

  def company_from_company_code
    @company = Company.find_by(code: @company_code.downcase)
  end

  def create_reservation
    reservation = Reservation.new(
      reservation_date: @reservation_date,
      phone_number: @sender,
      company_id: @company.id,
      details: additional_details
    )

    if reservation.save
      I18n.t 'reservation.created',
             company_name: @company.name,
             reservation_date: @reservation_date.strftime('%H:%M %p'),
             reservation_message: @company.reservation_message
    else
      reservation.errors.full_messages.join('.')
    end
  end

  def set_locale
    if Phonelib.parse(@sender).country == 'RO'
      I18n.default_locale = :ro
    else
      I18n.default_locale = :en
    end
  end
end
