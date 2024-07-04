#INCLUDE "JURA203C.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203C
Selecionar parcelas fixas para a fila de geração de Fatura.

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA203C(oBrwFila)
Local aTemp      := {}
Local aFields    := {}
Local aOrder     := {}
Local aFldsFilt  := {}
Local aIndEsp    := {}
Local aTmpFld    := {}
Local aTmpFilt   := {}
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bseek      := {||}
Local aFiltro    := J203FilUsr('NX0')
Local cCliente   := ""
Local cLoja      := ""
Local cContrato  := ""
Local cTipHon    := ""
Local cGrClien   := ""

Private oBrw203C := Nil
Private TABLANC  := ''

If Len(aFiltro) == 5
	cCliente   := aFiltro[1]
	cLoja      := aFiltro[2]
	cContrato  := aFiltro[3]
	cTipHon    := aFiltro[4]
	cGrClien   := aFiltro[5]

	//Inclusão de índice por cliente e loja
	Aadd(aIndEsp, {Alltrim(RetTitle("NT1_CCLIEN")) + " + " + Alltrim(RetTitle("NT1_CLOJA")), ;
	               "NT1_CCLIEN+NT1_CLOJA", ;
	               (TAMSX3("NT1_CCLIEN")[1] + TAMSX3("NT1_CLOJA")[1] )})

	aTemp       := J203Filtro('NT1', aIndEsp, cCliente, cLoja, cContrato, cTipHon, cGrClien)
	oTmpTable   := aTemp[1]
	aTmpFilt    := aTemp[2]
	aOrder      := aTemp[3]
	aTmpFld     := aTemp[4]
	TABLANC     := oTmpTable:GetAlias()

	If(cLojaAuto == "1")
		AEVAL(aTmpFld  , {|aX| Iif ("NT1_CLOJA " != aX[2],Aadd(aFields  ,aX),)})
		AEVAL(aTmpFilt , {|aX| Iif ("NT1_CLOJA " != aX[1],Aadd(aFldsFilt,aX),)})
	Else
		aFields   := aTmpFld
		aFldsFilt := aTmpFilt
	EndIf

	oBrw203C := FWMarkBrowse():New()
	oBrw203C:SetDescription( STR0001 ) //"Seleção de Fixo para emissão de Fatura"
	oBrw203C:SetAlias( TABLANC )
	oBrw203C:SetTemporary( .T. )
	oBrw203C:SetFields(aFields)

	oBrw203C:oBrowse:SetDBFFilter(.T.)
	oBrw203C:oBrowse:SetUseFilter()

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------

	bseek := {|oSeek| MySeek(oSeek,oBrw203C:oBrowse)}
	oBrw203C:oBrowse:SetIniWindow({||oBrw203C:oBrowse:oData:SetSeekAction(bseek)})
	oBrw203C:oBrowse:SetSeek(.T.,aOrder)
	oBrw203C:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw203C:oBrowse:bOnStartFilter := Nil

	oBrw203C:SetMenuDef( 'JURA203C' )
	oBrw203C:SetFieldMark( 'NT1_OK' )
	JurSetLeg( oBrw203C, 'NT1' )
	JurSetBSize( oBrw203C )

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw203C:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw203C:ForceQuitButton(.T.)
	oBrw203C:oBrowse:SetBeforeClose({ || oBrw203C:oBrowse:VerifyLayout()})
	oBrw203C:SetProfileId("C")
	oBrw203C:Activate()

	oTmpTable:Delete()

	oBrwFila:Refresh( .T. )
	oBrwFila:GoTop()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmete Mostra os Campos
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

aAdd( aRotina, { STR0002, 'JA203CASS( oBrw203C )', 0, 3, 0, NIL } ) //"Enviar p/ Fila"

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
Local oModel  := FWLoadModel( 'JURA203C' )
Local oStruct := FWFormStruct( 2, 'NT1' )

JurSetAgrp( 'NT1',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA203C_VIEW', oStruct, 'NT1MASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA203C_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0003 ) //"Time Sheet da Pré-Fatura"
IIf(IsBlind(), , oMarkUp:SetFieldMark( 'NT1_OK' )) // Controle devido a automação 

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
Local oStruct    := FWFormStruct( 1, 'NT1' )

oModel:= MPFormModel():New( 'JURA203C', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NT1MASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0004 ) //"Modelo de Dados de Time Sheet Pré-Fatura"
oModel:GetModel( 'NT1MASTER' ):SetDescription( STR0005 ) //"Dados de Time Sheet da Pré-Fatura"
oModel:GetModel( 'NT1MASTER' ):SetOnlyView()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203CASS
Inclui as parcelas de fixo selecionadas na fila de impressão de Faturas

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203CASS(oBrw203C, lAutomato, cAutoMarca)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNT1   := NT1->(GetArea())
Local cMarca     := ''
Local cCmd       := ''
Local cCmd2      := ''
Local cQryRes    := GetNextAlias()
Local cQryRes2   := GetNextAlias()
Local cFila      := 0
Local aResult    := {}
Local cMsg       := STR0009 + CRLF //"Erro ao incluir pelo menos uma parcela de fixo na fila: "
Local nValorFix  := 0
Local nVlrCorri  := 0
Local aAreaNT0   := NT0->(GetArea())
Local oModel096  := Nil
Local cFilEsc    := ''
Local aSequen    := {}
Local cMemoErr   := ""
Local lTransact  := .T.
Local nSaveSX8   := GetSx8Len()  // guarda a quantidade de registro não confirmados antes da emissão
Local dDtEmit    := CToD( '  /  /  ' )
Local aApagar    := {}
Local nI         := 0
Local aRet       := {}
Local lRefDspFx  := SuperGetMv('MV_JRFDPFX',, "1") == "1"
Local aTemp      := {}
Local oTmpTable  := Nil
Local cTamMarca  := Space(TamSX3("NT1_OK")[1])
Local lVincTs    := SuperGetMv('MV_JVINCTS ',, .T.)
Local nViasCa    := SuperGetMv('MV_JVIASCA',, 1)
Local nViasBo    := SuperGetMv('MV_JVIASBO',, 1)
Local nViasRe    := SuperGetMv('MV_JVIASRE',, 1)
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
Local lServReinf := (NXA->( FieldPos( "NXA_TPSERV" )) > 0 )
Local lPoNumber  := NX5->( ColumnPos( "NX5_PONUMB" )) > 0  //12.1.27
Local cDspFix    := AllTrim(GetSX3Cache("NX5_DSPFIX", "X3_RELACAO"))
Local cIniDspFix := IIf(Empty(cDspFix), "1", InitPad(cDspFix))

Default lAutomato  := .F.
Default cAutoMarca := ""
Default oBrw203C   := Nil

// Caso o valor seja passado sem aspas, fazemos a conversão para funcionar corretamente
cIniDspFix := IIf(ValType(cIniDspFix) == "N", CValToChar(cIniDspFix), cIniDspFix)

cMarca  := Iif(!lAutomato, oBrw203C:Mark(), cAutoMarca)
lInvert := Iif(!lAutomato, oBrw203C:IsInvert(), .F.)

aRet := JURA203G( 'FT', Date(), 'FATEMI'  )

If aRet[2]
	dDtEmit := aRet[1]
Else
	lRet    := aRet[2]
EndIf

If lRet

	If lAutomato
		aTemp     := J203Filtro('NT1', , , , , , , lAutomato)
		oTmpTable := aTemp[1]
		TABLANC   := oTmpTable:GetAlias()
	EndIf

	(TABLANC)->( dbSetOrder(1) )
	(TABLANC)->( dbGoTop() )
	While !(TABLANC)->( EOF() )
		If (TABLANC)->NT1_OK == Iif(!lInvert, cMarca, cTamMarca)
			aAdd(aSequen, (TABLANC)->NT1_SEQUEN)
		EndIf
		(TABLANC)->( dbSkip() )
	EndDo

	cCmd := " SELECT NT1.NT1_SEQUEN, NT1.NT1_PARC, NT1.NT1_DATAVE, NT1.NT1_VALORA, NT1.NT1_VALORB, "
	cCmd +=        " NT1.NT1_DATAIN, NT1.NT1_DATAFI, NT0.NT0_CCLIEN, NT0.NT0_CLOJA, NT0.NT0_COD, "
	cCmd +=        " NT0.NT0_CESCR, NT0.NT0_CMOE, NT0.NT0_CMOEF, NT1.R_E_C_N_O_ NT1RECNO, "
	cCmd +=        " NT0.NT0_TPCORR, NT0.NT0_DTBASE, NT0.NT0_PERCOR, NT0.NT0_CINDIC, NT0.NT0_CTPHON, NT1.NT1_CCONTR, "
	cCmd +=        " NT0.R_E_C_N_O_ NT0RECNO, NT0.NT0_CALFX, NT0.NT0_CGRPCL, NW3.NW3_CJCONT, NT0.NT0_PONUMB"
	cCmd +=   " FROM " + RetSqlName( 'NT1' ) + " NT1 "
	cCmd +=   " INNER JOIN " + RetSqlName( 'NT0' ) + " NT0 "
	cCmd +=   " ON (NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cCmd +=       " AND NT0.NT0_SIT = '2' "
	cCmd +=       " AND NT0.NT0_COD = NT1.NT1_CCONTR "
	If NT0->(ColumnPos("NT0_FIXREV")) > 0
		cCmd +=   " AND NT0.NT0_FIXREV = '2' "
	EndIf	
	cCmd +=       " AND NT0.D_E_L_E_T_ = ' ') "
	cCmd +=   " LEFT OUTER JOIN " + RetSqlName( 'NW3' ) + " NW3 "
	cCmd +=   " ON (NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cCmd +=       " AND NW3.NW3_CCONTR = NT1.NT1_CCONTR "
	cCmd +=       " AND NW3.D_E_L_E_T_ = ' ') "
	cCmd +=   " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") + "' "
	cCmd +=     " AND NT1.D_E_L_E_T_ = ' ' "
	cCmd +=     " AND NT1.NT1_SEQUEN IN ('" + AtoC(aSequen, "', '") + "') "
	
	cCmd := ChangeQuery(cCmd, .F.)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd), cQryRes, .T., .T.)

	oModel096 := FWLoadModel("JURA096")
	(cQryRes)->(dbgoTop())
	While !(cQryRes)->(EOF())

		If JUR96FAIXA((cQryRes)->NT0_CTPHON) //Verifica se é por faixa de faturamento - Quantidade de Casos (Fixo)
			oModel096:SetOperation(MODEL_OPERATION_UPDATE)
			NT0->(DBSeek(xFilial("NT0") + (cQryRes)->NT0_COD))
			oModel096:Activate()

			nValorCalc := J96CalcCDF(oModel096, (cQryRes)->NT1_SEQUEN)
			oModel096:DeActivate()
			
			J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4") //Grava na fila de sincronização
		EndIf

		(cQryRes)->(dbSkip())
	EndDo

	(cQryRes)->(dbgoTop())
	If !(cQryRes)->(EOF())
		While !(cQryRes)->(EOF())

			If JA203VLDIN( (cQryRes)->NT0_COD, (cQryRes)->NT1_SEQUEN, 'FX', cMarca ) //Valida se a pré-fatura, parcela adicional ou fixa pode ser incluída na fila de geração de faturas

				BEGIN TRANSACTION
					lTransact  := .T.
					nSaveSX8  := GetSx8Len()

					J203BDelFl( , , (cQryRes)->NT1_SEQUEN) //Remove registros perdidos na fila de emissão

					If IIf(Empty((cQryRes)->NT0_TPCORR), '1', (cQryRes)->NT0_TPCORR) == '1'
						nValorFix := (cQryRes)->NT1_VALORB
						NT1->( dbGoto((cQryRes)->NT1RECNO) )
						RecLock("NT1", .F.)
						NT1->NT1_VALORA := nValorFix
						NT1->(MsUnlock())
						NT1->(DbCommit())
						//Grava na fila de sincronização
						J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
					Else
						nValorFix := (cQryRes)->NT1_VALORA
						If (cQryRes)->NT0_TPCORR == "2" .And. !Empty((cQryRes)->NT0_CINDIC)
							nVlrCorri := JCorrIndic((cQryRes)->NT1_VALORB, ;
								(cQryRes)->NT0_DTBASE, ;
								(cQryRes)->NT1_DATAVE, ;
								(cQryRes)->NT0_PERCOR, ;
								(cQryRes)->NT0_CINDIC, ;
								"V")
							If !nValorFix == Round(nVlrCorri, 2)
								If ApMsgYesNo(STR0010 + (cQryRes)->NT1_CCONTR + STR0011) //"O valor da parcela do contrato "+NT1_CCONTR+
									//"não está atualizado. Deseja fazer a correção?"
									nValorFix := nVlrCorri
									NT1->( dbGoto((cQryRes)->NT1RECNO) )
									RecLock("NT1", .F.)
									NT1->NT1_VALORA := nVlrCorri
									NT1->NT1_DATAAT := Date()
									NT1->(MsUnlock())
									NT1->(DbCommit())
									//Grava na fila de sincronização
									J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
								EndIf
							EndIf
						EndIf
					EndIf

					cFila := JurGetNum('NX5', 'NX5_COD')

					RecLock("NX5", .T.)
					NX5->NX5_FILIAL := xFilial('NX5')
					NX5->NX5_COD    := cFila
					NX5->NX5_CFIXO  := (cQryRes)->NT1_SEQUEN
					NX5->NX5_CCLIEN := (cQryRes)->NT0_CCLIEN
					NX5->NX5_CLOJA  := (cQryRes)->NT0_CLOJA
					NX5->NX5_CCONTR := (cQryRes)->NT0_COD
					NX5->NX5_NPARC  := (cQryRes)->NT1_PARC
					NX5->NX5_CODUSR := __CUSERID
					NX5->NX5_FATADC := '2'
					NX5->NX5_VLFIXH := nValorFix
					NX5->NX5_CESCR  := (cQryRes)->NT0_CESCR
					NX5->NX5_CMOEFT := (cQryRes)->NT0_CMOE
					NX5->NX5_DTLRES := CToD('  /  /  ') //Data limite resp da minuta
					NX5->NX5_CALDIS := '1'
					NX5->NX5_TS     := Iif(lVincTs, '1', '2')
					NX5->NX5_DES    := '2'
					NX5->NX5_TAB    := '2'
					NX5->NX5_FIXO   := '1'
					NX5->NX5_DSPFIX := Iif(cIniDspFix $ "12", cIniDspFix, "1") //Indica se as despesas são vinculadas as parcelas fixas na emissão direta pela fila, por padrão usa inicializador do campo ou 1
					NX5->NX5_DREFIH := SToD( (cQryRes)->NT1_DATAIN )
					NX5->NX5_DREFFH := SToD( (cQryRes)->NT1_DATAFI )
					NX5->NX5_DREFID := IIf(lRefDspFx, SToD( (cQryRes)->NT1_DATAIN ), SToD('19000101'))
					NX5->NX5_DREFFD := IIf(lRefDspFx, SToD( (cQryRes)->NT1_DATAFI ), dDatabase)
					NX5->NX5_DREFIT := CToD('  /  /  ')
					NX5->NX5_DREFFT := CToD('  /  /  ')
					NX5->NX5_QVIAC  := nViasCa
					NX5->NX5_QVIAB  := nViasBo
					NX5->NX5_QVIAR  := nViasRe
					NX5->NX5_VLFATH := nValorFix
					NX5->NX5_CGRPCL := (cQryRes)->NT0_CGRPCL
					If lServReinf
						If Empty((cQryRes)->NW3_CJCONT)
							NX5->NX5_TPSERV := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT1_CCONTR, "NT0_TPSERV")
						Else
							NX5->NX5_TPSERV := JurGetDados("NW2", 1, xFilial("NW2") + (cQryRes)->NW3_CJCONT, "NW2_TPSERV")
						EndIf
					EndIf
					If lPoNumber
						NX5->NX5_PONUMB := (cQryRes)->NT0_PONUMB
					EndIf
					NX5->(MsUnlock())
					NX5->(DbCommit())

					//Cotação dos Lançamentos
					JA203COTLC(cFila, lVincTs,  NX5->NX5_DES == '1', NX5->NX5_TAB == '1', (cQryRes)->NT0_COD, (cQryRes)->NT0_CCLIEN,;
					           (cQryRes)->NT0_CLOJA, SToD((cQryRes)->NT1_DATAIN), SToD((cQryRes)->NT1_DATAFI), (cQryRes)->NT0_CMOE)

					cCmd2 := " SELECT NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO "
					cCmd2 += " FROM " + RetSqlName( 'NUT' ) + " NUT "
					cCmd2 += " WHERE NUT.D_E_L_E_T_ = ' ' "
					cCmd2 +=   " AND NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
					cCmd2 +=   " AND NUT.NUT_CCONTR = '" + (cQryRes)->NT0_COD + "' "

					cCmd2 := ChangeQuery(cCmd2, .F.)
					dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)
					(cQryRes2)->(dbgoTop())

					NX7->(dbSetOrder(1)) //NX7_FILIAL + NX7_CFILA +, NX7_CCLIEN + NX7_CLOJA + NX7_CCASO
					While !(cQryRes2)->(EOF())
						If !NX7->(DbSeek(xFilial("NX7") + cFila + (cQryRes2)->NUT_CCLIEN + (cQryRes2)->NUT_CLOJA + (cQryRes2)->NUT_CCASO))
							RecLock("NX7", .T.)
							NX7->NX7_FILIAL := xFilial("NX7")
							NX7->NX7_CFILA  := cFila
							NX7->NX7_CCLIEN := (cQryRes2)->NUT_CCLIEN
							NX7->NX7_CLOJA  := (cQryRes2)->NUT_CLOJA
							NX7->NX7_CCASO  := (cQryRes2)->NUT_CCASO
							NX7->(MsUnlock())
							NX7->(DbCommit())
						EndIf
						(cQryRes2)->(dbSkip())
					EndDo
					(cQryRes2)->( dbCloseArea() )

					cFilEsc := JurGetDados('NS7', 1, xFilial('NS7') + (cQryRes)->NT0_CESCR, 'NS7_CFILIA' )
					J203CFTPAG((cQryRes)->NT0_COD, (cQryRes)->NT1_SEQUEN, nValorFix, (cQryRes)->NW3_CJCONT, dDtEmit, cFilEsc, cFila, @cMemoErr )  //Verifica o percentual residual da parcela e inclui os pagadores.

					If !Empty(cMemoErr)
						lTransact := .F.
					EndIf

					If (cQryRes)->NT0_CMOE != (cQryRes)->NT0_CMOEF //Moeda do fixo diferente da moeda de faturamento (pré-fatura)
						aResult := J203DIncMoe((cQryRes)->NT0_CMOE, (cQryRes)->NT0_CMOEF, cMoedaNac, nValorFix, dDtEmit, cFilEsc, cFila)
						If !aResult[1]
							cMemoErr  += aResult[2]
							lTransact := .F.
						Else
							RecLock("NX5", .F.)
							NX5->NX5_VLFIXH := aResult[3]
							NX5->NX5_VLFATH := aResult[3]
							NX5->(MsUnlock())
							NX5->(DbCommit())
						EndIf
					EndIf

					If lTransact
						aAdd(aApagar, (cQryRes)->NT1_SEQUEN)
						While GetSX8Len() > nSaveSX8
							ConfirmSX8()
						EndDo
					Else
						While (GetSx8Len() > nSaveSX8)  //Libera os registros usados na transação
							RollBackSX8()
						EndDo
						DisarmTransaction()
						Break
					EndIf

				END TRANSACTION

			EndIf //Validação
			(cQryRes)->(dbSkip())
		EndDo

		(cQryRes)->( dbCloseArea() )
		MSUnlockAll()

	EndIf

	(TABLANC)->(DbGoTop())
	For nI := 1 To Len(aApagar)
		If (TABLANC)->( dbSeek(xFilial("NT1") + aApagar[nI] ) ) .And. (TABLANC)->NT1_OK == Iif(!lInvert, cMarca, cTamMarca)
			RecLock( TABLANC, .F.)
			(TABLANC)->(dbDelete())
			(TABLANC)->(MsUnLock())
		EndIf
	Next nI
	(TABLANC)->(DbGoTop())

	If lAutomato
		oTmpTable:Delete()
	EndIf

EndIf

If !lAutomato
	oBrw203C:Refresh(.T.)
	oBrw203C:GoTop()

	If !Empty(cMemoErr)
		cMsg += cMemoErr
		JurErrLog(cMsg, STR0015) //"Fila de Emissão de Fatura"
	EndIf
EndIf

RestArea(aAreaNT0)
RestArea(aAreaNT1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CFTPAG()
Rotina para recompor os percentual dos pagadores na fila de emissão das faturas

@Param  cContr      Código do contrato
@Param  cFixo       Fatura de Fixo à ser analisada (NT1_SEQUEN)
@Param  nValorFix   Valor da parecela de fixo do contrato
@Param  cConj       Código da junção do contrato
@Param  dDtEmit     Data de emissão 
@Param  cFila       Código da fila de fatura
@Param  cMemoErr    Mensagem de erro quando não houver condição de pagamento (Passado por referência)

@author Luciano Pereira dos Santos / Abner Fogaça
@since 14/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203CFTPAG(cContr, cFixo, nValorFix, cConj, dDtEmit, cFilEsc, cFila, cMemoErr)
Local aArea      := GetArea()
Local aAreaNXG   := NXG->(GetArea())
Local aPagFat    := {}
Local nI         := 0
Local lAtiva     := .F.
Local lPagNXG    := .T.
Local nPosFatAtv := 0
Local nPosDtVenc := 0
Local nPosEscrit := 0
Local nPosFatura := 0
Local nPosWO     := 0
Local cCodigo    := ""
Local cCondVld   := ""
Local cFilaOld   := J203CFila(cFixo, cFila)
Local cEscr      := ""
Local cFatura    := ""
Local cMoedaNac  := SuperGetMv('MV_JMOENAC', , "01")
Local cMoedaCnt  := JurGetDados('NT0', 1, xFilial('NT0') + cContr, 'NT0_CMOE')
Local aFixo      := JurGetDados('NT1', 1, xFilial('NT0') + cFixo, {'NT1_PARC', 'NT1_DATAVE'})
Local cParc      := aFixo[1]
Local dDtVenc    := aFixo[2]
Local lProtJuros := NXP->(ColumnPos("NXP_TXPERM")) > 0 .And. NXG->(ColumnPos("NXG_TXPERM")) > 0 // Proteção
Local lProtNatPg := NXP->(ColumnPos("NXP_CNATPG")) > 0 .And. NXG->(ColumnPos("NXG_CNATPG")) > 0 // Proteção
Local lProtEmail := NXP->(ColumnPos("NXP_EMAIL"))  > 0 .And. NXG->(ColumnPos("NXG_EMAIL"))  > 0 // @12.1.2310
Local lProtEMin  := NXP->(ColumnPos("NXP_EMLMIN")) > 0 .And. NXG->(ColumnPos("NXG_EMLMIN")) > 0 // @12.1.2310
Local lProtGrsHn := NXP->(ColumnPos("NXP_GROSHN")) > 0 .And. NXG->(ColumnPos("NXG_GROSHN")) > 0 // @12.1.2310

If !Empty(cFixo)
	cQuery := " SELECT NXG_PERCEN, NXG_DESPAD, NXG_CLIPG, NXG_LOJAPG, NXG_CCONT, NXG_FPAGTO, NXG_CCDPGT, "
	cQuery +=        " NXG_CBANCO, NXG_CAGENC, NXG_CCONTA, NXG_CMOE, NXG_CRELAT, NXG_CCARTA, NXG_CIDIO, NXG_CIDIO2, "
	cQuery +=        " NXG_DTVENC, NXG_CESCR, NXG_CFATUR, NXG_CWO, "
	If lProtJuros
		cQuery +=    " NXG_TXPERM,  NXG_PJUROS, NXG_DESFIN, NXG_DIADES, NXG_TPDESC,"
	Else
		cQuery +=    " 0 NXG_TXPERM, 0 NXG_PJUROS, 0 NXG_DESFIN, 0 NXG_DIADES, ' ' NXG_TPDESC,"
	EndIf
	cQuery += IIF(lProtNatPg, " NXG_CNATPG, ", " ' ' NXG_CNATPG, ")
	cQuery += IIF(lProtEmail, " NXG_EMAIL, " , " ' ' NXG_EMAIL, ")
	cQuery += IIF(lProtEMin , " NXG_EMLMIN, ", " ' ' NXG_EMLMIN, ")
	cQuery += IIF(lProtGrsHn, " NXG_GROSHN, NXG_PERCGH, ", " ' ' NXG_GROSHN, 0 NXG_PERCGH, ")
	cQuery +=        " (CASE WHEN (NXA.NXA_SITUAC = '1' OR (NXA.NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1')) THEN '1' ELSE '2' END) NXA_SITUAC "
	cQuery +=   " FROM " + RetSqlname('NXG') + " NXG "
	cQuery +=   " INNER JOIN " + RetSqlname('NXA') + " NXA "
	cQuery +=           " ON ( NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=                " AND NXA.NXA_COD = NXG.NXG_CFATUR "
	cQuery +=                " AND NXA.NXA_CESCR = NXG.NXG_CESCR "
	cQuery +=                " AND NXA.NXA_CFILA = NXG.NXG_FILA "
	cQuery +=                " AND NXA.NXA_CFIXO = '" + cFixo + "' "
	cQuery +=                " AND NXA.NXA_CFILA = '" + cFilaOld + "' "
	cQuery +=                " AND NXA.NXA_TIPO = 'FT' "
	cQuery +=                " AND NXA.D_E_L_E_T_ = ' ') " 
	cQuery +=   " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF " 
	cQuery +=            " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
	cQuery +=                 " AND NXA.NXA_COD = NUF.NUF_CFATU "
	cQuery +=                 " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
	cQuery +=                 " AND NUF.D_E_L_E_T_ = ' ') "
	cQuery +=   " WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQuery +=     " AND NXG.D_E_L_E_T_ = ' ' "

	// ATENÇÃO - Campos novos nesse JURSQL devem ser inseridos SEMPRE antes do 'NXG_DTVENC', 
	// por conta da estrutura do aPagFat que deve ter os mesmos campos pra NXP e NXG na mesma ordem, 
	// com exceção dos campos 'NXG_DTVENC', 'NXG_CESCR', 'NXG_CFATUR', 'NXG_CWO' e 'NXA_SITUAC',
	// que só existem no JURSQL da NXG. Por isso esses campos citados devem sempre ficar no final do JURSQL da NXG.
	aPagFat := JurSQL(cQuery, {'NXG_PERCEN', 'NXG_DESPAD', 'NXG_CLIPG' , 'NXG_LOJAPG', 'NXG_CCONT' , ; // 5
	                           'NXG_FPAGTO', 'NXG_CCDPGT', 'NXG_CBANCO', 'NXG_CAGENC', 'NXG_CCONTA', ; // 10
	                           'NXG_CMOE'  , 'NXG_CRELAT', 'NXG_CCARTA', 'NXG_CIDIO' , 'NXG_CIDIO2', ; // 15
	                           'NXG_TXPERM', 'NXG_PJUROS', 'NXG_DESFIN', 'NXG_DIADES', 'NXG_TPDESC', ; // 20
	                           'NXG_CNATPG', 'NXG_EMAIL' , 'NXG_EMLMIN', 'NXG_GROSHN', 'NXG_PERCGH', ; // 25
	                           'NXG_DTVENC', 'NXG_CESCR' , 'NXG_CFATUR', 'NXG_CWO'   , 'NXA_SITUAC'} ) // 30

	If Len(aPagFat) == 0
		lPagNXG := .F. // Indica que o pagador não é da NXG, e sim da NXP

		cQuery := " SELECT NXP_PERCEN, NXP_DESPAD, NXP_CLIPG, NXP_LOJAPG, NXP_CCONT, NXP_FPAGTO, NXP_CCDPGT, "
		If lProtJuros
			cQuery +=    " NXP_TXPERM,  NXP_PJUROS, NXP_DESFIN, NXP_DIADES, NXP_TPDESC,"
		Else
			cQuery +=    " 0 NXP_TXPERM, 0 NXP_PJUROS, 0 NXP_DESFIN, 0 NXP_DIADES, ' ' NXP_TPDESC,"
		EndIf
		cQuery += IIF(lProtNatPg, " NXP_CNATPG, ", " ' ' NXP_CNATPG, ")
		cQuery += IIF(lProtEmail, " NXP_EMAIL, " , " ' ' NXP_EMAIL, ")
		cQuery += IIF(lProtEMin , " NXP_EMLMIN, ", " ' ' NXP_EMLMIN, ")
		cQuery += IIF(lProtGrsHn, " NXP_GROSHN, NXP_PERCGH, ", " ' ' NXP_GROSHN, 0 NXP_PERCGH, ")
		cQuery +=        " NXP_CBANCO, NXP_CAGENC, NXP_CCONTA, NXP_CMOE, NXP_CRELAT, NXP_CCARTA, NXP_CIDIO, NXP_CIDIO2 "
		cQuery +=   " FROM " + RetSqlName('NXP') + " NXP "
		cQuery +=    " WHERE NXP.NXP_FILIAL = '" + xFilial("NXP") + "' "
		If Empty(cConj)
			cQuery +=    " AND NXP.NXP_CCONTR = '" + cContr + "' "
		Else
			cQuery +=    " AND NXP.NXP_CJCONT = '" + cConj + "' "
		EndIf
		cQuery +=        " AND NOT EXISTS (SELECT NXA.R_E_C_N_O_ "  //Não inclui os pagadores já faturados
		cQuery +=                                " FROM " + RetSqlname('NXA') + " NXA "
		cQuery +=                                " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
		cQuery +=                                             " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
		cQuery +=                                              " AND NXA.NXA_COD = NUF.NUF_CFATU "
		cQuery +=                                              " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
		cQuery +=                                              " AND NUF.D_E_L_E_T_ = ' ') "
		cQuery +=                              " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQuery +=                                " AND NXA.NXA_CFIXO = '" + cFixo + "' "
		cQuery +=                                " AND (NXA.NXA_SITUAC = '1' "
		cQuery +=                                 " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1')) " //Fatura de Wo Ativo
		cQuery +=                                " AND NXA.NXA_TIPO = 'FT' "
		cQuery +=                                " AND NXA.NXA_CLIPG = NXP.NXP_CLIPG "
		cQuery +=                                " AND NXA.NXA_LOJPG = NXP.NXP_LOJAPG "
		cQuery +=                                " AND NXA.D_E_L_E_T_ = ' ') "
		cQuery +=        " AND NXP.D_E_L_E_T_ = ' ' "

		aPagFat := JurSQL(cQuery, {'NXP_PERCEN', 'NXP_DESPAD', 'NXP_CLIPG' , 'NXP_LOJAPG', 'NXP_CCONT' , ; // 5
		                           'NXP_FPAGTO', 'NXP_CCDPGT', 'NXP_CBANCO', 'NXP_CAGENC', 'NXP_CCONTA', ; // 10
		                           'NXP_CMOE'  , 'NXP_CRELAT', 'NXP_CCARTA', 'NXP_CIDIO' , 'NXP_CIDIO2', ; // 15
		                           'NXP_TXPERM', 'NXP_PJUROS', 'NXP_DESFIN', 'NXP_DIADES', 'NXP_TPDESC', ; // 20
		                           'NXP_CNATPG', 'NXP_EMAIL' , 'NXP_EMLMIN', 'NXP_GROSHN', 'NXP_PERCGH'} ) // 25
	EndIf

	For nI := 1 To Len(aPagFat)
		If lPagNXG // Verifica se o pagador veio da query da NXG
			nPosFatAtv := Len(aPagFat[nI])
			nPosWO     := nPosFatAtv - 1
			nPosFatura := nPosWO - 1
			nPosEscrit := nPosFatura - 1
			nPosDtVenc := nPosEscrit - 1

			lAtiva  := aPagFat[nI][nPosFatAtv] == "1" // Se a fatura for válida preenche o codigo da fatura na fila 
			dDtVenc := StoD(aPagFat[nI][nPosDtVenc])
			cEscr   := IIf(lAtiva, aPagFat[nI][nPosEscrit], "")
			cFatura := IIf(lAtiva, aPagFat[nI][nPosFatura], "")
			cWO     := IIf(lAtiva, aPagFat[nI][nPosWO]    , "")
		Else
			lAtiva   := .F.
			cCondVld := J203CondPg(aPagFat[nI][7], aPagFat[nI][11], , , cContr, cParc, @cMemoErr)
			If Empty(cCondVld)
				Exit
			Else
				dDtVenc := J203VENCLI(cCondVld, aPagFat[nI][11], dDtVenc)
			EndIf
			cEscr   := ""
			cFatura := ""
			cWO     := ""
		EndIf

		cCodigo := JurGetNum('NXG', 'NXG_COD')
		RecLock("NXG", .T.)
		NXG->NXG_FILIAL := xFilial("NXG")
		NXG->NXG_COD    := cCodigo
		NXG->NXG_CFIXO  := cFixo
		NXG->NXG_FILA   := cFila
		NXG->NXG_PERCEN := aPagFat[nI][1]
		NXG->NXG_DESPAD := aPagFat[nI][2]
		NXG->NXG_CLIPG  := aPagFat[nI][3]
		NXG->NXG_LOJAPG := aPagFat[nI][4]
		NXG->NXG_CCONT  := aPagFat[nI][5]
		NXG->NXG_FPAGTO := aPagFat[nI][6]
		NXG->NXG_CCDPGT := aPagFat[nI][7]
		NXG->NXG_CBANCO := aPagFat[nI][8]
		NXG->NXG_CAGENC := aPagFat[nI][9]
		NXG->NXG_CCONTA := aPagFat[nI][10]
		NXG->NXG_CMOE   := aPagFat[nI][11]
		NXG->NXG_CRELAT := aPagFat[nI][12]
		NXG->NXG_CCARTA := aPagFat[nI][13]
		NXG->NXG_CIDIO  := aPagFat[nI][14]
		NXG->NXG_CIDIO2 := aPagFat[nI][15]
		If lProtJuros // Proteção
			NXG->NXG_TXPERM := aPagFat[nI][16]
			NXG->NXG_PJUROS := aPagFat[nI][17]
			NXG->NXG_DESFIN := aPagFat[nI][18]
			NXG->NXG_DIADES := aPagFat[nI][19]
			NXG->NXG_TPDESC := aPagFat[nI][20]
		EndIf
		If lProtNatPg
			NXG->NXG_CNATPG := aPagFat[nI][21]
		EndIf
		If lProtEmail
			NXG->NXG_EMAIL  := aPagFat[nI][22]
		EndIf
		If lProtEMin
			NXG->NXG_EMLMIN := aPagFat[nI][23]
		EndIf
		If lProtGrsHn
			NXG->NXG_GROSHN := aPagFat[nI][24]
			NXG->NXG_PERCGH := aPagFat[nI][25]
		EndIf
		NXG->NXG_DTVENC := dDtVenc
		NXG->NXG_CESCR  := cEscr
		NXG->NXG_CFATUR := cFatura
		NXG->NXG_CWO    := cWO
		NXG->(MsUnlock())
		NXG->(DbCommit())

		If cMoedaCnt != aPagFat[nI][11] .Or. aPagFat[nI][11] != cMoedaNac //Adiciona na fila a moeda do pagador diferente da moeda da faturamento (pré-fatura)
			aResult := J203DIncMoe(cMoedaCnt, aPagFat[nI][11], cMoedaNac, nValorFix, dDtEmit, cFilEsc, cFila, "1")
			If !aResult[1]
				cMemoErr += aResult[2]
				Exit
			EndIf
		EndIf

		J203CEncFil(cFila, cContr, cConj, cFixo, NXG->NXG_CLIPG, NXG->NXG_LOJAPG, cEscr, cFatura) //Adiciona os encaminhamentos de fatura
	Next nI 

EndIf

RestArea(aAreaNXG)
RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CFila()
Rotina para buscar o codigo da fila da ultima emissao a parcela de
fixo.

@Param  cFixo     Fatura de Fixo à ser analisada
@Param  cFilaNew  Código da fila de emissão

@return cFilaOld  Código da fila de emissão anterior

@author Luciano Pereira dos Santos
@since 13/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203CFila(cFixo, cFilaNew)
	Local cQuery    := ""
	Local aRet      := {}
	Local cFilaOld  := ""

	If !Empty(cFixo)
		cQuery := " SELECT MAX(NXA.NXA_CFILA) NXA_CFILA "
		cQuery +=     " FROM " + RetSqlname('NXA') + " NXA "
		cQuery +=     " LEFT OUTER JOIN " + RetSqlname('NUF') + " NUF "
		cQuery +=                    " ON ( NUF.NUF_FILIAL = '" + xFilial("NUF") + "' "
		cQuery +=                           " AND NXA.NXA_COD = NUF.NUF_CFATU "
		cQuery +=                           " AND NXA.NXA_CESCR = NUF.NUF_CESCR "
		cQuery +=                           " AND NUF.D_E_L_E_T_ = ' ') "
		cQuery +=     " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQuery +=         " AND NXA.NXA_CFIXO = '" + cFixo + "' "
		cQuery +=         " AND (NXA.NXA_SITUAC = '1' "
		cQuery +=              " OR (NXA_SITUAC = '2' AND NUF.NUF_SITUAC = '1' ) ) " //Fatura de Wo Ativo
		cQuery +=         " AND NXA.NXA_TIPO = 'FT' "
		cQuery +=         " AND NXA.D_E_L_E_T_ = ' ' "

		If Len(aRet := JurSQL(cQuery, {'NXA_CFILA'})) == 1
			cFilaOld := aRet[1][1]
		EndIf
	EndIf

	J203FlFxOld(cFilaNew, cFilaOld) //Armazena no array estático as numerações das filas de fixo.

Return cFilaOld

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CEncFil
Rotina para Adiciona na fila de impressão os encaminhamento do
pagador da parcela de fixo.

@Param cFila      Código da fila de emissão
@Param cContr     Código do Contrato
@Param cConj      Código da Junção de contrato
@Param cFixo      Código do Fixo
@Param cCliPag    Código do cliente pagador
@Param cLojaPag   Código da loja do cliente pagador
@Param cEscr     Código do escritório 
@Param cFatura   Código da Fatura 

@author Luciano Pereira dos Santos
@Date 28/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203CEncFil(cFila, cContr, cConj, cFixo, cCliPag, cLojaPag, cEscr, cFatura)
	Local cQuery    := ""
	Local cQryRes   := GetNextAlias()
	Local aStruct   := NVN->(DbStruct())
	Local cCampos   := ""
	Local aCampos   := {}
	Local nI        := 0

	aEval( aStruct, {|a| Aadd(aCampos, a[1])} )
	aEval( aCampos, {|a, nI| cCampos += a + IIf(nI != Len(aCampos), ",", "")} )

	cQuery := " SELECT " + cCampos + " "
	cQuery +=          " FROM " + RetSqlName("NVN")+ " NVN "
	cQuery +=         " WHERE NVN.NVN_FILIAL = '" + xFilial("NVN") + "' "
	cQuery +=           " AND NVN.NVN_CLIPG = '" + cCliPag + "' "
	cQuery +=           " AND NVN.NVN_LOJPG = '" + cLojaPag + "' "
	If Empty(cFatura) .And. Empty(cEscr)
		If !Empty(cConj)
			cQuery +=   " AND NVN.NVN_CJCONT = '" + cConj + "' "
		ElseIf !Empty(cContr)
			cQuery +=   " AND NVN.NVN_CCONTR = '" + cContr + "' " 
		EndIf
		If !Empty(cFixo) .And. NVN->(ColumnPos("NVN_CFIXO")) > 0 // Regra + Proteção
			cQuery +=       " AND NVN_CFIXO = '" + Space(TamSx3("NVN_CFIXO")[1]) + "' "
		EndIf
	ElseIf NVN->(ColumnPos("NVN_CESCR")) > 0 .And. NVN->(ColumnPos("NVN_CFATUR")) > 0 //Proteção (alterar elseif para else)
		cQuery +=       " AND NVN.NVN_CESCR = '" + cEscr + "' "
		cQuery +=       " AND NVN.NVN_CFATUR = '" + cFatura + "' "
	EndIf
	cQuery +=           " AND NVN.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(EOF())
		RecLock("NVN", .T.)
		For nI := 1 To Len(aCampos)
			Do Case
				// Não usar o contido $, pois o existe um campo NVN_CCONT que não pode ser limpo.
				Case aCampos[nI] == "NVN_CCONTR" .Or. aCampos[nI] == "NVN_CJCONT"
					xValor := ""
				Case aCampos[nI] == "NVN_CFIXO"
					xValor := cFixo
				Case aCampos[nI] == "NVN_CFILA"
					xValor := cFila
				OtherWise
					xValor := (cQryRes)->(FieldGet(FieldPos(aCampos[nI])))
			EndCase
			NVN->(FieldPut(FieldPos(aCampos[nI]), xValor))
		Next nI
		NVN->(MsUnlock())
		NVN->(DbCommit())
		(cQryRes)->(DbSkip())
	EndDo

	(cQryRes)->(dbCloseArea())

Return
