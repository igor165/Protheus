#INCLUDE "PROTHEUS.CH"    
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RU99XFUN.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU99XFUN01_GetDir()

Function calls standard file selection dialog and stores selected
item in the memory

@param       Described below
@return      Logical .T.
@example     
@author      astepanov
@since       January/29/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU99XFUN01_GetDir(cMask, cTitle, nMaskNum, cHomeDir, lSave,;
                           nOptions, lTree, lKeepCase)
    
    Local aArea As Array
    Local cVarb As Character

    /* cMask indicates the name of the file or mask.
    Example: '*.txt|*.txt' */
    Default cMask     := "" 

    /* cTitle indicates the title of the window. 
    If the parameter is not specified, the default title 
    will be displayed. */
    Default cTitle    := STR0001 /*"Select directory"*/

    /* nMaskNum Indicates the mask number. */
    Default nMaskNum  := 0

    /* cHomeDir indicates the home directory. */
    Default cHomeDir  := ""

    /*Indicates whether it is a "save dialog" or an "open dialog".
    .T. - save dialog, .F. - open dialog*/
    Default lSave     := .F.

    /* nOptions
     GETF_MULTISELECT (2)	Allows you to select more than 1 
        file in the default "file1 | file2 | file3" Note: Not compatible 
        with " GETF_RETDIRECTORY" command and "File Name" editing.
     GETF_NOCHANGEDIR (4)	Do not change the home directory.
     GETF_LOCALFLOPPY (8)	Displays the floppy drive of the local machine.
     GETF_LOCALHARD (16)	Displays the local disk drive.
     GETF_NETWORKDRIVE (32)	Displays the network drives (mapping). 
     When running SmartClient with a user other than the user 
     logged on to Windows session the Network drives will not be displayed.
     GETF_SHAREWARE (64)	Not implemented.
     GETF_RETDIRECTORY (128)	Returns / displays a directory.
     GETF_HIDDENDIR (256) 	Shows hidden files and folders *
     GETF_SYSDIR (512)      Shows system files and folders *
     * The two parameters are only available in builds greater than 7.00.131227A. */
    Default nOptions  :=  GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE;
                          +GETF_RETDIRECTORY

    /* lTree indicates whether, true (.T.) Displays the server tree; 
    otherwise false (.F.). */
    Default lTree     := .F.

    /* lKeepCase indicates if true (.T.) Holds the original case;
    otherwise false (.F.). */
    default lKeepCase := .T.


    
    aArea    := GetArea()

    /* ReadVar() provides the name of the variable or field that is 
    currently selected or edited in commands and screen interface functions.
    ReadVar() function works only during the execution of any object 
    of type GET() */
    cVarb    := ReadVar()

    &(cVarb) := cGetFile(cMask,cTitle,nMaskNum,cHomeDir,lSave,nOptions,;
                         lTree,lKeepCase)

    RestArea(aArea)

Return (.T.)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU99XFUN02_RetDir()

Function returns from memory item stored by RU99XFUN01_GetDir

@param       
@return      Variant &(ReadVar())
@example     
@author      astepanov
@since       January/29/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU99XFUN02_RetDir()
Return( &(ReadVar()) )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU99XFUN03_F49SQFilter()

Filter for standard query F49 (payment order selection in Bank statement)
It filters payment orders by order status, supplier code and unit code
@param
@return      Logical          lRet
@example     
@author      astepanov
@since       September/09/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU99XFUN03_F49SQFilter()

   Local lRet       As Logical
   Local cSupp      As Character
   Local cUnit      As Character
   Local oModel     As Object

   lRet   := .T.
   oModel := FWModelActive()
   If  oModel != Nil .AND. oModel:GetId() == "RU06D07" .AND. oModel:IsActive()
      lRet := IIF(INCLUI, F49->F49_STATUS == "1", lRet)
      If lRet
         cSupp  := FwFldGet("F4C_SUPP" )
         cUnit  := FwFldGet("F4C_UNIT" )
         lRet   := lRet .AND. IIF(Empty(cSupp) ,.T.,F49->F49_SUPP    == cSupp  )
         lRet   := lRet .AND. IIF(Empty(cUnit) ,.T.,F49->F49_UNIT    == cUnit  )
         //condition !(F49->F49_IDF49 == cIDF49) excluded by consultant requirement
      EndIf
   EndIf
        
Return (lRet) /*----------------------------------------------------RU99XFUN03_F49SQFilter*/

/*/{Protheus.doc} RU99XFUN04_MakeCombo
Returns combobox, created from string array
@author Ivanov Alexander
@since 06/02/2019
@version P12.1.27
@example  cBox := RU99XFUN04_MakeCombo({STR0101, STR0102})
@type function
@return combobox
/*/ 
Function RU99XFUN04_MakeCombo(aItems as Array)
	Local cBox       as Character
	Local cNum       as Character
	Local nI         as Numeric
	Local nItems     as Numeric
	Local nMaxNumLen as Numeric

	cBox := ""
	nItems := Len(aItems)
	// warning: it's better to use SX5 if nItems > 12
	nMaxNumLen := Iif (nItems <= 9, 1, 2)
	
	For nI := 1 To nItems
		cNum := StrZero(nI, nMaxNumLen)
		cBox += cNum + "=" + aItems[nI] + ";"
	Next nI

Return cBox

/*{Protheus.doc} RU99XFUN05_Help
@description Shows given help message including name of current function and current code line.
@author alexander.ivanov
@since 02/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN05_Help(cMessage as Character)
	Local cFunction  as Character
	Local cLineNum   as Character
	Local nNextScope as Numeric
	nNextScope := 1
	cFunction   := ProcName(nNextScope)
	cLineNum := Str(ProcLine(nNextScope))
	Help("", 1, cFunction + ", line " + cLineNum, , cMessage, 1, 0)
Return

/*{Protheus.doc} RU99XFUN06_ArgsToCallback
@description Puts 1,2 or 3 arguments of types Logical, Numeric or Character to the callback string
@example RU99XFUN06_ArgsToCallback("Func_Add", nLine, cField, lRet)
@author alexander.ivanov
@since 04/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN06_ToCallback(cFunction as Character, xArg1, xArg2, xArg3)
	Local cCallBack  as Character
	Local cSeparator as Character

	cCallBack := cFunction + "(" + RU99XFUN07_Serialize(xArg1)
	cSeparator := ", "

	If xArg2 <> nil
		cCallBack += cSeparator + RU99XFUN07_Serialize(xArg2) 
	EndIf

	If xArg3 <> nil
		cCallBack += cSeparator + RU99XFUN07_Serialize(xArg3)
	EndIf

	cCallBack += ")"
Return cCallBack

/*{Protheus.doc} RU99XFUN07_Serialize
@description Converts variable to string, string variables will be embraced in quotes
@author alexander.ivanov
@since 04/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN07_Serialize(xVar)
   Local cString as Character
   cString := CValToChar(xVar)
   If ValType(xVar)=="C"
      cString := '"' + cString + '"'
   EndIf
Return cString

/*{Protheus.doc} IsInteger
@description Checks if a string represents integer
@author alexander.ivanov
@since 19/03/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN08_IsInteger(cText)
	Local cChar  as Character
   Local lIsInt as Logical
   Local nLen   as Numeric
   Local nPos   as Numeric

   lIsInt := .F.
	cText:= AllTrim(cText)
	nLen := Len(cText)
   lIsInt:= nLen > 0
 
	For nPos := 1 to nLen
		cChar := Substr(cText, nPos, 1)
      lIsInt := lIsInt .AND. IsDigit(cChar)
		If !lIsInt
			Exit
		EndIf
	Next nPos
Return lIsInt


/*{Protheus.doc} RU99XFUN09_MakeYesNoCombo
@description Creates translated Yes/No combobox
@author alexander.ivanov
@since 08/06/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN09_MakeYesNoCombo()
   Local aItems as Array
	aItems := {STR0004, STR0005}
Return RU99XFUN04_MakeCombo(aItems)


/*{Protheus.doc} RU99XFUN10_AppendFields
@description  Appends array with subarrays with field information. If nZeroes is not defined, precision will also be taken from SX3 cache 
@author alexander.ivanov
@since 03/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN10_AppendFields(aList as Array, aColNames as Array, nZeroes as Numeric)
	Local aField      as Array
	Local nWidth      as Numeric
	Local nI    	   as Numeric	
   Local nPrecision  as Numeric
	Local cFieldName  as Character
	Local cType       as Character
   Local lUseZeroes  as Logical
   Default nZeroes := -1

   lUseZeroes := nZeroes != -1
	For nI := 1 To Len(aColNames)
		cFieldName := aColNames[nI]
		cType  :=  GetSX3Cache(cFieldName, "X3_TIPO")
		nWidth :=  GetSX3Cache(cFieldName, "X3_TAMANHO")
      nPrecision := Iif(lUseZeroes, nZeroes, GetSX3Cache(cFieldName, "X3_DECIMAL"))
		aField := {cFieldName, cType, nWidth, nPrecision}
		aAdd(aList, aField)
	Next
Return


/*{Protheus.doc} RU99XFUN11_Concatenate
@description Makes delimiter-separated text from array of strings
@author alexander.ivanov
@since 03/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN11_Concatenate(aStrings as Array, cDelimiter as Character)
	Local cColumn as Character
	Local cText  as Character
	Local nI      as Numeric	
	Local nMax    as Numeric
   Default cDelimiter := ""

	nMax := Len(aStrings)
	cText := ""

	For nI := 1 To nMax-1
		cColumn := aStrings[nI]
		cText += (cColumn + cDelimiter)
	Next

	If  Len(aStrings) > 0
		cColumn := aStrings[nMax]
		cText += cColumn
	EndIf
	
Return cText


/*{Protheus.doc} RU99XFUN12_MakeInsertQuery
@description Makes insertion query part from array of fields and table name
@author alexander.ivanov
@since 03/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN12_MakeInsertionQueryPart(aStrings as Array, cTableName as Character)
   Local cColumn    as Character
   Local cDelimiter as Character
   Local cQuery     as Character
   Local nI         as Numeric
   Local nMax       as Numeric
   
   cDelimiter := ", "
	nMax := Len(aStrings)
	cQuery := ""

	For nI := 1 To nMax-1
		cColumn := aStrings[nI][1]
		cQuery += (cColumn + cDelimiter)
	Next

	If Len(aStrings) > 0
		cColumn := aStrings[nMax][1]
		cQuery += cColumn
	EndIf

   cQuery := " INSERT INTO " + cTableName + " (" + cQuery + ") "
Return cQuery

/*{Protheus.doc} RU99XFUN13_ReturnFieldsUsed_for_An_Alias
@description Check for an alias if the fields are used for a corrent location
 and return an array with the used fields. shpuld be used always in a static to be called 
 once otherwise it can affetc the perfomance
@author eduardo.flima
@since 20/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN13_ReturnFieldsUsed_for_An_Alias(cAlias)
    Local aUsedFld As Array        
    aUsedFld := {}

   dbSelectArea("SX3")
   dbSetOrder(1)
   SX3->(dbSeek(cAlias))
   While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias)
      If  X3USO(SX3->X3_USADO)
     		aAdd(aUsedFld, SX3->X3_CAMPO)
      EndIf
      SX3->(dbSkip())
   EndDo

Return aUsedFld

/*{Protheus.doc} RU99XFUN14_MakeMotLine
@description Combines line of length 20 for ReadMotBx function in matxfunb.prx
@author alexander.ivanov
@since 28/07/2020
@version 1.0
@project MA3 - Russia
*/
Function RU99XFUN14_MakeMotLine(cPrefix, cTransl, cPostfix)
	Local cEOL       as Character
   Local cTransPad  as Character
   Local nLenTrans  as Numeric
   
   cEOL := Chr(13) + Chr(10)
   nLenTrans := 20 - (Len(cPrefix) + Len(cPostfix) + Len(cEOL)) 
   cTransPad := PadR(cTransl, nLenTrans, " ")
Return cPrefix + cTransPad + cPostfix + cEOL



/*/{Protheus.doc} GetRusPopupMenuPos
@Return array of X and Y coordinates of standard popup menu (use it only if cPaisLoc == 'RUS').
@author Alexander Ivanov
@since 10/16/2019
@version 1.0
/*/
Function RU99XFUN15_GetRusPopupMenuPos()

	Local aPosition 	as Array
	Local nA			as Numeric
	Local nB 			as Numeric
	Local nLeft         as Numeric
	Local nRight        as Numeric
	Local nX 			as Numeric
	Local nY 			as Numeric
	Local nMonitorWidth as Numeric
	Local oDefSize 		as Object

	// Linear model params. Optimal for monitors of width 1366...2560 -  max error is 1 pixel
	// Not bad for 1024 - max error is about 3 pixels for this minimal recommended width
	nA := 0.983
	nB := -216

	oDefSize := FwDefSize():New()
	oDefSize:Process()
	nLeft := oDefSize:aWindSize[2]
	nRight := oDefSize:aWindSize[4]
	nMonitorWidth := nRight - nLeft

	nX := Int(nA * nMonitorWidth + nB)
	nY := 53
	aPosition := {nX, nY}

Return aPosition


/*/{Protheus.doc} InitArrayConuniLegContract
@Return array of Convential Units and Legal Contract or define any element by default value.
            aRet[1] - mark about Convential Units or define by "2"
            aRet[2] - UID of Legal contracts or define by spaces
@author Alexandra Velmozhnaia
@since 18/08/2020
@version 1.0
/*/
Function RU99XFUN16_InitArrayConuniLegContract(aAddRus as array)
Local aRet as Array

If Len(aAddRus) > 0
   aRet[1] := Iif(Empty(aAddRus[1]),"2",aAddRus[1])
   aRet[2] := Iif(Empty(aAddRus[2]),Space(Tamsx3("F5Q_UID")[1]),aAddRus[2])
Else
   aRet := {"",""}
EndIf

Return aRet
