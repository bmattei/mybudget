class Entry < ApplicationRecord
  include Filterable

  belongs_to :account
  belongs_to :category, required: false
  has_one :transfer_entry, class_name: "Entry",
            foreign_key: "transfer_entry_id", dependent: :destroy
  belongs_to :transfer_entry, class_name: "Entry", optional: true,
             foreign_key: "transfer_entry_id"
  validates :amount, presence: true
  validates :account, presence: true
  # validate  :validate_transfer_or_category
  belongs_to :account
  filter_scope :payee_contains, :text, ->(str) {where("payee like ?", "%#{str}%")}
  after_create :after_create
  after_update :after_update

  def after_update
     update_balances
  end
  def after_create
    update_balances
  end
  def update_balances
    self.account.entries.where("entry_date >= ?", self.entry_date).each do |entry|
      entry.update_column(:balance, nil)
    end
  end


  def balance
    if !self[:balance]
      calc_balance = self.account.entries.
                          where("entry_date < ? or (entry_date = ? and (amount > ? or (amount = ? and id < ?)))",
                                self.entry_date, self.entry_date, self.amount, self.amount, self.id).sum(:amount) + self.amount

      self.update_column(:balance, calc_balance)
    end
    self[:balance]
  end
  def account_name
    account.name
  end
  def category_or_transfer_account
    if category
      category.name
    elsif transfer_entry
      transfer_entry.account.name
    else
      "UNCATEGORIZED"
    end
  end
  def inflow
    if amount && amount > 0
      amount
    end
  end
  def outflow
    if amount && amount < 0
      -(amount)
    end
  end

  private
  # def validate_transfer_or_category
  #  unless category_id ^ transfer_entry_id
  #    errors.add(:base, "must have a category if transaction is not a transfer")
  #  end
  # end

end
