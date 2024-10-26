# make sure the host drivers >= cuda11.8 corresponding version
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Setup time zone and locale data (necessary for SSL and HTTPS packages)
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -y \
    tzdata \
    locales \
    keyboard-configuration \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8

# Install common tools and ubuntu graphic desktop and vnc+novnc
# deps in https://github.com/o3de/o3de/blob/development/scripts/build/build_node/Platform/Linux/package-list.ubuntu-jammy.txt
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -y \
    bc \
    bind9-utils \
    binutils \
    ca-certificates \
    clang \
    cmake \
    curl \
    dbus-x11 \
    file \
    firewalld \
    git \
    git-lfs \
    jq \
    kbd \
    kmod \
    less \
    lsb-release \
    libglu1-mesa-dev \
    libxcb-xinerama0 \
    libfontconfig1-dev \
    libcurl4-openssl-dev \
    libnvidia-gl-470 \
    libssl-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    libxkbcommon-dev \
    libxcb-xfixes0-dev \
    libxcb-xinput-dev \
    libxcb-xinput0 \
    libpcre2-16-0 \
    lsof \
    net-tools \
    ninja-build \
    novnc \
    openssh-server \
    pciutils \
    python3-pip \
    software-properties-common \
    sudo \
    supervisor \
    tar \
    unzip \
    vim \
    wget \
    x11vnc xvfb \
    xfce4 xfce4-goodies \
    xz-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root

ADD startup.sh ./
ADD supervisord.conf ./

EXPOSE 5900
EXPOSE 22

# ROS2 humble
RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null


ARG ROS_DISTRO=humble
# Gem + ROS pacakges
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install --no-install-recommends -y \
    ros-humble-desktop \
    ros-dev-tools \
    ros-$ROS_DISTRO-ackermann-msgs \
    ros-$ROS_DISTRO-control-toolbox \
    ros-$ROS_DISTRO-gazebo-msgs \
    ros-$ROS_DISTRO-joy \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-rviz2 \
    ros-$ROS_DISTRO-tf2-ros \
    ros-$ROS_DISTRO-urdfdom \
    ros-$ROS_DISTRO-vision-msgs \
    ros-$ROS_DISTRO-nav2-bringup \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

## Symlink clang version to non-versioned clang and set cc to clang
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# O3DE 2310.1
ENV O3DE_HASH=c89678d6ba58271c76650e7aec180a3196f24f02

# ROS2GEM 2310.1
ENV O3DE_EXTRAS_HASH=f21f48125a24517bd6c29fd95ee97a85d546f675
ENV PROJECT_NAME=eail

ENV WORKDIR=/data/workspace
WORKDIR $WORKDIR

# Install o3de
RUN git clone https://github.com/o3de/o3de.git \
    && cd o3de \
    && git checkout ${O3DE_HASH} \
    && git lfs install \
    && git lfs pull \
    && python/get_python.sh

# Install o3de-extras
RUN git clone https://github.com/o3de/o3de-extras.git \
    && cd o3de-extras \
    && git checkout ${O3DE_EXTRAS_HASH} \
    && git lfs install \
    && git lfs pull

# regiester engine and Gems from o3de-extras
RUN ./o3de/scripts/o3de.sh register --this-engine \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/ROS2 \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/RosRobotSample \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/WarehouseSample 

# create in project from template in o3de-extras
RUN ./o3de/scripts/o3de.sh create-project \
    --project-path ${WORKDIR}/${PROJECT_NAME} \
    --template-path ./o3de-extras/Templates/Ros2ProjectTemplate/ -f

WORKDIR ${WORKDIR}/${PROJECT_NAME}

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && cmake -B build/linux -S . -G "Ninja Multi-Config" -DLY_STRIP_DEBUG_SYMBOLS=ON

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && cmake --build build/linux --config profile --target ${PROJECT_NAME} Editor AssetProcessor -j 15

# This final step takes long since they Assets will be downloading
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && echo "This final step can take more than 1 hour. Good time for going for a coffee :)" \
    && cmake --build build/linux --config profile --target ${PROJECT_NAME}.Assets -j 15

RUN pip install --no-cache-dir python-statemachine 

# add 3dgs gem

# add 3dgs depends cuda
WORKDIR /root/.o3de/3rdParty/packages/
RUN mkdir -p cuda-11.4-rev1-windows/cuda/lib/x64/ \
    && ln -s /usr/local/cuda/include cuda-11.4-rev1-windows/cuda/include \
    && ln -s /usr/local/cuda/lib64/libcudart_static.a cuda-11.4-rev1-windows/cuda/lib/x64/libcudart_static.a

ADD cuda/* ./cuda-11.4-rev1-windows/

WORKDIR /root

ENTRYPOINT ["./startup.sh"]
