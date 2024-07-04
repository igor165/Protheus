#INCLUDE "JURA109.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE NWMCGRUPO	1
#DEFINE NWMCCLIEN	2
#DEFINE NWMCLOJA	3
#DEFINE NWNCCASO	4
#DEFINE NWMCTPSRV	5
#DEFINE NWMQUANT	6
#DEFINE NWMCMOEDA	7
#DEFINE NWMVLATUA	8
#DEFINE NWMDESCRI	9
#DEFINE NWNCPART	10

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA109
Serviços Tabelados Recorrentes

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA109(cCliente, cLoja, cCaso, lChgAll)
Local oBrowse    := Nil
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Private cLastContr

Default cCliente := ''
Default cLoja    := ''
Default cCaso    := ''
Default lChgAll  := .T.

oBrowse := FWMBrowse():New()
oBrowse:SetChgAll( lChgAll )
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NWM" )
oBrowse:SetLocate()
If FindFunction("JurBrwRev")
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NWM", {"NWM_CLOJA"}), )
EndIf

If !Empty( cCliente ) .And. !Empty( cLoja ) .And. !Empty( cCaso )
	oBrowse:SetFilterDefault(J109Filtro(cCliente, cLoja, cCaso))
EndIf

oBrowse:SetMenuDef( 'JURA109' )
JurSetLeg( oBrowse, "NWM" )
JurSetBSize( oBrowse )
oBrowse:Activate()

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

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aRotNew	:= {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA109", 0, 2, 0, NIL } ) // "Visualizar"

If !IsInCallStack('JURA162')
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA109", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA109", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA109", 0, 5, 0, NIL } ) // "Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA109", 0, 8, 0, NIL } ) // "Imprimir"
	aAdd( aRotina, { STR0020, 'J109TelaLote()' , 0, 8, 0, NIL } ) // "Gerar Lote"
	aAdd( aRotina, { STR0037, 'JURA109A()'     , 0, 3, 0, NIL } ) // "Lotes Gerados"

	If ExistBlock("JR109MNU")
		aRotNew := ExecBlock( 'JR109MNU', .F., .F., { NIL , "MENUDEF", 'JR109MNU' } )
		If ValType( aRotNew ) == "A"
			aEval( aRotNew, { |aX| aAdd( aRotina, aX ) } )
		Endif
	Endif
EndIf

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados do Serviços Tabelados Recorrentes

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  	 := FWLoadModel( "JURA109" )
Local oStructNWM := FWFormStruct( 2, "NWM" )
Local oStructNWN := FWFormStruct( 2, "NWN" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	oStructNWM:RemoveField( "NWM_ALTPAR" )
	oStructNWM:RemoveField( "NWM_CPART" )
	oStructNWN:RemoveField( "NWN_CLOTE" )
	oStructNWN:RemoveField( "NWN_CPART" )
	Iif(cLojaAuto == "1", oStructNWM:RemoveField( "NWM_CLOJA" ), )

	JurSetAgrp( 'NWM',, oStructNWM )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA109_NWM",  oStructNWM, "NWMMASTER"  )
	oView:AddGrid(  "JURA109_NWN" , oStructNWN, "NWNDETAIL"  )

	oView:CreateFolder('FOLDER_01')
	oView:AddSheet('FOLDER_01', 'ABA_01', STR0007 ) // "Lançamento tabelado em lote"

	oView:CreateHorizontalBox('BOX_A01_F01',  55,,, 'FOLDER_01', 'ABA_01')
	oView:CreateHorizontalBox('BOX_A01_F02',  45,,, 'FOLDER_01', 'ABA_01')

	oView:SetOwnerView( "JURA109_NWM", "BOX_A01_F01" )
	oView:SetOwnerView( "JURA109_NWN", "BOX_A01_F02" )

	oView:AddUserButton( STR0030, 'MENURUN', { | oView | J109AtuVal("D") } ) // "Corr. Valor"
	oView:AddUserButton( STR0017, 'MENURUN', { | oView | J109AddCasos( oView:GetModel() ) } ) // "Casos/Contrato"

	oView:SetDescription( STR0007 ) // "Descrição da Parcela"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Serviços Tabelados Recorrentes

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0

@obs NWMMASTER - Dados da Descrição da Parcela
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNWM := FWFormStruct( 1, "NWM" )
Local oStructNWN := FWFormStruct( 1, "NWN" )

	oStructNWN:RemoveField( "NWN_CLOTE" )

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel := MPFormModel():New( "JURA109",/*Pre-Validacao*/,{ | oX | JA109TUDOK(oX) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

	oModel:AddFields( "NWMMASTER", Nil, oStructNWM, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:AddGrid  ( "NWNDETAIL", "NWMMASTER" /*cOwner*/, oStructNWN, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|oX| J109VldCasos(oX:GetModel())}/*bPost*/ )

	oModel:GetModel   ( "NWNDETAIL" ):SetUniqueLine( { "NWN_CCASO" } )
	oModel:SetRelation( "NWNDETAIL", { { "NWN_FILIAL", "xFilial('NWN')" } , { "NWN_CLOTE", "NWM_COD" } } , NWN->( IndexKey( 1 ) ) )

	oModel:SetDescription( STR0008 )                         // "Modelo de Dados dos Lançamento Tabelados Em Lote"
	oModel:GetModel( "NWMMASTER" ):SetDescription( STR0009 ) // "Dados dos Lançamento Tabelados Em Lote"
	oModel:GetModel( "NWNDETAIL" ):SetDescription( STR0010 ) // "Dados dos Casos Vinculados ao Lançamento Tabelados Em Lote"

	oModel:GetModel( "NWNDETAIL" ):SetDelAllLine(.F.)

	oModel:SetOptional( "NWNDETAIL", .T.)

	JurSetRules( oModel, 'NWMMASTER',, 'NWM' )
	JurSetRules( oModel, "NWNDETAIL",, 'NWN' )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA109TUDOK
Executa as rotinas ao confirmar as alteracao no oModel.

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA109TUDOK(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

	If nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR

		If FWFLDGET("NWM_TPCORR")=="2"
			If lRet .AND. Empty(FWFLDGET("NWM_CINDIC"))
				lRet := JurMsgErro(STR0052) //"É necessário informar o índice de correção: "
			EndIf
			If lRet .AND. Empty(FWFLDGET("NWM_PERCOR"))
				lRet := JurMsgErro(STR0053) // "É necessário informar a periodicidade de correção: "
			EndIf
		EndIf

		If lRet .AND. !(J109VldCasos(oModel) .And. J109VldPart(oModel))
			lRet := .F.
		EndIf

		If lRet .And. nOperation == OP_ALTERAR
			oModel:SetValue("NWMMASTER", "NWM_ALTPAR", JurUsuario(__CUSERID))
			oModel:SetValue("NWMMASTER", "NWM_ALTDT", Date())
			oModel:SetValue("NWMMASTER", "NWM_ALTHR", Time())
		EndIF

		If lRet .AND. Empty(FWFLDGET("NWM_CPART")) .And. oModel:GetOperation() != 5
			lRet := JurMsgErro(STR0059) // "É necessário informar o participante. Verifique!"
		EndIf

	EndIF

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J109VlCaso
Validação de caso

@author Felipe Bonvicini Conti
@since 12/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109VlCaso()
Local lRet	:= .T.
Local aArea	:= GetArea()

	If oModel:GetId() == 'JURA109'
		lRet :=	ExistCpo('NV4',FwFldGet('NWM_CCLIEN')+FwFldGet('NWM_CLOJA')+FwFldGet('NWN_CCASO'),1)
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109ValCpo
Função para validar o campo de Tipo de Serviço Tabelado

@Return lRet

@author Felipe Bonvicini Conti
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109ValCpo()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local cGrupo    := ''
Local cClien    := ''
Local cLoja     := ''

cGrupo  := oModel:GetValue("NWMMASTER", "NWM_CGRUPO")
cClien  := oModel:GetValue("NWMMASTER", "NWM_CCLIEN")
cLoja   := oModel:GetValue("NWMMASTER", "NWM_CLOJA")

Do Case
Case __ReadVar == 'M->NWM_CTPSRV'

	IIF(lRet, lRet := oModel:SetValue('NWMMASTER', 'NWM_DTPSRV', Posicione('NRD',1,XFilial('NRD')+FwFldGet("NWM_CTPSRV"), 'NRD_DESCH')), )
	IIF(lRet, lRet := oModel:SetValue('NWMMASTER', 'NWM_DESCRI', FwFldGet("NWM_DTPSRV")), )

Case lRet .And. __ReadVar $ 'M->NWM_CGRUPO'
	lRet := JurVldCli(cGrupo, cClien, cLoja,,,"GRP")

Case lRet .And. __ReadVar $ 'M->NWM_CCLIEN'
	lRet := JurVldCli(cGrupo, cClien, cLoja,,,"CLI")

Case lRet .And. __ReadVar $ 'M->NWM_CLOJA'
	lRet := JurVldCli(cGrupo, cClien, cLoja,,,"LOJ")

Case lRet .And. __ReadVar $ 'M->NWM_CCONTR'

	If Empty(cLastContr)
		cLastContr := NWM->NWM_CCONTR
	EndIF
	If lRet .And. !Empty(cLastContr) .And. cLastContr != FwFldGet("NWM_CCONTR") .And. ;
			!Empty(JFindMdl(oModel:GetModel('NWNDETAIL'), "NWN_CCONTR",cLastContr,{"POSICAO"})) .And. ;
			ApMsgYesNo(STR0013) // "Os Casos cadastrados do contrato serão removidos, continuar?"
		lRet := J109RemCaso(oModel, .F.)
	EndIf
	cLastContr := FwFldGet("NWM_CCONTR")
	IIF(lRet, lRet := oModel:SetValue('NWMMASTER','NWM_DCONTR', Posicione('NT0', 1, xFilial('NT0')+FwFldGet('NWM_CCONTR'),'NT0_NOME')), )

End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA109CLEAR
Função para limpar os campos.

@Return lRet

@author Felipe Bonvicini Conti
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA109CLEAR(oModel, cCampo)
Local lRet := .T.

	Do Case
	Case cCampo == "NWM_CGRUPO"
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_CCLIEN"), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_CLOJA" ), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCLIEN"), )
		IIF(lRet, lRet := oModel:SetValue('NWMMASTER', "NWM_CCONTR", ""), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCONTR"), )

	Case cCampo == "NWM_CCLIEN"
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_CLOJA" ), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCLIEN"), )
		IIF(lRet, lRet := oModel:SetValue('NWMMASTER', "NWM_CCONTR", ""), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCONTR"), )

	Case cCampo == "NWM_CLOJA"
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCLIEN"), )
		IIF(lRet, lRet := oModel:SetValue('NWMMASTER', "NWM_CCONTR", ""), )
		IIF(lRet, lRet := oModel:ClearField('NWMMASTER', "NWM_DCONTR"), )

	End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109RemCaso
Função Limpar o grid de casos

@Return lRet

@author Felipe Bonvicini Conti
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109RemCaso(oModel, lGatilho)
Local xRet        := Nil
Local oModelNWN   := Nil
Local nQtdNWN     := 0
Local nLinNWN     := 0
Local nI          := 0

Default oModel    := FwModelActive()
Default lGatilho  := .F.

xRet      := Iif(lGatilho, &(READVAR()), .T.)
oModelNWN := oModel:GetModel('NWNDETAIL')
nQtdNWN   := oModelNWN:GetQtdLine()
nLinNWN   := oModelNWN:nLine

If !oModelNWN:IsEmpty()
	For nI := 1 To nQtdNWN
		oModelNWN:GoLine(nI)
		If !oModelNWN:DeleteLine()
			JurMsgErro(STR0014) // "Erro ao apagar os casos!"
			Exit
		EndIf
	Next nI
EndIf

oModelNWN:GoLine(nLinNWN)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109AddCasos
Função para adicionar todos os casos vinculados ao Cliente Caso e Contrato

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109AddCasos(oModel)
Local lRet      := .T.
Local oModelNWN := oModel:GetModel('NWNDETAIL')
Local cClient   := FwFldGet("NWM_CCLIEN")
Local cLoja     := FwFldGet("NWM_CLOJA")
Local cContrato := FwFldGet("NWM_CCONTR")
Local nLineNWN  := oModelNWN:nLine
Local oView     := FWViewActive()
Local aArea     := GetArea()
Local cQry      := ""
Local aSQL      := {}
Local nI        := 0

	If !Empty(cClient) .And. !Empty(cLoja) .And. !Empty(cContrato)
		If JMdlNewLine(oModelNWN)
			IIF(lRet, lRet := oModelNWN:DeleteLine(), )
		EndIf
		cQry += " SELECT NUT.NUT_CCASO, NUT.NUT_CCONTR " + CRLF
		cQry += "   FROM " + RetSqlName("NUT") + " NUT " + CRLF
		cQry += "  WHERE NUT.D_E_L_E_T_ = ' ' " + CRLF
		cQry += "    AND NUT.NUT_FILIAL = '" +xFilial("NUT")+"' " + CRLF
		cQry += "    AND NUT.NUT_CCONTR = '" +cContrato+ "'" + CRLF
		cQry += "    AND NUT.NUT_CCLIEN = '" +cClient+ "'" + CRLF
		cQry += "    AND NUT.NUT_CLOJA  = '" +cLoja+ "'" + CRLF
		aSQL := JURSQL(cQry, {"NUT_CCASO", "NUT_CCONTR"})

		If lRet .And. !Empty(aSQL)
			For nI := 1 to Len(aSql)

				If Empty(JFindMdl(oModelNWN,"NWN_CCASO",aSql[nI][1],{"POSICAO"}))
					oModelNWN:AddLine()
					oModel:SetValue("NWNDETAIL", "NWN_CCASO",  aSql[nI][1])
					oModel:SetValue("NWNDETAIL", "NWN_CCONTR", aSql[nI][2])
				EndIF

			Next
		Else
			Alert(STR0015) // "Não existe casos neste contrato relacionado ao Cliente/Loja."
		EndIf
		oModelNWN:GoLine(nLineNWN)
	EndIF
	oView:Refresh()
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109VldCasos
Função para validar se o participante dos casos estão preenchidos.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109VldCasos(oModel)
Local lRet      := .T.
Local oModelNWM := oModel:GetModel("NWMMASTER")
Local oModelNWN := oModel:GetModel('NWNDETAIL')
Local nQtd      := oModelNWN:GetQtdLine()
Local lVazio    := .F.
Local nDeleted  := 0
Local nI        := 0

	If JMdlNewLine(oModelNWN)
		lVazio := .T.
	Else

		For nI := 1 To nQtd
			If oModelNWN:IsDeleted(nI)
				nDeleted++
			Else
				If Empty(oModelNWN:GetValue("NWN_SIGLA", nI))
					lRet := JurMsgErro(STR0038) // "Favor preencher a sigla do participante dos casos relacionados."
					Exit
				Else
					If !(lRet := J109VCaso(oModelNWN:GetValue("NWN_CCASO", nI), .T.))
						Exit
					EndIf
				EndIf
			EndIf
		Next

	EndIF

	If lRet .And. (lVazio .Or. nDeleted == nQtd)
		If Empty(oModelNWM:GetValue("NWM_CCONTR"))
			lRet := JurMsgErro(STR0044) // "Favor relacionar ao menos um caso ou então algum contrato. Verifique!"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109TelaLote
Função para gerar o lote do ano-mes

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109TelaLote()
Local oDlg      := Nil
Local oAnoMes   := Nil
Local oDia      := Nil
Local oMainColl := Nil
Local oLayer    := FWLayer():new()
Local aButtons  :={}

DEFINE MSDIALOG oDlg FROM 000,000 TO 200, 420 PIXEL TITLE STR0020 //"Gerar Lote"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oAnoMes := TJurPnlCampo():New(15,15,30,22,oMainColl,STR0021,'NWM_AMINI',{|| },{|| },,,,) //"Ano-Mês"
oAnoMes:oCampo:bValid := {|| J109ValGera(oAnoMes) }
oDia    := TJurPnlCampo():New(15,55,30,22,oMainColl,STR0022,'NWM_DIAGER',{|| },{|| },,,,) //"Dia Geração"
oDia:oCampo:bValid := {|| J109ValGera(oDia) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| J109BtnOk(oAnoMes, oDia)},{||oDlg:End()},,aButtons,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J109BtnOk
Função para validar o botão ok da geração.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109BtnOk(oAnoMes, oDia)
Local lRet      := .T.
Local oProcess  := NIL

	If Empty(oAnoMes:VALOR) .Or. Empty(oDia:VALOR)
		Alert(STR0031) // "Os campos de Ano-Mes e Dia Geração devem ser preenchidos. Verifique!"
		lRet := .F.
	EndIF

	If Val(oAnoMes:VALOR) > Val(AllTrim(Str(Year(Date()))) + AllTrim(StrZero(Month(Date()),2)))
		Alert(STR0043) // "O Ano-Mês de geração não pode ser maior que a data atual. Verifique!"
		lRet := .F.
	EndIf

	If lRet .And. ApMsgYesNo(STR0027) // "Gerar"
		oProcess := MsNewProcess():New( { |lEnd| lRet := J109GeraLote(oAnoMes:VALOR, oDia:VALOR, @lEnd, @oProcess) }, STR0047, STR0048, .T. ) // 'Aguarde' e 'Gerando os lotes...'
		oProcess:Activate()
	EndIF


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109BtnOk
Função de validação do botão ok da geração.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109ValGera(oCampo)
Local lRet := .T.

	Do Case
	Case AllTrim(oCampo:cNomeCampo) == "NWM_AMINI"
		lRet := Empty(oCampo:VALOR) .Or. JVldAnoMes(oCampo:VALOR)
	Case AllTrim(oCampo:cNomeCampo) == "NWM_DIAGER"
		lRet := Empty(oCampo:VALOR) .Or. Val(oCampo:VALOR)>0 .And. Val(oCampo:VALOR)<=31
	End Case

	If !lRet
		Alert(STR0025) // "Valor incorreto!"
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109GeraLote
Função para gerar o lote.

@Param  cAnoMes   Ano/Mês de geração do lote
@Param  cAnoMes   Dia da geração do lançamento tabelado
@Param  lEnd      Controle de iterrupção do processamento
@Param  oProcess  Objeto da barra de progresso

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109GeraLote(cAnoMes, cDia, lEnd, oProcess)
Local lRet      := .T.
Local aRet      := {}
Local cSQL      := ""
Local aSQL      := {}, aSucesso := {}, aErro := {}
Local nQtd      := 0
Local nI        := 1
Local oModelNV4 := FWLoadModel('JURA027')
Local cMsg      := ""
Local cCabLog   := ""
Local nDtLimite := SuperGetMV('MV_JLIMTAB',,99) + 1
Local cDtLim    := ""
Local cMsgAbort := ""

Default lEnd := .F.

nDtLimite := IIf(nDtLimite < 0, 31, nDtLimite )
nDtLimite := IIf(nDtLimite >99, 99, nDtLimite )
cDtLim    := Strzero( nDtLimite ,2)   //Dia limite de encerramento da pasta para gerar o lote de Lançamentos Tabelados do mês

If Empty(cAnoMes)
	cAnoMes := Str(Year(Date()), 4)+ Padl(Str(Month(Date()), 1),2, "0")
EndIF
If Empty(cDia)
	cDia    := Str(Day(Date()), 2)
EndIF

cSQL += "SELECT NWM_COD, NWM_PERCOB, R_E_C_N_O_, NWM_DIAGER, NWM.NWM_CINDIC, NWM_PERCOR, NWM_TPCORR " + CRLF
cSQL += " FROM "+RetSqlName("NWM")+" NWM " + CRLF
cSQL += " WHERE NWM.NWM_FILIAL = '"+xFilial("NWM")+"' " + CRLF
cSQL += " AND NWM.D_E_L_E_T_ = ' ' " + CRLF
cSQL += " AND NWM.NWM_AMINI <= '"+cAnoMes+"' " + CRLF
cSQL += " AND (NWM.NWM_AMFIM >= '"+cAnoMes+"' OR NWM.NWM_AMFIM = '"+ Space(TamSx3('NWM_AMFIM')[1]) +"' ) " + CRLF
cSQL += " AND EXISTS (SELECT NWN.R_E_C_N_O_ " + CRLF
cSQL +=              " FROM "+RetSqlName("NWN")+" NWN " + CRLF
cSQL +=             " WHERE NWN.NWN_FILIAL = '"+xFilial("NWN")+"' " + CRLF
cSQL +=               " AND NWN.NWN_CLOTE = NWM.NWM_COD " + CRLF
cSQL +=               " AND NWN.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=               " AND EXISTS (SELECT NSZ_COD " + CRLF
cSQL +=                            " FROM "+RetSqlName("NSZ")+" NSZ " + CRLF
cSQL +=                           " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'" + CRLF
cSQL +=                             " AND NSZ.D_E_L_E_T_ = ' '" + CRLF
cSQL +=                             " AND NSZ.NSZ_CCLIEN = NWM_CCLIEN" + CRLF
cSQL +=                             " AND NSZ.NSZ_LCLIEN = NWM_CLOJA" + CRLF
cSQL +=                             " AND NSZ.NSZ_NUMCAS = NWN_CCASO" + CRLF
cSQL +=                             " AND NSZ.NSZ_DTENTR <= '"+cAnoMes+"31'" + CRLF
cSQL +=                            " AND ( NSZ.NSZ_SITUAC = '1' " + CRLF
cSQL +=                                  " OR NSZ.NSZ_DTENCE BETWEEN '"+cAnoMes+cDtLim + "' AND '"+cAnoMes+"31'" + CRLF
cSQL +=                                  " OR NSZ.NSZ_DTENCE > '"+cAnoMes+"31'" + CRLF
cSQL +=                                " )" + CRLF
cSQL +=                          " )" + CRLF
cSQL +=            " ) " + CRLF
cSQL +=  " ORDER BY NWM.NWM_COD " + CRLF

aSQL := JurSQL(cSQL, {"NWM_COD", "NWM_PERCOB", "NWM_DIAGER", "R_E_C_N_O_", "NWM_CINDIC", "NWM_PERCOR", "NWM_TPCORR" })

If !Empty(aSQL)
	nQtd := Len(aSQL)

	oProcess:SetRegua1( nQtd )

	For nI := 1 To nQtd
		oProcess:IncRegua1(I18N(STR0049, {aSQL[nI][1]} ) ) //"Gerando Lote #1..."
		oProcess:SetRegua2(0)
		oProcess:IncRegua2(STR0011) //"Validando o lote..."
		ProcessMessage()

		If lEnd
			cMsgAbort := I18N(STR0034 , {aSQL[nI][1]} ) //"Processo interrompido pelo usuário. Lote #1."
			Exit
		EndIf

		lRet := .T.
		If !Empty(aSQL[nI][3])
			cDia := aSQL[nI][3]
		EndIf

		If aSQL[nI][7] == "2" .AND.(Empty(aSQL[nI][5]) .OR. Empty(aSQL[nI][6]))//NWM_CINDIC NWM_PERCOR
			If Empty(aSQL[nI][5])
				aAdd(aErro, {aSQL[nI][1], STR0052})	//"É necessário informar o índice de correção: "
			Else
				aAdd(aErro, {aSQL[nI][1], STR0053}) //"É necessário informar a periodicidade de correção: "
			EndIF
			lRet := .F.
		EndIf

		If 	lRet
			J109AtuVal("F", aSQL[nI][4], SToD(cAnoMes+cDia))

			aRet := GeraLote(oModelNV4, aSQL[nI][1], aSQL[nI][2], cAnoMes, cDia, @oProcess)
			If aRet[1]
				aAdd(aSucesso, {aSQL[nI][1], STR0018 + CRLF + aRet[2]}) // "Lançamentos Gerados"
			Else
				aAdd(aErro, {aSQL[nI][1], aRet[2]})
			EndIF
		EndIF

	Next
Else
	lRet := .F.
	cMsg := STR0026 // "Não existem Lançamentos base para serem gerados neste Ano-Mês!"
EndIf

cCabLog := STR0028 + CRLF + CRLF// "Log de geração: "
cCabLog += STR0054 + ": " + Alltrim(Str(Len(aSQL))) + CRLF  // "Total de lotes a gerar "
cCabLog += STR0037 + ": " + Alltrim(Str(Len(aSucesso))) + CRLF // "Lotes Gerados"
cCabLog += STR0055 + ": " + Alltrim(Str(Len(aErro))) + CRLF // "Lotes com Crítica: "
If lEnd
	cCabLog += cMsgAbort + CRLF
EndIf

AutoGrLog(cCabLog )
AEval(  aErro   , { |aX| AutoGrLog( STR0040 + aX[1] + ": " + CRLF + aX[2] ) } )

MostraErro()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLote
Função para gravar os registros na NV4.

@Param  oModelNV4  Modelo de dados do Lançamento tabelado
@Param  cCodLote   Codigo do lote
@Param  cPerCob    Periodo de cobrança
@Param  cAnoMes    Ano/Mês de geração do lote
@Param  cAnoMes    Dia da geração do lançamento tabelado
@Param  oProcess   Objeto da barra de progresso

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraLote(oModelNV4, cCodLote, cPerCob, cAnoMes, cDia, oProcess)
Local lRet     := .T.
Local lOk      := .T.
Local aArea    := GetArea()
Local aLote    := GetDadosLote(cCodLote, cAnoMes, cPerCob)
Local nI       := 1
Local cMsg     := ""
Local aLacuna  := {}
local nQtdLote := 0

Default oModelNV4 := FWLoadModel('JURA027')

If !Empty(aLote)

	aLacuna := J109PeriodoOk(cCodLote, cPerCob, cAnoMes) // Retornar .T. se não houver lacunas.
	If aLacuna[1]

		If !Empty(aLacuna[2])
			cMsg += STR0041+cCodLote+": " + AToC(aLacuna[2], " / ") + CRLF // "Meses faltantes do lote "
		EndIf
		nQtdLote := Len(aLote)

		oProcess:SetRegua2( nQtdLote )

		For nI := 1 To nQtdLote

			oProcess:IncRegua2(I18N(STR0050, {aLote[nI][4]})) // "Gerando para o lançamento base #1..."
			ProcessMessage()

			lOk := .T.
			oModelNV4:SetOperation(MODEL_OPERATION_INSERT)
			oModelNV4:Activate()

			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_DTLANC', SToD(cAnoMes+cDia)), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CGRUPO', aLote[nI][NWMCGRUPO]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CCLIEN', aLote[nI][NWMCCLIEN]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CLOJA' , aLote[nI][NWMCLOJA]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CCASO' , aLote[nI][NWNCCASO]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CTPSRV', aLote[nI][NWMCTPSRV]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_QUANT' , aLote[nI][NWMQUANT]), )
			IIF( lOk, lOk := oModelNV4:LoadValue('NV4MASTER', 'NV4_CMOEH', aLote[nI][NWMCMOEDA]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_VLHFAT', aLote[nI][NWMVLATUA]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_DESCRI', aLote[nI][NWMDESCRI]), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_SIGLA' , RTrim(Posicione('RD0',1,xFilial('RD0')+aLote[nI][NWNCPART],'RD0_SIGLA'))), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CLOTE' , cCodLote), )
			IIF( lOk, lOk := oModelNV4:SetValue('NV4MASTER', 'NV4_CONC'  , "1"), ) // Sim

			If lOk .And. oModelNV4:VldData()
				oModelNV4:CommitData()
			Else
				cMsg += STR0032 + aLote[nI][2]+"/"+aLote[nI][3]+"/"+aLote[nI][4] + CRLF+ JA109GetErr(oModelNV4) + CRLF // "Erro ao salvar Lançamento Tabelado do Cliente/Loja/Caso "
				lRet := .F.
			EndIF
			oModelNV4:DeActivate()
		Next nI

	Else
		lRet := .F.
		cMsg += STR0041+cCodLote+": " + AToC(aLacuna[2], " / ") + CRLF // "Meses faltantes do lote "
	EndIf

Else
	lRet := .F.
	cMsg += STR0033 + CRLF + STR0056  + CRLF // "Não existem dados para geração."  + CRLF + "Verifique se já existe lançamento tabelado gerado através deste lote."

EndIf
RestArea(aArea)

Return {lRet, cMsg}


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadosLote
Função para buscar os dados possiveis de geração de lote, que são:
- Que não exista lançamento já cadastrado para o ano-mes e que não esteja em andamento.
- O caso deve possuir ao menos 1 processo ativo.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetDadosLote(cCodLote, cAnoMes, cPerCob)
Local aRet       := {}
Local aArea      := GetArea()
Local cSQL       := ""
Local nI         := 1
Local cDataPerio := JurPrxData( SToD(cAnoMes+"01"), Val(cPerCob)-1, "M", 2) // Subtração
Local nDtLimite  := SuperGetMV('MV_JLIMTAB',,99) + 1

nDtLimite := IIf(nDtLimite <  0, 31, nDtLimite )
nDtLimite := IIf(nDtLimite > 99, 99, nDtLimite )
cDtLim    := Strzero( nDtLimite ,2) //Dia limite de encerramento da pasta para gerar o lote de Lançamentos Tabelados do mês

cDataPerio := Str(Year(cDataPerio), 4) + StrZero( Month(cDataPerio), 2 )

cSQL += " SELECT NWM_CGRUPO, NWM_CCLIEN, NWM_CLOJA, CASO, NWM_CTPSRV, CPART, " + CRLF
cSQL +=        " NWM_QUANT, NWM_CMOEDA, NWM_VLATUA, A.R_E_C_N_O_ " + CRLF
cSQL +=        " FROM (SELECT NWMa.NWM_CGRUPO, NWMa.NWM_CCLIEN, NWMa.NWM_CLOJA, NWNa.NWN_CCASO CASO, NWMa.NWM_CTPSRV, NWNa.NWN_CPART CPART, " + CRLF
cSQL +=                     " NWMa.NWM_QUANT, NWMa.NWM_CMOEDA, NWMa.NWM_VLATUA, NWMa.NWM_AMINI, NWMa.NWM_AMFIM, NWMa.NWM_COD, NWMa.R_E_C_N_O_ " + CRLF
cSQL +=                     " FROM " + RetSqlName("NWM") + " NWMa,  " + CRLF
cSQL +=                          " " + RetSqlName("NWN") + " NWNa  " + CRLF
cSQL +=                     " WHERE NWMa.NWM_FILIAL = '"+xFilial("NWM")+"' " + CRLF
cSQL +=                           " AND NWNa.NWN_FILIAL = '"+xFilial("NWN")+"' " + CRLF
cSQL +=                           " AND NWMa.NWM_COD = NWNa.NWN_CLOTE " + CRLF
cSQL +=                           " AND NWNa.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                           " AND NWMa.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                           " AND NWMa.NWM_COD = '"+cCodLote+"' " + CRLF
cSQL +=              " UNION " + CRLF
cSQL +=              " SELECT NWMb.NWM_CGRUPO, NWMb.NWM_CCLIEN, NWMb.NWM_CLOJA, NUTb.NUT_CCASO CASO, NWMb.NWM_CTPSRV, NWMb.NWM_CPART CPART, " + CRLF
cSQL +=                      " NWMb.NWM_QUANT, NWMb.NWM_CMOEDA, NWMb.NWM_VLATUA, NWMb.NWM_AMINI, NWMb.NWM_AMFIM, NWMb.NWM_COD, NWMb.R_E_C_N_O_ " + CRLF
cSQL +=                      " FROM " + RetSqlName("NWM") + " NWMb, " + CRLF
cSQL +=                           " " + RetSqlName("NUT") + " NUTb " + CRLF
cSQL +=                         " WHERE NWMb.NWM_FILIAL = '"+xFilial("NWM")+"' " + CRLF
cSQL +=                           " AND NUTb.NUT_FILIAL = '" + xFilial("NUT") + "' " + CRLF
cSQL +=                           " AND NUTb.NUT_CCONTR = NWMb.NWM_CCONTR " + CRLF
cSQL +=                           " AND NUTb.NUT_CCLIEN = NWMb.NWM_CCLIEN " + CRLF
cSQL +=                           " AND NUTb.NUT_CLOJA = NWMb.NWM_CLOJA " + CRLF
cSQL +=                           " AND NUTb.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                           " AND NWMb.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                           " AND NWMb.NWM_COD = '"+cCodLote+"' " + CRLF
cSQL +=                           " AND NOT EXISTS ( SELECT NWNc.R_E_C_N_O_ " + CRLF
cSQL +=                                                " FROM " + RetSqlName("NWM") + " NWMc, " + CRLF
cSQL +=                                                     " " + RetSqlName("NWN") + " NWNc " + CRLF
cSQL +=                                                " WHERE NWMc.NWM_FILIAL = '"+xFilial("NWM")+"' " + CRLF
cSQL +=                                                  " AND NWNc.NWN_FILIAL = '"+xFilial("NWN")+"' " + CRLF
cSQL +=                                                  " AND NWMc.NWM_CCLIEN = NUTb.NUT_CCLIEN " + CRLF
cSQL +=                                                  " AND NWMc.NWM_CLOJA = NUTb.NUT_CLOJA " + CRLF
cSQL +=                                                  " AND NWNc.NWN_CCASO = NUTb.NUT_CCASO " + CRLF
cSQL +=                                                  " AND NWMc.NWM_COD = '"+cCodLote+"' " + CRLF
cSQL +=                                                  " AND NWNc.NWN_CLOTE = NWMc.NWM_COD " + CRLF
cSQL +=                                                  " AND NWNc.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                                                  " AND NWMc.D_E_L_E_T_ = ' ')" + CRLF

cSQL +=              " ) A " + CRLF
cSQL +=        " WHERE '"+Str(Year(DATE()), 4) + Padl(  alltrim( Str(Month(DATE()), 2) ) ,2, "0")+"' >= '"+cAnoMes+"'" + CRLF
cSQL +=          " AND NWM_AMINI <= '"+cAnoMes+"'" + CRLF
cSQL +=          " AND NWM_AMFIM >= CASE NWM_AMFIM WHEN '"+ Space(TamSx3('NWM_AMFIM')[1]) +"' THEN NWM_AMFIM ELSE '"+cAnoMes+"' END " + CRLF
cSQL +=          " AND EXISTS (SELECT NSZ.R_E_C_N_O_ " + CRLF
cSQL +=                             " FROM "+RetSqlName("NSZ")+" NSZ " + CRLF
cSQL +=                            " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'" + CRLF
cSQL +=                              " AND NSZ.D_E_L_E_T_ = ' '" + CRLF
cSQL +=                              " AND NSZ.NSZ_CCLIEN = NWM_CCLIEN" + CRLF
cSQL +=                              " AND NSZ.NSZ_LCLIEN = NWM_CLOJA" + CRLF
cSQL +=                              " AND NSZ.NSZ_NUMCAS = A.CASO" + CRLF
cSQL +=                              " AND NSZ.NSZ_DTENTR <= '"+cAnoMes+"31'" + CRLF
cSQL +=                              " AND ( NSZ.NSZ_SITUAC = '1' " + CRLF
cSQL +=                                    " OR NSZ.NSZ_DTENCE BETWEEN '"+cAnoMes+cDtLim + "' AND '"+cAnoMes+"31'" + CRLF
cSQL +=                                    " OR NSZ.NSZ_DTENCE > '"+cAnoMes+"31'" + CRLF
cSQL +=                                  " )" + CRLF
cSQL +=                      " )" + CRLF
cSQL +=          " AND NOT EXISTS (SELECT NV4.R_E_C_N_O_ " + CRLF
cSQL +=                                 " FROM "+RetSqlName("NV4")+" NV4 " + CRLF
cSQL +=                                " WHERE NV4.NV4_FILIAL = '"+xFilial("NV4")+"' " + CRLF
cSQL +=                                  " AND NV4.D_E_L_E_T_ = ' ' " + CRLF
cSQL +=                                  " AND NV4.NV4_CLOTE = NWM_COD " + CRLF
cSQL +=                                  " AND NV4.NV4_CCLIEN = NWM_CCLIEN " + CRLF
cSQL +=                                  " AND NV4.NV4_CLOJA = NWM_CLOJA " + CRLF
cSQL +=                                  " AND NV4.NV4_CCASO = A.CASO " + CRLF
cSQL +=                                  " AND NV4.NV4_ANOMES >= '"+cDataPerio+"' AND NV4.NV4_ANOMES <= '"+cAnoMes+"') " + CRLF
cSQL +=        " ORDER BY A.NWM_CCLIEN, A.NWM_CLOJA, A.CASO " + CRLF

aRet := JurSQL(cSQL, {"NWM_CGRUPO","NWM_CCLIEN","NWM_CLOJA","CASO","NWM_CTPSRV",;
	"NWM_QUANT","NWM_CMOEDA","NWM_VLATUA","R_E_C_N_O_", "CPART"})

If !Empty(aRet)
	For nI := 1 to Len(aRet)
		NSZ->( DbSetOrder(2) ) //NSZ_FILIAL+NSZ_CCLIENT+NSZ_LCLIEN+NSZ_NUMCAS
		NSZ->( DbSeek( xFilial("NSZ") + aRet[nI][NWMCCLIEN] + aRet[nI][NWMCLOJA] + aRet[nI][NWNCCASO] ) )

		aRet[nI][NWMDESCRI] := GetDescri(aRet[nI][NWMDESCRI])
	Next
EndIf
RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDescri
Busca a descrição do lançamento a ser gerado.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetDescri(cRECNO)
Local cRet := ""

	NWM->(dbGoTo(cRECNO))

	If Empty(NWM->NWM_FORMUL)
		cRet := NWM->NWM_DESCRI
	Else
		cRet := Formula(NWM->NWM_FORMUL)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA109GetErr
Funçao para mostrar o erro do model.

@Return lRet

@author Luciano Pereira dos Santos
@since 23/07/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA109GetErr(oModel, aDados, cRotina, cMsgAdd)
Local cRet      := ""

Default aDados  := Nil
Default cRotina := ""
Default cMsgAdd := ""

aErro := oModel:GetErrorMessage()
cRet += cRotina + CRLF
cRet += JurShowErro( aErro, aDados, Nil, .F., .F.)
If !Empty(cMsgAdd)
	cRet += cMsgAdd + CRLF
	cRet += Replicate( '-', 78 ) + CRLF + CRLF
EndIf

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} J109AtuVal
Funçao para atualizar o valor do model com base no índice.

@Return lRet

@author Felipe Bonvicini Conti
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109AtuVal(cTipo, cRECNO, cDataVenc)
Local lRet  := .T.
Local aArea := GetArea()
Local oModel

Default cRECNO		:= NWM->(RECNO())
Default cDataVenc	:= Date()

	Do Case
		Case cTipo == "F" // No Browse
			NWM->(dbGoTo(cRECNO))

			If NWM->NWM_TPCORR == "2"
				cCompl	:= STR0040 + NWM->NWM_COD + CRLF // "Lançamento Base "
				cCompl	+= STR0051 + NWM->NWM_CINDIC + CRLF
				RecLock('NWM', .F.)
				NWM->NWM_VLATUA := JCorrIndic(NWM->NWM_VLBASE, NWM->NWM_DTBASE, cDataVenc, Val(NWM->NWM_PERCOR), NWM->NWM_CINDIC, "V",.F., cCompl)
				NWM->(MsUnlock())
			EndIF

		Case cTipo == "D" // Dentro do Model
			oModel := FwModelActive()
			If FwFldGet("NWM_TPCORR") == "2"
				cCompl	:= STR0040 + FwFldGet("NWM_COD")+ CRLF
				cCompl	+= STR0051 + FwFldGet("NWM_CINDIC")+ CRLF
				oModel:SetValue("NWMMASTER", "NWM_VLATUA", JCorrIndic(FwFldGet("NWM_VLBASE"), FwFldGet("NWM_DTBASE"), cDataVenc, ;
																Val(FwFldGet("NWM_PERCOR")), FwFldGet("NWM_CINDIC"), "V"),.F., cCompl)
			EndIF

	EndCase

	RestArea(aArea)

Return lRet

Static Function J109PeriodoOk(cCodLote, cPerCob, cAnoMes)
Local aRet         := { .T., {} }
Local aArea        := GetArea()
Local cQry         := ""
Local cAnoMesPerio := ""
Local cAnoMesLast  := ""
Local aNV4         := {}
Local aAux         := {}
Local nI

cQry += " SELECT NV4_ANOMES "
cQry += CRLF + " FROM "+RetSqlName("NV4")+" NV4 "
cQry += CRLF + " LEFT JOIN "+RetSqlName("NWM")+" NWM "
cQry += CRLF +   " ON NWM.NWM_COD = NV4_CLOTE "
cQry += CRLF +  " AND NWM.NWM_FILIAL = '"+xFilial("NWM")+"' "
cQry += CRLF +  " AND NWM.D_E_L_E_T_ = ' ' "
cQry += CRLF + " WHERE NV4.NV4_FILIAL = '"+xFilial("NV4")+"' "
cQry += CRLF +   " AND NV4.D_E_L_E_T_ = ' ' "
cQry += CRLF +   " AND NV4.NV4_CLOTE = '"+cCodLote+"'"
cQry += CRLF +   " AND NV4.NV4_ANOMES >= NWM.NWM_AMINI "
cQry += CRLF +   " AND NV4.NV4_ANOMES <= CASE NWM.NWM_AMFIM WHEN '"+ Space(TamSx3('NWM_AMFIM')[1]) +"' "
cQry += CRLF +                                            " THEN NV4.NV4_ANOMES ELSE NWM.NWM_AMFIM END "
cQry += CRLF + " GROUP BY NV4.NV4_ANOMES "
cQry += CRLF + " ORDER BY NV4.NV4_ANOMES "

aNV4 := JurSQL(cQry, "NV4_ANOMES")

If !Empty(aNV4)

	cAnoMesPerio := aNV4[1][1]
	cAnoMesLast  := aNV4[1][1]
	cAnoMesPerio := JSToFormat( JurDtAdd(cAnoMesPerio+'01', 'M', Val(cPerCob)) , "YYYYMM")
	While cAnoMesPerio <= cAnoMes
		aAdd(aAux, cAnoMesPerio)
		cAnoMesPerio := JSToFormat( JurDtAdd(cAnoMesPerio+'01', 'M', Val(cPerCob)) , "YYYYMM")
	End

	For nI := 1 to LEN(aAux)

		If aScan( aNV4, {|x| x[1] == aAux[nI]} ) == 0
			aAdd(aRet[2], aAux[nI])
		EndIf
		cAnoMesLast := aAux[nI]

	Next

EndIF

RestArea(aArea)

If Empty(aRet[2])
	cAnoMesLast := JSToFormat( JurDtAdd(cAnoMesLast+'01', 'M', Val(cPerCob)) , "YYYYMM")
	If aScan( aNV4, {|x| x[1] == cAnoMes} ) > 0 .Or. cAnoMes == cAnoMesLast .Or. Empty(aNV4)
		aRet[1] := .T.
	Else
		aRet[1] := .F.
	EndIF
Else
	If aScan( aRet[2], {|x| x == cAnoMes} ) > 0
		aRet[1] := .T.
		ADel(aRet[2], LEN(aRet[2])) // É excluido o ultimo registro que sempre será o que esta sendo inserido!
		ASize(aRet[2], LEN(aRet[2])-1) // Assim ele não irá aparecer no log final.
	Else
		aRet[1] := .F.
	EndIF
EndIF

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J109VSIGLA
Funçao para validar a sigla

@Return lRet

@author Felipe Bonvicini Conti
@since 20/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109VSIGLA()
Local lRet := .T.

	lRet := Vazio().OR.(ExistCpo("RD0",FWFLDGET("NWN_SIGLA"),9).AND.Posicione('RD0',9,xFilial('RD0')+FWFLDGET("NWN_SIGLA"),'RD0_TPJUR')=="1")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109VldPart
Funçao para validar o participante

@Return lRet

@author Felipe Bonvicini Conti
@since 26/01/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J109VldPart(oModel)
Local lRet := .T.

	If !Empty(FwFldGet("NWM_CCONTR")) .And. Empty(FwFldGet("NWM_SIGLA"))
		lRet := JurMsgErro(STR0046) // "" "Ao preencher o contrato sugerido o campo sigla do participante também deve ser preenchida!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109Filtro
Filtra os lançamentos tabelados em lote conforme informações do processo
Uso Geral.

@param cCliente    Código do cliente
@param cLoja	   Código da loja
@param cCaso	   Código do caso

@return cRet	   Expressão do filtro

@author Juliana Iwayama Velho
@since 28/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
function J109Filtro(cCliente, cLoja, cCaso)
Local cArea   := GetArea()
Local cRet    := ""
Local cQry    := ""
Local aFiltro := {}
Local nQtd    := 0
Local nI      := 0
Local nTamFil := 1400 //A tecnologia promete 2000 bytes para o tamanho do filtro, mas o binario só esta aceitando por volta de 1400

cQry := " SELECT NWM.NWM_COD "+CRLF
cQry += " FROM " + RetSqlName("NWM") + " NWM "+CRLF
cQry += " LEFT OUTER JOIN " + RetSqlName("NWN") + " NWN ON NWN.NWN_FILIAL = '" + xFilial("NWN") + "' AND NWM.NWM_COD = NWN.NWN_CLOTE AND NWN.D_E_L_E_T_ = ' '"
cQry += " LEFT OUTER JOIN " + RetSqlName("NUT") + " NUT ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND NWM.NWM_CCONTR = NUT.NUT_CCONTR AND NUT.D_E_L_E_T_ = ' '"
cQry += " WHERE NWM.NWM_FILIAL = '" + xFilial("NWM") + "'"+CRLF
cQry +=    " AND NWM.D_E_L_E_T_ = ' ' "+CRLF
cQry +=    " AND NWM.NWM_CCLIEN = '"+cCliente+"'"+CRLF
cQry +=    " AND NWM.NWM_CLOJA = '"+cLoja+"'"+CRLF
cQry +=    " AND (NWN.NWN_CCASO = '"+cCaso+"' OR NUT.NUT_CCASO = '"+cCaso+"')"
cQry += " GROUP BY NWM.NWM_COD " + CRLF

aFiltro := JurSQL(cQry, {"NWM_COD"})

nQtd := Len(aFiltro)

If nQtd > 0

	For nI := 1 to nQtd
		cRet += "NWM_COD=='"+ aFiltro[nI][1] +"'"
		If nI != nQtd
			cRet += ".Or."
		EndIf

		If Len(cRet) > nTamFil
			Exit
		EndIf
	Next nI

Else
	cRet += " 1 == 2 "
EndIf

RestArea( cArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109VCaso
Validação de caso Conforme flag de Permição Lançamento Tabelado
FLAG

@Param cCaso Código do caso
@Param lTudOk   Verifica se a rotina foi chamada da validação do modelo

@return lRet	   .T. ou .F.

@author Luciano Pereira dos Santos
@since 27/07/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109VCaso(cCaso, lTudOk)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNVE   := NVE->(GetArea())
Local oModel     := FwModelActive()
Local oModelNWM  := Nil
Local cClient    := ''
Local cLoja	     := ''
Local cMvJCaso   := SuperGetMV( 'MV_JCASO1',, '1' ) // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)
Local cMsg       := ''
Local aCliLoj    := {}

Default cCaso    := ''
Default lTudOk   := .F.

If !Empty(cCaso) .And. oModel:GetId() == "JURA109"
	
	cMsg := Iif(lTudOk, cCaso, '')
	oModelNWM := oModel:GetModel("NWMMASTER")

	If cMvJCaso == "1"
		cClient   := oModelNWM:Getvalue("NWM_CCLIEN")
		cLoja     := oModelNWM:Getvalue("NWM_CLOJA")

		NVE->(DbSetOrder(1)) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC
		If NVE->(DbSeek(xFilial("NVE")+cClient+cLoja+cCaso))
			If NVE->NVE_LANTAB == "2"
				lRet := JurMsgErro(I18N(STR0057, {cMsg} )) //"O caso #1 não permite lançamento tabelado."
			EndIf
		Else
			lRet := JurMsgErro(I18N(STR0058, {cMsg})) //"O caso #1 não é válido para o cliente e loja do lançamento tabelado em lote."
		EndIf

	ElseIf cMvJCaso == "2"
		NVE->(dbSetOrder(3)) //NVE_FILIAL+NVE_NUMCAS+NVE_SITUAC
		If NVE->(dbSeek(xFilial('NVE')+cCaso))
			aCliLoj := JCasoAtual(cCaso)
			If !Empty(aCliLoj)
				cClient := aCliLoj[1][1]
				cLoja   := aCliLoj[1][2]
				If (cClient == oModelNWM:Getvalue("NWM_CCLIEN")) .OR. (cLoja == oModelNWM:Getvalue("NWM_CLOJA"))
					If NVE->NVE_LANTAB == "2"
						lRet := JurMsgErro(I18N(STR0057, {cMsg})) //"O caso #1 não permite lançamento tabelado."
					EndIf
				Else
					lRet := JurMsgErro(I18N(STR0058, {cMsg})) //"O caso #1 não é válido para o cliente e loja do lançamento tabelado em lote."
				EndIf
			Else
				lRet := JurMsgErro(I18N(STR0058, {cMsg})) //"O caso #1 não é válido para o cliente e loja do lançamento tabelado em lote."
			EndIf
		EndIf

	EndIf

EndIf

RestArea(aAreaNVE)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J109ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU 
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 20/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J109ClxGr()
Local lRet    := .F.
Local oModel  := FwModelActive()
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

cGrupo  := oModel:GetValue("NWMMASTER", "NWM_CGRUPO")
cClien  := oModel:GetValue("NWMMASTER", "NWM_CCLIEN")
cLoja   := oModel:GetValue("NWMMASTER", "NWM_CLOJA")

lRet := JurClxGr(cClien, cLoja, cGrupo)

Return lRet
