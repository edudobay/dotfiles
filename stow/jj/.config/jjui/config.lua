function setup(config)
  local basename = string.match(config.repo, "[^/]+$")
  local dirname = string.match(config.repo, "^(.*)/")
  local dirbasename = string.match(dirname, "[^/]+$")

  local rest = "…"
  if dirname == "" then
    rest = ""
  elseif dirbasename and dirname == "/" .. dirbasename then
    rest = "/"
  end
  local title = string.format("jjui 📍%s%s/%s", rest, dirbasename, basename)
  io.write(string.format("\27]2;%s\27\\", title))
end
