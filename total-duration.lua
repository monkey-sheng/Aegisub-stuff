script_name = "总轴时长"
script_description = "把每行轴时长相加"
script_author = "monkey_sheng"
script_version = "0.1"

local function total_time(sub_table, selected_lines_i, active_line_i)
    local total_sub_time = 0
    for i = 1, #sub_table do
        line = sub_table[i]
        if line.class == "dialogue" then
            total_sub_time = total_sub_time + line.end_time - line.start_time
        end
    end
    aegisub.log("总轴时长：\n%s s", total_sub_time / 1000)
end

aegisub.register_macro(script_name, script_description, total_time)