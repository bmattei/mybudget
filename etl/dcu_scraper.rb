$LOAD_PATH << '.'
$LOAD_PATH << './etl'
require 'config/environment'

class DcuScraper
   def initialize(name, password)
     @name = name
     @password = password
     Capybara.register_driver :selenium do |app|
       Capybara::Selenium::Driver.new(app, browser: :chrome)
     end
     Capybara.javascript_driver = :chrome
     Capybara.configure do |config|
       config.default_max_wait_time = 15 # seconds
       config.default_driver = :selenium
     end
     @session = Capybara.current_session
     @driver = @session.driver
     @browser = @driver.browser
   end
   def login
     @driver.visit('https://dcu.org')
     sleep 3
     @session.fill_in("username", with:@name)
     @session.fill_in("password", with:@password)
     @session.click_on("Login")
   end
   def goto_statements
     statement_button_idx = 0
     pdf_button_idx = 1
     @session.has_text?("Free Checking 2")
     @session.click_on("Free Checking 2")
     @session.has_text?("MANAGE")
     @session.click_on("Manage")
     a = @session.all(".q-list .q-item")
     a[5].click
     frame = @session.find("iframe")
     @session.switch_to_frame(frame)
     @session.find_all('button')[statement_button_idx].click #select Period
     @session.has_text?("May")
     items = @session.find_all('.dropdown-item')

     num_items = items.count
     puts "num_statements: #{num_items}"
     (25..num_items).each do |i|
       puts "\nLOOP #{i}"
       begin
         items[i].click

         @session.find_all('button')[pdf_button_idx].click
         @session.find_all('button')[statement_button_idx].click #select Period
         @session.has_text?("May")
         items = @session.find_all('.dropdown-item')
       rescue => e
         puts e.message
         binding.break
       end
     end
   end
end
if __FILE__ == $0
  dcu = DcuScraper.new(ARGV[0], ARGV[1])
  dcu.login
  dcu.goto_statements
end
