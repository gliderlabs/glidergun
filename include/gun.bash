
declare GUN_MODULE_DIR="${GUN_MODULE_DIR:-cmds}"
declare GUN_ROOT

gun-init() {
	mkdir .gun
	# TODO: add to .gitignore if exists and not in it
}

gun-version() {
	echo "glidergun $GUN_VERSION"
}

gun-find-root() {
	local path="$PWD"
  	while [[ "$path" != "" && ! -d "$path/.gun" ]]; do
    	path="${path%/*}"
  	done
  	if [[ -d "$path/.gun" ]]; then
  		GUN_ROOT="$path"
  		cd "$GUN_ROOT"
  	fi
}

gun-load-profile() {
	if [[ -f ".gun_$1" ]]; then
		source ".gun_$1"
		shift
	else
		if [[ "$GUN_DEFAULT_PROFILE" && -f ".gun_$GUN_DEFAULT_PROFILE" ]]; then
			source ".gun_$GUN_DEFAULT_PROFILE"
			echo "* Using default profile $GUN_DEFAULT_PROFILE" 
		fi
	fi
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	gun-find-root	
	
	if [[ "$GUN_ROOT" ]]; then
		deps-init
		gun-load-profile
		if [[ -d "$GUN_MODULE_DIR" ]]; then
			module-load-dir "$GUN_MODULE_DIR"
		fi
	fi

	cmd-export gun-init init
	cmd-export gun-version version
	cmd-export env-show env
	cmd-export fn-call fn

	cmd-ns "" "$@"
}