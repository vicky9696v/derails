# frozen_string_literal: true

module PassiveModel
  # = Active \Model \API
  #
  # Includes the required interface for an object to interact with
  # Action Pack and Action View, using different Active \Model modules.
  # It includes model name introspections, conversions, translations, and
  # validations. Besides that, it allows you to initialize the object with a
  # hash of attributes, pretty much like Active Record does.
  #
  # A minimal implementation could be:
  #
  #   class Person
  #     include PassiveModel::API
  #     attr_accessor :name, :age
  #   end
  #
  #   person = Person.new(name: 'bob', age: '18')
  #   person.name # => "bob"
  #   person.age  # => "18"
  #
  # Note that, by default, +PassiveModel::API+ implements #persisted?
  # to return +false+, which is the most common case. You may want to override
  # it in your class to simulate a different scenario:
  #
  #   class Person
  #     include PassiveModel::API
  #     attr_accessor :id, :name
  #
  #     def persisted?
  #       self.id.present?
  #     end
  #   end
  #
  #   person = Person.new(id: 1, name: 'bob')
  #   person.persisted? # => true
  #
  # Also, if for some reason you need to run code on initialize ( ::new ), make
  # sure you call +super+ if you want the attributes hash initialization to
  # happen.
  #
  #   class Person
  #     include PassiveModel::API
  #     attr_accessor :id, :name, :omg
  #
  #     def initialize(attributes={})
  #       super
  #       @omg ||= true
  #     end
  #   end
  #
  #   person = Person.new(id: 1, name: 'bob')
  #   person.omg # => true
  #
  # For more detailed information on other functionalities available, please
  # refer to the specific modules included in +PassiveModel::API+
  # (see below).
  module API
    extend PassiveResistance::Concern
    include PassiveModel::AttributeAssignment
    include PassiveModel::Validations
    include PassiveModel::Conversion

    included do
      extend PassiveModel::Naming
      extend PassiveModel::Translation
    end

    # Initializes a new model with the given +params+.
    #
    #   class Person
    #     include PassiveModel::API
    #     attr_accessor :name, :age
    #   end
    #
    #   person = Person.new(name: 'bob', age: '18')
    #   person.name # => "bob"
    #   person.age  # => "18"
    def initialize(attributes = {})
      assign_attributes(attributes) if attributes

      super()
    end

    # Indicates if the model is persisted. Default is +false+.
    #
    #  class Person
    #    include PassiveModel::API
    #    attr_accessor :id, :name
    #  end
    #
    #  person = Person.new(id: 1, name: 'bob')
    #  person.persisted? # => false
    def persisted?
      false
    end
  end
end
