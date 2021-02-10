![prosody logo](./.assets/prosody_logo.png)

# MPLK - Movim, prosody, LDAP and Keycloak

prosody XMPP Server with Keycloak registration, LDAP authentication and PostgreSQL Storage

## Perquisites

You must have a working Nginx instance, with the ability to handle the path `.well-known` for the deployment of ACME certificates by using certbot.

curl, jq, Python with python-dotenv and jinja2

```shell
sudo apt install curl jq
sudo pip install python-dotenv jinja2
```

`python-ldap` is also required if you want to run the roster Python script locally.

# Initial Usage

Create and edit the `.env` file and change the settings to suit your environment. Copy the example file and update as required.

Fetch the certificates:

`./getcerts`

Run the deployment script. This will configure and start the container set with settings from the `.env`.

`./deploy`

At any change in configuration after the initial deployment use the configure script to recreate files from the templates and deliver them.

`./configure`

You may  want to restart the container set after any configuration change.

```shell
docker-compose down
docker-compose up -d
```

## Prosody

The `${CONTAINER_VOLUME}` path must belong to a user other than root or prosody fails to start with:

```shell
prosody_1   | usermod: UID '0' already exists
```

It uses `usermod` to change the containers prosody user id to the same as the folder which it obtains similarly to this:

```shell
stat -c %u /srv/container-volumes/prosody-bundle
```

Prosody uses `supervisord` to run both prosody and `cron`. The cron runs a daily job, which is a templated python file, that updates the roster using the credentials and details in the `.env` at deploy time. It can be updated by rerunning the template using `./configure`

It is possible to restart prosody alone by using the `supervisorctl` command from within the container.

`docker-compose exec prosody supervisorctl restart prosody`

### Certificates

Prosody relies upon the use of Let's Encrypt certificates. The script `getcerts` will initially fetch certificates for prosody wih all the correct SAN's. The `configure script will then deploy them to prosody and setup the automation of copying them into prosody each time they are renewed.

### Configuration Templates

To build the `cfg.lua` files and other templates I have switched to using Jinja2. As part of the `./deploy` script it renders the config files from `*cfg.*.template.lua` substituting the contained environment variables with their value.

### Deploy Script

The `./deploy` is a bash script that renders the lua config files, `nginx.conf` and keycloak templates from the `.env`. After the templates it also restarts prosody if it was running, deploys the `nginx.conf` config to `/etc/nginx/conf.d/${SERIAL}.conf` and reloads Nginx. Then runs a series of API calls to Keycloak to deploy the realm and LDAP configuration.

## PostgreSQL

At initial db startup The `init-db.sh` __should__ take care of creating the database and assigning permissions.

## Keycloak

This was added to allow users to register for accounts and be added into the LDAP schema automatically. It brings self service to the external users.

Self Service URL: [http://SERVER:PORT/auth/realms/REALM/account](#)

Configuration templating is done using the python jinja2 module.

## Movim

It's important to add in the headers required to any front end Nginx proxy you are using:

```nginx
    location / {
        proxy_pass http://movim;
        # force timeouts if the backend dies
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;

        # set headers
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Host $remote_addr;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Server-Select $scheme;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Url-Scheme: $scheme;
        proxy_set_header Host $host;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Upgrade $http_upgrade;
        proxy_http_version 1.1;

        # by default, do not forward anything
        proxy_redirect off;
    }
```    

This is done automatically by the configure script.
