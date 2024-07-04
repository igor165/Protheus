#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "GTPA426.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA426
(long_description)
@type function
@author crisf
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Function GTPA426()
	
	Local   oBrowse   := Nil
	
		oBrowse:=FWMBrowse():New()
		oBrowse:SetAlias('GZJ')
		oBrowse:SetDescription(STR0001)//"Registros Base para calculo de Comissão"
		oBrowse:Activate()
		
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} $ModelDef
(long_description)
@type function
@author crisf
@since 08/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function ModelDef()
	
	//Local oStruGZJ	:= FWFormStruct(1,'GZJ')
	Local oModel 	:= MPFormModel():New('GTPA426',/*bPreValid*/, /*bPost*/, /*bCommit*/)
	Local oStrGZJC	:= FWFormStruct(1,'GZJ',{|cCampo| (AllTrim(cCampo) $ "GZJ_FILIAL,GZJ_CODG94") }) 
	Local oStrGZJD	:= FWFormStruct(1,'GZJ') 
	
	//oModel:AddFields('GZJDETALHE',/*cOwner*/,oStruGZJ)	
	oModel:AddFields('GZJCABEC',/*cOwner*/,oStrGZJC)
	oModel:AddGrid('GZJDETALHE', 'GZJCABEC', oStrGZJD,/*bPreGIH*/,/*bPosGIH*/)
	oModel:SetRelation( "GZJDETALHE", { { 'GZJ_FILIAL', 'xFilial( "GZJ" )' }, { "GZJ_CODG94", "GZJ_CODG94" } }, GZJ->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey({ 'GZJ_FILIAL', 'GZJ_CODG94','GZJ_SEQUEN'})
	
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author crisf
@since 09/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel	:= FWLoadModel('GTPA426')
	Local oView	
	Local oStrGZJC	:= FWFormStruct(2,'GZJ',{|cCampo| (AllTrim(cCampo) $ "GZJ_FILIAL,GZJ_CODG94") }) 
	Local oStrGZJD	:= FWFormStruct(2,'GZJ') 
			
		oView:=FWFormView():New()
		oView:SetModel(oModel)
		
		oStrGZJD:RemoveField('GZJ_CODG94')
		
		oView:AddField("VIEW_CAB" , oStrGZJC, "GZJCABEC")
		oView:AddGrid("VIEW_DET" , oStrGZJD, "GZJDETALHE") 
	
		oView:CreateHorizontalBox("TELAUP",10)//Campos do cabeçalho 
		oView:CreateHorizontalBox("TELADOWN",90)//Detalhes
		
		oView:SetOwnerView("VIEW_CAB", "TELAUP") 
		oView:SetOwnerView("VIEW_DET", "TELADOWN") 
		
		oView:SetModel( oModel )
		
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@type function
@author crisf
@since 07/11/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.GTPA426' OPERATION 2 ACCESS 0//'Visualizar'
		ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA426' OPERATION 8 ACCESS 0//'Imprimir'

Return aRotina