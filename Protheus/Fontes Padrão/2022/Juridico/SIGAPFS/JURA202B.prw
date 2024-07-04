#INCLUDE 'JURA202B.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lNewLanc := .F. // Variável para controle de vínculo de lançamentos utilizada na função JA202BASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202B
Associação de Time Sheet da Pré-Fatura.

@param lAutomato  , Indica se a chamada foi feita da automação

@author Ernani Forastieri
@since  15/12/09
/*/
//-------------------------------------------------------------------
Function JURA202B(lAutomato)
Local aTemp       := {}
Local aFields     := {}
Local aOrder      := {}
Local aFldsFilt   := {}
Local aTmpFld     := {}
Local aTmpFilt    := {}
Local cLojaAuto   := SuperGetMv("MV_JLOJAUT", .F., "2",) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bseek       := Nil

Private oBrw202B  := Nil
Private TABLANC   := ''

Default lAutomato := .F.

lNewLanc := .F.

aTemp       := J202Filtro('NUE')
oTmpTable   := aTemp[1]
aTmpFilt    := aTemp[2]
aOrder      := aTemp[3]
aTmpFld     := aTemp[4]
TABLANC     := oTmpTable:GetAlias()

If (cLojaAuto == "1")
	AEVAL(aTmpFld , {|aX| Iif("NUE_CLOJA " != aX[2], Aadd(aFields  , aX),)})
	AEVAL(aTmpFilt, {|aX| Iif("NUE_CLOJA " != aX[1], Aadd(aFldsFilt, aX),)})
Else
	aFields   := aTmpFld
	aFldsFilt := aTmpFilt
EndIf

If lAutomato
	JA202BASS(Nil, "", lAutomato)
Else
	oBrw202B := FWMarkBrowse():New()
	oBrw202B:SetDescription( STR0001 ) //"Associação de Time Sheet da Pré-Faturas"
	oBrw202B:SetAlias( TABLANC )
	oBrw202B:SetTemporary( .T. )
	oBrw202B:SetFields(aFields)

	oBrw202B:oBrowse:SetDBFFilter(.T.)
	oBrw202B:oBrowse:SetUseFilter()
	//oBrw202B:oBrowse:SetSeek(,aOrder)
	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------

	bseek := {|oSeek| MySeek(oSeek,oBrw202B:oBrowse)}  //Realiza o ajuste da pesquisa para considerar o campo Filial
	oBrw202B:oBrowse:SetIniWindow({||oBrw202B:oBrowse:oData:SetSeekAction(bseek)})
	oBrw202B:oBrowse:SetSeek(.T.,aOrder)

	oBrw202B:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw202B:oBrowse:bOnStartFilter := Nil

	oBrw202B:SetMenuDef( 'JURA202B' )
	oBrw202B:SetFieldMark( 'NUE_OK' )
	JurSetLeg( oBrw202B, 'NUE' )
	JurSetBSize( oBrw202B )

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw202B:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw202B:Activate()
EndIf

oTmpTable:Delete() //Apaga a Tabela temporária

Return (lNewLanc)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - SimplesmeNUE Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, 'JA202BASS1( oBrw202B )', 0, 3, 0, NIL } ) //"Associar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheet da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := Nil
Local oModel  := FWLoadModel( 'JURA202B' )
Local oStruct := FWFormStruct( 2, 'NUE' )

JurSetAgrp( 'NUE',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA202B_VIEW', oStruct, 'NUEMASTER' )
oView:CreateHorizontalBox( 'FORMFIELD', 100)
oView:SetOwnerView( 'JURA202B_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0003 ) //"Time Sheet da Pré-Fatura"
IIf(IsBlind(), , oMarkUp:SetFieldMark( 'NUE_OK' )) // Controle devido a automação 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Time Sheet da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, 'NUE' )

oModel:= MPFormModel():New( 'JURA202B', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NUEMASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0004 ) //"Modelo de Dados de Time Sheet Pré-Fatura"
oModel:GetModel( 'NUEMASTER' ):SetDescription( STR0005 ) //"Dados de Time Sheet da Pré-Fatura"
oModel:GetModel( 'NUEMASTER' ):SetOnlyView()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202BASS1
Inclui os Time-Sheets marcados na pré-fatura selecionada

@param oBrw202B , Browse da opção novos na pré-fatura

@author David G. Fernandes
@since 25/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202BASS1( oBrw202B )

	MsgRun(STR0010, , {|| JA202BASS(oBrw202B, "", .F.) }) // "Associando..."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202BASS
Inclui os Time-Sheets marcados na pré-fatura selecionada

@param oBrw202B   , Browse da opção novos na pré-fatura
@param cAlsTmpLD  , Alias temporário para busca de novos TSs
@param lAutomato  , Indica se a chamada foi feita da automação

@author David G. Fernandes
@since 25/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202BASS( oBrw202B, cAlsTmpLD, lAutomato )
Local lVincLD     := .F.
Local cMarca      := ""
Local lInverte    := .F.
Local cFiltTela   := ""
Local cPreft      := NX0->NX0_COD
Local aArea       := GetArea()
Local aAreaNX1    := NX1->(GetArea())
Local aAreaNX8    := NX8->(GetArea())
Local nCount      := 0
Local aNX1RECNO   := {}
Local cMoedaPf    := NX0->NX0_CMOEDA
Local dDtEmitPf   := NX0->NX0_DTEMI
Local cContr      := NX0->NX0_CCONTR
Local cJContr     := NX0->NX0_CJCONT
Local nPDescH     := 0
Local cClien      := ""
Local cLoja       := ""
Local cCPART      := ""
Local aConvLanc   := {}
Local nVTAXA1     := 0
Local nVTAXA2     := 0
Local nSomaVTs    := 0
Local aContr      := {}
Local nI          := 0
Local aAjustPf    := {}
Local cContAj     := ""
Local lRevisLD    := (SuperGetMV("MV_JREVILD", .F., '2') == '1') // Controla a integracao da revisão de pré-fatura com o Legal Desk
Local cPartAlt    := ""
Local aTS         := {}
Local cTS         := ""
Local lJ202Its    := ExistBlock('JA202ITS')
Local lJ202Ilt    := ExistBlock('JA202ILT')
Local lTBVinc     := .F.
Local aDadosLim   := {}
Local aDadosFix   := {}
Local cTpHon      := ""
Local lFSinc      := SuperGetMV("MV_JFSINC", .F., '2') == '1'
Local lApuraTS    := SuperGetMv("MV_JTSPEND", .F., .F.,) .And. NX8->(ColumnPos("NX8_VLTSPD")) > 0 // Indica se no momento da emissão da pré-fatura serão calculados os Time Sheets pendentes e em minuta (.T. ou .F.)
Local nVlTSPd     := ""
Local nVlTSMi     := ""
Local aVigencia   := {}
Local aCasoMae    := {}
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cSituac     := '2|3|D|E'
Local lCpoCotac   := NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
Local lCobraH     := .T.
Local lFxNC       := NX0->(ColumnPos('NX0_FXNC')) > 0 .And. NX0->NX0_FXNC == "1" // @12.1.2210 - Indica se é uma pré de TS de contratos fixos ou não cobráveis

Default cAlsTmpLD := "" 
Default lAutomato := .F.

lVincLD   := !Empty(cAlsTmpLD)
cMarca    := IIf(lVincLD .Or. lAutomato, "" , oBrw202B:Mark())
lInverte  := IIf(lVincLD .Or. lAutomato, .F., oBrw202B:IsInvert())
cFiltTela := IIf(lVincLD .Or. lAutomato, "" , oBrw202B:FWFilter():GetExprADVPL())

If lVincLD
	cSituac := 'C|F' // Em Revisão | Aguardando Sincronização
	TABLANC := cAlsTmpLD
EndIf

If !(NX0->NX0_SITUAC $ cSituac)
	JurMsgErro( STR0009 ) //"Não é permitido associar time sheets nessa situação da Pré-Fatura"
	Return Nil
EndIf

If !Empty(cFiltTela) // É necessário recolocar o filtro da tela, pois quando é acessado uma rotina por botão o browse remove os filtros!
	(TABLANC)->( dbClearFilter() )
	(TABLANC)->( dbSetFilter( IIf( !Empty( cFiltTela ), &( ' { || ' + AllTrim( cFiltTela ) + ' } ' ), '' ), cFiltTela ) )
EndIf

(TABLANC)->( dbSetOrder(1) )
(TABLANC)->( dbgotop() )

NUE->( dbSetOrder( 1 ) )

BEGIN TRANSACTION

	While !((TABLANC)->(EOF()))
		If lVincLD .Or. lAutomato .Or. (Iif(lInverte, (TABLANC)->NUE_OK != cMarca, (TABLANC)->NUE_OK == cMarca)) // Não considera marca de seleção dos registros via REST ou Automação

			If (NUE->( dbseek( (TABLANC)->NUE_FILIAL + (TABLANC)->NUE_COD ) ) )

				// Verifica cotação do Time-Sheets
				aConvLanc   := JA201FConv(cMoedaPf, NUE->NUE_CMOEDA, NUE->NUE_VALOR, "2", dDtEmitPf, "", cPreft )
				nVVALORTEMP := aConvLanc[1]
				nVTAXA1     := aConvLanc[2] // Moeda da condição (TS)
				nVTAXA2     := aConvLanc[3] // Moeda da pré

				nSomaVTs += nVVALORTEMP

				RecLock("NUE", .F.)
				NUE->NUE_CPREFT    := cPreft
				If !lVincLD .And. !lAutomato // Não limpa marca de seleção dos registros via REST ou Automação
					NUE->NUE_OK    := Iif(lInverte, cMarca, Space(TamSX3("NUE_OK")[1])) // Limpa a marca
				EndIf
				NUE->NUE_CMOED1    := cMoedaPf
				NUE->NUE_VALOR1    := Iif(JurTSCob(NUE->NUE_COD, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CATIVI, lFxNC), nVVALORTEMP, 0)
				NUE->NUE_COTAC1    := Iif(NUE->NUE_VALOR1 > 0, nVTAXA1, 0)
				NUE->NUE_COTAC2    := Iif(NUE->NUE_VALOR1 > 0, nVTAXA2, 0)
				If lCpoCotac //Proteção
					NUE->NUE_COTAC := JurCotac(nVTAXA1, nVTAXA2)
				EndIf
				If NUE->(ColumnPos('NUE_ACAOLD')) > 0 //Proteção
					NUE->NUE_ACAOLD := ""
				EndIf
				
				If lJ202Its
					ExecBlock('JA202ITS', .F., .F., {cPreft})
				EndIf
				NUE->NUE_CUSERA := JurUsuario(__CUSERID)
				NUE->NUE_ALTDT  := Date()
				If lAltHr
					NUE->NUE_ALTHR  := Time()
				EndIf
				NUE->(msUnlock())
				NUE->(DbCommit())

				NW0->(dbSetOrder(1)) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
				If !(NW0->( dbSeek( xFilial( 'NW0' ) + NUE->NUE_COD + "1" + cPreft ) ))
					RecLock("NW0", .T.)
					NW0->NW0_FILIAL := xFilial("NW0")
					NW0->NW0_CTS    := NUE->NUE_COD
					NW0->NW0_SITUAC := "1"
					NW0->NW0_PRECNF := cPreft
					NW0->NW0_CANC   := "2"
					NW0->NW0_CODUSR := __cUserID
					NW0->NW0_CCLIEN := NUE->NUE_CCLIEN
					NW0->NW0_CLOJA  := NUE->NUE_CLOJA
					NW0->NW0_CCASO  := NUE->NUE_CCASO
					NW0->NW0_CPART1 := NUE->NUE_CPART1
					NW0->NW0_TEMPOL := NUE->NUE_TEMPOL
					NW0->NW0_TEMPOR := NUE->NUE_TEMPOR
					NW0->NW0_VALORH := NUE->NUE_VALORH
					NW0->NW0_CMOEDA := NUE->NUE_CMOEDA
					NW0->NW0_DATATS := NUE->NUE_DATATS
					NW0->NW0_COTAC1 := NUE->NUE_COTAC1
					NW0->NW0_COTAC2 := NUE->NUE_COTAC2
					If lCpoCotac
						NW0->NW0_COTAC := NUE->NUE_COTAC
					EndIf
					NW0->(MsUnlock())
					NW0->(DbCommit())
				Else
					RecLock("NW0", .F.)
					NW0->NW0_SITUAC := "1"
					NW0->NW0_CANC   := "2"
					NW0->NW0_CODUSR := __cUserID
					NW0->NW0_CCLIEN := NUE->NUE_CCLIEN
					NW0->NW0_CLOJA  := NUE->NUE_CLOJA
					NW0->NW0_CCASO  := NUE->NUE_CCASO
					NW0->NW0_CPART1 := NUE->NUE_CPART1
					NW0->NW0_TEMPOL := NUE->NUE_TEMPOL
					NW0->NW0_TEMPOR := NUE->NUE_TEMPOR
					NW0->NW0_VALORH := NUE->NUE_VALORH
					NW0->NW0_CMOEDA := NUE->NUE_CMOEDA
					NW0->NW0_DATATS := NUE->NUE_DATATS
					NW0->NW0_COTAC1 := NUE->NUE_COTAC1
					NW0->NW0_COTAC2 := NUE->NUE_COTAC2
					If lCpoCotac
						NW0->NW0_COTAC := NUE->NUE_COTAC
					EndIf
					NW0->(MsUnlock())
					NW0->(DbCommit())
				EndIf

				//Grava na fila de sincronização a alteração
				J170GRAVA("JURA144", xFilial("NUE") + (TABLANC)->NUE_COD, "4")
				
				// Verifica se o TS está relacionado a LT, e se sim, vincula ele também
				If !Empty( (TABLANC)->NUE_CLTAB )
					lTBVinc := .T.
					NV4->( dbSetOrder( 1 ) ) // NV4_FILIAL+NV4_COD
					If (NV4->( dbSeek( (TABLANC)->NUE_FILIAL + (TABLANC)->NUE_CLTAB ) ) )
						RecLock("NV4", .F.)
						NV4->NV4_CPREFT    := cPreft
						NV4->NV4_COTAC1    := nVTAXA1
						NV4->NV4_COTAC2    := nVTAXA2
						If NV4->(ColumnPos('NV4_COTAC')) > 0 //Proteção
							NV4->NV4_COTAC := JurCotac(nVTAXA1, nVTAXA2)
						EndIf
						If lJ202Ilt
							ExecBlock('JA202ILT',.F.,.F.,{cPreft} )
						EndIf
						NV4->(MsUnlock())
						NV4->(DbCommit())
						
						NW4->(dbSetOrder(4)) // NW4_FILIAL+NW4_CLTAB+NW4_SITUAC+NW4_PRECNF
						If !(NW4->( dbSeek( xFilial( 'NW4' ) + (TABLANC)->NUE_CLTAB + "1" + cPreft ) ))
							RecLock("NW4", .T.)
							NW4->NW4_FILIAL   := xFilial("NW4")
							NW4->NW4_CLTAB    := (TABLANC)->NUE_CLTAB
							NW4->NW4_SITUAC   := "1"
							NW4->NW4_PRECNF   := cPreft
							NW4->NW4_CANC     := "2"
							NW4->NW4_CODUSR   := __cUserID
							NW4->NW4_CCLIEN   := NV4->NV4_CCLIEN
							NW4->NW4_CLOJA    := NV4->NV4_CLOJA
							NW4->NW4_CCASO    := NV4->NV4_CCASO
							NW4->NW4_CPART1   := NV4->NV4_CPART
							NW4->NW4_DTCONC   := NV4->NV4_DTCONC
							NW4->NW4_VALORH   := NV4->NV4_VLHFAT
							NW4->NW4_CMOEDH   := NV4->NV4_CMOEH
							NW4->NW4_COTAC1   := NV4->NV4_COTAC1
							NW4->NW4_COTAC2   := NV4->NV4_COTAC2
							If lCpoCotac
								NW4->NW4_COTAC := NV4->NV4_COTAC
							EndIf
							NW4->(MsUnlock())
							NW4->(DbCommit())
						 Else
						 	RecLock("NW4", .F.)
							NW4->NW4_SITUAC   := "1"
							NW4->NW4_CANC     := "2"
							NW4->NW4_CODUSR   := __cUserID
							NW4->NW4_CCLIEN   := NV4->NV4_CCLIEN
							NW4->NW4_CLOJA    := NV4->NV4_CLOJA
							NW4->NW4_CCASO    := NV4->NV4_CCASO
							NW4->NW4_CPART1   := NV4->NV4_CPART
							NW4->NW4_DTCONC   := NV4->NV4_DTCONC
							NW4->NW4_VALORH   := NV4->NV4_VLHFAT
							NW4->NW4_CMOEDH   := NV4->NV4_CMOEH
							NW4->(MsUnlock())
							NW4->(DbCommit())
						EndIf
					EndIf

					//Grava na fila de sincronização a alteração
					
					J170GRAVA("NV4", xFilial("NV4") + (TABLANC)->NUE_CLTAB, "4")
					
					// Ajuste para vínculo de outros TSs vinculados ao Tabelado
					If FindFunction("JurTSTab") .And. Len(aTSTab := JurTSTab((TABLANC)->NUE_CLTAB)) > 0
						For nI := 1 To Len(aTSTab)
							If aTSTab[nI][1] != (TABLANC)->NUE_COD .And. (NUE->( dbseek( (TABLANC)->NUE_FILIAL + aTSTab[nI][1]) ) )
								
								RecLock("NUE", .F.)
								NUE->NUE_CPREFT    := cPreft
								NUE->NUE_CMOED1    := cMoedaPf
								NUE->NUE_VALOR1    := Iif(JurTSCob(NUE->NUE_COD, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CATIVI, lFxNC), nVVALORTEMP, 0)
								NUE->NUE_COTAC1    := Iif(NUE->NUE_VALOR1 > 0, nVTAXA1, 0)
								NUE->NUE_COTAC2    := Iif(NUE->NUE_VALOR1 > 0, nVTAXA2, 0)
								If NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
									NUE->NUE_COTAC := JurCotac(nVTAXA1, nVTAXA2)
								EndIf
								If NUE->(ColumnPos('NUE_ACAOLD')) > 0 //Proteção
									NUE->NUE_ACAOLD := ""
								EndIf
								
								If lJ202Its
									ExecBlock('JA202ITS', .F., .F., {cPreft} )
								EndIf
								NUE->(msUnlock())
								NUE->(DbCommit())
				
								NW0->(dbSetOrder(1)) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
								If !(NW0->( dbSeek( xFilial( 'NW0' ) + NUE->NUE_COD + "1" + cPreft ) ))
									RecLock("NW0", .T.)
									NW0->NW0_FILIAL  := xFilial("NW0")
									NW0->NW0_CTS     := NUE->NUE_COD
									NW0->NW0_SITUAC  := "1"
									NW0->NW0_PRECNF  := cPreft
									NW0->NW0_CANC    := "2"
									NW0->NW0_CODUSR  := __cUserID
									NW0->NW0_CCLIEN  := NUE->NUE_CCLIEN
									NW0->NW0_CLOJA   := NUE->NUE_CLOJA
									NW0->NW0_CCASO   := NUE->NUE_CCASO
									NW0->NW0_CPART1  := NUE->NUE_CPART1
									NW0->NW0_TEMPOL  := NUE->NUE_TEMPOL
									NW0->NW0_TEMPOR  := NUE->NUE_TEMPOR
									NW0->NW0_VALORH  := NUE->NUE_VALORH
									NW0->NW0_CMOEDA  := NUE->NUE_CMOEDA
									NW0->NW0_DATATS  := NUE->NUE_DATATS
									NW0->(MsUnlock())
									NW0->(DbCommit())
								Else
									RecLock("NW0", .F.)
									NW0->NW0_SITUAC  := "1"
									NW0->NW0_CANC    := "2"
									NW0->NW0_CODUSR  := __cUserID
									NW0->NW0_CCLIEN  := NUE->NUE_CCLIEN
									NW0->NW0_CLOJA   := NUE->NUE_CLOJA
									NW0->NW0_CCASO   := NUE->NUE_CCASO
									NW0->NW0_CPART1  := NUE->NUE_CPART1
									NW0->NW0_TEMPOL  := NUE->NUE_TEMPOL
									NW0->NW0_TEMPOR  := NUE->NUE_TEMPOR
									NW0->NW0_VALORH  := NUE->NUE_VALORH
									NW0->NW0_CMOEDA  := NUE->NUE_CMOEDA
									NW0->NW0_DATATS  := NUE->NUE_DATATS
									NW0->(MsUnlock())
									NW0->(DbCommit())
								EndIf
				
								//Grava na fila de sincronização a alteração

								J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")

							EndIf
						Next nI
					EndIf
					
				EndIf
				
				nCount++

				//Ajusta os contratos
				If aScan( aContr, { | x | x[4] == NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO) } ) == 0

					If !Empty(aAjustPf := J202BCntPf(cPreft, cContr, cJContr, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, "TS"))
						cClien  := aAjustPf[1]
						cloja   := aAjustPf[2]
						cContAj := aAjustPf[3]
						lCobraH := aAjustPf[5] == "1" // Contrato cobra hora
					EndIf

					If aScan( aContr, { | x | x[3] == cContAj } ) == 0
						aAdd( aContr, {cClien, cloja, cContAj, NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO), lTBVinc } )
					EndIf

				EndIf

				If !Empty(cContAj)
					NX1->(dbSetOrder(1)) //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
					If !(NX1->( dbSeek( xFilial( 'NX1' ) + NUE->(NUE_CPREFT + NUE_CCLIEN + NUE_CLOJA + cContAj + NUE_CCASO) ) ))

						nPDescH := JurGetDados("NVE", 1, xFilial("NVE") + NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO), "NVE_DESPAD")
						cCPART  := JurGetDados("NVE", 1, xFilial("NVE") + NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO), "NVE_CPART1")
						If NX1->(ColumnPos('NX1_CMOELI')) > 0
							aDadosLim := JurGetDados("NVE", 1, xFilial("NVE") + NUE->(NUE_CCLIEN + NUE_CLOJA + NUE_CCASO),;
							                         {'NVE_CMOELI', 'NVE_VLRLI', 'NVE_SALDOI', 'NVE_CFACVL', 'NVE_CTBCVL'})
						EndIf

						RecLock("NX1", .T.)
						NX1->NX1_FILIAL := xFilial("NX1")
						NX1->NX1_CPREFT := NUE->NUE_CPREFT
						NX1->NX1_CCONTR := cContAj
						NX1->NX1_CCLIEN := NUE->NUE_CCLIEN
						NX1->NX1_CLOJA  := NUE->NUE_CLOJA
						NX1->NX1_CCASO  := NUE->NUE_CCASO
						NX1->NX1_TS     := "1"
						NX1->NX1_DESP   := "2"
						NX1->NX1_VTS    := IIF(lCobraH, nSomaVTs, 0)
						If lTBVinc
							NX1->NX1_LANTAB := "1"
						Else
							NX1->NX1_LANTAB := "2"
						EndIf
						NX1->NX1_PDESCH := nPDescH
						NX1->NX1_CPART  := cCPART
						NX1->NX1_CMOETH := NUE->NUE_CMOEDA
						NX1->NX1_TSREV  := "2"
						NX1->NX1_DSPREV := "2"
						NX1->NX1_TABREV := "2"
						If NX1->(ColumnPos('NX1_SITREV')) > 0
							NX1->NX1_SITREV := "2"
						EndIf
						If NX1->(ColumnPos('NX1_DESCEX')) > 0
							NX1->NX1_DESCEX := "2"
						EndIf
						If NX1->(ColumnPos('NX1_CMOELI')) > 0
							NX1->NX1_CMOELI := aDadosLim[1]
							NX1->NX1_VLRLI  := aDadosLim[2]
							NX1->NX1_SALDOI := aDadosLim[3]
							NX1->NX1_CFACVL := aDadosLim[4]
							NX1->NX1_CTBCVL := aDadosLim[5]
						EndIf
						NX1->(MsUnlock())
						NX1->(DbCommit())

						J201EGrvRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, .F.) // Grava sócios/revisores
					Else
						If NX1->NX1_TS == "2" .Or. lTBVinc
							RecLock("NX1", .F.)
							NX1->NX1_TS    := "1"
							NX1->NX1_TSREV := "2"
							NX1->NX1_VTS   += IIF(lCobraH, nSomaVTs, 0)
							If lTBVinc
								NX1->NX1_LANTAB := "1"
							EndIf
							NX1->(MsUnlock())
							NX1->(DbCommit())
						EndIf
					EndIf
					
					If aScan( aNX1RECNO, { | x | x[1] == NX1->(RECNO()) } ) == 0
						aAdd( aNX1RECNO, {NX1->(RECNO())} )
					EndIf
					
				EndIf
			EndIf
			
			aAdd(aTS, NUE->NUE_COD)
			RecLock( TABLANC, .F. )
			(TABLANC)->( dbDelete() )
			(TABLANC)->(MsUnLock() )
			
		EndIf
		
		lTBVinc := .F.
		
		(TABLANC)->(dbSkip())
	EndDo

	If nCount > 0
		
		cPartAlt := JurUsuario(__CUSERID)

		//Ajusta os contratos
		NX8->(dbSetOrder(1)) //NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
		For nI := 1 To Len(aContr)
			If NX8->( dbSeek( xFilial('NX8') + cPreft +  aContr[nI][3] ))
				RecLock("NX8", .F.)
				NX8->NX8_TS := '1'
				If aContr[nI][5]
					NX8->NX8_LANTAB := "1"
				EndIf
				NX8->(msUnlock())
				NX8->(DbCommit())
			Else
				
				If NX8->(ColumnPos('NX8_CMOELI')) > 0
					aDadosLim := JurGetDados("NT0", 1, xFilial("NT0") + aContr[nI][3],;
					                         {'NT0_CMOELI', 'NT0_VLRLI', 'NT0_VLRLIF', 'NT0_CFACVL', 'NT0_CFXCVL', 'NT0_CTBCVL', 'NT0_SALDOI'})
				EndIf
				If NX8->(ColumnPos('NX8_CMOEF')) > 0
					aDadosFix := JurGetDados("NT0", 1, xFilial("NT0") + aContr[nI][3],;
					                         {'NT0_CMOEF', 'NT0_VLRBAS', 'NT0_TPCEXC', 'NT0_LIMEXH', 'NT0_PERCD'})
				EndIf
				If NX8->(ColumnPos('NX8_CTPHON'))
					cTpHon := JurGetDados("NT0", 1, xFilial("NT0") + aContr[nI][3], 'NT0_CTPHON')
				EndIf
				If lApuraTS
					nVlTSPd := J201EApuTS("P", aContr[nI][3], cMoedaPf, dDtEmitPf, cPreft)
					nVlTSMi := J201EApuTS("M", aContr[nI][3], cMoedaPf, dDtEmitPf, cPreft)
				EndIf
				If NT0->(ColumnPos("NT0_DTVIGI")) > 0
					aVigencia := JurGetDados("NT0", 1, xFilial("NT0") + aContr[nI][3], {'NT0_DTVIGI', 'NT0_DTVIGF'})
				EndIf
				If lFSinc .And. NX8->(ColumnPos('NX8_CCLICM')) > 0
					aCasoMae := JurGetDados("NT0", 1, xFilial("NT0") + aContr[nI][3], {'NT0_CCLICM', 'NT0_CLOJCM', 'NT0_CCASCM'})
				EndIf
				
				RecLock("NX8", .T.)
				NX8->NX8_FILIAL := xFilial("NX8")
				NX8->NX8_CPREFT := cPreft
				NX8->NX8_CCLIEN := aContr[nI][1]
				NX8->NX8_CLOJA  := aContr[nI][2]
				NX8->NX8_CCONTR := aContr[nI][3]
				NX8->NX8_CJCONT := cJContr
				NX8->NX8_TSREV  := "2"
				NX8->NX8_DSPREV := "2"
				NX8->NX8_TABREV := "2"
				NX8->NX8_FIXO   := "2"
				NX8->NX8_FATADC := "2"
				NX8->NX8_TS     := "1"
				NX8->NX8_DESP   := "2"
				If aContr[nI][5]
					NX8->NX8_LANTAB := "1"
				Else
					NX8->NX8_LANTAB := "2"
				EndIf
				If NX8->(ColumnPos('NX8_CMOELI')) > 0
					NX8->NX8_CMOELI := aDadosLim[1]
					NX8->NX8_VLRLI  := aDadosLim[2]
					NX8->NX8_VLRLIF := aDadosLim[3]
					NX8->NX8_CFACVL := aDadosLim[4]
					NX8->NX8_CFXCVL := aDadosLim[5]
					NX8->NX8_CTBCVL := aDadosLim[6]
					NX8->NX8_SALDOI := aDadosLim[7]
				EndIf
				If NX8->(ColumnPos('NX8_CMOEF')) > 0
					NX8->NX8_CMOEF  := aDadosFix[1]
					NX8->NX8_VLRBAS := aDadosFix[2]
					NX8->NX8_TPCEXC := aDadosFix[3]
					NX8->NX8_LIMEXH := aDadosFix[4]
					NX8->NX8_PERCD  := aDadosFix[5]
				EndIf
				If NX8->(ColumnPos('NX8_CTPHON'))
					NX8->NX8_CTPHON := cTpHon
				EndIf
				If NT0->(ColumnPos("NT0_DTVIGI")) > 0
					NX8->NX8_DTVIGI := aVigencia[1]
					NX8->NX8_DTVIGF := aVigencia[2]
				EndIf
				If lFSinc .And. NX8->(ColumnPos('NX8_CCLICM')) > 0
					NX8->NX8_CCLICM := aCasoMae[1]
					NX8->NX8_CLOJCM := aCasoMae[2]
					NX8->NX8_CCASCM := aCasoMae[3]
				EndIf
				If lApuraTS
					NX8->NX8_VLTSPD := nVlTSPd
					NX8->NX8_VLTSMI := nVlTSMi
				EndIf
				NX8->(MsUnlock())
				NX8->(DbCommit())
			EndIf
		Next nI
		
		RecLock("NX0", .F.)
		NX0->NX0_TS := '1'
		If aScan( aContr, { | x | x[5] == .T. } ) > 0
			NX0->NX0_LANTAB := '1'
		EndIf
		If !lVincLD // Quando o vínculo de TS é feito via LD, não é permitido alterar a situação da Pré, que deve permanecer como "EM REVISÃO"
			NX0->NX0_SITUAC := '3'
		EndIf
		NX0->NX0_USRALT := cPartAlt
		NX0->NX0_DTALT  := Date()
		NX0->NX0_VTS    += nSomaVTs
		NX0->(msUnlock())
		NX0->(DbCommit())
		
		J202ADDESC(aNX1RECNO, "NUE", cMoedaPf, dDtEmitPf) // Atualiza o desconto na pré-fatura
		
		AEval(aTS, {|x| cTS += x + CRLF})
		J202HIST('99', cPreft, cPartAlt, STR0001+":" + CRLF + cTS, "7") //"Associação de Time Sheet da Pré-Fatura"

	EndIf
	
END TRANSACTION

If nCount == 0
	JurMsgErro(STR0008) // "Nenhum Lançamento Marcado"
Else
	lNewLanc := .T.
EndIf

If !lVincLD .And. !lAutomato
	oBrw202B:GoTop()
	oBrw202B:Refresh( .T. )
EndIf

RestArea( aAreaNX8 )
RestArea( aAreaNX1 )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J202BCntPf
Verifica o contrato para incluir o registro do caso do lançamento.

@Param		cPreFat	Código da Pré-Fatura
@Param		cContr		Contrato da Pré-Fatura
@Param		cJContr	Junção de Contrado da Pré-Fatura
@Param		cClient	Cliente do lançamento
@Param		cLoja		Loja do lançamento
@Param		cCaso		Caso do lançamento
@Param		cTipo		Tipo do lançamento 
						"TS" - TimeSheet,
						"DP" - Despesas,
						"TB" - Tabelado

@Return	aRet		Array com as informaçoes do contrato 
						aRet[1] - Cliente do Contrato
						aRet[2] - Loja do Contrato
						aRet[3] - Código do Contrato
						aRet[4] - Caso do lançamento vinculado ao Contrato

@author Luciano Pereira dos Santos
@since 29/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J202BCntPf(cPreFat, cContr, cJContr, cClient, cLoja, cCaso, cTipo)
Local aRet      := {}
Local cCmd      := ''
Local cQryRes   := GetNextAlias()
Local lVincTS   := SuperGetMv('MV_JVINCTS ',, .T.) //Vinc TS em contrato Fixo
Local lBtnNovos := FWIsInCallStack("JA202Add")
Local aArea     := GetArea()

cCmd := " SELECT NT0.NT0_COD, NT0.NT0_CCLIEN, NT0.NT0_CLOJA, NRA.NRA_COBRAH "
cCmd += " FROM " + RetSqlName('NUT') + " NUT, "
cCmd +=      " " + RetSqlName('NT0') + " NT0, "
cCmd +=      " " + RetSqlName('NRA') + " NRA  "
If lBtnNovos
	cCmd += ", " + RetSqlName('NX8') + " NX8  "
EndIf
cCmd +=      " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
cCmd +=        " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
cCmd +=        " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
If !Empty(cContr)
	cCmd +=    " AND NUT.NUT_CCONTR = '" + cContr + "' "
ElseIf !Empty(cJContr)
	cCmd +=    " AND NUT.NUT_CCONTR IN ( SELECT NW3.NW3_CCONTR "
	cCmd +=                              " FROM " + RetSqlName("NW3") + " NW3 "
	cCmd +=                              " WHERE NW3.NW3_FILIAL = '" + xFilial("NW3") +"' "
	cCmd +=                                " AND NW3.NW3_CJCONT = '" + cJContr +"' "
	cCmd +=                                " AND NW3.D_E_L_E_T_ = ' ' "
	cCmd +=                            ") "
EndIf
cCmd +=       " AND NT0.NT0_COD = NUT.NUT_CCONTR "
cCmd +=       " AND NT0.NT0_ATIVO  = '1' "
If lBtnNovos
	cCmd +=   " AND NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
	cCmd +=   " AND NX8.NX8_CTPHON = NRA.NRA_COD "
	cCmd +=   " AND NX8.NX8_CPREFT = '" + cPreFat + "' "
Else
	cCmd +=   " AND NT0.NT0_CTPHON = NRA.NRA_COD "
EndIf
Do Case
Case cTipo == "TS"
	cCmd +=   " AND NT0.NT0_ENCH   = '2' "
	cCmd +=   " AND (NRA.NRA_COBRAH = '1' "
	cCmd +=        " OR (NRA.NRA_COBRAF = '1' AND NT0.NT0_FIXEXC = '1') "
	
	If lVincTS
		cCmd +=           " OR (NRA.NRA_COBRAF = '1' AND EXISTS ( SELECT NT1.R_E_C_N_O_ "
		cCmd +=                                            " FROM " + RetSqlName( 'NT1' ) + "  NT1 "
		cCmd +=                                            " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
		cCmd +=                                              " AND NT1.NT1_CCONTR = NT0.NT0_COD "
		cCmd +=                                              " AND NT1.NT1_CPREFT = '" + cPreFat + "' "
		cCmd +=                                              " AND NT1.D_E_L_E_T_ = ' ' ) ) "
	EndIf
	
	cCmd +=           " ) "
Case cTipo == "DP"
	cCmd +=   " AND NT0.NT0_ENCD = '2' "
	cCmd +=   " AND NT0.NT0_DESPES = '1' "
Case cTipo == "TB"
	cCmd +=   " AND NT0.NT0_ENCT = '2' "
	cCmd +=   " AND NT0.NT0_SERTAB = '1' "
EndCase
cCmd +=       " AND NUT.NUT_CCLIEN = '" + cClient + "' "
cCmd +=       " AND NUT.NUT_CLOJA  = '" + cLoja + "' "
cCmd +=       " AND NUT.NUT_CCASO  = '" + cCaso + "' "
cCmd +=       " AND NUT.D_E_L_E_T_ = ' ' "
cCmd +=       " AND NT0.D_E_L_E_T_ = ' ' "
cCmd +=       " AND NRA.D_E_L_E_T_ = ' ' "

cCmd := ChangeQuery(cCmd, .F.)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd), cQryRes, .T., .T.)

If !(cQryRes)->(Eof())
	aRet :={(cQryRes)->NT0_CCLIEN, (cQryRes)->NT0_CLOJA, (cQryRes)->NT0_COD, cCaso, (cQryRes)->NRA_COBRAH}
EndIf

(cQryRes)->( dbcloseArea() )

RestArea( aArea )

Return aRet
