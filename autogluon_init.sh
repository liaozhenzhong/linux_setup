#!/bin/bash
# exec &>> your_file.log

usage() {
    echo \
"usage: $0 [-d <0|1>] [-c <0|1>]
-d: 1 use docker, 0 no use docker
-c: 1 use cpu, 0 use gpu"
}

DOCKER=1
CPU=1

while getopts dc: name
do
    case $name in
        d)
            DOCKER="$OPTARG"
            ;;
        c)
            CPU="$OPTARG"
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

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

function docker() {
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
}

if [[ $DOCKER -eq 0 && $CPU -eq 1 ]] ; then
    python3 -m pip install "torch>=1.0,<1.12+cpu" -f https://download.pytorch.org/whl/cpu/torch_stable.html
    python3 -m pip install autogluon
fi

if [[ $DOCKER -eq 0 && $CPU -eq 0 ]] ; then
    python3 -m pip install autogluon
fi

if [[ $DOCKER -eq 1 && $CPU -eq 1 ]] ; then
    docker
    sudo docker run --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
    # sudo docker pull autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
fi

if [[ $DOCKER -eq 1 && $CPU -eq 0 ]] ; then
    docker
    sudo docker run --gpus all --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
    # sudo docker pull autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
fi

sudo apt autoremove -y
