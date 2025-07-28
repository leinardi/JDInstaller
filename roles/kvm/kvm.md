# KVM Role – Installation & GPU-Passthrough Guide

This document explains how to install KVM and, optionally, enable GPU passthrough on Ubuntu 24.04 using this Ansible role.

## Prerequisites

1. **Enable hardware virtualisation in firmware (BIOS/UEFI)**
* • Intel: look for “VT-d” and enable it.
* • AMD  : look for “SVM” *and* “IOMMU” and enable both.


2. **GRUB as a bootloader**
* This role supports only **GRUB** for now.

3. **Ubuntu as Host OS**
* This role supports **ubuntu** for now.


---

## Enabling the role

The KVM role is disabled by default. Enable it in either of two ways:

* **Temporarily (via CLI)**
  ```bash
  make install TAGS="kvm" EXTRA_VARS="kvm_enabled=true"
  ```

* **Permanently (via vars file)**
  Edit `group_vars/all.yml` and set
  ```yaml
  kvm_enabled: true
  ```

> Note that GPU passthrough is enabled by default. If you don't have 2 GPUs, then you must run the installation as follows:
> `make install TAGS="kvm" EXTRA_VARS="kvm_enabled=true,kvm_gpu_passthrough='disabled'"`

---

## GPU Passthrough (optional)

If your system has at least two IOMMU-isolated GPUs (typically an integrated GPU plus a dedicated one), the role can add extra GRUB [other bootloader may be supported in the future] menu entries that bind the chosen dedicated GPU to `vfio-pci` at boot.

> Note that GPUs must not belong to the same pci group. If a single group is found, then the installation exits.


* One menu entry is generated per GPU, e.g.

  ```
  Ubuntu
  Ubuntu with NVIDIA GPU Group 5 Passthrough
  Ubuntu with AMD GPU Group 2 Passthrough
  ```

  The default menu entry remains the standard “Ubuntu” which keeps all GPUs on the host.

* Selecting a passthrough entry hands the specified GPU (and its HDMI-audio function, if present) to virtual machines. The host can still boot using the integrated GPU.

> Note that this role doesn't configure your virtual machines. You must pass the GPU PCI manually to it (add hardware button on virt-manager)

### Runtime un-/re-binding

This role sets up passthrough **at boot**. It does not attempt runtime rebinding of GPUs. For hot-plug style switching see Bryan Steiner’s excellent [gpu-passthrough-tutorial](https://github.com/bryansteiner/gpu-passthrough-tutorial).

---

## Uninstalling KVM

To remove the packages installed by this role run:

```bash
sudo apt remove --purge qemu-kvm libvirt-daemon-system libvirt-clients \
                virt-manager ovmf bridge-utils qemu-utils
sudo systemctl disable --now libvirtd
```

---

## Credits

Inspired by Bryan Steiner’s GPU passthrough tutorial.
