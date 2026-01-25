#!/bin/bash

# Enable bash strict mode
set -euo pipefail

# Function to check if the script is run as root or with sudo
check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or using sudo."
    exit 1
  fi
}

# Function to add the Ansible PPA if it's not already added
add_ansible_ppa() {
  if ! grep -q "ansible/ansible" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "Adding Ansible PPA..."

    # Install software-properties-common if it's not installed
    if ! dpkg -s software-properties-common >/dev/null 2>&1; then
      sudo apt-get update -y
      sudo apt-get install -y software-properties-common
    fi

    # Add the Ansible PPA
    if ! sudo apt-add-repository ppa:ansible/ansible -y; then
      echo "Error: Failed to add Ansible PPA. Please check your connection or repository settings." >&2
      exit 1
    fi
  else
    echo "Ansible PPA already added."
  fi
}

# Function to install Ansible and dependencies
install_ansible() {
  echo "Installing Ansible and dependencies..."

  # Update package list and install Ansible
  sudo apt-get update -y
  if ! sudo apt-get install -y ansible git python3-apt; then
    echo "Error: Failed to install Ansible. Please check the logs." >&2
    exit 1
  fi
}

# Function to check if Ansible is installed
check_ansible_installed() {
  if ! command -v ansible >/dev/null 2>&1; then
    add_ansible_ppa
    install_ansible
  else
    echo "Ansible is already installed."
  fi
}

# Function to install Ansible requirements
install_ansible_requirements() {
  echo "Installing Ansible collections..."
  if ! ansible-galaxy collection install -r requirements.yml; then
    echo "Error: Failed to install Ansible requirements." >&2
    exit 1
  fi
}

# Function to print further instructions
print_instructions() {
  echo ""
  echo "=================================================="
  echo " Ansible installation and setup completed!"
  echo "=================================================="
  echo ""
  echo "Next steps:"
  echo ""
  echo "1. Customize the playbook to fit your needs:"
  echo "   -> Edit the file: **group_vars/all.yaml**"
  echo ""
  echo ""
  echo "2. Run Ansible with the following command:"
  echo "   $ ansible-playbook playbooks/ubuntu-setup.yaml --ask-become-pass"
  echo ""
  echo "   The '--ask-become-pass' flag will prompt you for the sudo password."
  echo ""
  echo "=================================================="
  echo ""
}

# Main execution
main() {
  check_root
  check_ansible_installed
  install_ansible_requirements
  print_instructions
}

# Run the main function
main
