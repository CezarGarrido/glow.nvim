local api = vim.api
local win, buf
local M = {}

-- title sets the window title
-- local function title(str)
--   local width = api.nvim_win_get_width(0)
--   local text_pos = math.floor(width / 2) - math.floor(string.len(str) / 2)
--   return string.rep(" ", text_pos) .. str
-- end

-- glow grabs glow command results
local function get_glow_output()
  -- need to check if glow command exists
  local content = api.nvim_buf_get_lines(1, 0, api.nvim_buf_line_count(1), false)

  -- call glow with current content

  return content
end

-- open_window draws a custom window with the markdown contents
local function open_window()
  buf = api.nvim_create_buf(false, true)
  local border_buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  -- api.nvim_buf_set_option(buf, 'filetype', 'markdown')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local border_opts = {
    style = "minimal";
    relative = "editor";
    width = win_width + 2;
    height = win_height + 2;
    row = row - 1;
    col = col - 1;
  }

  local opts = {
    style = "minimal";
    relative = "editor";
    width = win_width;
    height = win_height;
    row = row;
    col = col;
  }

  -- border buffer
  local border_lines = {'╔' .. string.rep('═', win_width) .. '╗'}
  local middle_line = '║' .. string.rep(' ', win_width) .. '║'
  for _ = 1, win_height do
    table.insert(border_lines, middle_line)
  end
  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
  api.nvim_open_win(border_buf, true, border_opts)
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

  -- main floating window buffer
  local result = get_glow_output()
  win = api.nvim_open_win(buf, true, opts)
  api.nvim_buf_set_option(buf, "modifiable", true)
  api.nvim_buf_set_lines(buf, 0, -1, false, result)
  api.nvim_buf_set_option(buf, "modifiable", false)
end

local function set_mappings()
  local mappings = {q = 'close_window()'}

  for key, val in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, "n", key, ":lua require('glow')." .. val .. "<cr>",
                            {nowait = true; noremap = true; silent = true})
  end
end

local function close_window()
  api.nvim_win_close(win, true)
  vim.cmd("bd")
end

local function validate()
  assert(vim.bo[0].filetype == "markdown", "file must be markdown")
end

local function dowload_glow()
  -- TODO:
end

-- exporting functions
M.glow = function()
  validate()
  open_window()
  set_mappings()
end

M.close_window = close_window

return M
