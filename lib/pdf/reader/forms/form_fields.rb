module PDF::Reader::Forms::FormFields

  attr_reader :form_fields, :fields_found, :textboxes, :radiobuttons, :selectboxes, :linkboxes

  def get_form_fields
    @form_fields ||= locate_the_form_fields
    @form_fields[:textboxes] ||= @textboxes if @textboxes
    @form_fields[:radiobuttons] ||= @radiobuttons if @radiobuttons
    @form_fields[:selectboxes] ||= @selectboxes if @selectboxes
    @form_fields[:linkboxes] ||= @linkboxes if @linkboxes
    @form_fields[:field_headers] ||= @field_headers if @field_headers
    @form_fields
  end

  def get_textboxes
    return @textboxes if @textboxes
    if @sorted_annotations && @fields_found == nil
      @textboxes = locate_the_questions(:textboxes)
    else
      @textboxes = []
    end
  end

  def get_radiobuttons
    return @radiobuttons if @radiobuttons
    if @sorted_annotations && @fields_found == nil
      @radiobuttons = locate_the_questions(:radiobuttons)
    else
      @radiobuttons = []
    end
  end

  def get_selectboxes
    return @selectboxes if @selectboxes
    if @sorted_annotations && @fields_found == nil
      @selectboxes = locate_the_questions(:selectboxes)
    else
      @selectboxes = []
    end
  end

  def get_linkboxes
    return @linkboxes if @linkboxes
    if @sorted_annotations && @fields_found == nil
      @linkboxes = locate_the_questions(:linkboxes)
    else
      @linkboxes = []
    end
  end

  def get_field_headers
    return @field_headers if @field_headers
    if @sorted_annotations || @fields_found == nil
      @field_headers = headers_helper
    else
      @fields_headers = []
    end
  end

  def locate_the_form_fields
    if @fields_found == nil
      @form_fields = {}
      if assemble_the_annotations
        @unsure_stack = {}; @unsure_stack.default_proc = proc {|h,k| h[k] = []}
        @content_stack = content.clone
        textboxes; radiobuttons; selectboxes
        linkboxes; field_headers
        # assemble it
      else
        return @fields_found = false
      end
      return @fields_found = true
    end
    @fields_found
  end

  def assemble_the_annotations
    annots = reader.pages.map{|p| p.attributes[:Annots]}
    annotations = annots.reduce([]) do |arr, r|
      if r.class == PDF::Reader::Reference
        refs = reader.reader.objects[r.id].select{|e| e.class == PDF::Reader::Reference}
        objs = reader.reader.objects[r.id].reject{|e| e.class == PDF::Reader::Reference}
        annots << refs unless refs.empty?
        arr << objs unless objs.empty?
      else
        arr << r
      end
      annots.flatten!; arr.flatten!; arr
    end
    return nil if annotations.compact.empty?
    sort_the_annotations annotations
  end

  def sort_the_annotations( annotations )
    @sorted_annotations = annotations.reduce({}) do |h, el|
      d = Hash.new; d.default_proc = proc {|h,k| h[k] = []}
      case
      when el[:TU]
        d[:textboxes] << el
      when el[:NM]
        d[:radiobuttons] << el
      when el[:PL]
        d[:select] << el
      when el[:FL]
        d[:links] << el
      end
      h.merge(d){|key,oldval,newval| oldval << newval}
    end
  end

  def locate_the_questions type
    # results = @sorted_annotations[type].map do | box |
    #   questions_helper(box, type)
    # end.compact if @sorted_annotations[type]
    # return results || []
    []
  end

  def questions_helper( box, type )
    page = reader.pages.select{|p| p.attributes == reader.objects[box[:P].id]}.first.number
    location = box[:Rect]
    result, newlocation = find_the_linked_text( location, type, page )
    if result == :unsure
      dump_to_unsure_stack(box, type)
      return nil
    else
      box[:question] = result.join(" ")
      box[:Rect] = newlocation
    end
    box
  end

  def headers_helper
    #todo
    # @field_headers = @unknown_stack do | box |
    #   headers_helper box
    # end.compact if @unknown_stack && @fields_found == nil
    # @fields_found ? @field_headers : []
    return []
  end

  def find_the_linked_text( location, type, pg )
    case type  # todo...clean
    when :tb
      # NoMethodError: undefined method `>=' for #<Array:0x007fa4c0163a70>
      # from /home/coda/sites/gems/pdf-reader-forms/lib/pdf/reader/forms/positioning.rb:16:in `block in text_in_region'
      result = text_in_region(location[0], location[2], location[1], location[3]+20, 1, true, content_stack[pg])
      location[3] = location[3] + 20
      result = text_in_region(location[0], location[2], location[1]-20, location[3], 1, true, content_stack[pg]) unless result.count == 1
    when :rad
      result = text_in_region(location[0], location[2]+50, location[1], location[3], 1, true, content_stack[pg])
      result = text_in_region(location[0]-50, location[2], location[1], location[3], 1, true, content_stack[pg]) unless result.count == 1
    when :slt
      result
    when :lnk
      result
    end
    #delete the result from the stack, and update the location...
    return result, location
  end

  def try_the_linked_text_again( location, type )
    #todo
  end

  def dump_to_unsure_stack( annotation, type )
    @unsure_stack[type] << annotation
  end

  def dump_to_known_stack
    #todo....?
  end

  def grouped_assembly
    @raw_output = @raw_output.group_by{|e| e["FieldName"].split(".")[0..1]}
    pages = @raw_output.count
    pages_array = @raw_output.each_value.collect{|v| v}
    @content = pages_array.inject([]) do |array, page|
      t = {}
      t[:title] = "Section #{pages_array.index(page)+1}"
      t[:intro] = "This is Section #{pages_array.index(page)+1} of #{pages_array.count}."
      t[:lede] = "There are #{page.count} fields in this Section. Good luck."
      t[:fields] = page.collect{ |f| fields_set_up( f ) }
      array << t
    end
  end

  def fields_set_up raw_field
    data = {}
    if raw_field["FieldType"] == "Button"
      data[:type] = 'checkbox'
    elsif raw_field["FieldType"] == "Choice"
      data[:type] = 'choice'                      #todo - update this for countries
    else
      data[:type] = 'text'
    end
    if @favor_alt_text
      data[:labeltext] = raw_field["FieldNameAlt"] || raw_field["FieldName"] || ""
    else
      data[:labeltext] = raw_field["FieldName"] || raw_field["FieldNameAlt"] || ""
    end
    data[:name] = raw_field["FieldName"] || ""
    data[:value] = raw_field["FieldValue"] || ""
    data[:minlength] = raw_field["FieldMinLength"] || ""
    data[:maxlength] = raw_field["FieldMaxLength"] || ""
    data[:fieldstateoptions] = raw_field["FieldStateOption"] || ""
    data[:fieldjustifiction] = raw_field["FieldJustification"] || ""
    data[:fieldflags] = raw_field["FieldFlags"] || ""
    data
  end
end