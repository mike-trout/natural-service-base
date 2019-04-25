# natural-service-base

This is the project for the base image for creating Software AG Natural micro-services.

To build the image locally, run:

`docker build --tag natural-service-base .`

You must have 'bought' (it is free) the `store/softwareag/natural-ce` image from the [Docker Hub Store](https://hub.docker.com/_/softwareag-natural-ce) and accepted the licence agreement. You must then `docker login` as the account under which you purchased the `store/softwareag/natural-ce` image.

The image is automatically built to [Docker Hub](https://hub.docker.com/r/miketrout/natural-service-base) on a commit to master as `miketrout/natural-service-base:latest`.
