# Pandocomatic Development

## Using Docker

For more information about using docker, you can read the official manual. I
like the [Chowdhury's (2021) *The Docker
Handbook*](https://www.freecodecamp.org/news/the-docker-handbook/) a lot as a short but
complete introductory tutorial. Once you're up and running with Docker, you
can use Docker for paru development.

### Common Docker Tasks

- Create a new version of the Docker image with Ruby and Pandoc defined in
  `Dockerfile`:

  ```{.bash}
  docker image build --tag pandocomatic:dev .
  ```

- Run a command interactively (CLI options `-i`, `-t`) in the Docker container, and remove the container afterwards
  (CLI option `--rm`). Also attach pandocomatic's cloned repository to the container
  (CLI option `--volume $(pwd):/home/pandocomatic-user`):

  ```{.bash}
  docker container run --rm -it --volume $(pwd):/home/pandocomatic-user pandocomatic:dev bash
  ```

  You can also run rake, for example, to run all pandocomatic's test suites.
