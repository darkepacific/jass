// function Check_If_Dummy_Damage takes nothing returns boolean
//     //Wont Work in Cases where Firelords Dummy is Dealing Damage (Eg Mass Entangle)
//     if ( GetEventDamageSource() == gg_unit_e028_1863 )  then
//         return false
//     endif
//     return true
// endfunction
globals
    timer array textTimer
    real TEXT_TIMEOUT = 0.5    

    //Boss Timers
    timer Sarg_Damage_Timer = null
    timer LK_Damage_Timer = null
    timer KJ_Damage_Timer = null
    timer Entropius_Damage_Timer = null
    timer Kael_Damage_Timer = null
    timer DW_Damage_Timer = null

    real global_damage = 0.0
endglobals

//Boss Timers Functions
function Trig_Sarg_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_N03U_1885) and not BlzIsUnitInvulnerable(gg_unit_N03U_1885)) then

        set bj_wantDestroyGroup = true 
        call ForGroupBJ(GetUnitsInRectAll(gg_rct_Sunwell_Plateau), function CleanUpSummons) //Kill Summoned units

        set spawn_pt = GetRectCenter(gg_rct_Sargeras)
        call ShowHero(gg_unit_N03U_1885, spawn_pt, false)
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

function Trig_LK_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_Uear_1259) and not BlzIsUnitInvulnerable(gg_unit_Uear_1259)) then

        set bj_wantDestroyGroup = true 
        call ForGroupBJ(GetUnitsInRectAll(gg_rct_Sunwell_Plateau), function CleanUpSummons) //Kill Summoned units

        set spawn_pt = GetRectCenter(gg_rct_Arthas)
        call ShowHero(gg_unit_Uear_1259, spawn_pt, false)
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

function Trig_KJ_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_Nkjx_2318) and not BlzIsUnitInvulnerable(gg_unit_Nkjx_2318)) then

        set bj_wantDestroyGroup = true 
        call ForGroupBJ(GetUnitsInRectAll(gg_rct_Sunwell_Plateau), function CleanUpSummons) //Kill Summoned units

        set spawn_pt = GetRectCenter(gg_rct_KilJaeden)
        call ShowHero(gg_unit_Nkjx_2318, spawn_pt, false)
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

function Trig_Entropius_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_H03X_2614) and not BlzIsUnitInvulnerable(gg_unit_H03X_2614)) then
        call HideHero(gg_unit_H03X_2614) // Hide the hero

        set bj_wantDestroyGroup = true 
        call ForGroupBJ(GetUnitsInRectAll(gg_rct_Sunwell_Plateau), function CleanUpSummons) //Kill Summoned units
       
        set spawn_pt = GetRectCenter(gg_rct_Muru)
        call ShowHero(gg_unit_H03W_2340, spawn_pt, true) // Show hero at target point
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

function Trig_Kael_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_Hkal_1415) and not BlzIsUnitInvulnerable(gg_unit_Hkal_1415)) then

        set bj_wantDestroyGroup = true 
        call ForGroupBJ(GetUnitsInRectAll(gg_rct_Sunwell_Plateau), function CleanUpSummons) //Kill Summoned units

        set spawn_pt = GetRectCenter(gg_rct_Kael)
        call ShowHero(gg_unit_Hkal_1415, spawn_pt, false)
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

function Trig_DW_Dmg_Timer_Actions takes nothing returns nothing
    local location spawn_pt

    if(IsUnitAliveBJ(gg_unit_E033_1368) and not BlzIsUnitInvulnerable(gg_unit_E033_1368)) then
        set spawn_pt = GetRectCenter(gg_rct_Deathwing)
        call ShowHero(gg_unit_E033_1368, spawn_pt, false)
        call RemoveLocation(spawn_pt)
    endif
    set spawn_pt = null
endfunction

//Out of Combat Check
function isOutOfCombat takes unit u returns boolean
    if TimerGetRemaining(udg_DamageTimer[GetPlayerHeroNumber(GetOwningPlayer(u))]) <= 0.0 then
        return true
    endif
    return false
endfunction

function Unkillable takes unit u, real damage, integer heroNumb returns real
    if GetUnitState(u, UNIT_STATE_LIFE) < damage then
        call BlzSetEventDamage(0 )
        call SetUnitLifeBJ(u, 1.00)

        if TimerGetRemaining(textTimer[heroNumb]) == 0.0 then
            call TimerStart(textTimer[heroNumb], TEXT_TIMEOUT, false, null)
            call CreateTextTagUnitBJ("Unkillable", u, 80.00, 10.00, 100, 20, 10, 0 )
            call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 160, 90 )
            call cleanUpText(1.2, 1.0) 
        endif

        return 0.0
    endif
    return damage
endfunction

function CheatDeath takes unit target returns nothing
    call CreateTextTagUnitBJ("Cheat Death", target, 80.00, 10.00, 15, 100, 20, 0 )
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 160, 90 )
    call cleanUpText(1.2, 1.0) 
endfunction

function DesperatePrayer takes unit target, real maxHP returns nothing
    local real bonusHP = maxHP * 25 / 100
    call BlzSetUnitMaxHP(target, R2I(maxHP + bonusHP))

    call StopSoundBJ(gg_snd_DesperatePrayer, false)
    call PlaySoundOnUnitBJ(gg_snd_DesperatePrayer, 100.0, target )

    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Yellow.mdx" ) 
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
    call AddSpecialEffectTargetUnitBJ("origin", target, "war3mapImported\\HolyAwakening.mdx" ) 
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
    call CreateTextTagUnitBJ("Desperate Prayer", target, 80.00, 10.00, 35, 100, 100, 80 )
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 160, 75 )
    call cleanUpText(1.5, 1.25) 

    call Debug("Desperate Prayer Healing")
    if ChaliceCheckUnit(target) then
        call HealthRestore( (1 + udg_CHALICE_HEAL) * bonusHP, target)
    else
        call HealthRestore(bonusHP, target)
    endif

    if target == udg_yA_Disc_Priest then 
        set udg_DespPrayer_Disc_A = bonusHP
    elseif target == udg_yH_Disc_Priest then
        set udg_DespPrayer_Disc_H = bonusHP
    elseif target == udg_yA_Holy_Priest then
        set udg_DespPrayer_Holy_A = bonusHP
    elseif target == udg_yH_Holy_Priest then
        set udg_DespPrayer_Holy_H = bonusHP
    endif

    call SetUnitOwner(gg_unit_e028_1863, GetOwningPlayer(target), true )
    call SetUnitAbilityLevel(gg_unit_e028_1863, 'ACbb', 10 )
    call IssueTargetOrderBJ(gg_unit_e028_1863, "bloodlust", target )
endfunction

function VampEmbraceHeal takes unit source, real damage returns nothing
    local real heal =((GetUnitAbilityLevel(source, 'A0E9') * 0.04) + 0.06) * damage
    if ChaliceCheckUnit(source) then
        set heal = heal * 1.2
    endif
    call SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + heal)
    call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\Heal Blue.mdx" )
    call BlzSetSpecialEffectAlpha(GetLastCreatedEffectBJ(), 25)
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
    call CreateTextTagUnitBJ(R2S(heal), source, 15.00 + GetRandomReal(0, 15.0), 9.00, 15, 100, 20, 0 )
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 90, 90 )
    call cleanUpText(1.2, 1.0) 
endfunction

function SoulRendingHeal takes unit source, real damage, real percent returns nothing
    local real heal = percent * damage
    call PlaySoundOnUnitBJ(gg_snd_HealTarget04, 100, source )
    if ChaliceCheckUnit(source) then
        set heal = heal *(1 + udg_CHALICE_HEAL)
    endif
    call HealthRestore(heal, source)
    call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\Firebrand Shot Green.mdx" )
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
    call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\GreenHeal_SND.mdx" )
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
endfunction

function AtonementHeal takes nothing returns nothing
    local real heal = 0.15 * global_damage

    if udg_TalentChoices[GetPlayerId(GetOwningPlayer(spellCaster)) * udg_NUM_OF_TC + 4]  then
        set heal = heal * 1.2
    endif

    call Debug("SpellCaster: " + GetUnitName(spellCaster)) 

    if UnitHasBuffBJ(spellUnit, 'B030') then
        if ChaliceCheckUnit(spellCaster) then
            set heal = heal * 1.2
        endif
        call HealthRestore(heal, spellUnit)
        call AddSpecialEffectTargetUnitBJ("origin", spellUnit, "war3mapImported\\Heal.mdx" )
        call BlzSetSpecialEffectAlpha(GetLastCreatedEffectBJ(), 25)
        call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        call CreateTextTagUnitBJ(R2S(heal), spellUnit, 15.00 + GetRandomReal(0, 15.0), 9.00, 15, 100, 20, 0 )
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 90, 90 )
        call cleanUpText(1.2, 1.0) 
    else
        if spellCaster == udg_yA_Disc_Priest then
            call SpellUnits_Remove(spellUnit, udg_z_PR_DISC_H, 40, 63)
            // call SpellUnits_Debug( udg_z_PR_DISC_A, 40, 63)
        elseif spellCaster == udg_yH_Disc_Priest then
            call SpellUnits_Remove(spellUnit, udg_z_PR_DISC_A, 40, 63)
            // call SpellUnits_Debug( udg_z_PR_DISC_A, 40, 63)
        endif
    endif
endfunction

function BladestormHeal takes unit source, real damage returns nothing
    call SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + 0.18 * damage)
    call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\Heal Orange.mdx" )
    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
endfunction

function DisableSecondWind takes unit u returns nothing
    if u == udg_yA_Prot_Warr then
        call DisableTrigger(gg_trg_Second_Wind_Prot_A )
    elseif u == udg_yH_Prot_Warr then
        call DisableTrigger(gg_trg_Second_Wind_Prot_H )
    elseif u == udg_yA_Arms_Warr then
        call DisableTrigger(gg_trg_Second_Wind_Arms_A )
    elseif u == udg_yH_Arms_Warr then
        call DisableTrigger(gg_trg_Second_Wind_Arms_H )
    endif
endfunction

function ArcaneMageManaCheck takes unit source, unit target returns boolean
    if GetUnitManaPercent(source) > 70.0 then
        call AddSpecialEffectTargetUnitBJ("chest", source, "Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl" ) 
        call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        if ModuloInteger(GetTriggerExecCount(GetTriggeringTrigger()), 3) == 0 then
            call AddSpecialEffectTargetUnitBJ("origin", source, "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl" ) 
            call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        endif
        call AddSpecialEffectTargetUnitBJ("chest", target, "war3mapImported\\Radiance Psionic.mdx" ) 
        call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        return true
    endif
    return false
endfunction

// for ((i=10; i<=20; i++)); do echo "elseif UnitHasBuffBJ(source, 'BS$i') then /- call UnitRemoveAbility(source, 'BS$i') /- return $i";  done
function GetBoneShieldLevel takes unit source returns integer
    if UnitHasBuffBJ(source, 'BS02') then 
        call UnitRemoveAbility(source, 'BS02') 
        return 2
    elseif UnitHasBuffBJ(source, 'BS03') then 
        call UnitRemoveAbility(source, 'BS03') 
        return 3
    elseif UnitHasBuffBJ(source, 'BS04') then 
        call UnitRemoveAbility(source, 'BS04') 
        return 4
    elseif UnitHasBuffBJ(source, 'BS05') then 
        call UnitRemoveAbility(source, 'BS05') 
        return 5
    elseif UnitHasBuffBJ(source, 'BS06') then 
        call UnitRemoveAbility(source, 'BS06') 
        return 6
    elseif UnitHasBuffBJ(source, 'BS07') then 
        call UnitRemoveAbility(source, 'BS07') 
        return 7
    elseif UnitHasBuffBJ(source, 'BS08') then 
        call UnitRemoveAbility(source, 'BS08') 
        return 8
    elseif UnitHasBuffBJ(source, 'BS09') then 
        call UnitRemoveAbility(source, 'BS09') 
        return 9
    elseif UnitHasBuffBJ(source, 'BS10') then 
        call UnitRemoveAbility(source, 'BS10') 
        return 10
    elseif UnitHasBuffBJ(source, 'BS11') then 
        call UnitRemoveAbility(source, 'BS11') 
        return 11
    elseif UnitHasBuffBJ(source, 'BS12') then 
        call UnitRemoveAbility(source, 'BS12') 
        return 12
    elseif UnitHasBuffBJ(source, 'BS13') then 
        call UnitRemoveAbility(source, 'BS13') 
        return 13
    elseif UnitHasBuffBJ(source, 'BS14') then 
        call UnitRemoveAbility(source, 'BS14') 
        return 14
    elseif UnitHasBuffBJ(source, 'BS15') then 
        call UnitRemoveAbility(source, 'BS15') 
        return 15
    elseif UnitHasBuffBJ(source, 'BS16') then 
        call UnitRemoveAbility(source, 'BS16') 
        return 16
    elseif UnitHasBuffBJ(source, 'BS17') then 
        call UnitRemoveAbility(source, 'BS17') 
        return 17
    elseif UnitHasBuffBJ(source, 'BS18') then 
        call UnitRemoveAbility(source, 'BS18') 
        return 18
    elseif UnitHasBuffBJ(source, 'BS19') then 
        call UnitRemoveAbility(source, 'BS19') 
        return 19
    elseif UnitHasBuffBJ(source, 'BS20') then 
        call UnitRemoveAbility(source, 'BS20') 
        return 20
    else
        return 0
    endif
endfunction

function Trig_Dmg_Engine_Actions takes nothing returns nothing
    local unit target = BlzGetEventDamageTarget()
    local player targetPlayer = GetOwningPlayer(target)
    local unit source = GetEventDamageSource()
    local player sourcePlayer = GetOwningPlayer(source)
    local damagetype dmgtype = BlzGetEventDamageType()
    local real damage = GetEventDamage()
    local boolean reduced = false
    local boolean increased = false
    local location pt1
    local location pt2
    local integer heroNumb
    local integer abilvl
    local integer i
    local real s

    if(udg_Debug and udg_Dmg) then
        call DisplayTextToForce(GetPlayersAll(), BlzGetUnitStringField(source, UNIT_SF_NAME) + " damaged " + BlzGetUnitStringField(target, UNIT_SF_NAME) + " for:" )
        if dmgtype == DAMAGE_TYPE_NORMAL then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cccFF2200Physical|r")
        elseif dmgtype == DAMAGE_TYPE_MAGIC then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc00099FFMagical|r")
        elseif dmgtype == DAMAGE_TYPE_SLOW_POISON then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc0ea00ffSlow Poison|r")
        elseif dmgtype == DAMAGE_TYPE_POISON then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cff41a109Poison|r")
        elseif dmgtype == DAMAGE_TYPE_DISEASE then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc055c315Disease|r")
        elseif dmgtype == DAMAGE_TYPE_ENHANCED then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc0c3b515Enhanced|r")
        elseif dmgtype == DAMAGE_TYPE_ACID then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc0c968d6Acid|r")
        elseif dmgtype == DAMAGE_TYPE_UNIVERSAL then
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " |cc07515c3Universal|r")
        else 
            call DisplayTextToForce(GetPlayersAll(), R2S(GetEventDamage()) + " Other")
        endif
    endif

    if damage > 0.0 then
        //--------------------------------------------------------------------------------------------------------
        // Combat Timers
        //--------------------------------------------------------------------------------------------------------
        //Out of Combat Source
        set heroNumb = GetPlayerHeroNumber(sourcePlayer)
        if heroNumb < 8 then
            if source == udg_Heroes[heroNumb] then
                call TimerStart(udg_DamageTimer[heroNumb], 5.00, false, null)
                call DisableSecondWind(source)
            endif
        endif
        
        //Out of Combat Target
        set heroNumb = GetPlayerHeroNumber(targetPlayer)
        if heroNumb < 8 then
            if target == udg_Heroes[heroNumb] then
                if udg_IsHearthing[heroNumb] then
                    call IssueImmediateOrder(target, "stop" )
                    set udg_IsHearthing[heroNumb] = false
                endif
                call TimerStart(udg_DamageTimer[heroNumb], 5.00, false, null)
                call DisableSecondWind(target)
            endif
        endif

        //Boss Timers Out of Combat
        //Sargeras
        if source == gg_unit_N03U_1885 or target == gg_unit_N03U_1885 then
            call TimerStart(Sarg_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_Sarg_Dmg_Timer_Actions)
        endif
        //Lich King
        if source == gg_unit_Uear_1259 or target == gg_unit_Uear_1259 then
            call TimerStart(LK_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_LK_Dmg_Timer_Actions)
        endif
        //Kil'Jaeden
        if source == gg_unit_Nkjx_2318 or target == gg_unit_Nkjx_2318 then
            call TimerStart(KJ_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_KJ_Dmg_Timer_Actions)
        endif
        //Entropius
        if source == gg_unit_H03X_2614 or target == gg_unit_H03X_2614 then
            call TimerStart(Entropius_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_Entropius_Dmg_Timer_Actions)
        endif
        //Kael
        if source == gg_unit_Hkal_1415 or target == gg_unit_Hkal_1415 then
            call TimerStart(Kael_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_Kael_Dmg_Timer_Actions)
        endif
        //Deathwing
        if source == gg_unit_E033_1368 or target == gg_unit_E033_1368 then
            call TimerStart(DW_Damage_Timer, udg_BOSS_COMBAT_TIMER, false, function Trig_DW_Dmg_Timer_Actions)
        endif

        //--------------------------------------------------------------------------------------------------------
        // Reduction Logic
        //--------------------------------------------------------------------------------------------------------
        //Faction Leaders
        if target == gg_unit_Usyl_0179 or target == gg_unit_O012_0383 then  //Sylvanas, Lor'themar
            set damage = damage *(0.8 +(udg_Num_Captured_Bases_Alliance * 0.02))
            set reduced = true
        elseif target == gg_unit_H02D_0004 or target == gg_unit_Hapm_0294 then //Anduin, Magni
            set damage = damage *(0.8 +(udg_Num_Captured_Bases_Horde * 0.02))
            set reduced = true
        endif

        //Bosses
            // Ymiron
        if target == gg_unit_Opgh_1163 then
            set damage = damage * 0.85
            set reduced = true
            //Skovald
        elseif target == gg_unit_H03R_2211 then
            set damage = damage * 0.85
            set reduced = true
            //Lich King
        elseif target == gg_unit_Uear_1259 then
            set damage = damage * 0.85
            set reduced = true
            //Patchwerk
        elseif target == gg_unit_U043_1599 then
            set damage = damage * 0.85
            set reduced = true
        elseif target == gg_unit_E033_1368 then
            set damage = damage * 0.95
            set reduced = true
            //Kil'Jaeden
        elseif target == gg_unit_Nkjx_2318 then
            set damage = damage * 0.72
            set reduced = true
            //Kael, Whitemane
        elseif target == gg_unit_Hkal_1415 or target == gg_unit_H01P_0467 then
            set damage = damage * 0.69
            set reduced = true
        endif
        
        //Quest 
        //Cannons
        if GetUnitTypeId(source) == 'o00Z' then
            if GetUnitTypeId(target) != 'h03T' then
                set damage = 0
                set reduced = true
            endif
        endif
        //Red and Black Dragons
        if GetUnitTypeId(target) == 'nrdr' or GetUnitTypeId(target) == 'nrwm' or GetUnitTypeId(target) == 'nbwm' then
            if GetUnitTypeId(source) != 'nrdr' and GetUnitTypeId(source) != 'nrwm' and GetUnitTypeId(source) != 'nbwm' then
                set damage = 0
                set reduced = true
            endif
        endif
        //Old Gods
        if GetUnitTypeId(target) == 'nfgo' then
            if GetUnitTypeId(source) == 'n053' then
                set damage = 1000
                set increased = true
            else
                call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Purple.mdx" ) 
                call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                set damage = 12
                set reduced = true
            endif
        endif

        //Demon Hunter
        if UnitHasBuffBJ(source, 'B03C') then
            if target == udg_yA_Demon_Hunt or target == udg_yH_Demon_Hunt then
                set damage = damage * 0.07
                set reduced = true
                call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Green.mdx" ) 
                call DestroyEffectBJ(GetLastCreatedEffectBJ() )
            endif
        endif
        
        //Rogue
        if target == udg_yA_Combat_Rogue or target == udg_yH_Combat_Rogue or target == udg_yA_Ass_Rogue or target == udg_yH_Ass_Rogue then
            //Cheat Death
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 13]  then
                //Main Timer is off CD
                if GetUnitState(target, UNIT_STATE_LIFE) < damage and TimerGetRemaining(udg_CheatDeath[heroNumb]) == 0.0 and udg_CheatDeathBool[heroNumb] == false then
                    //call SetUnitLifePercentBJ(target, 7.0)
                    call SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_MAX_LIFE) * 7 / 100)
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Green.mdx" ) 
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                    set udg_CheatDeathBool[heroNumb] = true
                    call StartTimerBJ(udg_CheatDeath[heroNumb], false, 3.00 )
                    call CheatDeath(target)
                    set damage = 0
                    set reduced = true
                else
                    //Secondary Timer is active
                    if udg_CheatDeathBool[heroNumb] == true then
                        call CheatDeath(target)
                        set damage = damage * 0.07
                        set reduced = true
                    endif
                endif
            endif
        endif
        if(target == udg_yA_Subtle_Rogue and udg_CloakofShadowsA) or(target == udg_yH_Subtle_Rogue and udg_CloakofShadowsH) then
            set damage = damage *(1 -(GetUnitAbilityLevel(target, 'A0EX') * 0.05 + 0.05))
            set reduced = true
        endif
        //Priest
        if target == udg_yA_Disc_Priest or target == udg_yH_Disc_Priest or target == udg_yA_Holy_Priest or target == udg_yH_Holy_Priest then
            //Desperate Prayer
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 10]  then
                //i is the offset
                if target == udg_yA_Disc_Priest or target == udg_yH_Disc_Priest then
                    set i = 48
                else
                    set i = 56
                endif
                set s = GetUnitState(target, UNIT_STATE_MAX_LIFE) 
                //Main Timer is off CD
                if GetUnitState(target, UNIT_STATE_LIFE) <(s * 25.1 / 100) and TimerGetRemaining(udg_CheatDeath[heroNumb + i]) == 0.0 and udg_CheatDeathBool[heroNumb + i] == false then
                    set udg_CheatDeathBool[heroNumb + i] = true
                    call StartTimerBJ(udg_CheatDeath[heroNumb + i], false, 6.00 )
                    call Debug("Starting Shorter Desperate Prayer Timer:" + I2S(heroNumb + i) )
                    call DesperatePrayer(target, s)
                endif
            endif
        endif
        //Holy Word Salvation
        if(UnitHasBuffBJ(target, 'B03B') ) then
            set damage = damage *(0.1)
            set reduced = true
            call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Yellow.mdx" ) 
            call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        endif
        //Pain Supression
        if(UnitHasBuffBJ(target, 'B031') ) then
            set damage = damage *(0.5)
            set reduced = true
            call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Blue.mdx" ) 
            call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        endif
        //Power Word Barrier
        if(UnitHasBuffBJ(target, 'B033') ) then
            set damage = damage *(0.75)
            set reduced = true
            call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Yellow.mdx" ) 
            call DestroyEffectBJ(GetLastCreatedEffectBJ() )
        endif
        //Warrior
        if target == udg_yA_Prot_Warr or target == udg_yH_Prot_Warr then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 10]  then
                set damage = damage * 0.88
                set reduced = true
            endif
        endif
        //Shield Wall
        if(UnitHasBuffBJ(target, 'B022') ) then
            set damage = damage *(0.6)
            set reduced = true
        endif
        //Death Knight -- Talents
        if target == udg_yA_Frost_DK or target == udg_yH_Frost_DK then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 14]  then
                set damage = damage * 0.85
                set reduced = true
            endif
        endif
        if target == udg_yA_Unholy_DK or target == udg_yH_Unholy_DK then
            if GetUnitAbilityLevel(target, 'Aeth') > 0 then
                set damage = damage * 0.5
                set reduced = true
            endif
        endif
        if target == udg_yA_Blood_DK or target == udg_yH_Blood_DK then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 11]  then
                if GetUnitLifePercent(target) < 30.00 then
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Red.mdx" ) 
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )

                    if TimerGetRemaining(textTimer[heroNumb]) == 0.0 then
                        call TimerStart(textTimer[heroNumb], TEXT_TIMEOUT, false, null)
                        call CreateTextTagUnitBJ("Will of the Necropolis", target, 80.00, 10.00, 100, 8.00, 8.00, 0 )
                        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 90, 90 )
                        call cleanUpText(1.2, 1.0) 
                    endif


                    set damage = damage * 0.6
                    set reduced = true
                endif
            endif
        endif
        //Paladin
        if target == udg_yA_Prot_Pally or target == udg_yH_Prot_Pally then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 14]  then
                if GetUnitLifePercent(target) < 35.00 then
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Effect_ShieldBuff_Yellow.mdx" ) 
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                    
                    if TimerGetRemaining(textTimer[heroNumb]) == 0.0 then
                        call TimerStart(textTimer[heroNumb], TEXT_TIMEOUT, false, null)
                        call CreateTextTagUnitBJ("Ardent Defender", target, 80.00, 10.00, 100, 100, 70, 0 )
                        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 90, 90 )
                        call cleanUpText(1.2, 1.0) 
                    endif
                    

                    set damage = damage * 0.65
                    set reduced = true
                endif
            endif
        endif
        //Druid
        if target == udg_yA_Feral_Druid or target == udg_yH_Feral_Druid then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 8]  then
                if GetUnitLifePercent(target) < 50.0 then
                    call IssueImmediateOrderBJ(target, "battleroar")
                    if 0.0 == BlzGetUnitAbilityCooldownRemaining(target, 'A0E3') then
                        call SetUnitAbilityLevel(gg_unit_e028_1863, 'ACbb', 6 )
                        call IssueTargetOrderBJ(gg_unit_e028_1863, "bloodlust", target )
                        call StopSoundBJ(gg_snd_Survival_Instincts, false )
                        call PlaySoundOnUnitBJ(gg_snd_Survival_Instincts, 88, target )
                        set udg_Temp_Unit_CD = target
                        call TriggerExecute(gg_trg_Cooldown_Maths)
                        call BlzStartUnitAbilityCooldown(udg_Temp_Unit_CD, 'A0E3',(udg_CooldownRemaining *(40 - 8 * GetUnitAbilityLevel(target, 'A0E3')  ) ) )
                    endif
                    call Debug("battleroar attempted to trigger, cd: " + R2S(BlzGetUnitAbilityCooldownRemaining(target, 'A0E3')))
                endif
            endif
            if(UnitHasBuffBJ(target, 'B026') ) then
                set damage = damage *(0.75)
                set reduced = true
            endif
        endif

        //ShieldLogic
        if HasShield(target) then
            set damage = DamageShield(target, damage, heroNumb, sourcePlayer)            
            set reduced = true
        endif

        if reduced then
            if udg_Dmg then
                call Debug("|cccFFaa00Damage reduced |r" + R2S(GetEventDamage()))
            endif
        endif

        //--------------------------------------------------------------------------------------------------------
        // Increase Logic
        //--------------------------------------------------------------------------------------------------------
        //Death Knight
        if source == udg_yA_Blood_DK or source == udg_yH_Blood_DK then
            if dmgtype == DAMAGE_TYPE_NORMAL then
                //Bone Armor
                if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 8]  then
                    set abilvl = GetUnitAbilityLevel(source, 'A0FJ') + 1
                    if GetRandomInt(1, 100) <= 34 then //(10 * abilvl + 10) then
                        set i = GetBoneShieldLevel(source)
                        set i = i + 15
                        call Debug(I2S(i))

                        if i <(abilvl * 5) + 15 then
                            set i = i + abilvl
                            if i > 35 then
                                set i = 35
                            endif
                        endif
                        call Debug(I2S(i))
                        call SetUnitAbilityLevel(gg_unit_e03G_2001, 'A0BF', i)

                        call IssueTargetOrder(gg_unit_e03G_2001, "innerfire", source )
                        call Debug("Attempted to cast boneshield.")
                    endif
                endif
                //Bloodworm
                if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 13]  then
                    if GetRandomInt(1, 20) > 15 then
                        set pt1 = GetUnitLoc(target)
                        call CreateUnitAtLocSaveLast(sourcePlayer, 'ndwm', pt1, GetUnitFacing(source))
                        call UnitApplyTimedLife(GetLastCreatedUnit(), 'BTLF', 8.0)
                        call SetUnitExploded(GetTriggerUnit(), true )
                        call RemoveLocation(pt1)
                    endif
                endif
            endif
        endif
        if UnitHasBuffBJ(target, 'B01K') then
            call SpellUnits_CleanMissingBuff(udg_z_DK_UNHO_A, 40, 63, 'B01K')
            call SpellUnits_Add(target, udg_z_DK_UNHO_A, 40, 63) 
        endif
        if UnitHasBuffBJ(target, 'B039') then
            call SpellUnits_CleanMissingBuff(udg_z_DK_UNHO_H, 40, 63, 'B039')
            call SpellUnits_Add(target, udg_z_DK_UNHO_H, 40, 63) 
        endif
        //Physical could cause a unit to be added to both Groups but have been plagued by only one DK
        // if dmgtype != DAMAGE_TYPE_NORMAL and dmgtype != DAMAGE_TYPE_POISON and dmgtype != DAMAGE_TYPE_SPIRIT_LINK and dmgtype != DAMAGE_TYPE_MAGIC and dmgtype != DAMAGE_TYPE_UNIVERSAL then
        //     if source == udg_yA_Unholy_DK or ( source == gg_unit_e00H_2048 and GetOwningPlayer(gg_unit_e00H_2048) == GetOwningPlayer(udg_yA_Unholy_DK) ) then
        //         call GroupAddUnitSimple( target, udg_AoEDoTGroup[1] )
        //     elseif source == udg_yH_Unholy_DK or ( source == gg_unit_e00H_2048 and GetOwningPlayer(gg_unit_e00H_2048) == GetOwningPlayer(udg_yH_Unholy_DK) ) then 
        //         call GroupAddUnitSimple( target, udg_AoEDoTGroup[0] )
        //     endif
        // endif
        if(dmgtype == DAMAGE_TYPE_SLOW_POISON) then
            if(sourcePlayer == GetOwningPlayer(udg_yA_Unholy_DK)) then
                call CastVirulentPlague(udg_yA_Unholy_DK, target)
            elseif(sourcePlayer == GetOwningPlayer(udg_yH_Unholy_DK)) then
                call CastVirulentPlague(udg_yH_Unholy_DK, target)
            endif
        endif
        
        //Rogue or Rogue's Dummy        // EP WILL BUG when gg_unit_e00H_2048 changes mid fight and not apply EP
        //NEED TO CAREFULLY THINK ABOUT DUMMY SWITCHING
        if source == udg_yA_Ass_Rogue or source == udg_yH_Ass_Rogue or(source == gg_unit_e00H_2048 and(GetOwningPlayer(gg_unit_e00H_2048) == GetOwningPlayer(udg_yA_Ass_Rogue) or GetOwningPlayer(gg_unit_e00H_2048) == GetOwningPlayer(udg_yH_Ass_Rogue) )) then
            set heroNumb = GetPlayerHeroNumber(sourcePlayer)
            //Envenom
            if dmgtype == DAMAGE_TYPE_SLOW_POISON then
                //Damage
                if TimerGetRemaining(udg_CheatDeath[heroNumb + 32]) > 0 then
                    set damage = damage + I2R((GetHeroStatBJ(bj_HEROSTAT_AGI, source, true) ))//- GetHeroStatBJ(bj_HEROSTAT_AGI, source, false) ))
                    set increased = true
                    call AddSpecialEffectTargetUnitBJ("origin", target, "war3mapImported\\OrbOfVenomMissile.mdx" )
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                endif
                //Heal
                if TimerGetRemaining(udg_CheatDeath[heroNumb + 24]) > 0 then     
                    call SoulRendingHeal(source, damage, 0.25)
                endif
                //Slow - does not call recursion b/c dmg must be > 0
                if TimerGetRemaining(udg_CheatDeath[heroNumb + 16]) > 0 then 
                    //Play Slow   f
                    call SetUnitAbilityLevelSwapped('A03P', gg_unit_e028_1863, 6 )
                    call SetUnitOwner(gg_unit_e028_1863, sourcePlayer, true )
                    call IssueTargetOrderBJ(gg_unit_e028_1863, "slow", target )
                    // call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(gg_unit_e028_1863, 'A03P'), ABILITY_RLF_DURATION_NORMAL, 5, 1.0 )
                    // call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(gg_unit_e028_1863, 'A03P'), ABILITY_RLF_DURATION_HERO, 5, 1.0 )
                endif
            endif
            //Elaborate Planning
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 14]  then
                if(udg_Debug) then
                    call DisplayTextToForce(GetPlayersAll(), "|cc00AA000EP Time Remaining: |r" + R2S(TimerGetRemaining(udg_CheatDeath[heroNumb + 8])) + " heroNumb: " + I2S(heroNumb) )
                endif
                if TimerGetRemaining(udg_CheatDeath[heroNumb + 8]) > 0 then
                    set damage = damage * 1.12
                    set increased = true
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Radiance Orange.mdx" ) 
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Ephemeral Cut Orange.mdx" )
                    call BlzSetSpecialEffectOrientation(GetLastCreatedEffectBJ(), GetRandomReal(0, 360.00), GetRandomReal(0, 360.00), GetRandomReal(0, 360.00) )
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )                    
                endif
            endif
        endif
        //Druid
        if source == udg_yA_Feral_Druid or source == udg_yH_Feral_Druid or source == udg_yA_Bal_Druid or source == udg_yH_Bal_Druid then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 3]  then
                if(UnitHasBuffBJ(target, 'B00C') ) then
                    set damage = damage *(1.1)
                    set increased = true
                    call AddSpecialEffectTargetUnitBJ("overhead", target, "war3mapImported\\Radiance Psionic.mdx" ) 
                    call DestroyEffectBJ(GetLastCreatedEffectBJ() )
                endif
            endif
            if(UnitHasBuffBJ(source, 'B026') ) then
                set damage = damage *(1.25)
                set increased = true
            endif
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 3]  then
            endif
        endif
        //Mage
        if sourcePlayer == GetOwningPlayer(udg_yA_Arcane_Mage) then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 4]  then
                if ArcaneMageManaCheck(udg_yA_Arcane_Mage, target) then
                    set damage = damage *(1.1)
                    set increased = true
                endif
            endif
        elseif sourcePlayer == GetOwningPlayer(udg_yH_Arcane_Mage) then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 4]  then
                if ArcaneMageManaCheck(udg_yH_Arcane_Mage, target) then
                    set damage = damage *(1.1)
                    set increased = true
                endif
            endif
        endif  
        if increased then
            if udg_Dmg then
                call Debug("|cc0aaaaFFDamage increased |r" + R2S(GetEventDamage()))
            endif
        endif


        //--------------------------------------------------------------------------------------------------------
        // Finally Set the Damage
        //--------------------------------------------------------------------------------------------------------
        call BlzSetEventDamage(damage )
        set global_damage = damage


        //--------------------------------------------------------------------------------------------------------
        // Healing Logic
        //--------------------------------------------------------------------------------------------------------
        if source == udg_yA_Arms_Warr then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 9]  then
                if IsTriggerEnabled(gg_trg_Bladestorm_Tick_Hu) then
                    call BladestormHeal(source, damage)
                endif
            endif
        elseif source == udg_yH_Arms_Warr then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 9]  then
                if IsTriggerEnabled(gg_trg_Bladestorm_Tick_Or) then
                    call BladestormHeal(source, damage)
                endif
            endif
        endif

        if source == udg_yA_Shadow_Priest then
            if udg_VampEmbrace_A then
                call VampEmbraceHeal(source, damage)
            endif
        elseif source == udg_yH_Shadow_Priest then
            if udg_VampEmbrace_H then
                call VampEmbraceHeal(source, damage)
            endif
        endif
        
        if source == udg_yA_Dark_Ranger then
            //Aspect of the Bat
            set s = GetUnitAbilityLevel(source, 'A0GD')
            if dmgtype == DAMAGE_TYPE_NORMAL and s > 0 and not IsTriggerEnabled(gg_trg_Withering_Fire_Tick_A) then
                set s = s * 0.04 //+ 0.05
                call Debug("Apsect of the Bat DR Heal: " + R2S(s))
                call HealthRestore(s * damage, source)
                call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\VampiricAuraTarget.mdx" )
                call DestroyEffectBJ(GetLastCreatedEffectBJ() )
            endif
            //Banshee Form
            if GetUnitTypeId(source) == 'E04M' then
                call SoulRendingHeal(source, damage, 0.50)
            endif
        elseif source == udg_yH_Dark_Ranger then
            //Aspect of the Bat
            set s = GetUnitAbilityLevel(source, 'A0GD')
            if dmgtype == DAMAGE_TYPE_NORMAL and s > 0 and not IsTriggerEnabled(gg_trg_Withering_Fire_Tick_H) then
                set s = s * 0.04 //+ 0.05
                call Debug("Apsect of the Bat DR Heal: " + R2S(s))
                call HealthRestore(s * damage, source)
                call AddSpecialEffectTargetUnitBJ("origin", source, "war3mapImported\\VampiricAuraTarget.mdx" )
                call DestroyEffectBJ(GetLastCreatedEffectBJ() )
            endif
            //Banshee Form
            if GetUnitTypeId(source) == 'E04M' then
                call SoulRendingHeal(source, damage, 0.50)
            endif
        endif

        if source == udg_yA_Demon_Hunt then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 14]  then
                call SoulRendingHeal(source, damage, 0.12)
            endif
        elseif source == udg_yH_Demon_Hunt then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 14]  then
                call SoulRendingHeal(source, damage, 0.12)
            endif
        endif

        //udg_SpellUnits[udg_z_PR_DISC_A + 7] is the dummy that casts Shadowmend
        if source == udg_yA_Disc_Priest or source == udg_SpellUnits[udg_z_PR_DISC_A + 7] then
            call SpellUnits_ForEach(source, udg_z_PR_DISC_A, 40, 63, function AtonementHeal) 
            // call SpellUnits_Debug( udg_z_PR_DISC_A, 40, 63)
        elseif source == udg_yH_Disc_Priest or source == udg_SpellUnits[udg_z_PR_DISC_H + 7] then
            call SpellUnits_ForEach(source, udg_z_PR_DISC_H, 40, 63, function AtonementHeal) 
            // call SpellUnits_Debug( udg_z_PR_DISC_H, 40, 63)
        endif
        if target == udg_yA_Brew_Monk or target == udg_yH_Brew_Monk then
            if udg_TalentChoices[GetPlayerId(targetPlayer) * udg_NUM_OF_TC + 7]  then
                if target == udg_yA_Brew_Monk then
                    set udg_o = udg_z_MK_BREW_A
                else
                    set udg_o = udg_z_MK_BREW_H
                endif
                if GetRandomInt(1, 10) < 3 then
                    set pt1 = GetUnitLoc(target)
                    set pt2 = GetUnitLoc(udg_SpellUnits[udg_o + 0] )
                    call Debug("Orb Loc: " + R2S(GetLocationX(pt2)) + ", " + R2S(GetLocationY(pt2)) )
                    if DistanceBetweenPoints(pt1, pt2) > 800 then
                        set i = 0
                        loop 
                            //tries 8 times to find a location for the orb
                            exitwhen i > 7
                            call RemoveLocation(pt2)
                            set pt2 = PolarProjectionBJ(pt1, GetRandomReal(200.00, 300.00), GetRandomDirectionDeg() )
                            if not IsTerrainPathable(GetLocationX(pt2), GetLocationY(pt2), PATHING_TYPE_WALKABILITY) then
                                if(udg_SpellUnits[udg_o + 0] == null) then
                                    call CreateNUnitsAtLoc(1, 'e04C', GetOwningPlayer(GetTriggerUnit()), pt2, GetRandomDirectionDeg() )
                                    set udg_SpellUnits[udg_o + 0] = GetLastCreatedUnit()
                                    call TriggerRegisterUnitInRangeSimple(gg_trg_Healing_Spheres_0, 64.00, udg_SpellUnits[udg_o + 0]  )
                                    //If the monk has never casted the ability before we need to assign it here
                                    if(udg_SpellUnits[udg_o + 1] == null) then
                                        call TriggerRegisterUnitEvent(gg_trg_Healing_Spheres_Death, target, EVENT_UNIT_DEATH  )
                                    endif
                                else
                                    call SetUnitPositionLoc(udg_SpellUnits[udg_o + 0], pt2 )
                                endif
                                set i = 8
                            else
                                set i = i + 1
                            endif
                        endloop
                    endif
                    call RemoveLocation(pt1)
                    call RemoveLocation(pt2)
                endif
            endif
        endif

        //--------------------------------------------------------------------------------------------------------
        // Additional Effects
        //--------------------------------------------------------------------------------------------------------
        //Fiery Brand Shield
        if UnitHasBuffBJ(target, 'B03C') then
            if source == udg_yA_Demon_Hunt then
                set udg_FieryBrandA = udg_FieryBrandA +(0.3 * damage)
            elseif source == udg_yH_Demon_Hunt then
                set udg_FieryBrandH = udg_FieryBrandH +(0.3 * damage)
            endif
        endif
        
        //Unkillable 
        if target == udg_yA_Fury_Warr and udg_A_Fury_Warr_Endless then
            set damage = Unkillable(target, damage, heroNumb )
        endif
        if target == udg_yH_Fury_Warr and udg_H_Fury_Warr_Endless then
            set damage = Unkillable(target, damage, heroNumb )
        endif
        if target == gg_unit_H03R_2211 and udg_N_God_King_Skovald_Endless then
            set damage = Unkillable(target, damage, heroNumb )
        endif

        //Hellfire
        if target == udg_yA_Destro_Warlock then
            if GetUnitState(target, UNIT_STATE_LIFE) < 2 * damage then
                call DisableTrigger(gg_trg_Hellfire_Tick_GN)
                call IssueImmediateOrder(target, "stop" )
                call IssueImmediateOrder(target, "unimmolation" )
                call Debug("Hellfire Disabled")
            endif
        endif
        if target == udg_yH_Destro_Warlock then
            if GetUnitState(target, UNIT_STATE_LIFE) < 2 * damage then
                call DisableTrigger(gg_trg_Hellfire_Tick_OR)
                call IssueImmediateOrder(target, "stop" )
                call IssueImmediateOrder(target, "unimmolation" )
                call Debug("Hellfire Disabled")
            endif
        endif
        //Killing Machine
        if target == udg_yA_Frost_DK then
            set udg_DmgTaken_FrostDK_A = udg_DmgTaken_FrostDK_A + damage
        elseif target == udg_yH_Frost_DK then
            set udg_DmgTaken_FrostDK_H = udg_DmgTaken_FrostDK_H + damage
        endif
        //Outbreak
        if BlzGetEventAttackType() == ATTACK_TYPE_SIEGE then
            if udg_TalentChoices[GetPlayerId(sourcePlayer) * udg_NUM_OF_TC + 14]  then
                if GetUnitState(target, UNIT_STATE_LIFE) < damage then
                    call Debug("Attempted to Reset Plague Bringer")
                    if source == udg_yA_Unholy_DK then
                        set udg_Unholy_DK_Reset_A = true
                    elseif source == udg_yH_Unholy_DK then
                        set udg_Unholy_DK_Reset_H = true
                    endif
                endif
            endif
        endif

        if udg_Dmg then
            call Debug("|cff80ff80Final Dmg: |r" + R2S(GetEventDamage()) )
        endif
    endif

    set target = null
    set targetPlayer = null
    set source = null
    set sourcePlayer = null
    set dmgtype = null
    set pt1 = null
    set pt2 = null

endfunction

//Out of Combat
function OutOfCombat takes unit u returns nothing
    if IsUnitDeadBJ(u) then
        return
    endif
    //Warriors
    if u == udg_yA_Prot_Warr then
        if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + 13]  then
            call EnableTrigger(gg_trg_Second_Wind_Prot_A )
            call EnableTrigger(gg_trg_Second_Wind_Mana_Toggle )
        endif
    elseif u == udg_yH_Prot_Warr then
        if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + 13]  then
            call EnableTrigger(gg_trg_Second_Wind_Prot_H )
            call EnableTrigger(gg_trg_Second_Wind_Mana_Toggle )
        endif
    elseif u == udg_yA_Arms_Warr then
        if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + 13]  then
            call EnableTrigger(gg_trg_Second_Wind_Arms_A )
            call EnableTrigger(gg_trg_Second_Wind_Mana_Toggle )
        endif
    elseif u == udg_yH_Arms_Warr then
        if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + 13]  then
            call EnableTrigger(gg_trg_Second_Wind_Arms_H )
            call EnableTrigger(gg_trg_Second_Wind_Mana_Toggle )
        endif
        //Death Knights
    elseif u == udg_yA_Frost_DK then
        set udg_DmgTaken_FrostDK_A = 0
    elseif u == udg_yH_Frost_DK then
        set udg_DmgTaken_FrostDK_H = 0
    endif
    call ResetComboPoints(u)
endfunction

function OutOfCombatTalent takes unit u returns nothing
    if IsOutOfCombat(u) then
        call OutOfCombat(u )
    endif
endfunction

//===========================================================================
function InitTrig_Dmg_Engine takes nothing returns nothing
    local integer i = 0
    set gg_trg_Dmg_Engine = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Dmg_Engine, EVENT_PLAYER_UNIT_DAMAGED )
    // call TriggerAddCondition( gg_trg_Dmg_Engine, Condition( function Check_If_Dummy_Damage ) )
    call TriggerAddAction(gg_trg_Dmg_Engine, function Trig_Dmg_Engine_Actions )

    //Instatiate all the text timers for udg_Heroes and 11 for neutral
    loop
        exitwhen i > 11
        if textTimer[i] == null then
            set textTimer[i] = CreateTimer()
        endif
        set i = i + 1
    endloop

    //Boss Timers Create
    set Sarg_Damage_Timer = CreateTimer()
    set LK_Damage_Timer = CreateTimer()
    set KJ_Damage_Timer = CreateTimer()
    set Entropius_Damage_Timer = CreateTimer()
    set Kael_Damage_Timer = CreateTimer()
    set DW_Damage_Timer = CreateTimer()
endfunction


