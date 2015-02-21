

init() {
	cmd-export-ns foo "Foo namespace"
	cmd-export foo-hello
}

foo-hello() {
	echo "Hello from foo"
}
