#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

#DEFINE cDefFWis "999"
#DEFINE cDefEWis "1"

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS0009

Rotina de integração entre o Protheus e WIS

@author Allan Constantino Bonfim
@since  15/08/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function WWIS0009(aParam)

Local aRet			:= {}
Local cFunExec	:= ""
Local aComboE 	:= {"01=Sanchez"}
Local aComboF 	:= {"01=Matriz","05=Franquias"}
Local aParamBox	:= {}
Local cPerg		:= "OM200"
Local aAreaSM0 	:= {}
Local lTAmbiente 	:= .F.
Local oAppBk
Local cEmp
Local cFil
Local _par01
Local _par02

Default aParam	:= {}


If Len(aParam) > 0
	_par01 	:= aParam[1]
	_par02	:= aParam[2]
Else
	_par01 := '01'
	_par02 := '05'
EndIf
	
If (Type("oMainWnd") == "O")
	
	AADD(aParamBox,{2,"Empresa: ", 1, aComboE, 100, ".F.", .F. })		// MV_PAR01
	AADD(aParamBox,{2,"Filial:  ", 2, aComboF, 100, ".F.", .F. })		// MV_PAR01
	
	If !ParamBox(aParamBox,"Filtros Extras...",@aRet,,,,,,,cPerg,.T.,.T.)
		Return()
	EndIf
	
	If ValType(aRet[1]) == "N"
		aRet[1] := Alltrim(Str(aRet[1]))
	Else
		aRet[1] := Alltrim(aRet[1])
	EndIf
	
	If ValType(aRet[2]) == "N"
		aRet[2] := Alltrim(Str(aRet[2]))
	Else
		aRet[2] := Alltrim(aRet[2])
	EndIf

	_par01 := iif(aRet[1] == '1', '01', iif(aRet[1] == '2', '02', aRet[1]))
	_par02 := iif(aRet[2]=='1', '01', iif(aRet[2]=='2', '05', aRet[2]))
	
	cEmp    := _par01
	cFil    := _par02
	
	//CM Solutions - Allan Constantino Bonfim - 
	If GetNewPar("ZZ_WIS9WIS", .F.)
		If cEmp <> FWCodEmp() .OR. cFil <> FWCodFil()
			lTAmbiente := .T. 
		EndIf
		
		If lTAmbiente
			oAppBk 	:= oApp //Guardo a variavel resposavel por componentes visuais
			aAreaSM0 	:= SM0->(GetArea())
			
			dbCloseAll() //Fecho todos os arquivos abertos
			OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
			dbSelectArea("SM0") //Abro a SM0
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmp+cFil, .T.)) //Posiciona Empresa
			cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
			cFilAnt := SM0->M0_CODFIL
			OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar				
		EndIf
		
		CONOUT("PROCESSOS WMS - INICIO - ID "+cValtochar(ThreadId())+" - EMPRESA "+cEmp+" - FILIAL "+cFil+" - DATA "+DTOC(ddatabase)+" - HORA "+Time())		

			DbSelectArea("ZWO")
			DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
			ZWO->(DbGoTop())
			
			While !ZWO->(EOF())
				cFunExec := ""
				If ZWO->ZWO_MSBLQL = "2" .AND. ZWO->ZWO_INTWIS = "1" .AND. ZWO->ZWO_PROEMP == "1"  
					cFunExec := ALLTRIM(ZWO_FUNAME)+"('"+cEmp+"','"+cFil+"',,'"+ALLTRIM(ZWO->ZWO_CODIGO)+"','"+ALLTRIM(ZWO->ZWO_TPNOTA)+"','"+ALLTRIM(ZWO->ZWO_TPPEDI)+"')"
					
					If !EMPTY(cFunExec)
						//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Ajuste no conout dos processos
						//U_W1CONOUT(ZWO->ZWO_CODIGO, ZWO->ZWO_DESCRI, cEmp, cFil, .T.)
						FWMsgRun(, {|| &cFunExec}, "Processos WMS - Processando...", SUBSTR(ALLTRIM(ZWO->ZWO_CODIGO)+ " - "+ZWO->ZWO_DESCRI, 1, 60))
						//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Ajuste no conout dos processos
						//U_W1CONOUT(ZWO->ZWO_CODIGO, ZWO->ZWO_DESCRI, cEmp, cFil, .F.)
					EndIf
				EndIf
				
				ZWO->(DbSkip())
			EndDo
		
		CONOUT("PROCESSOS WMS - FIM - ID "+cValtochar(ThreadId())+" - EMPRESA "+cEmp+" - FILIAL "+cFil+" - DATA "+DTOC(ddatabase)+" - HORA "+Time())

		If lTAmbiente
			dbCloseAll() //Fecho todos os arquivos abertos
			OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
			dbSelectArea("SM0")
			SM0->(dbSetOrder(1))
			SM0->(RestArea(aAreaSM0)) //Restaura Tabela
			cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
			cEmpAnt := SM0->M0_CODIGO
			
			OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
			oApp := oAppBk //Backup do componente visual		
		EndIf
			
		DelClassIntf()	
	EndIf

Else

	cEmp := _par01
	cFil := _par02
	
	//---------------------------------------------------------------------
	// Inicializa ambiente sem consumir licencas
	//---------------------------------------------------------------------
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
		If  GetNewPar("ZZ_WIS9WIS", .F.)
			
			CONOUT("PROCESSOS WMS - INICIO - ID "+cValtochar(ThreadId())+" - EMPRESA "+cEmp+" - FILIAL "+cFil+" - DATA "+DTOC(ddatabase)+" - HORA "+Time())		
	
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				ZWO->(DbGoTop())
				
				While !ZWO->(EOF())
					cFunExec := ""
					If ZWO->ZWO_MSBLQL = "2" .AND. ZWO->ZWO_INTWIS = "1" .AND. ZWO->ZWO_PROEMP == "1" 
						cFunExec := ALLTRIM(ZWO_FUNAME)+"('"+cEmp+"','"+cFil+"',,'"+ALLTRIM(ZWO->ZWO_CODIGO)+"','"+ALLTRIM(ZWO->ZWO_TPNOTA)+"','"+ALLTRIM(ZWO->ZWO_TPPEDI)+"')"
						
						If !EMPTY(cFunExec)
							//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Ajuste no conout dos processos
							//U_W1CONOUT(ZWO->ZWO_CODIGO, ZWO->ZWO_DESCRI, cEmp, cFil, .T.)
							FWMsgRun(, {|| &cFunExec}, "Processos WMS", "Processando "+ALLTRIM(ZWO->ZWO_CODIGO)+ " - "+ALLTRIM(ZWO->ZWO_DESCRI))
							//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Ajuste no conout dos processos
							//U_W1CONOUT(ZWO->ZWO_CODIGO, ZWO->ZWO_DESCRI, cEmp, cFil, .F.)
						EndIf
					EndIf
					
					ZWO->(DbSkip())
				EndDo
			
			CONOUT("PROCESSOS WMS - FIM - ID "+cValtochar(ThreadId())+" - EMPRESA "+cEmp+" - FILIAL "+cFil+" - DATA "+DTOC(ddatabase)+" - HORA "+Time())	
		EndIf			
	DelClassIntf()
	RpcClearEnv()		
			
Endif

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP004

Integração do Processo 004 - Faturamento para as Franquias

@author Allan Constantino Bonfim
@since  17/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP004(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 004"
Local cFunName	:= "WWISP004"

Default cEmpPrc	:= "01"
Default cFilPrc	:= "01" 
Default cProcess	:= "004"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	////CONOUT("INICIALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetNewPar("ZZ_WIS9WIS", .F.) //Alltrim(cFilPrc) $ "01" .AND. Alltrim(cFilPrc) == "01"
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName, .T., .F.)
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - PEDIDO DE SAIDA - SITUACAO 1
			
			//STATUS 01			
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - FINALIZAÇÃO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "00", .F.)
			//CONOUT(cTxtProc+" - FIM - FINALIZAÇÃO DO PROCESSO")
									
			UnLockByName(cFunName, .T., .F.)			
		Else
			//CONOUT(cTxtProc+" - ATENÇÂO - EM EXECUÇÃO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUÇÃO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZAÇÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP009

Integração do Processo 009 - Faturamento Fini para Clientes


@author Allan Constantino Bonfim
@since  17/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP009(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 009"
Local cFunName	:= "WWISP009"

Default cEmpPrc	:= "01"
Default cFilPrc	:= "01" 
Default cProcess	:= "009"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetNewPar("ZZ_WIS9WIS", .F.) //Alltrim(cFilPrc) $ "01" .AND. Alltrim(cFilPrc) == "01"
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName, .T., .F.)
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - PEDIDO DE SAIDA - SITUACAO 1
			
			//STATUS 01			
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - FINALIZAÇÃO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "00", .F.)
			//CONOUT(cTxtProc+" - FIM - FINALIZAÇÃO DO PROCESSO")
									
			UnLockByName(cFunName, .T., .F.)			
		Else
			//CONOUT(cTxtProc+" - ATENÇÂO - EM EXECUÇÃO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUÇÃO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZAÇÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP010

Integração do Processo 010 - Vendas de Marcas Próprias Sanchez Cano armaz. na Fini

@author Allan Constantino Bonfim
@since  17/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP010(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 010"
Local cFunName	:= "WWISP010"

Default cEmpPrc	:= "01"
Default cFilPrc	:= "01" 
Default cProcess	:= "010"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetNewPar("ZZ_WIS9WIS", .F.) //Alltrim(cFilPrc) $ "01" .AND. Alltrim(cFilPrc) == "01"
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName, .T., .F.)
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - PEDIDO DE SAIDA - SITUACAO 1
			
			//STATUS 01			
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - FINALIZAÇÃO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "00", .F.)
			//CONOUT(cTxtProc+" - FIM - FINALIZAÇÃO DO PROCESSO")
									
			UnLockByName(cFunName, .T., .F.)			
		Else
			//CONOUT(cTxtProc+" - ATENÇÂO - EM EXECUÇÃO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUÇÃO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZAÇÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZAÇÃO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W01FIMST

Finaliza os processos após o processamento

@author Allan Constantino Bonfim
@since  30/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function W01FIMST(cEmpres, cPAlias, cProcess, cStatSai, cStatEnt, lSituac9, cFilWis)

Local lRet			:= .F.
Local cQStat		:= ""
Local cTmpStat	:= GetNextAlias()

Default cEmpres	:= cDefEWis //"1" //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cPAlias	:= ""
Default cProcess	:= ""
Default cStatEnt	:= ""
Default cStatSai	:= ""
Default lSituac9	:= .T.
Default cFilWis	:= cDefFWis //"001"

If !Empty(cProcess)
	cQStat := "SELECT ZWK_FILIAL AS FILIAL, ZWK_EMPRES AS EMPRESA, ZWK_DEPOSI AS FILWIS, ZWK_CODIGO AS CODIGO, MIN(STENTRADA) AS STATENTRA, MIN(STSAIDA) AS STATSAIDA "+CHR(13)+CHR(10) 
	cQStat += "FROM ( "+CHR(13)+CHR(10)	
	cQStat += "		SELECT ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO, (CASE WHEN ZWK_STATUS > ZWL_STATUS THEN ISNULL(ZWL_STATUS, '00') ELSE ISNULL(ZWK_STATUS, '00') END) AS STSAIDA, " 
	cQStat += "		(CASE WHEN ZWI_STATUS > ZWJ_STATUS THEN ISNULL(ZWJ_STATUS, '00') ELSE ISNULL(ZWI_STATUS,'00') END) AS STENTRADA "+CHR(13)+CHR(10)
	cQStat += "		FROM "+RetSqlName("ZWK")+" ZWK (NOLOCK) "+CHR(13)+CHR(10)
	cQStat += "		LEFT JOIN "+RetSqlName("ZWL")+" ZWL (NOLOCK) "+CHR(13)+CHR(10)
	cQStat += "		ON (ZWK_FILIAL = ZWL_FILIAL AND ZWK_EMPRES = ZWL_EMPRES AND ZWK_DEPOSI = ZWL_DEPOSI AND ZWK_CODIGO = ZWL_CODIGO AND ZWK_PROCES = ZWL_PROCES AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
	cQStat += "		LEFT JOIN "+RetSqlName("ZWI")+" ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQStat += "		ON (ZWK_FILIAL = ZWI_FILIAL AND ZWK_EMPRES = ZWI_EMPRES AND ZWK_DEPOSI = ZWI_DEPOSI AND ZWK_CODIGO = ZWI_CODIGO AND ZWK_PROCES = ZWI_PROCES AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
	cQStat += "		LEFT JOIN "+RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
	cQStat += "		ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
	cQStat += "		WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQStat += "		AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
	cQStat += "		AND ZWK_CALIAS = '"+cPAlias+"' "+CHR(13)+CHR(10)
	cQStat += "		AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
	cQStat += "		AND ZWK_EMPRES = '"+cEmpres+"' "+CHR(13)+CHR(10)
	cQStat += "		AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
	
	If lSituac9
		cQStat += "		AND (EXISTS (SELECT ZWK_CODIGO FROM "+RetSqlName("ZWK")+" ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWK.ZWK_FILIAL AND ZWKA.ZWK_EMPRES = ZWK.ZWK_EMPRES "+CHR(13)+CHR(10)
		cQStat += "		AND ZWKA.ZWK_DEPOSI = ZWK.ZWK_DEPOSI AND ZWKA.ZWK_CODIGO = ZWK.ZWK_CODIGO AND ZWKA.ZWK_PROCES = ZWK.ZWK_PROCES AND ZWKA.ZWK_SITUAC = '3' AND ZWKA.ZWK_STATUS = '09') "+CHR(13)+CHR(10)
		cQStat += "		OR (ZWI_SITUAC = '68' AND ZWI_STATUS = '06')) "+CHR(13)+CHR(10)
	EndIf	
	
	cQStat += "		GROUP BY ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO, ZWK_STATUS, ZWL_STATUS, ZWI_STATUS, ZWJ_STATUS "+CHR(13)+CHR(10)
	cQStat += "		) TMP "+CHR(13)+CHR(10)
	cQStat += "GROUP BY ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO "+CHR(13)+CHR(10)
	cQStat += "HAVING MIN(STENTRADA) = '"+cStatEnt+"' AND MIN(STSAIDA) = '"+cStatSai+"' "+CHR(13)+CHR(10)
	
	If Select(cTmpStat) > 0
		(cTmpStat)->(DbCloseArea())
	EndIf
	
	cQStat := ChangeQuery(cQStat)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQStat),cTmpStat)	
	
	While !(cTmpStat)->(EOF())				
		//If cStatEnt == (cTmpStat)->STATENTRA .AND. cStatSai == (cTmpStat)->STATSAIDA
			lRet := .T.
			Begin Transaction
				DbSelectArea("ZWK")
				DbSetOrder(1) //ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO
				If ZWK->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
					While !ZWK->(EOF()) .AND. (cTmpStat)->FILIAL == ZWK->ZWK_FILIAL .AND. (cTmpStat)->EMPRESA == ZWK->ZWK_EMPRES .AND. (cTmpStat)->FILWIS == ZWK->ZWK_DEPOSI .AND. (cTmpStat)->CODIGO == ZWK->ZWK_CODIGO
						WWSTATUS("ZWK", ZWK->(RECNO()), "50")
						ZWK->(DbSkip())
					EndDo 
					
					DbSelectArea("ZWL")
					DbSetOrder(1) //ZWL_FILIAL, ZWL_EMPRES, ZWL_CODIGO, ZWL_ITEM
					If ZWL->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
						While !ZWL->(EOF()) .AND. ZWL->ZWL_FILIAL = (cTmpStat)->FILIAL .AND. (cTmpStat)->EMPRESA == ZWL->ZWL_EMPRES .AND. (cTmpStat)->FILWIS == ZWL->ZWL_DEPOSI .AND. ZWL->ZWL_CODIGO = (cTmpStat)->CODIGO
							WWSTATUS("ZWL", ZWL->(RECNO()), "50")
							ZWL->(DbSkip())					
						EndDo
					EndIf

					DbSelectArea("ZWI")
					DbSetOrder(1) //ZWI_FILIAL, ZWI_EMPRES, ZWI_CODIGO					
					If ZWI->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
						While !ZWI->(EOF()) .AND. ZWI->ZWI_FILIAL  == (cTmpStat)->FILIAL .AND. ZWI->ZWI_EMPRES == (cTmpStat)->EMPRESA .AND. (cTmpStat)->FILWIS == ZWI->ZWI_DEPOSI .AND. ZWI->ZWI_CODIGO == (cTmpStat)->CODIGO
							WWSTATUS("ZWI", ZWI->(RECNO()), "50")
							ZWI->(DbSkip())
						EndDo 
					
						DbSelectArea("ZWJ")
						DbSetOrder(1) //ZWJ_FILIAL, ZWJ_EMPRES, ZWJ_CODIGO, ZWJ_ITEM
						If ZWJ->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
							While !ZWJ->(EOF()) .AND. ZWJ->ZWJ_FILIAL = (cTmpStat)->FILIAL .AND. ZWJ->ZWJ_EMPRES = (cTmpStat)->EMPRESA .AND. (cTmpStat)->FILWIS == ZWJ->ZWJ_DEPOSI .AND. ZWJ->ZWJ_CODIGO = (cTmpStat)->CODIGO
								WWSTATUS("ZWJ", ZWJ->(RECNO()), "50")
								ZWJ->(DbSkip())					
							EndDo
						EndIf
					EndIf
				EndIf
			End Transaction						
		//EndIf
		(cTmpStat)->(DbSkip())
	EndDo
EndIf

If Select(cTmpStat) > 0
	(cTmpStat)->(DbCloseArea())
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWPFW

Rotina para integração PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  11/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

Static Function WIIWPFW(cInterface, cOrigem, cProcess, cStatus, cSituac)

Local aArea			:= GetArea()
Local lRet				:= .T.
Local nHndERP 		:= AdvConnection() 	// Salva a Conexão atual (SQL - Protheus)
Local cDBOra  		:= "" //"ODBC/WISHML"		// Nome da ODBC 
Local cSrvOra 		:= "" //"172.16.0.110"
Local nPorta			:= 0
Local nHndOra 		:= -1
Local cQuery  		:= ""
Local cCampos			:= ""
Local aCampos			:= ""
Local cValores		:= ""
Local nX				:= 0
Local nY				:= 0
Local cQDados			:= ""
Local cTmpDados		:= GetNextAlias()
Local nPosTipo		:= 5
Local nPosIPad		:= 3
Local aOpcoes			:= {}
Local lIntegra		:= .F.
Local cEmp				:= cDefEWis //"1"
Local cFilWIS			:= cDefFWis //"001"
Local cErro 			:= ""
Local lGrvLogOk		:= GetMv("MV_ZZWMSLT",, .T.)
Local cWISBd			:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
Local cWISAlias		:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cLogWis			:= ""
Local lCadOk			:= .T.
Local lVldCad			:= GetMv("MV_ZZWVCAD",, .F.)
Local xValTmp
Local cIntCod			:= ""
Local cIntItem		:= ""	

Default cInterface	:= ""
Default cOrigem		:= "" 
Default cProcess		:= "ZZZ"
Default cStatus		:= "01"
Default cSituac		:= "1"

If U_GETZPA("TIPO_ACESSO_WIS","ZZ") = "WISHML"  //WISHML ou WIS
	cDBOra  	:= "ORACLE/"+U_GETZPA("TIPO_ACESSO_WIS","ZZ")
	cSrvOra 	:= GetMv("ZZ_WISERVH")
	nPorta		:= GetMv("ZZ_WISPORH")
Else
	cDBOra  	:= "ORACLE/"+U_GETZPA("TIPO_ACESSO_WIS","ZZ")
	cSrvOra 	:= GetMv("ZZ_WISERV")
	nPorta		:= GetMv("ZZ_WISPORT")
Endif


If !EMPTY(cInterface) 

	If cOrigem == "1" //Protheus
	
		cCampos 	:= WW01GCPO(1, cInterface, cOrigem)
		aCampos 	:= WW01GCPO(3, cInterface, cOrigem)
		
		If ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
	
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ZWL.R_E_C_N_O_ AS ZWLREC, ZWL_PEDORI AS PEDIDO, * "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWK_FILIAL = ZWL_FILIAL AND ZWK_EMPRES = ZWL_EMPRES AND ZWK_CODIGO = ZWL_CODIGO AND ZWK_SITUAC = ZWL_SITUAC AND ZWL_PROCES = ZWK_PROCES AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_CALIAS IN ('SC6') "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)			
		
		ElseIf ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA" 

			//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZWK_OBSERV)),'') AS ZWK_OBSERV, ZWK_PEDORI AS PEDIDO, * "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_CALIAS IN ('SC5') "+CHR(13)+CHR(10)			
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)			
			cQDados += "AND ZWK_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)		
			cQDados += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)			
			//Verifica se nAo existe nenhum item nAo integrado com o WIS
			cQDados += "AND (	SELECT COUNT(*) QTDZWL "+CHR(13)+CHR(10)
			cQDados += "		FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "		WHERE ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_CALIAS IN ('SC6') "+CHR(13)+CHR(10)			
			cQDados += "		AND ZWL_EMPRES = ZWK_EMPRES "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_DEPOSI = ZWK_DEPOSI "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_FILIAL = ZWK_FILIAL "+CHR(13)+CHR(10)			
			cQDados += "		AND ZWL_CODIGO = ZWK_CODIGO "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_SITUAC = ZWK_SITUAC "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_PROCES = ZWK_PROCES "+CHR(13)+CHR(10)
			cQDados += "		AND (ZWL_STATUS <= '"+cStatus+"' OR ZWL_STATUS > '50') "+CHR(13)+CHR(10)
			cQDados += "		) = 0 "+CHR(13)+CHR(10)
						
		EndIf
		
		cQDados := ChangeQuery(cQDados)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)
	
		// Cria uma conexão com um outro banco, outro DBAcces
		nHndOra := TcLink(cDbOra, cSrvOra, nPorta)
		If nHndOra >= 0
	
			While !(cTmpDados)->(Eof())
				
				Begin Transaction

					TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)
					
					//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
					If ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL" .OR. ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
						cIntCod	:= (cTmpDados)->ZWL_CODIGO
						cIntItem	:= (cTmpDados)->ZWL_ITEM
					Else
						cIntCod	:= (cTmpDados)->ZWK_CODIGO
						cIntItem	:= ""		
					EndIf
					
					If !U_W1INSWIS(cInterface, cEmp, cFilWis, cSituac, cIntCod, cIntItem) //Registro ainda nAo foi integrado			
														
						If lVldCad
							//TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)
						
							If ALLTRIM(cInterface) == "INT_E_CAB_NOTA_FISCAL"
							
								If !WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									U_RWISTCAD(3, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
								EndIf
								
								If !WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									lCadOk := .F.
									cErro 	:= "O FORNECEDOR "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
								EndIf

							ElseIf ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"

								If !WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									U_RWISTCAD(3, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									
									If !WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										lCadOk := .F.
										cErro 	:= "O FORNECEDOR "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
									EndIf
								EndIf
							
								If lCadOk
									If !WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
										U_RWISTCAD(1, ALLTRIM((cTmpDados)->ZWL_PRODUT))
									
										If !WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
											lCadOk := .F.
											cErro 	:= "O PRODUTO "+ALLTRIM((cTmpDados)->ZWL_PRODUT)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									EndIf
								EndIf
							
							ElseIf ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA"
							
								If !WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									U_RWISTCAD(2, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									If !WWIS1CLI((cTmpDados)->ZWK_EMPRES, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_CLIFOR)
										lCadOk := .F.
										cErro 	:= "O CLIENTE "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
									EndIf
								EndIf
							
								If lCadOk
									If !WWIS1TRS(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CODTRA))
										U_RWISTCAD(4, ALLTRIM((cTmpDados)->ZWK_CODTRA))
									EndIf
									
									If !WWIS1TRS(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CODTRA))
										lCadOk := .F.
										cErro 	:= "A TRANSPORTADORA "+ALLTRIM((cTmpDados)->ZWK_CODTRA)+" NÃO FOI LOCALIZADA NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
									EndIf
								EndIf
							
							ElseIf ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
							
								If !WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									U_RWISTCAD(2, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									
									If !WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										lCadOk := .F.
										cErro 	:= "O CLIENTE "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
									EndIf
								EndIf
							
								If lCadOk
									If !WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
										U_RWISTCAD(1, ALLTRIM((cTmpDados)->ZWL_PRODUT))
									
										If !WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
											lCadOk := .F.
											cErro 	:= "O PRODUTO "+ALLTRIM((cTmpDados)->ZWL_PRODUT)+" NÃO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									EndIf
								EndIf
							
							EndIf
						EndIf
					
						If lCadOk					
											
							lIntegra	:= .F.
							cErro 		:= ""
							cLogWis	:= ""
													
							//cQuery := "INSERT INTO [WISHML]..[WIS50].["+cInterface+"] "
							cQuery := "INSERT INTO "+cWISAlias+"."+cInterface+" "
							cQuery += "("+cCampos+") "			
							cQuery += "VALUES "			
							
							cValores 	:= "("
							xValTmp	:= NIL
											
							For nX:= 1 to Len(aCampos)
							
								If nX > 1
									cValores += ","
								EndIf
								
								xValTmp := (cTmpDados)->&(aCampos[nX][1])
								
								If Empty(xValTmp) .AND. !Empty(aCampos[nX][nPosIPad]) //Inicializador Padrão
									xValTmp := aCampos[nX][nPosIPad]
								//Else
									//xValTmp := (cTmpDados)->&(aCampos[nX][1])
								EndIf						
								
								If !EMPTY(aCampos[nX][8]) //Opções do campo							
									aOpcoes := StrTokArr(aCampos[nX][8], ";")
									
									For nY := 1 to Len(aOpcoes)
										If ALLTRIM(xValTmp) == ALLTRIM(SUBSTR(aOpcoes[ny], 1, (AT("=", aOpcoes[ny])-1)))
											xValTmp := SUBSTR(aOpcoes[ny], (AT("=", aOpcoes[ny])+1), LEN(aOpcoes[ny]))
											Exit
										EndIf
									Next 
								EndIf		
								
								If aCampos[nX][nPosTipo] == "1" //Caracter
									If Valtype(xValTmp) == "N"
										If !EMPTY(aCampos[nX][6])
											xValTmp := STR(xValTmp,aCampos[nX][6], aCampos[nX][7])
										Else
											xValTmp := cValtoChar(xValTmp)
										EndIf
									EndIf
								ElseIf aCampos[nX][nPosTipo] == "2" //Numerico
									If Valtype(xValTmp) == "C"
										xValTmp := STR(Val(xValTmp),aCampos[nX][6], aCampos[nX][7])
									Else
										xValTmp := STR(xValTmp,aCampos[nX][6], aCampos[nX][7])
									EndIf
								ElseIf aCampos[nX][nPosTipo] == "3" //Data
									If !EMPTY(aCampos[nX][nPosIPad])
										xValTmp := "TO_DATE('"+StrZero(Year(dDataBase),4)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(day(dDataBase),2)+" "+Time()+"', 'yyyy/mm/dd hh24:mi:ss')"
									Else
										If Valtype(xValTmp) == "C" .AND. !EMPTY(xValTmp) //.AND. EMPTY(aCampos[nX][nPosIPad])
											xValTmp := "TO_DATE('"+xValTmp+" 00:00:00', 'yyyymmdd hh24:mi:ss')"
										EndIf
									EndIf				
								EndIf
								
								//Allan Constantino Bonfim - 29/05/2018 - Tratamento para não enviar o código do romaneio nos pedidos
								If cProcess == "030"
									If ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
										If ALLTRIM(aCampos[nX][1]) $ "ZWK_CARGA/ZWL_CARGA"
											xValTmp := ALLTRIM((cTmpDados)->PEDIDO)
										EndIf
									EndIf
								EndIf
								
								If EMPTY(xValTmp) .AND. aCampos[nX][4] == "1" //Campo obrigatório em branco
									xValTmp := aCampos[nX][nPosIPad]
								EndIf
								
								//Allan Constantino Bonfim - 05/09/2018 - Projeto WMS 100% - Correção para a retirada do apostrofo - evitando erro no insert com o WIS.								//Allan Constantino Bonfim - Projeto WMS 100% - Correção para a retirada do apostrofo - evitando erro no insert com o WIS.
								If aCampos[nX][nPosTipo] == "1"
									xValTmp := STRTRAN(xValTmp, "'", " ")
								EndIf
																												
								If EMPTY(xValTmp)
									cValores += "NULL"
								ElseIf aCampos[nX][nPosTipo] == "1"
									cValores += "'"+ALLTRIM(xValTmp)+"'"
								ElseIf EMPTY(Val(xValTmp)) 
									If aCampos[nX][4] == "1" //Obrigatório
										cValores += ALLTRIM(xValTmp)
									Else
										cValores += "NULL"
									EndIf
								Else 
									cValores += ALLTRIM(xValTmp)
								EndIf												
							Next 
							
							cValores += ")"
							
							cQuery += cValores 
											
							If TcSetConn(nHndORA)    //Conecta no Banco do Oracle (WIS)						
								If TcSQLExec(cQuery) >= 0 //Executa as Instruçoes do INSERT		
									cQuery := "Commit WORK"
									If TcSQLExec(cQuery) >= 0 //Realiza um Commit
										lIntegra := .T.						
									Else
										cErro 		:= "FALHA NA CONFIRMAÇÃO DA INCLUSÃO DOS DADOS NO BANCO DE DADOS WIS (COMMIT)"
										lIntegra 	:= .F.
									EndIf
								Else
									cErro 		:= "FALHA NA INCLUSÃO DOS DADOS NO BANCO DE DADOS WIS (INSERT)"
									lIntegra 	:= .F.
								EndIf				
							Else
								lIntegra 	:= .F.
								cErro 		:= "FALHA NA CONEXÂO COM BANCO DE DADOS WIS - "+cDbOra+" (SET CONNECTION)"						
							EndIf		
						Else
							lIntegra := .F.					
						EndIf
					Else
						lIntegra := .T. //Já integrou anteriormente - só atualiza o status					
					EndIf
					
					TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)
												
					If lIntegra
						
						If ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"
							If cStatus == "07"
								WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "08")
								If lGrvLogOk							
									//U_WIIWLOG("ZWL", 3,, (cTmpDados)->ZWLREC, (cTmpDados)->ZWL_CODIGO, (cTmpDados)->ZWL_ITEM, "WIIWPFW", ALLTRIM(cInterface),,,, "08")
								EndIf							
							Else
								WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "02")
								If lGrvLogOk									
									//U_WIIWLOG("ZWL", 3,, (cTmpDados)->ZWLREC, (cTmpDados)->ZWL_CODIGO, (cTmpDados)->ZWL_ITEM, "WIIWPFW", ALLTRIM(cInterface),,,, "02")
								EndIf
							EndIf				
						Else
							If cStatus == "07"
								WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "08")
								If lGrvLogOk							
									//U_WIIWLOG("ZWK", 3,, (cTmpDados)->ZWKREC, (cTmpDados)->ZWK_CODIGO,, "WIIWPFW", ALLTRIM(cInterface),,,, "08")
								EndIf
							Else
								WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "02")	
								If lGrvLogOk						
									//U_WIIWLOG("ZWK", 3,, (cTmpDados)->ZWKREC, (cTmpDados)->ZWK_CODIGO,, "WIIWPFW", ALLTRIM(cInterface),,,, "02")
								EndIf
							EndIf				
						EndIf

					Else				
								
						If ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"

							If !EMPTY((cTmpDados)->ZWL_INTERF)
								cLogWis := WWIS1LIN(cEmp, (cTmpDados)->ZWL_DEPOSI, (cTmpDados)->ZWL_INTERF)									
							EndIf
							
							If cStatus == "07"
								WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "92")																
								U_WIIWLOG(3,, "ZWL", (cTmpDados)->ZWLREC, (cTmpDados)->ZWL_EMPRES, (cTmpDados)->ZWL_DEPOSI, (cTmpDados)->ZWL_CODIGO, (cTmpDados)->ZWL_ITEM, (cTmpDados)->ZWL_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "92")							
							Else
								WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "98")
								U_WIIWLOG(3,, "ZWL", (cTmpDados)->ZWLREC, (cTmpDados)->ZWL_EMPRES, (cTmpDados)->ZWL_DEPOSI, (cTmpDados)->ZWL_CODIGO, (cTmpDados)->ZWL_ITEM, (cTmpDados)->ZWL_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "98")
							EndIf				
						
						Else
						
							If !EMPTY((cTmpDados)->ZWK_INTERF)
								cLogWis := WWIS1LIN(cEmp, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_INTERF)									
							EndIf
							
							If cStatus == "07"
								WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "92")
								U_WIIWLOG(3,, "ZWK", (cTmpDados)->ZWKREC, (cTmpDados)->ZWK_EMPRES, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_CODIGO,, (cTmpDados)->ZWK_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "92")
							Else						
								WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "98")
								U_WIIWLOG(3,, "ZWK", (cTmpDados)->ZWKREC, (cTmpDados)->ZWK_EMPRES, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_CODIGO,, (cTmpDados)->ZWK_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "98")
							EndIf				
						EndIf
						
					EndIf
				End Transaction
								
				(cTmpDados)->(DbSkip())
			EndDo
			
			TCUnlink(nHndOra)	// Finaliza a conexão TCLINK
		Else
			//UserException("Falha na conexão com " + cDbOra + " em " + cSrvOra)			
			cErro 	:= "FALHA NA CONEXÃO COM BANCO DE DADOS WIS - "+cDbOra+ " em " + cSrvOra+" (TCLINK)"	
			
			If cStatus == "01"
				WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "98")
			EndIf
			
			If !(cTmpDados)->(EOF())
				cDescErro 	:= ""
				cSolucao	:= ""
				
				DbSelectArea("ZWK")
				ZWK->(DbGoTo((cTmpDados)->ZWKREC))
				U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "1", cErro, "ERRO NA INTEGRACAO COM WIS DA TABELA INTEGRADORA", cDescErro, cSolucao, "94")																																					
			EndIf				
		Endif	
	
	ElseIf cOrigem == "2" //WIS
		
		If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA"
			
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWJ_EMPRES AS CD_EMPRESA, NU_INTERFACE, NU_PEDIDO_ORIGEM, ZWJ_CODIGO, ZWJ_ITEM, ZWJ_DEPOSI, ZWJ_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN ["+cWISBd+"]..["+cWISAlias+"].[INT_S_DET_PEDIDO_SAIDA] "+CHR(13)+CHR(10)
			cQDados += "ON (ZWJ_EMPRES = CD_EMPRESA AND ZWJ_DEPOSI = CD_DEPOSITO AND ZWJ_INTERF = NU_INTERFACE) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_CALIAS IN ('SC6') "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmp+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWIS+"' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWJ_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)			
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			
		ElseIf ALLTRIM(cInterface) == "INT_S_CAB_PEDIDO_SAIDA" 
		
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_EMPRES AS CD_EMPRESA, NU_INTERFACE, NU_DOC_ERP, ZWI_CODIGO, ZWI_DEPOSI, ZWI_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN ["+cWISBd+"]..["+cWISAlias+"].[INT_S_CAB_PEDIDO_SAIDA] "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_EMPRES = CD_EMPRESA AND ZWI_DEPOSI = CD_DEPOSITO AND ZWI_INTERF = NU_INTERFACE AND NU_DOC_ERP = ZWI_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_CALIAS IN ('SC5') "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmp+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWIS+"' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWI_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Validar se todos os itens constam com status 05 para processamento. 
			cQDados += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ.ZWJ_CALIAS = ZWI.ZWI_CALIAS AND ZWJ.ZWJ_EMPRES = ZWI.ZWI_EMPRES AND ZWJ.ZWJ_DEPOSI = ZWI.ZWI_DEPOSI AND ZWJ.ZWJ_CODIGO = ZWI.ZWI_CODIGO AND ZWJ.ZWJ_STATUS <> '06') "+CHR(13)+CHR(10)

		EndIf
		
		//cQDados := ChangeQuery(cQDados)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)

		// Cria uma conexão com um outro banco, outro DBAcces
		nHndOra := TcLink(cDbOra, cSrvOra, nPorta)
		If nHndOra >= 0
	
			While !(cTmpDados)->(Eof())
				
				Begin Transaction
					lIntegra	:= .F.
					
					cQuery := "UPDATE WIS50."+cInterface+" "
					cQuery += "SET ID_PROCESSADO = 'S', DT_PROCESSADO = (TO_DATE('"+StrZero(Year(dDataBase),4)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(day(dDataBase),2)+" "+Time()+"', 'yyyy/mm/dd hh24:mi:ss')) "			
					cQuery += "WHERE "
					cQuery += "CD_EMPRESA = "+Alltrim((cTmpDados)->CD_EMPRESA)+" "
					cQuery += "AND NU_INTERFACE = "+Alltrim(cValtoChar((cTmpDados)->NU_INTERFACE))+" "
					
					If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" 
						cQuery += "AND NU_PEDIDO_ORIGEM = '"+Alltrim((cTmpDados)->NU_PEDIDO_ORIGEM)+"' "					
					Else
						cQuery += "AND NU_DOC_ERP = '"+Alltrim((cTmpDados)->NU_DOC_ERP)+"' "
					EndIf
					
					cQuery += "AND ID_PROCESSADO = 'N' "
									
					If TcSetConn(nHndORA)    //Conecta no Banco do Oracle (WIS)
						
						If TcSQLExec(cQuery) >= 0 //Executa as Instruçoes do INSERT		
							lIntegra := .T.						
						Else
							cErro 		:= "FALHA NA ATUALIZAÇÂO DOS DADOS NO BANCO DE DADOS WIS (UPDATE)"
							lIntegra 	:= .F.
						EndIf
				
					Else
						lIntegra 	:= .F.
						cErro 		:= "FALHA NA CONEXÃO COM BANCO DE DADOS WIS - "+cDbOra+" (SET CONNECTION)"	
					EndIf		
							
					TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)					
					
					If lIntegra						
						If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_S_DET_NOTA_FISCAL"
							WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "06")
							If lGrvLogOk							
								//U_WIIWLOG("ZWJ", 3,, (cTmpDados)->ZWJREC, (cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJ_ITEM, "WIIWPFW", ALLTRIM(cInterface),,,, "06")
							EndIf					
						Else
							WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "06")
							If lGrvLogOk								
								//U_WIIWLOG("ZWI", 3,, (cTmpDados)->ZWIREC, (cTmpDados)->ZWI_CODIGO,, "WIIWPFW", ALLTRIM(cInterface),,,, "06")
							EndIf
						EndIf						
					Else
						If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_S_DET_NOTA_FISCAL"						
							If !EMPTY((cTmpDados)->ZWJ_INTERF)
								cLogWis := WWIS1LIN(cEmp, (cTmpDados)->ZWJ_DEPOSI, (cTmpDados)->ZWJ_INTERF)									
							EndIf							
							WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "94")
							U_WIIWLOG(3,, "ZWJ", (cTmpDados)->ZWJREC, (cTmpDados)->ZWJ_EMPRES, (cTmpDados)->ZWJ_DEPOSI, (cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJ_ITEM, (cTmpDados)->ZWJ_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "94")				
						Else						
							If !EMPTY((cTmpDados)->ZWI_INTERF)
								cLogWis := WWIS1LIN(cEmp, (cTmpDados)->ZWI_DEPOSI, (cTmpDados)->ZWI_INTERF)									
							EndIf							
							WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "94")
							U_WIIWLOG(3,, "ZWI", (cTmpDados)->ZWIREC, (cTmpDados)->ZWI_EMPRES, (cTmpDados)->ZWI_DEPOSI, (cTmpDados)->ZWI_CODIGO,, (cTmpDados)->ZWI_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")",, "94")				
						EndIf		
					EndIf
				End Transaction
								
				(cTmpDados)->(DbSkip())
			EndDo
			
			TCUnlink(nHndOra)	// Finaliza a conexão TCLINK			
		Else
			//UserException("Falha na conexão com " + cDbOra + " em " + cSrvOra)			
			cErro 	:= "FALHA NA CONEXAO COM BANCO DE DADOS WIS - "+cDbOra+ " em " + cSrvOra+" (TCLINK)"	
			
			WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "94")
			
			If (cTmpDados)->(EOF())				
				U_WIIWLOG(3,, "ZWI",,,,,,, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro,,, "94")
			Else
				U_WIIWLOG(3,, "ZWI", (cTmpDados)->ZWIREC,,, (cTmpDados)->ZWI_CODIGO,,, "WIIWPFW", ALLTRIM(cInterface), "0", cErro, cErro,,, "94")			
			EndIf	
		Endif	
	EndIf		
EndIf

TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)

If Select(cTmpDados) > 0
	(cTmpDados)->(DbCloseArea())
EndIf

RestArea(aArea)
				
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWSTATUS

Atualização do Status

@author Allan Constantino Bonfim
@since  25/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

Static Function WWSTATUS(cTabela, nRecno, cStatus)

Local aCabec		:= {}
Local aItens		:= {}
Local aLinha		:= {}
//Local cProcess	:= ""
//Local cTpDoc		:= "" 
Local cTabCab		:= ""
Local lRecSta		:= IIF(nRecno == 1, .T., .F.)

Default cTabela	:= ""
Default cStatus	:= ""
Default nRecno	:= 0

If cTabela == "ZWL"

	If !EMPTY(nRecno)	
		DbSelectArea("ZWL")
		ZWL->(DbGoto(nRecno))

		If lRecSta	
			Reclock("ZWL", .F.)
				
				ZWL->ZWL_STATUS := cStatus
				
				If cStatus $ "02/08"
					ZWL->ZWL_DTINTE 	:= dDatabase
					ZWL->ZWL_HRINTE	:= SUBSTR(TIME(),1, 5)
				ElseIf cStatus $ "03/09"
					ZWL->ZWL_DTPROC 	:= dDatabase
					ZWL->ZWL_IDPROC	:= "S"						
				EndIf						
			
			ZWL->(MsUnlock())		
		
		Else
		
			cTabCab	:= "ZWK"

			//aCabec
			AADD(aCabec, {"ZWK_FILIAL"	, ZWL->ZWL_FILIAL, Nil})
			AADD(aCabec, {"ZWK_CODIGO"	, ZWL->ZWL_CODIGO, Nil})
			AADD(aCabec, {"ZWK_EMPRES"	, ZWL->ZWL_EMPRES, Nil})								
			AADD(aCabec, {"ZWK_PROCES"	, ZWL->ZWL_PROCES, Nil})		
			AADD(aCabec, {"ZWK_SITUAC"	, ZWL->ZWL_SITUAC, Nil})		
	
			//aItens
			aLinha	:= {}
			AADD(aLinha, {"LINPOS"		, "ZWL_ITEM+ZWL_SITUAC", ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC})
			AADD(aLinha, {"AUTDELETA"	, "N",Nil})
			AADD(aLinha, {"ZWL_STATUS"	, cStatus, Nil})
	
			If cStatus $ "02/08"
				AADD(aLinha, {"ZWL_DTINTE"	, dDatabase, Nil})
				AADD(aLinha, {"ZWL_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})	
			ElseIf cStatus $ "03/09"
				AADD(aLinha, {"ZWL_IDPROC"	, "S", Nil})
				AADD(aLinha, {"ZWL_DTPROC"	, dDatabase, Nil})	
			EndIf				
			
			AADD(aItens,aLinha)			
		
		Endif			
	EndIf
				
ElseIf cTabela == "ZWK"

	If !EMPTY(nRecno)
		DbSelectArea("ZWK")
		ZWK->(DbGoto(nRecno))

		If lRecSta
		
			Reclock("ZWK", .F.)
				
				ZWK->ZWK_STATUS := cStatus
				
				If cStatus $ "02/08"
					ZWK->ZWK_DTINTE 	:= dDatabase
					ZWK->ZWK_HRINTE	:= SUBSTR(TIME(),1, 5)
				ElseIf cStatus $ "03/09"
					ZWK->ZWK_DTPROC 	:= dDatabase
					ZWK->ZWK_IDPROC	:= "S"						
				EndIf		
			
			ZWK->(MsUnlock())
		
		Else		
		
			cTabCab	:= "ZWK"

			//aCabec
			AADD(aCabec, {"ZWK_FILIAL"	, ZWK->ZWK_FILIAL, Nil})
			AADD(aCabec, {"ZWK_CODIGO"	, ZWK->ZWK_CODIGO, Nil})
			AADD(aCabec, {"ZWK_EMPRES"	, ZWK->ZWK_EMPRES, Nil})					
			AADD(aCabec, {"ZWK_PROCES"	, ZWK->ZWK_PROCES, Nil})						
			AADD(aCabec, {"ZWK_SITUAC"	, ZWK->ZWK_SITUAC, Nil})
			AADD(aCabec, {"ZWK_STATUS"	, cStatus, Nil})
			
			If cStatus $ "02/08"
				AADD(aCabec, {"ZWK_DTINTE"	, dDatabase, Nil})
				AADD(aCabec, {"ZWK_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})
			ElseIf cStatus $ "03/09"
				AADD(aCabec, {"ZWK_IDPROC"	, "S", Nil})
				AADD(aCabec, {"ZWK_DTPROC"	, dDatabase, Nil})
			EndIf		
		
		EndIf
	EndIf				

ElseIf cTabela == "ZWI"

	If !EMPTY(nRecno)
		DbSelectArea("ZWI")
		ZWI->(DbGoto(nRecno))
		
		If lRecSta
			Reclock("ZWI", .F.)
				
				ZWI->ZWI_STATUS := cStatus
				
				If cStatus == "05"
					ZWI->ZWI_DTINTE 	:= dDatabase
					ZWI->ZWI_HRINTE	:= SUBSTR(TIME(),1, 5)
				ElseIf cStatus == "06"
					ZWI->ZWI_IDPROC	:= "S"
					ZWI->ZWI_DTPROC	:= dDatabase					
				EndIf				
			
			ZWI->(MsUnlock())
			
			
		Else
					
			cTabCab	:= "ZWI"

			//aCabec
			AADD(aCabec, {"ZWI_FILIAL"	, ZWI->ZWI_FILIAL, Nil})
			AADD(aCabec, {"ZWI_CODIGO"	, ZWI->ZWI_CODIGO, Nil})
			AADD(aCabec, {"ZWI_EMPRES"	, ZWI->ZWI_EMPRES, Nil})
			AADD(aCabec, {"ZWI_PROCES"	, ZWI->ZWI_PROCES, Nil})						
			AADD(aCabec, {"ZWI_SITUAC"	, ZWI->ZWI_SITUAC, Nil})							
			AADD(aCabec, {"ZWI_STATUS"	, cStatus, Nil})
			
			If cStatus == "05"
				AADD(aCabec, {"ZWI_DTINTE"	, dDatabase, Nil})
				AADD(aCabec, {"ZWI_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})
			ElseIf cStatus == "06"
				AADD(aCabec, {"ZWI_IDPROC"	, "S", Nil})
				AADD(aCabec, {"ZWI_DTPROC"	, dDatabase, Nil})
			EndIf
			
		EndIf						
	EndIf		
		
ElseIf cTabela == "ZWJ"

	If !EMPTY(nRecno)
		DbSelectArea("ZWJ")
		ZWJ->(DbGoto(nRecno))
		
		If lRecSta
		
			Reclock("ZWJ", .F.)
				
				ZWJ->ZWJ_STATUS := cStatus
				
				If cStatus == "05"
					ZWJ->ZWJ_DTINTE 	:= dDatabase
					ZWJ->ZWJ_HRINTE	:= SUBSTR(TIME(),1, 5)
				ElseIf cStatus == "06"
					ZWJ->ZWJ_IDPROC	:= "S"
					ZWJ->ZWJ_DTPROC	:= dDatabase					
				EndIf				
			
			ZWJ->(MsUnlock())
			
		Else	
	
			cTabCab	:= "ZWI"				

			//aCabec
			AADD(aCabec, {"ZWI_FILIAL"	, ZWJ->ZWJ_FILIAL, Nil})
			AADD(aCabec, {"ZWI_CODIGO"	, ZWJ->ZWJ_CODIGO, Nil})
			AADD(aCabec, {"ZWI_EMPRES"	, ZWJ->ZWJ_EMPRES, Nil})					
			AADD(aCabec, {"ZWI_PROCES"	, ZWJ->ZWJ_PROCES, Nil})						
			AADD(aCabec, {"ZWI_SITUAC"	, ZWJ->ZWJ_SITUAC, Nil})
	
			//aItens
			aLinha	:= {}
			//AADD(aLinha, {"LINPOS"		, "ZWJ_ITEM", ZWJ->ZWJ_ITEM})
			AADD(aLinha, {"LINPOS"		, "ZWJ_ITEM+ZWJ_INTERF", ZWJ->ZWJ_ITEM, ZWJ->ZWJ_INTERF}) //Considerar a interface pois o item pode voltar duplicado do WIS (Quebrado)
			AADD(aLinha, {"AUTDELETA"	, "N",Nil})
			AADD(aLinha, {"ZWJ_STATUS"	, cStatus})
	
			If cStatus == "05"
				AADD(aLinha, {"ZWJ_DTINTE"	, dDatabase})
				AADD(aLinha, {"ZWJ_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})
			ElseIf cStatus == "06"
				AADD(aLinha, {"ZWJ_IDPROC"	, "S"})
				AADD(aLinha, {"ZWJ_DTPROC"	, dDataBase, Nil})					
			EndIf				
			AADD(aItens,aLinha)
		
		EndIf 				
	EndIf
			
EndIf

If Len(aCabec) > 0 
	If cTabCab == "ZWK"
		U_WIIWSAI(cTabCab, 4, aCabec, aItens)
	EndIf
EndIf
	
Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WW01GCPO

Rotina para integração PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  11/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

Static Function WW01GCPO(nRet, cInterface, cOrigem, cCampo)

Local xRet
Local cQuery  		:= ""
Local cAliasCpo 		:= GetNextAlias()

Default nRet			:= 1
Default cInterface	:= ""
Default cOrigem		:= "" 
Default cCampo		:= ""

If nRet == 3
	xRet := {}
Else
	xRet := ""
EndIf

If !EMPTY(cInterface)
	cQuery := "SELECT ZWN_DE, ZWN_PARA, ZWN_INIPAD, ZWN_OBRIGA, ZWN_TIPO, ZWN_TAMANH, ZWN_DECIMA, ZWN_INIPAD, ZWN_OPCOES "+CHR(13)+CHR(10) 
	cQuery += "FROM "+RetSqlName("ZWM")+" ZWM (NOLOCK) "+CHR(13)+CHR(10) 
	cQuery += "INNER JOIN "+RetSqlName("ZWN")+" ZWN (NOLOCK) "+CHR(13)+CHR(10)
	cQuery += "ON (ZWM_FILIAL = ZWN_FILIAL AND ZWM_INTERF = ZWN_INTERF AND ZWM_ORIGEM = ZWN_ORIGEM AND ZWN.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
	cQuery += "WHERE "+CHR(13)+CHR(10)
	cQuery += "ZWM.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQuery += "AND ZWM_FILIAL = '"+xFilial("ZWM")+"' "+CHR(13)+CHR(10)
	cQuery += "AND ZWM_MSBLQL <> '1' "+CHR(13)+CHR(10)
	cQuery += "AND ZWM_ORIGEM = '"+cOrigem+"' "+CHR(13)+CHR(10)
	cQuery += "AND ZWM_INTERF = '"+cInterface+"' "+CHR(13)+CHR(10)
	If !Empty(cCampo)
		cQuery += "AND ZWN_DE = '"+cCampo+"' "+CHR(13)+CHR(10)
	EndIf	
	cQuery += "ORDER BY ZWN_FILIAL, ZWN_INTERF, ZWN_ITEM "

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasCpo) > 0
		(cAliasCpo)->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCpo) 
	
	While !(cAliasCpo)->(Eof())
		
		If 	VALTYPE(xRet) == "C" .AND. !Empty(xRet)
			xRet += ","
		EndIf
		
		If nRet == 2
			xRet += ALLTRIM((cAliasCpo)->ZWN_INIPAD)
		ElseIf nRet == 3
			AADD(xRet, {	ALLTRIM((cAliasCpo)->ZWN_DE),; 
							ALLTRIM((cAliasCpo)->ZWN_PARA),; 
							ALLTRIM((cAliasCpo)->ZWN_INIPAD),; 
							ALLTRIM((cAliasCpo)->ZWN_OBRIGA),; 
							ALLTRIM((cAliasCpo)->ZWN_TIPO),;
							(cAliasCpo)->ZWN_TAMANH,;
							(cAliasCpo)->ZWN_DECIMA,;
							(cAliasCpo)->ZWN_OPCOES})		
		ElseIf nRet == 4
			If !EMPTY((cAliasCpo)->ZWN_PARA)	
				If !Empty((cAliasCpo)->ZWN_INIPAD)
					If (cAliasCpo)->ZWN_TIPO == "2"
						xRet += "'"+ALLTRIM(cValToChar((cAliasCpo)->ZWN_INIPAD)) +"' AS " + ALLTRIM((cAliasCpo)->ZWN_PARA)+" "
					Else
						xRet += "'"+ALLTRIM((cAliasCpo)->ZWN_INIPAD)+"' AS "+ALLTRIM((cAliasCpo)->ZWN_PARA)+" "
					EndIf
				Else
					If !Empty((cAliasCpo)->ZWN_DE)	
						xRet += ALLTRIM((cAliasCpo)->ZWN_DE) +" AS " + ALLTRIM((cAliasCpo)->ZWN_PARA)+" "
					EndIf
				EndIf
			EndIf 		
		Else
			xRet += ALLTRIM((cAliasCpo)->ZWN_PARA)
		EndIf
		
		(cAliasCpo)->(dBSkip())
	EndDo	
EndIf

If Select(cAliasCpo) > 0
	(cAliasCpo)->(DbCloseArea())
EndIf


Return xRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWTSAI

Rotina para teste da Interface de Integração de Saída PROTHEUS -> WIS.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return NIL
/*/
//-------------------------------------------------------------------------------------------------

Static Function WIIWTSAI(nOpcA, nIntegr, cProcess, cTpDoc, aCabec, aItens)

Local aArea		:= GetArea()
Local aLinha		:= {}
Local cQuery 		:= ""
Local cQuery1 	:= ""
Local cAliasQry 	:= GetNextAlias()
Local cItemQry 	:= GetNextAlias()
Local nX			:= 0
Local aStruCab	:= {}
Local aStruZWK	:= {}
Local nPosZWK		:= 0
Local aStruItem	:= {}
Local aStruZWL	:= {}
Local nPosZWL		:= 0
Local cEmp			:= "1" //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
//Local cIntWis		:= IIf(FWCodEmp() == '01', '1', IIF(FWCodEmp() == '02', '2', '0'))
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cLogWis		:= ""
Local cFilWIS		:= cDefFWis //"001"

Default nOpcA		:= 0
Default nIntegr	:= 0 //1=Notas de Entrada 2=Pedidos de Saida
Default cProcess	:= "ZZZ"
Default cTpDoc	:= ""
Default aCabec	:= {}
Default aItens	:= {}


DbSelectArea("ZWK")
DbSelectArea("ZWL")


//INCLUSAO
If nOpcA == 3

	//Montagem do Array aCabec e aItens
	If nIntegr == 2 //PEDIDOS DE VENDAS

		cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
		cQuery += "'"+ xFilial("ZWK") + "' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
		cQuery += "'"+cDefEWis+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
		cQuery += "'"+cDefFWis+"' AS ZWK_DEPOSI, "+CHR(13)+CHR(10) //cQuery += "'999' AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
		cQuery += "'SC5' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
		cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
		cQuery += "C5_FILIAL, "+CHR(13)+CHR(10)
		cQuery += "C5_NUM, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10) 		
		cQuery += "C5_EMISSAO AS ZWK_DATAEN, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
		//cQuery += "' ' AS 'ZWK_SERIE', "+CHR(13)+CHR(10)				
		//cQuery += "' ' AS ZWK_SOLCON, "+CHR(13)+CHR(10)
		cQuery += "COALESCE(A1_END, A2_END) AS ZWK_ENDENT, "+CHR(13)+CHR(10) 
		//cQuery += "' ' AS ZWK_NENDEN, "+CHR(13)+CHR(10) 
		cQuery += "COALESCE(A1_COMPLEM, A2_COMPLEM) AS ZWK_COMENT, "+CHR(13)+CHR(10) 
		cQuery += "COALESCE(A1_BAIRRO, A2_BAIRRO) AS ZWK_BAIENT, "+CHR(13)+CHR(10) 
		cQuery += "COALESCE(A1_MUN, A2_MUN) AS ZWK_MUNENT, "+CHR(13)+CHR(10) 
		cQuery += "COALESCE(A1_EST, A2_EST) AS ZWK_UFENTR, "+CHR(13)+CHR(10)
		cQuery += "COALESCE(A1_CEP, A2_CEP) AS ZWK_CEPENT, "+CHR(13)+CHR(10) 
		cQuery += "COALESCE((A1_DDD+A1_TEL), (A2_DDD+A2_TEL)) AS ZWK_TELENT, "+CHR(13)+CHR(10) 
		cQuery += "'01' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
		cQuery += "'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10)		
		cQuery += "DAK_TRANSP AS ZWK_CODTRA, "+CHR(13)+CHR(10)
		cQuery += "A4_NOME AS ZWK_TRANSP, "+CHR(13)+CHR(10)
		cQuery += "A4_CGC AS ZWK_CNPJTR, "+CHR(13)+CHR(10)
		cQuery += "(C5_CLIENTE+C5_LOJACLI) AS ZWK_CLIFOR, "+CHR(13)+CHR(10)
		cQuery += "C5_EMISSAO AS ZWK_DTEMIS, "+CHR(13)+CHR(10)
		cQuery += "COALESCE(A1_CGC, A2_CGC) AS ZWK_CNPJCF, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_PLACA, "+CHR(13)+CHR(10)	
		cQuery += "'1' AS ZWK_SITUAC, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_TIPONF, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_CDRAV, "+CHR(13)+CHR(10)
		cQuery += "'00000' AS ZWK_PORTA, "+CHR(13)+CHR(10)
		cQuery += "C5_NUM AS ZWK_PEDORI, "+CHR(13)+CHR(10)
		cQuery += "COALESCE(A1_NOME, A2_NOME) AS ZWK_NOMCEN, "+CHR(13)+CHR(10)
		cQuery += "COALESCE(A1_NOME, A2_NOME) AS ZWK_NOMCLI, "+CHR(13)+CHR(10)
		cQuery += "'"+cTpDoc+"' AS ZWK_TIPOPV, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_DESTPV, "+CHR(13)+CHR(10)
		cQuery += "C5_ZZVTOT AS ZWK_VLNOTA, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_SEQENT, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_CANAL, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_DCANAL, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_ROTA, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_DROTA, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_PONCLI, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_OBJPOS, "+CHR(13)+CHR(10)
		
		//If !cProcess == "030"
			//cQuery += "NULL AS ZWK_CARGA, "+CHR(13)+CHR(10)
		//Else
			cQuery += "DAK_COD AS ZWK_CARGA, "+CHR(13)+CHR(10)
		//EndIf
				
		//cQuery += "(SELECT COUNT(DISTINCT C9_PEDIDO) AS QTDCAR FROM " +RetSqlName("SC9")+ " SC9QTD WHERE SC9QTD.C9_ZROMAN = SC9.C9_ZROMAN AND SC9QTD.D_E_L_E_T_ = ' ' GROUP BY SC9QTD.C9_ZROMAN) AS ZWK_QTDCAR, "+CHR(13)+CHR(10)
		cQuery += "(SELECT COUNT(DISTINCT DAI_PEDIDO) AS QTDCAR FROM " +RetSqlName("DAI")+ " DAI (NOLOCK) WHERE DAI.D_E_L_E_T_ = ' ' AND DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD) AS ZWK_QTDCAR, "+CHR(13)+CHR(10)
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10)
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
		cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
		cQuery += "SC5.R_E_C_N_O_ AS ZWK_RECORI, "+CHR(13)+CHR(10)
		cQuery += "DAK.R_E_C_N_O_ AS DAKREC, "+CHR(13)+CHR(10)		
		cQuery += "ZWO_DESCRI AS ZWK_OBSERV, "+CHR(13)+CHR(10) 
		cQuery += "DAK_COD+C5_NUM AS ZWK_SEQINT "+CHR(13)+CHR(10)     			                    	
		cQuery += "FROM " +RetSqlName("SC5")+ " SC5 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("SC6")+ " SC6 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (B1_FILIAL = '"+xFilial("SB1")+ "' AND C6_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
//		cQuery += "INNER JOIN " +RetSqlName("SA1")+ "  SA1  (NOLOCK) "+CHR(13)+CHR(10)	
//		cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+ "' AND C5_CLIENT = A1_COD AND C5_LOJAENT = A1_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("SC9")+ " SC9 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC9.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
		cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (DAK_FILIAL = C9_FILIAL AND DAK_COD = C9_ZROMAN AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 
		cQuery += "INNER JOIN " +RetSqlName("ZWO")+ " ZWO (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWO_FILIAL = '"+xFilial("ZWO")+"' AND ZWO_CODIGO = C5_XWMSPRC AND ZWO.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
		cQuery += "LEFT JOIN "+RetSqlName("SA1")+ " SA1 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+"' AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND C5_TIPO NOT IN ('D','B')) "+CHR(13)+CHR(10)	
		cQuery += "LEFT JOIN "+RetSqlName("SA2")+ " SA2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (A2_FILIAL = '"+xFilial("SA2")+"' AND C5_CLIENTE = A2_COD AND C5_LOJACLI = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' AND C5_TIPO IN ('D','B')) "+CHR(13)+CHR(10)	
		cQuery += "LEFT JOIN " +RetSqlName("SA4")+ " SA4 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (A4_FILIAL = '"+xFilial("SA4")+ "' AND DAK_TRANSP = A4_COD AND SA4.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
		cQuery += "WHERE "+CHR(13)+CHR(10)
		cQuery += "SC5.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND C5_FILIAL = '"+xFilial("SC5")+"' "+CHR(13)+CHR(10)
		cQuery += "AND C9_ZROMAN <> ' ' "+CHR(13)+CHR(10)
		cQuery += "AND (C9_BLEST = ' ' OR C9_BLEST = '10') "+CHR(13)+CHR(10)
		//cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
		cQuery += "AND C5_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
		
		If DAK->(FieldPos("DAK_XWMSIN")) > 0
			cQuery += "AND DAK_XWMSIN <> 'S' "+CHR(13)+CHR(10)
		EndIf
		
		If DAK->(FieldPos("DAK_XWMSOK")) > 0
			cQuery += "AND DAK_XWMSOK = 'S' "+CHR(13)+CHR(10)
		EndIf
		
		cQuery += "AND NOT EXISTS (SELECT * FROM " +RetSqlName("ZWK")+ " ZWK  (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SC5' AND ZWK_RECORI =  SC5.R_E_C_N_O_ AND ZWK_CARGA = DAK_COD) "+CHR(13)+CHR(10)
		
		cQuery := ChangeQuery(cQuery)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	
		While !(cAliasQry)->(Eof())
			
			//aCabec			
			aStruCab := (cAliasQry)->(dBStruct())
			aStruZWK := ZWK->(dBStruct())
			aCabec		:= {}		
			aItens		:= {}
							
			For nX:= 1 to Len(aStruCab)
					
				nPosZWK := ASCAN(aStruZWK, {|x| x[1] == aStruCab[nX][1]})
					
				If nPosZWK > 0
					If aStruZWK[nPosZWK][2] == 'D'		
						TCSetField(cAliasQry, aStruZWK[nPosZWK][1], aStruZWK[nPosZWK][2])
					EndIf
					
					If aStruZWK[nPosZWK][2] == 'C'	
						AADD(aCabec, {aStruCab[nX][1], ALLTRIM((cAliasQry)->&(aStruCab[nX][1])), Nil})
					Else
						AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
					EndIf					
				EndIf
			Next
													
			cQuery1 := "SELECT DISTINCT "+CHR(13)+CHR(10)
			cQuery1 += "'"+ xFilial("ZWL") + "' AS ZWL_FILIAL, "+CHR(13)+CHR(10)
			cQuery1 += "'"+cDefEWis+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
			cQuery1 += "'"+cDefFWis+"' AS ZWL_DEPOSI, "+CHR(13)+CHR(10) //cQuery1 += "'999' AS ZWL_DEPOSI, "+CHR(13)+CHR(10)
			cQuery1 += "'SC6' AS ZWL_CALIAS, "+CHR(13)+CHR(10)
			cQuery1 += "'"+cProcess+"' AS ZWL_PROCES, "+CHR(13)+CHR(10) 			
			cQuery1 += "C6_ITEM AS ZWL_ITEM, "+CHR(13)+CHR(10)
			cQuery1 += "C6_PRODUTO AS ZWL_PRODUT, "+CHR(13)+CHR(10)
			
			//If !cProcess == "030"
				cQuery1 += "DAK_COD AS ZWL_CARGA, "+CHR(13)+CHR(10)
			//EndIf
			
			//cQuery1 += "' ' AS ZWL_LOTE, "+CHR(13)+CHR(10)
			cQuery1 += "'N' AS ZWL_EMBPRE, "+CHR(13)+CHR(10)
			cQuery1 += "C9_QTDLIB AS ZWL_QTSEPA, "+CHR(13)+CHR(10)
			cQuery1 += "'"+(cAliasQry)->ZWK_CNPJCF+"' AS ZWL_CNPJCL, "+CHR(13)+CHR(10)
			cQuery1 += "(C5_CLIENTE+C5_LOJACLI) AS ZWL_CODCLI, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_CAMPAN, "+CHR(13)+CHR(10)
			cQuery1 += "C5_NUM AS ZWL_PEDORI, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_PEDIDO, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_INTPED, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_DTNFE, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_CHVNFE, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_LOTEFO, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_FILL1, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_FILL2, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_FILL3, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_FILL4, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_FILL5, "+CHR(13)+CHR(10)
			cQuery1 += "(C5_CLIENTE+C5_LOJACLI) AS ZWL_CLIFOR, "+CHR(13)+CHR(10)
			cQuery1 += "'"+(cAliasQry)->ZWK_CNPJCF+"' AS ZWL_CNPJCF, "+CHR(13)+CHR(10)
			cQuery1 += "'"+(cAliasQry)->ZWK_SEQINT+"' AS ZWL_SEQINT, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_AGENDA, "+CHR(13)+CHR(10)			
			//cQuery1 += "' ' AS ZWL_NOTA, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_SERIE, "+CHR(13)+CHR(10)
			cQuery1 += "'1' AS ZWL_SITUAC, "+CHR(13)+CHR(10)
			cQuery1 += "C6_QTDVEN AS ZWL_QTDE, "+CHR(13)+CHR(10)
			cQuery1 += "C6_LOCAL AS ZWL_DEPERP, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_DTFABR, "+CHR(13)+CHR(10)
			cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_DTPROC, "+CHR(13)+CHR(10)
			//cQuery1 += "' ' AS ZWL_INTERF, "+CHR(13)+CHR(10)
			cQuery1 += "'01' AS ZWL_STATUS, "+CHR(13)+CHR(10)
			cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10)	
			cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10)		 
			cQuery1 += "SC6RECNO AS ZWL_RECORI "+CHR(13)+CHR(10)
			cQuery1 += "FROM ( "+CHR(13)+CHR(10)
			cQuery1 += "		SELECT C6_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C6_ITEM, C6_PRODUTO, C6_LOCAL, C9_ZROMAN, DAK_COD, SC6.R_E_C_N_O_ AS SC6RECNO, "+CHR(13)+CHR(10) 
			cQuery1 += "		ISNULL(SUM(C6_QTDVEN), 0) AS C6_QTDVEN, ISNULL(SUM(C9_QTDLIB), 0) AS C9_QTDLIB "+CHR(13)+CHR(10)			
			cQuery1 += "		FROM " +RetSqlName("SC5")+ " SC5 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("SC6")+ " SC6 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("SC9")+ " SC9 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC9.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (DAK_FILIAL = C9_FILIAL AND DAK_COD = C9_ZROMAN AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) //AND ZRC_TPCARG = '281' 				
			//cQuery1 += "	INNER JOIN " +RetSqlName("SA1")+ "  SA1  (NOLOCK) "+CHR(13)+CHR(10)	
			//cQuery1 += "	ON (A1_FILIAL = '"+xFilial("SA1")+ "' AND C5_CLIENT = A1_COD AND C5_LOJAENT = A1_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
			cQuery1 += "		INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (B1_FILIAL = '"+xFilial("SB1")+ "' AND C6_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
			cQuery1 += "		WHERE "+CHR(13)+CHR(10)
			cQuery1 += "		SC5.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery1 += "		AND C5_FILIAL = '"+xFilial("SC5")+"' "+CHR(13)+CHR(10)
			//cQuery1 += "	AND C5_EMISSAO > '20180320' "+CHR(13)+CHR(10)
			cQuery1 += "		AND C9_ZROMAN <> ' ' "+CHR(13)+CHR(10)
			cQuery1 += "		AND C6_FILIAL = '"+(cAliasQry)->C5_FILIAL+"' "+CHR(13)+CHR(10)
			//cQuery1 += "		AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			//cQuery1 += "	AND C6_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery1 += "		AND (C9_BLEST = ' ' OR C9_BLEST = '10') "+CHR(13)+CHR(10)			
			cQuery1 += "		AND C6_NUM = '"+(cAliasQry)->C5_NUM+"' "+CHR(13)+CHR(10)			
			cQuery1 += "		AND C9_ZROMAN = '"+(cAliasQry)->ZWK_CARGA+"' "+CHR(13)+CHR(10)									
			cQuery1 += "		AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK  (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SC6' AND ZWK_RECORI =  SC6.R_E_C_N_O_) "+CHR(13)+CHR(10)
			cQuery1 += "		GROUP BY C6_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C6_ITEM, C6_PRODUTO, C6_LOCAL, C9_ZROMAN, DAK_COD, SC6.R_E_C_N_O_ "+CHR(13)+CHR(10)
			cQuery1 += ") TMPSC6 "+CHR(13)+CHR(10)
					
			cQuery1 := ChangeQuery(cQuery1)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
			
			While !(cItemQry)->(Eof())

				//aItens
				aLinha		:= {}
				aStruItem 	:= (cItemQry)->(dBStruct())
				aStruZWL 	:= ZWL->(dBStruct())
															
				For nX:= 1 to Len(aStruItem)
					
					nPosZWL := ASCAN(aStruZWL, {|x| x[1] == aStruItem[nX][1]})
					
					If nPosZWL > 0						
						If aStruZWL[nPosZWL][2] == 'D'
							TCSetField(cItemQry, aStruZWL[nPosZWL][1], aStruZWL[nPosZWL][2])	
						EndIf
				
						If nX == Len(aStruItem) //Ultimo item								
							If aStruZWL[nPosZWL][2] == 'C'	
								AADD(aLinha, {aStruItem[nX][1], ALLTRIM((cItemQry)->&(aStruItem[nX][1])), Nil})
							Else
								AADD(aLinha, {aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1]), Nil})
							EndIf							
						Else
							If aStruZWL[nPosZWL][2] == 'C'	 						
								AADD(aLinha, {aStruItem[nX][1], ALLTRIM((cItemQry)->&(aStruItem[nX][1]))})
							Else
								AADD(aLinha, {aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1])})
							EndIf
						EndIf
					EndIf
				Next
		
				AADD(aItens,aLinha)
				
				(cItemQry)->(DbSkip())
			EndDo
	
			If Len(aCabec) > 0 .AND. Len(aItens) > 0
				If U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
					If DAK->(FieldPos("DAK_XWMSIN")) > 0
						If WW01IPED((cAliasQry)->ZWK_EMPRES, (cAliasQry)->ZWK_CARGA)
							DbSelectArea("DAK")
							DbGoto((cAliasQry)->DAKREC)
							Reclock("DAK", .F.)
								DAK->DAK_XWMSIN := "S"
							DAK->(MsUnlock())
						EndIf				
					EndIf			 
				EndIf
			EndIf
				
			If Select(cItemQry) > 0
				(cItemQry)->(dbCloseArea())
			EndIf
			
			aCabec := {}
			aItens := {}
			
			(cAliasQry)->(DbSkip())
			
		EndDo	
						
	EndIf
									
ElseIf nOpcA == 4

	If nIntegr == 2
		
		cCampos 	:= WW01GCPO(4, "INT_E_CAB_PEDIDO_SAIDA", "2")
		
		If !Empty(cCampos)
		
			Begin Transaction

				cQuery := "SELECT "+CHR(13)+CHR(10)
				cQuery += "ZWK_FILIAL, "+CHR(13)+CHR(10)
				cQuery += "ZWK_EMPRES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CODIGO, "+CHR(13)+CHR(10)
				cQuery += "ZWK_PROCES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CALIAS, "+CHR(13)+CHR(10)
				cQuery += "ZWK_DEPOSI, "+CHR(13)+CHR(10)			
				cQuery += "ZWK_RECORI, "+CHR(13)+CHR(10)
				cQuery += "ZWK.R_E_C_N_O_ AS ZWKREC, "+CHR(13)+CHR(10)		
				cQuery += "NU_PEDIDO_ORIGEM, "+CHR(13)+CHR(10)
				cQuery += "(CASE WHEN ID_PROCESSADO = 'S' THEN '03' ELSE '97' END) AS ZWK_STATUS, "+CHR(13)+CHR(10)
				cQuery += cCampos+" "+CHR(13)+CHR(10)			
				cQuery += "FROM 	( "+CHR(13)+CHR(10)
				cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
				cQuery += "		'SELECT * FROM INT_E_CAB_PEDIDO_SAIDA "+CHR(13)+CHR(10)
				cQuery += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
				cQuery += "		AND CD_DEPOSITO = ''"+cFilWIS+"'' "+CHR(13)+CHR(10)
				cQuery += "		AND DT_PROCESSADO IS NOT NULL "+CHR(13)+CHR(10)
				cQuery += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
				cQuery += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
				cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND ZWK_SITUAC = CD_SITUACAO AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SC5') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
				cQuery += "WHERE "+CHR(13)+CHR(10)
				cQuery += "ZWK_IDPROC = 'N' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_STATUS = '02' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_SITUAC <> '3' "+CHR(13)+CHR(10)
				cQuery += "ORDER BY DT_PROCESSADO "+CHR(13)+CHR(10)
													
				//cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				
				While !(cAliasQry)->(Eof())
							
					aStruCab 	:= (cAliasQry)->(dBStruct())
					aStruZWK 	:= ZWK->(dBStruct())
					aCabec		:= {}		
					aItens		:= {}
								
					For nX:= 1 to Len(aStruCab)						
						nPosZWK := ASCAN(aStruZWK, {|x| x[1] == aStruCab[nX][1]})
							
						If nPosZWK > 0						
							If aStruZWK[nPosZWK][2] <> aStruCab[nX][2]
								If aStruZWK[nPosZWK][2] == "D"
									TCSetField(cAliasQry, aStruZWK[nPosZWK][1], aStruZWK[nPosZWK][2])							
								ElseIf aStruZWK[nPosZWK][2] == "N"
									TCSetField(cAliasQry, aStruZWK[nPosZWK][1], aStruZWK[nPosZWK][2], aStruZWK[nPosZWK][3], aStruZWK[nPosZWK][4])
								EndIf
							EndIf
							
							If aStruZWK[nPosZWK][2] == "C" .AND. ValType((cAliasQry)->&(aStruCab[nX][1])) == "N"
								AADD(aCabec, {aStruCab[nX][1], cValtoChar((cAliasQry)->&(aStruCab[nX][1])), Nil})
							Else
								AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
							EndIf
						EndIf
					Next
	
					If (cAliasQry)->ZWK_STATUS == "97"			
						If !EMPTY((cAliasQry)->ZWK_INTERF)
							cLogWis := WWIS1LIN(cEmp, (cAliasQry)->ZWK_DEPOSI, (cAliasQry)->ZWK_INTERF)									
						EndIf
								
						U_WIIWLOG(3,, "ZWK", (cTmpDados)->ZWKREC,,, (cTmpDados)->ZWK_CODIGO,,, "WIIWPFW", "INT_E_CAB_NOTA_FISCAL", "0", "FALHA NA ATUALIZACAO PROCESSAMENTO WIS", cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")",, (cAliasQry)->ZWK_STATUS)
					EndIf
						
					cCampos 	:= WW01GCPO(4, "INT_E_DET_PEDIDO_SAIDA", "2")
					
					cQuery1 := "SELECT "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_ITEM, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_PROCES, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_CALIAS, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_DEPOSI, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_RECORI, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_SITUAC, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL.R_E_C_N_O_ AS ZWLREC, "+CHR(13)+CHR(10)						
					cQuery1 += "(CASE WHEN ID_PROCESSADO = 'S' THEN '03' ELSE '97' END) AS ZWL_STATUS, "+CHR(13)+CHR(10)
					cQuery1 += cCampos+" "+CHR(13)+CHR(10)				
					cQuery1 += "FROM 	( "+CHR(13)+CHR(10)
					cQuery1 += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
					cQuery1 += "		'SELECT * FROM INT_E_DET_PEDIDO_SAIDA "+CHR(13)+CHR(10)
					cQuery1 += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
					cQuery1 += "		AND CD_DEPOSITO = ''"+cFilWIS+"'' "+CHR(13)+CHR(10)					
					cQuery1 += "		AND NU_PEDIDO_ORIGEM = ''"+ALLTRIM((cAliasQry)->NU_PEDIDO_ORIGEM)+"'' "+CHR(13)+CHR(10)
					cQuery1 += "		AND DT_PROCESSADO IS NOT NULL "+CHR(13)+CHR(10)
					cQuery1 += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
					cQuery1 += "		) TMPWIS "+CHR(13)+CHR(10)				
					cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10) 
					cQuery1 += "ON (ZWL_EMPRES = CD_EMPRESA AND ZWL_SITUAC = CD_SITUACAO AND FILLER_5 = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND NU_ITEM_CORP = ZWL_ITEM COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 				
					cQuery1 += "WHERE "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_IDPROC = 'N' "+CHR(13)+CHR(10)
					cQuery1 += "AND ZWL_IDPROC = 'N' "+CHR(13)+CHR(10)  
					cQuery1 += "AND ZWL_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
					cQuery1 += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
					cQuery1 += "AND ZWL_SITUAC <> '3' "+CHR(13)+CHR(10)
					cQuery1 += "AND ZWL_STATUS = '02' "+CHR(13)+CHR(10) 						
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
						
					While !(cItemQry)->(Eof())
		
						aStruItem 	:= (cItemQry)->(dBStruct())
						aStruZWL 	:= ZWL->(dBStruct())
						aLinha		:= {}
								
						For nX:= 1 to Len(aStruItem)
								
							nPosZWL := ASCAN(aStruZWL, {|x| x[1] == aStruItem[nX][1]})
								
							If nPosZWL > 0
								If nX == 1 //.AND. ALLTRIM(aStruItem[nX][1]) == "ZWL_ITEM"
									AADD(aLinha, {"LINPOS", "ZWL_ITEM+ZWL_SITUAC", (cItemQry)->ZWL_ITEM, (cItemQry)->ZWL_SITUAC})
									AADD(aLinha, {"AUTDELETA", "N", NIL})
								EndIf
								
								If !ALLTRIM(aStruItem[nX][1]) $ "ZWL_CODIGO/ZWL_ITEM"															      
									If aStruZWL[nPosZWL][2] <> aStruItem[nX][2]
										If aStruZWL[nPosZWL][2] == "D"
											TCSetField(cItemQry, aStruZWL[nPosZWL][1], aStruZWL[nPosZWL][2])
										ElseIf aStruZWL[nPosZWL][2] == "N"
											TCSetField(cItemQry, aStruZWL[nPosZWL][1], aStruZWL[nPosZWL][2], aStruZWL[nPosZWL][3], aStruZWL[nPosZWL][4])
										EndIf
									EndIf
														
									If nX == Len(aStruItem) //Ultimo item
										If aStruZWL[nPosZWL][2] == "C" .AND. ValType((cItemQry)->&(aStruItem[nX][1])) == "N"
											AADD(aLinha, {aStruItem[nX][1], cValtoChar((cItemQry)->&(aStruItem[nX][1])), Nil})
										Else
											AADD(aLinha, {aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1]), Nil})
										EndIf
									Else
										If aStruZWL[nPosZWL][2] == "C" .AND. ValType((cItemQry)->&(aStruItem[nX][1])) == "N"
											AADD(aLinha, {aStruItem[nX][1], cValtoChar((cItemQry)->&(aStruItem[nX][1]))})
										Else 						
											AADD(aLinha, {aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1])})
										EndIf
									EndIf
								EndIf
							EndIf					
						Next
						
						AADD(aItens, aLinha)

						If (cItemQry)->ZWL_STATUS == "97"				
							If !EMPTY((cItemQry)->ZWL_INTERF)
								cLogWis := WWIS1LIN(cEmp, (cItemQry)->ZWL_DEPOSI, (cItemQry)->ZWL_INTERF)									
							EndIf
									
							U_WIIWLOG(3,, "ZWL", (cTmpDados)->ZWLREC,,, (cTmpDados)->ZWL_CODIGO,,, "WIIWTSAI", "INT_E_DET_NOTA_FISCAL", "0", "FALHA NA ATUALIZACAO PROCESSAMENTO WIS", cErro, "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")",, (cAliasQry)->ZWL_STATUS)
						EndIf
															
						(cItemQry)->(DbSkip())
					EndDo
					
					If Select(cItemQry) > 0
						(cItemQry)->(DbCloseArea())
					EndIf
					
					If Len(aCabec) > 0
						U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
					EndIf
					
					(cAliasQry)->(DbSkip())				
				EndDo
			
			End Transaction				
		EndIf					
	
	EndIf
	
EndIf

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf

If Select(cItemQry) > 0
	(cItemQry)->(DbCloseArea())
EndIf

RestArea(aArea)

Return 


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1CLI

Rotina para verificação da integração do cadastro de Cliente no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, Lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWIS1CLI(cEmpCli, cFilCli, cCodCli)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpCli	:= cDefEWis //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilCli	:= cDefFWis //PADR(FWCodFil(), 3, "0")   
Default cCodCli	:= ""

If GetNewPar("ZZ_WIS9WIS", .F.) //FWCodEmp() $ "01" .AND. FWCodFil() == "01"
	If !EMPTY(cCodCli)
		//Allan Constantino Bonfim  - 29/10/2018 - CM Solutions - WMS 100% - Ajuste para consumir a view na validação dos cadastros do WIS		
		cQueryWis := "SELECT TOP 1 * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)		 
		cQueryWis += "'SELECT CD_EMPRESA, CD_DEPOSITO, CD_CLIENTE, ID_PROCESSADO "+CHR(13)+CHR(10)		
		cQueryWis += "FROM INT_E_CLIENTE "+CHR(13)+CHR(10)
		cQueryWis += "WHERE "+CHR(13)+CHR(10)
		cQueryWis += "CD_EMPRESA = ''"+cEmpCli+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_DEPOSITO= ''"+cFilCli+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_CLIENTE = ''"+cCodCli+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND ID_PROCESSADO = ''S''') "+CHR(13)+CHR(10)	
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryWis), cAliasWis)
		
		If !(cAliasWis)->(EOF())
			lRet := .T.
		EndIf  
	EndIf
EndIf
	
If Select(cAliasWis) > 0
	(cAliasWis)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1FOR

Rotina para verificação da integração do cadastro de Fornecedor no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, Lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWIS1FOR(cEmpFor, cFilFor, cCodFor)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpFor	:= cDefEWis //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilFor	:= cDefFWis //PADR(FWCodFil(), 3, "0")  
Default cCodFor	:= ""

If GetNewPar("ZZ_WIS9WIS", .F.) //FWCodEmp() $ "01" .AND. FWCodFil() == "01"	
	If !EMPTY(cCodFor)
		//Allan Constantino Bonfim  - 29/10/2018 - CM Solutions - WMS 100% - Ajuste para consumir a view na validação dos cadastros do WIS		
		
		cQueryWis := "SELECT TOP 1 * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)		 
		cQueryWis += "'SELECT CD_EMPRESA, CD_DEPOSITO, CD_FORNECEDOR, ID_PROCESSADO "+CHR(13)+CHR(10)
		cQueryWis += "FROM INT_E_FORNECEDOR "+CHR(13)+CHR(10)		
		cQueryWis += "WHERE "+CHR(13)+CHR(10)
		cQueryWis += "CD_EMPRESA = ''"+cEmpFor+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_DEPOSITO= ''"+cFilFor+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_FORNECEDOR = ''"+cCodFor+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND ID_PROCESSADO = ''S''') "+CHR(13)+CHR(10)		
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryWis), cAliasWis)
		
		If !(cAliasWis)->(EOF())
			lRet := .T.
		EndIf  
	EndIf
EndIf

If Select(cAliasWis) > 0
	(cAliasWis)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1TRS

Rotina para verificação da integração do cadastro de Transportadora no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, Lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWIS1TRS(cEmpTrs, cFilTrs, cCodTrs)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpTrs	:= cDefEWis //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilTrs	:= cDefFWis //PADR(FWCodFil(), 3, "0") 
Default cCodTrs	:= ""

If GetNewPar("ZZ_WIS9WIS", .F.) //FWCodEmp() $ "01" .AND. FWCodFil() == "01"	
	If !EMPTY(cCodTrs)
		//Allan Constantino Bonfim  - 29/10/2018 - CM Solutions - WMS 100% - Ajuste para consumir a view na validação dos cadastros do WIS		
		
		cQueryWis := "SELECT TOP 1 * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)		 
		cQueryWis += "'SELECT CD_EMPRESA, CD_DEPOSITO, CD_TRANSPORTADORA, ID_PROCESSADO "+CHR(13)+CHR(10) 
		cQueryWis += "FROM INT_E_TRANSPORTADORA "+CHR(13)+CHR(10)		
		cQueryWis += "WHERE "+CHR(13)+CHR(10)
		cQueryWis += "CD_EMPRESA = ''"+cEmpTrs+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_DEPOSITO= ''"+cFilTrs+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_TRANSPORTADORA = ''"+cCodTrs+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND ID_PROCESSADO = ''S''') "+CHR(13)+CHR(10)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryWis), cAliasWis)
		
		If !(cAliasWis)->(EOF())
			lRet := .T.
		EndIf  
	EndIf
EndIf

If Select(cAliasWis) > 0
	(cAliasWis)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1PRD

Rotina para verificação da integração do cadastro de Produto no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, Lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWIS1PRD(cEmpPrd, cFilPrd, cCodPrd)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpPrd	:= cDefEWis //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilPrd	:= cDefFWis //PADR(FWCodFil(), 3, "0")
Default cCodPrd	:= ""

If GetNewPar("ZZ_WIS9WIS", .F.) //FWCodEmp() $ "01" .AND. FWCodFil() == "01"	
	If !EMPTY(cCodPrd)
		//Allan Constantino Bonfim  - 29/10/2018 - CM Solutions - WMS 100% - Ajuste para consumir a view na validação dos cadastros do WIS	    
		
		cQueryWis := "SELECT TOP 1 * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)		 
		cQueryWis += "'SELECT CD_EMPRESA, CD_DEPOSITO, CD_PRODUTO, ID_PROCESSADO "+CHR(13)+CHR(10) 
		cQueryWis += "FROM INT_E_PRODUTO "+CHR(13)+CHR(10)		
		cQueryWis += "WHERE "+CHR(13)+CHR(10)
		cQueryWis += "CD_EMPRESA = ''"+cEmpPrd+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_DEPOSITO= ''"+cFilPrd+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_PRODUTO = ''"+cCodPrd+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND ID_PROCESSADO = ''S''') "+CHR(13)+CHR(10)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryWis), cAliasWis)
		
		If !(cAliasWis)->(EOF())
			lRet := .T.
		EndIf  
	EndIf
EndIf

If Select(cAliasWis) > 0
	(cAliasWis)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1LIN

Rotina para verificação do log do processamento da interface no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, Lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWIS1LIN(cEmpInt, cDeposit, cInterf, lTodos)

Local aArea		:= GetArea()
Local cRet			:= ""
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cWisEmp		:= ""

Default cEmpInt	:= cDefEWis //IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cInterf	:= ""
Default lTodos	:= .F.
Default cDeposit	:= cDefFWis //"001"

If GetNewPar("ZZ_WIS9WIS", .F.) //FWCodEmp() $ "01" .AND. FWCodFil() == "01"

	If Valtype(cInterf) == "N"
		cInterf := cValtoChar(cInterf)
	EndIf
	
	cWisEmp := cEmpInt+cDeposit	
	
	If !EMPTY(cInterf)
		
		cQueryWis := "SELECT ISNULL(DS_OBSERVACAO, ' ') AS OBSERV FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
		cQueryWis += "'SELECT NU_INTERFACE, CD_EMPRESA, DS_OBSERVACAO, DT_ADDROW "+CHR(13)+CHR(10) 
		cQueryWis += "FROM T_LOG_INTERFACE "+CHR(13)+CHR(10)
		cQueryWis += "WHERE "+CHR(13)+CHR(10)
		cQueryWis += "NU_INTERFACE = ''"+cInterf+"'' "+CHR(13)+CHR(10)
		cQueryWis += "AND CD_EMPRESA = ''"+cWisEmp+"'' "+CHR(13)+CHR(10)
		cQueryWis += "ORDER BY DT_ADDROW DESC') "+CHR(13)+CHR(10)
		
		If !lTodos
			cQueryWis += "WHERE DATEDIFF(DAY, DT_ADDROW, GETDATE()) = 0 "+CHR(13)+CHR(10)			
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryWis), cAliasWis)
		
		While !(cAliasWis)->(EOF())
			If !EMPTY(cRet)
				cRet += "; "
			EndIf
			
			cRet += ALLTRIM((cAliasWis)->OBSERV)
			
			(cAliasWis)->(DbSkip())
		EndDo		
	EndIf
EndIf
	
RestArea(aArea)

Return cRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WW01IPED

Verifica se todos os pedidos do Romaneio foram integrados.

@author Allan Constantino Bonfim
@since  30/07/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function WW01IPED(cEmpres, cRoman, cAliasInt, cFilWis)

Local lRet			:= .F.
Local cQRoma		:= ""
Local cTmpRoma	:= GetNextAlias()

Default cEmpres	:= cDefEWis //FWCodEmp()
Default cRoman	:= ""
Default cAliasInt	:= "SC5"
Default cFilWis	:= cDefFWis //"001"

If !Empty(cRoman)
	
	cQRoma := "SELECT ZWK_EMPRES, ZWK_CARGA, ZWK_QTDCAR, COUNT(*) AS QTDCARGA "+CHR(13)+CHR(10) 
	cQRoma += "FROM "+RetSqlName("ZWK")+" ZWK (NOLOCK) "+CHR(13)+CHR(10)
	cQRoma += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_CALIAS = '"+ALLTRIM(cAliasInt)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_EMPRES = '"+ALLTRIM(cEmpres)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_CARGA = '"+Alltrim(cRoman)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_SITUAC = '1' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_STATUS < '50' "+CHR(13)+CHR(10)
	cQRoma += "GROUP BY ZWK_EMPRES, ZWK_CARGA, ZWK_QTDCAR "+CHR(13)+CHR(10)
	
	If Select(cTmpRoma) > 0
		(cTmpRoma)->(DbCloseArea())
	EndIf
	
	cQRoma := ChangeQuery(cQRoma)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRoma),cTmpRoma)	
	
	If !(cTmpRoma)->(EOF())
		If (cTmpRoma)->ZWK_QTDCAR == (cTmpRoma)->QTDCARGA
			lRet := .T.
		EndIf	
	EndIf
EndIf

If Select(cTmpRoma) > 0
	(cTmpRoma)->(DbCloseArea())
EndIf

Return lRet
