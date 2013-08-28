-- A Go language module for Textadept.
-- 2013, Robert Gieseke
-- License: MIT, see LICENSE

local M = {}

-- Run and compile commands.
_M.textadept.run.compile_command.go = 'go build %(filename)'
_M.textadept.run.run_command.go = 'go run %(filename)'
_M.textadept.run.error_detail.go = {
  pattern = '^(.-):(%d+): (.+)$',
  filename = 1, line = 2, message = 3
}

-- Sets default buffer properties for Go files.
events.connect(events.LEXER_LOADED, function(lang)
  if lang == 'go' then
    buffer.use_tabs = true
    buffer.tab_width = 4
  end
end)

-- Go files are run through `gofmt` before saving and the text is formatted
-- accordingly. If a syntax error is found it is displayed as an annotation.
events.connect(events.FILE_BEFORE_SAVE, function()
  if buffer:get_lexer() ~= 'go' then return end
  local text = buffer:get_text()
  local p = io.popen([[gofmt 2>&1 << "EOL"
]]..text..[[
EOL
]])
  local out = p:read('*a')
  local status = {p:close()}
  if status[3] == 2 then
    buffer:annotation_clear_all()
    local first = out:match('<standard input>:([^\n]+)')
    local line, msg = first:match('(%d-):%d-:([^\n]+)')
    if line and msg and tonumber(line) > 0 then
      -- Scintilla line numbers start from 0
      line = line - 1.
      -- If error is off screen, show annotation on the current line.
      if (line < buffer.first_visible_line) or
         (line > buffer.first_visible_line + buffer.lines_on_screen) then
        line = buffer.line_from_position(buffer.current_pos)
        msg = 'Line '..first
      end
      buffer.annotation_visible = 2
      buffer.annotation_text[line] = msg
      buffer.annotation_style[line] = 8 -- error style number
    end
  elseif status[3] == 0 then
    local current_pos = buffer.current_pos
    local current_line = buffer.line_from_position(current_pos)
    buffer:begin_undo_action()
    buffer.set_text(out)
    buffer:goto_pos(current_pos)
    -- Return to original line if reformatting moved the caret.
    if buffer.line_from_position(buffer.current_pos) ~= current_line then
      buffer:goto_line(current_line)
    end
    buffer:end_undo_action()
  end
end)

-- Go snippets.
if type(snippets) == 'table' then
  snippets.go = {
    const = 'const %1(name) %2(type)  = %3(value)',
    f = 'func %1(name)(%2(arguments)) %3((%4(results))) {\n\t%0\n}',
    imp = 'import "%1(package)"',
    imps = 'import (\n\t"%1(package)"%0\n)',
    pkg = 'package %1(main)',
    var = 'var %1(name) %2(type) %3( = %4(value))',
  }
end

return M
