//go:generate go-extpoints
package main

import (
	"os"

	"github.com/gliderlabs/glidergun/extpoints"
	_ "github.com/lalyos/glidergun-ext-browser"
	"github.com/progrium/go-basher"
)

var Version string

func getAllCommands() map[string]func([]string) {
	ret := map[string]func([]string){}

	var cmds = extpoints.CommandProviders
	for _, provider := range cmds.All() {
		for cmd, fn := range provider.Commands() {
			ret[cmd] = fn
		}
	}
	return ret
}

func main() {
	os.Setenv("GUN_VERSION", Version)
	basher.Application(
		getAllCommands(),
		[]string{
			"include/fn.bash",
			"include/cmd.bash",
			"include/module.bash",
			"include/env.bash",
			"include/gun.bash",
			"include/deps.bash",
			"include/color.bash",
		}, Asset, true)
}
