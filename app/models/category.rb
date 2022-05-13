class Category < ApplicationRecord
  include Filterable
  validates :name, presence: true
  validates :name, uniqueness: true
  has_many :categories, class_name: "Category",
            foreign_key: "category_id", dependent: :nullify
  belongs_to :category, class_name: "Category", optional: true,
             foreign_key: "category_id"
  filter_scope :name_contains, :text, -> (str) {where("categories.name like ?", "%#{str}%")}
  filter_scope :super_contains, :text, -> (str) {joins(:category).where("categories_categories.name LIKE ?", "%#{str}%")}
  def super
    category ? category.name : nil
  end


end
