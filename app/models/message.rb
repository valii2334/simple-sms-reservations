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
  end

  def perform
    return "Message format is not valid. Message example: CompanyCode 14:00" if @company_code.nil? || @reservation_date.nil?
    return "Company was not found. Message example: CompanyCode 14:00"       if company_from_company_code.nil?
    create_reservation
  end

  def process_text
    store_code         = @text.split(' ')[0]
    reservation_date   = datetime_from_time(@text.split(' ')[1])
    additional_details = @text.split(' ').drop(2).join(' ')

    return store_code, reservation_date, additional_details
  rescue
    return nil, nil, nil
  end

  def company_from_company_code
    @company = Company.find_by(code: @company_code.downcase)
  end

  def create_reservation
    reservation = Reservation.new(
      reservation_date: @reservation_date,
      phone_number:     @sender,
      company_id:       @company.id,
      details:          additional_details
    )

    if reservation.save
      return "Reservation created for #{@company.name} at #{hour_min_am_pm(@reservation_date)}. #{@company.reservation_message}"
    else
      return reservation.errors.full_messages.join('.')
    end
  end
end
