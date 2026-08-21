globals
    constant string GHD_HAND_MODEL = "war3mapImported\\Skeletal Hand.mdx"
    constant string GHD_DAMAGE_MODEL = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl"
    constant integer GHD_HAND_COUNT = 13

    constant integer GHD_GRID_COLS = 4
    constant integer GHD_GRID_ROWS = 4

    integer array GHD_CellIndex

    effect array GHD_HandEffect
endglobals

function GHD_IsPlayerOwnedUnit takes unit u returns boolean
    local integer pid = GetPlayerId(GetOwningPlayer(u))

    return pid >= 0 and pid < bj_MAX_PLAYERS and GetWidgetLife(u) > 0.405
endfunction

function GHD_DestroyHands takes nothing returns nothing
    local integer i = 1

    loop
        exitwhen i > GHD_HAND_COUNT

        if GHD_HandEffect[i] != null then
            call BlzSetSpecialEffectScale(GHD_HandEffect[i], 0.05)
            call BlzSetSpecialEffectAlpha(GHD_HandEffect[i], 50)
            call DestroyEffect(GHD_HandEffect[i])
            set GHD_HandEffect[i] = null
        endif

        set i = i + 1
    endloop
endfunction

function GHD_CreateHands takes nothing returns nothing
    local integer totalCells = GHD_GRID_COLS * GHD_GRID_ROWS
    local integer i = 0
    local integer j
    local integer temp
    local integer cell
    local integer col
    local integer row

    local real minX = GetRectMinX(gg_rct_Harsh_Lesson_TP_4)
    local real maxX = GetRectMaxX(gg_rct_Harsh_Lesson_TP_4)
    local real minY = GetRectMinY(gg_rct_Harsh_Lesson_TP_4)
    local real maxY = GetRectMaxY(gg_rct_Harsh_Lesson_TP_4)

    local real cellW = (maxX - minX) / I2R(GHD_GRID_COLS)
    local real cellH = (maxY - minY) / I2R(GHD_GRID_ROWS)

    local real x
    local real y

    // Build cell list: 0 through 15 for a 4x4 grid.
    loop
        exitwhen i >= totalCells
        set GHD_CellIndex[i] = i
        set i = i + 1
    endloop

    // Shuffle cells.
    set i = totalCells - 1
    loop
        exitwhen i <= 0

        set j = GetRandomInt(0, i)

        set temp = GHD_CellIndex[i]
        set GHD_CellIndex[i] = GHD_CellIndex[j]
        set GHD_CellIndex[j] = temp

        set i = i - 1
    endloop

    // Place one hand inside each selected cell.
    set i = 1
    loop
        exitwhen i > GHD_HAND_COUNT or i > totalCells

        set cell = GHD_CellIndex[i - 1]
        set col = ModuloInteger(cell, GHD_GRID_COLS)
        set row = cell / GHD_GRID_COLS

        set x = minX + (I2R(col) * cellW) + GetRandomReal(cellW * 0.15, cellW * 0.85)
        set y = minY + (I2R(row) * cellH) + GetRandomReal(cellH * 0.15, cellH * 0.85)

        set GHD_HandEffect[i] = AddSpecialEffect(GHD_HAND_MODEL, x, y)
        call BlzSetSpecialEffectScale(GHD_HandEffect[i], 0.31)

        set i = i + 1
    endloop
endfunction

function Trig_Gandling_Hand_Damage_Actions takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local boolean foundPlayerUnit = false

    // Destroy the previous tick's hands.
    call GHD_DestroyHands()

    call GroupEnumUnitsInRect(g, gg_rct_Harsh_Lesson_TP_4, null)

    loop
        set u = FirstOfGroup(g)
        exitwhen u == null

        call GroupRemoveUnit(g, u)

        if GHD_IsPlayerOwnedUnit(u) then
            set foundPlayerUnit = true

            call UnitDamageTargetBJ(gg_unit_U01S_1754, u, 260.00, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )

            // Death Coil impact effect at the damaged unit's position.
            call DestroyEffect(AddSpecialEffect(GHD_DAMAGE_MODEL, GetUnitX(u), GetUnitY(u)))
        endif
    endloop

    call DestroyGroup(g)
    set g = null
    set u = null

    // If no player-owned units are inside, stop the periodic trigger.
    if not foundPlayerUnit then
        call DisableTrigger(gg_trg_Gandling_Hand_Damage)
        return
    endif

    // Create the next set of hands.
    call GHD_CreateHands()
endfunction

function Trig_Gandling_Hand_Damage_Start takes nothing returns nothing
    call GHD_DestroyHands()
    call EnableTrigger(gg_trg_Gandling_Hand_Damage)
endfunction

//===========================================================================
function InitTrig_Gandling_Hand_Damage takes nothing returns nothing
    set gg_trg_Gandling_Hand_Damage = CreateTrigger()
    call DisableTrigger(gg_trg_Gandling_Hand_Damage)
    call TriggerRegisterTimerEventPeriodic(gg_trg_Gandling_Hand_Damage, 1.20)
    call TriggerAddAction(gg_trg_Gandling_Hand_Damage, function Trig_Gandling_Hand_Damage_Actions)
endfunction