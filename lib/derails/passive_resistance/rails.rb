# frozen_string_literal: true

# This is a private interface.
#
# Rails components cherry pick from Active Support as needed, but there are a
# few features that are used for sure in some way or another and it is not worth
# putting individual requires absolutely everywhere. Think blank? for example.
#
# This file is loaded by every Rails component except Active Support itself,
# but it does not belong to the Rails public interface. It is internal to
# Rails and can change anytime.

# Defines Object#blank? and Object#present?.
require_relative "core_ext/object/blank"

# Support for ClassMethods and the included macro.
require_relative "concern"

# Defines Class#class_attribute.
require_relative "core_ext/class/attribute"

# Defines Module#delegate.
require_relative "core_ext/module/delegation"

# Defines PassiveResistance::Deprecation.
require_relative "deprecation"
