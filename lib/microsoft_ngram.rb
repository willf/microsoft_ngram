require 'rest_client'

class MicrosoftNgram
  VERSION = '1.0.0'

  @@endpoint = "http://web-ngram.research.microsoft.com/rest/lookup.svc/"
  @@models = nil
  
  def MicrosoftNgram.models()
    @@models=RestClient.get(@@endpoint).split(/\s+/)
  end
  
  def MicrosoftNgram.defined_model?(model)
    MicrosoftNgram.models() if @@models == nil # cache the current models
    @@models.include?(model)
  end 
  
  attr_accessor :user_token
  # The model is the current model. Query this.models() for available models
  attr_accessor :model
  # Simple debug mode. If non-false, GET calls are display
  attr_accessor :debug
  
  def initialize(args = {}) 
    @user_token = args["user_token"] || args[:user_token] || ENV["NGRAM_TOKEN"]
    unless @user_token
      raise "Must provide user token as NGRAM_TOKEN env variable or as :user_token => token. To get a token, see http://web-ngram.research.microsoft.com/info/ "
    end
    # probably shouldn't change
    @model = args["model"] || args[:model] ||  "bing-body/jun09/3"
    unless MicrosoftNgram.defined_model?(@model)
      raise "Invalid models. Valid models are #{@@models.join('; ')}"
    end
    @debug = (args["debug"] || args[:debug] || nil)
  end
  
  def get(op,phrase,args)
    model = args["model"] || args[:model] || @model 
    RestClient.get(@@endpoint + model + '/' + op, {:params => {:u => @user_token, :p => phrase}.merge(args)}) do |res,req,result|
      $stderr.puts req.inspect if @debug
     res
    end
  end
  
  def post(op,phrases,args)
    model = args["model"] || args[:model] || @model 
    RestClient.post(@@endpoint + model + '/' + op + "?u=#{@user_token}", phrases.join("\n")) do |res,req,result|
      $stderr.puts req.inspect if @debug
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
  
  # spell-checking 
  # MicrosoftNgram.new(:debug=>nil,:model=>'bing-body/jun09/1').jps(edits1("appresiate").uniq).sort{|a,b| b[1] <=> a[1]}[0..30]
   
end
