#include "protheus.ch"
#Include "FwMvcDef.ch"
#Include "tcbrowse.ch"
#Include "RU99X11.CH"

// CONSTANTES
#Define ENTER  Chr(10) + Chr (13) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)
#DEFINE DB_TYPE AllTrim(TCGetDB()) //DataBase Type


/*/{Protheus.doc} RU99X11
Queries for Querie Engine
@type function
@author Rafael Goncalves da Silva
@since Dec|2019
/*/
Function RU99X11()
DbSelectArea('F6R')
F6R->(DbSetOrder(1))
DbSelectArea('F6S')
F6R->(DbSetOrder(1))
DbSelectArea('F6T')
F6R->(DbSetOrder(1))

FWMsgRun(, {|oSay| RU99X11A(oSay) }, STR0009, STR0010)  //"Processando"##"Processando a rotina para ajuste campo Linha da grid."

return .t.

Function RU99X11A()
Local aFunct as array
Local _nj as numeric
Local aFilUsr_ as Array // branchs that user has access
Local _Ni as Numeric //used for controling
Public cFilUser_ as Character // branches that user can access

cFilUser_ := ''
/*Branchs that user can acess*/
aFilUsr_	:=  AdmGetFil(.F.,.F.,"", .F., .F.,.F.)
For _Ni := 1 to len(aFilUsr_)
    If _Ni>1
        cFilUser_+= ','
    Endif
    cFilUser_ += "'"+aFilUsr_[_Ni,1]+"'"
Next

aFunct := {}
//update the queries, insert here all function that must be updated
aAdd(aFunct,'RU99X1101') // function for start "Query: Absence of VAT invoices for purchases" 4.3.1.
aAdd(aFunct,'RU99X1102') // function for start "Query: Absence of VAT invoices for sales" 4.3.2.
aAdd(aFunct,'RU99X1103') // function for start "Timeliness of issuing of VAT sales invoices" 4.3.3.
aAdd(aFunct,'RU99X1104') // function for start "Inflow VAT movements analyses" 4.3.4.
aAdd(aFunct,'RU99X1105') // function for start "Outflow VAT movements analyses" 4.3.5.
aAdd(aFunct,'RU99X1106') // function for start "Inflow VAT turnover sheet" 4.3.6
aAdd(aFunct,'RU99X1107') // function for start "Negative balances of inflow VAT" 4.3.7

begin transaction
    For _nj := 1 to len(aFunct)
        RU99X1100(aFunct[_nj])
    Next
End transaction

DbSelectArea('F6R') //set alias used at browser
F6R->(DbSetOrder(1))
return


/*/{Protheus.doc} RU99X11
Function update / create queries
@type function
@author Rafael Goncalves da Silva
@since Dec|2019
/*/
Static Function RU99X1100(cCodFunc)
Local aRetQue as Array
local _nI as Numeric
Local cValUs as Character
Local nPos as Numeric

cValUs := cCodFunc+"()"
//Check version and date for the information at F6R queries and update
DbSelectArea('F6R')
F6R->(DbSetOrder(2))
aRetQue := &(cValUs)
IF Msseek(xFilial('F6R')+cCodFunc)
    If F6R->F6R_DATE < aRetQue[1] .or. F6R->F6R_VERSIO < aRetQue[2] // need update
        RecLock('F6R',.f.)
            F6R->F6R_DATE   := aRetQue[1]//Date of last update
            F6R->F6R_VERSIO := aRetQue[2]
            F6R->F6R_CODQRY := aRetQue[3]
            F6R->F6R_TITULO := aRetQue[4]
            F6R->F6R_QUERY  := aRetQue[6]
            F6R->F6R_X1PERG := aRetQue[7]
            F6R->F6R_OPTION := aRetQue[10]
            F6R->F6R_FUNCTI := cCodFunc
        F6R->(MsUnlock())

        //////////////////////////////
        //        Check Index       //
        //////////////////////////////
        //Delete exist index not used anymore
        DbSelectArea('F6T')
        DbSetOrder(1)
        If Msseek(FWxFilial("F6T") + aRetQue[3])
            While !eof() .and. F6T->F6T_FILIAL + F6T->F6T_CODQRY == FWxFilial("F6T") + aRetQue[3]
                //Look at array if this information continues existin or must be deleted
                nPos := AScan(aRetQue[9], {|x| x[1]==F6T->F6T_ORDER})
                If nPos <= 0 //nao Achou, sera deletado
                    Reclock('F6T',.f.)
                        DbDelete()
                    F6T->(MsUnlock())
                EndIf
                DbSelectArea('F6T')
                F6T->(DbSkip())
            enddo
        Endif

        for _nI := 1 to len(aRetQue[9])
            DbSelectArea('F6T')
            F6T->(Msseek(FWxFilial("F6T") + aRetQue[3] + aRetQue[9,_ni,1]))
            (RecLock("F6T", !found()))
                F6T->F6T_FILIAL := FWxFilial("F6T")
                F6T->F6T_CODQRY := aRetQue[3]
                F6T->F6T_ORDER  := aRetQue[9,_ni,1]
                F6T->F6T_DESCRI := aRetQue[9,_ni,2]
                F6T->F6T_KEY    := aRetQue[9,_ni,3]
            F6T->(MsUnlock())
        Next _nI

        //////////////////////////////
        //        Check Order       //
        //////////////////////////////
        //Delete exist Order not used anymore
        DbSelectArea('F6S')
        DbSetOrder(1)
        If Msseek(FWxFilial("F6S") + aRetQue[3])
            While !eof() .and. F6S->F6S_FILIAL + F6S->F6S_CODQRY == FWxFilial("F6T") + aRetQue[3]
                //Look at array if this information continues existin or must be deleted
                nPos := AScan(aRetQue[8], {|x| x[1]==alltrim(F6S->F6S_CPOQRY)})
                If nPos <= 0 //if not found will be deleted
                    Reclock('F6S',.f.)
                        DbDelete()
                    F6S->(MsUnlock())
                EndIf
                DbSelectArea('F6S')
                F6S->(DbSkip())
            enddo
        Endif
        //Update order
        If Len(aRetQue[8]) > 0
            For _nI := 1 to len(aRetQue[8])
                DbSelectArea('F6S')
                F6S->(MsSeek(FWxFilial("F6S") + aRetQue[3] + aRetQue[8,_nI,1]))
                RecLock("F6S", !found())
                    F6S->F6S_FILIAL := FWxFilial("F6S")
                    F6S->F6S_CODQRY := aRetQue[3]
                    F6S->F6S_CPOQRY := aRetQue[8,_nI,1]
                    F6S->F6S_QRYMEM := aRetQue[8,_nI,3]
                    F6S->F6S_TITSUB := aRetQue[8,_nI,2]
                    F6S->F6S_LABEL  := aRetQue[8,_nI,4]
                    F6S->F6S_MASCAR := aRetQue[8,_nI,5]
                F6S->(MsUnlock())
            Next
		Endif
    Endif
ELSE
    RecLock('F6R',.T.)
        F6R->F6R_FILIAL := xFilial('F6R')
        F6R->F6R_DATE   := aRetQue[1]
        F6R->F6R_VERSIO := aRetQue[2]
        F6R->F6R_CODQRY := aRetQue[3]
        F6R->F6R_TITULO := aRetQue[4]
        F6R->F6R_QUERY  := aRetQue[6]
        F6R->F6R_X1PERG := aRetQue[7]
        F6R->F6R_OPTION := aRetQue[10]
        F6R->F6R_FUNCTI := cCodFunc
    F6R->(MsUnlock())

    //Create Index
     for _nI := 1 to len(aRetQue[9])
        DbSelectArea('F6T')
        RecLock("F6T", .T.)
            F6T->F6T_FILIAL := FWxFilial("F6T")
            F6T->F6T_CODQRY := aRetQue[3]
            F6T->F6T_ORDER  := aRetQue[9,_ni,1]
            F6T->F6T_DESCRI := alltrim(aRetQue[9,_ni,2])
            F6T->F6T_KEY    := alltrim(aRetQue[9,_ni,3])
        F6T->(MsUnlock())
    Next _nI

    //Create SubQuery
    DbSelectArea('F6S')
    if Len(aRetQue[8]) > 0 //subquery somente uma por cada  campo
       for _nI := 1 to len(aRetQue[8])
            RecLock("F6S", .T.)
                F6S->F6S_FILIAL := FWxFilial("F6S")
                F6S->F6S_CODQRY := aRetQue[3]
                F6S->F6S_CPOQRY := aRetQue[8,_nI,1]
                F6S->F6S_QRYMEM := aRetQue[8,_nI,3]
                F6S->F6S_TITSUB := aRetQue[8,_nI,2]
                F6S->F6S_LABEL  := aRetQue[8,_nI,4]
                F6S->F6S_MASCAR := aRetQue[8,_nI,5]
            F6S->(MsUnlock())
        Next
    endif
endif
return .t.




/*/{Protheus.doc} RU99X1101
@Description function for start "Query: Absence of VAT invoices for purchases" 4.3.1.
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
    1 - Date of update the querye / Small changes
    2 - Version / Big Changes
    3 - Cod
    4 - name
    5 - Description - for the screen header
    6 - Query
    7 - pergunte
    8 - Array(Sub Queries), last fields is many decimals we will need do display
    9 - Array(index)
    10 - Optional Fields to be displayed
    11 - Source document {
        11.1 Fields for action(where user click)
        11.2 Key for seek (index for dbSeek)
        11.3 Table for seek
        11.4 Index
        11.5 Function(could be one example bellow)
            //FWExecView
            //AxVisual
            //MATA103(,,2)
        11.6 Variaveis necessary for exec the vizualization(mandatory variables that need be create before call the function os step 11.5)
            {
                11.6.1 Variable
                11.6.2 Default Value
            }}
        11.7 Branch Information (cFilant will be replace with this information)
    12 - default fields to view
    13 - Fields for totals
/*/
Function RU99X1101(cFilUser_)
local cName as character
local cDesc as character
Local cQuery as character
Local cCod  as  character
Local cOpcFil as character //opcional fields
local dDate as date
Local nVersion as Numeric
Local aSubQuery as array
Local aIdexOrd as array
Local cPerg as character
Local aSourDoc as Array //Source document open
Local aTotal as Array
Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200902')   //when was small changes, update only here
nVersion := 1               //when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc  := {}
cPerg := 'QE0001'
cCod  := '000001'
cName := STR0020 //'Absence of VAT invoices for purchases'
//Description from Screen
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+ dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02) +', '+STR0028+' '+Iif(MV_PAR03==1,STR0030,(Iif(MV_PAR03==3,STR0032,STR0035)))
aTotal := {}

cOpcFil := 'F1_VALMERC,F1_MOEDA,F1_CONUNI,F1_TXMOEDA '
cDefFil := "F1_FILIAL,F1_FORNECE,F1_LOJA,A2_NREDUZ,F1_SERIE,F1_DOC,F1_EMISSAO,F1_TIPO,F1_DTDIGIT,F37_DOC,F37_PDATE,F37_RDATE,F37_FILIAL,F37_KEY"

cQuery := " select distinct RESULT, %FIELD:"+cDefFil+":FIELD% from ( " + ENTER
    cQuery += " select CASE WHEN  COALESCE(F37_PDATE, '') = '' THEN '.F.' ELSE '.T.' END AS RESULT," + ENTER
    cQuery += " F1_FILIAL,F1_FORNECE,F1_LOJA,COALESCE(A2_NREDUZ,A1_NREDUZ, '') as A2_NREDUZ,F1_SERIE,F1_DOC,F1_EMISSAO,F1_DTDIGIT,COALESCE(F37_DOC, ' ')  AS  F37_DOC ,COALESCE(F37_PDATE, ' ')  as F37_PDATE " + ENTER
    cQuery += " ,F1_VALMERC,F1_MOEDA,F1_CONUNI,F1_TXMOEDA,F1_TIPO,F1_COND,COALESCE(A2_END,A1_END, ' ')  AS  A2_END, COALESCE(A2_BAIRRO,A1_BAIRRO, ' ')  AS  A2_BAIRRO, COALESCE(A2_EST,A1_EST, ' ')  AS  A2_EST, COALESCE(A2_CEP,A1_CEP, ' ')  AS  A2_CEP, COALESCE(F37_RDATE, ' ')  AS  F37_RDATE, COALESCE(F37_FILIAL, ' ')  AS  F37_FILIAL , COALESCE(F37_KEY, ' ')  AS  F37_KEY " + ENTER
    cQuery += " from %TABLE:SF1% SF1 " + ENTER
    cQuery += " left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F1_FILIAL% and  SA2.A2_COD=SF1.F1_FORNECE AND SA2.A2_LOJA=SF1.F1_LOJA AND SA2.D_E_L_E_T_='' AND NOT (F1_TIPO IN ('D', 'B')) " + ENTER
    cQuery += " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F1_FILIAL% and  SA1.A1_COD=SF1.F1_FORNECE AND SA1.A1_LOJA=SF1.F1_LOJA AND SA1.D_E_L_E_T_='' AND (F1_TIPO IN ('D', 'B'))" + ENTER
    cQuery += " LEFT JOIN %TABLE:F38% F38 ON F1_FILIAL=F38_FILIAL AND F1_DOC = F38_INVDOC AND F1_SERIE = F38_INVSER AND F38.D_E_L_E_T_='' " + ENTER
    cQuery += " LEFT JOIN %TABLE:F37% F37 ON F1_FILIAL=F37_FILIAL AND F37_KEY = F38_KEY AND F37.D_E_L_E_T_='' AND F37_FORNEC=F1_FORNECE  AND F37_BRANCH=F1_LOJA" + ENTER
    cQuery += " where F1_DTDIGIT between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
    cQuery += "     and F1_FORNECE between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
    cQuery += "     and F1_LOJA between %Exp:MV_PAR05% and %Exp:MV_PAR07% " + ENTER
    cQuery += "     and F1_DOC between %Exp:MV_PAR08% and %Exp:MV_PAR10% " + ENTER
    cQuery += "     and F1_SERIE between %Exp:MV_PAR09% and %Exp:MV_PAR11% " + ENTER
    cQuery += "     and F1_FILIAL between %Exp:MV_PAR12% and %Exp:MV_PAR13% " + ENTER
    cQuery += "     and SF1.F1_ESPECIE='NF' " + ENTER
    cQuery += " and SF1.D_E_L_E_T_='' AND NOT (F1_TIPO IN ('D', 'B')) " + ENTER
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and SF1.F1_FILIAL in ("+cFilUser_ +") "+ ENTER
    Endif
cQuery += " ) as TMP" + ENTER
//                      Without VAT Invoice                         With VAT Invoice                                all lines
cQuery += " where ((%Exp:MV_PAR03% = 2 and F37_PDATE = ' ' ) or (%Exp:MV_PAR03% = 3  and F37_PDATE <> ' ' ) or (%Exp:MV_PAR03% = 1)) " + ENTER

//Index order //Ordem    , description             , Key
aAdd(aIdexOrd,{ '1'    ,STR0022,'F1_DTDIGIT+F1_DOC' }) //'Issue Date + Branch'

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F1_FORNECE|F1_LOJA|A2_NREDUZ', 'F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO', "SF1", 1 ,'RU99X11A1("SF1",1,(cCurrAlias)->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO) )',{ },'F1_FILIAL'})

aAdd(aSourDoc,{'F1_SERIE|F1_DOC|F1_EMISSAO','F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO','SF1',1,'CtbDocEnt()',{ {'aRotina','{{"","",0,2,0,Nil},{"","",0,2,0,Nil},{"","",0,2,0,Nil},{"","",0,2,0,Nil}}'}},'F1_FILIAL'}) //MATA101N(,,2)
aAdd(aSourDoc,{'F37_DOC|F37_PDATE|F37_KEY',;
                'PADR(F37_FILIAL,TamSX3("F37_FILIAL")[1]) + PADR(F37_KEY,TamSX3("F37_KEY")[1])',;
                'F37',;
                3 ,;
                "RU99X11A4('RU09T03')",; //Vizualizadion 'default
                {;
                    {"cCadastro","''"},;
                    {"INCLUI",".F."};
                },'PADR(F37_FILIAL,TamSX3("F37_FILIAL")[1])'})

//       01    02       03    04   05     06     07     08        09      10       11     12      13
return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}


/*/{Protheus.doc} RU99X1102
@Description function for start "Query: Absence of VAT invoices for sales" 4.3.2.
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
/*/
Function RU99X1102(cFilUser_)
local cName as character
local cDesc as character
Local cQuery as character
Local cCod  as  character
Local cOpcFil as character //opcional fields
local dDate as date
Local nVersion as Numeric
Local aSubQuery as array
Local aIdexOrd as array
Local cPerg as character
Local aSourDoc as Array //Source document open
Local aTotal as Array
Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200902')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0002'
cCod  := '000002'
cName := STR0023 //'Absence of VAT invoices for sales'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02)+', '+STR0028+' '+Iif(MV_PAR03==1,STR0030,(Iif(MV_PAR03==3,STR0032,STR0035)))
aTotal := {}

cOpcFil := 'F2_VALMERC,F2_VALBRUT,F2_MOEDA,F2_CONUNI,F2_TXMOEDA '
cDefFil := "F2_FILIAL,F2_CLIENTE,F2_LOJA,A1_NREDUZ,F2_SERIE,F2_DOC,F2_EMISSAO,F2_TIPO,F2_DTSAIDA,F35_DOC,F35_PDATE,F35_FILIAL,F35_TYPE"

cQuery := " select distinct RESULT,%FIELD:"+cDefFil+":FIELD% from ( " + ENTER
    cQuery += " select " + ENTER
    cQuery += " CASE WHEN  COALESCE(F35_PDATE, '') = '' THEN '.F.' ELSE '.T.' END AS RESULT, " + ENTER
    cQuery += " F2_FILIAL,F2_CLIENTE,F2_LOJA,COALESCE(A2_NREDUZ,A1_NREDUZ, '') as A1_NREDUZ,F2_SERIE,F2_DOC,F2_EMISSAO,F2_DTSAIDA,COALESCE(F35_DOC, ' ')  AS  F35_DOC,COALESCE(F35_PDATE, ' ')  as F35_PDATE" + ENTER
    cQuery += " ,F2_VALMERC,F2_VALBRUT,F2_MOEDA,F2_CONUNI,F2_TXMOEDA,F2_TIPO,F2_COND,COALESCE(A1_END,A2_END, ' ')  AS A1_END ,COALESCE(A1_BAIRRO,A2_BAIRRO, ' ')  AS  A1_BAIRRO,COALESCE(A1_EST,A2_EST, ' ')  AS  A1_EST,COALESCE(A1_CEP,A2_CEP, ' ')  AS  A1_CEP,COALESCE(F35_FILIAL, ' ')  AS F35_FILIAL,COALESCE(F35_TYPE, ' ')  AS F35_TYPE "
    cQuery += " from %TABLE:SF2% SF2 " + ENTER
    cQuery += " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F2_FILIAL% and SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_='' AND NOT (F2_TIPO IN ('D', 'B')) " + ENTER
    cQuery += " left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F2_FILIAL% and SA2.A2_COD=SF2.F2_CLIENTE AND SA2.A2_LOJA=SF2.F2_LOJA AND SA2.D_E_L_E_T_='' AND (F2_TIPO IN ('D', 'B'))" + ENTER
    cQuery += " LEFT JOIN  %TABLE:F36%  F36 ON F2_FILIAL = F36_FILIAL AND F2_DOC = F36_INVDOC AND F2_SERIE = F36_INVSER AND  F36.D_E_L_E_T_='' " + ENTER
    cQuery += " LEFT JOIN  %TABLE:F35%  F35 ON F2_FILIAL = F35_FILIAL AND F35_CLIENT = F2_CLIENTE and F35_BRANCH = F2_LOJA AND F36_KEY = F35_KEY AND F35_DOC = F36_DOC AND  F35.D_E_L_E_T_='' " + ENTER
    cQuery += " where F2_EMISSAO between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
    cQuery += " and SF2.D_E_L_E_T_='' AND NOT (F2_TIPO IN ('D', 'B'))" + ENTER
    cQuery += "     and F2_CLIENTE between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
    cQuery += "     and F2_LOJA between %Exp:MV_PAR05% and %Exp:MV_PAR07% " + ENTER
    cQuery += "     and F2_DOC between %Exp:MV_PAR08% and %Exp:MV_PAR10% " + ENTER
    cQuery += "     and F2_SERIE between %Exp:MV_PAR09% and %Exp:MV_PAR11% " + ENTER
    cQuery += "     and F2_FILIAL between %Exp:MV_PAR12% and %Exp:MV_PAR13% " + ENTER
    cQuery += "     and SF1.F1_ESPECIE='NF' " + ENTER
    //Branchs that user can access
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and SF2.F2_FILIAL in ("+cFilUser_ +") "+ ENTER
    EndIF
cQuery += " ) as TMP" + ENTER
//only with erros?
cQuery += " where ((%Exp:MV_PAR03% = 2 and F35_PDATE = ' ' ) or (%Exp:MV_PAR03% = 3  and F35_PDATE <> ' ' ) or (%Exp:MV_PAR03% = 1)) " + ENTER

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0006,'F2_FILIAL+F2_CLIENTE+F2_DTSAIDA' }) //'Branch+Customer+Issue Date'
aAdd(aIdexOrd,{ '2',STR0007,'F2_FILIAL+F2_DTSAIDA+F2_DOC' })

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F2_CLIENTE|F2_LOJA|A1_NREDUZ', 'F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO', 'SF2', 2 ,'RU99X11A1("SF2",2,(cCurrAlias)->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO) )',{ },'F2_FILIAL'}) //MATA030(,,2)
aAdd(aSourDoc,{'F2_SERIE|F2_DOC|F2_EMISSAO', 'F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO', 'SF2', 2 ,'CtbDocSaida()',{ {'aRotina','{{"","",0,2,0,Nil},	{"","",0,2,0,Nil},{"","",0,2,0,Nil},{"","",0,2,0,Nil}}'}},'F2_FILIAL'}) //MATA101N(,,2)
aAdd(aSourDoc,{'F35_DOC|F35_PDATE',;
                'PADR(F35_FILIAL,TamSX3("F35_FILIAL")[1])+PADR(dtos(F35_PDATE),TamSX3("F35_PDATE")[1])+PADR(F35_DOC,TamSX3("F35_DOC")[1])+PADR(F35_TYPE,TamSX3("F35_TYPE")[1])',;
                'F35',;
                1 ,;
                "RU99X11A4('RU09T02')",; //Vizualizadion 'default
                {;
                    {"cCadastro","''"},;
                     {"INCLUI",".F."};
                },'PADR(F35_FILIAL,TamSX3("F35_FILIAL")[1])'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}




/*/{Protheus.doc} RU99X1103
@Description function for start "Query: Timeliness of issuing of VAT sales invoices" 4.3.3.
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
/*/
Function RU99X1103(cFilUser_)
local cName as character

local cDesc as character
Local cQuery as character
Local cCod  as  character
Local cOpcFil as character //opcional fields
local dDate as date
Local nVersion as Numeric
Local aSubQuery as array
Local aIdexOrd as array
Local cPerg as character
Local aSourDoc as Array //Source document open
Local aTotal as Array
Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200729')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0003'
cCod  := '000003'
cName := STR0025 //'Timeliness of issuing of VAT sales invoices'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02)+', '+STR0028+' '+Iif(MV_PAR03==1,STR0030,STR0036)
aTotal := {}

cOpcFil := 'F2_VALMERC,F2_VALBRUT,F2_MOEDA,F2_CONUNI,F2_TXMOEDA,F2_COND '
cDefFil := "F2_FILIAL,F2_CLIENTE,F2_LOJA, A1_NREDUZ,F2_SERIE,F2_DOC,F2_EMISSAO,F2_DTSAIDA,F2_TIPO,F35_DOC,F35_PDATE,F35_FILIAL,F35_TYPE"

cQuery := " select " + ENTER
cQuery += " CASE WHEN  COALESCE(DIF_DAYS, 0) <= 4 THEN '.T.' ELSE '.F.' END AS RESULT, %FIELD:"+cDefFil+":FIELD% ,cast(COALESCE(DIF_DAYS, 0) as float) as _STR0005_ from ( " + ENTER
    cQuery += " select distinct" + ENTER
    cQuery += " F2_FILIAL,F2_CLIENTE,F2_LOJA,COALESCE(A2_NREDUZ,A1_NREDUZ, '') as A1_NREDUZ,F2_SERIE,F2_DOC,F2_EMISSAO,F2_DTSAIDA,COALESCE(F35_DOC, ' ')  F35_DOC,COALESCE(F35_PDATE, ' ')  F35_PDATE, " + ENTER
    //Verify DataBase Type
    If(DB_TYPE == "POSTGRES")
        cQuery += " DATE(F35_PDATE) - DATE(F2_DTSAIDA) as DIF_DAYS " + ENTER
    ElseIf(DB_TYPE == "MSSQL")
        cQuery += " DATEDIFF( day,CONVERT( DATE , F35_PDATE),CONVERT( DATE , F2_DTSAIDA))  as DIF_DAYS " + ENTER
    ElseIf(DB_TYPE == "ORACLE")
        cQuery += " TO_DATE(F35_PDATE, 'YYYYMMDD') - TO_DATE(F2_DTSAIDA, 'YYYYMMDD') as DIF_DAYS " + ENTER
    ELSE
        cQuery += " 0 as DIF_DAYS " + ENTER
    EndIf
    cQuery += ",F2_VALMERC,F2_VALBRUT,F2_MOEDA,F2_CONUNI,F2_TXMOEDA,F2_TIPO,F2_COND,COALESCE(A1_END,A2_END, ' ')  AS A1_END ,COALESCE(A1_BAIRRO,A2_BAIRRO, ' ')  AS  A1_BAIRRO, COALESCE(A1_EST,A2_EST, ' ')  AS  A1_EST,COALESCE(A1_CEP,A2_CEP, ' ')  AS  A1_CEP,COALESCE(F35_FILIAL, ' ')  AS F35_FILIAL,COALESCE(F35_TYPE, ' ')  AS F35_TYPE"
    cQuery += " from %TABLE:SF2% SF2 " + ENTER
    cQuery += " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F2_FILIAL% and SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.D_E_L_E_T_='' AND NOT (F2_TIPO IN ('D', 'B')) " + ENTER
    cQuery += " left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F2_FILIAL% and SA2.A2_COD=SF2.F2_CLIENTE AND SA2.A2_LOJA=SF2.F2_LOJA AND SA2.D_E_L_E_T_='' AND (F2_TIPO IN ('D', 'B'))" + ENTER
    cQuery += " INNER JOIN  %TABLE:F36%  F36 ON F2_FILIAL = F36_FILIAL AND F2_DOC = F36_INVDOC AND F2_SERIE = F36_INVSER AND  F36.D_E_L_E_T_='' " + ENTER
    cQuery += " INNER JOIN  %TABLE:F35%  F35 ON F2_FILIAL = F35_FILIAL AND F35_CLIENT = F2_CLIENTE and F35_BRANCH = F2_LOJA AND F36_KEY = F35_KEY AND F35_DOC = F36_DOC AND  F35.D_E_L_E_T_='' " + ENTER
    cQuery += " where F2_EMISSAO between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
    cQuery += " and SF2.D_E_L_E_T_=''  AND NOT (F2_TIPO IN ('D', 'B'))" + ENTER
    cQuery += "     and F2_CLIENTE between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
    cQuery += "     and F2_LOJA between %Exp:MV_PAR05% and %Exp:MV_PAR07% " + ENTER
    cQuery += "     and F2_DOC between %Exp:MV_PAR08% and %Exp:MV_PAR10% " + ENTER
    cQuery += "     and F2_SERIE between %Exp:MV_PAR09% and %Exp:MV_PAR11% " + ENTER
    cQuery += "     and F2_FILIAL between %Exp:MV_PAR12% and %Exp:MV_PAR13% " + ENTER
    //Branchs that user can access
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and SF2.F2_FILIAL in ("+cFilUser_ +") "+ ENTER
    EndIf
cQuery += " ) as TMP" + ENTER
//only with erros?  //4 days by low
cQuery += " where ((%Exp:MV_PAR03% = 2 and DIF_DAYS > 4 ) or (%Exp:MV_PAR03% = 1))" + ENTER

//Add subQuery //Field , title,query  , query
aAdd(aSubQuery,{'_STR0005_',' ',' ',STR0005,'',0 })

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0006,'F2_FILIAL+F2_CLIENTE+F2_DTSAIDA' })
aAdd(aIdexOrd,{ '2',STR0007,'F2_FILIAL+F2_DTSAIDA+F2_DOC' })

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F2_CLIENTE|F2_LOJA|A1_NREDUZ', 'F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO', 'SF2', 2 ,'RU99X11A1("SF2",2,(cCurrAlias)->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO) )',{ },'F2_FILIAL'}) //MATA030(,,2)
aAdd(aSourDoc,{'F2_SERIE|F2_DOC|F2_EMISSAO|F2_DTSAIDA', 'F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO', 'SF2', 2 ,'CtbDocSaida()',{ {'aRotina','{{"","",0,2,0,Nil},	{"","",0,2,0,Nil},{"","",0,2,0,Nil},{"","",0,2,0,Nil}}'}},'F2_FILIAL'}) //MATA101N(,,2)
aAdd(aSourDoc,{'F35_DOC|F35_PDATE',;
                'PADR(F35_FILIAL,TamSX3("F35_FILIAL")[1])+PADR(dtos(F35_PDATE),TamSX3("F35_PDATE")[1])+PADR(F35_DOC,TamSX3("F35_DOC")[1])+PADR(F35_TYPE,TamSX3("F35_TYPE")[1])',;
                'F35',;
                1 ,;
                "RU99X11A4('RU09T02')",; //Vizualizadion 'default
                {;
                    {"cCadastro","''"},{"INCLUI",".F."};
                },'PADR(F35_FILIAL,TamSX3("F35_FILIAL")[1])'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}






/*/{Protheus.doc} RU99X1104
@Description function for start "Query: Inflow VAT movements analyses" 4.3.4.
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
 /*/
Function RU99X1104(cFilUser_)
Local cName     as character
Local cDesc     as character
Local cQuery    as character
Local cCod      as  character
Local cOpcFil   as character //opcional fields
Local dDate     as date
Local nVersion  as Numeric
Local aSubQuery as array
Local aIdexOrd  as array
Local cPerg     as character
Local aSourDoc  as Array //Source document open
Local aTotal as Array
Local cSubq     as character

Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200729')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0004'
cCod  := '000004'
cName := STR0027//'Inflow VAT movements analyses'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02)
aTotal := {}

//Optional Fields
cOpcFil := ',F34_TYPE,F34_BOOKEY,F34_DOC,F34_PDATE, F34_KEY,F34_DATE'

//default fields, already at query
cDefFil := "F34_FILIAL,F34_SUPPL,F34_SUPUN,A2_NREDUZ,F34_VATRT,F34_VATCOD,F34_VATCD2,F31_TG_COD,F31_OPCODE,F31_FILIAL,A2_FILIAL"

cQuery := " select %FIELD:"+cDefFil+":FIELD%" + ENTER
cQuery += ' , cast(sum(STR0001_F34_VATBS) as float) as _STR0001_ ' + ENTER //STRInflow Base
cQuery += ' , cast(sum(STR0001_F34_VALUE) as float) as _STR0002_ ' + ENTER //Inflor Valur
cQuery += ' , cast(sum(STR0002_F34_VATBS) as float) as _STR0003_ ' + ENTER //STrOutflow base
cQuery += ' , cast(sum(STR0002_F34_VALUE) as float) as _STR0004_ ' + ENTER // Outf Value
cQuery += "  from ( " + ENTER
    cQuery += "select F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,'') as A2_NREDUZ, F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,A2_FILIAL" + ENTER //all fields
    cQuery += cOpcFil + ENTER
    cQuery += "  ,case when F34_TYPE IN ('01','04') then sum(F34_VATBS) else  0 end as STR0001_F34_VATBS, " + ENTER
    cQuery += "  case when F34_TYPE IN ('01','04') then sum(F34_VALUE) else  0 end as STR0001_F34_VALUE, " + ENTER
    cQuery += "  case when F34_TYPE NOT IN ('01','04') then sum(F34_VATBS) else  0 end as STR0002_F34_VATBS, " + ENTER
    cQuery += "  case when F34_TYPE NOT IN ('01','04') then sum(F34_VALUE) else  0 end as STR0002_F34_VALUE " + ENTER
    cQuery += "  FROM  %TABLE:F34% F34 " + ENTER
    cQuery += "  left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' " + ENTER
    cQuery += "  left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_='' " + ENTER
    cQuery += "  where F34.D_E_L_E_T_='' " + ENTER
    cQuery += "     and F34_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
    cQuery += "     and F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ENTER
    cQuery += "     and F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
    cQuery += "     and F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + ENTER
    //Branchs that user can access
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and F34.F34_FILIAL in ("+cFilUser_ +") "+ ENTER
    EndIf
    cQuery += " group by F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,''), F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' '),coalesce(F31_OPCODE,' '),coalesce(F31_FILIAL,' '),A2_FILIAL " + ENTER
    cQuery += cOpcFil
cQuery += " ) as TMP "
cQuery += " group by  %FIELD:"+cDefFil+":FIELD% "

//SubQuery was used for translation too
//Add subQuery //Field , title,query  , query
cSubq := " SELECT %FIELD:"+cDefFil+":FIELD% ,cast(sum(F34_VATBS) as float) as F34_VATBS,cast(sum(F34_VALUE) as float) as F34_VALUE from ( SELECT F34_VATBS,F34_VALUE ,F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,'') as A2_NREDUZ, F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,A2_FILIAL" +;
                                                                    cOpcFil + " from %TABLE:F34% F34"+;
                                                                    "  left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' "+;
                                                                    "  left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_='' "+;
                                                                    " where F34_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.D_E_L_E_T_=' ' and F34_TYPE IN ('01','04') and F34.F34_FILIAL = coalesce(%EXP:F34_FILIAL%,F34.F34_FILIAL) "+;
                                                                    ' and F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% and F34.F34_DIRECT = coalesce(%EXP:F34_DIRECT%,F34.F34_DIRECT)  and F34.F34_DATE = coalesce(%EXP:F34_DATE%,F34.F34_DATE) ' +;
                                                                    ' and F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% and F34.F34_TYPE = coalesce(%EXP:F34_TYPE%,F34.F34_TYPE)  and F34.F34_BOOKEY = coalesce(%EXP:F34_BOOKEY%,F34.F34_BOOKEY) ' +;
                                                                    ' and F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% and F34.F34_KEY = coalesce(%EXP:F34_KEY%,F34.F34_KEY)  and F34.F34_SUPPL = coalesce(%EXP:F34_SUPPL%,F34.F34_SUPPL) ' +;
                                                                    ' and F34.F34_SUPUN = coalesce(%EXP:F34_SUPUN%,F34.F34_SUPUN) and F34.F34_DOC = coalesce(%EXP:F34_DOC%,F34.F34_DOC) ' +;
                                                                    ' and F34.F34_PDATE = coalesce(%EXP:F34_PDATE%,F34.F34_PDATE) and F34.F34_VATCOD = coalesce(%EXP:F34_VATCOD%,F34.F34_VATCOD) ' +;
                                                                    ' and F34.F34_VATCD2 = coalesce(%EXP:F34_VATCD2%,F34.F34_VATCD2) and F34.F34_VATRT = coalesce(%EXP:F34_VATRT%,F34.F34_VATRT) ' +;
                                                                    ' and F34.F34_USER = coalesce(%EXP:F34_USER%,F34.F34_USER) and F34.F34_BOOK = coalesce(%EXP:F34_BOOK%,F34.F34_BOOK) ' +;
                                                                    ' and F34.F34_TG_COD = coalesce(%EXP:F34_TG_COD%,F34.F34_TG_COD) '+ IIf ( valtype(cFilUser_) <> 'U', " and F34.F34_FILIAL in ("+cFilUser_ +") " , "") + " " +;
                                                                    " and coalesce(A2_NREDUZ ,'') = coalesce(%EXP:A2_NREDUZ% ,coalesce(A2_NREDUZ ,'')) "+;
                                                                    " and coalesce(F31_TG_COD ,'') = coalesce(%EXP:F31_TG_COD% ,coalesce(F31_TG_COD ,'')) "+;
                                                                    " and coalesce(F31_OPCODE ,'') = coalesce(%EXP:F31_OPCODE% ,coalesce(F31_OPCODE ,'')) "+;
                                                                    " and coalesce(F31_FILIAL ,'') = coalesce(%EXP:F31_FILIAL% ,coalesce(F31_FILIAL ,'')) "+;
                                                                    " and coalesce(A2_FILIAL ,'') = coalesce(%EXP:A2_FILIAL% ,coalesce(A2_FILIAL ,'')) ) as temp group by  %FIELD:"+cDefFil+":FIELD% "

aAdd(aSubQuery,{'_STR0001_',' ',cSubq,STR0001,'',2 })
aAdd(aSubQuery,{'_STR0002_',' ',cSubq,STR0002,'',2 })

cSubq := " SELECT %FIELD:"+cDefFil+":FIELD% ,cast(sum(F34_VATBS) as float) as F34_VATBS,cast(sum(F34_VALUE) as float) as F34_VALUE from ( SELECT F34_VATBS,F34_VALUE ,F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,'') as A2_NREDUZ, F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,A2_FILIAL" +;
                                                                    cOpcFil + " from %TABLE:F34% F34"+;
                                                                    "  left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' "+;
                                                                    "  left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_='' "+;
                                                                    " where F34_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.D_E_L_E_T_=' ' and F34_TYPE NOT IN ('01','04') and F34.F34_FILIAL = coalesce(%EXP:F34_FILIAL%,F34.F34_FILIAL) "+;
                                                                    ' and F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% and F34.F34_DIRECT = coalesce(%EXP:F34_DIRECT%,F34.F34_DIRECT)  and F34.F34_DATE = coalesce(%EXP:F34_DATE%,F34.F34_DATE) ' +;
                                                                    ' and F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% and F34.F34_TYPE = coalesce(%EXP:F34_TYPE%,F34.F34_TYPE)  and F34.F34_BOOKEY = coalesce(%EXP:F34_BOOKEY%,F34.F34_BOOKEY) ' +;
                                                                    ' and F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% and F34.F34_KEY = coalesce(%EXP:F34_KEY%,F34.F34_KEY)  and F34.F34_SUPPL = coalesce(%EXP:F34_SUPPL%,F34.F34_SUPPL) ' +;
                                                                    ' and F34.F34_SUPUN = coalesce(%EXP:F34_SUPUN%,F34.F34_SUPUN) and F34.F34_DOC = coalesce(%EXP:F34_DOC%,F34.F34_DOC) ' +;
                                                                    ' and F34.F34_PDATE = coalesce(%EXP:F34_PDATE%,F34.F34_PDATE) and F34.F34_VATCOD = coalesce(%EXP:F34_VATCOD%,F34.F34_VATCOD) ' +;
                                                                    ' and F34.F34_VATCD2 = coalesce(%EXP:F34_VATCD2%,F34.F34_VATCD2) and F34.F34_VATRT = coalesce(%EXP:F34_VATRT%,F34.F34_VATRT) ' +;
                                                                    ' and F34.F34_USER = coalesce(%EXP:F34_USER%,F34.F34_USER) and F34.F34_BOOK = coalesce(%EXP:F34_BOOK%,F34.F34_BOOK) ' +;
                                                                    ' and F34.F34_TG_COD = coalesce(%EXP:F34_TG_COD%,F34.F34_TG_COD)'+ IIf ( valtype(cFilUser_) <> 'U', " and F34.F34_FILIAL in ("+cFilUser_ +") " , "") + " " +;
                                                                    " and coalesce(A2_NREDUZ ,'') = coalesce(%EXP:A2_NREDUZ% ,coalesce(A2_NREDUZ ,'')) "+;
                                                                    " and coalesce(F31_TG_COD ,'') = coalesce(%EXP:F31_TG_COD% ,coalesce(F31_TG_COD ,'')) "+;
                                                                    " and coalesce(F31_OPCODE ,'') = coalesce(%EXP:F31_OPCODE% ,coalesce(F31_OPCODE ,'')) "+;
                                                                    " and coalesce(F31_FILIAL ,'') = coalesce(%EXP:F31_FILIAL% ,coalesce(F31_FILIAL ,'')) "+;
                                                                    " and coalesce(A2_FILIAL ,'') = coalesce(%EXP:A2_FILIAL% ,coalesce(A2_FILIAL ,'')) ) as temp group by  %FIELD:"+cDefFil+":FIELD% "
aAdd(aSubQuery,{'_STR0003_',' ',cSubq,STR0003,'',2 })
aAdd(aSubQuery,{'_STR0004_',' ',cSubq,STR0004,'',2 })

aAdd(aSubQuery,{'F31_FILIAL',' ',' ',STR0011,'' }) // F31 Filial
aAdd(aSubQuery,{'A2_FILIAL',' ',' ',STR0013,'' }) // A2 Filial

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0008,'F34_FILIAL+F34_SUPPL+F34_PDATE' }) //Branch+Customer+Issue Date
aAdd(aIdexOrd,{ '2',STR0007,'F34_FILIAL+F34_PDATE+F34_DOC' }) //Branch+Issue Date+Invoice

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F34_SUPPL|F34_SUPUN', 'A2_FILIAL+F34_SUPPL+F34_SUPUN', 'SA2', 1 ,"RU99X11A4('MATA020')",{ },'A2_FILIAL' })
aAdd(aSourDoc,{'F34_VATCOD|F31_OPCODE|F31_TG_COD', 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])+F34_VATCOD', 'F31', 1 ,"RU99X11A4('RU09D02')",{ },'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])' })
aAdd(aSourDoc,{'F34_KEY|F34_DOC|F34_PDATE', 'F34_FILIAL+F34_KEY', 'F37', 3 ,"RU99X11A4('RU09T03')",{ {"INCLUI",".F."} },'F34_FILIAL' })
aAdd(aSourDoc,{'F34_BOOKEY|F34_DATE', 'F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2', "F34", 1 ,'RU99X11A2("F34",1,(cCurrAlias)->(F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2) )',{ {"INCLUI",".F."},{"ALTERA",".F."} }, 'F34_FILIAL'})

//Total Fields
aAdd(aTotal,{'_STR0001_'})
aAdd(aTotal,{'_STR0002_'})
aAdd(aTotal,{'_STR0003_'})
aAdd(aTotal,{'_STR0004_'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}




/*/{Protheus.doc} RU99X1104
@Description function for start "Outflow VAT movements analyses" 4.3.5.
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
/*/
Function RU99X1105(cFilUser_)
Local cName     as character
Local cDesc     as character
Local cQuery    as character
Local cCod      as  character
Local cOpcFil   as character //opcional fields
Local dDate     as date
Local nVersion  as Numeric
Local aSubQuery as array
Local aIdexOrd  as array
Local cPerg     as character
Local aSourDoc  as Array //Source document open
Local aTotal    as Array
Local cSubq     as character

Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200729')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0005'
cCod  := '000005'
cName := STR0029 //'Outflow VAT movements analyses'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02)
aTotal := {}

//Optional Fields
cOpcFil := ',F54_TYPE,F54_DOC,F54_PDATE,F54_KEY,F54_DATE,F54_REGKEY,F54_REGDOC'

//default fields
cDefFil := "F54_FILIAL,F54_CLIENT,F54_CLIBRA,A1_NREDUZ,F54_VATRT,F54_VATCOD,F31_TG_COD,F31_OPCODE,A1_FILIAL,F31_FILIAL"

cQuery := " select %FIELD:"+cDefFil+":FIELD%" + ENTER
cQuery += ' , sum(cast(INFLOW_BASE as float)) as _STR0001_ ' + ENTER //Inflow Base
cQuery += ' , sum(cast(INFLOW_VALUE as float)) as _STR0002_ ' + ENTER //Inflor Valur
cQuery += ' , sum(cast(OUTFLOW_BASE as float)) as _STR0003_ ' + ENTER //Outflow base
cQuery += ' , sum(cast(OUTFLOW_VALUE as float)) as _STR0004_ ' + ENTER // Outflow Value
cQuery += "  from ( " + ENTER
    cQuery += "select F54_DIRECT,F54_FILIAL,F54_CLIENT,F54_CLIBRA,coalesce(A1_NREDUZ, ' ') as A1_NREDUZ,F54_VATRT,F54_VATCOD,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL" + ENTER //all fields
    cQuery += cOpcFil + ENTER
    cQuery += ", case when F54_DIRECT='+' then sum(F54_VATBS) else 0 end as INFLOW_BASE, " + ENTER
    cQuery += "  case when F54_DIRECT='+' then sum(F54_VALUE) else 0 end as INFLOW_VALUE, " + ENTER
    cQuery += "  case when F54_DIRECT='-' then sum(F54_VATBS) else 0 end as OUTFLOW_BASE, " + ENTER
    cQuery += "  case when F54_DIRECT='-' then sum(F54_VALUE) else 0 end as OUTFLOW_VALUE,coalesce(A1_FILIAL,' ') as A1_FILIAL " + ENTER
    cQuery += "  FROM  %TABLE:F54% F54 " + ENTER
    cQuery += " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F54_FILIAL% and  SA1.A1_COD=F54.F54_CLIENT AND SA1.A1_LOJA=F54.F54_CLIBRA AND SA1.D_E_L_E_T_='' " + ENTER
    cQuery += "  left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F54_FILIAL% and F31.F31_CODE=F54.F54_VATCOD AND F31.D_E_L_E_T_='' " + ENTER
    cQuery += "  where F54.D_E_L_E_T_='' " + ENTER
    cQuery += "     and F54_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
    cQuery += "     and F54_CLIENT between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ENTER
    cQuery += "     and F54_CLIBRA between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
    cQuery += "     and F54_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + ENTER
    //Branchs that user can access
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and F54.F54_FILIAL in ("+cFilUser_ +") "+ ENTER
    EndIf
    cQuery += " group by F54_DIRECT, F54_DIRECT,F54_FILIAL,F54_CLIENT,F54_CLIBRA,coalesce(A1_NREDUZ, ' ') ,F54_VATRT,F54_VATCOD,coalesce(F31_TG_COD,' '),coalesce(F31_OPCODE,' '),coalesce(F31_FILIAL,' '),coalesce(A1_FILIAL,' ')   " + ENTER
    cQuery += cOpcFil
cQuery += " ) as TMP "
cQuery += " group by  %FIELD:"+cDefFil+":FIELD%  "

//SubQuery was used for translation too
//Add subQuery //Field , title,query  , query
cSubq := " SELECT %FIELD:"+cDefFil+":FIELD% ,sum(F54_VATBS) as F54_VATBS, sum(F54_VALUE) as F54_VALUE from (  select F54_VATBS,F54_VALUE,F54_DIRECT,F54_FILIAL,F54_CLIENT,F54_CLIBRA,coalesce(A1_NREDUZ, ' ') as A1_NREDUZ,F54_VATRT,F54_VATCOD,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,coalesce(A1_FILIAL,' ') as A1_FILIAL "+;
                                cOpcFil +' FROM %TABLE:F54% F54 '+;
                                " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F54_FILIAL% and  SA1.A1_COD=F54.F54_CLIENT AND SA1.A1_LOJA=F54.F54_CLIBRA AND SA1.D_E_L_E_T_='' " +;
                                " left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F54_FILIAL% and F31.F31_CODE=F54.F54_VATCOD AND F31.D_E_L_E_T_='' " +;
                                " Where  F54.D_E_L_E_T_='' and F54_DIRECT='+' AND "+;
                                " F54_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02%   and F54_CLIENT between %Exp:MV_PAR03% and %Exp:MV_PAR05%  and F54_CLIBRA between %Exp:MV_PAR04% and %Exp:MV_PAR06%  and F54_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% and "+ IIf ( valtype(cFilUser_) <> 'U', " F54_FILIAL in ("+cFilUser_ +") and " , "") + " " +;
                                ' F54_FILIAL		= coalesce(%EXP:F54_FILIAL%,F54_FILIAL) and F54_DATE  	= coalesce(%EXP:F54_DATE%,F54_DATE) and '+;
                                ' F54_TYPE  		= coalesce(%EXP:F54_TYPE%,F54_TYPE)     and F54_CLIENT	= coalesce(%EXP:F54_CLIENT%,F54_CLIENT) and '+;
                                ' F54_CLIBRA		= coalesce(%EXP:F54_CLIBRA%,F54_CLIBRA) and F54_KEY     = coalesce(%EXP:F54_KEY%,F54_KEY) and '+;
                                ' F54_DOC   		= coalesce(%EXP:F54_DOC%,F54_DOC)       and F54_PDATE 	= coalesce(%EXP:F54_PDATE%,F54_PDATE) and '+;
                                ' F54_VATCOD		= coalesce(%EXP:F54_VATCOD%,F54_VATCOD) and '+;
                                ' F54_VATRT 		= coalesce(%EXP:F54_VATRT%,F54_VATRT)   and '+;
                                ' F54_REGKEY		= coalesce(%EXP:F54_REGKEY%,F54_REGKEY) and F54_REGDOC  = coalesce(%EXP:F54_REGDOC%,F54_REGDOC)'+;
                                " and coalesce(A1_NREDUZ ,'') = coalesce(%EXP:A1_NREDUZ% ,coalesce(A1_NREDUZ ,'')) "+;
                                " and coalesce(F31_TG_COD ,'') = coalesce(%EXP:F31_TG_COD% ,coalesce(F31_TG_COD ,'')) "+;
                                " and coalesce(F31_OPCODE ,'') = coalesce(%EXP:F31_OPCODE% ,coalesce(F31_OPCODE ,'')) "+;
                                " and coalesce(F31_FILIAL ,'') = coalesce(%EXP:F31_FILIAL% ,coalesce(F31_FILIAL ,''))  ) as temp group by %FIELD:"+cDefFil+":FIELD% "
aAdd(aSubQuery,{'_STR0001_',' ',cSubq,STR0001,'',2 })
aAdd(aSubQuery,{'_STR0002_',' ',cSubq,STR0002,'',2 })

cSubq := " SELECT %FIELD:"+cDefFil+":FIELD% ,sum(F54_VATBS) as F54_VATBS,sum(F54_VALUE) as F54_VALUE from (  select F54_VATBS,F54_VALUE,F54_DIRECT,F54_FILIAL,F54_CLIENT,F54_CLIBRA,coalesce(A1_NREDUZ, ' ') as A1_NREDUZ,F54_VATRT,F54_VATCOD,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,coalesce(A1_FILIAL,' ') as A1_FILIAL "+;
                                cOpcFil +' FROM %TABLE:F54% F54 '+;
                                " left join %TABLE:SA1% SA1 on SA1.A1_FILIAL = %XFILIAL:SA1:F54_FILIAL% and  SA1.A1_COD=F54.F54_CLIENT AND SA1.A1_LOJA=F54.F54_CLIBRA AND SA1.D_E_L_E_T_='' " +;
                                " left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F54_FILIAL% and F31.F31_CODE=F54.F54_VATCOD AND F31.D_E_L_E_T_='' " +;
                                " Where  F54.D_E_L_E_T_='' and F54_DIRECT='-' AND "+;
                                " F54_PDATE between %Exp:MV_PAR01% and %Exp:MV_PAR02%   and F54_CLIENT between %Exp:MV_PAR03% and %Exp:MV_PAR05%  and F54_CLIBRA between %Exp:MV_PAR04% and %Exp:MV_PAR06%  and F54_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% and "+ IIf ( valtype(cFilUser_) <> 'U', " F54_FILIAL in ("+cFilUser_ +") and " , "") + " " +;
                                ' F54_FILIAL		= coalesce(%EXP:F54_FILIAL%,F54_FILIAL) and F54_DATE  	= coalesce(%EXP:F54_DATE%,F54_DATE) and '+;
                                ' F54_TYPE  		= coalesce(%EXP:F54_TYPE%,F54_TYPE)     and F54_CLIENT	= coalesce(%EXP:F54_CLIENT%,F54_CLIENT) and '+;
                                ' F54_CLIBRA		= coalesce(%EXP:F54_CLIBRA%,F54_CLIBRA) and F54_KEY     = coalesce(%EXP:F54_KEY%,F54_KEY) and '+;
                                ' F54_DOC   		= coalesce(%EXP:F54_DOC%,F54_DOC)       and F54_PDATE 	= coalesce(%EXP:F54_PDATE%,F54_PDATE) and '+;
                                ' F54_VATCOD		= coalesce(%EXP:F54_VATCOD%,F54_VATCOD) and '+;
                                ' F54_VATRT 		= coalesce(%EXP:F54_VATRT%,F54_VATRT)   and '+;
                                ' F54_REGKEY		= coalesce(%EXP:F54_REGKEY%,F54_REGKEY) and F54_REGDOC  = coalesce(%EXP:F54_REGDOC%,F54_REGDOC)'+;
                                " and coalesce(A1_NREDUZ ,'') = coalesce(%EXP:A1_NREDUZ% ,coalesce(A1_NREDUZ ,'')) "+;
                                " and coalesce(F31_TG_COD ,'') = coalesce(%EXP:F31_TG_COD% ,coalesce(F31_TG_COD ,'')) "+;
                                " and coalesce(F31_OPCODE ,'') = coalesce(%EXP:F31_OPCODE% ,coalesce(F31_OPCODE ,'')) "+;
                                " and coalesce(F31_FILIAL ,'') = coalesce(%EXP:F31_FILIAL% ,coalesce(F31_FILIAL ,''))  ) as temp group by %FIELD:"+cDefFil+":FIELD%"
aAdd(aSubQuery,{'_STR0003_',' ',cSubq,STR0003,'',2 })
aAdd(aSubQuery,{'_STR0004_',' ',cSubq,STR0004,'',2 })

aAdd(aSubQuery,{'A1_FILIAL' ,' ',' ',STR0012,'' }) // Customer Filial
aAdd(aSubQuery,{'F31_FILIAL',' ',' ',STR0011,'' }) // F31 Filial

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0006,'F54_FILIAL+F54_CLIENT+F54_PDATE' })
aAdd(aIdexOrd,{ '2',STR0007,'F34_FILIAL+F54_PDATE+F54_DOC' })

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F54_CLIENT|F54_SUPUN', 'PADR(A1_FILIAL,TamSX3("A1_FILIAL")[1])+F54_CLIENT+F54_CLIBRA', 'SA1', 1 ,"AxVisual('SA1',recno(),2)",{ {"cCadastro","''"} },'PADR(A1_FILIAL,TamSX3("A1_FILIAL")[1])' })
aAdd(aSourDoc,{'F54_VATCOD', 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])+F54_VATCOD', 'F31', 1 ,"RU99X11A4('RU09D02')",{ } , 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])'})
aAdd(aSourDoc,{'F54_KEY|F54_DOC|F54_PDATE', 'F54_FILIAL+F54_KEY', 'F35', 3 ,"RU99X11A4('RU09T02')",{ {"INCLUI",".F."} }, 'F54_FILIAL' })
aAdd(aSourDoc,{'F54_REGKEY|F54_DATE', 'F54_FILIAL+F54_DOC+DTOS(F54_DATE)+F54_TYPE+F54_KEY+F54_REGDOC+F54_REGKEY+F54_VATCOD', "F54", 1 ,'RU99X11A2("F54",1,(cCurrAlias)->(F54_FILIAL+F54_DOC+DTOS(F54_DATE)+F54_TYPE+F54_KEY+F54_REGDOC+F54_REGKEY+F54_VATCOD) )',{ {"INCLUI",".F."},{"ALTERA",".F."} }, 'F54_FILIAL'})

//Total Fields
aAdd(aTotal,{'_STR0001_'})
aAdd(aTotal,{'_STR0002_'})
aAdd(aTotal,{'_STR0003_'})
aAdd(aTotal,{'_STR0004_'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}







/*/{Protheus.doc} RU99X1106
@Description function for start "Query: Inflow VAT turnover sheet" 4.3.6.
@type Static Function
@author Rafael Goncalves da Silva
@since jan|2020
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
/*/
Function RU99X1106(cFilUser_)
Local cName     as character
Local cDesc     as character
Local cQuery    as character
Local cCod      as  character
Local cOpcFil   as character //opcional fields
Local dDate     as date
Local nVersion  as Numeric
Local aSubQuery as array
Local aIdexOrd  as array
Local cPerg     as character
Local aSourDoc  as Array //Source document open
Local aTotal as Array
Local cSubq     as character

Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200729')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0006'
cCod  := '000006'
cName := STR0031 //'Inflow VAT turnover sheet'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0024 +' '+dtoc(MV_PAR01) +' '+ STR0026 +' '+ dtoc(MV_PAR02)
aTotal := {}

//Optional Fields
cOpcFil := ',F34_TYPE,F34_BOOKEY,F34_PDATE, F34_KEY,F34_DATE'
//default fields, already at query
cDefFil := "F34_FILIAL,F34_SUPPL,F34_SUPUN,A2_NREDUZ,F34_DOC,F34_VATRT,F34_VATCOD,F34_VATCD2,F31_TG_COD,F31_OPCODE,F31_FILIAL,A2_FILIAL"

//group information
cQuery := " select %FIELD:"+cDefFil+":FIELD%" + ENTER
//cQuery += " F34_FILIAL, F34_VATRT, F34_VATCOD, F34_SUPPL,F34_SUPUN, F34_DOC, F34_PDATE, F34_KEY, " + ENTER
cQuery += " ,sum(cast(F34_BASE_BEFF as float)) as _STR0016_, " + ENTER
cQuery += " sum(cast(F34_VALUE_BEFF as float)) as _STR0017_, " + ENTER
cQuery += " sum(cast(INFLOW_BASE as float)) as _STR0001_, " + ENTER
cQuery += " sum(cast(INFLOW_VALUE as float)) as _STR0002_, " + ENTER
cQuery += " sum(cast(OUTFLOW_BASE as float)) as _STR0003_, " + ENTER
cQuery += " sum(cast(OUTFLOW_VALUE as float)) as _STR0004_, " + ENTER
cQuery += "  SUM(cast(F34_BASE_BEFF as float)) + SUM(cast(INFLOW_BASE as float)) - SUM(cast(OUTFLOW_BASE as float)) AS _STR0018_, " + ENTER
 cQuery += " SUM(cast(F34_VALUE_BEFF as float)) + SUM(cast(INFLOW_VALUE as float)) - SUM(cast(OUTFLOW_VALUE as float)) AS _STR0019_ " + ENTER
cQuery += " from ( " + ENTER
    //List all records and create total collumns
cQuery += "     select " + ENTER
cQuery += "     case when F34.F34_DATE < %Exp:MV_PAR01% then F34.F34_VATBS * (case when F34.F34_TYPE IN ('01','04') then 1 else -1 end) else 0 end  as F34_BASE_BEFF, " + ENTER
cQuery += "     case when F34.F34_DATE < %Exp:MV_PAR01% then F34.F34_VALUE * (case when F34.F34_TYPE IN ('01','04') then 1 else -1 end) else 0 end as F34_VALUE_BEFF, " + ENTER

cQuery += "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE IN ('01','04') then F34.F34_VATBS else 0 end as INFLOW_BASE, " + ENTER
cQuery += "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE IN ('01','04') then F34.F34_VALUE else 0 end as INFLOW_VALUE, " + ENTER
cQuery += "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE NOT IN ('01','04') then F34.F34_VATBS else 0 end as OUTFLOW_BASE, " + ENTER
cQuery += "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE NOT IN ('01','04') then F34.F34_VALUE else 0 end as OUTFLOW_VALUE, " + ENTER
cQuery += "     F34.*, coalesce(A2_NREDUZ,'') as A2_NREDUZ,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,coalesce(A2_FILIAL,' ') as A2_FILIAL" + ENTER //all fields
cQuery += "     from ( " + ENTER
        //Found moviments at fiters conditions
cQuery += "         Select F341.F34_FILIAL, F341.F34_VATRT, F341.F34_VATCOD, F341.F34_SUPPL,F341.F34_SUPUN, F341.F34_DOC, F341.F34_PDATE, F341.F34_KEY,F341.F34_VATCD2 from %TABLE:F34% F341 " + ENTER
cQuery += "         where F341.D_E_L_E_T_ = ' ' " + ENTER
cQuery += "             and F341.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ENTER
cQuery += "             and F341.F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ENTER
cQuery += "             and F341.F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
cQuery += "             and F341.F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + ENTER
    //Branchs that user can access
If valtype(cFilUser_) <> 'U' //Branchs that user can access
    cQuery += "             and F341.F34_FILIAL in ("+cFilUser_ +") "+ ENTER
EndIf
cQuery += "         union " + ENTER
        //has Open balance without movements filter monivemtns conditions
cQuery += "             select TMPSEL.F34_FILIAL, TMPSEL.F34_VATRT, TMPSEL.F34_VATCOD, TMPSEL.F34_SUPPL,TMPSEL.F34_SUPUN, TMPSEL.F34_DOC, TMPSEL.F34_PDATE, TMPSEL.F34_KEY,TMPSEL.F34_VATCD2 from ( " + ENTER
cQuery += "                 select  sum(F342.F34_VATBS * (case when F342.F34_TYPE IN ('01','04') then 1 else -1 end)) as F34_BASE_RES, " + ENTER
cQuery += "                         sum(F342.F34_VALUE * (case when F342.F34_TYPE IN ('01','04') then 1 else -1 end)) as F34_VALUE_RES, " + ENTER
cQuery += "                         F342.F34_FILIAL, F342.F34_VATRT, F342.F34_VATCOD, F342.F34_SUPPL,F342.F34_SUPUN, F342.F34_DOC, F342.F34_PDATE, F342.F34_KEY,F342.F34_VATCD2 from %TABLE:F34% F342 " + ENTER
cQuery += "                 where F342.D_E_L_E_T_ = ' ' " + ENTER
cQuery += "                 and F342.F34_DATE <= %Exp:MV_PAR02% " + ENTER
cQuery += "                 and F342.F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ENTER
cQuery += "                 and F342.F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ENTER
cQuery += "                 and F342.F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + ENTER
//Branchs that user can access
If valtype(cFilUser_) <> 'U' //Branchs that user can access
    cQuery += "                 and F342.F34_FILIAL in ("+cFilUser_ +") "+ ENTER
EndIf
cQuery += "                 group by F342.F34_FILIAL, F342.F34_VATRT, F342.F34_VATCOD, F342.F34_SUPPL,F342.F34_SUPUN, F342.F34_DOC, F342.F34_PDATE, F342.F34_KEY,F342.F34_VATCD2 " + ENTER
cQuery += "                 ) as TMPSEL " + ENTER
cQuery += "                 where " + ENTER
cQuery += "                     (abs(TMPSEL.F34_BASE_RES) >= 0.01 or abs(TMPSEL.F34_VALUE_RES) >= 0.01) " + ENTER
cQuery += "             ) as TMP " + ENTER
cQuery += "     inner join %TABLE:F34% F34 on F34.F34_FILIAL = TMP.F34_FILIAL  and F34.F34_KEY =  TMP.F34_KEY " + ENTER
cQuery += "             and F34.F34_SUPPL =  TMP.F34_SUPPL  and F34.F34_SUPUN =  TMP.F34_SUPUN  and F34.F34_DOC =  TMP.F34_DOC  and F34.F34_PDATE =  TMP.F34_PDATE " + ENTER
cQuery += "             and F34.F34_VATCOD =  TMP.F34_VATCOD  and F34.F34_VATCD2 =  TMP.F34_VATCD2  and F34.F34_VATRT =  TMP.F34_VATRT  and F34.D_E_L_E_T_ = ' ' " + ENTER
cQuery += "      left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=TMP.F34_SUPPL AND SA2.A2_LOJA=TMP.F34_SUPUN AND SA2.D_E_L_E_T_='' " + ENTER
cQuery += "      left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:TMP.F34_FILIAL% and F31.F31_CODE=TMP.F34_VATCOD AND F31.D_E_L_E_T_='' " + ENTER
cQuery += " ) as TMP2 " + ENTER
cQuery += " group by %FIELD:"+cDefFil+":FIELD% "// order by %FIELD:"+cDefFil+":FIELD% "


cSubq :=  "SELECT %FIELD:"+cDefFil+":FIELD% , " + ;
                " sum(cast(F34_BASE_BEFF as float)) as _STR0016_, " + ;
                " sum(cast(F34_VALUE_BEFF as float)) as _STR0017_, " + ;
                " sum(cast(INFLOW_BASE as float)) as _STR0001_, " + ;
                " sum(cast(INFLOW_VALUE as float)) as _STR0002_, " + ;
                " sum(cast(OUTFLOW_BASE as float)) as _STR0003_, " + ;
                " sum(cast(OUTFLOW_VALUE as float)) as _STR0004_, " + ;
                " sum(cast(F34_BASE_BEFF as float)) + SUM(cast(INFLOW_BASE as float)) - SUM(cast(OUTFLOW_BASE as float)) AS _STR0018_, " + ;
                " sum(cast(F34_VALUE_BEFF as float)) + SUM(cast(INFLOW_VALUE as float)) - SUM(cast(OUTFLOW_VALUE as float)) AS _STR0019_ " + ;
                " from ( " + ;
                    " select "+;
                        "     case when F34.F34_DATE < %Exp:MV_PAR01% then F34.F34_VATBS * (case when F34.F34_TYPE IN ('01','04') then 1 else -1 end) else 0 end  as F34_BASE_BEFF, " + ;
                        "     case when F34.F34_DATE < %Exp:MV_PAR01% then F34.F34_VALUE * (case when F34.F34_TYPE IN ('01','04') then 1 else -1 end) else 0 end as F34_VALUE_BEFF, " + ;
                        "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE IN ('01','04') then F34.F34_VATBS else 0 end as INFLOW_BASE, " + ;
                        "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE IN ('01','04') then F34.F34_VALUE else 0 end as INFLOW_VALUE, " + ;
                        "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE NOT IN ('01','04') then F34.F34_VATBS else 0 end as OUTFLOW_BASE, " + ;
                        "     case when F34.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% and F34.F34_TYPE NOT IN ('01','04') then F34.F34_VALUE else 0 end as OUTFLOW_VALUE, " + ;
                        "      F34.F34_FILIAL,F34.F34_SUPPL,F34.F34_SUPUN,F34.F34_DOC,F34.F34_VATRT,F34.F34_VATCOD,F34.F34_VATCD2,F34.F34_TYPE,F34.F34_BOOKEY,F34.F34_PDATE, F34.F34_KEY,F34.F34_DATE, coalesce(A2_NREDUZ,'') as A2_NREDUZ,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,coalesce(A2_FILIAL,' ') as A2_FILIAL"+;
                        " from ( " +;  //Found moviments at fiters conditions
                            "         Select F341.F34_FILIAL, F341.F34_VATRT, F341.F34_VATCOD, F341.F34_SUPPL,F341.F34_SUPUN, F341.F34_DOC, F341.F34_PDATE, F341.F34_KEY,F341.F34_VATCD2 from %TABLE:F34% F341 " + ;
                            "         where F341.D_E_L_E_T_ = ' ' " + ;
                            "             and F341.F34_DATE between %Exp:MV_PAR01% and %Exp:MV_PAR02% " + ;
                            "             and F341.F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ;
                            "             and F341.F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ;
                            "             and F341.F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + IIf ( valtype(cFilUser_) <> 'U', " and F341.F34_FILIAL in ("+cFilUser_ +") " , "") + " " +;
                            "union " + ;//has Open balance without movements filter moviments conditions
                            "             select TMPSEL.F34_FILIAL, TMPSEL.F34_VATRT, TMPSEL.F34_VATCOD, TMPSEL.F34_SUPPL,TMPSEL.F34_SUPUN, TMPSEL.F34_DOC, TMPSEL.F34_PDATE, TMPSEL.F34_KEY,TMPSEL.F34_VATCD2 from ( " + ;
                            "                 select  sum(F342.F34_VATBS * (case when F342.F34_TYPE IN ('01','04') then 1 else -1 end)) as F34_BASE_RES, " + ;
                            "                         sum(F342.F34_VALUE * (case when F342.F34_TYPE IN ('01','04') then 1 else -1 end)) as F34_VALUE_RES, " + ;
                            "                         F342.F34_FILIAL, F342.F34_VATRT, F342.F34_VATCOD, F342.F34_SUPPL,F342.F34_SUPUN, F342.F34_DOC, F342.F34_PDATE, F342.F34_KEY,F342.F34_VATCD2 from %TABLE:F34% F342 " + ;
                            "                 where F342.D_E_L_E_T_ = ' ' " + ;
                            "                 and F342.F34_DATE <= %Exp:MV_PAR02% " + ;
                            "                 and F342.F34_SUPPL between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ;
                            "                 and F342.F34_SUPUN between %Exp:MV_PAR04% and %Exp:MV_PAR06% " + ;
                            "                 and F342.F34_FILIAL between %Exp:MV_PAR07% and %Exp:MV_PAR08% " + IIf ( valtype(cFilUser_) <> 'U', " and F342.F34_FILIAL in ("+cFilUser_ +") " , "") + " " +;
                            "                 group by F342.F34_FILIAL, F342.F34_VATRT, F342.F34_VATCOD, F342.F34_SUPPL,F342.F34_SUPUN, F342.F34_DOC, F342.F34_PDATE, F342.F34_KEY,F342.F34_VATCD2 " + ;
                            "                 ) as TMPSEL " + ;
                            "                 where " + ;
                            "                     (abs(TMPSEL.F34_BASE_RES) >= 0.01 or abs(TMPSEL.F34_VALUE_RES) >= 0.01) " + ;
                            "             ) as TMP " + ;
                            "     inner join %TABLE:F34% F34 on F34.F34_FILIAL = TMP.F34_FILIAL  and F34.F34_KEY =  TMP.F34_KEY " + ;
                            "             and F34.F34_SUPPL =  TMP.F34_SUPPL  and F34.F34_SUPUN =  TMP.F34_SUPUN  and F34.F34_DOC =  TMP.F34_DOC  and F34.F34_PDATE =  TMP.F34_PDATE " + ;
                            "             and F34.F34_VATCOD =  TMP.F34_VATCOD  and F34.F34_VATCD2 =  TMP.F34_VATCD2  and F34.F34_VATRT =  TMP.F34_VATRT  and F34.D_E_L_E_T_ = ' ' " + ;
                            "      left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' " +;
                            "      left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34.F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_='' "+;
                                " where F34.D_E_L_E_T_=' ' and F34.F34_DATE <= %Exp:MV_PAR02%  and F34.F34_FILIAL = coalesce(%EXP:F34_FILIAL%,F34.F34_FILIAL) "+;
                                ' and F34.F34_DIRECT = coalesce(%EXP:F34_DIRECT%,F34.F34_DIRECT)  ' +;
                                ' and F34.F34_TYPE = coalesce(%EXP:F34_TYPE%,F34.F34_TYPE)  and F34.F34_BOOKEY = coalesce(%EXP:F34_BOOKEY%,F34.F34_BOOKEY) ' +;
                                ' and F34.F34_KEY = coalesce(%EXP:F34_KEY%,F34.F34_KEY)  and F34.F34_SUPPL = coalesce(%EXP:F34_SUPPL%,F34.F34_SUPPL) ' +;
                                ' and F34.F34_SUPUN = coalesce(%EXP:F34_SUPUN%,F34.F34_SUPUN) and F34.F34_DOC = coalesce(%EXP:F34_DOC%,F34.F34_DOC) ' +;
                                ' and F34.F34_PDATE = coalesce(%EXP:F34_PDATE%,F34.F34_PDATE) and F34.F34_VATCOD = coalesce(%EXP:F34_VATCOD%,F34.F34_VATCOD) ' +;
                                ' and F34.F34_VATCD2 = coalesce(%EXP:F34_VATCD2%,F34.F34_VATCD2) and F34.F34_VATRT = coalesce(%EXP:F34_VATRT%,F34.F34_VATRT) ' +;
                                ' and F34.F34_USER = coalesce(%EXP:F34_USER%,F34.F34_USER) and F34.F34_BOOK = coalesce(%EXP:F34_BOOK%,F34.F34_BOOK) ' +;
                                ' and F34.F34_TG_COD = coalesce(%EXP:F34_TG_COD%,F34.F34_TG_COD) ' +;
                                " and coalesce(A2_NREDUZ ,'') = coalesce(%EXP:A2_NREDUZ% ,coalesce(A2_NREDUZ ,'')) and coalesce(F31_TG_COD,'') = coalesce(%EXP:F31_TG_COD%,coalesce(F31_TG_COD,'')) " +;
                                " and coalesce(F31_OPCODE,'') = coalesce(%EXP:F31_OPCODE%,coalesce(F31_OPCODE,'')) and coalesce(F31_FILIAL,'') = coalesce(%EXP:F31_FILIAL%,coalesce(F31_FILIAL,'')) " +;
                                " and coalesce(A2_FILIAL ,'') = coalesce(%EXP:A2_FILIAL% ,coalesce(A2_FILIAL ,''))"+;
                        " ) as TEMPPRI " +;
                        " group by %FIELD:"+cDefFil+":FIELD% "
aAdd(aSubQuery,{'_STR0016_',' ',cSubq,STR0016,'',2 }) //Initial Base
aAdd(aSubQuery,{'_STR0017_',' ',cSubq,STR0017,'',2 }) //Initial Value
aAdd(aSubQuery,{'_STR0001_',' ',cSubq,STR0001,'',2 }) //Inflow Base
aAdd(aSubQuery,{'_STR0002_',' ',cSubq,STR0002,'',2 }) //Inflow Value
aAdd(aSubQuery,{'_STR0003_',' ',cSubq,STR0003,'',2 }) //Outflow Base
aAdd(aSubQuery,{'_STR0004_',' ',cSubq,STR0004,'',2 }) //Outflow Value
aAdd(aSubQuery,{'_STR0018_',' ',cSubq,STR0018,'',2 }) //Final Base
aAdd(aSubQuery,{'_STR0019_',' ',cSubq,STR0019,'',2 }) //Final Value

aAdd(aSubQuery,{'F31_FILIAL',' ',' ',STR0011,'' }) // F31 Filial
aAdd(aSubQuery,{'A2_FILIAL',' ',' ',STR0013,'' }) // A2 Filial

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0008,'F34_FILIAL+F34_SUPPL+F34_PDATE' }) //Branch+Customer+Issue Date
aAdd(aIdexOrd,{ '2',STR0007,'F34_FILIAL+F34_PDATE+F34_DOC' }) //Branch+Issue Date+Invoice

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F34_SUPPL|F34_SUPUN', 'PADR(A2_FILIAL,TamSX3("A2_FILIAL")[1])+F34_SUPPL+F34_SUPUN', 'SA2', 1 ,"RU99X11A4('MATA020')",{ }, 'PADR(A2_FILIAL,TamSX3("A2_FILIAL")[1])' })
aAdd(aSourDoc,{'F34_VATCOD|F31_OPCODE|F31_TG_COD', 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])+F34_VATCOD', 'F31', 1 ,"RU99X11A4('RU09D02')",{ }, 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])' })
aAdd(aSourDoc,{'F34_KEY|F34_DOC|F34_PDATE', 'F34_FILIAL+F34_KEY', 'F37', 3 ,"RU99X11A4('RU09T03')",{ {"INCLUI",".F."} }, 'F34_FILIAL' })
aAdd(aSourDoc,{'F34_BOOKEY|F34_DATE', 'F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2', "F34", 1 ,'RU99X11A2("F34",1,(cCurrAlias)->(F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2) )',{ {"INCLUI",".F."},{"ALTERA",".F."} }, 'F34_FILIAL'})

//Total Fields
aAdd(aTotal,{'_STR0001_'})
aAdd(aTotal,{'_STR0002_'})
aAdd(aTotal,{'_STR0003_'})
aAdd(aTotal,{'_STR0004_'})
aAdd(aTotal,{'_STR0016_'})
aAdd(aTotal,{'_STR0017_'})
aAdd(aTotal,{'_STR0018_'})
aAdd(aTotal,{'_STR0019_'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}





/*/{Protheus.doc} RU99X1107
@Description function for start "Query: Negative balances of inflow VAT" 4.3.7.
@type Static Function
@author Rafael Goncalves da Silva
@since Jan|2020
@return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}
 /*/
Function RU99X1107(cFilUser_)
Local cName as character
Local cDesc as character
Local cQuery as character
Local cCod  as  character
Local cOpcFil as character //opcional fields
Local dDate as date
Local nVersion as Numeric
Local aSubQuery as array
Local aIdexOrd as array
Local cPerg as character
Local aSourDoc as Array //Source document open
Local aTotal as Array
Local cSubq as Character
Default cFilUser_ := RU99X11A3()

//Changing LAST date
dDate := stod('20200729')   //when was small changes, update here only
nVersion := 1               // when was big change, also change here
aSubQuery := {}
aIdexOrd  := {}
aSourDoc    := {}

cPerg := 'QE0007'
cCod  := '000007'
cName := STR0033//'Negative balances of inflow VAT'
Pergunte(alltrim(cPerg), .F.)
cDesc := cName + ' - ' + STR0021 +' '+ STR0037 +' '+dtoc(MV_PAR01)
aTotal := {}

//Optional Fields
cOpcFil := ',F34_TYPE,F34_BOOKEY,F34_KEY,F34_DATE'

//default fields, already at query
cDefFil := "F34_FILIAL,F34_SUPPL,F34_SUPUN,A2_NREDUZ,F34_DOC,F34_PDATE,F34_VATRT,F34_VATCOD,F34_VATCD2,F31_TG_COD,F31_OPCODE,F31_FILIAL,A2_FILIAL"

cQuery := " select %FIELD:"+cDefFil+":FIELD%" + ENTER
cQuery += ' , sum(cast(STR0018_F34_VATBS as float)) as _STR0018_ ' + ENTER //Final Base
cQuery += ' , sum(cast(STR0019_F34_VALUE as float)) as _STR0019_ ' + ENTER //Final Value
cQuery += "  from ( " + ENTER
    cQuery += "select F34_DOC,F34_PDATE,F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,'') as A2_NREDUZ, F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,A2_FILIAL" + ENTER //all fields
    cQuery += cOpcFil + ENTER
    cQuery += "  ,case when F34_TYPE IN ('01','04') then sum(F34_VATBS) else  sum(F34_VATBS)*-1 end as STR0018_F34_VATBS, " + ENTER
    cQuery += "  case when F34_TYPE IN ('01','04') then sum(F34_VALUE) else  sum(F34_VALUE)*-1 end as STR0019_F34_VALUE " + ENTER
    cQuery += "  FROM  %TABLE:F34% F34 " + ENTER
    cQuery += "  left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' " + ENTER
    cQuery += "  left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_='' " + ENTER
    cQuery += "  where F34.D_E_L_E_T_='' " + ENTER
    cQuery += "     and F34_DATE < %Exp:MV_PAR01% " + ENTER
    cQuery += "     and F34_SUPPL between %Exp:MV_PAR02% and %Exp:MV_PAR04% " + ENTER
    cQuery += "     and F34_SUPUN between %Exp:MV_PAR03% and %Exp:MV_PAR05% " + ENTER
    cQuery += "     and F34_FILIAL between %Exp:MV_PAR06% and %Exp:MV_PAR07% " + ENTER
    //Branchs that user can access
    If valtype(cFilUser_) <> 'U' //Branchs that user can access
        cQuery += " and F34.F34_FILIAL in ("+cFilUser_ +") "+ ENTER
    EndIf
    cQuery += " group by F34_DOC,F34_PDATE,F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,''), F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' '),coalesce(F31_OPCODE,' '),coalesce(F31_FILIAL,' '),A2_FILIAL " + ENTER
    cQuery += cOpcFil
cQuery += " ) as TMP "
cQuery += " group by  %FIELD:"+cDefFil+":FIELD%"
//Only register with negative balances
cQuery += " having sum(STR0018_F34_VATBS) < 0 or sum(STR0019_F34_VALUE) < 0 "

//SubQuery was used for translation too
//Add subQuery //Field , title,query  , query
cSubq :=  "SELECT %FIELD:"+cDefFil+":FIELD% ,sum(F34_VATBS) as F34_VATBS, sum(F34_VALUE) as F34_VALUE from ( "+;
                                                                    " select F34_DOC,F34_VALUE * (case when F34_TYPE IN ('01','04') then 1 else -1 end) as F34_VALUE,F34_VATBS * (case when F34_TYPE IN ('01','04') then 1 else -1 end) as F34_VATBS,F34_PDATE,F34_FILIAL,F34_SUPPL,F34_SUPUN,coalesce(A2_NREDUZ,'') as A2_NREDUZ, F34_VATRT,F34_VATCOD,F34_VATCD2,coalesce(F31_TG_COD,' ') as F31_TG_COD,coalesce(F31_OPCODE,' ') as F31_OPCODE,coalesce(F31_FILIAL,' ') as F31_FILIAL,A2_FILIAL,F34_TYPE,F34_BOOKEY,F34_KEY,F34_DATE "+;
                                                                    " from %TABLE:F34% F34 " +;
                                                                    "   left join %TABLE:SA2% SA2 on SA2.A2_FILIAL = %XFILIAL:SA2:F34_FILIAL% and SA2.A2_COD=F34.F34_SUPPL AND SA2.A2_LOJA=F34.F34_SUPUN AND SA2.D_E_L_E_T_='' " +;
                                                                    "   left join %TABLE:F31% F31 on F31.F31_FILIAL = %XFILIAL:F31:F34_FILIAL% and F31.F31_CODE=F34.F34_VATCOD AND F31.D_E_L_E_T_=''" +;
                                                                    " where F34.D_E_L_E_T_=' ' and F34.F34_FILIAL = coalesce(%EXP:F34_FILIAL%,F34.F34_FILIAL) "+;
                                                                    " and F34_DATE < %Exp:MV_PAR01%  and F34_SUPPL between %Exp:MV_PAR02% and %Exp:MV_PAR04%   and F34_SUPUN between %Exp:MV_PAR03% and %Exp:MV_PAR05%  and F34_FILIAL between %Exp:MV_PAR06% and %Exp:MV_PAR07% "+ IIf ( valtype(cFilUser_) <> 'U', " and F34.F34_FILIAL in ("+cFilUser_ +")  " , "") + " " +;
                                                                    ' and F34.F34_DIRECT = coalesce(%EXP:F34_DIRECT%,F34.F34_DIRECT)  ' +;
                                                                    ' and F34.F34_TYPE = coalesce(%EXP:F34_TYPE%,F34.F34_TYPE)  and F34.F34_BOOKEY = coalesce(%EXP:F34_BOOKEY%,F34.F34_BOOKEY) ' +;
                                                                    ' and F34.F34_KEY = coalesce(%EXP:F34_KEY%,F34.F34_KEY)  and F34.F34_SUPPL = coalesce(%EXP:F34_SUPPL%,F34.F34_SUPPL) ' +;
                                                                    ' and F34.F34_SUPUN = coalesce(%EXP:F34_SUPUN%,F34.F34_SUPUN) and F34.F34_DOC = coalesce(%EXP:F34_DOC%,F34.F34_DOC) ' +;
                                                                    ' and F34.F34_PDATE = coalesce(%EXP:F34_PDATE%,F34.F34_PDATE) and F34.F34_VATCOD = coalesce(%EXP:F34_VATCOD%,F34.F34_VATCOD) ' +;
                                                                    ' and F34.F34_VATCD2 = coalesce(%EXP:F34_VATCD2%,F34.F34_VATCD2) and F34.F34_VATRT = coalesce(%EXP:F34_VATRT%,F34.F34_VATRT) ' +;
                                                                    ' and F34.F34_USER = coalesce(%EXP:F34_USER%,F34.F34_USER) and F34.F34_BOOK = coalesce(%EXP:F34_BOOK%,F34.F34_BOOK) ' +;
                                                                    ' and F34.F34_TG_COD = coalesce(%EXP:F34_TG_COD%,F34.F34_TG_COD) ' +;
                                                                    " and coalesce(A2_NREDUZ ,'') = coalesce(%EXP:A2_NREDUZ% ,coalesce(A2_NREDUZ ,'')) " +;
                                                                    " and coalesce(F31_TG_COD,'') = coalesce(%EXP:F31_TG_COD%,coalesce(F31_TG_COD,'')) " +;
                                                                    " and coalesce(F31_OPCODE,'') = coalesce(%EXP:F31_OPCODE%,coalesce(F31_OPCODE,'')) " +;
                                                                    " and coalesce(F31_FILIAL,'') = coalesce(%EXP:F31_FILIAL%,coalesce(F31_FILIAL,'')) " +;
                                                                    " and coalesce(A2_FILIAL,'') = coalesce(%EXP:A2_FILIAL%,coalesce(A2_FILIAL,''))  ) as temp group by %FIELD:"+cDefFil+":FIELD%"

aAdd(aSubQuery,{'_STR0018_',' ',cSubq,STR0018,'',2 }) // Final Base
aAdd(aSubQuery,{'_STR0019_',' ',cSubq,STR0019,'',2 }) // Final Value
aAdd(aSubQuery,{'F31_FILIAL',' ',' ',STR0011,'' }) // F31 Filial
aAdd(aSubQuery,{'A2_FILIAL',' ',' ',STR0013,'' }) // A2 Filial

//Index order //Ordem, description                    , Key
aAdd(aIdexOrd,{ '1',STR0008,'F34_FILIAL+F34_SUPPL+F34_PDATE' }) //Branch+Customer+Issue Date
aAdd(aIdexOrd,{ '2',STR0007,'F34_FILIAL+F34_PDATE+F34_DOC' }) //Branch+Issue Date+Invoice

//Source document functionality, in the future will be in a new table.
aAdd(aSourDoc,{'F34_SUPPL|F34_SUPUN', 'A2_FILIAL+F34_SUPPL+F34_SUPUN', 'SA2', 1 ,"RU99X11A4('MATA020')",{ }, 'A2_FILIAL' })
aAdd(aSourDoc,{'F34_VATCOD|F31_OPCODE|F31_TG_COD', 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])+F34_VATCOD', 'F31', 1 ,"RU99X11A4('RU09D02')",{ }, 'PADR(F31_FILIAL,TamSX3("F31_FILIAL")[1])' })
aAdd(aSourDoc,{'F34_KEY|F34_DOC|F34_PDATE', 'F34_FILIAL+F34_KEY', 'F37', 3 ,"RU99X11A4('RU09T03')",{ {"INCLUI",".F."} }, 'F34_FILIAL' })
aAdd(aSourDoc,{'F34_BOOKEY|F34_DATE', 'F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2', "F34", 1 ,'RU99X11A2("F34",1,(cCurrAlias)->(F34_FILIAL+F34_BOOKEY+F34_KEY+F34_VATCOD+F34_VATCD2) )',{ {"INCLUI",".F."},{"ALTERA",".F."} }, 'F34_FILIAL'})

//Total Fields
aAdd(aTotal,{'_STR0018_'})
aAdd(aTotal,{'_STR0019_'})

return {dDate,nVersion,cCod,cName,cDesc,cQuery,cPerg,aSubQuery,aIdexOrd,cOpcFil,aSourDoc,cDefFil,aTotal}




/*/{Protheus.doc} RU99X11A1
@Description Auxiliar function responsable to open customer or vendor according to parameters
@type Static Function
@author Rafael Goncalves da Silva
@since Dec|2019
@return .T.
*/
Function RU99X11A1(cTable as Character,nIndex as Numeric,cKey as Character) as Boolean
default cTable  := ''
default nIndex  := 1
default cKey    := ''

If cTable == 'SF1'
    DbSelectArea('SF1')
    DbSetOrder(nIndex)
    If Msseek(cKey)
        If !(SF1->F1_TIPO $ ('D|B')) //return of sales or Ben. open supplier
            DbSelectArea('SA2')
            DbSetORder(1)
            If MsSeek(FwxFilial('SA2')+SF1->(F1_FORNECE+F1_LOJA))
                RU99X11A4('MATA020')
            EndIf
        else /// open customer
            DbSelectArea('SA1')
            DbSetORder(1)
            If MsSeek(FwxFilial('SA1')+SF1->(F1_FORNECE+F1_LOJA))
                cCadastro := STR0014
                AxVisual('SA1',recno(),2)
            EndIf
        Endif
    EndIf
ELSE //Outflow
    DbSelectArea('SF2')
    DbSetOrder(nIndex)
    If Msseek(cKey)
        If SF2->F2_TIPO $ ('D|B') //return of sales or Ben. open supplier
            DbSelectArea('SA2')
            DbSetORder(1)
            If MsSeek(FwxFilial('SA2')+SF2->(F2_CLIENTE+F2_LOJA))
                RU99X11A4('MATA020')
            Endif
        else /// open customer
            DbSelectArea('SA1')
            DbSetORder(1)
            If MsSeek(FwxFilial('SA1')+SF2->(F2_CLIENTE+F2_LOJA))
                cCadastro := STR0014
                AxVisual('SA1',recno(),2)
            Endif
        Endif
    EndIf
Endif
Return .t.




/*/{Protheus.doc} RU99X11A2
@Description Auxiliar function responsable to open Movement VAT document
@type Static Function
@author Rafael Goncalves da Silva
@since Jan|2020
@return .T.
*/
Function RU99X11A2(cTable as Character,nIndex as Numeric,cKey as Character) as Boolean
default cTable  := ''
default nIndex  := 1
default cKey    := ''

If cTable == 'F34' // Inflow VAT Movements
    DbSelectArea('F34')
    DbSetOrder(nIndex)
    If Msseek(cKey)
        /* souce RU09D04
        #define F34_INVOICE_MOVEMENT		"01"
        #define F34_BOOK_MOVEMENT			"02"
        #define F34_WRITE_OFF_MOVEMENT		"03"
        #define F34_RESTORATION_MOVEMENT	"04"
        */
        //Check F34_TYPE to open source document
        If F34->F34_TYPE == '01' // Invoice Movement // "RU09T03"
            DbSelectArea('F37')
            DbSetORder(2) //F37_FILIAL+F37_FORNEC+F37_BRANCH+DTOS(F37_PDATE)+F37_DOC+F37_TYPE
            If MsSeek(F34->(F34_FILIAL+F34_SUPPL+F34_SUPUN+Dtos(F34_PDATE)+F34_DOC))
                RU99X11A4('RU09T03')
             EndIf
        ElseIf F34->F34_TYPE == '02'//BOOK_MOVEMENT //"RU09T05"
            DbSelectArea('F3B')
            DbSetORder(1) //F3B_FILIAL+F3B_BOOKEY
            If MsSeek(F34->(F34_FILIAL+F34_BOOKEY))
                RU99X11A4('RU09T05')
                EndIf
        ElseIf F34->F34_TYPE == '03'//WRITE_OFF_MOVEMENT  //"RU09T06"
            DbSelectArea('F3D')
            DbSetORder(1) //F3D_FILIAL+F3D_WRIKEY
            If MsSeek(F34->(F34_FILIAL+F34_BOOKEY))
                RU99X11A4('RU09T06')
               EndIf
        ElseIf F34->F34_TYPE == '04'//RESTORATION_MOVEMENT  //"RU09T08"
            DbSelectArea('F52')
            DbSetORder(1) //F52_FILIAL+F52_CODE+F52_RESKEY
            If MsSeek(F34->(F34_FILIAL+PadR(F34_BOOK, TamSX3("F52_CODE")[1] ) +F34_BOOKEY))
                RU99X11A4('RU09T08')
              EndIf
        Endif
    EndIf
ELSE //Outflow TBD
    DbSelectArea('F54')
    DbSetOrder(nIndex) //F54_FILIAL+DTOS(F54_PDATE)+F54_DOC
    If Msseek(cKey)
        /** Source RU09D07
        #define F54_INVOICE_MOVEMENT	"01"
        #define F54_SALES_BOOK			"02"
        #define F54_VAT_RESTORATION		"03" */
        //Check F54_TYPE to open source document
        If F54->F54_TYPE == '01' // F54_INVOICE_MOVEMENT // RU09T02
            DbSelectArea('F35')
            DbSetORder(2) //F35_FILIAL+F35_CLIENT+F35_BRANCH+DTOS(F35_PDATE)+F35_DOC+F35_TYPE
            If MsSeek(F54->(F54_FILIAL+F54_CLIENT+F54_CLIBRA+DTOS(F54_PDATE)+PadR(F54_DOC, TamSX3("F35_DOC")[1] )))
                RU99X11A4('RU09T02')
            EndIf
        ElseIf F54->F54_TYPE == '02' // F54_SALES_BOOK // RU09T04
            DbSelectArea('F39')
            DbSetORder(1)//F39_FILIAL+F39_CODE
            If MsSeek(F54->(F54_FILIAL+PadR(F54_REGDOC, TamSX3("F39_CODE")[1] )))
                RU99X11A4('RU09T04')
            EndIf
        ElseIf F54->F54_TYPE == '03' // F54_VAT_RESTORATION //RU09T08
            DbSelectArea('F52')
            DbSetORder(1)//F52_FILIAL+F52_CODE+F52_RESKEY
            If MsSeek(F54->(F54_FILIAL+PadR(F54_REGDOC, TamSX3("F52_CODE")[1] ) + PadR(F54_REGKEY, TamSX3("F52_RESKEY")[1] )))
                RU99X11A4('RU09T08')
             EndIf
        Endif
    Endif
Endif
Return .t.



/*/{Protheus.doc} RU99X11A3
@Description Auxiliar function responsable to load branchs that user has access
@type Static Function
@author Rafael Goncalves da Silva
@since Jan|2020
@return .T.
*/
Function RU99X11A3() as Character
Local aFilUsr_ as Array // branchs that user has access
Local _Ni as Numeric //used for controling
Public cFilUser_ as Character // branches that user can access

cFilUser_ := ''
/*Branchs that user can acess*/
aFilUsr_	:=  AdmGetFil(.F.,.F.,"", .F., .F.,.F.)
For _Ni := 1 to len(aFilUsr_)
    If _Ni>1
        cFilUser_+= ','
    Endif
    cFilUser_ += "'"+aFilUsr_[_Ni,1]+"'"
Next

return cFilUser_



/*/{Protheus.doc} RU99X11A4
@Description Auxiliar function responsable load model and call loadview
@type Static Function
@author Rafael Goncalves da Silva
@since Jan|2020
@return .T.
*/
Function RU99X11A4(cModel as character)
Local oModel as Object
Local aArea  as Character

aArea   := GetArea()

//Already posicioned at function RUDblClick on source RU99X05
oModel  := FWLoadModel( cModel )
oModel:SetOperation( MODEL_OPERATION_VIEW )
oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

FWExecView( '' , cModel, , /*oDlg*/, /*bCloseOnOk*/ , /*bOk*/ , /*nRedutionPerc*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)

If Valtype(oModel) == 'O' .And. oModel:IsActive()
    oModel:DeActivate()
    oModel := Nil
EndIf

RestArea(aArea)

return cFilUser_
