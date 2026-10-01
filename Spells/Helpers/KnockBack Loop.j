function KnockBackTick takes nothing returns nothing
    local integer i
    local unit u
    local integer id
    local real angle
    local real distance
    local real step
    local real arc
    local real x
    local real y
    local real nx
    local real ny
    call KnockBackAbsorbGroup()
    set i = KnockBackCount
    loop
        exitwhen i < 1
        set u = KnockBackUnits[i]
        if u == null or GetUnitTypeId(u) == 0 or BlzIsUnitInvulnerable(u) then
            call KnockBackDrop(i)
        else
            set id = GetHandleId(u)
            set angle = LoadReal(udg_KnockBacksHash, id, 0)
            set distance = LoadReal(udg_KnockBacksHash, id, 3)
            set x = GetUnitX(u)
            set y = GetUnitY(u)
            set nx = x + distance * Cos(angle * bj_DEGTORAD)
            set ny = y + distance * Sin(angle * bj_DEGTORAD)
            if LoadBoolean(udg_KnockBacksHash, id, 4) then
                call SetUnitX(u, nx)
                call SetUnitY(u, ny)
            elseif not IsTerrainPathable(nx, ny, PATHING_TYPE_WALKABILITY) then
                call SetUnitPosition(u, nx, ny)
            endif
            set step = LoadReal(udg_KnockBacksHash, id, 1) + 1.00
            set arc = 1.00 - (step / 8.00)
            if arc > 1.00 then
                set arc = 1.00
            elseif arc < -1.00 then
                set arc = -1.00
            endif
            call SetUnitFlyHeight(u, LoadReal(udg_KnockBacksHash, id, 2) * Sin(Acos(arc)), 0.00)
            if step >= 16.00 then
                call KnockBackDrop(i)
            else
                call SaveReal(udg_KnockBacksHash, id, 1, step)
            endif
        endif
        set i = i - 1
    endloop
    call KnockBackRebuildGroup()
    if KnockBackCount == 0 then
        call Debug("Knockbacks Is Empty")
        call DisableTrigger(gg_trg_KnockBackLoop)
    endif
    set u = null
endfunction

function Trig_KnockBackLoop_Actions takes nothing returns nothing
    call KnockBackTick()
endfunction

function InitTrig_KnockBackLoop takes nothing returns nothing
    set gg_trg_KnockBackLoop = CreateTrigger()
    call DisableTrigger(gg_trg_KnockBackLoop)
    call TriggerRegisterTimerEventPeriodic(gg_trg_KnockBackLoop, 0.02)
    call TriggerAddAction(gg_trg_KnockBackLoop, function Trig_KnockBackLoop_Actions)
endfunction