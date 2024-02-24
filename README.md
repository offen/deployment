<a href="https://www.offen.dev/">
  <img src="https://offen.github.io/press-kit/avatars/avatar-OFWA-header.svg" alt="Offen Fair Web Analytics logo" title="Offen Fair Web Analytics" width="60px"/>
</a>

# Deployment

This repository contains the configuration we use for deploying our own instance of Offen Fair Web Analytics at `offen.offen.dev` using Docker and docker-compose, running on a bare `CX11` instance at Hetzner. It is designed as a template for you to use in a similar setup.

## Key features

- Running off the `offen/offen` image that is published on Docker Hub, no setup other than installing Docker and docker-compose is required to run a production ready application.
- Data is persisted in a local SQLite database which performs well, is easy to backup and incurs no additional infrastructure costs.
- The setup is able to acquire and renew its own SSL certificate using LetsEncrypt. Using https comes without costs or additional effort.
- The Docker volume containing the database file is automatically backed up locally. This uses the `offen/docker-volume-backup` image.

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
docker-compose up
```

---

## Configuration

### Offen Fair Web Analytics

The `offen.env` file referenced in the compose files are ignored in this repository as they contain secrets. Refer to the template files for what values are expected. Full documentation for these values is found in the [Offen docs][docs].

If you are [experiencing issues with values being double quoted][quotes-issue], make sure to check if your `docker-compose` version is up to date.

[docs]: https://docs.offen.dev/running-offen/configuring-the-application/
[quotes-issue]: https://github.com/docker/compose/issues/2854

### Backup

Documentation on how to configure the database backups can be found in the [`offen/docker-volume-backup` repository][backup]

[backup]: https://github.com/offen/docker-volume-backup
