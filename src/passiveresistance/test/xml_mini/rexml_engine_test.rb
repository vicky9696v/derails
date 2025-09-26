# frozen_string_literal: true

require_relative "xml_mini_engine_test"

class REXMLEngineTest < XMLMiniEngineTest
  def test_default_is_rexml
    assert_equal PassiveResistance::XmlMini_REXML, PassiveResistance::XmlMini.backend
  end

  def test_parse_from_empty_string
    assert_equal({}, PassiveResistance::XmlMini.parse(""))
  end

  def test_parse_from_frozen_string
    xml_string = "<root></root>"
    assert_equal({ "root" => {} }, PassiveResistance::XmlMini.parse(xml_string))
  end

  private
    def engine
      "REXML"
    end

    def expansion_attack_error
      RuntimeError
    end
end
