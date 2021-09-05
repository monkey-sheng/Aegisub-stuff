script_name = "Insert per char k tag"
script_description = "Insert a k tag before every char"
script_author = "monkey_sheng"
script_version = "1"

unicode = require('unicode')
--require('utf8')
function insert_per_char_ktag(subs, sel, active)
    for _, i in ipairs(sel) do
        text = ''
        local line = subs[i]
        --line.effect = ''
        local ltext = line.text
        -- for char in line.text:gmatch('.') do
        --     --line.text = line.text .. [[{\k}]]..char
        --     line.text = line.text:sub(1,1)
        -- end

        -- for char in unicode.chars(ltext) do
        --     if not unicode.codepoint(char) == 32 then
        --         text = text .. [[{\k}]] .. char
        --     else text = text .. type(char:sub(1,1))
        --     end
        -- end

        for char in unicode.chars(ltext) do
            if (not (unicode.codepoint(char) == 32)) then 
                text = text..[[{\k0}]] ..char
            else text = text..' '
            end
        end

        line.text = text
        subs[i] = line
    end
    aegisub.set_undo_point('insert per char ktag')
end 

aegisub.register_macro(script_name, script_description, insert_per_char_ktag)