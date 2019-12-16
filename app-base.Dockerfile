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

# Install requirements.txt pre-built dependencies
COPY --from=wheelhouse /wheelhouse /wheelhouse/
RUN ls -1 -d /wheelhouse/*.whl | xargs python3 -m pip install --no-cache-dir && \
    rm -rf /wheelhouse

# Using apt-get instead of dpkg to install OpenCV and all libs it depends on. 
# If OpenCV is ever rebuilt to add/remove a feature, this will automatically adjust itself.
COPY --from=opencv-dependencies /dist /dist/
RUN apt-get update && apt-get install -y --no-install-recommends /dist/*.deb && \
    rm -rf /dist && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ldconfig
