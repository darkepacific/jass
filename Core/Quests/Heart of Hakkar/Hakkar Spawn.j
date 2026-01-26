function Trig_Hakkar_Spawn_Actions takes nothing returns nothing
    local location p = null
    local unit u = null
    local effect fx = null
    // Thunder
    set p = GetRectCenter(gg_rct_Hakkar)
    set u = CreateUnitAtLoc(Player(1), 'e01Q', p, 62.03)
    call UnitApplyTimedLifeBJ( 4.00, 'BTLF', u )
    call PlaySoundAtPointBJ( gg_snd_RollingThunder1, 100.00, p, 0 )
    call RemoveLocation(p)
    set p = null
    // Spawn Clouds
    set p = GetRectCenter(gg_rct_Altar_of_Hakkar3)
    set u = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), 'e03V', p, 45.00)
    call UnitApplyTimedLifeBJ( 3.00, 'BTLF', u )
    call SetUnitMoveSpeed( u, 360.00 )
    call SetUnitScalePercent( u, 200.00, 200.00, 200.00 )
    call SetUnitVertexColorBJ( u, 100, 100, 100, 50.00 )
    call RemoveLocation(p)
    set p = null
    set p = GetRectCenter(gg_rct_Hakkar)
    call IssuePointOrderLocBJ( u, "patrol", p )
    call RemoveLocation(p)
    set p = null
    set p = GetRectCenter(gg_rct_Altar_of_Hakkar2)
    set u = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), 'e03V', p, 45.00)
    call UnitApplyTimedLifeBJ( 3.00, 'BTLF', u )
    call SetUnitMoveSpeed( u, 360.00 )
    call SetUnitScalePercent( u, 200.00, 200.00, 200.00 )
    call SetUnitVertexColorBJ( u, 100, 100, 100, 50.00 )
    call RemoveLocation(p)
    set p = null
    set p = GetRectCenter(gg_rct_Hakkar)
    call IssuePointOrderLocBJ( u, "patrol", p )
    call RemoveLocation(p)
    set p = null
    set p = GetRectCenter(gg_rct_Altar_of_Hakkar1)
    set u = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_PASSIVE), 'e03V', p, 45.00)
    call UnitApplyTimedLifeBJ( 3.00, 'BTLF', u )
    call SetUnitMoveSpeed( u, 360.00 )
    call SetUnitScalePercent( u, 200.00, 200.00, 200.00 )
    call SetUnitVertexColorBJ( u, 100, 100, 100, 50.00 )
    call RemoveLocation(p)
    set p = null
    set p = GetRectCenter(gg_rct_Hinterlands_Trolls_2)
    call IssuePointOrderLocBJ( u, "patrol", p )
    call RemoveLocation(p)
    set p = null
    call TriggerSleepAction( 3.00 )

    set p = GetRectCenter(gg_rct_Altar_of_Hakkar3)
    set fx = AddSpecialEffectLoc("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", p)
    if fx != null then
        call BlzSetSpecialEffectZ( fx, 20.00 )
        call DestroyEffect( fx )
    endif
    call RemoveLocation(p)
    set p = null

    set p = GetRectCenter(gg_rct_Altar_of_Hakkar2)
    set fx = AddSpecialEffectLoc("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", p)
    if fx != null then
        call BlzSetSpecialEffectZ( fx, 15.00 )
        call DestroyEffect( fx )
    endif
    call RemoveLocation(p)
    set p = null

    set p = GetRectCenter(gg_rct_Altar_of_Hakkar1)
    set fx = AddSpecialEffectLoc("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", p)
    if fx != null then
        call BlzSetSpecialEffectZ( fx, 15.00 )
        call DestroyEffect( fx )
    endif
    call RemoveLocation(p)
    set p = null

    set p = GetRectCenter(gg_rct_Hakkar)
    set fx = AddSpecialEffectLoc("Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl", p)
    if fx != null then
        call DestroyEffect( fx )
    endif
    call PlaySoundAtPointBJ( gg_snd_LightningBolt1, 100.00, p, 0 )
    call RemoveLocation(p)
    set p = null
    call TriggerSleepAction( 0.65 )

    // Spawn Hakkar
    set p = GetRectCenter(gg_rct_Hakkar)
    set u = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'E04O', p, 62.03)
    call PlaySoundOnUnitBJ( gg_snd_Hakkar_DIE_MORTALS, 100, u )
    call RemoveLocation(p)
    set p = null
    call SetUnitColor( u, PLAYER_COLOR_RED )
    call SetHeroLevelBJ( u, 12, true )
    call CreateTextTagUnitBJ( "TRIGSTR_379", u, 0, 9.00, 100.00, 0.00, 0.00, 0 )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 15.00, 90.00 )
    call cleanUpText(1.65,1.3)

    // (Re)create minimap icon now that Hakkar exists
    call CampaignMinimapIconUnitBJ( u, bj_CAMPPINGSTYLE_BOSS )
    set udg_MiniMapIcon[31] = GetLastCreatedMinimapIcon()
    call SetMinimapIconOrphanDestroy( udg_MiniMapIcon[31], false )
    call SetMinimapIconVisible( udg_MiniMapIcon[31], false )
    if IsPlayerInForce(GetLocalPlayer(), udg_AlliancePlayers) then
        call SetMinimapIconVisible( udg_MiniMapIcon[31], true )
    endif

    call TriggerSleepAction( 2.00 )
    call EnableTrigger(gg_trg_Hakkar_Takes_DMG)
    call SelectHeroSkill( u, 'ANfl' )
    call SelectHeroSkill( u, 'ANfl' )
    call SelectHeroSkill( u, 'ANfl' )

    set u = null
    set fx = null
endfunction

//===========================================================================
function InitTrig_Hakkar_Spawn takes nothing returns nothing
    set gg_trg_Hakkar_Spawn = CreateTrigger(  )
    call DisableTrigger( gg_trg_Hakkar_Spawn )
    call TriggerAddAction( gg_trg_Hakkar_Spawn, function Trig_Hakkar_Spawn_Actions )
endfunction

