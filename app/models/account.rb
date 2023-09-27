class Account < ApplicationRecord
  include Filterable
  has_many :entries
  validates :bank, :name, :number, presence:true
  validates :name, uniqueness:true
  validates :number, uniqueness: {scope: :bank}
  filter_scope :bank_contains, :text, ->(str) {where("bank like ?", "%#{str}%")}
  filter_scope :name_contains, :text, ->(str) {where("name like ?", "%#{str}%")}
  filter_scope :number_contains, :text, ->(str) {where("number like ?", "%#{str}%")}
  # default_scope { order(bank: :asc, name: :asc) }

  def balance(on_date: nil)
      if on_date
        self.entries.where("entry_date <= ?", on_date).sum(:amount)
      else
        self.entries.sum(:amount)
      end
  end



end
