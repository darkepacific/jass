library SaveFile requires FileIO, GenericFunctions

    globals
        // 0 = unknown, 1 = offline, 2 = online
        integer udg_OfflineModeState = 0
    endglobals

    function IsOfflineGame takes nothing returns boolean
        local boolean before
        local boolean after

        // Lazy detection to avoid init-timing issues.
        // In offline single-player, Cheat("ItVexesMe") toggles IsNoVictoryCheat().
        // In online/BNet games, Cheat() does nothing, so the state won't change.
        //
        // IMPORTANT: Prefer triggering this from a deterministic global flow
        // (e.g. GameModeSelection startup UI). This is a safe fallback.
        if udg_OfflineModeState == 0 then
            set before = IsNoVictoryCheat()
            call Cheat("ItVexesMe")
            set after = IsNoVictoryCheat()

            if after != before then
                set udg_OfflineModeState = 1
                // Revert to original state.
                call Cheat("ItVexesMe")
            else
                set udg_OfflineModeState = 2
            endif
        endif
        return udg_OfflineModeState == 1
    endfunction
    
    struct SaveFile extends array
        static constant string ManualPath = "Manual"
        static constant string InvalidPath = "Unknown"
        static constant string SP_FOLDER = "Singleplayer"
        static constant string MP_FOLDER = "Multiplayer"
        static constant integer MIN_SLOTS = 1
        static constant integer MAX_SLOTS = 290//12
        
        private File file
	
        static method operator Folder takes nothing returns string
            return (udg_MapName + "\\")
        endmethod

        static method IsSinglePlayerGame takes nothing returns boolean
            // NOTE: This intentionally means OFFLINE single-player.
            // Online/BNet games should always be treated as multiplayer saves (even with one player).
            return IsOfflineGame()
        endmethod

        static method ModeFolder takes nothing returns string
            if thistype.IsSinglePlayerGame() then
                return thistype.SP_FOLDER
            endif
            return thistype.MP_FOLDER
        endmethod

        static method Faction takes player p returns string
            if IsAlliancePlayer(p) then
                return "Alliance"
            else
                return "Horde"
            endif
        endmethod

        static method getBankPath takes player p returns string
            return Folder + ModeFolder() + "\\" + Faction(p) + "\\Bank.pld"
        endmethod

        static method getPath takes player p, integer slot returns string
            if (slot == 0) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot > 0 and (slot < MIN_SLOTS or slot > MAX_SLOTS)) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot < 0) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\SaveSlot_" + ManualPath + ".pld"
            endif
            return Folder + ModeFolder() + "\\" + Faction(p) + "\\SaveSlot_" + I2S(slot) + ".pld"
        endmethod

        static method getLegacyPath takes player p, integer slot returns string
            if (slot == 0) then
                return Folder + Faction(p) + "\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot > 0 and (slot < MIN_SLOTS or slot > MAX_SLOTS)) then
                return Folder + Faction(p) + "\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot < 0) then
                return Folder + Faction(p) + "\\SaveSlot_" + ManualPath + ".pld"
            endif
            return Folder + Faction(p) + "\\SaveSlot_" + I2S(slot) + ".pld"
        endmethod

        static method getBackupPath takes player p, integer slot, integer saveNumber returns string
            if (slot == 0) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\Backups\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot > 0 and (slot < MIN_SLOTS or slot > MAX_SLOTS)) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\Backups\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot < 0) then
                return Folder + ModeFolder() + "\\" + Faction(p) + "\\Backups\\SaveSlot_" + ManualPath + ".pld"
            endif
            return Folder + ModeFolder() + "\\" + Faction(p) + "\\Backups\\SaveSlot_" + I2S(slot) + "_" + I2S(saveNumber) + ".pld"
        endmethod

        static method getLegacyBackupPath takes player p, integer slot, integer saveNumber returns string
            if (slot == 0) then
                return Folder + Faction(p) + "\\Backups\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot > 0 and (slot < MIN_SLOTS or slot > MAX_SLOTS)) then
                return Folder + Faction(p) + "\\Backups\\SaveSlot_" + InvalidPath + ".pld" 
            elseif (slot < 0) then
                return Folder + Faction(p) + "\\Backups\\SaveSlot_" + ManualPath + ".pld"
            endif
            return Folder + Faction(p) + "\\Backups\\SaveSlot_" + I2S(slot) + "_" + I2S(saveNumber) + ".pld"
        endmethod
    
        static method create takes player p, string title, string items, integer slot, integer saveNumber, string data returns thistype
            if (GetLocalPlayer() == p) then
                call FileIO_Write(getPath(p, slot), title + "\n" + data + "\n" + items)
                call FileIO_Write(getBackupPath(p, slot, saveNumber), title + "\n" + data + "\n" + items)
            endif
            return slot
        endmethod
        
        static method clear takes player p, integer slot, integer saveNumber returns thistype
            if (GetLocalPlayer() == p) then
                call FileIO_Write(getPath(p, slot), "")
                call FileIO_Write(getBackupPath(p, slot, saveNumber), "")
                // Also clear legacy files so old saves don't "stick" in UI lists.
                call FileIO_Write(getLegacyPath(p, slot), "")
                call FileIO_Write(getLegacyBackupPath(p, slot, saveNumber), "")
            endif
            return slot
        endmethod
        
        static method exists takes player p, integer slot, integer saveNumber returns boolean // async
            if saveNumber == 0 then
                if StringLength(FileIO_Read(getPath(p, slot))) > 1 then
                    return true
                endif
                return StringLength(FileIO_Read(getLegacyPath(p, slot))) > 1
            else
                if StringLength(FileIO_Read(getBackupPath(p, slot, saveNumber))) > 1 then
                    return true
                endif
                return StringLength(FileIO_Read(getLegacyBackupPath(p, slot, saveNumber))) > 1
            endif
        endmethod
        
        method getLines takes player p, integer line, boolean includePrevious, integer saveNumber returns string // async
            local string contents
            local integer len
            local string char       = null
            local string buffer     = ""
            local integer curLine   = 0
            local integer i         = 0
            
            if saveNumber == 0 then
                set contents = FileIO_Read(getPath(p, this))
                if StringLength(contents) <= 1 then
                    set contents = FileIO_Read(getLegacyPath(p, this))
                endif
                // call Debug("Reading " + getPath(this) + " with length " + I2S(len))
            elseif saveNumber > 0 then
                set contents = FileIO_Read(getBackupPath(p, this, saveNumber))
                if StringLength(contents) <= 1 then
                    set contents = FileIO_Read(getLegacyBackupPath(p, this, saveNumber))
                endif
                // call Debug("Reading " + getBackupPath(this, saveNumber) + " with length " + I2S(len))
            // else
            //     set contents = FileIO_Read(getBankPath(this, saveNumber))
            //     call Debug("Reading " + getBankPath(this, saveNumber) + " with length " + I2S(len))
            endif
            set len = StringLength(contents)
            // call Debug("Contents " + contents)

            loop
                exitwhen i > len
                set char = SubString(contents, i, i + 1)
                if (char == "\n") then
                    set curLine = curLine + 1
                    if (curLine > line) then
                        return buffer
                    endif
                    if (not includePrevious) then
                        set buffer = ""
                    endif
                else
                    set buffer = buffer + char
                endif
                set i = i + 1
            endloop
            if (curLine == line) then
                return buffer
            endif
            return null
        endmethod
        
        method getLine takes player p, integer line, integer saveNumber  returns string // async
            return this.getLines(p, line, false, saveNumber)
        endmethod
        
        method getTitle takes player p, integer saveNumber returns string // async
            return this.getLines(p, 0, false, saveNumber)
        endmethod
        
        method getData takes player p, integer saveNumber returns string // async
            return this.getLines(p, 1, false, saveNumber)
        endmethod

        method getItems takes player p, integer saveNumber returns string // async
            return this.getLines(p, 2, false, saveNumber)
        endmethod

        // method getBackupData takes integer saveNumber returns string // async
        //     return this.getLines(1, false, saveNumber)
        // endmethod
    endstruct
    
endlibrary
