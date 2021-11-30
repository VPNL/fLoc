# Create Docker container that can run fLoc analysis.

# Start with the Matlab r2017b runtime container
FROM  flywheel/matlab-mcr:v93

MAINTAINER Michael Perry <lmperry@stanford.edu>


############################
# Install dependencies

RUN apt-get update && apt-get install -y --force-yes \
    xvfb \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    zip \
    unzip \
    jq \
    bc \
    tar \
    zip \
    wget \
    gawk \
    tcsh \
    libgomp1 \
    perl-modules \
    python-pip


############################
# Download Freesurfer v6.0.0 from MGH and untar to /opt

RUN wget -N -qO- ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz | tar -xz -C /opt && \
    chown -R root:root /opt/freesurfer && \
    rm -rf /opt/freesurfer/MCRv80 /opt/freesurfer/average /opt/freesurfer/subjects /opt/freesurfer/trctrain /opt/freesurfer/tktools && \
    touch /opt/freesurfer/.license && \
    chmod 777 /opt/freesurfer/.license


# Set the diplay env variable for xvfb
ENV DISPLAY :1.0

# Install Flywheel-SDK
RUN pip install flywheel-sdk>=12.04

# ADD the Matlab Stand-Alone (MSA) into the container.
# Must be compiled prior to gear build - this will fail otherwise
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
