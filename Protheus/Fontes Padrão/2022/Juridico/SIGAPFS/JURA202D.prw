#INCLUDE 'JURA202D.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lNewLanc := .F. // Variável para controle de vínculo de lançamentos utilizada na função JA202DASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202D
Associação de Lanc. Tabelado da Pré-Fatura

@param lAutomato  , Indica se a chamada foi feita da automação

@author Ernani Forastieri
@since  15/12/09
/*/
//-------------------------------------------------------------------
Function JURA202D(lAutomato)
Local aTemp       := {}
Local aFields     := {}
Local aOrder      := {}
Local aFldsFilt   := {}
Local aTmpFld     := {}
Local aTmpFilt    := {}
Local cLojaAuto   := SuperGetMv("MV_JLOJAUT", .F., "2",) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bseek       := Nil

Private oBrw202D  := Nil
Private TABLANC   := ''

Default lAutomato := .F.

lNewLanc := .F.

aTemp       := J202Filtro('NV4')
oTmpTable   := aTemp[1]
aTmpFilt    := aTemp[2]
aOrder      := aTemp[3]
aTmpFld     := aTemp[4]
TABLANC     := oTmpTable:GetAlias()

If (cLojaAuto == "1")
	AEVAL(aTmpFld , {|aX| Iif("NV4_CLOJA " != aX[2], Aadd(aFields  , aX),)})
	AEVAL(aTmpFilt, {|aX| Iif("NV4_CLOJA " != aX[1], Aadd(aFldsFilt, aX),)})
Else
	aFields   := aTmpFld
	aFldsFilt := aTmpFilt
EndIf

If lAutomato
	JA202DASS(Nil, lAutomato)
Else
	oBrw202D := FWMarkBrowse():New()
	oBrw202D:SetDescription(STR0001) // "Associação de Lanc. Tabelado da Pré-Faturas"
	oBrw202D:SetAlias(TABLANC)
	oBrw202D:SetTemporary(.T.)
	oBrw202D:SetFields(aFields)

	oBrw202D:oBrowse:SetDBFFilter(.T.) 
	oBrw202D:oBrowse:SetUseFilter()    

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela 
	//------------------------------------------------------
	bseek := {|oSeek| MySeek(oSeek, oBrw202D:oBrowse)}
	oBrw202D:oBrowse:SetIniWindow({|| oBrw202D:oBrowse:oData:SetSeekAction(bseek)})
	oBrw202D:oBrowse:SetSeek(.T., aOrder) 

	oBrw202D:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw202D:oBrowse:bOnStartFilter := Nil

	oBrw202D:SetMenuDef('JURA202D')
	oBrw202D:SetFieldMark('NV4_OK')
	JurSetLeg(oBrw202D, 'NV4')
	JurSetBSize(oBrw202D)

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw202D:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw202D:Activate()
EndIf

oTmpTable:Delete()

Return lNewLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - SimplesmeNV4 Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro correNV4
5 - Remove o registro correNV4 do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 15/12/09
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd(aRotina, {STR0002, 'JA202DASS( oBrw202D )', 0, 3, 0, NIL}) // "Associar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Lanc. Tabelado da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := Nil
Local oModel  := FWLoadModel('JURA202D')
Local oStruct := FWFormStruct(2, 'NV4')

JurSetAgrp('NV4',, oStruct)

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('JURA202D_VIEW', oStruct, 'NV4MASTER')
oView:CreateHorizontalBox('FORMFIELD', 100)
oView:SetOwnerView('JURA202D_VIEW', 'FORMFIELD')
oView:SetDescription(STR0003) // "Lanc. Tabelado da Pré-Fatura"
IIf(IsBlind(), , oMarkUp:SetFieldMark('NV4_OK')) // Controle devido a automação 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Lanc. Tabelado da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, 'NV4' )

oModel:= MPFormModel():New('JURA202D', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields('NV4MASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/)
oModel:SetDescription(STR0004) // "Modelo de Dados de Pré Fatura"
oModel:GetModel('NV4MASTER'):SetDescription(STR0005) // "Dados de Lanc.Trabalhado da Pré-Fatura"
oModel:GetModel('NV4MASTER'):SetOnlyView()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202DASS
Inclui os Tabelados marcados na pré-fatura selecionada

@param oBrw202D   , Browse da opção novos na pré-fatura
@param lAutomato  , Indica se a chamada foi feita da automação
@param cAlsTmpLD  , Alias temporário para busca de novos Tabelados

@author David G. Fernandes
@since 25/01/2010
/*/
//-------------------------------------------------------------------
Function JA202DASS(oBrw202D, lAutomato, cAlsTmpLD)
Local aArea       := GetArea()
Local aAreaNX1    := NX1->(GetArea())
Local aAreaNX8    := NX8->(GetArea())
Local cMarca      := ""
Local lInverte    := .F.
Local cFiltTela   := ""
Local cPreft      := NX0->NX0_COD
Local cMoedaPf    := NX0->NX0_CMOEDA
Local dDtEmitPf   := NX0->NX0_DTEMI
Local cContr      := NX0->NX0_CCONTR
Local nPDescH     := 0
Local cJContr     := NX0->NX0_CJCONT
Local cClien      := ""
Local cLoja       := ""
Local cCPART      := ""
Local aConvLanc   := {}
Local nSomaLTs    := 0
Local nVTAXA1     := 0
Local nVTAXA2     := 0 
Local nCount      := 0
Local aNX1RECNO   := {}
Local aContr      := {}
Local nI          := 0
Local aAjustPf    := {}
Local cContAj     := ""
Local lRevisLD    := (SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk
Local cPartAlt    := ""
Local aLT         := {}
Local aTSs        := {}
Local cLT         := ""
Local lJ202Ilt    := ExistBlock('JA202ILT')
Local lJ202Its    := ExistBlock('JA202ITS')
Local lTSVinc     := .F.
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
Local lVincLD     := .F.
Local cSituac     := '2|3|D|E'
Local lCpoCotac   := NV4->(ColumnPos('NV4_COTAC')) > 0 //Proteção

Default cAlsTmpLD := "" 
Default lAutomato := .F.

	If !Empty(cAlsTmpLD)
		lVincLD := .T.
		TABLANC := cAlsTmpLD
		cSituac := 'C|F' // Em Revisão | Aguardando Sincronização
	EndIf

	If !lAutomato .And. !lVincLD
		cMarca    := oBrw202D:Mark()
		lInverte  := oBrw202D:IsInvert()
		cFiltTela := oBrw202D:FWFilter():GetExprADVPL()
	EndIf

	If !(NX0->NX0_SITUAC $ cSituac)
		JurMsgErro( STR0009 ) //"Não é permitido associar lanc. tabelado nessa situação da Pré-Fatura"
		Return Nil
	EndIf

	If !Empty(cFiltTela) // É necessário recolocar o filtro da tela, pois quando é acessado uma rotina por botão o browse remove os filtros!
		(TABLANC)->( dbClearFilter() )
		(TABLANC)->( dbSetFilter( IIf( !Empty( cFiltTela ), &( ' { || ' + AllTrim( cFiltTela ) + ' } ' ), '' ), cFiltTela ) )
	EndIf

	(TABLANC)->( dbSetOrder(1) )
	(TABLANC)->( dbgotop() )
	
	NV4->( dbSetOrder( 1 ) )

	BEGIN TRANSACTION
		
		While !((TABLANC)->(EOF()))
			If lAutomato .Or. lVincLD .Or. (Iif(lInverte, (TABLANC)->NV4_OK != cMarca, (TABLANC)->NV4_OK == cMarca ) )

				If (NV4->( dbseek( (TABLANC)->NV4_FILIAL + (TABLANC)->NV4_COD ) ) )
			
					// Verifica cotação do Tabelado
					aConvLanc := JA201FConv(cMoedaPf, NV4->NV4_CMOEH, NV4->NV4_VLHFAT, "2", dDtEmitPf, "", cPreft )
					nSomaLTs  += aConvLanc[1]
					nVTAXA1   := aConvLanc[2] // Moeda da condição (TB)
					nVTAXA2   := aConvLanc[3] // Moeda da pré
						
					RecLock("NV4", .F.)
					NV4->NV4_CPREFT    := cPreft
					If !lVincLD .And. !lAutomato // Não limpa marca de seleção dos registros via Automação
						NV4->NV4_OK    := Iif(lInverte, cMarca, Space(TamSX3("NV4_OK")[1])) // Limpa a marca
					EndIf
					NV4->NV4_COTAC1    := nVTAXA1
					NV4->NV4_COTAC2    := nVTAXA2
					If lCpoCotac //Proteção
						NV4->NV4_COTAC := JurCotac(nVTAXA1, nVTAXA2)
					EndIf
					If lJ202Ilt
						ExecBlock('JA202ILT', .F., .F., {cPreft})
					EndIf
						
					NV4->(msUnlock())
					NV4->(DbCommit())
					
					NW4->(dbSetOrder(4)) //NW4_FILIAL+NW4_CLTAB+NW4_SITUAC+NW4_PRECNF  
					If !(NW4->( dbSeek( xFilial( 'NW4' ) + NV4->NV4_COD + "1" + cPreft ) ))
						RecLock("NW4",.T.)
						NW4->NW4_FILIAL    := xFilial("NW4")
						NW4->NW4_CLTAB     := NV4->NV4_COD
						NW4->NW4_SITUAC    := "1"
						NW4->NW4_PRECNF    := cPreft
						NW4->NW4_CANC      := "2"
						NW4->NW4_CODUSR    := __cUserID
						NW4->NW4_CCLIEN    := NV4->NV4_CCLIEN
						NW4->NW4_CLOJA     := NV4->NV4_CLOJA
						NW4->NW4_CCASO     := NV4->NV4_CCASO
						NW4->NW4_CPART1    := NV4->NV4_CPART
						NW4->NW4_DTCONC    := NV4->NV4_DTCONC
						NW4->NW4_VALORH    := NV4->NV4_VLHFAT
						NW4->NW4_CMOEDH    := NV4->NV4_CMOEH
						NW4->NW4_COTAC1    := NV4->NV4_COTAC1
						NW4->NW4_COTAC2    := NV4->NV4_COTAC2
						If lCpoCotac
							NW4->NW4_COTAC := NV4->NV4_COTAC
						EndIf
						NW4->(MsUnlock())
						NW4->(DbCommit())
					 Else
					 	RecLock("NW4",.F.)
						NW4->NW4_SITUAC    := "1"
						NW4->NW4_CANC      := "2"
						NW4->NW4_CODUSR    := __cUserID
						NW4->NW4_CCLIEN    := NV4->NV4_CCLIEN
						NW4->NW4_CLOJA     := NV4->NV4_CLOJA
						NW4->NW4_CCASO     := NV4->NV4_CCASO
						NW4->NW4_CPART1    := NV4->NV4_CPART
						NW4->NW4_DTCONC    := NV4->NV4_DTCONC
						NW4->NW4_VALORH    := NV4->NV4_VLHFAT
						NW4->NW4_CMOEDH    := NV4->NV4_CMOEH
						NW4->NW4_COTAC1    := NV4->NV4_COTAC1
						NW4->NW4_COTAC2    := NV4->NV4_COTAC2
						If lCpoCotac
							NW4->NW4_COTAC := NV4->NV4_COTAC
						EndIf
						NW4->(MsUnlock())
						NW4->(DbCommit())
					EndIf
					
					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NV4", xFilial("NV4") + (TABLANC)->NV4_COD, "4")
					EndIf
					
					// Verifica se o LT está relacionado a TSs, e se sim, vincula eles também
					If FindFunction("JurTSTab") .And. Len(aTSs := JurTSTab((TABLANC)->NV4_COD)) > 0
						lTSVinc := .T.
						NUE->( dbSetOrder( 1 ) ) // NUE_FILIAL+NUE_COD
						For nI := 1 To Len(aTSs)
							If (NUE->( dbseek( xFilial( 'NUE' ) + aTSs[nI][1] ) ) )
								RecLock("NUE", .F.)
								NUE->NUE_CPREFT    := cPreft
								NUE->NUE_CMOED1    := cMoedaPf
								NUE->NUE_COTAC1    := nVTAXA1
								NUE->NUE_COTAC2    := nVTAXA2
								If NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
									NUE->NUE_COTAC := JurCotac(nVTAXA1, nVTAXA2)
								EndIf
								If NUE->(ColumnPos('NUE_ACAOLD')) > 0 //Proteção
									NUE->NUE_ACAOLD := ""
								EndIf
								
								If lJ202Its
									ExecBlock('JA202ITS',.F.,.F.,{cPreft} )
								EndIf
								NUE->NUE_CUSERA := JurUsuario(__CUSERID)
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR  := Time()
								EndIf
								NUE->(msUnlock())
								NUE->(DbCommit())
				
								NW0->(dbSetOrder(1)) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
								If !(NW0->( dbSeek( xFilial( 'NW0' ) + aTSs[nI][1] + "1" + cPreft ) ))
									RecLock("NW0",.T.)
									NW0->NW0_FILIAL   := xFilial("NW0")
									NW0->NW0_CTS      := NUE->NUE_COD
									NW0->NW0_SITUAC   := "1"
									NW0->NW0_PRECNF   := cPreft
									NW0->NW0_CANC     := "2"
									NW0->NW0_CODUSR   := __cUserID
									NW0->NW0_CCLIEN   := NUE->NUE_CCLIEN
									NW0->NW0_CLOJA    := NUE->NUE_CLOJA
									NW0->NW0_CCASO    := NUE->NUE_CCASO
									NW0->NW0_CPART1   := NUE->NUE_CPART1
									NW0->NW0_TEMPOL   := NUE->NUE_TEMPOL
									NW0->NW0_TEMPOR   := NUE->NUE_TEMPOR
									NW0->NW0_VALORH   := NUE->NUE_VALORH
									NW0->NW0_CMOEDA   := NUE->NUE_CMOEDA
									NW0->NW0_DATATS   := NUE->NUE_DATATS
									NW0->(MsUnlock())
									NW0->(DbCommit())
								Else
									RecLock("NW0",.F.)
									NW0->NW0_SITUAC   := "1"
									NW0->NW0_CANC     := "2"
									NW0->NW0_CODUSR   := __cUserID
									NW0->NW0_CCLIEN   := NUE->NUE_CCLIEN
									NW0->NW0_CLOJA    := NUE->NUE_CLOJA
									NW0->NW0_CCASO    := NUE->NUE_CCASO
									NW0->NW0_CPART1   := NUE->NUE_CPART1
									NW0->NW0_TEMPOL   := NUE->NUE_TEMPOL
									NW0->NW0_TEMPOR   := NUE->NUE_TEMPOR
									NW0->NW0_VALORH   := NUE->NUE_VALORH
									NW0->NW0_CMOEDA   := NUE->NUE_CMOEDA
									NW0->NW0_DATATS   := NUE->NUE_DATATS
									NW0->(MsUnlock())
									NW0->(DbCommit())
								EndIf
			
								//Grava na fila de sincronização a alteração
								If !lRevisLD
									J170GRAVA("NUE", xFilial("NUE") + aTSs[nI][1], "4")
								EndIf
							EndIf
						Next nI
					EndIf
					
					nCount++

					//Ajusta os contratos
					If aScan( aContr, { | x | x[4] == NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO) } ) == 0 
					
						If !Empty(aAjustPf := J202BCntPf(cPreft, cContr, cJContr, NV4->NV4_CCLIEN, NV4->NV4_CLOJA, NV4->NV4_CCASO, "TB"))
							cClien  := aAjustPf[1]
							cloja   := aAjustPf[2]
							cContAj := aAjustPf[3]
						EndIf
						
						If aScan( aContr, { | x | x[3] == cContAj } ) == 0
							aAdd( aContr, {cClien, cloja, cContAj, NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO), lTSVinc } ) 	
						EndIf
						
					EndIf  
  				    
  				    If !Empty(cContAj) 
	  					NX1->(dbSetOrder(1)) //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
						If !(NX1->( dbSeek( xFilial( 'NX1' ) + NV4->(NV4_CPREFT + NV4_CCLIEN + NV4_CLOJA + cContAj + NV4_CCASO) ) )) 
							
							nPDescH := JurGetDados("NVE", 1, xFilial("NVE") + NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO), "NVE_DESPAD")
							cCPART  := JurGetDados("NVE", 1, xFilial("NVE") + NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO), "NVE_CPART1") 
							If NX1->(ColumnPos('NX1_CMOELI')) > 0
								aDadosLim := JurGetDados("NVE", 1, xFilial("NVE") + NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO),;
								                         {'NVE_CMOELI', 'NVE_VLRLI', 'NVE_SALDOI', 'NVE_CFACVL', 'NVE_CTBCVL'})
							EndIf
							
							RecLock("NX1", .T.)
							NX1->NX1_FILIAL  := xFilial("NX1")
							NX1->NX1_CPREFT  := NV4->NV4_CPREFT
							NX1->NX1_CCONTR  := cContAj
							NX1->NX1_CCLIEN  := NV4->NV4_CCLIEN
							NX1->NX1_CLOJA   := NV4->NV4_CLOJA
							NX1->NX1_CCASO   := NV4->NV4_CCASO
							If lTSVinc
								NX1->NX1_TS  := "1"
							Else
								NX1->NX1_TS  := "2"
							EndIf
							NX1->NX1_DESP    := "2"
							NX1->NX1_LANTAB  := "1"
							NX1->NX1_PDESCH  := nPDescH						
							NX1->NX1_VTAB    := nSomaLTs
							NX1->NX1_CPART   := cCPART
							NX1->NX1_TSREV   := "2"
							NX1->NX1_DSPREV  := "2"
							NX1->NX1_TABREV  := "2"
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
							If NX1->NX1_LANTAB == "2" .Or. lTSVinc
								RecLock("NX1", .F.)
								NX1->NX1_LANTAB := "1"
								If lTSVinc
									NX1->NX1_TS := "1"
								EndIf
								NX1->NX1_VTAB   += nSomaLTs
								NX1->NX1_TABREV := "2"
								NX1->(MsUnlock())
								NX1->(DbCommit())
							EndIf

						EndIf

						If aScan( aNX1RECNO, { | x | x[1] == NX1->(RECNO()) } ) == 0
							aAdd( aNX1RECNO, {NX1->(RECNO())} )	
						EndIf
					EndIf
				EndIf

				aAdd(aLT, NV4->NV4_COD)
				RecLock( TABLANC, .F. )
				(TABLANC)->( dbDelete() )
				(TABLANC)->(MsUnLock() )
				
			EndIf
			
			lTSVinc := .F.

			(TABLANC)->(dbSkip())
		EndDo

		If nCount > 0

			cPartAlt := JurUsuario(__CUSERID)

			//Ajusta os contratos
			NX8->(dbSetOrder(1)) //NX8_FILIAL+NX8_CPREFT+NX8_CCONTR			
			For nI := 1 To Len(aContr) 
				If NX8->( dbSeek( xFilial('NX8') + cPreft + aContr[nI][3] ))
					RecLock("NX8", .F.)
					NX8->NX8_LANTAB := '1'
					If aContr[nI][5]
						NX8->NX8_TS := '1'
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
					If aContr[nI][5]
						NX8->NX8_TS := "1"
					Else
						NX8->NX8_TS := "2"
					EndIf
					NX8->NX8_DESP   := "2"
					NX8->NX8_LANTAB := "1"
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
		EndIf
			
		RecLock("NX0", .F.)
		NX0->NX0_LANTAB := '1'
		If aScan( aContr, { | x | x[5] == .T. } ) > 0
			NX0->NX0_TS := '1'
		EndIf
		If !lVincLD // Quando é feito o vínculo via LD, não é permitido alterar a situação da Pré, que deve permanecer como "EM REVISÃO"
			NX0->NX0_SITUAC := '3'
		EndIf
		NX0->NX0_USRALT := cPartAlt
		NX0->NX0_DTALT  := Date()
		NX0->(msUnlock())
		NX0->(DbCommit())
			
		J202ADDESC(aNX1RECNO, "NV4", cMoedaPf, dDtEmitPf) // Atualiza o desconto na pré-fatura 
	
		AEval(aLT, {|x| cLT += x + CRLF})
		J202HIST('99', cPreft, cPartAlt, STR0001 + ":" + CRLF + cLT, "7") //"Associação de Lanc.Tabelado da Pré-Fatura"

	END TRANSACTION

	If nCount == 0
		JurMsgErro(STR0008) // "Nenhum Lançamento Marcado"
	Else
		lNewLanc := .T.
	EndIf
	
	If !lVincLD .And. !lAutomato
		oBrw202D:GoTop()
		oBrw202D:Refresh( .T. )
	EndIf

	RestArea( aAreaNX8 )
	RestArea( aAreaNX1 )
	RestArea( aArea )
	
Return NIL 
