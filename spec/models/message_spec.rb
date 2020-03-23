require 'rails_helper'

RSpec.describe Message, type: :model do
  let!(:company) { create :company }

  context '#process_text' do
    it 'should return correct data' do
      message = Message.new('0123456789', 'VlzDevOps 09/12 12:00')

      expect(message.sender).to eql('0123456789')
      expect(message.reservation_date).to eql(DateTime.new(2020, 12, 9, 12, 0))
      expect(message.company_code).to eql('VlzDevOps')
    end
  end

  context '#perform' do
    describe 'message format' do
      it 'returns Message format is not valid. if time is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps aa')
        expect(message.perform).to eql(I18n.t 'message.wrong_format')
      end

      it 'returns Message format is not valid. if hour is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps a:00')
        expect(message.perform).to eql(I18n.t 'message.wrong_format')
      end

      it 'returns Message format is not valid. if minute is not sent correctly' do
        message = Message.new('0123456789', 'VlzDevOps 1:aa')
        expect(message.perform).to eql(I18n.t 'message.wrong_format')
      end
    end

    describe 'company code' do
      it 'returns Company was not found. if no company code is provided' do
        message = Message.new('0123456789', 'a 01/01 18:00')
        expect(message.perform).to eql(I18n.t 'message.company_not_found')
      end

      it 'returns Company was not found. if random company code is provided' do
        message = Message.new('0123456789', 'randomCode 01/01 18:00')
        expect(message.perform).to eql(I18n.t 'message.company_not_found')
      end
    end

    describe 'reservation' do
      it 'returns company is temporarily closed  if company is closed temporarily_closed' do
        company.update(temporarily_closed: true)

        message = Message.new('0123456789', "VlzDevOps 01/01/2120 09:00")
        expect(message.perform).to eql(I18n.t('reservation.temporarily_closed', company_name: company.name, company_temporarily_closed_message: company.temporarily_closed_message))
      end

      it 'returns company is closed if not between business hours' do
        message = Message.new('0123456789', "VlzDevOps 01/01/2120 08:00")
        expect(message.perform).to eql(I18n.t('reservation.out_of_business_hour', company_name: company.name, company_schedule: company.schedule))
      end

      it 'returns time slot not available if time slot is occupied' do
        company.update(customers_per_unit_of_time: 1)

        message = Message.new('0123456789', "VlzDevOps 01/01/2120 09:00")
        expect(message.perform).to eql(I18n.t 'reservation.created', company_name: company.name, reservation_date: DateTime.new(2120, 1, 1, 9, 0).strftime('%d %B, %H:%M'), reservation_message: company.reservation_message)

        message = Message.new('0123456788', "VlzDevOps 01/01/2120 09:00")
        expect(message.perform).to eql(I18n.t('reservation.reservation_slot_still_available', company_name: company.name, next_slots: company.available_time_slots_after_given_date_time_to_string(DateTime.new(2120,1,1,9,0), 3)))
      end
    end
  end
end
