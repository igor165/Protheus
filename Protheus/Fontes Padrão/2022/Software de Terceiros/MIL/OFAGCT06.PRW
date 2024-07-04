#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} OFAGCT06
	Criado para re-iniciar processo DMS-4 (ultimos 36 meses)

	@type  Function
	@author Andre Luis Almeida
	@since 18/06/2018
	@version 12
	/*/
Function OFAGCT06
	Local nCntFor := 0
	Local cInter // usado pra chamar a funcao correta da interface
	Private cFileName := ""
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oUtil     := DMS_Util():New()
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := "'" + oArHlp:Join(oVmiPars:grupos(), "','") + oArHlp:Join(oVmiPars:gruposParalelos(), "','") + "'"
	Private aFilis    := oVmiPars:filiais()
	Private dData36At := dDataBase - ( 36 * 30 ) // ultimos 36 meses
	Private oLogger  
	If MsgYesNo("Deseja re-iniciar processo DMS-4 dos ultimos 36 meses?","OFAGCT06")
		For nCntFor :=  1 to len(aFilis)
			cFilAnt   := aFilis[nCntFor]
			cFileName := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
			oLogger   := DMS_Logger():New(xFilial('VS3') + "_LOG_OFAGCA02.LOG")
			IniDMS4() // DMS-4
		Next
		MsgAlert("Processo finalizado!","OFAGCT06")
	EndIf
	//
Return .T.

Static Function IniDMS4()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0
	//
	cQuery := "    SELECT DISTINCT VS1_NUMORC, '' as VO1_NUMOSV "
	cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
	cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE VS1_FILIAL      = '"+xFilial('VS1')+"' "
	cQuery += "       AND VS1_DATORC     >= '"+DTOS(dData36At)+"' AND VS1_DATORC <= '"+DTOS( dDataBase )+"' "
	cQuery += "       AND VS1.D_E_L_E_T_  = ' ' "
	cQuery += "       AND VS1.VS1_TIPORC IN ('1','3','P') "
	cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+") "
	cQuery += " UNION ALL "
	cQuery += "    SELECT DISTINCT ' ' as VS1_NUMORC, VO1_NUMOSV "
	cQuery += "      FROM " + oSqlHlp:NoLock('VO1')
	cQuery += "      JOIN " + oSqlHlp:NoLock('VO2') + " ON VO2_FILIAL = '"+xFilial('VO2')+"' AND VO2_NUMOSV = VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + oSqlHlp:NoLock('VO3') + " ON VO3_FILIAL = '"+xFilial('VO3')+"' AND VO3_NUMOSV = VO2_NUMOSV AND VO3_NOSNUM = VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO   = VO3_GRUITE AND B1_CODITE  = VO3_CODITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE VO1_FILIAL     =  '"+xFilial('VO1')+"' "
	cQuery += "       AND VO1_DATABE    >=  '"+DTOS(dData36At)+"' AND VO1_DATABE <= '"+DTOS( dDataBase )+"' "
	cQuery += "       AND VO1.D_E_L_E_T_ =  ' ' "
	cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+")"
	nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. ) // + " ORDER BY VS1_NUMORC, VO1_NUMOSV "

	while !( (cAl)->(eof()) )
		if Empty( (cAl)->(VS1_NUMORC) )
			oVMi:Trigger({;
				{'INICIALIZACAO', .T.                   },;
				{'EVENTO'       , oVmi:oVmiMovimentos:OS},;
				{'ORIGEM'       , "OFAGCT06_IniDMS4"    },;
				{'NUMERO_OS'    , (cAl)->VO1_NUMOSV     } ;
			})
		else
			oVMi:Trigger({;
				{'INICIALIZACAO'   , .T.                          },;
				{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
				{'ORIGEM'          , "OFAGCT06_IniDMS4"           },;
				{'NUMERO_ORCAMENTO', (cAl)->VS1_NUMORC            } ;
			})
		endif
		nFeitos += 1
		if MOD(nFeitos, 100) == 0
			oLogger:Log({'TIMESTAMP', "Gerando dados dos orçamentos..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))})
		endif
		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())
	//
Return .T.
