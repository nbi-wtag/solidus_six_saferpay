# begin
#   require 'bundler/setup'
# rescue LoadError
#   puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
# end

# require 'rdoc/task'

# RDoc::Task.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'SolidusSixSaferpay'
#   rdoc.options << '--line-numbers'
#   rdoc.rdoc_files.include('README.md')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end

# APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
# load 'rails/tasks/engine.rake'

# load 'rails/tasks/statistics.rake'

# require 'bundler/gem_tasks'

# require 'rspec/core/rake_task'
# RSpec::Core::RakeTask.new(:spec)

# task default: :spec

require 'bundler'

Bundler::GemHelper.install_tasks

begin
  require 'spree/testing_support/extension_rake'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  # task default: %i(first_run spec)
  task default: %i(first_run spec)
rescue LoadError
  # no rspec available
end

task :first_run do
  if Dir['spec/dummy'].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir('../../')
  end
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'solidus_six_saferpay'
  Rake::Task['extension:test_app'].invoke
end
