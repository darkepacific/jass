function Pillar_of_Frost_Loop_A takes nothing returns nothing
    local unit u = GetEnumUnit()
    if(IsUnitTargetableEnemyHitsAll(u, udg_yA_Frost_DK)) then
        if udg_o <= (64 + udg_Temp_Int2) then
            set udg_SpellUnits[udg_o] = u
            call IssueImmediateOrder(u, "stop")
            call AddSpecialEffectTargetUnitBJ("origin", u, "war3mapImported\\Blizzard II Missile")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call AddSpecialEffectTargetUnitBJ("origin", u, "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            set udg_o = udg_o + 1
        endif
    endif
    set u = null
endfunction

function PillarOfFrostCalculatDamage takes unit caster returns real
    set udg_RealStatCalc = 0.1 * I2R(GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)) + 0.1 * I2R(GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)) 
    set udg_RealStatCalc = udg_RealStatCalc + I2R(GetUnitAbilityLevel(caster, 'A0G3') * 8) + 8
    return udg_RealStatCalc
endfunction

function PillarOfFrostDealDamage takes unit caster, unit target, real distance returns nothing
    call UnitDamageTargetBJ(caster, target, (440 - distance) / 220 * udg_RealStatCalc, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC)
endfunction

//== Main Function ===

function Trig_Pillar_of_Frost_Tick_A_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 49
    local real pillarX = GetLocationX(udg_Point_Charge_Begin[udg_Temp_Int])
    local real pillarY = GetLocationY(udg_Point_Charge_Begin[udg_Temp_Int])
    local real pillarZ = BlzGetLocalSpecialEffectZ(udg_Charge_SE[udg_Temp_Int])
    local real angle = 0
    local real z = 0
    local real distance = 0
    local integer offset = 0
    local integer i = 0
    local integer o = udg_z_DK_FROS_A
    local unit u
    local unit caster = udg_yA_Frost_DK
    local location pointPull
    set udg_o = o
    set udg_Temp_Int2 = 19

    if udg_Charge_Loop[udg_Temp_Int] < 20 then

        //Create Pillar
        call BlzSetSpecialEffectZ(udg_Charge_SE[udg_Temp_Int], pillarZ + 10)
        call BlzSetSpecialEffectPitch(udg_Charge_SE[udg_Temp_Int], GetRandomReal(0, 0.2))

    elseif udg_Charge_Loop[udg_Temp_Int] == 20 then

        // Designate chained units
        call DummyRootSet(GetOwningPlayer(caster), udg_Point_Charge_Begin[udg_Temp_Int], 0.0, 3)
        set bj_wantDestroyGroup = true
        call ForGroupBJ(GetUnitsInRangeOfLocAll(330.00, udg_Point_Charge_Begin[udg_Temp_Int]), function Pillar_of_Frost_Loop_A)
        set udg_o = o
        set udg_Temp_Unit = caster
        call TriggerExecute(gg_trg_Firelords_Helper_Keep_Temp)
        call PillarOfFrostCalculatDamage(caster)
        loop
            exitwhen i > udg_Temp_Int2
            set u = udg_SpellUnits[udg_o + i]
            if u != null then
                set udg_LightningEffects[offset + i] = AddLightningEx("BLCA", false, pillarX, pillarY, pillarZ + GetRandomReal(120, 130), GetUnitX(u), GetUnitY(u), BlzGetUnitZ(u) + 20)
                call Debug("Made Lightning Effect " + I2S(i))
                call IssueTargetOrderBJ(gg_unit_e00H_2048, "ensnare", u)
                // Deal damage
                call PillarOfFrostDealDamage(caster, u, 0)
                call HasFirelords(u)
            else
                set i = udg_Temp_Int2
            endif
            set i = i + 1
        endloop

    elseif udg_Charge_Loop[udg_Temp_Int] > 20 and udg_Charge_Loop[udg_Temp_Int] < 220 then

        if ModuloReal(udg_Charge_Loop[udg_Temp_Int], 10) == 0 then
            // call AddSpecialEffectLocBJ( udg_Point_Charge_Begin[udg_Temp_Int], "war3mapImported\\RemorselessWinter.mdx" )
            call AddSpecialEffectLocBJ(udg_Point_Charge_Begin[udg_Temp_Int], "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathMissile.mdl")
            // call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.6)
            // call BlzSetSpecialEffectAlpha(GetLastCreatedEffectBJ(), 185)
            call DestroyEffect(GetLastCreatedEffectBJ())
            call PillarOfFrostCalculatDamage(caster)
        endif

        // Move units that are out of range and update chains
        call DummyRootSet(GetOwningPlayer(udg_yA_Frost_DK), udg_Point_Charge_Begin[udg_Temp_Int], 0.0, 3)
        set udg_o = o
        loop
            exitwhen i > udg_Temp_Int2
            set u = udg_SpellUnits[udg_o + i]
            if u != null then
                if IsUnitType(u, UNIT_TYPE_FLYING) then
                    set z = GetUnitFlyHeight(u)
                else
                    set z = 20
                endif
                if IsUnitDeadBJ(u) then
                    call DestroyLightningBJ(udg_LightningEffects[offset + i])
                else
                    call MoveLightningEx(udg_LightningEffects[offset + i], false, pillarX, pillarY, pillarZ + GetRandomReal(120, 130), GetUnitX(u), GetUnitY(u), BlzGetUnitZ(u) + z)   
                endif
                set udg_Point_Charge_End[udg_Temp_Int] = GetUnitLoc(u)
                set distance = DistanceBetweenPoints(udg_Point_Charge_Begin[udg_Temp_Int], udg_Point_Charge_End[udg_Temp_Int])
                if UnitHasBuffBJ(u, 'B03F') or UnitHasBuffBJ(u, 'B03G') then
                    set angle = AngleBetweenPoints(udg_Point_Charge_Begin[udg_Temp_Int], udg_Point_Charge_End[udg_Temp_Int])
                    set pointPull = PolarProjectionBJ(udg_Point_Charge_End[udg_Temp_Int], -16, angle)
                    call SetUnitPositionLoc(u, pointPull)
                    call AddSpecialEffectTargetUnitBJ("origin", u, "war3mapImported\\Blizzard II Missile")
                    call DestroyEffectBJ(GetLastCreatedEffectBJ())
                    call AddSpecialEffectTargetUnitBJ("origin", u, "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl")
                    call DestroyEffectBJ(GetLastCreatedEffectBJ())
                endif
                if distance > 220 then
                    set angle = AngleBetweenPoints(udg_Point_Charge_Begin[udg_Temp_Int], udg_Point_Charge_End[udg_Temp_Int])
                    set pointPull = PolarProjectionBJ(udg_Point_Charge_Begin[udg_Temp_Int], 200, angle)
                    call SetUnitPositionLoc(u, pointPull)
                    // mark with buff
                    if(UnitHasBuffBJ(u, 'B03F') or UnitHasBuffBJ(u, 'B03G')) == false then
                        call IssueTargetOrderBJ(gg_unit_e00H_2048, "ensnare", u)
                    endif
                endif
                call RemoveLocation(udg_Point_Charge_End[udg_Temp_Int])

                if ModuloReal(udg_Charge_Loop[udg_Temp_Int], 10) == 0 then
                    //Deal dmg
                    call PillarOfFrostDealDamage(caster, u, distance)
                endif
            else
                set i = udg_Temp_Int2
            endif
            set i = i + 1
        endloop
    
    elseif udg_Charge_Loop[udg_Temp_Int] >= 220 and udg_Charge_Loop[udg_Temp_Int] < 240 then
        // Clean up Pillar
        call BlzSetSpecialEffectZ(udg_Charge_SE[udg_Temp_Int], pillarZ - 13)
        call BlzSetSpecialEffectPitch(udg_Charge_SE[udg_Temp_Int], GetRandomReal(0, 0.2))

        // Clean up chains
        if udg_Charge_Loop[udg_Temp_Int] == 224 then
            loop
                exitwhen i > udg_Temp_Int2
                call DestroyLightningBJ(udg_LightningEffects[offset + i])
                set udg_SpellUnits[udg_o + i] = null
                set i = i + 1
            endloop
        endif
    else
        //Turn off Trigger
        call BlzSetSpecialEffectAlpha(udg_Charge_SE[udg_Temp_Int], 0)
        call DestroyEffectBJ(udg_Charge_SE[udg_Temp_Int])
        call RemoveLocation(udg_Point_Charge_Begin[udg_Temp_Int])

        //Move Dummy away
        set udg_Point_Charge_Begin[udg_Temp_Int] = GetRectCenter(gg_rct_DummyIsland)
        call DummyRootSet(Player(PLAYER_NEUTRAL_PASSIVE), udg_Point_Charge_Begin[udg_Temp_Int], 0.0, 3)
        call RemoveLocation(udg_Point_Charge_Begin[udg_Temp_Int])
        call DisableTrigger(GetTriggeringTrigger())
    endif

    set udg_Charge_Loop[udg_Temp_Int] = udg_Charge_Loop[udg_Temp_Int] + 1
    set u = null
    set caster = null
    set pointPull = null
endfunction


//===========================================================================
function InitTrig_Pillar_of_Frost_Tick_A takes nothing returns nothing
    set gg_trg_Pillar_of_Frost_Tick_A = CreateTrigger()
    call DisableTrigger(gg_trg_Pillar_of_Frost_Tick_A)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Pillar_of_Frost_Tick_A, 0.02)
    call TriggerAddAction(gg_trg_Pillar_of_Frost_Tick_A, function Trig_Pillar_of_Frost_Tick_A_Actions)
endfunction

