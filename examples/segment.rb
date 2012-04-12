require File.dirname(__FILE__) + '/../lib/microsoft_ngram'
require 'rubygems'
require 'memoize'

# This code based on Peter Novig's chapter on "Natural Language Corpus Data" in
# Beautiful Data. 

include Memoize

$bi_body_model = Bing::Ngram.new(:model => "bing-body/apr10/2", :debug=>false)
$uni_body_model = Bing::Ngram.new(:model => "bing-body/apr10/1", :debug=>false)
$magic_pr =  -13.419954 # twice as uncommon as "kraig" last word in Bing 100k list

# Returns all the splits of a string up to a given length
def splits(text,max_len=text.size)
  Range.new(0,[text.size,max_len].min-1).map{|i| [text[0..i],text[i+1..-1]]}
end

# This keeps just those splits whose first item is above the magic unigram
# log probability
def reasonable_splits(text,max_len=text.size)
  splits(text,max_len).find_all{|pre,suf| Pr(pre)>=$magic_pr}
end

# Get the unigram log probability of a token
def Pr(str)
  $uni_body_model.cp(str)
end 

# Get the conditional probability of a word, given a prior
def cPw(word, prev)
  $bi_body_model.cp([prev,word].join(' '))
end

# combine data
def combine(pfirst, first, pr)
  prem, rem = pr
  return [pfirst+prem, [first]+rem]
end

# segment a text, assuming it is at the beginning of a sentence
# return a pair: the log probability, and the most probable segmentation
def segment2(text, prev="<s>")
  #puts "segment2: #{text.inspect} prev: #{prev}"
  return [0.0,[]] if (!text or text.size==0)
  reasonable_splits(text).map{|first,rem| combine(cPw(first,prev), first, segment2(rem, first))}.max
end

# just return the best segmentation
def segment(text)
  segment2(text)[1]
end

# We want to memoize a lot of things.
memoize :splits
memoize :reasonable_splits
memoize :Pr 
memoize :cPw 
memoize :segment2 

# These are some Twitter hash tags which I segmented.
#  > segment("bpcares")
#  => ["bp", "cares"] 
#  > segment("Twitter")
#  => ["Twitter"] 
#  > segment("writers")
#  => ["writers"] 
#  > segment("iamwriting")
#  => ["i", "am", "writing"] 
#  > segment("backchannel")
#  => ["back", "channel"] 
#  > segment("tcot")
#  => ["tcot"] 
#  > segment("vacationfallout")
#  => ["vacation", "fall", "out"] 


