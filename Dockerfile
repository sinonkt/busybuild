FROM sinonkt/agnostic-box:latest

LABEL maintainer="oatkrittin@gmail.com"

ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/home/opt/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all

# Create Modules user & Easybuild init script. Practices by dtu.dk
# https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#installing-easybuild specify MODULES_HOME
RUN mkdir -p $EASYBUILD_PREFIX && \
  groupadd -g 984 modules && \
  useradd -ms /bin/bash -c "Modules user" -d $EASYBUILD_PREFIX -u 984 -g modules modules && \
  chown -R modules:modules $EASYBUILD_PREFIX && \
  chmod -R 775 $EASYBUILD_PREFIX

# Switch to user `modules` to install EasyBuild
USER modules
WORKDIR $EASYBUILD_PREFIX

ENV PATH="${PATH}:/opt/apps/lmod/lmod/libexec"
ENV EASYBUILD_MODULES_TOOL=Lmod
ENV EASYBUILD_PREFIX=/home/opt/modules
ENV ALL_MODULES=${EASYBUILD_PREFIX}/modules/all
ENV MODULEPATH=/home/opt/modules/modules/all

RUN /bin/bash -c "source /etc/profile.d/z00_lmod.sh" && \
    curl -O https://raw.githubusercontent.com/easybuilders/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py && \
    python bootstrap_eb.py $EASYBUILD_PREFIX && \
    rm -f bootstrap_eb.py && \
    echo "source /etc/profile.d/z00_lmod.sh" >> ~/.bashrc

VOLUME [ "${EASYBUILD_PREFIX}/ebs", "$MODULEPATH"]