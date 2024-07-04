#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "VEIA240.CH" // mesmo CH do VEIA240

CLASS VEIA241EVDEF FROM FWModelEvent

	DATA lDispEMail

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD GridLinePreVld()
	METHOD ModelPreVld()
	METHOD ModelPosVld()
	METHOD DeActivate()

ENDCLASS


METHOD New() CLASS VEIA241EVDEF

	::lDispEMail := .f. // Não Disparar E-Mail

RETURN .T.


METHOD Activate(oModel, lCopy) CLASS VEIA241EVDEF
	
	::lDispEMail := .f. // Não Disparar E-Mail

RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA241EVDEF

	Local lRet := .t.
	Local nX := 0
	Local oView := FWViewActive()

	If cModelId == "VN2DETAIL" 
	
		If cAction == "SETVALUE"

			oSubModel:GoLine(nLine)

			If cId == "VN2_STATUS"

				If xCurrentValue == "0" .and. xValue == "1" .and. !oSubModel:IsInserted(nLine)
					Help("",1,"VN2_STATUS",,STR0037,1,0) // Não é possivel alterar o status para Ativado uma vez que o mesmo já foi atualizado para Desativado
					lRet := .f.
				Else
					oSubModel:LoadValue( "VN2_DATALT" , FGX_Timestamp() ) // Grava novamente se mudar o STATUS
				EndIf
				
			ElseIf cId == "VN2_DATINI"
				If xValue >= dDataBase
					For nX := 1 to oSubModel:Length()
						oSubModel:GoLine(nX)
						If nLine <> nX .and. xValue == oSubModel:GetValue("VN2_DATINI") .and. oSubModel:GetValue("VN2_STATUS") == "1"
							If MsgYesNo(STR0038,STR0025) // Existe um Custo do Pacote Ativo na mesma Data informada. Deseja desativar o registro anterior mantendo a nova digitação? / Atenção
								oSubModel:LoadValue( "VN2_STATUS" , "0" ) // 0=Desativado
								oSubModel:LoadValue( "VN2_DATALT" , FGX_Timestamp() ) // Grava novamente se mudar o STATUS
								oSubModel:GoLine(nLine)
								oView:Refresh()
							Else
								oSubModel:GoLine(nLine)
								oSubModel:ClearField(cId , nLine, .f.)
								lRet := .f.
							EndIf
							Exit
						EndIf
					Next
				EndIf

			EndIf

		ElseIf cAction == "CANSETVALUE"

			If (cId == "VN2_VALPAC" .or. cId == "VN2_FREPAC" .or. cId == "VN2_DATINI") .and. !oSubModel:IsInserted(nLine)

				lRet := .f.

			EndIf

		EndIf
		
	EndIf

RETURN lRet


METHOD ModelPreVld(oModel, cModelId) CLASS VEIA241EVDEF
	Local nCntFor   := 0
	Local aOpcs     := {}
	Local cOpcs     := ""
	Local oModelVN0 := oModel:GetModel("VN0MASTER")
	Local oModelVN1 := oModel:GetModel("VN1DETAIL")
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If cModelId == "VN0MASTER"
			For nCntFor := 1 to oModelVN1:Length()
				oModelVN1:GoLine(nCntFor)
				If !oModelVN1:IsDeleted(nCntFor)
					aAdd(aOpcs,Alltrim(VC1400011_CodigoOpcional(oModelVN1:GetValue("VN1_CODVQD"))))
				EndIf
			Next
			aSort(aOpcs)
			For nCntFor := 1 to len(aOpcs)
				cOpcs += aOpcs[nCntFor]
			Next
			oModelVN0:SetValue("VN0_CHVOPC", cOpcs )
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE
				oModelVN0:LoadValue( "VN0_DATALT" , FGX_Timestamp() ) // Grava Controle de Alteração para APP
			EndIf
		EndIf
	EndIf
RETURN .T.


METHOD ModelPosVld(oModel, cID) CLASS VEIA241EVDEF
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If !IsInCallStack("VEIA140") .and. !IsInCallStack("VEIA244") // Não é importação CGPOLL e Não chamado pela rotina de Replica de Custo Geral
			::lDispEMail := .t. // Disparar E-mail
		EndIf
	EndIf
RETURN .T.


METHOD DeActivate(oModel) CLASS VEIA241EVDEF
	If ::lDispEMail // Disparar E-mail
		VA2400171_EnviarEmail(.t.,.f.) // Enviar E-mail referente a alteração na Lista de Preços dos Pacotes
	EndIf
RETURN .T.