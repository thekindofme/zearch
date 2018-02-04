require_relative 'spec_helper'
require_relative '../lib/populate_user_attributes'

RSpec.describe PopulateUserAttributes do
  let(:database) { double }
  subject(:populate_ticket_attrs) { PopulateUserAttributes.new(records, database) }

  describe '#populate' do
    before { allow(database).to receive(:search_with_out_relation_data).and_return([]) }

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

    context 'when user have submitted tickets' do
      let(:records) { [{ '_id' => '1' }] }

      it 'populates submitted ticket subjects in the record' do
        expect(database).to receive(:search_with_out_relation_data)
                              .with(category: :tickets, term: 'submitter_id', value: '1')
                              .and_return([{ 'subject' => 'ticket_1' }, { 'subject' => 'ticket_2' }])

        populate_ticket_attrs.populate

        expect(records.first['submitted_ticket_0']).to eq('ticket_1')
        expect(records.first['submitted_ticket_1']).to eq('ticket_2')
      end
    end

    context 'when user have assigned tickets' do
      let(:records) { [{ '_id' => '1' }] }

      it 'populates assigned ticket subjects in the record' do
        expect(database).to receive(:search_with_out_relation_data)
                              .with(category: :tickets, term: 'assignee_id', value: '1')
                              .and_return([{ 'subject' => 'ticket_1' }, { 'subject' => 'ticket_2' }])

        populate_ticket_attrs.populate

        expect(records.first['assigned_ticket_0']).to eq('ticket_1')
        expect(records.first['assigned_ticket_1']).to eq('ticket_2')
      end
    end
  end
end
