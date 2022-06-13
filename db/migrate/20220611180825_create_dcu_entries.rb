class CreateDcuEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :dcu_entries do |t|
      t.date :entry_date
      t.text :account_name
      t.text :type
      t.integer :check_number
      t.text :description
      t.decimal :amount, precision: 13, scale: 4
      t.decimal :balance, precision: 13, scale: 4

      t.timestamps
    end
    add_index :dcu_entries, :entry_date
    add_index :dcu_entries, :account_name
  end
end
