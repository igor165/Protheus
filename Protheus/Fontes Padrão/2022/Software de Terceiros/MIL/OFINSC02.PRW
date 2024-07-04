////////////////
// Versao 003 //
////////////////

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFINSC02.CH"

/*/{Protheus.doc} OFINSC02

Cadastro do Registro de Cliente para o Scania Assistance

@author Rubens
@since 15/09/2015
@version 1.0

/*/
Function OFINSC02()

Local oBrowse := Nil
Private nOpcTrans := .f.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VGJ')
oBrowse:SetDescription( STR0001 ) // "Cadastro de Cliente - Scania Assistance"

// Adiciona legendas
oBrowse:AddLegend( "VGJ_ENVIAD='1'", "BLUE"   , STR0002 ) // "Enviado"
oBrowse:AddLegend( "VGJ_ENVIAD='0'", "GREEN"  , STR0003 ) // "Não Enviado"

oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Definição do modelo de dados (MVC)

@author Rubens
@since 07/09/2015
@version 1.0
/*/
Static Function ModelDef()

Local oStruct := FWFormStruct(1,"VGJ")

Local oModel

oModel := MPFormModel():New( "OFINSC02", /* bPre */, /* bPost */ , /* bCommit */ )
oModel:AddFields("VGJMASTER", /* cOwner */ , oStruct)
oModel:SetDescription(STR0004) // "Modelo de dados do Registro de Scania Assistance"
oModel:GetModel("VGJMASTER"):SetDescription(STR0005) // "Dados do Registro de Scania Assistance"

oModel:SetVldActivate( { |oModel| OFNSC02PRE( oModel ) } )

Return oModel

/*/{Protheus.doc} OFNSC02PRE

Valida se o registro pode ser alterado ou excluido 

@author Rubens
@since 18/09/2015
@version 1.0
@param oModel, objeto, Modelo do MVC
@return lRet, Indica se o registro pode ser excluido ou alterado
/*/
Static Function OFNSC02PRE(oModel) 

Local lRet := .t.
Local nOper

If VGJ->VGJ_ENVIAD == "1"
	nOper := oModel:GetOperation()
	If nOper == MODEL_OPERATION_DELETE
		lRet := .F.
		Help(" ",1,"NODELETA")
	EndIf
	If nOper == MODEL_OPERATION_UPDATE
		lRet := .f.
		Help( ,1, 'HELP',,STR0020, 1, 0 ) // "Registro já enviado."
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} ViewDef
Definição da Visão (MVC)

@author Rubens
@since 07/09/2015
@version 1.0
/*/
Static Function ViewDef()

Local oModel:= FWLoadModel("OFINSC02")
Local oStruct := FWFormStruct(2,"VGJ")
//Local oView

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_VGJ",oStruct,"VGJMASTER")

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_VGJ','TELA')

Return oView

/*/{Protheus.doc} OFNSC02TRA

Transmite registro para a Scania

@author Rubens
@since 07/09/2015
@version 1.0
/*/
Function OFNSC02TRA()

Local cTitulo := STR0006 // "Transmissão do Registro"
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,""},{.T.,STR0007},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

If VGJ->VGJ_ENVIAD == "1"
	Help( ,1, 'HELP',,STR0020, 1, 0 ) // "Registro já enviado."
	Return 
EndIf

oExecView := FWViewExec():New()
oExecView:SetTitle(cTitulo)
oExecView:SetSource("OFINSC02")
oExecView:SetOperation(MODEL_OPERATION_VIEW)
oExecView:SetCancel( { |oView| OFNSC02WEBS(oView) } )
oExecView:SetButtons( aButtons )
oExecView:OpenView( .t. )

Return

/*/{Protheus.doc} OFNSC02VLD

Validação da digitação dos campos da Enchoice

@author Rubens
@since 15/09/2015
@version 1.0
@param cReadVar, character, Nome do campo que está sendo alterado pelo cliente
@return bool, Indica se a validação esta correta
/*/
Function OFNSC02VLD(cReadVar)

Local oModel := FwModelActive()
Local lFound := .f.

If cReadVar == "M->VGJ_CLIENT" .or. cReadVar == "M->VGJ_LOJA"
	If Empty(&(cReadVar ))
		oModel:SetValue( 'VGJMASTER', 'VGJ_NOME', '' )
		Return .t.
	EndIf

	SA1->(dbSetOrder(1))
	lFound := SA1->(MsSeek(xFilial("SA1")+M->VGJ_CLIENT+AllTrim(M->VGJ_LOJA)))
	If !lFound
		If cReadVar == "M->VGJ_CLIENT"
			oModel:SetValue( 'VGJMASTER', 'VGJ_LOJA', Space(Len(M->VGJ_LOJA)) )
		EndIf
		oModel:SetValue( 'VGJMASTER', 'VGJ_NOME', '' )
		HELP(" ",1,"EXISTCLI")
		Return .f.
	EndIf
	If cReadVar == "M->VGJ_LOJA"
		oModel:SetValue( 'VGJMASTER', 'VGJ_NOME'  , SA1->A1_NOME )
		oModel:SetValue( 'VGJMASTER', 'VGJ_PESSO' , SA1->A1_PESSOA )
		oModel:SetValue( 'VGJMASTER', 'VGJ_CUSTID', SA1->A1_CGC )
		M->VGJ_PESSO := SA1->A1_PESSOA
	EndIf
EndIf

Return .t.

/*/{Protheus.doc} OFNSC02WEBS

Transmite o registro ao WebService da Fábrica

@author Rubens
@since 15/09/2015
@version 1.0
@param oView, objeto, (Descrição do parâmetro)

/*/
Static Function OFNSC02WEBS(oView)

Local oWS
Local oAuxModel
Local oModel
Local lRet := .t.

If !MsgYesNo(STR0008)
	Return .f.
EndIf

lProcessado := .f.
oWS := WSMIL_ScaniaAssist():New()
//oWS:SetDebug()

MsgRun(STR0009 + "..." , STR0010, ;
	{ || lProcessado := oWS:SetGOPDealer( Val(VGJ->VGJ_CUSTID),;
		Val(VGJ->VGJ_DEALER),;
		IIF( VGJ->VGJ_HOMEDE == "0" , "N" , "Y" ),;
		VGJ->VGJ_VALGOP,;
		FormatDate( VGJ->VGJ_DATVAL ),;
		IIf( VGJ->(FieldPos("VGJ_HORATE")) <> 0 , VGJ->VGJ_HORATE , NIL ) ) } )

If !lProcessado
	oWS:ExibeErro("SetGOPDealer")
	Return .f.
EndIf

If oWS:oWSSetGOPDealerResult:oWSStatus:Value <> "SUCCESS"
	MsgStop(oWS:oWSSetGOPDealerResult:cMessage)
	Return .f.
EndIf

oAuxModel := FWLoadModel( 'OFINSC02' )
oAuxModel:SetOperation( MODEL_OPERATION_UPDATE )
oAuxModel:Activate()
oAuxModel:SetValue("VGJMASTER" , "VGJ_ENVIAD" , "1")
oAuxModel:SetValue("VGJMASTER" , "VGJ_DATENV" , dDataBase)
oAuxModel:SetValue("VGJMASTER" , "VGJ_USUENV" , UsrRetName(RetCodUsr()) )
If oAuxModel:VldData()
	oAuxModel:CommitData()
Else
	aErro := oAuxModel:GetErrorMessage()
	lRet := .F.
EndIf
oAuxModel:DeActivate()

Return lRet


Static Function FormatDate(dAuxData)
Return (Str(Year(dAuxData),4) + "-" + StrZero(Month(dAuxData),2) + "-" + StrZero(Day(dAuxData),2))


/*/{Protheus.doc} OFNSC02GOP

Consulta o valor padrão de garantia de pagamento

@author Rubens
@since 15/09/2015
@version 1.0
@return nValor, Valor padrão de garantia de pagamento

/*/
Function OFNSC02GOP()

Local oWS

If !MsgYesNo(STR0011) // "Confirma consulta do valor padrão"
	Return .f.
EndIf

oWS := WSMIL_ScaniaAssist():New()

lProcessado	:= .f.
MsgRun(STR0012 , STR0013, {|| lProcessado := oWS:GetGOP() } ) // "Consulta Valor GOP"
If !lProcessado
	oWS:ExibeErro("GetGOP")
	Return .f.
EndIf

MsgInfo(STR0014 + ": " + Transform(oWS:nGetGOPResult,"@E 999,999,999.99")) // Valor GOP

Return .t.


/*/{Protheus.doc} MenuDef
Definição do menu da Rotina

@author Rubens
@since 24/01/2014
@version 1.0

/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0015 ACTION 'VIEWDEF.OFINSC02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0016 ACTION 'VIEWDEF.OFINSC02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"   
ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.OFINSC02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"   
ADD OPTION aRotina TITLE STR0018 ACTION 'VIEWDEF.OFINSC02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"   
ADD OPTION aRotina TITLE STR0019 ACTION 'OFNSC02TRA'       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // "Transmitir"
ADD OPTION aRotina TITLE STR0014 ACTION 'OFNSC02GOP'       OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Valor de Garantia"

Return aRotina