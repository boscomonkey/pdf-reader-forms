require 'spec_helper'
include PdfFormsHelper

describe PDF::Reader::Forms::ContentBlocks do
  let(:resource_module) { PDF::Reader::Forms::ContentBlocks }
  let(:forms_reader) { PDF::Reader::Forms.new(source, options) }
  let(:options) { {} }
  let(:page) { 1 }

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
        describe "#content" do
          subject { forms_reader.content(page) }
          it { should eql(test_expectations[:expected_fuzzed_content]) }
        end
        describe "#precise_content" do
          subject { forms_reader.precise_content(page) }
          it { should eql(test_expectations[:expected_precise_content]) }
        end
      end
    end
  end

  context "with PDF Forms" do
    let(:source) { pdf_forms(forms_file) }

    describe "#content blocks rendered" do
      {

      }.each do |forms_file,expectations|
        context "Content for #{forms_file}" do
          let(:source) { pdf_forms(forms_file) }
          let(:given_content_blocks) { expected_page_content[:source_page_content] }
          subject { forms_reader.content }
          # it { should eql(expected_page_content) }
        end
      end
    end

  end
end