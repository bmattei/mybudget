$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
class LoadDiscoverCsv
  Trans_Date = 0
  Post_Date = 1
  Description = 2
  Amount = 3
  Category = 4
  def initialize(file)
    if (File.exist?(file) && file.end_with?("csv"))
      @file = File.new(file)
    else
      raise ArgumentError.new("File #{file} not found")
    end
  end
  def import_data


    file_path = @file.path
    puts file_path
    rows = CSV.read(@file)
    if !rows[0][Trans_Date].eql?("Trans. Date")
      puts "\n****Not a discover CSV FILE:  #{file_path} ****"
      return
    end
    rows.slice(1..).each do |row|
      trans_date = Date.strptime(row[Trans_Date],"%m/%d/%Y")
      post_date = Date.strptime(row[Post_Date],"%m/%d/%Y")
      description = row[Description]
      category = row[Category]
      amount = -row[Amount].to_f
      puts "\ntrans_date: #{trans_date}  post_date #{post_date}"
      puts "description: #{description} category: #{category}  amount: #{amount}"
       Disentry.create(trans_date: trans_date,
                   post_date: post_date,
                     description: description,
                   category: category,
                   amount: amount,
                  file: file_path)
    end
  end
end
if __FILE__ == $0
  if File.directory?(ARGV[0])
    dir = Dir.new(ARGV[0])
    dir.children.each {|file_str|
      file_path = File.join(ARGV[0],file_str)
      if File.file?(file_path) && file_str.ends_with?("csv")
        puts "file_str:#{file_str} file_path:#{file_path}"
        etl = LoadDiscoverCsv.new(file_path)
        pp etl
        etl.import_data
      end
    }
  else
    etl = LoadDiscoverCsv.new(ARGV[0])
    etl.import_data
  end

end
