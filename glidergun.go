package main

import (
	"os"

	"github.com/progrium/go-basher"
)

var Version string

func main() {
	os.Setenv("GUN_VERSION", Version)
	basher.Application(map[string]func([]string){}, []string{
		"include/fn.bash",
		"include/cmd.bash",
		"include/module.bash",
		"include/env.bash",
		"include/gun.bash",
		"include/deps.bash",
		"include/color.bash",
	}, Asset, true)
}
