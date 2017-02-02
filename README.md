# glidergun

[![CircleCI](https://img.shields.io/circleci/project/gliderlabs/glidergun/release.svg)](https://circleci.com/gh/gliderlabs/glidergun)
[![IRC Channel](https://img.shields.io/badge/irc-%23gliderlabs-blue.svg)](https://kiwiirc.com/client/irc.freenode.net/#gliderlabs)

glidergun allows writing write-once-run-anywhere cli tools using  [Go](https://golang.org) and Bash(http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html).

# Install

    $ curl https://dl.gliderlabs.com/gh/glidergun/latest/$(uname -sm|tr \  _).tgz \
      | tar -zxC /usr/local/bin


# How it works 

Glidergun acts as a framework runtime using its `gun` (/usr/local/bin/gun).
Cli-tools typically consist of :

   mytool/Gunfile             # specify environment variables here
   mytool/cmds                # folder with scripts
   
See example glidergun application [here](https://github.com/lalyos/glidergun-test))

# Features:

* intermixing Go & Bash language using [go-basher](https://github.com/progrium/go-basher). 
* dependency management (`deps-require jq 1.4` e.g.)
* module system
* support for exposing bash functions as subcommands

## Upgrading

	$ gun :update

<img src="https://ga-beacon.appspot.com/UA-58928488-2/glidergun/readme?pixel" />
