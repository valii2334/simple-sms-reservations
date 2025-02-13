class MessagesController < ActionController::Base
  def inbound
    received_params = params.merge(parsed_body)

    message = Message.new(received_params['msisdn'], received_params['text'])

    client.sms.send(
      from: ENV['NEXMO_NUMBER'],
      to: message.sender,
      text: message.perform
    )

    render json: { status: 200, text: 'inbound' }
  end

  def inbound_twilio
    received_params = params.merge(parsed_body)

    message = Message.new(received_params['From'], received_params['Body'])

    twiml = Twilio::TwiML::MessagingResponse.new do |r|
      r.message(
        from: ENV['TWILIO_NUMBER'],
        to: message.sender,
        body: message.perform
      )
    end

    render xml: twiml.to_s
  end

  def delivery
    render json: { status: 200, text: 'delivery' }
  end

  def status
    render json: { status: 200, text: 'status' }
  end

  private

  def client
    Nexmo::Client.new(
      api_key: ENV['NEXMO_API_KEY'],
      api_secret: ENV['NEXMO_API_SECRET']
    )
  end

  def parsed_body
     json? ? JSON.parse(request.body.read) : {}
  end

  def json?
    request.content_type == 'application/json'
  end
end
