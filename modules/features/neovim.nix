{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.neovim = (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        {
          config.vim = {
#============================================== START CONFIG
            options = {
              tabstop = 2;
              shiftwidth = 2;
              expandtab = false;
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
						};
						ui = {
							smartcolumn.enable = true;
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
						languages = {
							nix.enable = true;

							# Web LSPs
							typescript.enable = true;
							html.enable = true;
							css.enable = true;
							tailwind.enable = true;

							# Scripting LSPs
							lua.enable = true;
							python.enable = true;

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
						utility.smart-splits = {
							enable = true;
							keymaps = {
								swap_buf_down = null;
								swap_buf_left = null;
								swap_buf_up = null;
								swap_buf_right = null;
							};
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
								setupModule = "nordic";
								# setupOpts = { ... };
							};
						};

						binds.whichKey = {
							enable = true;
							setupOpts.preset = "helix";
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
