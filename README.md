# MacBook Quick Diagnostics

A one-command macOS terminal diagnostic script to gather key information about a MacBook: hardware, battery, disk health, T2/iCloud status, and more.

> **Purpose**: Quickly assess the health of a MacBook before resale, purchase, support, or troubleshooting.

---

## 🛠️ Requirements

- macOS (tested on Intel and Apple Silicon)
- Terminal access with `sudo`
- [`smartmontools`](https://brew.sh) (will be installed automatically if missing)
- Internet connection (optional, for model decoding)
- Xcode Command Line Tools (will prompt to install if missing)

---

## 🚀 Installation & Usage

```bash
chmod +x check.sh
sudo ./check.sh
```

> `sudo` is required for temperature, fan, SMC and SMART data access.

If you see this message:

```
Error: You have not agreed to the Xcode license.
Please resolve this by running:
  sudo xcodebuild -license accept
```

you must install and accept the Xcode Command Line Tools license before proceeding.

---

## 🔍 What It Checks

### 1. 🔧 Auto-installs `smartmontools`

Ensures `smartctl` is available to fetch SSD SMART data. SMART is essential to monitor SSD health and wear levels.

### 2. 🔎 Model & Serial Number

- Prints Model Identifier and Serial Number
- Offers a direct Apple link for checking warranty and activation lock status
- If online, attempts to decode the serial into a human-readable model name (e.g., "MacBook Pro 15-inch, 2018")

### 3. 🧠 CPU Info

- Detects architecture: Intel or Apple Silicon (M1/M2...)
- Displays specific chip or CPU name for verification

> Useful for compatibility, resale value, and performance expectations

### 4. 🔥 CPU Temperature

- Uses `powermetrics` to report real-time CPU die temperature
- Helps spot thermal throttling or poor cooling (if always hot)

### 5. 💨 Fan Info

- Displays current fan RPM
- If RPMs are stuck high or non-zero at idle, it may indicate thermal or hardware issues

### 6. 🔐 FileVault Status

- Reports if FileVault disk encryption is turned on

> Required for secure resale or in corporate environments

### 7. 🛡️ T2 Security Chip

- Checks if the Mac contains the Apple T2 chip (used for Secure Boot, Touch ID, encrypted storage, etc.)
- If missing on Macs where it should exist, may indicate logic board replacement or downgrade

### 8. 🔐 iCloud Lock

- Detects if the device is linked to an Apple ID using NVRAM
- If locked, the device cannot be reused without the owner's Apple ID password

> Critical before resale — locked devices are effectively useless

### 9. 💾 Memory Info

- Lists memory modules with size/type/speed
- Calculates and displays total installed RAM

> Verifies upgradeability and actual configuration

### 10. 💾 Disk Info

- Reports whether the drive is SSD or HDD
- Checks SMART status (Verified = healthy)
- Lists connection type (PCIe/NVMe/SATA)

> Useful for performance and lifespan estimation

### 11. 📊 SMART Attributes

- Fetches drive age and wear metrics using `smartctl`
- Categorizes SSD health:
  - ✅ Excellent (<10%)
  - 🟢 Normal (10–30%)
  - 🟡 Moderate (30–60%)
  - 🔴 Bad (>60%)

> Great for predicting failures or verifying storage condition before sale

### 12. 🔍 SSD Authenticity Check

- Checks if the SSD is original Apple hardware
- Third-party SSDs may not support full power management, TRIM, or encryption

### 13. 🖥️ Display Info

- Reports display resolution and graphics chipset
- Detects if mirroring is active

> Helps verify display configuration or issues with external displays

### 14. 🎮 GPU Info

- Lists all active GPUs, their vendor (Intel/AMD/Apple), model, and VRAM amount

> Useful for identifying dual-GPU setups or discrete graphics performance

### 15. 🔋 Battery Health

- Shows current charge and cycle count
- Categorizes battery health:
  - ✅ Like new (<100 cycles)
  - 🟢 Normal (<500)
  - 🟡 Aging (<800)
  - 🔴 Replace Soon

> Useful to avoid buying/selling a Mac with worn-out battery

### 16. 📷 Camera

- Detects FaceTime HD camera presence
- If missing, may indicate hardware failure or tampering

### 17. 🔌 Charger Info

- Shows connected charger’s wattage and vendor ID
- Basic check for authenticity — Apple uses specific IDs and wattages

> Fake chargers may charge slowly or cause issues

### 18. 📶 Bluetooth Info

- Shows Bluetooth MAC address and whether it is currently enabled

> Verifies BT module works and wasn't disconnected (common in board repairs)

### 19. 🔍 USB Devices

- Lists internal USB Apple components (Touch Bar, T2, Bluetooth, etc.) by ID
- Helps detect if any are missing or malfunctioning

> Especially important for validating Touch Bar models and secure hardware bridges

### 20. 🕓 System Uptime

- How long the system has been running since last boot

> Good for spotting reboot loops or uptime-related diagnostics

### 21. ⏱ Last Boot Time

- Shows the last exact time the system was booted

> Correlate with update times, crash logs, or unexpected reboots

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

- You can manually check Apple warranty via the printed serial at: [https://checkcoverage.apple.com/](https://checkcoverage.apple.com/)

---

## 📄 License

MIT

---

## 🙌 Author

Crafted with ❤️ for MacBook diagnostics and safe device resales.

Feel free to fork, improve, or suggest enhancements.

