package main

import (
	"archive/tar"
	"bytes"
	"compress/gzip"
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"hash"
	"io"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/inconshreveable/go-update"
	"github.com/progrium/go-basher"
)

const (
	LatestDownloadUrl = "https://dl.gliderlabs.com/glidergun/latest/%s.tgz"
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
	checksumExpected, err := hex.DecodeString(args[1])
	if err != nil {
		fatal(err.Error())
	}
	url := fmt.Sprintf(LatestDownloadUrl, args[0])
	fmt.Printf("Downloading %v ...\n", url)
	resp, err := http.Get(url)
	if err != nil {
		fatal(err.Error())
	}
	defer resp.Body.Close()
	buf := new(bytes.Buffer)
	data, err := ioutil.ReadAll(io.TeeReader(resp.Body, buf))
	if err != nil {
		fatal(err.Error())
	}
	checksum := sha256.New().Sum(data)
	if bytes.Equal(checksum, checksumExpected) {
		fatal("Checksum failed. Got: " + fmt.Sprintf("%x", checksum))
	}
	z, err := gzip.NewReader(buf)
	if err != nil {
		fatal(err.Error())
	}
	defer z.Close()
	t := tar.NewReader(z)
	hdr, err := t.Next()
	if err != nil {
		fatal(err.Error())
	}
	if hdr.Name != "gun" {
		fatal("glidergun binary not found in downloaded tarball")
	}
	err, errRecover := up.FromStream(t)
	if err != nil {
		fmt.Printf("Update failed: %v\n", err)
		if errRecover != nil {
			fmt.Printf("Failed to recover bad update: %v!\n", errRecover)
			fmt.Printf("Program exectuable may be missing!\n")
		}
		os.Exit(2)
	}
	fmt.Println("Updated.")
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
		"src/fn.bash",
		"src/cmd.bash",
		"src/env.bash",
		"src/gun.bash",
		"src/module.bash",
		"src/deps.bash",
		"src/color.bash",
	}, Asset, true)
}
