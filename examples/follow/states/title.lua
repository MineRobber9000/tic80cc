local change_state, set_difficulty
--# bundle "utils"
local utils = require("utils")

function confirm_delete()
    if btnp(2) then
        for i=0,3 do pmem(i,0) end
        change_state("title")
    end
    if btnp(3) then
        change_state("title")
    end
    
    cls(13)
    utils.printc("ARE YOU SURE YOU",8,0)
    utils.printc("WISH TO WIPE HIGH SCORES?",16,0)
    utils.quad(120-16,136//2-32,2,q==0 and t>0)
    utils.quad(120-34,136//2-16,9,q==2 and t>0)
    utils.printc("YES",136//2-3,12,102/240)
    utils.quad(120-16,136//2,6,q==1 and t>0)
    utils.quad(120+2,136//2-16,4,q==3 and t>0)
    utils.printc("NO",136//2-3,12,138/240)
end

function title()
    if btn(4) and btn(5) then change_state("confirm_delete") end
    if btnp(0) then
        set_difficulty(1,20*60,60)
        change_state("show_it")
    end
    if btnp(2) then
        set_difficulty(0,15*60,30)
        change_state("show_it")
    end
    if btnp(1) then
        set_difficulty(2,10*60,15)
        change_state("show_it")
    end
    if btnp(3) then
        set_difficulty(3,120*60,0)
        change_state("show_it")
    end
    
    
    
    cls(13)
    spr(256,240//2-74//2,8,12,1,0,0,10,2) -- FOLLOW
    utils.quad(120-16,136//2-32,2,q==0 and t>0)
    utils.quad(120-34,136//2-16,9,q==2 and t>0)
    utils.quad(120-16,136//2,6,q==1 and t>0)
    utils.quad(120+2,136//2-16,4,q==3 and t>0)
    if (time()%4000)<2000 then
        utils.printc("EASY",136//2-19,12)
        utils.printc("MEH",136//2-3,12,102/240)
        utils.printc("HARD",136//2+13,12)
        utils.printc("2MIN",136//2-3,12,138/240)
    else
        utils.printc(pmem(1),136//2-19,12)
        utils.printc(pmem(0),136//2-3,12,102/240)
        utils.printc(pmem(2),136//2+13,12)
        utils.printc(pmem(3),136//2-3,12,138/240)
    end
    spr(288,240//2-120//2,136-24,12,1,0,0,15,1) -- A PATTERN-MATCHING
    spr(304,240//2-28//2,136-16,12,1,0,0,4,1) -- GAME
end

return function(states,_cs,funcs)
	states.title=title
	states.confirm_delete=confirm_delete
	change_state=_cs
	set_difficulty=funcs.set_difficulty
end
