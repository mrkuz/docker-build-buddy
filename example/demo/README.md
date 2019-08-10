# Introduction

This example was generated using [gradle-project-generator](https://github.com/mrkuz/gradle-project-generator).

# Running the container

Supply the project name and the main class as arguments.
``` shell
docker run --rm -p 2222:22 -p 8080:8080 -p 9999:9999 -v .:/home/user/src:ro build-buddy demo com.example.demo.Application
```

You have to trigger the initial build:

``` shell
touch build.gradle
```

# Using docker-compose
``` shell
docker-compose -f build-buddy.yaml up
```

# Using rsync instead of mounts

``` shell
rsync -av -e 'ssh -p2222' . user@localhost:/home/user/src --exclude=build --exclude=out --exclude=.gradle --exclude=.git
```

