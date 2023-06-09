class BookPolicy < ApplicationPolicy
  attr_reader :user, :book

  def initialize(user, book)
    @user = user
    @book = book
  end

  def update?
    user == book.user
  end

  def destroy?
    user == book.user
  end
end
