class PDF::Reader::Forms

  module Positioning

    # Returns an array of text elements found within the x,y limits on +page+:
    # * x ranges from +xmin+ (left of page) to +xmax+ (right of page)
    # * y ranges from +ymin+ (bottom of page) to +ymax+ (top of page)
    # When +inclusive+ is false (default) the x/y limits do not include the actual x/y value.
    # Each line of text is an array of the seperate text elements found on that line.
    #   [["first line first text", "first line last text"],["second line text"]]
    def text_in_region(xmin,xmax,ymin,ymax,page=1,expansive=true,array=false)
      return [] unless xmin && xmax && ymin && ymax
      array ? text_map = array : text_map = content(page)
      box = []
      text_map.each do |y,text_row|
        if (y >= ymin && y <= ymax)
          takers = []
          text_row.each do |xstart,xstop,element|
            if expansive ? (xstop >= xmin && xstart <= xmax) : (xstart >= xmin && xstop <= xmax)
              takers << element
            end
          end
          box << takers unless takers.empty?
        end
      end
      box
    end

    # Returns the position of +text+ on +page+
    #   {x: val, y: val }
    # +text+ may be a string (exact match required) or a RegEx.
    # Returns nil if the text cannot be found.
    # Returns an array of all the matches found either for the string or the RegEx.
    def text_position(text,page=1)
      results = []
      item = if text.class <= Regexp
        content(page).map do |k,v|
          x = v.select{|vv| vv[2] =~ text  }
          results << [k,x] if x
        end
      else
        content(page).map do |k,v|
          x = v.select{|vv| vv[2].include?( text )}
          ( results << [k,x] ) unless x.empty?
        end
      end
      results = results.map do |item|
        item = item.compact.flatten
        { :xstart => item[1], :xstop => item[2], :y => item[0], :result =>item[3] } unless item.empty?
      end.reject{ |el| el[:result] == nil }
      if results.empty?
        return nil
      else
        return results
      end
    end

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
end