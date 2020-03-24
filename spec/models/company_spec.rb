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
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 8, 00, 0)

      expect(company).to_not be_valid
    end

    it 'is not valid if closing_time is equal to opening_time' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 9, 00, 0)

      expect(company).to_not be_valid
    end

    it 'is valid if closing_time is bigger than opening_time' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      expect(company).to be_valid
    end
  end

  ##################################
  # Methods
  ##################################

  context '#available_reservation_times' do
    it 'returns available reservation times between 09:00 and 10:00' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      expect(company.available_reservation_times).to eql(
        [
          DateTime.new(2012, 07, 11, 9, 00, 0).strftime('%H:%M'),
          DateTime.new(2012, 07, 11, 9, 15, 0).strftime('%H:%M'),
          DateTime.new(2012, 07, 11, 9, 30, 0).strftime('%H:%M'),
          DateTime.new(2012, 07, 11, 9, 45, 0).strftime('%H:%M')
        ]
      )
    end

    it 'returns available reservation times between 09:02 and 9:30' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 02, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 9, 30, 0)

      expect(company.available_reservation_times).to eql(
        [
          DateTime.new(2012, 07, 11, 9, 02, 0).strftime('%H:%M'),
          DateTime.new(2012, 07, 11, 9, 17, 0).strftime('%H:%M')
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

  context '#reservation_time_available?' do
    it 'returns false if invalid time is provided' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 10, 0))).to eql(false)
    end

    it 'returns true if valid time is provided' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 00, 0))).to eql(true)
    end

    it 'returns false if all time slots at 9:00 are occupied' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 00, 0)
      create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 00, 0)
      create :reservation, company: company, phone_number: '0123456783', reservation_date: DateTime.new(2012, 07, 11, 9, 00, 0)

      expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 00, 0))).to eql(false)
    end

    it 'returns true if one time slots at 9:00 is available' do
      company.opening_time = DateTime.new(2012, 07, 11, 9, 00, 0)
      company.closing_time = DateTime.new(2012, 07, 11, 10, 00, 0)

      create :reservation, company: company, phone_number: '0123456781', reservation_date: DateTime.new(2012, 07, 11, 9, 00, 0)
      create :reservation, company: company, phone_number: '0123456782', reservation_date: DateTime.new(2012, 07, 11, 9, 00, 0)

      expect(company.reservation_time_available?(DateTime.new(2012, 07, 11, 9, 00, 0))).to eql(true)
    end
  end
end
