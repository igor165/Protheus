#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA303A.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303A
(long_description)
@type function
@author jacomo.fernandes
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function GTPA303A()

Local oBrowse	:= Nil		

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GQE")
oBrowse:SetDescription("Alocação de Colaborador")	// Tipos de Vales
oBrowse:Activate()

Return (oBrowse)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados para alocação de colaborador
@type function
@author jacomo.fernandes
@since 31/10/2017
@version 1.0
@return oModel, Retorna o modelo de dados
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
Local oStruct	:= FWFormStruct( 1,"GQE") 
Local oModel	:= MPFormModel():New('GTPA303A',/*bPreValid*/,{|oModel|Ga303aVldPos(oModel)}/*bPosValid*/, /*bCommit*/  )
Local bTrig	:= {|oMdl,cField,xVal|Ga303aRunTrg(oMdl,cField,xVal)}

oStruct:SetProperty("GQE_ITEM"	, MODEL_FIELD_VALID	, {|| ExistChav('GQE',FwFldGet('GQE_VIACOD')+FwFldGet('GQE_SEQ')+FwFldGet('GQE_ITEM'),3) } )
oStruct:SetProperty("GQE_ITEM"	, MODEL_FIELD_OBRIGAT,.T.)

oStruct:AddTrigger("GQE_CODVIA"	,"GQE_CODVIA"	,{||.T.},bTrig)
oStruct:AddTrigger("GQE_SEQ"	,"GQE_SEQ"		,{||.T.},bTrig)

oModel:AddFields('FIELD_GQE',/*Owner*/,oStruct)

oModel:SetPrimaryKey({})

oModel:SetDescription("Alocação de Colaborador") 


Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacomo.fernandes
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA303A')
Local oStruct	:= FWFormStruct(2, 'GQE')

oView:SetModel(oModel)
oView:AddField('VIEW', oStruct, 'FIELD_GQE') 

oView:CreateHorizontalBox( 'BOX', 100)
oView:SetOwnerView('VIEW','BOX')

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@type function
@author jacomo.fernandes
@since 31/10/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GTPA303A"	OPERATION 2	ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.GTPA303A" 	OPERATION 3	ACCESS 0 	// "Incluir"
ADD OPTION aRotina TITLE "Excluir"   	ACTION "VIEWDEF.GTPA303A"	OPERATION 5	ACCESS 0 	// "Excluir"
ADD OPTION aRotina TITLE "Alterar"   	ACTION "VIEWDEF.GTPA303A"	OPERATION 4	ACCESS 0 	// "Alterar"

Return ( aRotina )
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga303aVldPos
(long_description)
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga303aVldPos(oModel)
Local lRet 	:= .T.
Local oMdlGQE := oModel:GetModel("FIELD_GQE")

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	If !ExistChav('GQE',FwFldGet('GQE_VIACOD')+FwFldGet('GQE_TRECUR')+FwFldGet('GQE_RECURS')+FwFldGet('GQE_SEQ'),2)
		lRet := .F.
	ElseIf !ExistChav('GQE',FwFldGet('GQE_VIACOD')+FwFldGet('GQE_SEQ')+FwFldGet('GQE_ITEM'),3)
		lRet := .F.
	Endif
	
	oMdlGQE:SetValue("GQE_USRALO", cUserName)
	oMdlGQE:SetValue("GQE_DTALOC", FwTimeStamp(2))
	
Endif
Return lRet

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga303aRunTrg
(long_description)
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga303aRunTrg(oMdl,cField,xVal)
Local cNewAlias	:= GetNextAlias()
Local cCodGYN		:= oMdl:GetValue('GQE_VIACOD')
Local cCodG55		:= oMdl:GetValue('GQE_SEQ')

If !Empty(cCodGYN) .and. !Empty(cCodG55)
	BeginSql Alias cNewAlias
		Select 
			(CASE WHEN MAX(GQE_ITEM) IS NULL THEN 1 ELSE  MAX(GQE_ITEM) +1 END) AS MAXGQE
		From 
			%Table:GQE% GQE
		Where
			GQE_FILIAL = %xFilial:GQE% AND 
			GQE_VIACOD = %Exp:cCodGYN% AND
			GQE_SEQ = %Exp:cCodG55% AND
			%NotDel%
	EndSql
	oMdl:SetValue('GQE_ITEM',StrZero((cNewAlias)->MAXGQE,TamSx3('GQE_ITEM')[1] ))
	(cNewAlias)->(DbCloseArea())
Else
	oMdl:SetValue('GQE_ITEM','')
Endif
Return xVal

