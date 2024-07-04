//////////////////
// versao 0005  //
//////////////////

#include 'protheus.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "004170_4"


/*/{Protheus.doc} OFINJD34 "Atualização de pedidos JD(SCHEDULER)"
    Rotina scheduler que pode ser usada para corrigir pedidos importados com erro no protheus(ofinjd22/impxml)

    Pontos de entrada:
		
	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug
		

    @author Vinicius Gati
    @since  16/10/2015
/*/
Function OFINJD34(aParam)
	Local aRet      := {}
	Local aParamBox := {}
	Private lMenu           := (VALTYPE(aParam) == "U")
	Private oCacheB2        := nil
	Private oUtil           := Nil
	Private oSqlHlp         := Nil
	Private oArHlp          := Nil
	Private oLogger         := Nil
	Private aNotas          := {}
	Private lProcessado     := .F.
	Private lCorrige        := .F.
	Private cQuery          := ""
	Private cQueryC         := ""
	Private cFornec         := ""
//	Private cLoja           := ""
	Private cTblLogCod
	Private lIsDebug
	Private lProcForce

	if ! lMenu
		nModulo := 41
		cModulo := "PEC"
		__cInternet := 'AUTOMATICO'

		cEmpr   := aParam[1]
		cFil    := aParam[2]

		If Type("cArqTab")=="U"
		 cArqTab:=""
		EndIf

		cFOPENed := ""

		DbCloseAll()
		Prepare Environment Empresa cEmpr Filial cFil Modulo cModulo
	EndIf

	oLogger      := DMS_Logger():New("OFINJD34.LOG")
	oUtil        := DMS_Util():New()
	oSqlHlp      := DMS_SqlHelper():New()
	oArHlp       := DMS_ArrayHelper():New()

	// se está debugando o DPM ou só o Fonte
	lIsDebug     := "OFINJD34" $ GetNewPar("MV_XMILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_XMILDBG", "NAO")
	lProcForce   := lIsDebug .AND. "FORCE" $ GetNewPar("MV_XMILDBG", "NAO")

	// configura parametros
	aAdd(aParamBox,{1,"Fornecedor",SPACE(tamsx3('A2_COD' )[1]),"@!","","SA2",".T.",40,.T.})// Fornecedor
//	aAdd(aParamBox,{1,"Loja",SPACE(tamsx3('A2_LOJA')[1]),"@!","","",".T.",20,.T.})// Loja
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.) // Filtros
		cFornec := aRet[1]
//		cLoja   := aRet[2]
		ONJD34Tela()
	EndIf

Return .T.

/*/{Protheus.doc} ONJD34Tela
	Mostra UI para controle do processamento

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  16/10/2015
/*/
Function ONJD34Tela()
	// configuracao do formbatch
	Local aButtons := {;
		{ 1, .T., { || Processa( {|lAbort| ONJD34Proc(@lAbort) }, "Processando" /*"Processando"*/, "", .T. )   }},;
		{ 2, .T., { || FechaBatch()                 }} ;
	}
	FORMBATCH("Atualização automatica pedidos John Deere" /* "Atualização automatica pedidos Jhonn Deere " */ ,;
		     {"Rotina usada para atualizar os status dos pedidos com a JD" /* "Rotina usada para atualizar os status dos pedidos com a JD" */,;
		      "" /* "" */},;
		      aButtons)
Return

/*/{Protheus.doc} ONJD34Proc
	Atualiza os pedidos

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  16/10/2015
/*/
Function ONJD34Proc(lAbort)
	Local nIdx    := 0
	Local nIdxi   := 0
	Local i       := 0
	Local bBlock
	Local oWs
	Local oPediData
	Local oPed
	Local cAliasSC7
	Local cQuery := ""
	

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD34'                                  },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
		{'VQL_DADOS'      , 'MODO:' + IIF(lMenu, "Normal", "Agendado")  } ;
	})

	cQuery += " SELECT DISTINCT D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO "
	cQuery += "   FROM " + oSqlHlp:NoLock("SD1")
	cQuery += "  WHERE 1=1 "
	cQuery += "    AND D_E_L_E_T_ = ' ' AND D1_FORNECE = '"+cFornec+"' AND YEAR(D1_EMISSAO) >= 2015 "
	cQuery += "    AND D1_DOC NOT IN (SELECT VQL_DADOS FROM " + RetSQLName('VQL') + " WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD34' AND VQL_TIPO = 'FLAG' AND D_E_L_E_T_ = ' ') "
	cQuery += "  ORDER BY D1_EMISSAO DESC "
	If lMenu
		ProcRegua( LEN(aNotas) )
	EndIf
	
	aNotas := oSqlHlp:GetSelect({;
		{'campos', {"D1_FILIAL","D1_DOC", "D1_SERIE"}},;
		{'query' , cQuery                            } ;
	})

	// em caso de falha continua de onde parou
	If nIdx == 0
		nIdx := 1
	Else
		nIdx := nIdx + 1
	EndIf

	For nIdx := nIdx to LEN(aNotas)
		If lMenu
			IncProc( "Sincronizando Pedido: " /*"Sincronizando Pedido: "*/ + ALLTRIM(STR(nIdx)) + " de " /*" de "*/ + ALLTRIM(STR(LEN(aNotas))) ) 
		EndIf
		oPediData := aNotas[nIdx]
		cFilAnt   := oPediData:GetValue('D1_FILIAL')

		TcSqlExec("UPDATE "+ RetSQLName('VQL') + " SET VQL_HORAI = '"+ALLTRIM(STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ))+"' WHERE VQL_CODIGO = '"+cTblLogCod+"' AND D_E_L_E_T_ = ' ' ")
		
		IncProc( "Atualizando nota: " /*"Atualizando "*/ + ALLTRIM(STR(nIdx)) + " de " /*" de "*/ + ALLTRIM(STR(LEN(aNotas))) )

		BEGIN SEQUENCE
			
			If lProcForce .OR. FM_SQL(" SELECT COALESCE(COUNT(*),0) FROM " + RetSQLName('VQL') + " WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD34' AND VQL_TIPO = 'FLAG' AND VQL_DADOS = '"+oPediData:GetValue('D1_DOC')+"' AND VQL_DATAI >= '"+DTOS(ddatabase-2)+"' AND D_E_L_E_T_ = ' ' ") == 0
				oWS := WSJohnDeereJDPointNF():New()
				//oWS:SetDebug()
				oWS:oWSInput:cinvSequenceNumber := AllTrim(strzero(val(oPediData:GetValue('D1_DOC')),6))
				oWS:oWSInput:csoldByUnitCode := "2003"
				oWS:oWSInput:caccountID := alltrim(GetNewPar("MV_MIL0005",""))
				lProcessado := .f.
				lProcessado := oWS:getAdvanceShipNotice()
				
				//oLgNotas := DMS_Logger():New('NOTAS_PESQ.LOG')
				//oLgNotas:Log({ " filial protheus: "+xfilial('VS3')+" invoice: " + AllTrim(strzero(val(oPediData:GetValue('D1_DOC')),6)) + " Account: " + alltrim(GetNewPar("MV_MIL0005","")) })

				// Vou gravar no VQL datas de atualização do pedido, para evitar atualizar mais de uma vez em curto periodo de tempo
				BEGIN TRANSACTION
					

					If !lProcessado .AND. lMenu
						// Não faz nada, deu erro de ws, vai fazer de novo depois
					ElseIf !lProcessado
						conout("ERRO ao sincronizar dados com Webservice Jhonn Deere, rode pelo menu para mais detalhes.")
						oLogger:LogToTable({;
							{'VQL_AGROUP'     , 'OFINJD34'                                  },;
							{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
							{'VQL_DADOS'      , "ERRO ao sincronizar dados com Webservice Jhonn Deere, rode pelo menu para mais detalhes."  },;
							{'VQL_CODVQL'     , cTblLogCod                                  } ;
						})
					Else

						If oWS:oWSgetAdvanceShipNoticeReturn:creturnCode == "0"
							oLogger:Log({"TIMESTAMP", "Return code igual zero: " +oWS:oWSgetAdvanceShipNoticeReturn:cresponseMessage })
						Else
							nQtdItem := oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem
							if LEN(nQtdItem) == 0
								oLogger:LogToTable({;
									{'VQL_AGROUP'     , 'OFINJD34'                   },;
									{'VQL_TIPO'       , 'FLAG'                       },;
									{'VQL_DADOS'      , oPediData:GetValue('D1_DOC') },;
									{'VQL_CODVQL'     , cTblLogCod                   } ;
								})
							EndIf
							For i := 1 to Len(nQtdItem)
								cQuery := "SELECT SC7.R_E_C_N_O_ SC7RECNO , SC7.C7_NUM , SC7.C7_ITEM , SC7.C7_PRODUTO "
								cQuery += "FROM "
								cQuery += RetSqlName( "SC7" ) + " SC7 " 
								cQuery += "WHERE " 
								cQuery += "SC7.C7_FILIAL='"+ xFilial("SC7")+ "' AND SC7.C7_PEDFAB = '"+oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:corderID+"' AND SC7.C7_PRODUTO = '"+oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cpartNumber+"' AND SC7.C7_ITEPED = '"+substr(oWS:oWSgetAdvanceShipNoticeReturn:oWSinvoice:oWSinvoiceitem[i]:cMoveOrderID,11,4)+"' AND "
								cQuery += "SC7.D_E_L_E_T_=' '"
								cAliasSC7 := getnextalias()
								dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )
								
								if !( cAliasSC7 )->( Eof() )
										dbSelectArea("SD1")
										dbSetOrder(2)
										if dbSeek( xFilial("SD1") + (cAliasSC7)->C7_PRODUTO + ALLTRIM(oPediData:GetValue('D1_DOC')) + ALLTRIM(oPediData:GetValue('D1_SERIE'))) 
											Reclock("SD1",.f.)
											SD1->D1_PEDIDO := ( cAliasSC7 )->C7_NUM
											SD1->D1_ITEMPC := ( cAliasSC7 )->C7_ITEM
											MsUnlock()
											dbSelectArea("SC7")
											dbGoTo((cAliasSC7)->SC7RECNO)
											RecLock("SC7",.f.)
											SC7->C7_QUJE += SD1->D1_QUANT
											MsUnlock()
										Endif
								Endif
								(cAliasSC7)->(dbCloseArea())
							Next
						Endif
					EndIf
				End TRANSACTION
			EndIf

		RECOVER
			// ErrorBlock(bBlock)
		END SEQUENCE
	Next

	oLogger:CloseOpened(cTblLogCod)

	// limpando registros inuteis do banco
	// TcSqlExec(" UPDATE "+RetSQLName('VQL')+" SET R_E_C_D_E_L_ = R_E_C_N_O_ , D_E_L_E_T_ = '*' WHERE VQL_DATAI < '"+DTOS(ddatabase-4)+"' AND VQL_AGROUP = 'OFINJD34' AND VQL_TIPO = 'FLAG' AND D_E_L_E_T_ = ' ' ")
Return .T.
