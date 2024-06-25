ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

# Install bash, curl, and ffmpeg
RUN apk add --no-cache bash curl ffmpeg

CMD [ "/run.sh" ]