function Trig_Virulent_Plague_Begin_Conditions takes nothing returns boolean
    return ( GetSpellAbilityId() == 'A03J' ) 
endfunction

function Trig_Virulent_Plague_Error_Msg takes nothing returns nothing
    call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
    call ErrorMessage( "No currently plagued targets.", GetOwningPlayer(GetTriggerUnit()) )
    call SetUnitManaBJ( GetTriggerUnit(), ( GetUnitStateSwap(UNIT_STATE_MANA, GetTriggerUnit()) + I2R(BlzGetAbilityManaCost('A03J', ( GetUnitAbilityLevelSwapped(GetSpellAbilityId(), GetTriggerUnit()) - 1 ))) ) )
endfunction

function Trig_Virulent_Plague_Begin_Actions takes nothing returns nothing
    if ( GetTriggerUnit() == udg_yA_Unholy_DK) then
        call SpellUnits_CleanMissingBuff( udg_z_DK_UNHO_A, 40, 63, 'B01K')
        if  SpellUnits_Count( udg_z_DK_UNHO_A, 40, 63) == 0 then
            call Trig_Virulent_Plague_Error_Msg()
        endif
    elseif ( GetTriggerUnit() == udg_yH_Unholy_DK) then
        call SpellUnits_CleanMissingBuff( udg_z_DK_UNHO_H, 40, 63, 'B039')
        if  SpellUnits_Count( udg_z_DK_UNHO_H, 40, 63) == 0 then
            call Trig_Virulent_Plague_Error_Msg()
        endif
    endif
 endfunction

//===========================================================================
function InitTrig_Virulent_Plague_Begin takes nothing returns nothing
    set gg_trg_Virulent_Plague_Begin = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Virulent_Plague_Begin, EVENT_PLAYER_UNIT_SPELL_CAST )
    call TriggerAddCondition( gg_trg_Virulent_Plague_Begin, Condition( function Trig_Virulent_Plague_Begin_Conditions ) )
    call TriggerAddAction( gg_trg_Virulent_Plague_Begin, function Trig_Virulent_Plague_Begin_Actions )
endfunction

