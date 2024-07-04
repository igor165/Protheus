
#include "protheus.ch"

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  14/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGCT01
	Tela para envio de dados iniciais a AGCO conforme documentação AGCO

	<b>DMS-01</b>: Enviar posição atual dos itens que estão disponível com pedidos em <br>
		aberto, itens reservados ou retornados.<br><br>

	<b>DMS-02</b>: Enviar todas as peças que já tiveram alguma movimentação.<br><br>

	<b>DMS-03</b>: Enviar todos os pedidos de compra feitos para a AGCO ou outros<br>
		fornecedores nos últimos 6 meses. As transferências entre filiais <br>
		devem ser enviadas, mas as vendas para concessionárias da rede não.<br><br>

	<b>DMS-04</b>: Enviar os últimos 36 meses de pedidos/vendas (balcão e oficina)<br>
		e devoluções. As transferências entre filiais devem ser enviadas, mas<br>
		as vendas para concessionárias da rede não.<br>

	<b>DMS-05</b>: N/A<br>

	<b>DMS-06</b>: Enviar todos os clientes ativos nos últimos 36 meses. Sendo ativos<br>
		todos aqueles que realizaram compra, devolução, orçamentos ou gerarem <br>
		uma venda perdida na concessionária.

	@author Vinicius Gati
	@since  14/06/2017
/*/
Function OFAGCT01()
	Private oProcess
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oUtil     := DMS_Util():New()
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := "'" + oArHlp:Join(oVmiPars:grupos(), "','")+oArHlp:Join(oVmiPars:gruposParalelos(), "','") + "'"
	Private cInFils   := oArHlp:Join(oVmiPars:filiais()        , "','")
	Private aFilis    := oVmiPars:filiais()
	Private dData36At := oVmiPars:DataInit()

	dData36At := oUtil:RemoveMeses(dData36At, 12)
	dData36At := oUtil:RemoveMeses(dData36At, 12) // 24
	dData36At := oUtil:RemoveMeses(dData36At, 12) // 36
	//OFAGCT0102DelimitaInit(aFilis)
	//oProcess := MsNewProcess():New( { || FS_RODA() }, "Gerando dados", "Aguarde...", .T. )
	//oProcess:Activate()
	// este fonte não é mais utilizado
Return .T.


/*/{Protheus.doc} FS_Roda
	Cria tela

	@author Vinicius Gati
	@since  14/06/2017
/*/
Static Function FS_RODA()
	Local aInterfaces := {"DMS-1", "DMS-2", "DMS-3", "DMS-4", "DMS-6"}
	Local nIdx := 1
	Local cInter // usado pra chamar a funcao correta da interface
	oProcess:SetRegua1( LEN(aInterfaces) )

	for nIdx := 1 to LEN(aInterfaces)
		oProcess:IncRegua1("Gerando dados interface : " + aInterfaces[nIdx])
		cInter := STRTRAN(aInterfaces[nIdx], "-", "") // remove o - pra chamar a função diretamente

		eval({|| &("Ini"+cInter+"()") })
	next
	MSGALERT("Processo Concluído ", "Atenção")
Return .t.

/*/{Protheus.doc} IniDMS1
	Enviar posição atual dos itens que estão disponível com pedidos em <br>
	aberto, itens reservados ou retornados.

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS1()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0

	cInArms := "'" + oArHlp:Join(oVmiPars:ArmReserva(), "','") + "'"

	For nIdx := 1 to Len(aFilis)
		cFilAnt := aFilis[nIdx]
		if ! OFAGCT0104PodeFazer(cFilAnt, "DMS1")
			loop
		end

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
		cQuery += "        AND SD1.D1_DTDIGIT >= '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD1.D_E_L_E_T_  = ' ' "
		cQuery += " ) TBTMP "
		cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+") "
		nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
		oProcess:SetRegua2(0)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

		while !( (cAl)->(eof()) )
			oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario},;
				{'ORIGEM', "OFAGCT01_IniDMS1"            },;
				{'PECAS'  , {(cAl)->CODIGO}              } ;
			})
			nFeitos += 1
			if MOD(nFeitos, 150) == 0
				oProcess:IncRegua2("Enviando dados de inventário..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot)))
			endif

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		OFAGCT0103GrvPontoRest(cFilAnt, "DMS1")
	Next
Return .T.

/*/{Protheus.doc} IniDMS2
	Enviar todas as peças que já tiveram alguma movimentação.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS2()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0

	For nIdx := 1 to Len(aFilis)
		cFilAnt := aFilis[nIdx]
		if ! OFAGCT0104PodeFazer(cFilAnt, "DMS2")
			loop
		end

		cQuery := " SELECT CODIGO FROM ( "
		cQuery += "     SELECT D1_COD CODIGO "
		cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
		cQuery += "      WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
		cQuery += "        AND SD1.D1_DTDIGIT >= '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += "   UNION "
		cQuery += "     SELECT D2_COD CODIGO "
		cQuery += "       FROM "+oSqlHlp:NoLock("SD2")
		cQuery += "      WHERE SD2.D2_FILIAL  = '"+xFilial('SD2')+"' "
		cQuery += "        AND SD2.D2_DTDIGIT >= '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += "   UNION "
		cQuery += "     SELECT D3_COD CODIGO "
		cQuery += "       FROM "+oSqlHlp:NoLock('SD3')
		cQuery += "      WHERE SD3.D3_FILIAL  = '"+xFilial('SD3')+"' "
		cQuery += "        AND SD3.D3_EMISSAO >= '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD3.D_E_L_E_T_ = ' ' "
		cQuery += " ) TBTMP "
		cQuery += " JOIN "+oSqlHlp:NoLock("SB1")+" ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = CODIGO AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SB1.B1_GRUPO IN ("+cGrupos+") "
		nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
		oProcess:SetRegua2(0)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

		while !( (cAl)->(eof()) )
			oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
				{'ORIGEM', "OFAGCT01_IniDMS2"           },;
				{'PECAS' , {(cAl)->CODIGO              }} ;
			})
			nFeitos += 1
			if MOD(nFeitos, 150) == 0
				oProcess:IncRegua2("Enviando dados de peças..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot)))
			endif

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		OFAGCT0103GrvPontoRest(cFilAnt, "DMS2")
	Next
Return .T.

/*/{Protheus.doc} IniDMS3
	Enviar todos os pedidos de compra feitos para a AGCO ou outros<br>
		fornecedores nos últimos 6 meses. As transferências entre filiais <br>
		devem ser enviadas, mas as vendas para concessionárias da rede não.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS3()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0

	For nIdx := 1 to Len(aFilis)
		cFilAnt := aFilis[nIdx]
		if ! OFAGCT0104PodeFazer(cFilAnt, "DMS3")
			loop
		end
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
		oProcess:SetRegua2(0)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

		while !( (cAl)->(eof()) )
			oVMi:Trigger({;
				{'INICIALIZACAO', .T.                             },;
				{'EVENTO'       , oVmi:oVmiMovimentos:Pedido      },;
				{'ORIGEM'       , "OFAGCT01_IniDMS3"              },;
				{'CODIGO'       , (cAl)->D1_DOC + (cAl)->D1_SERIE + (cAl)->D1_FORNECE + (cAl)->D1_LOJA } ;
			})
			nFeitos += 1
			if MOD(nFeitos, 150) == 0
				oProcess:IncRegua2("Enviando dados de compra/pedido..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot)))
			endif

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		OFAGCT0103GrvPontoRest(cFilAnt, "DMS3")
	Next
	// Pedidos de compra ultimos 6 meses
	// Transferencias removendo concessionários da rede
Return .T.

/*/{Protheus.doc} IniDMS4
	Enviar os últimos 36 meses de pedidos/vendas (balcão e oficina)<br>
	e devoluções. As transferências entre filiais devem ser enviadas, mas<br>
	as vendas para concessionárias da rede não.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS4()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0

	For nIdx := 1 to Len(aFilis)
		cFilAnt := aFilis[nIdx]
		if ! OFAGCT0104PodeFazer(cFilAnt, "DMS4")
			loop
		end

		cQuery := "    SELECT DISTINCT VS1_NUMORC, ' ' as VO1_NUMOSV "
		cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
		cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "     WHERE VS1_FILIAL      = '"+xFilial('VS1')+"' "
		cQuery += "       AND VS1_DATORC     >= '"+DTOS(dData36At)+"' "
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
		cQuery += "       AND VO1_DATABE     >= '"+DTOS(dData36At)+"' "
		cQuery += "       AND VO1.D_E_L_E_T_ =  ' ' "
		cQuery += "       AND SB1.B1_GRUPO IN ("+cGrupos+") "
		nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
		oProcess:SetRegua2(0)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

		while !( (cAl)->(eof()) )
			if Empty( (cAl)->(VS1_NUMORC) )
				oVMi:Trigger({;
					{'INICIALIZACAO', .T.                   },;
					{'EVENTO'       , oVmi:oVmiMovimentos:OS},;
					{'ORIGEM'       , "OFAGCT01_IniDMS4"    },;
					{'NUMERO_OS'    , (cAl)->VO1_NUMOSV     } ;
				})
			else
				oVMi:Trigger({;
					{'INICIALIZACAO'   , .T.                          },;
					{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
					{'ORIGEM'          , "OFAGCT01_IniDMS4"           },;
					{'NUMERO_ORCAMENTO', (cAl)->VS1_NUMORC            } ;
				})
			end
			nFeitos += 1
			if MOD(nFeitos, 150) == 0
				oProcess:IncRegua2("Enviando dados dos orçamentos..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot)))
			endif

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		OFAGCT0103GrvPontoRest(cFilAnt, "DMS4")
	Next
Return .T.

/*/{Protheus.doc} IniDMS6
	Enviar todos os clientes ativos nos últimos 36 meses. Sendo ativos<br>
	todos aqueles que realizaram compra, devolução, orçamentos ou gerarem <br>
	uma venda perdida na concessionária.<br><br>

	@author Vinicius Gati
	@since 14/06/2017
/*/
Static Function IniDMS6()
	Local cQuery  := ""
	Local nIdx    := 1
	Local cAl     := GetNextAlias()
	Local nFeitos := 0

	For nIdx := 1 to Len(aFilis)
		cFilAnt := aFilis[nIdx]
		if ! OFAGCT0104PodeFazer(cFilAnt, "DMS6")
			loop
		end

		cQuery := " SELECT CODIGO, LOJA FROM ( "
		cQuery += "     SELECT D1_FORNECE CODIGO, D1_LOJA LOJA "
		cQuery += "       FROM "+oSqlHlp:NoLock('SD1')
		cQuery += "      WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"' "
		cQuery += "        AND SD1.D1_DTDIGIT > '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += "  UNION "
		cQuery += "     SELECT D2_CLIENTE CODIGO, D2_LOJA LOJA "
		cQuery += "       FROM "+oSqlHlp:NoLock("SD2")
		cQuery += "      WHERE SD2.D2_FILIAL  = '"+xFilial('SD2')+"' "
		cQuery += "        AND SD2.D2_DTDIGIT > '"+DTOS(dData36At)+"' "
		cQuery += "        AND SD2.D_E_L_E_T_ = ' ' "
		cQuery += " ) TBTMP "
		cQuery += " JOIN "+oSqlHlp:NoLock("SA1")+" ON A1_FILIAL = '"+xFilial('SB1')+"' AND A1_COD = CODIGO AND A1_LOJA = LOJA AND SA1.D_E_L_E_T_ = ' ' "

		nTot := FM_SQL(" SELECT COALESCE(COUNT(*), 0) FROM ("+cQuery+") TBTMPCOUNT ")
		oProcess:SetRegua2(0)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )

		while !( (cAl)->(eof()) )
			oVMi:Trigger({;
				{'EVENTO' , oVmi:oVmiMovimentos:Cliente},;
				{'ORIGEM' , "OFAGCT01_IniDMS6"         },;
				{'CODIGO' , (cAl)->CODIGO              },;
				{'LOJA'   , (cAl)->LOJA                } ;
			})
			nFeitos += 1
			if MOD(nFeitos, 150) == 0
				oProcess:IncRegua2("Enviando dados de peças..." + ALLTRIM(STR(nFeitos)) + "/" + ALLTRIM(STR(nTot)))
			endif

			(cAl)->(DBSkip())
		enddo
		(cAl)->(dbCloseArea())
		OFAGCT0103GrvPontoRest(cFilAnt, "DMS6")
	Next
Return .T.

/*/{Protheus.doc} OFAGCT0101DadosExecucao
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 30/06/2017
/*/
Static Function OFAGCT0101DadosExecucao()
	local cFileName := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
	local oDados    := oUtil:ParamFileOpen(cFileName)
	if Empty( oDados:GetValue("FILIAL", "") )
		oDados:SetValue("FILIAL"   , "")
		oDados:SetValue("INTERFACE", "")
		oUtil:ParamFileSave(cFileName, oDados)
	end
Return oDados

/*/{Protheus.doc} OFAGCT0103GrvPontoRest
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 04/07/2017
/*/
Static Function OFAGCT0103GrvPontoRest(cFil, cInter)
	local cFileName := xFilial('VS3') + "_VMI_DADOS_EXECUCAO_INIT.JSON"
	local oDados := OFAGCT0101DadosExecucao()
	oDados:SetValue("FILIAL"   , cFil)
	oDados:SetValue("INTERFACE", cInter)
	oUtil:ParamFileSave(cFileName, oDados)
Return .T.

/*/{Protheus.doc} OFAGCT0104PodeFazer
	Retorna dados da execução do INIT pois o mesmo é feito 1 vez somente e pode demorar muito

	@author Vinicius Gati
	@since 04/07/2017
/*/
Static Function OFAGCT0104PodeFazer(cFil, cInter)
	local oDados := OFAGCT0101DadosExecucao()
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
