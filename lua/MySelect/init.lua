local config = {
    start = "ns",
    delete = "dS",
    placement = "top",
}

local last_win = nil

local function delete_split ()
    if last_win == nil then return end
    if not vim.api.nvim_win_is_valid(last_win) then
        last_win = nil
        return
    end

    vim.api.nvim_win_close(last_win, true)
end

local function delete_split_operator ()
    delete_split()
    return "Deleted Split"
end


_G.start_split = function ()
    local start_line = vim.fn.getpos("'[")[2]
    local stop_line = vim.fn.getpos("']")[2]
    local win_height = math.max(1, stop_line-start_line + 1)
    delete_split()
    local og_win = vim.api.nvim_get_current_win()
    vim.cmd(string.format("%s %dsplit", config.placement, win_height))
    local new_win = vim.api.nvim_get_current_win()
    vim.wo.scrolloff = 0
    vim.cmd(tostring(start_line))
    vim.api.nvim_set_current_win(og_win)
    last_win = new_win
end

local function start_split_operator ()
    vim.opt.operatorfunc = "v:lua.start_split"
    return "g@"
end

-- idk if these keybind will actually be changed when user chaning keybinds
vim.keymap.set({"n", "x"}, config.start, start_split_operator, {expr = true})
vim.keymap.set({"n"}, config.delete, delete_split_operator)

