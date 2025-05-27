return {
  --"ThePrimeagen/harpoon",
  "shikorido/harpoon",
  branch = "harpoon2",
  --event = "VeryLazy",
  config = function()
    local harpoon = require("harpoon")
    local harpoon_extensions = require("harpoon.extensions")

    local Path = require("plenary.path")
    local function abspath(buf_name)
      return Path:new(buf_name):absolute()
    end

    -- Basic Telescope configuration.
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end
      require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({})
      }):find()
    end

    local toggle_opts = {
      -- From src.
      ui_fallback_width = 69,
      ui_width_ratio = 0.62569,
      -- Custom.
      height_in_lines = 12,
      ui_max_width = 100,
    }

    harpoon:setup({
      settings = {
        save_on_toggle = false,
        sync_on_ui_close = true,
        -- Key for lists lookup. One key => multiple named lists.
        -- Default list name is "__harpoon_files".
        --key = function()
        --  return vim.uv.cwd()
        --end
        -- No more HARPOON_LISTS_DICT->UV_CWD_KEY->LISTS_DICT->__harpoon_files (default).
        -- It will be only HARPOON_LISTS_DICT->GLOBAL_KEY->LISTS_DICT->UV_CWD_KEY (new default if conditions met).
        -- To make it work, Config.DEFAULT_LIST must be changed to vim.uv.cwd()
        -- if no list name provided, key returns "<global>" and new_default_list_behavior is true.
        key = function() return "<global>" end,
        new_default_list_behavior = true,
      },
      global = {
        create_list_item = function(config)
          local name = abspath(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
          local bufnr = vim.fn.bufnr(name, false)
          local pos = { 1, 0 }
          local opts = {}
          if bufnr ~= -1 then
            pos = vim.api.nvim_win_get_cursor(0)
            local buftype = vim.fn.getbufvar(bufnr, "&bt")
            if buftype ~= "" then
              opts.buftype = buftype
            end
          end
          return {
            value = name,
            context = {
              row = pos[1],
              col = pos[2],
              opts = opts,
            },
          }
        end,
      },
    })
    -- Also sets cursor position to the highlighted item.
    -- TODO: Center it via zz.
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    -- Global lists for key-independent files (use separate harpoon instance).
    -- TODO: Figure out how to maintain key for each CWD and in the same time
    --       have "<global>" key or smth. Many things in harpoon code are tied to cwd.
    --       Therefore, it can be tough to achieve w/o invasive src modifications.
    -- TODO2: Implement global list with marks, i.e. add new entry if the context (row, col)
    --        is different from existing ones. Also on select always jump to the context
    --        whenever buffer exists. Life saver for help files, I think.
    -- TODO3: Figure out why help files opened from Harpoon are not configured
    --        well (conceallevel, concealcursor, buftype, etc.).
    vim.keymap.set("n", "<leader>G", function() harpoon:list("global"):prepend() end)
    vim.keymap.set("n", "<leader>g", function() harpoon:list("global"):add() end)
    vim.keymap.set("n", "<C-g>", function() harpoon.ui:toggle_quick_menu(harpoon:list("global"), toggle_opts) end)

    vim.keymap.set("n", "<leader>A", function() harpoon:list():prepend() end)
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts) end)
    vim.keymap.set("n", "<leader><C-s>", function() toggle_telescope(harpoon:list()) end)

    vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
    vim.keymap.set("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
    vim.keymap.set("n", "<leader><C-j>", function() harpoon:list():replace_at(2) end)
    vim.keymap.set("n", "<leader><C-k>", function() harpoon:list():replace_at(3) end)
    vim.keymap.set("n", "<leader><C-l>", function() harpoon:list():replace_at(4) end)

    -- Toggle previous & next buffers stored within Harpoon list.
    --local nav_opts = { ui_nav_wrap = true } --opts to prev/next methods.
    vim.keymap.set("n", "<C-[>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-]>", function() harpoon:list():next() end)

    harpoon:extend({
      UI_CREATE = function(cx)
        vim.keymap.set("n", "<C-x>", function()
          harpoon.ui:select_menu_item({ split = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-v>", function()
          harpoon.ui:select_menu_item({ vsplit = true })
        end, { buffer = cx.bufnr })

        vim.keymap.set("n", "<C-t>", function()
          harpoon.ui:select_menu_item({ tabedit = true })
        end, { buffer = cx.bufnr })

        vim.wo[cx.win_id].rnu = true

        --vim.notify(vim.inspect(cx), vim.log.levels.WARN)
      end
    })

    -- Fixed in fork.
    --local function selectAndUpdateIdx(index, options)
    --  harpoon:list():select(index, options)
    --  --vim.notify("harpoon:" .. vim.inspect(harpoon), vim.log.levels.INFO)
    --  if harpoon:list().items[index] or harpoon:list().config.select_with_nil then
    --    harpoon:list()._index = index
    --  end
    --end

    -- Early, vim.wo[win].nu has no effect, but rnu has.
    --vim.api.nvim_create_autocmd("FileType", {
    --  pattern = "harpoon",
    --  callback = function()
    --    local win = vim.api.nvim_get_current_win()
    --    vim.wo[win].nu = false
    --    vim.wo[win].rnu = false
    --  end
    --})
  end,
}
