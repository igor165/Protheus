#INCLUDE "OGA252.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA252
Rotina para cadastro de monitoramento.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	11/09/2018
@Uso: 		SIGAAGR - Origina��o de Gr�os
*/
Function OGA252(cCodrom)
	Local oBrowse
	Local cFiltroDef 	:= iIf( !Empty( cCodrom ), "NCN_CODROM='"+cCodrom+"'", "" )
	Private pcCodRom 		:= cCodrom
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NCN")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGA252")	// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetFilterDefault( cFiltroDef )
	oBrowse:SetDescription(STR0001)	// Descri��o do browse 
	
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	11/09/2018
@Uso: 		OGA252
*/
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGA252" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGA252" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005   ACTION "VIEWDEF.OGA252" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGA252" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.OGA252" OPERATION 8 ACCESS 0 //"Imprimir"
	
	Return aRotina
	
/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	11/09/2018
@Uso: 		OGA252
*/
Static Function ModelDef()
	
	Local oStruNCN := FWFormStruct( 1, "NCN" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGA252", /*<bPre >*/ ,  , /*bCommit*/, /*bCancel*/ )
	
	oStruNCN:SetProperty( "NCN_SEQUEN" , MODEL_FIELD_INIT , { | | GETSXENUM("NCN","NCN_SEQUEN")  } ) 	
	oStruNCN:SetProperty( "NCN_SEQUEN"  , MODEL_FIELD_WHEN  , {|| .F. } )
			
	If  TYPE ("pcCodRom") == "C" .AND. ! Empty( pcCodRom )
		oStruNCN:SetProperty( "NCN_CODROM" , MODEL_FIELD_INIT , { | | pcCodRom    } ) 
		oStruNCN:SetProperty( "NCN_USER"   , MODEL_FIELD_INIT , { | | CUSERNAME   } ) 	
		
		oStruNCN:SetProperty( "NCN_CODROM"  , MODEL_FIELD_WHEN  , {|| .F. } )
		oStruNCN:SetProperty( "NCN_USER"    , MODEL_FIELD_WHEN  , {|| .F. } )
			
	EndIf
	
	oModel:AddFields("OGA252_NCN", Nil, oStruNCN ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"NCN_FILIAL","NCN_CODROM","NCN_SEQUEN"})
Return oModel

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso: 		OGAA780/
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGA252")
	Local oView  := Nil
	Local oStructNCN := FWFormStruct(2,"NCN")   
	              
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "OGA252_NCN" , oStructNCN, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "OGA252_NCN" , "MASTER" )   
Return oView
