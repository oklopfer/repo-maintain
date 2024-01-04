FROM ubuntu:latest
LABEL org.opencontainers.image.description "Contains Pacstall 4.3.1 Firebrick2"

SHELL ["/bin/bash", "-l", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ="Africa/Libreville"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG package="pacstall"

RUN if [[ $(dpkg --print-architecture) == "amd64" ]]; then dpkg --add-architecture i386; fi && apt-get update && apt-get dist-upgrade -y && apt-get install wget curl git sudo nano ca-certificates util-linux -y --fix-missing --no-install-recommends && apt-get clean && apt-get autoclean && apt-get autoremove -y

RUN adduser --disabled-password --gecos '' pacstall && adduser pacstall sudo
RUN echo N | sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install\?dnt || wget -q https://pacstall.dev/q/install\?dnt -O -)" && rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN chown -R pacstall:pacstall /var/log/pacstall && chown -R pacstall:pacstall /tmp/pacstall
RUN runuser -l pacstall -c 'HOME=/home/pacstall SUDO_USER=pacstall PACSTALL_DOWNLOADER=quiet-wget pacstall -PI rhino-neofetch-git'
RUN pkgver="$(runuser -l pacstall -c 'HOME=/home/pacstall SUDO_USER=pacstall pacstall -V' | awk '{print $1}')"; \
    style="$(runuser -l pacstall -c 'HOME=/home/pacstall SUDO_USER=pacstall pacstall -V' | awk '{print $2}' | sed 's/\x1b\[[0-9;]*m//g')"; \
    branch="$(lsb_release -cs)"; \
    echo "PRETTY_NAME=\"Pacstall ${pkgver} ${style}\"" | tee /usr/lib/os-release && \
    echo "NAME=\"Pacstall\"" >> /usr/lib/os-release  >> /usr/lib/os-release && \
    echo "VERSION_ID=\"${pkgver}\""  >> /usr/lib/os-release && \
    echo "VERSION=\"${pkgver} ${style}\""  >> /usr/lib/os-release && \
    echo "VERSION_CODENAME=\"${branch}\"" >> /usr/lib/os-release && \
    echo "ID=ubuntu" >> /usr/lib/os-release && \
    echo "ID_LIKE=debian" >> /usr/lib/os-release && \
    echo "HOME_URL=\"https://pacstall.dev/\"" >> /usr/lib/os-release && \
    echo "SUPPORT_URL=\"https://github.com/pacstall\"" >> /usr/lib/os-release && \
    echo "BUG_REPORT_URL=\"https://github.com/pacstall\"" >> /usr/lib/os-release && \
    echo "PRIVACY_POLICY_URL=\"https://www.ubuntu.com/legal/terms-and-policies/privacy-policy\"" >> /usr/lib/os-release && \
    echo "UBUNTU_CODENAME=\"${branch}\""  >> /usr/lib/os-release && \
    echo "neofetch" >> /home/pacstall/.bashrc

# https://askubuntu.com/a/1026978
RUN rm /etc/apt/apt.conf.d/docker-clean

USER pacstall
WORKDIR /home/pacstall

# ENTRYPOINT ["/bin/bash"]
CMD ["bash"]
