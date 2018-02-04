# frozen_string_literal: true

require 'json/stream'

class SearchableFieldsParser
  JSONParseError = Class.new(StandardError)

  def initialize(file_path)
    @state = :init
    @fields = []
    @file_path = file_path
    @file_parser = ::JSON::Stream::Parser.new
    @file_parser.end_object { @state = :end_object }
    @file_parser.key { |key| @fields << key }
  end

  def parse
    IO.foreach(file_path) do |line|
      break if fields_populated?

      begin
        file_parser << line
      rescue JSON::Stream::ParserError => e
        raise JSONParseError, 'Unable to parse the list of searchable fields: ' + e.inspect
      end
    end

    fields
  end

  private

  attr_reader :file_path, :file_parser, :state, :fields

  def fields_populated?
    state == :end_object
  end
end
