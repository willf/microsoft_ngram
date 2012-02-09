require 'rubygems'
require "rest-client"

module Bing
  
  # this class is only used to find the best default model, 
  # that is, for the default_model call
  class ModelSpec
    
    attr_accessor :model_type, :date, :size
    
    def initialize (spec)
      def parse_month(m)
        case m
          when 'jan': '01'
          when 'feb': '02'
          when 'mar': '03'        
          when 'apr': '04'        
          when 'may': '05'        
          when 'jun': '06'        
          when 'jul': '07'        
          when 'aug': '08'        
          when 'sep': '09'        
          when 'oct': '10'        
          when 'nov': '11'
          when 'dec': '12'
          else '??'
        end
      end
      parts = spec.split('/')
      @model_type = parts[0].split('-')[1] # 'bing-body'
      yr = parts[1].split(/\D/)[-1].to_i + 2000
      month = parse_month(parts[1].split(/\d/)[0])
      @date = "#{yr}-#{month}"
      @size = parts[2].to_i
    end
  end
  
  class Ngram

    @@endpoint = "http://web-ngram.research.microsoft.com/rest/lookup.svc/"
    @@models = nil
  
    def self.models()
      @@models=RestClient.get(@@endpoint).split(/\s+/)
    end
  
    def self.defined_model?(model)
      Bing::Ngram.models() if @@models == nil # cache the current models
      @@models.include?(model)
    end 
  
    def self.default_model(model_type='body') #most recent, longest
      Bing::Ngram.models() if @@models == nil # cache the current models
      ms = @@models.
        map{|x| [ModelSpec.new(x),x]}.
        find_all{|c| c[0].model_type == model_type}.
        sort_by{|c| [c[0].date, c[0].size]}
        @@default_model = ms.size > 0 ? ms[-1][1] : nil
    end
    
    def self.models_find_all(model_type='body',min_size=1)
      Bing::Ngram.models() if @@models == nil # cache the current models
      ms = @@models.
        map{|x| [ModelSpec.new(x),x]}.
        find_all{|c| c[0].model_type == model_type}.
        find_all{|c| c[0].size >= min_size}.
        sort_by{|c| [c[0].date, c[0].size]}.
        map{|spec,m| m}.
        reverse
    end
    
    attr_accessor :user_token
    # The model is the current model. Query this.models() for available models
    attr_accessor :model
    # Simple debug mode. If non-false, GET calls are display
    attr_accessor :debug
    # Ngram size based on model
    attr_accessor :ngram_size
    
    def initialize(args = {}) 
      @user_token = args["user_token"] || args[:user_token] || ENV["NGRAM_TOKEN"]
      unless @user_token
        raise "Must provide user token as NGRAM_TOKEN env variable or as :user_token => token. To get a token, see http://web-ngram.research.microsoft.com/info/ "
      end
      # probably shouldn't change
      @model = args["model"] || args[:model] || Bing::Ngram.default_model() 
      unless Bing::Ngram.defined_model?(@model)
        raise "Invalid model: #{@model}. Valid models are #{@@models.join('; ')}"
      end
      @debug = (args["debug"] || args[:debug] || nil)
      #puts "Creating #{@model.inspect} with debug=#{@debug}"
      @ngram_size = @model.split(/\//)[-1].to_i
    end
  
    
    
    def get(op,phrase,args)
      model = args["model"] || args[:model] || @model 
      RestClient.get(@@endpoint + model + '/' + op, {:params => {:u => @user_token, :p => phrase}.merge(args)}) do |res,req,result|
        $stderr.puts res.inspect if @debug
       res
      end
    end
  
    def post(op,phrases,args)
      model = args["model"] || args[:model] || @model 
      RestClient.post(@@endpoint + model + '/' + op + "?u=#{@user_token}", phrases.join("\n")) do |res,req,result|
        $stderr.puts res.inspect if @debug
       res
      end
    end
  
    def cp(phrase,args={})
      get('cp',phrase,args).to_f
    end
  
    def cps(phrases,args={})
      phrases.zip(post('cp',phrases,args).split(/\s+/).map{|r| r.strip.to_f})
    end
  
    def jp(phrase,args={})
      get('jp',phrase,args).to_f
    end
  
    def jps(phrases,args={})
      phrases.zip(post('jp',phrases,args).split(/\s+/).map{|r| r.strip.to_f})
    end
  
    # Yield up to nstop token, log-prob pairs given the tokens in the phrase. 

    def generate(phrase,nstop=2**32)
      arg = {}
      while true do
        break if nstop <= 0 
        arg['n']=[1000,[0,nstop].max].min
        result = get("gen",phrase,arg).split("\r\n")
        break if result.size <= 2
        nstop -= (result.size - 2)
        arg['cookie']=result[0]
        backoff = result[1]
        result[2..-1].each do |x|
          pair = x.split(';')
          yield [pair[0], pair[1].to_f]
        end
      end
    end
    
    # get a list of the next most popular tokens with log-freq
    def generate_list(phrase, max_length)
      l = []
      generate(phrase,max_length){|p| l << p}
      l
    end
  
    # spell-checking 
    # Bing::Ngram.new(:debug=>nil,:model=>'bing-body/jun09/1').jps(edits1("appresiate").uniq).sort{|a,b| b[1] <=> a[1]}[0..30]
  
  end
  
end
