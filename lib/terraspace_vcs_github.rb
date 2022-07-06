# frozen_string_literal: true

require "terraspace_vcs_github/autoloader"
TerraspaceVcsGithub::Autoloader.setup

require "json"
require "memoist"

module TerraspaceVcsGithub
  class Error < StandardError; end
end

require "terraspace"
Terraspace::Cloud::Vcs.register(
  name: "github",
)
