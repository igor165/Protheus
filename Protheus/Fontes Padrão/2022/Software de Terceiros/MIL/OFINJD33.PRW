//////////////////
// versao 0004  //
//////////////////

#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD33.CH'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "004170_3"


/*/{Protheus.doc} OFINJD33 "Atualiza status do pedido com JD"
    Rotina scheduler que vai atualizar status do pedido com ws john deere

    Pontos de entrada:
    	OFJD33DV => Número de dias do intervalo para refazer o mesmo pedido
		//
		// Intervalo em dias para atualizar o status do pedido(padrão 2)
		//
		User function OFJD33DV
		Return 1


		
	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug
		

    @author Vinicius Gati
    @since  07/07/2015
/*/
Function OFINJD33(aParam)
	Private lMenu           := (VALTYPE(aParam) == "U")
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
	Private oCacheB2        := nil
	Private oUtil           := Nil
	Private oSqlHlp         := Nil
	Private oArHlp          := Nil
	Private oLogger         := Nil
	Private aPedidos        := {}
	Private lProcessado     := .F.
	Private lCorrige        := .F.
	Private cQuery          := ""
	Private cQueryC         := ""
	Private oWs
	Private cTblLogCod
	Private lIsDebug
	Private lProcForce
	Private nQtdDias :=  IIF(ExistBlock('OFJD33DV'), ExecBlock("OFJD33DV",.f.,.f.), 1)

	oLogger      := DMS_Logger():New("OFINJD33.LOG")
	oUtil        := DMS_Util():New()
	oSqlHlp      := DMS_SqlHelper():New()
	oArHlp       := DMS_ArrayHelper():New()
	oWs          := Nil

	// se está debugando o DPM ou só o Fonte
	lIsDebug     := "OFINJD33" $ GetNewPar("MV_XMILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_XMILDBG", "NAO")
	lProcForce   := lIsDebug .AND. "FORCE" $ GetNewPar("MV_XMILDBG", "NAO")

	ONJD33Tela()
	
Return .T.

/*/{Protheus.doc} ONJD33Tela
	Mostra UI para controle do processamento

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/09/2015
/*/
Function ONJD33Tela()
	// configuracao do formbatch
	Local aButtons := {;
		{ 1, .T., { || Processa( {|lAbort| ONJD33Proc(@lAbort, lMenu) }, "Processando" /*"Processando"*/, "", .T. )   }},;
		{ 2, .T., { || FechaBatch()                 }} ;
	}
	FORMBATCH(STR0001 /* "Atualização automatica pedidos Jhonn Deere " */ ,;
		     {STR0002 /* "Rotina usada para atualizar os status dos pedidos com a JD" */,;
		      "" /* "" */},;
		      aButtons)
Return

/*/{Protheus.doc} ONJD33Proc
	Atualiza os pedidos

	Pontos de entrada:

	Parametros:

	@author Vinicius Gati
	@since  14/10/2015
/*/
Function ONJD33Proc(lAbort,lMenu)
	Local nIdx    := 0
	Local nIdxi   := 0
	default lMenu := .F.

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD33'                                  },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
		{'VQL_DADOS'      , 'MODO:' + IIF(lMenu, "Normal", "Agendado")  } ;
	})

	If lMenu
		lCorrige := MsgNoYes(STR0003 /*"Deseja corrigir os pedidos com nota?"*/, STR0004 /* "Informação" */)
	Else
		lCorrige := .T.
	EndIf

	cQuery += " SELECT DISTINCT C7_FILIAL, C7_PEDFAB "
	cQuery += "   FROM " + oSqlHlp:NoLock('SC7')
	cQuery += "  WHERE C7_PEDFAB <> ' ' "
	If lMenu .AND. lCorrige
		cQuery += "    AND C7_QUJE < C7_QUANT "
	EndIf
	cQuery += "    AND C7_PEDFAB NOT IN (SELECT VQL_DADOS FROM " + RetSQLName('VQL') + " WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_AGROUP = 'OFINJD33' AND VQL_TIPO = 'FLAG'  AND VQL_DATAI >= '"+DTOS(ddatabase-nQtdDias)+"' AND D_E_L_E_T_ = ' ') "
	cQuery += "    AND D_E_L_E_T_ = ' ' "

	aPedidos := oSqlHlp:GetSelect({;
		{'campos', {"C7_FILIAL", "C7_PEDFAB"}},;
		{'query' , cQuery                    } ;
	})

	If lMenu
		ProcRegua( LEN(aPedidos) )
	EndIf

	For nIdx := 1 to LEN(aPedidos)
		oPediData := aPedidos[nIdx]
		cFilAnt := oPediData:GetValue('C7_FILIAL')

		If lMenu
			IncProc(STR0006 /*"Sincronizando Pedido: "*/ + ALLTRIM(STR(nIdx)) + STR0007 /*" de "*/ + ALLTRIM(STR(LEN(aPedidos))) ) 
		Else
			conout(STR0008 /*"Sincronizando Pedido:"*/ + oPediData:GetValue('C7_PEDFAB'))
			oLogger:Log({"TIMESTAMP", STR0008 + oPediData:GetValue('C7_PEDFAB')})
		EndIf

		If OJD33UPEDFAB(oPediData, labort, .T.) == .F. // cancelou
			return .f.
		EndIf
	Next

	if lMenu
		MSGINFO(STR0010 /*"Finalizado"*/, STR0004)
	EndIf
	oLogger:CloseOpened(cTblLogCod)

	// limpando registros inuteis do banco
	TcSqlExec(" UPDATE "+RetSQLName('VQL')+" SET R_E_C_D_E_L_ = R_E_C_N_O_ , D_E_L_E_T_ = '*' WHERE VQL_DATAI < '"+DTOS(ddatabase-4)+"' AND VQL_AGROUP = 'OFINJD33' AND VQL_TIPO = 'FLAG' AND D_E_L_E_T_ = ' ' ")
Return .T.
//
//
//
//
//
Function OJD33UPEDFAB(oPediData, lAbort, lRot)
//	Local nIdx  := 0
	Local nIdxi := 0
	Local oAuxObj
	default lRot := .F.

	If EMPTY(oWS)
		oWS := WSJohnDeereJDPoint_Pedido_Compra():New()
	EndIf

	oLogger:LOG({"TIMESTAMP","usuário : " + oWs:_USER + " senha : " + oWs:_PASSWD })

	//oWS:SetDebug()
	oWS:corderNumber   := ALLTRIM( oPediData:GetValue('C7_PEDFAB') )
	oWS:caccountnumber := ALLTRIM( GetMV("MV_MIL0005") )
	lProcessado := .F.
	lProcessado := oWS:retrieveOrderStatus()
	If !lProcessado .AND. lMenu
		oWS:ExibeErro()
		Return
	ElseIf !lProcessado
		conout(STR0005) /*"ERRO ao sincronizar dados com Webservice Jhonn Deere, execute a rotina pelo menu para mais detalhes."*/
		Return .F.
		oLogger:Log({"TIMESTAMP", STR0005})
		oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD33'                                  },;
			{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
			{'VQL_DADOS'      , 'MODO:' + IIF(lMenu, "Normal", "Agendado")  },;
			{'VQL_CODVQL'     , cTblLogCod                                  } ;
		})
	EndIf

	If lAbort // botao cancelar
		MSGINFO(STR0009  /*"Processo cancelado"*/, STR0004 /* "Informação" */)
		Return .F.
	EndIf

	If lProcForce .OR. FM_SQL(" SELECT COALESCE(COUNT(*),0) FROM " + RetSQLName('VQL') + " WHERE VQL_FILIAL = '"+xFilial('VQL')+"' AND VQL_DADOS = '"+oPediData:GetValue('C7_PEDFAB')+"' AND VQL_DATAI >= '"+DTOS(ddatabase-nQtdDias)+"' AND D_E_L_E_T_ = ' ' ") == 0
		If !Empty( oWS:oOrderStatusReturn:OWSOrderLines )
			For nIdxi := 1 to Len(oWS:oOrderStatusReturn:OWSOrderLines:OWSOrderLine)

				oAuxObj := oWS:oOrderStatusReturn:OWSOrderLines:oWSOrderLine[nIdxi]
				cProduto := FM_SQL("SELECT SB1.B1_COD FROM "+RetSQLName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_CODFAB='"+oAuxObj:cpartNumber+"' AND SB1.D_E_L_E_T_=' '")
				cStatus  := OJD10GTSTS(oAuxObj:cstatus)

				// Vou gravar no VQL datas de atualização do pedido, para evitar atualizar mais de uma vez em curto periodo de tempo
				oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'OFINJD33'                        },;
					{'VQL_TIPO'       , 'FLAG'                            },;
					{'VQL_DADOS'      , oPediData:GetValue('C7_PEDFAB')   },;
					{'VQL_CODVQL'     , cTblLogCod                        } ;
				})

				If Empty(cStatus)
					cStatus := ""
				EndIf

				If ! Empty(cStatus)
					TcSqlExec("UPDATE TOP (1) "+RetSQLName('SC7')+" SET C7_STATUS = '"+cStatus+"', C7_ITEPED = '"+oAuxObj:clineNumber+"' " + ;
						"WHERE C7_FILIAL = '"+oPediData:GetValue('C7_FILIAL')+"' AND C7_PRODUTO = '"+cProduto+"' AND C7_PEDFAB = '"+oPediData:GetValue('C7_PEDFAB')+"' AND C7_ITEPED IN ('', '"+oAuxObj:clineNumber+"') AND D_E_L_E_T_ = ' ' ")
				EndIf

				oAuxObj:cStatus := ""
				oAuxObj:clineNumber := ""
			Next

			// Vou gravar no VQL datas de atualização do pedido, para evitar atualizar mais de uma vez em curto periodo de tempo
			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFINJD33'                        },;
				{'VQL_TIPO'       , 'FLAG'                            },;
				{'VQL_DADOS'      , oPediData:GetValue('C7_PEDFAB')   },;
				{'VQL_CODVQL'     , cTblLogCod                        } ;
			})
		EndIf
	EndIf
	
Return .T.
