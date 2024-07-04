#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include "topconn.ch"
#Include "APWIZARD.CH"    
#Include "FWBROWSE.CH"
#Include "PLSA014G.CH"


//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRJGENT
Exibir dialog para reajuste de preços das tabelas B22 e B23

@author  Renan Martins
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Function PLSRJGENT (lAutoma)
Local cCodTab		:= B22->B22_CODTAB
Local cCodInt		:= B22->B22_CODINT
Local cTabDes 		:= "" //ProxSqnT(cCodInt)
Local cDesDes 		:= B22->B22_DESCRI
Local dDataAt 		:= B22->B22_DATFIM
Local dDataIn 		:= B22->B22_DATINI

Local oDlg
Local nOpca   		:= 0
Local dDatFim 		:= STOD("")

Local nBanDus 		:= 0
Local nTipBanDus
Local lChkBanDus 	:= .F.
Local oGetBanDus
Local oChkBanDus

Local nVrPco 		:= 0
Local nTipoVrPco
Local lChkVrPco 	:= .F.
Local oGetVrPco
Local oChkVrPco

Local nVrPp 		:= 0
local nTipoVrPp
Local lChkVrPp 		:= .F.
local oGetVrPp
local oChkVrPp

Local nBanDuc 		:= 0
Local nTipBanDuc
Local lChkBanDuc 	:= .F.
Local oGetBanDuc
local oChkBanDuc

Local nBanTa 		:= 0
Local nTipoBanTa
Local lChkBanTa 	:= .F.
Local oGetBanTa 
local oChkBanTa

Local nBanDap 		:= 0
Local nTipoBanDa
Local lChkBanDap 	:= .F.  
Local oGetBanDap
local oChkBanDap

Local nBanFm 		:= 0
Local nTipoBanFm
Local lChkBanFm 	:= .F.
Local oGetBanFm
local oChkBanFm

Local oGroup1, oGroup2 := nil    

Local lRet := .F.

Private cCodProDE	:= Space(18)
Private cCodProAT	:= Space(18)
Private oProAT		:= Nil
Private oProDE		:= Nil

default lAutoma := .f.


If !Empty(dDataAt) .and. !lAutoma
	MsgStop(STR0004)//"Copia abortada! Data Vigencia Final já informada."
	Return
EndIf

if !lAutoma
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 008.2,010.3 TO 042.4,135.3 OF GetWndDefault()
		oGroup1 := tGroup():New(35,4,90,485,STR0002,oDlg,,,.T.)//"Dados do Cadastro."
		oGroup2 := tGroup():New(105,4,240,485,STR0003,oDlg,,,.T.)//"Preencha caso Necessário Reajuste."

		@ 56,10 Say STR0007 PIXEL  //Procedimento de 
		@ 56,55 MsGet oPRODE VAR cCodProDE Size 65,08 PIXEL F3 "B23REA" Picture "@ 999999999999999999" Valid VldDeAte(cCodProDE, cCodProAT, .T.)
		
		@ 56,140 Say STR0008 PIXEL  //Procedimento Até
		@ 56,190 MsGet oProAT VAR cCodProAT  Size 65,08 PIXEL F3 /*"B23RE2"*/"B23REA" Picture "@ 999999999999999999" Valid VldDeAte(cCodProDE, cCodProAT, .T.)

		@ 76,010 Say STR0014 PIXEL  //Final da Vigência
		@ 75,55 MsGet dDatFim  Size 65,08 PIXEL  Picture "@D"
		
		@ 115,010 Say allTrim(TitX3("B23_BANDUS")) PIXEL SIZE 30,08
		@ 115,050 CHECKBOX oChkBanDus VAR lChkBanDus PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanDus,;
		oGetBanDus:Disable(LmpBanDus(@nBanDus)),	oGetBanDus:Enable() ), oGetBanDus:Refresh() ) 
		oGetBanDus := TGet():New( 115,060, {|u| If( PCount() == 0, nBanDus , nBanDus  := u ) }, oDlg, 50,08 , X3Picture("B23_BANDUS"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_BANDUS","B23_BANDUS",,,.T.,,,) 
		Eval(oChkBanDus:bChange)
		@ 115,111 Say "%" 	PIXEL	
		@ 130,050 RADIO oTipoBanDus VAR nTipBanDus 3D SIZE 40,08 PROMPT STR0009, STR0010	PIXEL When lChkBanDus //Banda US  //"Acrescimo","Desconto"
		
		@ 115,130 Say allTrim(TitX3("B23_VRPCO")) PIXEL SIZE 30,08
		@ 115,170 CHECKBOX oChkVrPco VAR lChkVrPco PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrPco, oGetVrPco:Disable(LmpVrPco(@nVrPco)),;
		oGetVrPco:Enable() ), oGetVrPco:Refresh() )//On Change ( IIf( lChkVrPco, oGetVrPco:Disable(), oGetVrPco:Enable() ))
		oGetVrPco := TGet():New( 115,180, {|u| If( PCount() == 0, nVrPco , nVrPco  := u ) }, oDlg, 50,08 , X3Picture("B23_VRPCO"),,,,,.F.,,.T.,,.F.,;
		/*{|u| If( lChkVrPco == .F., .F. , .T. ) }*/,.F.,.F.,,.F.,.F.,,"B23_VRPCO","B23_VRPCO",,,.T.,,,) 
		Eval(oChkVrPco:bChange)
		@ 115,231 Say "%" 	PIXEL	
		@ 130,170 RADIO oTipoVrPco VAR nTipoVrPco 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkVrPco //VL CO PAGTO             //"Acrescimo","Desconto"
		
		@ 115,250 Say allTrim(TitX3("B23_BANDUC")) PIXEL SIZE 30,08
		@ 115,290 CHECKBOX oChkBanDuc VAR lChkBanDuc PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanDuc,;
		oGetBanDuc: Disable(LmpBanDuc(@nBanDuc)),oGetBanDuc:Enable() ), oGetBanDuc:Refresh() )
		oGetBanDuc := TGet():New( 115,300, {|u| If( PCount() == 0, nBanDuc , nBanDuc  := u ) }, oDlg, 50,08 , X3Picture("B23_BANDUC"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_BANDUC","B23_BANDUC",,,.T.,,,)	
		Eval(oChkBanDuc:bChange)
		@ 115,351 Say "%" 	PIXEL	
		@ 130,290 RADIO oTipoBanDu VAR nTipBanDuc 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkBanDuc//Banda UCO //"Acrescimo","Desconto"

		@ 115,370 Say allTrim(TitX3("B23_BANPTA")) PIXEL SIZE 30,08
		@ 115,410 CHECKBOX oChkBanTa VAR lChkBanTa PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanTa,;
		oGetBanTa:Disable(LmpBanTa(@nBanTa)),oGetBanTa:Enable() ), oGetBanTa:Refresh() )
		oGetBanTa := TGet():New( 115,420, {|u| If( PCount() == 0, nBanTa , nBanTa  := u ) }, oDlg, 50,08 , X3Picture("B23_BANPTA"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_BANPTA","B23_BANPTA",,,.T.,,,)	
		Eval(oChkBanTa:bChange)
		@ 115,471 Say "%" 	PIXEL	
		@ 130,410 RADIO oTipoBanTa VAR nTipoBanTa 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkBanTa   //Banda Porte           //"Acrescimo","Desconto"
		
		
		@ 155,010 Say allTrim(TitX3("B23_BANDAP")) PIXEL SIZE 30,08
		@ 155,050 CHECKBOX oChkBanDap VAR lChkBanDap PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanDap,;
		oGetBanDap:Disable(LmpBanDap(@nBanDap)),oGetBanDap:Enable() ), oGetBanDap:Refresh() )
		oGetBanDap := TGet():New( 155,060, {|u| If( PCount() == 0, nBanDap , nBanDap  := u ) }, oDlg, 50,08 , X3Picture("B23_BANDAP"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_BANDAP","B23_BANDAP",,,.T.,,,)		
		Eval(oChkBanDap:bChange)
		@ 155,111 Say "%" 	PIXEL	
		@ 170,050 RADIO oTipoBanDa VAR nTipoBanDa 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkBanDap //Banda PAGTO             //"Acrescimo","Desconto"
		
		
		@ 155,130 Say allTrim(TitX3("B23_BANDFM")) PIXEL SIZE 30,08
		@ 155,170 CHECKBOX oChkBanFm VAR lChkBanFm PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkBanFm,;
		oGetBanFm:Disable(LmpBanFm(@nBanFm)),oGetBanFm:Enable() ), oGetBanFm:Refresh() )
		oGetBanFm := TGet():New( 155,180, {|u| If( PCount() == 0, nBanFm , nBanFm  := u ) }, oDlg, 50,08 , X3Picture("B23_BANDFM"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_BANDFM","B23_BANDFM",,,.T.,,,)	
		Eval(oChkBanFm:bChange)
		@ 155,231 Say "%" 	PIXEL	
		@ 170,170 RADIO oTipoBanFm VAR nTipoBanFm 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkBanFm //Banda Filme             //"Acrescimo","Desconto"

		@ 155,250 Say allTrim(TitX3("B23_VRPPP")) PIXEL SIZE 30,08
		@ 155,290 CHECKBOX oChkVrPp VAR lChkVrPp PROMPT OemtoAnsi("") PIXEL SIZE 08,08 On Change ( IIf( !lChkVrPp,;
		oGetVrPp:Disable(LmpVrPp(@nVrPp)),oGetVrPp:Enable() ), oGetVrPp:Refresh() )
		oGetVrPp := TGet():New( 155,300, {|u| If( PCount() == 0, nVrPp, nVrPp  := u ) }, oDlg, 50,08 , X3Picture("B23_VRPPP"),,,,,.F.,,.T.,,.F.,;
		,.F.,.F.,,.F.,.F.,,"B23_VRPPP","B23_VRPPP",,,.T.,,,)	
		Eval(oChkVrPp:bChange)
		@ 155,351 Say "%" 	PIXEL	
		@ 170,290 RADIO oTipoVrPp VAR nTipoVrPp 3D SIZE 40,08 PROMPT	STR0009, STR0010 PIXEL When lChkVrPp //VL PP Pagto             //"Acrescimo","Desconto"	

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(lRet := VrfDtF(dDatFim),oDlg:End(),nOpca:=0)},{||nOpca:=0,oDlg:End()}) Center
			
	If nOpca == 1 // faz a inserção da nova tabela
		if (QryTabRea(B22->B22_CODINT, B22->B22_CODTAB, cCodProDE, cCodProAT, dDatFim, .t., .f.))
				ReajTbGen(cCodInt,cCodTab,cTabDes,cDesDes,dDatFim,;
				lChkBanDus,nBanDus,nTipBanDus,lChkVrPco,nVrPco,nTipoVrPco,;
				lChkVrPp,nVrPp,nTipoVrPp,lChkBanDuc,nBanDuc,nTipBanDuc,;
				lChkBanTa,nBanTa,nTipoBanTa,lChkBanDap,nBanDap,nTipoBanDa,;
				lChkBanFm,nBanFm,nTipoBanFm,cCodProDE,cCodProAT, dDataIn)
		ENDIF
	endif
endif
Return

//---------------------------------------------------------------------------------
/*/{Protheus.doc} TitX3
Pegar título do campo conforme SX3 da tabela selecionada

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function TitX3(cCampo)

Local cTit := ""
Local aArea := sGetArea()

sGetArea(aArea,"SX3")

SX3->(DbSetOrder(2))
SX3->(MsSeek(cCampo))
cTit := X3Titulo()

sRestArea(aArea)

Return(cTit)


//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpBanDus
Limpar  BanDus

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function LmpBanDus(nBanDus)

nBanDus := 0  

Return nBanDus       

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpVrPco
Limpar  VRPCO

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function LmpVrPco(nVrPco)

nVrPco := 0

Return nVrPco

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpVrPp
Limpar  VrPp

@author  
@version P12
@since   08/2016
/*/
//--------------------------------------------------------------------------------- 
Static Function LmpVrPp(nVrPp)

nVrPp := 0

Return nVrPp

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpBanDuc
Limpar BanDuc

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function LmpBanDuc(nBanDuc)

nBanDuc := 0

Return nBanDuc

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpBanTa
Limpar BanTa

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function LmpBanTa(nBanTa)

nBanTa := 0

Return nBanTa

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpBanDap
Limpar Banda Pagamento

@author  
@version P12
@since   08/2016
/*/
//---------------------------------------------------------------------------------
Static Function LmpBanDap(nBanDap)

nBanDap := 0

Return nBanDap

//---------------------------------------------------------------------------------
/*/{Protheus.doc} LmpBanFm
Limpar Banda Recebimento

@author  
@version P12
@since   08/2016
/*/
//--------------------------------------------------------------------------------- 
Static Function LmpBanFm(nBanFm)

nBanFm := 0

Return nBanFm   


//---------------------------------------------------------------------------------
/*/{Protheus.doc} ReajTbGen
Função para reajustar os itens.

@author  Renan Martins
@version P12
@since   08/2016
/*/
//--------------------------------------------------------------------------------- 
Function ReajTbGen(cCodInt, cCodTab, cTabDes, cDesTab, dDatFim,;
	lChkBanDus,nBanDus,nTipBanDus,lChkVrPco,nVrPco,nTipoVrPco,;
	lChkVrPp,nVrPp,nTipoVrPp,lChkBanDuc,nBanDuc,nTipBanDuc,;
	lChkBanTa,nBanTa,nTipoBanTa,lChkBanDap,nBanDap,nTipoBanDa,;
	lChkBanFm,nBanFm,nTipoBanFm,cCodProDE,cCodProAT, B22VIGINI, lAutoma)

Local nColB23   	:= Len(B23->(DbStruct()))
Local aDaDB23 		:= {}
Local nI			:= 0 
Local nJ			:= 0 	
Local nCont 		:= 1
local cCampo 		:= ""
local dDatIni		:= iif( !empty(dDatFim), dDatFim + 1, dDatFim )
local lTroDtIn		:= .f.
default lAutoma 	:= .F.

//Atualização dos Procedimentos da B23
nCont := 0
dbselectarea("B23")
B23->(dbSetOrder(1))

If B23->(msseek(xFilial("B23")+cCodInt+cCodTab)) .and. QryTabRea(B22->B22_CODINT, B23->B23_CODTAB, cCodProDE, cCodProAT, dDatFim)
	While (!DadosEnc->(eof()))

		B23->(dbgoto(DadosEnc->REC))
		nCont++
		aadd(aDaDB23, {})
		For nI := 1 to nColB23			
			aadd(aDaDB23[nCont], {Field(nI), FieldGet(nI)})
		Next
		
		lTroDtIn := iif(B23->B23_VIGINI > dDatFim .or. empty(B23->B23_VIGINI), .t., .f.)

		If !Empty(dDatFim)			
			B23->(RecLock("B23",.F.))
				B23->B23_VIGFIM := dDatFim
				iif(lTroDtIn, B23->B23_VIGINI := dDatFim - 1, "")
			B23->(MsUnLock())
		EndIf
	DadosEnc->(DbSkip())	

	Enddo
	
	For nI := 1 to Len(aDaDB23)
		B23->( RecLock("B23",.T.) )
		For nJ := 1 To nColB23			
			cCampo 	  := "B23->"+aDaDB23[nI, nJ, 1]
			&(cCampo) := aDaDB23[nI, nJ, 2]
		Next
		B23->B23_VIGINI := dDatIni
		B23->B23_VIGFIM := StoD('')
		
		If (lChkBanDus) .and. (nBanDus>0) .and. (B23->B23_BANDUS>0)
			If nTipBanDus==1
				B23->B23_BANDUS := B23->B23_BANDUS+(nBanDus*B23->B23_BANDUS/100)
			ElseIf nTipBanDus==2
				B23->B23_BANDUS := B23->B23_BANDUS-(nBanDus*B23->B23_BANDUS/100)
			EndIf
		EndIf
		If (lChkVrPco) .and. (nVrPco>0) .and. (B23->B23_VRPCO>0)
			If nTipoVrPco==1
				B23->B23_VRPCO := B23->B23_VRPCO+(nVrPco*B23->B23_VRPCO/100)
			ElseIf nTipoVrPco==2
				B23->B23_VRPCO := B23->B23_VRPCO-(nVrPco*B23->B23_VRPCO/100)
			EndIf
		EndIf
		If (lChkVrPp) .and. (nVrPp>0) .and. (B23->B23_VRPPP>0)
			If nTipoVrPp==1
				B23->B23_VRPPP := B23->B23_VRPPP+(nVrPp*B23->B23_VRPPP/100)
			ElseIf nTipoVrPp==2 
				B23->B23_VRPPP := B23->B23_VRPPP-(nVrPp*B23->B23_VRPPP/100)
			EndIf
		EndIf
		If (lChkBanDuc) .and. (nBanDuc>0) .and. (B23->B23_BANDUC>0)
			If nTipBanDuc==1
				B23->B23_BANDUC := B23->B23_BANDUC+(nBanDuc*B23->B23_BANDUC/100)
			ElseIf nTipBanDuc==2
				B23->B23_BANDUC := B23->B23_BANDUC-(nBanDuc*B23->B23_BANDUC/100)
			EndIf
		EndIf
		If (lChkBanTa) .and. (nBanTa>0) .and. (B23->B23_BANPTA>0)
			If nTipoBanTa==1
				B23->B23_BANPTA := B23->B23_BANPTA+(nBanTa*B23->B23_BANPTA/100)
			ElseIf nTipoBanTa==2
				B23->B23_BANPTA := B23->B23_BANPTA-(nBanTa*B23->B23_BANPTA/100)
			EndIf
		EndIf
		If (lChkBanDap) .and. (nBanDap>0) .and. (B23->B23_BANDAP>0)
			If nTipoBanDa==1
				B23->B23_BANDAP := B23->B23_BANDAP+(nBanDap*B23->B23_BANDAP/100)
			ElseIf nTipoBanDa==2  
				B23->B23_BANDAP := B23->B23_BANDAP-(nBanDap*B23->B23_BANDAP/100)
			EndIf
		EndIf
		If (lChkBanFm) .and. (nBanFm>0) .and. (B23->B23_BANDFM>0)
			If nTipoBanFm==1
				B23->B23_BANDFM := B23->B23_BANDFM+(nBanFm*B23->B23_BANDFM/100)
			ElseIf nTipoBanFm==2
				B23->B23_BANDFM := B23->B23_BANDFM-(nBanFm*B23->B23_BANDFM/100)
			Endif
		EndIf	
				
		B23->( DbUnlock() )
	Next
EndIf

if len(aDaDB23) > 0
	while len(aDaDB23) > 0
		 adel(aDaDB23, len(aDaDB23))
		asize(aDaDB23, len(aDaDB23)-1)	
	enddo
	aDaDB23 := {}
	iif( !lAutoma, msgalert( STR0025, STR0026 ), "") //"Os itens reajustados foram inseridos com sucesso." / Atenção
endif

DadosEnc->(dbclosearea())

Return	



//---------------------------------------------------------------------------------
/*/{Protheus.doc} VrfDtF
Verifica se a data final de vigência está preenchida.

@author  Renan Martins
@version P12
@since   08/2016
/*/
//--------------------------------------------------------------------------------- 
Static Function VrfDtF(dData)
Local lRet := .F.

IF Empty(dData)
	msgalert(STR0017) //Informe a Data Final de Vigência para prosseguir!
Else
	lRet := .T.
ENDIF

Return lRet


//---------------------------------------------------------------------------------
/*/{Protheus.doc} VldDeAte
valida se o cód. procedimento do campo De é menor que o campo Até

@author  Pablo Alipio
@since   09/2019
/*/
//--------------------------------------------------------------------------------- 
function VldDeAte(cCodDE, cCodAT, lClean)
local lRet 		 := .T.
local cCodPadDe  := ""
local cCodPadAte := ""

default cCodDE   := ""
default cCodAT   := ""
default lClean   := .F. 

// na tela de reajuste o valor do campo de/até é o codpad e codpro juntos
if lClean
	cCodPadDe	:= left(cCodDE,2)
	cCodPadAte	:= left(cCodAT,2)
	cCodDE 		:= right(cCodDE,16)
	cCodAT 		:= right(cCodAT,16)
endif

if !empty(allTrim(cCodDE)) .and. (!empty(allTrim(cCodAT)) .and. allTrim(cCodDE) > allTrim(cCodAT))
	MsgAlert('O valor do campo Proc. De deve ser menor que o valor do campo Proc. Até', 'PLSA106' )
	lRet := .F.
elseif !empty(cCodPadDe) .and. (!empty(cCodPadAte) .and. cCodPadDe != cCodPadAte)
	MsgAlert('A tabela do campo Proc. De deve ser igual a tabela do campo Proc. Até', 'PLSA106' )
	lRet := .F.
endif	

return lRet


//---------------------------------------------------------------------------------
/*/{Protheus.doc} QryTabRea
Query dos dados para reajuste.
1 - Registros com vigências finais em aberto ou maior que a data final definida pelo usuário serão atualizados
2 - Registros com vigência inicial menor que a data de reajuste serão ignorados (não colocar vigência anteriores)

@since   11/2019
/*/
//--------------------------------------------------------------------------------- 
static function QryTabRea(cCodInt, cCodTab, cCodDe, cCodAte, dDatFim, lCont, lAutoma)
local cSql 		:= ""
local lRet 		:= .f.
local aArea		:= GetArea()
local cQry 		:= ""
default lCont	:= .f.
default lAutoma	:= .f.

iif( select("DadosEnc") > 0, DadosEnc->(dbCloseArea()), "")

cQry := iif(lCont, " COUNT (B23_CODPRO) QTD ", " R_E_C_N_O_ REC ")

cSql := " SELECT " + cQry + " FROM " + RetSqlname("B23")
cSql += " WHERE "
cSql += " B23_FILIAL = '" + xFilial("B23") + "' "
cSql += " AND B23_CODINT = '" + cCodInt + "' "
cSql += " AND B23_CODTAB = '" + cCodTab + "' "
cSql += " AND B23_CDPAD1 >= '" + LEFT(cCodDe,2) + "' "
cSql += " AND B23_CDPRO1 >= '" + RIGHT(cCodDe,16) + "' "
cSql += " AND B23_CDPAD1 <= '" + LEFT(cCodAte,2) + "' "
cSql += " AND B23_CDPRO1 <= '" + RIGHT(cCodAte,16) + "' "  
cSql += " AND B23_VIGINI <= '" + dtos(dDatFim) + "' "
cSql += " AND (B23_VIGFIM = '        ' OR B23_VIGFIM >= '" + dtos(dDatFim) + "') "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"DadosEnc",.F.,.T.)

if !lCont 
	lRet := iif(!DadosEnc->(eof()), .t., .f. )
endif		

if lCont
	if !lAutoma
		if (DadosEnc->QTD > 0)
			lRet := MsgYesNo(STR0018 + AllTrim(STR(DadosEnc->QTD)) + STR0019 )//"Deseja mesmo atualizar os " # " procedimentos encontrados de acordo com os dados informados na tabela?"
		else
			lRet := .f.
			MSGALERT( STR0024) //"Nenhum registro foi localizado para reajuste, de acordo com os dados informados."
		endif	
	else
		lRet := iif( DadosEnc->QTD > 0, .t., .f. )
	endif		
	DadosEnc->(dbclosearea())
endif

RestArea(aArea)	
return lRet


//---------------------------------------------------------------------------------
/*/{Protheus.doc} PlFilB23REA
Filtro para buscar os dados na pesquisa padrão SXB - B23REA

@since   11/2019
/*/
//--------------------------------------------------------------------------------- 
function PlFilB23REA()
local cRet := ""

cRet := "@#B23->B23_FILIAL = '" + xFilial("B23") + "' "
cRet += " .AND. B23->B23_CODTAB == B22->B22_CODTAB "
cRet += " .AND. (empty(B23->B23_VIGFIM) .or. B23->B23_VIGFIM > '" + dtos(dDataBase) + "') @#"

return cRet