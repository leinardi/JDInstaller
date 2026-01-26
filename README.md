[![Ubuntu test](https://github.com/leinardi/JDInstaller/actions/workflows/ubuntu-test.yaml/badge.svg?branch=release)](https://github.com/leinardi/JDInstaller/actions/workflows/ubuntu-test.yaml) [![CI release](https://github.com/leinardi/JDInstaller/actions/workflows/ci.yaml/badge.svg?branch=release)](https://github.com/leinardi/JDInstaller/actions/workflows/ci.yaml)

# JDInstaller

This Ansible playbook is designed to initialize a fresh Ubuntu installation with packages and configurations that suit my personal preferences. While it is
specifically tailored to my needs, it can be easily adapted to different setups. Every major Ansible role can be individually enabled or disabled by modifying
its respective value in `inventory/group_vars/all.yaml`.

## Table of Contents

- [Introduction](#introduction)
- [How to Use](#how-to-use)
    - [Download the Repository](#download-the-repository)
    - [Run the Installation](#run-the-installation)
    - [Run Single Roles](#run-single-roles)
- [Playbooks](#playbooks)
- [Roles](#roles)
- [DaVinci Resolve](#davinci-resolve)
- [Contributions](#contributions)
- [Acknowledgements](#acknowledgements)

## Introduction

This project uses [Ansible](https://www.ansible.com/) to automate the setup of Ubuntu installations. By running the main playbook (`playbooks/ubuntu-setup.yaml`), the
system will be configured with a range of packages and settings that I prefer. You can easily customize the playbook by enabling or disabling specific roles in
`inventory/group_vars/all.yaml`.

### What is a Role?

An Ansible role is a modular way of organizing playbooks. Roles allow you to break up a complex playbook into reusable components. Each role can include tasks,
variables, handlers, and more, and they are self-contained to allow easy inclusion into other playbooks. Roles in this project mainly deal with the installation
of various software packages.

## How to Use

### Download the Repository

You can either download the ZIP file of this repository or clone the repository using git.

#### Option 1: Download ZIP

1. Go to this link: [Download ZIP](https://github.com/leinardi/JDInstaller/archive/refs/heads/master.zip)
2. Extract the ZIP file:

   ```bash
   unzip JDInstaller-master.zip
   cd JDInstaller-master
   ```
3. Install `make` if it is not already installed:

   ```bash
   sudo apt install make
   ```

#### Option 2: Clone via Git

1. Install `git` and `make` if they are not already installed:

   ```bash
   sudo apt install git make
   ```

2. Clone the repository:

   ```bash
   git clone https://github.com/leinardi/JDInstaller.git
   cd JDInstaller
   ```

### Run the Installation

Once you have the repository on your machine, you can start the installation process by running:

```bash
make install
```

This command will:

1. Automatically install Ansible if it’s not already installed.
2. Launch the main playbook (`playbooks/ubuntu-setup.yaml`) to configure the system.
3. Prompt for the sudo password of the current user.

Alternatively, you can run the playbook manually:

```bash
ansible-playbook playbooks/ubuntu-setup.yaml --ask-become-pass
```

### Run Single Roles

Each role has an associated tag (same as the role name). To install a specific role, use the `TAGS` parameter like this:

```bash
make install TAGS=virtualbox
```

Or manually run the playbook with specific tags:

```bash
ansible-playbook playbooks/ubuntu-setup.yaml --ask-become-pass --tags=virtualbox
```

### Reset Configuration

To generate/reset the `inventory/group_vars/all.yaml` file to the default values, run:

```bash
./generate-group-vars.sh
```

## Playbooks

Below is a list of the playbooks that are included in this project. You can enable or disable each one by modifying the respective variable in
`inventory/group_vars/all.yaml`.

| Playbook          | Enabled by Default | Description                               |
|-------------------|--------------------|-------------------------------------------|
| `common.yaml`      | ✅                  | Sets up common packages and settings.     |
| `desktop.yaml`     | ✅                  | Installs desktop-specific applications.   |
| `development.yaml` | ✅                  | Installs development tools and libraries. |
| `gaming.yaml`      | ✅                  | Installs gaming-related tools.            |
| `work.yaml`        | ⛔                  | Installs work-related applications.       |

## Roles

The tables below provide an overview of the roles included in this project. Each role can be enabled or disabled via `inventory/group_vars/all.yaml`. The "Enabled by
Default" column shows whether the role is active by default. Even if a role is enabled by default, if the relative playbook is disabled via
`inventory/group_vars/all.yaml`, the role will not be executed. To run a specific playbook or role, make sure both the playbook and the role are enabled in
`inventory/group_vars/all.yaml`.

### Playbook: `common.yaml`

| Role     | Enabled by Default | Source | Description                                                    |
|----------|--------------------|--------|----------------------------------------------------------------|
| `common` | ✅                  | apt    | Installs a set of common packages listed in `common.packages`. |
| `snapd`  | ⛔                  | apt    | Installs snapd for managing Snap packages.                     |
| `ufw`    | ⛔                  | apt    | Installs and configures Uncomplicated Firewall (UFW).          |

### Playbook: `desktop.yaml`

| Role               | Enabled by Default | Source                | Description                                                                                    |
|--------------------|--------------------|-----------------------|------------------------------------------------------------------------------------------------|
| `desktop`          | ✅                  | apt                   | Installs a set of desktop-related packages listed in `desktop.packages`.                       |
| `chrome`           | ✅                  | apt (Google repo)     | Installs Google Chrome.                                                                        |
| `chromium`         | ✅                  | apt                   | Installs the open-source Chromium browser.                                                     |
| `davinci_resolve`  | ⛔                  | archive               | Installs DaVinci Resolve. Change `davinci_resolve.install_studio` to install the Studio build. |
| `doublecmd`        | ✅                  | apt                   | Installs Double Commander, a file manager.                                                     |
| `earth`            | ✅                  | apt                   | Installs Google Earth Pro.                                                                     |
| `edge`             | ⛔                  | apt (Google repo)     | Installs Microsoft Edge browser.                                                               |
| `firefox`          | ✅                  | apt (Mozilla repo)    | Installs Mozilla Firefox.                                                                      |
| `flatpak`          | ✅                  | apt                   | Installs Flatpak for managing app installations.                                               |
| `gimp`             | ✅                  | apt                   | Installs GIMP, a graphic editor.                                                               |
| `gnome_extensions` | ✅                  | apt                   | Installs GNOME extensions. See `gnome_extensions.packages` for the list of extensions.         |
| `gparted`          | ✅                  | apt                   | Installs GParted, a partition editor.                                                          |
| `graphics_drivers` | ✅                  | PPA                   | Installs proprietary drivers for graphics cards.                                               |
| `gsettings`        | ✅                  | -                     | Configures GNOME settings via gsettings.                                                       |
| `handbrake`        | ⛔                  | apt                   | Installs HandBrake, a video transcoder.                                                        |
| `inkscape`         | ✅                  | apt                   | Installs Inkscape, a vector graphics editor.                                                   |
| `insync`           | ✅                  | apt (InSync repo)     | Installs Insync, a Google Drive sync client.                                                   |
| `libreoffice`      | ✅                  | apt                   | Installs LibreOffice, a free office suite.                                                     |
| `mainline`         | ✅                  | PPA                   | Installs Mainline, a tool for managing Linux kernels.                                          |
| `meld`             | ✅                  | apt                   | Installs Meld, a file comparison tool.                                                         |
| `nautilus_plugins` | ⛔                  | apt                   | Installs plugins for the Nautilus file manager.                                                |
| `nordvpn`          | ✅                  | apt (NordVPN repo)    | Installs NordVPN client.                                                                       |
| `openjre`          | ⛔                  | apt                   | Installs OpenJRE, a Java runtime environment.                                                  |
| `sweethome3d`      | ✅                  | flathub               | Installs Sweet Home 3D, an interior design app.                                                |
| `timeshift`        | ⛔                  | apt                   | Installs Timeshift for system backups.                                                         |
| `ulauncher`        | ✅                  | PPA                   | Installs Ulauncher, an application launcher.                                                   |
| `virtualbox`       | ✅                  | apt (VirtualBox repo) | Installs VirtualBox for running virtual machines.                                              |
| `vlc`              | ✅                  | apt                   | Installs VLC media player.                                                                     |
| `xfburn`           | ✅                  | apt                   | Installs Xfburn, a tool for burning CDs and DVDs.                                              |

### Playbook: `development.yaml`

| Role          | Enabled by Default | Source | Description                                                           |
|---------------|--------------------|--------|-----------------------------------------------------------------------|
| `development` | ✅                  | apt    | Installs a set of development tools listed in `development.packages`. |
| `filezilla`   | ✅                  | apt    | Installs FileZilla, an FTP client.                                    |
| `git`         | ✅                  | apt    | Installs Git, a version control system.                               |
| `openjdk`     | ✅                  | apt    | Installs OpenJDK, a Java development environment.                     |
| `python`      | ✅                  | apt    | Installs Python.                                                      |
| `slack`       | ⛔                  | snap   | Installs Slack for team communication.                                |

### Playbook: `gaming.yaml`

| Role       | Enabled by Default | Source | Description                                      |
|------------|--------------------|--------|--------------------------------------------------|
| `discord`  | ✅                  | deb    | Installs Discord for chatting and VoIP.          |
| `gamemode` | ✅                  | apt    | Installs GameMode, a tool for optimizing gaming. |
| `mangohud` | ✅                  | github | Installs MangoHud, a gaming performance overlay. |
| `steam`    | ✅                  | deb    | Installs Steam, a gaming platform.               |

### Playbook: `work.yaml`

| Role                        | Enabled by Default | Source                | Description                                   |
|-----------------------------|--------------------|-----------------------|-----------------------------------------------|
| `globalprotect_openconnect` | ✅                  | deb                   | Installs OpenConnect for GlobalProtect VPN.   |
| `mattermost`                | ✅                  | apt (mattermost repo) | Installs Mattermost, a team chat application. |
| `zoom`                      | ✅                  | deb                   | Installs Zoom, a video conferencing tool.     |

Each playbook can be customized, and roles enabled or disabled as required via `inventory/group_vars/all.yaml`. By default, the playbook `work.yaml` is disabled,
but can be easily enabled if needed by changing the `work_enabled` in `inventory/group_vars/all.yaml`.

## DaVinci Resolve

The DaVinci Resolve section of this script automates the entire installation process on Ubuntu 24.04, making it straightforward to get the software up and
running without requiring older system dependencies or containers.

This part of the script:

- Downloads the official DaVinci Resolve archive and installs it in `/opt/`
- Sets up necessary symlinks to avoid downgrading dependencies
- Installs udev rules for USB peripherals like DaVinci Panels
- Auto-detects and installs the correct OpenCL libraries for AMD, Intel, or Nvidia GPUs
- Sets up system icons, MIME files, and desktop entries

By default, **the installation of DaVinci Resolve is disabled**. Please refer to [DaVinciResolve.md](roles/davinci_resolve/DaVinciResolve.md) for detailed
instructions on enabling the installation, as well as uninstallation steps.

## Contributions

Bug fixes and improvements to the Ansible code are welcome. However, please note that the list of default software installations is strictly based on my
personal preferences. I will accept pull requests adding roles for software that I don't use, but they must be disabled by default via `inventory/group_vars/all.yaml`.

**Before opening a pull request, please create an issue to describe the feature you would like to add and wait for my approval.** This helps avoid unnecessary
work.

This project uses the [pre-commit framework](https://pre-commit.com/) to ensure consistent formatting and basic static analysis across commits.

To enable it:

1. Install `pre-commit` system-wide (e.g., via APT):

    ```bash
    sudo apt install pre-commit
    ````

2. Set it up for this repository:

   ```bash
   make install-pre-commit
   ```

After that, checks will automatically run before each commit. You can also run the checks manually with:

```bash
make check
```

This command performs static analysis on shell and YAML files and regenerates the `inventory/group_vars/all.yaml` file.

## Acknowledgements

This project is inspired by [ansible-ubuntu-desktop](https://github.com/sys0dm1n/ansible-ubuntu-desktop). Many thanks
to [@sys0dm1n](https://github.com/sys0dm1n) for sharing their playbook.
