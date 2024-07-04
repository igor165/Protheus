#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA040.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA040()
Cadastro de Destinatários
 
@sample	GTPA040()
 
@return	oBrowse  Retorna o Cadastro de Destinatários
 
@author	Renan Ribeiro Brando -  Inovação
@since		08/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA040()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GZ5")
oBrowse:SetDescription(STR0001)  // Cadastro de Destinatários
oBrowse:AddLegend("GZ5_STATUS=='1'", "GREEN", STR0002) // Ativo
oBrowse:AddLegend("GZ5_STATUS=='2'", "RED", STR0003) // Inativo
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Renan Ribeiro Brando -  Inovação
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
Definição do modelo de Dados

@author	Renan Ribeiro Brando -  Inovação
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGZ5  := FWFormStruct(1,"GZ5")
Local bPosValidMdl	:= {|oModel| GA040PosValidMdl(oModel)}
Local oModel	:= MPFormModel():New("GTPA040",/*bPreValidMdl*/, bPosValidMdl,/*bCommit*/, /*bCancel*/ )

oStruGZ5:SetProperty('GZ5_EMAIL', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID , "vldMail(FwFldget('GZ5_EMAIL'))"))

oModel:SetDescription(STR0001) // Cadastro de Destinatários
 
oModel:AddFields('FIELDGZ5',,oStruGZ5)
oModel:GetModel('FIELDGZ5'):SetDescription(STR0001)  // Cadastro de Destinatários

oModel:SetPrimaryKey({'GZ5_FILIAL', 'GZ5_CODIGO'}) // Primary key pode ser definida no X2_única também 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author	Renan Ribeiro Brando -  Inovação
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
Pós validação do commit MVC, para validação da chave primária 
 
@sample	GA040PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA040PosValidMdl(oModel)

Local oModelGZ5	  := oModel:GetModel('FIELDGZ5')
Local lRet		  := .T.

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oModelGZ5:GetOperation() == MODEL_OPERATION_INSERT .OR. oModelGZ5:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GZ5", oModelGZ5:GetValue("GZ5_CODIGO")))
        lRet := .F.
    EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldMail(cMail)
Função que valida se destinatário é email 
 
@sample	vldMail(cMail)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inovação
@since		15/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function vldMail(cMail)

If (at( "@", cMail ) == 0)
    Return .F.
Endif	

Return .T.