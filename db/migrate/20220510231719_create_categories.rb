class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'citext'
    create_table :categories do |t|
      t.citext :name
      t.integer :category_id

      t.timestamps
    end
  end
end
