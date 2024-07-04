#INCLUDE 'JURA202C.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lNewLanc := .F. // Variável para controle de vínculo de lançamentos utilizada na função JA202CASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202C
Associação de Despesas da Pré-Fatura

@param lAutomato  , Indica se a chamada foi feita da automação

@author Ernani Forastieri
@since  15/12/09
/*/
//-------------------------------------------------------------------
Function JURA202C(lAutomato)
Local aTemp       := {}
Local aFields     := {}
Local aOrder      := {}
Local aFldsFilt   := {}
Local aTmpFld     := {}
Local aTmpFilt    := {}
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bseek       := Nil

Private oBrw202C  := nil
Private TABLANC   := ''

Default lAutomato := .F.

lNewLanc := .F.

aTemp       := J202Filtro('NVY')
oTmpTable   := aTemp[1]
aTmpFilt    := aTemp[2]
aOrder      := aTemp[3]
aTmpFld     := aTemp[4]
TABLANC     := oTmpTable:GetAlias()

If(cLojaAuto == "1")
	AEVAL(aTmpFld  , {|aX| Iif ("NVY_CLOJA " != aX[2],Aadd(aFields  ,aX),)})
	AEVAL(aTmpFilt , {|aX| Iif ("NVY_CLOJA " != aX[1],Aadd(aFldsFilt,aX),)})
Else
	aFields   := aTmpFld
	aFldsFilt := aTmpFilt
EndIf

If lAutomato
	JA202CASS(Nil, lAutomato)
Else
	oBrw202C := FWMarkBrowse():New()
	oBrw202C:SetDescription( STR0001 ) //"Associação de Despesas da Pré-Faturas"
	oBrw202C:SetAlias( TABLANC )
	oBrw202C:SetTemporary( .T. )
	oBrw202C:SetFields(aFields)

	oBrw202C:oBrowse:SetDBFFilter(.T.)
	oBrw202C:oBrowse:SetUseFilter()

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------

	bseek := {|oSeek| MySeek(oSeek,oBrw202C:oBrowse)}
	oBrw202C:oBrowse:SetIniWindow({||oBrw202C:oBrowse:oData:SetSeekAction(bseek)})
	oBrw202C:oBrowse:SetSeek(.T.,aOrder)

	oBrw202C:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw202C:oBrowse:bOnStartFilter := Nil

	oBrw202C:SetMenuDef( 'JURA202C' )
	oBrw202C:SetFieldMark( 'NVY_OK' )
	JurSetLeg( oBrw202C, 'NVY' )
	JurSetBSize( oBrw202C )

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw202C:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw202C:Activate()
EndIf

oTmpTable:Delete() //Apaga a Tabela temporária

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
2 - SimplesmeNVY Mostra os Campos
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

aAdd( aRotina, { STR0002, 'JA202CASS( oBrw202C )', 0, 3, 0, NIL } ) //"Associar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Despesas da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( 'JURA202C' )
Local oStruct := FWFormStruct( 2, 'NVY' )

JurSetAgrp( 'NVY',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA202C_VIEW', oStruct, 'NVYMASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA202C_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0003 ) //"Despesas da Pré-Fatura"
IIf(IsBlind(), , oMarkUp:SetFieldMark( 'NVY_OK' )) // Controle devido a automação 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Despesas da Pré-Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, 'NVY' )

oModel:= MPFormModel():New( 'JURA202C', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NVYMASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0004 ) //"Modelo de Dados de Despesas Pré-Fatura"
oModel:GetModel( 'NVYMASTER' ):SetDescription( STR0005 ) //"Dados de Despesas da Pré-Fatura"
oModel:GetModel( 'NVYMASTER' ):SetOnlyView()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CASS1
Inclui as Despeas marcadas na pré-fatura selecionada

@author David G. Fernandes
@since 25/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202CASS1( oBrw202C )

	MsgRun(STR0010, ,{|| JA202CASS(oBrw202C) }) // "Associando..."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA202CASS
Inclui as Despeas marcadas na pré-fatura selecionada

@param oBrw202C   , Browse da opção novos na pré-fatura
@param lAutomato  , Indica se a chamada foi feita da automação
@param cAlsTmpLD  , Alias temporário para busca de novos Despesas

@author David G. Fernandes
@since 25/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA202CASS( oBrw202C, lAutomato, cAlsTmpLD)
Local aArea       := GetArea()
Local aAreaNX1    := NX1->(GetArea())
Local aAreaNX8    := NX8->(GetArea())  
Local cMarca      := ""
Local lInverte    := .F.
Local cFiltTela   := ""
Local cPreft      := NX0->NX0_COD
Local nCount      := 0
Local cMoedaPf    := NX0->NX0_CMOEDA
Local dDtEmitPf   := NX0->NX0_DTEMI
Local cContr      := NX0->NX0_CCONTR
Local cJContr     := NX0->NX0_CJCONT
Local cClien      := ""
Local cLoja       := ""
Local cCPART      := ""
Local aConvLanc   := {}
Local nVTAXA1     := 0
Local nVTAXA2     := 0
Local aContr      := {}
Local nI          := 0
Local aAjustPf    := {}
Local cContAj     := ""
Local lRevisLD    := (SuperGetMV("MV_JREVILD",.F.,'2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk
Local cPartAlt    := ""
Local aDP         := {}
Local cDP         := ""
Local lJA202IDP   := ExistBlock('JA202IDP')
Local aDadosLim   := {}
Local aDadosFix   := {}
Local cTpHon      := ""
Local lFSinc      := SuperGetMV("MV_JFSINC", .F., '2') == '1'
Local lApuraTS    := SuperGetMv("MV_JTSPEND", .F., .F.,) .And. NX8->(ColumnPos("NX8_VLTSPD")) > 0 // Indica se no momento da emissão da pré-fatura serão calculados os Time Sheets pendentes e em minuta (.T. ou .F.)
Local nVlTSPd     := ""
Local nVlTSMi     := ""
Local aVigencia   := {}
Local aCasoMae    := {}
Local lVincLD     := .F.
Local cSituac     := '2|3|D|E'
Local lCpoCotac   := NVY->(ColumnPos('NVY_COTAC')) > 0 //Proteção

Default cAlsTmpLD := "" 
Default lAutomato := .F.

	If !Empty(cAlsTmpLD)
		lVincLD := .T.
		TABLANC := cAlsTmpLD
		cSituac := 'C|F' // Em Revisão | Aguardando Sincronização
	EndIf

	If !lAutomato .And. !lVincLD
		cMarca     := oBrw202C:Mark()
		lInverte   := oBrw202C:IsInvert()
		cFiltTela  := oBrw202C:FWFilter():GetExprADVPL()
	EndIf

	If !(NX0->NX0_SITUAC $ cSituac)
		JurMsgErro( STR0009 ) //"Não é permitido associar despesa nessa situação da Pré-Fatura"
		Return Nil
	EndIf

	If !Empty(cFiltTela) // É necessário recolocar o filtro da tela, pois quando é acessado uma rotina por botão o browse remove os filtros!
		(TABLANC)->( dbClearFilter() )
		(TABLANC)->( dbSetFilter( IIf( !Empty( cFiltTela ), &( ' { || ' + AllTrim( cFiltTela ) + ' } ' ), '' ), cFiltTela ) )
	EndIf

	(TABLANC)->( dbSetOrder(1) )
	(TABLANC)->( dbgotop() )

	NVY->( dbSetOrder( 1 ) )

	BEGIN TRANSACTION

		While !((TABLANC)->(EOF()))
			If lAutomato .Or. lVincLD .Or. (Iif(lInverte, (TABLANC)->NVY_OK != cMarca, (TABLANC)->NVY_OK == cMarca ) )

				If (NVY->( dbseek( (TABLANC)->NVY_FILIAL + (TABLANC)->NVY_COD ) ) )

					// Verifica cotação das Despesas
					aConvLanc := JA201FConv(cMoedaPf, NVY->NVY_CMOEDA, NVY->NVY_VALOR, "2", dDtEmitPf, "", cPreft )
					nVTAXA1   := aConvLanc[2] // Moeda da condição (DP)
					nVTAXA2   := aConvLanc[3] // Moeda da pré
					
					RecLock("NVY", .F.)
					NVY->NVY_CPREFT  := cPreft
					If !lVincLD .And. !lAutomato // Não limpa marca de seleção dos registros via Automação
						NVY->NVY_OK  := Iif(lInverte, cMarca, Space(TamSX3("NVY_OK")[1])) // Limpa a marca
					EndIf
					NVY->NVY_COTAC1  := nVTAXA1
					NVY->NVY_COTAC2  := nVTAXA2
					If lCpoCotac //Proteção
						NVY->NVY_COTAC := JurCotac(nVTAXA1, nVTAXA2)
					EndIf
					If lJA202IDP
						ExecBlock('JA202IDP',.F.,.F.,{cPreft} )
					EndIf

					NVY->(msUnlock())
					NVY->(DbCommit())

					NVZ->(dbSetOrder(1)) //NVZ_FILIAL+NVZ_CDESP+NVZ_SITUAC+NVZ_PRECNF+NVZ_CFATUR+NVZ_CESCR+NVZ_CWO
					If !(NVZ->( dbSeek( xFilial( 'NVZ' ) + NVY->NVY_COD+ "1"+ cPreft ) ))
						RecLock("NVZ", .T.)
						NVZ->NVZ_FILIAL   := xFilial("NVZ")
						NVZ->NVZ_CDESP    := NVY->NVY_COD
						NVZ->NVZ_SITUAC   := "1"
						NVZ->NVZ_PRECNF   := cPreft
						NVZ->NVZ_CANC     := "2"
						NVZ->NVZ_CODUSR   := __cUserID
						NVZ->NVZ_CCLIEN   := NVY->NVY_CCLIEN
						NVZ->NVZ_CLOJA    := NVY->NVY_CLOJA
						NVZ->NVZ_CCASO    := NVY->NVY_CCASO
						NVZ->NVZ_DTDESP   := NVY->NVY_DATA
						NVZ->NVZ_CTPDSP   := NVY->NVY_CTPDSP
						NVZ->NVZ_CMOEDA   := NVY->NVY_CMOEDA
						NVZ->NVZ_VALORD   := NVY->NVY_VALOR
						NVZ->NVZ_COTAC1   := NVY->NVY_COTAC1
						NVZ->NVZ_COTAC2   := NVY->NVY_COTAC2
						If lCpoCotac
							NVZ->NVZ_COTAC := NVY->NVY_COTAC
						EndIf
						NVZ->(MsUnlock())
						NVZ->(DbCommit())
					Else
						RecLock("NVZ", .F.)
						NVZ->NVZ_SITUAC   := "1"
						NVZ->NVZ_CANC     := "2"
						NVZ->NVZ_CODUSR   := __cUserID
						NVZ->NVZ_CCLIEN   := NVY->NVY_CCLIEN
						NVZ->NVZ_CLOJA    := NVY->NVY_CLOJA
						NVZ->NVZ_CCASO    := NVY->NVY_CCASO
						NVZ->NVZ_DTDESP   := NVY->NVY_DATA
						NVZ->NVZ_CTPDSP   := NVY->NVY_CTPDSP
						NVZ->NVZ_CMOEDA   := NVY->NVY_CMOEDA
						NVZ->NVZ_VALORD   := NVY->NVY_VALOR
						NVZ->NVZ_COTAC1   := NVY->NVY_COTAC1
						NVZ->NVZ_COTAC2   := NVY->NVY_COTAC2
						If lCpoCotac
							NVZ->NVZ_COTAC := NVY->NVY_COTAC
						EndIf
						NVZ->(MsUnlock())
						NVZ->(DbCommit())
					EndIf

					//Grava na fila de sincronização a alteração
					If !lRevisLD
						J170GRAVA("NVY", xFilial("NVY") + (TABLANC)->NVY_COD, "4")
					EndIf

					nCount++

					//Ajusta os contratos
					If aScan( aContr, { | x | x[4] == NVY->(NVY_CCLIEN + NVY_CLOJA + NVY_CCASO) } ) == 0

						If !Empty(aAjustPf := J202BCntPf(cPreft, cContr, cJContr, NVY->NVY_CCLIEN, NVY->NVY_CLOJA, NVY->NVY_CCASO, "DP"))
							cClien  := aAjustPf[1]
							cloja   := aAjustPf[2]
							cContAj := aAjustPf[3]
						EndIf

						If aScan( aContr, { | x | x[3] == cContAj } ) == 0
							aAdd( aContr, {cClien, cloja, cContAj, NVY->(NVY_CCLIEN + NVY_CLOJA + NVY_CCASO) } )
						EndIf

					EndIf

					NX1->(dbSetOrder(1)) //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
					If !(NX1->(dbSeek(xFilial('NX1') + NVY->(NVY_CPREFT + NVY_CCLIEN + NVY_CLOJA + cContAj + NVY_CCASO))))

						cCPART := JurGetDados("NVE", 1, xFilial("NVE") + NVY->(NVY_CCLIEN + NVY_CLOJA + NVY_CCASO), "NVE_CPART1")
						If NX1->(ColumnPos('NX1_CMOELI')) > 0
							aDadosLim := JurGetDados("NVE", 1, xFilial("NVE") + NVY->(NVY_CCLIEN + NVY_CLOJA + NVY_CCASO),;
							                         {'NVE_CMOELI', 'NVE_VLRLI', 'NVE_SALDOI', 'NVE_CFACVL', 'NVE_CTBCVL'})
						EndIf

						RecLock("NX1", .T.)
						NX1->NX1_FILIAL   := xFilial("NX1")
						NX1->NX1_CPREFT   := NVY->NVY_CPREFT
						NX1->NX1_CCONTR   := cContAj
						NX1->NX1_CCLIEN   := NVY->NVY_CCLIEN
						NX1->NX1_CLOJA    := NVY->NVY_CLOJA
						NX1->NX1_CCASO    := NVY->NVY_CCASO
						NX1->NX1_TS       := "2"
						NX1->NX1_DESP     := "1"
						NX1->NX1_LANTAB   := "2"
						NX1->NX1_CPART    := cCPART
						NX1->NX1_TSREV    := "2"
						NX1->NX1_DSPREV   := "2"
						NX1->NX1_TABREV   := "2"
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
						If NX1->NX1_DESP == "2"
							RecLock("NX1", .F.)
							NX1->NX1_DESP   := "1"
							NX1->NX1_DSPREV := "2"
							NX1->(MsUnlock())
							NX1->(DbCommit())
						EndIf
					EndIf
				EndIf

				aAdd(aDP, NVY->NVY_COD)
				RecLock(TABLANC, .F.)
				(TABLANC)->(dbDelete())
				(TABLANC)->(MsUnLock())

			EndIf
			(TABLANC)->(dbSkip())
		EndDo

		If nCount > 0

			cPartAlt := JurUsuario(__CUSERID)
	
			//Ajusta os contratos
			NX8->(dbSetOrder(1)) //NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
			For nI := 1 To Len(aContr)
				If NX8->(dbSeek( xFilial('NX8') + cPreft +  aContr[nI][3]))
					RecLock("NX8", .F.)
					NX8->NX8_DESP := '1'
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
					NX8->NX8_TS     := "2"
					NX8->NX8_DESP   := "1"
					NX8->NX8_LANTAB := "2"
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
			NX0->NX0_DESP   := '1'
			If !lVincLD // Quando é feito o vínculo via LD, não é permitido alterar a situação da Pré, que deve permanecer como "EM REVISÃO"
				NX0->NX0_SITUAC := '3'
			EndIf
			NX0->NX0_USRALT := cPartAlt
			NX0->NX0_DTALT  := date()
			NX0->(msUnlock())
			NX0->(DbCommit())
	
			AEval(aDP, {|x| cDP += x + CRLF})
			J202HIST('99', cPreft, cPartAlt, STR0001+":" + CRLF + cDP, "7") //"Associação de Despesas da Pré-Fatura"
	
		EndIf

	END TRANSACTION

	If nCount == 0
		JurMsgErro(STR0008) // "Nenhum Lançamento Marcado"
	Else
		lNewLanc := .T.
	EndIf

	If !lVincLD .And. !lAutomato
		oBrw202C:GoTop()
		oBrw202C:Refresh( .T. )
	EndIf

	RestArea( aAreaNX8 )
	RestArea( aAreaNX1 )
	RestArea( aArea )

Return NIL
