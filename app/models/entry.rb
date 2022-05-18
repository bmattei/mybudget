class Entry < ApplicationRecord
  include Filterable

  belongs_to :account
  belongs_to :category, required: false
  has_one :transfer_entry, class_name: "Entry",
            foreign_key: "transfer_entry_id", dependent: :destroy
  belongs_to :transfer_entry, class_name: "Entry", optional: true,
             foreign_key: "transfer_entry_id"

  belongs_to :transfer_account, class_name: "Account", optional: true,
                        foreign_key: "transfer_account_id"
  validates :amount, presence: true
  validates :account, presence: true
  # validate  :validate_transfer_or_category
  belongs_to :account
  filter_scope :payee_contains, :text, ->(str) {where("payee like ?", "%#{str}%")}
  after_update :update_balances
  after_create :add_transfer_transaction
  # skip_callback :after_update, :after_create, if: -> {self.transfer_entry_id}


  def add_transfer_transaction
    if self.transfer_account && !self.transfer_entry
      transfer_amount = -self.amount
      puts "transfer amount: #{transfer_amount}"
      transfer = Entry.create(account: self.transfer_account,
                              amount: transfer_amount,
                              entry_date: self.entry_date,
                              memo: self.memo,
                              transfer_account: self.account,
                              transfer_entry: self)

      if transfer
       self.update_column(:transfer_entry_id, transfer.id)
      else
       errors.add("COULD NOT ADD TRANSFER TO #{self.transfer_account.name}")
       raise ActiveRecord::Rollback
      end
    end
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
