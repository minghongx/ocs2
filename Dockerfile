FROM ubuntu:focal
LABEL Name=ocs2 Version=2022.07.05

RUN apt-get update && apt-get install --yes --no-install-recommends \
        gnupg \
        wget \
    && wget http://packages.ros.org/ros.key -O - | apt-key add - && \
       echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        # Both GCC 11 and Clang fail to compile OCS2. It seems that only GCC 9 can be used
        build-essential \
        make \
        cmake \
        ros-noetic-cmake-modules \
        # Catkin
        ros-noetic-pybind11-catkin python3-catkin-tools \
        # Eigen 3.3, GLPK, and Boost C++ 1.71
        libeigen3-dev libglpk-dev libboost-all-dev \
        # Doxyge
        doxygen doxygen-latex graphviz \
        # Dependencies of hpp-fcl and pinocchio
        liburdfdom-dev liboctomap-dev libassimp-dev \
        # Dependencies of blasfeo_catkin
        git \
        # Make the installation of raisimLib easy to find for catkin and easy to uninstall in the future
        checkinstall \
        # Dependencies of OCS2
        ros-noetic-common-msgs \
        ros-noetic-interactive-markers \
        ros-noetic-tf \
        ros-noetic-urdf \
        ros-noetic-kdl-parser \
        ros-noetic-robot-state-publisher \
        ros-noetic-rviz \
        ros-noetic-grid-map-rviz-plugin \
        # Official examples use GUI
        gnome-terminal \
        dbus-x11 \
        libcanberra-gtk-module libcanberra-gtk3-module \
        # Optional dependencies
        ros-noetic-rqt-multiplot \
        ros-noetic-grid-map-msgs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/install
COPY deps/raisimLib raisimLib
# RaiSim is not supported on Linux ARM64. See https://github.com/raisimTech/raisimLib/issues/284
RUN cd raisimLib && mkdir build && cd build \
    && cmake .. -DRAISIM_EXAMPLE=ON -DRAISIM_PY=ON -DPYTHON_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") \
    && make -j4 && checkinstall \
    && rm -rf /tmp/* /var/tmp/*

WORKDIR /catkin_ws/src
COPY deps/catkin-pkgs .
RUN catkin init --workspace .. \
    && catkin config --extend /opt/ros/noetic \
    && catkin config -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && catkin build ocs2

# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container
# Workaround: https://hub.docker.com/_/debian/
RUN apt-get update && apt-get install --yes locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Workaround: https://askubuntu.com/questions/432604/couldnt-connect-to-accessibility-bus
ENV NO_AT_BRIDGE=1
