# Boa - The Smart Constructor

This is a work in progress. It is not ready for production use.

## Usage

```ruby
class Person < T::Struct
  include Boa

  prop :id,         UUID
  prop :name,       String, length: 1..50
  prop :email,      T.nilable(Email)
  prop :admin,      T.nilable(T::Boolean)
  prop :birth_date, T.nilable(Date), includes: Date.new(1900)..Date.today
  prop :created_at, DateTime, factory: -> { DateTime.now }
end

# Person.new actually does a few things:
# - Constructs the data using the *real* constructor
# - Validates the object
# - If valid it returns a Person
# - If invalid it returns a Person::Invalid that wraps the data, containing
#   all the errors for the Person. Use with Ruby 3 case pattern matching.
person = Person.new(id: id, name: 'Dan Kubb', email: 'github@dan.kubb.ca')

# Expected accessor usage
puts person.created_at  # => returns DateTime.now
puts person.email       # => returns an Email object (or nil when no email is provided)

# Ruby 3 case pattern matching
valid_person =
  case person
  in Person if person.admin
    person                                              # person is valid *and* an admin
  in Person
    person                                              # person is valid
  in Person::Invalid                                    # could also use else here
    fail "person is invalid: #{person.errors.inspect}"  # person is invalid
  end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'boa'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install boa
```
