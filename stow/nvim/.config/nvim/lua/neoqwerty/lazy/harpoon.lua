return {
  --"ThePrimeagen/harpoon",
  "shikorido/harpoon",
  branch = "harpoon2",
  --dependencies = { "plenary.nvim" },

  -- Until I refactor it for more laziness.
  event = "VeryLazy",

  config = function()
    local harpoon = require("harpoon")
    local harpoon_extensions = require("harpoon.extensions")

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
        -- Key for lists lookup.
        -- One key => multiple named lists.
        -- Default list is "__harpoon_files".
        --key = function()
        --	return vim.uv.cwd()
        --end
      },
      --cmd = {
      --	-- @param possible_value string only passed in when you alter the ui manual
      --	create_list_item = function(possible_value)
      --		vim.notify("add", vim.log.levels.WARN)
      --		-- get the current line idx
      --		local idx = vim.fn.line(".")

      --		-- read the current line
      --		local cmd = vim.api.nvim_buf_get_lines(0, idx - 1, idx, false)[1]
      --		if cmd == nil then
      --			return nil
      --		end

      --		return {
      --			value = cmd,
      --			context = { "aboba" }
      --		}
      --	end,

      --	-- @param list_item {value: any, context: any}
      --	-- @param list { ... }
      --	-- @param option any
      --	select = function(list_item, list, option)
      --		vim.cmd(list_item.value)
      --	end
      --}
    })
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    -- Basic Telescope configuration
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

    vim.keymap.set("n", "<leader>A", function() harpoon:list():prepend() end)
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts) end)
    vim.keymap.set("n", "<leader><C-s>", function() toggle_telescope(harpoon:list()) end)

    --local function selectAndUpdateIdx(index, options)
    --	harpoon:list():select(index, options)
    --	--vim.notify("harpoon:" .. vim.inspect(harpoon), vim.log.levels.INFO)
    --	if harpoon:list().items[index] or harpoon:list().config.select_with_nil then
    --		harpoon:list()._index = index
    --	end
    --end

    vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
    vim.keymap.set("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
    vim.keymap.set("n", "<leader><C-j>", function() harpoon:list():replace_at(2) end)
    vim.keymap.set("n", "<leader><C-k>", function() harpoon:list():replace_at(3) end)
    vim.keymap.set("n", "<leader><C-l>", function() harpoon:list():replace_at(4) end)

    -- Toggle previous & next buffers stored within Harpoon list.
    -- list():select() does not update an internal index used by prev/next,
    -- fork fixes it.
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

    -- Early, vim.wo[win].nu has no effect, but rnu has.
    --vim.api.nvim_create_autocmd("FileType", {
    --	pattern = "harpoon",
    --	callback = function()
    --		local win = vim.api.nvim_get_current_win()
    --		vim.wo[win].nu = false
    --		vim.wo[win].rnu = false
    --	end
    --})
  end,
}
