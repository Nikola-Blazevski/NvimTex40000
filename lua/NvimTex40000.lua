local M = {}

local function get_pdf_path()
  return "build/" .. vim.fn.expand("%:t:r") .. ".pdf"
end



local function ensure_build_dir()

  if vim.fn.isdirectory("build") == 0 then
    vim.fn.mkdir("build")
  end

end



local function compile_and_open_zathura()
  ensure_build_dir()
  local tex_file = vim.fn.expand("%")
  local pdf_file = get_pdf_path()

  vim.fn.jobstart(
  {
    "pdflatex", "-interaction=nonstopmode",
    "-synctex=1", "-output-directory=build", tex_file
  }, 

  {
    on_exit = function(_, code)

      if code == 0 then
        local handle = io.popen("pgrep -a zathura")
        local output = handle:read("*a")
        handle:close()

        if not output:match(pdf_file) then
          vim.fn.jobstart({ "i3-msg", "split horizontal" })
          vim.fn.jobstart({ "sh", "-c", "zathura '" .. pdf_file .. "' & sleep 0.4 && i3-msg focus left" }, { detach = true })
        end

      else
        vim.notify("Unable to compile.", vim.log.levels.ERROR) -- should probably add more descriptive message, maybe use tmux to create new window for user to see compile
      end

    end

  })

end





-- Close Zathura if it has this PDF open
local function close_zathura()

  local pdf_file = get_pdf_path()
  local handle = io.popen("pgrep -a zathura")
  local output = handle:read("*a")
  handle:close()

  for pid, cmd in output:gmatch("(%d+)%s+(.-)\n") do
	  
    if cmd:find(pdf_file, 1, true) then
      vim.fn.jobstart({ "kill", pid })
    end

  end

end






-- Setup autocommands
function M.setup()

  vim.api.nvim_create_autocmd("BufEnter", 
  {
    pattern = "*.tex",
    callback = compile_and_open_zathura,
  })

  vim.api.nvim_create_autocmd("BufWritePost", 
  {
    pattern = "*.tex",
    callback = compile_and_open_zathura,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", 
  {
    pattern = "*.tex",
    callback = close_zathura,
  })

end

return M
