class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      enable_extension 'citext'

      t.citext :name
      t.citext :number
      t.citext :bank
      t.boolean :has_checking, default: false

      t.timestamps
    end
  end
end
