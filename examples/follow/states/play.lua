local q=0
local t=0

local seq={0}
local seq_i=1
local show=true
local frames_per_note=30
local timer=15*60
local score=0
local difficulty=0

--# bundle "utils"
local utils = require("utils")

local change_state

local function format_timer()
    local seconds=timer/60
    return ("%02d:%02d"):format(math.floor(seconds/60),math.floor(seconds)%60)
end

local function gen_sequence()
    seq[#seq+1]=math.random(0,3)
    seq_i=1
    show=true
    change_state("show_it")
    timer=timer+(#seq*frames_per_note)
    score=score+1
end

local notes={[0]="C-4","E-4","G-4","B-4"}
local function press_button(n)
    q=n
    t=30
    if not show then
        if seq[seq_i]==n then
            seq_i=seq_i+1
            if seq_i>#seq then
                -- GENERATE NEW SEQUENCE
                gen_sequence()
            end
        else
            sfx(1,"C-2")
            q=seq[seq_i]
            seq_i=1
            timer=timer-(5*60)
            return
        end
    end
    sfx(0,notes[n])
end

function play()

    if btnp(0) then press_button(0) end
    if btnp(1) then press_button(1) end
    if btnp(2) then press_button(2) end
    if btnp(3) then press_button(3) end
    if t>0 then t=t-1 end
    if timer>0 then timer=timer-1 else change_state("game_over") timer=0 end

    cls(13)
    utils.quad(120-16,136//2-32,2,q==0 and t>0)
    utils.quad(120-34,136//2-16,9,q==2 and t>0)
    utils.quad(120-16,136//2,6,q==1 and t>0)
    utils.quad(120+2,136//2-16,4,q==3 and t>0)
    utils.printc("SCORE:",136//2-8,12,1/8)
    utils.printc(score,136//2,12,1/8)
    utils.printc("TIMER:",136//2-8,12,7/8)
    utils.printc(format_timer(),136//2,12,7/8)

end

local showt=0
function show_it()

    if showt==0 then
        if seq_i>#seq then
            show=false
            seq_i=1
            change_state("play")
            showt=30
        else
            if seq[seq_i]==0 then press_button(0) end
            if seq[seq_i]==1 then press_button(1) end
            if seq[seq_i]==2 then press_button(2) end
            if seq[seq_i]==3 then press_button(3) end
            seq_i=seq_i+1
            showt=59
        end
    else
        showt=showt-1
    end
    if t>0 then t=t-1 end

    cls(13)
    utils.quad(120-16,136//2-32,2,q==0 and t>0)
    utils.quad(120-34,136//2-16,9,q==2 and t>0)
    utils.quad(120-16,136//2,6,q==1 and t>0)
    utils.quad(120+2,136//2-16,4,q==3 and t>0)
    utils.printc("SCORE:",136//2-8,12,1/8)
    utils.printc(score,136//2,12,1/8)
    utils.printc("TIMER:",136//2-8,12,7/8)
    if (time()%1000)<500 then utils.printc(format_timer(),136//2,12,7/8) end

end

local first=false
local high_score=0
local set_high_score=false
local take_it=false
function game_over()
    if not first then
        high_score=pmem(difficulty)
        if score>high_score then pmem(difficulty,score) high_score=score set_high_score=true end
    end
    t=0
    cls(13)
    utils.quad(120-16,136//2-32,2,q==0 and t>0)
    utils.quad(120-34,136//2-16,9,q==2 and t>0)
    utils.quad(120-16,136//2,6,q==1 and t>0)
    utils.quad(120+2,136//2-16,4,q==3 and t>0)
    utils.printc("SCORE:",136//2-8,12,1/8)
    utils.printc(score,136//2,12,1/8)
    utils.printc("TIMER:",136//2-8,12,7/8)
    utils.printc(format_timer(),136//2,12,7/8)
    utils.printc("HIGH SCORE:",8,12)
    utils.printc(high_score,16,12)
    if set_high_score then
        if (time()%1000)<500 then utils.printc("NEW HIGH SCORE",136-24,12) end
    end
    utils.printc("PRESS ANY BUTTON TO RESET",136-16,12)
    if not take_it then
        if btn()==0 then take_it=true end
    else
        if btn()>0 then reset() end
    end
end

return function(states,_cs,funcs)
	states.game_over=game_over
	states.show_it=show_it
	states.play=play
	change_state=_cs
	funcs.set_difficulty=function(d,t,fpn)
		difficulty=d
		timer=t
		frames_per_note=fpn
	end
end
