# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

module HttpHelper
  def parse_page(url)
    doc = HTTParty.get(url)
    Nokogiri::HTML(doc)
  end

  def next_pages(page)
    page.css('ul.pages-items').css('a').map { |x| x['href'] }.uniq
  end
end
