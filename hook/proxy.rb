@host  = "0.0.0.0"
@port  = 6379
@redis = Redis.new(@host, @port)

def load_scores
 score = JSON.parse(@redis.get('score'))
 ret = {}
 score.each{|k, v| ret[k] = JWT.base64url_decode(v)}
 return ret
end

r = Nginx::Request.new
scores = load_scores
target_score = scores[scores.keys.select{|k| r.uri =~ /#{k}/}.first]

eval("def backend_logic r;#{target_score};end")

r.var.set "backend", backend_logic(r)

