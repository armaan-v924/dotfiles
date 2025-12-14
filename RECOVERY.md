# RECOVERY.md — Fresh Machine Playbook

This is the fast path for getting a brand-new macOS or Linux host to a fully functional state using these dotfiles.

## 0. Pre-flight Checklist

You need a working network connection and `git`.

* **macOS**: install the Xcode Command Line Tools.
  ```bash
  xcode-select --install
  ```
* **Linux**: use your distro package manager to install git (e.g. `sudo apt-get install git`).

Sign in to the accounts you need:

* GitHub (personal) — SSH keys or HTTPS tokens.
* Work Git provider if you plan to pull the work overlay.

## 1. Clone the dotfiles

```bash
rm -rf ~/.dotfiles
git clone git@github.com:armaan-dotfiles/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

If you use HTTPS:

```bash
git clone https://github.com/armaan-dotfiles/dotfiles.git ~/.dotfiles
```

## 2. (Optional) Clone the work overlay

```bash
cd ~/.dotfiles/overlays
rm -rf work
git clone git@work.git/your/work-overlay.git work
```

The overlay is a separate repo. It stays ignored by the base dotfiles.

## 3. Bootstrap the machine

Run the main bootstrap entry point. It guides you through overlay selection, installs packages, links files, and runs setup scripts.

```bash
~/.dotfiles/bootstrap/bootstrap.sh
```

The bootstrap does the following:

1. Asks which overlay to use (defaults to `personal` for non-interactive runs).
2. Installs packages via `brew`/`apt` according to manifests + overlay manifests.
3. Runs the linker to symlink configs into `$HOME`.
4. Executes setup scripts (git, ssh, etc.).

It is idempotent — rerun it whenever you update manifests or configs.

## 4. Post-bootstrap sanity checks

After bootstrap completes:

* Open a new terminal — you should automatically land in tmux with the configured prompt.
* Launch Neovim (`nvim`) — plugins should install via lazy.nvim; run `:checkhealth` if something looks off.
* Check `git config --list --show-origin | grep dotfiles` to confirm the generated configs are in place.
* Run `brew bundle dump` or similar only if you intend to reconcile manifests manually (not usually required).

## 5. Keeping things up to date

* Update this repo (`git pull`) and rerun bootstrap to apply changes.
* Overlay updates are managed independently — pull in `overlays/work` and rerun bootstrap to apply work-specific changes.
* Package changes go through manifests. Edit the appropriate file under `manifests/` (or the overlay mirror) and re-run bootstrap.

## 6. Troubleshooting quick hits

| Symptom | Fix |
| --- | --- |
| Packages missing | Verify manifests + rerun `bootstrap/install-packages.sh`. Check `DOTFILES_OVERLAY_DIR` for overlay selection. |
| tmux not auto-starting | Ensure you’re in a login shell and that `DOTFILES_DISABLE_AUTO_TMUX` is unset. |
| Git setup reruns repeatedly | Delete `~/.gitconfig-machine` or change the marker if you want to reconfigure; otherwise it is skipped once generated. |
| Missing overlay env | Confirm `overlays/<name>/shell/env.sh` exists and overlay was selected during bootstrap. |

## 7. Safe reset

If something goes sideways:

```bash
pushd ~
mkdir -p dotfiles-rescue
mv .zshrc .zprofile .config/tmux dotfiles-rescue/ 2>/dev/null || true
rm -rf ~/.dotfiles
popd
```

Then clone + bootstrap again following the steps above.

---

**Remember:** `$HOME` is disposable. These dotfiles are the source of truth. Reapply rather than patching ad-hoc.

