#INCLUDE "OGAA780.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} OGAA780
Usuários Portal Agro Comercial
@param:     Nil
@return:    nil
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGAA780( )
	Local oBrowse
	
	//Proteç?o
	If !TableInDic('N9L')
		Help( , , STR0008, , STR0010, 1, 0 ) //"Atenç?o" //""Para acessar esta funcionalidade é necessario atualizar a tabela 'Usuario Portal Agro' .""
		Return(Nil)
	EndIf 
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("N9L")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGAA780")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso: 		OGAA780
*/
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGAA780" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGAA780" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005   ACTION "VIEWDEF.OGAA780" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGAA780" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.OGAA780" OPERATION 8 ACCESS 0 //"Imprimir"
	
	Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso: 		OGAA780
*/
Static Function ModelDef()
	
	Local oStruN9L := FWFormStruct( 1, "N9L" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGAA780", /*<bPre >*/ , {| oModel | PosModelo( oModel ) } , /*bCommit*/, /*bCancel*/ )
	
	oStruN9L:AddTrigger( "N9L_CODUSU", "N9L_CODCON", { || .T. }, { | x | fTrgN9LCon( x ) } )
	
	oModel:AddFields("OGAA780_N9L", Nil, oStruN9L ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"N9L_FILIAL","N9L_IDUSR"})
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso: 		OGAA780/
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGAA780")
	Local oView  := Nil
	Local oStructN9L := FWFormStruct(2,"N9L")   
	              
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "OGAA780_N9L" , oStructN9L, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "OGAA780_N9L" , "MASTER" )   
Return oView

/** {Protheus.doc} PosModelo
Validação do model
@param: 	Nil
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso: 		OGAA780
*/
Static Function PosModelo(oModel)
	Local lRet    := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If oModel:GetValue( "OGAA780_N9L", "N9L_PRIVIL" ) = '1' .And. Empty(oModel:GetValue( "OGAA780_N9L", "N9L_CODCON" ) ) //Usuário
			Help(, , STR0008, , STR0009, 1, 0 ) //"Ajuda"###"Contato deve ser informado"
			lRet := .F.
		EndIf
	EndIF
	
Return lRet

/** {Protheus.doc} fTrgN9LCon
Função criada para realizar gatilho para o campo contato
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso:       OGAA780
*/
Static Function fTrgN9LCon() 
	Local oModel	:= FwModelActive()
	Local oN9L		:= oModel:GetModel( "OGAA780_N9L" )
	Local cRetorno	:= ""
	Local cQuery   := ""
	Local cAlias   := GetNextAlias()

	cQuery := " SELECT U5_CODCONT "
	cQuery += " FROM " + RetSqlName("SU5") + " SU5 "
	cQuery += " WHERE SU5.U5_CODUSR = '" + oN9L:GetValue("N9L_CODUSU") + "'"
	cQuery += "   AND SU5.D_E_L_E_T_ = '' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.) 
	DbselectArea(cAlias)
	DbGoTop()
	If (cAlias)->(!Eof())
		cRetorno := (cAlias)->U5_CODCONT
	EndIf
	(cAlias)->(DbCloseArea())
	
Return( cRetorno )

