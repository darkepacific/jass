function Trig_Learns_Combo_Gen_Ability_Func001C takes nothing returns boolean
    if ( ( GetLearnedSkillBJ() == 'A04P' ) ) then
        return true
    endif
    if ( ( GetLearnedSkillBJ() == 'A017' ) ) then
        return true
    endif
    if ( ( GetLearnedSkillBJ() == 'A00W' ) ) then
        return true
    endif
    if ( ( GetLearnedSkillBJ() == 'A0SD' ) ) then
        return true
    endif
    if ( ( GetLearnedSkillBJ() == 'A09V' ) ) then
        return true
    endif
    return false
endfunction

function Trig_Learns_Combo_Gen_Ability_Conditions takes nothing returns boolean
    if ( not Trig_Learns_Combo_Gen_Ability_Func001C() ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func002C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yA_Subtle_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func003C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yH_Subtle_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func004C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yA_Combat_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func005C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yH_Combat_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func006C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yH_Ass_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Func007C takes nothing returns boolean
    if ( not ( GetLearningUnit() == udg_yA_Ass_Rogue ) ) then
        return false
    endif
    return true
endfunction

function Trig_Learns_Combo_Gen_Ability_Actions takes nothing returns nothing
    if ( Trig_Learns_Combo_Gen_Ability_Func002C() ) then
        set udg_NEREviscerate = true
    else
    endif
    if ( Trig_Learns_Combo_Gen_Ability_Func003C() ) then
        set udg_BEREviscerate = true
    else
    endif
    if ( Trig_Learns_Combo_Gen_Ability_Func004C() ) then
        set udg_WREviscerate = true
    else
    endif
    if ( Trig_Learns_Combo_Gen_Ability_Func005C() ) then
        set udg_UREviscerate = true
    else
    endif
    if ( Trig_Learns_Combo_Gen_Ability_Func006C() ) then
        set udg_HAssEviscerate = true
    else
    endif
    if ( Trig_Learns_Combo_Gen_Ability_Func007C() ) then
        set udg_AAssEviscerate = true
    else
    endif
endfunction

//===========================================================================
function InitTrig_Learns_Combo_Gen_Ability takes nothing returns nothing
    set gg_trg_Learns_Combo_Gen_Ability = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Learns_Combo_Gen_Ability, EVENT_PLAYER_HERO_SKILL )
    call TriggerAddCondition( gg_trg_Learns_Combo_Gen_Ability, Condition( function Trig_Learns_Combo_Gen_Ability_Conditions ) )
    call TriggerAddAction( gg_trg_Learns_Combo_Gen_Ability, function Trig_Learns_Combo_Gen_Ability_Actions )
endfunction

