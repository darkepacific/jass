globals
    constant integer LVT_VOSS_UNIT_ID = 'E01E'
    constant integer LVT_VOSS_LEVEL = 40

    constant string LVT_BLINK_MODEL = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"

    // Swap this if you want a different tether beam.
    constant string LVT_LIGHTNING_CODE = "MYSB"

    constant real LVT_PERIOD = 0.025
    constant real LVT_RISE_TIME = 2.50
    constant real LVT_FALL_TIME = 1.00
    constant real LVT_FINAL_HEIGHT = 550.00

    constant real LVT_SOURCE_Z_OFFSET = 50.00
    constant real LVT_UNIT_Z_OFFSET = 10.00

    // Tether states.
    constant integer LVT_STATE_IDLE = 0
    constant integer LVT_STATE_RISING = 1
    constant integer LVT_STATE_FALLING = 2

    unit LVT_Voss = null

    rect LVT_VossSpawnRect = null
    rect LVT_VossRaiseRect = null
    rect LVT_TetherSourceRect = null

    lightning LVT_Lightning = null

    integer LVT_State = LVT_STATE_IDLE

    real LVT_Elapsed = 0.00

    real LVT_StartHeight = 0.00
    real LVT_ReleaseStartHeight = 0.00

    real LVT_StartX = 0.00
    real LVT_StartY = 0.00
    real LVT_TargetX = 0.00
    real LVT_TargetY = 0.00
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
    if u == null then
        return
    endif

    call DestroyEffect(AddSpecialEffectTarget(LVT_BLINK_MODEL, u, "origin"))
endfunction

function LVT_ConfigureVoss takes unit u returns nothing
    call LVT_EnableFlyHeight(u)

    call SetUnitColor(u, PLAYER_COLOR_PURPLE)
    call SetUnitPathing(u, false)

    if IsUnitType(u, UNIT_TYPE_HERO) then
        call SetHeroLevel(u, LVT_VOSS_LEVEL, false)
        call SuspendHeroXP(u, true)
    endif
endfunction

// Used while Voss needs to cast or attack.
// She can act, but cannot be damaged.
function LVT_PrepareVossForAttack takes unit u returns nothing
    call LVT_ConfigureVoss(u)
    call PauseUnit(u, false)
    call SetUnitInvulnerable(u, true)
endfunction

// Used while Gandling has Voss tethered.
// She cannot act or be damaged.
function LVT_PrepareVossForTether takes unit u returns nothing
    call LVT_ConfigureVoss(u)
    call PauseAddInvuln(u, null)
endfunction

function LVT_CreateVossAtRect takes rect spawnRect, real facing returns unit
    local real x = GetRectCenterX(spawnRect)
    local real y = GetRectCenterY(spawnRect)
    local player p = Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u = CreateUnit(p, LVT_VOSS_UNIT_ID, x, y, facing)

    set LVT_Voss = u

    call LVT_PrepareVossForAttack(u)

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
    call LVT_PrepareVossForAttack(LVT_Voss)

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

function Trig_Lilian_Voss_Tether_Actions takes nothing returns nothing
    local real t
    local real easedT
    local real x
    local real y
    local real h

    if LVT_Voss == null then
        call LVT_DestroyLightning()

        set LVT_State = LVT_STATE_IDLE

        call DisableTrigger(gg_trg_Lilian_Voss_Tether)
        return
    endif

    // =========================================================
    // RISING / BEING PULLED TOWARD GANDLING
    // =========================================================

    if LVT_State == LVT_STATE_RISING then
        set LVT_Elapsed = LVT_Elapsed + LVT_PERIOD
        set t = LVT_Elapsed / LVT_RISE_TIME

        if t > 1.00 then
            set t = 1.00
        endif

        // Smooth start and stop.
        set easedT = 0.50 - (0.50 * Cos(t * bj_PI))

        set x = LVT_StartX + ((LVT_TargetX - LVT_StartX) * easedT)
        set y = LVT_StartY + ((LVT_TargetY - LVT_StartY) * easedT)
        set h = LVT_StartHeight + ((LVT_FINAL_HEIGHT - LVT_StartHeight) * easedT)

        call SetUnitX(LVT_Voss, x)
        call SetUnitY(LVT_Voss, y)
        call SetUnitFlyHeight(LVT_Voss, h, 0.00)

        call LVT_UpdateLightning()

        if t >= 1.00 then
            call SetUnitX(LVT_Voss, LVT_TargetX)
            call SetUnitY(LVT_Voss, LVT_TargetY)
            call SetUnitFlyHeight(LVT_Voss, LVT_FINAL_HEIGHT, 0.00)

            call LVT_UpdateLightning()

            // Voss stays suspended and tethered.
            set LVT_State = LVT_STATE_IDLE
            call DisableTrigger(gg_trg_Lilian_Voss_Tether)
        endif

    // =========================================================
    // RELEASED / FALLING
    // =========================================================

    elseif LVT_State == LVT_STATE_FALLING then
        set LVT_Elapsed = LVT_Elapsed + LVT_PERIOD
        set t = LVT_Elapsed / LVT_FALL_TIME

        if t > 1.00 then
            set t = 1.00
        endif

        // Accelerating downward fall.
        set h = LVT_ReleaseStartHeight * (1.00 - (t * t))

        if h < 0.00 then
            set h = 0.00
        endif

        call SetUnitFlyHeight(LVT_Voss, h, 0.00)

        if t >= 1.00 then
            call SetUnitFlyHeight(LVT_Voss, 0.00, 0.00)

            set LVT_State = LVT_STATE_IDLE
            call DisableTrigger(gg_trg_Lilian_Voss_Tether)
        endif
    endif
endfunction

// Begins Gandling pulling Voss toward the tether position.
//
// Voss is NOT teleported.
// Her current X/Y becomes the starting position and she moves toward
// the center of raiseRect while simultaneously being lifted.
function LVT_StartLiftTether takes unit voss, rect sourceRect, rect raiseRect returns nothing
    if voss == null or sourceRect == null or raiseRect == null then
        return
    endif

    set LVT_Voss = voss
    set LVT_TetherSourceRect = sourceRect
    set LVT_VossRaiseRect = raiseRect

    call LVT_PrepareVossForTether(voss)

    set LVT_StartX = GetUnitX(voss)
    set LVT_StartY = GetUnitY(voss)

    set LVT_TargetX = GetRectCenterX(raiseRect)
    set LVT_TargetY = GetRectCenterY(raiseRect)

    set LVT_StartHeight = GetUnitFlyHeight(voss)
    set LVT_Elapsed = 0.00

    set LVT_State = LVT_STATE_RISING

    call LVT_CreateLightning()
    call EnableTrigger(gg_trg_Lilian_Voss_Tether)
endfunction

// Releases Voss from Gandling's tether.
//
// Lightning disappears immediately, then Voss falls vertically to
// the ground over LVT_FALL_TIME.
//
// She remains paused/invulnerable so cinematic logic can decide
// what happens to her afterward.
function LVT_Release takes nothing returns nothing
    call LVT_DestroyLightning()

    if LVT_Voss == null then
        set LVT_State = LVT_STATE_IDLE
        call DisableTrigger(gg_trg_Lilian_Voss_Tether)
        return
    endif

    set LVT_Elapsed = 0.00
    set LVT_ReleaseStartHeight = GetUnitFlyHeight(LVT_Voss)
    set LVT_State = LVT_STATE_FALLING

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

    set LVT_State = LVT_STATE_IDLE
    set LVT_Elapsed = 0.00

    set LVT_StartHeight = 0.00
    set LVT_ReleaseStartHeight = 0.00

    if LVT_Voss != null then
        call LVT_ResetVossHeight(LVT_Voss)
        call HideHero(LVT_Voss)
    endif
endfunction

function LVT_StartDefaultSequence takes nothing returns nothing
    call LVT_StopAndCleanup()
    call LVT_StartSequenceAtRects(gg_rct_Voss_Spawn_Die_Necro, gg_rct_Voss_Raise, gg_rct_Darkmaster_Gandling)
endfunction

//===========================================================================
function InitTrig_Lilian_Voss_Tether takes nothing returns nothing
    set gg_trg_Lilian_Voss_Tether = CreateTrigger()
    call DisableTrigger(gg_trg_Lilian_Voss_Tether)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Lilian_Voss_Tether, LVT_PERIOD)
    call TriggerAddAction(gg_trg_Lilian_Voss_Tether, function Trig_Lilian_Voss_Tether_Actions)
endfunction