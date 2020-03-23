require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:company) { create(:company) }

  context 'future reservation date' do
    it 'can not create a reservation if date is in the past' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2020,4,17,9,0), phone_number: '1234567890'

      expect(reservation).to_not be_valid
      expect(reservation.errors.full_messages.join('')).to eql(I18n.t('reservation.not_in_the_future', company_name: company.name))
    end

    it 'can create a reservation if date is in the future' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'

      expect(reservation).to be_valid
    end
  end

  context '#temporarily_closed' do
    it 'can not create a reservation if the company is temporarily_closed' do
      company.temporarily_closed = true
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,15), phone_number: '1234567890'

      expect(reservation).to_not be_valid
      expect(reservation.errors.full_messages.join('')).to eql(I18n.t('reservation.temporarily_closed', company_name: company.name, company_temporarily_closed_message: company.temporarily_closed_message))
    end
  end

  context '#company_is_open' do
    it 'can not create a reservation if outside of business hours' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2120,4,17,8,0), phone_number: '1234567890'

      expect(reservation).to_not be_valid
      expect(reservation.errors.full_messages.join('')).to eql(I18n.t('reservation.out_of_business_hour', company_name: company.name, company_schedule: company.schedule))
    end

    it 'can create a reservation if between business hours' do
      reservation = build :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'

      expect(reservation).to be_valid
    end
  end

  context 'time_slot_still_available' do
    it 'can not create a reservation if time slot is not available' do
      company.customers_per_unit_of_time = 1

      reservation = create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567891'
      reservation1 = build :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'

      expect(reservation1).to_not be_valid
      expect(reservation1.errors.full_messages.join('')).to eql(I18n.t('reservation.reservation_slot_still_available', company_name: company.name, next_slots: company.available_time_slots_after_given_date_time_to_string(DateTime.new(2120,4,17,9,0), 3)))
    end
  end
end
