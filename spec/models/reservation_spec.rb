require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:company) { create(:company) }

  context '#temporarily_closed' do
    it 'can not create a reservation if the company is temporarily_closed' do
      company.temporarily_closed = true
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2020,4,17,9,15), phone_number: '1234567890'

      expect(reservation).to_not be_valid
      expect(reservation.errors.full_messages.join('')).to include('is temporarily closed')
    end
  end

  context '#company_is_open' do
    it 'can not create a reservation if outside of business hours' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2020,4,17,8,0), phone_number: '1234567890'

      expect(reservation).to_not be_valid
      expect(reservation.errors.full_messages.join('')).to include('your reservation date is not between our business hours')
    end

    it 'can create a reservation if between business hours' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2020,4,17,9,0), phone_number: '1234567890'

      expect(reservation).to be_valid
    end
  end

  context 'time_slot_still_available' do
    it 'can not create a reservation if time slot is not available' do
      company.customers_per_unit_of_time = 1

      reservation = create :reservation, company: company, reservation_date: DateTime.new(2020,4,17,9,0), phone_number: '1234567891'
      reservation1 = build :reservation, company: company, reservation_date: DateTime.new(2020,4,17,9,0), phone_number: '1234567890'

      expect(reservation1).to_not be_valid
      expect(reservation1.errors.full_messages.join('')).to include('you can not make a reservation at this time')
    end
  end
end
