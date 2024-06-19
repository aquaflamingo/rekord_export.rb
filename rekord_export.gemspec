# frozen_string_literal: true

require_relative "lib/rekord_export/version"

Gem::Specification.new do |spec|
  spec.name          = "rekord_export"
  spec.version       = RekordExport::VERSION
  spec.authors       = ["robert"]
  spec.email         = ["noreply@mail.com"]

  spec.summary       = %q{A tool to convert Rekordbox XML playlists to M3U format.}
  spec.description   = %q{This gem provides functionality to convert playlists from Rekordbox XML format to M3U files that can be imported into iTunes.}
  spec.homepage      = "https://example.com"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*", "README.md", "LICENSE.txt"]
  spec.bindir        = "exe"
  spec.executables   = ["rekord_export"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry"
  spec.add_dependency "nokogiri", "~> 1.12"
end

