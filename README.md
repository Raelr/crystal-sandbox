# crystal-sandbox

[![Crystal-sandbox](https://circleci.com/gh/circleci/circleci-docs.svg?style=svg)](https://app.circleci.com/pipelines/github/Raelr/crystal-sandbox)

## Setup

Setup requires two manual steps: setting up your postgres credentials in `docker-compose.yml` and in `configuration.yaml`. 

First, open the `docker-compose.yml` file and fill in the `POSTGRES_USERNAME`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` fields:

```docker-compose
  # docker-compose.yaml
  psql: 
    container_name: psql
    image: postgres
    environment:
      POSTGRES_PASSWORD: <YOUR_PASSWORD> # <---- replace with desired password
      POSTGRES_USER: <YOUR_USERNAME> # <--- replace with desired username
      POSTGRES_DB: users # <---- fill in (if a custom db name is selected)
```

When done, save the file and find the `configuration_template.yaml` file. Once found, copy the file and rename the new file to `configuration.yaml`:

```
cp configuration_template.yaml configuration.yaml
```

Open `configuration.yaml` and fill in the `postgres_username`, `postgres_password`, and `database_name fields`:

```
  # configuration.yaml file
  pg: 
    postgres_username: <YOUR_USERNAME> # <---- replace with desired username
    postgres_password: <YOUR_PASSWORD> # <---- replace with desired password
    host: localhost
    port: 5432
    database_name: users               # <---- replace with desired database name
```

Once done, save the files and run the following commands to start the page:

```bash
# Start postgres container:
$ docker-compose up -d

# Run server
$ crystal run src/login-backend.cr
```

The server should start from there. 
