# KVM Installation Guide

This document provides detailed instructions for installing and uninstalling KVM on Ubuntu 24.04 using this Ansible script.

### Enabling KVM Installation

By default, kvm is disabled. Thus, to install KVM, you must enable it by overwriting the `kvm_enabled` variable in the `roles/kvm/defaults/main.yaml`.
