class CreateBookRanks < ActiveRecord::Migration[7.0]
  def change
    create_table :book_ranks do |t|
      t.references :book, null: false, foreign_key: true
      t.references :rank, null: false, foreign_key: true
      t.integer :view
      t.integer :order_id

      t.timestamps
    end
  end
end
