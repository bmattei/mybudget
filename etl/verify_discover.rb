$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'

class VerifyDiscover


 def initialize
   @dcu = Account.where(name: "DCU CHECKING").first
   @discover = Account.where(name: "Discover Card").first
   @disentry_start_date = Disentry.minimum(:trans_date)
   @min_date = @disentry_start_date
   @disentry_end_date = Disentry.maximum(:post_date)
   @dcu_end_date = @dcu.entries.maximum(:entry_date)
   @max_date = [@disentry_end_date, @dcu_end_date].min

 end
  def verify_dcu_transfers

    dcu_trans = @dcu.entries.where(transfer_account_id: @discover.id).
    where("entry_date >= ? and entry_date <= ?", @min_date, @max_date).order(entry_date: :asc)

    dis_trans = Disentry.where("description like ?", "DIRECTPAY%").
            where("post_date >= ? and trans_date <= ?", @min_date, @max_date).order(trans_date: :asc)

    num_transfers = dcu_trans.count

    sum_transfers = dcu_trans.sum(:amount)

    puts "DCU checking has #{num_transfers} totaling #{sum_transfers}"

    num_dis_transfers = dis_trans.count

    sum_dis_transfers = dis_trans.sum(:amount)

    puts "Disentry  has #{num_dis_transfers} totaling #{sum_dis_transfers}"

   dcu_trans.each_with_index do |entry,i |
     if dis_trans[i]
       puts "#{entry.entry_date} #{entry.amount} #{dis_trans[i].trans_date} #{dis_trans[i].amount}"
     else
       puts "#{entry.entry_date} #{entry.amount}"
     end
   end
    puts "DISENTRY"
    dis_trans.each do |entry|
      puts "#{entry.trans_date} #{entry.post_date} *#{entry.description}  **#{entry.category} #{entry.amount}"
    end




  end
end
if __FILE__ == $0
  verifier = VerifyDiscover.new
  verifier.verify_dcu_transfers
end
