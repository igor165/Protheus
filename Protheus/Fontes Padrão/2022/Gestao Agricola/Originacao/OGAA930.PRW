#INCLUDE "OGAA930.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
/** {Protheus.doc} OGAA930
Usuários Portal Agro Comercial
@param:     Nil
@return:    nil
@author:    Christopher.miranda
@since:     04/10/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGAA930( )
	Local oBrowse
	
	//Proteç?o
	If !TableInDic('NL7') 
		Help( , , STR0008, , STR0009, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf 

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NL7")			// Alias da tabela utilizada
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:SetMenuDef("OGAA930")	// Nome do fonte onde esta a função MenuDef
	
	oBrowse:Activate()         
                                  
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA930
*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGAA930" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGAA930" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005   ACTION "VIEWDEF.OGAA930" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGAA930" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.OGAA930" OPERATION 8 ACCESS 0 //"Imprimir"
	
Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA930
*/
Static Function ModelDef()
	
	Local oStruNL7 := FWFormStruct( 1, "NL7" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGAA930")
	
	oModel:AddFields("OGAA930_NL7", Nil, oStruNL7)
	oModel:SetPrimaryKey({"NL7_FILIAL","NL7_CODUNS"})

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA930/
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGAA930")
	Local oView  := Nil
	Local oStructNL7 := FWFormStruct(2,"NL7")   
	              
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "OGAA930_NL7" , oStructNL7)	
	oView:CreateHorizontalBox( "MASTER" , 100)

	oView:SetOwnerView( "OGAA930_NL7" , "MASTER" )   

Return oView