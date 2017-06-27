## Docker git-crypt Alpine image

[Git-crypt](https://github.com/AGWA/git-crypt) in Docker.

Forked from [xueshanf/docker-git-crypt](https://github.com/xueshanf/docker-git-crypt),
with the following changes:

- Upgraded Alpine to 3.6
- Added GnuPG inside the container
- Removed source code from the container after building
- Added a user instead of using root inside the container
- Change CMD to an ENTRYPOINT
- Added Makefile for building
- Added labelschema labels to Dockerfile

You can use git-crypt container on systems that git-crypt packages aren't
available, such as CoreOS, and it helps you avoid shared library dependency
hell; this is what drove me here, as I was maintaining multiple, specific, old
versions of openssl-1.0-compat on Arch Linux in order for git-crypt and
Spotify to work.

The container exposes volume /repo, to which you can bind-mount a git repository.

## Building the Image

Use `make`:

```
make build
```

This will build `quay.io/lukebond/git-crypt:VERSION`, where `VERSION` is
specified in the Makefile (current `v1.0.0`).

## Create a git-crypt shell wrapper

Ensure you have the image pulled locally:

```
$ docker pull quay.io/lukebond/git-crypt:v1.0.0
```

To make it easy to use, create a shell wrapper `git-crypt`, make it
executable, and save it somewhere in your path (I put it in `~/bin`).

Run the following commands from the root directory of your project that uses
git-crypt.

If using shared key:

```
#!/bin/bash -e
exec docker run -it -v $(pwd):/repo -v /path/to/shared-git-crypt-key:/repo/.git/.git-crypt/keys/default quay.io/lukebond/git-crypt:v1.0.0 "$@"
```

If using gpg private key:

```
#!/bin/bash -e
exec docker run -it -v $(pwd):/repo -v ~/.gnupg:/home/gitcrypt/.gnupg quay.io/lukebond/git-crypt:v1.0.0 "$@"
```

## Troubleshooting

If you have a password on your GPG key, you may see messages such as "No
secret key". This is likely because you have a X dialog that pops up and asks
for your password, which won't work inside the container without a bit of
work. Instead, tell GPG to use the loopback pinentry mode:

In `~/.gnupg/gpg-agent.conf`:

```
allow-loopback-pinentry
```

... and in `~/.gnupg/gpg.conf:

```
pinentry-mode loopback
```

According to the [Arch Linux documentation](https://wiki.archlinux.org/index.php/GnuPG#Configuration_2),
the latter may cause problems and it's best to pass the `--pinentry-mode loopback`
command-line argument to the `gpg` command. Something that could be done in
this Docker image by wrapping or aliasing the `gpg` command. Bear this in mind
if you have issues.

## Example usages

Make sure the above git-crypt wrapper command is in your command path.

* Command help

	```
	$ git-crypt help
	```

* List encrypted files:
	
	```
	$ git-crypt status -e
	```
* List unencrypted files

	```
	$ git-crypt status -u
	```

* Unlock encrypted files

	```
	$ git-crypt unlock
	```
