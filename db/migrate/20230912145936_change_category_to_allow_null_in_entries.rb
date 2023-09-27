class ChangeCategoryToAllowNullInEntries < ActiveRecord::Migration[7.0]
  def change
    change_column_null :entries, :category_id, true
  end
end
