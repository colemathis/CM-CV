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

-- Set the phrase "public science communication" (e.g. in a talk's note) in
-- the highlight color, keeping any surrounding punctuation uncolored.
local function highlight_phrase(inlines)
    local i = 1
    while i + 4 <= #inlines do
        local a, s1, b, s2, c = inlines[i], inlines[i + 1], inlines[i + 2], inlines[i + 3], inlines[i + 4]
        local pre = a.t == "Str" and a.text:match("^(%p*)public$")
        local post = c.t == "Str" and c.text:match("^communication(%p*)$")
        if pre and post and s1.t == "Space" and b.t == "Str" and b.text == "science"
            and s2.t == "Space" then
            local repl = {pandoc.Str(pre), latex("\\textcolor{awesome}{"),
                          pandoc.Str("public"), pandoc.Space(), pandoc.Str("science"),
                          pandoc.Space(), pandoc.Str("communication"), latex("}"),
                          pandoc.Str(post)}
            for _ = 1, 5 do table.remove(inlines, i) end
            for j = #repl, 1, -1 do table.insert(inlines, i, repl[j]) end
            i = i + #repl
        else
            i = i + 1
        end
    end
    return inlines
end

function Block(el)
    if el.t == "Para" or el.t == "Plain" then
        el = el:walk({Inlines = highlight_phrase})
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
