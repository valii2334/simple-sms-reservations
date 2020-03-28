FactoryBot.define do
  factory :company do
    user
    name { 'VLZ DevOps' }
    code { 'vlzdevops' }
    opening_time { DateTime.new(2012, 07, 11, 9, 0) }
    closing_time { DateTime.new(2012, 07, 11, 10, 0) }
    unit_of_time { 15 }
    customers_per_unit_of_time { 3 }
    closed_saturday { true }
    closed_sunday { true }
    temporarily_closed { false }
    opening_time_saturday { DateTime.new(2012, 07, 14, 10, 0) }
    closing_time_saturday { DateTime.new(2012, 07, 14, 12, 0) }
    opening_time_sunday { DateTime.new(2012, 07, 15, 14, 0) }
    closing_time_sunday { DateTime.new(2012, 07, 15, 16, 0) }
  end
end
