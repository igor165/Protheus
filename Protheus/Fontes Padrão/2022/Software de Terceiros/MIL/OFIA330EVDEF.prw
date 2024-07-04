#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA330.CH"

CLASS OFIA330EVDEF FROM FWModelEvent

	Data aCpoAlt

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD InTTS()

ENDCLASS


METHOD New() CLASS OFIA330EVDEF

	::aCpoAlt   := {}

RETURN .T.


METHOD FieldPreVld(oModel, cModelID, cAction, cId, xValue) CLASS OFIA330EVDEF

	Local nPosCpo := 0
	
	If cAction == "SETVALUE"
		if oModel:GetValue(cId) <> xValue

			cContAnt := oModel:GetValue(cId)
			cContNov := xValue

			cTpCpo := GeTSX3Cache(cId,"X3_TIPO")

			If cTpCpo == "N"
				cContAnt := cValToChar(cContAnt)
				cContNov := cValToChar(cContNov)
			ElseIf cTpCpo == "D"
				cContAnt := DtoC(cContAnt)
				cContNov := DtoC(cContNov)
			EndIf
			
			nPosCpo := aScan(self:aCpoAlt,{|x| x[1] == cId})
			If nPosCpo == 0
				aAdd(self:aCpoAlt,{cId,cContAnt,cContNov})
			Else
				self:aCpoAlt[nPosCpo,3] := cContNov
			EndIf

		EndIf
	EndIf

RETURN .t.

METHOD InTTS(oModel, cModelId) CLASS OFIA330EVDEF

	Local nPos := 0
	Local oVM2 := FWLoadModel( 'OFIA191' )

	nPos := aScan(self:aCpoAlt,{|x| x[1] == "VM7_STATUS"})

	If nPos > 0

		If self:aCpoAlt[nPos,2] <> self:aCpoAlt[nPos,3]

			oVM2:SetOperation( MODEL_OPERATION_INSERT )
			lRet := oVM2:Activate()

			if lRet

				oVM2:SetValue( "VM2MASTER", "VM2_CODIGO", oModel:GetValue("VM7MASTER","VM7_CODIGO") )
				oVM2:SetValue( "VM2MASTER", "VM2_TIPO"  , "4" )
				oVM2:SetValue( "VM2MASTER", "VM2_STATUS", self:aCpoAlt[nPos,3] )
				oVM2:SetValue( "VM2MASTER", "VM2_USRSTA", __cUserID )
				oVM2:SetValue( "VM2MASTER", "VM2_DATSTA", dDataBase )
				oVM2:SetValue( "VM2MASTER", "VM2_HORSTA", Time() )

				If ( lRet := oVM2:VldData() )
					if ( lRet := oVM2:CommitData())
					Else
						Help("",1,"COMMITVM2",,STR0003,1,0) // Não foi possível incluir o(s) registro(s)
					EndIf
				Else
					Help("",1,"VALIDVM2",,oVM2:GetErrorMessage()[6] + " "+STR0004+": " + oVM2:GetErrorMessage()[2],1,0) // Campo
				EndIf

				oVM2:DeActivate()

			Else
				Help("",1,"ACTIVEVM2",,STR0005,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM2
			EndIf

		EndIf

	EndIf

	self:aCpoAlt := aSize(self:aCpoAlt,0)

	FreeObj(oVM2)

RETURN .t.