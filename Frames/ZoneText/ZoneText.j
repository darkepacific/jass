library ZoneText initializer Init requires optional FrameLoader
    // Top-right ZONE-NAME banner (e.g. "Tirisfal Glades"). It is one opaque box,
    // sized big enough to fit a zone name, drawn OVER the default food + upkeep
    // displays (which are useless on this map - we just cover them, we don't hide
    // them). One line of centred text, per-player (local) so each player sees the
    // zone THEIR OWN hero is standing in.
    //
    // Drive it from your own region-enter triggers / cinematics:
    //   call ZoneTextSetForPlayer(p, "Tirisfal Glades")            // one player, default gold
    //   call ZoneTextSetForAll("The Undercity")                    // everyone, default gold
    //   call ZoneTextSetColoredForAll("Stranglethorn", Colors.RED) // everyone, chosen colour (palette in GenericFunctions)
    //
    // Conventions followed here (learned the hard way on the other frame libs):
    //   * Frames are built on a 0s timer (they need the game UI to exist) and are
    //     rebuilt after a save-load via FrameLoader.
    //   * No trigger is created mid-frame-build (that silently kills the init thread);
    //     the only timer used at runtime is created up-front in Init.
    //   * Frames are non-interactive (BlzFrameSetEnable false) so they neither grab
    //     keyboard focus nor swallow clicks meant for the resource bar behind them.
    //   * Every text write is local-only (BlzFrameSetText) -> no desync.

    globals
        // ---- Black cover box ----
        // The camera-fade "Black_mask" texture: a full, solid, opaque BLACK rectangle that
        // ships with WC3. Used directly (no tint) -> a clean black box, no ornate border.
        // (BlzFrameSetVertexColor does NOT tint a BACKDROP, which is why a tinted Teamcolor
        // texture showed up red - so we just use an already-black texture instead.)
        private constant string  COVER_TEXTURE = "ReplaceableTextures\\CameraMasks\\Black_mask.blp"
        private constant integer PANEL_LEVEL   = 6       // draw above the default resource bar

        // The box stretches to cover from the FOOD display's top-left to the UPKEEP
        // display's bottom-right; these pads (frame units) grow it outward so it fully
        // swallows both boxes, including the food icon. Tune in-game:
        private constant real    PAD_LEFT      = -0.016  // extend left over the food icon (more negative = further left)
        private constant real    PAD_TOP       =  0.0012  // extend up
        private constant real    PAD_RIGHT     =  0.002  // extend right past the upkeep box
        private constant real    PAD_BOTTOM    = -0.000  // extend down

        // Fallback box, ONLY used if the resource-bar frames can't be found by name.
        private constant real    FALLBACK_X    =  0.620
        private constant real    FALLBACK_Y    =  0.600
        private constant real    FALLBACK_W    =  0.170
        private constant real    FALLBACK_H    =  0.028

        // ---- Text ----
        private constant real    TEXT_SCALE    = 1.10   // zone-name font size
        private constant string  TEXT_COLOR    = "|cffffd9a0" // warm gold; set "" for plain white

        private framehandle Panel = null
        private framehandle Label = null
    endglobals

    // ---- Display primitives (local-only) -------------------------------------

    private function ApplyText takes string color, string name returns nothing
        if Label == null then
            return
        endif
        if name == null then
            set name = ""
        endif
        call BlzFrameSetText(Label, color + name + "|r")
    endfunction

    // PUBLIC: set the banner for one player in the DEFAULT colour. Local-guarded, so it
    // is safe to call from ordinary synchronous code - only that player's UI changes.
    function ZoneTextSetForPlayer takes player p, string name returns nothing
        if GetLocalPlayer() == p then
            call ApplyText(TEXT_COLOR, name)
        endif
    endfunction

    // PUBLIC: set the banner for everyone in the DEFAULT colour.
    function ZoneTextSetForAll takes string name returns nothing
        call ApplyText(TEXT_COLOR, name)
    endfunction

    // PUBLIC: as above but in a chosen colour - pass a |c..-code (e.g. Colors.RED).
    function ZoneTextSetColoredForPlayer takes player p, string name, string color returns nothing
        if GetLocalPlayer() == p then
            call ApplyText(color, name)
        endif
    endfunction

    // PUBLIC: set the banner for everyone in a chosen colour (e.g. Colors.RED).
    function ZoneTextSetColoredForAll takes string name, string color returns nothing
        call ApplyText(color, name)
    endfunction

    // PUBLIC: show/hide the whole banner for one player.
    function ZoneTextShowForPlayer takes player p, boolean show returns nothing
        if Panel != null and GetLocalPlayer() == p then
            call BlzFrameSetVisible(Panel, show)
        endif
    endfunction

    // ---- Frame construction --------------------------------------------------

    // Stretches the black box to span both resource frames. Anchored to the engine
    // food + upkeep frames by name so it tracks them at any resolution; the GAME UI
    // corner is NOT used because on widescreen it sits well right of the bar.
    private function AnchorPanel takes nothing returns nothing
        local framehandle foodF   = BlzGetFrameByName("ResourceBarSupplyText", 0)
        local framehandle upkeepF = BlzGetFrameByName("ResourceBarUpkeepText", 0)
        call BlzFrameClearAllPoints(Panel)
        if foodF != null and upkeepF != null then
            // Two points -> the panel stretches to fill from food (top-left) to upkeep (bottom-right).
            call BlzFrameSetPoint(Panel, FRAMEPOINT_TOPLEFT,     foodF,   FRAMEPOINT_TOPLEFT,     PAD_LEFT,  PAD_TOP)
            call BlzFrameSetPoint(Panel, FRAMEPOINT_BOTTOMRIGHT, upkeepF, FRAMEPOINT_BOTTOMRIGHT, PAD_RIGHT, PAD_BOTTOM)
        else
            // Names didn't resolve in this version: fall back to a fixed box (calibrate FALLBACK_*).
            call BlzFrameSetSize(Panel, FALLBACK_W, FALLBACK_H)
            call BlzFrameSetAbsPoint(Panel, FRAMEPOINT_TOP, FALLBACK_X, FALLBACK_Y)
        endif
        set foodF = null
        set upkeepF = null
    endfunction

    private function CreateUI takes nothing returns nothing
        local framehandle gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

        set Panel = BlzCreateFrameByType("BACKDROP", "ZoneTextPanel", gameUI, "", 0)
        call BlzFrameSetTexture(Panel, COVER_TEXTURE, 0, true) // already solid black, no tint needed
        call BlzFrameSetLevel(Panel, PANEL_LEVEL)
        call BlzFrameSetEnable(Panel, false)   // non-interactive: no focus grab, no click-eating
        call AnchorPanel()

        set Label = BlzCreateFrameByType("TEXT", "ZoneTextLabel", Panel, "", 0)
        call BlzFrameSetAllPoints(Label, Panel)
        call BlzFrameSetTextAlignment(Label, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        call BlzFrameSetScale(Label, TEXT_SCALE)
        call BlzFrameSetEnable(Label, false)
        call ApplyText(TEXT_COLOR, "")

        set gameUI = null
    endfunction

    private function Init takes nothing returns nothing
        // Build the frames after map init (they need the game UI to exist) and rebuild
        // them after a save-load if FrameLoader is present.
        call TimerStart(CreateTimer(), 0.00, false, function CreateUI)
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function CreateUI)
        endif
    endfunction

endlibrary
