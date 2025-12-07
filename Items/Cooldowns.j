function Trig_Cooldowns_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() != 'A035' ) ) then
        return false
    endif
    if ( not ( GetSpellAbilityId() != 'A031' ) ) then
        return false
    endif
    if ( not ( GetSpellAbilityId() != 'ANss' ) ) then
        return false
    endif
    if ( not ( GetSpellAbilityId() != 'A02D' ) ) then
        return false
    endif
    if ( not ( GetSpellAbilityId() != 'A0DK' ) ) then
        return false
    endif
    if ( not ( GetSpellAbilityId() != 'A02U' ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Func009C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A0AE' ) ) then
        return false
    endif
    if ( not ( GetUnitTypeId(GetTriggerUnit()) != 'O00N' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Func011C takes nothing returns boolean
    if ( not ( udg_CooldownRemaining < 1.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Cooldowns_Actions takes nothing returns nothing
    set udg_Temp_Unit_CD = GetTriggerUnit()
    if ( Trig_Cooldowns_Func009C() ) then
        call BlzStartUnitAbilityCooldown( udg_Temp_Unit_CD, GetSpellAbilityId(), 1.00 )
        return
    endif
    if (GetSpellAbilityId() == 'A03J') then
        if udg_Temp_Unit_CD == udg_yA_Unholy_DK and udg_Unholy_DK_Reset_A then
            set udg_Unholy_DK_Reset_A = false
            call BlzEndUnitAbilityCooldown( udg_Temp_Unit_CD, 'A03J' )
            return
        elseif udg_Temp_Unit_CD == udg_yH_Unholy_DK and udg_Unholy_DK_Reset_H then
            set udg_Unholy_DK_Reset_H = false
            call BlzEndUnitAbilityCooldown( udg_Temp_Unit_CD, 'A03J' )
            return
        endif
    endif
    call TriggerExecute( gg_trg_Cooldown_Maths) 
    if ( Trig_Cooldowns_Func011C() ) then
        call BlzStartUnitAbilityCooldown( udg_Temp_Unit_CD, GetSpellAbilityId(), ( udg_CooldownRemaining * BlzGetUnitAbilityCooldownRemaining(GetTriggerUnit(), GetSpellAbilityId()) ) )
    endif
endfunction

//===========================================================================
function InitTrig_Cooldowns takes nothing returns nothing
    set gg_trg_Cooldowns = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Cooldowns, EVENT_PLAYER_UNIT_SPELL_ENDCAST )
    call TriggerAddCondition( gg_trg_Cooldowns, Condition( function Trig_Cooldowns_Conditions ) )
    call TriggerAddAction( gg_trg_Cooldowns, function Trig_Cooldowns_Actions )
endfunction

