#include "CRMA590.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA590 

Rotina que faz a chamada para o cadastro de Rotinas Perfil 360

@sample		CRMA590()

@param 		oModel - Model da rotina

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------

Function CRMA590(uRotAuto, nOpcAuto)

Local oBrowse

Private lMsErroAuto := .F.


Default uRotAuto := Nil
Default nOpcAuto := Nil

If uRotAuto == Nil .AND. nOpcAuto == Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('AOO')
	oBrowse:SetDescription(STR0001)//'Rotinas Perfil 360'
	oBrowse:Activate()
Else
	FWMVCRotAuto( ModelDef(), "AOO", nOpcAuto, { { "AOOMASTER", uRotAuto } }, /*lSeek*/, .T. )

  	If 	IsBlind() .AND. lMsErroAuto   
  		MostraErro() 
  	Endif 

EndIf

Return !( lMsErroAuto )


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef 

Funcao de chamada do menu.

@sample		MenuDef()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.CRMA590'	OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.CRMA590' 	OPERATION 3 ACCESS 0//'Incluir'
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.CRMA590'	OPERATION 4 ACCESS 0//'Alterar'
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.CRMA590'	OPERATION 5 ACCESS 0//'Excluir'

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef 

Funcao de chamada do menu.

@sample		ModelDef()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructAOO := FWFormStruct( 1, 'AOO', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel 	 := Nil

oModel := MPFormModel():New('CRMA590', /*bPreValidacao*/, {|oModel| CA590TOK(oModel)} ,/*bComiit*/, /*bCancel*/ )
oModel:AddFields( 'AOOMASTER', /*cOwner*/, oStructAOO, /*bPreValidaadmicao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({"AOO_FILIAL","AOO_CODIGO"})  

oStructAOO:SetProperty("AOO_ALIAS",MODEL_FIELD_OBRIGAT,.F.)

oModel:SetDescription( STR0006 )//'Rotinas do Perfil 360'
oModel:GetModel( 'AOOMASTER' ):SetDescription( STR0007 )//'Rotinas'

Return oModel


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef 

Funcao de chamada do menu.

@sample		ViewDef()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel( 'CRMA590' )
Local oStructAOO := FWFormStruct( 2, 'AOO' )
Local oView      := Nil
Local cCampos    := {}

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_AOO', oStructAOO, 'AOOMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_AOO', 'TELA' )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CA590TOK 

Validações da rotina

@sample		CA590TOK()

@param 		oModel - Model da rotina

@return		.T. - Gravação da rotina

@author		Aline Sebrian Damasceno
@since		11/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CA590TOK(oModel)
Local lRet := .T.
Local cQuery := ''
Local lInclui		:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local lAltera		:= oModel:GetOperation() == MODEL_OPERATION_UPDATE 

Local oModelAOO := oModel:GetModel("AOOMASTER")
Local cRotina   := Upper(oModelAOO:GetValue("AOO_ROTINA"))
Local cCodigo   := Upper(oModelAOO:GetValue("AOO_CODIGO"))
Local cTpFun    := oModelAOO:GetValue("AOO_TPFUN")

If (lInclui .Or. lAltera)  
	cQuery := " SELECT * FROM  " +RetSQLName("AOO") +" AOO "
	cQuery += " Where AOO_FILIAL   =   '"+xFilial("AOO")+"'
	cQuery += "   And AOO_ROTINA   =   '"+ Alltrim(cRotina) +"'"
	cQuery += "   And AOO_TPFUN    =   '"+ AllTrim(cTpFun) +"'"
	cQuery += "   And D_E_L_E_T_   =   '' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"QRYTRB",.F.,.T.)
	
	If  !(QRYTRB->(Eof())) .AND. QRYTRB->AOO_CODIGO <> cCodigo  
		Help('',1,'CRM590VUS',,STR0008,1) 
		lRet := .F.
	EndIf
	
	QRYTRB->(dbCloseArea())
EndIf

Return lRet