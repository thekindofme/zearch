Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each {|file| require file }

database = ZenSearch::Database.new(data_sources: {
  users: 'data/users.json',
  tickets: 'data/tickets.json',
  organizations: 'data/organizations.json'
})
ZenSearch::Cli.run(database: database)
