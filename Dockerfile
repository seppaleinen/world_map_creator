FROM petkr/gdal-python-alpine

RUN echo "http://mirror.leaseweb.com/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add --no-cache geos 

ENV ENVIRONMENT DOCKER
ENV PYTHONUNBUFFERED 1
ENV TZ Europe/Stockholm


RUN apk --update add build-base libxslt-dev

RUN apk add --virtual .build-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        gcc libc-dev geos-dev geos && \
    runDeps="$(scanelf --needed --nobanner --recursive /usr/local \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | xargs -r apk info --installed \
    | sort -u)" && \
    apk add --virtual .rundeps $runDeps

RUN geos-config --cflags

ADD ./requirements.txt .
RUN pip install --disable-pip-version-check -r requirements.txt

RUN apk del build-base python3-dev && \
    rm -rf /var/cache/apk/*

ADD processor.py .
ADD input_file.json .

ENTRYPOINT ["/bin/sh", "-c", "python processor.py input_file.json"]
