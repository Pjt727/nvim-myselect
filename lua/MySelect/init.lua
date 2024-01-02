-- To run for testing:
--    nvim -c "set rtp+=."
print("Loaded Plugin")
local M = {}

-- Default configuration
local config = {
    start = "ns", -- new select
    delete = "<Leader>nd", -- delete select
    repeat_char = "s",
    padding_lines = 0,
    auto_close = true,  -- Auto-close split pane
    max_panes = 2  -- Maximum number of split panes
}

-- need to consider here if it was deleted by other means 
-- besides the plugin features
local active_windows = {}

local function delete_pane()
    if next(active_windows) == nil then return end
    local oldest_win = active_windows[1]
    table.remove(active_windows, 1)

    -- Store current heights to resize after removing
    local heights = {}
    for _, window in ipairs(active_windows) do
        local win_height = vim.api.nvim_win_get_height(window)
        table.insert(heights, win_height)
    end

    vim.api.nvim_win_close(oldest_win, true)

    -- Resize the other windows to their previous heights
    for index, window in ipairs(active_windows) do
        vim.api.nvim_win_set_height(window, heights[index])
    end
end

local function get_char()
    local ok, char = pcall(vim.fn.getcharstr)
    if not ok or char == "\27" then
        return nil
    end
    return vim.api.nvim_replace_termcodes(char, true, true, true)
end

-- Gets the amount of lines above the cursor
-- if it is above the cursor then it will be negative
local function get_lines_below ()
    local command_buffer = ""
    while true do
         local ch = get_char()
         if ch == nil then return nil end
         if ch:match("[1-9]") then
             command_buffer = command_buffer .. ch
         else
             if command_buffer == "" and ch == config.repeat_char then return 0 end
             if ch ~= "j" and ch ~= "k" then return nil end
             local size = 1
             if command_buffer ~= "" then
                 ---@diagnostic disable-next-line: param-type-mismatch
                 size = math.floor(tonumber(command_buffer))
             end
             if ch == "k" then size = size * -1 end
             return size
         end
     end
end

-- Function to handle split command
function M.start_split()
    -- local current_line = vim.api.nvim_win_get_cursor(0)[1]

    local lines_below = get_lines_below()
    if lines_below == nil then return end
    -- delete pane if a capicity
    if #active_windows + 1 > config.max_panes then
        delete_pane()
    end
    -- Place the text in the new window
    local current_buffer = vim.api.nvim_get_current_buf()
    local old_win = vim.api.nvim_get_current_win()
    vim.api.nvim_command('split')
    local new_win = vim.api.nvim_get_current_win()
    -- not sure if this is needed
    -- putting the cursor in the center of the selection
    -- prob a less hacky way of doing that
    vim.api.nvim_win_set_option(new_win, 'scrolloff', 9999)
    vim.api.nvim_win_set_buf(new_win, current_buffer)
    local height = math.abs(lines_below) + 1
    local current_line = vim.api.nvim_win_get_cursor(new_win)[1]
    -- TODO add more functionality to make height change for out of bounds
    vim.api.nvim_win_set_height(new_win, height)
    local center_line = math.floor((current_line + current_line + lines_below)/2)
    vim.api.nvim_win_set_cursor(new_win, { center_line, 1 })
    vim.api.nvim_set_current_win(old_win)

    -- Keep track of windows opened by the plugin
    table.insert(active_windows, new_win)
end

-- Function to close the split pane
function M.close_split()
    delete_pane()
end

-- Set configuration options
function M.setup(user_config)
    config = vim.tbl_extend('force', config, user_config)
end

vim.keymap.set("n", config.start, ":lua require('MySelect').start_split()<CR>")
vim.keymap.set("n", config.delete, ":lua require('MySelect').close_split()<CR>")

return M
