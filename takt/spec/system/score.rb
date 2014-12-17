# Score must returns the variable "$backend".
# $backend variable is used by parameter as http://$backend in nginx.conf
#

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
