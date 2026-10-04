// BATTLE FOR LORDAERON - ZONE LABELS - revision 1
// Based on the supplied war3map.j snapshot, October 2026.
//
// INSTALL
// 1. Make one new trigger named exactly Zone Labels, convert that new trigger
//    to custom text, and replace its entire contents with this file.
//    The vJASS library initializer handles startup (JassHelper must be enabled).
// 2. Keep the existing ZoneText and GenericFunctions libraries.
// 3. Keep the 22 old GUI label triggers present. This code disables them at
//    startup, so no individual conversions or manual disabling are required.
//    Keep music, graveyard, capture, and boss triggers enabled as before.
// 4. Save/compile, then test a hero crossing borders and using a cave portal.
//    Type -zone to see the current subject, coordinates, winning label, and
//    overlapping labels. This command does not move units or change game state.
// 5. Rollback: uncheck THIS custom-text trigger's Enabled flag in the editor
//    so its code is excluded from compilation, then save again.
//    The old label triggers will operate normally in the next map session.
//
// DO NOT replace war3map.j with this file. war3map.j is the generated snapshot;
// these changes belong in the World Editor's trigger source.
// No GUI variables or new editor regions are needed for this first pass.
//
// DESIGN
// - One named zone can contain any number of disconnected editor rectangles.
// - One native region (union of rectangles) is built per named zone at startup.
// - Higher priority wins an overlap; equal priority uses configuration order.
// - Registered heroes are tracked through udg_Heroes, not UNIT_TYPE_HERO.
// - An alive registered flight mount is used while its hero is paused.
// - Position checks run every 0.25s, covering spawn, teleport, movement, revive,
//   and reroll without one enter trigger per rectangle or per music track.
// - Stationary subjects reuse their cached result. The cached text is reapplied
//   each tick so the existing FrameLoader rebuild also recovers the banner.
// - Coordinates and native region membership stay synchronized. The existing
//   ZoneTextSetForPlayer function provides the local-only frame update.
// - No locations, groups, or per-tick handles are created.
//
// SCOPE AND GEOMETRY REVIEW
// This first pass replaces LABELS ONLY. Music selection, udg_Revives, faction
// ownership, Genn/Nathanos, and border graveyard exceptions remain in their
// existing systems. A shared music track does not identify a geographical zone.
//
// Labels below use existing editor rectangles and cave waygate connections.
// They do not infer new rectangles from terrain. Uncovered points CLEAR the
// banner instead of continuing to display a stale label. -zone reports them
// as UNMAPPED. Add an existing or new geography rectangle to the appropriate
// zone below when a gap is confirmed in the editor.
//
// In particular, SP_Cave_Int and Secret_Mine_Int are tiny doorway rectangles,
// with no unambiguous whole-interior rectangle in this snapshot. They are NOT
// claimed as fully covered. Silverpine's Deep_Elem_Mine is mapped separately.
// Any traversable gaps between the named Gilneas rectangles may also
// need an added geography rectangle; do not repurpose graveyard strips for it.
// Review the explicit naming notes for Grim Batol and the connected caves,
// and the Cryptlord_Music geography note under Eastern Plaguelands.
// Existing 22 labels retain their current text, including the two level ranges.
//
// ADD / EDIT A ZONE
// In ZoneLabels_Configure, add:
//   set z = ZoneLabels_Define("Readable zone name", 10)
//   call ZoneLabels_AddRect(z, gg_rct_Your_First_Rectangle)
//   call ZoneLabels_AddRect(z, gg_rct_Your_Second_Rectangle)
// Region globals keep their editor names; no unit or ability rawcodes are used.
// Priorities: terrain 10, selected borders/settlements 20, cities/instances 30,
// and specific neighboring-interior overlap overrides 40.
// Change priorities deliberately if you introduce a new overlapping subzone.
//
// USEFUL API FOR LATER CONSOLIDATION
// ZoneLabelsGetSubject(player) -> current hero / registered flight carrier.
// ZoneLabelsResolve(x, y) -> geographical label ID (0 means unmapped).
// ZoneLabelsGetName(id) -> display text.
// Music profiles and revive rules should be separate location policies. Revive
// resolution must also evaluate faction/capture state when that state changes,
// even for a stationary player; a cached label is not a cached graveyard choice.
//
// VALIDATION
// Plain-JASS projection passed pjass against common.j (the vJASS library/private
// wrapper was stripped for that check). All rectangle and legacy-trigger names
// were checked against this snapshot. Source logic was exercised with native
// stubs for landmarks, overlaps, unmapped locations, hero replacement, death,
// flights, invalid subjects, stationary caching, and frame-text restoration.
// World Editor/JassHelper compilation and actual in-game region cells/UI have
// not been run here. In-game checks to make after compiling:
// - Brill -> Undercity; verify NPCs/pets cannot change the player's banner.
// - Gilneas chapel portal and wall; test deaths with each faction owning it.
// - Azurelode, Ogre Cave, and Weeping Cave; confirm their distinct parent labels.
// - Teleport/revive/reroll; confirm the registered hero drives the new label.
// - One flight route; confirm the moving carrier supplies the label.
// - For any blank banner, type -zone and inspect/add its geography rectangle.

library ZoneLabels initializer ZoneLabels_Init requires ZoneText, GenericFunctions

    globals
        private constant real ZoneLabels_PERIOD = 0.25
        private constant string ZoneLabels_UNMAPPED_TEXT = ""
        private integer ZoneLabels_Count = 0
        private region array ZoneLabels_Areas
        private string array ZoneLabels_Names
        private integer array ZoneLabels_Priorities
        private player array ZoneLabels_Players
        private unit array ZoneLabels_LastSubject
        private real array ZoneLabels_LastX
        private real array ZoneLabels_LastY
        private integer array ZoneLabels_LastZone
        private boolean array ZoneLabels_CacheValid
    endglobals

    private function ZoneLabels_Define takes string name, integer priority returns integer
        set ZoneLabels_Count = ZoneLabels_Count + 1
        set ZoneLabels_Areas[ZoneLabels_Count] = CreateRegion()
        set ZoneLabels_Names[ZoneLabels_Count] = name
        set ZoneLabels_Priorities[ZoneLabels_Count] = priority
        return ZoneLabels_Count
    endfunction

    private function ZoneLabels_AddRect takes integer z, rect r returns nothing
        call RegionAddRect(ZoneLabels_Areas[z], r)
    endfunction

    function ZoneLabelsGetName takes integer z returns string
        if z < 1 or z > ZoneLabels_Count then
            return ZoneLabels_UNMAPPED_TEXT
        endif
        return ZoneLabels_Names[z]
    endfunction

    function ZoneLabelsResolve takes real x, real y returns integer
        local integer z = 1
        local integer best = 0
        // Strictly greater preserves the FIRST configured zone when priorities tie.
        loop
            exitwhen z > ZoneLabels_Count
            if IsPointInRegion(ZoneLabels_Areas[z], x, y) then
                if best == 0 or ZoneLabels_Priorities[z] > ZoneLabels_Priorities[best] then
                    set best = z
                endif
            endif
            set z = z + 1
        endloop
        return best
    endfunction

    function ZoneLabelsGetSubject takes player p returns unit
        local integer slot = GetPlayerHeroNumber(p)
        if slot < 0 or slot > 7 then
            return null
        endif
        if udg_Heroes[slot] == null then
            return null
        endif
        if GetUnitTypeId(udg_Heroes[slot]) == 0 or GetOwningPlayer(udg_Heroes[slot]) != p then
            return null
        endif
        // Dead heroes still identify the player's last position until revived.
        // Flights park and pause that hero; their registered live carrier supplies
        // the moving position. A dead/stale carrier cannot take over the label.
        if udg_FP_Bats_n_Gryphons[slot] != null and IsUnitPaused(udg_Heroes[slot]) then
            if GetUnitTypeId(udg_FP_Bats_n_Gryphons[slot]) != 0 and GetOwningPlayer(udg_FP_Bats_n_Gryphons[slot]) == p then
                if not IsUnitType(udg_FP_Bats_n_Gryphons[slot], UNIT_TYPE_DEAD) and GetWidgetLife(udg_FP_Bats_n_Gryphons[slot]) > 0.405 then
                    return udg_FP_Bats_n_Gryphons[slot]
                endif
            endif
        endif
        return udg_Heroes[slot]
    endfunction

    private function ZoneLabels_Update takes nothing returns nothing
        local integer slot = 0
        local unit subject = null
        local real x = 0.0
        local real y = 0.0
        loop
            exitwhen slot > 7
            set subject = ZoneLabelsGetSubject(ZoneLabels_Players[slot])
            if subject == null then
                set ZoneLabels_LastSubject[slot] = null
                set ZoneLabels_LastZone[slot] = 0
                set ZoneLabels_CacheValid[slot] = false
            else
                set x = GetUnitX(subject)
                set y = GetUnitY(subject)
                if not ZoneLabels_CacheValid[slot] or subject != ZoneLabels_LastSubject[slot] or x != ZoneLabels_LastX[slot] or y != ZoneLabels_LastY[slot] then
                    set ZoneLabels_LastSubject[slot] = subject
                    set ZoneLabels_LastX[slot] = x
                    set ZoneLabels_LastY[slot] = y
                    set ZoneLabels_LastZone[slot] = ZoneLabelsResolve(x, y)
                    set ZoneLabels_CacheValid[slot] = true
                endif
            endif
            // Reapply even when stationary: FrameLoader resets the text on rebuild.
            call ZoneTextSetForPlayer(ZoneLabels_Players[slot], ZoneLabelsGetName(ZoneLabels_LastZone[slot]))
            set slot = slot + 1
        endloop
        set subject = null
    endfunction

    private function ZoneLabels_Diagnose takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local unit subject = ZoneLabelsGetSubject(p)
        local integer z = 0
        local integer i = 1
        local real x = 0.0
        local real y = 0.0
        local string name = "UNMAPPED"
        local string kind = "hero"
        if subject == null then
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 15.0, "Zone labels: no registered hero for this player.")
        else
            set x = GetUnitX(subject)
            set y = GetUnitY(subject)
            set z = ZoneLabelsResolve(x, y)
            if z != 0 then
                set name = ZoneLabelsGetName(z)
            endif
            if subject == udg_FP_Bats_n_Gryphons[GetPlayerHeroNumber(p)] then
                set kind = "flight carrier"
            endif
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 15.0, "Zone: " + name + " | subject: " + kind + " | x=" + R2S(x) + " y=" + R2S(y))
            loop
                exitwhen i > ZoneLabels_Count
                if IsPointInRegion(ZoneLabels_Areas[i], x, y) then
                    call DisplayTimedTextToPlayer(p, 0.0, 0.0, 15.0, "Matches: " + ZoneLabels_Names[i] + " (priority " + I2S(ZoneLabels_Priorities[i]) + ")")
                endif
                set i = i + 1
            endloop
        endif
        set subject = null
        set p = null
    endfunction

    private function ZoneLabels_Configure takes nothing returns nothing
        local integer z = 0

        // Tirisfal Glades
        set z = ZoneLabels_Define("Tirisfal Glades", 10)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_Glades_Soliden_Farm_0)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_Murloc_Coast_0)
        call ZoneLabels_AddRect(z, gg_rct_Trisfal_Glades_0)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_South_Tower_0)
        call ZoneLabels_AddRect(z, gg_rct_Balnir__and_Bulwark_12)
        call ZoneLabels_AddRect(z, gg_rct_DeathKnell_100)
        call ZoneLabels_AddRect(z, gg_rct_Venomweb_Vale_12)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_East_12)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_South_East_12)
        call ZoneLabels_AddRect(z, gg_rct_Tirisfal_South_Tower_Sliver_0)

        // Silverpine Forest
        // Deep_Elem_Mine is reached through SP_Mine_Ext in Silverpine. Shadowfang Keep retains the
        // existing Silverpine label. The graveyard-only Gilneas_Wall_SP_Side_GY_Trigger_2 is
        // deliberately absent.
        set z = ZoneLabels_Define("Silverpine Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Silverpine_2)
        call ZoneLabels_AddRect(z, gg_rct_Silverpine_W_2)
        call ZoneLabels_AddRect(z, gg_rct_Fenris_Isles_2)
        call ZoneLabels_AddRect(z, gg_rct_Skittering_Dark)
        call ZoneLabels_AddRect(z, gg_rct_SF_Keep)
        call ZoneLabels_AddRect(z, gg_rct_Pyrewood_Village)
        call ZoneLabels_AddRect(z, gg_rct_Deep_Elem_Mine)
        call ZoneLabels_AddRect(z, gg_rct_SP_Mine_Int)
        call ZoneLabels_AddRect(z, gg_rct_Skittering_Dark_Cave_Ext)

        // Gilneas
        // Ownership affects revives, not this label. Cathedral_North includes the chapel doorway
        // just outside Gilneas_Chapel. No Genn/Nathanos or graveyard logic is changed. Priority 20
        // makes the named Gilneas geography win over broader terrain if rectangles are extended
        // later.
        set z = ZoneLabels_Define("Gilneas", 20)
        call ZoneLabels_AddRect(z, gg_rct_Gilneas_City)
        call ZoneLabels_AddRect(z, gg_rct_Gilneas_Wall_SP_Side)
        call ZoneLabels_AddRect(z, gg_rct_Gilneas_Chapel)
        call ZoneLabels_AddRect(z, gg_rct_Cathedral_North)
        call ZoneLabels_AddRect(z, gg_rct_Gil_Mine_Lumber)
        call ZoneLabels_AddRect(z, gg_rct_Gilneas_TB_Entrance)
        call ZoneLabels_AddRect(z, gg_rct_Greymane_Manor)
        call ZoneLabels_AddRect(z, gg_rct_Tempest_Reach)
        call ZoneLabels_AddRect(z, gg_rct_Duskhaven_Battle_Music)
        call ZoneLabels_AddRect(z, gg_rct_The_WitchWood)
        call ZoneLabels_AddRect(z, gg_rct_Emberstone_Mine)
        call ZoneLabels_AddRect(z, gg_rct_Emberstone_Int)

        // Hillsbrad
        // Azurelode is connected to Hillsbrad by Azurelode_Mine_Ext. The Kobold_Cave interior
        // below has entrances from both Hillsbrad and the Hinterlands path, so it has its own
        // label.
        set z = ZoneLabels_Define("Hillsbrad", 10)
        call ZoneLabels_AddRect(z, gg_rct_Tarren_Mill_Music_3)
        call ZoneLabels_AddRect(z, gg_rct_Hillsbrad_Foothills_3)
        call ZoneLabels_AddRect(z, gg_rct_SouthHillsbrad_3)
        call ZoneLabels_AddRect(z, gg_rct_North_Hillsbrad_3)
        call ZoneLabels_AddRect(z, gg_rct_Hillsbrad_Foothills_E_3)
        call ZoneLabels_AddRect(z, gg_rct_Dalaran_Crater_3)
        call ZoneLabels_AddRect(z, gg_rct_Azurelode_Mine)
        call ZoneLabels_AddRect(z, gg_rct_Azurelode_Mine_Int)

        // Tol Barad
        set z = ZoneLabels_Define("Tol Barad", 10)
        call ZoneLabels_AddRect(z, gg_rct_Tol_Barad_17)

        // Arathi Highlands (1-10)
        // Ogre_Mine_Ext and the two ElementalCave entrances connect these interiors to Arathi.
        // Stromgarde Harbor wins its overlap with SouthHillsbrad. Existing level text is retained;
        // no new level ranges are invented.
        set z = ZoneLabels_Define("Arathi Highlands (1-10)", 20)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_Starting_Zone_100)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_Starting_Zone_S_100)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_Starting_Blip_100)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_Passage_1)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_North_1)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_North_Blip_1)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_East_1)
        call ZoneLabels_AddRect(z, gg_rct_Arathi_West_1)
        call ZoneLabels_AddRect(z, gg_rct_Thoradins_Wall_1)
        call ZoneLabels_AddRect(z, gg_rct_StromGarde_1)
        call ZoneLabels_AddRect(z, gg_rct_StromGarde_Harbor_1)
        call ZoneLabels_AddRect(z, gg_rct_Ogres_Boss)
        call ZoneLabels_AddRect(z, gg_rct_Ogre_Cave_Music)
        call ZoneLabels_AddRect(z, gg_rct_ElementalCave)
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_North)
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_South)

        // Hinterlands
        // The secret path wins its overlap with eastern Hillsbrad. SecretPathCave uses the
        // Hints_Cave_South entrance. The water cave uses HintWaterCaveWest/East. Sharing cave
        // music does not merge their labels with the Arathi caves.
        set z = ZoneLabels_Define("Hinterlands", 20)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_2)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Secret_Path_2)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Troll_Enclave_2)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Troll_Boss_2)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Seaside_2_or_8)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Moonlight)
        call ZoneLabels_AddRect(z, gg_rct_Revantusk_8)
        call ZoneLabels_AddRect(z, gg_rct_Aerie_Peak)
        call ZoneLabels_AddRect(z, gg_rct_SecretPathCave)
        call ZoneLabels_AddRect(z, gg_rct_Hinterlands_Dwarf_Cave_2)
        call ZoneLabels_AddRect(z, gg_rct_Hint_Pass_Nor)

        // Alterac
        // Alterac_4_SW wins its overlap with North_Hillsbrad_3. The detached keep is connected by
        // Alterac_Int/Ext. Syndicate_Indoors connects the inn to Alterac_North.
        set z = ZoneLabels_Define("Alterac", 20)
        call ZoneLabels_AddRect(z, gg_rct_Alterac_4)
        call ZoneLabels_AddRect(z, gg_rct_Alterac_4_SW)
        call ZoneLabels_AddRect(z, gg_rct_Alterac_North)
        call ZoneLabels_AddRect(z, gg_rct_Alterac_Keep)
        call ZoneLabels_AddRect(z, gg_rct_Syndacite_Inn)

        // Wetlands
        set z = ZoneLabels_Define("Wetlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Wetlands_13)
        call ZoneLabels_AddRect(z, gg_rct_Wetlands_Bordering_Grim_Batol)
        call ZoneLabels_AddRect(z, gg_rct_Wetlands_Coast)
        call ZoneLabels_AddRect(z, gg_rct_Greenwardens_Grove)
        call ZoneLabels_AddRect(z, gg_rct_Sludge_Cave_Wetlands)
        call ZoneLabels_AddRect(z, gg_rct_SludgeCave)
        call ZoneLabels_AddRect(z, gg_rct_SludgeCave_Int)

        // Eversong Woods
        set z = ZoneLabels_Define("Eversong Woods", 10)
        call ZoneLabels_AddRect(z, gg_rct_Eversong_Woods_1)
        call ZoneLabels_AddRect(z, gg_rct_Eversong_Murlocs_1)
        call ZoneLabels_AddRect(z, gg_rct_South_Eversong_1)
        call ZoneLabels_AddRect(z, gg_rct_South_Eversong_Sliver_1)
        call ZoneLabels_AddRect(z, gg_rct_Sunstrider_Isle_101)
        call ZoneLabels_AddRect(z, gg_rct_Silvermoon_Ruins_1)
        call ZoneLabels_AddRect(z, gg_rct_Torwatha)
        call ZoneLabels_AddRect(z, gg_rct_Shalandis_Isle)

        // Ghostlands
        // The Amani catacombs connect through Amani_North/South_Ext in Ghostlands. They are not
        // assigned to Zandalar merely because the music trigger groups them together.
        set z = ZoneLabels_Define("Ghostlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Ghostlands_Center)
        call ZoneLabels_AddRect(z, gg_rct_Ghostlands_South)
        call ZoneLabels_AddRect(z, gg_rct_Ghostlands_West)
        call ZoneLabels_AddRect(z, gg_rct_Deatholme)
        call ZoneLabels_AddRect(z, gg_rct_Dawnstar_Spire)
        call ZoneLabels_AddRect(z, gg_rct_Windrunner_Spire)
        call ZoneLabels_AddRect(z, gg_rct_Amani_Catacombs)
        call ZoneLabels_AddRect(z, gg_rct_Amani_North_Int)
        call ZoneLabels_AddRect(z, gg_rct_Amani_South_Int)
        call ZoneLabels_AddRect(z, gg_rct_Ghostlands_Lake)

        // Western Plaguelands
        // Weeping_Cave_Mine_Entrance is in Western Plaguelands.
        set z = ZoneLabels_Define("Western Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Western_Plaguelands_5)
        call ZoneLabels_AddRect(z, gg_rct_WP_Enter_5)
        call ZoneLabels_AddRect(z, gg_rct_Andorhal_5)
        call ZoneLabels_AddRect(z, gg_rct_MoonWell_WP)
        call ZoneLabels_AddRect(z, gg_rct_Hearth_Glen)
        call ZoneLabels_AddRect(z, gg_rct_Uthers_Grave_Music)
        call ZoneLabels_AddRect(z, gg_rct_Weeping_Cave_WP)
        call ZoneLabels_AddRect(z, gg_rct_Western_Plaguelands_North_5)
        call ZoneLabels_AddRect(z, gg_rct_Western_Plaguelands_Dwarf_Farm_5)
        call ZoneLabels_AddRect(z, gg_rct_Western_Plaguelands_East_5)

        // Eastern Plaguelands
        // REVIEW PARENT: Cryptlord_Music is mostly INSIDE Eastern_Plaguelands_9. This follows that
        // geographical rectangle, despite the older music trigger being called GY WP M.
        set z = ZoneLabels_Define("Eastern Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Eastern_Plaguelands_9)
        call ZoneLabels_AddRect(z, gg_rct_Lights_Hope_9)
        call ZoneLabels_AddRect(z, gg_rct_KT_Music_9)
        call ZoneLabels_AddRect(z, gg_rct_Scarlet_Enclave_9)
        call ZoneLabels_AddRect(z, gg_rct_Cryptlord_Music)

        // Dun Morogh
        set z = ZoneLabels_Define("Dun Morogh", 10)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Morogh_Starting_101)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Morogh_0)
        call ZoneLabels_AddRect(z, gg_rct_DM_Troggs)
        call ZoneLabels_AddRect(z, gg_rct_Gnome_Cave_0)

        // Loch Modan
        set z = ZoneLabels_Define("Loch Modan", 10)
        call ZoneLabels_AddRect(z, gg_rct_Loch_Modan_0)

        // Twilight Highlands
        set z = ZoneLabels_Define("Twilight Highlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Twighlight_Highlands_North_14)
        call ZoneLabels_AddRect(z, gg_rct_Twighlight_Highlands_Delta)
        call ZoneLabels_AddRect(z, gg_rct_Twighlight_Highlands_Maw_Of_Madness)
        call ZoneLabels_AddRect(z, gg_rct_Obsdian_Forest)
        call ZoneLabels_AddRect(z, gg_rct_Obsdian_Forest_Mini)
        call ZoneLabels_AddRect(z, gg_rct_The_Krazzworks)
        call ZoneLabels_AddRect(z, gg_rct_Dragonmaw_Port_14)
        call ZoneLabels_AddRect(z, gg_rct_Highbank_14)
        call ZoneLabels_AddRect(z, gg_rct_Vemillion_Redoubt)

        // Howling Fjord
        set z = ZoneLabels_Define("Howling Fjord", 10)
        call ZoneLabels_AddRect(z, gg_rct_Howling_Fjord_East_7)
        call ZoneLabels_AddRect(z, gg_rct_Howling_Fjord_West_7)
        call ZoneLabels_AddRect(z, gg_rct_HowlingFjordForsaken)
        call ZoneLabels_AddRect(z, gg_rct_Sindragosa_Music)

        // Grizzly Hills
        set z = ZoneLabels_Define("Grizzly Hills", 10)
        call ZoneLabels_AddRect(z, gg_rct_Grizzlemaw)
        call ZoneLabels_AddRect(z, gg_rct_Amberpine)

        // Zul Drak
        set z = ZoneLabels_Define("Zul Drak", 10)
        call ZoneLabels_AddRect(z, gg_rct_Zul_Drak)
        call ZoneLabels_AddRect(z, gg_rct_Zul_Drak_E)

        // Dragonblight
        set z = ZoneLabels_Define("Dragonblight", 10)
        call ZoneLabels_AddRect(z, gg_rct_Dragonblight_North)
        call ZoneLabels_AddRect(z, gg_rct_Dragonblight_Central)
        call ZoneLabels_AddRect(z, gg_rct_Dragonblight_West)
        call ZoneLabels_AddRect(z, gg_rct_Agmars_Hammer)
        call ZoneLabels_AddRect(z, gg_rct_Maoki_Harbor)

        // Icecrown
        set z = ZoneLabels_Define("Icecrown", 10)
        call ZoneLabels_AddRect(z, gg_rct_Icecrown_Central)
        call ZoneLabels_AddRect(z, gg_rct_Icecrown_East)
        call ZoneLabels_AddRect(z, gg_rct_Icecrown_South)
        call ZoneLabels_AddRect(z, gg_rct_Icecrown_West)
        call ZoneLabels_AddRect(z, gg_rct_Icecrown_Glacier)

        // Crystalsong Forest
        set z = ZoneLabels_Define("Crystalsong Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Crystal_Song_E)
        call ZoneLabels_AddRect(z, gg_rct_Crystal_Song_M)
        call ZoneLabels_AddRect(z, gg_rct_Crystal_Song_W)

        // Storm Peaks
        // Takes precedence at the shared edge with Crystalsong Forest.
        set z = ZoneLabels_Define("Storm Peaks", 20)
        call ZoneLabels_AddRect(z, gg_rct_Storm_Peaks)

        // Valsharah
        set z = ZoneLabels_Define("Valsharah", 10)
        call ZoneLabels_AddRect(z, gg_rct_Valsharah_11)

        // Suramar
        set z = ZoneLabels_Define("Suramar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Suramar_North)
        call ZoneLabels_AddRect(z, gg_rct_Suramar)
        call ZoneLabels_AddRect(z, gg_rct_Suramar_Fel)

        // Stormheim
        set z = ZoneLabels_Define("Stormheim", 10)
        call ZoneLabels_AddRect(z, gg_rct_Stormheim_South)
        call ZoneLabels_AddRect(z, gg_rct_Stormheim_North)
        call ZoneLabels_AddRect(z, gg_rct_Hrydshal)
        call ZoneLabels_AddRect(z, gg_rct_Hyrja_Island)

        // High Mountain
        set z = ZoneLabels_Define("High Mountain", 10)
        call ZoneLabels_AddRect(z, gg_rct_High_Mountain)

        // Vashjir
        set z = ZoneLabels_Define("Vashjir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Vashjir_6)

        // Kul Tiras
        // Uses the named landmass rectangle, not revive ID 6, which is also shared with Vashjir
        // and other locations.
        set z = ZoneLabels_Define("Kul Tiras", 20)
        call ZoneLabels_AddRect(z, gg_rct_KulTiras_6)

        // Zandalar
        set z = ZoneLabels_Define("Zandalar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Zandalar_6)

        // Nazmir
        set z = ZoneLabels_Define("Nazmir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Nazmir)

        // The Undercity
        set z = ZoneLabels_Define("The Undercity", 30)
        call ZoneLabels_AddRect(z, gg_rct_Undercity)

        // Silvermoon
        set z = ZoneLabels_Define("Silvermoon", 30)
        call ZoneLabels_AddRect(z, gg_rct_Silvermoon)

        // Scarlet Monastery
        set z = ZoneLabels_Define("Scarlet Monastery", 30)
        call ZoneLabels_AddRect(z, gg_rct_Scarlet_Monastery_12)

        // Scholomance (25-40)
        set z = ZoneLabels_Define("Scholomance (25-40)", 30)
        call ZoneLabels_AddRect(z, gg_rct_Scholomance_Music)

        // Stratholme
        set z = ZoneLabels_Define("Stratholme", 30)
        call ZoneLabels_AddRect(z, gg_rct_Stratholme)

        // Naxxramas
        // Wins the 32-unit strip shared with the Scholomance_Music rectangle.
        set z = ZoneLabels_Define("Naxxramas", 40)
        call ZoneLabels_AddRect(z, gg_rct_Naxxramas)

        // Dalaran
        set z = ZoneLabels_Define("Dalaran", 30)
        call ZoneLabels_AddRect(z, gg_rct_Dalaran_City)
        call ZoneLabels_AddRect(z, gg_rct_Dalaran_Portal_Room)

        // Scarlet Onslaught
        set z = ZoneLabels_Define("Scarlet Onslaught", 30)
        call ZoneLabels_AddRect(z, gg_rct_Dragonblight_Scarlet_Onslaught)

        // Argent Tournament
        set z = ZoneLabels_Define("Argent Tournament", 30)
        call ZoneLabels_AddRect(z, gg_rct_Argent_Tournament)

        // Azjol Nerub
        set z = ZoneLabels_Define("Azjol Nerub", 30)
        call ZoneLabels_AddRect(z, gg_rct_Azjol_Nerub)

        // Ulduar
        // Wins the 32-unit strip shared with Azjol_Nerub.
        set z = ZoneLabels_Define("Ulduar", 40)
        call ZoneLabels_AddRect(z, gg_rct_Ulduar_Dung)

        // Utgarde Keep
        set z = ZoneLabels_Define("Utgarde Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Utguarde_Keep)

        // Zulaman
        set z = ZoneLabels_Define("Zulaman", 30)
        call ZoneLabels_AddRect(z, gg_rct_Zulaman)

        // Sunwell Plateau
        set z = ZoneLabels_Define("Sunwell Plateau", 30)
        call ZoneLabels_AddRect(z, gg_rct_Sunwell_Plateau)

        // Bastion of Twilight
        set z = ZoneLabels_Define("Bastion of Twilight", 30)
        call ZoneLabels_AddRect(z, gg_rct_Bastion_of_Twilight_14)
        call ZoneLabels_AddRect(z, gg_rct_Bastion_of_Twilight_South)

        // Grim Batol
        // REVIEW NAME: current trigger Grim Batol M uses Ironforge_0. This label follows that
        // trigger name; the exported region still has its older Ironforge name.
        set z = ZoneLabels_Define("Grim Batol", 30)
        call ZoneLabels_AddRect(z, gg_rct_Ironforge_0)
        call ZoneLabels_AddRect(z, gg_rct_Ironforge_Magni_0)

        // Grim Batol Volcano
        set z = ZoneLabels_Define("Grim Batol Volcano", 30)
        call ZoneLabels_AddRect(z, gg_rct_Grim_Batol_Volcano)

        // Karazhan
        set z = ZoneLabels_Define("Karazhan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Karazhan)

        // Deadwind Pass
        set z = ZoneLabels_Define("Deadwind Pass", 10)
        call ZoneLabels_AddRect(z, gg_rct_Deadwind_Pass)

        // Neltharions Lair
        set z = ZoneLabels_Define("Neltharions Lair", 30)
        call ZoneLabels_AddRect(z, gg_rct_Nelfarions_Lair)

        // Chromies Inn
        set z = ZoneLabels_Define("Chromies Inn", 30)
        call ZoneLabels_AddRect(z, gg_rct_ChromieInn)

        // Blue Dragon Island
        set z = ZoneLabels_Define("Blue Dragon Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Blue_Dragon_Island)

        // Kamuga Village
        set z = ZoneLabels_Define("Kamuga Village", 20)
        call ZoneLabels_AddRect(z, gg_rct_Kamuga_Village)

        // Vrykul Island
        set z = ZoneLabels_Define("Vrykul Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Vrykul_Island)

        // Tuskar Island
        set z = ZoneLabels_Define("Tuskar Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Tuskar_Island)

        // Warchiefs Cove
        set z = ZoneLabels_Define("Warchiefs Cove", 20)
        call ZoneLabels_AddRect(z, gg_rct_Warchiefs_Cove_6)

        // Admirals Point
        set z = ZoneLabels_Define("Admirals Point", 20)
        call ZoneLabels_AddRect(z, gg_rct_Admirals_Point_6)

        // Dark Portal
        set z = ZoneLabels_Define("Dark Portal", 30)
        call ZoneLabels_AddRect(z, gg_rct_Dark_Portal)

        // Duel Island
        set z = ZoneLabels_Define("Duel Island", 30)
        call ZoneLabels_AddRect(z, gg_rct_Duel_Island)

        // Kobold Cave
        // REVIEW LABEL: a connected cave with entrances at Cave_Mine_Exterior (Hillsbrad) and
        // Dwarf_Mine_Entrance (Hinterlands path). A distinct place name avoids guessing one parent
        // for the whole connected interior.
        set z = ZoneLabels_Define("Kobold Cave", 30)
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave)

        // Gnomeregan
        // REVIEW LABEL: connected to both Dun Morogh (DM_Mine_W) and Loch Modan (DM_Mine_E). Uses
        // a distinct interior name for now.
        set z = ZoneLabels_Define("Gnomeregan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Dwarf_Cave_0)

        // Dun Morogh Pass
        // The detached passage is connected by the KZPass and DulAlgaz waygates.
        set z = ZoneLabels_Define("Dun Morogh Pass", 30)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Morogh_Pass_0)
        call ZoneLabels_AddRect(z, gg_rct_Dwarf_Passasge)

        // Dun Modr
        // Dun_Modr_Thass wins its overlap with the larger Ironforge_0 rectangle.
        set z = ZoneLabels_Define("Dun Modr", 40)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Modr_Ent)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Modr_West)
        call ZoneLabels_AddRect(z, gg_rct_Dun_Modr_Thass)
    endfunction

    private function ZoneLabels_DisableLegacyLabels takes nothing returns nothing
        // These 22 are label-only triggers in the supplied snapshot. In particular,
        // gg_trg_Gilneas_10 and gg_trg_Silverpine_2 are NOT on this list: they assign
        // revive areas and must remain active. Music and capture triggers stay active.
        call DisableTrigger(gg_trg_Tirisfal)
        call DisableTrigger(gg_trg_Silverpine)
        call DisableTrigger(gg_trg_Gilneas)
        call DisableTrigger(gg_trg_Hillsbrad)
        call DisableTrigger(gg_trg_Tol_Barad)
        call DisableTrigger(gg_trg_Arathi_Highlands)
        call DisableTrigger(gg_trg_Hinterlands)
        call DisableTrigger(gg_trg_Alterac_Mountains)
        call DisableTrigger(gg_trg_Wetlands)
        call DisableTrigger(gg_trg_Eversong_Woods)
        call DisableTrigger(gg_trg_Scholomance)
        call DisableTrigger(gg_trg_Dalaran)
        call DisableTrigger(gg_trg_Crystalsong_Forest)
        call DisableTrigger(gg_trg_Icecrown)
        call DisableTrigger(gg_trg_Dragonblight)
        call DisableTrigger(gg_trg_Scarlet_Onslaught)
        call DisableTrigger(gg_trg_Grizzly_Hills)
        call DisableTrigger(gg_trg_Zul_Drak)
        call DisableTrigger(gg_trg_Argent_Tournament)
        call DisableTrigger(gg_trg_Azjol_Nerub)
        call DisableTrigger(gg_trg_Ulduar)
        call DisableTrigger(gg_trg_Storm_Peaks)
    endfunction

    private function ZoneLabels_Start takes nothing returns nothing
        local timer clock = GetExpiredTimer()
        local trigger diagnostic = CreateTrigger()
        local integer playerID = 0
        local integer slot = 0
        // Runs after map startup, when editor rectangles and GUI triggers exist.
        call ZoneLabels_Configure()
        call ZoneLabels_DisableLegacyLabels()
        loop
            exitwhen playerID >= bj_MAX_PLAYER_SLOTS
            set slot = GetPlayerHeroNumber(Player(playerID))
            if slot >= 0 and slot <= 7 then
                // Invert the existing helper instead of duplicating its slot table.
                set ZoneLabels_Players[slot] = Player(playerID)
                call TriggerRegisterPlayerChatEvent(diagnostic, Player(playerID), "-zone", true)
            endif
            set playerID = playerID + 1
        endloop
        call TriggerAddAction(diagnostic, function ZoneLabels_Diagnose)
        call ZoneLabels_Update()
        // Reuse the one startup timer as the periodic timer.
        call TimerStart(clock, ZoneLabels_PERIOD, true, function ZoneLabels_Update)
        set diagnostic = null
        set clock = null
    endfunction

    private function ZoneLabels_Init takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.00, false, function ZoneLabels_Start)
    endfunction

endlibrary