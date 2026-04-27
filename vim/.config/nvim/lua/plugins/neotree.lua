return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		filesystem = {
			filtered_items = {
				visible = true, -- when true, hidden files are still "hidden" but dimmed
				hide_dotfiles = false,
				hide_gitignored = false,
			},
		},
	},
}
