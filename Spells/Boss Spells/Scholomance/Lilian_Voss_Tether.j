globals
    constant integer LVT_VOSS_UNIT_ID = 'E01E'
    constant integer LVT_VOSS_LEVEL = 40

    constant string LVT_BLINK_MODEL = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"

    // Swap this if you want a different tether beam.
    constant string LVT_LIGHTNING_CODE = "MYSB"

    constant real LVT_PERIOD = 0.025
    constant real LVT_RISE_TIME = 2.50
    constant real LVT_FINAL_HEIGHT = 550.00

    constant real LVT_SOURCE_Z_OFFSET = 50.00
    constant real LVT_UNIT_Z_OFFSET = 10.00

    unit LVT_Voss = null

    rect LVT_VossSpawnRect = null
    rect LVT_VossRaiseRect = null
    rect LVT_TetherSourceRect = null

    lightning LVT_Lightning = null

    real LVT_Elapsed = 0.00
    real LVT_StartHeight = 0.00
endglobals

function LVT_GetTerrainZ takes real x, real y returns real
    local location p = Location(x, y)
    local real z = GetLocationZ(p)

    call RemoveLocation(p)
    set p = null

    return z
endfunction

function LVT_EnableFlyHeight takes unit u returns nothing
    call UnitAddAbility(u, 'Amrf')
    call UnitRemoveAbility(u, 'Amrf')
endfunction

function LVT_ResetVossHeight takes unit u returns nothing
    if u == null then
        return
    endif

    call LVT_EnableFlyHeight(u)
    call SetUnitFlyHeight(u, 0.00, 0.00)
endfunction

function LVT_CreateBlinkAtUnit takes unit u returns nothing
    call DestroyEffect(AddSpecialEffectTarget(LVT_BLINK_MODEL, u, "origin"))
endfunction

function LVT_PrepareVoss takes unit u returns nothing
    call LVT_EnableFlyHeight(u)

    call SetUnitColor(u, PLAYER_COLOR_PURPLE)
    call SetUnitPathing(u, false)

    if IsUnitType(u, UNIT_TYPE_HERO) then
        call SetHeroLevel(u, LVT_VOSS_LEVEL, false)
        call SuspendHeroXP(u, true)
    endif

    call PauseAddInvuln(u, null)
endfunction

function LVT_CreateVossAtRect takes rect spawnRect, real facing returns unit
    local real x = GetRectCenterX(spawnRect)
    local real y = GetRectCenterY(spawnRect)
    local player p = Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u = CreateUnit(p, LVT_VOSS_UNIT_ID, x, y, facing)

    set LVT_Voss = u

    call LVT_PrepareVoss(u)
    call LVT_CreateBlinkAtUnit(u)

    set p = null

    return u
endfunction

function LVT_ShowOrCreateVossAtRect takes rect spawnRect, real facing, boolean showRevivalGraphics returns unit
    local location p

    if spawnRect == null then
        return null
    endif

    if LVT_Voss == null then
        set LVT_Voss = LVT_CreateVossAtRect(spawnRect, facing)
        return LVT_Voss
    endif

    call LVT_ResetVossHeight(LVT_Voss)

    set p = Location(GetRectCenterX(spawnRect), GetRectCenterY(spawnRect))
    call ShowHero(LVT_Voss, p, showRevivalGraphics)
    call RemoveLocation(p)
    set p = null

    call SetUnitFacing(LVT_Voss, facing)
    call LVT_PrepareVoss(LVT_Voss)
    call LVT_CreateBlinkAtUnit(LVT_Voss)

    return LVT_Voss
endfunction

function LVT_DestroyLightning takes nothing returns nothing
    if LVT_Lightning != null then
        call DestroyLightning(LVT_Lightning)
        set LVT_Lightning = null
    endif
endfunction

function LVT_UpdateLightning takes nothing returns nothing
    local real sx
    local real sy
    local real sz
    local real ux
    local real uy
    local real uz

    if LVT_Lightning == null or LVT_Voss == null or LVT_TetherSourceRect == null then
        return
    endif

    set sx = GetRectCenterX(LVT_TetherSourceRect)
    set sy = GetRectCenterY(LVT_TetherSourceRect)
    set sz = LVT_GetTerrainZ(sx, sy) + LVT_SOURCE_Z_OFFSET

    set ux = GetUnitX(LVT_Voss)
    set uy = GetUnitY(LVT_Voss)
    set uz = LVT_GetTerrainZ(ux, uy) + GetUnitFlyHeight(LVT_Voss) + LVT_UNIT_Z_OFFSET

    call MoveLightningEx(LVT_Lightning, false, sx, sy, sz, ux, uy, uz)
endfunction

function LVT_CreateLightning takes nothing returns nothing
    local real sx
    local real sy
    local real sz
    local real ux
    local real uy
    local real uz

    call LVT_DestroyLightning()

    if LVT_Voss == null or LVT_TetherSourceRect == null then
        return
    endif

    set sx = GetRectCenterX(LVT_TetherSourceRect)
    set sy = GetRectCenterY(LVT_TetherSourceRect)
    set sz = LVT_GetTerrainZ(sx, sy) + LVT_SOURCE_Z_OFFSET

    set ux = GetUnitX(LVT_Voss)
    set uy = GetUnitY(LVT_Voss)
    set uz = LVT_GetTerrainZ(ux, uy) + GetUnitFlyHeight(LVT_Voss) + LVT_UNIT_Z_OFFSET

    set LVT_Lightning = AddLightningEx(LVT_LIGHTNING_CODE, false, sx, sy, sz, ux, uy, uz)
endfunction

function LVT_MoveVossToRaiseRect takes nothing returns nothing
    local real rx
    local real ry
    local real dx
    local real dy

    if LVT_Voss == null or LVT_VossRaiseRect == null then
        return
    endif

    set rx = GetRectCenterX(LVT_VossRaiseRect)
    set ry = GetRectCenterY(LVT_VossRaiseRect)

    set dx = GetUnitX(LVT_Voss) - rx
    set dy = GetUnitY(LVT_Voss) - ry

    call SetUnitX(LVT_Voss, rx)
    call SetUnitY(LVT_Voss, ry)

    // Only make a second blink if future spawn/raise rects are different.
    if ((dx * dx) + (dy * dy)) > 4.00 then
        call LVT_CreateBlinkAtUnit(LVT_Voss)
    endif
endfunction

function Trig_Lilian_Voss_Tether_Actions takes nothing returns nothing
    local real t
    local real easedT
    local real h

    if LVT_Voss == null then
        call LVT_DestroyLightning()
        call DisableTrigger(gg_trg_Lilian_Voss_Tether)
        return
    endif

    set LVT_Elapsed = LVT_Elapsed + LVT_PERIOD
    set t = LVT_Elapsed / LVT_RISE_TIME

    if t > 1.00 then
        set t = 1.00
    endif

    // Smooth lift: slow start, faster middle, slow end.
    set easedT = 0.50 - (0.50 * Cos(t * bj_PI))
    set h = LVT_StartHeight + ((LVT_FINAL_HEIGHT - LVT_StartHeight) * easedT)

    call SetUnitFlyHeight(LVT_Voss, h, 0.00)
    call LVT_UpdateLightning()

    if t >= 1.00 then
        call SetUnitFlyHeight(LVT_Voss, LVT_FINAL_HEIGHT, 0.00)
        call LVT_UpdateLightning()

        // Voss remains paused, invulnerable, suspended, and tethered.
        call DisableTrigger(gg_trg_Lilian_Voss_Tether)
    endif
endfunction

function LVT_StartLiftTether takes unit voss, rect sourceRect, rect raiseRect returns nothing
    if voss == null or sourceRect == null or raiseRect == null then
        return
    endif

    set LVT_Voss = voss
    set LVT_TetherSourceRect = sourceRect
    set LVT_VossRaiseRect = raiseRect

    call LVT_PrepareVoss(voss)
    call LVT_MoveVossToRaiseRect()

    set LVT_Elapsed = 0.00
    set LVT_StartHeight = GetUnitFlyHeight(voss)

    call LVT_CreateLightning()
    call EnableTrigger(gg_trg_Lilian_Voss_Tether)
endfunction

function LVT_StartSequenceAtRects takes rect spawnRect, rect raiseRect, rect sourceRect returns nothing
    set LVT_VossSpawnRect = spawnRect
    set LVT_VossRaiseRect = raiseRect
    set LVT_TetherSourceRect = sourceRect

    set LVT_Voss = LVT_ShowOrCreateVossAtRect(LVT_VossSpawnRect, 270.00, false)

    if LVT_Voss == null then
        return
    endif

    call LVT_StartLiftTether(LVT_Voss, LVT_TetherSourceRect, LVT_VossRaiseRect)
endfunction

function LVT_StopAndCleanup takes nothing returns nothing
    call LVT_DestroyLightning()
    call DisableTrigger(gg_trg_Lilian_Voss_Tether)

    set LVT_Elapsed = 0.00
    set LVT_StartHeight = 0.00

    if LVT_Voss != null then
        call LVT_ResetVossHeight(LVT_Voss)
        call HideHero(LVT_Voss)
    endif
endfunction

function LVT_StartDefaultSequence takes nothing returns nothing
    call LVT_StopAndCleanup()
    call LVT_StartSequenceAtRects(gg_rct_Voss_Raise, gg_rct_Voss_Raise, gg_rct_Darkmaster_Gandling)
endfunction

//===========================================================================
function InitTrig_Lilian_Voss_Tether takes nothing returns nothing
    set gg_trg_Lilian_Voss_Tether = CreateTrigger()
    call DisableTrigger(gg_trg_Lilian_Voss_Tether)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Lilian_Voss_Tether, LVT_PERIOD)
    call TriggerAddAction(gg_trg_Lilian_Voss_Tether, function Trig_Lilian_Voss_Tether_Actions)
endfunction