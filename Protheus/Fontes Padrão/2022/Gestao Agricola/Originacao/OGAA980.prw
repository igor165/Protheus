#INCLUDE "OGAA980.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGAA980
Metas de Faturamento
@param:     Nil
@return:    nil
@author:    tamyris.g
@since:     04/10/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGAA980( )
	Local oBrowse
	
	Private __lCopy := .F. 
	
	//Proteç?o
	If !TableInDic('NCZ')
		Help( , , STR0010, , STR0012, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NCZ")			// Alias da tabela utilizada
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:SetFilterDefault( " Empty(NCZ_DATFIM) " )
	oBrowse:SetMenuDef("OGAA980")	// Nome do fonte onde esta a função MenuDef
	
	oBrowse:Activate()         
                                  
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    tamyris.g
@since:     04/10/2018
@Uso: 		OGAA980
*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGAA980" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGAA980" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005   ACTION "OGAA980CPY()"    OPERATION 9 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGAA980" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.OGAA980" OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE STR0011   ACTION "OGAA980A()" OPERATION 9 ACCESS 0 //"Histórico"
	
Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author:    tamyris.g
@since:     04/10/2018
@Uso: 		OGAA980
*/
Static Function ModelDef()
	Local oStruNCZ := FWFormStruct( 1, "NCZ" )
	Local oModel :=  MPFormModel():New( "OGAA980", , {| oModel | PosModelo( oModel ) })
	Default __lCopy := .F. 
	 
	If __lCopy
		oStruNCZ:SetProperty( "NCZ_CODPRO" , MODEL_FIELD_INIT , { | | NCZ->NCZ_CODPRO } ) 
		oStruNCZ:SetProperty( "NCZ_DESPRO" , MODEL_FIELD_INIT , { | | Posicione( "SB1", 1, xFilial( "SB1" ) + NCZ->NCZ_CODPRO, "B1_DESC" ) } )
		oStruNCZ:SetProperty( "NCZ_ANO"    , MODEL_FIELD_INIT , { | | NCZ->NCZ_ANO } ) 	
		oStruNCZ:SetProperty( "NCZ_CODPRO" , MODEL_FIELD_WHEN , {||.F.} )
		oStruNCZ:SetProperty( "NCZ_ANO"    , MODEL_FIELD_WHEN , {||.F.} )	
	EndIf
	
	oModel:AddFields( 'NCZUNICO', Nil, oStruNCZ )
	oModel:SetDescription( STR0001 ) //"Metas de Faturamento"
	oModel:GetModel( 'NCZUNICO' ):SetDescription( STR0001 ) //"Metas de Faturamento"
	oModel:GetModel( "NCZUNICO" ):SetFldNoCopy( {'NCZ_SEQUEN','NCZ_DATINI','NCZ_DATFIM'} )
	
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    tamyris.g
@since:     04/10/2018
@Uso: 		OGAA980/
*/
Static Function ViewDef()
	Local oStruNCZ	:= FWFormStruct( 2, "NCZ" )
	Local oModel	:= FWLoadModel( "OGAA980" )
	Local oView		:= FWFormView():New()
	
	oStruNCZ:RemoveField( "NCZ_SEQUEN" )
	
	oView:SetModel( oModel )
	oView:CreateHorizontalBox( "SUPERIOR" , 100 )
	
	oView:AddField( "VIEW_NCZ", oStruNCZ, "NCZUNICO" )
	oView:SetOwnerView( "VIEW_NCZ", "SUPERIOR" )
	oView:EnableTitleView( "VIEW_NCZ" )
	
	oStruNCZ:AddGroup("GrpGeral" , "", "1", 2) 
	oStruNCZ:AddGroup("GrpValor" , STR0008 , "1", 2)  
	
	oStruNCZ:SetProperty("NCZ_CODPRO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruNCZ:SetProperty("NCZ_DESPRO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruNCZ:SetProperty("NCZ_UM1PRO",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruNCZ:SetProperty("NCZ_ANO"   ,  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruNCZ:SetProperty("NCZ_DATINI",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	oStruNCZ:SetProperty("NCZ_DATFIM",  MVC_VIEW_GROUP_NUMBER, "GrpGeral")
	     
	oStruNCZ:SetProperty("NCZ_VLME01",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME02",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME03",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME04",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME05",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME06",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME07",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME08",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME09",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME10",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME11",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	oStruNCZ:SetProperty("NCZ_VLME12",  MVC_VIEW_GROUP_NUMBER, "GrpValor")
	
	oView:SetCloseOnOk( {||.t.} )
	
Return oView

/** {Protheus.doc} PosModelo
Pós validação do modelo, antes da gravação.
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Tamyris Ganzenmueller	
@since: 	13/02/2019
@Uso: 		OGAA980 */
Static Function PosModelo( oParModel )
	Local aAreaAtu		:= GetArea()
	Local lRetorno		:= .T.
	Local oModel		:= oParModel:GetModel()
	Local nOperation	:= oModel:GetOperation()
	Local oNCZ			:= oModel:GetModel( "NCZUNICO" )
	
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT
		
		//Verifica se já tem outra meta cadastrada para o produto/ano
		cAliasQry  := GetNextAlias()
		cQuery := "SELECT NCZ_DATINI, NCZ.R_E_C_N_O_ AS NCZ_RECNO "
		cQuery += " FROM " + RetSqlName("NCZ") + " NCZ "
		cQuery += " WHERE NCZ.NCZ_FILIAL = '" + xFilial("NCZ") + " '"
		cQuery += " AND   NCZ.NCZ_CODPRO = '" + oNCZ:GetValue( "NCZ_CODPRO" ) + "' "
		cQuery += " AND   NCZ.NCZ_ANO    = '" + oNCZ:GetValue( "NCZ_ANO" ) + "' "
		cQuery += " AND   NCZ.NCZ_DATFIM = '' "
		cQuery += " AND   NCZ.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY NCZ_DATINI ASC "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			
			//Se já tem um registro na data de hoje, mostra validação
			If oModel:IsCopy() 
				NCZ->(DbCloseArea())
			
				DbSelectArea("NCZ")
				NCZ->(DbGoTop())
				NCZ->(dbGoTo( (cAliasQry)->NCZ_RECNO ) )
				RecLock("NCZ",.F.)
					NCZ->NCZ_DATFIM := dDataBase
				NCZ->(MsUnlock())
			Else
				Help( , , STR0010, , STR0009, 1, 0 ) //Ajuda # "Já existe registro para o Produto no ano informado"           
				lRetorno := .F.
			EndIf
			
		EndIf
		(cAliasQry)->(DbcloseArea())
	EndIf
	
	RestArea( aAreaAtu )
Return( lRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} OGAA980CPY
Função para executar o menu de copy
@author tamyris.g
@since 20/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function OGAA980CPY()
	
	__lCopy := .T.
	
	FWExecView('', 'VIEWDEF.OGAA980', 9, , {|| .T. }) 
	
	__lCopy := .F.
Return .T.
