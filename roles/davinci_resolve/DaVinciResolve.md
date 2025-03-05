# DaVinci Resolve Installation Guide

This document provides detailed instructions for installing and uninstalling DaVinci Resolve on Ubuntu 24.04 using this Ansible script.

## Enabling DaVinci Resolve Installation

The DaVinci Resolve installation is disabled by default. To enable it:

1. First, follow the instructions to [Download the Repository](../../README.md#download-the-repository).

2. Ensure you are on the DaVinci Resolve branch of the repository:
   ```bash
   git checkout davinci
   ```

3. To install the standard (non-Studio) version, move to the next step. If you want, instead, to install the Studio version, update the configuration by setting
   `davinci_resolve.install_studio` to `true` in `group_vars/all.yml`:
   ```yaml
   davinci_resolve:
     install_studio: true
   ```

4. Run the following command to initiate the installation:
   ```bash
   make install TAGS=davinci_resolve
   ```
   or, if you have already downloaded the Davinci Resolve ZIP archive, you can avoid re-downloading it by pointing the script to the existing file like this:
   
   ```bash
      make install TAGS=davinci_resolve EXTRA_VARS="davinci_resolve_zip_file=/path/to/davinci_resolve_file.zip"
   ```


This process will automate the download and installation of DaVinci Resolve, setting up all necessary libraries, udev rules, desktop icons, and MIME files.

## Uninstalling DaVinci Resolve

To uninstall DaVinci Resolve, please follow these steps:

```bash
# Remove desktop files from /usr/share/applications
sudo rm -f /usr/share/applications/DaVinciResolve.desktop
sudo rm -f /usr/share/applications/DaVinciControlPanelsSetup.desktop
sudo rm -f /usr/share/applications/DaVinciResolveInstaller.desktop
sudo rm -f /usr/share/applications/DaVinciResolveCaptureLogs.desktop
sudo rm -f /usr/share/applications/blackmagicraw-player.desktop
sudo rm -f /usr/share/applications/blackmagicraw-speedtest.desktop

# Remove DaVinciResolve.directory from /usr/share/desktop-directories
sudo rm -f /usr/share/desktop-directories/DaVinciResolve.directory

# Remove DaVinciResolve.menu from /etc/xdg/menus
sudo rm -f /etc/xdg/menus/DaVinciResolve.menu

# Remove icons from /usr/share/icons/hicolor/64x64/apps
sudo rm -f /usr/share/icons/hicolor/64x64/apps/DV_Resolve.png
sudo rm -f /usr/share/icons/hicolor/64x64/apps/DV_ResolveProj.png

# Remove resolve.xml from /usr/share/mime/packages
sudo rm -f /usr/share/mime/packages/resolve.xml

# Remove udev rules from /usr/lib/udev/rules.d
sudo rm -f /usr/lib/udev/rules.d/99-BlackmagicDevices.rules
sudo rm -f /usr/lib/udev/rules.d/99-ResolveKeyboardHID.rules
sudo rm -f /usr/lib/udev/rules.d/99-DavinciPanel.rules

# Remove /opt directory for DaVinci Resolve
sudo rm -rf /opt/davinci-resolve
```

> **Note:** If you installed the Studio version, replace `sudo rm -rf /opt/davinci-resolve` with:
> ```bash
> sudo rm -rf /opt/davinci-resolve-studio
> ```

This will completely remove DaVinci Resolve and all associated files from your system.
