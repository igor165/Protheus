#INCLUDE "OGA870.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} OGA870()
Rotina para cadastro de Itens de Controle Pepro
@type  Function
@author tamyris.g
@since 31/07/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA870()
Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NBY" )
oMBrowse:SetDescription( STR0001 ) //"Itens de Controle Pepro"

oMBrowse:Activate()

Return()

/*/{Protheus.doc} MenuDef()
Função que retorna os itens para construção do menu da rotina
@type  Function
@author tamyris.g
@since 31/07/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'PesqBrw'       , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0004, 'ViewDef.OGA870', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0005, 'ViewDef.OGA870', 0, 3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0006, 'ViewDef.OGA870', 0, 4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0007, 'ViewDef.OGA870', 0, 5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0008, 'ViewDef.OGA870', 0, 8, 0, Nil } ) //'Imprimir'

Return aRotina

/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author tamyris.g
@since 31/07/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oStruNBY := FWFormStruct( 1, "NBY" )
Local oModel   := MPFormModel():New( "OGA870", , , )

oStruNBY:AddTrigger( "NBY_TIPDOC", "NBY_DTPDOC", , { |  | fTrgTipDoc( ) } )

oModel:AddFields( 'NBYUNICO', Nil, oStruNBY )
oModel:SetDescription( STR0001 ) //"Itens de Controle Pepro"
oModel:GetModel( 'NBYUNICO' ):SetDescription( STR0001 ) 

Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author tamyris.g
@since 31/07/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oStruNBY	:= FWFormStruct( 2, "NBY" )
Local oModel	:= FWLoadModel( "OGA870" )
Local oView		:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_NBY', oStruNBY, 'NBYUNICO' )
oView:CreateHorizontalBox( 'TOTAL'  , 100 )
oView:SetOwnerView( 'VIEW_NBY', 'TOTAL'   )

oView:SetCloseOnOk( {||.t.} )

Return oView

/** {Protheus.doc} fTrgTipDoc
Função criada para tratar a data final
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso:       OGA820
*/
Static Function fTrgTipDoc(  )
	Local oModel	:= FwModelActive()
	Local oNBY		:= oModel:GetModel( "NBYUNICO" )
	
	cRet := DescTipDoc(oNBY:GetValue("NBY_TIPDOC"))

return cRet

/** {Protheus.doc} fTrgTipDoc
Função criada para tratar a data final
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     23/05/2018
@Uso:       OGA820
*/
Function DescTipDoc(nTipDoc)
	
	Local cRet := ""
	
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT N9S_DESCRI "
	cQuery += " FROM " + RetSqlName("N9S") + " N9S "
	cQuery += " WHERE N9S.N9S_FILIAL = '" + FwxFilial('N9S') + " '"
	cQuery += " AND   N9S.N9S_CODIGO = "  + AllTrim(Str(nTipDoc)) + " " 
	cQuery += " AND   N9S.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	If (cAliasQry)->(!Eof() )
		
		cRet := (cAliasQry)->N9S_DESCRI
		(cAliasQry)->(dbSkip())
	EndIf
	(cAliasQry)->(DbcloseArea())
	
return cRet

