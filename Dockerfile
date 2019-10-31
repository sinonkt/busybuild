FROM sinonkt/agnostic-box:latest

LABEL maintainer="oatkrittin@gmail.com"

ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/modules
ENV MODULES_HOME=/home/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all

RUN mkdir -p $EASYBUILD_PREFIX $MODULES_HOME

COPY init_easybuild.sh ${MODULES_HOME}/.

# Create Modules user & Easybuild init script. Practices by dtu.dk
# https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#installing-easybuild specify MODULES_HOME
RUN groupadd -g 1000 modules && \
  useradd -ms /bin/bash -c "Modules user" -d $MODULES_HOME -u 1000 -G wheel sudo -p modules -g modules modules && \
  chown -R modules:modules $EASYBUILD_PREFIX $MODULES_HOME && \
  chmod -R 775 $EASYBUILD_PREFIX $MODULES_HOME /usr/local/bin

RUN yum remove -y epel-release && \
  wget https://rpmfind.net/linux/centos/7.7.1908/extras/x86_64/Packages/epel-release-7-11.noarch.rpm && \
  rpm -ivh epel-release-7-11.noarch.rpm && \
  yum update -y && \
  yum install -y git vim \
    openssl-devel \
    libopenssl-devel \
    libssl-dev \
    patch

# Switch to user `modules` to install EasyBuild
USER modules
WORKDIR $MODULES_HOME

ENV PATH="${PATH}:/opt/apps/lmod/lmod/libexec"
ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all
ENV MODULEPATH=/modules/modules/all

RUN /bin/bash -c "source /etc/profile.d/z00_lmod.sh" && \
    echo "source /etc/profile.d/z00_lmod.sh" >> ~/.bashrc

VOLUME [ "/ebs", "/modules" ]