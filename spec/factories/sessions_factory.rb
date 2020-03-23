FactoryBot.define do
  factory :session do
    association :authenticable, factory: :user
  end
end
