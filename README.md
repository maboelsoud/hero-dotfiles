# hero-dotfiles

my own dotfiles, inspired by xero/dotfiles but with my own twist

## Vim / Neovim

The `vim` module installs Neovim and links a LazyVim starter config to
`~/.config/nvim`.

Install just the Vim module:

```bash
./scripts.sh all vim
```

Or install it separately and link it later:

```bash
./scripts.sh install vim
./scripts.sh link vim
```

On first launch, `nvim` will bootstrap `lazy.nvim` and download the LazyVim
plugin set automatically.

Useful follow-up commands:

```bash
nvim
:LazyHealth
```

Notes:

- LazyVim currently requires Neovim 0.11.2 or newer.
- This repo tracks your Neovim config files, not the downloaded plugin code.
- Custom LazyVim tweaks can go in `vim/.config/nvim/lua/plugins/`.
