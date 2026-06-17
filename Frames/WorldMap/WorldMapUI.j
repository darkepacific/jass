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
        private constant real MAP_CLOSE_OFF_X = -0.006
        private constant real MAP_CLOSE_OFF_Y = -0.006

        // --- Hero markers (you + allies) ---
        private constant real MARKER_SIZE   = 0.018   // size of each hero icon on the map
        private constant real MARKER_UPDATE = 0.40    // reposition interval (s) while the map is open
        // Where the actual playable map sits INSIDE the image border, as fractions of MAP_SIZE
        // (0 = left/bottom edge of the frame, 1 = right/top edge). CALIBRATE these so blips line up
        // with the terrain (see the note in chat: stand at a known landmark, nudge until it matches).
        private constant real MAP_INNER_LEFT   = 0.075
        private constant real MAP_INNER_RIGHT  = 0.925
        private constant real MAP_INNER_BOTTOM = 0.075
        private constant real MAP_INNER_TOP    = 0.925
        // Pushes blips away from the map center (>1 = further out, scaled by distance from center,
        // so the effect is biggest at the edges). Fixes "icons sit too close to the center".
        private constant real MAP_SPREAD       = 1.20

        private framehandle MapPanel = null
        private framehandle MapCloseButton = null
        private trigger MapCloseTrigger = null
        private framehandle array Marker        // one per udg_Heroes[0..7]
        private framehandle TooltipPanel = null // shared hover tooltip (player name)
        private framehandle TooltipText = null
        private trigger HoverTrigger = null
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
        call MapSetVisibleLocal(GetTriggerPlayer(), false)
    endfunction

    // Hover over a hero marker -> show the owning player's name in a tooltip above it; un-hover hides
    // it. MOUSE_ENTER/LEAVE are local frame events, so this is per-client (no desync).
    private function MarkerHoverAction takes nothing returns nothing
        local framehandle f = BlzGetTriggerFrame()
        local integer i = 0
        local unit h
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
                    call BlzFrameSetText(TooltipText, GetPlayerName(GetOwningPlayer(h)))
                    call BlzFrameClearAllPoints(TooltipPanel)
                    call BlzFrameSetPoint(TooltipPanel, FRAMEPOINT_BOTTOM, Marker[i], FRAMEPOINT_TOP, 0.0, 0.004)
                    call BlzFrameSetVisible(TooltipPanel, true)
                endif
                set h = null
                set f = null
                return
            endif
            set i = i + 1
        endloop
        set f = null
    endfunction

    // Builds (or rebuilds, after a save-game load) the frames. Safe to run more than once: it just
    // reassigns the globals to the fresh frames; the close trigger is created once and reused.
    private function CreateMapUI takes nothing returns nothing
        local framehandle backdrop
        local integer i = 0
        // A BUTTON container captures mouse input so clicks on the open map don't fall through to the
        // game world behind it (ordering your hero around). The BACKDROP child draws the map image.
        set MapPanel = BlzCreateFrameByType("BUTTON", "WorldMapPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetSize(MapPanel, MAP_SIZE, MAP_SIZE)
        call BlzFrameSetAbsPoint(MapPanel, FRAMEPOINT_CENTER, MAP_CENTER_X, MAP_CENTER_Y)
        call BlzFrameSetLevel(MapPanel, MAP_FRAME_LEVEL)

        set backdrop = BlzCreateFrameByType("BACKDROP", "WorldMapBackdrop", MapPanel, "", 0)
        call BlzFrameSetAllPoints(backdrop, MapPanel)
        call BlzFrameSetTexture(backdrop, MAP_TEXTURE, 0, true)

        // Hero markers, one per udg_Heroes slot, drawn above the map image (level 2) and positioned
        // / shown each tick by UpdateMarkers. Children of MapPanel, so they hide and move with it.
        // Each registers hover events so MarkerHoverAction can show the owning player's name.
        if HoverTrigger == null then
            set HoverTrigger = CreateTrigger()
            call TriggerAddAction(HoverTrigger, function MarkerHoverAction)
        endif
        loop
            exitwhen i > 7
            set Marker[i] = BlzCreateFrameByType("BACKDROP", "WorldMapHeroMarker", MapPanel, "", i)
            call BlzFrameSetSize(Marker[i], MARKER_SIZE, MARKER_SIZE)
            call BlzFrameSetLevel(Marker[i], 2)
            call BlzFrameSetVisible(Marker[i], false)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, Marker[i], FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(HoverTrigger, Marker[i], FRAMEEVENT_MOUSE_LEAVE)
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
        call BlzFrameSetSize(TooltipPanel, 0.12, 0.022)
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

    // Repositions/shows the hero icons for the LOCAL player + allies, while the map is open.
    // GetUnitX/Y etc. are sync-safe reads; the GetLocalPlayer ally check only drives local frame
    // visibility, so there is no desync. Heroes live in udg_Heroes[0..7] (slot order, not playerId).
    private function UpdateMarkers takes nothing returns nothing
        local integer i = 0
        local unit h
        local player owner
        local real nx
        local real ny
        if MapPanel == null or not BlzFrameIsVisible(MapPanel) then
            return
        endif
        loop
            exitwhen i > 7
            set h = udg_Heroes[i]
            if h != null and GetUnitTypeId(h) != 0 and GetWidgetLife(h) > 0.405 then
                set owner = GetOwningPlayer(h)
                if owner == GetLocalPlayer() or GetPlayerAlliance(GetLocalPlayer(), owner, ALLIANCE_PASSIVE) then
                    set nx = (GetUnitX(h) - WorldMinX) / (WorldMaxX - WorldMinX)
                    set ny = (GetUnitY(h) - WorldMinY) / (WorldMaxY - WorldMinY)
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
                    call BlzFrameClearAllPoints(Marker[i])
                    call BlzFrameSetPoint(Marker[i], FRAMEPOINT_CENTER, MapPanel, FRAMEPOINT_BOTTOMLEFT, (MAP_INNER_LEFT + nx * (MAP_INNER_RIGHT - MAP_INNER_LEFT)) * MAP_SIZE, (MAP_INNER_BOTTOM + ny * (MAP_INNER_TOP - MAP_INNER_BOTTOM)) * MAP_SIZE)
                    call BlzFrameSetTexture(Marker[i], BlzGetAbilityIcon(GetUnitTypeId(h)), 0, true)
                    call BlzFrameSetVisible(Marker[i], true)
                else
                    call BlzFrameSetVisible(Marker[i], false)
                endif
            else
                call BlzFrameSetVisible(Marker[i], false)
            endif
            set i = i + 1
        endloop
        set h = null
        set owner = null
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
