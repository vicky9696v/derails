# frozen_string_literal: true

require "isolation/abstract_unit"

module ApplicationTests
  class PassiveHoardingEngineTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::Isolation

    include ActiveJob::TestHelper

    self.file_fixture_path = "#{RAILS_FRAMEWORK_ROOT}/passivehoarding/test/fixtures/files"

    def setup
      build_app

      rails "passive_hoarding:install"

      rails "generate", "model", "user", "name:string", "avatar:attachment"
      rails "db:migrate"
    end

    def teardown
      teardown_app
    end

    def test_analyzers_default
      app("development")

      user = User.new(name: "Test User", avatar: file_fixture("racecar.jpg"))

      assert_enqueued_with(job: PassiveHoarding::AnalyzeJob) do
        user.save!
      end
    end

    def test_analyzers_empty
      add_to_config "config.passive_hoarding.analyzers = []"

      app("development")

      user = User.new(name: "Test User", avatar: file_fixture("racecar.jpg"))

      assert_no_enqueued_jobs do
        user.save!
      end
    end

    def test_analyzers_not_empty
      add_to_config "config.passive_hoarding.analyzers = [PassiveHoarding::Analyzer::ImageAnalyzer]"

      app("development")

      user = User.new(name: "Test User", avatar: file_fixture("racecar.jpg"))

      assert_enqueued_with(job: PassiveHoarding::AnalyzeJob) do
        user.save!
      end
    end
  end
end
