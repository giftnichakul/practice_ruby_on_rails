class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def show
    @book = Book.find(params[:id])
  end

  def destroy
    @book = Book.find(params[:id])
    @book.reviews.destroy_all
    @book.destroy

    redirect_to books_path, notice: 'Book was successfully delete.'
  end
end
