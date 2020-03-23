class MessagesController < ActionController::Base
  def inbound
    received_params = params.merge(parsed_body)

    message = Message.new(received_params)
    text_to_send = message.perform

    client.sms.send(
      from: 'VLZ DevOps',
      to: message.sender,
      text: text_to_send
    )

    render json: { status: 200, text: 'inbound' }
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
