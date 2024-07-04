// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º   3    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "VEIA260.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWEditPanel.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ VEIA260 ³ Autor ³Jose Luis Silveira Filho³ Data ³ 17/01/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Endossos VQF                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIA260()

Local oBrowse

Private oModelSeg

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VQF')
oBrowse:SetDescription( STR0001 )//"Cadastro de Endossos"
oBrowse:Activate()

Return .T.

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA260')

Return aRotina

Static Function ModelDef()
Local oStrVQF := FWFormStruct(1,"VQF")

oModelSeg := MPFormModel():New("VEIA260", /* bPre */, {|oModelSeg| VA260021_TudoOk(oModelSeg) } /* bPost */ , /* bCommit */ , /* bCancel */ )

oModelSeg:AddFields("VQFMASTER",/*cOwner*/ , oStrVQF)
oModelSeg:GetModel("VQFMASTER"):SetDescription(STR0001) // Cadastro de Endossos
oModelSeg:SetPrimaryKey( { "VQF_FILIAL", "VQF_CODIGO" } )
oModelSeg:SetDescription(STR0001) // Cadastro de Endossos

oModelSeg:InstallEvent("VEIA260EVDEF", /*cOwner*/, VEIA260EVDEF():New() )

oModelSeg:AddRules( 'VQFMASTER', 'VQF_LOJCLI', 'VQFMASTER', 'VQF_CODCLI', 3)

Return oModelSeg


Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVQF:= FWFormStruct(2, "VQF")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VQF', 100)
	oView:AddField('VIEW_VQF', oStrVQF, 'VQFMASTER')
	oView:EnableTitleView('VIEW_VQF', STR0001 )//Cadastro de Endossos
	oView:SetOwnerView('VIEW_VQF','VQF')

Return oView



Function VA260011_ValidacaoCampos(cAlias,oSubModel,cId,xValue)
Local lRet   := .t.
Local nRecNo := 0
Local oSqlHelp := DMS_SqlHelper():New()

If cId $ "VQF_CODSEG"
	M->VQF_CODSEG := xValue
	If !Empty(M->VQF_CODSEG)
		cCliente := FM_SQL("SELECT "+oSqlHelp:Concat({'VQ8_CODCLI', 'VQ8_LOJCLI'})+" AS CLIENTE FROM "+RetSQLName("VQ8")+" WHERE VQ8_FILIAL='"+xFilial("VQ8")+"' AND VQ8_CODIGO='"+M->VQF_CODSEG+"' AND D_E_L_E_T_=' '")
		If len(cCliente) > 0 // Existe Cliente
			oSubModel:LoadValue("VQF_CODCLI",( Substr(cCliente,1,6)))
			oSubModel:LoadValue("VQF_LOJCLI",( Substr(cCliente,7,2)))
		EndIf
	EndIf
Endif

Return lRet

Function VA260021_TudoOk(oModel)
Local lRet   := .t.
Local cCod   := ""
Local cLoj   := ""

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	lRet := .f.
	cCod := oModel:GetValue("VQFMASTER","VQF_CODCLI")
	cLoj := oModel:GetValue("VQFMASTER","VQF_LOJCLI")
	If !Empty( cCod + cLoj )
		lRet := .t.
	Else
		Help(NIL, NIL, "VA260021_TudoOk", NIL, STR0002 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003}) // Código/Loja do Cliente inválido! / Informe um Código/Loja de Cliente válido.
	EndIf
	if oModel:GetValue("VQFMASTER","VQF_DTUSOE") <> ctod("  /  /  ")
		Help(NIL, NIL, "VA260021_TudoOk", NIL, STR0004 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) // Alterar Endosso / Impossivel ALTERAR o Endosso, ja existe NF gerada para uma ou mais parcelas.
		lRet := .f.
	EndIf
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	if oModel:GetValue("VQFMASTER","VQF_DTUSOE") <> ctod("  /  /  ")
		Help(NIL, NIL, "VA260021_TudoOk", NIL, STR0005 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007}) // Excluir Endosso / Impossivel EXCLUIR o Endosso, ja existe NF gerada para uma ou mais parcelas.
		lRet := .f.
	EndIf
EndIf

Return lRet
