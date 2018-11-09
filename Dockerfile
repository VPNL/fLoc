# Create Docker container that can run fLoc analysis.

# Start with the Matlab r2017b runtime container
FROM  flywheel/matlab-mcr:v93

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
COPY --from=scitran/freesurfer-recon-all:0.1.4 /opt/freesurfer /opt/freesurfer
RUN touch /opt/freesurfer/.license && chmod 777 /opt/freesurfer/.license

RUN apt-get update && \
        apt-get install -y python-pip &&  \
        pip install flywheel-sdk

# ADD the Matlab Stand-Alone (MSA) into the container.
COPY gear/bin/fLocGearRun \
     gear/bin/run_fLocGearRun.sh \
     /usr/local/bin/

# Make directory for flywheel spec (v0)
ENV FLYWHEEL /flywheel/v0
RUN mkdir -p ${FLYWHEEL}

# Copy and configure run script and metadata code
COPY gear/run.py ${FLYWHEEL}/run
RUN chmod +x ${FLYWHEEL}/run
COPY gear/manifest.json ${FLYWHEEL}/manifest.json

# Configure entrypoint
ENTRYPOINT ["/flywheel/v0/run"]
