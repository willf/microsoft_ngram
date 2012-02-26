require File.dirname(__FILE__) + '/synthese_lib.rb'
require 'rubygems'
require 'trollop'


def tcase(w)
  return w.upcase if w.size < 2
  w[0..0].upcase + w[1..-1]
end

def scribble(opts)
  s = opts[:s]
  wc = -1
  s.generate_n(opts[:max_wc],opts[:starter]){ |w| 
    ((wc+=1) == 0) ? print(tcase(w)) : (((w=="<s>") || (w=="</s>")) ? print("#{w}\n") : print(w))
    print(" ")
    $stdout.flush
  }
end

def main
  opts = Trollop::options do
    banner "Samsabot writer"
    opt :starter, "Starter text for story", :default => "As Gregor Samsa awoke"
    opt :max_wc, "Max number of words to generate", :default => 35
    opt :model, "Corpus model to use", :default => Bing::Ngram.default_model
    opt :depth, "How deep to look for the next token", :depth => 100
    opt :debug, "Debug errors", :default=> true
  end
  
  opts[:s] = Synthese.new(opts)
  trap("INT","EXIT")
  while true
    scribble(opts)
    puts "\n\n"
    $stdout.flush
  end
end

main

  
