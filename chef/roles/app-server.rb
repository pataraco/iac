name "app-server"
description "create an Apache Web Server"

run_list(
  "recipe[hostname]",
  "recipe[app-server]",
  "recipe[filebeat]"
)
