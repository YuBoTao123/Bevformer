#!/bin/bash

HERE=$(pwd)
DOCKER_USER="${USER}"
# DEV_CONTAINER="nvcr.io/nvidia/tensorrt:21.05-py3"
DEV_CONTAINER="bevformer:latest"
#DEV_CONTAINER="pytorch/pytorch:1.2-cuda10.0-cudnn7-runtime"
# DATA_DIR="pingshan_data"
# echo "data dir is $DATA_DIR"
xhost +

docker run \
    --shm-size=20g \
    -v $HERE:/workspace:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/localtime:/etc/localtime:ro \
    -w /workspace \
    -u root \
    --gpus all \
    -it --privileged=true --rm \
    --name=bevformer \
    -e DISPLAY=unix$DISPLAY \
    $DEV_CONTAINER\
    /bin/bash


# docker run \
#     --shm-size=20g \
#     -v /tmp/.X11-unix:/tmp/.X11-unix \
#     -v /etc/timezone:/etc/timezone:ro \
#     -v /etc/localtime:/etc/localtime:ro \
#     -w /BEVFormer \
#     -u root \
#     --gpus all \
#     -it --privileged=true --rm \
#     --name=bevformer \
#     -e DISPLAY=unix$DISPLAY \
#     $DEV_CONTAINER\
#     /bin/bash