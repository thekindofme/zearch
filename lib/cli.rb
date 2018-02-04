# frozen_string_literal: true

class Cli
  def self.run(database: database)
    workflow = WorkflowStateMachine.new(database: database)

    loop do
      input = gets.chomp
      workflow.handle_input(input)
    end
  end
end
