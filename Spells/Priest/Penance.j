function Trig_Penance_Tick_A_Actions takes nothing returns nothing
    local integer i = 38
    local integer modulo = 40
    local location Target_Point 
    local real FacingAngle
    local real SOUND_VOL = 69.0
    local integer offset = PenanceOffset(ModuloInteger( udg_SpellTicks[i], 8 ))
    
    set udg_o = udg_z_PR_DISC_A
    set udg_Temp_Unit = udg_yA_Disc_Priest
    

    //CREATE NEW
    if udg_PenanceChannel_A and IsUnitAliveBJ(udg_Temp_Unit) and ModuloInteger( udg_SpellTicks[i], modulo ) == 0 and udg_SpellTicks[i] != (modulo * 3) and IsUnitAliveBJ(udg_SpellUnits[udg_o]) then
        call DestroyEffect(udg_Penance_A)
        set udg_Temp_Unit_Point = GetUnitLoc(udg_Temp_Unit)
        set FacingAngle = GetUnitFacing( udg_Temp_Unit)
        set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 32.00, FacingAngle)
        call RemoveLocation (udg_Temp_Unit_Point)
        call AddSpecialEffectLocBJ( udg_Temp_Polar_Point, "war3mapImported\\Penance.mdx" )
        set udg_Penance_A = GetLastCreatedEffectBJ()
        call BlzSetSpecialEffectAlpha(udg_Penance_A, 88)
        call BlzSetSpecialEffectYaw( udg_Penance_A, Deg2Rad(FacingAngle) )
        call BlzSetSpecialEffectZ( udg_Penance_A, ( 32.00 + offset + BlzGetLocalSpecialEffectZ(udg_Penance_A) ) )
        call RemoveLocation (udg_Temp_Polar_Point)
        call PenanceCastSound(SOUND_VOL)
    else
        //MOVE EXISTING
        if udg_Penance_A != null then
            set udg_Temp_Unit_Point = GetSpecialEffectLoc( udg_Penance_A )
            set Target_Point = GetUnitLoc(udg_SpellUnits[udg_o])
            set FacingAngle = AngleBetweenPoints(udg_Temp_Unit_Point, Target_Point)
            set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 22.00, FacingAngle)
            call RemoveLocation (udg_Temp_Unit_Point)
            call BlzSetSpecialEffectPositionLoc( udg_Penance_A, udg_Temp_Polar_Point)
            call BlzSetSpecialEffectZ( udg_Penance_A, ( 32.00 + offset + (GetLocationZ( udg_Temp_Polar_Point) + BlzGetUnitZ(udg_SpellUnits[udg_o]) ) / 2 ) )
            if DistanceBetweenPoints(udg_Temp_Polar_Point, Target_Point) < 12 then
                call BlzSetSpecialEffectPositionLoc( udg_Penance_A, Target_Point)
                call BlzSetSpecialEffectZ( udg_Penance_A, BlzGetUnitZ(udg_SpellUnits[udg_o]) + 8.0)//( 32.00 + GetLocationZ( Target_Point) ) )
                call DestroyEffect(udg_Penance_A)
                set udg_Penance_A = null
                set udg_RealStatCalc = ( I2R(GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, true)) - I2R(GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, false)) ) 
                if IsUnitEnemy(udg_SpellUnits[udg_o], GetOwningPlayer(udg_Temp_Unit)) then
                    set udg_RealStatCalc = 2.0 * udg_RealStatCalc
                    set udg_HeroStatCalc = GetUnitAbilityLevel(udg_Temp_Unit, 'A02P') * 30 + 15
                else
                    set udg_RealStatCalc = 1.5 * udg_RealStatCalc
                    set udg_HeroStatCalc = GetUnitAbilityLevel(udg_Temp_Unit, 'A02P') * 25 + 15
                endif
                set udg_RealStatCalc = udg_RealStatCalc + I2R(udg_HeroStatCalc)
                if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 0 ] then
                    set udg_RealStatCalc = udg_RealStatCalc * 1.2
                endif
                if IsUnitEnemy(udg_SpellUnits[udg_o], GetOwningPlayer(udg_Temp_Unit)) then
                    call TriggerExecute( gg_trg_Firelords_Helper_Keep_Temp)
                    //Call Add Unit to Firelords Here, Disable Firelords on automatic
                    call UnitDamageTargetBJ(udg_Temp_Unit, udg_SpellUnits[udg_o], udg_RealStatCalc, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
                    call PenanceImpactSound(SOUND_VOL)
                else
                    call ChaliceSet()
                    call SetUnitLifeBJ(udg_SpellUnits[udg_o], GetUnitState( udg_SpellUnits[udg_o], UNIT_STATE_LIFE) + udg_RealStatCalc )
                    call PenanceHealSound(i, modulo, SOUND_VOL)
                    //call AddAtonement
                endif
            endif
            call RemoveLocation (udg_Temp_Polar_Point)
            call RemoveLocation (Target_Point)
        endif
    endif
    
    if udg_SpellTicks[i] == modulo * 3 then
        if udg_Penance_A != null then
            call DestroyEffect(udg_Penance_A)
            set udg_Penance_A = null
        endif
        call DisableTrigger(GetTriggeringTrigger())
    endif

    set udg_SpellTicks[i] = udg_SpellTicks[i] + 1
    set Target_Point = null
endfunction

//===========================================================================
function InitTrig_Penance_Tick_A takes nothing returns nothing
    set gg_trg_Penance_Tick_A = CreateTrigger(  )
    call DisableTrigger( gg_trg_Penance_Tick_A )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Penance_Tick_A, 0.02 )
    call TriggerAddAction( gg_trg_Penance_Tick_A, function Trig_Penance_Tick_A_Actions )
endfunction