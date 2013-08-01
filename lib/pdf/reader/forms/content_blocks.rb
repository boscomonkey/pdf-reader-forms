module PDF::Reader::Forms::ContentBlocks

  def headers page=1
    @headers ||= []
    unless @headers[page]
      setup_page page
      find_headers page
    end
    @headers[page]
  end

  def text page=1
    @text_blocks ||= []
    unless @text_blocks[page]
      setup_page page
      find_text_blocks page
    end
    @text_blocks[page]
  end

  private

  def setup_page page
    mfs page
    mfh page
  end

  def mfs page
    @mfs ||= []
    unless @mfs[page]
      @mfs[page] = content_blocks(page).reduce([0,0]){|tot,ele| tot[0] += (ele.first.size * ele.last.last); tot[1] += (ele.first.size); tot }
      @mfs[page] = @mfs[page][0]/@mfs[page][1]
    end
    @mfs[page]
  end

  def mrh page
    @mrh ||= []
    unless @mrh[page]
      @mrh[page] = content.map{|e| e.first}
      while @mrh[page].count > 1; h||=[]; h << (@mrh[page][-2]-@mrh[page][-1]); 2.times{@mrh[page].pop}; end
      @mrh[page] = h.reduce(0){|n,e| n+=e} / content.size
    end
    @mrh[page]
  end

  def find_headers page
    filter = reductor_hash
    header_filters.each{|fil| fil.call(page).each{ |e| filter[e]+=1 } }
    @headers[page] = filter.map{ |k,v| k if v >= 2 }.compact; filter.clear
    @headers[page].each{|b| content_blocks(page).delete(b) }
  end

  def find_text_blocks page
    @text_blocks[page] = find_via_threading(page)
  end

  def header_filters
    headers_by_mean_font_size = ->(page) { content_blocks(page).select{|b| b.last.last > (@mfs*1.1) } }
    headers_by_italics = ->(page) { content_blocks(page).select{|b| b.last.first[/italic|oblique/] } }
    headers_by_bold = ->(page) { content_blocks(page).select{|b| b.last.first[/bold/] } }
    return [ headers_by_mean_font_size, headers_by_italics, headers_by_bold ]
  end

  def find_via_threading page
    strats = [ ssx, hb, vs, ai, ao, cpe ]
    filter = reductor_hash
    strats.permutation(3).reduce([]) do |results, perm|                                    # this will result in 120 threads
      #fork the process && make sure subprocess can talk to results
      results += find_for_individual_thread page, results, perm
      #close the process
    end.each{|b| filter[b] += 1 }
    final_tally = filter.map{ |k,v| k if v >= 90 }.compact; filter.clear                  # 75% success rate
    final_tally
  end

  def find_for_individual_thread page, results, perm
    filter = reductor_hash
    perm.reduce([]) do |threaded_blocks, test|
      threaded_blocks += map_blocks page, true, test
      threaded_blocks += map_blocks page, false, test
    end.each{ |b| filter[b] += 1 }
    results += filter.map{ |k,v| k if v >= 4 }.compact; filter.clear # array of 3 * boolean = 6, so 4 is a 75% hit
    results
  end

  # dir = true ==> going DOWN the page
  def map_blocks page, dir, condition
    text_blocks = [[]]
    cont = content_blocks(page).dup
    cont.each_with_index do | b, c |
      begin; dir ? c = cont[c+1][1] : c = cont[c-1][1]; rescue; c = b[1]; end
      condition.call( b[1], c, dir ) ? text_blocks.last << b : text_blocks.push([b])
      content_blocks(page).delete(b)
    end
    cont.clear
    reduce_blocks text_blocks
  end

  def reduce_blocks text_blocks
    text_blocks.reduce([]) do |a,b|
      t = ''; p = [0,0,0,0]; f = reductor_hash
      b.each do |ele|
        t += ' ' + ele[0]; f[ele[2]]+=1
        ele[1].each_with_index{|c,i| c > p[i] ? p[i] = c : p[i] }
      end
      t = t.gsub("\n", ' ').squeeze(' ').strip
      f = f.key(f.each_value.max)
      a << [t, p, f]
    end
  end

  def reductor_hash
    hash = {}; hash.default_proc = proc {|h,k| h[k] = 0}
    hash
  end

  def cpe
    catch_para_ends = lambda do |a, b, c|
      if c
        ( ( a[1] - b[1] ) > ( (a[1] - a[0]) * 0.10 ) )
      else
        ( ( b[1] - a[1] ) > ( (a[1] - a[0]) * 0.10 ) )
      end
    end
  end

  def ao
    allow_outdents = lambda do |a, b, c|
      if c
        ( ( a[0] - b[0] ) > ( (a[1] - a[0]) * 0.10 ) )
      else
        ( ( b[0] - a[0] ) > ( (a[1] - a[0]) * 0.10 ) )
      end
    end
  end

  def ai
    allow_indents = lambda do |a, b, c|
      if c
        ( ( a[0] - b[0] ) < ( (a[1] - a[0]) * 0.10 ) )
      else
        ( ( b[0] - a[0] ) < ( (a[1] - a[0]) * 0.10 ) )
      end
    end
  end

  def vs
    vertical_space = lambda do |a, b, c|
      if c
        ( ( a[2] - b[3] ) < mrh(page) )
      else
        ( ( b[2] - a[3] ) < mrh(page) )
      end
    end
  end

  def hb
    horizontal_breaks = ->(a, b, c) { ( ( a[1] - b[0] ) < ( mfs(page) * 1.1 ) ) }
  end

  def ssx
    same_starting_x = ->(a, b, c) { ( a[0] == b[0] ) }
  end
end