#!/bin/bash

IMGPREFIX=hal433
IMGNAME=docker-zeppelin
IMG="${IMGPREFIX}/${IMGNAME}"

echo -e "Building docker image ${IMG}..."

docker build -t $IMG .
