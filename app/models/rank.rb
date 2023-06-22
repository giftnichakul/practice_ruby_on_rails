class Rank < ApplicationRecord
  has_many :book_ranks, dependent: :destroy
end
