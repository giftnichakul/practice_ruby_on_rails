class Book < ApplicationRecord
  validates :name, presence: true
  has_many :reviews, dependent: :destroy
  belongs_to :user
end
