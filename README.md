<a href="https://offen.dev/">
    <img src="https://offen.github.io/press-kit/offen-material/gfx-GitHub-Offen-logo.svg" alt="Offen logo" title="Offen" width="150px"/>
</a>

# Deployment

This repository contains the configuration we use for deploying our own instance of Offen at `offen.offen.dev` using Docker and docker-compose, running on a bare `CX11` instance at Hetzner. It is designed as a template for you to use in a similar setup.

## Key features

- Running off the `offen/offen` image we publish on Docker Hub, no setup other than installing Docker and docker-compose is required to run a production ready application.
- Data is persisted in a local SQLite database which performs well, is easy to backup and incurs no additional infrastructure costs.
- The setup is able to acquire and renew its own SSL certificate using LetsEncrypt. Secure transmission of data comes without costs or additional effort.
- The Docker volume containing the database file is automatically backed up to a S3 compatible storage each day. Old backups are pruned automatically.

## Quickstart

Make sure you have Docker and docker-compose installed. Next, clone the repository:

```sh
git clone git@github.com:offen/deployment.git
cd deployment
```

Create an `offen.env` file by copying the template file:

```sh
cp offen.env.template offen.env
```

Once you have populated the file with your specific config, you are ready to start the setup:

```sh
./deploy.sh
```

## Adding automated database backups

If you want to regularly back up your database file to an S3 compatible storage, you can use the provided `backup` service. Create an `backup.env` file by copying the the template file:

```sh
cp backup.env.template backup.env
```

The backup currently runs once a day at 02:00 UTC. You can change this schedule in `docker-compose.backup.yml`.

Once populated, start the setup passing an additional `backup` argument:

```sh
./deploy.sh backup
```

## Automatically expiring old backups

This deployment setup can also handle automatic deletion of old backups from your storage. To enable this feature, start the setup passing `expire`:

```sh
./deploy.sh backup expire
```

The expire script currently runs once a day at 02:30 UTC. If needed, you can change this schedule in `expire/crontab.txt`.

You can also run this command manually if you prefer not to have the container handle this for you:

```sh
docker-compose -f docker-compose.expire.yml run --entrypoint expire --rm  expire $AWS_S3_BUCKET_NAME $BACKUP_RETENTION
```

---

## Configuration

The `offen.env` and `backup.env` files referenced in the compose files are ignored in this repository as they contain secrets. Refer to the template files for what values are expected. Full documentation for these values is found in the [Offen docs][docs].

If you are [experiencing issues with values being double quoted][quotes-issue], make sure to check if your `docker-compose` version is up to date.

[docs]: https://docs.offen.dev/running-offen/configuring-the-application/
[quotes-issue]: https://github.com/docker/compose/issues/2854

---

## Automatically updating the setup via post-receive

As we update Offen on a rolling basis to keep up with development, we use a remote git repository on the VPS to handle updates.

When pushing to `offen-offen-dev`, CI will relay the changes to a git repository on `offen.offen.dev`. There, a `post-receive` hook will trigger an update of the running service via the following script:

```sh
#!/bin/bash
set -eo pipefail

prepare () {
  # pull env files from any source
}

while read oldrev newrev ref
do
  if [[ $ref =~ .*/offen-offen-dev$ ]]; then
    echo "Master ref received. Updating working copy and running deploy script now."
    git --work-tree=/root/offen/deployment --git-dir=/root/offen/deployment.git checkout -f "$ref"
    set +e
    (cd /root/offen/deployment && prepare && ./deploy.sh backup expire); ec=$?
    set -e
    if [ "$ec" != "0" ]; then
      echo "ERR_DEPLOYMENT_FAILED: deployment script exited with code $ec"
      exit $ec
    fi
  else
    echo "Ref $ref successfully received. Doing nothing: only the offen-offen-dev branch may be deployed on this server."
  fi
done
```
