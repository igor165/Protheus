#Include "PROTHEUS.CH"
#Include "OFAGCA10.CH"
/*/{Protheus.doc} OFAGCA10
	VMI - Rotina de Menu que vai gerar/enviar DMS1 (Inventario) ou DMS2 (Dados da Peça) de todas as Peças de um determinado Grupo

	@author Andre Luis Almeida
	@since  02/03/2022
/*/
Function OFAGCA10()
Local oVmiPars   := OFAGVmiParametros():New()
Local aFilis     := oVmiPars:filiais()
Local aRecSB1    := {}
Local cQuery     := ""
Local cSQLAlias  := "SQLSB1"
Local nCntFor    := 0
Local nCntSB1    := 0
Local cBkpFilAnt := cFilAnt
Local cDMS       := "DMS1"
Local aDMS       := {"DMS1","DMS2","DMS1+DMS2"}
Local aRet       := {"",cDMS}
Local aParamBox  := {}
aAdd(aParamBox,{1,STR0002,space(GetSx3Cache("B1_GRUPO","X3_TAMANHO")),"@!",'FG_Seek("SBM","MV_PAR01",1,.f.)',"SBM",".t.",060,.t.}) // Grupo
aAdd(aParamBox,{2,STR0003,cDMS,aDMS,60,"",.t.,".t."}) // Interface
If ParamBox(aParamBox, STR0001 ,@aRet,,,,,,,,.F.,.F.) // Geração VMI
	For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
		cFilAnt := aFilis[nCntFor]
		If oVmiPars:FilialValida(cFilAnt)
			aRecSB1 := {}
			cQuery := "SELECT R_E_C_N_O_ AS RECSB1"
			cQuery += "  FROM "+RetSqlName("SB1")
			cQuery += " WHERE B1_FILIAL='"+xFilial("SB1")+"'"
			cQuery += "   AND B1_GRUPO='"+aRet[1]+"'"
			cQuery += "   AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
			While !(cSQLAlias)->(Eof())
				aAdd( aRecSB1 , (cSQLAlias)->( RECSB1 ) )
				(cSQLAlias)->(dbSkip())
			EndDo
			(cSQLAlias)->(dbCloseArea())
			DBSelectArea("SB1")
			For nCntSB1 := 1 to len(aRecSB1)
				SB1->(DbGoto( aRecSB1[nCntSB1] ))
				If aRet[2] == "DMS1+DMS2"
					OFAGCA0207_ItemEspecifico( SB1->B1_COD , "DMS1" ) // ( B1_COD , Interface do DMS )
					OFAGCA0207_ItemEspecifico( SB1->B1_COD , "DMS2" ) // ( B1_COD , Interface do DMS )
				Else
					OFAGCA0207_ItemEspecifico( SB1->B1_COD , aRet[2] ) // ( B1_COD , Interface do DMS )
				EndIf
			Next
		EndIf
	Next
	cFilAnt := cBkpFilAnt
EndIf
Return