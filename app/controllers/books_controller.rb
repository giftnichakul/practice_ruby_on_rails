class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    # Rails.cache.clear
    books = Rails.cache.fetch('all_key_books', expires_in: 10.minute) do
      Book.all.to_a
    end

    puts Rails.cache.redis.keys

    @books = Kaminari.paginate_array(books).page(params[:page]).per(5)
  end

  def show
    reviews = @book.cached_reviews
    @reviews = Kaminari.paginate_array(reviews).page(params[:page]).per(10)
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params)

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
    @book = Rails.cache.fetch("books/#{params[:id]}", expires_in: 10.minute) do
      Book.find(params[:id])
    end
  end

  def book_params
    params.require(:book).permit(:name, :description, :release)
  end
end
