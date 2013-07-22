# Receiver to access positional (x,y) text content from a PDF
#
# Typical usage:
#
#   reader = PDF::Reader.new(filename)
#   receiver = PDF::Reader::PositionOfTextReceiver.new
#   reader.page(page).walk(receiver)
#   receiver.content
#
class PDF::Reader::PositionOfTextReceiver < PDF::Reader::PageTextReceiver

  # record text that is drawn on the page
  def show_text(string)
    internal_show_text(string)
    temp_hash = {}
    chars = @state.current_font.to_utf8(string)
    newx, newy = @state.trm_transform(0,0)
    temp_hash[newy] ||= {}
    temp_hash[newy][newx] ||= ''
    temp_hash[newy][newx] = chars || ''
    @content << temp_hash if chars
  end

  # override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     y_coord=>{x_coord=>text, x_coord=>text },
  #     y_coord=>{x_coord=>text, x_coord=>text }
  #   }
  def content
    @content = @content.inject({}) do |hash, element|
      hash.merge(element){|key,oldvalue,newvalue| oldvalue.merge(newvalue)}
    end
  end

end
