local colors = {
  bg = "#2e3440",
  fg = "#d8dee9",
  cyan = "#88c0d0",
  magenta = "#b48ead",
  slate = "#434c5e",
  steel = "#4c566a",
}

local wizard_theme = {
  normal = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.magenta, fg = colors.bg },
    c = { bg = colors.steel, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
  insert = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.magenta, fg = colors.bg },
    c = { bg = colors.steel, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
  visual = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.magenta, fg = colors.bg },
    c = { bg = colors.steel, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
  replace = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.magenta, fg = colors.bg },
    c = { bg = colors.steel, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
  command = {
    a = { bg = colors.cyan, fg = colors.bg },
    b = { bg = colors.magenta, fg = colors.bg },
    c = { bg = colors.steel, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
  inactive = {
    a = { bg = colors.slate, fg = colors.fg },
    b = { bg = colors.steel, fg = colors.fg },
    c = { bg = colors.slate, fg = colors.fg },
    x = { bg = colors.slate, fg = colors.fg },
    y = { bg = colors.steel, fg = colors.fg },
    z = { bg = colors.slate, fg = colors.fg },
  },
}

local function hero_path()
  local path = vim.fn.expand("%:~:.")
  if path == "" then
    path = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
  end
  return path
end

local function hero_branch()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns or not gitsigns.head or gitsigns.head == "" then
    return ""
  end

  local dirty = ""
  if (gitsigns.added or 0) > 0 or (gitsigns.changed or 0) > 0 or (gitsigns.removed or 0) > 0 then
    dirty = "↯"
  end

  return string.format("%s%s", gitsigns.head, dirty)
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = wizard_theme
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "█▓▒░", right = "░▒▓█" }
    opts.options.always_divide_middle = false

    opts.sections.lualine_a = {
      {
        hero_path,
        padding = { left = 1, right = 1 },
      },
    }
    opts.sections.lualine_b = {
      {
        hero_branch,
        cond = function()
          return hero_branch() ~= ""
        end,
        padding = { left = 1, right = 1 },
      },
    }
    opts.sections.lualine_c = {}
    opts.sections.lualine_x = {}
    opts.sections.lualine_y = {
      { "progress", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    }
    opts.sections.lualine_z = {
      {
        function()
          return os.date("%R")
        end,
        padding = { left = 1, right = 1 },
      },
    }

    return opts
  end,
}
