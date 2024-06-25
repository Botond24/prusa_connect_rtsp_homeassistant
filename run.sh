#!/usr/bin/with-contenv bashio

trap "echo SIGINT received, exiting...; exit 0" INT

CAMERA_URLS=$(bashio::config 'CAMERA_URLS')
TOKENS=$(bashio::config 'TOKENS')
FRAME_CAPTURE_DELAY=$(bashio::config 'FRAME_CAPTURE_DELAY' 1)
CAMERA_CYCLE_DELAY=$(bashio::config 'CAMERA_CYCLE_DELAY' 10)
CONNECTION_TIMEOUT_DELAY=$(bashio::config 'CONNECTION_TIMEOUT_DELAY' 5)


bashio::log.info "     ██╗████████╗███████╗███████╗██████╗ ██████╗"
bashio::log.info "     ██║╚══██╔══╝██╔════╝██╔════╝╚════██╗██╔══██╗"
bashio::log.info "     ██║   ██║   █████╗  █████╗   █████╔╝██║  ██║"
bashio::log.info "██   ██║   ██║   ██╔══╝  ██╔══╝   ╚═══██╗██║  ██║"
bashio::log.info "╚█████╔╝   ██║   ███████╗███████╗██████╔╝██████╔╝"
bashio::log.info " ╚════╝    ╚═╝   ╚══════╝╚══════╝╚═════╝ ╚═════╝ "
bashio::log.info ""
bashio::log.info "This script sends snapshots of RTSP and MJPEG streams to Prusa Connect."
bashio::log.info ""
: "${PRUSA_URL:=https://webcam.connect.prusa3d.com/c/snapshot}"
: "${CAMERA_URLS:=}"
: "${TOKENS:=}"

declare log_level

log_level=$(bashio::string.lower "$(bashio::config log_level invalid)")
if [ "$log_level" = "invalid" ] || [ "$log_level" = "" ]; then
  #bashio::log.magenta 'Received invalid log_level from config, fallback to info'
  log_level="info"
fi
bashio::log.level "$log_level"

CAMERA_URLS=$(echo "$CAMERA_URLS" | tr -d ' ')
TOKENS=$(echo "$TOKENS" | tr -d ' ')
FRAME_CAPTURE_DELAY=${FRAME_CAPTURE_DELAY:-1}
CAMERA_CYCLE_DELAY=${CAMERA_CYCLE_DELAY:-10}
CONNECTION_TIMEOUT_DELAY=${CONNECTION_TIMEOUT_DELAY:-5}

readarray -t TOKENS <<<"$TOKENS"
readarray -t CAMERA_URLS <<< "$CAMERA_URLS"

FINGERPRINTS=()
for i in $(seq 1 ${#CAMERA_URLS[@]}); do
    FINGERPRINTS+=($(printf "camera%010d" $i))
done

bashio::log.info "Input variables:"
for i in "${!CAMERA_URLS[@]}"; do
    bashio::log.info "Camera $((i + 1)), URL: ${CAMERA_URLS[$i]}, ${TOKENS[$i]}"
done

while true; do
    for i in "${!CAMERA_URLS[@]}"; do
        bashio::log.debug "Processing camera: $((i + 1))"
        bashio::log.debug "URL: ${CAMERA_URLS[$i]}"
        bashio::log.debug "Token: ${TOKENS[$i]}"
        bashio::log.debug "Fingerprint: ${FINGERPRINTS[$i]}"
        bashio::log.debug "------"
        if [[ ${CAMERA_URLS[$i]} == *"rtsp"* ]]; then
            ffmpeg \
                -loglevel error \
                -y \
                -rtsp_transport tcp \
                -i "${CAMERA_URLS[$i]}" \
                -f image2 \
                -vframes 1 \
                -pix_fmt yuvj420p \
                -timeout "$CONNECTION_TIMEOUT_DELAY" \
                output_$i.jpg
        else
            ffmpeg \
                -loglevel error \
                -y \
                -i "${CAMERA_URLS[$i]}" \
                -f image2 \
                -vframes 1 \
                -pix_fmt yuvj420p \
                -timeout "$CONNECTION_TIMEOUT_DELAY" \
                output_$i.jpg
        fi

        if [ $? -eq 0 ]; then
            curl -X PUT "$PRUSA_URL" \
                -H "accept: */*" \
                -H "content-type: image/jpg" \
                -H "fingerprint: ${FINGERPRINTS[$i]}" \
                -H "token: ${TOKENS[$i]}" \
                --data-binary "@output_$i.jpg" \
                --no-progress-meter \
                --compressed \
                --max-time "$CONNECTION_TIMEOUT_DELAY"
        else
            bashio::log.error "FFmpeg returned an error for camera $((i + 1))."
        fi
        sleep "$FRAME_CAPTURE_DELAY"
    done

    sleep "$CAMERA_CYCLE_DELAY"
done
