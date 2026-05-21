globals
    // Probe item used instead of native 'ankh'. Swap this to a dedicated
    // custom soulstone rawcode once you add one in the object editor.
    // 'I06M' = Chalice of Holy Regeneration (permanent epic, not Charged,
    // not Powerup, not auto-consumed on pickup).
    constant integer CREATE_SOULSTONE_ITEM_ID = 'I06M'
    timer CreateSoulStoneAddTimer = CreateTimer()
    integer CreateSoulStoneAddCount = 0
    unit array CreateSoulStoneAddCaster
    item array CreateSoulStoneAddItem

    // Deferred-execution queue for the entire success branch.
    // The SPELL_CAST handler validates inline; if valid, the side-effecting
    // half is captured here and run by a 0.0s timer, decoupling all
    // CreateItem/RemoveItem/TasItemBagAddItem/RequestUIUpdate work from the
    // SPELL_CAST event frame itself. This is to isolate / eliminate any
    // desyncs that might come from mutating inventory inside the spell event.
    timer CreateSoulStoneDeferTimer = CreateTimer()
    integer CreateSoulStoneDeferCount = 0
    unit array CreateSoulStoneDeferCaster
    player array CreateSoulStoneDeferPlayer
    integer array CreateSoulStoneDeferPlayerKey
    integer array CreateSoulStoneDeferChargesLeft
    item array CreateSoulStoneDeferShard
    item array CreateSoulStoneDeferOldSS
endglobals

function CreateSoulStoneFinishAdd takes nothing returns nothing
    local integer i = 1
    local unit caster
    local item soulStone

    loop
        exitwhen i > CreateSoulStoneAddCount
        set caster = CreateSoulStoneAddCaster[i]
        set soulStone = CreateSoulStoneAddItem[i]

        if caster != null and soulStone != null and GetItemTypeId(soulStone) != 0 then
            set udg_dontDepositIntoBag = true
            call UnitAddItem(caster, soulStone)
            set udg_dontDepositIntoBag = false
            if not UnitHasItem(caster, soulStone) and GetItemTypeId(soulStone) != 0 then
                call TasItemBagAddItem(caster, soulStone, false)
            endif
        endif

        set CreateSoulStoneAddCaster[i] = null
        set CreateSoulStoneAddItem[i] = null
        set i = i + 1
    endloop

    set CreateSoulStoneAddCount = 0
    set caster = null
    set soulStone = null
endfunction

function CreateSoulStoneQueueAdd takes unit caster, item soulStone returns nothing
    if caster == null or soulStone == null or GetItemTypeId(soulStone) == 0 then
        return
    endif

    set CreateSoulStoneAddCount = CreateSoulStoneAddCount + 1
    set CreateSoulStoneAddCaster[CreateSoulStoneAddCount] = caster
    set CreateSoulStoneAddItem[CreateSoulStoneAddCount] = soulStone
    call TimerStart(CreateSoulStoneAddTimer, 0.01, false, function CreateSoulStoneFinishAdd)

    set caster = null
    set soulStone = null
endfunction

function CreateSoulStoneFindStorageSlot takes integer bagArrayBase, item searchedItem returns integer
    local integer storageSlot = 1
    if searchedItem == null then
        return 0
    endif
    loop
        exitwhen storageSlot > 36
        if udg_P_Items[bagArrayBase + storageSlot] == searchedItem then
            return storageSlot
        endif
        set storageSlot = storageSlot + 1
    endloop
    return 0
endfunction

function CreateSoulStoneCountEmptyExtraSlots takes integer bagArrayBase returns integer
    local integer storageSlot = 13
    local integer emptySlots = 0
    loop
        exitwhen storageSlot > 36
        if udg_P_Items[bagArrayBase + storageSlot] == null then
            set emptySlots = emptySlots + 1
        endif
        set storageSlot = storageSlot + 1
    endloop
    return emptySlots
endfunction

function CreateSoulStoneHasStorageForSpend takes integer bagArrayBase, item shard, item oldSoulStone, integer chargesLeft returns boolean
    local integer availableSlots = CreateSoulStoneCountEmptyExtraSlots(bagArrayBase)
    local integer shardSlot = CreateSoulStoneFindStorageSlot(bagArrayBase, shard)
    local integer oldSoulStoneSlot = CreateSoulStoneFindStorageSlot(bagArrayBase, oldSoulStone)
    local integer requiredSlots = 1

    if chargesLeft > 0 then
        set requiredSlots = requiredSlots + 1
    endif
    if shardSlot > 12 then
        set availableSlots = availableSlots + 1
    endif
    if oldSoulStoneSlot > 12 and oldSoulStoneSlot != shardSlot then
        set availableSlots = availableSlots + 1
    endif

    return availableSlots >= requiredSlots
endfunction

function CreateSoulStoneRemoveTrackedShard takes integer bagArrayBase, item shard returns nothing
    local integer storageSlot = CreateSoulStoneFindStorageSlot(bagArrayBase, shard)
    if storageSlot > 0 then
        set udg_P_Items[bagArrayBase + storageSlot] = null
    endif
    call RemoveItem(shard)
endfunction

// Runs the side-effecting half of Create Soulstone for every entry that was
// queued during this game tick. Fires off a 0.0s timer so all the
// CreateItem/RemoveItem/TasItemBag work happens OUTSIDE the SPELL_CAST event
// frame. Debug("SS:...") instrumentation prints to all players when udg_Debug
// is on; comparing the last line each client saw isolates the divergence
// point if a desync still occurs.
function CreateSoulStoneRunDeferred takes nothing returns nothing
    local integer i = 1
    local unit caster
    local player p
    local integer playerKey
    local integer chargesLeft
    local item shard
    local item oldSoulStone
    local item remainderShard
    local item newSoulStone

    loop
        exitwhen i > CreateSoulStoneDeferCount
        set caster = CreateSoulStoneDeferCaster[i]
        set p = CreateSoulStoneDeferPlayer[i]
        set playerKey = CreateSoulStoneDeferPlayerKey[i]
        set chargesLeft = CreateSoulStoneDeferChargesLeft[i]
        set shard = CreateSoulStoneDeferShard[i]
        set oldSoulStone = CreateSoulStoneDeferOldSS[i]
        set remainderShard = null
        set newSoulStone = null

        call DebugLog("SS:01 deferred run entry=" + I2S(i) + " playerKey=" + I2S(playerKey) + " chargesLeft=" + I2S(chargesLeft) + " shard=" + I2S(GetHandleId(shard)) + " oldSS=" + I2S(GetHandleId(oldSoulStone)))

        if caster != null and shard != null and GetItemTypeId(shard) != 0 then
            call CreateSoulStoneRemoveTrackedShard(playerKey, shard)
            call DebugLog("SS:02 after RemoveTrackedShard")

            if chargesLeft > 0 then
                call DebugLog("SS:03 creating remainder shard")
                set remainderShard = CreateItem('I08E', GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
                call DebugLog("SS:04 remainder id=" + I2S(GetHandleId(remainderShard)))
                if remainderShard != null then
                    call SetItemCharges(remainderShard, chargesLeft)
                    call DebugLog("SS:05 before TasItemBagAddItem(remainder)")
                    call TasItemBagAddItem(caster, remainderShard, false)
                    call DebugLog("SS:06 after TasItemBagAddItem(remainder)")
                endif
            endif

            call DebugLog("SS:07 before AddSpecialEffect")
            call AddSpecialEffectTargetUnitBJ("overhead", caster, "war3mapImported\\Void Disc.mdx")
            call DestroyEffectBJ(GetLastCreatedEffectBJ())
            call DebugLog("SS:08 after DestroyEffect")

            if oldSoulStone != null and GetItemTypeId(oldSoulStone) != 0 then
                call DebugLog("SS:09 removing old soulstone id=" + I2S(GetHandleId(oldSoulStone)))
                if not TasItemBagRemoveItem(caster, oldSoulStone, false) and UnitHasItem(caster, oldSoulStone) then
                    call DebugLog("SS:09a UnitRemoveItem fallback")
                    call UnitRemoveItem(caster, oldSoulStone)
                endif
                call RemoveItem(oldSoulStone)
                call DebugLog("SS:10 after RemoveItem(oldSoulStone)")
            endif

            call DebugLog("SS:11 creating probe soulstone item rawcode=" + I2S(CREATE_SOULSTONE_ITEM_ID))
            set newSoulStone = CreateItem(CREATE_SOULSTONE_ITEM_ID, GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
            call DebugLog("SS:12 probe soulstone id=" + I2S(GetHandleId(newSoulStone)))
            if newSoulStone != null then
                call DebugLog("SS:13 before TasItemBagAddItem(probeSoulstone)")
                call TasItemBagAddItem(caster, newSoulStone, false)
                call DebugLog("SS:14 after TasItemBagAddItem(probeSoulstone)")
            endif

            if caster == udg_yA_Demon_Warlock then
                set udg_yA_DEMO_SS = newSoulStone
            elseif caster == udg_yH_Demon_Warlock then
                set udg_yH_DEMO_SS = newSoulStone
            endif
            call DebugLog("SS:15 after global SS assignment")

            call CreateTextTagUnitBJ("Soulstone probe item created", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0)
            call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
            call cleanUpText(1.25, 0.75)
            call DebugLog("SS:16 success branch complete")
        endif

        set CreateSoulStoneDeferCaster[i] = null
        set CreateSoulStoneDeferPlayer[i] = null
        set CreateSoulStoneDeferShard[i] = null
        set CreateSoulStoneDeferOldSS[i] = null
        set i = i + 1
    endloop

    set CreateSoulStoneDeferCount = 0
    set caster = null
    set p = null
    set shard = null
    set oldSoulStone = null
    set remainderShard = null
    set newSoulStone = null
endfunction

function CreateSoulStoneEnqueueDeferred takes unit caster, player p, integer playerKey, integer chargesLeft, item shard, item oldSoulStone returns nothing
    set CreateSoulStoneDeferCount = CreateSoulStoneDeferCount + 1
    set CreateSoulStoneDeferCaster[CreateSoulStoneDeferCount] = caster
    set CreateSoulStoneDeferPlayer[CreateSoulStoneDeferCount] = p
    set CreateSoulStoneDeferPlayerKey[CreateSoulStoneDeferCount] = playerKey
    set CreateSoulStoneDeferChargesLeft[CreateSoulStoneDeferCount] = chargesLeft
    set CreateSoulStoneDeferShard[CreateSoulStoneDeferCount] = shard
    set CreateSoulStoneDeferOldSS[CreateSoulStoneDeferCount] = oldSoulStone
    call TimerStart(CreateSoulStoneDeferTimer, 0.00, false, function CreateSoulStoneRunDeferred)
endfunction

function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A039'
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer reqCharges = 10
    local integer abilityLevel = GetUnitAbilityLevelSwapped('A039', GetTriggerUnit())
    local integer playerKey
    local integer slot = 1
    local integer chargesLeft = 0
    local integer manaRefund
    local unit caster = GetTriggerUnit()
    local player p = GetOwningPlayer(caster)
    local item shard = null
    local item oldSoulStone = null

    if udg_TalentChoices[GetPlayerId(p) * udg_NUM_OF_TC + 10] then
        set reqCharges = 6
    endif

    call SetBagNumber(p)
    set playerKey = udg_Bag_Num

    // Find one soul shard stack anywhere in this player's storage with enough charges.
    loop
        exitwhen slot > 36
        set shard = udg_P_Items[playerKey + slot]
        if shard != null and GetItemTypeId(shard) == 'I08E' and GetItemCharges(shard) >= reqCharges then
            exitwhen true
        endif
        set shard = null
        set slot = slot + 1
    endloop

    if caster == udg_yA_Demon_Warlock then
        set oldSoulStone = udg_yA_DEMO_SS
    elseif caster == udg_yH_Demon_Warlock then
        set oldSoulStone = udg_yH_DEMO_SS
    endif

    if shard != null then
        set chargesLeft = GetItemCharges(shard) - reqCharges
    endif

    if shard == null then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Not enough Soul Shards.", p)
    elseif not CreateSoulStoneHasStorageForSpend(playerKey, shard, oldSoulStone, chargesLeft) then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Bag is full.", p)
    else
        // Defer the entire success branch to a 0.0s timer so all
        // CreateItem/RemoveItem/TasItemBagAddItem work runs OUTSIDE the
        // SPELL_CAST event frame. shard / oldSoulStone are captured by handle
        // and consumed in the deferred function.
        call DebugLog("SS:00 enqueue deferred playerKey=" + I2S(playerKey) + " shardSlot=" + I2S(slot) + " chargesLeft=" + I2S(chargesLeft) + " shard=" + I2S(GetHandleId(shard)) + " oldSS=" + I2S(GetHandleId(oldSoulStone)))
        call CreateSoulStoneEnqueueDeferred(caster, p, playerKey, chargesLeft, shard, oldSoulStone)
        set shard = null
        set oldSoulStone = null
    endif

    set oldSoulStone = null
    set shard = null
    set p = null
    set caster = null
endfunction

//===========================================================================
function InitTrig_Create_Soul_Stone takes nothing returns nothing
    set gg_trg_Create_Soul_Stone = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Create_Soul_Stone, EVENT_PLAYER_UNIT_SPELL_CAST )
    call TriggerAddCondition( gg_trg_Create_Soul_Stone, Condition( function Trig_Create_Soul_Stone_Conditions ) )
    call TriggerAddAction( gg_trg_Create_Soul_Stone, function Trig_Create_Soul_Stone_Actions )
endfunction

