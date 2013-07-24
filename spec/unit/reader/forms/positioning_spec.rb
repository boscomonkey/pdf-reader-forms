require 'spec_helper'

describe PDF::Reader::Forms::Positioning do
  let(:forms_reader) { PDF::Reader::Forms.new(source,options) }
  let(:source) { nil } # we're just going to mock the PDF source here
  let(:options) { {} }

  context 'with Mocked Resources' do
    let(:page) { 1 }
    before do
      forms_reader.should_receive(:load_content).with(page).and_return(given_page_content)
    end

    describe "#text_in_region" do
      {
        :restrictive_with_no_results => {
          :source_page_content => {10.0=>{10.0=>[60.0,"a first bit of text"]}},
          :xmin => 1, :xmax => 5, :ymin => 0, :ymax => 20, :expansive => false,
          :expected_text => []
        },
        :restrictive_with_single_text => {
          :source_page_content => {10.0=>{10.0=>[60.0,"a first bit of text"]}},
          :xmin => 0, :xmax => 100, :ymin => 0, :ymax => 100, :expansive => false,
          :expected_text => [["a first bit of text"]]
        },
        :restrictive_with_single_line_text => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            30.0=>{10.0=>[50.0,"first part found"], 55.0=>[95.0,"last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 0, :xmax => 100, :ymin => 20, :ymax => 50, :expansive => false,
          :expected_text => [["first part found", "last part found"]]
        },
        :restrictive_with_multi_line_text => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            40.0=>{10.0=>[50.0,"first line first part found"], 55.0=>[95.0,"first line last part found"]},
            30.0=>{10.0=>[50.0,"last line first part found"], 55.0=>[95.0,"last line last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 0, :xmax => 100, :ymin => 20, :ymax => 50, :expansive => false,
          :expected_text => [
            ["first line first part found", "first line last part found"],
            ["last line first part found", "last line last part found"]
          ]
        },
        :expansive_with_no_results => {
          :source_page_content => {10.0=>{10.0=>[60.0,"a first bit of text"]}},
          :xmin => 1, :xmax => 5, :ymin => 0, :ymax => 20, :expansive => true,
          :expected_text => []
        },
        :expansive_with_single_text => {
          :source_page_content => {10.0=>{10.0=>[60.0,"a first bit of text"]}},
          :xmin => 15, :xmax => 45, :ymin => 0, :ymax => 20, :expansive => true,
          :expected_text => [["a first bit of text"]]
        },
        :expansive_with_single_line_text => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            30.0=>{10.0=>[50.0,"first part found"], 55.0=>[95.0,"last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 20, :xmax => 75, :ymin => 20, :ymax => 40, :expansive => true,
          :expected_text => [["first part found", "last part found"]]
        },
        :expansive_with_single_line_text_single_line_search => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            30.0=>{10.0=>[50.0,"first part found"], 55.0=>[95.0,"last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 20, :xmax => 75, :ymin => 30, :ymax => 30, :expansive => true,
          :expected_text => [["first part found", "last part found"]]
        },
        :expansive_with_multi_line_text => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            40.0=>{10.0=>[50.0,"first line first part found"], 55.0=>[95.0,"first line last part found"]},
            30.0=>{10.0=>[50.0,"last line first part found"], 55.0=>[95.0,"last line last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 20, :xmax => 75, :ymin => 20, :ymax => 50, :expansive => true,
          :expected_text => [
            ["first line first part found", "first line last part found"],
            ["last line first part found", "last line last part found"]
          ]
        },
        :expansive_with_multi_line_text_no_line_overlap => {
          :source_page_content => {
            70.0=>{10.0=>[60.0,"first line ignored"]},
            40.0=>{10.0=>[50.0,"first line first part found"], 55.0=>[95.0,"first line last part found"]},
            30.0=>{10.0=>[50.0,"last line first part found"], 55.0=>[95.0,"last line last part found"]},
            10.0=>{10.0=>[60.0,"last line ignored"]}
          },
          :xmin => 20, :xmax => 75, :ymin => 30, :ymax => 40, :expansive => true,
          :expected_text => [
            ["first line first part found", "first line last part found"],
            ["last line first part found", "last line last part found"]
          ]
        }
      }.each do |test_name,test_expectations|
        context test_name do
          let(:given_page_content) { test_expectations[:source_page_content] }
          let(:xmin) { test_expectations[:xmin] }
          let(:xmax) { test_expectations[:xmax] }
          let(:ymin) { test_expectations[:ymin] }
          let(:ymax) { test_expectations[:ymax] }
          let(:expansive) { test_expectations[:expansive] }
          let(:expected_text) { test_expectations[:expected_text] }
          subject { forms_reader.text_in_region(xmin,xmax,ymin,ymax,page,expansive) }
          it { should eql(expected_text) }
        end
      end
    end

    describe "#text_position" do
      let(:given_page_content) { {
        70.0=>{10.0=>[60.0,"crunchy bacon"]},
        40.0=>{15.0=>[45.0,"bacon on kimchi noodles"], 55.0=>[95.0,"heaven"]},
        30.0=>{30.0=>[60.0,"turkey bacon"], 75.0=>[100.0,"fraud"]},
        10.0=>{40.0=>[100.0,"smoked and streaky da bomb"]}
      } }
      {
        :with_no_match => { :match_term => 'bertie beetle', :expected_position => nil },
        :with_simple_match => { :match_term => 'turkey bacon', :expected_position => [{:xstart=>30.0, :xstop=>60.0, :y=>30.0, :result=>"turkey bacon"}] },
        :with_match_along_line => { :match_term => 'heaven', :expected_position => [{:xstart=>55.0, :xstop=>95.0, :y=>40.0, :result=>"heaven"}] },
        :with_regex_match => { :match_term => /kimchi/, :expected_position => [{:xstart=>15.0, :xstop=> 45.0, :y=>40.0, :result=>"bacon on kimchi noodles"}] },
        :with_regex_multi_matches_first => { :match_term => /turkey|crunchy/, :expected_position => [{:xstart=>10.0, :xstop=>60.0, :y=>70.0, :result=>"crunchy bacon"}, {:xstart=>30.0, :xstop=>60.0, :y=>30.0, :result=>"turkey bacon"}] },
        :with_multiple_string_matches => { :match_term => 'bacon', :expected_position => [{:xstart=>10.0, :xstop=>60.0, :y=>70.0, :result=>"crunchy bacon"}, {:xstart=>15.0, :xstop=>45.0, :y=>40.0, :result=>"bacon on kimchi noodles"}, {:xstart=>30.0, :xstop=>60.0, :y=>30.0, :result=>"turkey bacon"}] }
      }.each do |test_name,test_expectations|
        context test_name do
          let(:match_term) { test_expectations[:match_term] }
          let(:expected_position) { test_expectations[:expected_position] }
          subject { forms_reader.text_position(match_term,page) }
          it { should eql(expected_position) }
        end
      end
    end
  end
end