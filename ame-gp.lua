-- png jumping downwards

-- code once
PNG_PRE = [[{\bord0\shad0}{\1img(c:/users/jason/desktop/ame-jump-pre.png)}%s{\p1}m 0 0 l 0 95 l 95 95 l 95 0 {\p0}]];
PNG_POST = [[{\bord0\shad0}{\1img(c:/users/jason/desktop/ame-jump-post.png)}%s{\p1}m 0 0 l 0 95 l 95 95 l 95 0 {\p0}]];
CTRL_PT_Y = 100; JUMP_X_OFFSET = 60; JUMP_TIME_OFFSET = 250; FINAL_JUMP_DURATION = 550;
CTRL_PT_Y_PER_TIME = 0.2;  -- 500ms -> 100(px) CTRL_PT_Y
CTRL_PT_Y_MAX = 300; CTRL_PT_Y_MIN = 100;

--next_syl = syl.line.kara[syl.i+1]; if syl.i==1 then prev_syl = nil else prev_syl = syl.line.kara[syl.i-1] end
function next_syl(syl) return syl.line.kara[syl.i+1] end
function prev_syl(syl) local prev_syl; if syl.i==1 then prev_syl = nil else prev_syl = syl.line.kara[syl.i-1] end return prev_syl end

-- will be called in template syl notext, returns tags that moves png from previous syl center top to current syl center top in parabola
-- take care of the first and last one
function jump(syl)
    local start_jump_x, start_jump_y, end_jump_x, end_jump_y, control_point_x, control_point_y;
    local other_tags = "";
    local moves3_tag = [[{\moves3(%d,%d,%d,%d,%d,%d)}]];

    -- first jump: zoom in with {\fsc0\t(0,150,\fsc100)} tag
    -- last jump: use PNG_PRE, and jumps off when j == 3
    -- normal jump: split into 2 cases
    -- normal jump case:
        -- if j == 1: use PNG_PRE and retime for syl start to syl middle
        -- if j == 2: use PNG_POST and only make it appear during syl middle to syl end

    --control_point_y = syl.line.top - CTRL_PT_Y;

    if (prev_syl(syl) == nil) then
        other_tags = [[{\fsc0\t(0,150,\fsc95)}]];
        start_jump_x = syl.line.left - JUMP_X_OFFSET; start_jump_y = syl.line.top;
        end_jump_x = syl.center + syl.line.left; end_jump_y = syl.line.top;
        control_point_x = math.floor((start_jump_x + end_jump_x) / 2);
        control_point_y = syl.line.top - math.min(CTRL_PT_Y_MAX, math.max(CTRL_PT_Y_MIN, CTRL_PT_Y_PER_TIME * syl.duration));
        retime("syl", 0, 0);
        return other_tags .. string.format(PNG_POST,"") .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
    elseif (next_syl(syl) == nil) and (j == 3) then
        start_jump_x = syl.center + syl.line.left; start_jump_y = syl.line.top;
        end_jump_x = syl.line.right + JUMP_X_OFFSET; end_jump_y = 1200;
        control_point_x = math.floor((start_jump_x + end_jump_x) / 2); control_point_y = syl.line.top - CTRL_PT_Y;
        retime("postsyl", 0, FINAL_JUMP_DURATION);
        return string.format(PNG_PRE,"") .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
    else
        if (j == 1) then
            start_jump_x = prev_syl(syl).center + prev_syl(syl).line.left; start_jump_y = prev_syl(syl).line.top;
            end_jump_x = syl.center + syl.line.left; end_jump_y = syl.line.top;
            control_point_x = math.floor((start_jump_x + end_jump_x) / 2);
            control_point_y = syl.line.top - math.min(CTRL_PT_Y_MAX, math.max(CTRL_PT_Y_MIN, CTRL_PT_Y_PER_TIME * syl.duration));
            local appear_syl_start_to_mid_tag = string.format([[{\t(%d,%d,\alpha&ff)}]], math.floor(syl.duration / 2), math.floor(syl.duration / 2))
            --retime("syl", 0, - math.floor(syl.duration / 2));
            retime("syl", 0, 0);
            return string.format(PNG_PRE, appear_syl_start_to_mid_tag) .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
        elseif (j == 2) then
            start_jump_x = prev_syl(syl).center + prev_syl(syl).line.left; start_jump_y = prev_syl(syl).line.top;
            end_jump_x = syl.center + syl.line.left; end_jump_y = syl.line.top;
            control_point_x = math.floor((start_jump_x + end_jump_x) / 2);
            control_point_y = syl.line.top - math.min(CTRL_PT_Y_MAX, math.max(CTRL_PT_Y_MIN, CTRL_PT_Y_PER_TIME * syl.duration));
            local appear_syl_mid_to_end_tag = string.format([[{\alpha&ff\t(%d,%d,\alpha&00)}]], math.floor(syl.duration / 2), math.floor(syl.duration / 2))
            retime("syl", 0, 0);
            return string.format(PNG_POST, appear_syl_mid_to_end_tag) .. string.format(moves3_tag, start_jump_x,start_jump_y,control_point_x,control_point_y,end_jump_x,end_jump_y);
        end
    end
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

-- sort of a wrapper around the actual jump, but for normal jump `maxloop(2)` and for last jump `maxloop(3)`, will need to be set up
-- loop 2 for normal jump because using 2 different PNGs, for last jump because jumping normal as well as jumping off screen
function do_jump(syl)
    if (prev_syl(syl) == nil) then
        return jump(syl)
    elseif (next_syl(syl) == nil) then
        maxloop(3); return jump(syl);
    else
        maxloop(2); return jump(syl);
    end
end

-- shatter effect using clip
-- code once const
-- discount factor: the further the piece is from impact point, the shorter it flies
SHATTER_PIECE_SIZE = 10; SHATTER_DISTANCE = 120; SHATTER_DURATION = 400;
DISTANCE_DISCOUNT_FACTOR = 0.7;

-- the number of loops for shattered pieces depends on the shatter size defined above
-- move clip using \t, movement vector computed from (pseudo) point of impact
function shatter_syl(syl)
    local function normalise(x, y)
        local norm_factor = math.sqrt(math.pow(x,2)+math.pow(y,2));
        return x / norm_factor, y / norm_factor;
    end
    local column_count = math.ceil(syl.width / SHATTER_PIECE_SIZE);
    local row_count = math.ceil(syl.height / SHATTER_PIECE_SIZE);
    local total_pieces = column_count * row_count;
    maxloop(total_pieces);
    local row = math.floor((j-1) / column_count); local column = (j-1) % column_count;
    local syl_left_x = syl.line.left + syl.left; local syl_bottom_y = syl.line.bottom;
    local syl_cneter_x = syl.line.left + syl.center;
    local clip_left_x = column * SHATTER_PIECE_SIZE + syl_left_x;
    local clip_top_y = row * SHATTER_PIECE_SIZE + syl.line.top;
    local clip_right_x = clip_left_x + SHATTER_PIECE_SIZE;
    local clip_bottom_y = clip_top_y + SHATTER_PIECE_SIZE;
    local clip_center_x = clip_left_x + math.floor(SHATTER_PIECE_SIZE / 2);
    local clip_center_y = clip_top_y + math.floor(SHATTER_PIECE_SIZE / 2);
    local impact_x = syl.center + syl.line.left; local impact_y = syl.line.top;
    local direction_vector_x, direction_vector_y = normalise((clip_center_x - impact_x), (clip_center_y - impact_y));
    local movement_x = direction_vector_x * SHATTER_DISTANCE; local movement_y = direction_vector_y * SHATTER_DISTANCE;
    local clip_end_left_x = math.floor(movement_x + clip_left_x);
    local clip_end_top_y = math.floor(movement_y + clip_top_y);
    local clip_end_right_x = clip_end_left_x + SHATTER_PIECE_SIZE;
    local clip_end_bottom_y = clip_end_top_y + SHATTER_PIECE_SIZE;
    local syl_end_center_x = syl_cneter_x + movement_x; local syl_end_bottom_y = syl_bottom_y + movement_y;
    retime("postsyl", 0, SHATTER_DURATION);
    local clip_tag = [[{\clip(%d,%d,%d,%d)\t(\clip(%d,%d,%d,%d))}{\move(%d,%d,%d,%d)}]]
    return string.format(clip_tag, clip_left_x, clip_top_y, clip_right_x, clip_bottom_y, clip_end_left_x, clip_end_top_y, clip_end_right_x, clip_end_bottom_y, syl_cneter_x, syl_bottom_y, syl_end_center_x, syl_end_bottom_y);
end