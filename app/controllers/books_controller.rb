class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update]

  def index
    @books = Book.all
  end

  def show; end

  private

  def set_book
    @book = Book.find(params[:id])
  end
end
