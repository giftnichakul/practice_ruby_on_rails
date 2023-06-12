FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}_#test@test.com" }
    # email { 'factory@bot.com' }
    password { '1234567' }
  end
end
