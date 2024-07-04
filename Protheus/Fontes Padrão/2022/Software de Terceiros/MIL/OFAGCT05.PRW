#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} OFAGCT05
	Criado para re-iniciar processo DMS-1

	@type  Function
	@author Andre Luis Almeida
	@since 19/06/2018
	@version 12
	/*/
Function OFAGCT05
	Local nCntFor := 0
	Local cInter // usado pra chamar a funcao correta da interface
	Private cFileName := ""
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oUtil     := DMS_Util():New()
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := "'"+oArHlp:Join(oVmiPars:grupos(), "','") + oArHlp:Join(oVmiPars:gruposParalelos(), "','") + "'"
	Private aFilis    := oVmiPars:filiais()
	Private dData36At := oVmiPars:DataInit()
	Private oLogger  
	If MsgYesNo("Deseja re-iniciar processo DMS-1 de todos os Itens?","OFAGCT05")
		For nCntFor :=  1 to len(aFilis)
			cFilAnt   := aFilis[nCntFor]
			cFileName := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
			oLogger   := DMS_Logger():New(xFilial('VS3') + "_LOG_OFAGCA02.LOG")
			IniDMS1() // DMS-1
		Next
		MsgAlert("Processo finalizado!","OFAGCT05")
	EndIf
	//
Return .T.

Static Function IniDMS1()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0
	//
	cQuery := " SELECT CODIGO FROM ( "
	cQuery += "     SELECT B2_COD CODIGO "
	cQuery += "       FROM "+oSqlHlp:NoLock("SB2")
	cQuery += "      WHERE B2_FILIAL = '"+xFilial('SB2')+"' "
	cQuery += "        AND B2_QATU > 0 "
	cQuery += "        AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += "   UNION "
	cQuery += "     SELECT D1_COD CODIGO "
	cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
	cQuery += "       JOIN "+oSqlHlp:NoLock('SF4')+" ON F4_FILIAL = '"+xFilial('SF4')+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += "      WHERE D1_FILIAL = '"+xFilial('SD1')+"' "
	cQuery += "        AND SF4.F4_OPEMOV   = '09' "
	cQuery += "        AND SD1.D1_DTDIGIT >= '"+DTOS(dData36At)+"' AND SD1.D1_DTDIGIT <= '"+DTOS( dDataBase )+"' "
	cQuery += "        AND SD1.D_E_L_E_T_  = ' ' "
	cQuery += " ) TBTMP "
	//	
	cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+") "
	nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
	while !( (cAl)->(eof()) )
			oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario},;
				{'ORIGEM', "OFAGCT05_IniDMS1"            },;
				{'PECAS' , {(cAl)->CODIGO}               } ;
			})
			nFeitos += 1
			if MOD(nFeitos, 100) == 0
				oLogger:Log({'TIMESTAMP', "Gerando dados de inventário..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))})
			endif
		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())
	//	
Return .T.