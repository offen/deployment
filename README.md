<a href="https://offen.dev/">
    <img src="https://offen.github.io/press-kit/offen-material/gfx-GitHub-Offen-logo.svg" alt="Offen logo" title="Offen" width="150px"/>
</a>

# Deployment

> Deployment configuration for offen.offen.dev

This repository keeps the configuration we use for deploying our very own instance of Offen at `offen.offen.dev`, running on a bare `CX11` instance at Hetzner. You can use it as a template for a similar setup.

---

Key features are:

- The setup is able to acquire and renew its own SSL certificate using LetsEncrypt. Secure transmission of data comes without costs or additional effort.
- Data is persisted in a local SQLite database which performs well, is easy to backup and incurs no additional infrastructure costs.
- The Docker volume containing the database file is automatically backed up each day. Old backups are pruned automatically.
- Running off the docker/docker image we publish on Docker Hub, no setup other than installing Docker and docker-compose is required to run a production ready application.

---

The `offen.env` file referenced in the compose file is not included in this repository as it contains secrets. The keys it contains are:

```
OFFEN_SECRET = "<xxx>"
OFFEN_SMTP_HOST = "<xxx>"
OFFEN_SMTP_USER = "<xxx>"
OFFEN_SMTP_PASSWORD = "<xxx>"
OFFEN_SMTP_SENDER = "noreply@offen.dev"
OFFEN_SERVER_AUTOTLS="offen.offen.dev"
```

`backup.env` contains credentials for MinIO / AWS S3:

```
AWS_ACCESS_KEY_ID="<xxx>"
AWS_SECRET_ACCESS_KEY="<xxx>"
AWS_ENDPOINT="<xxx>"
AWS_DEFAULT_REGION="<xxx>"
AWS_S3_BUCKET_NAME="<xxx>"
AWS_EXTRA_ARGS="--endpoint https://${AWS_ENDPOINT}"
```

---

## Automatically updating the setup via post-receive

When pushing to `master`, CircleCI will relay the changes to a git repository on `offen.offen.dev`. There, a `post-receive` hook will trigger an update of the running service via the following script:

```sh
#!/bin/bash
set -eo pipefail

prepare () {
  # pull env files from any source
}

while read oldrev newrev ref
do
  if [[ $ref =~ .*/master$ ]]; then
    echo "Master ref received. Updating working copy and running deploy script now."
    git --work-tree=/root/offen/deployment --git-dir=/root/offen/deployment.git checkout -f
    set +e
    (cd /root/offen/deployment && prepare && ./deploy.sh); ec=$?
    set -e
    if [ "$ec" != "0" ]; then
      echo "ERR_DEPLOYMENT_FAILED: deployment script exited with code $ec"
      exit $ec
    fi
  else
    echo "Ref $ref successfully received. Doing nothing: only the master branch may be deployed on this server."
  fi
done
```
