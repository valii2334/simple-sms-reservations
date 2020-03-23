class MessagesController < ApplicationController
  def inbound
    render json: { text: 'inbound' }
  end

  def delivery
    render json: { text: 'deliver' }
  end

  def status
    render json: { text: 'status'}
  end

  private

  def client
    Nexmo::Client.new(
      api_key: ENV['NEXMO_API_KEY'],
      api_secret: ENV['NEXMO_API_SECRET']
    )
  end
end
