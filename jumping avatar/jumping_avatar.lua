-- png jumping downwards

-- code once
PNG = [[{\bord0\shad0}{\1img(c:/users/jason/desktop/mira.png)}{\p1}m 0 0 l 0 74 l 80 74 l 80 0 {\p0}]];
CTRL_PT_Y = 100; JUMP_X_OFFSET = 60; JUMP_TIME_OFFSET = 250; FINAL_JUMP_DURATION = 550;

--next_syl = syl.line.kara[syl.i+1]; if syl.i==1 then prev_syl = nil else prev_syl = syl.line.kara[syl.i-1] end
function next_syl(syl) return syl.line.kara[syl.i+1] end
function prev_syl(syl) local prev_syl; if syl.i==1 then prev_syl = nil else prev_syl = syl.line.kara[syl.i-1] end return prev_syl end

-- will be called in template syl notext, returns tags that moves png from previous syl center top to current syl center top in parabola
-- take care of the first and last one
function jump(syl) 
    local start_jump_x, start_jump_y, end_jump_x, end_jump_y, control_point_x, control_point_y, start_jump_time, end_jump_time;
    local other_tags = "";
    local moves3_tag = [[{\moves3(%d,%d,%d,%d,%d,%d)}]];
    if (prev_syl(syl) == nil) then 
        -- the first jump
        other_tags = [[{\fsc0\t(0,150,\fsc100)}]];
        start_jump_x = syl.line.left - JUMP_X_OFFSET; start_jump_y = syl.line.top;
        end_jump_x = syl.center + syl.line.left; end_jump_y = syl.line.top;
        control_point_x = math.floor((start_jump_x + end_jump_x) / 2); control_point_y = syl.line.top - CTRL_PT_Y;
        start_jump_time = syl.start_time; end_jump_time = 0; --end_jump_time = syl.end_time;
    elseif (next_syl(syl) == nil) and (j == 2) then 
        -- last jump
        start_jump_x = syl.center + syl.line.left; start_jump_y = syl.line.top;
        end_jump_x = syl.line.right + JUMP_X_OFFSET; end_jump_y = 1130;
        control_point_x = math.floor((start_jump_x + end_jump_x) / 2); control_point_y = syl.line.top - CTRL_PT_Y;
        start_jump_time = syl.end_time; end_jump_time = FINAL_JUMP_DURATION; --end_jump_time = start_jump_time + FINAL_JUMP_DURATION;
        retime("postsyl", 0, FINAL_JUMP_DURATION);
        return PNG .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
    else 
        -- normal jump
        start_jump_x = prev_syl(syl).center + prev_syl(syl).line.left; start_jump_y = prev_syl(syl).line.top;
        end_jump_x = syl.center + syl.line.left; end_jump_y = syl.line.top;
        control_point_x = math.floor((start_jump_x + end_jump_x) / 2); control_point_y = syl.line.top - CTRL_PT_Y;
        start_jump_time = prev_syl(syl).end_time; end_jump_time = 0; --end_jump_time = syl.end_time;
    end 
    retime("syl", 0, end_jump_time);
    return other_tags .. PNG .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
end

-- call once
function call_once(func)
    local called = false;
    local function check(...) if called then return "" else called = true; return func(...) end end
    return check
end

-- usage:
    -- retime_once = call_once(retime, ...)
    -- retime_once needs to be reset according every line in this case
    -- so add a code line: retime_once = call_once(retime, ...)