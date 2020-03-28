# /usr/bin/bash


DIR=$(dirname $0)

# without arguments deletes all workers
worker_amount=${1:-0}

# clean workspace
rm -rf $DIR/*worker

for (( worker_i=0; worker_i<$worker_amount; worker_i++ )); do
    worker_name="$((worker_i+1))worker"
    cp -r $DIR/worker_prime $DIR/$worker_name
done