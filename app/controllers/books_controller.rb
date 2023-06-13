class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    if Rails.cache.exist?('all_key_books')
      cache_keys = Rails.cache.read('all_key_books')
      books = cache_keys.map { |key| Rails.cache.read(key) }
      @books = Kaminari.paginate_array(books).page(params[:page]).per(5)
    else
      Rails.cache.clear
      @books = Book.all
      cache_hash = @books.map { |book| [book.cache_key, book] }.to_h
      cache_keys = cache_hash.keys

      cache_hash.each do |cache_key, book|
        Rails.cache.write(cache_key, book, expires_in: 10.minute)
        Rails.cache.write("#{cache_key}_reviews", book.reviews, expires_in: 10.minute)
      end

      Rails.cache.write('all_key_books', cache_keys, expires_in: 10.minutes)
      # Rails.cache.write_multi(cache_hash, expires_in: 1.minutes)
      @books = @books.page(params[:page])
    end
    cache_stats = Rails.cache.redis.keys

    puts cache_stats

  end

  def show
    if Rails.cache.exist?("#{@book.cache_key}_reviews")
      @reviews = Rails.cache.read("#{@book.cache_key}_reviews")
      puts 'reviewssssss'
      puts @reviews
    else
      @reviews = Rails.cache.fetch("#{@book.cache_key}_reviews", expires_in: 1.minute) do
        @book.reviews
      end

    end
    # @reviews = Kaminari.paginate_array(books).page(params[:page]).per(5)

    @reviews = @reviews.page(params[:page])
    # @reviews = @book.reviews.page(params[:page])
  end

  def new
    @book = Book.new
  end

  def create
    @book = current_user.books.new(book_params)

    if @book.save
      Rails.cache.write( @book.cache_key, @book, expires_in: 10.minutes)
      redirect_to @book
    else
      redirect_to new_book_path(error: @book.errors.full_messages)
    end
  end

  def edit; end

  def update
    authorize @book
    if @book.update(book_params)
      # Rails.cache.write( @book.cache_key, @book, expires_in: 10.minutes)
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
      @book = Book.find(params[:id])
      Rails.cache.write("books/#{params[:id]}_reviews", @book.reviews, expires_in: 1.minute)
      Book.find(params[:id])
    end
  end

  def book_params
    params.require(:book).permit(:name, :description, :release)
  end
end
