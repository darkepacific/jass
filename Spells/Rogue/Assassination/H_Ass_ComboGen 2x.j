function Trig_H_Ass_ComboGen_2x_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityUnit() == udg_yH_Ass_Rogue ) ) then
        return false
    endif
    if ( not ( udg_HAssEviscerate == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_H_Ass_ComboGen_2x_Func004Func002Func002C takes nothing returns boolean
    if ( not ( udg_HAssComboPoints == 2.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_H_Ass_ComboGen_2x_Func004Func002C takes nothing returns boolean
    if ( not ( udg_HAssComboPoints == 1.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_H_Ass_ComboGen_2x_Func004C takes nothing returns boolean
    if ( not ( udg_HAssComboPoints == 0.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_H_Ass_ComboGen_2x_Actions takes nothing returns nothing
    set udg_Temp_Unit = udg_yH_Ass_Rogue
    if ( Trig_H_Ass_ComboGen_2x_Func004C() ) then
        call DestroyEffectBJ( udg_HAssComboEffects[0] )
        call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "RedSpellOrb.mdx" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
        set udg_HAssComboEffects[0] = GetLastCreatedEffectBJ()
        call DestroyEffectBJ( udg_HAssComboEffects[1] )
        call AddSpecialEffectTargetUnitBJ( "right hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
        set udg_HAssComboEffects[1] = GetLastCreatedEffectBJ()
        call CreateTextTagUnitBJ( "TRIGSTR_5850", udg_Temp_Unit, 10.00, 8.00, 100, 100, 0.00, 0 )
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
        call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
        call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 1.00 )
        call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.50 )
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
        set udg_HAssComboPoints = ( udg_HAssComboPoints + 2.00 )
    else
        if ( Trig_H_Ass_ComboGen_2x_Func004Func002C() ) then
            call DestroyEffectBJ( udg_HAssComboEffects[1] )
            call AddSpecialEffectTargetUnitBJ( "right hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
            call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
            set udg_HAssComboEffects[1] = GetLastCreatedEffectBJ()
            call DestroyEffectBJ( udg_HAssComboEffects[2] )
            call AddSpecialEffectTargetUnitBJ( "left hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
            call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
            set udg_HAssComboEffects[2] = GetLastCreatedEffectBJ()
            call CreateTextTagUnitBJ( "TRIGSTR_2750", udg_Temp_Unit, 10.00, 8.00, 100, 100, 0.00, 0 )
            call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
            call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
            call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 1.00 )
            call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.50 )
            call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
            set udg_HAssComboPoints = ( udg_HAssComboPoints + 2.00 )
        else
            if ( Trig_H_Ass_ComboGen_2x_Func004Func002Func002C() ) then
                call DestroyEffectBJ( udg_HAssComboEffects[2] )
                call AddSpecialEffectTargetUnitBJ( "left hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
                call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
                set udg_HAssComboEffects[2] = GetLastCreatedEffectBJ()
                call CreateTextTagUnitBJ( "TRIGSTR_2749", udg_Temp_Unit, 10.00, 8.00, 100, 100, 0.00, 0 )
                call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
                call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
                call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 1.00 )
                call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.50 )
                call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
                set udg_HAssComboPoints = ( udg_HAssComboPoints + 1 )
            else
            endif
        endif
    endif
endfunction

//===========================================================================
function InitTrig_H_Ass_ComboGen_2x takes nothing returns nothing
    set gg_trg_H_Ass_ComboGen_2x = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_H_Ass_ComboGen_2x, Condition( function Trig_H_Ass_ComboGen_2x_Conditions ) )
    call TriggerAddAction( gg_trg_H_Ass_ComboGen_2x, function Trig_H_Ass_ComboGen_2x_Actions )
endfunction

