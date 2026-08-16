function Create_Gandling_Barrier takes nothing returns nothing
    local real x1 = GetRectCenterX(gg_rct_Scholomance_Gandling_Lightning_E)
    local real y1 = GetRectCenterY(gg_rct_Scholomance_Gandling_Lightning_E)
    local real x2 = GetRectCenterX(gg_rct_Scholomance_Gandling_Lightning_W)
    local real y2 = GetRectCenterY(gg_rct_Scholomance_Gandling_Lightning_W)
    local location loc1 = Location(x1, y1)
    local location loc2 = Location(x2, y2)
    local real z1 = GetLocationZ(loc1) + 100.00
    local real z2 = GetLocationZ(loc2) + 100.00

    set udg_Scholomance_Lightning1 = AddLightningEx("DRAL", false, x1, y1, z1, x2, y2, z2)
    set udg_Scholomance_Lightning2 = AddLightningEx("MYSB", false, x1, y1, z1, x2, y2, z2)
    
    call RemoveLocation(loc1)
    call RemoveLocation(loc2)

    set x1 = GetRectCenterX(gg_rct_Scholomance_Gandling_Lightning_NE)
    set y1 = GetRectCenterY(gg_rct_Scholomance_Gandling_Lightning_NE)
    set x2 = GetRectCenterX(gg_rct_Scholomance_Gandling_Lightning_NW)
    set y2 = GetRectCenterY(gg_rct_Scholomance_Gandling_Lightning_NW)
    set loc1 = Location(x1, y1)
    set loc2 = Location(x2, y2)
    set z1 = GetLocationZ(loc1) + 100.00
    set z2 = GetLocationZ(loc2) + 100.00

    set udg_Scholomance_Lightning3 = AddLightningEx("DRAL", false, x1, y1, z1, x2, y2, z2)
    set udg_Scholomance_Lightning4 = AddLightningEx("MYSB", false, x1, y1, z1, x2, y2, z2)

    call RemoveLocation(loc1)
    call RemoveLocation(loc2)

    call PauseAddInvuln(gg_unit_U01S_1754, null)

    set loc1 = null
    set loc2 = null
endfunction