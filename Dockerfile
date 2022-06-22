FROM ubuntu:focal
LABEL Name=ocs2 Version=2022.06.23

RUN apt-get update && apt-get install --yes --no-install-recommends \
        gnupg \
        wget \
    && wget http://packages.ros.org/ros.key -O - | apt-key add - && \
       echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
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
        # Optional dependencies
        ros-noetic-rqt-multiplot \
        ros-noetic-grid-map-msgs

WORKDIR /tmp/install
COPY deps/raisimLib raisimLib
RUN cd raisimLib && mkdir build && cd build \
    && cmake .. -DRAISIM_EXAMPLE=ON -DRAISIM_PY=ON -DPYTHON_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") \
    && make -j4 && checkinstall

WORKDIR /opt/ocs2/src
COPY deps/catkin-pkgs .
RUN catkin init --workspace .. \
    && catkin config --extend /opt/ros/noetic \
    && catkin config -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && catkin build ocs2

WORKDIR /home/surf
