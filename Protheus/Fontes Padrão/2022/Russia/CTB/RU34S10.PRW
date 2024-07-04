#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34S10.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU34S10
@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU34S10()
Local cCTB020       := IIF(FindFunction("GetSPName"), GetSPName("CTB020","01"), "CTB020")
Private oMainDlg 	as Object
Private nOper       as numeric

If cPaisLoc != "RUS"
    Help( ,, "RU34S10",, STR0080 , 1, 0 )
    return Nil
Endif
If GetMv("MV_R34CORR") == Nil
    Help ( ,, "RU34S10",, STR0083 , 1, 0 )
    return Nil
Endif

//TODO - should be removed after fix Stored Procedure
//At store procedure there is no treatment to red Storno, so we disable that for now until fix it
If ExistProc(cCTB020) 
    Help( ,, "RU34S10",, "Stored Procedure: "+cCTB020+;
    " activated, the recalculation will not work correct, please deactivate Stored procedure (CTBA190) and run  CTBA190, before execute this routine." , 1, 0 )
    return Nil
Endif
    
RU34S1010()

Return Nil

/*-----------------------------------------------------------------------
@Descrip.:  Function for run turnover sheet report
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Function RU34S1010()
Local lExit as logical
Private aLevelsEn	:= {}
Private aFiltersEn	:= {}
Private aDivisions  := { "1="+STR0041, "2="+STR0042, "3="+STR0043, "4="+STR0044 } //"No Division","Hundred","Thousand","Milion"
Private aGrBalance  := { STR0081, STR0082} //"Show Grouped balance:" // 1=No, 2=Yes
Private aSumLedAcc  := { STR0081, STR0082} //"show summarized ledger account :" // 1=No, 2=Yes
Private aLedAccDsc  := { STR0081, STR0082} //"show ledger account description:" // 1=No, 2=Yes
Private nLevel		:= 1
Private nMaxLevelE	:= 1
Private cAliasAtu	:= ""
Private cCadastro	:= ""
Private aCT1_CONTA  := {}
Private aLevelTabE	:= {}
Private dDateFrom	:= CTOD("  /  /  ")
Private dDateTo		:= CTOD("  /  /  ")
Private cFilFrom	:= Space(254)//Space(TamSx3("CT2_FILIAL")[1])
Private cFilTo		:= Space(TamSx3("CT2_FILIAL")[1])
Private cCurrency	:= "  "
Private cBalType	:= Space(254)//" "
Private	cDivision	:= aDivisions[1]
Private nDivide		:= 1
Private cGrBalance  := aGrBalance[1]
Private cSumLedAcc  := aSumLedAcc[1]
Private cLedAccDsc  := aLedAccDsc[1]
Private	aParametro	:= {}
Private	aPrintPara	:= {}
Private lMarker     := .T.
Private cRetSX5SL   := ""
Private oGet1       as Object
Private aPsListA    as array //array with parameters used at wizard, even user not save the changes this array will keep last changes
Private aPsList3A   as array
Private lSelParam   as logical
Private cSelParam   as character
Private cTempParam  as character
Private aF61XData   as array //array with paramter at DB.
Private cUserf61    as character
Private cUNamParam  as character
Private lEdit       as logical
Private aF61MData   as array
Private lShowWiz    as logical
Private lIsEscape   := .F.

lExit       :=.F.
aF61MData   :={}
lShowWiz    :=.T.
lEdit       :=.F.
cUserf61    :=Space(6)
cUNamParam  :=""
aF61XData   :={}
lSelParam   :=.F.
aPsListA    :={}
aPsList3A   :={}
nOper       :=0

Processa( {||lExit:=RU34S10RB()}, STR0056 , STR0057 , .T. )//"Please Wait..." "Processing Entities!"
If lExit
    GetF61_header({"NAME","SHARED","SHAREDVALUE"},"RU34S10")

    If lShowWiz
        If RU34S10WIZ()
            Processa( {||Process()}, STR0056 , STR0057 , .T. )//"Please Wait..." "Processing Entities!"
        Endif
    Else
        Processa( {||RU34S1006_RunReport()}, STR0056 , STR0057 , .T. )//"Please Wait..." "Processing Entities!"
    EndIf
EndIf
Return .T.

//-------------------------------------------------------------------
Static Function Process()
    Local oPanel 		As Object
    Local oDados 		As Object
    Local oPnMaster 	As Object
    Local oTempTable 	As Object
    Local aButtons      As Object
    Local aLevel 		as array
    Local aFields 		as array
    Local a2Fields 		as array
    Local aSizes		as array
    Local aBalBeg		as array
    Local bDoubleCli	as block
    Local nX			as numeric
    Local nI			as numeric
    Local nRecCount		as numeric
    Local cQryDoc		as character
    Local cAreaRepp		as character
    Local aAddEcFld     As Array
    Local aColFilter    as Array
    Local aButtons2     as array
    Local nRet1         as Numeric
    Local cSupAcc       as character //superior acc
    Local cIndSub       as character //index to seek superior acc
    Local nQtdEnt       as character //Number of aditional acc entities
    
    oDados := CreateQry() //Create the main query for moviments, using CT2 to selecte values
    If oDados <> Nil //If has information for parameter selected, create and show main  dialog

        nQtdEnt     := CtbQtdEntd() 
        aSizes		:= FWGetDialogSize() //size of dialog MsAdvSize()
        cQryDoc		:= GetNextAlias()
        nRet1       := 0
        aLevel		:= {}
        aFields 	:= {}
        aBalBeg 	:= {}
        aSelFil		:= RngFil()
        nRecCount	:= 0
        aButtons	:= {}
        bDoubleCli	:= { || LastLevel(cAreaRepp) }
        cAreaRepp	:= GetNextAlias()
        aAddEcFld   := {}
        aColFilter  := {}

        //Verify aditional
        CT0->(DbSetOrder(1))    //CT0_FILIAL+CT0_ID
        CT0->(DbGoTop())
        While !CT0->(Eof()) .And. CT0->CT0_FILIAL == xFilial("CT0")
            If !Empty(aScan(aLevelTabE,{|x| UPPER(x[1]) == UPPER(CT0->CT0_ALIAS)})) .And. !Empty(CT0->CT0_ENTIDA)
                aAdd(aAddEcFld,AllTrim(CT0->CT0_ID))
            Endif
            CT0->(DbSkip())
        EndDo

        //Add actions 
        aAdd(aButtons,	{ STR0086, { || RU34S10PRT(),oFWBrow:refresh(.T.) }, STR0086} ) //"Print"
        aButtons2 := {}
        aAdd(aButtons2, { , { || RU34S1001_SaveF61(aPsListA,1) }, STR0145} )//save in new (Save Name/Share)
        aAdd(aButtons2, { , { || Iif(EditF61_header(cSelParam,.T.),Iif(lShowWiz,EditF61_items(aPsListA,cSelParam),MsgInfo(STR0107, STR0108)),)},STR0146} )// Save in current (Edit Name/Share)
        aAdd(aButtons2, { , { || nOper:=3,lEdit:=.T.,lShowWiz:=.T.,Iif(RU34S10WIZ(aPsListA),(oMainDlg:End(),Process()),.F.)},STR0147} )//change current, send current values at parameter on function RU34S10WIZ
        aAdd(aButtons2, { , { || nRet1 := RU34S1002(),Iif(nRet1>0, (oMainDlg:End(),Iif(nRet1==1,Process(), RU34S1006_RunReport())),.T.) }, STR0148} )//'Open configuration'} )
        aAdd(aButtons,{,, STR0152, STR0152,,,aButtons2} )
        
        cCadastro := STR0001 //"Drill Down Accounting Analysis"

        Define MsDialog oMainDlg Title cCadastro From aSizes[1], aSizes[2] To aSizes[3], aSizes[4] Pixel

        oPnMaster := tPanel():New(0,0,,oMainDlg,,,,,,0,0)
        oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT

        oPanelBC := tPanel():New(0,0,,oPnMaster,,,,,,0,49)
        oPanelBC:Align := CONTROL_ALIGN_BOTTOM

        oPanelBrw := tPanel():New(0,0,,oPnMaster,,,,,,0,0)
        oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT
        oFont1 := TFont():New("Arial",,,.T.)
        oFont1:Bold := .T.
        oFont2 := TFont():New("Arial",,,.T.)
        oSay := tSay():New(5,10,{|| STR0069},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Filial From: "
        oSay := tSay():New(5,60,{|| If(Empty(cFilFrom),"'   '",cFilFrom) },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        oSay := tSay():New(20,10,{|| STR0071},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Date From: "
        oSay := tSay():New(20,60,{|| dDateFrom },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        oSay := tSay():New(35,10,{|| STR0072},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Date To: "
        oSay := tSay():New(35,60,{|| dDateTo },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        oSay := tSay():New(5,220,{|| STR0073},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Currency: "
        oSay := tSay():New(5,270,{|| cCurrency },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        oSay := tSay():New(20,220,{|| STR0074},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Balance Type: "
        oSay := tSay():New(20,270,{|| cBalType },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        oSay := tSay():New(35,220,{|| STR0075},oPanelBC,,oFont1,,,,.T.,,,50,15)//"Division by: "
        //Division
        Do Case
            Case cDivision == "1"
                oSay := tSay():New(35,270,{|| STR0041 },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
            Case cDivision == "2"
                oSay := tSay():New(35,270,{|| STR0042 },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
            Case cDivision == "3"
                oSay := tSay():New(35,270,{|| STR0043 },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
            Case cDivision == "4"
                oSay := tSay():New(35,270,{|| STR0044 },oPanelBC,,oFont2,,,,.T.,CLR_RED,,145,15)
        EndCase
        oSay := tSay():New(5, 480, {|| STR0084}, oPanelBC, , oFont1, , , , .T., , , 70, 15)//"Show gr balance: "
        oSay := tSay():New(5, 540, {|| IIf(cGrBalance == "1", SubStr(STR0081, 03), SubStr(STR0082, 03)) }, oPanelBC, , oFont2, , , , .T., CLR_RED, , 145, 15)
        oSay := tSay():New(20, 480, {|| STR0095}, oPanelBC, , oFont1, , , , .T., , , 70, 15)//"show summarized ledger account :"
        oSay := tSay():New(20, 540, {|| IIf(cSumLedAcc == "1", SubStr(STR0081, 03), SubStr(STR0082, 03)) }, oPanelBC, , oFont2, , , , .T., CLR_RED, , 145, 15)
        oSay := tSay():New(35, 480, {|| STR0089}, oPanelBC, , oFont1, , , , .T., , , 70, 15)//"show ledger account description:"
        oSay := tSay():New(35, 540, {|| IIf(cLedAccDsc == "1", SubStr(STR0081, 03), SubStr(STR0082, 03)) }, oPanelBC, , oFont2, , , , .T., CLR_RED, , 145, 15)

        /*************************************************************************************************//*
        
        Add here the treatment to result be equal CTBRT051, for that we decide:
          1-leave the report without change  (querys before)
          2-add heve the all combinations that we found at CVX (acc cube)
          3-join this 2 query: moviments at CT2 + all combinations at CVX
          4-make a sum/distinct of the results to get only one line for each conbination
        
            when we loop the register the funciton SldAnt will get the balance for each combination

        *//*************************************************************************************************/
        cQuery :=" SELECT ACCOUNT,SUPACC,CT1CLASSE, "
        If (cLedAccDsc == "2")//Ledge Account Description
            cQuery +=" ACCDESCR, "
        EndIf
        For nX := 2 To Len(aLevelsEn) //Selected Entities
            cQuery +=" "+aLevelsEn[nX][1][1]+", "
        Next nX
        cQuery +=" MAX(TYPEBAL) as TYPEBAL,  " //need put max here becouse from CVX we dont have that information(came from CT2)
        cQuery +=" NORMALDB, SUM(DEBITVAL) AS DEBITVAL, SUM(CREDITVAL) AS CREDITVAL " + CRLF
        cQuery +=" from ( " + CRLF
            //account with moviments at CT2
            cQuery +="	SELECT ACCOUNT,SUPACC,CT1CLASSE, "
            If (cLedAccDsc == "2")//Ledge Account Description
                cQuery +=" ACCDESCR, "
            EndIf
            For nX := 2 To Len(aLevelsEn)
                cQuery +=" "+aLevelsEn[nX][1][1]+", "
            Next nX
            /* Removed becouse we dont have yet the corresponding accounting configurated
            For nX := 01 To Len(aAddEcFld)
                cQuery += " 		EC"+aAddEcFld[nX] + ", "
                cQuery += " 		CEC"+aAddEcFld[nX] + ", "
            Next nX*/
            cQuery +=" TYPEBAL, NORMALDB,  SUM(DEBITVAL) AS DEBITVAL,  SUM(CREDITVAL) AS CREDITVAL "
            cQuery +=" FROM  " + CRLF
            cQuery +=" " + oDados:GetRealName() + " "
            cQuery +=" GROUP BY " + CRLF
            cQuery +=" ACCOUNT,SUPACC,CT1CLASSE, "
            If (cLedAccDsc == "2")//Ledge Account Description
                cQuery +=" ACCDESCR, "
            EndIf
            For nX := 2 To Len(aLevelsEn)
                cQuery +=" "+aLevelsEn[nX][1][1]+", "
            Next nX
            cQuery +=" TYPEBAL, NORMALDB  " + CRLF + CRLF
                        
            //Show balances withou moviments only if type balance is Real(selected at wizard) - here we get all information at CVX to be join with moviment
            If '1'$ alltrim(cBalType) //only real balance
                cQuery +=" UNION ALL "  + CRLF + CRLF//Jois the result query with all combinations

                //Join with all combination without moviment (make it equal to CTBR051)
                cQuery += "SELECT DISTINCT ACCOUNT,SUPACC,CT1CLASSE, " + CRLF
                If (cLedAccDsc == "2")//Ledge Account Description
                    cQuery +=" ACCDESCR, "
                EndIf
                For nX := 2 To Len(aLevelsEn)
                    cQuery +=" "+aLevelsEn[nX][1][1]+", " + CRLF
                Next nX
                cQuery +="	'1' as 	TYPEBAL,  NORMALDB,  	0 AS DEBITVAL,  0 AS CREDITVAL  FROM ( " + CRLF
                    //get all information at CVX
                    cQuery += "SELECT" + CRLF
                    cQuery += "	CVX.CVX_NIV01 ACCOUNT, CT1.CT1_CTASUP SUPACC,  CT1.CT1_CLASSE CT1CLASSE," + CRLF
                    cQuery +="	CT1_DESC01	ACCDESCR, CVX.CVX_NIV02 CUSTO," + CRLF
                    cQuery += "	CVX.CVX_NIV03 ITEM, CVX.CVX_NIV04 CLVL," + CRLF
                    For nX := 05 To nQtdEnt //Aditional entities
                        cQuery += "			CVX.CVX_NIV" + StrZero(nX, 02) + " EC"+StrZero(nX, 02)+", " + CRLF
                    Next nX
                    cQuery += "	CT1.CT1_NORMAL NORMALDB " + CRLF
                    cQuery += " FROM  " + RetSqlName("CVX") + " CVX " + CRLF
                    cQuery += " INNER JOIN " + RetSqlName("CT1") + " CT1 " + CRLF
                    cQuery += " 			ON ( CT1.CT1_FILIAL = " + FSFILCH("CT1","CT2","CT2.CT2_FILIAL") + " "
                    cQuery += " 			AND CT1.CT1_CONTA = CVX_NIV01 AND CT1.D_E_L_E_T_ = ' ' )   "
                    cQuery += " WHERE " + CRLF
                    cQuery += "	CVX_CONFIG = '" + StrZero(nQtdEnt, 02) + "' AND  CVX_MOEDA='" + cCurrency + "' and CVX.D_E_L_E_T_ = ' ' " + CRLF
                    If !(Empty(cFilFrom)) //branch Filter
                        cQuery += " 	  AND  CVX.CVX_FILIAL IN " + FormatIn(AllTrim(cFilFrom), ",") + " "
                    EndIf
                    cQuery += "				 AND CVX.CVX_DATA < '" + DTOS(dDateFrom)+ "' " //Date initial, for previus balance must be less than moviments
                    If Len(aCT1_CONTA) > 0
                        cQuery += " and CVX.CVX_NIV01 in ( "
                        For nX:=1 To Len(aCT1_CONTA)
                            If nX == Len(aCT1_CONTA)
                                cQuery += "'"+AllTrim(aCT1_CONTA[nX]) +"')"
                            Else
                                cQuery += "'"+AllTrim(aCT1_CONTA[nX]) +"',"
                            Endif
                        Next nX
                    Endif
                cQuery += " ) as TEMP " + CRLF
                If Len(aFiltersEn)  > 1 //Filter others entities 
                    cQuery += " WHERE " + CRLF
                    For nX:=2 To Len(aFiltersEn) //entities upper then accouting
                        cQuery += aFiltersEn[nX][1] + " BETWEEN '" + alltrim(aFiltersEn[nX][2]) + "' AND '" + aFiltersEn[nX][3] + iIf(nX ==  Len(aFiltersEn), "' ", "' AND ") //"' AND "
                    Next nX
                Endif                
            Endif
        cQuery +=" ) as temp2 " + CRLF
        cQuery +=" GROUP BY " + CRLF
        cQuery +=" ACCOUNT, SUPACC, CT1CLASSE,  "
        If (cLedAccDsc == "2")//Ledge Account Description
            cQuery +=" ACCDESCR, "
        EndIf
        For nX := 2 To Len(aLevelsEn) //Selected Entities
            cQuery +=" "+aLevelsEn[nX][1][1]+", "
        Next nX
        cQuery +=" NORMALDB ORDER BY " + CRLF
        cQuery +=" SUPACC, ACCOUNT, "
        For nX := 2 To Len(aLevelsEn)
            cQuery +=" "+aLevelsEn[nX][1][1]+", "
        Next nX
        cQuery +=" TYPEBAL  "

        cQuery := ChangeQuery(cQuery)
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDoc, .T., .F. )
        ProcRegua( 0 )

        oTempTable	:= FWTemporaryTable():New( cAreaRepp )
        aadd(aFields,{"ORDEM", "C", 02, 0, "Ordem", "@!"})
        aadd(aFields,{"ACCOUNT", "C",TamSX3("CT2_DEBITO")[1], 0, STR0003, "@!"})
        If (cLedAccDsc == "2")
            aadd(aFields,{"ACCDESCR", "C", TamSX3("CT1_DESC01")[01], TamSX3("CT1_DESC01")[02], STR0027, "@!"})
        EndIf
        For nX := 2 To Len(aLevelsEn)
            aadd(aFields, { aLevelsEn[nX][1][1], "C", TAMSX3(aLevelsEn[nX][1][5][1])[1], 0, aLevelsEn[nX][1][2], "@!" })
        Next nX
        /*For nX := 01 To Len(aAddEcFld)
            If (AScan(aFields, {|x| AllTrim(x[01]) == "EC" + aAddEcFld[nX]}) == 0)
                aadd(aFields, { "EC" + aAddEcFld[nX], "C", TAMSX3("CT2_EC" + aAddEcFld[nX] + "DB")[1], 0, STR0025 + " " + aAddEcFld[nX], "@!"})
            EndIf
        Next nX*/
        aadd(aFields, {"TYPEBAL", "C", TamSX3("CT2_TPSALD")[01], 0,alltrim(STR0004),"@!"} )
        aadd(aFields, {"NORMALDB", "C", TamSX3("CT1_NORMAL")[01], 0,STR0024,"@!"} )
        aadd(aFields, {"DEBITBEG", "N", 16, 2,STR0038 + STR0005	,"@E 999,999,999,999.99"} )
        aadd(aFields, {"CREDITBEG", "N", 16, 2,STR0038 + STR0006,"@E 999,999,999,999.99"} )
        aadd(aFields, {"DEBITVAL", "N", TamSX3("CT2_VALOR")[01], 2,STR0039 + STR0005,"@E 999,999,999,999.99"} )
        aadd(aFields, {"CREDITVAL", "N", TamSX3("CT2_VALOR")[01], 2,STR0039 + STR0006,"@E 999,999,999,999.99"} )
        aadd(aFields, {"DEBITEND", "N", TamSX3("CT2_VALOR")[01], 2,STR0040 + STR0005,"@E 999,999,999,999.99"} )
        aadd(aFields, {"CREDITEND", "N", TamSX3("CT2_VALOR")[01], 2,STR0040 + STR0006,"@E 999,999,999,999.99"} )
        aadd(aFields, {"CT1CLASSE", "C", 1, 0,STR0154,"@!"} )

        oTemptable:SetFields( aFields )
        nI:=1
        For nX:=1 to len(aFields) //fast searching
            If !(alltrim(aFields[nX, 01]) $ "NORMALDB/ORDEM/CUSTO/ITEM/CLVL/CT1CLASSE")
                oTempTable:AddIndex("indice"+alltrim(str(nI)), {aFields[nX][1]} )
                If (alltrim(aFields[nX, 01]) == "ACCOUNT")
                    cIndSub := "indice"+alltrim(str(nI))//get order for look accounting superior
                Endif
                nI++
            Endif
        Next nX
        
        oTempTable:Create()

        While !(cQryDoc)->(EOF())
            nRecCount++
            RecLock(cAreaRepp,.T.)
                (cAreaRepp)->ORDEM		:= StrZero(nRecCount, 2)
                (cAreaRepp)->ACCOUNT :=  (cQryDoc)->ACCOUNT
                (cAreaRepp)->CT1CLASSE :=  (cQryDoc)->CT1CLASSE
                //Ledge Account Description
                If (cLedAccDsc == "2")
                    (cAreaRepp)->ACCDESCR :=  (cQryDoc)->ACCDESCR
                EndIf
                For nX := 2 To Len(aLevelsEn)
                    (cAreaRepp)->&(aLevelsEn[nX][1][1]) :=  (cQryDoc)->&(aLevelsEn[nX][1][1])
                Next nX
                /*For nX := 01 To Len(aAddEcFld)
                    (cAreaRepp)->&("EC" + aAddEcFld[nX]) :=  (cQryDoc)->&("EC" + aAddEcFld[nX])
                    (cAreaRepp)->&("CEC" + aAddEcFld[nX]) :=  (cQryDoc)->&("CEC" + aAddEcFld[nX])
                Next nX*/
                (cAreaRepp)->TYPEBAL	:=	(cQryDoc)->TYPEBAL

                aBalBeg := SldAnt(cQryDoc,aSelFil) //return balance previously 

                (cAreaRepp)->DEBITVAL   :=  (cQryDoc)->DEBITVAL
                (cAreaRepp)->CREDITVAL  :=  (cQryDoc)->CREDITVAL    
                If ((cQryDoc)->NORMALDB == "1")
                    //For lines with CT1_NORMAL = 1 (Debit account) we should made calculation:
                    //Initial Debit := ( Debit - Credit ) and found the value for that column, on column credit the value should be 0. 
                    (cAreaRepp)->DEBITBEG  := aBalBeg[1] - aBalBeg[2]
                    (cAreaRepp)->CREDITBEG := 0                
                    (cAreaRepp)->DEBITEND	:=  (cAreaRepp)->DEBITBEG + (cAreaRepp)->DEBITVAL - (cQryDoc)->CREDITVAL
                    (cAreaRepp)->CREDITEND	:=  0 

                Else
                //For lines with CT1_NORMAL = 2 (Credit account) we should made calculation:
                //Initial Credit := (Credit - Debit) and found the value for that column, on column debit the value should be 0.
                    (cAreaRepp)->DEBITBEG  := 0
                    (cAreaRepp)->CREDITBEG := aBalBeg[2] - aBalBeg[1]
                    (cAreaRepp)->DEBITEND	:=  0
                    (cAreaRepp)->CREDITEND	:=  (cAreaRepp)->CREDITBEG + (cAreaRepp)->CREDITVAL - (cAreaRepp)->DEBITVAL
                EndIf
            MsUnlock()

            //Verify if summarized ledge account
            cSupAcc := (cQryDoc)->SUPACC
            nOrdem  := 1 
            If (cSumLedAcc == "2") .and. !Empty(cSupAcc)                 
                While .T. // look for superior accounts
                    nOrdem++ //Add level for sorting 

                    CT1->(DbSetOrder(1))
                    If CT1->(MsSeek( xFilial("CT1") + AllTrim(cSupAcc)) )
                        //check if add or edit
                        //get index for acc number                   
                        (cAreaRepp)->(DBSetOrder(aScan(oTempTable:ostruct:aindexes,{|x| upper(x[1]) == upper(cIndSub)}) ))
                        If ((cAreaRepp)->(DBSeek(CT1->CT1_CONTA))) //Fouded account, just add values
                            RecLock(cAreaRepp,.F.)
                                (cAreaRepp)->DEBITVAL   +=  (cQryDoc)->DEBITVAL
                                (cAreaRepp)->CREDITVAL  +=  (cQryDoc)->CREDITVAL
                                Do case
                                    case cGrBalance == "2" // parameter "Show Grouped balance" - Yes
                                        If (CT1->CT1_NORMAL == "1")
                                            //For lines with CT1_NORMAL = 1 (Debit account) we should made calculation:
                                            //Initial Debit := ( Debit - Credit ) and found the value for that column, on column credit the value should be 0. 
                                            (cAreaRepp)->DEBITBEG   += aBalBeg[1] - aBalBeg[2]
                                            (cAreaRepp)->CREDITBEG  += 0                                        
                                            (cAreaRepp)->DEBITEND	:=  (cAreaRepp)->DEBITBEG + (cAreaRepp)->DEBITVAL - (cQryDoc)->CREDITVAL
                                            (cAreaRepp)->CREDITEND	:=  0 
                                        Else
                                        //For lines with CT1_NORMAL = 2 (Credit account) we should made calculation:
                                        //Initial Credit := (Credit - Debit) and found the value for that column, on column debit the value should be 0.
                                            (cAreaRepp)->DEBITBEG   += 0
                                            (cAreaRepp)->CREDITBEG  += aBalBeg[2] - aBalBeg[1]
                                            (cAreaRepp)->DEBITEND	:=  0
                                            (cAreaRepp)->CREDITEND	:=  (cAreaRepp)->CREDITBEG + (cAreaRepp)->CREDITVAL - (cAreaRepp)->DEBITVAL
                                        EndIf
                                    Otherwise
                                        (cAreaRepp)->DEBITBEG   += aBalBeg[1]
                                        (cAreaRepp)->CREDITBEG  += aBalBeg[2]
                                        (cAreaRepp)->DEBITEND	:=  (cAreaRepp)->DEBITBEG + (cAreaRepp)->DEBITVAL
                                        (cAreaRepp)->CREDITEND	:=  (cAreaRepp)->CREDITBEG + (cAreaRepp)->CREDITVAL
                                EndCase                            
                            MsUnlock()
                        Else // new account
                            RecLock(cAreaRepp,.T.)
                                (cAreaRepp)->ORDEM		:= StrZero(nOrdem, 2)
                                //(cAreaRepp)->FILIAL		:= (cQryDoc)->FILIAL
                                (cAreaRepp)->ACCOUNT    :=  CT1->CT1_CONTA
                                (cAreaRepp)->CT1CLASSE  :=  CT1->CT1_CLASSE
                                //Ledge Account Description
                                If (cLedAccDsc == "2")
                                    (cAreaRepp)->ACCDESCR := CT1->CT1_DESC01
                                EndIf
                                (cAreaRepp)->TYPEBAL	:=	(cQryDoc)->TYPEBAL
                                (cAreaRepp)->DEBITVAL   :=  (cQryDoc)->DEBITVAL
                                (cAreaRepp)->CREDITVAL  :=  (cQryDoc)->CREDITVAL
                                Do case
                                    case cGrBalance == "2" // parameter "Show Grouped balance" - Yes
                                        If ((cQryDoc)->NORMALDB == "1")
                                            //For lines with CT1_NORMAL = 1 (Debit account) we should made calculation:
                                            //Initial Debit := ( Debit -½ Credit ) and found the value for that column, on column credit the value should be 0. 
                                            (cAreaRepp)->DEBITBEG   := aBalBeg[1] - aBalBeg[2]
                                            (cAreaRepp)->CREDITBEG  := 0                                        
                                            (cAreaRepp)->DEBITEND	:=  (cAreaRepp)->DEBITBEG + (cAreaRepp)->DEBITVAL - (cQryDoc)->CREDITVAL
                                            (cAreaRepp)->CREDITEND	:=  0 
                                        Else
                                        //For lines with CT1_NORMAL = 2 (Credit account) we should made calculation:
                                        //Initial Credit := (Credit - Debit) and found the value for that column, on column debit the value should be 0.
                                            (cAreaRepp)->DEBITBEG   := 0
                                            (cAreaRepp)->CREDITBEG  := aBalBeg[2] - aBalBeg[1]
                                            (cAreaRepp)->DEBITEND	:=  0
                                            (cAreaRepp)->CREDITEND	:=  (cAreaRepp)->CREDITBEG + (cAreaRepp)->CREDITVAL - (cAreaRepp)->DEBITVAL
                                        EndIf
                                    Otherwise
                                        (cAreaRepp)->DEBITBEG   := aBalBeg[1]
                                        (cAreaRepp)->CREDITBEG  := aBalBeg[2]
                                        (cAreaRepp)->DEBITEND	:=  (cAreaRepp)->DEBITBEG + (cAreaRepp)->DEBITVAL
                                        (cAreaRepp)->CREDITEND	:=  (cAreaRepp)->CREDITBEG + (cAreaRepp)->CREDITVAL
                                EndCase                            
                            MsUnlock()
                        Endif                          
                    EndIf
                    If Empty(CT1->CT1_CTASUP)
                        Exit
                    Else
                        cSupAcc := CT1->CT1_CTASUP
                    EndIf
                EndDo
            EndIf

            (cQryDoc)->(DbSkip())
            IncProc(STR0066+AllTrim(STR(nRecCount)))
        EndDo

        cAliasAtu := cAreaRepp

        oPanel := tPanel():New(0,0,,oPanelBrw,,,,,,0,0)
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT
        oPanel:lVisible:= .F.

        aStruct :=  aClone(aFields)

        aSeek := {}
        nX:=1
        For nI:=1 to len(aFields)
            If !(alltrim(aFields[nI, 01]) $ "NORMALDB/ORDEM/CUSTO/ITEM/LEGEND/CT1CLASSE")//Fixed crash by adding LEGEND
                Aadd(aSeek,{aFields[nI][5] ,{{"", aFields[nI][2] , aFields[nI][3] , aFields[nI][4] , aFields[nI][5] , aFields[nI][6] }}, nX, .T. } )//Fixed mask
                nX++
            Endif
        next nI

        nCol := 1
        a2Fields := {}
        For nI := 1 to Len(aStruct)
            if !(aStruct[nI, 01] $ "NORMALDB/ORDEM/CT1CLASSE")
                bField := &(" {|| " + cAreaRepp + "->" + aStruct[nI][01] + "}")

                aAdd(a2Fields,FWBrwColumn():New())
                a2Fields[nCol]:SetData(bField)
                a2Fields[nCol]:SetTitle(aStruct[nI, 05])
                a2Fields[nCol]:SetPicture(aStruct[nI, 06])
                a2Fields[nCol]:SetType(aStruct[nI, 02])
                Do Case
		        Case aStruct[nI, 01] == "ACCDESCR"
                    a2Fields[nCol]:SetSize(aStruct[nI, 03])
		        Case aStruct[nI, 01] == "TYPEBAL"
                    a2Fields[nCol]:SetSize(1)
		        Otherwise
                    a2Fields[nCol]:SetSize(aStruct[nI, 03]*0,75)
	            EndCase
                a2Fields[nCol]:SetDoubleClick(bDoubleCli)
                If aStruct[nI, 02] == "N"
                    a2Fields[nCol]:SetAlign(2)
                EndIf
                a2Fields[nCol]:SetReadVar(aStruct[nI][01])

                Aadd(aColFilter,{aStruct[nI][1],aStruct[nI][5],aStruct[nI][2],aStruct[nI][3],aStruct[nI][4],aStruct[nI][6]})
                nCol++
            Endif
        Next nX

        oFWBrow := FWFormBrowse():New()
        oFWBrow:SetAlias(cAreaRepp) //Temporary Table Alias
        oFWBrow:SetDataTable(.T.)
        oFWBrow:SetTemporary(.T.) //Using Temporary Table

        oFWBrow:DisableDetails()
        oFWBrow:SetOwner(oPanel)
        oFWBrow:DisableReport()

        oFWBrow:AddLegend( "CT1CLASSE == '1'", "GREEN"  , STR0113    )
        oFWBrow:AddLegend( "CT1CLASSE <> '1'", "ORANGE" , STR0114   )
        oFWBrow:SetColumns(a2Fields)

        // Filter definitions        
        oFWBrow:SetSeek(,aSeek)//Field at Browse == Important == Fields at aSeek are displayed at folder Key, Index at temporary table define the fieds at folder Column 
        oFWBrow:SetProfileID("RU34S10FI2")
        oFWBrow:SetUseCaseFilter(.T.)
        oFWBrow:SetUseFilter(.T.)
        oFWBrow:SetDBFFilter(.T.)
        oFWBrow:SetFieldFilter(aColFilter) //field displayed at filter popup called at button "Filter" at folder

        //Activate
        oFWBrow:Activate(oPanel)
        oPanel:lVisible:= .T.

        Activate MsDialog oMainDlg ON INIT (EnchoiceBar(oMainDlg, {||oMainDlg:End()}, {||oMainDlg:End()}, ,aButtons,,,.F.,.F.,.F.,.F.,.F.)) CENTERED
    Else
        MsgInfo(STR0045, STR0046)//"The filters selected does not brought results."#"No Results Found"
    Endif

Return NIL

//-----------------------------------------------------------------------
/*/{Protheus.doc} CreateQry()

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function CreateQry()
    Local cWorkArea	as character
    Local cQryDoc	as character
    Local oWorkArea	As Object
    Local aFields	as array
    Local aAddEcFld	as array
    Local aBalBeg	as array
    Local cQuery 	as character
    Local c1Query 	as character
    Local c2Query 	as character
    Local nX		as numeric
    Local nI		as numeric
    Local nOrdem	as numeric
    LOCAL nPosTPS	as numeric
    Local aAccounts	as array

    cWorkArea	:= GetNextAlias()
    cQryDoc		:= GetNextAlias()
    oWorkArea	:= FWTemporaryTable():New( cWorkArea )
    aFields		:= {}
    aAddEcFld	:= {}
    aBalBeg		:= {}
    aAccounts	:= {}
    nX			:= 1
    nPosTPS		:= 0

    //Verify aditional
    CT0->(DbSetOrder(1))    //CT0_FILIAL+CT0_ID
    CT0->(DbGoTop())
    While !CT0->(Eof()) .And. CT0->CT0_FILIAL == xFilial("CT0")
        If !Empty(aScan(aLevelTabE,{|x| UPPER(x[1]) == UPPER(CT0->CT0_ALIAS)})) .And. !Empty(CT0->CT0_ENTIDA)
            aAdd(aAddEcFld,AllTrim(CT0->CT0_ID))
        Endif
        CT0->(DbSkip())
    EndDo

    cQuery := " SELECT FILIAL, "
    cQuery += " 	NORMALDB,    "
    cQuery += " 	ACCOUNT,SUPACC, "
    
    //Ledge Account Description
    If (cLedAccDsc == "2")
        cQuery += "     ACCDESCR, "
    EndIf

    For nX:= 1 To Len(aAddEcFld)
        cQuery +=  iif (cSumLedAcc == "2", " COALESCE(EC" + aAddEcFld[nX] + "SUP, '') AS ", "" ) + " EC"+aAddEcFld[nX]+", "

        cQuery +=  iif (cSumLedAcc == "2", " COALESCE(CEC"+aAddEcFld[nX]+"SUP,'') AS ", "" ) + " CEC"+aAddEcFld[nX]+", "
    Next nX

    cQuery += " 	TYPEBAL,   "
    cQuery += " 	CUSTO,   "
    cQuery += " 	ITEM,   "
    cQuery += " 	CLVL,   "
    cQuery += " 	SUM(CT2SEL.DEBITVAL)  AS DEBITVAL,   "
    cQuery += " 	SUM(CT2SEL.CREDITVAL) AS CREDITVAL,   "
    cQuery += " CT1CLASSE"
    cQuery += " FROM 1SQL2CRUNCH3 "

    c1Query:= "SELECT CT2.CT2_FILIAL  AS FILIAL,   "
    c1Query += " 			 CT1D.CT1_CTASUP    AS SUPACC,   "
    c1Query += " 			 CT1D.CT1_NORMAL    AS NORMALDB,   "
    c1Query += " 			 CT2.CT2_DEBITO     AS ACCOUNT, "

    //Ledge Account Description
    If (cLedAccDsc == "2")
        c1Query += " 			 CT1D.CT1_DESC01     AS ACCDESCR, "
    EndIf

    c1Query += " 			 CTTD.CTT_CCSUP     AS CCSUP,  "
    c1Query += " 			 CT2.CT2_CCD        AS CUSTO, "
    c1Query += " 			 CTDD.CTD_ITSUP     AS ITSUP, "
    c1Query += " 			 CT2.CT2_ITEMD      AS ITEM,   "
    c1Query += " 			 CTHD.CTH_CLSUP     AS CLSUP, "
    c1Query += " 			 CT2.CT2_CLVLDB     AS CLVL,   "
    c1Query += " 			 CT1D.CT1_CLASSE     AS CT1CLASSE,   "

    For nX:= 1 To Len(aAddEcFld)
        c1Query += " CASE COALESCE(CV0C"+aAddEcFld[nX]+".CV0_ENTSUP, ' ') WHEN ' ' THEN CT2.CT2_EC"+aAddEcFld[nX]+"DB ELSE CV0C"+aAddEcFld[nX]+".CV0_ENTSUP END AS EC" + aAddEcFld[nX] + "SUP,"
        c1Query += " 			 CT2.CT2_EC"+aAddEcFld[nX]+"DB AS EC"+aAddEcFld[nX]+", "

        c1Query += " CASE COALESCE(CV0D"+aAddEcFld[nX]+".CV0_ENTSUP, ' ') WHEN ' ' THEN CT2.CT2_EC"+aAddEcFld[nX]+"CR ELSE CV0D"+aAddEcFld[nX]+".CV0_ENTSUP END AS CEC" + aAddEcFld[nX] + "SUP,"
        c1Query += " 			 CT2.CT2_EC"+aAddEcFld[nX]+"CR 	AS CEC"+aAddEcFld[nX]+","
    Next nX

    c1Query += " 			 CT2.CT2_TPSALD     AS TYPEBAL,   "
    c1Query += " 			 SUM(CT2.CT2_VALOR) AS DEBITVAL,   "
    c1Query += " 			 0                  AS CREDITVAL   "
    c1Query += " 	  FROM   " + RetSqlName("CT2") + " CT2   "
    c1Query += " 			 INNER JOIN " + RetSqlName("CT1") + " CT1D   "
    c1Query += " 					 ON ( CT1D.CT1_FILIAL = " + FSFILCH("CT1","CT2","CT2.CT2_FILIAL") + " "
    c1Query += " 						  AND CT1D.CT1_CONTA = CT2.CT2_DEBITO   "
    c1Query += " 						  AND CT1D.D_E_L_E_T_ = ' ' )   "
    c1Query += " 			 LEFT JOIN " + RetSqlName("CTT") + " CTTD   "
    c1Query += " 					 ON ( CTTD.CTT_FILIAL = " + FSFILCH("CTT","CT2","CT2.CT2_FILIAL")  + " "
    c1Query += " 						  AND CTTD.CTT_CUSTO = CT2.CT2_CCD "
    c1Query += " 						  AND CTTD.D_E_L_E_T_ = ' ' ) "
    c1Query += " 			 LEFT JOIN " + RetSqlName("CTD") + " CTDD   "
    c1Query += " 					 ON ( CTDD.CTD_FILIAL = " + FSFILCH("CTD","CT2","CT2.CT2_FILIAL") + " "
    c1Query += " 						  AND CTDD.CTD_ITEM = CT2.CT2_ITEMD "
    c1Query += " 						  AND CTDD.D_E_L_E_T_ = ' ' ) 	 		    "
    c1Query += " 			 LEFT JOIN " + RetSqlName("CTH") + " CTHD   "
    c1Query += " 					 ON ( CTHD.CTH_FILIAL = " + FSFILCH("CTH","CT2","CT2.CT2_FILIAL") + " "
    c1Query += " 						  AND CTHD.CTH_CLVL = CT2.CT2_CLVLDB "
    c1Query += " 						  AND CTHD.D_E_L_E_T_ = ' ' ) 	 		    "

    For nX:= 1 To Len(aAddEcFld)
        c1Query += " 			 LEFT JOIN " + RetSqlName("CV0") + "	 CV0C"+aAddEcFld[nX]+"	  	"
        c1Query += " 					 ON ( CV0C" + aAddEcFld[nX] + ".CV0_FILIAL = " + FSFILCH("CV0","CT2","CT2.CT2_FILIAL") + " "
        c1Query += " AND CV0C" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "DB AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR") + "' "
       /* c1Query += iif(cSumLedAcc == "2", " AND CV0C" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "DB AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR") + "' ", ; // 05 - in param
                                            "  AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = CT2.CT2_EC" + aAddEcFld[nX] + "DB ")*/
        c1Query += "                        AND CV0C" + aAddEcFld[nX] + ".D_E_L_E_T_ = ' ' )  "
        c1Query += "				LEFT JOIN " + RetSqlName("CV0") + " CV0D" + aAddEcFld[nX]+"		"
        c1Query += "                   ON ( CV0D"+aAddEcFld[nX] + ".CV0_FILIAL = " + FSFILCH("CV0","CT2","CT2.CT2_FILIAL") + " "
        c1Query += " AND CV0D" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "CR AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' "
        /*c1Query += iif(cSumLedAcc == "2", " AND CV0D" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "CR AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' ", ; // 05 - in param
                                            "  AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = CT2.CT2_EC" + aAddEcFld[nX] + "CR ")*/
        c1Query += "                        AND CV0D" + aAddEcFld[nX] + ".D_E_L_E_T_ = ' ' )  "
    Next nX

    If !(Empty(cFilFrom))
        c1Query += " 	  WHERE  CT2.CT2_FILIAL IN " + FormatIn(AllTrim(cFilFrom), ",") + " "
    EndIf

    c1Query += " 			 AND CT2.CT2_DC IN ( '1', '3' )   "
    c1Query += "				 AND CT2.CT2_DATA BETWEEN '" + DTOS(dDateFrom)+ "' AND '" + DTOS(dDateTo)+ "' "
    c1Query += "				 AND CT2.CT2_MOEDLC = '" + cCurrency + "' "

    IF !EMPTY(cBalType)
        IF AT("-", cBalType) != 0
            nPosTPS := AT( "-", cBalType)
            c1Query += " AND CT2.CT2_TPSALD BETWEEN '" + SUBSTR( cBalType, 1, nPosTPS-1) + "' AND '" + SUBSTR( cBalType, nPosTPS+1,Len(cBalType)-1 ) + "' "
        ELSE
            c1Query += " AND CT2.CT2_TPSALD IN " + formatIN(Alltrim(cBalType),";") + " "
        ENDIF
    ENDIF

    c1Query += " 			 AND CT2.D_E_L_E_T_ = ' '   "
    c1Query += " 	  GROUP  BY CT2.CT2_FILIAL,   "
    c1Query += " 				CT1D.CT1_CTASUP,   "
    c1Query += " 				CT1D.CT1_NORMAL,   "
    c1Query += " 				CT2.CT2_DEBITO, "

    //Ledge Account Description
    If (cLedAccDsc == "2")
        c1Query += "     CT1D.CT1_DESC01, "
    EndIf

    c1Query += " 				CTDD.CTD_ITSUP,  "
    c1Query += " 				CT2.CT2_ITEMD,  "
    c1Query += " 				CTTD.CTT_CCSUP,   "
    c1Query += " 				CT2.CT2_CCD,   "
    c1Query += " 				CTHD.CTH_CLSUP,   "
    c1Query += " 				CT2.CT2_CLVLDB,   "

    For nX:= 1 To Len(aAddEcFld)
        c1Query += " 				CV0C"+aAddEcFld[nX]+".CV0_ENTSUP, "
        c1Query += " 				CT2.CT2_EC"+aAddEcFld[nX]+"DB,    "

        c1Query += " 				CV0D"+aAddEcFld[nX]+".CV0_ENTSUP,	"
        c1Query += " 				CT2.CT2_EC"+aAddEcFld[nX]+"CR,		"
    Next nX

    c1Query += " 				CT2.CT2_TPSALD,CT1D.CT1_CLASSE
    c1Query:=ChangeQuery(c1Query)

    c2Query := " 	 SELECT CT2.CT2_FILIAL    AS FILIAL,   "
    c2Query += " 			 CT1C.CT1_CTASUP   AS SUPACC,   "
    c2Query += " 			 CT1C.CT1_NORMAL   AS NORMALDB,   "
    c2Query += " 			 CT2.CT2_CREDIT    AS ACCOUNT, "

    //Ledge Account Description
    If (cLedAccDsc == "2")
        c2Query += " 			 CT1C.CT1_DESC01     AS ACCDESCR, "
    EndIf

    c2Query += " 			 CTTC.CTT_CCSUP    AS CCSUP,   "
    c2Query += " 			 CT2.CT2_CCC       AS CUSTO,  "
    c2Query += " 			 CTDD.CTD_ITSUP    AS ITSUP,    "
    c2Query += " 			 CT2.CT2_ITEMC     AS ITEM,    "
    c2Query += " 			 CTHC.CTH_CLSUP    AS CLSUP, "
    c2Query += " 			 CT2.CT2_CLVLCR    AS CLVL,   "
    c2Query += " 			 CT1C.CT1_CLASSE     AS CT1CLASSE,   "

    For nX:= 1 To Len(aAddEcFld)
        c2Query += " CASE COALESCE(CV0C"+aAddEcFld[nX]+".CV0_ENTSUP, ' ') WHEN ' ' THEN CT2.CT2_EC"+aAddEcFld[nX]+"CR ELSE CV0C"+aAddEcFld[nX]+".CV0_ENTSUP END AS EC" + aAddEcFld[nX] + "SUP ,"
        c2Query += " 			 CT2.CT2_EC"+aAddEcFld[nX]+"CR		AS EC"+aAddEcFld[nX]+",		"

        c2Query += " CASE COALESCE(CV0D"+aAddEcFld[nX]+".CV0_ENTSUP, ' ') WHEN ' ' THEN CT2.CT2_EC"+aAddEcFld[nX]+"DB ELSE CV0D"+aAddEcFld[nX]+".CV0_ENTSUP END AS CEC" + aAddEcFld[nX] + "SUP,"
        c2Query += " 			 CT2.CT2_EC"+aAddEcFld[nX]+"DB   AS CEC"+aAddEcFld[nX]+",		"
    Next nX

    c2Query += " 			 CT2.CT2_TPSALD     AS TYPEBAL,   "
    c2Query += " 			 0                  AS DEBITVAL,   "
    c2Query += " 			 SUM(CT2.CT2_VALOR) AS CREDITVAL   "
    c2Query += " 	  FROM   " + RetSqlName("CT2") + " CT2   "
    c2Query += " 			 INNER JOIN " + RetSqlName("CT1") + " CT1C   "
    c2Query += " 					 ON ( CT1C.CT1_FILIAL = " + FSFILCH("CT1","CT2","CT2.CT2_FILIAL") + " "
    c2Query += " 						  AND CT1C.CT1_CONTA = CT2.CT2_CREDIT   "
    c2Query += " 						  AND CT1C.D_E_L_E_T_ = ' ' )   "
    c2Query += " 			 LEFT JOIN " + RetSqlName("CTT") + " CTTC   "
    c2Query += " 					 ON ( CTTC.CTT_FILIAL = " + FSFILCH("CTT","CT2","CT2.CT2_FILIAL") + " "
    c2Query += " 						  AND CTTC.CTT_CUSTO = CT2.CT2_CCC "
    c2Query += " 						  AND CTTC.D_E_L_E_T_ = ' ' )  "
    c2Query += " 			 LEFT JOIN " + RetSqlName("CTD") + " CTDD   "
    c2Query += " 					 ON ( CTDD.CTD_FILIAL = " + FSFILCH("CTD","CT2","CT2.CT2_FILIAL") + " "
    c2Query += " 						  AND CTDD.CTD_ITEM = CT2.CT2_ITEMD "
    c2Query += " 						  AND CTDD.D_E_L_E_T_ = ' ' ) 	 "
    c2Query += " 			 LEFT JOIN " + RetSqlName("CTH") + " CTHC   "
    c2Query += " 					 ON ( CTHC.CTH_FILIAL = " + FSFILCH("CTH","CT2","CT2.CT2_FILIAL") + " "
    c2Query += " 						  AND CTHC.CTH_CLVL = CT2.CT2_CLVLCR"
    c2Query += " 						  AND CTHC.D_E_L_E_T_ = ' ' ) 	 		    "

    For nX:= 1 To Len(aAddEcFld)
        c2Query += " 			 LEFT JOIN " + RetSqlName("CV0") + "  CV0C"+aAddEcFld[nX]+" "
        c2Query += " 					 ON ( CV0C"+aAddEcFld[nX]+".CV0_FILIAL = " + FSFILCH("CV0","CT2","CT2.CT2_FILIAL") + " "
        c2Query += " AND CV0C" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "DB AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' "
        /*c2Query += iif(cSumLedAcc == "2", " AND CV0C" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "DB AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' ", ; // 05 - in param
                                            "  AND CV0C" + aAddEcFld[nX] + ".CV0_PLANO = CT2.CT2_EC" + aAddEcFld[nX] + "DB ")*/
        c2Query += " 						  AND CV0C"+aAddEcFld[nX]+".D_E_L_E_T_ = ' ' )"
        c2Query += " 			 LEFT JOIN " + RetSqlName("CV0") + "  CV0D"+aAddEcFld[nX]+"		"
        c2Query += " 					 ON ( CV0D"+aAddEcFld[nX]+".CV0_FILIAL = " + FSFILCH("CV0","CT2","CT2.CT2_FILIAL") + " "
        c2Query += " AND CV0D" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "CR AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' "
        /*c2Query += iif(cSumLedAcc == "2", " AND CV0D" + aAddEcFld[nX] + ".CV0_CODIGO = CT2.CT2_EC" + aAddEcFld[nX] + "CR AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = '"+ GetMv("MV_R34CORR")+ "' ", ; // 05 - in param
                                            "  AND CV0D" + aAddEcFld[nX] + ".CV0_PLANO = CT2.CT2_EC" + aAddEcFld[nX] + "CR ")*/
        c2Query += " 						  AND CV0D"+aAddEcFld[nX]+".D_E_L_E_T_ = ' ' )"
    Next nX

    If !(Empty(cFilFrom))
        c2Query += " 	  WHERE  CT2.CT2_FILIAL IN " + FormatIn(AllTrim(cFilFrom), ",") + " "
    EndIf

    c2Query += " 			 AND CT2.CT2_DC IN ( '2', '3' )   "
    c2Query += "				 AND CT2.CT2_DATA BETWEEN '" + DTOS(dDateFrom)+ "' AND '" + DTOS(dDateTo)+ "' "
    c2Query += "				 AND CT2.CT2_MOEDLC = '" + cCurrency + "' "

    IF !EMPTY(cBalType)
        IF AT("-", cBalType) != 0
            nPosTPS := AT( "-", cBalType)
            c2Query += " AND CT2.CT2_TPSALD BETWEEN '" + SUBSTR( cBalType, 1, nPosTPS-1) + "' AND '" + SUBSTR( cBalType, nPosTPS+1,Len(cBalType)-1 ) + "' "
        ELSE
            c2Query += " AND CT2.CT2_TPSALD IN " + formatIN(Alltrim(cBalType),";") + " "
        ENDIF
    ENDIF
    c2Query += " 			 AND CT2.D_E_L_E_T_ = ' '   "
    c2Query += " 	  GROUP  BY CT2.CT2_FILIAL,   "
    c2Query += " 				CT1C.CT1_CTASUP,   "
    c2Query += " 				CT1C.CT1_NORMAL,   "
    c2Query += " 				CT2.CT2_CREDIT,  "

    //Ledge Account Description
    If (cLedAccDsc == "2")
        c2Query += "     CT1C.CT1_DESC01, "
    EndIf

    c2Query += " 				CTTC.CTT_CCSUP, "
    c2Query += " 				CT2.CT2_CCC, "
    c2Query += " 				CTDD.CTD_ITSUP,   "
    c2Query += " 				CT2.CT2_ITEMC,   "
    c2Query += " 				CTHC.CTH_CLSUP,   "
    c2Query += " 				CT2.CT2_CLVLCR,   "

    For nX:= 1 To Len(aAddEcFld)
        c2Query += " 				CV0C"+aAddEcFld[nX]+".CV0_ENTSUP,	"
        c2Query += " 				CT2.CT2_EC"+aAddEcFld[nX]+"CR,		"

        c2Query += " 				CV0D"+aAddEcFld[nX]+".CV0_ENTSUP,	"
        c2Query += " 				CT2.CT2_EC"+aAddEcFld[nX]+"DB,		"
    Next nX

    c2Query += " 				CT2.CT2_TPSALD,CT1C.CT1_CLASSE "
    c2Query:=ChangeQuery(c2Query)

    If Len(aFiltersEn) > 0 .Or. Len(aCT1_CONTA) > 0
        cQuery += " WHERE "
    EndIf
    
    For nX:=2 To Len(aFiltersEn)
        cQuery += aFiltersEn[nX][1] + " BETWEEN '" + aFiltersEn[nX][2] + "' AND '" + aFiltersEn[nX][3] + iIf(nX ==  Len(aFiltersEn), "' ", "' AND ") //"' AND "
    Next nX
    
    If Len(aFiltersEn) > 0 .and. Len(aCT1_CONTA) > 0
        cQuery += " AND "
    EndIf

    If Len(aCT1_CONTA) > 0
        For nX:=1 To Len(aCT1_CONTA)
            CT1Sup(aCT1_CONTA[nX],@aAccounts)
        Next nX
    Endif

    If Len(aAccounts) > 0
        cQuery += " ACCOUNT IN ("
        For nX:=1 To Len(aAccounts)
            If nX == Len(aAccounts)
                cQuery += "'"+AllTrim(aAccounts[nX]) +"')"
            Else
                cQuery += "'"+AllTrim(aAccounts[nX]) +"',"
            Endif
        Next nX
    Endif

    cQuery += " GROUP  BY FILIAL,      "
    cQuery += " 		NORMALDB,    "
    cQuery += " 		ACCOUNT, "
    cQuery += " 		SUPACC, "

    //Ledge Account Description
    If (cLedAccDsc == "2")
        cQuery += "     ACCDESCR, "
    EndIf

    cQuery += " 		CUSTO, "
    cQuery += " 		ITEM, "
    cQuery += " 		CLVL, "
    cQuery += " 		CT1CLASSE, "

    For nX:= 1 To Len(aAddEcFld)
        cQuery += " 		EC"+aAddEcFld[nX]+ iif(cSumLedAcc == "2", "SUP, ", ", ")

        cQuery += " 		CEC"+aAddEcFld[nX]+iif(cSumLedAcc == "2", "SUP, ", ", ")
    Next nX

    cQuery += " 		TYPEBAL "
    cQuery += " ORDER  BY FILIAL, "
    cQuery += " 	   TYPEBAL, "
    cQuery += " 	   SUPACC,ACCOUNT "

    cQuery := ChangeQuery(cQuery)
    cQuery:= Substr(cQuery,1,AT("1SQL2CRUNCH3",cQuery)-1) + " ( ( " + c1Query + " ) UNION ALL ( " + c2Query + ")) AS CT2SEL   " + Substr(cQuery,AT("1SQL2CRUNCH3",cQuery)+12,len(cQuery))

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDoc, .T., .F. )

    If !(cQryDoc)->(EOF())
        aadd(aFields,{"ORDEM", "C", 02, 0})
        aadd(aFields,{"FILIAL", "C", TAMSX3("CT2_FILIAL")[1], 0})
        aadd(aFields,{"ACCOUNT", "C", TAMSX3("CT2_DEBITO")[1], 0})
        aadd(aFields,{"SUPACC", "C", TAMSX3("CT1_CTASUP")[1], 0})
        aadd(aFields,{"CT1CLASSE", "C", TAMSX3("CT1_CLASSE")[1], 0})

        //Ledge Account Description
        If (cLedAccDsc == "2")
            aadd(aFields,{"ACCDESCR", "C", TAMSX3("CT1_DESC01")[01], TAMSX3("CT1_DESC01")[02]})
        EndIf

        For nX := 2 To Len(aLevelsEn)
            AAdd(aFields,{aLevelsEn[nX][1][1], "C", TAMSX3(aLevelsEn[nX][1][5][1])[1], 0})
        Next nX

        For nX:= 1 To Len(aAddEcFld)
            If (AScan(aFields, {|x| AllTrim(x[01]) == "EC"+aAddEcFld[nX]}) == 0)
                aadd(aFields,{"EC"+aAddEcFld[nX], "C", TAMSX3("CT2_EC"+aAddEcFld[nX]+"DB")[1], 0})
            EndIf

            If (AScan(aFields, {|x| AllTrim(x[01]) == "CEC"+aAddEcFld[nX]}) == 0)
                aadd(aFields,{"CEC"+aAddEcFld[nX], "C", TAMSX3("CT2_EC"+aAddEcFld[nX]+"DBCR")[1], 0})
            EndIf
        Next nX

        aadd(aFields, {"TYPEBAL", "C", 02, 0})
        aadd(aFields, {"NORMALDB", "C", 01, 0})

        //--Period
        aadd(aFields,{"DEBITVAL", "N", TAMSX3("CT2_VALOR")[1], 2})
        aadd(aFields,{"CREDITVAL", "N", TAMSX3("CT2_VALOR")[1], 2})


        oWorkArea:SetFields( aFields )
        nI:=1
        For nX:=1 to len(aFields)
            If !(alltrim(aFields[nX, 01]) $ "NORMALDB/ORDEM/CUSTO/ITEM/CLVL")
                oWorkArea:AddIndex("indice"+alltrim(str(nI)), {aFields[nX][1]} )
                nI++
            Endif
        Next nX
        
        oWorkArea:Create()

        //Add at temporary table
        While !(cQryDoc)->(EOF())
            nOrdem := 1
            RecLock(cWorkArea,.T.)
                (cWorkArea)->ORDEM      := StrZero(nOrdem, 2)
                (cWorkArea)->FILIAL     := (cQryDoc)->FILIAL
                (cWorkArea)->ACCOUNT    := (cQryDoc)->ACCOUNT
                (cWorkArea)->SUPACC     := (cQryDoc)->SUPACC
                (cWorkArea)->CT1CLASSE  := (cQryDoc)->CT1CLASSE

                //Ledge Account Description
                If (cLedAccDsc == "2")
                    (cWorkArea)->ACCDESCR := (cQryDoc)->ACCDESCR
                EndIf

                For nX := 2 To Len(aLevelsEn)
                     (cWorkArea)->&(aLevelsEn[nX][1][1]) := (cQryDoc)->&(aLevelsEn[nX][1][1])
                Next nX


                For nX:= 1 To Len(aAddEcFld)
                    (cWorkArea)->&("EC" + aAddEcFld[nX] ) := (cQryDoc)->&("EC"+aAddEcFld[nX])

                    (cWorkArea)->&("CEC"+aAddEcFld[nX]) := (cQryDoc)->&("CEC"+ aAddEcFld[nX])
                Next nX

                (cWorkArea)->TYPEBAL := (cQryDoc)->TYPEBAL
                (cWorkArea)->NORMALDB := (cQryDoc)->NORMALDB

                (cWorkArea)->DEBITVAL := (cQryDoc)->DEBITVAL/nDivide
                (cWorkArea)->CREDITVAL := (cQryDoc)->CREDITVAL/nDivide

            MsUnlock()
            
            (cQryDoc)->(DbSkip())
        EndDo

    Else
        oWorkArea:= NIL
    Endif

Return oWorkArea

//-------------------------------------------------------------------
Static Function RngFil()

    Local aAreaSM0	:= SM0->(GetArea())
    Local aRngFil	:= {}
    Local cQuery	:= ""
    Local cAlsQry	:= ""

    cQuery  := "SELECT M0_CODFIL"
    cQuery  += " FROM " + MPSysSqlName( "SM0" ) + " SM0"
    cQuery  += " WHERE D_E_L_E_T_= ' '"
    //cQuery  += "  WHERE M0_CODIGO = 'T1' AND M0_CODFIL BETWEEN '"+ cFilFrom + "' AND '" + cFilTo +"'"

    If !(Empty(cFilFrom))
        cQuery  += "  AND M0_CODIGO = '" + cEmpAnt + "' AND M0_CODFIL IN " + FormatIn(AllTrim(cFilFrom), ",") + " "
    EndIf

    cQuery  += "    ORDER BY M0_CODFIL "

    cAlsQry := ChangeQuery( cQuery )

    cAlsQry := MPSysOpenQuery( cQuery )

    While !(cAlsQry)->( Eof() )
        aAdd( aRngFil, (cAlsQry)->M0_CODFIL )
        (cAlsQry)->( dbSkip() )
    EndDo

    RestArea(aAreaSM0)

Return aRngFil

//-------------------------------------------------------------------
Static Function SldAnt(cAreaTmp,aBranches)
    Local aFldLevel	:= {}
    Local aSaldoAnt	:= {}
    Local aEntAdd	:= {}
    Local cMoeda	:= alltrim(cCurrency)
    Local cTpSaldo	:= cBalType
    Local dDataIni	:= dDateFrom
    Local nX:= 1
    Local oObjCubo
    
    aAdd(aEntAdd, left((cAreaTmp)->ACCOUNT+Space(TamSx3("CT2_DEBITO")[1]),TamSx3("CT2_DEBITO")[1]))//Accouting
    aAdd(aEntAdd, If(FieldPos("CUSTO") > 0, left((cAreaTmp)->CUSTO+Space(TamSx3("CT2_CCD")[1])      ,TamSx3("CT2_CCD")[1])      , "") ) //Cost center
    aAdd(aEntAdd, If(FieldPos("ITEM" ) > 0, left((cAreaTmp)->ITEM +Space(TamSx3("CT2_ITEMD")[1])    ,TamSx3("CT2_ITEMD")[1])    , "") )//Item
    aAdd(aEntAdd, If(FieldPos("CLVL" ) > 0, left((cAreaTmp)->CLVL +Space(TamSx3("CT2_CLVLDB")[1])   ,TamSx3("CT2_CLVLDB")[1])   , "") )//Class value

    For nX:=1 to nMaxLevelE
        If aLevelTabE[nX][1] == "CV0"
            aFldLevel := FldLevel(nX,"E")
              aAdd(aEntAdd, If(FieldPos(aFldLevel[1][1]) > 0,  left(alltrim((cAreaTmp)->&(aFldLevel[1][1]))+ Space(TamSx3("CV0_CODIGO")[1])   ,TamSx3("CV0_CODIGO")[1]) , "") )
        Endif
    Next nX

    //aEntVazio := Ctb_Vazio(aEntAdd)
    //aSaldoAnt := CtbSldCubo(aEntAdd,aEntAdd,Ctod("//"),dDataIni-1,cMoeda,cTpSaldo,aBranches,/*lMantemTmp*/,/*lBuscaExata*/, aEntVazio)
    //change for smilar approach that we have at report CTBR051, any question look that source
    aSaldoAnt := CTBS34(aEntAdd,aEntAdd,Ctod("//"),dDataIni-1, '0'+alltrim(str(len(aEntAdd))),cMoeda,cTpSaldo,aBranches,@oObjCubo) 
    oObjCubo:ErasedFiles()
Return aSaldoAnt


//-------------------------------------------------------------------
/*{Protheus.doc} CTBS34
Function responsable to get the previous balance for accoutin + entity level selected
-- This Function is similar that we have at CTBR051, if changes are necessary look this source --

@author Rafael Goncalves
@version MA3
@since   Jul/2020
@return  array with previous balance credit and debit
@obs
*/
//-------------------------------------------------------------------
Static Function CTBS34(aEntdIni,aEntdFim,dDataIni,dDataFim,cCodCubo,cMoeda,cTpSald,aSelFil, oObjCubo)
Local aDataIni	:= {}
Local aDataFim	:= {}
Local cArqTemp	:= ""   
Local cQry		:= "" 
Local cQryField := ""                  
Local nX		:= 0
Local nY		:= 0
Local nEntidade	:= Len(aEntdIni)
Local aTam		:= TamSx3('CT2_VALOR')  
Local nAntDeb := 0 //Debit 
Local nAntCrd := 0 //Credit

Default aSelFil := {cFilAnt}

// Dates to be used at cube
if Empty(dDataIni)
    AADD(aDataIni,Ctod("01/01/80"))		// Initial                                             
else
   AADD(aDataIni,dDataIni)		// Initial
Endif
AADD(aDataFim,dDataFim)				// Final

oObjCubo := Ctb_Exec_Cube():New(cCodCubo,cMoeda,cTpSald,nEntidade,Len(aDataFim))
oObjCubo:lZerado := .T.

cArqTemp :=  oObjCubo:CtbCriaTemp() 
                                             
For nY:=1 To nEntidade
	oObjCubo:Set_Level_Cube(nY)
                                                                                                     
	oObjCubo:oStructCube:Ctb_Set_IniParam(nY, aEntdIni[nY])         
	oObjCubo:oStructCube:Ctb_Set_FimParam(nY, aEntdFim[nY])			

	oObjCubo:CtbCriaQueryDim()
Next nY	

oObjCubo:Set_Level_Cube(nEntidade) 

oObjCubo:Set_aSelFil(aSelFil) 
                                    
oObjCubo:CtbCriaQry(.F./*lMoviments*/, aDataIni, aDataFim, cArqTemp, .T./*lAllNiveis*/, .F./* lFechamento*/)

oObjCubo:CtbPopulaTemp(cArqTemp) 

cQryField := ""
FOR nX := 1 TO Val(cCodCubo)
	cQryField += "CVX_NIV0"+ AllTrim(Str(nX)) + ", "
Next   
cQry += "Select CVX_FILIAL, "
cQry += "       CVX_CONFIG, "
cQry += "       CVX_MOEDA , "
cQry += "       CVX_TPSALD, "   
cQry += cQryField              
cQry += "       CVX_PROC ,  "       
cQry += "       CVX_NIVEL,  " 
cQry += "       CVX_IDPAI,  "
cQry += "       SUM( CVX_SLCR01 ) CVX_SLCR01, " 
cQry += "       SUM( CVX_SLDB01 ) CVX_SLDB01, " 
cQry += "       SUM( CVX_SALD01 ) CVX_SALD01 " 
cQry += " FROM "+cArqTemp   
/*Fiter according the entity selected*/
cQry += " WHERE  D_E_L_E_T_ = ' ' and CVX_MOEDA='" + alltrim(cCurrency) + "' "
FOR nX := 1 TO len(aEntdIni)
    If Len(aEntdIni[nX]) > 0
        cQry += " AND CVX_NIV0"+AllTrim(Str(nX))+ " = '" + aEntdIni[nX] + "' "
    Endif
Next   
cQry += " GROUP BY CVX_FILIAL, "
cQry += "          CVX_CONFIG, "
cQry += "          CVX_MOEDA , "
cQry += "          CVX_TPSALD, "   
cQry += cQryField              
cQry += "          CVX_PROC , "       
cQry += "          CVX_NIVEL, " 
cQry += "          CVX_IDPAI  " 

cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"cArqTmp",.T.,.F.)
TCSetField("cArqTmp","CVX_SLCR01", "N",aTam[1],aTam[2])	 
TCSetField("cArqTmp","CVX_SLDB01", "N",aTam[1],aTam[2])	
TCSetField("cArqTmp","CVX_SALD01", "N",aTam[1],aTam[2])	

DbSelectArea("cArqTmp")
DbGoTop()
//Sum values for combinations
While ("cArqTmp")->(!EOF())

    nAntCrd += cArqTmp->CVX_SLCR01
    nAntDeb += cArqTmp->CVX_SLDB01

    DbSelectArea("cArqTmp")
    ("cArqTmp")->(dbSkip())
EndDo

//Close temp area
If Select("cArqTmp") > 0
    DbSelectArea("cArqTmp")
    ("cArqTmp")->(DbCloseArea())
    Ferase("cArqTmp")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Return:                                             ³
//³ [1] Previous balance Debit                           ³
//³ [2] Previous balance Credit                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return {nAntDeb,nAntCrd}

//-----------------------------------------------------------------------
/*/{Protheus.doc} FldLevel

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function FldLevel(nLevel,cType)
    Local aFldLevel	as array

    aFldLevel	:= {}
    If cType == "E"
        aFldLevel := aLevelsEn[nLevel]
    Endif

Return aFldLevel

//-------------------------------------------------------------------
/*/{Protheus.doc} LastLevel()
Rotina que chama a nova tela

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LastLevel(cAliasTMP)
    Local aArea	as array

    aArea := GetArea()

    FWExecView(STR0018, "RU34S10", 3, , { || .T. } )//"Track"

    RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definiï¿½ï¿½o do modelo de Dados

@author Flavio Lopes

@since 25/01/2017
@version MA3
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
    Local oModel		As Object
    Local oStruSaldo	As Object
    Local oStruCT2		As Object

    oStruSaldo	:= MontaSCab()
    oStruCT2	:= FWFormStruct(1,"CT2",{ |cCpo| CT2->(FieldPos(ALLTRIM(cCpo))) > 0 .And. ALLTRIM(cCpo) $ Ct2Fields() })

    oModel := MPFormModel():New("RU34S10")

    oModel:SetDescription(STR0019)  //"Account Details"

    oStruCT2:AddField("R_E_C_N_O_","Recno CT2" , "R_E_C_N_O_", "C", 17 )

    oModel:addFields("SDOMASTER",,oStruSaldo,,,{|oModel|CargaCQ1(oModel)},,)
    oModel:addGrid("CT2DETAIL","SDOMASTER",oStruCT2,,,,,{|oModel| CargaCT2(oModel) })

    oModel:SetPrimaryKey({})

    oModel:getModel("SDOMASTER"):SetDescription(STR0020) //"Balance"
    oModel:getModel("CT2DETAIL"):SetDescription(STR0021) //"Entries"

    oModel:Activate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definiï¿½ï¿½o do interface

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

    Local oModel		As Object
    Local oStruSaldo	As Object
    Local oStruCT2		As Object
    Local coView 		as character
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oView			As Object

    oModel   	:= FWLoadModel( "RU34S10" )
    oStruSaldo	:= MontaVCab()
    oStruCT2	:= FWFormStruct(2, "CT2",{ |cCpo| CT2->(FieldPos(ALLTRIM(cCpo))) > 0 .And. ALLTRIM(cCpo) $ Ct2Fields() })

    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_CABEC" , oStruSaldo,"SDOMASTER" )
    oView:AddGrid("VIEW_CT2"  , oStruCT2,"CT2DETAIL")

    coView := oView:AVIEWS[2][1] //[3][1]

    oView:CreateHorizontalBox( "BOXFORM1", 35)
    oView:CreateHorizontalBox( "BOXFORM2", 65)

    oView:SetOwnerView("VIEW_CABEC","BOXFORM1")
    oView:SetOwnerView("VIEW_CT2","BOXFORM2")

    oView:EnableTitleView("VIEW_CABEC" , STR0020 )				//"Balance"
    oView:EnableTitleView("VIEW_CT2" , STR0021 )			//"Entries"

    oView:SetViewProperty("VIEW_CT2" , "GRIDVSCROLL", {.F.}  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSCab()
Retorna estrutura do tipo FWformModelStruct.

@author Flavio Lopes

@since 25/01/2017
@version MA3
/*/
//-------------------------------------------------------------------

Static function MontaSCab()
    Local oStruct	As Object
    Local nX		as numeric

    oStruct := FWFormStruct( 1,"SDOCTB", /*bAvalCampo*/, /*lViewUsado*/ )

    oStruct:AddTable("SDOCTB",{ "CODIGO", "DATA", "CREDITVAL", "DEBITVAL", "RECTMP" },STR0023 ) //"Account Ballance"

    //oStruct:AddField(STR0024,STR0024 , "FILIAL", "C",TamSx3("CT2_FILIAL")[1],,,,,,,.T. ) //"Branch"

    For nX := 1 To Len(aLevelsEn)
        oStruct:AddField(AllTrim(aLevelsEn[nX][1][2]),AllTrim(aLevelsEn[nX][1][2]) , AllTrim(aLevelsEn[nX][1][1]), "C",10,,,,,,,.T.,.F.) //'TESTE'
    Next nX

    //Dates
    oStruct:AddField(STR0028,STR0028 , "DATALANCI", "D",8 ) //"Date"
    oStruct:AddField(STR0028,STR0028 , "DATALANCF", "D",8 ) //"Date"

    oStruct:AddField(STR0029,STR0029 , "DEBITBEG", "N",16,2 ) //"Credit Balance"
    oStruct:AddField(STR0030,STR0030 , "CREDITBEG", "N",16,2 ) //"Debit Balance"
    //Balances
    oStruct:AddField(STR0029,STR0029 , "DEBITVAL", "N",16,2 ) //"Credit Balance"
    oStruct:AddField(STR0030,STR0030 , "CREDITVAL", "N",16,2 ) //"Debit Balance"

    oStruct:AddField(STR0029,STR0029 , "DEBITEND", "N",16,2 ) //"Credit Balance"
    oStruct:AddField(STR0030,STR0030 , "CREDITEND", "N",16,2 ) //"Debit Balance"

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVCab()
Retorna estrutura do tipo FWFormViewStruct.

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MontaVCab()
    Local oStruct	As Object
    Local nX		as numeric
    Local nOrd		as numeric

    oStruct := FWFormViewStruct():New()
    nOrd := 1

    //oStruct:AddField( "FILIAL"  , StrZero(nOrd,2) , STR0024,STR0024,, "Get" ,,,,.F.)//'TESTE' Branch

    For nX := 1 To Len(aLevelsEn)
        nOrd++
        oStruct:AddField( AllTrim(aLevelsEn[nX][1][1])  , StrZero(nOrd,2) , AllTrim(aLevelsEn[nX][1][2]),AllTrim(aLevelsEn[nX][1][2]),, "Get" ,,,,.F.)//'TESTE'
    Next nX

    nOrd++

    oStruct:AddField( "DATALANCI", StrZero(nOrd++,2) , STR0078,STR0078,, "Get" ,,,,.F.) //"Data" "Inicial Date"
    oStruct:AddField( "DATALANCF", StrZero(nOrd++,2), STR0079,STR0079,, "Get" ,,,,.F.) //"Data" "Final Date"

    //Balances
    oStruct:AddField( "CREDITBEG" , StrZero(nOrd++,2), STR0029,STR0029,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) //"Saldo Credito"
    oStruct:AddField( "DEBITBEG"  , StrZero(nOrd++,2), STR0030,STR0030,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) // "Saldo Debito"
    //Balances
    oStruct:AddField( "CREDITVAL" , StrZero(nOrd++,2), STR0029,STR0029,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) //"Saldo Credito"
    oStruct:AddField( "DEBITVAL"  , StrZero(nOrd++,2), STR0030,STR0030,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) // "Saldo Debito"
    //Balances
    oStruct:AddField( "CREDITEND" , StrZero(nOrd++,2), STR0029,STR0029,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) //"Saldo Credito"
    oStruct:AddField( "DEBITEND"  , StrZero(nOrd++,2), STR0030,STR0030,,"Get" ,"@E 99,999,999,999,999.99",,,.F.) // "Saldo Debito"

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaCQ1()
 Carga da Tabela de Saldos

@author wilson.possani

@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaCQ1(oModel)
    Local aAux	 	as array
    Local aField	as array
    Local cCredDeb	as character
    Local nX		as numeric
    Local cEntity	as character

    aAux	 	:= {}
    aField 		:= FldLevel(nMaxLevelE,"E")
    cCredDeb	:= If(Empty((cAliasAtu)->CREDITVAL),"D","C")

    //aAdd(aAux,(cAliasAtu)->FILIAL)
    For nX := 1 To Len(aLevelsEn)
        cEntity := AllTrim(aLevelsEn[nX][1][1])
        aAdd(aAux,(cAliasAtu)->&(cEntity))
    Next nX

    aAdd(aAux,dDateFrom)
    aAdd(aAux,dDateTo)

    aAdd(aAux,(cAliasAtu)->CREDITBEG)
    aAdd(aAux,(cAliasAtu)->DEBITBEG)

    aAdd(aAux,(cAliasAtu)->CREDITVAL)
    aAdd(aAux,(cAliasAtu)->DEBITVAL)

    aAdd(aAux,(cAliasAtu)->CREDITEND)
    aAdd(aAux,(cAliasAtu)->DEBITEND)

Return aAux

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaCT2()
Busca os

@author Flavio Lopes

@since 25/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaCT2(oModel)
    Local lRet      as logic
    Local cQuery    as character
    Local aArea     as array
    Local aFields	as array
    Local aCpoCT2	as array
    Local nX		as numeric
    Local nY		as numeric
    Local aAux		as array
    Local cCampo 	as character
    Local __aRet1	as array
    Local aFldWhere	as array
    Local cValEnt	as character
    Local cCredDeb	as character
    Local aAddEcFld As Array
    Local aNom as Array
    Local lNom as logic
    Local cNomQuery as character
    Local cTempCT1 as character
    Local n2X as Numeric

    aNom:={}
    lNom:=.T.

    lRet    	:= .F.
    aArea   	:= GetArea()
    aFields		:= oModel:GetStruct():GetFields()
    aCpoCT2		:= {}
    aAux		:= {}
    __aRet1		:= {}
    aFldWhere	:= {}
    cCredDeb	:= If(Empty((cAliasAtu)->CREDITVAL),"D","C")

    aAddEcFld   := {}

    //Verify aditional
    CT0->(DbSetOrder(1))    //CT0_FILIAL+CT0_ID
    CT0->(DbGoTop())
    While !CT0->(Eof()) .And. CT0->CT0_FILIAL == FWxFilial("CT0")
        If !Empty(aScan(aLevelTabE,{|x| UPPER(x[1]) == UPPER(CT0->CT0_ALIAS)})) .And. !Empty(CT0->CT0_ENTIDA)
            aAdd(aAddEcFld,AllTrim(CT0->CT0_ID))
        Endif
        CT0->(DbSkip())
    EndDo

    DbSelectArea("CT2")
    DbSetOrder(1)
    cTabCT2	  := GetNextAlias()

    cQuery    := ""
    cQuery    += "SELECT"
    cQuery    += " *"
    cQuery    += " FROM "+RetSQLName("CT2")+" TMP"
    cQuery    += " WHERE"
    For nX:=1 To nMaxLevelE
        aFldWhere := FldLevel(nX,"E")

        cValEnt  := (cAliasAtu)->&(aFldWhere[1][1])

        If Empty(cValEnt)
            cValEnt := Space(3)
        Endif

        AADD(aNom,{cValEnt,(cAliasAtu)->CT1CLASSE})
        n2X:=1
        If nX==1 .and. aNom[n2X,2]=="1"
        
            While lNom
                If aNom[n2X,2]=="1"//CT1_CLASSE
                    cNom:=aNom[n2X,1]
                    cNomQuery:="SELECT CT1_CONTA,CT1_CLASSE FROM " + RetSQLName("CT1") + " WHERE CT1_CTASUP = '" + cNom + "'"
                    cNomQuery+= " AND CT1_CONTA IN (" + ArrayToStr(ACT1_CONTA,",","'") + " )"
                    cTempCT1:= GetNextAlias()
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNomQuery),cTempCT1,.T.,.T.)
                    (cTempCT1)->(DbGoTop())
                    While (cTempCT1)->(!EOF())
                        AADD(aNom,{(cTempCT1)->CT1_CONTA,(cTempCT1)->CT1_CLASSE})
                        (cTempCT1)->(dbSkip())
                    EndDo
                    (cTempCT1)->(dbCloseArea())
                EndIf
                n2X++
                lNom:=n2X<Len(aNom)
            EndDo
            aNom:=RU99X02005_ArrSpecialToArr(aNom,,1)
            cQuery += "(" + aFldWhere[1][5][If(cCredDeb=="D",1,2)] + " IN (" + ArrayToStr(aNom,",","'") + ")) AND "
            aNom:={}
        Else
            cQuery += "(" + aFldWhere[1][5][If(cCredDeb=="D",1,2)] + " = '"+ cValEnt + "') AND "
        Endif
        
    Next nX

    cQuery += " CT2_DATA BETWEEN '" + DTOS(dDateFrom)+ "' AND '" + DTOS(dDateTo)+ "' AND  "
    cQuery    += "	CT2_MOEDLC = '"+ cCurrency +"' AND "

    cQuery    += " TMP.D_E_L_E_T_ = ' ' "

    IF !EMPTY(cBalType)
        IF AT("-", cBalType) != 0
            nPosTPS := AT( "-", cBalType)
            cQuery += " AND CT2_TPSALD BETWEEN '" + SUBSTR( cBalType, 1, nPosTPS-1) + "' AND '" + SUBSTR( cBalType, nPosTPS+1,Len(cBalType)-1 ) + "' "
        ELSE
            cQuery += " AND CT2_TPSALD IN " + formatIN(cBalType,";") + " "
        ENDIF
    ENDIF

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCT2,.T.,.T.)

    For nY := 1 to Len(aFields)
        cCampo :=  Alltrim(aFields[nY][3])
        aAdd(aCpoCT2, cCampo  )
    Next nY

    While (cTabCT2)->(!EOF())
        TCSetField(cTabCT2,"R_E_C_N_O_", "C")
        aAux := Nil
        aAux := Array(Len(aCpoCT2))

        For nX := 1 to Len(aCpoCT2)
            If Alltrim(aCpoCT2[nX]) == "CT2_DATA"
                cCampo   := aCpoCT2[nX]
                aAux[nX] := STOD((cTabCT2)->&(cCampo))
            ElseIf Alltrim(aCpoCT2[nX]) $ "R_E_C_N_O_"
                cCampo   := aCpoCT2[nX]
                cChave:= (cTabCT2)->CT2_FILIAL+(cTabCT2)->CT2_DATA+(cTabCT2)->CT2_LOTE+(cTabCT2)->CT2_SBLOTE+(cTabCT2)->CT2_DOC+(cTabCT2)->CT2_LINHA+(cTabCT2)->CT2_TPSALD+(cTabCT2)->CT2_EMPORI+(cTabCT2)->CT2_FILORI+"01"
                CT2->(dbseek(cChave))
                aAux[nX] := ALLTRIM(STR(CT2->(Recno())))
            Else
                cCampo   := aCpoCT2[nX]
                aAux[nX] := (cTabCT2)->&(cCampo)
            EndIf
        Next nX

        aAdd(__aRet1,{0 ,aAux })

        (cTabCT2)->(dbSkip())
    EndDo

    If Select(cTabCT2) > 0
        DbSelectArea(cTabCT2)
        (cTabCT2)->(DbCloseArea())
        Ferase(cTabCT2)
    Endif

Return __aRet1

//-----------------------------------------------------------------------
/*/{Protheus.doc} EcFields

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function EcFields(cAliasFld,cEntNum)
    Local aEcFields as array

    aEcFields := {}

    Do Case
        Case cAliasFld == "CT1"
            aEcFields := {"CT2_DEBITO","CT2_CREDIT"}
        Case cAliasFld == "CTT"
            aEcFields := {"CT2_CCD","CT2_CCC"}
        Case cAliasFld == "CTD"
            aEcFields := {"CT2_ITEMD","CT2_ITEMC"}
        Case cAliasFld == "CTH"
            aEcFields := {"CT2_CLVLDB","CT2_CLVLCR"}
        Case cAliasFld == "CV0"
            aEcFields := {"CT2_EC" + cEntNum + "DB","CT2_EC" + cEntNum + "CR"}
    EndCase

Return aEcFields


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU34WIZ()
Wizard para filtros da consulta

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU34S10WIZ(aActParam)
    Local aEntCkMain	as array
    Local aFilEnt	 	as array
    Local aGetsEnt		as array
    Local oStepWiz 		As Object
    Local aAccounts		as array
    Local oPnlFilEn		As Object
    Local lRet 			as Logical
    Local lUserSave		as Logical
    Local cLoad			as character
    Private aFldBrw	:= {}
    Private cArq
    Private nWizStep	:= 1
    Private lSelFinDim  := .F.
    Default aActParam := {} //parameter to be used at display wizard(used at main screen when user would like actual parameters)

    aEntMain 	:= {}
    aEntCkMain 	:= {}
    aFilEnt	 	:= {}
    aGetsEnt	:= {}
    aEntidades	:= {}
    aAccounts	:= {}
    cLoad		:= "RU34S10"

    //This configaration was necessary when user change the wizard at main screen, not save and press edit again, this will make display the data filled before. 
    If Len(aActParam) > 0
        aF61XData := {}
        aF61XData := aActParam  //replace this array because they are used at fucntin GetPS_PAR(cId) to get valued to wizar
    Endif


    if !len(aPsListA)>0
        aPsListA:={}
        aAdd(aPsListA,{"NAME",Space(160),STR0109})
        aAdd(aPsListA,{"SHARED",Space(160),STR0110})
        aAdd(aPsListA,{"SHAREDVALUE",Space(130),STR0111})
    EndIf

    lUserSave	:= .F.
    lRet 		:= .T.
    If len(aParametro)==0
        Aadd(aParametro,{1,"Filial:" ,cFilFrom,"@" 	 ,""  ,""    ,"" ,120 ,.F. }) //"Filial:"
        Aadd(aParametro,{4,"",dDateFrom,"Date From:",40,,.F.}) //"Date From:"
        Aadd(aParametro,{4,"",dDateTo,"Date To:",40,,.F.}) //"Date To:"
        Aadd(aParametro,{1,"Currency:" ,cCurrency,"@" 	 ,""  ,""    ,"" ,120 ,.F. }) //"Currency:"
        Aadd(aParametro,{1,"Balance Type:" ,cBalType,"@" 	 ,""  ,""    ,"" ,120 ,.F. })//"Balance Type:"
        Aadd(aParametro,{1,"Division by:" ,cDivision,"@" 	 ,""  ,""    ,"" ,120 ,.F. })//"Division by:"
        Aadd(aParametro,{1,"Show gr. balance:", cGrBalance, "@", "", "", "", 120, .F. })//"Show Grouped balance:"
        Aadd(aParametro,{1,"Show sum. l.a.:", cSumLedAcc, "@", "", "", "", 120, .F. })//"show summarized ledger account :"
        Aadd(aParametro,{1,"Show l.a. desc.:", cLedAccDsc, "@", "", "", "", 120, .F. })//"show ledger account description:"
    Endif
    SetPrvt("MV_PAR01")
    SetPrvt("MV_PAR02")
    SetPrvt("MV_PAR03")    
    SetPrvt("MV_PAR04")
    SetPrvt("MV_PAR05")
    SetPrvt("MV_PAR06")
    SetPrvt("MV_PAR07")
    SetPrvt("MV_PAR08")
    SetPrvt("MV_PAR09")

    If lSelParam
        MV_PAR01 := GetPS_PAR("MV_PAR01")
        MV_PAR02 := STOD(GetPS_PAR("MV_PAR02"))
        MV_PAR03 := STOD(GetPS_PAR("MV_PAR03"))
        MV_PAR04 := GetPS_PAR("MV_PAR04")
        MV_PAR05 := GetPS_PAR("MV_PAR05")
        MV_PAR06 := GetPS_PAR("MV_PAR06")
        MV_PAR07 := GetPS_PAR("MV_PAR07")
        MV_PAR08 := GetPS_PAR("MV_PAR08")
        MV_PAR09 := GetPS_PAR("MV_PAR09")
    Else
        MV_PAR01 := ParamLoad(cLoad,aParametro,1,aParametro[1,3],Iif(Len(aParametro[1])>10,aParametro[1,10],.F.))
        MV_PAR02 := ParamLoad(cLoad,aParametro,2,aParametro[2,3],Iif(Len(aParametro[2])>10,aParametro[2,10],.F.))
        MV_PAR03 := ParamLoad(cLoad,aParametro,3,aParametro[3,3],Iif(Len(aParametro[3])>10,aParametro[3,10],.F.))
        MV_PAR04 := ParamLoad(cLoad,aParametro,4,aParametro[4,3],Iif(Len(aParametro[4])>10,aParametro[4,10],.F.))
        MV_PAR05 := ParamLoad(cLoad,aParametro,5,aParametro[5,3],Iif(Len(aParametro[5])>10,aParametro[5,10],.F.))
        MV_PAR06 := ParamLoad(cLoad,aParametro,6,aParametro[6,3],Iif(Len(aParametro[6])>10,aParametro[6,10],.F.))
        MV_PAR07 := ParamLoad(cLoad,aParametro,7,aParametro[7,3],Iif(Len(aParametro[7])>10,aParametro[7,10],.F.))
        MV_PAR08 := ParamLoad(cLoad,aParametro,8,aParametro[8,3],Iif(Len(aParametro[8])>10,aParametro[8,10],.F.))
        MV_PAR09 := ParamLoad(cLoad,aParametro,9,aParametro[9,3],Iif(Len(aParametro[9])>10,aParametro[9,10],.F.))
    Endif

    oStepWiz:= FWWizardControl():New(,{600,720})//Instancia a classe FWWizard
    oStepWiz:ActiveUISteps()

    //----------------------
    // Page 1
    //----------------------

    oNewPag := oStepWiz:AddStep("1")
    //Altera a descriï¿½ï¿½o do step
    oNewPag:SetStepDescription(STR0049)//"Accounts Selection"
    //Define o bloco de construï¿½ï¿½o
    oNewPag:SetConstruction({|Panel|SelAccount(Panel, @aAccounts)})
    //Define o bloco ao clicar no botï¿½o Prï¿½ximo
    oNewPag:SetNextAction({||ValSelAcc(@aAccounts),nWizStep++})
    //Define o bloco ao clicar no botï¿½o Cancelar
    oNewPag:SetCancelAction({||lRet := .F., .T.})

    //----------------------
    // Page 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2", {|Panel|SelEntit(Panel, @aEntidades)})
    oNewPag:SetStepDescription(STR0050)//"Entities Selection"
    oNewPag:SetNextAction({||ValSelEnt(@aEntidades, @aLevelsEn), FilRecon(@oPnlFilEn, @aFilEnt, @aGetsEnt, @aLevelsEn, @oPnlFilEn, @aLevelTabE), nWizStep++})
    //Define o bloco ao clicar no botï¿½o Voltar
    oNewPag:SetCancelAction({||lRet := .F., .T.})
    oNewPag:SetPrevAction({||nWizStep--, .T.})
    //oNewPag:SetPrevTitle(STR0051)//"Back"

    //----------------------
    // Page 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3", {|Panel|FilEnti(Panel,@aFilEnt,@aGetsEnt,@aLevelsEn,@oPnlFilEn,@aLevelTabE)})
    oNewPag:SetStepDescription(STR0052)//"Entities Filters"
    oNewPag:SetNextAction({||ValFilters(@aLevelsEn,@aFilEnt,@aFiltersEn),nWizStep++})
    oNewPag:SetPrevAction({||nWizStep--, .T.})
    oNewPag:SetCancelAction({||lRet := .F., .T.})

    //----------------------
    // Page 4
    //----------------------
    oNewPag := oStepWiz:AddStep("4", {|Panel|FilGeneral(Panel)})
    oNewPag:SetStepDescription(STR0055)//"General Filters"
    oNewPag:SetNextAction({|Panel|ValFIlGen(), .T.})
    oNewPag:SetPrevAction({||nWizStep--, .T.})
    oNewPag:SetCancelAction({||lRet := .F., .T.})

    oStepWiz:Activate()

    lRet := lRet .And. lIsEscape

    If lRet
        If MsgYesNo(STR0144) //Save configuration
            If nOper==1//New Configuration
                RU34S1001_SaveF61(aPsListA,1)
            Elseif nOper==3 //Edit Selected
                EditF61_items(aPsListA,cSelParam)
            EndiF
        Endif
    Endif
Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} SelAccount

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function SelAccount(oPanel, aArquivo)

    Local aHeadCols  as array
    Local oMBrowse	 as Object
    Local oFWFilter  as Object
    Local oTempTable as Object
    Local aAccounts	 as array
    Local cQuery 	 as character
    Local cAliasTmp	 as character
    Local cAliasQry  as Character
    Local aStruct    as Array //Fields Struct
    Local aColumns   as Array //Browse Columns
    Local aSeek      as Array // Fields for Searching process
    Local aFilter    as Array //Filter Array
    Local nX         as Numeric //Loop Control
    Local nOrder     as Numeric //Order
    Local lMusSel   as Logical //acouting are selected before?

    aStruct := {}
    AAdd(aStruct, {"MARK"      , "C", 02                       , 00})
    AAdd(aStruct, {"NUMREG"    , "N", 12                       , 00})
    AAdd(aStruct, {"CT1_CONTA" , "C", TamSX3("CT1_CONTA")[01]  , TamSX3("CT1_CONTA")[02]})
    AAdd(aStruct, {"CT1_DESC01", "C", TamSX3("CT1_DESC01")[01] , TamSX3("CT1_DESC01")[02]})
    AAdd(aStruct, {"CT1_CTASUP", "C", TamSX3("CT1_CTASUP")[01] , TamSX3("CT1_CTASUP")[02]})

    //Set Columns
    aColumns := {}
    aFilter  := {}
    aSeek    := {}

    For nX := 03 To Len(aStruct)
        //Columns
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX][1]))
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
        aColumns[Len(aColumns)]:SetPicture(PesqPict("CT1",aStruct[nX][1]))
        //Filters
        aAdd(aFilter, {aStruct[nX][1], RetTitle(aStruct[nX][1]), TamSX3(aStruct[nX][1])[3], TamSX3(aStruct[nX][1])[1], TamSX3(aStruct[nX][1])[2], PesqPict("CT1", aStruct[nX][1])} )
    Next nX

    //Instance of Temporary Table
	oTempTable := FWTemporaryTable():New()
	//Set Fields
	oTempTable:SetFields(aStruct)
    //Set Indexes
    oTempTable:AddIndex("INDEX1", {"CT1_CONTA","CT1_CTASUP"} )
    oTempTable:AddIndex("INDEX2", {"CT1_CTASUP","CT1_CONTA"} )
	//Create
	oTempTable:Create()
    cAliasTmp := oTemptable:GetAlias()

    aHeadCols := {}
    oMBrowse	:= NIL
    aAccounts := {}
    cQuery := ""

    cAliasQry := GetNextAlias()

    aArquivo := {}

    cQuery := "SELECT ' ' MARK, CT1.CT1_CONTA, CT1.CT1_DESC01, CT1_CTASUP "
    cQuery += "FROM " + RetSqlName("CT1") + " CT1 "
    cQuery += "WHERE CT1.CT1_FILIAL = '" + FWxFILIAL("CT1") + "' "
    //cQuery += "  AND CT1.CT1_CTASUP = ' ' "
    cQuery += "  AND CT1.D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY  CT1.CT1_CONTA, CT1.CT1_CTASUP "

    cQuery := ChangeQuery(cQuery)

    PlsQuery(cQuery, cAliasQry)

    nOrder := 01
    If lSelParam
        cTempParam:=GetPS_PAR("ACCOUNT")
    Endif

    DBSelectArea(cAliasTMP)
    (cAliasQry)->(DbGoTop())
    While !(cAliasQry)->(Eof())
        //Add Array
        AAdd(aArquivo, {})
        lMusSel := .F.
        If lSelParam .and. !Empty(cTempParam) .and. (('#'+alltrim((cAliasQry)->CT1_CONTA)+'#') $ cTempParam)
            lMusSel := .T.
        Endif

        AAdd(ATail(aArquivo),lMusSel)
        AAdd(ATail(aArquivo), alltrim((cAliasQry)->CT1_CONTA)) //reduce data whem store at SYP table
        AAdd(ATail(aArquivo), (cAliasQry)->CT1_DESC01)
        AAdd(ATail(aArquivo), (cAliasQry)->CT1_CTASUP)
        //Add Temporary Table
        If (RecLock(cAliasTMP, .T.))
            If lMusSel
                (cAliasTMP)->MARK       := "XX"
            Else
                (cAliasTMP)->MARK       := Space(02)
            Endif
            (cAliasTMP)->NUMREG      := nOrder
            (cAliasTMP)->CT1_CONTA  := (cAliasQry)->CT1_CONTA
            (cAliasTMP)->CT1_DESC01 := (cAliasQry)->CT1_DESC01
            (cAliasTMP)->CT1_CTASUP := (cAliasQry)->CT1_CTASUP
            (cAliasTMP)->(MsUnlock())
        EndIf
        nOrder ++
        (cAliasQry)->(DBSkip())
    EndDo

    (cAliasTMP)->(DbGoTop())
    if lShowWiz
        oMBrowse:= FWMarkBrowse():New()
    
        //Seek
        For nX := 3 to len(aStruct)
            aAdd(aSeek,{RetTitle(aStruct[nX][1])/*Title*/,{{""/*LookUp*/, TamSX3(aStruct[nX][1])[3]/*Type*/, TamSX3(aStruct[nX][1])[1]/*Size*/, TamSX3(aStruct[nX][1])[2]/*Decimal*/,PesqPict("CT1", aStruct[nX][1])}},(nX-2),.T. } )
        Next nX

        oMBrowse:oBrowse:SetAlias(cAliasTMP) //Temporary Table Alias
	    oMBrowse:oBrowse:SetTemporary(.T.) //Using Temporary Table
        oMBrowse:oBrowse:SetSeek(.T., aSeek)
	    oMBrowse:oBrowse:SetUseFilter(.T.) //Using Filter
	    oMBrowse:oBrowse:SetProfileID("RU34S10FIL")//ID for filter
        oMBrowse:oBrowse:DisableDetails()
        oMBrowse:oBrowse:DisableReport()
        oMBrowse:oBrowse:SetColumns(aColumns)
        oMBrowse:oBrowse:SetFieldFilter(aFilter) //Set Filters

        //Create Mark Column
        oMBrowse:oBrowse:AddMarkColumns({|| IIf(Empty((cAliasTMP)->MARK), "LBNO", "LBOK")},; //Code-Block image
            {|| SelectOne(oMBrowse:oBrowse, cAliasTMP, aArquivo)},; //Code-Block Double Click
            {|| SelectAll(oMBrowse:oBrowse, 01, cAliasTMP, aArquivo) }) //Code-Block Header Click
        //Change Order
        oMBrowse:oBrowse:SetColumnOrder(Len(oMBrowse:oBrowse:aColumns), 01)
        oMBrowse:oBrowse:Activate(oPanel)
        oFWFilter := oMBrowse:oBrowse:FWFilter()
    Endif
Return .T.

Static Function SelectOne(oBrowse, cAliasTMP, aArquivo)
    Local nX       := (cAliasTMP)->NUMREG
    Local cMark    := "XX"
    Local cCtaSup  := (cAliasTMP)->CT1_CTASUP
    Local cAccount := (cAliasTMP)->CT1_CONTA
    Local lMark    := Empty((cAliasTMP)->MARK)

    If (nX <= Len(aArquivo))
        //Update Temporary
        If (RecLock(cAliasTMP, .F.))
            (cAliasTMP)->MARK := IIf(lMark, cMark, Space(02))
            (cAliasTMP)->(MsUnlock())
        EndIf

        //Update Child's
        UpdCT1Child(cAliasTMP, cAccount, cMark, lMark, aArquivo)

        //Go Back register
        (cAliasTMP)->(DBSetOrder(01)) //CT1_CONTA + CT1_CTASUP
        ((cAliasTMP)->(DBSeek(cCtaSup + cAccount)))

        //Update Array
        aArquivo[nX, 01] := !aArquivo[nX, 01]
        oBrowse:Refresh()
    EndIf
    oBrowse:Refresh()
Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} SelectAll

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function SelectAll(oBrowse, nCol, cAliasTMP, aArquivo)
    Local cMark := "XX"
    Local nX    := (cAliasTMP)->NUMREG - 1
    (cAliasTMP)->(DBSetOrder(01))//CT1_CONTA + CT1_CTASUP
    If nCol == 1
        (cAliasTMP)->(DBGoTop())

        While !(cAliasTMP)->(EOF())
            //Update Temporary
            If (RecLock(cAliasTMP, .F.))
                (cAliasTMP)->MARK := IIf(lMarker, cMark, "  ")
                (cAliasTMP)->(MsUnlock())
            EndIf

            //Update Array
            nX ++
            If (nX <= Len(aArquivo))
                aArquivo[nX, 01] := IIf(Empty((cAliasTMP)->MARK), .F., .T.)
            EndIf

            (cAliasTMP)->(DBSkip())
        EndDo

        (cAliasTMP)->(DBGoTop())
    Endif

    oBrowse:Refresh()
    lMarker:=!lMarker
Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValSelAcc

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function ValSelAcc(aAccounts)
Local nX        as numeric
Local cPS_PAR01 as character

cPS_PAR01   :="#"
aCT1_CONTA  := {}

For nX:=1 To Len(aAccounts)
    If aAccounts[nX][1]
        AADD( aCT1_CONTA, aAccounts[nX][2] )
        cPS_PAR01 += aAccounts[nX][2]+"#" //add special caracter between accounts to be possibel select correct when load for parameters saved
    EndIf
Next nX

If len(aPsListA)=3
    aAdd(aPsListA,{"ACCOUNT",cPS_PAR01,STR0123})
Else
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="ACCOUNT"}),2]:=cPS_PAR01
Endif

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} SelEntit

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------

Static Function SelEntit(oPanel,aEntidades)
Local oOK			As Object
Local oNO			As Object
Local aAreaCT0		as array
Local aSize			as array
Local aFldLevel		as array
Local aPosObj		as array
Local aHeadCols 	as array
Local nX 			as numeric
Local bBlock		as block

aAreaCT0	:= CT0->(GetArea())
aSize		:= MsAdvSize()
aPosObj		:= {}
aHeadCols 	:= {}
oOK			:= LoadBitmap(GetResources(),"LBOK")
oNO			:= LoadBitmap(GetResources(),"LBNO")
nX          := 1
aFldLevel	:= {}
aEntidades	:= {}

aHeadCols := {" ",STR0009} //"Entities"
If lSelParam
    cTempParam:=GetPS_PAR("VISION")
Endif

CT0->(DbSetOrder(1))
CT0->(DbGoTop())
While !CT0->(Eof()) .And. CT0->CT0_FILIAL == xFilial("CT0")
    aAdd(aEntidades,{})
    If lSelParam
        aAdd(aTail(aEntidades),Alltrim(str(nX)) $ cTempParam)
    Else
        aAdd(aTail(aEntidades),Iif(CT0->CT0_ALIAS == "CT1",.T.,.F.))
    Endif
    aAdd(aTail(aEntidades),AllTrim(CT0->CT0_DESC))
    aAdd(aTail(aEntidades),CT0->(Recno()))
    bBlock := &("{|u| if( Pcount()>0, aEntidades["+ AllTrim(Str(nX)) +"][1] := u, aEntidades[" + AllTrim(Str(nX)) + "][1]) }")
    If lShowWiz .and. CT0->CT0_ALIAS <> "CT1"
        aAdd(aTail(aEntidades),TCheckBox():New(nX*10,20, AllTrim(CT0->CT0_DESC),bBlock,oPanel,100,210,,,,,,,,.T.))
    EndIf
    CT0->(DbSkip())
    nX++
End

RestArea( aAreaCT0 )

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValSelEnt

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function ValSelEnt(aEntidades,aLevelsREF)
Local aAreaCT0	as array
Local aFldLevel as array
Local nX		as numeric
local cPS_PAR02 as character

cPS_PAR02:=""
For nX:=1 to len(aEntidades)
    If aEntidades[nX][1]
        cPS_PAR02+=Alltrim(str(nX))+"|"
    EndIf
Next nX
If len(aPsListA)==4
    aAdd(aPsListA,{"VISION",cPS_PAR02})
Else
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="VISION"}),2]:=cPS_PAR02
Endif
aAreaCT0	:= CT0->(GetArea())
aFldLevel	:= {}
nX 			:= 1
aLevelsREF	:= {}
aFldLevel 	:= {}
aLevelTabE	:= {}

lSelFinDim := .F.

aAdd(aFldLevel, {"ACCOUNT",STR0003,30,(alltrim(STR0077)) +" ",{"CT2_DEBITO","CT2_CREDIT"}})//STR0077="Acc."2
aAdd(aLevelTabE, {"CT1","",1,"CT1_DESC01"})

aAdd(aLevelsREF,aFldLevel)

For nX := 2 To Len(aEntidades)
    aFldLevel	:= {}
    lSelFinDim	:= lSelFinDim .Or. aEntidades[nX,1]
    If aEntidades[nX,1]
        CT0->(DbGoTo(aEntidades[nX,3]))
        If Empty(CT0->CT0_ENTIDA)
            aAdd(aFldLevel, {SubStr(CT0->CT0_CPOCHV,5,Len(CT0->CT0_CPOCHV)),AllTrim(CT0->CT0_DESC),30,AllTrim(CT0->CT0_DESC),EcFields(CT0->CT0_ALIAS,CT0->CT0_ID)})
            aAdd(aLevelTabE, {CT0->CT0_ALIAS, CT0->CT0_ID,1,CT0->CT0_CPODSC})
        Else
            aAdd(aFldLevel, {"EC" + CT0->CT0_ID,AllTrim(CT0->CT0_DESC),30,AllTrim(CT0->CT0_DESC),EcFields(CT0->CT0_ALIAS,CT0->CT0_ID)})
            aAdd(aLevelTabE, {CT0->CT0_ALIAS,"",1,CT0->CT0_CPODSC})
        EndIf

        aAdd(aLevelsREF,aFldLevel)
    Endif
Next nX

nMaxLevelE := Len(aLevelsREF)

RestArea( aAreaCT0 )
Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} FilEnti

@param		Nenhum
@return		Nenhum
@author 	Flavio Lopes
@since 		16/01/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function FilEnti(oPanel,aFilEnt,aGets,aLevelsRef,oPanelAft,aLevelTab)
Local nX		as numeric
Local bBlock	as block
Local nLastComp as numeric
Local nCol 		as numeric
Local nColLabel as numeric 
Local cTextSay  as Character
Local lRunVal   as logical
aTempPSVar  :={}
nLastComp 	:= 10
nCol 		:= 70
nColLabel 	:= 15
If lSelFinDim
    aGets 		:= {}
    aFilEnt		:= {}
    If lSelParam
        aAdd(aFilEnt,{left(GetPS_PAR("VISIONX1")+Space(30),30),left(GetPS_PAR("VISIONX2")+Space(30),30)})
    Else
        aAdd(aFilEnt,{Space(30),Space(30)})
    Endif

    For nX:= 2 To Len(aLevelsRef)
        If nX == 5
            nCol := 250
            nLastComp := 10
            nColLabel := 200
        Endif

        If lSelParam
            aAdd(aFilEnt,{left(GetPS_PAR("VISIONX"+alltrim(str(nX*2-1)))+Space(30),30),left(GetPS_PAR("VISIONX"+alltrim(str(nX*2)))+Space(30),30)})
        Else
            aAdd(aFilEnt,{Space(30),Space(30)})
        Endif
        If lShowWiz
            bBlock := &("{|| aLevelsRef["+ AllTrim(Str(nX))+ "][1][4]+ '" + " " + (AllTrim(STR0067)) + "'  }")
            oSay := tSay():New(nLastComp+2,nColLabel,bBlock,oPanel,,,,,,.T.,,,100,10)
            bBlock := &("{ | u | If( PCount() == 0, aFilEnt["+AllTrim(Str(nX))+"][1], aFilEnt["+AllTrim(Str(nX))+"][1] := u ) }")
            aAdd( aGets,  TGet():New(nLastComp,nCol,bBlock,oPanel,070,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aFilEnt[nX][1],,,, ))
            aGets[Len(aGets)]:cF3 := aLevelTab[nX][1]
            nLastComp += 20
    
            bBlock := &("{|| aLevelsRef["+ AllTrim(Str(nX))+ "][1][4]+ '" + " " + (AllTrim(STR0068)) + "'  }")
            oSay := tSay():New(nLastComp+2,nColLabel,bBlock,oPanel,,,,,,.T.,,,100,10)
            bBlock := &("{ | u | If( PCount() == 0, aFilEnt["+AllTrim(Str(nX))+"][2], aFilEnt["+AllTrim(Str(nX))+"][2] := u ) }")
            aAdd( aGets,  TGet():New(nLastComp,nCol,bBlock,oPanel,070,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,aFilEnt[nX][2],,,, ))
            aGets[Len(aGets)]:cF3 := aLevelTab[nX][1]
            nLastComp += 20
        Else
            lRunVal:=.T.
        Endif
    Next nX
Else
    cTextSay := STR0090
    If lShowWiz
        oSay := tSay():New(nLastComp-2,nColLabel,{||cTextSay},oPanel,,,,,,.T.,,,500,10)
    EndIf
EndIf

If lShowWiz
    oPanelAft := @oPanel
Elseif lRunVal
    ValFilters(@aLevelsEn,@aFilEnt,@aFiltersEn)
EndIf

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValFilters
Create generic filters' screen

@author 	Flavio Lopes
@since 		24/05/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function ValFilters(aLevelsRef,aFilEnt,aFiltRef)
Local aFromTo := {}
Local nX := 1
Local nY := 1
Local nLenFill  as numeric
Local nTempN    as numeric
aFiltRef := {}
If lSelFinDim
    For nX:=1 To Len(aLevelsRef)
        aFromTo := {}
        aAdd(aFromTo,aLevelsRef[nX][1][1])
        aAdd(aFromTo,If(Empty(aFilEnt[nX][1]),"   ",aFilEnt[nX][1]))
        aAdd(aFromTo,If(Empty(aFilEnt[nX][2]),"ZZZ",aFilEnt[nX][2]))
        aAdd(aFiltRef,aFromTo)
    Next nX
EndIf
nLenFill:=Len(aFilEnt)
nY      :=1
For nX:=1 to nLenFill
    nTempN:=aScan(aPsList3A, {|x| AllTrim(x[1]) == "VISIONX"+Alltrim(Str(nY))} )
    If nTempN==0
        aAdd(aPsList3A,{"VISIONX"+Alltrim(Str(nY)), aFilEnt[nX,1],aLevelsRef[nX,1,4]+" "+STR0067})//"VISIONX1" "VISIONX2" ...
    Else
        aPsList3A[nTempN,2]:=aFilEnt[nX,1]
        aPsList3A[nTempN,3]:=aLevelsRef[nX,1,4]+" "+STR0067
    End
    nY++

    nTempN:=aScan(aPsList3A, {|x| AllTrim(x[1]) == "VISIONX"+Alltrim(Str(nY))} )
    If nTempN==0
        aAdd(aPsList3A,{"VISIONX"+Alltrim(Str(nY)), aFilEnt[nX,2],aLevelsRef[nX,1,4]+" "+STR0067})
    Else
        aPsList3A[nTempN,2]:=aFilEnt[nX,2]
        aPsList3A[nTempN,3]:=aLevelsRef[nX,1,4]+" "+STR0067
    End
    nY++
Next nX
Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} FilGeneral
Create generic filters' screen

@author 	Flavio Lopes
@since 		24/05/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function FilGeneral(oPanel)
Local lHasButton as logic

lHasButton := .T.

oSay := tSay():New(12,15,{|| STR0096},oPanel,,,,,,.T.,,,60,10) //Branch From
oGet1 := TGet():New( 10, 70, { |u| If( PCount() == 0, MV_PAR01, MV_PAR01 := u ) },oPanel,060,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"MV_PAR01",,,,lHasButton )
oGet1:cF3 := "R34SM0"

oSay := tSay():New(32,15,{|| STR0060},oPanel,,,,,,.T.,,,60,10)//Date From:
oGet3 := TGet():New( 30, 70, { |u| If( PCount() == 0, MV_PAR02, MV_PAR02 := u ) },oPanel,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"MV_PAR02",,,,lHasButton )

oSay := tSay():New(52,15,{|| STR0061},oPanel,,,,,,.T.,,,60,10)//Date To:
oGet4 := TGet():New( 50, 70, { |u| If( PCount() == 0, MV_PAR03, MV_PAR03 := u ) },oPanel,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"MV_PAR03",,,,lHasButton )

oSay := tSay():New(72,15,{|| STR0062},oPanel,,,,,,.T.,,,60,10)//Currency:
oGet5 := TGet():New( 70, 70, { | u | If( PCount() == 0, MV_PAR04, MV_PAR04 := u ) },oPanel, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"MV_PAR04",,,,lHasButton  )
oGet5:cF3 := "CTO"

oSay := tSay():New(92,15,{|| STR0063},oPanel,,,,,,.T.,,,60,10)//Balance Type:
oGet6 := TGet():New( 90, 70, { | u | If( PCount() == 0, MV_PAR05, MV_PAR05 := u ) },oPanel, 060, 010, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"MV_PAR05",,,,lHasButton  )
oGet6:cF3 := "SX5SL"

oSay := tSay():New(112, 15, {|| STR0064}, oPanel, ,,,,,.T.,,, 60, 10)//Division by:
oCombo7 := TComboBox():New(110, 70, {|u|if(PCount()>0, MV_PAR06:=u, MV_PAR06)}, aDivisions, 60, 10, oPanel, ,,,,,.T.,,,,,,,,,"MV_PAR06")

oSay := tSay():New(132, 15,{|| STR0097 },oPanel,,,,,,.T.,,,60,10)//Show gr balance:
oCombo8 := TComboBox():New(130, 70, {|u|if(PCount()>0, MV_PAR07 := u, MV_PAR07)}, aGrBalance, 60, 10, oPanel, ,,,,,.T.,,,,,,,,,"MV_PAR07")

oSay := tSay():New(152, 15, {|| STR0095}, oPanel, ,,,,,.T.,,, 60, 20)//"Show sum.ledg acc."//vshishkin: changed STR0085 to STR0095, also changed the Y size(from 10 to 20) of tSay-box(for english UI)
oCombo9 := TComboBox():New(150, 70, {|u|if(PCount()>0, MV_PAR08:=u, MV_PAR08)}, aSumLedAcc, 60, 10, oPanel, ,,,,,.T.,,,,,,,,,"MV_PAR08")

oSay := tSay():New(172, 15, {|| STR0089}, oPanel, ,,,,,.T.,,, 60, 20)//"Show ledg acc. desc."//vshishkin: changed the Y size(from 10 to 20) of tSay-box(for english UI)
oComboA := TComboBox():New(170, 70, {|u|if(PCount()>0, MV_PAR09:=u, MV_PAR09)}, aLedAccDsc, 60, 10, oPanel, ,,,,,.T.,,,,,,,,,"MV_PAR09")        

Return .T.

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValFilGen
Validation for generic filters

@author 	Flavio Lopes
@since 		24/05/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function ValFilGen()
Local nY	    as numeric
Local aTempAr   as array
Local nLenTA    as numeric
Local cTempTA   as character
Local nCheck    as numeric

cFilFrom 	:= MV_PAR01
dDateFrom	:= MV_PAR02
dDateTo 	:= MV_PAR03
cCurrency	:= MV_PAR04
cBalType	:= MV_PAR05
cDivision	:= Alltrim(MV_PAR06)
cGrBalance  := Alltrim(MV_PAR07)
cSumLedAcc  := Alltrim(MV_PAR08)
cLedAccDsc  := Alltrim(MV_PAR09)

For nY:=1 to len(aPsList3A)
    nCheck:=aScan(aPsListA, {|x| AllTrim(x[1]) == "VISIONX"+Alltrim(Str(nY))} )
    If nCheck==0
        Aadd(aPsListA,aPsList3A[nY])
    Else
        aPsListA[nCheck,2]:=aPsList3A[nY,2]
    Endif
Next nY

If aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR01"})==0
    aAdd(aPsListA,{"MV_PAR01",MV_PAR01})
    aAdd(aPsListA,{"MV_PAR02",DTOS(MV_PAR02)})
    aAdd(aPsListA,{"MV_PAR03",DTOS(MV_PAR03)})
    aAdd(aPsListA,{"MV_PAR04",MV_PAR04})
    aAdd(aPsListA,{"MV_PAR05",MV_PAR05})
    aAdd(aPsListA,{"MV_PAR06",MV_PAR06})
    aAdd(aPsListA,{"MV_PAR07",MV_PAR07})
    aAdd(aPsListA,{"MV_PAR08",MV_PAR08})
    aAdd(aPsListA,{"MV_PAR09",MV_PAR09})
Else //udpdate actual values
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR01"}),2]:=MV_PAR01
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR02"}),2]:=DTOS(MV_PAR02)
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR03"}),2]:=DTOS(MV_PAR03)
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR04"}),2]:=MV_PAR04
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR05"}),2]:=MV_PAR05
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR06"}),2]:=MV_PAR06
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR07"}),2]:=MV_PAR07
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR08"}),2]:=MV_PAR08
    aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="MV_PAR09"}),2]:=MV_PAR09
EndIf

If cDivision == "2"
    nDivide := 100
ElseIf cDivision == "3"
    nDivide := 1000
ElseIf cDivision == "4"
    nDivide := 1000000
Else
    nDivide := 1
EndIf

cTempTA:=""
aTempAr:={}
aTempAr:= StrTokArr(GetPS_PAR("ACCOUNT"),"/")
nLenTA:=Len(aTempAr)
For nY:=1 to nLenTA
    cTempTA+=Alltrim(aTempAr[nY])
    If nY==nLenTA
        cTempTA+="."
    Else
        cTempTA+=","
    Endif
Next nY

Aadd(aPrintPara,{STR0123,cTempTA})//accounts
Aadd(aPrintPara, {STR0058 , MV_PAR01} ) //"Filial De:"
Aadd(aPrintPara, {STR0060, DTOS(MV_PAR02)} ) //"Date From:"
Aadd(aPrintPara, {STR0061, DTOS(MV_PAR03)} ) //"Date To:"
Aadd(aPrintPara, {STR0062, MV_PAR04} ) //"Currency:"
Aadd(aPrintPara, {STR0063, MV_PAR05} )//"Balance Type:"
Aadd(aPrintPara, {STR0064, GetDesc(ArrayToStr(aDivisions), TRIM(MV_PAR06))} )//"Division by:"
Aadd(aPrintPara, {STR0084, GetDesc(ArrayToStr(aGrBalance), Trim(MV_PAR07))} )//"Show Grouped balance:"
Aadd(aPrintPara, {STR0085, GetDesc(ArrayToStr(aSumLedAcc), Trim(MV_PAR08))} )//"show summarized ledger account :"
Aadd(aPrintPara, {STR0089, GetDesc(ArrayToStr(aLedAccDsc), Trim(MV_PAR09))} )//"show ledger account description:"

lIsEscape := .T.
Return .T.
//-----------------------------------------------------------------------
/*/{Protheus.doc} FilRecon
Resconstruction of the next filter panel.

@author 	Flavio Lopes
@since 		24/05/2017
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Static Function FilRecon(oPanel,aFilEnt,aGetsEnt,aLevelsEn,oPnlFilEn,aLevelTab)
if lShowWiz
    If oPanel <> NIL
        oPanel:FreeChildren()
        FilEnti(@oPanel,@aFilEnt,@aGetsEnt,@aLevelsEn,@oPnlFilEn,@aLevelTab)
    Endif
Endif
Return .T.

//-----------------------------------------------------------------------
Function RuFilXBCT1(cCtaSup)
    Local lRet as logic
    lRet:= .T.
    If IsInCallStack("RU34S10WIZ") .And. nWizStep == 3
        lRet := aScan(aCT1_CONTA,{|x| x == cCtaSup}) > 0
    ElseIf (CT1->CT1_CLASSE=='1' .AND. RU34S10004_IsBsProc() )  //payment request payment order baks statment and gererate payment order
        lRet:= .F.
    EndIf
Return lRet
//-----------------------------------------------------------------------

/*/{Protheus.doc} RU34S10001_RuFilXBeNTITTE
Filter accounting entities in SXB not to be displayed when XXX_CLASE == 1
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
@return lRet (True - Show in SXB , False do not show on SXB)
/*/
Function RU34S10001_RuFilXBeNTITTE(cAlias)
    Local lRet as logical
    Local cClass as Character
    
    DEFAULT cAlias = alias()

    cClass:= cAlias+"->"+cAlias+"_CLASSE"
    lRet:= .T.

    If (&(cClass)=='1' .AND. RU34S10004_IsBsProc())  //payment request payment order baks statment and gererate payment order
        lRet:= .F.
    EndIf
Return lRet

/*/{Protheus.doc} RU34S10002_VldEntiti
Validates accounting entities
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
    cAlias: alias of the standart entrie case empty will take the cottent of X3_F3 if its is a valid entity in SX2
    cField: cottent to be validated if empty will take the field that is been used (readvar)
    lSint:  If true allow sumyrized itens othewise it does not accept and show the message by defalt it is false
@return lRet (True - is a valid entitie , False is not a valid entitie)
/*/
Function RU34S10002_VldEntiti(cAlias,cField,lSint)
    Local lRet as logical
    Local cClass as Character

    DEFAULT cAlias = ""
    DEFAULT cField = ""
    DEFAULT lSint  = .F.
    
    If EMPTY( cAlias )
        cAlias = RU34S10003_getAliasRead_var(READVAR())
    EndIf
    If EMPTY( cField )
        cField = &(READVAR())
    EndIf

    cClass:= cAlias+"->"+cAlias+"_CLASSE"
    lRet:= .T.

    If !(ExistCpo(cAlias)) 
        lRet:= .F.
    ElseIf !lSint .AND. (Posicione(cAlias, 1, xFilial(cAlias) + cField, cClass) == '1')
        Help(" ",1,"NOCLASSE")    
        lRet:= .F.
    EndIf
Return lRet

/*/{Protheus.doc} RU34S10003_getAliasRead_var
Returns the alias of the entity based on the X3_F3 of the field in the parameter that is 
triggered when using the routine RU34S10002_VldEntiti when the parameter cAlias is empty
@type function
@author eduardo.Flima
@since Jun|2020
@version 1.0
@param 
    cReadVar: Nome do cammpo da entidade contabil podendo recever o proprio readVar 
@return cAlias: Alias da entidade contabil baseada no X3_F3
/*/
Static Function RU34S10003_getAliasRead_var(cReadVar)
    Local cAlias as Character 
    Local aReadVar as Array 
    Local aArea	as array
    DEFAULT cReadVar = ''
    aReadVar:= {}
    cAlias := ''
    aArea := GetArea()
        If !empty(cReadVar)
            cReadVar:= StrTran( cReadVar, "M->", "" )  
        EndIf
        cAlias:= alltrim(GetSx3Cache(cReadVar,'X3_F3'))
    RestArea(aArea)
Return cAlias

Static Function RU34S10004_IsBsProc()
    Local lRet      as Logical
    Local aFuncs    as Array 
    Local nX        as Numeric

    lRet    :=.F.
    aFuncs  := {}

    //Add here Functions to be considered in Bs process and related to accountty entityes 
    //-----------------------------------------------------------------------------------
        AADD( aFuncs, 'RU06D04RUS' ) // PAYMENT REQUEST
        AADD( aFuncs, 'RU06D05RUS' ) // PAYMENT ORDER
        AADD( aFuncs, 'RU06D07RUS' ) // Bank Statment
        AADD( aFuncs, 'RU09D08' )   // Configuration for Payment Request to Budget Payment.


        


    //-----------------------------------------------------------------------------------

    For nX:=1 To Len(aFuncs)
        lRet =  IsInCallStack(aFuncs[nX])
        If lRet 
            Exit
        EndIf   
    Next nX

Return lRet

//-----------------------------------------------------------------------
Static Function Ct2Fields()

    Local cRet:= ""

    cRet += "|CT2_FILIAL"
    cRet += "|CT2_DATA"
    cRet += "|CT2_LOTE"
    cRet += "|CT2_SBLOTE"
    cRet += "|CT2_DOC"
    cRet += "|CT2_LINHA"
    cRet += "|CT2_MOEDLC"
    cRet += "|CT2_DC"
    cRet += "|CT2_DEBITO"
    cRet += "|CT2_CREDIT"
    cRet += "|CT2_VALOR"
    cRet += "|CT2_MOEDAS"
    cRet += "|CT2_HP"
    cRet += "|CT2_HIST"
    cRet += "|CT2_CCD"
    cRet += "|CT2_CCC"
    cRet += "|CT2_ITEMD"
    cRet += "|CT2_ITEMC"
    cRet += "|CT2_CLVLDB"
    cRet += "|CT2_CLVLCR"
    cRet += "|CT2_TPSALD"
    cRet += "|CT2_SEQUEN"
    cRet += "|CT2_MANUAL"
    cRet += "|CT2_ORIGEM"
    cRet += "|CT2_ROTINA"
    cRet += "|CT2_AGLUT"
    cRet += "|CT2_LP"
    cRet += "|CT2_SEQHIS"
    cRet += "|CT2_SEQLAN"
    cRet += "|CT2_DTVENC"
    cRet += "|CT2_DATATX"
    cRet += "|CT2_TAXA"
    cRet += "|CT2_VLR01"
    cRet += "|CT2_VLR02"
    cRet += "|CT2_VLR03"
    cRet += "|CT2_VLR04"
    cRet += "|CT2_VLR05"
    cRet += "|CT2_CRCONV"
    cRet += "|CT2_DTCV3"
    cRet += "|CT2_USRCNF"
    cRet += "|CT2_DTCONF"
    cRet += "|CT2_HRCONF"
    cRet += "|CT2_MLTSLD"
    cRet += "|CT2_CODPAR"
    cRet += "|CT2_NODIA"
    cRet += "|CT2_EC05DB"
    cRet += "|CT2_DIACTB"
    cRet += "|CT2_EC05CR"
    cRet += "|CT2_USERGI"
    cRet += "|CT2_USERGA"
    cRet += "|CT2_AT01DB"
    cRet += "|CT2_AT01CR"
    cRet += "|CT2_AT02DB"
    cRet += "|CT2_AT02CR"
    cRet += "|CT2_AT03DB"
    cRet += "|CT2_AT03CR"
    cRet += "|CT2_AT04DB"
    cRet += "|CT2_AT04CR"
    cRet += "|CT2_LANCSU"
    cRet += "|CT2_GRPDIA"
    cRet += "|CT2_LANC"
    cRet += "|CT2_CODCLI"
    cRet += "|CT2_CODFOR"

Return cRet

/*/{Protheus.doc} CT1Sup
Function to select all sons when we selected a superios account
@type  Static Function
@author Ma3
@since 
@version 
@param  Superior accouting
        array to store result
@return nil
/*/
Static Function CT1Sup(cSuperior,aAccounts)
    Local aAreaCT1	:= CT1->(GetArea())

    CT1->(DbSetOrder(5))
    CT1->(DbSeek( xFilial("CT1") + AllTrim(cSuperior)) )

    If !CT1->(EOF())
        aAdd(aAccounts,cSuperior)
        While !CT1->(EOF()) .And. CT1->CT1_CTASUP == cSuperior
            CT1Sup(CT1->CT1_CONTA,@aAccounts)
            CT1->(DbSkip())
        End
    Else
        aAdd(aAccounts,cSuperior)
    EndIf

    RestArea( aAreaCT1 )

Return nil

//-----------------------------------------------------------------------
Static Function RU34S10PRT()
    Local oReport	As Object
    Local clPerg    as CHAR

    clPerg	:= "RU34S10"

    oReport := ReportDef(clPerg)
    oReport:PrintDialog()

return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ReportDef(clPerg)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function ReportDef(clPerg)
    Local oReport   As Object
    Local oSecRepp  As Object
    Local oSecParam   As Object
    Local nX	    as numeric

    oReport := TReport():New("RU34S10", STR0001, clPerg, {|oReport| ReportPrint(oReport)}, STR0086)
    oReport:lParamPage	:= .F.	// not print patameter page

    //Pergunte(oReport:uParam,.F.)

    oSecParam:= TRSection():New(oReport,"",{} , , .F., .F.)
    TRCell():New( oSecParam, "Param",  , STR0087/*X3Titulo()*/, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New( oSecParam, "Value",  , STR0088/*X3Titulo()*/, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

    oSecRepp := TRSection():New(oReport,"",{cAliasAtu} , , .F., .F.)
    //TRCell():New( oSecRepp, "FILIAL"  , cAliasAtu , STR0024/*X3Titulo()*/, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    TRCell():New( oSecRepp, "ACCOUNT"  , cAliasAtu , STR0003/*X3Titulo()*/, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

    If (cLedAccDsc == "2")
        TRCell():New( oSecRepp, "ACCDESCR"  , cAliasAtu , STR0027, "@!" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
    EndIf

    For nX := 2 To Len(aLevelsEn)
        TRCell():New( oSecRepp, aLevelsEn[nX][1][1]  , cAliasAtu , aLevelsEn[nX][1][2]/*X3Titulo()*/, /*Picture*/, TAMSX3(alltrim(aLevelsEn[nX][1][5][1]))[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    Next nX

    TRCell():New( oSecRepp, "TYPEBAL", cAliasAtu , STR0004/*X3Titulo()*/, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo

    TRCell():New( oSecRepp, "DEBITBEG" , cAliasAtu , STR0038 + STR0005 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    TRCell():New( oSecRepp, "CREDITBEG", cAliasAtu , STR0038 + STR0006 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    TRCell():New( oSecRepp, "DEBITVAL" , cAliasAtu , STR0039 + STR0005 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    TRCell():New( oSecRepp, "CREDITVAL", cAliasAtu , STR0039 + STR0006 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    TRCell():New( oSecRepp, "DEBITEND" , cAliasAtu , STR0040 + STR0005 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo
    TRCell():New( oSecRepp, "CREDITEND", cAliasAtu , STR0040 + STR0006 /*X3Titulo()*/, "@E 99,999,999,999,999.99" /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)	// Centro de custo

Return (oReport)

//-----------------------------------------------------------------------
Static Function ReportPrint(oReport)
    Local oSecRepp  As Object
    Local oSecParam As Object
    Local nX	    as numeric

    oSecParam := oReport:Section(1)
    oSecRepp := oReport:Section(2)

    If oReport:Cancel()
	    Return .T.
    EndIf
    oReport:IncMeter()
    // print params from wizard
    oSecParam:Init()
    For nX:=1 To Len(aPrintPara)
        oSecParam:Cell("Param"):SetValue(aPrintPara[nX][1])
        oSecParam:Cell("Value"):SetValue(aPrintPara[nX][2])
        oSecParam:Printline()
    Next nX

    // print main report
    oSecRepp:Init()

    Dbselectarea(cAliasAtu)
    dbgotop()

    While (cAliasAtu)->(!EOF())

        //oSecRepp:Cell("FILIAL"):SetValue( (cAliasAtu)->FILIAL )
        oSecRepp:Cell("ACCOUNT"):SetValue( (cAliasAtu)->ACCOUNT )

        For nX := 2 To Len(aLevelsEn)
           oSecRepp:Cell(aLevelsEn[nX][1][1]):SetValue( (cAliasAtu)->&(aLevelsEn[nX][1][1])  )
        Next nX

        oSecRepp:Cell("TYPEBAL"):SetValue( (cAliasAtu)->TYPEBAL )

        oSecRepp:Cell("DEBITBEG"):SetValue( (cAliasAtu)->DEBITBEG )
        oSecRepp:Cell("CREDITBEG"):SetValue( (cAliasAtu)->CREDITBEG )

        oSecRepp:Cell("DEBITVAL"):SetValue( (cAliasAtu)->DEBITVAL )
        oSecRepp:Cell("CREDITVAL"):SetValue( (cAliasAtu)->CREDITVAL )

        oSecRepp:Cell("DEBITEND"):SetValue( (cAliasAtu)->DEBITEND )
        oSecRepp:Cell("CREDITEND"):SetValue( (cAliasAtu)->CREDITEND )

        oSecRepp:Printline()
        (cAliasAtu)->(DbSkip())
    EndDo
    oSecParam:Finish()
    oSecRepp:Finish()

return (NIL)
//-----------------------------------------------------------------------

/* GetDesc
    Function gets from combobox the Description from value. For example, "1=aa;2=bb;3=cc" Description of value "2 is "bb"
    @type  Static Function
    @author Din Belotserkovsky
    @since 2019.05.31
    @version 1.0
    @param
        str need to be like "1=aa;2=bb;3=cc"
        cId is value, witch Description will get
    @return
        the Description from combobox

*/
Static Function GetDesc(cStrs as Char , cId as Char)
Local aDesc     as Array
Local cRes      as Char
Local nIniPos   as Numeric

aDesc   := RetSx3Box(cStrs, , , 1)
nIniPos := Ascan(aDesc, {|x| cId == x[2]})
cRes    := iIf(nIniPos == 0, "",  aDesc[nIniPos,3])

return cRes


/*{Protheus.doc} ArrayToStr(aItems as Array)
    combines an array into a string
    @type  Static Function
    @author Din Belotserkovsky
    @since 2019.05.31
    @version 1.0
    @param aItems Array input items
    @return string in format "item1;item2;"
    */
 Static Function ArrayToStr(aItems as Array,cTypeSeparator,cStartEnd)
    Local cRes as Char
    Local nX as Numeric
    local n2Len as Numeric
    DEFAULT cTypeSeparator = ";"
    DEFAULT cStartEnd = ""
    
    n2Len:=Len(aItems)
    cRes := ""

    If empty(cStartEnd)
        For nX:= 1 To n2Len
            cRes += aItems[nX] + cTypeSeparator
        Next nX
    Else
        For nX:= 1 To n2Len
            cRes += cStartEnd + aItems[nX] + cStartEnd
            If !(nX==n2Len)
                cRes += cTypeSeparator
            Endif
        Next nX
    Endif

Return cRes



/*/{Protheus.doc} GetLastCV0
    Get Last Level in CV0, according Account

    @type  Static Function
    @author Alison Kaique
    @since Jun|2019
    @version 1.0
    @param cAccount, character, Account Code
    @return cLastLevel, character, Last Level
/*/
Static Function GetLastCV0(cAccount As Character)
    Local cLastLevel As Character //Last Level
    Local cLevel     As Character //Currenty Level

    Default cAccount := ""

    //Initiliaze Variable
    cLastLevel := PadR(cAccount, TamSX3("CV0_CODIGO")[01])
    cLevel     := PadR(cAccount, TamSX3("CV0_CODIGO")[01])

    DBSelectArea("CV0")
    CV0->(DBSetOrder(02)) //CV0_FILIAL+CV0_CODIGO

    While !(Empty(cLevel))
        //Seek
        If CV0->(DBSeek(FWxFilial("CV0") + cLevel))
            cLastLevel := CV0->CV0_CODIGO
            cLevel     := CV0->CV0_ENTSUP
        Else
            Exit 
        EndIf
    EndDo
Return cLastLevel

/*/{Protheus.doc} UpdCT1Child
    Update Account childs

    @type  Static Function
    @author Alison Kaique
    @since Jun|2019
    @version 1.0
    @param cAliasTMP, character, Temporary Alias
    @param cCtaSup  , character, Superior Account
    @param cMark    , character, Mark
    @param lMark    , logical  , Is Marked ?
    @param aArquivo , array    , Auxiliary array from accounts
    @return lReturn, logical, Process Control
/*/
Static Function UpdCT1Child(cAliasTMP As Character, cCtaSup As Character, cMark As Character, lMark As Logical, aArquivo As Array)
    Local lReturn  As Logical //Process Control
    Local cAccount As Character //Currenty Account

    //Initialize variables
    lReturn := .T.

    //Find childs
    (cAliasTMP)->(DBSetOrder(02)) //CT1_CTASUP + CT1_CONTA
    (cAliasTMP)->(DBGoTop())
    If ((cAliasTMP)->(DBSeek(cCtaSup)))
        While (!(cAliasTMP)->(EOF()) .AND. (cAliasTMP)->CT1_CTASUP == cCtaSup)
            cAccount := (cAliasTMP)->CT1_CONTA
            //Update
            If (RecLock(cAliasTMP, .F.))
                (cAliasTMP)->MARK := IIf(lMark, cMark, Space(02))
                (cAliasTMP)->(MsUnlock())
            EndIf
            //Update Array
            aArquivo[(cAliasTMP)->NUMREG, 01] := !aArquivo[(cAliasTMP)->NUMREG, 01]
            //Call recursively
            UpdCT1Child(cAliasTMP, (cAliasTMP)->CT1_CONTA, cMark, lMark, aArquivo)
            //Go Back register
            ((cAliasTMP)->(DBSeek(cCtaSup + cAccount)))
            //Skip register
            (cAliasTMP)->(DBSkip())
        EndDo
    Else
        lReturn := .F.
    EndIf

Return lReturn

/*/{Protheus.doc} R34S10SM0
    Standard Query from Filials

    @type  Static Function
    @author Alison Kaique
    @since Jun|2019
    @version 1.0

    @return lReturn, logical, Process Control
/*/
Function R34S10SM0()
    Local aFilials As Array //Selected Filials
    Local cFilials As Character //Selected Filials
    Local lReturn  As Logical //Process Control
    Private MvRet  As Character //MV_PAR??
    Public cRetR34SM0 As Character //Return

    MvRet   := Alltrim(ReadVar())

    lReturn := .T.

    #IFDEF WINDOWS
        oWnd := GetWndDefault()
    #ENDIF

    //Get Filials
    aFilials := AdmGetFil()

    //Transform array in string
    cFilials := ArrTokStr(aFilials, ",")

	&MvRet:= cFilials

    cRetR34SM0 := &MvRet
    oGet1:CtrlRefresh()

Return lReturn

/*-----------------------------------------------------------------------
@Descrip.:  Deleting registers F61
@param		
@return		
@author 	Nikitenko Artem                     @Date 28/02/2020
@version 	 1.0                                 @project	MA3
-----------------------------------------------------------------------*/
Static function DeletF61(cUUID)
local cSeek as character
cSeek:=""

If lSelParam
    if MsgYesNo (STR0131  + CRLF + STR0133 + CRLF + STR0132)
        F61->(dbSetOrder(1))//"F61_FILIAL+F61_UUID+F61_PARAM"
        cSeek:=xFilial('F61')+cUUID
        If F61->(DbSeek(cSeek))
            While !(F61->(Eof()))
                If F61->F61_UUID==cUUID
                    RecLock("F61", .F.)
                        //Deletes from SYP table
                        MSMM(F61->F61_VALUE,,,,2)
                        //Deletes from F61
                    	F61->(DbDelete())
                    MsUnlock("F61")
                Else
                    Exit
                Endif
                F61->(DbSkip())
            EndDo
        EndIf
        F61RefreshWindow()
    Endif
Else
    MsgInfo(STR0135,STR0134)
Endif

Return
/*-----------------------------------------------------------------------
@Descrip.:  selecting parameters window
@param		
@return		
@author 	Nikitenko Artem                     @Date 28/02/2020
@version 	 1.0                                 @project	MA3
-----------------------------------------------------------------------*/
Static Function CopyF61(cUUID)
//copy
aPsListA:={}
aF61XData:={}
aPsListA:=aF61XData:=GetF61_Items(Alltrim(cUUID))
if RU34S1001_SaveF61(aPsListA,2)
    F61RefreshWindow()
Endif
Return

/*-----------------------------------------------------------------------
@Descrip.:  Writing data in DB
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		aPsListA
@return		
-----------------------------------------------------------------------*/
Static Function STORE(aPsListA)
local _ni       as numeric
local _nQtd     as numeric
local nSize     as numeric
Local cF61Uuid  as character 

DbSelectArea("F61")

nSize       := TamSX3("F61_VALUE")[1]
cF61Uuid    := FWUUIDV4() 
_nQtd       := Len(aPsListA)
aPsListA    := ASORT(aPsListA,,,{|x,y|x[1]<y[1]})

//Loop and store information 
BEGIN TRANSACTION

    For _ni := 1 to _nQtd
        RecLock("F61",.T.)
            F61->F61_FILIAL := xfilial("F61")
            F61->F61_UUID   := cF61Uuid
            F61->F61_PARAM  := aPsListA[_ni,1]
            If aPsListA[_ni,1]=="SHAREDVALUE" .and. aPsListA[_ni-1,2]=="User"
                F61->F61_VALUE  := MSMM(,nSize,,alltrim(cUserf61),1,,,"F61","F61_VALUE")
            Else
                F61->F61_VALUE  := MSMM(,nSize,,aPsListA[_ni,2],1,,,"F61","F61_VALUE")
            Endif
            F61->F61_USER   := __cUserID
            F61->F61_ROUTIN := ("RU34S10"+space(10))
        MsUnlock()
    Next

END TRANSACTION
MsgInfo(STR0107, STR0108)
If nOper==1
    lSelParam   := .T.
    cUNamParam  := aPsListA[aScan(aPsListA,{|x|AllTrim(x[1])=="NAME"})][2]
    cSelParam   := cF61Uuid
    aPsListA    := aF61XData:=GetF61_Items(cSelParam)
Endif
Return

/*-----------------------------------------------------------------------
@Descrip.:  Writing data in DB
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		aPsListA
@return		
-----------------------------------------------------------------------*/
Static Function EditF61_h(aPsListA,cUUID,lFromResul,nPsListNum,cPsListVal)
Local _ni as numeric
Local nSize as numeric
Local cSeek as character

Default lFromResul := .F.
cSeek:=""

If !Empty(cPsListVal) //if has user value, use It
    aPsListA[nPsListNum,2]:=cPsListVal
Endif

_ni:=1
If !empty(cUUID)
    BEGIN TRANSACTION
        nSize := TamSX3("F61_VALUE")[1]
        DbSelectArea("F61")
        F61->(dbSetOrder(1))//"F61_FILIAL+F61_UUID+F61_PARAM"
        cSeek:=xFilial("F61")+cUUID
        If F61->(MsSeek(cSeek))
            While !(F61->(Eof()))
                If F61_UUID==cUUID
                    RecLock("F61", .F.)
                        If alltrim(F61->F61_PARAM) $ "NAME/SHARED/SHAREDVALUE"
                            //First check if value change, avoid create a lot of SYP
                            If alltrim(MSMM(F61->F61_VALUE,,,,3)) <> alltrim(aPsListA[_ni,2]) //means user change the value
                                //If change, remove old SYP and create a new one
                                MSMM(F61->F61_VALUE,,,,2) //option 2 is for delete
                                Replace F61->F61_VALUE With MSMM(,nSize,,alltrim(aPsListA[_ni,2]),1,,,"F61","F61_VALUE")
                            Endif
                        Endif
                        Replace F61->F61_USER With __cUserID
                    MsUnlock("F61")
                Else
                    Exit
                Endif
                F61->(DbSkip())
                _ni++
            EndDo
        EndIf
    END TRANSACTION
    if !lFromResul
        MsgInfo(STR0107, STR0108)
    Endif
Endif

Return

/*-----------------------------------------------------------------------
@Descrip.:
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function F61RefreshWindow()

RU34S1007_RecreateTable()
GetF612_header({"NAME","SHARED","SHAREDVALUE"},"RU34S10",c2AliasTmp)

Return


/*-----------------------------------------------------------------------
@Descrip.:  Open window, writing information and save or cancel.
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Function RU34S1001_SaveF61(aPsListA,nNum)
local aButtons      as Array
local nPInArrNam    as Numeric
local nPInArrSha   as Numeric
local nPInArrSVa   as Numeric
Local lRet          as Logical

lRet:=.F.
aPsListA:=ASORT(aPsListA,,,{|x,y|x[1]<y[1]})

nPInArrNam:=aScan(aPsListA,{|x|AllTrim(x[1])=="NAME"})
nPInArrSha:=aScan(aPsListA,{|x|AllTrim(x[1])=="SHARED"})
nPInArrSVa:=aScan(aPsListA,{|x|AllTrim(x[1])=="SHAREDVALUE"})

If nNum==2 .and. aPsListA[nPInArrSha][2]=="User" //copy
    cUserf61:=aPsListA[nPInArrSVa,2]
    aPsListA[nPInArrSVa,2]:=Space(6)
Elseif nNum==1 //save
    cUserf61:=__cUserID
    aPsListA[nPInArrSha][2]:="Group"
    aPsListA[nPInArrSVa][2]:=UsrRetGrp(,__cUserID)[1]
Endif

aPsListA[nPInArrNam][2]:=PADR(aPsListA[nPInArrNam][2],250," ")
aPsListA[nPInArrSha][2]:=PADR(aPsListA[nPInArrSha][2],20," ")
aPsListA[nPInArrSVa][2]:=PADR(aPsListA[nPInArrSVa][2],6," ")

cUserf61:= PADR(cUserf61,6," ")

aButtons:={}

//aAdd(aButtons,	{ STR0098, { || iif(RU34S1003_Validation(aPsListA[nPInArrNam][2],aPsListA[nPInArrSha][2],aPsListA[nPInArrSVa][2]),lRet:=.T.,lRet:=.F.)}, STR0098} )// Save Parameters 
//aAdd(aButtons,	{ STR0143, { || lRet:=.F.,o2Dlg:End() }, STR0143} )//"CANCEL"

DEFINE MsDIALOG o2Dlg TITLE STR0098 From 1, 4 To 200, 812 Pixel

    o2Say := tSay():New(43,5,{|| STR0109},o2Dlg,,,,,,.T.,,,40,12)//Name of vision:
    oGet11 := TGet():New( 43, 55, { | u | If( PCount() == 0, aPsListA[nPInArrNam][2], aPsListA[nPInArrNam][2] := u ) } ,o2Dlg, 335, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"aPsListA["+Alltrim(Str(nPInArrNam))+"][2]",,,,.F. )

    o2Say := tSay():New(70,5,{|| STR0110},o2Dlg,,,,,,.T.,,,70,12)//Shared vision:
    oCombo11 := TComboBox():New(70, 55, ;
    { | u | If( PCount() == 0, aPsListA[nPInArrSha][2], aPsListA[nPInArrSha][2] := u ) },;
    {"All","Group","User"}, 60, 8, o2Dlg,,;
    ,,,,.T.,,,,,,,,,"aPsListA["+Alltrim(Str(nPInArrSha))+"][2]")

    o2Say := tSay():New(70,130,{|| STR0111},o2Dlg,,,,,,.T.,,,70,12)//Group:
    oGet13 := TGet():New( 70, 150, { | u | If( PCount() == 0, aPsListA[nPInArrSVa][2], aPsListA[nPInArrSVa][2] := u ) },o2Dlg, 90, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,;
    {||RU34S1008_ChCompare(aPsListA[nPInArrSha][2],"Group",nPInArrSVa)},.F.,.F.,,.F.,.F. ,,"aPsListA["+Alltrim(Str(nPInArrSVa))+"][2]",,,,.T. )
    oGet13:cF3 := "R34GRP"

    o2Say := tSay():New(70,280,{|| STR0112},o2Dlg,,,,,,.T.,,,70,12)//User:
    oGet14 := TGet():New( 70, 300, { | u | If( PCount() == 0, cUserf61, cUserf61 := u ) },o2Dlg, 90, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,;
    {||RU34S1008_ChCompare(aPsListA[nPInArrSha][2],"User")},.F.,.F.,,.F./*21*/,.F. ,,"cUserf61",,,,.T. )
    oGet14:cF3 := "R34USR"

ACTIVATE MsDIALOG o2Dlg ON INIT (EnchoiceBar(o2Dlg, {||Iif(RU34S1003_Validation(aPsListA[nPInArrNam][2],aPsListA[nPInArrSha][2],aPsListA[nPInArrSVa][2]),lRet:=.T.,lRet:=.F.)}, {||olRet:=.F.,o2Dlg:End()}, ,aButtons,,,.F.,.F.,.F.,.T.,.F.)) CENTERED

Return lRet

/*-----------------------------------------------------------------------
@Descrip.:  returns data from table F61 with key
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		cUUID - charracter - ID Key for MSseek (From F61_UUID)
@return		aData - array - (data F61 from DB)
-----------------------------------------------------------------------*/
Static Function GetF61_Items(cUUID)
Local aData as array
Local cQuery as Character
Local cQryT3 as Character

aData   := {}
cQuery  := ''
cQryT3  := GetNextAlias()
DBSelectArea("F61")

cQuery+="SELECT R_E_C_N_O_ as recFile FROM " + RetSqlName("F61")
cQuery+=" WHERE F61_UUID = '"+cUUID+"' AND D_E_L_E_T_=''"
cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )
(cQryT3)->(DbGoTop())
While (cQryT3)->(!EOF())
    DbSelectAre('F61')
    F61->(dbGoTo( (cQryT3)->(recFile)))
    
    Aadd(aData, {Alltrim(F61->F61_PARAM),MSMM(F61->F61_VALUE,,,,3)})
    
    (cQryT3)->(dbSkip())
EndDo
(cQryT3)->(dbCloseArea())
DBSelectArea("F61")

Return ASORT(aData,,,{|x,y|x[1]<y[1]})


/*-----------------------------------------------------------------------
@Descrip.:  Returning data of parameter (/searching data in array with key)
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		cId - character - (key for searching - F61_PARAM)
@return		Character (char of MSMM() for F61_VALUE field)
-----------------------------------------------------------------------*/

Static Function GetPS_PAR(cId)
Local nX        as numeric
Local nLenxData as numeric
Local cDataForP as character

cDataForP   :=''
nLenxData   :=len(aF61XData)

For nX:=1 to nLenxData
    If aF61XData[nX][1]==cId
        cDataForP:=aF61XData[nX][2]
        Exit
    Endif
Next nX

If nX>nLenxData
    cDataForP:=Space(250)
Endif

Return cDataForP

/*-----------------------------------------------------------------------
@Descrip.:  (Not finished) Open window, writing information and save or cancel.
@author 	Nikitenko Artem                     @Date 02/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function EditF61_header(cUUID,lFromResul)
Local aButtons      as Array
Local nPInArrNam    as Numeric
Local nPInArrSha    as Numeric
Local nPInArrSVa    as Numeric
Local lRet          as Logical
Default lFromResul :=.F.

lRet:=.F.

if !lFromResul
    aPsListA:={}
    aF61XData:={}
    aPsListA:=aF61XData:=GetF61_Items(Alltrim(cUUID))
Else
    aPsListA:=ASORT(aPsListA,,,{|x,y|x[1]<y[1]})
Endif

nPInArrNam:=aScan(aPsListA,{|x|AllTrim(x[1])=="NAME"})
nPInArrSha:=aScan(aPsListA,{|x|AllTrim(x[1])=="SHARED"})
nPInArrSVa:=aScan(aPsListA,{|x|AllTrim(x[1])=="SHAREDVALUE"})

if lFromResul 
    aF61XData:=GetF61_Items(Alltrim(cUUID))
    aPsListA[nPInArrNam,2]:=GetPS_PAR("NAME")
    aPsListA[nPInArrSha,2]:=GetPS_PAR("SHARED")
    aPsListA[nPInArrSVa,2]:=GetPS_PAR("SHAREDVALUE")
Endif

If aPsListA[nPInArrSha][2]=="User"
    cUserf61:=aPsListA[nPInArrSVa,2]
    aPsListA[nPInArrSVa,2]:=Space(6)
Endif
aPsListA[nPInArrNam][2]:=PADR(aPsListA[nPInArrNam][2],250," ")
aPsListA[nPInArrSha][2]:=PADR(aPsListA[nPInArrSha][2],20," ")
aPsListA[nPInArrSVa][2]:=PADR(aPsListA[nPInArrSVa][2],6," ")
cUserf61:= PADR(cUserf61,6," ")

aButtons:={}

//aAdd(aButtons,	{ STR0116, { || EditF61_h(aPsListA,cUUID,lFromResul,nPInArrSVa,cUserf61),lOk:=.T.,o2Dlg:End(),lRet:=.T.}, STR0116} )// Edit Parameters
//aAdd(aButtons,	{ STR0143, { ||o2Dlg:End(),nOpca := 0}, STR0143} )// "Cancel"

DEFINE MsDIALOG o2Dlg TITLE STR0098 From 1, 4 To 200, 812 Pixel

    o2Say := tSay():New(40,5,{|| STR0109},o2Dlg,,,,,,.T.,,,40,12)//Name of vision:
    oGet11 := TGet():New( 40, 55, { | u | If( PCount() == 0, aPsListA[nPInArrNam][2], aPsListA[nPInArrNam][2] := u ) } ,o2Dlg, 335, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"aPsListA["+Alltrim(Str(nPInArrNam))+"][2]",,,,.F. )

    o2Say := tSay():New(70,5,{|| STR0110},o2Dlg,,,,,,.T.,,,70,12)//Shared vision:
    oCombo11 := TComboBox():New(70, 55, { | u | If( PCount() == 0, aPsListA[nPInArrSha][2], aPsListA[nPInArrSha][2] := u ) }, {"All","Group","User"}, 60, 8, o2Dlg, ,,,,,.T.,,,,,,,,,"aPsListA["+Alltrim(Str(nPInArrSha))+"][2]")

    o2Say := tSay():New(70,130,{|| STR0111},o2Dlg,,,,,,.T.,,,70,12)//Group:
    oGet13 := TGet():New( 70, 150, { | u | If( PCount() == 0, aPsListA[nPInArrSVa][2], aPsListA[nPInArrSVa][2] := u ) },o2Dlg, 90, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,;
    {||RU34S1008_ChCompare(aPsListA[nPInArrSha][2],"Group",nPInArrSVa)},.F.,.F.,,.F.,.F. ,,"aPsListA["+Alltrim(Str(nPInArrSVa))+"][2]",,,,.T. )
    oGet13:cF3 := "R34GRP"
    
    o2Say := tSay():New(70,280,{|| STR0112},o2Dlg,,,,,,.T.,,,70,12)//User:
    oGet14 := TGet():New( 70, 300, { | u | If( PCount() == 0, cUserf61, cUserf61 := u ) },o2Dlg, 90, 8, "@!",, 0, 16777215,,.F.,,.T.,,.F.,;
    {||RU34S1008_ChCompare(aPsListA[nPInArrSha][2],"User")},.F.,.F.,,.F.,.F. ,,"cUserf61",,,,.F. )
    oGet14:cF3 := "R34USR"

ACTIVATE MsDIALOG o2Dlg ON INIT (EnchoiceBar(o2Dlg, {||EditF61_h(aPsListA,cUUID,lFromResul,nPInArrSVa,cUserf61),o2Dlg:End(),lRet:=.T.}, {||o2Dlg:End(),nOpca := 0}, ,aButtons,,,.F.,.F.,.F.,.T.,.F.)) CENTERED
If lRet .and. !lFromResul
    F61RefreshWindow()
Endif
Return lRet

/*-----------------------------------------------------------------------
@Descrip.:  Get F61_header
@author 	Nikitenko Artem                     @Date 14/02/2020
@version 	1.0                                 @project	MA3
@param		
@return		rewriting aF61MData
-----------------------------------------------------------------------*/
Static Function GetF61_header(aKeys,cRoutine)
Local nLenArrKey    as Numeric
local nX            as Numeric
local nY            as Numeric
Local cQuery        as Character
Local cQryT3        as Character
Local bCodeArr
Local aTempArr      as Array
Local aGroupUser    as Array

cQryT3  := ""
cQuery  := ""
aF61MData   := {}
aTempArr    := {}
aGroupUser  := {}
cQryT3      := GetNextAlias()
nLenArrKey  := Len(aKeys)

bCodeArr    := "{.F.,(cQryT3)->F61_UUID"
For nY:=1 to nLenArrKey
    bCodeArr+=",''"
Next nY
bCodeArr+="}"

cQuery+="SELECT F61_UUID FROM " + RetSqlName("F61")
cQuery+=" WHERE F61_ROUTIN = '"+cRoutine+"' AND D_E_L_E_T_=''"
cQuery+=" GROUP BY F61_UUID ORDER BY F61_UUID"
cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

(cQryT3)->(DbGoTop())
While (cQryT3)->(!EOF())
    Aadd(aF61MData,&bCodeArr)
    (cQryT3)->(dbSkip())
EndDo
(cQryT3)->(dbCloseArea())

DBSelectArea("F61")
F61->(DBSetOrder(04))//"F61_FILIAL+F61_PARAM"

For nY:=1 to nLenArrKey
    F61->(DbGoTop())
    cChave:=xfilial('F61')+aKeys[nY]
    If F61->(MSseek(cChave))
        While F61->(!EOF())
            If alltrim(F61->F61_PARAM)==aKeys[nY]
                For nX:=1 to len(aF61MData)
                    if aF61MData[nX][2]==F61->F61_UUID
                        aF61MData[nX][2+nY]:=MSMM(F61->F61_VALUE,,,,3)
                    Endif
                Next nX
                F61->(dbSkip())
            Else
                Exit
            Endif
        EndDo
    Endif
Next nY
F61->(DbCloseArea())

//Checking user access and group (and remove)
nLenArrKey:=Len(aF61MData)
if nLenArrKey>0
    aGroupUser:=UsrRetGrp(,__cUserID)
    For nX:=1 to nLenArrKey
        If  aF61MData[nX,4]=="All" .or. (aF61MData[nX,4]=="User" .and. aF61MData[nX,5]==__cUserID)
            Aadd(aTempArr,{aF61MData[nX,1],aF61MData[nX,2],aF61MData[nX,3],aF61MData[nX,4],aF61MData[nX,5]})
        Elseif aF61MData[nX,4]=="Group"
            For nY:=1 to len(aGroupUser)
                If aGroupUser[nY] == aF61MData[nX,5]
                    Aadd(aTempArr,{aF61MData[nX,1],aF61MData[nX,2],aF61MData[nX,3],aF61MData[nX,4],aF61MData[nX,5]})
                    Exit
                Endif
            Next nY
        Endif
    Next nX
    aF61MData:=aTempArr
Endif

Return

/*-----------------------------------------------------------------------
@Descrip.:  
@author 	Nikitenko Artem                     @Date 04/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function PrintF61Items(cUUID)
Local oReport   As Object
Local oSecParam As Object
aPsListA:=GetF61_Items(cUUID)

oReport := TReport():New("", 'STR0001', "", {|oReport| R2eportPrint(oReport)}, 'STR0086')
oReport:lParamPage	:= .F.

oSecParam:= TRSection():New(oReport,"",{} , , .F., .F.)
TRCell():New( oSecParam, "Param",  , 'STR0087'/*X3Titulo()*/, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New( oSecParam, "Value",  , 'STR0088'/*X3Titulo()*/, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
oReport:PrintDialog()
Return

/*-----------------------------------------------------------------------
@Descrip.:  prints
@author 	Nikitenko Artem                     @Date 04/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function R2eportPrint(oReport)
Local oSecParam as Object
Local nX	    as numeric

oSecParam := oReport:Section(1)
If oReport:Cancel()
    Return .T.
EndIf
oReport:IncMeter()

oSecParam:Init()
For nX:=1 To Len(aPsListA)
    oSecParam:Cell("Param"):SetValue(aPsListA[nX][1])
    oSecParam:Cell("Value"):SetValue(aPsListA[nX][2])
    oSecParam:Printline()
Next nX
oSecParam:Finish()

return (NIL)

/*-----------------------------------------------------------------------
@Descrip.:  prints header of parameter
@author 	Nikitenko Artem                     @Date 04/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static function PrintF61Header()
Local oReport   as Object
Local oSecParam as Object

oReport := TReport():New("", 'STR0001', "", {|oReport| R3eportPrint(oReport)}, 'STR0086')
oReport:lParamPage	:= .F.
oSecParam:= TRSection():New(oReport,"",{} , , .F., .F.)
TRCell():New( oSecParam, "Nameofvision",  , STR0109/*X3Titulo()*/, /*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)//Name of vision:
TRCell():New( oSecParam, "SharedVision",  , STR0110/*X3Titulo()*/, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)//Shared vision:
TRCell():New( oSecParam, "Group",  , STR0111/*X3Titulo()*/, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)//Group:
TRCell():New( oSecParam, "User",  , STR0112/*X3Titulo()*/, /*Picture*/, 10/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)//User
oReport:PrintDialog()

Return

/*-----------------------------------------------------------------------
@Descrip.:  prints of parameter
@author 	Nikitenko Artem                     @Date 04/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function R3eportPrint(oReport)
    Local oSecParam As Object
    Local nX	    as numeric

    oSecParam := oReport:Section(1)
    If oReport:Cancel()
	    Return .T.
    EndIf
    oReport:IncMeter()

    oSecParam:Init()
    For nX:=1 To Len(aF61MData)
        oSecParam:Cell("Nameofvision"):SetValue(aF61MData[nX][3])
        oSecParam:Cell("SharedVision"):SetValue(aF61MData[nX][4])
        oSecParam:Cell("Group"):SetValue(aF61MData[nX][5])
        oSecParam:Cell("User"):SetValue(GetAdvFVal("F61",{"F61_USER"}, xFilial("F61")+aF61MData[nX][2]+"NAME" ,1,"")[1])//"F61_FILIAL+F61_UUID+F61_PARAM"
        oSecParam:Printline()
    Next nX
    oSecParam:Finish()

return (NIL)

/*-----------------------------------------------------------------------
@Descrip.:  editings F61 items
@author 	Nikitenko Artem                     @Date 04/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/

Static function EditF61_items(aPsListA,cUUID)
Local nX        as numeric
Local nPos      as Numeric
Local nSize     as numeric
Local aDBarr    as array

aDBarr  :={}
aDBarr  :=GetF61_Items(cUUID)
aPsListA:=ASORT(aPsListA,,,{|x,y|x[1]<y[1]})
aDBarr  :=ASORT(aDBarr,,,{|x,y|x[1]<y[1]})

If !Empty(cUUID)
    nSize := TamSX3("F61_VALUE")[1]

    BEGIN TRANSACTION
        DbSelectArea("F61")
        F61->(dbSetOrder(1))//"F61_FILIAL+F61_UUID+F61_PARAM"

        //Update or insert new values
        //use new array values, look at arraydb values
        For nX:=1 to len(aPsListA)
            If !(alltrim(aPsListA[nX,1]) $ "NAME/SHARED/SHAREDVALUE")
                F61->(dbSetOrder(1))
                If F61->(DbSeek(xFilial("F61")+cUUID+aPsListA[nx,1])) //found value at DB
                    //look at old array the values are the same
                    nPos := aScan(aDBarr,{|x| alltrim(UPPER(x[1])) == alltrim(UPPER(aPsListA[nx,1])) } )
                    If nPos > 0 //position at old array line      
                        If !(alltrim(aPsListA[nX,2])==alltrim(aDBarr[nPos,2])) //check if values are equal, no changes at db are necesary
                            //Delet old data from SYP table
                            MSMM(F61->F61_VALUE,,,,2)
                            RecLock("F61", .F.)
                                Replace F61->F61_VALUE With MSMM(,nSize,,aPsListA[nX,2],1,,,"F61","F61_VALUE")//creates fresh data in SYP table and puts key for this in F61_VALUE
                            MsUnlock("F61")
                        Endif                    
                    EndIf
                Else //not found, add at table
                    RecLock("F61",.T.)
                        F61->F61_FILIAL := xFilial("F61")
                        F61->F61_UUID   := cUUID
                        F61->F61_PARAM  := aPsListA[nX,1]
                        F61->F61_VALUE  := MSMM(,nSize,,aPsListA[nX,2],1,,,"F61","F61_VALUE")
                        F61->F61_USER   := __cUserID
                        F61->F61_ROUTIN := ("RU34S10"+space(10))
                    MsUnlock("F61")
                Endif
            Endif
        Next nX

        //delete values not used anymore(are at old parameters but not at new)
        F61->(dbSetOrder(1))//"F61_FILIAL+F61_UUID+F61_PARAM"
        For nX:=1 to len(aDBarr)
            If !(alltrim(aDBarr[nX,1]) $ "NAME/SHARED/SHAREDVALUE")
                //look if this old value are at new array, if not, must be deleted
                If aScan(aPsListA,{|x| alltrim(UPPER(x[1])) == alltrim(UPPER(aDBarr[nx,1])) } ) <= 0 //check if exist at new array   
                    If F61->(DbSeek(xFilial("F61")+cUUID+aDBarr[nx,1]))
                        //Deletes register from SYP table
                        MSMM(F61->F61_VALUE,,,,2)
                        //Deletes register from F61 table
                        RecLock("F61", .F.)
                            F61->(DbDelete())
                        MsUnlock("F61")
                    EndIf
                EndIf
            EndIf
        Next nX
    END TRANSACTION
    DbSelectArea('F61')
    MsgInfo(STR0107, STR0108)
Endif
Return

/*-----------------------------------------------------------------------
@Descrip.:  function for loupe 
@author 	Nikitenko Artem                     @Date 10/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Function R34S10GRP() //R34GRP
Local aArray as array
Local aTempArr as array
local nX as numeric
Local cDelimiter as character
Private MvPar as character
Private MvRet     := Alltrim(ReadVar())
Private cGrpSel as character
cGrpSel:=''
MvPar:=""
cDelimiter:= ' - '
aTempArr:={}
aArray:={}
aArray:=AllGroups()

For nX:=1 to len(aArray)
    Aadd(aTempArr,alltrim(aArray[nX,1,1]) + cDelimiter + Alltrim(aArray[nX,1,3]))
Next nX

f_Opcoes(@MvPar,"Titul",aTempArr,,10,50,.T.,1)

//Cuts data for field
&MvRet := ""
&MvRet := Substr(MvPar,1,AT("-",MvPar)-2)

//crunch - because f_Opcoes working uncorrect with "*"
If &MvRet=="**"
    &MvRet:="*"
Endif
//Keeps the function return in a private variable
cGrpSel := &MvRet

//Refresh tget
oGet13:CtrlRefresh()
Return(.T.)

/*-----------------------------------------------------------------------
@Descrip.:  function for loupe 
@author 	Nikitenko Artem                     @Date 10/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Function R34S10USR() //R34USR
Local aArray as array
Local aTempArr as array
local nX as numeric
Local cDelimiter as character
Private MvPar as character
Private MvRet     := Alltrim(ReadVar())
Private cSelUser as character
cSelUser:=''
MvPar:=""
cDelimiter:= ' - '
aTempArr:={}
aArray:={}

aArray:=FWSFALLUSERS()
For nX:=1 to len(aArray)
    Aadd(aTempArr,alltrim(aArray[nX,2]) + cDelimiter + Alltrim(aArray[nX,4]))
Next nX

f_Opcoes(@MvPar,"Titul",aTempArr,,10,50,.T.,1)

//Cuts data for field
&MvRet := ""
&MvRet := Substr(MvPar,1,AT("-",MvPar)-1)

//Keeps the function return in a private variable
cSelUser := &MvRet

//Refresh tget
oGet14:CtrlRefresh()
Return(.T.)

/*-----------------------------------------------------------------------
@Descrip.:  
@author 	Nikitenko Artem                     @Date 24/03/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/

Function RU34S1003_Validation(cName, cShar, cSharVal)
Local lLogic as logical
lLogic:=.F.

Do Case
    Case Len(Alltrim(cName))=0
        MsgInfo(STR0125, STR0128)//empty name
    Case Alltrim(cShar)=="Group" .and. Len(Alltrim(cSharVal))=0
        MsgInfo(STR0127, STR0129)//empty group
    Case Alltrim(cShar)=="User" .and. Len(Alltrim(cUserf61))=0
        MsgInfo(STR0126, STR0130)//empty user
    Otherwise
        lLogic:=.T.
EndCase
if lLogic
    STORE(aPsListA)
    o2Dlg:End()
Endif

Return lLogic


/*-----------------------------------------------------------------------
@Descrip.:  Window for selecting startup settings.
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		lRet
-----------------------------------------------------------------------*/

Function RU34S10RB()
Local nX := 0
Local lRet          as logical
Local aColumns      as array
private aStruct     as array
private o2FWBrow    as object
private oTempTable  as Object
private c2AliasTmp  as character

lRet        := .F.
aStruct     := {}
AAdd(aStruct, {"MARK","C",02,0,''})
AAdd(aStruct, {"UUID","C",32,0,''})
AAdd(aStruct, {"NAME","C",50,0,STR0109})
AAdd(aStruct, {"SHARED","C",25,0,STR0110})
AAdd(aStruct, {"SVALUE","C",25,0,STR0153})

//Set Columns
aColumns := {}

For nX := 03 To Len(aStruct)
    //Columns
    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
    aColumns[Len(aColumns)]:SetTitle((aStruct[nX][5]))
    aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
    aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
Next nX

oTempTable := FWTemporaryTable():New()
oTempTable:SetFields(aStruct)
oTempTable:AddIndex("INDEX1", {"UUID"} )
oTempTable:Create()
c2AliasTmp := oTemptable:GetAlias()

aHeadCols   := {}
oMBrowse	:= NIL
aAccounts   := {}

GetF612_header({"NAME","SHARED","SHAREDVALUE"},"RU34S10",c2AliasTmp)//rewriting temporary table

DEFINE MsDIALOG o3Dlg TITLE STR0103 From 0, 4 To 450, 1180 Pixel
    
    oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
    oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT

    o2FWBrow := FWFormBrowse():New()
    o2FWBrow:SetAlias(c2AliasTMP)
    o2FWBrow:SetDataTable(.T.)
    o2FWBrow:SetTemporary(.T.)
    o2FWBrow:DisableDetails()
    o2FWBrow:SetOwner(oPnMaster)
    o2FWBrow:DisableReport()
    o2FWBrow:SetColumns(aColumns)

    o2FWBrow:SetDoubleClick({|| lSelParam:=.T.,cUNamParam:=(c2AliasTMP)->NAME,cSelParam:=(c2AliasTMP)->UUID,lShowWiz:=.F.,lRet := .T.,o3Dlg:End()}) //double click

    o2FWBrow:AddButton( OemTOAnsi(STR0137), {|| nOper:=1, lShowWiz:=.T., lSelParam:=.F.,lRet := .T.,o3Dlg:End() } ,, 2 ) //"new"
    o2FWBrow:AddButton( OemTOAnsi(STR0138), {|| nOper:=2, lShowWiz:=.F., lSelParam:=.T.,lRet := .T.,cUNamParam:=(c2AliasTMP)->NAME,cSelParam:=(c2AliasTMP)->UUID,o3Dlg:End()} ,, 2 ) //"open"
    o2FWBrow:AddButton( OemTOAnsi(STR0139), {|| nOper:=3, lShowWiz:=.T., lSelParam:=.T.,lRet := .T.,cUNamParam:=(c2AliasTMP)->NAME,cSelParam:=(c2AliasTMP)->UUID,o3Dlg:End(),aF61XData:=GetF61_Items(cSelParam)} ,, 2 ) //"edit"

    o2FWBrow:AddButton( OemTOAnsi(STR0143), {|| lShowWiz:=.T., lRet := .F., o3Dlg:End() } ,, 2 ) //"Cancelar"

    o2FWBrow:AddButton(OemTOAnsi(STR0117), { || CopyF61((c2AliasTMP)->UUID),o2FWBrow:SetAlias(c2AliasTMP),o2FWBrow:refresh(.T.),lRet := .T. },,2)//"Copy" oBrowse:oBrowse:Refresh()
    o2FWBrow:AddButton(OemTOAnsi(STR0119), { || lSelParam:=.T.,DeletF61((c2AliasTMP)->UUID),o2FWBrow:SetAlias(c2AliasTMP),o2FWBrow:refresh(.T.) },,2)//"Delete"
    o2FWBrow:AddButton(OemTOAnsi(STR0141), { || EditF61_header((c2AliasTMP)->UUID),o2FWBrow:SetAlias(c2AliasTMP),o2FWBrow:refresh(.T.) },,2)//"Edit header"
    //o2FWBrow:AddButton(OemTOAnsi(STR0120), { || PrintF61Items((c2AliasTMP)->UUID),lRet := .T. },,2) //"Print chosed Parameter"
    //o2FWBrow:AddButton(OemTOAnsi(STR0121), { || PrintF61Header() },,2)//"Print list headers of parameter"
    o2FWBrow:Activate(oPnMaster)

Activate MsDialog o3Dlg

Return lRet
/*-----------------------------------------------------------------------
@Descrip.:  This function builds temp table with header data from F61 table
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function GetF612_header(aKeys,cRoutine,AliasQry)
Local nLenArrKey as Numeric
local nY        as Numeric
Local cQuery    as Character
Local cQryT3    as Character
Local aGroupUser as array
Local cValue    as Character
Local lVizualiz as Logical
Local cShare    as Character
Local cnameF61  as Character
local cQryT4    as Character

cQryT3      := ""
cQuery      := ""
aGroupUser  := {}
aGroupUser  := UsrRetGrp(,__cUserID)
cQryT3      := GetNextAlias()
nLenArrKey  := Len(aKeys)

cQuery+="SELECT F61_UUID FROM " + RetSqlName("F61")
cQuery+=" WHERE F61_ROUTIN = '"+cRoutine+"' AND D_E_L_E_T_=''"
cQuery+=" GROUP BY F61_UUID ORDER BY F61_UUID"
cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

//check if user can see this configuration
(cQryT3)->(DbGoTop())
While (cQryT3)->(!EOF())
    //For wach line at F61 as must check the shared values
    cQuery:="SELECT R_E_C_N_O_ as recLine, * FROM " + RetSqlName("F61")
    cQuery+=" WHERE F61_ROUTIN = '"+cRoutine+"' AND D_E_L_E_T_='' and F61_UUID='"+ (cQryT3)->F61_UUID+"' and F61_PARAM in ('SHARED','SHAREDVALUE')"
    cQryT4:= GetNextAlias()
    cQuery:=ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT4, .T., .F.)
    If ( (cQryT4)->(!EOF()))
        //Get values
        cShare := ''
        cValue := ''
        (cQryT4)->(DbGoTop())
        While (cQryT4)->(!EOF())
            F61->(DBGoTo((cQryT4)->recLine))
            If alltrim((cQryT4)->F61_PARAM) == 'SHARED'
                cShare := alltrim(MSMM(F61->(F61_VALUE),,,,3))
            ElseIf alltrim((cQryT4)->F61_PARAM) == 'SHAREDVALUE'
                cValue := alltrim(MSMM(F61->(F61_VALUE),,,,3))
            Endif
            (cQryT4)->(dbSkip())
        EndDo
        (cQryT4)->(dbCloseArea())

        //check if user can see this configuration
        lVizualiz := .F.
        If  cShare=="All" 
            lVizualiz := .T.
        ElseIf (cShare=="User" .and. cValue == __cUserID)
            lVizualiz := .T.
        Elseif cShare=="Group"
            For nY:=1 to len(aGroupUser)
                If aGroupUser[nY] == cValue
                    lVizualiz := .T.
                    Exit
                Endif
            Next nY
        Endif

        //add at temporary table
        If lVizualiz
            cQuery:="SELECT  R_E_C_N_O_ as recLine,* FROM " + RetSqlName("F61")
            cQuery+=" WHERE F61_ROUTIN = '"+cRoutine+"' AND D_E_L_E_T_='' and F61_UUID='"+ (cQryT3)->F61_UUID+"' and F61_PARAM in ('NAME')"
            cQryT4:= GetNextAlias()
            cQuery:=ChangeQuery(cQuery)
            dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT4, .T., .F. )
            cnameF61 := ''
            If ( (cQryT4)->(!EOF()))            
                F61->(DBGoTo((cQryT4)->recLine))
                cnameF61 := alltrim(MSMM(F61->(F61_VALUE),,,,3))
            Endif
            (cQryT4)->(dbCloseArea())

            //Add Temporary Table
            If (RecLock(c2AliasTMP, .T.))
                (c2AliasTMP)->MARK           := Space(02)
                (c2AliasTMP)->UUID           := alltrim((cQryT3)->F61_UUID)
                (c2AliasTMP)->NAME           := cnameF61
                (c2AliasTMP)->SHARED         := cShare
                (c2AliasTMP)->SVALUE         := cValue
                (c2AliasTMP)->(MsUnlock())
            EndIf
        Endif
    Endif
    (cQryT3)->(dbSkip())
EndDo
(cQryT3)->(dbCloseArea())
DbSelectArea('F61')
Return

/*-----------------------------------------------------------------------
@Descrip.:  Preparing and calls functions for showing report without "wizard"
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function RU34S1006_RunReport()
    Local aFilEnt	 	as array
    Local aGetsEnt		as array
    Local aEntidades	as array
    Local aAccounts		as array
    Local cLoad			as character

    Private nWizStep	:= 1
    Private lSelFinDim  := .F.

    aPsListA:=aF61XData:=GetF61_Items(Alltrim(cSelParam))

    aFilEnt	 	:= {}
    aGetsEnt	:= {}
    aEntidades	:= {}
    aAccounts	:= {}
    cLoad		:= "RU34S10"

    If len(aParametro)==0
        Aadd(aParametro,{1,"Filial:" ,cFilFrom,"@" 	 ,""  ,""    ,"" ,120 ,.F. }) //"Filial:"
        Aadd(aParametro,{4,"",dDateFrom,"Date From:",40,,.F.}) //"Date From:"
        Aadd(aParametro,{4,"",dDateTo,"Date To:",40,,.F.}) //"Date To:"
        Aadd(aParametro,{1,"Currency:" ,cCurrency,"@" 	 ,""  ,""    ,"" ,120 ,.F. }) //"Currency:"
        Aadd(aParametro,{1,"Balance Type:" ,cBalType,"@" 	 ,""  ,""    ,"" ,120 ,.F. })//"Balance Type:"
        Aadd(aParametro,{1,"Division by:" ,cDivision,"@" 	 ,""  ,""    ,"" ,120 ,.F. })//"Division by:"
        Aadd(aParametro,{1,"Show gr. balance:", cGrBalance, "@", "", "", "", 120, .F. })//"Show Grouped balance:"
        Aadd(aParametro,{1,"Show sum. l.a.:", cSumLedAcc, "@", "", "", "", 120, .F. })//"show summarized ledger account :"
        Aadd(aParametro,{1,"Show l.a. desc.:", cLedAccDsc, "@", "", "", "", 120, .F. })//"show ledger account description:"
    Endif
    SetPrvt("MV_PAR01")
    SetPrvt("MV_PAR02")
    SetPrvt("MV_PAR03")    
    SetPrvt("MV_PAR04")
    SetPrvt("MV_PAR05")
    SetPrvt("MV_PAR06")
    SetPrvt("MV_PAR07")
    SetPrvt("MV_PAR08")
    SetPrvt("MV_PAR09")

    If lSelParam
        MV_PAR01 := left(GetPS_PAR("MV_PAR01")+space(120),120)
        MV_PAR02 := STOD(GetPS_PAR("MV_PAR02"))
        MV_PAR03 := STOD(GetPS_PAR("MV_PAR03"))
        MV_PAR04 := left(GetPS_PAR("MV_PAR04")+space(120),120)
        MV_PAR05 := left(GetPS_PAR("MV_PAR05")+space(120),120)
        MV_PAR06 := left(GetPS_PAR("MV_PAR06")+space(120),120)
        MV_PAR07 := left(GetPS_PAR("MV_PAR07")+space(120),120)
        MV_PAR08 := left(GetPS_PAR("MV_PAR08")+space(120),120)
        MV_PAR09 := left(GetPS_PAR("MV_PAR09")+space(120),120)
    Else
        MV_PAR01 := ParamLoad(cLoad,aParametro,1,aParametro[1,3],Iif(Len(aParametro[1])>10,aParametro[1,10],.F.))
        MV_PAR02 := ParamLoad(cLoad,aParametro,2,aParametro[2,3],Iif(Len(aParametro[2])>10,aParametro[2,10],.F.))
        MV_PAR03 := ParamLoad(cLoad,aParametro,3,aParametro[3,3],Iif(Len(aParametro[3])>10,aParametro[3,10],.F.))
        MV_PAR04 := ParamLoad(cLoad,aParametro,4,aParametro[4,3],Iif(Len(aParametro[4])>10,aParametro[4,10],.F.))
        MV_PAR05 := ParamLoad(cLoad,aParametro,5,aParametro[5,3],Iif(Len(aParametro[5])>10,aParametro[5,10],.F.))
        MV_PAR06 := ParamLoad(cLoad,aParametro,6,aParametro[6,3],Iif(Len(aParametro[6])>10,aParametro[6,10],.F.))
        MV_PAR07 := ParamLoad(cLoad,aParametro,7,aParametro[7,3],Iif(Len(aParametro[7])>10,aParametro[7,10],.F.))
        MV_PAR08 := ParamLoad(cLoad,aParametro,8,aParametro[8,3],Iif(Len(aParametro[8])>10,aParametro[8,10],.F.))
        MV_PAR09 := ParamLoad(cLoad,aParametro,9,aParametro[9,3],Iif(Len(aParametro[9])>10,aParametro[9,10],.F.))
    Endif
    //preparing for report
    SelAccount(, @aAccounts)
    ValSelAcc(@aAccounts)
    SelEntit(, @aEntidades)
    ValSelEnt(@aEntidades, @aLevelsEn)
    FilEnti(,@aFilEnt,@aGetsEnt,@aLevelsEn,,@aLevelTabE)
    ValFIlGen()

    //report building
    Process()
Return


/*-----------------------------------------------------------------------
@Descrip.:  Recreating temp table
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static Function RU34S1007_RecreateTable()
oTempTable:=Nil
//Instance of Temporary Table
oTempTable := FWTemporaryTable():New()
//Set Fields
oTempTable:SetFields(aStruct)

oTempTable:AddIndex("INDEX1", {"UUID"} )
//Create
oTempTable:Create()
c2AliasTmp := oTemptable:GetAlias()

Return

/*-----------------------------------------------------------------------
@Descrip.:  
@author 	Nikitenko Artem                     @Date 08/05/2020
@version 	1.0                                 @project	MA3
@param		
@return		
-----------------------------------------------------------------------*/
Static function RU34S1008_ChCompare(cCHeckChar,cBaseChar,nPosInArr)
Local iRet as logical
iRet:=.F.
if alltrim(cCHeckChar)==cBaseChar
    iRet:=.T.
    if cCHeckChar=="User" .and. empty(alltrim(cUserf61))
        cUserf61:=__cUserID
    elseif cCHeckChar=="Group" .and. empty(alltrim(aPsListA[nPosInArr][2]))
        aPsListA[nPosInArr][2]:=UsrRetGrp(,__cUserID)[1]
    endif
Elseif cBaseChar=="User"
    cUserf61:='   '
ElseIf cBaseChar=="Group"
    aPsListA[nPosInArr][2]:="      "
Endif
Return iRet


/*/{Protheus.doc} RU34S1002
Call save parameter from result screen, all threatments do close and open correct
@type function
@author Rafael Gonçalves
@since Jun|2020
@version 1.0
@param 
@return nRet (0-nothing to do, 1-run routine with wizard, 2-run routine without wizard)
/*/
Function RU34S1002()
Local lRet          as Logical
Local nRet          as Numeric
lRet        := .F.
lShowWiz    := .F.
nRet        := 0
nOper       := 0
Processa( {||lRet:=RU34S10RB()}, STR0056 , STR0057 , .T. )//"Please Wait..." "Processing Entities!"
If lRet //retun some operation that need close and start sgain main dialog
    GetF61_header({"NAME","SHARED","SHAREDVALUE"},"RU34S10")
    If lShowWiz
        if RU34S10WIZ()
            nRet := 1
        Endif
    Else
        nRet := 2
    Endif
Endif
Return nRet //if true, close main dialog and call process (create main dialod again)


/*/{Protheus.doc} FSFLILCH
Function that retun the correct filial string to be used at joins
@type function
@author Rafael Gonçalves
@since Jul|2020
@version 1.0
@param 
@return string with correct value to be used at join
/*/
Static Function FSFILCH(cOrigin,cDestinat,cDestBranch)
Local cOrgEmp   as Character //Origin Company shared
Local cOrgUn    as Character //Origin Unit shared
Local cOrgFil   as Character //Origin Branch shared
Local cDesEmp   as Character //Destin Company shared
Local cDesUn    as Character //Destin Unit shared
Local cDesFil   as Character //Destin Branch shared
Local cReturn   as Character //Return

cReturn := cDestBranch
cOrgEmp	:= FWModeAccess(cOrigin,1) //Empresa
cOrgUn	:= FWModeAccess(cOrigin,2) //Unidade de Negocio
cOrgFil	:= FWModeAccess(cOrigin,3) //Filial
cDesEmp	:= FWModeAccess(cDestinat,1) //Empresa
cDesUn	:= FWModeAccess(cDestinat,2) //Unidade de Negocio
cDesFil	:= FWModeAccess(cDestinat,3) //Filial

//Check tables shared information for filial
If !(cOrgEmp+cOrgUn+cOrgFil) == (cDesEmp+cDesUn+cDesFil) //equal, no changes necessary
    cReturn := "'"+space(FWSizeFilial())+"'" //when origin is shared, this is the final condition
    //If they table shared are diferen, adjust the information from destinitarion
    If cOrgFil $ 'E'
        cReturn := 'SUBSTRING('+cDestBranch+',1,'+cvaltochar(Len(FWSizeFilial()))+')'
    EndIf
    If cOrgUn $ 'E' .and. Empty(cReturn)
        cReturn := 'SUBSTRING('+cDestBranch+',1,'+cvaltochar(Len(FWSM0LayOut(,1))+Len(FWSM0LayOut(,2)))+')'
    EndIf
    If cOrgEmp $ 'E' .and. Empty(cReturn)
        cReturn := 'SUBSTRING('+cDestBranch+',1,'+cvaltochar(Len(FWSM0LayOut(,1)))+')'
    EndIf
Endif
Return cReturn

