ARG WHEELHOUSE
ARG OPENCV_DEPENDENCIES
ARG IMAGE
FROM ${WHEELHOUSE} as wheelhouse

ARG OPENCV_DEPENDENCIES
ARG IMAGE
FROM ${OPENCV_DEPENDENCIES} as opencv-dependencies

ARG IMAGE
FROM ${IMAGE} as base

ENV PYTHONPATH="/usr/lib/python3.7/site-packages:/usr/lib/python3.7/dist-packages:${PYTHONPATH}"

COPY --from=wheelhouse /wheelhouse /wheelhouse/
RUN ls -1 -d /wheelhouse/*.whl | xargs python3 -m pip install --no-cache-dir && \
    rm -rf /wheelhouse

# OpenCV Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        libavcodec-extra58 \
        libavformat58 \
        libavutil56 \
        libcairo2 \
        libgtk-3-0 \
        libswscale5 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=opencv-dependencies /dist /dist/
RUN dpkg --install /dist/*.deb && \
    rm -rf /dist

RUN ldconfig

COPY /*.py /















