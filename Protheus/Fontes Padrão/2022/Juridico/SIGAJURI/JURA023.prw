#INCLUDE "JURA023.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//campos virtuais referentes à instância atual ou que utilizam função para mostrar o valor
#DEFINE CAMPOSNAOCONFIG 'NSZ_DCOMAR/NSZ_NUMPRO/NSZ_DLOC2N/NSZ_DLOC3N/NSZ_DNATUR/NSZ_DTIPAC/NSZ_PATIVO/'+;
						'NSZ_PPASSI/NSZ_TIPOPR/NSZ_CONMES/NUQ_INSATU/NUQ_CAJURI/NT9_CAJURI/'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA023
Campos Exportação Personalizada

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA023()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQ0" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQ0" )
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

@author Juliana Iwayama Velho
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA023", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA023", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA023", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA023", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA023", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0013, "Processa({|| JA023CONFG()})"     , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Campos Exportação Personalizada

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA023" )
Local oStructNQ0
Local oStructNQ2
Local oStructNQV
Local oStructNZJ
Local oView
Local lNZJInDic := FWAliasInDic("NZJ") //Verifica se existe a tabela NZJ - Fórmulas no Dicionário (Proteção)
Local lCpoNZJ := .F.

dbSelectArea('NZJ')
lCpoNZJ := ColumnPos('NZJ_COD') > 0

oStructNQ0 := FWFormStruct( 2, "NQ0" )
oStructNQ2 := FWFormStruct( 2, "NQ2" )
oStructNQV := FWFormStruct( 2, "NQV" )
If lNZJInDic
	oStructNZJ := FWFormStruct( 2, "NZJ" )
EndIf

oStructNQ2:RemoveField( "NQ2_CTABEL" )
oStructNQV:RemoveField( "NQV_CRELAC" )

JurSetAgrp( 'NQ0',, oStructNQ0 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA023_TABELA", oStructNQ0, "NQ0MASTER"  )
oView:AddGrid ( "JURA023_RELACI", oStructNQ2, "NQ2DETAIL"  )
oView:AddGrid ( "JURA023_CAMPOS", oStructNQV, "NQVDETAIL"  )

oView:CreateHorizontalBox( "FORMTABELA" , 15 )
oView:CreateHorizontalBox( "FORMRELACI" , 30 )
oView:CreateHorizontalBox( "FORMCAMPOS" , 35 )

oView:SetOwnerView( "NQ0MASTER" , "FORMTABELA" )
oView:SetOwnerView( "NQ2DETAIL" , "FORMRELACI" )
oView:SetOwnerView( "NQVDETAIL" , "FORMCAMPOS" )

oView:AddIncrementField( "NQ2DETAIL" , "NQ2_COD" )
oView:AddIncrementField( "NQVDETAIL" , "NQV_COD" )

If lNZJInDic
	oStructNZJ:RemoveField("NZJ_CRELAC")

	If lCpoNZJ
		oStructNZJ:SetProperty("NZJ_COD", MVC_VIEW_ORDEM, "01")
	EndIf

	oView:AddGrid("JURA023_FORMULA", oStructNZJ, "NZJDETAIL")
	oView:CreateHorizontalBox("FORMFORMUL", 20)
	oView:SetOwnerView("NZJDETAIL", "FORMFORMUL")
	If lCpoNZJ
		oView:AddIncrementField("NZJDETAIL" ,"NZJ_COD")
	EndIf
EndIf

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

oView:EnableTitleView( "JURA023_CAMPOS" )

If lNZJInDic
	oView:EnableTitleView( "JURA023_FORMULA" )
EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Campos Exportação Personalizada

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0

@obs NQVMASTER - Dados dos Campos Exportação Personalizada

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNQ0 := NIL
Local oStructNQ2 := NIL
Local oStructNQV := NIL
Local oStructNZJ := NIL
Local oModel     := NIL

Local lNZJInDic := FWAliasInDic("NZJ") //Verifica se existe a tabela NZJ - Fórmulas no Dicionário (Proteção)

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNQ0 := FWFormStruct(1,"NQ0")
oStructNQ2 := FWFormStruct(1,"NQ2")
oStructNQV := FWFormStruct(1,"NQV")
If lNZJInDic
	oStructNZJ := FWFormStruct(1,"NZJ")
EndIf

oStructNQ2:RemoveField( "NQ2_CTABEL" )
oStructNQV:RemoveField( "NQV_CRELAC" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA023", /*Pre-Validacao*/, {|oX|JA023TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NQ0MASTER", /*cOwner*/, oStructNQ0,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NQ0MASTER" ):SetDescription( STR0008 )

oModel:AddGrid( "NQ2DETAIL", "NQ0MASTER" /*cOwner*/, oStructNQ2, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NQ2DETAIL"  ):SetDescription( STR0009 )
oModel:SetRelation( "NQ2DETAIL", { { "NQ2_FILIAL", "XFILIAL('NQ0')" }, { "NQ2_CTABEL", "NQ0_COD" } }, NQ2->( IndexKey( 1 ) ) )

oModel:AddGrid( "NQVDETAIL", "NQ2DETAIL" /*cOwner*/, oStructNQV, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NQVDETAIL"  ):SetDescription( STR0030 )//"Campos"
oModel:SetRelation( "NQVDETAIL", { { "NQV_FILIAL", "XFILIAL('NQ2')" }, { "NQV_CRELAC", "NQ2_COD" } }, NQV->( IndexKey( 1 ) ) )

If lNZJInDic
	oModel:AddGrid( "NZJDETAIL", "NQ2DETAIL" /*cOwner*/, oStructNZJ, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NZJDETAIL"  ):SetDescription( STR0029 ) //"Fórmulas"
	oModel:SetRelation( "NZJDETAIL", { { "NZJ_FILIAL", "XFILIAL('NQ2')" }, { "NZJ_CRELAC", "NQ2_COD" } }, NZJ->( IndexKey( 2 ) ) )
	oModel:SetOptional( "NZJDETAIL" , .T. )
	JurSetRules( oModel, "NZJDETAIL",, 'NZJ' )

	oModel:GetModel( "NZJDETAIL" ):SetUniqueLine( {"NZJ_DESC", "NZJ_FUNC", "NZJ_PARAM"} )
EndIf

oModel:GetModel( "NQ2DETAIL" ):SetUniqueLine( { "NQ2_COD" } )
oModel:GetModel( "NQVDETAIL" ):SetUniqueLine( { "NQV_COD" } )

JurSetRules( oModel, "NQ0MASTER",, 'NQ0' )
JurSetRules( oModel, "NQ2DETAIL",, 'NQ2' )
JurSetRules( oModel, "NQVDETAIL",, 'NQV' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA023TOK(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNQ0 := NQ0->( GetArea() )
Local nOpc     := oModel:GetOperation()

If nOpc == 3 .Or. nOpc == 4
	If lRet
		lRet:= JA023VFILT()
	EndIf
EndIf

RestArea(aAreaNQ0)
RestArea(aArea   )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NCAMP
Retorna os campos para não aparecer na consulta padrão

@Return cRet	 	Filtro de campos

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023NCAMP()
Return " .AND. !X3_CAMPO $ ('"+CAMPOSNAOCONFIG+"')"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023VLDCP
Verifica se o campo digitado é permitido a configuração

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023VLDCP()
Local lRet := .T.

If !Empty (FwFldGet('NQV_CAMPO'))
	lRet := ! (FwFldGet('NQV_CAMPO') $ "('"+CAMPOSNAOCONFIG+"')")
EndIf

If !lRet .And. !Empty (FwFldGet('NQV_CAMPOT'))
	lRet := ! (FwFldGet('NQV_CAMPOT') $ "('"+CAMPOSNAOCONFIG+"')")
EndIf

If !lRet
	JurMsgErro(STR0012)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023VFILT
Valida se o campo de filtro possui os campos com apelido

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/12/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023VFILT()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oModelNQ2  := oModel:GetModel('NQ2DETAIL')
Local nCt        := 0
Local aApelid    := {}
Local aCampos    := {}

For nCt := 1 To oModelNQ2:GetQtdLine()

	oModelNQ2:GoLine( nCt )

	If !oModelNQ2:IsDeleted()

		If !Empty( oModelNQ2:GetValue('NQ2_FILTRO') )

			aApelid:= JurAtAll(AllTrim( FwFldGet('NQ2_APELID') )+'.', AllTrim( FwFldGet('NQ2_FILTRO') ))

			aCampos:= JurAtAll(PrefixoCpo( FwFldGet('NQ2_TABELA') )+'_', AllTrim( FwFldGet('NQ2_FILTRO') ))

			If ( Len(aCampos) == 0 .And. Len(aApelid) == 0 ) .Or. ( Len(aCampos) <> Len(aApelid) )

				lRet := .F.
				JurMsgErro(STR0010)
				Exit

			EndIf

		EndIf

	EndIf

Next

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023VAPE1
Valida se o apelido já existe

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/12/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023VAPE1()
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNQ0 := NQ0->( GetArea() )


	If !Empty( Posicione('NQ0', 3 , xFilial('NQ0') + FwFldGet('NQ0_APELID'), 'NQ0_COD') )
		lRet := .F.
		JurMsgErro(STR0011)
	EndIf


RestArea(aAreaNQ0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023VAPE2
Valida se o apelido já existe

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 22/12/09
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023VAPE2()
Local lRet     := .T.
Local aArea    := GetArea()
Local oModel   := FWModelActive()
Local oModelNQ2:= oModel:GetModel('NQ2DETAIL')
Local nCt      := 0

For nCt := 1 To oModelNQ2:GetQtdLine()

	oModelNQ2:GoLine( nCt )

	If !oModelNQ2:IsDeleted()

		If oModelNQ2:GetValue('NQ2_APELID') == FwFldGet('NQ2_APELID')

			lRet := .F.
			JurMsgErro(STR0011)
			Exit

		EndIf
	EndIf
Next

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023CONFG
Realiza a carga inicial da configuração de campos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 15/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023CONFG(lAutomato)
Local lRet     			:= .T.
Local oModel   			:= ModelDef()
Local lCadastroPadrao 	:= .T.
Local aArea    			:= GetArea()
Local nFlxCorres		:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

Default lAutomato := .F.

	If !lAutomato
		ProcRegua(0)
		IncProc(STR0031) //"Carga inicial está sendo efetuda..."
		lRet := ApMsgYesNo( STR0024 ) //"Serão incluídas novas tabelas da configuração de exportação personalizada padrão. Deseja continuar?"
	EndIf

	If lRet

		// Assunto Jurídico
		If lRet .And. !JA023EXTAB("NSZ",, lAutomato) //valida se a tabela já existe na configuração
			lRet:= JA023NSZ(oModel)
			lCadastroPadrao := .F.
		Endif

		// Instância Origem
		If lRet .And. !JA023EXTAB("NUQ", "NUQ001", lAutomato)
			lRet:= JA023NUQ(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Instância do Processo
		If lRet .And. !JA023EXTAB("NUQ", "NUQ002", lAutomato)
			lRet:= JA023NUQ02(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Instância do Andamento
		If lRet .And. !JA023EXTAB("NUQ", "NUQAND", lAutomato)
			lRet:= JA23NUQAND(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Instância do Follow-up
		If lRet .And. !JA023EXTAB("NUQ", "NUQFUP", lAutomato)
			lRet:= JA23NUQFUP(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Polo Ativo
		If lRet .And. !JA023EXTAB("NT9", "NT9001", lAutomato)
			lRet:= JA023NT901(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Polo Passivo
		If lRet .And. !JA023EXTAB("NT9", "NT9002", lAutomato)
			lRet:= JA023NT902(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Follow-up
		If lRet .And. !JA023EXTAB("NTA",, lAutomato)
			lRet:= JA023NTA(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Objetos
		If lRet .And. !JA023EXTAB("NSY",, lAutomato)
			lRet:= JA023NSY(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Garantias
		If lRet .And. !JA023EXTAB("NT2",, lAutomato)
			lRet:= JA023NT2(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Despesas
		If lRet .And. !JA023EXTAB("NT3",, lAutomato)
			lRet:= JA023NT3(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Andamentos
		If lRet .And. !JA023EXTAB("NT4",, lAutomato)
			lRet:= JA023NT4(oModel)
			lCadastroPadrao := .F.
		EndIf

		//Fluxo de correspondente Assunto Jurídico
		If nFlxCorres == 2

			If lRet .And. !JA023EXTAB("NSU",, lAutomato)
				lRet:= JA023NSU(oModel)
				lCadastroPadrao := .F.
			EndIf
		EndIf

		// Unidades
		If lRet .And. !JA023EXTAB("NYJ",, lAutomato)
			lRet:= JA023NYJ(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Acordos
		If lRet .And. !JA023EXTAB("NYP",, lAutomato)
			lRet:= JA023NYP(oModel)
			lCadastroPadrao := .F.
		EndIf

		// Solicitação de documentos
		If FWAliasInDic("O0M") .AND. FWAliasInDic("O0N")
			If lRet .And. !JA023ExTab("O0M",, lAutomato)
				lRet := JA023O0M(oModel)
				lCadastroPadrao := .F.
			EndIf

			If lRet .And. !JA023ExTab("O0N",, lAutomato)
				lRet := JA023O0N(oModel)
				lCadastroPadrao := .F.
			EndIf
		EndIf

		// Mensagem caso não tenha tido alterações
		If lCadastroPadrao
			lRet := .F.
			JurMsgErro( STR0022 )
		EndIf

	Endif

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NSZ
Inclusão de configuração de processo

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NSZ(oModel)
Local nI
Local lRet      := .T.
Local aNQV      := {}
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Processo
// !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', INFOSX2( FwFldGet('NQ0_TABELA'), 'X2_NOME' ) )  --- !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', INFOSX2( FwFldGet('NQ0_TABELA'), 'X2_NOME' ) )
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NSZ') .Or. ;
		!oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))) .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','NSZ001') .Or.!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0014 )
EndIf

//Instância ORIGEM
If lRet
	If !oModelNQ2:SetValue('NQ2_TABELA','NUQ') .Or.;
			!oModelNQ2:SetValue('NQ2_DTABEL',STR0032) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NUQ001') .Or.	!oModelNQ2:SetValue('NQ2_FILTRO',"NUQ001.NUQ_INSATU = '1'") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'NUQ_NUMPRO')
		lRet := .F.
		JurMsgErro( STR0014 )
	Else
		aAdd( aNQV, 'NUQ_CNATUR' )
		aAdd( aNQV, 'NUQ_CTIPAC' )
		aAdd( aNQV, 'NUQ_CCOMAR' )
		aAdd( aNQV, 'NUQ_CLOC2N' )
		aAdd( aNQV, 'NUQ_CLOC3N' )
		aAdd( aNQV, 'NUQ_INSTAN' )

		//Fluxo de correspondente por Assunto Jurídico
		If nFlxCorres == 2
			aAdd( aNQV, 'NUQ_CCORRE' )
			aAdd( aNQV, 'NUQ_LCORRE' )
		EndIf

		For nI := 1 To Len( aNQV )
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
				lRet := .F.
				JurMsgErro( STR0014 + ': '+aNQV[nI] )
				Exit
			EndIf
		Next

		aNQV := {}

	EndIf

	//Instância do Processo
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NUQ') .Or.;
				!oModelNQ2:SetValue('NQ2_DTABEL',JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NUQ002') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'NUQ_NUMPRO')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIF
	EndIf

	//Envolvido - pólo ativo princial
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NT9') .Or.;
				!oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NT9001') .Or.;
			!oModelNQ2:SetValue('NQ2_FILTRO',"NT9001.NT9_TIPOEN='1' AND NT9001.NT9_PRINCI = '1'") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'NT9_NOME')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO' ,'NT9_CTPENV')
				lRet := .F.
				JurMsgErro( STR0014)
			EndIf
		EndIf
	EndIf

	//Envolvido - pólo passivo princial
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NT9') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NT9002') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO',"NT9002.NT9_TIPOEN='2' AND NT9002.NT9_PRINCI = '1'") .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NT9_NOME')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO' ,'NT9_CTPENV')
				lRet := .F.
				JurMsgErro( STR0014)
			EndIf
		EndIf
	EndIf

	//Clientes
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SA1') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SA1001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'A1_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DCLIEN')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Caso
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NVE') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NVE001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NVE_TITULO') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DCASO')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Escritório
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NS7') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NS7001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NS7_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DESCRI')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Área
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NRB') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or. !oModelNQ2:SetValue('NQ2_APELID','NRB001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'NRB_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DAREAJ')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//SubÁrea
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NRL') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NRL001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'NRL_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DSUBAR')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Participante 1 - Coordenador
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','RD0') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID','RD0001') .Or.;
			!oModelNQ2:SetValue('NQ2_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CPART1') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'RD0_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DPART1')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Participante 2 - Advogado
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','RD0') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','RD0002') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','RD0002.RD0_CODIGO = NSZ001.NSZ_CPART2') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'RD0_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DPART2')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Participante 3 - Estagiário
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','RD0') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','RD0003') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','RD0003.RD0_CODIGO = NSZ001.NSZ_CPART3') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'RD0_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DPART3')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Participante 4 - Responsável Licitação
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','RD0') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','RD0004') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','RD0004.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'RD0_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_NOMRES')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor da Causa
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO001.CTO_MOEDA= NSZ001.NSZ_CMOCAU') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOCAU')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor do Contrato
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO002') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO002.CTO_MOEDA= NSZ001.NSZ_CMOCON') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOCON')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor Envolvido
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO003') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO003.CTO_MOEDA= NSZ001.NSZ_CMOENV') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOENV')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor da Licitação
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO004') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO004.CTO_MOEDA= NSZ001.NSZ_CMOLIC') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOLIC')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor Final
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO005') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO005.CTO_MOEDA= NSZ001.NSZ_CMOFIN') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOFIN')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Valor de Provisão
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO006') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','CTO006.CTO_MOEDA= NSZ001.NSZ_CMOPRO') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOPRO')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Classe
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NSV') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NSV001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NSV_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DCLASS')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Condição de pagamento
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SE4') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SE4001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'E4_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DCPCON')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Forma de Correção
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NW7') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NW7001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NW7_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DFCORR')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Modalidade
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY4') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY4001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY4_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMODLI')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Motivo de Encerramento
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQI') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQI001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NQI_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMOENC')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Município
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CC2') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CC2001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'CC2_MUN') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DMUNIC')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Prognóstico
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ7') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQ7001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO','NQ7001.NQ7_COD= NSZ001.NSZ_CPROGN') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'NQ7_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DPROGN')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Tipo de Contrato
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY0') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY0001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY0_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DESCON')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Natureza da Marca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY8') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY8001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY8_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DNATMA')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Objeto
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ4') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQ4001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NQ4_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DOBJET')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Situação da Marca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY7') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY7001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY7_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DSITMA')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Tipo da Marca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY6') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY6001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY6_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DTIPMA')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Critério
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NY5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NY5001') .Or. !oModelNQV:LoadValue('NQV_CAMPO' ,'NY5_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DCRIJU')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Depto Solicitante
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"SX5001.X5_TABELA= 'JZ' AND SX5001.X5_CHAVE= NSZ001.NSZ_CDPSOL") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DDPSOL')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Regional
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5002') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"SX5002.X5_TABELA= 'JY' AND SX5002.X5_CHAVE= NSZ001.NSZ_CREGIO") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DREGIO')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Subtipo Procuração
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5003') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"SX5003.X5_TABELA= 'J5' AND SX5003.X5_CHAVE= NSZ001.NSZ_CSBPRO") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DSBPRO')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Tipo de Sociedade
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5004') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"SX5004.X5_TABELA= 'J4' AND SX5004.X5_CHAVE= NSZ001.NSZ_CTPSOC") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSZ_DTPSOC')
			lRet := .F.
			JurMsgErro( STR0014 )
		EndIf
	EndIf

	//Follow-ups
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NTA') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NTA001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NTA_DTFLWP')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNQV, 'NTA_CTIPO'  )
			aAdd( aNQV, 'NTA_CRESUL' )
			aAdd( aNQV, 'NTA_DESC'   )

			//Fluxo de correspondente por Follow-up
			If nFlxCorres == 1
				aAdd( aNQV, 'NTA_CCORRE' )
				aAdd( aNQV, 'NTA_LCORRE' )
			EndIf

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNQV[nI] )
					Exit
				EndIf
			Next

			aNQV := {}
		EndIf

	EndIf

	//Valores
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NSY') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NSY001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NSY_PEDATA')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNQV, 'NSY_CMOPED' )
			aAdd( aNQV, 'NSY_PEVLR'  )
			aAdd( aNQV, 'NSY_PESOMA' )
			aAdd( aNQV, 'NSY_PEINVL' )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNQV[nI] )
					Exit
				EndIf
			Next

			aNQV := {}
		EndIf
	EndIf

	//Garantias
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NT2') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NT2001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"NT2001.NT2_MOVFIN= '1'") .Or.; //Filtro para buscar apenas garantias
			!oModelNQV:LoadValue('NQV_CAMPO','NT2_CTPGAR')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNQV, 'NT2_CGARAN' )
			aAdd( aNQV, 'NT2_MOVFIN' )
			aAdd( aNQV, 'NT2_DATA'   )
			aAdd( aNQV, 'NT2_CMOEDA' )
			aAdd( aNQV, 'NT2_VALOR'  )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNQV[nI] )
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	//Garantias
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NT3') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NT3001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NT3_CTPDES')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNQV, 'NT3_DATA'   )
			aAdd( aNQV, 'NT3_CMOEDA' )
			aAdd( aNQV, 'NT3_VALOR'  )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNQV[nI] )
					Exit
				EndIf
			Next

			aNQV := {}
		EndIf
	EndIf

	//Andamentos
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NT4') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NT4001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NT4_DTANDA')
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNQV, 'NT4_PCLIEN' )
			aAdd( aNQV, 'NT4_CFASE'  )
			aAdd( aNQV, 'NT4_CATO'   )
			aAdd( aNQV, 'NT4_DESC'   )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNQV[nI] )
					Exit
				EndIf
			Next

			aNQV := {}
		EndIf
	EndIf

	//Contrato correspondentes e Fluxo de correspondente por Assunto Jurídico
	If lRet .And. nFlxCorres == 2

		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NSU') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NSU001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NSU_CTCONT')
			lRet := .F.
			JurMsgErro( STR0023 ) //"Erro na carga da configuração inicial - Contrato Processo"
		Else
			aAdd( aNQV, 'NSU_INSTAN' )
			aAdd( aNQV, 'NSU_CFORNE' )
			aAdd( aNQV, 'NSU_LFORNE' )
			aAdd( aNQV, 'NSU_CPADRA' )
			aAdd( aNQV, 'NSU_VALOR'  )
			aAdd( aNQV, 'NSU_DETALH' )
			aAdd( aNQV, 'NSU_INIVGN' )
			aAdd( aNQV, 'NSU_FIMVGN' )
			aAdd( aNQV, 'NSU_NCAREN' )
			aAdd( aNQV, 'NSU_DCAREN' )
			aAdd( aNQV, 'NSU_DESAUT' )
			aAdd( aNQV, 'NSU_FLGREJ' )
			aAdd( aNQV, 'NSU_DTREAJ' )
			aAdd( aNQV, 'NSU_CMOEDA' )


			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0023 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Contrato Processo"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	//Unidades
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NYJ') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NYJ001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"NYJ001.NYJ_UNIDAD= '1'") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','NYJ_UNIDAD')
			lRet := .F.
			JurMsgErro( STR0023 ) //"Erro na carga da configuração inicial - Contrato Processo"
		Else
			aAdd( aNQV, 'NYJ_CCLIEN' )
			aAdd( aNQV, 'NYJ_LCLIEN' )
			aAdd( aNQV, 'NYJ_NOMEFT' )
			aAdd( aNQV, 'NYJ_TIPOP' )
			aAdd( aNQV, 'NYJ_CGC' )
			aAdd( aNQV, 'NYJ_DENOM' )
			aAdd( aNQV, 'NYJ_CTPSOC' )
			aAdd( aNQV, 'NYJ_DTCONS'  )
			aAdd( aNQV, 'NYJ_INSEST' )
			aAdd( aNQV, 'NYJ_INSMUN' )
			aAdd( aNQV, 'NYJ_NIRE' )
			aAdd( aNQV, 'NYJ_ALVARA' )
			aAdd( aNQV, 'NYJ_CNAE' )
			aAdd( aNQV, 'NYJ_LOGRAD' )
			aAdd( aNQV, 'NYJ_LOGNUM' )
			aAdd( aNQV, 'NYJ_COMPLE' )
			aAdd( aNQV, 'NYJ_BAIRRO' )
			aAdd( aNQV, 'NYJ_ESTADO' )
			aAdd( aNQV, 'NYJ_CMUNIC' )
			aAdd( aNQV, 'NYJ_CEP' )
			aAdd( aNQV, 'NYJ_DTABER' )
			aAdd( aNQV, 'NYJ_DTENCE' )


			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0023 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Contrato Processo"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

  //Aditivos
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NXY') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NXY001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NXY_ADITIV')
			lRet := .F.
			JurMsgErro( STR0023 ) //"Erro na carga da configuração inicial - Contrato Processo"
		Else
			aAdd( aNQV, 'NXY_DTASSI' )
			aAdd( aNQV, 'NXY_CTIPO' )
			aAdd( aNQV, 'NXY_NUMCON' )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0023 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Contrato Processo"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	//Acordos
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NYP') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NYP001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NYP_COD')
			lRet := .F.
			JurMsgErro( STR0023 ) //"Erro na carga da configuração inicial - Contrato Processo"
		Else
			aAdd( aNQV, 'NYP_DATA'   )
			aAdd( aNQV, 'NYP_CMOEDA' )
			aAdd( aNQV, 'NYP_VALOR'  )
			aAdd( aNQV, 'NYP_CONDPG' )
			aAdd( aNQV, 'NYP_QTPARC' )
			aAdd( aNQV, 'NYP_CBANCO' )
			aAdd( aNQV, 'NYP_CAGENC' )
			aAdd( aNQV, 'NYP_CCONTA' )
			aAdd( aNQV, 'NYP_DATALI' )
			aAdd( aNQV, 'NYP_TIPO'   )
			aAdd( aNQV, 'NYP_REALIZ' )
			aAdd( aNQV, 'NYP_OBSERV' )
			aAdd( aNQV, 'NYP_CCONT'  )
			aAdd( aNQV, 'NYP_FONE'   )
			aAdd( aNQV, 'NYP_EMAIL'  )
			aAdd( aNQV, 'NYP_CSTATU' )
			aAdd( aNQV, 'NYP_DATAIN' )
			aAdd( aNQV, 'NYP_USUIN'  )
			aAdd( aNQV, 'NYP_DATALT' )
			aAdd( aNQV, 'NYP_USUAL'  )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0023 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Contrato Processo"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	//Valores Históricos
	If lRet .And. FWAliasInDic("NYZ")
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NYZ') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NYZ001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"NYZ001.NYZ_ANOMES= ':ANOMES'")
			lRet := .F.
			JurMsgErro( STR0023 ) //"Erro na carga da configuração inicial - Valores Históricos"
		Else
			aAdd( aNQV, 'NYZ_ANOMES' )
			aAdd( aNQV, 'NYZ_CFCORR' )
			aAdd( aNQV, 'NYZ_VACAUS' )
			aAdd( aNQV, 'NYZ_VAENVO' )
			aAdd( aNQV, 'NYZ_VAHIST' )
			aAdd( aNQV, 'NYZ_VCPROV' )
			aAdd( aNQV, 'NYZ_VJPROV' )
			aAdd( aNQV, 'NYZ_VAPROV' )

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0023 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Contrato Processo"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	//Solicitação de Documentos
	If lRet .And. FWAliasInDic("O0M")
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','O0M') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','O0M001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"")
			lRet := .F.
			JurMsgErro( STR0038 ) //"Erro na carga da configuração inicial - Solicitação de Documentos"
		Else
			aAdd( aNQV, 'O0M_COD' 	)
			aAdd( aNQV, 'O0M_CAJURI'	)
			aAdd( aNQV, 'O0M_DTSOLI'	)
			aAdd( aNQV, 'O0M_USRSOL'	)
			aAdd( aNQV, 'O0M_OBS' 	)
			aAdd( aNQV, 'O0M_PRZSOL'	)

			For nI := 1 To Len( aNQV )
				oModelNQV:AddLine()
				If !oModelNQV:LoadValue('NQV_CAMPO',aNQV[nI])
					lRet := .F.
					JurMsgErro( STR0038 + ': '+aNQV[nI] ) //"Erro na carga da configuração inicial - Solicitação de Documentos"
					Exit
				EndIf
			Next

			aNQV := {}

		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

	oModel:DeActivate()

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NUQ
Inclusão de configuração de instância

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NUQ(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Instância
// OK
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NUQ') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL',STR0032) .Or.;
	!oModel:SetValue('NQ0MASTER','NQ0_APELID','NUQ001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0015 )
EndIf

If lRet
	//Tipo de Ação
	If !oModelNQ2:SetValue('NQ2_TABELA','NQU')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2(FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or.;
		!oModelNQ2:SetValue('NQ2_APELID','NQU001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DTIPAC')
		lRet := .F.
		JurMsgErro( STR0015 )
	EndIf

	//Natureza
   	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ1')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQ1001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQ1_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DNATUR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Comarca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ6') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NQ6001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQ6_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCOMAR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 2. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQC')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQC001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQC_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC2N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 3. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQE')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQE001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQE_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC3N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Advogado
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SU5')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','SU5001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DADVOG')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Decisão
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQQ')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQQ001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DDECIS')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Correspondente
	If lRet

		//Fluxo de correspondente por Assunto Jurídico
		If nFlxCorres == 2
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SA2')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID',JA023GAPEL("SA2")) .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','A2_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCORRE')
				lRet := .F.
				JurMsgErro( STR0015 )
			EndIf
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NUQ02
Inclusão de configuração de instância

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Beatriz Gomes
@since 10/10/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NUQ02(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Instância
// OK
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NUQ') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL',INFOSX2(FwFldGet('NQ0_TABELA'), 'X2_NOME' )) .Or.;
	!oModel:SetValue('NQ0MASTER','NQ0_APELID','NUQ002') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
	lRet := .F.
	JurMsgErro( STR0015 )
EndIf

If lRet
	//Tipo de Ação
	If !oModelNQ2:SetValue('NQ2_TABELA','NQU')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2(FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NQU001') .Or.;
		!oModelNQV:LoadValue('NQV_CAMPO','NQU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DTIPAC')
		lRet := .F.
		JurMsgErro( STR0015 )
	EndIf

	//Natureza
   	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ1')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQ1001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQ1_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DNATUR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Comarca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ6') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NQ6001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQ6_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCOMAR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 2. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQC')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQC001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQC_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC2N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 3. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQE')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQE001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQE_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC3N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Advogado
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SU5')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','SU5001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DADVOG')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Decisão
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQQ')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID','NQQ001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DDECIS')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Correspondente
	If lRet

		//Fluxo de correspondente por Assunto Jurídico
		If nFlxCorres == 2
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SA2')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or. !oModelNQ2:SetValue('NQ2_APELID',JA023GAPEL("SA2")) .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','A2_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCORRE')
				lRet := .F.
				JurMsgErro( STR0015 )
			EndIf
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA23NUQAND
Inclusão de configuração de instância

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Beatriz Gomes
@since 10/10/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA23NUQAND(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Instância
// OK
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NUQ') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL',STR0033) .Or.;
	!oModel:SetValue('NQ0MASTER','NQ0_APELID','NUQAND') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0015 )
EndIf

If lRet
	//Tipo de Ação
	If !oModelNQ2:SetValue('NQ2_TABELA','NQU')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2(FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or.;
		!oModelNQ2:SetValue('NQ2_APELID','NQUAND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DTIPAC')
		lRet := .F.
		JurMsgErro( STR0015 )
	EndIf

	//Natureza
   	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ1')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQ1AND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQ1_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DNATUR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Comarca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ6') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQ6AND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQ6_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCOMAR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 2. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQC')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQCAND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQC_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC2N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 3. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQE')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQEAND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQE_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC3N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Advogado
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SU5') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','SU5AND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DADVOG')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Decisão
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQQ')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQQAND') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DDECIS')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Correspondente
	If lRet

		//Fluxo de correspondente por Assunto Jurídico
		If nFlxCorres == 2
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SA2')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID',JA023GAPEL("SA2")) .Or. !oModelNQV:LoadValue('NQV_CAMPO','A2_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCORRE')
				lRet := .F.
				JurMsgErro( STR0015 )
			EndIf
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} JA23NUQFUP
Inclusão de configuração de instância

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Beatriz Gomes
@since 10/10/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA23NUQFUP(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Instância
// OK
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NUQ') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL',STR0034) .Or.;
	!oModel:SetValue('NQ0MASTER','NQ0_APELID','NUQFUP') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0015 )
EndIf

If lRet
	//Tipo de Ação
	If !oModelNQ2:SetValue('NQ2_TABELA','NQU') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2(FwFldGet('NQ2_TABELA'), 'X2_NOME' ))  .Or.;
		!oModelNQ2:SetValue('NQ2_APELID','NQUFUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DTIPAC')
		lRet := .F.
		JurMsgErro( STR0015 )
	EndIf

	//Natureza
   	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ1') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQ1FUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQ1_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DNATUR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Comarca
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQ6') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQ6FUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQ6_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCOMAR')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 2. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQC')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQCFUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQC_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC2N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Loc. 3. nivel
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQE')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQEFUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQE_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DLOC3N')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Advogado
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SU5')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','SU5FUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DADVOG')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Decisão
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQQ')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQQFUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DDECIS')
			lRet := .F.
			JurMsgErro( STR0015 )
		EndIf
	EndIf

	//Correspondente
	If lRet

		//Fluxo de correspondente por Assunto Jurídico
		If nFlxCorres == 2
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SA2')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', INFOSX2( FwFldGet('NQ2_TABELA'), 'X2_NOME' )) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID',JA023GAPEL("SA2")) .Or. !oModelNQV:LoadValue('NQV_CAMPO','A2_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NUQ_DCORRE')
				lRet := .F.
				JurMsgErro( STR0015 )
			EndIf
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NT901
Inclusão de configuração de envolvido ativo principal

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NT901(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Envolvido Principal Ativo
//OK
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NT9') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL' , STR0027)  .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','NT9001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0016 )

Else
	//Tipo de Envolvimento
	If !oModelNQ2:SetValue('NQ2_TABELA','NQA') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQA001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQA_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DTPENV')
		lRet := .F.
		JurMsgErro( STR0016 )
	EndIf

	//Cargo Cliente
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NRP')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NRP001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NRP_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DCGECL')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf
	EndIf

	//Cargo Funcionário
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NRP')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NRP002') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NRP_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DCRGDP')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf
	EndIf

	//Situação
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NXU')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NXU001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NXU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DSITUA')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf
	EndIf

	//Departamento
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5001') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"SX5001.X5_TABELA= 'JZ' AND SX5001.X5_CHAVE= NT9001.NT9_CDPENV") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DDPENV')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf
	EndIf

	//Nacionalidade
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5002') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO',"SX5002.X5_TABELA= '34' AND SX5002.X5_CHAVE= NT9001.NT9_CNACIO") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DNACIO')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf
EndIf

oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NT902
Inclusão de configuração de envolvido passivo principal

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NT902(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Envolvido Principal Passivo
//OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NT9') .Or. !oModel:SetValue( 'NQ0MASTER', 'NQ0_DTABEL' ,STR0028)  .Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_APELID','NT9002') .Or.; //"Pólo Passivo"
			!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
		lRet := .F.
		JurMsgErro( STR0016 )
	Else
		//Tipo de Envolvimento
		If !oModelNQ2:SetValue('NQ2_TABELA','NQA')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQA002') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQA_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DTPENV')
			lRet := .F.
			JurMsgErro( STR0016 )
		EndIf

		//Cargo Cliente
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NRP')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NRP003') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NRP_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DCGECL')
				lRet := .F.
				JurMsgErro( STR0016 )
			EndIf
		EndIf

		//Cargo Funcionário
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NRP')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NRP004') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NRP_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DCRGDP')
				lRet := .F.
				JurMsgErro( STR0016 )
			EndIf
		EndIf

		//Situação
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NXU')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NXU002') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NXU_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DSITUA')
				lRet := .F.
				JurMsgErro( STR0016 )
			EndIf
		EndIf

		//Departamento
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','SX5003') .Or.;
					!oModelNQ2:SetValue('NQ2_FILTRO',"SX5003.X5_TABELA= 'JZ' AND SX5003.X5_CHAVE= NT9002.NT9_CDPENV") .Or.;
					!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DDPENV')
				lRet := .F.
				JurMsgErro( STR0016 )
			EndIf
		EndIf

		//Nacionalidade
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5004') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO',"SX5004.X5_TABELA= '34' AND SX5004.X5_CHAVE= NT9002.NT9_CNACIO") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT9_DNACIO')
				lRet := .F.
				JurMsgErro( STR0016 )
			EndIf
		EndIf

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NTA
Inclusão de configuração de follow-up

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NTA(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local nFlxCorres:= SuperGetMV("MV_JFLXCOR", , 1)	//Fluxo de correspondente por Follow-up ou Assunto Jurídico? (1=Follow-up ; 2=Assunto Jurídico)"

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Follow-up
// OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NTA').Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))) .Or.;
			 !oModel:SetValue('NQ0MASTER','NQ0_APELID','NTA001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
		lRet := .F.
		JurMsgErro( STR0017 )
	Else
		//Tipo de Follow-up
		If !oModelNQ2:SetValue('NQ2_TABELA','NQS') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQS001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQS_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DTIPO')
			lRet := .F.
			JurMsgErro( STR0017 )
		Else
			//Resultado de follow-up
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NQN') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NQN001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQN_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DRESUL')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NUQ') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', STR0034) .Or. ;
				!oModelNQ2:SetValue('NQ2_APELID','NUQFUP') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NUQ_NUMPRO') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO',"NUQFUP.NUQ_COD = NTA001.NTA_CINSTA")
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf

		//Advogado
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','SU5') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','SU5001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DADVCR')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf

		//Fase
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NQG') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NQG001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQG_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DFASE')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf

		//Preposto
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NQM') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NQM001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NQM_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DPREPO')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf

		//Ato
		If lRet
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NRO') .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NRO001') .Or. !oModelNQV:LoadValue('NQV_CAMPO','NRO_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DATO')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		EndIf

		//Correspondente
		If lRet

			//Fluxo de correspondente por Follow-up
			If nFlxCorres == 1
				oModelNQ2:AddLine()
				If !oModelNQ2:SetValue('NQ2_TABELA','SA2')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
						!oModelNQ2:SetValue('NQ2_APELID',JA023GAPEL("SA2")) .Or.;
						!oModelNQV:LoadValue('NQV_CAMPO','A2_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NTA_DCORRE')
					lRet := .F.
					JurMsgErro( STR0017 )
				EndIf
			EndIf

		EndIf

		//Responsavel
		If lRet
		oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NTE') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or. !oModelNQ2:SetValue('NQ2_APELID','NTE001') .Or.;
			 !oModelNQV:LoadValue('NQV_CAMPO' ,'NTE_CPART')
				lRet := .F.
				JurMsgErro( STR0017 )
			EndIf
		Endif

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NSY
Inclusão de configuração de valores

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NSY(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Valores
// OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NSY') .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))) .Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_APELID','NSY001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
		lRet := .F.
		JurMsgErro( STR0018 )
	Else
		//Moeda do Pedido
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID','CTO002') .Or.;
			!oModelNQ2:SetValue('NQ2_FILTRO','CTO002.CTO_MOEDA = NSY001.NSY_CMOPED') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSY_DMOPED')
			lRet := .F.
			JurMsgErro( STR0018 )
		EndIf

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NT2
Inclusão de configuração de garantias

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NT2(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Garantias
// OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NT2')  .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_APELID','NT2001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
		lRet := .F.
		JurMsgErro( STR0019 )
	Else
		//Moeda da Garantia
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO').Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','CTO003') .Or.;
			!oModelNQ2:SetValue('NQ2_FILTRO','CTO003.CTO_MOEDA = NT2001.NT2_CMOEDA') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT2_DMOEDA')
			lRet := .F.
			JurMsgErro( STR0019 )
		Else
			//Tipo de follow-up
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NQW').Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NQW001') .Or.;
					!oModelNQV:LoadValue('NQV_CAMPO','NQW_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT2_DTPGAR')
				lRet := .F.
				JurMsgErro( STR0019 )
			EndIf
		EndIf

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NT3
Inclusão de configuração de despesas

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NT3(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Despesas
//OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NT3') .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA')) ) .Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_APELID','NT3001') .Or. !oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
		lRet := .F.
		JurMsgErro( STR0020 )
	Else
		//Moeda da Despesa
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO004') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO','CTO004.CTO_MOEDA = NT3001.NT3_CMOEDA') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT3_DMOEDA')
			lRet := .F.
			JurMsgErro( STR0020 )
		Else
			//Tipo de despesa
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NSR') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
					!oModelNQ2:SetValue('NQ2_APELID','NSR001') .Or.;
					!oModelNQV:LoadValue('NQV_CAMPO','NSR_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT3_DTPDES')
				lRet := .F.
				JurMsgErro( STR0020 )
			EndIf

		EndIf

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NT4
Inclusão de configuração de andamento

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 19/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NT4(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Andamentos
// Ok
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NT4') .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','NT4001') .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
	lRet := .F.
	JurMsgErro( STR0021 )
EndIf

If lRet
	//Fase
	If !oModelNQ2:SetValue('NQ2_TABELA','NQG') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NQG001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NQG_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT4_DFASE')
		lRet := .F.
		JurMsgErro( STR0021 )
	EndIf

	//Ato
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NRO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NRO001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','NRO_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT4_DATO')
			lRet := .F.
			JurMsgErro( STR0021 )
		EndIf
	EndIf

	//Perito
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NQL') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','NQL001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','NQL_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NT4_DPERIT')
			lRet := .F.
			JurMsgErro( STR0021 )
		EndIf
	EndIf

	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','NUQ') .Or. !oModelNQ2:SetValue('NQ2_DTABEL',STR0033) .Or. !oModelNQ2:SetValue('NQ2_APELID','NUQAND') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NUQ_NUMPRO') .Or. !oModelNQ2:SetValue('NQ2_FILTRO',"NUQAND.NUQ_COD = NT4001.NT4_CINSTA")
			lRet := .F.
			JurMsgErro( STR0021 )
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023Grava
Grava a configuração de tabelas, relacionamentos e campos

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 18/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023Grava(oModel, lRet)
Local aErro:= {}

If lRet .AND. !JurAuto()
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf

EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} JA023X3Des
Retorna o conteúdo do campo "X3_Descric" da tabela SX3, indicado pelo parametro

@Param cCampo	Nome do campo do qual deseja que a descrição
@Return cRet Retorna o conteúdo do campo "X3_Descric" da tabela SX3, indicado pelo parametro

@author Rafael Rezende Costa
@since 22/10/12
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023X3Des(cCampo)
Local aAreaSX3 := SX3->( GetArea() )
Local aArea       := GetArea()
Local lRet   		:= .F.
Local cRet 		:= ''

If !Empty(cCampo)
	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )
	lRet := SX3->( dbSeek(cCampo) )

	If lRet  := .T.
		If __Language == "PORTUGUESE"
			cRet := allTrim( SX3->X3_DESCRIC)
		ElseIf __Language == "ENGLISH"
			cRet := allTrim( SX3->X3_DESCENG)
		Else
			cRet := allTrim( SX3->X3_DESCSPA)
		EndIF
	EndIf
EndIf

RestArea(aAreaSX3)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NSU
Inclusão de configuração de contrato de correspondentes

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Andr[e Spirigoni Pinto
@since 09/09/13
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NSU(oModel)
Local lRet := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local cApelCTO := JA023GAPEL("CTO")

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Contratos de Correspondentes
// OK
If lRet
	If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NSU')  .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_APELID','NSU001') .Or.;
			!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
		lRet := .F.
		JurMsgErro( STR0019 )
	Else
		//Moeda do contrato
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO').Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID',cApelCTO) .Or.;
			!oModelNQ2:SetValue('NQ2_FILTRO',cApelCTO + '.CTO_MOEDA = NSU001.NSU_CMOEDA') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSU_DMOEDA')
			lRet := .F.
			JurMsgErro( STR0019 )
		Else
			//Tipo de contratos
			oModelNQ2:AddLine()
			If !oModelNQ2:SetValue('NQ2_TABELA','NSQ').Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or. !oModelNQ2:SetValue('NQ2_APELID','NSQ001') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO','NSQ001.NSQ_COD = NSU001.NSU_CTCONT') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','NSQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NSU_DTCONT')
				lRet := .F.
				JurMsgErro( STR0019 )
			EndIf
		EndIf

		If lRet
			JA023Grava(oModel, lRet)
		EndIf
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NYP
Inclusão de configuração de acordos

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio Carlos Ferreira
@since 06/02/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NYP(oModel)
Local lRet      := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Acordos
// Ok
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NYP') .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','NYP001') .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
	lRet := .F.
	JurMsgErro( STR0025 ) //"Erro na carga da configuração inicial - Acordos"
EndIf

If lRet
	//Status de Acordo
	If !oModelNQ2:SetValue('NQ2_TABELA','NYQ') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NYQ001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','NYQ_DESC') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYP_DSTATU')
		lRet := .F.
		JurMsgErro( STR0025 ) //"Erro na carga da configuração inicial - Acordos"
	EndIf

	//Agência
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SA6') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SA6001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','A6_NOMEAGE') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYP_DAGENC')
			lRet := .F.
			JurMsgErro( STR0025 )
		Else
			//Banco
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO' ,'A6_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYP_DBANCO')
				lRet := .F.
				JurMsgErro( STR0025 )
			EndIf
		EndIf
	EndIf

	//Contato
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SU5')  .Or. !oModelNQ2:SetValue( 'NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SU5001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','U5_CONTAT') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYP_DCONT')
			lRet := .F.
			JurMsgErro( STR0025 )
		EndIf
	EndIf

	//Moeda
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYP_DMOEDA')
			lRet := .F.
			JurMsgErro( STR0026 )
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023NYJ
Inclusão de configuração de acordos

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 25/04/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023NYJ(oModel)
Local lRet      := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Acordos
// Ok
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','NYJ') .Or. !oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA')) ).Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','NYJ001') .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
	lRet := .F.
	JurMsgErro( STR0026 ) //"Erro na carga da configuração inicial - Unidades"
EndIf

If lRet
	//Status de Acordo
	If !oModelNQ2:SetValue('NQ2_TABELA','SA1') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','SA1001') .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','A1_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYJ_DCLIEN')
		lRet := .F.
		JurMsgErro( STR0026 ) //"Erro na carga da configuração inicial - Unidades"
	EndIf

	//Moeda Capital
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CTO') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CTO001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','CTO_SIMB') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYJ_DMOCAP')
			lRet := .F.
			JurMsgErro( STR0026 )
		EndIf
	EndIf

	//Município
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','CC2') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','CC2001') .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO','CC2_MUN') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYJ_DMUNIC')
			lRet := .F.
			JurMsgErro( STR0026 )
		EndIf
	EndIf

	//Tipo de Sociedade
	If lRet
		oModelNQ2:AddLine()
		If !oModelNQ2:SetValue('NQ2_TABELA','SX5') .Or. !oModelNQ2:SetValue('NQ2_DTABEL', JA023TIT(FwFldGet('NQ2_TABELA')))  .Or.;
				!oModelNQ2:SetValue('NQ2_APELID','SX5001') .Or.;
				!oModelNQ2:SetValue('NQ2_FILTRO',"SX5001.X5_TABELA= 'J4' AND SX5001.X5_CHAVE= NSZ001.NYJ_CTPSOC") .Or.;
				!oModelNQV:LoadValue('NQV_CAMPO' ,'X5_DESCRI') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','NYJ_DTPSOC')
			lRet := .F.
			JurMsgErro( STR0026 )
		EndIf
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023O0M
Inclusão de configuração de Solicitação de Documentos

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio Carlos Ferreira
@since 06/02/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023O0M(oModel)
Local lRet      := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local aO0N      := {}
Local nI        := 0

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Solicitação de Documentos
// Ok
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','O0M') .Or. ;
		!oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','O0M001') .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','1')
	lRet := .F.
	JurMsgErro( STR0038 ) //"Erro na carga da configuração inicial - Solicitação de Documentos"
EndIf

If lRet
	// Itens da Solicitação
	If !oModelNQ2:SetValue('NQ2_TABELA','O0N') .Or.;
			!oModelNQ2:SetValue('NQ2_DTABEL',JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','O0N001') .Or.	!oModelNQ2:SetValue('NQ2_FILTRO',"") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'O0N_CTPDOC')
		lRet := .F.
		JurMsgErro( STR0038 )
	Else
		aAdd( aO0N, 'O0N_CPART' )

		For nI := 1 To Len( aO0N )
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO',aO0N[nI])
				lRet := .F.
				JurMsgErro( STR0038 + ': '+aO0N[nI] )
				Exit
			EndIf
		Next

		aO0N := {}

	EndIf

	// Envolvido
	oModelNQ2:AddLine()
	If !oModelNQ2:SetValue('NQ2_TABELA','NT9') .Or.;
			!oModelNQ2:SetValue('NQ2_DTABEL',JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','NT9001') .Or.	!oModelNQ2:SetValue('NQ2_FILTRO',"") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO' ,'NT9_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT' ,'O0M_DENVOL')
		lRet := .F.
		JurMsgErro( STR0038 )
	EndIf

	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023O0N
Inclusão de configuração de Solicitação de Documentos

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Antonio Carlos Ferreira
@since 06/02/14
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA023O0N(oModel)
Local lRet      := .T.
Local oModelNQ2 := oModel:GetModel('NQ2DETAIL')
Local oModelNQV := oModel:GetModel('NQVDETAIL')
Local aRD0      := {}
Local nI        := 0

oModel:SetOperation( 3 )
oModel:Activate()

//Configuração para Solicitação de Documentos
// Ok
If !oModel:SetValue('NQ0MASTER','NQ0_TABELA','O0N') .Or. ;
		!oModel:SetValue('NQ0MASTER','NQ0_DTABEL', JA023TIT(FwFldGet('NQ0_TABELA'))).Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_APELID','O0N001') .Or.;
		!oModel:SetValue('NQ0MASTER','NQ0_AGRUPA','2')
	lRet := .F.
	JurMsgErro( STR0038 ) //"Erro na carga da configuração inicial - Solicitação de Documentos"
EndIf

If lRet
	If !oModelNQ2:SetValue('NQ2_TABELA','O0L') .Or.;
			!oModelNQ2:SetValue('NQ2_DTABEL',JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','O0L001') .Or.	!oModelNQ2:SetValue('NQ2_FILTRO',"") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','O0L_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','O0N_DTPDOC')
		lRet := .F.
		JurMsgErro( STR0038 )
	EndIf

	oModelNQ2:AddLine()
	If !oModelNQ2:SetValue('NQ2_TABELA','RD0') .Or.;
			!oModelNQ2:SetValue('NQ2_DTABEL',JA023TIT(FwFldGet('NQ2_TABELA'))) .Or.;
			!oModelNQ2:SetValue('NQ2_APELID','RD0001') .Or.	!oModelNQ2:SetValue('NQ2_FILTRO',"") .Or.;
			!oModelNQV:LoadValue('NQV_CAMPO','RD0_NOME') .Or. !oModelNQV:LoadValue('NQV_CAMPOT','O0N_DPART')
		lRet := .F.
		JurMsgErro( STR0038 )
	Else
		aAdd( aRD0, {'RD0_SIGLA','O0N_SIGLA'} )

		For nI := 1 To Len( aRD0 )
			oModelNQV:AddLine()
			If !oModelNQV:LoadValue('NQV_CAMPO',aRD0[nI][1]) .Or. !oModelNQV:LoadValue('NQV_CAMPOT',aRD0[nI][2])
				lRet := .F.
				JurMsgErro( STR0038 + ': '+ aRD0[nI][1] + '/' + aRD0[nI][2] )
				Exit
			EndIf
		Next

		aRD0 := {}

	EndIf
	If lRet
		JA023Grava(oModel, lRet)
	EndIf

EndIf

oModel:DeActivate()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023EXTAB
Valida se a tabela já está configurada na NQ0

@Param cTab		Tabela que será validada na NQ0

@Return lRet	 	.T./.F. Se a tabela existe ou não na configuração.

@author André Spirigoni Pinto
@since 09/09/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023EXTAB(cTab, cApel, lAutomato)
Local lRet := .F.
Local aArea    := GetArea()
Local aAreaNQ0 := NQ0->( GetArea() )

Default cApel     := ""
Default lAutomato := .F.

	If !Empty(cApel)
		dbSelectArea('NQ0')
		dbSetOrder(3)

		If dbSeek(xFilial('NQ0') + cApel)
			lRet := .T.
		Endif
	Else
		dbSelectArea('NQ0')
		dbSetOrder(2)

		If dbSeek(xFilial('NQ0') + cTab)
			lRet := .T.
		Endif
	EndIf

	If lAutomato
		lRet := .F.
	EndIf

	RestArea(aAreaNQ0)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023GAPEL
Pega no banco de dados a último apelido usado por alguma tabela

@Param cTab		Tabela que será validada na NQ2

@Return cRet	 	O apelido que deverá ser usado.

@author André Spirigoni Pinto
@since 13/09/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023GAPEL(cTab)
Local cRet      := cTab
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()

BeginSql Alias cAliasQry
		SELECT MAX(NQ2_APELID) APELIDO
		FROM %table:NQ2% NQ2
		WHERE NQ2.NQ2_TABELA = %Exp:cTab%
		AND NQ2.NQ2_FILIAL = %xFilial:NQ2%
		AND NQ2.%notDel%
EndSql

dbSelectArea(cAliasQry)
(cAliasQry)->(DbgoTop())

If !(cAliasQry)->( EOF())
	cRet := cRet + PadL(AllTrim(Str(val(SubStr((cAliasQry)->APELIDO,4,3))+1)),3,'0')
Else
	cRet := cRet + "001"
End

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA023TIT
Pega o titulo da tabela de acordo com o idioma

@Param cTab		Tabela para buscar o titulo

@Return cTit	 	Titulo atualizado de acordo com o idioma

@author Beatriz Gomes
@since 23/08/17
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA023TIT(cTab)
Local cTit := ''

	IF __Language == "PORTUGUESE"
		cTit := INFOSX2( cTab, 'X2_NOME' )
	ElseIF __Language == "ENGLISH"
		cTit := INFOSX2( cTab, 'X2_NOMEENG' )
	Else
		cTit := INFOSX2( cTab, 'X2_NOMESPA' )
	EndIf

Return cTit
