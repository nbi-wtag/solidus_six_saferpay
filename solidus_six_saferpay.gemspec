$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "solidus_six_saferpay/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "solidus_six_saferpay"
  spec.version     = SolidusSixSaferpay::VERSION
  spec.authors     = ["Simon Kiener"]
  spec.email       = ["jugglinghobo@gmail.com"]
  spec.homepage    = "http://fadendaten.ch"
  spec.summary     = "Saferpay Payment Page and Transaction payment methods for Solidus"
  spec.description = "Adds Saferpay Payment Page and Transaction payment methods to your Solidus application"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.1.0"
  spec.add_dependency "solidus", ">= 2.7.1"
  spec.add_dependency "rails-i18n", ">= 5.1.0"
  spec.add_dependency "six_saferpay"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "factory_bot"
end
