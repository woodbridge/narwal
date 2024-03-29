# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "narwal/version"

Gem::Specification.new do |s|
  s.name        = "narwal"
  s.version     = Narwal::VERSION
  s.authors     = ["Justin Woodbridge"]
  s.email       = ["jwoodbridge@me.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "narwal"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency ""
  s.add_runtime_dependency "sqlite3-ruby"
  s.add_runtime_dependency "grit"
  s.add_runtime_dependency "terminal-table"
end
