$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'



 account_map = {
   "Etrade-Retirement" => "Etrade Retirement",
   "Etrade Taxable" => "Etrade Taxable",
   'Dcu Checking' => 'DCU CHECKING',
   'DCU Home Equity Credit line' => 'DCU HELOC',
   'DCU Savings' => 'DCU SAVINGS',
   'DCU LTD account' => 'DCU LONG TERM',
   'Discover' => 'Discover Card',
   'Lisa Cash Account' => 'Lisa Cash',
   'Target' => 'Target',
   'Target Lisa' => 'Lisa Target',
   'Robert Cash Account' => 'Bob Cash',
   'avidia - Lisa Business' => 'Lisa Biz Avidia',
   'Avidia Checking' => 'Avidia CHECKING',
   'Avidia-AlyssaAccount' => 'Alyssa Avidia'
 }
 if false
 account_map.each do |k,v|
   puts "\n #{k}\n"
   puts YnabEntry.where(account_name:k).count
   account = Account.where(name:v).first
   puts account.name
   puts Entry.where(account_id: account.id).count

  end
end
discover = Account.where(name: 'Discover Card').first

#test_dates = ["2013-12-31".to_date,"2014-12-31".to_date,"2015-12-31".to_date, "2016-12-31".to_date,
#              "2017-12-31".to_date, "2020-01-01".to_date, "2020-05-29".to_date, "2020-12-29".to_date,
#              "2021-11-28".to_date]
test_dates = [  "2020-04-27".to_date, "2020-04-28".to_date,"2020-04-29".to_date,"2020-04-30".to_date, "2020-05-01".to_date ]

test_dates.each do |e_date|
  puts " ************* #{e_date} *********"
  ynab_entries = YnabEntry.where(account_name: 'Discover', entry_date: e_date)
  discover_entries = discover.entries.where(entry_date:e_date)
  ynab_balances = ynab_entries.collect {|x| x.balance.to_f}
  discover_balances = discover_entries.collect {|x| x.balance.to_f}

  ynab_balance = ynab_balances.min
  discover_balance = discover_balances.min
  puts "\n\nynab date: #{e_date} balances: #{ynab_balances} balance: #{ynab_balance}"
  puts "discover                 balances: #{discover_balances} balance: #{discover_balance}"
  puts " ************* YNAB *********"

  ynab_entries.each do |entry|
    puts "#{entry.entry_date} #{entry.outflow.to_f} #{entry.inflow.to_f} #{entry.balance.to_f} "
  end
  puts " ************* discover *********"

  discover_entries.each do |entry|
    puts "#{entry.entry_date} #{entry.amount.to_f} #{entry.balance.to_f} "
  end
end


if false
 last_entry_dates = YnabEntry.group(:account_name).select(:account_name).maximum(:entry_date)
 account_map.each do |k,v|
   puts "\n\n****************************************************************\n\n"
    YnabEntry.where(account_name:k).where(entry_date:last_entry_dates[k]).each do |from_a|
      pp from_a
    end
    account_id = Account.where(name:v).first.id
    Entry.where(account_id: account_id).where(entry_date:last_entry_dates[k]).each do |to_a|
      puts "account: #{to_a.account.name} date: #{to_a.entry_date} payee: #{to_a.payee} amount: #{to_a.amount.to_f} balance:#{to_a.balance.to_f}"
    end
  end
  ynab_discover_entries = YnabEntry.where(account_name: 'Discover').order(entry_date: :asc)
  i = 0
  ynab_discover_entries.each do |ye|
    ne = discover.entries.order(entry_date: :asc)[i]
    if ne
       puts "#{ye.entry_date} #{ye.balance} #{ne.entry_date} #{ne.balance}"
    else
      puts "#{ye.entry_date} #{ye.balance}"
    end
    i += 1
  end
end
