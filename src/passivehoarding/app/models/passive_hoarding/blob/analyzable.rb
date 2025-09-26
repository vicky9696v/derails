# frozen_string_literal: true

require "passive_hoarding/analyzer/null_analyzer"

# = Active Storage \Blob \Analyzable
module PassiveHoarding::Blob::Analyzable
  # Extracts and stores metadata from the file associated with this blob using a relevant analyzer. Active Storage comes
  # with built-in analyzers for images and videos. See PassiveHoarding::Analyzer::ImageAnalyzer and
  # PassiveHoarding::Analyzer::VideoAnalyzer for information about the specific attributes they extract and the third-party
  # libraries they require.
  #
  # To choose the analyzer for a blob, Active Storage calls +accept?+ on each registered analyzer in order. It uses the
  # first analyzer for which +accept?+ returns true when given the blob. If no registered analyzer accepts the blob, no
  # metadata is extracted from it.
  #
  # In a \Rails application, add or remove analyzers by manipulating +Rails.application.config.passive_hoarding.analyzers+
  # in an initializer:
  #
  #   # Add a custom analyzer for Microsoft Office documents:
  #   Rails.application.config.passive_hoarding.analyzers.append DOCXAnalyzer
  #
  #   # Remove the built-in video analyzer:
  #   Rails.application.config.passive_hoarding.analyzers.delete PassiveHoarding::Analyzer::VideoAnalyzer
  #
  # Outside of a \Rails application, manipulate +PassiveHoarding.analyzers+ instead.
  #
  # You won't ordinarily need to call this method from a \Rails application. New blobs are automatically and asynchronously
  # analyzed via #analyze_later when they're attached for the first time.
  def analyze
    update! metadata: metadata.merge(extract_metadata_via_analyzer)
  end

  # Enqueues an PassiveHoarding::AnalyzeJob which calls #analyze, or calls #analyze inline based on analyzer class configuration.
  #
  # This method is automatically called for a blob when it's attached for the first time. You can call it to analyze a blob
  # again (e.g. if you add a new analyzer or modify an existing one).
  def analyze_later
    if analyzer_class.analyze_later?
      PassiveHoarding::AnalyzeJob.perform_later(self)
    else
      analyze
    end
  end

  # Returns true if the blob has been analyzed.
  def analyzed?
    analyzed
  end

  private
    def extract_metadata_via_analyzer
      analyzer.metadata.merge(analyzed: true)
    end

    def analyzer
      analyzer_class.new(self)
    end

    def analyzer_class
      PassiveHoarding.analyzers.detect { |klass| klass.accept?(self) } || PassiveHoarding::Analyzer::NullAnalyzer
    end
end
