class Book < ApplicationRecord
  validates :name, presence: true
  has_many :reviews, dependent: :destroy
  belongs_to :user
  paginates_per 5
end
