# frozen_string_literal: true

class PopulateUserAttributes
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

      submitted_tickets = submitted_tickets(record['_id'])
      if submitted_tickets.any?
        submitted_tickets.each_with_index do |ticket, index|
          record["submitted_ticket_#{index}"] = ticket['subject']
        end
      end

      assigned_tickets = assigned_tickets(record['_id'])
      next unless assigned_tickets.any?
      assigned_tickets.each_with_index do |ticket, index|
        record["assigned_ticket_#{index}"] = ticket['subject']
      end
    end
  end

  private

  def organization_details(id)
    @database.search_with_out_relation_data(category: :organizations, term: '_id', value: id).first
  end

  def submitted_tickets(user_id)
    @database.search_with_out_relation_data(category: :tickets, term: 'submitter_id', value: user_id)
  end

  def assigned_tickets(user_id)
    @database.search_with_out_relation_data(category: :tickets, term: 'assignee_id', value: user_id)
  end
end
