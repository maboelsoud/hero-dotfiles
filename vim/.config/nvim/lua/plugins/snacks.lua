return {
	"folke/snacks.nvim",
	opts = {
		styles = {
			-- Make picker/explorer windows sit on the same Nord-ish slate background
			-- instead of the near-black NormalFloat defaults.
			picker = {
				wo = {
					winhighlight = table.concat({
						"Normal:SnacksPicker",
						"NormalNC:SnacksPicker",
						"NormalFloat:SnacksPicker",
						"FloatBorder:SnacksPickerBorder",
						"FloatTitle:SnacksPickerTitle",
					}, ","),
				},
			},
		},
		picker = {
			sources = {
				explorer = {
					hidden = true, -- Show hidden files in explorer
				},
			},
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)

		local function set_picker_highlights()
			-- local bg = "#3b4252"
			local bg = "#2d3440"
			local bg_alt = "#434c5e"
			local fg = "#d8dee9"
			local accent = "#81a1c1"
			local border = "#4c566a"
			local hidden = "#4c566a"

			local set = vim.api.nvim_set_hl
			set(0, "SnacksPicker", { bg = bg, fg = fg })
			set(0, "SnacksPickerBorder", { bg = bg, fg = border })
			set(0, "SnacksPickerTitle", { bg = bg_alt, fg = accent, bold = true })
			set(0, "SnacksPickerBoxBorder", { bg = bg, fg = border })
			set(0, "SnacksPickerInput", { bg = bg, fg = fg })
			set(0, "SnacksPickerInputBorder", { bg = bg, fg = border })
			set(0, "SnacksPickerList", { bg = bg, fg = fg })
			set(0, "SnacksPickerPreview", { bg = bg, fg = fg })
			set(0, "SnacksPickerPreviewBorder", { bg = bg, fg = border })
			set(0, "SnacksPickerPreviewTitle", { bg = bg_alt, fg = accent, bold = true })
			set(0, "SnacksPickerDir", { fg = accent, bg = bg })
			set(0, "SnacksPickerPathHidden", { fg = hidden, bg = bg })
			set(0, "SnacksPickerCursorLine", { bg = bg_alt })
			set(0, "SnacksPickerListCursorLine", { bg = bg_alt })
			set(0, "SnacksPickerMatch", { fg = "#88c0d0", bold = true })
		end

		set_picker_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("hero_snacks_nord", { clear = true }),
			callback = set_picker_highlights,
		})
	end,
}
