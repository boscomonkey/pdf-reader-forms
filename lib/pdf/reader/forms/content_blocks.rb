module PDF::Reader::Forms::ContentBlocks

  # Returns an Array with fuzzed positioning, ordered by decreasing y position. Row content order by x position.
  #   [ fuzzed_y_position, [[x_position_start,x_position_end,content]] ]
  # Given +input+ as a hash:
  #   { y_position: { x_position_start: [x_position_end,content]}}
  # Fuzz factors: +y_precision+
  def fuzzed_y(input)
    output = []
    input.keys.sort.reverse.each do |precise_y|
      matching_y, y_index = get_whys( precise_y, output )
      if y_index
        output[y_index] = [ matching_y, later_row_agglomerate( get_new_row( input[precise_y] ), output[y_index] ) ]
      else
        output << [ matching_y, first_row_agglomerate( get_new_row( input[precise_y] ) ) ]
      end
    end
    output
  end
  def mean_font_size
    p content_blocks
    p content
  end

  private

  def get_whys( precise_y, output )
    matching_y = output.map(&:first).select{|new_y| (new_y - precise_y).abs < y_precision }.first || precise_y
    y_index = output.index{|y| y.first == matching_y }
    return matching_y, y_index
  end

  def get_new_row( input )
    new_row_content = input.to_a
    new_row_content.inject([]){|arr,a| a.each{|e| e.is_a?(Array) ? arr.last.concat(e) : arr << [e]}; arr}
  end

  def first_row_agglomerate( new_row_content )
    if new_row_content.first.is_a?(Array)
      new_row_content = new_row_content.sort{ |a,b| a.first <=> b.first }
    end
    return new_row_content
  end

  def later_row_agglomerate( new_row_content, row_content )
    row_content = row_content.last if row_content.count == 2 && row_content.first.is_a?(Float)
    row_content += new_row_content
    if row_content.first.is_a?(Array)
      row_content = row_content.sort{ |a,b| a.first <=> b.first }
    else
      row_content = row_content[1..-1].sort{ |a,b| a.first <=> b.first }
    end
    return row_content
  end

end