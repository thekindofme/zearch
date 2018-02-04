require_relative 'lib/cli'
require_relative 'lib/workflow_state_machine'
require_relative 'lib/database'

database = Database.new(data_sources: {
  users: 'data/users.json',
  tickets: 'data/tickets.json',
  organizations: 'data/organizations.json'
})
Cli.run(database: database)
