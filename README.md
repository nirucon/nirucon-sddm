# NIRU Noir SDDM 1.5.3

Minimal dark SDDM theme for Debian, Arch, Void and other Linux systems using SDDM.

## Changes in 1.5.3

- Cross-distro hostname handling for Debian, Void, Arch and CachyOS.
- Reads `/etc/hostname` at greeter runtime when available.
- install.sh writes a HostInfo fallback from the current system hostname.
- Avoids false `localhost` when SDDM does not expose the real hostname.

## Changes in 1.5.2

- Username field gets focus on startup.
- Existing default username is selected automatically, so it can be overwritten directly.
- Tab/backtab switches cleanly between username and password.
- Enter in username moves to password.
- Enter in password logs in.
- Failed login clears only the password and keeps focus on password.
- Hostname is read from `/etc/hostname` first, with install-time and SDDM fallbacks.
- No hardcoded hostname or hardcoded runes.
- Cleaner install script with safe QML escaping for default username.

## Install

```bash
unzip nirucon-sddm-1.5.3.zip
cd nirucon-sddm-1.5.3
sudo ./install.sh
```

## Test

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/niru-noir
```

## Restart

```bash
sudo systemctl restart sddm
```

## Uninstall

```bash
sudo ./uninstall.sh
```
