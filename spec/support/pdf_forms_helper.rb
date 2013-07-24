require 'pathname'

module PdfFormsHelper

  def pdf_forms_path
    Pathname.new(File.dirname(__FILE__)).join('..','fixtures','pdf_forms')
  end

  def pdf_forms(form_name)
    pdf_forms_path.join(form_name)
  end

  def pdf_forms_names
    Dir[pdf_forms_path.join("*.pdf")]
  end

  def pdf_forms_receiver_expectations_path
    pdf_forms_path.join('receiver_expectations.yml')
  end

  def pdf_forms_receiver_expectations
    begin
      YAML.load_file pdf_forms_receiver_expectations_path
    rescue
      []
    end
  end

  def pdf_forms_blocks_expectations_path
    pdf_forms_path.join('block_expectations.yml')
  end

  def pdf_forms_blocks_expectations
    begin
      YAML.load_file pdf_forms_block_expectations_path
    rescue
      []
    end
  end
end