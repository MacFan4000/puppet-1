node 'bots2002.fossbots.org' {
  include role::botserver
}
node 'tools2002.fossbots.org' {
  include role::toolserver
  include ::icinga2::master
}
node 'db2002.fossbots.org' {
  include role::dbserver
}
node /^bots[34]001\.fossbots\.org$/ {
  include role::botserver
}
node /^tools[34]001\.fossbots\.org$/ {
  include role::toolserver
  include ::icinga2::node
}
node /^db[34]001\.fossbots\.org$/ {
  include role::dbserver
}

