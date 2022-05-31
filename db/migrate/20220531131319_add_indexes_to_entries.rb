class AddIndexesToEntries < ActiveRecord::Migration[7.0]
  def change
    add_index :entries, :amount
  end
end
