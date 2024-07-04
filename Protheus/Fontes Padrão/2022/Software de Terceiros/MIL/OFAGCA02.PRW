#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#Include "OFAGCA02.CH"

/*/{Protheus.doc} OFAGCA02
	Rotina scheduler que vai gerar os dados de inicialização do VMI, pode demorar muito tempo

	@author Vinicius Gati
	@since  26/11/2015
/*/
Function OFAGCA02(aParam)
	BatchProcess(STR0001,STR0002,,{ || PROCESSO() }) // Geração de dados VMI / Este processo funciona via agendador, é um processo infinito que gera os dados de inicialização do VMI.
Return .T.

/*/{Protheus.doc} SchedDef
	Função padrão scheduler

	@author Vinicius Gati
	@since 28/06/2017
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"",;
	"",;
	"",;
	"" ;
	}
Return aParam


/*/{Protheus.doc} PROCESSO
	Gera dados de inicialização do VMI

	@author Vinicius Gati
	@since  26/11/2015
/*/
Static Function PROCESSO( cCOD , cDMS , cTIP )
	Local nIdx := 1
	Local cInter // usado pra chamar a funcao correta da interface
	Private cFileName := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oUtil     := DMS_Util():New()
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := "'" + oArHlp:Join(oVmiPars:grupos(), "','") + oArHlp:Join(oVmiPars:gruposParalelos(), "','") + "'"
	Private cInFils   := oArHlp:Join(oVmiPars:filiais()        , "','")
	Private lDebug    := "OFAGCA02" $ GetNewPar("MV_XMILDBG", "NAO") .OR. "AGCO" $ GetNewPar("MV_XMILDBG", "NAO")
	Private aFilis    := oVmiPars:filiais()
	Private dData36At := oVmiPars:DataInit()
	Private oLogger   := DMS_Logger():New(xFilial('VS3') + "_LOG_OFAGCA02.LOG")
	Default cCOD      := ""
	Default cDMS      := ""
	Default cTIP      := ""
	If Empty(cDMS)
		if ! LockByName("OFAGCA02" + xFilial('VS3') , .T. , .T. , .T. )
			conout(STR0003+' ' + xFilial('VS3')) // Ja rodando OFAGCA02 para a filial
			return .t.
		endif
		dData36At := oUtil:RemoveMeses(dData36At, 12)
		dData36At := oUtil:RemoveMeses(dData36At, 12) // 24
		dData36At := oUtil:RemoveMeses(dData36At, 12) // 36
		if oVmiPars:FilialValida(cFilAnt)  // só executa para filiais AGCO configuradas via OFAGCT02
			aInterfaces := {"DMS-1", "DMS-2", "DMS-3", "DMS-4", "DMS-6"} // não alterar a ordem pois a verificação de checkpoint é feita usando os numeros
			for nIdx := 1 to LEN(aInterfaces)
				cInter := STRTRAN(aInterfaces[nIdx], "-", "") // remove o - pra chamar a função diretamente
				eval({|| &("Ini"+cInter+"()") })
			next
		else
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			return .F.
		end
		UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
	Else // Item Especifico
		if oVmiPars:FilialValida(cFilAnt)
			eval({|| &("Ini"+cDMS+"('"+cCOD+"','"+cTIP+"')") })
		Else
			return .F.
		EndIf
	EndIf
Return .T.


/*/{Protheus.doc} IniDMS1
	Enviar posição atual dos itens que estão disponível com pedidos em <br>
	aberto, itens reservados ou retornados.

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS1(cB1_COD,cTIP)
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := ""
	Local nFeitos := 0
	Default cB1_COD := ""
	Default cTIP    := ""
	If Empty(cB1_COD)
		if OFAGCA0204PodeFazer(cFilAnt, "DMS1")
			cAl     := GetNextAlias()
			cInArms := "'" + oArHlp:Join(oVmiPars:ArmReserva(), "','") + "'"
			cQuery := " SELECT CODIGO FROM ( "
			cQuery += "     SELECT B2_COD CODIGO "
			cQuery += "       FROM "+oSqlHlp:NoLock("SB2")
			cQuery += "      WHERE B2_FILIAL = '"+xFilial('SB2')+"' "
			cQuery += "        AND B2_QATU > 0 "
			cQuery += "        AND B2_LOCAL IN ("+cInArms+") "
			cQuery += "        AND SB2.D_E_L_E_T_ = ' ' "
			cQuery += "   UNION "
			cQuery += "     SELECT D1_COD CODIGO "
			cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
			cQuery += "       JOIN "+oSqlHlp:NoLock('SF4')+" ON F4_FILIAL = '"+xFilial('SF4')+"' AND F4_CODIGO = D1_TES AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += "      WHERE D1_FILIAL = '"+xFilial('SD1')+"' "
			cQuery += "        AND SF4.F4_OPEMOV   = '09' "
			cQuery += "        AND SD1.D1_DTDIGIT >= '"+DTOS(dData36At)+"' AND SD1.D1_DTDIGIT <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "        AND SD1.D_E_L_E_T_  = ' ' "
			cQuery += " ) TBTMP "
			cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+")"
			nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
			while !( (cAl)->(eof()) )
					oVMi:Trigger({;
						{'EVENTO', oVmi:oVmiMovimentos:Inventario},;
						{'ORIGEM', "OFAGCA02_IniDMS1"            },;
						{'PECAS' , {(cAl)->CODIGO}               } ;
					})
					nFeitos += 1
					if MOD(nFeitos, 100) == 0
						oLogger:Log({'TIMESTAMP', STR0004 + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))}) // Gerando dados de inventário...
					endif
				(cAl)->(DBSkip())
			enddo
			(cAl)->(dbCloseArea())
			OFAGCA0203GrvPontoRest(cFilAnt, "DMS1")
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			KillApp(.t.)
		endif
	Else // Item Especifico
		oVMi:Trigger({;
			{'EVENTO', oVmi:oVmiMovimentos:Inventario},;
			{'ORIGEM', "OFAGCA04_IniDMS1"            },;
			{'PECAS' , {cB1_COD}} ;
			})
	EndIf
Return .T.

/*/{Protheus.doc} IniDMS2
	Enviar todas as peças que já tiveram alguma movimentação.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS2(cB1_COD,cTIP)
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := ""
	Local nFeitos := 0
	Default cB1_COD := ""
	Default cTIP    := ""
	If Empty(cB1_COD)
		if OFAGCA0204PodeFazer(cFilAnt, "DMS2")
			cAl    := GetNextAlias()
			cQuery := " SELECT CODIGO FROM ( "
			cQuery += "     SELECT D1_COD CODIGO "
			cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
			cQuery += "      WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
			cQuery += "        AND SD1.D1_DTDIGIT >= '"+DTOS(dData36At)+"'  AND SD1.D1_DTDIGIT <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "        AND SD1.D_E_L_E_T_ = ' ' "
			cQuery += "   UNION "
			cQuery += "     SELECT D2_COD CODIGO "
			cQuery += "       FROM "+oSqlHlp:NoLock("SD2")
			cQuery += "      WHERE SD2.D2_FILIAL  = '"+xFilial('SD2')+"' "
			cQuery += "        AND SD2.D2_DTDIGIT >= '"+DTOS(dData36At)+"'  AND SD2.D2_DTDIGIT <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += "   UNION "
			cQuery += "     SELECT D3_COD CODIGO "
			cQuery += "       FROM "+oSqlHlp:NoLock('SD3')
			cQuery += "      WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"' "
			cQuery += "        AND SD3.D3_EMISSAO >= '"+DTOS(dData36At)+"'  AND SD3.D3_EMISSAO <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "        AND SD3.D_E_L_E_T_ = ' ' "
			cQuery += " ) TBTMP "
			cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+")"
			nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
			while !( (cAl)->(eof()) )
				oVMi:Trigger({;
					{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
					{'ORIGEM', "OFAGCA02_IniDMS2"           },;
					{'PECAS' , {(cAl)->CODIGO              }} ;
				})
				nFeitos += 1
				if MOD(nFeitos, 100) == 0
					oLogger:Log({'TIMESTAMP', STR0005 + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))}) // Gerando dados de peças...
				endif
				(cAl)->(DBSkip())
			enddo
			(cAl)->(dbCloseArea())
			OFAGCA0203GrvPontoRest(cFilAnt, "DMS2")
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			KillApp(.t.)
		endif
	Else // Item Especifico
		oVMi:Trigger({;
			{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
			{'ORIGEM', "OFAGCA04_IniDMS2"           },;
			{'PECAS' , {cB1_COD}} ;
			})
	EndIf
Return .T.

/*/{Protheus.doc} IniDMS3
	Enviar todos os pedidos de compra (NF Entrada) feitos para a AGCO ou outros<br>
		fornecedores nos últimos 6 meses. As transferências entre filiais <br>
		devem ser enviadas, mas as vendas para concessionárias da rede não.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS3(cNUM,cTIP)
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := ""
	Local nFeitos := 0
	Default cNUM  := ""
	Default cTIP  := ""
	If Empty(cNUM)
		if OFAGCA0204PodeFazer(cFilAnt, "DMS3")
			cAl    := GetNextAlias()
			cQuery := "SELECT D1_DOC , D1_SERIE , D1_FORNECE , D1_LOJA "
			cQuery += "  FROM " + oSqlHlp:NoLock('SD1')
			cQuery += "  JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = D1_COD AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += "  JOIN " + oSqlHlp:NoLock('SF4') + " ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO  = D1_TES AND F4_OPEMOV = '01' AND SF4.D_E_L_E_T_ =' ' "
			cQuery += " WHERE D1_FILIAL   = '"+xFilial('SD1')+"' "
			cQuery += "   AND D1_DTDIGIT >= '"+DTOS(oVmiPars:DataInit() - 180)+"'  AND D1_DTDIGIT <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
			cQuery += "   AND SB1.B1_GRUPO IN ("+cGrupos+")"
			cQuery += " GROUP BY D1_DOC , D1_SERIE , D1_FORNECE , D1_LOJA "
			nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
			while !( (cAl)->(eof()) )
				oVMi:Trigger({;
					{'INICIALIZACAO', .T.                             },;
					{'EVENTO'       , oVmi:oVmiMovimentos:Pedido      },;
					{'ORIGEM'       , "OFAGCA02_IniDMS3"              },;
					{'CODIGO'       , (cAl)->D1_DOC + (cAl)->D1_SERIE + (cAl)->D1_FORNECE + (cAl)->D1_LOJA } ; // DOC + SERIE + FORNECEDOR + LOJA
				})
				nFeitos += 1
				if MOD(nFeitos, 100) == 0
					oLogger:Log({'TIMESTAMP', STR0006 + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))}) // Gerando dados de pedido...
				endif
				(cAl)->(DBSkip())
			enddo
			(cAl)->(dbCloseArea())
			OFAGCA0203GrvPontoRest(cFilAnt, "DMS3")
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			KillApp(.t.)
		endif
	Else // Pedido Especifico
		oVMi:Trigger({;
			{'INICIALIZACAO', .T.                             },;
			{'EVENTO'       , oVmi:oVmiMovimentos:Pedido      },;
			{'ORIGEM'       , "OFAGCA05_IniDMS3"              },;
			{'CODIGO'       , cNUM                            } ; // DOC + SERIE + FORNECEDOR + LOJA
			})
	EndIf
Return .T.

/*/{Protheus.doc} IniDMS4
	Enviar os últimos 36 meses de pedidos/vendas (balcão e oficina)<br>
	e devoluções. As transferências entre filiais devem ser enviadas, mas<br>
	as vendas para concessionárias da rede não.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS4(cNUM,cTIP)
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := ""
	Local nFeitos := 0
	Default cNUM  := ""
	Default cTIP  := ""
	If Empty(cNUM)
		if OFAGCA0204PodeFazer(cFilAnt, "DMS4")
			cAl    := GetNextAlias()
			cQuery := "    SELECT DISTINCT VS1_NUMORC, '' as VO1_NUMOSV "
			cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
			cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
			cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += "     WHERE VS1_FILIAL      = '"+xFilial('VS1')+"' "
			cQuery += "       AND VS1_DATORC     >= '"+DTOS(dData36At)+"' AND VS1_DATORC <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "       AND VS1.D_E_L_E_T_  = ' ' "
			cQuery += "       AND VS1.VS1_TIPORC IN ('1','3','P') "
			cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+")"
			cQuery += " UNION ALL "
			cQuery += "    SELECT DISTINCT ' ' as VS1_NUMORC, VO1_NUMOSV "
			cQuery += "      FROM " + oSqlHlp:NoLock('VO1')
			cQuery += "      JOIN " + oSqlHlp:NoLock('VO2') + " ON VO2_FILIAL = '"+xFilial('VO2')+"' AND VO2_NUMOSV = VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
			cQuery += "      JOIN " + oSqlHlp:NoLock('VO3') + " ON VO3_FILIAL = '"+xFilial('VO3')+"' AND VO3_NUMOSV = VO2_NUMOSV AND VO3_NOSNUM = VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' ' "
			cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_GRUPO   = VO3_GRUITE AND B1_CODITE  = VO3_CODITE AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += "     WHERE VO1_FILIAL     =  '"+xFilial('VO1')+"' "
			cQuery += "       AND VO1_DATABE    >=  '"+DTOS(dData36At)+"' AND VO1_DATABE <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "       AND VO1.D_E_L_E_T_ =  ' ' "
			cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+")"
			nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. ) // + " ORDER BY VS1_NUMORC, VO1_NUMOSV "
			while !( (cAl)->(eof()) )
				if Empty( (cAl)->(VS1_NUMORC) )
					oVMi:Trigger({;
						{'INICIALIZACAO', .T.                   },;
						{'EVENTO'       , oVmi:oVmiMovimentos:OS},;
						{'ORIGEM'       , "OFAGCA02_IniDMS4"    },;
						{'NUMERO_OS'    , (cAl)->VO1_NUMOSV     } ;
					})
				else
					oVMi:Trigger({;
						{'INICIALIZACAO'   , .T.                          },;
						{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
						{'ORIGEM'          , "OFAGCA02_IniDMS4"           },;
						{'NUMERO_ORCAMENTO', (cAl)->VS1_NUMORC            } ;
					})
				endif
				nFeitos += 1
				if MOD(nFeitos, 100) == 0
					oLogger:Log({'TIMESTAMP', STR0007 + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))}) // Gerando dados dos orçamentos...
				endif
				(cAl)->(DBSkip())
			enddo
			(cAl)->(dbCloseArea())
			OFAGCA0203GrvPontoRest(cFilAnt, "DMS4")
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			KillApp(.t.)
		endif
	Else // Especifico
		If cTIP == "1" // OS Especifica
			oVMi:Trigger({;
				{'INICIALIZACAO', .T.                   },;
				{'EVENTO'       , oVmi:oVmiMovimentos:OS},;
				{'ORIGEM'       , "OFAGCA06_IniDMS4"    },;
				{'NUMERO_OS'    , cNUM                  } ;
			})
		Else // Orcamento Especifico
			oVMi:Trigger({;
				{'INICIALIZACAO'   , .T.                          },;
				{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
				{'ORIGEM'          , "OFAGCA07_IniDMS4"           },;
				{'NUMERO_ORCAMENTO', cNUM                         } ;
			})
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} IniDMS6
	Enviar todos os clientes ativos nos últimos 36 meses. Sendo ativos<br>
	todos aqueles que realizaram compra, devolução, orçamentos ou gerarem <br>
	uma venda perdida na concessionária.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS6(cCODLOJ,cTIP)
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := ""
	Local nFeitos := 0
	Default cCODLOJ := ""
	Default cTIP    := ""
	If Empty(cCODLOJ)
		if OFAGCA0204PodeFazer(cFilAnt, "DMS6")
			cAl    := GetNextAlias()
			cQuery := " SELECT CODIGO, LOJA FROM ( "
			cQuery += "     SELECT D2_CLIENTE CODIGO, D2_LOJA LOJA "
			cQuery += "       FROM "+oSqlHlp:NoLock("SD2")
			cQuery += "      WHERE SD2.D2_FILIAL  = '"+xFilial('SD2')+"' "
			cQuery += "        AND SD2.D2_DTDIGIT >= '"+DTOS(dData36At)+"' AND SD2.D2_DTDIGIT <= '"+DTOS( oVmiPars:DataInit() )+"' "
			cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += " ) TBTMP "
			cQuery += " JOIN "+oSqlHlp:NoLock("SA1")+" ON A1_FILIAL = '"+xFilial('SA1')+"' AND A1_COD = CODIGO AND A1_LOJA = LOJA AND SA1.D_E_L_E_T_ = ' ' "
			nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
			while !( (cAl)->(eof()) )
				oVMi:Trigger({;
					{'EVENTO' , oVmi:oVmiMovimentos:Cliente},;
					{'ORIGEM' , "OFAGCA02_IniDMS6"         },;
					{'CODIGO' , (cAl)->CODIGO              },;
					{'LOJA'   , (cAl)->LOJA                } ;
				})
				nFeitos += 1
				if MOD(nFeitos, 100) == 0
					oLogger:Log({'TIMESTAMP', STR0008 + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot))}) // Gerando dados de clientes...
				endif

				(cAl)->(DBSkip())
			enddo
			(cAl)->(dbCloseArea())
			OFAGCA0203GrvPontoRest(cFilAnt, "DMS6")
			UnLockByName("OFAGCA02" + xFilial('VS3'), .T. , .T. , .T. )
			KillApp(.t.)
		endif
	Else // Cliente Especifico
		oVMi:Trigger({;
			{'EVENTO' , oVmi:oVmiMovimentos:Cliente},;
			{'ORIGEM' , "OFAGCA08_IniDMS6"         },;
			{'CODIGO' , left(cCODLOJ,GeTSX3Cache("A1_COD","X3_TAMANHO"))   },;
			{'LOJA'   , right(cCODLOJ,GeTSX3Cache("A1_LOJA","X3_TAMANHO")) } ;
		})
	EndIf
Return .T.

/*/{Protheus.doc} OFAGCA0201DadosExecucao
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 30/06/2017
/*/
Static Function OFAGCA0201DadosExecucao()
	local oDados := oUtil:ParamFileOpen(cFileName)
	if Empty( oDados:GetValue("FILIAL", "") )
		oDados:SetValue("FILIAL"   , "")
		oDados:SetValue("INTERFACE", "")
		oDados:SetValue("NUMERO_ATUAL", "-1")
		oUtil:ParamFileSave(cFileName, oDados)
	end
Return oDados

/*/{Protheus.doc} OFAGCA0203GrvPontoRest
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 04/07/2017
/*/
Static Function OFAGCA0203GrvPontoRest(cFil, cInter)
	local oDados := OFAGCA0201DadosExecucao()
	oDados:SetValue("FILIAL"   , cFil)
	oDados:SetValue("INTERFACE", cInter)
	oDados:SetValue("NUMERO_ATUAL", "-1")
	oUtil:ParamFileSave(cFileName, oDados)
Return .T.

/*/{Protheus.doc} OFAGCA0204PodeFazer
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 04/07/2017
/*/
Static Function OFAGCA0204PodeFazer(cFil, cInter)
	local oDados := OFAGCA0201DadosExecucao()
	local lPode  := .F.
	if Empty( oDados:GetValue("INTERFACE", "") )
		return .T.
	else
		nRest    := VAL( RIGHT(oDados:GetValue("INTERFACE"), 1) )
		nAtu     := VAL( RIGHT(cInter,1) )
		nFilRest := ASCAN(aFilis, {|cEl| cEl == oDados:GetValue("FILIAL") })
		nFilAtu  := ASCAN(aFilis, {|cEl| cEl == cFil  })
		if nAtu > nRest // verifica se interface nao eh menor e se filial nao foi feita ainda
			lPode := .T.
		elseif nAtu == nRest .AND. nFilAtu > nFilRest
			lPode := .T.
		end
	end
Return lPode

/*/{Protheus.doc} OFAGCA0205FoiFeito
	Usado para determinar se o registro já foi criado pela inicialização

	@type function
	@author Vinicius Gati
	@since 14/08/2017
/*/
Static Function OFAGCA0205FoiFeito(cFil, nNumAt)
	local oDados := OFAGCA0201DadosExecucao()
	if nNumAt > VAL( oDados:GetValue("NUMERO_ATUAL", "-1") )
		return .T.
	endIf
Return .F.

/*/{Protheus.doc} OFAGCA0206GravaStatusFor
	Grava em arquivo o indice do for atual, para que retorne quando reiniciado o processo

	@type function
	@author Vinicius Gati
	@since 14/08/2017
/*/
Static Function OFAGCA0206GravaStatusFor(nNumAt)
	local oDados := OFAGCA0201DadosExecucao()
	oDados:SetValue("NUMERO_ATUAL", ALLTRIM(STR(nNumAt)))
	oUtil:ParamFileSave(cFileName, oDados)
Return .F.

/*/{Protheus.doc} OFAGCA0207_ItemEspecifico
	Chamada pelo OFAGCA04 -> Item Especifico -> envio de DMS1 ou DMS2

	@type function
	@author Andre Luis Almeida
	@since 12/05/2021
/*/
Function OFAGCA0207_ItemEspecifico( cCOD , cDMS )
Default cCOD := ""
Default cDMS := ""
If !Empty(cCOD) .and. !Empty(cDMS) 
	PROCESSO( cCOD , cDMS , "" )
EndIf
Return .T.

/*/{Protheus.doc} OFAGCA0208_PedidoEspecifico
	Chamada pelo OFAGCA05 -> Pedido Especifico (NF Entrada) -> envio de DMS3

	@type function
	@author Andre Luis Almeida
	@since 14/05/2021
/*/
Function OFAGCA0208_PedidoEspecifico( cNUM , cDMS )
Default cNUM := ""
Default cDMS := ""
If !Empty(cNUM) .and. !Empty(cDMS)
	PROCESSO( cNUM , cDMS , "" )
EndIf
Return .T.

/*/{Protheus.doc} OFAGCA0209_OSEspecifica
	Chamada pelo OFAGCA06 -> OS Especifica -> envio de DMS4

	@type function
	@author Andre Luis Almeida
	@since 14/05/2021
/*/
Function OFAGCA0209_OSEspecifica( cNUM , cDMS )
Default cNUM := ""
Default cDMS := ""
If !Empty(cNUM) .and. !Empty(cDMS)
	PROCESSO( cNUM , cDMS , "1" ) // 1-OS
EndIf
Return .T.

/*/{Protheus.doc} OFAGCA0210_OrcamentoEspecifico
	Chamada pelo OFAGCA07 -> Orcamento Especifico -> envio de DMS4

	@type function
	@author Andre Luis Almeida
	@since 14/05/2021
/*/
Function OFAGCA0210_OrcamentoEspecifico( cNUM , cDMS )
Default cNUM := ""
Default cDMS := ""
If !Empty(cNUM) .and. !Empty(cDMS)
	PROCESSO( cNUM , cDMS , "2" ) // 2-Orcamento
EndIf
Return .T.

/*/{Protheus.doc} OFAGCA0211_ClienteEspecifico
	Chamada pelo OFAGCA08 -> Cliente Especifico -> envio de DMS6

	@type function
	@author Andre Luis Almeida
	@since 14/05/2021
/*/
Function OFAGCA0211_ClienteEspecifico( cCODLOJ , cDMS )
Default cCODLOJ := ""
Default cDMS    := ""
If !Empty(cCODLOJ) .and. !Empty(cDMS)
	PROCESSO( cCODLOJ , cDMS , "" )
EndIf
Return .T.