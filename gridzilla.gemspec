# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gridzilla/version"

Gem::Specification.new do |s|
  s.name        = %q{gridzilla}
  s.version     = Gridzilla::VERSION
  s.authors     = ["Anthony Crumley, Mike Heiztke, Josh Moore, Andrew Sellers"]
  s.email       = %q{tech@gradesfirst.com}
  s.homepage    = %q{https://github.com/Thoughtwright-LLC/gridzilla}
  s.summary     = %q{Grid based solution with action buttons}
  #s.description = %q{Example of creating a Ruby gem for ASCIIcast #301}
  s.test_files  = [
    "test/test_helper.rb",
    "test/gridzilla_test.rb"
  ]

  s.rubyforge_project = "gridzilla"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency %q<actionpack>

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "rdoc"
end
