# Linux installation on the 500 GB Samsung SSD

This guide targets the **Samsung SSD 860 EVO 500GB**, shown as approximately
**465.8 GiB** and formerly used as Windows `G:`. It was Disk 1 during
preparation, but disk numbers can change. Confirm the model and capacity in the
installer before erasing anything.

Do not modify the 1 TB Samsung drive, the Kingston drive, or any Windows/data
drive. Disconnecting non-target drives during installation is the safest
option when practical.

## Before booting the installer

1. Back up anything still needed from the 500 GB SSD.
2. In Windows, disable Fast Startup in Control Panel under Power Options,
   "Choose what the power buttons do." It was enabled during preparation.
3. Leave firmware in UEFI mode. Use GPT, not legacy BIOS/MBR.
4. Boot the 64 GB SanDisk Cruzer Blade Ventoy USB with `F12` on the Gigabyte
   B650M GAMING PLUS WIFI board.
5. Select one of the hash-verified images: Pop!_OS 24.04 NVIDIA build 26,
   Fedora KDE 44, or EndeavourOS Titan Neo 2026.04.27.
6. Start the live environment first. Check display output, Wi-Fi, audio,
   keyboard, mouse, and access to the RTX 4070 Ti SUPER before installing.

## Storage rules

- Select only the Samsung SSD 860 EVO 500GB (465.8 GiB).
- Use the installer's standard encrypted automatic layout and default
  filesystem. Do not force one manual layout across all three distributions.
- The result must use UEFI/GPT, with its EFI system partition and bootloader on
  this same 500 GB SSD.
- Enable full-disk encryption and record the recovery passphrase securely.
- Do not create a separate `/home` partition unless the installer requires it.

## Pop!_OS 24.04

1. Choose `Clean Install`, then select the 500 GB Samsung by model and size.
2. Choose `Encrypt Drive` and set the disk-encryption passphrase.
3. Confirm that the clean install and bootloader both target that SSD. Pop!_OS
   creates its required EFI, recovery, encrypted system, and swap layout.
4. Stop if the confirmation screen names another drive.

## Fedora KDE 44

1. Under `Installation Destination`, select only the 500 GB Samsung.
2. Choose automatic storage configuration and enable `Encrypt my data`.
3. Keep Fedora's default filesystem and automatic partitioning. Confirm the
   boot device is the same Samsung SSD and reclaim space only on that disk.
4. Stop if another drive is selected or listed for destructive changes.

## EndeavourOS

1. In the Calamares partitioning page, choose `Erase disk` and select the 500
   GB Samsung by model and size.
2. Select GPT/UEFI, enable `Encrypt system`, and keep the offered filesystem
   default.
3. Put the bootloader on the same Samsung SSD. Do not choose a separate home
   partition.
4. Review the final partition summary and stop if any other disk appears under
   create, format, delete, or bootloader actions.

## First boot

1. Remove the USB and boot the installed system from the firmware menu.
2. Confirm the encryption prompt appears and the system reaches the desktop.
3. Reboot once more and verify the 500 GB SSD remains independently bootable.
4. Install system updates and the recommended NVIDIA driver where the chosen
   distribution does not already provide it.
5. Only after those checks, reconnect or mount other drives. Mount Windows
   volumes read-only first if Fast Startup was not successfully disabled.

Clone this repository and run the starter pack:

```sh
git clone https://github.com/alvinwin/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --dry-run
./bootstrap.sh
```

The dry run prints package, link, font, and OpenCode actions. The real run is
safe to repeat and preserves conflicting configuration instead of overwriting
it.

## Verification

Restart the shell and OpenCode, then run:

```sh
git --version
tmux -V
nvim --version | sed -n '1p'
opencode --version
kitty --version
fc-match 'MesloLGS Nerd Font Mono'
command -v wl-copy rg fzf
readlink -f ~/.tmux.conf
readlink -f ~/.config/{tmux,tmux-palette,nvim,opencode,kitty}
git config --get init.defaultBranch
printf '%s\n' "$EDITOR"
```

Launch `kitty`, start `tmux`, and open `nvim`. OpenCode configuration changes
are loaded only on a fresh OpenCode process.
