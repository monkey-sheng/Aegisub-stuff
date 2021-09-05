local tr = aegisub.gettext

script_name = tr"Remove text in selected lines"
script_description = tr"Remove all text from selected lines"
script_author = "monkey_sheng"
script_version = "1"

function strip_tags(subs, sel, active)
    for _, i in ipairs(sel) do
        local line = subs[i]
        line.text = ""
        subs[i] = line
    end
    aegisub.set_undo_point(tr"remove text")
end

aegisub.register_macro(script_name, script_description, strip_tags)