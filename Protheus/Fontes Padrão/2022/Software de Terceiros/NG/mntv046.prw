#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTV046
C�lculo da vari�vel FTEP - Faturamento da empresa no per�odo.

@param De_Data  , Date    , Data in�cio para filtro na Query
@param Ate_Data  , Date    , Ate data para filtro na Query
@param Fat_Period, Num�rico, Faturamento da empresa no per�odo.

@author Wexlei Silveira
@since 25/07/2018
@version P12
@return nResult, Num�rico, Soma do faturamento
/*/
//------------------------------------------------------------------------------
Function MNTV046(De_Data, Ate_Data, Fat_Period)

	Local aArea    := GetArea() // Salva �rea posicionada.
	Local cAlias   := GetNextAlias() // Alias atual.
	Local cQry     := "" // Vari�vel para armazenamento da query.
	Local nResult  := 0 // Vari�vel do resultado.
	Local lSigaFin := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S" // Verificar se est� habilitado o M�dulo Financeiro.

	Default De_Data   := CToD("")
	Default Fat_Period := 0

	If lSigaFin .And. Fat_Period == 0 // Caso seja integrado ao Financeiro e n�o foi informado valor no FAT_PERIOD

		cQry := "SELECT SUM(E1_VALOR) AS FATURAMENTO_BRUTO"
		cQry += "  FROM " + RetSqlName("SE1")
		cQry += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
		cQry += "   AND E1_VENCREA BETWEEN " + ValToSQL(De_Data) + " AND " + ValToSQL(Ate_Data)
		cQry += "   AND D_E_L_E_T_ <> '*'"

		cQry := ChangeQuery(cQry)
		MPSysOpenQuery(cQry, cAlias)

		dbSelectArea(cAlias)
		nResult := (cAlias)->FATURAMENTO
		(cAlias)->(dbCloseArea())
	Else
		nResult := Fat_Period
	EndIf

	RestArea(aArea)

Return nResult
