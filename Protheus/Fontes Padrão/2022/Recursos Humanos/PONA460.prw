#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONA460.CH"

/*/{Protheus.doc} PONA460
Cadastro de Endereços para a marcação do ponto via clock-in
@type  Function
@author Cícero Alves
@since 05/10/2021
/*/
Function PONA460()
	
	Local oBrowse := FWMBrowse():New()
	
	Private aRotina := MenuDef()
	
	DbSelectArea("RRE")
	DbSetOrder(1)
	
	oBrowse:SetAlias("RRE")
	oBrowse:SetDescription(STR0001) //"Cadastro de Endereços para o Clock-in"
	oBrowse:SetFilterDefault( "RRE_FILIAL == SRA->RA_FILIAL .And. RRE_MAT == SRA->RA_MAT" )
	oBrowse:SetMenuDef( "PONA460" ) 
	
	oBrowse:Activate()
	
Return

/*/{Protheus.doc} MenuDef
Disponibiliza as Opções da rotina
@type  Static Function
@author Cícero Alves
@since 05/10/2021
@return aRotina, Array, Opções disponí­veis no menu da rotina
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "VIEWDEF.PONA460", 0, 3, 0, NIL } )	// "Incluir"
	aAdd( aRotina, { STR0003, "VIEWDEF.PONA460", 0, 4, 0, NIL } )	// "Alterar"
	aAdd( aRotina, { STR0004, "VIEWDEF.PONA460", 0, 2, 0, NIL } )	// "Visualizar"
	aAdd( aRotina, { STR0005, "VIEWDEF.PONA460", 0, 5, 0, NIL } )	// "Excluir"
	
Return aRotina

/*/{Protheus.doc} ViewDef
Cria a Interface da rotina
@type  Static Function
@author Cícero Alves
@since 05/10/2021
@return oView, Objeto, Instância da Classe FWFormView 
/*/
Static Function ViewDef()
	
	Local oModel 	:= FWLoadModel("PONA460")
	Local oView		:= FWFormView():New()
	Local oStruRRE := FWFormStruct( 2, "RRE" )
	
	oStruRRE:RemoveField("RRE_MAT")
	
	oView:SetModel(oModel)
	
	oView:AddField("VIEW_RRE", oStruRRE, "RRECADASTRO")
	
	oView:SetViewAction( "BUTTONCANCEL", {|| RollbackSXE()} )
	
	oView:CreateHorizontalBox( "CADASTRO", 100)
	
	oView:EnableTitleView("VIEW_RRE")
	
	oView:SetOwnerView("VIEW_RRE", "CADASTRO")
	
Return oView

/*/{Protheus.doc} ModelDef
Definições do modelo de dados
@type  Static Function
@author Cícero Alves
@since 05/10/2021
@return oModel, Objeto, Instância da classe MPFormModel
/*/
Static Function ModelDef()
	
	Local oModel := MPFormModel():New("PONA460",,{|oModel| fVldInfo(oModel)})
	Local oStruRRE := FWFormStruct( 1, "RRE" )
	
	oStruRRE:SetProperty("RRE_MAT", MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "SRA->RA_MAT"))
	oStruRRE:SetProperty("RRE_COD", MODEL_FIELD_KEY, .T.)
	
	oModel:AddFields( "RRECADASTRO",, oStruRRE)
	
	oModel:SetDescription( STR0001 ) // "Cadastro de Endereços Clock-in"
	oModel:GetModel( "RRECADASTRO" ):SetDescription( STR0007 )	// "Informações do Endereço"
	
Return oModel

/*/{Protheus.doc} fVldInfo
Valida as informações da tela
@type  Static Function
@author Cícero Alves
@since 05/10/2021
@param oModel, Objeto, Instância da classe MPFormModel
@return lOk, Lógico, indica se as informações são válidas
/*/
Static Function fVldInfo(oModel)
	
	Local OmodelRRE	:= oModel:GetModel("RRECADASTRO")
	Local lRet	:= .T.
	
	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		If Empty(Alltrim(OmodelRRE:GetValue("RRE_LATITU")) + Alltrim(OmodelRRE:GetValue("RRE_LONGIT")))
			
			If Empty(OmodelRRE:GetValue("RRE_ENDERE")) 
				// "Endereço não informado"
				Help(,, "Help", , STR0008, 1, 0, ,,,,, {STR0009})	// "Preencha o endereço com todas as informações, ou informe a latitude e longitude, para que o Clock-in consiga utilizá-lo para a Geolocalização."
				lRet := .F.
			ElseIf Empty(OmodelRRE:GetValue("RRE_CEP")) .Or. Empty(OmodelRRE:GetValue("RRE_UF")) .Or. Empty(OmodelRRE:GetValue("RRE_MUNICI"))
				If !IsBlind()
					// "Endereço incompleto"
					MsgAlert( STR0010, STR0011 ) // "É importante que o endereço tenha todas as informações para que o Clock-in consiga utilizá-lo para a Geolocalização."
				Else
					Help(,, "Help", , STR0011, 1, 0, ,,,,, {STR0010})
					lRet := .F.
				EndIf
			EndIf
		ElseIf Empty(OmodelRRE:GetValue("RRE_LATITU")) .Or. Empty(OmodelRRE:GetValue("RRE_LONGIT"))
			Help(,, "Help", , STR0011, 1, 0, ,,,,, {STR0010})
			lRet := .F.
		EndIf
	EndIf
	
Return lRet

