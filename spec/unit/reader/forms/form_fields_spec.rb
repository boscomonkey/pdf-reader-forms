require 'spec_helper'

describe PDF::Reader::Forms::FormFields do
  let(:forms_reader) { PDF::Reader::Forms.new(source,options) }
  let(:options) { {} }
  let(:page) { 1 }

  context "Analyze PDF Forms without valid Form Fields" do
    let(:source) { pdf_forms('first_form.pdf') }

    describe 'to locate the form fields' do
      describe 'locate the fields return' do
        subject { forms_reader.locate_the_form_fields }
        it { should be false }
      end
      describe 'to ensure annotations guard assembled' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.fields_found }
        it { should be false }
      end
      describe 'to locate the fields after already running once' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.locate_the_form_fields }
        it { should be false }
        subject { forms_reader.fields_found }
        it { should be false }
      end
    end

    describe 'to find individual content types' do
      describe 'locate the textboxes' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_textboxes }
        it { should eql([]) }
      end
      describe 'locate the radiobuttons' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_radiobuttons }
        it { should eql([]) }
      end
      describe 'locate the selectboxes' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_selectboxes }
        it { should eql([]) }
      end
      describe 'locate the linkboxes' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_linkboxes }
        it { should eql([]) }
      end
      describe 'locate the field headers' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_field_headers }
        it { should eql([]) }
      end
      describe 'locate the form fields' do
        before { forms_reader.locate_the_form_fields }
        subject { forms_reader.get_form_fields }
        it { should eql({}) }
      end
    end
  end

  context "with PDF Forms that have valid Form Fields" do
    let(:source) { pdf_forms('third_form.pdf') }
    before do
      forms_reader.find_the_form_fields
    end

    describe '#locate_the_questions' do
      describe ''
    end
  end

end