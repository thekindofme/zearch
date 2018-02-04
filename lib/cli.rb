# frozen_string_literal: true

module ZenSearch
  class Cli
    def self.run(database:)
      workflow = WorkflowStateMachine.new(database: database)

      loop do
        input = gets.chomp
        workflow.handle_input(input)
      end
    end
  end
end
