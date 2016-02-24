name "web-server"
description "create an Apache Web Server"

run_list(
  "recipe[hostname]",
  "recipe[web-server]",
  "recipe[filebeat]"
)
