## Setup
- `bundle install`

## Dependencies
- Ruby 2.5.0

## How to run
- Test suit: `rspec`
- Program: `ruby zen_search.rb` 

## Design
### Streaming JSON files over loading them in-memory
As we are required to be able to handle large amounts of data as per the specification. I've taken a streaming
approach (against a in-memory approach) when it comes to parsing and searching the provided data. This should give 
us linear time complexity O(n) (which is no worse than the in-memory approach) and fixed O(1) space complexity for
searching an n number of objects in a JSON file.

### Use of state machines to manage the CLI and Search (over stream)
- The `WorkflowStateMachine` class is a state machine that manages the various user workflows via the CLI
- `StreamedJsonFileSearcher` and `SearchableFieldsParser` uses internal 'state machines' to search the JSON documents

## Assumptions
- all records of a given type (ex: User) have the same set of fields
- where a certain record has a blank value (ex:a ticket with no description), the JSON file specifies the blank value 
for the term (ex: `description: ''`) instead of omitting the term all together.
- when searching, all data values will be converted to a string before being compared with the specified search string.
ex: if you search for id => "1" it'll match records where id => "1" and id => 1 (where the string representation of the value is "1")...etc
