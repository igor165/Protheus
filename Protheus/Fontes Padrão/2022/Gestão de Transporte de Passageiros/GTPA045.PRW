#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA045.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA045()
Cadastro de Cheques
 
@sample	GTPA045()
 
@return	oBrowse	Retorna o Cadastro de Cheques
 
@author	Flavio Martins -  Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA045()

Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GZD')
oBrowse:SetDescription(STR0001) //Cadastro de Cheques
oBrowse:Activate()

Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Flavio Martins -  Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA045' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA045" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA045" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "GA045Del" OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Flavio Martins -  Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruGZD	:= FWFormStruct(1,'GZD')
Local bPosvalid	:= {|oModel|TP045TudOK(oModel)}

oStruGZD:SetProperty("GZD_CODIGO", MODEL_FIELD_WHEN, {|| INCLUI } )

oModel := MPFormModel():New('GTPA045', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
oModel:AddFields('GZDMASTER',/*cOwner*/,oStruGZD)
oModel:GetModel('GZDMASTER'):SetDescription(STR0001) //Cadastro de Cheques
oStruGZD:SetProperty('GZD_DTEMIS', MODEL_FIELD_VALID, {||GA045VldDt()})
oStruGZD:SetProperty('GZD_DTDEPO', MODEL_FIELD_VALID, {||GA045VldDt()})
oModel:SetPrimaryKey({"GZD_FILIAL","GZD_CODIGO"})

oStruGZD:SetProperty('GZD_AGENCI',MODEL_FIELD_VALID, {|oMdl,cField,cNewValue,cOldValue| ValidUserAg(oMdl,cField,cNewValue,cOldValue) } )

Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Flavio Martins -  Inovação
@since		20/07/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGZD	:= FWFormStruct(2, 'GZD')

oView:SetModel(oModel)
oView:SetDescription(STR0006) 
oView:AddField('VIEW_GZD' ,oStruGZD,'GZDMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_GZD','TELA')

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} GA045VldDt

Valida datas de emissão e depósito

@param	cDataIni, cDataFim

@author	Flavio Martins -  Inovação
@since		21/07/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function GA045VldDt()
Local lRet := .T.
Local oModel	:= FwModelActive()
Local cDtEmis	:= DtoS(oModel:GetModel('GZDMASTER'):GetValue('GZD_DTEMIS'))
Local cDtDepo	:= DtoS(oModel:GetModel('GZDMASTER'):GetValue('GZD_DTDEPO'))

If !Empty(cDtDepo) .And. (cDtDepo < cDtEmis) 
	lRet	:= .F.
EndIf

Return lRet

/*/{Protheus.doc} GA045Del
(long_description)
@type function
@since 18/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA045Del()

Local cFichaR	:=  GZD->GZD_FICHAR

IF Empty(cFichar)
   FWExecView( STR0005,'VIEWDEF.GTPA045', MODEL_OPERATION_DELETE, , , , , )
Else
	MsgAlert(STR0007)
ENDIF

Return NIL    

//-------------------------------------------------------------------
/*/{Protheus.doc} TP045TudOK

Validação pos valid

@param	oModel

@author	 -  Inovação
@since		25/07/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function TP045TudOK(oModel)
Local lRet		:= .T.
Local oMdlGZD	:= oModel:GetModel("GZDMASTER")
Local aArea		:= GetArea()

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	dbSelectArea("GZD")
	GZD->(dbSetOrder(1))
	//Verifica se o registro ja foi cadastrado.
	If GZD->(dbSeek(xFilial("GZD")+oMdlGZD:GetValue("GZD_NUMERO")+oMdlGZD:GetValue("GZD_BANCO")+;
					oMdlGZD:GetValue("GZD_BCOAGE")+oMdlGZD:GetValue("GZD_CONTA")))
		
		Help( ,, 'Help',"GTPA045", STR0008, 1, 0 )
		lRet	:= .F.
		
	EndIf
EndIf

RestArea(aArea)

Return lRet
