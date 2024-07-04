//////////////////
// versao 0006  //
//////////////////

#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFINJD25.ch'

/*/{Protheus.doc} OFINJD25
    Rotina scheduler que vai manter cache de calcest que sera usado no DPM

    Pontos de entrada:
		//
		// Hora inicial do expediente
		//
		User function OFJD25HI
		Return 6

		//
		// Hora final do expediente
		//
		User function OFJD25HF
		Return 18

		//
		// Pula o tempo de respiro (lentidao) da execucao, quem tem uma infra mais robusta pode querer isto
		//
		User function OFJD25F
		Return .T.

		//
		// Configura quantos meses atras serao mantidos em cache
		//
		User Function OFJD25MV
		Return 12

	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug
		

    @author Vinicius Gati
    @since  07/07/2015
/*/
Function OFINJD25(aParam)
	Private lMenu           := (VALTYPE(aParam) == "U")
	Private oCacheB2        := nil
	Private oUtil           := Nil
	Private oSqlHlp         := Nil
	Private oArHlp          := Nil
	Private oLogger         := Nil
	Private nMesesVoltar    := Nil
	Private aDatasOk        := {}
	Private nMesProcessando := 0
	Private cTblLogCod
	Private cAlias
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

	oLogger      := DMS_Logger():New("OFINJD25.LOG")
	oUtil        := DMS_Util():New()
	oSqlHlp      := DMS_SqlHelper():New()
	oArHlp       := DMS_ArrayHelper():New()
	// se está debugando o DPM ou só o Fonte
	lIsDebug     := "OFINJD25" $ GetNewPar("MV_XMILDBG", "NAO") .OR. "*DPM*" $ GetNewPar("MV_XMILDBG", "NAO")
	lProcForce   := lIsDebug .AND. "FORCE" $ GetNewPar("MV_XMILDBG", "NAO")
	aDatasOk     := oArHlp:Map( oLogger:GetArray("OFINJD25", 'MES_COMPLETO'), {|cData| STOD(cData) } )
	nMesesVoltar := IIF(ExistBlock('OFJD25MV'), ExecBlock("OFJD25MV",.f.,.f.),  12)

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFINJD25'                                  },;
		{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
		{'VQL_DADOS'      , 'MODO:' + IIF(lMenu, "Normal", "Agendado")  } ;
	})

	// Inicia a tabela de cache de calc est
	// cria a mesma no banco de dados caso não exista e fica preparado
	oCacheB2 := DMS_CacheB2():New()
	//
	dDToCache := oUtil:RemoveMeses( oUtil:UltimoDia( YEAR(dDatabase), MONTH(dDatabase) ), nMesesVoltar )
	//
	conout(STR0001 /*Iniciando*/ + " OFINJD25 " + DTOC(dDToCache) + " até :" + DTOC(oUtil:RemoveMeses( oUtil:UltimoDia( YEAR(dDatabase), MONTH(dDatabase) ), 1 )))
	dDtFinal := oUtil:RemoveMeses( oUtil:UltimoDia( YEAR(dDatabase), MONTH(dDatabase) ), 1 )
	dDtFinal := oUtil:UltimoDia( YEAR(dDtFinal), MONTH(dDtFinal) )
	//
	Do While dDToCache <=  dDtFinal // data do cache ser menor ou igual a data do mes atual - 1
		// Reseta status
		lAllProd := .F.
		//
		// Cabeçalho de inicio de processamento de mês
		cCodLogMes := oLogger:LogToTable({;
			{'VQL_AGROUP'     , 'OFINJD25'                                  },;
			{'VQL_TIPO'       , 'LOG_EXECUCAO'                              },;
			{'VQL_DADOS'      , 'Iniciando Mes ' + STR(MONTH(dDToCache))    },;
			{'VQL_CODVQL'     , cTblLogCod                                  } ;
		})
		//
		conout("OFINJD25 - 1.1 -" + TIME() + STR0001 /*Iniciando*/ + " mes  " + STR(MONTH(dDToCache)))
		//
		If ASCAN( aDatasOk, {|dData| dData == dDToCache } ) > 0 .AND. lProcForce == .F. // se a data ja foi processada "pula"
			dDToCache := oUtil:AddMeses(dDToCache, 1)
			dDToCache := oUtil:UltimoDia( YEAR(dDToCache), MONTH(dDToCache) )
			LOOP
		EndIf
		dMesAnt := oUtil:RemoveMeses( dDToCache, 1)
		dMesAnt := oUtil:UltimoDia(YEAR(dMesAnt), MONTH(dMesAnt))
		If ASCAN( aDatasOk, {|dData| dData == dMesAnt }) >  0 // já tenho o mês anterior ao que vou processar "ok"? se tiver posso processar demaneira rápida.
			oCacheB2:CacheToPMM( YEAR(dDToCache), MONTH(dDToCache) )
		Else
			oCacheB2:PrepareToProc(dDToCache, , lProcForce) // vai criar os registros sem flag de processamento
			oCacheB2:ProcLote(dDToCache, 3000, {|| IIF( ! JD25HvPerm(), sleep(10000), ) })
		EndIf
		//
		// fecha log de execução do mês para acompanhamento do tempo
		oLogger:CloseOpened(cCodLogMes) 
		//
		// oLogger pode ser usado para guardar informacoes tambem
		// nesse caso vou guardar os meses completos para não refazer posteriormente
		oLogger:LogToTable({                        ;
			{'VQL_AGROUP'     , 'OFINJD25'        },;
			{'VQL_TIPO'       , 'MES_COMPLETO'    },;
			{'VQL_CODVQL'     , cTblLogCod        },;
			{'VQL_DADOS'      , DTOS(dDToCache)   } ;
		})
		aDatasOk  := oArHlp:Map( oLogger:GetArray("OFINJD25", 'MES_COMPLETO'), {|cData| STOD(cData) } )
		dDToCache := oUtil:AddMeses(dDToCache, 1)
		dDToCache := oUtil:UltimoDia( YEAR(dDToCache), MONTH(dDToCache) )
		conout(DTOS(dDToCache))
	End Do

	oLogger:CloseOpened(cTblLogCod) // fecha log de execução total dos ultimos 6 meses
Return .T.

/*/{Protheus.doc} JD25HvPerm

	@author       Vinicius Gati
	@since        08/07/2015
	@description  Verifica se está no momento permitido de processar coisas pesadas

/*/
Function JD25HvPerm()
	Local cTime  := TIME()                   // Resultado: 10:37:17
	nHora        := VAL(SUBSTR(cTime, 1, 2)) // Resultado: 10
	nMinutos     := VAL(SUBSTR(cTime, 4, 2)) // Resultado: 37
	nHoraiBlock  := IIF(ExistBlock('OFJD25HI'), ExecBlock("OFJD25HI",.f.,.f.),  6) // hora inicio dia
	nHorafBlock  := IIF(ExistBlock('OFJD25HF'), ExecBlock("OFJD25HF",.f.,.f.), 22) // hora fim do dia


	If lProcForce .OR. ExistBlock('OFJD25F') // PE = forcar execucao
		Return .T.
	ElseIf nHora >= nHorafBlock .OR. nHora <= nHoraiBlock
		Return .T.
	Else
		Return .F.
	endIf
Return .F.
