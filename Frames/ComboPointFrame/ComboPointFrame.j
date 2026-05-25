library ComboPointFrame initializer Init

    globals
        private constant integer MAX_POINTS = 3
        private constant real ORB_SIZE = 0.022
        private constant real ORB_GAP = 0.004
        private constant real ANCHOR_X = 0.400
        private constant real ANCHOR_Y = 0.100
        private constant string ROGUE_ORB_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNOrbOfFire.blp"
        private constant string PRIEST_ORB_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNOrbOfDarkness.blp"

        private framehandle parentFrame = null
        private framehandle array orbFrame
        private timer initTimer = null

        private boolean array enabledForPlayer
        private unit array activeHero
        private integer array currentPoints
        private string array orbTexture
    endglobals

    function ComboPointFrameIsSupportedHero takes unit hero returns boolean
        return hero == udg_yA_Ass_Rogue or hero == udg_yH_Ass_Rogue or hero == udg_yA_Combat_Rogue or hero == udg_yH_Combat_Rogue or hero == udg_yA_Subtle_Rogue or hero == udg_yH_Subtle_Rogue or hero == udg_yA_Shadow_Priest or hero == udg_yH_Shadow_Priest
    endfunction

    private function IsPriestHero takes unit hero returns boolean
        return hero == udg_yA_Shadow_Priest or hero == udg_yH_Shadow_Priest
    endfunction

    private function GetTextureForHero takes unit hero returns string
        if IsPriestHero(hero) then
            return PRIEST_ORB_TEXTURE
        endif
        return ROGUE_ORB_TEXTURE
    endfunction

    private function NormalizePoints takes real points returns integer
        if points <= 0.00 then
            return 0
        elseif points >= I2R(MAX_POINTS) then
            return MAX_POINTS
        endif
        return R2I(points)
    endfunction

    private function RenderForLocalPlayer takes nothing returns nothing
        local player localPlayer
        local integer playerId
        local integer pointIndex = 0
        local boolean shouldShow

        if parentFrame == null then
            return
        endif

        set localPlayer = GetLocalPlayer()
        set playerId = GetPlayerId(localPlayer)
        set shouldShow = enabledForPlayer[playerId]

        call BlzFrameSetVisible(parentFrame, shouldShow)
        loop
            exitwhen pointIndex >= MAX_POINTS
            call BlzFrameSetTexture(orbFrame[pointIndex], orbTexture[playerId], 0, true)
            call BlzFrameSetVisible(orbFrame[pointIndex], shouldShow and pointIndex < currentPoints[playerId])
            set pointIndex = pointIndex + 1
        endloop

        set localPlayer = null
    endfunction

    function ComboPointFrameDisableForPlayer takes player whichPlayer returns nothing
        local integer playerId

        if whichPlayer == null then
            return
        endif

        set playerId = GetPlayerId(whichPlayer)
        set enabledForPlayer[playerId] = false
        set activeHero[playerId] = null
        set currentPoints[playerId] = 0
        call RenderForLocalPlayer()
    endfunction

    function ComboPointFrameEnableForHero takes unit hero returns nothing
        local player owner
        local integer playerId

        if hero == null then
            return
        endif

        set owner = GetOwningPlayer(hero)
        if not ComboPointFrameIsSupportedHero(hero) then
            call ComboPointFrameDisableForPlayer(owner)
            set owner = null
            return
        endif

        set playerId = GetPlayerId(owner)
        set enabledForPlayer[playerId] = true
        set activeHero[playerId] = hero
        set currentPoints[playerId] = 0
        set orbTexture[playerId] = GetTextureForHero(hero)
        call RenderForLocalPlayer()

        set owner = null
    endfunction

    function ComboPointFrameSetPointsForPlayer takes player whichPlayer, real points returns nothing
        local integer playerId

        if whichPlayer == null then
            return
        endif

        set playerId = GetPlayerId(whichPlayer)
        set currentPoints[playerId] = NormalizePoints(points)
        call RenderForLocalPlayer()
    endfunction

    function ComboPointFrameSetPoints takes unit hero, real points returns nothing
        local player owner
        local integer playerId

        if hero == null then
            return
        endif
        if not ComboPointFrameIsSupportedHero(hero) then
            return
        endif

        set owner = GetOwningPlayer(hero)
        set playerId = GetPlayerId(owner)
        if not enabledForPlayer[playerId] or activeHero[playerId] != hero then
            call ComboPointFrameEnableForHero(hero)
        endif

        set currentPoints[playerId] = NormalizePoints(points)
        call RenderForLocalPlayer()

        set owner = null
    endfunction

    function ComboPointFrameClear takes unit hero returns nothing
        call ComboPointFrameSetPoints(hero, 0.00)
    endfunction

    private function CreateOrbFrames takes nothing returns nothing
        local integer pointIndex = 0

        set parentFrame = BlzCreateFrameByType("FRAME", "ComboPointFrameParent", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetSize(parentFrame, I2R(MAX_POINTS) * ORB_SIZE + I2R(MAX_POINTS - 1) * ORB_GAP, ORB_SIZE)
        call BlzFrameSetAbsPoint(parentFrame, FRAMEPOINT_CENTER, ANCHOR_X, ANCHOR_Y)
        call BlzFrameSetLevel(parentFrame, 1)

        loop
            exitwhen pointIndex >= MAX_POINTS
            set orbFrame[pointIndex] = BlzCreateFrameByType("BACKDROP", "ComboPointFrameOrb", parentFrame, "", pointIndex)
            call BlzFrameSetSize(orbFrame[pointIndex], ORB_SIZE, ORB_SIZE)
            call BlzFrameSetPoint(orbFrame[pointIndex], FRAMEPOINT_LEFT, parentFrame, FRAMEPOINT_LEFT, I2R(pointIndex) * (ORB_SIZE + ORB_GAP), 0.0)
            call BlzFrameSetTexture(orbFrame[pointIndex], ROGUE_ORB_TEXTURE, 0, true)
            call BlzFrameSetEnable(orbFrame[pointIndex], false)
            call BlzFrameSetVisible(orbFrame[pointIndex], false)
            set pointIndex = pointIndex + 1
        endloop

        call BlzFrameSetVisible(parentFrame, false)
        call RenderForLocalPlayer()
    endfunction

    private function InitFrames takes nothing returns nothing
        if initTimer != null then
            call DestroyTimer(initTimer)
            set initTimer = null
        endif
        call CreateOrbFrames()
    endfunction

    private function InitPlayerDefaults takes nothing returns nothing
        local integer playerId = 0

        loop
            exitwhen playerId >= bj_MAX_PLAYERS
            set enabledForPlayer[playerId] = false
            set activeHero[playerId] = null
            set currentPoints[playerId] = 0
            set orbTexture[playerId] = ROGUE_ORB_TEXTURE
            set playerId = playerId + 1
        endloop
    endfunction

    private function Init takes nothing returns nothing
        call InitPlayerDefaults()
        set initTimer = CreateTimer()
        call TimerStart(initTimer, 0.00, false, function InitFrames)
    endfunction

endlibrary