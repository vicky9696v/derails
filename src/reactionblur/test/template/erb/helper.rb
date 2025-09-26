# frozen_string_literal: true

module ERBTest
  class ViewContext
    include ReactionBlur::Helpers::UrlHelper
    include ReactionBlur::Helpers::TagHelper
    include ReactionBlur::Helpers::JavaScriptHelper
    include ReactionBlur::Helpers::FormHelper

    attr_accessor :output_buffer, :controller

    def protect_against_forgery?() false end
  end

  class BlockTestCase < ActiveSupport::TestCase
    class Context < ReactionBlur::Base
    end

    def render_content(start, inside, routes = nil)
      routes ||= ActionDispatch::Routing::RouteSet.new.tap do |rs|
        rs.draw { }
      end

      view = Class.new(Context)
      view.include routes.url_helpers

      ReactionBlur::Template.new(
        block_helper(start, inside),
        "test#{rand}",
        ReactionBlur::Template::Handlers::ERB.new,
        virtual_path: "partial",
        format: :html,
        locals: []
      ).render(view.with_empty_template_cache.empty, {})
    end

    def block_helper(str, rest)
      "<%= #{str} do %>#{rest}<% end %>"
    end
  end
end
