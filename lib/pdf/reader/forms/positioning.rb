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
  end
end