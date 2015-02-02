
init() {
	env-export AWS_ACCESS_KEY_ID
	env-export AWS_SECRET_ACCESS_KEY
	deps-require aws
}

aws-json() {
	: ${AWS_ACCESS_KEY_ID:?} ${AWS_SECRET_ACCESS_KEY:?}
	aws --output json $@
}

aws-text() {
	: ${AWS_ACCESS_KEY_ID:?} ${AWS_SECRET_ACCESS_KEY:?}
	aws --output text $@
}