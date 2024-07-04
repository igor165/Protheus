#INCLUDE "JURA034.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA034
Ramal Por Profissional

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA034()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NR6" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NR6" )
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
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA034", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA034", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA034", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA034", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA034", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Ramal Por Profissional

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA034" )
Local oStruct := FWFormStruct( 2, "NR6" ) 

oStruct:RemoveField('NR6_CPART')

JurSetAgrp( 'NR6',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA034_VIEW", oStruct, "NR6MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA034_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Ramal Por Profissional"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Ramal Por Profissional

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0

@obs NR6MASTER - Dados do Ramal Por Profissional

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NR6" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA034", /*Pre-Validacao*/, {|oM| JA034TUDOK(oM)} /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NR6MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Ramal Por Profissional"
oModel:GetModel( "NR6MASTER" ):SetDescription( STR0009 ) // "Dados de Ramal Por Profissional"

JurSetRules( oModel, 'NR6MASTER',, 'NR6' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA034TUDOK
Validações ao salvar ao salvar o Time-Sheet

@author David Gonçalves Fernandes
@since 03/07/09
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JA034TUDOK(oModel)
Local lRet := .T.

If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
	If Empty(FWFldGet('NR6_CPART'))
		JurMsgErro(STR0010)  //"O participante não foi preenchido. Verifique!"
		lRet := .F.
	EndIf
	lRet := J034VldRml(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J034VldRml
Função para permitir somente um ramal como principal para um participante.

@param	oModel	Objeto do modelo de dados

@author Abner Fogaça de Oliveira
@since 18/06/09
/*/
//-------------------------------------------------------------------
Static Function J034VldRml(oModel)
Local oModelNR6  := oModel:GetModel('NR6MASTER')
Local cSigla     := ""
Local cRamal     := cValtochar(oModelNR6:GetValue("NR6_RAMAL"))
Local cCodNR6    := ""
Local aDados     := {}
Local lRet       := .T.

If oModelNR6:GetValue("NR6_TIPO") == "1"
	aDados := J034BusRml(cRamal)
	If !Empty(aDados)
		cCodNR6 := aDados [1][2]
		If oModelNR6:GetValue("NR6_COD") != cCodNR6
			cSigla := JurGetDados("RD0", 1, xFilial("RD0") + aDados[1][1],"RD0_SIGLA")
			JurMsgErro(STR0011, ,I18N(STR0012, {AllTrim(cSigla),aDados[1][1]})) //"Ramal já cadastrado como principal." / "O participante '#1' ('#2') está cadastrado com este ramal como principal."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J034BusRml
Função para identificar o participante que contém o ramal como principal.

@param	cRamal	Ramal para busca do participante
@param	cTipo	Tipo do Ramal (primário e secundário)

@return	aDados	Array com o código do participante e código da NR6

@author Abner Fogaça de Oliveira
@since 18/06/09
/*/
//-------------------------------------------------------------------
Function J034BusRml(cRamal, cTipo)
Local cQuery     := ""
Local nTamPartic := TamSX3("RD0_CODIGO")[1]

Default cTipo := '1'

cQuery := " SELECT " 
cQuery +=   " SUBSTRING(NR6_CPART, 1, " + cValToChar(nTamPartic) + ") NR6_CPART , " //Proteção devido o campo NR6_CPART estar com o tamanho errado.
cQuery +=   " NR6_COD "
cQuery += " FROM " + RetSqlName("NR6")
cQuery += " WHERE NR6_FILIAL = '" + xFilial("NR6") + "' "
cQuery +=	" AND NR6_RAMAL = " + cRamal + " "
If !Empty(cTipo)
	cQuery += " AND NR6_TIPO = '" + cTipo + "' "
EndIf
cQuery +=	" AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY  NR6_TIPO, NR6_COD "

aDados := JurSQL(cQuery, {"NR6_CPART", "NR6_COD"})

Return aDados
