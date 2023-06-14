class WorkerJob
  include Sidekiq::Job

  def perform
    yesterday_rank = Rank.create(date: Date.yesterday)

    books = Book.all
    books.each do |book|
      view = Rails.cache.fetch("views/#{book.id}") { 0 }
      BookRank.create(book: book, rank: yesterday_rank, view: view)
    end

    Rails.cache.clear
    book_ranks = BookRank.where(rank: yesterday_rank).order(view: :desc)
    book_ranks.each_with_index do |book_rank, idx|
      book_rank.update(order_id: idx + 1)
    end
  end
end
