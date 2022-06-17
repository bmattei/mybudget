class AddFileToDcuEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :dcu_entries, :file, :text
  end
end
