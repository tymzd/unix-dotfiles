# Open Clipboard URL in Simple Browser

A tiny personal VS Code extension that adds one command:

- **Open Clipboard URL in Simple Browser** (`sos.openClipboardInSimpleBrowser`):
  reads the clipboard and, if it holds an `http(s)` URL, opens it in VS Code's
  integrated Simple Browser. Otherwise it shows a warning.

## Why it exists

I want GitLens's "open on remote" shortcuts (`shift+alt+i` for the file,
`shift+alt+r` for the commit) to open Gerrit inside VS Code rather than in
Chrome. GitLens's `openFileOnRemote` / `openCommitOnRemote` always use VS
Code's "open external" path, and `workbench.externalUriOpeners` can't redirect
them because the Simple Browser only registers itself as an external opener for
localhost URLs.

So the keybindings in `home-config/.config/Code/User/keybindings.json` instead
chain two commands with `runCommands`:

1. GitLens copies the remote URL (`gitlens.copyRemoteFileUrlToClipboard` /
   `gitlens.copyRemoteCommitUrl`).
2. This extension opens the clipboard URL with `simpleBrowser.show`.

## Install

```sh
./install.sh              # build the .vsix and `code --install-extension` it
./install.sh --build-only # just build the .vsix
```

Then run **Developer: Reload Window**.

## Remote-SSH notes

- Run `install.sh` from VS Code's integrated terminal while connected to the
  remote, so it installs on the remote VS Code server next to GitLens.
- Keybindings, on the other hand, are read from the **client** machine's
  `keybindings.json` (open it with *Preferences: Open Keyboard Shortcuts
  (JSON)*), so the bindings need to be present on the laptop too.
