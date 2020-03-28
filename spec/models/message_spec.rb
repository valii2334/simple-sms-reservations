require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    Timecop.freeze(DateTime.new(2012, 07, 11))
  end

  after do
    Timecop.return
  end

  context '#process_text' do
    it 'should return correct data' do
      message = Message.new('0123456789', 'VlzDevOps/12:00')

      expect(message.sender).to eql('0123456789')
      expect(message.text).to eql('VlzDevOps/12:00')
      expect(message.reservation_date).to eql(DateTime.now.in_time_zone.beginning_of_day.change({hour: '12:00'.to_datetime.hour, min: '12:00'.to_datetime.min}))
      expect(message.company_code).to eql('VlzDevOps')
    end
  end

  context '#perform' do
    describe 'message format' do
      it 'returns Message format is not valid. if not a valid format is sent' do
        message = Message.new('0123456789', 'Some random text')
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if time is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps/aa')
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if hour is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps/a:00')
        expect(message.perform).to eql('Message format is not valid.')
      end

      it 'returns Message format is not valid. if minute is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps/1:aa')
        expect(message.perform).to eql('Message format is not valid.')
      end
    end

    describe 'company code' do
      it 'returns Company was not found. if no company code is provided' do
        message = Message.new('0123456789', '/18:00')
        expect(message.perform).to eql('Company was not found.')
      end

      it 'returns Company was not found. if random company code is provided' do
        message = Message.new('0123456789', 'randomCode/18:00')
        expect(message.perform).to eql('Company was not found.')
      end
    end

    describe 'reservation' do
      it 'returns company is closed if company is closed' do
        company = create :company, temporarily_closed: true

        message = Message.new('0123456789', "#{company.code}/09:00")
        expect(message.perform).to eql("#{company.name} is closed today. Our schedule is Monday - Friday: 09:00 AM - 10:00 AM. Saturday: Closed. Sunday: Closed. ")
      end

      it 'returns time slot not available if invalid time is provided' do
        company = create :company

        message = Message.new('0123456789', "#{company.code}/08:00")
        expect(message.perform).to eql('You can not make a reservation at this time. Next 3 available spot(s) are: 09:00,09:15,09:30')
      end

      it 'returns time slot not available if time slot is occupied' do
        company = create :company, customers_per_unit_of_time: 1

        message = Message.new('0123456789', "#{company.code}/09:00")
        expect(message.perform).to eql('Reservation succesfully created.')

        message = Message.new('0123456788', "#{company.code}/09:00")
        expect(message.perform).to eql('You can not make a reservation at this time. Next 3 available spot(s) are: 09:15,09:30,09:45')
      end
    end
  end
end
