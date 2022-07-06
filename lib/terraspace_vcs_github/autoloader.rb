require "zeitwerk"

module TerraspaceVcsGithub
  class Autoloader
    class Inflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = { version: "VERSION" }
        map[basename.to_sym] || super
      end
    end

    class << self
      def setup
        loader = Zeitwerk::Loader.new
        loader.inflector = Inflector.new
        loader.push_dir(File.dirname(__dir__)) # lib
        loader.log! if ENV["TERRASPACE_VCS_GITHUB_AUTOLOAD_LOG"]
        loader.setup
      end
    end
  end
end

