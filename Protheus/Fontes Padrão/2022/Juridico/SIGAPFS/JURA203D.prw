#INCLUDE "JURA203D.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203D
Rotina de inclusão de Faturas Adicionais na fila de geração de Fatura.

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA203D(oBrwFila)
Local aTemp       := {}
Local aFields     := {}
Local aOrder      := {}
Local aFldsFilt   := {}
Local bseek       := {||}
Local aFiltro     := J203FilUsr('NVV')
Local cCliente    := ""
Local cLoja       := ""
Local cContrato   := ""
Local cTipHon     := ""
Local cGrClien    := ""

Private oBrw203D  := Nil
Private TABLANC   := ''

If Len(aFiltro) == 5
	cCliente   := aFiltro[1]
	cLoja      := aFiltro[2]
	cContrato  := aFiltro[3]
	cTipHon    := aFiltro[4]
	cGrClien   := aFiltro[5]

	aTemp      := J203Filtro('NVV', , cCliente, cLoja, cContrato, cTipHon, cGrClien)
	oTmpTable  := aTemp[1]
	aFldsFilt  := aTemp[2]
	aOrder     := aTemp[3]
	aFields    := aTemp[4]
	TABLANC    := oTmpTable:GetAlias()

	oBrw203D := FWMarkBrowse():New()
	oBrw203D:SetDescription( STR0001 ) // "Seleção de Fatura Adicional para emissão de Fatura"
	oBrw203D:SetAlias( TABLANC )
	oBrw203D:SetTemporary( .T. )
	oBrw203D:SetFields(aFields)
	oBrw203D:oBrowse:SetDBFFilter(.T.)
	oBrw203D:oBrowse:SetUseFilter()

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------

	bseek := {|oSeek| MySeek(oSeek, oBrw203D:oBrowse)}
	oBrw203D:oBrowse:SetIniWindow({||oBrw203D:oBrowse:oData:SetSeekAction(bseek)})
	oBrw203D:oBrowse:SetSeek(.T., aOrder)
	oBrw203D:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw203D:oBrowse:bOnStartFilter := Nil

	oBrw203D:SetMenuDef( 'JURA203D' )
	oBrw203D:SetFieldMark( 'NVV_OK    ' )
	JurSetLeg( oBrw203D, 'NVV' )
	JurSetBSize( oBrw203D )

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw203D:oBrowse:SetObfuscFields(aTemp[7])
	EndIf
	oBrw203D:ForceQuitButton(.T.)
	oBrw203D:oBrowse:SetBeforeClose({ || oBrw203D:oBrowse:VerifyLayout()})
	oBrw203D:SetProfileId("D")
	oBrw203D:Activate()

	oTmpTable:Delete() //Apaga a Tabela temporária

	oBrwFila:Refresh( .T. )
	oBrwFila:GoTop()

EndIf

Return Nil

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

aAdd( aRotina, { STR0002, 'JA203DASS( oBrw203D )', 0, 3, 0, NIL } ) //"Enviar p/ Fila"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de inclusão de Faturas Adicionais na fila de geração de 
Fatura.

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   := Nil
Local oModel  := FWLoadModel( 'JURA203D' )
Local oStruct := FWFormStruct( 2, 'NVV' )

JurSetAgrp( 'NVV',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA203D_VIEW', oStruct, 'NVVMASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100)
oView:SetOwnerView( 'JURA203D_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0003 ) //"Faturas adicionais"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de inclusão de Faturas Adicionais na fila de geração de Fatura.

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, 'NVV' )

oModel:= MPFormModel():New( 'JURA203D', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NVVMASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0004 ) //"Modelo de Dados de Faturas Adicionais na fila de geração de Fatura"
oModel:GetModel( 'NVVMASTER' ):SetDescription( STR0005 ) //"Dados de Faturas Adicionais na fila de geração de Fatura"
oModel:GetModel( 'NVVMASTER' ):SetOnlyView()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203DASS
Inclui as Faturas Adicionais selecionadas na fila de impressão de Faturas

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203DASS(oBrw203D, lAutomato, cAutoMarca)
Local lRet         := .T.
Local aArea        := GetArea()
Local cMarca       := ''
Local lInvert      := .F.
Local cCmd         := ''
Local cCmd2        := ''
Local cCmd3        := ''
Local cQryRes      := GetNextAlias()
Local cQryRes2     := GetNextAlias()
Local cQryRes3     := GetNextAlias()
Local cFila        := 0
Local aResult      := {}
Local cMsg         := STR0009 + CRLF //"Erro ao incluir pelo menos uma fatura adicional na fila: "
Local cFilEsc      := ''
Local aSequen      := {}
Local cMemoErr     := ""
Local lTransact    := .T.
Local nSaveSX8     := GetSx8Len()  // guarda a quantidade de registro não confirmados antes da emissão
Local nVLH         := 0
Local nVLD         := 0
Local aApagar      := {}
Local aRet         := {}
Local nI           := 0
Local dDtEmit      := CToD( '  /  /  ' )
Local aTemp        := {}
Local oTmpTable    := Nil
Local cTamMarca    := Space(TamSX3("NVV_OK")[1])
Local nViasCa      := SuperGetMv('MV_JVIASCA',, 1)
Local nViasBo      := SuperGetMv('MV_JVIASBO',, 1)
Local nViasRe      := SuperGetMv('MV_JVIASRE',, 1)
Local lVincTs      := SuperGetMv('MV_JVINCTS ',, .T.)
Local cMoedaNac    := SuperGetMv('MV_JMOENAC', , "01")
Local cJuncao      := ""
Local lServReinf   := (NXA->( FieldPos( "NXA_TPSERV" )) > 0 )
Local lCpoLimCas   := NVE->(ColumnPos("NVE_CMOELI")) > 0
Local lPoNumbNX5   := NX5->( ColumnPos( "NX5_PONUMB" )) > 0  //12.1.27
Local cPoNumber    := ""

Default lAutomato  := .F.
Default cAutoMarca := ""
Default oBrw203D   := Nil

cMarca  := Iif(!lAutomato, oBrw203D:Mark(), cAutoMarca)
lInvert := Iif(!lAutomato, oBrw203D:IsInvert(), .F.)

aRet := JURA203G( 'FT', Date(), 'FATEMI'  )

If aRet[2] == .T.
	dDtEmit := aRet[1]
Else
	lRet := aRet[2]
EndIf

If lAutomato
	aTemp     := J203Filtro('NVV', , , , , , , lAutomato)
	oTmpTable := aTemp[1]
	TABLANC   := oTmpTable:GetAlias()
EndIf

If lRet
	(TABLANC)->( dbSetOrder(1) )

	(TABLANC)->( dbGoTop() )
	While !(TABLANC)->( EOF() )
		If (TABLANC)->NVV_OK == Iif(!lInvert, cMarca, cTamMarca)
			aAdd(aSequen, (TABLANC)->NVV_COD)
		EndIf
		(TABLANC)->( dbSkip() )
	EndDo

	cCmd := " SELECT NVV.NVV_FILIAL, NVV.NVV_COD, NVV.NVV_CCLIEN, NVV.NVV_CLOJA,  NVV.NVV_PARC, "
	cCmd += "       NVV.NVV_CCONTR, NVV.NVV_DTINIH, NVV.NVV_DTFIMH, NVV.NVV_CMOE1,  NVV.NVV_VALORH,"
	cCmd += "       NVV.NVV_DTINID, NVV.NVV_DTFIMD, NVV.NVV_CMOE2,  NVV.NVV_VALORD, NVV.NVV_CESCR, "
	cCmd += "       NVV.NVV_CMOE3, NVV.NVV_CGRUPO, "
	cCmd += "       NVV.NVV_TRATS, NVV.NVV_TRADSP, NVV.NVV_CCONTR, NVV.NVV_TRALT, NVV.R_E_C_N_O_ NVVRECNO, "
	cCmd += "       NVV.NVV_CMOE4, NVV.NVV_VALORT, NVV.NVV_DTINIT, NVV.NVV_DTFIMT "
	cCmd += "  FROM "+ RetSqlName( 'NVV' ) + " NVV "
	cCmd +=       " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") + "' "
	cCmd +=       " AND NVV.NVV_COD IN ('" + AtoC(aSequen, "', '") + "') "
	cCmd +=       " AND (NVV.NVV_SITUAC = '1' OR "
	cCmd +=             " EXISTS ( SELECT NXG.NXG_CFATAD "
	cCmd +=                        " FROM " + RetSqlName( 'NXG' ) + " NXG "
	cCmd +=                          " WHERE NXG.NXG_FILIAL = '"+ xFilial("NXG") +"' "
	cCmd +=                          " AND NXG.NXG_CFATAD = NVV.NVV_COD "
	cCmd +=                          " AND NXG.NXG_CFATUR = '" + Space(TamSX3("NXG_CFATUR")[1]) + "' "
	cCmd +=                          " AND NXG.NXG_CESCR = '" + Space(TamSX3("NXG_CESCR")[1]) + "' "
	cCmd +=                          " AND NXG.D_E_L_E_T_ = ' ' "
	cCmd +=                    " ) "
	cCmd +=            " ) "
	cCmd +=       " AND NVV.D_E_L_E_T_ = ' ' "

	cCmd := ChangeQuery(cCmd, .F.)

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd), cQryRes, .T., .T.)
	(cQryRes)->(dbgoTop())
	If !(cQryRes)->(EOF())
		While !(cQryRes)->(EOF())
			If JA203VLDIN( (cQryRes)->NVV_CCONTR, (cQryRes)->NVV_COD, 'FA', cMarca )
				BEGIN TRANSACTION
					lTransact  := .T.
					nSaveSX8   := GetSx8Len()

					J203BDelFl( ,(cQryRes)->NVV_COD) //Remove registros perdidos na fila de emissão
					
					cFila  := JurGetNum('NX5', 'NX5_COD')

					cFilEsc := JurGetDados('NS7', 1, xFilial('NS7') + (cQryRes)->NVV_CESCR, 'NS7_CFILIA' )

					aResult := JA201FConv((cQryRes)->NVV_CMOE3, (cQryRes)->NVV_CMOE1, (cQryRes)->NVV_VALORH, "1", dDtEmit, "", "", cFilEsc )
					nVLH    := aResult[1]
					aResult := JA201FConv((cQryRes)->NVV_CMOE3, (cQryRes)->NVV_CMOE4, (cQryRes)->NVV_VALORT, "1", dDtEmit, "", "", cFilEsc )
					nVLH    += aResult[1]
					aResult := JA201FConv((cQryRes)->NVV_CMOE3, (cQryRes)->NVV_CMOE2, (cQryRes)->NVV_VALORD, "1", dDtEmit, "", "", cFilEsc )
					nVLD    := aResult[1]

					RecLock("NX5", .T.)
					NX5->NX5_FILIAL := xFilial('NX5')
					NX5->NX5_COD    := cFila
					NX5->NX5_CFATAD := (cQryRes)->NVV_COD
					NX5->NX5_CCLIEN := (cQryRes)->NVV_CCLIEN
					NX5->NX5_CLOJA  := (cQryRes)->NVV_CLOJA
					NX5->NX5_CCONTR := (cQryRes)->NVV_CCONTR
					NX5->NX5_NPARC  := (cQryRes)->NVV_PARC
					NX5->NX5_CODUSR := __CUSERID
					NX5->NX5_FATADC := '1'
					NX5->NX5_VLFIXH := nVLH
					NX5->NX5_VLFIXD := nVLD
					NX5->NX5_CESCR  := (cQryRes)->NVV_CESCR
					NX5->NX5_CMOEFT := (cQryRes)->NVV_CMOE3 //Moeda da Fatura (NVV_CMOE1 - Moed Hon / NVV_CMOE2 - Moed Desp)
					NX5->NX5_DTLRES := CToD ('  /  /  ')
					NX5->NX5_CALDIS := '1'
					NX5->NX5_TS     := (cQryRes)->NVV_TRATS
					NX5->NX5_DES    := (cQryRes)->NVV_TRADSP
					NX5->NX5_TAB    := (cQryRes)->NVV_TRALT
					NX5->NX5_FIXO   := '2'
					NX5->NX5_DREFIH := SToD( (cQryRes)->NVV_DTINIH )
					NX5->NX5_DREFFH := SToD( (cQryRes)->NVV_DTFIMH )
					NX5->NX5_DREFID := SToD( (cQryRes)->NVV_DTINID )
					NX5->NX5_DREFFD := SToD( (cQryRes)->NVV_DTFIMD )
					NX5->NX5_DREFIT := SToD( (cQryRes)->NVV_DTINIT ) // Futuramente deverá ser criado o campo NVV_DTINIT
					NX5->NX5_DREFFT := SToD( (cQryRes)->NVV_DTFIMT ) // Futuramente deverá ser criado o campo NVV_DTFIMT
					NX5->NX5_QVIAC  := nViasCa
					NX5->NX5_QVIAB  := nViasBo
					NX5->NX5_QVIAR  := nViasRe
					NX5->NX5_VLFATH := nVLH
					NX5->NX5_VLFATD := nVLD
					NX5->NX5_CGRPCL := (cQryRes)->NVV_CGRUPO
					If lServReinf
						cJuncao := JurGetDados("NW3", 2, xFilial("NW3") + (cQryRes)->NVV_CCONTR, "NW3_CJCONT" )
						If Empty(cJuncao)
							NX5->NX5_TPSERV := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NVV_CCONTR, "NT0_TPSERV")
						Else
							NX5->NX5_TPSERV := JurGetDados("NW2", 1, xFilial("NW2") + cJuncao, "NW2_TPSERV")							
						EndIf
					EndIf
					If lPoNumbNX5
						If Empty(cJuncao)
							cPoNumber := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NVV_CCONTR, "NT0_PONUMB")
						Else
							cPoNumber := JurGetDados("NW2", 1, xFilial("NW2") + cJuncao, "NW2_PONUMB")
						EndIf
						NX5->NX5_PONUMB := cPoNumber
					EndIf
					NX5->(MsUnlock())
					NX5->(DbCommit())

					aResult := J203DIncMoe(cMoedaNac, (cQryRes)->NVV_CMOE3, cMoedaNac, 1000, dDtEmit, cFilEsc, cFila, "1") //Insere a cotação da moeda da fatura

					cCmd2 := " SELECT NVW_CODFAD, NVW_CCLIEN, NVW_CLOJA, NVW_CCASO "
					If lCpoLimCas
						cCmd2 += " ,NVE.NVE_CMOELI "
						cCmd2 +=      " FROM "+ RetSqlName( 'NVW' ) + " NVW "
						cCmd2 +=      " INNER JOIN " + RetSqlName( 'NVE' ) + " NVE "
						cCmd2 +=              " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
						cCmd2 +=             " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN "
						cCmd2 +=             " AND NVE.NVE_LCLIEN = NVW.NVW_CLOJA "
						cCmd2 +=             " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO "
						cCmd2 +=             " AND NVE.D_E_L_E_T_ = ' ' "
					Else
						cCmd2 +=      " FROM "+ RetSqlName( 'NVW' ) + " NVW "
					EndIf
					cCmd2 +=       " WHERE NVW.NVW_FILIAL = '" + xFilial("NVW") + "' "
					cCmd2 +=       " AND NVW.NVW_CODFAD = '" + (cQryRes)->NVV_COD + "' "
					cCmd2 +=       " AND NVW.D_E_L_E_T_ = ' ' "

					cCmd2 := ChangeQuery(cCmd2, .F.)
					dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)
					(cQryRes2)->(dbGoTop())

					NX7->(dbSetOrder(1)) //NX7_FILIAL + NX7_CFILA +, NX7_CCLIEN + NX7_CLOJA + NX7_CCASO
					While !(cQryRes2)->(EOF())
						If !NX7->(DbSeek(xFilial("NX7") + cFila + (cQryRes2)->NVW_CCLIEN + (cQryRes2)->NVW_CLOJA + (cQryRes2)->NVW_CCASO))
							If lCpoLimCas .And. !Empty((cQryRes2)->NVE_CMOELI) .And. (cQryRes2)->NVE_CMOELI != cMoedaNac
								aResult := J203DIncMoe(cMoedaNac, (cQryRes2)->NVE_CMOELI, cMoedaNac, 1000, dDtEmit, cFilEsc, cFila) //Insere a cotação da moeda do limite do caso
								If !aResult[1]
									cMemoErr += aResult[2]
									lTransact := .F.
									Exit
								EndIf
							EndIf
							If lTransact
								RecLock("NX7", .T.)
								NX7->NX7_CFILA  := cFila
								NX7->NX7_CCLIEN := (cQryRes2)->NVW_CCLIEN
								NX7->NX7_CLOJA  := (cQryRes2)->NVW_CLOJA
								NX7->NX7_CCASO  := (cQryRes2)->NVW_CCASO
								NX7->(msUnlock())
								NX7->(DbCommit())
							EndIf
						EndIf
						(cQryRes2)->(dbSkip())
					EndDo
					(cQryRes2)->( dbCloseArea() )

					aResult := J203BNXG(cFila, , (cQryRes)->NVV_COD, @cMemoErr) //Grava a fila de emissao nos pagadores da fatura

					If !aResult[1]
						cMemoErr += aResult[2]
						lTransact := .F.
					EndIf

					If lTransact
						cCmd3 := " SELECT NXG.NXG_CMOE "
						cCmd3 += "   FROM "+ RetSqlName( 'NXG' ) + " NXG "
						cCmd3 += "  WHERE NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
						cCmd3 += "    AND NXG.NXG_FILA = '" + cFila + "' "
						cCmd3 += "    AND NXG.D_E_L_E_T_ = ' ' "
	
						cCmd3 := ChangeQuery(cCmd3, .F.)
						dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd3), cQryRes3, .T., .T.)
						(cQryRes3)->(dbgoTop())
	
						While !(cQryRes3)->(EOF())
	
							aResult := J203DIncMoe(cMoedaNac, (cQryRes3)->NXG_CMOE, cMoedaNac, 1000, dDtEmit, cFilEsc, cFila, "1") //Moeda do Pagadores da fatura
							If aResult[1] //Insere a cotação da Moeda de Honorários diferente da fatura
								aResult := J203DIncMoe((cQryRes3)->NXG_CMOE, (cQryRes)->NVV_CMOE1, cMoedaNac, (cQryRes)->NVV_VALORH, dDtEmit, cFilEsc, cFila) 
							EndIf
							If aResult[1] //Insere a cotação da Moeda de Despeas da Fatura
								aResult := J203DIncMoe((cQryRes3)->NXG_CMOE, (cQryRes)->NVV_CMOE2, cMoedaNac, (cQryRes)->NVV_VALORD, dDtEmit, cFilEsc, cFila) 
							EndIf
							If aResult[1] //Insere a cotação da Moeda de Tabelado da Fatura
								aResult := J203DIncMoe((cQryRes3)->NXG_CMOE, (cQryRes)->NVV_CMOE4, cMoedaNac, (cQryRes)->NVV_VALORT, dDtEmit, cFilEsc, cFila) 
							EndIf
	
							If !aResult[1]
								cMemoErr += aResult[2]
								lTransact := .F.
								Exit
							EndIf
	
							(cQryRes3)->(dbSkip())
						EndDo
						(cQryRes3)->( dbCloseArea() )
					EndIf

					//Cotação dos Lançamentos
					If lTransact 
						JA203COTLC(cFila, lVincTs, NX5->NX5_DES == '1', NX5->NX5_TAB == '1', (cQryRes)->NVV_CCONTR, (cQryRes)->NVV_CCLIEN, ;
						            (cQryRes)->NVV_CLOJA, SToD((cQryRes)->NVV_DTINIH), SToD((cQryRes)->NVV_DTFIMH), (cQryRes)->NVV_CMOE3 )
					EndIf

					If lTransact
						aAdd(aApagar, (cQryRes)->NVV_COD)
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
			EndIf

			(cQryRes)->(dbSkip())
		EndDo

		(cQryRes)->( dbCloseArea() )

		MSUnlockAll()

	EndIf

	(TABLANC)->( dbGoTop())
	For nI := 1 To Len(aApagar)
		If (TABLANC)->( dbSeek(xFilial("NVV") + aApagar[nI] ) ) .And. (TABLANC)->NVV_OK == Iif(!lInvert, cMarca, cTamMarca)
			RecLock( TABLANC, .F. )
			(TABLANC)->( dbDelete() )
			(TABLANC)->(MsUnLock())
		EndIf
	Next nI
	(TABLANC)->(dbGoTop())

	If lAutomato
		oTmpTable:Delete()
	EndIf

EndIf

If(!lAutomato)
	oBrw203D:Refresh(.T.)
	oBrw203D:GoTop()

	If !Empty(cMemoErr)
		cMsg += cMemoErr
		JurErrLog(cMsg, STR0013) //"Erro ao enviar para a Fila de Emissão"
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203DIncMoe()
Inclui as cotaçoes dos lançamentos da fatura adicoinal e fixo na fila 
de emissão da fatura.

@param cMoeLanc  Moeda do Lançamento
@param cMoeFat   Moeda de faturamento
@param cMoedaNac Moeda da nacional
@param nValor    Valor do Lancamento
@param dDtEmit   Data de Emissão 
@param cFilEsc   Filial do escritório de faturamento
@param cFila     Fila de emissão da fatura

@author Luciano Pereira dos Santos
@since 07/12/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203DIncMoe(cMoeFat, cMoeLanc, cMoedaNac, nValor, dDtEmit, cFilEsc, cFila, cOrigem)
	Local aRet      := {.T., "", nValor}
	Local aResult   := {}

	Default cOrigem := "2"

	If !Empty(cMoeLanc) .And. (cMoeLanc != cMoedaNac)
		If !(NX6->( DbSeek( xFilial("NX6") + cFila + cMoeLanc) )) 
			aResult := JA201FConv(cMoeFat, cMoeLanc, nValor, "1", dDtEmit, , , cFilEsc )
			If Empty(aResult[4])
				RecLock("NX6", .T.)
				NX6_FILIAL := xFilial("NX6")
				NX6_CFILA  := cFila
				NX6_CMOEDA := cMoeLanc
				NX6_COTAC1 := aResult[2]
				NX6_ORIGEM := cOrigem
				NX6->(msUnlock())
				NX6->(DbCommit())
				aRet := {.T., aResult[4], aResult[1]}
			Else
				aRet := {.F., aResult[4], aResult[1]}
			EndIf
		EndIf
	EndIf

Return aRet
