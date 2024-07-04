#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU05XFUN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
//define for dialogs
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP
 
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

/*{Protheus.doc} RUXXTS01
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns counteragent atribute by alias, if it is some subdivision

Function RUXXTS01(cFieldName as character, cAliasP as character)
Local cRet := ""
If cAliasP == "A1_"
    If (SA1->A1_TIPO == "3")
        cRet := Posicione('AI0',1,xFilial('AI0') + SA1->A1_COD + SA1->A1_LOJA, 'AI0_'+cFieldName)  
    EndIf
Else
    If (SA2->A2_TIPO == "3")
        cRet := SA2-> &("A2_"+cFieldName)
    EndIf
EndIf   
Return(cRet)

/*{Protheus.doc} RUXXTS02
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns *_NREDUZ(short name) of Head Office if counteragent is a subdivision

Function RUXXTS02(cAliasP as character,cNametab as character)
Local cRet := ""
    If  &(cNametab + "->" + cAliasP +"TIPO")=="3"
        cRet := Posicione(cNametab,1,xFilial(cNametab) + RUXXTS01('HEAD',cAliasP) + RUXXTS01('HEADUN',cAliasP),cAliasP + "NREDUZ")
    Endif  

Return(cRet)
*/


/*{Protheus.doc} RUXXTO03_FullAdrOffice
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@description Returns AGA->AGA_FULL address or empty string if none 
*/
Static Function RUXXTO03_FullAdrOffice(cAliasP as character, cKeyP as character, cTipo as character)
Local cRet := ""
Local cQuery := ""
Local cAgaFull := ""
Local cTab := ""

if (!empty(cAliasP) .and. !empty(cKeyP) .and. !empty(cTipo))

	cQuery := " SELECT AGA.*, AGA.R_E_C_N_O_ AS AGAREC FROM " + RetSqlName("AGA") + " AGA "
	cQuery += " WHERE AGA_FILIAL = '"+xFilial("AGA")+"'"
	cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'"
	cQuery += " AND AGA_CODENT = '" + cKeyP + "'"
	cQuery += " AND AGA_TIPO = '" + cTipo + "'"	
	cQuery += " AND '" + DtoS(dDatabase) + "' BETWEEN AGA_FROM AND AGA_TO"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cTab := MPSysOpenQuery(cQuery)

	If (cTab)->(!EOF())
		AGA->(dbGoTo((cTab)->AGAREC))
		cAgaFull	:= AGA->AGA_FULL
	
		If !Empty(cAgaFull)
			cRet := cAgaFull
		EndIf
	EndIf

	(cTab)->( dbCloseArea() )
EndIf

Return(cRet)

/*{Protheus.doc} RUXXTS03
@author Marina Dubovaya
@since 29.05.2018
@version 1.0
@return character cRet
@type function
@use RUXXTO03_FullAdrOffice()
@description Returns  postal address if flag 2, 
                      legal address head office if flag 0 and A*_tipo = 3, 
                      legal address if flag 0 and A*_tipo <> 3                
Function RUXXTS03(cFlag as character,cAliasP as character,cNametab as character)
Local cRet as Character

    If cFlag == '0'
      If (&(cNametab + "->" + cAliasP +"TIPO")=="3")
	      cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + RUXXTS01('HEAD', cAliasP) + RUXXTS01('HEADUN',cAliasP),'0') //addr head office
        Else
	      cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + &(cNametab + "->" + cAliasP + "COD") + &(cNametab + "->" + cAliasP +"LOJA"),'0') //addr office
       Endif 
    Else  
        cRet := RUXXTO03_FullAdrOffice(cNametab, xFilial(cNametab) + &(cNametab + "->" + cAliasP + "COD") + &(cNametab + "->" + cAliasP +"LOJA"),'2') // postal
    EndIf  
          
Return(cRet)
*/

/*{Protheus.doc} RUXXTS04
@author Marina Dubovaya.
@since 29.05.2018
@version 1.0
@return character lRet
@type function
@use x3_when for F1_CNORSUP, F1_CNEEBUY, F2_CNORVEN, F2_CNEECLI, C5_CNORVEN, C5_CNEECLI
@description Returns  .T. if only GOODS are selected     
*/
Function RUXXTS04(DCod)
Local nX := 0
Local nPosCode  as Numeric
local cGrs      as Character
Local lRet      as Logical

lRet:=.F.

If (type ("aHeader") != "U") .AND. (type ("aCols") != "U") .and. (type ("lLocxAuto") != "U" .and. !lLocxAuto )//not called by execauto
    nPosCode := aScan(aHeader,{|x| AllTrim(x[2]) == Dcod   } )
    If nPosCode > 0
        For nX   := 1 to Len(aCols)
            If !aCols[nX][Len(aCols[nX])]
                DbSelectArea("SB1")
                If (SB1->(DbSeek(xFilial("SB1") + aCols[nX][nPosCode])))
                    cGrs := SB1->B1_GRUPO
                    DbSelectArea("SBM")
                    If (SBM->(DbSeek(xFilial("SBM") + cGrs)))
                        If (SBM->BM_GDSSRV) == '1' 
                            lRet:=.T.
                        EndIf            
                    Endif
                EndIf
            EndIf     
        Next nX

        If Dcod <> 'C6_PRODUTO' .AND. Type("bRefresh") == "B"
        	Eval(bRefresh)
        EndIf
	EndIf  
elseIf (type ("lLocxAuto") != "U" .and. lLocxAuto )//called by execauto MATA465N ULCD
    lRet:=.T.
EndIf

Return (lRet)

/*{Protheus.doc} RUXXTS05
@author Marina Dubovaya
@since 06.05.2018
@version 1.0
@return character cRet
@type function
@use x3_when for F1_MOEDA, F1_CONUNI and LocxNF in function LocxDlgNF()
@description Returns  .T. if empty D#_PEDIDO (purchase/sales order), D#_REMITO(purchase/sales delivery), D#_NFORI (credit/debet note)
*/
Function RUXXTS05()
Local nX as Numeric
Local nPosPedido as Numeric
Local nPosRemito as Numeric
Local nPosNfOri  as Numeric
Local nPosNfoSD1  as Numeric
lRet:=.T.

If !IsBlind() .And. (type("aHeader") != "U") .AND. (type("aCols") != "U")
    nPosPedido := aScan(aHeader,{|x| "_PEDIDO"  $ AllTrim(x[2])  } )
    nPosRemito := aScan(aHeader,{|x| "_REMITO"  $ AllTrim(x[2])   } )
    nPosNfOri := aScan(aHeader,{|x|  "_NFORI"   $ AllTrim(x[2])   } )
    If nPosPedido > 0 .Or. nPosRemito > 0 .Or. nPosNfOri > 0
		For nX   := 1 to Len(aCols)
			If !aCols[nX][Len(aCols[nX])]
                lRet := lRet .And. ( Empty(nPosPedido) .Or. Empty(aCols[nX][nPosPedido]) )
                lRet := lRet .And. ( Empty(nPosRemito) .Or. Empty(aCols[nX][nPosRemito]) )
                lRet := lRet .And. ( Empty(nPosNfOri) .Or. Empty(aCols[nX][nPosNfOri]) )
			EndIf   
		Next
		If Type("bRefresh") == "B"
			Eval(bRefresh)
		EndIf
	EndIf  
EndIf

Return (lRet)

/*{Protheus.doc} RUXXTS06
@author Anna Fedorova
@since 09.13.2018
@version P12.1.23
@return Logical lRet
@type function
@param 
    cConsigID - C5_CNORVEN or C5_CNEECLI
    cConsigCod - C5_CNORCOD or C5_CNEECOD
    cConsigBranch - C5_CNORBR or C5_CNEEBR
@use x3_valid for C5_CNORVEN, C5_CNEECLI
@description Validation for Consignee and Consignor fields.
*/

Function RUXXTS06(cConsigID as Character, cConsigCod as Character, cConsigBranch as Character)
Local lRet as logical
lRet := .F.

lRet :=  IIF(M->&(cConsigID) == "1",;
            EVAL({||(M->&(cConsigCod):=Space(TamSX3(cConsigCod)[1]),;
                    M->&(cConsigBranch):=Space(TamSX3(cConsigBranch)[1])),.T.}),;
            .T.)

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05X0001_InitMoeDes

Standard init. for C5_MOEDES field

@param		None
@return		CHARACTER cDescr
@author 	victor.rezende
@since 		21/09/2018
@version 	1.5
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05X0001_InitMoeDes()
Local cCurMoed  AS CHARACTER
Local cRet      AS CHARACTER
Local oModel    AS OBJECT
Local oModelSC5 AS OBJECT

cRet        := ""
cCurMoed    := ""
oModel      := FwModelActive()

If Empty(oModel)
    cCurMoed    := Posicione("CTO",1,xFilial("CTO")+StrZero(M->C5_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")
ElseIf ValType(oModel) == "O" .And. ! Empty( oModelSC5 := oModel:GetModel("SC5DETAIL") ) .And. oModel:GetOperation() <> MODEL_OPERATION_INSERT .And. ! Empty( oModelSC5:Length() )
    cCurMoed    := oModelSC5:GetValue("C5_MOEDA")
EndIf

If ! Empty( cCurMoed )
    cRet        := Posicione("CTO",1,xFilial("CTO")+StrZero(M->C5_MOEDA,TamSX3("CTO_MOEDA")[1]),"CTO_SIMB")
EndIf

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05XDTSAI

Check date of sales remito

@param		cOrder   Character  Order of Delivery;
            cClient  Character  Client;
            cLoja    Character  Unit of Client
@return		CHARACTER dRet
@author 	Alexandra Menyashina
@since 		27/09/2018
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05XDTSAI(cOrder as Character, cClient as Character, cLoja as Character)
local   nWidth      AS NUMERIC
local   nHeight     AS NUMERIC
Local   dRet        AS DATE
Local   cText       AS CHARACTER

Private oDlg as object

DEFAULT dRET := dDatabase

nWidth:=400
nHeight:=150

oDlg    := TDialog():New(000,000,nHeight,nWidth,STR0001,,,,,,,,,.T.)
oGBC    := tGridLayout():New(oDlg,CONTROL_ALIGN_ALLCLIENT)
oTFont := TFont():New(,,-13)

oOrder  := TSay():New(,, {|| STR0002 + cOrder}, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)
oClient := TSay():New(,, {|| STR0003 + cClient }, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)
oLoja   := TSay():New(,, {|| STR0004 + cLoja}, oGBC,,oTFont,,,,.T.,,,,,,,,,,.T.)

oGet := TGet():New( ,, { | u | If( PCount() == 0, dRet, dRet := u ) },oGBC, ;
     60, 10, "@d",, 0, 16777215, oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dRet",,,,.T./*lHasButton*/  )
oButton1 := TButton():New(,, STR0005, oGBC, {||.T. .AND. oDlg:End()},;
	40,10,,oTFont,.F.,.T.,.F.,,.F.,,,.F.)

oGBC:addInLayout(oOrder,1,1,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oClient,1,2,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oLoja,1,3,,,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oGet,2,1,,3,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)
oGBC:addInLayout(oButton1,3,1,,3,LAYOUT_ALIGN_HCENTER + LAYOUT_ALIGN_VCENTER)

oDlg:Activate(,,,.T.,,,)

Return dRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05X0002_OriDoc

MarkBrowse of original document for credit/debit notes

@param		cAliasHead   Character Alias of header table which will be created;
            nTipo          Numeric Type of document
            
@return		nil
@author 	Alexandra Velmozhnaya
@since 		06/03/2019
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function RU05X0002_OriDoc(cAliasHead as Character, nTipo as Numeric)
Local aArea    		:= GetArea()
Local aSF2			:= SF2->(GetArea())
Local aSD2			:= SD2->(GetArea())
Local aCposF4		:= {}
Local aRecs    		:= {}
Local aRet     		:= {}
Local nI 			:= 0
Local nJ 			:= 0
Local nTaxaNf		:= 0
Local nUm			:= 0
Local nSegUm		:= 0
Local nCod			:= 0
Local nFdesc		:= 0
Local nLocal		:= 0
Local nQuant		:= 0
Local nNfOri		:= 0
Local nSeriOri		:= 0
Local nItemOri		:= 0
Local nItem			:= 0
Local nTes			:= 0
Local nCf			:= 0
Local nLoteCtl		:= 0
Local nNumLote		:= 0
Local nDtValid		:= 0
Local nVunit		:= 0
Local nTotal		:= 0
Local nQTSegum		:= 0
Local nConta		:= 0
Local nCCusto		:= 0
Local nDesc			:= 0
Local nValDesc		:= 0
Local nProvEnt 		:= 0
Local nClVl			:= 0
Local nClientD2		:= 0
Local nLojaD2		:= 0
Local nTotalM		:= 0
Local nDescri		:= 0
Local cFilter 	    := ""
Local cItem			:= ""
Local cTipoDoc 		:= ""
Local cCliFor		:= M->F2_CLIENTE
Local cLoja  		:= M->F2_LOJA
Local dInvDoc       := M->F2_EMISSAO
Local cSeek  		:= ""
Local cWhile 		:= ""
Local cAliasCab		:= ""
Local cAliasItem	:= ""
Local cAliasTRB		:= ""
Local cQuery		:= ""
Local cDoc			:= ""
Local cFilSD		:= ""
Local lFiltroDoc	:= ExistBlock( "LxDocOri" )
Local cFilSB1		:= xFilial("SB1")
Local cFilSD2		:= xFilial("SD2")

Private aFiltro		:= {}

If Empty(cCliFor) .OR. Empty(cLoja)
	Aviso(cCadastro,STR0006,{STR0005}) //"Please complete the heading?s data"###"OK"
	Return
EndIf

For nI:=1 to Len(aHeader)
	Do Case
		Case  Alltrim(aHeader[nI][2]) == "D2_UM"
			nUm      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SEGUM"
			nSegUm   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_COD"
			nCod     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOCAL"
			nLocal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QUANT"
			nQuant   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NFORI"
			nNfOri  := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_SERIORI"
			nSeriOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEMORI"
			nItemOri := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_ITEM"
			nItem    := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TES"
			nTes     := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CF"
			nCf      := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOTECTL"
			nLoteCtl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_NUMLOTE"
			nNumLote := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DTVALID"
			nDtValid := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PRCVEN"
			nVunit   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_TOTAL"
			nTotal   := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_QTSEGUM"
			nQTSegum := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CONTA"
			nConta := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CC"
			nCCusto := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_VALDESC"
			nValDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_DESC"
			nDesc := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_PROVENT"
			nProvEnt := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLVL"
			nClVl := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_CLIENTE"
			nClientD2 := nI
		Case  Alltrim(aHeader[nI][2]) == "D2_LOJA"
			nLojaD2 := nI
		Case Alltrim(aHeader[nI][2]) == "D2_TOTALM"
			nTotalM   := nI
		Case Alltrim(aHeader[nI][2]) == "D2_FDESC"
			nFdesc     := nI
		Case Alltrim(aHeader[nI][2]) == "D2_DESCRI"
			nDescri     := nI
	Endcase
Next nI

cAliasCab	:= "SF2"
cAliasItem	:= "SD2"
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAliasCab))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAliasCab
	If SX3->X3_BROWSE == "S" .AND. cNivel >= SX3->X3_NIVEL
		AAdd(aCposF4,SX3->X3_CAMPO)
	Endif
	SX3->(DbSkip())
EndDo

If nTipo == 2

	cTipoDoc	:= "'01'"
	cSeek  		:= "'" + xFilial(cAliasCab)+cCliFor+cLoja + "'"
	cWhile 		:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA)== " + cSeek
	cFilter     := "Ascan(aFiltro,SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_TIPODOC)) > 0"
	cItem		:= aCols[Len(aCols),nItem]

    cAliasTRB := GetNextAlias()
    
    cQuery := "select distinct D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC,D2_ITEM"
    cQuery += " from " + RetSqlName("SD2") + " SD2 where "
    cQuery += " D2_FILIAL ='" + xFilial("SD2") + "'"
    cQuery += " and D2_CLIENTE = '" + cCliFor + "'"
    cQuery += " and D2_LOJA = '" + cLoja + "'"
    cQuery += " and D2_EMISSAO <= '" + DTOS(dInvDoc) + "'"
    cQuery += " and D2_TIPODOC in (" + cTipoDoc + ")"
    cQuery += " and D2_QUANT > D2_QTDEDEV"
    cQuery += " and SD2.D_E_L_E_T_ = ' ' "

    If lFiltroDoc
        cQuery := ExecBlock( "LxDocOri", .F., .F., { cQuery } )
    EndIf

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.F.,.T.)
    DbSelectArea(cAliasTRB)
    While (cAliasTRB)->(!Eof())
        nI := Ascan(aCols,{|x| x[nNFORI] == (cAliasTRB)->D2_DOC .AND. x[nItemOri] == (cAliasTRB)->D2_ITEM .AND. !x[Len(x)]})
        If nI == 0
            Aadd(aFiltro, (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_TIPODOC)
        EndIf
        (cAliasTRB)->(DbSkip())
    EndDo
    (cAliasTRB)->(DbCloseArea())
Else
	Return
EndIf
If !Empty(aFiltro)
	aRet := LocxF4(cAliasCab,2,cWhile,cSeek,aCposF4,,STR0007,cFilter,.T.,,,,,.F.,,,.F.)  // Return
Else
	Help(" ",1,"A103F4")
	Return
EndIf
If ValType(aRet)=="A" .AND. Len(aRet)==3
	aRecs := aRet[3]
EndIf
If ValType(aRecs)!="A" .OR. (ValType(aRecs)=="A" .AND. Len(aRecs)==0)
	Return
EndIf
SD2->(DbSetOrder(3))
cFilSD := cFilSD2
ProcRegua(Len(aRecs))

For nI := 1 To Len(aRecs)
	SF2->(MsGoTo(aRecs[nI]))
	SD2->(DbSeek(cFilSD + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
	IncProc(STR0008 + "(" + SF2->F2_DOC + ")")
	While SD2->D2_FILIAL == cFilSD .AND. SD2->D2_DOC == SF2->F2_DOC .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND.;
            SD2->D2_CLIENTE == SF2->F2_CLIENTE .AND. SD2->D2_LOJA == SF2->F2_LOJA
		
        If Ascan(aCols,{|x| x[nNFORI] == SD2->D2_DOC .AND. x[nItemOri] == SD2->D2_ITEM .AND. !x[Len(x)]}) == 0
            nLenAcols := Len(aCols)
            If !Empty(aCols[nLenAcols,nCod])
                AAdd(aCols,Array(Len(aHeader)+1))
                nLenAcols := Len(aCols)
                cItem := Soma1(cItem)
            Endif
            aCols[nLenAcols][Len(aHeader)+1]:=.F.
            If Empty(cCondicao) .OR. RUXXTS05()
                M->F2_CNTID 	:= SF2->F2_CNTID
                M->F2_F5QDESC   := Iif(!EMPTY(SF2->F2_CNTID),Posicione("F5Q",1,XFILIAL("F5Q")+SF2->F2_CNTID,"F5Q_CODE"),"")
                MaFisAlt("NF_MOEDA",SF2->F2_MOEDA)
                M->F2_MOEDA 	:= SF2->F2_MOEDA
                nMoedaNF		:= SF2->F2_MOEDA
                nMoedaCor		:= SF2->F2_MOEDA
                MaFisAlt("NF_TXMOEDA",SF2->F2_TXMOEDA)
                M->F2_TXMOEDA	:= SF2->F2_TXMOEDA
                M->F2_CONUNI	:= SF2->F2_CONUNI
                M->F2_CNORSUP	:= SF2->F2_CNORVEN	
                M->F2_CNEEBUY	:= SF2->F2_CNEECLI
                M->F2_CNORCOD	:= SF2->F2_CNORCOD
                M->F2_CNORBR	:= SF2->F2_CNORBR
                M->F2_CNEECOD	:= SF2->F2_CNEECOD
                M->F2_CNEEBR	:= SF2->F2_CNEEBR
                M->F2_DTSAIDA   := M->F2_DTSAIDA
                cCondicao   	:= SF2->F2_COND
            EndIf						

            nTaxaNF := MaFisRet(,'NF_TXMOEDA')
            nTaxaNF := Iif(nTaxaNF == 0,Recmoeda(dDEmissao,M->F1_MOEDA),nTaxaNF)
                      
            SB1->(MsSeek(cFilSB1+SD2->D2_COD))
            If (nUm      >  0  ,  aCOLS[nLenAcols][nUm      ] := SD2->D2_UM	,)
            If (nSegUm   >  0  ,  aCOLS[nLenAcols][nSegUm   ] := SB1->B1_SEGUM,)
            If (nCod     >  0  ,  aCOLS[nLenAcols][nCod     ] := SD2->D2_COD,)
            If (nDescri  >  0  ,  aCOLS[nLenAcols][nDescri  ] := SD2->D2_DESCRI,)
            If (nFdesc   >  0  ,  aCOLS[nLenAcols][nFdesc   ] := SD2->D2_FDESC,)
            If (nLocal   >  0  ,  aCOLS[nLenAcols][nLocal   ] := SD2->D2_LOCAL,)
            If (nNfOri   >  0  ,  aCOLS[nLenAcols][nNfOri   ] := SD2->D2_DOC,)
            If (nSeriOri >  0  ,  aCOLS[nLenAcols][nSeriOri ] := SD2->D2_SERIE,)
            If (nItemOri >  0  ,  aCOLS[nLenAcols][nItemOri ] := SD2->D2_ITEM,)
            If (nItem    >  0  ,  aCOLS[nLenAcols][nItem    ] := cItem,)
            If (nConta   >  0  ,  aCOLS[nLenAcols][nConta   ] := SD2->D2_CONTA,)
            If (nCCusto  >  0  ,  aCOLS[nLenAcols][nCCusto  ] := SD2->D2_CCUSTO,)
            If (nClVl    >  0  ,  aCOLS[nLenAcols][nClVl    ] := SD2->D2_CLVL,)
            If (nLoteCtl >  0  ,  aCOLS[nLenAcols][nLoteCtl ] := SD2->D2_LOTECTL,)
            If (nNumLote >  0  ,  aCOLS[nLenAcols][nNumLote ] := SD2->D2_NUMLOTE,)
            If (nDtValid >  0  ,  aCOLS[nLenAcols][nDtValid ] := SD2->D2_DTVALID,)
            If (nQtSegUm >  0  ,  aCOLS[nLenAcols][nQtSegUm ] := SD2->D2_QTSEGUM,)
            If (nClientD2 >  0 ,  aCOLS[nLenAcols][nClientD2] := SD2->D2_CLIENTE,)
            If (nLojaD2  >  0  ,  aCOLS[nLenAcols][nLojaD2  ] :=SD2->D2_LOJA,)
            If (nQuant  >  0   ,  aCOLS[nLenAcols][nQuant   ] := SD2->D2_QUANT,)
            If (nVUnit > 0     ,  aCOLS[nLenAcols][nVUnit   ] := SD2->D2_PRCVEN,)
            If (nTES > 0       ,  aCOLS[nLenAcols][nTES     ] := SD2->D2_TES,)
            If (nCf > 0        ,  aCOLS[nLenAcols][nCf      ] := SD2->D2_CF,)
            If (nTotal > 0     ,  aCOLS[nLenAcols][nTotal   ] := SD2->D2_TOTAL,)
            If (nTotalM > 0    ,   aCOLS[nLenAcols][nTotalM ] := SD2->D2_TOTALM,)

            AEval(aHeader,{|x,y| If(aCols[nLenAcols][y]==NIL,aCols[nLenAcols][y]:=CriaVar(x[2]),) })
            MaColsToFis(aHeader,aCols,nLenAcols,"MT100",.T.)    //TODO:debug for changing price = total. Its wrong
            MaFisAlt("IT_BASEIV1_C1",SD2->D2_BSIMP1M,nLenAcols)
			MaFisAlt("IT_VALIV1_C1",SD2->D2_VLIMP1M,nLenAcols)
            MaFisAlt("IT_RECORI",SD2->(Recno()),nLenAcols)
        EndIf

		SD2->(DbSkip())
	EndDo
Next nI
oGetDados:lNewLine:=.F.
oGetDados:obrowse:refresh()
Eval(bDoRefresh)
ModxAtuObj(.F.)

AtuLoadQt()
RestArea(aSD2)
RestArea(aSF2)
RestArea(aArea)

Return nil

// Ainda na locxnf restaurar quando for aceito pela esquipe de localizacao
// Still on locxnf restore when accepted by the localization team
/*{Protheus.doc} ExcRt101N
@author Alexandra Menyashina
@since 11/04/2018
@version P12.1.20
@param lCallRate    Logical     Flag of mandatory recalculation 
@return lRet
@type function
@description called by validation in Currency Rate to update all the item lines and header when the end user changes currency rate (for Inflow Invoice)

Function ExcRt101N(lCallRate)
Local nPosImp := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VALIMP1')} )
Local nPosBas := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_BASIMP1')} )
Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TOTAL')} )
Local nPosBrut := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VALBRUT')} )

Local nPosTotM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TOTALM')} )
Local nPosBrutM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VLBRUTM')} )
Local nPosBsIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_BSIMP1M')} )
Local nPosVlIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_VLIMP1M')} )
Local nI as numeric
Local nVlImp1M as numeric
Local nBsImp1M as numeric
Local nTotalM as numeric
Local nBrutM as numeric
Local nRate := M->F1_TXMOEDA
Local lRecalc := .T.

Default lCallRate := .T.

If !lCallRate .And. !IsBlind() .And. !RUXXTS05() .And. RUXXTS04("D1_COD") 
    lRecalc := MsgYesNo(STR0012, STR0011)
EndIf

If lRecalc
    If !lCallRate .Or. ReadVar() == "F1_MOEDA"
        nRate := RecMoeda(M->F1_EMISSAO,M->F1_MOEDA)
    EndIf
    nVlImp1M :=	0
    nBsImp1M :=	0
    nTotalM :=	0
    nBrutM	:=	0

    For nI := 1 To Len(aCols)
        If !aCols[nI][Len(aCols[nI])]
            aCols[nI][nPosTotM] :=	xMoeda(aCols[nI][nPosTot],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBsIM] := 	xMoeda(aCols[nI][nPosBas],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosVlIM] := 	xMoeda(aCols[nI][nPosImp],M->F1_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBrutM] :=	aCols[nI][nPosBsIM] + aCols[nI][nPosVlIM]

            nVlImp1M += aCols[nI][nPosVlIM]
            nBsImp1M += aCols[nI][nPosBsIM]
            nTotalM += aCols[nI][nPosTotM]
            nBrutM += aCols[nI][nPosBrutM]
        EndIf
    Next nI

    M->F1_VLIMP1M := nVlImp1M
    M->F1_BSIMP1M := nBsImp1M
    M->F1_VLBRUTM := nBrutM
    M->F1_VLMERCM := nTotalM
    MaFisRef("NF_BASEIV1_C1","MT100",nBsImp1M)
    MaFisRef("NF_VALIV1_C1","MT100",nVlImp1M)
    MaFisRef("NF_VALMERC_C1","MT100",nTotalM)
    MaFisRef("NF_TOTAL_C1","MT100",nBrutM)
    If !IsBlind()
        aoSbx[1]:Refresh()
    EndIf
EndIf
return lCallRate .Or. lRecalc

/*{Protheus.doc} ExcRt467N
@author Alexandra Menyashina
@since 23/04/2018
@version P12.1.20
@param lCallRate    Logical     Flag of mandatory recalculation 
@return lRet
@type function
@description called by validation in Currency Rate to update all the item lines and header when the end user changes currency rate (for Outflow Invoice)

Function ExcRt467N(lCallRate)
Local nPosImp := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VALIMP1')} )
Local nPosBas := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_BASIMP1')} )
Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TOTAL')} )
Local nPosBrut := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VALBRUT')} )

Local nPosTotM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TOTALM')} )
Local nPosBrutM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VLBRUTM')} )
Local nPosBsIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_BSIMP1M')} )
Local nPosVlIM := aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_VLIMP1M')} )
Local nI as numeric
Local nVlImp1M as numeric
Local nBsImp1M as numeric
Local nTotalM as numeric
Local nBrutM as numeric
Local nRate := M->F2_TXMOEDA
Local lRecalc := .T.

Default lCallRate := .T.

If lCallRate .And. !IsBlind() .And. RUXXTS04("D2_COD") .And. (Empty(M->F2_CNTID) .OR. M->F2_MOEDA!=1) 
    lRecalc := MsgYesNo(STR0012, STR0011)
EndIf
If lRecalc
    If !lCallRate .Or. ReadVar() == "F2_MOEDA"
        nRate := RecMoeda(M->F2_DTSAIDA,M->F2_MOEDA)
    EndIf 
    nVlImp1M :=	0
    nBsImp1M :=	0
    nTotalM :=	0
    nBrutM	:=	0
    For nI := 1 To Len(aCols)
        If !aCols[nI][Len(aCols[nI])]
            aCols[nI][nPosTotM] :=	xMoeda(aCols[nI][nPosTot],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBsIM] := 	xMoeda(aCols[nI][nPosBas],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosVlIM] := 	xMoeda(aCols[nI][nPosImp],M->F2_MOEDA,1,dDEmissao,,nRate)
            aCols[nI][nPosBrutM] :=	aCols[nI][nPosBsIM] + aCols[nI][nPosVlIM]

            nVlImp1M += aCols[nI][nPosVlIM]
            nBsImp1M += aCols[nI][nPosBsIM]
            nTotalM += aCols[nI][nPosTotM]
            nBrutM += aCols[nI][nPosBrutM]
        EndIf
    Next nI
    M->F2_VLIMP1M := nVlImp1M
    M->F2_BSIMP1M := nBsImp1M
    M->F2_VLBRUTM := nBrutM
    M->F2_VLMERCM := nTotalM
    MaFisRef("NF_BASEIV1_C1","MT100",nBsImp1M)
    MaFisRef("NF_VALIV1_C1","MT100",nVlImp1M)
    MaFisRef("NF_VALMERC_C1","MT100",nTotalM)
    MaFisRef("NF_TOTAL_C1","MT100",nBrutM)
    If !IsBlind()
        aoSbx[1]:Refresh()
    EndIf
EndIf
return lCallRate .Or. lRecalc
/*/
/*/{Protheus.doc} RU05X0003_VATOriDoc
Routine responsible to Select a Original Document according Type
1 - Commercial Invoice (SF2)
2 - Correction Invoice (F5Y)
2 - Adjustment Invoice (F5Y)

@type function
@author Alison Kaique
@since Apr|2019

@param nOrigType, numeric  , Type of Original Document
@param cCustomer, character, Customer Code
@param cUnit    , character, Customer Unit
@param cSeries  , character, Document Series
@param cDocument, character, Document Number
@param cDocType , character, Document Type
@return lReturn , logical, Process Control
/*/
Function RU05X0003_VATOriDoc(nOrigType As Numeric, cCustomer As Character, cUnit AS Character, cSeries As Character, cDocument As Character, cDocType As Character)
    Local cHeaderAlias As Character //Header Alias
    Local aFields      As Array //Table Fields
    Local lReturn      As Logical //Process Control

    Local cType        As Character //Document Type
    Local cSeek        As Character //String Seek
    Local cWhile       As Character //String While
    Local cFilter      As Character //String Filter
    Local cItem        As Character //Invoice Item
    Local cAliasTMP    As Character //Alias for Temporary Table
    Local cQuery       As Character //String Query
    Local aReturn      As Array //Return for registers
    Local cDblClick    As Character //Double Click Routine

    Private aFilter    As Array //Filter for Notes

    Default cSeries   := ""
    Default cDocument := ""
    Default cDocType  := ""

    aFilter := {}

    lReturn := .T. //Process Control

    cDblClick := ""

    //Verify Type and define parameters
    Do Case
        Case nOrigType == 01 //Commercial Invoice
            //Verify if informed Series, Document and DocType
            If (!Empty(cSeries) .OR. !Empty(cDocument) .OR. !Empty(cDocType))
                //Seek Document
                SF2->(DbSetOrder(02)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
                If !(SF2->(DbSeek(FWxFilial("SF2") + cCustomer + cUnit + cDocument + cSeries + cDocType)))
                    lReturn := .F.
                EndIf
            Else
                cHeaderAlias := "SF2"
                //Get Fields
                aFields := {"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA", "F2_EMISSAO", "F2_VLBRUTM", "F2_MOEDA", "F2_CONUNI", "F2_BASIMP1", "F2_VALIMP1", "F2_F5QDESC", "F2_TIPO", "F2_TIPODOC"}

                cType   	:= "'01'"
                cSeek  		:= "'" + FWxFilial(cHeaderAlias) + cCustomer + cUnit + "'"
                cWhile 		:= "SF2->(!EOF()) .AND. SF2->(F2_FILIAL + F2_CLIENTE + F2_LOJA) == " + cSeek
                cFilter     := "Ascan(aFilter, SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_TIPODOC)) > 0"
                cItem		:= StrZero(01, TamSX3("D2_ITEM")[01])

                cAliasTMP   := GetNextAlias()

                cQuery := "SELECT" + CRLF
                cQuery += " DISTINCT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,D2_TIPODOC" + CRLF
                cQuery += "FROM " + RetSqlName("SD2") + " SD2" + CRLF
                cQuery += "WHERE" + CRLF
                cQuery += " D2_FILIAL = '" + FWxFilial("SD2") + "'"
                cQuery += " AND D2_CLIENTE = '" + cCustomer + "'"
                cQuery += " AND D2_LOJA = '" + cUnit + "'"
                cQuery += " AND D2_TIPODOC in (" + cType + ")"
                cQuery += " AND D2_QUANT > D2_QTDEDEV"
                cQuery += " AND (SELECT COUNT(*) FROM " + RetSqlName("SD2") + " B WHERE B.D2_FILIAL = '" + FWxFilial("SD2") + "' AND B.D2_NFORI = SD2.D2_DOC AND B.D2_SERIORI = SD2.D2_SERIE AND B.D_E_L_E_T_ = '') = 0" + CRLF
                cQuery += " AND SD2.D_E_L_E_T_ = ' ' "

                cQuery := ChangeQuery(cQuery)

                PlsQuery(cQuery, cAliasTMP)

                While (cAliasTMP)->(!Eof())
                    Aadd(aFilter, (cAliasTMP)->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_TIPODOC))
                    (cAliasTMP)->(DbSkip())
                EndDo
                (cAliasTMP)->(DbCloseArea())

                cDblClick := "RU05X0004_OpenComInv(01, {" + StrTran(StrTran(FormatIn(ArrTokStr(aFields, ","), ","), "(", ""), ")", "") + "}, '" + cCustomer + "', '" + cUnit + "')"
            EndIf
        Case nOrigType == 02 //ULCD
            cHeaderAlias := "F5Y"

            //Get Fields
            aFields := {"F5Y_FILIAL", "F5Y_DOC", "F5Y_SERIE", "F5Y_CLIENT", "F5Y_BRANCH", "F5Y_DATE"}

            cSeek  		:= "'" + FWxFilial(cHeaderAlias) + cCustomer + cUnit + "'"
            cWhile 		:= "F5Y->(!EOF()) .AND. F5Y->(F5Y_FILIAL + F5Y_CLIENT + F5Y_BRANCH) == " + cSeek
            cFilter     := "Ascan(aFilter, F5Y->(F5Y_FILIAL + F5Y_DOC + F5Y_SERIE + F5Y_CLIENT + F5Y_BRANCH)) > 0"
            cItem		:= StrZero(01, TamSX3("D2_ITEM")[01])

            cAliasTMP   := GetNextAlias()

            cQuery := "SELECT" + CRLF
            cQuery += " F5Y_FILIAL, F5Y_DOC, F5Y_SERIE, F5Y_CLIENT, F5Y_BRANCH" + CRLF
            cQuery += "FROM " + RetSqlName("F5Y") + " F5Y" + CRLF
            cQuery += "WHERE" + CRLF
            cQuery += " F5Y_FILIAL = '" + FWxFilial("F5Y") + "'" + CRLF
            cQuery += " AND F5Y_CLIENT = '" + cCustomer + "'" + CRLF
            cQuery += " AND F5Y_BRANCH = '" + cUnit + "'" + CRLF
            cQuery += " AND (SELECT COUNT(*) FROM " + RetSqlName("F5Y") + " B WHERE B.F5Y_FILIAL = '" + FWxFilial("F5Y") + "' AND B.F5Y_DOCORI = F5Y.F5Y_DOC AND B.F5Y_SERORI = F5Y.F5Y_SERIE AND B.D_E_L_E_T_ = '') = 0" + CRLF
            cQuery += " AND F5Y.D_E_L_E_T_ = ' ' " + CRLF

            cQuery := ChangeQuery(cQuery)

            PlsQuery(cQuery, cAliasTMP)

            While (cAliasTMP)->(!Eof())
                Aadd(aFilter, (cAliasTMP)->(F5Y_FILIAL + F5Y_DOC + F5Y_SERIE + F5Y_CLIENT + F5Y_BRANCH))
                (cAliasTMP)->(DbSkip())
            EndDo
            (cAliasTMP)->(DbCloseArea())

            cDblClick := "RU05X0004_OpenComInv(02, {" + StrTran(StrTran(FormatIn(ArrTokStr(aFields, ","), ","), "(", ""), ")", "") + "}, '" + cCustomer + "', '" + cUnit + "')"
    EndCase

    If Len(aFilter) > 0
        aReturn := LocxF4(cHeaderAlias, 02, cWhile, cSeek, aFields, , STR0009, cFilter, .F.,,,, cDblClick, .F.,,,.F.) //"Select Original Document"
    Else
        lReturn := .F.
    EndIf

    If ValType(aReturn) == "A" .AND. Len(aReturn) == 3
        //Go To Recno
        DBSelectArea(cHeaderAlias)
        (cHeaderAlias)->(DBGoTo(aReturn[03]))
    Else
        lReturn := .F.
    EndIf

    If (!lReturn)
        Help(" ", 01, "VATOriDoc", , STR0010, 04, 15) //"No Original Documents found"
    EndIf

Return lReturn


/*{Protheus.doc} RU05X0005_ValidDateIncDoc
@author Alexandra Velmozhnya
@since 27/05/2019
@version 1.0
@param None
@return lRet
@type function
@description 
*/
Function RU05X0005_ValidDateIncDoc(dInvDate, dDocDate)
Local lRet as Logical

Default dInvDate := dDatabase
Default dDocDate := dDatabase

lRet := dInvDate >= dDocDate

If !lRet 
    Help("", 1, "RU05X0005_ValidDateIncDoc1",, STR0013, 1, 0)   //Date of document which was include could not be more than Invoice date
EndIf

Return lRet

/*{Protheus.doc} RU05X0006_RecalcTotal
@author Alexandra Velmozhnya
@since 06/06/2019
@version 1.0
@param None
@return nRet
@type function
@description trigger for recalculation D*_TOTAL
*/
Function RU05X0006_RecalcTotal()
Local nRet := 0
Local nPosQuant := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_QUANT|D1_QUANT"})
Local nPosPrice := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_PRCVEN/D1_VUNIT"})
Local nPosTotal := aScan(aHeader,{|x| Upper(Alltrim(x[2]))$"D2_TOTAL/D1_TOTAL"})

If nPosPrice > 0 .And. nPosQuant > 0 .And. nPosTotal > 0
    nRet := Iif( aCols[n][nPosQuant] > 0 .And. aCols[n][nPosPrice] > 0, aCols[n][nPosQuant] * aCols[n][nPosPrice] , aCols[n][nPosTotal] )
EndIf
return nRet

/*{Protheus.doc} RU05XFN007_InitialArrayMatxFis
@author Alexandra Velmozhnya
@since 23/01/2020
@version 1.0
@param  aHeader array   - structure of grid
        aCols   array   - data of grid
        lClear  logical - Flag clear array if operation creation
@return Nil
@type function
@description Initializing MatXFis array
*/
Function RU05XFN007_InitialArrayMatxFis(aHeader,aCols, lClear)
Local nY		As Numeric
Local nX		As Numeric
Local cValid	As Character
Local cRefCols	As Character
Local aRefImpos	As Array

Default lClear := .F.

If lClear
    MaFisClear()
EndIf
aRefImpos := MaFisRelImp("MATA461",{"SC6"})
aSort(aRefImpos,,,{|x,y| x[3]<y[3]})

MaFisIni(SC5->C5_CLIENTE/*cClient*/,SC5->C5_LOJACLI/*cLoja*/,"C","N",Nil,aRefImpos,,.F.)		//Initialize NFCab and NFItem
For nX := 1 to Len(aCols)
    MaFisIniLoad(nX)
    For nY	:= 1 To Len(aHeader)
        cValid	:= AllTrim(UPPER(aHeader[nY][6]))
        cRefCols := MaFisGetRf(cValid)[1]
        If !Empty(cRefCols) .AND. MaFisFound("IT",nX)
            MaFisLoad(cRefCols,aCols[nX][nY],nX)
        EndIf
    Next nY
    MaFisEndLoad(nX,1)
Next nX
return Nil


/*{Protheus.doc} RU05XFN008_Help
@author Artem Kostin
@since 02/08/2019
@version 1.0
@param cFunTrown - function, which trows an error
@return None
@type function
@description generalization of  
*/
Function RU05XFN008_Help(oModel as Object)
If (oModel:HasErrorMessage())
    Help(NIL, NIL, ProcName(1)+":"+Procname(0), NIL;
        , oModel:GetErrorMessage()[1] + CRLF;
        + oModel:GetErrorMessage()[2] + CRLF;
        + oModel:GetErrorMessage()[3] + CRLF;
        + oModel:GetErrorMessage()[4] + CRLF;
        + oModel:GetErrorMessage()[5] + CRLF;
        + oModel:GetErrorMessage()[6];
        , 1, 0, NIL, NIL, NIL, NIL, NIL;
        , {oModel:GetErrorMessage()[7], Iif(oModel:GetErrorMessage()[8] == Nil, "", oModel:GetErrorMessage()[8]), Iif(oModel:GetErrorMessage()[9] == Nil, "", oModel:GetErrorMessage()[9])};
    )
EndIf
Return

/*{Protheus.doc} RU05XFN009_ArrayColumns
@author Alexandra Velmozhnya
@since 27/12/2019
@version 1.0
@param aMarkField - name of Fields for mark Browse
@param aHideFields - name of Fields which should be hidden but in temporary table should be
@return None
@type function
@description generalization of  
*/
Function RU05XFN009_ArrayColumns(aMarkField as array, aHideFields as Array)
Local aRet as Array
Local aArea as Array
Local aAreaSX3 as Array
Local nI as Numeric

aRet := {}
aArea := GetArea()
aAreaSX3 := SX3->(GetArea())
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nI := 1 To Len(aMarkField)
    If (SX3->(DbSeek(aMarkField[nI])))
        aAdd(aRet, FwBrwColumn():New())
        aRet[Len(aRet)]:SetData(&("{|| " + aMarkField[nI] + "}"))
        aRet[Len(aRet)]:SetTitle(X3Titulo())
        aRet[Len(aRet)]:SetSize(TamSX3(aMarkField[nI])[1])
        aRet[Len(aRet)]:SetDecimal(TamSX3(aMarkField[nI])[2])
        aRet[Len(aRet)]:SetPicture(PesqPict("S" + SubStr(aMarkField[nI], 1, 2), aMarkField[nI]))
        aRet[Len(aRet)]:SetOptions( Separa(RTrim(X3CBox()),";") )
        If aScan(aHideFields,{|x| x == aMarkField[nI]}) > 0
            aRet[Len(aRet)]:SetDelete(.T.)
        EndIf
    EndIf
Next nI
RestArea(aAreaSX3)
RestArea(aArea)
Return aRet


/*{Protheus.doc} RU05XFN010_CheckModel
@author Artem Kostin
@since 06/02/2020
@version 1.0
@param oModel   - A model to be checked.
@param cModelIds - The name of the model to be checked.
@return lRet    - Idicates whether the model passed all checks or not.
@type function
@description
    The function checks:
        if parameter oModel has object type,
        if paramenter cModelIds equals the name of the model
        if the model is acivated
    If any of these checks is not passed, help message with the name of caller
    and decription of the issue will be displayed.
*/
Function RU05XFN010_CheckModel(oModel as Object, cModelIds as Character)
Local lRet as Logical
Local cProcessName	as Character

lRet := .T.
cProcessName := ProcName(1)

If (ValType(oModel) != "O")
	lRet := .F.
	Help(" ", 01, cProcessName + ":01", , STR0014 + STR0015 + STR0016, 1, 1) // "Model is not an object."
ElseIf !(oModel:GetId() $ cModelIds)
	lRet := .F.
	Help(" ", 01, cProcessName + ":02", , STR0014 + oModel:GetId() + STR0015 + cModelIds, 1, 1) // "Model is " + oModel:GetId() + ", not " + cModelIds
ElseIf (!oModel:IsActive())
	lRet := .F.
	Help(" ", 01, cProcessName + ":03", , STR0014 + STR0015 + STR0017, 1, 1) // "Model is not activated."
EndIf
Return lRet
