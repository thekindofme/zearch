# frozen_string_literal: true

class WorkflowStateMachine
  INTRO_TEXT = "
Welcome to Zen Search
Type 'quit' to exit at any time, Press 'Enter' to continue
"
  SEARCH_OPTIONS_TEXT = "
Select search options:
* Press 1 to search Zendesk
* Press 2 to view a list of searchable fields
* Type 'quit' to exit
"
  SELECT_SEARCH_CATEGORY_MSG = <<~END
    Select 1) Users or 2) Tickets or 3) Organizations
  END

  UNKNOWN_COMMAND_MSG = 'Unknown input'
  INVALID_SEARCH_CATEGORY_MSG = 'Invalid search category!'
  QUIT_CMD = 'quit'
  PROCEED_CMD = ''
  START_SEARCH_CMD = '1'
  LIST_SEARCHABLE_FIELDS_CMD = '2'
  ENTER_SEARCH_TERM_MSG = 'Enter search term'
  INVALID_SEARCH_TERM_MSG = 'Invalid search term!'
  ENTER_SEARCH_VALUE_MSG = "Enter search value (or just 'Enter' for empty value)"
  SEARCH_INITIATED_MSG = 'Searching %<category>s for %<term>s with a value of %<value>s'

  def initialize(database:)
    self.database = database
    self.state = :intro_stage
    self.user_input_to_search_category_map = {
      '1' => :users, '2' => :tickets, '3' => :organizations
    }

    puts INTRO_TEXT
  end

  def handle_input(input)
    Kernel.exit if input == QUIT_CMD
    raise StandardError, 'Invalid `state`' if state.nil?
    send("handle_#{state}", input)
  end

  private

  attr_accessor :state, :search_category, :search_term, :search_value, :database, :user_input_to_search_category_map

  def handle_intro_stage(input)
    case input
    when PROCEED_CMD
      self.state = :options_select_stage
      puts SEARCH_OPTIONS_TEXT
    else
      puts "#{UNKNOWN_COMMAND_MSG}: #{input}"
    end
  end

  def handle_options_select_stage(input)
    case input
    when START_SEARCH_CMD
      self.state = :search_select_category_stage
      puts SELECT_SEARCH_CATEGORY_MSG
    when LIST_SEARCHABLE_FIELDS_CMD
      puts all_searchable_fields

      reset_state_machine
      puts INTRO_TEXT
    else
      puts "#{UNKNOWN_COMMAND_MSG}: #{input}"
    end
  end

  def handle_search_select_category_stage(input)
    case input
    when '1', '2', '3'
      self.state = :search_enter_term_stage
      self.search_category = user_input_to_search_category_map[input]
      puts ENTER_SEARCH_TERM_MSG
    else
      puts "#{INVALID_SEARCH_CATEGORY_MSG}: #{input}"
      puts SELECT_SEARCH_CATEGORY_MSG
    end
  end

  def handle_search_enter_term_stage(input)
    if valid_search_term?(input)
      self.state = :search_enter_value_stage
      self.search_term = input
      puts ENTER_SEARCH_VALUE_MSG
    else
      puts "#{INVALID_SEARCH_TERM_MSG}: #{input}"
    end
  end

  def handle_search_enter_value_stage(input)
    self.search_value = input
    puts format(
      SEARCH_INITIATED_MSG,
      category: search_category,
      term: search_term,
      value: search_value
    )

    result = execute_search(category: search_category, term: search_term, value: search_value)
    puts result

    reset_state_machine
    puts INTRO_TEXT
  end

  def valid_search_term?(search_term)
    database.valid_search_term?(search_term)
  end

  def reset_state_machine
    self.state = :intro_stage
    self.search_category = self.search_term = self.search_value = nil
  end

  def execute_search(category:, term:, value:)
    database.search(category: category, term: term, value: value)
  end

  def all_searchable_fields
    database.list_searchable_fields
  end
end
