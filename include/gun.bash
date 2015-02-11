
readonly latest_version_url="https://dl.gliderlabs.com/glidergun/latest/version.txt"
readonly latest_checksum_url="https://dl.gliderlabs.com/glidergun/latest/%s/glidergun.tgz.sha256"

declare GUN_MODULE_DIR="${GUN_MODULE_DIR:-cmds}"

gun-init() {
	declare desc="Initialize a glidergun project directory"
	mkdir .gun
	echo "*" > .gun/.gitignore
	echo "!.gitignore" >> .gun/.gitignore
}

gun-version() {
	declare desc="Display version of glidergun"
	echo "glidergun $GUN_VERSION"
}

gun-update() {
	declare desc="Self-update glidergun to latest version"
	if [[ "$GUN_VERSION" == "$(curl --fail -s $latest_version_url)" ]]; then
		echo "glidergun is already up-to-date!"
		exit
	fi
	local platform="$(uname -sm | tr " " "_")"
	# calls back into go executable
	selfupdate "$platform" "$(curl --fail -s $(printf $latest_checksum_url $platform))"
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
			local builtins=(init version help selfupdate)
			if ! [[ ${builtins[*]} =~ "$1" ]]; then
				echo "* Unable to load profile $1" | yellow
			fi
		fi
	fi

	cmd-export gun-init init
	cmd-export cmd-help help
	cmd-export gun-version version
	cmd-export gun-update update
	
	cmd-ns "" "$@"
}