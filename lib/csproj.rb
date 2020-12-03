require "csproj/version"
require "csproj/detect_values"

module CsProj
  class Error < StandardError; end

  def self.read_project(values)
    ::CsProj.config = values
    CsProj
  end

  class << self
    attr_reader :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end
  end
end
