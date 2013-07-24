require 'spec_helper'
include PdfSamplesHelper
include PdfFormsHelper

describe PDF::Reader::PositionOfTextReceiver do
  let(:resource_class) { PDF::Reader::PositionOfTextReceiver }
  let(:reader) { PDF::Reader.new(source) }
  let(:receiver) { resource_class.new }
  let(:options) { test_specifications[:options] || {} }
  let(:page) { 1 }

  context "with invalid or encrypted PDFs" do
    describe '#content' do
      context "New invalid file: not-valid.pdf" do
        let(:source) { pdf_sample( 'encrypted.pdf' ) }
        subject { reader.pages should raise_error PDF::Reader::MalformedPDFError }
        subject { reader.page(page).text should raise_error NoMethodError }
      end
    end
  end

  before do
    reader.page(page).walk(receiver)
  end

  context "with valid Simple PDFs" do
    describe "#content" do
      {
        'junk_prefix.pdf' => {747.384=>{36=>[298.992, "This PDF contains junk before the %-PDF marker"]}},
        'hello_world.pdf' => {747.384=>{36=>[97.824, "Hello World"]}}
      }.each do |sample_file,expected_page_content|
        context "Content for #{sample_file}" do
          let(:source) { pdf_sample(sample_file) }
          subject { receiver.content }
          it { should eql(expected_page_content) }
        end
      end
    end

    describe "#content_blocks_with_sizes" do
      {
        'junk_prefix.pdf' => [[["Helvetica", "Type1", 12.0], "This PDF contains junk before the %-PDF marker"]],
        'hello_world.pdf' => [[["Helvetica", "Type1", 12.0], "Hello World"]]
      }.each do |sample_file,expected_content_blocks|
        context "Content_blocks_with_sizes for #{sample_file}" do
          let(:source) { pdf_sample(sample_file)}
          subject { receiver.content_blocks_with_sizes }
          it { should eql(expected_content_blocks) }
        end
      end
    end
  end

  context "with PDF Forms" do
    describe "#stack_of_fonts" do
      pdf_forms_expectations.each do |forms_file,expectations|
        context "Content for #{forms_file}" do
          let(:source) { pdf_forms(forms_file) }
          subject { receiver.stack_of_fonts }
          it { should eql(expectations[:test_font_stack]) }
        end
      end
    end

    describe "#content_blocks_with_sizes" do
      pdf_forms_expectations.each do |forms_file,expectations|
        context "Content for #{forms_file}" do
          let(:source) { pdf_forms(forms_file) }
          subject { receiver.content_blocks_with_sizes }
          it { should eql(expectations[:test_content_blocks_with_sizes])}
        end
      end
    end
  end
end