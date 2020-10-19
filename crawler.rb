# frozen_string_literal: true

$LOAD_PATH << '.'

require 'lightly'
require 'lib/http_helper'
require 'services/product_service'

# 36 items per page to advance the progress
PAGINATION = 36

class Crawler
  include HttpHelper

  def initialize
    @initial_url = 'https://magento-test.finology.com.my/breathe-easy-tank.html'
    @products = []
    @product_service = ProductService.new
  end

  def run
    initial_page = parse_page(@initial_url)
    categories_url = collect_categories_url(initial_page)
    products_url = collect_products_url(categories_url)
    # I choose to send request to each item page because the HTML elements on
    # category page aren't consistent, and have higher complexity of checking.
    products_url.each do |product_url|
      page = parse_page(product_url)
      product = {
        name: product_name(page),
        price: product_price(page),
        description: product_description(page),
        extra_information: product_information(page)
      }
      @products << product
    end

    @product_service.bulk_create(@products)

    sorted_products = @products.sort_by { |product| product[:name] }
    puts sorted_products
  end

  def parse_page(url)
    content = Lightly.new(life: '3h').get(url) do
      super(url).serialize
    end
    Nokogiri::HTML(content)
  end

  def collect_categories_url(page)
    # Since first level category already covered second level and so on
    # we don't need to request the others.
    all_category = page.css('ul.level0').css('li').css('a')
    child_category = page.css('ul.level0').css('li').css('ul').css('a')

    collect_url(all_category - child_category)
  end

  def collect_products_url(categories_url)
    products = []
    categories_url.each do |category_url|
      category_url += "?product_list_limit=#{PAGINATION}"
      category_page = parse_page(category_url)

      products += collect_products(category_page)

      next_pages(category_page).each do |next_url|
        next_page = parse_page(next_url)
        products += collect_products(next_page)
      end
    end

    collect_url(products)
  end

  def collect_products(page)
    page.css('.product-item-link').css('a')
  end

  def collect_url(link)
    Array(link).flat_map { |a| a['href'] }.compact
  end

  private

  def product_name(page)
    name = page.css('h1.page-title').first
    name&.text&.strip
  end

  def product_price(page)
    price = page.css('span.price-wrapper').css('span.price').first
    price&.text
  end

  def product_description(page)
    description = page.css('div.product.attribute.description').first
    description&.text&.strip
  end

  def product_information(page)
    info = {}
    page.css('table.data.table.additional-attributes').css('tr').each do |row|
      key = row.css('th').first.text
      value = row.css('td').first.text
      info[key] = value
    end
    info
  end
end
