
declare GUN_REMOTE_MODULES="${GUN_REMOTE_MODULES:-$GUN_DIR/modules}"

module-load() {
	declare filename="$1"
	source "$filename"
	if grep '^init()' "$filename" > /dev/null; then
		init
	fi

    module-auto-export $filename
}

module-auto-export() {
    declare filename="$1"
    
    local autoprefix="cmd:"
    while read cmd; do
        cmd-export "cmd:$cmd" "$cmd"
    done < <(
        sed -n "s/^cmd:\([^(]*\)(.*/\1/p"  "$filename"
    )

}

module-load-dir() {
	declare dir="$1"
	shopt -s nullglob
	for path in $dir/*.bash; do
		module-load "$path"
	done
	shopt -u nullglob
}

module-load-remote() {
	shopt -s nullglob
	for module in $GUN_REMOTE_MODULES/**/*.bash; do
		module-load "$module"
	done
	shopt -u nullglob
}

module-require() {
	declare url="$1" as="$2"
	module-check "$url" "$as" && return
	if [[ ! "$as" ]]; then
		as="$(basename ${url%%.git})"
	fi
	echo "* Module required, installing $as from $url ..." | >&2 yellow
	module-get "$url" "$as"
	module-load-dir "$GUN_REMOTE_MODULES/$as"
}

module-check() {
	declare url="$1" as="$2"
	: "${url:?}"
	if [[ ! "$as" ]]; then
		as="$(basename ${url%%.git})"
	fi
	[[ -d "$GUN_REMOTE_MODULES/$as" ]]
}

module-get() {
	declare desc="Install or update a remote module by URL"
	declare url="$1" as="$2"
	: "${url:?}"
	if [[ ! "$(which git)" ]]; then
		echo "!! git is required for fetching modules"| >&2 red
		exit 2
	fi
	if [[ ! "$url" =~ ^http ]]; then
		url="http://$url"
	fi
	if [[ ! "$as" ]]; then
		as="$(basename ${url%%.git})"
	fi
	local tmproot tmprepo scheme domain user repo path
	IFS="/" read scheme _ domain user repo path <<< "$url"
	tmproot="${GUN_DIR:?}/tmp"
	tmprepo="$tmproot/$domain/$user/$repo"
	mkdir -p "$tmprepo"
	git clone --quiet --depth 1 "$scheme//$domain/$user/$repo" "$tmprepo"
	rm -rf "${tmprepo:?}/.git"
	rm -rf "${GUN_REMOTE_MODULES:?}/$as"
	mkdir -p "$GUN_REMOTE_MODULES"
	mv "$tmprepo/$path" "$GUN_REMOTE_MODULES/$as"
	rm -rf "${tmproot:?}"
}
