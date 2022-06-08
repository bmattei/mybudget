$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'
load "etl/load_discover_pdf.rb"
load "etl/load_new_discover_pdf.rb"
load "etl/load_discover_csv.rb"
Disentry.delete_all

path = 'etl/discover'
dir = Dir.new(path)
new_pdf_date = Date.new(2020, 2, 1)
dir.children.each do |file_str|
  file_path = File.join(path, file_str)
  if File.file?(file_path) && file_str.ends_with?('csv')
    puts "file_str:#{file_str} file_path:#{file_path}"
    etl = LoadDiscoverCsv.new(file_path)
    etl.import_data
  elsif file_str.ends_with?('pdf')
    if Date.strptime(file_path.slice(-14..-5), '%Y-%m-%d') > new_pdf_date
      etl = LoadNewDiscoverPdf.new(file_path)
      etl.load_file
    else
      etl = LoadDiscoverPdf.new(file_path)
      etl.load_transactions
    end # if
  end # if
end
