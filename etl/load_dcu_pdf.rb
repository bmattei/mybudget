$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
# Read DCU file and Load into DCUEntry model
class ReadDcuPdf
    def initialize(path)
      if File.file?(path) && path.end_with?(".pdf")
        @path = path
      else
        raise ArgumentError.new("File #{path} not found")
      end
      @pdf_reader = PDF::Reader.new(@path)
      @end_date = Date.strptime(@path.slice(-12..-5),"%Y%m%d")
      @start_date = @end_date.beginning_of_month
    end
    def readlines
       pages = @pdf_reader.pages
       lines = []
       pages.each do |pg|
         pg_lines = pg.text.split(/\n/)
         lines += pg_lines
       end
       lines
    end
    def str_to_amount(str)
      str = str.gsub("," , "")
      str.last.eql?("-") ? -(str.chop.to_f) : str.to_f
    end
    def str_to_date(str)
      date_str = ""
      # In january we may get an entry from december the year before
      if @start_date.month == 1 && str =~ /dec/i
        date_str = str+(@start_date.year - 1).to_s
      else
        date_str = str+@start_date.year.to_s
      end
      Date.strptime(date_str,"%b%d%Y")
    end
    def read_checking_entries
       entries = []
       previous_balance_re = /PREVIOUS BALANCE\s+([0-9,.]{2,})/
       table_label_re = /FREE CHECKING\s+ACCT#/
       table_header_re = /DATE\s+TRANSACTION DESCRIPTION\s{5,}WITHDRAWALS\s+DEPOSITS\s+BALANCE/
       table_line_re = /([A-Z]{3}\d\d)(.*?)\s+(-?[\d,]+\.\d\d-?)\s+(-?[\d,]+\.\d\d-?)/
       new_balance_re =/([A-Z]{3}\d\d)\s+NEW BALANCE\s{5,}([0-9,.]{2,})/
       lines = readlines
       state = :wait_label
       lines.each do |line|

          case state
          when :wait_label
            state = :read_table_header if table_label_re.match(line)
          when :read_table_header
            state = :read_previous_balance if table_header_re.match(line)
          when :read_previous_balance
            if match = previous_balance_re.match(line)
              entries << {entry_date: @start_date,
                          previous_balance: true,
                          description: "PREVIOUS BALANCE",
                          balance: str_to_amount(match[1])}
               state = :read_table
            end
          when :read_table
            pp line
            if match = table_line_re.match(line)
              entries << {entry_date: str_to_date(match[1]),
                description: match[2],
                amount: str_to_amount(match[3]),
                balance:  str_to_amount(match[4])
              }
            elsif match = new_balance_re.match(line)
              entries << {entry_date: str_to_date(match[1]),
                          new_balance: true,
                          description: "NEW BALANCE",
                          balance: str_to_amount(match[2])
                        }
               break
            end

          end
        end
        # pp entries
        return entries
    end
end

class LoadDcuEntry


  def write_dcu_entries(records, account_name)
    records.each do |rec|
      puts "#{account_name} #{rec[:entry_date]} #{rec[:amount]} #{rec[:balance]} #{rec[:description]}"
      DcuEntry.create(account_name: account_name,
        entry_date: rec[:entry_date],
        amount: rec[:amount],
        balance: rec[:balance],
        description:  rec[:description] )
    end
  end
end
if __FILE__ == $0


  if File.directory?(ARGV[0])
    dir_path = ARGV[0]
    dir = Dir.new(dir_path)
    wrtr = LoadDcuEntry.new
    DcuEntry.delete_all if ARGV.include?("load")
    files = dir.children.sort {|a, b| Date.strptime(a.slice(-12..-5), "%Y%m%d") <=> Date.strptime(b.slice(-12..-5), "%Y%m%d")}
    files.each do |file|
      file_path = File.join(ARGV[0],file)
      puts "*************#{file_path}"
      rdr = ReadDcuPdf.new(file_path)
      entries = rdr.read_checking_entries
      pp entries
      wrtr.write_dcu_entries(entries, "DCU CHECKING") if ARGV.include?("load")
    end
  else
    rdr = ReadDcuPdf.new(ARGV[0])
    entries = rdr.read_checking_entries
    pp entries
  end

end
