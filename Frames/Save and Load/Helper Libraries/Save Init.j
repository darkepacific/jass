function Trig_Save_Init_Func025A takes nothing returns nothing
    call RemoveItem( GetEnumItem() )
endfunction

function Trig_Save_Init_Actions takes nothing returns nothing
    set udg_SaveLoadMaxLength = 64
    // -------------------
    // This willl be the directory the save codes will be saved to.
    // -------------------
    set udg_MapName = "BattleForLordaeron"
    // -------------------
    // This message will display to players who don't have local files enabled
    // -------------------
    set udg_LocalFiles_WarningMessage = "|cffe53b3bYou need to enable local files to load your character from disk on patches prior to 1.30!"
    set udg_LocalFiles_WarningMessage = udg_LocalFiles_WarningMessage + "\n\n"
    // -------------------
    // Save hero name (only works with the save slots, not raw save codes)
    // Also make sure to set the object editor field "Text - Proper Names Used" to 999  for all of your heroes.
    // -------------------
    set udg_SaveNameMax = 999
    // -------------------
    // -------------------
    // Max STR/AGI/INT
    // -------------------
    set udg_SaveUnitMaxStat = 999
    // -------------------
    // Store item types that can be saved here
    // -------------------
    call EnumItemsInRectBJ( gg_rct_XTRA_Island, function Trig_Save_Init_Func025A )
    set udg_SaveItemTypeMax = 999
    // Note: Changing max values can cause a code wipe
    // -------------------
    // Store ability types that can be saved here
    // -------------------
    set udg_i = 1
    set udg_SaveAbilityType[udg_i] = 'A08B'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03Q'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AUan'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AUan'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03X'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0C5'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00G'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00H'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08A'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05M'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0GD'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0EO'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08Y'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHav'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHbn'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09G'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHbh'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03D'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANbr'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A031'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00N'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05B'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0DA'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02H'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04R'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AEbl'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHbz'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01Z'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A06J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05I'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANbf'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANcf'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0CP'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01A'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04X'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01N'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01M'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00S'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A035'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08P'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AOcl'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A094'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A018'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04M'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00B'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00M'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A001'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0DS'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0DG'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A007'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0FU'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A06D'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05D'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00D'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'Acdb'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANdh'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'Acdh'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09S'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AOeq'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05K'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A010'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANav'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A030'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AEev'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A005'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A017'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A06F'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AEfk'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AOsf'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ACs7'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00I'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHfs'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AEfn'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03N'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08Q'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08I'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08L'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AE'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00W'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04N'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05G'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00K'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANhs'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AOhw'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03C'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03U'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04K'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHhb'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08W'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A099'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08H'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AR'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AOw2'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0FX'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08U'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05H'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08R'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09F'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04L'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AEme'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A003'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A05F'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0D0'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02Z'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0CS'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0D1'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A065'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0A2'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04W'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AN'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A037'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02P'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A014'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A03J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00F'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0A3'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A090'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0FQ'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09A'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02Y'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02J'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00U'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AD'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04P'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A045'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00C'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0FN'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0GS'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AM'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0D6'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0SD'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A02T'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANso'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A039'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A09C'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01E'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08S'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A01Y'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AHtc'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0AK'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0CR'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0D2'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'AUau'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A0E9'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A04U'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A00V'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'ANcs'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A034'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityType[udg_i] = 'A08T'
    set udg_i = ( udg_i + 1 )
    set udg_SaveAbilityTypeMax = 999
    // Note: Changing max values can cause a code wipe
    // -------------------
    // Automatically copy variables
    // -------------------
    set udg_SavePlayerLoading[0] = false
    set udg_SaveCount = 0
    set udg_SaveValue[0] = 0
    set udg_SaveMaxValue[0] = 0
    set udg_SaveTempInt = 0
    call SaveHelper.Init()
endfunction

//===========================================================================
function InitTrig_Save_Init takes nothing returns nothing
    set gg_trg_Save_Init = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Save_Init, function Trig_Save_Init_Actions )
endfunction

