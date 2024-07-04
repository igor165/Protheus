#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CT030GRA

Ponto de Entrada para alterar campos do cadastro do participante.

@author  Allan Constantino Bonfim
@since   03/02/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------  
User Function APDGRV01()

	Local _aArea	:= GetArea()
	Local _aAreaRD0
	Local _nRecRD0	:= RD0->(Recno())
	Local _cCodApr	:= ""
	Local _aParam	:= PARAMIXB //1=RD0_CODIGO, 2=SRA, 3=SRA recno, 4=Filial+ matricula SRA, nOpcRel, I=Inclusao, A=Alteracao

	
	If _nRecRD0 > 0

		//Comentado devido ao aprovador do funcionário estar desatualizado no cadastro de funcionários.
		/*
		_aAreaRD0 := GetArea("RD0")
	
		DbSelectArea("RD0")
		RD0->(DbSetOrder(6)) //RD0_FILIAL, RD0_CIC, RD0_CODIGO
		DbGoto(_nRecRD0)

		If !Empty(SRA->RA_ZZSUPIM)
			DbSelectArea("RBA")
			RBA->(DbSetOrder(1)) //RBA_FILIAL, RBA_CODRES
			If RBA->(DbSeek(FwxFilial("RBA")+SRA->RA_ZZSUPIM))
				If RD0->(DbSeek(FwxFilial("RD0")+RBA->RBA_ZZCIC))
					_cCodApr := RD0->RD0_CODIGO
				EndIf	
			EndIf
		EndIf
	
		RestArea(_aAreaRD0)
		*/

		DbSelectArea("RD0")
		RD0->(DbSetOrder(1)) //RD0_FILIAL, RD0_CODIGO
		DbGoto(_nRecRD0)

		//If _aParam[7] == "I" //I=Inclusao, A=Alteracao
			Reclock("RD0", .F.)

				If Empty(RD0->RD0_XADNAP)
					RD0->RD0_XADNAP := "N"
				EndIf

				If Empty(RD0->RD0_XVINAP)
					RD0->RD0_XVINAP	:= "N"	
				EndIf

				If Empty(RD0->RD0_XVNNAP)
					RD0->RD0_XVNNAP	:= "N"	
				EndIf

				If Empty(RD0->RD0_XRNAPR)
					RD0->RD0_XRNAPR	:= "N"	
				EndIf

				If Empty(RD0->RD0_XSPTER)
					RD0->RD0_XSPTER	:= "N"	
				EndIf

				If Empty(RD0->RD0_XNAPRO)
					RD0->RD0_XNAPRO	:= "N"	
				EndIf

				If Empty(RD0->RD0_XVIP)
					RD0->RD0_XVIP	:= "N"	
				EndIf
				
				If Empty(RD0->RD0_XAPADT)
					RD0->RD0_XAPADT	:= "N"	
				EndIf

				If Empty(RD0->RD0_XAPCNF)
					RD0->RD0_XAPCNF	:= "N"	
				EndIf

				If Empty(RD0->RD0_XAPINT)
					RD0->RD0_XAPINT	:= "N"	
				EndIf
				
				If Empty(RD0->RD0_XAPNAC)	
					RD0->RD0_XAPNAC	:= "N"	
				EndIf

				If Empty(RD0->RD0_XAPREE)
					RD0->RD0_XAPREE	:= "N"	
				EndIf

				If Empty(RD0->RD0_XALATU)
					RD0->RD0_XALATU	:= "N"
				EndIf

			RD0->(MsUnlock())
		//EndIf

		//Comentado devido ao aprovador do funcionário estar desatualizado no cadastro de funcionários.
		/*
		If !Empty(_cCodApr)
			Reclock("RD0", .F.)
				RD0->RD0_APROPC := _cCodApr
			RD0->(MsUnlock())
		EndIf
		*/

		If 	RD0->RD0_EMPATU	<> RDZ->RDZ_EMPENT .OR. RD0->RD0_FILATU <> RDZ->RDZ_FILENT
			Reclock("RD0", .F.)
				RD0->RD0_EMPATU	:= RDZ->RDZ_EMPENT
				RD0->RD0_FILATU	:= RDZ->RDZ_FILENT
			RD0->(MsUnlock())
		EndIf

	EndIf

	Restarea(_aArea)

Return