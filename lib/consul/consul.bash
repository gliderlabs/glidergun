# Commands for working with Consul KV

init() {
	env-import CONSUL_URL
	env-import CONSUL_AUTH ""

	cmd-export-ns consul "Consul key-value operations"
	cmd-export consul-import
	cmd-export consul-export
	cmd-export consul-get
	cmd-export consul-encoded
	cmd-export consul-set
	cmd-export consul-ls
	cmd-export consul-del
	cmd-export consul-info
	cmd-export consul-open
	cmd-export consul-service
}

consul-cmd() {
	declare path="$1"; shift
	local cmd="curl"
	if [[ "$CONSUL_AUTH" ]]; then
		cmd="curl -u $CONSUL_AUTH"
	fi
	$cmd --fail -Ss "${CONSUL_URL:?}$path" "$@"
}

consul-info() {
	declare desc="Show all metadata for key"
	declare key="${1/#\//}"
	consul-cmd "/v1/kv/$key" \
		| jq -r .[]
}

consul-get() {
	declare desc="Get the value of key"
	declare key="${1/#\//}"
	consul-encoded "$key" \
		| base64 -d \
		| echo "$(cat)"
}

consul-encoded() {
	declare desc="Get the base64 encoded value of key"
	declare key="${1/#\//}"
	consul-cmd "/v1/kv/$key" \
		| jq -r .[].Value
}

consul-set() {
	declare desc="Set the value of key"
	declare key="${1/#\//}" value="$2"
	consul-cmd "/v1/kv/$key" -X PUT -d "$value" > /dev/null
}

consul-del() {
	declare desc="Delete key"
	declare key="${1/#\//}"
	consul-cmd "/v1/kv/$key" -X DELETE > /dev/null
}

consul-ls() {
	declare desc="List keys under key"
	declare key="${1/#\//}"
	if [[ ! "$key" ]]; then
		consul-cmd "/v1/kv/?keys&separator=/" \
			| jq -r .[] \
			| sed 's|/$||'
	else
		consul-cmd "/v1/kv/$key/?keys&separator=/" \
			| jq -r .[] \
			| sed "s|$key/||" \
			| grep -v ^$ \
			| sed 's|/$||'
	fi
}

consul-export() {
	declare desc="Export values to Bash variables"
	declare key="${1/#\//}"
	consul-cmd "/v1/kv/$key/?recurse" \
		| jq -r '.[] | [.Key, .Value] | join(" ")' \
		| sed "s|$key/||" \
		| grep -v '^\s*$' \
		| \
		while read key value; do
			key="${key^^}"
			key="${key//\//_}"
			printf "$key=%s\n" "$(echo "$value" | base64 -d)"
		done
}

consul-import() {
	declare desc="Import Bash variables under key"
	declare key="${1/#\//}"
	input="$(cat)"
	eval "$input" || exit 2
	IFS=$'\n'
	for line in $input; do
		IFS='=' read k v <<< "$line"
		IFS=' ' consul-cmd "/v1/kv/${key:?}/$k" -X PUT -d "${!k}" > /dev/null
	done
	unset IFS
}

consul-open() {
	declare desc="Opens Consul UI in browser (OS X only)"
	declare page="$1"
	local scheme url
	IFS=':' read scheme url <<< "$CONSUL_URL"
	open "$scheme://${CONSUL_AUTH}@${url##//}#$page"
}

consul-service() {
	declare service="$1"
	consul-cmd "/v1/health/service/$service?passing"
}
