<a href="https://offen.dev/">
    <img src="https://offen.github.io/press-kit/offen-material/gfx-GitHub-Offen-logo.svg" alt="Offen logo" title="Offen" width="150px"/>
</a>

# Deployment

> Deployment configuration for analytics.offen.dev

This repository keeps the configuration we use for deploying our very own instance of Offen at `analytics.offen.dev`, running on a bare `t2.micro` EC2 instance on AWS.

---

Key features are:

- The application is able to acquire and renew its own SSL certificate using LetsEncrypt. This means we can guarantee secure transmission of data without costs or additional effort.
- Data is persisted in a local SQLite database which performs well, is easy to backup and comes at no additional infrastructure cost.
- Running off the docker/docker image we publish on Docker Hub, no setup other than installing Docker and configuring the application using the provided setup command is required to run a production ready application.

---

`docker-compose` is not strictly necessary in this case, but it frees us from handling unwieldy multiline `docker run` commands.

The `offen.env` file referenced in the compose file is not included in this repository as it contains secrets. The keys it contains are:

```
 OFFEN_SMTP_HOST = "xxx"
 OFFEN_SMTP_USER = "xxx"
 OFFEN_SMTP_PASSWORD = "xxx"
 OFFEN_SMTP_SENDER = "xxx"
 OFFEN_SECRET = "xxx"
```

---

## Automatically updating the application via post-receive

When pushing to `master`, CircleCI will relay the changes to a git repository on `analytics.offen.dev`. There, a `post-receive` hook will trigger an update of the running service via the following script:

```sh
#!/bin/bash
set -eo pipefail

while read oldrev newrev ref
do
    if [[ $ref =~ .*/master$ ]];
    then
        echo "Master ref received. Updating working copy and running deploy script now."
        git --work-tree=/home/ubuntu/offen/deployment --git-dir=/home/ubuntu/offen/deployment.git checkout -f
        /home/ubuntu/offen/deployment/deploy "s3://offen-secrets/offen.env"
    else
        echo "Ref $ref successfully received. Doing nothing: only the master branch may be deployed on this server."
    fi
done
```
