# Temporary place for utility functions

parallel() {
	declare cmd="$@"
	declare -a pids
	for line in $(cat); do
		eval "${cmd//\{\}/$line} &"
		pids+=($!)
	done
	local failed=$((0))
	for pid in ${pids[@]}; do
		if ! wait $pid; then
			failed=$((failed + 1))
		fi
	done
	return $((failed))
}

ssh-cmd() {
	echo "ssh -A $SSH_OPTS $@"
}
