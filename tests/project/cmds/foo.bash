

init() {
	cmd-export-ns foo "Foo namespace"
	cmd-export foo-hello
	env-import AWS_ACCESS_KEY_ID ""
}

foo-hello() {
	echo "Hello from foo"
}
