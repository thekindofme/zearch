require_relative 'lib/json_parse_error'
require_relative 'lib/cli'
require_relative 'lib/workflow_state_machine'
require_relative 'lib/database'
require_relative 'lib/category_table'
require_relative 'lib/searchable_fields_parser'

database = Database.new(data_sources: {
  users: 'data/users.json',
  tickets: 'data/tickets.json',
  organizations: 'data/organizations.json'
})
Cli.run(database: database)
