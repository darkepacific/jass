globals
    timer CreateSoulStoneAddTimer = CreateTimer()
    integer CreateSoulStoneAddCount = 0
    unit array CreateSoulStoneAddCaster
    item array CreateSoulStoneAddItem
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

function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A039'
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer reqCharges = 10
    local integer abilityLevel = GetUnitAbilityLevelSwapped('A039', GetTriggerUnit())
    local integer playerKey
    local integer slot = 1
    local integer chargesLeft
    local integer manaRefund
    local integer reviveLife
    local unit caster = GetTriggerUnit()
    local player p = GetOwningPlayer(caster)
    local item shard = null
    local item remainderShard = null
    local item oldSoulStone = null
    local item newSoulStone = null
    local string tooltipText

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
        call CreateSoulStoneRemoveTrackedShard(playerKey, shard)
        set shard = null

        if chargesLeft > 0 then
            set remainderShard = CreateItem('I08E', GetUnitX(caster), GetUnitY(caster))
            if remainderShard != null then
                call SetItemCharges(remainderShard, chargesLeft)
                call TasItemBagAddItem(caster, remainderShard, false)
            endif
            set remainderShard = null
        endif

        call AddSpecialEffectTargetUnitBJ("overhead", caster, "war3mapImported\\Void Disc.mdx")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())

        if oldSoulStone != null then
            if not TasItemBagRemoveItem(caster, oldSoulStone, false) and UnitHasItem(caster, oldSoulStone) then
                call UnitRemoveItem(caster, oldSoulStone)
            endif
            call RemoveItem(oldSoulStone)
        endif

        set newSoulStone = CreateItem('ankh', GetUnitX(caster), GetUnitY(caster))
        if newSoulStone != null then
            //     set abilityLevel = abilityLevel * 2
            //     if abilityLevel == 2 then
            //         call BlzItemAddAbilityBJ(newSoulStone, 'AIrc')
            //         call BlzItemAddAbilityBJ(newSoulStone, 'AIx2')
            //     elseif abilityLevel == 4 then
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DP')
            //         call BlzItemAddAbilityBJ(newSoulStone, 'AIx4')
            //     elseif abilityLevel == 6 then
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DQ')
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0CO')
            //     elseif abilityLevel == 8 then
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DR')
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DU')
            //     elseif abilityLevel == 10 then
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DT')
            //         call BlzItemAddAbilityBJ(newSoulStone, 'A0DV')
            //     endif

            // set reviveLife = 300 + (150 * abilityLevel)
            // set tooltipText = "+" + I2S(abilityLevel) + " Strength " + I2S(abilityLevel) + " Agility " + I2S(abilityLevel) + " Intelligence|n|n+|cc00FFFFF" + I2S(abilityLevel) + "% Cooldown Reduction|r"
            // set tooltipText = tooltipText + "|n|n|c00CC44FFNon-Stacking Passive:|r  Automatically brings the Hero back to life with " + I2S(reviveLife) + " hit points when the Hero dies."
            // call BlzSetItemDescription(newSoulStone, tooltipText)
            // call BlzSetItemExtendedTooltip(newSoulStone, tooltipText)

            // call CreateSoulStoneQueueAdd(caster, newSoulStone)
            call TasItemBagAddItem(caster, newSoulStone, false)
        endif

        if caster == udg_yA_Demon_Warlock then
            set udg_yA_DEMO_SS = newSoulStone
        elseif caster == udg_yH_Demon_Warlock then
            set udg_yH_DEMO_SS = newSoulStone
        endif

        call CreateTextTagUnitBJ("Soulstone Created!", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0)
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
        call cleanUpText(1.25, 0.75)

        // call TasItemBag_RequestUIUpdate()
    endif

    set tooltipText = null
    set oldSoulStone = null
    set newSoulStone = null
    set remainderShard = null
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

