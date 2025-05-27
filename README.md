## Supported environments
- Debian-based linux distributions (marked as kali which I use)
- Msys2 (any kind, in theory)
- Termux (automatically patches pulseaudio config file and hererocks if needed)
- Windows (wip)

### All the scripts are written to be POSIX-compliant

## Dotfiles installation
1. Run `bootstrap.sh` **once**
2. Run `install.sh` (can be re-runed multiple times cause conflict checks ignore symlinks, stow does not throw errors upon restows)

### For Windows
1. Run `win_bootstrap.bat` **once**
2. Run `win_install.bat` (can be re-runed multiple times cause conflict checks ignore symlinks, stow does not throw errors upon restows)

## Dotfiles removing
1. Run `uninstall.sh`
2. Run `deboostrap.sh` which forcefully removes worktrees to leave only an initial master

### For Windows
1. Run `win_uninstall.bat`
2. Run `win_deboostrap.bat` which forcefully removes worktrees to leave only an initial master

Dependencies are not removed.

### TODO
- [ ] Proot setup within Termux. Will include `nh` in local binaries at least (kali-nethunter proot).
- [ ] CHRoot setup within Rooted Termux. Will include chroot utils and scripts for magisk's post-fs-data.d and service.d.

#### Based on [ThePrimeAgen dotfiles](https://github.com/ThePrimeagen/.dotfiles)

