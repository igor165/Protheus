#INCLUDE "JURA009.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA009 
Tipo de Envolvimento

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA009()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQA" )
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

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA009", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA009", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA009", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA009", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA009", 0, 8, 0, NIL } ) //"Imprimir"
aAdd( aRotina, { STR0010, "JA009CFG"	 	 , 0, 3, 0, NIL } ) //"Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Envolvimento

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA009" )
Local oStruct := FWFormStruct( 2, "NQA" )

JurSetAgrp( 'NQA',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA009_VIEW", oStruct, "NQAMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA009_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Tipo de Envolvimento"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Envolvimento

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0

@obs NQAMASTER - Dados do Tipo de Envolvimento

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQA := FWFormStruct( 1, "NQA" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA009", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA009Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQAMASTER", NIL, oStructNQA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Tipo de Envolvimento"
oModel:GetModel( "NQAMASTER" ):SetDescription( STR0009 ) //"Dados de Tipo de Envolvimento"

JurSetRules( oModel, 'NQAMASTER',, 'NQA' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA009Commit
Commit de dados de Tipo de envolvimento

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA009Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQAMASTER","NQA_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3 .AND. !IsInCallStack("JA009CFG")
		lRet := JurSetRest('NQA',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA009CFG()
Rotina que faz a chamada do processamento da carga inicial

@author Reginaldo Natal Soares
@since 02/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA009CFG()

Local lExiste    	:= .F.
Local nI			:= 0
Local aPlvdes		:= {}

If IsInCallStack("JurLoadAsJ") .Or. ApMsgYesNo( STR0011 ) //"Serão incluídos novos Tipos de Envolvimento padrão. Deseja continuar?"

	aAdd( aPlvdes, {STR0014, "2", "2", "1"} ) //"Advogado da parte contrária"
	aAdd( aPlvdes, {STR0015, "2", "1", "2"} ) //"Agravado"
	aAdd( aPlvdes, {STR0016, "1", "2", "2"} ) //"Agravante"
	aAdd( aPlvdes, {STR0017, "2", "1", "2"} ) //"Apelado"
	aAdd( aPlvdes, {STR0018, "1", "2", "2"} ) //"Apelante"
	aAdd( aPlvdes, {STR0019, "1", "2", "2"} ) //"Autor"
	aAdd( aPlvdes, {STR0020, "2", "1", "2"} ) //"Contratado"
	aAdd( aPlvdes, {STR0021, "1", "2", "2"} ) //"Contratante"
	aAdd( aPlvdes, {STR0022, "2", "1", "2"} ) //"Denunciado"
	aAdd( aPlvdes, {STR0023, "1", "2", "2"} ) //"Denunciante"
	aAdd( aPlvdes, {STR0024, "2", "1", "2"} ) //"Embargado"
	aAdd( aPlvdes, {STR0025, "1", "2", "2"} ) //"Embargante"
	aAdd( aPlvdes, {STR0026, "2", "1", "2"} ) //"Executado"
	aAdd( aPlvdes, {STR0027, "1", "2", "2"} ) //"Exequente"
	aAdd( aPlvdes, {STR0028, "2", "1", "2"} ) //"Impetrado"
	aAdd( aPlvdes, {STR0029, "1", "2", "2"} ) //"Impetrante"
	aAdd( aPlvdes, {STR0030, "2", "1", "2"} ) //"Outorgado"
	aAdd( aPlvdes, {STR0031, "1", "2", "2"} ) //"Outorgante"
	aAdd( aPlvdes, {STR0032, "2", "1", "2"} ) //"Reclamado"
	aAdd( aPlvdes, {STR0033, "1", "2", "2"} ) //"Reclamante"
	aAdd( aPlvdes, {STR0034, "1", "2", "2"} ) //"Recorrente"
	aAdd( aPlvdes, {STR0035, "2", "1", "2"} ) //"Recorrido"
	aAdd( aPlvdes, {STR0036, "2", "1", "2"} ) //"Réu" 
	aAdd( aPlvdes, {STR0037, "2", "2", "1"} ) //"Terceiro Interessado"
	aAdd( aPlvdes, {STR0038, "2", "2", "1"} ) //"Testemunha"
	aAdd( aPlvdes, {STR0039, "2", "2", "1"} ) //"Representante Legal"
	aAdd( aPlvdes, {STR0040, "2", "2", "1"} ) //"Interlocutor"
	aAdd( aPlvdes, {STR0041, "1", "2", "2"} ) //"Beneficiário"
	aAdd( aPlvdes, {STR0042, "2", "1", "2"} ) //"Operadora"
	
	For nI:=1 To Len(aPlvdes)

		lExiste := JA009PLVDE(aPlvdes[nI][1])
		If !lExiste
			If !JA009AddTipo(aPlvdes[nI])
				Exit
			EndIf
		EndIf
	Next nI
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA009AddTipo
Realiza a inclusão de Tipos de envolvimento, via modelo

@param aPlvdes    array com os dados do tipo a ser adicionado
                  aPlvdes[1] - NQA_DESC
                  aPlvdes[2] - NQA_POLOAT
                  aPlvdes[3] - NQA_POLOPA
                  aPlvdes[4] - NQA_TERCIN
@return lRet      .T./ .F. se gravou
@since 05/08/2021
/*/
//-------------------------------------------------------------------
Function JA009AddTipo(aPlvdes)

Local aArea      := GetArea()
Local lRet       := .T.
Local oModel     := ModelDef()

	oModel:SetOperation( 3 )
	oModel:Activate()

	 If !oModel:SetValue("NQAMASTER",'NQA_DESC'    ,aPlvdes[1]) .Or. ;
		!oModel:SetValue("NQAMASTER",'NQA_POLOAT' ,aPlvdes[2]) .Or. ;
		!oModel:SetValue("NQAMASTER",'NQA_POLOPA' ,aPlvdes[3]) .Or. ;
		!oModel:SetValue("NQAMASTER",'NQA_TERCIN' ,aPlvdes[4])
		lRet := .F.
		JurMsgErro( I18N(STR0012, {""}) ) //Erro na carga da configuração inicial
	EndIf

	If	lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		Else
			aErro := oModel:GetErrorMessage()
			JurMsgErro(aErro[6])
		EndIf
	EndIf

	oModel:DeActivate()
	
	RestArea(aArea)
Return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA009PLVDE
Retorna .T./.F. se contiver a descrição indicada no parâmetro

@Param cDesc    - Descrição
@Param cTipoRet - Indica o tipo de retorno da função (L- Lógico / C - Caractere)

@Return xRet - Pode ser lógico / caractere
			Lógico - .T. quando encontrou o registro e .F. quando não encontrou)
			Caractere - Indica o código do tipo de envolvimento cadastrado

@author Reginaldo Natal Soares
@since 02/08/16
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA009PLVDE(cDesc, cTipoRet)
Local aArea    := GetArea()
Local aAreaNQA := NQA->( GetArea() )
Local cQuery   := ""
Local xRet     := .F.
Local cAlias

Default cTipoRet := 'L'

	cDesc := LOWER(PADR(JurLmpCpo(cDesc) + '', TamSx3('NQA_DESC')[1]))

	cQuery := " SELECT NQA_COD COD"
	cQuery +=     " FROM "+RetSqlName("NQA")+" NQA"
	cQuery +=   " WHERE NQA_FILIAL = '" + xFilial( "NQA" ) + "'"
	cQuery +=     " AND " + JurFormat("NQA_DESC", .T./*lAcentua*/,.T./*lPontua*/) + " = '" +cDesc+ "'"
	cQuery +=     " AND NQA.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	
	cAlias := GetNextAlias()
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	(cAlias)->( dbGoTop() )
	
	If !(cAlias)->( EOF() )
		xRet := IIF(cTipoRet == 'L', .T., (cAlias)->COD)
	Endif

	(cAlias)->( dbcloseArea() )

RestArea(aAreaNQA)
RestArea(aArea)
	
Return xRet
