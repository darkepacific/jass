function Trig_Frozen_Orb_Loop takes nothing returns nothing
    local unit u = GetEnumUnit()
    if ( IsUnitTargetableEnemy(u, udg_Temp_Unit) and not( UnitHasBuffBJ(u, 'B01M') ) ) then
        call IssueTargetOrderBJ( gg_unit_e028_1863, "slow", u )
        call AddSpecialEffectTargetUnitBJ( "origin", u, "war3mapImported\\Blizzard II Missile" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call UnitDamageTargetBJ( udg_Temp_Unit, u, udg_RealStatCalc, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
	call HasFirelords( u )
    endif
    set u = null
endfunction

function Frozen_Orb_Dmg takes nothing returns nothing
    call TriggerExecute( gg_trg_Firelords_Helper)

    call SetUnitOwner( gg_unit_e028_1863, GetOwningPlayer(udg_Temp_Unit), true )
    //call SetUnitAbilityLevelSwapped( 'A03P', gg_unit_e028_1863, 1 )
    
    // SE
    set udg_Temp_Unit_Point = GetUnitLoc(udg_SpellUnits[ udg_o ])
    call AddSpecialEffectLocBJ( udg_Temp_Unit_Point, "war3mapImported\\RemorselessWinter.mdx" )
    call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.8)
    call DestroyEffect(GetLastCreatedEffectBJ())
    
    // AoE
    
    set bj_wantDestroyGroup = true
    call ForGroupBJ( GetUnitsInRangeOfLocAll(250.00, udg_Temp_Unit_Point), function Trig_Frozen_Orb_Loop )
    call RemoveLocation (udg_Temp_Unit_Point)
endfunction