require File.dirname(__FILE__) + '/synthese_lib.rb'
require 'rubygems'
require 'trollop'

def weighted_random_index l
    tot = l.inject(0.0){|a,b| a+ b}
    ns = l.map{|i| i/tot}
    r = rand
    c = 0.0
    ns.each_with_index{|n,i| return i if r < (c+= n)}
    l.size-1 # PRACTICE SAFETY 
end 

def random_punctuation
  p = [".", "?", "!"]
  f = [0.9, 0.05, 0.05]
  p[weighted_random_index(f)]
end

def rand_btw(min,max)
  rand(max-min)+min
end

def tcase(w)
  return w.upcase if w.size < 2
  w[0..0].upcase + w[1..-1]
end

def scribble(opts)
  puts "\n== " + opts[:title].split(/ /).map{|w| tcase(w)}.join(" ") + " ==\n\n" if opts[:title] && opts[:title].size > 0
  len = rand_btw(opts[:max_sentence_length],opts[:max_sentence_length])
  wc = -1
  s = opts[:s]
  s.generate_n(opts[:max_wc],opts[:starter]){ |w| 
    ((wc+=1) == 0) ? print(tcase(w)) : (((w=="<s>") || (w=="</s>")) ? print("#{w}\n") : print(w))
    print(" ")
    $stdout.flush
  }
end

def main
  opts = Trollop::options do
    banner "Synthetic writer"
    opt :title, "Title for story", :default => ""
    opt :starter, "Starter text for story", :default => "It was the best of times, it was the worst of times"
    opt :max_wc, "Max number of words to generate", :default => 1000
    opt :model, "Corpus model to use", :default => Bing::Ngram.default_model
    opt :depth, "How deep to look for the next token", :depth => 100
    opt :max_sentence_length, "Maximum length of sentences to generate", :default => 16
    opt :min_sentence_length, "Minimum length of sentences to generate", :default => 8
    opt :debug, "Debug errors", :default=> true
  end
  
  opts[:s] = Synthese.new(opts)
  trap("INT","EXIT")
  scribble(opts)
end

main
  
