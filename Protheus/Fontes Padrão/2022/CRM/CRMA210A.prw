#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA210A.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cadastro de Papeis do Usuário.

@sample		CRMA210A( uRotAuto, nOpcAuto )

@param		uRotAuto, array		, Papeis do Usuário
			nOpcAuto, numerico	, Numero de identificacao da operacao
			
@return		lRetorno, logico, Verdadeiro / Falso quanto ao sucesso da operação.	

@author		Anderson Silva
@since		08/01/2016
@version	P12
/*/
//-------------------------------------------------------------------
Function CRMA210A( uRotAuto, uOpcAuto )
	Local oMBrowse		:= Nil
	Local lRetorno		:= .T.

	Default uRotAuto	:= Nil
	Default uOpcAuto	:= Nil

	Private lMsErroAuto := .F.

	DbSelectArea("AZR")
	AZR->( DbSetOrder(1) )

	If uRotAuto == Nil .And. uOpcAuto == Nil
		oMBrowse := FWMBrowse():New()
		oMBrowse:SetCanSaveArea(.T.) 	
		oMBrowse:SetAlias( "AZR" ) 
		oMBrowse:SetDescription( STR0001 )  //"Papéis do Usuário"
		oMBrowse:Activate()

	Else
		
		FWMVCRotAuto( ModelDef(), "AZR", uOpcAuto, { { "AZRMASTER", uRotAuto } }, /*lSeek*/, .T. )
		
		If lMsErroAuto  
			MostraErro()
			lRetorno := .F. 
		Endif 
		
	EndIf

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do modelo de dados.

@sample		ModelDef()

@param		Nenhum
			
@return		oModel, Objeto, Modelo de Dados

@author		Anderson Silva
@since		08/01/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= Nil
	Local oStructAZR	:= FWFormStruct( 1, "AZR", /*bAvalCampo*/, /*lViewUsado*/ )

	oModel := MPFormModel():New( "CRMA210A", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( "AZRMASTER", /*cOwner*/, oStructAZR, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetDescription( STR0001 ) //"Papéis do Usuário"

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da interface.

@sample		ViewDef()

@param		Nenhum
			
@return		ExpO - Objeto do modelo da interface  

@author		Anderson Silva
@since		08/01/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil 
	Local oModel     := ModelDef()
	Local oStructAZR := FWFormStruct( 2, "AZR", /*bAvalCampo*/, /*lViewUsado*/ )

	oView := FWFormView():New()

	oView:SetModel( oModel, "AZRMASTER" )
	oView:AddField( "VIEW_AZR", oStructAZR, "AZRMASTER" ) 
	oView:CreateHorizontalBox( "ALL", 100 )
	oView:SetOwnerView( "VIEW_AZR", "ALL" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das rotinas.

@sample		MenuDef()

@param		Nenhum
			
@return		ExpA - Array de rotinas   

@author		Anderson Silva 
@since		08/01/2016
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := FwMVCMenu("CRMA210A")

Return ( aRotina )