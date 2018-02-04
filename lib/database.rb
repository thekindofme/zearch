# frozen_string_literal: true

class Database
  def initialize(data_sources:)
    init_category_tables(data_sources)
  end

  def valid_search_term?(category:, term:)
    searchable_fields[category].include?(term)
  end

  def searchable_fields
    {}.tap do |result|
      category_tables.values.each do |table|
        result[table.name] = table.searchable_fields
      end
    end
  end

  private

  attr_accessor :category_tables

  def init_category_tables(data_sources)
    self.category_tables = {}
    data_sources.each do |table_name, data_file_path|
      category_tables[table_name] = CategoryTable.new(table_name, data_file_path)
    end
  end

end
