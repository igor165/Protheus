#INCLUDE "OGA970.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

Static __cTpCampo := "1"
/** {Protheus.doc} OGA970
Cadastro de Textos Padrões para Registro de Negócio/Contrato
@param:     Nil
@return:    nil
@author:    Christopher.miranda
@since:     13/02/2019
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGA970()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ND0")			// Alias da tabela utilizada
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:SetMenuDef("OGA970")	// Nome do fonte onde esta a função MenuDef
	
	oBrowse:Activate()         
                                  	
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Christopher.miranda;
@since:     13/02/2019
@Uso: 		OGA970
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.OGA970"  , 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "OGA970INC()", 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.OGA970"  , 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.OGA970"  , 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.OGA970"  , 0, 8, 0, .T. } ) //"Imprimir"
	
Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Christopher.miranda
@since:     13/02/2019
@Uso: 		OGA970
*/
Static Function ModelDef()
	
	Local oStruND0 := FWFormStruct( 1, "ND0" )
	Local oModel
	
	oModel :=  MPFormModel():New( "OGA970")

	If IsInCallStack("OGA700")
		oStruND0:SetProperty( 'ND0_TPCAMP' , MODEL_FIELD_WHEN , {|| .F.}) 
		oStruND0:SetProperty( 'ND0_TIPMER' , MODEL_FIELD_WHEN , {|| .F.}) 
		oStruND0:SetProperty( 'ND0_CODPRO' , MODEL_FIELD_WHEN , {|| .F.})

		oStruND0:SetProperty( 'ND0_TPCAMP' , MODEL_FIELD_INIT , {|| __cTpCampo})
		oStruND0:SetProperty( 'ND0_TIPMER' , MODEL_FIELD_INIT , {|| M->N79_TIPMER})
		oStruND0:SetProperty( 'ND0_CODPRO' , MODEL_FIELD_INIT , {|| M->N79_CODPRO})
		oStruND0:SetProperty( 'ND0_DESPRO' , MODEL_FIELD_INIT , {|| POSICIONE("SB1",1,fWxFilial("SB1")+M->N79_CODPRO,"B1_DESC")})

	EndIf

	oModel:AddFields("OGA970_ND0", Nil, oStruND0)
	oModel:SetPrimaryKey({"ND0_FILIAL","ND0_CODTXT"})

	oStruND0:SetProperty( "ND0_RESUMO", MODEL_FIELD_OBRIGAT, .T. )

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Christopher.miranda
@since:     13/02/2019
@Uso: 		OGA970
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGA970")
	Local oView  := Nil
	Local oStructND0 := FWFormStruct(2,"ND0")   
	              
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "OGA970_ND0" , oStructND0)	
	oView:CreateHorizontalBox( "MASTER" , 100)

	oView:SetOwnerView( "OGA970_ND0" , "MASTER" )  

	oStructND0:SetProperty("ND0_CODTXT",MVC_VIEW_ORDEM,'01') 
	oStructND0:SetProperty("ND0_RESUMO",MVC_VIEW_ORDEM,'02') 
	oStructND0:SetProperty("ND0_DESTXT",MVC_VIEW_ORDEM,'03') 
	oStructND0:SetProperty("ND0_TPCAMP",MVC_VIEW_ORDEM,'04') 

Return oView

/** {Protheus.doc} OGA970INC
Função de inclusão
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    marcos.wagner
@since:     21/02/2019
@Uso: 		OGA970
*/
Function OGA970INC(cTpCampo)
	Local lRet := .f.
	Default cTpCampo := ""

	__cTpCampo := cTpCampo

	lRet := FWExecView( '','OGA970', MODEL_OPERATION_INSERT )
	
Return lRet

/** {Protheus.doc} OGA970FILT
Filtro das consultas na tabela ND0
@param: 	Nil
@return:	oView - View do modelo de dados
@author:    marcos.wagner
@since:     21/02/2019
@Uso: 		OGA970
*/
Function OGA970FILT(cFiltro) 
	Local lRet := .f.
	Local oModel := FwModelActive()
	Local cTipMer := oModel:GetValue( "N79UNICO","N79_TIPMER" )
	Local cCodPro := oModel:GetValue( "N79UNICO","N79_CODPRO" )

	If ND0->ND0_TPCAMP == cFiltro .AND. ND0->ND0_TIPMER == cTipMer .AND. ND0->ND0_CODPRO == cCodPro
		lRet := .t.
	EndIf
	
Return lRet
