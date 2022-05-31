class AddIndexToEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :entries, [:entry_date, :amount]
  end
end
