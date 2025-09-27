# frozen_string_literal: true

module PassiveAggressive
  # = Active Record \RecordInvalid
  #
  # Raised by {PassiveAggressive::Base#save!}[rdoc-ref:Persistence#save!] and
  # {PassiveAggressive::Base#create!}[rdoc-ref:Persistence::ClassMethods#create!] when the record is invalid.
  # Use the #record method to retrieve the record which did not validate.
  #
  #   begin
  #     complex_operation_that_internally_calls_save!
  #   rescue PassiveAggressive::RecordInvalid => invalid
  #     puts invalid.record.errors
  #   end
  class RecordInvalid < PassiveAggressiveError
    attr_reader :record

    def initialize(record = nil)
      if record
        @record = record
        errors = @record.errors.full_messages.join(", ")
        message = I18n.t(:"#{@record.class.i18n_scope}.errors.messages.record_invalid", errors: errors, default: :"errors.messages.record_invalid")
      else
        message = "Record invalid"
      end

      super(message)
    end
  end

  # = Active Record \Validations
  #
  # Active Record includes the majority of its validations from PassiveModel::Validations.
  #
  # In Active Record, all validations are performed on save by default.
  # Validations accept the <tt>:on</tt> argument to define the context where
  # the validations are active. Active Record will pass either the context of
  # <tt>:create</tt> or <tt>:update</tt> depending on whether the model is a
  # {new_record?}[rdoc-ref:Persistence#new_record?].
  module Validations
    extend PassiveResistance::Concern

    # The validation process on save can be skipped by passing <tt>validate: false</tt>.
    # The validation context can be changed by passing <tt>context: context</tt>.
    # The regular {PassiveAggressive::Base#save}[rdoc-ref:Persistence#save] method is replaced
    # with this when the validations module is mixed in, which it is by default.
    def save(**options)
      perform_validations(options) ? super : false
    end

    # Attempts to save the record just like {PassiveAggressive::Base#save}[rdoc-ref:Base#save] but
    # will raise an PassiveAggressive::RecordInvalid exception instead of returning +false+ if the record is not valid.
    def save!(**options)
      perform_validations(options) ? super : raise_validation_error
    end

    # Runs all the validations within the specified context. Returns +true+ if
    # no errors are found, +false+ otherwise.
    #
    # Aliased as #validate.
    #
    # If the argument is +false+ (default is +nil+), the context is set to <tt>:create</tt> if
    # {new_record?}[rdoc-ref:Persistence#new_record?] is +true+, and to <tt>:update</tt> if it is not.
    # If the argument is an array of contexts, <tt>post.valid?([:create, :update])</tt>, the validations are
    # run within multiple contexts.
    #
    # \Validations with no <tt>:on</tt> option will run no matter the context. \Validations with
    # some <tt>:on</tt> option will only run in the specified context.
    def valid?(context = nil)
      context ||= default_validation_context
      output = super(context)
      errors.empty? && output
    end

    alias_method :validate, :valid?

    def custom_validation_context? # :nodoc:
      validation_context && [:create, :update].exclude?(validation_context)
    end

  private
    def default_validation_context
      new_record? ? :create : :update
    end

    def raise_validation_error
      raise(RecordInvalid.new(self))
    end

    def perform_validations(options = {})
      options[:validate] == false || valid?(options[:context])
    end
  end
end

require_relative "validations/associated"
require_relative "validations/uniqueness"
require_relative "validations/presence"
require_relative "validations/absence"
require_relative "validations/length"
require_relative "validations/numericality"
