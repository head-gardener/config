## Dependencies

`packer.nvim` is used for package management.
Multiple language servers are mentioned in `lua/lsp.lua`, make sure they work or change them up if you are planning on using language servers.

## Configure

Install `packer.nvim`.
Run 
```
:PackerCompile
:PackerInstall
```
Should be a smooth ride from there.

## Syntax highlighting

Run
```
:TSInstall <lang>
```
To install syntax highlighting module for a language.

## Branches

To switch to a safe branch run
```
git checkout safe
```
In safe branch all plugins are disabled, 
leaving only colorscheme, some configs and keymaps.  
I use it for `/root/.config`.

