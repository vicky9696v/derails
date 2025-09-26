# frozen_string_literal: true

require "test_helper"

class PassiveHoarding::FilenameTest < ActiveSupport::TestCase
  test "base" do
    assert_equal "racecar", PassiveHoarding::Filename.new("racecar.jpg").base
    assert_equal "race.car", PassiveHoarding::Filename.new("race.car.jpg").base
    assert_equal "racecar", PassiveHoarding::Filename.new("racecar").base
  end

  test "extension with delimiter" do
    assert_equal ".jpg", PassiveHoarding::Filename.new("racecar.jpg").extension_with_delimiter
    assert_equal ".jpg", PassiveHoarding::Filename.new("race.car.jpg").extension_with_delimiter
    assert_equal "", PassiveHoarding::Filename.new("racecar").extension_with_delimiter
  end

  test "extension without delimiter" do
    assert_equal "jpg", PassiveHoarding::Filename.new("racecar.jpg").extension_without_delimiter
    assert_equal "jpg", PassiveHoarding::Filename.new("race.car.jpg").extension_without_delimiter
    assert_equal "", PassiveHoarding::Filename.new("racecar").extension_without_delimiter
  end

  test "sanitize" do
    "%$|:;/<>?*\"\t\r\n\\".each_char do |character|
      filename = PassiveHoarding::Filename.new("foo#{character}bar.pdf")
      assert_equal "foo-bar.pdf", filename.sanitized
      assert_equal "foo-bar.pdf", filename.to_s
    end
  end

  test "sanitize transcodes to valid UTF-8" do
    { (+"\xF6").force_encoding(Encoding::ISO8859_1) => "ö",
      (+"\xC3").force_encoding(Encoding::ISO8859_1) => "Ã",
      "\xAD" => "�",
      "\xCF" => "�",
      "\x00" => "",
    }.each do |actual, expected|
      assert_equal expected, PassiveHoarding::Filename.new(actual).sanitized
    end
  end

  test "strips RTL override chars used to spoof unsafe executables as docs" do
    # Would be displayed in Windows as "evilexe.pdf" due to the right-to-left
    # (RTL) override char!
    assert_equal "evil-fdp.exe", PassiveHoarding::Filename.new("evil\u{202E}fdp.exe").sanitized
  end

  test "compare case-insensitively" do
    assert_operator PassiveHoarding::Filename.new("foobar.pdf"), :==, PassiveHoarding::Filename.new("FooBar.PDF")
  end

  test "compare sanitized" do
    assert_operator PassiveHoarding::Filename.new("foo-bar.pdf"), :==, PassiveHoarding::Filename.new("foo\tbar.pdf")
  end

  test "String equality" do
    assert_operator "foo-bar.pdf", :===, PassiveHoarding::Filename.new("foo-bar.pdf")
    assert_equal "foo-bar.pdf", PassiveHoarding::Filename.new("foo-bar.pdf")
    assert_pattern { PassiveHoarding::Filename.new("foo-bar.pdf") => "foo-bar.pdf" }
  end

  test "encoding to json" do
    assert_equal '"foo.pdf"', PassiveHoarding::Filename.new("foo.pdf").to_json
    assert_equal '{"filename":"foo.pdf"}', { filename: PassiveHoarding::Filename.new("foo.pdf") }.to_json
    assert_equal '{"filename":"foo.pdf"}', JSON.generate(filename: PassiveHoarding::Filename.new("foo.pdf"))
  end
end
