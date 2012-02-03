microsoft_ngram
===============

This is a simple ruby gem to access the Bing Ngram data. It's loosely based on Microsoft's Python library.
Source code at [github.com/willf/microsoft_ngram](http://github.com/willf/microsoft_ngram).

Installation
------------

Email [webngram@microsoft.com](mailto:webngram@microsoft.com?subject=Token%20Request) and request a token.
When you get your token, add it to your .bashrc or .bash_profile:

    export NGRAM_TOKEN="YOUR-TOKEN-HERE"
    
Then install the gem:

    gem install microsoft_ngram

Usage
-----

To get a list of currently available models:
 
    > MicrosoftNgram.models
    => ["bing-anchor/jun09/1", "bing-anchor/jun09/2", "bing-anchor/jun09/3", "bing-anchor/jun09/4", "bing-body/jun09/1", "bing-body/jun09/2", "bing-body/jun09/3", "bing-title/jun09/1", "bing-title/jun09/2", "bing-title/jun09/3", "bing-title/jun09/4", "bing-query/jun09/1", "bing-query/jun09/2", "bing-query/jun09/3"] 
 
To see the default model:

    > MicrosoftNgram.new.model            
    => "bing-body/jun09/3" 

Parameters to the initializer are:

    :model => <i>string</i> (sets model)
    :user_token => <i>string</i> (sets user token)
    :debug => <i>boolean</i> (will show GET/POST calls)
 
So, to use the 2-gram title model:

    > model = MicrosoftNgram.new(:model => "bing-title/jun09/2")

To get a single joint probability, or multiple joint probabilities (If
you know you want multiple joint probabilities, it is better to ask
for several at once):

    > MicrosoftNgram.new.jps(['fish sticks', 'frog sticks'])
    => [["fish sticks", -6.853792], ["frog sticks", -9.91852]] 
    > MicrosoftNgram.new.jp("fish sticks")
    => -6.853792 

To get a single conditional probability, or multiple conditional probabilities (If you know you want multiple conditional probabilities, it is better to ask for several at once):

    > MicrosoftNgram.new.cp("fish sticks")
    => -2.712575 
    > MicrosoftNgram.new.cps(['fish sticks', 'frog sticks'])
    => [["fish sticks", -2.712575], ["frog sticks", -4.788582]] 

To yield the most probable next token using the default model:

    > MicrosoftNgram.new.generate("Microsoft Windows",5)  {|x| puts x.join(' ')}
    xp -0.6964428
    vista -0.9242383
    server -1.106876
    2000 -1.145312
    currentversion -1.168404

To use the query model for the same thing:

    > MicrosoftNgram.new(:model => 'bing-query/jun09/3').generate("Microsoft Windows",5)  {|x| puts x.join(' ')}
    xp -0.5429792
    </s> -1.062959
    update -1.08291
    vista -1.199022
    installer -1.248958

More Info
---------

See the [REST API](http://web-ngram.research.microsoft.com/info/rest.html) and the 
[terms of use](http://web-ngram.research.microsoft.com/info/TermsOfUse.htm) for accessing the Microsoft data.

License
-------

(The MIT License)

Copyright (c) 2010/2011

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
