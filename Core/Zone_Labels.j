// BATTLE FOR LORDAERON - ZONE LABELS + TRANSITIONS + MUSIC - revision 4
// Replace the ENTIRE existing ZoneLabels library with this file. JassHelper required.
// Requires the existing ZoneText and GenericFunctions libraries. No InitTrig wrapper.
// Keep the old GUI triggers. Startup suppresses ambient audio through conditions;
// Gilneas enable/disable flags and sanctuary entry effects remain functional.
// Death/revive, weather, quests, spawns, boss boundaries, and cinematics stay separate.
// Based on the fresh 5 October export and your latest 75-group/220-binding source.
// 215 stable label rectangles + all 46 transitions; 94 ambient playback policies.
// -zone reports label/place/transition/music provenance. Numeric suffixes are not policy.
// Uncovered gaps retain state. Remote transition arrivals choose local explicit anchors.
// Cinematic mute mode is deferred. Existing quest/scene playback remains active.
// Two places with no old ambient policy (Kul Tiras/Deadwind Pass) retain existing audio.
// Music uses the original call sequences, not a newly invented playlist format.

library ZoneLabels initializer ZoneLabels_Init requires ZoneText, GenericFunctions

    globals
        private constant real ZoneLabels_PERIOD = 0.25
        // A jump this large in one sample invalidates local transition continuity.
        private constant real ZoneLabels_REMOTE_DISTANCE = 1536.0
        private constant string ZoneLabels_UNMAPPED_TEXT = ""
        private integer ZoneLabels_Count = 0
        private region array ZoneLabels_Areas
        private string array ZoneLabels_Names
        private integer array ZoneLabels_Priorities
        private hashtable ZoneLabels_Index = null
        private integer ZoneLabels_PlaceCount = 0
        private region array ZoneLabels_PlaceArea
        private rect array ZoneLabels_PlaceRect
        private integer array ZoneLabels_PlaceZone
        private string array ZoneLabels_PlaceName
        private integer array ZoneLabels_PlaceMusic
        private boolean array ZoneLabels_PlaceCore
        private real array ZoneLabels_PlaceSize
        private integer ZoneLabels_TransitionCount = 0
        private region array ZoneLabels_TransitionArea
        private string array ZoneLabels_TransitionName
        private integer array ZoneLabels_TransitionPriority
        private boolean array ZoneLabels_TransitionBuffer
        private integer array ZoneLabels_AnchorFirst
        private integer array ZoneLabels_AnchorLast
        private integer ZoneLabels_AnchorCount = 0
        private integer array ZoneLabels_AnchorPlace
        private string array ZoneLabels_MusicKey
        private integer array ZoneLabels_MusicFamily
        private player array ZoneLabels_Players
        private unit array ZoneLabels_LastSubject
        private real array ZoneLabels_LastX
        private real array ZoneLabels_LastY
        private integer array ZoneLabels_LastZone
        private integer array ZoneLabels_LastPlace
        private integer array ZoneLabels_LastMusicPlace
        private integer array ZoneLabels_LastRawMusic
        private integer array ZoneLabels_LabelTransition
        private integer array ZoneLabels_MusicTransition
        private integer array ZoneLabels_ActiveTransition
        private integer array ZoneLabels_AppliedMusic
        private integer array ZoneLabels_AppliedFlavor
        private string array ZoneLabels_LegacyMirror
        private boolean array ZoneLabels_ForeignMusic
        private string array ZoneLabels_LabelReason
        private string array ZoneLabels_MusicReason
        private boolean array ZoneLabels_CacheValid
        private boolean array ZoneLabels_Relocated
        private constant integer ZM_Undercity = 1
        private constant integer ZM_Tirisfal_Glades = 2
        private constant integer ZM_Deathknell = 3
        private constant integer ZM_Dalaran_Enter = 4
        private constant integer ZM_Lights_Hope = 5
        private constant integer ZM_Vermillion_Redoubt = 6
        private constant integer ZM_ChromieInn = 7
        private constant integer ZM_HearthGlen = 8
        private constant integer ZM_Valshara = 9
        private constant integer ZM_TarrenMill = 10
        private constant integer ZM_SilverPine_M = 11
        private constant integer ZM_Skittering_Dark_M = 12
        private constant integer ZM_Shadowfang_Keep_M = 13
        private constant integer ZM_Gilneas_City_Classical = 14
        private constant integer ZM_Gilneas_City_Battle_Music = 15
        private constant integer ZM_Pyrewood = 16
        private constant integer ZM_Gilneas_Chapel = 17
        private constant integer ZM_Tempest_Reach = 18
        private constant integer ZM_Battle_for_Gilneas = 19
        private constant integer ZM_The_WitchWood = 20
        private constant integer ZM_EmberstoneMine = 21
        private constant integer ZM_Scholomance_M = 22
        private constant integer ZM_Uthers_Grave_M = 23
        private constant integer ZM_Naxxramas_M = 24
        private constant integer ZM_Andorhal_M = 25
        private constant integer ZM_Western_Plaguelands_M = 26
        private constant integer ZM_Eastern_Plaguelands_M = 27
        private constant integer ZM_Stratholme_M = 28
        private constant integer ZM_KelThuzad_M = 29
        private constant integer ZM_GY_WP_M = 30
        private constant integer ZM_Venomweb_Vale_M = 31
        private constant integer ZM_Hinterlands_M = 32
        private constant integer ZM_TolBarad_M = 33
        private constant integer ZM_Hillsbrad_M = 34
        private constant integer ZM_Arathi_M = 35
        private constant integer ZM_Grizzly_Hills_M = 36
        private constant integer ZM_Utguarde_Hrydshal_M = 37
        private constant integer ZM_Lich_King_M = 38
        private constant integer ZM_Ice_Crown_M = 39
        private constant integer ZM_HowlingFjord_M = 40
        private constant integer ZM_Blue_Dragon_Island_M = 41
        private constant integer ZM_Dragonblight_M = 42
        private constant integer ZM_Agmars_Hammer_M = 43
        private constant integer ZM_Zul_Drak_M = 44
        private constant integer ZM_Storm_Peaks_M = 45
        private constant integer ZM_Argent_Tournament_M = 46
        private constant integer ZM_Crystalsong_M = 47
        private constant integer ZM_Azjol_Nerub_M = 48
        private constant integer ZM_Ulduar_M = 49
        private constant integer ZM_Hinterlands_Troll_M = 50
        private constant integer ZM_Jungle_Troll_M = 51
        private constant integer ZM_Zandalar_n_Zulaman_M = 52
        private constant integer ZM_Nazmir_M = 53
        private constant integer ZM_Silvermoon_M = 54
        private constant integer ZM_Sunwell_M = 55
        private constant integer ZM_Silvermoon_Ruins_M = 56
        private constant integer ZM_Eversong_Woods_M = 57
        private constant integer ZM_Ghostlands_M = 58
        private constant integer ZM_Windrunner_Spire_M = 59
        private constant integer ZM_Alterac_M = 60
        private constant integer ZM_VashJir_M = 61
        private constant integer ZM_StromGuarde_M = 62
        private constant integer ZM_Grim_Batol_M = 63
        private constant integer ZM_Wetlands_M = 64
        private constant integer ZM_Wetlands_Cave_M = 65
        private constant integer ZM_Greenwardens_Grove_M = 66
        private constant integer ZM_Loch_Modan_M = 67
        private constant integer ZM_Dun_Morogh_M = 68
        private constant integer ZM_Dun_Modr_M = 69
        private constant integer ZM_AeriePeak_M = 70
        private constant integer ZM_Bastion_of_Twilight = 71
        private constant integer ZM_Twilight_Highlands_North = 72
        private constant integer ZM_Twilight_Highlands_South = 73
        private constant integer ZM_Goblin_Music = 74
        private constant integer ZM_Orc_Music_Dragonmaw_Port = 75
        private constant integer ZM_Highbank = 76
        private constant integer ZM_Alterac_Keep_M = 77
        private constant integer ZM_Dwarf_Cave = 78
        private constant integer ZM_Syndicate_Inn = 79
        private constant integer ZM_Balric = 80
        private constant integer ZM_Ogre_Konold_Sludge_Golem_Cave = 81
        private constant integer ZM_Cave_of_the_Elements = 82
        private constant integer ZM_Dalaran_Crater_M = 83
        private constant integer ZM_Night_Elf_Shaladnis_M = 84
        private constant integer ZM_Suramar_M = 85
        private constant integer ZM_Dark_Portal_Sargeras = 86
        private constant integer ZM_NelfarionsLair = 87
        private constant integer ZM_Vrykul_M = 88
        private constant integer ZM_Tuskar = 89
        private constant integer ZM_High_Mountain = 90
        private constant integer ZM_Stormheim = 91
        private constant integer ZM_RagnarosLair = 92
        private constant integer ZM_Karazhan = 93
        private constant integer ZM_Duel_Island = 94
    endglobals

    private function ZoneLabels_Define takes string name, integer priority returns integer
        set ZoneLabels_Count = ZoneLabels_Count + 1
        set ZoneLabels_Areas[ZoneLabels_Count] = CreateRegion()
        set ZoneLabels_Names[ZoneLabels_Count] = name
        set ZoneLabels_Priorities[ZoneLabels_Count] = priority
        return ZoneLabels_Count
    endfunction

    private function ZoneLabels_AddRect takes integer z, rect r, string name returns nothing
        local integer a = ZoneLabels_PlaceCount + 1
        set ZoneLabels_PlaceCount = a
        set ZoneLabels_PlaceArea[a] = CreateRegion()
        call RegionAddRect(ZoneLabels_PlaceArea[a], r)
        call RegionAddRect(ZoneLabels_Areas[z], r)
        set ZoneLabels_PlaceRect[a] = r
        set ZoneLabels_PlaceZone[a] = z
        set ZoneLabels_PlaceName[a] = name
        set ZoneLabels_PlaceSize[a] = (GetRectMaxX(r) - GetRectMinX(r)) * (GetRectMaxY(r) - GetRectMinY(r))
        call SaveInteger(ZoneLabels_Index, GetHandleId(r), 0, a)
    endfunction

    private function ZoneLabels_BindMusic takes rect r, integer profile, boolean core returns nothing
        local integer a = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        if a != 0 then
            set ZoneLabels_PlaceMusic[a] = profile
            set ZoneLabels_PlaceCore[a] = core
        endif
    endfunction

    private function ZoneLabels_AddTransition takes rect r, string name, integer priority, boolean buffer returns integer
        local integer t = ZoneLabels_TransitionCount + 1
        set ZoneLabels_TransitionCount = t
        set ZoneLabels_TransitionArea[t] = CreateRegion()
        call RegionAddRect(ZoneLabels_TransitionArea[t], r)
        set ZoneLabels_TransitionName[t] = name
        set ZoneLabels_TransitionPriority[t] = priority
        set ZoneLabels_TransitionBuffer[t] = buffer
        set ZoneLabels_AnchorFirst[t] = ZoneLabels_AnchorCount + 1
        set ZoneLabels_AnchorLast[t] = ZoneLabels_AnchorCount
        return t
    endfunction

    private function ZoneLabels_AddAnchor takes integer t, rect r returns nothing
        set ZoneLabels_AnchorCount = ZoneLabels_AnchorCount + 1
        set ZoneLabels_AnchorPlace[ZoneLabels_AnchorCount] = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        set ZoneLabels_AnchorLast[t] = ZoneLabels_AnchorCount
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

    private function ZoneLabels_LabelPlace takes integer z, real x, real y returns integer
        local integer a = 1
        local integer best = 0
        loop
            exitwhen a > ZoneLabels_PlaceCount
            if ZoneLabels_PlaceZone[a] == z and IsPointInRegion(ZoneLabels_PlaceArea[a], x, y) then
                if best == 0 then
                    set best = a
                elseif ZoneLabels_PlaceCore[a] and not ZoneLabels_PlaceCore[best] then
                    set best = a
                elseif ZoneLabels_PlaceCore[a] == ZoneLabels_PlaceCore[best] and ZoneLabels_PlaceSize[a] < ZoneLabels_PlaceSize[best] then
                    set best = a
                endif
            endif
            set a = a + 1
        endloop
        return best
    endfunction

    private function ZoneLabels_NormalMusicPlace takes real x, real y returns integer
        local integer a = 1
        local integer best = 0
        local integer rank = 0
        local integer bestRank = 0
        loop
            exitwhen a > ZoneLabels_PlaceCount
            if ZoneLabels_PlaceMusic[a] != 0 and IsPointInRegion(ZoneLabels_PlaceArea[a], x, y) then
                set rank = ZoneLabels_Priorities[ZoneLabels_PlaceZone[a]]
                if ZoneLabels_PlaceCore[a] then
                    set rank = rank + 1000
                endif
                if best == 0 or rank > bestRank then
                    set best = a
                    set bestRank = rank
                elseif rank == bestRank and ZoneLabels_PlaceSize[a] < ZoneLabels_PlaceSize[best] then
                    set best = a
                endif
            endif
            set a = a + 1
        endloop
        return best
    endfunction

    private function ZoneLabels_ResolveTransition takes real x, real y returns integer
        local integer t = 1
        local integer best = 0
        loop
            exitwhen t > ZoneLabels_TransitionCount
            if IsPointInRegion(ZoneLabels_TransitionArea[t], x, y) then
                if best == 0 or ZoneLabels_TransitionPriority[t] > ZoneLabels_TransitionPriority[best] then
                    set best = t
                endif
            endif
            set t = t + 1
        endloop
        return best
    endfunction

    private function ZoneLabels_Eligible takes integer t, integer a returns boolean
        local integer i = ZoneLabels_AnchorFirst[t]
        local integer other = 0
        if a == 0 or t == 0 then
            return false
        endif
        loop
            exitwhen i > ZoneLabels_AnchorLast[t]
            set other = ZoneLabels_AnchorPlace[i]
            // A profile is not geography: require the same curated label family too.
            // Equivalent nearby rectangles may retain state without listing every sliver.
            if other == a then
                return true
            endif
            if other != 0 and ZoneLabels_PlaceZone[other] == ZoneLabels_PlaceZone[a] and ZoneLabels_PlaceMusic[other] == ZoneLabels_PlaceMusic[a] then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    private function ZoneLabels_RectDistanceSquared takes rect r, real x, real y returns real
        local real dx = 0.0
        local real dy = 0.0
        if x < GetRectMinX(r) then
            set dx = GetRectMinX(r) - x
        elseif x > GetRectMaxX(r) then
            set dx = x - GetRectMaxX(r)
        endif
        if y < GetRectMinY(r) then
            set dy = GetRectMinY(r) - y
        elseif y > GetRectMaxY(r) then
            set dy = y - GetRectMaxY(r)
        endif
        return dx * dx + dy * dy
    endfunction

    private function ZoneLabels_Fallback takes integer t, real x, real y returns integer
        local integer i = ZoneLabels_AnchorFirst[t]
        local integer a = 0
        local integer best = 0
        local real distance = 0.0
        local real bestDistance = 0.0
        loop
            exitwhen i > ZoneLabels_AnchorLast[t]
            set a = ZoneLabels_AnchorPlace[i]
            if a != 0 then
                set distance = ZoneLabels_RectDistanceSquared(ZoneLabels_PlaceRect[a], x, y)
                if best == 0 or distance < bestDistance then
                    set best = a
                    set bestDistance = distance
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    private function ZoneLabels_TransitionPlace takes integer t, integer previous, integer oldTransition, boolean remote, real x, real y returns integer
        if not remote and previous != 0 then
            // Latch a local fallback instead of recomputing it around a midpoint.
            if t == oldTransition or ZoneLabels_Eligible(t, previous) then
                return previous
            endif
        endif
        return ZoneLabels_Fallback(t, x, y)
    endfunction

    private function ZoneLabels_Profile takes integer a returns integer
        local integer profile = ZoneLabels_PlaceMusic[a]
        if profile == ZM_Gilneas_City_Classical then
            if IsTriggerEnabled(gg_trg_Gilneas_City_Battle_Music) then
                return ZM_Gilneas_City_Battle_Music
            elseif not IsTriggerEnabled(gg_trg_Gilneas_City_Classical) then
                return 0
            endif
        endif
        return profile
    endfunction

    private function ZoneLabels_Flavor takes integer profile returns integer
        if profile == ZM_Gilneas_City_Classical then
            if GetOwningPlayer(gg_unit_ncop_1664) == Player(3) then
                return 1
            endif
            return 2
        endif
        return 0
    endfunction

    private function ZoneLabels_TrackedSlot takes unit u returns integer
        local integer slot = 0
        if u == null then
            return 11
        endif
        loop
            exitwhen slot > 7
            if u == udg_Heroes[slot] or u == udg_FP_Bats_n_Gryphons[slot] then
                return slot
            endif
            set slot = slot + 1
        endloop
        return 11
    endfunction

    // Optional future teleport hooks can explicitly invalidate continuity.
    function ZoneLabelsNotifyRelocation takes player p returns nothing
        local integer slot = GetPlayerHeroNumber(p)
        if slot >= 0 and slot <= 7 then
            set ZoneLabels_Relocated[slot] = true
        endif
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

    private function ZoneLabels_ConfigureLabels takes nothing returns nothing
        local integer z = 0

        // Tirisfal Glades
        set z = ZoneLabels_Define("Tirisfal Glades", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_Glades_Soliden_Farm_0, "Tirisfal Glades Soliden Farm 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_Murloc_Coast_0, "Tirisfal Murloc Coast 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Trisfal_Glades_0, "Trisfal Glades 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_Tower_0, "Tirisfal South Tower 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Balnir_and_Bulwark_12, "Balnir and Bulwark 12")
        call ZoneLabels_AddRect(z, gg_rct_Z_DeathKnell_100, "DeathKnell 100")
        call ZoneLabels_AddRect(z, gg_rct_Z_Venomweb_Vale_12, "Venomweb Vale 12")
// Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Tirisfal_East_Transition_12
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_East_12, "Tirisfal South East 12")
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_Tower_Sliver_0, "Tirisfal South Tower Sliver 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Bulwark_12, "Bulwark 12")
        call ZoneLabels_AddRect(z, gg_rct_Z_Crusader_Output_Zone_12, "Crusader Output Zone 12")
        call ZoneLabels_AddRect(z, gg_rct_Z_Venomweb_Vale_East_12, "Venomweb Vale East 12")

        // Silverpine Forest
        // Deep_Elem_Mine is reached through SP_Mine_Ext in Silverpine. Shadowfang Keep retains the
        // existing Silverpine label. The Gilneas wall's Silverpine-side rectangle also
        // feeds the legacy Silverpine label and Horde revive trigger; include its label.
        set z = ZoneLabels_Define("Silverpine Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_2, "Silverpine 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_West_2, "Silverpine West 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_Fenris_Isles_2, "Silverpine Fenris Isles 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Skittering_Dark, "Skittering Dark")
        call ZoneLabels_AddRect(z, gg_rct_Z_Shadowfang_Keep, "Shadowfang Keep")
        call ZoneLabels_AddRect(z, gg_rct_Z_Pyrewood_Village, "Pyrewood Village")
        call ZoneLabels_AddRect(z, gg_rct_Z_Deep_Elem_Mine, "Deep Elem Mine")
        call ZoneLabels_AddRect(z, gg_rct_SP_Mine_Int, "SP Mine Int")
        call ZoneLabels_AddRect(z, gg_rct_Skittering_Dark_Cave_Ext, "Skittering Dark Cave Ext")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ambermill_Cave, "Ambermill Cave")
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Silverpine, "South Silverpine")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2, "Gilneas Wall Silverpine Side GY Trigger 2")

        // Gilneas
        // Ownership affects revives, not this label. Cathedral_North includes the chapel doorway
        // just outside Gilneas_Chapel. No Genn/Nathanos or graveyard logic is changed. Priority 20
        // makes the named Gilneas geography win over broader terrain if rectangles are extended
        // later.
        set z = ZoneLabels_Define("Gilneas", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_City, "Gilneas City")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Wall, "Gilneas Wall")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Chapel, "Gilneas Chapel")
        call ZoneLabels_AddRect(z, gg_rct_Cathedral_North, "Cathedral North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gil_Mine_Lumber, "Gil Mine Lumber")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Tol_Barad_Entrance, "Gilneas Tol Barad Entrance")
        call ZoneLabels_AddRect(z, gg_rct_Z_Greymane_Manor, "Greymane Manor")
        call ZoneLabels_AddRect(z, gg_rct_Z_Tempest_Reach, "Tempest Reach")
        call ZoneLabels_AddRect(z, gg_rct_Z_Duskhaven_Battle_Music, "Duskhaven Battle Music")
        call ZoneLabels_AddRect(z, gg_rct_Z_The_WitchWood, "The WitchWood")
        call ZoneLabels_AddRect(z, gg_rct_Z_Emberstone_Mine, "Emberstone Mine")
        call ZoneLabels_AddRect(z, gg_rct_Emberstone_Int, "Emberstone Int")

        // Hillsbrad
        // Azurelode is connected to Hillsbrad by Azurelode_Mine_Ext. The Kobold_Cave interior
        // below has entrances from both Hillsbrad and the Hinterlands path, so it has its own
        // label.
        set z = ZoneLabels_Define("Hillsbrad", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tarren_Mill_Music_3, "Tarren Mill Music 3")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Foothills_3, "Hillsbrad Foothills 3")
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Hillsbrad_3, "South Hillsbrad 3")
// Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_North_Hillsbrad_Transition_3
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Foothills_E_3, "Hillsbrad Foothills E 3")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_Crater_3, "Dalaran Crater 3")
        call ZoneLabels_AddRect(z, gg_rct_Z_Azurelode_Mine, "Azurelode Mine")
        call ZoneLabels_AddRect(z, gg_rct_Azurelode_Mine_Int, "Azurelode Mine Int")
        call ZoneLabels_AddRect(z, gg_rct_Z_South_East_Hillsbrad_3, "South East Hillsbrad 3")

        // Tol Barad
        set z = ZoneLabels_Define("Tol Barad", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tol_Barad_17, "Tol Barad 17")

        // Arathi Highlands
        // Ogre_Mine_Ext and the two ElementalCave entrances connect these interiors to Arathi.
        // Stromgarde Harbor wins its overlap with SouthHillsbrad.
        set z = ZoneLabels_Define("Arathi Highlands", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Starting_Zone_100, "Arathi Starting Zone 100")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Starting_Zone_S_100, "Arathi Starting Zone S 100")
// Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Arathi_Starting_Transition_100
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Passage_1, "Arathi Passage 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_North_1, "Arathi North 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_North_Graveyard_1, "Arathi North Graveyard 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_East_1, "Arathi East 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_West_1, "Arathi West 1")
// Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Hillsbrad_to_Arathi_Transition
        call ZoneLabels_AddRect(z, gg_rct_Z_StromGarde_1, "StromGarde 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_StromGarde_Harbor_1, "StromGarde Harbor 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Ogres_Boss, "Arathi Ogres Boss")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ogre_Cave_Music, "Ogre Cave Music")
        call ZoneLabels_AddRect(z, gg_rct_Z_ElementalCave, "ElementalCave")
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_North, "Kobold Cave North")
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_South, "Kobold Cave South")

        // Hinterlands
        // The secret path wins its overlap with eastern Hillsbrad. SecretPathCave uses the
        // Hints_Cave_South entrance. The water cave uses HintWaterCaveWest/East. Sharing cave
        // music does not merge their labels with the Arathi caves.
        set z = ZoneLabels_Define("Hinterlands", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_2, "Hinterlands 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Secret_Path_2, "Hinterlands Secret Path 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Troll_Enclave_2, "Hinterlands Troll Enclave 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Troll_Boss_2, "Hinterlands Troll Boss 2")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Seaside_2_or_8, "Hinterlands Seaside 2 or 8")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Moonlight, "Hinterlands Moonlight")
        call ZoneLabels_AddRect(z, gg_rct_Z_Revantusk_8, "Revantusk 8")
        call ZoneLabels_AddRect(z, gg_rct_Z_Aerie_Peak, "Aerie Peak")
        call ZoneLabels_AddRect(z, gg_rct_Z_SecretPathCave, "SecretPathCave")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Dwarf_Cave_2, "Hinterlands Dwarf Cave 2")
        call ZoneLabels_AddRect(z, gg_rct_Hint_Pass_Nor, "Hint Pass Nor")

        // Alterac
        // Alterac_4_SW wins its overlap with North_Hillsbrad_3.
        set z = ZoneLabels_Define("Alterac", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_4, "Alterac 4")
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_4_SW, "Alterac 4 SW")
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_North, "Alterac North")

        // Alterac Keep; the detached keep is connected by Alterac_Int/Ext.
        set z = ZoneLabels_Define("Alterac Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_Keep, "Alterac Keep")

        // Syndicate Inn; Syndicate_Indoors connects it to Alterac_North.
        set z = ZoneLabels_Define("Syndicate Inn", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Syndacite_Inn, "Syndacite Inn")

        // Wetlands
        set z = ZoneLabels_Define("Wetlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_13, "Wetlands 13")
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_Bordering_Grim_Batol, "Wetlands Bordering Grim Batol")
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_Coast, "Wetlands Coast")
        call ZoneLabels_AddRect(z, gg_rct_Z_Greenwardens_Grove, "Greenwardens Grove")
        call ZoneLabels_AddRect(z, gg_rct_Z_Sludge_Cave_Wetlands, "Sludge Cave Wetlands")
        call ZoneLabels_AddRect(z, gg_rct_Sludge_Cave, "Sludge Cave")
        call ZoneLabels_AddRect(z, gg_rct_SludgeCave_Int, "SludgeCave Int")

        // Eversong Woods
        set z = ZoneLabels_Define("Eversong Woods", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Woods_1, "Eversong Woods 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Murlocs_1, "Eversong Murlocs 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Eversong_1, "South Eversong 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Eversong_Sliver_1, "South Eversong Sliver 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Sunstrider_Isle_101, "Sunstrider Isle 101")
        call ZoneLabels_AddRect(z, gg_rct_Z_Silvermoon_Ruins_1, "Silvermoon Ruins 1")
        call ZoneLabels_AddRect(z, gg_rct_Z_Torwatha, "Torwatha")
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Murlocs_EW, "Eversong Murlocs EW")
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Pheonix, "Eversong Pheonix")

        // Shalandis Isle
        set z = ZoneLabels_Define("Shalandis Isle", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Shalandis_Isle, "Shalandis Isle")

        // Ghostlands
        // The Amani catacombs connect through Amani_North/South_Ext in Ghostlands. They are not
        // assigned to Zandalar merely because the music trigger groups them together.
        set z = ZoneLabels_Define("Ghostlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Center, "Ghostlands Center")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_South, "Ghostlands South")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_West, "Ghostlands West")
        call ZoneLabels_AddRect(z, gg_rct_Z_Deatholme, "Deatholme")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dawnstar_Spire, "Dawnstar Spire")
        call ZoneLabels_AddRect(z, gg_rct_Z_Windrunner_Spire, "Windrunner Spire")
        call ZoneLabels_AddRect(z, gg_rct_Z_Amani_Catacombs, "Amani Catacombs")
        call ZoneLabels_AddRect(z, gg_rct_Amani_North_Int, "Amani North Int")
        call ZoneLabels_AddRect(z, gg_rct_Amani_South_Int, "Amani South Int")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Lake, "Ghostlands Lake")
        call ZoneLabels_AddRect(z, gg_rct_Z_Deadscar_Ghostlands_North, "Deadscar Ghostlands North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Far_North, "Ghostlands Far North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Goldenmist_Village_North, "Goldenmist Village North")

        // Western Plaguelands
        // Weeping_Cave_Mine_Entrance is in Western Plaguelands.
        set z = ZoneLabels_Define("Western Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_5, "Western Plaguelands 5")
// Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_WP_Transition_5
        call ZoneLabels_AddRect(z, gg_rct_Z_Andorhal_5, "Andorhal 5")
        call ZoneLabels_AddRect(z, gg_rct_Z_MoonWell_WP, "MoonWell WP")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hearth_Glen, "Hearth Glen")
        call ZoneLabels_AddRect(z, gg_rct_Z_Uthers_Grave_Music, "Uthers Grave Music")
        call ZoneLabels_AddRect(z, gg_rct_Z_Weeping_Cave_WP, "Weeping Cave WP")
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_North_5, "Western Plaguelands North 5")
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_Dwarf_Farm_5, "Western Plaguelands Dwarf Farm 5")
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_East_5, "Western Plaguelands East 5")

        // Eastern Plaguelands
        // REVIEW PARENT: Cryptlord_Music is mostly INSIDE Eastern_Plaguelands_9. This follows that
        // geographical rectangle, despite the older music trigger being called GY WP M.
        set z = ZoneLabels_Define("Eastern Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eastern_Plaguelands_9, "Eastern Plaguelands 9")
        call ZoneLabels_AddRect(z, gg_rct_Z_Lights_Hope_9, "Lights Hope 9")
        call ZoneLabels_AddRect(z, gg_rct_Z_KT_Music_9, "KT Music 9")
        call ZoneLabels_AddRect(z, gg_rct_Z_Scarlet_Enclave_9, "Scarlet Enclave 9")
        call ZoneLabels_AddRect(z, gg_rct_Z_Eastern_Plaguelands_Tower_Graveyard_Music, "Eastern Plaguelands Tower Graveyard Music")

        // Dun Morogh
        set z = ZoneLabels_Define("Dun Morogh", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_Starting_101, "Dun Morogh Starting 101")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_0, "Dun Morogh 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_South, "Dun Morogh South")
        call ZoneLabels_AddRect(z, gg_rct_Z_Gnome_Cave_0, "Gnome Cave 0")

        // Loch Modan
        set z = ZoneLabels_Define("Loch Modan", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Loch_Modan_0, "Loch Modan 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Loch_Modan_Farstrider_Lodge_0, "Loch Modan Farstrider Lodge 0")

        // Twilight Highlands
        set z = ZoneLabels_Define("Twilight Highlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_North_14, "Twighlight Highlands North 14")
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_Delta, "Twighlight Highlands Delta")
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness, "Twighlight Highlands Maw Of Madness")
        call ZoneLabels_AddRect(z, gg_rct_Z_Obsdian_Forest, "Obsdian Forest")
        call ZoneLabels_AddRect(z, gg_rct_Z_Obsdian_Forest_Mini, "Obsdian Forest Mini")
        call ZoneLabels_AddRect(z, gg_rct_Z_Vemillion_Redoubt, "Vemillion Redoubt")
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_16, "Twighlight Highlands 16")

        // The Krazzworks
        set z = ZoneLabels_Define("The Krazzworks", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_The_Krazzworks, "The Krazzworks")

        // Dragonmaw Port
        set z = ZoneLabels_Define("Dragonmaw Port", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonmaw_Port_14, "Dragonmaw Port 14")

        // Highbank
        set z = ZoneLabels_Define("Highbank", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Highbank_14, "Highbank 14")

        // Howling Fjord
        set z = ZoneLabels_Define("Howling Fjord", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_East_7, "Howling Fjord East 7")
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_West_7, "Howling Fjord West 7")
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_Forsaken, "Howling Fjord Forsaken")
        call ZoneLabels_AddRect(z, gg_rct_Z_Sindragosa_Music, "Sindragosa Music")
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_Central, "Howling Fjord Central")

        // Grizzly Hills
        set z = ZoneLabels_Define("Grizzly Hills", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Grizzlemaw, "Grizzlemaw")
        call ZoneLabels_AddRect(z, gg_rct_Z_Grizzly_Hills_Amberpine, "Grizzly Hills Amberpine")

        // Zul'Drak
        set z = ZoneLabels_Define("Zul'Drak", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zul_Drak, "Zul Drak")
        call ZoneLabels_AddRect(z, gg_rct_Z_Zul_Drak_E, "Zul Drak E")

        // Dragonblight
        set z = ZoneLabels_Define("Dragonblight", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_North, "Dragonblight North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_Central, "Dragonblight Central")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_West, "Dragonblight West")
        call ZoneLabels_AddRect(z, gg_rct_Z_Agmars_Hammer, "Agmars Hammer")

        // Maoki Harbor
        set z = ZoneLabels_Define("Maoki Harbor", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Maoki_Harbor, "Maoki Harbor")

        // Icecrown
        set z = ZoneLabels_Define("Icecrown", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_Central, "Icecrown Central")
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_East, "Icecrown East")
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_South, "Icecrown South")
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_West, "Icecrown West")
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_Glacier, "Icecrown Glacier")

        // Crystalsong Forest
        set z = ZoneLabels_Define("Crystalsong Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_E, "Crystal Song E")
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_M, "Crystal Song M")
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_W, "Crystal Song W")

        // Storm Peaks
        // Takes precedence at the shared edge with Crystalsong Forest.
        set z = ZoneLabels_Define("Storm Peaks", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Storm_Peaks, "Storm Peaks")

        // Valsharah
        set z = ZoneLabels_Define("Valsharah", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Valsharah_11, "Valsharah 11")

        // Suramar
        set z = ZoneLabels_Define("Suramar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_North, "Suramar North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar, "Suramar")
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_Fel, "Suramar Fel")
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_South, "Suramar South")

        // Stormheim
        set z = ZoneLabels_Define("Stormheim", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Stormheim_South, "Stormheim South")
        call ZoneLabels_AddRect(z, gg_rct_Z_Stormheim_North, "Stormheim North")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hrydshal, "Hrydshal")
        call ZoneLabels_AddRect(z, gg_rct_Z_Hyrja_Island, "Hyrja Island")

        // High Mountain
        set z = ZoneLabels_Define("High Mountain", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_High_Mountain, "High Mountain")

        // Vashjir
        set z = ZoneLabels_Define("Vashjir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Vashjir_6, "Vashjir 6")

        // Kul Tiras
        // Uses the named landmass rectangle, not revive ID 6, which is also shared with Vashjir
        // and other locations.
        set z = ZoneLabels_Define("Kul Tiras", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_KulTiras_6, "KulTiras 6")

        // Zandalar
        set z = ZoneLabels_Define("Zandalar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zandalar_6, "Zandalar 6")

        // Nazmir
        set z = ZoneLabels_Define("Nazmir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Nazmir, "Nazmir")

        // Curated location labels take precedence over their broader parent labels.
        // Chillwind Camp
        set z = ZoneLabels_Define("Chillwind Camp", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Chillwind_Camp, "Chillwind Camp")

        // Light's Hope; this larger rectangle surrounds the older EP label area.
        // Sanctuary/PvP behavior stays in its existing system.
        set z = ZoneLabels_Define("Light's Hope", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Lights_Hope_Santuary, "Lights Hope Santuary")

        // Detached seal/penguin cave belongs to Howling Fjord; requested label is Northrend.
        set z = ZoneLabels_Define("Northrend", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Lots_O_Seels_n_Penwens_Music, "Lots O Seels n Penwens Music")

        // Combined zone/quest harbor rectangle; quest and cannon reset logic remain active.
        set z = ZoneLabels_Define("Stromgarde", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_and_Q_StromGarde_Inner_Harbor, "and Q StromGarde Inner Harbor")

        // Ghostlands Alliance GY is intentionally not a label area.
        // Thoradins_Wall_1 (formerly _Copy) remains deferred: fully inside the
        // Hillsbrad-to-Arathi transition, with no existing runtime consumers.

        // The Undercity
        set z = ZoneLabels_Define("The Undercity", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Undercity, "Undercity")

        // Silvermoon
        set z = ZoneLabels_Define("Silvermoon", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silvermoon, "Silvermoon")

        // Scarlet Monastery
        set z = ZoneLabels_Define("Scarlet Monastery", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Scarlet_Monastery_12, "Scarlet Monastery 12")

        // Scholomance
        set z = ZoneLabels_Define("Scholomance", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Scholomance_Music, "Scholomance Music")

        // Stratholme
        set z = ZoneLabels_Define("Stratholme", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Stratholme, "Stratholme")

        // Naxxramas
        // Wins the 32-unit strip shared with the Scholomance_Music rectangle.
        set z = ZoneLabels_Define("Naxxramas", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Naxxramas, "Naxxramas")

        // Dalaran
        set z = ZoneLabels_Define("Dalaran", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_City, "Dalaran City")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_Portal_Room, "Dalaran Portal Room")

        // Scarlet Onslaught
        set z = ZoneLabels_Define("Scarlet Onslaught", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_Scarlet_Onslaught, "Dragonblight Scarlet Onslaught")

        // Argent Tournament
        set z = ZoneLabels_Define("Argent Tournament", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Argent_Tournament, "Argent Tournament")

        // Azjol Nerub
        set z = ZoneLabels_Define("Azjol Nerub", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Azjol_Nerub, "Azjol Nerub")

        // Ulduar
        // Wins the 32-unit strip shared with Azjol_Nerub.
        set z = ZoneLabels_Define("Ulduar", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ulduar_Dungeon, "Ulduar Dungeon")

        // Utgarde Keep
        set z = ZoneLabels_Define("Utgarde Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Utguarde_Keep, "Utguarde Keep")

        // Zulaman
        set z = ZoneLabels_Define("Zul'Aman", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zulaman, "Zulaman")

        // Sunwell Plateau
        set z = ZoneLabels_Define("Sunwell Plateau", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Sunwell_Plateau, "Sunwell Plateau")

        // Bastion of Twilight
        set z = ZoneLabels_Define("Bastion of Twilight", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Bastion_of_Twilight_14, "Bastion of Twilight 14")
        call ZoneLabels_AddRect(z, gg_rct_Z_Bastion_of_Twilight_South, "Bastion of Twilight South")

        // Grim Batol
        // REVIEW NAME: current trigger Grim Batol M uses Ironforge_0. This label follows that
        // trigger name; the exported region still has its older Ironforge name.
        set z = ZoneLabels_Define("Grim Batol", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ironforge_0, "Ironforge 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Ironforge_Magni_0, "Ironforge Magni 0")

        // Grim Batol Volcano
        set z = ZoneLabels_Define("Grim Batol Volcano", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Grim_Batol_Volcano, "Grim Batol Volcano")

        // Karazhan
        set z = ZoneLabels_Define("Karazhan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Karazhan, "Karazhan")

        // Deadwind Pass
        set z = ZoneLabels_Define("Deadwind Pass", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Deadwind_Pass, "Deadwind Pass")

        // Neltharions Lair
        set z = ZoneLabels_Define("Neltharions Lair", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Nelfarions_Lair, "Nelfarions Lair")

        // Chromies Inn
        set z = ZoneLabels_Define("Chromies Inn", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_ChromieInn, "ChromieInn")

        // Blue Dragon Island
        set z = ZoneLabels_Define("Blue Dragon Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Blue_Dragon_Island, "Blue Dragon Island")

        // Kamuga Village
        set z = ZoneLabels_Define("Kamuga Village", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Kamuga_Village, "Kamuga Village")

        // Vrykul Island
        set z = ZoneLabels_Define("Vrykul Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Vrykul_Island, "Vrykul Island")

        // Tuskar Island
        set z = ZoneLabels_Define("Tuskar Island", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tuskar_Island, "Tuskar Island")

        // Warchiefs Cove
        set z = ZoneLabels_Define("Warchiefs Cove", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Warchiefs_Cove_6, "Warchiefs Cove 6")

        // Admirals Point
        set z = ZoneLabels_Define("Admirals Point", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Admirals_Point_6, "Admirals Point 6")

        // Dark Portal
        set z = ZoneLabels_Define("Dark Portal", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Broken_Isles_Dark_Portal, "Broken Isles Dark Portal")

        // Duel Island
        set z = ZoneLabels_Define("Duel Island", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Duel_Island, "Duel Island")

        // Kobold Cave
        // REVIEW LABEL: a connected cave with entrances at Cave_Mine_Exterior (Hillsbrad) and
        // Dwarf_Mine_Entrance (Hinterlands path). A distinct place name avoids guessing one parent
        // for the whole connected interior.
        set z = ZoneLabels_Define("Kobold Cave", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Kobold_Cave, "Kobold Cave")

        // Gnomeregan
        // REVIEW LABEL: connected to both Dun Morogh (DM_Mine_W) and Loch Modan (DM_Mine_E). Uses
        // a distinct interior name for now.
        set z = ZoneLabels_Define("Gnomeregan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dwarf_Cave_0, "Dwarf Cave 0")

        // Dun Morogh Pass
        // The detached passage is connected by the KZPass and DulAlgaz waygates.
        set z = ZoneLabels_Define("Dun Morogh Pass", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_Pass_0, "Dun Morogh Pass 0")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dwarf_Passasge, "Dwarf Passasge")

        // Dun Modr
        // Dun_Modr_Thass wins its overlap with the larger Ironforge_0 rectangle.
        set z = ZoneLabels_Define("Dun Modr", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_Ent, "Dun Modr Ent")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_West, "Dun Modr West")
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_Thass, "Dun Modr Thass")
    endfunction

    private function ZoneLabels_ConfigureMusic takes nothing returns nothing
        set ZoneLabels_MusicKey[ZM_Undercity] = "Undercity"
        set ZoneLabels_MusicFamily[ZM_Undercity] = 1
        call ZoneLabels_BindMusic(gg_rct_Z_Undercity, ZM_Undercity, true)

        set ZoneLabels_MusicKey[ZM_Tirisfal_Glades] = "Tirisfal"
        set ZoneLabels_MusicFamily[ZM_Tirisfal_Glades] = 2
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_Glades_Soliden_Farm_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_Murloc_Coast_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Trisfal_Glades_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_Tower_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Balnir_and_Bulwark_12, ZM_Tirisfal_Glades, false)

        set ZoneLabels_MusicKey[ZM_Deathknell] = "Deathknell"
        set ZoneLabels_MusicFamily[ZM_Deathknell] = 3
        call ZoneLabels_BindMusic(gg_rct_Z_DeathKnell_100, ZM_Deathknell, true)

        set ZoneLabels_MusicKey[ZM_Dalaran_Enter] = "Dalaran"
        set ZoneLabels_MusicFamily[ZM_Dalaran_Enter] = 4
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_City, ZM_Dalaran_Enter, true)

        set ZoneLabels_MusicKey[ZM_Lights_Hope] = "Lightshope"
        set ZoneLabels_MusicFamily[ZM_Lights_Hope] = 5
        call ZoneLabels_BindMusic(gg_rct_Z_Lights_Hope_9, ZM_Lights_Hope, true)

        set ZoneLabels_MusicKey[ZM_Vermillion_Redoubt] = "Vermillion Redoubt"
        set ZoneLabels_MusicFamily[ZM_Vermillion_Redoubt] = 6
        call ZoneLabels_BindMusic(gg_rct_Z_Vemillion_Redoubt, ZM_Vermillion_Redoubt, true)

        set ZoneLabels_MusicKey[ZM_ChromieInn] = "Chromie"
        set ZoneLabels_MusicFamily[ZM_ChromieInn] = 7
        call ZoneLabels_BindMusic(gg_rct_Z_ChromieInn, ZM_ChromieInn, true)

        set ZoneLabels_MusicKey[ZM_HearthGlen] = "Hearthglen"
        set ZoneLabels_MusicFamily[ZM_HearthGlen] = 8
        call ZoneLabels_BindMusic(gg_rct_Z_Hearth_Glen, ZM_HearthGlen, true)

        set ZoneLabels_MusicKey[ZM_Valshara] = "Valshara"
        set ZoneLabels_MusicFamily[ZM_Valshara] = 9
        call ZoneLabels_BindMusic(gg_rct_Z_Valsharah_11, ZM_Valshara, false)

        set ZoneLabels_MusicKey[ZM_TarrenMill] = "TarrenMill"
        set ZoneLabels_MusicFamily[ZM_TarrenMill] = 10
        call ZoneLabels_BindMusic(gg_rct_Z_Tarren_Mill_Music_3, ZM_TarrenMill, true)

        set ZoneLabels_MusicKey[ZM_SilverPine_M] = "Silverpine"
        set ZoneLabels_MusicFamily[ZM_SilverPine_M] = 11
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_West_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_Fenris_Isles_2, ZM_SilverPine_M, false)

        set ZoneLabels_MusicKey[ZM_Skittering_Dark_M] = "Skittering Dark"
        set ZoneLabels_MusicFamily[ZM_Skittering_Dark_M] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Skittering_Dark, ZM_Skittering_Dark_M, true)

        set ZoneLabels_MusicKey[ZM_Shadowfang_Keep_M] = "Shadowfang"
        set ZoneLabels_MusicFamily[ZM_Shadowfang_Keep_M] = 13
        call ZoneLabels_BindMusic(gg_rct_Z_Shadowfang_Keep, ZM_Shadowfang_Keep_M, true)

        set ZoneLabels_MusicKey[ZM_Gilneas_City_Classical] = "GilneasCityClassical"
        set ZoneLabels_MusicFamily[ZM_Gilneas_City_Classical] = 14
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_City, ZM_Gilneas_City_Classical, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Wall, ZM_Gilneas_City_Classical, true)

        set ZoneLabels_MusicKey[ZM_Gilneas_City_Battle_Music] = "GilneasCityBattle"
        set ZoneLabels_MusicFamily[ZM_Gilneas_City_Battle_Music] = 15

        set ZoneLabels_MusicKey[ZM_Pyrewood] = "Pyrewood"
        set ZoneLabels_MusicFamily[ZM_Pyrewood] = 16
        call ZoneLabels_BindMusic(gg_rct_Z_Pyrewood_Village, ZM_Pyrewood, true)

        set ZoneLabels_MusicKey[ZM_Gilneas_Chapel] = "GilneasChapel"
        set ZoneLabels_MusicFamily[ZM_Gilneas_Chapel] = 17
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Chapel, ZM_Gilneas_Chapel, true)

        set ZoneLabels_MusicKey[ZM_Tempest_Reach] = "TempestReach"
        set ZoneLabels_MusicFamily[ZM_Tempest_Reach] = 17
        call ZoneLabels_BindMusic(gg_rct_Z_Gil_Mine_Lumber, ZM_Tempest_Reach, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Tol_Barad_Entrance, ZM_Tempest_Reach, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Greymane_Manor, ZM_Tempest_Reach, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Tempest_Reach, ZM_Tempest_Reach, false)

        set ZoneLabels_MusicKey[ZM_Battle_for_Gilneas] = "GilneasGate"
        set ZoneLabels_MusicFamily[ZM_Battle_for_Gilneas] = 15
        call ZoneLabels_BindMusic(gg_rct_Z_Duskhaven_Battle_Music, ZM_Battle_for_Gilneas, true)

        set ZoneLabels_MusicKey[ZM_The_WitchWood] = "Witchwood"
        set ZoneLabels_MusicFamily[ZM_The_WitchWood] = 18
        call ZoneLabels_BindMusic(gg_rct_Z_The_WitchWood, ZM_The_WitchWood, true)

        set ZoneLabels_MusicKey[ZM_EmberstoneMine] = "Emberstone"
        set ZoneLabels_MusicFamily[ZM_EmberstoneMine] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Emberstone_Mine, ZM_EmberstoneMine, true)

        set ZoneLabels_MusicKey[ZM_Scholomance_M] = "Scholomance"
        set ZoneLabels_MusicFamily[ZM_Scholomance_M] = 19
        call ZoneLabels_BindMusic(gg_rct_Z_Scholomance_Music, ZM_Scholomance_M, true)

        set ZoneLabels_MusicKey[ZM_Uthers_Grave_M] = "Uthers Grave"
        set ZoneLabels_MusicFamily[ZM_Uthers_Grave_M] = 5
        call ZoneLabels_BindMusic(gg_rct_Z_Uthers_Grave_Music, ZM_Uthers_Grave_M, true)

        set ZoneLabels_MusicKey[ZM_Naxxramas_M] = "Naxxramas"
        set ZoneLabels_MusicFamily[ZM_Naxxramas_M] = 20
        call ZoneLabels_BindMusic(gg_rct_Z_Naxxramas, ZM_Naxxramas_M, true)

        set ZoneLabels_MusicKey[ZM_Andorhal_M] = "Andorhal"
        set ZoneLabels_MusicFamily[ZM_Andorhal_M] = 21
        call ZoneLabels_BindMusic(gg_rct_Z_Andorhal_5, ZM_Andorhal_M, true)

        set ZoneLabels_MusicKey[ZM_Western_Plaguelands_M] = "WesternPlaguelands"
        set ZoneLabels_MusicFamily[ZM_Western_Plaguelands_M] = 22
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_5, ZM_Western_Plaguelands_M, false)

        set ZoneLabels_MusicKey[ZM_Eastern_Plaguelands_M] = "Plaguelands"
        set ZoneLabels_MusicFamily[ZM_Eastern_Plaguelands_M] = 23
        call ZoneLabels_BindMusic(gg_rct_Z_Eastern_Plaguelands_9, ZM_Eastern_Plaguelands_M, false)

        set ZoneLabels_MusicKey[ZM_Stratholme_M] = "Stratholme"
        set ZoneLabels_MusicFamily[ZM_Stratholme_M] = 24
        call ZoneLabels_BindMusic(gg_rct_Z_Stratholme, ZM_Stratholme_M, true)

        set ZoneLabels_MusicKey[ZM_KelThuzad_M] = "KelThuzad"
        set ZoneLabels_MusicFamily[ZM_KelThuzad_M] = 25
        call ZoneLabels_BindMusic(gg_rct_Z_KT_Music_9, ZM_KelThuzad_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Scarlet_Enclave_9, ZM_KelThuzad_M, true)

        set ZoneLabels_MusicKey[ZM_GY_WP_M] = "GYWP"
        set ZoneLabels_MusicFamily[ZM_GY_WP_M] = 3
        call ZoneLabels_BindMusic(gg_rct_Z_Eastern_Plaguelands_Tower_Graveyard_Music, ZM_GY_WP_M, true)

        set ZoneLabels_MusicKey[ZM_Venomweb_Vale_M] = "VenomwebVale"
        set ZoneLabels_MusicFamily[ZM_Venomweb_Vale_M] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Venomweb_Vale_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Scarlet_Monastery_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Azurelode_Mine, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_SecretPathCave, ZM_Venomweb_Vale_M, true)

        set ZoneLabels_MusicKey[ZM_Hinterlands_M] = "Hinterlands"
        set ZoneLabels_MusicFamily[ZM_Hinterlands_M] = 26
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_2, ZM_Hinterlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Secret_Path_2, ZM_Hinterlands_M, false)

        set ZoneLabels_MusicKey[ZM_TolBarad_M] = "Tolbarad"
        set ZoneLabels_MusicFamily[ZM_TolBarad_M] = 15
        call ZoneLabels_BindMusic(gg_rct_Z_Tol_Barad_17, ZM_TolBarad_M, false)

        set ZoneLabels_MusicKey[ZM_Hillsbrad_M] = "Hillsbrad"
        set ZoneLabels_MusicFamily[ZM_Hillsbrad_M] = 27
        call ZoneLabels_BindMusic(gg_rct_Z_Hillsbrad_Foothills_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_South_Hillsbrad_3, ZM_Hillsbrad_M, false)

        set ZoneLabels_MusicKey[ZM_Arathi_M] = "Arathi"
        set ZoneLabels_MusicFamily[ZM_Arathi_M] = 28
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Starting_Zone_100, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Starting_Zone_S_100, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Passage_1, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_North_1, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_North_Graveyard_1, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_East_1, ZM_Arathi_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_West_1, ZM_Arathi_M, false)

        set ZoneLabels_MusicKey[ZM_Grizzly_Hills_M] = "Grizzly Hills"
        set ZoneLabels_MusicFamily[ZM_Grizzly_Hills_M] = 29
        call ZoneLabels_BindMusic(gg_rct_Z_Grizzlemaw, ZM_Grizzly_Hills_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Grizzly_Hills_Amberpine, ZM_Grizzly_Hills_M, false)

        set ZoneLabels_MusicKey[ZM_Utguarde_Hrydshal_M] = "Utguarde"
        set ZoneLabels_MusicFamily[ZM_Utguarde_Hrydshal_M] = 30
        call ZoneLabels_BindMusic(gg_rct_Z_Utguarde_Keep, ZM_Utguarde_Hrydshal_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hrydshal, ZM_Utguarde_Hrydshal_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hyrja_Island, ZM_Utguarde_Hrydshal_M, true)

        set ZoneLabels_MusicKey[ZM_Lich_King_M] = "LichKing"
        set ZoneLabels_MusicFamily[ZM_Lich_King_M] = 31
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_Glacier, ZM_Lich_King_M, true)

        set ZoneLabels_MusicKey[ZM_Ice_Crown_M] = "Ice Crown"
        set ZoneLabels_MusicFamily[ZM_Ice_Crown_M] = 32
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_Central, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_East, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_South, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_West, ZM_Ice_Crown_M, false)

        set ZoneLabels_MusicKey[ZM_HowlingFjord_M] = "HowlingFjord"
        set ZoneLabels_MusicFamily[ZM_HowlingFjord_M] = 33
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_East_7, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_West_7, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_Forsaken, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Sindragosa_Music, ZM_HowlingFjord_M, false)

        set ZoneLabels_MusicKey[ZM_Blue_Dragon_Island_M] = "BDIsland"
        set ZoneLabels_MusicFamily[ZM_Blue_Dragon_Island_M] = 26
        call ZoneLabels_BindMusic(gg_rct_Z_Blue_Dragon_Island, ZM_Blue_Dragon_Island_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Kamuga_Village, ZM_Blue_Dragon_Island_M, true)

        set ZoneLabels_MusicKey[ZM_Dragonblight_M] = "Dragonblight"
        set ZoneLabels_MusicFamily[ZM_Dragonblight_M] = 34
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_Scarlet_Onslaught, ZM_Dragonblight_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_Central, ZM_Dragonblight_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_North, ZM_Dragonblight_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_West, ZM_Dragonblight_M, false)

        set ZoneLabels_MusicKey[ZM_Agmars_Hammer_M] = "Agmars Hammer"
        set ZoneLabels_MusicFamily[ZM_Agmars_Hammer_M] = 35
        call ZoneLabels_BindMusic(gg_rct_Z_Agmars_Hammer, ZM_Agmars_Hammer_M, true)

        set ZoneLabels_MusicKey[ZM_Zul_Drak_M] = "Zul Drak"
        set ZoneLabels_MusicFamily[ZM_Zul_Drak_M] = 36
        call ZoneLabels_BindMusic(gg_rct_Z_Zul_Drak, ZM_Zul_Drak_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Zul_Drak_E, ZM_Zul_Drak_M, false)

        set ZoneLabels_MusicKey[ZM_Storm_Peaks_M] = "Storm Peaks"
        set ZoneLabels_MusicFamily[ZM_Storm_Peaks_M] = 37
        call ZoneLabels_BindMusic(gg_rct_Z_Storm_Peaks, ZM_Storm_Peaks_M, false)

        set ZoneLabels_MusicKey[ZM_Argent_Tournament_M] = "Argent Tournament"
        set ZoneLabels_MusicFamily[ZM_Argent_Tournament_M] = 38
        call ZoneLabels_BindMusic(gg_rct_Z_Argent_Tournament, ZM_Argent_Tournament_M, true)

        set ZoneLabels_MusicKey[ZM_Crystalsong_M] = "Crystalsong"
        set ZoneLabels_MusicFamily[ZM_Crystalsong_M] = 39
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_E, ZM_Crystalsong_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_M, ZM_Crystalsong_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_W, ZM_Crystalsong_M, false)

        set ZoneLabels_MusicKey[ZM_Azjol_Nerub_M] = "Azjol Nerub"
        set ZoneLabels_MusicFamily[ZM_Azjol_Nerub_M] = 40
        call ZoneLabels_BindMusic(gg_rct_Z_Azjol_Nerub, ZM_Azjol_Nerub_M, true)

        set ZoneLabels_MusicKey[ZM_Ulduar_M] = "Azjol Nerub"
        set ZoneLabels_MusicFamily[ZM_Ulduar_M] = 41
        call ZoneLabels_BindMusic(gg_rct_Z_Ulduar_Dungeon, ZM_Ulduar_M, true)

        set ZoneLabels_MusicKey[ZM_Hinterlands_Troll_M] = "HinterlandsTrolls"
        set ZoneLabels_MusicFamily[ZM_Hinterlands_Troll_M] = 42
        call ZoneLabels_BindMusic(gg_rct_Z_Revantusk_8, ZM_Hinterlands_Troll_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Troll_Boss_2, ZM_Hinterlands_Troll_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Troll_Enclave_2, ZM_Hinterlands_Troll_M, true)

        set ZoneLabels_MusicKey[ZM_Jungle_Troll_M] = "EversongTroll"
        set ZoneLabels_MusicFamily[ZM_Jungle_Troll_M] = 42
        call ZoneLabels_BindMusic(gg_rct_Z_Torwatha, ZM_Jungle_Troll_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Warchiefs_Cove_6, ZM_Jungle_Troll_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Admirals_Point_6, ZM_Jungle_Troll_M, true)

        set ZoneLabels_MusicKey[ZM_Zandalar_n_Zulaman_M] = "Zandalar"
        set ZoneLabels_MusicFamily[ZM_Zandalar_n_Zulaman_M] = 43
        call ZoneLabels_BindMusic(gg_rct_Z_Zandalar_6, ZM_Zandalar_n_Zulaman_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Zulaman, ZM_Zandalar_n_Zulaman_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Amani_Catacombs, ZM_Zandalar_n_Zulaman_M, true)

        set ZoneLabels_MusicKey[ZM_Nazmir_M] = "Nazmir"
        set ZoneLabels_MusicFamily[ZM_Nazmir_M] = 44
        call ZoneLabels_BindMusic(gg_rct_Z_Nazmir, ZM_Nazmir_M, true)

        set ZoneLabels_MusicKey[ZM_Silvermoon_M] = "Silvermoon"
        set ZoneLabels_MusicFamily[ZM_Silvermoon_M] = 45
        call ZoneLabels_BindMusic(gg_rct_Z_Silvermoon, ZM_Silvermoon_M, true)

        set ZoneLabels_MusicKey[ZM_Sunwell_M] = "Sunwell"
        set ZoneLabels_MusicFamily[ZM_Sunwell_M] = 46
        call ZoneLabels_BindMusic(gg_rct_Z_Sunwell_Plateau, ZM_Sunwell_M, true)

        set ZoneLabels_MusicKey[ZM_Silvermoon_Ruins_M] = "SilvermoonRuins"
        set ZoneLabels_MusicFamily[ZM_Silvermoon_Ruins_M] = 47
        call ZoneLabels_BindMusic(gg_rct_Z_Silvermoon_Ruins_1, ZM_Silvermoon_Ruins_M, true)

        set ZoneLabels_MusicKey[ZM_Eversong_Woods_M] = "EversongWoods"
        set ZoneLabels_MusicFamily[ZM_Eversong_Woods_M] = 48
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Woods_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_South_Eversong_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Sunstrider_Isle_101, ZM_Eversong_Woods_M, false)

        set ZoneLabels_MusicKey[ZM_Ghostlands_M] = "Ghostlands"
        set ZoneLabels_MusicFamily[ZM_Ghostlands_M] = 49
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Center, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_South, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Deatholme, ZM_Ghostlands_M, false)

        set ZoneLabels_MusicKey[ZM_Windrunner_Spire_M] = "Windrunner Spire"
        set ZoneLabels_MusicFamily[ZM_Windrunner_Spire_M] = 50
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_West, ZM_Windrunner_Spire_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dawnstar_Spire, ZM_Windrunner_Spire_M, true)

        set ZoneLabels_MusicKey[ZM_Alterac_M] = "Alterac"
        set ZoneLabels_MusicFamily[ZM_Alterac_M] = 51
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_4, ZM_Alterac_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_4_SW, ZM_Alterac_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_North, ZM_Alterac_M, false)

        set ZoneLabels_MusicKey[ZM_VashJir_M] = "Vashjir"
        set ZoneLabels_MusicFamily[ZM_VashJir_M] = 52
        call ZoneLabels_BindMusic(gg_rct_Z_Vashjir_6, ZM_VashJir_M, false)

        set ZoneLabels_MusicKey[ZM_StromGuarde_M] = "StromGuarde"
        set ZoneLabels_MusicFamily[ZM_StromGuarde_M] = 53
        call ZoneLabels_BindMusic(gg_rct_Z_StromGarde_1, ZM_StromGuarde_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_StromGarde_Harbor_1, ZM_StromGuarde_M, true)

        set ZoneLabels_MusicKey[ZM_Grim_Batol_M] = "GrimBatol"
        set ZoneLabels_MusicFamily[ZM_Grim_Batol_M] = 54
        call ZoneLabels_BindMusic(gg_rct_Z_Ironforge_0, ZM_Grim_Batol_M, true)

        set ZoneLabels_MusicKey[ZM_Wetlands_M] = "Wetlands"
        set ZoneLabels_MusicFamily[ZM_Wetlands_M] = 55
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_13, ZM_Wetlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_Bordering_Grim_Batol, ZM_Wetlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_Coast, ZM_Wetlands_M, false)

        set ZoneLabels_MusicKey[ZM_Wetlands_Cave_M] = "Sludge Cave Wetlands"
        set ZoneLabels_MusicFamily[ZM_Wetlands_Cave_M] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Sludge_Cave_Wetlands, ZM_Wetlands_Cave_M, true)

        set ZoneLabels_MusicKey[ZM_Greenwardens_Grove_M] = "Greenwardens"
        set ZoneLabels_MusicFamily[ZM_Greenwardens_Grove_M] = 56
        call ZoneLabels_BindMusic(gg_rct_Z_Greenwardens_Grove, ZM_Greenwardens_Grove_M, true)

        set ZoneLabels_MusicKey[ZM_Loch_Modan_M] = "Hillsbrad"
        set ZoneLabels_MusicFamily[ZM_Loch_Modan_M] = 27
        call ZoneLabels_BindMusic(gg_rct_Z_Loch_Modan_0, ZM_Loch_Modan_M, false)

        set ZoneLabels_MusicKey[ZM_Dun_Morogh_M] = "Dun Morogh"
        set ZoneLabels_MusicFamily[ZM_Dun_Morogh_M] = 57
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_Starting_101, ZM_Dun_Morogh_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_0, ZM_Dun_Morogh_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_South, ZM_Dun_Morogh_M, false)

        set ZoneLabels_MusicKey[ZM_Dun_Modr_M] = "Dwarf Cave"
        set ZoneLabels_MusicFamily[ZM_Dun_Modr_M] = 58
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_Ent, ZM_Dun_Modr_M, true)

        set ZoneLabels_MusicKey[ZM_AeriePeak_M] = "AeriePeak"
        set ZoneLabels_MusicFamily[ZM_AeriePeak_M] = 54
        call ZoneLabels_BindMusic(gg_rct_Z_Aerie_Peak, ZM_AeriePeak_M, true)

        set ZoneLabels_MusicKey[ZM_Bastion_of_Twilight] = "Bastion of Twilight"
        set ZoneLabels_MusicFamily[ZM_Bastion_of_Twilight] = 59
        call ZoneLabels_BindMusic(gg_rct_Z_Bastion_of_Twilight_14, ZM_Bastion_of_Twilight, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Bastion_of_Twilight_South, ZM_Bastion_of_Twilight, true)

        set ZoneLabels_MusicKey[ZM_Twilight_Highlands_North] = "Twilight Highlands North"
        set ZoneLabels_MusicFamily[ZM_Twilight_Highlands_North] = 60
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_North_14, ZM_Twilight_Highlands_North, false)

        set ZoneLabels_MusicKey[ZM_Twilight_Highlands_South] = "TWHS"
        set ZoneLabels_MusicFamily[ZM_Twilight_Highlands_South] = 61
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_Delta, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Obsdian_Forest, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Obsdian_Forest_Mini, ZM_Twilight_Highlands_South, false)

        set ZoneLabels_MusicKey[ZM_Goblin_Music] = "Goblin"
        set ZoneLabels_MusicFamily[ZM_Goblin_Music] = 62
        call ZoneLabels_BindMusic(gg_rct_Z_The_Krazzworks, ZM_Goblin_Music, true)

        set ZoneLabels_MusicKey[ZM_Orc_Music_Dragonmaw_Port] = "Orc Music"
        set ZoneLabels_MusicFamily[ZM_Orc_Music_Dragonmaw_Port] = 63
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonmaw_Port_14, ZM_Orc_Music_Dragonmaw_Port, true)

        set ZoneLabels_MusicKey[ZM_Highbank] = "Highbank"
        set ZoneLabels_MusicFamily[ZM_Highbank] = 64
        call ZoneLabels_BindMusic(gg_rct_Z_Highbank_14, ZM_Highbank, true)

        set ZoneLabels_MusicKey[ZM_Alterac_Keep_M] = "Alterac Keep"
        set ZoneLabels_MusicFamily[ZM_Alterac_Keep_M] = 65
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_Keep, ZM_Alterac_Keep_M, true)

        set ZoneLabels_MusicKey[ZM_Dwarf_Cave] = "Dwarf Cave"
        set ZoneLabels_MusicFamily[ZM_Dwarf_Cave] = 66
        call ZoneLabels_BindMusic(gg_rct_Z_Dwarf_Cave_0, ZM_Dwarf_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dwarf_Passasge, ZM_Dwarf_Cave, true)

        set ZoneLabels_MusicKey[ZM_Syndicate_Inn] = "SyndicateInn"
        set ZoneLabels_MusicFamily[ZM_Syndicate_Inn] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Syndacite_Inn, ZM_Syndicate_Inn, true)

        set ZoneLabels_MusicKey[ZM_Balric] = "Balric"
        set ZoneLabels_MusicFamily[ZM_Balric] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Ogres_Boss, ZM_Balric, true)

        set ZoneLabels_MusicKey[ZM_Ogre_Konold_Sludge_Golem_Cave] = "Caves"
        set ZoneLabels_MusicFamily[ZM_Ogre_Konold_Sludge_Golem_Cave] = 12
        call ZoneLabels_BindMusic(gg_rct_Z_Ogre_Cave_Music, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Kobold_Cave, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Weeping_Cave_WP, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Dwarf_Cave_2, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        set ZoneLabels_MusicKey[ZM_Cave_of_the_Elements] = "Deepholm"
        set ZoneLabels_MusicFamily[ZM_Cave_of_the_Elements] = 67
        call ZoneLabels_BindMusic(gg_rct_Z_ElementalCave, ZM_Cave_of_the_Elements, true)

        set ZoneLabels_MusicKey[ZM_Dalaran_Crater_M] = "DalaranCrater"
        set ZoneLabels_MusicFamily[ZM_Dalaran_Crater_M] = 68
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_Crater_3, ZM_Dalaran_Crater_M, true)

        set ZoneLabels_MusicKey[ZM_Night_Elf_Shaladnis_M] = "Moonwell"
        set ZoneLabels_MusicFamily[ZM_Night_Elf_Shaladnis_M] = 69
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Moonlight, ZM_Night_Elf_Shaladnis_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_MoonWell_WP, ZM_Night_Elf_Shaladnis_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Shalandis_Isle, ZM_Night_Elf_Shaladnis_M, true)

        set ZoneLabels_MusicKey[ZM_Suramar_M] = "Suramar"
        set ZoneLabels_MusicFamily[ZM_Suramar_M] = 70
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_North, ZM_Suramar_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar, ZM_Suramar_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_Fel, ZM_Suramar_M, false)

        set ZoneLabels_MusicKey[ZM_Dark_Portal_Sargeras] = "Sargeras"
        set ZoneLabels_MusicFamily[ZM_Dark_Portal_Sargeras] = 71
        call ZoneLabels_BindMusic(gg_rct_Z_Broken_Isles_Dark_Portal, ZM_Dark_Portal_Sargeras, true)

        set ZoneLabels_MusicKey[ZM_NelfarionsLair] = "Twilight"
        set ZoneLabels_MusicFamily[ZM_NelfarionsLair] = 72
        call ZoneLabels_BindMusic(gg_rct_Z_Nelfarions_Lair, ZM_NelfarionsLair, true)

        set ZoneLabels_MusicKey[ZM_Vrykul_M] = "Vrykul"
        set ZoneLabels_MusicFamily[ZM_Vrykul_M] = 73
        call ZoneLabels_BindMusic(gg_rct_Z_Vrykul_Island, ZM_Vrykul_M, true)

        set ZoneLabels_MusicKey[ZM_Tuskar] = "Tuskar"
        set ZoneLabels_MusicFamily[ZM_Tuskar] = 74
        call ZoneLabels_BindMusic(gg_rct_Z_Tuskar_Island, ZM_Tuskar, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Maoki_Harbor, ZM_Tuskar, true)

        set ZoneLabels_MusicKey[ZM_High_Mountain] = "Valshara"
        set ZoneLabels_MusicFamily[ZM_High_Mountain] = 9
        call ZoneLabels_BindMusic(gg_rct_Z_High_Mountain, ZM_High_Mountain, false)

        set ZoneLabels_MusicKey[ZM_Stormheim] = "Stormheim"
        set ZoneLabels_MusicFamily[ZM_Stormheim] = 75
        call ZoneLabels_BindMusic(gg_rct_Z_Stormheim_South, ZM_Stormheim, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Stormheim_North, ZM_Stormheim, false)

        set ZoneLabels_MusicKey[ZM_RagnarosLair] = "Ragnaros"
        set ZoneLabels_MusicFamily[ZM_RagnarosLair] = 76
        call ZoneLabels_BindMusic(gg_rct_Z_Grim_Batol_Volcano, ZM_RagnarosLair, true)

        set ZoneLabels_MusicKey[ZM_Karazhan] = "Karazhan"
        set ZoneLabels_MusicFamily[ZM_Karazhan] = 77
        call ZoneLabels_BindMusic(gg_rct_Z_Karazhan, ZM_Karazhan, true)

        set ZoneLabels_MusicKey[ZM_Duel_Island] = "Duel Island"
        set ZoneLabels_MusicFamily[ZM_Duel_Island] = 78
        call ZoneLabels_BindMusic(gg_rct_Z_Duel_Island, ZM_Duel_Island, true)

        // Curated coverage / doorway defaults. These are easy to change independently.
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_East_12, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_Tower_Sliver_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Bulwark_12, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Crusader_Output_Zone_12, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Venomweb_Vale_East_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Deep_Elem_Mine, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindMusic(gg_rct_SP_Mine_Int, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindMusic(gg_rct_Skittering_Dark_Cave_Ext, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Ambermill_Cave, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_South_Silverpine, ZM_SilverPine_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindMusic(gg_rct_Cathedral_North, ZM_Gilneas_Chapel, true)
        call ZoneLabels_BindMusic(gg_rct_Emberstone_Int, ZM_EmberstoneMine, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hillsbrad_Foothills_E_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindMusic(gg_rct_Azurelode_Mine_Int, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_South_East_Hillsbrad_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindMusic(gg_rct_Kobold_Cave_North, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Kobold_Cave_South, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Seaside_2_or_8, ZM_Hinterlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Hint_Pass_Nor, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Sludge_Cave, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_SludgeCave_Int, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Murlocs_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_South_Eversong_Sliver_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Murlocs_EW, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Pheonix, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Windrunner_Spire, ZM_Windrunner_Spire_M, true)
        call ZoneLabels_BindMusic(gg_rct_Amani_North_Int, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Amani_South_Int, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Lake, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Deadscar_Ghostlands_North, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Far_North, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Goldenmist_Village_North, ZM_Ghostlands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_North_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_Dwarf_Farm_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_East_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Gnome_Cave_0, ZM_Dwarf_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Loch_Modan_Farstrider_Lodge_0, ZM_Loch_Modan_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_16, ZM_Twilight_Highlands_North, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_Central, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_South, ZM_Suramar_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Chillwind_Camp, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_BindMusic(gg_rct_Z_Lights_Hope_Santuary, ZM_Lights_Hope, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Lots_O_Seels_n_Penwens_Music, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_and_Q_StromGarde_Inner_Harbor, ZM_StromGuarde_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_Portal_Room, ZM_Dalaran_Enter, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Ironforge_Magni_0, ZM_Grim_Batol_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_Pass_0, ZM_Dwarf_Cave, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_West, ZM_Dun_Modr_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_Thass, ZM_Dun_Modr_M, true)
        // Kul Tiras and Deadwind Pass have no source ambient policy: music 0 retains audio.
    endfunction

    private function ZoneLabels_ConfigureTransitions takes nothing returns nothing
        local integer t = 0

        set t = ZoneLabels_AddTransition(gg_rct_Z_WP_Transition_5, "WP Transition 5", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Bulwark_12)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Western_Plaguelands_5)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Andorhal_5)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Arathi_Starting_Transition_100, "Arathi Starting Transition 100", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Starting_Zone_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Starting_Zone_S_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_North_1)

        set t = ZoneLabels_AddTransition(gg_rct_Z_North_Hillsbrad_Transition_3, "North Hillsbrad Transition 3", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_E_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tarren_Mill_Music_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dalaran_Crater_3)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Hillsbrad_to_Arathi_Transition, "Hillsbrad to Arathi Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_E_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_West_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_North_1)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tirisfal_East_Transition_12, "Tirisfal East Transition 12", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Trisfal_Glades_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crusader_Output_Zone_12)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Balnir_and_Bulwark_12)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tirisfal_South_East_12)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Scarlet_Monastery_12)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Venomweb_Vale_12)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Ghostlands_Transition, "Ghostlands Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Center)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_South)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Zulaman)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Dun_Morogh_to_Loch_Transition, "Dun Morogh to Loch Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dun_Morogh_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Loch_Modan_0)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Northrend_Stormpeaks_Zul_Drak_Draonglblight_and_Grizzly_Hills_Transition, "Northrend Stormpeaks Zul Drak Draonglblight and Grizzly Hills Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Storm_Peaks)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Zul_Drak)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dragonblight_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzlemaw)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzly_Hills_Amberpine)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tirisfal_Death_Knell_Transition, "Tirisfal Death Knell Transition", 30, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_DeathKnell_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tirisfal_South_Tower_0)

        set t = ZoneLabels_AddTransition(gg_rct_Z_SecretPathCave_to_Scholomance_Transition, "SecretPathCave to Scholomance Transition", 30, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_SecretPathCave)
        call ZoneLabels_AddAnchor(t, gg_rct_Hint_Pass_Nor)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Scholomance_Music)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Twilight_Highlands_South_Transition, "Twilight Highlands South Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_Delta)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dragonmaw_Port_14)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Highbank_14)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Bastion_of_Twilight_South)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Obsdian_Forest)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Twilight_Highlands_Central_Transition, "Twilight Highlands Central Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_Delta)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_North_14)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_The_Krazzworks)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dragonmaw_Port_14)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Twilight_Highlands_North_Transition, "Twilight Highlands North Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_North_14)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Vemillion_Redoubt)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Twilight_Highlands_Northern_Most_Transition, "Twilight Highlands Northern Most Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_16)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_North_14)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Vemillion_Redoubt)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Wetlands_to_Twilight_Highlands_Transition, "Wetlands to Twilight Highlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Wetlands_Bordering_Grim_Batol)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Greenwardens_Grove)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_16)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_North_14)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tolbarad_To_Wetlands_Transition, "Tolbarad To Wetlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tol_Barad_17)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Wetlands_Coast)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Wetlands_13)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Gilneas_Hillbsrad_and_Tol_Barad_Transition, "Gilneas Hillbsrad and Tol Barad Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gilneas_Tol_Barad_Entrance)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gil_Mine_Lumber)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Hillsbrad_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tol_Barad_17)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Gilneas_Grand_Central_Transition, "Gilneas Grand Central Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gilneas_City)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gilneas_Chapel)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Greymane_Manor)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gil_Mine_Lumber)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tempest_Reach)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Duskhaven_Battle_Music)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_The_WitchWood)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Alterac_North_Transition, "Alterac North Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Alterac_Western_Plaguelands_and_Hinterlands_Transition, "Alterac Western Plaguelands and Hinterlands Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Western_Plaguelands_5)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Andorhal_5)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Chillwind_Camp)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Uthers_Grave_Music)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Hinterlands_South_West_Transition, "Hinterlands South West Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Secret_Path_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Troll_Enclave_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Aerie_Peak)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Hinterlands_North_Transition, "Hinterlands North Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Moonlight)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Hinterlands_South_East_Transition, "Hinterlands South East Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Seaside_2_or_8)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Troll_Boss_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Revantusk_8)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Silverpine_to_Hillsbrad_Transition, "Silverpine to Hillsbrad Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Silverpine)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Hillsbrad_3)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Shadowfang_Keep_Ambermill_and_Silverpine_Transition, "Shadowfang Keep Ambermill and Silverpine Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_West_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Shadowfang_Keep)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Pyrewood_Village)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Silverpine_Alterac_Transition, "Silverpine Alterac Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_Fenris_Isles_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4_SW)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Silverpine_to_Fenrise_Isle_Transition, "Silverpine to Fenrise Isle Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_Fenris_Isles_2)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tirisfal_to_Silverpine_Transition, "Tirisfal to Silverpine Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tirisfal_South_Tower_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tirisfal_South_Tower_Sliver_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silverpine_2)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Hinterlands_to_Arathi_Transition, "Hinterlands to Arathi Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hinterlands_Secret_Path_2)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Passage_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Starting_Zone_100)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Shalandris_Eversong_Ghostlands_Transition, "Shalandris Eversong Ghostlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Murlocs_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Murlocs_EW)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Woods_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Goldenmist_Village_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Shalandis_Isle)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Windrunner_Spire)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Eastern_Plaguelands_Transition, "Eastern Plaguelands Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eastern_Plaguelands_9)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Lights_Hope_9)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Lights_Hope_Santuary)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_KT_Music_9)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eastern_Plaguelands_Tower_Graveyard_Music)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Ghostlands_to_Deathholme_Transition, "Ghostlands to Deathholme Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Deatholme)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Center)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_South)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_West)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Eversong_Ghostlands_Transition, "Eversong Ghostlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Eversong_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Center)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Lake)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Torwatha)

        set t = ZoneLabels_AddTransition(gg_rct_Z_South_Eversong_to_Torwatha_Transition, "South Eversong to Torwatha Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Eversong_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Woods_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Torwatha)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Torwatha_to_Dawnstar_Spire_Transition, "Torwatha to Dawnstar Spire Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Torwatha)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dawnstar_Spire)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Lake)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Sunstrider_Isle_to_Silvermoon_Ruins_Transition, "Sunstrider Isle to Silvermoon Ruins Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Sunstrider_Isle_101)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silvermoon_Ruins_1)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Silvermoon_Ruins_to_Eversong_Transition, "Silvermoon Ruins to Eversong Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Silvermoon_Ruins_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Woods_1)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Loch_Modan_to_Twilight_Highlands_Transition, "Loch Modan to Twilight Highlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Loch_Modan_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Loch_Modan_Farstrider_Lodge_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Twighlight_Highlands_16)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Bastion_of_Twilight_14)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Suramar_Dark_Portal_Transition, "Suramar Dark Portal Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Suramar)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Suramar_Fel)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Suramar_South)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Broken_Isles_Dark_Portal)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Broken_Isles_General_Transition, "Broken Isles General Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Suramar_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Suramar_Fel)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Valsharah_11)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_High_Mountain)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Stormheim_South)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Zul_Drak_to_Grizzly_Hills_Transition, "Zul Drak to Grizzly Hills Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Zul_Drak)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Zul_Drak_E)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzlemaw)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Dragonbllight_Grizzly_Hills_and_Howling_Fjord_Transition, "Dragonbllight Grizzly Hills and Howling Fjord Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dragonblight_Central)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dragonblight_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzlemaw)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzly_Hills_Amberpine)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Howling_Fjord_East_7)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Howling_Fjord_West_7)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Eversong_to_Ghostlands_Transition, "Eversong to Ghostlands Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_South_Eversong_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Center)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Ghostlands_Far_North)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Argent_Tournament_Storm_Peaks_and_Crystal_Song_Transition, "Argent Tournament Storm Peaks and Crystal Song Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Argent_Tournament)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Storm_Peaks)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crystal_Song_W)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crystal_Song_M)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Argent_Tournament_Ice_Crown_Transition, "Argent Tournament Ice Crown Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Argent_Tournament)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Icecrown_Central)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Icecrown_East)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Icecrown_West)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Storm_Peaks_Crystal_Song_Transition, "Storm Peaks Crystal Song Transition", 20, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Storm_Peaks)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crystal_Song_E)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crystal_Song_M)
    endfunction

    // Shared playback: Undercity
    private function ZoneLabels_Play_Undercity takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\INTRO_Undercity.mp3")
            call PlayMusicBJ(gg_snd_Undercity_Walk)
            call PlayMusicBJ(gg_snd_INTRO_Undercity)
        endif
    endfunction

    // Shared playback: Tirisfal_Glades
    private function ZoneLabels_Play_Tirisfal_Glades takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Tirisfal_1.mp3")
            call PlayMusicBJ(gg_snd_Tirisfal_3)
            call PlayMusicBJ(gg_snd_Tirisfal_1)
        endif
    endfunction

    // Shared playback: Deathknell, GY_WP_M
    private function ZoneLabels_Play_Deathknell takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Haunted_1)
        endif
    endfunction

    // Shared playback: Dalaran_Enter
    private function ZoneLabels_Play_Dalaran_Enter takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Dalaran_3)
        endif
    endfunction

    // Shared playback: Lights_Hope, Uthers_Grave_M
    private function ZoneLabels_Play_Lights_Hope takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_HumanDefeat01)
            call PlayMusicBJ(gg_snd_HumanVictory)
        endif
    endfunction

    // Shared playback: Vermillion_Redoubt
    private function ZoneLabels_Play_Vermillion_Redoubt takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Hyjal_Short)
        endif
    endfunction

    // Shared playback: ChromieInn
    private function ZoneLabels_Play_ChromieInn takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\UndeadInn.mp3")
            call PlayMusicBJ(gg_snd_Undercity_Walk)
            call PlayMusicBJ(gg_snd_UndeadInn)
        endif
    endfunction

    // Shared playback: HearthGlen
    private function ZoneLabels_Play_HearthGlen takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_StormWind_2)
        endif
    endfunction

    // Shared playback: Valshara, High_Mountain
    private function ZoneLabels_Play_Valshara takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_MUS_Aftermath_UU01)
            call PlayMusicBJ(gg_snd_Moonlight_1)
        endif
    endfunction

    // Shared playback: TarrenMill
    private function ZoneLabels_Play_TarrenMill takes player p returns nothing
        if (GetRandomInt(1, 2) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Undercity_Walk.mp3")
                call PlayMusicBJ(gg_snd_Undercity_Walk)
                call PlayMusicBJ(gg_snd_Tirisfal_1)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Tirisfal_1.mp3")
                call PlayMusicBJ(gg_snd_Undercity_Walk)
                call PlayMusicBJ(gg_snd_Tirisfal_1)
            endif
        endif
    endfunction

    // Shared playback: SilverPine_M
    private function ZoneLabels_Play_SilverPine_M takes player p returns nothing
        if (GetRandomInt(1, 2) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Silverpine_2.mp3")
                call PlayMusicBJ(gg_snd_Tirisfal_1)
                call PlayMusicBJ(gg_snd_Tirisfal_3)
                call PlayMusicBJ(gg_snd_Silverpine_1)
                call PlayMusicBJ(gg_snd_Silverpine_2)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Silverpine_1.mp3")
                call PlayMusicBJ(gg_snd_Silverpine_2)
                call PlayMusicBJ(gg_snd_Tirisfal_1)
                call PlayMusicBJ(gg_snd_Tirisfal_3)
                call PlayMusicBJ(gg_snd_Silverpine_1)
            endif
        endif
    endfunction

    // Shared playback: Skittering_Dark_M, EmberstoneMine, Venomweb_Vale_M, Wetlands_Cave_M, Syndicate_Inn, Balric, Ogre_Konold_Sludge_Golem_Cave
    private function ZoneLabels_Play_Skittering_Dark_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Lurking_Haunted_2)
        endif
    endfunction

    // Shared playback: Shadowfang_Keep_M
    private function ZoneLabels_Play_Shadowfang_Keep_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Lurking_Haunted_2)
            call PlayMusicBJ(gg_snd_Ebonhold_1)
        endif
    endfunction

    // Shared playback: Gilneas_City_Classical
    private function ZoneLabels_Play_Gilneas_City_Classical takes player p returns nothing
        if (GetOwningPlayer(gg_unit_ncop_1664) == Player(3)) then
            if (GetRandomInt(1, 5) > 2) then
                if GetLocalPlayer() == p then
                    call ClearMapMusicBJ()
                    call StopMusicBJ(false)
                    call EndThematicMusicBJ()
                    call PlayMusicBJ(gg_snd_Gilneas_3)
                    call PlayMusicBJ(gg_snd_Ebonhold_1)
                endif
            else
                if GetLocalPlayer() == p then
                    call ClearMapMusicBJ()
                    call StopMusicBJ(false)
                    call EndThematicMusicBJ()
                    call PlayMusicBJ(gg_snd_Gilneas_1)
                    call PlayMusicBJ(gg_snd_Gilneas_3)
                endif
            endif
        else
            if (GetRandomInt(1, 3) > 1) then
                if GetLocalPlayer() == p then
                    call ClearMapMusicBJ()
                    call StopMusicBJ(false)
                    call EndThematicMusicBJ()
                    call PlayMusicBJ(gg_snd_Gilneas_1)
                    call PlayMusicBJ(gg_snd_Gilneas_3)
                endif
            else
                if GetLocalPlayer() == p then
                    call ClearMapMusicBJ()
                    call StopMusicBJ(false)
                    call EndThematicMusicBJ()
                    call PlayMusicBJ(gg_snd_Gilneas_3)
                    call PlayMusicBJ(gg_snd_Gilneas_1)
                endif
            endif
        endif
    endfunction

    // Shared playback: Gilneas_City_Battle_Music, Battle_for_Gilneas, TolBarad_M
    private function ZoneLabels_Play_Gilneas_City_Battle_Music takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_PvP_Tol_Barad)
        endif
    endfunction

    // Shared playback: Pyrewood
    private function ZoneLabels_Play_Pyrewood takes player p returns nothing
        if (GetRandomInt(1, 3) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Gilneas_3)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Gilneas_1)
            endif
        endif
    endfunction

    // Shared playback: Gilneas_Chapel, Tempest_Reach
    private function ZoneLabels_Play_Gilneas_Chapel takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Gilneas_3)
            call PlayMusicBJ(gg_snd_Gilneas_2)
        endif
    endfunction

    // Shared playback: The_WitchWood
    private function ZoneLabels_Play_The_WitchWood takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Drustvar_2)
                call PlayMusicBJ(gg_snd_Darkmoon_Faire)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Darkmoon_Faire)
                call PlayMusicBJ(gg_snd_Drustvar_2)
            endif
        endif
    endfunction

    // Shared playback: Scholomance_M
    private function ZoneLabels_Play_Scholomance_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\MUS_50_Scholomance_A_02.mp3")
            call PlayMusicBJ(gg_snd_MUS_50_Scholomance_A_02)
            call PlayMusicBJ(gg_snd_Ebonhold_1)
            call PlayMusicBJ(gg_snd_Plaguelands_2)
        endif
    endfunction

    // Shared playback: Naxxramas_M
    private function ZoneLabels_Play_Naxxramas_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Naxxaramus_Abom_1.mp3")
            call PlayMusicBJ(gg_snd_Ebonhold_1)
            call PlayMusicBJ(gg_snd_Undercity_Walk)
        endif
    endfunction

    // Shared playback: Andorhal_M
    private function ZoneLabels_Play_Andorhal_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Tirisfal_1)
            call PlayMusicBJ(gg_snd_Tirisfal_3)
        endif
    endfunction

    // Shared playback: Western_Plaguelands_M
    private function ZoneLabels_Play_Western_Plaguelands_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Elywnn_3)
            call PlayMusicBJ(gg_snd_Elywnn_1)
        endif
    endfunction

    // Shared playback: Eastern_Plaguelands_M
    private function ZoneLabels_Play_Eastern_Plaguelands_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Plaguelands_1)
            call PlayMusicBJ(gg_snd_Plaguelands_2)
            call PlayMusicBJ(gg_snd_Tirisfal_3)
            call PlayMusicBJ(gg_snd_Tirisfal_1)
        endif
    endfunction

    // Shared playback: Stratholme_M
    private function ZoneLabels_Play_Stratholme_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\CT_StratholmePastMalGanis.mp3")
            call PlayMusicBJ(gg_snd_Haunted_1)
            call PlayMusicBJ(gg_snd_CT_StratholmePastMalGanis)
        endif
    endfunction

    // Shared playback: KelThuzad_M
    private function ZoneLabels_Play_KelThuzad_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Plaguelands_2.mp3")
            call PlayMusicBJ(gg_snd_Undercity_Walk)
            call PlayMusicBJ(gg_snd_Plaguelands_2)
        endif
    endfunction

    // Shared playback: Hinterlands_M, Blue_Dragon_Island_M
    private function ZoneLabels_Play_Hinterlands_M takes player p returns nothing
        if (GetRandomInt(1, 3) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\DunMorogh_1.mp3")
                call PlayMusicBJ(gg_snd_DunMorogh_2)
                call PlayMusicBJ(gg_snd_DunMorogh_1)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\DunMorogh_2.mp3")
                call PlayMusicBJ(gg_snd_DunMorogh_1)
                call PlayMusicBJ(gg_snd_DunMorogh_2)
            endif
        endif
    endfunction

    // Shared playback: Hillsbrad_M, Loch_Modan_M
    private function ZoneLabels_Play_Hillsbrad_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Elywnn_1)
                call PlayMusicBJ(gg_snd_Elywnn_2)
                call PlayMusicBJ(gg_snd_Elywnn_3)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Elywnn_2)
                call PlayMusicBJ(gg_snd_Elywnn_3)
                call PlayMusicBJ(gg_snd_Elywnn_1)
            endif
        endif
    endfunction

    // Shared playback: Arathi_M
    private function ZoneLabels_Play_Arathi_M takes player p returns nothing
        if (GetRandomInt(1, 3) == 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Arathi Highlands_1(S.mp3")
                call PlayMusicBJ(gg_snd_Arathi_Highlands_4_CH_u)
                call PlayMusicBJ(gg_snd_Arathi_Highlands_7)
                call PlayMusicBJ(gg_snd_Arathi_Highlands_1_S)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Arathi Highlands_4(CH).mp3")
                call PlayMusicBJ(gg_snd_Arathi_Highlands_7)
                call PlayMusicBJ(gg_snd_Arathi_Highlands_1_S)
                call PlayMusicBJ(gg_snd_Arathi_Highlands_4_CH_u)
            endif
        endif
    endfunction

    // Shared playback: Grizzly_Hills_M
    private function ZoneLabels_Play_Grizzly_Hills_M takes player p returns nothing
        if (GetRandomInt(1, 5) > 3) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\GrizzlyHillsNightB.mp3")
                call PlayMusicBJ(gg_snd_gh_walkday06)
                call PlayMusicBJ(gg_snd_GrizzlyHillsNightB)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\gh_walkday06.mp3")
                call PlayMusicBJ(gg_snd_GrizzlyHillsNightB)
                call PlayMusicBJ(gg_snd_gh_walkday06)
            endif
        endif
    endfunction

    // Shared playback: Utguarde_Hrydshal_M
    private function ZoneLabels_Play_Utguarde_Hrydshal_M takes player p returns nothing
        if (GetRandomInt(1, 5) > 0) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\uk_generalwalkuni01.mp3")
                call PlayMusicBJ(gg_snd_IcecrownIntro)
                call PlayMusicBJ(gg_snd_uk_generalwalkuni01)
                call PlayMusicBJ(gg_snd_LichKingTheme)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\IcecrownIntro.mp3")
                call PlayMusicBJ(gg_snd_uk_generalwalkuni01)
                call PlayMusicBJ(gg_snd_LichKingTheme)
                call PlayMusicBJ(gg_snd_IcecrownIntro)
            endif
        endif
    endfunction

    // Shared playback: Lich_King_M
    private function ZoneLabels_Play_Lich_King_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Assault on New Avalon.mp3")
            call PlayMusicBJ(gg_snd_IcecrownIntro)
            call PlayMusicBJ(gg_snd_Assault_on_New_Avalon)
        endif
    endfunction

    // Shared playback: Ice_Crown_M
    private function ZoneLabels_Play_Ice_Crown_M takes player p returns nothing
        if (GetRandomInt(1, 5) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\IcecrownIntro.mp3")
                call PlayMusicBJ(gg_snd_LichKingTheme)
                call PlayMusicBJ(gg_snd_IcecrownIntro)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("LichKingTheme")
                call PlayMusicBJ(gg_snd_IcecrownIntro)
                call PlayMusicBJ(gg_snd_LichKingTheme)
            endif
        endif
    endfunction

    // Shared playback: HowlingFjord_M
    private function ZoneLabels_Play_HowlingFjord_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Howling_Fjord_Night)
        endif
    endfunction

    // Shared playback: Dragonblight_M
    private function ZoneLabels_Play_Dragonblight_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\db_generalwalk_night01.mp3")
                call PlayMusicBJ(gg_snd_db_generalwalk_day07)
                call PlayMusicBJ(gg_snd_db_generalwalk_night01)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\db_generalwalk_day07.mp3")
                call PlayMusicBJ(gg_snd_db_generalwalk_night01)
                call PlayMusicBJ(gg_snd_db_generalwalk_day07)
            endif
        endif
    endfunction

    // Shared playback: Agmars_Hammer_M
    private function ZoneLabels_Play_Agmars_Hammer_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\nr_orc_generalwalk_day01.mp3")
            call PlayMusicBJ(gg_snd_OgrimmarMoment2)
            call PlayMusicBJ(gg_snd_Orgrimmar_Cata_Short)
            call PlayMusicBJ(gg_snd_nr_orc_generalwalk_day01)
        endif
    endfunction

    // Shared playback: Zul_Drak_M
    private function ZoneLabels_Play_Zul_Drak_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\zd_generalintro_05.mp3")
                call PlayMusicBJ(gg_snd_zd_generalintro_05)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\zd_generalintro_05.mp3")
                call PlayMusicBJ(gg_snd_zd_generalintro_05)
            endif
        endif
    endfunction

    // Shared playback: Storm_Peaks_M
    private function ZoneLabels_Play_Storm_Peaks_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\ironforge_walking_04.mp3")
                call PlayMusicBJ(gg_snd_ironforge_walking_04)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\ironforge_walking_04.mp3")
                call PlayMusicBJ(gg_snd_ironforge_walking_04)
            endif
        endif
    endfunction

    // Shared playback: Argent_Tournament_M
    private function ZoneLabels_Play_Argent_Tournament_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\IR_LightsHammer5.mp3")
                call PlayMusicBJ(gg_snd_ArgentTournament_Joust_145_Joint_Stereo)
                call PlayMusicBJ(gg_snd_IR_LightsHammer5)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\ArgentTournament_Joust_145_Joint_Stereo.mp3")
                call PlayMusicBJ(gg_snd_IR_LightsHammer5)
                call PlayMusicBJ(gg_snd_ArgentTournament_Joust_145_Joint_Stereo)
            endif
        endif
    endfunction

    // Shared playback: Crystalsong_M
    private function ZoneLabels_Play_Crystalsong_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\cs_crystalsongwalkuni02.mp3")
            call PlayMusicBJ(gg_snd_cs_crystalsongwalkuni02)
        endif
    endfunction

    // Shared playback: Azjol_Nerub_M
    private function ZoneLabels_Play_Azjol_Nerub_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\an_generalwalk_01.mp3")
            call PlayMusicBJ(gg_snd_ur_ulduarraidextwalk01)
            call PlayMusicBJ(gg_snd_an_generalwalk_01)
        endif
    endfunction

    // Shared playback: Ulduar_M
    private function ZoneLabels_Play_Ulduar_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\ur_ulduarraidextwalk01.mp3")
            call PlayMusicBJ(gg_snd_an_generalwalk_01)
            call PlayMusicBJ(gg_snd_ur_ulduarraidextwalk01)
        endif
    endfunction

    // Shared playback: Hinterlands_Troll_M, Jungle_Troll_M
    private function ZoneLabels_Play_Hinterlands_Troll_M takes player p returns nothing
        if (GetRandomInt(1, 3) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\NightJungle_3.mp3")
                call PlayMusicBJ(gg_snd_NightJungle_2)
                call PlayMusicBJ(gg_snd_NightJungle_3)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\NightJungle_2.mp3")
                call PlayMusicBJ(gg_snd_NightJungle_3)
                call PlayMusicBJ(gg_snd_NightJungle_2)
            endif
        endif
    endfunction

    // Shared playback: Zandalar_n_Zulaman_M
    private function ZoneLabels_Play_Zandalar_n_Zulaman_M takes player p returns nothing
        if (GetRandomInt(1, 2) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\ZFRally9.mp3")
                call PlayMusicBJ(gg_snd_Zandalari_MoP_1)
                call PlayMusicBJ(gg_snd_ZFRally9)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\Zandalari_MoP_1.mp3")
                call PlayMusicBJ(gg_snd_ZFRally9)
                call PlayMusicBJ(gg_snd_Zandalari_MoP_1)
            endif
        endif
    endfunction

    // Shared playback: Nazmir_M
    private function ZoneLabels_Play_Nazmir_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Zandalari_MoP_1)
            call PlayMusicBJ(gg_snd_The_Firelands_Shorter)
        endif
    endfunction

    // Shared playback: Silvermoon_M
    private function ZoneLabels_Play_Silvermoon_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\INTRO_Silvermoon.mp3")
            call PlayMusicBJ(gg_snd_Silvermoon_Day_1)
            call PlayMusicBJ(gg_snd_INTRO_Silvermoon)
        endif
    endfunction

    // Shared playback: Sunwell_M
    private function ZoneLabels_Play_Sunwell_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Sunwell_7.mp3")
            call PlayMusicBJ(gg_snd_Sunwell_7)
            call PlayMusicBJ(gg_snd_Ghostlands_Day_2_Short_Switch)
            call PlayMusicBJ(gg_snd_Silvermoon_Day_1)
        endif
    endfunction

    // Shared playback: Silvermoon_Ruins_M
    private function ZoneLabels_Play_Silvermoon_Ruins_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Silvermoon_Day_1)
            call PlayMusicBJ(gg_snd_Sunwell_7)
            call PlayMusicBJ(gg_snd_Eversong_1)
        endif
    endfunction

    // Shared playback: Eversong_Woods_M
    private function ZoneLabels_Play_Eversong_Woods_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Eversong_1)
            call PlayMusicBJ(gg_snd_Silvermoon_Day_1)
        endif
    endfunction

    // Shared playback: Ghostlands_M
    private function ZoneLabels_Play_Ghostlands_M takes player p returns nothing
        if (GetRandomInt(1, 5) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Ghostlands_Day_2_Short_Switch)
                call PlayMusicBJ(gg_snd_Ghostlands_Day_3_Switch_Short)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Ghostlands_Day_3_Switch_Short)
                call PlayMusicBJ(gg_snd_Ghostlands_Day_2_Short_Switch)
            endif
        endif
    endfunction

    // Shared playback: Windrunner_Spire_M
    private function ZoneLabels_Play_Windrunner_Spire_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Lament_of_the_Highborne)
            call PlayMusicBJ(gg_snd_Ghostlands_Day_2_Short_Switch)
            call PlayMusicBJ(gg_snd_Ghostlands_Day_3_Switch_Short)
        endif
    endfunction

    // Shared playback: Alterac_M
    private function ZoneLabels_Play_Alterac_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\DunMorogh_1.mp3")
            call PlayMusicBJ(gg_snd_DunMorogh_2)
            call PlayMusicBJ(gg_snd_DunMorogh_1)
        endif
    endfunction

    // Shared playback: VashJir_M
    private function ZoneLabels_Play_VashJir_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_NagaTheme)
        endif
    endfunction

    // Shared playback: StromGuarde_M
    private function ZoneLabels_Play_StromGuarde_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\INTRO_Stormwind.mp3")
            call PlayMusicBJ(gg_snd_StormWind_2)
            call PlayMusicBJ(gg_snd_INTRO_Stormwind)
        endif
    endfunction

    // Shared playback: Grim_Batol_M, AeriePeak_M
    private function ZoneLabels_Play_Grim_Batol_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\INTRO_IronForge.mp3")
            call PlayMusicBJ(gg_snd_StormWind_2)
            call PlayMusicBJ(gg_snd_INTRO_IronForge)
        endif
    endfunction

    // Shared playback: Wetlands_M
    private function ZoneLabels_Play_Wetlands_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Wetlands_1.mp3")
            call PlayMusicBJ(gg_snd_Wetlands_3)
            call PlayMusicBJ(gg_snd_Wetlands_1)
        endif
    endfunction

    // Shared playback: Greenwardens_Grove_M
    private function ZoneLabels_Play_Greenwardens_Grove_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\EnchantedForest05.mp3")
            call PlayMusicBJ(gg_snd_EnchantedForest05)
        endif
    endfunction

    // Shared playback: Dun_Morogh_M
    private function ZoneLabels_Play_Dun_Morogh_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\DunMorogh_3.mp3")
                call PlayMusicBJ(gg_snd_DunMorogh_2)
                call PlayMusicBJ(gg_snd_DunMorogh_1)
                call PlayMusicBJ(gg_snd_DunMorogh_3)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\DunMorogh_2.mp3")
                call PlayMusicBJ(gg_snd_DunMorogh_3)
                call PlayMusicBJ(gg_snd_DunMorogh_2)
                call PlayMusicBJ(gg_snd_DunMorogh_1)
            endif
        endif
    endfunction

    // Shared playback: Dun_Modr_M
    private function ZoneLabels_Play_Dun_Modr_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\BurningSteppes_short.mp3")
            call PlayMusicBJ(gg_snd_BurningSteppes_short)
            call PlayMusicBJ(gg_snd_OgrimmarMoment2)
        endif
    endfunction

    // Shared playback: Bastion_of_Twilight
    private function ZoneLabels_Play_Bastion_of_Twilight takes player p returns nothing
        if (GetRandomInt(1, 4) > 0) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\TwilightsHammer.mp3")
                call PlayMusicBJ(gg_snd_EndTime)
                call PlayMusicBJ(gg_snd_TwilightsHammer)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\EndTime.mp3")
                call PlayMusicBJ(gg_snd_TwilightsHammer)
                call PlayMusicBJ(gg_snd_EndTime)
            endif
        endif
    endfunction

    // Shared playback: Twilight_Highlands_North
    private function ZoneLabels_Play_Twilight_Highlands_North takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_MUS_Azshara_GD01)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_MUS_Azshara_GD01)
            endif
        endif
    endfunction

    // Shared playback: Twilight_Highlands_South
    private function ZoneLabels_Play_Twilight_Highlands_South takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\The Firelands Shorter.mp3")
            call PlayMusicBJ(gg_snd_BurningSteppes_short)
            call PlayMusicBJ(gg_snd_The_Firelands_Shorter)
        endif
    endfunction

    // Shared playback: Goblin_Music
    private function ZoneLabels_Play_Goblin_Music takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Goblin_Curious_Short)
        endif
    endfunction

    // Shared playback: Orc_Music_Dragonmaw_Port
    private function ZoneLabels_Play_Orc_Music_Dragonmaw_Port takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Orgrimmar_Cata_Short.mp3")
            call PlayMusicBJ(gg_snd_OgrimmarMoment2)
            call PlayMusicBJ(gg_snd_Orgrimmar_Cata_Short)
        endif
    endfunction

    // Shared playback: Highbank
    private function ZoneLabels_Play_Highbank takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Stormwind_Variation_NA_v4.mp3")
            call PlayMusicBJ(gg_snd_StormWind_2)
            call PlayMusicBJ(gg_snd_Stormwind_Variation_NA_v4)
        endif
    endfunction

    // Shared playback: Alterac_Keep_M
    private function ZoneLabels_Play_Alterac_Keep_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\OgrimmarMoment2.mp3")
            call PlayMusicBJ(gg_snd_OgrimmarMoment2)
            call PlayMusicBJ(gg_snd_BurningSteppes_short)
        endif
    endfunction

    // Shared playback: Dwarf_Cave
    private function ZoneLabels_Play_Dwarf_Cave takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\BurningSteppes_short.mp3")
            call PlayMusicBJ(gg_snd_BurningSteppes_short)
        endif
    endfunction

    // Shared playback: Cave_of_the_Elements
    private function ZoneLabels_Play_Cave_of_the_Elements takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Deepholm_1)
        endif
    endfunction

    // Shared playback: Dalaran_Crater_M
    private function ZoneLabels_Play_Dalaran_Crater_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Moonlight_1)
        endif
    endfunction

    // Shared playback: Night_Elf_Shaladnis_M
    private function ZoneLabels_Play_Night_Elf_Shaladnis_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Moonlight_1)
            call PlayMusicBJ(gg_snd_EnchantedForest05)
        endif
    endfunction

    // Shared playback: Suramar_M
    private function ZoneLabels_Play_Suramar_M takes player p returns nothing
        if (GetRandomInt(1, 4) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_MUS_Azshara_GD01)
                call PlayMusicBJ(gg_snd_MUS_Aftermath_UU01)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_MUS_Azshara_GD01)
                call PlayMusicBJ(gg_snd_MUS_Aftermath_UU01)
            endif
        endif
    endfunction

    // Shared playback: Dark_Portal_Sargeras
    private function ZoneLabels_Play_Dark_Portal_Sargeras takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_MUS_73_AntoranWastes_GeneralWalk_04)
        endif
    endfunction

    // Shared playback: NelfarionsLair
    private function ZoneLabels_Play_NelfarionsLair takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\TwilightsHammer.mp3")
            call PlayMusicBJ(gg_snd_EndTime)
            call PlayMusicBJ(gg_snd_TwilightsHammer)
        endif
    endfunction

    // Shared playback: Vrykul_M
    private function ZoneLabels_Play_Vrykul_M takes player p returns nothing
        local boolean discardedRandom = false
        if (GetRandomInt(1, 3) > 2) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Tuskar)
                call PlayMusicBJ(gg_snd_Vrykul)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayMusicBJ(gg_snd_Vrykul)
                call PlayMusicBJ(gg_snd_Tuskar)
            endif
            set discardedRandom = (GetRandomInt(1, 2) > 1)
        endif
    endfunction

    // Shared playback: Tuskar
    private function ZoneLabels_Play_Tuskar takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Tuskar)
        endif
    endfunction

    // Shared playback: Stormheim
    private function ZoneLabels_Play_Stormheim takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\Stormheim_Short.mp3")
            call PlayMusicBJ(gg_snd_Vrykul)
            call PlayMusicBJ(gg_snd_Stormheim_Short)
        endif
    endfunction

    // Shared playback: RagnarosLair
    private function ZoneLabels_Play_RagnarosLair takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicExBJ("war3mapImported\\RagnarosReach.mp3", 12.00)
            call PlayMusicBJ(gg_snd_Deepholm_1)
            call PlayMusicBJ(gg_snd_RagnarosReach)
            call PlayMusicBJ(gg_snd_EndTime)
        endif
    endfunction

    // Shared playback: Karazhan
    private function ZoneLabels_Play_Karazhan takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayThematicMusicBJ("war3mapImported\\KarazhanVoicesShort.mp3")
            call PlayMusicBJ(gg_snd_KharazhanBest)
            call PlayMusicBJ(gg_snd_KarazhanHarpsichordShort)
            call PlayMusicBJ(gg_snd_KarazhanVoicesShort)
        endif
    endfunction

    // Shared playback: Duel_Island
    private function ZoneLabels_Play_Duel_Island takes player p returns nothing
        if (GetRandomInt(1, 2) > 1) then
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\PvP_Tol_Barad.mp3")
                call PlayMusicBJ(gg_snd_Zandalari_MoP_1)
                call PlayMusicBJ(gg_snd_OrcX1)
                call PlayMusicBJ(gg_snd_ArgentTournament_Joust_145_Joint_Stereo)
                call PlayMusicBJ(gg_snd_ZFRally9)
            endif
        else
            if GetLocalPlayer() == p then
                call ClearMapMusicBJ()
                call StopMusicBJ(false)
                call EndThematicMusicBJ()
                call PlayThematicMusicBJ("war3mapImported\\PvP_Tol_Barad.mp3")
                call PlayMusicBJ(gg_snd_ZFRally9)
                call PlayMusicBJ(gg_snd_Zandalari_MoP_1)
                call PlayMusicBJ(gg_snd_OrcX1)
                call PlayMusicBJ(gg_snd_ArgentTournament_Joust_145_Joint_Stereo)
            endif
        endif
    endfunction

    private function ZoneLabels_PlayMusic takes integer profile, player p returns nothing
        local integer family = ZoneLabels_MusicFamily[profile]
        if family == 1 then
            call ZoneLabels_Play_Undercity(p)
        elseif family == 2 then
            call ZoneLabels_Play_Tirisfal_Glades(p)
        elseif family == 3 then
            call ZoneLabels_Play_Deathknell(p)
        elseif family == 4 then
            call ZoneLabels_Play_Dalaran_Enter(p)
        elseif family == 5 then
            call ZoneLabels_Play_Lights_Hope(p)
        elseif family == 6 then
            call ZoneLabels_Play_Vermillion_Redoubt(p)
        elseif family == 7 then
            call ZoneLabels_Play_ChromieInn(p)
        elseif family == 8 then
            call ZoneLabels_Play_HearthGlen(p)
        elseif family == 9 then
            call ZoneLabels_Play_Valshara(p)
        elseif family == 10 then
            call ZoneLabels_Play_TarrenMill(p)
        elseif family == 11 then
            call ZoneLabels_Play_SilverPine_M(p)
        elseif family == 12 then
            call ZoneLabels_Play_Skittering_Dark_M(p)
        elseif family == 13 then
            call ZoneLabels_Play_Shadowfang_Keep_M(p)
        elseif family == 14 then
            call ZoneLabels_Play_Gilneas_City_Classical(p)
        elseif family == 15 then
            call ZoneLabels_Play_Gilneas_City_Battle_Music(p)
        elseif family == 16 then
            call ZoneLabels_Play_Pyrewood(p)
        elseif family == 17 then
            call ZoneLabels_Play_Gilneas_Chapel(p)
        elseif family == 18 then
            call ZoneLabels_Play_The_WitchWood(p)
        elseif family == 19 then
            call ZoneLabels_Play_Scholomance_M(p)
        elseif family == 20 then
            call ZoneLabels_Play_Naxxramas_M(p)
        elseif family == 21 then
            call ZoneLabels_Play_Andorhal_M(p)
        elseif family == 22 then
            call ZoneLabels_Play_Western_Plaguelands_M(p)
        elseif family == 23 then
            call ZoneLabels_Play_Eastern_Plaguelands_M(p)
        elseif family == 24 then
            call ZoneLabels_Play_Stratholme_M(p)
        elseif family == 25 then
            call ZoneLabels_Play_KelThuzad_M(p)
        elseif family == 26 then
            call ZoneLabels_Play_Hinterlands_M(p)
        elseif family == 27 then
            call ZoneLabels_Play_Hillsbrad_M(p)
        elseif family == 28 then
            call ZoneLabels_Play_Arathi_M(p)
        elseif family == 29 then
            call ZoneLabels_Play_Grizzly_Hills_M(p)
        elseif family == 30 then
            call ZoneLabels_Play_Utguarde_Hrydshal_M(p)
        elseif family == 31 then
            call ZoneLabels_Play_Lich_King_M(p)
        elseif family == 32 then
            call ZoneLabels_Play_Ice_Crown_M(p)
        elseif family == 33 then
            call ZoneLabels_Play_HowlingFjord_M(p)
        elseif family == 34 then
            call ZoneLabels_Play_Dragonblight_M(p)
        elseif family == 35 then
            call ZoneLabels_Play_Agmars_Hammer_M(p)
        elseif family == 36 then
            call ZoneLabels_Play_Zul_Drak_M(p)
        elseif family == 37 then
            call ZoneLabels_Play_Storm_Peaks_M(p)
        elseif family == 38 then
            call ZoneLabels_Play_Argent_Tournament_M(p)
        elseif family == 39 then
            call ZoneLabels_Play_Crystalsong_M(p)
        elseif family == 40 then
            call ZoneLabels_Play_Azjol_Nerub_M(p)
        elseif family == 41 then
            call ZoneLabels_Play_Ulduar_M(p)
        elseif family == 42 then
            call ZoneLabels_Play_Hinterlands_Troll_M(p)
        elseif family == 43 then
            call ZoneLabels_Play_Zandalar_n_Zulaman_M(p)
        elseif family == 44 then
            call ZoneLabels_Play_Nazmir_M(p)
        elseif family == 45 then
            call ZoneLabels_Play_Silvermoon_M(p)
        elseif family == 46 then
            call ZoneLabels_Play_Sunwell_M(p)
        elseif family == 47 then
            call ZoneLabels_Play_Silvermoon_Ruins_M(p)
        elseif family == 48 then
            call ZoneLabels_Play_Eversong_Woods_M(p)
        elseif family == 49 then
            call ZoneLabels_Play_Ghostlands_M(p)
        elseif family == 50 then
            call ZoneLabels_Play_Windrunner_Spire_M(p)
        elseif family == 51 then
            call ZoneLabels_Play_Alterac_M(p)
        elseif family == 52 then
            call ZoneLabels_Play_VashJir_M(p)
        elseif family == 53 then
            call ZoneLabels_Play_StromGuarde_M(p)
        elseif family == 54 then
            call ZoneLabels_Play_Grim_Batol_M(p)
        elseif family == 55 then
            call ZoneLabels_Play_Wetlands_M(p)
        elseif family == 56 then
            call ZoneLabels_Play_Greenwardens_Grove_M(p)
        elseif family == 57 then
            call ZoneLabels_Play_Dun_Morogh_M(p)
        elseif family == 58 then
            call ZoneLabels_Play_Dun_Modr_M(p)
        elseif family == 59 then
            call ZoneLabels_Play_Bastion_of_Twilight(p)
        elseif family == 60 then
            call ZoneLabels_Play_Twilight_Highlands_North(p)
        elseif family == 61 then
            call ZoneLabels_Play_Twilight_Highlands_South(p)
        elseif family == 62 then
            call ZoneLabels_Play_Goblin_Music(p)
        elseif family == 63 then
            call ZoneLabels_Play_Orc_Music_Dragonmaw_Port(p)
        elseif family == 64 then
            call ZoneLabels_Play_Highbank(p)
        elseif family == 65 then
            call ZoneLabels_Play_Alterac_Keep_M(p)
        elseif family == 66 then
            call ZoneLabels_Play_Dwarf_Cave(p)
        elseif family == 67 then
            call ZoneLabels_Play_Cave_of_the_Elements(p)
        elseif family == 68 then
            call ZoneLabels_Play_Dalaran_Crater_M(p)
        elseif family == 69 then
            call ZoneLabels_Play_Night_Elf_Shaladnis_M(p)
        elseif family == 70 then
            call ZoneLabels_Play_Suramar_M(p)
        elseif family == 71 then
            call ZoneLabels_Play_Dark_Portal_Sargeras(p)
        elseif family == 72 then
            call ZoneLabels_Play_NelfarionsLair(p)
        elseif family == 73 then
            call ZoneLabels_Play_Vrykul_M(p)
        elseif family == 74 then
            call ZoneLabels_Play_Tuskar(p)
        elseif family == 75 then
            call ZoneLabels_Play_Stormheim(p)
        elseif family == 76 then
            call ZoneLabels_Play_RagnarosLair(p)
        elseif family == 77 then
            call ZoneLabels_Play_Karazhan(p)
        elseif family == 78 then
            call ZoneLabels_Play_Duel_Island(p)
        endif
    endfunction

    private function ZoneLabels_ApplyMusic takes integer slot, boolean boundary returns nothing
        local integer profile = ZoneLabels_Profile(ZoneLabels_LastMusicPlace[slot])
        local integer previous = ZoneLabels_AppliedMusic[slot]
        local integer flavor = ZoneLabels_Flavor(profile)
        if profile == 0 then
            return
        endif
        // External cannon/ride/selection keys are not overwritten by a stationary poll.
        if ZoneLabels_ForeignMusic[slot] and not boundary then
            return
        endif
        if profile == previous and flavor == ZoneLabels_AppliedFlavor[slot] and not boundary then
            return
        endif
        if previous == 0 or ZoneLabels_MusicFamily[profile] != ZoneLabels_MusicFamily[previous] or flavor != ZoneLabels_AppliedFlavor[slot] or ZoneLabels_ForeignMusic[slot] then
            // Random branch selection runs on all clients; only audio calls are local.
            call ZoneLabels_PlayMusic(profile, ZoneLabels_Players[slot])
        endif
        set ZoneLabels_AppliedMusic[slot] = profile
        set ZoneLabels_AppliedFlavor[slot] = flavor
        set udg_Player_Music[slot] = ZoneLabels_MusicKey[profile]
        set ZoneLabels_LegacyMirror[slot] = udg_Player_Music[slot]
        set ZoneLabels_ForeignMusic[slot] = false
    endfunction

    private function ZoneLabels_Update takes nothing returns nothing
        local integer slot = 0
        local unit subject = null
        local real x = 0.0
        local real y = 0.0
        local real dx = 0.0
        local real dy = 0.0
        local integer z = 0
        local integer a = 0
        local integer t = 0
        local integer rawMusic = 0
        local integer music = 0
        local boolean remote = false
        local boolean boundary = false
        loop
            exitwhen slot > 7
            set boundary = false
            if udg_Player_Music[slot] != ZoneLabels_LegacyMirror[slot] then
                set ZoneLabels_ForeignMusic[slot] = true
                set ZoneLabels_LegacyMirror[slot] = udg_Player_Music[slot]
            endif
            set subject = ZoneLabelsGetSubject(ZoneLabels_Players[slot])
            if subject == null then
                set ZoneLabels_LastSubject[slot] = null
                set ZoneLabels_LastZone[slot] = 0
                set ZoneLabels_LastPlace[slot] = 0
                set ZoneLabels_LastMusicPlace[slot] = 0
                set ZoneLabels_LastRawMusic[slot] = 0
                set ZoneLabels_LabelTransition[slot] = 0
                set ZoneLabels_MusicTransition[slot] = 0
                set ZoneLabels_ActiveTransition[slot] = 0
                set ZoneLabels_AppliedMusic[slot] = 0
                set ZoneLabels_AppliedFlavor[slot] = 0
                set ZoneLabels_LabelReason[slot] = "NO SUBJECT"
                set ZoneLabels_MusicReason[slot] = "NO SUBJECT"
                set ZoneLabels_CacheValid[slot] = false
                set ZoneLabels_Relocated[slot] = false
            else
                set x = GetUnitX(subject)
                set y = GetUnitY(subject)
                if not ZoneLabels_CacheValid[slot] or subject != ZoneLabels_LastSubject[slot] or x != ZoneLabels_LastX[slot] or y != ZoneLabels_LastY[slot] or ZoneLabels_Relocated[slot] then
                    set dx = x - ZoneLabels_LastX[slot]
                    set dy = y - ZoneLabels_LastY[slot]
                    set remote = not ZoneLabels_CacheValid[slot] or subject != ZoneLabels_LastSubject[slot] or ZoneLabels_Relocated[slot] or dx * dx + dy * dy > ZoneLabels_REMOTE_DISTANCE * ZoneLabels_REMOTE_DISTANCE
                    set z = ZoneLabelsResolve(x, y)
                    set a = ZoneLabels_LabelPlace(z, x, y)
                    set t = ZoneLabels_ResolveTransition(x, y)
                    set ZoneLabels_ActiveTransition[slot] = t
                    if a != 0 then
                        set ZoneLabels_LastPlace[slot] = a
                        set ZoneLabels_LabelTransition[slot] = 0
                        set ZoneLabels_LabelReason[slot] = "NORMAL"
                    elseif t != 0 then
                        set a = ZoneLabels_TransitionPlace(t, ZoneLabels_LastPlace[slot], ZoneLabels_LabelTransition[slot], remote, x, y)
                        if a == ZoneLabels_LastPlace[slot] and not remote then
                            set ZoneLabels_LabelReason[slot] = "TRANSITION RETAINED"
                        else
                            set ZoneLabels_LabelReason[slot] = "LOCAL FALLBACK"
                        endif
                        set ZoneLabels_LastPlace[slot] = a
                        set ZoneLabels_LabelTransition[slot] = t
                    else
                        set ZoneLabels_LabelTransition[slot] = 0
                        set ZoneLabels_LabelReason[slot] = "GAP RETAINED"
                    endif
                    set ZoneLabels_LastZone[slot] = ZoneLabels_PlaceZone[ZoneLabels_LastPlace[slot]]
                    set rawMusic = ZoneLabels_NormalMusicPlace(x, y)
                    set music = rawMusic
                    if t != 0 and (rawMusic == 0 or (ZoneLabels_TransitionBuffer[t] and not ZoneLabels_PlaceCore[rawMusic] and not remote and ZoneLabels_Eligible(t, rawMusic))) then
                        set music = ZoneLabels_TransitionPlace(t, ZoneLabels_LastMusicPlace[slot], ZoneLabels_MusicTransition[slot], remote, x, y)
                        if music == ZoneLabels_LastMusicPlace[slot] and not remote then
                            set ZoneLabels_MusicReason[slot] = "TRANSITION RETAINED"
                        else
                            set ZoneLabels_MusicReason[slot] = "LOCAL FALLBACK"
                        endif
                        set ZoneLabels_MusicTransition[slot] = t
                    elseif rawMusic != 0 then
                        set ZoneLabels_MusicTransition[slot] = 0
                        if ZoneLabels_PlaceCore[rawMusic] then
                            set ZoneLabels_MusicReason[slot] = "LOCAL OVERRIDE"
                        else
                            set ZoneLabels_MusicReason[slot] = "NORMAL"
                        endif
                    else
                        set ZoneLabels_MusicTransition[slot] = 0
                        set ZoneLabels_MusicReason[slot] = "GAP / UNASSIGNED RETAINED"
                        set music = ZoneLabels_LastMusicPlace[slot]
                    endif
                    if music != 0 then
                        set boundary = music != ZoneLabels_LastMusicPlace[slot] or (ZoneLabels_MusicTransition[slot] == 0 and rawMusic != 0 and rawMusic != ZoneLabels_LastRawMusic[slot])
                        set ZoneLabels_LastMusicPlace[slot] = music
                    endif
                    set ZoneLabels_LastRawMusic[slot] = rawMusic
                    set ZoneLabels_LastSubject[slot] = subject
                    set ZoneLabels_LastX[slot] = x
                    set ZoneLabels_LastY[slot] = y
                    set ZoneLabels_CacheValid[slot] = true
                    set ZoneLabels_Relocated[slot] = false
                endif
                // Gilneas state is checked even without movement; no repeated track restart.
                call ZoneLabels_ApplyMusic(slot, boundary)
            endif
            // FrameLoader can rebuild the text frame while the hero is stationary.
            call ZoneTextSetForPlayer(ZoneLabels_Players[slot], ZoneLabelsGetName(ZoneLabels_LastZone[slot]))
            set slot = slot + 1
        endloop
        set subject = null
    endfunction

    private function ZoneLabels_Diagnose takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer slot = GetPlayerHeroNumber(p)
        local unit subject = ZoneLabelsGetSubject(p)
        local integer a = 0
        local integer t = 0
        local integer profile = 0
        local integer i = 1
        local string kind = "hero"
        local string text = ""
        local real x = 0.0
        local real y = 0.0
        if subject == null or slot < 0 or slot > 7 then
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Zones: no registered subject.")
        else
            set x = GetUnitX(subject)
            set y = GetUnitY(subject)
            if subject == udg_FP_Bats_n_Gryphons[slot] then
                set kind = "flight carrier"
            endif
            set a = ZoneLabels_LastPlace[slot]
            set t = ZoneLabels_ActiveTransition[slot]
            set profile = ZoneLabels_Profile(ZoneLabels_LastMusicPlace[slot])
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Label: " + ZoneLabelsGetName(ZoneLabels_LastZone[slot]) + " | " + ZoneLabels_LabelReason[slot])
            if a != 0 then
                call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Place: " + ZoneLabels_PlaceName[a] + " | subject: " + kind + " | x=" + R2S(x) + " y=" + R2S(y))
            endif
            if t != 0 then
                call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Transition: " + ZoneLabels_TransitionName[t])
            elseif ZoneLabelsResolve(x, y) == 0 then
                call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "UNMAPPED: last valid state retained.")
            endif
            if profile != 0 then
                set text = ZoneLabels_MusicKey[profile] + " (#" + I2S(profile) + ")"
            else
                set text = "UNASSIGNED"
            endif
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Music desired: " + text + " | " + ZoneLabels_MusicReason[slot] + " | actual legacy key: " + udg_Player_Music[slot])
            if ZoneLabels_ForeignMusic[slot] then
                call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "External music key retained until the next committed local boundary.")
            endif
            loop
                exitwhen i > ZoneLabels_Count
                if IsPointInRegion(ZoneLabels_Areas[i], x, y) then
                    call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Label match: " + ZoneLabels_Names[i] + " (priority " + I2S(ZoneLabels_Priorities[i]) + ")")
                endif
                set i = i + 1
            endloop
        endif
        set subject = null
        set p = null
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

    // Block only old audio. Retain trigger enable flags used by Gilneas mechanics.
    private function ZoneLabels_BlockAmbient takes nothing returns boolean
        return false
    endfunction

    private function ZoneLabels_Enter_Dalaran_Enter takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer slot = ZoneLabels_TrackedSlot(u)
        if slot >= 0 and slot <= 7 then
            call PlayerEntersLocation(GetOwningPlayer(u), "Dalaran", 2)
        endif
        set u = null
        return false
    endfunction

    private function ZoneLabels_Enter_Lights_Hope takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer slot = ZoneLabels_TrackedSlot(u)
        if slot >= 0 and slot <= 7 then
            call PlayerEntersLocation(GetOwningPlayer(u), "Lights Hope", 2)
        endif
        set u = null
        return false
    endfunction

    private function ZoneLabels_Enter_Vermillion_Redoubt takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer slot = ZoneLabels_TrackedSlot(u)
        if slot >= 0 and slot <= 7 then
            call PlayerEntersLocation(GetOwningPlayer(u), "Vermillion Redoubt", 2)
        endif
        set u = null
        return false
    endfunction

    private function ZoneLabels_HookLegacyMusic takes nothing returns nothing
        call TriggerAddCondition(gg_trg_Undercity, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Tirisfal_Glades, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Deathknell, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dalaran_Enter, Condition(function ZoneLabels_Enter_Dalaran_Enter))
        call TriggerAddCondition(gg_trg_Lights_Hope, Condition(function ZoneLabels_Enter_Lights_Hope))
        call TriggerAddCondition(gg_trg_Vermillion_Redoubt, Condition(function ZoneLabels_Enter_Vermillion_Redoubt))
        call TriggerAddCondition(gg_trg_ChromieInn, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_HearthGlen, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Valshara, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_TarrenMill, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_SilverPine_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Skittering_Dark_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Shadowfang_Keep_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Gilneas_City_Classical, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Gilneas_City_Battle_Music, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Pyrewood, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Gilneas_Chapel, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Tempest_Reach, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Battle_for_Gilneas, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_The_WitchWood, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_EmberstoneMine, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Scholomance_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Uthers_Grave_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Naxxramas_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Andorhal_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Western_Plaguelands_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Eastern_Plaguelands_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Stratholme_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_KelThuzad_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_GY_WP_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Venomweb_Vale_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Hinterlands_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_TolBarad_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Hillsbrad_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Arathi_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Grizzly_Hills_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Utguarde_Hrydshal_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Lich_King_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Ice_Crown_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_HowlingFjord_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Blue_Dragon_Island_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dragonblight_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Agmars_Hammer_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Zul_Drak_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Storm_Peaks_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Argent_Tournament_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Crystalsong_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Azjol_Nerub_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Ulduar_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Hinterlands_Troll_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Jungle_Troll_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Zandalar_n_Zulaman_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Nazmir_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Silvermoon_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Sunwell_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Silvermoon_Ruins_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Eversong_Woods_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Ghostlands_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Windrunner_Spire_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Alterac_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_VashJir_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_StromGuarde_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Grim_Batol_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Wetlands_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Wetlands_Cave_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Greenwardens_Grove_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Loch_Modan_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dun_Morogh_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dun_Modr_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_AeriePeak_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Bastion_of_Twilight, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Twilight_Highlands_North, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Twilight_Highlands_South, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Goblin_Music, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Orc_Music_Dragonmaw_Port, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Highbank, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Alterac_Keep_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dwarf_Cave, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Syndicate_Inn, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Balric, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Ogre_Konold_Sludge_Golem_Cave, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Cave_of_the_Elements, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dalaran_Crater_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Night_Elf_Shaladnis_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Suramar_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Dark_Portal_Sargeras, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_NelfarionsLair, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Vrykul_M, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Tuskar, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_High_Mountain, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Stormheim, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_RagnarosLair, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Karazhan, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Duel_Island, Condition(function ZoneLabels_BlockAmbient))
    endfunction

    private function ZoneLabels_Start takes nothing returns nothing
        local timer clock = GetExpiredTimer()
        local trigger diagnostic = CreateTrigger()
        local integer playerID = 0
        local integer slot = 0
        set ZoneLabels_Index = InitHashtable()
        call ZoneLabels_ConfigureLabels()
        call ZoneLabels_ConfigureMusic()
        call ZoneLabels_ConfigureTransitions()
        call ZoneLabels_DisableLegacyLabels()
        call ZoneLabels_HookLegacyMusic()
        loop
            exitwhen playerID >= bj_MAX_PLAYER_SLOTS
            set slot = GetPlayerHeroNumber(Player(playerID))
            if slot >= 0 and slot <= 7 then
                set ZoneLabels_Players[slot] = Player(playerID)
                set ZoneLabels_LegacyMirror[slot] = udg_Player_Music[slot]
                call TriggerRegisterPlayerChatEvent(diagnostic, Player(playerID), "-zone", true)
            endif
            set playerID = playerID + 1
        endloop
        call TriggerAddAction(diagnostic, function ZoneLabels_Diagnose)
        call ZoneLabels_Update()
        call TimerStart(clock, ZoneLabels_PERIOD, true, function ZoneLabels_Update)
        set diagnostic = null
        set clock = null
    endfunction

    private function ZoneLabels_Init takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.00, false, function ZoneLabels_Start)
    endfunction

endlibrary
