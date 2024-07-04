#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'VEIA142.CH'

CLASS VEIA142EVDF FROM FWModelEvent

	Data aCpoAlt

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD VldActivate()

ENDCLASS



METHOD New() CLASS VEIA142EVDF

	::aCpoAlt   := {}

RETURN .T.


METHOD FieldPreVld(oModel, cModelID, cAction, cId, xValue) CLASS VEIA142EVDF

	Local nX      := 0
	Local nSeq    := 0
	Local nCodReq := 0
	Local nPosCpo := 0
	
	If cAction == "SETVALUE" .and. oModel:GetOperation() == 4
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

METHOD InTTS(oModel, cModelId) CLASS VEIA142EVDF

	Local nPos 		:= 0
	Local oVJS 		:= FWLoadModel( 'VEIA143' )
	Local oVV1 		:= FWLoadModel( 'VEIA070' )
	Local cCodMar 	:= FMX_RETMAR(GetNewPar("MV_MIL0006",""))
	Local cCriaMaq 	:= ""

	cCriaMaq := VA140005G_GravaMaquina( oModel:GetValue( "VQ0MASTER", "VQ0_CHAINT"),;
										oModel:GetValue( "VQ0MASTER", "VQ0_MODVEI"),;
										oModel:GetValue( "VQ0MASTER", "VQ0_CHASSI"),;
										oModel:GetValue( "VQ0MASTER", "VQ0_FILENT"),;
										oVV1,;
										oModel:GetValue( "VQ0MASTER", "VQ0_CORVEI"),;
										oModel:GetValue( "VQ0MASTER", "VQ0_SEGMOD"),;
										cCodMar )

	If !Empty(cCriaMaq)
		RecLock("VQ0", .f.)
			VQ0->VQ0_CHAINT := cCriaMaq
		MsUnLock()
	EndIf

	For nPos := 1 to Len(self:aCpoAlt)

		If self:aCpoAlt[nPos,2] <> self:aCpoAlt[nPos,3]

			oVJS:SetOperation( MODEL_OPERATION_INSERT )
			lRet := oVJS:Activate()

			if lRet

				oVJS:SetValue( "VJSMASTER", "VJS_CODVQ0", oModel:GetValue("VQ0MASTER","VQ0_CODIGO") )
				oVJS:SetValue( "VJSMASTER", "VJS_DATALT", dDataBase )
				oVJS:SetValue( "VJSMASTER", "VJS_CPOALT", self:aCpoAlt[nPos,1] )
				oVJS:SetValue( "VJSMASTER", "VJS_CONANT", self:aCpoAlt[nPos,2] )
				oVJS:SetValue( "VJSMASTER", "VJS_CONNOV", self:aCpoAlt[nPos,3] )

				If ( lRet := oVJS:VldData() )
					if ( lRet := oVJS:CommitData())
					Else
						Help("",1,"COMMITVJS",,oVJS:GetErrorMessage()[6],1,0)
					EndIf
				Else
					Help("",1,"VALIDVJS",,oVJS:GetErrorMessage()[6] + STR0041 + oVJS:GetErrorMessage()[2],1,0) //"Campo: "
				EndIf
				
				oVJS:DeActivate()

			Else
				Help("",1,"ACTIVEVJS",, STR0029 ,1,0) //"Não foi possivel ativar o modelo de inclusão da tabela"
			EndIf

		EndIf

	Next

	self:aCpoAlt := aSize(self:aCpoAlt,0)

	FreeObj(oVJS)
	FreeObj(oVV1)

RETURN .t. 


METHOD ModelPosVld(oModel, cModelId) CLASS VEIA142EVDF

	Local cVQ0Cod := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		cVQ0Cod := FM_SQL("SELECT VQ0_CODIGO FROM " + RetSQLName("VQ0") + " WHERE VQ0_CODIGO = '" +oModel:GetValue("VQ0MASTER","VQ0_CODIGO")+ "' AND VQ0_FILIAL = '"+xFilial("VQ0")+"' AND D_E_L_E_T_ = ' '")
		
		If !Empty(cVQ0Cod)
			MsgStop(STR0044,STR0024) //Código do pedido já existe na base de dados, necessário consultar o controle de numeração. / Atenção
			Return .f.
		EndIf
	EndIf

RETURN .t.

 METHOD VldActivate(oModel, cModelId) CLASS VEIA142EVDF	
	Local nOperation := oModel:GetOperation()	
	Local aRet := {}

	If nOperation == 5
		aRet:= FGX_VEIMOVS( VQ0->VQ0_CHASSI , "E" , "0" )
		If Len(aRet) > 0			
			FMX_HELP("VEIA142EVDFERR01",STR0045,STR0046)//("Veiculo ja possui movimentação de Entrada. Impossivel continuar. / Atencao")	 	
			Return .f.		
		EndIf
	EndIf

RETURN .T.




