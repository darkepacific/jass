// BATTLE FOR LORDAERON - ZONE LABELS + TRANSITIONS + MUSIC + DEATH POLICIES - revision 7.3 (merged)
// Base: 7.3 (19 October 2026). Merges intentional label/death/transition edits from edited 7.1.
// Sanctuary entry/exit is controller-owned. Keep only the two Gilneas ambient/state handles.
// Apply GenericFunctions_Sanctuary_Patch.j, replace ZoneLabels, and follow Zone_Music_Trigger_Cleanup.md.
// Dependencies: ZoneText, GenericFunctions, DeathSet. No InitTrig wrapper.
// 115 label groups; 224 places; 47 transitions; 95 music / 26 death policies; 130 death bindings; 6 sanctuary rectangles.
//
// WHERE TO EDIT
//   ConfigureLabels      - labels, rectangles, music, death policies, and six sanctuary traits.
//   ConfigureMusic       - compatibility keys and shared playback-family metadata only.
//   ConfigureDeath       - supported destination allowlists and named faction-aware death policies.
//   ConfigureTransitions - transition bounds, buffer settings, and contiguous anchor lists.
//   Play_* functions     - original playback sequences; change only when changing actual tracks.
//
// ADD OR EDIT A PLACE
//   set z = ZoneLabels_Define("Durnholde", 20)
//   call ZoneLabels_AddRect(z, gg_rct_Z_Durnholde, "Durnholde")
//   call ZoneLabels_BindMusic(gg_rct_Z_Durnholde, ZM_Hillsbrad_M, false)
//   call ZoneLabels_BindDeath(gg_rct_Z_Durnholde, ZD_HILLSBRAD)
//   Define's text is displayed. AddRect's text is diagnostic only. Bind after registering.
//   A second AddRect using the same z shares the label, but still needs its own music binding.
//   No binding means overlapping normal music can apply; otherwise the last audio is retained.
//   It does not automatically inherit music from a parent label.
//
// ADD OR EDIT A TRANSITION
//   set t = ZoneLabels_AddTransition(r, diagnosticName, transitionPriority, bufferMusic)
//   ZoneLabels_AddAnchor(t, neighboringRect) follows immediately; finish the list before the next transition.
//   A normal anchor allows both walk-in continuity and nearest-anchor arrival fallback.
//   ZoneLabels_AddLatchAnchor allows continuity but is excluded while regular fallback anchors exist.
//   Fallback measures distance to rectangle edges, not centers. It stays latched while moving.
//
// TWO DIFFERENT PRIORITIES / TWO DIFFERENT BOOLEANS
//   Define priority: compares normal LABEL groups. Higher wins; equal means first configured.
//   Transition priority: compares overlapping TRANSITIONS only. Higher wins; equal means first.
//   Normal label coverage wins over transition label fallback, regardless of those priorities.
//   BindMusic core=true: local music override; bypasses overlap buffering on entry.
//   BindMusic core=false: ordinary ambient coverage; a transition may hold prior audio over it.
//   AddTransition buffer=true: may hold prior eligible audio even over ordinary music coverage.
//   AddTransition buffer=false: normal music commits; transition-only gaps can still retain state.
//   These flags do not enforce strict label/music exits or perform an audio crossfade.
//
// STATE AND COMPATIBILITY
//   Each player has independent label/music history. Uncovered gaps preserve valid prior state.
//   Remote jumps (>1536 units per 0.25-second sample) use local transition fallback.
//   ZoneLabelsNotifyRelocation(p) explicitly invalidates continuity for shorter teleports.
//   -zone reports the selected place, transition, and label/music selection reasons.
//   GUI cleanup: replace all sanctuary entry/leave events and ambient-only music triggers with
//   the controller. Keep the two Gilneas state handles; see Zone_Music_Trigger_Cleanup.md.
//   Sanctuary bounds are explicit BindSanctuary traits, not retained labels or music policies.
//   Keep label registration order stable; it is the tie-breaker for equal-priority overlaps.
//   INT/EXT registrations are temporary coverage exceptions pending suitable parent Z geometry.
//   Azurelode_Mine_Int is not registered: its former ineffective music binding was removed.
//
// DEATH ROLLOUT AND SAFETY CONTRACT
//   ZoneLabels_DEATH_TAKEOVER remains true in this revision: validated takeover is requested.
//   If changed to false, GUI deaths remain in control; diagnostics compare predictions only.
//   -zd reports whether takeover installed successfully or configuration/handle checks refused it.
//   Do not delete the old assignment triggers or the two Death_Set action functions.
//   Takeover replaces their action lists with guards that call the consolidated DeathSet functions.
//   This protects TriggerExecute callers too; trigger conditions alone would not protect those calls.
//   Resurrection timing, graves, camera pans, revive logic, and Gilneas ownership remain in DeathSet.
//
//   ZD_* constants are POLICY IDs, not udg_Revives numbers. BindDeath translates by faction.
//   ZD_KEEP means this policy does not change that faction's assignment; 0 is a VALID revive route.
//   Every new write passes the actual faction handler's supported-route allowlist.
//   Recovery order: valid candidate -> last valid route -> valid current GUI route -> home route 0.
//   The home handles and policy configuration are checked before takeover is permitted.
//   Death geography is refreshed on death and immediately before guarded destination selection.
//   The resolved route freezes while dead; Gilneas ownership is still evaluated by the old handler.
//   StartingPoint/load assignments seed state. Empty gaps and unassigned factions retain valid state.
//
//   Original GUI death routes are retained. The edited branch additionally assigns Alliance Revantusk
//   to route 2 and adds Silverpine coverage for Skittering Dark/Deep Elm Mine and Bulwark for East
//   Venomweb Vale. Five Hillsbrad/Arathi coverage additions from 7.3 are also preserved.
//   Four transitions already had explicit GUI death assignments: those assignments remain explicit.
//   Other transition-only space retains incoming death state or uses a faction-valid local anchor.
//   Death fallback ignores music's latch-only/buffer flags and does not search for a global nearest GY.
//   Overlapping direct death coverage uses the smaller rectangle; equal-size ties keep binding order.
//   This is intentionally independent of label priority. Comparison differences need review before use.
//   Unsupported numbers (including Alliance 8/12 and both factions 16/18/19) are never new assignments.
//   Weather, quests, spawns, boss boundaries, and full cinematic suppression remain separate.
//   Sanctuary protection is disabled in PVP mode and updates with tracked hero/flight geometry.
//   Duel Island is a hard exclusion: its duel triggers retain all force/protection ownership.

library ZoneLabels initializer ZoneLabels_Init requires ZoneText, GenericFunctions, DeathSet

    globals
        // Sampling settings. World coordinates are measured in Warcraft map units.
        private constant real ZoneLabels_PERIOD = 0.25
        // A jump this large in one sample invalidates local transition continuity.
        private constant real ZoneLabels_REMOTE_DISTANCE = 1536.0
        private constant string ZoneLabels_UNMAPPED_TEXT = ""
        // Label groups (z): displayed text, priority, and combined normal coverage.
        private integer ZoneLabels_Count = 0
        private region array ZoneLabels_Areas
        private string array ZoneLabels_Names
        private integer array ZoneLabels_Priorities
        // Places (a): one registered rectangle, its label group, and its music binding.
        // Index maps a rectangle handle to its place ID; register each rectangle once.
        private hashtable ZoneLabels_Index = null
        private integer ZoneLabels_PlaceCount = 0
        private region array ZoneLabels_PlaceArea
        private rect array ZoneLabels_PlaceRect
        private integer array ZoneLabels_PlaceZone
        private string array ZoneLabels_PlaceName
        private integer array ZoneLabels_PlaceMusic
        private boolean array ZoneLabels_PlaceCore
        private real array ZoneLabels_PlaceSize
        // Transitions (t) and contiguous anchor ranges.
        private integer ZoneLabels_TransitionCount = 0
        private region array ZoneLabels_TransitionArea
        private string array ZoneLabels_TransitionName
        private integer array ZoneLabels_TransitionPriority
        private boolean array ZoneLabels_TransitionBuffer
        private integer array ZoneLabels_AnchorFirst
        private integer array ZoneLabels_AnchorLast
        private integer ZoneLabels_AnchorCount = 0
        private integer array ZoneLabels_AnchorPlace
        private boolean array ZoneLabels_AnchorLatchOnly
        // Music policies (profile): legacy key and shared playback family.
        private string array ZoneLabels_MusicKey
        private integer array ZoneLabels_MusicFamily
        // Per-player state (slot 0..7). Label place and music place can differ intentionally.
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
        // Sanctuary membership is geometry, independent of labels/music/death routes.
        private string array ZoneLabels_SanctuaryName
        private integer array ZoneLabels_LastSanctuary
        private unit array ZoneLabels_SanctuarySubject
        private string array ZoneLabels_SanctuaryMode
        private boolean array ZoneLabels_SanctuarySuspended
        // Stable music policy IDs. A policy ID is different from its playback-family ID.
        private constant integer ZM_Undercity = 1
        private constant integer ZM_Tirisfal_Glades = 2
        private constant integer ZM_Deathknell = 3
        private constant integer ZM_Dalaran_Enter = 4
        private constant integer ZM_Lights_Hope = 5
        private constant integer ZM_Vermillion_Redoubt = 6
        private constant integer ZM_ChromieInn = 7
        private constant integer ZM_Hearthglen = 8
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
        private constant integer ZM_Chillwind_Camp = 95

        // Death rollout. false = comparison only: no revive writes or GUI takeover.
        // After comparison playtests, true enables validated assignments and guarded legacy handlers.
        private constant boolean ZoneLabels_DEATH_TAKEOVER = true
        private constant integer ZD_KEEP = -1
        private constant integer ZoneLabels_DEATH_POLICY_LIMIT = 26
        private boolean ZoneLabels_DeathConfigOK = true
        private boolean ZoneLabels_DeathActive = false
        private boolean array ZoneLabels_DeathValidA
        private boolean array ZoneLabels_DeathValidH
        private boolean array ZoneLabels_DeathPolicyDefined
        private string array ZoneLabels_DeathPolicyName
        private integer array ZoneLabels_DeathPolicyA
        private integer array ZoneLabels_DeathPolicyH
        private integer ZoneLabels_DeathCount = 0
        private rect array ZoneLabels_DeathRect
        private region array ZoneLabels_DeathArea
        private real array ZoneLabels_DeathSize
        private integer array ZoneLabels_DeathPolicy
        private string array ZoneLabels_DeathName
        private unit array ZoneLabels_DeathHero
        private unit array ZoneLabels_DeathSubject
        private real array ZoneLabels_DeathX
        private real array ZoneLabels_DeathY
        private boolean array ZoneLabels_DeathCache
        private integer array ZoneLabels_DeathValue
        private integer array ZoneLabels_DeathEntry
        private integer array ZoneLabels_DeathTransition
        private boolean array ZoneLabels_DeathFrozen
        private integer array ZoneLabels_DeathFrozenValue
        private boolean array ZoneLabels_DeathHasGood
        private integer array ZoneLabels_DeathLastGood
        private integer array ZoneLabels_DeathLegacyMirror
        private string array ZoneLabels_DeathReason
        private integer array ZoneLabels_DeathDifferences
        private integer array ZoneLabels_DeathRepairs
        private boolean array ZoneLabels_DeathMismatch
        private integer array ZoneLabels_DeathMismatchActual
        private integer array ZoneLabels_DeathMismatchPredicted
        private constant integer ZD_DUN_MOROGH = 1
        private constant integer ZD_TIRISFAL = 2
        private constant integer ZD_EVERSONG = 3
        private constant integer ZD_ARATHI = 4
        private constant integer ZD_SILVERPINE = 5
        private constant integer ZD_HINTERLANDS = 6
        private constant integer ZD_HILLSBRAD = 7
        private constant integer ZD_ALTERAC = 8
        private constant integer ZD_REVANTUSK = 9
        private constant integer ZD_WESTERN_PLAGUELANDS = 10
        private constant integer ZD_EASTERN_PLAGUELANDS = 11
        private constant integer ZD_VASHJIR = 12
        private constant integer ZD_HOWLING_FJORD = 13
        private constant integer ZD_GILNEAS = 14
        private constant integer ZD_VALSHARAH = 15
        private constant integer ZD_BULWARK = 16
        private constant integer ZD_WETLANDS = 17
        private constant integer ZD_TWILIGHT_HIGHLANDS = 18
        private constant integer ZD_GHOSTLANDS = 19
        private constant integer ZD_TOL_BARAD = 20
        private constant integer ZD_DALARAN = 21
        private constant integer ZD_STORMHEIM = 22
        private constant integer ZD_SCARLET_ONSLAUGHT = 23
        private constant integer ZD_ARGENT_TOURNAMENT = 24
        private constant integer ZD_DRAGONBLIGHT_ICECROWN = 25
        private constant integer ZD_HINTERLANDS_COAST = 26
    endglobals

    // Define(name, priority) -> label-group ID z.
    // name: displayed zone text. priority: normal-label overlap rank; higher wins.
    // Equal priorities use definition order. This priority also contributes to music overlap rank.
    private function ZoneLabels_Define takes string name, integer priority returns integer
        set ZoneLabels_Count = ZoneLabels_Count + 1
        set ZoneLabels_Areas[ZoneLabels_Count] = CreateRegion()
        set ZoneLabels_Names[ZoneLabels_Count] = name
        set ZoneLabels_Priorities[ZoneLabels_Count] = priority
        return ZoneLabels_Count
    endfunction

    // AddRect(z, r, name).
    // z: group returned by Define. r: editor rectangle to register exactly once.
    // name: diagnostic text for -zone; it does not control the displayed label.
    // Register first, then BindMusic. Use an explicit transition for transition-only coverage.
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

    // BindMusic(r, profile, core).
    // r: already registered place rectangle. profile: an existing ZM_* policy constant.
    // core=true: local music override (+1000 overlap rank), commits despite music buffering.
    // core=false: ordinary ambient music, eligible for retention in a buffered transition.
    // Neither value changes the displayed label or enforces an immediate exit. Missing r is ignored.
    private function ZoneLabels_BindMusic takes rect r, integer profile, boolean core returns nothing
        local integer a = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        if a != 0 then
            set ZoneLabels_PlaceMusic[a] = profile
            set ZoneLabels_PlaceCore[a] = core
        endif
    endfunction

    // BindSanctuary(r, name): mark a registered place as sanctuary geometry.
    // The shared GenericFunctions registry also backs IsUnitInSanctuary.
    // Label/music priority, transitions, and retained labels never extend protection.
    private function ZoneLabels_BindSanctuary takes rect r, string name returns nothing
        local integer place = 0
        local integer sanctuary = 0
        if r == null then
            return
        endif
        set place = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        if place == 0 then
            return
        endif
        set sanctuary = SanctuaryRegisterRect(r)
        if sanctuary != 0 then
            set ZoneLabels_SanctuaryName[sanctuary] = name
        endif
    endfunction

    // AddTransition(r, name, priority, buffer) -> transition ID t.
    // r: transition coverage. name: diagnostic text only, not a zone label.
    // priority: compare with OTHER overlapping transitions; no comparison with label priorities.
    // buffer=true: may retain previous eligible music over ordinary non-core music coverage.
    // buffer=false: normal mapped music commits. Both settings retain/fallback in transition-only gaps.
    // Add all this transition's anchors immediately before declaring the next transition.
    private function ZoneLabels_AddTransition takes rect r, string name, integer priority, boolean buffer returns integer
        local integer t = ZoneLabels_TransitionCount + 1
        set ZoneLabels_TransitionCount = t
        set ZoneLabels_TransitionArea[t] = CreateRegion()
        call RegionAddRect(ZoneLabels_TransitionArea[t], r)
        set ZoneLabels_TransitionName[t] = name
        set ZoneLabels_TransitionPriority[t] = priority
        set ZoneLabels_TransitionBuffer[t] = buffer
        call SaveInteger(ZoneLabels_Index, GetHandleId(r), 1, t)
        set ZoneLabels_AnchorFirst[t] = ZoneLabels_AnchorCount + 1
        set ZoneLabels_AnchorLast[t] = ZoneLabels_AnchorCount
        return t
    endfunction

    // AddAnchor(t, r).
    // t: most recently declared transition. r: already registered neighboring place rectangle.
    // Allows continuity from this place AND nearest-edge fallback for fresh/remote arrivals.
    // Order breaks equal-distance ties. The resolver never searches unlisted places globally.
    private function ZoneLabels_AddAnchor takes integer t, rect r returns nothing
        set ZoneLabels_AnchorCount = ZoneLabels_AnchorCount + 1
        set ZoneLabels_AnchorPlace[ZoneLabels_AnchorCount] = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        set ZoneLabels_AnchorLast[t] = ZoneLabels_AnchorCount
    endfunction

    // AddLatchAnchor(t, r): same parameters as AddAnchor, but continuity-only while regular anchors exist.
    // Walking out of r can retain it. A fresh arrival chooses among regular anchors instead.
    // If no usable regular anchor exists, the current resolver can fall back to a latch-only anchor.
    private function ZoneLabels_AddLatchAnchor takes integer t, rect r returns nothing
        call ZoneLabels_AddAnchor(t, r)
        set ZoneLabels_AnchorLatchOnly[ZoneLabels_AnchorCount] = true
    endfunction

    // GetName(z) -> displayed text for a label-group ID; invalid IDs return empty text.
    // z is a label ID, not a place ID, transition ID, music policy, or revive number.
    function ZoneLabelsGetName takes integer z returns string
        if z < 1 or z > ZoneLabels_Count then
            return ZoneLabels_UNMAPPED_TEXT
        endif
        return ZoneLabels_Names[z]
    endfunction

    // Resolve(x, y) -> winning NORMAL label-group ID, or 0 when no normal coverage matches.
    // x/y: world coordinates. This raw lookup does not apply transition fallback or player history.
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

    // LabelPlace(z, x, y) -> matching place within the winning label group.
    // Local music overrides win place ties, then smaller rectangles; exact ties keep registration order.
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

    // NormalMusicPlace(x, y) -> matching place with an explicit music binding, or 0.
    // Rank is label priority +1000 for core music; smaller rectangles break rank ties.
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

    // ResolveTransition(x, y) -> highest-priority matching transition, or 0.
    // Equal-priority ties keep configuration order; overlapping anchor lists are not merged.
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

    // Eligible(t, a): can place a carry local continuity into transition t?
    // Exact anchors qualify, as do places sharing an anchor's label group AND music policy.
    // Sharing a track/policy alone is insufficient geographic evidence.
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

    // RectDistanceSquared(r, x, y): squared shortest distance to r's edges; 0 inside r.
    // This is not distance to the rectangle center and does not account for terrain/pathing.
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

    // Fallback(t, x, y) -> nearest registered regular anchor place for transition t.
    // Uses latch-only candidates only if no usable regular anchor exists; 0 if none exist.
    private function ZoneLabels_Fallback takes integer t, real x, real y returns integer
        local integer i = ZoneLabels_AnchorFirst[t]
        local integer a = 0
        local integer best = 0
        local integer bestLatch = 0
        local real distance = 0.0
        local real bestDistance = 0.0
        local real bestLatchDistance = 0.0
        loop
            exitwhen i > ZoneLabels_AnchorLast[t]
            set a = ZoneLabels_AnchorPlace[i]
            if a != 0 then
                set distance = ZoneLabels_RectDistanceSquared(ZoneLabels_PlaceRect[a], x, y)
                if ZoneLabels_AnchorLatchOnly[i] then
                    if bestLatch == 0 or distance < bestLatchDistance then
                        set bestLatch = a
                        set bestLatchDistance = distance
                    endif
                elseif best == 0 or distance < bestDistance then
                    set best = a
                    set bestDistance = distance
                endif
            endif
            set i = i + 1
        endloop
        if best == 0 then
            return bestLatch
        endif
        return best
    endfunction

    // TransitionPlace(t, previous, oldTransition, remote, x, y) -> selected place ID.
    // previous: this player's last label OR music place; callers maintain separate histories.
    // oldTransition: transition that last retained that history. remote: continuity invalidated.
    // Local eligible arrivals, or movement within the same latched transition, retain previous.
    // Otherwise choose Fallback(t, x, y); crossing the midpoint does not repeatedly switch it.
    private function ZoneLabels_TransitionPlace takes integer t, integer previous, integer oldTransition, boolean remote, real x, real y returns integer
        if not remote and previous != 0 then
            // Latch a local fallback instead of recomputing it around a midpoint.
            if t == oldTransition or ZoneLabels_Eligible(t, previous) then
                return previous
            endif
        endif
        return ZoneLabels_Fallback(t, x, y)
    endfunction

    // Profile(a) -> effective music policy for place a, including current Gilneas trigger flags.
    // Returns 0 when no ambient policy is currently permitted; no death/ownership assignment occurs.
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

    // Flavor(profile) -> current playback variant. Gilneas classical depends on its control marker.
    // Rechecked while stationary so ownership/music-mode changes do not require a region re-entry.
    private function ZoneLabels_Flavor takes integer profile returns integer
        if profile == ZM_Gilneas_City_Classical then
            if GetOwningPlayer(gg_unit_ncop_1664) == Player(3) then
                return 1
            endif
            return 2
        endif
        return 0
    endfunction



    // NotifyRelocation(p): invalidate player p's continuity at the next update, even for a short teleport.
    // This marks state only; it does not move the hero or immediately play music. Optional ability hook.
    function ZoneLabelsNotifyRelocation takes player p returns nothing
        local integer slot = GetPlayerHeroNumber(p)
        if slot >= 0 and slot <= 7 then
            set ZoneLabels_Relocated[slot] = true
        endif
    endfunction

    // GetSubject(p) -> tracked hero, or its valid live flight carrier while that hero is paused.
    // Returns null if the hero/slot/owner is invalid. Dead heroes retain their identity/position.
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

    // DeathValid(value, horde): allowlist of implemented legacy destination branches.
    // Arrays are populated from actual graveyard handles; 0 is a valid home route.
    // Negative, missing, and faction-unsupported numbers are rejected.
    private function ZoneLabels_DeathValid takes integer value, boolean horde returns boolean
        if value < 0 or value > 24 then
            return false
        endif
        if horde then
            return ZoneLabels_DeathValidH[value]
        endif
        return ZoneLabels_DeathValidA[value]
    endfunction

    // DeathSafe(slot, candidate, horde): candidate -> last valid -> legacy -> home.
    // Never use a policy ID as a raw revive value. Home is verified before takeover can start.
    private function ZoneLabels_DeathSafe takes integer slot, integer candidate, boolean horde returns integer
        if ZoneLabels_DeathValid(candidate, horde) then
            return candidate
        endif
        if ZoneLabels_DeathHasGood[slot] and ZoneLabels_DeathValid(ZoneLabels_DeathLastGood[slot], horde) then
            return ZoneLabels_DeathLastGood[slot]
        endif
        if ZoneLabels_DeathValid(udg_Revives[slot], horde) then
            return udg_Revives[slot]
        endif
        return 0
    endfunction

    // The ONLY udg_Revives write in this library. Comparison mode never writes.
    // Validate at this boundary even if the candidate was validated earlier.
    private function ZoneLabels_DeathCommit takes integer slot, integer candidate, boolean horde returns nothing
        local integer value = 0
        if slot < 0 or slot > 7 or not ZoneLabels_DeathActive then
            return
        endif
        set value = ZoneLabels_DeathSafe(slot, candidate, horde)
        if ZoneLabels_DeathValid(value, horde) then
            if not ZoneLabels_DeathValid(candidate, horde) or not ZoneLabels_DeathValid(udg_Revives[slot], horde) then
                set ZoneLabels_DeathRepairs[slot] = ZoneLabels_DeathRepairs[slot] + 1
            endif
            set udg_Revives[slot] = value
            set ZoneLabels_DeathLastGood[slot] = value
            set ZoneLabels_DeathHasGood[slot] = true
            set ZoneLabels_DeathLegacyMirror[slot] = value
        endif
    endfunction

    // RegisterDeath(policy, name, alliance, horde).
    // policy: named ZD_* ID. name: diagnostic geography. Values: legacy revive numbers or ZD_KEEP.
    private function ZoneLabels_RegisterDeath takes integer policy, string name, integer alliance, integer horde returns nothing
        if policy < 1 or policy > ZoneLabels_DEATH_POLICY_LIMIT then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        if ZoneLabels_DeathPolicyDefined[policy] then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        if (alliance != ZD_KEEP and not ZoneLabels_DeathValid(alliance, false)) or (horde != ZD_KEEP and not ZoneLabels_DeathValid(horde, true)) then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        set ZoneLabels_DeathPolicyDefined[policy] = true
        set ZoneLabels_DeathPolicyName[policy] = name
        set ZoneLabels_DeathPolicyA[policy] = alliance
        set ZoneLabels_DeathPolicyH[policy] = horde
    endfunction

    // DeathPolicyValue(policy, slot): raw destination route for this faction, or ZD_KEEP.
    // Existing IsHordeHero/IsAllianceHero use slots 0..3 / 4..7 respectively.
    private function ZoneLabels_DeathPolicyValue takes integer policy, integer slot returns integer
        if policy < 1 or policy > ZoneLabels_DEATH_POLICY_LIMIT then
            return ZD_KEEP
        endif
        if not ZoneLabels_DeathPolicyDefined[policy] then
            return ZD_KEEP
        endif
        if slot < 4 then
            return ZoneLabels_DeathPolicyH[policy]
        endif
        return ZoneLabels_DeathPolicyA[policy]
    endfunction

    // BindDeath(r, policy): independent death coverage; works for a place OR a transition rectangle.
    // Reuses an existing native region where possible. Register each rectangle once.
    // Overlapping death coverage chooses the smaller rectangle; exact ties keep binding order.
    // Label priorities, music overrides, and transition music-buffer flags do not rank death coverage.
    private function ZoneLabels_BindDeath takes rect r, integer policy returns nothing
        local integer a = 0
        local integer t = 0
        local integer d = 0
        if r == null or policy < 1 or policy > ZoneLabels_DEATH_POLICY_LIMIT then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        if not ZoneLabels_DeathPolicyDefined[policy] then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        if LoadInteger(ZoneLabels_Index, GetHandleId(r), 2) != 0 then
            set ZoneLabels_DeathConfigOK = false
            return
        endif
        set a = LoadInteger(ZoneLabels_Index, GetHandleId(r), 0)
        set t = LoadInteger(ZoneLabels_Index, GetHandleId(r), 1)
        set d = ZoneLabels_DeathCount + 1
        set ZoneLabels_DeathCount = d
        set ZoneLabels_DeathRect[d] = r
        set ZoneLabels_DeathPolicy[d] = policy
        set ZoneLabels_DeathSize[d] = (GetRectMaxX(r) - GetRectMinX(r)) * (GetRectMaxY(r) - GetRectMinY(r))
        if a != 0 then
            set ZoneLabels_DeathArea[d] = ZoneLabels_PlaceArea[a]
            set ZoneLabels_DeathName[d] = ZoneLabels_PlaceName[a]
        elseif t != 0 then
            set ZoneLabels_DeathArea[d] = ZoneLabels_TransitionArea[t]
            set ZoneLabels_DeathName[d] = ZoneLabels_TransitionName[t]
        else
            set ZoneLabels_DeathArea[d] = CreateRegion()
            call RegionAddRect(ZoneLabels_DeathArea[d], r)
            set ZoneLabels_DeathName[d] = "Death-only coverage"
        endif
        call SaveInteger(ZoneLabels_Index, GetHandleId(r), 2, d)
    endfunction

    private function ZoneLabels_DeathRaw takes integer slot, real x, real y returns integer
        local integer d = 1
        local integer best = 0
        local integer value = ZD_KEEP
        loop
            exitwhen d > ZoneLabels_DeathCount
            set value = ZoneLabels_DeathPolicyValue(ZoneLabels_DeathPolicy[d], slot)
            if value != ZD_KEEP and ZoneLabels_DeathValid(value, slot < 4) and IsPointInRegion(ZoneLabels_DeathArea[d], x, y) then
                if best == 0 or ZoneLabels_DeathSize[d] < ZoneLabels_DeathSize[best] then
                    set best = d
                endif
            endif
            set d = d + 1
        endloop
        return best
    endfunction

    // DeathAnchorEntry(anchorIndex, slot): map an explicit place anchor to a faction-valid death entry.
    // Unassigned/opposite-faction anchors are skipped; no global nearest-graveyard search is used.
    private function ZoneLabels_DeathAnchorEntry takes integer anchor, integer slot returns integer
        local integer a = ZoneLabels_AnchorPlace[anchor]
        local integer d = 0
        local integer value = ZD_KEEP
        if a != 0 then
            set d = LoadInteger(ZoneLabels_Index, GetHandleId(ZoneLabels_PlaceRect[a]), 2)
            set value = ZoneLabels_DeathPolicyValue(ZoneLabels_DeathPolicy[d], slot)
            if value != ZD_KEEP and ZoneLabels_DeathValid(value, slot < 4) then
                return d
            endif
        endif
        return 0
    endfunction

    private function ZoneLabels_DeathEligible takes integer t, integer previous, integer slot returns boolean
        local integer i = ZoneLabels_AnchorFirst[t]
        local integer d = 0
        local integer value = ZoneLabels_DeathPolicyValue(ZoneLabels_DeathPolicy[previous], slot)
        if previous == 0 or value == ZD_KEEP then
            return false
        endif
        loop
            exitwhen i > ZoneLabels_AnchorLast[t]
            set d = ZoneLabels_DeathAnchorEntry(i, slot)
            if d != 0 and ZoneLabels_DeathPolicyValue(ZoneLabels_DeathPolicy[d], slot) == value then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    private function ZoneLabels_DeathFallback takes integer t, integer slot, real x, real y returns integer
        local integer i = ZoneLabels_AnchorFirst[t]
        local integer d = 0
        local integer best = 0
        local real distance = 0.0
        local real bestDistance = 0.0
        loop
            exitwhen i > ZoneLabels_AnchorLast[t]
            set d = ZoneLabels_DeathAnchorEntry(i, slot)
            if d != 0 then
                set distance = ZoneLabels_RectDistanceSquared(ZoneLabels_DeathRect[d], x, y)
                if best == 0 or distance < bestDistance then
                    set best = d
                    set bestDistance = distance
                endif
            endif
            set i = i + 1
        endloop
        return best
    endfunction

    // ResolveDeath updates only this player's predicted geography/state, never udg_Revives.
    // Explicit legacy transition death assignments are ordinary death coverage here: preserved on purpose.
    // Only transition-only space WITHOUT an explicit death assignment uses retain/local-anchor fallback.
    private function ZoneLabels_ResolveDeath takes integer slot, unit subject, boolean relocated returns nothing
        local real x = GetUnitX(subject)
        local real y = GetUnitY(subject)
        local real dx = x - ZoneLabels_DeathX[slot]
        local real dy = y - ZoneLabels_DeathY[slot]
        local boolean remote = not ZoneLabels_DeathCache[slot] or subject != ZoneLabels_DeathSubject[slot] or relocated or dx * dx + dy * dy > ZoneLabels_REMOTE_DISTANCE * ZoneLabels_REMOTE_DISTANCE
        local integer d = ZoneLabels_DeathRaw(slot, x, y)
        local integer t = ZoneLabels_ResolveTransition(x, y)
        local integer previous = ZoneLabels_DeathEntry[slot]
        local integer value = ZD_KEEP
        if d != 0 then
            set ZoneLabels_DeathTransition[slot] = 0
            set ZoneLabels_DeathReason[slot] = "EXPLICIT DEATH COVERAGE"
        elseif t != 0 then
            if not remote and previous != 0 and (t == ZoneLabels_DeathTransition[slot] or ZoneLabels_DeathEligible(t, previous, slot)) then
                set d = previous
                set ZoneLabels_DeathReason[slot] = "DEATH TRANSITION RETAINED"
            else
                set d = ZoneLabels_DeathFallback(t, slot, x, y)
                set ZoneLabels_DeathReason[slot] = "LOCAL DEATH ANCHOR"
            endif
            set ZoneLabels_DeathTransition[slot] = t
            if d == 0 then
                set ZoneLabels_DeathReason[slot] = "NO VALID LOCAL DEATH ANCHOR; RETAINED"
            endif
        else
            set ZoneLabels_DeathTransition[slot] = 0
            set ZoneLabels_DeathReason[slot] = "GAP / FACTION-UNASSIGNED; RETAINED"
        endif
        if d != 0 then
            set value = ZoneLabels_DeathPolicyValue(ZoneLabels_DeathPolicy[d], slot)
            if ZoneLabels_DeathValid(value, slot < 4) then
                set ZoneLabels_DeathValue[slot] = value
                set ZoneLabels_DeathEntry[slot] = d
            endif
        endif
        set ZoneLabels_DeathValue[slot] = ZoneLabels_DeathSafe(slot, ZoneLabels_DeathValue[slot], slot < 4)
        set ZoneLabels_DeathX[slot] = x
        set ZoneLabels_DeathY[slot] = y
        set ZoneLabels_DeathSubject[slot] = subject
        set ZoneLabels_DeathCache[slot] = true
    endfunction

    private function ZoneLabels_DeathCompare takes integer slot returns nothing
        local integer actual = udg_Revives[slot]
        local integer predicted = ZoneLabels_DeathValue[slot]
        if actual != predicted then
            if not ZoneLabels_DeathMismatch[slot] or actual != ZoneLabels_DeathMismatchActual[slot] or predicted != ZoneLabels_DeathMismatchPredicted[slot] then
                set ZoneLabels_DeathDifferences[slot] = ZoneLabels_DeathDifferences[slot] + 1
            endif
            set ZoneLabels_DeathMismatch[slot] = true
            set ZoneLabels_DeathMismatchActual[slot] = actual
            set ZoneLabels_DeathMismatchPredicted[slot] = predicted
        else
            set ZoneLabels_DeathMismatch[slot] = false
        endif
    endfunction

    // ObserveDeath: called before the label controller clears its relocation flag.
    // Seeds from StartingPoint/load assignments; caches live positions; resolves once and freezes on death.
    private function ZoneLabels_ObserveDeath takes integer slot, unit subject, boolean relocated returns nothing
        local unit hero = udg_Heroes[slot]
        local integer actual = udg_Revives[slot]
        local boolean dead = false
        if hero == null or subject == null then
            set ZoneLabels_DeathCache[slot] = false
            set hero = null
            return
        endif
        if GetUnitTypeId(hero) == 0 then
            set ZoneLabels_DeathCache[slot] = false
            set hero = null
            return
        endif
        if hero != ZoneLabels_DeathHero[slot] then
            set ZoneLabels_DeathHero[slot] = hero
            set ZoneLabels_DeathFrozen[slot] = false
            set ZoneLabels_DeathCache[slot] = false
            set ZoneLabels_DeathEntry[slot] = 0
            set ZoneLabels_DeathTransition[slot] = 0
            set ZoneLabels_DeathValue[slot] = ZoneLabels_DeathSafe(slot, actual, slot < 4)
            set ZoneLabels_DeathLegacyMirror[slot] = actual
        endif
        if ZoneLabels_DeathValid(actual, slot < 4) then
            set ZoneLabels_DeathLastGood[slot] = actual
            set ZoneLabels_DeathHasGood[slot] = true
            // With GUI assignment blocked, a valid outside write is a start/load/manual reassignment.
            if ZoneLabels_DeathActive and actual != ZoneLabels_DeathLegacyMirror[slot] then
                set ZoneLabels_DeathValue[slot] = actual
                set ZoneLabels_DeathEntry[slot] = 0
                set ZoneLabels_DeathTransition[slot] = 0
                set ZoneLabels_DeathCache[slot] = false
            endif
        endif
        set ZoneLabels_DeathLegacyMirror[slot] = actual
        set dead = IsUnitType(hero, UNIT_TYPE_DEAD) or GetWidgetLife(hero) <= 0.405
        if dead then
            if not ZoneLabels_DeathFrozen[slot] then
                call ZoneLabels_ResolveDeath(slot, hero, relocated)
                set ZoneLabels_DeathFrozenValue[slot] = ZoneLabels_DeathSafe(slot, ZoneLabels_DeathValue[slot], slot < 4)
                set ZoneLabels_DeathFrozen[slot] = true
            endif
            set ZoneLabels_DeathValue[slot] = ZoneLabels_DeathFrozenValue[slot]
        else
            if ZoneLabels_DeathFrozen[slot] then
                set ZoneLabels_DeathFrozen[slot] = false
                set ZoneLabels_DeathCache[slot] = false
            endif
            if not ZoneLabels_DeathCache[slot] or subject != ZoneLabels_DeathSubject[slot] or GetUnitX(subject) != ZoneLabels_DeathX[slot] or GetUnitY(subject) != ZoneLabels_DeathY[slot] or relocated then
                call ZoneLabels_ResolveDeath(slot, subject, relocated)
            endif
        endif
        call ZoneLabels_DeathCommit(slot, ZoneLabels_DeathValue[slot], slot < 4)
        call ZoneLabels_DeathCompare(slot)
        set hero = null
    endfunction

    // Independent observer; comparison mode does not change the existing death trigger's conditions/actions.
    private function ZoneLabels_DeathOnDeath takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local integer slot = 0
        loop
            exitwhen slot > 7
            if u == udg_Heroes[slot] then
                if IsUnitType(u, UNIT_TYPE_DEAD) or GetWidgetLife(u) <= 0.405 then
                    call ZoneLabels_ObserveDeath(slot, u, ZoneLabels_Relocated[slot])
                endif
                set u = null
                return
            endif
            set slot = slot + 1
        endloop
        set u = null
    endfunction

    // PrepareRevive(slot, horde): final guard for the ACTUAL destination handler about to execute.
    // Handles death-before-next-poll and missed observer events. Frozen geography preserves ownership
    // evaluation inside the original Gilneas handler. The original resurrection-at-grave branch remains.
    private function ZoneLabels_DeathPrepareRevive takes integer slot, boolean horde returns boolean
        local unit hero = null
        local integer value = ZD_KEEP
        if slot < 0 or slot > 7 then
            return false
        endif
        set hero = udg_Heroes[slot]
        if hero == null then
            return false
        endif
        if GetUnitTypeId(hero) == 0 then
            set hero = null
            return false
        endif
        call ZoneLabels_ObserveDeath(slot, hero, ZoneLabels_Relocated[slot])
        set value = ZoneLabels_DeathValue[slot]
        if ZoneLabels_DeathFrozen[slot] then
            set value = ZoneLabels_DeathFrozenValue[slot]
        endif
        call ZoneLabels_DeathCommit(slot, value, horde)
        set hero = null
        return ZoneLabels_DeathValid(udg_Revives[slot], horde)
    endfunction

    // The wrappers call the ORIGINAL GUI action bodies, not TriggerExecute on these same triggers.
    // Conditions would not protect TriggerExecute callers; the guard must be the first action.
    private function ZoneLabels_DeathAllianceRevive takes nothing returns nothing
        local integer slot = udg_Temp_Int
        if ZoneLabels_DeathPrepareRevive(slot, false) then
            call Death_Set_Alliance()
        endif
    endfunction

    private function ZoneLabels_DeathHordeRevive takes nothing returns nothing
        local integer slot = udg_Temp_Int
        if ZoneLabels_DeathPrepareRevive(slot, true) then
            call Death_Set_Horde()
        endif
    endfunction

    private function ZoneLabels_AllowLegacyDeath takes nothing returns boolean
        return not ZoneLabels_DeathActive
    endfunction

    private function ZoneLabels_DeathDescribe takes player p, integer slot returns nothing
        local integer d = ZoneLabels_DeathEntry[slot]
        local string mode = "COMPARE: GUI controls deaths"
        local string place = "retained starting/previous assignment"
        local string status = "VALID"
        if ZoneLabels_DeathActive then
            set mode = "ACTIVE: zone death assignments + guarded legacy handlers"
        endif
        if not ZoneLabels_DeathConfigOK then
            set mode = mode + " | CONFIGURATION ERROR: takeover refused"
        endif
        if not ZoneLabels_DeathValid(udg_Revives[slot], slot < 4) then
            set status = "INVALID FOR FACTION"
        endif
        if d != 0 then
            set place = ZoneLabels_DeathName[d] + " / " + ZoneLabels_DeathPolicyName[ZoneLabels_DeathPolicy[d]]
        endif
        call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Deaths " + mode)
        call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Revive actual=" + I2S(udg_Revives[slot]) + " (" + status + ") | predicted=" + I2S(ZoneLabels_DeathValue[slot]) + " | " + ZoneLabels_DeathReason[slot])
        call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Death place: " + place + " | differences=" + I2S(ZoneLabels_DeathDifferences[slot]) + " | repairs=" + I2S(ZoneLabels_DeathRepairs[slot]))
        if ZoneLabels_DeathFrozen[slot] then
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, "Death geography frozen at route " + I2S(ZoneLabels_DeathFrozenValue[slot]) + "; Gilneas ownership still resolves in the original handler.")
        endif
    endfunction

    private function ZoneLabels_DeathDiagnose takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer slot = GetPlayerHeroNumber(p)
        local unit subject = null
        if slot >= 0 and slot <= 7 then
            set subject = ZoneLabelsGetSubject(p)
            if subject != null then
                call ZoneLabels_ObserveDeath(slot, subject, ZoneLabels_Relocated[slot])
            endif
            call ZoneLabels_DeathDescribe(p, slot)
        endif
        set subject = null
        set p = null
    endfunction

    // ConfigureDeath: explicit supported routes, then named faction-aware policies.
    // The seemingly reversed WP/EP routes are preserved exactly; do not infer values from names.
    // Twilight Highlands uses 14 in the actual action. Its old debug message says 16 only.
    private function ZoneLabels_ConfigureDeath takes nothing returns nothing
        set ZoneLabels_DeathValidA[0] = gg_rct_GY_Kharanos != null
        set ZoneLabels_DeathValidA[1] = gg_rct_GY_Arathi != null
        set ZoneLabels_DeathValidA[2] = gg_rct_GY_Hinterland != null
        set ZoneLabels_DeathValidA[3] = gg_rct_GY_Southshore != null
        set ZoneLabels_DeathValidA[4] = gg_rct_GY_Alterac != null
        set ZoneLabels_DeathValidA[5] = gg_rct_GY_EP != null
        set ZoneLabels_DeathValidA[6] = gg_rct_GY_KulTiras != null
        set ZoneLabels_DeathValidA[7] = gg_rct_GY_Westguard != null
        set ZoneLabels_DeathValidA[9] = gg_rct_GY_WP != null
        set ZoneLabels_DeathValidA[10] = gg_rct_GY_Headlands != null and gg_rct_GY_Gilneas_City_Controlled != null
        set ZoneLabels_DeathValidA[11] = gg_rct_GY_Valsharah != null
        set ZoneLabels_DeathValidA[13] = gg_rct_GY_Wetlands != null
        set ZoneLabels_DeathValidA[14] = gg_rct_GY_GrimBatol != null
        set ZoneLabels_DeathValidA[15] = gg_rct_GY_Ghostlands_Alliance != null
        set ZoneLabels_DeathValidA[17] = gg_rct_GY_TolBarad != null
        set ZoneLabels_DeathValidA[20] = gg_rct_Hearth_Dalaran_14 != null
        set ZoneLabels_DeathValidA[21] = gg_rct_GY_Stormheim != null
        set ZoneLabels_DeathValidA[22] = gg_rct_GY_Dragonblight != null
        set ZoneLabels_DeathValidA[23] = gg_rct_Hearth_Argent_Tourney_22 != null
        set ZoneLabels_DeathValidA[24] = gg_rct_Hearth_Wintergarde_Keep_21 != null
        set ZoneLabels_DeathValidH[0] = gg_rct_GY_Brill != null
        set ZoneLabels_DeathValidH[1] = gg_rct_GY_Eversong != null
        set ZoneLabels_DeathValidH[2] = gg_rct_GY_Sepulcher != null
        set ZoneLabels_DeathValidH[3] = gg_rct_GY_Tarren_Mill != null
        set ZoneLabels_DeathValidH[4] = gg_rct_GY_Alterac != null
        set ZoneLabels_DeathValidH[5] = gg_rct_GY_EP != null
        set ZoneLabels_DeathValidH[6] = gg_rct_GY_Zandalar != null
        set ZoneLabels_DeathValidH[7] = gg_rct_GY_Vengance != null
        set ZoneLabels_DeathValidH[8] = gg_rct_GY_Revantusk != null
        set ZoneLabels_DeathValidH[9] = gg_rct_GY_WP != null
        set ZoneLabels_DeathValidH[10] = gg_rct_GY_Headlands != null and gg_rct_GY_Gilneas_City_Controlled != null
        set ZoneLabels_DeathValidH[11] = gg_rct_GY_Valsharah != null
        set ZoneLabels_DeathValidH[12] = gg_rct_GY_Bulwark != null
        set ZoneLabels_DeathValidH[13] = gg_rct_GY_GrimBatol != null
        set ZoneLabels_DeathValidH[14] = gg_rct_GY_GrimBatol != null
        set ZoneLabels_DeathValidH[15] = gg_rct_GY_Ghostlands != null
        set ZoneLabels_DeathValidH[17] = gg_rct_GY_TolBarad != null
        set ZoneLabels_DeathValidH[20] = gg_rct_Hearth_Dalaran_14 != null
        set ZoneLabels_DeathValidH[21] = gg_rct_GY_Stormheim != null
        set ZoneLabels_DeathValidH[22] = gg_rct_GY_Dragonblight != null
        set ZoneLabels_DeathValidH[23] = gg_rct_Hearth_Argent_Tourney_22 != null
        set ZoneLabels_DeathValidH[24] = gg_rct_Hearth_Agmars_Hammer_21 != null
        if not ZoneLabels_DeathValid(0, false) or not ZoneLabels_DeathValid(0, true) then
            set ZoneLabels_DeathConfigOK = false
        endif

        call ZoneLabels_RegisterDeath(ZD_DUN_MOROGH, "Dun Morogh / Loch Modan", 0, ZD_KEEP)
        call ZoneLabels_RegisterDeath(ZD_TIRISFAL, "Tirisfal", ZD_KEEP, 0)
        call ZoneLabels_RegisterDeath(ZD_EVERSONG, "Eversong", ZD_KEEP, 1)
        call ZoneLabels_RegisterDeath(ZD_ARATHI, "Arathi", 1, ZD_KEEP)
        call ZoneLabels_RegisterDeath(ZD_SILVERPINE, "Silverpine", ZD_KEEP, 2)
        call ZoneLabels_RegisterDeath(ZD_HINTERLANDS, "Hinterlands", 2, ZD_KEEP)
        call ZoneLabels_RegisterDeath(ZD_HILLSBRAD, "Hillsbrad", 3, 3)
        call ZoneLabels_RegisterDeath(ZD_ALTERAC, "Alterac", 4, 4)
        call ZoneLabels_RegisterDeath(ZD_REVANTUSK, "Revantusk", 2, 8)
        call ZoneLabels_RegisterDeath(ZD_WESTERN_PLAGUELANDS, "Western Plaguelands - legacy route 5", 5, 5)
        call ZoneLabels_RegisterDeath(ZD_EASTERN_PLAGUELANDS, "Eastern Plaguelands - legacy route 9", 9, 9)
        call ZoneLabels_RegisterDeath(ZD_VASHJIR, "Vashjir / islands", 6, 6)
        call ZoneLabels_RegisterDeath(ZD_HOWLING_FJORD, "Howling Fjord", 7, 7)
        call ZoneLabels_RegisterDeath(ZD_GILNEAS, "Gilneas - ownership resolved by legacy handler", 10, 10)
        call ZoneLabels_RegisterDeath(ZD_VALSHARAH, "Valsharah / Suramar", 11, 11)
        call ZoneLabels_RegisterDeath(ZD_BULWARK, "Bulwark", ZD_KEEP, 12)
        call ZoneLabels_RegisterDeath(ZD_WETLANDS, "Wetlands", 13, 13)
        call ZoneLabels_RegisterDeath(ZD_TWILIGHT_HIGHLANDS, "Twilight Highlands", 14, 14)
        call ZoneLabels_RegisterDeath(ZD_GHOSTLANDS, "Ghostlands", 15, 15)
        call ZoneLabels_RegisterDeath(ZD_TOL_BARAD, "Tol Barad", 17, 17)
        call ZoneLabels_RegisterDeath(ZD_DALARAN, "Dalaran", 20, 20)
        call ZoneLabels_RegisterDeath(ZD_STORMHEIM, "Stormheim / High Mountain", 21, 21)
        call ZoneLabels_RegisterDeath(ZD_SCARLET_ONSLAUGHT, "Scarlet Onslaught / northern islands", 22, 22)
        call ZoneLabels_RegisterDeath(ZD_ARGENT_TOURNAMENT, "Argent Tournament", 23, 23)
        call ZoneLabels_RegisterDeath(ZD_DRAGONBLIGHT_ICECROWN, "Dragonblight / Icecrown", 24, 24)
        call ZoneLabels_RegisterDeath(ZD_HINTERLANDS_COAST, "Hinterlands coast - faction-specific split", 2, 8)
    endfunction

    //=======================================================================
    // PLACE CONFIGURATION - EDIT LABEL AND MUSIC TOGETHER HERE
    // No parameters. Defines label groups, registers places, then binds music and explicit death policy.
    // Music policy metadata is initialized first by ConfigureMusic at startup.
    // Registration order is intentional: equal label/music ties can depend on it.
    //=======================================================================
    private function ZoneLabels_ConfigureLabels takes nothing returns nothing
        local integer z = 0

        // BROAD GEOGRAPHY AND EARLY SUBZONES
        // Keep group order stable: equal label priorities use the first configured group.

        // Tirisfal Glades
        set z = ZoneLabels_Define("Tirisfal Glades", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_Glades_Soliden_Farm_0, "Tirisfal Glades Soliden Farm 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_Glades_Soliden_Farm_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Tirisfal_Glades_Soliden_Farm_0, ZD_TIRISFAL)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_Murloc_Coast_0, "Tirisfal Murloc Coast 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_Murloc_Coast_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Tirisfal_Murloc_Coast_0, ZD_TIRISFAL)
        call ZoneLabels_AddRect(z, gg_rct_Z_Trisfal_Glades_0, "Trisfal Glades 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Trisfal_Glades_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Trisfal_Glades_0, ZD_TIRISFAL)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_Tower_0, "Tirisfal South Tower 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_Tower_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Tirisfal_South_Tower_0, ZD_TIRISFAL)
        call ZoneLabels_AddRect(z, gg_rct_Z_Balnir_and_Bulwark_12, "Balnir and Bulwark 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Balnir_and_Bulwark_12, ZM_Tirisfal_Glades, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Balnir_and_Bulwark_12, ZD_BULWARK)
        // Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Tirisfal_East_Transition_12
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_East_12, "Tirisfal South East 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_East_12, ZM_Tirisfal_Glades, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tirisfal_South_Tower_Sliver_0, "Tirisfal South Tower Sliver 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Tirisfal_South_Tower_Sliver_0, ZM_Tirisfal_Glades, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Crusader_Output_Zone_12, "Crusader Output Zone 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Crusader_Output_Zone_12, ZM_Tirisfal_Glades, false)
        // Venomweb Vale is geographically distinct from Tirisfal; both rectangles share its label.
        set z = ZoneLabels_Define("Venomweb Vale", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Venomweb_Vale_12, "Venomweb Vale 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Venomweb_Vale_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Venomweb_Vale_12, ZD_BULWARK)
        call ZoneLabels_AddRect(z, gg_rct_Z_Venomweb_Vale_East_12, "Venomweb Vale East 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Venomweb_Vale_East_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Venomweb_Vale_East_12, ZD_BULWARK)

        set z = ZoneLabels_Define("The Bulwark", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Bulwark_12, "Bulwark 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Bulwark_12, ZM_Tirisfal_Glades, false)

        set z = ZoneLabels_Define("Deathknell", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_DeathKnell_100, "DeathKnell 100")
        call ZoneLabels_BindMusic(gg_rct_Z_DeathKnell_100, ZM_Deathknell, true)

        // Silverpine Forest
        // Deep_Elem_Mine is reached through SP_Mine_Ext in Silverpine and has its own label below.
        // Shadowfang Keep, Pyrewood, Deep Elm Mine and Ambermill moved to curated location labels.
        // The Gilneas wall's Silverpine-side rectangle also
        // feeds the legacy Silverpine label and Horde revive trigger; include its label.
        set z = ZoneLabels_Define("Silverpine Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_2, "Silverpine 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Silverpine_2, ZD_SILVERPINE)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_West_2, "Silverpine West 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_West_2, ZM_SilverPine_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silverpine_Fenris_Isles_2, "Silverpine Fenris Isles 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Silverpine_Fenris_Isles_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Silverpine_Fenris_Isles_2, ZD_SILVERPINE)
        call ZoneLabels_AddRect(z, gg_rct_Z_Skittering_Dark, "Skittering Dark")
        call ZoneLabels_BindMusic(gg_rct_Z_Skittering_Dark, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Skittering_Dark, ZD_SILVERPINE)
        call ZoneLabels_AddRect(z, gg_rct_SP_Mine_Int, "SP Mine Int")
        call ZoneLabels_BindMusic(gg_rct_SP_Mine_Int, ZM_Skittering_Dark_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Skittering_Dark_Cave_Ext, "Skittering Dark Cave Ext")
        call ZoneLabels_BindMusic(gg_rct_Skittering_Dark_Cave_Ext, ZM_Skittering_Dark_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Silverpine, "South Silverpine")
        call ZoneLabels_BindMusic(gg_rct_Z_South_Silverpine, ZM_SilverPine_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2, "Gilneas Wall Silverpine Side GY Trigger 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2, ZM_SilverPine_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Gilneas_Wall_Silverpine_Side_GY_Trigger_2, ZD_SILVERPINE)

        // The Sepulcher
        set z = ZoneLabels_Define("The Sepulcher", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_The_Sepulcher, "The Sepulcher")

        // Gilneas
        // Ownership affects revives, not this label. No Genn/Nathanos or graveyard logic is changed. Priority 20
        // makes the named Gilneas geography win over broader terrain if rectangles are extended
        // later.
        set z = ZoneLabels_Define("Gilneas", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gil_Mine_Lumber, "Gil Mine Lumber")
        call ZoneLabels_BindMusic(gg_rct_Z_Gil_Mine_Lumber, ZM_Tempest_Reach, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Gil_Mine_Lumber, ZD_GILNEAS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Tol_Barad_Entrance, "Gilneas Tol Barad Entrance")
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Tol_Barad_Entrance, ZM_Tempest_Reach, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Gilneas_Tol_Barad_Entrance, ZD_GILNEAS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Greymane_Manor, "Greymane Manor")
        call ZoneLabels_BindMusic(gg_rct_Z_Greymane_Manor, ZM_Tempest_Reach, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Greymane_Manor, ZD_GILNEAS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tempest_Reach, "Tempest Reach")
        call ZoneLabels_BindMusic(gg_rct_Z_Tempest_Reach, ZM_Tempest_Reach, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Tempest_Reach, ZD_GILNEAS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Duskhaven_Battle_Music, "Duskhaven Battle Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Duskhaven_Battle_Music, ZM_Battle_for_Gilneas, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Emberstone_Mine, "Emberstone Mine")
        call ZoneLabels_BindMusic(gg_rct_Z_Emberstone_Mine, ZM_EmberstoneMine, true)
        call ZoneLabels_AddRect(z, gg_rct_Emberstone_Int, "Emberstone Int")
        call ZoneLabels_BindMusic(gg_rct_Emberstone_Int, ZM_EmberstoneMine, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Grand_Central_Transition, "Gilneas Grand Central Transition")
        call ZoneLabels_BindDeath(gg_rct_Z_Gilneas_Grand_Central_Transition, ZD_GILNEAS)

        set z = ZoneLabels_Define("Light's Dawn Cathedral", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Chapel, "Gilneas Chapel")
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Chapel, ZM_Gilneas_Chapel, true)

        set z = ZoneLabels_Define("Gilneas City", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_City, "Gilneas City")
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_City, ZM_Gilneas_City_Classical, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Gilneas_City, ZD_GILNEAS)

        set z = ZoneLabels_Define("The Witchwood", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_The_WitchWood, "The WitchWood")
        call ZoneLabels_BindMusic(gg_rct_Z_The_WitchWood, ZM_The_WitchWood, true)
        call ZoneLabels_BindDeath(gg_rct_Z_The_WitchWood, ZD_GILNEAS)

        set z = ZoneLabels_Define("Greymane Wall", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gilneas_Wall, "Gilneas Wall")
        call ZoneLabels_BindMusic(gg_rct_Z_Gilneas_Wall, ZM_Gilneas_City_Classical, true)

        // Hillsbrad
        // Azurelode is connected to Hillsbrad by Azurelode_Mine_Ext. The Kobold_Cave interior
        // below has entrances from both Hillsbrad and the Hinterlands path, so it has its own
        // label.
        // Tarren Mill and Dalaran Ruins have their own curated labels below.
        set z = ZoneLabels_Define("Hillsbrad Foothills", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Foothills_3, "Hillsbrad Foothills 3")
        call ZoneLabels_BindMusic(gg_rct_Z_Hillsbrad_Foothills_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hillsbrad_Foothills_3, ZD_HILLSBRAD)
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Hillsbrad_3, "South Hillsbrad 3")
        call ZoneLabels_BindMusic(gg_rct_Z_South_Hillsbrad_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_South_Hillsbrad_3, ZD_HILLSBRAD)
        // Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_North_Hillsbrad_Transition_3
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Foothills_E_3, "Hillsbrad Foothills E 3")
        call ZoneLabels_BindMusic(gg_rct_Z_Hillsbrad_Foothills_E_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hillsbrad_Foothills_E_3, ZD_HILLSBRAD)
        // New death coverage: closes a legacy GUI omission; expected comparison difference here.
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Foothills_Small_E_3, "Hillsbrad Foothills Small E 3")
        call ZoneLabels_BindMusic(gg_rct_Z_Hillsbrad_Foothills_Small_E_3, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hillsbrad_Foothills_Small_E_3, ZD_HILLSBRAD)
        // New death coverage: closes a legacy GUI omission; expected comparison difference here.
        call ZoneLabels_AddRect(z, gg_rct_Z_South_East_Hillsbrad_3, "South East Hillsbrad 3")
        call ZoneLabels_BindMusic(gg_rct_Z_South_East_Hillsbrad_3, ZM_Hillsbrad_M, false)

        set z = ZoneLabels_Define("Durnholde", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Durnholde, "Durnholde")
        call ZoneLabels_BindMusic(gg_rct_Z_Durnholde, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Durnholde, ZD_HILLSBRAD)
        call ZoneLabels_AddRect(z, gg_rct_Z_Durnholde_Small_E, "Durnholde Small E")
        call ZoneLabels_BindMusic(gg_rct_Z_Durnholde_Small_E, ZM_Hillsbrad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Durnholde_Small_E, ZD_HILLSBRAD)
        // New death coverage: closes a legacy GUI omission; expected comparison difference here.

        set z = ZoneLabels_Define("Southshore", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Southshore, "Southshore")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Brill", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Brill, "Brill")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Agmand Mills", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Agmand_Mills, "Agmand Mills")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Kharanos", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Kharanos, "Kharanos")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Thelsamar", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Thelsamar, "Thelsamar")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Azurelode Mine", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Azurelode_Mine, "Azurelode Mine")
        call ZoneLabels_BindMusic(gg_rct_Z_Azurelode_Mine, ZM_Venomweb_Vale_M, true)

        // Tol Barad
        set z = ZoneLabels_Define("Tol Barad", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tol_Barad_17, "Tol Barad 17")
        call ZoneLabels_BindMusic(gg_rct_Z_Tol_Barad_17, ZM_TolBarad_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Tol_Barad_17, ZD_TOL_BARAD)

        // Arathi Highlands
        // Ogre_Mine_Ext and the two ElementalCave entrances connect these interiors to Arathi.
        // Stromgarde, Stromgarde Harbor and Bal'Ric's Lair have curated labels below, which win
        // their overlaps with Arathi and South Hillsbrad.
        set z = ZoneLabels_Define("Arathi Highlands", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Starting_Zone_100, "Arathi Starting Zone 100")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Starting_Zone_100, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Starting_Zone_100, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Starting_Zone_S_100, "Arathi Starting Zone S 100")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Starting_Zone_S_100, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Starting_Zone_S_100, ZD_ARATHI)
        // Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Arathi_Starting_Transition_100
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Passage_1, "Arathi Passage 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Passage_1, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Passage_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_North_1, "Arathi North 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_North_1, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_North_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_North_Graveyard_1, "Arathi North Graveyard 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_North_Graveyard_1, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_North_Graveyard_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_East_1, "Arathi East 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_East_1, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_East_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_West_1, "Arathi West 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_West_1, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_West_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Small_NW, "Z Arathi Small NW")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Small_NW, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Small_NW, ZD_ARATHI)
        // New death coverage: closes a legacy GUI omission; expected comparison difference here.
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Tiny_NW, "Z Arathi Tiny NW")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Tiny_NW, ZM_Arathi_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Tiny_NW, ZD_ARATHI)
        // New death coverage: closes a legacy GUI omission; expected comparison difference here.
        // Transition moved to ZoneLabels_ConfigureTransitions: gg_rct_Z_Hillsbrad_to_Arathi_Transition
        call ZoneLabels_AddRect(z, gg_rct_Z_Ogre_Cave_Music, "Ogre Cave Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Ogre_Cave_Music, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_ElementalCave, "ElementalCave")
        call ZoneLabels_BindMusic(gg_rct_Z_ElementalCave, ZM_Cave_of_the_Elements, true)
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_North, "Kobold Cave North")
        call ZoneLabels_BindMusic(gg_rct_Kobold_Cave_North, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_AddRect(z, gg_rct_Kobold_Cave_South, "Kobold Cave South")
        call ZoneLabels_BindMusic(gg_rct_Kobold_Cave_South, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        // Hinterlands
        // The secret path wins its overlap with eastern Hillsbrad. SecretPathCave uses the
        // Hints_Cave_South entrance. The water cave uses HintWaterCaveWest/East. Sharing cave
        // music does not merge their labels with the Arathi caves.
        set z = ZoneLabels_Define("The Hinterlands", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_2, "Hinterlands 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_2, ZM_Hinterlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_2, ZD_HINTERLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Secret_Path_2, "Hinterlands Secret Path 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Secret_Path_2, ZM_Hinterlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_Secret_Path_2, ZD_HINTERLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Troll_Enclave_2, "Hinterlands Troll Enclave 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Troll_Enclave_2, ZM_Hinterlands_Troll_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_Troll_Enclave_2, ZD_HINTERLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Troll_Boss_2, "Hinterlands Troll Boss 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Troll_Boss_2, ZM_Hinterlands_Troll_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_Troll_Boss_2, ZD_HINTERLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Seaside_2_or_8, "Hinterlands Seaside 2 or 8")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Seaside_2_or_8, ZM_Hinterlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_Seaside_2_or_8, ZD_HINTERLANDS_COAST)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Moonlight, "Hinterlands Moonlight")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Moonlight, ZM_Night_Elf_Shaladnis_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hinterlands_Moonlight, ZD_HINTERLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hinterlands_Dwarf_Cave_2, "Hinterlands Dwarf Cave 2")
        call ZoneLabels_BindMusic(gg_rct_Z_Hinterlands_Dwarf_Cave_2, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        set z = ZoneLabels_Define("Revantusk Village", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Revantusk_8, "Revantusk 8")
        call ZoneLabels_BindMusic(gg_rct_Z_Revantusk_8, ZM_Hinterlands_Troll_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Revantusk_8, ZD_REVANTUSK)

        set z = ZoneLabels_Define("Plaguemist Ravine", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_SecretPathCave, "SecretPathCave")
        call ZoneLabels_BindMusic(gg_rct_Z_SecretPathCave, ZM_Venomweb_Vale_M, true)

        set z = ZoneLabels_Define("Aerie Peak", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Aerie_Peak, "Aerie Peak")
        call ZoneLabels_BindMusic(gg_rct_Z_Aerie_Peak, ZM_AeriePeak_M, true)

        // Alterac
        // Alterac_4_SW wins its overlap with North_Hillsbrad_3.
        set z = ZoneLabels_Define("Alterac Mountains", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_4, "Alterac 4")
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_4, ZM_Alterac_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Alterac_4, ZD_ALTERAC)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_4_SW, "Alterac 4 SW")
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_4_SW, ZM_Alterac_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_North, "Alterac North")
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_North, ZM_Alterac_M, false)

        // Alterac Keep; the detached keep is connected by Alterac_Int/Ext.
        set z = ZoneLabels_Define("Alterac Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Alterac_Keep, "Alterac Keep")
        call ZoneLabels_BindMusic(gg_rct_Z_Alterac_Keep, ZM_Alterac_Keep_M, true)

        // Syndicate Inn; Syndicate_Indoors connects it to Alterac_North.
        set z = ZoneLabels_Define("Dandred's Fold", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Syndacite_Inn, "Syndacite Inn")
        call ZoneLabels_BindMusic(gg_rct_Z_Syndacite_Inn, ZM_Syndicate_Inn, true)

        // Wetlands
        set z = ZoneLabels_Define("Wetlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_13, "Wetlands 13")
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_13, ZM_Wetlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Wetlands_13, ZD_WETLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_Bordering_Grim_Batol, "Wetlands Bordering Grim Batol")
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_Bordering_Grim_Batol, ZM_Wetlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Wetlands_Bordering_Grim_Batol, ZD_WETLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Wetlands_Coast, "Wetlands Coast")
        call ZoneLabels_BindMusic(gg_rct_Z_Wetlands_Coast, ZM_Wetlands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Sludge_Cave_Wetlands, "Sludge Cave Wetlands")
        call ZoneLabels_BindMusic(gg_rct_Z_Sludge_Cave_Wetlands, ZM_Wetlands_Cave_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Sludge_Cave, "Sludge Cave")
        call ZoneLabels_BindMusic(gg_rct_Sludge_Cave, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        // Eversong Woods
        set z = ZoneLabels_Define("Eversong Woods", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Woods_1, "Eversong Woods 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Woods_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Eversong_Woods_1, ZD_EVERSONG)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Murlocs_1, "Eversong Murlocs 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Murlocs_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Eversong_Murlocs_1, ZD_EVERSONG)
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Eversong_1, "South Eversong 1")
        call ZoneLabels_BindMusic(gg_rct_Z_South_Eversong_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_South_Eversong_1, ZD_EVERSONG)
        call ZoneLabels_AddRect(z, gg_rct_Z_South_Eversong_Sliver_1, "South Eversong Sliver 1")
        call ZoneLabels_BindMusic(gg_rct_Z_South_Eversong_Sliver_1, ZM_Eversong_Woods_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_South_Eversong_Sliver_1, ZD_EVERSONG)
        call ZoneLabels_AddRect(z, gg_rct_Z_Sunstrider_Isle_101, "Sunstrider Isle 101")
        call ZoneLabels_BindMusic(gg_rct_Z_Sunstrider_Isle_101, ZM_Eversong_Woods_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silvermoon_Ruins_1, "Silvermoon Ruins 1")
        call ZoneLabels_BindMusic(gg_rct_Z_Silvermoon_Ruins_1, ZM_Silvermoon_Ruins_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Silvermoon_Ruins_1, ZD_EVERSONG)
        call ZoneLabels_AddRect(z, gg_rct_Z_Torwatha, "Torwatha")
        call ZoneLabels_BindMusic(gg_rct_Z_Torwatha, ZM_Jungle_Troll_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Murlocs_EW, "Eversong Murlocs EW")
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Murlocs_EW, ZM_Eversong_Woods_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eversong_Pheonix, "Eversong Pheonix")
        call ZoneLabels_BindMusic(gg_rct_Z_Eversong_Pheonix, ZM_Eversong_Woods_M, false)

        // Shalandis Isle
        set z = ZoneLabels_Define("Shalandis Isle", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Shalandis_Isle, "Shalandis Isle")
        call ZoneLabels_BindMusic(gg_rct_Z_Shalandis_Isle, ZM_Night_Elf_Shaladnis_M, true)

        // Ghostlands
        // The Amani catacombs connect through Amani_North/South_Ext in Ghostlands. They are not
        // assigned to Zandalar merely because the music trigger groups them together.
        // Windrunner Spire and Goldenmist Village have curated labels below.
        set z = ZoneLabels_Define("Ghostlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Center, "Ghostlands Center")
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Center, ZM_Ghostlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Ghostlands_Center, ZD_GHOSTLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_South, "Ghostlands South")
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_South, ZM_Ghostlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Ghostlands_South, ZD_GHOSTLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_West, "Ghostlands West")
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_West, ZM_Windrunner_Spire_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Ghostlands_West, ZD_GHOSTLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dawnstar_Spire, "Dawnstar Spire")
        call ZoneLabels_BindMusic(gg_rct_Z_Dawnstar_Spire, ZM_Windrunner_Spire_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dawnstar_Spire, ZD_GHOSTLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Lake, "Ghostlands Lake")
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Lake, ZM_Ghostlands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Deadscar_Ghostlands_North, "Deadscar Ghostlands North")
        call ZoneLabels_BindMusic(gg_rct_Z_Deadscar_Ghostlands_North, ZM_Ghostlands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ghostlands_Far_North, "Ghostlands Far North")
        call ZoneLabels_BindMusic(gg_rct_Z_Ghostlands_Far_North, ZM_Ghostlands_M, false)

        set z = ZoneLabels_Define("Amani Catacombs", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Amani_Catacombs, "Amani Catacombs")
        call ZoneLabels_BindMusic(gg_rct_Z_Amani_Catacombs, ZM_Zandalar_n_Zulaman_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Amani_Catacombs, ZD_GHOSTLANDS)

        // Western Plaguelands
        // Weeping_Cave_Mine_Entrance is in Western Plaguelands.
        set z = ZoneLabels_Define("Western Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_5, "Western Plaguelands 5")
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Western_Plaguelands_5, ZD_WESTERN_PLAGUELANDS)
        // Explicit WP label here; no direct music binding so entry music can continue.
        // The same rectangle remains a buffered transition, with its death policy bound there.
        call ZoneLabels_AddRect(z, gg_rct_Z_WP_Transition_5, "WP Transition 5")
        // Transition also configured in ZoneLabels_ConfigureTransitions: gg_rct_Z_WP_Transition_5
        call ZoneLabels_AddRect(z, gg_rct_Z_Weeping_Cave_WP, "Weeping Cave WP")
        call ZoneLabels_BindMusic(gg_rct_Z_Weeping_Cave_WP, ZM_Ogre_Konold_Sludge_Golem_Cave, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_North_5, "Western Plaguelands North 5")
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_North_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_Dwarf_Farm_5, "Western Plaguelands Dwarf Farm 5")
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_Dwarf_Farm_5, ZM_Western_Plaguelands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Western_Plaguelands_East_5, "Western Plaguelands East 5")
        call ZoneLabels_BindMusic(gg_rct_Z_Western_Plaguelands_East_5, ZM_Western_Plaguelands_M, false)

        set z = ZoneLabels_Define("The Mender's Stead", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_MoonWell_WP, "MoonWell WP")
        call ZoneLabels_BindMusic(gg_rct_Z_MoonWell_WP, ZM_Night_Elf_Shaladnis_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_MoonWell_WP, ZD_WESTERN_PLAGUELANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_The_Menders_Stead, "The Menders Stead")
        call ZoneLabels_BindDeath(gg_rct_Z_The_Menders_Stead, ZD_WESTERN_PLAGUELANDS)

        set z = ZoneLabels_Define("Hearthglen", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hearthglen, "Hearthglen")
        call ZoneLabels_BindSanctuary(gg_rct_Z_Hearthglen, "Hearthglen")
        call ZoneLabels_BindMusic(gg_rct_Z_Hearthglen, ZM_Hearthglen, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hearthglen, ZD_WESTERN_PLAGUELANDS)

        set z = ZoneLabels_Define("Uther's Tomb", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Uthers_Grave_Music, "Uthers Grave Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Uthers_Grave_Music, ZM_Uthers_Grave_M, true)

        // Eastern Plaguelands
        // REVIEW PARENT: Cryptlord_Music is mostly INSIDE Eastern_Plaguelands_9. This follows that
        // geographical rectangle, despite the older music trigger being called GY WP M.
        set z = ZoneLabels_Define("Eastern Plaguelands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eastern_Plaguelands_9, "Eastern Plaguelands 9")
        call ZoneLabels_BindMusic(gg_rct_Z_Eastern_Plaguelands_9, ZM_Eastern_Plaguelands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Eastern_Plaguelands_9, ZD_EASTERN_PLAGUELANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_KT_Music_9, "KT Music 9")
        call ZoneLabels_BindMusic(gg_rct_Z_KT_Music_9, ZM_KelThuzad_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_KT_Music_9, ZD_EASTERN_PLAGUELANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Scarlet_Enclave_9, "Scarlet Enclave 9")
        call ZoneLabels_BindMusic(gg_rct_Z_Scarlet_Enclave_9, ZM_KelThuzad_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Scarlet_Enclave_9, ZD_EASTERN_PLAGUELANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Eastern_Plaguelands_Tower_Graveyard_Music, "Eastern Plaguelands Tower Graveyard Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Eastern_Plaguelands_Tower_Graveyard_Music, ZM_GY_WP_M, true)

        // Dun Morogh
        set z = ZoneLabels_Define("Dun Morogh", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_Starting_101, "Dun Morogh Starting 101")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_Starting_101, ZM_Dun_Morogh_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dun_Morogh_Starting_101, ZD_DUN_MOROGH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_0, "Dun Morogh 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_0, ZM_Dun_Morogh_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dun_Morogh_0, ZD_DUN_MOROGH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_South, "Dun Morogh South")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_South, ZM_Dun_Morogh_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dun_Morogh_South, ZD_DUN_MOROGH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gnome_Cave_0, "Gnome Cave 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Gnome_Cave_0, ZM_Dwarf_Cave, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Gnome_Cave_0, ZD_DUN_MOROGH)

        // Loch Modan
        set z = ZoneLabels_Define("Loch Modan", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Loch_Modan_0, "Loch Modan 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Loch_Modan_0, ZM_Loch_Modan_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Loch_Modan_0, ZD_DUN_MOROGH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Loch_Modan_Farstrider_Lodge_0, "Loch Modan Farstrider Lodge 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Loch_Modan_Farstrider_Lodge_0, ZM_Loch_Modan_M, false)

        // Twilight Highlands
        set z = ZoneLabels_Define("Twilight Highlands", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_North_14, "Twighlight Highlands North 14")
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_North_14, ZM_Twilight_Highlands_North, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Twighlight_Highlands_North_14, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_Delta, "Twighlight Highlands Delta")
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_Delta, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Twighlight_Highlands_Delta, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness, "Twighlight Highlands Maw Of Madness")
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Twighlight_Highlands_Maw_Of_Madness, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Obsdian_Forest, "Obsdian Forest")
        call ZoneLabels_BindMusic(gg_rct_Z_Obsdian_Forest, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Obsdian_Forest, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Obsdian_Forest_Mini, "Obsdian Forest Mini")
        call ZoneLabels_BindMusic(gg_rct_Z_Obsdian_Forest_Mini, ZM_Twilight_Highlands_South, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Obsdian_Forest_Mini, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Twighlight_Highlands_16, "Twighlight Highlands 16")
        call ZoneLabels_BindMusic(gg_rct_Z_Twighlight_Highlands_16, ZM_Twilight_Highlands_North, false)

        // The Krazzworks
        set z = ZoneLabels_Define("The Krazzworks", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_The_Krazzworks, "The Krazzworks")
        call ZoneLabels_BindMusic(gg_rct_Z_The_Krazzworks, ZM_Goblin_Music, true)
        call ZoneLabels_BindDeath(gg_rct_Z_The_Krazzworks, ZD_TWILIGHT_HIGHLANDS)

        // Dragonmaw Port
        set z = ZoneLabels_Define("Dragonmaw Port", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonmaw_Port_14, "Dragonmaw Port 14")
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonmaw_Port_14, ZM_Orc_Music_Dragonmaw_Port, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dragonmaw_Port_14, ZD_TWILIGHT_HIGHLANDS)

        // Highbank
        set z = ZoneLabels_Define("Highbank", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Highbank_14, "Highbank 14")
        call ZoneLabels_BindMusic(gg_rct_Z_Highbank_14, ZM_Highbank, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Highbank_14, ZD_TWILIGHT_HIGHLANDS)

        // Howling Fjord
        set z = ZoneLabels_Define("Howling Fjord", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_East_7, "Howling Fjord East 7")
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_East_7, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Howling_Fjord_East_7, ZD_HOWLING_FJORD)
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_West_7, "Howling Fjord West 7")
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_West_7, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Howling_Fjord_West_7, ZD_HOWLING_FJORD)
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_Forsaken, "Howling Fjord Forsaken")
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_Forsaken, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Howling_Fjord_Forsaken, ZD_HOWLING_FJORD)
        call ZoneLabels_AddRect(z, gg_rct_Z_Sindragosa_Music, "Sindragosa Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Sindragosa_Music, ZM_HowlingFjord_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Sindragosa_Music, ZD_HOWLING_FJORD)
        call ZoneLabels_AddRect(z, gg_rct_Z_Howling_Fjord_Central, "Howling Fjord Central")
        call ZoneLabels_BindMusic(gg_rct_Z_Howling_Fjord_Central, ZM_HowlingFjord_M, false)

        // Grizzly Hills
        set z = ZoneLabels_Define("Grizzly Hills", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Grizzlemaw, "Grizzlemaw")
        call ZoneLabels_BindMusic(gg_rct_Z_Grizzlemaw, ZM_Grizzly_Hills_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Grizzlemaw, ZD_HOWLING_FJORD)

        // Amberpine Lodge
        set z = ZoneLabels_Define("Amberpine Lodge", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Grizzly_Hills_Amberpine, "Grizzly Hills Amberpine")
        call ZoneLabels_BindMusic(gg_rct_Z_Grizzly_Hills_Amberpine, ZM_Grizzly_Hills_M, false)

        // Dun Argol
        set z = ZoneLabels_Define("Dun Argol", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Argol, "Dun Argol")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Argol, ZM_Grizzly_Hills_M, false)

        // Zul'Drak
        set z = ZoneLabels_Define("Zul'Drak", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zul_Drak, "Zul Drak")
        call ZoneLabels_BindMusic(gg_rct_Z_Zul_Drak, ZM_Zul_Drak_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zul_Drak_E, "Zul Drak E")
        call ZoneLabels_BindMusic(gg_rct_Z_Zul_Drak_E, ZM_Zul_Drak_M, false)

        // Dragonblight
        set z = ZoneLabels_Define("Dragonblight", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_North, "Dragonblight North")
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_North, ZM_Dragonblight_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dragonblight_North, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_Central, "Dragonblight Central")
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_Central, ZM_Dragonblight_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dragonblight_Central, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_West, "Dragonblight West")
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_West, ZM_Dragonblight_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dragonblight_West, ZD_DRAGONBLIGHT_ICECROWN)

        // Maoki Harbor
        set z = ZoneLabels_Define("Maoki Harbor", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Maoki_Harbor, "Maoki Harbor")
        call ZoneLabels_BindMusic(gg_rct_Z_Maoki_Harbor, ZM_Tuskar, true)

        // Icecrown
        set z = ZoneLabels_Define("Icecrown", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_Central, "Icecrown Central")
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_Central, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Icecrown_Central, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_East, "Icecrown East")
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_East, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Icecrown_East, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_South, "Icecrown South")
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_South, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Icecrown_South, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_West, "Icecrown West")
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_West, ZM_Ice_Crown_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Icecrown_West, ZD_DRAGONBLIGHT_ICECROWN)
        call ZoneLabels_AddRect(z, gg_rct_Z_Icecrown_Glacier, "Icecrown Glacier")
        call ZoneLabels_BindMusic(gg_rct_Z_Icecrown_Glacier, ZM_Lich_King_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Icecrown_Glacier, ZD_DRAGONBLIGHT_ICECROWN)

        // Crystalsong Forest
        set z = ZoneLabels_Define("Crystalsong Forest", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_E, "Crystal Song E")
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_E, ZM_Crystalsong_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_M, "Crystal Song M")
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_M, ZM_Crystalsong_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Crystal_Song_W, "Crystal Song W")
        call ZoneLabels_BindMusic(gg_rct_Z_Crystal_Song_W, ZM_Crystalsong_M, false)

        // Storm Peaks
        // Takes precedence at the shared edge with Crystalsong Forest.
        set z = ZoneLabels_Define("Storm Peaks", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Storm_Peaks, "Storm Peaks")
        call ZoneLabels_BindMusic(gg_rct_Z_Storm_Peaks, ZM_Storm_Peaks_M, false)

        // Valsharah
        set z = ZoneLabels_Define("Val'sharah", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Valsharah_11, "Valsharah 11")
        call ZoneLabels_BindSanctuary(gg_rct_Z_Valsharah_11, "Val'sharah")
        call ZoneLabels_BindMusic(gg_rct_Z_Valsharah_11, ZM_Valshara, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Valsharah_11, ZD_VALSHARAH)

        // Suramar
        set z = ZoneLabels_Define("Suramar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_North, "Suramar North")
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_North, ZM_Suramar_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Suramar_North, ZD_VALSHARAH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar, "Suramar")
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar, ZM_Suramar_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Suramar, ZD_VALSHARAH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_Fel, "Suramar Fel")
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_Fel, ZM_Suramar_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Suramar_South, "Suramar South")
        call ZoneLabels_BindMusic(gg_rct_Z_Suramar_South, ZM_Suramar_M, false)

        // Stormheim
        set z = ZoneLabels_Define("Stormheim", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Stormheim_South, "Stormheim South")
        call ZoneLabels_BindMusic(gg_rct_Z_Stormheim_South, ZM_Stormheim, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Stormheim_South, ZD_STORMHEIM)
        call ZoneLabels_AddRect(z, gg_rct_Z_Stormheim_North, "Stormheim North")
        call ZoneLabels_BindMusic(gg_rct_Z_Stormheim_North, ZM_Stormheim, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Stormheim_North, ZD_STORMHEIM)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hrydshal, "Hrydshal")
        call ZoneLabels_BindMusic(gg_rct_Z_Hrydshal, ZM_Utguarde_Hrydshal_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hrydshal, ZD_STORMHEIM)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hyrja_Island, "Hyrja Island")
        call ZoneLabels_BindMusic(gg_rct_Z_Hyrja_Island, ZM_Utguarde_Hrydshal_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hyrja_Island, ZD_STORMHEIM)

        // High Mountain
        set z = ZoneLabels_Define("High Mountain", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_High_Mountain, "High Mountain")
        call ZoneLabels_BindMusic(gg_rct_Z_High_Mountain, ZM_High_Mountain, false)
        call ZoneLabels_BindDeath(gg_rct_Z_High_Mountain, ZD_STORMHEIM)

        // Vashjir
        set z = ZoneLabels_Define("Vashj'ir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Vashjir_6, "Vashjir 6")
        call ZoneLabels_BindMusic(gg_rct_Z_Vashjir_6, ZM_VashJir_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Vashjir_6, ZD_VASHJIR)

        // Kul Tiras
        // Uses the named landmass rectangle, not revive ID 6, which is also shared with Vashjir
        // and other locations.
        set z = ZoneLabels_Define("Kul Tiras", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_KulTiras_6, "KulTiras 6")
        call ZoneLabels_BindDeath(gg_rct_Z_KulTiras_6, ZD_VASHJIR)
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        // Zandalar
        set z = ZoneLabels_Define("Zandalar", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zandalar_6, "Zandalar 6")
        call ZoneLabels_BindMusic(gg_rct_Z_Zandalar_6, ZM_Zandalar_n_Zulaman_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Zandalar_6, ZD_VASHJIR)

        // Nazmir
        set z = ZoneLabels_Define("Nazmir", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Nazmir, "Nazmir")
        call ZoneLabels_BindMusic(gg_rct_Z_Nazmir, ZM_Nazmir_M, true)

        // Curated location labels take precedence over their broader parent labels.
        // ADDITIONAL NAMED LOCATIONS, CITIES, AND INTERIORS
        // These remain in their original order to preserve equal-priority overlap behavior.

        // Chillwind Camp
        set z = ZoneLabels_Define("Chillwind Camp", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Chillwind_Camp, "Chillwind Camp")
        // Intentionally no local music binding: retain/inherit ambient audio.
        // The 7.3 dedicated Chillwind test policy is kept below but not active here.
        call ZoneLabels_BindMusic(gg_rct_Z_Chillwind_Camp, ZM_Chillwind_Camp, false)

        // Light's Hope; this larger rectangle surrounds the older EP label area.
        // Sanctuary protection is bound independently to the existing Lights_Hope_9 bounds above.
        set z = ZoneLabels_Define("Light's Hope", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Lights_Hope_Santuary, "Lights Hope Santuary")
        call ZoneLabels_BindMusic(gg_rct_Z_Lights_Hope_Santuary, ZM_Lights_Hope, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Lights_Hope_9, "Lights Hope 9")
        call ZoneLabels_BindSanctuary(gg_rct_Z_Lights_Hope_9, "Light's Hope")
        call ZoneLabels_BindMusic(gg_rct_Z_Lights_Hope_9, ZM_Lights_Hope, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Lights_Hope_9, ZD_EASTERN_PLAGUELANDS)

        // Detached seal/penguin cave belongs to Howling Fjord; requested label is Northrend.
        set z = ZoneLabels_Define("The Lonely Cave", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Lots_O_Seels_n_Penwens_Music, "Lots O Seels n Penwens Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Lots_O_Seels_n_Penwens_Music, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        // Stromgarde city proper. The outer and inner harbor rectangles use a separate label.
        set z = ZoneLabels_Define("Stromgarde", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_StromGarde_1, "StromGarde 1")
        call ZoneLabels_BindMusic(gg_rct_Z_StromGarde_1, ZM_StromGuarde_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_StromGarde_1, ZD_ARATHI)

        // Stromgarde Harbor: the outer harbor and the combined zone/quest inner harbor. Quest and
        // cannon reset logic remain active. Only the outer harbor has the city ambient track.
        set z = ZoneLabels_Define("Stromgarde Harbor", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_StromGarde_Harbor_1, "StromGarde Harbor 1")
        call ZoneLabels_BindMusic(gg_rct_Z_StromGarde_Harbor_1, ZM_StromGuarde_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_StromGarde_Harbor_1, ZD_ARATHI)
        call ZoneLabels_AddRect(z, gg_rct_ZQ_StromGarde_Inner_Harbor, "and Q StromGarde Inner Harbor")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        // Curated named locations. Priority 30 wins over their overlapping parent-zone geometry;
        // their music bindings are beside each rectangle and several keep the parent's policy.
        set z = ZoneLabels_Define("Agmar's Hammer", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Agmars_Hammer, "Agmars Hammer")
        call ZoneLabels_BindMusic(gg_rct_Z_Agmars_Hammer, ZM_Agmars_Hammer_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Agmars_Hammer, ZD_DRAGONBLIGHT_ICECROWN)

        set z = ZoneLabels_Define("Bal'Ric's Lair", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Arathi_Ogres_Boss, "Arathi Ogres Boss")
        call ZoneLabels_BindMusic(gg_rct_Z_Arathi_Ogres_Boss, ZM_Balric, true)

        set z = ZoneLabels_Define("Dalaran Ruins", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_Crater_3, "Dalaran Crater 3")
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_Crater_3, ZM_Dalaran_Crater_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dalaran_Crater_3, ZD_HILLSBRAD)

        set z = ZoneLabels_Define("Tarren Mill", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tarren_Mill_Music_3, "Tarren Mill Music 3")
        call ZoneLabels_BindMusic(gg_rct_Z_Tarren_Mill_Music_3, ZM_TarrenMill, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Tarren_Mill_Music_3, ZD_HILLSBRAD)

        set z = ZoneLabels_Define("Hillsbrad Fields", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Hillsbrad_Fields, "Hillsbrad Fields")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        set z = ZoneLabels_Define("Ambermill", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ambermill, "Ambermill")

        set z = ZoneLabels_Define("Ambermill Cave", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ambermill_Cave, "Ambermill Cave")
        call ZoneLabels_BindMusic(gg_rct_Z_Ambermill_Cave, ZM_Skittering_Dark_M, true)

        set z = ZoneLabels_Define("Pyrewood Village", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Pyrewood_Village, "Pyrewood Village")
        call ZoneLabels_BindMusic(gg_rct_Z_Pyrewood_Village, ZM_Pyrewood, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Pyrewood_Village, ZD_SILVERPINE)

        set z = ZoneLabels_Define("Shadowfang Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Shadowfang_Keep, "Shadowfang Keep")
        call ZoneLabels_BindMusic(gg_rct_Z_Shadowfang_Keep, ZM_Shadowfang_Keep_M, true)

        set z = ZoneLabels_Define("Deep Elm Mine", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Deep_Elem_Mine, "Deep Elem Mine")
        call ZoneLabels_BindMusic(gg_rct_Z_Deep_Elem_Mine, ZM_Skittering_Dark_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Deep_Elem_Mine, ZD_SILVERPINE)

        set z = ZoneLabels_Define("Andorhal", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Andorhal_5, "Andorhal 5")
        // call ZoneLabels_BindMusic(gg_rct_Z_Andorhal_5, ZM_Andorhal_M, true)
        call ZoneLabels_BindMusic(gg_rct_Z_Andorhal_5, ZM_Tirisfal_Glades, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Andorhal_5, ZD_WESTERN_PLAGUELANDS)

        set z = ZoneLabels_Define("Greenwarden's Grove", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Greenwardens_Grove, "Greenwardens Grove")
        call ZoneLabels_BindMusic(gg_rct_Z_Greenwardens_Grove, ZM_Greenwardens_Grove_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Greenwardens_Grove, ZD_WETLANDS)

        set z = ZoneLabels_Define("Vermillion Redoubt", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Vemillion_Redoubt, "Vemillion Redoubt")
        call ZoneLabels_BindSanctuary(gg_rct_Z_Vemillion_Redoubt, "Vermillion Redoubt")
        call ZoneLabels_BindMusic(gg_rct_Z_Vemillion_Redoubt, ZM_Vermillion_Redoubt, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Vemillion_Redoubt, ZD_TWILIGHT_HIGHLANDS)

        set z = ZoneLabels_Define("Windrunner Spire", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Windrunner_Spire, "Windrunner Spire")
        call ZoneLabels_BindMusic(gg_rct_Z_Windrunner_Spire, ZM_Windrunner_Spire_M, true)

        set z = ZoneLabels_Define("Deatholme", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Deatholme, "Deatholme")
        call ZoneLabels_BindMusic(gg_rct_Z_Deatholme, ZM_Ghostlands_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Deatholme, ZD_GHOSTLANDS)

        set z = ZoneLabels_Define("Goldenmist Village", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Goldenmist_Village_North, "Goldenmist Village North")
        call ZoneLabels_BindMusic(gg_rct_Z_Goldenmist_Village_North, ZM_Ghostlands_M, false)
        call ZoneLabels_AddRect(z, gg_rct_Z_Goldenmist_Village_South, "Goldenmist Village South")
        call ZoneLabels_BindMusic(gg_rct_Z_Goldenmist_Village_South, ZM_Ghostlands_M, false)
        // Ghostlands Alliance GY is intentionally not a label area.
        // Thoradins_Wall_1 (formerly _Copy) remains deferred: fully inside the
        // Hillsbrad-to-Arathi transition, with no existing runtime consumers.

        // The Undercity
        set z = ZoneLabels_Define("The Undercity", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Undercity, "Undercity")
        call ZoneLabels_BindMusic(gg_rct_Z_Undercity, ZM_Undercity, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Undercity, ZD_TIRISFAL)

        // Silvermoon
        set z = ZoneLabels_Define("Silvermoon", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Silvermoon, "Silvermoon")
        call ZoneLabels_BindMusic(gg_rct_Z_Silvermoon, ZM_Silvermoon_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Silvermoon, ZD_EVERSONG)

        // Scarlet Monastery
        set z = ZoneLabels_Define("Scarlet Monastery", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Scarlet_Monastery_12, "Scarlet Monastery 12")
        call ZoneLabels_BindMusic(gg_rct_Z_Scarlet_Monastery_12, ZM_Venomweb_Vale_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Scarlet_Monastery_12, ZD_BULWARK)

        // Scholomance
        set z = ZoneLabels_Define("Scholomance", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Scholomance_Music, "Scholomance Music")
        call ZoneLabels_BindMusic(gg_rct_Z_Scholomance_Music, ZM_Scholomance_M, true)

        // Stratholme
        set z = ZoneLabels_Define("Stratholme", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Stratholme, "Stratholme")
        call ZoneLabels_BindMusic(gg_rct_Z_Stratholme, ZM_Stratholme_M, true)

        // Naxxramas
        // Wins the 32-unit strip shared with the Scholomance_Music rectangle.
        set z = ZoneLabels_Define("Naxxramas", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Naxxramas, "Naxxramas")
        call ZoneLabels_BindMusic(gg_rct_Z_Naxxramas, ZM_Naxxramas_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Naxxramas, ZD_EASTERN_PLAGUELANDS)

        // Dalaran
        set z = ZoneLabels_Define("Dalaran", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_City, "Dalaran City")
        call ZoneLabels_BindSanctuary(gg_rct_Z_Dalaran_City, "Dalaran")
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_City, ZM_Dalaran_Enter, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dalaran_City, ZD_DALARAN)

        // Dalaran Portal Room
        set z = ZoneLabels_Define("Dalaran Portal Room", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dalaran_Portal_Room, "Dalaran Portal Room")
        call ZoneLabels_BindMusic(gg_rct_Z_Dalaran_Portal_Room, ZM_Dalaran_Enter, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dalaran_Portal_Room, ZD_DALARAN)

        // Scarlet Onslaught
        set z = ZoneLabels_Define("Scarlet Onslaught", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dragonblight_Scarlet_Onslaught, "Dragonblight Scarlet Onslaught")
        call ZoneLabels_BindMusic(gg_rct_Z_Dragonblight_Scarlet_Onslaught, ZM_Dragonblight_M, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Dragonblight_Scarlet_Onslaught, ZD_SCARLET_ONSLAUGHT)

        // Argent Tournament
        set z = ZoneLabels_Define("Argent Tournament", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Argent_Tournament, "Argent Tournament")
        call ZoneLabels_BindMusic(gg_rct_Z_Argent_Tournament, ZM_Argent_Tournament_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Argent_Tournament, ZD_ARGENT_TOURNAMENT)

        // Azjol Nerub
        set z = ZoneLabels_Define("Azjol Nerub", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Azjol_Nerub, "Azjol Nerub")
        call ZoneLabels_BindMusic(gg_rct_Z_Azjol_Nerub, ZM_Azjol_Nerub_M, true)

        // Ulduar
        // Wins the 32-unit strip shared with Azjol_Nerub.
        set z = ZoneLabels_Define("Ulduar", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ulduar_Dungeon, "Ulduar Dungeon")
        call ZoneLabels_BindMusic(gg_rct_Z_Ulduar_Dungeon, ZM_Ulduar_M, true)

        // Utgarde Keep
        set z = ZoneLabels_Define("Utgarde Keep", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Utguarde_Keep, "Utguarde Keep")
        call ZoneLabels_BindMusic(gg_rct_Z_Utguarde_Keep, ZM_Utguarde_Hrydshal_M, true)

        // Zulaman
        set z = ZoneLabels_Define("Zul'Aman", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Zulaman, "Zulaman")
        call ZoneLabels_BindMusic(gg_rct_Z_Zulaman, ZM_Zandalar_n_Zulaman_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Zulaman, ZD_GHOSTLANDS)

        // Sunwell Plateau
        set z = ZoneLabels_Define("Sunwell Plateau", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Sunwell_Plateau, "Sunwell Plateau")
        call ZoneLabels_BindMusic(gg_rct_Z_Sunwell_Plateau, ZM_Sunwell_M, true)

        // Bastion of Twilight
        set z = ZoneLabels_Define("Bastion of Twilight", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Bastion_of_Twilight_14, "Bastion of Twilight 14")
        call ZoneLabels_BindMusic(gg_rct_Z_Bastion_of_Twilight_14, ZM_Bastion_of_Twilight, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Bastion_of_Twilight_14, ZD_TWILIGHT_HIGHLANDS)
        call ZoneLabels_AddRect(z, gg_rct_Z_Bastion_of_Twilight_South, "Bastion of Twilight South")
        call ZoneLabels_BindMusic(gg_rct_Z_Bastion_of_Twilight_South, ZM_Bastion_of_Twilight, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Bastion_of_Twilight_South, ZD_TWILIGHT_HIGHLANDS)

        // Ironforge-named geometry / legacy Grim Batol music.
        // Keep the authored display name below; old rectangle/music names do not determine it.
        set z = ZoneLabels_Define("Ironforge", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ironforge_0, "Ironforge 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Ironforge_0, ZM_Grim_Batol_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Ironforge_0, ZD_DUN_MOROGH)
        call ZoneLabels_AddRect(z, gg_rct_Z_Ironforge_Magni_0, "Ironforge Magni 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Ironforge_Magni_0, ZM_Grim_Batol_M, true)

        // Grim Batol Volcano
        set z = ZoneLabels_Define("Ragnaros's Lair", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Grim_Batol_Volcano, "Ragnaros's Lair")
        call ZoneLabels_BindMusic(gg_rct_Z_Grim_Batol_Volcano, ZM_RagnarosLair, true)

        // Karazhan
        set z = ZoneLabels_Define("Karazhan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Karazhan, "Karazhan")
        call ZoneLabels_BindMusic(gg_rct_Z_Karazhan, ZM_Karazhan, true)

        // Deadwind Pass
        set z = ZoneLabels_Define("Deadwind Pass", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Deadwind_Pass, "Deadwind Pass")
        // No direct ambient binding: use overlapping music coverage, otherwise retain audio.

        // Neltharions Lair
        set z = ZoneLabels_Define("Neltharions Lair", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Nelfarions_Lair, "Nelfarions Lair")
        call ZoneLabels_BindMusic(gg_rct_Z_Nelfarions_Lair, ZM_NelfarionsLair, true)

        // Chromie's Inn
        set z = ZoneLabels_Define("Chromie's Inn", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_ChromieInn, "ChromieInn")
        call ZoneLabels_BindSanctuary(gg_rct_Z_ChromieInn, "Chromie's Inn")
        call ZoneLabels_BindMusic(gg_rct_Z_ChromieInn, ZM_ChromieInn, true)

        // Gjalerbron
        set z = ZoneLabels_Define("Gjalerbron", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Gjalerbron, "Gjalerbron")
        call ZoneLabels_BindMusic(gg_rct_Z_Gjalerbron, ZM_Vrykul_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Gjalerbron, ZD_SCARLET_ONSLAUGHT)

        // Blue Dragon Island
        set z = ZoneLabels_Define("Scalawag Point", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Blue_Dragon_Island, "Blue Dragon Island")
        call ZoneLabels_BindMusic(gg_rct_Z_Blue_Dragon_Island, ZM_Blue_Dragon_Island_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Blue_Dragon_Island, ZD_SCARLET_ONSLAUGHT)

        // Kamuga Village
        set z = ZoneLabels_Define("Kamuga Village", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Kamuga_Village, "Kamuga Village")
        call ZoneLabels_BindMusic(gg_rct_Z_Kamuga_Village, ZM_Blue_Dragon_Island_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Kamuga_Village, ZD_SCARLET_ONSLAUGHT)

        // Tuskar Island
        set z = ZoneLabels_Define("Isle of Spears", 10)
        call ZoneLabels_AddRect(z, gg_rct_Z_Tuskar_Island, "Tuskar Island")
        call ZoneLabels_BindMusic(gg_rct_Z_Tuskar_Island, ZM_Tuskar, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Tuskar_Island, ZD_SCARLET_ONSLAUGHT)

        // Warchiefs Cove
        set z = ZoneLabels_Define("Warchiefs Cove", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Warchiefs_Cove_6, "Warchiefs Cove 6")
        call ZoneLabels_BindMusic(gg_rct_Z_Warchiefs_Cove_6, ZM_Jungle_Troll_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Warchiefs_Cove_6, ZD_VASHJIR)

        // Admirals Point
        set z = ZoneLabels_Define("Admirals Point", 20)
        call ZoneLabels_AddRect(z, gg_rct_Z_Admirals_Point_6, "Admirals Point 6")
        call ZoneLabels_BindMusic(gg_rct_Z_Admirals_Point_6, ZM_Jungle_Troll_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Admirals_Point_6, ZD_VASHJIR)

        // Dark Portal
        set z = ZoneLabels_Define("Dark Portal", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Broken_Isles_Dark_Portal, "Broken Isles Dark Portal")
        call ZoneLabels_BindMusic(gg_rct_Z_Broken_Isles_Dark_Portal, ZM_Dark_Portal_Sargeras, true)

        // Duel Island
        set z = ZoneLabels_Define("Duel Island", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Duel_Island, "Duel Island")
        call ZoneLabels_BindMusic(gg_rct_Z_Duel_Island, ZM_Duel_Island, true)

        // Kobold Cave
        // REVIEW LABEL: a connected cave with entrances at Cave_Mine_Exterior (Hillsbrad) and
        // Dwarf_Mine_Entrance (Hinterlands path). A distinct place name avoids guessing one parent
        // for the whole connected interior.
        set z = ZoneLabels_Define("Skulk Rock", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Kobold_Cave, "Kobold Cave")
        call ZoneLabels_BindMusic(gg_rct_Z_Kobold_Cave, ZM_Ogre_Konold_Sludge_Golem_Cave, true)

        // Gnomeregan
        // REVIEW LABEL: connected to both Dun Morogh (DM_Mine_W) and Loch Modan (DM_Mine_E). Uses
        // a distinct interior name for now.
        set z = ZoneLabels_Define("Gnomeregan", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dwarf_Cave_0, "Dwarf Cave 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Dwarf_Cave_0, ZM_Dwarf_Cave, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dwarf_Cave_0, ZD_DUN_MOROGH)

        // Khaz Modan Pass
        // The detached passage is connected by the KZPass and DulAlgaz waygates.
        set z = ZoneLabels_Define("Khaz Modan Pass", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dwarf_Passasge, "Dwarf Passasge")
        call ZoneLabels_BindMusic(gg_rct_Z_Dwarf_Passasge, ZM_Dwarf_Cave, true)

        set z = ZoneLabels_Define("Mountaineer's Pass", 30)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Morogh_Pass_0, "Dun Morogh Pass 0")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Morogh_Pass_0, ZM_Dun_Morogh_M, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Dun_Morogh_Pass_0, ZD_DUN_MOROGH)

        // Dun Modr
        // Dun_Modr_Thass wins its overlap with the larger Ironforge_0 rectangle.
        set z = ZoneLabels_Define("Dun Modr", 40)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_Ent, "Dun Modr Ent")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_Ent, ZM_Dun_Modr_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_West, "Dun Modr West")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_West, ZM_Dun_Modr_M, true)
        call ZoneLabels_AddRect(z, gg_rct_Z_Dun_Modr_Thass, "Dun Modr Thass")
        call ZoneLabels_BindMusic(gg_rct_Z_Dun_Modr_Thass, ZM_Dun_Modr_M, true)
    endfunction

    //=======================================================================
    // MUSIC CATALOG - KEYS AND PLAYBACK FAMILIES, NOT RECTANGLE ASSIGNMENTS
    // No parameters. Called before ConfigureLabels. ZM_* IDs are declared in globals above.
    // MusicKey preserves udg_Player_Music strings consumed by legacy quests and other systems.
    // MusicFamily selects PlayMusic's shared playback routine; equal families avoid track restarts.
    // Rectangle assignments belong beside AddRect in ConfigureLabels.
    //=======================================================================
    private function ZoneLabels_ConfigureMusic takes nothing returns nothing
        // Each policy keeps its existing compatibility key and playback family.
        // Bind rectangles in ConfigureLabels; do not add BindMusic calls here.

        set ZoneLabels_MusicKey[ZM_Undercity] = "Undercity"
        set ZoneLabels_MusicFamily[ZM_Undercity] = 1

        set ZoneLabels_MusicKey[ZM_Tirisfal_Glades] = "Tirisfal"
        set ZoneLabels_MusicFamily[ZM_Tirisfal_Glades] = 2

        set ZoneLabels_MusicKey[ZM_Deathknell] = "Deathknell"
        set ZoneLabels_MusicFamily[ZM_Deathknell] = 3

        set ZoneLabels_MusicKey[ZM_Dalaran_Enter] = "Dalaran"
        set ZoneLabels_MusicFamily[ZM_Dalaran_Enter] = 4

        set ZoneLabels_MusicKey[ZM_Lights_Hope] = "Lightshope"
        set ZoneLabels_MusicFamily[ZM_Lights_Hope] = 5

        set ZoneLabels_MusicKey[ZM_Vermillion_Redoubt] = "Vermillion Redoubt"
        set ZoneLabels_MusicFamily[ZM_Vermillion_Redoubt] = 6

        set ZoneLabels_MusicKey[ZM_ChromieInn] = "Chromie"
        set ZoneLabels_MusicFamily[ZM_ChromieInn] = 7

        set ZoneLabels_MusicKey[ZM_Hearthglen] = "Hearthglen"
        set ZoneLabels_MusicFamily[ZM_Hearthglen] = 8

        set ZoneLabels_MusicKey[ZM_Valshara] = "Valshara"
        set ZoneLabels_MusicFamily[ZM_Valshara] = 9

        set ZoneLabels_MusicKey[ZM_TarrenMill] = "TarrenMill"
        set ZoneLabels_MusicFamily[ZM_TarrenMill] = 10

        set ZoneLabels_MusicKey[ZM_SilverPine_M] = "Silverpine"
        set ZoneLabels_MusicFamily[ZM_SilverPine_M] = 11

        set ZoneLabels_MusicKey[ZM_Skittering_Dark_M] = "Skittering Dark"
        set ZoneLabels_MusicFamily[ZM_Skittering_Dark_M] = 12

        set ZoneLabels_MusicKey[ZM_Shadowfang_Keep_M] = "Shadowfang"
        set ZoneLabels_MusicFamily[ZM_Shadowfang_Keep_M] = 12

        set ZoneLabels_MusicKey[ZM_Gilneas_City_Classical] = "GilneasCityClassical"
        set ZoneLabels_MusicFamily[ZM_Gilneas_City_Classical] = 14

        set ZoneLabels_MusicKey[ZM_Gilneas_City_Battle_Music] = "GilneasCityBattle"
        set ZoneLabels_MusicFamily[ZM_Gilneas_City_Battle_Music] = 15

        set ZoneLabels_MusicKey[ZM_Pyrewood] = "Pyrewood"
        set ZoneLabels_MusicFamily[ZM_Pyrewood] = 16

        set ZoneLabels_MusicKey[ZM_Gilneas_Chapel] = "GilneasChapel"
        set ZoneLabels_MusicFamily[ZM_Gilneas_Chapel] = 17

        set ZoneLabels_MusicKey[ZM_Tempest_Reach] = "TempestReach"
        set ZoneLabels_MusicFamily[ZM_Tempest_Reach] = 17

        set ZoneLabels_MusicKey[ZM_Battle_for_Gilneas] = "GilneasGate"
        set ZoneLabels_MusicFamily[ZM_Battle_for_Gilneas] = 15

        set ZoneLabels_MusicKey[ZM_The_WitchWood] = "Witchwood"
        set ZoneLabels_MusicFamily[ZM_The_WitchWood] = 18

        set ZoneLabels_MusicKey[ZM_EmberstoneMine] = "Emberstone"
        set ZoneLabels_MusicFamily[ZM_EmberstoneMine] = 12

        set ZoneLabels_MusicKey[ZM_Scholomance_M] = "Scholomance"
        set ZoneLabels_MusicFamily[ZM_Scholomance_M] = 19

        set ZoneLabels_MusicKey[ZM_Uthers_Grave_M] = "Uthers Grave"
        set ZoneLabels_MusicFamily[ZM_Uthers_Grave_M] = 5

        set ZoneLabels_MusicKey[ZM_Naxxramas_M] = "Naxxramas"
        set ZoneLabels_MusicFamily[ZM_Naxxramas_M] = 20

        set ZoneLabels_MusicKey[ZM_Andorhal_M] = "Andorhal"
        set ZoneLabels_MusicFamily[ZM_Andorhal_M] = 21

        set ZoneLabels_MusicKey[ZM_Western_Plaguelands_M] = "WesternPlaguelands"
        set ZoneLabels_MusicFamily[ZM_Western_Plaguelands_M] = 22

        // New policy and family; existing Western Plaguelands playback is unchanged.
        set ZoneLabels_MusicKey[ZM_Chillwind_Camp] = "ChillwindCamp"
        set ZoneLabels_MusicFamily[ZM_Chillwind_Camp] = 79

        set ZoneLabels_MusicKey[ZM_Eastern_Plaguelands_M] = "Plaguelands"
        set ZoneLabels_MusicFamily[ZM_Eastern_Plaguelands_M] = 23

        set ZoneLabels_MusicKey[ZM_Stratholme_M] = "Stratholme"
        set ZoneLabels_MusicFamily[ZM_Stratholme_M] = 24

        set ZoneLabels_MusicKey[ZM_KelThuzad_M] = "KelThuzad"
        set ZoneLabels_MusicFamily[ZM_KelThuzad_M] = 25

        set ZoneLabels_MusicKey[ZM_GY_WP_M] = "GYWP"
        set ZoneLabels_MusicFamily[ZM_GY_WP_M] = 3

        set ZoneLabels_MusicKey[ZM_Venomweb_Vale_M] = "VenomwebVale"
        set ZoneLabels_MusicFamily[ZM_Venomweb_Vale_M] = 12

        set ZoneLabels_MusicKey[ZM_Hinterlands_M] = "Hinterlands"
        set ZoneLabels_MusicFamily[ZM_Hinterlands_M] = 26

        set ZoneLabels_MusicKey[ZM_TolBarad_M] = "Tolbarad"
        set ZoneLabels_MusicFamily[ZM_TolBarad_M] = 15

        set ZoneLabels_MusicKey[ZM_Hillsbrad_M] = "Hillsbrad"
        set ZoneLabels_MusicFamily[ZM_Hillsbrad_M] = 27

        set ZoneLabels_MusicKey[ZM_Arathi_M] = "Arathi"
        set ZoneLabels_MusicFamily[ZM_Arathi_M] = 28

        set ZoneLabels_MusicKey[ZM_Grizzly_Hills_M] = "Grizzly Hills"
        set ZoneLabels_MusicFamily[ZM_Grizzly_Hills_M] = 29

        set ZoneLabels_MusicKey[ZM_Utguarde_Hrydshal_M] = "Utguarde"
        set ZoneLabels_MusicFamily[ZM_Utguarde_Hrydshal_M] = 30

        set ZoneLabels_MusicKey[ZM_Lich_King_M] = "LichKing"
        set ZoneLabels_MusicFamily[ZM_Lich_King_M] = 31

        set ZoneLabels_MusicKey[ZM_Ice_Crown_M] = "Ice Crown"
        set ZoneLabels_MusicFamily[ZM_Ice_Crown_M] = 32

        set ZoneLabels_MusicKey[ZM_HowlingFjord_M] = "HowlingFjord"
        set ZoneLabels_MusicFamily[ZM_HowlingFjord_M] = 33

        set ZoneLabels_MusicKey[ZM_Blue_Dragon_Island_M] = "BDIsland"
        set ZoneLabels_MusicFamily[ZM_Blue_Dragon_Island_M] = 26

        set ZoneLabels_MusicKey[ZM_Dragonblight_M] = "Dragonblight"
        set ZoneLabels_MusicFamily[ZM_Dragonblight_M] = 34

        set ZoneLabels_MusicKey[ZM_Agmars_Hammer_M] = "Agmars Hammer"
        set ZoneLabels_MusicFamily[ZM_Agmars_Hammer_M] = 35

        set ZoneLabels_MusicKey[ZM_Zul_Drak_M] = "Zul Drak"
        set ZoneLabels_MusicFamily[ZM_Zul_Drak_M] = 36

        set ZoneLabels_MusicKey[ZM_Storm_Peaks_M] = "Storm Peaks"
        set ZoneLabels_MusicFamily[ZM_Storm_Peaks_M] = 37

        set ZoneLabels_MusicKey[ZM_Argent_Tournament_M] = "Argent Tournament"
        set ZoneLabels_MusicFamily[ZM_Argent_Tournament_M] = 38

        set ZoneLabels_MusicKey[ZM_Crystalsong_M] = "Crystalsong"
        set ZoneLabels_MusicFamily[ZM_Crystalsong_M] = 39

        set ZoneLabels_MusicKey[ZM_Azjol_Nerub_M] = "Azjol Nerub"
        set ZoneLabels_MusicFamily[ZM_Azjol_Nerub_M] = 40

        set ZoneLabels_MusicKey[ZM_Ulduar_M] = "Azjol Nerub"
        set ZoneLabels_MusicFamily[ZM_Ulduar_M] = 41

        set ZoneLabels_MusicKey[ZM_Hinterlands_Troll_M] = "HinterlandsTrolls"
        set ZoneLabels_MusicFamily[ZM_Hinterlands_Troll_M] = 42

        set ZoneLabels_MusicKey[ZM_Jungle_Troll_M] = "EversongTroll"
        set ZoneLabels_MusicFamily[ZM_Jungle_Troll_M] = 42

        set ZoneLabels_MusicKey[ZM_Zandalar_n_Zulaman_M] = "Zandalar"
        set ZoneLabels_MusicFamily[ZM_Zandalar_n_Zulaman_M] = 43

        set ZoneLabels_MusicKey[ZM_Nazmir_M] = "Nazmir"
        set ZoneLabels_MusicFamily[ZM_Nazmir_M] = 44

        set ZoneLabels_MusicKey[ZM_Silvermoon_M] = "Silvermoon"
        set ZoneLabels_MusicFamily[ZM_Silvermoon_M] = 45

        set ZoneLabels_MusicKey[ZM_Sunwell_M] = "Sunwell"
        set ZoneLabels_MusicFamily[ZM_Sunwell_M] = 46

        set ZoneLabels_MusicKey[ZM_Silvermoon_Ruins_M] = "SilvermoonRuins"
        set ZoneLabels_MusicFamily[ZM_Silvermoon_Ruins_M] = 47

        set ZoneLabels_MusicKey[ZM_Eversong_Woods_M] = "EversongWoods"
        set ZoneLabels_MusicFamily[ZM_Eversong_Woods_M] = 48

        set ZoneLabels_MusicKey[ZM_Ghostlands_M] = "Ghostlands"
        set ZoneLabels_MusicFamily[ZM_Ghostlands_M] = 49

        set ZoneLabels_MusicKey[ZM_Windrunner_Spire_M] = "Windrunner Spire"
        set ZoneLabels_MusicFamily[ZM_Windrunner_Spire_M] = 50

        set ZoneLabels_MusicKey[ZM_Alterac_M] = "Alterac"
        set ZoneLabels_MusicFamily[ZM_Alterac_M] = 51

        set ZoneLabels_MusicKey[ZM_VashJir_M] = "Vashjir"
        set ZoneLabels_MusicFamily[ZM_VashJir_M] = 52

        set ZoneLabels_MusicKey[ZM_StromGuarde_M] = "StromGuarde"
        set ZoneLabels_MusicFamily[ZM_StromGuarde_M] = 53

        set ZoneLabels_MusicKey[ZM_Grim_Batol_M] = "GrimBatol"
        set ZoneLabels_MusicFamily[ZM_Grim_Batol_M] = 54

        set ZoneLabels_MusicKey[ZM_Wetlands_M] = "Wetlands"
        set ZoneLabels_MusicFamily[ZM_Wetlands_M] = 55

        set ZoneLabels_MusicKey[ZM_Wetlands_Cave_M] = "Sludge Cave Wetlands"
        set ZoneLabels_MusicFamily[ZM_Wetlands_Cave_M] = 12

        set ZoneLabels_MusicKey[ZM_Greenwardens_Grove_M] = "Greenwardens"
        set ZoneLabels_MusicFamily[ZM_Greenwardens_Grove_M] = 56

        set ZoneLabels_MusicKey[ZM_Loch_Modan_M] = "Hillsbrad"
        set ZoneLabels_MusicFamily[ZM_Loch_Modan_M] = 27

        set ZoneLabels_MusicKey[ZM_Dun_Morogh_M] = "Dun Morogh"
        set ZoneLabels_MusicFamily[ZM_Dun_Morogh_M] = 57

        set ZoneLabels_MusicKey[ZM_Dun_Modr_M] = "Dwarf Cave"
        set ZoneLabels_MusicFamily[ZM_Dun_Modr_M] = 58

        set ZoneLabels_MusicKey[ZM_AeriePeak_M] = "AeriePeak"
        set ZoneLabels_MusicFamily[ZM_AeriePeak_M] = 54

        set ZoneLabels_MusicKey[ZM_Bastion_of_Twilight] = "Bastion of Twilight"
        set ZoneLabels_MusicFamily[ZM_Bastion_of_Twilight] = 59

        set ZoneLabels_MusicKey[ZM_Twilight_Highlands_North] = "Twilight Highlands North"
        set ZoneLabels_MusicFamily[ZM_Twilight_Highlands_North] = 60

        set ZoneLabels_MusicKey[ZM_Twilight_Highlands_South] = "TWHS"
        set ZoneLabels_MusicFamily[ZM_Twilight_Highlands_South] = 61

        set ZoneLabels_MusicKey[ZM_Goblin_Music] = "Goblin"
        set ZoneLabels_MusicFamily[ZM_Goblin_Music] = 62

        set ZoneLabels_MusicKey[ZM_Orc_Music_Dragonmaw_Port] = "Orc Music"
        set ZoneLabels_MusicFamily[ZM_Orc_Music_Dragonmaw_Port] = 63

        set ZoneLabels_MusicKey[ZM_Highbank] = "Highbank"
        set ZoneLabels_MusicFamily[ZM_Highbank] = 64

        set ZoneLabels_MusicKey[ZM_Alterac_Keep_M] = "Alterac Keep"
        set ZoneLabels_MusicFamily[ZM_Alterac_Keep_M] = 65

        set ZoneLabels_MusicKey[ZM_Dwarf_Cave] = "Dwarf Cave"
        set ZoneLabels_MusicFamily[ZM_Dwarf_Cave] = 66

        set ZoneLabels_MusicKey[ZM_Syndicate_Inn] = "SyndicateInn"
        set ZoneLabels_MusicFamily[ZM_Syndicate_Inn] = 12

        set ZoneLabels_MusicKey[ZM_Balric] = "Balric"
        set ZoneLabels_MusicFamily[ZM_Balric] = 12

        set ZoneLabels_MusicKey[ZM_Ogre_Konold_Sludge_Golem_Cave] = "Caves"
        set ZoneLabels_MusicFamily[ZM_Ogre_Konold_Sludge_Golem_Cave] = 12

        set ZoneLabels_MusicKey[ZM_Cave_of_the_Elements] = "Deepholm"
        set ZoneLabels_MusicFamily[ZM_Cave_of_the_Elements] = 67

        set ZoneLabels_MusicKey[ZM_Dalaran_Crater_M] = "DalaranCrater"
        set ZoneLabels_MusicFamily[ZM_Dalaran_Crater_M] = 68

        set ZoneLabels_MusicKey[ZM_Night_Elf_Shaladnis_M] = "Moonwell"
        set ZoneLabels_MusicFamily[ZM_Night_Elf_Shaladnis_M] = 69

        set ZoneLabels_MusicKey[ZM_Suramar_M] = "Suramar"
        set ZoneLabels_MusicFamily[ZM_Suramar_M] = 70

        set ZoneLabels_MusicKey[ZM_Dark_Portal_Sargeras] = "Sargeras"
        set ZoneLabels_MusicFamily[ZM_Dark_Portal_Sargeras] = 71

        set ZoneLabels_MusicKey[ZM_NelfarionsLair] = "Twilight"
        set ZoneLabels_MusicFamily[ZM_NelfarionsLair] = 72

        set ZoneLabels_MusicKey[ZM_Vrykul_M] = "Vrykul"
        set ZoneLabels_MusicFamily[ZM_Vrykul_M] = 73

        set ZoneLabels_MusicKey[ZM_Tuskar] = "Tuskar"
        set ZoneLabels_MusicFamily[ZM_Tuskar] = 74

        set ZoneLabels_MusicKey[ZM_High_Mountain] = "Valshara"
        set ZoneLabels_MusicFamily[ZM_High_Mountain] = 9

        set ZoneLabels_MusicKey[ZM_Stormheim] = "Stormheim"
        set ZoneLabels_MusicFamily[ZM_Stormheim] = 75

        set ZoneLabels_MusicKey[ZM_RagnarosLair] = "Ragnaros"
        set ZoneLabels_MusicFamily[ZM_RagnarosLair] = 76

        set ZoneLabels_MusicKey[ZM_Karazhan] = "Karazhan"
        set ZoneLabels_MusicFamily[ZM_Karazhan] = 77

        set ZoneLabels_MusicKey[ZM_Duel_Island] = "Duel Island"
        set ZoneLabels_MusicFamily[ZM_Duel_Island] = 78
    endfunction

    //=======================================================================
    // TRANSITION CONFIGURATION - EDIT COVERAGE, BUFFERING, AND NEIGHBORS HERE
    // No parameters. All places must already exist before adding anchors.
    // Declaration order breaks equal transition priorities; anchor order breaks distance ties.
    // Keep each transition's entire anchor list contiguous. Names/numeric suffixes do not infer policy.
    //=======================================================================
    private function ZoneLabels_ConfigureTransitions takes nothing returns nothing
        local integer t = 0

        set t = ZoneLabels_AddTransition(gg_rct_Z_WP_Transition_5, "WP Transition 5", 20, true)
        call ZoneLabels_BindDeath(gg_rct_Z_WP_Transition_5, ZD_WESTERN_PLAGUELANDS)
        // Explicit legacy death assignment preserved here; music buffering does not alter it.
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Western_Plaguelands_5)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Andorhal_5)
        call ZoneLabels_AddLatchAnchor(t, gg_rct_Z_Bulwark_12)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Arathi_Starting_Transition_100, "Arathi Starting Transition 100", 10, false)
        call ZoneLabels_BindDeath(gg_rct_Z_Arathi_Starting_Transition_100, ZD_ARATHI)
        // Explicit legacy death assignment preserved here; music buffering does not alter it.
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Starting_Zone_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Starting_Zone_S_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_North_1)

        // Tarren Mill and Dalaran Ruins latch local state but are not the distance fallback for the
        // broad band: it reaches over 1000 units from both.
        set t = ZoneLabels_AddTransition(gg_rct_Z_North_Hillsbrad_Transition_3, "North Hillsbrad Transition 3", 10, false)
        call ZoneLabels_BindDeath(gg_rct_Z_North_Hillsbrad_Transition_3, ZD_HILLSBRAD)
        // Explicit legacy death assignment preserved here; music buffering does not alter it.
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_E_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Alterac_4)
        call ZoneLabels_AddLatchAnchor(t, gg_rct_Z_Tarren_Mill_Music_3)
        call ZoneLabels_AddLatchAnchor(t, gg_rct_Z_Dalaran_Crater_3)

        // The narrowed 640x640 border now uses regular anchors on BOTH sides.
        // Walking retains the incoming side; remote arrivals choose the nearest anchor rectangle.
        // The small unpathable seams reviewed in the editor do not require extra zone coverage.
        set t = ZoneLabels_AddTransition(gg_rct_Z_Hillsbrad_to_Arathi_Transition, "Hillsbrad to Arathi Transition", 20, true)
        call ZoneLabels_BindDeath(gg_rct_Z_Hillsbrad_to_Arathi_Transition, ZD_ARATHI)
        // Explicit legacy death assignment preserved here; music buffering does not alter it.
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_E_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Hillsbrad_Foothills_Small_E_3)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Small_NW)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Arathi_Tiny_NW)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tirisfal_East_Transition_12, "Tirisfal East Transition 12", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Trisfal_Glades_0)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Crusader_Output_Zone_12)
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

        set t = ZoneLabels_AddTransition(gg_rct_Z_Tirisfal_Death_Knell_Transition, "Tirisfal Death Knell Transition", 30, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_DeathKnell_100)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Tirisfal_South_Tower_0)

        set t = ZoneLabels_AddTransition(gg_rct_Z_SecretPathCave_to_Scholomance_Transition, "SecretPathCave to Scholomance Transition", 30, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_SecretPathCave)
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

        // Gap coverage only: its music buffer is off so the named Goldenmist, Windrunner Spire and
        // Eversong rectangles inside it commit their own music instead of holding Shalandis/Eversong.
        set t = ZoneLabels_AddTransition(gg_rct_Z_Shalandris_Eversong_Ghostlands_Transition, "Shalandris Eversong Ghostlands Transition", 20, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Murlocs_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Murlocs_EW)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eversong_Woods_1)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Goldenmist_Village_North)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Goldenmist_Village_South)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Shalandis_Isle)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Windrunner_Spire)

        set t = ZoneLabels_AddTransition(gg_rct_Z_Eastern_Plaguelands_Transition, "Eastern Plaguelands Transition", 10, false)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Eastern_Plaguelands_9)
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

        set t = ZoneLabels_AddTransition(gg_rct_Z_Dun_Argol_Howling_Fjord_Transition, "Dun Argol Howling Fjord Transition", 30, true)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Grizzlemaw)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Dun_Argol)
        call ZoneLabels_AddAnchor(t, gg_rct_Z_Howling_Fjord_Forsaken)

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

    //=======================================================================
    // SHARED PLAYBACK ROUTINES - EXISTING TRACK SEQUENCES
    // Each Play_*(p) routine targets player p; policy-to-family mapping lives in ConfigureMusic.
    //=======================================================================

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

    // Shared playback: Hearthglen
    private function ZoneLabels_Play_Hearthglen takes player p returns nothing
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

    // Shared playback: Skittering_Dark_M, Shadowfang_Keep_M, EmberstoneMine, Venomweb_Vale_M, Wetlands_Cave_M, Syndicate_Inn, Balric, Ogre_Konold_Sludge_Golem_Cave
    private function ZoneLabels_Play_Skittering_Dark_M takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Lurking_Haunted_2)
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

    // Dedicated Chillwind Camp test track. Keep the Sound Editor music handle/import.
    private function ZoneLabels_Play_Chillwind_Camp takes player p returns nothing
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false)
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_MUS_WestPlagueB_GN03)
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

    //=======================================================================
    // PLAYBACK DISPATCH - KEEP TRACK SEQUENCES IN THE Play_* FUNCTIONS ABOVE
    // profile: effective ZM_* policy. p: player who should hear the audio.
    // Shared-family selection runs in sync; individual audio calls are scoped to the local player.
    //=======================================================================
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
            call ZoneLabels_Play_Hearthglen(p)
        elseif family == 9 then
            call ZoneLabels_Play_Valshara(p)
        elseif family == 10 then
            call ZoneLabels_Play_TarrenMill(p)
        elseif family == 11 then
            call ZoneLabels_Play_SilverPine_M(p)
        elseif family == 12 then
            call ZoneLabels_Play_Skittering_Dark_M(p)
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
        elseif family == 79 then
            call ZoneLabels_Play_Chillwind_Camp(p)
        endif
    endfunction

    // ApplyMusic(slot, boundary).
    // slot: tracked player index 0..7. boundary: a newly committed local music boundary.
    // Preserves external music keys while stationary and avoids restarting an unchanged family.
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

    // Sanctuary geometry is authoritative outside Duel Island. Announce only on entry/change.
    // Never touch forces or sanctuary flags while the hero OR tracked subject is on Duel Island.
    private function ZoneLabels_UpdateSanctuary takes integer slot, unit subject returns nothing
        local player p = ZoneLabels_Players[slot]
        local integer sanctuary = 0
        local boolean changed = false
        if p == null or subject == null then
            // No reliable tracked position: do not guess at force/protection changes.
            set p = null
            return
        endif
        if RectContainsUnit(gg_rct_Z_Duel_Island, subject) or (udg_Heroes[slot] != null and RectContainsUnit(gg_rct_Z_Duel_Island, udg_Heroes[slot])) then
            set ZoneLabels_SanctuarySuspended[slot] = true
            set p = null
            return
        endif
        set sanctuary = SanctuaryResolve(subject)
        set changed = sanctuary != ZoneLabels_LastSanctuary[slot] or subject != ZoneLabels_SanctuarySubject[slot] or udg_GameMode != ZoneLabels_SanctuaryMode[slot] or ZoneLabels_Relocated[slot] or ZoneLabels_SanctuarySuspended[slot]
        if changed and sanctuary != 0 then
            // Preserves the existing announcement and normal/PVP-mode entry rules.
            call PlayerEntersLocation(p, ZoneLabels_SanctuaryName[sanctuary], 2)
        endif
        if sanctuary == 0 or udg_GameMode == "PVP" then
            if changed or IsPlayerInSanctuary(p) then
                // Exit/reset is required outside sanctuary coverage, except on Duel Island above.
                call ResetEnemyForces(p)
            endif
        elseif not IsPlayerInSanctuary(p) then
            call SetPlayerInSanctuary(p, true)
        endif
        set ZoneLabels_SanctuarySuspended[slot] = false
        set ZoneLabels_LastSanctuary[slot] = sanctuary
        set ZoneLabels_SanctuarySubject[slot] = subject
        set ZoneLabels_SanctuaryMode[slot] = udg_GameMode
        set p = null
    endfunction

    // Update(): timer callback for all tracked slots, every ZoneLabels_PERIOD seconds.
    // Resolves label/music separately when position or subject changes; preserves ordinary gaps.
    // Gilneas policy changes and text-frame refresh still run while stationary.
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
            call ZoneLabels_UpdateSanctuary(slot, subject)
            call ZoneLabels_ObserveDeath(slot, subject, ZoneLabels_Relocated[slot])
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

    // Diagnose(): -zone chat handler; prints selected places, transition, reasons, and legacy music key.
    private function ZoneLabels_Diagnose takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer slot = GetPlayerHeroNumber(p)
        local unit subject = ZoneLabelsGetSubject(p)
        local integer a = 0
        local integer t = 0
        local integer profile = 0
        local integer sanctuary = ZoneLabels_LastSanctuary[slot]
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
            call ZoneLabels_DeathDescribe(p, slot)
            set text = "Sanctuary: none"
            if ZoneLabels_SanctuarySuspended[slot] then
                set text = "Sanctuary: Duel Island | controller suspended; duel triggers control forces"
            elseif sanctuary != 0 then
                set text = "Sanctuary: " + ZoneLabels_SanctuaryName[sanctuary]
            endif
            if not ZoneLabels_SanctuarySuspended[slot] then
                if IsPlayerInSanctuary(p) then
                    set text = text + " | protection ON"
                elseif udg_GameMode == "PVP" then
                    set text = text + " | protection OFF (PVP mode)"
                else
                    set text = text + " | protection OFF"
                endif
            endif
            call DisplayTimedTextToPlayer(p, 0.0, 0.0, 20.0, text)
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

    //=======================================================================
    // LEGACY GILNEAS MUSIC-STATE COMPATIBILITY
    //=======================================================================

    // Block only old audio. Retain trigger enable flags used by Gilneas mechanics.
    private function ZoneLabels_BlockAmbient takes nothing returns boolean
        return false
    endfunction







    // HookLegacyMusic(): preserve only the two live Gilneas music/quest-state handles.
    // Sanctuary GUI entry/leave triggers are retired; protection is updated by the controller.
    private function ZoneLabels_HookLegacyMusic takes nothing returns nothing
        // These two handles are live Gilneas quest state. Block only their old ambient actions.
        call TriggerAddCondition(gg_trg_Gilneas_City_Classical, Condition(function ZoneLabels_BlockAmbient))
        call TriggerAddCondition(gg_trg_Gilneas_City_Battle_Music, Condition(function ZoneLabels_BlockAmbient))
    endfunction

    // InstallDeath: comparison mode leaves old death triggers unchanged; active mode installs guards.
    // Takeover requires valid configuration and all expected legacy handles.
    private function ZoneLabels_InstallDeath takes nothing returns nothing
        local trigger observer = CreateTrigger()
        local trigger diagnostic = CreateTrigger()
        local integer slot = 0
        local boolean handlesOK = true
        loop
            exitwhen slot > 7
            if ZoneLabels_Players[slot] != null then
                call TriggerRegisterPlayerUnitEvent(observer, ZoneLabels_Players[slot], EVENT_PLAYER_UNIT_DEATH, null)
                call TriggerRegisterPlayerChatEvent(diagnostic, ZoneLabels_Players[slot], "-zd", true)
            endif
            set slot = slot + 1
        endloop
        call TriggerAddAction(observer, function ZoneLabels_DeathOnDeath)
        call TriggerAddAction(diagnostic, function ZoneLabels_DeathDiagnose)
        if ZoneLabels_DEATH_TAKEOVER then
            if gg_trg_Death_Set_Alliance == null or gg_trg_Death_Set_Horde == null then
                set handlesOK = false
            endif
            if gg_trg_Dun_Morogh_and_Loch_Modan_0 == null then
                set handlesOK = false
            endif
            if gg_trg_Tirisfal_0 == null then
                set handlesOK = false
            endif
            if gg_trg_Eversong_1 == null then
                set handlesOK = false
            endif
            if gg_trg_Arathi_1 == null then
                set handlesOK = false
            endif
            if gg_trg_Silverpine_2 == null then
                set handlesOK = false
            endif
            if gg_trg_Hinterlands_2 == null then
                set handlesOK = false
            endif
            if gg_trg_Hillsbrad_3 == null then
                set handlesOK = false
            endif
            if gg_trg_Alterac_4 == null then
                set handlesOK = false
            endif
            if gg_trg_Revantusk_8 == null then
                set handlesOK = false
            endif
            if gg_trg_WP_5 == null then
                set handlesOK = false
            endif
            if gg_trg_EP_9 == null then
                set handlesOK = false
            endif
            if gg_trg_Vashjir_6 == null then
                set handlesOK = false
            endif
            if gg_trg_Howling_Fjord_7 == null then
                set handlesOK = false
            endif
            if gg_trg_Gilneas_10 == null then
                set handlesOK = false
            endif
            if gg_trg_Valsharah_11 == null then
                set handlesOK = false
            endif
            if gg_trg_Bulwark_12 == null then
                set handlesOK = false
            endif
            if gg_trg_Wetlands_13 == null then
                set handlesOK = false
            endif
            if gg_trg_Twilight_Highlands_14_or_16 == null then
                set handlesOK = false
            endif
            if gg_trg_Ghostlands_15_Horde_and_Alliance == null then
                set handlesOK = false
            endif
            if gg_trg_TolBarad_17 == null then
                set handlesOK = false
            endif
            if gg_trg_Dalaran_20 == null then
                set handlesOK = false
            endif
            if gg_trg_Stormheim_21 == null then
                set handlesOK = false
            endif
            if gg_trg_Scarlet_Onslaught_22 == null then
                set handlesOK = false
            endif
            if gg_trg_Argent_Tournament_23 == null then
                set handlesOK = false
            endif
            if gg_trg_Dragonblight_and_Icecrown_24 == null then
                set handlesOK = false
            endif
            if ZoneLabels_DeathConfigOK and handlesOK then
                call TriggerClearActions(gg_trg_Death_Set_Alliance)
                call TriggerAddAction(gg_trg_Death_Set_Alliance, function ZoneLabels_DeathAllianceRevive)
                call TriggerClearActions(gg_trg_Death_Set_Horde)
                call TriggerAddAction(gg_trg_Death_Set_Horde, function ZoneLabels_DeathHordeRevive)
                call TriggerAddCondition(gg_trg_Dun_Morogh_and_Loch_Modan_0, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Tirisfal_0, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Eversong_1, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Arathi_1, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Silverpine_2, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Hinterlands_2, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Hillsbrad_3, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Alterac_4, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Revantusk_8, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_WP_5, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_EP_9, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Vashjir_6, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Howling_Fjord_7, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Gilneas_10, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Valsharah_11, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Bulwark_12, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Wetlands_13, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Twilight_Highlands_14_or_16, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Ghostlands_15_Horde_and_Alliance, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_TolBarad_17, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Dalaran_20, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Stormheim_21, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Scarlet_Onslaught_22, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Argent_Tournament_23, Condition(function ZoneLabels_AllowLegacyDeath))
                call TriggerAddCondition(gg_trg_Dragonblight_and_Icecrown_24, Condition(function ZoneLabels_AllowLegacyDeath))
                set ZoneLabels_DeathActive = true
            else
                set ZoneLabels_DeathConfigOK = false
            endif
        endif
        set observer = null
        set diagnostic = null
    endfunction

    // Start(): zero-delay startup callback after editor regions and GUI triggers have initialized.
    // Order: music/death catalogs -> places/bindings -> transitions -> hooks -> first update.
    private function ZoneLabels_Start takes nothing returns nothing
        local timer clock = GetExpiredTimer()
        local trigger diagnostic = CreateTrigger()
        local integer playerID = 0
        local integer slot = 0
        set ZoneLabels_Index = InitHashtable()
        call ZoneLabels_ConfigureMusic()
        call ZoneLabels_ConfigureDeath()
        call ZoneLabels_ConfigureLabels()
        call ZoneLabels_ConfigureTransitions()
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
        call ZoneLabels_InstallDeath()
        call ZoneLabels_Update()
        call TimerStart(clock, ZoneLabels_PERIOD, true, function ZoneLabels_Update)
        set diagnostic = null
        set clock = null
    endfunction

    // Init(): library initializer. Defers actual startup so all editor-generated handles exist.
    private function ZoneLabels_Init takes nothing returns nothing
        call TimerStart(CreateTimer(), 0.00, false, function ZoneLabels_Start)
    endfunction

endlibrary
