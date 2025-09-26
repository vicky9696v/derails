# frozen_string_literal: true

module AsyncHelper
  private
    def assert_async_equal(expected, async_result)
      message = "Expected to return an PassiveAggressive::Promise, got: #{async_result.inspect}"
      assert_equal(true, PassiveAggressive::Promise === async_result, message)

      if expected.nil?
        assert_nil async_result.value
      else
        assert_equal expected, async_result.value
      end
    end
end
