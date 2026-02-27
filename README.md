# Linux-toolbox
Linux Toolbox is a lightweight, interactive bash script for Linux server management. It provides system info, file tools, network utilities, monitoring, repo switching, Python/Node.js installation, and swap management. Simple, safe, and compatible with most Linux distributions.

### English Description for Linux Toolbox Script
Here’s a professional, concise English description for your Linux Toolbox bash script (optimized for documentation/website use):

---

# Linux Toolbox v1.0.0
A comprehensive, interactive bash script designed to simplify system administration tasks on Linux-based operating systems. This all-in-one tool provides an intuitive menu-driven interface for both beginners and experienced system administrators, with pre-built functionality to streamline common Linux operations across different distributions (Debian/Ubuntu, RHEL/CentOS, Rocky Linux, AlmaLinux, Fedora, etc.).

## Core Features
- **System Information**: Detailed hardware/software diagnostics (OS version, CPU/memory/disk usage, hardware details, and customizable system reports).
- **File Operations**: Advanced file management tools (large/old/duplicate file search, temp file cleanup, permission checks, text search/replace/compare, directory tree visualization).
- **Network Utilities**: Network interface management, connectivity testing (ping/DNS), port scanning, open port detection, and route tracing.
- **System Monitoring**: Real-time process management, resource utilization tracking (CPU/memory/disk), system log analysis, service status checks, and boot time profiling.
- **Package Source Management**: One-click replacement of system repositories (APT/YUM/DNF) with domestic mirrors (Alibaba Cloud, Tencent Cloud, Huawei Cloud, Tsinghua University) and EPEL repository setup.
- **Software Installation**: Automated compilation/install of Python (3.8-3.12) and Node.js (16.x/18.x/24.x) with mirror support, compatibility checks for legacy systems (e.g., CentOS 7), and system-wide symlink configuration.
- **Swap Memory Management**: Create/delete swap files, adjust swappiness values, and view swap usage statistics with persistent configuration (fstab integration).


- **Cross-distribution Compatibility**: Automatically detects OS type, package managers (APT/YUM/DNF/Pacman/Zypper), and architecture (x86_64/arm64) for universal support.
- **User-friendly Interface**: Color-coded menus, clear prompts, and error handling for non-technical users.
- **Safety & Reliability**: Automatic backup of system configurations (e.g., repo files) before modification, root privilege warnings, and input validation.
- **Mirror Optimization**: Prioritizes domestic mirrors for faster downloads of Python/Node.js binaries, reducing dependency on international servers.


1. Make the script executable: `chmod +x linux_toolbox.sh`
2. Run interactively: `./linux_toolbox.sh`
3. Follow the on-screen menu to select desired operations (no prior CLI expertise required).

---


Linux Toolbox v1.0.0 is an interactive bash script for Linux system administration, featuring system info monitoring, file management, network tools, package source configuration, Python/Node.js installation, and swap memory management. It supports major Linux distributions, uses domestic mirrors for fast downloads, and provides a user-friendly menu interface with safety backups for system changes.


- 🛠️ All-in-one Linux admin tool with 7+ functional modules
- 🌍 Cross-distribution support (Debian/RHEL/Fedora/Rocky/AlmaLinux)
- 🚀 Domestic mirror optimization for faster package downloads
- 🎨 Intuitive color-coded menu interface (no CLI expertise needed)
- 🔒 Safe operations with automatic config backups
- 📊 Real-time system monitoring & detailed reporting
- 📦 One-click Python/Node.js installation (multiple versions)
