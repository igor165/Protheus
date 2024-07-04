#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------
/*/{Protheus.doc}	Complemento de Produto DCL / DCL-EST
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Function DCLEA014()

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbSelectArea("D30")
D30->(dbSetOrder(1)) //D30_FILIAL+D30_CODFOR+D30_LOJFOR+D30_INSTSI
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("D30")
oBrowse:SetMenuDef("DCLEA014")
oBrowse:SetDescription("Complemento Fornecedor DCL")

oBrowse:Activate()
	
Return Nil

//-----------------------------------------------------
/*/{Protheus.doc}Modelo de Dados
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruCab := FWFormStruct(1,"D30") //Estrutura Cabecalho 

oModel := MPFormModel():New("DCEA014", /*bPreValidacao*/,{|oModel|EA014PosValid(oModel)}/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
oModel:AddFields("D30MASTER",/*cOwner*/,oStruCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetDescription("Complemento Fornecedor DCL")
oModel:SetPrimaryKey( {} ) //Obrigatorio setar a chave primaria (mesmo que vazia)
oModel:SetActivate({|oModel| A014Active(oModel )})

Return oModel

//-----------------------------------------------------
/*/{Protheus.doc} - View do Cadastro
@author jose.eulalio
@version P12
@since 20/02/2017
/*/
//------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel("DCLEA014")
Local oStruCab	:= FWFormStruct(2,"D30") //Estrutura Cabecalho 
Local oView		:= FWFormView():New()

oView:SetModel(oModel)

//	Insere os componentes na view
oView:AddField("MASTER_D30",oStruCab,"D30MASTER")   //Cabecalho 

//	Cria os Box's
oView:CreateHorizontalBox("CABEC",20)

//	Associa os componentes
oView:SetOwnerView("MASTER_D30","CABEC")

Return oView


//-----------------------------------------------------
/*/{Protheus.doc}	Menu de opcoes
@author jose.eulalio
@version P12
@since 21/02/2014
/*/
//------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"  ACTION "VIEWDEF.DCLEA014" OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
ADD OPTION aRotina TITLE "Incluir"     ACTION "VIEWDEF.DCLEA014" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"     ACTION "VIEWDEF.DCLEA014" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina TITLE "Excluir"     ACTION "VIEWDEF.DCLEA014" OPERATION MODEL_OPERATION_DELETE ACCESS 3

Return aRotina

//-----------------------------------------------------
/*/{Protheus.doc}A014Active
Activate do modelo
@author jose.eulalio
@param oModel
@return aCarga
@version P12
@since 08/03/2014
/*/
//------------------------------------------------------
Static Function A014Active(oModel)
Local lRet			:= .T.
Local oModMaster	:= oModel:GetModel("D30MASTER")
Local nOper		:= oModel:GetOperation() 

oModMaster:GetStruct():setProperty('D30_CODFOR',MODEL_FIELD_OBRIGAT,.T.)
oModMaster:GetStruct():setProperty('D30_CODFOR',MODEL_FIELD_OBRIGAT,.T.)

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}EA014PosValid
Activate do modelo
@author jose.eulalio
@param oModel
@return lRet
@version P12
@since 23/02/2014
/*/
//------------------------------------------------------
Static Function EA014PosValid(oModel)
Local lRet			:= .T.

Return lRet

//-----------------------------------------------------
/*/{Protheus.doc}DCLA014Del
Rotina automatica para deletar
@author jose.eulalio
@return lRet
@version P12
@since 24/02/2014
/*/
//------------------------------------------------------
Function DCLA014Del(cForn,cLoja)
Local lRet			:= .T.
Local aAreaD30	:= D30->(GetArea())
Local oModel

If D30->(DbSeek(xFilial("D30") + cForn + cLoja ))
	oModel := FwLoadModel("DCLEA014")
	oModel:SetOperation(MODEL_OPERATION_DELETE)  
	oModel:Activate()
	oModel:CommitData()
	oModel:DeActivate()
EndIf

Return lRet



