class ReviewsController < ApplicationController
  def edit
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find(params[:id])
  end

  def update
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find(params[:id])

    if @review.update(review_params)
      redirect_to book_path(@book)
    else
      render :edit
    end
  end

  private

  def review_params
    params.require(:review).permit(:comment, :star, :book)
  end
end
