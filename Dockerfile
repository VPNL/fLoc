# Create Docker container that can run fLoc analysis.

# Start with the Matlab r2017a runtime container
FROM  flywheel/matlab-mcr:v92.1

MAINTAINER Michael Perry <lmperry@stanford.edu>

############################
# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --force-yes \
    xvfb \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    zip \
    unzip \
    python \
    jq

# Set the diplay env variable for xvfb
ENV DISPLAY :1.0

RUN apt-get update && apt-get -y install \
        bc \
        tar \
        zip \
        wget \
        gawk \
        tcsh \
        python \
        libgomp1 \
        python2.7 \
        perl-modules

# Download Freesurfer v6.0.0 from MGH and untar to /opt
RUN wget -N -qO- ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz | tar -xz -C /opt && chown -R root:root /opt/freesurfer

# The brainstem and hippocampal subfield modules in FreeSurfer 6.0 require the Matlab R2012 runtime
RUN apt-get install -y libxt-dev libxmu-dev
ENV FREESURFER_HOME /opt/freesurfer
RUN wget -N -qO- "http://surfer.nmr.mgh.harvard.edu/fswiki/MatlabRuntime?action=AttachFile&do=get&target=runtime2012bLinux.tar.gz" | tar -xz -C $FREESURFER_HOME && chown -R root:root /opt/freesurfer/MCRv80

# ADD the Matlab Stand-Alone (MSA) into the container.
# COPY gear/bin/gear_floc /usr/local/bin/floc

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}

# Copy and configure run script and metadata code
COPY gear/run ${FLYWHEEL}/run
RUN chmod +x ${FLYWHEEL}/run
COPY gear/manifest.json ${FLYWHEEL}/manifest.json

# Configure entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
