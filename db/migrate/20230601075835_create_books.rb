class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :release

      t.timestamps
    end
  end
end
