local defs = {}

defs.local_lib_dir = os.getenv 'HOME' .. '/.local/lib'
defs.deps_dir = defs.local_lib_dir .. '/nvim-deps'

return defs
