function Trig_C_Gandling_Enter_Conditions takes nothing returns boolean
    return IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO)
endfunction

function Trig_C_Gandling_Enter_Actions takes nothing returns nothing
    local location p
    local effect e
    local unit voss

    call DisableTrigger(GetTriggeringTrigger())
    call StopSoundBJ(gg_snd_8_GANDLING_THE_BONES, false)

    // =========================================================
    // VOSS ENTERS
    // =========================================================

    // Make sure any previous Voss/tether state is cleaned up.
    // LVT_Voss itself is preserved and recycled.
    call LVT_StopAndCleanup()

    // Blink Voss into position.
    set voss = LVT_ShowOrCreateVossAtRect(gg_rct_Voss_Spawn_Die_Necro, 270.00, false)
    call SetUnitFacing(voss, 45.00)

    if voss == null then
        // Fail-safe: do not leave Gandling permanently locked.
        call UnPauseAddInvuln(gg_unit_U01S_1754, null)
        return
    endif

    // Learn Mutilate if she does not already know it.
    if GetUnitAbilityLevel(voss, 'A0AN') == 0 then
        call SelectHeroSkill(voss, 'A0AN')
    endif

    // Voss attacks Gandling with Mutilate.
    call IssueImmediateOrder(voss, "fanofknives")

    // Visual impact on Gandling.
    set e = AddSpecialEffectTarget("war3mapImported\\Coup de Grace Blue.mdx", gg_unit_U01S_1754, "origin")
    call DestroyEffect(e)
    set e = null

    // =========================================================
    // "DIE, NECROMANCER!"
    // =========================================================

    set p = GetRectCenter(gg_rct_Harsh_Lesson_TP_Center)

    call TransmissionFromUnitTypeWithNameBJ(udg_Scholomance_Message_Group, Player(3), 'E01E', "TRIGSTR_11911", p, gg_snd_9_VOSS_DIE_NECROMANCER, "TRIGSTR_11912", bj_TIMETYPE_ADD, 0.00, false)

    // Give the attack and Voss's line time to land.
    call GameTimeWait(2.00)

    // =========================================================
    // GANDLING RESPONDS
    // "YOUR SOUL IS MINE!"
    // =========================================================

    call TransmissionFromUnitTypeWithNameBJ(udg_Scholomance_Message_Group, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'U01S', "TRIGSTR_11915", p, gg_snd_10_GANDLING_YOUR_SOUL_IS_MINE, "TRIGSTR_11916", bj_TIMETYPE_ADD, 0.00, false)

    // Gandling channels the spell imprisoning Voss.
    call SetUnitAnimation(gg_unit_U01S_1754, "spell channel")

    // Begin Voss's tether and lift.
    // This moves her to Voss_Raise, pauses her, makes her
    // invulnerable, creates the lightning, and starts the lift.
    call LVT_StartLiftTether(voss, gg_rct_Darkmaster_Gandling, gg_rct_Voss_Raise)

    // Lift takes 2.50 seconds. Give it 3 seconds before Voss responds.
    call GameTimeWait(3.00)

    // =========================================================
    // VOSS: "MY SOUL... IT BURNS!"
    // =========================================================

    call TransmissionFromUnitTypeWithNameBJ(udg_Scholomance_Message_Group, Player(3), 'E01E', "TRIGSTR_11919", p, gg_snd_11_VOSS_IT_BURNS, "TRIGSTR_11920", bj_TIMETYPE_ADD, 0.00, false)

    // =========================================================
    // BEGIN GANDLING BOSS FIGHT
    // =========================================================

    call UnPauseAddInvuln(gg_unit_U01S_1754, null)

    call RemoveLocation(p)

    set p = null
    set e = null
    set voss = null
endfunction

//===========================================================================
function InitTrig_C_Gandling_Enter takes nothing returns nothing
    set gg_trg_C_Gandling_Enter = CreateTrigger()
    call DisableTrigger(gg_trg_C_Gandling_Enter)
    call TriggerRegisterEnterRectSimple(gg_trg_C_Gandling_Enter, gg_rct_Gandling_Cinematic_Start)
    call TriggerAddCondition(gg_trg_C_Gandling_Enter, Condition(function Trig_C_Gandling_Enter_Conditions))
    call TriggerAddAction(gg_trg_C_Gandling_Enter, function Trig_C_Gandling_Enter_Actions)
endfunction