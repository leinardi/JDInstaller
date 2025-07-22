# KVM Installation Guide

This document provides detailed instructions for installing and uninstalling KVM on Ubuntu 24.04 using this Ansible script.


### Pre-requisites

You must manually enable the virtualization capability for your CPU in the BIOS.

1. Reboot your computer
2. press `f12` or `f11` or `delete` to enter the BIOS/UEFI depending on your motherboard vendor
3. Search for an option called `VT-d (Intel)` or `AMD IOMMU` (AMD) in the settings

> Some AMD motherboards call the CPU virtualization setting: "SVM Mode"

### Enabling KVM Installation

By default, kvm is disabled. Thus, to install KVM, you must enable it by overwriting the `kvm_enabled` variable in the `roles/kvm/defaults/main.yaml`.


### GPU Passthrough

This role also enables GPU passthrough if your computer is capable of it. When you start your computer, the bootloader menu shows you an extra option that dedicates the device's GPU to Virtual Machines. By default the bootloader will **NOT** choose this option after the few seconds.

> Note that dedicating a GPU for a virtual machine will disable the GPU on your computer

Keep in mind that, most computers would have 2 GPUs: integrated GPU (iGPU) and dedicated GPU (dGPU). The integrated GPU mostly is attached to the CPU and can do minimum screen-rendering tasks. In other words, it is not your gaming or AI GPU. The dedicated GPU on the other hand, is used for heavy tasks. This playbook will only consider the dedicated GPUs for virtualization.


> Note taht, for each dedicated GPU, a new entry in your bootscreen will be added. Only 1 entry per GPU. You are going to see in your boot screen something as: ubuntu, ubuntu with virtualized <dGPU1_name>, ubuntu with virtualized <dGPU2_name>... etc


### Credits

Special thanks to bryansteiner for providing a clear [gpu-passthrough-tutorial](https://github.com/bryansteiner/gpu-passthrough-tutorial) guide for KVM.

> Note that this playbook does not support realtime GPU drivers unbinding (unlike bryan's tutorial). I faced some issues while trying to unbind/bind my Nvidia GPU at runtime
