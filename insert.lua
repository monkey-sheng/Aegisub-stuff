script_name = "Insert a line b4&after"
script_description = "Insert a line before and after every line"
script_author = "monkey_sheng"
script_version = "1"

function insert_b4_after(subs, sel, active)
    BEFORE_DURATION = 800
    AFTER_DURATION = 1000

    new_subs = {}
    sel_start = sel[1]
    sel_end = sel[#sel]
    -- strip (k)tags and do a per char k tag for start and after
    for _, i in ipairs(sel) do
        original_line = subs[i]
        b4_start = original_line.start_time - BEFORE_DURATION
        b4_end = original_line.start_time
        after_start = original_line.end_time
        after_end = original_line.end_time + AFTER_DURATION

        b4 = subs[i]
        b4.start_time = b4_start
        b4.end_time = b4_end
        b4.style = 'start-' .. b4.style
        b4.text = b4.text:gsub("{[^}]+}", "")
        text = ''
        for char in b4.text:gmatch('.') do
            text = text .. [[{\k0}]] .. char
        end
        b4.text = text

        after = subs[i]
        after.start_time = after_start
        after.end_time = after_end
        after.style = 'after-' .. after.style
        after.text = after.text:gsub("{[^}]+}", "")
        text = ''
        for char in after.text:gmatch('.') do
            text = text .. [[{\k0}]] .. char
        end
        after.text = text

        table.insert(new_subs, b4)
        table.insert(new_subs, original_line)
        table.insert(new_subs, after)
    end
    subs.deleterange(sel_start, sel_end)
    subs.insert(sel_start, table.unpack(new_subs))
    aegisub.set_undo_point('insert_b4_after')
end

aegisub.register_macro(script_name, script_description, insert_b4_after)