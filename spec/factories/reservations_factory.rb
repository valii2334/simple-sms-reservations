FactoryBot.define do
  factory :reservation do
    company
    reservation_date { DateTime.new(2012, 07, 11, 9, 0) }
    phone_number { '1111111111' }
  end
end
