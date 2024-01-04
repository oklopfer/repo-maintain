FROM ubuntu:devel
LABEL org.opencontainers.image.description "Contains Rhino Linux 2023.4"

SHELL ["/bin/bash", "-l", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ="Africa/Libreville"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG package="pacstall"

RUN if [[ $(dpkg --print-architecture) == "amd64" ]]; then dpkg --add-architecture i386; fi && apt-get update && apt-get dist-upgrade -y && apt-get install wget curl git sudo nano ca-certificates util-linux lsb-release adduser dpkg-dev apt-utils -y --fix-missing --no-install-recommends && apt-get clean && apt-get autoclean && apt-get autoremove -y
RUN VERSION_CODENAME="$(lsb_release -cs)" && sudo sed -i "s/$VERSION_CODENAME/.\/devel/g" /etc/apt/sources.list && sudo apt-get update
RUN adduser --disabled-password --gecos '' rhino && adduser rhino sudo
RUN sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install\?dnt || wget -q https://pacstall.dev/q/install\?dnt -O -)" && rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -R rhino:rhino /var/log/pacstall && chown -R rhino:rhino /tmp/pacstall
RUN chown -R rhino:rhino /var/log/pacstall && chown -R rhino:rhino /tmp/pacstall
RUN runuser -l rhino -c 'HOME=/home/rhino SUDO_USER=rhino PACSTALL_DOWNLOADER=quiet-wget pacstall -PI nala-deb rhino-server-core'
RUN echo "neofetch" >> /home/rhino/.bashrc
# https://askubuntu.com/a/1026978
RUN rm /etc/apt/apt.conf.d/docker-clean

USER rhino
WORKDIR /home/rhino

# ENTRYPOINT ["/bin/bash"]
CMD ["bash"]
