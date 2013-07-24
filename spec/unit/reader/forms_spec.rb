require 'spec_helper'
include PdfSamplesHelper

describe PDF::Reader::Forms do
  let(:resource_class) { PDF::Reader::Forms }
  let(:forms_reader) { resource_class.new(source,options) }
  let(:source) { nil } # we're just going to mock the PDF source here
  let(:options) { {} }

  describe "#reader" do
    subject { forms_reader.reader}
    it { should be_a(PDF::Reader) }
  end

  context "with PDF Samples" do

    describe "#initialize" do
      context "New invalid file: not-valid.pdf" do
        let(:source) { pdf_sample( 'not_valid.pdf' ) }
        subject { forms_reader.reader should raise_error PDF::Reader::MalformedPDFError }
      end
    end

    describe "#initialize" do [
        'junk_prefix.pdf', 'hello_world.pdf'
      ].each do | samples_file |
        context "New valid file: #{samples_file}" do
          let(:source) { pdf_sample(samples_file) }
          subject { forms_reader.reader }
          it { should be_a(PDF::Reader) }
        end
      end
    end
  end

  describe "#y_precision" do
    subject { forms_reader.y_precision}
    context "default" do
      it { should eql(3) }
    end
    context "when set with options" do
      let(:expected) { 5 }
      let(:options) { { :y_precision => expected } }
      it { should eql(expected) }
    end
  end
end