require 'spec_helper'

describe MicrosoftNgram do  

  include ::MicrosoftNgram
  
  it "should return a list of models" do
    MicrosoftNgram.models.size.should > 0
  end 
  
  it "should have a user token, or you're hosed" do
    MicrosoftNgram.new.user_token.should_not == nil 
  end 
  
  it "should have a default model" do
    MicrosoftNgram.new.model.should_not == nil 
  end
  
  it "should retrieve a joint probability" do
    MicrosoftNgram.new.jp("fish sticks").should < 0 
  end 
  
  it 'should retrieve a list of joint probabilities' do
    fish, frog = ["fish sticks", "frog sticks"]
    fish_results, frog_results = MicrosoftNgram.new.jps([fish, frog])
    fish_results[0].should == fish
    fish_results[1].should < 0
    frog_results[0].should == frog
    frog_results[1].should < 0
    fish_results[1].should > frog_results[1] 
  end
  
  it "should retrieve a conditional probability" do
     MicrosoftNgram.new.cp("fish sticks").should < 0 
   end
  
   it 'should retrieve a list of conditional probabilities' do
     fish, frog = ["fish sticks", "frog sticks"]
     fish_results, frog_results = MicrosoftNgram.new.cps([fish, frog])
     fish_results[0].should == fish
     fish_results[1].should < 0
     frog_results[0].should == frog
     frog_results[1].should < 0
     fish_results[1].should > frog_results[1] 
   end
   
   it 'should yield most probable next tokens' do
     two_gram_stream = MicrosoftNgram.models.find do |model|
       name, date, size = model.split(/\//)
       name.include?("body") && size=="2"
     end
     two_gram_stream.should_not == nil
     m = MicrosoftNgram.new(:model => two_gram_stream)
     count = 0
     m.generate("the",10) do |word, log_prob|
       count += 1
       word.should_not == nil
       log_prob.should < 0
     end
     count.should == 10
   end
end 

