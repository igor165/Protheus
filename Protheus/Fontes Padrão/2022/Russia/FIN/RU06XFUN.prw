#INCLUDE "PROTHEUS.CH"    
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RU06XFUN.CH"
#INCLUDE "RWMAKE.CH"

Static __cRuPrf 		:='' // used for filters  FINXFIN02_FILFilter(),  Function FINXFIN01_BCOFilter()
/*/
{Protheus.doc} RU06XFUN01_CleanFlds()
Function to load empty values to the list of character fields
if lRelacao is .T., fields in aFields will be initialized by
functions located in x3_relacao
@author natalia.khozyainova
@since 12/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN01_CleanFlds(aFields as Array, lRelacao As Logical)
Local nX     As Numeric
Local bBlock As Block
Local cRunFn As Character
Local xVal

Default lRelacao := .F.

If ValType(aFields)=='A' 
    For nX:=1 to Len(aFields)
        If !lRelacao .OR. Empty(GetSX3Cache(aFields[nX],"X3_RELACAO"))
            If     GetSX3Cache(aFields[nX],"X3_TIPO") == "C"
                FwFldPut(aFields[nX],"",,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "N"
                FwFldPut(aFields[nX],0,,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "M"
                FwFldPut(aFields[nX],"",,,,.T.)
            ElseIf GetSX3Cache(aFields[nX],"X3_TIPO") == "D"
                FwFldPut(aFields[nX],STOD(".."),,,,.T.)
            EndIf
        Else
            cRunFn := AllTrim(GetSX3Cache(aFields[nX],"X3_RELACAO"))
            bBlock := &("{|| "+ cRunFn + " }")
            xVal := Eval(bBlock)
            FwFldPut(aFields[nX],xVal,,,,.T.)
        EndIf
    Next nX    
EndIf
Return (Nil)

/*/
{Protheus.doc} RU06XFUN02_ShwFIL()
a query to FIL table which returns FIL->FIL_TIPO value if nNum=1 
or FIL->FIL_ACNAME value if nNum=2.
If nNum == 0 will be returnd array with next data:
{"type of account", "bank name", "account name", "supplier's name"}
called for initialisation of fields F47_, F49_, F4C_... TYPCC, BKRNAM
@param    Numeric        nNum     //1, 2, 0
          Character      cSupp    //Supplier
          Character      cUnit    //Unit
          Character      cBnk
          Character      cBIK
          Character      cAcc
@return   Variant        xRet     //If nNum == 0, will be returned array of values:
                                    {"_TYPCC","_BKNAME","_ACNAME", "_RECNAM"}, so
                                    this array can be extended in future. 
                                    If nNum == 1 returns TMPFIL->FIL_TIPO   (_TYPCC )
                                    If nNum == 2 returns TMPFIL->FIL_ACNAME (_ACNAME)
nothing found in FIL -> Empty string or array with empty strings will be returned
@author natalia.khozyainova
@since 12/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN02_ShwFIL(nNum as Numeric  , cSupp as Character, cUnit as Character,;
                           cBnk as Character, cBIK  as Character, cAcc  as Character )

    Local     cRet      As Character
    Local     cAlias    As Character
    Local     aArea     As Array
    Local     aRet      As Array
    Local     xRet
    Default   nNum := 1

    cRet := ""
    cAlias := RU06XFUN40_RetBankAccountDataFromFIL(cSupp,cUnit,Nil,cBnk,cBIK,cAcc,.T.)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        If     nNum == 1 // account type
            cRet := (cAlias)->(_TYPCC)
        ElseIf nNum == 2 // account name
            cRet := (cAlias)->(_ACNAME)
        ElseIf nNum == 0
            aRet := {(cAlias)->_TYPCC ,;
                     (cAlias)->_BKNAME,;
                     (cAlias)->_ACNAME,;
                     (cAlias)->_RECNAM }
        EndIf
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)


/*/
{Protheus.doc} RU06XFUN03_ShwSA6()
@param  Numeric     nNum    //1, 2, 0
        Character   cBnk    //bank code
        Character   cBIK    //BIC
        Character   cAcc    //Account
@return Variant     xRet    // in case nNum == 0:
will be returnd array with next data {"type of account", "bank name",
"account name", "reciever's or payer's name"} , so this array can be
extended in future.
                            // in case nNum != 0:  
                            if nNum == 1, -> A6_NOME   //bank name
                            if nNum == 2, -> A6_ACNAME //account name
nothing found in SA6 -> Empty string or array with empty strings 
@author natalia.khozyainova
@since 21/11/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06XFUN03_ShwSA6(nNum as Numeric  , cBnk as Character,;
                           cBIK as Character, cAcc as Character )

    Local       aArea       As Array
    Local       aRet        As Array
    Local       cAlias      As Character
    Local       cRet        As Character
    Local       xRet
    Default     nNum := 1
    cRet   := ""
    cAlias := RU06XFUN39_RetBankAccountDataFromSA6(cBnk, cBIK, cAcc, Nil, .T.)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DbGoTop()
    If !Eof()
        If     nNum == 1
            cRet := (cAlias)->_BKPNAM
        ElseIf nNum == 2
            cRet := (cAlias)->_ACPNAM
        ElseIf nNum == 0 
            aRet := {(cAlias)->_TYPCP ,;
                     (cAlias)->_BKPNAM,;
                     (cAlias)->_ACPNAM,;
                     (cAlias)->_PAYNAM }
        EndIf
    EndIF
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)

/*/
{Protheus.doc} RU06XFUN04_VldFIL()
@author natalia.khozyainova
@since 21/11/2018
@version 1.0
@project MA3 - Russia
This function validates bank account information located in FIL table and 
fills fields passed through aFlds array
How it works: Function recives several parameters: cCurr (Currency code), cBnk(Bank code), 
cBIK(Bank BIK or BIC), cAccount (Account number) and tries to find bank account information in FIL table 
using these parameters. If cAcc is Empty, or other parameter is Empty, it will be excluded from 
sql query, so sql query can return to us zero or several lines. SQl query located in 
RU06XFUN40_RetBankAccountDataFromFIL function.
cSupp (Supplier's code) and cUnit (supplier's loja) are obligatory, so if they are empty in normal case
will be returned .F.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case we should recieve
by sql query one or zero lines, if it is zero - it means no bank account information (lRet == .F.)
Alse you can use lForce( default: false) parameter setting it to .T.. If lForce is .T., doesn't matter
empty or not empty is cAcc parameter, all parameters will be included to SQL query
If lForce is .T. or cAcc is not empty, bank account information will be putted to fields in aFlds array.
Rule for aFlds items: For example aFlds[1] == "XXX_PAYBIK", if query result contains field "_PAYBIK", so
value of _PAYBIK will be putted in XXX_PAYBIK.
If lExClsd we exclude from result closed bank accounts.
/*/
Function RU06XFUN04_VldFIL(cSupp as Character, cUnit as Character, cCurr as Character, cBnk   as Character,;
                           cBIK  as Character, cAcc  as Character, aFlds as Array,     lForce as Logical  ,;
                           lExClsd as Logical                                                              )
    Local lRet        As Logical
    Local lFull       As Logical
    Local nMoeda      As Numeric
    Local nX          As Numeric
    Local nY          As Numeric
    Local cAlias      As Character
    Local cFieldName  As Character
    Local aSaveArea   As Array
    Local xFldVal
    Default lForce    := .F.
    Default lExClsd   := .F.

    nMoeda := IIF(ValType(cCurr) == "C" .AND. !Empty(cCurr), Val(cCurr), 0)
    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN40_RetBankAccountDataFromFIL(cSupp, cUnit, nMoeda, cBnk, cBik, cAcc,;
                                                       lFull, .T./*left join F45*/, lExClsd)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have account info in FIL
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            xFldVal := (cAlias)->(FieldGet(nX))
                            xFldVal := IIf(ValType(xFldVal) == "C", AllTrim(xFldVal),xFldVal)
                            FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.) 
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)

Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN41_VldF4N

Function can be used for validation customer's bank account info and 
filling fields passed through aFlds array if it is not empty

How it works: Function recives several parameters: cCurr (Currency code), cBnk(Bank code), 
cBIK(Bank BIK or BIC), cAccount (Account number) and tries to find bank account information 
in F4N table using these parameters. If cAcc is Empty, or other parameter is Empty, it will 
be excluded from sql query, so sql query can return to us zero or several lines. 
SQl query located in RU06XFUN42_RetBankAccountDataFromF4N function. 
cCust (Customer's code) and cUnit (customer's loja) are obligatory, so if they are empty 
in normal case will be returned .F.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case 
we should recieve by sql query one or zero lines, if it is zero - it means no bank account 
information (lRet == .F.).
Alse you can use lForce( default: false) parameter setting it to .T.. 
If lForce is .T., doesn't matter empty or not empty is cAcc parameter, all parameters will 
be included to SQL query.
If lForce is .T. or cAcc is not empty, bank account information will be putted to 
fields located in aFlds array. Rule for aFlds items: For example aFlds[1] == "XXX_PAYBIK", 
if query result contains field "_PAYBIK", so value of _PAYBIK will be putted in XXX_PAYBIK.

@param       Character          cCust       // Customer's code ->F4N_CLIENT
             Character          cUnit       // Customer's loja ->F4N_LOJA
             Character          cBnk        // Customer's bank code ->F4N->BANK
             Character          cBIK        // BIK ->F4N_BIK
             Character          cAcc        // Account number ->F4N_ACC
             Array              aField      // array of fields should be updated, not obrig
             Logical            lForce      // if .T. - all parmeters will be included to
                                            // sql query, .F. - nonempty parameters will
                                            // be included(default)          
@return      Logical            lRet        // .T. - ok, validated
@example     
@author      astepanov
@since       July/03/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN41_VldF4N(cCust As Character, cUnit  As Character, cCurr as Character,;
                           cBnk  As Character, cBIK   As Character, cAcc  as Character,;
                           aFlds As Array    , lForce As Logical                       )

    Local lRet       As Logical
    Local lFull      As Logical
    Local aSaveArea  As Array
    Local cAlias     As Character
    Local cFieldName As Character
    Local nX         As Numeric
    Local nY         As Numeric
    Local xFldVal
    Default lForce   := .F. 

    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN42_RetBankAccountDataFromF4N(cCust, cUnit, cCurr, cBnk, cBIK,;
                                                       cAcc, lFull)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have account info in F4N
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            xFldVal := (cAlias)->(FieldGet(nX))
                            xFldVal := IIf(ValType(xFldVal)=="C",AllTrim(xFldVal),xFldVal)
                            FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.) 
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)
    
Return (lRet) /*---------------------------------------------------------RU06XFUN41_VldF4N*/


/*/{Protheus.doc} RU06XFUN05_VldSA6
SA6 Fields validation 
@author natalia.khozyainova
@since 25/11/2018
@version 1.0
@project MA3 - Russia
This function validates bank account information and 
fills fields passed through aFlds array
cCurr is optional
How it works: Function recives several parameters: cCurr (Currency code),
cBnk(Bank code), cBIK(Bank BIK or BIC),
cAccount (Account number)  and tries to find bank account information in SA6 table using these parameters.
If cAcc is Empty, or other parameter is Empty, it will be excluded from sql query, so sql query can return
to us zero or several lines. SQl query located in RU06XFUN39_RetBankAccountDataFromSA6 function.
If cAcc is not empty, all parameters will be included in sql query - so, in normal case we should recieve
by sql query one or zero lines, if it is zero - it means no bank account information.
Alse you can use lForce( default: false) parameter setting it to .T.. If lForce is .T., doesn't matter
empty or not empty is cAcc parameter, all parameters will be included to SQL query
If lForce is .T. or cAcc is not empty, bank account information will be putted to fields in aFlds array.
Rule for aFlds items: For example aFlds[1] == "XXX_BKRNAM", if query result contains field "_BKRNAM", so
value of _BKRNAM will be putted in XXX_BKRNAM.
/*/
Function RU06XFUN05_VldSA6(cCurr as Character, cBnk as Character, cBIK as Character, cAcc as Character, aFlds as Array,;
                           lForce As Logical)

    Local lRet        As Logical
    Local lFull       As Logical
    Local nMoeda      As Numeric
    Local nX          As Numeric
    Local nY          As Numeric
    Local cAlias      As Character
    Local cFieldName  As Character
    Local aSaveArea   As Array
    Local xFldVal

    Default lForce    := .F. 

    nMoeda := IIF(ValType(cCurr) == "C" .AND. !Empty(cCurr), Val(cCurr), 0)
    lRet := .T.
    aSaveArea  := GetArea()
    lFull      := !Empty(cAcc) .OR. lForce
    If lRet
        cAlias := RU06XFUN39_RetBankAccountDataFromSA6(cBnk, cBIK, cAcc, nMoeda, lFull)
        DBSelectArea(cAlias)
        DBGoTop()
        If !Eof() // bank account was found
            If !Empty(aFlds) .AND. lFull            //fill fields from aFlds when  
                For nX := 1 To (cAlias)->(FCOUNT()) //we already have all account info in SA6
                    cFieldName := AllTrim((cAlias)->(FIELD(nX)))
                    For nY := 1 To Len(aFlds)
                        If  cFieldName $ aFlds[nY]
                            If nMoeda == 0 .AND. cFieldName == "_CURREN"
                                FwFldPut(aFlds[nY],;
                                        PADL(AllTrim(STR((cAlias)->(FieldGet(nX)))),;
                                        GetSX3Cache(aFlds[nY],"X3_TAMANHO"),"0"   );
                                        ,,,.T.,.T.)
                                RunTrigger(1,Nil,Nil,,"F60_CURREN")
                            ElseIf nMoeda != 0 .AND. cFieldName == "_CURREN"
                                xFldVal := (cAlias)->(FieldGet(nX))
                                xFldVal := PADL(AllTrim(STR(xFldVal)), GetSX3Cache(aFlds[nY],"X3_TAMANHO"),"0"   )
                                FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.)
                            Else
                                xFldVal := (cAlias)->(FieldGet(nX))
                                xFldVal := IIf(ValType(xFldVal) == "C",AllTrim(xFldVal),xFldVal)
                                FwFldPut(aFlds[nY],xFldVal,,,.T.,.T.)
                            EndIf   
                        EndIf 
                    Next nY
                Next nX
            EndIf
        Else
            lRet := .F. // no bank account
        EndIf
        (cAlias)->(DBCloseArea())
    EndIf
    RestArea(aSaveArea)

Return (lRet)

/*/{Protheus.doc} RU06XFUN06_GetOpenBalance
Function Used to restore the Open balance of the accounts payable 
Subtracting all the values that is already used in any Bank Statement Process.
@author natalia.khozyainova
@since 27/11/2018
@version 1.1
@edit   astepanov 11 July 2019
@Parameter 
cSe2Key: String with key Fields of SE2 used to find the Specified Register
in the format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA
@Return
nOpBal: Numeric with the Value considering the E2_SALDO- SUM(F5M_VALPAY) to the related cSe2Key
@project MA3 - Russia
/*/
Function RU06XFUN06_GetOpenBalance(cSe2Key)

    Local nOpBal    As Numeric
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array

    aSaveArea := GetArea()
    cQuery:= RU06XFUN55_QuerryF5MBalance(cSe2Key) // set the querry 
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nOpBal := (cAlias)->SALDO - (cAlias)->TOTAL
    Else
        nOpBal := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)

Return (nOpBal)


/*/{Protheus.doc} RU06XFUN07_WrToF5
Function to write a line in F5M table at the moment of ebtries in Payment Request, Payment Order or Bank Statement Creation/Edition/Deletion
@author natalia.khozyainova
@since 28/11/2018
@version 1.0
@Parameter 
cIdDoc: Unique ID of Document F47_IDF47, F48_UUID, F49_IDF49, F4B_UUID, F4C_CUUID
cAlias: Name of a tabel: F47, F48, F49, F4B, F4C
cKeyF5M: format is E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNRCE|E2_LOJA with the spaces
nValue: line amount to pay
cCtrlBal: 1 or 2. 1 means line participates on Open balance calculation
nOper: Operation to perform on F5M, can be 1 or 2. 1 means - update or create line, 2 menas - delete line
cFil: Filial
lCtrBalOnl : update only F5M_CTRBAL, so it have senese when nOper == 1 , and we have F5M record for update,
             Default  - .F.
nVALCNV -> F5M_VALCNV
nBSVATC -> F5M_BSVATC
nVLVATC -> F5M_VLVATC
@Return
nil
@project MA3 - Russia
/*/
Function RU06XFUN07_WrToF5(cIdDoc  as Character, cAlias     as Character, cKeyF5M as Character,;
                           nValue  as Numeric  , cCtrlBal   as Character, nOper   as Numeric  ,;
                           cFil    as Character, lCtrBalOnl as Logical  , nVALCNV as Numeric  ,;
                           nBSVATC as Numeric  , nVLVATC    as Numeric                         )
// nOper==1 is update or create, nOper==2 is deletion
Local aSaveArea as Array
Default cFil:=xFilial("F5M")
Default cIdDoc:=""
Default cAlias:=""
Default cKeyF5M:=""
Default nValue:=0
Default cCtrlBal:="2"
Default nOper:=0
Default lCtrBalOnl := .F.
Default nVALCNV := 0
Default nBSVATC := 0
Default nVLVATC := 0

aSaveArea:=GetArea()

If nOper==1 .and. !Empty(cIdDoc) .and. !(Empty(cKeyF5M) .and. cCtrlBal=="1")
    DBSELECTAREA("F5M")
    DBSETORDER(1)
    If !lCtrBalOnl
        If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
            RECLOCK("F5M",.F.)
        Else
            RECLOCK("F5M",.T.)
        EndIf
        F5M->F5M_FILIAL:=cFil
        F5M->F5M_IDDOC:=cIdDoc
        F5M->F5M_ALIAS:=cAlias
        F5M->F5M_VALPAY:=nValue
        F5M->F5M_CTRBAL:=cCtrlBal
        F5M->F5M_KEY:=cKeyF5M
        F5M->F5M_VALCNV := nVALCNV
        F5M->F5M_BSVATC := nBSVATC
        F5M->F5M_VLVATC := nVLVATC
        MSUNLOCK()
    Else //just update F5M_CTRBAL
        If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
            RECLOCK("F5M",.F.)
            F5M->F5M_CTRBAL:=cCtrlBal
            MSUNLOCK()
        EndIf
    EndIf
ElseIf nOper==2 .and. !Empty(cIdDoc)
    DBSELECTAREA("F5M")
    DBSETORDER(1)
	If DBSEEK(cFil+cAlias+cIdDoc+cKeyF5M )
		RECLOCK("F5M")
		DBDELETE()
		MSUNLOCK()
    EndIf
EndIf

Return(Nil)

/*/{Protheus.doc} RU06XFUN08_SetOpenBalance
Function Used to Set the Locked balance of the accounts payable related to the bank statement process.
@author natalia.khozyainova
@since 28/11/2018
@version 1.0
@Parameter 
cNewUuid : Mandatory. UUID related to the new register in table F5M. Will be the content of the field F5M_IDDOC (to add)
cNewAlias: Mandatory. Alias related to the new register in table F5M. Will be the content of the field F5M_ALIAS (to add)
nValPay  : Mandatory. Value related to the new register in table F5M. Will be the content of the field F5M_VALPAY (to add) 
cCtrBal  : Optional. Flag if this settlement control balance 
1-Control Ballance 	
2-don`t control Ballance (default)	
cSe2Key  : Optional. Key Fields of SE2 used to link the Specified Register with an account payable when this link exists (to add and for search) 
Format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA with spaces
cOldUuid : Optional. UUID related to the old register in table F5M that we need to delete (for search nd to delete)
cOldAlias: Optional. Alias related to the old register in table F5M that we need to delete (for search and to delete)
@Return
lReturn: Logic return showing if all the process occurs ok
@project MA3 - Russia
/*/
Function RU06XFUN08_SetOpenBalance(cNewUuid as Character, cNewAlias as Character, nValPay as Numeric, cCtrBal as Character, cSe2Key as Character, cOldUuid as Character, cOldAlias as Character)
Local lRet as Logical
Default cNewUuid:=""
Default cNewAlias:=""
Default cSe2Key:=""
Default nValPay:=0
Default cCtrBal:="2"
Default cOldUuid:=""
Default cOldAlias:=""
lRet:=.F.
If !Empty(cOldUuid) .and. !Empty(cOldAlias)
    RU06XFUN07_WrToF5(cOldUuid, cOldAlias, cSe2Key, , , 2)// delete if old line exists
    RU06XFUN07_WrToF5(cNewUuid, cNewAlias, cSe2Key, nValPay, cCtrBal, 1)
    lRet:=.T.
EndIf
Return (lRet) 

/*/{Protheus.doc} RU06XFUN09_RetSE2F5MJoinOnString
Function returns string to join part of sql query
when we try join SE2 line to F5M line, because F5M_KEY field
constructs from: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_LOJA ... so on
So, we don't use RPAD (Transact-SLQ doesn't support it), we use TRIM and
SUBSTRING which can be easly converted to SUBSTR for Oracle DBMS.
@author natalia.khozyainova
@since 28/11/2018
@version 1.3
@edit astepanov 16 July 2019
@param   Character        cFMTN       // F5M table alias name
@edit avelmozhnya 29 January 2020
@param   Logical          lInflow       // Bank Statment direction
@return  Character        cJoinLn   
@project MA3 - Russia
/*/
Function RU06XFUN09_RetSE2F5MJoinOnString(cFM5TNA As Character, lInflow as Logical)

    Local cJoinLn    As Character
    Local cTabName   As Character
    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local aKs        As Array
    Default cFM5TNA  := "F5M"
    Default lInflow := .F.

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cTabName := Iif(lInflow,"SE1.E1","SE2.E2")
    
    cJoinLn := " TRIM("+cTabName+"_FILIAL)  = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cFS+","+cFE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_PREFIXO) = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cPS+","+cPE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_NUM)     = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cNS+","+cNE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_PARCELA) = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cRS+","+cRE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_TIPO)    = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cTS+","+cTE+")) AND "
    cJoinLn += " TRIM("+cTabName+Iif(lInflow,"_CLIENTE)","_FORNECE)")+" = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cCS+","+cCE+")) AND "
    cJoinLn += " TRIM("+cTabName+"_LOJA)    = TRIM(SUBSTRING("+cFM5TNA+".F5M_KEY,"+cLS+","+cLE+"))     "
   
Return(cJoinLn)

/*/{Protheus.doc} RU06XFUN10_PickUpAPs
This function has inside the Group of Questions for picking up Accounts Payables (items to F48) and
the window with markbrowse
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06XFUN10_PickUpAPs(cHeadAlias AS Character, lInflow as Logical)
Local cPerg       as Character
Local cProgName   as Character
Local cHeadModel  as Character
Local lRet        as Logical
Local lInAdvance  as Logical
Local oModel      as Object

Default lInflow := .F.

Do Case
    Case cHeadAlias == 'F47'
        cProgName := 'RU06D04'
        lInAdvance := FwFldGet(cHeadAlias + "_PREPAY") != '1'
    Case cHeadAlias == 'F49'
        cProgName := 'RU06D06'
        lInAdvance := FwFldGet(cHeadAlias + "_PREPAY") != '1'
    Case cHeadAlias == 'F4C'
        cProgName := 'RU06D07'
        lInAdvance := IIf(lInflow,FwFldGet(cHeadAlias + "_PREREC") != '1',FwFldGet(cHeadAlias + "_PREPAY") != '1')
EndCase

If cProgName = "RU06D06"
    cHeadModel := "RU06D05_MF49"
Else
    cHeadModel := cProgName + "_MHEAD"
EndIf
If lInAdvance // if not prepayment
    If IIf(lInflow,Empty(FwFldGet(cHeadAlias + "_CUST")),Empty(FwFldGet(cHeadAlias + "_SUPP")) )
        If lInflow
            Help("",1,STR0060,,STR0058,1,0,,,,,,{STR0059}) //Client data -- Client is not selected -- Select Client
        Else
            Help("",1,STR0001,,STR0030,1,0,,,,,,{STR0031}) //Supplier data -- Supplier is not selected -- Select supplier
        EndIf
    ElseIf  IIf(lInflow,;
            !(ExistCpo("SA1",FwFldGet(cHeadAlias + "_CUST") + FwFldGet(cHeadAlias + "_CUNI"))),; // something is wrong with client code/unit
            !(ExistCpo("SA2",FwFldGet(cHeadAlias + "_SUPP") + FwFldGet(cHeadAlias + "_UNIT")))) // something is wrong with supplier code/unit
            If lInflow
                Help("",1,STR0060,,STR0061,1,0,,,,,,{STR0062}) // Client data -- Client Code and Unit not valid -- Change Client data
            Else
                Help("",1,STR0001,,STR0002,1,0,,,,,,{STR0003}) // Supplier data -- Supplier Code and Unit not valid -- Change supplier data
            EndIf
    ElseIf lInflow .And. Vazio(FwFldGet(cHeadAlias + "_VALUE") )
        Help("",1,STR0020,,STR0063,1,0,,,,,,{STR0064}) // Balance -- Operation is unavailable -- Fill in the amount field
    Else
        oModel:= FWModelActive()
        cPerg := "RUD604" 
        // Update initial Ranges in Group of Questions:
        If Empty(FwFldGet(cHeadAlias+"_CURREN"))
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR09",Replicate(" ",TamSX3(cHeadAlias + "_CURREN")[1]))
            SetMVValue(cPerg,"MV_PAR10",Replicate("Z",TamSX3(cHeadAlias + "_CURREN")[1]))
        Else
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR09", oModel:GetValue(cHeadModel,cHeadAlias + '_CURREN'))
            SetMVValue(cPerg,"MV_PAR10", oModel:GetValue(cHeadModel,cHeadAlias + '_CURREN'))
        Endif

        If Empty(FwFldGet(cHeadAlias + "_CNT"))
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR07",Replicate(" ",TamSX3(cHeadAlias + "_CNT")[1]))
            SetMVValue(cPerg,"MV_PAR08",Replicate("Z",TamSX3(cHeadAlias + "_CNT")[1]))
        Else
            // in case when user has 'last values' from pergunta stored in system table
            SetMVValue(cPerg,"MV_PAR07",oModel:GetValue(cHeadModel,cHeadAlias + '_CNT'))
            SetMVValue(cPerg,"MV_PAR08",oModel:GetValue(cHeadModel,cHeadAlias + '_CNT'))
        Endif
        
        lRet:= Pergunte(cPerg,.T.,IIf(lInflow,STR0065,STR0004),.F.) // Pick Up APs

        If lRet
            RU06XFUN12_MBRW(cHeadAlias, cProgName, lInflow) // MarkBrowse is here
        Endif
    EndIf
Else
    Help("",1,IIf(lInflow,STR0065,STR0004),,IIf(lInflow,STR0066,STR0005),1,0,,,,,,{STR0006}) // Pick Up APs -- Not allowed APs in Prepayment - Change type to add bills 
EndIf
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN12_MBRW
This function will create and process the markbrowse window 
where we choose Bils for Payment Request
@author natalia.khozyainova
@since 11/12/2018
@version 3.0
@edit   astepanov 12 July 2019
@project MA3 - Russia
/*/
Function RU06XFUN12_MBRW(cHeadAlias as Character, cProgName as Character, lInflow as Logical)
    Local aSize        As Array
    Local aColumns     As Array
    Local aFields      As Array
    Local aInp         As Array
    Local aForView     As Array
    Local aArea        As Array
    Local nX           As Numeric
    Local nY           As Numeric
    Local nZ           As Numeric
    Local cErrMsg      As Character
    Local cFldOK       As Character

    Private oMoreDlg   As Object
    Private oBrowsePut As Object
    Private oTempTable As Object
    Private cTempTbl   As Character
    Private cMark      As Character

    Default lInflow := .F.

    aArea := GetArea()
    // Create temporary table
    // "Please wait"  "Creating temporary table"
    MsgRun(STR0007,STR0008,{|| aInp := RU06XFUN15_MyCreaTRB(cHeadAlias, cProgName, lInflow)})
    // aInp == {FWtemporaryTable, aFields, cErrMsg}
    oTempTable := aInp[1]
    aFields    := aInp[2]
    cErrMsg    := aInp[3]
    If Empty(cErrMsg)
        cTempTbl   := oTempTable:GetAlias()
        DBSelectArea(cTempTbl)
        DBGoTop()
        If !((cTempTbl)->(Eof()))
            aColumns 	:= {}
            If lInflow
                 aForView    := {"E1_PREFIXO", "E1_NUM"    , "E1_PARCELA",;
                                "E1_TIPO"   , "E1_EMISSAO", "E1_VENCREA",;
                                "CTO_MOEDA" , "E1_CONUNI" , "E1_VALOR"  ,;
                                "E1_BALANCE"                             }
            Else
                aForView    := {"E2_PREFIXO", "E2_NUM"    , "E2_PARCELA",;
                                "E2_TIPO"   , "E2_EMISSAO", "E2_VENCREA",;
                                "CTO_MOEDA" , "E2_CONUNI" , "E2_VALOR"  ,;
                                "E2_BALANCE"                             }
            EndIf
            For nX := 1 To  Len(aForView)
                For nY := 1 To Len(aFields)
                    If AllTrim(aForView[nX]) == AllTrim(aFields[nY][1])
                        AADD(aColumns, FWBrwColumn():New())
                        nZ := Len(aColumns)
                        aColumns[nZ]:SetData(&("{||"+aFields[nY][1]+"}"))
                        aColumns[nZ]:SetTitle(aFields[nY][6]  ) 
                        aColumns[nZ]:SetSize(aFields[nY][3]   )
                        aColumns[nZ]:SetDecimal(aFields[nY][4])
                        aColumns[nZ]:SetPicture(aFields[nY][5])
                        If aFields[nY][2] == "N" // https://jiraproducao.totvs.com.br/browse/RULOC-369
                            aColumns[nZ]:SetAlign(2) // 0-center, 1-left, 2-right
                        EndIf
                    EndIf
                Next nY
            Next nX
            aSize	 := MsAdvSize()
            oMoreDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5],;
                                        STR0021, , , , , CLR_BLACK, CLR_WHITE,;
                                        , , .T., , , , .T.                     )
            oBrowsePut := FWMarkBrowse():New()
            cFldOK := IIf(lInflow,"E1_OK","E2_OK")
            oBrowsePut:SetFieldMark(cFldOK)
            oBrowsePut:SetOwner(oMoreDlg)
            oBrowsePut:SetAlias(cTempTbl)
            oBrowsePut:SetMenuDef("")
            oBrowsePut:SetColumns(aColumns)
            oBrowsePut:bAllMark := {||RU06XFUN16_MarkAll(oBrowsePut,cTempTbl,cFldOK)}
            oBrowsePut:DisableReport()
            oBrowsePut:SetIgnoreARotina(.T.)
            oBrowsePut:AddButton(STR0012, {||RU06XFUN13_CloseMBrowse()},0, 1)   //Cancel
            Do Case 
                Case cProgName == "RU06D04"     //Payment Request
                    oBrowsePut:AddButton(STR0011, {||RU06D04WR()},0, 3)                 //Add
                    oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                //Show Bill Details 
                Case cProgName == "RU06D06"     //Payment Orders without payment requsts
                    // oBrowsePut:AddButton(STR0011, {||RU06D06001_AddBills(oTempTable, oMoreDlg, cMark)},0, 3) //Add Incluir no proximo release
                    oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                                     //Show Bill Details 
                Case cProgName == "RU06D07"    //Bank Statement
                    oBrowsePut:AddButton(STR0011, {||RU06D0722_WriteFromMBr(oTempTable, oMoreDlg, cMark)},0, 3)   //Add          
                    If lInflow
                        oBrowsePut:AddButton(STR0013, {||RU06D07011_ShowInflowBill()},0, 1) //Show Bill Details
                        oBrowsePut:AddButton(STR0067, {||RU06XFUN14_AddByRules("FIFO",oTempTable, oMoreDlg, cMark, oBrowsePut)},0, 8) //"Add FIFO"
                        oBrowsePut:AddButton(STR0068, {||RU06XFUN14_AddByRules("EXACT",oTempTable, oMoreDlg, cMark, oBrowsePut)},0, 8) //"Add Exact Value"
                    Else
                        oBrowsePut:AddButton(STR0011, {||RU06D0722_WriteFromMBr(oTempTable, oMoreDlg, cMark)},0, 3)   //Add
                        oBrowsePut:AddButton(STR0013, {||R0604ShwBl()},0, 1)                  //Show Bill Details  
                    EndIf
            EndCase
            
            oBrowsePut:Activate()
            cMark := oBrowsePut:Mark()
            oMoreDlg:Activate(,,,.T.,,,)
            aRotina	 := MenuDef() //Return aRotina
            (cTempTbl)->(DBCloseArea())
            oTempTable:Delete()
        Else
            Help("",1,STR0009,,STR0010,; //No bills found, Change Group of Questions
                 1,0,,,,,,/*{'solution'}*/) 
        EndIf
    Else
        Help("",1,"TSQLError()",,cErrMsg,;
             1,0,,,,,,/*{'solution'}*/) // Error during sql query execution
    EndIf
    RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} RU06XFUN13_CloseMBrowse
Cancel Button - close window
@param	oModel	
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN13_CloseMBrowse()
oMoreDlg:End()
Return (.F.)

/*/{Protheus.doc} RU06XFUN14_AddByRules
Function for adding Biils according specific rules (FIFO, EXACT Value)
@author eduardo.flima
@edit   alexandra.velmozhnaia
        20/03/2020
@since 18/03/2020
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN14_AddByRules(cRule, oTempTable, oMoreDlg, cMark, oBrowsePut)
Local lRet       as Logical
Local nDifVlpay  as Numeric
Local aTotals    as Array
Local oModel     as Object
Local oModelF4C  as Object
Local oModelVrt  as Object

Default cRule := "FIFO"
Do Case 
    Case cRule == "FIFO"
        lRet := RU06D07014_AddFIFO(@oTempTable, @oMoreDlg, @cMark, @oBrowsePut)
    Case cRule == "EXACT"
        lRet:=  RU06D07015_AddExactValue(@oTempTable, @oMoreDlg, @cMark, @oBrowsePut)
EndCase
If lRet
    RU06D0722_WriteFromMBr(@oTempTable, @oMoreDlg, @cMark)
Endif

If lRet .And. cRule == "FIFO"
    oModel := FWModelActive()
    oModelF4C := oModel:GetModel("RU06D07_MHEAD")
    oModelVrt := oModel:GetModel("RU06D07_MVIRT")
    nDifVlpay := oModelF4C:GetValue("F4C_ITBALA")
    
    //Fix payment value in last line
    If nDifVlpay < 0
        oModelVrt:GoLine(oModelVrt:Length())
    // Difference in currency of bill
        If oModelVrt:GetValue("B_CONUNI") == "1"
            nDifVlpay := xMoeda(nDifVlpay /*Value */,;
                                1 /* Currency from*/,;
                                oModelVrt:GetValue("B_CURREN")/* Currency to*/ ,;
                                oModelF4C:GetValue("F4C_DTTRAN") /* Date of exchage rate*/  ,;
                                GetSX3Cache("F48_VALPAY", "X3_DECIMAL")  /* Decimal*/)
        EndIf
        lRet := RU06D07E2_RecalcVlsForNonPA("B_VALPAY"/*cID*/,;
                                        oModelVrt:GetValue("B_VALPAY")+nDifVlpay/*xNVal*/,;
                                        oModelVrt:GetValue("B_VALPAY")/*xCVal*/,;
                                        oModelVrt/*oModel*/,;
                                        oModelF4C/*oMdlHdr*/)
        lRet := lRet .And. oModelVrt:LoadValue("B_VALPAY",oModelVrt:GetValue("B_VALPAY")+nDifVlpay)

        // Update Total Values according fixing in last line of grid
        aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT",.T.)
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITBALA", oModelF4C:GetValue("F4C_VALUE") - aTotals[1])

        nDifVlpay := oModelF4C:GetValue("F4C_ITBALA")
        // check rounding error
        If nDifVlpay <> 0 .And. oModelVrt:GetValue("B_CONUNI") == "1"
            lRet := RU06D07E2_RecalcVlsForNonPA("B_VALCNV"/*cID*/,;
                                        oModelVrt:GetValue("B_VALCNV")+nDifVlpay/*xNVal*/,;
                                        oModelVrt:GetValue("B_VALCNV")/*xCVal*/,;
                                        oModelVrt/*oModel*/,;
                                        oModelF4C/*oMdlHdr*/)
            lRet := lRet .And. oModelVrt:LoadValue("B_VALCNV",oModelVrt:GetValue("B_VALCNV")+nDifVlpay)
        EndIf

        lRet := lRet .And. RU06D07E9_UpdateF5MLine(oModelVrt/*oSubModel*/, oModelF4C/*oMdlHdr*/, "UPDATE"/*cAction*/)

        // Update Total Values according fixing in last line of grid
        aTotals := RU06D07E7_RetTotalsForHeader(oModelVrt, "VRT",.T.)
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITTOTA",aTotals[1])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATF",aTotals[2])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITVATO",aTotals[3])
        lRet := lRet .And. oModelF4C:LoadValue("F4C_ITBALA", oModelF4C:GetValue("F4C_VALUE") - aTotals[1])
        oModelVrt:GoLine(1)
    EndIf
EndIf
If lRet
    oBrowsePut:GetOwner():End()
EndIf

Return Nil

/*/{Protheus.doc} RU06XFUN15_MyCreaTRB
Create temporary table and insert data into it
Please, extend aFieldList array if you need it.
@param	cHeadAlias - Header table name
        cProgName  - Source name (RU06D04 or RU06D07)
@return		Array      aRet {oTempTable , aFields, cErrMsg}
                                         // temporary table which was created, +
                                         // array of fields with parameters for view, 
                                         // + cErrMsg, if all ok with qeuries
                                         // cErrMsg will be Empty
@author natalia.khozyainova
@since 11/12/2018
@edit   astepanov 11 July 2019
@version 3.0
@type function
/*/
Static Function RU06XFUN15_MyCreaTRB(cHeadAlias As Character, cProgName As Character, lInflow as Logical)
    Local aFields    As Array
    Local aRet       As Array
    Local aFields2   As Array
    Local aInp       As Array
    Local aInpSE2F5M As Array
    Local aArea      As Array
    local cQuery     As Character
    Local oModel     As Object
    Local oModelHead As Object
    Local oModelDet  As Object
    Local oTmpTab2   As Object
    Local oTempTable As Object
    Local oTmpSE2    As Object
    Local oTmpF5M    As Object
    Local oTmpPST    As Object
    Local cSupp      As Character
    Local cUnit      As Character
    Local cCurr      As Character
    Local cDetAlias  As Character
    Local cLnForDel  As Character
    Local cTab2Fun15 As Character
    Local cErrMsg    As Character
    Local cSETab     As Character
    Local cFilLen    As Character
    Local cFields    As Character
    Local cQrSE2     As Character
    Local cSelct     As Character
    Local cQrCTO     As Character
    Local cQrF5Q     As Character
    Local cPr        As Character
    Local cE         As Character
    Local cForCli    As Character
    Local cFrCl      As Character
    Local cExclTipos As Character
    Local nX         As Numeric
    Local nAddSE2KLn As Numeric
    Local lLock      As Logical

    Default lInflow := .F.

    cErrMsg    := ""
    nStatus    := 0
    oModel     := FWModelActive()
    If cProgName == "RU06D06"
        oModelHead := oModel:GetModel("RU06D05_MF49")
    Else
        oModelHead := oModel:GetModel(cProgName + "_MHEAD")
    EndIf
    Do Case 
        Case cProgName == "RU06D04"
            oModelDet := oModel:GetModel(cProgName + "_MLNS" )
            cDetAlias := "F48"
        Case cProgName == "RU06D06"
            oModelDet := oModel:GetModel("RU06D05_MF4B")
            cDetAlias := "F4B"
        Case cProgName == "RU06D07"
            oModelDet := oModel:GetModel(cProgName + "_MVIRT")
            cDetAlias := "B"
    EndCase
    cFilLen    := cValToChar(GetSX3Cache("F5M_FILIAL", "X3_TAMANHO"))
    aInp       := RU06XFUN47_CreateTmpTab1(lInflow)
    oTempTable := aInp[1]
    aFields    := aInp[2]
    cSupp   := oModelHead:GetValue(cHeadAlias + Iif(lInflow, "_CUST","_SUPP")  )
    cUnit   := oModelHead:GetValue(cHeadAlias + Iif(lInflow,"_CUNI","_UNIT")  )
    cCurr   := oModelHead:GetValue(cHeadAlias + "_CURREN")
    cTab2Fun15 := CriaTrab(, .F.)
    oTmpTab2   := FWTemporaryTable():New(cTab2Fun15)
    aFields2   := {}
    nAddSE2KLn := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][5]
    cSETab := Iif(lInflow,"SE1","SE2")
    cPr    := IIF(lInflow,"SE1.E1_", "SE2.E2_")
    cE     := IIF(lInflow,"E1_", "E2_")
    cForCli:= IIF(lInflow,"SE1.E1_CLIENTE", "SE2.E2_FORNECE")
    cFrCl  := IIF(lInflow,"E1_CLIENTE","E2_FORNECE")
    AADD(aFields2,{IIf(lInflow,"ADDSE1KEYT","ADDSE2KEYT")  , "C", nAddSE2KLn ,00})
    oTmpTab2:SetFields(aFields2)
    oTmpTab2:AddIndex("1", {IIf(lInflow,"ADDSE1KEYT","ADDSE2KEYT")})
    oTmpTab2:Create()
    For nX := 1 To oModelDet:Length() // pass virtual grid, and add lines which
        oModelDet:GoLine(nX)          // will be excluded from result query
        If !(oModelDet:IsDeleted())
            cLnForDel := AllTrim(xFilial(cSETab))                           +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_PREFIX")) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_NUM"   )) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_PARCEL")) +;
                         AllTrim(oModelDet:GetValue(cDetAlias + "_TYPE"  )) +;
                         AllTrim(cSupp)                                     +;
                         AllTrim(cUnit)
            cLnForDel := PADR(cLnForDel,nAddSE2KLn,' ')
            cQuery  := "INSERT INTO " + oTmpTab2:GetRealName() + " ( ADDSE2KEYT ) "
            cQuery  += "VALUES ( '" + cLnForDel + "' )"
            cQuery  := IIf(lInflow,StrTran(cQuery,"( ADDSE2KEYT )","( ADDSE1KEYT )"),cQuery)
            nStatus := TCSqlExec(cQuery)
            If nStatus < 0
                cErrMsg += " TCSQLError() " + TCSQLError()
                Exit
            EndIf
        EndIf
    Next nX
    //form a set of keys cExclTipos for excluding from query result
    //lines with E2_(E1_)TIPO in MVRECANT,MVPAGANT,MV_CPNEG,MV_CRNEG
    //https://jiraproducao.totvs.com.br/browse/RUIT-700
    cExclTipos := IIf(lInflow,MVRECANT+"|"+MV_CRNEG, MVPAGANT+"|"+MV_CPNEG)
    cExclTipos := FormatIn(cExclTipos,"|")
    
    // Query text for Temporary table
    cSelct := " SELECT                                                               "
    cSelct += "    CAST('0' AS CHAR(1))     "+cE+"OK,                                "
    cSelct += "    "+cPr+"FILIAL , "+cPr+"PREFIXO, "+cPr+"NUM    ,                   "
    cSelct += "    "+cPr+"PARCELA, "+cPr+"TIPO   , "+cPr+"EMISSAO, "+cPr+"VENCREA,   "
    cSelct += "    CTO.CTO_MOEDA ,                                                   "
    cSelct += "    CASE WHEN "+cPr+"CONUNI = '1'                                     "
    cSelct += "         THEN 'Yes'                                                   "
    cSelct += "         ELSE 'No'                                                    "
    cSelct += "    END "+cE+"CONUNI , "+cPr+"VALOR  ,                                "
    cSelct += "    COALESCE("+cPr+"SALDO - OPB.OPBVALUE, "+cPr+"SALDO) "+cE+"BALANCE,"
    cSelct += "    "+cForCli+", "+cPr+"LOJA   ,                                      "
    cSelct += "    (TRIM("+cPr+"FILIAL) ||TRIM("+cPr+"PREFIXO)||TRIM("+cPr+"NUM) ||  "
    cSelct += "     TRIM("+cPr+"PARCELA)||TRIM("+cPr+"TIPO)   ||TRIM("+cForCli+")    "
    cSelct += "     ||TRIM("+cPr+"LOJA))  ADD"+cSETab+"KEYC ,                        "
    cSelct += "    "+cPr+"MOEDA  , "+cPr+"VALIMP1, "+cPr+"NATUREZ, "+cPr+"VLCRUZ ,   "
    cSelct += "    "+cPr+"ALQIMP1, "+cPr+"F5QUID,                                    "
    cSelct += "    COALESCE(F5Q.F5Q_DESCR, '' ),                                     "
    cSelct += "    CAST('1' AS CHAR(1)),                                             "
    cSelct += "    COALESCE(F5Q.F5Q_CODE , ''),                                      "
    cSelct += "    "+cPr+"CONUNI "+IIF(lInflow,"E1","E2")+"CUDIGTL,                  "
    cSelct += "    CAST('"+xFilial(cSETab)+"' AS CHAR("+cFilLen+")) F5M_FILIAL,      "
    cSelct += "    COALESCE(OPB.VALCNVBF, 0)   VALCNVBF,                             "
    cSelct += "    COALESCE(OPB.BSVATCBF, 0)   BSVATCBF,                             "
    cSelct += "    COALESCE(OPB.VLVATCBF, 0)   VLVATCBF,                             "
    cSelct += "    "+cPr+"BASIMP1,                                                   "
    cSelct += "    COALESCE(PST.VLVATPST, 0)   VLVATPST                              "

    cQrSE2 := "           ( SELECT *                                                 "
    cQrSE2 += "             FROM " + RetSQLName(cSETab) + "                          "
    cQrSE2 += "             WHERE                                                    "
    cQrSE2 += "                       "+cE+"FILIAL   =   '" + xFilial(cSETab)+ "'    "
    cQrSE2 += "                   AND "+cFrCl+"      =   '" +      cSupp     + "'    "
    cQrSE2 += "                   AND "+cE+"LOJA     =   '" +      cUnit     + "'    "
    cQrSE2 += "                   AND "+cE+"VENCREA  BETWEEN                         "
    cQrSE2 += "                                          '" + DTOS(MV_PAR01) + "'    "
    cQrSE2 += "                                      AND '" + DTOS(MV_PAR02) + "'    "
    cQrSE2 += "                   AND "+cE+"NUM      BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR03    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR04    + "'    "
    cQrSE2 += "                   AND "+cE+"NATUREZ  BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR05    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR06    + "'    "
    cQrSE2 += "                   AND "+cE+"F5QCODE  BETWEEN                         "
    cQrSE2 += "                                          '" +    MV_PAR07    + "'    "
    cQrSE2 += "                                      AND '" +    MV_PAR08    + "'    "
    If !Empty(cExclTipos)
        cQrSE2 += "               AND "+cE+"TIPO NOT IN                              "
        cQrSE2 += "                                       " +   cExclTipos   + "     "
    EndIf
    If !lInflow .And. GETMV("MV_CTLIPAG")
        cQrSE2 += "               AND (   E2_STATLIB  = '03'                         "
        cQrSE2 += "                    OR E2_STATLIB  = '05' )                       "
    EndIf
    If !Empty(cCurr)
        If cCurr == '01'
            cQrSE2 += "           AND "+cE+"MOEDA    BETWEEN                         "
            cQrSE2 += "                                   " +     MV_PAR09   + "     "
            cQrSE2 += "                               AND " +     MV_PAR10   + "     "
            cQrSE2 += "           AND (   "+cE+"MOEDA    =  1                        "
            cQrSE2 += "                OR "+cE+"CONUNI   = '1'  )                    "
        Else
            cQrSE2 += "           AND "+cE+"MOEDA    =    " +      cCurr     + "     "
            cQrSE2 += "           AND "+cE+"CONUNI   <>  '" +       "1"      + "'    "
        EndIf
    EndIf
    cQrSE2 += "                   AND D_E_L_E_T_  = ' ' ) "+cSETab+"                 "

    cQrCTO := " INNER JOIN " + RetSQLName("CTO") + " CTO                             "
    cQrCTO += "            ON (                                                      "
    cQrCTO += "                    CAST(CTO.CTO_MOEDA AS INTEGER) = "+cPr+"MOEDA     "
    cQrCTO += "                AND CTO.CTO_FILIAL = '"+xFilial("CTO")+"'             "
    cQrCTO += "                AND CTO.D_E_L_E_T_ = ' '                    )         "

    cQrF5Q := " LEFT JOIN  " + RetSQlName("F5Q") + " F5Q                             "
    cQrF5Q += "            ON (                                                      "
    cQrF5Q += "                    F5Q.F5Q_FILIAL = "+cPr+"FILIAL                    "
    cQrF5Q += "                AND F5Q.F5Q_UID    = "+cPr+"F5QUID                    "
    cQrF5Q += "                AND F5Q.D_E_L_E_T_ = ' '                    )         "

    cFields := "( "
    For nX := 1 To Len(aFields) //get list of fields
        cFields += aFields[nX][1] + ", "
    Next nX
    cFields := Left(cFields,Len(cFields)-2)
    cFields += ") "
    If nStatus >= 0
        aInpSE2F5M := RU06XFUN51_RecieveSE2F5MLines(cQrSE2, lInflow)
        oTmpSE2    := aInpSE2F5M[1]
        oTmpF5M    := aInpSE2F5M[2]
        oTmpPST    := aInpSE2F5M[3]
        nStatus    := aInpSE2F5M[4]
        lLock      := aInpSE2F5M[6]
        If lLock
            If nStatus >= 0
                cQuery := cSelct
                cQuery += " FROM                                                                 "
                cQuery += "      ( SELECT *                                                      "
                cQuery += "        FROM " +oTmpSE2:GetRealName() + "                             "
                cQuery += "                                    )                  "+cSETab+"     "
                cQuery += " LEFT JOIN                                                            "
                cQuery += "      ( SELECT                                                        "
                cQuery += "            GRP.F5M_KEY           F5M_KEY,                            "
                cQuery += "            SUM(GRP.F5M_VALPAY)   OPBVALUE,                           "
                cQuery += "            SUM(GRP.F5M_VALCNV)   VALCNVBF,                           "
                cQuery += "            SUM(GRP.F5M_BSVATC)   BSVATCBF,                           "
                cQuery += "            SUM(GRP.F5M_VLVATC)   VLVATCBF                            "
                cQuery += "        FROM                                                          "
                cQuery += "             ( SELECT F5M_KEY,                                        "
                cQuery += "                      F5M_VALPAY,                                     "
                cQuery += "                      F5M_VALCNV,                                     "
                cQuery += "                      F5M_BSVATC,                                     "
                cQuery += "                      F5M_VLVATC                                      "
                cQuery += "               FROM     " + oTmpF5M:GetRealName() + "                 "
                cQuery += "                                                ) GRP                 "
                cQuery += "               GROUP BY GRP.F5M_KEY)                   OPB            "
                cQuery += " ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("OPB",lInflow) + ")       "
				cQuery += " LEFT JOIN                                                            "
                cQuery += "      ( SELECT                                                        "
                cQuery += "            GRP.F5M_KEY           F5M_KEY,                            "
                cQuery += "            SUM(GRP.F5M_VLVATC)   VLVATPST                            "
                cQuery += "        FROM                                                          "
                cQuery += "             ( SELECT F5M_KEY,                                        "
                cQuery += "                      F5M_VLVATC                                      "
                cQuery += "               FROM     " + oTmpPST:GetRealName() + "                 "
                cQuery += "                                                ) GRP                 "
                cQuery += "               GROUP BY GRP.F5M_KEY)                   PST            "
                cQuery += " ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("PST",lInflow) + ")       "
                //---------Join moeda information from CTO table----------------------------------
                cQuery += cQrCTO
                //---------Join contract information from F5Q table-------------------------------
                cQuery += cQrF5Q
                //--------Balance should be greater 0---------------------------------------------
                cQuery += " WHERE COALESCE("+cPr+"SALDO - OPB.OPBVALUE, "+cPr+"SALDO) > 0        "
                cQuery += "   AND                                                                "
                cQuery += "    (TRIM("+cPr+"FILIAL) ||TRIM("+cPr+"PREFIXO)||TRIM("+cPr+"NUM) ||  "
                cQuery += "     TRIM("+cPr+"PARCELA)||TRIM("+cPr+"TIPO)   ||TRIM("+cForCli+")    "
                cQuery += "     ||TRIM("+cPr+"LOJA))  NOT IN (                                   "
                cQuery += "                               SELECT ADD"+cSETab+"KEYT               "
                cQuery += "                               FROM " + oTmpTab2:GetRealName() + "    "
                cQuery += "                                                            )         "
                cQuery := ChangeQuery(cQuery)
                cQuery := " INSERT INTO " + oTempTable:GetRealName() + " " + cFields + " " + cQuery
                nStatus := TCSqlExec(cQuery)
                If nStatus < 0
                    cErrMsg += " TCSQLError() " + TCSQLError()
                EndIf
            Else
                cErrMsg += aInpSE2F5M[5]
            EndIf
        Else
            cErrMsg += STR0023 //Records are locked, please try again
        EndIf
        aArea := GetArea()
        If !Empty(oTmpSE2)
            oTmpSE2:Delete()
        EndIf
        If !Empty(oTmpF5M)
            oTmpF5M:Delete()
        EndIf
        If !Empty(oTmpPST)
            oTmpPST:Delete()
        EndIf
        RestArea(aArea)
    EndIf
    aRet    := {oTempTable, aFields, cErrMsg}
Return (aRet)

/*/{Protheus.doc} RU06XFUN16_MarkAll
Mark all records
@param		oBrowsePut - Object
			cTempTbl - Alias markbrowse
            cFieldName - Name of field containing mark sign in markbrowse
@author natalia.khozyainova
@since 11/12/2018
@version 2.0
@type function
@project	MA3
/*/
Function RU06XFUN16_MarkAll(oBrowsePut as Object, cTempTbl as Char, cFieldName as Character)
Local nRecOri 	as Numeric

Default cFieldName:="E2_OK"
nRecOri	:= (cTempTbl)->( RecNo() )

dbSelectArea(cTempTbl)
(cTempTbl)->( DbGoTop() )
Do while !(cTempTbl)->( Eof() )
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)-> ( &(cFieldName) ) )
		(cTempTbl)-> ( &(cFieldName) ) := ""
	Else
		(cTempTbl)->( &(cFieldName) ) := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->( DbSkip() )
Enddo

(cTempTbl)->( DbGoTo(nRecOri) )
oBrowsePut:oBrowse:Refresh(.T.)
Return .T.

/*/{Protheus.doc} RU06XFUN17_VldVATFields
VAT fields validation and update in RU06D04, RU06D05, RU06D07
@param	nNum - shows which field is validated, comes from sx3
		cAlias - ehader table alias
        cModelLines - model name to check if grid is empty
@author eduardo.flima
@since 18/12/2018
@version 3.0
@type function
@project	MA3
/*/
Function RU06XFUN17_VldVATFields(nNum as Numeric, cAlias as Character, cModelLines as Character)
// 1 = VALUE, 2=COD , 3=RAT, 4=AMOUNT
Local lRet          as Logical
Local aRate         as Array
Local oModel        as Object
Local oModelL       as Object
Local lGridEmpty    as Logical

lRet        := .T.
aRate       := {0,100}  // if VATCOD is empty
oModel      :=FWModelActive()
oModelL     :=oModel:GetModel(cModelLines)
lGridEmpty  := oModelL:IsEmpty()

If nNum <> 4
    If !Empty( FwFldGet(cAlias+"_VATCOD") )   // Need to check if it is a formula or a rate.
        // formula
        aRate := RU06XFUN34_ParseVatRate( FwFldGet(cAlias+"_VATCOD") )
    Else
        aRate := { FwFldGet(cAlias+"_VATRAT"), 100 }
    EndIf
EndIf

If nNum == 2 // _VATCOD
    If !Empty(FwFldGet(cAlias+"_VATCOD"))
        FwFldPut(cAlias+"_VATRAT", aRate[1],,,.T.)
        If FwFldGet(cAlias+"_PREPAY")=="1" .or. lGridEmpty                 
            FWFldPut(cAlias+"_VATAMT", RU06XFUN18_VATFormula(FwFldGet(cAlias+"_VALUE"),aRate) )
        Endif                    
        lRet:= .T.
    Endif
EndIf

If (nNum==1 .or. nNum==3) // _VALUE or _VATRATE    
    FWFldPut(cAlias+"_VATAMT", RU06XFUN18_VATFormula(FwFldGet(cAlias+"_VALUE"), aRate) )
EndIf

If (nNum==4) .and. !(Positivo()) // _VATAMT
    lRet:=.F.
EndIf
Return (lRet)

/*/{Protheus.doc} RU06XFUN18_VATFormula
Formula to calculate VAT
@author eduardo.flima
@since 04/05/2018
@version 3.0
@type function
/*/
Function RU06XFUN18_VATFormula(nValue, aVatRat, nDec, lInc) 
    Local   nRet As Numeric

    Default nValue  := 0
    Default aVatRat := {0,100}
    Default nDec    := 2
    Default lInc    := .T. // If .T. - VAT amount included in nValue

    nRet   := 0 
    If lInc //VAT included in nValue
        nRet := ROUND((nValue  * aVatRat[1]) /;
                      (aVatRat[2] + aVatRat[1]), nDec)
    EndIf
Return (nRet)


/*/{Protheus.doc} RU06XFUN19_ReasonText
Function to generate automatic text of Reason of Payment
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN19_ReasonText(lForce as Logical, nLine as Numeric, cAction as Character) 
Local cRet as Character
Local oModel as Object
Local oModelH as Object
Local oModelL as Object
Local nX as Numeric
Local nQtyLns as Numeric
Local cContract as Character
Local cReason as Character
Local cBills as Character
Local nVatRt as Numeric
Local nVatAmnt as Numeric
Local cPrepay as Character
Local cAliasH as Character
Local cAliasL as Character
Local cModel as Character
Local cF5QUID as Character
Local aArea   as Array

Default lForce:=.F.
Default nLine:=0
Default cAction:=""
oModel:=FwModelActive()
cModel:=oModel:GetID()
aArea := GetArea()
Do Case 
    Case cModel=="RU06D04"
        oModelH:=oModel:GetModel("RU06D04_MHEAD")
        oModelL:=oModel:GetModel("RU06D04_MLNS")
        cAliasH:="F47"
        cAliasL:="F48"
        cF5QUID:=cAliasH+"_F5QUID"
    Case cModel=="RU06D07"
        oModelH:=oModel:GetModel("RU06D07_MHEAD")
        oModelL:=oModel:GetModel("RU06D07_MVIRT")
        cAliasH:="F4C"
        cAliasL:="B"
        cF5QUID:=cAliasH+"_UIDF5Q"
    Case cModel=="RU06D06"
        oModelH:=oModel:GetModel("RU06D05_MF49")
        oModelL:=oModel:GetModel("RU06D05_MVIRT")
        cAliasH:="F49"
        cAliasL:="B"
        cF5QUID:=cAliasH+"_F5QUID"
EndCase

cContract:= ""

If !Empty(oModelH:GetValue(cF5QUID))
    DBSelectArea("F5Q")
    F5Q->(DBGoTop())
    F5Q->(DbSetOrder(1)) //F5Q_FILIAL+F5Q_UID
    If F5Q->(DbSeek(xFilial("F5Q")+oModelH:GetValue(cF5QUID)))
        cContract := AllTrim(F5Q->F5Q_NUMBER) + STR0073 + DToC(F5Q_EDATE)
    EndIf
    DBCloseArea()
EndIf

cReason:=oModelH:GetValue(cAliasH+"_REASON")
nVatRt:=oModelH:GetValue(cAliasH+"_VATRAT")
nVatAmnt:=oModelH:GetValue(cAliasH+"_VATAMT")
cPrepay:=oModelH:GetValue(cAliasH+"_PREPAY")

nQtyLns:=0
cBills:=''

// calc qty of lines
For nX := 1 To oModelL:Length()
    oModelL:GoLine(nX)
    if ( !(oModelL:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty(oModelL:GetValue(cAliasL+"_NUM")) 
        if !(cAction='DELETE' .and. nX==nLine)
            nQtyLns++
        EndIf
    EndIf
Next nX

If nQtyLns > 0
    // Go line by line to check bills
    For nX := 1 To oModelL:Length()
        oModelL:GoLine(nX)
        if ( !(oModelL:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty(oModelL:GetValue(cAliasL+"_NUM")) 
            if !(cAction='DELETE' .and. nX==nLine)
                If alltrim(cBills)==""
                    If nQtyLns == 1
                        cBills:=STR0014 //' the bill'
                    Else
                        cBills:=STR0015 //' the bills'
                    EndIf
                EndIf
                cBills+=' '+alltrim(oModelL:GetValue(cAliasL+"_PREFIX"))+if(alltrim(oModelL:GetValue(cAliasL+"_PREFIX"))!='','/','');
                +alltrim(oModelL:GetValue(cAliasL+"_NUM"))+STR0016 +DToC(oModelL:GetValue(cAliasL+"_EMISS"))+',' //' from '
                nQtyLns++
            EndIf
        EndIf
    Next nX
    cBills:=left(cBills,Len(cBills)-1)+'.'
Else
    cBills:=''
Endif

If alltrim(cReason) == '' .or. left(alltrim(cReason),Len(STR0018)) == STR0018  .or. left(alltrim(cReason),Len(STR0017)) == STR0017 .or. lForce //'Payment' or 'Including VAT '
    cRet:=''
    IF alltrim(cContract)!=''
        cRet:=STR0018 //'Payment'
        cRet+=STR0019 + ' ' + alltrim(cContract)+', ' //' under the contrract '
    EndIf

    IF alltrim(cBills)!='' .and. cPrepay!='1'
        If alltrim(cRet) == ''
            cRet:=STR0018 //'Payment'
        EndIf
        cRet+=cBills+' '
    EndIf


    If alltrim(cRet)!='' 
        cRet+= CRLF
    EndIf

    if !(nVatRt=0 .and. nVatAmnt=0)
        If nVatRt!=0
            cRet+=STR0017+' '+alltrim(STR(ROUND(nVatRt,2)))+'%' //'Including VAT '
        EndIf

        If nVatAmnt!=0
            cRet+=' - '+alltrim(STR(ROUND(nVatAmnt,2),15,2))
        EndIf

    Endif
Else
    cRet:=cReason
EndIf

RestArea(aArea)

Return (cRet)

/*/{Protheus.doc} RU06XFUN20_VldValPay
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN20_VldValPay(nPos as Numeric)
Local lRet      as Logical
Local oModel    as Object
Local cModel    as Character
Local oModelL   as Object
Local oModelH   as Object
Local nOpBal    as Numeric
Local cKey      as Character
Local nCurren   as Numeric
Local dDateToCalc as Date
Local nValLineFld as Numeric
Local aImp        as Array

lRet:=.T.
nOpBal:=0
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    dDateToCalc:=oModelH:GetValue("F47_DTPLAN")
    cAliasH:="F47"
    cAliasL:="F48"
    nValLineFld:=oModelL:GetValue("F48_VALREQ")
    Case cModel=="RU06D07"
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    dDateToCalc:=oModelH:GetValue("F4C_DTTRAN")
    cAliasH:="F4C"
    cAliasL:="B"
    nValLineFld:=oModelL:GetValue("B_VALPAY")
    Case cModel=="RU06D06"
    oModelH:=oModel:GetModel("RU06D05_MF49")
    oModelL:=oModel:GetModel("RU06D05_MF4B")
    dDateToCalc:=oModelH:GetValue("F49_DTPAYM")
    cAliasH:="F49"
    cAliasL:="F4B"
    nValLineFld:=oModelL:GetValue("F4B_VALPAY")
    Otherwise
    Return(lRet)
EndCase
nPos:=oModelL:GetLine()
nOpBal:=oModelL:GetValue(cAliasL+"_OPBAL")
nCurren:=oModelL:GetValue(cAliasL+"_CURREN")

If (nValLineFld <= 0)  .OR. (nValLineFld > nOpBal)
            lRet := .F.
EndIf
If !lRet
    Help("",1,"",,STR0022 + cValToChar(nOpBal),1,0,,,,,,) // Error: Bill Balance =
Else
    cKey := oModelL:GetValue(cAliasL+"_FLORIG")+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+;
            oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")+;
            oModelH:GetValue(cAliasH+"_SUPP")+oModelH:GetValue(cAliasH+"_UNIT")
    aImp :=  RU06XFUN80_Ret_VLIMP1_BSIMP1(cKey,nValLineFld,oModelL:GetValue(cAliasL+"_VALUE"),2)
    oModelL:LoadValue(cAliasL+"_VLIMP1",aImp[1])
    oModelL:LoadValue(cAliasL+"_BSIMP1",aImp[2])
EndIf

Return (lRet)


/*/{Protheus.doc} RU06XFUN21_RecalcRubls
@author natalia.khozyainova
@since 28/12/2018
@version 1.0
@type function
/*/
Function RU06XFUN21_RecalcRubls(lOnlyRate, dDateToRecalc)
Local oModel    as Object
Local cModel    as Character
Local oModelH   as Object
Local oModelL   as Object
Local nCurrLin  as Numeric
Local nExgRat   as Numeric
Local cAliasL   as Character
Local cAliasH   as Character
Local nValLineFld as Numeric
Local nValImp     as Numeric
Local aCnvVls     as Array

Default lOnlyRate:=.F.

oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    Default dDateToRecalc:=oModelH:GetValue("F47_DTPLAN")
    cAliasL:="F48"
    cAliasH:="F47"
    nValLineFld:=oModelL:GetValue("F48_VALREQ")
    Case cModel=="RU06D06"
    oModelH:=oModel:GetModel("RU06D05_MF49")
    oModelL:=oModel:GetModel("RU06D05_MF4B")
    Default dDateToCalc:=oModelH:GetValue("F49_DTPAYM")
    cAliasH:="F49"
    cAliasL:="F4B"
    nValLineFld:=oModelL:GetValue("F4B_VALPAY")
EndCase
nCurrLin:=oModelL:GetValue(cAliasL+"_CURREN")
nExgRat:=oModelL:GetValue(cAliasL+"_EXGRAT")

LimpaMoeda()

If lOnlyRate
    If Val(oModelH:GetValue(cAliasH+"_CURREN")) == 1 // local currency
        If nCurrLin == 1 //i.e. RUB/RUB
            oModelL:LoadValue(cAliasL+"_EXGRAT", 1)
        Else //i.e. USD/RUB
            oModelL:LoadValue(cAliasL+"_EXGRAT", RecMoeda(dDateToRecalc,nCurrLin))
        EndIf
    Else // for different currencies calculates cross rate
        If nCurrLin == Val(oModelH:GetVaValue(cAliasH+"_CURREN")) // i.e. EUR/EUR
            oModelL:LoadValue(cAliasL+"_EXGRAT", 1)
        Else // i.e. USD/EUR
            oModelL:LoadValue(cAliasL+"_EXGRAT", xMoeda(1, nCurrLin,;
                              Val(oModelH:GetValue(cAliasH+"_CURREN")),;
                              dDateToRecalc,4))
        EndIf
    EndIf 
Else
    nValImp := oModelL:GetValue(cAliasL+"_VLIMP1")
    aCnvVls := RU06XFUN81_RetCnvValues(nValLineFld,nValImp,oModelL:GetValue(cAliasL + "_EXGRAT"),2)
    oModelL:LoadValue(cAliasL+"_VALCNV",aCnvVls[1])
    oModelL:LoadValue(cAliasL+"_VLVATC",aCnvVls[2])
    oModelL:LoadValue(cAliasL+"_BSVATC",aCnvVls[3])
    Do Case
        Case cModel == "RU06D04"
            RU06D0407_ValidRubles()
    EndCase
EndIf

Return (.T.)

/*/{Protheus.doc} RU06XFUN22_CurrRatValid
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
@type function
/*/
Function RU06XFUN22_CurrRatValid(nNum)
Local oModel    as Object
Local oModelL   as Object
Local cModel    as Character
Local oStrL     as Object
Local cAliasL   as Character
Default nNum:=0

oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    cAliasL:="F48"
EndCase

oStrL:=oModelL:GetStruct()

If nNum==2 
    If FwFldGet(cAliasL+"_RATUSR") != "1"   
    RU06XFUN21_RecalcRubls(.T.)
    EndIf
Else   
    oModelL:SetValue(cAliasL+"_RATUSR","1")
    oStrL:SetProperty(cAliasL+"_CHECK"	,MODEL_FIELD_WHEN,{|| .T. })
    oModelL:SetValue(cAliasL+"_CHECK",.T.)
EndIf
RU06XFUN21_RecalcRubls(.F.)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN23_VirtCheckBoxValid
Validation on virtual checkbox, attached to _RATUSR fields
@type function
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function RU06XFUN23_VirtCheckBoxValid()
Local lRet      as Logical
Local oModel    as Object
Local cModel    as Character
Local oStrL     as Object
Local cAliasL   as Character

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oStrL:=oModel:GetModel("RU06D04_MLNS"):GetStruct()
    cAliasL:="F48"
EndCase

If FwFldGet(cAliasL+"_CHECK")
            FwFldPut(cAliasL+"_RATUSR","1")
Else
    FwFldPut(cAliasL+"_RATUSR","0")
    oStrL:SetProperty(cAliasL+"_CHECK"	,MODEL_FIELD_WHEN,{|| .F. })
EndIf

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN24_2Click
Doubleclick on bills
@author natalia.khozyainova
@since 21/01/2019
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function RU06XFUN24_2Click(oFormula, cFieldName, nLineGrid, nLineModel)
Local aArea		as Array
Local aAreaSE2	as Array 
Local aAreaSA6	as Array 
Local aAreaFil	as Array 
Local oModel    as Object
Local oModelL   as Object
Local oModelH   as Object
Local lRet      as Logical
Local lInflow   as Logical
Local cAliasL   as Character
Local cAliasH   as Character
Local cModel    as Character
Local cFilReserv  as Character
Private cCadastro as Character

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
aArea:= GetArea()
aAreaSA6:= SA6->(GetArea())
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    cAliasL:="F48"
    cAliasH:="F47"
    lInflow := .F.

    Case cModel=="RU06D07"
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    cAliasL:="B"
    cAliasH:="F4C"
    lInflow := (oModelH:GetValue("F4C_OPER") == '1')

EndCase

If lInflow
    aAreaSE2:= SE1->(GetArea())
Else
    aAreaSE2:= SE2->(GetArea())
EndIf

If cFieldName==cAliasL+"_CHECK" .or. cFieldName==cAliasL+"_EXGRAT" .or. cFieldName==cAliasL+"_VALCNV" .or. cFieldName==cAliasL+"_CONUNI"
    lRet:=.T.
ElseIf !(oModelL:CanSetValue(cFieldName))
    If lInflow
        SE1->(DbSetOrder(2))    //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        If SE1->(DbSeek(ALLTRIM(oModelL:GetValue(cAliasL+"_FLORIG"))+oModelH:GetValue(cAliasH+"_CUST")+oModelH:GetValue(cAliasH+"_CUNI")+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")))
            dbSelectArea("SA1")
            If SA1->(dbSeek(xFilial("SA1", SE1->E1_FILIAL)+SE1->E1_CLIENTE+SE1->E1_LOJA))
                dbSelectArea("SE1")
                aAreaFil:= GetArea()
                cFilReserv:=cFilAnt
                cFilAnt:=SE1->E1_FILIAL
                cCadastro := OEMToAnsi(STR0074)
                AxVisual("SE1",SE1->(RecNo()),4,,4,SA1->A1_NOME)
                cFilAnt:=cFilReserv
                RestArea(aAreaFil)
            EndIf
            lRet:=.F.
        EndIf
    Else
        SE2->(DbSetOrder(1))
        If SE2->(DbSeek(ALLTRIM(oModelL:GetValue(cAliasL+"_FLORIG"))+oModelL:GetValue(cAliasL+"_PREFIX")+oModelL:GetValue(cAliasL+"_NUM")+oModelL:GetValue(cAliasL+"_PARCEL")+oModelL:GetValue(cAliasL+"_TYPE")+oModelH:GetValue(cAliasH+"_SUPP")+oModelH:GetValue(cAliasH+"_UNIT")))
            dbSelectArea("SA2")
            If SA2->(dbSeek(xFilial("SA2", SE2->E2_FILIAL)+SE2->E2_FORNECE+SE2->E2_LOJA))
                dbSelectArea("SE2")
                aAreaFil:= GetArea()
                cFilReserv:=cFilAnt
                cFilAnt:=SE2->E2_FILIAL
                cCadastro := OEMToAnsi(STR0021)
                AxVisual("SE2",SE2->(RecNo()),4,,4,SA2->A2_NOME)
                cFilAnt:=cFilReserv
                RestArea(aAreaFil)
            EndIf
            lRet:=.F.
        EndIf
    EndIf
EndIf
RestArea(aArea)
RestArea(aAreaSE2)
RestArea(aAreaSA6)
Return (lRet)

/*/{Protheus.doc} RU06XFUN25_CheckBoxWhen()

@type function
@author natalia.khozyainova
@since 21/01/2019
@version 1.0
/*/ 
Function RU06XFUN25_CheckBoxWhen(cAliasL)
Local lRet
lRet:=.F.
If !Empty(cAliasL)
    lRet:=IIF(FwFldGet(cAliasL+"_RATUSR")=="1", .T., .F.)
EndIf
Return (lRet)

/*/{Protheus.doc} RU06XFUN26_CheckCurrHeadLines()
this function will compare currency in the header of the document to currency in each line
and return lRet == True, if currency is same or 01 in header and conventional units in lines
return lRet == False otherwise
@type function
@author natalia.khozyainova
@since 29/01/2019
@version 1.0
/*/ 
Function RU06XFUN26_CheckCurrHeadLines()
Local oModel    as Object
Local oModelL   as Object
Local oModelH   as Object
Local lRet      as Logical
Local cAliasL   as Character
Local cAliasH   as Character
Local cModel    as Character
Local nX        as Numeric
Local cCurrenH  as Character
Local cCurrenL  as Character
local cType     as Character 

lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()
Do Case 
    Case cModel=="RU06D04"
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    oModelH:=oModel:GetModel("RU06D04_MHEAD")
    cAliasL:="F48"
    cAliasH:="F47"

    Case cModel=="RU06D07"
    oModelL:=oModel:GetModel("RU06D07_MVIRT")
    oModelH:=oModel:GetModel("RU06D07_MHEAD")
    cAliasL:="B"
    cAliasH:="F4C"

    Case cModel=="RU06T02"
    oModelL:=oModel:GetModel("RU06T02_MVIRT")
    oModelH:=oModel:GetModel("RU06T02_MHEAD")
    cAliasL:="B"
    cAliasH:="F60"

EndCase
cCurrenH:=oModelH:GetValue(cAliasH+"_CURREN")
nX:=1
cType := ValType(oModelL:GetValue(cAliasL+"_CURREN"))

While nX <= oModelL:Length() .and. lRet
    oModelL:GoLine(nX)

    IF cType == "N"
        cCurrenL:=STRZERO(oModelL:GetValue(cAliasL+"_CURREN"), 2, 0)
    ElseIf cType == "C"
        cCurrenL:=oModelL:GetValue(cAliasL+"_CURREN")
    Endif 

    If !(oModelL:IsDeleted())
        If ( !Empty(Val(cCurrenL)) .AND. cCurrenH!=cCurrenL )
            If !( cCurrenH =="01" .and. oModelL:GetValue(cAliasL+"_CONUNI") == "1" )
                lRet:=.F.
            Endif
        Endif
    EndIf
    nX++
Enddo
Return (lRet)

/*/{Protheus.doc} RU06XFUN27_GridSortAPs()
this function is designed to sort grid after manual include of APs to payment request or to bank statement
@type function
@author eduardo.FLima
@since 29/01/2019
@version 2.0
/*/ 
Function RU06XFUN27_GridSortAPs(oGrid,cAliasL,nDest)
Local lRet          as Logical
Local cFrom         as Char
Local cTo           as Char
Local nOrig         as Numeric
Local cFilFldName   as Character 

Default nDest :=  1 
lRet := .F.    
cFilFldName:=IIF(cAliasL=="B","B_BRANCH",cAliasL+"_FILIAL")
cFrom := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  
nOrig := oGrid:GetLine()
oGrid:GoLine(nDest)
cTo  := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  

While cFrom !=   cTo    
    If cFrom < cTo 
        oGrid:LineShift( nOrig, nDest)
        lRet := .T.
        oGrid:GoLine(nOrig)
        RU06XFUN27_GridSortAPs(oGrid,cAliasL,nDest)
        cFrom := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")              
    Else 
        nDest := nDest + 1 
        oGrid:GoLine(nDest)
        cTo  := oGrid:GetValue(cFilFldName) + oGrid:GetValue(cAliasL+"_PREFIX") +  oGrid:GetValue(cAliasL+"_NUM") +  oGrid:GetValue(cAliasL+"_PARCEL")  +  oGrid:GetValue(cAliasL+"_TYPE")  
    Endif
Enddo 

Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN28_CheckAReversalOfAdvancePayment

Function Used to Check If the write-off of this bill was generated 
by a Reversal of an advance payment.

@param       Character        cKey //String with the key to find the BIL in this operation
                                   //filial+prefixo+num+parcela+tipo+fornece+loja for SE2
@return      Logical          lRet //Returns if the Write off of this bill was generated 
                                   //by Reversal PA Bank Statement Process
@example     
@author      astepanov
@since       March/20/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN28_CheckAReversalOfAdvancePayment(cKey)
    Local lRet       As Logical
    Local aArea      As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local cFK7Chave  As Character
    lRet := .F.
    aArea := GetArea()
    DBSelectArea("SE2")  
    DBSetOrder(1)   // filial+prefixo+num+parcela+tipo+fornece+loja
    If DBSeek(cKey) // position to record before post
        /*Check if it`s a PA and if the BILL was generated in the Bank Statement Process--*/
        
        If AllTrim(SE2->E2_TIPO) == "PA" .AND. AllTrim(SE2->E2_ORIGEM) == "RU06D07"
            cFK7Chave := PADR(SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+;
                              SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+;
                              SE2->E2_LOJA,GetSX3Cache("FK7_CHAVE", "X3_TAMANHO"), " " )
            cQuery := "SELECT FK7.FK7_CHAVE "
            cQuery += "FROM "       + RetSQLName("FK2") + " FK2 "
            cQuery += "INNER JOIN " + RetSQLName("FK7") + " FK7 "
            cQuery += " ON (FK7.FK7_IDDOC = FK2.FK2_IDDOC) "
            cQuery += "WHERE "
            cQuery += " FK7.FK7_CHAVE      = '"+ cFK7Chave    +"' "
            cQuery += " AND FK2.FK2_FILIAL = '"+xFilial("FK2")+"' "
            cQuery += " AND FK7.FK7_FILIAL = '"+xFilial("FK7")+"' "
            cQuery += " AND FK2.FK2_MOTBX  = " + " 'DAC' "
            cQuery += " AND FK2.FK2_ORIGEM = " + " 'RU06D07' "
            cQuery += " AND FK7.d_e_l_e_t_ = " + "''"
            cQuery += " AND FK2.d_e_l_e_t_ = " + "''"
            cQuery := ChangeQuery(cQuery)
            cTab   := MPSysOpenQuery(cQuery)
            DBSelectArea(cTab)
            DBGoTop()
            If (cTab)->(!eof())
                lRet := .T.
            EndIf
            (cTab)->(DBCloseArea())
        EndIf
    EndIf
    RestArea(aArea)
Return (lRet) /*---------------------------------RU06XFUN28_CheckAReversalOfAdvancePayment*/


/*/{Protheus.doc} RU06XFUN29_ShwF4N
Function used load values to fields related to table F4N
@param  Numeric     nNum    //1, 2, 0
        Character   cCust   //customer's code (->F4N_CLIENT)
        Character   cUnit   //customer's loja (->F4N_LOJA)
        Character   cBnk    //bank code
        Character   cBIK    //BIC
        Character   cAcc    //Account
@return Variant     xRet    //in case nNum == 0:
will be returnd array with next data {"type of account", "bank name",
"account name", "customer's name"} , so this array can be
extended in future.
                            // in case nNum != 0:  
                            if nNum == 1, -> _BKPNAM  bank name
                            if nNum == 2, -> _ACPNAM  account name
                            if nNum == 3, -> _TYPCP   account type
nothing found in F4N -> Empty string or array with empty strings will be returned 
@type function
@author dtereshenko
@since 2019/04/10
@version P12.1.25
@project MA3 - Russia
/*/
Function RU06XFUN29_ShwF4N(nNum As Numeric  , cCust As Character, cUnit As Character,;
                           cBnk As Character, cBIK  As Character, cAcc  As Character )

    Local cRet    As Character
    Local cAlias  As Character
    Local aArea   As Array
    Local aRet    As Array
    Local xRet
    Default nNum  := 1
    
    cRet := ""
    cAlias := RU06XFUN42_RetBankAccountDataFromF4N(cCust,cUnit,Nil,cBnk,cBIK,cAcc,.T.)
    aArea  := GetArea()
    DbSelectArea(cAlias)
    DbGoTop()
    If !EoF()
        If     nNum == 1 // bank name from F45 table
            cRet := (cAlias)->(_BKPNAM)
        ElseIf nNum == 2 // account name
            cRet := (cAlias)->(_ACPNAM)
        ElseIf nNum == 3 // account type
            cRet := (cAlias)->(_TYPCP)
        ElseIf nNum == 0 // array of data
            aRet := {(cAlias)->(_TYPCP) ,;
                     (cAlias)->(_BKPNAM),;
                     (cAlias)->(_ACPNAM),;
                     (cAlias)->(_PAYNAM) }
        EndIf
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := IIf(nNum == 0, aRet, cRet)

Return (xRet)

/*/{Protheus.doc} RU06XFUN31_RelacaoRerun()
Function for rerun x3_relacao of all virtual fields in oModel.

oModel - Model where function should rerun relacao's.
cModelID - If this argument is not empty, rerun will affect only fields of this Submodel. 
           If it's empty, function will affect all Model.

@type function
@author Cherchik.Konstantin
@since 02/04/2019
@version P12.1.25
/*/ 
Function RU06XFUN31_RelacaoRerun(oModel as Object, cModelID as Character)
Local lRet         as Logical
Local aModelIDs    as Array
Local aFields      as Array
Local cModelName   as Character
Local cFieldName   as Character
Local nModels      as Numeric
Local nItems       as Numeric

lRet     := .T.
aModelIDs := oModel:GetModelIds()

If EMPTY(AllTrim(cModelID)) .And. !EMPTY(aModelIDs)
    For  nModels := 1 to Len(aModelIDs)
        cModelName := aModelIDs[nModels]
        aFields := oModel:GetModel(aModelIDs[nModels]):GetStruct():GetFields()
        For  nItems := 1 to Len(aFields)
            If aFields[nItems][MODEL_FIELD_VIRTUAL] .And. aFields[nItems][MODEL_FIELD_INIT] != NIL
                cFieldName := aFields[nItems][MODEL_FIELD_IDFIELD] 
                lRet := lRet .And. oModel:GetModel(cModelName):LoadValue(cFieldName,CriaVar(cFieldName))
            EndIf
        Next nItems
    Next nModels
ElseIf ValType(oModel:GetModel(cModelID)) == "O"
    aFields := oModel:GetModel(cModelID):GetStruct():GetFields()
        For  nItems := 1 to Len(aFields)
            If aFields[nItems][MODEL_FIELD_VIRTUAL] .And. aFields[nItems][MODEL_FIELD_INIT] != NIL
                cFieldName := aFields[nItems][MODEL_FIELD_IDFIELD]
                lRet := lRet .And. oModel:GetModel(cModelID):LoadValue(cFieldName,CriaVar(cFieldName))
            EndIf
        Next nItems
EndIf

Return lRet

/*/{Protheus.doc} RU06XFUN32_GetFromCbox()
Function to get value from cbox.

cField - Field's ID from SX3, which Combo-box you need.
cValue - Value, that user was selected from Combo-box.

@type function
@author Cherchik.Konstantin
@since 06/04/2019
@version P12.1.25
/*/ 
Function RU06XFUN32_GetFromCbox(cField as Character, cValue as Character)
Local cString     as Character
Local cContainer  as Character
Local nStrStart   as Numeric
Local nStrtEnd    as Numeric
Local nShift      as Numeric

Default cString := " "

If !EMPTY(AllTrim(cField))
    nShift := 2     // First 2 symbols in Cbox for each value starts from "1=", thats why we need to do shift for 2 symbols.
    cContainer := GetSx3Cache(cField,"X3_CBOXENG")
EndIf

If !EMPTY(AllTrim(cContainer)) .And. !EMPTY(AllTrim(cValue)) .And. cValue $ cContainer
    nStrStart := AT(cValue,cContainer)+nShift
    nStrtEnd := AT(";",cContainer,nStrStart)
    cString := SubStr(cContainer,nStrStart,nStrtEnd-nStrStart)
EndIf 

Return cString

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN34_ParseVatRate

Function parses F30_RATE to array

@param       Character  cVatCode
@return      Array      aRet
@example     
@author      Alexandra Velmozhnya
@since       21/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN34_ParseVatRate(cVatCode)
    Local aRet    as Array
    Local aRate   as Array
    Local aArea    as Array
    Local aAreaF30 as Array

    Default cVatCode := ""
    aRate := {}
    cVatCode := PADR(cVatCode,GetSX3Cache("F30_CODE", "X3_TAMANHO"), " ")
    aArea    := GetArea()
    aAreaF30 := F30->(GetArea())
    F30->(DbSetOrder(1))
    // Trying to find VAT Rate
    If (F30->(DbSeek(xFilial("F30") + cVatCode)))
        // Needs to check if it is a formula or a rate
        If ("/" $ F30->F30_RATE)
            aRate   := StrTokArr(F30->F30_RATE, "/")
            aRet    := {Val(aRate[1]), Val(aRate[2])}
        Else
            aRet    := {Val(F30->F30_RATE), 100}
        EndIf
    Else
        aRet        := {0, 100}
    EndIf
    RestArea(aAreaF30)
    RestArea(aArea)

Return aRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN35_RetTempTablWTaxAgentsContracts

Function recieves string which contains F4C->F4C_CUUID value(s)
and returns temporary table with next fields:
F4C_CUUID (C:32), 
E2_F5QUID (C:32)
Sql query seeks all APs related to bank statement, takes from these lines E2_F5QUID (C:32)
field and seeks in legal contracts (F5Q table) lines according to next condition:
F5Q_UID = E2_F5QUID and F5Q_TPAGEN <> '01'
'01' is a parameter (X5_CHAVE) located in 'OT' (X5_TABELA = 'OT'), 
X5_DESCENG = 'With the buyer/customer'
F5M_KEY field is a character(100) string which contains "|" delimiter. 
F5M_KEY should be used for searching lines in SE2 table by next order: filial+prefixo+num+
parcela+tipo+fornece+loja (7 fields).
So we seek all contracts except contracts concluded with the bayer or customer.
Relation scheme between tables can be showed like this:
===========================================================================================
+----+------------------+
| T  |F4C Bank Statement|
+----+------------------+
| PK |F4C_FILIAL(C:6)   |
|    |F4C_CUUID(C:32)   +-=-+---------------------------+
+----+------------------+   | +---+---------------+     |       +---+----------------+
|    |----------------- |   | | T |F5M BS lines   |     |       | T |SE2 AP          |
+----+------------------+   | +---+---------------+     |       +---+----------------+
                            | |PK |F5M_FILIAL(C:6)|     |       |PK |E2_FILIAL(C:6)  |
                            | |   |F5M_ALIAS(C:3) |     |       |   |E2_PREFIXO(C:3) |
                            | |   |F5M_IDDOC(C:32)+-=---+       |   |E2_NUM(C:8)     |
                            | |   |F5M_KEY(C:100) +-=---------=-+   |E2_PARCELA(C:2) |
+----+----------------+     | +---+---------------+             |   |E2_TIPO(C:3)    |
| T  |F5Q Legal contr.|     | |   |-------------- |             |   |E2_FORNECE(C:6) |
+----+----------------+     | +---+---------------+             |   |E2_LOJA(C:2)    |
| PK |F5Q_FILIAL(C:6) +-1-+ |                                   +---+----------------+
|    |F5Q_UIDF4C(C:32)+-=---------------------------------------|-=-+E2_F5QUID(C:32)+-+
+----+----------------+   | |                                   |   |--------------- | =
|    |F5Q_TPAGEN(C:6) |   | |                                   +---+----------------+ |
|    |F5Q_CODE(C:9)   |   | |                                                          |
|    |                |   | | +---+----------------+                                   |
|    |--------------- |   | | | T |F35 VAT Inv.    |                                   |
+----+----------------+   | | +---+----------------|                                   |
                          | | |PK |F35_FILIAL(C:6) +-1-----+                           |
+----+----------------+   | | |   |F35_KEY(C:10)   +-=--+  |                           |
| T  |F5R Legal contr.|   | | +---+----------------+    |  |                           |
|    |    Revision    |   | | |   |F35_CONTRA(C:32)+-=---------------------------------+
+----+----------------+   | | |   |--------------- |    |  |
| PK |F5R_FILIAL(C:6) +-N-+ | +---+----------------+    |  |    +----+---------------+
|    |F5R_UID(C:32)   |     |                           |  |    | T  |F36 VAT Inv.Det|
+----+----------------+     | +---+----------------+    |  |    +----+---------------+
|    |F5R_CODE(C:9)   |     | | T |F5P Advanc. Doc.|    |  +--N-+PK  |F36_FILIAL(C:6)|
|    |------------    |     | +---+----------------+    |       |    |F36_KEY(C:10)  |
+----+----------------+     | |PK |F5P_FILIAL(C:6) |    |       |    |F36_ITEM(C:4)  |
                            | |   |F5P_KEY(C:10)   +-=--+       +----+---------------+
                            | +---+----------------+            |    |-------------- |
                            +-|-=-+F5P_UIDF4C(C:32)|            +----+---------------+
                              |   |--------------- |
                              +---+----------------+
===========================================================================================
If bank statement doesn't contains payments under contracts concluded by the company as a
tax agent, temporary table will be empty and cursor will be positioned on eof().
In case of error in sql query, function returns {Nil, "Error message"},
in normal case will be returned {FWTemporaryTable(), ""}

@param       Character       cF4C_CUUID // 32 character UID for bank statement
             Logical         lPackage   // .T. - indicates that we must process 2 or more
                                        //       bank statements, so cF4C_CUUID should be
                                        //       a complex string with delimiters
                                        // .F. - return tax agent VAT invoices only for 1
                                        //       bank statement (Default)
                                        // it is not used yet but it will be used in case
                                        // of list of BS. So, need implementation.
@return      Array           aRet    // aRet[1] == FWTemporaryTable() Object with the
                                     fields: F4C_CUUID, E2_F5QUID with Index by F4C_CUUID
                                     aRet[2] (C) // in normal case it will be "", in case of
                                     error it contains error message and aRet[1] will be Nil

@example     
@author      astepanov
@since       June/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN35_RetTempTablWTaxAgentsContracts(cF4C_CUUID As Character,;
                                                   lPackage   As Logical   )
    Local aRet       As Array
    Local aArea      As Array
    Local aFields    As Array
    Local oTmpTab    As Object
    Local cHlpMsg    As Character
    Local cAlias     As Character
    Local cQuery     As Character
    Local cFields    As Character
    Local nStat      As Numeric
    Local nX         As Numeric
    Default cF4C_CUUID := ""
    Default lPackage   := .F.
    
    aArea   := GetArea()
    cAlias  := CriaTrab(, .F.)
    oTmpTab := FWTemporaryTable():New(cAlias)
    cHlpMsg := ""
    aFields := {}
    AADD(aFields, {"F4C_FILIAL",;
                    GetSX3Cache("F4C_FILIAL", "X3_TIPO"   ),;
                    GetSX3Cache("F4C_FILIAL", "X3_TAMANHO"),;
                    GetSX3Cache("F4C_FILIAL", "X3_DECIMAL") })
    AADD(aFields, {"F4C_CUUID",;              
                    GetSX3Cache("F4C_CUUID" , "X3_TIPO"   ),;
                    GetSX3Cache("F4C_CUUID" , "X3_TAMANHO"),;
                    GetSX3Cache("F4C_CUUID" , "X3_DECIMAL") })
    AADD(aFields, {"E2_F5QUID",;
                    GetSX3Cache("E2_F5QUID", "X3_TIPO")   ,;
                    GetSX3Cache("E2_F5QUID", "X3_TAMANHO"),;
                    GetSX3Cache("E2_F5QUID", "X3_DECIMAL") })
    oTmpTab:SetFields(aFields)
    oTmpTab:AddIndex(cAlias + "01",{"F4C_CUUID"})
    oTmpTab:Create()

    //----------INSERT INTO oTmpTab:GetRealName()-------------------------------------
    cQuery := " SELECT                                                               "
    cQuery += "           F4C.F4C_FILIAL AS F4C_FILIAL,                              "
    cQuery += "           F4C.F4C_CUUID  AS F4C_CUUID,                               "
    cQuery += "           SE2.E2_F5QUID AS E2_F5QUID                                 "
    cQuery += " FROM                                                                 "
    cQuery += "           ( SELECT * FROM  " + RetSQLName("F4C") + "                 "
    cQuery += "                      WHERE F4C_FILIAL =  '" + xFilial("F4C") + "'    "
    cQuery += "                        AND F4C_CUUID  =  '" + cF4C_CUUID     + "'    "
    cQuery += "                        AND D_E_L_E_T_ =  ' '                   ) F4C "
    cQuery += " INNER JOIN " + RetSQLName("F5M")   + " F5M                           "
    cQuery += "            ON (F5M.F5M_FILIAL = F4C.F4C_FILIAL                       "
    cQuery += "           AND  F5M.F5M_IDDOC  = F4C.F4C_CUUID                        "
    cQuery += "           AND  F5M.D_E_L_E_T_ = ' '  )                               "
    cQuery += " INNER JOIN " + RetSQLName("SE2")   + " SE2                           "
    cQuery += "            ON ("+RU06XFUN09_RetSE2F5MJoinOnString()+"                "
    cQuery += "           AND  SE2.D_E_L_E_T_ = ' '  )                               "
    cQuery += " INNER JOIN " + RetSQLName("F5Q")   + " F5Q                           "
    cQuery += "            ON (F5Q.F5Q_FILIAL = SE2.E2_FILIAL                        "
    cQuery += "           AND  F5Q.F5Q_UID    = SE2.E2_F5QUID                        "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '                                  "
    cQuery += "           AND  F5Q.F5Q_TPAGEN <> "  +  "                            '"
    cQuery +=                     PADR("01",TamSX3("F5Q_TPAGEN")[1])  + "' )         "
    cQuery += " GROUP BY F4C_FILIAL, F4C_CUUID, E2_F5QUID                            "
    cQuery := ChangeQuery(cQuery)
    cFields := "( "
    For nX := 1 To Len(aFields) //get list of fields
        cFields += aFields[nX][1] + ", "
    Next nX
    cFields := Left(cFields,Len(cFields)-2)
    cFields += ") "
    cQuery := " INSERT INTO " + oTmpTab:GetRealName() + " " + cFields + " " + cQuery
    nStat  := TCSqlExec(cQuery)
    If nStat < 0
        cHlpMsg += "TCSQLError() " + TCSQLError()
    EndIf
    RestArea(aArea)
    If Empty(cHlpMsg)
        aRet := {oTmpTab, cHlpMsg}
    Else
        aRet := {Nil,     cHlpMsg}
    EndIf
Return (aRet) /*---------------------------------RU06XFUN35_RetTempTablWTaxAgentsContracts*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN36_RetTaxAgentInvoicesForBS

This function returns a list of VAT Tax agent invoices produced for bank statement
List format: {"F4C_CUUID","E2_F5QUID","F35_FILIAL","F35_KEY"}

@param      Character        cF4C_CUUID // Unique 32symb ID for Bank statement
            Object           oTmpTab    // Temporary table generated by function:
                                        // RU06XFUN35_RetTempTablWTaxAgentsContracts
                                        // it can be Nil.
            Logical          lPackage   // .T. - indicates that we must process 2 or more
                                        //       bank statements, so cF4C_CUUID should be
                                        //       a complex string with delimiters
                                        // .F. - return tax agent VAT invoices only for 1
                                        //       bank statement (Default)
                                        // it is not used yet but it will be used in case
                                        // of list of BS. So, need implementation.
@return     Array            aRet       // aRet[1] == FWTemporaryTable with next fields:
                                        // {"F4C_CUUID","E2_F5QUID","F35_FILIAL",;
                                        // "F35_KEY"                                }
                                        // aRet[2] == (Character) "" or "ErrorMsg"
                                        // In case of no VAT invoices temporary table will
                                        // be empty and cursor will be positioned on eof()
                                        // In case of error: {Nil, "cHlpMsg"} will be
                                        // returned
                                        // aRet[3] == LastRec(). number of last record
@example     
@author      astepanov
@since       June/21/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN36_RetTaxAgentInvoicesForBS(cF4C_CUUID As Character,;
                                             oTmpTab    As Object,;
                                             lPackage   As Logical    )
    Local aArea      As Array
    Local aRet       As Array
    Local aInp       As Array
    Local aFields    As Array
    Local lRes       As Logical
    Local lDelTMP    As Logical
    Local cQuery     As Character
    Local cTab       As Character
    Local cAlias     As Character
    Local cHlpMsg    As Character
    Local cFields    As Character
    Local oRetTab    As Object
    Local nStat      As Numeric
    Local nX         As Numeric
    Local nLastRec   As Numeric
    Default cF4C_CUUID := ""
    Default lPackage   := .F.
    lRes    := .T.
    lDelTMP := .F.
    cTab    := ""
    cHlpMsg := ""
    aRet    := {Nil, cHlpMsg, 0}
    aArea   := GetArea()
    If oTmpTab == Nil
        aInp :=  RU06XFUN35_RetTempTablWTaxAgentsContracts(cF4C_CUUID, lPackage)
        If aInp[1] == Nil
            lRes    := .F.
            cHlpMsg += aInp[2]
        Else
            oTmpTab := aInp[1]
            lDelTMP := .T.
        EndIf
    EndIf
    If lRes
        cAlias  := CriaTrab(, .F.) 
        oRetTab := FWTemporaryTable():New(cAlias)
        aFields := {}
        AADD(aFields, {"F4C_CUUID",;              
                        GetSX3Cache("F4C_CUUID" , "X3_TIPO"   ),;
                        GetSX3Cache("F4C_CUUID" , "X3_TAMANHO"),;
                        GetSX3Cache("F4C_CUUID" , "X3_DECIMAL") })
        AADD(aFields, {"E2_F5QUID",;
                        GetSX3Cache("E2_F5QUID", "X3_TIPO")   ,;
                        GetSX3Cache("E2_F5QUID", "X3_TAMANHO"),;
                        GetSX3Cache("E2_F5QUID", "X3_DECIMAL") })
        AADD(aFields, {"F35_FILIAL",;
                        GetSX3Cache("F35_FILIAL", "X3_TIPO"   ),;
                        GetSX3Cache("F35_FILIAL", "X3_TAMANHO"),;
                        GetSX3Cache("F35_FILIAL", "X3_DECIMAL") })
        AADD(aFields, {"F35_KEY",;
                        GetSX3Cache("F35_KEY"   , "X3_TIPO"   ),;
                        GetSX3Cache("F35_KEY"   , "X3_TAMANHO"),;
                        GetSX3Cache("F35_KEY"   , "X3_DECIMAL") })
        oRetTab:SetFields(aFields)
        oRetTab:AddIndex(cAlias+"01",{"F4C_CUUID" , "E2_F5QUID",;
                                      "F35_FILIAL", "F35_KEY"   })
        oRetTab:Create()
        cQuery := " SELECT                                               "
        cQuery += "         TMP.F4C_CUUID  AS F4C_CUUID,                 "
        cQuery += "         TMP.E2_F5QUID AS E2_F5QUID,                  "
        cQuery += "         F35.F35_FILIAL AS F35_FILIAL,                "
        cQuery += "         F35.F35_KEY    AS F35_KEY                    "
        cQuery += " FROM " + oTmpTab:GetRealName()     + " TMP           "
        cQuery += " INNER JOIN " + RetSQLName("F5P")   + " F5P           "
        cQuery += "            ON (F5P.F5P_FILIAL = TMP.F4C_FILIAL       "
        cQuery += "           AND  F5P.F5P_UIDF4C = TMP.F4C_CUUID        "
        cQuery += "           AND  F5P.D_E_L_E_T_ = ' ')                 "
        cQuery += " INNER JOIN " + RetSQLName("F35")   + " F35           "
        cQuery += "            ON (F35.F35_FILIAL = F5P.F5P_FILIAL       "
        cQuery += "           AND  F35.F35_KEY    = F5P.F5P_KEY          "
        cQuery += "           AND  F35.D_E_L_E_T_ = ' '                  "
        cQuery += "           AND  F35.F35_F5QUID = TMP.E2_F5QUID)      "
        cQuery += " GROUP BY F4C_CUUID, E2_F5QUID, F35_FILIAL, F35_KEY  "
        cQuery := ChangeQuery(cQuery)
        cFields := "( "
        For nX := 1 To Len(aFields) //get list of fields
            cFields += aFields[nX][1] + ", "
        Next nX
        cFields := Left(cFields,Len(cFields)-2)
        cFields += ") "
        cQuery := "INSERT INTO " + oRetTab:GetRealName() + " " + cFields + " " + cQuery
        nStat  := TCSqlExec(cQuery)
        If nStat < 0 
            lRes    := .F.
            cHlpMsg += "TCSQLError() " + TCSQLError()
        EndIf
    EndIf
    nLastRec := 0
    DBSelectArea(cAlias)
    nLastRec := LastRec()
    If lDelTMP
       oTmpTab:Delete() 
    EndIf
    If lRes
        aRet[1] := oRetTab
        aRet[2] := cHlpMsg
        aRet[3] := nLastRec
    Else
        aRet[1] := Nil
        aRet[2] := cHlpMsg
        aRet[3] := nLastRec
    EndIf
    RestArea(aArea)
Return (aRet) /*---------------------------------------RU06XFUN36_RetTaxAgentInvoicesForBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN37_RetPODataByKey

This function recievs search key for payment order and returns data related to passed PO.
So it returns alias to the result of SQL query execution, 
if there is no result a cursor will be positioned on Eof()

@param       Character        cKey   // search key F49_PAYORD
             Character        cIDF49 //            F49_IDF49 
             Character        cStat  // PO status (default "1")
@return      Caharacter       cAlias // alias to SQL query execution result, don't forget
                                     // DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN37_RetPODataByKey(cKey, cIDF49, cStat)

    Local   cAlias       As Character
    Local   cQuery       As Character
    Default cKey       := ""
    Default cIDF49     := ""
    Default cStat      := "1"

    cKey   := PADR(cKey  ,GetSX3Cache("F49_PAYORD","X3_TAMANHO"), ' ')
    cStat  := PADR(cStat ,GetSX3Cache("F49_STATUS","X3_TAMANHO"), ' ')
    cIDF49 := PADR(cIDF49,GetSx3Cache("F49_IDF49" ,"X3_TAMANHO"), " ")
    cQuery := " SELECT                                                             "
    cQuery += " F49.F49_SUPP   As _SUPP,   COALESCE(SA2.A2_NOME,  '')  As _SUPNAM, "
    cQuery += " F49.F49_UNIT   As _UNIT,   F49.F49_IDF49               As _IDF49,  "
    cQuery += " F49.F49_CURREN As _CURREN, COALESCE(CTO.CTO_DESC, '')  As _CURNAM, "
    cQuery += " F49.F49_PREPAY As _PREPAY, F49.F49_DTPAYM              As _DTPAYM, "
    cQuery += " F49.F49_BNKPAY As _BNKPAY, F49.F49_PAYBIK              As _PAYBIK, "
    cQuery += " F49.F49_PAYACC As _PAYACC, F49.F49_PAYNAM              As _PAYNAM, "
    cQuery += " F49.F49_REASON As _REASON, F49.F49_VALUE               As _VALUE,  "
    cQuery += " F49.F49_F5QUID As _UIDF5Q, F49.F49_CNT                 As _CNT,    "
    cQuery += " F49.F49_CLASS  As _CLASS,  COALESCE(F5Q.F5Q_DESCR,'')  As _F5QDES, "
    cQuery += " F49.F49_VATCOD As _VATCOD, F49.F49_VATRAT              As _VATRAT, "
    cQuery += " F49.F49_VATAMT As _VATAMT, F49.F49_KPPREC              As _KPPREC, "
    cQuery += " F49.F49_BNKREC As _BNKREC, F49.F49_RECBIK              As _RECBIK, "
    cQuery += " F49.F49_RECACC As _RECACC, F49.F49_RECNAM              As _RECNAM, "
    cQuery += " F49.F49_CTPRE  As _CTPRE,  F49.F49_CTPOS               As _CTPOS,  "
    cQuery += " F49.F49_CCPRE  As _CCPRE,  F49.F49_CCPOS               As _CCPOS,  "
    cQuery += " F49.F49_ITPRE  As _ITPRE,  F49.F49_ITPOS               As _ITPOS,  "
    cQuery += " F49.F49_CLPRE  As _CLPRE,  F49.F49_CLPOS               As _CLPOS,  "
    cQuery += " F49.F49_BNKORD As _BNKORD, COALESCE(FIL.FIL_TIPO,  '') As _TYPCC,  "
    cQuery += "                            COALESCE(FIL.FIL_ACNAME,'') As _ACRNAM, "
    cQuery += "                            COALESCE(F45.F45_NAME,  '') As _BKRNAM, "
    cQuery += "                            COALESCE(SA6.A6_NOME,   '') As _BKPNAM, "
    cQuery += "                            COALESCE(SA6.A6_ACNAME, '') As _ACPNAM  "
    cQuery += " FROM                                                               "
    cQuery += "       ( SELECT *                                    "
    cQuery += "         FROM " + RetSQlName("F49") + "              "
    cQuery += "         WHERE F49_FILIAL = '" + xFilial("F49") + "' "
    cQuery += "         AND   F49_IDF49  = '" + cIDF49         + "' "
    cQuery += "         AND   F49_PAYORD = '" + cKey           + "' "
    cQuery += "         AND   F49_STATUS = '" + cStat          + "' "
    cQuery += "         AND   D_E_L_E_T_ = ' ') As F49              "
    cQuery += " LEFT JOIN " + RetSQlName("SA2")   + " As SA2                       "
    cQuery += "           ON  (SA2.A2_FILIAL  = '"+ xFilial("SA2") + "'            "
    cQuery += "           AND  SA2.A2_COD     = F49.F49_SUPP                       "
    cQuery += "           AND  SA2.A2_LOJA    = F49.F49_UNIT                       "
    cQuery += "           AND  SA2.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("CTO")   + " As CTO                       "
    cQuery += "           ON  (CTO.CTO_FILIAL = '"+ xFilial("CTO") + "'            "
    cQuery += "           AND CTO.CTO_MOEDA   = F49.F49_CURREN                     "
    cQuery += "           AND CTO.D_E_L_E_T_  = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQLName("F5Q")   + " As F5Q                       "
    cQuery += "           ON  (F5Q.F5Q_FILIAL = F49.F49_FILIAL                     "
    cQuery += "           AND  F5Q.F5Q_UID    = F49.F49_F5QUID                     "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQLName("FIL")   + " As FIL                       "
    cQuery += "           ON  (FIL.FIL_FILIAL = '"+ xFilial("FIL") + "'            "
    cQuery += "           AND  FIL.FIL_FORNEC = F49.F49_SUPP                       "
    cQuery += "           AND  FIL.FIL_LOJA   = F49.F49_UNIT                       "
    cQuery += "           AND  FIL.FIL_BANCO  = F49.F49_BNKREC                     "
    cQuery += "           AND  FIL.FIL_AGENCI = F49.F49_RECBIK                     "
    cQuery += "           AND  FIL.FIL_CONTA  = F49.F49_RECACC                     "
    cQuery += "           AND  FIL.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("F45")   + " As F45                       "
    cQuery += "           ON  (F45.F45_FILIAL = '"+ xFilial("F45") + "'            "
    cQuery += "           AND  F45.F45_BIK    = F49.F49_RECBIK                     "
    cQuery += "           AND  F45.D_E_L_E_T_ = ' '           )                    "
    cQuery += " LEFT JOIN " + RetSQlName("SA6")   + " As SA6                       "
    cQuery += "           ON  (SA6.A6_FILIAL  = '"+ xFilial("SA6") + "'            "
    cQuery += "           AND  SA6.A6_COD     = F49.F49_BNKPAY                     "
    cQuery += "           AND  SA6.A6_AGENCIA = F49.F49_PAYBIK                     "
    cQuery += "           AND  SA6.A6_NUMCON  = F49.F49_PAYACC                     "
    cQuery += "           AND  SA6.D_E_L_E_T_ = ' '           )                    "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

Return (cAlias) /*-----------------------------------------------RU06XFUN37_RetPODataByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN38_RetSuppDataByKey

Get Supplier information using key: filial+cod+loja
Also it returns supplier bank information from FIL table and F45 table, using left join

@param       Character        cCoD   // A2_COD
             Character        cLoja  // A2_LOJA
             Numeric          nMoeda // currency number, for searching account by currency
             Character        cBnkrec // bank BIK code
             Character        cJoin  // how FIL will be connected to SA2    
             Logical          lExClsd // exclude closed bank accounts  if .T., we add
                                      // condition  FIL.FIL_CLOSED  = '2'
             Character        cRecBik // bank BIK code FIL_AGENCI
             Character        cRecAcc // bank account code FIL_CONTA
@return      Object           cAlias // alias to sql query result, 
                                     // don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN38_RetSuppDataByKey(cCod, cLoja, nMoeda, cBnkRec, cJoin, lExClsd, cRecBik,;
                                     cRecAcc)

    Local   cMoeda  As Character
    Local   cAlias  As Character
    Local   cQuery  As Character
    Default cCoD    := ""
    Default cLoja   := ""
    Default nMoeda  := 0
    Default cBnkRec := ""
    Default cJoin   := " LEFT JOIN "
    Default lExClsd := .F.
    Default cRecBik := ""
    Default cRecAcc := ""
 
    cCOD    := PADR(cCOD   , GetSX3Cache("A2_COD"    ,"X3_TAMANHO"))
    cLoja   := PADR(cLoja  , GetSX3Cache("A2_LOJA"   ,"X3_TAMANHO"))
    cBnkRec := PADR(cBnkRec, GetSX3Cache("FIL_BANCO" ,"X3_TAMANHO"))
    cRecBik := PADR(cRecBik, GetSX3Cache("FIL_AGENCI","X3_TAMANHO"))
    cRecAcc := PADR(cRecAcc, GetSX3Cache("FIL_CONTA" ,"X3_TAMANHO"))
    cMoeda := cValToChar(nMoeda)
    cQuery := " SELECT                                                         "
    cQuery += " SA2.A2_NOME                 As _SUPNAM, SA2.A2_KPP As _KPPREC, "
    cQuery += " SA2.A2_LOJA                 As _UNIT,                          "
    cQuery += " COALESCE(FIL.FIL_BANCO ,'') As _BNKREC,                        "
    cQuery += " COALESCE(FIL.FIL_AGENCI,'') As _RECBIK,                        "
    cQuery += " COALESCE(FIL.FIL_CONTA ,'') As _RECACC,                        "
    cQuery += " COALESCE(FIL.FIL_TIPO  ,'') As _TYPCC ,                        "
    cQuery += " COALESCE(F45.F45_NAME  ,'') As _BKRNAM,                        "
    cQuery += " COALESCE(FIL.FIL_ACNAME,'') As _ACRNAM,                        "
    cQuery += " LEFT(TRIM(COALESCE(FIL.FIL_NMECOR,' ')),100) As _RECNAM,       "
    cQuery += " COALESCE(FIL.FIL_MOEDA , 0) As _CURREN                         "        
    cQuery += " FROM                                                           "
    cQuery += "       (SELECT * FROM " + RetSQLName("SA2") + "                 "
    cQuery += "                 WHERE A2_FILIAL  = '" + xFilial("SA2") + "'    "
    cQuery += "                 AND   A2_COD     = '" + cCoD           + "'    "
    If !Empty(cLoja)
        cQuery += "             AND   A2_LOJA    = '" + cLoja          + "'    "
    EndIf
    cQuery += "                 AND   D_E_L_E_T_ = ' '  ) As SA2               "
    cQuery += cJoin         + RetSQLName("FIL") + " As FIL                     "
    cQuery += "           ON  (FIL.FIL_FILIAL  = '"+xFilial("FIL")+"'          "
    cQuery += "           AND  FIL.FIL_FORNEC  = SA2.A2_COD                    "
    cQuery += "           AND  FIL.FIL_LOJA    = SA2.A2_LOJA                   "
    If nMoeda != 0
        cQuery += "       AND  FIL.FIL_MOEDA   =  "+    cMoeda    +"           "
    EndIf
    If !Empty(cBnkRec)
        cQuery += "       AND  FIL.FIL_BANCO   = '"+    cBnkRec   +"'          "
    EndIf
    If !Empty(cRecBik)
        cQuery += "       AND  FIL_AGENCI      = '"+    cRecBik    +"'         "
    EndIf
    If !Empty(cRecAcc)
        cQuery += "       AND  FIL_CONTA       = '"+    cRecAcc    +"'         "
    EndIf
    If lExClsd
        cQuery += "       AND  FIL.FIL_CLOSED  = '2'                           "
    EndIf
    cQuery += "           AND  FIL.D_E_L_E_T_  = ' '                )          "
    cQuery += cJoin         + RetSQLName("F45") + " As F45                     "
    cQuery += "           ON  (F45.F45_FILIAL  = '"+xFilial("F45")+"'          "
    cQuery += "           AND  F45.F45_BIK     = FIL.FIL_AGENCI                "
    cQuery += "           AND  F45.D_E_L_E_T_  = ' '                )          "
    //          -- MAIN ACCOUNT SHOULD BE FIRST IN THE RESULT                  
    cQuery += " ORDER BY _SUPNAM, _UNIT, _TYPCC                                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

    
Return (cAlias) /*---------------------------------------------RU06XFUN38_RetSuppDataByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN39_RetBankAccountDataFromSA6

Function returns alias to the query result with bank account information according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query. If lFull == .T.  - function will search bank account information 
using all parameteres cBnkCod+cBik+cAcc and no matter empty this parameter or not.

@param       Character        cBnkCod  // A6_COD
             Character        cBik     // A6_AGENCIA
             Character        cAcc     // A6_NUMCON
             Numeric          nMoeda   // A6_MOEDA
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cBnkCod == A6_COD,
                                       //  cBik == A6_AGENCIA, cAcc == A6_NUMCON
                                       // So if lFull == .T. should be returned 
                                       // after query execution 1 or 0 lines, no more
                                       // If lFull == .F., it can be returned several lines
             Logical          lExBlkd  // If .T. Blocked accounts with A6_BLOCKED == "1"
                                          will be excluded, if .F. (default) blocked accnts
                                          will be included in query result. So only
                                          accounts with A6_BLOCKED == "2" will be included
                                          in query result if this parameter equals .T.
             Logical          lOBncAc  // .T. select only non cash account
                                       //TIPBCO = "1"
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN39_RetBankAccountDataFromSA6(cBnkCod, cBik, cAcc, nMoeda, lFull,;
                                              lExBlkd, lOBncAc                   )

    Local cAlias      As Character
    Local cQuery      As Character
    Local cMoeda      As Character
    Local cLstOfOrder As Character

    Default nMoeda  := 0
    Default cBnkCod := ""
    Default cBik    := ""
    Default cAcc    := ""
    Default lFull   := .F.
    Default lExBlkd := .F.
    Default lOBncAc := .F.
    
    cLstOfOrder := " SA6.A6_TYPEACC "
    cMoeda      := cValToChar(nMoeda)
    cBnkCod     := PADR(cBnkCod, GetSX3Cache("A6_COD"    ,"X3_TAMANHO"))
    cBik        := PADR(cBik   , GetSX3Cache("A6_AGENCIA","X3_TAMANHO"))
    cAcc        := PADR(cAcc   , GetSX3Cache("A6_NUMCON" ,"X3_TAMANHO"))
    cQuery := " SELECT                                                     "
    cQuery += " SA6.A6_MOEDA      _CURREN, SA6.A6_COD          _BNKPAY,    "
    cQuery += " SA6.A6_AGENCIA    _PAYBIK, SA6.A6_NUMCON       _PAYACC,    "
    cQuery += " SA6.A6_NOME       _BKPNAM, SA6.A6_ACNAME       _ACPNAM,    "
    cQuery += " TRIM(SA6.A6_NAMECOR)  _PAYNAM,                             "
    cQuery += "                            SA6.A6_COD          _BNKREC,    "
    cQuery += " SA6.A6_AGENCIA    _RECBIK, SA6.A6_NUMCON       _RECACC,    "
    cQuery += " SA6.A6_NOME       _BKRNAM, SA6.A6_ACNAME       _ACRNAM,    "
    cQuery += " TRIM(SA6.A6_NAMECOR)  _RECNAM,                             "
    cQuery += " SA6.A6_TYPEACC    _TYPCC,  SA6.A6_TYPEACC      _TYPCP      "
    cQuery += " FROM " + RetSQLName("SA6") + "    SA6                      "
    cQuery += " WHERE     SA6.A6_FILIAL  = '" + xFilial("SA6") + "'        "
    //-- FILTERS------------------------------------------------------------
    If nMoeda != 0
        cQuery += "   AND SA6.A6_MOEDA   =  " +   cMoeda       + "         "    
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery += "   AND SA6.A6_COD     = '" +   cBnkCod      + "'        "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery += "   AND SA6.A6_AGENCIA = '" +     cBik       + "'        "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery += "   AND SA6.A6_NUMCON  = '" +     cAcc       + "'        "
    EndIf
    If lExBlkd
        cQuery += "   AND SA6.A6_BLOCKED = '" +     "2"        + "'        " 
    EndIf
    If lOBncAc
        cQuery += "   AND SA6.A6_TIPBCO  = '" +     "1"        + "'        "
    EndIf
    //-- FILTERS------------------------------------------------------------
    cQuery += "       AND SA6.D_E_L_E_T_ = ' '                             "
    cQuery += " ORDER BY  " +cLstOfOrder + "                               "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    
Return (cAlias) /*------------------------------------RU06XFUN39_RetBankAccountDataFromSA6*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN40_RetBankAccountDataFromFIL

Function returns alias to the query result with bank account information from FIL according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query.
cSupp and cUnit are obligatory.
If lFull == .T.  - function will search bank account information 
using all parameteres cSupp+cUnit+cBnkCod+cBik+cAcc 
and no matter empty this parameter or not.

param        Character        cSupp    // Supplier's code (obligatory) FIL_FORNEC
             Character        cUnit    // Supplier's loja (obligatory) FIL_LOJA
             Numeric          nMoeda   // FIL_MOEDA
             Character        cBnkCod  // FIL_BANCO
             Character        cBik     // FIL_AGENCI
             Character        cAcc     // FIL_CONTA
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cSupp+cUnit+cBnkCod+cBik+cAcc
                                       // So, after query execution 1 or 0 lines 
                                       // will be returned, no more.
                                       // If lFull == .F., it can be returned several lines
             Logical          LJnF45   // If .T.(Default) - F45 fields will be joined, .F. -
                                       // we don't left join F45
             Logical          lExClsd  // if .T. we exclude form result closed bank accounts
                                       // FIL.FIL_CLOSED  = '2'
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@example     
@author      astepanov
@since       July/01/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN40_RetBankAccountDataFromFIL(cSupp, cUnit, nMoeda, cBnkCod, cBik, cAcc,;
                                              lFull, lJnF45, lExClsd)

    Local cAlias       As Character
    Local cMoeda       As Character
    Local cQuery       As Character
    Local cLstOfOrder  As Character
    Default nMoeda  := 0
    Default lFull   := .F.
    Default cSupp   := ""
    Default cUnit   := ""
    Default cBnkCod := ""
    Default cAcc    := ""
    Default lJnF45  := .T.
    Default lExClsd := .F.

    cSupp   := PADR(cSupp,  GetSX3Cache("FIL_FORNEC" ,"X3_TAMANHO"))
    cUnit   := PADR(cUnit,  GetSX3Cache("FIL_LOJA"   ,"X3_TAMANHO"))
    cMoeda  := cValToChar(nMoeda)
    cBnkCod := PADR(cBnkCod,GetSX3Cache("FIL_BANCO"  ,"X3_TAMANHO"))
    cBik    := PADR(cBik,   GetSX3Cache("FIL_AGENCI" ,"X3_TAMANHO"))
    cAcc    := PADR(cAcc,   GetSX3Cache("FIL_CONTA"  ,"X3_TAMANHO"))
    cLstOfOrder := " FIL.FIL_TIPO "

    cQuery  := " SELECT                                                         "
    cQuery  += " FIL.FIL_TIPO   _TYPCC ,                                        "
    cQuery  += " FIL.FIL_ACNAME _ACNAME, FIL.FIL_REASON            _REASON  ,   "
    cQuery  += " TRIM(FIL.FIL_NMECOR)      _RECNAM,                             "
    If lJnF45
        cQuery += " COALESCE(F45.F45_NAME,'') _BKNAME,                          "
        cQuery += " COALESCE(F45.F45_NAME,'') _BKRNAM,                          "
    EndIf
    cQuery  += " FIL.FIL_ACNAME            _ACRNAM,                             "
    cQuery  += " FIL.R_E_C_N_O_            _FILREC,                             "
    cQuery  += " FIL.FIL_MOEDA             _MOEDA                               "
    cQuery  += " FROM                                                           "
    cQuery  += " (SELECT * FROM " + RetSQLName("FIL") + "                       "
    cQuery  += " WHERE    FIL_FILIAL  = '" + xFilial("FIL") + "'                "
    cQuery  += "     AND  FIL_FORNEC  = '"   +     cSupp    + "'                "
    cQuery  += "     AND  FIL_LOJA    = '"   +     cUnit    + "'                "
    //-- FILTERS-----------------------------------------------------------------
    If nMoeda != 0
        cQuery  += " AND  FIL_MOEDA   =  "   +     cMoeda   + "                 "
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery  += " AND  FIL_BANCO   = '"   +    cBnkCod   + "'                "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery  += " AND  FIL_AGENCI  = '"   +     cBik     + "'                "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery  += " AND  FIL_CONTA   = '"   +     cAcc     + "'                "
    EndIf
    If lExClsd
        cQuery  += " AND  FIL_CLOSED  = '"   +     "2"      + "'                "
    EndIf
    //-- FILTERS-----------------------------------------------------------------
    cQuery  +=  "    AND  D_E_L_E_T_  = ' '                                     "
    cQuery  +=  "                              ) FIL                            "
    If lJnF45
        cQuery  +=  " LEFT JOIN " + RetSQLName("F45")  + " F45                  "
        cQuery  +=  "         ON (F45.F45_FILIAL = '" + xFilial("F45") + "'     "
        cQuery  +=  "        AND  F45.F45_BIK    = FIL.FIL_AGENCI               "
        cQuery  +=  "        AND  F45.D_E_L_E_T_ = ' ')                         "
    EndIf
    cQuery  +=  " ORDER BY " + cLstOfOrder + "                                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)

Return (cAlias) /*------------------------------------RU06XFUN40_RetBankAccountDataFromFIL*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN42_RetBankAccountDataFromF4N
Function returns alias to the query result with bank account information from F4N according
the parameters passed to this function,
If lFull == .F. function checks cBnkCod, cBik, cAcc. If someone is empty it will
be excluded from query.
cSupp and cUnit are obligatory.
If lFull == .T.  - function will search bank account information 
using all parameteres cCust+cUnit+cBnkCod+cBik+cAcc 
and no matter empty this parameter or not.

@param       Character        cCust    // Customer's code (obligatory) F4N_CLIENT
             Character        cUnit    // Customer's loja (obligatory) F4N_LOJA
             Character        cMoeda   // F4N_CURREN
             Character        cBnkCod  // F4N_BANK
             Character        cBik     // F4N_BIK
             Character        cAcc     // F4N_ACC
             Logical          lFull    // If .T. should be returned account data
                                       // by next search key: cCust+cUnit+cBnkCod+cBik+cAcc
                                       // So, after query execution 1 or 0 lines 
                                       // will be returned, no more.
                                       // If lFull == .F., it can be returned several lines
@return      Character        cAlias   // alias to query result, don't forget DBCloseArea()
@author      astepanov
@since       July/03/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN42_RetBankAccountDataFromF4N(cCust, cUnit, cMoeda, cBnkCod, cBik, cAcc,;
                                              lFull)

    Local cAlias      As Character
    Local cLstOfOrder As Character
    Local cQuery      As Character
    Default cCust     := ""
    Default cUnit     := ""
    Default cBnkCod   := ""
    Default cBik      := ""
    Default cAcc      := ""

    cCust   := PADR(cCust,  GetSX3Cache("F4N_CLIENT" ,"X3_TAMANHO"))
    cUnit   := PADR(cUnit,  GetSX3Cache("F4N_LOJA"   ,"X3_TAMANHO"))
    cBnkCod := PADR(cBnkCod,GetSX3Cache("F4N_BANK"   ,"X3_TAMANHO"))
    cBik    := PADR(cBik,   GetSX3Cache("F4N_BIK"    ,"X3_TAMANHO"))
    cAcc    := PADR(cAcc,   GetSX3Cache("F4N_ACC"    ,"X3_TAMANHO"))
    If !Empty(cMoeda)
        cMoeda  := PADL(AllTrim(cMoeda), GetSX3Cache("F4N_CURREN","X3_TAMANHO"),"0")
    EndIf
    cLstOfOrder := " F4N.F4N_TYPE "

    cQuery  := " SELECT                                                         "
    cQuery  += " F4N.F4N_TYPE   _TYPCP , COALESCE(F45.F45_NAME,'') _BKPNAM ,    "
    cQuery  += " F4N.F4N_ACNAME _ACPNAM, F4N.F4N_NMECOR            _PAYNAM ,    "
    cQuery  += " F4N.F4N_ACC    _PAYACC, F4N.F4N_BIK               _PAYBIK ,    "
    cQuery  += " F4N.F4N_BANK   _BNKPAY                                         "
    cQuery  += " FROM                                                           "
    cQuery  += " (SELECT * FROM " + RetSQLName("F4N") + "                       "
    cQuery  += " WHERE    F4N_FILIAL  = '" + xFilial("F4N") + "'                "
    cQuery  += "     AND  F4N_CLIENT  = '"   +     cCust    + "'                "
    cQuery  += "     AND  F4N_LOJA    = '"   +     cUnit    + "'                "
    //-- FILTERS-----------------------------------------------------------------
    If !Empty(cMoeda)
        cQuery  += " AND  F4N_CURREN  = '"   +     cMoeda   + "'                "
    EndIf
    If !Empty(cBnkCod) .OR. lFull
        cQuery  += " AND  F4N_BANK    = '"   +    cBnkCod   + "'                "
    EndIf
    If !Empty(cBik)    .OR. lFull
        cQuery  += " AND  F4N_BIK     = '"   +     cBik     + "'                "
    EndIf
    If !Empty(cAcc)    .OR. lFull
        cQuery  += " AND  F4N_ACC     = '"   +     cAcc     + "'                "
    EndIf
    //-- FILTERS-----------------------------------------------------------------
    cQuery  +=  "    AND  D_E_L_E_T_  = ' '                                     "
    cQuery  +=  "                              ) F4N                            "
    cQuery  +=  " LEFT JOIN " + RetSQLName("F45")  + " F45                      "
    cQuery  +=  "         ON (F45.F45_FILIAL = '" + xFilial("F45") + "'         "
    cQuery  +=  "        AND  F45.F45_BIK    = F4N.F4N_BIK                      "
    cQuery  +=  "        AND  F45.D_E_L_E_T_ = ' ')                             "
    cQuery  +=  " ORDER BY " + cLstOfOrder + "                                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
  
Return (cAlias) /*------------------------------------RU06XFUN42_RetBankAccountDataFromF4N*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN43_RetCustDataByKey()
Get Customer information using key: filial+cod+loja
Also it returns customer's bank information from F4N table and F45 table, using left join 
by default or cJoin from parameter.
@param       Character        cCoD    // A1_COD
             Character        cLoja   // A1_LOJA
             Character        cMoeda  // currency code, for searching account by currency
             Character        cBnkRec // bank code
             Character        cBnkBIC // bank BIC
             Character        cBnkAcc // bank account
             Character        cJoin   // how F4N will be connected to SA1
             Logical          lExClsd // exclude form query closed bank accounts         
@return      Object           cAlias  // alias to sql query result, 
                                      // don't forget DBCloseArea()
@example     
@author      astepanov
@since       June/27/2019
@edit        November/03/2020
@version     1.1
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN43_RetCustDataByKey(cCod, cLoja, cMoeda, cBnkRec, cBnkBIC, cBnkAcc, cJoin, lExClsd)

    Local   cAlias  As Character
    Local   cQuery  As Character
    Default cCoD    := ""
    Default cLoja   := ""
    Default cMoeda  := ""
    Default cBnkRec := ""
    Default cJoin   := " LEFT JOIN "
    Default lExClsd := .F.
 
    cCOD    := PADR(cCOD   , GetSX3Cache("A1_COD"   ,"X3_TAMANHO"))
    cLoja   := PADR(cLoja  , GetSX3Cache("A1_LOJA"  ,"X3_TAMANHO"))
    cBnkRec := PADR(cBnkRec, GetSX3Cache("F4N_BANK" ,"X3_TAMANHO"))
    cBnkBIC := PADR(cBnkBIC, GetSX3Cache("F4N_BIK"  ,"X3_TAMANHO"))
    cBnkAcc := PADR(cBnkAcc, GetSX3Cache("F4N_ACC"  ,"X3_TAMANHO"))
    If !Empty(cMoeda)
        cMoeda  := PADL(AllTrim(cMoeda), GetSX3Cache("F4N_CURREN","X3_TAMANHO"),"0")
    EndIf
    cQuery := " SELECT   
    cQuery += " SA1.A1_NOME                  _CUSNAM, SA1.A1_INSCGAN  _KPPPAY, "
    cQuery += " SA1.A1_LOJA                  _CUNI  ,                          "
    cQuery += " COALESCE(F4N.F4N_BANK,  '')  _BNKPAY,                          "
    cQuery += " COALESCE(F4N.F4N_BIK,   '')  _PAYBIK,                          "
    cQuery += " COALESCE(F4N.F4N_ACC,   '')  _PAYACC,                          "
    cQuery += " COALESCE(F4N.F4N_TYPE,  '')  _TYPCP ,                          "
    cQuery += " COALESCE(F45.F45_NAME,  '')  _BKPNAM,                          "
    cQuery += " COALESCE(F4N.F4N_ACNAME,'')  _ACPNAM,                          "
    cQuery += " COALESCE(F4N.F4N_NMECOR,'')  _PAYNAM,                          "
    cQuery += " COALESCE(F4N.F4N_CURREN,'')  _CURREN                           " 
    cQuery += " FROM                                                           "
    cQuery += "       (SELECT * FROM " + RetSQLName("SA1") + "                 "
    cQuery += "                 WHERE A1_FILIAL  = '" + xFilial("SA1") + "'    "
    cQuery += "                 AND   A1_COD     = '" + cCoD           + "'    "
    If !Empty(cLoja)
        cQuery += "             AND   A1_LOJA    = '" + cLoja          + "'    "
    EndIf
    cQuery += "                 AND   D_E_L_E_T_ = ' '  )    SA1               "
    cQuery += cJoin         + RetSQLName("F4N") + "    F4N                     "
    cQuery += "           ON  (F4N.F4N_FILIAL  = '"+xFilial("F4N")+"'          "
    cQuery += "           AND  F4N.F4N_CLIENT  = SA1.A1_COD                    "
    cQuery += "           AND  F4N.F4N_LOJA    = SA1.A1_LOJA                   "
    If !Empty(cMoeda)
        cQuery += "       AND  F4N.F4N_CURREN  = '"+    cMoeda    +"'          "
    EndIf
    If !Empty(cBnkRec)
        cQuery += "       AND  F4N.F4N_BANK    = '"+    cBnkRec   +"'          "
    EndIf
    If !Empty(cBnkBIC)
        cQuery += "       AND  F4N.F4N_BIK     = '"+    cBnkBIC   +"'          "
    EndIf
    If !Empty(cBnkAcc)
        cQuery += "       AND  F4N.F4N_ACC     = '"+    cBnkAcc   +"'          "
    EndIf
    If lExClsd
        cQuery += "       AND  F4N.F4N_CLOSED  = '2'                           "
    EndIf
    cQuery += "           AND  F4N.D_E_L_E_T_  = ' '                )          "
    cQuery += cJoin         + RetSQLName("F45") + "    F45                     "
    cQuery += "           ON  (F45.F45_FILIAL  = '"+xFilial("F45")+"'          "
    cQuery += "           AND  F45.F45_BIK     = F4N.F4N_BIK                   "
    cQuery += "           AND  F45.D_E_L_E_T_  = ' '                )          "
    //          -- MAIN ACCOUNT SHOULD BE FIRST IN THE RESULT                  
    cQuery += " ORDER BY _CUSNAM, _CUNI, _TYPCP                                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    
Return (cAlias) /*---------------------------------------------------RU06XFUN43_RetCustDataByKey*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN33_RetPOLinesByKey

Function returns payment order lines from F4B table, according
to passed payment order number F49_PAYORD(C:10) and payment order ID cF49IDF49(C:32)
used tables: F49 - Payment order, F4A - Payment order details, F4B - Payment order bills
SE2 - Accounts payable, F5Q - legal contracts

@param       Character        cF49PayOrd // F49_PAYORD
             Character        cF49IDF49  // F49_IDF49
             Array            aVrtFields
             Array            aF5MFields
@return      Character        cAlias     // alias to sql query result, don't forget about
                                            DBCloseArea()
@example     
@author      astepanov
@since       July/15/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------------/*/
Function RU06XFUN33_RetPOLinesByKey(cF49PayOrd As Character, cF49IDF49 As Character,;
                                    aVrtFields As Array    , aF5MFields As Array    )

    Local   cAlias     As Character
    Local   cQuery     As Character
    Local   cF5MLen    As Character
    Local   nX         As Numeric
    Default cF49PayOrd := ""
    Default cF49IDF49  := ""

    cF49IDF49  := PADR(AllTrim(cF49IDF49), GetSX3Cache("F49_IDF49" ,"X3_TAMANHO")," ")
    cF49PayOrd := PADR(AllTrim(cF49PayOrd),GetSX3Cache("F49_PAYORD","X3_TAMANHO")," ")
    cF5MLen    := RU06XFUN44_RetSE2FldsPosInFMKey()[8][2]
    cQuery := " SELECT                                                                           "
    cQuery += " F4B.F4B_FLORIG   B_FLORIG, F4B.F4B_PREFIX   B_PREFIX,  F4B.F4B_NUM     B_NUM    ,"
    cQuery += " F4B.F4B_PARCEL   B_PARCEL, F4B.F4B_TYPE     B_TYPE  ,  F49.F49_SUPP    B_FORNECE,"
    cQuery += " F49.F49_UNIT     B_LOJA  ,                             F4B.F4B_EXGRAT  B_EXGRAT ,"
    cQuery += " F4B.F4B_VALCNV   B_VALCNV, F4B.F4B_BSVATC   B_BSVATC,  F4B.F4B_VLVATC  B_VLVATC ,"
    cQuery += " F4B.F4B_RATUSR   B_RATUSR, F4B.F4B_VALPAY   B_VALPAY,  F4B.F4B_CONUNI  B_CONUNI ,"
    cQuery += " F4B.F4B_IDF4A    B_IDF4A , F4B.F4B_FILIAL   B_BRANCH,  F4B.F4B_RATUSR  B_CHECK  ,"
    cQuery += " COALESCE(F4A.F4A_CODREQ, '')              B_CODREQ  ,                            "
    cQuery += " COALESCE(SE2.E2_NATUREZ, '')              B_CLASS   ,                            "
    cQuery += " COALESCE(SE2.E2_EMISSAO, '')              B_EMISS   ,                            "
    cQuery += " COALESCE(SE2.E2_VENCREA, '')              B_REALMT  ,                            "
    cQuery += " COALESCE(SE2.E2_VALOR  ,  0)              B_VALUE   ,                            "
    cQuery += " COALESCE(SE2.E2_MOEDA  ,  1)              B_CURREN  ,                            "
    cQuery += " COALESCE(SE2.E2_SALDO  ,  0)              E2_SALDO  ,                            "
    cQuery += " COALESCE(SE2.E2_BASIMP1,  0)              E2_BASIMP1,                            "
    cQuery += " COALESCE(SE2.E2_ALQIMP1,  0)              B_ALIMP1  ,                            "
    cQuery += " COALESCE(SE2.E2_VALIMP1,  0)              E2_VALIMP1,                            "
    // Calculate B_OPBAL
    cQuery += " CASE WHEN COALESCE(OPB.F5MCTRBAL, '1')  = '1'                                    "
    cQuery += " THEN                                                                             "
    cQuery += " ( COALESCE(SE2.E2_SALDO, 0) -                                                    "
    cQuery += "   COALESCE(OPB.OPBVALUE, 0) +                                                    "
    cQuery += "   F4B.F4B_VALPAY                                                                 "
    cQuery += " )                                                                                "
    cQuery += " ELSE                                                                             "
    cQuery += " ( COALESCE(SE2.E2_SALDO, 0) -                                                    "
    cQuery += "   COALESCE(OPB.OPBVALUE, 0)                                                      "
    cQuery += " )                                                                                "
    cQuery += " END                                                                   B_OPBAL   ,"
    // B_VLCRUZ
    cQuery += " COALESCE(SE2.E2_VLCRUZ,0)                                             B_VLCRUZ  ,"
    // B_VLIMP1
    cQuery += " F4B.F4B_VLIMP1                                                        B_VLIMP1  ,"
    // B_BSIMP1
    cQuery += " COALESCE(SE2.E2_BASIMP1,0)                                            B_BSIMP1  ,"
    cQuery += " COALESCE(SE2.E2_CONUNI ,'2')                                          E2_CONUNI ,"
    cQuery += " COALESCE(F5Q.F5Q_CODE  , '')                                          B_MDCNTR  ,"
    cQuery += " '"+xFilial("F5M")+"'                                      F5M_FILIAL,            "
    cQuery += " COALESCE(OPB.F5MCTRBAL, '1')                              F5M_CTRBAL,            "
    cQuery += " F4B.F4B_VALPAY F5M_VALPAY, F4B.F4B_EXGRAT F5M_EXGRAT,  F4B.F4B_VALCNV F5M_VALCNV,"
    cQuery += " F4B.F4B_BSVATC F5M_BSVATC, F4B.F4B_VLVATC F5M_VLVATC,  F4B.F4B_RATUSR F5M_RATUSR,"
    cQuery += " ' '            F5M_IDDOC , ' '            F5M_ALIAS ,  ' '            F5M_KEY,   "
    cQuery += " 0              F5M_RTORIG, 0              F5M_VLORIG,  ' '            F5M_KEYALI "
    cQuery += " FROM                                                                             "
    cQuery += "              ( SELECT *                                                          "
    cQuery += "                         FROM " + RetSQLName("F49") +  "                          "
    cQuery += "                         WHERE F49_FILIAL =   '" + xFilial("F49")      + "'       "
    cQuery += "                           AND F49_IDF49  =   '" + cF49IDF49           + "'       "
    cQuery += "                           AND F49_PAYORD =   '" + cF49PayOrd          + "'       "
    cQuery += "                           AND D_E_L_E_T_ = ' '          ) F49                    "
    cQuery += " INNER JOIN " + RetSQLName("F4B") + "  F4B                                        "
    cQuery += "            ON (F4B.F4B_FILIAL = F49.F49_FILIAL                                   "
    cQuery += "           AND  F4B.F4B_IDF49  = F49.F49_IDF49                                    "
    cQuery += "           AND  F4B.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT  JOIN " + RetSQLName("F4A") + "  F4A                                        "
    cQuery += "            ON (F4A.F4A_FILIAL = F4B.F4B_FILIAL                                   "
    cQuery += "           AND  F4A.F4A_IDF4A  = F4B.F4B_IDF4A                                    "
    cQuery += "           AND  F4A.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT  JOIN " + RetSQLName("SE2") + "  SE2                                        "
    cQuery += "            ON (SE2.E2_FILIAL  = F4B.F4B_FLORIG                                   "
    cQuery += "           AND  SE2.E2_PREFIXO = F4B.F4B_PREFIX                                   "
    cQuery += "           AND  SE2.E2_NUM     = F4B.F4B_NUM                                      "
    cQuery += "           AND  SE2.E2_PARCELA = F4B.F4B_PARCEL                                   "
    cQuery += "           AND  SE2.E2_TIPO    = F4B.F4B_TYPE                                     "
    cQuery += "           AND  SE2.E2_FORNECE = F49.F49_SUPP                                     "
    cQuery += "           AND  SE2.E2_LOJA    = F49.F49_UNIT                                     "
    cQuery += "           AND  SE2.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT JOIN  " + RetSQLName("F5Q") + "  F5Q                                        "
    cQuery += "            ON (F5Q.F5Q_FILIAL = SE2.E2_FILIAL                                    "
    cQuery += "           AND  F5Q.F5Q_UID    = SE2.E2_F5QUID                                    "
    cQuery += "           AND  F5Q.D_E_L_E_T_ = ' '           )                                  "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "           ( SELECT                                                               "
    cQuery += "                    GRP.F5M_KEY           F5M_KEY,                                "
    cQuery += "                    SUM(GRP.F5M_VALPAY)   OPBVALUE,                               "
    cQuery += "                    CAST('1' AS CHAR(1))  F5MCTRBAL                               "
    cQuery += "             FROM                                                                 "
    cQuery += "                  ( SELECT                                                        "
    cQuery += "                           TRIM(SUBSTRING(F5M_KEY,1,"+cF5MLen+")) F5M_KEY,        "
    cQuery += "                                                                  F5M_VALPAY      "
    cQuery += "                    FROM " + RetSQLName("F5M") + "                                "
    cQuery += "                    WHERE  F5M_CTRBAL = '1'                                       "
    cQuery += "                      AND D_E_L_E_T_ = ' ') GRP                                   "
    cQuery += "                    GROUP BY F5M_KEY)                             OPB             "
    cQuery += "            ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("OPB") + ")                "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    For nX := 1 To Len(aVrtFields)
        If !(aVrtFields[nX][4] == "C" .OR. aVrtFields[nX][4] == "M")
            TCSetField(cAlias,aVrtFields[nX][3],aVrtFields[nX][4],aVrtFields[nX][5],aVrtFields[nX][6])
        EndIf
    Next nX
    For nX := 1 To Len(aF5MFields)
        If !(aF5MFields[nX][4] == "C" .OR. aF5MFields[nX][4] == "M")
            TCSetField(cAlias,aF5MFields[nX][3],aF5MFields[nX][4],aF5MFields[nX][5],aF5MFields[nX][6])
        EndIf
    Next nX

Return (cAlias) /*----------------------------------------------------RU06XFUN33_RetPOLinesByKey*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN30_RetVrtLnsForOutBS

Function returns alias to query result for creating
lines for Outflow bank statement virtual grid

@param       Character        cF4C_CUUID  //F4C_CUUID 32 character UID
             Character        cF49PayOrd  //F49_PAYORD value
             Character        cF49IDF49   //F49_IDF49 32sym UID
             Date             dDtTran     //F4C->F4C_DTTRAN
             Character        cCurren     //F4C->F4C_CURREN
@Edit       aVelmozhya
@param      Logical           lInflow     //F4C_OPER Bank Statment Direction
@return      Character        cAlias      //Alias to query result, if no result will be ""   
@example     
@author      astepanov
@since       July/16/2019
@version     1.2
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN30_RetVrtLnsForOutBS(cF4C_CUUID, cF49PayOrd, cF49IDF49, lReplace,;
                                      dDtTran   , cCurren   , lInflow             )

    Local   cVlPT   , cVlPD   , cExRT   , cExRD  , cVT              As Character
    Local   cVD     , cVC    , cCD     , cAQ     , cAT              As Character
    Local   cE2ST   , cE2SD  , cE2IT   , cE2ID   , cBImT  , cBImD   As Character
    Local   cVCnT   , CVCnD  , cBCnT   , cBcnD   , cVVnT  , cVVnD   As Character
    Local   cQuery  , cAlias , cLFILIA                              As Character
    Local   cF5MLen , cQRQSt , cQRQLn  , cF4CAlias , cSE2Alias      As Character
    Local   cRtOT   , cRtOD  , cV5OT                                As Character
    Local   cPr     , cTab                                          As Character
    Local   lExistPO   As Logical

    Default cF4C_CUUID := ""
    Default cF49PayOrd := ""
    Default cF49IDF49  := ""
    Default lReplace   := .F.
    Default lInflow    := .F.
    cAlias     := ""

    cPr        := IIF(lInflow, "SE1.E1_", "SE2.E2_")
    cTab       := IIF(lInflow, "SE1", "SE2")
    cF4C_CUUID := PADR(cF4C_CUUID,GetSX3Cache("F4C_CUUID" ,"X3_TAMANHO"), " ")
    cF49PayOrd := PADR(cF49PayOrd,GetSX3Cache("F4C_PAYORD","X3_TAMANHO"), " ")
    cF49IDF49  := PADR(cF49IDF49 ,GetSX3Cache("F4C_IDF49" ,"X3_TAMANHO"), " ")
    lExistPO   := IIF(!Empty(cF49PayOrd) .AND. !Empty(cF49IDF49), .T., .F.)
    cLFILIA := cValToChar(GetSX3Cache("F5M_FILIAL","X3_TAMANHO"))
    cVlPT   := cValToChar(GetSX3Cache("F5M_VALPAY","X3_TAMANHO"))
    cVlPD   := cValToChar(GetSX3Cache("F5M_VALPAY","X3_DECIMAL"))
    cExRT   := cValToChar(GetSX3Cache("F5M_EXGRAT","X3_TAMANHO"))
    cExRD   := cValToChar(GetSX3Cache("F5M_EXGRAT","X3_DECIMAL"))
    cVT     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR")  ,"X3_TAMANHO"))
    cVD     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR")  ,"X3_DECIMAL"))
    cVC     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VLCRUZ","E2_VLCRUZ") ,"X3_TAMANHO"))
    cCD     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VLCRUZ","E2_VLCRUZ") ,"X3_DECIMAL"))
    cAQ     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_ALQIMP1","E2_ALQIMP1"),"X3_TAMANHO"))
    cAT     := cValToChar(GetSX3Cache(Iif(lInflow,"E1_ALQIMP1","E2_ALQIMP1"),"X3_DECIMAL"))
    cE2ST   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_SALDO","E2_SALDO")  ,"X3_TAMANHO"))
    cE2SD   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_SALDO","E2_SALDO")  ,"X3_DECIMAL"))
    cE2IT   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALIMP1","E2_VALIMP1"),"X3_TAMANHO"))
    cE2ID   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_VALIMP1","E2_VALIMP1"),"X3_DECIMAL"))
    cBImT   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_BASIMP1","E2_BASIMP1"),"X3_TAMANHO"))
    cBImD   := cValToChar(GetSX3Cache(Iif(lInflow,"E1_BASIMP1","E2_BASIMP1"),"X3_DECIMAL"))
    cVCnT   := cValToChar(GetSX3Cache("F5M_VALCNV","X3_TAMANHO"))
    CVCnD   := cValToChar(GetSX3Cache("F5M_VALCNV","X3_DECIMAL"))
    cBCnT   := cValToChar(GetSX3Cache("F5M_BSVATC","X3_TAMANHO"))
    cBcnD   := cValToChar(GetSX3Cache("F5M_BSVATC","X3_DECIMAL"))
    cVVnT   := cValToChar(GetSX3Cache("F5M_VLVATC","X3_TAMANHO"))
    cVVnD   := cValToChar(GetSX3Cache("F5M_VLVATC","X3_DECIMAL"))
    cF5MLen := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][2]
    cQRQSt  := cValToChar(Val(cF5MLen) + 2)
    cQRQLn  := cValToChar(GetSX3Cache("F4A_CODREQ","X3_TAMANHO"))
    cF4CAlias := PADR("F4C", GetSX3Cache("F5M_ALIAS" ,"X3_TAMANHO"), " ")
    cSE2Alias := PADR(Iif(lInflow,"SE1","SE2"), GetSX3Cache("F5M_KEYALI","X3_TAMANHO"), " ")
    //
    cRtOT   := cValToChar(GetSX3Cache("F5M_RTORIG","X3_TAMANHO"))
    cRtOD   := cValToChar(GetSX3Cache("F5M_RTORIG","X3_DECIMAL"))
    cV5OT   := cValToChar(GetSX3Cache("F5M_VLORIG","X3_TAMANHO"))
    cV5OD   := cValToChar(GetSX3Cache("F5M_VLORIG","X3_DECIMAL"))
    If !Empty(cF4C_CUUID)
        cQuery := " SELECT                                                                 "
        //-----------------------------------------------------------------------[-FIELDS-]-
        cQuery += " F5M.F5M_RATUSR                                                B_CHECK ,"
        cQuery += " F5M.F5M_RATUSR                                                B_RATUSR,"
        cQuery += " F5M.F5M_RATUSR                                              F5M_RATUSR,"
        cQuery += " F5M.F5M_KEY                                                   B_F5MKEY,"
        cQuery += " F5M.F5M_KEY                                                    F5M_KEY,"
        cQuery += " COALESCE("+cPr+"NATUREZ,'')                                   B_CLASS ,"
        cQuery += " COALESCE("+cPr+"EMISSAO,'')                                   B_EMISS ,"
        cQuery += " COALESCE("+cPr+"VENCREA,'')                                   B_REALMT,"
        cQuery += " F5M.F5M_VALPAY                                                B_VALPAY,"
        cQuery += " F5M.F5M_VALPAY                                              F5M_VALPAY,"
        cQuery += " F5M.F5M_EXGRAT                                                B_EXGRAT,"
        cQuery += " F5M.F5M_EXGRAT                                              F5M_EXGRAT,"
        cQuery += " F5M.F5M_VALCNV                                                B_VALCNV,"
        cQuery += " F5M.F5M_VALCNV                                              F5M_VALCNV,"
        cQuery += " F5M.F5M_BSVATC                                                B_BSVATC,"
        cQuery += " F5M.F5M_BSVATC                                              F5M_BSVATC,"
        cQuery += " F5M.F5M_VLVATC                                                B_VLVATC,"
        cQuery += " F5M.F5M_VLVATC                                              F5M_VLVATC,"
        cQuery += " F5M.F5M_RTORIG                                              F5M_RTORIG,"
        cQuery += " F5M.F5M_VLORIG                                              F5M_VLORIG,"
        cQuery += " F5M.F5M_ALIAS                                               F5M_ALIAS ,"
        cQuery += " F5M.F5M_KEYALI                                              F5M_KEYALI,"
        cQuery += " COALESCE("+cPr+"VALOR,0)                                      B_VALUE ,"
        cQuery += " COALESCE("+cPr+"MOEDA,1)                                      B_CURREN,"
        cQuery += " COALESCE("+cPr+"CONUNI,'2')                                   B_CONUNI,"
        cQuery += " COALESCE("+cPr+"ALQIMP1,0)                                    B_ALIMP1,"
        cQuery += " COALESCE(F5Q.F5Q_CODE, ' ')                                   B_MDCNTR,"
        If lExistPO // define B_BRANCH, B_IDF4A in case PO existance
            cQuery += " CASE WHEN COALESCE(F4A.F4A_FILIAL,' ') = ' '                       "
            cQuery += "      THEN F5M.F5M_FILIAL                                           "
            cQuery += "      ELSE F4A.F4A_FILIAL                                           "
            cQuery += " END                                                       B_BRANCH,"
        Else        // so, we have no payment order
            cQuery += " F5M.F5M_FILIAL                                            B_BRANCH,"
        EndIf
        // Calculate B_OPBAL
        cQuery += " CASE WHEN F5M.F5M_CTRBAL = '1'                                         "
        cQuery += " THEN                                                                   "
        cQuery += " ( COALESCE("+cPr+"SALDO, 0)   -                                        "
        cQuery += "   COALESCE(OPB.OPBVALUE, 0)   +                                        "
        cQuery += "   F5M.F5M_VALPAY                                                       "
        cQuery += " )                                                                      "
        cQuery += " ELSE                                                                   "
        cQuery += " ( COALESCE("+cPr+"SALDO, 0)   -                                        "
        cQuery += "   COALESCE(OPB.OPBVALUE, 0)                                            "
        cQuery += " )                                                                      "
        cQuery += " END                                                           B_OPBAL, "
        // B_VLCRUZ
        cQuery += " COALESCE("+cPr+"VLCRUZ,0)                                     B_VLCRUZ,"
        // B_VLIMP1
        cQuery += " COALESCE("+cPr+"VALIMP1,0)                                    B_VLIMP1,"
        // B_BSIMP1
        cQuery += " COALESCE("+cPr+"BASIMP1,0)                                    B_BSIMP1 "
        //-----------------------------------------------------------------------[-FROM---]-
        cQuery += " FROM                                                                   "
        cQuery += "        (SELECT * FROM " + RetSQLName("F4C") + "                        "
        cQuery += "                  WHERE F4C_FILIAL =  '" + xFilial("F4C") + "'          "
        cQuery += "                    AND F4C_CUUID  =  '" +   cF4C_CUUID   + "'          "
        cQuery += "                    AND D_E_L_E_T_ =  ' '                     ) F4C     "
        If !lReplace
            cQuery += " INNER JOIN            " + RetSQLName("F5M") + "                F5M "
            cQuery += "                  ON (  F5M.F5M_FILIAL  = F4C.F4C_FILIAL            "
            cQuery += "                    AND F5M.F5M_IDDOC   = F4C.F4C_CUUID             "
            cQuery += "                    AND F5M.D_E_L_E_T_  = ' '                 )     "
        Else
            cQuery += " INNER JOIN            " + RetSQLName("F5M") + "                F5M "
            cQuery += "                  ON (  F5M.F5M_FILIAL  = F4C.F4C_FILIAL            "
            cQuery += "                    AND F5M.F5M_IDDOC   = F4C.F4C_CUUID             "
            cQuery += "                    AND SUBSTRING(F5M.F5M_KEY," + " "
            cQuery +=                          cValToChar(Val(cLFILIA)+1) + ",1) = '|'     "
            cQuery += "                    AND F5M.F5M_ALIAS   = '" +cF4CAlias+ "'         "
            cQuery += "                    AND F5M.F5M_KEYALI  = '" +cSE2Alias+ "'         " 
            cQuery += "                    AND F5M.D_E_L_E_T_  = ' '                 )     "  
        EndIf
        cQuery += " LEFT JOIN             " + RetSQLName(cTab) + "           " + cTab + "  "
        cQuery += "                  ON ( " + RU06XFUN09_RetSE2F5MJoinOnString(,lInflow) +""
        cQuery += "                    AND "+cTab+".D_E_L_E_T_ = ' '                  )    "
        cQuery += " LEFT JOIN                                                              "
        cQuery += "           ( SELECT                                                     "
        cQuery += "                    GRP.F5M_KEY           F5M_KEY,                      "
        cQuery += "                    SUM(GRP.F5M_VALPAY)   OPBVALUE                      "
        cQuery += "             FROM                                                       "
        cQuery += "                  ( SELECT                                              "
        cQuery += "                         TRIM(SUBSTRING(F5M_KEY,1,"+cF5MLen+")) F5M_KEY,"
        cQuery += "                                                             F5M_VALPAY "
        cQuery += "                    FROM " + RetSQLName("F5M") + "                      "
        cQuery += "                    WHERE  F5M_CTRBAL = '1'                             "
        cQuery += "                      AND D_E_L_E_T_ = ' ') GRP                         "
        cQuery += "                    GROUP BY F5M_KEY)                           OPB     "
        cQuery += "            ON ( "+ RU06XFUN09_RetSE2F5MJoinOnString("OPB",lInflow)+" ) "
        cQuery += " LEFT JOIN             " + RetSQLName("F5Q") + "                F5Q     "
        cQuery += "                  ON (  F5Q.F5Q_FILIAL = "+cPr+"FILIAL                  "
        cQuery += "                    AND F5Q.F5Q_UID    = "+cPr+"F5QUID                  "
        cQuery += "                    AND F5Q.D_E_L_E_T_ = ' '                  )         "
        If lExistPO
            //-Join Payment order and its details-------------------------------------------
            cQuery += " INNER JOIN " + RetSQLName("F49") + "                       F49     "
            cQuery += "           ON ( F49.F49_FILIAL = F4C.F4C_FILIAL                     "
            cQuery += "           AND  F49.F49_PAYORD = F4C.F4C_PAYORD                     "
            cQuery += "           AND  F49.F49_IDF49  = F4C.F4C_IDF49                      "
            cQuery += "           AND  F49.D_E_L_E_T_ = ' '            )                   "
            cQuery += " LEFT  JOIN                                                         "
            cQuery += "           (         SELECT                                         "
            cQuery += "                            F4A_IDF49 ,                             "
            cQuery += "                            F4A_FILIAL,                             "
            cQuery += "                            F4A_IDF4A ,                             "
            cQuery += "                            F4A_CODREQ                              "
            cQuery += "                     FROM " + RetSQLName("F4A") +  "                "
            cQuery += "                     WHERE  F4A_FILIAL = '" + xFilial("F4A") + "'   "
            cQuery += "                       AND  F4A_IDF49  = '" +    cF49IDF49   + "'   "
            cQuery += "                       AND  D_E_L_E_T_ = ' '                        " 
            cQuery += "                     GROUP BY F4A_IDF49 , F4A_FILIAL, F4A_IDF4A,    "
            cQuery += "                              F4A_CODREQ                 )     F4A  " 
            cQuery += "           ON   (F4A.F4A_FILIAL = F49.F49_FILIAL                    " 
            cQuery += "           AND   F4A.F4A_IDF49  = F49.F49_IDF49                     "
            cQuery += "           AND   TRIM(F4A.F4A_CODREQ) =                             "
            cQuery += "                 TRIM(SUBSTRING(F5M.F5M_KEY,                        "
            cQuery += "                        "+cQRQSt+","+cQRQLn+"))  )                  "
        EndIf
        cQuery := ChangeQuery(cQuery)
        cAlias := CriaTrab(Nil, .F.)
        dbUseArea( .T., 'TOPCONN', TCGenQry( , , cQuery ), cAlias, .F., .T. )

        //TCSetField( < cAlias >, < cField >, < cType >, [ nSize ], [ nPrecision ] )
        //If a value other than "D", "L" and "N" is passed in cType , the command will 
        //be ignored and a warning message will be displayed in the Application Server 
        //console log: " TCSetField with type different from 'D', ' L 'and' N '- 
        //statement ignored. ".
        
        //Use PADR or AllTrim function when process result of query
        //because using CAST function prohibited

        TCSetField( cAlias, "B_VALPAY"  , "N", Val(cVlPT), Val(cVlPD) )
        TCSetField( cAlias, "F5M_VALPAY", "N", Val(cVlPT), Val(cVlPD) )
        TCSetField( cAlias, "B_EXGRAT"  , "N", Val(cExRT), Val(cExRD) )
        TCSetField( cAlias, "F5M_EXGRAT", "N", Val(cExRT), Val(cExRD) )
        TCSetField( cAlias, "B_VALCNV"  , "N", Val(cVCnT), Val(CVCnD) )
        TCSetField( cAlias, "F5M_VALCNV", "N", Val(cVCnT), Val(CVCnD) )
        TCSetField( cAlias, "B_BSVATC"  , "N", Val(cBCnT), Val(cBcnD) )
        TCSetField( cAlias, "F5M_BSVATC", "N", Val(cBCnT), Val(cBcnD) )
        TCSetField( cAlias, "B_VLVATC"  , "N", Val(cVVnT), Val(cVVnD) )
        TCSetField( cAlias, "F5M_VLVATC", "N", Val(cVVnT), Val(cVVnD) )
        TCSetField( cAlias, "F5M_RTORIG", "N", Val(cRtOT), Val(cRtOD) )
        TCSetField( cAlias, "F5M_VLORIG", "N", Val(cV5OT), Val(cV5OD) )
        TCSetField( cAlias, "B_VALUE"   , "N", Val(cVT)  , Val(cVD)   )
        TCSetField( cAlias, "B_ALIMP1"  , "N", Val(cAQ)  , Val(cAT)   )
        TCSetField( cAlias, "B_OPBAL"   , "N", Val(cE2ST), Val(cE2SD) )
        TCSetField( cAlias, "B_VLCRUZ"  , "N", Val(cVC)  , Val(cCD)   )
        TCSetField( cAlias, "B_VLIMP1"  , "N", Val(cE2IT), Val(cE2ID) )
        TCSetField( cAlias, "B_BSIMP1"  , "N", Val(cBImT), Val(cBImD) )

    EndIf

Return (cAlias) /*--------------------------------------------RU06XFUN30_RetVrtLnsForOutBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN44_RetSE2FldsPosInFMKey

Function returns array with SE2 fields names which located in F5M_KEY, and 
position of each one and its length.
F5M_KEY consists from 7 or more strings delimited by '|'example:
E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA ... so on
Please, don't change fields order, it should be fixed.
aRet[8][4]  - Sum of [x][5] + 6 delimires
aRet[8][5]  - Sum of [x][5]

@return      Array         aRet
                [1]         [2]  [3] [4] [5]
@example     {{'E2_FILIAL' ,'1' ,'6', 1 , 6 }  [1]
              {'E2_PREFIXO','8' ,'3', 8 , 3 }  [2]
              {'E2_NUM'    ,'12','8', 12, 8 }  [3]
              {'E2_PARCELA','21','2', 21, 2 }  [4]
              {'E2_TIPO'   ,'24','3', 24, 3 }  [5]
              {'E2_FORNECE','28','6', 28, 6 }  [6]
              {'E2_LOJA'   ,'35','2', 35, 2 }  [7]
              {''          ,'36','30',36, 30}  [8]
             }
@author      astepanov
@since       July/17/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN44_RetSE2FldsPosInFMKey(lInflow as Logical)
    Local aRet       As Array
    Local cFl        As Character
    Local cFS        As Character
    Local cPr        As Character
    Local cPS        As Character
    Local cNm        As Character
    Local cNS        As Character
    Local cPl        As Character
    Local cRS        As Character
    Local cTp        As Character
    Local cTS        As Character
    Local cFr        As Character
    Local cCS        As Character
    Local cLS        As Character
    Local cLj        As Character
    Local nF5MKeyLen As Numeric
    Local nX         As Numeric

    Default lInflow := .F.

    aRet       := {}
    nF5MKeyLen := 0
    nX         := GetSX3Cache("E2_FILIAL" , "X3_TAMANHO")
    cFl        := cValToChar(nX)
    cFS        := "1"
    AADD(aRet,{Iif(lInflow, "E1_FILIAL","E2_FILIAL"),cFS,cFl,Val(cFS),Val(cFl)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_PREFIXO", "X3_TAMANHO")
    cPr        := cValToChar(nX)
    cPS        := cValToChar(nF5MKeyLen + 2)
    AADD(aRet,{Iif(lInflow,"E1_PREFIXO", "E2_PREFIXO"),cPS,cPr,Val(cPS),Val(cPr)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_NUM"    , "X3_TAMANHO")
    cNm        := cValToChar(nX)
    cNS        := cValToChar(nF5MKeyLen + 3)
    AADD(aRet,{Iif(lInflow,"E1_NUM","E2_NUM"),cNS,cNm,Val(cNS),Val(cNm)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_PARCELA", "X3_TAMANHO")
    cPl        := cValToChar(nX)
    cRS        := cValToChar(nF5MKeyLen + 4)
    AADD(aRet,{Iif(lInflow,"E1_PARCELA","E2_PARCELA"),cRS,cPl,Val(cRS),Val(cPl)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_TIPO"   , "X3_TAMANHO")
    cTp        := cValToChar(nX)
    cTS        := cValToChar(nF5MKeyLen + 5)
    AADD(aRet,{Iif(lInflow,"E1_TIPO","E2_TIPO" ),cTS,cTp,Val(cTS),Val(cTp)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_FORNECE", "X3_TAMANHO")
    cFr        := cValToChar(nX)
    cCS        := cValToChar(nF5MKeyLen + 6)
    AADD(aRet,{Iif(lInflow,"E1_CLIENTE","E2_FORNECE"),cCS,cFr,Val(cCs),Val(cFr)})
    nF5MKeyLen += nX
    nX         := GetSX3Cache("E2_LOJA"   , "X3_TAMANHO")
    cLj        := cValToChar(nX)
    cLS        := cValToChar(nF5MKeyLen + 7)
    AADD(aRet,{Iif(lInflow,"E1_LOJA","E2_LOJA"),cLS,cLj,Val(cLS),Val(cLj)})

    nF5MKeyLen += nX + 6 // 6 is count of delimiter chars -  |
    nX         := nF5MKeyLen - 6 
    AADD(aRet,{"",cValToChar(nF5MKeyLen),cValToChar(nX), nF5MKeyLen, nX})

Return (aRet) /*-------------------------------------------RU06XFUN44_RetSE2FldsPosInFMKey*/

//-----------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN45_RetF5MnVrtLnsFromAPs

Function recieves FWTemporarytable generated by RU06XFUN12_MBRW, cMark parameter used for
filter data by E2_OK field, dTrnDate date on which we will recieve exhange rates,
oModel - link to Header model, for example: oModelF4C

@param       Object           oTmp
             Character        cMark
             Date             dExRatDate// Date for exhange rate 
             Object           oModel    // link to Header model, for example: oModelF4C
             Character        cAPTip    // deafult "", but when we create new AP line from BS
                                        // it should be markered like "PA" for payment in advance
             Numeric          nPAval    // Payment in advance value, should be filled when
                                        // cAPTip is not empty
             Numeric          nPAVAT    // Payment in advance VAT value
@edit   Velmozhnya Alexandra
            Logical           lInflow   // Bank Statment Direction
@return      Array            aRet {oTmpRet, cErrMsg} oTmpRet - temporary table with result 
@example     
@author      astepanov
@since       July/22/2019
@version     1.1
@project     MA3
@see         None
//--------------------------------------------------------------------------------------------/*/
Function RU06XFUN45_RetF5MnVrtLnsFromAPs(oTmp, cMark, dExRatDate, oModel, cAPTip, nPAVal, nPAVAT, lInflow)

    Local cAlias       As Character
    Local cErrMsg      As Character
    Local cQuery       As Character
    Local cPr          As Character
    Local cAl          As Character
    Local cCnnd        As Character
    Local cForCli      As Character
    Local cGr          As Character
    Local nMoedaHdr    As Numeric
    Local nVATRAT      As Numeric
    Local nX           As Numeric
    Local aRet         As Array
    Local aArea        As Array
    Local aGrdFields   As Array
    Local aVrtFields   As Array
    Local aFields      As Array
    Local aSEFields    As Array
    Local oTmpRet      As Object
    Local oModelGrd    As Object
    Local oModelVrt    As Object

    Default cMark      := " "
    Default dExRatDate := dDataBase
    Default cAPTip     := ""
    Default nPAVal     := 0
    Default nPAVAT     := 0
    Default lInflow    := .F.

    cAlias    := ""
    cMark     := AllTrim(cMark)
    cErrMsg   := ""
    aArea     := GetArea()
    If     oModel:CID == "RU06D07_MHEAD"
        cGr       := "F5M"
        oModelGrd := oModel:GetModel():GetModel("RU06D07_MLNS" )
        oModelVrt := oModel:GetModel():GetModel("RU06D07_MVIRT")
        nVATRAT   := IIF(Empty(oModel:GetValue("F4C_VATRAT")),0,oModel:GetValue("F4C_VATRAT"))
        nMoedaHdr := IIf(Empty(oModel:GetValue("F4C_CURREN")),;
                        1,Val(oModel:GetValue("F4C_CURREN")) )
    ElseIf oModel:CID == "RU06D05_MF49"
        cGr       := "F4B"
        oModelGrd := oModel:GetModel():GetModel("RU06D05_MF4B" )
        oModelVrt := oModel:GetModel():GetModel("RU06D05_MVIRT")
        nVATRAT   := IIF(Empty(oModel:GetValue("F49_VATRAT")),0,oModel:GetValue("F49_VATRAT"))
        nMoedaHdr := IIf(Empty(oModel:GetValue("F49_CURREN")),;
                        1,Val(oModel:GetValue("F49_CURREN")) )
    EndIf
    If  lInflow
        cPr       := "E1_"
        cAl       := "SE1"
        cCnnd     := "E1CUDIGTL"
        cForCli   := "E1_CLIENTE"
    Else
        cPr       := "E2_"
        cAl       := "SE2"
        cCnnd     := "E2CUDIGTL"
        cForCli   := "E2_FORNECE"
    EndIf
    
    aGrdFields := ACLONE(oModelGrd:GetStruct():GetFields())
    aVrtFields := ACLONE(oModelVrt:GetStruct():GetFields())
    aFields    := {}
    For nX := 1 To Len(aGrdFields)
        AADD(aFields, {aGrdFields[nX][3],;
                       aGrdFields[nX][4],;
                       aGrdFields[nX][5],;
                       aGrdFields[nX][6]}) 
    Next nX
    For nX := 1 To Len(aVrtFields)
        AADD(aFields, {aVrtFields[nX][3],;
                       aVrtFields[nX][4],;
                       aVrtFields[nX][5],;
                       aVrtFields[nX][6]})
    Next nX
    AADD(aFields ,{"B_FORNECE", GetSx3Cache(cForCli,"X3_TIPO"   ),;
                                GetSx3Cache(cForCli,"X3_TAMANHO"),;
                                GetSx3Cache(cForCli,"X3_DECIMAL")})
    AADD(aFields ,{"B_LOJA"   , GetSx3Cache(cPr+"LOJA","X3_TIPO"   ),;
                                GetSx3Cache(cPr+"LOJA","X3_TAMANHO"),;
                                GetSx3Cache(cPr+"LOJA","X3_DECIMAL")})
    AADD(aFields ,{"B_F5QDES" , GetSx3Cache("F4C_F5QDES","X3_TIPO"   ),;
                                GetSx3Cache("F4C_F5QDES","X3_TAMANHO"),;
                                GetSx3Cache("F4C_F5QDES","X3_DECIMAL")})
    AADD(aFields ,{"B_UIDF5Q" , GetSx3Cache("F4C_UIDF5Q","X3_TIPO"   ),;
                                GetSx3Cache("F4C_UIDF5Q","X3_TAMANHO"),;
                                GetSx3Cache("F4C_UIDF5Q","X3_DECIMAL")})
    AADD(aFields ,{"BALANCE" ,  GetSx3Cache(cPr+"SALDO","X3_TIPO"   ),;
                                GetSx3Cache(cPr+"SALDO","X3_TAMANHO"),;
                                GetSx3Cache(cPr+"SALDO","X3_DECIMAL")})
    AADD(aFields ,{"VLVATCBF" , GetSx3Cache("F5M_VLVATC","X3_TIPO"   ),;
                                GetSx3Cache("F5M_VLVATC","X3_TAMANHO"),;
                                GetSx3Cache("F5M_VLVATC","X3_DECIMAL")})
    AADD(aFields ,{"VLVATPST" , GetSx3Cache("F5M_VLVATC","X3_TIPO"   ),;
                                GetSx3Cache("F5M_VLVATC","X3_TAMANHO"),;
                                GetSx3Cache("F5M_VLVATC","X3_DECIMAL")}) 
    aSEFields := {"VALOR", "VLCRUZ","VALIMP1","BASIMP1","ALQIMP1"}
    For nX := 1 To Len(aSEFields)
        AADD(aFields ,{aSEFields[nX],GetSx3Cache(cPr+aSEFields[nX],"X3_TIPO"   ),;
                                     GetSx3Cache(cPr+aSEFields[nX],"X3_TAMANHO"),;
                                     GetSx3Cache(cPr+aSEFields[nX],"X3_DECIMAL")})
    Next nX
    oTmpRet := FWTemporaryTable():New(CriaTrab(,.F.))                         
    oTmpRet:SetFields(aFields)
    oTmpRet:Create()
    cQuery := " INSERT INTO " + oTmpRet:GetRealName() + "      "
    cQuery += "( "+cGr+"_FILIAL ,                                                 "
    If cGr == "F5M"
        cQuery += "              F5M_CTRBAL     ,                                 "
    EndIf 
    cQuery += "                                  B_BRANCH       ,B_REALMT       , "
    cQuery += "  B_PREFIX       ,B_NUM          ,B_PARCEL       ,B_TYPE         , "
    cQuery += "  B_CLASS        ,B_EMISS        ,B_CURREN       ,B_CONUNI       , "
    cQuery += "  B_FORNECE      ,B_LOJA         ,B_MDCNTR       ,B_FLORIG       , "
    cQuery += "  B_F5QDES       ,B_UIDF5Q       ,BALANCE        ,VALOR          , "
    cQuery += "  VLCRUZ         ,VALIMP1        ,BASIMP1        ,ALQIMP1        , "
    cQuery += "  VLVATCBF       ,VLVATPST                                         "
    cQuery += ")                                                                  "
    cQuery += " SELECT                                                            "
    cQuery += " F5M_FILIAL      ,                                                 "
    If cGr == "F5M"
        cQuery += "              F5M_CTRBAL     ,                                 "
    EndIf  
    cQuery += "                                  F5M_FILIAL     ,"+cPr+"VENCREA , "
    cQuery += " "+cPr+"PREFIXO  ,"+cPr+"NUM     ,"+cPr+"PARCELA ,"+cPr+"TIPO    , "
    cQuery += " "+cPr+"NATUREZ  ,"+cPr+"EMISSAO ,"+cPr+"MOEDA   ,"+cCnnd+"      , "
    cQuery += " "+cForCli+"     ,"+cPr+"LOJA    ,F5Q_CODE       ,"+cPr+"FILIAL  , "
    cQuery += " F5Q_DESCR       ,"+cPr+"F5QUID  ,"+cPr+"BALANCE ,"+cPr+"VALOR   , "
    cQuery += " "+cPr+"VLCRUZ   ,"+cPr+"VALIMP1 ,"+cPr+"BASIMP1 ,"+cPr+"ALQIMP1 , "
    cQuery += " VLVATCBF        ,VLVATPST                                         "
    cQuery += " FROM " + oTmp:GetRealName() + "                                   "
    cQuery += " WHERE "+cPr+"OK = '" + cMark  + "'                                "
    If lInflow
        cQuery += " ORDER BY "+cPr+"VENCREA ASC, "+cPr+"BALANCE DESC              "
    EndIf  

    nStat := TCSqlExec(cQuery)
    If nStat >= 0
        DbSelectArea(oTmpRet:GetAlias())
        DBGoTop()
        While !Eof()
            nExgRat := xMoeda(1, (B_CURREN), nMoedaHdr, dExRatDate, GetSX3Cache(cGr+"_EXGRAT","X3_DECIMAL"))
            nExgCRZ := xMoeda(1, (B_CURREN), 1, dExRatDate, GetSX3Cache(cGr+"_EXGRAT","X3_DECIMAL"))
            nExgRat := IIF(nExgRat == 0, 1, nExgRat)
            nExgCRZ := IIF(nExgCRZ == 0, 1, nExgCRZ)
            
            RecLock(oTmpRet:GetAlias(),.F.)
            &(cGr+"_EXGRAT") := nExgRat
            (B_EXGRAT)       := &(cGr+"_EXGRAT")
            If AllTrim(cAPTip) $ "PA|RA"
                (B_VALPAY)   := Round(nPAVal/F5M_EXGRAT,aFields[ASCAN(aFields,{|x| x[1] = "B_VALPAY"})][4])
                (F5M_VALPAY) := (B_VALPAY)
                (B_VALUE)    := (B_VALPAY)
                (B_OPBAL)    := (B_VALPAY)
                (B_VLCRUZ)   := Round((nPAVal*nExgCRZ)/F5M_EXGRAT,aFields[ASCAN(aFields,{|x| x[1] = "B_VLCRUZ"})][4])
                (B_VLIMP1)   := Round(nPAVAT/F5M_EXGRAT,aFields[ASCAN(aFields,{|x| x[1] = "B_VLIMP1"})][4])
                (B_BSIMP1)   := (B_VALUE) - (B_VLIMP1)
                (F5M_VALCNV) := nPAVal
                (F5M_VLVATC) := nPAVAT
                (F5M_BSVATC) := (F5M_VALCNV) - (F5M_VLVATC)
                (B_VALCNV)   := (F5M_VALCNV)
                (B_VLVATC)   := (F5M_VLVATC)
                (B_BSVATC)   := (F5M_BSVATC)
                (B_ALIMP1)   := nVATRAT
            Else
                // for different ex rates for different dates 
                // we have currency diffearls. So, this part of calculations should be changed and
                // we need new one specification for this case
                (B_VALPAY)       := (BALANCE)
                &(cGr+"_VALPAY") := (B_VALPAY)
                (B_VALUE)        := (VALOR)
                (B_OPBAL)        := (BALANCE)
                (B_VLCRUZ)       := (VLCRUZ)
                &(cGr+"_VALCNV") := Round(B_VALPAY*&(cGr+"_EXGRAT"),aFields[ASCAN(aFields,{|x| x[1] = cGr+"_VALCNV"})][4])
                &(cGr+"_VLVATC") := Round(VALIMP1*&(cGr+"_EXGRAT"),aFields[ASCAN(aFields,{|x| x[1] = cGr+"_VLVATC"})][4]) - ;
                                (VLVATCBF) - (VLVATPST)
                &(cGr+"_BSVATC") := &(cGr+"_VALCNV") - &(cGr+"_VLVATC") 
                (B_VALCNV)   := &(cGr+"_VALCNV")
                (B_VLVATC)   := &(cGr+"_VLVATC")
                (B_BSVATC)   := &(cGr+"_BSVATC")
                (B_ALIMP1)   := (ALQIMP1)
                (B_VLIMP1)   := RU06XFUN82_Calc_VLIMP1((B_VALPAY), (VALIMP1), (B_VALUE), GetSX3Cache("E2_VALIMP1","X3_DECIMAL"))
                (B_BSIMP1)   := (B_VALPAY)-(B_VLIMP1)
            EndIf
            If     cGr == "F5M"
                (F5M_KEY)    := ""
                (F5M_ALIAS)  := ""
                (F5M_KEYALI) := cAl
                (F5M_IDDOC)  := ""
                (F5M_RTORIG) := 0
                (F5M_VLORIG) := 0
                (B_CHECK)    := .F.
                (B_CODREQ)   := ""
                (B_IDF4A)    := ""
            ElseIf cGr == "F4B"
                (B_CHECK)    := .F.
                &(cGr+"_CHECK")  := (B_CHECK)
                &(cGr+"_PREFIX") := (B_PREFIX)
                &(cGr+"_NUM")    := (B_NUM)
                &(cGr+"_PARCEL") := (B_PARCEL)
                &(cGr+"_TYPE")   := (B_TYPE)
                &(cGr+"_CLASS")  := (B_CLASS)
                &(cGr+"_EMISS")  := (B_EMISS)
                &(cGr+"_REALMT") := (B_REALMT)
                &(cGr+"_VALUE")  := (B_VALUE)
                &(cGr+"_CURREN") := (B_CURREN)
                &(cGr+"_CONUNI") := (B_CONUNI)
                &(cGr+"_VLCRUZ") := (B_VLCRUZ)
                &(cGr+"_OPBAL")  := (B_OPBAL)
                &(cGr+"_BSIMP1") := (B_BSIMP1)
                &(cGr+"_ALIMP1") := (B_ALIMP1)
                &(cGr+"_VLIMP1") := (B_VLIMP1)
                &(cGr+"_MDCNTR") := (B_MDCNTR)
                &(cGr+"_FLORIG") := (B_FLORIG)
                (B_CODREQ)   := ""
                &(cGr+"_CODREQ") := (B_CODREQ)
                // we generate IDF4A because unique key
                // for F4B is: F4B_FILIAL+F4B_IDF4A+F4B_PREFIX+F4B_NUM+F4B_PARCEL+F4B_TYPE
                // so this IDF4A will not relate to real payment request
                (B_IDF4A)      := FWUUIDV4()
                &(cGr+"_IDF4A") := (B_IDF4A)
            EndIf
            &(cGr+"_RATUSR") := "0"
            (B_RATUSR)       := &(cGr+"_RATUSR")
            MSUnlock()
            DBSkip()
        EndDo
    Else
        cErrMsg := "TCSqlError() "+TCSqlError()
    EndIf
    RestArea(aArea)
    aRet := {oTmpRet, cErrMsg}
Return (aRet) /*------------------------------------------------RU06XFUN45_RetF5MnVrtLnsFromAPs*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN46_CheckPO

Function for checking payment order existance by next fields F49_PAYORD and F49_IDF49

@param       Character        cF49_PAYORD
             Character        cF49_IDF49
@return      Logical          lRet
@example     
@author      astepanov
@since       July/23/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN46_CheckPO(cF49_PAYORD, cF49_IDF49)

    Local   lRet        As Logical
    Local   cQuery      As Character
    Local   cAlias      As Character
    Local   aArea       As Array
    Default cF49_PAYORD := ""
    Default cF49_IDF49  := "" 

    lRet := .F.
    cF49_PAYORD := PADR(cF49_PAYORD,GetSX3Cache("F49_PAYORD","X3_TAMANHO"), " ")
    cF49_IDF49  := PADR(cF49_IDF49 ,GetSX3Cache("F49_IDF49" ,"X3_TAMANHO"), " ")
    cQuery := " SELECT *                                                    "
    cQuery += " FROM " + RetSQLName("F49") + "  F49                         "
    cQuery += " WHERE                                                       "
    cQuery += "      F49.F49_FILIAL = '"   +  xFilial("F49") + "'           "
    cQuery += "  AND F49.F49_IDF49  = '"   +   cF49_IDF49    + "'           "
    cQuery += "  AND F49.F49_PAYORD = '"   +   cF49_PAYORD   + "'           "
    cQuery += "  AND F49.D_E_L_E_T_ = ' '                                   "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea  := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If !EoF()
        lRet := .T.
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
Return (lRet) /*--------------------------------------------------------RU06XFUN46_CheckPO*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN47_CreateTmpTab1

<Short description>

@param       <Parameter type> <Parameter name>
@return      Logical          lRet
@example     
@author      astepanov
@since       July/24/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN47_CreateTmpTab1(lInflow as Logical)

    Local aRet       As Array
    Local aFieldList As Array
    Local aFields    As Array
    Local cAlias     As Character
    Local oTempTable As Object
    Local nX         As Numeric
    Local nAddSE2KLn As Numeric

    Default lInflow := .F.
    aRet := {}

    cAlias     := CriaTrab(, .F.)
    oTempTable := FWTemporaryTable():New(cAlias)
    nAddSE2KLn := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][5]
    If lInflow
        aFieldList := {"E1_OK"     , "E1_FILIAL" , "E1_PREFIXO", "E1_NUM" ,;
                    "E1_PARCELA", "E1_TIPO"   , "E1_EMISSAO", "E1_VENCREA",;
                    "CTO_MOEDA" , "E1_CONUNI" , "E1_VALOR"  , "E1_BALANCE",;
                    "E1_CLIENTE", "E1_LOJA"   , "ADDSE1KEYC", "E1_MOEDA"  ,;
                    "E1_VALIMP1", "E1_NATUREZ", "E1_VLCRUZ" , "E1_ALQIMP1",;
                    "E1_F5QUID" , "F5Q_DESCR" , "F5M_CTRBAL", "F5Q_CODE"  ,;
                    "E1CUDIGTL" , "F5M_FILIAL", "VALCNVBF"  , "BSVATCBF"  ,;
                    "VLVATCBF"  , "E1_BASIMP1", "VLVATPST"                 }
    Else
        aFieldList := {"E2_OK"     , "E2_FILIAL" , "E2_PREFIXO", "E2_NUM" ,;
                    "E2_PARCELA", "E2_TIPO"   , "E2_EMISSAO", "E2_VENCREA",;
                    "CTO_MOEDA" , "E2_CONUNI" , "E2_VALOR"  , "E2_BALANCE",;
                    "E2_FORNECE", "E2_LOJA"   , "ADDSE2KEYC", "E2_MOEDA"  ,;
                    "E2_VALIMP1", "E2_NATUREZ", "E2_VLCRUZ" , "E2_ALQIMP1",;
                    "E2_F5QUID" , "F5Q_DESCR" , "F5M_CTRBAL", "F5Q_CODE"  ,;
                    "E2CUDIGTL" , "F5M_FILIAL", "VALCNVBF"  , "BSVATCBF"  ,;
                    "VLVATCBF"  , "E2_BASIMP1", "VLVATPST"                 }
    EndIf
    // aFields: {{"field name", "x3_tipo"   , "x3_tamanho", "x3_decimal",;
    //            "x3_picture", "RetTitle()"                            }}
    aFields := {}
    For nX  := 1 To Len(aFieldList)
        If     aFieldList[nX] $ "E1_OK|E2_OK"
            AADD(aFields, {aFieldList[nX], "C", 1, 00, "", ""       })
        ElseIf aFieldList[nX] $ "E1_CONUNI|E2_CONUNI"
            AADD(aFields, {aFieldList[nX], "C", 3, 00, "",;
                           RetTitle(Iif(lInflow,"E1_CONUNI","E2_CONUNI"))                    })
        ElseIf aFieldList[nX] $ "E1_BALANCE|E2_BALANCE"
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_TIPO"   ),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_TAMANHO"),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_DECIMAL"),;
                           GetSX3Cache(Iif(lInflow,"E1_VALOR","E2_VALOR" )     ,"X3_PICTURE"),;
                           STR0020                                  })
        ElseIf aFieldList[nX] $ "ADDSE1KEYC|ADDSE2KEYC"
            AADD(aFields, {aFieldList[nX],"C",nAddSE2KLn,00,"",""   })
        ElseIf aFieldList[nX] == "VALCNVBF"
             AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("F5M_VALCNV"   ,"X3_TIPO"   ),;
                           GetSX3Cache("F5M_VALCNV"   ,"X3_TAMANHO"),;
                           GetSX3Cache("F5M_VALCNV"   ,"X3_DECIMAL"),;
                           GetSX3Cache("F5M_VALCNV"   ,"X3_PICTURE"),;
                           RetTitle("F5M_VALCNV")                   })
        ElseIf aFieldList[nX] == "BSVATCBF"
             AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("F5M_BSVATC"   ,"X3_TIPO"   ),;
                           GetSX3Cache("F5M_BSVATC"   ,"X3_TAMANHO"),;
                           GetSX3Cache("F5M_BSVATC"   ,"X3_DECIMAL"),;
                           GetSX3Cache("F5M_BSVATC"   ,"X3_PICTURE"),;
                           RetTitle("F5M_BSVATC")                   })
        ElseIf aFieldList[nX] == "VLVATCBF" .OR.;
               aFieldList[nX] == "VLVATPST"
             AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("F5M_VLVATC"   ,"X3_TIPO"   ),;
                           GetSX3Cache("F5M_VLVATC"   ,"X3_TAMANHO"),;
                           GetSX3Cache("F5M_VLVATC"   ,"X3_DECIMAL"),;
                           GetSX3Cache("F5M_VLVATC"   ,"X3_PICTURE"),;
                           RetTitle("F5M_VLVATC")                   })
        ElseIf aFieldList[nX] $ "E1CUDIGTL|E2CUDIGTL"
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache("E2_CONUNI"    ,"X3_TIPO"   ),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_TAMANHO"),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_DECIMAL"),;
                           GetSX3Cache("E2_CONUNI"    ,"X3_PICTURE"),;
                           RetTitle("E2_CONUNI")                    })
        Else  
            AADD(aFields, {aFieldList[nX],;
                           GetSX3Cache(aFieldList[nX] ,"X3_TIPO"   ),;
                           GetSX3Cache(aFieldList[nX] ,"X3_TAMANHO"),;
                           GetSX3Cache(aFieldList[nX] ,"X3_DECIMAL"),;
                           GetSX3Cache(aFieldList[nX] ,"X3_PICTURE"),;
                           RetTitle(aFieldList[nX])                 })
        EndIf 
    Next nX
    oTempTable:SetFields(aFields)
    If lInflow
            oTempTable:AddIndex(cAlias+"1", {"E1_FILIAL", "E1_VENCREA"} )
            oTempTable:AddIndex(cAlias+"2", {"E1_FILIAL", "E1_PREFIXO",;
                                        "E1_NUM"   , "E1_PARCELA",;
                                        "E1_TIPO"}                 )
    Else
        oTempTable:AddIndex(cAlias+"1", {"E2_FILIAL", "E2_VENCREA"} )
        oTempTable:AddIndex(cAlias+"2", {"E2_FILIAL", "E2_PREFIXO",;
                                        "E2_NUM"   , "E2_PARCELA",;
                                        "E2_TIPO"}                 )
    EndIf
    oTempTable:Create()
    aRet := {oTempTable,aFields}

Return (aRet) /*--------------------------------------------------RU06XFUN47_CreateTmpTab1*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS

Returns alias to table with structure:
[AP_MOEDA]---[ERCNYS]-[ERCNNO]-[ERQVMD]-[CRUZMD]

@param       Array          aMoedas     // array with currencies like numerics
             Date           dExRatDate  // exchange rates on this date
@return      Object         oTmpMds     // temprary table with different exchange rates
                                        // for the list of currencies
@example     [AP_MOEDA]---[ERCNYS]-[ERCNNO]-[ERQVMD]-[CRUZMD]
                2          72.3645    1.36     1      72.3645   ... so on
@author      astepanov
@since       July/25/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS(aMoedas,;
                                                                  dExRatDate,nMoedaHdr)

    Local   oTmpMds    As Object
    Local   cTmpMds    As Character
    Local   nX         As Numeric
    Local   nCnt       As Numeric 
    Local   aFields    As Array
    Local   aArea      As Array
    Default aMoedas    := {}
    Default dExRatDate := dDataBase
    Default nMoedaHdr  := 1

    cTmpMds   := CriaTrab(, .F.)
    oTmpMds   := FWTemporaryTable():New(cTmpMds)
    aFields   := {}
    AADD(aFields, {"AP_MOEDA",;
                   GetSX3Cache("E2_MOEDA"  , "X3_TIPO"   ),;
                   GetSX3Cache("E2_MOEDA"  , "X3_TAMANHO"),;
                   GetSX3Cache("E2_MOEDA"  , "X3_DECIMAL") })
    AADD(aFields, {"ERCNYS",; // exgrat when conuni = yes
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"ERCNNO",; // exgrat when conuni  = no, 
                            ; // but currencies are different,
                            ; // crossrate 
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"ERQVMD",; // exgrat when moedas equals
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") })
    AADD(aFields, {"CRUZMD",; // exrate for calculating VALCRUZ
                   GetSX3Cache("F5M_EXGRAT", "X3_TIPO"   ),;
                   GetSX3Cache("F5M_EXGRAT", "X3_TAMANHO"),;
                   GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL") }) 
    oTmpMds:SetFields(aFields)
    oTmpMds:AddIndex(cTmpMds+"01",{"AP_MOEDA"})
    oTmpMds:Create()
    aArea := GetArea()
    If Empty(aMoedas)
        // add moedas
        AADD(aMoedas,1)
        nCnt := MoedFin()
        If nCnt > 1
            For nX := 2 To nCnt
                AADD(aMoedas,nX)
            Next nX
        EndIf
    EndIf
    DBSelectArea(cTmpMds)
    nRnd := GetSX3Cache("F5M_EXGRAT", "X3_DECIMAL")
    For nX := 1 To Len(aMoedas)
        RecLock((cTmpMds), .T.)
        (cTmpMds)->AP_MOEDA := aMoedas[nX]
        (cTmpMds)->ERCNYS   := IIf(RecMoeda(dExRatDate,aMoedas[nX]) == 0, 1,;
                                   RecMoeda(dExRatDate,aMoedas[nX])         )
        (cTmpMds)->ERCNNO   := IIf(xMoeda(1,aMoedas[nX],;
                                          nMoedaHdr    ,;
                                          dExRatDate   ,;
                                          nRnd          ) == 0, 1,;
                                   xMoeda(1,aMoedas[nX],;
                                          nMoedaHdr    ,;
                                          dExRatDate   ,;
                                          nRnd          )         )
        (cTmpMds)->ERQVMD   := 1
        (cTmpMds)->CRUZMD   := IIf(xMoeda(1,aMoedas[nX],;
                                          1            ,;
                                          dExRatDate   ,;
                                          nRnd          ) == 0, 1,;
                                   xMoeda(1,aMoedas[nX],;
                                          1            ,;
                                          dExRatDate   ,;
                                          nRnd          )         )
        (cTmpMds)->(MsUnlock())
    Next nX
    RestArea(aArea)
Return (oTmpMds) /*---------------RU06XFUN48_RetExchRatesTempTabForAddingNewF5MlineToOutBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN49_CheckF4CUUIDRE

Function called from RU06D0731_ViewFPost
If lRevers == .F.
We check existanse bankstatement with F4C_CUUID which equals F4C_UUIDRE
If lRevers == .T.
We check existanse bankstatement with F4C_UUIDRE which equals F4C_CUUID
If it exist .T.  - will be returned, if it is not exist .F. will be returned

If lData == .T. will be returned F4C_CUUID or ""

@param       Character        cKey //F4C_CUUID or F4C_UUIDRE
             Logical          LRevers
@return      Logical          lRet
@example     
@author      astepanov
@since       August/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN49_CheckF4CUUIDRE(cKey, lRevers, lData)

    Local lRet       As Logical
    Local cQuery     As Character
    Local cAlias     As Character
    Local cF4C_CUUID As Character
    Local aArea      As Array
    Local xRet

    Default lRevers  := .F.
    Default lData    := .F.

    lRet := .T.
    cKey := PADR(cKey ,GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), " ")
    cF4C_CUUID := ""
    cQuery := " SELECT                                  "
    cQuery += "        F4C_CUUID                        "
    cQuery += " FROM  "+RetSQLName("F4C")+"             "
    cQuery += " WHERE F4C_FILIAL = '"+xFilial("F4C")+"' "
    If lRevers
        cQuery += "   AND F4C_UUIDRE = '" +  cKey + "'  "
    Else
        cQuery += "   AND F4C_CUUID  = '" +  cKey + "'  "
    EndIf
    cQuery += "   AND D_E_L_E_T_ = ' '                  "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    aArea := GetArea()
    DBSelectArea(cAlias)
    DBGoTop()
    If Eof()
        lRet := .F.
    Else
        lRet := .T.
        cF4C_CUUID := PADR((cAlias)->F4C_CUUID,;
                      GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), " ")
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aArea)
    xRet := lRet
    If lData
        xRet := cF4C_CUUID
    EndIf

Return (xRet) /*------------------------------------------------RU06XFUN49_CheckF4CUUIDRE*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN50_RetVATSaldoValues
Function used for get VAT realted values for last part of AP added to BAnk statement
It works correct for equal currencies or when exhange rates are permanent,
but for case when we have change in exchange rates we should rewrite query below,
but it is part of the next specification.
@param       Object           oVrtModel,
             Object           oHdrModel,
@return      Array            aRet array with next values {B_VALCNV,B_VLVATC,B_BSVATC,B_VLCRUZ,
                                                           B_VLIMP1,B_BSIMP1                  }
@example     
@author      astepanov
@since       November/13/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------------/*/
Function RU06XFUN50_RetVATSaldoValues(oVrtModel,oHdrModel)

    Local   aRet      As Array
    Local   cFil      As Character
    Local   cPrefixo  As Character
    Local   cNum      As Character
    Local   cParcela  As Character
    Local   cTipo     As Character
    Local   cFornece  As Character
    Local   cLoja     As Character
    Local   cF5MKey   As Character
    Local   cF5MkLen  As Character
    Local   cBExgRat  As Character
    Local   cLVLCNV   As Character
    Local   cLE2VLIMP As Character
    Local   cLVLVATC  As Character
    Local   cAlias    As Character
    Local   cQuery    As Character
    Local   cF4CCUUID As Character
    Local   cLVLCRUZ  As Character
    Local   cLE2BIMD  As Character
    Local   cLE2SLDD  As Character
    Local   cLBSVATC  As Character
    Local   cPr       As Character
    Local   cE        As Character
    Local   cForCli   As Character
    Local   cTab      As Character
    Local   lInflow   As Logical
    Default nCruzRat := 1
    aRet     := {}

    lInflow   := (oHdrModel:GetValue("F4C_OPER") == "1")
    cFil      := PADR(oVrtModel:GetValue("B_FLORIG"),GetSX3Cache(IIf(lInflow,"E1_FILIAL" ,"E2_FILIAL") ,"X3_TAMANHO")," ")
	cPrefixo  := PADR(oVrtModel:GetValue("B_PREFIX"),GetSX3Cache(IIf(lInflow,"E1_PREFIXO","E2_PREFIXO"),"X3_TAMANHO")," ")
	cNum      := PADR(oVrtModel:GetValue("B_NUM"   ),GetSX3Cache(IIf(lInflow,"E1_NUM"    ,"E2_NUM")    ,"X3_TAMANHO")," ")
	cParcela  := PADR(oVrtModel:GetValue("B_PARCEL"),GetSX3Cache(IIf(lInflow,"E1_PARCELA","E2_PARCELA"),"X3_TAMANHO")," ")
	cTipo     := PADR(oVrtModel:GetValue("B_TYPE"  ),GetSX3Cache(IIf(lInflow,"E1_TIPO"   ,"E2_TIPO")   ,"X3_TAMANHO")," ")
	cFornece  := PADR(Iif(lInflow, oHdrModel:GetValue("F4C_CUST"),oHdrModel:GetValue("F4C_SUPP")),;
                      GetSX3Cache(IIf(lInflow,"E1_CLIENTE","E2_FORNECE"),"X3_TAMANHO")," "        )
	cLoja     := PADR(Iif(lInflow, oHdrModel:GetValue("F4C_CUNI"),oHdrModel:GetValue("F4C_UNIT")),;
                      GetSX3Cache(IIf(lInflow,"E1_LOJA","E2_LOJA")  ,"X3_TAMANHO")," "            )
    cF5MKey   := cFil+"|"+cPrefixo+"|"+cNum+"|"+cParcela+"|"+cTipo+"|"+cFornece+"|"+cLoja
    cF5MkLen  := cValToChar(Len(cF5MKey))
    cBExgRat  := cValToChar(oVrtModel:GetValue("B_EXGRAT"))
    cF4CCUUID := IIF(Empty(oHdrModel:GetValue("F4C_CUUID")),"",oHdrModel:GetValue("F4C_CUUID"))
    cLVLCNV   := cValToChar(GetSX3Cache("F5M_VALCNV", "X3_DECIMAL"))
    cLVLCRUZ  := cValToChar(GetSx3Cache(IIf(lInflow,"E1_VLCRUZ" ,"E2_VLCRUZ" ), "X3_DECIMAL"))
    cLE2VLIMP := cValToChar(GetSX3Cache(IIf(lInflow,"E1_VALIMP1","E2_VALIMP1"), "X3_DECIMAL"))
    cLVLVATC  := cValToChar(GetSX3Cache("F5M_VLVATC", "X3_DECIMAL"))
    cLBSVATC  := cValToChar(GetSX3Cache("F5M_BSVATC", "X3_DECIMAL"))
    cLE2BIMD  := cValToChar(GetSX3Cache(IIf(lInflow,"E1_BASIMP1","E2_BASIMP1"), "X3_DECIMAL"))
    cLE2SLDD  := cValToChar(GetSX3Cache(IIf(lInflow,"E1_SALDO"  ,"E2_SALDO"  ), "X3_DECIMAL"))
    cPr       := IIF(lInflow, "SE1.E1_", "SE2.E2_")
    cE        := IIF(lInflow, "E1_"    , "E2_")
    cForCli   := IIF(lInflow, "E1_CLIENTE", "E2_FORNECE")
    cTab      := IIF(lInflow, "SE1", "SE2")
    cQuery := " SELECT                                                                           "
    //for different ex rates this part of query should be rewrited
    cQuery += " ROUND(("+cPr+"SALDO -                                                            "
    cQuery += "        COALESCE(TMP.VALUEBEF,0)) * "+cBExgRat+" ,"+cLVLCNV+")         B_VALCNV  ,"
    cQuery += " ROUND(("+cPr+"VALIMP1 * "+cBExgRat+" )                                           "
    cQuery += "        ,"+cLVLVATC+")  - ROUND(COALESCE(TMP.VLVATCBF,0),"+cLVLVATC+")            "
    cQuery += "                        - ROUND(COALESCE(PST.VLVATPST,0),"+cLVLVATC+") B_VLVATC  ,"
    cQuery += " ROUND(                                                                           "
    cQuery += " ROUND(("+cPr+"SALDO -                                                            "
    cQuery += "        COALESCE(TMP.VALUEBEF,0)) * "+cBExgRat+" ,"+cLVLCNV+") -                  "
    cQuery += " (ROUND(("+cPr+"VALIMP1 * "+cBExgRat+" )                                          "
    cQuery += "        ,"+cLVLVATC+")  - ROUND(COALESCE(TMP.VLVATCBF,0),"+cLVLVATC+")            "
    cQuery += "                        - ROUND(COALESCE(PST.VLVATPST,0),"+cLVLVATC+")            "
    cQuery += " )                                                                                "
    cQuery += "      , "+cLBSVATC+")                                                  B_BSVATC  ,"
    //^^^^^^^
    //B_VLCRUZ
    cQuery += " ROUND("+cPr+"VLCRUZ, "+cLVLCRUZ+" )                                   B_VLCRUZ  ,"
    //B_VLIMP1
    cQuery += " ROUND("+cPr+"VALIMP1,"+cLE2VLIMP+")                                   B_VLIMP1  ,"
    //B_BSIMP1
    cQuery += " ROUND("+cPr+"BASIMP1,"+cLE2BIMD +")                                   B_BSIMP1   "
    cQuery += " FROM                                                                             "
    cQuery += "       (SELECT "+cE+"SALDO  ,                                                     "
    cQuery += "               "+cE+"VALIMP1,                                                     "
    cQuery += "               "+cE+"BASIMP1,                                                     "
    cQuery += "               "+cE+"VLCRUZ ,                                                     "
    cQuery += "               "+cE+"FILIAL, "+cE+"PREFIXO, "+cE+"NUM, "+cE+"PARCELA, "+cE+"TIPO, "
    cQuery += "               "+cForCli+",  "+cE+"LOJA                                           "
    cQuery += "        FROM  " + RetSQLName(cTab)   +"                                           "
    cQuery += "        WHERE "+cE+"FILIAL  = '"+cFil    +"'                                      "
    cQuery += "          AND "+cE+"PREFIXO = '"+cPrefixo+"'                                      "
    cQuery += "          AND "+cE+"NUM     = '"+cNum    +"'                                      "
    cQuery += "          AND "+cE+"PARCELA = '"+cParcela+"'                                      "
    cQuery += "          AND "+cE+"TIPO    = '"+cTipo   +"'                                      "
    cQuery += "          AND "+cForCli+"   = '"+cFornece+"'                                      "
    cQuery += "          AND "+cE+"LOJA    = '"+cLoja   +"'                                      "
    cQuery += "          AND D_E_L_E_T_ = ' ' )                              "+cTab+"            "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "       ( SELECT                                                                   "
    cQuery += "                GRP.F5M_KEY           F5M_KEY,                                    "
    cQuery += "                SUM(GRP.F5M_VALPAY)   VALUEBEF,                                   "
    cQuery += "                SUM(GRP.F5M_VALCNV)   VALCNVBF,                                   "
    cQuery += "                SUM(GRP.F5M_BSVATC)   BSVATCBF,                                   "
    cQuery += "                SUM(GRP.F5M_VLVATC)   VLVATCBF                                    "
    cQuery += "         FROM                                                                     "
    cQuery += "              ( SELECT                                                            "
    cQuery += "                       CAST(F5M_KEY AS CHAR("+cF5MkLen+")) F5M_KEY,               "
    cQuery += "                                                       F5M_VALPAY,                "
    cQuery += "                                                       F5M_VALCNV,                "
    cQuery += "                                                       F5M_BSVATC,                "
    cQuery += "                                                       F5M_VLVATC                 "
    cQuery += "                FROM " + RetSQLName("F5M") + "                                    "
    cQuery += "                WHERE F5M_CTRBAL = '1'                                            "
    cQuery += "                AND TRIM(SUBSTRING(F5M_KEY,"+"1"+","+cF5MkLen+")) = '"+cF5MKey+"' "
    cQuery += "                AND F5M_IDDOC <> '"+cF4CCUUID+"'                                  "
    cQuery += "                AND D_E_L_E_T_ = ' ') GRP                                         "
    cQuery += "                GROUP BY GRP.F5M_KEY)                         TMP                 "
    cQuery += "        ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("TMP",lInflow) + ")            "
    cQuery += " LEFT JOIN                                                                        "
    cQuery += "       ( SELECT                                                                   "
    cQuery += "                GRP.F5M_KEY           F5M_KEY,                                    "
    cQuery += "                SUM(GRP.F5M_VLVATC)   VLVATPST                                    "
    cQuery += "         FROM                                                                     "
    cQuery += "              ( SELECT                                                            "
    cQuery += "                       CAST(F5M_KEY AS CHAR("+cF5MkLen+")) F5M_KEY,               "
    cQuery += "                                                       F5M_VLVATC,                "
    cQuery += "                                                       F5M_IDDOC                  "
    cQuery += "                FROM " + RetSQLName("F5M") + "                                    "
    cQuery += "                WHERE F5M_CTRBAL = '2'                                            "
    cQuery += "                AND TRIM(SUBSTRING(F5M_KEY,"+"1"+","+cF5MkLen+")) = '"+cF5MKey+"' "
    cQuery += "                AND F5M_ALIAS  = 'F4C'                                            "
    cQuery += "                AND D_E_L_E_T_ = ' '                                              "
    cQuery += "                                    ) GRP                                         "
    cQuery += "         INNER JOIN                                                               "
    cQuery += "              ( SELECT *                                                          "
    cQuery += "                FROM " + RetSqlName("F4C") + "                                    "
    cQuery += "                WHERE F4C_FILIAL = '"+xFilial("F4C")+"'                           "
    cQuery += "                AND (F4C_STATUS = '2' OR F4C_STATUS = '5')                        "
    cQuery += "                AND D_E_L_E_T_ = ' '                                              " 
    cQuery += "                                    ) F4C                                         "
    cQuery += "              ON (F4C.F4C_CUUID = GRP.F5M_IDDOC)                                  "                 
    cQuery += "         GROUP BY GRP.F5M_KEY)                                PST                 "
    cQuery += "        ON ( "  + RU06XFUN09_RetSE2F5MJoinOnString("PST",lInflow) + ")            "
    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    //shuld be returnd 1 line, if no - it is error in data
    While !EoF()
        AADD(aRet,(cAlias)->B_VALCNV)
        AADD(aRet,(cAlias)->B_VLVATC)
        AADD(aRet,(cAlias)->B_BSVATC)
        AADD(aRet,(cAlias)->B_VLCRUZ)
        AADD(aRet,(cAlias)->B_VLIMP1)
        AADD(aRet,(cAlias)->B_BSIMP1)
        DBSkip()
    EndDo
    (cAlias)->(DBCloseArea())
    RestArea(aArea)

Return (aRet) /*----------------------------------------------------RU06XFUN50_RetVATSaldoValues*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN51_RecieveSE2F5MLines

Function recieves query to SE2 table as character. It gets SE2 lines, locks them and puts
result to the temporary table, also recieves F5M lines related to SE2 lines, lock them and
puts to the temporary table.
After data recieving SE2 and F5M lines will be unlocked.
So, it returns SE2 temporary table(with applied filter), F5M temporary table as result of
the joining to SE2 records.
This function needed if want to calculate correct difference between E2_SALDO and F5M_VALPAY
and so on.
If one line in SE2 or F5M is locked for writing in returning result (array) we will see 
aRet[6] == .F., so we should run query again when lines will be unlocked.
If nStat < 0 aRet[4] < 0, we have trouble in SQL query, details will be explained in aRet[4]
aRet[1] - Alias to temporary SE2 table, aRet[2] - Alias to temporary F5M table where
F5M_CTRBAL == "1", aRet[3] - alias to temporary F5M table where F5M_CTRBAL == "2"

@param       Character         cQrSE2  // query to SE2 table
@return      Array             aRet   // {temp table to SE2, temp tab to F5M where
                                          CTRBAL == "1", temp tab to F5M where CTRBAL =="2",
                                          result of SQL query execution should be >= 0,
                                          error message, in normal case should be "",
                                          result of records locking, in normal case 
                                          should be .T., if we have trouble with locking
                                          one of the selected record .F. will be returned}
@example     
@author      astepanov
@since       November/15/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN51_RecieveSE2F5MLines(cQrSE2, lInflow)

    Local aRet       As Array
    Local aSE2Fields As Array
    Local aF5MFields As Array
    Local aF5MFldsAd As Array
    Local aLockSE2   As Array
    Local aLockF5M   As Array
    Local aArea      As Array
    Local aAreaSE2   As Array
    Local aAreaF5M   As Array
    Local aTmpTabs   As Array
    Local cTmpTabSE2 As Character
    Local cTmpTabF5M As Character
    Local cTmpTabTP1 As Character
    Local cSE2Fields As Character
    Local cF5MFields As Character
    Local cF5MFldsAd As Character
    Local cF5MLen    As Character
    Local cQuery     As Character
    Local cQuery2    As Character
    Local cErrMsg    As Character
    Local cSE2TMPAls As Character
    Local cF5MTMPAls As Character
    Local cTpTF5MRet As Character
    Local cTpTSE2Ret As Character
    Local cTpTTP1Ret As Character
    Local cSE2Nm     As Character
    Local cQtSE2     As Character
    Local oTmpTabSE2 As Object
    Local oTpTSE2Ret As Object
    Local oTmpTabF5M As Object
    Local oTpTF5MRet As Object
    Local oTmpTabTP1 As Object
    Local oTpTTP1Ret As Object
    Local nX         As Numeric
    Local nY         As Numeric
    Local nStat      As Numeric
    Local nLnLckSE2  As Numeric
    Local nLnLckF5M  As Numeric
    Local nSE2Nl     As Numeric
    Local nSE2Ps     As Numeric
    Local lLock      As Logical

    Default lInflow := .F.

    // get SE2 fields and form temporary table for Se2
    cTmpTabSE2 := CriaTrab(, .F.)
    oTmpTabSE2 := FWTemporaryTable():New(cTmpTabSE2)
    aSE2Fields := IIf(lInflow, SE1->(DBStruct()),SE2->(DBStruct()))
    oTmpTabSE2:SetFields(aSE2Fields)
    If lInflow
        oTmpTabSE2:AddIndex(cTmpTabSE2+"1",;
            {"E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA"})
    Else
        oTmpTabSE2:AddIndex(cTmpTabSE2+"1",;
            {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
    EndIf
    oTmpTabSE2:Create()
    cTpTSE2Ret := CriaTrab(, .F.)
    oTpTSE2Ret := FWTemporaryTable():New(cTpTSE2Ret)
    oTpTSE2Ret:SetFields(aSE2Fields)
    If lInflow
        oTpTSE2Ret:AddIndex(cTpTSE2Ret+"1",;
            {"E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA"})
    Else
        oTpTSE2Ret:AddIndex(cTpTSE2Ret+"1",;
            {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
    EndIf
    oTpTSE2Ret:Create()
    cSE2Fields := " "
    For nX := 1 To Len(aSE2Fields)
        cSE2Fields += aSE2Fields[nX][1] + ", "
    Next nX
    cSE2Fields := SubStr(cSE2Fields,1,Len(cSE2Fields)-2)
    //get F5M fields and form temporary table for F5M
    cTmpTabF5M := CriaTrab(, .F.)
    oTmpTabF5M := FWTemporaryTable():New(cTmpTabF5M)
    aF5MFields := F5M->(DBStruct())
    aF5MFldsAd := ACLONE(aF5MFields)
    AADD(aF5MFldsAd,{"F5MFLKEY"                         ,;
                     GetSX3Cache("F5M_KEY","X3_TIPO")   ,;
                     GetSX3Cache("F5M_KEY","X3_TAMANHO"),;
                     GetSx3Cache("F5M_KEY","X3_DECIMAL")})
    oTmpTabF5M:SetFields(aF5MFldsAd)
    oTmpTabF5M:AddIndex(cTmpTabF5M+"1",;
        {"F5M_FILIAL","F5M_ALIAS","F5M_IDDOC","F5MFLKEY"})
    oTmpTabF5M:Create()
    cTpTF5MRet := CriaTrab(, .F.)
    oTpTF5MRet := FWTemporaryTable():New(cTpTF5MRet)
    oTpTF5MRet:SetFields(aF5MFldsAd)
    oTpTF5MRet:AddIndex(cTpTF5MRet+"1",;
        {"F5M_FILIAL","F5M_ALIAS","F5M_IDDOC","F5MFLKEY"})
    oTpTF5MRet:Create()

    cTmpTabTP1 := CriaTrab(, .F.)
    oTmpTabTP1 := FWTemporaryTable():New(cTmpTabTP1)
    oTmpTabTP1:SetFields(aF5MFldsAd)
    oTmpTabTP1:AddIndex(cTmpTabTP1+"1",;
        {"F5M_FILIAL","F5M_ALIAS","F5M_IDDOC","F5MFLKEY"})
    oTmpTabTP1:Create()

    cTpTTP1Ret := CriaTrab(, .F.)
    oTpTTP1Ret := FWTemporaryTable():New(cTpTTP1Ret)
    oTpTTP1Ret:SetFields(aF5MFldsAd)
    oTpTTP1Ret:AddIndex(cTpTTP1Ret+"1",;
        {"F5M_FILIAL","F5M_ALIAS","F5M_IDDOC","F5MFLKEY"})
    oTpTTP1Ret:Create()

    cF5MFields := " "
    cF5MFldsAd := " "
    cF5MLen    := RU06XFUN44_RetSE2FldsPosInFMKey(lInflow)[8][2]
    For nX := 1 To Len(aF5MFldsAd)
        If     aF5MFldsAd[nX][1] == "F5M_KEY"
            cF5MFldsAd += "CAST(F5M_KEY AS CHAR("+cF5MLen+")) F5M_KEY" + ", "
            cF5MFields += aF5MFldsAd[nX][1]  + ", "
        ElseIf aF5MFldsAd[nX][1] == "F5MFLKEY"
            cF5MFldsAd += "F5M_KEY F5MFLKEY" + ", "
            cF5MFields += aF5MFldsAd[nX][1]  + ", "
        Else
            cF5MFldsAd += aF5MFldsAd[nX][1] + ", "
            cF5MFields += aF5MFldsAd[nX][1] + ", "
        EndIf
    Next nX
    cF5MFields := SubStr(cF5MFields,1,Len(cF5MFields)-2)
    cF5MFldsAd := SubStr(cF5MFldsAd,1,Len(cF5MFldsAd)-2)
    // get data from SE2 table and create temporary table    
    cQuery := "SELECT "
    cQuery += cSE2Fields
    cQuery += " FROM " + cQrSE2
    cQuery := ChangeQuery(cQuery)
    cQuery := "INSERT INTO "+oTmpTabSE2:GetRealName()+;
              " ( "+cSE2Fields+" ) "+ cQuery
    nStat  := -1
    lLock  := .T.
    nStat  := TCSqlExec(cQuery)
    aLockSE2 := {}
    aLockF5M := {}
    cErrMsg  := ""
    If nStat >= 0
        aArea := GetArea()
        If lInflow
            aAreaSE2 := SE1->(GetArea())
            SE1->(DBGoTop())
            SE1->(DBSetOrder(2)) //fil+cli+loja+pr+num+par+tip
        Else
            aAreaSE2 := SE2->(GetArea())
            SE2->(DBGoTop())
            SE2->(DBSetOrder(1)) //fil+pr+num+par+tip+for+loja
        EndIf
        cSE2TMPAls := oTmpTabSE2:GetAlias()
        DBSelectArea(cSE2TMPAls)
        DBGoTop()
        While lLock .AND. !Eof()
            If lInflow
                If SE1->(DBSeek((cSE2TMPAls)->E1_FILIAL+;
                        (cSE2TMPAls)->E1_CLIENTE+;
                        (cSE2TMPAls)->E1_LOJA+;
                        (cSE2TMPAls)->E1_PREFIXO+;
                        (cSE2TMPAls)->E1_NUM+;
                        (cSE2TMPAls)->E1_PARCELA+;
                        (cSE2TMPAls)->E1_TIPO        ))
                    // if we didn't find SE1 line, someone already
                    // rewrited it
                    If SE1->(MSRLock())
                        RecLock((cSE2TMPAls),.F.)
                        For nX := 1 To Len(aSE2Fields) 
                            (cSE2TMPAls)->&(aSE2Fields[nX][1]) := ;
                            SE1->&(aSE2Fields[nX][1])
                        Next nX
                        AADD(aLockSE2,SE1->(RecNo()))
                        (cSE2TMPAls)->(MSUnlock())
                    Else
                        lLock := .F.
                    EndIf
                Else
                    lLock := .F.
                EndIf
            Else
                If SE2->(DBSeek((cSE2TMPAls)->E2_FILIAL+;
                      (cSE2TMPAls)->E2_PREFIXO+;
                      (cSE2TMPAls)->E2_NUM+;
                      (cSE2TMPAls)->E2_PARCELA+;
                      (cSE2TMPAls)->E2_TIPO+;
                      (cSE2TMPAls)->E2_FORNECE+;
                      (cSE2TMPAls)->E2_LOJA        ))
                    // if we didn't find SE2 line, someone already
                    // rewrited it
                    If SE2->(MSRLock())
                        RecLock((cSE2TMPAls),.F.)
                        For nX := 1 To Len(aSE2Fields) 
                            (cSE2TMPAls)->&(aSE2Fields[nX][1]) := ;
                            SE2->&(aSE2Fields[nX][1])
                        Next nX
                        AADD(aLockSE2,SE2->(RecNo()))
                        (cSE2TMPAls)->(MSUnlock())
                    Else
                        lLock := .F.
                    EndIf
                Else
                    lLock := .F.
                EndIf
            EndIf
            DBSkip()
        EndDo
        RestArea(aAreaSE2)
        RestArea(aArea)
        If lLock == .T.
             //Delete SE2 lines from temp table where 
            //where filter parameters are not applied to selected
            //lines
            If !Empty(oTmpTabSE2)
                aArea  := GetArea()
                cSE2Nm := IIF(lInflow,RetSQLName("SE1"),RetSQLName("SE2"))
                nSE2Nl := Len(cSE2Nm)
                nSE2Ps := At(cSE2Nm,cQrSE2)
                cQtSE2 := SubStr(cQrSE2,1,nSE2Ps-1)+" "+oTmpTabSE2:GetRealName()+" "+;
                          SubStr(cQrSE2,nSE2Ps+nSE2Nl)
                cQuery := " SELECT "
                cQuery += cSE2Fields
                cQuery += " FROM " + cQtSE2
                cQuery := ChangeQuery(cQuery)
                cQuery := "INSERT INTO "+oTpTSE2Ret:GetRealName()+;
                          " ( "+cSE2Fields+" ) "+ cQuery
                nStat  := TCSqlExec(cQuery)
                If nStat < 0
                    cErrMsg += " TCSQLError() " + TCSQLError()
                EndIf
                oTmpTabSE2:Delete()
                RestArea(aArea)
            EndIf
            // get data from F5M table where F5M_CTRBAL == 1 
            // and create temporary table
            cSE2Nm := IIf(lInflow, "SE1", "SE2") 
            cQuery := " SELECT " + cF5MFields + "                               "
            cQuery += " FROM                                                    "
            cQuery += "      ( SELECT *                                         "
            cQuery += "        FROM     "+ oTpTSE2Ret:GetRealName()
            cQuery += "                                           ) "+cSE2Nm+"  "
            cQuery += " INNER JOIN                                              "
            cQuery += "      ( SELECT " + cF5MFldsAd + "                        "
            cQuery += "        FROM     "+RetSQlName("F5M") + "                 "
            cQuery += "        WHERE F5M_CTRBAL = '1'                           "
            cQuery += "          AND D_E_L_E_T_ = ' '                           "
            cQuery += "                                           ) F5M         "
            cQuery += " ON ("+RU06XFUN09_RetSE2F5MJoinOnString("F5M",lInflow)+")"
            cQuery := ChangeQuery(cQuery)
            cQuery := "INSERT INTO "+oTmpTabF5M:GetRealName()+;
                      " ( "+cF5MFields+" ) "+ cQuery
            // get data from F5M table where F5M_CTRBAL == 2, F5M_ALIAS == "F4C"
            // and F4C_STATUS inner joined to F5M line by F5M_IDODC
            // have value 2 or 5
            cQuery2 := " SELECT " + cF5MFields + "                               "
            cQuery2 += " FROM                                                    "
            cQuery2 += "      ( SELECT *                                         "
            cQuery2 += "        FROM     "+ oTpTSE2Ret:GetRealName() + "         "
            cQuery2 += "                                           ) "+cSE2Nm+"  "
            cQuery2 += " INNER JOIN                                              "
            cQuery2 += "      ( SELECT " + cF5MFldsAd + "                        "
            cQuery2 += "        FROM     "+RetSQlName("F5M") + "                 "
            cQuery2 += "        WHERE F5M_CTRBAL = '2'                           "
            cQuery2 += "          AND F5M_ALIAS  = 'F4C'                         "
            cQuery2 += "          AND D_E_L_E_T_ = ' '                           "
            cQuery2 += "                                           ) F5M         "
            cQuery2 += " ON ("+RU06XFUN09_RetSE2F5MJoinOnString("F5M",lInflow)+")"
            cQuery2 += " INNER JOIN                                              "
            cQuery2 += "      ( SELECT *                                         "
            cQuery2 += "        FROM   "+RetSQlName("F4C")+"                     "
            cQuery2 += "        WHERE F4C_FILIAL = '"+xFilial("F4C")+"'          "
            cQuery2 += "          AND (F4C_STATUS = '2' OR F4C_STATUS = '5')     "
            cQuery2 += "          AND D_E_L_E_T_ = ' '                           "
            cQuery2 += "                                           ) F4C         "
            cQuery2 += " ON  ( F4C.F4C_CUUID = F5M.F5M_IDDOC )                   "
            cQuery2 := ChangeQuery(cQuery2)
            cQuery2 := "INSERT INTO "+oTmpTabTP1:GetRealName()+;
                      " ( "+cF5MFields+" ) "+ cQuery2
            If nStat >= 0
                nStat  := TCSqlExec(cQuery)
                If nStat >= 0
                    nStat := TCSqlExec(cQuery2)
                EndIf
            EndIf
            aTmpTabs := {oTmpTabF5M, oTmpTabTP1}
            If nStat >= 0
                For nY := 1 To Len(aTmpTabs)
                    oTmp := aTmpTabs[nY]
                    aArea := GetArea()
                    aAreaF5M := F5M->(GetArea())
                    F5M->(DBGoTop())
                    F5M->(DBSetOrder(1)) //F5M_FILIAL+F5M_ALIAS+F5M_IDDOC+F5M_KEY
                    cF5MTMPAls := oTmp:GetAlias()
                    DBSelectArea(cF5MTMPAls)
                    DBGoTop()
                    While lLock .AND. !Eof()
                        If F5M->(DBSeek((cF5MTMPAls)->F5M_FILIAL+;
                                (cF5MTMPAls)->F5M_ALIAS+;
                                (cF5MTMPAls)->F5M_IDDOC+;
                                (cF5MTMPAls)->F5MFLKEY          ))
                            // if we didn't find F5M line, someone already
                            // rewrited it
                            If F5M->(MSRLock())
                                RecLock((cF5MTMPAls),.F.)
                                For nX := 1 To Len(aF5MFldsAd)
                                    If     aF5MFldsAd[nX][1] == "F5MFLKEY"
                                        (cF5MTMPAls)->&(aF5MFldsAd[nX][1]) := ;
                                        F5M->F5M_KEY
                                    ElseIf aF5MFldsAd[nX][1] == "F5M_KEY"
                                        (cF5MTMPAls)->F5M_KEY := ;
                                        SubStr(F5M->F5M_KEY,1,Val(cF5MLen))
                                    Else
                                        (cF5MTMPAls)->&(aF5MFldsAd[nX][1]) := ;
                                        F5M->&(aF5MFldsAd[nX][1])
                                    EndIf
                                Next nX
                                AADD(aLockF5M,F5M->(RecNo()))
                                (cF5MTMPAls)->(MSUnlock())
                            Else
                                lLock := .F.
                            EndIf
                        Else
                            lLock := .F.
                        EndIf
                        DBSkip()
                    EndDo
                    RestArea(aAreaF5M)
                    RestArea(aArea)
                Next nY
            Else
                cErrMsg += " TCSQLError() " + TCSQLError()
            EndIf
        EndIf
    Else
        cErrMsg += " TCSQLError() " + TCSQLError()
    EndIf
    //Delete F5M lines from temp table where F5M_CTRBAL != "1"
    If !Empty(oTmpTabF5M)
        aArea  := GetArea()
        cQuery := " SELECT " + cF5MFields + "             "
        cQuery += " FROM " + oTmpTabF5M:GetRealName() + " "
        cQuery += " WHERE F5M_CTRBAL = '1'                "
        cQuery += "   AND D_E_L_E_T_ = ' '                "
        cQuery := ChangeQuery(cQuery)
        cQuery := "INSERT INTO "+oTpTF5MRet:GetRealName()+;
                  " ( "+cF5MFields+" ) "+ cQuery
        If nStat >= 0
            nStat  := TCSqlExec(cQuery)
            If nStat < 0
                cErrMsg += " TCSQLError() " + TCSQLError()
            EndIf
        EndIf
        oTmpTabF5M:Delete()
        RestArea(aArea)
    EndIf
    //Delete F5M lines from temp table where F5M_CTRBAL != "2"
    If !Empty(oTmpTabTP1)
        aArea  := GetArea()
        cQuery := " SELECT " + cF5MFields + "             "
        cQuery += " FROM " + oTmpTabTP1:GetRealName() + " "
        cQuery += " WHERE F5M_CTRBAL = '2'                "
        cQuery += "   AND D_E_L_E_T_ = ' '                "
        cQuery := ChangeQuery(cQuery)
        cQuery := "INSERT INTO "+oTpTTP1Ret:GetRealName()+;
                  " ( "+cF5MFields+" ) "+ cQuery
        If nStat >= 0
            nStat  := TCSqlExec(cQuery)
            If nStat < 0
                cErrMsg += " TCSQLError() " + TCSQLError()
            EndIf
        EndIf
        oTmpTabTP1:Delete()
        RestArea(aArea)
    EndIf
    // unlock F5M records
    If !Empty(aLockF5M)
        aArea := GetArea()
        aAreaF5M := F5M->(GetArea())
        DBSelectArea("F5M")
        nLnLckF5M := Len(aLockF5M)
        For nX := 1 To nLnLckF5M
            DBGoTo(aLockF5M[nX])
            MSRUnLock()
        Next nX
        RestArea(aAreaF5M)
        RestArea(aArea)
    EndIf
    // unlock SE2 records
    If !Empty(aLockSE2)
        aArea := GetArea()
        
        If lInflow
			aAreaSE2 := SE1->(GetArea())
            DBSelectArea("SE1")
        Else
			aAreaSE2 := SE2->(GetArea())
            DBSelectArea("SE2")
        EndIf
        nLnLckSE2 := Len(aLockSE2)
        For nX := 1 To nLnLckSE2
            DBGoTo(aLockSE2[nX])
            MSRUnLock()
        Next nX
        RestArea(aAreaSE2)
        RestArea(aArea)
    EndIf
    //return result
    aRet := {IIF(!Empty(oTpTSE2Ret),oTpTSE2Ret,Nil),;
             IIF(!Empty(oTpTF5MRet),oTpTF5MRet,Nil),;
             IIF(!Empty(oTpTTP1Ret),oTpTTP1Ret,Nil),;
             nStat,cErrMsg,lLock                    }   
Return (aRet) /*---------------------------------------------RU06XFUN51_RecieveSE2F5MLines*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN52_CTBF4C

This function called from CTBFINProc() and used for automatic offline accounting posting
for bank statements

@param       nShwPst  - Show Postings? 1- Yes, 2- No. Related to private var in RU06D07RUS
                        lDigita (.T. - dispaly entries, .F. - not display)                        
             dDatFrm  - Date Started, From Date
             dDatEnd  - End Date, To Date
@public      cFilAnt  - Current branch, for which we make postings in accounting
@return      Logical          lRet
@example     
@author      astepanov
@since       November/06/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN52_CTBF4C(nShwPst,dDatFrm,dDatEnd)

    Local lRet       As Logical
    Local cSFINPOS   As Character
    Local cSREPLPS   As Character
    Local cQuery     As Character
    Local cAlias     As Character
    Local aArea      As Array
    Local aAreaF4C   As Array
    Local aTmpArea   As Array
    Local lTmpGerLn  As Logical
    Local lTmpDigit  As Logical

    Default nShwPst := 1
    Default dDatFrm := dDataBase
    Default dDatEnd := dDataBase

    lRet := .T.
    
    //check private vars and create temporary store for them
    //if lGeraLanc == .T. we create accounting postings
    //so, for our case it should be always .T.
    //if lDigita == .T. - we show accounting postings
    //if lDigita == .F. - we don't show accounting postings
    If Type("lGeraLanc") == "L"
        lTmpGerLn := lGeraLanc
        lGeraLanc := .T.
    Else
        Private lGeraLanc := .T.
        lTmpGerLn := lGeraLanc
    EndIf
    If Type("lDigita") == "L"
        lTmpDigit := lDigita
        lDigita   := IIf(nShwPst == 1,.T.,.F.)
    Else
        Private lDigita := IIf(nShwPst == 1,.T.,.F.)
        lTmpDigit := lDigita
    EndIf

    cSFINPOS :=  "2" // status: posted in finance
    cSREPLPS :=  "5" // replacement posted in finance

    //select  outflow bank statements unposted in accounting which
    //posted in finance . We select unposted BS lines because:
    //1: if BS header is posted in accounting (F4C_LA == "S") according
    //   to current specification writeoffs and PA lines which related to
    //   this BS line should be posted in accounting too. We cannot post separate
    //   BS header and BS line. If it will be changed in future, 
    //   so we should also select F4C_LA == "S" too and change if condition
    //   below.
    //2: For BS reversal F4C_LA=="S" and for reverasal in finance we also
    //   have postings in accounting. So according to specification
    //   reversed BS line always posted in accounting.
    cQuery := " SELECT R_E_C_N_O_,                        "
    cQuery += "        F4C_DTTRAN,                        "
    cQuery += "        F4C_INTNUM                         "
    cQuery += " FROM " + RetSQLName("F4C") + "            "
    cQuery += " WHERE  F4C_FILIAL = '" + cFilAnt + "'     "
    cQuery += "   AND  F4C_DTTRAN BETWEEN                 "
    cQuery += "                   '" + DTOS(dDatFrm) + "' "
    cQuery += "                   AND                     "
    cQuery += "                   '" + DTOS(dDatEnd) + "' "
    cQuery += "   AND (F4C_STATUS = '" + cSFINPOS +    "' "
    cQuery += "        OR                                 "
    cQuery += "        F4C_STATUS = '" + cSREPLPS +    "')" 
    cQuery += "   AND  F4C_LA    <> 'S'                   "
    cQuery += "   AND  D_E_L_E_T_ = ' '                   "
    cQuery += " ORDER BY F4C_DTTRAN, F4C_INTNUM ASC       "
    cQuery   := ChangeQuery(cQuery)
    cAlias   := MPSysOpenQuery(cQuery)
    aArea    := GetArea()
    aAreaF4C := F4C->(GetArea())
    DBSelectArea(cAlias)
    DBGoTop()
    While lRet .AND. !EoF()
        aTmpArea := GetArea()
        DbSelectArea("F4C")
        DBGoTo((cAlias)->(R_E_C_N_O_))
        //lock F4C record
        If RecLock("F4C",.F.)
            If !(F4C->F4C_LA == "S") .AND.;
                (F4C->F4C_STATUS == cSFINPOS .OR.;
                 F4C->F4C_STATUS == cSREPLPS     )
               //so we postioned on correct F4C record it is locked
               //for changes, so run posting function:
               lRet := lRet .AND. RU06D07009_PostInAccounting(.F.)
            EndIf
            F4C->(MSUnlock())
        Else
            lRet := .F. // stop postings, we can't lock F4C record
        EndIf
        RestArea(aTmpArea)
        DBSkip()
    EndDo
    (cAlias)->(DBCloseArea())
    RestArea(aAreaF4C)
    RestArea(aArea)

    //restore private vars values if we need it:
    If Type("lGeraLanc") == "L"
        lGeraLanc := lTmpGerLn
    EndIf
    If Type("lDigita") == "L"
        lDigita   := lTmpDigit
    EndIf
    
Return (lRet) /*---------------------------------------------------------RU06XFUN52_CTBF4C*/

/*/{Protheus.doc} RU06XFUN53_LegendForQuery()
Makes legend in finc040 and finc050: Query menu - Other actions - Legend button
@author Alexander Ivanov
@since 28/11/2019
@project     MA3
@version 12.1.25
/*/
Function RU06XFUN53_LegendForQuery(cOperation)
    Local aLegenda as Array
    Local lShowLgnd as Logical
    aLegenda := {}
    lShowLgnd := .T.

    aadd(aLegenda, {"BR_VERDE",   STR0024})
    aadd(aLegenda, {"DISABLE",    STR0025})

    If cOperation == "AP"
        aadd(aLegenda, {"BR_BRANCO",  STR0026})

    ElseIf cOperation == "AR"  
        aadd(aLegenda, {"BR_AMARELO", STR0028})

    Else
        Help(STR0029)
        lShowLgnd := .F.  
    EndIf

    aadd(aLegenda, {"BR_PRETO", STR0057})
    If lShowLgnd
        BrwLegenda(STR0027, STR0027, aLegenda)
    EndIf
Return

/*/{Protheus.doc} RU06XFUN53_LegendForQuery()
Retunr The recno related to the cancelation of the writeoff moviment. 
@author Eduardo.Flima
@since 17/21/2019
@project     MA3
@version 12.1.25
/*/
Function RU06XFUN54_RetFk2Canc(cIdOrig)
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array
    Local nRet      As Numeric
    
    aSaveArea  := GetArea()
    cQuery:=""
    cAlias:=""

    cQuery:= "SELECT R_E_C_N_O_ "
    cQuery += " FROM "      + RetSQLName("FK2") +" "  
    cQuery += " WHERE  fk2_iddoc = ( "
    cQuery += " SELECT fk2_iddoc  "
    cQuery += " FROM "      + RetSQLName("FK2") +" "    
    cQuery += " WHERE  fk2_idfk2 = '"+ cIdOrig +"') "    
    cQuery += " AND fk2_tpdoc = 'ES'  "    
    
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nRet := (cAlias)->R_E_C_N_O_
    Else
        nRet := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)
Return nRet
/*/{Protheus.doc} RU06XFUN55_QuerryF5MBalance
Function Used to set the query about the locked balances in F5M used in several functons that need to have access to this
information like RU06XFUN06_GetOpenBalance. It only set the query so the use of this string will be setled in the calling function
@author eduardo.flima
@since 18/12/2018
@version 1.1
@Parameter 
cSe2Key: String with key Fields of SE2 used to find the Specified Register
in the format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA
@Return
cQuery: Character with the String responsible to perform the query and return the values about the balance locked in F5M to the related cSe2Key
@project MA3 - Russia
/*/

Function RU06XFUN55_QuerryF5MBalance(cSe2Key)
    Local aSe2Key   As Array
    aSe2Key   := StrTokArr(cSe2Key, "|") 
    cQuery := " SELECT                                                         "
    cQuery += "      SE2.E2_SALDO SALDOSE2,                                    "
    cQuery += "      0            TOTALF5M                                     "
    cQuery += " FROM "      + RetSQLName("SE2") + " SE2                        "
    cQuery += " WHERE SE2.E2_FILIAL  = '"+ PADR(AllTrim(aSe2Key[1]),GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_PREFIXO = '"+ PADR(AllTrim(aSe2Key[2]),GetSX3Cache("E2_PREFIXO","X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_NUM     = '"+ PADR(AllTrim(aSe2Key[3]),GetSX3Cache("E2_NUM"    ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_PARCELA = '"+ PADR(AllTrim(aSe2Key[4]),GetSX3Cache("E2_PARCELA","X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_TIPO    = '"+ PADR(AllTrim(aSe2Key[5]),GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_FORNECE = '"+ PADR(AllTrim(aSe2Key[6]),GetSX3Cache("E2_FORNECE","X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.E2_LOJA    = '"+ PADR(AllTrim(aSe2Key[7]),GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO"),' ') + "'"
    cQuery += "   AND SE2.D_E_L_E_T_ = ' '                                     "
    cQuery += " UNION                                                          "
    cQuery += " SELECT                                                         "
    cQuery += "       0                   SALDOSE2,                            "
    cQuery += "       SUM(F5M.F5M_VALPAY) TOTALF5M                             "
    cQuery += " FROM "      + RetSQLName("F5M") + " F5M                        "
    cQuery += "           WHERE  F5M.F5M_KEY    = '" + cSe2Key + "'            "
    cQuery += "             AND  F5M.F5M_CTRBAL = '" +   "1"   + "'            "
    cQuery += "             AND  F5M.D_E_L_E_T_ = ' '                          "
    cQuery := " SELECT SUM(SALDOSE2) SALDO, SUM(TOTALF5M) TOTAL FROM ( " +;
            cQuery +;
            " ) RSLT "
    cQuery := ChangeQuery(cQuery)

Return cQuery





/*/{Protheus.doc} RU06XFUN06_GetOpenBalance
Function Used to restore the Open balance of the accounts payable 
Subtracting all the values that is already used in any Bank Statement Process.
@author natalia.khozyainova
@since 27/11/2018
@version 1.1
@edit   astepanov 11 July 2019
@Parameter 
cSe2Key: String with key Fields of SE2 used to find the Specified Register
in the format: E2_FILIAL|E2_PREFIXO|E2_NUM|E2_PARCELA|E2_TIPO|E2_FORNECE|E2_LOJA
@Return
nOpBal: Numeric with the Value considering the E2_SALDO- SUM(F5M_VALPAY) to the related cSe2Key
@project MA3 - Russia
/*/
Function RU06XFUN56_GetLockedBalance(cSe2Key)

    Local nLockBal    As Numeric
    Local cQuery    As Character
    Local cAlias    As Character
    Local aSaveArea As Array

    aSaveArea := GetArea()
    cQuery:= RU06XFUN55_QuerryF5MBalance(cSe2Key) // set the querry 
    cAlias := MPSysOpenQuery(cQuery)
    DBSelectArea(cAlias)
    DBGoTop()
    If !Eof()
        nLockBal := (cAlias)->TOTAL
    Else
        nLockBal := 0
    EndIf
    (cAlias)->(DBCloseArea())
    RestArea(aSaveArea)

Return (nLockBal)

/*/{Protheus.doc} RU06XFUN
Check EA table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN57_PutTableEA()

DbSelectArea('SX5')
SX5->(DbSetOrder(1))
Do case
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0048)))
        FWPutSX5(STR0047, STR0055, STR0048, STR0032, STR0032, STR0032, STR0032)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0049)))
        FWPutSX5(STR0047, STR0055, STR0049, STR0033, STR0033, STR0033, STR0033)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0050)))
        FWPutSX5(STR0047, STR0055, STR0050, STR0034, STR0034, STR0034, STR0034)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0051)))
        FWPutSX5(STR0047, STR0055, STR0051, STR0035, STR0035, STR0035, STR0035)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0052)))
        FWPutSX5(STR0047, STR0055, STR0052, STR0036, STR0036, STR0036, STR0036)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0053)))
        FWPutSX5(STR0047, STR0055, STR0053, STR0037, STR0037, STR0037, STR0037)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0055 + STR0054)))
        FWPutSX5(STR0047, STR0055, STR0054, STR0038, STR0038, STR0038, STR0038)
EndCase

Return

/*/{Protheus.doc} RU06XFUN
Check EB table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN58_PutTableEB()

DbSelectArea('SX5')
SX5->(DbSetOrder(1))
Do case
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0043)))
        FWPutSX5(STR0047, STR0056, STR0043, STR0039, STR0039, STR0039, STR0039)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0044)))
        FWPutSX5(STR0047, STR0056, STR0044, STR0040, STR0040, STR0040, STR0040)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0045)))
        FWPutSX5(STR0047, STR0056, STR0045, STR0041, STR0041, STR0041, STR0041)
    Case(SX5->(Dbseek(xFilial('SX5') + STR0056 + STR0046)))
        FWPutSX5(STR0047, STR0056, STR0046, STR0042, STR0042, STR0042, STR0042)
EndCase

Return
/*/{Protheus.doc} RU06XFUN
Check EB table in SX5
FI-CF-25-5
@author alexander.kharchenko
@since 16.12.2019 
@version 1.0 
@project MA3 - Russia
/*/
Function RU06XFUN60_Calcfk3Rus(cOrdPag,dBaixa,nValBx,cFil,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja)
    Local aArea         As Array
    Local cQuery        as Character
    Local cAlias        as Character
    Local cF5MKLn       as Character
    Local nVatCalc      as Numeric
    Local nVatBaseC     as Numeric
    Local aImpostos     as Array



    aArea       := GetArea()
    cQuery      := ""
    cAlias      :=""
    nVatCalc    :=0
    nVatBaseC   :=0
    aImpostos   :={}

    If !empty(cOrdPag)
        cFil      := PADR(cFil,GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO")," ")
	    cPrefixo  := PADR(cPrefixo,GetSX3Cache("E2_PREFIXO","X3_TAMANHO")," ")
	    cNum      := PADR(cNum,GetSX3Cache("E2_NUM"    ,"X3_TAMANHO")," ")
	    cParcela  := PADR(cParcela,GetSX3Cache("E2_PARCELA","X3_TAMANHO")," ")
	    cTipo     := PADR(cTipo,GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO")," ")
	    cFornece  := PADR(cFornece,GetSX3Cache("E2_FORNECE","X3_TAMANHO")," ")
	    cLoja     := PADR(cLoja,GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO")," ")
        cF5MKey   := cFil+"|"+cPrefixo+"|"+cNum+"|"+cParcela+"|"+cTipo+"|"+cFornece+"|"+cLoja
        cF5MKLn   := RU06XFUN44_RetSE2FldsPosInFMKey()[8][2]

        cQuery := " SELECT    F5M_BSVATC,                                      "
        cQuery += "       F5M_VLVATC,                                          "
        cQuery += "       F5M_VALPAY                                          "        
        cQuery += " FROM " + RetSQlName("F5M") + " F5M                         "
        cQuery += " WHERE F5M_FILIAL = '"+xFilial("F5M")+"' "
        cQuery += " AND F5M_IDDOC = (SELECT F4C_CUUID                       "
        cQuery += " FROM " + RetSQlName("F4C") + " F4C                         "
        cQuery += " WHERE F4C_FILIAL = '"+xFilial("F4C")+"' "
        cQuery += "   AND F4C_INTNUM = '"+ cOrdPag +"'"                       
        cQuery += "   AND F4C_DTTRAN = '" + DTOS(dBaixa) + "'               "
        cQuery += "   AND F4C.D_E_L_E_T_ = ' '             ) "
        cQuery += "   AND TRIM(SUBSTRING(F5M_KEY,1,"+cF5MKLn+")) = '" + cF5MKey + "' "
        cQuery += " AND F5M.D_E_L_E_T_ = ' '                       "
        cQuery := ChangeQuery(cQuery)
        cAlias := MPSysOpenQuery(cQuery)
        DbSelectArea(cAlias)
        DBGoTop()
        If !EoF()
            nVatCalc := (cAlias)->F5M_VLVATC
            nVatBaseC:= (cAlias)->F5M_BSVATC
            (cAlias)->(DBCloseArea())
        EndIf
        RestArea(aArea)
    Else
        DBSelectArea("SE2")  
        DBSetOrder(1)   // filial+prefixo+num+parcela+tipo+fornece+loja
        If DBSeek(cFil+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja) // position to record before post
            nVatBaseC:=nValBx			
            nVatCalc:= round((nValBx / SE2->E2_VALOR * SE2->e2_valimp1),2)
        Endif
        RestArea(aArea)
    Endif
	aadd(aImpostos,{"VAT", nVatCalc, "VAT", "", 0, nVatBaseC, , ""})

Return aImpostos

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN01_BCOFilter (Russian Name)
Filter for BCO query, Russia
@Author	natalia.khozyainova	
@since	15/10/2018
/*/
//-----------------------------------------------------------------------------------------------------
Function FINXFIN001()
Local lRet as Logical
Local cFldMoeda as Character
Local cFldConUni as Character

If alltrim(ReadVar())!= ''
	__cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
EndIf
lRet:=.T.

If __cRuPrf=='E1' .or. __cRuPrf=='E2'
	cFldMoeda:='M->'+__cRuPrf+'_MOEDA'
	cFldConUni:='M->'+__cRuPrf+'_CONUNI'
	lRet:= (SA6->A6_MOEDA == &(cFldMoeda).and. &(cFldConUni)!='1') .or. ( SA6->A6_MOEDA==1 .and. &(cFldConUni)=='1')
ElseIf __cRuPrf=='F47' .or. __cRuPrf=='F49' 
	cFldMoeda:='M->'+__cRuPrf+'_CURREN'
	lRet:= (SA6->A6_MOEDA== VAL(&(cFldMoeda)) ) 
EndIf

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN002_FILFilter (Russian Name)
    (old: FINXFIN02)
Filter for FIL query, Russia
@Author	natalia.khozyainova	
@since	15/10/2018
/*/
//-----------------------------------------------------------------------------------------------------

Function FINXFIN002_FILFilter()
    Local cRet			as Character
    Local cFldMoeda		as Character
    Local cFldConUni	as Character
    Local cCliFor		as Character
    Local cBranch		as Character

    cRet:="@#@#"
    
    If alltrim(ReadVar())!= ''
        __cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
    EndIf
    If __cRuPrf == "A2"
        cCliFor := M->A2_COD
        cBranch := M->A2_LOJA
        cRet := "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "')@#"
    ElseIf __cRuPrf=='E1' .or. __cRuPrf=='E2'
        cCliFor := Iif(__cRuPrf == "E1",M->E1_CLIENTE,M->E2_FORNECE)
        cBranch := &(__cRuPrf+"_LOJA")
        cFldMoeda:='M->'+__cRuPrf+'_MOEDA'
        cFldConUni:='M->'+__cRuPrf+'_CONUNI'
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') .And. ((FIL_MOEDA == " + alltrim(STR(&(cFldMoeda))) + " .And. " + cFldConUni + "!='1') .Or. ( FIL_MOEDA==1 .And. " + cFldConUni + "=='1'))@#"
    ElseIf __cRuPrf $ "F47|F49|F4C"
        cCliFor := &(__cRuPrf + "_SUPP")
        cBranch := &(__cRuPrf+"_UNIT")
        cFldMoeda:='M->'+__cRuPrf+'_CURREN'
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') .And. (FIL_MOEDA== VAL('" + &(cFldMoeda) + "') )@#"
   	ElseIf __cRuPrf $ "F6B"
		cCliFor := FwFldGet("F6B_SUPP")
		cBranch := FwFldGet("F6B_UNIT")
        cRet:= "@#(FIL_FORNEC = '" + cCliFor + "') .And. (FIL_LOJA == '" + cBranch + "') @#"
	EndIf
Return cRet


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN004_F4NFilter (Russian Name)
Filter for F4N query, Russia
@Author	alexandra.velmozhnya
@since	16/01/2020
/*/
//-----------------------------------------------------------------------------------------------------
function FINXFIN004_F4NFilter()
Local cRuPrf as Character	//Prefix current table
Local cCliFor as Character	//Client or Supplier Code
Local cBranch as Character	//Client or Supplier Branch
Local cBSFlowDir as Character	//Bank Statment Direction
Local cMoeda as Character	//Currency of Document
Local cRet := ""

If alltrim(ReadVar())!= ''
     cRuPrf:=SUBSTR(ReadVar(),4,AT('_',ReadVar())-4)
EndIf

If cRuPrf == "A1"
	cCliFor := M->A1_COD
	cBranch := M->A1_LOJA
	cMoeda := ""
ElseIf cRuPrf == "F4C"
    cBSFlowDir := FwFldGet("F4C_OPER")
    cCliFor := Iif(cBSFlowDir == "1",FWFldGet("F4C_CUST"),FWFldGet("F4C_SUPP"))
    cBranch := Iif(cBSFlowDir == "1",FWFldGet("F4C_CUNI"),FWFldGet("F4C_UNIT"))
    cMoeda := FwFldGet("F4C_CURREN")
EndIf
cRet := "@#F4N_CLIENT == '"+ cCliFor + "' .And. F4N_LOJA == '"+ cBranch + Iif(!Empty(cMoeda),"' .And. F4N_CURREN == '" + cMoeda + "'@#","'@#")
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN61_SE5LinesFilter

This function used by CTBFINProc() in ctbafin.prw
We use it during bank statement automatic off-line accounting posting
for excluding SE5 lines created by outflow bank statement

@return      Character        cQuery
@example     
@author      astepanov
@since       February/28/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN61_SE5LinesFilter()

    Local cQuery     As Character
    cQuery := ""
    cQuery += " E5_ORIGEM <> '"+;
              PADR("RU06D07",GetSX3Cache("E5_ORIGEM","X3_TAMANHO")," ")+"' AND "
    cQuery += " NOT ( "
    cQuery += "       E5_TIPO    = 'PA' AND "
    cQuery += "       E5_ORIGEM  = ' '  AND "
    cQuery += "       E5_TIPODOC = 'BA' AND "
    cQuery += "       E5_PREFIXO = '"+;
              PADR(GetMV("MV_BSTPRE"),GetSX3Cache("E5_PREFIXO","X3_TAMANHO")," ")+"' AND "
    cQuery += "       E5_MOVFKS  = 'N'  AND "
    cQuery += "       E5_IDORIG  = ' '  AND "
    cQuery += "       E5_TABORI  = ' '      "
    cQuery += "     ) AND "
    
Return (cQuery) /*------------------------------------------------RU06XFUN61_SE5LinesFilter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN62_SE2LinesFilter

This function used by CTBFINProc() in ctbafin.prw
We use it during bank statement automatic off-line accounting posting
for excluding SE2 lines created by outflow bank statement

@return      Character        cQuery
@example     
@author      astepanov
@since       February/28/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN62_SE2LinesFilter()

    Local cQuery     As Character
    cQuery := ""
    cQuery += " E2_ORIGEM <> '"+;
              PADR("RU06D07",GetSX3Cache("E2_ORIGEM","X3_TAMANHO")," ")+"' AND "
    
Return (cQuery) /*------------------------------------------------RU06XFUN62_SE2LinesFilter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN63_F40GrvSE5

Russian variant of F040GrvSE5 located in FINA040

@param       Numeric          nOpc  // 1
             Logical          lDesdobr
             Character        cBcoAdt
             Character        cAgeAdt
             Character        cCtaAdt
             Numeric          nRecSe1
             Array            aAutoCab
@return      Logical          lRet
@example     
@author      astepanov
@since       March/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN63_F40GrvSE5(nOpc,lDesdobr,cBcoAdt,cAgeAdt,cCtaAdt,nRecSe1,aAutoCab)

    Local lRet       As Logical
    Local lMovFinBS  As Logical
    Local nZ         As Numeric

    lRet      := .T.
    nZ := ASCAN(aAutoCab, {|x| x[1] == "GERFINBS"})
    lMovFinBS := IIF(nZ > 0, aAutoCab[nZ,2], .T.)
    If lMovFinBS
        F040GrvSE5(nOpc,lDesdobr,cBcoAdt,cAgeAdt,cCtaAdt,nRecSE1)
    EndIf

Return (lRet) /*------------------------------------------------------RU06XFUN63_F40GrvSE5*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN64_AddLinkToAR

Adds field to aBaixaSE5 to link the write-off to specific account receivables
This function called from FINA070.
This function involved in process of Innflow Bank statement financial posting.

@param       Array            aBaixaSE5
             Character        cNumero
             Character        cOrdRec
             Character        cSerRec
             Logical          lRaRtImp
@return      Nil
@example     
@author      astepanov
@since       March/10/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN64_AddLinkToAR(aBaixaSE5,cNumero,cOrdRec,cSerRec,lRaRtImp)
    AADD(aBaixaSE5,{ SE5->E5_PREFIXO , cNumero         , SE5->E5_PARCELA , SE5->E5_TIPO   ,;
                     SE5->E5_CLIFOR  , SE5->E5_LOJA    , SE5->E5_DATA    , SE5->E5_VALOR  ,;
                     SE5->E5_SEQ     , SE5->E5_DTDISPO , SE5->E5_BANCO   , SE5->E5_AGENCIA,;
                     SE5->E5_CONTA   , SE5->E5_VLJUROS , SE5->E5_VLMULTA , SE5->E5_VLDESCO,;
                     SE5->E5_VLCORRE , SE5->E5_VRETPIS , SE5->E5_VRETCOF , SE5->E5_VRETCSL,;
                     SE5->E5_PRETPIS , SE5->E5_PRETCOF , SE5->E5_PRETCSL , SE5->E5_MOEDA  ,;
                     SE5->E5_TIPODOC , AllTrim(SE5->E5_FORMAPG)          , cOrdRec        ,;
                     cSerRec         , SE5->E5_MOTBX   , SE5->E5_VRETIRF , SE5->E5_PRETIRF,;
                     If(lRaRtImp, SE5->E5_PRISS,0)     , If(lRaRtImp, SE5->E5_PRINSS,0)   ,;
                     SE5->E5_ORDREC                                                       })
Return (Nil) /*-----------------------------------------------------RU06XFUN64_AddLinkToAR*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN65_FI040TrackBS

This function called from FINA04 and added to aRotina in MenuDef() of FINA040.
It is used to show all Bank statements related to currently selected AR.
For properly work, cursor should be positioned on correct SE1 line.

@private     aRotina, oPQDlgRU06
@return      Nil
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN65_FI040TrackBS()

    Local aFldList   As Array
    Local aFields    As Array
    Local aArea      As Array
    Local aColumns   As Array
    Local aSize      As Array
    Local aTmpRot    As Array
    Local nX         As Numeric
    Local nStat      As Numeric
    Local oTmp       As Object
    Local oBrwsInfBS As Object
    Local cQuery     As Character
    Local cInsFld    As Character
    Local cKey       As Character
    Local cHlpMsg    As Character
    Local cAlias     As Character

    Private oPQDlgRU06 As Object

    aArea    := GetArea()
    cHlpMsg  := ""
    cKey     := SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+;
                SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+;
                SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
    cKey     := PADR(cKey,GetSX3Cache("F5M_KEY","X3_TAMANHO"), " ")
    //F4C_CUSNAM field is virtual
    aFldList := {"F4C_FILIAL", "F4C_INTNUM", "F4C_DTTRAN",;
                 "F4C_CUST"  , "F4C_CUNI"  , "F4C_CUSNAM",;
                 "F5M_VALPAY"                              }
    aFields  := {}
    cInsFld  := ""
    cSlcFld  := ""
    // aFields: {{field_name,tipo,tamanho,decimal,picture,title}}
    // cInsFld " F4C_FILIAL, F4C_INTNUM ...... "
    For nX := 1 To Len(aFldList)
        AADD(aFields, { aFldList[nX],;
                        GetSX3Cache(aFldList[nX], "X3_TIPO"   ),;
                        GetSX3Cache(aFldList[nX], "X3_TAMANHO"),;
                        GetSX3Cache(aFldList[nX], "X3_DECIMAL"),;
                        GetSX3Cache(aFldList[nX], "X3_PICTURE"),;
                        RetTitle(aFldList[nX]);
                       }                                        )
        If     aFldList[nX] == "F5M_VALPAY"
            cSlcFld += aFldList[nX] + ", "
        ElseIf aFldList[nX] == "F4C_CUSNAM"
            cSlcFld += "COALESCE(A1_NOME,'') AS "+aFldList[nX]+", "
        Else
            cSlcFld += "COALESCE("+aFldList[nX]+",'') AS "+aFldList[nX]+", "
        EndIf
        cInsFld += aFldList[nX] + ", "
    Next nX
    cSlcFld := SubStr(cSlcFld,1,Len(cSlcFld)-2)
    cInsFld := SubStr(cInsFld,1,Len(cInsFld)-2)
    cAlias  := CriaTrab(,.F.)
    oTmp := FWTemporaryTable():New(cAlias)
    oTmp:SetFields(aFields)
    oTmp:AddIndex(cAlias+"1",{"F4C_FILIAL", "F4C_INTNUM"})
    oTmp:Create()
    cQuery := " SELECT " + cSlcFld + "                              "
    cQuery += " FROM                                                "
    cQuery += "      ( SELECT *                                     "
    cQuery += "        FROM " + RetSqlName("F5M") + "               "
    cQuery += "        WHERE F5M_KEY    = '" + cKey + "'            "
    cQuery += "          AND F5M_KEYALI = 'SE1'                     "
    cQuery += "          AND D_E_L_E_T_ = ' '                       "
    cQuery += "      )                              F5M             "
    cQuery += " LEFT JOIN " + RetSqlName("F4C") + " F4C             "
    cQuery += "        ON F4C.F4C_FILIAL = '" + xFilial("F4C") + "' "
    cQuery += "       AND F4C.F4C_CUUID  = F5M.F5M_IDDOC            "
    cQuery += "       AND F4C.D_E_L_E_T_ = ' '                      "
    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1             "
    cQuery += "        ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
    cQuery += "       AND SA1.A1_COD     = F4C.F4C_CUST             "
    cQuery += "       AND SA1.A1_LOJA    = F4C.F4C_CUNI             "
    cQuery += "       AND SA1.D_E_L_E_T_ = ' '                      "
    cQuery := ChangeQuery(cQuery)
    cQuery := "INSERT INTO " + oTmp:GetRealName() +;
              "          ( " + cInsFld            + ") " + cQuery
    nStat  := TCSqlExec(cQuery)
    If nStat >= 0
        DBSelectArea(oTmp:GetAlias())
        DBGoTop()
        If !EoF()
            aColumns := {}
            For nX := 1 To Len(aFields)
                AADD(aColumns, FWBrwColumn():New())  
                aColumns[nX]:SetData(&("{||"+aFields[nX][1]+"}"))
                aColumns[nX]:SetTitle(aFields[nX][6])
                aColumns[nX]:SetSize(aFields[nX][3])
                aColumns[nX]:SetDecimal(aFields[nX][4])
                aColumns[nX]:SetPicture(aFields[nX][5]) 
            Next nX
            aSize  := MsAdvSize()
            oPQDlgRU06 := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5],;
                                        STR0069, , , , ,; //Bank statements
                                        CLR_BLACK, CLR_WHITE, , ,;
                                        .T., , , , .T.                         )
            
            oBrwsInfBS := FWMBrowse():New()
            oBrwsInfBS:SetAlias(oTmp:GetAlias())
            oBrwsInfBS:SetOwner(oPQDlgRU06)
            oBrwsInfBS:SetColumns(aColumns)
            aTmpRot  := IIF(aRotina == Nil, Nil, ACLONE(aRotina))
            aRotina  := RU06XFUN66_FI040TBSMenu() //Reset global aRotina
            oBrwsInfBS:SetMenuDef("RU06XFUN66_FI040TBSMenu")
            oBrwsInfBS:Activate()
            oPQDlgRU06:Activate(,,,.T.,,,)
            aRotina  := aTmpRot //Return aRotina
        Else
            cHlpMsg := STR0070 // no BS for this AR
        EndIf
    Else
        cHlpMsg += " TCSQLError() " + TCSQLError()
    EndIf
    If !Empty(cHlpMsg)
        Help("",1,STR0071,,cHlpMsg,1,0) //Information
    EndIf
    If !Empty(oTmp:GetAlias())
       DBSelectArea(oTmp:GetAlias())
       DBCloseArea()
    EndIf
    oTmp:Delete()
    RestArea(aArea)

Return (Nil) /*----------------------------------------------------RU06XFUN65_FI040TrackBS*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN66_FI040TBSMenu
This function returm menu items for oPQDlgRU06
@private     aRotina, oPQDlgRU06
@return      aRet     // Menu for oPQDlgRU06
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Static Function RU06XFUN66_FI040TBSMenu()

    Local aRet As Array
    aRet := {{ STR0072, "RU06XFUN67_FI040TBS_VIEW()", 0, 2, 0, Nil},; //view
             { STR0012, "oPQDlgRU06:End()"          , 0, 1, 0, Nil} } //cancl
Return (aRet) /*---------------------------------------------------RU06XFUN66_FI040TBSMenu*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN67_FI040TBS_VIEW
This function open Bank Statement for view
Alias of the current area should be equal to oTmp:GetAlias() from RU06XFUN65_FI040TrackBS
@return      Nil
@example     
@author      astepanov
@since       April/23/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN67_FI040TBS_VIEW()
    
    Local aArea    As Array
    Local cAlias   As Character
    Local cKey     As Character

    aArea := GetArea()
    cAlias := aArea[1]
    cKey   := (cAlias)->F4C_FILIAL + (cAlias)->F4C_INTNUM +;
              DTOS((cAlias)->F4C_DTTRAN)
    DBSelectArea("F4C")
    DBSetOrder(1)
    If DBSeek(cKey)
        RU06D0710_Act(1)
    EndIf
    RestArea(aArea)

Return (Nil) /*---------------------------------------------------RU06XFUN67_FI040TBS_VIEW*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN68_CheckAReversalOfRecivableAdvance

Function Used to Check If the write-off of this bill was generated 
by a Reversal of an advance recivable in bank statement
For correct work we should be positioned on correct SE1 record

We are able to use the AR type NF the way we want after we revert the bank statement 
but we cannot use the AR type RA created by it so we need to change the behavior in the 
routine FINA070 and don`t allow that the user can cancel this the write-off of this 
accounts receivables advanced when it is linked with a bank statement 
Reversed or Replaced and Reversed.

@param       Character        cKey //String with the key to find the BIL in this operation
                                   //filial+prefixo+num+parcela+tipo+cliente+loja for SE1
@return      Logical          lRet //Returns if the Write off of this bill was generated 
                                   //by Reversal RA Bank Statement Process, .T. - means
                                   //generated by Bank tsatement
@example     
@author      astepanov
@since       April/24/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN68_CheckAReversalOfRecivableAdvance(cKey)
    Local lRet       As Logical
    Local aArea      As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local cFK7Chave  As Character
    lRet := .F.
    aArea := GetArea()
    /*Check if it`s a RA and if the BILL was generated in the Bank Statement Process--*/
    If AllTrim(SE1->E1_TIPO) == "RA" .AND. AllTrim(SE1->E1_ORIGEM) == "RU06D07"
        cFK7Chave := PADR(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+;
                          SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+;
                          SE1->E1_LOJA,GetSX3Cache("FK7_CHAVE", "X3_TAMANHO"), " " )
        cQuery := " SELECT FK7.FK7_CHAVE                             "
        cQuery += " FROM                                             "
        cQuery += "    ( SELECT FK7_CHAVE, FK7_IDDOC                 "
        cQuery += "      FROM   " + RetSQlName("FK7") + "            "
        cQuery += "      WHERE FK7_FILIAL = '" + xFilial("FK7") + "' "
        cQuery += "        AND FK7_CHAVE  = '" +    cFK7Chave   + "' " 
        cQuery += "        AND D_E_L_E_T_ = ' '                      " 
        cQuery += "    )                                       FK7   "
        cQuery += " INNER JOIN                                       "
        cQuery += "    ( SELECT FK1_IDDOC                            "
        cQuery += "      FROM   " + RetSQlName("FK1") + "            "
        cQuery += "      WHERE FK1_FILIAL = '" + xFilial("FK1") + "' "
        cQuery += "        AND FK1_MOTBX  = 'DAC'                    "
        cQuery += "        AND FK1_ORIGEM = 'RU06D07'                "
        cQuery += "        AND D_E_L_E_T_ = ' '                      "
        cQuery += "    )                                       FK1   "
        cQuery += " ON  FK1.FK1_IDDOC = FK7.FK7_IDDOC                "
        cQuery := ChangeQuery(cQuery)
        cTab   := MPSysOpenQuery(cQuery)
        DBSelectArea(cTab)
        DBGoTop()
        If (cTab)->(!eof())
            lRet := .T.
        EndIf
        (cTab)->(DBCloseArea())
    EndIf
    RestArea(aArea)
Return (lRet) /*-------------------------------RU06XFUN68_CheckAReversalOfRecivableAdvance*/


//-----------------------------------------------------------------------
/*/{Protheus.doc} FINA04001_VATCalc(RUSSIAN FUNCTION NAME)

Function calculates and returns:
								tax amount in case of VALIMP
								tax base in case of BASIMP
								0 otherwise
General Rule for indirect tax calculation:

	TaxAmount = TaxBase * (TaxRate / 100)
	GrossTotalWithTax = TaxBase + TaxAmount

[Business Cases for Russia, INCLUI == True, cPaisLoc == 'RUS']
1st case: 
User changes TaxRate or GrossTotalWithTax, so we should call this 
function 2 times: 
1: param = BASIMP, (TaxBase will be changed)
2: param = VALIMP, (TaxAmount will be changed)
2nd case:
User changes TaxBase, so we call this function 1 time:
1: param = VALIMP, (TaxAmount will be changed)
In this case we don't control TaxRate,
this routine should be implemented additionaly.
And we don't control situation when GrossTotalWithTax < TaxBase, in
this condition function returns negative number.

@param       CHARACTER cField   {VALIMP;BASIMP;...}
@return      NUMERIC   nRet     {min(NUMERIC)..max(NUMERIC)}
@examples   
@author      astepanov
@since       November/13/2018
@version     1.0
@project     MA3
@see         FI-CF-23-5
/*/
//-----------------------------------------------------------------------
Function FINA04001(cField)

    Local    nRet     As NUMERIC
    Local	 nGrosTot As NUMERIC //Gross total with a tax >= 0
    Local	 nTaxBase As NUMERIC //Tax base >= 0
    Local    nTaxRate As NUMERIC //Tax rate >= 0 
    
    Default  cField := ''
    nGrosTot := M->E1_VALOR
    nTaxBase := M->E1_BASIMP1
    nTaxRate := M->E1_ALQIMP1

    If cPaisLoc == 'RUS' .and.;
    INCLUI            .and.;
    !Empty(nGrosTot)
            Do Case
                Case cField == 'BASIMP'
                    If nTaxRate == 0
                        nRet := nGrosTot
                    Else
                        nRet := (nGrosTot * 100)/(100 + nTaxRate)
                    EndIf
                Case cField == 'VALIMP'
                    nRet := (nGrosTot - nTaxBase)
                OtherWise
                    nRet := 0
            EndCase
    Else
        nRet := 0
    EndIf

Return nRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} FINXFIN03_FlView(Russian Name)

This function excludes fields from SE1(SE2) View.
Function gets cAlias to current selected Area, if it equals SE1(SE2) 
function returns field array, otherwise returns Nil

@param       CHARACTER cAlias
@return      ARRAY     aFields .or. NIL
@author      astepanov
@since       November/27/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function FINXFIN03(cAlias)
	Local aFields    AS ARRAY
	Local aExcField  AS ARRAY
	Local cFieldName AS CHARACTER
	Local cQuery	 AS CHARACTER
	Local cAliasQry	 AS CHARACTER
	Local nPos       AS NUMERIC
	Local nFieldPos  As NUMERIC 

	aFields := {}
	cAliasQry := GetNextAlias()

	If cAlias != Nil
		cQuery := "SELECT X3_CAMPO FROM " + RetSQLName("SX3") + " WHERE X3_ARQUIVO = '" + cAlias + "' AND D_E_L_E_T_  = ' '"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		While !(cAliasQry)->(Eof()) 
			AADD(aFields, AllTrim((cAliasQry)->X3_CAMPO))
			(cAliasQry)->(dbSkip())
		EndDo 
		(cAliasQRY)->(dbCloseArea())
	EndIf

	aExcField := {}
	Do Case  //#2 Fills array by fields for exclusion
		Case aFields != Nil .and. cAlias == "SE1"
			AADD(aExcField, "E1_FILDEB" )
			AADD(aExcField, "E1_FABOV"  )
			AADD(aExcField, "E1_FACS"   )
			AADD(aExcField, "E1_INSTR1" )
			AADD(aExcField, "E1_INSTR2" )
			AADD(aExcField, "E1_DTACRED")
			AADD(aExcField, "E1_BCOCLI" )
			AADD(aExcField, "E1_OCORREN")
			AADD(aExcField, "E1_NODIA"  )
			AADD(aExcField, "E1_DIACTB" )
			AADD(aExcField, "E1_PROJPMS")
			AADD(aExcField, "E1_CODORCA")
			AADD(aExcField, "E1_CODIMOV")
			AADD(aExcField, "E1_NUMCRD" )
			AADD(aExcField, "E1_TXMDCOR")
			AADD(aExcField, "E1_MDCRON" )
			AADD(aExcField, "E1_MDCONTR")
			AADD(aExcField, "E1_MEDNUME")
			AADD(aExcField, "E1_MDPLANI")
			AADD(aExcField, "E1_MDPARCE")
			AADD(aExcField, "E1_MDREVIS")
			AADD(aExcField, "E1_NUMMOV" )
			AADD(aExcField, "E1_BOLETO" )
			AADD(aExcField, "E1_NUMPRO" )
			AADD(aExcField, "E1_INDPRO" )
			AADD(aExcField, "E1_RETCNTR")
			AADD(aExcField, "E1_MDDESC" )
			AADD(aExcField, "E1_MDBONI" )
			AADD(aExcField, "E1_MDMULT" )
			AADD(aExcField, "E1_TURMA"  )
			AADD(aExcField, "E1_TCONHTL")
			AADD(aExcField, "E1_CONHTL" )
		//-} aFields != Nil .and. cAlias == "SE1"
		Case aFields != Nil .and. cAlias == "SE2"
			AADD(aExcField, "E2_VBASISS")
			AADD(aExcField, "E2_APLVLMN")
			AADD(aExcField, "E2_NODIA"  )
			AADD(aExcField, "E2_DIACTB" )
	End Case //#2
	Do Case  //#3 Excludes fields for viewing 
		Case aFields != Nil .and. Len(aExcField) > 0
			For nPos := 1 To Len(aExcField)
				nFieldPos    := AScan(aFields, {|cFieldName| cFieldName == aExcField[nPos]})
				If nFieldPos != 0 
					ADel(aFields,nFieldPos)
				End If
			Next
	End Case //#3
Return aFields //End FINXFIN03_FlView



//-------------------------------------------------------------------------------------------------------------
// Revitalização FINA050
// Funções exclusivas da localização RUS - Movidas por não ter cobertura da automação para essa localização
//-------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------
/*/{Protheus.doc} R604Is48

@author TOTVS S/A

@since 01/01/2018
@version P12
/*/
//-------------------------------------------------------
Function R604Is48(cFilOrig,cPrefix,cNUm,cParcel,cTipo,cForn,cLoj)
	
    Local lRet As Logical // if bill included in Payment Request
	Local cQuery As Character
	Local nStatus As Numeric
	Local aArea As Array

	aArea := GetArea()

	cQuery	:= "SELECT F48.F48_FLORIG, F48.F48_PREFIX, F48.F48_NUM, F48.F48_PARCEL, F48.F48_TYPE, F47.F47_SUPP, F47.F47_UNIT, F47.F47_CODREQ "
	cQuery	+= "FROM " + RetSQLName("F48") +" F48 INNER JOIN " +  RetSQLName("F47") + " F47 "
	cQuery	+= " ON F48.F48_IDF48 = F47.F47_IDF47 "
	cQuery	+= " WHERE F48.F48_FILIAL = '" + xFilial("F48") + "' AND F48.F48_FLORIG = '" + cFilOrig + "'"
	cQuery	+= " AND F48.F48_PREFIX = '" + cPrefix + "'"
	cQuery	+= " AND F48.F48_NUM = '" + cNUm + "'"
	cQuery	+= " AND F48.F48_PARCEL = '" + cParcel + "'"
	cQuery	+= " AND F48.F48_TYPE = '" + cTipo + "'"
	cQuery	+= " AND F47.F47_SUPP = '" + cForn + "'"
	cQuery	+= " AND F47.F47_UNIT = '" + cLoj + "'"
	cQuery	+= " AND F47.D_E_L_E_T_ = ' '  AND F48.D_E_L_E_T_ = ' ' "

	nStatus := TCSqlExec(cQuery)
	cQuery := ChangeQuery(cQuery)
	If select("TMPFIL") > 0
		TMPFIL->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPFIL", .T., .F.)
	If !(TMPFIL->(Eof()))
		lRet:=.T.
	Else
		lRet:=.F.
	EndIf
	RestArea(aArea)

Return (lRet)


//-------------------------------------------------------
/*/{Protheus.doc} FIN50PQBrw

@author TOTVS S/A

@since 01/01/2018
@version P12
/*/
//-------------------------------------------------------
Function FIN50PQBrw(cDoc) 
	Local aSize     As Array
	Local aStr      As Array // Structure to show
	Local aColumns  As Array
	Local nX        As Numeric 
	Local cTitle    As Character
	Local cWinHeader as Character
	Local cErrorMsg as Character
	
	Private oPQDlg    As object
	Private oBrowsePut  As object
	Private oTmpPQs  As Object
	Private cTmpPQs    As character
	Private cMark   As character
	Private	lOneline	As Logical
	
	Default cDoc:='PR' // PR - paymnnt request, PO - payment order
	aSize	:= MsAdvSize()
	nX:=0
	cTmpPQs	:= CriaTrab(,.F.)
	aStr	:= {}
	aColumns 	:= {}
	cTitle:=""
	cErrorMsg:=''
	cWinHeader:=''
	lOneline	:= .F.
	
	// Create temporary table
	if cDoc=='PR'
		aStr:={"F47_FILIAL", "F47_CODREQ", "F47_DTREQ", "F47_SUPP", "F47_UNIT", "F47_VALUE", "F47_PRIORI", "CTO_DESC"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0076    //"Solicitações de pagamento"
		cErrorMsg:= STR0077  //"Any Payment Requests cannot be found for this bill"                                                                                                                                                                                                                                                                                                                                                                                                                                                                
	ElseIf cDoc=='PO'
		aStr:={"F49_FILIAL", "F49_PAYORD", "F49_DTPAYM", "F49_SUPP", "F49_UNIT", "F49_VALUE", "F49_DTACTP", "CTO_DESC"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0078 // Paymnet Order
		cErrorMsg:= STR0079  //"No payment orders are found for this AP"                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	ElseIf cDoc == 'BS'
		aStr:={"F4C_FILIAL", "F4C_INTNUM", "F4C_DTTRAN", "F4C_DTPAYM", "F4C_PREPAY", "F4C_BNKPAY", "F4C_CNT", "F4C_CLASS", "F4C_VALUE", "F4C_REASON"}
		MsgRun(STR0007,STR0008,{|| PQCreaTRB(cDoc, aStr)}) //"Please wait"//"Creating temporary table"
		cWinHeader:= STR0080 // "Bank Statements"
		cErrorMsg:=STR0081	//"No Bank Statements are found for this AP"
	EndIf
	
	If ((cTmpPQs)->(Eof()))
		Help("",1,cWinHeader,,cErrorMsg,1,0) // FINA 050 -- Can not find any Payment Requests for this bill
	ElseIf cDoc == "BS" .And. lOneline
		FINA50OkBr("BS")
	Else
		For nX := 1 TO  Len(aStr)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStr[nX])) 
			aColumns[Len(aColumns)]:SetSize(GetSX3Cache(aStr[nX], "X3_TAMANHO")) 
			aColumns[Len(aColumns)]:SetDecimal(GetSX3Cache(aStr[nX], "X3_DECIMAL"))
			aColumns[Len(aColumns)]:SetPicture(GetSX3Cache(aStr[nX], "X3_PICTURE")) 
		Next nX
	
		oPQDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5], cWinHeader, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // PQs or POs
	
		oBrowsePut := FWMBrowse():New()
		oBrowsePut:SetAlias(cTmpPQs)
		oBrowsePut:SetOwner(oPQDlg)
		oBrowsePut:SetColumns(aColumns)
		aRotina	 := FIN50BrMen(cDoc) //Reset global aRotina
		oBrowsePut:SetMenuDef("FIN50BrMen")
			
		oBrowsePut:Activate()
		oPQDlg:Activate(,,,.T.,,,)
	
		If !Empty (cTmpPQs)
			dbSelectArea(cTmpPQs)
			dbCloseArea()
			cTmpPQs := ""
			dbSelectArea("SE2")
			dbSetOrder(1)
		EndIf
	
		If oTmpPQs <> Nil
			oTmpPQs:Delete()
			oTmpPQs := Nil
	
		Endif
	EndIf 
	
return (.T.)
	
	
	
//-------------------------------------------------------
/*/ PQCreaTRB

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Static Function PQCreaTRB(cDoc, aStr)
	Local aFields   As Array
	local cQuery    As Character
	Local cSupp     As Character
	Local cUnit     As Character
	Local cPrefix	As Character
	Local cNum		As Character
	Local cParcel	As Character
	Local cType		As Character
	Local nX 		As Numeric
	Local cF5MKey	As Character
	Local cF4CUID	As Character
    Local cFields   As Character
    	
	Default cDoc:='PR'
	Default aStr:={}

    cFields := ''
	cPrefix :=SE2->E2_PREFIXO
	cNum    :=SE2->E2_NUM
	cParcel :=SE2->E2_PARCELA
	cType   :=SE2->E2_TIPO
	cSupp   :=SE2->E2_FORNECE
	cUnit   :=SE2->E2_LOJA
	
	/* Object creation*/
	oTmpPQs := FWTemporaryTable():New(cTmpPQs)
	
	// Table fields - structure
	aFields := {}
	For nX := 1 TO  Len(aStr)
		aadd(aFields, {aStr[nX]	, GetSX3Cache(aStr[nX], "X3_TIPO"), GetSX3Cache(aStr[nX], "X3_TAMANHO"), GetSX3Cache(aStr[nX], "X3_DECIMAL")})
        cFields += Iif(empty(cFields),aStr[nX],','+aStr[nX]) //fields for select and insert
	Next nX
	
	If cDoc=='PO'
		aadd(aFields, {"F49_BNKORD"	, GetSX3Cache("F49_BNKORD", "X3_TIPO"), GetSX3Cache("F49_BNKORD", "X3_TAMANHO"), GetSX3Cache("F49_BNKORD", "X3_DECIMAL")})
        cFields += ',F49_BNKORD'
	ElseIf cDoc == "BS"
		aadd(aFields, {"F4C_CUUID"	, GetSX3Cache("F4C_CUUID", "X3_TIPO"), GetSX3Cache("F4C_CUUID", "X3_TAMANHO"), GetSX3Cache("F4C_CUUID", "X3_DECIMAL")})
        cFields += ',F4C_CUUID'
	EndIf
	
	oTmpPQs:SetFields(aFields)
	if cDoc=='PR'
		oTmpPQs:AddIndex("Indice2", {"F47_FILIAL", "F47_CODREQ"} )
	ElseIf cDoc=='PO'
		oTmpPQs:AddIndex("Indice2", {"F49_FILIAL", "F49_PAYORD"} )
	ElseIf cDoc=='BS'
		oTmpPQs:AddIndex("Indice2", {"F4C_FILIAL", "F4C_INTNUM"} )
		cF5MKey := xFilial("SE2") + "|" + cPrefix + "|"+ cNum + "|" + cParcel + "|"+ cType +"|" + cSupp + "|" + cUnit 
	EndIf
	
	// Table creation - data
	oTmpPQs:Create()
	
	if cDoc=='PR'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName() +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F47") + " F47 "
		cQuery += " INNER JOIN " + RetSQLName("CTO") + " CTO ON (F47_CURREN=CTO_MOEDA and CTO_FILIAL = '" + xFILIAL("F47",CTO->CTO_FILIAL) + "') "
		cQuery += " INNER JOIN " + RetSQLName("F48") + " F48 ON (F47_IDF47=F48_IDF48 and F48_FILIAL = '" + xFILIAL("F48") + "') "
		cQuery += " WHERE F47.D_E_L_E_T_ =' ' AND F48.D_E_L_E_T_=' '  AND CTO.D_E_L_E_T_=' '" 
		cQuery += " AND F48_PREFIX = '" + cPrefix + "'"
		cQuery += " AND F48_NUM  = '" +  cNum  + "'"
		cQuery += " AND F48_PARCEL = '" + cParcel +"'"
		cQuery += " AND F48_TYPE = '" + cType +"'"
		cQuery += " AND F47_SUPP = '" + cSupp +"'"
		cQuery += " AND F47_UNIT = '" + cUnit +"'"
	ElseIf cDoc=='PO'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName()  +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F49") + " F49 "
		cQuery += " INNER JOIN " + RetSQLName("CTO") + " CTO ON (F49_CURREN=CTO_MOEDA and CTO_FILIAL = '" + xFILIAL("F49",CTO->CTO_FILIAL) + "') "
		cQuery += " INNER JOIN " + RetSQLName("F4B") + " F4B ON (F4B_IDF49=F49_IDF49 and F4B_FILIAL = '" + xFILIAL("F4B") + "') "
		cQuery += " WHERE F49.D_E_L_E_T_ =' ' AND F4B.D_E_L_E_T_=' ' AND CTO.D_E_L_E_T_=' '" 
		cQuery += " AND F4B_PREFIX = '" + cPrefix + "'"
		cQuery += " AND F4B_NUM  = '" +  cNum  + "'"
		cQuery += " AND F4B_PARCEL = '" + cParcel +"'"
		cQuery += " AND F4B_TYPE = '" + cType +"'"
		cQuery += " AND F49_SUPP = '" + cSupp +"'"
		cQuery += " AND F49_UNIT = '" + cUnit +"'"
	ElseIf cDoc=='BS'
		cQuery := "INSERT INTO " + oTmpPQs:GetRealName()  +" (" + cFields + ") "
		cQuery += " SELECT " + cFields
		cQuery += " FROM " + RetSQLName("F4C") + " F4C "
		cQuery += " INNER JOIN " + RetSQLName("F5M") + " F5M ON (F5M_IDDOC=F4C_CUUID and F5M_FILIAL = '" + xFILIAL("F5M") + "') "
		cQuery += " WHERE F4C.D_E_L_E_T_ =' ' AND F5M.D_E_L_E_T_=' '"
		cQuery += " AND F5M_KEY like '" + cF5MKey + "%' and F5M_ALIAS='F4C' "
	EndIf
	
    //cQuery := ChangeQuery(cQuery)     //Change query here create a SQL statment wrong with two select that became invalid return error -19 at TCSqlExec
	TCSqlExec(cQuery)
	
	DbSelectArea(cTmpPQs) 
	DbGotop()
	
	If cDoc == "BS"
		lOneline := (cTmpPQs)->(!Eof())
		If lOneline
			cF4CUID := (cTmpPQs)->F4C_CUUID
			DbGoBottom()
			lOneline := cF4CUID == (cTmpPQs)->F4C_CUUID
		EndIf
		DbGotop()
	EndIf
	
Return (NIL)
	
//-------------------------------------------------------
/*/ FIN50BrMen

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Static Function FIN50BrMen(cDoc)
	Local aRet As Array
	
	Default cDoc:='PR'
	aRet := {}
	aAdd(aRet, {STR0072, "FINA50OkBr('"+cDoc+"')", 0, 2, 0, Nil})	//Ok
	aAdd(aRet, {STR0012, "FIN50ClBr()", 0, 1, 0, Nil})		//Cancel

Return (aRet)

//-------------------------------------------------------
/*/ FIN50ClBr

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Function FIN50ClBr()
	oPQDlg:End()
Return .F.

//-------------------------------------------------------
/*/ FINA50OkBr

@author TOTVS S/A

@since 01/01/2018
@version P12
*/
//-------------------------------------------------------
Function FINA50OkBr(cDoc)
    Local aEnableButtons As Array
    Local aArea As Array
    Local cKey As Character
    Local cHeadArea		As Character 
    Local cProgName		As Character
    Local nHeadIndex	As Numeric

    Default cDoc:='PR'

    aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0012},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Hide the standart options of the Form 
    aArea := (cTmpPQs)->(GetArea())	

    If cDoc == 'PR'
        cKey:=(cTmpPQs)->F47_FILIAL+(cTmpPQs)->F47_CODREQ
        cHeadArea := "F47"
        nHeadIndex := 1
        cProgName := "RU06D04"
    ElseIf cDoc == 'PO'
        cKey:=(cTmpPQs)->F49_FILIAL+(cTmpPQs)->F49_PAYORD+(cTmpPQs)->F49_BNKORD+DTOS((cTmpPQs)->F49_DTPAYM)
        cHeadArea := "F49"
        nHeadIndex := 1
        cProgName := "RU06D05"
    ElseIf cDoc == 'BS'
        //F4C_FILIAL+F4C_INTNUM+DTOS(F4C_DTTRAN)
        cKey:=(cTmpPQs)->F4C_FILIAL+(cTmpPQs)->F4C_INTNUM+DTOS((cTmpPQs)->F4C_DTTRAN)
        cHeadArea := "F4C"
        nHeadIndex := 1
    EndIf

    dbSelectArea(cHeadArea)
    &(cHeadArea)->(DbSetOrder(nHeadIndex))

    If &(cHeadArea)->(DbSeek(cKey))
        If cDoc == "BS" 
            RU06D0710_Act(MODEL_OPERATION_VIEW)
        Else
            FWExecView( STR0072, cProgName, MODEL_OPERATION_VIEW, /*oDlg*/,/*/ {|| .T. }/*/ ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ ) // Payment Request - View
        EndIf
    EndIf

    &(cHeadArea)->(DbCloseArea())
    RestArea(aArea)
Return Nil

//-------------------------------------------------------
/*/ FINA05001_VATCalc(Russian Function Name)

@author natalia.khozyainova
@since 16/10/2018
@version P12
*/
//-------------------------------------------------------
Function FINA05001_(cField)
    Local nRet as Numeric
    Default cField:=''
    nRet:=0

    If cPaisLoc=='RUS' .and. INCLUI
        If !Empty(M->E2_ALQIMP1) .and. !Empty(M->E2_VALOR)
            If cField=='BASIMP'
                nRet:= (M->E2_VALOR *100) / (100 + M->E2_ALQIMP1)
            ElseIf cField == 'VALIMP'
                nRet:= M->E2_VALOR - M->E2_BASIMP1
            EndIf
        EndIf
    EndIf

Return nRet




//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN69_F340VlCrVl
Function for validation for Value to clear.

@return lRet

@author Cherchik Konstantin
@since  18/09/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN69_F340VlCrVl(nValor,nSaldo,cHelp)
	Local lRet 		as Logicaly
	Local nOpenBal	as Numeric
	Local cSe2Key	as Character

	lRet		:= .F.
	cSe2Key		:= SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
	nOpenBal	:= RU06XFUN06(cSe2Key) // Open balance from F5M //RU06XFUN06_GetOpenBalance

	If !Empty(nValor) .And. !Empty(nSaldo)
		If nValor <= nOpenBal	//nSaldo
			lRet := .T.
		Else
            Help("",1,"FA340ValClrVld",,cHelp,1,0)
		EndIf
	EndIf

Return lRet




//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN70_FA340Filte
Filter for AP list

@author Cherchik Konstantin
@since  02/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN70_FA340Filte(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cMsg,cTitMsg)
	Local cPerg		as Character
	Local lRet		as Logical
	Local aFilter as Array

	lRet	:=.F.
	cPerg	:=""
	lFilMark:= MsgYesNo(cMsg,cTitMsg)

	If lFilMark
		cPerg := "AF3401"
		lRet  := Pergunte(cPerg,.T.,cTitMsg)
		If lRet
			cTitFilt := ""
			aFilter := {}
			Aadd(aFilter, MV_PAR01)	//From E2_PREFIXO
			Aadd(aFilter, MV_PAR02)	//To E2_PREFIXO
			Aadd(aFilter, MV_PAR03)	//From E2_NUM
			Aadd(aFilter, MV_PAR04)	//To E2_NUM
			Aadd(aFilter, MV_PAR05)	//From E2_TIPO
			Aadd(aFilter, MV_PAR06)	//To E2_TIPO
			Aadd(aFilter, MV_PAR07)	//From E2_MOEDA
			Aadd(aFilter, MV_PAR08)	//To E2_MOEDA
			Aadd(aFilter, MV_PAR09)	//From E2_FORNECE
			Aadd(aFilter, MV_PAR10)	//To E2_FORNECE
			Aadd(aFilter, MV_PAR11)	//From E2_F5QCODE
			Aadd(aFilter, MV_PAR12)	//To E2_F5QCODE
			Aadd(aFilter, MV_PAR13)	//From E2_EMISSAO
			Aadd(aFilter, MV_PAR14)	//To E2_EMISSAO
			Aadd(aFilter, MV_PAR15)	//From E2_VENCTO
			Aadd(aFilter, MV_PAR16)	//To E2_VENCTO
			Pergunte("AFI340",.F.)

			cTitFilt += " AND SE2.E2_PREFIXO >= '" + aFilter[1] + "' AND SE2.E2_PREFIXO <= '" + aFilter[2] + "'" 
			cTitFilt += " AND SE2.E2_NUM >= '" + aFilter[3] + "' AND SE2.E2_NUM <= '" + aFilter[4] + "'"
			cTitFilt += " AND SE2.E2_TIPO >= '" + aFilter[5] + "' AND SE2.E2_TIPO <= '" + aFilter[6] + "'"
			cTitFilt += " AND SE2.E2_MOEDA >= " + AllTrim(Str(aFilter[7])) + " AND SE2.E2_MOEDA <= " + AllTrim(Str(aFilter[8])) + ""
			cTitFilt += " AND SE2.E2_FORNECE >= '" + aFilter[9] + "' AND SE2.E2_FORNECE <= '" + aFilter[10] + "'"
			cTitFilt += " AND SE2.E2_F5QCODE >= '" + aFilter[11] + "' AND SE2.E2_F5QCODE <= '" + aFilter[12] + "'"
			cTitFilt += " AND SE2.E2_EMISSAO >= '" + DTOS(aFilter[13]) + "' AND SE2.E2_EMISSAO <= '" + DTOS(aFilter[14]) + "'"
			cTitFilt += " AND SE2.E2_VENCTO >= '" + DTOS(aFilter[15]) + "' AND SE2.E2_VENCTO <= '" + DTOS(aFilter[16]) + "'"

			Fa340TitEx(cNumCont, 0, lAutomato) //Generates Table with titles - aTitulos:
		EndIf
	EndIf

	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
		aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
		aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
		aTitulos[oTitulo:nAt,18],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
		aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
		aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
		aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
		aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()
	Pergunte("AFI340",.F.)
Return lRet


//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN71_FA340Unfil
Function to remove the filter from the listbox

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN71_FA340Unfil(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cMsg,cTitMsg)
	Local lUnfilter	as Logical

	lUnfilter := MsgYesNo(cMsg,cTitMsg)

	If lUnfilter
		cTitFilt := ""
		Fa340TitEx(cNumCont, 0, lAutomato)
		oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
				aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
				aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,14]}}
		oTitulo:Refresh()	
	EndIf
Return lUnfilter

//--------------------------------------------------------------------------
/*/{Protheus.doc}FA340Sort
Sorting for AP list

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN72_FA340Sort (oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cTitle,cMsg,cOpc1,cOpc2)
	Local nX		as Numeric
	Local nOpcS		as Numeric
	Local aPayTypes as Array
	Local oDlg 		as Object
	Local oCbx 		as Object 
	Local oRadio 	as Object 

	aPayTypes:= {}
	oDlg	 := Nil
	oCbx	 := Nil
	oRadio	 := Nil
	nOpcS	 :=0

	If !IsInCallStack("RU06XFUN73_F340AutMrk")
		For nX := 2 To Len(oTitulo:AHEADERS) 
			Aadd(aPayTypes, oTitulo:AHEADERS[nX]) 
		Next

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE cTitle PIXEL 
		@ 10,17 Say cMsg SIZE 150,7 OF oDlg PIXEL
		@ 27,07 TO 72, 140 OF oDlg  PIXEL
		@ 34,13 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
		@ 50,13 Radio 	oRadio VAR nRadio;
			ITEMS 	cOpc1,;	
					cOpc2;	
			SIZE 110,10 OF oDlg PIXEL
		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpcS := 1,FA340Combo(cPayType, oDlg,oCbx,@nSel))
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpcS := 0,FA340Combo(cPayType, oDlg,oCbx,@nSel))
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcS := 0, .T.)    
	EndIf

		/* Due to the fact that the arrays aTitulos & aHeaders are out of sync, the sort function must be synchronized in this form */

	DO Case
		Case nSel == 1
			cSortField := "E2_FILIAL "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[13] < y[13] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[13] > y[13] } )		
			Endif 
		Case nSel == 2
			cSortField := "E2_PREFIXO, E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
			Endif  
		Case nSel == 3
			cSortField := "E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
			Endif	  
		Case nSel == 4
			cSortField := "E2_PARCELA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
			Endif	 
		Case nSel == 5
			cSortField := "E2_TIPO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
			Endif	
		Case nSel == 6
			cSortField := "E2_MOEDA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
			Endif	 
		Case nSel == 7
			cSortField := "E2_MOEDA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
			Endif	
		Case nSel == 8
			cSortField := "E2_SALDO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
			Endif	 
		Case nSel == 9
			cSortField := "E2_NUM " // We can not sort and set "clear value"  at the same time, in column that contains values to clear.
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
			Endif	 
		Case nSel == 10
			cSortField := "E2_FORNECE "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[11] < y[11] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[11] > y[11] } )
			Endif	
		Case nSel == 11
			cSortField := "E2_NOMFOR "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[7] < y[7] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[7] > y[7] } )
			Endif	 
		Case nSel == 12
			cSortField := "E2_LOJA "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[12] < y[12] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[12] > y[12] } )
			Endif	  
		Case nSel == 13
			cSortField := "E2_F5QCODE "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
			Endif	
		Case nSel == 14
			cSortField := "E2_EMISSAO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
			Endif	  
		Case nSel == 15
			cSortField := "E2_VENCTO "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
			Endif	
		Case nSel == 16
			cSortField := "E2_VALOR "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[16] < y[16] } ) 
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )
			Endif	
		Case nSel == 17
			cSortField := "E2_VLCRUZ "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[17] < y[17] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[17] > y[17] } )
			Endif	
		Case nSel == 18
			cSortField := "E2_CONUNI "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[14] < y[14] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[14] > y[14] } )
			Endif	 
		Otherwise
			cSortField := "E2_NUM "
			If nRadio = 1
				cSortType := " ASC"
				ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
			Else
				cSortType := " DESC"
				ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
			Endif	 
	EndCase
	
	oTitulo:SetArray(aTitulos)
	oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
		aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
		aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
		aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
		aTitulos[oTitulo:nAt,18],;
		aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
		aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
		aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
		aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
		aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
		aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()	

Return nSel


//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN73_F340AutMrk
Function for Auto Mark

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function RU06XFUN73_F340AutMrk(oTitulo,aTitulos, oOk,oNo,cNumCont,lAutomato,cTitle,cMsg,cHlp)
	Local nOpcB		as Numeric
	Local oDlg 		as Object
	Local oGet01 	as Object

	nOpcB:=0
	oDlg	 := Nil
	oGet01	 := Nil	
	

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,233 TITLE cTitle PIXEL 
	@ 05,17 Say cMsg SIZE 110,7 OF oDlg PIXEL
	@ 22,07 TO 72, 100 OF oDlg  PIXEL
	@ 30,10 MSGET oGet01 VAR nValor PICTURE "@E 999,999,999.99" Valid .T. WHEN .T. PIXEL OF oDlg SIZE 70,7 HASBUTTON	


	DEFINE SBUTTON FROM 75,045 TYPE 1 ENABLE OF oDlg ACTION (nOpcB := 1,Iif(nValor >= 0 .AND. nValor <= nSaldo,oDlg:End(),EVAL({|| Help("",1,"F340VlCrVl",,cHlp,1,0) , .F. })))
	DEFINE SBUTTON FROM 75,75 TYPE 2 ENABLE OF oDlg ACTION (nOpcB := 0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcB := 0, .T.)    

	If nOpcB == 1 
		RU06XFUN72(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,nValTot) // RU06XFUN72_FA340Sort
		Fa340TitEx(cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
			aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
			aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
			aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
			aTitulos[oTitulo:nAt,18],;
			aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
			aTitulos[oTitulo:nAt,11],aTitulos[oTitulo:nAt,7],;
			aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,15],;
			aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,19],;
			aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,17],;
			aTitulos[oTitulo:nAt,14]}}
	oTitulo:Refresh()	
	Endif

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}RU06XFUN74_RetOrd
Function to encapsulate the order of titles in browse 

@author eduardo.flima
@since  07/08/2020
@version R9
/*/
//--------------------------------------------------------------------------
Function RU06XFUN74_RetFunc()
Return IsInCallStack("RU06XFUN72_FA340Sort") .Or. IsInCallStack("RU06XFUN73_F340AutMrk")





//--------------------------------------------------------------------------
/*/{Protheus.doc}FA340Combo
Function for buttons of FA340Sort

@author Cherchik Konstantin
@since  03/08/2018
@version 12
/*/
//--------------------------------------------------------------------------
Static Function FA340Combo(cPayType, oDlg,oCbx, nSel)
	nSel := oCbx:nAt
	oDlg:End()
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN75_Set_VLCRUZ
This function is called from FA050AxInc(FA040valor) function located in FINA050.PRX
(FINA040.PRX) when we post new outflow (inflow) bank statement.
We set SE2->E2_VLCRUZ(M->E1_VLCRUZ) for AP (AR) created by outflow bank statement with type
"PA"("RA")
We use value calculated in RU06D07

@param       Character          cTipo        //"PA"(Default) or "RA" (E2_TIPO or E1_TIPO)
@return      Numeric            nRet        // VLCRUZ
@example     
@author      astepanov
@since       September/01/2020
@edit        January/15/2021
@version     1.1
@project     MA3
@see         https://jiraproducao.totvs.com.br/browse/RULOC-694
             https://jiraproducao.totvs.com.br/browse/RULOC-1205
//---------------------------------------------------------------------------------------/*/
Function RU06XFUN75_Set_VLCRUZ(cTipo)

    Local nPos1       As Numeric
    Local nPos2       As Numeric
    Local nRet        As Numeric

    Default cTipo     := "PA"
    If     cTipo == "PA"
        nRet := SE2->E2_VLCRUZ
    ElseIf cTipo == "RA"
        nRet := M->E1_VLCRUZ
    EndIf
    If Type("aAutoCab") == "A"
        nPos1 := ASCAN(aAutoCab, {|x| x[1] $ "E2_ORIGEM|E1_ORIGEM"})
        nPos2 := ASCAN(aAutoCab, {|x| x[1] $ "E2_TIPO|E1_TIPO"})
        If nPos1 > 0 .AND. nPos2 > 0 .AND. AllTrim(aAutoCab[nPos1][2]) == "RU06D07" .AND.;
           AllTrim(aAutoCab[nPos2][2]) == cTipo
            nRet := aAutoCab[ASCAN(aAutoCab,{|x| x[1] $ "E2_VLCRUZ|E1_VLCRUZ"})][2]
        EndIf
    EndIf

Return nRet /*-------------------------------------------------------RU06XFUN75_Set_VLCRUZ*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN76_ARortinaUpd
This is a generic function used when we need to update or replace aRotina in standart 
non russian source codes 
@param    Numeric        nNum     //1, 2, 0
          Character      cSupp    //Supplier
          Character      cUnit    //Unit
          Character      cBnk
          Character      cBIK
          Character      cAcc

@param    
    cRot    : Character : Madatory Tag identifing from wich routine we are calling and what is the procedure to take. 
    aOriRot : Array     : Optional the original aRotina that maybe can be used to re-feed inside the function it is not mandatory. 
    aOriRot :aStr       : Optional Strings from original source code that maybe used in the aRotina                        
@return 
    aRotina: Array: the new array of aRotina
@example     
@author      Eduardo.Flima
@since       01/01/2020
@version     1.0
@project     MA3
//---------------------------------------------------------------------------------------/*/

Function RU06XFUN76_ARortinaUpd(cRot,aOriRot,aStr)
    Local aXRotina     As Array    

    DEFAULT aOriRot := {}
    DEFAULT cRot := ""
    DEFAULT aStr := {}

    aXRotina := {}

    cRot := AllTrim(UPPER(cRot))
    Do Case
        Case cRot == 'FINA070'
            aAdd( aXRotina,	{ aStr[1], "fa070Visual", 0, 2})         // View
            aAdd( aXRotina,	{ aStr[2], "fA070Tit", 0, 4})            // Post
            aAdd( aXRotina,	{ aStr[3], "fA070Lot", 0, 4})            // Lot
            aAdd( aXRotina,	{ aStr[4], "fA070Can", 0, 5})            // Cancel
            aAdd( aXRotina,	{ aStr[5], "FA040Legenda", 0, 6, ,.F.})  // Legend
            aAdd( aXRotina,	{ aStr[6], "Fc040Con", 0, 2})            // Query
            aAdd( aXRotina,	{ aStr[7], "CTBC662", 0, 7})             // Acc. tracker

        Case cRot == 'FINA080'
            // Removed "Delete" option, added "Query" option
            aXRotina := {;
            { aStr[1], "AxPesqui" , 0 , 1,,.F.},; //"Pesquisar"
            { aStr[2], "AxVisual" , 0 , 2},; //"Visualizar"
            { aStr[3], "FA080Tit" , 0 , 4},; //"Baixar"
            { aStr[4], "FA080Lot" , 0 , 4},; //"Lote"
            { aStr[5], "FA080Can" , 0 , 5},; //"Canc Baixa"
            { aStr[6], "CTBC662" , 0 , 8},;	//"Tracker Contábil"
            { aStr[7], "FA040Legenda", 0 , 6, ,.F.},; //"Le&genda"
            { aStr[8], "fc050con", 0 , 4 }}  // Query
    EndCase


Return aXRotina /*-------------------------------------------------------RU06XFUN76_ARortinaUpd*/


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN77_RetVrtLinesForPO
This function returns alias to query result when we load lines
to virtual grid in Payment order

@param       Array     aVrtFields // reslut of 
                                     oModel:GetStruct():GetFields()
             Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             Character cIDF49     // Unique identifier for F49 record
                                     F49_IDF49 
@return      Character cAlias     //don't forget about 
                                    (cAlias)->(DBCloseArea())
@examples   
@author      astepanov
@since       October/22/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN77_RetVrtLinesForPO(aVrtFields,cSupp,cUnit,cIDF49)
    Local cQuery     As Character
    Local cAlias     As Character
    Local nX         As Numeric


    cQuery := " SELECT '"+xFilial("F4B")+"'              B_BRANCH,"
    cQuery += "  CASE                                             "
    cQuery += "  WHEN   F4B.F4B_RATUSR = '1' THEN 'T'             "
    cQuery += "  ELSE                             'F'             "
    cQuery += "  END                                     B_CHECK ,"
    cQuery += "         COALESCE(F4A.F4A_CODREQ,'')      B_CODREQ,"
    cQuery += "         F4B.F4B_PREFIX                   B_PREFIX,"
    cQuery += "         F4B.F4B_NUM                      B_NUM   ,"
    cQuery += "         F4B.F4B_PARCEL                   B_PARCEL,"
    cQuery += "         F4B.F4B_TYPE                     B_TYPE  ,"
    cQuery += "         COALESCE(SE2.E2_NATUREZ,'')      B_CLASS ,"
    cQuery += "         COALESCE(SE2.E2_EMISSAO,'')      B_EMISS ,"
    cQuery += "         COALESCE(SE2.E2_VENCREA,'')      B_REALMT,"
    cQuery += "         F4B.F4B_VALPAY                   B_VALPAY,"
    cQuery += "         F4B.F4B_EXGRAT                   B_EXGRAT,"
    cQuery += "         F4B.F4B_VALCNV                   B_VALCNV,"
    cQuery += "         F4B.F4B_BSVATC                   B_BSVATC,"
    cQuery += "         F4B.F4B_VLVATC                   B_VLVATC,"
    cQuery += "         COALESCE(SE2.E2_VALOR  , 0)      B_VALUE ,"
    cQuery += "         COALESCE(SE2.E2_MOEDA  , 1)      B_CURREN,"
    cQuery += "         F4B.F4B_CONUNI                   B_CONUNI,"
    cQuery += "         COALESCE(SE2.E2_VLCRUZ , 0)      B_VLCRUZ,"
    cQuery += "         (COALESCE(SE2.E2_SALDO  , 0) -            "
    cQuery += "         COALESCE(OPB.OPBVALUE  , 0)   ) +         "
    cQuery += "         COALESCE(F5M.F5M_VALPAY, 0)      B_OPBAL ,"
    cQuery += "         COALESCE(SE2.E2_ALQIMP1, 0)      B_ALIMP1,"
    cQuery += "         F4B.F4B_VLIMP1                   B_VLIMP1,"
    cQuery += "         F4B.F4B_VALPAY - F4B.F4B_VLIMP1  B_BSIMP1,"
    cQuery += "         COALESCE(SE2.E2_F5QCODE,'')      B_MDCNTR,"
    cQuery += "         F4B.F4B_FLORIG                   B_FLORIG,"
    cQuery += "         F4B.F4B_IDF4A                    B_IDF4A ,"
    cQuery += "         F4B.F4B_RATUSR                   B_RATUSR "
    cQuery += " FROM      "+RetSQLName("F4B")+"               F4B "

    cQuery += " LEFT JOIN "+RetSQLName("SE2")+"               SE2 "
    cQuery += "        ON ( SE2.E2_FILIAL  = F4B.F4B_FLORIG       "
    cQuery += "         AND SE2.E2_PREFIXO = F4B.F4B_PREFIX       "
    cQuery += "         AND SE2.E2_NUM     = F4B.F4B_NUM          "
    cQuery += "         AND SE2.E2_PARCELA = F4B.F4B_PARCEL       "
    cQuery += "         AND SE2.E2_TIPO    = F4B.F4B_TYPE         "
    cQuery += "         AND SE2.E2_FORNECE = '"+cSupp+"'          "
    cQuery += "         AND SE2.E2_LOJA    = '"+cUnit+"'          "
    cQuery += "         AND SE2.D_E_L_E_T_ = ' '            )     "

    cQuery += " LEFT JOIN                                         "
    cQuery += "  ( SELECT                                         "
    cQuery += "        GRP.F5M_KEY             F5M_KEY,           "
    cQuery += "        SUM(GRP.F5M_VALPAY)     OPBVALUE           "
    cQuery += "    FROM                                           "
    cQuery += "      (SELECT                                      "
    cQuery += "                         F5M.F5M_KEY   ,           "
    cQuery += "                         F5M.F5M_VALPAY            "
    cQuery += "       FROM "+RetSQLName("F5M")+"             F5M  "
    cQuery += "       WHERE F5M_CTRBAL     = '1'                  "
    cQuery += "         AND F5M.D_E_L_E_T_ = ' '                  "
    cQuery += "      )                                        GRP "
    cQuery += "    GROUP BY GRP.F5M_KEY                           "
    cQuery += "  )                                            OPB "
    cQuery += "   ON ("+RU06XFUN09_RetSE2F5MJoinOnString("OPB")+")"

    cQuery += " LEFT JOIN "+RetSQLName("F5M")+"               F5M "
    cQuery += "   ON ("+RU06XFUN78_JoinOnF5MToF4B(cSupp,cUnit)+"  "
    cQuery += "         AND F5M.F5M_CTRBAL = '1'            )     "
    
    cQuery += " LEFT JOIN "+RetSQLName("F4A")+"               F4A "
    cQuery += "        ON ( F4A.F4A_FILIAL = F4B.F4B_FILIAL       "
    cQuery += "         AND F4A.F4A_IDF4A  = F4B.F4B_IDF4A        "
    cQuery += "         AND F4A.D_E_L_E_T_ = ' '            )     "

    cQuery += " WHERE                                             "
    cQuery += "             F4B.F4B_FILIAL = '"+xFilial("F4B")+"' "
    cQuery += "         AND F4B.F4B_IDF49  = '"+cIDF49+"'         "
    cQuery += "         AND F4B.D_E_L_E_T_ = ' '                  "

    cQuery := ChangeQuery(cQuery)
    cAlias := CriaTrab( , .F.)
    TcQuery cQuery New Alias ((cAlias))
    For nX := 1 To Len(aVrtFields)
        If aVrtFields[nX][4] $ "N|D|L"
            TCSetField(cAlias, aVrtFields[nX][3],;
                               aVrtFields[nX][4],;
                               aVrtFields[nX][5],;
                               aVrtFields[nX][6] )
        EndIf
    Next nX
Return cAlias //End of RU06XFUN77_RetVrtLinesForPO

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN78_JoinOnF5MToF4B
Function creates join string for joining F5M line to F4B line

@param       Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             
@return      Character cRet
@examples   
@author      astepanov
@since       October/23/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN78_JoinOnF5MToF4B(cSupp,cUnit)

    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local cRet       As Character
    Local aKs        As Array

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey()
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cRet := " F5M.F5M_FILIAL                               = '"+xFilial("F5M")+"' AND "
    cRet += " F5M.F5M_ALIAS                                = 'F4B'                AND "
    cRet += " F5M.F5M_IDDOC                                =  F4B.F4B_UUID        AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cFS+","+cFE+")) = TRIM(F4B.F4B_FLORIG) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cPS+","+cPE+")) = TRIM(F4B.F4B_PREFIX) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cNS+","+cNE+")) = TRIM(F4B.F4B_NUM)    AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cRS+","+cRE+")) = TRIM(F4B.F4B_PARCEL) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cTS+","+cTE+")) = TRIM(F4B.F4B_TYPE)   AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cCS+","+cCE+")) = '"+cSupp+"'          AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cLS+","+cLE+")) = '"+cUnit+"'          AND "
    cRet += " F5M.D_E_L_E_T_                               = ' '                      "

Return cRet //End of RU06XFUN78_JoinOnF5MToF4B


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN79_JoinOnF5MToF48
Function creates join string for joining F5M line to F48 line

@param       Character cSupp      // Supplier code for E2_FORNECE
             Character cUnit      // Supplier unit for E2_LOJA
             
@return      Character cRet
@examples   
@author      astepanov
@since       October/27/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN79_JoinOnF5MToF48(cSupp,cUnit)

    Local cFS, cFE, cPS, cPE, cNS, cNE, cRS, cRE, cTS As Character
    Local cTE, cCS, cCE, cLS, cLE                     As Character
    Local cRet       As Character
    Local aKs        As Array

    aKs := RU06XFUN44_RetSE2FldsPosInFMKey()
    cFS := aKs[1][2]
    cFE := aKs[1][3]
    cPS := aKs[2][2]
    cPE := aKs[2][3]
    cNS := aKs[3][2]
    cNE := aKs[3][3]
    cRS := aKs[4][2]
    cRE := aKs[4][3]
    cTS := aKs[5][2]
    cTE := aKs[5][3]
    cCS := aKs[6][2]
    cCE := aKs[6][3]
    cLS := aKs[7][2]
    cLE := aKs[7][3]

    cRet := " F5M.F5M_FILIAL                               = '"+xFilial("F5M")+"' AND "
    cRet += " F5M.F5M_ALIAS                                = 'F48'                AND "
    cRet += " F5M.F5M_IDDOC                                =  F48.F48_UUID        AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cFS+","+cFE+")) = TRIM(F48.F48_FLORIG) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cPS+","+cPE+")) = TRIM(F48.F48_PREFIX) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cNS+","+cNE+")) = TRIM(F48.F48_NUM)    AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cRS+","+cRE+")) = TRIM(F48.F48_PARCEL) AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cTS+","+cTE+")) = TRIM(F48.F48_TYPE)   AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cCS+","+cCE+")) = '"+cSupp+"'          AND "
    cRet += " TRIM(SUBSTRING(F5M.F5M_KEY,"+cLS+","+cLE+")) = '"+cUnit+"'          AND "
    cRet += " F5M.D_E_L_E_T_                               = ' '                      "

Return cRet  //End of RU06XFUN79_JoinOnF5MToF48


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN80_Ret_VLIMP1_BSIMP1
We use this function when calculate _VLIMP1 or _BSIMP1
@param       Character cSE2Key    // Key for SE2 index #1 
                            filial+prefix+num+parcel+tipo+fornece+loja
             Numeric   nValpay    // payment value
             Numeric   nSE2Valor  // can be Nil, if Nil 
                                  // we get SE2->E2_VALOR from search
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VLIMP1
                                  // Default is 2
             
@return      Array     aRet       // {_VLIMP1,_BSIMP1}
@examples   
@author      astepanov
@since       October/29/2020
@version     1.0
@project     MA3
Look at https://jiraproducao.totvs.com.br/browse/RULOC-44
Comments #3-6
/*/
//-----------------------------------------------------------------------
Function RU06XFUN80_Ret_VLIMP1_BSIMP1(cSE2Key,nValpay,nSE2Valor,nRnd)

    Local aRet        As Array
    Local aArea       As Array
    Local aSE2Area    As Array
    Local nSE2Valimp  As Numeric
    Default nRnd  := 2

    aRet := {0,0}
    aArea      := GetArea()
    aSE2Area   := SE2->(GetArea())
    DBSelectArea("SE2")
    DBSetOrder(1) //filial+prefix+num+parcel+tipo+fornece+loja
    If DBSeek(cSE2Key)
        nSE2Valimp := SE2->E2_VALIMP1
        If nSE2Valor == Nil
            nSE2Valor := SE2->E2_VALOR
        EndIf
    Else
        nSE2Valimp := 0
    EndIf
    RestArea(aSE2Area)
    RestArea(aArea)
    aRet[1]  := RU06XFUN82_Calc_VLIMP1(nValpay,nSE2Valimp,nSE2Valor,nRnd)
    aRet[2]  := nValpay - aRet[1]

Return aRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN81_RetCnvValues
According to passed Payment value ,_VLIMP1 and exchange rate
we calculate _VALCNV, _VLVATC, BSVATC according to rules previously
located in RU06XFUN20_VldValPay :
nValImp := oModelL:GetValue(cAliasL+"_VLIMP1")
oModelL:LoadValue(cAliasL+"_VALCNV",ROUND(nValLineFld * oModelL:GetValue(cAliasL + "_EXGRAT"), 2))
oModelL:LoadValue(cAliasL+"_VLVATC",ROUND(nValImp     * oModelL:GetValue(cAliasL + "_EXGRAT"), 2))
oModelL:LoadValue(cAliasL+"_BSVATC",oModelL:GetValue(cAliasL + "_VALCNV") - ;
                                    oModelL:GetValue(cAliasL + "_VLVATC")   )

@param       Numeric   nValpay    // payment value
             Numeric   nValImp    // _VLIMP1
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VALCNV
                                  // default is 2
             
@return      Array     aRet       // {_VALCNV,_VLVATC,_BSVATC}
@examples   
@author      astepanov
@since       October/29/2020
@version     1.0
@project     MA3

/*/
//-----------------------------------------------------------------------
Function RU06XFUN81_RetCnvValues(nValPay,nValImp,nExgRat,nRnd)

    Local   aRet As Array
    Default nRnd := 2

    aRet    := {0,0,0} //{_VALCNV,_VLVATC,_BSVATC}
    aRet[1] := Round(nValPay*nExgRat,nRnd)
    aRet[2] := Round(nValImp*nExgRat,nRnd)
    aRet[3] := aRet[1] - aRet[2]

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06XFUN82_Calc_VLIMP1
This function used by RU06XFUN80_Ret_VLIMP1_BSIMP1 for _VLIMP1
calculation
_VLIMP1 = (nValpay * SE2->E2_VALIMP1)/SE2->E2_VALOR
@param       Numeric   nValpay    // payment value
             Numeric   nSE2Valimp // relates to SE2->E2_VALIMP1
             Numeric   nSE2Valor  // relates to SE2->E2_VALOR
             Numeric   nRnd       // how many numbers we leave after
                                  // point when round _VLIMP1
                                  // default is 2
             
@return      Numeric   nVlimp1
@examples   
@author      astepanov
@since       October/29/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU06XFUN82_Calc_VLIMP1(nValpay, nSE2Valimp, nSE2Valor, nRnd)
    Local nVlimp1 As Numeric
    Default nRnd := 2
    nVlimp1 := ROUND((nValpay*nSE2Valimp)/nSE2Valor,nRnd)
Return nVlimp1

/*{Protheus.doc} RU06XFUN83_Add_Info_In_Rate_Diff_Doc
@type           
@description    Adding information about the code and GIUD of the main document to a new document 
                that is created when converting the amount of the main document for the difference in exchange rates.
@author         Nikita.Lysenko
@since          06/04/2021
@version        1.0
@project        MA3 - Russia
*/
Function RU06XFUN83_Add_Info_In_Rate_Diff_Doc(aTitulo, cF5qcode, cF5quid)
    AADD (aTitulo, {"E2_F5QCODE",   cF5qcode,	Nil})
    AADD (aTitulo, {"E2_F5QUID",    cF5quid,	Nil})
Return aTitulo


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Filt
Filter for AR list

@author Cherchik Konstantin
@since  14/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Filt(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,cVarQ,oPanel,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)
	Local cPerg		as Character
	Local lRet		as Logical
	Local cParCont	as Character

	Private aFilter as Array

	cParCont	:= MV_PAR02
    If Type("lFilterMark") == 'U' .And. ValType(lFilterMark) == 'U'
        Private lFilterMark := .F.
    EndIf 
	lFilterMark	:= MsgYesNo(STR0090,STR0089)    // Filter will unmark all selections, do you agree? ## Filter 
    cPerg       :=""
    lRet        :=.F.
    aFilter     := {}


	If lFilterMark
		cPerg := "AF3301"
		lRet  := Pergunte(cPerg,.T.,STR0085)    // Sorting
		If lRet
			cTitFilt := ""			
			Aadd(aFilter, MV_PAR01)	//From E1_PREFIXO
			Aadd(aFilter, MV_PAR02)	//To E1_PREFIXO
			Aadd(aFilter, MV_PAR03)	//From E1_NUM
			Aadd(aFilter, MV_PAR04)	//To E1_NUM
			Aadd(aFilter, MV_PAR05)	//From E1_TIPO
			Aadd(aFilter, MV_PAR06)	//To E1_TIPO
			Aadd(aFilter, MV_PAR07)	//From E1_MOEDA 
			Aadd(aFilter, MV_PAR08)	//To E1_MOEDA
			Aadd(aFilter, MV_PAR09)	//From E1_CLIENTE
			Aadd(aFilter, MV_PAR10)	//To E1_CLIENTE
			Aadd(aFilter, MV_PAR11)	//From E1_F5QCODE
			Aadd(aFilter, MV_PAR12)	//To E1_F5QCODE
			Aadd(aFilter, MV_PAR13)	//From E1_EMISSAO
			Aadd(aFilter, MV_PAR14)	//To E1_EMISSAO
			Pergunte("FIN330",.F.)

			cTitFilt += " SE1.E1_PREFIXO >= '" + aFilter[1] + "' AND SE1.E1_PREFIXO <= '" + aFilter[2] + "'" 
			cTitFilt += " AND SE1.E1_NUM >= '" + aFilter[3] + "' AND SE1.E1_NUM <= '" + aFilter[4] + "'"
			cTitFilt += " AND SE1.E1_TIPO >= '" + aFilter[5] + "' AND SE1.E1_TIPO <= '" + aFilter[6] + "'"
			cTitFilt += " AND SE1.E1_MOEDA >= " + AllTrim(Str(aFilter[7])) + " AND SE1.E1_MOEDA <= " + AllTrim(Str(aFilter[8])) + ""
			cTitFilt += " AND SE1.E1_CLIENTE >= '" + aFilter[9] + "' AND SE1.E1_CLIENTE <= '" + aFilter[10] + "'"
			cTitFilt += " AND SE1.E1_F5QCODE >= '" + aFilter[11] + "' AND SE1.E1_F5QCODE <= '" + aFilter[12] + "'"
			cTitFilt += " AND SE1.E1_EMISSAO >= '" + DTOS(aFilter[13]) + "' AND SE1.E1_EMISSAO <= '" + DTOS(aFilter[14]) + "' AND "

			Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont)  //Generates Table with titles - aTitulos:
		EndIf
	EndIf

	MV_PAR02 := cParCont
	oTitulo:SetArray(aTitulos)
	If MV_PAR02 == 2
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
				aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
	Else
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
	EndIf
	oTitulo:Refresh()
	Pergunte("FIN330",.F.)    
Return


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Unfil
Function to remove the filter from the listbox

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Unfil(oTitulo,aTitulos,lAutomato,oOk,oNo,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)
	Local lUnfilter	as Logical

	lUnfilter := MsgYesNo(STR0092,STR0091)  	// Unfilter will unmark all selections, do you agree? ## Unfilter

	If lUnfilter
		cTitFilt := ""
		Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato, cNumCont)
		If MV_PAR02 == 2
			oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
					aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
					aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
					aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
					aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
					aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
					aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
					aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
			oTitulo:Refresh()
			Pergunte("FIN330",.F.)
		Else
			oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
					aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
					aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
					aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
					aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
					aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
					aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
			oTitulo:Refresh()
			Pergunte("FIN330",.F.)
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330AutMk
Function for Auto Mark

@author Cherchik Konstantin
@since  12/11/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330AutMk(oTitulo,aTitulos,lAutomato,oOk,oNo,dEmissao,cOrigem,lCredito,aNumLay,cNumCont)

	Local nOpcB as Numeric
    Local oDlg as Object
    Local oGet01 as Object 

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,233 TITLE STR0082 PIXEL  //Auto Mark
	@ 05,17 Say STR0083 SIZE 110,7 OF oDlg PIXEL        // Value to clear
	@ 22,07 TO 72, 100 OF oDlg  PIXEL
	@ 30,20 MSGET oGet01 VAR nValor PICTURE "@E 999,999,999.99" Valid .T. WHEN .T. PIXEL OF oDlg SIZE 70,7 HASBUTTON	

	DEFINE SBUTTON FROM 75,045 TYPE 1 ENABLE OF oDlg ACTION (nOpcB := 1,Iif(nValor >= 0 .AND. nValor <= nSaldo,oDlg:End(),EVAL({|| Help("",1,"FA330ValClrVld",,STR0084,1,0) , .F. })))  //You have entered the value that exceeds the limit
	DEFINE SBUTTON FROM 75,75 TYPE 2 ENABLE OF oDlg ACTION (nOpcB := 0,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcB := 0, .T.)    

	If nOpcB == 1 .And. MV_PAR02 == 2
		FA330Sort(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,nValTot)
		Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
				aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
		oTitulo:Refresh()	
	ElseIf nOpcB == 1
		FA330Sort(oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,nValTot)
		Fa330TitEx(dEmissao,cOrigem,lCredito,aNumLay,lAutomato,cNumCont) //Generates Table with titles - aTitulos:
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
		oTitulo:Refresh()	
	Endif
Return

//--------------------------------------------------------------------------
/*/{Protheus.doc}FINA340Sort
Sorting for AR list

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Sort (oTitulo,aTitulos,cNumCont,lAutomato,oOk,oNo,oPanel,nValTot)
	Local nX		as Numeric
	Local nOpcS		as Numeric
    Local aPayTypes as Array
    Local oDlg      as Object
    Local oCbx      as Object
    Local oRadio    as Object 


    aPayTypes   := {}
    oDlg        :=nil
    oCbx        :=nil

	If !IsInCallStack("FA330AutMk")		
		For nX := 2 To Len(oTitulo:AHEADERS) 
			Aadd(aPayTypes, oTitulo:AHEADERS[nX]) 
		Next

		aDel(aPayTypes,9) // We can not sort and set "clear value"  at the same time, in column that contains values to clear.

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE STR0085 PIXEL  	//Sorting
		@ 10,17 Say STR0086 SIZE 150,7 OF oDlg PIXEL 		// Order
		@ 27,07 TO 72, 140 OF oDlg  PIXEL
		@ 34,13 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
		@ 50,13 Radio 	oRadio VAR nRadio; 
			ITEMS 	STR0087,;			// Ascending
					STR0088;			// Descending
			SIZE 110,10 OF oDlg PIXEL
		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpcS := 1,FA330Combo(cPayType, oDlg,oCbx,@nSel))
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpcS := 0,FA330Combo(cPayType, oDlg,oCbx,@nSel))
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpcS := 0, .T.)    
	EndIf

	/* Due to the fact that the arrays aTitulos & aHeaders are out of sync, the sort function must be synchronized in this form */

	If MV_PAR02 == 2
	DO Case
			Case nSel == 1
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[16] < y[16] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )		
				Endif 
			Case nSel == 2
				cSortField := "E1_PREFIXO, E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
				Endif  
			Case nSel == 3
				cSortField := "E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	  
			Case nSel == 4
				cSortField := "E1_PARCELA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
				Endif	 
			Case nSel == 5
				cSortField := "E1_TIPO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
				Endif	
			Case nSel == 6
				cSortField := "E1_MOEDA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
				Endif	 
			Case nSel == 7
				cSortField := "E1_MOEDA "	//CTO_SIMB
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[23] < y[23] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[23] > y[23] } )
				Endif	
			Case nSel == 8
				cSortField := "E1_SALDO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
				Endif	 
			Case nSel == 9
				cSortField := "E1_CLIENTE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
				Endif	 
			Case nSel == 10
				cSortField := "E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
				Endif	  
			Case nSel == 11
				cSortField := "E1_CLIENTE, E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18]+x[5] < y[18]+y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18]+x[5] > y[18]+y[5] } )
				Endif	
			Case nSel == 12
				cSortField := "E1_HIST "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
				Endif	
			Case nSel == 13
				cSortField := "E1_F5QCODE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
				Endif	
			Case nSel == 14
				cSortField := "E1_EMISSAO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
				Endif	  
			Case nSel == 15
				cSortField := "E1_VALOR "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[20] < y[20] } ) 
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[20] > y[20] } )
				Endif	
			Case nSel == 16
				cSortField := "E1_VLCRUZ "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[21] < y[21] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[21] > y[21] } )
				Endif	
			Case nSel == 17
				cSortField := "E1_CONUNI "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[22] < y[22] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[22] > y[22] } )
				Endif	 
			Otherwise
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	 
		EndCase
			
		oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,16],aTitulos[oTitulo:nAt,1],;
					aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
					aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
					aTitulos[oTitulo:nAt,23],aTitulos[oTitulo:nAt,6],;
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,18],;
					aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,11],;
					aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,19],;
					aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,20],;
					aTitulos[oTitulo:nAt,21],aTitulos[oTitulo:nAt,22]}}
			oTitulo:Refresh()
	Else
		DO Case
			Case nSel == 1
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[13] < y[13] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[13] > y[13] } )		
				Endif 
			Case nSel == 2
				cSortField := "E1_PREFIXO, E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] < y[1]+y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[1]+x[2] > y[1]+y[2] } )		
				Endif  
			Case nSel == 3
				cSortField := "E1_NUM "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	  
			Case nSel == 4
				cSortField := "E1_PARCELA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[3] < y[3] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[3] > y[3] } )
				Endif	 
			Case nSel == 5
				cSortField := "E1_TIPO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[4] < y[4] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[4] > y[4] } )
				Endif	
			Case nSel == 6
				cSortField := "E1_MOEDA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[9] < y[9] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[9] > y[9] } )
				Endif	 
			Case nSel == 7
				cSortField := "E1_MOEDA "	//CTO_SIMB
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[20] < y[20] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[20] > y[20] } )
				Endif	
			Case nSel == 8
				cSortField := "E1_SALDO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[6] < y[6] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[6] > y[6] } )
				Endif	 	 
			Case nSel == 9
				cSortField := "E1_CLIENTE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[15] < y[15] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[15] > y[15] } )
				Endif	 
			Case nSel == 10
				cSortField := "E1_LOJA "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[5] < y[5] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[5] > y[5] } )
				Endif	  
			Case nSel == 11
				cSortField := "E1_F5QCODE "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[16] < y[16] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[16] > y[16] } )
				Endif	
			Case nSel == 12
				cSortField := "E1_EMISSAO "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[10] < y[10] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[10] > y[10] } )
				Endif	  
			Case nSel == 13
				cSortField := "E1_VALOR "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[17] < y[17] } ) 
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[17] > y[17] } )
				Endif	
			Case nSel == 14
				cSortField := "E1_VLCRUZ "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[18] < y[18] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[18] > y[18] } )
				Endif	
			Case nSel == 15
				cSortField := "E1_CONUNI "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[19] < y[19] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[19] > y[19] } )
				Endif	 
			Otherwise
				cSortField := "E1_FILIAL "
				If nRadio = 1
					cSortType := " ASC"
					ASORT(aTitulos, , , { | x,y | x[2] < y[2] } )
				Else
					cSortType := " DESC"
					ASORT(aTitulos, , , { | x,y | x[2] > y[2] } )
				Endif	 
		EndCase
			
		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,13],aTitulos[oTitulo:nAt,1],;
				aTitulos[oTitulo:nAt,2],aTitulos[oTitulo:nAt,3],;
				aTitulos[oTitulo:nAt,4],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,20],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,15],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,16],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,17],;
				aTitulos[oTitulo:nAt,18],aTitulos[oTitulo:nAt,19]}}
		oTitulo:Refresh()	
	EndIf
Return


//--------------------------------------------------------------------------
/*/{Protheus.doc}FA330Combo
Function for buttons of FA330Sort

@author Cherchik Konstantin
@since  13/12/2018
@version 12
/*/
//--------------------------------------------------------------------------
Function FA330Combo(cPayType, oDlg,oCbx, nSel)
	nSel := oCbx:nAt
	oDlg:End()
Return
