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

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book
    else
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit(:name, :description, :release)
  end
end
