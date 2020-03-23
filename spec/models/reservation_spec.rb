require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:reservation) { create(:reservation) }
  let(:company) { create(:company) }
  ##################################
  # Attribute existence
  ##################################

  it { should have_attribute :reservation_date }
  it { should have_attribute :phone_number }
  it { should belong_to(:company).without_validating_presence }

  ##################################
  # Validations
  ##################################

  it { reservation.should validate_presence_of :phone_number }

  context '#uniqueness' do
    it 'can not create a reservation with same company_id, reservation_date, phone_number' do
      create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456789'
      reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456789'

      expect(reservation).to_not be_valid
      expect(reservation.errors.to_a[0]).to eql('Reservation date you already reserved this date')
    end
  end

  context '#company_is_open' do
    it 'can not create a reservation if company is closed' do
      company.update(temporarily_closed: true)
      reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456789'

      expect(reservation).to_not be_valid
      expect(reservation.errors.to_a[0]).to eql("Company #{company.name} is closed today.")
    end
  end

  context '#time_slot_still_available' do
    it 'can not create a reservation if all slots are occupied' do
      expect do
        create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456781'
      end.to change(company.reservations, :count).by(1)

      expect do
        create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456782'
      end.to change(company.reservations, :count).by(1)

      expect do
        create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456783'
      end.to change(company.reservations, :count).by(1)

      expect {
        create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 00, 0), phone_number: '0123456784'
      }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
