#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA504.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA504

Cadastro de Tipo de Documento

@Author		Felipe C. Seolin
@Since		11/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA504()

Local oBrowse	as object

oBrowse	:=	FwMBrowse():New()

If TAFAlsInDic( "V1P" )
	oBrowse:SetDescription( STR0001 ) //"Tipo de Documento"
	oBrowse:SetAlias( "V1P" )
	oBrowse:SetMenuDef( "TAFA504" )
	oBrowse:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Return	aRotina - Array com as opções de menu.

@Author		Felipe C. Seolin
@Since		11/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return( xFunMnuTAF( "TAFA504" ) )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função genérica MVC do modelo.

@Return	oModel - Objeto do modelo MVC

@Author		Felipe C. Seolin
@Since		11/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV1P	as object
Local oModel	as object

oStruV1P	:=	FWFormStruct( 1, "V1P" )
oModel		:=	MPFormModel():New( "TAFA504" )

oModel:AddFields( "MODEL_V1P", /*cOwner*/, oStruV1P )
oModel:GetModel( "MODEL_V1P" ):SetPrimaryKey( { "V1P_CODIGO", "V1P_VALIDA" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da view.

@Return	oView - Objeto da view MVC

@Author		Felipe C. Seolin
@Since		11/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruV1P	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA504" )
oStruV1P	:=	FWFormStruct( 2, "V1P" )
oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_V1P", oStruV1P, "MODEL_V1P" )
oView:EnableTitleView( "VIEW_V1P", STR0001 ) //"Tipo de Documento"

oView:CreateHorizontalBox( "FIELDSV1P", 100 )

oView:SetOwnerView( "VIEW_V1P", "FIELDSV1P" )

oStruV1P:RemoveField( "V1P_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	- Versão corrente na empresa
			nVerAtu	- Versão atual ( passado como referência )

@Return	aRet		- Array com estrutura de campos e conteúdo da tabela

@Author		Felipe C. Seolin
@Since		11/04/2018
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	as array
Local aBody		as array
Local aRet		as array

aHeader	:=	{}
aBody	:=	{}
aRet	:=	{}

nVerAtu := 1023

If nVerEmp < nVerAtu
	aAdd( aHeader, "V1P_FILIAL" )
	aAdd( aHeader, "V1P_ID" )
	aAdd( aHeader, "V1P_CODIGO" )
	aAdd( aHeader, "V1P_DESCRI" )
	aAdd( aHeader, "V1P_VALIDA" )

	aAdd( aBody, { "", "08dbb739-f7fd-1690-0d29-588ff5ca0bb8", "CI", "Cédula de Identidade", "" } )
	aAdd( aBody, { "", "f9817a0a-fb30-8cf4-ab79-1b4644598e99", "PS", "Passaporte", "" } )
	aAdd( aBody, { "", "f5ea139f-c720-dea2-3f07-bc60d5145929", "BI", "Bilhete de Identidade", "" } )
	aAdd( aBody, { "", "d78e3933-b340-6a09-7666-e69849ad88a2", "DI", "Documentos Nacional de Identificação", "" } )
	aAdd( aBody, { "", "d8bfa851-10a1-b4d8-a949-afb105087405", "SR", "State Registry", "" } )
	aAdd( aBody, { "", "9d7a4b9e-38a3-1abb-d10b-92aa54b24c1d", "CT", "Carnet de Identidad", "" } )
	aAdd( aBody, { "", "5c4a6d05-b18f-1c3e-6be5-a832b0c914d8", "TI", "Tarjeta de Identidad", "" } )
	aAdd( aBody, { "", "551ee8cc-e8ec-a752-bc7e-6f5bbb478844", "NC", "National Identity Card", "" } )
	aAdd( aBody, { "", "1aee299e-e7cc-6767-652c-1e1df9878892", "PC", "Permanent Resident Cards", "" } )
	aAdd( aBody, { "", "fe791edb-d723-73b1-d22d-1cfdee1963cd", "DL", "Driver's License", "" } )
	aAdd( aBody, { "", "c83f6c53-bf95-4195-a46b-1328f1cec590", "SN", "Social Securty Number (SSN)", "" } )
	aAdd( aBody, { "", "57dd3d16-532a-00d1-e3c5-5330c8bf17f0", "OT", "Outros", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )