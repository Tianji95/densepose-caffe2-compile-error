
**ubuntu16.04 + caffe2 + python2.7 densepose 配置指南(踩坑合集)**

因为学习/实习需求，在linux上部署caffe2和densepose，中间踩了很多很多的坑。。。。在这里记录一下吧

**Docker 环境配置：**
1. 从https://hub.docker.com/r/caffe2/caffe2/tags/ 这个url中pull下来镜像文件：
```
docker pull caffe2/caffe2:snapshot-py2-cuda8.0-cudnn7-ubuntu16.04 
```
注意这个时候服务器只能用cuda80或者cuda90的镜像，需要根据服务器cuda版本下载

2. 运行脚本
```
#!/bin/bash

set -x
set -e

DOCKER_IMAGE="caffe2/caffe2:snapshot-py2-cuda8.0-cudnn7-ubuntu16.04"

# using docker to build BINS

nvidia-docker run \
   --network=host \
   --ipc=host \
   -v /home/你的名字:/host/你的名字 \    例如-v /home/hzzhengtianji:/host/hzzhengtianji \
   -dit $DOCKER_IMAGE

```

3. docker ps 查看docker进程，查找出你的进程id号，然后进入到你自己的进程里面

    docker exec -ti [id] bash

4. 在docker环境中执行：
```
    apt-get update
    apt-get install vim 等一类的软件
    apt-get install wget
```

5. 这里进入到DensePoseData文件夹里面，如果能够直接执行.sh文件的话是最好的。但是我第一次进入的时候发现我司的网不太能访问s3.amazonaws.com这个网址，所以我是在windows上开ss翻墙下载然后再传上去的.这里需要用到xftp和docker cp两个工具

6. PYTHONPATH /usr/local/caffe2_build:${PYTHONPATH}等环境变量应该按照Dockerfile里面的一样配置


7. 同样的东西，模型也没办法直接用tools/test.py的脚本下载，只能自己先下载下来，然后用xftp传上去以后cp到/tmp下面

8. 直接运行即
```
CUDA_VISIBLE_DEVICES=3 python2 tools/infer_simple.py \
    --cfg configs/DensePose_ResNet101_FPN_s1x-e2e.yaml \
    --output-dir DensePoseData/infer_out/ \
    --image-ext jpg \
    --wts https://s3.amazonaws.com/densepose/DensePose_ResNet101_FPN_s1x-e2e.pkl \
    DensePoseData/demo_data/demo_im.jpg
```

**ubuntu系统 环境配置：**

1. 要求ubuntu16.04（据说14.04也可以）还是建议以16.04为主，其他版本可能会有些坑，不过基本步骤应该差不多

2. 安装显卡驱动，配置cuda8+cudnn6，因为之前安装过显卡驱动了，所以在安装cuda的时候不需要再次安装驱动，所以在询问你是否install graphics driver的时候选择否就行了。其他版本不太清楚，这个地方遇到的坑就是环境变量没有配置对，请务必在~/.profile 里面编辑出（这里请按照你自己安装的cuda位置来

    export CUDA_HOME=/usr/local/cuda 
    export PATH=$PATH:$CUDA_HOME/bin
    export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

3. 安装python2.7, ubuntu自带python2.7.所以不用刻意安装，但是一定要确保python2.7的包位置和查找的位置一样，而且要保证python确实能找到这些安装的包（**血泪教训**）
注意：因为某些包安装路径不同，python setup install 和pip安装路径很可能不同，所以一定要注意，实在不行用一下--target确定下路径

另外，国内网pip install的时候默认的是pypi.python.org,经常会下载着就连不上了，所以可以在后面加一个 -i https://pypi.douban.com/simple例如：
    
    pip install matplotlib -i https://pypi.douban.com/simple --target /usr/lib/python2.7/dist-packages


4. 配置caffe2，按照官网https://caffe2.ai/docs/getting-started.html?platform=ubuntu&configuration=compile进行安装和配置

    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libgoogle-glog-dev \
        libgtest-dev \
        libiomp-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libopenmpi-dev \
        libsnappy-dev \
        libprotobuf-dev \
        openmpi-bin \
        openmpi-doc \
        protobuf-compiler \
        python-dev \
        python-pip      

    pip install --user \
        future \
        numpy \
        protobuf

    sudo apt-get install -y --no-install-recommends libgflags-dev

5. 在进行下面代码的时候，建议加一个版本号，不然直接git下来的源码非常不稳定，全是bug（**血泪教训**)
    例如：git clone https://github.com/pytorch/pytorch.git --branch v0.4.1（非常建议）

    下面是官网推荐的安装方法：
    git clone https://github.com/pytorch/pytorch.git && cd pytorch
    git submodule update --init --recursive
    sudo FULL_CAFFE2=1 python setup.py install
    
**注意这个地方，因为默认是不build caffe2的，所以需要额外添加FULL_CAFFE2=1参数，也是一个深坑了**
所以如果遇到找不到caffe2_pb文件的，很可能就是这个地方没有build caffe2

6. 中间你可能会遇到各种问题：例如：
    
    no instance of constructor at tensoroptions caffe2_gpu_generated_THCStoragecopy.cu.o
    at::tensorimpl has no member tostring
    caffe2 fatal error cudnn.h no such file or directory
    [Caffe2] Cannot load caffe2.python. Error: libcaffe2.so: cannot open shared object file: No such file or directory

所有的问题基本都是路径问题导致的（**血泪教训**）请一定一定一定一定要保证你的安装路径和查找路径是一直的，源码和链接库也能对应上的。特别是如果电脑里面装了两个python的时候，一定要确保你默认的python，默认python的查找库，实际的查找位置，对应的链接库等等都是能对应上的，因为pip有时候会安装到奇怪的位置，所以一定一定要小心，在这里我分享下我的~/.profile文件：
    
    PATH = "$HOME/bin:/usr/bin:$PATH"
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/lib/python2.7/dist-packages/torch/lib
    export CUDA_HOME=/usr/local/cuda
    export PYTHONPATH=/home/tianji/densepose/pytorch/build:/home/tianji/densepose/pytorch/modules/detectron
    export COCOAPI=/home/tianji/densepose/cocoapi

一般来说.so文件或者是.o文件找不到都是lib文件夹找不到，需要配置LD_LIBRARY_PATH，.h文件找不到就是python查找文件找不到

7. python相关的其他问题基本google下就能搞定，基本就是setuptools的坑啊，或者是pip的坑啊，或者是其他库的坑，换下版本或者加一个参数都能搞定的，不多说了

8. 按照官网 https://github.com/facebookresearch/DensePose/blob/master/INSTALL.md 继续往下走，安装coco api，安装densepose，这个时候因为安装requirement.txt的时候，因为众所周知的原因，国内的网还是emmmmmmm，所以很可能会出现HTTPSConnectionPool的timed out error,这个时候没办法可能需要自己手动装，例如requirement.txt里面需要用到opencv_python，那我们就需要
    
    pip install opencv_python -i https://pypi.douban.com/simple
    pip install h5py -i https://pypi.douban.com/simple

anyway，自己查一下requirement里面都有什么东西，然后自己手动装就行了，不过豆瓣的源有时候版本会比较落后的，如果不符合要求的话，可以试一下清华的源https://pypi.tuna.tsinghua.edu.cn/simple/


事实上到目前为止已经可以跑起来sample了，然后会遇到下面的坑：

9. ImportError: No module named 'pycocotools'坑
    
    进入到之前clone的cocoapi，重新执行一遍
    python PythonAPI/setup.py build_ext install

10. 模型需要自己下载下来然后拷贝到/tmp/detectron-download-cache下面，如果不拷贝的话，或者拷贝路径错误的话，或者没有添加 --wts https://..... 参数的话，会报 TypeError：expected string or buffer的错误


下面是densepose的选做项目，不做好像也可以跑起来，但是不做的话未来可能会出问题：

9. 在densepose里面进行make ops的时候，可能会遇到下面的问题

    Could not find a package configuration file provided by "caffe2" with any
    of the following names:

    caffe2Config.cmake
    caffe2-config.cmake

这个时候一般是没有配置Caffe2_DIR导致的，按照官网的方法，我发现caffe2并没有真正的install到/usr/local/里面，而是在caffe2 git的文件夹里面，那么只需要

    sudo find / -name caffe2Config.cmake
    找到caffe2Config.cmake存在的路径
    然后找到文件里面的cmake文件，把Caffe2_DIR加入进去

注意这里面的Caffe2_DIR指的是CMake变量而不是环境变量，注意区分

哇靠新版的caffe2实在是太坑了，在文件夹里面cmake的路径完全就是乱掉的，我实在没办法就把之前弄好的docker里面的文件放进来才行。。。。
首先把docker里面的caffe2_build和caffe2文件夹拷出来，然后把PYTHONPATH 和Caffe_DIR修改掉，

    sudo cp -r caffe2 /usr/local
    sudo cp -r caffe2_build /usr/local
    gedit ～/.profile
    export PYTHONPATH=/usr/local/caffe2_build
    export Caffe2_DIR=/usr/local/caffe2_build/share/cmake/Caffe2

重启电脑，或者source ~/.profile
删除densepose里面的build文件夹，或者执行：
    
    mv build build_old

最后安装2.6.1版本的protobuf，编译出来的libprotobuf.so拷贝到/usr/lib/x86_64-linux-gnu/里面，最后再执行
    
    sudo make ops Caffe2_DIR=/usr/local/caffe2_build/share/cmake/Caffe2
 
最终终于编好了。。。。实在是太坑

........................................................................................

你以为到这里就结束了么。。。错。。。。。。我们只是把caffe2的新环境换成了老的。。。。那么对应的so文件等也要全套换掉，不信的话直接跑

    python detectron/tests/test_zero_even_op.py
看能不能跑起来。。。。。。。。。。。。
ok问题一个一个解决

10.CRITICAL:root:Cannot load caffe2.python. Error: libcaffe2.so: cannot open shared object file: No such file or directory

找不到so文件了，，，那我们就先把原来的caffe源码换成现在的：
    
    cd /usr/local/lib/python2.7/dist-packages
    sudo mv caffe caffe_old
    sudo mv caffe2 caffe2_old
    sudo ln -s /usr/local/caffe2 caffe2
    sudo gedit /etc/ld.so.conf.d/caffe2.conf
    sudo gedit /etc/ld.so.conf.d/cuda-8-0.conf
    sudo ldconfig
    
本以为大功告成，然后发现WARNING:root:Debug message: libcudnn.so.7: cannot open shared object file: No such file or directory
CRITICAL:root:Cannot load caffe2.python. Error: libhiredis.so.0.13: cannot open shared object file: No such file or directory

okok，你厉害你厉害，我考过来还不行么。。。。然后我就把cudnn换成了7，把libhiredis.so.0.13考了一份过来

    sudo cp libhiredis.so.0.13 /usr/lib/x86_64-linux-gnu/libhiredis.so.0.13
    cd /usr/local/cuda-8.0/lib64
    sudo rm libcudnn*
    cd /usr/local/cuda-8.0/include
    sudo rm cudnn.h 
    cn ～/cudnn7
    sudo cp libcudnn* /usr/local/cuda-8.0/lib64
    sudo cp cudnn.h /usr/local/cuda-8.0/include
    sudo ln -sf libcudnn.so.7.0.5  libcudnn.so.7 #创建软链接
    sudo ln -sf libcudnn.so.7  libcudnn.so
    sudo ldconfig


10. densepose/build/libcaffe2_detectron_custom_ops_gpu.so: undefined symbol: _ZN6google8protobuf8internal9ArenaImpl28AllocateAlignedAndAddCleanupEmPFvPvE 坑
把protobuf卸载掉就好了，这个是因为系统中有两个protobuf的原因，
    
