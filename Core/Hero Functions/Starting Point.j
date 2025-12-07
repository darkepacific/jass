library StartingPoint requires HeroRegistration //CameraSetup, HeroGlobals, TalentUI, UnitIndexer

    // globals
    //     rect gg_rct_DwarvenStartPoint
    //     rect gg_rct_HumanStartPoint
    //     rect gg_rct_NightElfStartPoint
    //     rect gg_rct_BloodElfStartPoint
    //     rect gg_rct_UndeadStartPoint
    //     rect gg_rct_TrollStartPoint
    //     camerasetup gg_cam_Camera_Dwarf_Start
    //     camerasetup gg_cam_Camera_Human_Start
    //     camerasetup gg_cam_Camera_NightElf_Start
    //     camerasetup gg_cam_Camera_BloodElf_Start
    //     camerasetup gg_cam_Camera_Undead_Start
    //     camerasetup gg_cam_Camera_Troll_Start
    // endglobals

    function StartingPoint takes player p, unit hero, rect startRect, camerasetup camera, string hearth, integer revives, integer hearthstone, real facing returns nothing

        set udg_Temp_Unit_Point = GetRectCenter(startRect)
        call SetUnitPositionLocFacingBJ( hero, udg_Temp_Unit_Point, facing )
        call RemoveLocation (udg_Temp_Unit_Point)
        call SetUnitOwner( hero, p, true )
        
        call SetPlayerNumber( p )
        call CameraSetupApplyForPlayer( true, camera, p, 0.00 )
        call SetCameraFieldForPlayer( p, CAMERA_FIELD_TARGET_DISTANCE, udg_Z_Camera[udg_Player_Number], 0 )

        set udg_Revives[udg_Player_Number] = revives
        set udg_Hearthstones[udg_Player_Number] = hearthstone
        set udg_Heroes[udg_Player_Number] = hero

        call SelectUnitForPlayerSingle( udg_Heroes[udg_Player_Number] , p )

        if GetLocalPlayer() == p then
            call BlzSetAbilityExtendedTooltip( 'A02D', ( "After a short delay teleports the hero back to a zone or town. Restores 50%% of health and mana." + ( "|n|nCurrent Hearth: " + ( hearth + "." ) ) ), 0 )
        endif

        if IsPlayerInForce(p, udg_AlliancePlayers) then
            call A_Hero_Registration(hero)
        else
            call H_Hero_Registration(hero)
        endif

        //This has to be after the hero registration because its sets bj_wantDestroyGroup = true
        // call Recreate_HeroesGroup()
        
        call RefreshTalentUI(p)
    endfunction

    function DwarfStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_DwarvenStartPoint, gg_cam_Camera_Dwarf_Start, "Anvilmar", 0, 900, 270.00)
    endfunction

    function HumanStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_HumanStartPoint, gg_cam_Camera_Human_Start, "Refuge Pointe", 1, 800, 270.00)
    endfunction

    function NightElfStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_DwarvenStartPoint, gg_cam_Camera_Dwarf_Start, "Shadowglen", 0, 900, 270.00)
    endfunction

    function BloodElfStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_BloodElfStartPoint, gg_cam_Camera_BloodElf_Start, "Sunstrider Isle", 1, 900, 243.00)
    endfunction

    function UndeadStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_ForsakenStartPoint, gg_cam_Camera_Forsaken_Start, "Deathknell", 0, 800, 200.00)
    endfunction   

    function TrollStartingPoint takes player p, unit hero returns nothing
        call StartingPoint(p, hero, gg_rct_DwarvenStartPoint, gg_cam_Camera_Dwarf_Start, "Echo Isles", 0, 900, 270.00)
    endfunction

endlibrary