name "elk-server"
description "create a log server (ELK Stack)"

run_list(
  "recipe[hostname]",
  "recipe[elk-server]"
)
