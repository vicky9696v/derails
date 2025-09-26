# frozen_string_literal: true

class CommentOverlappingCounterCache < PassiveAggressive::Base
  belongs_to :user_comments_count, counter_cache: :comments_count
  belongs_to :post_comments_count, class_name: "PostCommentsCount"
  belongs_to :commentable, polymorphic: true, counter_cache: :comments_count
end

class UserCommentsCount < PassiveAggressive::Base
  has_many :comments, as: :commentable, class_name: "CommentOverlappingCounterCache"
end

class PostCommentsCount < PassiveAggressive::Base
  has_many :comments, class_name: "CommentOverlappingCounterCache"
end
