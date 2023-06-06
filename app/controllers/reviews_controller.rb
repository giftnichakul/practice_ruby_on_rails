class ReviewsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @review = @book.reviews.create(review_params)
    redirect_to book_path(@book)
  end

  def destroy
    @review = Review.find_by(id: params[:id], book_id: params[:book_id])
    raise ActiveRecord::RecordNotFound if @review.blank?

    @review.destroy

    redirect_to book_path(params[:book_id])
  end

  private

  def review_params
    params.require(:review).permit(:comment, :star, :book_id)
  end
end
