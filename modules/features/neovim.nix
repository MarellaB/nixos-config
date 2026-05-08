{ inputs, ... }: {
  perSystem = { pkgs, system, ... }:
  let
    patchedPkgs = if system == "aarch64-darwin"
      then pkgs.extend (_: prev: {
        csharp-ls = prev.csharp-ls.overrideAttrs (old: {
          meta = old.meta // { badPlatforms = []; };
        });
      })
      else pkgs;
  in {
    packages.neovim = (inputs.nvf.lib.neovimConfiguration {
      pkgs = patchedPkgs;
      modules = [
        {
          config.vim = {
#============================================== START CONFIG
            options = {
              tabstop = 2;
              shiftwidth = 2;
              expandtab = false;
							cursorline= true;
							cursorlineopt = "both";
							scrolloff = 8;
							wrap = false;
							autoindent = true;
							smartindent = true;
            };
						git.enable = true;
						autocomplete.blink-cmp.enable = true;
						# Disable in built themes and use the imported nordic theme
            theme.enable = false;
						luaConfigPost = ''
							vim.cmd.colorscheme("nordic");
						'';

						visuals = {
							nvim-web-devicons.enable = true;
							blink-indent = {
								enable = true;
								setupOpts = {
									scope.highlights = [ "BlinkIndentScope" ];
								};
							};
							cinnamon-nvim.enable = true;
							highlight-undo.enable = true;
							nvim-cursorline = {
								enable = true;
								setupOpts = {
									# cursorline.enable = true;
									# cursorline.number = true;
									cursorword.enable = true;
								};
							};

							# FML Mode (Fun)
							cellular-automaton.enable = true;
						};
						ui = {
							smartcolumn = {
								enable = true;
								setupOpts.colorcolumn = "80";
							};
							noice = {
								enable = true;
								setupOpts.presets = {
									bottom_search = true;
									command_palette = true;
									long_message_to_split = true;
								};
							};
						};

						lsp.enable = true;
						lsp.presets = {
							tailwindcss-language-server.enable = true;
						};
						lsp.servers.nixd.settings.nil.nix.autoArchive = true;
						languages = {
							enableTreesitter = true;

							nix.enable = true;
							markdown.enable = true;
							toml.enable = true;
							yaml.enable = true;
							json.enable = true;
							xml.enable = true;

							# Web LSPs
							typescript = {
								enable = true;
								extensions.ts-error-translator.enable = true;
							};
							html.enable = true;
							css.enable = true;
							svelte.enable = true;

							# Scripting LSPs
							lua.enable = true;
							python.enable = true;
							bash.enable = true;

							# Work LSPs
							csharp.enable = true;
						};

#============================================== PLUGINS

						filetree.neo-tree = {
							enable = true;
							setupOpts = {
								add_blank_line_at_top = true;
								close_if_last_window = false;
								follow_current_file.enabled = true;
								filesystem = {
									follow_current_file.enabled = true;
									use_libuv_file_watcher = true;
									filtered_items = {
										visible = true;
										hide_dotfiles = false;
										hide_gitignored = false;
									};
								};
							};
						};

						statusline.lualine.enable = true;

            telescope = {
              enable = true;
              mappings = {
                findFiles = "<leader>ff";
                liveGrep = "<leader>fg";
                buffers = "<leader>fb";
                helpTags = "<leader>fh";
              };
            };

						# Dashboard
						dashboard.alpha = {
							enable = true;
						};

						# Replaces tmux-navigator
						utility = {
							smart-splits = {
								enable = true;
								keymaps = {
									swap_buf_down = null;
									swap_buf_left = null;
									swap_buf_up = null;
									swap_buf_right = null;
								};
							};

							yanky-nvim = {
								enable = true;
								setupOpts = {
									ring.storage = "memory";
									highlight.timer = 100;
								};
							};

							leetcode-nvim = {
								enable = true;
								setupOpts = {
									lang = "typescript";
								};
							};

							outline.aerial-nvim = {
								enable = true;
								mappings.toggle = "<leader>so";
							};
							
							# Useful to learn more in depth motions, but distracting.
							# motion.precognition.enable = true;

							# Flash or Leap for faster jump navigation?
						};


						terminal.toggleterm = {
							enable = true;
							lazygit = {
								enable = true;
								mappings.open = "<leader>gg";
							};
						};

						lazy.plugins = {
							"smear-cursor.nvim" = {
								package = pkgs.vimPlugins.smear-cursor-nvim;
								setupModule = "smear_cursor";
								setupOpts = {
									smear_between_buffers = true;
									smear_between_neighbor_lines = true;
									cursor_color = "#d0d0d0";
								};
							};

							"nordic.nvim" = {
								package = pkgs.vimPlugins.nordic-nvim;
								# setupModule = "nordic";
								# setupOpts = { ... };
							};
						};

						binds.whichKey = {
							enable = true;
							setupOpts.preset = "helix";
						};

						extraPlugins = {
							bento-nvim = {
								package = pkgs.vimUtils.buildVimPlugin {
									name = "bento-nvim";
									src = inputs.bento-nvim;
								};
								setup = "require('bento').setup {}";
							};
						};

#============================================== KEYMAPS
            keymaps = [

							# Telescope quick search
							{
								key = "<leader><leader>";
								mode = "n";
								silent = true;
								action = "<cmd>Telescope find_files<cr>";
								desc = "Find Files";
							}

							# Explorer Keybinds
							{
								key = "<leader>e";
								mode = "n";
								silent = true;
								action = "<cmd>Neotree toggle<cr>";
								desc = "Toggle file explorer";
							}

							# Tab Movement Binds
							{
								key = "<";
								mode = "v";
								silent = true;
								action = "<gv";
							}
							{
								key = ">";
								mode = "v";
								silent = true;
								action = ">gv";
							}
						];

#============================================== AUTO-COMMANDS

						autocmds = [
							
							/* Enables neo-tree to open at startup.
							{
								event = [ "VimEnter" ];
								command = "Neotree show";
								desc = "Open neo-tree on startup";
							}
							*/

						];

#============================================== END CONFIG
          };
        }
      ];
    }).neovim;
  };
}
