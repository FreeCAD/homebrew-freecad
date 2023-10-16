## github actions readme

This readme is intended explain the validate runner status workflow used with github actions. The three self-hosted runners are macos virtual machines running on a arch linux install using qemu+kvm. The below sections display the code for the systemd unit file for using a virtual machine as a service, and the bash startup script for launching the virtual machine.

**todo**:
- include asciicast for setting up bridge networking for virtual machines
- add commands for modifying github runner service commands to always launch the runner service when the system boots

## systemd unit file for qemu+kvm virtual machine

1. to setup a *nix based distro to work with this unit file.
2. copy the below code contents to `/etc/systemd/system/vmmojave.service`
3. then run the below commands

```
systemctl daemon-reload
```

<details>
<summary>systemd unit file for for controlling a qemu+kvm virtual machine</summary>

```
[Unit]
Description=macos mojave qemu virtual machine
After=network-online.target docker.service
Requires=network-online.target

[Service]
EnvironmentFile=/etc/environment_vars
Environment="haltcmd=kill -INT $MAINPID"
Type=forking
User=capin
ExecStart=/bin/bash -c '/home/capin/vmz/basic.mydisk.mojave.bridge.sh || true' &
ExecStop=/usr/bin/bash -c ${haltcmd}
ExecStop=/usr/bin/bash -c 'while nc localhost 7400; do sleep 1; done'

[Install]
WantedBy=multi-user.target
```

</details>


## controlling the systemd servies via a restricted user

i have created a specific user on my host machine archbox that has limited permissions using sudo to status, stop, start, and restart the systemd services controlling the virtual machines. this particular user belongs to a specific group that allows controlling these services using sudo without having to input a password,

```
# this file requires the below criteria
# 1. the host system requires a user group with the name farmers
# 2. a systemd service with the name vmmojave
# 3. a user added to the user group farmers
# 4. the /etc/sudoers file requires the below line
# `@includedir /etc/sudoers.d`

%farmers ALL= NOPASSWD: /bin/ls

%farmers ALL= NOPASSWD: /bin/systemctl start vmmojave
%farmers ALL= NOPASSWD: /bin/systemctl stop vmmojave
%farmers ALL= NOPASSWD: /bin/systemctl restart vmmojave
%farmers ALL= NOPASSWD: /bin/systemctl status vmmojave

%farmers ALL= NOPASSWD: /bin/systemctl start vmcatalina
%farmers ALL= NOPASSWD: /bin/systemctl stop vmcatalina
%farmers ALL= NOPASSWD: /bin/systemctl restart vmcatalina
%farmers ALL= NOPASSWD: /bin/systemctl status vmcatalina

%farmers ALL= NOPASSWD: /bin/systemctl start vmbigsur
%farmers ALL= NOPASSWD: /bin/systemctl stop vmbigsur
%farmers ALL= NOPASSWD: /bin/systemctl restart vmbigsur
%farmers ALL= NOPASSWD: /bin/systemctl status vmbigsur
```

## virtual machine startup file

<details>
<summary>startup file for virtual machine</summary>

```bash
#!/bin/bash

source "/etc/environment_vars"
vmdir="/home/capin/vmz"
ovmf_dir="$vmdir"

#------------
# non supported CPU flags on 4th gen i7 haswell, +xsavec +xgetbv1
# NOTES: ipatch
# - to enable nested paging inside VM, (hardware accel for vm inside vm) add `+vmx` to  cpu flags
# 	- `+vmx` is only compat with intel cpu's, AMD uses +svm
# networking / BRIDGE
#	-netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
#	-device vmxnet3,netdev=net0,mac=52:54:00:c9:18:27

# networking / USER
# -netdev user,id=net0 \
# -device [usb-mouse] or [usb-tablet]
#
# NOTE: ipatch, mouting EFI partition within the host OS, no need for VM to edit clover/config.plist
# install `libguestfs` for *nix distro, see: github.com/foxlet/macos-simple-kvm/pull/133
#-

osx_kvm_repo="/home/capin/code/osx-kvm"

# foxlet, github.com/foxlet/macos-simple-kvm
#-drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
#-drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \

# shellcheck disable=SC2054
args=(
-enable-kvm \
-m 4G \
-machine q35,accel=kvm \
# NOTE: ipatch, use all available cores from host OS
-smp $(nproc) \
-cpu \
host,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
-device isa-applesmc,osk="$OSK" \
-smbios type=2 \
-drive if=pflash,format=raw,readonly=on,file="$ovmf_dir/OVMF_CODE-mojave.fd" \
-drive if=pflash,format=raw,file="$ovmf_dir/OVMF_VARS-1024x768.mojave.fd" \
-vga qxl \
\
# network
-netdev tap,id=net0,ifname=tap14,script=no,downscript=no \
-device vmxnet3,netdev=net0,mac=52:55:00:c9:00:14
\
# audio
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa
-device ich9-intel-hda -device hda-output \
# keyboard & mouse, generic USB
-usb -device usb-kbd -device usb-tablet \
\
#------------
# NOTE: ipatch, uncomment to boot from coreboot ISO
# will also need to insert macos install media to resize vdisk
#----
# -device ich9-ahci,id=sata \
# -drive id=OpenCoreBoot,if=none,snapshot=on,format=raw,file="./OpenCore-v13.iso" \
# -device ide-hd,bus=sata.2,drive=OpenCoreBoot,bootindex=1 \
\
# macos install media, required to resize vdisk, ie. catalina
#----
# -drive id=macosinstall,if=none,snapshot=on,format=raw,file="./BaseSystemCatalina.img" \
# -device ide-hd,bus=sata.3,drive=macosinstall,bootindex=4 \
#------
\
-device nvme,id=nvme-ctrl-1,serial=deadbeed2 \
-drive file="/home/capin/vmz/mymojavedisk256G.qcow2",format=qcow2,if=none,id=mydisk3 \
-device nvme-ns,drive=mydisk3,bootindex=3 \
\
-nographic \
# -display gtk,zoom-to-fit=on
-serial none \
# NOTE: ipatch, add `-nodefaults` prevents pseudo DVD-ROM drive from appearing in macos
-nodefaults \
# NOTE: ipatch, to exit the telnet session, type `Ctrl + ]`
-serial telnet:localhost:7000,server,nowait,nodelay \
-monitor telnet:localhost:7400,server,nowait,nodelay \
# -monitor stdio \
-name vmmojave \
)

# DEBUG comment/uncomment the below line
# echo qemu-system-x86_64 "${args[@]}"

# qemu-system-x86_64 "${args[@]}"

# Run qemu-system-x86_64 in the background, ie. systemd service file
qemu-system-x86_64 "${args[@]}" &
```

</details>


## runner service setup on virtual machine

the below steps / commands detail the process for launching the runner process on boot

1. first install the runner service on the system for the currently logged in user `./svc.sh install`

  a. example output from above command,

  ```
  Creating launch runner in /Users/brewer/Library/LaunchAgents/actions.runner.FreeCAD-homebrew-freecad.vmcatalina.plist
  Creating /Users/brewer/Library/Logs/actions.runner.FreeCAD-homebrew-freecad.vmcatalina
  Creating /Users/brewer/Library/LaunchAgents/actions.runner.FreeCAD-homebrew-freecad.vmcatalina.plist
  Creating runsvc.sh
  Creating .service
  svc install complete
  ```

3. copy the startup file for the service to the below directory
  ```
  /Library/LaunchDaemons/
  ```

  the command i used for vmmojave

  ```
  sudo mv /Users/brewer/Library/LaunchAgents/actions.runner.FreeCAD-homebrew-freecad.vmmojave.plist /Library/LaunchDaemons/actions.runner.FreeCAD-homebrew-freecad.vmmojave.plist
  ```

4. set the permissions for the service file, then start the service

  ```
  sudo chown root:wheel /Library/LaunchDaemons/actions.runner.FreeCAD-homebrew-freecad.vmmojave.plist
  sudo launchctl load /Library/LaunchDaemons/actions.runner.FreeCAD-homebrew-freecad.vmmojave.plist
  ```

5. verify the service is running after loading using launchctl

```
sudo launchctl list | grep -i actions
```

> the above command must be run with superuser

now every time the virtual machine starts up the self-hosted runner service should start
