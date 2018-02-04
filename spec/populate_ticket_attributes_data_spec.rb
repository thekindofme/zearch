require_relative 'spec_helper'
require_relative '../lib/populate_ticket_attributes'

RSpec.describe PopulateTicketAttributes do
  let(:database) { double }
  subject(:populate_ticket_attrs) { PopulateTicketAttributes.new(records, database) }

  describe '#populate' do
    context 'when `organization_id` is present' do
      let(:records) { [{ 'organization_id' => '1w' }] }

      it 'populate `organization_name`' do
        expect(database).to receive(:search_with_out_relation_data)
                              .with(category: :organizations, term: '_id', value: '1w')
                              .and_return([{ 'name' => 'org_xyz' }])

        populate_ticket_attrs.populate

        expect(records.first['organization_name']).to eq('org_xyz')
      end
    end

    context 'when `submitter_id` is present' do
      let(:records) { [{ 'submitter_id' => '1w' }] }

      it 'populate `submitted_by`' do
        expect(database).to receive(:search_with_out_relation_data)
                              .with(category: :users, term: '_id', value: '1w')
                              .and_return([{ 'name' => 'user_xyz' }])

        populate_ticket_attrs.populate

        expect(records.first['submitted_by']).to eq('user_xyz')
      end
    end

    context 'when `assignee_id` is present' do
      let(:records) { [{ 'assignee_id' => '1w' }] }

      it 'populate `submitted_by`' do
        expect(database).to receive(:search_with_out_relation_data)
                              .with(category: :users, term: '_id', value: '1w')
                              .and_return([{ 'name' => 'user_xyz' }])

        populate_ticket_attrs.populate

        expect(records.first['assigned_to']).to eq('user_xyz')
      end
    end
  end
end
