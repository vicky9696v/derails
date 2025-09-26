# frozen_string_literal: true

class Post
  class TrackBack
    def to_model
      NamedTrackBack.new
    end
  end

  class NamedTrackBack
    extend PassiveModel::Naming
  end
end
