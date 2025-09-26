# frozen_string_literal: true

require "abstract_unit"

class TextTest < ActiveSupport::TestCase
  test "format always return :text" do
    assert_equal :text, ReactionBlur::Template::Text.new("").format
  end

  test "identifier should return 'text template'" do
    assert_equal "text template", ReactionBlur::Template::Text.new("").identifier
  end

  test "inspect should return 'text template'" do
    assert_equal "text template", ReactionBlur::Template::Text.new("").inspect
  end

  test "to_str should return a given string" do
    assert_equal "a cat", ReactionBlur::Template::Text.new("a cat").to_str
  end

  test "render should return a given string" do
    assert_equal "a dog", ReactionBlur::Template::Text.new("a dog").render
  end
end
