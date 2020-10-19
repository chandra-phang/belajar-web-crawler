# frozen_string_literal: true

$LOAD_PATH << '.'

require 'spec_helper'
require 'pry'
require 'crawler'

RSpec.describe 'Crawler' do
  describe 'product pagination' do
    it 'returns 36 items' do
      category_page = "https://magento-test.finology.com.my/women/tops-women.html"
      paginated_page = category_page += "?product_list_limit=#{PAGINATION}"

      crawler = Crawler.new
      page = crawler.parse_page(paginated_page)
      products = crawler.collect_products(page)
      url = crawler.collect_url(products)

      expect(url.count).to eq(36)
    end
  end

  describe 'cache' do
    it 'creating cache folder' do
      Lightly.new.flush
      expect(File).not_to exist("./cache")

      Crawler.new.run
      expect(File).to exist("./cache")
    end
  end
end
