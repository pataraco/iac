name "db-server"
description "create a database server (MySQL)"

run_list(
  "recipe[hostname]",
  "recipe[mysql-server]",
  "recipe[filebeat]"
)
