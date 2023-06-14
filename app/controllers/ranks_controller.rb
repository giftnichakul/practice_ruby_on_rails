class RanksController < ApplicationController

  def index
    @ranks = Rank.all
  end

  def show
    @rank = Rank.find(params[:id])
    @book_ranks = BookRank.where(rank: params[:id])
  end
end
