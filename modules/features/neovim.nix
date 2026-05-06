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
						autocomplete.blink-cmp.enable = true;
            theme = {
							enable = true;
							name = "catppuccin";
							style = "frappe";
						};
						visuals = {
							nvim-web-devicons.enable = true;
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
						languages.nix.enable = true;

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
