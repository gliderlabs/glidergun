# EC2 in VPC helpers and commands

SSH_HOST=""
SSH_OPTS="${SSH_OPTS:--o PasswordAuthentication=no -o StrictHostKeyChecking=no}"

init() {
	env-import EC2_VPC ""
	env-import SSH_USER "core"
	env-import SSH_BASTION_USER "$SSH_USER"

	cmd-export-ns ec2 "EC2 instance management"
	cmd-export ec2-list
	cmd-export ec2-info
	cmd-export ec2-ssh
	cmd-export ec2-pssh
	cmd-export ec2-rsync
	cmd-export ec2-prsync
	cmd-export ec2-ip
	cmd-export ec2-tag
	cmd-export ec2-untag
	cmd-export ec2-vpcs
	cmd-export ec2-terminate
}

ec2-info() {
	declare desc="Instance info by name or ID"
	declare instance="$1"
	if [[ "${instance:0:2}" != "i-" ]]; then
		instance="$(ec2-id instance $instance)"
	fi
	aws-json ec2 describe-instances --filters "Name=instance-id,Values=$instance" \
		| jq '.Reservations[].Instances[] as $instance |
  			$instance.Tags[] | select(.Key == "Name") | .Value as $name | {
  				name: $name,
  				labels: [$instance.Tags[] | select(.Value == null) | .Key],
  				state: $instance.State.Name,
    			private_ip: $instance.PrivateIpAddress,
    			public_ip: $instance.PublicIpAddress,
    			instance_id: $instance.InstanceId,
    			subnet_id: $instance.SubnetId }'
}

ec2-ip() {
	declare desc="Public or private IP by ID or tag"
	declare type="$1" key="$2" value="$3"
	local filter vpc_id
	if [[ "${key:0:2}" = "i-" ]]; then
		filter="Name=instance-id,Values=$key"
	else
		filter="Name=tag:$key,Values=$value"
	fi
	vpc_id="$(ec2-id vpc ${EC2_VPC:?})"
	aws-json ec2 describe-instances --filters "Name=vpc-id,Values=$vpc_id" "$filter" \
		| jq -r ".Reservations[0].Instances[0].${type^}IpAddress // empty"
}

ec2-setup-ssh-bastion() {
	declare instance="$1"
	local bastion_ip
	bastion_ip="$(ec2-ip public bastion)"
	if [[ "$bastion_ip" ]]; then
		SSH_OPTS="$SSH_OPTS -o \"ProxyCommand=ssh -W %h:%p $BASTION_USER@$bastion_ip\""
		SSH_HOST="$(ec2-ip private $instance)"
	fi
}

ec2-ssh() {
	declare desc="SSH to instance by name or ID"
	declare instance="${1:?}"; shift
	if [[ "${instance:0:2}" != "i-" ]]; then
		instance="$(ec2-id instance $instance)"
	fi
	ec2-setup-ssh-bastion "$instance"
	SSH_HOST="${SSH_HOST:-$(ec2-ip public $instance)}"
	local cmd
	if [[ "$1" ]]; then
		cmd="set -eo pipefail; $@"
	fi
	eval $(ssh-cmd "$SSH_USER@${SSH_HOST:?}") -- "$(printf '%q' "$cmd")"
}

ec2-pssh() {
	declare desc="Parallel SSH to instances by label"
	declare label="$1"; shift
	ec2-list "${label:?}" \
		| jq -r .[].name \
		| parallel "ec2-ssh {} $(printf '%q ' "$@") | sed 's/^/{}: /'"
}

ec2-rsync() {
	declare desc="Rsync files to instance by name or ID"
	declare instance="${1:?}" path="$2" remote="$3"
	if [[ "${instance:0:2}" != "i-" ]]; then
		instance="$(ec2-id instance $instance)"
	fi
	ec2-setup-ssh-bastion "$instance"
	SSH_HOST="${SSH_HOST:-$(ec2-ip public $instance)}"
	rsync -rzue "$(ssh-cmd)" \
		--rsync-path "mkdir -p $(dirname $remote) && rsync" \
		"${path:?}" "$SSH_USER@${SSH_HOST:?}:${remote:?}"
}

ec2-prsync() {
	declare desc="Parallel rsync files to instances by label"
	declare label="$1" path="$2" remote="$3"
	ec2-list "${label:?}" \
		| jq -r .[].name \
		| parallel "ec2-rsync {} $path $remote | sed 's/^/{}: /'"
}

ec2-list() {
	declare desc="List instances for a VPC"
	declare label="$1"
	local vpc_id label_filter
	vpc_id="$(ec2-id vpc ${EC2_VPC:?})"
	if [[ "$label" ]]; then
		label_filter="Name=tag:$label,Values="
	fi
	aws-json ec2 describe-instances --filters "Name=vpc-id,Values=${vpc_id:?}" "$label_filter" \
		| jq '[.Reservations[].Instances[] as $instance |
  			$instance.Tags[] | select(.Key == "Name") | .Value as $name | {
  				name: $name,
  				labels: [$instance.Tags[] | select(.Value == null) | .Key],
    			private_ip: $instance.PrivateIpAddress,
    			instance_id: $instance.InstanceId,
    			subnet_id: $instance.SubnetId }]'
}

ec2-factory() {
	declare id_selector="$1"; shift
	aws-json ec2 $@ | jq -e -r "$id_selector"
}

ec2-tag() {
	declare desc="Tag an EC2 resource"
	declare resource="$1" key="$2" value="$3"
	aws-json ec2 create-tags \
		--resources "${resource:?}" \
		--tags "Key=${key:?},Value=${value}" > /dev/null
}

ec2-untag() {
	declare desc="Untag an EC2 resource"
	declare resource="$1" key="$2"
	aws-json ec2 delete-tags \
		--resources "${resource:?}" \
		--tags "Key=${key:?}" > /dev/null
}

ec2-id() {
	declare type="$1" name="$2"
	local json_type filter_name extra_filter
	filter_name="tag:Name"
	json_type="$(titleize ${type//-/ })"
	json_type="${json_type// /}"
	json_collection="${json_type}s"
	if [[ "$type" = "instance" ]]; then
		json_collection="Reservations[0].$json_collection"
		extra_filter="Name=instance-state-name,Values=running"
	fi
	if [[ "$type" = "security-group" ]]; then
		filter_name="group-name"
		json_type="Group"
	fi
	aws-json ec2 "describe-${type}s" \
		--filters "$extra_filter" "Name=$filter_name,Values=$name" \
		| jq -e -r ".${json_collection}[0].${json_type}Id"
}

ec2-terminate() {
	declare desc="Terminate instance by ID"
	declare id="$1"
	aws-json ec2 terminate-instances --instance-ids "${id:?}"
}

ec2-vpcs() {
	declare desc="List VPCs"
	aws-json ec2 describe-vpcs | jq '.Vpcs[] as $vpc |
  		$vpc.Tags[] | select(.Key == "Name") | .Value as $name | {
  			name: $name,
  			id: $vpc.VpcId }'
}
