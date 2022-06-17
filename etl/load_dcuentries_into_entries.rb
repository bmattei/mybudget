$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'

# Load a statement from DcuEntries to entries. For now this is
# only handles dcu_checking and very simple it does very little
# Data manipulation.  It does not handle transfers it does
# Not do any smart selecting of a category.  All not transfer
# Transaction will be entered as either an expense or income.
# It is expected the transaction will be reviewed by  hand
# and modfied as needed.
# For now it it just a way to speed up entering transactions
# But it is not smart enought to do it in a way that does
# not require human review.
# TODO: Change this file to more handle transfers and be
# more intelligent about assigning categories.

class LoadDcuentriesIntoEntries
  def initialize(statement)
    @statement = statement.split(/\//).last
    @dcu_checking =  Account.where(name: "DCU CHECKING").first|| raise("Bad Account")
    @discover = Account.where(name: "Discover Card").first|| raise("Bad Account")
    @cash = Account.where(name: "Lisa Cash").first|| raise("Bad Account")
    @target = Account.where(name: "Target").first|| raise("Bad Account")
    @retirement = Account.where(name: "Etrade Retirement").first|| raise("Bad Account")
    @etrade = Account.where(name: "Etrade Taxable").first|| raise("Bad Account")
    @balance = @initial_balance || @discover.balance
    @misc_expense = Category.where(name:"expense : misc").first || raise("Bad Cat")
    @charity = Category.where(name: "Charity").first || raise("Bad Cat")
    @income = Category.where(name: "Income : Available next month").first || raise("Bad Cat")
    @fed_tax = Category.where(name: "income tax : federal").first || raise("Bad Cat")
    @health = Category.where(name: "Personal : Health Insurance").first || raise("Bad Cat")
    @tolls = Category.where(name: "Transportation : tolls").first || raise("Bad Cat")
    @cell = Category.where(name: "RV : Cell Phones and Data").first || raise("Bad Cat")


  end
  def load_transactions
    entries = DcuEntry.where(file: @statement).order(entry_date: :asc)
    entries.each do |entry|
      if entry.amount.to_f.abs > 0
        info = parse_description(entry.description, entry.amount)
        info[:entry_date] = entry.entry_date

        pp info

        @dcu_checking.entries.create(entry_date: info[:entry_date],
                                     check_number: info[:check_number],
                                     payee: info[:payee],
                                     transfer_account: info[:transfer_account],
                                     amount: entry.amount,
                                     category: info[:category],
                                     memo: info[:memo] ) 
      end
    end

  end

  def parse_description(description, amount)
    info = {amount: amount,
            memo: "AUTO IMPORT - VERIFY"}


     case description
     when /check\s+(\d+)/i
       info[:payee] = "EDIT THIS"
       info[:check_number] = $1
       info[:category] = @misc_expense
     when /EFT ACH DISCOVER/i
        info[:payee] = "Transfer: Discover"
        info[:transfer_account] = @discover
     when /EFT ACH SAVE THE CHILD/i
       info[:payee] = "SAVE THE CHILDREN"
       info[:category] = @charity
     when /EFT ACH VERIZON WIRELESS/i
       info[:payee] = "VERIZON WIRELESS"
       info[:category] = @cell
     when /EFT ACH PUMPKIN BROOK/i
       info[:payee] = "PUMPKIN BROOK"
       info[:category] = @Income
     when /EFT ACH IRS TREAS/i
       info[:payee] = "IRS"
       info[:category] = @fed_tax
     when /WITHDRAWAL/i
       info[:payee] = "Transfer: Lisa Cash"
       info[:transfer_account] = @cash
     when /EFT ACH TARGET CARD/i
       info[:payee] = "Transfer: Target"
       info[:transfer_account] = @target
     when /COMMONWEALTH HEA/i
       info[:payee] = "Ma Health Connector"
       info[:category] = @health
     when /E-ZPass MA/i
       info[:payee] = "E-ZPASS"
       info[:category] = @tolls
     when /ACH Sweetwater/i
         info[:payee] = "Sweetwater Pay"
         info[:category] = @income
      when /ACH E\*TRADE/i
         info[:transfer_account] = @retirement
         info[:payee] = "transfer: Etrade Retirement"
       when /ACH MSPBNA/i
          info[:transfer_account] = @retirement
          info[:payee] = "transfer: Etrade Retirement"
      else
        info[:payee] = description
        info[:category] = @misc_expense

     end

    return info

  end

end

if __FILE__ == $0
  statement = ARGV[0]
  etl = LoadDcuentriesIntoEntries.new(statement)
  etl.load_transactions

end
