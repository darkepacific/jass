library WorldMapUI initializer Init uses TasItemBag
    // Full-world map opened by the far-right "Y" side-key (and the Y key). It is a single framed
    // image - the ornate border is already baked into the .blp, so this is just: show the texture,
    // give it a standard X close button (top-right) + ESC, like the other UI frames.
    //
    // Kept in its own file on purpose so TasItemBag does not absorb another unrelated UI.
    // Wiring: TasItemBag owns the Y side-key trigger; this library only adds its toggle action to it
    // via TasItemBagRegisterSideKeyAction (the same seam DialogSystem uses for the menu button).
    globals
        private constant string  MAP_TEXTURE = "war3mapImported\\FullMap_v4.blp"
        // The Y side-key is TasItemBag's SIDEKEY_EXTRA (index 3). Literal here, like the talents wiring.
        private constant integer SIDEKEY_EXTRA_INDEX = 3
        // Image is 1:1 (1024x1024), so the frame is square. Nudge these to taste.
        private constant real MAP_SIZE     = 0.42
        private constant real MAP_CENTER_X = 0.40
        private constant real MAP_CENTER_Y = 0.34
        private constant integer MAP_FRAME_LEVEL = 50   // above the hotbar / inventory
        // X close button offset from the panel's top-right corner (CENTER anchor). Less-negative =
        // up + right, toward/outside the corner. Will likely want a final tweak after the image regen.
        private constant real MAP_CLOSE_OFF_X = -0.012
        private constant real MAP_CLOSE_OFF_Y = -0.012

        // --- Hero markers (you + allies) ---
        private constant real MARKER_SIZE   = 0.018   // size of each hero icon on the map
        private constant real MARKER_UPDATE = 0.25    // reposition interval (s) while the map is open
        private constant integer BOSS_MARKER_MAX = 16 // simultaneous quest/boss icons (WorldMapAddUnit)
        private constant integer STATIC_MARKER_MAX = 16 // simultaneous fixed icons (WorldMapAddStatic)
        private constant real TOOLTIP_W = 0.10    // hover tooltip width (smaller = tighter)
        private constant real TOOLTIP_H = 0.032   // hover tooltip height (fits the 2-line hero label)
        // Where the actual playable map sits INSIDE the image border, as fractions of MAP_SIZE
        // (0 = left/bottom edge of the frame, 1 = right/top edge). CALIBRATE these so blips line up
        // with the terrain (see the note in chat: stand at a known landmark, nudge until it matches).
        private constant real MAP_INNER_LEFT   = 0.075
        private constant real MAP_INNER_RIGHT  = 0.925
        private constant real MAP_INNER_BOTTOM = 0.075
        private constant real MAP_INNER_TOP    = 0.925
        // Pushes blips away from the map center (>1 = further out, scaled by distance from center,
        // so the effect is biggest at the edges). Fixes "icons sit too close to the center".
        private constant real MAP_SPREAD       = 1.23
        // Click-to-pan grid: an N x N lattice of invisible click cells over the playable area. WC3
        // gives no cursor position on a custom frame click - only WHICH frame fired - so each cell is
        // itself a known map point, and clicking it pans there. Higher N = finer panning + more frames
        // (static/invisible: no in-game perf cost, only a touch of load time + frame budget).
        private constant integer MAP_GRID_N    = 30

        private framehandle MapPanel = null
        private framehandle MapCloseButton = null
        private trigger MapCloseTrigger = null
        private framehandle array Marker        // one per udg_Heroes[0..7] (BUTTON: hover + click)
        private framehandle array MarkerIcon    // hero-icon BACKDROP child of each Marker
        private unit array BossUnit             // quest/boss units added via WorldMapAddUnit
        private framehandle array BossMarker     // BOSS_MARKER_MAX-frame pool (BUTTON: hover + click)
        private framehandle array BossMarkerIcon // unit-icon BACKDROP child of each BossMarker
        private string array StaticName          // fixed markers (WorldMapAddStatic); name is the key + tooltip
        private real array StaticX
        private real array StaticY
        private string array StaticIcon          // icon path (BlzGetAbilityIcon of the passed unit type)
        private framehandle array StaticMarker   // STATIC_MARKER_MAX-frame pool (BUTTON: hover + click)
        private framehandle array StaticMarkerIcon
        private framehandle TooltipPanel = null // shared hover tooltip (player name)
        private framehandle TooltipText = null
        private framehandle array GridCell       // MAP_GRID_N^2 invisible click cells (click-to-pan)
        private trigger HoverTrigger = null
        private trigger ClickTrigger = null      // frame CONTROL_CLICK -> defocus + pan
        private timer MarkerTimer = null
        private real WorldMinX
        private real WorldMaxX
        private real WorldMinY
        private real WorldMaxY
    endglobals

    private function MapSetVisibleLocal takes player p, boolean show returns nothing
        if GetLocalPlayer() == p and MapPanel != null then
            call BlzFrameSetVisible(MapPanel, show)
        endif
    endfunction

    // Fired by the Y side-key (click or Y key) through TasItemBag's registration seam.
    private function MapToggleAction takes nothing returns nothing
        if MapPanel != null and GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(MapPanel, not BlzFrameIsVisible(MapPanel))
        endif
    endfunction

    // X button click and ESC both just hide it (local-guarded -> no desync).
    private function MapCloseAction takes nothing returns nothing
        // A frame click grabs keyboard focus and swallows later key input; release it. ESC has no
        // trigger frame, so guard on that.
        if GetLocalPlayer() == GetTriggerPlayer() and BlzGetTriggerFrame() != null then
            call BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            call BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        endif
        call MapSetVisibleLocal(GetTriggerPlayer(), false)
    endfunction

    // Sets the shared tooltip's text and anchors it just above the given marker, then shows it.
    private function ShowMarkerTooltip takes framehandle mk, string txt returns nothing
        call BlzFrameSetText(TooltipText, txt)
        call BlzFrameClearAllPoints(TooltipPanel)
        call BlzFrameSetPoint(TooltipPanel, FRAMEPOINT_BOTTOM, mk, FRAMEPOINT_TOP, 0.0, 0.004)
        call BlzFrameSetVisible(TooltipPanel, true)
    endfunction

    // Hover over a marker -> tooltip above it; un-hover hides it. Hero markers show the player name +
    // unit/class name (two lines); boss markers show the unit's proper name (class name if it has none).
    // MOUSE_ENTER/LEAVE are local frame events, so this is per-client (no desync).
    private function MarkerHoverAction takes nothing returns nothing
        local framehandle f = BlzGetTriggerFrame()
        local integer i = 0
        local unit h
        local string s
        if TooltipPanel == null then
            return
        endif
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_LEAVE then
            call BlzFrameSetVisible(TooltipPanel, false)
            set f = null
            return
        endif
        loop
            exitwhen i > 7
            if f == Marker[i] then
                set h = udg_Heroes[i]
                if h != null and GetUnitTypeId(h) != 0 then
                    call ShowMarkerTooltip(Marker[i], GetPlayerName(GetOwningPlayer(h)) + "|n" + GetUnitName(h))
                endif
                set h = null
                set f = null
                return
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= BOSS_MARKER_MAX
            if f == BossMarker[i] then
                set h = BossUnit[i]
                if h != null and GetUnitTypeId(h) != 0 then
                    set s = GetHeroProperName(h)
                    if s == null then
                        set s = GetUnitName(h)
                    endif
                    call ShowMarkerTooltip(BossMarker[i], s)
                endif
                set h = null
                set f = null
                return
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= STATIC_MARKER_MAX
            if f == StaticMarker[i] then
                if StaticName[i] != null then
                    call ShowMarkerTooltip(StaticMarker[i], StaticName[i])
                endif
                set f = null
                return
            endif
            set i = i + 1
        endloop
        set f = null
    endfunction

    // Every click on the map comes through here (panel border, a hero marker, or a grid cell - all on
    // ClickTrigger). We can't read the cursor's position on a custom frame, but we DO know which frame
    // fired, so we resolve the pan target by identity:
    //   - a hero marker  -> pan straight to that hero (exact)
    //   - a grid cell     -> pan to that cell's mapped world point (inverse of the marker map)
    //   - the bare panel  -> nothing but the focus release (border clicks)
    // Always release keyboard focus first (a frame click grabs it, swallowing later key input). Frame
    // event is local-only and the camera is local state -> no desync.
    private function MapClickAction takes nothing returns nothing
        local framehandle f = BlzGetTriggerFrame()
        local integer k = 0
        local integer col
        local integer row
        local real nx
        local real ny
        local unit h
        if MapPanel == null or GetLocalPlayer() != GetTriggerPlayer() then
            set f = null
            return
        endif
        // Release keyboard focus. A click on a child cell leaves focus on the PANEL container (not the
        // cell), so defocusing only the clicked frame isn't enough - drop the panel's focus too.
        call BlzFrameSetEnable(MapPanel, false)
        call BlzFrameSetEnable(MapPanel, true)
        if f != MapPanel then
            call BlzFrameSetEnable(f, false)
            call BlzFrameSetEnable(f, true)
        endif
        if not BlzFrameIsVisible(MapPanel) then
            set f = null
            return
        endif
        loop
            exitwhen k > 7
            if f == Marker[k] then
                set h = udg_Heroes[k]
                if h != null and GetUnitTypeId(h) != 0 then
                    call PanCameraToTimed(GetUnitX(h), GetUnitY(h), 0.0)
                endif
                set h = null
                set f = null
                return
            endif
            set k = k + 1
        endloop
        set k = 0
        loop
            exitwhen k >= BOSS_MARKER_MAX
            if f == BossMarker[k] then
                set h = BossUnit[k]
                if h != null and GetUnitTypeId(h) != 0 then
                    call PanCameraToTimed(GetUnitX(h), GetUnitY(h), 0.0)
                endif
                set h = null
                set f = null
                return
            endif
            set k = k + 1
        endloop
        set k = 0
        loop
            exitwhen k >= STATIC_MARKER_MAX
            if f == StaticMarker[k] then
                if StaticName[k] != null then
                    call PanCameraToTimed(StaticX[k], StaticY[k], 0.0)
                endif
                set f = null
                return
            endif
            set k = k + 1
        endloop
        set k = 0
        loop
            exitwhen k >= MAP_GRID_N * MAP_GRID_N
            if f == GridCell[k] then
                set col = k - (k / MAP_GRID_N) * MAP_GRID_N
                set row = k / MAP_GRID_N
                set nx = 0.5 + (((I2R(col) + 0.5) / I2R(MAP_GRID_N)) - 0.5) / MAP_SPREAD
                set ny = 0.5 + (((I2R(row) + 0.5) / I2R(MAP_GRID_N)) - 0.5) / MAP_SPREAD
                call PanCameraToTimed(WorldMinX + nx * (WorldMaxX - WorldMinX), WorldMinY + ny * (WorldMaxY - WorldMinY), 0.0)
                set f = null
                return
            endif
            set k = k + 1
        endloop
        set f = null
    endfunction

    // Builds (or rebuilds, after a save-game load) the frames. Safe to run more than once: it just
    // reassigns the globals to the fresh frames; the close trigger is created once and reused.
    private function CreateMapUI takes nothing returns nothing
        local framehandle backdrop
        local integer i = 0
        local integer col
        local integer row
        local real cellFracX = (MAP_INNER_RIGHT - MAP_INNER_LEFT) / I2R(MAP_GRID_N)
        local real cellFracY = (MAP_INNER_TOP - MAP_INNER_BOTTOM) / I2R(MAP_GRID_N)
        // A BUTTON container captures mouse input so clicks on the open map don't fall through to the
        // game world behind it (ordering your hero around). The BACKDROP child draws the map image.
        set MapPanel = BlzCreateFrameByType("BUTTON", "WorldMapPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetSize(MapPanel, MAP_SIZE, MAP_SIZE)
        call BlzFrameSetAbsPoint(MapPanel, FRAMEPOINT_CENTER, MAP_CENTER_X, MAP_CENTER_Y)
        call BlzFrameSetLevel(MapPanel, MAP_FRAME_LEVEL)
        if ClickTrigger == null then
            set ClickTrigger = CreateTrigger()
            call TriggerAddAction(ClickTrigger, function MapClickAction)
        endif
        // The panel only catches border clicks (just defocus); the grid cells + markers do the panning.
        call BlzTriggerRegisterFrameEvent(ClickTrigger, MapPanel, FRAMEEVENT_CONTROL_CLICK)

        set backdrop = BlzCreateFrameByType("BACKDROP", "WorldMapBackdrop", MapPanel, "", 0)
        call BlzFrameSetAllPoints(backdrop, MapPanel)
        call BlzFrameSetTexture(backdrop, MAP_TEXTURE, 0, true)

        // Invisible click-grid over the playable area (level 1: above the image, below the markers at
        // level 2 so marker hover/clicks still win). Each cell is a BUTTON whose CONTROL_CLICK lands in
        // MapClickAction, which pans to the cell's known map point. This is how we get a position out of
        // a click when WC3 won't give us cursor coords on a custom frame.
        loop
            exitwhen i >= MAP_GRID_N * MAP_GRID_N
            set col = i - (i / MAP_GRID_N) * MAP_GRID_N
            set row = i / MAP_GRID_N
            set GridCell[i] = BlzCreateFrameByType("BUTTON", "WorldMapGridCell", MapPanel, "", i)
            call BlzFrameSetSize(GridCell[i], cellFracX * MAP_SIZE, cellFracY * MAP_SIZE)
            call BlzFrameClearAllPoints(GridCell[i])
            call BlzFrameSetPoint(GridCell[i], FRAMEPOINT_BOTTOMLEFT, MapPanel, FRAMEPOINT_BOTTOMLEFT, (MAP_INNER_LEFT + I2R(col) * cellFracX) * MAP_SIZE, (MAP_INNER_BOTTOM + I2R(row) * cellFracY) * MAP_SIZE)
            call BlzFrameSetAlpha(GridCell[i], 0)
            call BlzFrameSetLevel(GridCell[i], 1)
            call BlzTriggerRegisterFrameEvent(ClickTrigger, GridCell[i], FRAMEEVENT_CONTROL_CLICK)
            set i = i + 1
        endloop
        set i = 0

        // Hero markers, one per udg_Heroes slot, drawn above the map image (level 2) and positioned
        // / shown each tick by UpdateMarkers. Children of MapPanel, so they hide and move with it.
        // Each registers hover events so MarkerHoverAction can show the owning player's name.
        if HoverTrigger == null then
            set HoverTrigger = CreateTrigger()
            call TriggerAddAction(HoverTrigger, function MarkerHoverAction)
        endif
        loop
            exitwhen i > 7
            // BUTTON (so it reliably fires hover + click on top of the panel); the hero icon is a
            // BACKDROP child filling it (a bare BUTTON can't show a texture itself).
            set Marker[i] = BlzCreateFrameByType("BUTTON", "WorldMapHeroMarker", MapPanel, "", i)
            call BlzFrameSetSize(Marker[i], MARKER_SIZE, MARKER_SIZE)
            call BlzFrameSetLevel(Marker[i], 2)
            set MarkerIcon[i] = BlzCreateFrameByType("BACKDROP", "WorldMapHeroMarkerIcon", Marker[i], "", i)
            call BlzFrameSetAllPoints(MarkerIcon[i], Marker[i])
            call BlzFrameSetEnable(MarkerIcon[i], false)
            call BlzFrameSetVisible(Marker[i], false)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, Marker[i], FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, Marker[i], FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(ClickTrigger, Marker[i], FRAMEEVENT_CONTROL_CLICK)
            set i = i + 1
        endloop

        // Quest/boss marker pool (assigned on demand by WorldMapAddUnit). Same construction as the hero
        // markers; hover shows the proper name, click pans to the unit. Hidden until a unit is assigned.
        set i = 0
        loop
            exitwhen i >= BOSS_MARKER_MAX
            set BossMarker[i] = BlzCreateFrameByType("BUTTON", "WorldMapBossMarker", MapPanel, "", i)
            call BlzFrameSetSize(BossMarker[i], MARKER_SIZE, MARKER_SIZE)
            call BlzFrameSetLevel(BossMarker[i], 2)
            set BossMarkerIcon[i] = BlzCreateFrameByType("BACKDROP", "WorldMapBossMarkerIcon", BossMarker[i], "", i)
            call BlzFrameSetAllPoints(BossMarkerIcon[i], BossMarker[i])
            call BlzFrameSetEnable(BossMarkerIcon[i], false)
            call BlzFrameSetVisible(BossMarker[i], false)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, BossMarker[i], FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, BossMarker[i], FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(ClickTrigger, BossMarker[i], FRAMEEVENT_CONTROL_CLICK)
            set i = i + 1
        endloop

        // Fixed/static marker pool (WorldMapAddStatic) - same construction, positioned from stored x/y.
        set i = 0
        loop
            exitwhen i >= STATIC_MARKER_MAX
            set StaticMarker[i] = BlzCreateFrameByType("BUTTON", "WorldMapStaticMarker", MapPanel, "", i)
            call BlzFrameSetSize(StaticMarker[i], MARKER_SIZE, MARKER_SIZE)
            call BlzFrameSetLevel(StaticMarker[i], 2)
            set StaticMarkerIcon[i] = BlzCreateFrameByType("BACKDROP", "WorldMapStaticMarkerIcon", StaticMarker[i], "", i)
            call BlzFrameSetAllPoints(StaticMarkerIcon[i], StaticMarker[i])
            call BlzFrameSetEnable(StaticMarkerIcon[i], false)
            call BlzFrameSetVisible(StaticMarker[i], false)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, StaticMarker[i], FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, StaticMarker[i], FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(ClickTrigger, StaticMarker[i], FRAMEEVENT_CONTROL_CLICK)
            set i = i + 1
        endloop

        // Standard X close button in the top-right corner (mirrors the bag/talent frames). Level 5
        // keeps it above the markers so it stays clickable even if a blip lands in the corner.
        set MapCloseButton = BlzCreateFrameByType("GLUETEXTBUTTON", "WorldMapCloseButton", MapPanel, "ScriptDialogButton", 0)
        call BlzFrameSetSize(MapCloseButton, 0.03, 0.03)
        call BlzFrameSetText(MapCloseButton, "X")
        call BlzFrameSetLevel(MapCloseButton, 5)
        call BlzFrameSetPoint(MapCloseButton, FRAMEPOINT_CENTER, MapPanel, FRAMEPOINT_TOPRIGHT, MAP_CLOSE_OFF_X, MAP_CLOSE_OFF_Y)
        if MapCloseTrigger == null then
            set MapCloseTrigger = CreateTrigger()
            call TriggerAddAction(MapCloseTrigger, function MapCloseAction)
        endif
        call BlzTriggerRegisterFrameEvent(MapCloseTrigger, MapCloseButton, FRAMEEVENT_CONTROL_CLICK)

        // Shared hover tooltip (player name), drawn above everything (level 6). Non-interactive so it
        // never intercepts the hover; MarkerHoverAction positions it above the hovered marker.
        set TooltipPanel = BlzCreateFrameByType("BACKDROP", "WorldMapTooltip", MapPanel, "", 0)
        call BlzFrameSetSize(TooltipPanel, TOOLTIP_W, TOOLTIP_H)
        call BlzFrameSetTexture(TooltipPanel, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background.blp", 0, true)
        call BlzFrameSetLevel(TooltipPanel, 6)
        call BlzFrameSetEnable(TooltipPanel, false)
        set TooltipText = BlzCreateFrameByType("TEXT", "WorldMapTooltipText", TooltipPanel, "", 0)
        call BlzFrameSetAllPoints(TooltipText, TooltipPanel)
        call BlzFrameSetTextAlignment(TooltipText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        call BlzFrameSetEnable(TooltipText, false)
        call BlzFrameSetVisible(TooltipPanel, false)

        call BlzFrameSetVisible(MapPanel, false)
        set backdrop = null
    endfunction

    // Maps a world point into the map frame (normalize -> spread -> clamp), sets the icon, shows it.
    private function PlaceMarkerXY takes framehandle mk, framehandle icon, real wx, real wy, string iconPath returns nothing
        local real nx = (wx - WorldMinX) / (WorldMaxX - WorldMinX)
        local real ny = (wy - WorldMinY) / (WorldMaxY - WorldMinY)
        set nx = 0.5 + (nx - 0.5) * MAP_SPREAD
        set ny = 0.5 + (ny - 0.5) * MAP_SPREAD
        if nx < 0.0 then
            set nx = 0.0
        elseif nx > 1.0 then
            set nx = 1.0
        endif
        if ny < 0.0 then
            set ny = 0.0
        elseif ny > 1.0 then
            set ny = 1.0
        endif
        call BlzFrameClearAllPoints(mk)
        call BlzFrameSetPoint(mk, FRAMEPOINT_CENTER, MapPanel, FRAMEPOINT_BOTTOMLEFT, (MAP_INNER_LEFT + nx * (MAP_INNER_RIGHT - MAP_INNER_LEFT)) * MAP_SIZE, (MAP_INNER_BOTTOM + ny * (MAP_INNER_TOP - MAP_INNER_BOTTOM)) * MAP_SIZE)
        call BlzFrameSetTexture(icon, iconPath, 0, true)
        call BlzFrameSetVisible(mk, true)
    endfunction

    // Convenience wrapper for a live unit: pulls its current position + icon.
    private function PlaceMarker takes framehandle mk, framehandle icon, unit h returns nothing
        call PlaceMarkerXY(mk, icon, GetUnitX(h), GetUnitY(h), BlzGetAbilityIcon(GetUnitTypeId(h)))
    endfunction

    // Repositions/shows the icons while the map is open. Heroes: the LOCAL player + allies always, plus
    // any ENEMY hero the local player currently sees (IsUnitVisible -> hides again in fog). Boss/quest
    // units (WorldMapAddUnit): always shown while alive. GetUnitX/Y are sync-safe reads; the GetLocalPlayer
    // vision/ally checks only drive local frame visibility, so there is no desync.
    private function UpdateMarkers takes nothing returns nothing
        local integer i = 0
        local unit h
        local player owner
        if MapPanel == null or not BlzFrameIsVisible(MapPanel) then
            return
        endif
        loop
            exitwhen i > 7
            set h = udg_Heroes[i]
            if h != null and GetUnitTypeId(h) != 0 and GetWidgetLife(h) > 0.405 then
                set owner = GetOwningPlayer(h)
                if owner == GetLocalPlayer() or GetPlayerAlliance(GetLocalPlayer(), owner, ALLIANCE_PASSIVE) or IsUnitVisible(h, GetLocalPlayer()) then
                    call PlaceMarker(Marker[i], MarkerIcon[i], h)
                else
                    call BlzFrameSetVisible(Marker[i], false)
                endif
            else
                call BlzFrameSetVisible(Marker[i], false)
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= BOSS_MARKER_MAX
            set h = BossUnit[i]
            if h != null and GetUnitTypeId(h) != 0 and GetWidgetLife(h) > 0.405 then
                call PlaceMarker(BossMarker[i], BossMarkerIcon[i], h)
            else
                call BlzFrameSetVisible(BossMarker[i], false)
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= STATIC_MARKER_MAX
            if StaticName[i] != null then
                call PlaceMarkerXY(StaticMarker[i], StaticMarkerIcon[i], StaticX[i], StaticY[i], StaticIcon[i])
            else
                call BlzFrameSetVisible(StaticMarker[i], false)
            endif
            set i = i + 1
        endloop
        set h = null
        set owner = null
    endfunction

    // PUBLIC: add a unit's icon to the world map (e.g. a quest boss). Hover shows its proper name (or
    // class name if it has none); click pans to it. Idempotent - a unit already shown is ignored, and
    // it silently no-ops if the pool (BOSS_MARKER_MAX) is full. Call WorldMapRemoveUnit to take it off.
    function WorldMapAddUnit takes unit u returns nothing
        local integer i = 0
        if u == null then
            return
        endif
        loop
            exitwhen i >= BOSS_MARKER_MAX
            if BossUnit[i] == u then
                return
            endif
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= BOSS_MARKER_MAX
            if BossUnit[i] == null then
                set BossUnit[i] = u
                return
            endif
            set i = i + 1
        endloop
    endfunction

    // PUBLIC: remove a unit previously added via WorldMapAddUnit and hide its icon.
    function WorldMapRemoveUnit takes unit u returns nothing
        local integer i = 0
        loop
            exitwhen i >= BOSS_MARKER_MAX
            if BossUnit[i] == u then
                set BossUnit[i] = null
                if BossMarker[i] != null then
                    call BlzFrameSetVisible(BossMarker[i], false)
                endif
                return
            endif
            set i = i + 1
        endloop
    endfunction

    // PUBLIC: add a FIXED icon at a world point (x,y) with a display name, its image pulled from the
    // given unit type's icon - for bosses that have not spawned yet (no live unit needed). It never
    // moves. Calling again with the same name updates the existing marker's spot/icon (safe to refresh).
    // Hover shows the name; click pans to it. No-ops if the pool (STATIC_MARKER_MAX) is full.
    function WorldMapAddStatic takes string name, real x, real y, integer unitType returns nothing
        local integer i = 0
        local integer free = -1
        if name == null then
            return
        endif
        loop
            exitwhen i >= STATIC_MARKER_MAX
            if StaticName[i] == name then
                set StaticX[i] = x
                set StaticY[i] = y
                set StaticIcon[i] = BlzGetAbilityIcon(unitType)
                return
            endif
            if free < 0 and StaticName[i] == null then
                set free = i
            endif
            set i = i + 1
        endloop
        if free >= 0 then
            set StaticName[free] = name
            set StaticX[free] = x
            set StaticY[free] = y
            set StaticIcon[free] = BlzGetAbilityIcon(unitType)
        endif
    endfunction

    // PUBLIC: remove a fixed marker previously added via WorldMapAddStatic (matched by name).
    function WorldMapRemoveStatic takes string name returns nothing
        local integer i = 0
        loop
            exitwhen i >= STATIC_MARKER_MAX
            if StaticName[i] == name then
                set StaticName[i] = null
                if StaticMarker[i] != null then
                    call BlzFrameSetVisible(StaticMarker[i], false)
                endif
                return
            endif
            set i = i + 1
        endloop
    endfunction

    // Runs once, after TasItemBag has created its side-key triggers in its 0s init (registering
    // earlier would hit a null trigger - same trap the menu/talents wiring hit).
    private function Setup takes nothing returns nothing
        local rect r = GetWorldBounds()
        set WorldMinX = GetRectMinX(r)
        set WorldMaxX = GetRectMaxX(r)
        set WorldMinY = GetRectMinY(r)
        set WorldMaxY = GetRectMaxY(r)
        call RemoveRect(r)
        set r = null
        call CreateMapUI()
        call TasItemBagRegisterSideKeyAction(SIDEKEY_EXTRA_INDEX, function MapToggleAction)
        set MarkerTimer = CreateTimer()
        call TimerStart(MarkerTimer, MARKER_UPDATE, true, function UpdateMarkers)
    endfunction

    private function Init takes nothing returns nothing
        local trigger esc = CreateTrigger()
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call BlzTriggerRegisterPlayerKeyEvent(esc, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
        endloop
        call TriggerAddAction(esc, function MapCloseAction)
        set esc = null

        call TimerStart(CreateTimer(), 0.10, false, function Setup)
        // Recreate frames after a saved game loads (frames don't survive load in this engine).
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function CreateMapUI)
        endif
    endfunction
endlibrary
