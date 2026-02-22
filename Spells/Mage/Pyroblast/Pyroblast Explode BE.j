function Trig_Pyroblast_Explode_BE_Conditions takes nothing returns boolean
    if ( GetTriggerUnit() == udg_SpellUnits[ udg_z_MA_FIRE_H ]  ) then
        return true
    endif
    return false
endfunction

function Trig_Pyroblast_Explode_BE_Actions takes nothing returns nothing
    local location explodeLoc
    local integer lvl
    local integer baseInt
    local integer bonusInt
    local effect explosion
    local real lvlfactor = 0.00
    

    call DisableTrigger( gg_trg_Pyroblast_Move_BE )
    call DisableTrigger( GetTriggeringTrigger() )
    set gg_Pyroblast_Caster = udg_yH_Fire_Mage

    set udg_Temp_Unit = gg_Pyroblast_Caster
    call TriggerExecute( gg_trg_Firelords_Helper_Keep_Temp)

    set lvl = GetUnitAbilityLevelSwapped('A0H2', gg_Pyroblast_Caster)
    if ( lvl >= 2 ) then
        set lvlfactor = 1.5 *(lvl - 1)
    endif
    set gg_Pyroblast_Dmg = 120 + (lvl * 120) + ( GetTotalInt( gg_Pyroblast_Caster ) * (7 + lvlfactor))
    set gg_Pyroblast_Dmg = gg_Pyroblast_Dmg * 0.5//Set to 50% because most of the damage is the AoE

    call Debug("Pyroblast Explode Triggered on Target: " + GetUnitName(GetTriggerUnit()) + " Caster: " + GetUnitName(gg_Pyroblast_Caster) )

    set explodeLoc = GetUnitLoc(udg_SpellUnits[ udg_z_MA_FIRE_H ] )
    set explosion =  AddSpecialEffectLoc("war3mapImported\\Pyroblast.mdx", explodeLoc)
    call BlzSetSpecialEffectZ ( explosion, BlzGetLocalSpecialEffectZ(explosion) + 100.00 )
    call DestroyEffectBJ( explosion )
    
    set bj_wantDestroyGroup = true
    call ForGroupBJ( GetUnitsInRangeOfLocAll(310.00, explodeLoc), function Pyroblast_Explode_BE_GroupDamage )
    call RemoveLocation (explodeLoc)

    call SetUnitOwner( gg_unit_e01Q_0089, Player(PLAYER_NEUTRAL_PASSIVE), true )
    set explodeLoc = GetRectCenter(gg_rct_DummyIsland)
    call SetUnitPositionLoc( gg_unit_e01Q_0089, explodeLoc )
    call RemoveLocation (explodeLoc)


    set explodeLoc = null
    set explosion = null
endfunction

//===========================================================================
function InitTrig_Pyroblast_Explode_BE takes nothing returns nothing
    set gg_trg_Pyroblast_Explode_BE = CreateTrigger(  )
    call DisableTrigger( gg_trg_Pyroblast_Explode_BE )
    call TriggerRegisterUnitInRangeSimple( gg_trg_Pyroblast_Explode_BE, 45.00, gg_unit_e01Q_0089 )
    call TriggerAddCondition( gg_trg_Pyroblast_Explode_BE, Condition( function Trig_Pyroblast_Explode_BE_Conditions ) )
    call TriggerAddAction( gg_trg_Pyroblast_Explode_BE, function Trig_Pyroblast_Explode_BE_Actions )
endfunction

