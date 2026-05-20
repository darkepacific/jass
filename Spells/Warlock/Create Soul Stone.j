function CreateSoulStoneRemoveTrackedItem takes unit caster, item whichItem returns nothing
    if whichItem == null then
        return
    endif

    if not TasItemBagRemoveItem(caster, whichItem, false) and UnitHasItem(caster, whichItem) then
        call UnitRemoveItem(caster, whichItem)
    endif
    call RemoveItem(whichItem)

    set whichItem = null
    set caster = null
endfunction

function Trig_Create_Soul_Stone_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A039' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Create_Soul_Stone_Actions takes nothing returns nothing
    local integer reqCharges = 10
    local integer abilityLevel = GetUnitAbilityLevelSwapped('A039', GetTriggerUnit())
    local integer playerKey
    local integer slot = 1
    local integer chargesLeft
    local integer mergeSpace
    local integer mergeCharges
    local integer movedCharges
    local integer manaRefund
    local integer reviveLife
    local unit caster = GetTriggerUnit()
    local player p = GetOwningPlayer(caster)
    local item shard = null
    local item mergeShard = null
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

    if shard == null then
        set manaRefund = BlzGetAbilityManaCost('A039', abilityLevel - 1)
        call IssueImmediateOrderBJ(caster, "stop")
        call SetUnitManaBJ(caster, GetUnitStateSwap(UNIT_STATE_MANA, caster) + I2R(manaRefund))
        call ErrorMessage("Not enough Soul Shards.", p)
    else
        call SetItemCharges(shard, GetItemCharges(shard) - reqCharges)
        set chargesLeft = GetItemCharges(shard)

        if chargesLeft <= 0 then
            call CreateSoulStoneRemoveTrackedItem(caster, shard)
            set shard = null
        else
            // Merge the leftover stack into one other shard stack once.
            set slot = 1
            loop
                exitwhen slot > 36 or shard == null
                set mergeShard = udg_P_Items[playerKey + slot]
                if mergeShard != null and mergeShard != shard and GetItemTypeId(mergeShard) == 'I08E' then
                    set mergeSpace = 20 - chargesLeft
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
                                call CreateSoulStoneRemoveTrackedItem(caster, mergeShard)
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
        endif

        call AddSpecialEffectTargetUnitBJ("overhead", caster, "war3mapImported\\Void Disc.mdx")
        call DestroyEffectBJ(GetLastCreatedEffectBJ())

        if caster == udg_yA_Demon_Warlock then
            set oldSoulStone = udg_yA_DEMO_SS
        elseif caster == udg_yH_Demon_Warlock then
            set oldSoulStone = udg_yH_DEMO_SS
        endif

        if oldSoulStone != null then
            call CreateSoulStoneRemoveTrackedItem(caster, oldSoulStone)
        endif

        set newSoulStone = CreateItem('ankh', GetUnitX(caster), GetUnitY(caster))

        if caster == udg_yA_Demon_Warlock then
            set udg_yA_DEMO_SS = newSoulStone
        elseif caster == udg_yH_Demon_Warlock then
            set udg_yH_DEMO_SS = newSoulStone
        endif

        set abilityLevel = abilityLevel * 2
        if newSoulStone != null then
            if abilityLevel == 2 then
                call BlzItemAddAbilityBJ(newSoulStone, 'AIrc')
                call BlzItemAddAbilityBJ(newSoulStone, 'AIx2')
            elseif abilityLevel == 4 then
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DP')
                call BlzItemAddAbilityBJ(newSoulStone, 'AIx4')
            elseif abilityLevel == 6 then
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DQ')
                call BlzItemAddAbilityBJ(newSoulStone, 'A0CO')
            elseif abilityLevel == 8 then
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DR')
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DU')
            elseif abilityLevel == 10 then
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DT')
                call BlzItemAddAbilityBJ(newSoulStone, 'A0DV')
            endif

            set reviveLife = 300 + (150 * abilityLevel)
            set tooltipText = "+" + I2S(abilityLevel) + " Strength " + I2S(abilityLevel) + " Agility " + I2S(abilityLevel) + " Intelligence|n|n+|cc00FFFFF" + I2S(abilityLevel) + "% Cooldown Reduction|r"
            set tooltipText = tooltipText + "|n|n|c00CC44FFNon-Stacking Passive:|r  Automatically brings the Hero back to life with " + I2S(reviveLife) + " hit points when the Hero dies. |n|n|cff808080Soulstone must be in active inventory to take effect and does not persist between save and load.|r"
            call BlzSetItemDescription(newSoulStone, tooltipText)
            call BlzSetItemExtendedTooltip(newSoulStone, tooltipText)

            set udg_dontDepositIntoBag = true
            call UnitAddItem(caster, newSoulStone)
            set udg_dontDepositIntoBag = false
            if not UnitHasItem(caster, newSoulStone) then
                if GetItemTypeId(newSoulStone) != 0 then
                    call TasItemBagAddItem(caster, newSoulStone, false)
                endif
            endif

            call CreateTextTagUnitBJ("Soulstone Created!", caster, 0.00, 9.00, 80.00, 40.00, 100.00, 0)
            call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
            call SetTextTagLifespan(GetLastCreatedTextTag(), 1.25)
            call cleanUpText(1.25, 0.75)
        endif
    endif

    set tooltipText = null
    set oldSoulStone = null
    set newSoulStone = null
    set mergeShard = null
    set shard = null
    set p = null
    set caster = null
endfunction

//===========================================================================
function InitTrig_Create_Soul_Stone takes nothing returns nothing
    set gg_trg_Create_Soul_Stone = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Create_Soul_Stone, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Create_Soul_Stone, Condition( function Trig_Create_Soul_Stone_Conditions ) )
    call TriggerAddAction( gg_trg_Create_Soul_Stone, function Trig_Create_Soul_Stone_Actions )
endfunction

