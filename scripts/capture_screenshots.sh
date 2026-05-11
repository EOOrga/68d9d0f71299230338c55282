#!/usr/bin/env bash
set -euo pipefail

package_name="com.taziggg100.bretonnier_carole"
apk_path="build/app/outputs/flutter-apk/app-debug.apk"
screens_dir="docs/screens"

if [[ ! -f "${apk_path}" ]]; then
  echo "Missing ${apk_path}. Build the screenshot APK first." >&2
  exit 1
fi

mkdir -p "${screens_dir}"
touch "${screens_dir}/.gitkeep"
rm -f "${screens_dir}"/*.png

adb wait-for-device >/dev/null
adb shell wm size reset >/dev/null
adb shell wm density reset >/dev/null
adb shell settings put system accelerometer_rotation 0 >/dev/null
adb shell settings put system user_rotation 0 >/dev/null
adb shell settings put system font_scale 1.0 >/dev/null
adb shell input keyevent KEYCODE_WAKEUP >/dev/null || true
adb shell input keyevent KEYCODE_MENU >/dev/null || true
sleep 2

adb install -r "${apk_path}" >/dev/null
adb shell monkey -p "${package_name}" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 5

size="$(adb shell wm size | tr -d '\r' | sed -nE 's/.* ([0-9]+)x([0-9]+)/\1x\2/p' | tail -n 1)"
width="${size%x*}"
height="${size#*x}"
nav_y=$((height - 130))

tap_nav() {
  local slot="$1"
  local x=$((width * slot / 10))
  adb shell input tap "${x}" "${nav_y}" >/dev/null
  sleep 2
}

capture() {
  local name="$1"
  adb exec-out screencap -p > "${screens_dir}/${name}.png"
}

capture "01_dashboard"
tap_nav 3
capture "02_leads"
tap_nav 5
capture "03_bookings"
tap_nav 7
capture "04_quality"
tap_nav 9
capture "05_shifts"
adb shell input tap $((width - 90)) 220 >/dev/null
sleep 2
capture "06_settings_privacy"
