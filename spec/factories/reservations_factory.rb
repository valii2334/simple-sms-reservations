FactoryBot.define do
  factory :reservation do
    company
    reservation_date { Time.parse('09:00') }
    phone_number { '1111111111' }
  end
end
