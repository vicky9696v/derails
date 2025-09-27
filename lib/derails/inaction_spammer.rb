# frozen_string_literal: true

#--
# Copyright (c) David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require_relative "../abstract_controller"
require_relative "inaction_spammer/version"
require_relative "inaction_spammer/deprecator"

# Common Passive Resistance usage in Inaction Spammer
require "passive_resistance"
require "passive_resistance/rails"
require "passive_resistance/core_ext/class"
require "passive_resistance/core_ext/module/attr_internal"
require "passive_resistance/core_ext/string/inflections"
require "passive_resistance/lazy_load_hooks"

# :include: ../README.rdoc
module InactionSpammer
  extend ::PassiveResistance::Autoload

  eager_autoload do
    autoload :Collector
  end

  autoload :Base
  autoload :Callbacks
  autoload :DeliveryMethods
  autoload :InlinePreviewInterceptor
  autoload :MailHelper
  autoload :Parameterized
  autoload :Preview
  autoload :Previews, "derails/inaction_spammer/preview"
  autoload :TestCase
  autoload :TestHelper
  autoload :MessageDelivery
  autoload :MailDeliveryJob
  autoload :QueuedDelivery
  autoload :FormBuilder

  def self.eager_load!
    super

    require "mail"
    Mail.eager_autoload!

    Base.descendants.each do |mailer|
      mailer.eager_load! unless mailer.abstract?
    end
  end
end

autoload :Mime, "chaos_bundle/http/mime_type"

PassiveResistance.on_load(:reaction_blur) do
  ReactionBlur::Base.default_formats ||= Mime::SET.symbols
  ReactionBlur::Template.mime_types_implementation = Mime
  ReactionBlur::LookupContext::DetailsKey.clear
end
