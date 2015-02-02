
declare -a _env

env-export() {
	declare var="$1"
	_env+=($var)
}

env-show() {
	for var in "${_env[@]}"; do
		echo "$var=${!var}"
	done
}