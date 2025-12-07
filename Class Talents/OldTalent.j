loop
    set level = TalentUnitGetSelectionLevel(uId, selectionsDone)
    set tier = TalentHeroGetTier(heroTypeId, level)
    set spellNr = TalentUnitGetSelectionButtonUsed(uId, selectionsDone)
    set choice = TalentTierGetChoice(tier, spellNr)
    
    set udg_Talent__Choice = choice
    set udg_Talent__Tier = tier
    set udg_Talent__Level = level
    set udg_Talent__Button = spellNr
    
    static if LIBRARY_TalentTasStats then
        call TalentTasStatsRemove(u, choice)
    endif

    if TalentThrowEventReset then	//Throw a event that this choice is going to be lost.
        set udg_Talent__Event = 0
        set udg_Talent__Event = -1
        set udg_Talent__Event = 0
    endif
    
    
    set loopB = TalentChoiceGetAbilityCount(choice)
    loop	//Load all saved Abilities and remove/decrease them for the unit
        exitwhen loopB == 0
        set skillGained = LoadInteger(udg_TalentHash, choice, loopB)
        set skillReplaced = LoadInteger(udg_TalentHash, choice, -loopB)
        
        if skillReplaced != 0 then //Replaces?
            if BlzGetUnitAbilityCooldownRemaining( u, skillGained ) > 0  and not isReroll then
                call ErrorMessage( "Abilities must be off cooldown before being unlearned", GetOwningPlayer(u) )
                return
            else 
                //Delay this  1
                call TalentReplaceSkill(u, skillGained, skillReplaced)
            endif
        else
            if BlzGetUnitAbilityCooldownRemaining( u, skillGained ) > 0 and not isReroll then 
                call ErrorMessage( "Abilities must be off cooldown before being unlearned", GetOwningPlayer(u) )
                return
            else
                //Delay this 2
                call TalentRemoveSkill(u, skillGained)
            endif
        endif
        set loopB = loopB - 1
    endloop
    
    //Delay This  3
    call TriggerExecute(udg_TalentChoiceOnReset[choice])

    //Choice, gained, replaced all Integers
    //Just make a queue with options 1,2,3 and next 4 blocks = skillGained/Replaced/choice/(extra future use?), then loop through until option 0, call each based on 1/2/3
    //local array integer prevSelections

    set selectionsDone = selectionsDone - 1
    set amountOfResets = amountOfResets - 1
    exitwhen selectionsDone <= 0 or amountOfResets <= 0
endloop