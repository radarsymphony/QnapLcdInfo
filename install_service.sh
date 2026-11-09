#!/bin/bash

#root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if ! command uv --version > /dev/null 2>&1; then
    echo "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
    uv --version || { echo "uv failed to install or not found in path"; exit 1; }
fi

binary_path="/root/QnapLcdInfo"

mkdir -p "${binary_path}"
cp -r . "${binary_path}"

chmod 775 "${binary_path}"/lcdInfo.py
chmod +x "${binary_path}"/lcdInfo.py

uv sync --directory "${binary_path}"

sed -i "s|WorkingDirectory=.*|WorkingDirectory=${binary_path}|g" ./systemd/lcdinfo.service
sed -i "s|ExecStart=.*|ExecStart=${HOME}/.local/bin/uv run lcdInfo.py|g" ./systemd/lcdinfo.service

cp ./systemd/lcdinfo.service /etc/systemd/system/

systemctl enable lcdinfo.service --now
