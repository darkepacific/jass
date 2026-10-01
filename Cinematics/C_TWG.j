//===========================================================================
// THE WRATHGATE - SHARED WORLD CINEMATIC
//
// Started by an Alliance or Horde quest trigger after setting udg_Faction.
// The physical scene is visible to everyone. The camera pan, music change,
// dialogue track, and transmissions are limited to the completing faction.
//
// Expected Sound Editor variable:
//     gg_snd_Wrathgate_Cenamatic
//
// Expected regions:
//     gg_rct_Quest_TWG_Cinematic_Start
//     gg_rct_TWG_Arthas_Spawn
//     gg_rct_TWG_Arthas_Move
//     gg_rct_TWG_Bolvar
//     gg_rct_TWG_Saurfang
//     gg_rct_TWG_Putress
//     gg_rct_TWG_Apothecary_1
//     gg_rct_TWG_Apothecary_2
//     gg_rct_TWG_Catapult_1
//     gg_rct_TWG_Catapult_2
//     gg_rct_TWG_Catapult_3
//     gg_rct_TWG_Catapult_4
//     gg_rct_TWG_Catapult_5
//     gg_rct_TWG_Catapult_1_Move
//     gg_rct_TWG_Catapult_2_Move
//     gg_rct_TWG_Catapult_3_Move
//     gg_rct_TWG_Catapult_4_Move
//     gg_rct_TWG_Catapult_5_Move
//     gg_rct_TWG_Catapult_Initial_Blast
//     gg_rct_TWG_Catapult_Outer_Attack_1
//     gg_rct_TWG_Catapult_Outer_Attack_2
//     gg_rct_TWG_Catapult_Outer_Attack_3
//     gg_rct_TWG_Catapult_Outer_Attack_4
//     gg_rct_TWG_Catapult_Outer_Attack_5
//     gg_rct_TWG_Catapult_Precise_Scourge_Strike_1
//     gg_rct_TWG_Catapult_Precise_Scourge_Strike_2
//     gg_rct_TWG_Red_Dragons
//     gg_rct_TWG_Putress_Retreat
//===========================================================================
function Trig_C_TWG_PanCamera takes nothing returns nothing
    call PanCameraToTimedForPlayer(GetEnumPlayer(), GetRectCenterX(gg_rct_Quest_TWG_Cinematic_Start), GetRectCenterY(gg_rct_Quest_TWG_Cinematic_Start), 1.00)
endfunction

function Trig_C_TWG_FindGate takes nothing returns nothing
    if GetDestructableTypeId(GetEnumDestructable()) == 'ITtg' then
        set bj_lastCreatedDestructable = GetEnumDestructable()
    endif
endfunction

function Trig_C_TWG_RemoveUnit takes nothing returns nothing
    call RemoveUnit(GetEnumUnit())
endfunction

function Trig_C_TWG_KillUnit takes nothing returns nothing
    call KillUnit(GetEnumUnit())
endfunction

function Trig_C_TWG_LockUnit takes unit u returns nothing
    call SetUnitInvulnerable(u, true)
    call PauseUnit(u, true)
endfunction

// Wait for an absolute timestamp measured from the start of the dialogue track.
// If an earlier action ran late, this automatically shortens or skips the wait.
function Trig_C_TWG_WaitUntil takes timer sceneTimer, real timestamp returns nothing
    local real remaining = timestamp - TimerGetElapsed(sceneTimer)
    if remaining > 0.00 then
        call GameTimeWait(remaining)
    endif
endfunction

// Hold Bolvar only after he has walked onto the retreat point.
// A wide arrival radius was pausing him short of the region center. The move
// order also completes a step early, so that last step is corrected only once
// he is already beside the point. Never snap him in from range.
function Trig_C_TWG_StopBolvarIfDue takes unit bolvar, timer sceneTimer, real arrival, real nextBeat, boolean stopped returns boolean
    local real targetX
    local real targetY
    local real dx
    local real dy
    local real distanceSquared
    if stopped then
        return true
    endif
    set targetX = GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2)
    set targetY = GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2)
    set dx = GetUnitX(bolvar) - targetX
    set dy = GetUnitY(bolvar) - targetY
    set distanceSquared = dx * dx + dy * dy
    // On the point, or the order already finished just short of it.
    if distanceSquared <= 36.00 * 36.00 or (distanceSquared <= 72.00 * 72.00 and GetUnitCurrentOrder(bolvar) != OrderId("move")) then
        call SetUnitX(bolvar, targetX)
        call SetUnitY(bolvar, targetY)
        call IssueImmediateOrder(bolvar, "stop")
        call PauseUnit(bolvar, true)
        return true
    endif
    // Neutral Passive will walk him home once the move order ends. Refresh it
    // until he is actually at the retreat point, then pause him there.
    if GetUnitCurrentOrder(bolvar) != OrderId("move") then
        call IssuePointOrder(bolvar, "move", targetX, targetY)
    endif
    return false
endfunction

function Trig_C_TWG_CreateFormation takes integer unitId, player owner, integer colorId, real heroX, real heroY, real targetX, real targetY, group sceneUnits, group army returns nothing
    local integer row = 0
    local integer column
    local real distance = SquareRoot((targetX - heroX) * (targetX - heroX) + (targetY - heroY) * (targetY - heroY))
    local real forwardX = (targetX - heroX) / distance
    local real forwardY = (targetY - heroY) / distance
    local real sideX = -forwardY
    local real sideY = forwardX
    local real rearDistance
    local real sideDistance
    local real ux
    local real uy
    local real facing = Atan2(targetY - heroY, targetX - heroX) * bj_RADTODEG
    local unit u
    loop
        exitwhen row >= 2
        set column = 0
        set rearDistance = 190.00 + 145.00 * I2R(row)
        loop
            exitwhen column >= 6
            set sideDistance = (I2R(column) - 2.50) * 115.00
            set ux = heroX - forwardX * rearDistance + sideX * sideDistance
            set uy = heroY - forwardY * rearDistance + sideY * sideDistance
            set u = CreateUnit(owner, unitId, ux, uy, facing)
            call SetUnitColor(u, ConvertPlayerColor(colorId))
            call SetUnitManaPercentBJ(u, 100.00)
            call SetUnitMoveSpeed(u, GetUnitDefaultMoveSpeed(u) - 50)
            call Trig_C_TWG_LockUnit(u)
            call GroupAddUnit(sceneUnits, u)
            call GroupAddUnit(army, u)
            set column = column + 1
        endloop
        set row = row + 1
    endloop
    set u = null
endfunction

// Creates one six-unit rank behind a commander, using the same facing and
// spacing as the two front infantry ranks.
function Trig_C_TWG_CreateFormationLine takes integer unitId, player owner, integer colorId, real heroX, real heroY, real targetX, real targetY, real rearDistance, group sceneUnits, group army returns nothing
    local integer column = 0
    local real distance = SquareRoot((targetX - heroX) * (targetX - heroX) + (targetY - heroY) * (targetY - heroY))
    local real forwardX = (targetX - heroX) / distance
    local real forwardY = (targetY - heroY) / distance
    local real sideX = -forwardY
    local real sideY = forwardX
    local real sideDistance
    local real ux
    local real uy
    local real facing = Atan2(targetY - heroY, targetX - heroX) * bj_RADTODEG
    local unit u
    loop
        exitwhen column >= 6
        set sideDistance = (I2R(column) - 2.50) * 115.00
        set ux = heroX - forwardX * rearDistance + sideX * sideDistance
        set uy = heroY - forwardY * rearDistance + sideY * sideDistance
        set u = CreateUnit(owner, unitId, ux, uy, facing)
        call SetUnitColor(u, ConvertPlayerColor(colorId))
        call Trig_C_TWG_LockUnit(u)
        call GroupAddUnit(sceneUnits, u)
        call GroupAddUnit(army, u)
        set column = column + 1
    endloop
    set u = null
endfunction

// Creates three undead on a battlefield-facing arc. The alternating arc offset
// used by the caller keeps the center lane clear for Saurfang's charge.
function Trig_C_TWG_CreateUndead takes integer unitId, real x, real y, real radius, real arcOffset, real targetX, real targetY, group sceneUnits, group newUndead returns nothing
    local integer i = 0
    local real battlefieldAngle = Atan2(targetY - y, targetX - x) * bj_RADTODEG
    local real angle
    local real ux
    local real uy
    local unit u
    loop
        exitwhen i >= 3

        // All three positions stay on the half of Arthas that faces the armies.
        set angle = battlefieldAngle + arcOffset + 52.00 * I2R(i)
        set ux = x + radius * Cos(angle * bj_DEGTORAD)
        set uy = y + radius * Sin(angle * bj_DEGTORAD)
        set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), unitId, ux, uy, Atan2(targetY - uy, targetX - ux) * bj_RADTODEG)
        call SetUnitInvulnerable(u, true)
        call PauseUnit(u, true)

        // These are paused cinematic actors and should not block Saurfang's charge.
        call SetUnitPathing(u, false)
        call SetUnitAcquireRange(u, 0.00)
        call SetUnitAnimation(u, "birth")
        call GroupAddUnit(sceneUnits, u)
        call GroupAddUnit(newUndead, u)
        set i = i + 1
    endloop
    set u = null
endfunction

function Trig_C_TWG_StandNewUndead takes group newUndead returns nothing
    local group temp = CreateGroup()
    local unit u
    call GroupAddGroup(newUndead, temp)
    loop
        set u = FirstOfGroup(temp)
        exitwhen u == null
        call GroupRemoveUnit(temp, u)
        call SetUnitAnimation(u, "stand")
    endloop
    call DestroyGroup(temp)
    set temp = null
    set u = null
endfunction

function Trig_C_TWG_KillRandomArmy takes group army, integer count returns nothing
    local group temp = CreateGroup()
    local unit u
    local integer i = 0
    call GroupAddGroup(army, temp)
    loop
        exitwhen i >= count or FirstOfGroup(temp) == null
        set u = GroupPickRandomUnit(temp)
        call GroupRemoveUnit(temp, u)
        if GetWidgetLife(u) > 0.405 then
            call KillUnit(u)
            set i = i + 1
        endif
    endloop
    call DestroyGroup(temp)
    set temp = null
    set u = null
endfunction

// Kills the living Scourge actor nearest to Saurfang. Called while he is charging.
function Trig_C_TWG_KillClosestUndead takes unit saurfang, group undead returns nothing
    local group temp = CreateGroup()
    local unit u
    local unit closest = null
    local real bestDistance = 100000000.00
    local real dx
    local real dy
    local real distance
    local real saurfangX = GetUnitX(saurfang)
    local real saurfangY = GetUnitY(saurfang)
    call GroupAddGroup(undead, temp)
    loop
        set u = FirstOfGroup(temp)
        exitwhen u == null
        call GroupRemoveUnit(temp, u)
        if GetWidgetLife(u) > 0.405 then
            set dx = GetUnitX(u) - saurfangX
            set dy = GetUnitY(u) - saurfangY
            set distance = dx * dx + dy * dy
            if distance < bestDistance then
                set bestDistance = distance
                set closest = u
            endif
        endif
    endloop
    if closest != null then
        call SetUnitInvulnerable(closest, false)
        call PauseUnit(closest, false)
        call KillUnit(closest)
    endif
    call DestroyGroup(temp)
    set temp = null
    set u = null
    set closest = null
endfunction

function Trig_C_TWG_CollectImpactVictims takes group units, group victims, real x, real y, real radius returns integer
    local group temp = CreateGroup()
    local unit u
    local real dx
    local real dy
    local real radiusSquared = radius * radius
    local integer count = 0
    call GroupAddGroup(units, temp)
    loop
        set u = FirstOfGroup(temp)
        exitwhen u == null
        call GroupRemoveUnit(temp, u)
        if GetWidgetLife(u) > 0.405 then
            set dx = GetUnitX(u) - x
            set dy = GetUnitY(u) - y
            if dx * dx + dy * dy <= radiusSquared then
                call GroupAddUnit(victims, u)
                set count = count + 1
            endif
        endif
    endloop
    call DestroyGroup(temp)
    set temp = null
    set u = null
    return count
endfunction

function Trig_C_TWG_CollectImpactVictimsOfType takes group units, group victims, integer unitTypeId, real x, real y, real radius returns integer
    local group temp = CreateGroup()
    local unit u
    local real dx
    local real dy
    local real radiusSquared = radius * radius
    local integer count = 0
    call GroupAddGroup(units, temp)
    loop
        set u = FirstOfGroup(temp)
        exitwhen u == null
        call GroupRemoveUnit(temp, u)
        if GetWidgetLife(u) > 0.405 and GetUnitTypeId(u) == unitTypeId then
            set dx = GetUnitX(u) - x
            set dy = GetUnitY(u) - y
            if dx * dx + dy * dy <= radiusSquared then
                call GroupAddUnit(victims, u)
                set count = count + 1
            endif
        endif
    endloop
    call DestroyGroup(temp)
    set temp = null
    set u = null
    return count
endfunction

// Crow form has to be applied before death or the corpse will not leave the ground.
function Trig_C_TWG_TossDyingUnit takes unit u, real x, real y returns nothing
    local real dx = GetUnitX(u) - x
    local real dy = GetUnitY(u) - y
    local real angle
    if dx * dx + dy * dy < 1.00 then
        set angle = GetRandomReal(0.00, 360.00)
    else
        set angle = Atan2(dy, dx) * bj_RADTODEG + GetRandomReal(-20.00, 20.00)
    endif
    call SetUnitInvulnerable(u, false)
    call PauseUnit(u, false)
    call SetUnitFacing(u, angle)
    call KnockBackUnit(u, angle, 0.00, 200.00, 0.00, 22.00, true)
    call KillUnit(u)
endfunction

// Kills 4-6 living units near a plague impact. If the primary radius contains
// fewer than four candidates, one wider local search is used instead.
function Trig_C_TWG_KillNearPlagueImpact takes group units, real x, real y, real primaryRadius, real backupRadius, boolean toss returns nothing
    local group victims = CreateGroup()
    local unit u
    local integer available
    local integer killGoal
    local integer killed = 0
    set available = Trig_C_TWG_CollectImpactVictims(units, victims, x, y, primaryRadius)
    if available < 4 then
        call GroupClear(victims)
        set available = Trig_C_TWG_CollectImpactVictims(units, victims, x, y, backupRadius)
    endif
    set killGoal = GetRandomInt(4, 6)
    if killGoal > available then
        set killGoal = available
    endif
    loop
        exitwhen killed >= killGoal
        set u = GroupPickRandomUnit(victims)
        exitwhen u == null
        call GroupRemoveUnit(victims, u)
        if toss then
            call Trig_C_TWG_TossDyingUnit(u, x, y)
        else
            call KillUnit(u)
        endif
        set killed = killed + 1
    endloop
    call DestroyGroup(victims)
    set victims = null
    set u = null
endfunction

// Kills an exact number of one unit type near an impact, using the wider
// radius only when the primary blast area does not contain enough targets.
function Trig_C_TWG_KillNearPlagueImpactOfType takes group units, integer unitTypeId, integer count, real x, real y, real primaryRadius, real backupRadius returns nothing
    local group victims = CreateGroup()
    local unit u
    local integer available
    local integer killGoal = count
    local integer killed = 0
    set available = Trig_C_TWG_CollectImpactVictimsOfType(units, victims, unitTypeId, x, y, primaryRadius)
    if available < count then
        call GroupClear(victims)
        set available = Trig_C_TWG_CollectImpactVictimsOfType(units, victims, unitTypeId, x, y, backupRadius)
    endif
    if killGoal > available then
        set killGoal = available
    endif
    loop
        exitwhen killed >= killGoal
        set u = GroupPickRandomUnit(victims)
        exitwhen u == null
        call GroupRemoveUnit(victims, u)
        call KillUnit(u)
        set killed = killed + 1
    endloop
    call DestroyGroup(victims)
    set victims = null
    set u = null
endfunction

function Trig_C_TWG_ScatterUnits takes group units, real centerX, real centerY returns nothing
    local group temp = CreateGroup()
    local unit u
    local real angle
    local real distance
    local real targetX
    local real targetY
    call GroupAddGroup(units, temp)
    loop
        set u = FirstOfGroup(temp)
        exitwhen u == null
        call GroupRemoveUnit(temp, u)
        if GetWidgetLife(u) > 0.405 then
            set angle = Atan2(GetUnitY(u) - centerY, GetUnitX(u) - centerX) + GetRandomReal(-35.00, 35.00) * bj_DEGTORAD
            set distance = GetRandomReal(900.00, 1400.00)
            set targetX = GetUnitX(u) + Cos(angle) * distance
            set targetY = GetUnitY(u) + Sin(angle) * distance
            call PauseUnit(u, false)
            call SetUnitFacing(u, angle * bj_RADTODEG)
            call IssuePointOrder(u, "move", targetX, targetY)
        endif
    endloop
    call DestroyGroup(temp)
    set temp = null
    set u = null
endfunction

function Trig_C_TWG_PlagueBurst takes real x, real y, hashtable plagueClouds, integer cloudCount returns integer
    local effect e
    local effect cloud
    set e = AddSpecialEffect("war3mapImported\\FelMeteor.mdx", x, y)
    call BlzSetSpecialEffectScale(e, 0.75)
    call DestroyEffect(e)
    set e = AddSpecialEffect("war3mapImported\\WotLK-Plague -Forsaken-Catapult Missile.mdx", x, y)
    call BlzSetSpecialEffectScale(e, 1.00)
    call DestroyEffect(e)
    set e = AddSpecialEffect("Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl", x, y)
    call BlzSetSpecialEffectScale(e, 1.35)
    call DestroyEffect(e)
    set cloud = AddSpecialEffect("war3mapImported\\ForsakenCatapultPlagueEmbersEffect.mdx", x, y)
    call SaveEffectHandle(plagueClouds, 0, cloudCount, cloud)
    call SaveReal(plagueClouds, 1, cloudCount, x)
    call SaveReal(plagueClouds, 2, cloudCount, y)
    set cloudCount = cloudCount + 1
    set cloud = AddSpecialEffect("units\\undead\\PlagueCloud\\PlagueCloud.mdl", x, y)
    call SaveEffectHandle(plagueClouds, 0, cloudCount, cloud)
    call SaveReal(plagueClouds, 1, cloudCount, x)
    call SaveReal(plagueClouds, 2, cloudCount, y)
    set cloudCount = cloudCount + 1
    set cloud = AddSpecialEffect("war3mapImported\\ElitePlagueCloud.mdx", x, y)
    call BlzSetSpecialEffectScale(cloud, 0.9)
    call SaveEffectHandle(plagueClouds, 0, cloudCount, cloud)
    call SaveReal(plagueClouds, 1, cloudCount, x)
    call SaveReal(plagueClouds, 2, cloudCount, y)
    set cloudCount = cloudCount + 1
    set e = null
    set cloud = null
    return cloudCount
endfunction

function Trig_C_TWG_ClearPlagueClouds takes hashtable plagueClouds, integer cloudCount returns nothing
    local integer i = 0
    local effect cloud
    loop
        exitwhen i >= cloudCount
        set cloud = LoadEffectHandle(plagueClouds, 0, i)
        if cloud != null then
            call DestroyEffect(cloud)
            call RemoveSavedHandle(plagueClouds, 0, i)
            call RemoveSavedReal(plagueClouds, 1, i)
            call RemoveSavedReal(plagueClouds, 2, i)
        endif
        set i = i + 1
    endloop
    set cloud = null
endfunction

// Removes only plague effects reached by a dragon-fire burst.
function Trig_C_TWG_ClearPlagueNearPoint takes hashtable plagueClouds, integer cloudCount, real x, real y, real radius returns nothing
    local integer i = 0
    local real dx
    local real dy
    local real radiusSquared = radius * radius
    local effect cloud
    loop
        exitwhen i >= cloudCount
        set cloud = LoadEffectHandle(plagueClouds, 0, i)
        if cloud != null then
            set dx = LoadReal(plagueClouds, 1, i) - x
            set dy = LoadReal(plagueClouds, 2, i) - y
            if dx * dx + dy * dy <= radiusSquared then
                call DestroyEffect(cloud)
                call RemoveSavedHandle(plagueClouds, 0, i)
                call RemoveSavedReal(plagueClouds, 1, i)
                call RemoveSavedReal(plagueClouds, 2, i)
            endif
        endif
        set i = i + 1
    endloop
    set cloud = null
endfunction

// Finds a surviving plague effect so a cleansing burst can visibly strike it.
function Trig_C_TWG_GetRandomPlagueIndex takes hashtable plagueClouds, integer cloudCount returns integer
    local integer start
    local integer offset = 0
    local integer index
    if cloudCount <= 0 then
        return -1
    endif
    set start = GetRandomInt(0, cloudCount - 1)
    loop
        exitwhen offset >= cloudCount
        set index = ModuloInteger(start + offset, cloudCount)
        if LoadEffectHandle(plagueClouds, 0, index) != null then
            return index
        endif
        set offset = offset + 1
    endloop
    return -1
endfunction

function Trig_C_TWG_OrderCatapultAtRandomUnit takes unit catapult, group targets, hashtable plagueClouds, integer cloudCount returns integer
    local group temp = CreateGroup()
    local unit target = null
    local unit candidate
    local real targetX
    local real targetY
    call GroupAddGroup(targets, temp)
    loop
        set candidate = GroupPickRandomUnit(temp)
        exitwhen candidate == null
        call GroupRemoveUnit(temp, candidate)
        if GetWidgetLife(candidate) > 0.405 then
            set target = candidate
            set candidate = null
        endif
        exitwhen target != null
    endloop
    if target != null then
        set targetX = GetUnitX(target)
        set targetY = GetUnitY(target)
        call IssuePointOrder(catapult, "attackground", targetX, targetY)
        set cloudCount = Trig_C_TWG_PlagueBurst(targetX, targetY, plagueClouds, cloudCount)
    endif
    call DestroyGroup(temp)
    set temp = null
    set target = null
    set candidate = null
    return cloudCount
endfunction

function Trig_C_TWG_OrderDragonMove takes unit dragon, real targetX, real targetY, real jitter returns nothing
    call IssuePointOrder(dragon, "move", targetX + GetRandomReal(-jitter, jitter), targetY + GetRandomReal(-jitter, jitter))
endfunction

function Trig_C_TWG_DragonStrikeUnit takes unit dragon, unit target returns nothing
    call SetUnitInvulnerable(target, false)
    call PauseUnit(target, false)
    call IssueTargetOrder(dragon, "attack", target)
endfunction

function Trig_C_TWG_DragonAttackGround takes unit dragon, real targetX, real targetY, group sceneUnits returns unit
    local unit target = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'e025', targetX, targetY, 0.00)
    call SetUnitPathing(target, false)
    call PauseUnit(target, true)
    call SetUnitInvulnerable(target, false)
    call BlzSetUnitMaxHP(target, 100000)
    call SetUnitState(target, UNIT_STATE_LIFE, 100000.00)
    call SetUnitVertexColor(target, 255, 255, 255, 0)
    call GroupAddUnit(sceneUnits, target)
    call SetUnitAnimation(dragon, "attack")
    call IssueTargetOrder(dragon, "attack", target)
    return target
endfunction

// Leaves a persistent fire where cleansing dragon flame landed.
function Trig_C_TWG_AddDragonFire takes real x, real y, real scale, hashtable fires, integer fireCount returns integer
    local effect fire = AddSpecialEffect("Environment\\LargeBuildingFire\\LargeBuildingFire2.mdl", x, y)
    call BlzSetSpecialEffectScale(fire, scale)
    call SaveEffectHandle(fires, 0, fireCount, fire)
    set fire = null
    return fireCount + 1
endfunction

function Trig_C_TWG_ClearDragonFires takes hashtable fires, integer fireCount returns nothing
    local integer i = 0
    local effect fire
    loop
        exitwhen i >= fireCount
        set fire = LoadEffectHandle(fires, 0, i)
        if fire != null then
            call DestroyEffect(fire)
            call RemoveSavedHandle(fires, 0, i)
        endif
        set i = i + 1
    endloop
    set fire = null
endfunction

// Creates five cleansing bursts. Four preferentially land on surviving plague
// patches; the fifth remains random so the battlefield burn feels less rigid.
function Trig_C_TWG_DragonFire takes hashtable plagueClouds, integer plagueCloudCount, hashtable fires, integer fireCount returns integer
    local integer i = 0
    local integer plagueIndex
    local real x
    local real y
    local effect e
    loop
        exitwhen i >= 5
        set plagueIndex = -1
        if i < 4 then
            set plagueIndex = Trig_C_TWG_GetRandomPlagueIndex(plagueClouds, plagueCloudCount)
        endif
        if plagueIndex >= 0 then
            set x = LoadReal(plagueClouds, 1, plagueIndex)
            set y = LoadReal(plagueClouds, 2, plagueIndex)
        else
            set x = GetRandomReal(GetRectMinX(gg_rct_Quest_TWG_Cinematic_Start) + 128.00, GetRectMaxX(gg_rct_Quest_TWG_Cinematic_Start) - 128.00)
            set y = GetRandomReal(GetRectMinY(gg_rct_Quest_TWG_Cinematic_Start) + 128.00, GetRectMaxY(gg_rct_Quest_TWG_Cinematic_Start) - 128.00)
        endif
        set e = AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", x, y)
        call BlzSetSpecialEffectScale(e, GetRandomReal(1.00, 1.60))
        call DestroyEffect(e)
        set e = AddSpecialEffect("Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl", x, y)
        call BlzSetSpecialEffectScale(e, 1.40)
        call DestroyEffect(e)
        set fireCount = Trig_C_TWG_AddDragonFire(x, y, 0.90, fires, fireCount)
        call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, x, y, 300.00)
        set i = i + 1
    endloop
    set e = null
    return fireCount
endfunction

function Trig_C_TWG_StartFog takes fogmodifier f returns nothing
    if f != null then
        call FogModifierStart(f)
    endif
endfunction

function Trig_C_TWG_DestroyFog takes fogmodifier f returns nothing
    if f != null then
        call FogModifierStop(f)
        call DestroyFogModifier(f)
    endif
endfunction

function Trig_C_TWG_Actions takes nothing returns nothing
    local force viewers = CreateForce()
    local group sceneUnits = CreateGroup()
    local group army = CreateGroup()
    local group fallbackUnits = CreateGroup()
    local group newUndead = CreateGroup()
    local hashtable plagueClouds = InitHashtable()
    local hashtable dragonFires = InitHashtable()
    local integer plagueCloudCount = 0
    local integer dragonFireCount = 0
    local destructable gate = null
    local location scenePoint = GetRectCenter(gg_rct_Quest_TWG_Cinematic_Start)
    local fogmodifier fog1 = null
    local fogmodifier fog2 = null
    local fogmodifier fog3 = null
    local fogmodifier fog4 = null
    local real sceneX = GetLocationX(scenePoint)
    local real sceneY = GetLocationY(scenePoint)
    local real gateX
    local real gateY
    local real arthasSpawnX = GetRectCenterX(gg_rct_TWG_Arthas_Spawn)
    local real arthasSpawnY = GetRectCenterY(gg_rct_TWG_Arthas_Spawn)
    local real arthasX = GetRectCenterX(gg_rct_TWG_Arthas_Move)
    local real arthasY = GetRectCenterY(gg_rct_TWG_Arthas_Move)
    local real bolvarX = GetRectCenterX(gg_rct_TWG_Bolvar)
    local real bolvarY = GetRectCenterY(gg_rct_TWG_Bolvar)
    local real saurfangX = GetRectCenterX(gg_rct_TWG_Saurfang)
    local real saurfangY = GetRectCenterY(gg_rct_TWG_Saurfang)
    local real putressX = GetRectCenterX(gg_rct_TWG_Putress)
    local real putressY = GetRectCenterY(gg_rct_TWG_Putress)
    local real putressRetreatX = GetRectCenterX(gg_rct_TWG_Putress_Retreat)
    local real putressRetreatY = GetRectCenterY(gg_rct_TWG_Putress_Retreat)
    local real dragonX = GetRectCenterX(gg_rct_TWG_Red_Dragons)
    local real dragonY = GetRectCenterY(gg_rct_TWG_Red_Dragons)
    local real scourgeStrike1X = arthasX + (GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1) - arthasX) * 0.50
    local real scourgeStrike1Y = arthasY + (GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1) - arthasY) * 0.50
    local real scourgeStrike2X = arthasX + (GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2) - arthasX) * 0.50
    local real scourgeStrike2Y = arthasY + (GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2) - arthasY) * 0.50
    local real scourgeStrike3X = arthasX + (GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3) - arthasX) * 0.50
    local real scourgeStrike3Y = arthasY + (GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3) - arthasY) * 0.50
    local real scourgeStrike4X = arthasX + (GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4) - arthasX) * 0.50
    local real scourgeStrike4Y = arthasY + (GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4) - arthasY) * 0.50
    local real scourgeStrike5X = GetRectCenterX(gg_rct_TWG_Catapult_Precise_Scourge_Strike_1)
    local real scourgeStrike5Y = GetRectCenterY(gg_rct_TWG_Catapult_Precise_Scourge_Strike_1)
    local real scourgeStrike6X = GetRectCenterX(gg_rct_TWG_Catapult_Precise_Scourge_Strike_2)
    local real scourgeStrike6Y = GetRectCenterY(gg_rct_TWG_Catapult_Precise_Scourge_Strike_2)
    local real bolvarRetreatX
    local real bolvarRetreatY
    local real bolvarSpeed
    local real bolvarArrival = 0.00
    local boolean bolvarStopped = false
    local unit arthas
    local unit bolvar
    local unit saurfang
    local unit putress
    local unit apothecary1
    local unit apothecary2
    local unit catapult1
    local unit catapult2
    local unit catapult3
    local unit catapult4
    local unit catapult5
    local unit dragon1 = null
    local unit dragon2 = null
    local unit dragon3 = null
    local unit dragon4 = null
    local unit dragon5 = null
    local unit dragonAttackTarget1 = null
    local unit dragonAttackTarget2 = null
    local unit dragonAttackTarget3 = null
    local effect soulEffect = null
    local effect bloodEffect = null
    local effect chargeEffect = null
    local effect zigguratMissile1 = null
    local effect zigguratMissile2 = null
    local effect zigguratMissile3 = null
    local timer sceneTimer = CreateTimer()

    // Only one physical showing can run at once. If both factions complete the
    // quest together, the second showing waits for the first cleanup.
    loop
        exitwhen IsTriggerEnabled(gg_trg_C_TWG)
        call GameTimeWait(1.00)
    endloop
    call DisableTrigger(gg_trg_C_TWG)
    if udg_Faction == 0 then
        call ForceAddPlayer(viewers, Player(2))
        call ForceAddPlayer(viewers, Player(7))
        call ForceAddPlayer(viewers, Player(8))
        call ForceAddPlayer(viewers, Player(9))
        set fog1 = CreateFogModifierRadius(Player(2), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog2 = CreateFogModifierRadius(Player(7), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog3 = CreateFogModifierRadius(Player(8), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog4 = CreateFogModifierRadius(Player(9), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
    else
        call ForceAddPlayer(viewers, Player(4))
        call ForceAddPlayer(viewers, Player(5))
        call ForceAddPlayer(viewers, Player(6))
        call ForceAddPlayer(viewers, Player(10))
        set fog1 = CreateFogModifierRadius(Player(4), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog2 = CreateFogModifierRadius(Player(5), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog3 = CreateFogModifierRadius(Player(6), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
        set fog4 = CreateFogModifierRadius(Player(10), FOG_OF_WAR_VISIBLE, sceneX, sceneY, 2400.00, true, false)
    endif
    call Trig_C_TWG_StartFog(fog1)
    call Trig_C_TWG_StartFog(fog2)
    call Trig_C_TWG_StartFog(fog3)
    call Trig_C_TWG_StartFog(fog4)
    call ForForce(viewers, function Trig_C_TWG_PanCamera)

    // Find the single Icecrown gate inside the cinematic region.
    set bj_lastCreatedDestructable = null
    call EnumDestructablesInRect(gg_rct_Quest_TWG_Cinematic_Start, null, function Trig_C_TWG_FindGate)
    set gate = bj_lastCreatedDestructable
    if gate != null then
        set gateX = GetDestructableX(gate)
        set gateY = GetDestructableY(gate)
    else
        set gateX = arthasX
        set gateY = arthasY
    endif

    // Main cast.
    set arthas = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', arthasSpawnX, arthasSpawnY, Atan2(arthasY - gateY, arthasX - gateX) * bj_RADTODEG)
    call SetUnitMoveSpeed(arthas, GetUnitDefaultMoveSpeed(arthas) - 45)
    set bolvar = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'H048', bolvarX, bolvarY, Atan2(arthasY - bolvarY, arthasX - bolvarX) * bj_RADTODEG)
    set saurfang = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'H049', saurfangX, saurfangY, Atan2(arthasY - saurfangY, arthasX - saurfangX) * bj_RADTODEG)
    call SetUnitMoveSpeed(saurfang, GetUnitDefaultMoveSpeed(saurfang) - 35)
    set putress = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', putressX, putressY, Atan2(arthasY - putressY, arthasX - putressX) * bj_RADTODEG)
    set apothecary1 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u048', GetRectCenterX(gg_rct_TWG_Apothecary_1), GetRectCenterY(gg_rct_TWG_Apothecary_1), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Apothecary_1), arthasX - GetRectCenterX(gg_rct_TWG_Apothecary_1)) * bj_RADTODEG)
    set apothecary2 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u048', GetRectCenterX(gg_rct_TWG_Apothecary_2), GetRectCenterY(gg_rct_TWG_Apothecary_2), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Apothecary_2), arthasX - GetRectCenterX(gg_rct_TWG_Apothecary_2)) * bj_RADTODEG)
    set catapult1 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04F', GetRectCenterX(gg_rct_TWG_Catapult_1), GetRectCenterY(gg_rct_TWG_Catapult_1), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Catapult_1), arthasX - GetRectCenterX(gg_rct_TWG_Catapult_1)) * bj_RADTODEG)
    set catapult2 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04F', GetRectCenterX(gg_rct_TWG_Catapult_2), GetRectCenterY(gg_rct_TWG_Catapult_2), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Catapult_2), arthasX - GetRectCenterX(gg_rct_TWG_Catapult_2)) * bj_RADTODEG)
    set catapult3 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04F', GetRectCenterX(gg_rct_TWG_Catapult_3), GetRectCenterY(gg_rct_TWG_Catapult_3), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Catapult_3), arthasX - GetRectCenterX(gg_rct_TWG_Catapult_3)) * bj_RADTODEG)
    set catapult4 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04F', GetRectCenterX(gg_rct_TWG_Catapult_4), GetRectCenterY(gg_rct_TWG_Catapult_4), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Catapult_4), arthasX - GetRectCenterX(gg_rct_TWG_Catapult_4)) * bj_RADTODEG)
    set catapult5 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'u04F', GetRectCenterX(gg_rct_TWG_Catapult_5), GetRectCenterY(gg_rct_TWG_Catapult_5), Atan2(arthasY - GetRectCenterY(gg_rct_TWG_Catapult_5), arthasX - GetRectCenterX(gg_rct_TWG_Catapult_5)) * bj_RADTODEG)

    // Alliance blue, Horde red, and Forsaken purple.
    call SetUnitColor(bolvar, ConvertPlayerColor(1))
    call SetUnitColor(saurfang, ConvertPlayerColor(0))
    call SetUnitColor(putress, ConvertPlayerColor(3))
    call SetUnitColor(apothecary1, ConvertPlayerColor(3))
    call SetUnitColor(apothecary2, ConvertPlayerColor(3))
    call SetUnitColor(catapult1, ConvertPlayerColor(3))
    call SetUnitColor(catapult2, ConvertPlayerColor(3))
    call SetUnitColor(catapult3, ConvertPlayerColor(3))
    call SetUnitColor(catapult4, ConvertPlayerColor(3))
    call SetUnitColor(catapult5, ConvertPlayerColor(3))
    call Trig_C_TWG_LockUnit(arthas)
    call Trig_C_TWG_LockUnit(bolvar)
    call Trig_C_TWG_LockUnit(saurfang)
    call Trig_C_TWG_LockUnit(putress)
    call Trig_C_TWG_LockUnit(apothecary1)
    call Trig_C_TWG_LockUnit(apothecary2)
    call Trig_C_TWG_LockUnit(catapult1)
    call Trig_C_TWG_LockUnit(catapult2)
    call Trig_C_TWG_LockUnit(catapult3)
    call Trig_C_TWG_LockUnit(catapult4)
    call Trig_C_TWG_LockUnit(catapult5)
    call ShowUnit(arthas, false)
    call ShowUnit(putress, false)
    call ShowUnit(apothecary1, false)
    call ShowUnit(apothecary2, false)
    call ShowUnit(catapult1, false)
    call ShowUnit(catapult2, false)
    call ShowUnit(catapult3, false)
    call ShowUnit(catapult4, false)
    call ShowUnit(catapult5, false)
    call GroupAddUnit(sceneUnits, arthas)
    call GroupAddUnit(sceneUnits, bolvar)
    call GroupAddUnit(sceneUnits, saurfang)
    call GroupAddUnit(sceneUnits, putress)
    call GroupAddUnit(sceneUnits, apothecary1)
    call GroupAddUnit(sceneUnits, apothecary2)
    call GroupAddUnit(sceneUnits, catapult1)
    call GroupAddUnit(sceneUnits, catapult2)
    call GroupAddUnit(sceneUnits, catapult3)
    call GroupAddUnit(sceneUnits, catapult4)
    call GroupAddUnit(sceneUnits, catapult5)
    call SetHeroLevel(arthas, 60, false)
    call SetHeroLevel(bolvar, 60, false)
    call SetHeroLevel(saurfang, 60, false)

    // Two infantry ranks, one ranged rank, and one caster rank behind each commander.
    call Trig_C_TWG_CreateFormation('hfoo', Player(PLAYER_NEUTRAL_PASSIVE), 1, bolvarX, bolvarY, arthasX, arthasY, sceneUnits, army)
    call Trig_C_TWG_CreateFormation('ogru', Player(PLAYER_NEUTRAL_PASSIVE), 0, saurfangX, saurfangY, arthasX, arthasY, sceneUnits, army)
    call Trig_C_TWG_CreateFormationLine('hrif', Player(PLAYER_NEUTRAL_PASSIVE), 1, bolvarX, bolvarY, arthasX, arthasY, 480.00, sceneUnits, army)
    call Trig_C_TWG_CreateFormationLine('ohun', Player(PLAYER_NEUTRAL_PASSIVE), 0, saurfangX, saurfangY, arthasX, arthasY, 480.00, sceneUnits, army)
    call Trig_C_TWG_CreateFormationLine('hmpr', Player(PLAYER_NEUTRAL_PASSIVE), 1, bolvarX, bolvarY, arthasX, arthasY, 625.00, sceneUnits, army)
    call Trig_C_TWG_CreateFormationLine('oshm', Player(PLAYER_NEUTRAL_PASSIVE), 0, saurfangX, saurfangY, arthasX, arthasY, 625.00, sceneUnits, army)

    // Only Alliance and Horde troops belong to the fallback group.
    call GroupAddGroup(army, fallbackUnits)

    // The positional sound is started only on clients in the completing faction.
    call SetSoundPosition(gg_snd_Wrathgate_Cenamatic, sceneX, sceneY, 0.00)
    call TimerStart(sceneTimer, 300.00, false, null)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call EndThematicMusic()
        call StopMusicBJ(false)
        call StartSound(gg_snd_Wrathgate_Cenamatic)
    endif

    // 0:005
    call Trig_C_TWG_WaitUntil(sceneTimer, 0.50)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call EndThematicMusic()
        call StopMusicBJ(false)
    endif

    // 0:01
    call Trig_C_TWG_WaitUntil(sceneTimer, 1.00)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call EndThematicMusic()
        call StopMusicBJ(false)
    endif

    // 0:02 Bolvar
    call Trig_C_TWG_WaitUntil(sceneTimer, 2.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'H048', "Highlord Bolvar Fordragon", scenePoint, null, " Arthas! The blood of your father, of your people, demands justice! Come forth, coward, and answer for your crimes!", bj_TIMETYPE_SET, 17.00, false)

    // 0:05
    call Trig_C_TWG_WaitUntil(sceneTimer, 5.00)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call EndThematicMusic()
        call StopMusicBJ(false)
    endif

    // 0:10
    call Trig_C_TWG_WaitUntil(sceneTimer, 10.00)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call EndThematicMusic()
        call StopMusicBJ(false)
    endif

    // 0:17 - gate opens.
    call Trig_C_TWG_WaitUntil(sceneTimer, 17.00)
    if gate != null then
        call ModifyGateBJ(bj_GATEOPERATION_OPEN, gate)
    endif

    // 0:19 - Arthas emerges.
    call Trig_C_TWG_WaitUntil(sceneTimer, 19.00)
    call ShowUnit(arthas, true)
    call PauseUnit(arthas, false)
    call IssuePointOrder(arthas, "move", arthasX, arthasY)
    call Trig_C_TWG_WaitUntil(sceneTimer, 23.00)
    call PauseUnit(arthas, true)

    // 0:26 - eighteen undead rise between Arthas and the living armies.
    call Trig_C_TWG_WaitUntil(sceneTimer, 26.00)
    call SetUnitX(arthas, arthasX)
    call SetUnitY(arthas, arthasY)
    call SetUnitFacingTimed(arthas, Atan2(saurfangY - arthasY, saurfangX - arthasX) * bj_RADTODEG, 1.00)
    call Trig_C_TWG_CreateUndead('n059', arthasX, arthasY, 360.00, -65.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('nskg', arthasX, arthasY, 420.00, -39.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('nska', arthasX, arthasY, 480.00, -65.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('uske', arthasX, arthasY, 540.00, -39.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('uskm', arthasX, arthasY, 600.00, -65.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('n06F', arthasX, arthasY, 660.00, -39.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('usog', arthasX, arthasY, 580.00, 144.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    call Trig_C_TWG_CreateUndead('nsoc', arthasX, arthasY, 660.00, 180.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)

    // call Trig_C_TWG_CreateUndead('n059', arthasX, arthasY, 260.00, 0.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('nskg', arthasX, arthasY, 340.00, 36.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('nska', arthasX, arthasY, 420.00, 72.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('uske', arthasX, arthasY, 500.00, 108.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('uskm', arthasX, arthasY, 580.00, 144.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('n06F', arthasX, arthasY, 660.00, 180.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)
    // call Trig_C_TWG_CreateUndead('nska', arthasX, arthasY, 500.00, 216.00, (bolvarX + saurfangX) * 0.50, (bolvarY + saurfangY) * 0.50, sceneUnits, newUndead)

    
    call Trig_C_TWG_WaitUntil(sceneTimer, 28.33)
    call Trig_C_TWG_StandNewUndead(newUndead)

    // Keep the Scourge separate: they die under "Death to the Scourge" and
    // never join the Alliance/Horde fallback.

    // 0:28.5 - Arthas addresses the armies.
    call Trig_C_TWG_WaitUntil(sceneTimer, 28.50)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', "The Lich King", scenePoint, null, "You speak of justice, of cowardice. I will show you the justice of the grave, and the true meaning of fear!", bj_TIMETYPE_SET, 12.50, false)

    // 0:42.5 - Saurfang learns Piercing Taunt, casts it, then charges.
    call Trig_C_TWG_WaitUntil(sceneTimer, 42.50)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'H049', "Dranosh Saurfang", scenePoint, null, "Enough talk! Let it be finished!", bj_TIMETYPE_SET, 6.50, false)
    call SelectHeroSkill(saurfang, 'A014')
    call SetUnitState(saurfang, UNIT_STATE_MANA, GetUnitState(saurfang, UNIT_STATE_MAX_MANA))
    call PauseUnit(saurfang, false)
    call IssueImmediateOrder(saurfang, "howlofterror")

    // 0:44 - Saurfang charges towards Arthas - killing undead along the way
    call Trig_C_TWG_WaitUntil(sceneTimer, 44.00)
    set chargeEffect = AddSpecialEffectTarget("war3mapImported\\Valiant Charge.mdx", saurfang, "origin")
    call IssuePointOrder(saurfang, "move", GetUnitX(arthas) + 120.00, GetUnitY(arthas) - 120.00)
    call Trig_C_TWG_WaitUntil(sceneTimer, 44.60)
    call Trig_C_TWG_KillClosestUndead(saurfang, newUndead)
    call Trig_C_TWG_WaitUntil(sceneTimer, 45.20)
    call Trig_C_TWG_KillClosestUndead(saurfang, newUndead)
    call Trig_C_TWG_WaitUntil(sceneTimer, 45.80)
    call Trig_C_TWG_KillClosestUndead(saurfang, newUndead)

    // 0:46.4 - parry once, 0:47.4 - parry twice, 0:48.4 - Arthas begins the final blow.
    call Trig_C_TWG_WaitUntil(sceneTimer, 46.40)
    call DestroyEffect(chargeEffect)
    set chargeEffect = null
    call PauseUnit(saurfang, true)
    call SetUnitAnimation(saurfang, "attack")
    call SetUnitAnimation(arthas, "attack")
    call Trig_C_TWG_WaitUntil(sceneTimer, 47.40)
    call PauseUnit(saurfang, true)
    call SetUnitAnimation(saurfang, "attack")
    call SetUnitAnimation(arthas, "attack")
    call Trig_C_TWG_WaitUntil(sceneTimer, 48.40)
    call PauseUnit(saurfang, true)
    call SetUnitAnimation(saurfang, "attack")
    call SetUnitAnimation(arthas, "spell throw")
    call Trig_C_TWG_WaitUntil(sceneTimer, 49.00)
    set bloodEffect = AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl", saurfang, "origin")
    call DestroyEffect(bloodEffect)
    call Trig_C_TWG_WaitUntil(sceneTimer, 50.00)
    set bloodEffect = AddSpecialEffect("Objects\\Spawnmodels\\Orc\\Orcblood\\BattrollBlood.mdl", GetUnitX(saurfang), GetUnitY(saurfang))
    call BlzSetSpecialEffectScale(bloodEffect, 1.50)
    call DestroyEffect(bloodEffect)
    set bloodEffect = AddSpecialEffect("Objects\\Spawnmodels\\Orc\\Orcblood\\OrcBloodGrunt.mdl", GetUnitX(saurfang)+10, GetUnitY(saurfang)+10)
    call BlzSetSpecialEffectScale(bloodEffect, 1.50)
    call DestroyEffect(bloodEffect)
    set bloodEffect = null
    call SetUnitInvulnerable(saurfang, false)
    call SetUnitTimeScale(saurfang, 0.60)
    call KillUnit(saurfang)

    // 0:55 - Arthas claims Saurfang's soul.
    call Trig_C_TWG_WaitUntil(sceneTimer, 55.00)
    call SetUnitAnimation(arthas, "spell channel")
    set soulEffect = AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl", GetUnitX(saurfang), GetUnitY(saurfang))
    call BlzSetSpecialEffectScale(soulEffect, 1.35)
    call DestroyEffect(soulEffect)
    set soulEffect = AddSpecialEffect("Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl", GetUnitX(saurfang), GetUnitY(saurfang))
    call BlzSetSpecialEffectScale(soulEffect, 1.35)
    call DestroyEffect(soulEffect)
    set soulEffect = null
    set zigguratMissile1 = AddSpecialEffect("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", GetUnitX(saurfang) + 50.00, GetUnitY(saurfang))
    set zigguratMissile2 = AddSpecialEffect("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", GetUnitX(saurfang) + 50.00 * Cos(120.00 * bj_DEGTORAD), GetUnitY(saurfang) + 50.00 * Sin(120.00 * bj_DEGTORAD))
    set zigguratMissile3 = AddSpecialEffect("Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdl", GetUnitX(saurfang) + 50.00 * Cos(240.00 * bj_DEGTORAD), GetUnitY(saurfang) + 50.00 * Sin(240.00 * bj_DEGTORAD))
    call Trig_C_TWG_WaitUntil(sceneTimer, 56.00)
    call DestroyEffect(zigguratMissile1)
    call DestroyEffect(zigguratMissile2)
    call DestroyEffect(zigguratMissile3)
    set zigguratMissile1 = null
    set zigguratMissile2 = null
    set zigguratMissile3 = null
    call SetUnitAnimation(arthas, "stand")

    // 0:58.5 - Bolvar challenges Arthas.
    call Trig_C_TWG_WaitUntil(sceneTimer, 58.50)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'H048', "Highlord Bolvar Fordragon", scenePoint, null, "You will pay for all the lives you've stolen, traitor!", bj_TIMETYPE_SET, 5.00, false)

    // 1:04 - Arthas begins his reply.
    call Trig_C_TWG_WaitUntil(sceneTimer, 64.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', "The Lich King", scenePoint, null, "Boldly stated. But there is nothing you can...", bj_TIMETYPE_SET, 5.00, false)

    // 1:04 - set up catapult 2 early
    call ShowUnit(catapult2, true)
    call PauseUnit(catapult2, false)
    call SetUnitAcquireRange(catapult2, 0.00)
    call RemoveGuardPosition(catapult2) 
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Initial_Blast), GetRectCenterY(gg_rct_TWG_Catapult_Initial_Blast))

    // 1:06 - plague explosion behind the armies.
    call Trig_C_TWG_WaitUntil(sceneTimer, 66.00)
    call ShowUnit(putress, true)
    call ShowUnit(apothecary1, true)
    call ShowUnit(apothecary2, true)
    call ShowUnit(catapult1, true)
    call ShowUnit(catapult3, true)
    call ShowUnit(catapult4, true)
    call ShowUnit(catapult5, true)
    call PauseUnit(catapult1, false)
    call PauseUnit(catapult3, false)
    call PauseUnit(catapult4, false)
    call PauseUnit(catapult5, false)
    call SetUnitAcquireRange(catapult1, 0.00)
    call SetUnitAcquireRange(catapult3, 0.00)
    call SetUnitAcquireRange(catapult4, 0.00)
    call SetUnitAcquireRange(catapult5, 0.00)
    call RemoveGuardPosition(catapult1)
    call RemoveGuardPosition(catapult3)
    call RemoveGuardPosition(catapult4)
    call RemoveGuardPosition(catapult5)
    call SetUnitAnimation(putress, "spell")

    // 1:08 - the opening plague strike lands directly on the footmen.
    call Trig_C_TWG_WaitUntil(sceneTimer, 68.00)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Initial_Blast), GetRectCenterY(gg_rct_TWG_Catapult_Initial_Blast), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpactOfType(army, 'hfoo', 4, GetRectCenterX(gg_rct_TWG_Catapult_Initial_Blast), GetRectCenterY(gg_rct_TWG_Catapult_Initial_Blast), 325.00, 600.00)

    // 1:11 - Arthas reacts to the plague explosion.
    // Order catapults to stop attacking
    call IssueImmediateOrder(catapult1, "stop")
    call IssueImmediateOrder(catapult2, "stop")
    call IssueImmediateOrder(catapult3, "stop")
    call IssueImmediateOrder(catapult4, "stop")
    call IssueImmediateOrder(catapult5, "stop")
    call Trig_C_TWG_WaitUntil(sceneTimer, 71.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', "The Lich King", scenePoint, null, "What?", bj_TIMETYPE_SET, 1.00, false)

    // 1:12 - Putress reveals himself and laughs.
    call Trig_C_TWG_WaitUntil(sceneTimer, 72.00)
    call SetUnitAnimation(putress, "spell")

    // 1:14 - Putress addresses Arthas.
    call Trig_C_TWG_WaitUntil(sceneTimer, 74.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', "Grand Apothecary Putress", scenePoint, null, "Did you think we had forgotten? Did you think we had forgiven?", bj_TIMETYPE_SET, 9.00, false)

    // 1:21 - the plague catapults pull into view.
    call Trig_C_TWG_WaitUntil(sceneTimer, 81.00)
    call IssuePointOrder(catapult1, "move", GetRectCenterX(gg_rct_TWG_Catapult_1_Move), GetRectCenterY(gg_rct_TWG_Catapult_1_Move))
    call IssuePointOrder(catapult2, "move", GetRectCenterX(gg_rct_TWG_Catapult_2_Move), GetRectCenterY(gg_rct_TWG_Catapult_2_Move))
    call IssuePointOrder(catapult3, "move", GetRectCenterX(gg_rct_TWG_Catapult_3_Move), GetRectCenterY(gg_rct_TWG_Catapult_3_Move))
    call IssuePointOrder(catapult4, "move", GetRectCenterX(gg_rct_TWG_Catapult_4_Move), GetRectCenterY(gg_rct_TWG_Catapult_4_Move))
    call IssuePointOrder(catapult5, "move", GetRectCenterX(gg_rct_TWG_Catapult_5_Move), GetRectCenterY(gg_rct_TWG_Catapult_5_Move))

    // 1:24 - Putress announces the Forsaken's vengeance.
    call Trig_C_TWG_WaitUntil(sceneTimer, 84.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', "Grand Apothecary Putress", scenePoint, null, "Behold now, the terrible vengeance of the Forsaken!", bj_TIMETYPE_SET, 5.50, false)

    // 1:27 - Order to move into position again
    call Trig_C_TWG_WaitUntil(sceneTimer, 87.00)
    call IssuePointOrder(catapult1, "move", GetRectCenterX(gg_rct_TWG_Catapult_1_Move), GetRectCenterY(gg_rct_TWG_Catapult_1_Move))
    call IssuePointOrder(catapult2, "move", GetRectCenterX(gg_rct_TWG_Catapult_2_Move), GetRectCenterY(gg_rct_TWG_Catapult_2_Move))
    call IssuePointOrder(catapult3, "move", GetRectCenterX(gg_rct_TWG_Catapult_3_Move), GetRectCenterY(gg_rct_TWG_Catapult_3_Move))
    call IssuePointOrder(catapult4, "move", GetRectCenterX(gg_rct_TWG_Catapult_4_Move), GetRectCenterY(gg_rct_TWG_Catapult_4_Move))
    call IssuePointOrder(catapult5, "move", GetRectCenterX(gg_rct_TWG_Catapult_5_Move), GetRectCenterY(gg_rct_TWG_Catapult_5_Move))
    // call IssuePointOrder(catapult1, "attackground", scourgeStrike1X, scourgeStrike1Y)
    // call IssuePointOrder(catapult2, "attackground", scourgeStrike2X, scourgeStrike2Y)
    // call IssuePointOrder(catapult3, "attackground", scourgeStrike3X, scourgeStrike3Y)
    // call IssuePointOrder(catapult4, "attackground", scourgeStrike4X, scourgeStrike4Y)

    // 1:28 - Arthas realizes who is behind the attack.
    call Trig_C_TWG_WaitUntil(sceneTimer, 88.00)
    call SetUnitAnimation(arthas, "Stand ready")
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', "The Lich King", scenePoint, null, "Sylvanas...", bj_TIMETYPE_SET, 2.50, false)

    // 1:29 - aim the first mass volley between Arthas and the living armies.
    // Attack-ground remains active, so all four catapults keep firing.
    call Trig_C_TWG_WaitUntil(sceneTimer, 89.00)
    call IssuePointOrder(catapult1, "attackground", scourgeStrike1X, scourgeStrike1Y)
    call IssuePointOrder(catapult2, "attackground", scourgeStrike2X, scourgeStrike2Y)
    call IssuePointOrder(catapult3, "attackground", scourgeStrike3X, scourgeStrike3Y)
    call IssuePointOrder(catapult4, "attackground", scourgeStrike4X, scourgeStrike4Y)
    call IssuePointOrder(catapult5, "attackground", scourgeStrike5X, scourgeStrike5Y)

    // 1:30 - Putress orders death to the Scourge.
    call Trig_C_TWG_WaitUntil(sceneTimer, 90.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', "Grand Apothecary Putress", scenePoint, null, "Death to the Scourge!", bj_TIMETYPE_SET, 2.00, false)

    // 1:31 - the gate-side volley lands on the Scourge.
    call Trig_C_TWG_WaitUntil(sceneTimer, 91.00)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike1X, scourgeStrike1Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike1X, scourgeStrike1Y, 350.00, 600.00, true)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike2X, scourgeStrike2Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike2X, scourgeStrike2Y, 350.00, 600.00, true)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike3X, scourgeStrike3Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike3X, scourgeStrike3Y, 350.00, 600.00, true)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike4X, scourgeStrike4Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike4X, scourgeStrike4Y, 350.00, 600.00, true)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike5X, scourgeStrike5Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike5X, scourgeStrike5Y, 350.00, 600.00, true)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(scourgeStrike6X, scourgeStrike6Y, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(newUndead, scourgeStrike6X, scourgeStrike6Y, 350.00, 600.00, true)


    // Any Scourge outside the four impact radii still succumb before Putress
    // turns the barrage on the living.
    call ForGroup(newUndead, function Trig_C_TWG_KillUnit)

    // 1:34 - the catapults retarget farther across the battlefield.
    call Trig_C_TWG_WaitUntil(sceneTimer, 94.00)
    call IssuePointOrder(catapult1, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1))
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2))
    call IssuePointOrder(catapult3, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3))
    call IssuePointOrder(catapult4, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4))
    call IssuePointOrder(catapult5, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5))

    // 1:35 - and death to the living.
    call Trig_C_TWG_WaitUntil(sceneTimer, 95.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', "Grand Apothecary Putress", scenePoint, null, "And death to the living!", bj_TIMETYPE_SET, 5.00, false)

    // 1:36 - a second mass volley lands farther out among the living armies.
    call Trig_C_TWG_WaitUntil(sceneTimer, 96.00)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1), 425.00, 600.00, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2), 425.00, 600.00, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3), 425.00, 600.00, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4), 425.00, 600.00, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), 425.00, 600.00, false)

    // 1:39 - Bolvar orders the retreat, raises defend, and falls back at 80% speed.
    call Trig_C_TWG_WaitUntil(sceneTimer, 99.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'H048', "Highlord Bolvar Fordragon", scenePoint, null, "FALL BACK!", bj_TIMETYPE_SET, 3.00, false)
    set bolvarRetreatX = GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2)
    set bolvarRetreatY = GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2)
    set bolvarSpeed = GetUnitDefaultMoveSpeed(bolvar) * 0.75
    // Defend slows him further after the speed cut, so straight-line time is too low.
    set bolvarArrival = 102.50 + SquareRoot((bolvarRetreatX - GetUnitX(bolvar)) * (bolvarRetreatX - GetUnitX(bolvar)) + (bolvarRetreatY - GetUnitY(bolvar)) * (bolvarRetreatY - GetUnitY(bolvar))) / bolvarSpeed * 1.50
    call PauseUnit(bolvar, false)
    call SetUnitPathing(bolvar, false)
    call SetUnitAcquireRange(bolvar, 0.00)
    call RemoveGuardPosition(bolvar)
    call IssueImmediateOrder(bolvar, "defend")
    call SetUnitMoveSpeed(bolvar, bolvarSpeed)
    call Trig_C_TWG_WaitUntil(sceneTimer, 100.00)
    call IssuePointOrder(bolvar, "move", bolvarRetreatX, bolvarRetreatY)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(sceneX, sceneY, plagueClouds, plagueCloudCount)

    // Only Alliance and Horde troops turn away, scatter, and die in waves.
    call Trig_C_TWG_ScatterUnits(fallbackUnits, sceneX, sceneY)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult1, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult2, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult3, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult4, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult5, fallbackUnits, plagueClouds, plagueCloudCount)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 102.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 102.00)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult1, fallbackUnits, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillRandomArmy(fallbackUnits, 6)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 104.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 104.00)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult2, fallbackUnits, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillRandomArmy(fallbackUnits, 6)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 106.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 106.00)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult3, fallbackUnits, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillRandomArmy(fallbackUnits, 6)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 108.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 108.00)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult1, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult2, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult3, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult4, fallbackUnits, plagueClouds, plagueCloudCount)
    set plagueCloudCount = Trig_C_TWG_OrderCatapultAtRandomUnit(catapult5, fallbackUnits, plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillRandomArmy(fallbackUnits, 6)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 110.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 110.00)
    call ForGroup(fallbackUnits, function Trig_C_TWG_KillUnit)
    call IssuePointOrder(catapult1, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1))
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2))
    call IssuePointOrder(catapult3, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3))
    call IssuePointOrder(catapult4, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4))
    call IssuePointOrder(catapult5, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5))

    // 1:50 - Arthas retreats through the gate.
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_AGGRESSIVE), 'Uear', "The Lich King", scenePoint, null, "This... isn't... over...", bj_TIMETYPE_SET, 10.00, false)
    call PauseUnit(arthas, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(arthasX, arthasY, plagueClouds, plagueCloudCount)
    call IssuePointOrder(arthas, "move", arthasSpawnX, arthasSpawnY)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 120.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 120.00)
    call ShowUnit(arthas, false)
    call PauseUnit(arthas, true)

    // 2:05 - Putress declares the Forsaken's victory.
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 125.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 125.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'u04E', "Grand Apothecary Putress", scenePoint, null, "Now all can see, this is the hour of the Forsaken!", bj_TIMETYPE_SET, 11.00, false)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(sceneX, sceneY, plagueClouds, plagueCloudCount)
    call IssuePointOrder(catapult1, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult3, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult4, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult5, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150))
    call SetUnitAnimation(putress, "spell")
    call SetUnitAnimation(apothecary1, "spell")
    call SetUnitAnimation(apothecary2, "spell")

    // 2:08 - midway through the line, Putress retreats from the battlefield.
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 128.00, bolvarStopped)
    call Trig_C_TWG_WaitUntil(sceneTimer, 128.00)
    call PauseUnit(putress, false)
    call SetUnitAcquireRange(putress, 0.00)
    call SetUnitMoveSpeed(putress, GetUnitDefaultMoveSpeed(putress) - 160)
    call RemoveGuardPosition(putress)
    call IssuePointOrder(putress, "move", putressRetreatX, putressRetreatY)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), 425.00, 600.00, false)
    call IssuePointOrder(catapult1, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult3, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult4, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult5, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150))
    call SetUnitAnimation(apothecary1, "spell")
    call SetUnitAnimation(apothecary2, "spell")

    // Bolvar begins his 3.03-second death animation.
    // call Trig_C_TWG_WaitUntil(sceneTimer, 129.00)
    set bolvarStopped = Trig_C_TWG_StopBolvarIfDue(bolvar, sceneTimer, bolvarArrival, 128.00, bolvarStopped)
    if not bolvarStopped then
        call IssueImmediateOrder(bolvar, "stop")
        call PauseUnit(bolvar, true)
    endif
    call SetUnitTimeScale(bolvar, 0.75)
    call SetUnitAnimation(bolvar, "death")

    // 2:11 - the second outer-attack shot lands while the apothecaries keep casting.
    call Trig_C_TWG_WaitUntil(sceneTimer, 131.00)
    set plagueCloudCount = Trig_C_TWG_PlagueBurst(GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), plagueClouds, plagueCloudCount)
    call Trig_C_TWG_KillNearPlagueImpact(army, GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5), 425.00, 600.00, false)
    call SetUnitAnimation(apothecary1, "spell")
    call SetUnitAnimation(apothecary2, "spell")
    call Trig_C_TWG_WaitUntil(sceneTimer, 134.00)
    call SetUnitAnimation(apothecary1, "spell")
    call SetUnitAnimation(apothecary2, "spell")

    // Play the two-second dissipate animation at 20% speed.
    call Trig_C_TWG_WaitUntil(sceneTimer, 137.00)
    call SetUnitTimeScale(bolvar, 0.20)
    call SetUnitAnimation(bolvar, "dissipate")
    call SetUnitAnimation(apothecary1, "spell")
    call SetUnitAnimation(apothecary2, "spell")
    
    //remove putress
    call RemoveUnit(putress)

    // 2:15 - spell again retarget catapults
    call SetUnitAnimation(apothecary1, "spell")  
    call SetUnitAnimation(apothecary2, "spell")
    call IssuePointOrder(catapult1, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_1) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult2, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_2) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult3, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_3) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult4, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_4) + GetRandomReal(-150, 150))
    call IssuePointOrder(catapult5, "attackground", GetRectCenterX(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150), GetRectCenterY(gg_rct_TWG_Catapult_Outer_Attack_5) + GetRandomReal(-150, 150))


    // 2:19 - Bolvar realizes there is no escape.
    call Trig_C_TWG_WaitUntil(sceneTimer, 139.00)
    call TransmissionFromUnitTypeWithNameBJ(viewers, Player(PLAYER_NEUTRAL_PASSIVE), 'H048', "Highlord Bolvar Fordragon", scenePoint, null, "We're finished. No escape... for any of us.", bj_TIMETYPE_SET, 7.00, false)
    call Trig_C_TWG_WaitUntil(sceneTimer, 143.10)
    call ShowUnit(bolvar, false)
    call SetUnitInvulnerable(bolvar, false)
    call KillUnit(bolvar)
    call SetUnitAnimation(apothecary1, "stand")
    call SetUnitAnimation(apothecary2, "stand")

    // 2:20 - five red dragons leave Wyrmrest and fly toward Putress.
    call Trig_C_TWG_WaitUntil(sceneTimer, 140.00)
    set dragon1 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nrwm', dragonX - 300.00, dragonY - 75.00, Atan2(putressY - dragonY, putressX - dragonX) * bj_RADTODEG)
    set dragon2 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nrwm', dragonX - 150.00, dragonY + 75.00, Atan2(putressY - dragonY, putressX - dragonX) * bj_RADTODEG)
    set dragon3 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nrwm', dragonX, dragonY, Atan2(putressY - dragonY, putressX - dragonX) * bj_RADTODEG)
    set dragon4 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nrwm', dragonX + 150.00, dragonY - 75.00, Atan2(putressY - dragonY, putressX - dragonX) * bj_RADTODEG)
    set dragon5 = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'nrwm', dragonX + 300.00, dragonY + 75.00, Atan2(putressY - dragonY, putressX - dragonX) * bj_RADTODEG)
    call SetUnitMoveSpeed(dragon1, GetUnitDefaultMoveSpeed(dragon1) - 45)
    call SetUnitMoveSpeed(dragon2, GetUnitDefaultMoveSpeed(dragon2) - 45)
    call SetUnitMoveSpeed(dragon3, GetUnitDefaultMoveSpeed(dragon3) - 45)
    call SetUnitMoveSpeed(dragon4, GetUnitDefaultMoveSpeed(dragon4) - 45)
    call SetUnitMoveSpeed(dragon5, GetUnitDefaultMoveSpeed(dragon5) - 45)
    call SetUnitInvulnerable(dragon1, true)
    call SetUnitInvulnerable(dragon2, true)
    call SetUnitInvulnerable(dragon3, true)
    call SetUnitInvulnerable(dragon4, true)
    call SetUnitInvulnerable(dragon5, true)

    // Neutral flying creeps otherwise may acquire targets or return to a guard point.
    call SetUnitAcquireRange(dragon1, 0.00)
    call SetUnitAcquireRange(dragon2, 0.00)
    call SetUnitAcquireRange(dragon3, 0.00)
    call SetUnitAcquireRange(dragon4, 0.00)
    call SetUnitAcquireRange(dragon5, 0.00)
    call RemoveGuardPosition(dragon1)
    call RemoveGuardPosition(dragon2)
    call RemoveGuardPosition(dragon3)
    call RemoveGuardPosition(dragon4)
    call RemoveGuardPosition(dragon5)
    call GroupAddUnit(sceneUnits, dragon1)
    call GroupAddUnit(sceneUnits, dragon2)
    call GroupAddUnit(sceneUnits, dragon3)
    call GroupAddUnit(sceneUnits, dragon4)
    call GroupAddUnit(sceneUnits, dragon5)
    call Trig_C_TWG_OrderDragonMove(dragon1, putressX - 320.00, putressY - 180.00, 50.00)
    call Trig_C_TWG_OrderDragonMove(dragon2, putressX - 160.00, putressY + 180.00, 50.00)
    call Trig_C_TWG_OrderDragonMove(dragon3, putressX, putressY - 30.00, 50.00)
    call Trig_C_TWG_OrderDragonMove(dragon4, putressX + 160.00, putressY - 180.00, 50.00)
    call Trig_C_TWG_OrderDragonMove(dragon5, putressX + 320.00, putressY + 180.00, 50.00)

    // 2:26 - Bolvar's line ends while the dragons are in flight.
    call Trig_C_TWG_WaitUntil(sceneTimer, 146.00)
    call Trig_C_TWG_OrderDragonMove(dragon1, putressX - 320.00, putressY - 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon2, putressX - 160.00, putressY + 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon3, putressX, putressY - 30.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon4, putressX + 160.00, putressY - 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon5, putressX + 320.00, putressY + 180.00, 150.00)

    // 2:27 - Order dragons to move again
    call Trig_C_TWG_OrderDragonMove(dragon1, putressX - 320.00, putressY - 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon2, putressX - 160.00, putressY + 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon3, putressX, putressY - 30.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon4, putressX + 160.00, putressY - 180.00, 150.00)
    call Trig_C_TWG_OrderDragonMove(dragon5, putressX + 320.00, putressY + 180.00, 150.00)

    // 2:28 - the dragons begin burning the battlefield.
    call Trig_C_TWG_WaitUntil(sceneTimer, 148.00)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)
    // Three dragons break formation and breathe fire at ground targets.
    set dragonAttackTarget1 = Trig_C_TWG_DragonAttackGround(dragon1, sceneX - 350.00, sceneY + 150.00, sceneUnits)
    set dragonAttackTarget2 = Trig_C_TWG_DragonAttackGround(dragon3, sceneX, sceneY - 100.00, sceneUnits)
    set dragonAttackTarget3 = Trig_C_TWG_DragonAttackGround(dragon5, sceneX + 350.00, sceneY + 170.00, sceneUnits)
    call ForGroup(army, function Trig_C_TWG_KillUnit)
    // 2 Dragons peel off about 6 seconds before the first apothecary and catapult die.
    call Trig_C_TWG_DragonStrikeUnit(dragon2, apothecary1)
    call Trig_C_TWG_DragonStrikeUnit(dragon4, catapult1)

    // Reorder dragon strikes 4 seconds before the first apothecary and catapult die.
    call Trig_C_TWG_WaitUntil(sceneTimer, 150.00)
    call Trig_C_TWG_DragonStrikeUnit(dragon2, apothecary1)
    call Trig_C_TWG_DragonStrikeUnit(dragon4, catapult1)

    // The direct breath impacts leave larger fires while the periodic cleansing
    // passes continue burning plague patches across the battlefield.
    call Trig_C_TWG_WaitUntil(sceneTimer, 154.00)
    set dragonFireCount = Trig_C_TWG_AddDragonFire(sceneX - 350.00, sceneY + 150.00, 1.35, dragonFires, dragonFireCount)
    call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, sceneX - 350.00, sceneY + 150.00, 300.00)
    set dragonFireCount = Trig_C_TWG_AddDragonFire(sceneX, sceneY - 100.00, 1.35, dragonFires, dragonFireCount)
    call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, sceneX, sceneY - 100.00, 300.00)
    set dragonFireCount = Trig_C_TWG_AddDragonFire(sceneX + 350.00, sceneY + 170.00, 1.35, dragonFires, dragonFireCount)
    call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, sceneX + 350.00, sceneY + 170.00, 300.00)
    call GroupRemoveUnit(sceneUnits, dragonAttackTarget1)
    call GroupRemoveUnit(sceneUnits, dragonAttackTarget2)
    call GroupRemoveUnit(sceneUnits, dragonAttackTarget3)
    call RemoveUnit(dragonAttackTarget1)
    call RemoveUnit(dragonAttackTarget2)
    call RemoveUnit(dragonAttackTarget3)
    set dragonAttackTarget1 = null
    set dragonAttackTarget2 = null
    set dragonAttackTarget3 = null
    call KillUnit(apothecary1)
    call KillUnit(catapult1)
    call Trig_C_TWG_OrderDragonMove(dragon1, putressX - 320.00, putressY - 180.00, 90.00)
    call Trig_C_TWG_OrderDragonMove(dragon2, putressX - 160.00, putressY + 180.00, 90.00)
    call Trig_C_TWG_OrderDragonMove(dragon3, putressX, putressY - 30.00, 90.00)
    call Trig_C_TWG_OrderDragonMove(dragon5, putressX + 320.00, putressY + 180.00, 90.00)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)

    // Dragon 2 and Dragon 4 peel off about 4 seconds before the second apothecary and catapult die.
    call Trig_C_TWG_DragonStrikeUnit(dragon2, apothecary2)
    call Trig_C_TWG_DragonStrikeUnit(dragon4, catapult2)
    call Trig_C_TWG_WaitUntil(sceneTimer, 158.00)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)
    call KillUnit(apothecary2)
    call KillUnit(catapult2)
    call Trig_C_TWG_OrderDragonMove(dragon4, putressX + 160.00, putressY - 180.00, 90.00)

    // Two different dragons pause for a second fire pass.
    set dragonAttackTarget1 = Trig_C_TWG_DragonAttackGround(dragon2, sceneX - 180.00, sceneY - 260.00, sceneUnits)
    set dragonAttackTarget2 = Trig_C_TWG_DragonAttackGround(dragon3, sceneX + 220.00, sceneY + 260.00, sceneUnits)

    // Dragon 1 peels off about 4 seconds before the third catapult dies.
    call Trig_C_TWG_DragonStrikeUnit(dragon1, catapult3)
    call Trig_C_TWG_WaitUntil(sceneTimer, 162.00)
    set dragonFireCount = Trig_C_TWG_AddDragonFire(sceneX - 180.00, sceneY - 260.00, 1.35, dragonFires, dragonFireCount)
    call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, sceneX - 180.00, sceneY - 260.00, 300.00)
    set dragonFireCount = Trig_C_TWG_AddDragonFire(sceneX + 220.00, sceneY + 260.00, 1.35, dragonFires, dragonFireCount)
    call Trig_C_TWG_ClearPlagueNearPoint(plagueClouds, plagueCloudCount, sceneX + 220.00, sceneY + 260.00, 300.00)
    call GroupRemoveUnit(sceneUnits, dragonAttackTarget1)
    call GroupRemoveUnit(sceneUnits, dragonAttackTarget2)
    call RemoveUnit(dragonAttackTarget1)
    call RemoveUnit(dragonAttackTarget2)
    set dragonAttackTarget1 = null
    set dragonAttackTarget2 = null
    call KillUnit(catapult3)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)

    // Dragon 5 peels off about 4 seconds before catapult 4 dies.
    call Trig_C_TWG_DragonStrikeUnit(dragon5, catapult4)

    // Dragon 3 peels off about 4 seconds before the fifth catapult dies.
    call Trig_C_TWG_DragonStrikeUnit(dragon3, catapult5)

    // Order the dragons to head back to Wyrmrest. Dragons 3 and 5 stay on the catapults.
    call Trig_C_TWG_WaitUntil(sceneTimer, 164.00)
    call Trig_C_TWG_OrderDragonMove(dragon1, dragonX - 320.00, dragonY - 180.00, 60.00)
    call Trig_C_TWG_OrderDragonMove(dragon2, dragonX - 160.00, dragonY + 180.00, 60.00)
    call Trig_C_TWG_OrderDragonMove(dragon4, dragonX + 160.00, dragonY - 180.00, 60.00)
    call Trig_C_TWG_WaitUntil(sceneTimer, 166.00)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)
    call KillUnit(catapult4)
    call KillUnit(catapult5)
    call Trig_C_TWG_OrderDragonMove(dragon3, dragonX, dragonY, 60.00)
    call Trig_C_TWG_OrderDragonMove(dragon5, dragonX + 320.00, dragonY + 180.00, 60.00)
    call Trig_C_TWG_WaitUntil(sceneTimer, 170.00)
    set dragonFireCount = Trig_C_TWG_DragonFire(plagueClouds, plagueCloudCount, dragonFires, dragonFireCount)

    // 2:53 - audio has faded; restore the area for the next showing.
    call Trig_C_TWG_WaitUntil(sceneTimer, 173.00)
    if IsPlayerInForce(GetLocalPlayer(), viewers) then
        call StopSound(gg_snd_Wrathgate_Cenamatic, false, false)
        call ResumeMusicBJ()
    endif
    if gate != null then
        call ModifyGateBJ(bj_GATEOPERATION_CLOSE, gate)
    endif
    call Trig_C_TWG_ClearPlagueClouds(plagueClouds, plagueCloudCount)
    call Trig_C_TWG_ClearDragonFires(dragonFires, dragonFireCount)
    call FlushParentHashtable(plagueClouds)
    call FlushParentHashtable(dragonFires)
    call ForGroup(sceneUnits, function Trig_C_TWG_RemoveUnit)
    call Trig_C_TWG_DestroyFog(fog1)
    call Trig_C_TWG_DestroyFog(fog2)
    call Trig_C_TWG_DestroyFog(fog3)
    call Trig_C_TWG_DestroyFog(fog4)
    call DestroyGroup(newUndead)
    call DestroyGroup(fallbackUnits)
    call DestroyGroup(army)
    call DestroyGroup(sceneUnits)
    call DestroyForce(viewers)
    call RemoveLocation(scenePoint)
    call DestroyTimer(sceneTimer)
    call EnableTrigger(gg_trg_C_TWG)
    set viewers = null
    set sceneUnits = null
    set army = null
    set fallbackUnits = null
    set newUndead = null
    set plagueClouds = null
    set dragonFires = null
    set gate = null
    set scenePoint = null
    set fog1 = null
    set fog2 = null
    set fog3 = null
    set fog4 = null
    set arthas = null
    set bolvar = null
    set saurfang = null
    set putress = null
    set apothecary1 = null
    set apothecary2 = null
    set catapult1 = null
    set catapult2 = null
    set catapult3 = null
    set catapult4 = null
    set catapult5 = null
    set dragon1 = null
    set dragon2 = null
    set dragon3 = null
    set dragon4 = null
    set dragon5 = null
    set dragonAttackTarget1 = null
    set dragonAttackTarget2 = null
    set dragonAttackTarget3 = null
    set soulEffect = null
    set bloodEffect = null
    set chargeEffect = null
    set zigguratMissile1 = null
    set zigguratMissile2 = null
    set zigguratMissile3 = null
    set sceneTimer = null
endfunction

//===========================================================================
function InitTrig_C_TWG takes nothing returns nothing
    set gg_trg_C_TWG = CreateTrigger()
    call TriggerAddAction(gg_trg_C_TWG, function Trig_C_TWG_Actions)
endfunction
