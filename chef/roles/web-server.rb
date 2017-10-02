name "web-server"
description "create an nginx Web Server"

run_list(
  "recipe[hostname]",
  "recipe[web-server]",
  "recipe[filebeat]"
)
