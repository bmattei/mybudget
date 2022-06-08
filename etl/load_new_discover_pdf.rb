$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'

class LoadNewDiscoverPdf

def initialize(path)
    if File.file?(path) && path.end_with?(".pdf")
      @path = path
    else
      raise ArgumentError.new("File #{path} not found")
    end
    @pdf_reader = PDF::Reader.new(@path)

end

  def full_date(month_day_str)
    return_date = Date.strptime("#{@start_date.year}/#{month_day_str}", "%Y/%m/%d")
    if @end_date.month == 1 && return_date.month == 1
      return_date += 1.year
    end
    return_date
  end
  def str_to_money(str)
     str.gsub('$',"").gsub(",","").to_f
  end
  def get_total_payments

      total_payments_re = /Payments and Credits\s{3,}-*(\$[\d,]*.\d\d)/
      total_payments = 0
      lines = @pdf_reader.pages[0].text.split(/\n/)
      lines.each do |line|
        if m = total_payments_re.match(line)
          total_payments = str_to_money(m[1])
          break
        end
      end
      total_payments
  end
  def get_total_purchases
    total_purchases_re = /Purchases\s{3,}\+*(\$[\d,]*.\d\d)/
    total_purchases = 0
    lines = @pdf_reader.pages[0].text.split(/\n/)
    lines.each do |line|
      if m = total_purchases_re.match(line)
        total_purchases = -str_to_money(m[1])
        break
      end
    end
    total_purchases
  end

  def read_table_rows
    purchase_re = /(\d\d\/\d\d)\s+((\S*[\s]\S+)*)\s+(\S+\s?\S+)\s{3,}[$](\d[,.\d]{3,})/
    payment_re = /(\d\d\/\d\d)\s+((\S*[\s]\S+)*)\s{3,}-\$(\d[,.\d]{3,})/
    rows = []
    pages = @pdf_reader.pages
    pages.each do |pg|
      puts "------------------\n\n"
      lines = pg.text.split(/\n/)
      lines.each do |line|

         record = {}
         if m = purchase_re.match(line)
           puts "***" + line

           record[:trans_date] = record[:post_date] = full_date(m[1])
           record[:payee] = m[2]
           record[:category] = m[4]
           record[:amount] = -str_to_money(m[5])
           rows << record
         elsif m = payment_re.match(line)
           puts "***" + line

           record[:trans_date] = record[:post_date] = full_date(m[1])
           record[:payee] = m[2]
           record[:category] = "Payments and Credits"
           record[:amount] = str_to_money(m[4])
           rows << record
         end #if
       end #lines.each
     end # pages
     return rows
  end #read_tables


  def load_file

    @end_date = Date.strptime(@path.slice(-14..-5),"%Y-%m-%d")
    @start_date = @end_date - 1.month + 1.day
    rows = read_table_rows
    calc_total_purchases = 0
    calc_total_payments = 0
    rows.each do |row|
      if row[:amount] > 0
        calc_total_payments += row[:amount]
      else
        calc_total_purchases += row[:amount]
      end
      puts "#{row[:trans_date]}\t#{row[:post_date]}\t#{row[:payee].slice(0..10)}\t#{row[:category].slice(0..10)}\t#{row[:amount]}"
      Disentry.create(category: row[:category], post_date: row[:post_date], description: row[:payee], trans_date: row[:trans_date], amount: row[:amount])
    end
    purchases = get_total_purchases.round(2)
    payments = get_total_payments.round(2)

    if calc_total_payments.round(2) != payments.round(2)
      raise "payments mismatch expected: #{payments.round(2)} #{calc_total_payments.round(2)}"
    end
    if calc_total_purchases.round(2) != purchases.round(2)
      raise "purchases mismatch expected: #{purchases.round(2)} #{calc_total_purchases.round(2)}"
    end
    puts "payments: #{calc_total_payments.round(2)} purchase: #{calc_total_purchases.round(2)}"
  end # load_pdf_file
end
if __FILE__ == $0
  path = ARGV[0]
  etl = LoadNewDiscoverPdf.new(path)
  etl.load_file

end
