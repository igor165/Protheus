#INCLUDE "JURA068.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA068 
Escritório.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA068()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) //"Cadastro de Escritório"
oBrowse:SetAlias( "NS7" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NS7" )
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

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA068", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA068", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA068", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA068", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA068", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Escritório.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA068" )
Local oStructNS7 := FWFormStruct( 2, "NS7" )
Local oStructOHJ := Nil
Local lExistOHJ  := FWAliasInDic("OHJ") 

If lExistOHJ
	oStructOHJ := FWFormStruct( 2, "OHJ" )
	oStructOHJ:RemoveField( "OHJ_COD" )
	oStructOHJ:RemoveField( "OHJ_DESCR" )
EndIf

JurSetAgrp( 'NS7',, oStructNS7 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "NS7_VIEW", oStructNS7, "NS7MASTER"  )

If lExistOHJ
	oView:AddGrid( "OHJ_VIEW", oStructOHJ, "OHJDETAIL"  )
	oView:CreateHorizontalBox( "SUPERIOR", 60 )
	oView:CreateHorizontalBox( "INFERIOR", 40 )
	oView:SetOwnerView( "OHJ_VIEW", "INFERIOR" )
	oView:EnableTitleView( "OHJ_VIEW" )
Else
	oView:CreateHorizontalBox( "SUPERIOR", 100 )
EndIf

oView:SetOwnerView( "NS7_VIEW", "SUPERIOR" )
oView:SetDescription( STR0007 ) //"Cadastro de Escritório"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Escritório.

@author Fabio Crespo Arruda
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNS7 := FWFormStruct( 1, "NS7" )
Local oStructOHJ := Nil
Local oCommit    := JA068COMMIT():New()
Local lExistOHJ  := FWAliasInDic("OHJ") 

oModel:= MPFormModel():New( "JURA068", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NS7MASTER", NIL, oStructNS7, /*Pre-Validacao*/, /*Pos-Validacao*/ )

If lExistOHJ
	oStructOHJ := FWFormStruct( 1, "OHJ" )
	oModel:AddGrid( "OHJDETAIL", "NS7MASTER", oStructOHJ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetRelation( "OHJDETAIL", { {"OHJ_FILIAL", "xFilial('OHJ')"}, {"OHJ_COD", "NS7_COD"} }, OHJ->( IndexKey(1) ) )
	oModel:GetModel("OHJDETAIL"):SetOptional( .T. )
	oModel:GetModel("OHJDETAIL"):SetUniqueLine( { "OHJ_CTPDP" } )
EndIf

oModel:SetDescription( STR0008 ) //"Modelo de Dados do Cadastro de Escritório"
oModel:GetModel( "NS7MASTER" ):SetDescription( STR0009 ) //"Dados do Cadastro de Escritório"
oModel:InstallEvent("JA068COMMIT", /*cOwner*/, oCommit)
JurSetRules( oModel, 'NS7MASTER',, 'NS7' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA068SetRst
Função para chamada da JurSetRest() - Restrição de Cadastros, quando 
for inclusão pelo SIGAJURI.

@author Jorge Luis Branco Martins Junior
@since 12/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA068SetRst(oModel)
Local cCod := oModel:GetValue("NS7MASTER", "NS7_COD")
Local nOpc := oModel:GetOperation()

	If nOpc == 3 .And. nModulo == 76
		lRet := JurSetRest('NS7', cCod)
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA068DTINAT
Rotina para preenchimento da data de inativação do escritório.

@author Cristina Cintra
@since 11/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA068DTINAT() 
Local dData

Do Case
	Case M->NS7_ATIVO == '1' //Ativo
		dData := ''

	Case M->NS7_ATIVO == '2' //Inativo
		dData := IIF(Empty(NS7->NS7_DTINAT), Date(), NS7->NS7_DTINAT)
EndCase

Return dData

//-------------------------------------------------------------------
/*/{Protheus.doc} JA068FILIA
Validação da filial do escritório

@author Andreia Lima
@since 31/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA068FILIA()
Local lRet := .T.
	
	If SuperGetMV("MV_JFTJURI",, "2" ) == "1"
		lRet := ExistCpo('SM0', M->NS7_CEMP + M->NS7_CFILIA, 1) .And. ExistChav('NS7', M->NS7_CFILIA + M->NS7_CEMP, 4)
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J068VlLink
Validação do link de NF

@param oModel, Modelo principal

@return lRet, Se está ok o campo NS7_LINKNF

@author Bruno Ritter / Jorge Martins
@since 06/11/2019
/*/
//-------------------------------------------------------------------
Function J068VlLink(oModel)
	Local lRet        := .T.
	Local cVar        := ""
	Local cLink       := Iif(oModel:HasField("NS7MASTER", "NS7_LINKNF"), oModel:GetValue("NS7MASTER", "NS7_LINKNF"), "")
	Local cTabela     := ""
	Local nPosCpo     := 0

	While lRet .And. RAt("#@", cLink) > 0

		cVar := Upper( Substr(cLink, At("@#", cLink) + 2, At("#@", cLink) - ( At("@#", cLink) + 2 )))

		If Empty(cVar)
			lRet := .F.
			JurMsgErro(STR0013, , ; // "Um ou mais campos informados para a macro substituição estão vazios."
			      I18n(STR0014, {AllTrim(FwX3Titulo('NS7_LINKNF'))})) // "Verifique o conteúdo do campo '#1'. Serão permitidos apenas campos das entidades SF2, NS7 e NXA."

		Else
			//Verifica se o campo inicia com |, indicando uma formula a ser macroexecutada, caso afirmativo, ignora este campo
			If Left(cVar,1) != "|"
				cTabela := SubStr(cVar, 1, At("_", cVar) - 1)
				If Len(cTabela) == 2
					cTabela := "S" + cTabela
				EndIf

				If FWAliasInDic(cTabela) .And. cTabela $ "SF2|NS7|NXA"
					nPosCpo := (cTabela)->(FieldPos(cVar))
				Else
					nPosCpo := 0
				EndIf

				If nPosCpo == 0
					lRet := .F.
					JurMsgErro(I18n(STR0015, {cVar}) ,, ; // "Campo '#1' informado para a macro substituição é inválido."
							I18n(STR0014, {AllTrim(FwX3Titulo('NS7_LINKNF'))})) // "Verifique o conteúdo do campo '#1'. Serão permitidos apenas campos das entidades SF2, NS7 e NXA."							
				EndIf
			EndIf
			cLink := Substr(cLink, 1, At("@#", cLink) - 1)  + Substr(cLink, At("#@", cLink) + 2)		
		EndIf
	EndDo
	
Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA068COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA068COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
	Method ModelPosVld()
End Class

Method New() Class JA068COMMIT
Return

Method ModelPosVld(oModel, cModelId)  Class JA068COMMIT
	lRet := J068VlLink(oModel)

Return lRet

Method InTTS(oSubModel, cModelId) Class JA068COMMIT
	JA068SetRst(oSubModel:GetModel())
	JFILASINC(oSubModel:GetModel(), "NS7", "NS7MASTER", "NS7_COD")
Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA068GetFil()
Retorna a descrição da filial

@author Abner Fogaça de Oliveira
@since 29/01/2020
@obs Função utilizada no gatilho do campo NS7_CFILIA
/*/
//-------------------------------------------------------------------
Function JA068GetFil()
	Local cRet := ""

	cRet := Substr(JurGetDados("SM0", 1, M->NS7_CEMP + M->NS7_CFILIA, "M0_FILIAL"), 1, TamSX3("NS7_DFILIA")[1])

Return cRet
