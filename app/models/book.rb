class Book < ApplicationRecord
  validates :name, presence: true
  has_many :book_ranks, dependent: :destroy
  has_many :reviews, dependent: :destroy
  belongs_to :user
  paginates_per 5

  def cached_reviews
    Rails.cache.fetch([self, :reviews], expires_in: 10.minutes) do
      reviews.to_a
    end
  end

  def average_star
    cached_reviews.sum { |review| review.star } / cached_reviews.count
  end
end
