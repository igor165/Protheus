#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA037.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA037
(long_description)
@type function
@author crisf
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Function GTPA037()
Local aArea 	:= GetArea()
Local cCadastro	:= STR0001//"Tipo de Bonificação ou Desconto"

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("G5K")
oBrowse:SetDescription(cCadastro)
oBrowse:SetUseFilter(.T.)
oBrowse:SetUseCaseFilter(.T.)				
oBrowse:Activate()
	
RestArea(aArea)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author crisf
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStruct := FWFormStruct(1, 'G5K')
Local bActive := {|oModel| VldModif(oModel)}

oModel := MPFormModel():New('GTPA037',/*bPreVld*/, /*bPosVld*/, /*bCommit*/)		
oModel:AddFields('G5KMASTER', /*cOwner*/, oStruct)
oModel:SetPrimaryKey({'G5K_FILIAL', 'G5K_CODIGO'})
oModel:SetDescription(STR0001)//"Tipo de Bonificação ou Desconto"

oModel:SetVldActivate(bActive)
		
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author crisf
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('GTPA037')
Local oStruG5K := FWFormStruct(2, 'G5K')
Local oView	   := nil

oView := FWFormView():New()
oView:AddField('VIEW_G5K', oStruG5K, 'G5KMASTER')
oView:SetModel(oModel)
		
Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@type function
@author crisf
@since 19/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA037" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA037" OPERATION 3 ACCESS 0 //"Incluir"	
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA037" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GTPA037" OPERATION 5 ACCESS 0 //"Excluir"	
			
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldModif
Valida se o cadastro possui vinculo ou não para poder ser modificado.
@type function
@author crisf
@since 25/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function VldModif(oModel)
Local lVldModif	:= .T.
Local cTmpGYA   := GetNextAlias()
				
If (oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 5)
	BeginSQL alias cTmpGYA
		SELECT 
			GIH.GIH_CODG5D
		FROM 
			%Table:GIH% GIH 
		WHERE 
			GIH.GIH_FILIAL = %xFilial:GIH%
			AND GIH_CODGYA = %Exp:G5K->G5K_CODIGO%
			AND GIH.%NotDel% 		
	EndSQL
	
	if !(cTmpGYA)->(Eof())
		FWAlertHelp(STR0007, STR0008 + (cTmpGYA)->GIH_CODG5D + ".") //"Não é permitido modificar cadastros associados a uma comissão."##"Criar um novo cadastro. Visualizar a comissão de exemplo número "
		lVldModif := .F.	
	EndIf
	
	(cTmpGYA)->(dbCloseArea())
EndIf
		
Return lVldModif
