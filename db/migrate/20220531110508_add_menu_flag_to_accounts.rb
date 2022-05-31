class AddMenuFlagToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :in_menu, :boolean
  end
end
