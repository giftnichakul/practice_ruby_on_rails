class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]
  before_action :authenticate_user!

  def index
    @books = Book.page(params[:page]).per(5)
  end

  def show
    @reviews = @book.reviews.page(params[:page]).per(10)
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.build(book_params)

    if @book.save
      redirect_to @book
    else
      redirect_to new_book_path(error: @book.errors.full_messages)
    end
  end

  def edit; end

  def update
    authorize @book
    if @book.update(book_params)
      redirect_to @book
    else
      render :edit
    end
  end

  def destroy
    authorize @book
    @book.destroy

    redirect_to books_path, notice: 'Book was successfully delete.'
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:name, :description, :release)
  end
end
