#INCLUDE "AGRA050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGRA050
//TODO Descrição auto-gerada.
@author silvana.torres
@since 09/10/2017
@version undefined

@type function
/*/
Function AGRA050()

	Local oMBrowse	:= Nil

	oMBrowse := FWMBrowse():New()  // Instancia o Browse
	oMBrowse:SetAlias( "NNV" )
	oMBrowse:SetMenuDef( "AGRA050" )
	oMBrowse:SetDescription(STR0001) //"Cadastro de Variedades"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
	
Return 

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author silvana.torres
@since 09/10/2017
@version undefined

@type function
/*/
Static Function MenuDef()

	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.AGRA050' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.AGRA050' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.AGRA050' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.AGRA050' OPERATION 5 ACCESS 0    // 'Excluir'  

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author silvana.torres
@since 09/10/2017
@version undefined

@type function
/*/
Static Function ModelDef()

	Local oModel	:= nil	
	Local oStruNNV 	:= FWFormStruct(1, "NNV")
	
	oModel := MPFormModel():New("AGRA050",/*bPre*/ ,/*bPost*/ ,/*bCommit*/ , /*bCancel*/)
	
	oStruNNV:SetProperty('NNV_DESCRI', MODEL_FIELD_OBRIGAT, .F.)
	
	oModel:SetDescription(STR0001)
	oModel:AddFields('AGRA050_NNV', , oStruNNV)
	oModel:getModel('AGRA050_NNV'):SetDescription(STR0001)
	
Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author silvana.torres
@since 09/10/2017
@version undefined

@type function
/*/
Static Function ViewDef()

	Local oView  	:= FWFormView():New()
	Local oModel 	:= ModelDef()
	Local oStrNNV 	:= FWFormStruct(2, "NNV")

	If NNV->(ColumnPos('NNV_ID')) > 0 
		oStrNNV:RemoveField('NNV_ID')
	EndIf
		
	oView:SetModel(oModel)
	oView:addField("VIEW_NNV",oStrNNV,"AGRA050_NNV")
		       
Return oView
	

/*/{Protheus.doc} IntegDef
//TODO Descrição auto-gerada.
@author silvana.torres
@since 09/10/2017
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )


	Local aRet := {}
	
	if !NNV->(ColumnPos('NNV_ATIVO') > 0)
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	endIf	
	
	if ExistFunc("AGRI050")
		aRet:= AGRI050( cXml, nTypeTrans, cTypeMessage )
	endIf

Return aRet