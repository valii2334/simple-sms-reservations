FactoryBot.define do
  factory :company do
    user
    name { 'VLZ DevOps' }
    code { 'vlzdevops' }
    opening_time { Time.parse('09:00') }
    closing_time { Time.parse('20:00') }
    unit_of_time { 15 }
    customers_per_unit_of_time { 3 }
    closed_saturday { false }
    closed_sunday { false }
    temporarily_closed { false }
  end
end
