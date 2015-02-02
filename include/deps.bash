# Simple binary dependency management

declare DEPS_REPO="${DEPS_REPO:-https://raw.githubusercontent.com/gliderlabs/glidergun-rack/master/index}"

deps-init() {
	export PATH="$(deps-dir)/bin:$PATH"
}

deps-dir() {
	echo "${GUN_ROOT:?}/.gun" # hmm, glidergun specific...
}

deps-require() {
	declare name="$1" version="${2:-latest}"
	deps-check "$name" "$version" && return
	echo "* Dependency required, installing $name $version ..."
	deps-install "$name" "$version"
}

deps-check() {
	declare name="$1" version="${2:-latest}"
	[[ -f "$(deps-dir)/bin/$name" ]]
}

deps-install() {
	declare name="$1" version="${2:-latest}"
	local tag index tmpfile dep filename extension install
	mkdir -p "$(deps-dir)/bin"
	index=$(curl -s "$DEPS_REPO/$name")
	tag="$(uname -s)$(uname -m | grep -s 64 > /dev/null && echo amd64 || echo 386)"
	if ! dep="$(echo "$index" | grep -i -e "^$version $tag " -e "^$version * ")"; then
		echo "!! Dependency not in index: $name $version"
		exit 2
	fi
	IFS=' ' read v t url checksum <<< "$dep"
	tmpfile="/tmp/$name" # TODO: real temp file
	curl -s $url > "$tmpfile"
	if ! [[ "$(cat "$tmpfile" | md5)" = "$checksum" ]]; then
		echo "!! Dependency checksum failed: $name $version $checksum"
		exit 2
	fi
	cd /tmp # TODO: cd to real tempfile dir
	filename="$(basename "$url")"
	extension="${filename##*.}"
	case "$extension" in
		zip) unzip "$tmpfile" > /dev/null;;
		tgz|tar.gz) tar -zxf "$tmpfile" > /dev/null;;
	esac
	install="$(echo "$index" | grep "^# install: " || true)"
	if [[ "$install" ]]; then
		IFS=':' read _ script <<< "$install"
		export PREFIX="$(deps-dir)"
		eval "$script" > /dev/null
		unset PREFIX
		rm -rf "$tmpfile"
	else
		mv "$tmpfile" "$(deps-dir)/bin"
	fi
	cd - > /dev/null
	deps-check "$name" "$version"
}
