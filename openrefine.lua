local json = require 'pandoc.json'

local highlight = {jython="python", grel="javascript"}

local style = [[
<style>
  h2 {
    font-size: 1.25rem;
  }
  div.sourceCode {
    margin: initial;
  }
  table {
    border-radius: .5em;
    box-shadow: 2px 2px 4px silver;
    border-collapse: separate;
    border-spacing: .25em .75em;
  }
  tbody {
    border: none;
  }
  td {
    vertical-align: top;
  }
  td:first-child {
    font-weight: bold;
  }
  td:first-child::after {
    content: ":"
  }
  td:last-child {
    border-radius: .2em;
    padding: .2em;
    box-shadow: rgba(0, 0, 0, 0.15) 0px 3px 3px 0px inset;
  }

</style>
]]

local function format_code( text )
    local lang = string.match(text, "([^:]+)")
    hl_lang = highlight[lang]
    local rest = string.sub(text, string.len(lang)+2)
    if string.find(rest, "\n") then
        code = pandoc.CodeBlock(rest, {class=hl_lang})
    else
        code = pandoc.Code(rest, {class=hl_lang})
    end
    return lang, code
end

function Reader( input )
    local parsed = json.decode(tostring(input))
    local blocks = {}

    for _, entry in ipairs(parsed) do
        local item = {}
        local extra = {}
        local desc = ""
        if entry.expression or entry.urlExpression then
            local expression
            if entry.expression then
                expression = entry.expression
            elseif entry.urlExpression then
                expression = entry.urlExpression
            end
            s, e = string.find(entry.description, " using expression " .. expression, 1, true)
            -- description w/o expression
            --table.insert(item, string.sub(entry.description, 1, s-1))
            desc = string.sub(entry.description, 1, s-1)
            -- expression
            if expression ~= "grel:value" then
                local lang, code = format_code(expression)
                extra["Language"] = lang
                extra["Expression"] = code
            end
        else
            desc = entry.description
        end
        table.insert(item, pandoc.Header(2, desc))
        -- check for extra info to print
        if entry.op == "core/column-reorder" then
            extra["Column order"] = table.concat(entry.columnNames, ", ")
        end
        if entry.separator then
            extra["Separator"] = pandoc.Code(entry.separator)
        end
        if entry.maxColumns then
            extra["At most columns"] = string.format("%d", entry.maxColumns)
        end
        -- create table with extra information
        if next(extra) ~= nil then
            local rows = {}
            for key, value in pairs(extra) do
                local row = {key, value}
                table.insert(rows, row)
            end
            param_table = pandoc.SimpleTable(
                "", -- caption
                {pandoc.AlignDefault, pandoc.AlignDefault}, -- alignments
                {0, 0}, -- column width (unspecified)
                {},
                rows
                )
            table.insert(item, pandoc.utils.from_simple_table(param_table))
        end
        local div = pandoc.Div(item, {class="openrefine"})
        table.insert(blocks, div)
    end

    return pandoc.Pandoc(blocks,
                         {["header-includes"] = pandoc.RawBlock("html", style)})

end
