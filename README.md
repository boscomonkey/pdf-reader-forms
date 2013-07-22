# PDF::Reader::Forms

[![Build Status](https://travis-ci.org/compleatang/pdf-reader-forms.png)](https://travis-ci.org/compleatang/pdf-reader-forms)[![Code Climate](https://codeclimate.com/github/compleatang/pdf-reader-forms.png)](https://codeclimate.com/github/compleatang/pdf-reader-forms)[![Dependency Status](https://gemnasium.com/compleatang/pdf-reader-forms.png)](https://gemnasium.com/compleatang/pdf-reader-forms)

PDF::Reader::Forms is an extension for the most excellent [PDF::Reader](https://github.com/yob/pdf-reader) gem.

The aim of PDF::Reader::Forms is to provide simple and convenient methods for extracting PDF text content along with PDF forms data so as to convert the entire form into objects which can be consumed by Ruby code. Primarily, this was developed to support the [PDF-Form-Filler](https://github.com/compleatang/pdf_form_filler) gem which converts the objects which have been extracted by this gem into a hash which is consumeable by Rails and Sinatra applications.

# Usage of PDF::Reader::Forms

## Installation

It is distributed as a gem, so all normal gem installation procedures apply. To install the gem directly from the command line:

```bash
$ gem install pdf-reader-turtletext
```

For Rails or Sinatra, add to your Gemfile:

```ruby
gem 'pdf-reader-turtletext'
```

Then bundle install:

```bash
$ bundle install
```

## How to instantiate Forms in code

All interaction is done using an instance of the PDF::Reader::Forms class. It is initialised given a filename or IO-like object, and any required options.

Typical usage:

```ruby
pdf_filename = '../some_path/some.pdf'
reader = PDF::Reader::Forms.new(pdf_filename)
#options = { :y_precision => 5 }
#reader_with_options = PDF::Reader::Forms.new(pdf_filename,options)
```

## Extract text for a region with known positional co-ordinates

If you know (or can calculate) the x,y positions of the required text region, you can extract the region's text using the `text_in_region` method.

```ruby
text = reader.text_in_region(
  10,   # minimum x (left-most)
  900,  # maximum x (right-most)
  200,  # minimum y (bottom-most)
  400,  # maximum y (top-most)
  1,    # page (default 1)
  false # inclusive of x/y position if true (default false)
)
=> [['string','string'],['string']] # array of rows, each row is an array of text elements in the row
```

Note that the x,y origin is at the bottom-left of the page.

## How to find the x,y co-ordinate of a specific text element

Problem: if you are doing low-level text extraction with `text_in_region` for example, it is usually necessary to locate specific text to provide a positional reference.

Solution: use the `text_position` method to locate text by exact or partial match. It returns a Hash of x/y co-ordinates that is the bottom-left corner of the text.

```ruby
page = 1
text_by_exact_match = reader.text_position("Transaction Table", page)
=> { :x => 10.0, :y => 600.0 }
text_by_regex_match = reader.text_position(/transaction summary/i, page)
=> { :x => 10.0, :y => 300.0 }
```

Note: in the case of multitple matches, only the first match is returned.

# Thanks & Motivation

TODO

# Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Add Tests (and feel free to help here since I don't (yet) really know how to do that.).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create new Pull Request.

# Copyright

MIT License - (c) 2013 - Watershed Legal Services, PLLC. All copyrights are owned by [Watershed Legal Services, PLLC](http://watershedlegal.com).

Portions of this Gem were forked from the PDF::Reader::Turtletext gem. PDF::Reader::Turtletext is MIT Copyright (c) 2012 Paul Gallagher. See LICENSE for further details.

See License file.