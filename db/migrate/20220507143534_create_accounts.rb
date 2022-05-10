class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :number
      t.string :bank
      t.boolean :has_checking, default: false

      t.timestamps
    end
  end
end
