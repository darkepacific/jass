function Trig_Pyroblast_Start_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A0H2' 
endfunction

function Trig_Pyroblast_Start_Actions takes nothing returns nothing
    local location casterLoc
    local location polarLoc
    local location targetLoc
    local unit dummy
    local integer o 
    local unit caster = GetSpellAbilityUnit()
    
    if caster == null then
        return
    elseif caster == udg_yA_Fire_Mage then
        set o = udg_z_MA_FIRE_A
        set dummy = gg_unit_e01Q_1985
    elseif caster == udg_yH_Fire_Mage then
        set o = udg_z_MA_FIRE_H
        set dummy = gg_unit_e01Q_0089   
    endif

    
    set udg_SpellUnits[ o ] = udg_SpellUnits[ o + 1] 
    call Debug ("Pyroblast Start Triggered Caster: " + GetUnitName(caster) + " Target: " + GetUnitName(udg_SpellUnits[ o ]))
    set casterLoc = GetUnitLoc(caster)
    set polarLoc = PolarProjectionBJ(casterLoc, 96.00, GetUnitFacing(caster))
    call SetUnitPositionLoc( dummy, polarLoc )
    call RemoveLocation (polarLoc)
    call RemoveLocation (casterLoc)

    if caster == udg_yA_Fire_Mage then
        call SetUnitOwner( dummy, Player(1), true )
    elseif caster == udg_yH_Fire_Mage then
        call SetUnitOwner( dummy, Player(0), true )
    endif
    set targetLoc = GetUnitLoc(udg_SpellUnits[ o ] )
    call IssuePointOrderLocBJ( dummy, "move", targetLoc )
    call RemoveLocation (targetLoc)

    if caster == udg_yA_Fire_Mage then
        call EnableTrigger( gg_trg_Pyroblast_Explode_HU )
        call EnableTrigger( gg_trg_Pyroblast_Move_HU )
    elseif caster == udg_yH_Fire_Mage then
        call EnableTrigger( gg_trg_Pyroblast_Explode_BE )
        call EnableTrigger( gg_trg_Pyroblast_Move_BE )
    endif


    call TriggerExecute( gg_trg_Cooldown_Maths)
    set udg_CooldownRemaining = ( udg_CooldownRemaining * 25.0 )
    call BlzStartUnitAbilityCooldown( caster, 'A0H2', udg_CooldownRemaining )

    set casterLoc = null
    set polarLoc = null
    set targetLoc = null
    set dummy = null
    set caster = null
endfunction

//===========================================================================
function InitTrig_Pyroblast_Start takes nothing returns nothing
    set gg_trg_Pyroblast_Start = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Pyroblast_Start, EVENT_PLAYER_UNIT_SPELL_FINISH ) //SPELL FINISH
    call TriggerAddCondition( gg_trg_Pyroblast_Start, Condition( function Trig_Pyroblast_Start_Conditions ) )
    call TriggerAddAction( gg_trg_Pyroblast_Start, function Trig_Pyroblast_Start_Actions )
endfunction

