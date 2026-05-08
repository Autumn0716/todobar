#!/usr/bin/env bash
set -euo pipefail

APP_NAME="TodoBar"
PRODUCT_NAME="TodoBar"
CONFIGURATION="debug"
BUNDLE_ID="local.TodoBar"
MIN_SYSTEM_VERSION="14.0"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
EXECUTABLE_PATH="${MACOS_DIR}/${APP_NAME}"
MODE="${1:-run}"

usage() {
  cat <<EOF
Usage: $0 [run|--verify|--logs|--telemetry|--debug]

Builds ${PRODUCT_NAME}, stages ${APP_DIR}, and launches it with /usr/bin/open -n.

Options:
  run          Build and launch the app.
  --logs       After launch, stream recent macOS logs for ${APP_NAME}.
  --telemetry  After launch, stream unified logs filtered to ${BUNDLE_ID}.
  --verify     Launch the app and verify the ${APP_NAME} process exists.
  --debug      Build and open the staged executable in lldb.
EOF
}

case "${MODE}" in
  run|--verify|verify|--logs|logs|--telemetry|telemetry|--debug|debug) ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: ${MODE}" >&2
    usage >&2
    exit 2
    ;;
esac

if [[ ! -f Package.swift ]]; then
  echo "Package.swift not found. Run this from the SwiftPM project root." >&2
  exit 1
fi

echo "Stopping existing ${APP_NAME} processes..."
/usr/bin/pkill -x "${APP_NAME}" 2>/dev/null || true

echo "Building ${PRODUCT_NAME} (${CONFIGURATION})..."
swift build --configuration "${CONFIGURATION}" --product "${PRODUCT_NAME}"

BUILD_BINARY="$(swift build --configuration "${CONFIGURATION}" --product "${PRODUCT_NAME}" --show-bin-path)/${PRODUCT_NAME}"
if [[ ! -x "${BUILD_BINARY}" ]]; then
  echo "Built executable not found at ${BUILD_BINARY}" >&2
  exit 1
fi

echo "Staging ${APP_DIR}..."
/bin/rm -rf "${APP_DIR}"
/bin/mkdir -p "${MACOS_DIR}"
/bin/cp "${BUILD_BINARY}" "${EXECUTABLE_PATH}"
/bin/chmod +x "${EXECUTABLE_PATH}"

cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>${MIN_SYSTEM_VERSION}</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
</dict>
</plist>
EOF

/usr/bin/plutil -lint "${CONTENTS_DIR}/Info.plist" >/dev/null

open_app() {
  echo "Launching ${APP_NAME}..."
  /usr/bin/open -n "${APP_DIR}"
}

case "${MODE}" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "${EXECUTABLE_PATH}"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"${APP_NAME}\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"${BUNDLE_ID}\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "${APP_NAME}" >/dev/null
    echo "Verified ${APP_NAME} is running."
    ;;
esac
