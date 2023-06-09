class Review < ApplicationRecord
  validates :comment, presence: true
  validates :star, numericality: { in: 0..5 }
  belongs_to :book
  belongs_to :user
  paginates_per 10
end
