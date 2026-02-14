function Trig_Mograine_Dies_Actions takes nothing returns nothing
    local unit mograine = GetTriggerUnit()
    local unit killer = GetKillingUnit()
    local real mograineDeathX = GetUnitX(mograine)
    local real mograineDeathY = GetUnitY(mograine)
    local unit whitemane = gg_unit_H01P_0467
    local location whitemaneLoc
    local location mograineLoc
    local location killerLoc
    local location centerLoc
    local effect corpseGlowFxSilver
    local effect corpseGlowFxHoly
    local effect whitemaneGlowFx
    local effect progressBarFx
    local effect rightHandFx
    local effect leftHandFx
    local effect overheadFx
    local real whitemaneAcquireRange

    // Text tag styling (shared)
    local real TT_SIZE = 9.00
    local integer TT_R = 100
    local integer TT_G = 25
    local integer TT_B = 15
    local integer TT_TRANSPARENCY = 0

    if killer != null then
        set killerLoc = GetUnitLoc(killer)
    endif

    call DisableTrigger( GetTriggeringTrigger() )

    call GameTimeWait(0.5)

    set whitemaneLoc = GetUnitLoc(whitemane)
    set mograineLoc = Location(mograineDeathX, mograineDeathY)

    /*
    =====================================================================================
        MOGRAINE HAS FALLEN?!
    =====================================================================================
    */
    call PlaySoundAtPointBJ( gg_snd_HighInquisitorWhitemaneSpawn01, 100, whitemaneLoc, 0 )
    call CreateTextTagUnitBJ( "Mograine has fallen?", whitemane, 0, TT_SIZE, TT_R, TT_G, TT_B, TT_TRANSPARENCY )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
    call cleanUpText(2.0, 1.8)
    call GameTimeWait(2.2)
   

    /*
    =====================================================================================
        YOU SHALL PAY FOR THIS TREACHERY!
    =====================================================================================
    */
    call CreateTextTagUnitBJ( "You shall pay for this treachery!", whitemane, 0, TT_SIZE, TT_R, TT_G, TT_B, TT_TRANSPARENCY )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
    call cleanUpText(2.7, 2.5)
    
    // Order Whitemane to move to Mograine's corpse position
    call PauseUnit( whitemane, false)
    set whitemaneAcquireRange = BlzGetUnitRealField(whitemane, UNIT_RF_ACQUISITION_RANGE)
    call BlzSetUnitRealField(whitemane, UNIT_RF_ACQUISITION_RANGE, 0.0)
    call IssuePointOrder(whitemane, "move", mograineDeathX, mograineDeathY)
    call GameTimeWait(2.8)
    call BlzSetUnitRealField(whitemane, UNIT_RF_ACQUISITION_RANGE, whitemaneAcquireRange)
    call PauseUnit( whitemane, true)
    call RemoveLocation(whitemaneLoc)
    set whitemaneLoc = GetUnitLoc(whitemane)


    /*
    =====================================================================================
        ARISE MY CHAMPION...
    =====================================================================================
    */
    call CreateTextTagUnitBJ( "Arise my champion...", whitemane, 0, TT_SIZE, TT_R, TT_G, TT_B, TT_TRANSPARENCY )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
    call cleanUpText(2.0, 1.8)

    call SetUnitAnimation(whitemane, "spell")
    call QueueUnitAnimation(whitemane, "stand")
    
    call PlaySoundAtPointBJ( gg_snd_HighInquisitorWhitemaneRes01, 100, whitemaneLoc, 0 )
    call StopSoundBJ( gg_snd_LayOnHands, false )
    call PlaySoundAtPointBJ( gg_snd_LayOnHands, 100, whitemaneLoc, 0 )
    
    call AddSpecialEffectLocBJ( whitemaneLoc, "Progressbar.mdx" )
    call BlzSetSpecialEffectColorByPlayer( GetLastCreatedEffectBJ(), Player(21) )
    call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 1.20 )
    set progressBarFx = GetLastCreatedEffectBJ()
    call BlzSetSpecialEffectZ( progressBarFx, ( 180.00 + BlzGetLocalUnitZ(whitemane)) )
    call BlzSetSpecialEffectTimeScale( GetLastCreatedEffectBJ(), 0.50 )

    // Glow at Mograine's corpse position + Whitemane glow
    call AddSpecialEffectLocBJ(mograineLoc, "war3mapImported\\Radiance Silver.mdx")
    set corpseGlowFxSilver = GetLastCreatedEffectBJ()
    call AddSpecialEffectLocBJ(mograineLoc, "war3mapImported\\Radiance Holy.mdx")
    set corpseGlowFxHoly = GetLastCreatedEffectBJ()
    set whitemaneGlowFx = AddSpecialEffectTarget("war3mapImported\\Radiance Crimson.mdx", whitemane, "origin")
    
    set rightHandFx = AddSpecialEffectTarget("LootEFFECT.mdx", whitemane, "right hand")
    set leftHandFx = AddSpecialEffectTarget("LootEFFECT.mdx", whitemane, "left hand")
    set overheadFx = AddSpecialEffectTarget("LootEFFECT.mdx", whitemane, "overhead")

    call GameTimeWait(2.0)



    /*
    =====================================================================================
            Rezz
    =====================================================================================
    */
    call DestroyEffect( progressBarFx )
    call DestroyEffect( rightHandFx )
    call DestroyEffect( leftHandFx )
    call DestroyEffect( overheadFx )
    call DestroyEffect( corpseGlowFxSilver )
    call DestroyEffect( corpseGlowFxHoly )
    call DestroyEffect( whitemaneGlowFx )

    call ReviveHeroLoc( mograine, mograineLoc, true )
    call SetUnitManaPercentBJ( mograine, 100.00 )
    call AddSpecialEffectTargetUnitBJ( "origin", mograine, "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    call AddSpecialEffectTargetUnitBJ( "origin", mograine, "war3mapImported\\Heal.mdx" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    call GameTimeWait(1.5)

    /*
    =====================================================================================
        AT YOUR SIDE M'LADY!
    =====================================================================================
    */
    call PlaySoundAtPointBJ( gg_snd_ScarletCommanderMograineAtRest01, 100, mograineLoc, 0 )
    call CreateTextTagUnitBJ( "At your side m'lady", mograine, 0, TT_SIZE, TT_R, TT_G, TT_B, TT_TRANSPARENCY )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
    call cleanUpText(2.0, 1.8)
    call UnPauseAddInvuln( whitemane, null)

    // Order both to attack-move to the stored killer position (fallback: center)
    if killerLoc == null then
        set centerLoc = GetRectCenter(gg_rct_Scarlet_Sac_N_and_Base_Return)
        set killerLoc = centerLoc
    endif
    call IssuePointOrderLocBJ(whitemane, "attack", killerLoc)
    call IssuePointOrderLocBJ(mograine, "attack", killerLoc)
    if centerLoc != null then
        call RemoveLocation(centerLoc)
    endif

    call RemoveLocation(whitemaneLoc)
    call RemoveLocation(mograineLoc)
    if killerLoc != null then
        call RemoveLocation(killerLoc)
    endif

    set whitemane = null
    set killer = null
    set whitemaneLoc = null
    set mograineLoc = null
    set killerLoc = null
    set centerLoc = null
    set corpseGlowFxSilver = null
    set corpseGlowFxHoly = null
    set whitemaneGlowFx = null
    set progressBarFx = null
    set rightHandFx = null
    set leftHandFx = null
    set overheadFx = null
endfunction

//===========================================================================
function InitTrig_Mograine_Dies takes nothing returns nothing
    set gg_trg_Mograine_Dies = CreateTrigger(  )
    call TriggerRegisterUnitEvent( gg_trg_Mograine_Dies, gg_unit_Hdgo_1208, EVENT_UNIT_DEATH )
    call TriggerAddAction( gg_trg_Mograine_Dies, function Trig_Mograine_Dies_Actions )
endfunction

