-- Bold my name ("Mathis, C.") in bibliography entries. On entries where I am
-- the author of correspondence (bold "#" annote marker), also set the marker
-- and my name in the CV highlight color (LaTeX color "awesome").

local function latex(s) return pandoc.RawInline("latex", s) end

local function highlight(inlines)
    local out = {latex("\\textcolor{awesome}{")}
    for _, inl in ipairs(inlines) do table.insert(out, inl) end
    table.insert(out, latex("}"))
    return out
end

-- True if the paragraph's bold annote marker contains "#"; recolors that "#".
local function mark_corresponding(content)
    local found = false
    for _, inl in ipairs(content) do
        if inl.t == "Strong" then
            for i, s in ipairs(inl.content) do
                if s.t == "Str" and s.text == "#" then
                    inl.content[i] = latex("\\textcolor{awesome}{\\#}")
                    found = true
                end
            end
            if found then return true end
        end
    end
    return false
end

function Block(el)
    if el.t == "Para" or el.t == "Plain" then
        local corresponding = mark_corresponding(el.content)

        for k, _ in ipairs(el.content) do

            if el.content[k].t == "Str" and el.content[k].text == "Mathis," and
                el.content[k + 1].t == "Space" and el.content[k + 2].t == "Str" and
                el.content[k + 2].text:find("^C.") then

                local _, e = el.content[k + 2].text:find("^C.")
                local rest = el.content[k + 2].text:sub(e + 1) -- empty if e+1>length
                local name = pandoc.Strong {pandoc.Str("Mathis, C.")}
                if corresponding then
                    name = pandoc.Span(highlight({name}))
                end
                el.content[k] = name
                el.content[k + 1] = pandoc.Str(rest)
                table.remove(el.content, k + 2) -- safe? another way would be to set element k+2 to Str("")
                -- no real need to skip ipairs items here

            end

        end
    end
    return el
end
