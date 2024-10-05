# Ansible Ubuntu setup

Ansible roles to setup Ubuntu desktop. This playbook is focused on quickly deploying a "ready to use" Ubuntu Desktop.

## Requirements

- Git
- Ansible 2+ (automatically installed from [Ansible offical PPA](https://launchpad.net/~ansible/+archive/ubuntu/ansible) with the provided install.sh
  script)

## Installation

First, you need to install Git and Ansible :

```
$ sudo apt-get install git
$ git clone https://github.com/sys0dm1n/ansible-ubuntu-desktop.git
$ cd ansible-ubuntu-desktop
$ bash ./install.sh
```

Then you need to copy the `group_vars/all.yml` to `group_vars/local.yml` and customize which roles suit your needs. All roles except `locales`,
`common`, and `desktop` are disabled by default.

Run `ansible-playbook ansible-desktop.yml --ask-become-pass` and enter your sudo password to run the playbook

Optionaly you can run just some of the tags like:
`ansible-playbook ansible-desktop.yml --ask-become-pass --tags=virtualbox`

Tags are named the same as role dirs. If a role is in a sub dir then the tag for that specific role is sepparated with a colon like: `aws:cli`. But
you can also use `aws` and that should install all the roles under the `aws` dir.

## Roles included

| Role                | Description                                                                                                                                                                                                                                                           |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                     | **General**                                                                                                                                                                                                                                                           |
| common              | Install a lot of usefull packages (curl, htop, less, zip ... see [corresponding task file](https://github.com/sys0dm1n/ansible-ubuntu-desktop/blob/master/roles/common/tasks/main.yml))                                                                               |
| locales             | Configure system locales and timezone                                                                                                                                                                                                                                 |
| snapd               | Install [snapd](https://snapcraft.io/about)                                                                                                                                                                                                                           |
| ufw                 | Install [ufw](https://help.ubuntu.com/community/UFW)                                                                                                                                                                                                                  |
|                     | **Desktop tools**                                                                                                                                                                                                                                                     |
| bitwarden           | Install [bitwarden](https://snapcraft.io/bitwarden) password manager desktop client.                                                                                                                                                                                  |
| chromium            | Install [Chromium](https://www.chromium.org/).                                                                                                                                                                                                                        |
| desktop             | Install a lot of usefull packages (meld, tilda, vlc, xclip)                                                                                                                                                                                                           |
| discord             | Install [Discord](https://discord.com/download) chat app.                                                                                                                                                                                                             |
| filezilla           | Install [Filezilla](https://filezilla-project.org/) (no particular settings, basic installation)                                                                                                                                                                      |
| firefox             | Install [Firefox](https://www.mozilla.org/firefox/) (no particular settings, basic installation)                                                                                                                                                                      |
| gimp                | Install [Gimp](https://www.gimp.org/) and some minor settings                                                                                                                                                                                                         |
| gnome-encfs-manager | Install [gnome-encfs-manager](https://moritzmolch.com/apps/gencfsm.html) an easy to use manager and mounter for encfs stashes.                                                                                                                                        |
| gparted             | Install [Gparted](https://gparted.org/) a free partition editor for graphically managing your disk partitions.                                                                                                                                                        |
| handbrake           | Install [handbrake](https://handbrake.fr/) a video converting tool from nearly any format to a selection of modern, widely supported codecs.                                                                                                                          |
| libreoffice         | Install [LibreOffice](https://www.libreoffice.org/) using [LibreOffice 5.1 PPA](https://launchpad.net/~libreoffice/+archive/ubuntu/libreoffice-5-1)                                                                                                                   |
| nautilus-plugins    | Install Nautilus plugins                                                                                                                                                                                                                                              |
| remmina             | Install [Remmina](http://www.remmina.org/)                                                                                                                                                                                                                            |
| slack               | Install [Slack](https://slack.com/) set of proprietary team collaboration tools and services.                                                                                                                                                                         |
| sunflower           | Install [SunFlower](http://sunflower-fm.org/download)fom online dev                                                                                                                                                                                                   |
| thunderbird         | Install [Thunderbird](https://www.mozilla.org/thunderbird/) (no particular settings, basic installation)                                                                                                                                                              |
| timeshift           | Install [TimeShift](https://github.com/teejee2008/timeshift)                                                                                                                                                                                                          |
|                     | **Development tools**                                                                                                                                                                                                                                                 |
| assh                | Install [assh](https://github.com/moul/assh) A transparent ssh wrapper that adds yaml configuration and more to SSH                                                                                                                                                   |
| java/openjdk        | Install Default Java JDK                                                                                                                                                                                                                                              |
| java/openjre        | Install Default Java JRE                                                                                                                                                                                                                                              |
| python              | Install python language                                                                                                                                                                                                                                               |
| snapd               | Install [snapd](https://snapcraft.io/snapd) a service that manages installed snaps (app packages for Linux)                                                                                                                                                           |
| ssh                 | Install [OpenSSH Server](http://www.openssh.com/)                                                                                                                                                                                                                     |
| tmux                | Install [tmux](https://github.com/tmux/tmux/wiki) tmux is a terminal multiplexer. It lets you switch easily between several programs in one terminal, detach them (they keep running in the background) and reattach them to a different terminal. And do a lot more. |
| virtualbox          | Install [VirtualBox](https://www.virtualbox.org/) from VirtualBox APT repositories                                                                                                                                                                                    |

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests and examples for any new or changed functionality.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
