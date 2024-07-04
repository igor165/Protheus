#include 'PROTHEUS.CH'
#INCLUDE "RU06D07.CH"
#INCLUDE 'PARMTYPE.CH' 
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D07
Payment Request Routine

@author Eduardo.FLima
@since 20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D07RUS()
Local aCoors     as Array
Local aRes       as Array
Local cIdTotal 	 as Character
Local cIdBrowse  as Character
Local oPanelDn   as Object
Local oPanelUp   as Object
Local oWin       as Object
Local oFWFilter  as Object
Local aTotFlds   as Object
Local oDlgPrinc  as Object

Private oBrowseUp   as Object
Private oBrowseTot  as Object
Private oTTbTotD07  as Object 

Private cCadastro   as Character // Included because of the MSDOCUMENT routine, 
Private aRotina     as Array     //but MSDOCUMENT needs the arotina and cCastro variables

Private lDigita     as Logical   //.T.-display entries, .F.-not display
Private lGeraLanc   as Logical   //.T.-account post OnLine, .F.-OffLine

Private aFltDflt07  as Array     //Contains intial default filter setting for oBrowseUp

lDigita    := .F.
lGeraLanc  := .F.
aCoors	   := FWGetDialogSize(oMainWnd) // size of a maximized window underneath the main Protheus window
aRotina	   := {}
aFltDflt07 := {}
DbSelectArea('F4C') // start table
DbSelectArea('F5M') // start table

Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) STYLE DS_MODALFRAME  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4]  OF oMainWnd Pixel  //Bank Statements
oDlgPrinc:lMaximized := .T.
// Create container where panels will be situated
oWin        := FWFormContainer():New(oDlgPrinc)
cIdBrowse   := oWin:CreateHorizontalBox( 90 ) // Space that we reserve to the Browse
cIdTotal    := oWin:CreateHorizontalBox( 10 ) // Space that we reserve to the Totals

oWin:Activate(oDlgPrinc, .F.)

// Create panels where browses will be created
oPanelUp    := oWin:GeTPanel(cIdBrowse) //Panel where we will create the Browse
oPanelDn    := oWin:GeTPanel(cIdTotal) //Panel where we will create the Total
oBrowseUp   := BrowseDef()
oBrowseUp:SetOwner(oPanelUp)

oBrowseTot := FWMBrowse():New()
aTotFlds := {{"BEGBAL", STR0033 },;
             {"INBAL" , STR0034 },;
             {"OUTBAL", STR0035 },;
             {"ENDBAL", STR0036 } }
aRes := RU06D07813_CreateTmpTabForTotBrowse(aTotFlds)
oTTbTotD07 := aRes[1]
oBrowseTot:SetAlias(oTTbTotD07:GetAlias())
aFltDflt07 := RU06D07811_Filter(Pergunte("RUD607",.T., STR0018,.F.))
If !Empty(aFltDflt07[1])
    oBrowseUp:SetFilterDefault(aFltDflt07[1])
EndIf
oBrowseTot:SetFields(RU06D0757_TotalFields(oTTbTotD07:GetAlias(),aRes[2]))
oBrowseTot:SetUseFilter(.F.)
oBrowseTot:SetUseCaseFilter(.F.)
oBrowseTot:SetAmbiente(.F.)
oBrowseTot:SetMenuDef("")
oBrowseTot:SetIgnoreARotina(.T.)
oBrowseTot:SetWalkThru(.F.)
oBrowseTot:SetOwner(oPanelDn)
oBrowseTot:DisableReport()
oBrowseTot:DisableDetails(.T.)
oBrowseTot:SetVScroll(.F.)

oBrowseUp:Activate()
oFWFilter := FWFilter():New(oBrowseUp)

RU06D0758_QueryTotal()

oBrowseTot:Activate() 

//Block code which will be executed after applying User filter
oBrowseUp:oFWFilter:SetValidExecute({|| RU06D0758_QueryTotal(),;
                                        oBrowseTot:Refresh()  })
//Block code which will be executed after executing 
//the operation defined for the button
oBrowseUp:SetAfterExec({|| RU06D0758_QueryTotal(),;
                           oBrowseTot:Refresh()  ,;
                           RU06D07812_Unlock()   })
//Load the last selected values from pergunte without show in screen 
//invisible to the user
RU06D07810_LoadAccountParametrization(.F.)
//Set that when the user press the key F12 we will open pergunte to
//the user choose the accounting way
SetKey(VK_F12, {|| RU06D07810_LoadAccountParametrization()})

Activate MsDialog oDlgPrinc Center
oTTbTotD07:Delete()

Return (Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef 
Browse definition.
@author Eduardo.FLima
@since  20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()

Local oBrowse as Object

oBrowse := FWLoadBrw("RU06D07")
oBrowse:SetDescription(STR0002)	// Bank Statements
oBrowse:SetMenuDef('RU06D07')
oBrowse:DisableDetails()
oBrowse:SetAlias('F4C')
oBrowse:SetProfileID('1')
oBrowse:ForceQuitButton()	
oBrowse:SetCacheView(.F.)

Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.
@author natalia.khozyainova
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

Local aRotina	AS ARRAY
aRotina :=  FWLoadMenuDef("RU06D07")
AADD(aRotina,{STR0019, "RU06D0755_RUSResetFilterBtn()", 0, 3, 0, Nil})

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.
@author Eduardo.FLima
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

Local oModel as object
	
oModel:= FwLoadModel("RU06D07")
oModel:SetDescription(STR0002) // Bank Statements

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author Eduardo.FLima
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Return (FWLoadView("RU06D07"))


/*/{Protheus.doc} RU06D0755_RUSResetFilterBtn
Reset Filter Button
@private aFltDflt07, oBrowseUp, oBrowseTot
@author natalia.khozyainova
@since 23/11/2018
@edit  astepanov 05/April/2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0755_RUSResetFilterBtn()

    If Pergunte("RUD607",.T., STR0018,.F.)
        aFltDflt07 := RU06D07811_Filter(.T.)
        oBrowseUp:CleanFilter() 
        If !Empty(aFltDflt07[1])
            oBrowseUp:SetFilterDefault(aFltDflt07[1])
        EndIf
        oBrowseUp:ExecuteFilter(.T.)
        oBrowseUp:GetOwner():Refresh()
    EndIf

Return (Nil)

/*/{Protheus.doc} RU06D0757_TotalFields
This function returns Field structure of Total browse
@param 
    Character cAlias alias to temporary table
    Array    aFields {{FieldName,FieldType,FldTamanho,
                       FldDecimal, FldPicture, 
                       FldTitle}...}
@author alexandra.menyashina
@since 12/12/2018
@edit  astepanov  04/April/2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0757_TotalFields(cAlias, aFields)

    Local aRet      as Array
    Local nX        as Numeric
    Local bBlk      as Block

    aRet  := {}
    For nX := 1 To Len(aFields)
        bBlk  := &("{|| "+cAlias+"->"+aFields[nX][1]+"}")
        AADD(aRet, {aFields[nX][6] ,; //[01] Column title
                    bBlk           ,; //[02] Data load code-block
                    aFields[nX][2] ,; //[03] Data type
                    aFields[nX][5] ,; //[04] Mask
                    0              ,; //[05] Alignment (0 = Centered, 1 = Left or 2 = Right)
                    aFields[nX][3] ,; //[06] Size
                    aFields[nX][4] ,; //[07] Decimal
                                   })
    Next nX

Return aRet

/*/{Protheus.doc} RU06D0758_QueryTotal
This function runs Query for Total and insert
result to temporary table which used by oBrowseTot
@return   Logical  .T.
@private oBrowseUp, aFltDflt07
@author alexandra.menyashina
@edit   astepanov 31 Jan 2020, 04 April 2020
@since 12/12/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0758_QueryTotal()
    Local cQuery     as Character
    Local cUsrFilter as Character
    Local cWhereSE8  as Character
    Local cWhereF4C  as Character
    Local cQr        as Character
    Local cAlias     as Character
    Local aFilters   as Array
    Local aArea      as Array
    Local nX         as Numeric
    Local nStat      as Numeric

    // Get default and user filters
    aFilters := IIF(ValType(oBrowseUp) == "O" .AND.  oBrowseUp:FwFilter() != Nil,;
                    oBrowseUp:FwFilter():GetFilter(), {}                         )
    cUsrFilter  := ""
    For nX:=1 to Len(aFilters) // convert standard filters expressions to SQL format
        If !Empty(aFilters[nX][3])
            cUsrFilter += " AND "
            If SubStr(aFilters[nX][3], 1, 1) == "#"
                cUsrFilter += &(SubStr(aFilters[nX][3],2,Len(aFilters[1][3])-2))
            Else
                cUsrFilter += aFilters[nX][3]
            EndIf
        EndIf
    Next nX
    // Create where conditions for data selection
    // current E8_FILIAL is shared, so we can't filter
    // data in SE8 by filial, so current SE8 saldos we can get only
    // by all filials. If it will be private we should
    // transfer E8_FILIAL condition to If !(Empty(aFltDflt07[1]))
    // condition, and after that we can get correct SE8 saldo by filial 
    cWhereSE8 := " WHERE E8_FILIAL  = '"+xFilial("SE8")+"' "
    cWhereSE8 += " AND D_E_L_E_T_ = ' ' "
    cWhereF4C := " WHERE "
    If !(Empty(aFltDflt07[1]))
        cWhereSE8 += " AND E8_DTSALAT < '"+aFltDflt07[5]+"' AND "
        cWhereSE8 += " E8_BANCO  >= '"+aFltDflt07[7]+"'     AND "
        cWhereSE8 += " E8_BANCO  <= '"+aFltDflt07[8]+"'         "
        If !Empty(aFltDflt07[9])
            cWhereSE8 += " AND "
            cWhereSE8 += "E8_MOEDA = '"+aFltDflt07[9]+"'        "
        EndIf
        cWhereF4C += aFltDflt07[2] + " AND "
    Else
        cWhereSE8 += " AND E8_DTSALAT < '"+"00000000"+"' "
    EndIf
    // F4C_STATUS   1 2 3 4 5 6 7
    // F4C_VALUE    + + 0 + + 0 +
    cWhereF4C += " F4C_STATUS IN ('1','2','4','5','7') AND      "
    cWhereF4C += " D_E_L_E_T_ = ' ' " + cUsrFilter

    // this query recieves BEGBAL, INBAL, OUTBAL AND ENDBAL from
    // F4C and SE8 tables. BEGBAL we get from SE8 table, we can
    // get BEGBAL from F4C table by calculating overturns 
    // but it will be bad way.
    // formula from consultant:
    // BEGBAL - from SE8
    // INBAL and OUTBAL from F4C
    // ENDBAL = BEGBAL + INBAL - OUTBAL
    // So we group values by currencies, but according to strange
    // requirement from consultant we should summarize values in
    // different currencies. I don't know how we can add goats
    // to cows, but anyway you can apply minimum changes to this
    // query and get values in different currencies
    // exclude groupings:  GROUP BY TB2.MOEDA  and 
    // GROUP BY SE8.E8_MOEDA and you will recieve values in
    // different currencies
    // We use UNION ALL, so field order is very important.
    cQuery := "SELECT SUM(BEGBAL) BEGBAL,                       " 
    cQuery += "       SUM(INBAL)  INBAL,                        "
    cQuery += "       SUM(OUTBAL) OUTBAL,                       "
    cQuery += "       SUM(ENDBAL) ENDBAL                        "
    cQuery += "FROM (                                           "
    //subquery for getting INBAL and OUTBAL from F4C table
    cQuery += " SELECT COALESCE(SUM(TB3.BEGBAL),0) BEGBAL,      "
    cQuery += "        COALESCE(SUM(TB3.INBAL) ,0)  INBAL,      "
    cQuery += "        COALESCE(SUM(TB3.OUTBAL),0) OUTBAL,      "
    cQuery += "        COALESCE(SUM(TB3.ENDBAL),0) ENDBAL       "
    cQuery += " FROM (                                          "
    cQuery += "   SELECT CAST(TB2.MOEDA  AS NUMERIC) MOEDA,     "
    cQuery += "          0                           BEGBAL,    "
    cQuery += "          SUM(TB2.INBAL)              INBAL,     "
    cQuery += "          SUM(TB2.OUTBAL)             OUTBAL,    "
    cQuery += "          SUM(TB2.INBAL) -                       "
    cQuery += "          SUM(TB2.OUTBAL)             ENDBAL     "
    cQuery += "   FROM (                                        "
    cQuery += "     SELECT  F4C_CURREN                  MOEDA,  "
    cQuery += "             CASE WHEN F4C_OPER = '1'            "
    cQuery += "                  THEN F4C_VALUE                 "
    cQuery += "                  ELSE 0                         "
    cQuery += "             END                         INBAL,  "
    cQuery += "             CASE WHEN F4C_OPER = '2'            "
    cQuery += "                  THEN F4C_VALUE                 "
    cQuery += "                  ELSE 0                         "
    cQuery += "             END                         OUTBAL  "
    cQuery += "     FROM " + RetSQLName("F4C") + "              "
    cQuery +=       cWhereF4C
    cQuery += "        ) TB2                                    "
    cQuery += "   GROUP BY TB2.MOEDA                            "
    cQuery += "      ) TB3                                      "
    //-----------------------------------------------------------
    cQuery += " UNION ALL                                       "
    //-----------------------------------------------------------
    //subquery for getting BEGBAL from SE8
    cQuery += " SELECT COALESCE(SUM(TB4.BEGBAL),0) BEGBAL,      "
    cQuery += "        COALESCE(SUM(TB4.INBAL) ,0)  INBAL,      "
    cQuery += "        COALESCE(SUM(TB4.OUTBAL),0) OUTBAL,      "
    cQuery += "        COALESCE(SUM(TB4.ENDBAL),0) ENDBAL       "
    cQuery += " FROM (                                          "
    cQuery += "   SELECT CAST(SE8.E8_MOEDA AS NUMERIC) MOEDA,   "
    cQuery += "          SUM(SE8.E8_SALATUA)           BEGBAL,  "
    cQuery += "          0                             INBAL,   "
    cQuery += "          0                             OUTBAL,  "
    cQuery += "          SUM(SE8.E8_SALATUA)           ENDBAL   "
    cQuery += "   FROM   "+RetSQLName("SE8")+ " SE8             "
    cQuery += "   INNER JOIN (                                  "
    cQuery += "                SELECT E8_FILIAL,                "
    cQuery += "                       E8_BANCO,                 "
    cQuery += "                       E8_AGENCIA,               "
    cQuery += "                       E8_CONTA,                 "
    cQuery += "                       E8_MOEDA,                 "
    cQuery += "                       MAX(E8_DTSALAT) E8_DTSALAT"
    cQuery += "                FROM "+RetSQLName("SE8")+"       "
    cQuery +=                  cWhereSE8
    cQuery += "                GROUP BY E8_FILIAL,  E8_BANCO,   "
    cQuery += "                         E8_AGENCIA, E8_CONTA,   "
    cQuery += "                         E8_MOEDA                "
    cQuery += "              ) TB1                              "
    cQuery += "   ON ( SE8.E8_FILIAL  = TB1.E8_FILIAL           "
    cQuery += "    AND SE8.E8_BANCO   = TB1.E8_BANCO            "
    cQuery += "    AND SE8.E8_AGENCIA = TB1.E8_AGENCIA          "
    cQuery += "    AND SE8.E8_CONTA   = TB1.E8_CONTA            "
    cQuery += "    AND SE8.E8_MOEDA   = TB1.E8_MOEDA            "
    cQuery += "    AND SE8.E8_DTSALAT = TB1.E8_DTSALAT          "
    cQuery += "    AND SE8.D_E_L_E_T_ = ' '           )         "
    cQuery += "   GROUP BY SE8.E8_MOEDA                         "
    cQuery += "      ) TB4                                      "
    cQuery += ") BLN                                            "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    If (oTTbTotD07:GetAlias())->(LastRec()) == 0
        cQr :=    " INSERT INTO " + oTTbTotD07:GetRealName() + "  "+;
                  " (BEGBAL, INBAL, OUTBAL, ENDBAL) "        + cQuery
        nStat := TCSqlExec(cQr)
    Else
        cAlias := MPSysOpenQuery(cQuery)
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        While !Eof()
            cQr := " UPDATE "  + oTTbTotD07:GetRealName() + " "
            cQr += " SET BEGBAL = " + cValToChar((cAlias)->BEGBAL) + ", "
            cQr += "     INBAL  = " + cValToChar((cAlias)->INBAL ) + ", "
            cQr += "     OUTBAL = " + cValToChar((cAlias)->OUTBAL) + ", "
            cQr += "     ENDBAL = " + cValToChar((cAlias)->ENDBAL) + "  "
            nStat := TCSqlExec(cQr)
            (cAlias)->(DBSkip())
        EndDo
        (cAlias)->(DBCloseArea())
    EndIf
    (oTTbTotD07:GetAlias())->(DBGoTop())
    RestArea(aArea)
Return (.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07810_LoadAccountParametrization

Function used to load the parametrization of accounting post

@param       Logical          lShow   : flag that inform if we must show the ask screen
                                        to the user, if it is .F. we only load the values 
                                        stored previously in private variables
@return      Logical          lRet
@private     lGeraLanc, nBSPos, lDigita 
@example     
@author      astepanov
@since       September/23/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07810_LoadAccountParametrization(lShow)

    Local    lRet       As Logical
    Local    lConfirm   As Logical
    Local    nLenPerg   As Numeric
    Local    nX         As Numeric
    Local    cPergunta  As Character
    Local    aParFilter As Array
    Default  lShow      := .T.

    lRet       := .F.
    lConfirm   := .F.
    aParFilter := {}
    //First we need to save the values related to the Filter pergunte, after we set the
    //private variables we need to set it back
    nLenPerg := FGetLenPgt("RUD607") //Returns # of questns from the question group in use
    //Store in an array the values of this pergunte
    For nX := 1 To nLenPerg                                              
        cPergunta := "mv_par" + StrZero(nX,2)
        AADD(aParFilter, &(cPergunta))
    Next nX
    //Access the pergunte related to the accounting post and according to the variable lShow
    //show or not the choices screen
    lConfirm := Pergunte("RUD67CTB", lShow, STR0168) //Accounting configurations
    If !lShow .OR. lConfirm
        //Define variables , if choise screen is non-visible we load values, otherwise
        //we load them only if the user confirmed your own choice
        lGeraLanc   := (MV_PAR01 == 1)
        lDigita     := (MV_PAR03 == 1)
    EndIf
    //Restore mv_parXX
    For nX := 1 To nLenPerg
        cPergunta    := "mv_par" + StrZero(nX,2)
        &(cPergunta) := aParFilter[nX]
    Next nX

    lRet := .T.
    
Return (lRet) /*-------------------------------------RU06D07810_LoadAccountParametrization*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07811_Filter

Function used to load intitial default filter data according to Pergunta RUD607

@param      Logical          lOk    : .T. - if we pressed in pergunte OK, .F. - if we 
                                      pressed Cancel
@return     Array            aRet  [cFltADVPL, cFltSQL, cFilialBeg, cFilialEnd, cDtTranBeg, 
                                    cDtTranEnd, cBnkCodBeg, cBnkCodEnd, cCurren           ]
@example     
@author      aVelmoznaia
@since       March/11/2020
@edit        astepanov  April/03/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07811_Filter(lOk)

    Local aRet       As Array
    Local cFltADVPL  As Character
    Local cFltSQL    As Character
    Local cAND       As Character
    Local cFilialBeg As Character
    Local cFilialEnd As Character
    Local cDtTranBeg As Character
    Local cDtTranEnd As Character
    Local cBnkCodBeg As Character
    Local cBnkCodEnd As Character
    Local cCurren    As Character

    Default  lOk     := .F.
    aRet      := {}
    cFltADVPL := "" //default filter in ADVPL
    cFltSQL   := "" //default filter in SQL
    cFilialBeg := IIF(Empty(MV_PAR01)                           ,;
                      Replicate(" ",TamSX3("F4C_FILIAL")[1])    ,;
                      PADR(MV_PAR01,TamSX3("F4C_FILIAL")[1]," ") )
    cFilialEnd := IIF(Empty(MV_PAR02)                           ,;
                      Replicate("z",TamSX3("F4C_FILIAL")[1])    ,;
                      PADR(MV_PAR02,TamSX3("F4C_FILIAL")[1]," ") )
    cDtTranBeg := IIF(Empty(MV_PAR03)                           ,;
                      "00000000"                                ,;
                      DTOS(MV_PAR03)                             )
    cDtTranEnd := IIF(Empty(MV_PAR04)                           ,;
                      "99991231"                                ,;
                      DTOS(MV_PAR04)                             )
    cBnkCodBeg := IIF(Empty(MV_PAR05)                           ,;
                      Replicate(" ",TamSX3("E8_BANCO")[1])      ,;
                      PADR(MV_PAR05,TamSX3("E8_BANCO")[1], " ")  )
    cBnkCodEnd := IIF(Empty(MV_PAR06)                           ,;
                      Replicate("z",TamSX3("E8_BANCO")[1])      ,;
                      PADR(MV_PAR06,TamSX3("E8_BANCO")[1], " ")  )
    // at this moment E8_MOEDA looks like " 1" , but not "01"
    // should be changed if currency representation will be
    // changed in E8_MOEDA
    cCurren    := IIF(Empty(MV_PAR07)                           ,;
                      Replicate(" ",TamSX3("E8_MOEDA")[1])      ,;
                      PADL(AllTrim(Str(Val(MV_PAR07))),;
                                    TamSX3("E8_MOEDA")[1], " ")  )
    If lOk //was pressed Ok in Pergunte
        cAND    := " .AND. "
        If !(Empty(MV_PAR01))
            cFltADVPL += " F4C_FILIAL >=       '" + cFilialBeg + "' "
            cFltADVPL += cAND
        EndIf
        If !(Empty(MV_PAR02))
            cFltADVPL += " F4C_FILIAL <=       '" + cFilialEnd + "' "
            cFltADVPL += cAND  
        EndIf
        If !(Empty(MV_PAR03))
            cFltADVPL += " DTOS(F4C_DTTRAN) >= '" + cDtTranBeg + "' "
            cFltADVPL += cAND        
        EndIf
        If !(Empty(MV_PAR04))
            cFltADVPL += " DTOS(F4C_DTTRAN) <= '" + cDtTranEnd + "' "
            cFltADVPL += cAND      
        EndIf
        If !(Empty(MV_PAR07))
            cFltADVPL += " F4C_CURREN = '" + MV_PAR07 + "'          "
            cFltADVPL += cAND
        EndIf
        //If F4C_OPER = Outflow, filter by F4C_BNKPAY
        //If F4C_OPER = Inflow, filter by F4C_BNKREC
        cFltADVPL += " ("
        cFltADVPL += "  (F4C_OPER = '2'                         "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKPAY >= '" + cBnkCodBeg  + "'    "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKPAY <= '" + cBnkCodEnd  + "' )  "
        //---
        cFltADVPL += " .OR. "
        //--
        cFltADVPL += "  (F4C_OPER = '1'                         "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKREC >= '" + cBnkCodBeg  + "'    "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKREC <= '" + cBnkCodEnd  + "' )  "
        cFltADVPL += ") "
        cFltADVPL += cAND 
        If !Empty(cFltADVPL)
            cFltADVPL := SubStr(cFltADVPL,1,Len(cFltADVPL)-Len(cAND))
            //be careful with conversion
            cFltSQL   := StrTran(cFltADVPL," .OR. ", " OR ",/*nStart*/,/*nCount*/)
            cFltSQL   := StrTran(cFltSQL," .AND. ", " AND ",/*nStart*/,/*nCount*/)
            cFltSQL   := StrTran(cFltSQL," DTOS(F4C_DTTRAN) "," F4C_DTTRAN "     )
        EndIf
    EndIf
    AADD(aRet, cFltADVPL )
    AADD(aRet, cFltSQL   )
    AADD(aRet, cFilialBeg)
    AADD(aRet, cFilialEnd)
    AADD(aRet, cDtTranBeg)
    AADD(aRet, cDtTranEnd)
    AADD(aRet, cBnkCodBeg)
    AADD(aRet, cBnkCodEnd)
    AADD(aRet, cCurren   )

Return (aRet) /*---------------------------------------------------------RU06D07811_Filter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07812_Unlock
@return      Logical      .T. // this function temporary solves temporary problem with 
                              // mBrowse()
@example     
@author      astepanov
@since       April/04/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07812_Unlock()
    //Three lines below included because Browse create strange situation:
    //it locks current record but don't unlock it.
    //So this is temporary fix for unlocking current line in Browse,
    //until real problem will be found.
    If Len(("F4C")->(DBRLockList())) > 0 
        F4C->( MsUnlock() )
    EndIf
    //Line below fix F12 key trouble for Browse
    SetKey(VK_F12, {|| RU06D07810_LoadAccountParametrization()})

Return (.T.) /*----------------------------------------------------------RU06D07812_Unlock*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07813_CreateTmpTabForTotBrowse
Function returns clear temporary table for oBrowseTot
@param       Array       aTotFlds {{"BEGBAL","Tit"}, {"INBAL","Tit"}, 
                                  {"OUTBAL","Tit"}, {"ENDBAL","Tit"}...}
@return      Array       {Object oTmpTab, Array aFields} 
@example     
@author      astepanov
@since       April/04/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07813_CreateTmpTabForTotBrowse(aTotFlds)
    
    Local oTmpTab    as Object
    Local aFields    as Array
    Local nX         as Numeric
    oTmpTab := FWTemporaryTable():New(CriaTrab(,.F.))
    aFields := {}
    For nX := 1 To Len(aTotFlds)
        AADD(aFields,{ aTotFlds[nX][1],;
                       GetSX3Cache("F4C_VALUE","X3_TIPO"),;
                       GetSX3Cache("F4C_VALUE","X3_TAMANHO"),;
                       GetSX3Cache("F4C_VALUE","X3_DECIMAL"),;
                       GetSX3Cache("F4C_VALUE","X3_PICTURE"),;
                       aTotFlds[nX][2]                       })
    Next nX
    oTmpTab:SetFields(aFields)
    oTmpTab:Create()

Return ({oTmpTab,aFields}) /*--------------------------RU06D07813_CreateTmpTabForTotBrowse*/

