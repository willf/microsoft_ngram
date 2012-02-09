require File.dirname(__FILE__) + '/../lib/microsoft_ngram'
require 'rubygems'

class BackoffGenerator
  attr_accessor :model_type, :models, :debug
  
  def initialize(model_type="body",max_models=5,debug=false)
    @model_type = model_type
    @debug=debug
    @models = Bing::Ngram::models_find_all(model_type).take(max_models).map{|m|Bing::Ngram.new(:model => m, :debug=>debug)}
  end
  
  def generate_list(text, n, initial_text)
    @models.each do |model|
      l = model.generate_list(text,n)
      return l if l.size > 0
    end
    if (text != initial_text) 
      generate_list(initial_text, n, initial_text)
    else
      []
    end
  end
  
end

class Synthese
  attr_accessor :generator, :depth, :n, :debug
  
  def initialize(args = {})
    #puts args.inspect
    mtype = args[:model_type] || "body"
    @debug = args[:debug] || false
    @generator = BackoffGenerator.new(mtype,5,false)
    @depth = (args[:depth] ? args[:depth].to_i : 100)
    @n = Bing::ModelSpec.new(@generator.models[0].model).size
  end
  
  def self.weighted_random_index l
      tot = l.inject(0.0){|a,b| a+ b}
      ns = l.map{|i| i/tot}
      r = rand
      c = 0.0
      ns.each_with_index{|n,i| return i if r < (c+= n)}
      l.size-1 # PRACTICE SAFETY 
  end

  def self.random_word l
    l[Synthese.weighted_random_index(l.map{|w,lp| Math.exp(lp)})][0]
  end
  
  
  def generate(text)
    tokens = text.split(/\s/)
    tokens.each{|token| yield token}
    tokens = tokens[-@n..-1] if tokens.size > @n
    initial_text = text
    text = tokens.join(' ')
    while true
      #puts "OUTER. Generating from : #{text}"
      l = @generator.generate_list(text,@depth,initial_text)
      break if l.size == 0
      w = Synthese.random_word(l)
      yield w
      tokens << w
      tokens = tokens[-@n..-1] if tokens.size > @n
      text = tokens.join(' ')
    end
  end
  
  def generate_n(n,text)
    counter = 0
    generate(text){|w| yield w; counter += 1; break if counter > n }  
  end
end
