#INCLUDE "OGC130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} OGC130
Consulta - Painel de Saldos de Notas de Remessa
@param:     Nil
@return:    nil
@author:    Tamyris Ganzenmueller
@since:     02/05/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGC130( cFiltroDef )
	Local oBrowse
	
	Default cFiltroDef := ''
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("N9I")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGC130")				    // Nome do fonte onde esta a função MenuDef
	oBrowse:SetFilterDefault( cFiltroDef )
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	
	oBrowse:SetAttach( .T. ) //visualizações 
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Tamyris Ganzenmueller
@since:     02/05/2018
@Uso: 		OGC130
*/
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGC130" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGC130" OPERATION 8 ACCESS 0 //"Imprimir"
	
	Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Tamyris Ganzenmueller
@since:     02/05/2018
@Uso: 		OGC130
*/
Static Function ModelDef()
	
	Local oStruN9I := FWFormStruct( 1, "N9I" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGC130", /*<bPre >*/ , /*bPost*/ , /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields("OGC130_N9I", Nil, oStruN9I ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"N9I_FILIAL","N9I_DOC","N9I_SERIE","N9I_CLIFOR","N9I_LOJA","N9I_ITEDOC","N9I_ITEFLO"})
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Tamyris Ganzenmueller
@since:     02/05/2018
@Uso: 		OGC130
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGC130")
	Local oView  := Nil
	Local oStructN9I := FWFormStruct(2,"N9I")   
	              
		oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "OGC130_N9I" , oStructN9I, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "OGC130_N9I" , "MASTER" )   
Return oView





