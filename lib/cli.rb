# frozen_string_literal: true

class Cli
  def run
    workflow = WorkflowStateMachine.new(database: nil)

    loop do
      input = gets.chomp
      workflow.handle_input(input)
    end
  end
end
