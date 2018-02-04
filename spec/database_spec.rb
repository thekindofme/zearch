require_relative 'spec_helper'
require_relative '../lib/database'
require_relative '../lib/category_table'
require_relative '../lib/json_parse_error'
require_relative '../lib/searchable_fields_parser'
require_relative '../lib/streamed_json_file_searcher'
require_relative '../lib/populate_user_attributes'
require_relative '../lib/populate_ticket_attributes'

RSpec.describe Database do
  let(:data_sources) {
    {
      users: 'data/users.json',
      tickets: 'data/tickets.json',
      organizations: 'data/organizations.json'
    }
  }
  subject(:database) { Database.new(data_sources: data_sources) }

  describe '#searchable_fields' do
    it 'returns a hash of searchable fields for each category' do
      searchable_fields = database.searchable_fields
      expect(searchable_fields[:users]).to include(
                                             "_id", "url", "external_id", "name", "alias", "created_at",
                                             "active", "verified", "shared", "locale", "last_login_at",
                                             "timezone", "email", "phone", "signature", "organization_id",
                                             "tags", "suspended", "role"
                                           )

      expect(searchable_fields[:tickets]).to include(
                                               "_id", "url", "external_id", "created_at", "type", "subject",
                                               "description", "priority", "status", "submitter_id", "assignee_id",
                                               "organization_id", "tags", "has_incidents", "due_at", "via"
                                             )

      expect(searchable_fields[:organizations]).to include(
                                                     "_id", "url", "external_id", "name", "domain_names", "created_at",
                                                     "details", "shared_tickets", "tags"
                                                   )
    end
  end

  describe '#valid_search_term?' do
    context 'when given a valid search term' do
      it 'returns true' do
        expect(database.valid_search_term?(category: :organizations, term: 'details')).to be true
      end
    end

    context 'when given an invalid search term' do
      it 'returns false' do
        expect(database.valid_search_term?(category: :users, term: 'coast')).to be false
      end
    end
  end

  describe '#search' do
    context 'when there are matching records' do
      context 'for Users' do
        it 'includes organization name' do
          expect(database.search(category: :users, term: '_id', value: '22').first['organization_name']).to eq('Bitrex')
        end

        it 'includes assigned ticket subjects' do
          result = database.search(category: :users, term: '_id', value: '22')
          expect(result.first['assigned_ticket_0']).to eq("A Problem in Denmark")
          expect(result.first['assigned_ticket_1']).to eq("A Drama in East Timor")
          expect(result.first['assigned_ticket_2']).to eq("A Drama in Chad")
          expect(result.first['assigned_ticket_3']).to eq("A Problem in Malaysia")
        end

        it 'includes submitted ticket subjects' do
          result = database.search(category: :users, term: '_id', value: '22')
          expect(result.first['submitted_ticket_0']).to eq("A Catastrophe in Guam")
          expect(result.first['submitted_ticket_1']).to eq("A Catastrophe in Korea (South)")
          expect(result.first['submitted_ticket_2']).to eq("A Nuisance in Anguilla")
          expect(result.first['submitted_ticket_3']).to eq("A Problem in Gambia")
          expect(result.first['submitted_ticket_4']).to eq("A Drama in Cameroon")
        end
      end

      context 'for Tickets' do
        it 'includes organization name' do
          results = database.search(category: :tickets, term: '_id', value: '49a3526c-2bc4-45b0-a6dd-6a55e5a4bd9f')
          expect(results.first['organization_name']).to eq('Netur')
        end

        it 'includes assignee name' do
          results = database.search(category: :tickets, term: '_id', value: '49a3526c-2bc4-45b0-a6dd-6a55e5a4bd9f')
          expect(results.first['assigned_to']).to eq('Alvarez Black')
        end

        it 'includes submitter name' do
          results = database.search(category: :tickets, term: '_id', value: '49a3526c-2bc4-45b0-a6dd-6a55e5a4bd9f')
          expect(results.first['submitted_by']).to eq('Tyler Bates')
        end
      end
    end
  end

  describe '#search_with_out_relation_data' do
    context 'when there are matching records' do
      it 'returns an array of results' do
        results = database.search_with_out_relation_data(category: :users, term: '_id', value: '7')
        expect(results).not_to be_empty
        expect(results.first['_id']).to eq(7)
      end
    end

    context 'when there no matching records' do
      it 'returns an empty array' do
        expect(database.search_with_out_relation_data(category: :users, term: '_id', value: '412112axdw')).to be_empty
      end
    end
  end
end
