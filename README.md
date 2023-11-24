# Boa - The Smart Constructor

This is a work in progress. It is not ready for production use.

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

## Usage

```ruby
class Person
  include Boa

  prop :id,    UUID,                    key: true           # required by default
  prop :name,  String, required: true,  length: 1..50
  prop :email, Email,  required: false, key: :unique_email
  prop :admin, Boolean                  default: false

  prop :birth_date, Date, required: false do
    # Checks the value is within range
    includes Date.new(1900)..Date.today
  end

  # creates nested Person::Address Boa class
  prop :address, Object, required: false do
    prop :street_address, String, length: 1..100
    prop :city,           String, length: 1..50
    prop :state,          String, in: STATE_CODES   # alpha2 subdivision codes
    prop :country,        String, in: COUNTRY_CODES # alpha2 country codes
    prop :postal_code,    String, length: 1..20
  end

  # same as:
  # prop :created_at, DateTime, default: -> { DateTime.now }, private: true, required: true
  prop :created_at, DateTime do
    # override the initializer to set the default, or normalization
    def initialize(created_at)
      fail Private.new(:created_at), 'must not be set' if created_at
      super(DateTime.now)
    end

    # can even override .new to return different object types based on input
  end
end

# Person instance is immutable (deep frozen) when Boa is used
# Boa::Mutable allow for mutable instances

# Person.new actually does a few things:
# - Constructs the data using the *real* constructor
# - Validates the object
# - If valid it returns a Person
# - If invalid it returns a Person::Invalid that wraps the Person, containing
#   all the errors for the Person. Use with Ruby 3 case pattern matching.
person = Person.new(id: id, name: 'Dan Kubb', email: 'github@dan.kubb.ca')

# Expected accessor usage
puts person.created_at  # => returns DateTime.now
puts person.email       # => returns an Email object (or nil when no email is provided)

# no mutators unless marked as writeable
person.email = 'new@example.com'  # raises a NoMethod error!

# Person#valid? is always true
# Person::Invalid#valid? is always false
puts person.valid?

# Person#errors always returns a Person::ErrorSet::Empty object   (always empty)
# Person::Invalid#errors always returns a Person::ErrorSet object (always non-empty)
#  - provides #[] to return the ordered set of errors by attribute name
#  - each error is an error object that contains enough information to display an error to the user
puts person.errors

# Ruby 3 case pattern matching
valid_person =
  case person
  in Person if person.admin?
    person                                              # person is valid *and* an admin
  in Person
    person                                              # person is valid
  in Person::Invalid                                    # could also use else here
    fail "person is invalid: #{person.errors.inspect}"  # person is invalid
  end
```
