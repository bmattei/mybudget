$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
load 'etl/load_discover_pdf.rb'
load 'etl/load_new_discover_pdf.rb'
load 'etl/load_discover_csv.rb'
class FixDcu
  def initialize
    @discover = Account.where(name: 'Discover Card').first || raise('Bad Account')
    @dcu_checking = Account.where(name: 'DCU CHECKING').first || raise('Bad Account')
    @start_date = Date.new(2015, 5, 14)
    @start_balance = 692.52
    @category_initial_balance = Category.where(name: "Initial Balance").first ||  raise("Bad Category")


  end
  def set_initial_dcu_checking_balance
    initial = @dcu_checking.entries.where(payee:"INITIAL BALANCE").first
    if !initial
      puts "ADD INITIAL"
      @dcu_checking.entries.create(entry_date: @start_date, payee: "INITIAL BALANCE",amount: @start_balance, category: @category_initial_balance, memo: "ADDED BY FIX_DCU")
    end
  end
  def check_balances



  end
  def dcu_entry_balance
    entries = @dcu_checking.entries.order(entry_date: :asc, amount: :desc, id: :asc).limit(100)
    f = entries.first
    f.balance = nil
    f.save
     entries.each do |e|
       puts "#{e.id.to_s.ljust(10)} #{e.entry_date.to_s.ljust(10)} #{e.amount.to_s.ljust(10)} #{e.balance.to_s.ljust(10)}"
     end
  end
  def destroy_old_entries
      destroy_entries = Entry.where("entry_date < ?", Date.new(2015, 5, 14))
      destroy_entries.destroy_all
  end
  def remove_dupicates
    discover_transfers = @discover.entries.where(transfer_account: @dcu_checking)
    dcu_checking_transfers = @dcu_checking.entries.where(transfer_account: @discover)
    puts "discover transfers: #{discover_transfers.count} dcu_checking: #{dcu_checking_transfers.count}"
    puts "discover transfers: #{discover_transfers.sum(:amount)} dcu_checking: #{dcu_checking_transfers.sum(:amount)}"

    dcu_checking_transfers.each do |t|
      begin
        Entry.find(t.transfer_entry_id)
        puts "OK #{t.id} #{t.entry_date} #{t.amount}"
      rescue StandardError
        puts "Delete #{t.id} #{t.entry_date} #{t.amount}"
        t.destroy
      end
    end
  end
end

if __FILE__ == $0
  fixer = FixDcu.new
  fixer.destroy_old_entries
  fixer.set_initial_dcu_checking_balance
  fixer.dcu_entry_balance
end
