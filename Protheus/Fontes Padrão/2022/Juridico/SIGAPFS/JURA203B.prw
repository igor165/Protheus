#INCLUDE "JURA203B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203B
Selecionar pré-fatura para a fila de geração de Fatura

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA203B(oBrwFila)
Local aTemp         := {}
Local aFields       := {}
Local aOrder        := {}
Local aFldsFilt     := {}
Local aTmpFld       := {}
Local aTmpFilt      := {}
Local oTmpTable     := Nil
Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local bseek         := {||}
Local aFiltro       := J203FilUsr('NX0')
Local cCliente      := ""
Local cLoja         := ""
Local cContrato     := ""
Local cTipHon       := ""
Local cGrClien      := ""

Private oBrw203B    := Nil
Private oBrwUltFat  := Nil
Private TABLANC     := ''
Private TABFAT      := ''

If Len(aFiltro) == 5
	cCliente   := aFiltro[1]
	cLoja      := aFiltro[2]
	cContrato  := aFiltro[3]
	cTipHon    := aFiltro[4]
	cGrClien   := aFiltro[5]

	aTemp     := J203Filtro('NX0', , cCliente, cLoja, cContrato, cTipHon, cGrClien)
	oTmpTable := aTemp[1]
	aTmpFilt  := aTemp[2]
	aOrder    := aTemp[3]
	aTmpFld   := aTemp[4]
	TABLANC   := oTmpTable:GetAlias()

	If(cLojaAuto == "1")
		AEVAL(aTmpFld , {|aX| Iif ("NX0_CLOJA " != aX[2], Aadd(aFields  , aX),)})
		AEVAL(aTmpFilt, {|aX| Iif ("NX0_CLOJA " != aX[1], Aadd(aFldsFilt, aX),)})
	Else
		aFields   := aTmpFld
		aFldsFilt := aTmpFilt
	EndIf

	// Painel Superior
	oBrw203B := FWMarkBrowse():New()
	oBrw203B:SetDescription( STR0001 ) //"Associação de Time Sheet da Pré-Faturas"
	oBrw203B:SetAlias( TABLANC )
	oBrw203B:SetTemporary( .T. )
	oBrw203B:SetFields(aFields)

	oBrw203B:oBrowse:SetDBFFilter(.T.)
	oBrw203B:oBrowse:SetUseFilter()
	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------
	bseek := {|oSeek| MySeek(oSeek, oBrw203B:oBrowse)}
	oBrw203B:oBrowse:SetIniWindow({|| oBrw203B:oBrowse:oData:SetSeekAction(bseek)})
	oBrw203B:oBrowse:SetSeek(.T., aOrder)

	oBrw203B:oBrowse:SetFieldFilter(aFldsFilt)
	oBrw203B:oBrowse:bOnStartFilter := Nil

	oBrw203B:SetMenuDef( 'JURA203B' )
	oBrw203B:SetFieldMark( 'NX0_OK' )

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw203B:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw203B:ForceQuitButton(.T.)
	oBrw203B:oBrowse:SetBeforeClose({ || oBrw203B:oBrowse:VerifyLayout()})
	JurSetBSize( oBrw203B )
	oBrw203B:SetProfileId("B")
	oBrw203B:Activate()

	oTmpTable:Delete() //Apaga a Tabela temporária

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

aAdd( aRotina, { STR0002, 'JA203BASS( oBrw203B )', 0, 3, 0, NIL } ) //"Enviar p/ Fila"

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
Local oView
Local oModel  := FWLoadModel( 'JURA203B' )
Local oStruct := FWFormStruct( 2, 'NX0' )

JurSetAgrp( 'NX0',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA203B_VIEW', oStruct, 'NX0MASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100)
oView:SetOwnerView( 'JURA203B_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0003 ) //"Time Sheet da Pré-Fatura"

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
Local oStruct    := FWFormStruct( 1, 'NX0' )

oModel:= MPFormModel():New( 'JURA203B', /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( 'NX0MASTER', NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0004 ) //"Modelo de Dados de Time Sheet Pré-Fatura"
oModel:GetModel( 'NX0MASTER' ):SetDescription( STR0005 ) //"Dados de Time Sheet da Pré-Fatura"
oModel:GetModel( 'NX0MASTER' ):SetOnlyView()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203BASS
Inclui as pré-faturas selecionadas na fila de impressão de Faturas
@param oBrw203B  , Grid de Faturas
@param lAutomato , Execução em automação
@param cAutoMarca, Marca de Seleção
@param lMinutaPre, Emissão de Minuta (origem JURA202)
@param lEmite    , Quando a função é chamada pela J202EmitM envia pra fila de emissão

@return lRet           , Inclusão realizada com sucesso
@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203BASS( oBrw203B, lAutomato, cAutoMarca, lMinutaPre, lEmite)
Local lRet         := .T.
Local aArea        := GetArea()
Local lInvert      := .F.
Local cMarca       := ''
Local cCmd         := ''
Local cCmd2        := ''
Local cQryRes      := GetNextAlias()
Local cQryRes2     := GetNextAlias()
Local aResult      := {}
Local cFila        := 0
Local nSequen      := 1
Local dDtIniH      := CToD( '  /  /  ' )
Local dDtFimH      := CToD( '  /  /  ' )
Local dDtIniD      := CToD( '  /  /  ' )
Local dDtFimD      := CToD( '  /  /  ' )
Local dDtIniT      := CToD( '  /  /  ' )
Local dDtFimT      := CToD( '  /  /  ' )
Local aSequen      := {}
Local cMemoErr     := ""
Local cMsg         := STR0021 + CRLF //"Erro ao incluir pelo menos uma pré-fatura na fila: "
Local cFilJ202     := ""
Local aApagar      := {}
Local nI           := 0
Local a203G        := {}
Local aTemp        := {}
Local oTmpTable    := Nil
Local cTamMarca    := Space(TamSX3("NX0_OK")[1])
Local nViasCa      := SuperGetMv('MV_JVIASCA',, 1)
Local nViasBo      := SuperGetMv('MV_JVIASBO',, 1)
Local nViasRe      := SuperGetMv('MV_JVIASRE',, 1)
Local lServReinf   := (NXA->( FieldPos( "NXA_TPSERV" )) > 0 )
Local aRetPE       := {.T., ""}
Local lPoNumber    := NX5->( ColumnPos( "NX5_PONUMB" )) > 0 //12.1.27
Local lJ203BPre	   := ExistBLock("J203BPRE")
Local lAltSitua    := .F.
Local aRetAltSit   := {.T.,{}}

Default lAutomato  := .F.
Default cAutoMarca := ""
Default oBrw203B   := Nil
Default lMinutaPre := IsInCallStack( 'JURA202' )
Default lEmite     := .F.

lInvert := Iif(!lAutomato, oBrw203B:IsInvert(), .F.)
cMarca  := Iif(!lAutomato, oBrw203B:Mark()    , cAutoMarca)

a203G := JURA203G( 'FT', Date(), 'FATEMI' )

If a203G[2] == .F.
	lRet := .F.
EndIf

If lRet

	If lMinutaPre .Or. lAutomato
		aTemp     := J203Filtro('NX0', , , , , , , lAutomato)
		oTmpTable := aTemp[1]
		TABLANC   := oTmpTable:GetAlias()

		If !LockByName( 'JURA203' + __cUserId, .T., .F. )
			ApMsgStop( STR0015 ) //"A rotina de emissão de Faturas/Minutas só pode ser executada uma vez por usuário"
			Return NIL
		EndIf
	EndIf

	(TABLANC)->( dbSetOrder(1) )
	(TABLANC)->( dbGoTop() )

	IF lMinutaPre .And. !lAutomato // Para gerar minuta de pré-fatura o filtro deve ser mesmo do browser da JURA202.
		cFilJ202 := oBrw203B:FWFilter():GetExprADVPL()

		If !Empty(cFilJ202)
			(TABLANC)->( dbClearFilter() )
			(TABLANC)->( dbSetFilter( &( ' { || ' + AllTrim( cFilJ202 ) + ' } ' ), cFilJ202 ) )
		EndIf
	EndIf

	(TABLANC)->( dbGoTop() )
	While !(TABLANC)->( EOF() )
		If (TABLANC)->NX0_OK == Iif(!lInvert, cMarca, cTamMarca)
			aAdd(aSequen, (TABLANC)->NX0_COD)
			If (TABLANC)->NX0_SITUAC $ '2|D' // Em Analise
				lAltSitua := .T. 
			EndIf
		EndIf

		(TABLANC)->( dbSkip() )
	EndDo

	If lAltSitua
		aRetAltSit := JA202SIT( '5', lAutomato, cAutoMarca,/*cFilterAuto*/,.T.)
		lRet := aRetAltSit[1]
	EndIf

	If lRet .And. !Empty(aSequen)

		cCmd := " SELECT NX0.NX0_COD, NX0.NX0_CCLIEN, NX0.NX0_CLOJA, NX0.NX0_CCONTR, NX0.NX0_CJCONT, "
		cCmd +=        " NX0.NX0_CODEXI, NX0.NX0_FATADC, NX0.NX0_VLFATH, NX0.NX0_VTS, NX0.NX0_VDESCT, "
		cCmd +=        " NX0.NX0_VLFATD, NX0.NX0_CESCR, NX0.NX0_CMOEDA, NX0.NX0_TS, NX0.NX0_DESP, "
		cCmd +=        " NX0.NX0_LANTAB, NX0.NX0_FIXO , NX0.NX0_VLFATH, NX0.NX0_VLFATD, NX0.R_E_C_N_O_ as NX0RECNO, "
		cCmd +=        " NX0.NX0_DINITS, NX0.NX0_DFIMTS, NX0.NX0_DINIDP, NX0.NX0_DFIMDP, "
		cCmd +=        " NX0.NX0_DINITB, NX0.NX0_DFIMTB, NX0.NX0_DINIFX, NX0.NX0_DFIMFX, NX0.NX0_CGRUPO, "
		cCmd +=        " NX0.NX0_ACRESH, NX0.NX0_PACREH, NX0.NX0_CFTADC, NX0.NX0_PONUMB"
		If lServReinf
			cCmd +=    ", NX0.NX0_TPSERV "
		EndIf
		cCmd +=    " FROM "+ RetSqlName( 'NX0' ) + " NX0 "
		cCmd +=   " WHERE NX0.NX0_FILIAL = '" + xFilial("NX0") + "' "
		cCmd +=     " AND NX0.NX0_COD IN ('" + AtoC(aSequen, "', '") + "') "
		If lMinutaPre
			cCmd += " AND NX0.NX0_SITUAC IN ('5','9') " // Emitir Minuta / Minuta Sócio
		Else
			cCmd += " AND NX0.NX0_SITUAC IN ('4','6') " // Emitir Fatura / Minuta Emitida
		EndIf
		cCmd +=     " AND NX0.D_E_L_E_T_ = ' '"
		cCmd +=     " AND NOT EXISTS (SELECT NX5.NX5_CPREFT "
		cCmd +=                     " FROM "+ RetSqlName( 'NX5' ) + " NX5 "
		cCmd +=                     " WHERE NX5.D_E_L_E_T_ = ' ' "
		cCmd +=                       " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
		cCmd +=                       " AND NX5.NX5_CPREFT = NX0.NX0_COD "
		cCmd +=                     " ) "

		cCmd := ChangeQuery(cCmd, .F.)

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd), cQryRes, .T., .T.)
		(cQryRes)->(dbgoTop())

		If (cQryRes)->( Eof() )
			APMsgInfo( STR0014 ) // "A(s) Pré-Fatura(s) selecionada(s) já foi(ram) enviada(s) para Fila por outro Usuário, verifique!"
		EndIf

		While !(cQryRes)->(EOF())
			If JA203VLDIN( (cQryRes)->NX0_CCONTR, (cQryRes)->NX0_COD, 'PF', cMarca, lAutomato )
				BEGIN TRANSACTION

					J203BDelFl((cQryRes)->NX0_COD) //Remove registros perdidos na fila de emissão

					dDtIniH := IIf( (cQryRes)->NX0_FIXO == "1", sTod( (cQryRes)->NX0_DINIFX ), sTod( (cQryRes)->NX0_DINITS ) )
					dDtFimH := IIf( (cQryRes)->NX0_FIXO == "1", sTod( (cQryRes)->NX0_DFIMFX ), sTod( (cQryRes)->NX0_DFIMTS ) )
					dDtIniD := sTod( (cQryRes)->NX0_DINIDP )
					dDtFimD := sTod( (cQryRes)->NX0_DFIMDP )
					dDtIniT := sTod( (cQryRes)->NX0_DINITB )
					dDtFimT := sTod( (cQryRes)->NX0_DFIMTB )

					RecLock("NX5", .T.)
					cFila := JurGetNum('NX5', 'NX5_COD')
					NX5->NX5_FILIAL := xFilial('NX5')
					NX5->NX5_COD    := cFila
					NX5->NX5_CPREFT := (cQryRes)->NX0_COD
					NX5->NX5_CFATAD := (cQryRes)->NX0_CFTADC
					NX5->NX5_CCLIEN := (cQryRes)->NX0_CCLIEN
					NX5->NX5_CLOJA  := (cQryRes)->NX0_CLOJA
					NX5->NX5_CCONTR := (cQryRes)->NX0_CCONTR
					NX5->NX5_CJCONT := (cQryRes)->NX0_CJCONT
					NX5->NX5_NPARC  := '0'
					NX5->NX5_DESCH  := (cQryRes)->NX0_VDESCT
					NX5->NX5_ACRESH := (cQryRes)->NX0_ACRESH
					NX5->NX5_PACREH := (cQryRes)->NX0_PACREH
					NX5->NX5_CODUSR := __CUSERID
					NX5->NX5_FATADC := (cQryRes)->NX0_FATADC
					NX5->NX5_CESCR  := (cQryRes)->NX0_CESCR
					NX5->NX5_CMOEFT := (cQryRes)->NX0_CMOEDA
					NX5->NX5_DTLRES := ctod ('  /  /  ')
					NX5->NX5_CALDIS := '1'
					NX5->NX5_TS     := (cQryRes)->NX0_TS
					NX5->NX5_DES    := (cQryRes)->NX0_DESP
					NX5->NX5_TAB    := (cQryRes)->NX0_LANTAB
					NX5->NX5_FIXO   := (cQryRes)->NX0_FIXO
					NX5->NX5_DREFIH := dDtIniH
					NX5->NX5_DREFFH := dDtFimH
					NX5->NX5_DREFID := dDtIniD
					NX5->NX5_DREFFD := dDtFimD
					NX5->NX5_DREFIT := dDtIniT
					NX5->NX5_DREFFT := dDtFimT
					NX5->NX5_QVIAC  := nViasCa
					NX5->NX5_QVIAB  := nViasBo
					NX5->NX5_QVIAR  := nViasRe
					NX5->NX5_VLFATH := (cQryRes)->NX0_VLFATH
					NX5->NX5_VLFATD := (cQryRes)->NX0_VLFATD
					NX5->NX5_CGRPCL := (cQryRes)->NX0_CGRUPO
					If lServReinf
						NX5->NX5_TPSERV := (cQryRes)->NX0_TPSERV
					EndIf
					If lPoNumber   
						NX5->NX5_PONUMB := (cQryRes)->NX0_PONUMB
					EndIf
					NX5->(MsUnlock())
					NX5->(DbCommit())

					cCmd2 := " SELECT NX1.NX1_CCLIEN, NX1.NX1_CLOJA, NX1.NX1_CCASO "
					cCmd2 +=   " FROM " + RetSqlName( 'NX1' ) + " NX1 "
					cCmd2 +=   " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
					cCmd2 +=     " AND NX1.NX1_CPREFT = '" + (cQryRes)->NX0_COD + "'  "
					cCmd2 +=     " AND NX1.D_E_L_E_T_ = ' ' "

					cCmd2 := ChangeQuery(cCmd2, .F.)
					dbUseArea(.T., "TOPCONN", TcGenQry(,, cCmd2), cQryRes2, .T., .T.)

					NX7->(dbSetOrder(1)) //NX7_FILIAL + NX7_CFILA + NX7_CCLIEN + NX7_CLOJA + NX7_CCASO
					While !(cQryRes2)->(EOF())
						If !NX7->(DbSeek(xFilial("NX7") + cFila + (cQryRes2)->NX1_CCLIEN + (cQryRes2)->NX1_CLOJA + (cQryRes2)->NX1_CCASO))
							RecLock("NX7", .T.)
							NX7->NX7_CFILA  := cFila
							NX7->NX7_CCLIEN := (cQryRes2)->NX1_CCLIEN
							NX7->NX7_CLOJA  := (cQryRes2)->NX1_CLOJA
							NX7->NX7_CCASO  := (cQryRes2)->NX1_CCASO
							NX7->(MsUnlock())
							NX7->(DbCommit())
						EndIf
						(cQryRes2)->(dbSkip())
					EndDo
					(cQryRes2)->( dbCloseArea() )

					//Inclui na fila as cotações usadas na Pré-fatura
					JA203COTPF( (cQryRes)->NX0_COD , cFila )

					//Inclui a cotação de pagadores que foram inclusos pós emissão da Pré-Fatura
					aResult := JA203COTPG( (cQryRes)->NX0_COD )

					If !Empty(aResult)
						JA203INNX6(cFila, aResult, "1")
					EndIf

					aResult := J203BNXG( cFila, (cQryRes)->NX0_COD)

					If aResult[1] .And. lJ203BPre
						aRetPE := ExecBlock("J203BPRE", .F., .F., {(cQryRes)->NX0_COD})
						If ValType(aRetPE) == "A" .And. Len(aRetPE) == 2
							aResult[1] := IIF(ValType(aRetPE[1]) == "L", aRetPE[1], .F.)
							aResult[2] := IIF(ValType(aRetPE[2]) == "C", aRetPE[2] + CRLF, "")
						Else
							aResult[1] := .F.
							aResult[2] := STR0022 + CRLF // "Retorno inválido no ponto de entrada 'J203BPRE'. Consulta a documentação."
						EndIf
					EndIf

					If !aResult[1]
						cMemoErr += aResult[2]
						DisarmTransaction()
						Break
					Else
						While GetSX8Len() > 0
							ConfirmSX8()
						EndDo
						aAdd(aApagar, (cQryRes)->NX0_COD)
					EndIf

				END TRANSACTION

				MSUnlockAll()
				nSequen++
			Else
				aSequen[nSequen] := ''
			EndIf //validação

			If lMinutaPre
				//Limpa a Flag de Marcação
				NX0->( DbGoTo( (cQryRes)->NX0RECNO ) )
				RecLock( 'NX0', .F. )
				NX0->NX0_OK := Iif(lInvert, cMarca, cTamMarca) // Limpa flag de marcacao
				NX0->(MsUnlock())
				NX0->(DbCommit())
			EndIf

			(cQryRes)->(dbSkip())

		EndDo
		(cQryRes)->( dbCloseArea() )

		(TABLANC)->(dbGoTop())

		For nI := 1 to len(aApagar)
			If (TABLANC)->( dbSeek(xFilial("NX0") + aApagar[nI] ) ) .And. (TABLANC)->NX0_OK == Iif(!lInvert, cMarca, cTamMarca)
				RecLock( TABLANC, .F. )
				(TABLANC)->( dbDelete() )
				(TABLANC)->(MsUnLock())
			EndIf
		Next nI

		(TABLANC)->(dbGoTop())
	ElseIf !lEmite
		JurErrLog(STR0016, STR0012) //"Nenhuma Pré-fatura enviada para a fila de emissão." "Erro ao enviar para a Fila de Emissão"
	EndIf

	IF lMinutaPre .AND. !lAutomato
		oBrw203B:AddFilter(STR0013,"!(NX0_COD $ '" + AtoC(aSequen, "|") + "')", .F., .T., , , , __CUSERID)
		UnlockByName( 'JURA203' + __cUserId, .T., .F. )
	EndIf
EndIf

If(!lAutomato)
	If !lEmite
		oBrw203B:Refresh(.T.)
		oBrw203B:GoTop()
	EndIf

	If !Empty(cMemoErr)
		cMsg += cMemoErr
		JurErrLog(cMsg, STR0012) //"Erro ao enviar para a Fila de Emissão"
	EndIf
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203BNXG
Rotina para inserir na fila de impressão os pagadores da pre-fatura e fatura adicional

@Param cFila    Codigo da fila de emissão 
@Param cCodPre  Codigo da pré-fatura 
@Param cFatAdic Codigo do fatura adicional

@author por Jacques Alves Xavier
@Date 03/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203BNXG(cFila, cCodPre, cFatAdic)
Local aArea     := GetArea()
Local aRet      := {.T.,''}
Local cSQL      := ""
Local aNXG      := {}
Local nI        := 0
Local dDtVenc   := CToD( '  /  /  ' )
Local cCondPag  := ""
Local cMsgErro  := ""

cSQL := " SELECT NXG.R_E_C_N_O_ NXGRECNO, NXG.NXG_CCDPGT, NXG.NXG_CMOE "
cSQL +=          " FROM " +RetSqlName( 'NXG' )+ " NXG "
cSQL +=          " WHERE NXG.NXG_FILIAL = '"+ xFilial("NXG") +"' "
If !Empty(cCodPre)
	cSQL +=        " AND NXG.NXG_CPREFT = '" + cCodPre + "' "
EndIf
If !Empty(cFatAdic)
	cSQL +=        " AND NXG.NXG_CFATAD = '" + cFatAdic + "' "
EndIf
cSQL +=            " AND NXG.D_E_L_E_T_ = ' ' "

aNXG := JurSQL(cSQL, {"NXGRECNO","NXG_CCDPGT","NXG_CMOE"})

For nI := 1 To Len(aNXG)
	cCondPag := J203CondPg(aNXG[nI][2], aNXG[nI][3], cCodPre, cFatAdic, , , @cMsgErro) 
	If !Empty(cCondPag)
		dDtVenc := J203VENCLI(cCondPag, aNXG[nI][3])
		NXG->( DBGoto( aNXG[nI][1] ) )
		RecLock( 'NXG', .F. )
		NXG->NXG_FILA   := cFila
		NXG->NXG_DTVENC := dDtVenc
		NXG->NXG_CCDPGT := cCondPag
		NXG->(MsUnlock())
		NXG->(DbCommit())
		J203EncFila(cFila, cCodPre, cFatAdic, , NXG->NXG_CLIPG, NXG->NXG_LOJAPG, "A")
	Else
		aRet := {.F., cMsgErro}
		Exit 
	EndIf
Next nI

JurFreeArr(@aNXG)

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203CondPg
Rotina de verificar e validar da condição de pagamento preenchida no pagador
ou conforme os parametros MV_JCPGINT e MV_JCPGNAC.

@Param	cCondPag condição de pagamento (opcional)
@Param	cMoeda   Moeda de faturamento 
@Param	cPreFat  Codigo da pré-fatura 
@Param	cFatAdic Codigo do fatura adicional
@Param	cContr   Código do contrato 
@Param	cParcela Código da parcela de fixo do contrato 
@Param	cMsgErro Mensagem de critica (passada por referência)  

@return cCondic  Código da condição de pagamento

@author Luciano Pereira dos Santos / Abner Oliveira
@since 26/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203CondPg(cCondPag, cMoeda, cPreFat, cFatAdic, cContr, cParcela, cMsgErro) 
	Local cCndPgInt  := SuperGetMv('MV_JCPGINT')
	Local cCndPgNac  := SuperGetMv('MV_JCPGNAC')
	Local cMoedaNac  := SuperGetMv('MV_JMOENAC', , "01")
	Local cMsg       := ""
	Local cCondic    := ""

	Default cMsgErro := ""

	If Empty(cCondPag)
		If cMoeda == cMoedaNac //NXP_CMOE
			cCondPag := cCndPgNac
			cMsg += I18N(STR0017, {cCondPag, 'MV_JCPGNAC'}) //"A condição de pagamento '#1', parâmetro '#2',  não é válida."
		Else
			cCondPag := cCndPgInt
			cMsg += I18N(STR0017, {cCondPag, 'MV_JCPGINT'}) //"A condição de pagamento '#1', parâmetro '#2',  não é válida."
		EndIf
	Else
		Do Case
			Case !Empty(cContr)
				cMsg += I18N(STR0018, {cCondPag, cParcela, cContr} ) //"A condição de pagamento '#1' da parcela '#2', contrato '#3' não é válida."
			Case !Empty(cPreFat)
				cMsg += I18N(STR0019, {cCondPag, cPreFat} ) //"A condição de pagamento '#1' da pré-fatura '#2' não é válida."
			Case !Empty(cFatAdic)
				cMsg += I18N(STR0020, {cCondPag, cPreFat} ) //"A condição de pagamento '#1' da fatura adicional '#2' não é válida."
		EndCase
	EndIf

	cCondic := JurGetDados("SE4", 1, Xfilial("SE4") + cCondPag, "E4_CODIGO") //Valida o codigo 

	If Empty(cCondic) 
		cMsgErro += cMsg + CRLF
	EndIf

Return cCondic

//-------------------------------------------------------------------
/*/{Protheus.doc} J203BDelFl
Rotina apagar fila de emissão para pre-fatura, fatura adiocial o fixo 
que sera emitido (proteção para queda de conexão no processo de emissão)

@Param cfixo    Codigo da da parcela de fixo
@Param cCodPre  Codigo da pré-fatura
@Param cFatAdic Codigo do fatura adicional

@Return Nil

@author Luciano pereira dos Santos
@Date 04/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203BDelFl(cPreFat, cFatAdic, cfixo)
	Local cQuery     := ""
	Local aFila      := {}
	Local nI         := 0

	Default cPreFat  := ""
	Default cFatAdic := ""
	Default cfixo    := ""

	cQuery := " SELECT NX5.R_E_C_N_O_ NX5RECNO"
	cQuery +=        " FROM "+ RetSqlName( 'NX5' ) + " NX5"
	cQuery +=       " WHERE NX5.NX5_FILIAL = '" + xFilial("NX5") + "'" 
	cQuery +=         " AND NX5.NX5_CODUSR <> '"+ __CUSERID +"'"
	If !Empty(cPreFat)
		cQuery +=     " AND NX5.NX5_CPREFT = '" + cPreFat + "' "
	ElseIf !Empty(cFatAdic)
		cQuery +=     " AND NX5.NX5_CFATAD = '" + cFatAdic + " ' "
	ElseIf !Empty(cfixo)
		cQuery +=    " AND NX5.NX5_CFIXO = '" + cfixo + " ' "
	EndIf
	cQuery +=        " AND NX5.D_E_L_E_T_ = ' '"
	aFila := JurSQL(cQuery, {"NX5RECNO"})

	For nI := 1 To Len(aFila) 
		JA203Apag(aFila[nI][1], .T.)
	Next nI

	JurFreeArr(@aFila)

Return
