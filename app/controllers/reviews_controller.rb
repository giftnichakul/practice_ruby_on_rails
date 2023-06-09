class ReviewsController < ApplicationController
  before_action :set_book, only: %i[create edit update destroy]
  before_action :set_review, only: %i[edit update]

  def create
    @review = Review.create(review_params)
    Rails.cache.write([@book, :reviews], @book.reviews.to_a)
    redirect_to book_path(id: params[:book_id], error: @review.errors.full_messages)
  end

  def destroy
    @review = Review.find_by(id: params[:id], book_id: params[:book_id])
    raise ActiveRecord::RecordNotFound if @review.blank?

    authorize @review

    @review.destroy
    Rails.cache.write([@book, :reviews], @book.reviews.to_a)

    redirect_to book_path(params[:book_id])
  end

  def edit; end

  def update
    authorize @review
    if @review.update(review_params)
      Rails.cache.write([@book, :reviews], @book.reviews.to_a)
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  private

  def review_params
    params.require(:review).permit(:comment, :star).merge(book_id: params[:book_id], user: current_user)
  end

  def set_book
    @book = Book.find(params[:book_id])
  end

  def set_review
    @review = @book.cached_reviews.find { |review| review.id.to_s == params[:id] }
  end
end
