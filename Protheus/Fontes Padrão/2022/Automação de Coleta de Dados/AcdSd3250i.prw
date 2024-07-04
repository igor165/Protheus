#include "Protheus.ch"
#INCLUDE "FWLIBVERSION.CH"

Static __oSQLCBSD3 as object
Static __lVerLib 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º  Funcao  ³ CBSD3250I  º Autor ³ Anderson Rodrigues º Data ³Tue  08/11/02º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Impressao das Etiquetas dos PA's no						 	º±±
±±º          ³ apontamento da producao e baixa da requisicao do D4_EMPROC 	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBSD3250I()
	Local cAlias     := Alias()
	Local lRet       := .t.
	Local cImpOP     :=  AllTrim(GetNewPar("MV_IMPIPOP","0"))
	Local cOP        := ''
	Local cNumSeq    := ''
	Local cIdent     := ''
	Local cArmProc   := GetMvNNR('MV_LOCPROC','99')
	Local lAuto      := IIF(Type("aRotAuto") =="U",.F.,.T.)
	Local cQuery	 := ""

	__lVerLib := iIf(__lVerLib == NIL,FWLibVersion() >= "20211116",__lVerLib )


	If !SuperGetMV("MV_CBPE018",.F.,.F.)
		Return
	EndIf

	If !lAuto
		If Type("l250Auto") != "U"
			lAuto := l250Auto
		EndIf

		If !lAuto .AND. Type("l681Auto") != "U"
			lAuto := l681Auto
		EndIf

		If !lAuto .AND. Type("l680Auto") != "U"
			lAuto := l680Auto
		EndIf
	EndIf

	/* Verifica se deve imprimir etiqueta do PA ou do PI no fim do apontamento da producao*/
	If  cImpOp $ "1|2" // 1- Pergunta se imprime; 2- Imprime automaticamente sem perguntar
		If CBImpEti(SD3->D3_COD)
			ACDI10OP(lAuto)
		EndIf
	EndIf

	// Baixa os empenhos do campo SD4->D4_EMPROC -> Saldo Requisitado para armazem de processos
	If ExistBlock('ACD250I')
		lRet:= ExecBlock("ACD250I",.F.,.F.)
	EndIf

	If !lRet
		Return
	Endif

	cOP       := SD3->D3_OP
	cNumSeq   := SD3->D3_NUMSEQ
	cIdent    := SD3->D3_IDENT

	If __oSQLCBSD3 == nil
		cQuery := "SELECT SD3.D3_COD, SD4.R_E_C_N_O_ RECNOSD4, "
		cQuery += " SUM(SD3.D3_QUANT) D3_QUANT"
		cQuery += " FROM "+RetSqlName("SD3")+" SD3 "
		cQuery += " JOIN "+RetSqlName("SD4")+" SD4 "
		cQuery += "	ON SD4.D4_FILIAL = ?"               //- 1
		cQuery += "	AND SD4.D4_OP = SD3.D3_OP "
		cQuery += "	AND SD4.D4_COD = SD3.D3_COD "
		cQuery += "	AND SD4.D4_LOCAL = SD3.D3_LOCAL "
		cQuery += " AND SD4.D_E_L_E_T_ = ?"             //- 2
		cQuery += " WHERE SD3.D3_FILIAL = ?"             //- 3
		cQuery += "	AND SD3.D3_OP = ?"                  //- 4
		cQuery += "	AND SD3.D3_LOCAL = ?"               //- 5
		cQuery += "	AND SD3.D3_NUMSEQ = ?"              //- 6
		cQuery += "	AND SD3.D3_CF = ?"                  //- 7
		cQuery += "	AND SD3.D3_IDENT = ?"               //- 8
		cQuery += "	AND SD3.D_E_L_E_T_ = ?"             //- 9
		cQuery += " GROUP BY SD3.D3_COD, SD4.R_E_C_N_O_"
		cQuery := ChangeQuery(cQuery)
		If __lVerLib
			__oSQLCBSD3 := FwExecStatement():New(cQuery)
		Else
			__oSQLCBSD3 := FWPreparedStatement():New(cQuery)
		EndIf
	EndIf
	__oSQLCBSD3:SetString(01, xFilial('SD4'))
	__oSQLCBSD3:SetString(02, ' ')
	__oSQLCBSD3:SetString(03, xFilial('SD3'))
	__oSQLCBSD3:SetString(04, cOP)
	__oSQLCBSD3:SetString(05, cArmProc)
	__oSQLCBSD3:SetString(06, cNumSeq)
	__oSQLCBSD3:SetString(07, 'RE2')
	__oSQLCBSD3:SetString(08, cIdent)
	__oSQLCBSD3:SetString(09, ' ')

	If __lVerLib
		__oSQLCBSD3:OpenAlias('SD3TMP')
	Else
		cQuery := __oSQLCBSD3:GetFixQuery()
		MpSysOpenQuery(cQuery,'SD3TMP')
	ENDIF

	While !SD3TMP->(EOF())
		If SubStr(SD3TMP->D3_COD,1,3) == 'MOD'
			SD3TMP->(dbSkip())
			Loop
		EndIf

		cQuery := " UPDATE "+RetSqlName("SD4")
		cQuery += " SET D4_EMPROC = D4_EMPROC - "+CValToChar(SD3TMP->D3_QUANT)
		cQuery += " WHERE R_E_C_N_O_ = "+CValToChar(SD3TMP->RECNOSD4)

		If TcSqlExec(cQuery) != 0
			UserException(TcSQLError())
		EndIf

		SD3TMP->(dbSkip())
	End
	SD3TMP->(dbCloseArea())

	If !Empty(cAlias)
		DbSelectArea(cAlias)
	EndIf
Return
