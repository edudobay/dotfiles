local function config(opts)
  vim.api.nvim_create_user_command('Trim', function()
    vim.cmd '%s/[ \t\r]\\+$//e'
  end, {})

  vim.api.nvim_create_user_command('ChmodX', function()
    if vim.o.modified then
      if vim.fn.confirm('File has been modified! Save?', '&Cancel\n\\&Yes') ~= 2 then
        return
      end

      vim.cmd.w()
    end

    local file = vim.fn.expand '%'
    vim.api.nvim_exec2('silent !chmod -v +x "' .. file .. '"', {})
  end, {})
end

return {
  dir = '.',
  name = 'utils',
  config = config,
  cmd = { 'Trim', 'ChmodX' },
}
