# frozen_string_literal: true

require 'sqlite3'

class ProductService
  def bulk_create(products)
    db = SQLite3::Database.open('crawler.db')
    db.execute(create_table_query)

    products.each do |product|
      db.execute(
        "INSERT OR IGNORE INTO products (name, price, description, extra_information)
        VALUES(?, ?, ?, ?)",
        product[:name],
        product[:price],
        product[:description],
        product[:extra_information].to_json
      )
    end
  rescue SQLite3::Exception => e
    puts "Exception occurred: #{e}"
  ensure
    db&.close
  end

  private

  def create_table_query
    "CREATE TABLE IF NOT EXISTS products(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      price INTEGER NOT NULL,
      description TEXT,
      extra_information JSON
    )"
  end
end
