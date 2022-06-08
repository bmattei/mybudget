$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'

class LoadDiscoverPdf
  def initialize(path)
    if File.directory?(path)
      @dir_path = path
    elsif File.file?(path) && path.end_with?(".pdf")
      @file_path = path
    else
      raise ArgumentError.new("File #{path} not found")
    end

    @line_re = /(\w*.*\w*)\s*([A-Z][a-z][a-z]\s+\d+)\s+([A-Z][a-z][a-z]\s+\d+)\s+(\S*.*\S*)\s+[\s$]*([-,\d.]{4,})/
    @date_re = /Open Date:\s+(.*\d{4})\s-\sClose Date:\s(.*\d{4})/

  end
  def str_to_money(str)
     str.gsub('$',"").gsub(",","").to_f
  end
  def get_total_credits

      total_payments_re = /Payments and Credits\s+-\s+(\$[\d,]*.\d\d)/
      total_payments = 0
      lines = @pdf_reader.pages[0].text.split(/\n/)
      lines.each do |line|
        if m = total_payments_re.match(line)
          total_payments = str_to_money(m[1])
          break
        end
      end
      total_payments.round(2)
  end
  def get_total_purchases
    total_purchases_re = /Purchases\s+\$([\d,]*.\d\d)/
    total_purchases = 0
    lines = @pdf_reader.pages[0].text.split(/\n/)
    lines.each do |line|
      if m = total_purchases_re.match(line)
        total_purchases = -str_to_money(m[1])
        break
      end
    end
    total_purchases.round(2)
  end
  def verify_payments_and_credits
    purchases = get_total_purchases
    credits = get_total_credits
    if @purchases.round(2) != purchases
       raise "expected payments: #{purchases} #{}{@purchases}"
    elsif @credits.round(2) != credits
      raise "expected credits: #{credits} #{@credits}"
    end
    print "\n\ncredits: #{credits} purchase: #{purchases}\n\n"
  end
  def get_date_range(line)
      if md = @date_re.match(line)
        @start_date = Date.strptime(md[1].strip, '%b %d, %Y')
        @end_date = Date.strptime(md[2].strip, '%b %d, %Y')
      end
    return
  end

  def write_database(category, trans_date_str, post_date_str, payee, amount)
    begin
      # I'm going to add the actual year later for now I just add a year
      # to get around the FEB 29 entries that can't be converted if the year
      # current year is not a leap year.
      trans_date_str = trans_date_str + " 1980"
      post_date_str = post_date_str + " 1980"
      trans_date  = Date.strptime(trans_date_str,"%B %d %Y")
      post_date = Date.strptime(post_date_str,"%B %d %Y")
    rescue Exception => e
      puts e.message
      raise e
    end
    post_date = post_date.change(year: post_date.month == @start_date.month ? @start_date.year : @end_date.year)
    trans_date = trans_date.change(year: trans_date.month == @start_date.month ? @start_date.year : @end_date.year)
    if category.length > 0
      @category = category
    end

    amount_value = -(amount.gsub(",","").gsub("$","").to_f)
    if amount_value < 0
      @purchases += amount_value
    else
      @credits += amount_value
    end
    puts "#{@category.slice(0..10)}\t#{trans_date}\t#{post_date}\t#{payee.slice(0..20)}\t #{amount}\t(#{amount_value.to_f}}  "

    Disentry.create(category: category, post_date: post_date, description: payee, trans_date: trans_date, amount: amount_value)

  end
  def load_transactions
    Disentry.transaction do
      if @dir_path
        dir = Dir.new(@dir_path)
        dir.children.each do |file|
          next unless file =~ /pdf$/
          puts file
          file_path = File.join(@dir_path, file)
          load_pdf_file(file_path)
        end
      else
        load_pdf_file(@file_path)
      end
    end
  end

  def load_pdf_file(path)
    @start_date = nil
    @end_date = nil
    @category = nil
    @pdf_reader = PDF::Reader.new(path)
    @credits = 0
    @purchases = 0
    pages = @pdf_reader.pages

    pages.each do |pg|
      lines = pg.text.split(/\n/)
      lines.each do |line|
        if !@start_date
          get_date_range(line)
        elsif m = @line_re.match(line)
           write_database(m[1].strip, m[2].strip, m[3].strip, m[4].gsub('$',"").strip, m[5].strip )
        end
      end # lines.each
    end #pages.each
    verify_payments_and_credits
  end # load_pdf_file

end # ReadDiscoverPdf
if __FILE__ == $0
  path = ARGV[0]
  etl = LoadDiscoverPdf.new(path)
  etl.load_transactions

end
