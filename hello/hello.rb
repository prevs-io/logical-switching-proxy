SECRET_KEY  = 'this is the very secret key!'
REDIS = Redis.new(host: '127.0.0.1', port: '6379')

class Hello < Sinatra::Base
  
  set :public => "public", :static => true

  get "/" do
    @version     = RUBY_VERSION
    @environment = ENV['RACK_ENV']

    erb :welcome
  end

  get "/api/rarities"  do
    m = ENV['PARAM_RARITY'].to_f
    content_type :json
    [:rarities => {:character_1 => sprintf("%4.1f",m),
                 :character_2 => sprintf("%4.1f",m * 0.75),
                 :character_3 => sprintf("%4.1f",m * 0.5),
    }].to_json
  end

end
