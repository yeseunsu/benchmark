#!/bin/bash
COMMAND="bash ./run_model.sh"

${COMMAND} inception_v1 1 64 8 fake /data/ilsvrc12_train_lmdb /data/ilsvrc12_val_lmdb /data/imagenet_mean.binaryproto
${COMMAND} resnet_101 1 32 8 fake /data/ilsvrc12_train_lmdb /data/ilsvrc12_val_lmdb /data/imagenet_mean.binaryproto
