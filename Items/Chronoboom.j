function Trig_Chronoboom_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A09T' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Chronoboom_Actions takes nothing returns nothing
    local effect eff
    local effect sparkle
    call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
    call PauseUnitBJ( true, GetTriggerUnit() )
    call SetUnitInvulnerable( GetTriggerUnit(), true )
    call StopSoundBJ( gg_snd_HourglassCast_3, false )
    call PlaySoundOnUnitBJ( gg_snd_HourglassCast_3, 85.00, GetTriggerUnit() )
    call SetUnitVertexColorBJ( GetTriggerUnit(), 100, 80.00, 25.00, 0 )
    call AddSpecialEffectTargetUnitBJ( "origin", GetTriggerUnit(), "war3mapImported\\ClockRune.mdx" )
    set eff = GetLastCreatedEffectBJ()
    call AddSpecialEffectTargetUnitBJ( "chest", GetTriggerUnit(), "LootEFFECT.mdx" )
    set sparkle = GetLastCreatedEffectBJ()
    // Marksman Pause
    if GetTriggerUnit() == udg_yA_Marksman_Hunter then
    set udg_FeignDeathWait[1] = true
    elseif GetTriggerUnit() == udg_yH_Marksman_Hunter then
    set udg_FeignDeathWait[3] = true
    endif
    // Demon Hunter Pause
    if GetTriggerUnit() == udg_yA_Demon_Hunt then
    set udg_FeignDeathWait[5] = true
    elseif GetTriggerUnit() == udg_yH_Demon_Hunt then
    set udg_FeignDeathWait[6] = true
    endif
    // Wait & Destroy
    call GameTimeWait(2.5)
    call DestroyEffectBJ( eff )
    call DestroyEffectBJ( sparkle )
    set eff = null
    set sparkle = null
    call SetUnitVertexColorBJ( GetTriggerUnit(), 100, 100, 100, 0 )
    call PauseUnitBJ( false, GetTriggerUnit() )
    call SetUnitInvulnerable( GetTriggerUnit(), false )
endfunction

//===========================================================================
function InitTrig_Chronoboom takes nothing returns nothing
    set gg_trg_Chronoboom = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Chronoboom, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Chronoboom, Condition( function Trig_Chronoboom_Conditions ) )
    call TriggerAddAction( gg_trg_Chronoboom, function Trig_Chronoboom_Actions )
endfunction
