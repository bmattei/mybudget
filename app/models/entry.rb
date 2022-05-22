class Entry < ApplicationRecord
  include Filterable

  belongs_to :account
  belongs_to :category, required: false
  has_one :transfer_entry, class_name: "Entry",
            foreign_key: "transfer_entry_id"
  belongs_to :transfer_entry, class_name: "Entry", optional: true,
             foreign_key: "transfer_entry_id"

  belongs_to :transfer_account, class_name: "Account", optional: true,
                        foreign_key: "transfer_account_id"
  validates :amount, presence: true
  validates :account, presence: true
  # validate  :validate_transfer_or_category
  belongs_to :account
  filter_scope :payee_contains, :text, ->(str) {where("payee like ?", "%#{str}%")}
  after_update :clear_balances
  after_save :manage_transfers
  before_destroy :delete_other_transfer_entry




 private def add_transfer_entry
   transfer_amount = -self.amount
   transfer = Entry.create(account: self.transfer_account,
                           amount: transfer_amount,
                           entry_date: self.entry_date,
                           memo: self.memo,
                           transfer_account: self.account,
                           transfer_entry: self)

   if transfer
    self.update_column(:transfer_entry_id, transfer.id)
    transfer.clear_balances
   else
    errors.add("COULD NOT ADD TRANSFER TO #{self.transfer_account.name}")
    raise ActiveRecord::Rollback
   end
 end
private def delete_other_transfer_entry
  if self.transfer_entry
     self.transfer_entry.delete
  end
end
private def manage_transfers
    if self.transfer_account
      if !self.transfer_entry
        add_transfer_entry
      else
        self.transfer_entry.update_column(:amount, -(self.amount))
      end
    else
      self.update_column(:transfer_entry_id, nil)
      trans_entry = Entry.where(transfer_entry_id: self.id).first
      if !trans_entry.nil?
       trans_entry.clear_balances
       trans_entry.delete
       puts "LINE 54"
      end
    end
  end
  def clear_balances
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
