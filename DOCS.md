# declarch 0.2

Declarative configuration for CachyOS / Arch. Describe your system in `.arch` files (TOML syntax); `declarch` makes the machine match. Idempotent, with generations and rollback.

## Install
```bash
./install.sh            # copies to /usr/local/bin, creates /etc/declarch, runs `declarch init`
./install.sh uninstall  # removes the tool, keeps your config
```
Or as a package: `makepkg -si` in this folder (then `sudo declarch init`).
Needs Python 3.11+. Optional: `paru`/`yay` (AUR), `flatpak`, `snapper`.

## Organizing with imports (optional)
By default everything lives in one file: `/etc/declarch/configuration.arch`. When it grows, you can branch out into more `.arch` files and pull them in:
```toml
imports = ["packages.arch", "services.arch", "modules/*.arch"]
```
- Paths are relative to the file that contains the import; globs are allowed; imports nest (cycles are detected).
- Merge rules: lists are concatenated (deduplicated), tables are merged, scalars from the importing file win.
- `source` (files) and `links` paths are relative to the config folder (where `configuration.arch` lives).

A split layout (see `example/split/`):
```
/etc/declarch/
├── configuration.arch # main file: imports + [system], [users]
├── packages.arch      # [packages]
├── services.arch      # [services]
├── modules/gaming.arch
└── dotfiles/zshrc
```
`.arch` is just TOML syntax, so editors highlight it as TOML if you map the extension.

## Commands
| Command | Does |
|---|---|
| `declarch init` | Generate a single `configuration.arch` from the current system |
| `declarch check` | Validate syntax, imports and section names |
| `declarch plan` | Dry run, shows what would change |
| `sudo declarch apply` | Make the system match |
| `sudo declarch upgrade` | `pacman -Syu`, then apply (avoids partial upgrades) |
| `sudo declarch edit` | Open in `$EDITOR`, then check + plan |
| `declarch generations` | List saved generations |
| `sudo declarch rollback [id]` | Re-apply an earlier generation (default: previous) |

`-c PATH` uses another entry file.

## Sections
- **[system]** `hostname`, `timezone`, `locale`, `keymap`
- **[packages]** `pacman`, `aur`, `flatpak`; `prune = true` removes packages you declared before and later deleted from the config (never touches undeclared ones)
- **[services]** `enable`, `disable` (systemd, `--now`)
- **[users.NAME]** `shell`, `groups` (additive)
- **[sysctl]** key/values -> `/etc/sysctl.d/99-declarch.conf`
- **[environment]** key/values -> `/etc/environment.d/90-declarch.conf`
- **[kernel]** `modules` -> `/etc/modules-load.d/declarch.conf`
- **[files."/path"]** `content` or `source`, optional `mode`; files dropped from config are removed
- **[links]** `"/target" = "relative/source"` symlinks (dotfiles). An existing real file is moved to `*.declarch-bak`
- **[hooks]** `pre_apply`, `post_apply` shell commands (only run when something changes)

## How apply works
Load + merge -> build action list -> snapshot via snapper (if present) -> run actions -> save the whole config folder as a generation in `/var/lib/declarch/generations/` -> record managed packages/files/links in `state.json`.

## Limitations
Not NixOS: no atomic builds or version pinning; rollback re-applies config, so use the snapper snapshot for a filesystem-level revert. Run `plan` before enabling `prune`. Untested on a live system as of 0.2.0.

## Ideas for later
Systemd user services, bootloader/kernel params, auto-apply timer, per-host profiles.
