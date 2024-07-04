#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA630.CH"

#DEFINE NTAM_COD_INT  2

/*/------------------------------------------------------------------------------
{Protheus.doc} CRMA630
Rotina que monta tela para seleção dos agrupadores.
@sample		CRMA580E()
@param		nil
@return		ExpC - String dos agruapdores selecionados.
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
------------------------------------------------------------------------------/*/

Function CRMA630()

Local oModel		:= Nil
Local oView			:= Nil
Local oExecView		:= Nil
Local aButtons		:= {}
Local cRetorno      := ""

DbSelectArea("AOL")
DbSetOrder(1)

aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
			  {.F.,Nil},{.T.,"OK"},{.T.,"Fechar"},{.F.,Nil}		,;
			  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
				
oModel:= FWLoadModel("CRMA630A")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

//nao permite alterações, é tela de seleção
oModel:GetModel('AOLDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('AOLDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('AOLDETAIL'):SetNoUpdateLine(.F.)

oModel:bCommit := {|oModel| (cRetorno := CRM630Selec(oModel),.T.) }
oModel:Activate()
								
oView := FWLoadView("CRMA630A")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_UPDATE)
					
//apresenta a tela de seleção dos agrupadores
oExecView := FWViewExec():New()
oExecView:SetTitle(STR0001) //"Agrupadores para Faturamento"
oExecView:SetView(oView)
oExecView:SetModal(.F.)
oExecView:SetOperation(MODEL_OPERATION_VIEW)
oExecView:SetButtons(aButtons)
oExecView:SetSize(300,300)
oExecView:OpenView(.F.)

Return(cRetorno)

/*/-----------------------------------------------------------------------------
{Protheus.doc} CRM630Selec
Retorna os agrupador selecionado pelo usuario.
@sample		CRM580ERNvl()
@param		Nenhum
@return		ExpC - String dos Agrupadores Selecionados.
@author		SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
-----------------------------------------------------------------------------/*/

Static Function CRM630Selec(oModel)

//Local oModel			:= FwModelActive()
Local oMdlAOLGrid		:= oModel:GetModel("AOLDETAIL")
Local nX				:= 0
Local cReturn			:= ""

//Monta a string separada por ; para compor 
//o parametro MV_PAR16 do pergunte do faturamento 
For nX := 1 To oMdlAOLGrid:Length()
	
	oMdlAOLGrid:GoLine(nX)
	
	If oMdlAOLGrid:GetValue("AOL_MARK")
		cReturn += oMdlAOLGrid:GetValue("AOL_CODAGR")
		cReturn += ";"
	EndIf
	
Next nX

If !Empty(cReturn)
	cReturn := Left(cReturn,Len(cReturn)-1)
EndIf

Return(cReturn)
