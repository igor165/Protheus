#INCLUDE 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMT250TO
Avaliar Digitacao deapontamento de produção

@author TOTVS
@return lRet
@since 08/02/2017
@version P11
/*/
//-------------------------------------------------------------------
Function DCLMT250TO()

Local lRet := .T.
Local aAreaSD4 := SD4->(GetArea())
Local cProg := AllTrim(FunName())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

dbselectarea("SD4")
dbsetorder(2)

If (cProg <> "MATA460A") .And. (cProg <> "MATA460B")
	If MsSeek(xFilial("SD4")+M->D3_OP)
		While Alltrim(SD4->D4_OP) == Alltrim(M->D3_OP)
			lRet := ValEstDcl(SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,M->D3_EMISSAO,3)
			If !lRet
				Exit
			EndIf
			dbselectarea("SD4")
			dbskip()
		EndDo
	EndIf
EndIf

RestArea(aAreaSD4)

Return lRet