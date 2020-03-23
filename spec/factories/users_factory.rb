FactoryBot.define do
  factory :user do
    email { 'test@email.com' }
    password { SecureRandom.hex(4) }
    password_confirmation { password }
  end
end
