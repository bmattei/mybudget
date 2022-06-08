class AddFileNameToDisentries < ActiveRecord::Migration[7.0]
  def change
    add_column :disentries, :file, :text

  end
end
