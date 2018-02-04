# frozen_string_literal: true

module ZenSearch
  class CategoryTable
    attr_reader :name

    def initialize(name, data_file_path)
      @name = name
      @data_file_path = data_file_path
    end

    def searchable_fields
      @fields ||= SearchableFieldsParser.new(data_file_path).parse
    end

    def search(term:, value:)
      StreamedJSONFileSearcher.new(data_file_path).search(term: term, value: value)
    end

    private

    attr_reader :data_file_path
  end
end
