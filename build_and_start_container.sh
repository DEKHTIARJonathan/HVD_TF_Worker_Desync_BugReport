docker pull tensorflow/tensorflow:nightly-gpu

docker build -t tf_nightly_with_horovod:latest .

docker run -it --rm \
    --gpus all \
    --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
    --workdir /workspace/ \
    -v "$(pwd):/workspace/" \
    tf_nightly_with_horovod:latest
