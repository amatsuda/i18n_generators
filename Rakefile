require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
# require 'spec/rake/spectask'

desc 'Default: run the specs.'
task :default => :spec

# desc 'Run the specs for i18n_generators.'
# Spec::Rake::SpecTask.new(:spec) do |t|
#   t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
#   t.spec_files = FileList['spec/**/*_spec.rb']
# end

desc 'Generate documentation for the i18n_generators plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'I18nGenerators'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('generators/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'i18n_generators'
    gemspec.summary = 'Generates I18n locale files for Rails 2.2 and 2.3'
    gemspec.description = 'A Rails generator plugin & gem that generates Rails 2.2 and 2.3 I18n locale files for almost every known locale.'
    gemspec.email = 'ronnie@dio.jp'
    gemspec.homepage = 'http://github.com/amatsuda/i18n_generators/'
    gemspec.authors = ['Akira Matsuda']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: gem install jeweler'
end
