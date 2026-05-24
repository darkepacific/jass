function IsTenPercentItem takes nothing returns boolean
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
    return false
endfunction

function Trig_Cooldowns_Math_SoulstonePercent takes nothing returns real
    if ( udg_ItemTypeCheck == 'I0AL' ) then
        return 0.02
    endif
    if ( udg_ItemTypeCheck == 'I0AM' ) then
        return 0.04
    endif
    if ( udg_ItemTypeCheck == 'I0AN' ) then
        return 0.06
    endif
    if ( udg_ItemTypeCheck == 'I0AO' ) then
        return 0.08
    endif
    if ( udg_ItemTypeCheck == 'I0AP' ) then
        return 0.10
    endif
    return 0
endfunction

function Trig_Cooldowns_Math_Actions takes nothing returns nothing
    local integer inventoryIndex = 1

    set udg_CooldownRemaining = 1.00
    
    loop
        exitwhen inventoryIndex > 6
        set udg_ItemTypeCheck = GetItemTypeId(UnitItemInSlotBJ(udg_Temp_Unit_CD, inventoryIndex))

        if ( IsTenPercentItem() ) then
            set udg_CooldownRemaining = ( udg_CooldownRemaining - 0.10 )
        else
            set udg_CooldownRemaining = ( udg_CooldownRemaining - Trig_Cooldowns_Math_SoulstonePercent() )
        endif
        set inventoryIndex = inventoryIndex + 1

        if (udg_CooldownRemaining < 0.70) then
            set udg_CooldownRemaining = 0.70
            exitwhen true
        endif
    endloop
    
endfunction

// DIVERGENT THIS FUNCTION/TRIGGER IS NOT ACTUALLY USED, STILL USING GUI ONE IN GAME

//===========================================================================
function InitTrig_Cooldown_Maths takes nothing returns nothing
    set gg_trg_Cooldown_Maths = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Cooldown_Maths, function Trig_Cooldowns_Math_Actions )
endfunction

