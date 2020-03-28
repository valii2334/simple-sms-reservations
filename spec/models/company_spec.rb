require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { build(:company) }

  ##################################
  # Attribute existence
  ##################################

  it { should have_attribute :name }
  it { should have_attribute :code }
  it { should have_attribute :opening_time }
  it { should have_attribute :closing_time }
  it { should have_attribute :opening_time_saturday }
  it { should have_attribute :closing_time_saturday }
  it { should have_attribute :opening_time_sunday }
  it { should have_attribute :closing_time_sunday }
  it { should have_attribute :unit_of_time }
  it { should have_attribute :customers_per_unit_of_time }
  it { should have_attribute :closed_saturday }
  it { should have_attribute :closed_sunday }
  it { should have_attribute :temporarily_closed }
  it { should have_many :reservations }
  it { should belong_to(:user).without_validating_presence }

  ##################################
  # Validations
  ##################################

  it { company.should validate_presence_of :name }
  it { company.should validate_presence_of :opening_time }
  it { company.should validate_presence_of :closing_time }
  it { company.should validate_numericality_of(:unit_of_time).is_greater_than_or_equal_to(1) }
  it { company.should validate_numericality_of(:customers_per_unit_of_time).is_greater_than_or_equal_to(1) }
  it { company.should validate_uniqueness_of(:name) }
  it { company.should validate_uniqueness_of(:code) }

  context '#code' do
    it 'is not valid if empty' do
      company.code = ''
      expect(company).to_not be_valid
    end

    it 'is not valid if contains illegal characters' do
      company.code = '@VLZDevOps'
      expect(company).to_not be_valid
    end

    it 'is valid if contains only letters, numbers and dot' do
      company.code = 'vlzdevops'
      expect(company).to be_valid

      company.code = '01vlzdevops'
      expect(company).to be_valid

      company.code = '01vlzdevops.'
      expect(company).to be_valid
    end
  end

  context '#closing_time_bigger_than_oppening_time' do
    it 'is not valid if closing_time is less than opening_time' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 8, 0)

      expect(company).to_not be_valid
    end

    it 'is not valid if closing_time is equal to opening_time' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 9, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is bigger than opening_time' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 0)

      expect(company).to be_valid
    end
  end

  context '#closing_time_bigger_than_oppening_time_saturday' do
    it 'is not valid if closing_time is less than opening_time' do
      company.closed_saturday = false
      company.opening_time_saturday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_saturday = DateTime.new(2012, 07, 11, 8, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is less than opening_time but closed_saturday is true' do
      company.closed_saturday = true
      company.opening_time_saturday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_saturday = DateTime.new(2012, 07, 11, 8, 0)

      expect(company).to be_valid
    end

    it 'is not valid if closing_time is equal to opening_time' do
      company.closed_saturday = false
      company.opening_time_saturday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_saturday = DateTime.new(2012, 07, 11, 9, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is bigger than opening_time' do
      company.closed_saturday = false
      company.opening_time_saturday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_saturday = DateTime.new(2012, 07, 11, 10, 0)

      expect(company).to be_valid
    end
  end

  context '#closing_time_bigger_than_oppening_time_sunday' do
    it 'is not valid if closing_time is less than opening_time' do
      company.closed_sunday = false
      company.opening_time_sunday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_sunday = DateTime.new(2012, 07, 11, 8, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is less than opening_time but closed_sunday is true' do
      company.closed_sunday = true
      company.opening_time_sunday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_sunday = DateTime.new(2012, 07, 11, 8, 0)

      expect(company).to be_valid
    end

    it 'is not valid if closing_time is equal to opening_time' do
      company.closed_sunday = false
      company.opening_time_sunday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_sunday = DateTime.new(2012, 07, 11, 9, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is bigger than opening_time' do
      company.closed_sunday = false
      company.opening_time_sunday = DateTime.new(2012, 07, 11, 9, 0)
      company.closing_time_sunday = DateTime.new(2012, 07, 11, 10, 0)

      expect(company).to be_valid
    end
  end

  ##################################
  # Methods
  ##################################

  describe 'weekday' do
    before do
      Timecop.freeze(DateTime.new(2012, 07, 11))
    end

    after do
      Timecop.return
    end

    context '#available_reservation_times' do
      it 'returns available reservation times between 09:00 and 10:00' do
        company.opening_time = DateTime.new(2012, 07, 11, 9, 0)
        company.closing_time = DateTime.new(2012, 07, 11, 10, 0)

        expect(company.available_reservation_times).to eql(
          [
            DateTime.new(2012, 07, 11, 9, 0).strftime('%H:%M'),
            DateTime.new(2012, 07, 11, 9, 15).strftime('%H:%M'),
            DateTime.new(2012, 07, 11, 9, 30).strftime('%H:%M'),
            DateTime.new(2012, 07, 11, 9, 45).strftime('%H:%M')
          ]
        )
      end

      it 'returns available reservation times between 09:02 and 9:30' do
        company.opening_time = DateTime.new(2012, 07, 11, 9, 02)
        company.closing_time = DateTime.new(2012, 07, 11, 9, 30)

        expect(company.available_reservation_times).to eql(
          [
            DateTime.new(2012, 07, 11, 9, 02, 0).strftime('%H:%M')
          ]
        )
      end
    end

    context '#open_today?' do
      it 'returns false if temporarily_closed' do
        company.temporarily_closed = true

        expect(company.open_today?).to eql(false)
      end
    end

    describe '#reservation_time_available?' do
      it 'returns false if invalid time is provided' do
        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 10))).to eql(false)
      end

      it 'returns true if valid time is provided' do
        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 0))).to eql(true)
      end

      it 'returns false if all time slots at 9:00 are occupied' do
        create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 0)
        create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 0)
        create :reservation, company: company, phone_number: '0123456783', reservation_date: DateTime.new(2012, 07, 11, 9, 0)

        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 00, 0))).to eql(false)
      end

      it 'returns true if one time slots at 9:00 is available' do
        create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 0)
        create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 0)

        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 0))).to eql(true)
      end
    end

    context '#schedule' do
      it 'closed weekend' do
        company.opening_time = DateTime.new(2012, 07, 11, 9, 02)
        company.closing_time = DateTime.new(2012, 07, 11, 9, 30)

        expect(company.schedule).to eql('Monday - Friday: 09:02 AM - 09:30 AM. Saturday: Closed. Sunday: Closed. ')
      end

      it 'open on weekend' do
        company.closed_saturday = false
        company.closed_sunday = false

        expect(company.schedule).to eql('Monday - Friday: 09:00 AM - 10:00 AM. Saturday: 10:00 AM - 12:00 PM. Sunday: 14:00 PM - 16:00 PM. ')
      end
    end

    describe '#next_available_time_slots' do
      it 'returns next 3 available time slots 09:12, 09:17, 09:22' do
        company.customers_per_unit_of_time = 1
        company.unit_of_time = 5
        company.opening_time = DateTime.new(2012, 07, 11, 9, 02)
        company.closing_time = DateTime.new(2012, 07, 11, 9, 30)

        create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 02)
        create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 07)

        expect(company.next_available_time_slots(DateTime.new(2012, 07, 11, 9, 02), 3)).to eql(['09:12', '09:17', '09:22'])
      end

      it 'returns next 2 available time slots 09:12, 09:17' do
        company.customers_per_unit_of_time = 1
        company.unit_of_time = 5
        company.opening_time = DateTime.new(2012, 07, 11, 9, 02)
        company.closing_time = DateTime.new(2012, 07, 11, 9, 30)

        create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 02)
        create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 07)

        expect(company.next_available_time_slots(DateTime.new(2012, 07, 11, 9, 02), 2)).to eql(['09:12', '09:17'])
      end

      it 'returns next 2 available time slots 09:12, 09:22' do
        company.customers_per_unit_of_time = 1
        company.unit_of_time = 5
        company.opening_time = DateTime.new(2012, 07, 11, 9, 02)
        company.closing_time = DateTime.new(2012, 07, 11, 9, 30)

        create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 02)
        create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 07)
        create :reservation, company: company, phone_number: '0123456783', reservation_date: DateTime.new(2012, 07, 11, 9, 17)

        expect(company.next_available_time_slots(DateTime.new(2012, 07, 11, 9, 02), 2)).to eql(['09:12', '09:22'])
      end
    end
  end

  describe 'saturday' do
    before do
      Timecop.freeze(DateTime.new(2012, 07, 14))
    end

    after do
      Timecop.return
    end

    context 'reservation_time_available saturday' do
      it 'returns true if valid time is provided' do
        company.closed_saturday = false
        company.closed_sunday = false

        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 10, 0))).to eql(true)
      end
    end
  end

  describe 'sunday' do
    before do
      Timecop.freeze(DateTime.new(2012, 07, 15))
    end

    after do
      Timecop.return
    end

    context 'reservation_time_available sunday' do
      it 'returns true if valid time is provided' do
        company.closed_saturday = false
        company.closed_sunday = false

        expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 14, 0))).to eql(true)
      end
    end
  end
end
