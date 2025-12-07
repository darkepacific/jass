// Utility functions for working with spell unit ranges using udg_SpellUnits
// This library provides functions to manage spell unit slots for heroes.
library SpellUnits

    globals
        unit spellUnit = null
        unit spellCaster = null
    endglobals

    //==========================
    //  Utility functions
    //==========================

    // Debug function to print the contents of the spell unit slots
    function SpellUnits_Debug takes integer heroOffset, integer startSlot, integer endSlot returns nothing
        local integer i = startSlot
        local unit u
        if udg_Debug == false then
            return
        endif
        call Debug("Spell Units Debug: slot: " + I2S(heroOffset) + ", start: " + I2S(startSlot) + ", end: " + I2S(endSlot))
        loop
            exitwhen i > endSlot
            set u = udg_SpellUnits[heroOffset + i]
            if u != null then
                call Debug("Slot " + I2S(i) + ": " + GetUnitName(u))
            else
                call Debug("Slot " + I2S(i) + ": empty")
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // Checks if a unit is already in the spell unit slots
    function SpellUnits_Contains takes unit u, integer heroOffset, integer startSlot, integer endSlot returns boolean
        local integer i = startSlot
        loop
            exitwhen i > endSlot
            if udg_SpellUnits[heroOffset + i] == u then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    // Counts how many non-null units are in the spell unit slots
    function SpellUnits_Count takes integer heroOffset, integer startSlot, integer endSlot returns integer
        local integer i = startSlot
        local integer count = 0
        loop
            exitwhen i > endSlot
            if udg_SpellUnits[heroOffset + i] != null then
                set count = count + 1
            endif
            set i = i + 1
        endloop
        return count
    endfunction
    
    //==========================
    //  Data Modification functions
    //==========================

    // Adds a unit to the spell unit slots
    function SpellUnits_Add takes unit u, integer heroOffset, integer startSlot, integer endSlot returns nothing
        local integer i = startSlot
        if SpellUnits_Contains(u, heroOffset, startSlot, endSlot) then
            call Debug("Unit " + GetUnitName(u) + " already in slot " + I2S(i))
            return
        endif
        loop
            exitwhen i > endSlot
            if udg_SpellUnits[heroOffset + i] == null then      
                set udg_SpellUnits[heroOffset + i] = u
                call Debug("Added " + GetUnitName(u) + " to slot " + I2S(i))
                return
            endif
            set i = i + 1
        endloop
        // Overwrite first slot if full and a hero
        if IsUnitType(u, UNIT_TYPE_HERO) then
            set udg_SpellUnits[heroOffset + startSlot] = u
            call Debug("Overwrote " + GetUnitName(u) + " to slot " + I2S(startSlot))
        endif
    endfunction

    // Removes a specific unit from the spell unit slots
    function SpellUnits_Remove takes unit u, integer heroOffset, integer startSlot, integer endSlot returns nothing
        local integer i = startSlot
        loop
            exitwhen i > endSlot
            if udg_SpellUnits[heroOffset + i] == u then
                set udg_SpellUnits[heroOffset + i] = null
                call Debug("Removed " + GetUnitName(u) + " from slot " + I2S(i))
                return
            endif
            set i = i + 1
        endloop
    endfunction

    // Cleans any units without the given buff from the spell unit slots
    function SpellUnits_CleanMissingBuff takes integer heroOffset, integer startSlot, integer endSlot, integer buffId returns nothing
        local integer i = startSlot
        local unit u
        loop
            exitwhen i > endSlot
            set u = udg_SpellUnits[heroOffset + i]
            if u != null and not UnitHasBuffBJ(u, buffId) then
                set udg_SpellUnits[heroOffset + i] = null
                call Debug("Cleaned " + GetUnitName(u) + " from slot " + I2S(i))
            endif
            set i = i + 1
        endloop
        set u = null
    endfunction

    // Applies a user-defined function to each unit in the range
    // Requires user to set udg_Temp_Unit inside the callback if needed
    function SpellUnits_ForEach takes unit hero, integer heroOffset, integer startSlot, integer endSlot, code callback returns nothing
        local integer i = startSlot
        local unit u
        local trigger t = CreateTrigger()
        
        call TriggerAddAction(t, callback)
        
        set spellCaster = hero
        
        loop
            exitwhen i > endSlot
            set u = udg_SpellUnits[heroOffset + i]
            if u != null then
                set spellUnit = u
                call TriggerExecute(t) // safely calls the code block
            endif
            set i = i + 1
        endloop
        
        call DestroyTrigger(t)
        set t = null
        set u = null
    endfunction

    // Clears all units from the spell unit slots
    function SpellUnits_Clear takes integer heroOffset, integer startSlot, integer endSlot returns nothing
        local integer i = startSlot
        loop
            exitwhen i > endSlot
            set udg_SpellUnits[heroOffset + i] = null
            set i = i + 1
        endloop
    endfunction

endlibrary