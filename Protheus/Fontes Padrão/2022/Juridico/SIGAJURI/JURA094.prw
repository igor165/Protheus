#INCLUDE "JURA094.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static lRegAlterado := .F.	//Verifica se ocorreu alguma inclusao ou alteracao em algum registro, informacao para o fonte JURA100-Andamentos.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA094
Objetos

@author Raphael Zei Cartaxo Silva
@since 20/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA094(cProcesso, oModel095, cFilFiltro, lChgAll)
	Local oBrowse
	Local aArea    := GetArea()
	Local aAreaNSZ := NSZ->( GetArea() )

	Static cTipoAs := "" //tipo do assunto

	Default cProcesso   := ''
	Default oModel095   := FWModelActive()
	Default cFilFiltro  := xFilial("NSY")
	Default lChgAll     := .T.

	lRegAlterado := .F. //Verifica se ocorreu alguma inclusao ou alteracao em algum registro.
	cTipoAs      := FwFldGet('NSZ_TIPOAS',,oModel095)

	oBrowse := FWMBrowse():New()
	oBrowse:SetChgAll( lChgAll )
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "NSY" )
	oBrowse:SetLocate()

	If !Empty( cProcesso )
		oBrowse:SetFilterDefault( "NSY_FILIAL == '" + cFilFiltro + "' .AND. NSY_CAJURI == '" + cProcesso + "'" )
	EndIf

	oBrowse:SetMenuDef( 'JURA094' )

	JurSetBSize( oBrowse, '63,63,63' )
	JurSetLeg( oBrowse, "NSY" )
	oBrowse:Activate()

	RestArea( aAreaNSZ )
	RestArea( aArea )

Return lRegAlterado


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
@since 20/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local nI        := 0
	Local aAux      := {}
	Local aRotina   := {}
	Local aSubCor   := {}
	Local cGrpRest  := JurGrpRest()
	Local lAnoMes   := (SuperGetMV('MV_JVLHIST',, '2') == '1')
	Local lFlgaba   := JGetParTpa(cTipoAS, "MV_JVLRCO", "1") == "2" //Ativa o modo simplificado conforme valor do parametro MV_JVLRCO
	Local lNT6InDic := FWAliasInDic("NT6") //Verifica se existe a tabela NT6 no Dicionário (Proteção)

	aAdd( aRotina, { STR0001, "PesqBrw"          , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0010, "JurAnexos('NSY', NSY->NSY_COD+NSY->NSY_CAJURI, 3)", 0, 1, 0, .T. } ) // "Anexos"

	If lFlgaba .And. lNT6InDic
		If Existblock( 'JURR094' )
			aAdd( aRotina, { STR0039, "U_JURR094(NSY->NSY_COD)", 0, 1, 0, .T. } ) // "Histórico de Alterações"
		Else
			aAdd( aRotina, { STR0039, "JURR094(NSY->NSY_COD)", 0, 1, 0, .T. } ) // "Histórico de Alterações"
		EndIf
	Endif

	If JA162AcRst('06')
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA094"  , 0, 2, 0, NIL } ) // "Visualizar"
	EndIf

	If JA162AcRst('06', 3)
		aAdd( aRotina, { STR0003, "VIEWDEF.JURA094"  , 0, 3, 0, NIL } ) // "Incluir"
	EndIf

	If JA162AcRst('06', 4)
		aAdd( aRotina, { STR0004, "VIEWDEF.JURA094"  , 0, 4, 0, NIL } ) // "Alterar"
	EndIf

	If JA162AcRst('06', 5)
		aAdd( aRotina, { STR0005, "VIEWDEF.JURA094"  , 0, 5, 0, NIL } ) // "Excluir"
	EndIf

	If (!('CORRESPONDENTES' $ cGrpRest .Or. 'CLIENTES' $ cGrpRest) .Or. Empty(cGrpRest))
		If ('MATRIZ' $ cGrpRest .And. JA162AcRst('16', 2)) .Or. Empty(cGrpRest)
			If lAnoMes
				aAdd( aRotina, {STR0017, aSubCor        , 0, 1, 0, .T.} )                                 //"Correção Valores"
				aAdd( aSubCor, {STR0017, "J094Correc(1,NSY->NSY_CAJURI)", 0, 3, 0, NIL} )                 //"Correção Valores"
				aAdd( aSubCor, {STR0035, "J094Correc(2,NSY->NSY_CAJURI)", 0, 3, 0, NIL} )                 //"Recálculo"
				aAdd( aRotina, {STR0033, "JCall179(NSY->NSY_COD,NSY->NSY_FILIAL)", 0, 3, 0, NIL} )        //"Histórico Valores"
			Else
				aAdd( aRotina, {STR0017, "J094Correc(1,NSY->NSY_CAJURI)", 0, 6, 0, NIL} )                 //"Correção Valores"
			EndIf
		Endif
	EndIf

	If ExistBlock( 'JA094BTN' )
		aAux := Execblock('JA094BTN', .F., .F.)
		If Valtype( aAux ) == 'A'
			For nI := 1 to Len(aAux)
				aAdd(aRotina, aAux[nI])
			Next
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} J094Correc
Chama a rotina de correção e atualiza variavel de controle de alteração.

@author  Rafael Tenorio da Costa
@since   05/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J094Correc(nTipoCorr,cCajuri)

	Local aArea    := GetArea()
	Local aAreaNSY := NSY->( GetArea() )
	Local lRet     := .T.

	Default cCajuri  := NSY->NSY_CAJURI

	If nTipoCorr == 1
		lRet := JURCORVLRS('NSY')
	Else
		lRet := JURCORVLRS('NSY',,.T.)
	EndIf

	If lRet
		lRegAlterado := .T.
		If NSY->(FieldPos("NSY_REDUT")) > 0
			//Atualizando valor redutor da tela de objetos, após a correção ser efetuada
			JA94AtuRed(cCajuri)
		EndIf
	EndIf

	RestArea(aAreaNSY)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados do Objetos

@author Raphael Zei Cartaxo Silva
@since 20/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local nJ
	Local alCampos   := {}
	Local oModel     := FWLoadModel( "JURA094" )
	Local oStruct    := Nil
	Local oStructO07 := Nil
	Local aBotoes    := {}
	Local lFlgaba    := .F.
	Local lNT6InDic  := FWAliasInDic("NT6") //Verifica se existe a tabela NT6 no Dicionário (Proteção)
	Local lO07InDic  := FWAliasInDic("O07") //Verifica se existe a tabela O07 no Dicionário (Proteção)
	Local aGroups    := {}
	Local aNomcpo    := {}

	//Se não for relacionado a nenhum assunto jurídico, todos os campos do  modelo serão carregados
	If Type("cTipoAsJ") == "U"
		oStruct := FWFormStruct( 2, "NSY" )
	Else
		alCampos := J95NuzCpo(cTipoAsJ,"NSY")
		If Len(alCampos) == 0//Verifica se existe algum campo na NUZ
			JXLAtualiza(cTipoAsJ)//Sen não houver, é efetuada a carga inicial
			alCampos := J95NuzCpo(cTipoAsJ,"NSY")
		EndIf
		oStruct  := FWFormStruct( 2, "NSY", { | cCampo | x3Obrigat(cCampo) .Or. aScan(alCampos,cCampo) > 0 } )
		lFlgaba  := JGetParTpa(cTipoAS, "MV_JVLRCO", "1") == "2" //Ativa o modo simplificado conforme valor do parametro MV_JVLRCO
		JurSetAgrp( 'NSY',, oStruct, cTipoAs )
		JGetNmFld(oStruct, cTipoAsJ, c162TipoAs)
	EndIf

	aGroups    := oStruct:GetGroups()
	aNomcpo    := oStruct:GetFields()

	If lFlgaba
		J94CmpSimp(@oStruct, alCampos)

		For nJ := 1 To Len(aGroups)
			oStruct:Agroups[nJ]:cidFolder := "1"
			If !Empty( oStruct:Agroups[nJ]:cTitulo )
				J94GrpTroc( oStruct, oStruct:Agroups[nJ]:cTitulo, oStruct:Agroups[nJ]:cId, alCampos)
			Endif
		Next

		For nJ := 1 To Len(aNomcpo)
			If Val(oStruct:GetProperty( aNomcpo[nJ][1], MVC_VIEW_GROUP_NUMBER)) == 9
				If len(oStruct:GetProperty( aNomcpo[nJ][1], MVC_VIEW_GROUP_NUMBER)) == 2
					oStruct:SetProperty( aNomcpo[nJ][1], MVC_VIEW_GROUP_NUMBER, '01' )
				Else
					oStruct:SetProperty( aNomcpo[nJ][1], MVC_VIEW_GROUP_NUMBER, '1' )
				EndIf
			Endif
		Next
	Endif

	aSize(alCampos,0)

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 ) // "Objetos"
	oView:AddField("JURA094_VIEW", oStruct, "NSYMASTER")

	//Adiciona o sub-modelo Fundamentos do Objeto
	If lO07InDic
		oStructO07 := FWFormStruct(2, "O07")
		oStructO07:RemoveField("O07_COBJET")

		oView:AddGrid("JURA094_O07DETAIL", oStructO07, "O07DETAIL")
		oView:CreateHorizontalBox("FORMFIELD" , 75)
		oView:CreateHorizontalBox("FORMDETAIL", 25)

		oView:SetOwnerView("JURA094_O07DETAIL", "FORMDETAIL")
		oView:EnableTitleView("JURA094_O07DETAIL")
		If oStructO07:HasField( "O07_CAJURI" )
			oStructO07:RemoveField( "O07_CAJURI" )
		EndIf
	Else
		oView:CreateHorizontalBox("FORMFIELD" , 100)
	EndIf

	oView:SetOwnerView("JURA094_VIEW", "FORMFIELD")
	oView:EnableTitleView("JURA094_VIEW")
	oView:EnableControlBar(.T.)

	If Existblock( 'JA94RETBOT' )
		aBotoes := Execblock('JA94RETBOT', .F., .F.)
	EndIf

	If ( Empty(aBotoes) .Or. (Valtype( aBotoes ) == 'A' .And. aScan(aBotoes, {|x| AllTrim(x)=="BT01"} ) <= 0 ) ) .And. JA162AcRst('03')
		oView:AddUserButton( STR0010, "CLIPS", {| oView | IIF( J95AcesBtn(), J094Anexo(), FWModelActive()) } )
	EndIf

	oStruct:RemoveField( "NSY_CAJURI" )
	oStruct:RemoveField( "NSY_COD" )

	If lFlgaba .And. lNT6InDic
		If Existblock( 'JURR094' )
			oView:AddUserButton( STR0039, "CLIPS", {| oView | U_JURR094(NSY->NSY_COD) } )
		Else
			oView:AddUserButton( STR0039, "CLIPS", {| oView | JURR094(NSY->NSY_COD) } )
		EndIf
	Else
		If oStruct:HasField( "NSY_CINSTA" )
			oStruct:RemoveField( "NSY_CINSTA" )
		EndIf
	Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Objetos

@author Raphael Zei Cartaxo Silva
@since 20/05/09
@version 1.0

@obs NSYMASTER - Dados do Objetos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStruct    := FWFormStruct( 1, "NSY" )
	Local oStructNT6 := Nil
	Local oStructO07 := Nil
	Local lNT6InDic  := FWAliasInDic("NT6") //Verifica se existe a tabela NT6 no Dicionário (Proteção)
	Local lO07InDic  := FWAliasInDic("O07") //Verifica se existe a tabela O07 no Dicionário (Proteção)
	Local lFlgaba    := JGetParTpa(cTipoAS, "MV_JVLRCO", "1") == "2" //Ativa o modo simplificado conforme valor do parametro MV_JVLRCO

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------

	oModel:= MPFormModel():New( "JURA094",/*Pre-Validacao*/,{|oModel| JURA094TOK(oModel)}/*Pos-Validacao*/,{|oModel| JURA094COM(oModel)}/*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Valores em Discussão"
	oModel:AddFields( "NSYMASTER", NIL, oStruct,/*Pre-Validacao*/,/*Pos-Validacao*/)
	oModel:GetModel( "NSYMASTER" ):SetDescription( STR0009 ) // "Dados de Valores em Discussão"
	JurSetRules( oModel, 'NSYMASTER',, 'NSY' )

	If lNT6InDic .And. lFlgaba
		oStructNT6 := FWFormStruct( 1, "NT6" )

		oStructNT6:RemoveField( "NT6_CPEDID" )

		oModel:AddGrid( "NT6DETAIL", "NSYMASTER" /*cOwner*/, oStructNT6, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
		oModel:GetModel( "NT6DETAIL" ):SetDescription( "Histórico Pedidos" )
		oModel:SetRelation( "NT6DETAIL", {{"NT6_FILIAL", "XFILIAL('NT6')" }, {"NT6_CPEDID", "NSY_COD" }}, NT6->( IndexKey( 1 )))
		oModel:GetModel( "NT6DETAIL" ):SetUniqueLine( { "NT6_COD" } )
		oModel:GetModel( "NT6DETAIL" ):SetDelAllLine( .F. )
		oModel:GetModel( "NT6DETAIL" ):SetUseOldGrid( .F. )
		oModel:SetOptional( "NT6DETAIL" , .T. )
		JurSetRules( oModel, 'NT6DETAIL',, 'NT6' )
		//deixa o campo como obrigatório
		oStruct:SetProperty("NSY_CINSTA",MODEL_FIELD_OBRIGAT,.T.)
	EndIf

	//Adiciona o sub-modelo Fundamentos do Objeto
	If lO07InDic
		oStructO07 := FWFormStruct(1, "O07")
		oStructO07:RemoveField("O07_COBJET")

		oModel:AddGrid("O07DETAIL", "NSYMASTER" /*cOwner*/, oStructO07, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
		oModel:GetModel("O07DETAIL"):SetDescription(STR0040)	//"Fundamentos do Prognóstico"
		If oStructO07:HasField( "O07_CAJURI" )
			oModel:SetRelation("O07DETAIL", { {"O07_FILIAL", "XFILIAL('O07')" }, {"O07_CAJURI", "NSY_CAJURI"},{"O07_COBJET", "NSY_COD"} }, O07->( IndexKey(2) ) )
		Else
			oModel:SetRelation("O07DETAIL", { {"O07_FILIAL", "XFILIAL('O07')" }, {"O07_COBJET", "NSY_COD"} }, O07->( IndexKey(1) ) )
		EndIf
		oModel:GetModel( "O07DETAIL" ):SetUniqueLine( {"O07_CFUPRO", "O07_CCLFUN"} )
		oModel:SetOptional("O07DETAIL", .T.)
		JurSetRules(oModel, "O07DETAIL", , "O07")
	EndIf

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA094COM
Função para verificar se ocorreu inclusão/alteração do registro para ser utilizado principalmente no fonte JURA100-Andamentos.

@param  oModel	    Model a ser verificado

@author Antonio Carlos Ferreira
@since 25/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA094COM(oModel)
Local aArea    := GetArea()
Local nOpc     := oModel:GetOperation()
Local cCajuri  := FwFldGet("NSY_CAJURI")
Local cTipoAss := JurGetDados("NSZ", 1, xFilial("NSY") + cCajuri, "NSZ_TIPOAS")

	//Verifica se ocorreu alguma inclusao ou alteracao em algum registro, informacao para o fonte JURA100-Andamentos.
	lRegAlterado := lRegAlterado .Or. oModel:lModify .Or. nOpc == 5

	// Ajusta a correção e juros na NV3
	JurHisCont(cCajuri,, Date(), 0 , '2', '1', 'NSZ',3)
	JurHisCont(cCajuri,, Date(), 0 , '3', '1', 'NSZ',3)

	FWFormCommit(oModel)  //Grava os dados

	JURA002({{cCajuri, xFilial('NSY')}}, {'NSY'}, .F., , , , , .T., FwFldGet("NSY_COD"), "_COD")

	//Atualiza os valores de provisão\envolvido no processo
	If JGetParTpa(cTipoAss, "MV_JVLPROV", "1") == "2"
		AtuVlrPro(oModel)
	EndIf

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA094TOK
Validação ao salvar

@param  oModel	    Model a ser verificado
@Return lTudoOk	   	Valor lógico de retorno

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA094TOK( oModel )
	Local lTudoOk      := .T.
	Local aArea        := GetArea()
	Local nOpc         := oModel:GetOperation()
	Local aCamposMulta := {}
	Local lReg         := .F.
	Local nI           := 0
	Local aCmpsValDt   := J94CmpDt()
	Local lAnoMesHist  := (SuperGetMV('MV_JVLHIST',, '2') == '1')
	Local lFlgaba      := JGetParTpa(cTipoAS, "MV_JVLRCO", "1") == "2"
	Local lNT6InDic    := FWAliasInDic("NT6") //Verifica se existe a tabela NT6 no Dicionário (Proteção)
	Local oStructNSY   := oModel:GetModel("NSYMASTER"):GetStruct()
	Local aCampos      := {}
	Local cCajuri      := FwFldGet("NSY_CAJURI")

	If lTudoOk .And. (nOpc = 3 .Or. nOpc = 4) //3 - Incluir / 4 - Alterar
		//<-- Valida os campos de data da multa, se o campo de codigo estiver preenhcido -->
		for nI:= 1 TO LEN ( aCmpsValDt )
			// Verifica se o campo de codigo esta preenhcido e se a partir do codigo digitado será necessário preenhcer a data.
			IF !Empty( FwFldGet(aCmpsValDt[nI][1]) ).AND.JA094VlMult( FwFldGet(aCmpsValDt[nI][1]) )
				If Empty(FwFldGet(aCmpsValDt[nI][2]))
					lTudoOk := .F.
					//JurMsgErro("Favor preenhcer o campo "+ Alltrim(RetTitle(aCmpsValDt[nI][2])) + " da aba " +aCmpsValDt[nI][3] )
					JurMsgErro(STR0030 + Alltrim(RetTitle(aCmpsValDt[nI][2])) + STR0031 +aCmpsValDt[nI][3] )
					EXIT
				EndIF
			EndIf
		Next

		If lTudoOk
			//Valida campos de Multa de acordo com a Forma de Correção
			// Objeto
			If !Empty( FwFldGet('NSY_CCOMON')) .And. JA094VlMult( FwFldGet('NSY_CCOMON')) .And. ( Empty( FwFldGet('NSY_DTMULT')) .Or. Empty(FwFldGet('NSY_PERMUL')))
				lTudoOk:= .F.
				JurMsgErro( STR0019 + " (" + Iif(Empty(FwFldGet('NSY_DTMULT')),RetTitle('NSY_DTMULT'),RetTitle('NSY_PERMUL'))  +")" 	)
			EndIf
			// 1ª Instância
			If !Empty( FwFldGet('NSY_CFCOR1')) .And.JA094VlMult( FwFldGet('NSY_CFCOR1')) .And. ( Empty( FwFldGet('NSY_DTMUL1')) .Or. Empty( FwFldGet('NSY_PERMU1')))
				lTudoOk:= .F.
				JurMsgErro( STR0019 + " (" + Iif(Empty(FwFldGet('NSY_DTMUL1')), RetTitle('NSY_DTMUL1'),RetTitle('NSY_PERMU1'))  +")" )
			EndIf
			// 2ª Instância
			If !Empty( FwFldGet('NSY_CFCOR2')) .And. JA094VlMult( FwFldGet('NSY_CFCOR2')) .And. (Empty( FwFldGet('NSY_DTMUL2')) .Or. Empty(FwFldGet('NSY_PERMU2')))
				lTudoOk:= .F.
				JurMsgErro( STR0019 + " (" + Iif(Empty(FwFldGet('NSY_DTMUL2')), RetTitle('NSY_DTMUL2'),RetTitle('NSY_PERMU2'))  +")" )
			EndIf
			// Tribunal Superior
			If !Empty( FwFldGet('NSY_CFCORT')) .And. JA094VlMult( FwFldGet('NSY_CFCORT'))  .And. (Empty( FwFldGet('NSY_DTMUTR')) .Or. Empty(FwFldGet('NSY_PERMUT')))
				lTudoOk:= .F.
				JurMsgErro( STR0019 + " (" + Iif(Empty(FwFldGet('NSY_DTMUTR')), RetTitle('NSY_DTMUTR'),RetTitle('NSY_PERMUT'))  +")" )
			EndIf
			// Contingência
			If !Empty( FwFldGet('NSY_CFCORC')) .And. JA094VlMult( FwFldGet('NSY_CFCORC')) .And. (Empty(FwFldGet('NSY_DTMULC')) .Or. Empty( FwFldGet('NSY_PERMUC')))
				lTudoOk:= .F.
				JurMsgErro( STR0019 + " (" + Iif(Empty(FwFldGet('NSY_DTMULC')), RetTitle('NSY_DTMULC'),RetTitle('NSY_PERMUC'))  +")")
			EndIf
		EndIf

		If lTudoOk
			//Valida se os campos de data, moeda e valor estão OK (Ou preenche todos ou não preenche nenhum)
			//Valor do Pedido
			If FwFldGet('NSY_PEINVL') == "2" //Valor Inestimável = "2 - Não"
				If ( ( FwFldGet('NSY_PEVLR') > 0 ) .Or. !Empty( FwFldGet('NSY_PEDATA')) .Or. !Empty( FwFldGet('NSY_CMOPED')) ) .And. ;
						(( FwFldGet('NSY_PEVLR') == 0 ) .Or. Empty( FwFldGet('NSY_PEDATA')) .Or. Empty( FwFldGet('NSY_CMOPED')) )

					JurMsgErro(STR0012)    //"Preencher os campos de valor do objeto"
					lTudoOk:= .F.
				EndIf
			EndIf

			//Valor de Contingência
			If ( FwFldGet('NSY_INECON') == "2" ) //Valor Inestimável = "2 - Não"
				If ( ( FwFldGet('NSY_VLCONT') > 0 ) .Or. !Empty( FwFldGet('NSY_DTCONT')) .Or. !Empty( FwFldGet('NSY_CMOCON')) ) .And. ;
						( Empty( FwFldGet('NSY_DTCONT')) .Or. Empty( FwFldGet('NSY_CMOCON')) )
					JurMsgErro(STR0013)
					lTudoOk:= .F.
				EndIf
			EndIf

			//Tela em Modo Completo conforme valor do parametro MV_JVLRCO
			If (!lFlgaba ) .And. lTudoOk

				//Valor da 1ª Instância
				If ( ( FwFldGet('NSY_V1VLR') > 0 ) .Or. !Empty( FwFldGet('NSY_V1DATA')) .Or. !Empty( FwFldGet('NSY_CMOIN1')) ) .And. ;
						(( FwFldGet('NSY_V1VLR') == 0 ) .Or. Empty( FwFldGet('NSY_V1DATA')) .Or. Empty( FwFldGet('NSY_CMOIN1')) )
					JurMsgErro(STR0014)
					lTudoOk:= .F.
				EndIf

				//Valor da 2ª Instância
				If ( ( FwFldGet('NSY_V2VLR') > 0 ) .Or. !Empty( FwFldGet('NSY_V2DATA')) .Or. !Empty( FwFldGet('NSY_CMOIN2')) ) .And. ;
						( ( FwFldGet('NSY_V2VLR') == 0 ) .Or. Empty( FwFldGet('NSY_V2DATA')) .Or. Empty( FwFldGet('NSY_CMOIN2')) )
					JurMsgErro(STR0015)
					lTudoOk:= .F.
				EndIf

				//Valor do Tribunal Superior
				If ( ( FwFldGet('NSY_TRVLR') > 0 ) .Or. !Empty( FwFldGet('NSY_TRDATA')) .Or. !Empty( FwFldGet('NSY_CMOTRI')) ) .And. ;
						( ( FwFldGet('NSY_TRVLR') == 0 ) .Or. Empty( FwFldGet('NSY_TRDATA')) .Or. Empty( FwFldGet('NSY_CMOTRI')) )
					JurMsgErro(STR0016)
					lTudoOk:= .F.
				EndIf

				//Multa do Objeto
				If ( ( FwFldGet('NSY_VLRMUL') > 0 ) .Or. !Empty( FwFldGet('NSY_DTAMUL')) .Or. !Empty( FwFldGet('NSY_CMOEMU')) ) .And. ;
						( ( FwFldGet('NSY_VLRMUL') == 0 ) .Or. Empty( FwFldGet('NSY_DTAMUL')) .Or. Empty( FwFldGet('NSY_CMOEMU')) )
					JurMsgErro(STR0016)
					lTudoOk:= .F.
				EndIf

			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTJURJ')) .Or. !Empty(FwFldGet('NSY_CMOEJU')) .Or. !Empty(FwFldGet('NSY_VLRJUR'))) .And.;
						(Empty(FwFldGet('NSY_DTJURJ')) .Or. Empty(FwFldGet('NSY_CMOEJU')) .Or. Empty(FwFldGet('NSY_VLRJUR')))
					JurMsgErro(STR0021) //"Preencher os campos de valor de juros do Objeto"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTMUT1')) .Or. !Empty(FwFldGet('NSY_CMOEM1')) .Or. !Empty(FwFldGet('NSY_VLRMU1'))) .And.;
						(Empty(FwFldGet('NSY_DTMUT1')) .Or. Empty(FwFldGet('NSY_CMOEM1')) .Or. Empty(FwFldGet('NSY_VLRMU1')))
					JurMsgErro(STR0022) //"Preencher os campos de valor de multa 1ª instância"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTJU1')) .Or. !Empty(FwFldGet('NSY_CMOEJ1')) .Or. !Empty(FwFldGet('NSY_VLRJU1'))) .And.;
						(Empty(FwFldGet('NSY_DTJU1')) .Or. Empty(FwFldGet('NSY_CMOEJ1')) .Or. Empty(FwFldGet('NSY_VLRJU1')))
					JurMsgErro(STR0023) //"Preencher os campos de valor de juros 1ª instância"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTMUT2')) .Or. !Empty(FwFldGet('NSY_CMOEM2')) .Or. !Empty(FwFldGet('NSY_VLRMU2'))) .And.;
						(Empty(FwFldGet('NSY_DTMUT2')) .Or. Empty(FwFldGet('NSY_CMOEM2')) .Or. Empty(FwFldGet('NSY_VLRMU2')))
					JurMsgErro(STR0024) //"Preencher os campos de valor de multa 2ª instância"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTJU2')) .Or. !Empty(FwFldGet('NSY_CMOEJ2')) .Or. !Empty(FwFldGet('NSY_VLRJU2'))) .And.;
						(Empty(FwFldGet('NSY_DTJU2')) .Or. Empty(FwFldGet('NSY_CMOEJ2')) .Or. Empty(FwFldGet('NSY_VLRJU2')))
					JurMsgErro(STR0025) //"Preencher os campos de valor de juros 2ª instância"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTMUTT')) .Or. !Empty(FwFldGet('NSY_CMOEMT')) .Or. !Empty(FwFldGet('NSY_VLRMT'))) .And.;
						(Empty(FwFldGet('NSY_DTMUTT')) .Or. Empty(FwFldGet('NSY_CMOEMT')) .Or. Empty(FwFldGet('NSY_VLRMT')))
					JurMsgErro(STR0026) //"Preencher os campos de valor de multa tribunal superior"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTJUT')) .Or. !Empty(FwFldGet('NSY_CMOEJT')) .Or. !Empty(FwFldGet('NSY_VLRJUT'))) .And.;
						(Empty(FwFldGet('NSY_DTJUT')) .Or. Empty(FwFldGet('NSY_CMOEJT')) .Or. Empty(FwFldGet('NSY_VLRJUT')))
					JurMsgErro(STR0027) //"Preencher os campos de valor de juros tribunal superior"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTMUTC')) .Or. !Empty(FwFldGet('NSY_CMOEMC')) .Or. !Empty(FwFldGet('NSY_VLRMUC'))) .And.;
						(Empty(FwFldGet('NSY_DTMUTC')) .Or. Empty(FwFldGet('NSY_CMOEMC')) .Or. Empty(FwFldGet('NSY_VLRMUC')))
					JurMsgErro(STR0028) //"Preencher os campos de valor de multa contingência"
					lTudoOk:= .F.
				EndIf
			EndIf

			If lTudoOk
				If (!Empty(FwFldGet('NSY_DTJUC')) .Or. !Empty(FwFldGet('NSY_CMOEJC')) .Or. !Empty(FwFldGet('NSY_CLRJUC'))) .And.;
						(Empty(FwFldGet('NSY_DTJUC')) .Or. Empty(FwFldGet('NSY_CMOEJC')) .Or. Empty(FwFldGet('NSY_CLRJUC')))
					JurMsgErro(STR0029) //"Preencher os campos de valor de juros contingência"
					lTudoOk:= .F.
				EndIf
			EndIf

			//Valida Preenchimento da multa
			If lTudoOk
				If FwFldGet("NSY_DCOMON") == 'AutFederal' .And. DtoC(FwFldGet("NSY_DTMULT")) == "  /  /  "
					JurMsgErro(STR0018)	 //'O campo de data da multa de ser preenchido para este tipo de correção'
					lTudoOk := .F.
				Endif
			Endif

			If lTudoOk
				If (!Empty(FwFldGet('NSY_TRDATA')) .Or. !Empty(FwFldGet('NSY_CMOTRI')) .Or. !Empty(FwFldGet('NSY_TRVLR'))) .And.;
						!(!Empty(FwFldGet('NSY_TRDATA')) .And. !Empty(FwFldGet('NSY_CMOTRI')) .And. !Empty(FwFldGet('NSY_TRVLR')))
					JurMsgErro(STR0016)
					lTudoOk:= .F.
				EndIf
			EndIf

			//Limpar campos de valores atualizados quando o tipo de correção for modificado
			If nOpc == 4 .And. lTudoOk
				J095FCLMP(oModel:GetModel('NSYMASTER'),"NSY")
			EndIf

				/*<-- Verifca se o campo de multa esta vazio -->*/
			If lTudoOk
				aCamposMulta := { "NSY_PERMUC", "NSY_PERMU1", "NSY_PERMU2", "NSY_PERMUT", "NSY_PERMUC" }

				For nI= 1 to Len(aCamposMulta)
					lReg := .F.

					Do Case
					Case aCamposMulta[nI] == "NSY_PERMUC"
						lReg := JA094VlMult(FwFldGet('NSY_CFCORC'))

					Case aCamposMulta[nI] == "NSY_PERMU1"
						lReg := JA094VlMult(FwFldGet('NSY_CFCOR1'))

					Case aCamposMulta[nI] == "NSY_PERMU2"
						lReg := JA094VlMult(FwFldGet('NSY_CFCOR2'))

					Case aCamposMulta[nI] == "NSY_PERMUT"
						lReg := JA094VlMult(FwFldGet('NSY_CFCORT'))

					Case aCamposMulta[nI] == "NSY_PERMUC"
						lReg := JA094VlMult(FwFldGet('NSY_CFCORC'))
					EndCase

					If lReg
						If Empty( FwFldGet(aCamposMulta[nI] ))
							lTudoOk:= .F.
							JurMsgErro( STR0019 + " (" +  RetTitle(aCamposMulta[nI] ) +") " )
							EXIT	   // Sai do For
						EndIf
					EndIf
				Next
			EndIF

			//Verifica de onde sera pego o valor da provisao 1 = Processo \ 2 = Objetos
			If lTudoOk .And. JGetParTpa(cTipoAS, "MV_JVLPROV", "1") == "2"

				//Verifica se o codigo do prognostico foi preenchido
				If Empty( FwFldGet("NSY_CPROG") ) .AND. ( !Empty( oModel:GetValue("NSYMASTER","NSY_DTCONT") ) .OR. ;
						!Empty( oModel:GetValue("NSYMASTER","NSY_DTJURC") ) .OR. ;
						!Empty( oModel:GetValue("NSYMASTER","NSY_CMOCON") ) .OR. ;
						!Empty( oModel:GetValue("NSYMASTER","NSY_VLCONT") ) )
					JurMsgErro( I18N( STR0038, { AllTrim( JURX3INFO("NSY_CPROG", "X3_TITULO") )} ) )	//"Valor de provisão configurado para Objetos(MV_JVLPROV = 2). Por isso o campo #1 deverá ser preenchido."
					lTudoOk := .F.
				EndIf

			EndIf

			//Verifica a situação do processo e as configurações para poder alterá-lo com justificativa ou bloquear a alteração
			lTudoOk := JURSITPROC(cCajuri, 'MV_JTVENPD')

			//validação de alteração nos valores para atualização do histórico
			If lTudoOk .And. lAnoMesHist
				lTudoOk := J94AltValH(oModel:GetModel("NSYMASTER"), "NSY")
			Endif

			If lTudoOk .And. lFlgaba .And. lNT6InDic		//gravação da tabela NT6 (log de alterações tela simplificada)

				If 	oModel:IsFieldUpdated("NSYMASTER", "NSY_CINSTA") .Or.;
						oModel:IsFieldUpdated("NSYMASTER", "NSY_CDECPE") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_CPROG" ) .Or.;
						oModel:IsFieldUpdated("NSYMASTER", "NSY_PEVLR" ) .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_VLCONT")

					oModelNT6  := oModel:GetModel( 'NT6DETAIL' )

					If !oModelNT6:isEmpty()
						oModelNT6:AddLine()
					EndIf

					oModelNT6:SetValue('NT6_FILIAL',oModel:GetValue("NSYMASTER","NSY_FILIAL"))
					oModelNT6:SetValue('NT6_COD'   ,GetSXENUM( 'NT6', 'NT6_COD' )            )
					oModelNT6:SetValue('NT6_DTALT' ,Date()                                   )

					If oModelNT6:HasField('NT6_USUALT')
						oModelNT6:SetValue('NT6_USUALT',USRRETNAME(__CUSERID) )
					EndIf

					aCampos := {}
					Aadd(aCampos, {'NT6_CINSTA', "NSY_CINSTA"})
					Aadd(aCampos, {'NT6_CDECPE', "NSY_CDECPE"})
					Aadd(aCampos, {'NT6_CPROG' , "NSY_CPROG" })
					Aadd(aCampos, {'NT6_CCOMON', "NSY_CCOMON"})
					Aadd(aCampos, {'NT6_PEDATA', "NSY_PEDATA"})
					Aadd(aCampos, {'NT6_DTJURO', "NSY_DTJURO"})
					Aadd(aCampos, {'NT6_CMOPED', "NSY_CMOPED"})
					Aadd(aCampos, {'NT6_PEVLR' , "NSY_PEVLR" })
					Aadd(aCampos, {'NT6_DTMULT', "NSY_DTMULT"})
					Aadd(aCampos, {'NT6_PERMUL', "NSY_PERMUL"})
					Aadd(aCampos, {'NT6_PEINVL', "NSY_PEINVL"})
					Aadd(aCampos, {'NT6_CCORPE', "NSY_CCORPE"})
					Aadd(aCampos, {'NT6_CJURPE', "NSY_CJURPE"})

					Aadd(aCampos, {'NT6_MULATU', "NSY_MULATU"})
					Aadd(aCampos, {'NT6_PEVLRA', "NSY_PEVLRA"})
					Aadd(aCampos, {'NT6_CFCORC', "NSY_CFCORC"})
					Aadd(aCampos, {'NT6_DTCONT', "NSY_DTCONT"})
					Aadd(aCampos, {'NT6_DTJURC', "NSY_DTJURC"})
					Aadd(aCampos, {'NT6_CMOCON', "NSY_CMOCON"})
					Aadd(aCampos, {'NT6_VLCONT', "NSY_VLCONT"})
					Aadd(aCampos, {'NT6_DTMULC', "NSY_DTMULC"})
					Aadd(aCampos, {'NT6_PERMUC', "NSY_PERMUC"})
					Aadd(aCampos, {'NT6_INECON', "NSY_INECON"})
					Aadd(aCampos, {"NT6_CCORPC", "NSY_CCORPC"})
					Aadd(aCampos, {"NT6_CJURPC", "NSY_CJURPC"})
					Aadd(aCampos, {"NT6_MULATC", "NSY_MULATC"})
					Aadd(aCampos, {"NT6_VLCONA", "NSY_VLCONA"})

					For nI:=1 To Len(aCampos)
						If oStructNSY:HasField( aCampos[nI][2] )
							oModelNT6:SetValue(aCampos[nI][1], oModel:GetValue("NSYMASTER", aCampos[nI][2]))
						EndIf
					Next nI
				Endif
			Endif
		EndIf

	ElseIf nOpc == 5
		lTudoOk := JurExcAnex ('NSY',oModel:GetValue("NSYMASTER","NSY_COD"),cCajuri,'1')
	EndIf

	if lTudoOk .And. SuperGetMV('MV_JINTJUR',, '2') == '1'
		JurIntJuri(oModel:GetValue("NSYMASTER","NSY_COD"), cCajuri, "6", Str(nOpc))
	Endif


	If lTudoOk .And. SuperGetMV('MV_JFLUIGA',,'2') == '1'
		If NSY->( FieldPos("NSY_CODWF") ) > 0
			lTudoOk := J94FFluig(oModel, nOpc)
		EndIf
	EndIf

	RestArea( aArea )

Return lTudoOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR94G
Função utilizada para somar os valores no saldo referido ou para inestimar o valor do Assunto Jurídico corrente


@param 	cNomeCampo      	Nome do campo para ser somado
@param 	cAliasTabela 	    Alias da tabela
@param 	cAssuntoJuridico  	Código do Assunto Jurídico (CAJURI)
@param 	cRestricao       	Restrição para soma, notação em SQL
@param 	nValor           	Valor numérico do registro corrente
@param 	cTipo           	Tipo de opção para somar o valor
@param 	lInverte           	Inverte o tipo de opção para somar o valor

@Return nRet	         	Valor numérico de retorno

@sample
JUR94G('NSY_PEVLR','NSY',M->NSY_CAJURI,M->NSY_COD,"NSY_PESOMA='1'",M->NSY_PEVLR,M->NSY_PEINVL,.T.)

@author Raphael Zei
@since 09/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR94G ( cNomeCampo, cAliasTabela, cAssuntoJuridico, cCodigo, cRestricao, nValor, cTipo, lInverte, cTipoObjeto)
	local nRet    := 0
	Local aArea   := GetArea()
	local cRestr  := ''
	Local aCampos := {}

	Default cTipoObjeto := ""

	ParamType 0 Var cNomeCampo       As Character
	ParamType 1 Var cAliasTabela     As Character
	ParamType 2 Var cAssuntoJuridico As Character
	ParamType 3 Var cCodigo          As Character
	ParamType 4 Var cRestricao       As Character Optional Default ''
	ParamType 5 Var nValor           As Numeric
	ParamType 6 Var cTipo            As Character
	ParamType 7 Var lInverte         As Logical Default .F.
	ParamType 8 var cTipoObjeto      As Character

	cRestr := "AND "+cRestricao

	nRet := JURSOMA ( cNomeCampo, cAliasTabela, cAssuntoJuridico, cCodigo, cRestr, 0, cTipoObjeto)

	if (!lInverte .and. ctipo = '1') .or. (lInverte .and. ctipo = '2')
		aCampos := JURGetCampos(cTipoObjeto)
		nRet := nRet + nValor +FwFldGet(aCampos[1][1]) +FwFldGet(aCampos[1][2])
	end if

	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR94F3NSP
Customiza a consulta padrão de tipo para verificar o objeto do
assunto jurídico, a partir de parâmetro

@param 	cMaster  	NSYMASTER - Dados de Objetos
@Return cCampo	    NSY_CAJURI - Campo de código de Assunto Jurídico
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR94F3NSP(cMaster, cCampo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local oModel
	Local cQuery
	Local aPesq    := {"NSP_COD","NSP_DESC"}
	Local nResult  := 0

	Default cMaster := ''
	Default cCampo 	:= ''

	If IsPesquisa()
		cQuery   := JUR94NSP('')
	Else
		oModel   := FWModelActive()
		cQuery   := JUR94NSP(oModel:GetValue(cMaster,cCampo))
	EndIF

	cQuery := ChangeQuery(cQuery, .F.)

	RestArea( aArea )

	nResult := JurF3SXB("NSP", aPesq,, .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("NSP")
		NSP->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR94NSP
Monta a query de tipo a partir de parâmetro para filtro de
assunto jurídico

@Return cAssJur	    Campo de código de Assunto Jurídico
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 27/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR94NSP(cAssJur)
	Local cQuery   := ""

	If GetMV('MV_JFLTPED',, '2') == '1' .And. !Empty(cAssJur)

		cQuery += "SELECT NSP_COD, NSP_DESC, NSP.R_E_C_N_O_ NSPRECNO "
		cQuery += " FROM "+RetSqlName("NSP")+" NSP,"+RetSqlName("NQJ")+" NQJ,"+RetSqlName("NSZ")+" NSZ"
		cQuery += " WHERE NSZ_FILIAL   = '"+xFilial("NSZ")+"'"
		cQuery += " AND NQJ_FILIAL     = '"+xFilial("NQJ")+"'"
		cQuery += " AND NSP_FILIAL     = '"+xFilial("NSP")+"'"
		cQuery += " AND NQJ_FILIAL     = NSP_FILIAL"
		cQuery += " AND NSZ_COD        = '"+cAssJur+"'"
		cQuery += " AND NSZ_COBJET     = NQJ_COBJET "
		cQuery += " AND NQJ_CPEDID     = NSP_COD "
		cQuery += " AND NSZ.D_E_L_E_T_ = ' '"
		cQuery += " AND NQJ.D_E_L_E_T_ = ' '"
		cQuery += " AND NSP.D_E_L_E_T_ = ' '"

	Else

		cQuery += "SELECT NSP_COD, NSP_DESC, NSP.R_E_C_N_O_ NSPRECNO "
		cQuery += " FROM "+RetSqlName("NSP")+" NSP"
		cQuery += " WHERE NSP_FILIAL = '"+xFilial("NSP")+"'"
		cQuery += " AND NSP.D_E_L_E_T_ = ' '"

	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR94NSPV
Verifica se o valor do campo de tipo é valido

@param 	cMaster  	NSYMASTER - Dados dos Objetos
@Return cCampo	    NSY_CAJURI - Campo de código de Assunto Jurídico
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 27/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR94NSPV(cMaster, cCampo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaNSP := NSP->( GetArea() )
	Local oModel   := FWModelActive()
	Local cAssJur  := oModel:GetValue(cMaster,cCampo)
	Local cQuery   := JUR94NSP(cAssJur)
	Local cAlias   := GetNextAlias()

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	(cAlias)->( dbSelectArea( cAlias ) )
	(cAlias)->( dbGoTop() )

	While !(cAlias)->( EOF() )
		If (cAlias)->NSP_COD == oModel:GetValue(cMaster,'NSY_CPEVLR')
			lRet := .T.
			Exit
		EndIf
		(cAlias)->( dbSkip() )
	End

	If !lRet
		JurMsgErro(STR0011)
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea(aAreaNSP)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094F3NSY
Customiza a consulta padrão de juiz conforme a instância atual

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Clóvis Eduardo Teixeira
@since 27/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094F3NSY()
	Local lRet   := .F.
	Local aArea  := GetArea()
	Local cQuery := ''
	Local oModel
	Local aPesq  := {"NQH_COD","NQH_NOME"}
	Local nResult := 0

	If isPesquisa()
		cQuery := JA100QYNQH('')
	Else
		oModel := FWModelActive()
		cQuery := JA094QYNQH(oModel:GetValue('NSYMASTER','NSY_CAJURI'))
	EndIf

	cQuery := ChangeQuery(cQuery, .F.)
	RestArea( aArea )

	nResult := JurF3SXB("NQH", aPesq,, .F., .F.,, cQuery)
	lRet := nResult > 0

	If lRet
		DbSelectArea("NQH")
		NQH->(dbgoTo(nResult))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094QYNQH
Monta a query de juizes para trazer conforme a instância atual do
processo

@param  cAssJur	 	Código do assunto jurídico
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 27/04/10
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function JA094QYNQH(cAssJur)
	Local cQuery   := ""

	If !Empty(cAssJur)

		cQuery += "SELECT DISTINCT NQH_COD, NQH_NOME, NQH.R_E_C_N_O_ NQHRECNO "
		cQuery += " FROM "+RetSqlName("NQH")+" NQH, "+RetSqlName("NTD")+" NTD, "+RetSqlName("NUQ")+" NUQ "
		cQuery += " WHERE NUQ.D_E_L_E_T_ = ' '"
		cQuery += "   AND NQH.D_E_L_E_T_ = ' '"
		cQuery += "   AND NTD.D_E_L_E_T_ = ' '"
		cQuery += "   AND NUQ_FILIAL = '"+xFilial("NUQ")+"'"
		cQuery += "   AND NQH_FILIAL = '"+xFilial("NQH")+"'"
		cQuery += "   AND NTD_FILIAL = '"+xFilial("NTD")+"'"
		cQuery += "   AND NUQ_INSATU = '1'"
		cQuery += "   AND NUQ_CAJURI = '"+cAssJur+"'"
		cQuery += "   AND NQH_COD    = NTD_CODJUI"
		cQuery += "   AND NQH_TIPO   = NUQ_INSTAN"
		cQuery += "   AND NTD_CCOMAR = NUQ_CCOMAR"
		cQuery += "   AND NTD_CFORO  = NUQ_CLOC2N"
		cQuery += "   AND NTD_CVARA  = NUQ_CLOC3N"

	Else

		cQuery += "SELECT DISTINCT NQH_COD, NQH_NOME, NQH.R_E_C_N_O_ NQHRECNO "
		cQuery += " FROM "+RetSqlName("NQH")+" NQH "
		cQuery += " WHERE NQH.D_E_L_E_T_ = ' '"
		cQuery += "   AND NQH_FILIAL = '"+xFilial("NQH")+"'"

	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094VlMult(cCdFrmCorr)
Valida se deve habilitar os campos de multa(Data, Porcentagem e Valor)

@Param 	cCdFrmCorr	Código da Forma de Correção

@author Tiago Martins
@since 18/11/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094VlMult(cCdFrmCorr)
	Local cFormula  := ''
	Local lRet      := .F.

	if !Empty(cCdFrmCorr)
		If cCdFrmCorr == "30" .OR. cCdFrmCorr == "09"
			lRet := .T.
		Else
			cFormula := Posicione('NW7', 1 , xFilial('NW7') + cCdFrmCorr, 'NW7_FORMUL')
			lRet := '#VLRMULTA' $ cFormula
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094SAtuNSZ(cCajuri)
Informa nos valores do assunto Jurídico o Saldo dos Objetos Atualizados

@Param 	cCajuri		Código do Assunto Juridico

@author Jorge Luis Branco Martins Junior
@since 20/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094SAtuNSZ(cCajuri)
	Local aArea  := GetArea()
	Local cQuery := ''
	Local nValor := 0
	Local aSQL   := {}

	If !INCLUI
		cQuery += " SELECT SUM(ROUND(NSY_PEVLRA,2)) + SUM(ROUND(NSY_MUATUA,2)) + SUM(ROUND(NSY_JURATU,2)) VALOR "
		cQuery +=   " FROM " + RetSQLName('NSY')
		cQuery +=  " WHERE NSY_FILIAL = '" +xFilial('NSY')+"' "
		cQuery +=    " AND NSY_CAJURI = '"+cCajuri+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' ' "
		aSQL := JurSQL(cQuery, {"VALOR"})

		If !Empty(aSQL)
			nValor :=	aSQL[1][1]
		EndIf
	Else
		nValor :=	0
	EndIf

	RestArea(aArea)

Return nValor

///-------------------------------------------------------------------
/*/{Protheus.doc} JurCalcTotal
Soma dos campos de Valor Total Original e Valor Total Atualizado
@author Clóvis Eduardo Teixeira
@since 15/04/12
@version 1.0
/*/
//--------------------------------------------------------------------
Function JurCalcTotal(nValorObjeto, nValorMulta, nValorJuros)
	Local nValorTotal := 0

	If Empty(nValorObjeto)
		nValorObjeto := 0
	Endif

	If Empty(nValorMulta)
		nValorMulta := 0
	Endif

	If Empty(nValorJuros)
		nValorJuros := 0
	Endif

	nValorTotal := (nValorObjeto + nValorMulta + nValorJuros)

Return nValorTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094SAtuSAPE(aCodigos)
Atualização do campos de Saldo dos Objetos Atualizados
@Param 	aCodigos		Códigos dos Assuntos Juridicos
@author Clóvis Eduardo Teixeira
@since 20/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094SAtuSAPE(aCodigos)
	Local aArea  := GetArea()
	Local cTemp  := ''
	Local cQuery := ''
	Local nValor := 0
	Local nI     := 0

	If !Empty ( aCodigos )

		For nI := 1 to Len(aCodigos)

			cQuery := ''
			cQuery += "SELECT SUM(ROUND(NSY_PEVLRA,2)) + SUM(ROUND(NSY_MUATUA,2)) + SUM(ROUND(NSY_JURATU,2)) VALOR FROM " + RetSQLName( 'NSY' )
			cQuery += " WHERE NSY_FILIAL = '" +xFilial('NSY')+"' "
			cQuery += " 	AND NSY_CAJURI = '"+aCodigos[nI][1]+"'"
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			cTemp := GetNextAlias()

			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTemp, .T., .T. )
			nValor := (cTemp)->VALOR
			(cTemp)->( dbCloseArea() )

			NSZ->(DBSetOrder(1))

			If NSZ->(dbSeek(xFilial('NSZ') + aCodigos[nI][1]))
				RecLock('NSZ', .F.)
				NSZ->NSZ_SAPE := nValor
				NSZ->NSZ_DTUASP := sTod(AllTrim(J094DTUAP(aCodigos[nI][1])))
				MsUnlock()
			Endif

		Next

	Endif

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J094DTUAP
Campo para calculo do data da ultima atualização do saldo em juízo
Uso Geral
@Param cCajuri - Código do processo
@Return  cData - Data da ultima atualização
@author Clóvis Eduardo Teixeira
@since 20/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J094DTUAP(cCajuri)
	Local cData     := ''
	Local aArea 	  := GetArea()
	Local cAlias    := GetNextAlias()
	Local cQuery   := ""

	cQuery += "SELECT MAX(NSY_DTULAT) DATA_ULTATU"+ CRLF
	cQuery += "  FROM "+RetSqlName("NSY")+" NSY "+ CRLF
	cQuery += " WHERE NSY_FILIAL     = '"+xFilial("NSY")+"'"+ CRLF
	cQuery += "   AND NSY.D_E_L_E_T_ = ' ' AND NSY_CAJURI =  '"+cCajuri+"'"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If !(cAlias)->( EOF() )

		cData := (cAlias)->DATA_ULTATU

	Endif

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return cData

//-------------------------------------------------------------------
/*/{Protheus.doc} J94CmpDt()
Função para carregar um array com os campos de códigos e campos do tipo de
data para serem validados no TudoOk

@Return aCmps - Array dos campos para serem verificados.
@author Rafael Rezende Costa
@since 16/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94CmpDt()
	Local aCmps	 := {}

	// Objeto
	aAdd( aCmps,  {"NSY_CCOMON","NSY_DTMULT",JURX3XADesc("NSY_DTMULT") })
	aAdd( aCmps,  {"NSY_CFCMUL","NSY_DTAMUL",JURX3XADesc("NSY_DTAMUL") })
	aAdd( aCmps,  {"NSY_FCJURO","NSY_DTJURJ",JURX3XADesc("NSY_DTJURJ") })
	//1 Inst
	aAdd( aCmps,  {"NSY_CFCOR1","NSY_DTMUL1",JURX3XADesc("NSY_DTMUL1") })
	aAdd( aCmps,  {"NSY_CFJUR1","NSY_DTMUT1",JURX3XADesc("NSY_DTMUT1") })
	aAdd( aCmps,  {"NSY_FCJUR1","NSY_DTJU1" ,JURX3XADesc("NSY_DTJU1" ) })
	//2 Inst
	aAdd( aCmps,  {"NSY_CFCOR2","NSY_DTMUL2",JURX3XADesc("NSY_DTMUL2") })
	aAdd( aCmps,  {"NSY_CFMUL2","NSY_DTMUT2",JURX3XADesc("NSY_DTMUT2") })
	aAdd( aCmps,  {"NSY_FCJUR2","NSY_DTJU2" ,JURX3XADesc("NSY_DTJU2")  })
	// Tribunal Superior
	aAdd( aCmps,  {"NSY_CFCORT","NSY_DTMUTR",JURX3XADesc("NSY_DTMUTR") })
	aAdd( aCmps,  {"NSY_CFMULT","NSY_DTMUTT",JURX3XADesc("NSY_DTMUTT") })
	aAdd( aCmps,  {"NSY_FCJURT","NSY_DTMUTT",JURX3XADesc("NSY_DTMUTT") })
	// Contigência
	aAdd( aCmps,  {"NSY_CFCORC","NSY_DTMULC",JURX3XADesc("NSY_DTMULC") })
	aAdd( aCmps,  {"NSY_CFMULC","NSY_DTMUTC",JURX3XADesc("NSY_DTMUTC") })
	aAdd( aCmps,  {"NSY_FCJURC","NSY_DTJUC" ,JURX3XADesc("NSY_DTJUC") })

Return aCmps


//-------------------------------------------------------------------
/*/{Protheus.doc} J94CAJUR()
Posiciona de acordo com o Codigo do assunto juridico

@Return cCajuri Retorna o Codigo do assunto juridico
@author Wellington Coelho
@since 31/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94CAJUR()

	Local cCajuri := ''

	If  IsInCallStack('JURA100') .And. ( (M->NT4_CAJURI != NSZ->NSZ_COD) .And. (M->NT4_CAJURI != M->NSZ_COD) )
		NSZ->(DBSetOrder(1))
		If  NSZ->(dbSeek(xFilial('NSZ') + M->NT4_CAJURI))
			cCajuri := NSZ->NSZ_COD
		EndIf
	Else
		If  !( Empty(NSZ->NSZ_COD) )
			cCajuri := NSZ->NSZ_COD
		Else
			cCajuri := M->NSZ_COD
		EndIf
	EndIf

Return cCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall179
Função que chama a JURA179.

@param 	cProcesso 	Código do Assunto Jurídico \r\n

@author André Spirigoni Pinto
@since 17/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall179(cValor,cBrwFilial)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()

// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA100 inserida no XNU.
	AcBrowse := Replicate("x",10)
	SetFunName( 'JURA179' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA100

	JURA179(cValor,cBrwFilial)

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J94AltValH
Valida alterações nos campos de valor e data dos Objetos
atualizáveis para ajustar o histórico conforme necessário.

@param 	oModel   Modelo de dados
@param 	cTabela   Tabela que está sendo alterada
@author André Spirigoni Pinto

@since 21/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J94AltValH(oModel, cTabela)
	Local aArea     := GetArea()
	Local aAreaNZ1  := NZ1->( GetArea() )
	Local lData     := .F.
	Local lForma    := .F.
	Local lValor    := .F.
	Local lAviso    := .F.
	Local nI        := 0
	Local aCampos   := J095NW8(cTabela) //1 - campo, 2 - data, 3 - historico, 4 forma


	dbSelectArea("NZ1")
	NZ1->(DBSetOrder(1)) //NZ1_FILIAL+NZ1_CVALOR+NZ1_ANOMES

	For nI := 1 to Len(aCampos)
		lData := .F.
		lValor := .F.
		lForma := .F.

		Do Case
		Case oModel:isFieldUpdated(aCampos[nI][4])
			lForma := .T.
		Case oModel:isFieldUpdated(aCampos[nI][1])
			lValor := .T.
		Case oModel:isFieldUpdated(aCampos[nI][2])
			lData  := .T.
		End Case

		//caso a forma de correção tenha sido alterada o sistema deve recalcular tudo.
		If lForma
			If NZ1->( dbSeek( xFilial('NZ1') + oModel:GetValue('NSY_COD') ) )
				While !NZ1->(EOF()) .And. NZ1->NZ1_CVALOR ==  oModel:GetValue('NSY_COD')
					Reclock( 'NZ1', .F. )
					NZ1->&(aCampos[nI][3]) := 0
					NZ1->&(Replace(aCampos[nI][5],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][6],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][7],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][8],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][4],cTabela,"NZ1")) := oModel:GetValue(aCampos[nI][4])
					NZ1->( MsUnlock() )
					NZ1->( dbSkip() )
					lAviso := .T.
				End
			Endif
			//Caso a data seja alterada, a correção deve mudar a partir da mesma. Caso o valor tenha sido alterado.
		ElseIf lValor
			If NZ1->( dbSeek( xFilial('NZ1') + oModel:GetValue('NSY_COD') + AnoMes(oModel:GetValue(aCampos[nI][2])) ) )
				While !NZ1->(EOF()) .And. NZ1->NZ1_CVALOR ==  oModel:GetValue('NSY_COD')
					Reclock( 'NZ1', .F. )
					NZ1->&(aCampos[nI][3]) := 0
					NZ1->&(Replace(aCampos[nI][5],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][6],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][7],cTabela,"NZ1")) := 0
					NZ1->&(Replace(aCampos[nI][8],cTabela,"NZ1")) := 0
					NZ1->(MsUnlock())
					NZ1->( dbSkip() )
					lAviso := .T.
				End
			EndIf
		EndIf
	Next

	NZ1->( DBCloseArea() )
	If lAviso
		ApMsgInfo(STR0034) //"Para atualizar os valores, execute a correção de valores."
	Endif

	RestArea(aAreaNZ1)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094VlDis
Retorna a soma dos Objetos da ultima instancia, por tipo de provisão sendo
retornado o valor normal ou valor atualizado.

@param 	cProcesso 	- Numero do processo
@param 	cTipoProv	- Tipo da provisão a ser retornada - 1=Provavel;2=Possivel;3=Remoto
@param	lAtual		- Define se o valor retornado será o valor atualizado
@param 	cFilNsy		- Filial do processo
@param  lVlrCorrec  - Define se deve retornar a soma dos valores de correção e juros

@return	nTotal 		- Soma dos Objetos da ultima instancia
@author Rafael Tenorio da Costa

@since 12/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094VlDis( cProcesso, cTipoProv, lAtual, cFilNsy, lVlrCorrec )
Local aArea      := GetArea()
Local aAreaNSY   := NSY->( GetArea() )
Local nTotal     := 0
Local aTotal     := {}
Local cTabela    := ""
Local cQuery     := ""
Local lPedidos   := .F.

Default cTipoProv := "1"	//Tipo de provisão 1 = Provavel
Default lAtual    := .F.	//Define se o valor retornado deve ser o atualizado.
Default cFilNsy   := xFilial("NSY")
Default lVlrCorrec:= .F.

	//Verifica se existe ponto de entrada que irá retornar o valor dos objetos por tipo de provisão
	If ExistBlock("J94VLDIS")
		nTotal := ExecBlock("J94VLDIS", .F., .F., {cProcesso, cTipoProv, lAtual})
		If lVlrCorrec
			aAdd(aTotal, { nTotal, 0, 0})
		Else 
			aAdd(aTotal, nTotal)
		Endif
	Else
		
		//Verifica se a rotina de Pedidos foi implementada
		DBSelectArea("NSY")
		lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		NSY->( DBCloseArea() )

		cQuery := " SELECT ISNULL( " + CRLF
		cQuery +=               " SUM ( " + CRLF

		//Valores atualizados
		If lAtual

			If lPedidos
				cQuery += "( CASE WHEN NSY_CVERBA <> '' THEN ( "
				cQuery +=         " ISNULL( (CASE WHEN NSY_DTCONT > ''  THEN NSY_VLCONA ELSE NSY_PEVLRA END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA ELSE NSY_TRVLR  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_MUATT  > 0 THEN NSY_MUATT  ELSE NSY_VLRMT  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA ELSE NSY_V2VLR  END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_MUATU2 > 0 THEN NSY_MUATU2 ELSE NSY_VLRMU2 END), 0)"
				cQuery +=         " + ISNULL( (CASE WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA ELSE NSY_V1VLR  END), 0))" //Se tiver dados de pedidos feito pela tela nova, soma a multa, honorário e encargo.
				cQuery += " ELSE (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONA"
				cQuery +=            " WHEN NSY_TRDATA > '' THEN NSY_TRVLRA"
				cQuery +=            " WHEN NSY_DTJUR2 > '' THEN NSY_V2VLRA"
				cQuery +=            " WHEN NSY_V1DATA > '' THEN NSY_V1VLRA"
				cQuery +=       " ELSE NSY_PEVLRA END)"
				cQuery += " END)), 0) TOTAL "
				If lVlrCorrec
					cQuery += ", ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CCORPC"
					cQuery +=                          " WHEN NSY_TRDATA > '' THEN NSY_CCORPT"
					cQuery +=                          " WHEN NSY_DTJUR2 > '' THEN NSY_CCORP2"
					cQuery +=                          " WHEN NSY_V1DATA > '' THEN NSY_CCORP1"
					cQuery +=                          " ELSE NSY_CCORPE END)), 0 ) CORRECAO,"
					cQuery += " ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CJURPC"
					cQuery +=                          " WHEN NSY_TRDATA > '' THEN NSY_CJURPT"
					cQuery +=                          " WHEN NSY_DTJUR2 > '' THEN NSY_CJURP2"
					cQuery +=                          " WHEN NSY_V1DATA > '' THEN NSY_CJURP1"
					cQuery +=                          " ELSE NSY_CJURPE END)), 0 ) JUROS"
				EndIf
			Else
				cQuery += " (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONA"
				cQuery += 		" WHEN NSY_TRDATA > '' THEN NSY_TRVLRA"
				cQuery += 		" WHEN NSY_DTJUR2 > '' THEN NSY_V2VLRA"
				cQuery += 		" WHEN NSY_V1DATA > '' THEN NSY_V1VLRA"
				cQuery += " ELSE NSY_PEVLRA END)) "
				cQuery +=			            ", 0) TOTAL "
				If lVlrCorrec
					cQuery += ", ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CCORPC END)), 0 ) CORRECAO, "
					cQuery += " ISNULL( SUM( "
					cQuery +=                    " (CASE WHEN NSY_DTCONT > '' THEN NSY_CJURPC END)), 0 ) JUROS"
				EndIf
			EndIf

			//Valores normais
		Else
			cQuery += " (CASE WHEN NSY_DTCONT > '' THEN NSY_VLCONT"
			cQuery += 		" WHEN NSY_TRDATA > '' THEN NSY_TRVLR"
			cQuery += 		" WHEN NSY_DTJUR2 > '' THEN NSY_V2VLR"
			cQuery += 		" WHEN NSY_V1DATA > '' THEN NSY_V1VLR"
			cQuery += " ELSE NSY_PEVLR END)) "
			cQuery +=			            ", 0) TOTAL "
		EndIf

		cQuery += " FROM " +RetSqlName("NSY")+ " NSY INNER JOIN " +RetSqlName("NQ7")+ " NQ7 "
		cQuery +=   " ON NQ7_FILIAL = '" +xFilial("NQ7") + "' AND NSY_CPROG = NQ7_COD "
		cQuery += " WHERE NSY_FILIAL = '" + cFilNsy + "' "
		cQuery +=       " AND NSY_CAJURI = '" + cProcesso + "' "
		cQuery +=       " AND NQ7_TIPO = '" + cTipoProv + "' "//1=Provavel;2=Possivel;3=Remoto
		cQuery +=       " AND NSY.D_E_L_E_T_ = ' ' "
		cQuery +=       " AND NQ7.D_E_L_E_T_ = ' ' "

		cQuery  := ChangeQuery(cQuery)
		cTabela := GetNextAlias()

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		If !(cTabela)->( Eof() )
			If lVlrCorrec
				aAdd(aTotal, { (cTabela)->TOTAL , (cTabela)->CORRECAO, (cTabela)->JUROS})
			Else
				aAdd(aTotal, (cTabela)->TOTAL)
			EndIf
		EndIf

		(cTabela)->( DbCloseArea() )
	EndIf

	RestArea( aAreaNSY )
	RestArea( aArea )

Return Iif(lVlrCorrec,aTotal,aTotal[1])

//-------------------------------------------------------------------
/*/{Protheus.doc} J94CmpSimp()
Função para carregar os array com os campos dos grupos Dados Processo, Objeto e Contigência

@author Reginaldo N Soares
@since 17/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94CmpSimp(oStruct, acamposimp)
	Local nI
	Local allfields  := oStruct:GetFields()

	For nI := 1 To Len(acamposimp)
		If oStruct:HasField(AllTrim(acamposimp[nI]))
			oStruct:SetProperty(AllTrim(acamposimp[nI]) , MVC_VIEW_FOLDER_NUMBER, '1')
		EndIf
	Next

	For nI := 1 To Len(allfields)
		IF nI <= Len(allfields)

			//Verifica se o campos esta na primeira pasta
			If allfields[nI][MVC_VIEW_FOLDER_NUMBER] <> '1'

				//Verifica se eh campo de usuario
				If JurGetDados("SX3", 2, allfields[nI][MVC_VIEW_IDFIELD], "X3_PROPRI") == "U"
					oStruct:SetProperty(allfields[nI][MVC_VIEW_IDFIELD] , MVC_VIEW_FOLDER_NUMBER, '1')
				Else
					oStruct:RemoveField(allfields[nI][MVC_VIEW_IDFIELD])
					nI--
				EndIf
			Endif
		Else
			Exit
		Endif
	Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J94GrpTroc()
Função para trocar as pastas dos campos conforme a nova estrutura de grupos

@author Reginaldo N Soares
@since 17/03/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94GrpTroc(oStruct, cGrpnome, cGrpnro, acamposimp)
	Local aArea  := GetArea()
	Local cLista := GetNextAlias()
	Local cQuery := ""
	Local cCampo := ""
	Local cLang  := UPPER(__Language)

	cQuery := "SELECT NUY_CAMPO FROM " + RetSQLName("NUX") + " NUX " + CRLF
	cQuery += " INNER JOIN " + RetSQLName("NUY") + " NUY ON" + CRLF
	cQuery += " NUY_TABELA = NUX_TABELA " + CRLF
	cQuery += " AND NUY_CODGRP = NUX_CODGRP " + CRLF
	cQuery += " AND NUY.D_E_L_E_T_ = ' '" + CRLF
	cQuery += " WHERE NUX.D_E_L_E_T_ = ' '" + CRLF

	Do Case
	Case cLang == "PORTUGUESE"
		cQuery += " AND NUX_GRUPO = '" + cGrpnome + "'"
	Case cLang == "ENGLISH"
		cQuery += " AND NUX_GRUENG = '" + cGrpnome + "'"
	Case cLang == "SPANISH"
		cQuery += " AND NUX_GRUSPA = '" + cGrpnome + "'"
	EndCase

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cLista,.T.,.T.)

	While (cLista)->(!Eof())

		cCampo := AllTrim( (cLista)->NUY_CAMPO )
		If ( oStruct:HasField(cCampo) .And. (aScan(acamposimp, cCampo) > 0  .Or.;
				JurGetDados("SX3", 2, cCampo, "X3_PROPRI") == "U"))
			oStruct:SetProperty(cCampo, MVC_VIEW_GROUP_NUMBER, cGrpnro)
		Endif
		(cLista)->(dbSkip())
	Enddo

	(cLista)->( dbcloseArea() )
	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JA094VlEnv
Retorna o valor envolvido a partir soma de todos os Objetos com valores da
ultima instancia, retornado o valor normal e valor atualizado.

@param 	cProcesso 	- Numero do processo
@param 	cFilNsy		- Filial do processo
@return	aVlEnvolvi	- Soma dos Objetos da ultima instancia
@author Rafael Tenorio da Costa

@since 10/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA094VlEnv(cProcesso, cFilNsy )

	Local aArea		 := GetArea()
	Local aAreaNSY   := NSY->( GetArea() )
	Local aVlEnvolvi := {}
	Local cQuery	 := ""
	Local lPedidos   := .F.

	Default cFilNsy := xFilial("NSY")

	//Verifica se existe ponto de entrada que irá retornar o valor dos objetos por tipo de provisão
	If ExistBlock("J94VlEnv")
		aVlEnvolvi := ExecBlock("J94VlEnv", .F., .F., {cProcesso})
	Else
		//Verifica se a rotina de Pedidos foi implementada
		DBSelectArea("NSY")
		lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		NSY->( DBCloseArea() )

		cQuery := " SELECT "

		If lPedidos
			//Valores normais
			cQuery += " ISNULL(SUM (( CASE "
			cQuery +=                  "WHEN NSY.NSY_CVERBA <> '' THEN NSY.NSY_PEVLR "
			cQuery +=                  "WHEN NSY.NSY_TRVLR > 0 THEN NSY.NSY_TRVLR "
			cQuery +=                  "WHEN NSY.NSY_V2VLR > 0 THEN NSY.NSY_V2VLR "
			cQuery +=                  "WHEN NSY.NSY_V1VLR > 0 THEN NSY.NSY_V1VLR "
			cQuery +=                  "WHEN NSY.NSY_PEVLR > 0 THEN NSY.NSY_PEVLR "
			cQuery +=                "END )), 0) ENVOLVIDO,"

			//Valores atualizados
			cQuery += " ISNULL( SUM ( "
			cQuery +=                "( CASE WHEN NSY.NSY_CVERBA <> '' THEN ( "
			cQuery +=                       " ISNULL( (CASE WHEN NSY.NSY_DTCONT > ''  THEN NSY.NSY_VLCONA ELSE NSY.NSY_PEVLRA END), 0)"
			cQuery +=                       " + ISNULL( (CASE WHEN NSY.NSY_TRVLRA > 0 THEN NSY.NSY_TRVLRA ELSE NSY.NSY_TRVLR  END), 0)"
			cQuery +=                       " + ISNULL( (CASE WHEN NSY.NSY_MUATT  > 0 THEN NSY.NSY_MUATT  ELSE NSY.NSY_VLRMT  END), 0)"
			cQuery +=                       " + ISNULL( (CASE WHEN NSY.NSY_V2VLRA > 0 THEN NSY.NSY_V2VLRA ELSE NSY.NSY_V2VLR  END), 0)"
			cQuery +=                       " + ISNULL( (CASE WHEN NSY.NSY_MUATU2 > 0 THEN NSY.NSY_MUATU2 ELSE NSY.NSY_VLRMU2 END), 0)"
			cQuery +=                       " + ISNULL( (CASE WHEN NSY.NSY_V1VLRA > 0 THEN NSY.NSY_V1VLRA ELSE NSY.NSY_V1VLR  END), 0))" //Se tiver dados de pedidos feito pela tela nova, soma a multa, honorário e encargo.
			cQuery +=                 " ELSE (CASE
			cQuery +=                          " WHEN NSY.NSY_TRVLRA > 0 THEN NSY.NSY_TRVLRA"
			cQuery +=                          " WHEN NSY.NSY_V2VLRA > 0 THEN NSY.NSY_V2VLRA"
			cQuery +=                          " WHEN NSY.NSY_V1VLRA > 0 THEN NSY.NSY_V1VLRA"
			cQuery +=                          " WHEN NSY.NSY_PEVLRA > 0 THEN NSY.NSY_PEVLRA"
			cQuery +=                          " END) "
			cQuery +=                     " END)), 0) ENVOLVIDO_ATUALIZADO, "
		Else
			//Valores normais
			cQuery +=	" ISNULL( "
			cQuery +=		" SUM ( "
			cQuery +=			" (CASE WHEN NSY.NSY_TRVLR > 0 THEN NSY.NSY_TRVLR "
			cQuery +=				  " WHEN NSY.NSY_V2VLR > 0 THEN NSY.NSY_V2VLR "
			cQuery +=				  " WHEN NSY.NSY_V1VLR > 0 THEN NSY.NSY_V1VLR "
			cQuery +=				  " WHEN NSY.NSY_PEVLR > 0 THEN NSY.NSY_PEVLR "
			cQuery +=			  "END) "
			cQuery +=		" ) "
			cQuery +=	", 0) ENVOLVIDO, "

			//Valores atualizados
			cQuery +=	" ISNULL( "
			cQuery +=		" SUM ( "
			cQuery +=			" (CASE WHEN NSY.NSY_TRVLRA > 0 THEN NSY.NSY_TRVLRA "
			cQuery +=				  " WHEN NSY.NSY_V2VLRA > 0 THEN NSY.NSY_V2VLRA "
			cQuery +=				  " WHEN NSY.NSY_V1VLRA > 0 THEN NSY.NSY_V1VLRA "
			cQuery +=				  " WHEN NSY.NSY_PEVLRA > 0 THEN NSY.NSY_PEVLRA "
			cQuery +=			  "END) "
			cQuery +=		" ) "
			cQuery +=	", 0) ENVOLVIDO_ATUALIZADO, "
		EndIf

		//Valores de Correção atualizados
		cQuery += " ISNULL( SUM( "
		cQuery +=             " (CASE WHEN NSY.NSY_CCORPE > 0 THEN NSY.NSY_CCORPE END)) "
		cQuery += ", 0) CORRECAO, "

		//Valores de juros atualizados
		cQuery += " ISNULL( SUM( "
		cQuery +=             " (CASE WHEN NSY.NSY_CJURPE > 0 THEN NSY.NSY_CJURPE END)) "
		cQuery += ", 0) JUROS"

		cQuery += " FROM " + RetSqlName("NSY") + " NSY "

		cQuery += " WHERE NSY.NSY_FILIAL = '" +cFilNsy+	  "' "
		cQuery +=    " AND NSY.NSY_CAJURI = '" +cProcesso+ "' "
		cQuery +=    " AND NSY.D_E_L_E_T_ = ' ' "

		aVlEnvolvi := JurSQL(cQuery, {"ENVOLVIDO", "ENVOLVIDO_ATUALIZADO", "CORRECAO", "JUROS"})

	EndIf

	RestArea( aAreaNSY )
	RestArea( aArea )

Return aVlEnvolvi

//------------------------------------------------------------------
/*/{Protheus.doc} JURNT9NSY
Consulta padrão de Envolvido do Objeto

@return lResult - Indica se foi indicado algum código
@author Jorge Luis Branco Martins Junior
@since 02/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNT9NSY()
	Local cSQL       := ""
	Local cTab       := "NT9"
	Local aCampos    := {{"NT9","NT9_COD"}, {"NT9","NT9_NOME"}, {"NQA","NQA_DESC"}}
	Local lVisualiza := .F.
	Local lInclui    := .F.
	Local cFonte     := ""
	Local nResult    := 0
	Local lResult    := .F.

	cSQL := " SELECT NT9.NT9_COD, NT9.NT9_NOME, COALESCE(NQA.NQA_DESC,'') NQA_DESC, NT9.R_E_C_N_O_ recno "
	cSQL +=   " FROM " + RetSqlName("NT9") + " NT9 "
	cSQL += " LEFT JOIN " + RetSqlName("NQA") + " NQA ON ( "
	cSQL +=     " NQA.NQA_COD = NT9.NT9_CTPENV AND "
	cSQL +=     " NQA_FILIAL = '" + xFilial("NQA") + "' AND "
	cSQL +=     " NQA.D_E_L_E_T_ = ' ' ) "
	cSQL += " WHERE "
	cSQL +=     " NT9.NT9_FILIAL = '" + xFilial("NT9") + "' AND "
	cSQL +=     " NT9.NT9_CAJURI = '" + M->NSY_CAJURI + "' AND "
	cSQL +=     " NT9.D_E_L_E_T_ = ' ' "

	nResult := JurF3SXB(cTab, aCampos, "", lVisualiza, lInclui, cFonte, cSQL)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		&(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J94ProgObj
Retorna o prognóstico a partir dos objetos, que será atualizado no processo.

@Param cFilProc - Filial do Processo
@Param cProcesso - Processo a ser filtrado
@Param cCmpVlr - Campo de valor a ser filtrado

@author  Rafael Tenorio da Costa
@since   23/06/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94ProgObj(cFilProc, cProcesso, cCmpVlr)

	Local aArea     := GetArea()
	Local aRetorno  := {}
	Local cQuery    := ""
	Local cProgObj  := ""
	Local cPrioProg := SuperGetMv("MV_JPRIPRG", .F., "1243")		//Prioridade de Prognóstico
	Local aProgn    := {}
	Local nI        := 0
	Local nIndProg  := 0

	Default cCmpVlr := "NSY_VLCONT"

	// Quebra as prioridades em Array
	For nI := 1 To Len(cPrioProg)
		aAdd(aProgn, SubStr(cPrioProg,nI, 1))
	Next

	//Retorna o prognóstico maior peso
	cQuery := " SELECT NSY_CPROG, NQ7_TIPO "
	cQuery += " FROM " + RetSqlName("NSY") + " NSY INNER JOIN " + RetSqlName("NQ7") + " NQ7"
	cQuery +=   " ON NQ7_FILIAL = '" + xFilial("NQ7") + "' AND NSY_CPROG = NQ7_COD"
	cQuery += " WHERE NSY_FILIAL = '" + cFilProc + "'"
	cQuery += 	" AND NSY_CAJURI = '" + cProcesso + "'"
	cQuery += 	" AND NSY.D_E_L_E_T_ = ' ' "

	If !Empty(cCmpVlr)
		cQuery +=   " AND (NSY.NSY_INECON = '1' OR NSY." + cCmpVlr + " > 0 )" // Filtra o campo de valor para não considerar os Pedidos gerados automaticamente pelo TOTVS LEGAL
	EndIf

	cQuery += " ORDER BY NQ7_TIPO, NSY_COD DESC" //Ordena pelo tipo do prognóstico 1=Provavel, 2=Possível, 3=Remoto

	aRetorno := JurSQL(cQuery, {"NSY_CPROG", "NQ7_TIPO"})

	// Loop para encontrar o Prognóstico
	For nI := 1 to Len(aProgn)
		nIndProg := aScan(aRetorno, {|x| x[2] == aProgn[nI]})
		// Se for maior do que zero, pega o código do Prog e Interrompe o Loop
		If (nIndProg > 0)
			cProgObj := aRetorno[nIndProg][1]
			Exit
		EndIf
	Next

	// Se o Prognóstico estiver vazio e o campo filtrado for o de Contigência, faz a busca pegando o valor do Pedido
	If Empty(cProgObj) .And. (cCmpVlr == "NSY_VLCONT")
		cProgObj := J94ProgObj(cFilProc, cProcesso, "NSY_PEVLR")
	EndIf

	RestArea( aArea )

Return cProgObj

//-------------------------------------------------------------------
/*/{Protheus.doc} J94FFluig
Valida alterações nos campos de valor e data dos valores
atualizáveis para ajustar o histórico conforme necessário.

@param 	oModel   Modelo de dados
@param 	cTabela   Tabela que está sendo alterada

@author Marcelo Araujo Dente
@since 07/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94FFluig(oModel, nOpc)

	Local lRet       := .T.
	Local lNZKInDic  := FWAliasInDic("NZK") //Verifica se existe a tabela NZK no Dicionário
	Local aDadFwApv  := {}
	Local cTipFwApv  := "6"
	Local cCodWf     := oModel:GetValue("NSYMASTER", "NSY_CODWF")
	Local lFCorrPed  := .F.
	Local lDtMultPd  := .F.
	Local lPeMultPd  := .F.
	Local lFCorrCon  := .F.
	Local lDtMultCo  := .F.
	Local lPeMultCo  := .F.

	//*********************************************************************************************************************
	// Gera follow-up e tarefas de follow-up para aprovacao no fluig quando nao for uma aprovacao do fluig
	//*********************************************************************************************************************
	If lNZKInDic .And. !IsInCallStack("JA106ConfNZK") .And. !IsInCallStack("JA95ZerPro") .And.;
	   !Empty( JurGetDados("NQS", 3, xFilial("NQS") + cTipFwApv, "NQS_COD") ) .AND.;
			( nOpc == MODEL_OPERATION_DELETE .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_CPROG") .Or.;
			  oModel:IsFieldUpdated("NSYMASTER", "NSY_PEVLR") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_VLCONT") .Or.;
			  oModel:IsFieldUpdated("NSYMASTER", "NSY_DTCONT") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_PEDATA") .Or.;
			  oModel:IsFieldUpdated("NSYMASTER", "NSY_DTJURO") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_DTMULT") .Or.;
			  oModel:IsFieldUpdated("NSYMASTER", "NSY_PERMUL") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_DTJURC") .Or.;
			  oModel:IsFieldUpdated("NSYMASTER", "NSY_DTMULC") .Or. oModel:IsFieldUpdated("NSYMASTER", "NSY_PERMUC") )

		//Verifica se ja existe tarefa de follow-up em aprovacao
		If !Empty(cCodWf) .And. J94FTarFw(xFilial("NSY"), cCodWf, "1|5|6", "4")
			JurMsgErro(	STR0041 ) //"Já existe follow-up para aprovação pendente. Não será possível prosseguir com a alteração."
			lRet := .F.
		Else
			lFCorrPed  := !Empty(FwFldGet("NSY_CCOMON")) .Or. !Empty(NSY->NSY_CCOMON)
			lPeMultPd  := !Empty(FwFldGet("NSY_PERMUL")) .Or. !Empty(NSY->NSY_PERMUL)
			lDtMultPd  := !Empty(FwFldGet("NSY_DTMULT")) .Or. !Empty(NSY->NSY_DTMULT)
			lFCorrCon  := !Empty(FwFldGet("NSY_CFCORC")) .Or. !Empty(NSY->NSY_CFCORC)
			lPeMultCo  := !Empty(FwFldGet("NSY_PERMUC")) .Or. !Empty(NSY->NSY_PERMUC)
			lDtMultCo  := !Empty(FwFldGet("NSY_DTMULC")) .Or. !Empty(NSY->NSY_DTMULC)
			//Verifica se alterou valor da provisao
			If FwFldGet("NSY_PEVLR") <> NSY->NSY_PEVLR  .Or. ;
					FwFldGet("NSY_VLCONT") <> NSY->NSY_VLCONT .Or. ;
					( FwFldGet("NSY_CPROG") <> NSY->NSY_CPROG .And. (FwFldGet("NSY_PEVLR") > 0 .Or. FwFldGet("NSY_VLCONT") > 0) ) .Or. ;
					( FwFldGet("NSY_PEDATA") <> NSY->NSY_PEDATA .And. lFCorrPed ) .Or. ;
					( FwFldGet("NSY_DTJURO") <> NSY->NSY_DTJURO .And. lFCorrPed ) .Or. ;
					( FwFldGet("NSY_DTMULT") <> NSY->NSY_DTMULT .And. lFCorrPed .And. lPeMultPd ) .Or. ;
					( FwFldGet("NSY_PERMUL") <> NSY->NSY_PERMUL .And. lFCorrPed .And. lDtMultPd ) .Or. ;
					( FwFldGet("NSY_DTCONT") <> NSY->NSY_DTCONT .And. lFCorrCon ) .Or. ;
					( FwFldGet("NSY_DTJURC") <> NSY->NSY_DTJURC .And. lFCorrCon ) .Or. ;
					( FwFldGet("NSY_DTMULC") <> NSY->NSY_DTMULC .And. lFCorrCon .And. lPeMultCo ) .Or. ;
					( FwFldGet("NSY_PERMUC") <> NSY->NSY_PERMUC .And. lFCorrCon .And. lDtMultCo )


				//Verifica se existe algum resultado de follow-up com o tipo 4=Em Aprovacao
				If lRet .And. Empty( JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") )	//NQN_FILIAL + NQN_TIPO
					JurMsgErro(STR0042)		//"Não existe resultado de follow-up com o tipo 4=Em Aprovacao cadastrado. Verifique o cadastro de resultados do follow-up!"
					lRet := .F.
				EndIf

				If lRet .And. (nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_INSERT)

					//Preenche o array com os dados para aprovação, se for inclusão manda tudo, senão apenas o que foi alterado
					If nOpc == MODEL_OPERATION_INSERT

						//Carrega as alterações que serão feitas quando for aprovada a alteracao do objeto
						Aadd( aDadFwApv, {"NSY_CPROG" , FwFldGet("NSY_CPROG") } )
						Aadd( aDadFwApv, {"NSY_PEINVL", FwFldGet("NSY_PEINVL")} )
						Aadd( aDadFwApv, {"NSY_INECON", FwFldGet("NSY_INECON")} )
						Aadd( aDadFwApv, {"NSY_PEDATA", FwFldGet("NSY_PEDATA")} )
						Aadd( aDadFwApv, {"NSY_DTJURO", FwFldGet("NSY_DTJURO")} )
						Aadd( aDadFwApv, {"NSY_DTMULT", FwFldGet("NSY_DTMULT")} )
						Aadd( aDadFwApv, {"NSY_PERMUL", FwFldGet("NSY_PERMUL")} )
						Aadd( aDadFwApv, {"NSY_DTCONT", FwFldGet("NSY_DTCONT")} )
						Aadd( aDadFwApv, {"NSY_DTJURC", FwFldGet("NSY_DTJURC")} )
						Aadd( aDadFwApv, {"NSY_DTMULC", FwFldGet("NSY_DTMULC")} )
						Aadd( aDadFwApv, {"NSY_PERMUC", FwFldGet("NSY_PERMUC")} )

						//Valor inestimável do objeto 2=Não
						If FwFldGet("NSY_PEINVL") == "2"
							Aadd( aDadFwApv, {"NSY_CMOPED", FwFldGet("NSY_CMOPED")} )
							Aadd( aDadFwApv, {"NSY_PEVLR" , FwFldGet("NSY_PEVLR" )} )
						EndIf

						//Valor inestimável da contigência 2=Não
						If FwFldGet("NSY_INECON") == "2"
							Aadd( aDadFwApv, {"NSY_CMOCON", FwFldGet("NSY_CMOCON")} )
							Aadd( aDadFwApv, {"NSY_VLCONT", FwFldGet("NSY_VLCONT")} )

							If oModel:GetModel("NSYMASTER"):HasField("NSY_VLREDU")
								Aadd( aDadFwApv, {"NSY_VLREDU", FwFldGet("NSY_VLREDU")} )
							EndIf
						EndIf

						Aadd( aDadFwApv, {"PROV_NTA", RetVlrApro(nOpc)} )	//Diferença de valor que será aprovada
					
					ElseIf nOpc == MODEL_OPERATION_UPDATE
							//Carrega as alterações que serão feitas quando for aprovada a alteracao do objeto
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_CPROG")
							Aadd( aDadFwApv, {"NSY_CPROG" , FwFldGet("NSY_CPROG") } )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_PEINVL")
							Aadd( aDadFwApv, {"NSY_PEINVL", FwFldGet("NSY_PEINVL")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_INECON")
							Aadd( aDadFwApv, {"NSY_INECON", FwFldGet("NSY_INECON")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_PEDATA")
							Aadd( aDadFwApv, {"NSY_PEDATA", FwFldGet("NSY_PEDATA")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_DTJURO")
							Aadd( aDadFwApv, {"NSY_DTJURO", FwFldGet("NSY_DTJURO")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_DTMULT")
							Aadd( aDadFwApv, {"NSY_DTMULT", FwFldGet("NSY_DTMULT")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_PERMUL")
							Aadd( aDadFwApv, {"NSY_PERMUL", FwFldGet("NSY_PERMUL")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_DTCONT")
							Aadd( aDadFwApv, {"NSY_DTCONT", FwFldGet("NSY_DTCONT")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_DTJURC")
							Aadd( aDadFwApv, {"NSY_DTJURC", FwFldGet("NSY_DTJURC")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_DTMULC")
							Aadd( aDadFwApv, {"NSY_DTMULC", FwFldGet("NSY_DTMULC")} )
						EndIf
						If oModel:IsFieldUpdated("NSYMASTER", "NSY_PERMUC")
							Aadd( aDadFwApv, {"NSY_PERMUC", FwFldGet("NSY_PERMUC")} )
						EndIf

						//Valor inestimável do objeto 2=Não
						If FwFldGet("NSY_PEINVL") == "2"
							If oModel:IsFieldUpdated("NSYMASTER", "NSY_CMOPED")
								Aadd( aDadFwApv, {"NSY_CMOPED", FwFldGet("NSY_CMOPED")} )
							EndIf
							If oModel:IsFieldUpdated("NSYMASTER", "NSY_PEVLR")
								Aadd( aDadFwApv, {"NSY_PEVLR" , FwFldGet("NSY_PEVLR" )} )
							EndIf
						EndIf

						//Valor inestimável da contigência 2=Não
						If FwFldGet("NSY_INECON") == "2"
							If oModel:IsFieldUpdated("NSYMASTER", "NSY_CMOCON")
								Aadd( aDadFwApv, {"NSY_CMOCON", FwFldGet("NSY_CMOCON")} )
							EndIf
							If oModel:IsFieldUpdated("NSYMASTER", "NSY_VLCONT")
								Aadd( aDadFwApv, {"NSY_VLCONT", FwFldGet("NSY_VLCONT")} )
							EndIf

							If oModel:GetModel("NSYMASTER"):HasField("NSY_VLREDU")
								If oModel:IsFieldUpdated("NSYMASTER", "NSY_VLREDU")
									Aadd( aDadFwApv, {"NSY_VLREDU", FwFldGet("NSY_VLREDU")} )
								EndIf
							EndIf
						EndIf

						Aadd( aDadFwApv, {"PROV_NTA", RetVlrApro(nOpc)} )	//Diferença de valor que será aprovada
					EndIf

					//Volta dados da provisao antes de alteracao
					If nOpc == MODEL_OPERATION_UPDATE

						oModel:LoadValue("NSYMASTER", "NSY_CPROG" , NSY->NSY_CPROG 	)

						oModel:LoadValue("NSYMASTER", "NSY_PEINVL", NSY->NSY_PEINVL	)
						oModel:LoadValue("NSYMASTER", "NSY_CMOPED", NSY->NSY_CMOPED	)
						oModel:LoadValue("NSYMASTER", "NSY_PEVLR" , NSY->NSY_PEVLR	)

						oModel:LoadValue("NSYMASTER", "NSY_INECON", NSY->NSY_INECON	)
						oModel:LoadValue("NSYMASTER", "NSY_CMOCON", NSY->NSY_CMOCON	)
						oModel:LoadValue("NSYMASTER", "NSY_VLCONT", NSY->NSY_VLCONT	)
						oModel:LoadValue("NSYMASTER", "NSY_PEDATA", NSY->NSY_PEDATA	)
						oModel:LoadValue("NSYMASTER", "NSY_DTJURO", NSY->NSY_DTJURO	)
						oModel:LoadValue("NSYMASTER", "NSY_DTMULT", NSY->NSY_DTMULT	)
						oModel:LoadValue("NSYMASTER", "NSY_PERMUL", NSY->NSY_PERMUL	)
						oModel:LoadValue("NSYMASTER", "NSY_DTCONT", NSY->NSY_DTCONT	)
						oModel:LoadValue("NSYMASTER", "NSY_DTJURC", NSY->NSY_DTJURC	)
						oModel:LoadValue("NSYMASTER", "NSY_DTMULC", NSY->NSY_DTMULC	)
						oModel:LoadValue("NSYMASTER", "NSY_PERMUC", NSY->NSY_PERMUC	)

						If oModel:GetModel("NSYMASTER"):HasField("NSY_VLREDU")
							oModel:LoadValue("NSYMASTER", "NSY_VLREDU", NSY->NSY_VLREDU	)
						EndIf
					Else

						oModel:ClearField("NSYMASTER", "NSY_CPROG"   )

						oModel:ClearField("NSYMASTER", "NSY_PEINVL"	)
						oModel:ClearField("NSYMASTER", "NSY_CMOPED"	)
						oModel:ClearField("NSYMASTER", "NSY_PEVLR"	)

						oModel:ClearField("NSYMASTER", "NSY_INECON"	)
						oModel:ClearField("NSYMASTER", "NSY_CMOCON"	)
						oModel:ClearField("NSYMASTER", "NSY_VLCONT"	)
						oModel:ClearField("NSYMASTER", "NSY_PEDATA"	)
						oModel:ClearField("NSYMASTER", "NSY_DTJURO"	)
						oModel:ClearField("NSYMASTER", "NSY_DTMULT"	)
						oModel:ClearField("NSYMASTER", "NSY_PERMUL"	)
						oModel:ClearField("NSYMASTER", "NSY_DTCONT"	)
						oModel:ClearField("NSYMASTER", "NSY_DTJURC"	)
						oModel:ClearField("NSYMASTER", "NSY_DTMULC"	)
						oModel:ClearField("NSYMASTER", "NSY_PERMUC"	)
					EndIf

					//Gera follow-up de aprovacao de Valor de Provisao ou Encerramento
					Processa( {| | lRet := J94FFwApv(oModel:GetValue("NSYMASTER", "NSY_CAJURI"), oModel:GetValue("NSYMASTER", "NSY_COD"), aDadFwApv, cTipFwApv, oModel)}, STR0043, "")	//"Gerando aprovação no Fluig"
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J94FFwApv
Gera follow-up de aprovacao
Uso geral.

@return	aCampos - Campos que seram gravados na NZK
@author Marcelo Araujo Dente
@since 07/02/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94FFwApv(cProcesso, cObjeto, aCampos, cTipoFwApr, oModelAtu)

	Local aArea      := GetArea()
	Local aAreaNTA   := NTA->( GetArea() )
	Local lRet       := .T.
	Local oModelFw   := Nil
	Local aTipoFw    := JurGetDados("NQS", 3, xFilial("NQS") + cTipoFwApr, {"NQS_COD", "NQS_DPRAZO"} )	//NQS_FILIAL + NQS_TAPROV	1=Alteracao Valor Provisao 2=Aprovacao de despesas 3=Aprovacao de Garantias 4=Aprovacao de Levantamento 5=Encerramento
	Local cTipoFw    := ""
	Local nDiaPrazo  := 0
	Local cResultFw  := JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD")					//NQN_FILIAL + NQN_TIPO		4=Em Aprovacao
	Local cPart      := JurUsuario(__cUserId)
	Local cSigla     := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")				//RD0_FILIAL + RD0_CODIGO
	Local aNTA       := {}
	Local aNTE       := {}
	Local aNZK       := {}
	Local aNZM       := {}
	Local aAux       := {}
	Local nCont      := 0
	Local nReg       := 0
	Local nOpc       := oModelAtu:GetOperation()
	Local cConteudo  := ""
	Local aErroNTA   := {}
	Local cNQNTipoF  := ""  //Variável que vai guardar o tipo do resultado após incluir o WF no FLUIG
	Local cCodWF     := FwFldGet("NSY_CODWF")
	Local lPendente  := !Empty(cCodWf) .And. J94FTarFw(xFilial("NSY"), cCodWf, "6", "1")
	Local nOpcFw     := 3
	Local cDesc      := ""
	Local nPosValNTA := Ascan(aCampos,{|x| x[1] == "PROV_NTA"})
	Local nValorNTA  := 0				//Valor que será enviado para aprovação
	Local cProgAtual := ""
	Local nPosProgAp := Ascan(aCampos, {|x| x[1] == "NSY_CPROG"})
	Local cProgAprov := ''
	Local cInesObAtu := "2"
	Local nVlrObjAtu := 0
	Local nPosInObAp := Ascan(aCampos, {|x| x[1] == "NSY_PEINVL"})
	Local cInesObApr := ''

	Local nPosDtPdAp := Ascan(aCampos, {|x| x[1] == "NSY_PEDATA"})
	Local dPedidoApr := ''
	Local dPedidoAtu := SToD("")

	Local nPosDtJPAp := Ascan(aCampos, {|x| x[1] == "NSY_DTJURO"})
	Local dJurPedApr := ''
	Local dJurPedAtu := SToD("")

	Local nPosDtMPAp := Ascan(aCampos, {|x| x[1] == "NSY_DTMULT"})
	Local dMulPedApr := ''
	Local dMulPedAtu := SToD("")

	Local nPosPoMPAp := Ascan(aCampos, {|x| x[1] == "NSY_PERMUL"})
	Local cPoMuPdApr := ''
	Local cPoMuPdAtu := ""

	Local nPosDtCtAp := Ascan(aCampos, {|x| x[1] == "NSY_DTCONT"})
	Local dContigApr := ''
	Local dContigAtu := SToD("")
	
	Local nPosDtJCAp := Ascan(aCampos, {|x| x[1] == "NSY_DTJURC"})
	Local dJurConApr := ''
	Local dJurConAtu := SToD("")
	
	Local nPosDtMCAp := Ascan(aCampos, {|x| x[1] == "NSY_DTMULC"})
	Local dMulConApr := ''
	Local dMulConAtu := SToD("")
	
	Local nPosPoMCAp := Ascan(aCampos, {|x| x[1] == "NSY_PERMUC"})
	Local cPoMuCoApr := 0
	Local cPoMuCoAtu := ""

	Local nPosVlObAp := Ascan(aCampos, {|x| x[1] == "NSY_PEVLR"})
	Local nVlrObjApr := 0
	Local cInesCoAtu := "2"
	Local nVlrConAtu := 0
	Local nPosInCoAp := Ascan(aCampos, {|x| x[1] == "NSY_INECON"})
	Local cInesCoApr := ''
	Local nPosVlCoAp := Ascan(aCampos, {|x| x[1] == "NSY_VLCONT"})
	Local nVlrConApr := 0
	Local dDataFup   := DataValida(Date(),.T.)

	ProcRegua(0)
	IncProc()
	IncProc()

	//Carerga follow-up
	If !Empty(aTipoFw)
		cTipoFw		:= aTipoFw[1]
		nDiaPrazo	:= Val( aTipoFw[2] ) //Verificar se o campo NQS_DPRAZO sera mesmo caracter
	EndIf

	//Carrega campos atuais
	If nOpc == MODEL_OPERATION_UPDATE
		cProgAtual := JurGetDados("NQ7", 1, xFilial("NQ7") + NSY->NSY_CPROG, "NQ7_DESC")
		cInesObAtu := NSY->NSY_PEINVL
		cInesCoAtu := NSY->NSY_INECON
		nVlrObjAtu := NSY->NSY_PEVLR
		nVlrConAtu := NSY->NSY_VLCONT
		dPedidoAtu := NSY->NSY_PEDATA
		dJurPedAtu := NSY->NSY_DTJURO
		dMulPedAtu := NSY->NSY_DTMULT
		cPoMuPdAtu := NSY->NSY_PERMUL
		dContigAtu := NSY->NSY_DTCONT
		dJurConAtu := NSY->NSY_DTJURC
		dMulConAtu := NSY->NSY_DTMULC
		cPoMuCoAtu := NSY->NSY_PERMUC
	EndIf

	cDesc := STR0049 + JurGetDados("NSP", 1, xFilial("NSP") + FwFldGet("NSY_CPEVLR"), "NSP_DESC")	//"Aprovação de Alteração no Objeto: "

	If nPosValNTA > 0
		nValorNTA := aCampos[nPosValNTA][2]
		cDesc += CRLF + STR0051 + AllTrim( Transform(nValorNTA , "@E 99,999,999,999.99") )			//"Valor para aprovação: "
	EndIf

	cDesc += CRLF + STR0053 + cProgAtual															//"Prognóstico atual: "
	
	If nPosProgAp > 0
		cProgAprov := JurGetDados("NQ7", 1, xFilial("NQ7") + aCampos[nPosProgAp][2], "NQ7_DESC")
		cDesc += CRLF + STR0054 + cProgAprov														//"Prognóstico após aprovação: "
	EndIF

	cDesc += CRLF + STR0063 + Iif(Empty(dPedidoAtu), "", JSToFormat(dPedidoAtu, "dd/mm/yyyy"))		//"Data do pedido atual: "
	if nPosDtPdAp > 0
		dPedidoApr := aCampos[nPosDtPdAp][2]
		cDesc += CRLF + STR0064 + Iif(Empty(dPedidoApr), "", JSToFormat(dPedidoApr, "dd/mm/yyyy"))	//"Data do pedido após aprovação: "
	EndIf
	
	cDesc += CRLF + STR0067 + Iif(Empty(dJurPedAtu), "", JSToFormat(dJurPedAtu, "dd/mm/yyyy"))		//"Data de juros do pedido atual: "
	If nPosDtJPAp > 0
		dJurPedApr := aCampos[nPosDtJPAp][2]
		cDesc += CRLF + STR0068 + Iif(Empty(dJurPedApr), "", JSToFormat(dJurPedApr, "dd/mm/yyyy"))	//"Data de juros do pedido após aprovação: "
	EndIf

	cDesc += CRLF + STR0069 + Iif(Empty(dMulPedAtu), "", JSToFormat(dMulPedAtu, "dd/mm/yyyy"))		//"Data de multa do pedido atual: "
	If nPosDtMPAp > 0
		dMulPedAprv := aCampos[nPosDtMPAp][2]
		cDesc += CRLF + STR0070 + Iif(Empty(dMulPedApr), "", JSToFormat(dMulPedApr, "dd/mm/yyyy"))	//"Data de multa do pedido após aprovação: "
	EndIf
	
	cDesc += CRLF + STR0075 + AllTrim(cPoMuPdAtu) + Iif(!Empty(cPoMuPdAtu), "%", "")				//"Porcentagem de multa do pedido atual: "
	If nPosPoMPAp > 0
		cPoMuPdApr := aCampos[nPosPoMPAp][2]
		cDesc += CRLF + STR0076 + AllTrim(cPoMuPdApr) + Iif(!Empty(cPoMuPdApr), "%", "")			//"Porcentagem de multa do pedido após aprovação: "
	EndIf

	cDesc += CRLF + STR0057 + JurInfBox("NSY_PEINVL", cInesObAtu)									//"Objeto inestimável atual: "
	If nPosInObAp > 0
		cInesObApr := aCampos[nPosInObAp][2]
		cDesc += CRLF + STR0058 + JurInfBox("NSY_PEINVL", cInesObApr)								//"Objeto inestimável após aprovação: "
	EndIf

	cDesc += CRLF + STR0055 + AllTrim( Transform(nVlrObjAtu, "@E 99,999,999,999.99") )				//"Objeto atual: "
	If nPosVlObAp > 0
		nVlrObjApr := aCampos[nPosVlObAp][2]
		cDesc += CRLF + STR0056 + AllTrim( Transform(nVlrObjApr, "@E 99,999,999,999.99") )			//"Objeto após aprovação: "
	EndIf

	cDesc += CRLF + STR0059 + JurInfBox("NSY_INECON", cInesCoAtu)									//"Contingência inestimável atual: "
	If nPosInCoAp > 0
		cInesCoApr := aCampos[nPosInCoAp][2]
		cDesc += CRLF + STR0060 + JurInfBox("NSY_INECON", cInesCoApr)								//"Contingência inestimável após aprovação: "
	EndIf

	cDesc += CRLF + STR0050 + AllTrim( Transform(nVlrConAtu, "@E 99,999,999,999.99") )				//"Contingência atual: "
	If nPosVlCoAp > 0
		nVlrConApr := aCampos[nPosVlCoAp][2]
		cDesc += CRLF + STR0052 + AllTrim( Transform(nVlrConApr, "@E 99,999,999,999.99") )			//"Contingência após aprovação: "
	EndIf

	cDesc += CRLF + STR0065 + Iif(Empty(dContigAtu), "", JSToFormat(dContigAtu, "dd/mm/yyyy"))		//"Data de contingência atual: "
	If nPosDtCtAp > 0
		dContigApr := aCampos[nPosDtCtAp][2]
		cDesc += CRLF + STR0066 + Iif(Empty(dContigApr), "", JSToFormat(dContigApr, "dd/mm/yyyy"))	//"Data de contingência após aprovação: "
	EndIf

	cDesc += CRLF + STR0071 + Iif(Empty(dJurConAtu), "", JSToFormat(dJurConAtu, "dd/mm/yyyy"))		//"Data de juros de contingência atual: "
	If nPosDtJCAp > 0
		dJurConApr := aCampos[nPosDtJCAp][2]
		cDesc += CRLF + STR0072 + Iif(Empty(dJurConApr), "", JSToFormat(dJurConApr, "dd/mm/yyyy"))	//"Data de juros de contingência após aprovação: "
	EndIf
	
	cDesc += CRLF + STR0073 + Iif(Empty(dMulConAtu), "", JSToFormat(dMulConAtu, "dd/mm/yyyy"))		//"Data de multa de contingência atual: "
	If nPosDtMCAp >0
		dMulConApr := aCampos[nPosDtMCAp][2]
		cDesc += CRLF + STR0074 + Iif(Empty(dMulConApr), "", JSToFormat(dMulConApr, "dd/mm/yyyy"))	//"Data de multa de contingência após aprovação: "
	EndIf
	
	cDesc += CRLF + STR0077 + AllTrim(cPoMuCoAtu) + Iif(!Empty(cPoMuCoAtu), "%", "")				//"Porcentagem de multa de contingência atual: "     
	If nPosPoMCAp > 0
		cPoMuCoApr := aCampos[nPosPoMCAp][2]
		cDesc += CRLF + STR0078 + AllTrim(cPoMuCoApr) + Iif(!Empty(cPoMuCoApr), "%", "")			//"Porcentagem de multa de contingência após aprovação: "
	EndIf



	//Ja existe follow-up pendente e já esta posicionado
	If lPendente
		nOpcFw    := 4
		cResultFw := JurGetDados("NQN", 3, xFilial("NQN") + "2", "NQN_COD")	//NQN_FILIAL + NQN_TIPO 2=Concluido
		cDesc     := AllTrim(cDesc) + CRLF + Replicate("-", 5) + CRLF + AllTrim(NTA->NTA_DESC)

		aAdd(aNZM, {"NZM_CODWF"	, AllTrim(NTA->NTA_CODWF)})
		aAdd(aNZM, {"NZM_CAMPO"	, "sObsExecutor"		 })
		aAdd(aNZM, {"NZM_CSTEP"	, "16"					 })
		aAdd(aNZM, {"NZM_STATUS", "2"					 })
	EndIf

	Aadd(aNTA, {"NTA_CAJURI", cProcesso         } )
	Aadd(aNTA, {"NTA_CTIPO" , cTipoFw           } )
	Aadd(aNTA, {"NTA_DTFLWP", dDataFup          } )
	Aadd(aNTA, {"NTA_CRESUL", cResultFw         } )
	Aadd(aNTA, {"NTA__VALOR", Abs( nValorNTA )  } )
	Aadd(aNTA, {"NTA_DESC"  , cDesc             } )

	//Carerga participante
	Aadd(aNTE, {"NTE_SIGLA", cSigla} )
	Aadd(aNTE, {"NTE_CPART", cPart } )

	//Carrega Tarefas do Follow-up
	For nCont:=1 To Len( aCampos )

		If aCampos[nCont][1] <> "PROV_NTA" // Como é um campo de valor de aprovação que é usado na NTA, não é necessário incluir na NZK

			Do Case
			Case ValType( aCampos[nCont][2] ) == "D"
				cConteudo := DtoS( aCampos[nCont][2] )

			Case ValType( aCampos[nCont][2] ) == "N"
				cConteudo := cValToChar( aCampos[nCont][2] )

			OtherWise
				cConteudo := aCampos[nCont][2]
			End Case

			aAux := {}
			
			Aadd(aAux, {"NZK_STATUS", "1"								  } )	//1=Em Aprovacao
			Aadd(aAux, {"NZK_FONTE"	, "JURA094"							  } )
			Aadd(aAux, {"NZK_MODELO", "NSYMASTER"						  } )
			Aadd(aAux, {"NZK_CAMPO" , aCampos[nCont][1]					  } )
			Aadd(aAux, {"NZK_VALOR" , cConteudo							  } )
			Aadd(aAux, {"NZK_CHAVE" , xFilial("NSY") + cObjeto + cProcesso} )	//NSY_FILIAL+NSY_COD+NSY_CAJURI

			Aadd(aNZK, aAux)

		EndIf
	Next nCont

	//Prepara follow-up para inclusao
	oModelFw := FWLoadModel("JURA106")
	oModelFw:SetOperation(nOpcFw)
	oModelFw:Activate()

	//Atualiza follow-up
	For nCont:=1 To Len( aNTA )

		If aNTA[nCont][1] == "NTA_CAJURI"

			If nOpcFw == 3
				oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			EndIf

			Loop
		EndIf

		If aNTA[nCont][1] == "NTA_CRESUL"

			If nOpcFw == 4
				oModelFw:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			Else
				If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Else
			If !( oModelFw:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nCont

	If lRet

		If nOpcFw == 3 //Somente se for uma inclusão
			//Atualiza participante
			For nCont:=1 To Len( aNTE )
				If !( oModelFw:SetValue("NTEDETAIL", aNTE[nCont][1], aNTE[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

		If nOpcFw == 4 //Somente se for uma alteração
			//Atualiza participante
			For nCont:=1 To Len( aNZM )
				If !( oModelFw:SetValue("NZMDETAIL", aNZM[nCont][1], aNZM[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf

		If lRet

			//Atualiza tarefas do follow-up
			For nReg:=1 To Len( aNZK )

				If nReg > 1
					oModelFw:GetModel("NZKDETAIL"):AddLine()
				EndIf

				For nCont:=1 To Len( aNZK[nReg] )
					If !( oModelFw:SetValue("NZKDETAIL", aNZK[nReg][nCont][1], aNZK[nReg][nCont][2]) )
						lRet := .F.
						Exit
					EndIf
				Next nCont
			Next nReg

			//Inclui follow-up
			If lRet
				If ( lRet := oModelFw:VldData() )
					lRet := oModelFw:CommitData()
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet

		cCodWF := oModelFw:GetValue("NTAMASTER", "NTA_CODWF")

		//valida se o follow-up está concluído ou em aprovação
		cNQNTipoF := JurGetDados('NQN',1,xFilial('NQN')+oModelFw:GetValue("NTAMASTER","NTA_CRESUL"),"NQN_TIPO")

		if (cNQNTipoF == "2")
			//Volta os valores pois o FW foi concluído.
			For nCont := 1 to Len(aCampos)
				If aCampos[nCont][1] != "PROV_NTA"
					oModelAtu:LoadValue("NSYMASTER",aCampos[nCont][1],aCampos[nCont][2])
				Endif
			Next
		Else
			//Exibe mensagem de aprovação
			ApMsgInfo(	STR0044 + CRLF + CRLF +;	//"Aprovação enviada para o FLUIG." *****
			STR0045 , ProcName(0) )		//"Os dados alterados serão atualizados quando a aprovação for concluída." *****
		Endif
	Else

		aErroNTA := oModelFw:GetErrorMessage()
	EndIf

	oModelFw:DeActivate()
	oModelFw:Destroy()

	FWModelActive( oModelAtu )
	oModelAtu:Activate()

	If lRet
		oModelAtu:LoadValue("NSYMASTER", "NSY_CODWF", cCodWF)
	Else

		//Seta erro no modelo atual para retornar mensagem
		If Len(aErroNTA) > 0
			oModelAtu:SetErrorMessage(aErroNTA[1]			 	  , aErroNTA[2], aErroNTA[3], aErroNTA[4] 	, aErroNTA[5],;
				STR0046 + CRLF + aErroNTA[6], aErroNTA[7], /*xValue*/ , /*xOldValue*/ )	//"Não foi possível incluír o follow-up de aprovação. Verifique!"
		EndIf
	EndIf

	RestArea(aAreaNTA)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J94FTarFw
Consulta o follow-up por tipo de aprovação e resultado a partir do código do workflow do fluig.
Encontrando posiciona no follow-up.
Uso geral.

@param	cFilCod		- Código da filial que
@param	cCodWf		- Código do workflow gerado no fluig com relação ao follow-up
@param	cTipFwApv	- Código do tipo da aprovação relacionada ao tipo do follow-up
@param  cTipoResul	- Código do resultado do follow-up
@return	lRetorno 	- Informando se existe ou nao tarefa de follow-up.

@author Rafael Tenorio da Costa
@since  05/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J94FTarFw(cFilCod, cCodWf, cTipFwApv, cTipoResul)

	Local aArea		:= GetArea()
	Local lRetorno	:= .F.
	Local cQuery	:= ""

	cQuery := " SELECT NTA_FILIAL, NTA_COD"
	cQuery += " FROM " +RetSqlName("NTA")+ " NTA"
	cQuery += " INNER JOIN " +RetSqlName("NQS")+ " NQS"
	cQuery +=	" ON NQS_FILIAL = '" +xFilial("NQS")+ "' AND NTA_CTIPO = NQS_COD"
	cQuery += " INNER JOIN " +RetSqlName("NQN")+ " NQN"
	cQuery += 	" ON NQN_FILIAL = '" +xFilial("NQN")+ "' AND NTA_CRESUL = NQN_COD"
	cQuery += " WHERE NTA_FILIAL = '" + xFilial("NTA")	+ "'"
	cQuery += 	" AND NTA_CODWF  = '" + cCodWf			+ "'"
	cQuery += 	" AND NQS_TAPROV IN " + FormatIn(cTipFwApv , "|")	//1=Alteracao Valor Provisao; 2=Aprovacao de despesas; 3=Aprovacao de Garantias; 4=Aprovacao de Levantamento; 5=Encerramento; 6=Aprovação de Objeto
	cQuery += 	" AND NQN_TIPO IN "   + FormatIn(cTipoResul, "|")	//1=Pendente; 2=Concluido; 3=Cancelado; 4=Em Aprovacao
	cQuery += 	" AND NTA.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NQS.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NQN.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY NTA_COD DESC"

	aRetorno := JurSQL(cQuery, "*")

	If Len(aRetorno) > 0

		//Posiciona no follow-up que será utilizado
		DbSelectArea("NTA")
		NTA->( DbSetOrder(1) )	//NTA_FILIAL + NTA_COD
		lRetorno := NTA->( DbSeek(aRetorno[1][1] + aRetorno[1][2]) )
	EndIf

	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuVlrPro
Atualiza valores DO Processo provisão\envolvido.

@param 	oModel - Modelo de dados do JURA094

@author  Rafael Tenorio da Costa
@since 	 02/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuVlrPro(oModel)

	Local aArea      := GetArea()
	Local aAreaNSZ   := NSZ->( GetArea() )
	Local cFilProc   := xFilial("NSY")
	Local cProcesso  := oModel:GetValue("NSYMASTER", "NSY_CAJURI")
	Local cPrognost  := ""
	Local nVlrPro    := 0
	Local nVlrProAtu := 0
	Local aVlEnvolvi := {}
	Local dData      := Date()
	Local cMoeCod    := SuperGetMv("MV_JCMOPRO", .F., "01")			//Código da moeda utilizada nos valores envolvidos\provisão no processo quando estes valores vierem dos objetos
	Local oMdl95     := Nil
	Local lRet       := .F.
	Local aVlrPro    := {}
	Local nVCProAtu  := 0
	Local nVJProAtu  := 0

	//Busca prognóstico dos objetos
	cPrognost  := J94ProgObj(cFilProc, cProcesso)

	//Busca valor provavel
	nVlrPro    := JA094VlDis(cProcesso, "1", .F.)

	//Busca valor provavel atualizado
	aVlrPro := JA094VlDis(cProcesso, "1", .T.,,.T.)
	nVlrProAtu := aVlrPro[1][1] // Valor atualizado
	nVCProAtu  := aVlrPro[1][2] //Valor de correção Atualizado
	nVJProAtu  := aVlrPro[1][3] //Valor de Juros Atualizado

	//Busca valores envolvidos
	aVlEnvolvi := JA094VlEnv(cProcesso, cFilProc)

	oMdl95 := FWLoadModel("JURA095")
	oMdl95:SetOperation(4)
	oMdl95:Activate()

	DbSelectArea("NSZ")
	NSZ->( DbSetOrder(1) )  //-- NSZ_FILIAL + NSZ_COD

	//-- Atualiza as informações nos campos do processo - NSZ
	If NSZ->( DbSeek(cFilProc + cProcesso) )

		If !Empty(cPrognost)
			oMdl95:LoadValue("NSZMASTER", "NSZ_CPROGN", cPrognost)
		EndIf

		oMdl95:LoadValue("NSZMASTER", "NSZ_VLPROV", nVlrPro      )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VAPROV", nVlrProAtu   )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VCPROV", nVCProAtu   )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VJPROV", nVJProAtu   )

		If nVlrPro > 0
			oMdl95:LoadValue("NSZMASTER", "NSZ_DTPROV", dData    )
			oMdl95:LoadValue("NSZMASTER", "NSZ_CMOPRO", cMoeCod  )
		Else
			oMdl95:LoadValue("NSZMASTER", "NSZ_DTPROV", CtoD("") )
			oMdl95:LoadValue("NSZMASTER", "NSZ_CMOPRO", "" )
		EndIf

		oMdl95:LoadValue("NSZMASTER", "NSZ_VLENVO", aVlEnvolvi[1][1] )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VAENVO", aVlEnvolvi[1][2] )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VCENVO", aVlEnvolvi[1][3] )
		oMdl95:LoadValue("NSZMASTER", "NSZ_VJENVO", aVlEnvolvi[1][4] )

		If aVlEnvolvi[1][1] > 0
			oMdl95:LoadValue("NSZMASTER", "NSZ_DTENVO", dData     )
			oMdl95:LoadValue("NSZMASTER", "NSZ_CMOENV", cMoeCod   )
		Else
			oMdl95:LoadValue("NSZMASTER", "NSZ_DTENVO", CtoD("")  )
			oMdl95:LoadValue("NSZMASTER", "NSZ_CMOENV", "" )
		EndIf

		//-- Prognostico 1= Provavel
		If NSZ->( FieldPos('NSZ_VRDPRO') ) > 0
			oMdl95:LoadValue("NSZMASTER", "NSZ_VRDPRO", JA94CALRED(cProcesso,,'1') )
		EndIf

		//-- Prognostico 2= Possivel
		If NSZ->( FieldPos('NSZ_VRDPOS') ) > 0
			oMdl95:LoadValue("NSZMASTER", "NSZ_VRDPOS", JA94CALRED(cProcesso,,'2') )
		EndIf

		//-- Prognostico 3= Remoto
		If NSZ->( FieldPos('NSZ_VRDREM') ) > 0
			oMdl95:LoadValue("NSZMASTER", "NSZ_VRDREM", JA94CALRED(cProcesso,,'3') )
		EndIf
	EndIf

	lRet := oMdl95:VldData()

	If lRet
		lRet := oMdl95:CommitData()
	EndIf

	RestArea(aAreaNSZ)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetVlrApro
Retorna a maior diferença de valores do Objeto ou Contigencia

@param 	nOpc - Operação

@author  Rafael Tenorio da Costa
@since 	 23/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetVlrApro(nOpc)

	Local nValorDif := 0
	Local nObjDif 	:= 0
	Local nConDif 	:= 0

	If nOpc == MODEL_OPERATION_INSERT

		If FwFldGet("NSY_PEVLR") > FwFldGet("NSY_VLCONT")
			nValorDif := FwFldGet("NSY_PEVLR")
		Else
			nValorDif := FwFldGet("NSY_VLCONT")
		EndIf
	Else

		nObjDif := Abs(FwFldGet("NSY_PEVLR") - NSY->NSY_PEVLR)
		nConDif := Abs(FwFldGet("NSY_VLCONT") - NSY->NSY_VLCONT)

		If nObjDif > nConDif
			nValorDif := FwFldGet("NSY_PEVLR") - NSY->NSY_PEVLR
		Else
			nValorDif := FwFldGet("NSY_VLCONT") - NSY->NSY_VLCONT
		EndIf
	EndIf

Return nValorDif

//-------------------------------------------------------------------
/*/{Protheus.doc} JA94CALRED
Calcula o percentual do redutor

@param cCajuri   Código do Assunto Juridico
@param cCodObj   Código do Objeto
@param cProg     Tipo do Prognóstico 1= Provavel/2= Possivel/3=Remoto
@param cVlProv   Parametro que Define de onde será pego o valor de prov 1 = Processo / 2 = Objetos
@param cFilNsz   Filial do processo
@param cFaseProc Fase processual do processo
@param lAtuRed   Indica se atualiza os redutores na NSY

@author  Beatriz Gomes
@since   22/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA94CALRED(cCajuri, cCodObj, cProg, cVlProv, cFilNsz, cFaseProc, lAtuRed )
Local aArea      := GetArea()
Local aAreaNSY   := NSY->( GetArea() )
Local cQuery     := " SELECT "
Local cAlias     := GetNextAlias()
Local cData      := DtoS(dDataBase)
Local cTamTipoAs := Space(TamSx3("O0Q_TIPOAS")[1])
Local cTamAreaJ  := Space(TamSx3("O0Q_CAREAJ")[1])
Local cTamObjet  := Space(TamSx3("O0Q_COBJET")[1])
Local lRedutFase := .F.
Local cPercRedut := "O0Q.O0Q_PERCRE"
Local lPedidos   := .F.
local xRet       := Nil

Default cProg      := ''
Default cCodObj    := ''
Default cVlProv    := '2'
Default cFilNsz    := xFilial("NSZ")
Default cFaseProc  := JURA100Fase(cCajuri,cFilNsz,.T.) //pega o código da fase processual do processo para avaliar se ela possui restrição para redutor
Default lAtuRed    := .F.

	If lAtuRed
		xRet := {}
	Else
		xRet := 0
	End

	//Verifica se existe a tabela O0Q - Redutores
	If FWAliasInDic("O0Q")

		// Verificação do campo de "Considera Redutor"
		DbSelectArea("NQG")

		If ColumnPos("NQG_CONRED") > 0
			lRedutFase := JurGetDados("NQG",1,xFilial("NQG")+cFaseProc,"NQG_CONRED") == "2" // Utiliza a negação pois o campo pode estar em Branco

			// Se não for para considera a Fase Atual no Calculo, força os 100%
			If lRedutFase
				cPercRedut := "100"
			EndIf
		EndIf

		NQG->( DBCloseArea() )

		//Verifica se a rotina de Pedidos foi implementada
		If Select("NSY") > 0
			lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
		Else
			DBSelectArea("NSY")
			lPedidos := NSY->( FieldPos('NSY_CVERBA') ) > 0
			NSY->( DBCloseArea() )
		EndIf

		If lAtuRed
			cQuery +=    " NSY_COD, "
		EndIf

		cQuery +=        " VLRREDUT,"
		cQuery +=        " ( CASE WHEN O0Q_TIPOAS = '" + cTamTipoAs + "' THEN 0 ELSE 1 END +"
		cQuery +=          " CASE WHEN O0Q_CAREAJ = '" + cTamAreaJ  + "' THEN 0 ELSE 1 END +"
		cQuery +=          " CASE WHEN O0Q_COBJET = '" + cTamObjet  + "' THEN 0 ELSE 1 END"
		cQuery +=        " ) ORDEM"

		cQuery +=   " FROM ( SELECT "

		If cVlProv == '2' .OR. !Empty(cCodObj)

			If lPedidos

				If lAtuRed
					cQuery +=     " NSY_COD, "
				EndiF

				cQuery +=        "SUM( CASE WHEN NSY_CVERBA <> '' THEN ( "
				cQuery +=                 "   COALESCE( (CASE WHEN NSY_DTCONT > ''  THEN NSY_VLCONA ELSE NSY_PEVLRA END), 0)"
				cQuery +=                 " + COALESCE( (CASE WHEN NSY_TRVLRA > 0 THEN NSY_TRVLRA ELSE NSY_TRVLR  END), 0)"
				cQuery +=                 " + COALESCE( (CASE WHEN NSY_MUATT  > 0 THEN NSY_MUATT  ELSE NSY_VLRMT  END), 0)"
				cQuery +=                 " + COALESCE( (CASE WHEN NSY_V2VLRA > 0 THEN NSY_V2VLRA ELSE NSY_V2VLR  END), 0)"
				cQuery +=                 " + COALESCE( (CASE WHEN NSY_MUATU2 > 0 THEN NSY_MUATU2 ELSE NSY_VLRMU2 END), 0)"
				cQuery +=                 " + COALESCE( (CASE WHEN NSY_V1VLRA > 0 THEN NSY_V1VLRA ELSE NSY_V1VLR  END), 0))" //Se tiver dados de pedidos feito pela tela nova, soma a multa, honorário e encargo.
				cQuery +=                 " * (COALESCE( (CASE WHEN NSY.NSY_REDUT = '1' THEN " + cPercRedut +   " END), 100) / 100 ) "
				cQuery +=             " ELSE( CASE "
				cQuery +=                          " WHEN NSY.NSY_REDUT = '1' AND NSY.NSY_DTCONT > ' ' "
				cQuery +=                               "THEN ( NSY.NSY_VLCONA * (COALESCE(" + cPercRedut + ", 100) / 100) )" //Se não houver % Redutor, o calculo é feito 100% do valor
				cQuery +=                          " WHEN NSY.NSY_REDUT = '1' AND NSY.NSY_DTCONT = ' ' "
				cQuery +=                               "THEN ( NSY.NSY_PEVLRA * (COALESCE(" + cPercRedut + ", 100) / 100) )" //Se não houver valor de contingência preenchido
				cQuery +=                          " WHEN NSY.NSY_DTCONT = ' ' "
				cQuery +=                               "THEN NSY.NSY_PEVLRA"
				cQuery +=                          " ELSE NSY.NSY_VLCONA"
				cQuery +=                    " END) "
			Else

				If lAtuRed
					cQuery += " NSY_COD, "
				EndiF

				cQuery +=             "SUM( CASE WHEN NSY.NSY_REDUT = '1' AND NSY.NSY_DTCONT > ' ' "
				cQuery +=                           "THEN ( NSY.NSY_VLCONA * (COALESCE(" + cPercRedut + ", 100) / 100) )" //Se não houver % Redutor, o calculo é feito 100% do valor
				cQuery +=                      " WHEN NSY.NSY_REDUT = '1' AND NSY.NSY_DTCONT = ' ' "
				cQuery +=                           "THEN ( NSY.NSY_PEVLRA * (COALESCE(" + cPercRedut + ", 100) / 100) )" //Se não houver valor de contingência preenchido
				cQuery +=                      " WHEN NSY.NSY_DTCONT = ' ' "
				cQuery +=                           "THEN NSY.NSY_PEVLRA"
				cQuery +=                      " ELSE NSY.NSY_VLCONA"
			EndIf
			cQuery +=              " END ) VLRREDUT,"

			cQuery +=             " COALESCE(O0Q.O0Q_TIPOAS, '" + cTamTipoAs + "') O0Q_TIPOAS,"
			cQuery +=             " COALESCE(O0Q.O0Q_CAREAJ, '" + cTamAreaJ  + "') O0Q_CAREAJ,"
			cQuery +=             " COALESCE(O0Q.O0Q_COBJET, '" + cTamObjet  + "') O0Q_COBJET"

			cQuery +=        " FROM " + RetSqlName("NSY") + " NSY

			If !Empty(cProg)
				cQuery +=  " INNER JOIN " + RetSqlName("NQ7") + " NQ7 ON (NQ7_FILIAL = '" + xFilial("NQ7") + "'"
				cQuery +=                                               " AND NSY.NSY_CPROG  = NQ7_COD"
				cQuery +=                                               " AND NQ7.NQ7_TIPO = '"+cProg+"'" //1=Provavel;2=Possivel;3=Remoto
				cQuery +=                                               " AND NSY.D_E_L_E_T_ = NQ7.D_E_L_E_T_)"
			EndIf

			cQuery +=      " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON ( NSZ.NSZ_FILIAL = '" + cFilNsz + "' "
			cQuery +=                                                    " AND NSZ.NSZ_COD = '" + cCajuri + "' "
			cQuery +=                                                    " AND NSZ.D_E_L_E_T_ = ' ' )"

		Else

			If lAtuRed
				cQuery += " NSY_COD, "
			End

			cQuery += " ( NSZ_VAPROV * (COALESCE(" + cPercRedut + ", 100) / 100) ) VLRREDUT,"
			cQuery +=       " COALESCE(O0Q.O0Q_TIPOAS, '" + cTamTipoAs + "') O0Q_TIPOAS,"
			cQuery +=       " COALESCE(O0Q.O0Q_CAREAJ, '" + cTamAreaJ  + "') O0Q_CAREAJ,"
			cQuery +=       " COALESCE(O0Q.O0Q_COBJET, '" + cTamObjet  + "') O0Q_COBJET"
			cQuery +=  " FROM " + RetSqlName("NSZ") + " NSZ "
		EndIF

		cQuery += " LEFT JOIN " + RetSqlName("O0Q") + " O0Q ON (O0Q.O0Q_FILIAL = '" +xFilial("O0Q") + "'"
		cQuery +=                                             " AND (O0Q.O0Q_TIPOAS = NSZ.NSZ_TIPOAS OR O0Q.O0Q_TIPOAS = '" + cTamTipoAs + "') "
		cQuery +=                                             " AND (O0Q.O0Q_CAREAJ = NSZ.NSZ_CAREAJ OR O0Q.O0Q_CAREAJ = '" + cTamAreaJ	+ "') "
		cQuery +=                                             " AND (O0Q.O0Q_COBJET = NSZ.NSZ_COBJET OR O0Q.O0Q_COBJET = '" + cTamObjet 	+ "') "
		cQuery +=                                             " AND O0Q.O0Q_DTVIGD <= '" + cData + "'"
		cQuery +=                                             " AND O0Q.O0Q_DTVIGA >= '" + cData + "'"
		cQuery +=                                             " AND O0Q.D_E_L_E_T_ = ' ' )"

		If cVlProv == '2' .OR. !Empty(cCodObj)
			cQuery += " WHERE NSY.NSY_FILIAL = '" + cFilNsz + "'"
			cQuery +=   " AND NSY.NSY_CAJURI = NSZ.NSZ_COD "

			If !Empty(cCodObj)
				cQuery += " AND NSY.NSY_COD = '"+ cCodObj + "'"
			EndIf

			cQuery +=     " AND NSY.D_E_L_E_T_ = ' '"
		Else
			cQuery += " WHERE NSZ.NSZ_FILIAL = '" + cFilNsz + "'"
			cQuery +=	" AND NSZ.NSZ_COD = '" + cCajuri + "' "
			cQuery +=   " AND NSZ.D_E_L_E_T_ = ' ' "
		EndIf

		cQuery += " GROUP BY O0Q_TIPOAS, O0Q_CAREAJ, O0Q_COBJET, NSZ_VAPROV, O0Q_PERCRE"

		If lAtuRed
			cQuery += " ,NSY_COD "
		End

		cQuery += " ) REDUTORES"
		cQuery += " ORDER BY ORDEM DESC"

		// ChangeQuery removido por problemas de performance e por tratar-se de query no padrão ANSI
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
		If lAtuRed
			While !(cAlias)->(EOF())
				aAdd(xRet, {(cAlias)->NSY_COD,  Iif(Empty((cAlias)->VLRREDUT),0,(cAlias)->VLRREDUT)})//adc no array o percentual de juros e as datas no grid
				(cAlias)->(dbSkip())
			EndDo
		ElseIf !Empty( (cAlias)->VLRREDUT )
			xRet := (cAlias)->VLRREDUT
		EndIf

		(cAlias)->( DbCloseArea() )
	EndIf

	RestArea( aAreaNSY )
	RestArea( aArea )

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA94AtuRed
Calcula O Redutor de cada objeto pertencente ao processo

@param 	cCajuri Código do Assunto Juridico

@author  Beatriz Gomes
@since   22/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA94AtuRed(cCajuri)
Local aArea      := GetArea()
Local aAreaNSY   := NSY->( GetArea() )
Local cFilialNSY := xFilial("NSY")
Local aCodigos   := JA94CALRED(cCajuri,,,,,,.T.)
Local nI         := 0
Local nQtd       := Len(aCodigos)

	If nQtd > 0
	
		DbSelectArea("NSY")

		If NSY->( FieldPos("NSY_VLREDU") ) > 0

			NSY->( DbSetOrder( 3 ) ) //NSY_FILIAL+NSY_COD+NSY_CAJURI

			For nI := 1 to nQtd
				If NSY->( DbSeek(cFilialNSY + aCodigos[nI][1] + cCajuri) )
					Reclock("NSY", .F.)
					NSY->NSY_VLREDU := aCodigos[nI][2]
					NSY->( MsUnlock() )
				EndIf
			Next nI
		
		EndIf

		NSY->( DbCloseArea() )

	EndIf

	RestArea( aAreaNSY )
	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J094Anexo
Retorna os dados para exibir os documentos anexados do registro da entidade passada.

@author  leandro.silva
@since   21/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J094Anexo()
	Local oModel  := FWModelActive()
	Local cTab    := "NSY"
	Local cCajuri := AllTrim(oModel:GetValue("NSYMASTER","NSY_CAJURI"))
	Local cCod    := AllTrim(oModel:GetValue("NSYMASTER","NSY_COD"))
	Local nOrdem  := 3

	JurAnexos( cTab, cCod+cCajuri, nOrdem )

Return





