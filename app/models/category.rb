class Category < ApplicationRecord
  include Filterable
  validates :name, presence: true
  validates :name, uniqueness: true
  has_many :entries, dependent: :nullify
  has_many :splits
  has_many :sub_categories, class_name: "Category",
            foreign_key: "parent_id", dependent: :nullify
  belongs_to :parent, class_name: "Category", optional: true,
             foreign_key: "parent_id"
  filter_scope :name_contains, :text, -> (str) {where("categories.name like ?", "%#{str}%")}
  filter_scope :super_contains, :text, -> (str) {joins(:category).where("categories_categories.name LIKE ?", "%#{str}%")}
  def super
    # category ? category.name : nil
    parent ? parent.name : nil
  end


end
