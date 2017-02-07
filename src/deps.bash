# Simple binary dependency management

declare DEPS_REPO="${DEPS_REPO:-https://raw.githubusercontent.com/gliderlabs/glidergun-rack/master/index}"

deps-init() {
	export PATH="$GUN_DIR/bin:$PATH"
}

deps-require() {
	declare name="$1" version="${2:-latest}"
	deps-check "$name" "$version" && return
	echo "* Dependency required, installing $name $version ..." | >&2 yellow
	deps-install "$name" "$version"
}

deps-check() {
	declare name="$1" version="${2:-latest}"
	[[ -e "$GUN_DIR/bin/$name" ]]
}

deps-install() {
	declare name="$1" version="${2:-latest}"
	local tag index gundir bindir tmpdir tmpfile dep filename extension install
	gundir="$(cd $GUN_DIR; pwd)"
	bindir="$gundir/bin"
	mkdir -p "$bindir"
	index=$(curl -s "$DEPS_REPO/$name")
	tag="$(uname -s)_$(uname -m | grep -s 64 > /dev/null && echo amd64 || echo 386)"
	if ! dep="$(echo "$index" | grep -i -e "^$version $tag " -e "^$version \* ")"; then
		echo "!! Dependency not in index: $name $version" | >&2 red
		exit 2
	fi
	IFS=' ' read v t url checksum <<< "$dep"
	tmpdir="$gundir/tmp"
	mkdir -p "$tmpdir"
	tmpfile="${tmpdir:?}/$name.tmp"
	curl -Ls $url > "$tmpfile"
	if [[ "$checksum" ]]; then
		if ! [[ "$(cat "$tmpfile" | checksum md5)" = "$checksum" ]]; then
			echo "!! Dependency checksum failed: $name $version $checksum" | >&2 red
			exit 2
		fi
	fi
	cd "$tmpdir"
	filename="$(basename "$url")"
	extension="${filename#*.}"
	case "$extension" in
		zip) unzip "$tmpfile" > /dev/null;;
		tgz|tar.gz) tar -zxf "$tmpfile" > /dev/null;;
	esac
	install="$(echo "$index" | grep "^# install: " || true)"
	if [[ "$install" ]]; then
		IFS=':' read _ script <<< "$install"
		export PREFIX="$gundir"
		eval "$script" > /dev/null
		unset PREFIX
	else
		chmod +x "$tmpfile"
		mv "$tmpfile" "$bindir/$name"
	fi
	cd - > /dev/null
	rm -rf "${tmpdir:?}"
	deps-check "$name" "$version"
}
