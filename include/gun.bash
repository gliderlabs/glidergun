
declare GUN_MODULE_DIR="${GUN_MODULE_DIR:-cmds}"
declare GUN_ROOT

gun-init() {
	mkdir .gun
	if [[ -f .gitignore ]]; then
		if ! grep '^.gun$' .gitignore > /dev/null; then
			echo ".gun" >> .gitignore
		fi
	fi
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
	declare profile="$1"
	if [[ -f ".gun_$profile" ]]; then
		source ".gun_$profile"
		return
	else
		if [[ "$GUN_DEFAULT_PROFILE" && -f ".gun_$GUN_DEFAULT_PROFILE" ]]; then
			source ".gun_$GUN_DEFAULT_PROFILE"
			echo "* Using default profile $GUN_DEFAULT_PROFILE" 
			return
		fi
	fi
	return 1
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	gun-find-root	
	
	if [[ "$GUN_ROOT" ]]; then
		deps-init
		if gun-load-profile "$1"; then
			shift
		fi
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