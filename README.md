# deployment

> Deployment configuration for analytics.offen.dev

This repository keeps the configuration we use for deploying our very own instance of Offen at `analytics.offen.dev`, running on a bare `t2.micro` EC2 instance on AWS.

---

Key features are:

- The application is able to acquire and renew its own SSL certificate using LetsEncrypt. This means we can guarantee safe transmission of data without costs or additional effort.
- Data is persisted in a local SQLite database which performs well, is easy to backup and comes at no additional infrastructure cost.
- Running off the docker/docker image we publish on Docker Hub, no setup other than installing Docker and configuring the application using the provided setup command is required to run a production ready application.

---

`docker-compose` is not strictly necessary in this case, but it frees us from handling unwieldy multiline `docker run` commands.

The `offen.env` file referenced in the compose file is not included in this repository as it contains secrets. The keys it contains are:

```
 OFFEN_SECRETS_COOKIEEXCHANGE = "xxx"
 OFFEN_SECRETS_EMAILSALT = "xxx"
 OFFEN_SMTP_HOST = "xxx"
 OFFEN_SMTP_USER = "xxx"
 OFFEN_SMTP_PASSWORD = "xxx"
```
