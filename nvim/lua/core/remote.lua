local TARGET_DIR = "/tmp/nvim-remote"

local handle
local uv = vim.loop

local spawn_process = function(cmd, args, callback)
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()
  local stdout_result = {}
  local stderr_result = {}

  local on_read = function(result)
    return function(err, data)
      if err then
        print("Error reading from pipe: " .. err)
        return
      end

      if data then
        table.insert(result, data)
      end
    end
  end

  handle = uv.spawn(cmd, {
    args = args,
    stdio = { nil, stdout, nil },
  }, function(code)
    stdout:read_stop()
    stdout:close()
    handle:close()

    if #stderr_result > 0 then
      print(table.concat(stderr_result))
    end

    local pattern = "^%s*(.-)%s*$"
    local stdout_trimmed = table.concat(stdout_result):gsub(pattern, "%1")
    local stderr_trimmed = table.concat(stderr_result):gsub(pattern, "%1")

    if callback ~= nil then
      callback(code, stdout_trimmed, stderr_trimmed)
    end
  end)

  uv.read_start(stdout, on_read(stdout_result))
  uv.read_start(stderr, on_read(stderr_result))
end

local save_file = function(tmux_prefix)
  if tmux_prefix == nil then
    tmux_prefix = ""
  end

  local filename = TARGET_DIR .. "/" .. tmux_prefix .. vim.loop.getpid()

  -- If the previously created file is still the same,
  -- we don't need to write it again.
  if vim.g.remote_file == filename then
    os.execute("touch " .. filename)
    return
  end

  -- If the file already exists, remove it
  if vim.g.remote_file ~= nil then
    vim.loop.fs_unlink(vim.g.remote_file)
  end

  -- Write the remote file
  local fd = vim.loop.fs_open(filename, "w", tonumber("0644", 8))
  vim.loop.fs_write(fd, vim.v.servername)
  vim.loop.fs_close(fd)

  -- Update the global variable
  vim.g.remote_file = filename
end

local write_nvim_serverfile = function()
  if vim.v.servername == nil then
    -- Neovim build does not support remote, abort silently...
    return
  end

  -- Make sure the target directory exists
  os.execute("mkdir -p " .. TARGET_DIR)

  local is_tmux = os.getenv("TMUX")
  if is_tmux then
    spawn_process("tmux", {
      "display",
      "-p",
      "T_s#{s/^\\$//:session_id}_w#{s/^@//:window_id}_p#{s/^%%//:pane_id}_",
    }, function(code, stdout)
      if code ~= 0 then
        print("Error getting tmux pane info")
        return
      end

      save_file(stdout)
    end)
  else
    save_file()
  end
end

local delete_nvim_serverfile = function()
  local filename = vim.g.remote_file

  if filename ~= nil then
    vim.loop.fs_unlink(filename)
    vim.g.remote_file = nil
  end
end

-- Create a group to scope autocommands in
vim.api.nvim_create_augroup("RemoteAutogroup", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
  group = "RemoteAutogroup",
  callback = write_nvim_serverfile,
})

vim.api.nvim_create_autocmd({ "VimLeave" }, {
  group = "RemoteAutogroup",
  callback = delete_nvim_serverfile,
})
