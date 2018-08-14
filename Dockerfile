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
