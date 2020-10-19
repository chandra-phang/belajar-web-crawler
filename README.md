# Crawler
Crawler API to extract product information from: http://magento-test.finology.com.my/breathe-easy-tank.html

## Setup
1. Install ruby (I used 2.2.3 version)
2. Install gem
`gem install httparty`
`gem install nokogiri`
`gem install sqlite3`
`gem install lightly`
`gem install rspec`
`gem install rake`
`gem install pry`
3. Create database
`sqlite3 test.db`
3. Run the program
`irb`
`require './crawler'`
`Crawler.new.run`
4. Run `rspec spec/crawler_spec.rb` to check if everything's okay.