class Account < ApplicationRecord
  include Filterable
  validates :bank, :name, :number, presence:true
  validates :name, uniqueness:true
  validates :number, uniqueness: {scope: :bank}
  filter_scope :name_contains, ->(str) {where("name like ?", "%#{str}%")}
  filter_scope :bank_contains, ->(str) {where("name like ?", "%#{str}%")}
  filter_scope :has_checking, ->(bool) {where(has_checking: bool )}
end
