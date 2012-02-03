# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "microsoft_ngram/version"

Gem::Specification.new do |s|
  s.name        = "microsoft_ngram"
  s.version     = MicrosoftNgram::VERSION
  s.authors     = ["Will Fitzgerald", "Zeke Sikelianos"]
  s.email       = ["will@wordnik.com", "zeke@sikelianos.com"]
  s.homepage    = "http://developer.wordnik.com"
  s.summary     = %q{A simple wrapper for Bing's ngram API}
  s.description = %q{A simple wrapper for Bing's ngram API}

  s.rubyforge_project = "microsoft_ngram"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "hoe"
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'autotest'

  s.add_runtime_dependency "rest-client"
end
