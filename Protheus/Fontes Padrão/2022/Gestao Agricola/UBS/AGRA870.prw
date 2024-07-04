//#INCLUDE "AGRA870.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

Static lAGR87001 := ExistBlock("AGR87001") //Ponto de Entrada para adicionar novo botões na AGRA870

/** {Protheus.doc} AGRA870
Rotina para Visualização da Liberação de Lotes
@param: 	Nil
@author: 	Marcelo Ferrari
@since: 	29/11/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA870()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "NJ6" )
	oBrowse:SetDescription( "Consulta Separação de Lotes" ) //"STR0001"
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( "AGRA870" )
	oBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/

Static Function MenuDef()
	Local aRotina := {}
	Local aRetM		:= {}
	Local nX		:= 0
	
	aAdd( aRotina, { "Pesquisar"	, 'PesqBrw'      , 0, 1, 0, .T. } ) //STR0002
	aAdd( aRotina, { "Alterar"		, "AGRA870PSQ()" , 0, 4, 0, Nil } ) //STR0005
	
	IF lAGR87001
		aRetM := ExecBlock('AGR87001',.F.,.F.)
		If ValType(aRetM) == 'A'
			For nX := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nX])
			Next nX 
		EndIf
	EndIF

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ModelDef()
	Local oStruNJ6 := FWFormStruct( 1, "NJ6" )
	Local oModel := MPFormModel():New( "AGRA870M" )

	oModel:AddFields( 'NJ6UNICO', Nil, oStruNJ6 )
	oModel:SetDescription( "Separação de Lotes" ) //STR0009
	oModel:GetModel( 'NJ6UNICO' ):SetDescription( "Separação de Lotes" ) //STR0010

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ViewDef()
	Local oStruNJ6 := FWFormStruct( 2, 'NJ6' )
	Local oModel   := FWLoadModel( 'AGRA870' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NJ6', oStruNJ6, 'NJ6UNICO' )
	oView:CreateHorizontalBox( 'UM'  , 100 )
	oView:SetOwnerView( 'VIEW_NJ6', 'UM'   )

Return oView

Function AGRA870VLD( oModel )
	local lRet := .T.
	Local cAliasTab := "NJ6"
	lRet := AGRA950VAL(cAliasTab)
Return lRet

Function AGRA870PSQ()
	Local cChaveNJ6 := NJ6->(NJ6_FILIAL+";" +NJ6_CODCAR +";"+ NJ6_SEQCAR +";" + NJ6_NUMPV +";" + NJ6_ITEM +";" + NJ6_SEQUEN)
	Local aChaveNJS := {}

	DbSelectArea("NJS")
	DbSetOrder(2)
	If dbseek("NJ6" + cChaveNJ6) 
		aChaveNJS := {NJS_FILIAL, NJS_NRMOV, NJS_CDPTCT, NJS_SEQ, NJS_CDPERG}
		AGRA870B(aChaveNJS)
	Else
		Help(,, "Aviso",,"Não foi encontrado registro no ponto de controle para este movimento." , 1, 0 )
	EndIf

Return 
