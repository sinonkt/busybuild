FROM sinonkt/agnostic-box:latest

LABEL maintainer="oatkrittin@gmail.com"

ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/modules
ENV MODULES_HOME=/home/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all

# Create Modules user & Easybuild init script. Practices by dtu.dk
# https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#installing-easybuild specify MODULES_HOME
RUN mkdir -p $EASYBUILD_PREFIX $MODULES_HOME && \
  groupadd -g 984 modules && \
  useradd -ms /bin/bash -c "Modules user" -d $MODULES_HOME -u 984 -g modules modules && \
  chown -R modules:modules $EASYBUILD_PREFIX $MODULES_HOME && \
  chmod -R 775 $EASYBUILD_PREFIX $MODULES_HOME

# Switch to user `modules` to install EasyBuild
USER modules
WORKDIR $MODULES_HOME

ENV PATH="${PATH}:/opt/apps/lmod/lmod/libexec"
ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all
ENV MODULEPATH=/modules/modules/all

COPY init_easybuild.sh ~/.

RUN /bin/bash -c "source /etc/profile.d/z00_lmod.sh" && \
    curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py && \
    python bootstrap_eb.py $EASYBUILD_PREFIX && \
    rm -f bootstrap_eb.py && \
    echo "source /etc/profile.d/z00_lmod.sh" >> ~/.bashrc && \
    chmod u+x init_easybuild.sh

VOLUME [ "/ebs", "/modules" ]