# frozen_string_literal: true

class PopulateTicketAttributes
  def initialize(records, database)
    @records = records
    @database = database
  end

  def populate
    @records.each do |record|
      if record['organization_id']
        org_details = organization_details(record['organization_id'])
        record['organization_name'] = org_details['name']
      end

      if record['submitter_id']
        submitter_details = user_details(record['submitter_id'])
        record['submitted_by'] = submitter_details['name']
      end

      if record['assignee_id']
        assignee_details = user_details(record['assignee_id'])
        record['assigned_to'] = assignee_details['name']
      end
    end
  end

  private

  def organization_details(id)
    @database.search_with_out_relation_data(category: :organizations, term: '_id', value: id).first
  end

  def user_details(id)
    @database.search_with_out_relation_data(category: :users, term: '_id', value: id).first
  end
end
