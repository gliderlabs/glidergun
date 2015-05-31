
setup() {
  cd "$(dirname "${BASH_SOURCE[0]}")/project"
  gun &> /dev/null
}
setup

T_hello-cmd() {
  result="$(gun hello)"
  [[ "$result" == "Hello!" ]]
}

T_foo-namespace-cmd() {
  result="$(gun foo hello)"
  [[ "$result" == "Hello from foo" ]]
}

T_bar-namespace-cmd() {
  result="$(gun bar hello)"
  [[ "$result" == "Hello from bar" ]]
}

T_foo-env-import() {
  [[ "$(gun env | grep AWS_ACCESS_KEY_ID)" ]]
}

T_prod-profile() {
  result="$(gun prod env)"
  [[ "$result" == "AWS_ACCESS_KEY_ID = prod-access-key" ]]
}

T_stage-profile() {
  result="$(gun stage env)"
  [[ "$result" == "AWS_ACCESS_KEY_ID = staging-access-key" ]]
}
