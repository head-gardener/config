function dash -d ""
  if set -q XDG_DATA_HOME
    set data "$XDG_DATA_HOME/fish-dash"
  else
    set data "$HOME/.local/share/fish-dash"
  end
  mkdir -p "$data"

  gen-commands "$data"

  set file "$data/$(pwd | sed 's/[\/ ]/_/g').fish"
  touch "$file"

  nvim -c "source $data/commands.lua" "$file"
end

function gen-commands -a data
  echo '
Dash = {}

function Dash.sendline()
  local line = vim.fn.getline(".")
  local pane = 0
  vim.system({"tmux", "send", "-t", tostring(pane), line, "Enter"}, {})
end

function Dash.runline()
  local line = vim.fn.getline(".")
  local output = vim.fn.systemlist("fish -c \'" .. string.gsub(line, "\'", "\\\\\'") .. "\'")

  table.insert(output, "Exit code: " .. tostring(vim.v.shell_error))

  for i, v in ipairs(output) do
    output[i] = string.format(vim.bo.commentstring, "| " .. v)
  end

  local current_line = Dash.clearline()
  vim.fn.append(current_line, output)
end

function Dash.prevline()
  local comment_prefix = string.format(vim.bo.commentstring, "| ")
  vim.fn.search("^[^(" .. comment_prefix .. ")]", "b")
end

function Dash.nextline()
  local comment_prefix = string.format(vim.bo.commentstring, "| ")
  vim.fn.search("^[^(" .. comment_prefix .. ")]")
end

function Dash.clearline()
  local current_line = vim.fn.line(".") - 1
  local comment_prefix = string.format(vim.bo.commentstring, "| ")
  while string.sub(vim.fn.getline(current_line), 1, string.len(comment_prefix)) == comment_prefix do
   vim.fn.deletebufline("%", current_line)
   current_line = current_line - 1
  end
  return current_line
end

function Dash.clearall()
  local comment_prefix = string.format(vim.bo.commentstring, "| ")
  vim.cmd("g/^" .. comment_prefix .. "/delete")
end

vim.keymap.set("n", "<localleader>ls", Dash.sendline, { desc = "send current line to a pane" })
vim.keymap.set("n", "<localleader>lr", Dash.runline, { desc = "execute current line in buffer" })
vim.keymap.set({ "n", "v" }, "<localleader>lp", Dash.prevline, { desc = "go to next command line" })
vim.keymap.set({ "n", "v" }, "<localleader>ln", Dash.nextline, { desc = "go to previous command line" })
vim.keymap.set("n", "<localleader>lc", Dash.clearline, { desc = "clear dash comment for current line" })
vim.keymap.set("n", "<localleader>lw", Dash.clearall, { desc = "(w)ipe, clear all dash comments" })

print("Welcome to dash! Use `:lua Dash.<command>()` or <localleader>l prefix to execute commands")
' > "$data/commands.lua"
end
