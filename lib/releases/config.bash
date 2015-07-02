# Release config commands
# WARNING: work in progress

init() {
	cmd-export-ns config "Manage service config"
	cmd-export config-get
	cmd-export config-set
	cmd-export config-unset
	cmd-export config-edit
}

config-edit() {
	declare desc="Edit service config in Consul UI (OS X)"
	declare service="$1"
	consul-open "/dc1/kv/${EC2_VPC:?}/config/${service:?}/"
}

config-get() {
	declare desc="Get service config"
	declare service="$1" key="$2"
	if [[ "$key" ]]; then
		consul-get "${EC2_VPC:?}/config/${service:?}/${key:?}"
	else
		consul-export "${EC2_VPC:?}/config/${service:?}"
	fi
}

config-set() {
	declare desc="Set service config"
	declare service="$1" key="$2" value="$3"
	consul-set "${EC2_VPC:?}/config/${service:?}/${key:?}" "$value"
}

config-unset() {
	declare desc="Unset service config"
	declare service="$1" key="$2"
	consul-del "${EC2_VPC:?}/config/${service:?}/${key:?}"
}
