# Librarian

Librarian was made to keep track of resources in the office as if they were books. Librarian will keep track of its library and who has what resources checked out.

## Deploying

1. create intergration bot named `Resource Librarian` (or what ever you want)
1. get token for the new bot
1. create a `librarian` directory on host machine
1. copy `docker-compose.yml` to the `librarian` directory on host machine
1. create `.env` with the following content in the `librarian` directory on host machine

  ```
SLACK_BOT_TOKEN={bot-token}
LIBRARIAN_VERSION={version-you-want}
  ```

1. start librarian with `docker-compose up -d` from the `librarian` directory on host machine

## Testing

In order to run the tests you need a valid slack bot token. Once you have the token export it in your shell

```
export SLACK_BOT_TOKEN=<insert-token-here>
```

With that environment variable exported tests are run as follows.

```
mix test
```

## Running in dev mode

Given a `SLACK_BOT_TOKEN` environment variable (see above) the librarian can be run as follows.

```
mix run --no-halt
```

## Configuration

If deploying with docker, make a copy of `docker-compose.yml.example` and rename it `docker-compose.yml`. Replace the `SLACK_BOT_TOKEN` value with your slack bot token.

## Usage

To use librarian type `librarian COMMAND` ex: `librarian add foobar`.
Avaliable Commands:
`add RESOURCE` : will add the RESOURCE to the library

`checkout RESOURCE` : will checkout the RESOURCE from the library
  * aliases: co

`inventory` : will return an itemized list of all resources in the library and who has them checked out
  * aliases: status

`rename RESOURCE to NEW_NAME` : will rename the RESOURCE in the library to the NEW_NAME

`remove RESOURCE` : will remove the RESOURCE from the library
  * aliases: rm

`return [OPTION] RESOURCE` : will return the RESOURCE to the library if it is not checked out
  * aliases: checkin, ci
  * -f, --force
    * force the return of the RESOURCE
