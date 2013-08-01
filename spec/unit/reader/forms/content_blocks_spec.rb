require 'spec_helper'
include PdfFormsHelper

describe PDF::Reader::Forms::ContentBlocks do
  let(:resource_module) { PDF::Reader::Forms::ContentBlocks }
  let(:forms_reader) { PDF::Reader::Forms.new(source, options) }
  let(:options) { {} }
  let(:page) { 1 }

  describe "should Find the Blocks of Content" do
    # describe "determine #mean_font_size (#mfs)" do
    #   {
    #     'first_form.pdf' => 9.616902616902617,
    #     'second_form.pdf' => 9.616902616902617,
    #     'third_form.pdf' => 10.107190082644626
    #   }.each do |forms_file,expected_mean_font_size|
    #     context "Mean Font Size for #{forms_file}" do
    #       let(:source) { pdf_forms(forms_file) }
    #       subject { forms_reader.mfs(page) }
    #       it { should eql(expected_mean_font_size) }
    #     end
    #   end
    # end

    # describe "determine #mean_row_height (#mrh)" do
    #   {
    #     'first_form.pdf' => 12.666924999999996,
    #     'second_form.pdf' => 12.666928571428574,
    #     'third_form.pdf' => 12.82786086956522
    #   }.each do |forms_file,expected_mean_row_height|
    #     context "Mean Row Height for #{forms_file}" do
    #       let(:options) { { :y_precision => 20 } }
    #       let(:source) { pdf_forms(forms_file) }
    #       subject { forms_reader.mrh(page) }
    #       it { should eql(expected_mean_row_height) }
    #     end
    #   end
    # end
  end
end