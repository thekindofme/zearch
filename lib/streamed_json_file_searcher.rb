# frozen_string_literal: true

require 'json/stream'

class StreamedJSONFileSearcher
  def initialize(file_path)
    @state = :init
    @file_path = file_path
    @file_parser = ::JSON::Stream::Parser.new

    @file_parser.start_object { @current_object = {} }

    @file_parser.end_object do
      if @state == :add_obj_results
        @results << @current_object
        @state = :init
      end
    end

    @file_parser.key do |key|
      @last_read_key = key

      @state = :term_matched if key == @search_term
    end

    @file_parser.value do |value|
      @current_object[@last_read_key] = value if @current_object

      if @state == :term_matched
        @state = if search_value_found?(value)
                   :add_obj_results
                 else
                   :init
                 end
      end
    end
  end

  def search(term:, value:)
    @search_term = term
    @search_value = value
    @results = []

    IO.foreach(file_path) do |line|
      file_parser << line
    rescue JSON::Stream::ParserError => e
      raise JSONParseError, 'Unable to parse the JSON file for searching: ' + e.inspect
    end

    results
  end

  private

  attr_reader :file_path, :file_parser, :state, :results

  def search_value_found?(value)
    @search_value.to_s == value.to_s
  end
end
