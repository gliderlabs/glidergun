
init() {
	cmd-export-ns bar "Bar namespace"
	cmd-export bar-hello
	#deps-require jq 1.4
	#module-require github.com/gliderlabs/glidergun/lib/aws
}

bar-hello() {
	echo "Hello from bar"
}
