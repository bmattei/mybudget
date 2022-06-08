class CreateDisentries < ActiveRecord::Migration[7.0]
  def change
    create_table :disentries do |t|
      t.date :trans_date
      t.date :post_date
      t.text :description
      t.decimal :amount, precision: 13, scale: 4
      t.text :category

      t.timestamps
    end
  end
end
