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

  attr_reader :stack_of_fonts, :content_blocks_with_sizes

  def page=(page)
    super
    @content = {}
    @stack_of_fonts = []
  end

  # record text that is drawn on the page
  def show_text(string)
    @startx, @starty = @state.trm_transform(0,0)
    super
    @endx, @endy = @state.trm_transform(0,0)
    positional_transformer(string.gsub("\n", ""))
  end

  def show_text_with_positioning(params)
    @startx, @starty= @state.trm_transform(0,0)
    super
    @endx, @endy = @state.trm_transform(0,0)
    string = ''
    params.each{ |arg| string << arg.gsub("\n", "") if arg.is_a?(String) }
    positional_transformer(string)
  end

  def positional_transformer(string)
    chars = [ @endx, @state.current_font.to_utf8( string ) ]
    @content[@starty] ||= {}
    @content[@starty][@startx] = chars
    font_grabber
  end

  def font_grabber
    font = @state.current_font.basefont.to_s
    size = @state.font_size
    description = @state.current_font.subtype.to_s
    @stack_of_fonts << [ font, description, size ]
  end

  # override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     y_coord=>{x_coord=>text, x_coord=>text },
  #     y_coord=>{x_coord=>text, x_coord=>text }
  #   }
  def content
    @content
  end

  def content_blocks_with_sizes
    unless @content_blocks_with_sizes
      strings = []
      @content_blocks_with_sizes = @content.zip(@stack_of_fonts).map{|e| e.first[1]=e.first[1].to_a; e.flatten}.
            reduce([]){|arr,e| t=[]; t[0]=e[3]; t[1]=[e[1],e[2],e[0],e[0]+e[-1]]; t[2]=e[-3..-1]; arr << t}
    end
    @content_blocks_with_sizes
  end
end
