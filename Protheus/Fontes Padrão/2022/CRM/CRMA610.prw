#include "CRMA610.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA610

Cadastro de Segmentos.

@sample	CRMA610( uRotAuto, nOpcAuto )

@param		uRotAuto - Array com os segmentos de negocio 
			nOpcAuto - Tipo de opera็ใo CRUD
			
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//-------------------------------------------------------------------
Function CRMA610(uRotAuto, nOpcAuto)

	Local oBrowse		:= Nil
	Local lRetorno		:= .T.
	
	Default uRotAuto	:= Nil
	Default nOpcAuto	:= Nil
	
	If Type("lMsErroAuto") != "L"
		Private lMsErroAuto := .T.
	EndIf
	
	If uRotAuto == Nil .And. nOpcAuto == Nil
		
		//Browse de Segmentos de Neg๓cio
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription( STR0002 )//"Segmentos"
		oBrowse:SetAlias( "AOV" )
		oBrowse:Activate()
		
	Else	
		FWMVCRotAuto( ModelDef(), "AOV", nOpcAuto, { { "AOVMASTER", uRotAuto } }, /*lSeek*/, .T. )			
	EndIf

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados do Segmento de Neg๓cios

@sample		ModelDef()

@param		Nenhum

@return		ExpO - Modelo de Dados

@author		Anderson Silva
@since		04/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStructAOV	:= FWFormStruct( 1, "AOV", /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel 	 	:= Nil
	Local oEvtDEFJUR    := Nil
	
	oModel := MPFormModel():New( "CRMA610", /*bPreValidacao*/, /*bPosVldMdl*/, /*bCommitMdl*/, /*bCancel*/ )
	
	oModel:AddFields( "AOVMASTER", /*cOwner*/, oStructAOV, /*bPreValidacao*/, /*bPosVldMdl*/, /*bCarga*/ )
	
	oModel:SetDescription( STR0004 ) //"Segmentos"
	
	If Len(GetApoInfo("CRM610EventDEFJUR.PRW")) > 0 // Eventos do m๓dulo SIGAPFS
		oEvtDEFJUR := CRM610EventDEFJUR():New()
		oModel:InstallEvent("LOCDEFJUR", /*cOwner*/, oEvtDEFJUR)
	EndIf

Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface do Nํveis do Agrupador Dinamico.

@sample		ViewDef()

@param		Nenhum

@return		ExpO - Interface do Agrupador de Registros

@author		Anderson Silva
@since		04/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oStructAOV	:= FWFormStruct( 2, "AOV", /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel   		:= FWLoadModel( "CRMA610" )
	Local oView	 		:= Nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( "VIEW_AOV", oStructAOV, "AOVMASTER" )
	
	oView:CreateHorizontalBox( "ALLCLIENT", 100 )
	
	oView:SetOwnerView( "VIEW_AOV", "ALLCLIENT" )

Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Monta estrutura de fun็๕es do Browse

@sample	MenuDef()

@param		Nenhum

@return		aRotina - Array de Rotinas

@author		Anderson Silva
@since		04/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0005 ACTION "PesqBrw" 		 OPERATION 1 ACCESS 0 //STR0005//"Pesquisar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CRMA610" OPERATION 2 ACCESS 0 //STR0006//"Visualizar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.CRMA610" OPERATION 3 ACCESS 0 //STR0007 //"Incluir"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.CRMA610" OPERATION 4 ACCESS 0 //STR0008//"Alterar"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.CRMA610" OPERATION 5 ACCESS 0 //STR0009//"Excluir"

Return( aRotina ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA610DscPai

Retorna a descri็ใo do pai.

@sample	CRMA610DscPai(cCodPai)

@param		cCodPai - codigo do segmento pai

@return	cDescri - descricao do segmento pai

@author	Anderson Silva
@since		04/07/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA610DscPai(cCodPai)

Local aArea 		:= GetArea()
Local aAreaAOV	:= AOV->(GetArea())
Local cDescri		:= ""

DbSelectArea("AOV")
AOV->(DbSelectArea(3))

If AOV->(DbSeek(xFilial("AOV")+cCodPai))
	cDescri := AOV->AOV_DESSEG
EndIf

RestArea(aAreaAOV)
RestArea(aArea) 	

Return( cDescri ) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIntegDef  บAutor  ณ Totvs Cascavel       บ Data ณ  27/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Mensagem ฺnica												บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Mensagem ฺnica                                            	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon ) 

Local aRet 		:= {}
Default lJSon 	:= .F.

If lJSon
	aRet := CRMI610O( xEnt, nTypeTrans, cTypeMessage)
Endif

Return aRet