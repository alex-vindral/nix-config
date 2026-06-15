{...}: {
  burken.aspects.vfio = {
    nixos = {pkgs, ...}: let
      GPU = "0000:02:00.0";
      AUD = "0000:02:00.1";

      gpuVfio = pkgs.writeShellApplication {
        name = "gpu-vfio";
        runtimeInputs = with pkgs; [kmod pciutils psmisc];
        text = ''
          if [ "$EUID" -ne 0 ]; then
            echo "root required" >&2
            exit 1
          fi

          GPU=${GPU}
          AUD=${AUD}

          current=$(lspci -nnk -s "$GPU" | awk -F': ' '/Kernel driver in use/ {print $2}' || true)
          if [ "$current" = "vfio-pci" ]; then
            echo "already bound to vfio-pci"
            exit 0
          fi

          if fuser /dev/nvidia* "/dev/dri/by-path/pci-$GPU-card" "/dev/dri/by-path/pci-$GPU-render" >/dev/null 2>&1; then
            echo "nvidia devices are in use, cannot swap" >&2
            fuser -v /dev/nvidia* "/dev/dri/by-path/pci-$GPU-"* 2>&1 || true
            exit 1
          fi

          systemctl is-active --quiet nvidia-persistenced && systemctl stop nvidia-persistenced || true

          modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia i2c_nvidia_gpu 2>/dev/null || {
            echo "failed to unload nvidia modules" >&2
            exit 1
          }

          modprobe vfio
          modprobe vfio_iommu_type1
          modprobe vfio_pci

          for dev in "$GPU" "$AUD"; do
            echo vfio-pci > "/sys/bus/pci/devices/$dev/driver_override"
            if [ -e "/sys/bus/pci/devices/$dev/driver" ]; then
              echo "$dev" > "/sys/bus/pci/devices/$dev/driver/unbind"
            fi
            echo "$dev" > /sys/bus/pci/drivers_probe
          done

          echo "GPU bound to vfio-pci"
        '';
      };

      gpuNvidia = pkgs.writeShellApplication {
        name = "gpu-nvidia";
        runtimeInputs = with pkgs; [kmod pciutils];
        text = ''
          if [ "$EUID" -ne 0 ]; then
            echo "root required" >&2
            exit 1
          fi

          GPU=${GPU}
          AUD=${AUD}

          current=$(lspci -nnk -s "$GPU" | awk -F': ' '/Kernel driver in use/ {print $2}' || true)
          if [ "$current" = "nvidia" ]; then
            echo "already bound to nvidia"
            exit 0
          fi

          for dev in "$GPU" "$AUD"; do
            if [ -e "/sys/bus/pci/devices/$dev/driver" ]; then
              echo "$dev" > "/sys/bus/pci/devices/$dev/driver/unbind"
            fi
            echo "" > "/sys/bus/pci/devices/$dev/driver_override"
          done

          # Intentionally keep vfio modules loaded: libvirt validates
          # /dev/vfio/vfio before running the qemu prepare hook, so unloading
          # them here would make the NEXT vmup fail before the swap even runs.

          modprobe nvidia
          modprobe nvidia_modeset
          modprobe nvidia_uvm
          modprobe nvidia_drm

          for dev in "$GPU" "$AUD"; do
            echo "$dev" > /sys/bus/pci/drivers_probe
          done

          echo "GPU bound to nvidia"
        '';
      };
    in {
      # IOMMU required for VFIO.
      boot.kernelParams = [
        "intel_iommu=on"
        "iommu=pt"
      ];

      # vfio modules available, but they don't claim the GPU at boot — nvidia
      # binds it normally. The swap scripts move the GPU between drivers.
      boot.kernelModules = [
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
      ];

      environment.systemPackages = [gpuVfio gpuNvidia];

      # Libvirt qemu hook: swap GPU around the `windows` guest's lifecycle.
      # Fails fast if anything is holding the nvidia devices — VM start aborts.
      environment.etc."libvirt/hooks/qemu" = {
        mode = "0755";
        source = pkgs.writeShellScript "qemu-vfio-hook" ''
          set -e
          GUEST="$1"
          ACTION="$2"
          [ "$GUEST" = "windows" ] || exit 0
          case "$ACTION" in
            prepare) ${gpuVfio}/bin/gpu-vfio ;;
            release) ${gpuNvidia}/bin/gpu-nvidia ;;
          esac
        '';
      };
    };
  };
}
