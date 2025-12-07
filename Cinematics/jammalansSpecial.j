function IsAShroom takes destructable d returns boolean
    if ( GetDestructableTypeId(d) == 'B00N' ) then
        return true
    endif
    return false
endfunction

function IsAShroomEnum takes nothing returns boolean
    return IsAShroom(GetEnumDestructable())
endfunction

function ReviveMushroomCircle takes nothing returns nothing
    if IsAShroom(GetEnumDestructable()) then
        call DestructableRestoreLife( GetEnumDestructable(), 50, false )
    endif
endfunction

function KillMushroomCircle takes nothing returns nothing
    if IsAShroom(GetEnumDestructable()) then
        call KillDestructable( GetEnumDestructable() )
    endif
endfunction


//Periodic Trigger Portion
//===========================================================================

function Trig_C_JC_Actions takes nothing returns nothing
    local location point
    local effect eff
    local destructable destr
    // local location offset = PolarProjectionBJ(center, GetRandomReal(20, 160.0), GetRandomReal(0, 360.0))
    local integer r = GetRandomInt(1,4)
    
    // call EnumDestructablesInRectAll( gg_rct_Jammalans_Cauldron, function ReviveMushroomCircle )

    // set destr = RandomDestructableInRectBJ(gg_rct_Jammalans_Cauldron, Condition(function IsAShroomEnum))

    set point = GetRandomLocInRect(gg_rct_Jammalans_Cauldron)
    
    if r == 1 then
        call CreateItemLoc('I04B', point) // Diseased Frog Leg
    elseif r == 2 then
        call CreateItemLoc('I017', point) // Turkey Leg
    elseif r == 3 then
        call CreateItemLoc('I06F', point) // Shimmering Minnow
    else 
        call CreateItemLoc('phea', point) // Potion of Healing
    endif
 
    // call EnumDestructablesInRectAll( gg_rct_Jammalans_Cauldron, function KillMushroomCircle )
    
    //Meat Explostion
    call AddSpecialEffectLocBJ( point, "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl" )
    set eff = GetLastCreatedEffectBJ()
    call BlzSetSpecialEffectScale(eff, GetRandomReal(1.0, 1.25))
    call BlzSetSpecialEffectYaw( eff, Deg2Rad(GetRandomReal(0, 360.0)) )
    call DestroyEffectBJ( eff )
    call RemoveLocation (point)

    //Turn off
    if(GetTriggerExecCount(gg_trg_C_JC) > 7) then 
        call DestroyEffectBJ( udg_QuestMarks[129] )
        call DisableTrigger(gg_trg_C_JC)
    endif

    set point = null
    set eff = null
    set destr = null
endfunction

//===========================================================================
function InitTrig_C_JC takes nothing returns nothing
    set gg_trg_C_JC = CreateTrigger(  )
    call DisableTrigger( gg_trg_C_JC )
    call TriggerRegisterTimerEventPeriodic( gg_trg_C_JC, 0.12 )
    call TriggerAddAction( gg_trg_C_JC, function Trig_C_JC_Actions )
endfunction