require_relative '../spec_helper'

RSpec.describe ZenSearch::WorkflowStateMachine do
  let(:database) { double }
  subject(:workflow) { ZenSearch::WorkflowStateMachine.new(database: database) }

  describe '#initialize' do
    it 'display intro message' do
      expect { workflow }.to output(ZenSearch::WorkflowStateMachine::INTRO_TEXT).to_stdout
    end
  end

  describe '#handle_input' do
    it 'exit the program on `quit`' do
      expect(Kernel).to receive(:exit)
      workflow.handle_input('quit')
    end

    context 'in the intro stage' do
      it 'display `search options` on empty input' do
        workflow
        expect {
          workflow.handle_input('')
        }.to output(ZenSearch::WorkflowStateMachine::SEARCH_OPTIONS_TEXT).to_stdout
      end
    end

    context 'in the search options selection stage' do
      before { workflow.handle_input('') }

      context 'when opting to `search Zendesk`' do
        it 'asks for a search category' do
          expect { workflow.handle_input('1') }
            .to output(ZenSearch::WorkflowStateMachine::SELECT_SEARCH_CATEGORY_MSG).to_stdout
        end
      end

      context 'when opting to `list searchable fields`' do
        it 'calls `database.searchable_fields`' do
          expect(database).to receive(:searchable_fields).and_return({users: ['a', 'b', 'c']})
          workflow.handle_input('2')
        end

        it 'display the list of searchable fields received from the database' do
          allow(database).to receive(:searchable_fields).and_return({users: ['user_a']})
          expect { workflow.handle_input('2') }
            .to output(/user_a/).to_stdout
        end

        context 'when there is an error' do
          before { allow(database).to receive(:searchable_fields).and_raise(StandardError.new('debugging info goes here')) }

          it 'display error message' do
            expect { workflow.handle_input('2') }
              .to output(/#{ZenSearch::WorkflowStateMachine::ERROR_MSG}debugging info goes here/).to_stdout
          end
        end
      end
    end

    context 'in the `search Zendesk` -> select category stage' do
      before do
        workflow.handle_input('')
        workflow.handle_input('1')
      end

      context 'when a valid category is given' do
        it 'asks for a search term' do
          # Tickets category selected
          expect { workflow.handle_input('2') }
            .to output(/#{ZenSearch::WorkflowStateMachine::ENTER_SEARCH_TERM_MSG}/).to_stdout
        end
      end

      context 'when a invalid category is given' do
        it 'display an error' do
          # invalid category selected
          expect { workflow.handle_input('99xn9') }
            .to output(/#{ZenSearch::WorkflowStateMachine::INVALID_SEARCH_CATEGORY_MSG}: 99xn9/).to_stdout
        end
      end
    end

    context 'in the `search Zendesk` -> select category -> input search term stage' do
      before do
        workflow.handle_input('')
        workflow.handle_input('1')
        workflow.handle_input('2') # Tickets category selected
      end

      context 'when a valid search term is given' do
        it 'check search term validity via the database' do
          expect(database).to receive(:valid_search_term?)
                                .with(category: :tickets, term: 'valid_search_term').and_return(true)
          workflow.handle_input('valid_search_term')
        end

        it 'asks for a search value' do
          allow(database).to receive(:valid_search_term?)
                               .with(category: :tickets, term: 'valid_search_term').and_return(true)
          expect { workflow.handle_input('valid_search_term') }
            .to output(/#{Regexp.quote(ZenSearch::WorkflowStateMachine::ENTER_SEARCH_VALUE_MSG)}/).to_stdout
        end
      end

      context 'when a invalid search term is given' do
        it 'display an error' do
          allow(database).to receive(:valid_search_term?)
                               .with(category: :tickets, term: 'invalid_search_term').and_return(false)
          expect { workflow.handle_input('invalid_search_term') }
            .to output(/#{ZenSearch::WorkflowStateMachine::INVALID_SEARCH_TERM_MSG}/).to_stdout
        end
      end
    end

    context 'in the `search Zendesk` -> select category -> input term -> input value stage' do
      before do
        allow(database).to receive(:valid_search_term?)
                             .with(category: :tickets, term:'test_search_term').and_return(true)

        workflow.handle_input('')
        workflow.handle_input('1')
        workflow.handle_input('2') # Tickets category selected
        workflow.handle_input('test_search_term')
      end

      it 'executes a search via the database' do
        expect(database).to receive(:search).with(
          category: :tickets,
          term: 'test_search_term',
          value: 'test_search_value'
        ).and_return(['test search results'])

        workflow.handle_input('test_search_value')
      end

      it 'display search results returned by the database' do
        allow(database).to receive(:search).and_return(['test search results'])
        expect { workflow.handle_input('test_search_value') }
          .to output(/test search results/).to_stdout
      end

      context 'when search results are empty' do
        it 'display no search results message' do
          expect(database).to receive(:search).with(
            category: :tickets,
            term: 'test_search_term',
            value: 'test_search_value'
          ).and_return([])

          expect { workflow.handle_input('test_search_value') }
            .to output(/#{ZenSearch::WorkflowStateMachine::NO_RESULTS_FOUND_MSG}/).to_stdout
        end
      end

      context 'when there is an error searching for a match' do
        before { allow(database).to receive(:search).and_raise(StandardError.new('debugging info goes here')) }

        it 'display error message' do
          expect { workflow.handle_input('test_search_value') }
            .to output(/#{ZenSearch::WorkflowStateMachine::ERROR_MSG}debugging info goes here/).to_stdout
        end
      end
    end
  end
end
