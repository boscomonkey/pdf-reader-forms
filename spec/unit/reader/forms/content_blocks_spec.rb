require 'spec_helper'
include PdfFormsHelper

describe PDF::Reader::Forms::ContentBlocks do
  let(:resource_module) { PDF::Reader::Forms::ContentBlocks }
  let(:forms_reader) { PDF::Reader::Forms.new(source, options) }
  let(:options) { {} }
  let(:page) { 1 }

  describe "should Find the Content and Positions Correctly" do
    context "with Mocked Resources" do
      let(:source) { nil }
      before do
        forms_reader.should_receive(:load_content).with(page).and_return(given_page_content)
      end

      {
        :with_simple_text => {
          :source_page_content => {10.0=>{10.0=>[160.0,"a first bit of text"]}},
          :expected_precise_content => {10.0=>{10.0=>[160.0,"a first bit of text"]}},
          :expected_fuzzed_content => [[10.0,[[10.0,160.0,"a first bit of text"]]]]
        },
        :with_widely_separated_text => {
          :source_page_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},10.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_precise_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},10.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_fuzzed_content => [[20.0, [[10.0,160.0,"a first bit of text"]]], [10.0, [[20.0,175.0,"a second bit of text"]]]]
        },
        :with_unsorted_y_text => {
          :source_page_content => {10.0=>{10.0=>[160.0,"a first bit of text"]},20.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_precise_content => {10.0=>{10.0=>[160.0,"a first bit of text"]},20.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_fuzzed_content => [[20.0, [[20.0, 175.0, "a second bit of text"]]], [10.0, [[10.0, 160.0, "a first bit of text"]]]]
        },
        :with_fuzzed_y_text => {
          :source_page_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},18.0=>{12.0=>[150.0,"a second bit of text"]}},
          :expected_precise_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},18.0=>{12.0=>[150.0,"a second bit of text"]}},
          :expected_fuzzed_content => [[20.0, [[10.0, 160.0, "a first bit of text"], [12.0, 150.0, "a second bit of text"]]]]
        },
        :with_widely_separated_fuzzed_y_text => {
          :y_precision => 25,
          :source_page_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},10.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_precise_content => {20.0=>{10.0=>[160.0,"a first bit of text"]},10.0=>{20.0=>[175.0,"a second bit of text"]}},
          :expected_fuzzed_content => [[20.0, [[10.0, 160.0, "a first bit of text"], [20.0, 175.0, "a second bit of text"]]]]
        },
        :with_multiple_row_text => {
          :source_page_content => {10.0=>{10.0=>[50.0,"first"]},8.0=>{60.0=>[100.0,"second"],150.0=>[190.0,"third"]}},
          :expected_precise_content => {10.0=>{10.0=>[50.0,"first"]},8.0=>{60.0=>[100.0,"second"],150.0=>[190.0,"third"]}},
          :expected_fuzzed_content => [[10.0, [[10.0, 50.0, "first"], [60.0, 100.0, "second"], [150.0, 190.0, "third"]]]]
        },
        :with_unsorted_x_text => {
          :source_page_content => {10.0=>{200.0=>[240.0,"fourth"],150.0=>[190.0,"third"],10.0=>[50.0,"first"],60.0=>[90.0,"second"]}},
          :expected_precise_content => {10.0=>{200.0=>[240.0,"fourth"],150.0=>[190.0,"third"],10.0=>[50.0,"first"],60.0=>[90.0,"second"]}},
          :expected_fuzzed_content => [[10.0, [[10.0,50.0,"first"], [60.0,90.0,"second"], [150.0, 190.0, "third"], [200.0, 240.0, "fourth"]]]]
        }
      }.each do |test_name,test_expectations|
        context test_name do
          let(:given_page_content) { test_expectations[:source_page_content] }
          let(:options) {
            if (y_precision = test_expectations[:y_precision]) && y_precision != :default
              { :y_precision => y_precision }
            else
              {}
            end
          }
          describe "#content for Mocked Resources" do
            subject { forms_reader.content(page) }
            it { should eql(test_expectations[:expected_fuzzed_content]) }
          end
          describe "#precise_content for Mocked Resources" do
            subject { forms_reader.precise_content(page) }
            it { should eql(test_expectations[:expected_precise_content]) }
          end
        end
      end

      context "with PDF Forms" do
        pdf_forms_blocks_expectations.each do |forms_file,expectations|
          context "#precise_content for #{forms_file}" do
            let(:source) { pdf_forms(forms_file) }
            subject { forms_reader.content(1) }
            it { should eql(expectations[:test_precise_content])}
          end
        end
      end
    end
  end

  describe "should Find the Blocks of Content" do
    describe "determine #mean_font_size (#mfs)" do
      {
        'first_form.pdf' => 9.616902616902617,
        'second_form.pdf' => 9.616902616902617,
        'third_form.pdf' => 10.107190082644626
      }.each do |forms_file,expected_mean_font_size|
        context "Mean Font Size for #{forms_file}" do
          let(:source) { pdf_forms(forms_file) }
          subject { forms_reader.mfs(page) }
          it { should eql(expected_mean_font_size) }
        end
      end
    end

    describe "determine #mean_row_height (#mrh)" do
      {
        'first_form.pdf' => 12.666924999999996,
        'second_form.pdf' => 12.666928571428574,
        'third_form.pdf' => 12.82786086956522
      }.each do |forms_file,expected_mean_row_height|
        context "Mean Row Height for #{forms_file}" do
          let(:options) { { :y_precision => 20 } }
          let(:source) { pdf_forms(forms_file) }
          subject { forms_reader.mrh(page) }
          it { should eql(expected_mean_row_height) }
        end
      end
    end
  end
end