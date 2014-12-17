Logical-switching-proxy
========

Proxy switching dynamically for developing mobile application requires api backend

Overview
---------

![](https://dl.dropboxusercontent.com/u/10177896/Logical-switching-proxy.png)

In mobile application development with API backend, if you have multiple staging endpoint servers with development, it is often hard to switch api endpoint config.

`logical-switching-proxy` is a reverse proxy dynamically routing by user specified logic. For example, mobile application request the endpoint with request header
'X-Switching-Id:', then the proxy routing request to backend staging server by user defined logic, so you can switch the api endpoint what you want without changing api endpoint config with re-build app. The logic can be written in mruby, which you can define a routing rule very easily.

Demo
----------

If you'd like to know simple usage, you can try the sample demo  in this project easily with running the Docker container we prepared.

    git clone https://github.com/ainoya/logical-switching-proxy.git && cd logical-switching-proxy
    docker build -t lsp .
    docker run -it --rm -p 49080:80 -p 49081:8080 -p 49082:3000 --name lsp lsp /data/scripts/start.sh

In this demo, it demonstrates use case following:

    - In development, your mobile application communicate with the endpoint `api.staging.com`
    - Mobile application requests the endpoint with request header `X-Switching-Id: test-001`
    - Logical Switching Proxy service process the request from mobile, then proxy routing requests by the value of `X-Switching-Id`.

At first, insert routing logic into store through management service `Takt`. The orchestration logic is written in mruby, like below.

    case r.headers_in["X-Switching-Id"]
    when 'test-001'
      backend='0.0.0.0:8080'
    when 'test-002'
      backend='0.0.0.0:9000'
    when 'test-003'
      backend='0.0.0.0:9001'
    else
      backend='0.0.0.0:8080'
    end

    return backend

The logic is in `./takt/spec/system/score.rb`, and next write the logic to `Takt` on `http://0.0.0.0:3000/write_score` with `POST`. Of cource, these procedure is also prepared in `./takt/spec/write_score.rb`:

    #!/usr/bin/env ruby
    require 'httparty'
    require 'json'
    require 'base64'

    path = File.dirname(__FILE__)

    score=File.open(File.join(path, 'score.rb')).readlines.join('')

    url = 'http://0.0.0.0:49082/write_score'

    # stored logic structure: {'context path' => 'base64 encoded routing logic written in mruby'}
    body = {'.*' =>  Base64.encode64(score)}.to_json

    HTTParty.post(url, :body=>body)

    ['test-001', 'test-002', 'test-003'].each do |id|
      puts HTTParty.get('http://0.0.0.0:49080/api/rarities', :headers => {'X-Switching-Id' => id})
    end

After writing the routing logic, check it works with this script.

    ➜  takt git:(master) ✗ bundle exec ruby spec/system/write_score.rb

    #puts HTTParty.get('http://0.0.0.0:49080/api/rarities', :headers => {'X-Switching-Id' => 'test-001'})
    {"rarities"=>{"character_1"=>" 0.1", "character_2"=>" 0.1", "character_3"=>" 0.1"}}
    #puts HTTParty.get('http://0.0.0.0:49080/api/rarities', :headers => {'X-Switching-Id' => 'test-002'})
    {"rarities"=>{"character_1"=>" 0.3", "character_2"=>" 0.2", "character_3"=>" 0.1"}}
    #puts HTTParty.get('http://0.0.0.0:49080/api/rarities', :headers => {'X-Switching-Id' => 'test-003'})
    {"rarities"=>{"character_1"=>" 0.9", "character_2"=>" 0.7", "character_3"=>" 0.5"}}

Finally, you can bind the two apis into one api!

## Contributing

Once you've made your great commits:

1. [Fork][fk]
2. Create your feature branch (``git checkout -b my-new-feature``)
3. Write tests
4. Run tests with ``rake test``
5. Commit your changes (``git commit -am 'Added some feature'``)
6. Push to the branch (``git push origin my-new-feature``)
7. Create new pull request
8. That's it!

Or, you can create an [Issue][is].

## License

### Copyright

* Copyright (c) 2014- Naoki AINOYA
* License
  * Apache License, Version 2.0

[is]: https://github.com/ainoya/logical-switching-proxy/issues
[darzana]: https://github.com/kawasima/darzana
[ngx_mruby]: https://github.com/matsumoto-r/ngx_mruby/
[overview]: https://dl.dropboxusercontent.com/u/10177896/karajan-overview.png
[netflix]: http://techblog.netflix.com/2012/07/embracing-differences-inside-netflix.html
[fk]: http://help.github.com/forking/
