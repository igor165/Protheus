#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A390PCPInt
Integração do estoque com o MRP
@author Marcelo Neumann
@since 25/09/2019
@version 1.0
/*/
Function A390PCPInt(cFil, cProduto, cLocal)

	Local aArea  := GetArea()
	Local cIdReg := cFil + cProduto + cLocal

	//Verifica se a tabela do MRP existe
	If !AliasInDic("T4R")
		Return
	EndIf

	//Verifica se a integração está ativa
	If !IntNewMRP("MRPSTOCKBALANCE")
		Return
	EndIf

	//Verifica se já existe um registro na T4R para esse produto + local
	dbSelectArea("T4R")
	T4R->(dbSetOrder(1))
	If !T4R->(dbSeek(xFilial("T4R") + cIdReg))
		//Inclui um registro na T4R para a integração
		RecLock("T4R", .T.)
			T4R->T4R_FILIAL := xFilial("T4R")
			T4R->T4R_API    := "MRPSTOCKBALANCE"
			T4R->T4R_STATUS := "3"
			T4R->T4R_IDREG  := cIdReg
			T4R->T4R_DTENV  := Date()
			T4R->T4R_HRENV  := Time()
			T4R->T4R_PROG   := "MATA390"
			T4R->T4R_TIPO   := "1"
		MsUnlock()
	EndIf

	If FWAliasInDic("HWL",.F.)
		dbSelectArea('HWL')
		HWL->(dbSetOrder(1))
		IF HWL->( dbSeek( xFilial("HWL") + "1" ) )
			If HWL->HWL_NETCH == "1"
				//Verifica se a tabela do Net Change existe
				If AliasInDic("HWJ")
					dbSelectArea("HWJ")
					HWJ->(dbSetOrder(1))
					If !HWJ->(dbSeek(xFilial("HWJ") + cProduto))
						//Inclui um registro na HWJ para a integração
						RecLock("HWJ", .T.)
							HWJ->HWJ_FILIAL := xFilial("HWJ")
							HWJ->HWJ_PROD   := cProduto
							HWJ->HWJ_EVENTO := "1"
							HWJ->HWJ_ORIGEM := "3"
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return