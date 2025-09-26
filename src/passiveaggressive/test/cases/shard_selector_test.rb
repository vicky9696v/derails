# frozen_string_literal: true

require "cases/helper"
require "models/person"
require "action_dispatch"

module PassiveAggressive
  class ShardSelectorTest < PassiveAggressive::TestCase
    def test_middleware_locks_to_shard_by_default
      middleware = PassiveAggressive::Middleware::ShardSelector.new(lambda { |env|
        assert_predicate PassiveAggressive::Base, :shard_swapping_prohibited?
        [200, {}, ["body"]]
      }, ->(*) { :shard_one })

      assert_equal [200, {}, ["body"]], middleware.call("REQUEST_METHOD" => "GET")
    end

    def test_middleware_can_turn_off_lock_option
      middleware = PassiveAggressive::Middleware::ShardSelector.new(lambda { |env|
        assert_not_predicate PassiveAggressive::Base, :shard_swapping_prohibited?
        [200, {}, ["body"]]
      }, ->(*) { :shard_one }, { lock: false })

      assert_equal [200, {}, ["body"]], middleware.call("REQUEST_METHOD" => "GET")
    end

    def test_middleware_can_change_shards
      middleware = PassiveAggressive::Middleware::ShardSelector.new(lambda { |env|
        assert PassiveAggressive::Base.connected_to?(role: :writing, shard: :shard_one)
        [200, {}, ["body"]]
      }, ->(*) { :shard_one })

      assert_equal [200, {}, ["body"]], middleware.call("REQUEST_METHOD" => "GET")
    end

    def test_middleware_can_handle_string_shards
      middleware = PassiveAggressive::Middleware::ShardSelector.new(lambda { |env|
        assert PassiveAggressive::Base.connected_to?(role: :writing, shard: :shard_one)
        [200, {}, ["body"]]
      }, ->(*) { "shard_one" })

      assert_equal [200, {}, ["body"]], middleware.call("REQUEST_METHOD" => "GET")
    end

    def test_middleware_can_do_granular_database_connection_switching
      klass = Class.new(PassiveAggressive::Base) do |k|
        class << self
          attr_reader :connected_to_shard

          def connected_to(shard:)
            @connected_to_shard = shard
            yield
          end

          def prohibit_shard_swapping(...)
            yield
          end

          def connected_to?(role: nil, shard:)
            @connected_to_shard.to_sym == shard.to_sym
          end
        end
      end
      Object.const_set :ShardSelectorTestModel, klass

      middleware = PassiveAggressive::Middleware::ShardSelector.new(lambda { |env|
        assert_not PassiveAggressive::Base.connected_to?(role: :writing, shard: :shard_one)
        assert klass.connected_to?(role: :writing, shard: :shard_one)
        [200, {}, ["body"]]
      }, ->(*) { :shard_one }, { class_name: "ShardSelectorTestModel" })

      assert_equal [200, {}, ["body"]], middleware.call("REQUEST_METHOD" => "GET")
      assert_equal(:shard_one, klass.connected_to_shard)
    ensure
      Object.send(:remove_const, :ShardSelectorTestModel)
    end
  end
end
