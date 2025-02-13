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
  it { should have_attribute :reservation_message }
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

  context '#can_change_unit_of_time' do
    it 'can not change unit_of_time if reservations present' do
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'

      company.unit_of_time = 10
      company.save

      expect(company).to_not be_valid
      expect(company.errors.full_messages.join('')).to include('can not be changed if reservations present')
    end

    it 'can change unit_of_time if reservations not present' do
      company.unit_of_time = 10
      company.save

      expect(company).to be_valid
    end
  end

  ##################################
  # Methods
  ##################################

  describe '#open' do
    context 'weekday' do
      it 'returns false if temporarily_closed and between working hours' do
        company.temporarily_closed = true

        expect(company.open?(DateTime.new(2020,4,17,9,0))).to eql(false)
      end

      it 'returns false if not between working hours' do
        expect(company.open?(DateTime.new(2020,4,17,11,0))).to eql(false)
      end

      it 'returns true if between working hours' do
        expect(company.open?(DateTime.new(2020,4,17,9,0))).to eql(true)
        expect(company.open?(DateTime.new(2020,4,17,10,0))).to eql(true)
      end
    end

    context 'Saturday' do
      it 'returns false if temporarily_closed and between working hours' do
        company.temporarily_closed = true
        company.closed_saturday = false

        expect(company.open?(DateTime.new(2020,4,18,10,0))).to eql(false)
      end

      it 'returns false if not between working hours' do
        company.closed_saturday = false

        expect(company.open?(DateTime.new(2020,4,18,9,0))).to eql(false)
      end

      it 'returns true if between working hours' do
        company.closed_saturday = false

        expect(company.open?(DateTime.new(2020,4,18,10,0))).to eql(true)
        expect(company.open?(DateTime.new(2020,4,18,12,0))).to eql(true)
      end
    end

    context 'Sunday' do
      it 'returns false if temporarily_closed and between working hours' do
        company.temporarily_closed = true
        company.closed_sunday = false

        expect(company.open?(DateTime.new(2020,4,19,14,0))).to eql(false)
      end

      it 'returns false if not between working hours' do
        company.closed_sunday = false

        expect(company.open?(DateTime.new(2020,4,19,13,0))).to eql(false)
      end

      it 'returns true if between working hours' do
        company.closed_sunday = false

        expect(company.open?(DateTime.new(2020,4,19,14,0))).to eql(true)
        expect(company.open?(DateTime.new(2020,4,19,16,0))).to eql(true)
      end
    end
  end

  context '#time_slot_still_available?' do
    it 'returns false if not open' do
      company.temporarily_closed = true

      expect(company.time_slot_still_available?(DateTime.new(2020,4,17,9,0))).to eql(false)
    end

    it 'returns false if all reservations slots are occupied' do
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567891'
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567892'

      expect(company.time_slot_still_available?(DateTime.new(2120,4,17,9,0))).to eql(false)
    end

    it 'returns true if one spot is still available' do
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567891'

      expect(company.time_slot_still_available?(DateTime.new(2120,4,17,9,0))).to eql(true)
    end
  end

  context '#available_time_slots' do
    it 'returns all the time slots between the two dates' do
      expect(company.today_time_slots(DateTime.new(2020,4,17,9,0))).to eql([
        DateTime.new(2020,4,17,9,0).in_time_zone,
        DateTime.new(2020,4,17,9,15).in_time_zone,
        DateTime.new(2020,4,17,9,30).in_time_zone,
        DateTime.new(2020,4,17,9,45).in_time_zone
      ])
    end
  end

  context '#available_time_slots_after_given_date' do
    it 'returns all available time slots' do
      company.customers_per_unit_of_time = 1

      expect(company.available_time_slots_after_given_date_time(DateTime.new(2120,4,17,9,0))).to eql([
        DateTime.new(2120,4,17,9,0).in_time_zone,
        DateTime.new(2120,4,17,9,15).in_time_zone,
        DateTime.new(2120,4,17,9,30).in_time_zone,
        DateTime.new(2120,4,17,9,45).in_time_zone
      ])

      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,0), phone_number: '1234567890'
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,30), phone_number: '1234567891'

      expect(company.available_time_slots_after_given_date_time(DateTime.new(2120,4,17,9,0))).to eql([
        DateTime.new(2120,4,17,9,15).in_time_zone,
        DateTime.new(2120,4,17,9,45).in_time_zone
      ])

      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,15), phone_number: '1234567890'
      create :reservation, company: company, reservation_date: DateTime.new(2120,4,17,9,45), phone_number: '1234567891'

      expect(company.available_time_slots_after_given_date_time(DateTime.new(2120,4,17,9,0))).to eql([])
    end
  end
end
