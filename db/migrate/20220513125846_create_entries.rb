class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.references :account, null: false, foreign_key: true
      t.date :entry_date
      t.integer :check_number
      t.citext :payee
      t.decimal :amount, precision: 13, scale: 4
      t.integer :transfer_account_id
      t.integer :transfer_entry_id
      t.citext :memo
      t.decimal :balance, precision: 13, scale: 4
      t.references :category,  foreign_key: true

      t.timestamps

    end
    add_index :entries, [:entry_date]
    add_index :entries, [:account_id]
  end
end
