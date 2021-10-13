## Docker git-crypt Alpine image

[Git-crypt](https://github.com/AGWA/git-crypt) in docker.

This repo triggers auto-build and pushes the git-crypt image to dockerhub.com/u/xueshanf/git-crypt.

You can use git-crypt container on systems that git-crypt packages aren't available, such as CoreOS.

The container exposes volume /repo, to which you can bind-mount a git repository.

## Create a git-crypt shell wrapper

To make it easy to use, create a shell wrapper *git-crypt* and saved it as */opt/bin/git-crypt*.

If use shared key:

```
#!/bin/bash -e
docker pull xueshanf/git-crypt
exec docker run -it -v /path/to/repo:/repo -v /path/to/shared-git-crypt-key:/repo/.git/.git-crypt/keys/default xueshanf/git-crypt git-crypt "$@"
```

If use gpg private key:

Save the following script as /opt/bin/git-crypt (or whatever path in your command path):

```
#!/bin/bash -e
docker pull xueshanf/git-crypt
exec docker run -it -v /path/to/repo:/repo -v /path/to/.gnupg:/root/.gnupg xueshanf/git-crypt git-crypt "$@"
```

## Example usages

Make sure the above git-crypt wrapper command is in your command path.

* Command help

	```
	$ /opt/bin/git-crypt help
	```

* Check encrypted files:
	
	```
	$ /opt/bin/git-crypt status -e
	```
* Check un-encrypted files

	```
	$ /opt/bin/git-crypt status -u
	```

* Unlock encrypted file

	```
	$ /opt/bin/git-crypt unlock
	```