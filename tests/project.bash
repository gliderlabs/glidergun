
export GUN="${GUN:-gun}"

setup() {
  cd "$(dirname "${BASH_SOURCE[0]}")/project"
  $GUN &> /dev/null
}
setup

T_hello-cmd() {
  result="$($GUN hello)"
  [[ "$result" == "Hello!" ]]
}

T_foo-namespace-cmd() {
  result="$($GUN foo hello)"
  [[ "$result" == "Hello from foo" ]]
}

T_bar-namespace-cmd() {
  result="$($GUN bar hello)"
  [[ "$result" == "Hello from bar" ]]
}

T_foo-env-import() {
  [[ "$($GUN :env | grep AWS_ACCESS_KEY_ID)" ]]
}

T_prod-profile() {
  result="$($GUN prod :env)"
  [[ "$result" == "AWS_ACCESS_KEY_ID = prod-access-key" ]]
}

T_stage-profile() {
  result="$($GUN stage :env)"
  [[ "$result" == "AWS_ACCESS_KEY_ID = staging-access-key" ]]
}

T_aliased-cmd() {
  result="$($GUN aliased)"
  [[ "$result" == "aliased" ]]
}

T_autoexported-cmd() {
  result="$($GUN exported)"
  [[ "$result" == "exported" ]]
}

T_autoexported-cmd-with-dash() {
  result="$($GUN lazy-command)"
  [[ "$result" == "exported too" ]]
}

