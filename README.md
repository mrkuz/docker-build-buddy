### Introduction

Docker image to continuously build and automatic restart Spring Boot applications.

### Build

``` shell
docker build -t build-buddy .
```

### Description

The main process watches the source directory /home/user/src for changes.
Changes trigger a Gradle build, which in turn restarts the Spring Boot
application.

You can either use mounts or SSH to get your source into the container.

### Requirements

- Gradle single-project build
- Gradle Application plugin
- Spring Boot Devtools

### Example

See [example/demo/](/example/demo) for an example how to run the container.

### Ports

- Application: 8080
- JPDA: 9999
- SSH: 22
