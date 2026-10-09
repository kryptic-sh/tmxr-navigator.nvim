# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `C-h` / `C-j` / `C-k` / `C-l` move between nvim splits and, at nvim's edge
  inside tmxr, to the neighbouring tmxr pane (`tmxr select-pane`); `C-\` goes
  back to the previous one.
- `:TmxrNavigateLeft` / `Down` / `Up` / `Right` / `Previous` commands.
- Options `no_mappings`, `disable_when_zoomed` and `save_on_switch`, as in
  vim-tmux-navigator.
