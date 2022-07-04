#!/bin/bash
# exec &>> your_file.log

DOCKER=1
AUTOGLUON_LOCAL_CPU=0
AUTOGLUON_LOCAL_GPU=0
AUTOGLUON_DOCKER_CPU=1
AUTOGLUON_DOCKER_GPU=0

sudo apt update
sudo apt install tmux -y
sudo apt install vim -y
sudo apt install mc -y
sudo apt install build-essential -y
sudo apt install python3-pip -y
python3 -m pip install pip -U
python3 -m pip install setuptools wheel -U

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp .vimrc ~/.vimrc

if [ $DOCKER -eq 1 ] ; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi

if [ $AUTOGLUON_LOCAL_CPU -eq 1 ] ; then
    python3 -m pip install "torch>=1.0,<1.12+cpu" -f https://download.pytorch.org/whl/cpu/torch_stable.html
    python3 -m pip install autogluon
fi

if [ $AUTOGLUON_LOCAL_GPU -eq 1 ] ; then
    python3 -m pip install autogluon
fi

if [ $AUTOGLUON_DOCKER_CPU -eq 1 ] ; then
    # sudo docker run --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
    sudo docker pull autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
fi

if [ $AUTOGLUON_DOCKER_GPU -eq 1 ] ; then
    # sudo docker run --gpus all --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
    sudo docker pull autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
fi

sudo apt autoremove -y