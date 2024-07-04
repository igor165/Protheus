#INCLUDE "OGAA960.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"
/** {Protheus.doc} OGAA960
Cadastro de Status do Pepro
@param:     Nil
@return:    nil
@author:    Christopher.miranda
@since:     04/10/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGAA960( )
	Local oBrowse
	
	//Proteç?o
	If !TableInDic('NLK')
		Help( , , STR0008, , STR0009, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NLK")			// Alias da tabela utilizada
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:SetMenuDef("OGAA960")	// Nome do fonte onde esta a função MenuDef
	
	oBrowse:Activate()         
                                  
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA960
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.OGAA960"  , 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.OGAA960"  , 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.OGAA960"  , 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.OGAA960"  , 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.OGAA960"  , 0, 8, 0, .T. } ) //"Imprimir"
	
Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA960
*/
Static Function ModelDef()
	
	Local oStruNLK := FWFormStruct( 1, "NLK" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGAA960")
	
	oModel:AddFields("OGAA960_NLK", Nil, oStruNLK)
	oModel:SetPrimaryKey({"NLK_FILIAL","NLK_CODSTS"})

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Christopher.miranda
@since:     04/10/2018
@Uso: 		OGAA960/
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGAA960")
	Local oView  := Nil
	Local oStructNLK := FWFormStruct(2,"NLK")   
	              
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "OGAA960_NLK" , oStructNLK)	
	oView:CreateHorizontalBox( "MASTER" , 100)

	oView:SetOwnerView( "OGAA960_NLK" , "MASTER" )   

Return oView