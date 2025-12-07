// Dumps the current udg_SaveItemType mapping to CustomMapData\ItemMap.txt
function DumpItemMapToFile takes nothing returns nothing
    local integer i = 1
    local integer id
    local item temp_item
    local integer max = udg_SaveItemTypeMax // or use your actual last-used index

    call PreloadGenClear()
    call Preload("// === Item map dump ===")
    call Preload("// Generated in-game. Paste into an init function to freeze mapping.")
    call Preload("")

    loop
        exitwhen i > max
        set id = udg_SaveItemType[i]
        if id != 0 then
            // Comment with the editor name for readability
            call Preload(GetObjectName(id))
            // Assignment with rawcode literal
            set temp_item = CreateItem(id, - 16358.0, - 8802.9)
            call Preload("Tooltip:" + BlzGetItemExtendedTooltip(temp_item))
            call RemoveItem(temp_item)
            call Preload("") // blank line
        endif
        set i = i + 1
    endloop

    set temp_item = null

    call PreloadGenEnd(udg_MapName + "\\" + "ItemMap.txt") // writes to Warcraft III\CustomMapData\ItemMap.txt
endfunction

// Run this once after your region-scan has filled udg_SaveItemType[]
function Trig_Dump_Map_File_Actions takes nothing returns nothing
    // -------------------
    // Store item types that can be saved here
    // -------------------
    // At this point, your existing logic has already set udg_SaveItemType[...] and udg_SaveItemTypeMax
    set udg_SaveItemTypeMax = 999 // keep whatever cap you use

    // Dump the mapping for copy/paste hardcoding
    call DumpItemMapToFile()

    // (Optional) also keep your current SaveFile line if you want
    // call SaveFile(1).create(GetLocalPlayer(), "items", null, 1, 1, udg_SaveCodeString)
endfunction

function InitTrig_Dump_Map_File takes nothing returns nothing
    set gg_trg_Dump_Map_File = CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_Dump_Map_File, 2.00) // ensure arrays are populated
    call TriggerAddAction(gg_trg_Dump_Map_File, function Trig_Dump_Map_File_Actions)
endfunction