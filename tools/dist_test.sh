#!/usr/bin/env bash

CONFIG=$1
CHECKPOINT=$2
GPUS=$3
PORT=${PORT:-29503}

# PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \
# python -m torch.distributed.launch --nproc_per_node=$GPUS --master_port=$PORT \
#     $(dirname "$0")/test.py $CONFIG $CHECKPOINT --launcher pytorch ${@:4} --eval bbox

# PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \
#  CC=/home/botao/miniconda3/envs/bevformer_new/bin/gcc CXX=//home/botao/miniconda3/envs/bevformer_new/bin/g++-9 python $(dirname "$0")/test.py $CONFIG $CHECKPOINT --eval bbox

PYTHONPATH="$(dirname $0)/..":$PYTHONPATH \
 CC=/usr/bin/gcc CXX=/usr/bin/g++-9 python $(dirname "$0")/test.py $CONFIG $CHECKPOINT --eval bbox