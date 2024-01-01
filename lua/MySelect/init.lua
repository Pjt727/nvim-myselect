-- To run for testing:
--    nvim -c "set rtp+=."
print("Loaded Plugin")
local M = {}

-- Default configuration
local config = {
    key_press = "gs",
    padding_lines = 0,
    auto_close = true,  -- Auto-close split pane
    max_panes = 2  -- Maximum number of split panes
}

-- need to consider here if it was deleted by other means 
-- besides the plugin features
local active_windows = {}

-- Function to handle split command
function M.my_split_command()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]

    -- Calculate the height
    local height = 1

    -- delete pane if a capicity
    print(#active_windows)
    print(config.max_panes)
    if #active_windows + 1 > config.max_panes then
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

    -- Create a horizontal split and resize the window
    local current_buffer = vim.api.nvim_get_current_buf()
    local old_win = vim.api.nvim_get_current_win()
    vim.api.nvim_command('split')
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(new_win, current_buffer)
    vim.api.nvim_win_set_height(new_win, height)
    vim.api.nvim_set_current_win(old_win)
    table.insert(active_windows, new_win)
end

-- Function to close the split pane
function M.close_split()
    -- Close the split pane and clean up any autocmds
    vim.api.nvim_command('q')
    vim.cmd([[autocmd!]])
end

-- Set configuration options
function M.setup(user_config)
    config = vim.tbl_extend('force', config, user_config)
end

vim.keymap.set("n", "gs", ":lua require('MySelect').my_split_command()")

return M

