globals
    // Temporary non-ankh soulstone item. Swap this to the dedicated custom
    // soulstone rawcode once it exists in the object editor.
    constant integer CREATE_SOULSTONE_ITEM_ID = 'I06M'
endglobals

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

function CreateSoulStoneHasNativeSlotForNew takes unit caster, item shard, item oldSoulStone returns boolean
    local integer slot = 0
    local item slotItem
    if caster == null then
        return false
    endif
    loop
        exitwhen slot >= UnitInventorySize(caster)
        set slotItem = UnitItemInSlot(caster, slot)
        if slotItem == null or slotItem == shard or slotItem == oldSoulStone then
            set slotItem = null
            set caster = null
            set shard = null
            set oldSoulStone = null
            return true
        endif
        set slot = slot + 1
    endloop
    set slotItem = null
    set caster = null
    set shard = null
    set oldSoulStone = null
    return false
endfunction

function CreateSoulStoneHasStorageForSpend takes unit caster, integer bagArrayBase, item shard, item oldSoulStone, integer chargesLeft returns boolean
    local integer availableSlots = CreateSoulStoneCountEmptyExtraSlots(bagArrayBase)
    local integer shardSlot = CreateSoulStoneFindStorageSlot(bagArrayBase, shard)
    local integer oldSoulStoneSlot = CreateSoulStoneFindStorageSlot(bagArrayBase, oldSoulStone)
    local integer requiredSlots = 0

    if chargesLeft > 0 then
        set requiredSlots = requiredSlots + 1
    endif
    if not CreateSoulStoneHasNativeSlotForNew(caster, shard, oldSoulStone) then
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

function CreateSoulStoneStoreNew takes unit caster, item soulStone returns nothing
    local boolean added = false
    if caster != null and soulStone != null and GetItemTypeId(soulStone) != 0 then
        set udg_dontDepositIntoBag = true
        set added = UnitAddItem(caster, soulStone)
        set udg_dontDepositIntoBag = false

        if not added and GetItemTypeId(soulStone) != 0 then
            call TasItemBagAddItem(caster, soulStone, false)
        endif
    endif

    set caster = null
    set soulStone = null
endfunction

function CreateSoulStoneSpendAndCreate takes unit caster, integer playerKey, integer chargesLeft, item shard, item oldSoulStone returns nothing
    local item remainderShard = null
    local item newSoulStone = null

    if caster != null and shard != null and GetItemTypeId(shard) != 0 then
        call CreateSoulStoneRemoveTrackedShard(playerKey, shard)

        if chargesLeft > 0 then
            set remainderShard = CreateItem('I08E', GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
            if remainderShard != null then
                call SetItemCharges(remainderShard, chargesLeft)
                call TasItemBagAddItem(caster, remainderShard, false)
            endif
        endif

        call AddSpecialEffectTargetUnitBJ("overhead", caster, "war3mapImported\\Void Disc.mdx")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())

        if oldSoulStone != null and GetItemTypeId(oldSoulStone) != 0 then
            if not TasItemBagRemoveItem(caster, oldSoulStone, false) and UnitHasItem(caster, oldSoulStone) then
                call UnitRemoveItem(caster, oldSoulStone)
            endif
            call RemoveItem(oldSoulStone)
        endif

        set newSoulStone = CreateItem(CREATE_SOULSTONE_ITEM_ID, GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
        if newSoulStone != null then
            call CreateSoulStoneStoreNew(caster, newSoulStone)
        endif

        if caster == udg_yA_Demon_Warlock then
            set udg_yA_DEMO_SS = newSoulStone
        elseif caster == udg_yH_Demon_Warlock then
            set udg_yH_DEMO_SS = newSoulStone
        endif

        call CreateTextTagUnitBJ("Soulstone created", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0)
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
        call cleanUpText(1.25, 0.75)
    endif

    set remainderShard = null
    set newSoulStone = null
    set caster = null
    set shard = null
    set oldSoulStone = null
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
    elseif not CreateSoulStoneHasStorageForSpend(caster, playerKey, shard, oldSoulStone, chargesLeft) then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Bag is full.", p)
    else
        call CreateSoulStoneSpendAndCreate(caster, playerKey, chargesLeft, shard, oldSoulStone)
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

