#!/bin/sh
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv local 2.1 && ruby -v

/usr/local/bin/redis-server /etc/redis.conf

/usr/local/nginx/sbin/nginx &

cd /data
cp -rp hello hello1
cp -rp hello hello2
cd /data/hello
export PARAM_RARITY='0.1'; bundle exec unicorn -c config/unicorn.rb -l 0.0.0.0:8080 &
cd /data/hello1
export PARAM_RARITY='0.3'; bundle exec unicorn -c config/unicorn.rb -l 0.0.0.0:9000 &
cd /data/hello2
export PARAM_RARITY='0.9'; bundle exec unicorn -c config/unicorn.rb -l 0.0.0.0:9001 &


cd /data/takt
bundle exec unicorn -c config/unicorn.rb -l 0.0.0.0:3000 &

tail -F /usr/local/nginx/logs/access.log &
tail -F /usr/local/nginx/logs/error.log &
tail -F /data/hello/log/stderr.log &
tail -F /data/hello/log/stdout.log &
tail -F /data/takt/log/stderr.log &
tail -F /data/takt/log/stdout.log

