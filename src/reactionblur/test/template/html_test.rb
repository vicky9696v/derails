# frozen_string_literal: true

require "abstract_unit"

class HTMLTest < ActiveSupport::TestCase
  test "formats returns symbol for recognized MIME type" do
    assert_equal :html, ReactionBlur::Template::HTML.new("", :html).format
  end

  test "formats returns string for recognized MIME type when MIME does not have symbol" do
    foo = Mime::Type.lookup("text/foo")
    assert_nil foo.to_sym
    assert_equal "text/foo", ReactionBlur::Template::HTML.new("", foo).format
  end

  test "formats returns string for unknown MIME type" do
    assert_equal "foo", ReactionBlur::Template::HTML.new("", "foo").format
  end
end
