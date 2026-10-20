// BATTLE FOR LORDAERON - COMBINED DEATH SET HANDLERS
//
// INSTALL (one source file; keep both original editor trigger objects):
//   1. Paste this ENTIRE file into the converted Death Set Horde trigger.
//   2. Replace ALL code in the converted Death Set Alliance trigger with:
//          // Implemented in Death Set Horde by Death_Set_Combined.j.
//   3. Keep BOTH original triggers enabled and present. Do not install either old .j file.
// This file defines BOTH original InitTrig functions. The editor's existing init calls
// create each trigger exactly once, using the original gg_trg handles and action names.
// All existing TriggerExecute callers continue to work. No new trigger is required.
// Requires JassHelper and GenericFunctions (Debug).
//
// SHARED INPUTS (unchanged):
//   udg_Temp_Int   - target hero slot in Heroes / Revives / Graves and other arrays.
//   udg_DoRevive   - true: resurrect; false: destination only (including Death Gate).
//   udg_IsARezz    - true: gravestone destination; false: regional graveyard.
// SHARED OUTPUT:
//   udg_Temp_Z_Rev - destination. Destination-only callers own location cleanup.
// Actual resurrection removes that location and clears the flags as before.
//
// ORGANIZATION:
//   DeathSet_GetGraveyard - shared routes, Gilneas ownership, then faction-only routes.
//   DeathSet_Run          - ONE shared camera / resurrection / cleanup implementation.
//   Death_Set_Horde / Death_Set_Alliance - compatibility entry points.
//   Trig_* / InitTrig_*   - original trigger wrappers and editor registration.
//
// No route-number changes, new fallback, or ZoneLabels takeover are introduced.
// Unsupported routes leave the previous destination unchanged, as before.
// Keep TriggerExecute callers: the original 3.50-second wait remains.
// Camera objects are replaced by the Hearthstone instant pan to destination center.
// Existing camera-index mismatch and GetTriggerUnit protection are deliberately retained.

library DeathSet requires GenericFunctions

    // GetGraveyard(route, horde): route is the RAW udg_Revives value, not a zone-policy ID.
    // Returns null for an unsupported faction/route pair. The caller then retains its old location.
    private function DeathSet_GetGraveyard takes integer route, boolean horde returns rect
        local integer controlPlayer = 3

        // ----------------------------------------------------------------------
        // IDENTICAL ROUTES: one definition serves BOTH factions.
        // ----------------------------------------------------------------------
        //  4 - Alterac
        if route == 4 then
            return gg_rct_GY_Alterac

            //  5 - Eastern Plaguelands
        elseif route == 5 then
            return gg_rct_GY_EP

            //  9 - Western Plaguelands
        elseif route == 9 then
            return gg_rct_GY_WP

            // 11 - Val'sharah
        elseif route == 11 then
            return gg_rct_GY_Valsharah

            // 14 - Grim Batol
        elseif route == 14 then
            return gg_rct_GY_GrimBatol

            // 17 - Tol Barad
        elseif route == 17 then
            return gg_rct_GY_TolBarad

            // 20 - Dalaran
        elseif route == 20 then
            return gg_rct_Hearth_Dalaran_14

            // 21 - Stormheim
        elseif route == 21 then
            return gg_rct_GY_Stormheim

            // 22 - Dragonblight
        elseif route == 22 then
            return gg_rct_GY_Dragonblight

            // 23 - Argent Tournament
        elseif route == 23 then
            return gg_rct_Hearth_Argent_Tourney_22

        endif

        // 10 - Gilneas: preserve the original live, faction-specific ownership check.
        if route == 10 then
            if horde then
                set controlPlayer = 11
            endif
            if GetOwningPlayer(gg_unit_ncop_1664) == Player(controlPlayer) then
                return gg_rct_GY_Headlands
            else
                return gg_rct_GY_Gilneas_City_Controlled
            endif
        endif

        if horde then
            // ------------------------------------------------------------------
            // HORDE DESTINATIONS: differences from the shared routes above.
            // ------------------------------------------------------------------
            //  0 - Brill
            if route == 0 then
                return gg_rct_GY_Brill

                //  1 - Eversong
            elseif route == 1 then
                return gg_rct_GY_Eversong

                //  2 - Sepulcher
            elseif route == 2 then
                return gg_rct_GY_Sepulcher

                //  3 - Tarren Mill
            elseif route == 3 then
                return gg_rct_GY_Tarren_Mill

                //  6 - Zandalar
            elseif route == 6 then
                return gg_rct_GY_Zandalar

                //  7 - Vengeance Landing
            elseif route == 7 then
                return gg_rct_GY_Vengance

                //  8 - Revantusk
            elseif route == 8 then
                return gg_rct_GY_Revantusk

                // 12 - Bulwark
            elseif route == 12 then
                return gg_rct_GY_Bulwark

                // 13 - Grim Batol
            elseif route == 13 then
                return gg_rct_GY_GrimBatol

                // 15 - Ghostlands (Horde)
            elseif route == 15 then
                return gg_rct_GY_Ghostlands

                // 24 - Agmar's Hammer
            elseif route == 24 then
                return gg_rct_Hearth_Agmars_Hammer_21

            endif
        else
            // ------------------------------------------------------------------
            // ALLIANCE DESTINATIONS: differences from the shared routes above.
            // ------------------------------------------------------------------
            //  0 - Kharanos
            if route == 0 then
                return gg_rct_GY_Kharanos

                //  1 - Arathi
            elseif route == 1 then
                return gg_rct_GY_Arathi

                //  2 - Hinterlands
            elseif route == 2 then
                return gg_rct_GY_Hinterland

                //  3 - Southshore
            elseif route == 3 then
                return gg_rct_GY_Southshore

                //  6 - Kul Tiras
            elseif route == 6 then
                return gg_rct_GY_KulTiras

                //  7 - Westguard
            elseif route == 7 then
                return gg_rct_GY_Westguard

                // 13 - Wetlands
            elseif route == 13 then
                return gg_rct_GY_Wetlands

                // 15 - Ghostlands (Alliance)
            elseif route == 15 then
                return gg_rct_GY_Ghostlands_Alliance

                // 24 - Wintergarde Keep
            elseif route == 24 then
                return gg_rct_Hearth_Wintergarde_Keep_21

            endif
            // 8 (Revantusk) and 12 (Bulwark) remain unsupported for Alliance.
        endif

        return null
    endfunction

    // Run(horde): the original trigger action calls this in its own execution context.
    private function DeathSet_Run takes boolean horde returns nothing
        local rect graveyard = null

        call Debug("Temp_Int: " + I2S(udg_Temp_Int))
        set udg_X_Player_MUI = GetOwningPlayer(udg_Heroes[udg_Temp_Int])

        // ----------------------------------------------------------------------
        // DESTINATION: raw udg_Revives value -> graveyard rectangle.
        // These numbers are revive-route values, not ZoneLabels policy IDs.
        // ----------------------------------------------------------------------
        if not udg_IsARezz then
            set udg_Temp_Bool = udg_DoRevive

            set graveyard = DeathSet_GetGraveyard(udg_Revives[udg_Temp_Int], horde)

            // Unused routes have no branch and retain the existing destination.
            if graveyard != null then
                set udg_Temp_Z_Rev = GetRectCenter(graveyard)
                if udg_Temp_Bool then
                    call PanCameraToTimedForPlayer(udg_X_Player_MUI, GetLocationX(udg_Temp_Z_Rev), GetLocationY(udg_Temp_Z_Rev), 0.00)
                endif
            endif
        else
            // Priest / shaman spells and self-resurrection use the gravestone.
            call Debug("IsARezz == true")
            set udg_Temp_Z_Rev = GetDestructableLoc(udg_Graves[udg_Temp_Int])
        endif
        set graveyard = null

        // ----------------------------------------------------------------------
        // RESURRECTION: retained operation order and shared-global behavior.
        // Death Gate skips this entire block because udg_DoRevive is false.
        // ----------------------------------------------------------------------
        if udg_DoRevive then
            call Debug("DoRevive == true")

            // Legacy index mismatch intentionally preserved: test Temp_Int, read Player_Number.
            if udg_Z_Camera[udg_Temp_Int] != 1650 then
                call SetCameraFieldForPlayer(udg_X_Player_MUI, CAMERA_FIELD_TARGET_DISTANCE, udg_Z_Camera[udg_Player_Number], 0)
            endif

            // Remove the grave and its UI; stop the pending automatic respawn.
            call KillDestructable(udg_Graves[udg_Temp_Int])
            call ShowDestructable(udg_Graves[udg_Temp_Int], false)
            call DestroyTextTag(udg_FT[udg_Temp_Int])
            call StartTimerBJ(udg_RespawnTimer[udg_Temp_Int], false, 0.25)
            call PauseTimerBJ(true, udg_RespawnTimer[udg_Temp_Int])
            call DestroyTimerDialogBJ(udg_DeathTimerWindows[udg_Temp_Int])

            // Perform resurrection and restore mana.
            call ReviveHeroLoc(udg_Heroes[udg_Temp_Int], udg_Temp_Z_Rev, true)
            call RemoveLocation(udg_Temp_Z_Rev)
            call SetUnitManaPercentBJ(udg_Heroes[udg_Temp_Int], 100.00)

            // Close the relevant self-resurrection dialog.
            if udg_Heroes[udg_Temp_Int] == udg_yA_Holy_Priest or udg_Heroes[udg_Temp_Int] == udg_yH_Holy_Priest then
                call DialogDisplayBJ(false, udg_RessDialog, udg_X_Player_MUI)
            endif
            if udg_Heroes[udg_Temp_Int] == udg_yA_Resto_Sham or udg_Heroes[udg_Temp_Int] == udg_yH_Resto_Sham then
                call DialogDisplayBJ(false, udg_AncesDialog, udg_X_Player_MUI)
            endif

            // Restore the faction-specific Banshee talent bonus.
            if (horde and udg_WasBansheeH) or (not horde and udg_WasBansheeA) then
                if udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Heroes[udg_Temp_Int])) * udg_NUM_OF_TC + 4] then
                    call BlzSetUnitBaseDamage(udg_Heroes[udg_Temp_Int], BlzGetUnitBaseDamage(udg_Heroes[udg_Temp_Int], 0) + 25, 0)
                    if horde then
                        set udg_WasBansheeH = false
                    else
                        set udg_WasBansheeA = false
                    endif
                endif
            endif

            // Legacy protection target and wait are preserved for this cleanup.
            if not udg_IsARezz then
                call SetUnitInvulnerable(GetTriggerUnit(), true)
                call TriggerSleepAction(3.50)
                call SetUnitInvulnerable(GetTriggerUnit(), false)
            endif

            set udg_DoRevive = false
            set udg_IsARezz = false
        endif
    endfunction

    // Compatibility APIs: keep faction selection explicit, exactly as the old callers did.
    function Death_Set_Horde takes nothing returns nothing
        call DeathSet_Run(true)
    endfunction

    function Death_Set_Alliance takes nothing returns nothing
        call DeathSet_Run(false)
    endfunction

endlibrary
