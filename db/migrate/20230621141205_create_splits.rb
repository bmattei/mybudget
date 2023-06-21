class CreateSplits < ActiveRecord::Migration[7.0]
  def change
    create_table :splits do |t|
      t.references :entry, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount, precision: 13, scale: 4

      t.timestamps
    end
  end

end
