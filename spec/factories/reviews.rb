FactoryBot.define do
  factory :review do
    comment { 'This comment is from factory' }
    star { 3.5 }
    book { create(:book) }
  end
end
