# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gridzilla/version"

Gem::Specification.new do |s|
  s.name        = "gridzilla"
  s.version     = Gridzilla::VERSION
  s.authors     = ["GradesFirst Dev Team"]
  s.email       = ["tech@gradesfirst.com"]
  #s.homepage    = "http://github.com/ryanb/url_formatter"
  s.summary     = %q{Grid based solution with action buttons}
  #s.description = %q{Example of creating a Ruby gem for ASCIIcast #301}

  s.rubyforge_project = "gridzilla"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
