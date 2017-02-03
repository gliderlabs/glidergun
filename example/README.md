This tutorial tells how to use [glidergun](https://github.com/gliderlabs/glidergun).
We will discover all important glidergun features step-by-step.

## Install Glidergun

To install glidergun (gun for short):
```
$ curl -L https://github.com/gliderlabs/glidergun/releases/download/v0.1.0/glidergun_0.1.0_$(uname -sm|tr \  _).tgz \
    | tar -zxC /usr/local/bin
```
## Initialize a Glidergun project

Create a new empty directory and enter it.
```
mkdir /tmp/guntest
cd /tmp/guntest
```

gun will search for a file called `Gunfile` starting from $PWD and upwards.
If none found the `init` command will be available.

```
$ gun

Available commands:
  init                     Initialize a glidergun project directory
```

Use the `init` command to create an empty `Gunfile` which marks the directory as a valid gun project:
```
$ gun init
$ ls -la
-rw-r--r--   1 sillyname  wheel    0 Feb  3 09:26 Gunfile
```
## Write the first command

Lets say we want to create a tool for managing github teams. Gun will search the `cmds` directory for files with `*.bash` extension.

```
$ mkdir cmds
$ cat > cmds/github.bash <<EOF
init() {
    cmd-export gh-orgs
}

gh-orgs() {
    declare desc="Lists your GithHub organizations"

    echo "todo ..." | blue
}
EOF
```

We have 2 ordinary bash functions. As gun find *.bash files, it
will `source` them and call `init()`. We use `cmd-export` to expose
a function as a gun command. We use the `declare desc` to document the function. This docs is used by cmd-export.

The `| blue` at the end is also gun feature, it colors the output. For all colors see: [color.bash](https://github.com/gliderlabs/glidergun/blob/master/src/color.bash)

Let's give it a go:

```
$ gun

Available commands:
  gh-orgs                  Lists your GithHub organizations
  ...

$ gun gh-orgs
  todo ...
```

## Environment variables

Now lets use the github rest [ API](https://developer.github.com/v3/orgs/#list-your-organizations) to list your organizations. Change the gh-orgs function to:

```diff
gh-orgs() {
    declare desc="Lists your GithHub organizations"

-    echo "todo ..." | blue
+    curl -s \
+        -H "Authorization: Bearer $GITHUB_TOKEN" \
+        https://api.github.com/user/orgs
}
```

If you try now you will get a `Bad credentials` response, as
for github authorization, we need an oauth2 token. Lets declare
it in init() with `env-import`:

```diff
init() {
    cmd-export gh-orgs
+    env-import GITHUB_TOKEN
}
```

Now gun will complain about the missing env:
```
$ gun gh-orgs
!! Imported variable GITHUB_TOKEN must be set in profile or environment.
```

Go to https://github.com/settings/tokens to create one, and put in you `Gunfile`:

```
export GITHUB_TOKEN=0a12b34c5d6e789fg0123h4i56j789klm01n2op3
```

If you run gun again, it will successfully list your orgs.
```
$ gun gh-orgs
[
{
  "login": "gliderlabs",
  "id": 8484931,
  "url": "https://api.github.com/orgs/gliderlabs",
  "repos_url": "https://api.github.com/orgs/gliderlabs/repos",
  "events_url": "https://api.github.com/orgs/gliderlabs/events",
  "hooks_url": "https://api.github.com/orgs/gliderlabs/hooks",
  "issues_url": "https://api.github.com/orgs/gliderlabs/issues",
  "members_url": "https://api.github.com/orgs/gliderlabs/members{/member}",
  "public_members_url": "https://api.github.com/orgs/gliderlabs/public_members{/member}",
  "avatar_url": "https://avatars.githubusercontent.com/u/8484931?v=3",
  "description": ""
}
...
```

Its important to note, that gun forks a new bash process, and Gunfile is sourced only in that process.

## Env var with default

Its a good practice to set meaningful default values whenever possible. So lets introduce the `PAGE_SIZE`
env var. We bind it to github's [pagination](https://developer.github.com/v3/#pagination) functionality

```diff
init() {
    deps-require jq
    
    cmd-export gh-orgs
    env-import GITHUB_TOKEN
+    env-import PAGE_SIZE 5
}

gh-orgs() {
    declare desc="Lists your GithHub organizations"

    : ${GITHUB_TOKEN:? go to https://github.com/settings/tokens to create one}
    curl -s \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
-        https://api.github.com/user/orgs
+        https://api.github.com/user/orgs?per_page=$PAGE_SIZE
}
```

## List env vars

The `:env` command can be used to list all declared env vars with actual value:
```
$ gun :env
GITHUB_TOKEN = 0a12b34c5d6e789fg0123h4i56j789klm01n2op3
PAGE_SIZE    = 1
```

## External binary dependencies

Now we are getting closer, but there is to much output. Lets list only the organization's name.
Lets use [jq](https://stedolan.github.io/jq/), but you can take it granted the everybody has it.
`deps-require` comes to the rescue. It will make sure

```diff
init() {
+    deps-require jq 1.4
    cmd-export gh-orgs
    env-import GITHUB_TOKEN
    env-import PAGE_SIZE 5
}

gh-orgs() {
    declare desc="Lists your GithHub organizations"

    : ${GITHUB_TOKEN:? go to https://github.com/settings/tokens to create one}
    curl -s \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
-        https://api.github.com/user/orgs?per_page=$PAGE_SIZE
+        https://api.github.com/user/orgs?per_page=$PAGE_SIZE \
+          | jq ".[].login" -r

}
```

Dependencies are downloaded into `.gun/bin/` folder, and this dir is placed in the begining of the
forked bash process's PATH. So this way you can make sure you are using the correct version.

```
$ gun gh-orgs
* Dependency required, installing jq latest ...
lalyos-trainings
sequenceiq
gliderlabs
```

the [deps-require](https://github.com/gliderlabs/glidergun/blob/master/src/deps.bash) is a really

See the repository
https://github.com/gliderlabs/glidergun-rack/blob/master/index/jq

## Profiles

Sometimes you want to have multiple set of environment variables, like one `Gunfile` for
development and one for production. You can just add a postfix like: `Gunfile.dev`
or `Gunfile.prod`.

To determine which one is to use, there 2 ways. You can set the `GUN_DEFAULT_PROFILE`
```
$ export GUN_DEFAULT_PROFILE=dev
$ gun gh-orgs
* Using default profile dev
...
```

Or you can add an extra **first argument**, which will specify the actual profile, and than
cut of from the arg list (shift in bash terms)

```
$ gun dev gh-orgs
```

## Command namespaces

If you start to have a lot of commands it might make sense to group them together.
See an example in [ec2.bash](https://github.com/gliderlabs/glidergun/blob/master/lib/aws/ec2.bash#L11-L22)

```
init() {
	cmd-export-ns ec2 "EC2 instance management"
	cmd-export ec2-ip
	cmd-export ec2-info
	cmd-export ec2-list
}
```

When you list available root commands (gun without any commands), you get only the namsecpase listed.
If you specify a namespace insted of a command, you get the list of commands in that namespace:

```
$ gun

Available commands:
  ec2                      EC2 instance management

$ gun ec2
EC2 instance management

Available commands:
  info                     Instance info by name or ID
  ip                       Public or private IP by ID or tag
  list                     List instances for a VPC
...
```
## Using modules

Remote modules are github repositories contaiening gun scripts. For example if you want to use
all commands from this directory: [https://github.com/gliderlabs/glidergun/tree/master/lib/aws](https://github.com/gliderlabs/glidergun/tree/master/lib/aws)
You can refer to it by removing **https://** at the begining, and **tree/master/** from the middle:
```
gun :get github.com/gliderlabs/glidergun/lib/aws
```

## Troubleshooting

You can ask for help about any command by appending an `-h` to the end of the command.
```
$ gun gh-orgs -h
gh-orgs
  Lists your GithHub organizations

gh-orgs ()
{
    declare desc="Lists your GithHub organizations";
    curl -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user/orgs | jq ".[].login" -r
}
```

Or you can even trace the command by appending `-t`. It acts like adding a `set -x` into the bash script:
```
$ gun gh-orgs -t
+ cmd-ns '' gh-orgs
+ local ns=
+ shift
+ local cmd=gh-orgs
+ shift
+ local status=0
+ [[ -n exists ]]
+ gh-orgs
+ declare 'desc=Lists your GithHub organizations'
+ curl -s -H 'Authorization: Bearer 0a12b34c5d6e789fg0123h4i56j789klm01n2op3' https://api.github.com/user/orgs
+ jq '.[].login' -r
hortonworks
lalyos-trainings
sequenceiq
gliderlabs

```

## Calling non exported functions

Use the `::` meta-command.
```
gun :: non-exported-fn
```

## Custom dependency repo

If some dependency is missing from the original [glidergun-rack](https://github.com/gliderlabs/glidergun-rack/tree/master/index)
just fork the repo and a text file named by the needed dependency.

See an example sed dependency, for `docker-machine`
https://github.com/lalyos/glidergun-rack/blob/master/index/docker-machine

In order to use your fork, you have to set the `DEPS_REPO` env var in Gunfile:
```
export DEPS_REPO=https://raw.githubusercontent.com/lalyos/glidergun-rack/master/index
```

Actually hashcodes in rackfiles are optional, so for hacking around you can just leave them out.

## tldr;

There are some additional env vars you can change the default behaviour:
- GUN_PATH
- GUN_ROOT

### GUN_PATH

If you have some gun modules in your local file system, you can use a `:` separated list of those dirs.
```
export GUN_PATH=~/prj/gun-module-1:~/prj/gun-module-2:~/prj/gun-module-3
```
Now all 3 module's commands are available.

### GUN_ROOT

Normally you issue `gun` commands in a specific directory. But if you want to create globally usable gun command,
you can create a gun project let say at `~/.gunroot`, and use the folloing alias:

```
alias gun='GUN_ROOT=~/.gunroot /usr/local/bin/gun'
```
Now you can run gun command even in directories which are not `gun init`-ed. Meaning they, or any of they parent
dir doesn't contain a Gunfile.

