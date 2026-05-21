# AGENTS.md

This repo has no build, test, or lint commands — it's a dotfiles collection
installed by a custom ZSH-based installer.

## Installer DSL

`install.sh` walks the repo and parses `@!` annotations in each file.
The grep pattern is `@!\w+:` — annotations are **enabled** only when
`@!` has no space between the sigils.

To install: `zsh install.sh` from repo root.

Supported directives (all use the `@!directive:arg` format):
  @!os:<os>              # linux | darwin | unix
  @!user:<user>
  @!host:<hostname>
  @!install:<mode>:<path>
  @!dirmode:<mode>:<path>
  @!hardlink:<path>      # hardlinks from the last-@!install'd file
  @!zshexpn              # shell-expand file contents before install

## Disabling annotations

To temporarily disable an annotation, add a space: `@ !os:linux` or
change the sigil: `@x`.  The regex won't match either form.
Current disabled files:
  - quickshell/shell.qml      (uses @ ! — not ready to install)
  - lemonade/lemonade.toml    (uses @x — currently unused)
  - lemonade/lemonade.service (uses @X — currently unused)
  - nvim/queries/bash/indent.scm

## Known quirks

- `postexec` is parsed but the command is commented out with a TODO in
  install.sh — it never actually runs.
- `@!zshexpn` exists in the installer but no current file uses it.

## Obsolete directories

`ags/` and `eww/` are unused/legacy. Do not waste time on them.

## Repository

- Origin: git@github.com:samuellwn/myconfig.git
- Branch: master
