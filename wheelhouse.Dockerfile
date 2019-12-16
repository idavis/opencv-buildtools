
ARG IMAGE
FROM ${IMAGE} as base

RUN apt-get update && apt-get install -y \
    cmake 3.12 \
    git \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Pillow requirements
RUN apt-get update && apt-get install -y \
    python3-setuptools \
    libjpeg-dev \
    libopenjp2-7-dev \
    libtiff5-dev \
    zlib1g-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install wheel  
RUN mkdir /wheelhouse
ENV PIP_WHEEL_DIR=/wheelhouse
ENV WHEELHOUSE=/wheelhouse
ENV PIP_FIND_LINKS=/wheelhouse

ARG REQUIREMENTS_FILE
COPY /${REQUIREMENTS_FILE} /requirements.txt
RUN while read p; do python3 -m pip wheel $p; done < requirements.txt && \
    mv /requirements.txt /wheelhouse/

FROM ${IMAGE}

COPY --from=base /wheelhouse /wheelhouse/
