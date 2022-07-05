Linux ARM64 is not supported because of raisimTech/raisimLib#284.

## Start and interact with a container with Linux GUI support

### Preface

As of June 2022, the mainstream display server communications protocols are Wayland and X11. Only the use of the latter will be discussed below.

The container's name defualts to *surf*, as the container was developed for my XJTLU SURF in 2022.

### Linux

Let X Server accepts connections from Docker: `xhost +local:docker`

Start a container in detached mode:
```shell
> docker run -d -t --name surf -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ ghcr.io/minghongalexxu/ocs2
<containerID>
```
`-e DISPLAY=$DISPLAY` and `-v /tmp/.X11-unix/:/tmp/.X11-unix/` enable the container to display GUI on host.

Get a bash shell in the container, *surf*:
```shell
> docker exec -it surf /bin/bash
root@<containerID>:/path/to/workdir#
```

### Windows

Install X server, [VcXsrv](https://sourceforge.net/projects/vcxsrv/). Recommend using [Scoop](https://scoop.sh), a package manager for Windows.

Start the VcXsrv with access control disabled.

Start a container in detached mode:
```shell
> docker run -d -t --name surf -e DISPLAY=host.docker.internal:0 ghcr.io/minghongalexxu/ocs2
<containerID>
```
`-e DISPLAY=host.docker.internal:0` tells the container to display GUI on host's X server, VcXsrv.

Get a bash shell in the container, *surf*:
```shell
> docker exec -it surf /bin/bash
root@<containerID>:/path/to/workdir#
```

### macOS

Install X server, [Xquartz](https://www.xquartz.org). Recommend using [Homebrew](https://brew.sh), a package manager for macOS.

Indirect GLX enables the transmission of OpenGL commands from an X11 client to an X11 server. Enable it on Xquartz: `defaults write org.xquartz.X11 enable_iglx -bool true`

Check the config: `defaults read org.xquartz.X11`

Accept connection request from localhost: `xhost +localhost`

Start a container in detached mode:
```shell
> docker run -d -t --name surf -e DISPLAY=host.docker.internal:0 ghcr.io/minghongalexxu/ocs2
<containerID>
```
`-e DISPLAY=host.docker.internal:0` tells the container to display GUI on host's X server, Xquartz.

Get a bash shell in the container, *surf*:
```shell
> docker exec -it surf /bin/bash
root@<containerID>:/path/to/workdir#
```

### Graphics acceleration

- [Docker official doc on accessing Nvidia GPU](https://docs.docker.com/engine/reference/commandline/run/#access-an-nvidia-gpu)
- [ROS official doc on accelerated graphics](https://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration)



## Building image from source

1. Retrieve submodules: `git submodule update --init --recursive`
2. Build the Dockerfile
