class Message
  attr_accessor :sender,
                :text,
                :reservation_date,
                :company_code,
                :company,
                :additional_details

  def initialize(message)
    @sender = message['msisdn']
    @text   = message['text']
    @company_code, @reservation_date, @additional_details = process_text
  end

  def perform
    return 'Message format is not valid.' if @company_code.nil? || @reservation_date.nil?
    return 'Company was not found.' if company_from_company_code.nil?
    create_reservation
  end

  def process_text
    store_code_and_reservation_date = @text.split(' ')[0]
    additional_details = @text.split(' ').drop(1).join(' ')

    store_code = store_code_and_reservation_date.split('/')[0]

    reservation_info = store_code_and_reservation_date.split('/')[1]
    reservation_info = Time.parse(reservation_info)
    reservation_date = DateTime.now.change({ hour: reservation_info.hour, min: reservation_info.min})

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
      phone_number: @sender,
      company_id: @company.id,
      details: additional_details
    )

    if reservation.save
      return 'Reservation succesfully created.'
    else
      return reservation.errors.full_messages.join(' ')
    end
  end
end
