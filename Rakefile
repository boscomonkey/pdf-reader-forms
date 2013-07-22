# encoding: utf-8

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

desc "Run all RSpec test examples"
task :spec do
  RSpec::Core::RakeTask.new do |spec|
    spec.rspec_opts = ["-c", "-f progress"]
    spec.pattern = 'spec/**/*_spec.rb'
  end
end

desc "Generate sample PDFs for tests"
task :make_pdf_samples do |t|
  require Pathname.new(File.dirname(__FILE__)).join('spec','support','pdf_samples_helper')
  include PdfSamplesHelper
  make_pdf_samples
end

desc "Push the Gem"
task :publish do
  fail "Does not look like the Version file is updated!" unless `git status -s`.split("\n").include?(" M pdf-reader-forms.gemspec")
  tag = Gem::Specification.version
  system "git checkout master"
  system "git add -A"
  system "git commit -m 'Version Bump of Gem to version #{tag}'"
  system "git tag -a v" + tag
  system "git push github master --tags"
  system "git push wsl master --tags"
  system "rake install"
  system "gem push pkg/pdf-reader-forms-#{tag}.gem"
end

task :default => :spec