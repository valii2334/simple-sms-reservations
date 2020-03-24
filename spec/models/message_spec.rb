require 'rails_helper'

RSpec.describe Message, type: :model do
  context '#process_text' do
    it 'should return correct data' do
      message = Message.new({ 'msisdn' => '0123456789', 'text' => 'VlzDevOps/12:00' })

      expect(message.sender).to eql('0123456789')
      expect(message.text).to eql('VlzDevOps/12:00')
      expect(message.reservation_date).to eql(DateTime.now.change({ hour: 12, min: 0}))
      expect(message.company_code).to eql('VlzDevOps')
    end
  end

  context '#perform' do
    describe 'message format' do
      it 'returns Message format is not valid. if not a valid format is sent' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => 'Some random text' })
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if time is not sent correctly' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => 'VlzDevOps/aa' })
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if hour is not sent correctly' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => 'VlzDevOps/a:00' })
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if minute is not sent correctly' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => 'VlzDevOps/1:aa' })
        expect(message.perform).to eql('Message format is not valid.')
      end
    end

    describe 'company code' do
      it 'returns Company was not found. if no company code is provided' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => '/18:00' })
        expect(message.perform).to eql('Company was not found.')
      end

      it 'returns Company was not found. if random company code is provided' do
        message = Message.new({ 'msisdn' => '0123456789', 'text' => 'randomCode/18:00' })
        expect(message.perform).to eql('Company was not found.')
      end
    end

    describe 'reservation' do
      it 'returns company is closed if company is closed' do
        company = create :company, temporarily_closed: true

        message = Message.new({ 'msisdn' => '0123456789', 'text' => "#{company.code}/09:00" })
        expect(message.perform).to eql("Company #{company.name} is closed today")
      end

      it 'returns time slot not available if invalid time is provided' do
        company = create :company

        message = Message.new({ 'msisdn' => '0123456789', 'text' => "#{company.code}/08:00" })
        expect(message.perform).to eql('Reservation date can not be booked anymore')
      end

      it 'returns time slot not available if time slot is occupied' do
        company = create :company, customers_per_unit_of_time: 1

        message = Message.new({ 'msisdn' => '0123456789', 'text' => "#{company.code}/09:00" })
        expect(message.perform).to eql('Reservation succesfully created.')

        message = Message.new({ 'msisdn' => '0123456788', 'text' => "#{company.code}/09:00" })
        expect(message.perform).to eql('Reservation date can not be booked anymore')
      end
    end
  end
end
