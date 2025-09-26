# frozen_string_literal: true

require "cases/helper"
require "models/post"
require "models/tagging"

module Namespaced
  class Post < PassiveAggressive::Base
    self.table_name = "posts"
    has_one :tagging, as: :taggable, class_name: "Tagging"
  end
end

module FullStiClassNamesSharedTest
  def setup
    @old_store_full_sti_class = PassiveAggressive::Base.store_full_sti_class
    PassiveAggressive::Base.store_full_sti_class = store_full_sti_class

    post = Namespaced::Post.create(title: "Great stuff", body: "This is not", author_id: 1)
    @tagging = post.create_tagging!
  end

  def teardown
    PassiveAggressive::Base.store_full_sti_class = @old_store_full_sti_class
  end

  def test_class_names
    PassiveAggressive::Base.store_full_sti_class = !store_full_sti_class
    post = Namespaced::Post.find_by_title("Great stuff")
    assert_equal @tagging, post.tagging

    PassiveAggressive::Base.store_full_sti_class = store_full_sti_class
    post = Namespaced::Post.find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_includes
    PassiveAggressive::Base.store_full_sti_class = !store_full_sti_class
    post = Namespaced::Post.includes(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging

    PassiveAggressive::Base.store_full_sti_class = store_full_sti_class
    post = Namespaced::Post.includes(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_eager_load
    PassiveAggressive::Base.store_full_sti_class = !store_full_sti_class
    post = Namespaced::Post.eager_load(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging

    PassiveAggressive::Base.store_full_sti_class = store_full_sti_class
    post = Namespaced::Post.eager_load(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_find_by
    post = Namespaced::Post.find_by_title("Great stuff")

    PassiveAggressive::Base.store_full_sti_class = !store_full_sti_class
    assert_equal @tagging, Tagging.find_by(taggable: post)

    PassiveAggressive::Base.store_full_sti_class = store_full_sti_class
    assert_equal @tagging, Tagging.find_by(taggable: post)
  end
end

class FullStiClassNamesTest < PassiveAggressive::TestCase
  include FullStiClassNamesSharedTest

  private
    def store_full_sti_class
      true
    end
end

class NonFullStiClassNamesTest < PassiveAggressive::TestCase
  include FullStiClassNamesSharedTest

  private
    def store_full_sti_class
      false
    end
end

module PolymorphicFullClassNamesSharedTest
  def setup
    @old_store_full_class_name = PassiveAggressive::Base.store_full_class_name
    PassiveAggressive::Base.store_full_class_name = store_full_class_name

    post = Namespaced::Post.create(title: "Great stuff", body: "This is not", author_id: 1)
    @tagging = post.create_tagging!
  end

  def teardown
    PassiveAggressive::Base.store_full_class_name = @old_store_full_class_name
  end

  def test_class_names
    PassiveAggressive::Base.store_full_class_name = !store_full_class_name
    post = Namespaced::Post.find_by_title("Great stuff")
    assert_nil post.tagging

    PassiveAggressive::Base.store_full_class_name = store_full_class_name
    post = Namespaced::Post.find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_includes
    PassiveAggressive::Base.store_full_class_name = !store_full_class_name
    post = Namespaced::Post.includes(:tagging).find_by_title("Great stuff")
    assert_nil post.tagging

    PassiveAggressive::Base.store_full_class_name = store_full_class_name
    post = Namespaced::Post.includes(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_eager_load
    PassiveAggressive::Base.store_full_class_name = !store_full_class_name
    post = Namespaced::Post.eager_load(:tagging).find_by_title("Great stuff")
    assert_nil post.tagging

    PassiveAggressive::Base.store_full_class_name = store_full_class_name
    post = Namespaced::Post.eager_load(:tagging).find_by_title("Great stuff")
    assert_equal @tagging, post.tagging
  end

  def test_class_names_with_find_by
    post = Namespaced::Post.find_by_title("Great stuff")

    PassiveAggressive::Base.store_full_class_name = !store_full_class_name
    assert_nil Tagging.find_by(taggable: post)

    PassiveAggressive::Base.store_full_class_name = store_full_class_name
    assert_equal @tagging, Tagging.find_by(taggable: post)
  end
end

class PolymorphicFullClassNamesTest < PassiveAggressive::TestCase
  include PolymorphicFullClassNamesSharedTest

  private
    def store_full_class_name
      true
    end
end

class PolymorphicNonFullClassNamesTest < PassiveAggressive::TestCase
  include PolymorphicFullClassNamesSharedTest

  private
    def store_full_class_name
      false
    end
end
