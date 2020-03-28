require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let(:company) { create(:company) }

  context '#uniqueness' do
    before do
      Timecop.freeze(DateTime.new(2012, 07, 11))
    end

    after do
      Timecop.return
    end

    it 'can not create more than one reservation per day' do
      create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456789'
      reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456789'

      expect(reservation).to_not be_valid
      expect(reservation.errors.to_a[0]).to eql('You can not make more than one reservation per day for each company')
    end
  end

  describe '#company_is_open' do
    context 'weekday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 11))
      end

      after do
        Timecop.return
      end

      it 'can not create a reservation if company is temporarily closed' do
        company.update(temporarily_closed: true)
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456789'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql("#{company.name} is closed today. Our schedule is Monday - Friday: 09:00 AM - 10:00 AM. Saturday: Closed. Sunday: Closed. ")
      end

      it 'can create a reservation if company is open today' do
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456789'

        expect(reservation).to be_valid
      end
    end

    context 'Saturday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 14))
      end

      after do
        Timecop.return
      end

      it 'can not create a reservation if today is Saturday but the company is closed' do
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 14, 10, 0), phone_number: '0123456789'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql("#{company.name} is closed today. Our schedule is Monday - Friday: 09:00 AM - 10:00 AM. Saturday: Closed. Sunday: Closed. ")
      end

      it 'can create a reservation if today is Saturday and the company is open' do
        company.update(closed_saturday: false)
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 14, 10, 0), phone_number: '0123456789'

        expect(reservation).to be_valid
      end
    end

    context 'Sunday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 15))
      end

      after do
        Timecop.return
      end

      it 'can not create a reservation if today is Sunday but the company is closed' do
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 15, 14, 0), phone_number: '0123456789'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql("#{company.name} is closed today. Our schedule is Monday - Friday: 09:00 AM - 10:00 AM. Saturday: Closed. Sunday: Closed. ")
      end

      it 'can create a reservation if today is Sunday and the company is open' do
        company.update(closed_sunday: false)
        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 15, 14, 0), phone_number: '0123456789'

        expect(reservation).to be_valid
      end
    end
  end

  describe '#time_slot_still_available' do
    context 'weekday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 11))
      end

      after do
        Timecop.return
      end

      it 'can create a reservation if at least one spot is available' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)
      end

      it 'can not create a reservation if all slots are occupied' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)

        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 11, 9, 0), phone_number: '0123456784'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql('You can not make a reservation at this time. Next 3 available spot(s) are: 09:15,09:30,09:45')
      end
    end

    context 'Saturday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 14))
        company.update(closed_saturday: false)
      end

      after do
        Timecop.return
      end

      it 'can create a reservation if at least one spot is available' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 14, 10, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)
      end

      it 'can not create a reservation if all slots are occupied' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 14, 10, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)

        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 14, 10, 0), phone_number: '0123456784'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql('You can not make a reservation at this time. Next 3 available spot(s) are: 10:15,10:30,10:45')
      end
    end

    context 'Sunday' do
      before do
        Timecop.freeze(DateTime.new(2012, 07, 15))
        company.update(closed_sunday: false)
      end

      after do
        Timecop.return
      end

      it 'can create a reservation if at least one spot is available' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 15, 14, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)
      end

      it 'can not create a reservation if all slots are occupied' do
        company.update(customers_per_unit_of_time: 1)

        expect do
          create :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 15, 14, 0), phone_number: '0123456781'
        end.to change(company.reservations, :count).by(1)

        reservation = build :reservation, company: company, reservation_date:  DateTime.new(2012, 07, 15, 14, 0), phone_number: '0123456784'

        expect(reservation).to_not be_valid
        expect(reservation.errors.to_a[0]).to eql('You can not make a reservation at this time. Next 3 available spot(s) are: 14:15,14:30,14:45')
      end
    end
  end
end
