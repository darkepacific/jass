function Trig_Unit_Indexer_Func009Func005Func005C takes nothing returns boolean
    if ( not ( GetUnitUserData(udg_UDexUnits[udg_UDex]) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Unit_Indexer_Func009Func005C takes nothing returns boolean
    if ( not ( udg_UDexWasted == 32 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Unit_Indexer_Func009C takes nothing returns boolean
    if ( not ( udg_IsUnitPreplaced[0] == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Unit_Indexer_Func019Func004C takes nothing returns boolean
    if ( not ( udg_UDexRecycle == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Unit_Indexer_Func019C takes nothing returns boolean
    if ( not ( udg_UnitIndexerEnabled == true ) ) then
        return false
    endif
    if ( not ( GetUnitUserData(GetFilterUnit()) == 0 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Unit_Indexer_Actions takes nothing returns nothing
        call ExecuteFunc("InitializeUnitIndexer")
    endfunction
    //  
    // This is the core function - it provides an index all existing units and for units as they enter the map
    //  
    function IndexUnit takes nothing returns boolean
        local integer pdex = udg_UDex
        local integer ndex
    if ( Trig_Unit_Indexer_Func009C() ) then
        //  
        // Check for removed units for every (32) new units created
        //  
        set udg_UDexWasted = ( udg_UDexWasted + 1 )
        if ( Trig_Unit_Indexer_Func009Func005C() ) then
            set udg_UDexWasted = 0
            set udg_UDex = udg_UDexNext[0]
            loop
                exitwhen udg_UDex == 0
            if ( Trig_Unit_Indexer_Func009Func005Func005C() ) then
                //  
                // Remove index from linked list
                //  
                set ndex = udg_UDexNext[udg_UDex]
                set udg_UDexNext[udg_UDexPrev[udg_UDex]] = ndex
                set udg_UDexPrev[ndex] = udg_UDexPrev[udg_UDex]
                set udg_UDexPrev[udg_UDex] = 0
                set udg_IsUnitPreplaced[udg_UDex] = false
                //  
                // Fire deindex event for UDex
                //  
                set udg_UnitIndexEvent = 2.00
                set udg_UnitIndexEvent = 0.00
                //  
                // Recycle the index for later use
                //  
                set udg_UDexUnits[udg_UDex] = null
                set udg_UDexNext[udg_UDex] = udg_UDexRecycle
                set udg_UDexRecycle = udg_UDex
                set udg_UDex = ndex
            else
                set udg_UDex = udg_UDexNext[udg_UDex]
            endif
            endloop
        else
        endif
    else
    endif
    //  
    // You can use the boolean UnitIndexerEnabled to protect some of your undesirable units from being indexed
    // - Example:
    // -- Set UnitIndexerEnabled = False
    // -- Unit - Create 1 Dummy for (Triggering player) at TempLoc facing 0.00 degrees
    // -- Set UnitIndexerEnabled = True
    //  
    // You can also customize the following block - if conditions are false the (Matching unit) won't be indexed.
    //  
    if ( Trig_Unit_Indexer_Func019C() ) then
        //  
        // Generate a unique integer index for this unit
        //  
        if ( Trig_Unit_Indexer_Func019Func004C() ) then
            set udg_UDex = ( udg_UDexGen + 1 )
            set udg_UDexGen = udg_UDex
        else
            set udg_UDex = udg_UDexRecycle
            set udg_UDexRecycle = udg_UDexNext[udg_UDex]
        endif
        //  
        // Link index to unit, unit to index
        //  
        set udg_UDexUnits[udg_UDex] = GetFilterUnit()
        call SetUnitUserData( udg_UDexUnits[udg_UDex], udg_UDex )
        set udg_IsUnitPreplaced[udg_UDex] = udg_IsUnitPreplaced[0]
        //  
        // Use a doubly-linked list to store all active indexes
        //  
        set udg_UDexPrev[udg_UDexNext[0]] = udg_UDex
        set udg_UDexNext[udg_UDex] = udg_UDexNext[0]
        set udg_UDexNext[0] = udg_UDex
        //  
        // Fire index event for UDex
        //  
        set udg_UnitIndexEvent = 0.00
        set udg_UnitIndexEvent = 1.00
        set udg_UnitIndexEvent = 0.00
    else
    endif
        set udg_UDex = pdex
        return false
    endfunction
    //  
    // The next function initializes the core of the system
    //  
    function InitializeUnitIndexer takes nothing returns nothing
        local integer i = 0
        local region re = CreateRegion()
        local rect r = GetWorldBounds()
        local boolexpr b = Filter(function IndexUnit)
    set udg_UnitIndexEvent = -1.00
    set udg_UnitIndexerEnabled = true
    set udg_IsUnitPreplaced[0] = true
        call RegionAddRect(re, r)
        call TriggerRegisterEnterRegion(CreateTrigger(), re, b)
        call RemoveRect(r)
        set re = null
        set r = null
        loop
            call GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), b)
            set i = i + 1
            exitwhen i == bj_MAX_PLAYER_SLOTS
        endloop
        set b = null
    //  
    // This is the "Unit Indexer Initialized" event, use it instead of "Map Initialization" for best results
    //  
    set udg_IsUnitPreplaced[0] = false
    set udg_UnitIndexEvent = 3.00
endfunction

//===========================================================================
function InitTrig_Unit_Indexer takes nothing returns nothing
    set gg_trg_Unit_Indexer = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Unit_Indexer, function Trig_Unit_Indexer_Actions )
endfunction

