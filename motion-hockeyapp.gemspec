# -*- encoding: utf-8 -*-

Version = "1.2.0"

Gem::Specification.new do |spec|
  spec.name = 'motion-hockeyapp'
  spec.summary = 'HockeyApp integration for RubyMotion projects'
  spec.description = "motion-hockeyapp allows RubyMotion projects to easily embed the Hockey SDK and be submitted to the HockeyApp platform." 
  spec.author = 'Joe Noon'
  spec.email = 'joenoon@gmail.com'
  spec.homepage = 'http://www.rubymotion.com'
  spec.version = Version

  files = []
  files << 'README.rdoc'
  files << 'LICENSE'
  files.concat(Dir.glob('lib/**/*.rb'))
  spec.files = files
  spec.add_dependency "motion-cocoapods", ">= 1.4.1"
end
