# frozen_string_literal: true

class CategoryTable
  attr_reader :name

  def initialize(name, data_file_path)
    @name = name
    @data_file_path = data_file_path
  end

  def searchable_fields
    @fields ||= SearchableFieldsParser.new(data_file_path).parse
  end


  private

  attr_reader :data_file_path
end
