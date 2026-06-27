function Trig_Cooldown_Maths_Func002Func002Func001Func001Func001Func001C takes nothing returns boolean
    if ( not ( udg_ItemTypeCheck == 'I0AO' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Func002Func002Func001Func001Func001C takes nothing returns boolean
    if ( not ( udg_ItemTypeCheck == 'I0AN' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Func002Func002Func001Func001C takes nothing returns boolean
    if ( not ( udg_ItemTypeCheck == 'I0AM' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Func002Func002Func001C takes nothing returns boolean
    if ( not ( udg_ItemTypeCheck == 'I0AL' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Func002Func002Func002C takes nothing returns boolean
    if ( ( udg_ItemTypeCheck == 'I06V' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I06U' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I06W' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I05Y' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I03F' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I084' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I086' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I06M' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I087' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I071' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I05I' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I075' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I01N' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I023' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I073' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I074' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I07P' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I07O' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I08Q' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I08Y' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I073' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I0AE' ) ) then
        return true
    endif
    if ( ( udg_ItemTypeCheck == 'I0AP' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Cooldown_Maths_Func002Func002C takes nothing returns boolean
    if ( not Trig_Cooldown_Maths_Func002Func002Func002C() ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Func003C takes nothing returns boolean
    if ( not ( udg_CooldownRemaining < 0.70 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldown_Maths_Actions takes nothing returns nothing
    set udg_CooldownRemaining = 1.00
    set udg_Bag_Iterator = 1
    loop
        exitwhen udg_Bag_Iterator > 6
        set udg_ItemTypeCheck = GetItemTypeId(UnitItemInSlotBJ(udg_Temp_Unit_CD, udg_Bag_Iterator))
        if ( Trig_Cooldown_Maths_Func002Func002C() ) then
            set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.10 )
        else
            if ( Trig_Cooldown_Maths_Func002Func002Func001C() ) then
                set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.02 )
            else
                if ( Trig_Cooldown_Maths_Func002Func002Func001Func001C() ) then
                    set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.04 )
                else
                    if ( Trig_Cooldown_Maths_Func002Func002Func001Func001Func001C() ) then
                        set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.06 )
                    else
                        if ( Trig_Cooldown_Maths_Func002Func002Func001Func001Func001Func001C() ) then
                            set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.08 )
                        else
                        endif
                    endif
                endif
            endif
        endif
        set udg_Bag_Iterator = udg_Bag_Iterator + 1
    endloop
    if ( Trig_Cooldown_Maths_Func003C() ) then
        set udg_CooldownRemaining = 0.70
    else
    endif
endfunction

//===========================================================================
function InitTrig_Cooldown_Maths takes nothing returns nothing
    set gg_trg_Cooldown_Maths = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Cooldown_Maths, function Trig_Cooldown_Maths_Actions )
endfunction

