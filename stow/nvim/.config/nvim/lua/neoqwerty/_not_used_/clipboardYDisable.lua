--print('System clipboard provider disabler inactive')

--return
--goto exit
--goto ::exit::

--vim.opt.clipboard = nil
--vim.g.loaded_clipboard_provider = 1
--vim.cmd([[
--let g:clipboard = {"name": "void", "copy": {}, "paste": {}}
--let g:clipboard.copy["+"] = {-> v:true}
--let g:clipboard.copy["*"] = {-> []}
--let g:clipboard.paste["+"] = {-> v:true}
--let g:clipboard.paste["*"] = {-> []}
--]])
--vim.print(vim.g.clipboard)

--vim.keymap.set("n", "+y", "y", { remap = true })
--vim.keymap.set("n", "+Y", "Y", { remap = true })
