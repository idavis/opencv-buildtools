ARG IMAGE
FROM ${IMAGE}
RUN mkdir /dist
COPY ./  ./dist