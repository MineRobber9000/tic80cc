local utils = {}
function utils.quad(x,y,c,spot)
    poke4(0x3ff0*2+1,c or 1)
    spr(1,x,y,0,2)
    spr(1,x+16,y,0,2,1)
    spr(1,x,y+16,0,2,2)
    spr(1,x+16,y+16,0,2,3)
    if spot then spr(2,x+8,y+8,0,2) end
end

function utils.printc(s,y,c,m)
    m=m or .5
    local _w=print(s,0,-6)
    print(s,(240*m)-(_w//2),y,c)
end

return utils
