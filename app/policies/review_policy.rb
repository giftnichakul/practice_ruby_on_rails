class ReviewPolicy < ApplicationController
  attr_reader :user, :review

  def initialize(user, review)
    @user = user
    @review = review
  end

  def update?
    user == review.user
  end

  def destroy?
    user == review.user
  end
end
