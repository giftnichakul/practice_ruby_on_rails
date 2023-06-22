class WorkerJob
  include Sidekiq::Job

  def perform
    yesterday_rank = Rank.create(date: Date.yesterday)

    books = Book.all
    Book.transaction do
      books.each do |book|
        view = Rails.cache.fetch("views/#{book.id}") { 0 }
        Rails.cache.delete("views/#{book.id}")
        BookRank.create(book: book, rank: yesterday_rank, view: view)
      end
    end

    book_ranks = BookRank.where(rank: yesterday_rank).order(view: :desc)
    book_ranks.each_with_index do |book_rank, idx|
      book_rank.update(order_id: idx + 1)
    end
  end
end
