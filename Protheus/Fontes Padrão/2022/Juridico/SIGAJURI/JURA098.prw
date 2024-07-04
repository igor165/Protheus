#INCLUDE "JURA098.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA098
Garantia / Alvara

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA098( cProcesso, cFilFiltro, lChgAll )

	Local cParam   := SuperGetMV( 'MV_JHBPESG',, '2' ) // Habilita a tela de pesquisa de garantias/alvarás (1=Sim;2=Não), Valor Padrão: 2
	Local oBrowse
	Local aArea    := GetArea()
	Local aAreaNSZ := NSZ->( GetArea() )

	Private lCtrl  := .T.

	Default cProcesso  := ""
	Default cFilFiltro := xFilial("NT2")
	Default lChgAll    := .T.

	If cParam == '1' .AND. !(IsInCallStack('JURA162') .Or. IsInCallStack('JURA219') .Or. IsInCallStack('JURA095'))
		MsgRun(STR0070,STR0071, {||JURA162("3",STR0007,"JURA098")}) //"Carregando..." # "Aguarde..."
	Else
		// Eh criado o alias NT2_SXB para utilizacao na consulta padrao para nao desposicionar a
		// tabela NT2 pois eh feita uma referencia para ela mesma mesma
		If Select( 'NT2_SXB' ) > 0
			NT2_SXB->( dbCloseArea() )
		EndIf

		ChkFile( 'NT2',,'NT2_SXB' )

		oBrowse := FWMBrowse():New()
		oBrowse:SetChgAll( lChgAll )
		oBrowse:SetDescription( STR0007 )
		oBrowse:SetAlias( "NT2" )
		oBrowse:SetLocate()
		If !Empty( cProcesso )
			oBrowse:SetFilterDefault( "NT2_FILIAL == '" + cFilFiltro + "' .AND. NT2_CAJURI == '" + cProcesso + "'" )
		EndIf
		oBrowse:SetMenuDef( 'JURA098' )
		JurSetBSize( oBrowse, '50,50,50' )
		JurSetLeg( oBrowse, "NT2" )
		oBrowse:Activate()

		NT2_SXB->( dbCloseArea() )

	Endif

	RestArea( aAreaNSZ )
	RestArea( aArea )
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
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina  := {}
	Local aAux     := {}
	Local aSubLev := {}
	Local aSubCor  := {}
	Local nI
	Local aArea    := GetArea()
	Local cGrpRest := JurGrpRest()
	Local lAnoMes  := (SuperGetMV('MV_JVLHIST',, '2') == '1')

	aAdd( aRotina, { STR0001, "PesqBrw"          , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0010, "JurAnexos('NT2', NT2->NT2_CAJURI+NT2->NT2_COD, 1)", 0, 1, 0, .T. } ) // "Anexos"

	If JA162AcRst('07')
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA098"  , 0, 2, 0, NIL } ) // "Visualizar"
	EndIf

	If JA162AcRst('07', 3)
		aAdd( aRotina, { STR0003, "VIEWDEF.JURA098"  , 0, 3, 0, NIL } ) // "Incluir"
	EndIf
	If JA162AcRst('07', 4)
		aAdd( aRotina, { STR0004, "JA098Opc(4)"  , 0, 4, 0, .T. } ) // "Alterar"
	EndIf
	If JA162AcRst('07', 5)
		aAdd( aRotina, { STR0005, "JA098Opc(5)"  , 0, 5, 0, .T. } ) // "Excluir"
	EndIf

	If !('CORRESPONDENTES' $ cGrpRest .Or. 'CLIENTES' $ cGrpRest)
		If ('MATRIZ' $ cGrpRest .And. JA162AcRst('16', 2)) .Or. Empty(cGrpRest)
			If lAnoMes
				aAdd( aRotina, { STR0012, aSubCor                 , 0, 6, 0, .T. } ) //"Correção Valores"
				aAdd( aSubCor, { STR0012, "JURCORVLRS('NT2')"     , 0, 6, 0, .T. } ) // "Correção Valores"
				aAdd( aSubCor, { STR0063, "JURCORVLRS('NT2',,.T.)", 0, 6, 0, .T. } ) // "Recálculo"
			Else
				aAdd( aRotina, { STR0012, "JURCORVLRS('NT2')", 0, 6, 0, .T. } ) // "Correção Valores"
			EndIf
		Endif
	EndIf

	If JA162AcRst('07', 3)
		aAdd( aRotina, { STR0039, aSubLev               , 0, 1, 0, .T. } ) //"Levantamento"
		aAdd( aSubLev, { STR0056, "JA098LEV(1)"      , 0, 3, 0, NIL } ) //"Inclusão"
		aAdd( aSubLev, { STR0057, "J098EXLEV(NT2->NT2_CAJURI)"      , 0, 3, 0, NIL } ) //"Exclusão"
	EndIf

	aAdd( aRotina, { STR0043, "JA098RelG()", 0, 1, 0, NIL } ) // "Extrato de Garantia"

	If JA162AcRst('07') .AND.	(SuperGetMV('MV_JINTVAL',, '2') == '1')
		aAdd( aRotina, { STR0051, "JurTitPag('NT2',NT2->NT2_CAJURI,NT2->NT2_COD,,NT2->NT2_FILDES)" , 0, 2, 0, NIL } )  //Títulos
		If (SuperGetMV('MV_JALCADA',, '2') == '1')
			aAdd( aRotina, { STR0052, "JurLibDoc('NT2','2',NT2->NT2_CAJURI,NT2->NT2_COD,NT2->NT2_FILDES)" , 0, 2, 0, NIL } ) //Liberação de Dctos
		EndIf
	EndIf

	If ExistBlock( 'JA098BTN' )
		aAux := Execblock('JA098BTN', .F., .F.)
		If Valtype( aAux ) == 'A'
			For nI := 1 to Len(aAux)
				aAdd(aRotina, aAux[nI])
			Next
		EndIf
	EndIf

	If lAnoMes
		aAdd( aRotina, { STR0062, "JCall178(NT2->NT2_COD,NT2->NT2_FILIAL)"      , 0, 3, 0, NIL } ) //"Histórico Valores"
	EndIf

	RestArea(aArea)
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Garantia / Alvara

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local aArea   := GetArea()
	Local oModel  := FWLoadModel( "JURA098" )
	Local oStruct := FWFormStruct( 2, "NT2" )
	Local aBotoes := {}

	J098INCPOV(@oView,@oStruct)

	// Se o parametro de "Integração de valores com Financeiro e Contabilidade" estiver como falso,
	// o campo de NT2_INTFIN (Garantia integra financeiro) deverá se retirado da view
	If (SuperGetMV('MV_JINTVAL',, '2') == '2')
		oStruct:RemoveField( "NT2_FILDES" )
		oStruct:RemoveField( "NT2_INTFIN" )
		oStruct:RemoveField( "NT2_PREFIX" )
		oStruct:RemoveField( "NT2_CNATUT" )
		oStruct:RemoveField( "NT2_CTIPOT" )
		oStruct:RemoveField( "NT2_CFORNT" )
		oStruct:RemoveField( "NT2_LFORNT" )
		oStruct:RemoveField( "NT2_NOMEFT" )
		oStruct:RemoveField( "NT2_CGRUAP" )
		oStruct:RemoveField( "NT2_CBANCO" )
		oStruct:RemoveField( "NT2_CAGENC" )
		oStruct:RemoveField( "NT2_CCONTA" )
		oStruct:RemoveField( "NT2_DBANCO" )
		oStruct:RemoveField( "NT2_DAGENC" )
		If oStruct:HasField("NT2_CONDPG")
			oStruct:RemoveField( "NT2_CONDPG" )
		EndIf
		If oStruct:HasField("NT2_PRODUT")
			oStruct:RemoveField( "NT2_PRODUT" )
		EndIF
		If oStruct:HasField("NT2_GRPCOM")
			oStruct:RemoveField( "NT2_GRPCOM" )
		EndIF
	EndIf

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA098_VIEW", oStruct, "NT2MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA098_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) // "Garantia / Alvara"
	oView:EnableControlBar( .T. )

	If Existblock( 'JA98RETBOT' )
		aBotoes := Execblock('JA98RETBOT', .F., .F.)
	EndIf

	If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('03')
		oView:AddUserButton( STR0010, "CLIPS", {| oView | IIF( J95AcesBtn(), JurAnexos("NT2", NT2->NT2_CAJURI+NT2->NT2_COD, 1), FWModelActive()) } )
	EndIf

	RestArea(aArea)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Garantia / Alvara

@author Raphael Zei Cartaxo Silva
@since 27/05/09
@version 1.0

@obs NT2MASTER - Dados do Garantia / Alvara

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStruct    := FWFormStruct( 1, "NT2" )

	//-----------------------------------------
	//Cria os campos virtuais em tela
	//-----------------------------------------
	J098INCPOM(@oModel,@oStruct)
	J098StVld(@oModel,@oStruct)
	oStruct:SetProperty( 'NT2_MOVFIN', MODEL_FIELD_WHEN, { || Empty(Alltrim(M->NT2_MOVFIN)) } )

	If !( 'VAZIO() .OR. VlDtMoeda({M->NT2_DATA, M->NT2_CMOEDA}) .AND. J098SetVal()' $ Alltrim(oStruct:GetProperty("NT2_DATA", MODEL_FIELD_VALID)) )
		oStruct:SetProperty( 'NT2_DATA', MODEL_FIELD_VALID, {|| VAZIO() .OR. VlDtMoeda({M->NT2_DATA, M->NT2_CMOEDA}) .AND. J098SetVal() } )
	EndIf

	J098MOVFIN(@oModel,@oStruct)

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA098", {|oModel| J098VlrCpo(oModel)} /*Pre-Validacao*/, {|oModel| JURA098TOK(oModel)}/*Pos-Validacao*/, {|oModel| J98VerSlJz(oModel)} /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NT2MASTER", NIL, oStruct, /*Pre-Validacao*/,/*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Garantia / Alvara"
	oModel:GetModel( "NT2MASTER" ):SetDescription( STR0009 ) // "Dados de Garantia / Alvara"
	oModel:SetVldActivate( { |oModel| JCANCHANGE( oModel , "NT2" ) } )
	JurSetRules( oModel, 'NT2MASTER',, 'NT2' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA098TOK
Verifica se os 3 campos de data, moeda e valor foram preenchidos

@param 	oModel  	Model a ser verificado
@Return lTudoOk	    Valor lógico de retorno

@sample
{|oModel| JURA098TOK(oModel)}

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA098TOK( oModel )
	Local lTudoOk     := .T.
	Local nOpc        := oModel:GetOperation()
	Local aArea       := GetArea()
	Local oModelNT2   := oModel:GetModel("NT2MASTER")
	Local cGrupo      := ''
	Local aRetI       := {}
	Local lFlagInt    := .T.
	Local nTarifas    := 0
	Local lAnoMesHist := (SuperGetMV('MV_JVLHIST',, '2') == '1')
	Local lLibAlcada  := (SuperGetMV('MV_FINCTAL',, '2') == '2')//Opção para liberação de movimentos com base no formato de liberação simples ou alçada Ex: 1=Liberação Simples ou 2=Alçada
	Local lAlcada     := SuperGetMV('MV_JALCADA',, '2') == '1'
	Local lIntVal     := SuperGetMV('MV_JINTVAL',, '2') == '1'
	Local cTpGar      := oModel:GetValue("NT2MASTER","NT2_CTPGAR")
	Local lDespesa    := (JurGetDados("NQW", 1, xFilial("NQW") + cTpGar, "NQW_DESPES") == '1')
	Local cCajuri     := oModelNT2:getValue( "NT2_CAJURI")
	Local cCodigo     := oModelNT2:getValue( "NT2_COD")
	Local cGaran      := oModelNT2:getValue( "NT2_CGARAN")
	Local cPrefix     := oModelNT2:GetValue( "NT2_PREFIX")
	Local cNatut      := oModelNT2:GetValue( "NT2_CNATUT")
	Local cFornt      := oModelNT2:GetValue( "NT2_CFORNT")
	Local lFornt      := oModelNT2:GetValue( "NT2_LFORNT")
	Local cTipot      := oModelNT2:GetValue( "NT2_CTIPOT")
	Local cMovFin     := oModelNT2:GetValue( "NT2_MOVFIN")
	local cData       := oModelNT2:GetValue( "NT2_DATA")
	Local lIntCom     := .F.
	Local lJxIntval   := .T.

	//Proteção para a integração de compras, campos novos
	If oModelNT2:HasField('NT2_PRODUT') .And. oModelNT2:HasField('NT2_CONDPG')
		lIntCom  := JurGetDados("NQW",1,XFILIAL("NQW")+cTpGar, "NQW_INTCOM") == '1'
	EndIf

	If !lIntCom
		cGrupo := Alltrim(oModelNT2:getValue('NT2_CGRUAP'))
	Else
		If oModelNT2:HasField('NT2_GRPCOM')
			cGrupo := Alltrim(oModelNT2:getValue('NT2_GRPCOM'))
		EndIf
	EndIf

	If !IsInCallStack('J98SELLEI') //Se for levantamento automático não deve passar por essa rotina, pois irá zerar os valores.
		J098VlrCpo(oModel)
	EndIf

	If NT2->(FIELDPOS('NT2_INTFIN')) > 0 .AND. ( !Empty(oModelNT2:GetValue("NT2_INTFIN")) )
		lFlagInt := oModelNT2:GetValue("NT2_INTFIN") == '1'
	EndIF

	If nOpc > 2

		If lTudoOk
			If !(JurGetDados("NQW", 1, xFilial("NQW") + cTpGar, "NQW_TIPO") == cMovFin)
				JurMsgErro(STR0084)//"O tipo selecionado não corresponde com a movimentação. Verifique"
				lTudoOk := .F.
			EndIf
		EndIf

		If lTudoOk
			If Empty(cGaran) .And. cMovFin == '2' .And. (nOpc == 4 .Or. nOpc == 3)
				JurMsgErro(STR0047)//"Preencha o Código da Garantia"
				lTudoOk := .F.
			EndIf
		EndIf

		If lTudoOk
			If !IsInCallStack( 'J98SELLEV')
				lTudoOk := JURSITPROC(cCajuri, 'MV_JTVENGA')
				lCtrl	:= lTudoOk //Controle de MSG
			EndIf

			If nOpc == 5 .And. lTudoOk
				lTudoOk := JurExcAnex ('NT2', cCodigo, cCajuri,'2')
			EndIf
		endIf

		If lTudoOk .And. (nOpc == 3 .Or. nOpc == 4)
			lTudoOk := JurVDtDist("NT2_CAJURI","NT2_DATA")

			If lTudoOk
				If !Empty(cGaran)
					lTudoOk := JurGetDados("NT2", 5, xFilial("NT2") + M->NT2_CGARAN + M->NT2_CAJURI, "NT2_CAJURI") == M->NT2_CAJURI
				EndIf
			EndIf
		EndIf

	EndIf

	If lTudoOk
		If FwFldGet("NT2_DCOMON") == 'AutFederal' .And. DtoC(FwFldGet("NT2_DTMULT")) == "  /  /  "
			JurMsgErro(STR0046)	 //'O campo de data da multa de ser preenchido para este tipo de correção'
			lTudoOk := .F.
		Endif
	Endif

	If lTudoOk .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
		JurIntJuri(cCodigo, cCajuri, "6", Str(nOpc))
	Endif
	//----------------------------------------------
	// Valida se a integração financeira está ativa
	//----------------------------------------------
	If lTudoOk .And. lIntVal .And. lFlagInt

		If !Empty(cMovFin) .And. nOpc <> 5 .And. Empty(cGrupo)
			aRetI   := JAGetGrpAp(,, cTpGar, 1)
			lTudoOk := aRetI[1]
			cGrupo  := AllTrim(aRetI[2])
		EndIf

		//-----------------------------------------------------------------
		//Verifica o parametro para bloqueio de data em final de semana ou
		//feriado
		//-----------------------------------------------------------------
		If (nOpc == 3 .Or. nOpc == 4) .AND. lTudoOk
			lTudoOk := JURA098FDS('NT2_DATA')
		EndIf

		If (nOpc == 3 .Or. nOpc == 4) .AND. lTudoOk
			lTudoOk := JURA098FDS('NT2_DTVENC')
		EndIf

		If lTudoOk .And. (nOpc == 3 .Or. nOpc == 4) .AND. !Empty(cMovFin)
			If Empty(cPrefix) .OR. Empty(cTipot) .OR. Empty(cFornt) .OR. Empty(lFornt) .OR. Empty(cNatut)
				JurMsgErro(STR0048)//"Integração Ativa. Preencher Natureza, Tipo, e Fornecedor"
				lTudoOk := .F.
			ElseIf (nOpc == 3 .Or. nOpc == 4) .AND. (Empty(cGrupo)) .And. lAlcada .And. lTudoOk .And. lLibAlcada
				JurMsgErro(STR0069) //Integração Ativa. Preencher o campo de Grupo de Aprovadores.
				lTudoOk := .F.
			ElseIf lTudoOk
				//Ponto de Entrada para inibir ou complementar a integração automática.
				If Existblock("J98XINTVAL")
					lJxintval := Execblock("J98XINTVAL", .F., .F., {oModel})
				EndIf

				If (cMovFin == '1' .AND. lJxintval)

					//INTEGRAÇÃO COM COMPRAS
					If lIntCom
						If lAlcada .AND. (Empty(FwFldGet("NT2_CONDPG")) .Or. Empty(FwFldGet("NT2_PRODUT")))
							JurMsgErro(STR0090)//Controle de alçada habilitado. Preencher Cond. Pagto e Produto
							lTudoOk := .F.
						ElseIf !lAlcada
							JurMsgErro(STR0091 + "" + Alltrim(JurGetDados("NQW", 1, XFILIAL("NQW") + cTpGar, "NQW_DESC")) + "" + STR0092)
							lTudoOk := .F.
						EndIF
					EndIf

					If lTudoOk
						lTudoOk := JurHisCont(cCajuri, cCodigo, cData, FwFldGet("NT2_VALOR"), '1', '2', 'NT2', nOpc, cGrupo,,,,,,,,,lIntCom)
					EndIf

					If !lTudoOk .And. nOpc == 3
						DbSelectArea("NV3")
						NV3->(DbSetOrder(2))
						NV3->(DbGoTop())
						If NV3->(DbSeek(xFilial("NV3") + cCajuri + cCodigo + '2'))
							Reclock( 'NV3', .F. )
							dbDelete()
							MsUnlock()
						EndIf
					EndIf

				ElseIf (cMovFin == '2') .And. lTudoOk .AND. lJxintval
					If lTudoOk .And. (nOpc == 3 .Or. nOpc == 4)
						aTudoOk := J098ValLev(cCajuri, cGaran)
						If aTudoOk[5] <> 0 .Or. aTudoOk[6] <> 0 //Se os valores de ajustes forem maiores que 0
							JurMsgErro(STR0076) //"O valor dessa garantia já foi levantado totalmente"
							lTudoOk := .F.
						EndIf
						If lTudoOk .And. !(aTudoOk[1]) //Indica se o valor do levantamento é valido, pois caso passe do valor original da garantia, não será permitido
							lTudoOk := .F.
							If aTudoOk[10] == 1 // 1-Valor dos levantamentos é maior que o da garantia / 2-Valor da garantia é maior que o dos levantamentos /3-Valor do levantamento deve ser menor que o da garantia, pois se trata de um levantamento parcial
								JurMsgErro(STR0081)//"O valor do(s) levantamento(s) referente a esta garantia excede o valor da garantia"
							ElseIf aTudoOk[10] == 2
								JurMsgErro(STR0082)//"O valor do(s) levantamento(s) referente a esta garantia é menor que o valor da garantia"
							ElseIf aTudoOk[10] == 3
								JurMsgErro(STR0083)//"Valor do levantamento deve ser menor que o da garantia, pois se trata de um levantamento parcial."
							EndIf
						EndIf
					EndIf

					If lTudoOk
						lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData, oModelNT2:GetValue("NT2_VALOR"), '1', '9', 'NT2', nOpc, cGrupo)
					EndIf
					If FwFldGet("NT2_VCPROV") > 0 .And. lTudoOk
						lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData, oModelNT2:GetValue("NT2_VCPROV"), '2', '9', 'NT2', nOpc, cGrupo)
						If lTudoOk
							nValor := JA098VlrEs(oModel)[1]
							If nValor > 0
								lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData, nValor, '2', '7', 'NT2', nOpc, cGrupo, FwFldGet("NT2_FILDES"))
							EndIf
						EndIf
					EndIf
					If FwFldGet("NT2_VJPROV") > 0 .And. lTudoOk
						lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData, oModelNT2:GetValue("NT2_VJPROV"), '3', '9', 'NT2', nOpc, cGrupo)
						If lTudoOk
							nValor := JA098VlrEs(oModel)[2]
							If nValor > 0
								lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData, nValor, '3', '7', 'NT2', nOpc, cGrupo, FwFldGet("NT2_FILDES"))
							EndIf
						EndIf
					EndIf

					If oModelNT2:GetValue("NT2_AJUCOR") <> 0 .And. lTudoOk .And. nOpc == 3
						If oModelNT2:GetValue("NT2_AJUCOR") > 0
							lTudoOk	:= JurHisCont(cCajuri, cCodigo,cData,(oModelNT2:GetValue("NT2_AJUCOR")),'2','9','NT2', nOpc, cGrupo,.T.)
						Else
							lTudoOk	:= JurHisCont(cCajuri, cCodigo,cData,Abs(oModelNT2:GetValue("NT2_AJUCOR")),'2','A','NT2', nOpc, cGrupo,.T.)
						EndIf
					EndIf

					If oModelNT2:GetValue("NT2_AJUJUR") <> 0 .And. lTudoOk .And. nOpc == 3
						If oModelNT2:GetValue("NT2_AJUJUR") > 0
							lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData,(oModelNT2:GetValue("NT2_AJUJUR")),'3','9','NT2', nOpc, cGrupo,.T.)
						Else
							lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData,Abs(oModelNT2:GetValue("NT2_AJUJUR")),'3','A','NT2', nOpc, cGrupo,.T.)
						EndIf
					EndIf

					nTarifas := oModelNT2:GetValue("NT2_JUROS") + oModelNT2:GetValue("NT2_IR") + oModelNT2:GetValue("NT2_TEFBAN")

					If nTarifas > 0 .And. lTudoOk .And. nOpc == 3
						lTudoOk	:= JurHisCont(cCajuri, cCodigo, cData,nTarifas,'1','B','NT2', nOpc, cGrupo)
					EndIf

					If !lTudoOk .And. nOpc == 3
						DbSelectArea("NV3")
						NV3->(DbSetOrder(2))
						NV3->(DbGoTop())
						If NV3->(DbSeek(xFilial("NV3")+cCajuri+cCodigo+'9'))
							Reclock( 'NV3', .F. )
							dbDelete()
							MsUnlock()
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf nOpc == 5
			If cMovFin == '1'
				lTudoOk := JurHisCont(cCajuri, cCodigo, cData,FwFldGet("NT2_VALOR"),'1','2','NT2', nOpc)
			Else
				lTudoOk := JurHisCont(cCajuri, cCodigo, cData,FwFldGet("NT2_VALOR"),'1','9','NT2', nOpc)
			EndIf
		EndIf
	Endif

	If (lTudoOK .And. nOpc == 3 .And. cMovFin == '2' .And. lDespesa .And. !isBlind())
		lTudoOk := JA098GerNT3(oModel)//Gera despesa com os valores do levantamento
	EndIf

	If lTudoOk .And. (nOpc == 3 .Or. nOpc == 4) .And. (cMovFin == '2') .And. (Val(SuperGetMV('MV_JPERLEV',, '0')) > 0)
		//Valida se é uma inclusão ou alteração do código da garantia pois o tratamento é o mesmo
		If (nOpc == 3 .OR. NT2->NT2_CGARAN <> cGaran)
			If (oModelNT2:GetValue("NT2_VALOR") + JA098SaAl(cCajuri, cGaran)) >;
			(JurGetDados("NT2", 1, xFilial('NT2') + cCajuri + cGaran, "NT2_VALOR")) * (1+val(SuperGetMV('MV_JPERLEV',, '0'))/100)
				lTudoOk := .F.
				JurMsgErro(STR0053) //"O valor do levantamento excede o percentual maximo definido sobre o valor da garantia."
			Endif
		Else
			/*Valida a alteração. Foi preciso separar porque a conta retorna a soma de todas as garantias,
			inclusive a que já esta na tela e não pode ser considerada duas vezes.*/
			If (oModelNT2:GetValue("NT2_VALOR") - NT2->NT2_VALOR + JA098SaAl(cCajuri, cGaran)) >;
			(JurGetDados("NT2", 1, xFilial('NT2') + cCajuri + cGaran, "NT2_VALOR")) * (1+val(SuperGetMV('MV_JPERLEV',, '0'))/100)
				lTudoOk := .F.
				JurMsgErro(STR0053) //"O valor do levantamento excede o percentual maximo definido sobre o valor da garantia."
			Endif
		Endif
	Endif

	If lTudoOk .And. (nOpc == 5)
		//Valida se a garantia possui levantamento vinculado
		lTudoOk := JA098VldLev(cCajuri, cCodigo)
	Endif

	//validação de alteração nos valores para atualização do histórico
	If lTudoOk .And. nOpc == 4 .And. lAnoMesHist
		lTudoOk := J98AltValH(oModel:GetModel("NT2MASTER"), "NT2")
	Endif

	RestArea( aArea )

Return lTudoOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR98G
Função geral que retorna o resultado do calculo conforme o tipo solicitado

@param Tipo de retorno: 1=Garantia Atualizado
2=Alvara
3=Alvara Liquido
4=Saldo Juizo
5=Saldo Juizo Atualizado

@Return nRet Valor numérico de retorno

@sample
JUR98G('NT2','1')

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR98G ( cTipo,cAssJur)
	local nRet    := 0
	Local aArea   := GetArea()
	Local oModel  := FWModelActive()
	Local nValor1 := 0
	Local nValor2 := 0
	Local aSaldo  := {}
	Local nI
	Default cAssJur := oModel:GetValue("NT2MASTER", "NT2_CAJURI"  )

	ParamType 0 Var cTipo As Character

	aSaldo := JA098CriaS(cAssJur)

	//Campo Saldo Garantia
	if cTipo = '1'
		nRet   := 0
		For nI:= 1 to Len(aSaldo)
			If aSaldo[nI][4] == 'G'
				If JA098FrCor(cAssJur, aSaldo[nI][7]) .And. aSaldo[nI][10] > 0
					nRet := nRet + aSaldo[nI][10]
				Else
					nRet := nRet + aSaldo[nI][5]
				EndIf
			EndIf
		Next
		//Campo Saldo Levantamento
	elseif cTipo = '2'

		nRet   := 0

		For nI:= 1 to Len(aSaldo)
			If aSaldo[nI][4] == 'A'
				nRet := nRet + aSaldo[nI][6]
			EndIf
		Next

		//Campo Saldo Levantamento Liquido
	elseif cTipo = '3'

		For nI:= 1 to Len(aSaldo)
			If aSaldo[nI][4] == 'A'
				nValor1 := nValor1 + aSaldo[nI][6]
			EndIf
		Next

		nValor2 := JA098Total( "NT2_CPMF", "NT2", cAssJur ) + JA098Total( "NT2_IR", "NT2", cAssJur ) + ;
		JA098Total( "NT2_TEFBAN", "NT2", cAssJur ) + JA098Total( "NT2_JUROS", "NT2", cAssJur )

		nRet := nValor1 - nValor2

		//Campo Saldo Juizo Sem atualização
	elseif cTipo = '4'

		nRet   := 0

		For nI:= 1 to Len(aSaldo)
			If aSaldo[nI][4] == 'TTSA'
				nRet := nRet + aSaldo[nI][5]
			EndIf
		Next

		//Campo Saldo Juizo Atualizado
	elseif cTipo = '5'

		nRet   := 0

		If JA098FrCor(cAssJur)
			For nI:= 1 to Len(aSaldo)
				If aSaldo[nI][4] == 'TT'
					nRet := nRet + aSaldo[nI][5]
				EndIf
			Next
		Else
			For nI:= 1 to Len(aSaldo) //se não houver Forma de Correção o valor será igual ao do Saldo em Juízo
				If aSaldo[nI][4] == 'TTSA'
					nRet := nRet + aSaldo[nI][5]
				EndIf
			Next
		EndIf
	else
		nRet  := 0
	endif

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098CAJUR
Verifica o preenchimento do campo de código de assunto jurídico
Uso no cadastro de Garantia / Alvara.

@Return cRet	 	Código do assunto jurídico

@author Juliana Iwayama Velho
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098CAJUR()
	Local cRet := ''

	If IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
		cRet := M->NSZ_COD
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098HABCJ
Verifica se a tela não está sendo chamada a partir de Assunto Jurídico
e se a operação é de inclusão, para habilitar o campo de
Código de Assunto Jurídico para preenchimento pelo usuário

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098HABCJ()
	Local lRet  := .T.

	If IsInCallStack('JURA162') .And. !Empty(M->NSZ_COD)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098NT2
Monta a query de garantias a partir do assunto jurídico
Uso no cadastro de Garantia/Alvará

@param cAssJur	    Campo de código de Assunto Jurídico
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098NT2(cAssJur,cTipo)
	Local cQuery   := ""
	Local cSaldo    := ""

	Default cTipo :='1'

	If cTipo == '1'
		cSaldo :=     "COALESCE((SELECT SUM(NT2002.NT2_VALOR + NT2002.NT2_VCPROV + NT2002.NT2_VJPROV + NT2002.NT2_JUROS + NT2002.NT2_IR + NT2002.NT2_TEFBAN) "
		cSaldo +=          "FROM  " + RetSqlName("NT2") +"  NT2002 "
		cSaldo +=             "WHERE NT2002.NT2_MOVFIN = '2' AND NT2002.NT2_CGARAN = NT2001.NT2_COD AND NT2002.NT2_CAJURI = NT2001.NT2_CAJURI "
		cSaldo +=             "AND NT2002.D_E_L_E_T_ = ' ' AND NT2002.NT2_CAJURI = '"+cAssJur+"' AND NT2002.NT2_FILIAL = '" + xFilial("NT2") + "'),0)"

		cQuery :="   SELECT NT2001.NT2_COD, NT2001.NT2_DATA,NQW001.NQW_DESC, NT2001.NT2_VALOR,Round(NT2001.NT2_VALOR+NT2001.NT2_VJPROV+NT2001.NT2_VCPROV-"+ cSaldo + ",2) Saldo,NT2001.R_E_C_N_O_ NT2RECNO, NT2001.NT2_CENVOL " + CRLF
		cQuery +=   "FROM " + RetSqlName("NT2") +" NT2001 " + CRLF
		cQuery +=       "LEFT JOIN " + RetSqlName("NQW") + " NQW001" + CRLF
		cQuery +=       "ON NT2001.NT2_CTPGAR = NQW001.NQW_COD" + CRLF
		cQuery +=       "AND NQW001.D_E_L_E_T_ = ' ' AND NQW001.NQW_FILIAL = '" + xFilial("NQW")+"'" + CRLF
		cQuery +=   "WHERE NT2001.D_E_L_E_T_ = ' ' AND NT2001.NT2_MOVFIN = '1' " + CRLF
		cQuery +=       "AND NT2001.NT2_FILIAL = '"+xFilial("NT2")+"'" + CRLF
		cQuery +=       "AND NT2001.NT2_CAJURI = '"+cAssJur+"' " + CRLF
		cQuery +=       "AND (NT2001.NT2_VALOR+NT2001.NT2_VJPROV+NT2001.NT2_VCPROV -" + cSaldo +") > 0 "
	ElseIf cTipo == '2'
		cQuery += "SELECT NT2_COD, NT2_DATA, NQW_DESC, NT2_VALOR, NT2_CENVOL, NT2.R_E_C_N_O_ NT2RECNO "
		cQuery += " FROM "+RetSqlName("NT2")+" NT2,"+RetSqlName("NQW")+" NQW"
		cQuery += " WHERE NT2_FILIAL = '"+xFilial("NT2")+"'"
		cQuery += " AND NQW_FILIAL = '"+xFilial("NQW")+"'"
		cQuery += " AND NT2_CTPGAR = NQW_COD"
		cQuery += " AND NT2_MOVFIN = '1'"
		cQuery += " AND NT2.D_E_L_E_T_ = ' '"
		cQuery += " AND NQW.D_E_L_E_T_ = ' '"
		cQuery += " AND NT2_CAJURI = '"+cAssJur+"'"
		cQuery += " ORDER BY NT2_DATA "
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098VNT2
Verifica se o valor do campo de garantia é válido
Uso no cadastro de Garantia/Alvará

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098VNT2()
	Local lRet      := .F.
	Local aArea     := {}
	Local oModel
	Local cAlias    := ""
	Local cQuery    := ""
	Local cAssJur   := ""
	Local cCod      := ""
	Local lWSTLegal := JModRst()

	If lWSTLegal
		lRet := .T.

	Else
		If ExistCpo('NT2',M->NT2_CGARAN,2)

			aArea  := GetArea()
			oModel := FWModelActive()
			cAlias := GetNextAlias()

			If IsPesquisa()
				cAssJur := FwFldGet("NT2_CAJURI")
			Else
				cAssJur := oModel:GetValue("NT2MASTER","NT2_CAJURI")
			EndIf

			If Empty(cAssJur)
				cAssJur := NT2->NT2_CAJURI
			EndIf

			cQuery := JA098NT2( cAssJur )

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

			(cAlias)->( dbSelectArea( cAlias ) )
			(cAlias)->( dbGoTop() )

			If IsPesquisa()
				cCod := FwFldGet("NT2_CGARAN")
			Else
				cCod := oModel:GetValue("NT2MASTER",'NT2_CGARAN')
			EndIf

			While !(cAlias)->( EOF() )
				If (cAlias)->NT2_COD == cCod
					lRet := .T.
					Exit
				EndIf
				(cAlias)->( dbSkip() )
			End

			If !lRet
				JurMsgErro(STR0011)
			EndIf

		//-----
			IF Empty( oModel:GetValue("NT2MASTER","NT2_CENVOL") ) .Or.  ((cAlias)->NT2_CENVOL <> oModel:GetValue("NT2MASTER","NT2_CENVOL"))
				oModel:SetValue("NT2MASTER", "NT2_CENVOL", (cAlias)->NT2_CENVOL)
			Endif
		//-----

			(cAlias)->( dbcloseArea() )
			RestArea(aArea)

			If lRet
				ConOut(cAssJur + '' +  cCod)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098F3NT2
Customiza a consulta padrão de garantias
Uso no cadastro de Garantia/Alvará

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098F3NT2(cTipo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local oModel
	Local cQuery   := ''
	Default cTipo :='1'

	IF cTipo == '1'
		If IsPesquisa()
			cQuery   := JA098NT2(Alltrim(M->NT2_CAJURI),'1')
		Else
			oModel   := FWModelActive()
			cQuery   := JA098NT2( oModel:GetValue("NT2MASTER","NT2_CAJURI"),'1' )
		EndIf
	ElseIf cTipo == '2'
		If IsPesquisa()
			cQuery   := JA098NT2(Alltrim(M->NT2_CAJURI),'2')
		Else
			oModel   := FWModelActive()
			cQuery   := JA098NT2( oModel:GetValue("NT2MASTER","NT2_CAJURI"),'2')
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery, .F.)

	uRetorno := ''

	If Select('NT2_SXB') == 0
		ChkFile('NT2',,'NT2_SXB')
	EndIf

	If JurF3Qry( cQuery, 'JURA098F3', 'NT2RECNO', @uRetorno )
		NT2_SXB->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098Total
Realiza a soma do campo por processo

@param cNomeCampo  		Nome do campo a realizar a soma
@param cAliasTabela		Nome da tabela
@param cAssuntoJuridico	Código do assunto

@Return nRet	 		Total

@author Juliana Iwayama Velho
@since 09/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098Total( cNomeCampo, cAliasTabela, cAssuntoJuridico )
	Local nRet   := 0
	Local cTmp   := GetNextAlias()
	Local cQuery := ''
	Local aArea  := GetArea()

	ParamType 0 Var cNomeCampo       As Character
	ParamType 1 Var cAliasTabela     As Character
	ParamType 2 Var cAssuntoJuridico As Character

	cQuery += "SELECT SUM( " + cNomeCampo + " ) SOMA " + CRLF
	cQuery += "  FROM " + RetSqlName( cAliasTabela )+ " "+ cAliasTabela
	cQuery += " WHERE " + cAliasTabela + "_FILIAL = '" + xFilial( cAliasTabela ) + "' " + CRLF
	cQuery += "   AND " + cAliasTabela + "_CAJURI =  '" + cAssuntoJuridico + "' " + CRLF
	cQuery += "   AND " + cAliasTabela + ".D_E_L_E_T_ = ' ' " + CRLF
	cQuery := ChangeQuery(cQuery, .F.)

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	If !(cTmp)->( EOF() )
		nRet := (cTmp)->SOMA
	EndIf

	(cTmp)->( dbCloseArea() )

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098CVinc
Retorna o array de garantias/alvaras do processo, calculando a conta
corrente com vínculo entre os registros

@param cAssJur		Código do assunto
@param cFilOri		Código da Filial de Origem
@param aMsgErr		Array de Erros para retornar a Jura002

@Return aDados  	Array de valores

@author Juliana Iwayama Velho
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098CVinc(cAssJur , cFilOri, aMsgErr )
Local aArea       := GetArea()
Local cAlias      := GetNextAlias()
Local aGarantia   := {}
Local aAlvara     := {}
Local aDados      := {}
Local cDtCorte    := ''
Local cQuery      := ''
Local cFormaCor   := ''
Local cDataAtu    := ''
Local cDataBase   := ''
Local cDataAnt    := ''
Local cDtMesMes   := ''
Local cDtBaseFim  := ''
Local cTipo       := ''
Local cDataJuros  := ''
Local cCampoJur   := ''
Local cTpolo      := ''
Local cCodigo     := '' //Armazena o código da garantia ou alvara para vínculo no extrato
Local nValorAtu   := 0
Local nSaldo      := 0
Local nValorCorr  := 0
Local nVlrCorrAnt := 0
Local nSaldoAnt   := 0
Local nJuros      := 0
Local nVrlACorr   := 0
Local nQtdeAlv    := 0
Local nGarAlv     := 0
Local nValorFim   := 0
Local nValorAlv   := 0
Local nValorSF    := 0
Local nValorSFSA  := 0
Local nI          := 0
Local nJ          := 0
Local nCont       := 0
Local nTotAlvara  := 0
Local nTemp       := 0
Local nSalAtuCor  := 0
Local nSalAtuJur  := 0
Local nScan       := 1
Local nIdSaldo    := 1
Local aTmpVal     := {}

Private nAtuCorre := 0
Private nAtuJuros := 0

Default cFilOri := xFilial('NT2')
Default aMsgErr := {}

	//Pega a data de encerramento do processo para atualizar o saldo da garantia até ele
	cDtCorte := J098Corte(cAssJur,cFilOri)

	/*Saldo Juízo: Soma das garantias sem correção - levantamentos sem considerar juros (NT2_JUROS)
	Saldo Juízo Atualizado: Soma das garantias corrigidas até a data do levantamento - levantamentos considerando juros (NT2_JUROS)
	Saldo Garantia: Soma das garantias atualizadas (NT2_VLRATU) sem descontar levantamento
	Saldo Levantamento Liquido: Levantamento - Juros - impostos - tarifas bancárias - cpmf
	*/

	ParamType 0 Var cAssJur  As Character

	cQuery += " SELECT NT2G.NT2_CAJURI,"
	cQuery +=        " NT2G.NT2_COD NT2CODG," 
	cQuery +=        " NT2G.NT2_DATA DATAG,"
	cQuery +=        " NT2G.NT2_VALOR VALORG,"
	cQuery +=        " NT2G.NT2_CCOMON CORRECAO,"
	cQuery +=        " NT2G.NT2_VLRATU,"
	cQuery +=        " NT9.NT9_TIPOEN,"
	cQuery +=        " NT2G.NT2_DTULAT,"
	cQuery +=        " NT2G.NT2_VJPROV,"
	cQuery +=        " NT2G.NT2_VCPROV,"
	cQuery +=        " NT2A.NT2_COD NT2CODA,"
	cQuery +=        " NT2A.NT2_DATA DATAA,"
	cQuery +=        " ( NT2A.NT2_VALOR "
	cQuery +=          " + NT2A.NT2_JUROS "
	cQuery +=          " + NT2A.NT2_VJPROV "
	cQuery +=          " + NT2A.NT2_IR "
	cQuery +=          " + NT2A.NT2_TEFBAN "
	cQuery +=          " + NT2A.NT2_VCPROV "
	cQuery +=          " + NT2A.NT2_CREDIT "
	cQuery +=          " - NT2A.NT2_DEBITO "
	cQuery +=          " + NT2A.NT2_AJUCOR "
	cQuery +=          " + NT2A.NT2_AJUJUR ) VALORA,"
	cQuery +=        " NT2A.NT2_VALOR VALORSA"
	cQuery += " FROM " + RetSqlName('NT2') + " NT2G LEFT JOIN " + RetSqlName('NT9') + " NT9"
	cQuery +=		" ON ( NT9.NT9_FILIAL = '"+xFilial('NT9')+"' AND NT2G.NT2_CENVOL = NT9.NT9_COD AND NT9.D_E_L_E_T_ = ' ' )"
	cQuery += "	LEFT JOIN " + RetSqlName('NT2') + " NT2A"
	cQuery += 		" ON ( NT2G.NT2_COD = NT2A.NT2_CGARAN AND NT2G.NT2_CAJURI = NT2A.NT2_CAJURI AND NT2G.NT2_FILIAL = NT2A.NT2_FILIAL AND NT2A.D_E_L_E_T_ = '  ')"
	cQuery += "	WHERE NT2G.NT2_FILIAL = '" + cFilOri + "'"
	cQuery +=	" AND NT2G.NT2_CAJURI = '" + cAssJur + "'"
	cQuery += 	" AND NT2G.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NT2G.NT2_MOVFIN = '1'"
	cQuery += "	ORDER BY NT2G.NT2_COD, NT2A.NT2_DATA"

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F. )

	TcSetField( cAlias, 'DATAG' , 'D', TamSX3('NT2_DATA' )[1], 0 )
	TcSetField( cAlias, 'DATAA' , 'D', TamSX3('NT2_DATA' )[1], 0 )
	TcSetField( cAlias, 'NT2_DTULAT' , 'D', TamSX3('NT2_DTULAT' )[1], 0 )
	TcSetField( cAlias, 'NT2_VLRATU', 'N', TamSX3('NT2_VLRATU')[1], TamSX3('NT2_VLRATU')[2] )
	TcSetField( cAlias, 'VALORG', 'N', TamSX3('NT2_VALOR')[1], TamSX3('NT2_VALOR')[2] )
	TcSetField( cAlias, 'VALORA', 'N', TamSX3('NT2_VALOR')[1], TamSX3('NT2_VALOR')[2] )
	TcSetField( cAlias, 'NT2_VJPROV', 'N', TamSX3('NT2_VJPROV')[1], TamSX3('NT2_VJPROV')[2] )
	TcSetField( cAlias, 'NT2_VCPROV', 'N', TamSX3('NT2_VCPROV')[1], TamSX3('NT2_VCPROV')[2] )

	While !(cAlias)->( EOF() )
		if ((nTemp := aScan(aGarantia,{|x| x[2] == (cAlias)->NT2CODG},nScan)) == 0)
			aAdd(aGarantia, { (cAlias)->NT2_CAJURI, (cAlias)->NT2CODG, '1', (cAlias)->DATAG,(cAlias)->VALORG,;
			(cAlias)->CORRECAO, IIF(VAL((cAlias)->NT9_TIPOEN)>3,' ',(cAlias)->NT9_TIPOEN), (cAlias)->NT2_VLRATU, (cAlias)->NT2_DTULAT,(cAlias)->NT2_VJPROV,(cAlias)->NT2_VCPROV,!Empty((cAlias)->NT2CODA/*TemAlvara?*/)})
		Else
			nScan := nTemp
		Endif

		if !Empty((cAlias)->NT2CODA) // se existe alvará
			aAdd(aAlvara, { (cAlias)->NT2_CAJURI, (cAlias)->NT2CODA, '2', (cAlias)->DATAA,(cAlias)->VALORA,;
			(cAlias)->CORRECAO, (cAlias)->NT2CODG, IIF(VAL((cAlias)->NT9_TIPOEN)>3,' ',(cAlias)->NT9_TIPOEN), (cAlias)->VALORSA})
		Endif

		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbCloseArea() )

	cTipo  := JurGetDados("NW8", 1, xFilial("NW8") + 'NT2' + 'NT2_VALOR', 'NW8_DJUROS')

	If cTipo == '1'
		cDataJuros := DTOS(JurGetDados('NUQ', 2 , xFilial('NUQ') + cAssJur , 'NUQ_DTDIST'))
	ElseIf cTipo == '2'
		cDataJuros := DTOS(JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur , 'NSZ_DTENTR'))
	EndIf

	cTpolo := ''

	For nI:= 1 to Len(aGarantia)

		If nI == 1
			cTpolo := aGarantia[nI][7]
		Endif

		//Na tela de garantia não pode ser usado o índice da NSZ, mesmo se estiver em branco
		cFormaCor:= aGarantia[nI][6]

		If cTipo == '3'
			cDataJuros := DTOS(aGarantia[nI][4])
		ElseIf cTipo == '4'
			cCampoJur  := JurGetDados('NW8', 1 , xFilial('NW8') + 'NT2' + 'NT2_VALOR' , 'NW8_CDATAJ')
			cDataJuros := DTOS(JurGetDados('NT2', 1 , xFilial('NT2') + aGarantia[nI][1] + aGarantia[nI][2] , cCampoJur))
			if Empty(cDataJuros)
				cDataJuros := DTOS(aGarantia[nI][4])
			Endif
			If Alltrim(cDataJuros) == ''
				cDataJuros := DTOS(aGarantia[nI][4])
			EndIf
		EndIf

		cQuery := ''
		
		//Busca a quantidade de levantamentos por garantia
		cQuery += "SELECT COUNT(NT2_CGARAN) QTDE, NT2_CGARAN "
		cQuery += "  FROM " + RetSqlName( 'NT2' ) + " NT2 "
		cQuery += " WHERE NT2_FILIAL = '" + cFilOri + "' "
		cQuery += "   AND NT2_CAJURI = '" + cAssJur + "' AND NT2.D_E_L_E_T_ = ' ' "
		cQuery += "   AND NT2_MOVFIN = '2' AND NT2_CGARAN ='"+aGarantia[nI][2]+"'"
		cQuery += "   GROUP BY NT2_CGARAN "

		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F. )

		If (cAlias)->( EOF() )
			nQtdeAlv := 0
			nGarAlv  := '0'
		Else
			nQtdeAlv := (cAlias)->QTDE
			nGarAlv  := ((cAlias)->NT2_CGARAN)
		EndIf

		(cAlias)->( dbCloseArea() )

		nValorAtu:= aGarantia[nI][5]
		cDataAtu := DTOS(aGarantia[nI][4])

		aAdd(aDados,{nIdSaldo,cDataAtu,'','G',nValorAtu,0,aGarantia[nI][2],aGarantia[nI][2],aGarantia[nI][7],aGarantia[nI][8]})

		nCont 	   := 1
		nTotAlvara := 0

		For nJ:= 1 to Len(aAlvara)

			If aAlvara[nJ][7] == aGarantia[nI][2]

				nValorAtu  := aAlvara[nJ][5]
				cDataAtu   := DTOS(aAlvara[nJ][4])
				nValorAlv  := aAlvara[nJ][5]
				nTotAlvara += aAlvara[nJ][9]

				cDtMesMes := DTOS(aAlvara[nJ][4])

				If nQtdeAlv == 1 .Or. (nQtdeAlv > 1 .And. nCont == 1) //se esta no primeiro levantamento ou só tem 1
					nVrlACorr := aGarantia[nI][5]
					cDataBase := DTOS(aGarantia[nI][4])
					If nQtdeAlv == 1 //se tiver apenas um alvará, assumir a data dele como fim da correção do valor principal/original
						cDataAnt := cDataAtu
					EndIf
					nValorCorr := aGarantia[nI][8] //se for o primeiro alvará, o valor atualizado já esta guardado na tabela
				Else
					cDataBase := cDataAnt
					nVrlACorr := nSaldoAnt
					nValorCorr:= JA002Valor( cFormaCor, nVrlACorr, cDataBase, cDtMesMes, cDataJuros, , , , , , @aMsgErr ) //se não for o primeiro, deve corrigir o saldo
				EndIf

				if nValorCorr == 0
					nValorCorr := nVrlACorr
				Endif

				nJuros    := nValorCorr - nVrlACorr

				nIdSaldo := nIdSaldo + 1

				If nJ == 1 .Or. Len(aAlvara) > 1
					cCodigo := aGarantia[nI][2]
				Else
					cCodigo := aAlvara[nJ][2]
				EndIf

				aAdd(aDados,{nIdSaldo,cDataBase,cDtMesMes,'J',nJuros,0,aGarantia[nI][2],cCodigo,aGarantia[nI][7],0})
				nIdSaldo := nIdSaldo + 1
				aAdd(aDados,{nIdSaldo,cDtMesMes,'','S',nValorCorr,0,aGarantia[nI][2],cCodigo,aGarantia[nI][7],0})
				nIdSaldo := nIdSaldo + 1
				aAdd(aDados,{nIdSaldo,cDtMesMes,'','A',0,nValorAtu,aGarantia[nI][2],aAlvara[nJ][2],aGarantia[nI][7],0})
				nIdSaldo := nIdSaldo + 1
				nSaldo    := Round(nValorCorr,2) - nValorAtu
				aAdd(aDados,{nIdSaldo,cDtMesMes,'','S',nSaldo,0,aGarantia[nI][2],aGarantia[nI][2],aGarantia[nI][7],0})

				cDataAnt  := cDataAtu
				nSaldoAnt := nSaldo

				If nQtdeAlv == nCont
					nValorFim := nSaldo
					cDtBaseFim:= cDataAnt
				Endif

				nIdSaldo := nIdSaldo + 1
				nCont := nCont + 1

				If cTipo == '3'
					cDataJuros := DTOS(aAlvara[nJ][4])
				ElseIf cTipo == '4'
					cCampoJur  := JurGetDados('NW8', 1 , xFilial('NW8') + 'NT2' + 'NT2_VALOR' , 'NW8_CDATAJ')
					cDataJuros := DTOS(JurGetDados('NT2', 1 , xFilial('NT2') + aAlvara[nJ][1] + aAlvara[nJ][2] , cCampoJur))

					if Empty(cDataJuros)
						cDataJuros := DTOS(aAlvara[nJ][4])
					Endif

					If Alltrim(cDataJuros) == ''
						cDataJuros := DTOS(aGarantia[nJ][4])
					EndIf

				EndIf

			Else

			EndIf

		Next

		cDtMesMes := cDtCorte

		If nQtdeAlv > 0 .And. aGarantia[nI][2] == nGarAlv

		Else
			nValorFim := aGarantia[nI][5]
			cDtBaseFim:= DTOS(aGarantia[nI][4])
		EndIf

		nVlrCorrAnt := ROUND(nValorCorr,2)
		nVlrFimAnt	:= nValorFim

		If nQtdeAlv > 0
			nAtuCorre := 0
			nAtuJuros := 0
			
			nValorCorr := JA002Valor( cFormaCor, nValorFim, cDtBaseFim, cDtMesMes, cDataJuros, , , , , , @aMsgErr )
			nSalAtuJur := nAtuJuros
			nSalAtuCor := nAtuCorre
		Else
			nValorCorr := IIF(aGarantia[nI][8] > 0, aGarantia[nI][8], aGarantia[nI][5] ) // Se existir valor atualizado (foi aplicada correção) usa o mesmo, senão usa o valor original
			nSalAtuJur := aGarantia[nI][10]
			nSalAtuCor := aGarantia[nI][11]
		EndIf

		if (nValorCorr == 0) .Or. nGarAlv != '0'
			If Empty(cFormaCor) .Or. nVlrCorrAnt == nValorCorr
				nValorCorr	:= nVlrFimAnt
				nValorFim	:= nVlrFimAnt
			Elseif nVlrCorrAnt > 0
				nValorCorr := (nVlrCorrAnt - nValorAlv)
				nValorFim  := (nVlrCorrAnt - nValorAlv)
			Else
				nValorCorr := (aGarantia[nI][5] - nValorAlv)
				nValorFim  := (aGarantia[nI][5] - nValorAlv)
			Endif
		Endif

		nJuros := nValorCorr - nValorFim
		nIdSaldo := nIdSaldo + 1
		aAdd(aDados,{nIdSaldo,cDtBaseFim,cDtCorte,'J',nJuros,0,aGarantia[nI][2],aGarantia[nI][2],aGarantia[nI][7],0})
		nIdSaldo := nIdSaldo + 1
		aAdd(aDados,{nIdSaldo,cDtCorte,'','SF', IIF(nValorCorr > 0, nValorCorr, 0) ,0,aGarantia[nI][2],aGarantia[nI][2],aGarantia[nI][7],0})
		nIdSaldo := nIdSaldo + 1
		aAdd(aDados,{nIdSaldo,cDtCorte,'','SFSA', IIF(nValorFim > 0, nValorFim, 0 ),0,,aGarantia[nI][2],aGarantia[nI][7],0})
		nIdSaldo := nIdSaldo + 1
		aAdd(aDados,{nIdSaldo,cDtBaseFim,'','SCA',nSalAtuCor,0,,aGarantia[nI][2],aGarantia[nI][7],0})
		nIdSaldo := nIdSaldo + 1
		aAdd(aDados,{nIdSaldo,cDtBaseFim,'','SJA',nSalAtuJur,0,,aGarantia[nI][2],aGarantia[nI][7],0})
		nIdSaldo := nIdSaldo + 1

		nValorSF   += nValorCorr
		nValorSFSA += nValorFim
		cCodigo    := aGarantia[nI][2]

		If cTpolo != (IIF((nI+1 > Len(aGarantia)),'9',aGarantia[nI+1][7]))
			aTmpVal := J98Vvalor(nValorSFSA, nValorSF)
			aAdd(aDados,{nIdSaldo,cDtCorte,'','TT'  ,aTmpVal[1],0,,cCodigo,aGarantia[nI][7],0})
			nIdSaldo := nIdSaldo + 1
			aAdd(aDados,{nIdSaldo,cDtCorte,'','TTSA',aTmpVal[2],0,,cCodigo,aGarantia[nI][7],0})
			nIdSaldo := nIdSaldo + 1
			cTpolo := IIF(nI+1 > Len(aGarantia),'9',aGarantia[nI+1][7])
			nValorSF   := 0
			nValorSFSA := 0
		Endif

	Next

	RestArea( aArea )

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098CriaS
Retorna o array de garantias/alvaras do processo conforme parâmetro de
vínculo

@param cAssJur		Código do assunto
@param cFilOri		Código da Filial de Origem
@param aMsgErr		Array de erros para devolver a Jura002

@Return aReg    	Array de valores

@author Juliana Iwayama Velho
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098CriaS(cAssJur, cFilOri, aMsgErr )
Local aReg := {}
Default cFilOri := xFilial('NT2')
Default aMsgErr := {}

	aReg := JA098CVinc(cAssJur , cFilOri, @aMsgErr )

Return aReg

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098LEV
Levantamento Automatico

@author Ernani Forastieri
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098LEV( nTipo, cCajuri, cFilBrw )
	Local lIntVal := SuperGetMV('MV_JINTVAL',, '2') == '1'
	Local cTipo   := GetMV( 'MV_JTPLEAU',, '' )
	Local cAssJur := NT2->NT2_CAJURI
	Local aArea   := GetArea()

	Default cCajuri := ""
	Default cFilBrw :=Xfilial("NT2")
	if !lIntVal //Caso o parametro esteja ativado, ao tentar fazer o levantamento automatico o sistema abre a tela para o levantamento
		If Empty( cTipo )
			JurMsgErro( STR0038 ) // "Informe um tipo válido no parametro MV_JTPLEAU."
			Return NIL
		Else
			If Empty(JurGetDados("NQW",1,xFilial("NQW")+cTipo,"NQW_DESC"))
				JurMsgErro( STR0038 ) //"Informe um tipo válido no parametro MV_JTPLEAU."
				Return NIL
			EndIf
		EndIf
	Endif
	If !Empty(cCajuri)
		cAssJur := cCajuri
	EndIF

	If !MayIUseCode( 'NT2' + cFilBrw + cAssJur )
		JurMsgErro( STR0014 + cAssJur ) // 'Ja esta sendo feito o levantamento em outra estacao para o assunto '
		Return NIL
	EndIf

	If ApMsgYesNo( STR0015, STR0019 ) // 'Será realizado o levantamento integral das garantias que não foram objeto de levantamento parcial. Indique as garantias a serem levantadas. Deseja continuar?' / 'LEVANTAMENTO AUTOMATICO'
		JA098LEVAux( cAssJur )
	EndIf

	FreeUsedCode()

	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098LEVAUX
Rotina auxiliar de levantamento Automatico

@author Ernani Forastieri
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098LEVAUX( cAssJur )
	Local aArea       := GetArea()
	Local cQuery      := ''
	Local cWhere      := ''
	Local cTmp        := ''
	Local nCt         := 0

	cQuery := "SELECT COUNT(*) QTD FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cWhere := " WHERE NOT EXISTS "
	cWhere += "	 ( SELECT NT2B.R_E_C_N_O_ FROM " + RetSqlName( 'NT2' ) + " NT2B "
	cWhere += "	    WHERE NT2B.NT2_FILIAL = NT2.NT2_FILIAL "
	cWhere += "	      AND NT2B.NT2_CGARAN = NT2.NT2_COD "
	cWhere += "	      AND NT2B.NT2_CAJURI = NT2.NT2_CAJURI "
	cWhere += "	      AND NT2B.NT2_MOVFIN = '2' "
	cWhere += "	      AND NT2B.D_E_L_E_T_ = ' ' ) "
	cWhere += "   AND NT2.NT2_FILIAL = '" + NT2->NT2_FILIAL + "' "
	cWhere += "   AND NT2.NT2_CAJURI = '" + cAssJur + "' "
	cWhere += "   AND NT2.NT2_MOVFIN = '1' "
	cWhere += "   AND NT2.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery + cWhere )

	cTmp   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	nCt := (cTmp)->QTD

	(cTmp)->( dbCloseArea() )

	If nCt == 0
		JurMsgErro( STR0022 ) //"Não há garantias a serem levantadas para este assunto juridico."
		Return NIL
	Else
		JCall153(cAssJur,3)
	EndIf

	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098RelG
Rotina que realiza a impressão do extrato de garantias
@author Clóvis Eduardo Teixeira
@since 08/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098RelG(cCajuri, cFilOri, lAutomato, cNomeRel, cCaminho)
Local lRet     := .T.
Local nI       := 0
Local nJ       := 9999
Local cParams  := ""
Local aSaldo   := {}
Local lRel     := .T.

Default cCajuri := NT2->NT2_CAJURI
Default cFilOri := NT2->NT2_FILIAL
Default lAutomato := .F.

	If !lAutomato .And. !IsInCallStack('GET_EXTRATOGAR')
		lRel := ApMsgYesNo(STR0049)
	EndIf
	If lRel

		ChkFile("NWB")

		//<- Código do Process + Filial da Garantia (NT2) ->
		cParams := cCajuri

		aSaldo := JA098CriaS(cCajuri , cFilOri)

		if Len(aSaldo) > 0

			/* Limpa o conteudo da NWB */
			DbSelectArea("NWB")
			NWB->(DbGoTop())
			Do While NWB->(!Eof())
				RecLock("NWB",.F.)
				NWB->( DbDelete() )
				NWB->( MsUnlock() )

				NWB->(DbSkip())
			End

			For nI := 1 to Len(aSaldo)

				If aSaldo[nI][4] == 'SCA' .OR. aSaldo[nI][4] == 'SJA'
					lRet := .F.
				EndIf
				
				If lRet
					RecLock('NWB', .T.)
					NWB->NWB_FILIAL := cFilOri
					NWB->NWB_CAJURI := cCajuri

					If !Empty(aSaldo[nI][1])
						NWB->NWB_ORDEM  := IIF(aSaldo[nI][9]=' ','4',aSaldo[nI][9])+Transf(nJ-nI,"9999")
					EndIf

					If !Empty(aSaldo[nI][2])
						NWB->NWB_DTINIC := sToD(aSaldo[nI][2])
					EndIf

					If !Empty(aSaldo[nI][3])
						NWB->NWB_DTFIM := sToD(aSaldo[nI][3])
					EndIf

					If !Empty(aSaldo[nI][4])
						NWB->NWB_TIPO   := aSaldo[nI][4]
						NWB->NWB_COD    := aSaldo[nI][8] // aSaldo[nI][8] = Código da garantia(NT2_COD)
					EndIf

					If !Empty(aSaldo[nI][5])
						NWB->NWB_VALOR  := (aSaldo[nI][5])
					EndIf

					If !Empty(aSaldo[nI][6])
						NWB->NWB_VALORA := (aSaldo[nI][6])
					EndIf

					NWB->( MsUnlock() )
				EndIf

				lRet := .T.

			Next nI

			NWB->(DbGoTop())

			If Existblock( 'JURR098' )
				U_JURR098(cCajuri, cFilOri, lAutomato, cNomeRel, cCaminho)
			Else
				JURR098(cCajuri, cFilOri, lAutomato, cNomeRel, cCaminho)
			EndIf
		Else
			JurMsgErro(STR0045) //O relatório só pode ser gerado se houver garantia cadastrada para este processo!
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098FrCor()
Valida se há Forma de Correção selecionada no Processo ou na Garatia

@param cAssJur		Código do assunto

@Return lRet   Sendo igual .T. existe Forma de Correção selecionado

@author Tiago Martins
@since 29/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098FrCor(cAssJur, cCodGar)
	Local lRet 	:= .F.
	Local aArea	:= GetArea()
	Local cTmp  := GetNextAlias()

	Default cCodGar := ""

	cQuery := "SELECT NT2.NT2_CAJURI,NT2.NT2_CCOMON"
	cQuery += "  FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cQuery += " WHERE NT2.NT2_CAJURI = '"+cAssJur+"'"
	cQuery += "   AND NT2.D_E_L_E_T_ = ' '"

	If !Empty(cCodGar)
		cQuery += " AND NT2.NT2_COD = '" + cCodGar + "'"
	EndIf

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	While !(cTmp)->( EOF() )
		If !Empty((cTmp)->NT2_CCOMON)
			lRet := .T.
			Exit
		EndIF
		(cTmp)->( dbSkip() )
	End
	(cTmp)->(dbCloseArea())

	If !lRet .And. Empty(cCodGar) .And. !Empty( JurGetDados('NSZ', 1 , xFilial('NSZ') + cAssJur , 'NSZ_CFCORR') )
		lRet := .T.
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J98AtSalJz
Verifica o valor do campo de saldo e atualiza o mesmo na tela de processos.
Campo utilizado na exportação personalizada e relatórios, uma vez que na tela
de Garantias este saldo é campo virtual
Uso na correção de valores

@param aCodigos		Array de códigos de assunto jurídico
@param aMsgErr		Array de Erros para devolver a Jura002

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 17/01/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98AtSalJz(aCodigos, aMsgErr, oMonitor)
Local aArea      := GetArea()
Local aSaldo     := {}
Local nRet       := 0
Local nI         := 0
Local nJ         := 0
Local aValores   := {}
Local dData      := ctod('')
Local nLenCodigo := Len(aCodigos)
Local lPrintEvol := GetSrvProfString("Trace","") == '1' // Define se terá conout da evolução da correção

Default aMsgErr  := {}
Default oMonitor := Nil

	If !Empty ( aCodigos )

		If valType(oMonitor) == "J"
			oMonitor['O17_DESC'] := STR0094 //"Atualizando Saldo em Juízo das garantias"
			oMonitor['O17_MIN'] := 0
			oMonitor['O17_MAX'] := nLenCodigo
		EndIf

		For nJ := 1 to nLenCodigo

			nRet   := 0
			aSaldo := {}
			aValores := {}
			dData  := ctod('')

			aSaldo := JA098CriaS(aCodigos[nJ][1], , @aMsgErr)

			If JA098FrCor(aCodigos[nJ][1])
				For nI:= 1 to Len(aSaldo)
					If aSaldo[nI][4] == 'SF'
						nRet := nRet + aSaldo[nI][5]
					EndIf
				Next
			Else
				For nI:= 1 to Len(aSaldo)
					If aSaldo[nI][4] == 'SFSA'
						nRet := nRet + aSaldo[nI][5]
					EndIf
				Next
			EndIf

			If valType(oMonitor) == "J"
				oMonitor['O17_MIN']  := oMonitor['O17_MIN']+1
				oMonitor['O17_PERC'] := Round(oMonitor['O17_MIN']*100/oMonitor['O17_MAX'],0)
				J288GestRel(oMonitor)

				//Quando Finalizar, reseta o progresso
				If oMonitor['O17_MIN'] = nLenCodigo
					oMonitor['O17_MIN'] := 0
					oMonitor['O17_MAX'] := 0
				EndIf
			EndIf

			If lPrintEvol
				Conout( "------------------------------------------")
				Conout( time() + " JURA098 - CORRECAO DO SALDO JUIZO")
				ConOut( "Garantias Processo: " + aCodigos[nJ][1] 	)
				Conout( "------------------------------------------")
			EndIf

			If NSZ->(dbSeek(xFilial('NSZ') + aCodigos[nJ][1]))
				RecLock('NSZ', .F.)
				NSZ->NSZ_SJUIZA := nRet
				dData           := sTod(AllTrim(J098DTUAJ(aCodigos[nJ][1])))
				NSZ->NSZ_DTUASJ := dData
				NSZ->(MsUnlock())
				aAdd(aValores,{nRet, dData})
			EndIf
		Next
	EndIf

	RestArea(aArea)

Return aValores

//-------------------------------------------------------------------
/*/{Protheus.doc} J098DTUAJ
Campo para calculo do data da ultima atualização do saldo em pedido
Uso Geral
@Param cCajuri - Código do processo
@Return  cData - Data da ultima atualização
@author Clóvis Eduardo Teixeira
@since 20/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J098DTUAJ(cCajuri)
	Local cData		:= ''
	Local aArea		:= GetArea()
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ""

	cQuery += "SELECT MAX(NT2_DTULAT) DATA_ULTATU"+ CRLF
	cQuery += "  FROM "+RetSqlName("NT2")+" NT2 "+ CRLF
	cQuery += " WHERE NT2_FILIAL     = '"+xFilial("NT2")+"'"+ CRLF
	cQuery += "   AND NT2.D_E_L_E_T_ = ' ' AND NT2_CAJURI =  '"+cCajuri+"'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If !(cAlias)->( EOF() )

		cData := (cAlias)->DATA_ULTATU

	Endif

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return cData

//-------------------------------------------------------------------
/*/{Protheus.doc} J098VLFORN
Valida preenchimento do campo de fornecedor para preenchimento
dos campos de banco, agencia e conta

Uso Geral

@author Jorge Luis Branco Martins Junior
@since 02/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098VLFORN()
	Local aAreaSA2 := SA2->( GetArea() )
	Local lRet      := .F.
	Local cCodForn  := M->NT2_CFORNT
	Local cLojaForn := M->NT2_LFORNT

	If (!Empty(cCodForn) .And. !Empty(cLojaForn))
		SA2->( DbSetOrder(1) )
		If SA2->( dbSeek( xFilial("SA2") + cCodForn + AllTrim(cLojaForn) ) )
			//Valida se o banco vinculado com o fornecedor está desbloqueado, para poder gatilhar
			If JurGetDados('SA6', 1, xFilial('SA6') + SA2->A2_BANCO + SA2->A2_AGENCIA + SA2->A2_NUMCON, "A6_BLOCKED") == "2"
				lRet := .T.
			EndIf
		EndIf
	EndIf

RestArea( aAreaSA2 )
Return lRet
//------------------------------------------------------------------
/*/{Protheus.doc} JA098VldLev
Valida se a garantia está relacionada com algum lavantamento

@param cAssJur		Código do assunto

@Return lOk   	Validacao

@author André Spirigoni Pinto
@since 12/06/13
@version 1.0
/*/

Static Function JA098VldLev(cAssJur,cGaran )
	Local aArea       := GetArea()
	Local cQuery      := ''
	Local cWhere      := ''
	Local cTmp        := ''
	Local lOk         := .F.

	cQuery := "SELECT COUNT(*) QTD FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cWhere := " WHERE EXISTS "
	cWhere += "	 ( SELECT NT2B.R_E_C_N_O_ FROM " + RetSqlName( 'NT2' ) + " NT2B "
	cWhere += "	    WHERE NT2B.NT2_FILIAL = '" + xFilial("NT2") + "' "
	cWhere += "	      AND NT2B.NT2_CGARAN = NT2.NT2_COD "
	cWhere += "	      AND NT2B.NT2_CAJURI = NT2.NT2_CAJURI "
	cWhere += "	      AND NT2B.NT2_MOVFIN = '2' "
	cWhere += "	      AND NT2B.D_E_L_E_T_ = ' ' ) "
	cWhere += "   AND NT2.NT2_FILIAL = '" + xFilial("NT2") + "' "
	cWhere += "   AND NT2.NT2_CAJURI = '" + cAssJur + "' "
	cWhere += "   AND NT2.NT2_COD = '" + cGaran + "' "
	cWhere += "   AND NT2.NT2_MOVFIN = '1' "
	cWhere += "   AND NT2.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery + cWhere )

	cTmp   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	nCt := (cTmp)->QTD

	(cTmp)->( dbCloseArea() )

	If nCt == 0
		lOk := .T.
	Else
		JurMsgErro( STR0055 ) //"Existem levantamentos vinculados a esta garantia. Ela não pode ser excluída"
		lOk := .F.
	EndIf

	RestArea( aArea )

Return lOk

/*{Protheus.doc}  JCall153(cAssJur,nOperacao)
Função chamar a rotina JURA153 sem carregar as configurações de botão do XNU.
@param nOperacao - Operação que será executada no fonte 153. 3 - Inclusao, 5 - Exclusão

@author André Spirigoni Pinto
@since 18/07/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function JCall153(cAssJur, nOperacao, cFilBrw)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA153 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA153' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA153

	JURA153(cAssJur, nOperacao, cFilBrw)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*{Protheus.doc}  J98SELLEI( cAssJur, cCodGar)
Função que cria um levantamento automático para uma garantia.
Esta função é chamada a partir do fonte JURA153.

@author André Spirigoni Pinto
@since 18/07/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function J98SELLEI( cAssJur, cCodGar, aDadosFin)
	Local aArea        := GetArea()
	Local cTmp         := GetNextAlias()
	Local nI           := 0
	Local nJ           := 0
	Local nCt          := 0
	Local lErro        := .F.
	Local lRet         := .T.
	Local lCond		   := .F.
	Local aCamposView  := {}
	Local lCampo       := .T.
	Local cMsg         := ''
	Local lIntVal      := SuperGetMV('MV_JINTVAL',, '2') == '1'
	Local cTipo        := GetMV( 'MV_JTPLEAU',, '' )
	Local oModel, oMaster
	Local xAux, xValue
	Local aSaveLines   := nil
	Local nVlrGar      := 0
	Local nVlrAtu      := 0
	Local nAjuCorre    := 0
	Local nAux         := 0
	Local dData        := Date()
	Local dDtEncPro    := JurGetDados("NSZ", 1, xFilial("NSZ") + cAssJur, "NSZ_DTENCE")

	aSaveLines := FWSaveRows()
	
	JURCORVLRS('NT2', cAssJur, , , .T.)

	BeginSql Alias cTmp
		SELECT *
		FROM %Table:NT2% NT2
		WHERE NT2.NT2_CAJURI  = %Exp:cAssJur%
		AND NT2.NT2_FILIAL  = %xFilial:NT2%
		AND NT2.NT2_COD = %Exp:cCodGar%
		AND NT2.%notDEL%
	EndSql
	dbSelectArea(cTmp)

	aStruct := NT2->( dbStruct() )

	For nI := 1 To Len( aStruct )
		If aStruct[nI][2] <> 'C'
			TCSetField( cTmp, aStruct[nI][1], aStruct[nI][2], aStruct[nI][3], aStruct[nI][4] )
		EndIf
	Next

	aStruct := (cTmp)->( dbStruct() )

	nJ := 1

	While !(cTmp)->( EOF() )

		If dDtEncPro < dData .and. !Empty(dDtEncPro)
			dData := dDtEncPro
		EndIf

		lCtrl := .T.

		If lCtrl

			oView := FWLoadView( 'JURA098' ) // Pego os campos da view por causa da ordem de preenchimento
			xAux  := oView:GetViewStruct( 'NT2MASTER' )
			aCamposView := xAux:GetFields()

			oModel := FWLoadModel( 'JURA098' )
			oModel:SetOperation( 3 )
			oModel:Activate()

			oMaster := oModel:GetModel( 'NT2MASTER' )

			aSort( aCamposView,,, { | aX, aY | aX[MVC_VIEW_FOLDER_NUMBER] + aX[MVC_VIEW_GROUP_NUMBER] + aX[MVC_VIEW_ORDEM] <= aY[MVC_VIEW_FOLDER_NUMBER] + aY[MVC_VIEW_GROUP_NUMBER] + aY[MVC_VIEW_ORDEM] } )

			nVlrGar   := (cTmp)->NT2_VALOR
			nVlrAtu   := ((cTmp)->NT2_VLRATU - (cTmp)->NT2_VALOR)
			nAjuCorre := (cTmp)->NT2_VCPROV + (cTmp)->NT2_VJPROV

			nAux := (nVlrGar + nVlrAtu) - nAjuCorre

			If (nAux == 0 .and. nAjuCorre > 0)
				nVlrGar := 0.00000001
			Else
				If nAjuCorre > 0
					nVlrGar := nAux
				EndIf
			EndIf

			For nI := 1 To Len( aCamposView )

				lCampo := .T.
				If     aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CTPGAR"
					If lIntVal
						xValue := aDadosFin[1][1]
					Else
						xValue := cTipo
					Endif
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_MOVFIN"
					xValue := '2'
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_DATA"
					xValue := dData
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_COD"
					lCampo := .F.
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CGARAN"
					xValue := (cTmp)->NT2_COD
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_DESC"
					xValue := STR0019        //"Levantamento Automatico"
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_VALOR"
					xValue := nVlrGar
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_VCPROV"
					xValue := (cTmp)->NT2_VCPROV
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_VJPROV"
					xValue := (cTmp)->NT2_VJPROV
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_FILDES"
					xValue := (cTmp)->NT2_FILDES
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CAJURI"
					xValue := cAssJur
				ElseIf aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CCOMON"
					xValue := ''
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_PREFIX"
					xValue := 'LEV'
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CNATUT"
					xValue := aDadosFin[1][2]           //SuperGetMV('MV_JCNATUT',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CTIPOT"
					xValue := aDadosFin[1][3]           //SuperGetMV('MV_JCTIPOT',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CFORNT"
					xValue := aDadosFin[1][4]           //SuperGetMV('MV_JCFORNT',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_LFORNT"
					xValue := aDadosFin[1][5]           //SuperGetMV('MV_JLFORNT',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CGRUAP"
					xValue := aDadosFin[1][6]           //SuperGetMV('MV_JAPROVE',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CBANCO"
					xValue := aDadosFin[1][7]           //SuperGetMV('MV_JCBANCO',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CAGENC"
					xValue := aDadosFin[1][8]           //SuperGetMV('MV_JCAGENC',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_CCONTA"
					xValue := aDadosFin[1][9]           //SuperGetMV('MV_JCCONTA',, '')
				ElseIf lIntVal .And. aCamposView[nI][MVC_VIEW_IDFIELD ] == "NT2_INTFIN"
					xValue := '1'
				Else
					If aScan( aStruct, { | aX | aX[1] == aCamposView[nI][MVC_VIEW_IDFIELD] } ) > 0
						xValue := (cTmp)->( &( aCamposView[nI][MVC_VIEW_IDFIELD ] ) )
					Else
						lCampo := .F.
					EndIf
				EndIf

				If lCtrl .And. lCampo .And. oMaster:CanSetValue( aCamposView[nI][MVC_VIEW_IDFIELD] )
					If aCamposView[nI][MVC_VIEW_IDFIELD ] $ "NT2_CGARAN || NT2_VALOR"
						lCond := oMaster:LoadValue( aCamposView[nI][MVC_VIEW_IDFIELD], xValue )
					Else
						lCond := oMaster:SetValue( aCamposView[nI][MVC_VIEW_IDFIELD], xValue )
					EndIf

					If !lCond
						lErro := .T.
						lCtrl := .F.
						aErro := oModel:GetErrorMessage()

						cMsg  := ""
						cMsg  += STR0024 + '[' + AllToChar( aErro[1] ) + ']' + CRLF //"Id do formulário de origem: "
						cMsg  += STR0025 + '[' + AllToChar( aErro[2] ) + ']' + CRLF //"Id do campo de origem: "
						cMsg  += STR0026 + '[' + AllToChar( aErro[3] ) + ']' + CRLF //"Id do formulário de erro: "
						cMsg  += STR0027 + '[' + AllToChar( aErro[4] ) + ']' + CRLF //"Id do campo de erro: "
						cMsg  += STR0028 + '[' + AllToChar( aErro[5] ) + ']' + CRLF //"Id do erro: "
						cMsg  += STR0029 + '[' + AllToChar( aErro[6] ) + ']' + CRLF //"Mensagem do erro: "
						cMsg  += STR0030 + '[' + AllToChar( aErro[7] ) + ']' + CRLF //"Mensagem da solução: "
						cMsg  += STR0031 + '[' + AllToChar( aErro[8] ) + ']' + CRLF //"Valor atribuido: "
						cMsg  += STR0032 + '[' + AllToChar( aErro[9] ) + ']' + CRLF //"Valor anterior: "

						JurMsgErro( STR0033 + aCamposView[nI][MVC_VIEW_IDFIELD] + CRLF + cMsg ) //"Erro na Geracao Campo: "
						Exit
					EndIf
				EndIf
			Next

			If !lErro .And. lCtrl
				J098SetVal()
				If oModel:VldData()
					nCt++
					oModel:CommitData()				
				Else
					lErro := .T.
					lCtrl := .F.

					aErro := oModel:GetErrorMessage()

					cMsg  := ""
					cMsg  += STR0024 + '[' + AllToChar( aErro[1] ) + ']' + CRLF //"Id do formulário de origem: "
					cMsg  += STR0025 + '[' + AllToChar( aErro[2] ) + ']' + CRLF //"Id do campo de origem: "
					cMsg  += STR0026 + '[' + AllToChar( aErro[3] ) + ']' + CRLF //"Id do formulário de erro: "
					cMsg  += STR0027 + '[' + AllToChar( aErro[4] ) + ']' + CRLF //"Id do campo de erro: "
					cMsg  += STR0028 + '[' + AllToChar( aErro[5] ) + ']' + CRLF //"Id do erro: "
					cMsg  += STR0029 + '[' + AllToChar( aErro[6] ) + ']' + CRLF //"Mensagem do erro: "
					cMsg  += STR0030 + '[' + AllToChar( aErro[7] ) + ']' + CRLF //"Mensagem da solução: "
					cMsg  += STR0031 + '[' + AllToChar( aErro[8] ) + ']' + CRLF //"Valor atribuido: "
					cMsg  += STR0032 + '[' + AllToChar( aErro[9] ) + ']' + CRLF //"Valor anterior: "

					JurMsgErro( STR0034 + CRLF + cMsg ) //"Erro na Geracao Validacao: "
					Exit
				EndIf

				oModel:DeActivate()
			EndIf

		EndIf
		lContinua:=.T.
		nJ++

		(cTmp)->( dbSkip() )
	End

	(cTmp)->( dbCloseArea() )

	If lErro .And. !lCtrl
		lRet := .F.
	Else
		lRet := .T.
	EndIf

	RestArea( aArea )

	FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J098EXLEV
Rotina auxiliar para excluir levantamentos

@author Ernani Forastieri
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098EXLEV( cAssJur, cFilBrw )
	Local aArea       := GetArea()
	Local cQuery      := ''
	Local cWhere      := ''
	Local cTmp        := ''
	Local nCt         := 0

	Default cFilBrw := NT2->NT2_FILIAL

	cQuery := "SELECT COUNT(*) QTD FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cWhere := " WHERE EXISTS "
	cWhere += "	 ( SELECT NT2B.R_E_C_N_O_ FROM " + RetSqlName( 'NT2' ) + " NT2B "
	cWhere += "	    WHERE NT2B.NT2_FILIAL = NT2.NT2_FILIAL "
	cWhere += "	      AND NT2B.NT2_COD = NT2.NT2_CGARAN "
	cWhere += "	      AND NT2B.NT2_CAJURI = NT2.NT2_CAJURI "
	cWhere += "	      AND NT2B.NT2_MOVFIN = '1' "
	cWhere += "	      AND NT2B.D_E_L_E_T_ = ' ' ) "
	cWhere += "   AND NT2.NT2_FILIAL = '" + cFilBrw + "' "
	cWhere += "   AND NT2.NT2_CAJURI = '" + cAssJur + "' "
	cWhere += "   AND NT2.NT2_MOVFIN = '2' "
	cWhere += "   AND NT2.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery + cWhere )

	cTmp   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .F. )

	nCt := (cTmp)->QTD

	(cTmp)->( dbCloseArea() )

	If nCt == 0
		JurMsgErro( STR0058 ) //"Não há levantamentos a serem excluídos para este assunto juridico."
		Return NIL
	Else
		If ApMsgYesNo( STR0060)
			JCall153(cAssJur, 5, cFilBrw)
		Endif
	EndIf

	FreeUsedCode()

	RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc}  J98DELEV( cAssJur, cCodGar)
Função que cria um levantamento automático para uma garantia.
Esta função é chamada a partir do fonte JURA153.

@author André Spirigoni Pinto
@since 18/07/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function J98DELEV( cAssJur, cCodGar)
	Local aArea       := GetArea()
	Local nCt         := 0
	Local lErro       := .F.
	Local lRet        := .T.
	Local cMsg        := ''
	Local oModel      := FWLoadModel( 'JURA098' )
	Local oNT2        := oModel:GetModel( 'NT2MASTER' )
	Local oStruNT2    := oNT2:GetStruct()

	oStruNT2:SetProperty( 'NT2_SGARA' ,MODEL_FIELD_INIT, NIL )
	oStruNT2:SetProperty( 'NT2_SAL'   ,MODEL_FIELD_INIT, NIL )
	oStruNT2:SetProperty( 'NT2_SALLIQ',MODEL_FIELD_INIT, NIL )
	oStruNT2:SetProperty( 'NT2_SJUIZ' ,MODEL_FIELD_INIT, 0 )
	oStruNT2:SetProperty( 'NT2_SJUIZA',MODEL_FIELD_INIT, 0 )
	oStruNT2:SetProperty( 'NT2_MULATU',MODEL_FIELD_INIT, NIL )
	oStruNT2:SetProperty( 'NT2_VLRATU',MODEL_FIELD_INIT, NIL )
	oStruNT2:SetProperty( 'NT2_JUROS',MODEL_FIELD_INIT, NIL )

	NT2->( dbSetOrder( 1 ) )

	If NT2->( dbSeek( xFilial( 'NT2' ) + cAssJur + cCodGar ) )

		oModel:SetOperation( 5 )
		oModel:Activate()

		If oModel:VldData()
			nCt++
			oModel:CommitData()
		Else
			lErro := .T.
			lCtrl := .F.

			aErro := oModel:GetErrorMessage()

			cMsg  := ""
			cMsg  += STR0024 + '[' + AllToChar( aErro[1] ) + ']' + CRLF //"Id do formulário de origem: "
			cMsg  += STR0025 + '[' + AllToChar( aErro[2] ) + ']' + CRLF //"Id do campo de origem: "
			cMsg  += STR0026 + '[' + AllToChar( aErro[3] ) + ']' + CRLF //"Id do formulário de erro: "
			cMsg  += STR0027 + '[' + AllToChar( aErro[4] ) + ']' + CRLF //"Id do campo de erro: "
			cMsg  += STR0028 + '[' + AllToChar( aErro[5] ) + ']' + CRLF //"Id do erro: "
			cMsg  += STR0029 + '[' + AllToChar( aErro[6] ) + ']' + CRLF //"Mensagem do erro: "
			cMsg  += STR0030 + '[' + AllToChar( aErro[7] ) + ']' + CRLF //"Mensagem da solução: "
			cMsg  += STR0031 + '[' + AllToChar( aErro[8] ) + ']' + CRLF //"Valor atribuido: "
			cMsg  += STR0032 + '[' + AllToChar( aErro[9] ) + ']' + CRLF //"Valor anterior: "

			JurMsgErro( STR0034 + CRLF + cMsg ) //"Erro na Geracao Validacao: "
		EndIf

		oModel:DeActivate()

	EndIf

	If lErro .And. !lCtrl
		lRet := .F.
	Else
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098SaAl
Retorna a soma do valor dos alvarás vinculados a garantia especificada

@param cAssJur		Código do assunto
@param cGaran		Código da garantia

@Return nValorAlv Soma do valor dos alvarás relacionados a uma garantia

@author André Spirigoni Pinto
@since 02/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098SaAl(cAssJur, cGaran)
	Local aArea     	:= GetArea()
	Local cAlias    	:= GetNextAlias()
	Local cQuery    	:= ''
	Local nValorAlv 	:= 0

	cQuery += "SELECT SUM(NT2_VALOR) VALOR"+ CRLF
	cQuery += "  FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cQuery += " WHERE NT2_FILIAL = '" + xFilial( 'NT2' ) + "' "
	cQuery += "   AND NT2_CAJURI = '" + cAssJur + "' AND NT2.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NT2_MOVFIN = '2' "
	cQuery += "   AND NT2_CGARAN = '" + cGaran + "' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F. )

	If !(cAlias)->( EOF() )
		nValorAlv := (cAlias)->VALOR
	EndIf

	(cAlias)->( dbCloseArea() )
	RestArea(aArea)

Return nValorAlv

//-------------------------------------------------------------------
/*/{Protheus.doc} J98Vvalor
Rotina para verificar o valor do saldo em juizo e o total de saldo
em juizo atualizado.

O valor não podera ser negativo

@param nTSJ		Total Saldo em Juizo
@param nVSJA		Total Saldo em Juizo Atualizado

@Return aReturn Array com os valores arredontados para o crystal

@author Rafael Rezende Costa
@since 07/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98Vvalor(nTSJ, nVSJA )
	Local aReturn	:= {}

	Do case
		Case (ROUND(nVSJA, 2) == 0.00 ) .And. (ROUND(nTSJ, 2) == 0.00)
		aADD(aReturn, ROUND(nVSJA, 2))
		aADD(aReturn, ROUND(nTSJ, 2))

		Case !(ROUND(nVSJA, 2) < 0.00 ) .And. !(ROUND(nTSJ, 2) < 0.00)
		aADD(aReturn, ROUND(nVSJA, 2))
		aADD(aReturn, ROUND(nTSJ, 2))

		Case LEN(aReturn) == 0

		IF ROUND(nVSJA, 2) < 0.00
			aADD(aReturn, 0.00)
		Else
			aADD(aReturn,ROUND(nVSJA, 2))
		EndIf

		If ROUND(nTSJ, 2) < 0.00
			aADD(aReturn, 0.00)
		ELSE
			aADD(aReturn,ROUND(nTSJ, 2))
		EndIf
	End Case

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} J98AltValH
Valida alterações nos campos de valor e data dos valores
atualizáveis para ajustar o histórico conforme necessário.

@param 	oModel   Modelo de dados
@param 	cTabela   Tabela que está sendo alterada

@author André Spirigoni Pinto
@since 21/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J98AltValH(oModel, cTabela)
	Local aArea     := GetArea()
	Local aAreaNZ0  := NZ0->( GetArea() )
	Local lData     := .F.
	Local lForma    := .F.
	Local lValor    := .F.
	Local lAviso    := .F.
	Local nI        := 0
	Local aCampos   := J095NW8(cTabela) //1 - campo, 2 - data, 3 - historico, 4 forma

	For nI := 1 to Len(aCampos)

		lData := .F.
		lValor := .F.

		If !lForma //Não precisa nem continuar no case caso a forma tenha sido alterada
			Do Case
				Case oModel:isFieldUpdated(aCampos[nI][4])
				lForma := .T.
				Case oModel:isFieldUpdated(aCampos[nI][1])
				lValor := .T.
				Case oModel:isFieldUpdated(aCampos[nI][2])
				lData  := .T.
			End Case
		Endif

		//caso a forma de correção tenha sido alterada o sistema deve recalcular tudo.
		If lForma
			dbSelectArea("NZ0")
			NZ0->(DBSetOrder(1))

			If NZ0->( dbSeek( xFilial('NZ0') + oModel:GetValue('NT2_COD') ) )
				While !NZ0->(EOF()) .And. NZ0->NZ0_CGARAN ==  oModel:GetValue('NT2_COD')
					Reclock( 'NZ0', .F. )
					NZ0->NZ0_VCGARA := 0
					NZ0->NZ0_VLRATU := 0
					NZ0->NZ0_MULATU := 0
					NZ0->NZ0_VJGARA := 0
					NZ0->NZ0_CCOMON := oModel:GetValue(aCampos[nI][4])
					MsUnlock()
					NZ0->( dbSkip() )
					lAviso := .T.
				End
			Endif
			//Caso a data ou valor tenham sido alterados, não é preciso fazer nenhuma pergunta ao usuário
		ElseIf lValor
			dbSelectArea("NZ0")
			NZ0->(DBSetOrder(1))

			If NZ0->( dbSeek( xFilial('NZ0') + oModel:GetValue('NT2_COD') + AnoMes(oModel:GetValue(aCampos[nI][2])) ) )
				While !NZ0->(EOF()) .And. NZ0->NZ0_CGARAN ==  oModel:GetValue('NT2_COD')
					Reclock( 'NZ0', .F. )
					NZ0->&(aCampos[nI][3]) := 0
					NZ0->NZ0_VCGARA := 0
					NZ0->NZ0_MULATU := 0
					NZ0->NZ0_VJGARA := 0
					NZ0->NZ0_VLRATU := 0

					MsUnlock()
					NZ0->( dbSkip() )
					lAviso := .T.
				End
			Endif
		EndIf

	Next

	If lAviso
		ApMsgInfo(STR0061) //"Para atualizar os valores, execute a correção de valores."
	Endif

	RestArea(aAreaNZ0)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall178
Função que chama a JURA178.

@param 	cProcesso 	Código do Assunto Jurídico \r\n

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall178(cGaran,cBrwFilial)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

	// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA178' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA178(cGaran,cBrwFilial)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J98VerSlJz

Função que verifica se for operacao de exclusão
da garantia para atualizar seus valores

@param 	cProcesso 	Código do Assunto Jurídico \r\n

@author Rafael Rezende Costa
@since 02/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98VerSlJz(oModel)
Local lRet       := .T.
Local cNT2Cajuri := ''
Local cFilNT2    := ''
Local oModelNT2  := Nil

Default oModel := FwModelActive()

	//Realiza a Gravaca do Model
	FwFormCommit( oModel )
	
	oModelNT2  := oModel:GetModel("NT2MASTER")
	cNT2Cajuri := oModelNT2:GetValue("NT2_CAJURI")
	cFilNT2    := oModelNT2:GetValue("NT2_FILIAL")
	
	If !IsInCallStack('J98SELLEI')
		JURCORVLRS('NT2')
	EndIf

	//<- Atualiza os valores do Saldo em Juizo ->
	J98AtSalJz({{ cNT2Cajuri , cFilNT2 }})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J098MOVFIN
Desabilta parte de garantia ou levantamento conforme
Movimentação (NT2_MOVFIN)

@author Jorge Luis Branco Martins Junior
@since 27/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098MOVFIN(oModel,oStruct)
Local lRet   := .T.
Local aArea  := GetArea()
Local lWSTLegal := JModRst()

	If !IsInCallStack( 'J98SELLEI' )
		oStruct:SetProperty( 'NT2_CCOMON', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '1' } )
		oStruct:SetProperty( 'NT2_DCOMON', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '1' } )
		oStruct:SetProperty( 'NT2_DTULAT', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '1' } )
		oStruct:SetProperty( 'NT2_VALOR' , MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '1' } )
		oStruct:SetProperty( 'NT2_DTJURO', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '1' } )	

		oStruct:SetProperty( 'NT2_IR'    , MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
		oStruct:SetProperty( 'NT2_TEFBAN', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
		oStruct:SetProperty( 'NT2_JUROS' , MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
		oStruct:SetProperty( 'NT2_CGARAN', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2__LEVTP) } )

		If !lWSTLegal
			oStruct:SetProperty( 'NT2__VALOR', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
			oStruct:SetProperty( 'NT2__VCPRO', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
			oStruct:SetProperty( 'NT2__VJPRO', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) } )
		EndIf

		If !lWSTLegal
			oStruct:SetProperty( 'NT2_AJUCOR', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) .And. M->NT2__LEVTP == "1"} )
			oStruct:SetProperty( 'NT2_AJUJUR', MODEL_FIELD_WHEN, { || M->NT2_MOVFIN == '2' .And.  !Empty(M->NT2_CGARAN) .And. M->NT2__LEVTP == "1"} )
		EndIf

		oStruct:SetProperty( 'NT2__VALOR', MODEL_FIELD_INIT, { || J098IniCpo('NT2__VALOR') } )
		oStruct:SetProperty( 'NT2__VCPRO', MODEL_FIELD_INIT, { || J098IniCpo('NT2__VCPRO') } )
		oStruct:SetProperty( 'NT2__VJPRO', MODEL_FIELD_INIT, { || J098IniCpo('NT2__VJPRO') } )
		oStruct:SetProperty( 'NT2__VLRG' , MODEL_FIELD_INIT, { || J098IniCpo('NT2__VLRG' ) } )
		oStruct:SetProperty( 'NT2__VCPG' , MODEL_FIELD_INIT, { || J098IniCpo('NT2__VCPG' ) } )
		oStruct:SetProperty( 'NT2__VJPG' , MODEL_FIELD_INIT, { || J098IniCpo('NT2__VJPG' ) } )
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J098INCPOM
Inclui campos no model através da função AddField

@author Jorge Luis Branco Martins Junior
@since 02/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098INCPOM(oModel,oStruct)
	Local aArea     := GetArea()
	Local nI        := 0
	Local lCampo    := .F.
	Local aCampos   := {}
	Local cCampo    := ""
	Local cCpo      := ""
	Local lWSTLegal := JModRst()

	aAdd( aCampos, { 'NT2__VLRG' ,'NT2_VALOR'  } )
	aAdd( aCampos, { 'NT2__VCPG' ,'NT2_VCPROV' } )
	aAdd( aCampos, { 'NT2__VJPG' ,'NT2_VJPROV' } )
	aAdd( aCampos, { 'NT2__VALOR','NT2_VALOR'  } )
	aAdd( aCampos, { 'NT2__VCPRO','NT2_VCPROV' } )
	aAdd( aCampos, { 'NT2__VJPRO','NT2_VJPROV' } )

	For nI := 1 To Len(aCampos)

		cCampo := 'M->'+aCampos[nI][1]

		If ALLTRIM(aCampos[nI][1]) == "NT2__VALOR"
			lCampo := .T.
		Else
			lCampo := .F.
		EndIf

		cCpo := aCampos[nI][1]

		oStruct:AddField( ;
		JURX3INFO( aCampos[nI][2], 'X3_TITULO'  )                             , ; // [01] Titulo do campo // "Importar Arquivo"
		JURX3INFO( aCampos[nI][2], 'X3_DESCRIC' )                             , ; // [02] ToolTip do campo // "Importar Arquivo"
		aCampos[nI][1]                                                        , ; // [03] Id do Field
		JURX3INFO( aCampos[nI][2], 'X3_TIPO' )                                , ; // [04] Tipo do campo
		JURX3INFO( aCampos[nI][2], 'X3_TAMANHO' )                             , ; // [05] Tamanho do campo
		JURX3INFO( aCampos[nI][2], 'X3_DECIMAL' )                             , ; // [06] Decimal do campo
		, ; // [07] Code-block de validação do campo
		, ; // [08] Code-block de validação When do campo
		, ; // [09] Lista de valores permitido do campo
		.F.                                                                   , ; // [10] Indica se o campo tem preenchimento obrigatório
		, ; // [11] Bloco de código de inicializacao do campo
		, ; // [12] Indica se trata-se de um campo chave
		, ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.                                                                     ) // [14] Indica se o campo é virtual

	Next

	oStruct:AddField( ;
	STR0072                                                                  , ; // [01] Titulo do campo // "Tipo Levant"
	STR0073                                                                  , ; // [02] ToolTip do campo // "Tipo Levantamento"
	"NT2__LEVTP"                                                             , ; // [03] Id do Field
	"C"                                                                      , ; // [04] Tipo do campo
	1                                                                        , ; // [05] Tamanho do campo
	0                                                                        , ; // [06] Decimal do campo
	{ || J098NatTpt(oModel) }                                                , ; // [07] Code-block de validação do campo
	{ || Empty(Alltrim(M->NT2__LEVTP)) .And. M->NT2_MOVFIN == '2' }          , ; // [08] Code-block de validação When do campo
	{STR0074,STR0075}                                                        , ; // [09] Lista de valores permitido do campo // "1=Total","2=Parcial"
	.F.                                                                      , ; // [10] Indica se o campo tem preenchimento obrigatório
	{ || JA098TpLev()}                                                       , ; // [11] Bloco de código de inicializacao do campo
	, ; // [12] Indica se trata-se de um campo chave
	, ; // [13] Indica se o campo não pode receber valor em uma operação de update
	.T.                                                                        ) // [14] Indica se o campo é virtual

	oStruct:AddField( ;
	"Levantamento"                                                                  , ; // [01] Titulo do campo // "Levantamento"
	"Saldo do Levantamento"                                                                  , ; // [02] ToolTip do campo // "Saldo do Levantamento"
	"NT2__LEVSD"                                                             , ; // [03] Id do Field
	"N"                                                                      , ; // [04] Tipo do campo
	12                                                                        , ; // [05] Tamanho do campo
	2                                                                        , ; // [06] Decimal do campo
	{ || /*J098NatTpt(oModel)*/ }                                                , ; // [07] Code-block de validação do campo
	{ || /*Empty(Alltrim(M->NT2__LEVTP)) .And. M->NT2_MOVFIN == '2'*/ }          , ; // [08] Code-block de validação When do campo
	{/*STR0074,STR0075*/}                                                        , ; // [09] Lista de valores permitido do campo // "1=Total","2=Parcial"
	.F.                                                                      , ; // [10] Indica se o campo tem preenchimento obrigatório
	{ || JA098SaAl(M->NT2_CAJURI, M->NT2_COD)}                                                       , ; // [11] Bloco de código de inicializacao do campo
	, ; // [12] Indica se trata-se de um campo chave
	, ; // [13] Indica se o campo não pode receber valor em uma operação de update
	.T.                                                                        ) // [14] Indica se o campo é virtual

	oStruct:AddField( ;
	"Saldo em Juízo Atualizado"                                                                  , ; // [01] Titulo do campo // "Saldo em Juízo Atualizado"
	"Saldo em Juízo Atualizado"                                                                  , ; // [02] ToolTip do campo // "Saldo em Juízo Atualizado"
	"NT2__GASJA"                                                             , ; // [03] Id do Field
	"N"                                                                      , ; // [04] Tipo do campo
	12                                                                        , ; // [05] Tamanho do campo
	2                                                                        , ; // [06] Decimal do campo
	{ || /*J098NatTpt(oModel)*/ }                                                , ; // [07] Code-block de validação do campo
	{ || /*Empty(Alltrim(M->NT2__LEVTP)) .And. M->NT2_MOVFIN == '2'*/ }          , ; // [08] Code-block de validação When do campo
	{/*STR0074,STR0075*/}                                                        , ; // [09] Lista de valores permitido do campo // "1=Total","2=Parcial"
	.F.                                                                      , ; // [10] Indica se o campo tem preenchimento obrigatório
	{ || J098GaCpos(M->NT2_CAJURI, M->NT2_COD, "NT2__GASJA" )}                                                       , ; // [11] Bloco de código de inicializacao do campo
	, ; // [12] Indica se trata-se de um campo chave
	, ; // [13] Indica se o campo não pode receber valor em uma operação de update
	.T.                                                                        ) // [14] Indica se o campo é virtual

	oStruct:AddField( ;
	"Saldo em Juízo"                                                                  , ; // [01] Titulo do campo // "Saldo em Juízo"
	"Saldo em Juízo"                                                                  , ; // [02] ToolTip do campo // "Saldo em Juízo"
	"NT2__GASJ"                                                             , ; // [03] Id do Field
	"N"                                                                      , ; // [04] Tipo do campo
	12                                                                        , ; // [05] Tamanho do campo
	2                                                                        , ; // [06] Decimal do campo
	{ || /*J098NatTpt(oModel)*/ }                                                , ; // [07] Code-block de validação do campo
	{ || /*Empty(Alltrim(M->NT2__LEVTP)) .And. M->NT2_MOVFIN == '2'*/ }          , ; // [08] Code-block de validação When do campo
	{/*STR0074,STR0075*/}                                                        , ; // [09] Lista de valores permitido do campo // "1=Total","2=Parcial"
	.F.                                                                      , ; // [10] Indica se o campo tem preenchimento obrigatório
	{ || J098GaCpos(M->NT2_CAJURI, M->NT2_COD, "NT2__GASJ" )}                                                       , ; // [11] Bloco de código de inicializacao do campo
	, ; // [12] Indica se trata-se de um campo chave
	, ; // [13] Indica se o campo não pode receber valor em uma operação de update
	.T.                                                                        ) // [14] Indica se o campo é virtual

	If lWSTLegal // Se a chamada estiver vindo do TOTVS Legal
		//Campo que indica se o registro posicionado possui anexo - criado para o TOTVS Legal
		oStruct:AddField( ;
		""                                                 , ; // [01] Titulo do campo
		""		                                           , ; // [02] ToolTip do campo
		"NT2__TEMANX"                                      , ; // [03] Id do Field
		"C"                                                , ; // [04] Tipo do campo
		2                                                  , ; // [05] Tamanho do campo
		0                                                  , ; // [06] Decimal do campo
		,                                                    ; // [07] Bloco de código de validação do campo
		,                                                    ; // [08] Bloco de código de validação when do campo
		,                                                    ; // [09] Lista de valores permitido do campo
		,                                                    ; // [10] Indica se o campo tem preenchimento obrigatório
		{|| JTemAnexo("NT2",NT2->NT2_CAJURI,NT2->NT2_COD)} , ; // [11] Bloco de código de inicialização do campo
		,                                                    ; // [12] Indica se trata-se de um campo chave
		,                                                    ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.                                                  ; // [14] Indica se o campo é virtual
		,                                                    ; // [15] Valid do usuário em formato texto e sem alteração, usado para se criar o aHeader de compatibilidade
		)
	Endif

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J098INCPOV
Inclui campos no view através da função AddField

@author Jorge Luis Branco Martins Junior
@since 02/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098INCPOV(oView,oStruct)
	Local aArea   := GetArea()
	Local nI      := 0
	Local aCampos := {}

	aAdd( aCampos, { 'NT2__VLRG' ,'NT2_VALOR' , '97', .F. } )
	aAdd( aCampos, { 'NT2__VCPG' ,'NT2_VCPROV', '98', .F. } )
	aAdd( aCampos, { 'NT2__VJPG' ,'NT2_VJPROV', '99', .F. } )
	aAdd( aCampos, { 'NT2__VALOR','NT2_VALOR' , '01', .T. } )
	aAdd( aCampos, { 'NT2__VCPRO','NT2_VCPROV', '02', .T. } )
	aAdd( aCampos, { 'NT2__VJPRO','NT2_VJPROV', '03', .T. } )

	For nI := 1 To Len(aCampos)
		oStruct:AddField( ;
		aCampos[nI][1]                            , ; // [01] Campo
		aCampos[nI][3]                            , ; // [02] Ordem
		JURX3INFO( aCampos[nI][2], 'X3_TITULO'  ) , ; // [03] Titulo
		JURX3INFO( aCampos[nI][2], 'X3_DESCRIC' ) , ; // [04] Descricao
		, ; // [05] Help
		'C'                                       , ; // [06] Tipo do campo   COMBO, Get ou CHECK
		JURX3INFO( aCampos[nI][2], 'X3_PICTURE' ) , ; // [07] Picture
		, ; // [08] PictVar
		JURX3INFO( aCampos[nI][2], 'X3_F3' )      , ; // [09] F3
		aCampos[nI][4]                            , ; // [10] When
		""                                        , ; // [11] Folder
		, ; // [12] Group
		, ; // [13] Lista Combo
		, ; // [14] Tam Max Combo
		, ; // [15] Inic. Browse
		.T.                                       )   // [16] Virtual
	Next

	oStruct:AddField( ;
	"NT2__LEVTP"          , ; // [01] Campo
	'04'                  , ; // [02] Ordem
	STR0072               , ; // [03] Titulo // "Tipo Levant"
	STR0073               , ; // [04] Descricao // "Tipo Levantamento"
	, ; // [05] Help
	'C'                   , ; // [06] Tipo do campo   COMBO, Get ou CHECK
	"@!"                  , ; // [07] Picture
	, ; // [08] PictVar
	, ; // [09] F3
	.T.                   , ; // [10] Editavel
	""                    , ; // [11] Folder
	"001"                 , ; // [12] Group
	{" ",STR0074,STR0075} , ; // [13] Lista Combo //"1=Total","2=Parcial"
	1                     , ; // [14] Tam Max Combo
	, ; // [15] Inic. Browse
	.T.                   )   // [16] Virtual

	J098CriaAg(@oStruct)

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J098CriaAg
Cria os agrupamentos nas pastas criadas na view

@author Jorge Luis Branco Martins Junior
@since 02/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J098CriaAg(oStruct)

	// Agrupamento de campos de garantia - Movimentação = Garantia
	oStruct:SetProperty( 'NT2_CCOMON' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_DCOMON' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_DTJURO' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_DTULAT' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_DTMULT' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_PERMUL' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_MULATU' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_VALOR'  , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_VCPROV' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_VJPROV' , MVC_VIEW_GROUP_NUMBER, '002' )
	oStruct:SetProperty( 'NT2_VLRATU' , MVC_VIEW_GROUP_NUMBER, '002' )

	// Agrupamento de campos de garantia - Movimentação = Levantamento
	oStruct:SetProperty( 'NT2_CGARAN' , MVC_VIEW_GROUP_NUMBER, '003' )
	oStruct:SetProperty( 'NT2__VLRG'  , MVC_VIEW_GROUP_NUMBER, '003' )
	oStruct:SetProperty( 'NT2__VCPG'  , MVC_VIEW_GROUP_NUMBER, '003' )
	oStruct:SetProperty( 'NT2__VJPG'  , MVC_VIEW_GROUP_NUMBER, '003' )

	// Agrupamento de campos de levantamento - Movimentação = Levantamento
	oStruct:SetProperty( 'NT2__VALOR' , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2__VCPRO' , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2_AJUCOR' , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2__VJPRO' , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2_AJUJUR' , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2_JUROS'  , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2_IR'     , MVC_VIEW_GROUP_NUMBER, '004' )
	oStruct:SetProperty( 'NT2_TEFBAN' , MVC_VIEW_GROUP_NUMBER, '004' )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J098VlrCpo
Preenche os valores dos campos originais com os valores dos campos criados
manualmente

@author Jorge Luis Branco Martins Junior
@since 04/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098VlrCpo(oModel)
	Local nI        := 0
	Local aCampos   := {}
	Local nOpc      := 0
	Default oModel  := FwModelActive()

	nOpc := oModel:GetOperation()

	If (nOpc == 3) .Or. (nOpc == 4)

		If oModel:GetValue("NT2MASTER","NT2_MOVFIN") == '2'

			aAdd( aCampos, { 'NT2__VALOR','NT2_VALOR'  } )
			aAdd( aCampos, { 'NT2__VCPRO','NT2_VCPROV' } )
			aAdd( aCampos, { 'NT2__VJPRO','NT2_VJPROV' } )

			For nI := 1 to Len(aCampos)
				oModel:LoadValue("NT2MASTER", aCampos[nI][2],(oModel:GetValue("NT2MASTER",aCampos[nI][1]) ) )
			Next

		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J098SetVal
Preenche os valores dos campos de valor, correção e juros da garantia
selecionada para consulta. Essa função é chamada após o preenchimento
do campo NT2_CGARAN

@author Jorge Luis Branco Martins Junior
@since 05/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098SetVal()
Local oModel   := FwModelActive()
Local dDataLev := DtoS(oModel:getValue('NT2MASTER','NT2_DATA'))
Local cGaran   := oModel:getValue('NT2MASTER','NT2_CGARAN')
Local cCajuri  := oModel:getValue('NT2MASTER','NT2_CAJURI')
Local nValor   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VALOR")
Local nCorre   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VCPROV")
Local nJuros   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VJPROV")
Local nSaldo   := 0
Local nSalCorr := 0
Local nSalJur  := 0
Local aRetorno := {}
	
	oModel:LoadValue("NT2MASTER", 'NT2__VLRG', nValor )
	oModel:LoadValue("NT2MASTER", 'NT2__VCPG', nCorre )
	oModel:LoadValue("NT2MASTER", 'NT2__VJPG', nJuros )

	If M->NT2__LEVTP == "1" .and. !Empty(cGaran) .and. !Empty(dDataLev)
		aRetorno := JSugVlrTot(cGaran, cCajuri, dDataLev, '1', .F.)
		
		If Len(aRetorno) > 0
			nSaldo   := aRetorno[1][1]
			nSalCorr := aRetorno[1][2]
			nSalJur  := aRetorno[1][3]
		EndIf

		oModel:LoadValue("NT2MASTER", 'NT2__VALOR', nSaldo   )
		oModel:LoadValue("NT2MASTER", 'NT2__VCPRO', nSalCorr )
		oModel:LoadValue("NT2MASTER", 'NT2__VJPRO', nSalJur  )
	EndIf
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J098SetSug
Preenche os valores dos campos de correção e juros do levantamento
quando é um levantamento parcial. Será feito o cálculo de proporção
do valor do levantamento com o valor da garantia, e atavés dessa
proporção serão sugeridos os valores de correção e juros. Essa função
é chamada após o preenchimento do campo NT2__VALOR

@author Jorge Luis Branco Martins Junior
@since 12/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098SetSug(oModel, lCampo)

	Local nVlrGar := 0
	Local nCorGar := 0
	Local nJurGar := 0
	Local nPro    := 0 //guarda a proporção do valor do levantamento com base no valor da garantia.
	Local nVlrLev := 0
	Local nCorLev := 0
	Local nJurLev := 0

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		nVlrGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VALOR")
		nCorGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VCPROV")
		nJurGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VJPROV")

		If M->NT2__LEVTP == "2" .And. lCampo
			nVlrLev := oModel:GetValue("NT2MASTER","NT2__VALOR") 	//Valor do levantamento
			nPro    := Round(nVlrLev / nVlrGar , 2) 				//Proporção
			nCorLev := nCorGar * nPro 								//Valor de correção proporcional
			nJurLev := nJurGar * nPro 								//Valor de juros proporcional

			If nCorLev > 0
				oModel:LoadValue("NT2MASTER", 'NT2__VCPRO', nCorLev)
			EndIf

			If nJurLev > 0
				oModel:LoadValue("NT2MASTER", 'NT2__VJPRO', nJurLev)
			EndIf
			oModel:LoadValue("NT2MASTER", "NT2_VALOR", nVlrLev)

		ElseIf M->NT2__LEVTP == "1"
			nVlrLev := oModel:GetValue("NT2MASTER", "NT2__VALOR")
			oModel:LoadValue("NT2MASTER", "NT2_VALOR" , nVlrLev)
			oModel:LoadValue("NT2MASTER", "NT2_CMOEDA", JurGetDados("NT2", 5, xFilial("NT2") + M->NT2_CGARAN + M->NT2_CAJURI, "NT2_CMOEDA"))
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J098ValLev
Valida valor do levantamento, para que caso exista mais de um
levantamento os valores totais sejam iguais ao valor da garantia.

@param cCajuri   - Código do asssunto interno
@param cGaran    - Código da Garantia
@param cTpMovLev - Tipo do Levantamento?
@param lWsTLegal - Chamada vem do Totvs Legal?

@author Jorge Luis Branco Martins Junior
@since 12/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098ValLev(cCajuri,cGaran, cTpMovLev, lWsTLegal)
Local lRet      := .T.
Local nVlrGar   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VALOR")
Local nCorGar   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VCPROV")
Local nJurGar   := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VJPROV")
Local nVal      := 0 //Guarda o valor de todos os levantamentos feitos para essa garantia.
Local nGar      := 0
Local nVlrLev   := 0
Local nCorLev   := 0
Local nJurLev   := 0
Local nAjuCor   := 0
Local nAjuJur   := 0
Local nValAtu   := 0
Local nValJur   := 0
Local nIR       := 0
Local nTefBan   := 0
Local nMsg      := 0
Local aRet      := {}
Local cQuery    := ''
Local cQry      := GetNextAlias()
Local cDtUltLev := ''
Local nQtdLev   := 0

Default cCajuri   := ''
Default cGaran    := ''
Default cTpMovLev := ''
Default lWsTLegal := .F.

	cQuery := " SELECT NT2_COD, NT2_VALOR VALOR, NT2_VCPROV CORRECAO, NT2_VJPROV JUROS, NT2_AJUCOR AJUCOR, "
	cQuery +=        " NT2_AJUJUR AJUJUR, NT2_JUROS VALJUR, NT2_IR IR, NT2_TEFBAN TEFBAN, NT2_DATA "
	cQuery +=  " FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cQuery += " WHERE NT2_CGARAN = '" + cGaran + "' "
	cQuery +=   " AND NT2_MOVFIN = '2' "
	cQuery +=   " AND NT2_CAJURI = '" + cCajuri + "' AND NT2.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NT2_COD <> '" + M->NT2_COD + "' "
	cQuery +=   " AND NT2_FILIAL = '"+FwxFilial('NT2')+"' "
	cQuery += " ORDER BY NT2_DATA"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cQry, .T., .F. )

	While !(cQry)->( EOF() )
		nVlrLev   += (cQry)->VALOR
		nCorLev   += (cQry)->CORRECAO
		nJurLev   += (cQry)->JUROS
		nAjuCor   += (cQry)->AJUCOR
		nAjuJur   += (cQry)->AJUJUR
		nValJur   += (cQry)->VALJUR
		nIR       += (cQry)->IR
		nTefBan   += (cQry)->TEFBAN
		cDtUltLev := (cQry)->NT2_DATA
		(cQry)->( dbSkip() )
	End

	(cQry)->( dbCloseArea() )

	nVal := nVlrLev + nCorLev + nJurLev + nAjuCor + nAjuJur + nValJur + nIR + nTefBan //Valores de outros levantamentos somados.
	nGar := nVlrGar + nCorGar + nJurGar                                               //Valores da garantia

	nValAtu := M->NT2__VALOR + M->NT2__VCPRO + M->NT2__VJPRO  
	nValAtu += M->NT2_AJUCOR + M->NT2_AJUJUR + M->NT2_JUROS + M->NT2_IR + M->NT2_TEFBAN

	If cTpMovLev == '1' .or. M->NT2__LEVTP == "1"
		lRet := (nGar == (nVal+nValAtu))
		If nGar < (nVal+nValAtu)
			nMsg := 1 //Valor dos levantamentos é maior que o da garantia
		ElseIf nGar > (nVal+nValAtu)
			nMsg := 2 //Valor da garantia é maior que o dos levantamentos
		EndIf
	ElseIf cTpMovLev == '2' .or. M->NT2__LEVTP == "2"
		lRet := (nGar >= (nVal+nValAtu))
		If nValAtu > nGar
			nMsg := 3 //Valor do levantamento deve ser menor que o da garantia, por se tratar de um levantamento parcial.
		Else
			nMsg := 1 //Valor dos levantamentos é maior que o da garantia
		EndIf
	EndIf

	cQry   := GetNextAlias()

	cQuery := " SELECT COUNT(NT2_CGARAN) QTDE, NT2_CGARAN "
	cQuery += "  FROM " + RetSqlName( 'NT2' ) + " NT2 "
	cQuery += " WHERE NT2_FILIAL = '" + FwxFilial('NT2') + "'"
	cQuery += "   AND NT2_CAJURI = '" + cCajuri + "' AND NT2.D_E_L_E_T_ = ' ' "
	cQuery += "   AND NT2_MOVFIN = '2' AND NT2_CGARAN ='" + cGaran + "'"
	cQuery += "   GROUP BY NT2_CGARAN "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cQry, .T., .F. )
		nQtdLev := (cQry)->QTDE
	(cQry)->( dbCloseArea() )

	aADD(aRet, lRet)
	aADD(aRet, nVlrLev)
	aADD(aRet, nCorLev)
	aADD(aRet, nJurLev)
	aADD(aRet, nAjuCor)
	aADD(aRet, nAjuJur)
	aADD(aRet, nValJur)
	aADD(aRet, nIR)
	aADD(aRet, nTefBan)
	aADD(aRet, nMsg)
	aADD(aRet, cDtUltLev)
	aADD(aRet, nQtdLev)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J098NatTpt
Preenche os campos de natureza e tipo de título com o valor dos
parâmetros quando se tratar de alvará

@author Jorge Luis Branco Martins Junior
@since 12/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098NatTpt(oModel)
	Local cCNatuT  := SuperGetMV('MV_JCNATUT',, '')
	Local cCTipoT  := SuperGetMV('MV_JCTIPOT',, '')
	Local nOpc     := 0

	Default oModel := FwModelActive()

	nOpc := oModel:GetOperation()

	If SuperGetMV('MV_JINTVAL',, '2') == '1' .And. oModel:GetValue("NT2MASTER","NT2_MOVFIN")== '2' .And. nOpc == 3
		oModel:LoadValue("NT2MASTER", 'NT2_CNATUT', cCNatuT )
		oModel:LoadValue("NT2MASTER", 'NT2_CTIPOT', cCTipoT )
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J098IniCpo
Inicializador padrão dos campos criados manualmente

@author Jorge Luis Branco Martins Junior
@since 12/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098IniCpo(cCpo)
	Local xIni := 0

	If NT2->NT2_MOVFIN == "2" .And. !INCLUI

		Do case
			Case cCpo == 'NT2__VALOR'
			xIni := NT2->NT2_VALOR
			Case cCpo == 'NT2__VCPRO'
			xIni := NT2->NT2_VCPROV
			Case cCpo == 'NT2__VJPRO'
			xIni := NT2->NT2_VJPROV
			Case cCpo == 'NT2__VLRG'
			xIni := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VALOR")
			Case cCpo == 'NT2__VCPG'
			xIni := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VCPROV")
			Case cCpo == 'NT2__VJPG'
			xIni := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VJPROV")
		End Case

	EndIf

Return xIni

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098Opc
Determinar a acao

@author Jorge Luis Branco Martins Junior
@since 17/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098Opc( nOpc )
	Local lIntVal  := SuperGetMV('MV_JINTVAL',, '2') == '1'
	Local lExiCtb  := .F.
	Local cTexto   := ""
	Local cOpera   := ""
	Local cFilNV3  := ""
	Local cFilDest := NT2->NT2_FILDES
	Local lCompNV3 := Empty( xFilial("NV3") )		//Define se tabela eh compartilhada

	cFilNV3 := IIF( !Empty(cFilDest) .And. !lCompNV3, cFilDest, xFilial('NV3') )

	If AllTrim(JurGetDados("NV3",2,cFilNV3+NT2->NT2_CAJURI+NT2->NT2_COD+"91", "NV3_LA")) == "S" //9=Levantamento - 1=Valor Original
		lExiCtb := .T.
	EndIf

	nOperacao := nOpc

	If NT2->NT2_MOVFIN == "1"
		cTexto := STR0077 //"a garantia"
	Else
		cTexto := STR0078 //"o alvará"
	EndIf

	If nOperacao == 4
		cOpera := LOWER(STR0004) //"alterar"
	Else
		cOpera := LOWER(STR0005) //"excluir"
	EndIf

	If lExiCtb
		MsgAlert(I18N( STR0086, {cOpera, cTexto})) //'Não é possível #1 #2 pois seus valores já foram contabilizados'
	ElseIf lIntVal .and. nOperacao == 4 .And. NT2->NT2_INTFIN != "2" .And. !Empty(NT2->NT2_CTIPOT)
		MsgAlert(I18N( STR0080, {cOpera, cTexto})) //'Não é possível #1 #2 pois a integração do SIGAJURI com os módulo de SIGAFIN está habilitada'
	Else
		FWExecView( STR0007, 'JURA098', nOperacao ) //"Configurações de Relatórios"
	EndIf

	nOperacao := 0

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J98F3SA2
Customiza a consulta padrão de fornecedor conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98F3SA2(cMaster, cCampo)
	Local oModel   := FWModelActive()
	Local aPesq    := {"A2_COD","A2_LOJA","A2_NOME"}
	Local cFilDest := ""  //oModel:GetValue(cMaster,cCampo)
	Local lRet     := .F.
	Local aFilUsr  := {}
	Local nResult  := 0
	Local cFiltro  := "SA2->A2_MSBLQL == '2'"

	Default cMaster := ''
	Default cCampo := ''

	If oModel <> NIL
		cFilDest := oModel:GetValue(cMaster,cCampo)
	Else
		aFilUsr := JURFILUSR( __CUSERID, "SA2" )
		If Len(aFilUsr) > 0
			cFilDest := aFilUsr[1]
		EndIf
	EndIf

	If !Empty(cFilDest)
		cFiltro += " .AND. SA2->A2_FILIAL == '"+ FwxFilial('SA2',cFilDest) + "'"
	Else
		cFiltro += " .AND. SA2->A2_FILIAL == '" + FwxFilial('SA2') + "'"
	EndIF

	SA2->( DbSetOrder( 1 ) )

	nResult := JurF3SXB("SA2", aPesq, cFiltro, .F., .F.,,)
	lRet    := nResult > 0

	If lRet
		DbSelectArea("SA2")
		SA2->(dbgoTo(nResult))
	EndIf

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J098Fornec()
	Rotina para abrir a inclusão de fornecedores
	@Obs A rotina inicializa as variasveis privates excênciais
	a abertura da rotina A020Inclui, em caso de manutenção ver o fonte
	MATA020.PRX

	@Return Nil

	@author Luciano Pereira dos Santos
	@since 23/12/2016
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function J098Fornec()
	Private aParam    := {}
	Private aRotAuto  := Nil
	Private cCadastro := OemtoAnsi("Fornecedores")  //"Fornecedores"
	Private lIntLox   := GetMV("MV_QALOGIX") == "1"

	A020Inclui('SA2',,3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J98FORVAL
Função para validar as inforamções do fornecedor

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98FORVAL(cTabela)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaSA2 := SA2->( GetArea() )
	Local oModel   := FWModelActive()
	Local cFilDest := ""
	Local cCForne  := ""
	Local cLForne  := ""
	Local lFilial  := ""
	Local cMsgErro := ""

	Default cTabela := "NT2"

	lFilial := FWModeAccess(SUBSTRING('SA2',1,3),1) == "E" .OR. FWModeAccess(SUBSTRING('SA2',1,3),2) == "E" .OR. FWModeAccess(SUBSTRING('SA2',1,3),3) == "E"

	cFilDest := FWxFilial('SA2',oModel:GetValue(cTabela+"MASTER",cTabela+"_FILDES"))
	cCForne  := oModel:GetValue(cTabela+"MASTER",cTabela+"_CFORNT")
	cLForne  := oModel:GetValue(cTabela+"MASTER",cTabela+"_LFORNT")

	SA2->( dbSetOrder( 1 ) )

	If !Empty(cFilDest)
		If lFilial

			If SA2->( dbSeek( FwxFilial('SA2',cFilDest) + cCForne + AllTrim(cLForne) ) )
				lRet := .T.
			Endif

			If JurGetDados('SA2', 1, FwxFilial('SA2',cFilDest) + cCForne + AllTrim(cLForne) , 'A2_MSBLQL') == '1'
				lRet := .F.
				cMsgErro := STR0085 // "Fornecedor Bloqueado!"
			EndIf

		Else

			If SA2->( dbSeek( PadR(SubStr(cFilDest,1, Len(AllTrim(FWxFilial('SA2')))),Len(FwXFilial('SA2'))) + cCForne + AllTrim(cLForne) ) )
				lRet := .T.
			EndIf

			If JurGetDados('SA2', 1, PadR(SubStr(cFilDest,1, Len(AllTrim(FWxFilial('SA2')))),Len(FwXFilial('SA2'))) + cCForne + AllTrim(cLForne) , 'A2_MSBLQL') == '1'
				lRet := .F.
				cMsgErro := STR0085 // "Fornecedor Bloqueado!"
			EndIf

		EndIf
	Else
		If SA2->( dbSeek( FwxFilial( 'SA2' ) + cCForne + AllTrim(cLForne)) )
			lRet := .T.
		Endif

		If JurGetDados('SA2', 1, FwxFilial( 'SA2' ) + cCForne + AllTrim(cLForne) , 'A2_MSBLQL') == '1'
			lRet := .F.
			cMsgErro := STR0085 // "Fornecedor Bloqueado!"
		EndIf

	EndIf

	If !lRet
		If Empty(cMsgErro)
			JurMsgErro(STR0064) //"Não existe registro relacionado a este código"
		Else
			JurMsgErro(STR0085) // "Fornecedor Bloqueado!"
		EndIF
	EndIf

	RestArea( aAreaSA2 )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA98SED
Monta a query de tipo de ação partir de parâmetro de filial destino
Uso no cadastro de Garantias.

@Return cFildest  Campo de filial de destino
@Return cQuery	 	Query montada

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA98SED(cFilDest)
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local cTabela  := "SED"
	Local lFilial  := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	cQuery += " SELECT ED_CODIGO, ED_DESCRIC, R_E_C_N_O_ SEDRECNO "
	cQuery += "   FROM "+RetSqlName("SED")+" SED "
	cQuery += "  WHERE SED.D_E_L_E_T_ = ' '"
	cQuery += " AND ED_MSBLQL <> '"+ '1' +"'"   //status bloqueado

	If !Empty(cFilDest)
		if lFilial
			cQuery += " AND ED_FILIAL = '"+cFilDest+"'"
		Else
			cQuery += " AND ED_FILIAL = '"+PadR(SubStr(cFilDest,1, Len(AllTrim(FWxFilial('SED')))),Len(FwXFilial('SED')))+"'"
		Endif
	Else
		cQuery += " AND ED_FILIAL = '"+FwxFilial('SED')+"'"
	EndIf

	RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J98F3SED
Customiza a consulta padrão de Natureza conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98F3SED(cMaster, cCampo)
	Local lRet   := .F.
	Local aArea  := GetArea()
	Local oModel
	Local cQuery
	Local aPesq  := {"ED_CODIGO", "ED_DESCRIC"}
	Local nResult := 0

	Default cMaster := ''
	Default cCampo 	:= ''

	If IsPesquisa()
		cQuery   := JURA98SED(xFilial('SED'))
	Else
		oModel   := FWModelActive()

		If (oModel <> NIL) .And. !Empty(cMaster) .And. !Empty(cCampo)
			cQuery   := JURA98SED(oModel:GetValue(cMaster,cCampo))
		Else
			cQuery   := JURA98SED(xFilial('SED'))//JURA98SED(oModel:GetValue(cMaster,cCampo))
		EndIf
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)
	RestArea( aArea )

	nResult := JurF3SXB("SED", aPesq, "", .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("SED")
		SED->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J98ValNat
Customiza a consulta padrão de Natureza conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98ValNat( lVazio, cFilDest, cCampo, nUso, nTipoOk )
	Local lRet    := .T.
	Local aArea   := SED->( GetArea() )
	Local cFilSED := ''
	Local cTabela := "SED"
	Local lFilial := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .OR. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .OR. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"
	Local cBloqNat:= ""

	Default cCampo   := &( ReadVar() )
	Default nTipoOk  := 0
	Default nUso	 := 0

	If lFilial .And. !Empty(cFilDest)
		cFilSED := FWxFilial("SED", cFilDest)
	Else
		cFilSED := FWxFilial("SED")
	EndIf

	If lRet .AND. !Empty( cCampo )
		DbSelectArea( "SED" )
		SED->( DbSetOrder( 1 ) )

		If !SED->( DbSeek( cFilSED + cCampo ) )
			Help(" ", 1, "NATNAOENC", , STR0065, 1, 0)	//"A natureza não foi encontrada!!"
			lRet	:= .F.
		EndIf

		//Valida Natureza financeira com status bloqueada
		cBloqNat := JurGetDados("SED", 1, xFilial("SED") + cCampo , "ED_MSBLQL")

		IF cBloqNat == "1"
			JurMsgErro( STR0089 )  //"Natureza bloqueada para uso"
			lRet := .F.
		Endif

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA98FRP
Monta a query de Grupo Aprovacao partir de parâmetro de filial destino
Uso no cadastro de Garantias.

@Return cFildest  Campo de filial de destino
@Return cQuery	 	Query montada

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA98FRP(cFilDest)
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local lFilial  := FWModeAccess("FRP",1) == "E" .And. FWModeAccess("FRP",2) == "E" .And. FWModeAccess("FRP",3) == "E"
	Local nValor   := Iif(Empty(M->NT2_VALOR),0,M->NT2_VALOR)

	cQuery := " SELECT FRP_COD, RD0_NOME, FRP.R_E_C_N_O_ FRPRECNO "
	cQuery +=   " FROM " + RetSqlName("FRP") + " FRP LEFT JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=     " ON FRP_USER = RD0_USER "
	cQuery +=  " WHERE FRP.D_E_L_E_T_ = ' '"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=    " AND FRP_LIMMIN <= " + cValToChar(nValor)
	cQuery +=    " AND FRP_LIMMAX >= " + cValToChar(nValor)
	If !Empty(cFilDest) .And. lFilial
		cQuery += " AND FRP.FRP_FILIAL = '" + FwxFilial('FRP',cFilDest) + "'"
	Else
		cQuery += " AND FRP.FRP_FILIAL = '" + FwxFilial('FRP') + "'"
	EndIf

	RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J98F3FRP
Customiza a consulta padrão de fornecedor conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98F3FRP(cMaster, cCampo)
	Local lRet   := .F.
	Local aArea  := GetArea()
	Local oModel
	Local cQuery
	Local aPesq  := {"FRP_COD", "RD0_NOME"}
	Local nResult := 0

	Default cMaster := ''
	Default cCampo 	:= ''

	If IsPesquisa()
		cQuery   := JURA98FRP(xFilial("FRP"))
	Else
		oModel   := FWModelActive()

		If (oModel <> NIL) .And. !Empty(cMaster) .And. !Empty(cCampo)
			cQuery   := JURA98FRP(oModel:GetValue(cMaster,cCampo))
		Else
			cQuery   := JURA98FRP(xFilial("FRP"))
		Endif
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)
	RestArea( aArea )

	nResult := JurF3SXB("FRP", aPesq, "", .F., .F.,,cQuery)
	lRet    := nResult > 0

	If lRet
		DbSelectArea("FRP")
		FRP->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J98SALVAL
Função para validar as inforamções do grupo aprovador do financeiro.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98SALVAL(cTabela)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaFRP := FRP->( GetArea() )
	Local oModel   := FWModelActive()
	Local cFilDest := ""
	Local cCGrupo  := ""
	Local lFilial  := ""

	Default cTabela := "NT2"

	lFilial := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	cFilDest := xFilial('FRP')
	cCGrupo  := AllTrim(oModel:GetValue(cTabela+"MASTER",cTabela+"_CGRUAP"))

	FRP->( dbSetOrder( 1 ) )

	If !Empty(cFilDest) .And. lFilial
		if FRP->( dbSeek( cFilDest + cCGrupo  ) )
			lRet := .T.
		endif
	Else
		if	FRP->( dbSeek( FwxFilial( 'FRP' ) + cCGrupo) )
			lRet := .T.
		Endif
	Endif

	If !lRet
		JurMsgErro(STR0064) //"Não existe registro relacionado a este código"
		lRet := .F.
	EndIf

	RestArea( aAreaFRP )
	RestArea( aArea )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA098TpLev
Função para verificar o tipo de levantamento

@Return lTotal	    Retorna se é ou não levantamento total.

@author Wellington Coelho
@since 11/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098TpLev()
	Local cRet    := ''
	Local nVlrGar := 0
	Local nCorGar := 0
	Local nJurGar := 0
	Local nVlrLev := NT2->NT2_VALOR
	Local nCorLev := NT2->NT2_VCPROV
	Local nJurLev := NT2->NT2_VJPROV

	If !INCLUI .And. (NT2->NT2_MOVFIN  == '2')

		nVlrGar := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VALOR")
		nCorGar := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VCPROV")
		nJurGar := JurGetDados("NT2", 5, xFilial("NT2") + NT2->NT2_CGARAN + NT2->NT2_CAJURI, "NT2_VJPROV")

		If (nVlrGar+nCorGar+nJurGar == nVlrLev+nCorLev+nJurLev) .Or. ;
		(NT2->NT2_AJUJUR <> 0 .or. NT2->NT2_AJUCOR)
			cRet := '1'
		Else
			cRet := '2'
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098NQW
Efetua filtro na consulta padrão de Tipo de Garantia

@author Clovis Eduardo Teixeira
@since 28/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098NQW()
	Local cRet   := "@#@#"
	Local aArea  := GetArea()
	Local oModel := FWModelActive()
	Local cMovim := ''

	If oModel <> NIL
		cMovim := oModel:GetValue('NT2MASTER','NT2_MOVFIN')
	Endif

	If IsInCallStack('J98SELLEI')
		cMovim := '2'
	EndIf

	If !Empty(cMovim)
		cRet := "@#NQW->NQW_TIPO == '"+cMovim+"'@#"
	Endif

	RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA098FDS
Verifica parametro para validação da data de garantia quando é um final
de semana ou feriado
Uso no cadastro de Garantias.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Marcelo Araujo Dente
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA098FDS(cCampo)
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local aArea    := GetArea()
	Local dGarantia

	//Verifica se o parâmetro bloqueia feriado
	If SuperGetMv('MV_JBLQFER',, '2') == '1'

		nDow:= DOW(oModel:GetValue('NT2MASTER',cCampo))

		If nDow == 1 .Or. nDow == 7

			JurMsgErro(STR0087 + ' ' + cCampo)
			lRet := .F.

		Else

			dGarantia := DataValida(oModel:GetValue('NT2MASTER',cCampo))

			If  M->NT2_PRAZO == '1'  .AND. dGarantia <> oModel:GetValue('NT2MASTER',cCampo)

				JurMsgErro(STR0087 + ' ' + cCampo)
				lRet := .F.

			EndIf

		EndIf

	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J098Corte
Data de corte para correção do saldo da garantia
@param cCajur	Código Assunto Jurídico
@param cFilOri	Filial Assunto Jurídico
@return cDataCorte Data de corte
@author Andreia Lima
@since 22/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J098Corte(cCajur,cFilOri)
	Local aArea      := GetArea()
	Local cAliasQry  := GetNextAlias()
	Local cDataCorte := ''

	BeginSql Alias cAliasQry
		SELECT NSZ_DTENCE
		FROM %Table:NSZ% NSZ
		WHERE NSZ_COD = %Exp:cCajur%
		AND NSZ_FILIAL = %Exp:cFilOri%
		AND NSZ_SITUAC = '2'
		AND NSZ.%notDel%
	EndSql

	dbSelectArea(cAliasQry)

	If (cAliasQry)->(EOF())
		cDataCorte := DTOS(DATE())
	Else
		cDataCorte := (cAliasQry)->NSZ_DTENCE
	Endif

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return cDataCorte

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098VlrEs
Preenche os valores de estorno dos campos de correção e juros do
levantamento.

@author Jorge Luis Branco Martins Junior
@since 09/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA098VlrEs(oModel)
	Local nVlrGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VALOR")
	Local nCorGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VCPROV")
	Local nJurGar := JurGetDados("NT2", 5, xFilial("NT2") + oModel:GetValue("NT2MASTER","NT2_CGARAN") + oModel:GetValue("NT2MASTER","NT2_CAJURI"), "NT2_VJPROV")
	Local nPro    := 0 //guarda a proporção do valor do levantamento com base no valor da garantia.
	Local nVlrLev := 0
	Local nCorLev := 0
	Local nJurLev := 0
	Local nOpc    := 0

	nOpc := oModel:GetOperation()

	If (nOpc == 3) // "NT2__VALOR"
		nVlrLev := oModel:GetValue("NT2MASTER","NT2__VALOR") //Valor do levantamento
		nPro    := ROUND( nVlrLev / nVlrGar , 2) //proporção
		nCorLev := nCorGar * nPro //Valor de correção proporcional
		nJurLev := nJurGar * nPro //Valor de juros proporcional
	EndIf

Return {nCorLev, nJurLev}

//-------------------------------------------------------------------
/*/{Protheus.doc} J098IniTot
Inicializador do campo virtual de total de levantamento

@author Jorge Martins
@since 13/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J098IniTot()
	Local nRet := 0

	If NT2->NT2_MOVFIN == "2" .And. !INCLUI
		nRet := NT2->NT2_VALOR + NT2->NT2_VCPROV + NT2->NT2_VJPROV - NT2->NT2_JUROS - NT2->NT2_IR - NT2->NT2_TEFBAN
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098GerNT3
Cria uma despesa com os valores do levantamento efetuado de acordo com a indicação no tipo de Levantamento
Uso no cadastro de Garantias.

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Marcelo Araujo Dente
@since 16/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA098GerNT3(oModel)

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oMMaster   := nil
	Local oModelNT3  := nil
	Local lCancelado := .F.
	Local nSomaValor := 0
	Begin Sequence

		oMMaster := FWLoadModel("JURA099")
		oMMaster:SetOperation( 3 )
		oMMaster:Activate()

		oModelNT3 := oMMaster:GetModel( 'NT3MASTER' )

		oModelNT3:SetValue('NT3_DATA'  , oModel:GetValue("NT2MASTER","NT2_DATA" ))  //Data
		oModelNT3:SetValue('NT3_CMOEDA'  , oModel:GetValue("NT2MASTER","NT2_CMOEDA" ))  //Moeda

		nSomaValor:= oModel:GetValue("NT2MASTER","NT2_VALOR") + oModel:GetValue("NT2MASTER","NT2_VCPROV") + oModel:GetValue("NT2MASTER","NT2_VJPROV")
		nSomaValor+= oModel:GetValue("NT2MASTER","NT2_JUROS") + oModel:GetValue("NT2MASTER","NT2_IR") + oModel:GetValue("NT2MASTER","NT2_TEFBAN")

		oModelNT3:SetValue('NT3_VALOR'  ,nSomaValor)  //Valor da soma dos componentes do levantamento
		if Empty(oModelNT3:getValue("NT3_CAJURI"))
			oModelNT3:LoadValue('NT3_CAJURI',oModel:GetValue("NT2MASTER","NT2_CAJURI" ))
		Endif

		FWExecView(STR0019,'JURA099',3,,{|| .T. },/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,{|| lCancelado := .T.}/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oMMaster)  //"Incluir"
		lRet := !( lCancelado )
		oMMaster:DeActivate()

	End Sequence

	RestArea(aArea)

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J098StVld(oModel,oStruct)
	Inclusão dos Valids nos campos da tela de garantia

	@Return lRet	 	.T./.F. As informações são válidas ou não

	@author Willian Kazahaya
	@since 30/07/2018
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function J098StVld(oModel,oStruct)
	Local lRet := .T.

	oStruct:SetProperty( 'NT2__VLRG' , MODEL_FIELD_VALID , { || J098SetSug(@oModel, .F. ) }   )
	oStruct:SetProperty( 'NT2__VALOR', MODEL_FIELD_VALID , { || J098SetSug(@oModel, .T.) }   )

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J98VlGpCom ()
	Função responsável por verificar se o tipo de garantia tem integração com compras ou financeiro.

	@Return lRet .T. / .F. - As informações são verdadeiras ou falsas

	@author SIGAJURI
	@since 30/04/19
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function J98VlGpCom()
	Local lAlcada := SuperGetMV('MV_JALCADA',, '2') == '1'
	Local lRet    := .T.
	Local lIntCom := .F.
	Local cTpGar  := ''
	Local oModel  := FwModelActive()

	dbSelectArea('NT2')
	If ColumnPos("NT2_PRODUT") > 0 .AND. ColumnPos("NT2_CONDPG") > 0 .AND. ColumnPos("NT2_GRPCOM") > 0
		cTpGar := oModel:GetValue("NT2MASTER","NT2_CTPGAR")
		If !Empty(cTpGar) .and. lAlcada
			lIntCom  := JurGetDados("NQW",1,XFILIAL("NQW") + cTpGar, "NQW_INTCOM") == '1'
		EndIf
	EndIf

	If !lIntCom
		lRet := .F.
	EndIf
	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} J98VlGtGrp (cTabela)
	Função responsável por permitir que gatilhe os CDOMIN do X7_CAMPO='NT2_CTPGAR'.

	@Param cTabela Tabela a ser utilizada, para realização condição dos gatilhos.

	@Return lRet .T. / .F. - As informações são verdadeiras ou falsas

	@author SIGAJURI
	@since 30/04/19
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function J98VlGtGrp(cTabela)
	Local lRet    := .F.
	Local cTpGar  :=''
	Local cGrupo  := SuperGetMV('MV_JAPROVE',, '')
	Local lAlcada := SuperGetMV('MV_JALCADA',, '2') == '1'
	Local lIntCom := .F.

	Default cTabela := ''
	Default oModel  := FWModelActive()

	dbSelectArea('NT2')
	If ColumnPos("NT2_PRODUT") > 0 .AND. ColumnPos("NT2_CONDPG") > 0 .AND. ColumnPos("NT2_GRPCOM") > 0
		cTpGar := oModel:GetValue("NT2MASTER","NT2_CTPGAR")
		If !Empty(cTpGar) .and. lAlcada
			lIntCom  := JurGetDados("NQW",1,XFILIAL("NQW") + cTpGar, "NQW_INTCOM") == '1'
		EndIf
	EndIf

	If !Empty(cTabela)
		Do Case
			Case !lIntCom .AND. cTabela == 'FRP' .And. !Empty(cGrupo)
			lRet := !Empty(JurGetDados("FRP", 1, XFILIAL("FRP") + cGrupo, "FRP_COD"))
			Case lIntCom .AND. cTabela == 'SAL' .And. !Empty(cGrupo)
			lRet := !Empty(JurGetDados("SAL", 1, XFILIAL("SAL") + cGrupo, "AL_COD"))
			Case lIntCom .AND. cTabela == 'NQW'
			lRet := !Empty(JurGetDados("NQW",1,XFILIAL("NQW") + cTpGar, "NQW_GRPAPR"))
		End Case
	Else
		lRet := lIntCom
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JValidGrCom
Função para validar as inforamções do grupo aprovador de compras.

@Return lRet .T./.F. As informações são válidas ou não

@author SIGAJURI
@since 30/04/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function JValidGrCom()
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaSAL := SAL->( GetArea() )
	Local oModel   := FWModelActive()
	Local cFilDest := ""
	Local cCGrupo  := ""
	Local lFilial  := ""
	Local cTabela := "NT2"

	lFilial := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	cFilDest := xFilial('SAL')
	cCGrupo  := AllTrim(oModel:GetValue(cTabela+"MASTER",cTabela+"_GRPCOM"))

	SAL->( dbSetOrder( 1 ) )

	If !Empty(cFilDest) .And. lFilial
		if SAL->( dbSeek( cFilDest + cCGrupo  ) )
			lRet := .T.
		endif
	Else
		if	SAL->( dbSeek( FwxFilial( 'SAL' ) + cCGrupo) )
			lRet := .T.
		Endif
	Endif

	If !lRet
		JurMsgErro(STR0064) //"Não existe registro relacionado a este código"
		lRet := .F.
	EndIf

	RestArea( aAreaSAL )
	RestArea( aArea )

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} 3.983: Function J098GaCpos()
	Função para obter valores para uso na tela de garantia do TOTVS Legal.

	@Return nSalGaCpos numérico - Saldo em Juízo da garantia.

	@author SIGAJURI
	@since 06/08/19
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function J098GaCpos(cCajuri, cGarantia, cCpoGar)

	Local nSalGaCpos := 0
	Local aDados     := {}
	Local nX         := 0
	Local cTipo      := ''

	Default cCajuri    := M->NT2_CAJURI
	Default cGarantia  := M->NT2_COD

	If cCpoGar == "NT2__GASJA"
		cTipo := "SF"
	Elseif cCpoGar == "NT2__GASJ"
		ctipo := "SFSA"
	Endif

	aDados := JA098CriaS(cCajuri)

	If Len(aDados) > 0
		For nX := 1 To Len(aDados)

			If aDados[nx][8] == cGarantia
				If aDados[nX][4] == cTipo
					nSalGaCpos := aDados[nX][5]
				EndIf
			EndIf
		Next nX
	EndIf

Return nSalGaCpos

//-------------------------------------------------------------------
/*/{Protheus.doc} J98F3SA6
Customiza a consulta padrão de Banco conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@since 14/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98F3SA6(cMaster, cCampo)
	Local lRet    := .F.
	Local aArea   := GetArea()
	Local oModel  := Nil
	Local cQuery  := ""
	Local aPesq   := {"A6_COD", "A6_NOME", "A6_AGENCIA", "A6_NUMCON"}
	Local nResult := 0

	Default cMaster := ''
	Default cCampo  := ''

	If IsPesquisa()
		cQuery   := JURA98SA6(xFilial('SA6'))
	Else
		oModel   := FWModelActive()

		If (oModel <> NIL) .And. !Empty(cMaster) .And. !Empty(cCampo)
			cQuery   := JURA98SA6(oModel:GetValue(cMaster,cCampo))
		Else
			cQuery   := JURA98SA6(xFilial('SA6'))
		EndIf
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)
	RestArea( aArea )

	nResult := JurF3SXB("SA6", aPesq, "", .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("SA6")
		SA6->( dbgoTo(nResult) )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA98SA6
Monta a query de tipo de ação partir de parâmetro de filial destino
Uso no cadastro de Garantias.

@Return cFildest  Campo de filial de destino
@Return cQuery	 	Query montada

@since 14/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA98SA6(cFilDest)
	Local aArea    := GetArea()
	Local cQuery   := ""
	Local cTabela  := "SA6"
	Local lFilial  := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .And. FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	cQuery += " SELECT A6_COD, A6_NOME, A6_AGENCIA, A6_NUMCON, R_E_C_N_O_ SA6RECNO "
	cQuery += "   FROM " + RetSqlName("SA6") + " SA6 "
	cQuery += "  WHERE SA6.D_E_L_E_T_ = ' '"
	cQuery += " AND A6_BLOCKED <> '" + '1' +"'"   //status bloqueado

	If !Empty(cFilDest)
		if lFilial
			cQuery += " AND A6_FILIAL = '" + cFilDest+"'"
		Else
			cQuery += " AND A6_FILIAL = '" + PadR(SubStr(cFilDest,1, Len(AllTrim(FWxFilial('SA6')))),Len(FwXFilial('SA6'))) + "'"
		Endif
	Else
		cQuery += " AND A6_FILIAL = '" + FwxFilial('SA6') + "'"
	EndIf

	RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J98ValBan
Customiza a consulta padrão de Natureza conforme a filial destino
Uso no cadastro de Garantias.

@param 	cMaster  	NT2DETAIL  - Dados da Garantia
@Return cCampo	    NT2_FILDES - Campo da filial de destino
@Return lRet	 	.T./.F. As informações são válidas ou não

@since 14/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J98ValBan(cFilDest,cCampo)
	Local lRet       := .T.
	Local aArea      := SA6->( GetArea() )
	Local cFilSA6    := ''
	Local cTabela    := "SA6"
	Local cBloqBanco := ""
	Local lFilial    := FWModeAccess(SUBSTRING(cTabela,1,3),1) == "E" .OR.;
	FWModeAccess(SUBSTRING(cTabela,1,3),2) == "E" .OR. ;
	FWModeAccess(SUBSTRING(cTabela,1,3),3) == "E"

	If lFilial .And. !Empty(cFilDest)
		cFilSA6 := FWxFilial("SA6", cFilDest)
	Else
		cFilSA6 := FWxFilial("SA6")
	EndIf

	If lRet .AND. !Empty( cCampo )
		DbSelectArea( "SA6" )
		SA6->( DbSetOrder( 1 ) )

		If !SA6->( DbSeek( cFilSA6 + cCampo ) )
			JurMsgErro( STR0064 )
			lRet := .F.
		EndIf

		//Valida Natureza financeira com status bloqueada
		cBloqBanco := JurGetDados("SA6", 1, xFilial("SA6") + cCampo , "A6_BLOCKED")

		IF cBloqBanco == "1"
			JurMsgErro( STR0093 ) //"Banco bloqueado para uso"
			lRet := .F.
		Endif
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA098IniPad
Inicializador padrão do campo de natureza financeira

@return  cRet       código da natureza financeira

@author  nishizaka.cristiane
@since   12/06/2020
/*/
//-------------------------------------------------------------------
Function JA098NatuTit()

Local cRet := ""

	// Proteção da tabela de campos contabeis complementares 
	If FWAliasIndic("O11")
		cRet := Posicione("O11",1,xFilial("O11")+M->NT2_CAJURI,"O11_CNATUT")
	EndIf
	
	If Empty(cRet)
		cRet := GetMv("MV_JNATGAR")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSugVlrTot
Função que faz a sugestão dos valores de valor, correção e juros da garantia.

@param cGaran    - Código da Garantia
@param cCajuri   - Código do Assunto Interno
@param dDataLev  - Data do Levantamento
@param cTpMovLev - Tipo de Levantamento
@param lWsTLegal - Chamada vem do Totvs Legal? .T. para sim e .F. para não.

@since 24/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSugVlrTot(cGaran, cCajuri, dDataLev, cTpMovLev, lWsTLegal)
Local nValor    := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VALOR")
Local nCorre    := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VCPROV")
Local nJuros    := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VJPROV")
Local cFormaCor := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_CCOMON")
Local nAtualiza := JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_VLRATU") - nValor // Valor da Atualização da garantia
Local dDtGarant := DtoS(JurGetDados("NT2", 5, xFilial("NT2") + cGaran + cCajuri, "NT2_DATA"))
Local lRet      := .T.
Local aDados    := {}
Local aSalJuizo := {}
Local aRetorno  := {}
Local nVlrLev   := 0
Local nCorLev   := 0
Local nJurLev   := 0
Local nAjuCor   := 0
Local nAjuJur   := 0
Local nValJur   := 0
Local nIr       := 0
Local nTefBan   := 0
Local nSaldo    := 0
Local nSalCorr  := 0
Local nSalJur   := 0
Local nJurCorre := 0
Local nTotal    := 0
Local nAuxJur   := 0
Local nAuxCor   := 0
Local nQtdLev   := 0
Local nI        := 0
Local nSalAtu   := 0
Local nValorCor := 0
Local cDtUltLev := ""

Default cGaran    := ''
Default cCajuri   := ''
Default cTpMovLev := ''
Default dDataLev  := Date()
Default lWsTLegal := .F.

Private nAtuCorre := 0
Private nAtuJuros := 0
	
	aDados    := J098ValLev(cCajuri, cGaran, cTpMovLev, lWsTLegal)
	lRet      := aDados[1]  //aDados[1]  lRet    - Indica se o valor do levantamento é valido, pois caso passe do valor original da garantia, não será permitido
	nVlrLev   := aDados[2]  //aDados[2]  nVlrLev - Valor dos levantamentos já feitos para a garantia
	nCorLev   := aDados[3]  //aDados[3]  nCorLev - Valor de correção dos levantamentos já feitos para a garantia
	nJurLev   := aDados[4]  //aDados[4]  nJurLev - Valor de juros dos levantamentos já feitos para a garantia
	nAjuCor   := aDados[5]  //aDados[5]  nAjuCor - Valor de ajuste de correção do levantamento já feito para a garantia
	nAjuJur   := aDados[6]  //aDados[6]  nAjuJur - Valor de ajuste de juros do levantamento já feito para a garantia
	nValJur   := aDados[7]  //aDados[7]  nValJur - Valor de juros
	nIr       := aDados[8]  //aDados[8]  nIr     - Valor de IR
	nTefBan   := aDados[9]  //aDados[9]  nTefBan - Valor de tarifas bancárias
	nMsg      := aDados[10] //aDados[10] nMsg    - 1-Valor dos levantamentos é maior que o da garantia / 2-Valor da garantia é maior que o dos levantamentos
	cDtUltLev := aDados[11] //aDados[11] cDtUltLev - Data ultimo Levantamento
	nQtdLev   := aDados[12] //aDados[12] nQtdLev   - Quantidade de Levantamentos da Garantia
	
	If (nAjuCor == 0 .or. nAjuJur == 0) .and. cTpMovLev == '1'
		nJurCorre := nCorre + nJuros
		
		//Proteção para quando for informado a forma de correção, mas sem aplicar a correção.
		If nJurCorre == 0 .and. nAtualiza < 0
			nAtualiza := 0
		EndIf
		
		nSaldo  := (nValor + nAtualiza) - nJurCorre - nVlrLev - nIr - nTefBan
		nAuxCor := nCorre - nCorLev - nAjuCor
		nAuxJur := nJuros - nJurLev - nAjuJur - nValJur
		
		If !Empty(cDtUltLev) //Verificação de existencia de outros levantamentos da garantia
			If nQtdLev > 1
				aSalJuizo := JA098CriaS(cCajuri)
				
				For nI := 1 to Len(aSalJuizo)
					// Validação se pertence a garantia e somente tipo Juros / Correção
					If aSalJuizo[nI][4] ==  "J" .and. aSalJuizo[nI][7] == cGaran
						// Validação para desconsiderar o juros / correção do primeiro levantamento e do ultimo levantamento
						If aSalJuizo[nI][5] != nJurCorre .and. aSalJuizo[nI][3] != dDataLev
							nSalAtu += aSalJuizo[nI][5]
						EndIf
					EndIf
				Next
			EndIf
			
			nTotal    := nValor - nVlrLev - nValJur - nIr - nTefBan - nCorLev - nJurLev + nJurCorre + nSalAtu
			nValorCor := JA002Valor( cFormaCor, nTotal, cDtUltLev, dDataLev, cDtUltLev )
			nSalCorr  := nAtuCorre
			nSalJur   := nAtuJuros
			
			If nQtdLev > 1
				//Se a garantia possuir saldo de Correção e após aplicação da correção monetária,
				If nSalCorr == 0 .and. nAuxCor > nSalAtu //não tiver nenhum retorno de correção, o saldo da Correção será atribuido.
					If nSalAtu <> 0
						nSalCorr += nAuxCor + nSalAtu
					Else
						nSalCorr += nAuxCor
					EndIf
					
					nAuxCor  := 0
				ElseIf nSalJur == 0 .and. nAuxJur > nSalAtu //Se a garantia possuir saldo de Juros e após aplicação da correção monetária,
					If nSalAtu <> 0                         //não tiver nenhum retorno de Juros, o saldo do Juros será atribuido.
						nSalJur += nAuxJur + nSalAtu
					Else
						nSalJur += nAuxJur
					EndIf
					
					nAuxJur := 0
				Else
					nSalJur += nSalAtu
				EndIf
			Else
				//Se a garantia possuir saldo de Correção e após aplicação da correção monetária,
				If nSalCorr == 0 .and. nAuxCor > 0 //não tiver nenhum retorno de correção, o saldo da Correção será atribuido.
					nSalCorr += nAuxCor
					nAuxCor  := 0
				EndIf
				//Se a garantia possuir saldo de Juros e após aplicação da correção monetária,
				If nSalJur == 0 .and. nAuxJur > 0  //não tiver nenhum retorno de Juros, o saldo do Juros será atribuido.
					nSalJur += nAuxJur
					nAuxJur := 0
				EndIf
			EndIf
		Else
			//Proteção para quando houve conversão de moeda para Real e o valor for 0
			If Round(nSaldo,2) == 0
				nSaldo := 0.00000001
				nValorCor := JA002Valor( cFormaCor, nValor, dDtGarant, dDataLev, dDtGarant )
				
				If nAtuCorre < 0
					nSalCorr  := nAtuCorre + nValor
				Else
					nSalCorr  := nAtuCorre
				EndIf
				
				If nAtuJuros < 0
					nSalJur  := nAtuJuros + nValor
				Else
					nSalJur  := nAtuJuros
				EndIf
			Else
				nValorCor := JA002Valor( cFormaCor, nSaldo, dDtGarant, dDataLev, dDtGarant )
				
				nSalCorr  := nAtuCorre
				nSalJur   := nAtuJuros
			EndIf
		EndIf
		
		//Proteção para quando NÃO houver conversão de moeda para Real e o valor for diferente de 0
		If !( Round(nSaldo,2) == 0) .and. !Empty(cDtUltLev)
			nSalJur  += nAuxJur
			nSalCorr += nAuxCor
		EndIf
		
		aAdd(aRetorno, {nSaldo, nSalCorr, nSalJur})
		
		nAtuJuros := 0
		nAtuCorre := 0
	EndIf
	
Return aRetorno
