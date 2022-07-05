#!/bin/bash
exec &>> installation.log

DOCKER=0
CPU=0

function show_usage() {
echo \
"usage: $0 [-d <0|1>] [-c <0|1>]
-d: 1 use docker, 0 no use docker
-c: 1 use cpu, 0 use gpu"
}

function install_docker() {
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    if [[ $CPU -eq 0 ]] ; then
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
          && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
          && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
        sudo apt update
        sudo apt install -y nvidia-docker2
        sudo systemctl restart docker
    fi
}

function install_py_libs() {
    python3 -m pip install scikit-learn matplotlib pandas numpy seaborn plotly jupyter nltk tqdm
}

function start_jupyter() {
    jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser
}

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
            show_usage
            exit 1
            ;;
    esac
done

sudo apt update
sudo apt install tmux vim mc build-essential python3-pip -y
python3 -m pip install pip -U
python3 -m pip install setuptools wheel -U

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp .vimrc ~/.vimrc

if [[ $DOCKER -eq 0 && $CPU -eq 1 ]] ; then
    python3 -m pip install "torch>=1.0,<1.12+cpu" -f https://download.pytorch.org/whl/cpu/torch_stable.html
    python3 -m pip install autogluon
    install_py_libs
    start_jupyter
fi

if [[ $DOCKER -eq 0 && $CPU -eq 0 ]] ; then
    python3 -m pip install autogluon
    install_py_libs
    start_jupyter
fi

if [[ $DOCKER -eq 1 && $CPU -eq 1 ]] ; then
    install_docker
    sudo docker run --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
    # sudo docker pull autogluon/autogluon:0.4.0-cpu-jupyter-ubuntu20.04-py3.8
fi

if [[ $DOCKER -eq 1 && $CPU -eq 0 ]] ; then
    install_docker
    sudo docker run --gpus all --shm-size=64G -it -p 8888:8888 autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
    # sudo docker pull autogluon/autogluon:0.4.0-rapids22.04-cuda11.2-jupyter-ubuntu20.04-py3.8
fi

sudo apt autoremove -y
