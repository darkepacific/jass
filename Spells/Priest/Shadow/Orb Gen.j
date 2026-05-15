function Trig_Orb_Gen_Func009C takes nothing returns boolean
    if ( ( GetSpellAbilityId() == 'A003' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'A02M' ) ) then
        return true
    endif
    if ( ( GetSpellAbilityId() == 'A0FA' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Orb_Gen_Conditions takes nothing returns boolean
    if ( not ( GetUnitAbilityLevelSwapped('A007', GetTriggerUnit()) > 0 ) ) then
        return false
    endif
    if ( not Trig_Orb_Gen_Func009C() ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func004Func004C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A003' ) ) then
        return false
    endif
    if ( not ( GetRandomInt(1, 10) > 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func004C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberDW == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func005Func005C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A003' ) ) then
        return false
    endif
    if ( not ( GetRandomInt(1, 10) > 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func005C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberDW == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func006C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberDW == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func007C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberDW != 3 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func011Func003C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A003' ) ) then
        return false
    endif
    if ( not ( GetRandomInt(1, 10) > 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func011C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberUP == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func012Func005C takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A003' ) ) then
        return false
    endif
    if ( not ( GetRandomInt(1, 10) > 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func012C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberUP == 1 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func013C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberUP == 2 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Func014C takes nothing returns boolean
    if ( not ( udg_DPOrbNumberUP != 3 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Orb_Gen_Actions takes nothing returns nothing
    local boolean extraOrb = false
    set udg_Temp_Unit = GetTriggerUnit()
    if udg_Temp_Unit == udg_yA_Shadow_Priest then
    if ( Trig_Orb_Gen_Func004C() ) then
        call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsDW[0] = GetLastCreatedEffectBJ()
        if ( Trig_Orb_Gen_Func004Func004C() ) then
            if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 2 ] then
            set extraOrb = true
            set udg_DPOrbNumberDW = ( udg_DPOrbNumberDW + 1 )
            endif
        else
        endif
    else
    endif
    if ( Trig_Orb_Gen_Func005C() ) then
        call AddSpecialEffectTargetUnitBJ( "left hand", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsDW[1] = GetLastCreatedEffectBJ()
        if extraOrb == false then
        if ( Trig_Orb_Gen_Func005Func005C() ) then
            if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 2 ] then
            set extraOrb = true
            set udg_DPOrbNumberDW = ( udg_DPOrbNumberDW + 1 )
            endif
        else
        endif
        endif
    else
    endif
    if ( Trig_Orb_Gen_Func006C() ) then
        call AddSpecialEffectTargetUnitBJ( "right hand", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsDW[2] = GetLastCreatedEffectBJ()
    else
    endif
    if ( Trig_Orb_Gen_Func007C() ) then
        if extraOrb then
        call CreateTextTagUnitBJ( "TRIGSTR_10442", udg_Temp_Unit, 10.00, 8.00, 80.00, 0.00, 90.00, 0 )
        else
        call CreateTextTagUnitBJ( "TRIGSTR_10443", udg_Temp_Unit, 10.00, 8.00, 80.00, 0.00, 90.00, 0 )
        endif
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90.00 )
        call cleanUpText(1.2,0.6)
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_AlliancePlayers )
        set udg_DPOrbNumberDW = ( udg_DPOrbNumberDW + 1 )
    else
    endif
    elseif udg_Temp_Unit == udg_yH_Shadow_Priest then
    if ( Trig_Orb_Gen_Func011C() ) then
        call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsUP[0] = GetLastCreatedEffectBJ()
        if ( Trig_Orb_Gen_Func011Func003C() ) then
            if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 2 ] then
            set extraOrb = true
            set udg_DPOrbNumberUP = ( udg_DPOrbNumberUP + 1 )
            endif
        else
        endif
    else
    endif
    if ( Trig_Orb_Gen_Func012C() ) then
        call AddSpecialEffectTargetUnitBJ( "left hand", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsUP[1] = GetLastCreatedEffectBJ()
        if extraOrb == false then
        if ( Trig_Orb_Gen_Func012Func005C() ) then
            if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 2 ] then
            set extraOrb = true
            set udg_DPOrbNumberUP = ( udg_DPOrbNumberUP + 1 )
            endif
        else
        endif
        endif
    else
    endif
    if ( Trig_Orb_Gen_Func013C() ) then
        call AddSpecialEffectTargetUnitBJ( "right hand", udg_Temp_Unit, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl" )
        set udg_DPOrbEffectsUP[2] = GetLastCreatedEffectBJ()
    else
    endif
    if ( Trig_Orb_Gen_Func014C() ) then
        if extraOrb then
        call CreateTextTagUnitBJ( "TRIGSTR_10439", udg_Temp_Unit, 10.00, 8.00, 80.00, 0.00, 90.00, 0 )
        else
        call CreateTextTagUnitBJ( "TRIGSTR_392", udg_Temp_Unit, 10.00, 8.00, 80.00, 0.00, 90.00, 0 )
        endif
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90.00 )
        call cleanUpText(1.2,0.6)
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
        set udg_DPOrbNumberUP = ( udg_DPOrbNumberUP + 1 )
    else
    endif
    endif
endfunction

//===========================================================================
function InitTrig_Orb_Gen takes nothing returns nothing
    set gg_trg_Orb_Gen = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Orb_Gen, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Orb_Gen, Condition( function Trig_Orb_Gen_Conditions ) )
    call TriggerAddAction( gg_trg_Orb_Gen, function Trig_Orb_Gen_Actions )
endfunction

