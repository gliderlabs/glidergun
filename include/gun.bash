
declare GUN_MODULE_DIR="${GUN_MODULE_DIR:-cmds}"

gun-init() {
	declare desc="Initialize a glidergun project directory"
	mkdir .gun
	if [[ -f .gitignore ]]; then
		if ! grep '^.gun$' .gitignore > /dev/null; then
			echo ".gun" >> .gitignore
		fi
	fi
}

gun-version() {
	declare desc="Display version of glidergun"
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

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	color-init
	gun-find-root
	
	if [[ "$GUN_ROOT" ]]; then
		deps-init
		if [[ -f ".gun_$1" ]]; then
			source ".gun_$1"
			GUN_PROFILE="$1"
			shift
		elif [[ "$GUN_DEFAULT_PROFILE" && -f ".gun_$GUN_DEFAULT_PROFILE" ]]; then
			source ".gun_$GUN_DEFAULT_PROFILE"
			echo "* Using default profile $GUN_DEFAULT_PROFILE" | yellow
			GUN_PROFILE="$GUN_DEFAULT_PROFILE"
		fi
		if [[ "$GUN_PROFILE" ]]; then
			if [[ -d "$GUN_MODULE_DIR" ]]; then
				module-load-dir "$GUN_MODULE_DIR"
			fi
			cmd-export env-show env
			cmd-export fn-call fn
		else
			if [[ "$1" != "init" && "$1" != "version" && "$1" != "help" ]]; then
				echo "* Unable to load profile $1" | yellow
			fi
		fi
	fi

	cmd-export gun-init init
	cmd-export gun-version version

	cmd-ns "" "$@"
}