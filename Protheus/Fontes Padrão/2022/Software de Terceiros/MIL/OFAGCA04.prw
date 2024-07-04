#Include "PROTHEUS.CH"
#Include "OFAGCA04.CH"
/*/{Protheus.doc} OFAGCA04
	VMI - Rotina de Menu que vai gerar/enviar DMS1 (Inventario) ou DMS2 (Dados da Peça) de uma determinada Peça

	@author Andre Luis Almeida
	@since  12/05/2021
/*/
Function OFAGCA04()
Local oVmiPars   := OFAGVmiParametros():New()
Local aFilis     := oVmiPars:filiais()
Local nCntFor    := 0
Local cBkpFilAnt := cFilAnt
Local cDMS       := "DMS1"
Local aDMS       := {"DMS1","DMS2","DMS1+DMS2"}
Local aRet       := {"",cDMS}
Local aParamBox  := {}
aAdd(aParamBox,{1,STR0002,space(GetSx3Cache("B1_COD","X3_TAMANHO")),"@!",'FG_Seek("SB1","MV_PAR01",1,.f.)',"SB1",".t.",070,.t.}) // Peça
aAdd(aParamBox,{2,STR0003,cDMS,aDMS,60,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0001 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
		cFilAnt := aFilis[nCntFor]
		If oVmiPars:FilialValida(cFilAnt)
			If aRet[2] == "DMS1+DMS2"
				OFAGCA0207_ItemEspecifico( aRet[1] , "DMS1" ) // ( B1_COD , Interface do DMS )
				OFAGCA0207_ItemEspecifico( aRet[1] , "DMS2" ) // ( B1_COD , Interface do DMS )
			Else
				OFAGCA0207_ItemEspecifico( aRet[1] , aRet[2] ) // ( B1_COD , Interface do DMS )
			EndIf
		EndIf
	Next
	cFilAnt := cBkpFilAnt
EndIf
Return