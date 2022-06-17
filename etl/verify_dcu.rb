$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
#
#  Used to verify the data imported from YNAB into dcu checking.
#  Not sure it has anything useful going forward
#

class VerifyDcu

 def initialize
   @dcu = Account.where(name: "DCU CHECKING").first || raise("OHOH")
   @discover =  Account.where(name: "Discover Card").first|| raise("Bad Account")
 end

 def show_monthly_entries(start_date)
   puts "\n\n\n *** #{start_date.beginning_of_month}  ****"
   working_entries = @dcu.entries.where("entry_date >= ? and entry_date <= ?",
     start_date.beginning_of_month, start_date.end_of_month)

   expected_entries = DcuEntry.where("entry_date >= ? and entry_date <= ?",
     start_date.beginning_of_month, start_date.end_of_month).
     where.not("Description = 'NEW BALANCE' OR Description = 'PREVIOUS BALANCE'")

  puts "------dcu.entries"
  working_entries.each do |e|
    puts "dcu.entries: #{e.entry_date} #{e.payee} #{e.amount.to_f}"
   end
   puts "------DcuEntry"
   expected_entries.each do |e|
     puts "DcuEntry #{e.entry_date} #{e.description} #{e.amount.to_f}"
   end
   working_amounts =  working_entries.collect  {|e|  e.amount.to_f }
   expected_amounts = expected_entries.collect  {|e| e.amount.to_f}
   extra = working_amounts - expected_amounts
   missing = expected_amounts - working_amounts
   puts "\n Missing amounts"
   missing.each do |m|
     puts "#{m.to_f}"
   end
   puts "\n Extra amounts"
   extra.each do |e|
     puts "#{e.to_f}"
   end

 end

 def verify_monthly_balance(start_date: Date.new(2015, 6,15))

   monthly_record = DcuEntry.where(account_name: "DCU CHECKING", description: "NEW BALANCE").
   where( "entry_date > ?", start_date)
   monthly_record.each do |record|
      balance = @dcu.balance(on_date:record.entry_date).to_f
      if balance != record.balance.to_f
        #puts "Date: #{record.entry_date} DcuEntry balance: #{record.balance.to_f}"
        #puts "\n **** FAILURE dcu account balance #{balance} "
        puts "Date: #{record.entry_date} diff #{(record.balance.to_f - balance).to_f}"
        show_monthly_entries(record.entry_date.beginning_of_month)
        # break
      else
        # puts "Date: #{record.entry_date} balances match"
      end
   end
 end
end

if __FILE__ == $0
  verifier = VerifyDcu.new
  verifier.verify_monthly_balance(start_date:Date.new(2021,10,1))
end
