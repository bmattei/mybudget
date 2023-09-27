class Entry < ApplicationRecord
  belongs_to :account
  belongs_to :category, required: false
  has_many :splits
  accepts_nested_attributes_for :splits
  has_one :transfer_entry, class_name: "Entry",
          foreign_key: "transfer_entry_id"
  belongs_to :transfer_entry, class_name: "Entry", optional: true,
             foreign_key: "transfer_entry_id"

  belongs_to :transfer_account, class_name: "Account", optional: true,
             foreign_key: "transfer_account_id"
  before_save :validate_splits_sum
  include Filterable
  filter_scope :category_is, Category.all, -> (category_id) {where(category_id: category_id)}
  filter_scope :payee_contains, :text, ->(str) {where("payee like ?", "%#{str}%")}
  filter_scope :memo_contains, :text, ->(str) {where("memo like ?", "%#{str}%")}

  filter_scope :amount_greater_than, :money, ->(amount) {where("amount >= ?", amount.to_f)}
  filter_scope :amount_less_than, :money, ->(amount) {where("amount <= ?", amount.to_f)}
  filter_scope :date_before, :date, -> (date) {where("entry_date <= ?", date)}
  filter_scope :date_after, :date, -> (date) {where("entry_date >= ?", date)}
  filter_scope :check_after, :number, -> (num) {where("check_number >= ?", num)}
  filter_scope :check_before, :number, -> (num) {where("check_number <= ?", num)}
  scope        :normal_order, -> {order(entry_date: :desc).order(id: :desc)}


  validates :amount, presence: true
  validates :account, presence: true
  validates :entry_date, presence: true
  validate :category_and_transfer_account_or_splits_present

  
  # validate  :validate_transfer_or_category
  belongs_to :account
  after_update :clear_balances
  after_save :manage_transfers
  before_destroy :delete_other_transfer_entry, :clear_balances




 private def add_transfer_entry
   transfer_amount = -self.amount
   transfer = Entry.create(account: self.transfer_account,
                           amount: transfer_amount,
                           payee: "transfer : #{self.account.name}",
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
      self.payee = "transfer: #{self.transfer_account.name}"
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
      calc_balance = self.account.entries.where("entry_date < ? or (entry_date = ? and id <= ? )",
                      self.entry_date, self.entry_date,  self.id).sum(:amount)
      self.update_column(:balance, calc_balance)
    end
    self[:balance]
  end
  def account_name
    account.name
  end
  def category_name
      category.name if category
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
  def validate_splits_sum
    if splits.count > 0 && splits.sum(&:amount) != self.amount
      errors.add(:base, "Split amounts don't match the entry amount")
      throw :abort # This prevents the save operation
    end
  end
  def category_and_transfer_account_or_splits_present
    unless category || transfer_account || splits.exists?
      errors.add(:base, 'Either category and transfer_account or splits should exist.')
    end
  end
end
