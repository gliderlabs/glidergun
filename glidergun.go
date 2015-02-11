package main

import (
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"fmt"
	"hash"
	"io"
	"os"

	"github.com/inconshreveable/go-update"
	"github.com/progrium/go-basher"
)

const (
	LatestVersionUrl      = "https://dl.gliderlabs.com/glidergun/latest/version.txt"
	LatestDownloadUrlBase = "https://dl.gliderlabs.com/glidergun/latest/"
)

var Version string

func fatal(msg string) {
	println("!!", msg)
	os.Exit(2)
}

func Selfupdate(args []string) {
	up := update.New()
	err := up.CanUpdate()
	if err != nil {
		fatal("Can't update because: '" + err.Error() + "'. Try as root?")
	}
	fatal(args[0] + " " + args[1])
	//err, errRecover := up.FromUrl("https://example.com/new/hosts")
}

func Checksum(args []string) {
	if len(args) < 1 {
		fatal("No algorithm specified")
	}
	var h hash.Hash
	switch args[0] {
	case "md5":
		h = md5.New()
	case "sha1":
		h = sha1.New()
	case "sha256":
		h = sha256.New()
	default:
		fatal("Algorithm '" + args[0] + "' is unsupported")
	}
	io.Copy(h, os.Stdin)
	fmt.Printf("%x\n", h.Sum(nil))
}

func main() {
	os.Setenv("GUN_VERSION", Version)
	basher.Application(map[string]func([]string){
		"checksum":   Checksum,
		"selfupdate": Selfupdate,
	}, []string{
		"include/fn.bash",
		"include/cmd.bash",
		"include/module.bash",
		"include/env.bash",
		"include/gun.bash",
		"include/deps.bash",
		"include/color.bash",
	}, Asset, true)
}
