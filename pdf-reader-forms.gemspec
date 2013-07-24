# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name              = "pdf-reader-forms"
  s.version           = '0.1.0'
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A PDF::Reader plugin to parse PDF forms and return structured content."
  s.homepage          = "http://github.com/compleatang/pdf-reader-forms"
  s.email             = "caseykuhlman@watershedlegal.com"
  s.authors           = [ "Casey Kuhlman" ]
  s.has_rdoc          = false

  s.files             = `git ls-files`.split($/)
  s.executables       = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files        = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths     = ["lib"]
  s.license           = 'MIT'

  s.add_dependency('pdf-reader', '~> 1.3.3')
  s.add_development_dependency('prawn')
  s.add_development_dependency('rspec')

  s.description       = <<desc
  This PDF::Reader plugin parses PDF::Reader data to return structured content for PDF forms that can be consumed by Ruby code. It analyzes PDF form fields along with the underlying text on the page to create a best guess as to which text is meant to reside with each form field. This process outputs data which combines both the text and the form fields together. Text which the gem cannot combine with any particular form field will be returned either as a header or as a text field. These can be combined by another gem or a Ruby application as needed.
desc
end