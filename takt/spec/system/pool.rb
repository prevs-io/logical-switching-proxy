# Score must returns the variable "$backend".
# $backend variable is used by parameter as http://$backend in nginx.conf
#
# This routing logic is example to integrate with [pool](https://github.com/mookjp/pool) system.
#

preview_id = r.headers_in["X-Preview-Id"]

if preview_id
  backend = "#{preview_id}.appA.pool.dev"
else
  backend = '0.0.0.0:8080'
end

return backend
