globals
    constant integer CREATE_SOULSTONE_SHARD_MAX_CHARGES = 20
    constant integer CREATE_SOULSTONE_PAGE_SLOTS = 6
    constant integer CREATE_SOULSTONE_EXTRA_FIRST_SLOT = 13
    constant integer CREATE_SOULSTONE_STORAGE_LAST_SLOT = 36
endglobals

function CreateSoulStoneItemId takes integer spellLevel returns integer
    if spellLevel == 1 then
        return 'I0AL'
    elseif spellLevel == 2 then
        return 'I0AM'
    elseif spellLevel == 3 then
        return 'I0AN'
    elseif spellLevel == 4 then
        return 'I0AO'
    endif
    return 'I0AP'
endfunction

function CreateSoulStoneOtherPage takes player p returns integer
    if udg_Bag_Page[GetPlayerNumber(p)] == 1 then
        return 2
    endif
    return 1
endfunction

function CreateSoulStoneSlotOpensForNew takes item slotItem, item shard, item oldSoulStone, item mergeShard, boolean removeShard, boolean removeMergeShard returns boolean
    return slotItem == null or slotItem == oldSoulStone or (removeShard and slotItem == shard) or (removeMergeShard and slotItem == mergeShard)
endfunction

function CreateSoulStoneFindMergeShard takes integer playerKey, item shard returns item
    local integer slot = 1
    local item mergeShard = null

    loop
        exitwhen slot > CREATE_SOULSTONE_STORAGE_LAST_SLOT
        set mergeShard = udg_P_Items[playerKey + slot]
        if mergeShard != null and mergeShard != shard and GetItemTypeId(mergeShard) == 'I08E' then
            return mergeShard
        endif
        set mergeShard = null
        set slot = slot + 1
    endloop

    return null
endfunction

function CreateSoulStoneWillRemoveMergeShard takes item shard, item mergeShard, integer reqCharges returns boolean
    local integer chargesLeft
    local integer mergeSpace
    if shard == null or mergeShard == null or GetItemTypeId(shard) == 0 or GetItemTypeId(mergeShard) == 0 then
        return false
    endif

    set chargesLeft = GetItemCharges(shard) - reqCharges
    set mergeSpace = CREATE_SOULSTONE_SHARD_MAX_CHARGES - chargesLeft
    return chargesLeft > 0 and mergeSpace > 0 and GetItemCharges(mergeShard) > 0 and GetItemCharges(mergeShard) <= mergeSpace
endfunction

function CreateSoulStoneHasNativeSlotAfterSpend takes unit caster, item shard, item oldSoulStone, item mergeShard, boolean removeShard, boolean removeMergeShard returns boolean
    local integer slot = 0
    local item slotItem = null

    if caster == null then
        return false
    endif

    loop
        exitwhen slot >= UnitInventorySize(caster)
        set slotItem = UnitItemInSlot(caster, slot)
        if CreateSoulStoneSlotOpensForNew(slotItem, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) then
            set slotItem = null
            return true
        endif
        set slot = slot + 1
    endloop

    set slotItem = null
    return false
endfunction

function CreateSoulStoneCountPageSlotsAfterSpend takes player p, integer page, item shard, item oldSoulStone, item mergeShard, boolean removeShard, boolean removeMergeShard returns integer
    local integer slot = 1
    local integer openSlots = 0
    local item slotItem = null

    loop
        exitwhen slot > CREATE_SOULSTONE_PAGE_SLOTS
        set slotItem = udg_P_Items[GetPItemsIndex(p, page, slot)]
        if CreateSoulStoneSlotOpensForNew(slotItem, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) then
            set openSlots = openSlots + 1
        endif
        set slot = slot + 1
    endloop

    set slotItem = null
    return openSlots
endfunction

function CreateSoulStoneFindPageSlotAfterSpend takes player p, integer page, item shard, item oldSoulStone, item mergeShard, boolean removeShard, boolean removeMergeShard, boolean preserveLastOpen returns integer
    local integer slot = 1
    local item slotItem = null

    if preserveLastOpen and CreateSoulStoneCountPageSlotsAfterSpend(p, page, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) <= 1 then
        return 0
    endif

    loop
        exitwhen slot > CREATE_SOULSTONE_PAGE_SLOTS
        set slotItem = udg_P_Items[GetPItemsIndex(p, page, slot)]
        if CreateSoulStoneSlotOpensForNew(slotItem, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) then
            set slotItem = null
            return slot
        endif
        set slot = slot + 1
    endloop

    set slotItem = null
    return 0
endfunction

function CreateSoulStoneFindExtraSlotAfterSpend takes integer playerKey, item shard, item oldSoulStone, item mergeShard, boolean removeShard, boolean removeMergeShard returns integer
    local integer slot = CREATE_SOULSTONE_EXTRA_FIRST_SLOT
    local item slotItem = null

    loop
        exitwhen slot > CREATE_SOULSTONE_STORAGE_LAST_SLOT
        set slotItem = udg_P_Items[playerKey + slot]
        if CreateSoulStoneSlotOpensForNew(slotItem, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) then
            set slotItem = null
            return slot
        endif
        set slot = slot + 1
    endloop

    set slotItem = null
    return 0
endfunction

// Storage priority: current active page first, alternate page while preserving
// its last open slot, extra bag, then the alternate page's last slot as fallback.
function CreateSoulStoneHasStorageForNew takes unit caster, player p, integer playerKey, item shard, item oldSoulStone, integer reqCharges returns boolean
    local integer chargesLeft = GetItemCharges(shard) - reqCharges
    local integer otherPage = CreateSoulStoneOtherPage(p)
    local integer extraSlot = 0
    local item mergeShard = null
    local boolean removeShard = chargesLeft <= 0
    local boolean removeMergeShard = false

    if not removeShard then
        set mergeShard = CreateSoulStoneFindMergeShard(playerKey, shard)
        set removeMergeShard = CreateSoulStoneWillRemoveMergeShard(shard, mergeShard, reqCharges)
    endif

    if CreateSoulStoneHasNativeSlotAfterSpend(caster, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard) then
        set mergeShard = null
        return true
    endif

    set extraSlot = CreateSoulStoneFindExtraSlotAfterSpend(playerKey, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard)

    if CreateSoulStoneFindPageSlotAfterSpend(p, otherPage, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard, true) > 0 then
        set mergeShard = null
        return true
    endif

    if extraSlot > 0 then
        set mergeShard = null
        return true
    endif

    if CreateSoulStoneFindPageSlotAfterSpend(p, otherPage, shard, oldSoulStone, mergeShard, removeShard, removeMergeShard, false) > 0 then
        set mergeShard = null
        return true
    endif

    set mergeShard = null
    return false
endfunction

function CreateSoulStoneRemoveItem takes unit caster, item whichItem returns nothing
    if whichItem != null and GetItemTypeId(whichItem) != 0 then
        if not TasItemBagRemoveItem(caster, whichItem, false) and UnitHasItem(caster, whichItem) then
            call UnitRemoveItem(caster, whichItem)
        endif
        call RemoveItem(whichItem)
    endif

    set caster = null
    set whichItem = null
endfunction

function CreateSoulStoneMergeLeftoverShard takes unit caster, integer playerKey, item shard, integer chargesLeft returns nothing
    local integer slot = 1
    local integer mergeSpace
    local integer mergeCharges
    local integer movedCharges
    local item mergeShard = null

    loop
        exitwhen slot > CREATE_SOULSTONE_STORAGE_LAST_SLOT or shard == null
        set mergeShard = udg_P_Items[playerKey + slot]
        if mergeShard != null and mergeShard != shard and GetItemTypeId(mergeShard) == 'I08E' then
            set mergeSpace = CREATE_SOULSTONE_SHARD_MAX_CHARGES - chargesLeft
            if mergeSpace > 0 then
                set mergeCharges = GetItemCharges(mergeShard)
                if mergeCharges > 0 then
                    if mergeCharges > mergeSpace then
                        set movedCharges = mergeSpace
                    else
                        set movedCharges = mergeCharges
                    endif
                    call SetItemCharges(shard, chargesLeft + movedCharges)
                    set chargesLeft = chargesLeft + movedCharges
                    set mergeCharges = mergeCharges - movedCharges
                    if mergeCharges <= 0 then
                        call CreateSoulStoneRemoveItem(caster, mergeShard)
                    else
                        call SetItemCharges(mergeShard, mergeCharges)
                    endif
                endif
            endif
            exitwhen true
        endif
        set mergeShard = null
        set slot = slot + 1
    endloop

    set mergeShard = null
    set caster = null
    set shard = null
endfunction

function CreateSoulStoneSpendShard takes unit caster, integer playerKey, item shard, integer reqCharges returns nothing
    local integer chargesLeft

    if shard != null and GetItemTypeId(shard) != 0 then
        call SetItemCharges(shard, GetItemCharges(shard) - reqCharges)
        set chargesLeft = GetItemCharges(shard)

        if chargesLeft <= 0 then
            call CreateSoulStoneRemoveItem(caster, shard)
        else
            call CreateSoulStoneMergeLeftoverShard(caster, playerKey, shard, chargesLeft)
        endif
    endif

    set caster = null
    set shard = null
endfunction

function CreateSoulStoneFindPageEmptySlot takes player p, integer page, boolean preserveLastOpen returns integer
    local integer slot = 1
    local integer firstOpen = 0
    local integer openSlots = 0

    loop
        exitwhen slot > CREATE_SOULSTONE_PAGE_SLOTS
        if udg_P_Items[GetPItemsIndex(p, page, slot)] == null then
            set openSlots = openSlots + 1
            if firstOpen == 0 then
                set firstOpen = slot
            endif
        endif
        set slot = slot + 1
    endloop

    if preserveLastOpen and openSlots <= 1 then
        return 0
    endif
    return firstOpen
endfunction

function CreateSoulStoneFindExtraEmptySlot takes integer playerKey returns integer
    local integer slot = CREATE_SOULSTONE_EXTRA_FIRST_SLOT

    loop
        exitwhen slot > CREATE_SOULSTONE_STORAGE_LAST_SLOT
        if udg_P_Items[playerKey + slot] == null then
            return slot
        endif
        set slot = slot + 1
    endloop

    return 0
endfunction

function CreateSoulStoneStoreAtIndex takes integer arrIndex, item soulStone returns nothing
    local location itemIsland

    if soulStone == null or GetItemTypeId(soulStone) == 0 then
        return
    endif

    set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
    call SetItemPositionLoc(soulStone, itemIsland)
    call SetItemUserData(soulStone, 1)
    call RemoveLocation(itemIsland)
    set udg_P_Items[arrIndex] = soulStone

    set itemIsland = null
    set soulStone = null
endfunction

// Mirrors CreateSoulStoneHasStorageForNew after shard/old-soulstone removal.
function CreateSoulStoneStoreNew takes unit caster, player p, integer playerKey, item soulStone returns nothing
    local boolean added = false
    local boolean prevDontDeposit = false
    local boolean prevSuppress = false
    local integer otherPage
    local integer pageSlot
    local integer extraSlot

    if caster != null and p != null and soulStone != null and GetItemTypeId(soulStone) != 0 then
        set prevDontDeposit = udg_dontDepositIntoBag
        set prevSuppress = AcquireAndLoseItemHandler_PageRebuildSuppress
        set udg_dontDepositIntoBag = true
        set AcquireAndLoseItemHandler_PageRebuildSuppress = true
        set added = UnitAddItem(caster, soulStone)
        set AcquireAndLoseItemHandler_PageRebuildSuppress = prevSuppress
        set udg_dontDepositIntoBag = prevDontDeposit

        if added and UnitHasItem(caster, soulStone) then
            call AcquireItemHandler(caster, soulStone)
        endif

        if not added and GetItemTypeId(soulStone) != 0 then
            set otherPage = CreateSoulStoneOtherPage(p)
            set pageSlot = CreateSoulStoneFindPageEmptySlot(p, otherPage, true)
            if pageSlot > 0 then
                call CreateSoulStoneStoreAtIndex(GetPItemsIndex(p, otherPage, pageSlot), soulStone)
            else
                set extraSlot = CreateSoulStoneFindExtraEmptySlot(playerKey)
                if extraSlot > 0 then
                    call CreateSoulStoneStoreAtIndex(playerKey + extraSlot, soulStone)
                else
                    set pageSlot = CreateSoulStoneFindPageEmptySlot(p, otherPage, false)
                    if pageSlot > 0 then
                        call CreateSoulStoneStoreAtIndex(GetPItemsIndex(p, otherPage, pageSlot), soulStone)
                    else
                        call TasItemBagAddItem(caster, soulStone, false)
                    endif
                endif
            endif
        endif
    endif

    set p = null
    set caster = null
    set soulStone = null
endfunction

function CreateSoulStoneConfigureItem takes item soulStone, integer abilityLevel returns nothing
    local integer soulstonePower = abilityLevel * 2
    local integer reviveLife = 300 + (150 * soulstonePower)
    local string tooltipText = ""

    if soulStone != null and GetItemTypeId(soulStone) != 0 then
        set tooltipText = "+" + I2S(soulstonePower) + " Strength " + I2S(soulstonePower) + " Agility " + I2S(soulstonePower) + " Intelligence|n|n+|cc00FFFFF" + I2S(soulstonePower) + "% Cooldown Reduction|r"
        set tooltipText = tooltipText + "|n|n|c00CC44FFNon-Stacking Passive:|r  Automatically brings the Hero back to life with " + I2S(reviveLife) + " hit points when the Hero dies. |n|n|cff808080Soulstone must be in one of the two inventory pages to take effect and does not persist between save and load.|r"
        call BlzSetItemDescription(soulStone, tooltipText)
        call BlzSetItemExtendedTooltip(soulStone, tooltipText)
    endif

    set tooltipText = null
    set soulStone = null
endfunction

function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A039'
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer reqCharges = 10
    local integer abilityLevel = GetUnitAbilityLevelSwapped('A039', GetTriggerUnit())
    local integer playerKey
    local integer slot = 1
    local integer manaRefund
    local unit caster = GetTriggerUnit()
    local player p = GetOwningPlayer(caster)
    local item shard = null
    local item oldSoulStone = null
    local item newSoulStone = null

    if udg_TalentChoices[GetPlayerId(p) * udg_NUM_OF_TC + 10] then
        set reqCharges = 6
    endif

    call SetBagNumber(p)
    set playerKey = udg_Bag_Num

    // Find one soul shard stack anywhere in this player's storage with enough charges.
    loop
        exitwhen slot > CREATE_SOULSTONE_STORAGE_LAST_SLOT
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

    if shard == null then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Not enough Soul Shards.", p)
    elseif not CreateSoulStoneHasStorageForNew(caster, p, playerKey, shard, oldSoulStone, reqCharges) then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Bag is full.", p)
    else
        call CreateSoulStoneSpendShard(caster, playerKey, shard, reqCharges)

        call AddSpecialEffectTargetUnitBJ("overhead", caster, "war3mapImported\\Void Disc.mdx")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())

        call CreateSoulStoneRemoveItem(caster, oldSoulStone)

        set newSoulStone = CreateItem(CreateSoulStoneItemId(abilityLevel), GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
        if newSoulStone != null then
            call CreateSoulStoneConfigureItem(newSoulStone, abilityLevel)
            call CreateSoulStoneStoreNew(caster, p, playerKey, newSoulStone)
        endif

        if caster == udg_yA_Demon_Warlock then
            set udg_yA_DEMO_SS = newSoulStone
        elseif caster == udg_yH_Demon_Warlock then
            set udg_yH_DEMO_SS = newSoulStone
        endif

        call CreateTextTagUnitBJ("Soulstone Created!", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0)
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
        call SetTextTagLifespan(GetLastCreatedTextTag(), 1.25)
        call cleanUpText(1.25, 0.75)

        call TasItemBag_RequestUIUpdate()
    endif

    set oldSoulStone = null
    set newSoulStone = null
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

