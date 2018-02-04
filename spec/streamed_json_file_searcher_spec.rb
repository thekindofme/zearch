require_relative 'spec_helper'
require_relative '../lib/json_parse_error'
require_relative '../lib/streamed_json_file_searcher'

RSpec.describe StreamedJSONFileSearcher do
  subject(:searcher) { StreamedJSONFileSearcher.new('data/users.json') }

  describe '#search' do
    context 'when the search matches a single record' do
      it 'returns the matching record' do
        expect(searcher.search(term: 'phone', value: '9594-242-912').first['_id']).to eq(45)
      end
    end

    context 'when the search matches multiple records' do
      it 'returns all matching records' do
        expect(searcher.search(term: 'role', value: 'admin').size).to eq(24)
      end
    end

    context 'when the search does not match any record' do
      it 'returns an empty response' do
        expect(searcher.search(term: 'alias', value: 'James Bond')).to be_empty
      end
    end

    context 'when searching for objects where the search term is blank' do
      subject(:searcher) { StreamedJSONFileSearcher.new('spec/fixtures/tickets_with_blank_description.json') }

      it 'returns all matching records' do
        expect(searcher.search(term: 'description', value: '').count).to eq(1)
      end
    end

    context 'when there is a parsing error' do
      subject(:searcher) { StreamedJSONFileSearcher.new('spec/fixtures/invalid_data.json') }

      it 'raises a `JSONParsingError`' do
        expect { searcher.search(term: '_id', value: '12') }.to raise_error(JSONParseError)
      end
    end
  end
end
