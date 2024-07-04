#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

/*/{Protheus.doc} MATA020GUA
Cadastro de fornecedor localizado para RUSSIA.

O fonte cont�m browse, menu, model e view propria, todos herdados do MATA020. 
Qualquer regra que se aplique somente para a RUSSIA deve ser definida aqui.

As valida��es e integra��es realizadas ap�s/durante a grava��o est�o definidas nos eventos do modelo, 
na classe MATA020EVCOL.

@type function
 
@author Jos� Eul�lio
@since 22/09/2017
@version P12.1.17
 
/*/
Function MATA020RUS()
Local oBrowse		AS OBJECT

Private cCadastro	AS CHARACTER
Private aRotina		AS ARRAY

aRotina		:= {}
cCadastro	:= OemtoAnsi(STR0006)  //"Supplyers"

oBrowse		:= BrowseDef()
oBrowse:Activate()

Return Nil


Static Function BrowseDef()
Local oBrowse		AS OBJECT
oBrowse		:= FWLoadBrw(SOURCEFATHER)
Return oBrowse

Static Function ModelDef()
Local oModel	:= FWLoadModel(SOURCEFATHER)
Local oEvent	:= MATA020EVRUS():New()
Local oModBco	:= oModel:GetModel("BANCOS")
	
	oModBco:GetStruct():SetProperty("FIL_TIPO",MODEL_FIELD_VALID,{|oModBco| Mt020FilTp(oModBco) .And. Pertence('12')})
	
Return oModel

Static Function ViewDef()
Local oView			:= FWLoadView("MATA020")
Local cCamposRus	:= "FIL_BANCO|FIL_CONTA|FIL_ACNAME|FIL_MOEDA|FIL_AGENCI|FIL_BKNAME|FIL_CORRAC|FIL_CITY|FIL_SWIFT|FIL_NMECOR|FIL_REASON|FIL_FOREIG|FIL_CLOSED|FIL_TIPO"
Local nPosBanco		:= 0
Local nX			:= 0

	//Envia os campos para a montagem da View de Bancos
	For nX := 1 To Len(oView:aUserButtons)
		nPosBanco := aScan(oView:aUserButtons[nX],STR0068)	
		If nPosBanco > 0
			oView:aUserButtons[nX][3] := {|| A020Bancos(oView,cCamposRus) }
			Exit
		EndIf
	Next nX
oView:AddUserButton(STR0081,'AddrButton', {|| CRMA680RUS("SA2",xFilial("SA2")+ SA2->A2_COD + SA2->A2_LOJA,.F.,STR0081+ " " + SA2->A2_NOME)}, /*[cToolTip]*/,K_CTRL_A) // Other Actions - address button in viewdef
Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef(SOURCEFATHER)	

aAdd(aRotina,{STR0081, "CRMA680RUS('SA2',xFilial('SA2')+ SA2->A2_COD + SA2->A2_LOJA,.F.,"+"('"+STR0081 +"' + ' ' + SA2->A2_NOME))", 0, 2})	

Return aRotina

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Before
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit
antes da grava��o de cada submodelo (field ou cada linha de uma grid)

@type metodo
 
@author Jos� Eul�lio
@since 25/09/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------
Function Mt020FilTp(oModBco)
Local nX		:= 0
Local nLinha	:= oModBco:GetLine()
Local lRet		:= .T.

If oModBco:GetValue("FIL_TIPO") == "1"

	For nX := 1 to oModBco:Length()
		oModBco:GoLine(nX)
		If nX <> nLinha
			If oModBco:GetValue("FIL_TIPO") == "1"
				Help(" ",1,"MA020MAIN")//This supplier has already a Main Account!
				lRet := .F.
			EndIf
		EndIf
	Next nX
	
	oModBco:GoLine(nLinha)

EndIf

Return lRet