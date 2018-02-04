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

  def search(category:, term:, value:)
    records = search_with_out_relation_data(category: category, term: term, value: value)
    add_relation_data(category: category, records: records)
  end

  def search_with_out_relation_data(category:, term:, value:)
    category_tables[category].search(term: term, value: value)
  end

  private

  attr_accessor :category_tables

  def init_category_tables(data_sources)
    self.category_tables = {}
    data_sources.each do |table_name, data_file_path|
      category_tables[table_name] = CategoryTable.new(table_name, data_file_path)
    end
  end

  def add_relation_data(category:, records:)
    case category
    when :users
      PopulateUserAttributes.new(records, self).populate
    when :tickets
      PopulateTicketAttributes.new(records, self).populate
    when :organizations
      records
    else
      raise StandardError, "Don't know how to populate relation data for #{category}"
    end
  end
end
