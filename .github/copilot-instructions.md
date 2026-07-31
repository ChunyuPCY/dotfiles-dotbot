# Repository Instructions

## Architecture

- This is a Dotbot-managed dotfiles repository. `install.conf.yaml` is the
  deployment manifest: it maps each tracked configuration directory to its
  target under `~/.config` (and maps VS Code settings by operating system).
  The root `install` wrapper initializes the `dotbot` submodule and invokes
  that manifest.
- `dotbot` and `dotbot-age` are Git submodules. Treat their source and their
  own CI as upstream concerns unless the task explicitly changes a submodule.
- Secret-bearing configuration follows the Dotbot Age plugin convention:
  `encrypted/secrets.env.age` contains encrypted `KEY=VALUE` values;
  `encrypted/**` contains tracked templates using `{{PLACEHOLDER}}`; and
  `private/` is generated, gitignored output. `./edit-secrets` is the only
  normal workflow for editing the encrypted values: it re-encrypts and
  re-renders templates. Never add an age identity, rendered private output, or
  plaintext secret to Git.
- There are two independent Neovim configurations: `nvim-minimax/` is the
  MiniMax configuration and `lazyvim/` is the LazyVim configuration. Fish
  selects them with `NVIM_APPNAME` aliases. The `nvim/` directory is also
  linked by the manifest and follows the MiniMax layout.
- MiniMax loads `init.lua`, then numbered `plugin/` files for options, maps,
  mini.nvim, and other plugins. Plugin state is tracked in
  `nvim-pack-lock.json`; use `after/` for filetype, LSP, and snippet overrides.
  LazyVim initializes `lazy.nvim` in `lua/config/lazy.lua` and discovers
  custom plugin specs from `lua/plugins/`.
- The WezTerm entry point composes modules from `config/`, registers UI
  behavior from `events/`, and returns the assembled configuration.

## Commands

Run commands from the repository root unless a command changes directory.

| Purpose | Command |
| --- | --- |
| Preview all managed links without changing them | `./install --dry-run` |
| Apply the Dotbot manifest | `./install` |
| Edit and render encrypted secrets | `./edit-secrets` |
| Format-check MiniMax/LazyVim Lua | `cd nvim && stylua --check . && cd ../nvim-minimax && stylua --check . && cd ../lazyvim && stylua --check .` |
| Lint WezTerm Lua | `cd wezterm && luacheck wezterm.lua colors/* config/* events/* utils/*` |
| Format-check WezTerm Lua | `cd wezterm && stylua -g '!/config/init.lua' --check wezterm.lua colors/ config/ events/ utils/` |
| Test Dotbot submodule | `cd dotbot && hatch test -v --cover tests` |
| Run one Dotbot test file | `cd dotbot && hatch test -v --cover tests/test_link.py` |
| Type-check Dotbot submodule | `cd dotbot && hatch run types:check` |
| Format-check Dotbot submodule | `cd dotbot && hatch check fmt` |
| Lint Dotbot submodule | `cd dotbot && hatch check code` |

The root repository has no standalone build or test suite; validate deployment
changes with the dry run above. The Dotbot and WezTerm commands apply only when
editing those nested projects.

## Conventions

- Make target-path changes in `install.conf.yaml` together with the source
  configuration they deploy. Preserve its `link` defaults (`create`, `force`,
  and `relink`) and keep platform-specific VS Code mappings gated by their
  existing `if` conditions.
- Keep generated plugin lockfiles in sync with intentional Neovim plugin
  changes: `nvim-pack-lock.json` for MiniMax and `lazy-lock.json` for LazyVim.
- Format Lua using the configuration nearest to the edited project. MiniMax
  and LazyVim use two-space indentation and 120 columns; WezTerm uses
  three-space indentation and 100 columns.
- Fish loads the generated API-key file conditionally from
  `$XDG_CONFIG_HOME/fish/private/api-key.fish`; update its tracked template
  under `encrypted/fish/`, not the generated target.
