#
# Windows VM with NVIDIA GPU passthrough.
#
# Day-to-day:
#   vmup        start the VM (libvirt qemu hook swaps GPU to vfio-pci)
#   vmdown      graceful shutdown (hook swaps GPU back to nvidia)
#   vmkill      force off if Windows hangs
#   vmls        list VMs and their state
#   <remmina>   connect to the VM's IP on port 3389
#
# One-time install (do this once, then never again):
#   1. Get a Windows 11 ISO.
#   2. nix-shell -p virt-manager --run virt-manager
#      If it says "Could not detect a default hypervisor": File -> Add Connection,
#      Hypervisor = QEMU/KVM, leave "Connect to remote host" unchecked, Connect.
#   3. New VM, NAME IT EXACTLY `windows` (the hook keys on this name).
#      - Local install media -> Win11 ISO, OS = Windows 11
#      - ~16 GB RAM, 8 vCPUs, 200 GB virtio qcow2 disk
#      - Tick "Customize configuration before install"
#   4. In Customize:
#      - Firmware: UEFI (OVMF, secboot variant)
#      - Chipset:  Q35
#      - Add Hardware -> TPM: emulated, tpm-crb, version 2.0
#        Then REMOVE the pre-existing "TPM vNone" entry from the sidebar
#        (libvirt only allows one TPM device).
#      - Add Hardware -> Storage:
#          * Select "Select or create custom storage"
#          * Device type: CDROM device
#          * Path: /var/lib/libvirt/images/virtio-win.iso (built declaratively
#            below; type it in even if your user can't ls the dir -- libvirt
#            reads it as root)
#      - "SATA Disk 1" in the sidebar -> change Disk bus from SATA to VirtIO
#        (entry will re-label to "VirtIO Disk 1")
#      - "NIC :xx:xx:xx" in the sidebar -> Device model -> virtio
#      - "Display Spice" should already be there; leave it
#      - DO NOT add the GPU yet
#   5. Begin Install. Boot will land in the OVMF firmware screen:
#      a. When you see "Press any key to boot from CD or DVD" -- mash a key
#         fast (it times out in ~5s). If you miss it, you'll see "No bootable
#         option found"; press a key to enter Boot Manager, pick the first
#         "UEFI QEMU DVD-ROM" entry (usually the Windows ISO; if it boots the
#         virtio driver browser instead, reset and pick the other one).
#      b. In the Windows installer:
#         - Language/keyboard -> Next
#         - "I don't have a product key" to skip
#         - Edition: Windows 11 Pro (Home forces an MS account)
#         - Accept license -> Custom: Install Windows only
#         - Disk selection screen: the virtio disk won't appear yet.
#           Click "Load driver" -> Browse -> the virtio-win CDROM ->
#           viostor\w11\amd64 -> OK. The disk appears.
#           Repeat for the NIC: Load driver -> NetKVM\w11\amd64.
#         - Pick the now-visible disk -> Next. Files copy, VM reboots a few times.
#      c. Out-of-box experience: at the "Let's connect you to a network"
#         screen, force a LOCAL account (much easier than dealing with MS
#         account later). Press Shift+F10 to open a command prompt
#         (use virt-manager's Send Key menu if the host grabs F10), then:
#           start ms-cxh:localonly      (Win11 24H2+; opens a local-account dialog)
#         If that command isn't recognised, fall back to:
#           oobe\BypassNRO              (older Win11)
#           taskkill /F /IM oobenetworkconnectionflow.exe   (kills the screen)
#         Then finish OOBE with the local user.
#   6. Finish Windows setup. Inside Windows:
#      - Run virtio-win-gt-x64.msi from the second CDROM (full virtio drivers)
#      - Enable Remote Desktop (Settings -> System -> Remote Desktop)
#      - Note the name, example: DESKTOP-RTKSSUB
#      - Get the ip address using ipconfig, example: 192.168.122.204
#   7. Shut down cleanly.
#   8. Back in virt-manager:
#      - Remove both ISOs (Windows + virtio-win) from the VM
#      - Keep the Spice display + QXL video: nice break-glass console for
#        boot/install/network-down situations. Day-to-day you use RDP.
#      - Add Hardware -> PCI Host Device: 0000:02:00:0 (GPU) and 0000:02:00:1 (audio)
#      - Save.
#   9. `vmup`, then RDP in from remmina. Inside Windows install the NVIDIA
#      driver from nvidia.com; reboot the VM. After that the dGPU is the
#      primary display adapter and the Spice console becomes a secondary.
#
#  10. If `vmup` ever fails with "network 'default' is not active", libvirt's
#      NAT network didn't autostart this boot. The aspect declares the
#      autostart symlink via systemd.tmpfiles, but if it's missing (e.g.
#      first boot before libvirtd has materialised the default network XML),
#      do it once manually:
#          sudo virsh net-start default
#          sudo virsh net-autostart default
#
{...}: {
  bungo.aspects.vm = {
    nixos = {pkgs, ...}: let
      # nixpkgs virtio-win ships only the extracted contents; build an ISO
      # from them so libvirt has something to attach as a CDROM.
      virtioWinIso = pkgs.runCommand "virtio-win.iso" {
        nativeBuildInputs = [pkgs.cdrkit];
      } ''
        mkisofs -V virtio-win -J -r -o $out ${pkgs.virtio-win}
      '';
    in {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };

      users.users.bungo.extraGroups = ["libvirtd" "kvm"];

      environment.systemPackages = with pkgs; [
        virt-viewer
      ];

      # Share a host directory into the Windows guest over the libvirt NAT
      # network via SMB. In Windows, map a network drive to
      #   \\192.168.122.1\composer
      # (the host's address on the virbr0 bridge). One-time setup: the SMB
      # password is a secret and can't be declared, so run once on the host:
      #   sudo smbpasswd -a bungo
      services.samba = {
        enable = true;
        # Firewall is scoped to virbr0 below, so don't let the module punch
        # holes on every interface.
        openFirewall = false;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "nixos-host";
            "server role" = "standalone server";
            # Only ever answer on the VM bridge; reject everything else.
            "bind interfaces only" = "yes";
            "interfaces" = "virbr0 lo";
            "hosts allow" = "192.168.122.0/24 127.0.0.1";
            "hosts deny" = "0.0.0.0/0";
          };
          composer = {
            path = "/home/bungo/Documents/vindral-composer";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "bungo";
            "force user" = "bungo";
          };
        };
      };
      # Required for Windows to browse/resolve the share by name (optional but
      # avoids relying solely on the raw IP).
      services.samba-wsdd = {
        enable = true;
        openFirewall = false;
      };
      # Open SMB only on the libvirt bridge, never on the LAN/WAN.
      networking.firewall.interfaces.virbr0.allowedTCPPorts = [445 139 5357];
      networking.firewall.interfaces.virbr0.allowedUDPPorts = [137 138 3702];

      systemd.tmpfiles.rules = [
        # Symlink the built ISO into libvirt's default image pool location.
        "L+ /var/lib/libvirt/images/virtio-win.iso - - - - ${virtioWinIso}"
        # Autostart libvirt's default NAT network. Equivalent to running
        # `virsh net-autostart default` once. The target XML is created by
        # libvirtd on first start; if it doesn't exist yet the symlink is
        # harmless until then.
        "L+ /var/lib/libvirt/qemu/networks/autostart/default.xml - - - - ../default.xml"
      ];
    };

    homeManager = {
      home.shellAliases = {
        vm = "virsh -c qemu:///system";
        vmup = "virsh -c qemu:///system start windows";
        vmdown = "virsh -c qemu:///system shutdown windows";
        vmkill = "virsh -c qemu:///system destroy windows";
        vmls = "virsh -c qemu:///system list --all";
        vmview = "virt-viewer -c qemu:///system windows";
      };
    };
  };
}
