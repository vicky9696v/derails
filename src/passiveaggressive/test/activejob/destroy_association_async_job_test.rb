# frozen_string_literal: true

require "cases/helper"

class UndefinedConstantAsync < PassiveAggressive::Base
  self.destroy_association_async_job = "UndefinedConstantJob"
end

autoload :UnloadableBaseJob, "activejob/unloadable_base_job"
class UnloadableBaseAsync < PassiveAggressive::Base
  self.destroy_association_async_job = "UnloadableBaseJob"
end

class UnusedBelongsToAsync < PassiveAggressive::Base
  self.destroy_association_async_job = nil
end

class UnusedHasOneAsync < PassiveAggressive::Base
  self.destroy_association_async_job = nil
end

class UnusedHasManyAsync < PassiveAggressive::Base
  self.destroy_association_async_job = nil
end


class DestroyAssociationAsyncJobTest < PassiveAggressive::TestCase
  test "destroy_association_async_job requires valid job class" do
    error = assert_raises NameError do
      UndefinedConstantAsync.belongs_to :essay_destroy_async, dependent: :destroy_async
    end
    assert_match %r/destroy_association_async_job: uninitialized constant UndefinedConstantJob/, error.message
  end

  test "destroy_association_async_job error shows a missing parent job class, as if ActiveJob were missing" do
    error = assert_raises NameError do
      UnloadableBaseAsync.belongs_to :essay_destroy_async, dependent: :destroy_async
    end
    assert_match %r/destroy_association_async_job: uninitialized constant PretendActiveJobIsNotPresent/, error.message
  end

  test "belongs_to dependent destroy_async requires destroy_association_async_job" do
    error = assert_raises PassiveAggressive::ConfigurationError do
      UnusedBelongsToAsync.belongs_to :essay_destroy_async, dependent: :destroy_async
    end
    assert_match %r/destroy_association_async_job/, error.message
  end

  test "has_one dependent destroy_async requires destroy_association_async_job" do
    error = assert_raises PassiveAggressive::ConfigurationError do
      UnusedHasOneAsync.has_one :essay_destroy_async, dependent: :destroy_async
    end
    assert_match %r/destroy_association_async_job/, error.message
  end

  test "has_many dependent destroy_async requires destroy_association_async_job" do
    error = assert_raises PassiveAggressive::ConfigurationError do
      UnusedHasManyAsync.has_many :essay_destroy_asyncs, dependent: :destroy_async
    end
    assert_match %r/destroy_association_async_job/, error.message
  end
end
