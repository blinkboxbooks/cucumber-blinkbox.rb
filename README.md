# Cucumber::Blinkbox

A selection of blinkbox books specific helpers for cucumber tests.

## Installation

Add this line to your application's Gemfile:

    gem 'cucumber-blinkbox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cucumber-blinkbox

## Usage

### Data Dependencies

A series of known data can be defined and easily referenced from within steps.

Given `config/data.yml` is present:

```yaml
book:
  is currently available for purchase:
    - isbn: "9780753549674"
    - isbn: "9781446414330"
object:
  condition:
    - member objects
    - which may be returned
  other condition:
    - different member objects
    - which are chosen from at random
```

When a step is defined which needs access to data dependent information:

```ruby
require "cucumber/blinkbox/data_dependencies"

Given(/^there is a book I'm allowed to buy$/) do
  @book = data_for_a(:book, which: "is currently available for purchase")
end
```

Then a random member of the array defined for the specified object and with the given condition is returned.

For a step like "Given there is a different book" the `but_isnt:` named argument may be useful, which ensures the randomly chosen member object doesn't match (`==`) the one specified.

You can speify a different location for the yaml file by altering the contents of `TEST_CONFIG['data.yml']` before requiring this library.

### Environments

Given `config/environments.yml` is present:

```ruby
qa:
  servers:
    auth: https://auth.mobcastdev.com/
```

When a step is defined which needs the base URI for a service:

```ruby
require "cucumber/blinkbox/environments"

When(/^I have a chat with the auth server$/) do
  TotallyRealHTTPClient.get test_env[:auth]
  # or
  TotallyRealHTTPClient.get test_env.auth
end
```

Then the `servers` variable is a hash populated with the servers specified in the yaml file for ease of access. (This is used by the Requests helper)

You can speify a different location for the yaml file by altering the contents of `TEST_CONFIG['environments.yml']` before requiring this library.

### Requests

A series of methods which will help make HTTP requests to servers defined with an `environments.yml`:

* There are four methods: `http_get`, `http_post`, `http_put`, `http_delete`.
* A environment server should be specified eg: `http_post :auth, "/oauth2/token", {"body" => "as a hash"}`
* For the requests which need a body, the ruby object sent as the third argument will be JSONified for you.
* Headers can be specified as the third argument

### Responses

Defines the method `parse_response_data` which converts the most recently received HTTP response from JSON into a ruby object, and ensures that response had the correct Content-Type.

### Response Validation

Defines a series of helper methods for validating API responses. You will almost certainly need to define a structure for the entities your service needs:

Given entity validation definitions like this:

```ruby
module KnowsAboutCartoonServiceResponseValidation
  def validate_cartoon(data)
    validate_attribute(data, "name", type: String) { |value| expect(value).to eq(value.upcase) }
    validate_attribute(data, "lead_character.age", type: Numeric)
  end

  def validate_list_of_cartoon(data)
    total_age = 0
    data['items'].each do |item|
      total_age += item.deep_key('lead_character.age')
    end
    validate_attribute(data, "combined_age", type: Numeric) { |value| expect(value).to eq(total_age) }
  end
end

World(KnowsAboutCartoonServiceResponseValidation)
```

When steps are defined which validate the format of an item or list response:

```ruby
require "cucumber/blinkbox/response_validation"

Then(/^the response is a (.+)$/) do |item_type|
  validate_entity(item_type.snake_case, parse_response_data)
end

Then(/^the response is a(?: (.+))? list containing (#{CAPTURE_INTEGER}) (.+)s?$/) do |list_type, count, item_type|
  Cucumber::Rest::Status.ensure_status(200)
  data = parse_response_data
  validate_list(data, list_type: list_type, item_type: item_type.snake_case, count: count)
end
```
Then the defined validation will be run against the entity and/or the list as specified.

### Subjects

Tests often require that you keep track of the subject of the sentence which has been written in gherkin. While writing tests it's possible to lose track of what's defined and what isn't. This helper defines a method which provides a simple & readable way to set and get these, with useful errors for when you've forgotten to set something you need.

```ruby
Given(/^I have a book$/) do
  subject(:book,{"isbn" => "9780111222333"})
end

When(/^I submit my request$/) do
  @response = { "isbn" => "9780111222333" }
end

Then(/^the response matches the book I have$/) do
  expect(@response).to eq(subject(:book))
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
