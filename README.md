# MacBook Quick Diagnostics

A one-command macOS terminal diagnostic script to gather key information about a MacBook: hardware, battery, disk health, T2/iCloud status, and more.

> **Purpose**: Quickly assess the health of a MacBook before resale, purchase, support, or troubleshooting.

---

## 📦 Repository Name Suggestion
`macbook-quick-diagnostics`

---

## 🛠️ Requirements
- macOS (tested on Intel and Apple Silicon)
- Terminal access with `sudo`
- [`smartmontools`](https://brew.sh) (will be installed automatically if missing)

---

## 🚀 Installation & Usage
```bash
chmod +x check.sh
sudo ./check.sh
```
> `sudo` is required for temperature, fan, SMC and SMART data access.

---

## 🔍 What It Checks

### 1. 🔧 Auto-installs `smartmontools`
Ensures `smartctl` is available to fetch SSD SMART data.

### 2. 🔎 Model & Serial Number
- Model Identifier (e.g., `MacBookPro15,1`)
- Serial Number (with link to Apple warranty check)
- Attempts to translate model using Apple support lookup

### 3. 🧠 CPU Info
- Intel vs Apple Silicon detection
- Chip or CPU name shown accordingly

### 4. 🔥 CPU Temperature
- Uses `powermetrics` to read current CPU die temperature

### 5. 💨 Fan Info
- Reports current fan RPM if available

### 6. 🔐 FileVault Status
- Whether full-disk encryption is enabled

### 7. 🛡️ T2 Security Chip
- Detects Apple T2 presence

### 8. 🔐 iCloud Lock
- Checks for Activation Lock presence via NVRAM

### 9. 💾 Memory Info
- Lists each memory slot's size/type/speed
- Calculates and displays **total installed RAM**

### 10. 💾 Disk Info
- Shows disk type, SMART status, and whether it's an SSD

### 11. 📊 SMART Attributes
- Pulls wear/health indicators from `smartctl`
- Shows SSD health as percentage and categorizes:
  - ✅ Excellent
  - 🟢 Normal wear
  - 🟡 Moderate wear
  - 🔴 Needs attention

### 12. 🔍 SSD Authenticity Check
- Verifies if it's a genuine Apple SSD (starts with `APPLE SSD`)

### 13. 🖥️ Display Info
- Resolution, chipset model, and mirroring status

### 14. 🎮 GPU Info
- Detects all active GPUs
- Lists vendor, VRAM and model

### 15. 🔋 Battery Health
- Charge level and cycle count
- Interprets cycle health range:
  - ✅ Like new (<100)
  - 🟢 Normal (<500)
  - 🟡 Aging (<800)
  - 🔴 Needs replacement

### 16. 📷 Camera
- Detects FaceTime HD camera presence

### 17. 🔌 Charger Info
- Wattage and ID of connected AC adapter
- Basic authenticity check (Apple chargers use specific wattage and ID patterns)

### 18. 📶 Bluetooth Info
- Displays MAC address and status

### 19. 🔍 USB Devices
- Recognizes internal USB-based Apple devices by Product ID:
  - Touch Bar controllers
  - T2 bridge
  - Bluetooth, Camera, Audio
  - Trackpad/Keyboard bridge

### 20. 🕓 System Uptime
- Time since last reboot

### 21. ⏱ Last Boot Time
- Exact date/time of last macOS boot

---

## 📌 Example Output (abridged)
```
===== MACBOOK QUICK DIAGNOSTICS =====
Model Identifier: MacBookPro15,1
Serial Number: C02XXXXXXX5J
Translated Model: MacBook Pro (15-inch, 2018)
...
Battery status: 🟡 Aging (Cycle Count: 524)
SSD wear: 18% → 🟢 Normal wear
T2 Chip: ✅ Present
Activation Lock: ✅ Device is linked to an Apple ID
Camera: ✅ FaceTime HD detected and working
Charger authenticity: ✅ Likely genuine Apple charger
System Uptime: 51 days
Last Boot Date: 2025-06-03 08:01:47
✅ Completed
```

---

## 📋 Notes
- You can manually check Apple warranty via the printed serial at:
  https://checkcoverage.apple.com/

---

## 📄 License
MIT

---

## 🙌 Author
Crafted with ❤️ for MacBook diagnostics and safe device resales.

Feel free to fork, improve, or suggest enhancements.

