# Class for reading structured text content. Some of this Class#methods were forked from
# PDF::Reader::Turtletext. See LICENSE file.
#
# Typical usage:
#
#     TODO
#
class PDF::Reader::Forms
  require File.expand_path(File.dirname(__FILE__) + '/forms/form_fields.rb')
  require File.expand_path(File.dirname(__FILE__) + '/forms/positioning.rb')
  require File.expand_path(File.dirname(__FILE__) + '/forms/content_blocks.rb')

  include Positioning
  include ContentBlocks # TODO: This should be optional
  include FormFields

  attr_accessor :reader, :options
  attr_reader :form_fields, :fields_found, :textboxes, :radiobuttons, :selectboxes, :linkboxes,
    :field_headers, :stack_of_fonts, :content_blocks

  # +source+ is a file name or stream-like object. Just like in PDF::Reader
  # Supported +options+ include:
  # * :y_precision
  def initialize(source, options={})
    @options = options
    @reader = PDF::Reader.new(source)
  end

  # def form_fields
  #   self.
  # end

  # Returns the precision required in y positions.
  # This is the fuzz range for interpreting y positions.
  # Lines with y positions +/- +y_precision+ will be merged together.
  # This helps align text correctly which may visually appear on the same line, but is actually
  # off by a few pixels.
  def y_precision
    options[:y_precision] ||= 3
  end

  # Returns positional (with fuzzed y positioning) text content collection as a hash:
  #   [ fuzzed_y_position, [[x_position,content]] ]
  def content(page=1)
    @content ||= []
    if @content[page]
      @content[page]
    else
      @content[page] = fuzzed_y(precise_content(page))
    end
  end

  # Returns positional text content collection as a hash with precise x,y positioning:
  #   { y_position: { x_position: content}}
  def precise_content(page=1)
    @precise_content ||= []
    if @precise_content[page]
      @precise_content[page]
    else
      @precise_content[page] = load_content(page)
    end
  end

  private

  def load_content(page)
    receiver = PDF::Reader::PositionOfTextReceiver.new
    reader.page(page).walk(receiver)
    @content_blocks = receiver.content_blocks_with_sizes
    @stack_of_fonts = receiver.stack_of_fonts
    receiver.content
  end
end