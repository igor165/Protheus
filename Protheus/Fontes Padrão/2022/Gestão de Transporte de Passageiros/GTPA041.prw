#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA041.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA040()
Cadastro de Grupos de Destinatários
 
@sample	GTPA040()
 
@return	oBrowse  Retorna o Cadastro de Destinatários
 
@author	Renan Ribeiro Brando -  Inovação
@since		08/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA041()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GZ6")
oBrowse:SetDescription(STR0001)  // Cadastro de Grupos de Destinatários
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

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA041" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA041" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA041" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA041" OPERATION 5 ACCESS 0 // Excluir

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

Local oStruGZ6  := FWFormStruct(1,"GZ6")
Local oStruGZ7  := FWFormStruct(1,"GZ7")
Local bPosValidMdl	:= {|oModel| GA041PosValidMdl(oModel)}
Local oModel	:= MPFormModel():New("GTPA041",/*bPreValidMdl*/, bPosValidMdl,/*bCommit*/, /*bCancel*/ )

// Gatilho do Destinatário               
oStruGZ7:AddTrigger('GZ7_CODDES'  , ;     // [01] Id do campo de origem
					'GZ7_CODDES'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
		 			{ || GA041TrigDest() } ) // [04] Bloco de codigo de execução do gatilho

oStruGZ7:SetProperty('GZ7_CODDES',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA041VldCodDest()"))

oModel:SetDescription(STR0001) // Cadastro de Destinatários
 
oModel:AddFields('FIELDGZ6',,oStruGZ6)
oModel:AddGrid("GRIDGZ7", "FIELDGZ6", oStruGZ7,/*bPreVld*/,,,,)
oModel:SetRelation( 'GRIDGZ7', { { 'GZ7_FILIAL', 'xFilial( "GZ6" ) ' } , { 'GZ7_CODGRU', 'GZ6_CODIGO' } } , GZ7->( IndexKey( 1 ) ) )

oModel:GetModel('GRIDGZ7'):SetUniqueLine({"GZ7_FILIAL","GZ7_CODDES"})  //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
oModel:GetModel('FIELDGZ6'):SetDescription(STR0001) // Cadastro de Grupos de Destinatários

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
Local oStruGZ7 := FWFormStruct(2, 'GZ7')
Local oStruGZ6 := FWFormStruct(2, 'GZ6')

oStruGZ7:SetProperty("GZ7_CODDES", MVC_VIEW_LOOKUP , "GZ5")
oStruGZ7:RemoveField("GZ7_CODGRU")

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWGZ6', oStruGZ6, 'FIELDGZ6') 
oView:AddGrid('VIEWGRIDGZ7', oStruGZ7, 'GRIDGZ7') 

oView:CreateHorizontalBox( 'SUPERIOR', 40)
oView:CreateHorizontalBox( 'INFERIOR', 60)
oView:SetOwnerView('VIEWGZ6','SUPERIOR')
oView:SetOwnerView('VIEWGRIDGZ7','INFERIOR')

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA041TrigDest
Função que preenche os dados do destinatário

@sample	GA041TrigDest()

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA041TrigDest()

Local oModel    := FwModelActive()
Local oFieldGZ7 := oModel:GetModel('GRIDGZ7')

oFieldGZ7:SetValue("GZ7_EMAIL" , Posicione("GZ5",1,xFilial("GZ5")+FWFldGet("GZ7_CODDES"),"GZ5_EMAIL")) 
oFieldGZ7:SetValue("GZ7_STATUS", Posicione("GZ5",1,xFilial("GZ5")+FWFldGet("GZ7_CODDES"),"GZ5_STATUS"))

Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA041VldCodDest
Valida se o destinatário existe

@sample GA041VldCodDest()
@return  lRet

@author	Renan Ribeiro Brando - Inovação
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA041VldCodDest()
Local oModel	  := FWModelActive()
Local cAliasGZ5	  := GetNextAlias()
Local oModelGZ7	  := oModel:GetModel('GRIDGZ7')
Local cCodDest	  := oModelGZ7:GetValue("GZ7_CODDES")
Local lRet		  := .T.

If (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	BeginSQL Alias cAliasGZ5
		SELECT 
			COUNT(*) GZ5_CODIGO
		FROM 
			%table:GZ5% GZ5 
		WHERE
			GZ5.GZ5_FILIAL = %xFilial:GZ5%
			AND GZ5.GZ5_CODIGO = %Exp:cCodDest%  
			AND GZ5.%NotDel%
	EndSQL
	// Verifica se já existe um vale aberto daquele tipo para aquele funcionário
	If (!((cAliasGZ5)->GZ5_CODIGO > 0))
		Help(,, STR0006,, STR0007, 1,0 ) // Atenção, Destinatário não existente
		lRet := .F.
	EndIf
	(cAliasGZ5)->(DbCloseArea())
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA041PosValidMdl(oModel)
Pós validação do commit MVC, para validação da chave primária 
 
@sample	GA041PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA041PosValidMdl(oModel)

Local oModelGZ6	  := oModel:GetModel('FIELDGZ6')
Local oModelGZ7	  := oModel:GetModel('GRIDGZ7')
Local lRet		  := .T.

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oModelGZ6:GetOperation() == MODEL_OPERATION_INSERT .OR. oModelGZ6:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GZ6", oModelGZ6:GetValue("GZ6_CODIGO")))
        lRet := .F.
    EndIf
EndIf

Return lRet