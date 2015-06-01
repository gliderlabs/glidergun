
readonly latest_version_url="https://dl.gliderlabs.com/glidergun/latest/version.txt"
readonly latest_checksum_url="https://dl.gliderlabs.com/glidergun/latest/%s.tgz.sha256"

declare GUN_MODULE_DIR="${GUN_MODULE_DIR:-cmds}" # deprecated
declare GUN_PATH="${GUN_PATH:-"$GUN_MODULE_DIR"}"
declare GUN_DIR="${GUN_DIR:-.gun}"

gun-init() {
	declare desc="Initialize a glidergun project directory"
	touch Gunfile
	if [[ -f .gitignore ]]; then
		printf "\n.gun\nGunfile.*\n" >> .gitignore
	fi
}

gun-version() {
	declare desc="Display version of glidergun"
	local latest="$(curl -s $latest_version_url)"
	if [[ "$GUN_VERSION" == "$latest" ]]; then
		latest=""
	else
		latest=" (latest: $latest)"
	fi
	echo "glidergun $GUN_VERSION$latest"
}

gun-update() {
	declare desc="Self-update glidergun to latest version"
	if [[ "$GUN_VERSION" == "$(curl --fail -s $latest_version_url)" ]]; then
		echo "glidergun is already up-to-date!"
		exit
	fi
	local platform checksum
	platform="$(uname -sm | tr " " "_")"
	checksum="$(curl --fail -s $(printf "$latest_checksum_url" "$platform"))"
	# calls back into go executable
	selfupdate "$platform" "$checksum"
}

gun-find-root() {
	local path="$PWD"
	while [[ "$path" != "" && ! -f "$path/Gunfile" ]]; do
    path="${path%/*}"
  done
	if [[ -f "$path/Gunfile" ]]; then
  	GUN_ROOT="$path"
  fi

  if [[ -d "$GUN_ROOT" ]]; then
  	cd $GUN_ROOT
		mkdir -p $GUN_DIR
  fi
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	color-init
	gun-find-root

	if [[ "$GUN_ROOT" ]]; then
		deps-init
		module-load "Gunfile"
		if [[ -f "Gunfile.$1" ]]; then
			module-load "Gunfile.$1"
			GUN_PROFILE="$1"
			shift
		elif [[ "$GUN_DEFAULT_PROFILE" && -f "Gunfile.$GUN_DEFAULT_PROFILE" ]]; then
			module-load "Gunfile.$GUN_DEFAULT_PROFILE"
			echo "* Using default profile $GUN_DEFAULT_PROFILE" | >&2 yellow
			GUN_PROFILE="$GUN_DEFAULT_PROFILE"
		fi
		module-load-remote
		local gun_module_paths
		IFS=':' read -ra gun_module_paths <<< "$GUN_PATH"
		for path in "${gun_module_paths[@]}"; do
			module-load-dir "$path"
		done
		cmd-export env-show :env
		cmd-export fn-call ::
	else
		cmd-export gun-init init
	fi

	cmd-export cmd-help :help
	cmd-export module-get :get
	cmd-export gun-version :version
	cmd-export gun-update :update

	if [[ "${!#}" == "-h" || "${!#}" == "--help" ]]; then
		local args=("$@")
		unset args[${#args[@]}-1]
		cmd-ns "" :help "${args[@]}"
	elif [[ "${!#}" == "-t" || "${!#}" == "--trace" ]]; then
		local args=("$@")
		unset args[${#args[@]}-1]
		set -x
		cmd-ns "" "${args[@]}"
	else
		cmd-ns "" "$@"
	fi
}
