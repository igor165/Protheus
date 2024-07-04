#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA040.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA040()
Cadastro de Destinat�rios
 
@sample	GTPA040()
 
@return	oBrowse  Retorna o Cadastro de Destinat�rios
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA040()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GZ5")
oBrowse:SetDescription(STR0001)  // Cadastro de Destinat�rios
oBrowse:AddLegend("GZ5_STATUS=='1'", "GREEN", STR0002) // Ativo
oBrowse:AddLegend("GZ5_STATUS=='2'", "RED", STR0003) // Inativo
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Defini��o do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com op��es do menu
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
Local oModel  := FwModelActive()

ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA040" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA040" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GTPA040" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GTPA040" OPERATION 5 ACCESS 0 // Excluir

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGZ5  := FWFormStruct(1,"GZ5")
Local bPosValidMdl	:= {|oModel| GA040PosValidMdl(oModel)}
Local oModel	:= MPFormModel():New("GTPA040",/*bPreValidMdl*/, bPosValidMdl,/*bCommit*/, /*bCancel*/ )

oStruGZ5:SetProperty('GZ5_EMAIL', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "vldMail(FwFldget('GZ5_EMAIL'))"))

oModel:SetDescription(STR0001) // Cadastro de Destinat�rios
 
oModel:AddFields('FIELDGZ5',,oStruGZ5)
oModel:GetModel('FIELDGZ5'):SetDescription(STR0001)  // Cadastro de Destinat�rios

oModel:SetPrimaryKey({'GZ5_FILIAL', 'GZ5_CODIGO'}) // Primary key pode ser definida no X2_�nica tamb�m 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := ModelDef()
Local oStruGZ5 := FWFormStruct(2, 'GZ5')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWGZ5', oStruGZ5, 'FIELDGZ5') 

oView:CreateHorizontalBox( 'SUPERIOR', 100)
oView:SetOwnerView('VIEWGZ5','SUPERIOR')

Return oView


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA040PosValidMdl(oModel)
P�s valida��o do commit MVC, para valida��o da chave prim�ria 
 
@sample	GA040PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA040PosValidMdl(oModel)

Local oModelGZ5	  := oModel:GetModel('FIELDGZ5')
Local lRet		  := .T.

// Se j� existir a chave no banco de dados no momento do commit, a rotina 
If (oModelGZ5:GetOperation() == MODEL_OPERATION_INSERT .OR. oModelGZ5:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GZ5", oModelGZ5:GetValue("GZ5_CODIGO")))
        lRet := .F.
    EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldMail(cMail)
Fun��o que valida se destinat�rio � email 
 
@sample	vldMail(cMail)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inova��o
@since		15/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function vldMail(cMail)

If (at( "@", cMail ) == 0)
    Return .F.
Endif	

Return .T.