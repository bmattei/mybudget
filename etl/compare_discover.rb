$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
# This class is to verify the discover data has been
# correctly loaded into entries
class CompareDiscover
   def initialize
     @discover = Account.where(name: "Discover Card").first
     @min_date = Disentry.minimum(:trans_date)
     @max_date = @discover.entries.maximum(:entry_date)
   end
   def compare_amounts
     problem_amounts = []
     expected_amounts = Disentry.where("trans_date >= ? and trans_date <= ?", @min_date, @max_date).group(:amount).count
     actual_amounts = @discover.entries.where("entry_date >= ? and entry_date <= ?", @min_date, @max_date).group(:amount).count
     expected_amounts.each do |amount, expected_count|

       actual_count = actual_amounts[amount] || 0
       if actual_count != expected_count
         problem_amounts << amount
         # puts "#{amount.to_f} expected: #{expected_count} actual: #{actual_count}"
       end
     end
     actual_amounts.each do |amount, count|
       if !expected_amounts[amount]
         problem_amounts << amount
         # puts "#{amount} does not exist in expected data"
       end
     end
     problem_amounts.each do |amount|
       expected_records = Disentry.where("trans_date >= ? and trans_date <= ?", @min_date, @max_date).where(amount:amount)
       actual_records = @discover.entries.where("entry_date >= ? and entry_date <= ?", @min_date, @max_date).where(amount: amount)
       puts "\n\n\n AMOUNT #{amount} Expected"
       expected_records.each {|r| puts "#{r.post_date} #{r.trans_date} #{r.category} #{r.description} #{r.amount}"}
       puts "Actual ------------------------"
       actual_records.each {  |r| puts  "#{r.entry_date}                #{r.category.name} #{r.payee} #{r.amount}" }

     end
   end
   def compare_sums
     expected_sum = Disentry.where("trans_date >= ? and trans_date <= ?", @min_date, @max_date).sum(:amount)
     actual_sum = @discover.entries.where("entry_date >= ? and entry_date <= ?", @min_date, @max_date).sum(:amount)
     puts "\n*****\n #{@min_date} #{@max_date} expected: #{expected_sum} actual: #{actual_sum}\n *** \n"

   end
   def compare_counts

     expected_count = Disentry.where("trans_date >= ? and trans_date <= ?", @min_date, @max_date).count
     actual_count = @discover.entries.where("entry_date >= ? and entry_date <= ?", @min_date, @max_date).count
     puts "\n*****\n #{@min_date} #{@max_date} expected_count: #{expected_count} actual_count: #{actual_count}\n *** \n"

     start_date = @min_date
     while start_date < @max_date do
       end_date = start_date + 1.month
       expected_count = Disentry.where("trans_date >= ? and trans_date < ?", start_date, end_date).count
       actual_count = @discover.entries.where("entry_date >= ? and entry_date < ?", start_date, end_date).count
       if expected_count != actual_count
         puts "#{start_date} #{end_date} expected_count: #{expected_count} actual_count: #{actual_count}"
       end
       start_date = end_date
     end

   end

end
if __FILE__ == $0
  verifier = CompareDiscover.new()
  #verifier.compare_counts
  #verifier.compare_sums
  verifier.compare_amounts
end
