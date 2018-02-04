require_relative '../spec_helper'

RSpec.describe SearchableFieldsParser do
  describe '#parse' do
    context 'for users.json' do
      it 'returns all fields present in the first document in the provided JSON doc' do
        parser = SearchableFieldsParser.new('data/users.json')
        expect(parser.parse).to include("_id", "url", "external_id", "name", "alias", "created_at", "active",
                                        "verified", "shared", "locale", "last_login_at", "email", "phone",
                                        "signature", "organization_id", "tags", "suspended", "role")
      end
    end

    context 'for tickets.json' do
      it 'returns all fields present in the first document in the provided JSON doc' do
        parser = SearchableFieldsParser.new('data/tickets.json')
        expect(parser.parse).to include("_id", "url", "external_id", "created_at", "type",
                                        "subject", "description", "priority", "status", "submitter_id",
                                        "assignee_id", "organization_id", "tags", "has_incidents", "due_at", "via")
      end
    end

    context 'for organizations.json' do
      it 'returns all fields present in the first document in the provided JSON doc' do
        parser = SearchableFieldsParser.new('data/organizations.json')
        expect(parser.parse).to include("_id", "url", "external_id", "name", "domain_names", "created_at",
                                        "details", "shared_tickets", "tags")
      end
    end

    context 'when the document contain invalid json' do
      it 'raises a `JSONParseError`' do
        parser = SearchableFieldsParser.new('spec/fixtures/invalid_data.json')
        expect { parser.parse }.to raise_error(JSONParseError)
      end
    end
  end
end
