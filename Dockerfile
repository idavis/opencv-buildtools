ARG IMAGE
FROM $IMAGE

WORKDIR /app

COPY *.py ./

CMD [ "python3", "-u", "./main.py" ]