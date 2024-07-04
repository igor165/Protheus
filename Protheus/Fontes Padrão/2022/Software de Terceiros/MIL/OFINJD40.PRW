
#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD40.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  31/05/2016
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "2"

/*/{Protheus.doc} OFINJD40 "Correção de datas de primeira entrada de itens JD"

		Pontos de entrada:
		N/A		
		Parametros:
		N/A

		@author Vinicius Gati
		@since  31/05/2016
/*/
Function OFINJD40()
	Local   cQuery    := ""
	Local   nIdx      := 1
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oDpm      := DMS_DPM():New()
	
	MSGALERT(STR0005 /*"Por favor, faça backup dos dados da tabela SBZ ou SB5 dependendo do parametro MV_MIL0054 antes de prosseguir"*/, STR0001 /*"Atenção"*/)

	If MsgNoYes(STR0003 /*"Deseja rodar a correção de data de entrada do DPM?"*/, STR0001 /*"Atenção"*/)
		aFilis := oDpm:GetFiliais()
		//
		for nIdx := 1 to LEN(aFilis)
			//
			cFilAnt    := aFilis[nIdx, 1]
			//
			if GetNewPar("MV_MIL0054","SBZ") == "SBZ"
				cQuery += " UPDATE " + RetSqlName('SBZ') + " SET BZ_PRIENT = CALCULADO.PRIENT "
				cQuery += " FROM "
				cQuery += " ( "
				cQuery += "     SELECT SBZ.R_E_C_N_O_ RECNO, SBZ.BZ_PRIENT, MIN(VB8_ANO+VB8_MES+VB8_DIA) PRIENT, MAX(VB8_ANO+VB8_MES+VB8_DIA) ULTVDA "
				cQuery += "       FROM " + oSqlHlp:NoLock('VB8')
				cQuery += " INNER JOIN " + oSqlHlp:NoLock('SBZ') + " ON BZ_FILIAL = VB8_FILIAL AND BZ_COD = VB8_PRODUT AND SBZ.D_E_L_E_T_ = ' ' "
				cQuery += "      WHERE VB8.D_E_L_E_T_ = ' ' AND (VB8_VDAB + VB8_VDAO + VB8_HITSB + VB8_HITSO) > 0 "
				cQuery += "   GROUP BY SBZ.R_E_C_N_O_, VB8_FILIAL, VB8_PRODUT, BZ_PRIENT "
				cQuery += "     HAVING BZ_PRIENT > MIN(VB8_ANO+VB8_MES+VB8_DIA) OR BZ_PRIENT = ' ' "
				cQuery += " ) CALCULADO "
				cQuery += " WHERE CALCULADO.RECNO = R_E_C_N_O_ "
			Else
				cQuery += " UPDATE " + RetSqlName('SB5') + " SET B5_DTADDED = CALCULADO.PRIENT "
				cQuery += " FROM "
				cQuery += " ( "
				cQuery += "     SELECT SB5.R_E_C_N_O_ RECNO, SB5.B5_DTADDED, MIN(VB8_ANO+VB8_MES+VB8_DIA) PRIENT, MAX(VB8_ANO+VB8_MES+VB8_DIA) ULTVDA "
				cQuery += "       FROM " + oSqlHlp:NoLock('VB8')
				cQuery += " INNER JOIN " + oSqlHlp:NoLock('SB5') + " ON B5_FILIAL = VB8_FILIAL AND B5_COD = VB8_PRODUT AND SB5.D_E_L_E_T_ = ' ' "
				cQuery += "      WHERE VB8.D_E_L_E_T_ = ' ' AND (VB8_VDAB + VB8_VDAO + VB8_HITSB + VB8_HITSO) > 0 "
				cQuery += "   GROUP BY SB5.R_E_C_N_O_, VB8_FILIAL, VB8_PRODUT, B5_DTADDED "
				cQuery += "     HAVING SB5.B5_DTADDED > MIN(VB8_ANO+VB8_MES+VB8_DIA) OR SB5.B5_DTADDED = ' ' "
				cQuery += " ) CALCULADO "
				cQuery += " WHERE CALCULADO.RECNO = R_E_C_N_O_ "
			EndIf
			tcsqlexec(cQuery)
			//
		next
		//		
		MSGINFO(STR0004 /*"Processo finalizado com sucesso"*/, STR0002 /*"Sucesso"*/)
	EndIf
Return NIL
