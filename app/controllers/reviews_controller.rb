class ReviewsController < ApplicationController
  def destroy
    @book = Book.find(params[:book_id])
    @review = @book.reviews.find(params[:id])
    @review.destroy

    redirect_to book_path(@book)
  end
end
