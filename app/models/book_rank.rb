class BookRank < ApplicationRecord
  belongs_to :book
  belongs_to :rank
end
