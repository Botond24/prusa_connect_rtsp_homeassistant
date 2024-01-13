# Home Assistant Add-on: Prusa Connect RSTP

## Installation

Follow these steps to get the add-on installed on your system:

[![Add repository on my Home Assistant][repository-badge]][repository-url]

1. Click on the above badge.
2. Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on store**.
3. Find the "Prusa Connect RTSP" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

1. Add `CAMERA_URLS` to your add-on configuration.
2. Add `TOKENS` to your add-on configuration.
3. Start the add-on.

## Add-on Configuration

The MariaDB server add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```yaml
CAMERA_URLS: ["http://244.178.44.111:8080"]
TOKENS: ["ahdfblagfzVuzhuh"]
```

### Option: `CAMERA_URLS` (required)

This section defines the URLs of the cameras. For example, `rstp://244.178.44.111:554/video/channel/1` or `http://244.178.44.111:8080`.

### Option: `TOKENS` (required)

This section defines the tokens of the cameras in the same order as `CAMERA_URLS`.

### Option: `FRAME_CAPTURE_DELAY` (optional)

How many seconds should be waited between each camera's frame capture. Default is `1`.

### Option: `CAMERA_CYCLE_DELAY` (optional)

How many seconds should be waited restarting the cycle. Default is `10`.

### Option: `CONNECTION_TIMEOUT_DELAY` (optional)

How many seconds should be waited for the connection to be established. Default is `5`.

### Option: `log_level` (optional)

This section defines the log level of the add-on.

## Support

In case you've found a bug, please [open an issue on our GitHub][issue].

[issue]: https://github.com/Botond24/prusa_connect_rtsp_homeassistant/issues
[repository-badge]: https://img.shields.io/badge/Add%20repository%20to%20my-Home%20Assistant-41BDF5?logo=home-assistant&style=for-the-badge
[repository-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/Botond24/prusa_connect_rtsp_homeassistant