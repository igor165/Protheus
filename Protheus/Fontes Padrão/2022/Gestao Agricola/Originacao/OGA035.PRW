#INCLUDE "OGA035.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

/** {Protheus.doc} OGA035
Rotina para cadastro de parecer da qualidade

@param.: 	Nil
@author: 	Ana Laura Olegini
@since.: 	14/12/2015
@Uso...: 	SIGAAGR - Originação de Grãos
*/
Function OGA035()
	Local oMBrowse	:= Nil
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKJ" )
	oMBrowse:SetDescription( STR0001 ) //"Parecer da Qualidade"
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef( "OGA035" )
	oMBrowse:Activate()
Return( Nil )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param.: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindústria
@since.: 	14/12/2015
@Uso...: 	OGA035 - Parecer da Qualidade
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002 	, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "ViewDef.OGA035", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004  	, "ViewDef.OGA035", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005   	, "ViewDef.OGA035", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006   	, "ViewDef.OGA035", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007  	, "ViewDef.OGA035", 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008    , "ViewDef.OGA035", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param.: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindústria
@since.: 	14/12/2015
@Uso...:	OGA035 - Parecer da Qualidade
*/
Static Function ModelDef()
	Local oStruNKJ	:= FWFormStruct( 1, "NKJ" )
	Local oModel	:= MPFormModel():New( "OGA035" )


	oModel:AddFields( "NKJUNICO", Nil, oStruNKJ )
	oModel:SetDescription( STR0001  ) //"Parecer da Qualidade"
	oModel:GetModel( "NKJUNICO" ):SetDescription( STR0009  ) //"Dados do Parecer da Qualidade"


   //oStruNKJ:SetProperty( "NKJ_PAREC" , MODEL_FIELD_WHEN   , {||IIF(NKJ->NKJ_LIBQLD $ '1|2',.T.,.F.)})
	oModel:SetVldActivate( { |oModel| fIniModelo( oModel )} )
	
	
Return( oModel )



/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotinada

@param.: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindústria
@since.: 	14/12/2015
@Uso...: 	OGA035 - Parecer da Qualidade
*/
Static Function ViewDef()
	Local oStruNKJ := FWFormStruct( 2, "NKJ" )
	Local oModel   := FWLoadModel( "OGA035" )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NKJ", oStruNKJ, "NKJUNICO" )
	oView:CreateHorizontalBox( "UM" , 100 )
	oView:SetOwnerView( "VIEW_NKJ", "UM"   )

	oView:SetCloseOnOk( {||.T.} )

Return( oView )

/** {Protheus.doc} 
Função que Inicializa / Activate o modelo de dados

@param.: 	oModel 		- Modelo de dados
@param.: 	nOperation 	- Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	lRetorno 	- verdadeiro ou falso
@author: 	Ana Laura Olegini
@since.: 	17/12/2015
@Uso...:	OGA035 - Parecer da Qualidade
*/
Static Function fIniModelo( oModel )
	Local nOperation   := oModel:GetOperation()
//	Local aAreaNJJ     := NJJ->(GetArea() )
	Local lContinua    := .T.
	
	/* --- Alteração  --- */
	If nOperation == MODEL_OPERATION_UPDATE 
		dbSelectArea("NJJ")
		NJJ->(dbSetOrder(3)) //NJJ_FILIAL+NJJ_QPAREC
		IF NJJ->(DbSeek(fwXfilial('NJJ')+NKJ->NKJ_PAREC))
          Help(, , STR0010, , STR0011, 1, 0 ) //"AJUDA""Este parecer já está sendo utilizado. Não é possível alterar."                
          lContinua := .F.		
		EndIF      
	EndIf
	
	/* --- Exclusão  --- */
	If nOperation == MODEL_OPERATION_DELETE
        dbSelectArea("NJJ")
        NJJ->(dbSetOrder(3)) //NJJ_FILIAL+NJJ_QPAREC
        IF NJJ->(DbSeek(fwXfilial('NJJ')+NKJ->NKJ_PAREC))
          Help(, , STR0010, , STR0012, 1, 0 ) //"AJUDA""Este parecer já está sendo utilizado. Não é possível excluir."                
          lContinua := .F.      
        EndIF      
	EndIf
	
//RestAea(aAreaNJJ)
Return(lContinua)	