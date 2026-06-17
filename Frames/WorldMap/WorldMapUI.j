library WorldMapUI initializer Init uses TasItemBag
    // Full-world map opened by the far-right "Y" side-key (and the Y key). It is a single framed
    // image - the ornate border is already baked into the .blp, so this is just: show the texture,
    // give it a standard X close button (top-right) + ESC, like the other UI frames.
    //
    // Kept in its own file on purpose so TasItemBag does not absorb another unrelated UI.
    // Wiring: TasItemBag owns the Y side-key trigger; this library only adds its toggle action to it
    // via TasItemBagRegisterSideKeyAction (the same seam DialogSystem uses for the menu button).
    globals
        private constant string  MAP_TEXTURE = "war3mapImported\\FullMap.blp"
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

        private framehandle MapPanel = null
        private framehandle MapCloseButton = null
        private trigger MapCloseTrigger = null
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

    // Builds (or rebuilds, after a save-game load) the frames. Safe to run more than once: it just
    // reassigns the globals to the fresh frames; the close trigger is created once and reused.
    private function CreateMapUI takes nothing returns nothing
        local framehandle backdrop
        // A BUTTON container captures mouse input so clicks on the open map don't fall through to the
        // game world behind it (ordering your hero around). The BACKDROP child draws the map image.
        set MapPanel = BlzCreateFrameByType("BUTTON", "WorldMapPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetSize(MapPanel, MAP_SIZE, MAP_SIZE)
        call BlzFrameSetAbsPoint(MapPanel, FRAMEPOINT_CENTER, MAP_CENTER_X, MAP_CENTER_Y)
        call BlzFrameSetLevel(MapPanel, MAP_FRAME_LEVEL)

        set backdrop = BlzCreateFrameByType("BACKDROP", "WorldMapBackdrop", MapPanel, "", 0)
        call BlzFrameSetAllPoints(backdrop, MapPanel)
        call BlzFrameSetTexture(backdrop, MAP_TEXTURE, 0, true)

        // Standard X close button in the top-right corner (mirrors the bag/talent frames).
        set MapCloseButton = BlzCreateFrameByType("GLUETEXTBUTTON", "WorldMapCloseButton", MapPanel, "ScriptDialogButton", 0)
        call BlzFrameSetSize(MapCloseButton, 0.03, 0.03)
        call BlzFrameSetText(MapCloseButton, "X")
        call BlzFrameSetPoint(MapCloseButton, FRAMEPOINT_CENTER, MapPanel, FRAMEPOINT_TOPRIGHT, MAP_CLOSE_OFF_X, MAP_CLOSE_OFF_Y)
        if MapCloseTrigger == null then
            set MapCloseTrigger = CreateTrigger()
            call TriggerAddAction(MapCloseTrigger, function MapCloseAction)
        endif
        call BlzTriggerRegisterFrameEvent(MapCloseTrigger, MapCloseButton, FRAMEEVENT_CONTROL_CLICK)

        call BlzFrameSetVisible(MapPanel, false)
        set backdrop = null
    endfunction

    // Runs once, after TasItemBag has created its side-key triggers in its 0s init (registering
    // earlier would hit a null trigger - same trap the menu/talents wiring hit).
    private function Setup takes nothing returns nothing
        call CreateMapUI()
        call TasItemBagRegisterSideKeyAction(SIDEKEY_EXTRA_INDEX, function MapToggleAction)
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
