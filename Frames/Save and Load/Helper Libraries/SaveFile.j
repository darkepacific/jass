library SaveFile initializer Init requires FileIO, GenericFunctions

    globals
        // 0 = unresolved, 1 = offline, 2 = online
        integer udg_OfflineModeState = 0

        private timer udg_OfflineProbeTimer = null
        private integer udg_OfflineProbeAttempts = 0
        private constant integer OFFLINE_PROBE_MAX_ATTEMPTS = 40
        private constant real OFFLINE_PROBE_INTERVAL = 0.05
    endglobals

    function AnnounceDetectedMode takes nothing returns nothing
        local string msg

        if udg_OfflineModeState == 1 then
            set msg = "|cffffae00Offline Mode|n|r"
        elseif udg_OfflineModeState == 2 then
            set msg = "|cffffae00Multiplayer Mode (Online/BNet)|n|r"
        endif
        call NeatMessage(msg)

        set msg = null
    endfunction

    private function FinalizeOfflineMode takes integer mode returns nothing
        local integer i = 0

        if udg_OfflineModeState != 0 then
            return
        endif

        set udg_OfflineModeState = mode

        if mode == 1 then
            // Revert the cheat-granted lumber for all players.
            loop
                exitwhen i >= bj_MAX_PLAYERS
                call SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_LUMBER, 0)
                set i = i + 1
            endloop
        endif

        if udg_OfflineProbeTimer != null then
            call PauseTimer(udg_OfflineProbeTimer)
            call DestroyTimer(udg_OfflineProbeTimer)
            set udg_OfflineProbeTimer = null
        endif

        call AnnounceDetectedMode()
    endfunction

    function IsOfflineGame takes nothing returns boolean
        if udg_OfflineModeState == 0 and GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_LUMBER) > 0 then
            call FinalizeOfflineMode(1)
        endif
        return udg_OfflineModeState == 1
    endfunction

    private function CheckFirstPlayingUserLumber takes nothing returns nothing
        if GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_LUMBER) > 0 then
            call FinalizeOfflineMode(1)
            return
        endif

        set udg_OfflineProbeAttempts = udg_OfflineProbeAttempts + 1
        if udg_OfflineProbeAttempts >= OFFLINE_PROBE_MAX_ATTEMPTS then
            call FinalizeOfflineMode(2)
        endif
    endfunction

    private function Init takes nothing returns nothing
        call Cheat("LeafItToMe 100")
        call DisplayTextToForce(GetPlayersAll(), "\n\n\n\n\n\n\n\n\n\n\n\n")

        set udg_OfflineProbeTimer = CreateTimer()
        call CheckFirstPlayingUserLumber()
        if udg_OfflineProbeTimer == null then
            return
        endif
        call TimerStart(udg_OfflineProbeTimer, OFFLINE_PROBE_INTERVAL, true, function CheckFirstPlayingUserLumber)
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

        static method ModeFolder takes nothing returns string
            // NOTE: This intentionally means OFFLINE single-player.
            // Online/BNet games should always be treated as multiplayer saves (even with one player).
            if IsOfflineGame() then
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
            local string contents
            local string prefix
            local integer prefixLen

            set prefix = "[" + I2S(slot) + "]"
            set prefixLen = StringLength(prefix)
            if saveNumber == 0 then
                set contents = FileIO_Read(getPath(p, slot))
                if StringLength(contents) > 1 then
                    // If this save uses the new title prefix format, require it to match.
                    if SubString(contents, 0, 1) != "[" or SubString(contents, 0, prefixLen) == prefix then
                        return true
                    endif
                endif
                return StringLength(FileIO_Read(getLegacyPath(p, slot))) > 1
            else
                set contents = FileIO_Read(getBackupPath(p, slot, saveNumber))
                if StringLength(contents) > 1 then
                    if SubString(contents, 0, 1) != "[" or SubString(contents, 0, prefixLen) == prefix then
                        return true
                    endif
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
