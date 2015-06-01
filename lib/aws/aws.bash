# Shared AWS functions wrapping aws-cli

init() {
	env-import AWS_DEFAULT_REGION
	env-import AWS_ACCESS_KEY_ID
	env-import AWS_SECRET_ACCESS_KEY

	deps-require aws
	deps-require jq 1.4
}

aws-json() {
	aws --output json $@
}

aws-text() {
	aws --output text $@
}
