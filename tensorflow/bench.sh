#/bin/bash

DATA_DIR=/imagenet
LOG_DIR=output
EVAL_DIR=eval
TIMESTAMP=$(date +%m%d%H%M)
NUM_EPOCHS=1
SAMPLE_SIZE=1281167
NUM_GPU=8
JOB_NAME=$1
TASK_INDEX=$2

#LOG SETTING
TRAIN_DIR=train_log_single
SUMMARY_VERBOSITY=1
SUMMARIES_STEPS=1000

mkdir -p ${TRAIN_DIR}
mkdir -p ${LOG_DIR}

LS_HOST=(192.168.200.212 192.168.200.214)
PORT_PS=50000
PORT_WORKER=50001
VARIABLE_UPDATE=distributed_replicated

train() {
    MODEL=$1
    BATCH_SIZE=$2
    JOB_NAME=$3
    TASK_INDEX=$4
    TIMESTAMP=$(date +%m%d%H%M)
    NUM_BATCHES=$(( ${NUM_EPOCHS} * ${SAMPLE_SIZE} / ${BATCH_SIZE} / ${NUM_GPU} ))
    LOG_FILE="${LOG_DIR}/output_${MODEL}_e${NUM_EPOCHS}_b${BATCH_SIZE}_tid${TASK_INDEX}.${TIMESTAMP}.log"
    python tf_cnn_benchmarks/tf_cnn_benchmarks.py \
        --job_name=${JOB_NAME} \
        --ps_hosts="${LS_HOST[0]}:${PORT_PS},${LS_HOST[1]}:${PORT_PS}" \
        --worker_hosts="${LS_HOST[0]}:${PORT_WORKER},${LS_HOST[1]}:${PORT_WORKER}" \
        --task_index=${TASK_INDEX} \
        --model=${MODEL} --batch_size=${BATCH_SIZE} --num_batches=${NUM_BATCHES} --num_gpus=${NUM_GPU} \
        --data_name=imagenet --data_dir=${DATA_DIR} --variable_update=${VARIABLE_UPDATE} \
        --train_dir=${TRAIN_DIR} -p 6006:6006 \
        --summary_verbosity=${SUMMARY_VERBOSITY} --save_summaries_steps=${SUMMARIES_STEPS} \
        2>&1 | tee ${LOG_FILE}
}

train googlenet 64 ${JOB_NAME} ${TASK_INDEX}
train googlenet 96 ${JOB_NAME} ${TASK_INDEX}
train googlenet 128 ${JOB_NAME} ${TASK_INDEX}
train resnet101 32 ${JOB_NAME} ${TASK_INDEX}

