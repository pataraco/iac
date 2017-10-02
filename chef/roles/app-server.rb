name "app-server"
description "create an Node.js Server"

run_list(
  "recipe[hostname]",
  "recipe[app-server]",
  "recipe[filebeat]"
)
