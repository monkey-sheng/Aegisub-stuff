local tr = aegisub.gettext


function hello_world()
    return 'hello world'
end

function modify_syl_text(syl)
    local original = syl.text
    syl.text = 'hello from modify syl text'
    return syl.text
end

function return_exact(x)
    return x
end

-- _G.hello_world = hello_world
_G['hello_world'] = hello_world
_G['modify_syl_text'] = modify_syl_text
-- include('hello_world_include.lua')
--require('kara-templater')