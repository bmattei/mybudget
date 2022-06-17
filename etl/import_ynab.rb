  $LOAD_PATH << '.'
  $LOAD_PATH << './etl'
  require 'config/environment'
#
#  Used this to import dump of YNAB data into a CSV file.  It loads the data into
#  ynab_entries table in database.  It loads the data almost as is  except outflows
#  and inflows are put into amount with outflows put in as negative values.
#
class ImportYnab
  Account_Name = 0
  Flag = 1
  Cleared = 2
  Check_Number = 3
  Entry_Date = 4
  Payee = 5
  Category_Name = 6
  Master_Category = 7
  Sub_Category = 8
  Memo = 9
  Outflow = 10
  Inflow = 11
  Balance = 12
def run_etl
  Entry.delete_all
  Account.delete_all
  Category.delete_all
  dcu_savings = Account.create(bank: 'DCU', name: 'DCU SAVINGS', number: '5535909', has_checking: false)
  dcu_checking = Account.create(bank: 'DCU', name: 'DCU CHECKING', number: '17958877', has_checking: true)
  dcu_long_term = Account.create(bank: 'DCU', name: 'DCU LONG TERM', number: '5535909-LTD', has_checking: false)
  dcu_heloc  = Account.create(bank: 'DCU', name: 'DCU HELOC', number: '5535909-Heloc', has_checking: false)

  discover = Account.create(bank: 'Discover', name: 'Discover Card', number: '9369', has_checking: true)
  lisa_cash = Account.create(bank: 'Cash', name: 'Lisa Cash', number: 'Lisa Cash', has_checking: false)
  bob_cash = Account.create(bank: 'Cash', name: 'Bob Cash', number: 'Bob Cash', has_checking: false)
  lisa_biz_avidia = Account.create(bank: 'Avidia', name: 'Lisa Biz Avidia', number: 'Lisa Biz Avidia',
                                   has_checking: false)
  avidia_checking = Account.create(bank: 'Avidia', name: 'Avidia CHECKING', number: 'Avidia Checking', has_checking: true)
  target = Account.create(bank: 'Target', name: 'Target', number: 'Target', has_checking: false)
  lisa_target = Account.create(bank: 'Target', name: 'Lisa Target', number: 'Lisa Target', has_checking: false)
  alyssa_avidia = Account.create(bank: 'Avidia', name: 'Alyssa Avidia', number: 'Alyssa Avidia', has_checking: false)
  etrade_retirement = Account.create(bank: "Etrade", name: "Etrade Retirement", number: "Etrade Retirement", has_checking: false)
  etrade_taxable = Account.create(bank: "Etrade", name: "Etrade Taxable", number: "Etrade Taxable", has_checking: false)
  @account_map = {
    "Etrade-Retirement" => etrade_retirement,
    "Etrade Taxable" => etrade_taxable,
    'Dcu Checking' => dcu_checking,
    'DCU Home Equity Credit line' => dcu_heloc,
    'DCU Savings' => dcu_savings,
    'DCU LTD account' => dcu_long_term,
    'Discover' => discover,
    'Lisa Cash Account' => lisa_cash,
    'Target' => target,
    'Target Lisa' => lisa_target,
    'Robert Cash Account' => bob_cash,
    'avidia - Lisa Business' => lisa_biz_avidia,
    'Avidia Checking' => avidia_checking,
    'Avidia-AlyssaAccount' => alyssa_avidia
  }
  @category_map = {}
  pp ARGV
  if !ARGV.include?("skip_csv")
    path = 'etl/ynab.csv'
    create_ynab_entry
    load_ynab_entry(path)
  end
  YnabEntry.order(entry_date: :asc).each do |ynab_entry|
    amount = ynab_entry.inflow > 0 ? ynab_entry.inflow : -ynab_entry.outflow
    account = @account_map[ynab_entry.account_name] || abort("account not found #{ynab_entry.account_name}")
    next if amount == 0
    if ynab_entry.payee =~ /Transfer :/
      create_transfer(account, ynab_entry, amount) if (amount < 0)
    else
      create_entry(account, ynab_entry, amount)
    end
  end
end
  def create_transfer(account, ynab_entry, amount)
    (foo, transfer_account_name) = ynab_entry.payee.split(' : ')
    transfer_account = @account_map[transfer_account_name] || abort("****\naccount #{transfer_account} does not exist\n***")
    Entry.create!(account: account,
                  entry_date: ynab_entry.entry_date,
                  check_number: ynab_entry.check_number,
                  payee: ynab_entry.payee,
                  transfer_account: transfer_account,
                  amount: amount,
                  memo: ynab_entry.memo)
  end

  def create_entry(account, ynab_entry, amount)

    category_name = ynab_entry.category_name || (amount > 0 ? "income : misc" : "expense : misc")
    category = @category_map[category_name]


    category ||= create_category(category_name)
    # Entry.create(account: discover, entry_date: Date.today - 10, payee: "Hartford Ins", amount: -587.00, category: auto_insurance)
    Entry.create!(account: account,
                  entry_date: ynab_entry.entry_date,
                  check_number: ynab_entry.check_number,
                  payee: ynab_entry.payee,
                  amount: amount,
                  memo: ynab_entry.memo,
                  category: category
                  )
  end

  def create_category(full_category_name)
    (master_name, category_name) = full_category_name.split(' : ')
    master = Category.where(name: master_name).first
    unless master
      master = Category.create!(name: master_name)
      @category_map[master_name] = master
    end
    category = Category.create!(name: full_category_name, category: master)
    @category_map[full_category_name] = category
    return category
  end

  def load_ynab_entry(path)
      CSV.foreach(path) do |row|
        pp row
        if !row[Account_Name].strip.eql?("Account")
          YnabEntry.create(account_name: row[Account_Name],
                          flag: row[Flag],
                          cleared: row[Cleared],
                          check_number: row[Check_Number],
                          entry_date: Date.strptime(row[Entry_Date], '%m/%d/%Y'),
                          payee: row[Payee],
                          category_name: row[Category_Name],
                          master_category: row[Master_Category],
                          sub_category: row[Sub_Category],
                          memo: row[Memo],
                          inflow: row[Inflow].slice(1..).to_f,
                          outflow: row[Outflow].slice(1..).to_f,
                          balance: row[Balance].gsub('$',"").to_f)
        end
       end
  end
  def create_ynab_entry
    if !(defined? YnabEntry)
      create_ynab_entry_model
    else
       YnabEntry.delete_all
    end
  end
  def create_ynab_entry_model()
    #  'amount:decimal{13,4}'
    suppress(Exception) do
       syscmd('psql mybudget_development -c "DROP TABLE ynab_entries;"')
    end

    syscmd("rails g model ynab_entry account_name:text:index flag:text cleared:text check_number:integer entry_date:date:index" +
           " payee:text category_name:text master_category:text sub_category:text memo:text 'outflow:decimal{13,4}' 'inflow:decimal{13.4}' balance:decimal{13.4}")
    syscmd(" rails db:migrate")
  end
  def syscmd(cmd)
    puts cmd
    system(cmd) || raise("Error command failed #{cmd} error: #{$?}")
  end
end
if __FILE__ == $0
  etl = ImportYnab.new
  etl.run_etl
end
