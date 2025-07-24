#!/bin/bash

set -e

echo "===== MACBOOK QUICK DIAGNOSTICS ====="

## Install xcode clt in not installed
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Xcode Command Line Tools not found. Please run:"
  echo "xcode-select --install"
  exit 1
fi

### 🔧 Install smartmontools if not installed
if ! command -v smartctl >/dev/null 2>&1; then
  echo "Installing smartmontools via Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found! Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
  fi
  brew install smartmontools
fi

### 🔎 Model and Serial
echo -e "\n🔎 Model and Serial Number:"
MODEL_ID=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Identifier/ {print $2}')
SERIAL=$(system_profiler SPHardwareDataType | awk -F': ' '/Serial Number \(system\)/ {print $2}')
echo "Model Identifier: $MODEL_ID"
echo "Serial Number: $SERIAL Check warranty and activation: https://checkcoverage.apple.com/coverage"
MAC_MODEL=$(curl -s "https://support-sp.apple.com/sp/product?cc=${SERIAL: -4}" | sed -n 's:.*<configCode>\(.*\)</configCode>.*:\1:p')
if [[ "$MAC_MODEL" != "" ]]; then
  echo "Translated Model: $MAC_MODEL"
else
  echo "Translated Model: ⚠ Not found (possibly custom or non-retail unit)"
fi

echo -e "\n🧠 CPU Info:"
CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
  echo "Architecture: Intel x86_64"
  echo "CPU: $CPU_BRAND"
else
  CHIP=$(system_profiler SPHardwareDataType | awk -F': ' '/Chip/ {print $2}')
  echo "Architecture: Apple Silicon ($ARCH)"
  echo "Chip: $CHIP"
fi

### 🔥 CPU Temp
echo -e "\n🔥 CPU Temperature:"
powermetrics --samplers smc -n1 | grep -i "CPU die temperature"

### 💨 Fans
echo -e "\n💨 Fan Info:"
FAN_INFO=$(powermetrics --samplers smc -n1 | grep -i fan)
if [[ "$FAN_INFO" == "" ]]; then
  echo "Fan info not available (may be idle or unsupported)"
else
  echo "$FAN_INFO"
fi

echo -e "\n🔐 FileVault Status:"
fdesetup status

echo -e "\n🛡️ Secure Boot / T2 Status:"
T2_INFO=$(system_profiler SPiBridgeDataType 2>/dev/null)
if echo "$T2_INFO" | grep -q "Apple T2 Security Chip"; then
  echo "T2 Chip: ✅ Present"
else
  echo "T2 Chip: 🔴 Not found"
fi

### 🔐 iCloud Lock
echo -e "\n🔐 iCloud / Activation Lock status:"
if nvram -p | grep -q "fmm-mobileme-token-FMM"; then
  echo "Activation Lock: ✅ Device is linked to an Apple ID"
else
  echo "Activation Lock: 🔒 Not linked (no iCloud token found)"
fi

### Memory and display
echo -e "\n💾 Memory Info:"
MEMORY_LINES=$(system_profiler SPMemoryDataType | grep -E 'Size' | grep 'GB')
echo "$MEMORY_LINES"
TOTAL_GB=$(echo "$MEMORY_LINES" | awk '{sum += $2} END {print sum}')
echo "Total Memory: ${TOTAL_GB} GB"

### 💾 Disk Info
echo -e "\n💾 Disk:"
diskutil info disk0 | grep -E 'Device Node|Protocol|Internal|SMART|Device Name|Media Name|Solid State'

echo -e "\nSMART details:"
smartctl -a /dev/disk0 | grep -Ei 'Model|Serial|Power_On_Hours|Wear_Leveling_Count|Temperature|Percentage|Media_Wearout_Indicator'
WEAR=$(smartctl -a /dev/disk0 | awk '/Percentage Used:/ {print $3}' | tr -d '%')
if [[ "$WEAR" != "" ]]; then
  echo "SSD wear: ${WEAR}%"
  if [ "$WEAR" -lt 10 ]; then
    echo "SSD status: ✅ Excellent"
  elif [ "$WEAR" -lt 30 ]; then
    echo "SSD status: 🟢 Normal wear"
  elif [ "$WEAR" -lt 60 ]; then
    echo "SSD status: 🟡 Moderate wear"
  else
    echo "SSD status: 🔴 Consider replacing soon"
  fi
else
  echo "SSD wear info: Not available"
fi

echo -e "\n🖥️ Display Info:"
system_profiler SPDisplaysDataType | grep -E 'Resolution|Chipset|Display Type|Mirror' || echo "Display not detected"

echo -e "\n🎮 GPU Summary:"
system_profiler SPDisplaysDataType 2>/dev/null | awk '
/Chipset Model:/ {model=$3 " " $4; next}
/VRAM/ {vram=$2 " " $3; next}
/Vendor/ {
  vendor=$2;
  printf "• %s (%s VRAM) — %s\n", model, vram, vendor
}'

### 🔋 Battery
echo -e "\n🔋 Battery:"
pmset -g batt
CYCLE_COUNT=$(system_profiler SPPowerDataType | awk -F': ' '/Cycle Count/ {print $2}')
echo "Cycle Count: $CYCLE_COUNT"
if [ "$CYCLE_COUNT" -lt 100 ]; then
  echo "Battery status: ✅ Like new"
elif [ "$CYCLE_COUNT" -lt 500 ]; then
  echo "Battery status: 🟢 Normal usage"
elif [ "$CYCLE_COUNT" -lt 800 ]; then
  echo "Battery status: 🟡 Aging"
else
  echo "Battery status: 🔴 Needs replacement soon"
fi


### Camera
echo -e "\n📷 Camera Check:"
CAM_PRESENT=$(system_profiler SPCameraDataType 2>/dev/null | grep -A3 "FaceTime HD Camera" | grep -i "Unique ID")
if [[ -n "$CAM_PRESENT" ]]; then
  echo "Camera: ✅ FaceTime HD detected and working"
else
  echo "Camera: ⚠ FaceTime HD not detected"
fi

echo -e "\n🔍 SSD Authenticity Check:"
SSD_MODEL=$(smartctl -a /dev/disk0 | awk -F':' '/Model Number/ {print $2}' | xargs)
if [[ "$SSD_MODEL" =~ ^APPLE\ SSD ]]; then
  echo "SSD model: $SSD_MODEL"
  echo "SSD authenticity: ✅ Genuine Apple OEM drive"
else
  echo "SSD model: $SSD_MODEL"
  echo "SSD authenticity: ⚠ Possibly third-party replacement"
fi

echo -e "\n🔍 Identified USB Devices:"
system_profiler SPUSBDataType 2>/dev/null | awk '
  /Product ID/ {pid=$3}
  /Vendor ID/ {
    desc="Unknown Apple Device"
    if (pid=="0x8102") desc="Touch Bar Controller 1 (Touch input)"
    if (pid=="0x8103") desc="Touch Bar Controller 2 (Backlight / Display)"
    if (pid=="0x8302") desc="T2 Security Bridge"
    if (pid=="0x027c") desc="USB Audio (Microphone / Speakers)"
    if (pid=="0x8262") desc="Bluetooth Controller"
    if (pid=="0x8514") desc="FaceTime HD Camera"
    if (pid=="0x8233") desc="Keyboard/Trackpad Bridge"
    print "  ✅ " pid " → " desc
  }
'

echo -e "\n📶 Bluetooth Check:"
BT_INFO=$(system_profiler SPBluetoothDataType 2>/dev/null)
BT_ADDRESS=$(echo "$BT_INFO" | awk '/Address: / {print $2; exit}')
BT_STATE=$(echo "$BT_INFO" | awk '/State:/ {print $2; exit}')

if [[ "$BT_STATE" == "On" || -n "$BT_ADDRESS" ]]; then
  echo "Bluetooth: ✅ Enabled (MAC: $BT_ADDRESS)"
else
  echo "Bluetooth: 🔴 Off or not available"
fi


### 🔌 AC Charger
echo -e "\n🔌 AC Power Adapter:"
system_profiler SPPowerDataType | grep -A5 "AC Charger Information"

echo -e "\n🔍 Charger Authenticity Check:"
CHARGER_WATT=$(system_profiler SPPowerDataType | awk -F': ' '/Wattage/ {print $2}' | head -n 1)
CHARGER_ID=$(system_profiler SPPowerDataType | awk -F': ' '/ID/ {print $2}' | head -n 1)

echo "Charger Wattage: ${CHARGER_WATT}W"
echo "Charger ID: $CHARGER_ID"

if [[ "$CHARGER_WATT" -ge 85 && "$CHARGER_WATT" -le 96 && "$CHARGER_ID" =~ ^0x ]]; then
  echo "Charger authenticity: ✅ Likely genuine Apple charger"
else
  echo "Charger authenticity: ⚠ Unrecognized or third-party adapter"
fi


### 🕓 Uptime
echo -e "\n🕓 System Uptime:"
uptime

echo -e "\n⏱ Last Boot Date:"
last_boot=$(sysctl -n kern.boottime | awk -F'[ ,}]' '{print $4}')
date -j -f "%s" "$last_boot" "+%Y-%m-%d %H:%M:%S"

echo -e "\n✅ Completed"


