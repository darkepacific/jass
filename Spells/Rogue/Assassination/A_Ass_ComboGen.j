function Trig_A_Ass_ComboGen_Func003Func003C takes nothing returns boolean
    if ( ( GetSpellAbilityId() == 'A0AM' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'A09J' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'AEfk' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'A06M' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'A04S' ) ) then
        return true
    endif
    return false
endfunction

function Trig_A_Ass_ComboGen_Func003C takes nothing returns boolean
    if ( not ( GetSpellAbilityUnit() == udg_yA_Ass_Rogue ) ) then
        return false
    endif
    if ( not ( udg_AAssEviscerate == true ) ) then
        return false
    endif
    if ( not Trig_A_Ass_ComboGen_Func003Func003C() ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Conditions takes nothing returns boolean
    if ( not Trig_A_Ass_ComboGen_Func003C() ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Func004C takes nothing returns boolean
    if ( not ( udg_AAssComboPoints == 0.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Func005C takes nothing returns boolean
    if ( not ( udg_AAssComboPoints == 1.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Func006C takes nothing returns boolean
    if ( not ( udg_AAssComboPoints == 2.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Func007C takes nothing returns boolean
    if ( not ( udg_AAssComboPoints < 3.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_A_Ass_ComboGen_Actions takes nothing returns nothing
    set udg_Temp_Unit = udg_yA_Ass_Rogue
    if ( Trig_A_Ass_ComboGen_Func004C() ) then
        call DestroyEffectBJ( udg_AAssComboEffects[0] )
        call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "RedSpellOrb.mdx" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
        set udg_AAssComboEffects[0] = GetLastCreatedEffectBJ()
    else
    endif
    if ( Trig_A_Ass_ComboGen_Func005C() ) then
        call DestroyEffectBJ( udg_AAssComboEffects[1] )
        call AddSpecialEffectTargetUnitBJ( "right hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
        set udg_AAssComboEffects[1] = GetLastCreatedEffectBJ()
    else
    endif
    if ( Trig_A_Ass_ComboGen_Func006C() ) then
        call DestroyEffectBJ( udg_AAssComboEffects[2] )
        call AddSpecialEffectTargetUnitBJ( "left hand", udg_Temp_Unit, "RedSpellOrb.mdx" )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 0.18 )
        set udg_AAssComboEffects[2] = GetLastCreatedEffectBJ()
    else
    endif
    if ( Trig_A_Ass_ComboGen_Func007C() ) then
        call CreateTextTagUnitBJ( "TRIGSTR_5785", udg_Temp_Unit, 10.00, 8.00, 100, 100, 0.00, 0 )
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
        call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
        call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 1.00 )
        call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.50 )
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
        set udg_AAssComboPoints = ( udg_AAssComboPoints + 1 )
    else
    endif
endfunction

//===========================================================================
function InitTrig_A_Ass_ComboGen takes nothing returns nothing
    set gg_trg_A_Ass_ComboGen = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_A_Ass_ComboGen, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_A_Ass_ComboGen, Condition( function Trig_A_Ass_ComboGen_Conditions ) )
    call TriggerAddAction( gg_trg_A_Ass_ComboGen, function Trig_A_Ass_ComboGen_Actions )
endfunction

