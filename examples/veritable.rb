require File.dirname(__FILE__) + '/veritable_lib.rb'
require 'rubygems'
require 'trollop'

def main
  opts = Trollop::options do
    banner "Generate phrases from Bing's Ngram server based on patterns— specify pattern on command line as alternating strings and ints"
    opt :max_wild_children, "Max number of wildcard tokens to generate", :default => 20
    opt :max_literal_children, "Max number of tokens to generate after literal strings", :default => 100
    opt :model, "Corpus model to use", :default => Bing::Ngram.default_model
    opt :max_length, "Maximum length of phrases to generate", :default => 5
    opt :verbose, "Send logging messages to $STDERR", :default => false
  end
  
  pattern = []
  ARGV.each_with_index{|item, i| pattern << ((i % 2 == 0) ? item : [item.to_i])}
  if opts[:verbose]
    $stderr.puts opts.inspect
    $stderr.puts pattern.inspect
  end
  R.new(pattern, opts).generate{|t| $stdout.puts(t.join("\t"))}
end

trap("INT","EXIT")
main

# examples 
#  veritable.rb "veritable" 2 "of" 2 
#  veritable.rb  --max-literal-children 50 "a taste of" 2 
