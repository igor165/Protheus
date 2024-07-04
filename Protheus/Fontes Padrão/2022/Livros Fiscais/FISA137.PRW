#INCLUDE "FISA137.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA137

Cadastro de complementos de estabelecimentos

@author flavio.luiz
@since 30/12/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA137()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "F0F" )
oBrowse:SetDescription( STR0001 ) //"Cadastro de complementos de estabelecimentos"
oBrowse:Activate()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de complementos de estabelecimentos

@author flavio.luiz
@since 30/12/2017
/*/
//--------------------------------------------------------------------------
Static Function ModelDef()
Local oStruF0F := FwFormStruct( 1, "F0F", {|cCampo|!AllTrim(cCampo)+"|" $ "F0F_FILIAL|"} )
Local oModel   := MpFormModel():New( "FISA137", , { |oModel| ValidForm( oModel ) } )

oModel:AddFields( "MODEL_F0F", /*cOwner*/, oStruF0F )
oModel:SetDescription( STR0001 ) //"Cadastro de complementos de estabelecimentos"
oModel:SetPrimaryKey({"FOF_FILIAL","FOF_CODFIL","FOF_OBRA"})

oStruF0F:SetProperty( "F0F_CODFIL", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })
oStruF0F:SetProperty( "F0F_OBRA"  , MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })

Return oModel
//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de complementos de estabelecimentos

@author flavio.luiz
@since 30/12/2017
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FwLoadModel( "FISA137" )
Local oStruF0F := FwFormStruct( 2, "F0F", {|cCampo|!AllTrim(cCampo)+"|" $ "F0F_FILIAL|"} )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_F0F", oStruF0F, "MODEL_F0F" )

oView:CreateHorizontalBox( "TOTAL", 100 )
oView:SetOwnerView( "VIEW_F0F", "TOTAL" )

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de complementos de estabelecimentos

@author flavio.luiz
@since 30/12/2017
/*/
//----------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.FISA137" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.FISA137" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FISA137" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.FISA137" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina
//----------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author flavio.luiz
@since 30/12/2017
/*/
//----------------------------------------------------------------
Static Function ValidForm(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local cCodFil    := oModel:GetValue( "MODEL_F0F", "F0F_CODFIL" )
Local cCodObra   := oModel:GetValue( "MODEL_F0F", "F0F_OBRA"   )

If (nOperation == MODEL_OPERATION_INSERT)
	DbSetOrder(1)
	If F0F->( dbSeek( xFilial( "F0F" ) + cCodFil + cCodObra) )
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	EndIf
EndIf

Return lRet