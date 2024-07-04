#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

#DEFINE ERRO00 "ERRO INDERTEMINADO NA ROTINA DE GRAVACAO DO LOG"
#DEFINE ERRO99 "ERRO NA GERACAO DA TABELA INTEGRADORA DE ENVIO (ZWK/ZWL)"
#DEFINE ERRO98 "ERRO NA INTEGRACAO COM WIS DA TABELA INTEGRADORA"
#DEFINE ERRO97 "ERRO NA ATUALIZACAO DA TABELA INTEGRADORA DE ENVIO APOS A INTEGRACAO COM O WIS" //Verificar
#DEFINE ERRO96 "ERRO NA GERACAO DA TABELA INTEGRADORA DE RETORNO (ZWI/ZWJ)"
#DEFINE ERRO95 "ERRO NO PROCESSAMENTO DO RETORNO DO WIS NO PROTHEUS"
#DEFINE ERRO94 "ERRO NA ATUALIZACAO DA TABELA INTEGRADORA DE RETORNO APOS A INTEGRACAO COM O WIS" //Verificar
#DEFINE ERRO93 "ERRO NA INTEGRACAO - ATUALIZACAO NA TABELA INTEGRADORA PROTHEUS - ATUALIZACAO DO FATURAMENTO DO ROMANEIO(UPDATE ZWK/ZWL)" //Verificar
#DEFINE ERRO92 "ERRO NA INTEGRACAO COM WIS DA TABELA INTEGRADORA - ENVIO ATUALIZACAO DE FATURAMENTO PARA O WIS - SITUACAO 3" //Verificar
#DEFINE ERRO91 "ERRO NA ATUALIZACAO DA TABELA INTEGRADORA DE ATUALIZACAO DE FATURAMENTO APOS A INTEGRACAO COM O WIS - SITUACAO 3"


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS0001

Rotina de integraCAo entre o Protheus e WIS

@author Allan Constantino Bonfim
@since  04/04/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function WWIS0001(aParam)


Local aRet			:= {}
Local cFunExec	:= ""
Local aComboE 	:= {"01=Sanchez"	, "02=Fini"}
Local aComboF 	:= {"01=Matriz"	, "06=CD Fini", "80=Finistore"}
Local aParamBox	:= {}
Local cPerg		:= "WWIS01"
Local aAreaSM0 	:= {}
//Local aTables 	:= {"SA1","SA2","SA4","SB1","SB2","SB8","SF1","SD1","SD3","SD5","SD7","SF2","SD2","DAK","DAI","SC5","SC6","SC9","ZWH","ZWI","ZWJ","ZWH","ZWL","ZWM","ZWN","ZWO"}
Local lTAmbiente 	:= .F.
Local oAppBk
Local cEmp
Local cFil
Local _par01
Local _par02
	
Default aParam	:= {}
//Default _par01 	:= '02'
//Default _par02 	:= '01'
	
If Len(aParam) > 0
	_par01 := aParam[1]
	_par02	:= aParam[2]
Else
	_par01 := '02'
	_par02 := '01'
EndIf


If (Type("oMainWnd") == "O")
	
	AADD(aParamBox,{2,"Empresa: ", 2, aComboE, 100, ".F.", .F. })		// MV_PAR01
	AADD(aParamBox,{2,"Filial:  ", 1, aComboF, 100, ".F.", .F. })		// MV_PAR02
	
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
	_par02 := iif(aRet[2]=='1', '01', iif(aRet[2]=='2', '06', iif(aRet[2]=='3', '80', aRet[2])))
	
	cEmp    := _par01
	cFil    := _par02
	
	If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmp) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFil) $ GetMv("MV_ZZWMSFL",, "01")
		
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
				If ZWO->ZWO_MSBLQL = "2" .AND. ZWO->ZWO_INTWIS = "1"  
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
	//RpcSetEnv(cEmp,cFil,,,,GetEnvServer(), aTables)
		If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmp) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFil) $ GetMv("MV_ZZWMSFL",, "01")
			
			CONOUT("PROCESSOS WMS - INICIO - ID "+cValtochar(ThreadId())+" - EMPRESA "+cEmp+" - FILIAL "+cFil+" - DATA "+DTOC(ddatabase)+" - HORA "+Time())		
	
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				ZWO->(DbGoTop())
				
				While !ZWO->(EOF())
					cFunExec := ""
					If ZWO->ZWO_MSBLQL = "2" .AND. ZWO->ZWO_INTWIS = "1"  
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
/*/{Protheus.doc} WWISP002

IntegraCAo do Processo 002 – Vendas Sanchez -> Fini (RDV - venda de produtos acabados)


@author Allan Constantino Bonfim
@since  07/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP002(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 002"
Local cFunName	:= "WWISP002"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "002"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf

//FreeObj(oModel)
//oModel := NIL
//DelClassIntf()	
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP005

IntegraCAo do Processo 005 - Abastecimento Estoque de Produtos Nacionais para Franquias

@author Allan Constantino Bonfim
@since  14/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP005(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 005"
Local cFunName	:= "WWISP005"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "005"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP006

IntegraCAo do Processo 006 - Abastecimento de Estoque Finistore


@author Allan Constantino Bonfim
@since  23/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP006(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 006"
Local cFunName	:= "WWISP006"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "006"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
			
			//ROMANEIO
									
			//PROTHEUS -> WIS - PEDIDO DE SAIDA - SITUACAO 1
			
			//STATUS 01			
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")


			//DESMONTAGEM
						
			//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA - DE7
			
			//STATUS 01			
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP007

IntegraCAo do Processo 007 – Faturamentos Finistore

@author Allan Constantino Bonfim
@since  04/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP007(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)


Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 007"
Local cFunName	:= "WWISP007"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "007"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF2 / SD2 - NF DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 5, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF2 / SD2 - NF DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 8, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF2", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP008

IntegraCAo do Processo 008 - Fornecimento de PA Fini para ExportaCAo Sanchez


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP008(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 008"
Local cFunName	:= "WWISP008"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "008"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP011

IntegraCAo do Processo 011 – DevoluCões de Clientes Fini para a Fini


@author Allan Constantino Bonfim
@since  09/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP011(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 011"
Local cFunName	:= "WWISP011"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "011"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
					
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS001CQ(4, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP013

IntegraCAo do Processo 013 - Abastecimento para Loja Funcionários - Sanchez Cano


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP013(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 013"
Local cFunName	:= "WWISP013"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "013"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP015	

IntegraCAo do Processo 015 - Abastecimento do estoque para atender SAC Fini


@author Allan Constantino Bonfim
@since 02/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP015(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 015"
Local cFunName	:= "WWISP015"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "015"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA - DE7
			
			//STATUS 01			
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")


			//PROTHEUS -> WIS - DESMONTAGEM - PEDIDO SAIDA - RE7
			
			//STATUS 01	
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM -  STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS						
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - ENVIO SITUACAO 3 INTERFACE PEDIDO
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 7, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP016

IntegraCAo do Processo 016 - BonificaCões a Cliente SAC Fini


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP016(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 016"
Local cFunName	:= "WWISP016"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "016"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP017

IntegraCAo do Processo 017 - Abastecimento Filiais Fini 


@author Allan Constantino Bonfim
@since  01/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP017(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 017"
Local cFunName	:= "WWISP017"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "017"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP018

IntegraCAo do Processo 018 - Despacho de Materiais de TradeMkt a clientes


@author Allan Constantino Bonfim
@since  14/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP018(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 018"
Local cFunName	:= "WWISP018"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "018"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP019

IntegraCAo do Processo 019 – Recebimento de Compras de Materiais de TradeMkt


@author Allan Constantino Bonfim
@since  26/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP019(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 019"
Local cFunName	:= "WWISP019"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "019"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP020

IntegraCAo do Processo 020 – Recebimento Retorno de Armazenagem em 3os. de Materiais de TradeMkt

@author Allan Constantino Bonfim
@since  03/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP020(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 020"
Local cFunName	:= "WWISP020"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "020"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP022

IntegraCAo do Processo 022 – Retorno de PA Fini vindo de armazém Externo (sem estoque)

@author Allan Constantino Bonfim
@since  03/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP022(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 022"
Local cFunName	:= "WWISP022"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "022"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
						
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP023

IntegraCAo do Processo 023 - Retorno de PA Fini vindo de armazém Externo (com estoque)

@author Allan Constantino Bonfim
@since  03/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP023(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 023"
Local cFunName	:= "WWISP023"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "023"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP23B

IntegraCAo do Processo 23B - Retorno de PA Fini vindo de armazém Externo (com estoque) - Deposito 98

@author Allan Constantino Bonfim
@since  03/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*User Function WWISP23B(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 23B"

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "23B"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName("WWISP23B",.T.,.F.)
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName("WWISP23B",.T.,.F.)			
		Else
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, "WWISP23B", NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP025

IntegraCAo do Processo 025 - Remessa de PA FINI para armazenagem externa (sem estoque)


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP025(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 025"
Local cFunName	:= "WWISP025"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "025"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP026

IntegraCAo do Processo 026 - Remessa de PA FINI para armazenagem externa (com estoque)


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP026(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 026"
Local cFunName	:= "WWISP026"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "026"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP028

IntegraCAo do Processo 028 - OperaCões de Coleta de Amostras Fini para Sanchez (Qualidade e P&D)


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP028(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 028"
Local cFunName	:= "WWISP028"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "028"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP029

IntegraCAo do Processo 029 - ExportaCAo Sanchez de Produtos de Trademkt Fini


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP029(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 029"
Local cFunName	:= "WWISP029"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "029"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP030

IntegraCAo do Processo 030 - Finilog


@author Allan Constantino Bonfim
@since  29/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP030(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 030"
Local cFunName	:= "WWISP030"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "030"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP31A

IntegraCAo do Processo 31A - Remontagem E-commerce - Desmontagem


@author Allan Constantino Bonfim
@since 03/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*
User Function WWISP31A(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 31A"
Local cFunName	:= "WWISP31A"

Default cProcess	:= "31A"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA
		If !EMPTY(cTpDoc)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")			


		//PROTHEUS -> WIS - DESMONTAGEM - PEDIDDO SAIDA
		If !EMPTY(cTpPed)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
					
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SD3", cProcess, "03", "06", .F.)
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName, .T., .F.)
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP31B

IntegraCAo do Processo 31B - Remontagem E-commerce - Romaneio


@author Allan Constantino Bonfim
@since  03/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*
User Function WWISP31B(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 31B"
Local cFunName	:= "WWISP31B"

Default cProcess	:= "31B"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS
		If !EMPTY(cTpPed)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
		//CONOUT(cTxtProc+" - FIM - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	

		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO FATURAMENTO DO ROMANEIO (ZWK/ZWL)")
		U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
		//CONOUT(cTxtProc+" - FIM -  ATUALIZACAO DO FATURAMENTO DO ROMANEIO (ZWK/ZWL)")

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SC5", cProcess, "08", "06")
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName,.T.,.F.)		
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP31C

IntegraCAo do Processo 31C – Remontagem E-commerce - NF Entrada Finistore                                                     


@author Allan Constantino Bonfim
@since  04/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*User Function WWISP31C(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 31C"
Local cFunName	:= "WWISP31C"

Default cProcess	:= "31C"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS
		If !EMPTY(cTpDoc)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
		//CONOUT(cTxtProc+" - FIM - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SF1", cProcess, "03", "06", .F.)
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName, .T., .F.)			
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP32A

IntegraCAo do Processo 32A - Estorno da Remontagem E-commerce - Desmontagem


@author Allan Constantino Bonfim
@since 04/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*
User Function WWISP32A(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 32A"
Local cFunName	:= "WWISP32A"

Default cProcess	:= "32A"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA
		If !EMPTY(cTpDoc)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")			


		//PROTHEUS -> WIS - DESMONTAGEM - PEDIDDO SAIDA
		If !EMPTY(cTpPed)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
					
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SD3", cProcess, "03", "06", .F.)
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName, .T., .F.)
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP32B

IntegraCAo do Processo 32B - Estorno da Remontagem E-commerce - Romaneio


@author Allan Constantino Bonfim
@since  04/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*
User Function WWISP32B(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 32B"
Local cFunName	:= "WWISP32B"

Default cProcess	:= "32B"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS
		If !EMPTY(cTpPed)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
		//CONOUT(cTxtProc+" - FIM - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	

		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO FATURAMENTO DO ROMANEIO (ZWK/ZWL)")
		U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
		//CONOUT(cTxtProc+" - FIM -  ATUALIZACAO DO FATURAMENTO DO ROMANEIO (ZWK/ZWL)")

		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
		U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SC5", cProcess, "08", "06")
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName, .T., .F.)		
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP32C

IntegraCAo do Processo 32C – Estorno da Remontagem E-commerce - NF Entrada Finistore                                                     


@author Allan Constantino Bonfim
@since  04/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*User Function WWISP32C(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 32C"
Local cFunName	:= "WWISP32C"

Default cProcess	:= "32C"
Default cTpDoc	:= ""
Default cTpPed	:= ""

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
					
		//PROTHEUS -> WIS
		If !EMPTY(cTpDoc)		
			//CONOUT(cTxtProc+" - INICIO - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		EndIf
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
		//CONOUT(cTxtProc+" - FIM - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
		
		//WIS -> PROTHEUS
		//CONOUT(cTxtProc+" - INICIO - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
		//CONOUT(cTxtProc+" - FIM - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
	
		//CONOUT(cTxtProc+" - INICIO - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
		U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
		//CONOUT(cTxtProc+" - FIM - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
		//CONOUT(cTxtProc+" - INICIO - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
		//CONOUT(cTxtProc+" - FIM - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
		
		//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO")
		W01FIMST(, "SF1", cProcess, "03", "06", .F.)
		//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO")
		
		UnLockByName(cFunName, .T., .F.)			
	Else
		//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
		Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
		lRet := .F.
	EndIf
	
//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())

Return lRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP033

IntegraCAo do Processo 033 – Transferência entre armazéns


@author Allan Constantino Bonfim
@since  06/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP033(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 033"
Local cFunName	:= "WWISP033"

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "033"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName, .T., .F.)

			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 3, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01TRF(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06
			//CONOUT(cTxtProc+" - INICIO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_AJUSTE_ESTOQUE)")
			U_WIIWPFW("INT_S_AJUSTE_ESTOQUE", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_AJUSTE_ESTOQUE)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "TRF", cProcess, "00", "06", .F., .T.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")

			UnLockByName(cFunName, .T., .F.)			
		Else
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP034

IntegraCAo do Processo 034 – Abastecimento da Franquia para Fini Store


@author Allan Constantino Bonfim
@since  02/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP034(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 034"
Local cFunName	:= "WWISP034"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "034"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP035

IntegraCAo do Processo 035 - Faturamento DegustaCAo / BonificaCAo / Outras Saidas (Armazem 04 ou 98)                                

@author Allan Constantino Bonfim
@since  02/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP035(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 035"
Local cFunName	:= "WWISP035"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "035"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
					
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP036

IntegraCAo do Processo 036 - DevoluCAo Finistore                               

@author Allan Constantino Bonfim
@since  02/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP036(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 036"
Local cFunName	:= "WWISP036"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "036"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS001CQ(4, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP037

IntegraCAo do Processo 037 - Faturamento Fini para Clientes


@author Allan Constantino Bonfim
@since  02/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP037(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 037"
Local cFunName	:= "WWISP037"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "037"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
			
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")	
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP038	

IntegraCAo do Processo 038 - Remontagem SAC


@author Allan Constantino Bonfim
@since 01/07/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP038(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 038"
Local cFunName	:= "WWISP038"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "038"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA - DE7
			
			//STATUS 01			
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")


			//PROTHEUS -> WIS - DESMONTAGEM - PEDIDO SAIDA - RE7
			
			//STATUS 01	
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS						
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
						
			//PROTHEUS -> WIS - ENVIO SITUACAO 3 INTERFACE PEDIDO
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 7, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
											
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)		
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP039	

IntegraCAo do Processo 039 - Estorno da Desmontagem SAC


@author Allan Constantino Bonfim
@since 02/07/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP039(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 039"
Local cFunName	:= "WWISP039"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "039"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - ESTORNO DESMONTAGEM - NOTA ENTRADA - DE6
			
			//STATUS 01			
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
					
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")


			//PROTHEUS -> WIS - ESTORNO DESMONTAGEM - PEDIDO SAIDA - RE6
			
			//STATUS 01	
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS						
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - ENVIO SITUACAO 3 INTERFACE PEDIDO
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 7, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "09", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, "WWISP039", NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP040

IntegraCAo do Processo 040 – RETORNO DE FRANQUIAS PARA PARQUES  - NF SANCHEZ -> FINI


@author Allan Constantino Bonfim
@since  02/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP040(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 040"
Local cFunName	:= "WWISP040"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "040"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
					
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP041

IntegraCAo do Processo 041 - Remessa de Material TradeMarket para terceiros

@author Allan Constantino Bonfim
@since  01/06/2018
@version012
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP041(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 041"
Local cFunName	:= "WWISP041"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "041"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP042

IntegraCAo do Processo 042 - Desmontagem nível 3


@author Allan Constantino Bonfim
@since 02/06/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP042(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 042"
Local cFunName	:= "WWISP042"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "042"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS - DESMONTAGEM - NOTA ENTRADA - DE7
			
			//STATUS 01			
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 3, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")


			//PROTHEUS -> WIS - DESMONTAGEM - PEDIDO SAIDA - RE7
			
			//STATUS 01	
			If !EMPTY(cTpPed)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 4, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SD3 - MOVIMENTOS INTERNOS) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04 e //STATUS 05 - NAO REALIZA MOVIMENTACAO NO PROTHEUS
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess, .F.) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 e 05 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 06 - ITENS						
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")	
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - ENVIO SITUACAO 3 INTERFACE PEDIDO
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 7, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SD3", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP043

IntegraCAo do Processo 043 – Processo de Transferência da Filial para Matriz


@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP043(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 043"
Local cFunName	:= "WWISP043"
Local lEnvio		:= .F.
Local lRetorno	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "043"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.

			If EMPTY(cTpDoc) .AND. EMPTY(cTpPed)
				DbSelectArea("ZWO")
				DbSetOrder(1) //ZWO_FILIAL+ZWO_CODIGO
				If DbSeek(xFilial("ZWO")+cProcess)
					cTpDoc := ZWO->ZWO_TPNOTA
					cTpPed	:= ZWO->ZWO_TPPEDI
				EndIf
			EndIf
						
			//PROTHEUS -> WIS
			
			//STATUS 01
			If !EMPTY(cTpDoc)		
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 1, cProcess, cTpDoc) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SF1 / SD1 - NF ENTRADA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_DET_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_DET_NOTA_FISCAL DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_NOTA_FISCAL)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_E_CAB_NOTA_FISCAL", "1", cProcess, "01") //INCLUI REGISTRO NA TABELA INT_E_CAB_NOTA_FISCAL DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_NOTA_FISCAL)")	
			
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 1, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 1, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05				
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01MOV(3, cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_DET_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_NOTA_FISCAL)")
			
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			U_WIIWPFW("INT_S_CAB_NOTA_FISCAL", "2", cProcess, "05") //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_NOTA_FISCAL)")
			
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SF1", cProcess, "03", "06", .F.)
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
			
			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf

		If !(lEnvio .AND. lRetorno)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISP046

IntegraCAo do Processo 046 - Etiqueta de volume fracionado


@author Allan Constantino Bonfim
@since  19/07/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WWISP046(cEmpPrc, cFilPrc, lExclusiv, cProcess, cTpDoc, cTpPed)

Local lRet 		:= .T.
Local cTxtProc	:= "PROCESSO 046"
Local cFunName	:= "WWISP046"
Local lEnvio		:= .F.
Local lRetorno	:= .F.
Local lFatura 	:= .F.

Default cEmpPrc	:= "02"
Default cFilPrc	:= "01" 
Default cProcess	:= "046"
Default cTpDoc	:= ""
Default cTpPed	:= ""
Default lExclusiv	:= .F.

If lExclusiv
	RPCSetType(3)
	RpcSetEnv(cEmpPrc, cFilPrc,,,, GetEnvServer(), {})
	//CONOUT("INICIALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())				
EndIf			

If GetMv("MV_ZZWMSIN",, .T.) .AND. Alltrim(cEmpPrc) $ GetMv("MV_ZZWMSEM",, "02") .AND. Alltrim(cFilPrc) $ GetMv("MV_ZZWMSFL",, "01")
	
	//CONOUT(cTxtProc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
		
		If LockByName(cFunName+"ENV", .T., .F.)
			lEnvio := .T.
			
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
				//CONOUT(cTxtProc+" - INICIO - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
				U_WIIWTSAI(3, 2, cProcess, cTpPed) //INCLUI REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
				//CONOUT(cTxtProc+" - FIM - STATUS 01 - LEITURA DE DOCUMENTOS (SC5 / SC6 - PEDIDOS DE SAIDA) E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			EndIf
			
			//STATUS 02 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 02 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess) //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 02 - CABECALHO - INTEGRACAO PROTHEUS X WIS (INT_E_CAB_PEDIDO_SAIDA)")	
					
			//WIS -> PROTHEUS
			
			//STATUS 03
			//CONOUT(cTxtProc+" - INICIO - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 2, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 03 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")

			UnLockByName(cFunName+"ENV", .T., .F.)
		EndIf
			
		If LockByName(cFunName+"RET", .T., .F.)
			lRetorno := .T.		
		
			//STATUS 04
			//CONOUT(cTxtProc+" - INICIO - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			U_WIIWTENT(3, 2, cProcess) //INCLUI REGISTRO DO RETORNO DO WIS NA TABELA INTEGRADORA (ZWI/ZWJ)
			//CONOUT(cTxtProc+" - FIM - STATUS 04 - LEITURA DO RETORNO WMS WIS E GRAVACAO DA TABELA INTEGRADORA (ZWI/ZWJ)")
			
			//STATUS 05 - REALIZA MOVIMENTACAO NO PROTHEUS			
			//CONOUT(cTxtProc+" - INICIO - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			U_WIS01LPD(cProcess) //PROCESSAMENTO DO RETORNO NO PROTHEUS		
			//CONOUT(cTxtProc+" - FIM - STATUS 05 - PROCESSAMENTO DO RETORNO WMS WIS NO PROTHEUS")
			
			//STATUS 06 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_DET_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - ITENS - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_DET_PEDIDO_SAIDA)")
					
			//STATUS 06 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS  (INT_S_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_S_CAB_PEDIDO_SAIDA", "2", cProcess) //FINALIZA O PROCESSO NO PROTHEUS E WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 06 - CABECALHO - FINALIZACAO DO PROCESSO NO PROTHEUS E WIS (INT_S_CAB_PEDIDO_SAIDA)")

			UnLockByName(cFunName+"RET", .T., .F.)
		EndIf
		
		If LockByName(cFunName+"FAT", .T., .F.)
			lFatura := .T.	
			
			//PROTHEUS -> WIS - NOTA FISCAL SAIDA - SITUACAO 3 - ENVIO DA INTERFACE DE FATURAMENTO PARA O WIS 
			
			//STATUS 07
			//CONOUT(cTxtProc+" - INICIO - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			U_WIIWTSAI(3, 6, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL) COM AS INFORMACOES DE FATURAMENTO
			//CONOUT(cTxtProc+" - FIM - STATUS 07 - INCLUSAO DA SITUACAO 3 DO ROMANEIO PARA FINALIZACAO (ZWK/ZWL)")
			
			//STATUS 08 - ITENS
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_DET_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_DET_PEDIDO_SAIDA DO WIS 
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - ITENS - INTEGRACAO PROTHEUS X WIS (INT_E_DET_PEDIDO_SAIDA)")
			
			//STATUS 08 - CABECALHO
			//CONOUT(cTxtProc+" - INICIO - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS (INT_E_CAB_PEDIDO_SAIDA)")
			U_WIIWPFW("INT_E_CAB_PEDIDO_SAIDA", "1", cProcess, "07", "3") //INCLUI REGISTRO NA TABELA INT_E_CAB_PEDIDO_SAIDA DO WIS
			//CONOUT(cTxtProc+" - FIM - STATUS 08 - CABECALHO - INTEGRACAO PROTHEUS X WIS - ENVIO ATUALIZACAO DO FATURAMENTO DO ROMANEIO PRA O WIS(INT_E_CAB_PEDIDO_SAIDA)")	

			//STATUS 09
			//CONOUT(cTxtProc+" - INICIO - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
			U_WIIWTSAI(4, 3, cProcess) //ATUALIZA REGISTRO NA TABELA INTEGRADORA (ZWK/ZWL)
			//CONOUT(cTxtProc+" - FIM - STATUS 09 - ATUALIZACAO DO PROCESSAMENTO DA LEITURA E GRAVACAO DA TABELA INTEGRADORA (ZWK/ZWL)")
						
			//STATUS 50
			//CONOUT(cTxtProc+" - INICIO - STATUS 50 - FINALIZACAO DO PROCESSO")
			W01FIMST(, "SC5", cProcess, "03", "06")
			//CONOUT(cTxtProc+" - FIM - STATUS 50 - FINALIZACAO DO PROCESSO")
									
			UnLockByName(cFunName+"FAT", .T., .F.)			
		EndIf
		
		If !(lEnvio .AND. lRetorno .AND. lFatura)
			//CONOUT(cTxtProc+" - ATENCÂO - EM EXECUCAO POR OUTRO USUÀRIO")		
			Help(NIL, NIL, cFunName, NIL, cTxtProc+" - EM EXECUCAO POR OUTRO USUÀRIO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"AGUARDE A FINALIZACÂO DO PROCESSO E TENTE NOVAMENTE."})
			lRet := .F.
		EndIf
		
	//CONOUT(cTxtProc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

If lExclusiv
	//CONOUT("FINALIZACAO DO AMBIENTE - "+DTOC(ddatabase)+" - "+Time())		
	RpcClearEnv()
EndIf
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIS01TRF

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  06/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIS01TRF(nOpcA, cProcess)

Local aArea				:= GetArea()
Local lRet 				:= .T.
Local aLinha 				:= {}
Local aTransf				:= {}
Local cNumDoc				:= ""
Local cQueryCab			:= ""
Local cQDados				:= ""
Local cQTotIt				:= ""
Local cTmpCab				:= GetNextAlias()
Local cTmpDados			:= GetNextAlias()
Local cTmpTotIt			:= GetNextAlias()
Local aLogTMP				:= {}
Local cEmpWis				:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Local cFilWis				:= PADL(FWCodFil(), 3, "0")   
Local cErro				:= ""
Local cDescErro			:= ""
Local cSolucao			:= ""
Local nX					:= 0
Local nY					:= 0
Local cProduto			:= ""
Local cDescProd			:= ""
Local cUM					:= ""		
Local cArmOri 			:= ""
Local cArmDest			:= ""
Local cLote				:= ""
Local cLoteDest			:= ""
Local cEndOri				:= ""
Local cEndDest			:= ""
Local cObserva			:= ""
Local lGrvLogOk			:= GetMv("MV_ZZWMSLT",, .T.)
Local nPosDoc 			:= 1
Local nPosCod 			:= 2
Local nPosLocal 			:= 10
Local nPosLocOri 			:= 5
Local nPosLote 			:= 21
Local nPosQuant			:= 17
Local nItem				:= 0
Local nSaldo				:= 0
Local nQtde				:= 0
Local cUserWIS			:= "WIS"
Local aAreaSD3
Local aPrdLote

Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.  
Private lMsHelpAuto    	:= .T.
			
Default nOpcA				:= 0
Default cProcess 			:= ""

If !EMPTY(nOpcA) .AND. !EMPTY(cProcess)

	cQueryCab := "SELECT DISTINCT ZWI_FILIAL, ZWI_EMPRES, ZWI_DEPOSI, ZWI_CODIGO, ZWI.R_E_C_N_O_ AS ZWIREC "+CHR(13)+CHR(10)
	cQueryCab += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQueryCab += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_CALIAS = 'TRF' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_SITUAC = '15' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)	
	cQueryCab += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_IDPROC = 'N' "+CHR(13)+CHR(10)
	
	//CM Solutions - Allan Constantino Bonfim - 09/01/2020 - CHAMADO 17266 - Inclusão e tratamento do código do motivo de transferência 
	//cQueryCab += "AND ZWI_CODMOT <> ' ' "+CHR(13)+CHR(10)
	cQueryCab += "ORDER BY ZWI_CODIGO "+CHR(13)+CHR(10)

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf
	
	cQueryCab := ChangeQuery(cQueryCab)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCab),cTmpCab)	
	
	While !(cTmpCab)->(EOF())
		
		lRet 			:= .T.			 
		aZWJRec		:= {}
		nItem			:= 0
		cErro			:= ""
		cDescErro		:= ""
		lMsErroAuto 	:= .F.
												
		//Begin Transaction
					
			cQDados := "SELECT DISTINCT ZWJ_CODIGO, ZWJ_ITEM, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ_CODMOT, ZWJ_DEPERP, ZWJ_QTDE, "+CHR(13)+CHR(10)
			cQDados += "ZWJ_NOMFUN, ZWJ_QTDCNF, ZWJ_QTDAVA, ZWJ_LOTE, B1_COD, B1_DESC, B1_UM, ZWJ_DEPORI, ZWJ_DTVALD "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("SB1")+" SB1 (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZWJ_PRODUT AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
			cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)			
			cQDados += "AND ZWJ_CALIAS = 'TRF' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '04' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_SITUAC = '15' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_IDPROC = 'N' "+CHR(13)+CHR(10)
			
			If Select(cTmpDados) > 0
				(cTmpDados)->(DbCloseArea())
			EndIf
			
			cQDados := ChangeQuery(cQDados)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	
		
			While !(cTmpDados)->(EOF())														
				nSaldo		:= 0
				aLinha 	:= {}
				cErro		:= ""
				
				cProduto	:= Padr((cTmpDados)->B1_COD,TamSx3("D3_COD")[01])
				cDescProd	:= Padr((cTmpDados)->B1_DESC,TamSx3("D3_DESCRI")[01])
				cUM			:= Padr((cTmpDados)->B1_UM,TamSx3("D3_UM")[01])		
				cArmOri 	:= Padr((cTmpDados)->ZWJ_DEPORI,TamSx3("D3_LOCAL")[01])
				cArmDest	:= Padr((cTmpDados)->ZWJ_DEPERP,TamSx3("D3_LOCAL")[01]) 
				cLote		:= Padr((cTmpDados)->ZWJ_LOTE,TamSx3("D3_LOTECTL")[01])
				cLoteDest	:= Padr((cTmpDados)->ZWJ_LOTE,TamSx3("D3_LOTECTL")[01])
				cEndOri	:= CRIAVAR('D3_LOCALIZ')
				cEndDest	:= CRIAVAR('D3_LOCALIZ') 
				cObserva	:= Padr((cTmpDados)->ZWJ_CODIGO,TamSx3("D3_OBSERVA")[01])				
				dDataVld	:= GETVLOTE(cProduto, cArmOri, cLote)
				cUserWIS 	:= (cTmpDados)->ZWJ_NOMFUN 
				
				//CM Solutions - Allan Constantino Bonfim - 09/01/2020 - CHAMADO 17266 - Inclusão e tratamento do código do motivo de transferência				
				If !EMPTY((cTmpDados)->ZWJ_CODMOT) .AND. ALLTRIM((cTmpDados)->ZWJ_CODMOT) <> "0"					
				 	DbSelectArea("SB1")
				 	DbSetOrder(1)
				 	If SB1->(dbSeek(xFilial("SB1")+cProduto))										
					 	DbSelectArea("SB2")
					 	DbSetOrder(1)	
						//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)				
						If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmDest,TamSx3("B2_LOCAL")[01])))
							CriaSB2(cProduto,cArmDest)
						EndIf

						If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmOri,TamSx3("B2_LOCAL")[01])))
							CriaSB2(cProduto,cArmOri)
						EndIf

						nSaldo := SaldoSB2() //SB2->B2_SALDO
						
						If nSaldo >= (cTmpDados)->ZWJ_QTDE
						
							DbSelectArea("SD3")
							aTransf 	:= {}
							cNumDoc 	:= NextNumero("SD3", 2, "D3_DOC", .T.) 
						
							AADD(aTransf, {cNumDoc, dDataBase})
																	
							If Rastro(cProduto, "L")				
								dbSelectArea('SB8')			
								nSaldo := SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmOri,TamSx3("B8_LOCAL")[01]), Padr(cLote,TamSx3("B8_LOTECTL")[01]), NIL, NIL, NIL, NIL, dDataBase)
													
								If nSaldo >= (cTmpDados)->ZWJ_QTDE
									nItem++
									
									nQtde := (cTmpDados)->ZWJ_QTDE
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									
									AADD(aLinha, {"ITEM"			, StrZero(nItem, 3)					, Nil})
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
									AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
									AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
									AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
									AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote Origem
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
									AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
									AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
									AADD(aLinha, {"D3_QUANT"		, nQtde								, Nil}) //Quantidade
									AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
									AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
									AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
									AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote destino
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
									AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //validade lote destino
									AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
									AADD(aLinha, {"D3_OBSERVA"	, cObserva								, Nil}) //Observacao
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
									AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
									AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
																			    							
									AADD(aTransf, aLinha)													
									aLinha := {}
								Else							
									nSaldo := 0								
									nSaldo := SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmOri,TamSx3("B8_LOCAL")[01]), NIL, NIL, NIL, NIL, NIL, dDataBase)
								
									If nSaldo >= (cTmpDados)->ZWJ_QTDE	
										aPrdLote := SldPorLote(cProduto, cArmOri, (cTmpDados)->ZWJ_QTDE, ConvUm(cProduto, (cTmpDados)->ZWJ_QTDE, 0.00, 2),,,,,,.T., cArmOri,,,, dDataBase,,, .T.)
	
										If Len(aPrdLote) > 0										
											AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
											
											For nX := 1 to Len(aPrdLote)
												nItem++											
												cLote		:= aPrdLote[nX][1]
												dDataVld 	:= aPrdLote[nX][7]											
												nQtde 		:= aPrdLote[nX][5]
																
												AADD(aLinha, {"ITEM"			, StrZero(nItem, 3)					, Nil})
												AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
												AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
												AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
												AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
												AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
												AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
												AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
												AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
												AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
												AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
												AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
												AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote Origem
												AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
												AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
												AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
												AADD(aLinha, {"D3_QUANT"		, nQtde								, Nil}) //Quantidade
												AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
												AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
												AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
												AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote destino
												AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
												AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //validade lote destino
												AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
												AADD(aLinha, {"D3_OBSERVA"	, cObserva								, Nil}) //Observacao
												AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
												AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
												AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
												AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
														    							
												AADD(aTransf, aLinha)
												aLinha := {}													
											Next										
										Else									
											cErro 			:= "O SALDO DO LOTE "+ALLTRIM(cLote)+" DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE (SB8). SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar((cTmpDados)->ZWJ_QTDE)+"."
											AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
											lMsErroAuto 	:= .T.
											lRet			:= .F.
											Exit																			
										EndIf									
									Else								
										cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NOS LOTES DO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE (SB8). SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar((cTmpDados)->ZWJ_QTDE)+"."
										AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
										lMsErroAuto 	:= .T.
										lRet			:= .F.
										Exit									
									EndIf																	
								EndIf		
							Else		
								If nSaldo >= (cTmpDados)->ZWJ_QTDE
									nItem++
									
									nQtde := (cTmpDados)->ZWJ_QTDE
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									
									AADD(aLinha, {"ITEM"			, StrZero(nItem, 3)					, Nil})
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
									AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
									AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
									AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
									AADD(aLinha, {"D3_LOTECTL"	, CRIAVAR('D3_LOTECTL')				, Nil}) //Lote Origem					
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
									AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
									AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
									AADD(aLinha, {"D3_QUANT"		, nQtde								, Nil}) //Quantidade
									AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
									AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
									AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
									AADD(aLinha, {"D3_LOTECTL"	, CRIAVAR('D3_LOTECTL')				, Nil}) //Lote destino
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
									AADD(aLinha, {"D3_DTVALID"	, CRIAVAR('D3_DTVALID')				, Nil}) //validade lote destino
									AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
									AADD(aLinha, {"D3_OBSERVA"	, cObserva							, Nil}) //Observacao
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
									AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
									AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
											    							
									AADD(aTransf, aLinha)													
									aLinha := {}	
								Else						
									cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE. SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar((cTmpDados)->ZWJ_QTDE)+"."
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									lMsErroAuto 	:= .T.
									lRet			:= .F.
									Exit											
								EndIf						
							EndIf						
						Else						
							cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE. SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar((cTmpDados)->ZWJ_QTDE)+"."
							AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
							lMsErroAuto 	:= .T.
							lRet			:= .F.
							Exit											
						EndIf						
					Else
						cErro 			:= "O PRODUTO "+ALLTRIM(cProduto)+" NAO FOI LOCALIZADO NO CADASTRO DE PRODUTOS DO PROTHEUS."
						AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
						lMsErroAuto 	:= .T.
						lRet			:= .F.
						Exit
					EndIf						
				Else
					cErro 			:= "O MOTIVO DA TRANSFERÊNCIA DO PRODUTO "+ALLTRIM(cProduto)+" NAO FOI INFORMADO."
					AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
					lMsErroAuto 	:= .T.
					lRet			:= .F.
					Exit														
				EndIf
								
				(cTmpDados)->(DbSkip())	
			EndDo
			
			Begin Transaction	
				If Empty(cErro) .AND. Len(aTransf) > 1
				
					//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
					If ValType(cUserName) == "C"
						If Empty(cUserWIS)
							cUserWIS :=  "WIS"
						EndIf
						
						cUserName := Alltrim(cUserWIS)
					EndIf
															
					MSExecAuto({|x,y| MATA261(x,y)}, aTransf, nOpcA)
				EndIf        
				
				aAreaSD3 := SD3->(GetArea())
										
					//Verifica se todos os itens foram movimentados devido a um falto positivo no retorno do execauto
					If !lMsErroAuto
						SD3->(DBOrderNickname("SD3WIS100")) //D3_FILIAL+D3_DOC+D3_COD+D3_LOCAL+D3_LOTECTL+D3_EMISSAO+D3_ESTORNO
						For nY:= 2 to Len(aTransf)					
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+DTOS(dDataBase)))
								If SD3->D3_ESTORNO = 'S'
									lMsErroAuto := .T.
									//cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - PRODUTO "+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+" ARMAZEM "+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+" LOTE "+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+" QTDE "+cValtoChar(aTransf[nY][nPosQuant][2])+" (WIS -> PROTHEUS)"
									cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - ERRO EXECAUTO - NAO GEROU O REGISTRO DE TRANSFERENCIA - SD3 (WIS -> PROTHEUS)"
									Exit
								EndIf
							Else	 
								lMsErroAuto := .T.
								//cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - PRODUTO "+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+" ARMAZEM "+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+" LOTE "+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+" QTDE "+cValtoChar(aTransf[nY][nPosQuant][2])+" (WIS -> PROTHEUS)"
								cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - ERRO EXECAUTO - NAO GEROU O REGISTRO DE TRANSFERENCIA - SD3 (WIS -> PROTHEUS)"
								Exit
							EndIf
						Next
					EndIf							                          
																	                             
					If lMsErroAuto							
						lRet := .F.
					  	aLogTMP := GetAutoGRLog()
					  	
					  	If EMPTY(cErro)
					  		cErro := "FALHA NO PROCESSAMENTO DO RETORNO DE NOTAS FISCAIS - PROCESSO "+cProcess+" (WIS -> PROTHEUS)"
					  	EndIf
					  	
						For nY := 1 to Len(aZWJRec)
						
							DbSelectArea("ZWJ")
							ZWJ->(DbGoto(aZWJRec[nY][2]))	
							
							cDescErro	:= ""
							cSolucao 	:= ""
													
					  		U_WWSTATUS("ZWJ", aZWJRec[nY][2], "95", cDescErro)	
											  	
					    	If Len(aLogTMP) > 0
					    		If Len(aLogTMP) >= 7
					    			cSolucao := Alltrim(AllToChar(aLogTMP[7]))
					    		EndIf
				    			For nX := 1 to Len(aLogTMP)
				    				If !EMPTY(cDescErro)
				    					cDescErro += " - "	
				    				EndIf
				    			
				    				cDescErro += AllToChar(aLogTMP[nX])			    		
				    			Next					
							EndIf
							
							//cDescErro += CHR(13)+CHR(10)+" EXECAUTO MATA261 - ARRAY (aTransf) "+CHR(13)+CHR(10)+VarInfo("aTransf", aTransf, , .F.)
							
							U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01TRF",, IIF (!Empty(cErro), "3", "4"), cErro, ERRO95, cDescErro, cSolucao, "95")			    		  		
						Next					
					Else					
						For nY := 1 to Len(aZWJRec)						
							DbSelectArea("ZWJ")
							ZWJ->(DbGoto(aZWJRec[nY][2]))	
	
							U_WWSTATUS("ZWJ", aZWJRec[nY][2], "05")				
	
							If lGrvLogOk
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01MOV",, "0",,,,, "05")						
							EndIf		
						Next
										 
						SD3->(DBOrderNickname("SD3WIS100")) //D3_FILIAL+D3_DOC+D3_COD+D3_LOCAL+D3_LOTECTL+D3_EMISSAO+D3_ESTORNO
						
						For nY:= 2 to Len(aTransf)
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+DTOS(dDataBase))) 
								While 	!SD3->(EOF()) .AND. SD3->D3_DOC == Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01]) .AND.; 
										SD3->D3_COD == Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) .AND.; 
										SD3->D3_LOCAL == Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01]) .AND.;
										SD3->D3_LOTECTL == Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]) .AND.;
										DTOS(SD3->D3_EMISSAO) == DTOS(dDataBase) 	
									
									DbSelectArea("ZWJ")
									
									If Len(aZWJRec) < nY-1
										ZWJ->(DbGoTo(aZWJRec[1][2]))
									Else
										ZWJ->(DbGoTo(aZWJRec[nY-1][2]))
									EndIf
									
						 			//If Empty(SD3->D3_ESTORNO) .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)				 			
					 				If Empty(SD3->D3_ESTORNO) .AND. SD3->D3_QUANT == aTransf[nY][nPosQuant][2] .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)																					
										U_WW01PROC("ZWJ", ZWJ->(RECNO()), "SD3", SD3->(RECNO()), SD3->D3_DOC)
										
										//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
						 				Reclock("SD3", .F.)
								    		SD3->D3_XWMSCOD	:= ZWJ->ZWJ_CODIGO
								    		SD3->D3_XWMSITM	:= ZWJ->ZWJ_ITEM								    		
								    		SD3->D3_USUARIO	:= ZWJ->ZWJ_NOMFUN
								    		SD3->D3_XWMSPRO	:= cProcess 								    		
								    		//CM Solutions - Allan Constantino Bonfim - 09/01/2020 - CHAMADO 17266 - Inclusão e tratamento do código do motivo de transferência  
											SD3->D3_ZZMOT	:= ZWJ->ZWJ_CODMOT  
								    	SD3->(MsUnlock())
																			
										Exit
								    EndIf
				    								    									    				
				    				SD3->(DbSkip())
					    		EndDo
							EndIf
							
							//MOVIMENTO ORIGINAL - RE4
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]))) 
								While 	!SD3->(EOF()) .AND. SD3->D3_DOC == Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01]) .AND.; 
										SD3->D3_COD == Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) .AND.; 
										SD3->D3_LOCAL == Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01]) .AND.;
										SD3->D3_LOTECTL == Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]) 	
	
									DbSelectArea("ZWJ")
									ZWJ->(DbGoTo(aZWJRec[nY-1][2]))
									
						 			//If Empty(SD3->D3_ESTORNO) .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)						 			
						 			If Empty(SD3->D3_ESTORNO) .AND. SD3->D3_QUANT == aTransf[nY][nPosQuant][2] .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)
						 				//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
						 				Reclock("SD3", .F.)
								    		SD3->D3_XWMSCOD 	:= ZWJ->ZWJ_CODIGO
								    		SD3->D3_XWMSITM 	:= ZWJ->ZWJ_ITEM
								    		SD3->D3_USUARIO 	:= ZWJ->ZWJ_NOMFUN
								    		SD3->D3_XWMSPRO 	:= cProcess
								    		//CM Solutions - Allan Constantino Bonfim - 09/01/2020 - CHAMADO 17266 - Inclusão e tratamento do código do motivo de transferência  
											SD3->D3_ZZMOT	:= ZWJ->ZWJ_CODMOT  								    		
								    	SD3->(MsUnlock())
										Exit
								    EndIf
				    								    									    				
				    				SD3->(DbSkip())
					    		EndDo
							EndIf															    
						Next	    		 		    		   
				    EndIf
				     				    
				RestArea(aAreaSD3)
							    						
				If lRet
					cQTotIt := "SELECT COUNT(ZWJ_CODIGO) AS QTDITEM "+CHR(13)+CHR(10)
					cQTotIt += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
					cQTotIt += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_CALIAS = 'TRF' "+CHR(13)+CHR(10)
					cQTotIt += "AND (ZWJ_STATUS = '04' OR ZWJ_STATUS > '50') "+CHR(13)+CHR(10)		
					cQTotIt += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)	
				
					If Select(cTmpTotIt) > 0
						(cTmpTotIt)->(DbCloseArea())
					EndIf
			
					cQTotIt := ChangeQuery(cQTotIt)	
					dbUseArea(.T., "TOPCONN", TcGenQry(,,cQTotIt), cTmpTotIt)	
	
					If EMPTY((cTmpTotIt)->QTDITEM) 							
						U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "05")
						
						If lGrvLogOk
							DbSelectArea("ZWI")
							ZWI->(DbGoto((cTmpCab)->ZWIREC))					
							U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01TRF",, "0",,,,, "05")						
						EndIf													    								    						
					Else
						U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
					EndIf
				Else
					U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
				EndIf
						
			End Transaction
	
		(cTmpCab)->(DbSkip())	
	EndDo

	If Select(cTmpTotIt) > 0
		(cTmpTotIt)->(DbCloseArea())
	EndIf

	If Select(cTmpDados) > 0
		(cTmpDados)->(DbCloseArea())
	EndIf

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf
EndIf


RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIS01MOV

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  01/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIS01MOV(nOpcA, cProcess)

Local aArea				:= GetArea()
Local lRet 				:= .T.
Local aLinha 				:= {}
//Local aItemTrs 			:= {}
Local aTransf				:= {}
Local cNumDoc				:= ""
Local cQueryCab			:= ""
Local cQDados				:= ""
Local cQTotIt				:= ""
Local cTmpCab				:= GetNextAlias()
Local cTmpDados			:= GetNextAlias()
Local cTmpTotIt			:= GetNextAlias()
Local aLogTMP				:= {}
Local cEmpWis				:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) //PADR(IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')), TAMSX3("ZWK_EMPRES")[1], " ")
Local cFilWis				:= PADL(FWCodFil(), 3, "0")   
Local cDescErro			:= ""
Local cErro				:= "FALHA NO PROCESSAMENTO DO RETORNO DE NOTAS FISCAIS - PROCESSO "+cProcess+" (WIS -> PROTHEUS)"
Local cSolucao			:= ""
Local nX					:= 0
Local nY					:= 0
Local nZ					:= 0
Local cProduto			:= ""
Local cDescProd			:= ""
Local cUM					:= ""		
Local cArmOri 			:= ""
Local cArmDest			:= ""
Local cLote				:= ""
Local cLoteDest			:= ""
Local cEndOri				:= ""
Local cEndDest			:= ""
Local cObserva			:= ""
Local lGrvLogOk			:= GetMv("MV_ZZWMSLT",, .T.)
Local nPosDoc 			:= 1
Local nPosCod 			:= 2
Local nPosLocal 			:= 10
Local nPosLocOri 			:= 5
Local nPosLote 			:= 21
//Local nPosLOri			:= 13
//Local nPosEOri 			:= 6	
//Local nPosEDest 			:= 11
Local nPosQuant			:= 17
//Local nPosQtd2			:= 18
//Local lSomaQtd 			:= .F.
Local nItem				:= 0
Local nSaldo				:= 0
Local nQtdLib				:= 0
Local nQtde				:= 0
Local cUserWIS			:= "WIS"
Local nQtdTotPrd			:= 0
Local aPrdLote			:= {}
Local lPrdTransf 			:= .F.
Local dDtVldDest
Local dDataVld
Local aAreaSD3

Private lMsErroAuto		:= .T.
Private lAutoErrNoFile	:= .T.  
Private lMsHelpAuto    	:= .T.
			
Default nOpcA				:= 0
Default cProcess 			:= ""



If !EMPTY(nOpcA) .AND. !EMPTY(cProcess)

	cQueryCab := "SELECT DISTINCT ZWI_CODIGO, ZWI_NOTA, ZWI.R_E_C_N_O_ AS ZWIREC "+CHR(13)+CHR(10)
	cQueryCab += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQueryCab += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_CALIAS = 'SF1' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_SITUAC = '9' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_IDPROC = 'N' "+CHR(13)+CHR(10) 
	cQueryCab += "ORDER BY ZWI_CODIGO "+CHR(13)+CHR(10)

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf
	
	cQueryCab := ChangeQuery(cQueryCab)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCab),cTmpCab)	
	
	While !(cTmpCab)->(EOF())
		
		lRet 			:= .T.			 
		aTransf 		:= {}
		aZWJRec		:= {}
		nItem			:= 0
		cDescErro		:= ""
		cErro			:= "" //"FALHA NO PROCESSAMENTO DO RETORNO DE NOTAS FISCAIS - PROCESSO "+cProcess+" (WIS -> PROTHEUS)"
		lMsErroAuto	:= .F.
														
		//Begin Transaction

			cNumDoc 	:= Padr((cTmpCab)->ZWI_NOTA, TamSx3("D3_DOC")[01]) // NextNumero("SD3", 2, "D3_DOC", .T.)
			
			AADD(aTransf, {cNumDoc, dDataBase})
			
			cQDados := "SELECT DISTINCT ZWJ_CODIGO, ZWJ_ITEM, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ_DEPERP, ZWJ_QTDE, ZWJ_NOMFUN, "+CHR(13)+CHR(10)
			cQDados += "ZWJ_QTDCNF, ZWJ_QTDAVA, ZWJ_LOTE, B1_COD, B1_DESC, B1_UM, D1_UM, D1_DOC, D1_LOCAL, D1_LOTECTL, D1_LOTEFOR, D1_DTVALID "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("SD1")+" SD1 (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (D1_FILIAL = '"+xFilial("SD1")+"' AND ZWJ_RECORI = SD1.R_E_C_N_O_ AND SD1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("SB1")+" SB1 (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZWJ_PRODUT AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
			cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)			
			cQDados += "AND ZWJ_CALIAS = 'SD1' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '04' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_SITUAC = '9' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_IDPROC = 'N' "+CHR(13)+CHR(10)
			
			If Select(cTmpDados) > 0
				(cTmpDados)->(DbCloseArea())
			EndIf
			
			cQDados := ChangeQuery(cQDados)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	
		
			While !(cTmpDados)->(EOF())
				aLinha 	:= {}
				nQtdLib	:= 0
				//nItem++											

				cProduto	:= Padr((cTmpDados)->B1_COD,TamSx3("D3_COD")[01])
				cDescProd	:= Padr((cTmpDados)->B1_DESC,TamSx3("D3_DESCRI")[01])
				cUM			:= Padr((cTmpDados)->D1_UM,TamSx3("D3_UM")[01])		
				cArmOri 	:= Padr((cTmpDados)->D1_LOCAL,TamSx3("D3_LOCAL")[01])
				cArmDest	:= Padr((cTmpDados)->ZWJ_DEPERP,TamSx3("D3_LOCAL")[01]) 
				cLote		:= Padr((cTmpDados)->D1_LOTECTL,TamSx3("D3_LOTECTL")[01])
				cLoteDest	:= Padr((cTmpDados)->ZWJ_LOTE,TamSx3("D3_LOTECTL")[01])
				cEndOri	:= CRIAVAR('D3_LOCALIZ')
				cEndDest	:= CRIAVAR('D3_LOCALIZ') 
				cObserva	:= Padr((cTmpDados)->ZWJ_CODIGO,TamSx3("D3_OBSERVA")[01]) 
				cUserWIS 	:= (cTmpDados)->ZWJ_NOMFUN
				
				If EMPTY((cTmpDados)->D1_DTVALID)
					dDataVld	:= GETVLOTE(cProduto, cArmOri, cLote)
				Else
					dDataVld	:= STOD((cTmpDados)->D1_DTVALID)
				EndIf		
								
				If !EMPTY((cTmpDados)->ZWJ_QTDAVA)
					nQtde	:=	(cTmpDados)->ZWJ_QTDAVA
				Else
					nQtde	:=	(cTmpDados)->ZWJ_QTDCNF
				EndIf
				
			 	DbSelectArea("SB2")
			 	DbSetOrder(1)	
				//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
				If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmDest,TamSx3("B2_LOCAL")[01])))
					CriaSB2(cProduto,cArmDest)
				EndIf

				If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmOri,TamSx3("B2_LOCAL")[01])))
					CriaSB2(cProduto,cArmOri)
				EndIf
		
				
			 	DbSelectArea("SB1")
			 	DbSetOrder(1)
			 	If SB1->(dbSeek(xFilial("SB1")+cProduto))			 	
					lPrdTransf := .F.
					
					//Verifica se o produto / armazém já foi incluído no array para transferência 
					For nY := 2 to Len(aTransf)
						If 	Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) == cProduto .AND. Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01]) == cArmOri													
							lPrdTransf := .T.
							Exit
						Endif						
					Next
					
					If lPrdTransf
						//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})						
						AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})						
					Else 
						nSaldo 	:= SaldoSB2() //SB2->B2_SALDO
				 		nQtdTotPrd	:= WWISTLOTE(cQDados, cProduto, cArmOri) //Qtde produto
				 		
						If nSaldo >= nQtdTotPrd			 																					
							If Rastro(cProduto, "L")
								nQtdTotPrd	:= WWISTLOTE(cQDados, cProduto, cArmOri) //Qtde produto 
								dbSelectArea('SB8')
								nSaldo 	:= SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmOri,TamSx3("B8_LOCAL")[01]), NIL, NIL, NIL, NIL, NIL, dDataBase)
								
								If nSaldo >= nQtdTotPrd																
									aPrdLote := SldPorLote(cProduto, cArmOri, nQtdTotPrd, ConvUm(cProduto, nQtdTotPrd, 0.00, 2),,,,,,.T., cArmOri,,,, dDataBase,,, .T.)
	
									If Len(aPrdLote) > 0																				
										//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
										AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
										
										For nX := 1 to Len(aPrdLote)
											nItem++ 											
											cLote		:= aPrdLote[nX][1]
											dDataVld 	:= aPrdLote[nX][7]											
											nQtde 		:= aPrdLote[nX][5]

											//ALLAN - Correcao na busca da data validade do armazem destino
											dDtVldDest	:= GETVLOTE(cProduto, cArmDest, cLote)

											AADD(aLinha, {"ITEM"		, StrZero(nItem, 3)					, Nil})
											AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
											AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
											AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
											AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
											AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
											AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
											AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
											AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
											AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
											AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
											AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
											AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote Origem
											AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
											AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
											AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
											AADD(aLinha, {"D3_QUANT"	, nQtde								, Nil}) //Quantidade
											AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
											AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
											AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
											AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote destino
											AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
											AADD(aLinha, {"D3_DTVALID"	, dDtVldDest						, Nil}) //validade lote destino
											AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
											AADD(aLinha, {"D3_OBSERVA"	, cObserva								, Nil}) //Observacao
											AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
											AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
											AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
											AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
													    							
											AADD(aTransf, aLinha)
											aLinha := {}													
										Next										
									Else									
										cErro 			:= "O SALDO DO LOTE "+ALLTRIM(cLote)+" DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE (SB8). SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar(nQtdTotPrd)+"."
										//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
										AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
										lMsErroAuto 	:= .T.
										lRet			:= .F.
										Exit																			
									EndIf																			
								Else									
									cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NOS LOTES DO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE (SB8). SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar(nQtdTotPrd)+"."
									//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
									lMsErroAuto 	:= .T.
									lRet			:= .F.
									Exit																											
								EndIf																	
							Else		
								If nSaldo >= (cTmpDados)->ZWJ_QTDE
									nItem++
									
									nQtde := (cTmpDados)->ZWJ_QTDE
									//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
									
									AADD(aLinha, {"ITEM"			, StrZero(nItem, 3)					, Nil})
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
									AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
									AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
									AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
									AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
									AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
									AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
									AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
									AADD(aLinha, {"D3_LOTECTL"	, CRIAVAR('D3_LOTECTL')				, Nil}) //Lote Origem					
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
									AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
									AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
									AADD(aLinha, {"D3_QUANT"		, nQtde								, Nil}) //Quantidade
									AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
									AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
									AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
									AADD(aLinha, {"D3_LOTECTL"	, CRIAVAR('D3_LOTECTL')				, Nil}) //Lote destino
									AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
									AADD(aLinha, {"D3_DTVALID"	, CRIAVAR('D3_DTVALID')				, Nil}) //validade lote destino
									AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
									AADD(aLinha, {"D3_OBSERVA"	, cObserva							, Nil}) //Observacao
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
									AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
									AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
									AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
											    							
									AADD(aTransf, aLinha)													
									aLinha := {}	
								Else						
									cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE. SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar((cTmpDados)->ZWJ_QTDE)+"."
									//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
									AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
									lMsErroAuto 	:= .T.
									lRet			:= .F.
									Exit											
								EndIf						
							EndIf						
						Else						
							cErro 			:= "O SALDO DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE. SALDO ATUAL = "+cValtoChar(nSaldo)+".QUANTIDADE SOLICITADA = "+cValtoChar(nQtdTotPrd)+"."
							//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
							AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
							lMsErroAuto 	:= .T.
							lRet			:= .F.
							Exit											
						EndIf
					EndIf
				Else
					cErro 			:= "O PRODUTO "+ALLTRIM(cProduto)+" NAO FOI LOCALIZADO NO CADASTRO DE PRODUTOS DO PROTHEUS."
					//AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
					AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP})
					lMsErroAuto 	:= .T.
					lRet			:= .F.
					Exit
				EndIf						
								
				(cTmpDados)->(DbSkip())	
			EndDo


/*				
				If Rastro(cProduto, "L")
					dbSelectArea('SB8')
					dbSetOrder(3)
					If SB8->(dbSeek(xFilial('SB8')+Padr(cProduto,TamSx3("B8_PRODUTO")[01])+Padr(cArmOri,TamSx3("B8_LOCAL")[01])+Padr(cLote,TamSx3("B8_LOTECTL")[01]),.F.))
						nSaldo := SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmOri,TamSx3("B8_LOCAL")[01]), Padr(cLote,TamSx3("B8_LOTECTL")[01]), NIL, NIL, NIL, NIL, dDataBase)
						
						For nY := 2 to Len(aTransf)
							If 	Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) == cProduto .AND.; 
								Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01]) == cArmOri .AND.;
								Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]) == cLote  						
								
								nQtdLib += aTransf[nY][nPosQuant][2]
							Endif						
						Next
						
						If nSaldo < (nQtdLib+nQtde)
							cErro	 		:= "O SALDO DO LOTE "+ALLTRIM(cLote)+" DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" É INSUFICIENTE (SB8). SALDO ATUAL = "+cValtoChar(SB8->B8_SALDO)+".QUANTIDADE SOLICITADA = "+cValtoChar(nQtde)+"."
							AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
							lMsErroAuto 	:= .T.
							lRet			:= .F.
							Exit
						EndIf 
					Else
						cErro	 		:= "O LOTE "+ALLTRIM(cLote)+" DO PRODUTO "+ALLTRIM(cProduto)+" NO ARMAZEM "+ALLTRIM(cArmOri)+" NAO FOI LOCALIZADO (SB8). QUANTIDADE SOLICITADA = "+cValtoChar(nQtde)+"."
						AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC})
						lMsErroAuto	:= .T.
						lRet			:= .F.
						Exit
					EndIf
								
					DbSelectArea("SD5")
			 		DbSetOrder(1) //D5_FILIAL, D5_NUMLOTE, D5_PRODUTO
					SD5->(dbSeek(xFilial("SD5")+CRIAVAR('D3_LOCALIZ')+cProduto))						
				EndIf
					
			 	DbSelectArea("SB1")
			 	DbSetOrder(1)
			 	If SB1->(dbSeek(xFilial("SB1")+cProduto))
	*/				
					/*
					O Campos necessarios sao:
					Titulo     Campo      Tipo Tamanho Decimal
					---------- ---------- ---- ------- -------
					Prod.Orig. D3_COD      C        15       0
					Desc.Orig. D3_DESCRI   C        30       0
					UM Orig.   D3_UM       C         2       0
					Armazem Or D3_LOCAL    C         2       0
					Endereco O D3_LOCALIZ  C        15       0
					Prod.Desti D3_COD      C        15       0
					Desc.Desti D3_DESCRI   C        30       0
					UM Destino D3_UM       C         2       0
					Armazem De D3_LOCAL    C         2       0
					Endereco D D3_LOCALIZ  C        15       0
					Numero Ser D3_NUMSERI  C        20       0
					Lote       D3_LOTECTL  C        10       0
					Sub-Lote   D3_NUMLOTE  C         6       0
					Validade   D3_DTVALID  D         8       0
					Potencia   D3_POTENCI  N         6       2
					Quantidade D3_QUANT    N        11       2
					Qt 2aUM    D3_QTSEGUM  N        12       2
					Estornado  D3_ESTORNO  C         1       0
					Sequencia  D3_NUMSEQ   C         6       0
					Lote Desti D3_LOTECTL  C        10       0
					Validade D D3_DTVALID  D         8       0
					Item Grade D3_ITEMGRD  C         3       0
					Id DCF     D3_IDDCF    C         6       0
					ObservaCAo D3_OBSERVA  C        30       0
					*/
		/*			
					AADD(aZWJRec, {(cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJREC, (cTmpDados)->B1_COD, (cTmpDados)->D1_LOCAL, (cTmpDados)->ZWJ_DEPERP, (cTmpDados)->D1_LOTECTL})
					
					//Allan Constantino Bonfim - 18/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para o HELP 'A242JACAD' do execauto que não permite que o mesmo produto / lote / endereço seja informado mais de uma vez.
					lSomaQtd := .F.
					
					For nY := 2 to Len(aTransf)					
						If 	aTransf[nY][nPosCod][2] == cProduto .AND. aTransf[nY][nPosLocOri][2] == cArmOri .AND. aTransf[nY][nPosLocal][2] == cArmDest .AND.; 
						 	aTransf[nY][nPosLote][2] == cLote .AND. aTransf[nY][nPosLOri][2] == cLote .AND. aTransf[nY][nPosEOri][2] == cEndOri .AND.; 
						 	aTransf[nY][nPosEDest][2] == cEndDest
						 	lSomaQtd := .T.
						 	Exit
						EndIf
					Next 
										
					If lSomaQtd
						aTransf[nY][nPosQuant][2] 	:= aTransf[nY][nPosQuant][2] + nQtde	
						aTransf[nY][nPosQtd2][2] 	:= ConvUm(cProduto, aTransf[nY][nPosQuant][2], 0.00, 2)
					Else
						AADD(aLinha, {"ITEM"			, StrZero(nItem, 3)					, Nil})
						AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto origem 
						AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto origem 
						AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida origem 
						AADD(aLinha, {"D3_LOCAL"		, cArmOri								, Nil}) //armazem origem 
						AADD(aLinha, {"D3_LOCALIZ"	, cEndOri								, Nil}) //Informar endereCo origem
						AADD(aLinha, {"D3_COD"		, cProduto								, Nil}) //Cod Produto destino
						AADD(aLinha, {"D3_DESCRI"	, cDescProd							, Nil}) //descr produto destino 
						AADD(aLinha, {"D3_UM"		, cUM									, Nil}) //unidade medida destino 
						AADD(aLinha, {"D3_LOCAL"		, cArmDest								, Nil}) //armazem destino 
						AADD(aLinha, {"D3_LOCALIZ"	, cEndDest								, Nil}) //Informar endereCo destino				
						AADD(aLinha, {"D3_NUMSERI"	, CRIAVAR('D3_NUMSERI')				, Nil}) //Numero serie
						AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote Origem
						AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote origem
						AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //data validade 
						AADD(aLinha, {"D3_POTENCI"	, CRIAVAR('D3_POTENCI')				, Nil}) // Potencia
						AADD(aLinha, {"D3_QUANT"		, nQtde								, Nil}) //Quantidade
						AADD(aLinha, {"D3_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)	, Nil}) //Seg unidade medida
						AADD(aLinha, {"D3_ESTORNO"	, CRIAVAR("D3_ESTORNO")				, Nil}) //Estorno 						
						AADD(aLinha, {"D3_NUMSEQ"	, CRIAVAR("D3_NUMSEQ")				, Nil}) // Numero sequencia D3_NUMSEQ				
						AADD(aLinha, {"D3_LOTECTL"	, cLote								, Nil}) //Lote destino
						AADD(aLinha, {"D3_NUMLOTE"	, CRIAVAR('D3_NUMLOTE')				, Nil}) //sublote destino
						AADD(aLinha, {"D3_DTVALID"	, dDataVld								, Nil}) //validade lote destino
						AADD(aLinha, {"D3_ITEMGRD"	, CRIAVAR('D3_ITEMGRD')				, Nil}) //Item Grade
						AADD(aLinha, {"D3_OBSERVA"	, cObserva								, Nil}) //Observacao
						AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod origem
						AADD(aLinha, {"D3_CODLAN"	, CRIAVAR('D3_CODLAN')				, Nil}) //cat83 prod destino
						AADD(aLinha, {"D3_XWMSCOD"	, (cTmpDados)->ZWJ_CODIGO			, Nil}) 
						AADD(aLinha, {"D3_XWMSITM"	, (cTmpDados)->ZWJ_ITEM				, Nil}) 
						AADD(aLinha, {"D3_XWMSDOC"	, (cTmpDados)->D1_DOC				, Nil})  
								    							
						AADD(aTransf, aLinha)					
					EndIf	
				EndIf		

				(cTmpDados)->(DbSkip())	
			EndDo
*/			
			DbSelectArea("SD3")
			
			Begin Transaction
				If Empty(cErro) .AND. Len(aTransf) > 1
				
					//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
					If ValType(cUserName) == "C"
						If Empty(cUserWIS)
							cUserWIS :=  "WIS"
						EndIf
						
						cUserName := Alltrim(cUserWIS)
					EndIf
															
					MSExecAuto({|x,y| MATA261(x,y)}, aTransf, nOpcA)
				EndIf        
				
				aAreaSD3 := SD3->(GetArea())
							
					//Verifica se todos os itens foram movimentados devido a um falto positivo no retorno do execauto
					If !lMsErroAuto
						SD3->(DBOrderNickname("SD3WIS100")) //D3_FILIAL+D3_DOC+D3_COD+D3_LOCAL+D3_LOTECTL+D3_EMISSAO+D3_ESTORNO
						For nY:= 2 to Len(aTransf)					
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+DTOS(dDataBase))) 
								If SD3->D3_ESTORNO = 'S'
									//cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - PRODUTO "+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+" ARMAZEM "+Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01])+" LOTE "+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+" QTDE "+cValtoChar(aTransf[nY][nPosQuant][2])+" (WIS -> PROTHEUS)"
									cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - ERRO EXECAUTO - NAO GEROU O REGISTRO DE TRANSFERENCIA - SD3 (WIS -> PROTHEUS)"
									lMsErroAuto := .T.
									Exit
								EndIf
							Else
								//cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - PRODUTO "+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+" ARMAZEM "+Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01])+" LOTE "+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+" QTDE "+cValtoChar(aTransf[nY][nPosQuant][2])+" (WIS -> PROTHEUS)"
								cErro	:= "FALHA NO PROCESSAMENTO DA TRANSFERENCIA ENTRE ARMAZENS - ERRO EXECAUTO - NAO GEROU O REGISTRO DE TRANSFERENCIA - SD3 (WIS -> PROTHEUS)"
								lMsErroAuto := .T.
								Exit
							EndIf
						Next
					EndIf							                          
																	                             
					If lMsErroAuto // .Or. !SD3->(DbSeek(xFilial("SD3")+cNumDoc+cProduto))							
						lRet := .F.
					  	aLogTMP := GetAutoGRLog()
					  	
					  	If EMPTY(cErro)
					  		cErro := "FALHA NO PROCESSAMENTO DO RETORNO DE NOTAS FISCAIS - PROCESSO "+cProcess+" (WIS -> PROTHEUS)"
					  	EndIf
					  	
						For nY := 1 to Len(aZWJRec)
							
							DbSelectArea("ZWJ")
							ZWJ->(DbGoto(aZWJRec[nY][2]))	
							
							cDescErro	:= ""
							cSolucao 	:= ""
													
					  		U_WWSTATUS("ZWJ", aZWJRec[nY][2], "95", cErro)	
											  	
					    	If Len(aLogTMP) > 0
					    		If Len(aLogTMP) >= 7
					    			cSolucao := Alltrim(AllToChar(aLogTMP[7]))
					    		EndIf
				    			For nX := 1 to Len(aLogTMP)
				    				If !EMPTY(cDescErro)
				    					cDescErro += " - "	
				    				EndIf
				    			
				    				cDescErro += AllToChar(aLogTMP[nX])	
				    			Next					
							EndIf
							
							//cDescErro += CHR(13)+CHR(10)+" EXECAUTO MATA261 - ARRAY (aTransf) "+CHR(13)+CHR(10)+VarInfo("aTransf", aTransf, , .F.)

							U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01MOV",, IIF (!Empty(cErro), "3", "4"), cErro, ERRO95, cDescErro, cSolucao, "95")						
						Next					
					Else						 
						For nY := 1 to Len(aZWJRec)						
							DbSelectArea("ZWJ")
							ZWJ->(DbGoto(aZWJRec[nY][2]))	
	
							U_WWSTATUS("ZWJ", aZWJRec[nY][2], "05")				
	
							If lGrvLogOk
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01MOV",, "0",,,,, "05")						
							EndIf		
						Next
						
						DbSelectArea("SD3")
						SD3->(DBOrderNickname("SD3WIS100")) //D3_FILIAL+D3_DOC+D3_COD+D3_LOCAL+D3_LOTECTL+D3_EMISSAO+D3_ESTORNO
						
						For nY:= 2 to Len(aTransf)
							
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01])+DTOS(dDataBase))) 
								While 	!SD3->(EOF()) .AND. SD3->D3_DOC == Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01]) .AND.; 
										SD3->D3_COD == Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) .AND.; 
										SD3->D3_LOCAL == Padr(aTransf[nY][nPosLocal][2], TamSx3("D3_LOCAL")[01]) .AND.;
										SD3->D3_LOTECTL == Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]) .AND.; 	
										SD3->D3_EMISSAO == dDataBase
										 				
						 			//If Empty(SD3->D3_ESTORNO) .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)
						 			If Empty(SD3->D3_ESTORNO) .AND. SD3->D3_QUANT == aTransf[nY][nPosQuant][2] .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)
		 								//Allan Constantino Bonfim - 18/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para o HELP 'A242JACAD' do execauto que não permite que o mesmo produto / lote / endereço seja informado mais de uma vez.				 						 																						
										For nZ := 1 to Len(aZWJRec)
											If 	SD3->D3_COD == aZWJRec[nZ][3] .AND. SD3->D3_LOCAL == Padr(aZWJRec[nZ][5], TamSx3("D3_LOCAL")[01]) //.AND. SD3->D3_LOTECTL == Padr(aZWJRec[nZ][6], TamSx3("D3_LOTECTL")[01])
												
												DbSelectArea("ZWJ")
												ZWJ->(DbGoto(aZWJRec[nZ][2]))					
												U_WW01PROC("ZWJ", ZWJ->(RECNO()), "SD3", SD3->(RECNO()), SD3->D3_DOC)
												
												//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
												Reclock("SD3", .F.)
										    		SD3->D3_XWMSCOD := ZWJ->ZWJ_CODIGO
										    		SD3->D3_XWMSITM := ZWJ->ZWJ_ITEM
										    		SD3->D3_XWMSDOC := ZWJ->ZWJ_NOTA
										    		SD3->D3_USUARIO := ZWJ->ZWJ_NOMFUN
										    		SD3->D3_XWMSPRO := cProcess
										    	SD3->(MsUnlock())											
											EndIf
										Next
								    	Exit
								    EndIf
				    								    									    				
				    				SD3->(DbSkip())
					    		EndDo
							EndIf
							
							//MOVIMENTO ORIGINAL - RE4
							If SD3->(DbSeek(xFilial("SD3")+Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01])+Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01])+Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01])+Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]))) 
								While 	!SD3->(EOF()) .AND. SD3->D3_DOC == Padr(aTransf[1][nPosDoc], TamSx3("D3_DOC")[01]) .AND.; 
										SD3->D3_COD == Padr(aTransf[nY][nPosCod][2], TamSx3("D3_COD")[01]) .AND.; 
										SD3->D3_LOCAL == Padr(aTransf[nY][nPosLocOri][2], TamSx3("D3_LOCAL")[01]) .AND.;
										SD3->D3_LOTECTL == Padr(aTransf[nY][nPosLote][2], TamSx3("D3_LOTECTL")[01]) 	
	
						 			//If Empty(SD3->D3_ESTORNO) .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO)
						 			If Empty(SD3->D3_ESTORNO) .AND. SD3->D3_QUANT == aTransf[nY][nPosQuant][2] .AND. ALLTRIM(SD3->D3_OBSERVA) == ALLTRIM(ZWJ->ZWJ_CODIGO) 						 										    	
										//Allan Constantino Bonfim - 18/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para o HELP 'A242JACAD' do execauto que não permite que o mesmo produto / lote / endereço seja informado mais de uma vez.
										For nZ := 1 to Len(aZWJRec)
											If 	SD3->D3_COD == aZWJRec[nZ][3] .AND. SD3->D3_LOCAL == Padr(aZWJRec[nZ][4], TamSx3("D3_LOCAL")[01]) //.AND. SD3->D3_LOTECTL == Padr(aZWJRec[nZ][6], TamSx3("D3_LOTECTL")[01])
												
												DbSelectArea("ZWJ")
												ZWJ->(DbGoto(aZWJRec[nZ][2]))					
												U_WW01PROC("ZWJ", ZWJ->(RECNO()), "SD3", SD3->(RECNO()), SD3->D3_DOC)
												
												//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
												Reclock("SD3", .F.)
										    		SD3->D3_XWMSCOD := ZWJ->ZWJ_CODIGO
										    		SD3->D3_XWMSITM := ZWJ->ZWJ_ITEM
										    		SD3->D3_XWMSDOC := ZWJ->ZWJ_NOTA
										    		SD3->D3_USUARIO := ZWJ->ZWJ_NOMFUN
										    		SD3->D3_XWMSPRO := cProcess
										    	SD3->(MsUnlock())											
											EndIf
										Next
										Exit
								    EndIf
				    								    									    				
				    				SD3->(DbSkip())
					    		EndDo
							EndIf															    
						Next	    		 		    		   
				    EndIf
				     				    
				RestArea(aAreaSD3)
					    						
				If lRet
					cQTotIt := "SELECT COUNT(ZWJ_CODIGO) AS QTDITEM "+CHR(13)+CHR(10)
					cQTotIt += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
					cQTotIt += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_CALIAS = 'SD1' "+CHR(13)+CHR(10)
					cQTotIt += "AND (ZWJ_STATUS = '04' OR ZWJ_STATUS > '50') "+CHR(13)+CHR(10)		
					cQTotIt += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
					cQTotIt += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)	
				
					If Select(cTmpTotIt) > 0
						(cTmpTotIt)->(DbCloseArea())
					EndIf
			
					cQTotIt := ChangeQuery(cQTotIt)	
					dbUseArea(.T., "TOPCONN", TcGenQry(,,cQTotIt), cTmpTotIt)	
	
					If EMPTY((cTmpTotIt)->QTDITEM) 							
						U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "05")
						
						If lGrvLogOk
							DbSelectArea("ZWI")
							ZWI->(DbGoTo((cTmpCab)->ZWIREC))
							U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01MOV",, "0",,,,, "05")
						EndIf
					Else
						U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
					EndIf
				Else
					U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
				EndIf
						
			End Transaction
	
		(cTmpCab)->(DbSkip())	
	EndDo

	If Select(cTmpTotIt) > 0
		(cTmpTotIt)->(DbCloseArea())
	EndIf

	If Select(cTmpDados) > 0
		(cTmpDados)->(DbCloseArea())
	EndIf

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf
EndIf


RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIS001CQ

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  09/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIS001CQ(nOpcA, cProcess)

Local aArea				:= GetArea()
Local lRet 				:= .T.
Local aLibCq 				:= {}
Local aSD7	 				:= {}
Local cQuery				:= ""
Local cQDados				:= ""
Local cQueryCab			:= ""
Local cQTotIt				:= ""
Local cTmpCab				:= GetNextAlias()
Local cTmpQuery			:= GetNextAlias()
Local cTmpDados			:= GetNextAlias()
Local cTmpTotIt			:= GetNextAlias()
Local aLogTMP				:= {}
Local cEmpWis				:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) //PADR(IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')), TAMSX3("ZWK_EMPRES")[1], " ")
Local cFilWis				:= PADL(FWCodFil(), 3, "0")   
Local cErro				:= "FALHA NA LIBERACAO DO CQ NO PROCESSAMENTO DO RETORNO WIS - PROCESSO "+cProcess+" (WIS -> PROTHEUS)"
Local cDescErro			:= ""
Local cSolucao			:= ""
Local cProduto			:= ""
//Local cDescProd			:= ""
//Local cUM					:= ""		
Local cArmOri 			:= ""
Local cArmDest			:= ""
Local nQtdLib				:= 0
Local nTipoCq				:= 0
Local cObserv				:= ""
Local cMotRej				:= ""
Local nQtdTotCq			:= 0
Local nQtdTotal			:= 0
Local aLogRecno			:= {}
Local aLogSD7				:= {}
Local aLogZWJ				:= {}
//Local a96SD7				:= {}
Local nX					:= 0
Local nY					:= 0
Local lGrvLogOk			:= GetMv("MV_ZZWMSLT",, .T.)
Local nQtde				:= 0
Local lSD7Ok				:= .F.
//Local lSC9Est				:= .F.
//Local cUsrSD7		 		:= "WIS"
Local cSD7Fil 			:= "" 
Local cSD7Doc 			:= ""
Local cSD7Prd 			:= ""	
Local cUserWIS			:= "WIS"
Local aAreaSD7
Local aAreaSD3

Local cMvZZWMSCQ := GetMv("MV_ZZWMSCQ",, "FH")
Local cMvZZWAMNR := GetMv("MV_ZZWAMNR",, "96")


Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.  
Private lMsHelpAuto    	:= .T.

Default nOpcA				:= 0
Default cProcess 			:= ""

If !EMPTY(nOpcA) .AND. !EMPTY(cProcess) // $ "011"	

	cQueryCab := "SELECT DISTINCT ZWI_CODIGO, ZWI.R_E_C_N_O_ AS ZWIREC "+CHR(13)+CHR(10)
	cQueryCab += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQueryCab += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)	
	cQueryCab += "AND ZWI_CALIAS = 'SF1' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_SITUAC = '9' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
	cQueryCab += "ORDER BY ZWI_CODIGO "+CHR(13)+CHR(10)

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf
	
	cQueryCab := ChangeQuery(cQueryCab)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCab),cTmpCab)	
	
	While !(cTmpCab)->(EOF())
	
		//Begin Transaction
			
		lRet := .T.
		lMsErroAuto := .F.
								
		cQuery := "SELECT DISTINCT ZWI_CODIGO, ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ_ITEM "+CHR(13)+CHR(10)
		cQuery += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_CALIAS = 'SF1' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_SITUAC = '9' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)			
		cQuery += "ORDER BY ZWI_CODIGO, ZWJ_ITEM "+CHR(13)+CHR(10)
	
		If Select(cTmpQuery) > 0
			(cTmpQuery)->(DbCloseArea())
		EndIf
		
		cQuery := ChangeQuery(cQuery)	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpQuery)	
		
		Begin Transaction
		
			aLogRecno		:= {}
							
			While !(cTmpQuery)->(EOF())
						
				cQDados := "SELECT ZWJ_CODIGO, ZWJ_ITEM, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ_DEPERP, ZWJ_QTDE, ZWJ_QTDCNF, ZWJ_QTDAVA, "+CHR(13)+CHR(10)
				//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
				cQDados += "ZWJ_NOMFUN, B1_COD, B1_DESC, B1_UM, D1_UM, D1_LOCAL, D1_LOTECTL, D1_LOTEFOR, D1_DTVALID, D1_NUMSEQ, D1_NUMCQ, "+CHR(13)+CHR(10)
				cQDados += "(SELECT ISNULL(SUM(ZWJ_QTDCNF+ZWJ_QTDAVA),0) AS QTDTOT FROM " +RetSqlName("ZWJ")+" ZWJ1 (NOLOCK) WHERE ZWJ1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
				cQDados += "AND ZWJ1.ZWJ_EMPRES = ZWJ.ZWJ_EMPRES AND ZWJ1.ZWJ_CODIGO = ZWJ.ZWJ_CODIGO AND ZWJ1.ZWJ_ITEM = ZWJ.ZWJ_ITEM "+CHR(13)+CHR(10) 
				cQDados += "AND ZWJ_CALIAS = 'SD1' AND ZWJ_STATUS = '04' AND ZWJ_SITUAC = '9' AND ZWJ1.ZWJ_PROCES = ZWJ1.ZWJ_PROCES) AS QTDTOT "+CHR(13)+CHR(10)
				//cQDados += ",(SELECT COUNT(*) AS QTD FROM " +RetSqlName("SD7")+ " SD7 (NOLOCK) WHERE SD7.D_E_L_E_T_ = ' ' AND SD7.D7_ESTORNO <> 'S' AND SD7.D7_LOCDEST = ZWJ.ZWJ_DEPERP "+CHR(13)+CHR(10) 
				//cQDados += "AND CAST(SD7.D7_XWMSCOD AS VARCHAR(20)) = CAST(ZWJ.ZWJ_CODIGO  AS VARCHAR(20)) AND SD7.D7_XWMSITM = ZWJ.ZWJ_ITEM) AS QTDSD7 "+CHR(13)+CHR(10) 			
				cQDados += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("SD1")+" SD1 (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (D1_FILIAL = '"+xFilial("SD1")+"' AND ZWJ_RECORI = SD1.R_E_C_N_O_ AND SD1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("SB1")+" SB1 (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZWJ_PRODUT AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
				cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_CALIAS = 'SD1' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_STATUS = '04' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_SITUAC = '9' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)				
				cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_CODIGO = '"+(cTmpQuery)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_ITEM = '"+(cTmpQuery)->ZWJ_ITEM+"' "+CHR(13)+CHR(10)
				cQDados += "ORDER BY ZWJ_CODIGO, ZWJ_ITEM "+CHR(13)+CHR(10)	
		
				If Select(cTmpDados) > 0
					(cTmpDados)->(DbCloseArea())
				EndIf
				
				cQDados := ChangeQuery(cQDados)	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	
				 
				nQtdLib		:= 0
				aLogSD7		:= {}
				aLogZWJ		:= {}
				//a96SD7			:= {}
				aSD7			:= {}				
				lSD7Ok			:= .F.
				//cUsrSD7 		:= "WIS"
									
				While !(cTmpDados)->(EOF())

					aLibCq		:= {}
					cDescErro	:= ""
					cProduto	:= Padr((cTmpDados)->B1_COD,TamSx3("B2_COD")[01])
					cArmOri 	:= Padr((cTmpDados)->D1_LOCAL,TamSx3("B2_LOCAL")[01])
					cArmDest	:= Padr((cTmpDados)->ZWJ_DEPERP,TamSx3("B2_LOCAL")[01])
					cObserv	:= "PROCESSO WMS Nº "+ALLTRIM((cTmpDados)->ZWJ_CODIGO)+" - ITEM "+ALLTRIM((cTmpDados)->ZWJ_ITEM)						
					cUserWIS 	:= (cTmpDados)->ZWJ_NOMFUN
					
					nQtdTotCq	:= (cTmpDados)->QTDTOT 
					nQtdTotal	:= (cTmpDados)->ZWJ_QTDE
										 						
					If !EMPTY((cTmpDados)->ZWJ_QTDAVA)	.OR. !EMPTY((cTmpDados)->ZWJ_QTDCNF)									
						
						If !EMPTY((cTmpDados)->ZWJ_QTDAVA)
							nQtde		:=	(cTmpDados)->ZWJ_QTDAVA
							nTipoCq	:= 2
							cMotRej	:= cMvZZWMSCQ
						Else
							nQtde		:=	(cTmpDados)->ZWJ_QTDCNF
							nTipoCq	:= 1
							cMotRej	:= ""
						EndIf
					
						nQtdLib += nQtde
			
					 	DbSelectArea("SB2")
					 	DbSetOrder(1)	
						//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
						If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmOri,TamSx3("B2_LOCAL")[01])))
							CriaSB2(cProduto,cArmOri)
						EndIf
				
						If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cArmDest,TamSx3("B2_LOCAL")[01])))
							CriaSB2(cProduto,cArmDest)
						EndIf
													
						DbSelectArea("SD7")
					 	//SD7->(DbSetOrder(3))	//D7_FILIAL, D7_PRODUTO, D7_NUMSEQ, D7_NUMERO
					 	//If SD7->(dbSeek(xFilial('SD7')+cProduto+Padr((cTmpDados)->D1_NUMSEQ,TamSx3("D7_NUMSEQ")[01])))
					 	SD7->(DbSetOrder(2)) //D7_FILIAL, D7_NUMERO, D7_PRODUTO, D7_LOCAL, D7_NUMSEQ, D7_TIPO
						If SD7->(dbSeek(xFilial('SD7')+Padr((cTmpDados)->D1_NUMCQ,TamSx3("D7_NUMERO")[01])+cProduto+cArmOri+Padr((cTmpDados)->D1_NUMSEQ,TamSx3("D7_NUMSEQ")[01])))
							lSD7Ok := .T.
																					
							//AADD(aLibCq, {"D7_SEQ" 	 	, cNumSeq													,Nil})  // Sequencia
							AADD(aLibCq, {"D7_TIPO"   	, nTipoCq													,Nil})  // 1=Libera o item do CQ / 2=Rejeita o item do CQ
							AADD(aLibCq, {"D7_DATA"   	, dDataBase												,Nil})  // Data
							AADD(aLibCq, {"D7_QTDE"   	, nQtde													,Nil})  // Quantidade
							AADD(aLibCq, {"D7_OBS"    	, cObserv													,Nil})  // ObservaCões
							AADD(aLibCq, {"D7_QTSEGUM"	, ConvUm(cProduto, nQtde, 0.00, 2)						,Nil})  // Quant. 2ªUM
							AADD(aLibCq, {"D7_MOTREJE"	, cMotRej													,Nil})  // Motivo RejeiCAo
							AADD(aLibCq, {"D7_LOCDEST"	, cArmDest													,Nil})  // Local Destino
							AADD(aLibCq, {"D7_SALDO"  	, NIL       												,Nil})  // Saldo
							AADD(aLibCq, {"D7_SALDO2"	, ConvUm(cProduto, (nQtdTotal - nQtdLib), 0.00, 2)	,Nil})  // Saldo 2ªUM
							AADD(aLibCq, {"D7_ESTORNO"	, NIL                                               	,Nil})  // Estorno
							//AADD(aLibCq, {"D7_LOCALIZ", oMSNewGe1:aCols[ _x ][ aScan(oMSNewGe1:aHeader,{|x| AllTrim(x[2])=="D7_LOCALIZ"    }) ]  									,Nil})  // EndereCo
							//AADD(aLibCq, {"D7_NUMSERI", oMSNewGe1:aCols[ _x ][ aScan(oMSNewGe1:aHeader,{|x| AllTrim(x[2])=="D7_NUMSERI"    }) ]  									,Nil})  // Numero Serie
							AADD(aLibCq, {"D7_XWMSCOD" 	, (cTmpDados)->ZWJ_CODIGO								,Nil})  // Codigo Processo
							AADD(aLibCq, {"D7_XWMSITM" 	, (cTmpDados)->ZWJ_ITEM									,Nil})  // Item Processo
		
							AADD(aSD7, aClone(aLibCq))				
							
							AADD(aLogRecno, (cTmpDados)->ZWJREC)
							AADD(aLogSD7, SD7->(RECNO()))
							AADD(aLogZWJ, (cTmpDados)->ZWJREC)
						EndIf
					
					ElseIf nQtdTotal <> nQtdTotCq .AND. !lSD7Ok
					
					 	DbSelectArea("SB2")
					 	DbSetOrder(1)	
						//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
						If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cMvZZWAMNR,TamSx3("B2_LOCAL")[01])))
							CriaSB2(cProduto, cMvZZWAMNR)
						EndIf

						DbSelectArea("SD7")
					 	//SD7->(DbSetOrder(3))	//D7_FILIAL, D7_PRODUTO, D7_NUMSEQ, D7_NUMERO
					 	//If SD7->(dbSeek(xFilial('SD7')+cProduto+Padr((cTmpDados)->D1_NUMSEQ,TamSx3("D7_NUMSEQ")[01])))
					 	SD7->(DbSetOrder(2)) //D7_FILIAL, D7_NUMERO, D7_PRODUTO, D7_LOCAL, D7_NUMSEQ, D7_TIPO
						If SD7->(dbSeek(xFilial('SD7')+Padr((cTmpDados)->D1_NUMCQ,TamSx3("D7_NUMERO")[01])+cProduto+cArmOri+Padr((cTmpDados)->D1_NUMSEQ,TamSx3("D7_NUMSEQ")[01])))
										
							//AADD(aLibCq, {"D7_SEQ" 	 	, cNumSeq													,Nil})  // Sequencia
							AADD(aLibCq, {"D7_TIPO"   	, 1															,Nil})  // 1=Libera o item do CQ / 2=Rejeita o item do CQ
							AADD(aLibCq, {"D7_DATA"   	, dDataBase												,Nil})  // Data
							AADD(aLibCq, {"D7_QTDE"   	, (nQtdTotal - nQtdTotCq)								,Nil})  // Quantidade
							AADD(aLibCq, {"D7_OBS"    	, cObserv													,Nil})  // ObservaCões
							AADD(aLibCq, {"D7_QTSEGUM"	, ConvUm(cProduto, (nQtdTotal - nQtdTotCq), 0.00, 2)	,Nil})  // Quant. 2ªUM
							AADD(aLibCq, {"D7_MOTREJE"	, NIL														,Nil})  // Motivo RejeiCAo
							AADD(aLibCq, {"D7_LOCDEST"	, cMvZZWAMNR												,Nil})  // Local Destino
							AADD(aLibCq, {"D7_SALDO"  	, NIL       												,Nil})  // Saldo
							AADD(aLibCq, {"D7_SALDO2" 	, ConvUm(cProduto, (nQtdTotal - nQtdTotCq), 0.00, 2)	,Nil})  // Saldo 2ªUM
							AADD(aLibCq, {"D7_ESTORNO" 	, NIL														,Nil})  // Estorno
							AADD(aLibCq, {"D7_XWMSCOD" 	, (cTmpDados)->ZWJ_CODIGO								,Nil})  // Codigo Processo
							AADD(aLibCq, {"D7_XWMSITM" 	, (cTmpDados)->ZWJ_ITEM									,Nil})  // Item Processo
							
							AADD(aSD7, aClone(aLibCq))								
							AADD(aLogRecno, (cTmpDados)->ZWJREC)
							AADD(aLogZWJ, (cTmpDados)->ZWJREC)
							AADD(aLogSD7, SD7->(RECNO()))
						EndIf	
					EndIf
								
					(cTmpDados)->(DbSkip())
										
				EndDo
		
				If nQtdTotal <> nQtdTotCq .AND. lSD7Ok //Materiais nAo recebidos(faltantes), endereCar no local 96				
					aLibCq		:= {}
		
				 	DbSelectArea("SB2")
				 	DbSetOrder(1)	
					//-- Posiciona (ou Cria) o Arquivo de Saldos (SB2)
					If !SB2->(dbSeek(xFilial('SB2')+Padr(cProduto,TamSx3("B2_COD")[01])+Padr(cMvZZWAMNR,TamSx3("B2_LOCAL")[01])))
						CriaSB2(cProduto, cMvZZWAMNR)
					EndIf
								
					//AADD(aLibCq, {"D7_SEQ" 	 	, cNumSeq													,Nil})  // Sequencia
					AADD(aLibCq, {"D7_TIPO"   	, 1															,Nil})  // 1=Libera o item do CQ / 2=Rejeita o item do CQ
					AADD(aLibCq, {"D7_DATA"   	, dDataBase												,Nil})  // Data
					AADD(aLibCq, {"D7_QTDE"   	, (nQtdTotal - nQtdTotCq)								,Nil})  // Quantidade
					AADD(aLibCq, {"D7_OBS"    	, cObserv													,Nil})  // ObservaCões
					AADD(aLibCq, {"D7_QTSEGUM"	, ConvUm(cProduto, (nQtdTotal - nQtdTotCq), 0.00, 2)	,Nil})  // Quant. 2ªUM
					AADD(aLibCq, {"D7_MOTREJE"	, NIL														,Nil})  // Motivo RejeiCAo
					AADD(aLibCq, {"D7_LOCDEST"	, cMvZZWAMNR											,Nil})  // Local Destino
					AADD(aLibCq, {"D7_SALDO"  	, NIL       												,Nil})  // Saldo
					AADD(aLibCq, {"D7_SALDO2" 	, ConvUm(cProduto, (nQtdTotal - nQtdTotCq), 0.00, 2)	,Nil})  // Saldo 2ªUM
					AADD(aLibCq, {"D7_ESTORNO" 	, NIL														,Nil})  // Estorno
					AADD(aLibCq, {"D7_XWMSCOD" 	, (cTmpQuery)->ZWI_CODIGO								,Nil})  // Codigo Processo
					AADD(aLibCq, {"D7_XWMSITM" 	, NIL														,Nil})  // Item Processo
					
					AADD(aSD7, aClone(aLibCq))
					//AADD(a96SD7, SD7->(RECNO()))			
				EndIf
									
				If Len(aSD7) > 0
				
					//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
					If ValType(cUserName) == "C"
						If Empty(cUserWIS)
							cUserWIS :=  "WIS"
						EndIf
						
						cUserName := Alltrim(cUserWIS)
					EndIf
					
					lMsErroAuto := .F.
					MSExecAuto({|x,y| MATA175(x,y)}, aSD7, nOpcA) 	

					//Allan Constantino Bonfim - 31/11/2018 - CM Solutions - Projeto WMS 100% - Revalidação do execauto para resolver o problema de retorno falso positivo. 
		    		aAreaSD3 := SD3->(GetArea())
			    		SD3->(DbSetOrder(2)) //D3_FILIAL, D3_DOC, D3_COD
					    If !SD3->(DbSeek(xFilial("SD3")+Padr(SD7->D7_NUMERO,TamSx3("D3_DOC")[01])+SD7->D7_PRODUTO))
							lMsErroAuto := .T.
						EndIf
					RestArea(aAreaSD3)
					
					If lMsErroAuto
						lRet := .F.
						
						aLogTMP := GetAutoGRLog()
						
						//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
						For nX := 1 to Len(aLogZWJ)
							U_WWSTATUS("ZWJ", aLogZWJ[nX], "95")	
							  	
							DbSelectArea("ZWJ")
							ZWJ->(DbGoto(aLogZWJ[nX]))	
							
							cErro 		:= "FALHA NO PROCESSAMENTO DA LIBERACAO DO CQ - "+cObserv
							cDescErro	:= ""
							cSolucao 	:= ""
											  	
					    	If Len(aLogTMP) > 0
					    		If Len(aLogTMP) >= 7
					    			cSolucao := Alltrim(AllToChar(aLogTMP[7]))
					    		EndIf
				    			For nY := 1 to Len(aLogTMP)
				    				If !EMPTY(cDescErro)
				    					cDescErro += " - "	
				    				EndIf
				    			
				    				cDescErro += AllToChar(aLogTMP[nY])			    		
				    			Next					
							EndIf
							
							//cDescErro += CHR(13)+CHR(10)+" EXECAUTO MATA175 - ARRAY (aSD7) "+CHR(13)+CHR(10)+VarInfo("aSD7", aSD7, , .F.)
							
							U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS001CQ",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")							  	  		
						Next
					
					Else
						//Allan Constantino Bonfim - 03/12/2018 - CM Solutions - Projeto WMS 100% - Gravação dos usuários do WIS nas movimentações
						For nX := 1 to Len(aLogSD7)
						
					    	aAreaSD7 := SD7->(GetArea())
					    		SD7->(DbGoto(aLogSD7[nX]))

					    		cSD7Fil := SD7->D7_FILIAL 
					    		cSD7Doc := SD7->D7_DOC
					    		cSD7Prd := SD7->D7_PRODUTO	
					    		
								DbSelectArea("ZWJ")
								ZWJ->(DbGoto(aLogRecno[nX]))
								
								
					    		//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
					    		While 	!SD7->(EOF()) .AND. SD7->D7_FILIAL == cSD7Fil .AND. SD7->D7_DOC == cSD7Doc .AND. SD7->D7_PRODUTO == cSD7Prd 					    		
					    			If SD7->D7_TIPO == 1 
					    				If (SD7->D7_XWMSCOD == ZWJ->ZWJ_CODIGO .AND. SD7->D7_XWMSITM == ZWJ->ZWJ_ITEM) .OR. (SD7->D7_XWMSCOD == ZWJ->ZWJ_CODIGO .AND. EMPTY(SD7->D7_XWMSITM))				    							    									    			
							    			Reclock("SD7", .F.)
								    			SD7->D7_XWMSCOD := ZWJ->ZWJ_CODIGO
								    			SD7->D7_XWMSITM := ZWJ->ZWJ_ITEM
								    			
								    			If Empty(SD7->D7_USUARIO)
								    				SD7->D7_USUARIO := ZWJ->ZWJ_NOMFUN
								    			EndIf
							    			SD7->(MsUnlock())
						    		
					    					U_WW01PROC("ZWJ", aLogRecno[nX], "SD7", aLogSD7[nX], SD7->D7_NUMERO)
					    									
								    		//DbSelectArea("SD3")
								    		aAreaSD3 := SD3->(GetArea())
									    		SD3->(DbSetOrder(2)) //D3_FILIAL, D3_DOC, D3_COD
											    If SD3->(DbSeek(SD7->D7_FILIAL+Padr(SD7->D7_NUMERO,TamSx3("D3_DOC")[01])+Padr(SD7->D7_PRODUTO,TamSx3("D3_COD")[01])))
										    		While 	!SD3->(EOF()) .AND. SD3->D3_FILIAL = SD7->D7_FILIAL .AND. SD3->D3_DOC = Padr(SD7->D7_NUMERO,TamSx3("D3_DOC")[01]) .AND.; 
										    				SD3->D3_COD = +Padr(SD7->D7_PRODUTO,TamSx3("D3_COD")[01])
										    				
										    				If Empty(SD3->D3_ESTORNO) .AND. SD3->D3_NUMSEQ = Padr(SD7->D7_NUMSEQ,TamSx3("D3_NUMSEQ")[01])
												    			//CM Solutions - Allan Constanino Bonfim - Chamado 22244 - Correção para a gravação dos usuários na geração dos registros nas tabelas SD7 e SD3
												    			Reclock("SD3", .F.)
									    							SD3->D3_XWMSCOD := SD7->D7_XWMSCOD
									    							SD3->D3_XWMSITM := SD7->D7_XWMSITM
									    							SD3->D3_XWMSPRO := cProcess
									    							If Empty(SD3->D3_USUARIO)
									    								SD3->D3_USUARIO := ZWJ->ZWJ_NOMFUN
									    							EndIf
									    						SD3->(MsUnlock())
									    					EndIf
									    					
								    					SD3->(DbSkip())
										    		EndDo				
										    	EndIf
										  	RestArea(aAreaSD3)
								  		EndIf
								  	EndIf
								  	SD7->(DbSkip())
								EndDo  
						   	RestArea(aAreaSD7)	    		 		    		 
							
							If lGrvLogOk
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS001CQ",, "0",,,,, "05")						
						    EndIf
							
						Next

					EndIf
				EndIf	     

				(cTmpQuery)->(DbSkip())	
			EndDo

			If lRet
			
				For nX := 1 to Len(aLogRecno)																		
					U_WWSTATUS("ZWJ", aLogRecno[nX], "05")	
				Next
							
				cQTotIt := "SELECT COUNT(ZWJ_CODIGO) AS QTDITEM "+CHR(13)+CHR(10)
				cQTotIt += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
				cQTotIt += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQTotIt += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
				cQTotIt += "AND ZWJ_CALIAS = 'SD1' "+CHR(13)+CHR(10)
				cQTotIt += "AND (ZWJ_STATUS = '04' OR ZWJ_STATUS > '50') "+CHR(13)+CHR(10)		
				cQTotIt += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
				cQTotIt += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
				cQTotIt += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQTotIt += "AND ZWJ_CODIGO = '"+(cTmpCab)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
			
				If Select(cTmpTotIt) > 0
					(cTmpTotIt)->(DbCloseArea())
				EndIf
		
				cQTotIt := ChangeQuery(cQTotIt)	
				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQTotIt), cTmpTotIt)	

				If EMPTY((cTmpTotIt)->QTDITEM) 							
					U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "05")
					
					If lGrvLogOk
						DbSelectArea("ZWI")
						ZWI->(DbGoTo((cTmpCab)->ZWIREC))
						U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS001CQ",, "0",,,,, "05")
					EndIf					
				Else
					U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
				EndIf
			Else
				U_WWSTATUS("ZWI", (cTmpCab)->ZWIREC, "95")
			EndIf			
		
		End Transaction
										
		(cTmpCab)->(DbSkip())	
	EndDo

	If Select(cTmpCab) > 0
		(cTmpCab)->(DbCloseArea())
	EndIf

	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf

	If Select(cTmpDados) > 0
		(cTmpDados)->(DbCloseArea())
	EndIf
		
EndIf


RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIS01LPD

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  14/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIS01LPD(cProcess)

Local aArea     	:= GetArea()
Local aAreaC5   	:= SC5->(GetArea())
Local aAreaC6   	:= SC6->(GetArea())
Local aAreaC9   	:= SC9->(GetArea())
Local aAreaA1   	:= SA1->(GetArea())
Local aAreaA2   	:= SA2->(GetArea())
Local aAreaB1   	:= SB1->(GetArea())
Local cLiberOk 	:= ""
Local cSC6Lotect	:= ""
Local cSC6Lote 	:= ""
Local cSC6Locali	:= ""
Local cSC6NumSer	:= ""
Local dSC6DtVld	:= CTOD("")
Local cSC6Poten	:= ""
Local cIdDCF  	:= ""
Local cStServ 	:= ""		
Local cMercanet 	:= "" 
Local lIntWms 	:= .T. 
Local lProcessa 	:= .T.
Local cFase		:= ""
Local cSEQCAR		:= "" 
Local cSEQENT		:= ""
Local nLibPed		:= 0 
Local cDescErro	:= ""
Local cErro		:= ""
Local cSolucao	:= ""
Local lRet 		:= .T.
Local cQuery		:= ""
Local cQDados		:= ""
Local cQueryCab	:= ""
Local cTmpZWI		:= GetNextAlias()
Local cTmpQuery	:= GetNextAlias()
Local cTmpDados	:= GetNextAlias()
Local cEmp			:= FWCodEmp()
Local cCodEmp		:= PADR(IIf(cEmp=='01','2',iif(cEmp=='02','1','')), TAMSX3("ZWJ_EMPRES")[1], " ")
Local lNovaLib	:= .F.
Local nRecSC6 	:= 0
Local nRecSC9		:= 0 
Local cRomaneio	:= ""
Local aDadosZWI	:= {}
Local nX			:= 0
Local lGrvLogOk	:= GetMv("MV_ZZWMSLT",, .T.)
Local lDelPed		:= .F.
Local aAreaAux 

Default cProcess := ""


If !EMPTY(cProcess)	

	cQueryCab := "SELECT DISTINCT ZWI_EMPRES, ZWI_PROCES, ZWI_CODIGO, ZWI_SITUAC, ZWI_PEDORI, ZWI_CARGA, ZWI_RECORI, ZWI.R_E_C_N_O_ AS ZWIREC "+CHR(13)+CHR(10)
	cQueryCab += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQueryCab += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_CALIAS = 'SC5' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_EMPRES = '"+cCodEmp+"' "+CHR(13)+CHR(10)
	cQueryCab += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
	cQueryCab += "ORDER BY ZWI_CODIGO "+CHR(13)+CHR(10)

	If Select(cTmpZWI) > 0
		(cTmpZWI)->(DbCloseArea())
	EndIf
	
	cQueryCab := ChangeQuery(cQueryCab)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCab),cTmpZWI)	
	
	While !(cTmpZWI)->(EOF())
		
		lRet 		:= .T.
		lDelPed	:= .F.
				
		//Begin Transaction
		
			If ALLTRIM((cTmpZWI)->ZWI_SITUAC) == "68"
				lDelPed := .T.
				
				cRomaneio := PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")
				
				//CM Solutions - Allan Constantino Bonfim - 16/10/2020 - Chamado 34012 - Romaneio não interga no WIS. Ajuste na rotina de liberação do romaneio.
				If U_XRPVROMA(cRomaneio, (cTmpZWI)->ZWI_RECORI)
					AADD(aDadosZWI, {ALLTRIM((cTmpZWI)->ZWI_EMPRES), ALLTRIM((cTmpZWI)->ZWI_PROCES), PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")})
				Else
					lRet := .F.
					
					//Allan Constantino Bonfim - 31/10/2018 - CM Solutions - Projeto WMS 100% - Correção de error.log na atualização dos status do romaneio.
					DbSelectArea("ZWI")
					ZWI->(DbGoto((cTmpZWI)->ZWIREC))
					cErro		:= "ERRO NA EXCLUSAO DO PEDIDO "+ALLTRIM((cTmpZWI)->ZWI_PEDORI)+" DO ROMANEIO "+ALLTRIM(cRomaneio)+"."
					cDescErro	:= "FUNCAO U_XRPVROMA"
					cSolucao 	:= "VERIFICAR CORRECAO JUNTO AO TI."
					
					U_WWSTATUS("ZWI", (cTmpZWI)->ZWIREC, "95")	    		 		    		   
					U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01LPD",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")																								
				EndIf
								
			Else
				AADD(aDadosZWI, {ALLTRIM((cTmpZWI)->ZWI_EMPRES), ALLTRIM((cTmpZWI)->ZWI_PROCES), PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")})
			EndIf
													
			cQuery := "SELECT DISTINCT ZWI_CODIGO, ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_RECORI, ZWJ_ITEM, ZWJ_SITUAC, "+CHR(13)+CHR(10)
			cQuery += "(SELECT ISNULL(SUM(ZWJ1.ZWJ_QTDEXP), 0) AS QTDEXP FROM "+RetSqlName("ZWJ")+" ZWJ1 (NOLOCK) WHERE ZWJ1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND ZWJ1.ZWJ_CODIGO = ZWJ.ZWJ_CODIGO AND ZWJ1.ZWJ_ITEM = ZWJ.ZWJ_ITEM AND ZWJ1.ZWJ_SITUAC = '57') AS QTDEXP "+CHR(13)+CHR(10)
			cQuery += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
			cQuery += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_CALIAS = 'SC5' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
			cQuery += "AND ZWJ_STATUS = '04' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_EMPRES = '"+cCodEmp+"' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery += "AND ZWI_CODIGO = '"+(cTmpZWI)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)		
			cQuery += "ORDER BY ZWI_CODIGO, ZWJ_ITEM "+CHR(13)+CHR(10)
		
			If Select(cTmpQuery) > 0
				(cTmpQuery)->(DbCloseArea())
			EndIf
			
			cQuery := ChangeQuery(cQuery)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpQuery)		
			
			While !(cTmpQuery)->(EOF())
											
				cQDados := "SELECT ZWI_RECORI, ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_SITUAC, ZWJ_CODIGO, ZWJ_ITEM, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWJ_RECORI, ZWJ_DEPERP, "+CHR(13)+CHR(10)
				cQDados += "ZWJ_SITUAC, ZWJ_QTDE, ZWJ_QTDEXP, ZWJ_QTSEPA, ZWI_CARGA, B1_COD, B1_DESC, B1_UM, C6_PRODUTO, C6_QTDVEN, C6_QTDLIB, C6_LOCAL, C6_LOTECTL, C6_NUMLOTE, C6_DTVALID, "+CHR(13)+CHR(10)
				cQDados += "(SELECT ISNULL(SUM(C9_QTDLIB), 0) AS QTDLIB FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) WHERE SC9.D_E_L_E_T_ = ' ' AND C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM "+CHR(13)+CHR(10)
				cQDados += "AND C9_CLIENTE = C6_CLI AND C9_LOJA = C6_LOJA AND C9_ZROMAN = ZWI_CARGA) AS QTDLIB "+CHR(13)+CHR(10)					
				cQDados += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("SC6")+" SC6 (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (C6_FILIAL = '"+xFilial("SC6")+"' AND ZWJ_RECORI = SC6.R_E_C_N_O_ AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQDados += "INNER JOIN " +RetSqlName("SB1")+" SB1 (NOLOCK) "+CHR(13)+CHR(10)
				cQDados += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = ZWJ_PRODUT AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
				cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_CALIAS = 'SC6' "+CHR(13)+CHR(10)
				cQDados += "AND ZWI_STATUS = '04' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_STATUS = '04' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_EMPRES = '"+cCodEmp+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_CODIGO = '"+(cTmpQuery)->ZWI_CODIGO+"' "+CHR(13)+CHR(10)
				cQDados += "AND ZWJ_ITEM = '"+(cTmpQuery)->ZWJ_ITEM+"' "+CHR(13)+CHR(10)
				cQDados += "ORDER BY ZWJ_CODIGO, ZWJ_ITEM "+CHR(13)+CHR(10)	
		
				If Select(cTmpDados) > 0
					(cTmpDados)->(DbCloseArea())
				EndIf
								
				cQDados := ChangeQuery(cQDados)	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	
					
				While !(cTmpDados)->(EOF())
					
					lNovaLib	:= .F.
					nRecSC6 	:= (cTmpDados)->ZWJ_RECORI 
					nRecSC9	:= 0			

					//Gravar o recno SC9 na tabela integradora ZWJ
					DbSelectArea("SC6")
					DbSetOrder(1) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
					DbGoTo(nRecSC6)

					DbSelectArea("SC9")
					DbSetOrder(2) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM
					
					If	SC9->(DbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)) 
						nRecSC9 := SC9->(RECNO())
					EndIf
													
					If lDelPed					
						If lRet
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "05")	    		 		    		   
	
							If lGrvLogOk
								DbSelectArea("ZWJ")
								ZWJ->(DbGoTo((cTmpCab)->ZWJREC))
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "0",,,,, "05")
							EndIf
						Else
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "95")	    		 		    		   
	
							If lGrvLogOk
								DbSelectArea("ZWJ")
								ZWJ->(DbGoTo((cTmpCab)->ZWJREC))
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "0",,,,, "95")
							EndIf						
						EndIf
					Else						
						
						If ALLTRIM((cTmpQuery)->ZWJ_SITUAC) == "68" .OR. (cTmpQuery)->QTDEXP = 0 //Cancela o item no Romaneio
						
							If U_XRITROMA(PADL(ALLTRIM((cTmpDados)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0"), ALLTRIM((cTmpDados)->B1_COD), (cTmpDados)->ZWJ_RECORI)			
								U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "05")
									    		 		    		   
								If lGrvLogOk														
									DbSelectArea("ZWJ")
									ZWJ->(DbGoTo((cTmpCab)->ZWJREC))
									U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "0",,,,, "05")
								EndIf							
							Else
								lRet := .F.
								U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "95")
															  	
								DbSelectArea("ZWJ")
								ZWJ->(DbGoto((cTmpDados)->ZWJREC))	
								
								cErro		:= "ERRO NA REMOCAO DO ITEM "+ALLTRIM((cTmpDados)->ZWJ_ITEM)+" - PRODUTO "+ALLTRIM((cTmpDados)->B1_COD)+" DO ROMANEIO "+ALLTRIM((cTmpDados)->ZWI_CARGA)+" - FUNCAO U_XRITROMA"
								cDescErro	:= "FUNCAO U_XRITROMA"
								cSolucao 	:= "VERIRIFICAR JUNTO AO TI."
								
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")																		  	
							EndIf
						
						ElseIf ((cTmpQuery)->QTDEXP == (cTmpDados)->QTDLIB) .OR. (ALLTRIM((cTmpDados)->ZWJ_SITUAC) == "57" .AND. (cTmpDados)->ZWJ_QTDEXP = 0) //Quantidade total devolvida pelo WIS igual a quantidade já liberada ou item com o lote zerado que nAo deve ter corte
							
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "05")

							If lGrvLogOk
								DbSelectArea("ZWJ")
								ZWJ->(DbGoTo((cTmpCab)->ZWJREC))
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "0",,,,, "05")
							EndIf

						/*ElseIf (cTmpQuery)->QTDEXP > (cTmpDados)->QTDLIB //Quantidade total devolvida pelo WIS maior que a quantidade já liberada
						
							lRet := .F.
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "95")	
							  	
				   			AADD(aLog, {"ZWH_FILIAL"	, xFilial("ZWH"), Nil})
					   		AADD(aLog, {"ZWH_TABELA"	, "ZWJ", Nil})
					    	AADD(aLog, {"ZWH_RECNO"	, (cTmpDados)->ZWJREC, Nil})
					    	AADD(aLog, {"ZWH_CODIGO"	, (cTmpDados)->ZWJ_CODIGO, Nil})
					    	AADD(aLog, {"ZWH_ITEM"	, (cTmpDados)->ZWJ_ITEM, Nil})
					    	AADD(aLog, {"ZWH_FUNAME"	, "WIS01LPD", Nil})
					    	AADD(aLog, {"ZWH_INTERF"	, "", Nil})
					    	AADD(aLog, {"ZWH_ERRO"	, ERRO95, Nil})
					    	AADD(aLog, {"ZWH_SOLUCA"	, "", Nil})
							AADD(aLog, {"ZWH_OBSERV"	, "ERRO NA REMOCAO DO ITEM "+ALLTRIM((cTmpDados)->ZWJ_ITEM)+" - PRODUTO "+ALLTRIM((cTmpDados)->B1_COD)+" NO ROMANEIO "+ALLTRIM((cTmpDados)->ZWJ_CARGA)+" - FUNCAO U_XRITROMA", Nil})					    
							AADD(aLog, {"ZWH_STATUS"	, "95", Nil})	        	
					    	AADD(aLog, {"ZWH_DATA"	, dDatabase, Nil})
					    	AADD(aLog, {"ZWH_HORA"	, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]), Nil})  									
							*/					
						Else
	
							lNovaLib	:= .T. 
							
						EndIf
					
					EndIf

					(cTmpDados)->(DbSkip())	
				EndDo
				
				Begin Transaction
				
				If lNovaLib					
					cLiberOk 	:= ""
					cSC6Lotect	:= ""
					cSC6Lote 	:= ""
					cSC6Locali	:= ""
					cSC6NumSer	:= ""
					dSC6DtVld	:= CTOD("")
					cSC6Poten	:= ""
					cIdDCF  	:= ""
					cStServ 	:= ""		
					cMercanet 	:= "" 
					cFase		:= ""
					cSEQCAR	:= "" 
					cSEQENT	:= "" 
					nLibPed	:= 0
					cDescErro	:= ""
					cSolucao	:= ""
					lSC9Est	:= .F.
					cRomaneio	:= PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")
					// Ajusta o item no Romaneio conforme retorno do WIS
					// Busca liberaCoes no SC9 e estorna
					DbSelectArea("SC5")
					DbSetOrder(1) //C5_FILIAL, C5_NUM
					DbGoTo((cTmpZWI)->ZWI_RECORI)
						
					cLiberOk 	:= SC5->C5_LIBEROK
						
					DbSelectArea("SC6")
					DbSetOrder(1) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
					DbGoTo(nRecSC6)

					DbSelectArea("SC9")
					DbSetOrder(2) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM
					
					If	SC9->(DbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM)) 
							
						DbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL, B1_COD
						SB1->(MsSeek(xFilial("SB1")+SC9->C9_PRODUTO))

						If SC5->C5_TIPO $ "BD"
							DbSelectArea("SA2")
							DbSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA
							SA2->(DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
						Else
							DbSelectArea("SA1")
							DbSetOrder(1) //A1_FILIAL, A1_COD, A1_LOJA
							SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
						EndIf
						
						RecLock("SC5")
						RecLock("SC6")
						RecLock("SC9")
						
						cSC6Lotect	:= SC6->C6_LOTECTL
						cSC6Lote 	:= SC6->C6_NUMLOTE
						cSC6Locali	:= SC6->C6_LOCALIZ
						cSC6NumSer	:= SC6->C6_NUMSERI
						dSC6DtVld	:= SC6->C6_DTVALID
						cSC6Poten	:= SC6->C6_POTENCI
																	
						//SoftLock("SC9")
						If FieldPos("C9_ZZMERCA") > 0
							cMercanet := SC9->C9_ZZMERCA
						EndIf
						
						cIdDCF  	:= SC9->C9_IDDCF
						cStServ 	:= SC9->C9_STSERV
						cFase		:= SC9->C9_ZZFAS
						cSEQCAR	:= SC9->C9_SEQCAR 
						cSEQENT	:= SC9->C9_SEQENT 							
													
						//ValidaCAo para verificar se os serviCos no WMS já estAo em andamento
						lIntWms := IntDL(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
						If lIntWms
							//-- Somente valida a execuCAo da OS se a geraCAo da OS é feita na carga
							//-- 1=no Pedido;2=na Montagem da Carga;3=na Unitizacao da Carga
							If SC5->C5_GERAWMS <> "1"
								lProcessa := WmsAvalSC9()
							EndIf
								
						EndIf
							
						If lProcessa
															
							While !SC9->(EOF()) .And. xFilial("SC9") == SC9->C9_FILIAL .And. SC6->C6_NUM == SC9->C9_PEDIDO .And.;
								SC6->C6_ITEM == SC9->C9_ITEM
						
								If VAL((cTmpZWI)->ZWI_CARGA) == VAL(SC9->C9_ZROMAN) //.AND. ALLTRIM(SC9->C9_ZZFAS) = "RM"
									aAreaAux := GetArea() //Salva are
										If SC9->(a460Estorna())
											lSC9Est := .T.
										EndIf
									RestArea(aAreaAux) //Restaura area
								EndIf
								SC9->(DbSkip())
							EndDo	
						
							If lSC9Est
								//-- Efetua nova liberacao abatendo os itens cortados SEM gerar nova O.S.WMS
								nLibPed := MaLibDoFat(SC6->(RecNo()),(cTmpQuery)->QTDEXP,.T.,.T.,.F.,.F.,.F.,.F.,/*aEmpenho*/,{||.T.},,,/*lCriaDCF*/.F.)
								
								If nLibPed == (cTmpQuery)->QTDEXP								
									RecLock("SC6", .F.)
										SC6->C6_LOTECTL := cSC6Lotect
										SC6->C6_NUMLOTE := cSC6Lote
										SC6->C6_LOCALIZ := cSC6Locali	
										SC6->C6_NUMSERI := cSC6NumSer	
										SC6->C6_DTVALID := dSC6DtVld
										SC6->C6_POTENCI := cSC6Poten
									SC6->(MsUnlock())
								
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Retorna o status do pedido de venda quanto a liberacao                 ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									//+--------------------------------------------+
									//|Muda o Flag do SC5->C5_LIBEROK              |
									//+--------------------------------------------+
									//SC5->(Reclock("SC5",.F.))
									//SC5->(MaLiberOk({cPedido},.F.))
									//SC5->(MsUnlock())
									
									RecLock("SC5")
										SC5->C5_LIBEROK := cLiberOk
									SC5->(MsUnlock())
									
									//DbSelectArea("SC6")
									//DbSetOrder(1) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
									//DbGoTo(nRecSC6)
			
									DbSelectArea("SC9")
									DbSetOrder(2) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM
									
									If	SC9->(DbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM))
										While !SC9->(EOF()) .And. xFilial("SC9") == SC9->C9_FILIAL .And.;
											SC6->C6_NUM == SC9->C9_PEDIDO .And.;
											SC6->C6_ITEM == SC9->C9_ITEM
																						
											If Empty(SC9->C9_BLCRED+SC9->C9_BLEST) .And. Empty(SC9->C9_CARGA)									
												//-- Atualizando as informaCões do WMS
												RecLock("SC9", .F.)
													SC9->C9_IDDCF  	:= cIdDCF
													SC9->C9_STSERV 	:= cStServ
													SC9->C9_ZZFAS	 	:= cFase
													SC9->C9_ZROMAN 	:= cRomaneio
													SC9->C9_CARGA 	:= cRomaneio
													SC9->C9_SEQCAR 	:= cSEQCAR
													SC9->C9_SEQENT 	:= cSEQENT
													
													If FieldPos("C9_XWMSCOD") > 0
														SC9->C9_XWMSCOD 	:= (cTmpQuery)->ZWI_CODIGO
													EndIf
	
													If FieldPos("C9_XWMSITM") > 0
														SC9->C9_XWMSITM	:= (cTmpQuery)->ZWJ_ITEM
													EndIf
													
													If FieldPos("C9_ZZMERCA") > 0
														SC9->C9_ZZMERCA := cMercanet
													EndIf
												SC9->(MsUnLock())											
											EndIf																					
											
											nRecSC9 := SC9->(RECNO())
											
											SC9->(DbSkip())
										EndDo
										
										MsUnLock()
									Else
										lRet 		:= .F.
										cErro := "A liberacao do item "+SC6->C6_ITEM+" do pedido "+Alltrim(SC6->C6_NUM)+" nAo foi localizada." 
									EndIf
								Else
									lRet := .F.
									cErro := "Ocorreu um erro na liberacao do item "+SC6->C6_ITEM+" do pedido "+Alltrim(SC6->C6_NUM)+". Saldo do produto "+Alltrim(SC6->C6_PRODUTO)+". Qtde Solicitada = "+cValtoChar((cTmpQuery)->QTDEXP)+" / Qtde Liberada = "+cValtoChar(nLibPed)+"."
								EndIf									
							Else
								lRet := .F.
								cErro := "Ocorreu um erro no estorno da liberacao do item "+SC6->C6_ITEM+" do pedido "+Alltrim(SC6->C6_NUM)+". Funcao a460Estorna."
							EndIf	
						Else
							lRet := .F.			
							cErro := "Ocorreu um erro na validacao WmsAvalSC9() na liberacao do item "+SC6->C6_ITEM+" do pedido "+Alltrim(SC6->C6_NUM)+" - produto "+Alltrim(SC6->C6_PRODUTO)+"."																
						EndIf						
					Else
						lRet 		:= .F.
						cErro := "O item "+SC6->C6_ITEM+" do pedido "+Alltrim(SC6->C6_NUM)+" nao foi liberado." 
					EndIf					
				EndIf
				
				/*					
				If !lRet
					DisarmTransaction()
					Break
				EndIf
				*/
				DbSelectArea("ZWJ")
				DbSetOrder(1) //ZWJ_FILIAL, ZWJ_EMPRES, ZWJ_CODIGO, ZWJ_ITEM
				If ZWJ->(DBSeek(xFilial("ZWJ")+cCodEmp+(cTmpQuery)->ZWI_CODIGO+(cTmpQuery)->ZWJ_ITEM))											
					While !ZWJ->(EOF()) .AND. xFilial("ZWJ") == ZWJ->ZWJ_FILIAL .AND. ZWJ->ZWJ_EMPRES == cCodEmp .AND.;
						 ZWJ->ZWJ_CODIGO == (cTmpQuery)->ZWI_CODIGO .AND. ZWJ->ZWJ_ITEM == (cTmpQuery)->ZWJ_ITEM
						//If ZWJ->ZWJ_STATUS = "04"
							If lRet										
								If EMPTY(cRomaneio)
									cRomaneio	:= PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")
								EndIf
								
								U_WW01PROC("ZWJ", ZWJ->(RECNO()), "SC9", nRecSC9, cRomaneio)
								U_WWSTATUS("ZWJ", ZWJ->(RECNO()), "05")
								If lGrvLogOk
									U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "0",,,,, "05")
								EndIf
							Else 
								U_WWSTATUS("ZWJ", ZWJ->(RECNO()), "95")	
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIS01LPD",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")															
							EndIf
						//EndIf
						
						ZWJ->(DbSkip())
					EndDo
				EndIf
				
				End Transaction
								
				(cTmpQuery)->(DbSkip())	
			EndDo
/*
			If lDelPed //ALLTRIM((cTmpZWI)->ZWI_SITUAC) == "68" //Retira o Pedido do Romaneio
				cRomaneio := PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("DAK_COD")[1], "0")
				
				If !U_XRPVROMA(cRomaneio, (cTmpZWI)->ZWI_RECORI)
					lRet := .F.
					
					DbSelectArea("ZWI")
					ZWI->(DbGoto((cTmpZWI)->ZWIREC))
					cErro		:= "ERRO NA EXCLUSAO DO PEDIDO "+ALLTRIM((cTmpDados)->ZWI_PEDORI)+" DO ROMANEIO "+ALLTRIM(cRomaneio)+"."
					cDescErro	:= "FUNCAO U_XRPVROMA"
					cSolucao 	:= "VERIFICAR CORRECAO JUNTO AO TI."
					
					U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01LPD",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")																			
				EndIf 				
			EndIf
*/
			//Exclui o Romaneio caso nAo exista pedidos
			If lRet
				cRomaneio := PADL(ALLTRIM((cTmpZWI)->ZWI_CARGA), TAMSX3("C9_ZROMAN")[1], "0")
				If !W01ROMAN(xFilial("SC9"), cRomaneio)
					If !U_XDELROMA(, cRomaneio)
						lRet := .F.

						DbSelectArea("ZWI")
						ZWI->(DbGoto((cTmpZWI)->ZWIREC))
						cErro		:= "ERRO NA EXCLUSAO DO ROMANEIO "+ALLTRIM(cRomaneio)+"."
						cDescErro	:= "FUNCAO U_XDELROMA"
						cSolucao 	:= "VERIFICAR CORRECAO JUNTO AO TI."
							
						U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01LPD",, "4", cErro, ERRO95, cDescErro, cSolucao, "95")																														
					EndIf
				EndIf
			EndIf

			If lRet
				U_WWSTATUS("ZWI", (cTmpZWI)->ZWIREC, "05")
				
				If lGrvLogOk	
					DbSelectArea("ZWI")
					ZWI->(DbGoTo((cTmpZWI)->ZWIREC))
					U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01LPD",, "0",,,,, "05")								
				EndIf
			Else
				U_WWSTATUS("ZWI", (cTmpZWI)->ZWIREC, "95")
				/*
				DbSelectArea("ZWI")
				ZWI->(DbGoto((cTmpZWI)->ZWI_RECORI))
				//cErro		:= "" //"ERRO NA EXCLUSAO DO PEDIDO "+ALLTRIM((cTmpDados)->ZWI_PEDORI)+" DO ROMANEIO "+ALLTRIM(cRomaneio)+"."
				//cDescErro	:= ""//"FUNCAO U_XRPVROMA"
				//cSolucao 	:= "" //"Verificar correCAo junto ao TI."
					
				U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIS01LPD",, "3", cErro, ERRO95, cDescErro, cSolucao, "95")																			
				*/
			EndIf			
		//End Transaction
											
		(cTmpZWI)->(DbSkip())	
	EndDo

	//Liberar o romaneio automaticamente caso todos os pedidos processados ok
	For nX := 1 to Len(aDadosZWI)				
		If W01ROMOK(aDadosZWI[nX][1], aDadosZWI[nX][3])
			U_XRLIBROM(aDadosZWI[nX][3])
		EndIf
	Next 		
		
	If Select(cTmpZWI) > 0
		(cTmpZWI)->(DbCloseArea())
	EndIf

	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf

	If Select(cTmpDados) > 0
		(cTmpDados)->(DbCloseArea())
	EndIf

EndIf

RestArea(aAreaB1)
RestArea(aAreaA2) 
RestArea(aAreaA1) 
RestArea(aAreaC9)
RestArea(aAreaC6)
RestArea(aAreaC5)
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W01ROMAN

Verifica se existem itens no Romaneio

@author Allan Constantino Bonfim
@since  16/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function W01ROMAN(cFil, cRoman)

Local lRet			:= .T.
Local cQRoma		:= ""
Local cTmpRoma	:= GetNextAlias()

Default cRoman	:= ""
Default cFil		:= xFilial("SC9")

If !Empty(cRoman)
	cQRoma := "SELECT C9_ZROMAN "+CHR(13)+CHR(10) 
	cQRoma += "FROM "+RetSqlName("SC9")+" SC9 (NOLOCK) "+CHR(13)+CHR(10)
	cQRoma += "WHERE SC9.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQRoma += "AND C9_FILIAL = '"+Alltrim(cFil)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND C9_ZROMAN = '"+Alltrim(cRoman)+"' "+CHR(13)+CHR(10)
	
	If Select(cTmpRoma) > 0
		(cTmpRoma)->(DbCloseArea())
	EndIf
	
	cQRoma := ChangeQuery(cQRoma)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRoma),cTmpRoma)	
	
	If !(cTmpRoma)->(EOF())
		lRet := .T.	
	EndIf
EndIf

If Select(cTmpRoma) > 0
	(cTmpRoma)->(DbCloseArea())
EndIf

Return lRet


//-----------------------------W01ROMOK-------------------------------------------------------------------
/*/{Protheus.doc} W01ROMOK

Verifica se todos os pedidos do Romaneio foram processados.

@author Allan Constantino Bonfim
@since  25/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function W01ROMOK(cEmpres, cRoman)

Local lRet			:= .F.
Local cQRoma		:= ""
Local cTmpRoma	:= GetNextAlias()
Local cFilWis		:= PADL(FWCodFil(), 3, "0")   


Default cEmpres	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cRoman	:= ""

If !Empty(cRoman)
	//cRoman := PADL(cValtoChar(Val(cRoman)), TAMSX3("DAK_COD")[1], "0") //cValtoChar(Val(cRoman)) //Ajuste para o codigo do romaneio
	cQRoma := "SELECT ZWI_EMPRES, ZWI_CARGA, ZWK_QTDCAR, COUNT(*) AS QTDCARGA "+CHR(13)+CHR(10) 
	cQRoma += "FROM "+RetSqlName("ZWI")+" ZWI (NOLOCK) "+CHR(13)+CHR(10)
	cQRoma += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
	cQRoma += "ON (ZWK_FILIAL = ZWI_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
	cQRoma += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWI_CALIAS = 'SC5' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWI_EMPRES = '"+ALLTRIM(cEmpres)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWI_CARGA = '"+Alltrim(cRoman)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_SITUAC = '1' "+CHR(13)+CHR(10)
	//Allan Constantino Bonfim - 23/11/2018 - CM Solutions - Projeto WMS 100% - Ajuste na query para considerar os processos finalizados (status 50) na contagem de pedidos processados no retorno do WIS. 
	cQRoma += "AND (ZWI_STATUS >= '05' AND ZWI_STATUS <= '50') "+CHR(13)+CHR(10)
	cQRoma += "GROUP BY ZWI_EMPRES, ZWI_CARGA, ZWK_QTDCAR "+CHR(13)+CHR(10)
	//cQRoma += "HAVING COUNT(*) = ZWK_QTDCAR "+CHR(13)+CHR(10)
	
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


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GETVLOTE

Verifica a validade do Lote

@author Allan Constantino Bonfim
@since  02/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function GETVLOTE(cProduto, cLocal, cLote)
		
Local dtVldLote	:= dDatabase
Local cQDados		:= ""
Local cTmpDados	:= GetNextAlias()

Default cProduto	:= ""
Default cLocal	:= ""
Default cLote 	:= ""


cQDados := "SELECT B8_FILIAL, B8_PRODUTO, MAX(B8_DTVALID) AS B8_DTVALID "+CHR(13)+CHR(10) 
cQDados += "FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "+CHR(13)+CHR(10)
cQDados += "WHERE SB8.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
cQDados += "AND B8_FILIAL = '"+xFilial("SB8")+"' "+CHR(13)+CHR(10)
cQDados += "AND B8_PRODUTO = '"+Alltrim(cProduto)+"' "+CHR(13)+CHR(10)
cQDados += "AND B8_LOCAL = '"+Alltrim(cLocal)+"' "+CHR(13)+CHR(10)
cQDados += "AND B8_LOTECTL = '"+Alltrim(cLote)+"' "+CHR(13)+CHR(10)
cQDados += "GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_DTVALID "+CHR(13)+CHR(10)

If Select(cTmpDados) > 0
	(cTmpDados)->(DbCloseArea())
EndIf

cQDados := ChangeQuery(cQDados)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	

If !(cTmpDados)->(EOF())
	dtVldLote := STOD((cTmpDados)->B8_DTVALID)	
EndIf

If Select(cTmpDados) > 0
	(cTmpDados)->(DbCloseArea())
EndIf
	
Return dtVldLote


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VLOTESAL

Verifica lotes do produto com quantidade suficiente para o processamento.

@author Allan Constantino Bonfim
@since  02/08/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
/*Static Function VLOTESAL(cProduto, cLocal, cLote)
		
Local cQDados		:= ""
Local cTmpDados	:= GetNextAlias()
Local aRet			:= {}

Default cProduto	:= ""
Default cLocal	:= ""
Default cLote 	:= ""


cQDados := "SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_DTVALID, (B8_SALDO - B8_EMPENHO) AS B8_SALDO "+CHR(13)+CHR(10) 
cQDados += "FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "+CHR(13)+CHR(10)
cQDados += "WHERE SB8.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
cQDados += "AND B8_FILIAL = '"+xFilial("SB8")+"' "+CHR(13)+CHR(10)
cQDados += "AND B8_PRODUTO = '"+Alltrim(cProduto)+"' "+CHR(13)+CHR(10)
cQDados += "AND B8_LOCAL = '"+Alltrim(cLocal)+"' "+CHR(13)+CHR(10)

If !EMPTY(cLote)
	cQDados += "AND B8_LOTECTL = '"+Alltrim(cLote)+"' "+CHR(13)+CHR(10)
EndIf

cQDados += "AND (B8_SALDO - B8_EMPENHO) > 0 "+CHR(13)+CHR(10)
cQDados += "AND B8_DTVALID >= '"+DTOS(dDatabase)+"' "+CHR(13)+CHR(10)
cQDados += "ORDER BY B8_DTVALID "+CHR(13)+CHR(10)

If Select(cTmpDados) > 0
	(cTmpDados)->(DbCloseArea())
EndIf

cQDados := ChangeQuery(cQDados)	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)	

While !(cTmpDados)->(EOF())
	AADD(aRet, {(cTmpDados)->B8_PRODUTO, (cTmpDados)->B8_LOCAL, (cTmpDados)->B8_LOTECTL, STOD((cTmpDados)->B8_DTVALID), (cTmpDados)->B8_SALDO})
	
	(cTmpDados)->(DbSkip())	
EndDo

If Select(cTmpDados) > 0
	(cTmpDados)->(DbCloseArea())
EndIf
	
Return aRet
*/

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W01FIMST

Finaliza os processos apOs o processamento

@author Allan Constantino Bonfim
@since  30/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static Function W01FIMST(cEmpres, cPAlias, cProcess, cStatSai, cStatEnt, lSituac9, lOnlyZWI)

Local lRet			:= .F.
Local cQStat		:= ""
Local cTmpStat	:= GetNextAlias()
Local cFilWis		:= PADL(FWCodFil(), 3, "0")  

Default cEmpres	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cPAlias	:= ""
Default cProcess	:= ""
Default cStatEnt	:= ""
Default cStatSai	:= ""
Default lSituac9	:= .T.
Default lOnlyZWI	:= .F.

If !Empty(cProcess)

	If lOnlyZWI
			cQStat := "SELECT ZWI_FILIAL AS FILIAL, ZWI_DEPOSI AS FILWIS, ZWI_EMPRES AS EMPRESA, ZWI_CODIGO AS CODIGO,MIN(STENTRADA) AS STATENTRA,MIN(STSAIDA) AS STATSAIDA "+CHR(13)+CHR(10) 
		cQStat += "FROM ( "+CHR(13)+CHR(10)	
		cQStat += "		SELECT ZWI_FILIAL,ZWI_EMPRES, ZWI_DEPOSI, ZWI_CODIGO,(CASE WHEN ZWK_STATUS > ZWL_STATUS THEN COALESCE(ZWL_STATUS,'00') ELSE COALESCE(ZWK_STATUS,'00') END) AS STSAIDA, "+CHR(13)+CHR(10) 
		cQStat += "		(CASE WHEN ZWI_STATUS > ZWJ_STATUS THEN COALESCE(ZWJ_STATUS,'00') ELSE  COALESCE(ZWI_STATUS,'00') END) AS STENTRADA "+CHR(13)+CHR(10)
		cQStat += "		FROM "+RetSqlName("ZWI")+" ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		LEFT JOIN "+RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
		cQStat += "		LEFT JOIN "+RetSqlName("ZWK")+" ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWI_FILIAL = ZWK_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_DEPOSI = ZWK_DEPOSI AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWK.D_E_L_E_T_ = ' ')  "+CHR(13)+CHR(10)
		cQStat += "		LEFT JOIN "+RetSqlName("ZWL")+" ZWL (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWI_FILIAL = ZWL_FILIAL AND ZWI_EMPRES = ZWL_EMPRES AND ZWI_DEPOSI = ZWL_DEPOSI AND ZWI_CODIGO = ZWL_CODIGO AND ZWI_PROCES = ZWL_PROCES AND ZWL.D_E_L_E_T_ = ' ')  "+CHR(13)+CHR(10)
		cQStat += "		WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWI_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWI_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWI_CALIAS = '"+cPAlias+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWI_EMPRES = '"+cEmpres+"' "+CHR(13)+CHR(10)
		
		If lSituac9
			cQStat += "		AND (EXISTS (SELECT ZWK_CODIGO FROM "+RetSqlName("ZWK")+" ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWI.ZWI_FILIAL AND ZWKA.ZWK_EMPRES = ZWI.ZWI_EMPRES "+CHR(13)+CHR(10)
			cQStat += "		AND ZWKA.ZWK_DEPOSI = ZWI.ZWI_DEPOSI AND ZWKA.ZWK_CODIGO = ZWI.ZWI_CODIGO AND ZWKA.ZWK_PROCES = ZWI.ZWI_PROCES AND ZWKA.ZWK_SITUAC = '3' AND ZWKA.ZWK_STATUS = '09') "+CHR(13)+CHR(10)
			cQStat += "		OR (ZWI_SITUAC = '68' AND ZWI_STATUS = '06')) "+CHR(13)+CHR(10)
		EndIf	
		
		cQStat += "		GROUP BY ZWI_FILIAL, ZWI_EMPRES, ZWI_DEPOSI, ZWI_CODIGO, ZWK_STATUS, ZWL_STATUS, ZWI_STATUS, ZWJ_STATUS "+CHR(13)+CHR(10)
		cQStat += "		) TMP "+CHR(13)+CHR(10)
		cQStat += "GROUP BY ZWI_FILIAL, ZWI_EMPRES, ZWI_DEPOSI, ZWI_CODIGO "+CHR(13)+CHR(10)
		cQStat += "HAVING MIN(STENTRADA) = '"+cStatEnt+"' AND MIN(STSAIDA) = '"+cStatSai+"' "+CHR(13)+CHR(10)
	Else
		cQStat := "SELECT ZWK_FILIAL AS FILIAL, ZWK_DEPOSI AS FILWIS, ZWK_EMPRES AS EMPRESA, ZWK_CODIGO AS CODIGO, MIN(STENTRADA) AS STATENTRA, MIN(STSAIDA) AS STATSAIDA "+CHR(13)+CHR(10) 
		cQStat += "FROM ( "+CHR(13)+CHR(10)	
		cQStat += "		SELECT ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO, (CASE WHEN ZWK_STATUS > ZWL_STATUS THEN ISNULL(ZWL_STATUS, '00') ELSE ISNULL(ZWK_STATUS, '00') END) AS STSAIDA, " 
		cQStat += "		(CASE WHEN ZWI_STATUS > ZWJ_STATUS THEN ISNULL(ZWJ_STATUS, '00') ELSE ISNULL(ZWI_STATUS,'00') END) AS STENTRADA "+CHR(13)+CHR(10)
		cQStat += "		FROM "+RetSqlName("ZWK")+" ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		LEFT JOIN "+RetSqlName("ZWL")+" ZWL (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWK_FILIAL = ZWL_FILIAL AND ZWK_EMPRES = ZWL_EMPRES AND ZWK_DEPOSI = ZWL_DEPOSI AND ZWK_CODIGO = ZWL_CODIGO AND ZWK_PROCES = ZWL_PROCES AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQStat += "		LEFT JOIN "+RetSqlName("ZWI")+" ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWK_FILIAL = ZWI_FILIAL AND ZWK_EMPRES = ZWI_EMPRES AND ZWK_DEPOSI = ZWI_DEPOSI AND ZWK_CODIGO = ZWI_CODIGO AND ZWK_PROCES = ZWI_PROCES AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQStat += "		LEFT JOIN "+RetSqlName("ZWJ")+" ZWJ (NOLOCK) "+CHR(13)+CHR(10)
		cQStat += "		ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWK_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
		cQStat += "		WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWK_CALIAS = '"+cPAlias+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQStat += "		AND ZWK_EMPRES = '"+cEmpres+"' "+CHR(13)+CHR(10)
		
		If lSituac9
			cQStat += "		AND (EXISTS (SELECT ZWK_CODIGO FROM "+RetSqlName("ZWK")+" ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWK.ZWK_FILIAL AND ZWKA.ZWK_EMPRES = ZWK.ZWK_EMPRES "+CHR(13)+CHR(10)
			cQStat += "		AND ZWKA.ZWK_DEPOSI = ZWK.ZWK_DEPOSI AND ZWKA.ZWK_CODIGO = ZWK.ZWK_CODIGO AND ZWKA.ZWK_PROCES = ZWK.ZWK_PROCES AND ZWKA.ZWK_SITUAC = '3' AND ZWKA.ZWK_STATUS = '09') "+CHR(13)+CHR(10)
			cQStat += "		OR (ZWI_SITUAC = '68' AND ZWI_STATUS = '06')) "+CHR(13)+CHR(10)
		EndIf	
		
		cQStat += "		GROUP BY ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO, ZWK_STATUS, ZWL_STATUS, ZWI_STATUS, ZWJ_STATUS "+CHR(13)+CHR(10)
		cQStat += "		) TMP "+CHR(13)+CHR(10)
		cQStat += "GROUP BY ZWK_FILIAL, ZWK_EMPRES, ZWK_DEPOSI, ZWK_CODIGO "+CHR(13)+CHR(10)
		cQStat += "HAVING MIN(STENTRADA) = '"+cStatEnt+"' AND MIN(STSAIDA) = '"+cStatSai+"' "+CHR(13)+CHR(10)
	EndIf
			
	If Select(cTmpStat) > 0
		(cTmpStat)->(DbCloseArea())
	EndIf
	
	cQStat := ChangeQuery(cQStat)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQStat),cTmpStat)	
	
	While !(cTmpStat)->(EOF())				
		//If cStatEnt == (cTmpStat)->STATENTRA .AND. cStatSai == (cTmpStat)->STATSAIDA
			lRet := .T.
			Begin Transaction
				If lOnlyZWI
					DbSelectArea("ZWI")
					DbSetOrder(1) //ZWI_FILIAL, ZWI_EMPRES, ZWI_CODIGO					
					If ZWI->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
						While !ZWI->(EOF()) .AND. ZWI->ZWI_FILIAL  == (cTmpStat)->FILIAL .AND. ZWI->ZWI_EMPRES == (cTmpStat)->EMPRESA .AND. ZWI->ZWI_CODIGO == (cTmpStat)->CODIGO
							U_WWSTATUS("ZWI", ZWI->(RECNO()), "50")
							ZWI->(DbSkip())
						EndDo 
					
						DbSelectArea("ZWJ")
						DbSetOrder(1) //ZWJ_FILIAL, ZWJ_EMPRES, ZWJ_CODIGO, ZWJ_ITEM
						If ZWJ->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
							While !ZWJ->(EOF()) .AND. ZWJ->ZWJ_FILIAL = (cTmpStat)->FILIAL .AND. ZWJ->ZWJ_EMPRES = (cTmpStat)->EMPRESA .AND. ZWJ->ZWJ_CODIGO = (cTmpStat)->CODIGO
								U_WWSTATUS("ZWJ", ZWJ->(RECNO()), "50")
								ZWJ->(DbSkip())					
							EndDo
						EndIf

						DbSelectArea("ZWK")
						DbSetOrder(1) //ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO
						If ZWK->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
							While !ZWK->(EOF()) .AND. (cTmpStat)->FILIAL == ZWK->ZWK_FILIAL .AND. (cTmpStat)->EMPRESA == ZWK->ZWK_EMPRES .AND. (cTmpStat)->CODIGO == ZWK->ZWK_CODIGO
								U_WWSTATUS("ZWK", ZWK->(RECNO()), "50")
								ZWK->(DbSkip())
							EndDo 
												
							DbSelectArea("ZWL")
							DbSetOrder(1) //ZWL_FILIAL, ZWL_EMPRES, ZWL_CODIGO, ZWL_ITEM
							If ZWL->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
								While !ZWL->(EOF()) .AND. ZWL->ZWL_FILIAL = (cTmpStat)->FILIAL .AND. ZWL->ZWL_EMPRES = (cTmpStat)->EMPRESA .AND. ZWL->ZWL_CODIGO = (cTmpStat)->CODIGO
									U_WWSTATUS("ZWL", ZWL->(RECNO()), "50")
									ZWL->(DbSkip())					
								EndDo
							EndIf
						EndIf										
					EndIf				
				Else	
					DbSelectArea("ZWK")
					DbSetOrder(1) //ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO
					If ZWK->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
						While !ZWK->(EOF()) .AND. (cTmpStat)->FILIAL == ZWK->ZWK_FILIAL .AND. (cTmpStat)->EMPRESA == ZWK->ZWK_EMPRES .AND. (cTmpStat)->CODIGO == ZWK->ZWK_CODIGO
							U_WWSTATUS("ZWK", ZWK->(RECNO()), "50")
							ZWK->(DbSkip())
						EndDo 
						
						DbSelectArea("ZWL")
						DbSetOrder(1) //ZWL_FILIAL, ZWL_EMPRES, ZWL_CODIGO, ZWL_ITEM
						If ZWL->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
							While !ZWL->(EOF()) .AND. ZWL->ZWL_FILIAL = (cTmpStat)->FILIAL .AND. ZWL->ZWL_EMPRES = (cTmpStat)->EMPRESA .AND. ZWL->ZWL_CODIGO = (cTmpStat)->CODIGO
								U_WWSTATUS("ZWL", ZWL->(RECNO()), "50")
								ZWL->(DbSkip())					
							EndDo
						EndIf
	
						DbSelectArea("ZWI")
						DbSetOrder(1) //ZWI_FILIAL, ZWI_EMPRES, ZWI_CODIGO					
						If ZWI->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
							While !ZWI->(EOF()) .AND. ZWI->ZWI_FILIAL  == (cTmpStat)->FILIAL .AND. ZWI->ZWI_EMPRES == (cTmpStat)->EMPRESA .AND. ZWI->ZWI_CODIGO == (cTmpStat)->CODIGO
								U_WWSTATUS("ZWI", ZWI->(RECNO()), "50")
								ZWI->(DbSkip())
							EndDo 
						
							DbSelectArea("ZWJ")
							DbSetOrder(1) //ZWJ_FILIAL, ZWJ_EMPRES, ZWJ_CODIGO, ZWJ_ITEM
							If ZWJ->(DbSeek((cTmpStat)->FILIAL+(cTmpStat)->EMPRESA+(cTmpStat)->CODIGO))
								While !ZWJ->(EOF()) .AND. ZWJ->ZWJ_FILIAL = (cTmpStat)->FILIAL .AND. ZWJ->ZWJ_EMPRES = (cTmpStat)->EMPRESA .AND. ZWJ->ZWJ_CODIGO = (cTmpStat)->CODIGO
									U_WWSTATUS("ZWJ", ZWJ->(RECNO()), "50")
									ZWJ->(DbSkip())					
								EndDo
							EndIf
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

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  11/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

User Function WIIWPFW(cInterface, cOrigem, cProcess, cStatus, cSituac)

Local aArea			:= GetArea()
Local lRet				:= .T.
Local nHndERP 		:= AdvConnection() 	// Salva a ConexAo atual (SQL - Protheus)
Local cDBOra  		:= ""
Local cSrvOra 		:= "" //"172.16.0.110"
Local nPorta			:= 0
Local nHndOra 		:= -1
Local cQuery  		:= ""
Local cCampos			:= ""
Local aCampos			:= ""
Local cValores		:= ""
//Local aValores		:= {}
Local nX				:= 0
Local nY				:= 0
Local cQDados			:= ""
Local cTmpDados		:= GetNextAlias()
Local nPosTipo		:= 5
Local nPosIPad		:= 3
Local aOpcoes			:= {}
Local lIntegra		:= .F.
Local cEmpWis			:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) //PADR(IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')), TAMSX3("ZWK_EMPRES")[1], " ")
Local cFilWis			:= PADL(FWCodFil(), 3, "0")  
Local cErro 			:= ""
Local cDescErro 		:= ""
Local cSoluCAo		:= ""
Local lGrvLogOk		:= GetMv("MV_ZZWMSLT",, .T.)
Local cWISBd			:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
Local cWISAlias		:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cLogWis			:= ""
Local lCadOk			:= .T.
Local lVldCad			:= GetMv("MV_ZZWVCAD",, .F.)
Local cIntCod			:= ""
Local cIntItem		:= ""						
Local xValTmp

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
	
		cCampos 	:= U_WW01GCPO(1, cInterface, cOrigem)
		aCampos 	:= U_WW01GCPO(3, cInterface, cOrigem)
		
		If ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"
			
			//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ZWL.R_E_C_N_O_ AS ZWLREC, * "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWK_FILIAL = ZWL_FILIAL AND ZWK_EMPRES = ZWL_EMPRES AND ZWK_CODIGO = ZWL_CODIGO AND ZWK_SITUAC = ZWL_SITUAC AND ZWL_PROCES = ZWK_PROCES AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_CALIAS IN ('SD1', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)

		ElseIf ALLTRIM(cInterface) == "INT_E_CAB_NOTA_FISCAL" 
			
			//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
			//cQDados := "SELECT (SELECT COUNT(*) FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_E_CAB_NOTA_FISCAL] WHERE FILLER_5 IS NOT NULL AND ID_PROCESSADO <> 'E' AND CD_SITUACAO = '"+cSituac+"' "+CHR(13)+CHR(10)
			//cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' AND CD_DEPOSITO = '"+cFilWis+"' AND FILLER_5 = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) AS QTDWIS, "+CHR(13)+CHR(10)
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZWK_OBSERV)),'') AS ZWK_OBSERV, * "+CHR(13)+CHR(10)		
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)			
			cQDados += "AND ZWK_CALIAS IN ('SF1', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
			//Verifica se nAo existe nenhum item nAo integrado com o WIS
			cQDados += "AND (	SELECT COUNT(*) QTDZWL "+CHR(13)+CHR(10)
			cQDados += "		FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "		WHERE ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_CALIAS IN ('SD1', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_FILIAL = ZWK_FILIAL "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_EMPRES = ZWK_EMPRES "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_DEPOSI = ZWK_DEPOSI "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_CODIGO = ZWK_CODIGO "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_SITUAC = ZWK_SITUAC "+CHR(13)+CHR(10)
			cQDados += "		AND ZWL_PROCES = ZWK_PROCES "+CHR(13)+CHR(10)			
			cQDados += "		AND (ZWL_STATUS <= '"+cStatus+"' OR ZWL_STATUS > '50') "+CHR(13)+CHR(10)							
			cQDados += "		) = 0 "+CHR(13)+CHR(10)
		
		ElseIf ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
			
			//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ZWL.R_E_C_N_O_ AS ZWLREC, ZWL_PEDORI AS PEDIDO, * "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWK_FILIAL = ZWL_FILIAL AND ZWK_EMPRES = ZWL_EMPRES AND ZWK_CODIGO = ZWL_CODIGO AND ZWK_SITUAC = ZWL_SITUAC AND ZWL_PROCES = ZWK_PROCES AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			
			If cProcess == "006"
				cQDados += "AND ZWL_CALIAS IN ('SC6', 'SD2') "+CHR(13)+CHR(10)
			Else
				cQDados += "AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') "+CHR(13)+CHR(10)
			EndIf
			
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)			
		
		ElseIf ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA" 
			
			//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
			cQDados := "SELECT ZWK.R_E_C_N_O_ AS ZWKREC, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZWK_OBSERV)),'') AS ZWK_OBSERV, ZWK_PEDORI AS PEDIDO, * "+CHR(13)+CHR(10)
			cQDados += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			
			If cProcess == "006"
				cQDados += "AND ZWK_CALIAS IN ('SC5', 'SF2') "+CHR(13)+CHR(10)
			Else
				cQDados += "AND ZWK_CALIAS IN ('SC5', 'SD3', 'SF2') "+CHR(13)+CHR(10)
			EndIf
			
			cQDados += "AND ZWK_STATUS = '"+cStatus+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)			
			cQDados += "AND ZWK_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10)		
			cQDados += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWK_SITUAC = '"+cSituac+"' "+CHR(13)+CHR(10)			
			//Verifica se nAo existe nenhum item nAo integrado com o WIS
			cQDados += "AND (	SELECT COUNT(*) QTDZWL "+CHR(13)+CHR(10)
			cQDados += "		FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "		WHERE ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			
			If cProcess == "006"
				cQDados += "		AND ZWL_CALIAS IN ('SC6', 'SD2') "+CHR(13)+CHR(10)
			Else
				cQDados += "		AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') "+CHR(13)+CHR(10)
			EndIf
			
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
	
		// Cria uma conexAo com um outro banco, outro DBAcces
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
					
					If !U_W1INSWIS(cInterface, cEmpWis, cFilWis, cSituac, cIntCod, cIntItem) //Registro ainda nAo foi integrado			
					
						lCadOk := .T.
									
						If lVldCad
							//TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)
						
							If ALLTRIM(cInterface) == "INT_E_CAB_NOTA_FISCAL"
								
								If !U_WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
									If !EMPTY((cTmpDados)->ZWK_CLIFOR)									
										If SUBSTR((cTmpDados)->ZWK_CLIFOR, 1,1) == "C" //Cliente
											U_RWISTCAD(2, ALLTRIM(SUBSTR((cTmpDados)->ZWK_CLIFOR, 2, LEN((cTmpDados)->ZWK_CLIFOR))))
										Else
											U_RWISTCAD(3, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										EndIf
									
										If !U_WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
											lCadOk := .F.
											cErro 	:= "O FORNECEDOR "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									Else									
										lCadOk := .F.
										cErro 	:= "O FORNECEDOR NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
									EndIf
								EndIf

							ElseIf ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"
								
								If !U_WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
									If !EMPTY((cTmpDados)->ZWK_CLIFOR)									
										If SUBSTR((cTmpDados)->ZWK_CLIFOR, 1,1) == "C" //Cliente
											U_RWISTCAD(2, ALLTRIM(SUBSTR((cTmpDados)->ZWK_CLIFOR, 2, LEN((cTmpDados)->ZWK_CLIFOR))))
										Else
											U_RWISTCAD(3, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										EndIf
		
										If !U_WWIS1FOR(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
											lCadOk := .F.
											cErro 	:= "O FORNECEDOR "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									Else									
										lCadOk := .F.
										cErro 	:= "O FORNECEDOR NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
									EndIf										
								EndIf
								
								If lCadOk
									If !U_WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
										//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
										If !EMPTY((cTmpDados)->ZWL_PRODUT)									
											U_RWISTCAD(1, ALLTRIM((cTmpDados)->ZWL_PRODUT))
										
											If !U_WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
												lCadOk := .F.
												cErro 	:= "O PRODUTO "+ALLTRIM((cTmpDados)->ZWL_PRODUT)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
											EndIf
										Else									
											lCadOk := .F.
											cErro 	:= "O PRODUTO NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
										EndIf										
									EndIf		
								EndIf
							
							ElseIf ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA"
							
								If !U_WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
									If !EMPTY((cTmpDados)->ZWK_CLIFOR)																	
										If SUBSTR((cTmpDados)->ZWK_CLIFOR, 1,1) == "F" //Fornecedor
											U_RWISTCAD(3, ALLTRIM(SUBSTR((cTmpDados)->ZWK_CLIFOR, 2, LEN((cTmpDados)->ZWK_CLIFOR))))
										Else
											U_RWISTCAD(2, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										EndIf
										
										If !U_WWIS1CLI((cTmpDados)->ZWK_EMPRES, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_CLIFOR)
											lCadOk := .F.
											cErro 	:= "O CLIENTE "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									Else									
										lCadOk := .F.
										cErro 	:= "O CLIENTE NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
									EndIf																				
								EndIf
							
								If lCadOk
									If !U_WWIS1TRS(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CODTRA))
										//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
										If !EMPTY((cTmpDados)->ZWK_CODTRA)									
											U_RWISTCAD(4, ALLTRIM((cTmpDados)->ZWK_CODTRA))
											
											If !U_WWIS1TRS(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CODTRA))
												lCadOk := .F.
												cErro 	:= "A TRANSPORTADORA "+ALLTRIM((cTmpDados)->ZWK_CODTRA)+" NAO FOI LOCALIZADA NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
											EndIf
										Else									
											lCadOk := .F.
											cErro 	:= "A TRANSPORTADORA NAO FOI PREENCHIDA. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
										EndIf																															
									EndIf									
								EndIf
							
							ElseIf ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
							
								If !U_WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
									//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
									If !EMPTY((cTmpDados)->ZWK_CLIFOR)																	
										If SUBSTR((cTmpDados)->ZWK_CLIFOR, 1,1) == "F" //Fornecedor
											U_RWISTCAD(3, ALLTRIM(SUBSTR((cTmpDados)->ZWK_CLIFOR, 2, LEN((cTmpDados)->ZWK_CLIFOR))))
										Else
											U_RWISTCAD(2, ALLTRIM((cTmpDados)->ZWK_CLIFOR))
										EndIf
										
										If !U_WWIS1CLI(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWK_CLIFOR))
											lCadOk := .F.
											cErro 	:= "O CLIENTE "+ALLTRIM((cTmpDados)->ZWK_CLIFOR)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
										EndIf
									Else									
										lCadOk := .F.
										cErro 	:= "O CLIENTE NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
									EndIf																														
								EndIf
							
								If lCadOk
									If !U_WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
										//Allan Constantino Bonfim - CM SOLUTIONS - 27/11/2018 - Correção na validação do cadastro em branco antes do insert.
										If !EMPTY((cTmpDados)->ZWL_PRODUT)									
											U_RWISTCAD(1, ALLTRIM((cTmpDados)->ZWL_PRODUT))
										
											If !U_WWIS1PRD(ALLTRIM((cTmpDados)->ZWK_EMPRES), ALLTRIM((cTmpDados)->ZWK_DEPOSI), ALLTRIM((cTmpDados)->ZWL_PRODUT))
												lCadOk := .F.
												cErro 	:= "O PRODUTO "+ALLTRIM((cTmpDados)->ZWL_PRODUT)+" NAO FOI LOCALIZADO NA EMPRESA "+ALLTRIM((cTmpDados)->ZWK_EMPRES)+" / FILIAL "+ALLTRIM((cTmpDados)->ZWK_DEPOSI)+" DO WMS WIS."
											EndIf
										Else									
											lCadOk := .F.
											cErro 	:= "O PRODUTO NAO FOI PREENCHIDO. VERIFIQUE O DOCUMENTO E A TABELA INTEGRADORA."
										EndIf										
									EndIf										
								EndIf
							
							EndIf
							
							//TcSetConn(nHndOra)		// Volta a Instância aberta anteriormente.
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
								
								If Empty(xValTmp) .AND. !Empty(aCampos[nX][nPosIPad]) //Inicializador PadrAo
									xValTmp := aCampos[nX][nPosIPad]
								//Else
									//xValTmp := (cTmpDados)->&(aCampos[nX][1])
								EndIf						
								
								If !EMPTY(aCampos[nX][8]) //OpCões do campo							
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
								
								//Allan Constantino Bonfim - 29/05/2018 - Tratamento para nAo enviar o cOdigo do romaneio nos pedidos
								//CM Solutions - Allan Constantino Bonfim - 19/07/2018 - Chamado 23125 - Tratamento para nao enviar o codigo do romaneio nos pedidos de etiqueta de volume - Processo 046
								If cProcess $ "030/046"
									If ALLTRIM(cInterface) == "INT_E_CAB_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA"
										If ALLTRIM(aCampos[nX][1]) $ "ZWK_CARGA/ZWL_CARGA"
											//Allan Constantino Bonfim - 31/10/2018 - Projeto WMS 100% - Tratamento para enviar o código do romaneio em branco dos pedidos FINILOG.
											If cSituac == "3"
												xValTmp := W1WCARGA(cEmpWis, cFilWis, ALLTRIM((cTmpDados)->PEDIDO), cIntCod) 
											Else
												xValTmp := CRIAVAR(aCampos[nX][1])
											EndIf
										ElseIf ALLTRIM(aCampos[nX][1]) $ "ZWK_QTDCAR"	
											xValTmp := "1"
										EndIf
									EndIf
								EndIf
								
								If EMPTY(xValTmp) .AND. aCampos[nX][4] == "1" //Campo obrigatOrio em branco
									xValTmp := aCampos[nX][nPosIPad]
								EndIf

								//Allan Constantino Bonfim - 05/09/2018 - Projeto WMS 100% - Correção para a retirada do apostrofo - evitando erro no insert com o WIS.
								If aCampos[nX][nPosTipo] == "1"
									xValTmp := STRTRAN(xValTmp, "'", " ")
								EndIf
																				
								If EMPTY(xValTmp)
									cValores += "NULL"
								ElseIf aCampos[nX][nPosTipo] == "1"
									cValores += "'"+ALLTRIM(xValTmp)+"'"
								ElseIf EMPTY(Val(xValTmp)) 
									If aCampos[nX][4] == "1" //ObrigatOrio
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
								If TcSQLExec(cQuery) >= 0 //Executa as InstruCoes do INSERT		
									cQuery := "Commit WORK"
									If TcSQLExec(cQuery) >= 0 //Realiza um Commit
										lIntegra := .T.						
									Else
										cErro 		:= "FALHA NA CONFIRMACAO DA INCLUSAO DOS DADOS NO BANCO DE DADOS WIS (COMMIT)"
										lIntegra 	:= .F.
									EndIf
								Else
									cErro 		:= "FALHA NA INCLUSAO DOS DADOS NO BANCO DE DADOS WIS (INSERT)"
									lIntegra 	:= .F.
								EndIf				
							Else
								lIntegra 	:= .F.
								cErro 		:= "FALHA NA CONEXÂO COM BANCO DE DADOS WIS - "+cDbOra+" (SET CONNECTION)"						
							EndIf		
									
							TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)
						
						Else
							lIntegra := .F.					
						EndIf
					Else
						lIntegra := .T. //Já integrou anteriormente - sO atualiza o status					
					EndIf
					
					//TcSetConn(nHndERP)				
						If lIntegra												
							If ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"
								If cStatus == "07"
									U_WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "08")
																	
									If lGrvLogOk
										DbSelectArea("ZWL")
										ZWL->(DbGoto((cTmpDados)->ZWLREC))
										U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "08")
									EndIf																
								Else
									U_WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "02")
									
									If lGrvLogOk
										DbSelectArea("ZWL")
										ZWL->(DbGoto((cTmpDados)->ZWLREC))																	
										U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "02")
									EndIf
								EndIf				
							Else
								If cStatus == "07"
									U_WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "08")
									If lGrvLogOk	
										DbSelectArea("ZWK")
										ZWK->(DbGoTo((cTmpDados)->ZWKREC))
										U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "08")								
									EndIf								
								Else
									U_WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "02")
									If lGrvLogOk	
										DbSelectArea("ZWK")
										ZWK->(DbGoTo((cTmpDados)->ZWKREC))
										U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "02")								
									EndIf										
								EndIf				
							EndIf
						Else												
							If ALLTRIM(cInterface) == "INT_E_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_E_DET_NOTA_FISCAL"
								If !EMPTY((cTmpDados)->ZWL_INTERF)
									cLogWis := U_WWIS1LIN(cEmpWis, (cTmpDados)->ZWL_DEPOSI, (cTmpDados)->ZWL_INTERF)									
								EndIf
								
								If cStatus == "07"
									U_WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "92")
									
									DbSelectArea("ZWL")
									ZWL->(DbGoto((cTmpDados)->ZWLREC))
										
									If !Empty(cLogWis)
										cErro += " LOG WIS ("+cLogWis+")"							
									EndIf
									
									cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
									cSoluCAo	:= ""
									 																
									U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWPFW",, IIF(!lCadOk, "2", "1"), cErro, ERRO92, cDescErro, cSolucao, "92")							
								Else
									U_WWSTATUS("ZWL", (cTmpDados)->ZWLREC, "98")
	
									DbSelectArea("ZWL")
									ZWL->(DbGoto((cTmpDados)->ZWLREC))
										
									If !Empty(cLogWis)
										cErro += " LOG WIS ("+cLogWis+")"							
									EndIf
									
									cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
									cSoluCAo	:= ""
									 																
									U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWPFW",, IIF(!lCadOk, "2", "1"), cErro, ERRO98, cDescErro, cSolucao, "98")															
								EndIf								
							Else							
								If !EMPTY((cTmpDados)->ZWK_INTERF)
									cLogWis := U_WWIS1LIN(cEmpWis, (cTmpDados)->ZWK_DEPOSI, (cTmpDados)->ZWK_INTERF)									
								EndIf
								
								If cStatus == "07"
									U_WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "92")
	
									If !Empty(cLogWis)
										cErro += " LOG WIS ("+cLogWis+")"							
									EndIf
									
									cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
									cSoluCAo	:= ""
									
									DbSelectArea("ZWK")
									ZWK->(DbGoTo((cTmpDados)->ZWKREC))
									U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW",ALLTRIM(cInterface), IIF(!lCadOk, "2", "1"), cErro, ERRO92, cDescErro, cSolucao, "92")								
								Else						
									U_WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "98")
									
									If !Empty(cLogWis)
										cErro += " LOG WIS ("+cLogWis+")"							
									EndIf
									
									cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
									cSoluCAo	:= ""
									
									DbSelectArea("ZWK")
									ZWK->(DbGoTo((cTmpDados)->ZWKREC))
									U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW",ALLTRIM(cInterface), IIF(!lCadOk, "2", "1"), cErro, ERRO98, cDescErro, cSolucao, "98")																
								EndIf				
							EndIf
						EndIf
					//TcSetConn(nHndORA)						
				End Transaction
								
				(cTmpDados)->(DbSkip())
			EndDo
			
			TCUnlink(nHndOra)	// Finaliza a conexAo TCLINK
		Else
			//UserException("Falha na conexAo com " + cDbOra + " em " + cSrvOra)			
			cErro 	:= "FALHA NA CONEXAO COM BANCO DE DADOS WIS - "+cDbOra+ " em " + cSrvOra+" (TCLINK)"	
			
			If cStatus == "01"
				U_WWSTATUS("ZWK", (cTmpDados)->ZWKREC, "98")
			EndIf
			
			If !(cTmpDados)->(EOF())			
				cDescErro 	:= ""
				cSoluCAo	:= ""
				
				DbSelectArea("ZWK")
				ZWK->(DbGoTo((cTmpDados)->ZWKREC))
				U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWPFW",ALLTRIM(cInterface), "1", cErro, ERRO98, cDescErro, cSolucao, "98")																							
			EndIf				
		Endif	
	
	ElseIf cOrigem == "2" //WIS
		
		If ALLTRIM(cInterface) == "INT_S_DET_NOTA_FISCAL"
			 
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWJ_EMPRES AS CD_EMPRESA, CD_DEPOSITO, NU_INTERFACE, NU_DOC_ERP, ZWJ_CODIGO, ZWJ_ITEM, ZWJ_DEPOSI, ZWJ_INTERF, ZWJ_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_DET_NOTA_FISCAL] "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWJ_EMPRES = CD_EMPRESA AND ZWJ_DEPOSI = CD_DEPOSITO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWJ_INTERF = NU_INTERFACE AND NU_DOC_ERP = ZWJ_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_CALIAS IN ('SD1','SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)
			//cQDados += "AND ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWJ_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		
		ElseIf ALLTRIM(cInterface) == "INT_S_CAB_NOTA_FISCAL" 			
		
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_EMPRES AS CD_EMPRESA, CD_DEPOSITO, NU_INTERFACE, NU_DOC_ERP, ZWI_CODIGO,NU_INTERFACE, ZWI_DEPOSI, ZWI_INTERF, ZWI_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_CAB_NOTA_FISCAL] "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_EMPRES = CD_EMPRESA AND ZWI_DEPOSI = CD_DEPOSITO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWI_INTERF = NU_INTERFACE AND NU_DOC_ERP = ZWI_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_CALIAS IN ('SF1', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)
			//cQDados += "AND ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWI_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Validar se todos os itens constam com status 05 para processamento. 
			cQDados += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ.ZWJ_CALIAS = ZWI.ZWI_CALIAS AND ZWJ.ZWJ_EMPRES = ZWI.ZWI_EMPRES AND ZWJ.ZWJ_DEPOSI = ZWI.ZWI_DEPOSI AND ZWJ.ZWJ_CODIGO = ZWI.ZWI_CODIGO AND ZWJ.ZWJ_STATUS <> '06') "+CHR(13)+CHR(10)
				
		ElseIf ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA"
			
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWJ_EMPRES AS CD_EMPRESA, CD_DEPOSITO, NU_INTERFACE, NU_PEDIDO_ORIGEM, ZWJ_CODIGO, ZWJ_ITEM, ZWJ_DEPOSI, ZWJ_INTERF, ZWJ_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_DET_PEDIDO_SAIDA] "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			//cQDados += "ON (ZWJ_EMPRES = CD_EMPRESA AND ZWJ_INTERF = NU_INTERFACE AND NU_PEDIDO_ORIGEM = ZWJ_PEDORI COLLATE LATIN1_GENERAL_100_CS_AS AND ID_PROCESSADO = 'N') "+CHR(13)+CHR(10)
			cQDados += "ON (ZWJ_EMPRES = CD_EMPRESA AND ZWJ_DEPOSI = CD_DEPOSITO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWJ_INTERF = NU_INTERFACE) "+CHR(13)+CHR(10)			
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI_PROCES = ZWJ_PROCES AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_CALIAS IN ('SC6', 'SD2', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)
			//cQDados += "AND ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWJ_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)			
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			
		ElseIf ALLTRIM(cInterface) == "INT_S_CAB_PEDIDO_SAIDA" 
		
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_EMPRES AS CD_EMPRESA, CD_DEPOSITO, NU_INTERFACE, NU_DOC_ERP, ZWI_CODIGO, ZWI_DEPOSI, ZWI_INTERF, ZWI_SITUAC "+CHR(13)+CHR(10)
			cQDados += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_CAB_PEDIDO_SAIDA] "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_EMPRES = CD_EMPRESA AND ZWI_DEPOSI = CD_DEPOSITO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWI_INTERF = NU_INTERFACE AND NU_DOC_ERP = ZWI_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_CALIAS IN ('SC5', 'SF2', 'SD3') "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)
			//cQDados += "AND ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWI_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Validar se todos os itens constam com status 05 para processamento. 
			cQDados += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ.ZWJ_CALIAS = ZWI.ZWI_CALIAS AND ZWJ.ZWJ_EMPRES = ZWI.ZWI_EMPRES AND ZWJ.ZWJ_DEPOSI = ZWI.ZWI_DEPOSI AND ZWJ.ZWJ_CODIGO = ZWI.ZWI_CODIGO AND ZWJ.ZWJ_STATUS <> '06') "+CHR(13)+CHR(10)

		ElseIf ALLTRIM(cInterface) == "INT_S_AJUSTE_ESTOQUE" 
		
			cQDados := "SELECT ZWI.R_E_C_N_O_ AS ZWIREC, ZWI_EMPRES AS CD_EMPRESA, CD_DEPOSITO, NU_INTERFACE, NU_DOC_ERP, ZWI_CODIGO, ZWI_SITUAC, ZWJ_DEPOSI, ZWJ_INTERF, ZWJ.R_E_C_N_O_ AS ZWJREC, ZWJ_CODIGO, ZWJ_ITEM "+CHR(13)+CHR(10)
			cQDados += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_AJUSTE_ESTOQUE] "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWJ_EMPRES = CD_EMPRESA AND ZWJ_DEPOSI = CD_DEPOSITO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWJ_INTERF = NU_INTERFACE) "+CHR(13)+CHR(10)
			cQDados += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
			cQDados += "ON (ZWI_FILIAL = ZWJ_FILIAL AND ZWI_EMPRES = ZWJ_EMPRES AND ZWI_DEPOSI = ZWJ_DEPOSI AND ZWI_CODIGO = ZWJ_CODIGO AND ZWI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQDados += "WHERE ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_CALIAS = 'TRF' "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_STATUS = '05' "+CHR(13)+CHR(10)
			cQDados += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)
			cQDados += "AND (ID_PROCESSADO = 'N' OR ID_PROCESSADO <> ZWJ_IDPROC COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			cQDados += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Validar se todos os itens constam com status 05 para processamento. 
			//cQDados += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ.ZWJ_CALIAS = ZWI.ZWI_CALIAS AND ZWJ.ZWJ_EMPRES = ZWI.ZWI_EMPRES AND ZWJ.ZWJ_CODIGO = ZWI.ZWI_CODIGO AND ZWJ.ZWJ_STATUS <> '06') "+CHR(13)+CHR(10)			
						
		EndIf
		
		cQDados := ChangeQuery(cQDados)
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados),cTmpDados)

		(cTmpDados)->(DbGotop())
		// Cria uma conexAo com um outro banco, outro DBAcces
		nHndOra := TcLink(cDbOra, cSrvOra, nPorta)
		If nHndOra >= 0
	
			While !(cTmpDados)->(Eof())
				
				Begin Transaction
					lIntegra	:= .F.
					
					cQuery := "UPDATE WIS50."+cInterface+" "
					cQuery += "SET ID_PROCESSADO = 'S', DT_PROCESSADO = (TO_DATE('"+StrZero(Year(dDataBase),4)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(day(dDataBase),2)+" "+Time()+"', 'yyyy/mm/dd hh24:mi:ss')) "
					
					If ALLTRIM(cInterface) == "INT_S_AJUSTE_ESTOQUE"
						cQuery += ", FILLER_5 = '"+(cTmpDados)->ZWJ_CODIGO+"' "
					EndIf
								
					cQuery += "WHERE "
					cQuery += "CD_EMPRESA = '"+Alltrim((cTmpDados)->CD_EMPRESA)+"' "
					cQuery += "AND CD_DEPOSITO = '"+Alltrim((cTmpDados)->CD_DEPOSITO)+"' "
					cQuery += "AND NU_INTERFACE = "+Alltrim(cValtoChar((cTmpDados)->NU_INTERFACE))+" "
					
					If !ALLTRIM(cInterface) == "INT_S_AJUSTE_ESTOQUE"
						If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" 
							cQuery += "AND NU_PEDIDO_ORIGEM = '"+Alltrim((cTmpDados)->NU_PEDIDO_ORIGEM)+"' "					
						Else
							cQuery += "AND NU_DOC_ERP = '"+Alltrim((cTmpDados)->NU_DOC_ERP)+"' "
						EndIf
					EndIf
										
					cQuery += "AND ID_PROCESSADO = 'N' "
									
					If TcSetConn(nHndORA)    //Conecta no Banco do Oracle (WIS)
						
						If TcSQLExec(cQuery) >= 0 //Executa as InstruCoes do INSERT		
							cQuery := "Commit WORK"
							If TcSQLExec(cQuery) >= 0 //Realiza um Commit
								lIntegra := .T.
							Else
								cErro 		:= "FALHA NA CONFIRMACAO DA ATUALIZACAO DOS DADOS NO BANCO DE DADOS WIS (COMMIT)"
								lIntegra 	:= .F.						
							EndIf
						Else
							cErro 		:= "FALHA NA ATUALIZACÂO DOS DADOS NO BANCO DE DADOS WIS (UPDATE)"
							lIntegra 	:= .F.
						EndIf
				
					Else
						lIntegra 	:= .F.
						cErro 		:= "FALHA NA CONEXAO COM BANCO DE DADOS WIS - "+cDbOra+" (SET CONNECTION)"	
					EndIf		
							
					TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)					
					
					If lIntegra						
						If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_S_DET_NOTA_FISCAL"
							/*If (cTmpDados)->ZWJ_SITUAC = '68' //Finaliza o pedido com status 09 sem a geraCAo da situaCAo 3
								U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "06")
								If lGrvLogOk							
									U_WIIWLOG("ZWJ", 3,, (cTmpDados)->ZWJREC, (cTmpDados)->ZWJ_CODIGO, (cTmpDados)->ZWJ_ITEM, "WIIWPFW", ALLTRIM(cInterface),,,, "09")
								EndIf							
							Else*/
								U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "06")

								If lGrvLogOk
									DbSelectArea("ZWJ")
									ZWJ->(DbGoto((cTmpDados)->ZWJREC))																	
									U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "06")
								EndIf
							//EndIf		
						ElseIf ALLTRIM(cInterface) == "INT_S_AJUSTE_ESTOQUE"	
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "06")

							If lGrvLogOk
								DbSelectArea("ZWJ")
								ZWJ->(DbGoto((cTmpDados)->ZWJREC))																	
								U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "06")
							EndIf
					
							U_WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "06")

							If lGrvLogOk	
								DbSelectArea("ZWI")
								ZWI->(DbGoTo((cTmpDados)->ZWIREC))
								U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "06")								
							EndIf																							
						Else
							U_WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "06")
							
							If lGrvLogOk	
								DbSelectArea("ZWI")
								ZWI->(DbGoTo((cTmpDados)->ZWIREC))
								U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "0",,,,, "06")								
							EndIf																	
						EndIf										
					Else
						If ALLTRIM(cInterface) == "INT_S_DET_PEDIDO_SAIDA" .OR. ALLTRIM(cInterface) == "INT_S_DET_NOTA_FISCAL"						
							If !EMPTY((cTmpDados)->ZWJ_INTERF)
								cLogWis := U_WWIS1LIN(cEmpWis, (cTmpDados)->ZWJ_DEPOSI, (cTmpDados)->ZWJ_INTERF)									
							EndIf							
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "94")

							DbSelectArea("ZWJ")
							ZWJ->(DbGoto((cTmpDados)->ZWJREC))
								
							If !Empty(cLogWis)
								cErro += " LOG WIS ("+cLogWis+")"							
							EndIf
							
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
							cSoluCAo	:= ""
							 																
							U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIIWPFW",, "1", cErro, ERRO94, cDescErro, cSolucao, "94")							
						ElseIf ALLTRIM(cInterface) == "INT_S_AJUSTE_ESTOQUE"	

							U_WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "94")
							
							If !EMPTY((cTmpDados)->ZWJ_INTERF)
								cLogWis := U_WWIS1LIN(cEmpWis, (cTmpDados)->ZWJ_DEPOSI, (cTmpDados)->ZWJ_INTERF)									
							EndIf							
							
							U_WWSTATUS("ZWJ", (cTmpDados)->ZWJREC, "94")

							DbSelectArea("ZWJ")
							ZWJ->(DbGoto((cTmpDados)->ZWJREC))
								
							If !Empty(cLogWis)
								cErro += " LOG WIS ("+cLogWis+")"							
							EndIf
							
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
							cSoluCAo	:= ""
							 																
							U_WIIWLOG(3,, "ZWJ", ZWJ->(RECNO()), ZWJ->ZWJ_EMPRES, ZWJ->ZWJ_DEPOSI, ZWJ->ZWJ_CODIGO, ZWJ->ZWJ_ITEM, ZWJ->ZWJ_SITUAC, "WIIWPFW",, "1", cErro, ERRO94, cDescErro, cSolucao, "94")									
						Else						
							If !EMPTY((cTmpDados)->ZWI_INTERF)
								cLogWis := U_WWIS1LIN(cEmpWis, (cTmpDados)->ZWI_DEPOSI, (cTmpDados)->ZWI_INTERF)									
							EndIf							
							U_WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "94")
														
							If !Empty(cLogWis)
								cErro += " LOG WIS ("+cLogWis+")"							
							EndIf
								
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
							cSoluCAo	:= ""
							
							DbSelectArea("ZWI")
							ZWI->(DbGoTo((cTmpDados)->ZWIREC))
							U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "1", cErro, ERRO94, cDescErro, cSolucao, "94")																											
						EndIf		
					EndIf
					//TcSetConn(nHndORA)    //Conecta no Banco do Oracle (WIS)						
				End Transaction
								
				(cTmpDados)->(DbSkip())
			EndDo
			
			TCUnlink(nHndOra)	// Finaliza a conexAo TCLINK			
		Else
			//UserException("Falha na conexAo com " + cDbOra + " em " + cSrvOra)			
			cErro 	:= "FALHA NA CONEXAO COM BANCO DE DADOS WIS - "+cDbOra+ " em " + cSrvOra+" (TCLINK)"	
			
			U_WWSTATUS("ZWI", (cTmpDados)->ZWIREC, "94")
			
			If !(cTmpDados)->(EOF())				
				cDescErro 	:= ""
				cSoluCAo	:= ""
				
				DbSelectArea("ZWI")
				ZWI->(DbGoTo((cTmpDados)->ZWIREC))
				U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIIWPFW", ALLTRIM(cInterface), "1", cErro, ERRO94, cDescErro, cSolucao, "94")																											
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

AtualizaCAo do Status

@author Allan Constantino Bonfim
@since  25/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

User Function WWSTATUS(cTabela, nRecno, cStatus, cDescErro)

Local aCabec		:= {}
Local aItens		:= {}
Local aLinha		:= {}
//Local cProcess	:= ""
//Local cTpDoc		:= "" 
Local cTabCab		:= ""
Local lRecSta		:= IIF(nRecno == 1 .OR. GetMv("MV_ZZRECLS",, .F.), .T., .F.) //Encontrei problema nos testes com tabelas sem registros. //IIF(nRecno == 1, .T., GetMv("MV_ZZRECLS",, .F.))

Default cTabela	:= ""
Default cStatus	:= ""
Default nRecno	:= 0
Default cDescErro	:= ""

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
			/*cProcess 	:= ZWL->ZWL_PROCES  
			cTpDoc 	:= GetAdvFVal("ZWK", "ZWK_TIPONF", ZWL->ZWL_FILIAL+ZWL->ZWL_EMPRES+ZWL->ZWL_CODIGO, 1, "")
			
			If EMPTY(cTpDoc)
				cTpDoc := GetAdvFVal("ZWK", "ZWK_TIPOPV", ZWL->ZWL_FILIAL+ZWL->ZWL_EMPRES+ZWL->ZWL_CODIGO, 1, "")
			EndIf
	*/
			//aCabec
			AADD(aCabec, {"ZWK_FILIAL"	, ZWL->ZWL_FILIAL, Nil})
			AADD(aCabec, {"ZWK_EMPRES"	, ZWL->ZWL_EMPRES, Nil})
			AADD(aCabec, {"ZWK_CODIGO"	, ZWL->ZWL_CODIGO, Nil})											
			AADD(aCabec, {"ZWK_DEPOSI"	, ZWL->ZWL_DEPOSI, Nil})	
			AADD(aCabec, {"ZWK_PROCES"	, ZWL->ZWL_PROCES, Nil})		
			AADD(aCabec, {"ZWK_SITUAC"	, ZWL->ZWL_SITUAC, Nil})		
	
			If Val(cStatus)> 50
				AADD(aCabec, {"ZWK_STATUS"	, cStatus, Nil})
			EndIf
	
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
		/*	cProcess 	:= ZWK->ZWK_PROCES  
			cTpDoc 	:= ZWK->ZWK_TIPONF
	
			If EMPTY(cTpDoc)
				cTpDoc := ZWK->ZWK_TIPOPV
			EndIf
	*/
			//aCabec
			AADD(aCabec, {"ZWK_FILIAL"	, ZWK->ZWK_FILIAL, Nil})
			AADD(aCabec, {"ZWK_CODIGO"	, ZWK->ZWK_CODIGO, Nil})
			AADD(aCabec, {"ZWK_EMPRES"	, ZWK->ZWK_EMPRES, Nil})					
			AADD(aCabec, {"ZWK_DEPOSI"	, ZWK->ZWK_DEPOSI, Nil})
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
					ZWI->ZWI_ERRO		:= ""
					ZWI->ZWI_IDPROC	:= "S"
					ZWI->ZWI_DTPROC	:= dDatabase					
				EndIf				
				
				If !EMPTY(cDescErro)
					ZWI->ZWI_ERRO	:= cDescErro
				EndIf
					
			ZWI->(MsUnlock())
			
			
		Else
					
			cTabCab	:= "ZWI"
		/*	cProcess 	:= ZWI->ZWI_PROCES  
			cTpDoc 	:= ZWI->ZWI_TIPONF
	
			If EMPTY(cTpDoc)
				cTpDoc := ZWI->ZWI_TIPOPV
			EndIf
			*/		
			//aCabec
			AADD(aCabec, {"ZWI_FILIAL"	, ZWI->ZWI_FILIAL, Nil})
			AADD(aCabec, {"ZWI_CODIGO"	, ZWI->ZWI_CODIGO, Nil})
			AADD(aCabec, {"ZWI_EMPRES"	, ZWI->ZWI_EMPRES, Nil})
			AADD(aCabec, {"ZWI_DEPOSI"	, ZWI->ZWI_DEPOSI, Nil})
			AADD(aCabec, {"ZWI_PROCES"	, ZWI->ZWI_PROCES, Nil})						
			AADD(aCabec, {"ZWI_SITUAC"	, ZWI->ZWI_SITUAC, Nil})							
			AADD(aCabec, {"ZWI_STATUS"	, cStatus, Nil})
			
			If cStatus == "05"
				AADD(aCabec, {"ZWI_DTINTE"	, dDatabase, Nil})
				AADD(aCabec, {"ZWI_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})
			ElseIf cStatus == "06"
				AADD(aCabec, {"ZWI_IDPROC"	, "S", Nil})
				AADD(aCabec, {"ZWI_DTPROC"	, dDatabase, Nil})
				AADD(aCabec, {"ZWI_ERRO"		, "", Nil})
			EndIf

			If !EMPTY(cDescErro)
				AADD(aCabec, {"ZWI_ERRO"	, cDescErro, Nil})
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
					ZWJ->ZWJ_DSERRO	:= ""
					ZWJ->ZWJ_IDPROC	:= "S"
					ZWJ->ZWJ_DTPROC	:= dDatabase					
				EndIf				

				If !EMPTY(cDescErro)
					ZWJ->ZWJ_DSERRO	:= cDescErro
				EndIf
			
			ZWJ->(MsUnlock())
			
		Else	
	
			cTabCab	:= "ZWI"				
	/*		cProcess 	:= ZWJ->ZWJ_PROCES  
			cTpDoc 	:= GetAdvFVal("ZWI", "ZWI_TIPONF", ZWJ->ZWJ_FILIAL+ZWJ->ZWJ_EMPRES+ZWJ->ZWJ_CODIGO, 1, "")
	
			If EMPTY(cTpDoc)
				cTpDoc := GetAdvFVal("ZWI", "ZWI_TIPOPV", ZWL->ZWL_FILIAL+ZWL->ZWL_EMPRES+ZWL->ZWL_CODIGO, 1, "")
			EndIf
	*/
			//aCabec
			AADD(aCabec, {"ZWI_FILIAL"	, ZWJ->ZWJ_FILIAL, Nil})
			AADD(aCabec, {"ZWI_CODIGO"	, ZWJ->ZWJ_CODIGO, Nil})
			AADD(aCabec, {"ZWI_EMPRES"	, ZWJ->ZWJ_EMPRES, Nil})					
			AADD(aCabec, {"ZWI_DEPOSI"	, ZWJ->ZWJ_DEPOSI, Nil})
			AADD(aCabec, {"ZWI_PROCES"	, ZWJ->ZWJ_PROCES, Nil})						
			AADD(aCabec, {"ZWI_SITUAC"	, ZWJ->ZWJ_SITUAC, Nil})

			If Val(cStatus)> 50
				AADD(aCabec, {"ZWI_STATUS"	, cStatus, Nil})
			EndIf
				
			//aItens
			aLinha	:= {}
			//AADD(aLinha, {"LINPOS"		, "ZWJ_ITEM", ZWJ->ZWJ_ITEM})
			AADD(aLinha, {"LINPOS"		, "ZWJ_ITEM+ZWJ_INTERF", ZWJ->ZWJ_ITEM, ZWJ->ZWJ_INTERF}) //Considerar a interface pois o item pode voltar duplicado do WIS (Quebrado)
			AADD(aLinha, {"AUTDELETA"	, "N",Nil})
			AADD(aLinha, {"ZWJ_STATUS"	, cStatus})

			If !EMPTY(cDescErro)
				AADD(aLinha, {"ZWJ_DSERRO"	, cDescErro})
			EndIf
	
			If cStatus == "05"
				AADD(aLinha, {"ZWJ_DTINTE"	, dDatabase})
				AADD(aLinha, {"ZWJ_HRINTE"	, (SUBSTR(TIME(),1, 5)), Nil})
			ElseIf cStatus == "06"
				AADD(aLinha, {"ZWJ_DSERRO"	, ""})				
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
	ElseIf cTabCab == "ZWI"
		U_WIIWENT(cTabCab, 4, aCabec, aItens)
	EndIf
EndIf
	
Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WW01PROC

AtualizaCAo do Processamento Protheus

@author Allan Constantino Bonfim
@since  03/05/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

User Function WW01PROC(cTabela, nRecno, cTabProc, nRecProc, cDocument)

//Local aCabec		:= {}
//Local aItens		:= {}
//Local aLinha		:= {}

Default cTabela	:= ""
Default cTabProc	:= ""
Default nRecno	:= 0
Default nRecProc	:= 0
Default cDocument	:= ""

If cTabela == "ZWI"

	DbSelectArea("ZWI")
	ZWI->(DbGoto(nRecno))

	RecLock("ZWI", .F.)
		ZWI->ZWI_PALIAS 	:= cTabProc
		ZWI->ZWI_PRECOR 	:= nRecProc
		ZWI->ZWI_PDOCUM 	:= cDocument
	ZWI->(MsUnlock())
	
ElseIf cTabela == "ZWJ"

	DbSelectArea("ZWJ")
	ZWJ->(DbGoto(nRecno))

	RecLock("ZWJ", .F.)
		ZWJ->ZWJ_PALIAS 	:= cTabProc
		ZWJ->ZWJ_PRECOR 	:= nRecProc
		ZWJ->ZWJ_PDOCUM 	:= cDocument
	ZWJ->(MsUnlock())			
		
EndIf
	
Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS01NF

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  05/05/2018
@version P12
@return cProc, Codigo do Processo
/*/
//-------------------------------------------------------------------------------------------------

User Function WWIS01NF(cDocum, lHelp)

Local aArea		:= GetArea()
Local cRet			:= ""
Local aPergs 		:= {}
Local aRet			:= {}
Local cTxtDoc		:= ""

Default cDocum	:= ""
Default lHelp		:= .T.

If EMPTY(cDocum)
	cTxtDoc := "Selecione o processo ref. esse documento:"
Else
	cTxtDoc := "Selecione o processo ref. o "+cDocum+" :"
EndIf
   
aAdd(aPergs ,{9, cTxtDoc, 200,,.T.})
aAdd(aPergs ,{1, "Processo: ", SPACE(TAMSX3("ZWO_CODIGO")[1]), "@!", "NaoVazio()", "ZWO001", "", TAMSX3("ZWO_CODIGO")[1], .T.})    

If ParamBox(aPergs, "Processo", aRet)
	DbSelectArea("ZWO")
	DbSetOrder(1) //ZWO_FILIAL, ZWO_CODIGO, R_E_C_N_O_, D_E_L_E_T_
	If ZWO->(DbSeek(xFilial("ZWO")+aRet[2])) //ExistCpo("ZWO", aRet[2]) 
		cRet := aRet[2]
	Else
		If lHelp
			Help(NIL, NIL, "WWIS01NF", NIL, "O processo informado nAo existe.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione um processo válido e tente novamente."})
		EndIf	
	EndIf
EndIf	
	
RestArea(aArea)

Return cRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WW01GCPO

Rotina para integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  11/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------

User Function WW01GCPO(nRet, cInterface, cOrigem, cCampo)

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
/*/{Protheus.doc} WIIWTENT

Rotina para teste da Interface de IntegraCAo de Entrada WIS -> PROTHEUS.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return NIL
/*/
//-------------------------------------------------------------------------------------------------

User Function WIIWTENT(nOpcA, nIntegr, cProcess, lProcRet, aCabec, aItens)

Local aArea		:= GetArea()
Local aLinha		:= {}
Local cQuery 		:= ""
Local cQuery1 	:= ""
Local cAliasQry 	:= GetNextAlias()
Local cItemQry 	:= GetNextAlias()
Local cCampos		:= ""
Local nX			:= 0
//Local nY			:= 0
Local aStruZWI	:= {}
Local aStruZWJ	:= {}
Local aStruTmp	:= {}
Local nPosZWI		:= 0
Local nPosZWJ		:= 0
Local cEmpWis		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) //PADR(IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')), TAMSX3("ZWK_EMPRES")[1], " ")
Local cFilWis		:= PADL(FWCodFil(), 3, "0")  
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default nOpcA		:= 2
Default nIntegr 	:= 0
Default cProcess	:= "ZZZ"
Default lProcRet	:= .T.
Default aCabec	:= {}
Default aItens	:= {}


DbSelectArea("ZWI")
DbSelectArea("ZWJ")

//INCLUSAO
If nOpcA == 3

	If nIntegr == 1	
		cCampos 	:= U_WW01GCPO(4, "INT_S_CAB_NOTA_FISCAL", "2")
		
		If !Empty(cCampos)

			cQuery := "SELECT "+CHR(13)+CHR(10)
			cQuery += "NU_DOC_ERP, "+CHR(13)+CHR(10)
			cQuery += "'"+xFilial("ZWI")+"' AS ZWI_FILIAL, "+CHR(13)+CHR(10)
			//cQuery += "'"+FWxFilial()+"' AS ZWI_FILORI, "+CHR(13)+CHR(10)				
			cQuery += "ZWK_PROCES AS ZWI_PROCES, "+CHR(13)+CHR(10)
			cQuery += "ZWK_RECORI AS ZWI_RECORI, "+CHR(13)+CHR(10)
			
			If cProcess $ "06B/015/038/039/042"						
				cQuery += "'SD3' AS ZWI_CALIAS, "+CHR(13)+CHR(10)
			Else
				cQuery += "'SF1' AS ZWI_CALIAS, "+CHR(13)+CHR(10)
			EndIf
			
			If !lProcRet
				cQuery += "'05' AS ZWI_STATUS, "+CHR(13)+CHR(10)
			Else
				cQuery += "(CASE WHEN CD_SITUACAO = 9 THEN '04' ELSE '05' END) AS ZWI_STATUS, "+CHR(13)+CHR(10)
			EndIf
			
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWI_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWI_HRINCL, "+CHR(13)+CHR(10)
			cQuery += cCampos+" "+CHR(13)+CHR(10)
			cQuery += "FROM 	( "+CHR(13)+CHR(10)
			cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
			cQuery += "		'SELECT * FROM INT_S_CAB_NOTA_FISCAL "+CHR(13)+CHR(10)
			cQuery += "		WHERE CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
			cQuery += "		AND ID_PROCESSADO = ''N''') "+CHR(13)+CHR(10)
			cQuery += "		) TMPWIS "+CHR(13)+CHR(10)				
			cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SF1', 'SD3') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "ZWK_STATUS = '03' "+CHR(13)+CHR(10)
			cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Correção para evitar chave duplicada no retorno do processamento do WIS.
			cQuery += "AND ZWK_SITUAC = '1' "+CHR(13)+CHR(10)
			cQuery += "AND NOT EXISTS (SELECT ZWI_CODIGO FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) WHERE ZWI.D_E_L_E_T_ = ' ' AND ZWI_CALIAS IN ('SF1', 'SD3') AND ZWI_EMPRES = '"+cEmpWis+"' AND ZWI_DEPOSI = '"+cFilWis+"' AND NU_DOC_ERP = ZWI_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Garantir que nenhum item foi processado no WIS e nAo teve a tabela integradora atualizada evitando erros nos demais status. 
			cQuery += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS IN ('SD1', 'SD3') AND ZWL_EMPRES = '"+cEmpWis+"' AND ZWL_DEPOSI = '"+cFilWis+"' AND NU_DOC_ERP = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_STATUS <> '03') "+CHR(13)+CHR(10)
											
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
			While !(cAliasQry)->(Eof())
									
				aStruTmp 	:= (cAliasQry)->(dBStruct())
				aStruZWI 	:= ZWI->(dBStruct())
				aCabec		:= {}		
				aItens		:= {}
							
				For nX:= 1 to Len(aStruTmp)
						
					nPosZWI := ASCAN(aStruZWI, {|x| x[1] == aStruTmp[nX][1]})
						
					If nPosZWI > 0
						
						If aStruZWI[nPosZWI][2] <> aStruTmp[nX][2]
							If aStruZWI[nPosZWI][2] == "D"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2])							
							ElseIf aStruZWI[nPosZWI][2] == "N"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2], aStruZWI[nPosZWI][3], aStruZWI[nPosZWI][4])
							EndIf
						EndIf
						
						If aStruZWI[nPosZWI][2] == "C" .AND. ValType((cAliasQry)->&(aStruTmp[nX][1])) == "N"
							AADD(aCabec, {aStruTmp[nX][1], cValtoChar((cAliasQry)->&(aStruTmp[nX][1])), Nil})
						Else
							AADD(aCabec, {aStruTmp[nX][1], (cAliasQry)->&(aStruTmp[nX][1]), Nil})
						EndIf
					EndIf
				Next
	
				cCampos 	:= U_WW01GCPO(4, "INT_S_DET_NOTA_FISCAL", "2")
				
				cQuery1 := "SELECT "+CHR(13)+CHR(10)
				cQuery1 += "'"+xFilial("ZWJ")+"' AS ZWJ_FILIAL, "+CHR(13)+CHR(10)
				cQuery1 += "ZWL_PROCES AS ZWJ_PROCES, "+CHR(13)+CHR(10)
				
				If cProcess $ "06B/015/038/039/042"
					cQuery1 += "'SD3' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
				Else
					cQuery1 += "'SD1' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
				EndIf
				
				If !lProcRet
					cQuery1 += "'05' AS ZWJ_STATUS, "+CHR(13)+CHR(10)
				Else
					cQuery1 += "(CASE WHEN CD_SITUACAO = 9 THEN '04' ELSE '05' END) AS ZWJ_STATUS, "+CHR(13)+CHR(10)
				EndIf
			
				cQuery1 += "ZWL_RECORI AS ZWJ_RECORI, "+CHR(13)+CHR(10)			
				cQuery1 += "ZWL_DEPERP AS ZWJ_DEPORI, "+CHR(13)+CHR(10)					
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWJ_DTINCL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWJ_HRINCL, "+CHR(13)+CHR(10)
				cQuery1 += cCampos+" "+CHR(13)+CHR(10)					
				cQuery1 += "FROM 	( "+CHR(13)+CHR(10)
				cQuery1 += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
				cQuery1 += "		'SELECT * FROM INT_S_DET_NOTA_FISCAL "+CHR(13)+CHR(10)
				cQuery1 += "		WHERE CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND NU_DOC_ERP = ''"+ALLTRIM((cAliasQry)->NU_DOC_ERP)+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
				cQuery1 += "		AND ID_PROCESSADO = ''N''') "+CHR(13)+CHR(10)
				cQuery1 += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (ZWL_EMPRES = CD_EMPRESA AND NU_DOC_ERP = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND NU_ITEM_CORP = ZWL_ITEM COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_CALIAS IN ('SD1', 'SD3') AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
				cQuery1 += "WHERE "+CHR(13)+CHR(10) 
				cQuery1 += "ZWL_FILIAL = '"+xFilial("ZWL")+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Correção para evitar chave duplicada no retorno do processamento do WIS.
				cQuery1 += "AND ZWL_SITUAC = '1' "+CHR(13)+CHR(10)				
				cQuery1 += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_CALIAS IN ('SD1', 'SD3') AND ZWJ_EMPRES = '"+cEmpWis+"' AND ZWJ_DEPOSI = '"+cFilWis+"' AND ZWJ_CODIGO = '"+ALLTRIM((cAliasQry)->NU_DOC_ERP)+"') "+CHR(13)+CHR(10)
									
									
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
					
				While !(cItemQry)->(Eof())
	
					aStruTmp 	:= (cItemQry)->(dBStruct())
					aStruZWJ 	:= ZWJ->(dBStruct())
					aLinha		:= {}
							
					For nX:= 1 to Len(aStruTmp)
							
						nPosZWJ := ASCAN(aStruZWJ, {|x| x[1] == aStruTmp[nX][1]})
							
						If nPosZWJ > 0
							
							If aStruZWJ[nPosZWJ][2] <> aStruTmp[nX][2]
								If aStruZWJ[nPosZWJ][2] == "D"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2])
								ElseIf aStruZWJ[nPosZWJ][2] == "N"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2], aStruZWJ[nPosZWJ][3], aStruZWJ[nPosZWJ][4])
								EndIf
							EndIf
												
							If nX == Len(aStruTmp) //Ultimo item
								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"
									AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf
							Else
								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"
									AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1]))})
								Else 						
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1])})
								EndIf
							EndIf
						EndIf					
					Next
					
					AADD(aItens, aLinha)
														
					(cItemQry)->(DbSkip())
				EndDo
				
				If Select(cItemQry) > 0
					(cItemQry)->(DbCloseArea())
				EndIf
				
				If Len(aCabec) > 0 .AND. Len(aItens) > 0
					U_WIIWENT("ZWI", nOpcA, aCabec, aItens)
				EndIf
				
			(cAliasQry)->(DbSkip())
				
			EndDo
		EndIf	
				
	ElseIf nIntegr == 2
		
		cCampos 	:= U_WW01GCPO(4, "INT_S_CAB_PEDIDO_SAIDA", "2")
		
		If !Empty(cCampos)

			cQuery := "SELECT "+CHR(13)+CHR(10)
			cQuery += "NU_PEDIDO_ORIGEM, "+CHR(13)+CHR(10)
			cQuery += "CD_CARGA, "+CHR(13)+CHR(10)
			cQuery += "'"+xFilial("ZWI")+"' AS ZWI_FILIAL, "+CHR(13)+CHR(10)		
			cQuery += "ZWK_PROCES AS ZWI_PROCES, "+CHR(13)+CHR(10)
			cQuery += "ZWK_RECORI AS ZWI_RECORI, "+CHR(13)+CHR(10)
			
			If cProcess $ "015/038/039/042"
				cQuery += "'SD3' AS ZWI_CALIAS, "+CHR(13)+CHR(10)
			ElseIf cProcess $ "007"
				cQuery += "'SF2' AS ZWI_CALIAS, "+CHR(13)+CHR(10)	
				cQuery += "ZWK_NOTA AS ZWI_NOTA, "+CHR(13)+CHR(10)			
				cQuery += "ZWK_SERIE AS ZWI_SERIE, "+CHR(13)+CHR(10)		
			Else
				cQuery += "'SC5' AS ZWI_CALIAS, "+CHR(13)+CHR(10)
			EndIf

			If !lProcRet
				cQuery += "'05' AS ZWI_STATUS, "+CHR(13)+CHR(10)
			Else
				If cProcess $ "007/015/038/039/042"
					cQuery += "(CASE WHEN CD_SITUACAO = 57 THEN '04' ELSE '05' END) AS ZWI_STATUS, "+CHR(13)+CHR(10)
				Else
					//Allan Constantino Bonfim - CM Solutions - 10/06/2019 - Ajuste para não processar retornos de faturamento antecipado. 
					//cQuery += "(CASE WHEN ZWK_NOTA = ' ' AND ZWK_SERIE = ' ' THEN '04' ELSE '05' END) AS ZWI_STATUS, "+CHR(13)+CHR(10)
					cQuery += "(CASE WHEN ZWK_NOTA+ZWK_SERIE <> ' ' OR DAI_NFISCA+DAI_SERIE <> ' ' THEN '05' ELSE '04' END) AS ZWI_STATUS, "+CHR(13)+CHR(10)
				EndIf
			EndIf
						
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWI_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWI_HRINCL, "+CHR(13)+CHR(10)

			//Allan Constantino Bonfim - 29/05/2018 - Tratamento para nAo enviar o cOdigo do romaneio nos pedidos
			//CM Solutions - Allan Constantino Bonfim - 19/07/2018 - Chamado 23125 - Tratamento para nao enviar o codigo do romaneio nos pedidos de etiqueta de volume - Processo 046
			If cProcess $ "030/046"
				cQuery += "ZWK_CARGA AS ZWI_CARGA, "+CHR(13)+CHR(10)
			EndIf

			cQuery += cCampos+" "+CHR(13)+CHR(10)
			cQuery += "FROM 	( "+CHR(13)+CHR(10)
			cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
			cQuery += "		'SELECT * FROM INT_S_CAB_PEDIDO_SAIDA "+CHR(13)+CHR(10)
			cQuery += "		WHERE CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
			cQuery += "		AND ID_PROCESSADO = ''N''') "+CHR(13)+CHR(10)
			cQuery += "		) TMPWIS "+CHR(13)+CHR(10)																		
			cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SC5', 'SD3', 'SF2') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			
			//Allan Constantino Bonfim - CM Solutions - 10/06/2019 - Ajuste para não processar retornos de faturamento antecipado. 
			cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (DAK_FILIAL = ZWK_FILIAL AND DAK_COD = ZWK_CARGA AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD AND DAI_PEDIDO = ZWK_PEDORI AND DAI_CLIENT+DAI_LOJA = ZWK_CLIFOR AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
						
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)			
			cQuery += "AND ZWK_PROCES LIKE '%"+cProcess+"%' "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Correção para evitar chave duplicada no retorno do processamento do WIS.
			cQuery += "AND ZWK_SITUAC = '1' "+CHR(13)+CHR(10)						
			cQuery += "AND NOT EXISTS (SELECT ZWI_CODIGO FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) WHERE ZWI.D_E_L_E_T_ = ' ' AND ZWI_CALIAS IN ('SC5', 'SD3', 'SF2') AND ZWI_EMPRES = '"+cEmpWis+"' AND ZWI_DEPOSI = '"+cFilWis+"' AND NU_DOC_ERP = ZWI_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
			//Allan Constantino Bonfim - 10/07/2018 - Garantir que nenhum item foi processado no WIS e nAo teve a tabela integradora atualizada evitando erros nos demais status. 
			cQuery += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWL_EMPRES = '"+cEmpWis+"' AND ZWL_DEPOSI = '"+cFilWis+"' AND NU_DOC_ERP = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_STATUS <> '03') "+CHR(13)+CHR(10)			
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
			While !(cAliasQry)->(Eof())
						
				//aCabec			
				aStruTmp 	:= (cAliasQry)->(dBStruct())
				aStruZWI 	:= ZWI->(dBStruct())
				aCabec		:= {}		
				aItens		:= {}
							
				For nX:= 1 to Len(aStruTmp)
						
					nPosZWI := ASCAN(aStruZWI, {|x| x[1] == aStruTmp[nX][1]})
						
					If nPosZWI > 0						
						If aStruZWI[nPosZWI][2] <> aStruTmp[nX][2]
							If aStruZWI[nPosZWI][2] == "D"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2])							
							ElseIf aStruZWI[nPosZWI][2] == "N"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2], aStruZWI[nPosZWI][3], aStruZWI[nPosZWI][4])
							EndIf
						EndIf

						If aStruZWI[nPosZWI][2] == "C" .AND. ValType((cAliasQry)->&(aStruTmp[nX][1])) == "N"						
							//Ajuste do retorno do campo CD_CARGA que no WIS é numérico
							If aStruTmp[nX][1] == "ZWI_CARGA"
								AADD(aCabec, {aStruTmp[nX][1], PADL(cValtoChar((cAliasQry)->&(aStruTmp[nX][1])), TAMSX3("DAK_COD")[1], "0"), Nil})								
							Else 
								AADD(aCabec, {aStruTmp[nX][1], cValtoChar((cAliasQry)->&(aStruTmp[nX][1])), Nil})
							EndIf
						Else
							AADD(aCabec, {aStruTmp[nX][1], (cAliasQry)->&(aStruTmp[nX][1]), Nil})
						EndIf					
					EndIf
				Next
	
				cCampos 	:= U_WW01GCPO(4, "INT_S_DET_PEDIDO_SAIDA", "2")

				cQuery1 := "SELECT "+CHR(13)+CHR(10)
				cQuery1 += "'"+xFilial("ZWJ")+"' AS ZWJ_FILIAL, "+CHR(13)+CHR(10)
				cQuery1 += "ZWL_PROCES AS ZWJ_PROCES, "+CHR(13)+CHR(10)
				cQuery1 += "ZWL_RECORI AS ZWJ_RECORI, "+CHR(13)+CHR(10)
				cQuery1 += "ZWL_DEPERP AS ZWJ_DEPORI, "+CHR(13)+CHR(10)
				
				If cProcess $ "015/038/039/042"
					cQuery1 += "'SD3' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
				ElseIf cProcess $ "007"
					cQuery1 += "'SD2' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
					cQuery1 += "ZWL_NOTA AS ZWJ_NOTA, "+CHR(13)+CHR(10)			
					cQuery1 += "ZWL_SERIE AS ZWJ_SERIE, "+CHR(13)+CHR(10)
				Else
					cQuery1 += "'SC6' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
				EndIf	

				If !lProcRet
					cQuery1 += "'05' AS ZWJ_STATUS, "+CHR(13)+CHR(10)
				Else
					If cProcess $ "007/015/038/039/042"
						cQuery1 += "(CASE WHEN CD_SITUACAO = 57 THEN '04' ELSE '05' END) AS ZWJ_STATUS, "+CHR(13)+CHR(10)
					Else
						//Allan Constantino Bonfim - CM Solutions - 10/06/2019 - Ajuste para não processar retornos de faturamento antecipado. 
						//cQuery1 += "(CASE WHEN ZWL_NOTA = ' ' AND ZWL_SERIE = ' ' THEN '04' ELSE '05' END) AS ZWJ_STATUS, "+CHR(13)+CHR(10)
						cQuery1 += "(CASE WHEN ZWL_NOTA+ZWL_SERIE <> ' ' OR DAI_NFISCA+DAI_SERIE <> ' ' THEN '05' ELSE '04' END) AS ZWJ_STATUS, "+CHR(13)+CHR(10)
						
					EndIf 
				EndIf

				//Allan Constantino Bonfim - 29/05/2018 - Tratamento para nAo enviar o cOdigo do romaneio nos pedidos
				//CM Solutions - Allan Constantino Bonfim - 19/07/2018 - Chamado 23125 - Tratamento para nao enviar o codigo do romaneio nos pedidos de etiqueta de volume - Processo 046
				If cProcess $ "030/046"
					cQuery1 += "ZWL_CARGA AS ZWJ_CARGA, "+CHR(13)+CHR(10)
				EndIf

				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWJ_DTINCL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWJ_HRINCL, "+CHR(13)+CHR(10)
				cQuery1 += cCampos+" "+CHR(13)+CHR(10)				
				cQuery1 += "FROM 	( "+CHR(13)+CHR(10)
				cQuery1 += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
				cQuery1 += "		'SELECT * FROM INT_S_DET_PEDIDO_SAIDA "+CHR(13)+CHR(10)
				cQuery1 += "		WHERE CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND NU_PEDIDO_ORIGEM = ''"+ALLTRIM((cAliasQry)->NU_PEDIDO_ORIGEM)+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND CD_CARGA = ''"+cValtoChar((cAliasQry)->CD_CARGA)+"'' "+CHR(13)+CHR(10)
				cQuery1 += "		AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
				cQuery1 += "		AND ID_PROCESSADO = ''N''') "+CHR(13)+CHR(10)
				cQuery1 += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (ZWL_EMPRES = CD_EMPRESA AND NU_PEDIDO_ORIGEM = ZWL_PEDORI COLLATE LATIN1_GENERAL_100_CS_AS AND NU_ITEM_CORP = ZWL_ITEM COLLATE LATIN1_GENERAL_100_CS_AS AND CD_CARGA = '"+cValtoChar((cAliasQry)->CD_CARGA)+"' AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)						

				//Allan Constantino Bonfim - CM Solutions - 10/06/2019 - Ajuste para não processar retornos de faturamento antecipado. 
				cQuery1 += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (DAK_FILIAL = ZWL_FILIAL AND DAK_COD = ZWL_CARGA AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQuery1 += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD AND DAI_PEDIDO = ZWL_PEDORI AND DAI_CLIENT+DAI_LOJA = ZWL_CLIFOR AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			

				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND ZWL_FILIAL = '"+xFilial("ZWL")+"' "+CHR(13)+CHR(10)
				//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Correção para evitar chave duplicada no retorno do processamento do WIS.
				cQuery1 += "AND ZWL_SITUAC = '1' "+CHR(13)+CHR(10)

				//Allan Constantino Bonfim - 30/10/2018 - CM Solutions - Projeto WMS 100% - Correção na verificação da carga do item.
				//CM Solutions - Allan Constantino Bonfim - 19/07/2018 - Chamado 23125 - Tratamento para nao enviar o codigo do romaneio nos pedidos de etiqueta de volume - Processo 046
				If cProcess $ "030/046"
					cQuery1 += "AND ZWL_CARGA = '"+(cAliasQry)->ZWI_CARGA+"' "+CHR(13)+CHR(10)				
					cQuery1 += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWJ_EMPRES = '"+cEmpWis+"' AND ZWJ_DEPOSI = '"+cFilWis+"' AND ZWJ_PEDORI = '"+(cAliasQry)->NU_PEDIDO_ORIGEM+"' AND ZWJ_CARGA = '"+(cAliasQry)->ZWI_CARGA+"') "+CHR(13)+CHR(10)				
				Else
					cQuery1 += "AND ZWL_CARGA = '"+PADL(cValtoChar((cAliasQry)->CD_CARGA), TAMSX3("DAK_COD")[1], "0")+"' "+CHR(13)+CHR(10)				
					cQuery1 += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWJ_EMPRES = '"+cEmpWis+"' AND ZWJ_DEPOSI = '"+cFilWis+"' AND ZWJ_PEDORI = '"+(cAliasQry)->NU_PEDIDO_ORIGEM+"' AND ZWJ_CARGA = '"+PADL(cValtoChar((cAliasQry)->CD_CARGA), TAMSX3("DAK_COD")[1], "0")+"') "+CHR(13)+CHR(10)				
				EndIf
																									
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
					
				While !(cItemQry)->(Eof())
	
					aStruTmp 	:= (cItemQry)->(dBStruct())
					aStruZWJ 	:= ZWJ->(dBStruct())
					aLinha		:= {}
							
					For nX:= 1 to Len(aStruTmp)
							
						nPosZWJ := ASCAN(aStruZWJ, {|x| x[1] == aStruTmp[nX][1]})
							
						If nPosZWJ > 0
							
							If aStruZWJ[nPosZWJ][2] <> aStruTmp[nX][2]
								If aStruZWJ[nPosZWJ][2] == "D"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2])
								ElseIf aStruZWJ[nPosZWJ][2] == "N"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2], aStruZWJ[nPosZWJ][3], aStruZWJ[nPosZWJ][4])
								EndIf
							EndIf
												
							If nX == Len(aStruTmp) //Ultimo item
								/*If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"
									AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf */

								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"						
									//Ajuste do retorno do campo CD_CARGA que no WIS é numérico
									If aStruTmp[nX][1] == "ZWJ_CARGA"
										AADD(aLinha, {aStruTmp[nX][1], PADL(cValtoChar((cItemQry)->&(aStruTmp[nX][1])), TAMSX3("DAK_COD")[1], "0"), Nil})								
									Else 
										AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
									EndIf
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf													
							Else
								/*If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"
									AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1]))})
								Else 						
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1])})
								EndIf*/
								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"						
									//Ajuste do retorno do campo CD_CARGA que no WIS é numérico
									If aStruTmp[nX][1] == "ZWJ_CARGA"
										AADD(aLinha, {aStruTmp[nX][1], PADL(cValtoChar((cItemQry)->&(aStruTmp[nX][1])), TAMSX3("DAK_COD")[1], "0"), Nil})								
									Else 
										AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
									EndIf
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf								
							EndIf
						EndIf					
					Next
					
					AADD(aItens, aLinha)
														
					(cItemQry)->(DbSkip())
				EndDo
				
				If Select(cItemQry) > 0
					(cItemQry)->(DbCloseArea())
				EndIf
				
				If Len(aCabec) > 0 .AND. Len(aItens) > 0
					U_WIIWENT("ZWI", nOpcA, aCabec, aItens)
				EndIf
				
			(cAliasQry)->(DbSkip())
				
			EndDo
		EndIf		

	ElseIf nIntegr == 3
		
		cCampos 	:= U_WW01GCPO(4, "INT_S_CAB_AJUSTE_ESTOQUE", "2")
		//"ZWI_ENTRADAS - ZWI_CLIFOR - ZWI_ENTRADAS - ZWI_CLIFOR - FWNOWIDTH - Valor atribuído difere do tamanho do campo (Cod Forneced) -  -   -       
		If !Empty(cCampos)
			
			cQuery := "SELECT "+CHR(13)+CHR(10)
			cQuery += "'"+xFilial("ZWI")+"' AS ZWI_FILIAL, "+CHR(13)+CHR(10)	 	  	
			cQuery += "'"+cProcess+"' AS ZWI_PROCES, "+CHR(13)+CHR(10)			
			cQuery += "'TRF' AS ZWI_CALIAS, "+CHR(13)+CHR(10)
			cQuery += "'04' AS ZWI_STATUS, "+CHR(13)+CHR(10)
			cQuery += "'15' AS ZWI_SITUAC, "+CHR(13)+CHR(10)					
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWI_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWI_HRINCL, "+CHR(13)+CHR(10)
			cQuery += cCampos+" "+CHR(13)+CHR(10)			
			cQuery += "FROM 	( "+CHR(13)+CHR(10)
			cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
			cQuery += "		'SELECT * FROM INT_S_AJUSTE_ESTOQUE "+CHR(13)+CHR(10)
			cQuery += "		WHERE CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10)
			cQuery += "		AND TP_MOVIMENTO = ''T'' "+CHR(13)+CHR(10)
			cQuery += "		AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
			cQuery += "		AND ID_PROCESSADO = ''N''') "+CHR(13)+CHR(10)
			cQuery += "		) TMPWIS "+CHR(13)+CHR(10)
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)					
			cQuery += "AND NOT EXISTS (SELECT ZWI_CODIGO FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) WHERE ZWI.D_E_L_E_T_ = ' ' AND ZWI_CALIAS = 'TRF' AND ZWI_EMPRES = '"+cEmpWis+"' AND ZWI_DEPOSI = '"+cFilWis+"' AND NU_INTERFACE = ZWI_INTERF COLLATE LATIN1_GENERAL_100_CS_AS) "+CHR(13)+CHR(10)
													
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
			While !(cAliasQry)->(Eof())
						
				//aCabec			
				aStruTmp 	:= (cAliasQry)->(dBStruct())
				aStruZWI 	:= ZWI->(dBStruct())
				aCabec		:= {}		
				aItens		:= {}
							
				For nX:= 1 to Len(aStruTmp)
						
					nPosZWI := ASCAN(aStruZWI, {|x| x[1] == aStruTmp[nX][1]})
						
					If nPosZWI > 0						
						If aStruZWI[nPosZWI][2] <> aStruTmp[nX][2]
							If aStruZWI[nPosZWI][2] == "D"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2])							
							ElseIf aStruZWI[nPosZWI][2] == "N"
								TCSetField(cAliasQry, aStruZWI[nPosZWI][1], aStruZWI[nPosZWI][2], aStruZWI[nPosZWI][3], aStruZWI[nPosZWI][4])
							EndIf
						EndIf

						If aStruZWI[nPosZWI][2] == "C" .AND. ValType((cAliasQry)->&(aStruTmp[nX][1])) == "N"						
							AADD(aCabec, {aStruTmp[nX][1], cValtoChar((cAliasQry)->&(aStruTmp[nX][1])), Nil})
						Else
							AADD(aCabec, {aStruTmp[nX][1], (cAliasQry)->&(aStruTmp[nX][1]), Nil})
						EndIf					
					EndIf
				Next
					
				cCampos 	:= U_WW01GCPO(4, "INT_S_AJUSTE_ESTOQUE", "2")
				
				cQuery1 := "SELECT "+CHR(13)+CHR(10)
				cQuery1 += "'"+xFilial("ZWJ")+"' AS ZWJ_FILIAL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+cProcess+"' AS ZWJ_PROCES, "+CHR(13)+CHR(10)			
				cQuery1 += "'0001' AS ZWJ_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "'15' AS ZWJ_SITUAC, "+CHR(13)+CHR(10)
				cQuery1 += "'TRF' AS ZWJ_CALIAS, "+CHR(13)+CHR(10)
				cQuery1 += "'04' AS ZWJ_STATUS, "+CHR(13)+CHR(10)		
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWJ_DTINCL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWJ_HRINCL, "+CHR(13)+CHR(10)
				cQuery1 += cCampos+" "+CHR(13)+CHR(10)				
				cQuery1 += "FROM ["+cWISBd+"]..["+cWISAlias+"].[INT_S_AJUSTE_ESTOQUE] "+CHR(13)+CHR(10)
				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "ID_PROCESSADO = 'N' "+CHR(13)+CHR(10)
				cQuery1 += "AND DT_PROCESSADO IS NULL "+CHR(13)+CHR(10)
				cQuery1 += "AND TP_MOVIMENTO = 'T' "+CHR(13)+CHR(10)
				cQuery1 += "AND CD_EMPRESA = '"+cEmpWis+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND CD_DEPOSITO = '"+cFilWis+"' "+CHR(13)+CHR(10)						
				cQuery1 += "AND NU_INTERFACE = '"+cValtoChar((cAliasQry)->ZWI_INTERF)+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND NOT EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_CALIAS = 'TRF' AND ZWJ_EMPRES = '"+cEmpWis+"' AND ZWJ_DEPOSI = '"+cFilWis+"' AND ZWJ_INTERF = '"+cValtoChar((cAliasQry)->ZWI_INTERF)+"') "+CHR(13)+CHR(10)
									
				cQuery1 := ChangeQuery(cQuery1)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
					
				While !(cItemQry)->(Eof())
	
					aStruTmp 	:= (cItemQry)->(dBStruct())
					aStruZWJ 	:= ZWJ->(dBStruct())
					aLinha		:= {}
							
					For nX:= 1 to Len(aStruTmp)
							
						nPosZWJ := ASCAN(aStruZWJ, {|x| x[1] == aStruTmp[nX][1]})
							
						If nPosZWJ > 0
							
							If aStruZWJ[nPosZWJ][2] <> aStruTmp[nX][2]
								If aStruZWJ[nPosZWJ][2] == "D"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2])
								ElseIf aStruZWJ[nPosZWJ][2] == "N"
									TCSetField(cItemQry, aStruZWJ[nPosZWJ][1], aStruZWJ[nPosZWJ][2], aStruZWJ[nPosZWJ][3], aStruZWJ[nPosZWJ][4])
								EndIf
							EndIf
												
							If nX == Len(aStruTmp) //Ultimo item
								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"						
									//Ajuste do retorno do campo CD_CARGA que no WIS é numérico
									If aStruTmp[nX][1] == "ZWJ_CARGA"
										AADD(aLinha, {aStruTmp[nX][1], PADL(cValtoChar((cItemQry)->&(aStruTmp[nX][1])), TAMSX3("DAK_COD")[1], "0"), Nil})								
									Else 
										AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
									EndIf
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf													
							Else
								If aStruZWJ[nPosZWJ][2] == "C" .AND. ValType((cItemQry)->&(aStruTmp[nX][1])) == "N"						
									//Ajuste do retorno do campo CD_CARGA que no WIS é numérico
									If aStruTmp[nX][1] == "ZWJ_CARGA"
										AADD(aLinha, {aStruTmp[nX][1], PADL(cValtoChar((cItemQry)->&(aStruTmp[nX][1])), TAMSX3("DAK_COD")[1], "0"), Nil})								
									Else 
										AADD(aLinha, {aStruTmp[nX][1], cValtoChar((cItemQry)->&(aStruTmp[nX][1])), Nil})
									EndIf
								Else
									AADD(aLinha, {aStruTmp[nX][1], (cItemQry)->&(aStruTmp[nX][1]), Nil})
								EndIf								
							EndIf
						EndIf					
					Next
					
					AADD(aItens, aLinha)
														
					(cItemQry)->(DbSkip())
				EndDo
				
				If Select(cItemQry) > 0
					(cItemQry)->(DbCloseArea())
				EndIf
				
				If Len(aCabec) > 0 .AND. Len(aItens) > 0
					U_WIIWENT("ZWI", nOpcA, aCabec, aItens)
				EndIf
				
			(cAliasQry)->(DbSkip())
				
			EndDo
		EndIf
				 
	EndIf	
EndIf

If Select(cItemQry) > 0
	(cItemQry)->(DbCloseArea())
EndIf

If Select(cAliasQry) > 0
	(cAliasQry)->(DbCloseArea())
EndIf
		
RestArea(aArea)		
		
Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWTSAI

Rotina para teste da Interface de IntegraCAo de Saída PROTHEUS -> WIS.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return NIL
/*/
//-------------------------------------------------------------------------------------------------
User Function WIIWTSAI(nOpcA, nIntegr, cProcess, cTpDoc, aCabec, aItens)

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
Local cErro		:= ""
Local cDescErro	:= ""
Local cSolucao	:= ""
Local cEmp			:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) //PADR(IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')), TAMSX3("ZWK_EMPRES")[1], " ")
Local cIntWis		:= IIf(FWCodEmp() == '01', '1', IIF(FWCodEmp() == '02', '2', '0'))
Local aRecnoSD3	:= {}
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cLogWis		:= ""

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
	If nIntegr == 1 //NOTA ENTRADA - OK
				
		If Len(aCabec) == 0
			cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
			cQuery += "'"+ xFilial("ZWK") + "' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
			cQuery += "REPLACE(STR(F1_FILIAL, 3), SPACE(1), '0') AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
			cQuery += "'SF1' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
			cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10) 
			cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
			cQuery += "F1_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "F1_DOC, "+CHR(13)+CHR(10)
			cQuery += "F1_SERIE, "+CHR(13)+CHR(10)
			cQuery += "F1_FORNECE, "+CHR(13)+CHR(10)
			cQuery += "F1_LOJA, "+CHR(13)+CHR(10)
			cQuery += "F1_TIPO, "+CHR(13)+CHR(10)
			cQuery += "F1_CHVNFE, "+CHR(13)+CHR(10)		
			cQuery += "F1_DOC AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
			cQuery += "F1_SERIE AS 'ZWK_SERIE', "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SOLCON, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ENDENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_NENDEN, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_COMENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_BAIENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_MUNENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_UFENTR, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CEPENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_TELENT, "+CHR(13)+CHR(10) 
			cQuery += "'01' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
			cQuery += "'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CODTRA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_TRANSP, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CNPJTR, "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN F1_TIPO IN ('B', 'D') THEN ('C'+F1_FORNECE+F1_LOJA) ELSE (F1_FORNECE+F1_LOJA) END) AS ZWK_CLIFOR, "+CHR(13)+CHR(10)
			cQuery += "F1_EMISSAO AS ZWK_DTEMIS, "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN F1_TIPO IN ('B', 'D') THEN A1_CGC ELSE A2_CGC END) AS ZWK_CNPJCF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PLACA, "+CHR(13)+CHR(10)	
			cQuery += "'1' AS ZWK_SITUAC, "+CHR(13)+CHR(10)
			cQuery += "'"+cTpDoc+"' AS ZWK_TIPONF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CDRAV, "+CHR(13)+CHR(10)
			cQuery += "'00000' AS ZWK_PORTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PEDORI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_NOMCEN, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_NOMCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_TIPOPV, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DESTPV, "+CHR(13)+CHR(10)
			cQuery += "F1_VALBRUT AS ZWK_VLNOTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SEQENT, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DCANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PONCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_OBJPOS, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CARGA, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
			cQuery += "CAST(SF1.R_E_C_N_O_ AS VARCHAR(20)) AS ZWK_SEQINT, "+CHR(13)+CHR(10)
			cQuery += "ZWO_DESCRI AS ZWK_OBSERV, "+CHR(13)+CHR(10) 			
			cQuery += "SF1.R_E_C_N_O_ AS ZWK_RECORI "+CHR(13)+CHR(10)	                    	
			cQuery += "FROM " +RetSqlName("SF1")+ " SF1 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SD1")+ " SD1  (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO AND SD1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1  (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("ZWO")+ " ZWO (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWO_FILIAL = '"+xFilial("ZWO")+"' AND ZWO_CODIGO = F1_XWMSPRC AND ZWO.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
			cQuery += "LEFT JOIN "+RetSqlName("SA2")+ " SA2  (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (A2_FILIAL = '"+xFilial("SA2")+"' AND F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' AND F1_TIPO NOT IN ('D','B')) "+CHR(13)+CHR(10)	
			cQuery += "LEFT JOIN "+RetSqlName("SA1")+ " SA1 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+"' AND F1_FORNECE = A1_COD AND F1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND F1_TIPO IN ('D','B')) "+CHR(13)+CHR(10)	
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "SF1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND F1_FILIAL = '"+xFilial("SF1")+"' "+CHR(13)+CHR(10)
			//cQuery += "AND F1_DTDIGIT >= '20180401' "+CHR(13)+CHR(10)
			cQuery += "AND F1_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			
			If SF1->(FieldPos("F1_XWMSINT")) > 0				
				//CM Solutions - Allan Constantino Bonfim - 20/11/2019 - Chamado 24754 - Itens da nota fiscal integrado parcialmente no WIS.
				cQuery += "AND F1_XWMSINT = 'N' "+CHR(13)+CHR(10)
				//cQuery += "AND F1_XWMSINT <> 'S' "+CHR(13)+CHR(10)
			EndIf
						
			cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SF1' AND ZWK_RECORI =  SF1.R_E_C_N_O_) "+CHR(13)+CHR(10)
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
			While !(cAliasQry)->(Eof())
				
				//aCabec			
				aStruCab 	:= (cAliasQry)->(dBStruct())
				aStruZWK 	:= ZWK->(dBStruct())
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
				cQuery1 += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
				cQuery1 += "REPLACE(STR(D1_FILIAL, 3), SPACE(1), '0') AS ZWL_DEPOSI, "+CHR(13)+CHR(10)	
				cQuery1 += "'SD1' AS ZWL_CALIAS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+cProcess+"' AS ZWL_PROCES, "+CHR(13)+CHR(10) 			
				cQuery1 += "D1_ITEM AS ZWL_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "D1_COD AS ZWL_PRODUT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CARGA, "+CHR(13)+CHR(10)
				
				If ZWO->ZWO_ENVLOT == "S"
					cQuery1 += "D1_LOTECTL AS ZWL_LOTE, "+CHR(13)+CHR(10)
				EndIf
				
				//cQuery1 += "D1_LOTEFOR AS ZWL_LOTEFO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_EMBPRE, "+CHR(13)+CHR(10)
				//cQuery1 += "'0' AS ZWL_QTSEPA, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CNPJCL, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CODCLI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CAMPAN, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDORI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDIDO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTPED, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTNFE, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->F1_CHVNFE)+"' AS ZWL_CHVNFE, "+CHR(13)+CHR(10)				
				//cQuery1 += "' ' AS ZWL_FILL1, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL2, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL3, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL4, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL5, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->ZWK_CLIFOR)+"' AS ZWL_CLIFOR, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->ZWK_CNPJCF)+"' AS ZWL_CNPJCF, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_SEQINT+"' AS ZWL_SEQINT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_AGENDA, "+CHR(13)+CHR(10)			
				cQuery1 += "D1_DOC AS ZWL_NOTA, "+CHR(13)+CHR(10)
				cQuery1 += "D1_SERIE AS ZWL_SERIE, "+CHR(13)+CHR(10)
				cQuery1 += "'1' AS ZWL_SITUAC, "+CHR(13)+CHR(10)
				cQuery1 += "D1_QUANT AS ZWL_QTDE, "+CHR(13)+CHR(10)
				cQuery1 += "D1_LOCAL AS ZWL_DEPERP, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTFABR, "+CHR(13)+CHR(10)
				cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTERF, "+CHR(13)+CHR(10)
				cQuery1 += "'01' AS ZWL_STATUS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10)	
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10)			 				
				cQuery1 += "SD1.R_E_C_N_O_ AS ZWL_RECORI "+CHR(13)+CHR(10)
				cQuery1 += "FROM " +RetSqlName("SD1")+ " SD1  (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "INNER JOIN " +RetSqlName("SB1")+ " SB1  (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				//cQuery1 += "INNER JOIN " +RetSqlName("SA2")+ " SA2 (NOLOCK) "+CHR(13)+CHR(10)
				//cQuery1 += "ON (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)	
				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "SD1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQuery1 += "AND D1_FILIAL = '"+xFilial("SD1")+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D1_FILIAL = '"+(cAliasQry)->F1_FILIAL+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D1_DOC = '"+(cAliasQry)->F1_DOC+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D1_SERIE = '"+(cAliasQry)->F1_SERIE+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D1_FORNECE = '"+(cAliasQry)->F1_FORNECE+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D1_LOJA = '"+(cAliasQry)->F1_LOJA+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D1_TIPO = '"+(cAliasQry)->F1_TIPO+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)	
				//cQuery1 += "AND D1_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)						
				cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS = 'SD1' AND ZWL_RECORI =  SD1.R_E_C_N_O_) "+CHR(13)+CHR(10)
					
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
						If SF1->(FieldPos("F1_XWMSINT")) > 0
							DbSelectArea("SF1")
							DbGoto((cAliasQry)->ZWK_RECORI)
							Reclock("SF1", .F.)
								SF1->F1_XWMSINT := "S"
							SF1->(MsUnlock())
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
	
	ElseIf nIntegr == 2 //PEDIDOS DE VENDAS

		cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
		cQuery += "'"+ xFilial("ZWK") + "' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
		cQuery += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
		cQuery += "REPLACE(STR(C5_FILIAL, 3), SPACE(1), '0') AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
		cQuery += "'SC5' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
		cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
		cQuery += "C5_FILIAL, "+CHR(13)+CHR(10)
		cQuery += "C5_NUM, "+CHR(13)+CHR(10)
		//cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10) 		
		cQuery += "C5_EMISSAO AS ZWK_DATAEN, "+CHR(13)+CHR(10)
		cQuery += "(CASE WHEN F2_CHVNFE <> ' ' THEN F2_DOC ELSE ' ' END) AS ZWK_NOTA, "+CHR(13)+CHR(10)
		cQuery += "(CASE WHEN F2_CHVNFE <> ' ' THEN F2_SERIE ELSE ' ' END) AS ZWK_SERIE, "+CHR(13)+CHR(10)				
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
		cQuery += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD AND DAI_PEDIDO = C5_NUM AND DAI_CLIENT = C5_CLIENTE AND DAI_LOJA = C5_LOJACLI AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 		 
		cQuery += "LEFT JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (F2_FILIAL = DAI_FILIAL AND F2_DOC = DAI_NFISCA AND F2_SERIE = DAI_SERIE AND F2_CLIENTE = DAI_CLIENT AND F2_LOJA = DAI_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
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
		cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
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
			cQuery1 += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
			cQuery1 += "REPLACE(STR(C6_FILIAL, 3), SPACE(1), '0') AS ZWL_DEPOSI, "+CHR(13)+CHR(10)
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
			cQuery1 += "C6_DATFAT AS ZWL_DTNFE, "+CHR(13)+CHR(10)
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
			cQuery1 += "C6_NOTA AS ZWL_NOTA, "+CHR(13)+CHR(10)
			cQuery1 += "C6_SERIE AS ZWL_SERIE, "+CHR(13)+CHR(10)
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
			cQuery1 += "		SELECT C6_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C6_ITEM, C6_PRODUTO, C6_LOCAL, C6_NOTA, C6_SERIE, C6_DATFAT, SC6.R_E_C_N_O_ AS SC6RECNO, "+CHR(13)+CHR(10) 
			cQuery1 += "		C9_ZROMAN, DAK_COD, ISNULL(C6_QTDVEN, 0) AS C6_QTDVEN, ISNULL(SUM(C9_QTDLIB), 0) AS C9_QTDLIB "+CHR(13)+CHR(10)			
			cQuery1 += "		FROM " +RetSqlName("SC5")+ " SC5 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("SC6")+ " SC6 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("SC9")+ " SC9 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC9.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "		INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "		ON (DAK_FILIAL = C9_FILIAL AND DAK_COD = C9_ZROMAN AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) //AND ZRC_TPCARG = '281'
			//cQuery1 += "		INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
			//cQuery1 += "		ON (DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD AND DAI_PEDIDO = C5_NUM AND DAI_CLIENT = C5_CLIENTE AND DAI_LOJA = C5_LOJACLI AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 		 
			//cQuery1 += "		LEFT JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
			//cQuery1 += "		ON (F2_FILIAL = DAI_FILIAL AND F2_DOC = DAI_NFISCA AND F2_SERIE = DAI_SERIE AND F2_CLIENTE = DAI_CLIENT AND F2_LOJA = DAI_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)							 				
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
			cQuery1 += "		AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			//cQuery1 += "	AND C6_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery1 += "		AND (C9_BLEST = ' ' OR C9_BLEST = '10') "+CHR(13)+CHR(10)			
			cQuery1 += "		AND C6_NUM = '"+(cAliasQry)->C5_NUM+"' "+CHR(13)+CHR(10)			
			cQuery1 += "		AND C9_ZROMAN = '"+(cAliasQry)->ZWK_CARGA+"' "+CHR(13)+CHR(10)									
			cQuery1 += "		AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK  (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SC6' AND ZWK_RECORI =  SC6.R_E_C_N_O_) "+CHR(13)+CHR(10)
			cQuery1 += "		GROUP BY C6_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C6_ITEM, C6_PRODUTO, C6_LOCAL, C6_NOTA, C6_SERIE, C6_DATFAT, C6_QTDVEN, C9_ZROMAN, DAK_COD, SC6.R_E_C_N_O_ "+CHR(13)+CHR(10)
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
	
	ElseIf nIntegr == 3 //DESMONTAGEM - DE7 E ESTORNO DESMONTAGEM
		
		If Len(aCabec) == 0
			cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
			cQuery += "'"+xFilial("ZWK")+"' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
			cQuery += "REPLACE(STR(D3_FILIAL, 3), SPACE(1), '0') AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
			cQuery += "'SD3' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
			cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10) 
			cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
			cQuery += "D3_FILIAL, "+CHR(13)+CHR(10)
			//cQuery += "D3_DOC AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
			//cQuery += "D3_DOC, "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN D3_ESTORNO = 'S' THEN 'E_'+D3_NUMSEQ ELSE 'D_'+D3_NUMSEQ END) AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN D3_ESTORNO = 'S' THEN 'E' ELSE 'D' END) AS 'ZWK_SERIE', "+CHR(13)+CHR(10) //SEPARAR ESTORNO E MOVIMENTACAO NORMAL
			//cQuery += "' ' AS ZWK_SOLCON, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ENDENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_NENDEN, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_COMENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_BAIENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_MUNENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_UFENTR, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CEPENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_TELENT, "+CHR(13)+CHR(10) 
			cQuery += "'01' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
			cQuery += "'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10)
			cQuery += "'999999' AS ZWK_CODTRA, "+CHR(13)+CHR(10)
			cQuery += "'DESTINATARIO' AS ZWK_TRANSP, "+CHR(13)+CHR(10)
			cQuery += "'00000000000000' AS ZWK_CNPJTR, "+CHR(13)+CHR(10)
			cQuery += "'00527001' AS ZWK_CLIFOR, "+CHR(13)+CHR(10)
			cQuery += "D3_EMISSAO AS ZWK_DTEMIS, "+CHR(13)+CHR(10)
			cQuery += "'15579674000240' AS ZWK_CNPJCF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PLACA, "+CHR(13)+CHR(10)	
			cQuery += "'1' AS ZWK_SITUAC, "+CHR(13)+CHR(10)
			cQuery += "'"+cTpDoc+"' AS ZWK_TIPONF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CDRAV, "+CHR(13)+CHR(10)
			cQuery += "'00000' AS ZWK_PORTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PEDORI, "+CHR(13)+CHR(10)
			cQuery += "'FINI COMERCIALIZADORA LTDA' AS ZWK_NOMCEN, "+CHR(13)+CHR(10)
			cQuery += "'FINI COMERCIALIZADORA LTDA' AS ZWK_NOMCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_TIPOPV, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DESTPV, "+CHR(13)+CHR(10)
			cQuery += "0 AS ZWK_VLNOTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SEQENT, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DCANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PONCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_OBJPOS, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CARGA, "+CHR(13)+CHR(10)
			cQuery += "D3_NUMSEQ AS ZWK_SEQINT, "+CHR(13)+CHR(10) 	
			cQuery += "ZWO_DESCRI AS ZWK_OBSERV, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)			
			cQuery += "MIN(SD3.R_E_C_N_O_) AS ZWK_RECORI "+CHR(13)+CHR(10)	                    	
			cQuery += "FROM " +RetSqlName("SD3")+ " SD3 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1  (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("ZWO")+ " ZWO (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWO_FILIAL = '"+xFilial("ZWO")+"' AND ZWO_CODIGO = D3_XWMSPRC AND ZWO.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "SD3.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND D3_FILIAL = '"+xFilial("SD3")+"' "+CHR(13)+CHR(10)
			cQuery += "AND D3_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			cQuery += "AND D3_CF = 'DE7' "+CHR(13)+CHR(10)
						
			If cProcess == "039" //Estorno
				//cQuery += "AND D3_CF = 'DE6' "+CHR(13)+CHR(10)
				cQuery += "AND D3_ESTORNO = 'S' "+CHR(13)+CHR(10)
			Else
				cQuery += "AND D3_ESTORNO <> 'S' "+CHR(13)+CHR(10)	
			EndIf
			
			If SD3->(FieldPos("D3_XWMSINT")) > 0
				cQuery += "AND D3_XWMSINT <> 'S' "+CHR(13)+CHR(10)
			EndIf
						
			cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SD3' AND ZWK_RECORI = SD3.R_E_C_N_O_) "+CHR(13)+CHR(10)
			cQuery += "GROUP BY D3_FILIAL, D3_EMISSAO, D3_NUMSEQ, D3_ESTORNO, ZWO_DESCRI  "+CHR(13)+CHR(10)
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
			While !(cAliasQry)->(Eof())
				
				//aCabec			
				aStruCab 	:= (cAliasQry)->(dBStruct())
				aStruZWK 	:= ZWK->(dBStruct())
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
										
				cQuery1 := "SELECT REPLACE(STR(ROW_NUMBER() OVER(ORDER BY  SD3.R_E_C_N_O_),4),SPACE(1),'0') AS ZWL_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "'"+xFilial("ZWL")+"' AS ZWL_FILIAL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
				cQuery1 += "REPLACE(STR(D3_FILIAL, 3), SPACE(1), '0') AS ZWL_DEPOSI, "+CHR(13)+CHR(10)	
				cQuery1 += "'SD3' AS ZWL_CALIAS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+cProcess+"' AS ZWL_PROCES, "+CHR(13)+CHR(10) 			
				//cQuery1 += "D1_ITEM AS ZWL_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "D3_COD AS ZWL_PRODUT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CARGA, "+CHR(13)+CHR(10)
				//cQuery1 += "D1_LOTECTL AS ZWL_LOTE, "+CHR(13)+CHR(10)
				//cQuery1 += "D1_LOTEFOR AS ZWL_LOTEFO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_EMBPRE, "+CHR(13)+CHR(10)
				//cQuery1 += "'0' AS ZWL_QTSEPA, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CNPJCL, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CODCLI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CAMPAN, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDORI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDIDO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTPED, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTNFE, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CHVNFE, "+CHR(13)+CHR(10)				
				//cQuery1 += "' ' AS ZWL_FILL1, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL2, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL3, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL4, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL5, "+CHR(13)+CHR(10)
				cQuery1 += "'00527001' AS ZWL_CLIFOR, "+CHR(13)+CHR(10)
				cQuery1 += "'15579674000240' AS ZWL_CNPJCF, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_SEQINT+"' AS ZWL_SEQINT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_AGENDA, "+CHR(13)+CHR(10)			
				//cQuery1 += "D3_DOC AS ZWL_NOTA, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_NOTA+"' AS ZWL_NOTA, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_SERIE+"' AS ZWL_SERIE, "+CHR(13)+CHR(10)
				cQuery1 += "'1' AS ZWL_SITUAC, "+CHR(13)+CHR(10)
				cQuery1 += "D3_QUANT AS ZWL_QTDE, "+CHR(13)+CHR(10)
				cQuery1 += "D3_LOCAL AS ZWL_DEPERP, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTFABR, "+CHR(13)+CHR(10)
				cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTERF, "+CHR(13)+CHR(10)
				cQuery1 += "'01' AS ZWL_STATUS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10)	
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10)			 				
				cQuery1 += "SD3.R_E_C_N_O_ AS ZWL_RECORI "+CHR(13)+CHR(10)
				cQuery1 += "FROM " +RetSqlName("SD3")+ " SD3 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (D3_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "SD3.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQuery1 += "AND D3_FILIAL = '"+(cAliasQry)->D3_FILIAL+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D3_NUMSEQ = '"+(cAliasQry)->ZWK_SEQINT+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)	
				cQuery1 += "AND D3_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)			
				cQuery1 += "AND D3_CF = 'DE7' "+CHR(13)+CHR(10)
									
				If cProcess == "039" //Estorno
					//cQuery1 += "AND D3_CF = 'DE6' "+CHR(13)+CHR(10)
					cQuery1 += "AND D3_ESTORNO = 'S' "+CHR(13)+CHR(10)
				Else
					cQuery1 += "AND D3_ESTORNO <> 'S' "+CHR(13)+CHR(10)
				EndIf				
							
				If SD3->(FieldPos("D3_XWMSINT")) > 0
					cQuery1 += "AND D3_XWMSINT <> 'S' "+CHR(13)+CHR(10)
				EndIf
														
				cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS = 'SD3' AND ZWL_RECORI =  SD3.R_E_C_N_O_) "+CHR(13)+CHR(10)
					
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
			
					AADD(aItens, aLinha)
					AADD(aRecnoSD3, (cItemQry)->ZWL_RECORI)
					
					(cItemQry)->(DbSkip())
				EndDo
			
				If Len(aCabec) > 0 .AND. LEN(aItens) > 0 
					If U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)									
						If SD3->(FieldPos("D3_XWMSINT")) > 0
							For nX := 1 to Len(aRecnoSD3)
								DbSelectArea("SD3")
								DbGoto(aRecnoSD3[nX])
								Reclock("SD3", .F.)
									SD3->D3_XWMSINT := "S"
								SD3->(MsUnlock())
							Next
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
	
	ElseIf nIntegr == 4 //DESMONTAGEM - RE7 E ESTORNO DESMONTAGEM
		
		If Len(aCabec) == 0
			cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
			cQuery += "'"+xFilial("ZWK")+"' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
			cQuery += "REPLACE(STR(D3_FILIAL, 3), SPACE(1), '0') AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
			cQuery += "'SD3' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
			cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10)
			//cQuery += "D3_DOC, "+CHR(13)+CHR(10)  
			cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
			cQuery += "D3_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "D3_EMISSAO AS ZWK_DATAEN, "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN D3_ESTORNO = 'S' THEN 'E_'+D3_NUMSEQ ELSE 'D_'+D3_NUMSEQ END) AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN D3_ESTORNO = 'S' THEN 'E' ELSE 'D' END) AS 'ZWK_SERIE', "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SOLCON, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ENDENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_NENDEN, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_COMENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_BAIENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_MUNENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_UFENTR, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CEPENT, "+CHR(13)+CHR(10) 
			//cQuery += "' ' AS ZWK_TELENT, "+CHR(13)+CHR(10) 
			cQuery += "'01' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
			cQuery += "'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10)
			cQuery += "'999999' AS ZWK_CODTRA, "+CHR(13)+CHR(10)
			cQuery += "'DESTINATARIO' AS ZWK_TRANSP, "+CHR(13)+CHR(10)
			cQuery += "'00000000000000' AS ZWK_CNPJTR, "+CHR(13)+CHR(10)
			cQuery += "'F00527001' AS ZWK_CLIFOR, "+CHR(13)+CHR(10)
			cQuery += "D3_EMISSAO AS ZWK_DTEMIS, "+CHR(13)+CHR(10)
			cQuery += "'15579674000240' AS ZWK_CNPJCF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PLACA, "+CHR(13)+CHR(10)	
			cQuery += "'1' AS ZWK_SITUAC, "+CHR(13)+CHR(10)
			//cQuery += "'"+cTpDoc+"' AS ZWK_TIPONF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CDRAV, "+CHR(13)+CHR(10)
			cQuery += "'00000' AS ZWK_PORTA, "+CHR(13)+CHR(10)
			cQuery += "(CASE WHEN D3_ESTORNO = 'S' THEN 'E_'+D3_NUMSEQ ELSE 'D_'+D3_NUMSEQ END) AS ZWK_PEDORI, "+CHR(13)+CHR(10)
			cQuery += "'FINI COMERCIALIZADORA LTDA' AS ZWK_NOMCEN, "+CHR(13)+CHR(10)
			cQuery += "'FINI COMERCIALIZADORA LTDA' AS ZWK_NOMCLI, "+CHR(13)+CHR(10)
			cQuery += "'"+cTpDoc+"' AS ZWK_TIPOPV, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DESTPV, "+CHR(13)+CHR(10)
			cQuery += "0 AS ZWK_VLNOTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SEQENT, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DCANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PONCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_OBJPOS, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CARGA, "+CHR(13)+CHR(10)
			cQuery += "D3_NUMSEQ AS ZWK_SEQINT, "+CHR(13)+CHR(10) 
			//cQuery += "CAST(MIN(SD3.R_E_C_N_O_) AS VARCHAR(20)) AS ZWK_SEQINT, "+CHR(13)+CHR(10) 	
			cQuery += "ZWO_DESCRI AS ZWK_OBSERV, "+CHR(13)+CHR(10) 
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
			cQuery += "MIN(SD3.R_E_C_N_O_) AS ZWK_RECORI "+CHR(13)+CHR(10)	                    	
			cQuery += "FROM " +RetSqlName("SD3")+ " SD3 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1  (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
			cQuery += "INNER JOIN " +RetSqlName("ZWO")+ " ZWO (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWO_FILIAL = '"+xFilial("ZWO")+"' AND ZWO_CODIGO = D3_XWMSPRC AND ZWO.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "SD3.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND D3_FILIAL = '"+xFilial("SD3")+"' "+CHR(13)+CHR(10)
			cQuery += "AND D3_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			cQuery += "AND D3_CF = 'RE7' "+CHR(13)+CHR(10)
			
			If cProcess == "039" //Estorno
				//cQuery += "AND D3_CF = 'RE6' "+CHR(13)+CHR(10)
				cQuery += "AND D3_ESTORNO = 'S' "+CHR(13)+CHR(10)
			Else
				cQuery += "AND D3_ESTORNO <> 'S' "+CHR(13)+CHR(10)
			EndIf						
							
			If SD3->(FieldPos("D3_XWMSINT")) > 0
				cQuery += "AND D3_XWMSINT <> 'S' "+CHR(13)+CHR(10)
			EndIf

			cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SD3' AND ZWK_RECORI = SD3.R_E_C_N_O_) "+CHR(13)+CHR(10)
			cQuery += "GROUP BY D3_FILIAL, D3_EMISSAO, D3_NUMSEQ, D3_ESTORNO, ZWO_DESCRI "+CHR(13)+CHR(10)
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
			While !(cAliasQry)->(Eof())
				
				//aCabec			
				aStruCab 	:= (cAliasQry)->(dBStruct())
				aStruZWK 	:= ZWK->(dBStruct())
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
										
				cQuery1 := "SELECT REPLACE(STR(ROW_NUMBER() OVER(ORDER BY  SD3.R_E_C_N_O_),4),SPACE(1),'0') AS ZWL_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "'"+xFilial("ZWL")+"' AS ZWL_FILIAL, "+CHR(13)+CHR(10)
				cQuery1 += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
				cQuery1 += "REPLACE(STR(D3_FILIAL, 3), SPACE(1), '0') AS ZWL_DEPOSI, "+CHR(13)+CHR(10)	
				cQuery1 += "'SD3' AS ZWL_CALIAS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+cProcess+"' AS ZWL_PROCES, "+CHR(13)+CHR(10) 			
				cQuery1 += "D3_COD AS ZWL_PRODUT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CARGA, "+CHR(13)+CHR(10)
				//cQuery1 += "D1_LOTECTL AS ZWL_LOTE, "+CHR(13)+CHR(10)
				//cQuery1 += "D1_LOTEFOR AS ZWL_LOTEFO, "+CHR(13)+CHR(10)
				//cQuery1 += "'N' AS ZWL_EMBPRE, "+CHR(13)+CHR(10)
				cQuery1 += "D3_QUANT AS ZWL_QTSEPA, "+CHR(13)+CHR(10)
				cQuery1 += "'15579674000240' AS ZWL_CNPJCL, "+CHR(13)+CHR(10)
				cQuery1 += "'F00527001' AS ZWL_CODCLI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CAMPAN, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_PEDORI+"' AS ZWL_PEDORI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDIDO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTPED, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTNFE, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CHVNFE, "+CHR(13)+CHR(10)				
				//cQuery1 += "' ' AS ZWL_FILL1, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL2, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL3, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL4, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL5, "+CHR(13)+CHR(10)
				cQuery1 += "'00527001' AS ZWL_CLIFOR, "+CHR(13)+CHR(10)
				cQuery1 += "'15579674000240' AS ZWL_CNPJCF, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_SEQINT+"' AS ZWL_SEQINT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_AGENDA, "+CHR(13)+CHR(10)			
				cQuery1 += "'"+(cAliasQry)->ZWK_NOTA+"' AS ZWL_NOTA, "+CHR(13)+CHR(10)				
				cQuery1 += "'"+(cAliasQry)->ZWK_SERIE+"' AS ZWL_SERIE, "+CHR(13)+CHR(10)
				cQuery1 += "'1' AS ZWL_SITUAC, "+CHR(13)+CHR(10)
				cQuery1 += "D3_QUANT AS ZWL_QTDE, "+CHR(13)+CHR(10)
				cQuery1 += "D3_LOCAL AS ZWL_DEPERP, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTFABR, "+CHR(13)+CHR(10)
				cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTERF, "+CHR(13)+CHR(10)
				cQuery1 += "'01' AS ZWL_STATUS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10)	
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10)			 				
				cQuery1 += "SD3.R_E_C_N_O_ AS ZWL_RECORI "+CHR(13)+CHR(10)
				cQuery1 += "FROM " +RetSqlName("SD3")+ " SD3 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (D3_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "SD3.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQuery1 += "AND D3_FILIAL = '"+(cAliasQry)->D3_FILIAL+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D3_NUMSEQ = '"+(cAliasQry)->ZWK_SEQINT+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)	
				cQuery1 += "AND D3_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)			
				cQuery1 += "AND D3_CF = 'RE7' "+CHR(13)+CHR(10)							

				//cQuery1 += "AND D3_CF = 'RE7' "+CHR(13)+CHR(10)				
				If cProcess == "039" //Estorno
					//cQuery1 += "AND D3_CF = 'RE6' "+CHR(13)+CHR(10)
					cQuery1 += "AND D3_ESTORNO = 'S' "+CHR(13)+CHR(10)
				Else
					cQuery1 += "AND D3_ESTORNO <> 'S' "+CHR(13)+CHR(10)
				EndIf
				
				If SD3->(FieldPos("D3_XWMSINT")) > 0
					cQuery1 += "AND D3_XWMSINT <> 'S' "+CHR(13)+CHR(10)
				EndIf

				cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS = 'SD3' AND ZWL_RECORI =  SD3.R_E_C_N_O_) "+CHR(13)+CHR(10)
					
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
			
					AADD(aItens, aLinha)
					AADD(aRecnoSD3, (cItemQry)->ZWL_RECORI)
					
					(cItemQry)->(DbSkip())
				EndDo
			
				If Len(aCabec) > 0 .AND. LEN(aItens) > 0 
					If U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)				
						If SD3->(FieldPos("D3_XWMSINT")) > 0
							For nX := 1 to Len(aRecnoSD3)
								DbSelectArea("SD3")
								DbGoto(aRecnoSD3[nX])
								Reclock("SD3", .F.)
									SD3->D3_XWMSINT := "S"
								SD3->(MsUnlock())
							Next
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

	ElseIf nIntegr == 5 //NF DE SAIDA
		
		If Len(aCabec) == 0
			cQuery := "SELECT DISTINCT " +CHR(13)+CHR(10) 
			cQuery += "'"+xFilial("ZWK")+"' AS ZWK_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWK_EMPRES, "+CHR(13)+CHR(10) 
			cQuery += "REPLACE(STR(F2_FILIAL, 3), SPACE(1), '0') AS ZWK_DEPOSI, "+CHR(13)+CHR(10)	
			cQuery += "'SF2' AS ZWK_CALIAS, "+CHR(13)+CHR(10) 
			cQuery += "' ' AS ZWK_AGENDA, "+CHR(13)+CHR(10) 
			cQuery += "'"+cProcess+"' AS ZWK_PROCES, "+CHR(13)+CHR(10)
			cQuery += "F2_FILIAL, "+CHR(13)+CHR(10)
			cQuery += "F2_DOC, "+CHR(13)+CHR(10)
			cQuery += "F2_SERIE, "+CHR(13)+CHR(10)
			cQuery += "F2_CLIENTE, "+CHR(13)+CHR(10)
			cQuery += "F2_LOJA, "+CHR(13)+CHR(10)
			cQuery += "F2_TIPO, "+CHR(13)+CHR(10)				
			cQuery += "F2_CHVNFE, "+CHR(13)+CHR(10)
			cQuery += "F2_EMISSAO AS ZWK_DATAEN, "+CHR(13)+CHR(10)
			cQuery += "F2_DOC AS 'ZWK_NOTA', "+CHR(13)+CHR(10)
			cQuery += "F2_SERIE AS 'ZWK_SERIE', "+CHR(13)+CHR(10)
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
			cQuery += "F2_TRANSP AS ZWK_CODTRA, "+CHR(13)+CHR(10)
			cQuery += "A4_NOME AS ZWK_TRANSP, "+CHR(13)+CHR(10)
			cQuery += "A4_CGC AS ZWK_CNPJTR, "+CHR(13)+CHR(10)			
			cQuery += "(F2_CLIENTE+F2_LOJA) AS ZWK_CLIFOR, "+CHR(13)+CHR(10)
			cQuery += "F2_EMISSAO AS ZWK_DTEMIS, "+CHR(13)+CHR(10)
			cQuery += "COALESCE(A1_CGC, A2_CGC) AS ZWK_CNPJCF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PLACA, "+CHR(13)+CHR(10)	
			cQuery += "'1' AS ZWK_SITUAC, "+CHR(13)+CHR(10)
			//cQuery += "'"+cTpDoc+"' AS ZWK_TIPONF, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CDRAV, "+CHR(13)+CHR(10)
			cQuery += "'00000' AS ZWK_PORTA, "+CHR(13)+CHR(10)
			cQuery += "F2_DOC AS ZWK_PEDORI, "+CHR(13)+CHR(10)
			cQuery += "COALESCE(A1_NOME, A2_NOME) AS ZWK_NOMCEN, "+CHR(13)+CHR(10)
			cQuery += "COALESCE(A1_NOME, A2_NOME) AS ZWK_NOMCLI, "+CHR(13)+CHR(10)
			cQuery += "'"+cTpDoc+"' AS ZWK_TIPOPV, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DESTPV, "+CHR(13)+CHR(10)
			cQuery += "F2_VALBRUT AS ZWK_VLNOTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_SEQENT, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_CANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DCANAL, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_ROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_DROTA, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_PONCLI, "+CHR(13)+CHR(10)
			//cQuery += "' ' AS ZWK_OBJPOS, "+CHR(13)+CHR(10)
			//cQuery += "F2_CARGA AS ZWK_CARGA, "+CHR(13)+CHR(10)
			cQuery += "DAK_COD AS ZWK_CARGA, "+CHR(13)+CHR(10)
			cQuery += "(SELECT COUNT(DISTINCT DAI_PEDIDO) AS QTDCAR FROM " +RetSqlName("DAI")+ " DAI (NOLOCK) WHERE DAI.D_E_L_E_T_ = ' ' AND DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD) AS ZWK_QTDCAR, "+CHR(13)+CHR(10)
			cQuery += "ZWO_DESCRI AS ZWK_OBSERV, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10)
			cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
			cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
			cQuery += "CAST(SF2.R_E_C_N_O_ AS VARCHAR(20)) AS ZWK_SEQINT, "+CHR(13)+CHR(10) 	
			cQuery += "DAK.R_E_C_N_O_ AS DAKREC, "+CHR(13)+CHR(10)
			cQuery += "SF2.R_E_C_N_O_ AS ZWK_RECORI "+CHR(13)+CHR(10)	                    		                    	
			cQuery += "FROM " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SD2")+ " SD2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_TIPO = D2_TIPO AND SD2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (DAK_FILIAL = F2_FILIAL AND DAK_COD = F2_ZZROMAN AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			//cQuery += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
			//cQuery += "ON (DAI_FILIAL = DAK_FILIAL AND DAI_COD = DAK_COD AND DAI_NFISCA = F2_DOC AND DAI_SERIE = F2_SERIE AND DAI_CLIENT = F2_CLIENTE AND DAI_LOJA = F2_LOJA AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery += "INNER JOIN " +RetSqlName("ZWO")+ " ZWO (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (ZWO_FILIAL = '"+xFilial("ZWO")+"' AND F2_XWMSPRC = ZWO_CODIGO AND ZWO.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)						
			cQuery += "LEFT JOIN "+RetSqlName("SA2")+ " SA2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (A2_FILIAL = '"+xFilial("SA2")+"' AND F2_CLIENTE = A2_COD AND F2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' AND F2_TIPO IN ('D','B')) "+CHR(13)+CHR(10)	
			cQuery += "LEFT JOIN "+RetSqlName("SA1")+ " SA1 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+"' AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND F2_TIPO NOT IN ('D','B')) "+CHR(13)+CHR(10)
			cQuery += "LEFT JOIN " +RetSqlName("SA4")+ " SA4 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery += "ON (A4_FILIAL = '"+xFilial("SA4")+ "' AND F2_TRANSP = A4_COD AND SA4.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)								
			cQuery += "WHERE "+CHR(13)+CHR(10)
			cQuery += "SF2.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery += "AND F2_FILIAL = '"+xFilial("SF2")+"' "+CHR(13)+CHR(10)
			cQuery += "AND F2_XWMSPRC = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
			cQuery += "AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
			cQuery += "AND F2_ZZROMAN <> ' ' "+CHR(13)+CHR(10)													
							
			If SF2->(FieldPos("F2_XWMSINT")) > 0
				cQuery += "AND F2_XWMSINT <> 'S' "+CHR(13)+CHR(10)
			EndIf

			If DAK->(FieldPos("DAK_XWMSIN")) > 0
				cQuery += "AND DAK_XWMSIN <> 'S' "+CHR(13)+CHR(10)
			EndIf
			
			If DAK->(FieldPos("DAK_XWMSOK")) > 0
				cQuery += "AND DAK_XWMSOK = 'S' "+CHR(13)+CHR(10)
			EndIf

			cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWK  (NOLOCK) WHERE ZWK.D_E_L_E_T_ = ' ' AND ZWK_CALIAS = 'SF2' AND ZWK_RECORI =  SF2.R_E_C_N_O_) "+CHR(13)+CHR(10)
		
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
			While !(cAliasQry)->(Eof())
				
				//aCabec			
				aStruCab 	:= (cAliasQry)->(dBStruct())
				aStruZWK 	:= ZWK->(dBStruct())
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
				cQuery1 += "'"+ IIf(cEmpAnt=='01',"2","1")+"' AS ZWL_EMPRES, "+CHR(13)+CHR(10) 
				cQuery1 += "REPLACE(STR(D2_FILIAL, 3), SPACE(1), '0') AS ZWL_DEPOSI, "+CHR(13)+CHR(10)	
				cQuery1 += "'SD2' AS ZWL_CALIAS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+cProcess+"' AS ZWL_PROCES, "+CHR(13)+CHR(10) 			
				cQuery1 += "D2_ITEM AS ZWL_ITEM, "+CHR(13)+CHR(10)
				cQuery1 += "D2_COD AS ZWL_PRODUT, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_CARGA+"' AS ZWL_CARGA, "+CHR(13)+CHR(10)
				//cQuery1 += "D2_LOTECTL AS ZWL_LOTE, "+CHR(13)+CHR(10)
				//cQuery1 += "D2_LOTEFOR AS ZWL_LOTEFO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_EMBPRE, "+CHR(13)+CHR(10)
				cQuery1 += "D2_QUANT AS ZWL_QTSEPA, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->ZWK_CNPJCF)+"' AS ZWL_CNPJCL, "+CHR(13)+CHR(10)
				cQuery1 += "(D2_CLIENTE+D2_LOJA) AS ZWL_CODCLI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_CAMPAN, "+CHR(13)+CHR(10)
				cQuery1 += "D2_DOC AS ZWL_PEDORI, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_PEDIDO, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTPED, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTNFE, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->F2_CHVNFE)+"' AS ZWL_CHVNFE, "+CHR(13)+CHR(10)				
				//cQuery1 += "' ' AS ZWL_FILL1, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL2, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL3, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL4, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_FILL5, "+CHR(13)+CHR(10)
				cQuery1 += "(D2_CLIENTE+D2_LOJA) AS ZWL_CLIFOR, "+CHR(13)+CHR(10)
				cQuery1 += "'"+Alltrim((cAliasQry)->ZWK_CNPJCF)+"' AS ZWL_CNPJCF, "+CHR(13)+CHR(10)
				cQuery1 += "'"+(cAliasQry)->ZWK_SEQINT+"' AS ZWL_SEQINT, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_AGENDA, "+CHR(13)+CHR(10)			
				cQuery1 += "D2_DOC AS ZWL_NOTA, "+CHR(13)+CHR(10)
				cQuery1 += "D2_SERIE AS ZWL_SERIE, "+CHR(13)+CHR(10)
				cQuery1 += "'1' AS ZWL_SITUAC, "+CHR(13)+CHR(10)
				cQuery1 += "D2_QUANT AS ZWL_QTDE, "+CHR(13)+CHR(10)
				cQuery1 += "D2_LOCAL AS ZWL_DEPERP, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTFABR, "+CHR(13)+CHR(10)
				cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_DTPROC, "+CHR(13)+CHR(10)
				//cQuery1 += "' ' AS ZWL_INTERF, "+CHR(13)+CHR(10)
				cQuery1 += "'01' AS ZWL_STATUS, "+CHR(13)+CHR(10)
				cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10)	
				cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10)			 				
				cQuery1 += "SD2.R_E_C_N_O_ AS ZWL_RECORI "+CHR(13)+CHR(10)
				cQuery1 += "FROM " +RetSqlName("SD2")+ " SD2 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "INNER JOIN " +RetSqlName("SB1")+ " SB1 (NOLOCK) "+CHR(13)+CHR(10)
				cQuery1 += "ON (D2_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQuery1 += "WHERE "+CHR(13)+CHR(10)
				cQuery1 += "SD2.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
				cQuery1 += "AND D2_FILIAL = '"+(cAliasQry)->F2_FILIAL+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D2_DOC = '"+(cAliasQry)->F2_DOC+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND D2_SERIE = '"+(cAliasQry)->F2_SERIE+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D2_CLIENTE = '"+(cAliasQry)->F2_CLIENTE+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D2_LOJA = '"+(cAliasQry)->F2_LOJA+"' "+CHR(13)+CHR(10) 
				cQuery1 += "AND D2_TIPO = '"+(cAliasQry)->F2_TIPO+"' "+CHR(13)+CHR(10)
				cQuery1 += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)							
				cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWL  (NOLOCK) WHERE ZWL.D_E_L_E_T_ = ' ' AND ZWL_CALIAS = 'SD2' AND ZWL_RECORI =  SD2.R_E_C_N_O_) "+CHR(13)+CHR(10)
					
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
						If SF2->(FieldPos("F2_XWMSINT")) > 0
							DbSelectArea("SF2")
							DbGoto((cAliasQry)->ZWK_RECORI)
							Reclock("SF2", .F.)
								SF2->F2_XWMSINT := "S"
							SF2->(MsUnlock())
						EndIf
						
						If DAK->(FieldPos("DAK_XWMSIN")) > 0
							If WW01IPED((cAliasQry)->ZWK_EMPRES, (cAliasQry)->ZWK_CARGA, "SF2")
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
	
	ElseIf nIntegr == 6	//Romaneio - SituaCAo 3 - Pedidos de Vendas

		cQuery := "SELECT DISTINCT 'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10) 
		cQuery += "'07' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
		cQuery += "'3' AS ZWK_SITUAC,  "+CHR(13)+CHR(10)
		cQuery += "F2_DOC AS ZWK_NOTA, "+CHR(13)+CHR(10) 
		cQuery += "F2_SERIE AS ZWK_SERIE, " +CHR(13)+CHR(10)
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
		cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
		cQuery += "'"+DTOS(CTOD(''))+"' AS ZWK_DTINTE, "+CHR(13)+CHR(10)
		cQuery += "' ' AS ZWK_HRINTE, ZWK.* "+CHR(13)+CHR(10)
		cQuery += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWK_FILIAL = ZWI_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "INNER JOIN " +RetSqlName("SC5")+ " SC5 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (SC5.R_E_C_N_O_ = ZWK_RECORI AND SC5.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (DAI_FILIAL = C5_FILIAL AND DAI_COD = ZWK_CARGA AND DAI_PEDIDO = ZWK_PEDORI AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 
		cQuery += "INNER JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (F2_FILIAL = DAI_FILIAL AND F2_DOC = DAI_NFISCA AND F2_SERIE = DAI_SERIE AND F2_CLIENTE = DAI_CLIENT AND F2_LOJA = DAI_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "WHERE "+CHR(13)+CHR(10)
		cQuery += "ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_STATUS = '06' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_CALIAS = 'SC5' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_SITUAC <> '68' "+CHR(13)+CHR(10)
		cQuery += "AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)		
		cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWK.ZWK_FILIAL AND ZWKA.ZWK_EMPRES = ZWK.ZWK_EMPRES AND ZWKA.ZWK_CODIGO = ZWK.ZWK_CODIGO AND ZWKA.ZWK_PROCES = ZWK.ZWK_PROCES AND ZWKA.ZWK_CALIAS = ZWK.ZWK_CALIAS AND ZWKA.ZWK_RECORI = ZWK.ZWK_RECORI AND ZWKA.ZWK_SITUAC = '3') "+CHR(13)+CHR(10)		

		If DAK->(FieldPos("DAK_XWMSOK")) > 0
			cQuery += "AND DAK_XWMSOK = 'S' "+CHR(13)+CHR(10)
		EndIf
			
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
						AADD(aCabec, {aStruCab[nX][1], SUBSTR((cAliasQry)->&(aStruCab[nX][1]), 1, TAMSX3(aStruCab[nX][1])[1]), Nil})
					Else
						AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
					EndIf					
				EndIf
			Next

			cQuery1 := "SELECT DISTINCT ZWL_FILIAL, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_EMPRES, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_DEPOSI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CALIAS, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PROCES, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODIGO, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_ITEM, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PRODUT, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CARGA, "+CHR(13)+CHR(10) 
			cQuery1 += "'N' AS ZWL_EMBPRE, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_FILL5, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_QTSEPA, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CNPJCL, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODCLI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PEDORI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CLIFOR, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CNPJCF, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_QTDE, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_DEPERP, "+CHR(13)+CHR(10) 
			cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10) 
			cQuery1 += "'07' AS ZWL_STATUS, "+CHR(13)+CHR(10)   
			cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10) 
			cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_DOC AS ZWL_NOTA, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_SERIE AS ZWL_SERIE, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_EMISSAO AS ZWL_DTNFE, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_CHVNFE AS ZWL_CHVNFE, "+CHR(13)+CHR(10) 
			cQuery1 += "'3' AS ZWL_SITUAC, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_RECORI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_SEQINT "+CHR(13)+CHR(10)        
			cQuery1 += "FROM ( "+CHR(13)+CHR(10) 											
			cQuery1 += "	SELECT DISTINCT ZWL_FILIAL, ZWL_EMPRES, ZWL_DEPOSI, ZWL_CALIAS, ZWL_PROCES, ZWL_CODIGO, ZWL_ITEM, ZWL_PRODUT, ZWL_CARGA, ISNULL(SUM(ZWJ_QTDEXP), 0) AS ZWL_QTDE, ZWL_CNPJCL, "+CHR(13)+CHR(10) 					
			cQuery1 += "	ZWL_CODCLI, ZWL_PEDORI, ZWL_CLIFOR, ZWL_CNPJCF, ZWL_DEPERP, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CHVNFE, ISNULL(SUM(ZWJ_QTDEXP), 0) AS ZWL_QTSEPA, ZWL_FILL5, ZWL_RECORI, ZWL_SEQINT "+CHR(13)+CHR(10)
			cQuery1 += "	FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (ZWL_FILIAL = ZWJ_FILIAL AND ZWL_EMPRES = ZWJ_EMPRES AND ZWL_CODIGO = ZWJ_CODIGO AND ZWL_ITEM = ZWJ_ITEM AND ZWL_PROCES = ZWJ_PROCES AND ZWL_CALIAS = ZWJ_CALIAS AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
			cQuery1 += "	INNER JOIN " +RetSqlName("SC6")+ " SC6 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (SC6.R_E_C_N_O_ = ZWL_RECORI AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "	INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (DAI_FILIAL = C6_FILIAL AND DAI_COD = ZWL_CARGA AND DAI_PEDIDO = ZWL_PEDORI AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "	INNER JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (F2_FILIAL = DAI_FILIAL AND F2_DOC = DAI_NFISCA AND F2_SERIE = DAI_SERIE AND F2_CLIENTE = DAI_CLIENT AND F2_LOJA = DAI_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
			cQuery1 += "	WHERE "+CHR(13)+CHR(10)
			cQuery1 += "	ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_STATUS = '06' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_PROCES =  '"+(cAliasQry)->ZWK_PROCES+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_CALIAS = 'SC6' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_FILIAL = '"+(cAliasQry)->ZWK_FILIAL+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_EMPRES = '"+(cAliasQry)->ZWK_EMPRES+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWJ_SITUAC <> '68' "+CHR(13)+CHR(10)
			cQuery1 += "	AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWLA (NOLOCK) WHERE ZWLA.D_E_L_E_T_ = ' ' AND ZWLA.ZWL_FILIAL = ZWL.ZWL_FILIAL AND ZWLA.ZWL_EMPRES = ZWL.ZWL_EMPRES AND ZWLA.ZWL_CODIGO = ZWL.ZWL_CODIGO AND ZWLA.ZWL_ITEM = ZWL.ZWL_ITEM AND ZWLA.ZWL_PROCES = ZWL.ZWL_PROCES AND ZWLA.ZWL_CALIAS = ZWL.ZWL_CALIAS AND ZWLA.ZWL_RECORI = ZWL.ZWL_RECORI AND ZWLA.ZWL_SITUAC = '3') "+CHR(13)+CHR(10)			
			cQuery1 += "	GROUP BY ZWL_FILIAL, ZWL_EMPRES, ZWL_DEPOSI, ZWL_CALIAS, ZWL_PROCES, ZWL_CODIGO, ZWL_ITEM, ZWL_PRODUT, ZWL_CARGA, ZWL_QTSEPA, ZWL_CNPJCL, "+CHR(13)+CHR(10)
			cQuery1 += "	ZWL_CODCLI, ZWL_PEDORI, ZWL_CLIFOR, ZWL_CNPJCF, ZWL_DEPERP, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CHVNFE, ZWL_FILL5, ZWL_RECORI, ZWL_SEQINT "+CHR(13)+CHR(10)					
			cQuery1 += ") TMPFATROM"+CHR(13)+CHR(10)
			
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
				U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
			EndIf
			
			If Select(cItemQry) > 0
				(cItemQry)->(dbCloseArea())
			EndIf
			
			aCabec := {}
			aItens := {}
			
			(cAliasQry)->(DbSkip())			
		EndDo

	ElseIf nIntegr == 7	//Interface de Pedido - SituaCAo 3 - Desmontagem
			
		cQuery := "SELECT DISTINCT "+CHR(13)+CHR(10)
		cQuery += "ZWK_FILIAL, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_EMPRES, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CODIGO, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_PROCES, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CALIAS, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_DEPOSI, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_AGENDA, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_FILL5, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_INTERF, " +CHR(13)+CHR(10) 
		cQuery += "ZWK_DATAEN, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_ENDENT, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_COMENT, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_BAIENT, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_MUNENT, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_UFENTR, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CEPENT, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_OBSERV, " +CHR(13)+CHR(10)
		cQuery += "ZWK_TELENT, "+CHR(13)+CHR(10) 
		cQuery += "'07' ZWK_STATUS, "+CHR(13)+CHR(10) 
		cQuery += "'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CODTRA, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_TRANSP, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CNPJTR, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_CLIFOR, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_DTEMIS, " +CHR(13)+CHR(10)
		cQuery += "ZWK_CNPJCF, "+CHR(13)+CHR(10) 
		cQuery += "'3' AS ZWK_SITUAC, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_PORTA, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_PEDORI, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_NOMCEN, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_NOMCLI, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_TIPOPV, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_VLNOTA, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_TIPONF, " +CHR(13)+CHR(10)
		cQuery += "ZWK_SEQINT, " +CHR(13)+CHR(10)                    
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTAGEN, "+CHR(13)+CHR(10) 
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10) 
		cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10) 
		cQuery += "ZWK_RECORI, " +CHR(13)+CHR(10)
		cQuery += "(CASE WHEN ZWK_CALIAS = 'SD3' THEN ZWK_PEDORI ELSE ZWK_NOTA END) AS ZWK_NOTA, "+CHR(13)+CHR(10)   
		cQuery += "(CASE WHEN ZWK_CALIAS = 'SD3' THEN '0' ELSE ZWK_SERIE END) AS ZWK_SERIE "+CHR(13)+CHR(10)  
		cQuery += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWK_FILIAL = ZWI_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "WHERE "+CHR(13)+CHR(10)
		cQuery += "ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_STATUS = '06' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_CALIAS = 'SD3' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_PEDORI <> ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_TIPOPV <> ' ' "+CHR(13)+CHR(10)
		cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWK.ZWK_FILIAL AND ZWKA.ZWK_EMPRES = ZWK.ZWK_EMPRES AND ZWKA.ZWK_CODIGO = ZWK.ZWK_CODIGO AND ZWKA.ZWK_PROCES = ZWK.ZWK_PROCES AND ZWKA.ZWK_CALIAS = ZWK.ZWK_CALIAS AND ZWKA.ZWK_RECORI = ZWK.ZWK_RECORI AND ZWKA.ZWK_SITUAC = '3') "+CHR(13)+CHR(10)		
					
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
						AADD(aCabec, {aStruCab[nX][1], SUBSTR((cAliasQry)->&(aStruCab[nX][1]), 1, TAMSX3(aStruCab[nX][1])[1]), Nil})
					Else
						AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
					EndIf					
				EndIf
			Next

			cQuery1 := "SELECT DISTINCT " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_FILIAL, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_EMPRES, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODIGO, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_DEPOSI, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CALIAS, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PROCES, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWJ_ITEM AS ZWL_ITEM, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWJ_CARGA AS ZWL_CARGA, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWJ_PRODUT AS ZWL_PRODUT, " +CHR(13)+CHR(10)
			cQuery1 += "ZWJ_QTSEPA AS ZWL_QTSEPA, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_SEQINT, " +CHR(13)+CHR(10)
			cQuery1 += "ZWL_CNPJCL, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODCLI, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PEDORI, " +CHR(13)+CHR(10)
			cQuery1 += "ZWL_CHVNFE, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CLIFOR, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CNPJCF, " +CHR(13)+CHR(10) 
			cQuery1 += "'3' AS ZWL_SITUAC, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWJ_QTDE AS ZWL_QTDE, " +CHR(13)+CHR(10)
			cQuery1 += "ZWJ_DEPERP AS ZWL_DEPERP, " +CHR(13)+CHR(10) 
			cQuery1 += "'07' ZWL_STATUS, " +CHR(13)+CHR(10) 
			cQuery1 += "'N' AS ZWL_IDPROC, " +CHR(13)+CHR(10) 
			cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, " +CHR(13)+CHR(10)
			cQuery1 += "ZWL_FILL5, " +CHR(13)+CHR(10) 
			cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_RECORI, " +CHR(13)+CHR(10) 
			cQuery1 += "ZWL_INTERF, " +CHR(13)+CHR(10)
			cQuery1 += "(CASE WHEN ZWJ_CALIAS = 'SD3' THEN ZWJ_PEDORI ELSE ZWL_NOTA END) AS ZWL_NOTA, "+CHR(13)+CHR(10)   
			cQuery1 += "(CASE WHEN ZWJ_CALIAS = 'SD3' THEN '0' ELSE ZWL_SERIE END) AS ZWL_SERIE "+CHR(13)+CHR(10)  
			cQuery1 += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "ON (ZWJ_FILIAL = ZWL_FILIAL AND ZWJ_EMPRES = ZWL_EMPRES AND ZWJ_CODIGO = ZWL_CODIGO AND ZWJ_ITEM = ZWL_ITEM AND ZWJ_PROCES = ZWL_PROCES AND ZWJ_CALIAS = ZWL_CALIAS AND ZWL.D_E_L_E_T_ = ' ')  "+CHR(13)+CHR(10)
			cQuery1 += "WHERE "+CHR(13)+CHR(10)
			cQuery1 += "ZWJ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_STATUS = '06' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_CALIAS = 'SD3' "+CHR(13)+CHR(10)			
			cQuery1 += "AND ZWJ_PEDORI <> ' ' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWLA (NOLOCK) WHERE ZWLA.D_E_L_E_T_ = ' ' AND ZWLA.ZWL_FILIAL = ZWL.ZWL_FILIAL AND ZWLA.ZWL_EMPRES = ZWL.ZWL_EMPRES AND ZWLA.ZWL_CODIGO = ZWL.ZWL_CODIGO AND ZWLA.ZWL_ITEM = ZWL.ZWL_ITEM AND ZWLA.ZWL_PROCES = ZWL.ZWL_PROCES AND ZWLA.ZWL_CALIAS = ZWL.ZWL_CALIAS AND ZWLA.ZWL_RECORI = ZWL.ZWL_RECORI AND ZWLA.ZWL_SITUAC = '3') "+CHR(13)+CHR(10)
				
			cQuery1 := ChangeQuery(cQuery1)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
			
			While !(cItemQry)->(Eof())

				aStruItem 	:= (cItemQry)->(dBStruct())
				aStruZWL 	:= ZWL->(dBStruct())
				aLinha		:= {}
						
				For nX:= 1 to Len(aStruItem)
						
					nPosZWL := ASCAN(aStruZWL, {|x| x[1] == aStruItem[nX][1]})
						
					If nPosZWL > 0
						/*
						If nX == 1 //.AND. ALLTRIM(aStruItem[nX][1]) == "ZWL_ITEM"
							AADD(aLinha, {"LINPOS",aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1])})
							AADD(aLinha, {"AUTDELETA", "N", NIL})
						Else															      
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
						EndIf*/
					EndIf					
				Next
				
				AADD(aItens, aLinha)
				
				(cItemQry)->(DbSkip())
			EndDo
			
			If Len(aCabec) > 0 .AND. Len(aItens) > 0
				U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)			
			EndIf
			
			If Select(cItemQry) > 0
				(cItemQry)->(dbCloseArea())
			EndIf
			
			aCabec := {}
			aItens := {}
			
			(cAliasQry)->(DbSkip())			
		EndDo

	ElseIf nIntegr == 8	//Romaneio - SituaCAo 3 - Notas Fiscais de Saida

		cQuery := "SELECT DISTINCT 'N' AS ZWK_IDPROC, "+CHR(13)+CHR(10) 
		cQuery += "'07' AS ZWK_STATUS, "+CHR(13)+CHR(10) 
		cQuery += "'3' AS ZWK_SITUAC,  "+CHR(13)+CHR(10)
		cQuery += "F2_DOC AS ZWK_NOTA, "+CHR(13)+CHR(10) 
		cQuery += "F2_SERIE AS ZWK_SERIE, " +CHR(13)+CHR(10)
		cQuery += "'"+DTOS(dDatabase)+"' AS ZWK_DTINCL, "+CHR(13)+CHR(10)
		cQuery += "'"+SUBSTR(TIME(),1,5)+"' AS ZWK_HRINCL, "+CHR(13)+CHR(10)
		cQuery += "'"+DTOS(CTOD(''))+"' AS ZWK_DTINTE, "+CHR(13)+CHR(10)
		cQuery += "' ' AS ZWK_HRINTE, ZWK.* "+CHR(13)+CHR(10)
		cQuery += "FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWK_FILIAL = ZWI_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "INNER JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (SF2.R_E_C_N_O_ = ZWK_RECORI AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (DAK_FILIAL = F2_FILIAL AND DAK_COD = F2_ZZROMAN AND DAK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 
		//cQuery += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "ON (DAI_FILIAL = C5_FILIAL AND DAI_COD = ZWK_CARGA AND DAI_PEDIDO = ZWK_PEDORI AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		//cQuery += "INNER JOIN " +RetSqlName("DAK")+ " DAK (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "ON (DAK_FILIAL = DAI_FILIAL AND DAK_COD = DAI_COD AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 
		//cQuery += "INNER JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "ON (F2_FILIAL = DAI_FILIAL AND F2_DOC = DAI_NFISCA AND F2_SERIE = DAI_SERIE AND F2_CLIENTE = DAI_CLIENT AND F2_LOJA = DAI_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)		
		cQuery += "WHERE "+CHR(13)+CHR(10)
		cQuery += "ZWI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_FILIAL = '"+xFilial("ZWI")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_STATUS = '06' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_CALIAS = 'SF2' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_EMPRES = '"+cEmp+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWI_SITUAC <> '68' "+CHR(13)+CHR(10)
		cQuery += "AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
		cQuery += "AND F2_ZZROMAN <> ' ' "+CHR(13)+CHR(10) 		
		cQuery += "AND NOT EXISTS (SELECT ZWK_CODIGO FROM " +RetSqlName("ZWK")+ " ZWKA (NOLOCK) WHERE ZWKA.D_E_L_E_T_ = ' ' AND ZWKA.ZWK_FILIAL = ZWK.ZWK_FILIAL AND ZWKA.ZWK_EMPRES = ZWK.ZWK_EMPRES AND ZWKA.ZWK_CODIGO = ZWK.ZWK_CODIGO AND ZWKA.ZWK_PROCES = ZWK.ZWK_PROCES AND ZWKA.ZWK_CALIAS = ZWK.ZWK_CALIAS AND ZWKA.ZWK_RECORI = ZWK.ZWK_RECORI AND ZWKA.ZWK_SITUAC = '3') "+CHR(13)+CHR(10)		

		If DAK->(FieldPos("DAK_XWMSOK")) > 0
			cQuery += "AND DAK_XWMSOK = 'S' "+CHR(13)+CHR(10)
		EndIf
			
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
						AADD(aCabec, {aStruCab[nX][1], SUBSTR((cAliasQry)->&(aStruCab[nX][1]), 1, TAMSX3(aStruCab[nX][1])[1]), Nil})
					Else
						AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
					EndIf					
				EndIf
			Next

			cQuery1 := "SELECT DISTINCT ZWL_FILIAL, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_EMPRES, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_DEPOSI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CALIAS, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PROCES, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODIGO, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_ITEM, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PRODUT, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CARGA, "+CHR(13)+CHR(10) 
			cQuery1 += "'N' AS ZWL_EMBPRE, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_FILL5, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_QTSEPA, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CNPJCL, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CODCLI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_PEDORI, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CLIFOR, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_CNPJCF, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_QTDE, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_DEPERP, "+CHR(13)+CHR(10) 
			cQuery1 += "'N' AS ZWL_IDPROC, "+CHR(13)+CHR(10) 
			cQuery1 += "'07' AS ZWL_STATUS, "+CHR(13)+CHR(10)   
			cQuery1 += "'"+DTOS(dDatabase)+"' AS ZWL_DTINCL, "+CHR(13)+CHR(10) 
			cQuery1 += "'"+SUBSTR(TIME(),1,5)+"' AS ZWL_HRINCL, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_DOC AS ZWL_NOTA, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_SERIE AS ZWL_SERIE, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_EMISSAO AS ZWL_DTNFE, "+CHR(13)+CHR(10) 
			cQuery1 += "F2_CHVNFE AS ZWL_CHVNFE, "+CHR(13)+CHR(10) 
			cQuery1 += "'3' AS ZWL_SITUAC, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_SEQINT, "+CHR(13)+CHR(10) 
			cQuery1 += "ZWL_RECORI "+CHR(13)+CHR(10) 
			cQuery1 += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "ON (ZWL_FILIAL = ZWJ_FILIAL AND ZWL_EMPRES = ZWJ_EMPRES AND ZWL_CODIGO = ZWJ_CODIGO AND ZWL_ITEM = ZWJ_ITEM AND ZWL_PROCES = ZWJ_PROCES AND ZWL_CALIAS = ZWJ_CALIAS AND ZWJ.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)				
			cQuery1 += "INNER JOIN " +RetSqlName("SD2")+ " SD2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "ON (SD2.R_E_C_N_O_ = ZWL_RECORI AND SD2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "INNER JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "ON (F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
			cQuery1 += "INNER JOIN " +RetSqlName("DAI")+ " DAI (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "ON (DAI_FILIAL = D2_FILIAL AND DAI_COD = ZWJ_CARGA AND DAI_NFISCA = D2_DOC AND DAI_SERIE = D2_SERIE AND DAI_CLIENT = D2_CLIENTE AND DAI_LOJA = D2_LOJA AND DAI.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "WHERE "+CHR(13)+CHR(10)
			cQuery1 += "ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_STATUS = '06' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_PROCES =  '"+(cAliasQry)->ZWK_PROCES+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_CALIAS = 'SD2' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_FILIAL = '"+(cAliasQry)->ZWK_FILIAL+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_EMPRES = '"+(cAliasQry)->ZWK_EMPRES+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
			cQuery1 += "AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
			cQuery1 += "AND ZWJ_SITUAC <> '68' "+CHR(13)+CHR(10)
			cQuery1 += "AND NOT EXISTS (SELECT ZWL_CODIGO FROM " +RetSqlName("ZWL")+ " ZWLA (NOLOCK) WHERE ZWLA.D_E_L_E_T_ = ' ' AND ZWLA.ZWL_FILIAL = ZWL.ZWL_FILIAL AND ZWLA.ZWL_EMPRES = ZWL.ZWL_EMPRES AND ZWLA.ZWL_CODIGO = ZWL.ZWL_CODIGO AND ZWLA.ZWL_ITEM = ZWL.ZWL_ITEM AND ZWLA.ZWL_PROCES = ZWL.ZWL_PROCES AND ZWLA.ZWL_CALIAS = ZWL.ZWL_CALIAS AND ZWLA.ZWL_RECORI = ZWL.ZWL_RECORI AND ZWLA.ZWL_SITUAC = '3') "+CHR(13)+CHR(10)			
			//cQuery1 += "GROUP BY ZWL_FILIAL, ZWL_EMPRES, ZWL_DEPOSI, ZWL_CALIAS, ZWL_PROCES, ZWL_CODIGO, ZWL_ITEM, ZWL_PRODUT, ZWL_CARGA, ZWL_QTSEPA, ZWL_CNPJCL, "+CHR(13)+CHR(10)
			//cQuery1 += "ZWL_CODCLI, ZWL_PEDORI, ZWL_CLIFOR, ZWL_CNPJCF, ZWL_DEPERP, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CHVNFE, ZWL_FILL5, ZWL_RECORI "+CHR(13)+CHR(10)					
			
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
				U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
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

	If nIntegr == 1		
		cCampos 	:= U_WW01GCPO(4, "INT_E_CAB_NOTA_FISCAL", "2")		
		
		If !Empty(cCampos)
		
			//Begin Transaction
				cQuery := "SELECT "+CHR(13)+CHR(10)
				cQuery += "ZWK_FILIAL, "+CHR(13)+CHR(10)
				cQuery += "ZWK_EMPRES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CODIGO, "+CHR(13)+CHR(10)
				cQuery += "ZWK_PROCES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CALIAS, "+CHR(13)+CHR(10)
				cQuery += "ZWK_DEPOSI, "+CHR(13)+CHR(10)	
				cQuery += "ZWK_RECORI, "+CHR(13)+CHR(10)
				cQuery += "ZWK.R_E_C_N_O_ AS ZWKREC, "+CHR(13)+CHR(10)			
				cQuery += "NU_DOC_ERP, "+CHR(13)+CHR(10)			
				cQuery += "(CASE WHEN ID_PROCESSADO = 'S' THEN '03' ELSE '97' END) AS ZWK_STATUS, "+CHR(13)+CHR(10)
				cQuery += cCampos+" "+CHR(13)+CHR(10)			
				cQuery += "FROM 	( "+CHR(13)+CHR(10)
				cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
				cQuery += "		'SELECT * FROM INT_E_CAB_NOTA_FISCAL "+CHR(13)+CHR(10)
				cQuery += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
				cQuery += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
				cQuery += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
				cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SD3', 'SF1') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
				cQuery += "WHERE "+CHR(13)+CHR(10)
				cQuery += "ZWK_IDPROC = 'N' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_STATUS = '02' "+CHR(13)+CHR(10)
				cQuery += "ORDER BY DT_PROCESSADO "+CHR(13)+CHR(10)								
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				
				While !(cAliasQry)->(Eof())
				
					//Begin Transaction
							
						//aCabec			
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
								cLogWis := U_WWIS1LIN(cEmp, (cAliasQry)->ZWK_DEPOSI, (cAliasQry)->ZWK_INTERF)									
							EndIf
													
							cErro	:= "Erro no processamento da interface no WIS"
							
							If !Empty(cLogWis)
								cErro+= " LOG WIS ("+cLogWis+")"	
							EndIf
							
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"
							cSoluCAo	:= ""
							
							DbSelectArea("ZWK")		
							ZWK->(DbGoTo((cAliasQry)->ZWKREC))
							U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWTSAI", "INT_E_CAB_NOTA_FISCAL", "1", cErro, ERRO97, cDescErro, cSolucao, "97")															
						EndIf
						
						cCampos 	:= U_WW01GCPO(4, "INT_E_DET_NOTA_FISCAL", "2")
						
						cQuery1 := "SELECT "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_CODIGO, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_ITEM, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_PROCES, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_CALIAS, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_RECORI, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_DEPOSI, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_SITUAC, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL.R_E_C_N_O_ AS ZWLREC, "+CHR(13)+CHR(10)				
						cQuery1 += "(CASE WHEN ID_PROCESSADO = 'S' THEN '03' ELSE '97' END) AS ZWL_STATUS, "+CHR(13)+CHR(10)
						cQuery1 += cCampos+" "+CHR(13)+CHR(10)			
						cQuery1 += "FROM 	( "+CHR(13)+CHR(10)
						cQuery1 += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
						cQuery1 += "		'SELECT * FROM INT_E_DET_NOTA_FISCAL "+CHR(13)+CHR(10)
						cQuery1 += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
						cQuery1 += "		AND FILLER_5 = ''"+ALLTRIM((cAliasQry)->NU_DOC_ERP)+"'' "+CHR(13)+CHR(10)
						cQuery1 += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
						cQuery1 += "		) TMPWIS "+CHR(13)+CHR(10)				
						cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10) 
						cQuery1 += "ON (ZWL_EMPRES = CD_EMPRESA AND FILLER_5 = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND NU_ITEM_CORP = ZWL_ITEM COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_CALIAS IN ('SD1', 'SD3') AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 				
						cQuery1 += "WHERE "+CHR(13)+CHR(10) 
						cQuery1 += "ZWL_IDPROC = 'N' "+CHR(13)+CHR(10) 
						cQuery1 += "AND ZWL_PROCES = '"+cProcess+"' "
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
									cLogWis := U_WWIS1LIN(cEmp, (cItemQry)->ZWL_DEPOSI, (cItemQry)->ZWL_INTERF)									
								EndIf
								
								cErro := "Erro no processamento da interface no WIS"
								
								DbSelectArea("ZWL")
								ZWL->(DbGoto((cItemQry)->ZWLREC))
									
								If !Empty(cLogWis)
									cErro += " LOG WIS ("+cLogWis+")"							
								EndIf
								
								cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
								cSoluCAo	:= ""
								 																
								U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWTSAI", "INT_E_DET_NOTA_FISCAL", "1", cErro, ERRO97, cDescErro, cSolucao, "97")																						
							EndIf
																					
							(cItemQry)->(DbSkip())
						EndDo
						
						If Select(cItemQry) > 0
							(cItemQry)->(DbCloseArea())
						EndIf
					
					Begin Transaction
						
						If Len(aCabec) > 0 .AND. Len(aItens) > 0
							U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
						EndIf
						
					End Transaction
					
					(cAliasQry)->(DbSkip())				
				EndDo
			
			//End Transaction		
		EndIf
	
	ElseIf nIntegr == 2
		
		cCampos 	:= U_WW01GCPO(4, "INT_E_CAB_PEDIDO_SAIDA", "2")
		
		If !Empty(cCampos)
		
			//Begin Transaction
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
				cQuery += "		AND DT_PROCESSADO IS NOT NULL "+CHR(13)+CHR(10)
				cQuery += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
				cQuery += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
				cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND ZWK_SITUAC = CD_SITUACAO AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SC5', 'SD3', 'SF2') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
				cQuery += "WHERE "+CHR(13)+CHR(10)
				cQuery += "ZWK_IDPROC = 'N' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_STATUS = '02' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_SITUAC <> '3' "+CHR(13)+CHR(10)
				cQuery += "ORDER BY DT_PROCESSADO "+CHR(13)+CHR(10)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				
				While !(cAliasQry)->(Eof())
				
					//Begin Transaction
							
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
								cLogWis := U_WWIS1LIN(cEmp, (cAliasQry)->ZWK_DEPOSI, (cAliasQry)->ZWK_INTERF)									
							EndIf
									
							cErro	:= "Erro no processamento da interface no WIS"
							
							If !Empty(cLogWis)
								cErro+= " LOG WIS ("+cLogWis+")"	
							EndIf
							
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"
							cSoluCAo	:= ""
							
							DbSelectArea("ZWK")		
							ZWK->(DbGoTo((cAliasQry)->ZWKREC))
							U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWTSAI", "INT_E_CAB_NOTA_FISCAL", "1", cErro, ERRO97, cDescErro, cSolucao, "97")						
						EndIf
							
						cCampos 	:= U_WW01GCPO(4, "INT_E_DET_PEDIDO_SAIDA", "2")
						
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
									cLogWis := U_WWIS1LIN(cEmp, (cItemQry)->ZWL_DEPOSI, (cItemQry)->ZWL_INTERF)									
								EndIf
									
								cErro := "Erro no processamento da interface no WIS"
								
								DbSelectArea("ZWL")
								ZWL->(DbGoto((cItemQry)->ZWLREC))
									
								If !Empty(cLogWis)
									cErro += " LOG WIS ("+cLogWis+")"							
								EndIf
								
								cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
								cSoluCAo	:= ""
								 																
								U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWTSAI", "INT_E_DET_NOTA_FISCAL", "1", cErro, ERRO97, cDescErro, cSolucao, "97")																						
							EndIf
																
							(cItemQry)->(DbSkip())
						EndDo
						
						If Select(cItemQry) > 0
							(cItemQry)->(DbCloseArea())
						EndIf

					Begin Transaction
											
						If Len(aCabec) > 0 .AND. Len(aItens) > 0
							U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
						EndIf
					
					End Transaction
					
					(cAliasQry)->(DbSkip())				
				EndDo
			
			//End Transaction				
		EndIf					

	ElseIf nIntegr == 3
		
		cCampos 	:= U_WW01GCPO(4, "INT_E_CAB_PEDIDO_SAIDA", "2")
		
		If !Empty(cCampos)
		
			//Begin Transaction
				cQuery := "SELECT "+CHR(13)+CHR(10)
				cQuery += "ZWK_FILIAL, "+CHR(13)+CHR(10)
				cQuery += "ZWK_EMPRES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CODIGO, "+CHR(13)+CHR(10)
				cQuery += "ZWK_PROCES, "+CHR(13)+CHR(10)
				cQuery += "ZWK_CALIAS, "+CHR(13)+CHR(10)
				cQuery += "ZWK_DEPOSI, "+CHR(13)+CHR(10)
				cQuery += "ZWK.R_E_C_N_O_ AS ZWKREC, "+CHR(13)+CHR(10)	
				cQuery += "ZWK_SITUAC, "+CHR(13)+CHR(10)			
				cQuery += "NU_PEDIDO_ORIGEM, "+CHR(13)+CHR(10)
				cQuery += "(CASE WHEN ID_PROCESSADO = 'S' THEN '09' ELSE '91' END) AS ZWK_STATUS, "+CHR(13)+CHR(10)
				cQuery += "ZWK.R_E_C_N_O_ AS ZWKREC, "+CHR(13)+CHR(10)
				cQuery += cCampos+" "+CHR(13)+CHR(10)			
				cQuery += "FROM 	( "+CHR(13)+CHR(10)
				cQuery += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
				cQuery += "		'SELECT * FROM INT_E_CAB_PEDIDO_SAIDA "+CHR(13)+CHR(10)
				cQuery += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
				cQuery += "		AND CD_SITUACAO = ''3'' "+CHR(13)+CHR(10)
				cQuery += "		AND DT_PROCESSADO IS NOT NULL "+CHR(13)+CHR(10)
				cQuery += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
				cQuery += "		) TMPWIS "+CHR(13)+CHR(10)				
				cQuery += "INNER JOIN " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
				cQuery += "ON (ZWK_EMPRES = CD_EMPRESA AND ZWK_SITUAC = CD_SITUACAO AND NU_DOC_ERP = ZWK_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND ZWK_CALIAS IN ('SC5', 'SD3', 'SF2') AND ZWK.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)			
				cQuery += "WHERE "+CHR(13)+CHR(10)
				cQuery += "ZWK_IDPROC = 'N' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_STATUS = '08' "+CHR(13)+CHR(10)
				cQuery += "AND ZWK_SITUAC = '3' "+CHR(13)+CHR(10)
				cQuery += "ORDER BY DT_PROCESSADO "+CHR(13)+CHR(10)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				
				While !(cAliasQry)->(Eof())
					
					//Begin Transaction							
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
			
						If (cAliasQry)->ZWK_STATUS == "91"			
							If !EMPTY((cAliasQry)->ZWK_INTERF)
								cLogWis := U_WWIS1LIN(cEmp, (cAliasQry)->ZWK_DEPOSI, (cAliasQry)->ZWK_INTERF)									
							EndIf
									
							cErro	:= "Erro no processamento da interface no WIS"
							
							If !Empty(cLogWis)
								cErro+= " LOG WIS ("+cLogWis+")"	
							EndIf
							
							cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"
							cSoluCAo	:= ""
							
							DbSelectArea("ZWK")		
							ZWK->(DbGoTo((cAliasQry)->ZWKREC))
							U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWTSAI", "INT_E_CAB_NOTA_FISCAL", "1", cErro, ERRO91, cDescErro, cSolucao, "91")						
						EndIf
						
						cCampos 	:= U_WW01GCPO(4, "INT_E_DET_PEDIDO_SAIDA", "2")
						
						cQuery1 := "SELECT "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_ITEM, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_PROCES, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_CALIAS, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_DEPOSI, "+CHR(13)+CHR(10)
						//cQuery1 += "ZWL_RECORI, "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_SITUAC, "+CHR(13)+CHR(10)
						//cQuery1 += "ZWL_INTERF, "+CHR(13)+CHR(10)					
						cQuery1 += "ZWL.R_E_C_N_O_ AS ZWLREC, "+CHR(13)+CHR(10)				
						cQuery1 += "(CASE WHEN ID_PROCESSADO = 'S' THEN '09' ELSE '91' END)  AS ZWL_STATUS, "+CHR(13)+CHR(10)
						cQuery1 += cCampos+" "+CHR(13)+CHR(10)				
						cQuery1 += "FROM 	( "+CHR(13)+CHR(10)
						cQuery1 += "		SELECT * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
						cQuery1 += "		'SELECT * FROM INT_E_DET_PEDIDO_SAIDA "+CHR(13)+CHR(10)
						cQuery1 += "		WHERE CD_EMPRESA = ''"+cEmp+"'' "+CHR(13)+CHR(10)
						cQuery1 += "		AND NU_PEDIDO_ORIGEM = ''"+ALLTRIM((cAliasQry)->NU_PEDIDO_ORIGEM)+"'' "+CHR(13)+CHR(10)
						cQuery1 += "		AND CD_SITUACAO = ''3'' "+CHR(13)+CHR(10)
						cQuery1 += "		AND DT_PROCESSADO IS NOT NULL "+CHR(13)+CHR(10)
						cQuery1 += "		AND ID_PROCESSADO <> ''N''') "+CHR(13)+CHR(10)
						cQuery1 += "		) TMPWIS "+CHR(13)+CHR(10)				
						cQuery1 += "INNER JOIN " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10) 
						cQuery1 += "ON (ZWL_EMPRES = CD_EMPRESA AND ZWL_SITUAC = CD_SITUACAO AND FILLER_5 = ZWL_CODIGO COLLATE LATIN1_GENERAL_100_CS_AS AND NU_ITEM_CORP = ZWL_ITEM COLLATE LATIN1_GENERAL_100_CS_AS AND ZWL_CALIAS IN ('SC6', 'SD3', 'SD2') AND ZWL.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10) 				
						cQuery1 += "WHERE "+CHR(13)+CHR(10)
						cQuery1 += "ZWL_IDPROC = 'N' "+CHR(13)+CHR(10)
						cQuery1 += "AND ZWL_IDPROC = 'N' "+CHR(13)+CHR(10) 
						cQuery1 += "AND ZWL_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
						cQuery1 += "AND ZWL_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
						cQuery1 += "AND ZWL_SITUAC = '3' "+CHR(13)+CHR(10)
						cQuery1 += "AND ZWL_STATUS = '08' "+CHR(13)+CHR(10) 						
						
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
		
							If (cItemQry)->ZWL_STATUS == "91"				
								If !EMPTY((cItemQry)->ZWL_INTERF)
									cLogWis := U_WWIS1LIN(cEmp, (cItemQry)->ZWL_DEPOSI, (cItemQry)->ZWL_INTERF)									
								EndIf
										
								cErro := "Erro no processamento da interface no WIS"
								
								DbSelectArea("ZWL")
								ZWL->(DbGoto((cItemQry)->ZWLREC))
									
								If !Empty(cLogWis)
									cErro += " LOG WIS ("+cLogWis+")"							
								EndIf
								
								cDescErro 	:= "LOG WIS ("+cLogWis+")"+CHR(13)+CHR(10)+" QUERY ("+cQuery+")"+CHR(13)+CHR(10)+" SQL ERROR ("+TCSQLError()+")"
								cSoluCAo	:= ""
								 																
								U_WIIWLOG(3,, "ZWL", ZWL->(RECNO()), ZWL->ZWL_EMPRES, ZWL->ZWL_DEPOSI, ZWL->ZWL_CODIGO, ZWL->ZWL_ITEM, ZWL->ZWL_SITUAC, "WIIWTSAI", "INT_E_DET_NOTA_FISCAL", "1", cErro, ERRO91, cDescErro, cSolucao, "91")																													
							EndIf
																					
							(cItemQry)->(DbSkip())
						EndDo
						
						If Select(cItemQry) > 0
							(cItemQry)->(DbCloseArea())
						EndIf
					
					Begin Transaction
					
						If Len(aCabec) > 0 .AND. Len(aItens) > 0
							U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
						EndIf
					
					End Transaction
					
					(cAliasQry)->(DbSkip())				
				EndDo
				
			//End Transaction				
		EndIf					

		
/*	ElseIf nIntegr == 3	//Romaneio - NF Faturamento
			
		cQuery := "SELECT DISTINCT ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO, ZWK_PROCES, " +CHR(13)+CHR(10)
		cQuery += "(CASE WHEN F2_CHVNFE <> ' ' AND ZWI_SITUAC = '57' THEN '07' WHEN F2_CHVNFE IS NULL AND ZWI_SITUAC = '68' THEN '50' ELSE ZWK_STATUS END) AS ZWK_STATUS, " +CHR(13)+CHR(10)
		cQuery += "(CASE WHEN F2_CHVNFE <> ' ' AND ZWI_SITUAC = '57' THEN '3' ELSE ZWK_SITUAC END) AS ZWK_SITUAC " +CHR(13)+CHR(10)
		cQuery += "FROM " +RetSqlName("ZWK")+ " ZWK (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("ZWI")+ " ZWI (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWK_FILIAL = ZWI_FILIAL AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWI.D_E_L_E_T_ = ' ' AND ZWI_STATUS = '06') "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN " +RetSqlName("SC5")+ " SC5 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (SC5.R_E_C_N_O_ = ZWK_RECORI AND SC5.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "LEFT JOIN " +RetSqlName("SC9")+ " SC9 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (C5_FILIAL = C9_FILIAL AND C9_PEDIDO = C5_NUM AND C9_ZROMAN = ZWK_CARGA AND SC9.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "LEFT JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (F2_FILIAL = C9_FILIAL AND F2_DOC = C9_NFISCAL AND F2_SERIE = C9_SERIENF AND F2_CLIENTE = C9_CLIENTE AND F2_LOJA = C9_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE "+CHR(13)+CHR(10)
		cQuery += "ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_STATUS = '03' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_PROCES = '"+cProcess+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_CALIAS = 'SC5' "+CHR(13)+CHR(10)
		cQuery += "AND ZWK_EMPRES = '"+ IIf(cEmpAnt=='01',"2","1")+"' "+CHR(13)+CHR(10)
		//cQuery += "AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
		//cQuery += "AND EXISTS (SELECT ZWI_CODIGO FROM " +RetSqlName("ZWI")+ " ZWI (NOLOCK) WHERE ZWI.D_E_L_E_T_ = ' ' AND ZWI_STATUS = '06' AND ZWI_PROCES = ZWK_PROCES AND ZWI_CALIAS = ZWK_CALIAS AND ZWI_EMPRES = ZWK_EMPRES AND ZWI_CODIGO = ZWK_CODIGO) "+CHR(13)+CHR(10)
			
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
						AADD(aCabec, {aStruCab[nX][1], SUBSTR((cAliasQry)->&(aStruCab[nX][1]), 1, TAMSX3(aStruCab[nX][1])[1]), Nil})
					Else
						AADD(aCabec, {aStruCab[nX][1], (cAliasQry)->&(aStruCab[nX][1]), Nil})
					EndIf					
				EndIf
			Next

			cQuery1 := "SELECT ZWL_ITEM, ZWL_NOTA, ZWL_SITUAC, ZWL_SERIE, ZWL_DTNFE, ZWL_CHVNFE, "+CHR(13)+CHR(10) 
			cQuery1 += "(CASE WHEN ZWL_CHVNFE <> ' ' THEN '07' WHEN ZWL_CHVNFE IS NULL AND (ZWJ_SITUAC ='68' OR ZWJ_QTDEXP = 0) THEN '50' ELSE ZWL_STATUS END) AS ZWL_STATUS, "+CHR(13)+CHR(10) 
			cQuery1 += "(CASE WHEN ZWL_CHVNFE <> ' ' THEN '3' ELSE ZWL_SITUAC END) AS ZWL_SITUAC "+CHR(13)+CHR(10) 
			cQuery1 += "FROM ( "+CHR(13)+CHR(10) 											
			cQuery1 += "	SELECT DISTINCT ZWL_ITEM,D2_DOC AS ZWL_NOTA, ZWL_STATUS, ZWL_SITUAC, D2_SERIE AS ZWL_SERIE, D2_EMISSAO AS ZWL_DTNFE, "+CHR(13)+CHR(10) 					
			cQuery1 += "	F2_CHVNFE AS ZWL_CHVNFE, MAX(ZWJ_SITUAC) AS ZWJ_SITUAC, SUM(ZWJ_QTDEXP) AS ZWJ_QTDEXP "+CHR(13)+CHR(10)
			cQuery1 += "	FROM " +RetSqlName("ZWL")+ " ZWL (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	INNER JOIN " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (ZWL_FILIAL = ZWJ_FILIAL AND ZWL_EMPRES = ZWJ_EMPRES AND ZWL_CODIGO = ZWJ_CODIGO AND ZWL_ITEM = ZWJ_ITEM AND ZWL_PROCES = ZWJ_PROCES AND ZWL_CALIAS = ZWJ_CALIAS AND ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_STATUS = '06') "+CHR(13)+CHR(10)
			cQuery1 += "	INNER JOIN " +RetSqlName("SC6")+ " SC6 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (SC6.R_E_C_N_O_ = ZWL_RECORI AND SC6.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "	LEFT JOIN " +RetSqlName("SD2")+ " SD2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (D2_FILIAL = C6_FILIAL AND D2_DOC = C6_NOTA AND D2_SERIE = C6_SERIE AND D2_COD = C6_PRODUTO AND D2_ITEMPV = C6_ITEM AND D2_CLIENTE = C6_CLI AND D2_LOJA = C6_LOJA AND SD2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "	LEFT JOIN " +RetSqlName("SF2")+ " SF2 (NOLOCK) "+CHR(13)+CHR(10)
			cQuery1 += "	ON (F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND SF2.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
			cQuery1 += "	WHERE "+CHR(13)+CHR(10)
			cQuery1 += "	ZWL.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_STATUS = '03'  "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_PROCES =  '"+(cAliasQry)->ZWK_PROCES+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_CALIAS = 'SC6' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_FILIAL = '"+(cAliasQry)->ZWK_FILIAL+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_EMPRES = '"+(cAliasQry)->ZWK_EMPRES+"' "+CHR(13)+CHR(10)
			cQuery1 += "	AND ZWL_CODIGO = '"+(cAliasQry)->ZWK_CODIGO+"' "+CHR(13)+CHR(10)
			//cQuery1 += "	AND F2_CHVNFE <> ' ' "+CHR(13)+CHR(10)
			//cQuery1 += "	AND EXISTS (SELECT ZWJ_CODIGO FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) WHERE ZWJ.D_E_L_E_T_ = ' ' AND ZWJ_STATUS = '06' AND ZWJ_PROCES = ZWL_PROCES AND ZWJ_CALIAS = ZWL_CALIAS AND ZWJ_EMPRES = ZWL_EMPRES AND ZWJ_CODIGO = ZWL_CODIGO AND ZWJ_ITEM = ZWL_ITEM) "+CHR(13)+CHR(10)
			cQuery1 += "	GROUP BY ZWL_ITEM,D2_DOC,D2_SERIE,D2_EMISSAO, F2_CHVNFE, ZWL_STATUS, ZWL_SITUAC "+CHR(13)+CHR(10)					
			cQuery1 += ") TMPFATROM"+CHR(13)+CHR(10)
			
			cQuery1 := ChangeQuery(cQuery1)
		
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),cItemQry)
			
			While !(cItemQry)->(Eof())

				aStruItem 	:= (cItemQry)->(dBStruct())
				aStruZWL 	:= ZWL->(dBStruct())
				aLinha		:= {}
						
				For nX:= 1 to Len(aStruItem)
						
					nPosZWL := ASCAN(aStruZWL, {|x| x[1] == aStruItem[nX][1]})
						
					If nPosZWL > 0
						
						If nX == 1 .AND. ALLTRIM(aStruItem[nX][1]) == "ZWL_ITEM"
							AADD(aLinha, {"LINPOS",aStruItem[nX][1], (cItemQry)->&(aStruItem[nX][1])})
							AADD(aLinha, {"AUTDELETA", "N", NIL})
						Else															      
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
				
				(cItemQry)->(DbSkip())
			EndDo
	
			If U_WIIWSAI("ZWK", nOpcA, aCabec, aItens)
				//MsgInfo("Interface de saída gerada com sucesso.", "WIIWTSAI")
			Else
				//MsgStop("Falha na geraCAo da interface de saída. Verifique o Log.", "WIIWTSAI")
			EndIf
			
			If Select(cItemQry) > 0
				(cItemQry)->(dbCloseArea())
			EndIf
			
			aCabec := {}
			aItens := {}
			
			(cAliasQry)->(DbSkip())			
		EndDo
	*/
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
/*/{Protheus.doc} WWIS01AP

Rotina para verificaCAo do armazém padrAo do processo informado na integraCAo PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  11/05/2018
@version P12
@return cProc, Codigo do Processo
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS01AP(cProcess, cCodProd, cItem, cArmazem, lPrcEnt)

Local aArea		:= GetArea()
Local lRet			:= .T.
Local cIntWis		:= IIf(FWCodEmp() == '01', '1', IIF(FWCodEmp() == '02', '2', '0'))

Default cProcess	:= ""
Default cCodProd	:= ""
Default cArmazem	:= ""
Default cItem		:= ""
Default lPrcEnt	:= .T.

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01") //FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. GetMv("MV_ZZWMSIN",, .T.)
	If !EMPTY(cProcess) .AND. !EMPTY(cCodProd) .AND. !EMPTY(cArmazem)
		DbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL, B1_COD
		SB1->(DbSeek(xFilial("SB1")+cCodProd))		
	
		If SB1->B1_ZINTWIS = cIntWis 		
			DbSelectArea("ZWO")
			DbSetOrder(1) //ZWO_FILIAL, ZWO_CODIGO, R_E_C_N_O_, D_E_L_E_T_
			If ZWO->(DbSeek(xFilial("ZWO")+cProcess))
				If lRet
					If lPrcEnt
						If !EMPTY(ZWO->ZWO_ARMENT)
							If AllTrim(cArmazem) <> ALLTRIM(ZWO->ZWO_ARMENT)				
								If !EMPTY(cItem)
									Help(NIL, NIL, "MT100TOK", NIL, "O armazém informado no item "+ALLTRIM(cItem)+" - produto "+ALLTRIM(cCodProd)+" é invalido para o processo "+ALLTRIM(cProcess)+". Esse processo sO permite o lanCamento no armazém "+ALLTRIM(ZWO->ZWO_ARMENT)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione o armazém válido e tente novamente."})
								Else
									Help(NIL, NIL, "MT100TOK", NIL, "O armazém informado "+ALLTRIM(cArmazem)+" para o produto "+ALLTRIM(cCodProd)+" é invalido para o processo "+ALLTRIM(cProcess)+". Esse processo sO permite o lanCamento no armazém "+ALLTRIM(ZWO->ZWO_ARMENT)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione o armazém válido e tente novamente."})
								EndIf
						
								lRet := .F.
								Return lRet
							EndIf
						EndIf
					Else
						If !EMPTY(ZWO->ZWO_ARMSAI)
							If AllTrim(cArmazem) <> ALLTRIM(ZWO->ZWO_ARMSAI)				
								If !EMPTY(cItem)
									Help(NIL, NIL, "MT100TOK", NIL, "O armazém informado no item "+ALLTRIM(cItem)+" - produto "+ALLTRIM(cCodProd)+" é invalido para o processo "+ALLTRIM(cProcess)+". Esse processo sO permite o lanCamento no armazém "+ALLTRIM(ZWO->ZWO_ARMSAI)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione o armazém válido e tente novamente."})
								Else
									Help(NIL, NIL, "MT100TOK", NIL, "O armazém informado "+ALLTRIM(cArmazem)+" para o produto "+ALLTRIM(cCodProd)+" é invalido para o processo "+ALLTRIM(cProcess)+". Esse processo sO permite o lanCamento no armazém "+ALLTRIM(ZWO->ZWO_ARMSAI)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione o armazém válido e tente novamente."})
								EndIf
					
								lRet := .F.
								Return lRet
							EndIf
						EndIf
					EndIf
				EndIf				
			EndIf
		EndIf
	EndIf
EndIf
	
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWIS1CLI

Rotina para verificaCAo da integraCAo do cadastro de Cliente no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, LOgico
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS1CLI(cEmpCli, cFilCli, cCodCli)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpCli	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilCli	:= PADL(FWCodFil(), 3, "0")   
Default cCodCli	:= ""

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01")
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

Rotina para verificaCAo da integraCAo do cadastro de Fornecedor no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, LOgico
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS1FOR(cEmpFor, cFilFor, cCodFor)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpFor	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilFor	:= PADL(FWCodFil(), 3, "0")  
Default cCodFor	:= ""

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01")
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

Rotina para verificaCAo da integraCAo do cadastro de Transportadora no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, LOgico
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS1TRS(cEmpTrs, cFilTrs, cCodTrs)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpTrs	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilTrs	:= PADL(FWCodFil(), 3, "0") 
Default cCodTrs	:= ""

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01")
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

Rotina para verificaCAo da integraCAo do cadastro de Produto no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, LOgico
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS1PRD(cEmpPrd, cFilPrd, cCodPrd)

Local aArea		:= GetArea()
Local lRet			:= .F.
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cEmpPrd	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilPrd	:= PADL(FWCodFil(), 3, "0")
Default cCodPrd	:= ""

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01")
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

Rotina para verificaCAo do log do processamento da interface no WIS.

@author Allan Constantino Bonfim
@since  05/07/2018
@version P12
@return lRet, LOgico
/*/
//-------------------------------------------------------------------------------------------------
User Function WWIS1LIN(cEmpInt, cDeposit, cInterf, lTodos)

Local aArea		:= GetArea()
Local cRet			:= ""
Local cQueryWis 	:= ""	
Local cAliasWis	:= GetNextAlias()
Local cWISBd		:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias	:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))
Local cWisEmp		:= ""

Default cEmpInt	:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cInterf	:= ""
Default lTodos	:= .F.
Default cDeposit	:= "001"

If GetMv("MV_ZZWMSIN",, .T.) .AND. FWCodEmp() $ GetMv("MV_ZZWMSEM",, "02") .AND. FWCodFil() $ GetMv("MV_ZZWMSFL",, "01")

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
Static Function WW01IPED(cEmpres, cRoman, cAliasInt)

Local lRet			:= .F.
Local cQRoma		:= ""
Local cTmpRoma	:= GetNextAlias()

Default cEmpres	:= FWCodEmp()
Default cRoman	:= ""
Default cAliasInt	:= "SC5"

If !Empty(cRoman)
	
	cQRoma := "SELECT ZWK_EMPRES, ZWK_CARGA, ZWK_QTDCAR, COUNT(*) AS QTDCARGA "+CHR(13)+CHR(10) 
	cQRoma += "FROM "+RetSqlName("ZWK")+" ZWK (NOLOCK) "+CHR(13)+CHR(10)
	cQRoma += "WHERE ZWK.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_FILIAL = '"+xFilial("ZWK")+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_CALIAS = '"+ALLTRIM(cAliasInt)+"' "+CHR(13)+CHR(10)
	cQRoma += "AND ZWK_EMPRES = '"+ALLTRIM(cEmpres)+"' "+CHR(13)+CHR(10)
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


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W1INSWIS

Verifica se o registro foi já integrado ao WIS.

@author Allan Constantino Bonfim
@since  22/10/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function W1INSWIS(cInterface, cEmpWis, cFilWis, cSituac, cIntCod, cIntItem)

Local lRet				:= .F.
Local cQDados			:= ""
Local cTmpWInt		:= GetNextAlias()
Local cWISBd			:= Alltrim(GetMv("MV_ZZWISBD",, "WISHML"))
//Local cWISAlias		:= Alltrim(GetMv("MV_ZZWISAL",, "WIS50"))

Default cInterface	:= ""
Default cEmpWis		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilWis		:= PADL(FWCodFil(), 3, "0") 
Default cSituac		:= "1"
Default cIntCod		:= ""
Default cIntItem		:= ""

//Allan Constantino Bonfim - 22/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste para a verificação se o insert já foi realizado no WIS.
If !EMPTY(cInterface) .AND. !EMPTY(cIntCod)

	cQDados := "SELECT TOP 1 * FROM OPENQUERY(["+cWISBd+"], "+CHR(13)+CHR(10)
	cQDados += "'SELECT ID_PROCESSADO FROM "+ALLTRIM(cInterface)+" "+CHR(13)+CHR(10) 
	cQDados += "WHERE FILLER_5 IS NOT NULL "+CHR(13)+CHR(10) 
	cQDados += "AND ID_PROCESSADO <> ''E'' "+CHR(13)+CHR(10) 
	cQDados += "AND CD_SITUACAO = ''"+cSituac+"'' "+CHR(13)+CHR(10)
	cQDados += "AND CD_EMPRESA = ''"+cEmpWis+"'' "+CHR(13)+CHR(10) 
	cQDados += "AND CD_DEPOSITO = ''"+cFilWis+"'' "+CHR(13)+CHR(10) 

	If !EMPTY(cIntItem)
		cQDados += "AND NU_ITEM_CORP = ''"+cIntItem+"'' "+CHR(13)+CHR(10)
	EndIf

	cQDados += "AND FILLER_5 = ''"+cIntCod+"''') "+CHR(13)+CHR(10)
	

	//cQDados := ChangeQuery(cQDados)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpWInt)	
	
	If !(cTmpWInt)->(EOF())
		lRet := .T.	
	EndIf
EndIf

If Select(cTmpWInt) > 0
	(cTmpWInt)->(DbCloseArea())
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W1CONOUT

Função para gerar o conout no console.

@author Allan Constantino Bonfim
@since  27/11/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function W1CONOUT(cCodPrc, cDescPrc, cEmprc, cFilPrc, lInicio)

Default cCodPrc	:= ""
Default cDescPrc	:= ""
Default cEmprc	:= ""
Default cFilPrc	:= ""
Default lInicio	:= .T.

If lInicio
	CONOUT("PROCESSO "+ALLTRIM(cCodPrc)+" - "+ALLTRIM(cDescPrc)+" - EMPRESA "+cEmprc+" - FILIAL "+cFilPrc+" - INICIO - "+DTOC(ddatabase)+" - "+Time())
Else
	CONOUT("PROCESSO "+ALLTRIM(cCodPrc)+" - "+ALLTRIM(cDescPrc)+" - EMPRESA "+cEmprc+" - FILIAL "+cFilPrc+" - FIM - "+DTOC(ddatabase)+" - "+Time())
EndIf

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} W1WCARGA

Verifica o número do romaneio gerado automaticamente pelo WIS.

@author Allan Constantino Bonfim
@since  06/12/2018
@version P12
@return cCarga, variavel caracter
/*/
//-------------------------------------------------------------------------------------------------
Static Function W1WCARGA(cEmpWis, cFilWis, cPedido, cIntCod)

Local cCarga			:= ""
Local cQDados			:= ""
Local cTmpWInt		:= GetNextAlias()

Default cEmpWis		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Default cFilWis		:= PADL(FWCodFil(), 3, "0") 
Default cIntCod		:= ""
Default cPedido		:= ""


If !EMPTY(cPedido) .AND. !EMPTY(cIntCod)

	cQDados := "SELECT DISTINCT ZWJ_EMPRES, ZWJ_DEPOSI, ZWJ_CODIGO, ZWJ_CARGA, ZWJ_PEDORI, ZWJ_PEDIDO "+CHR(13)+CHR(10) 
	cQDados += "FROM " +RetSqlName("ZWJ")+ " ZWJ (NOLOCK) "+CHR(13)+CHR(10) 
	cQDados += "WHERE D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
	cQDados += "AND ZWJ_FILIAL = '"+xFilial("ZWJ")+"' "+CHR(13)+CHR(10) 
	cQDados += "AND ZWJ_EMPRES = '"+cEmpWis+"' "+CHR(13)+CHR(10) 
	cQDados += "AND ZWJ_DEPOSI = '"+cFilWis+"' "+CHR(13)+CHR(10) 
	cQDados += "AND ZWJ_CODIGO = '"+cIntCod+"' "+CHR(13)+CHR(10)
	cQDados += "AND ZWJ_PEDORI = '"+cPedido+"' "+CHR(13)+CHR(10) 

	cQDados := ChangeQuery(cQDados)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQDados), cTmpWInt)	
	
	If !(cTmpWInt)->(EOF())
		cCarga := ALLTRIM((cTmpWInt)->ZWJ_PEDIDO)
	EndIf
EndIf

If Select(cTmpWInt) > 0
	(cTmpWInt)->(DbCloseArea())
EndIf

Return cCarga


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WWISTLOTE

Valida se o saldo total do lote no armazém

@author CM Solutions - Allan Constantino Bonfim
@since  09/01/2020
@version P12
@return lRet, variavel lógica
/*/
//-------------------------------------------------------------------------------------------------
Static Function WWISTLOTE(cQueryOri, cProduto, cArmazem, cLote)

	Local aArea				:= GetArea()
	Local nRet				:= 0
	Local cQTotPrd			:= ""
	Local cTmpTotPrd		:= GetNextAlias()
	//Local nSldPrdArm		:= 0
	//Local nPrdQtde		:= 0
	
	Default cQueryOri		:= ""
	Default cProduto		:= ""
	Default cArmazem		:= ""
	Default cLote			:= ""
	
			
	If !EMPTY(cQueryOri) .AND. !EMPTY(cProduto) .AND. !EMPTY(cArmazem)
		/*
		If !Empty(cLote)
			nSldPrdArm := SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmazem,TamSx3("B8_LOCAL")[01]), cLote, NIL, NIL, NIL, NIL, dDataBase)
		Else
			nSldPrdArm := SaldoLote(Padr(cProduto,TamSx3("B8_PRODUTO")[01]), Padr(cArmazem,TamSx3("B8_LOCAL")[01]), NIL, NIL, NIL, NIL, NIL, dDataBase)
		EndIf
		*/
		cQTotPrd := "SELECT B1_COD, D1_LOCAL, SUM(ZWJ_QTDAVA) AS ZWJQTDAVA, SUM(ZWJ_QTDCNF) AS ZWJQTDCNF  "+CHR(13)+CHR(10)
		cQTotPrd += "FROM ( "+CHR(13)+CHR(10) 
		cQTotPrd += ChangeQuery(cQueryOri)
		cQTotPrd += " ) TMP "+CHR(13)+CHR(10)		
		cQTotPrd += "WHERE  "+CHR(13)+CHR(10)
		cQTotPrd += "B1_COD = '"+cProduto+"' "+CHR(13)+CHR(10)
		cQTotPrd += "AND D1_LOCAL = '"+cArmazem+"' "+CHR(13)+CHR(10)
		
		If !EMPTY(cLote)
			cQTotPrd += "AND (D1_LOTECTL = '"+cLote+"' OR ZWJ_LOTE = '"+cLote+"') "+CHR(13)+CHR(10)
		EndIf
		
		cQTotPrd += "GROUP BY B1_COD, D1_LOCAL "+CHR(13)+CHR(10) 
	
		If Select(cTmpTotPrd) > 0
			(cTmpTotPrd)->(DbCloseArea())
		EndIf
		
		cQTotPrd := ChangeQuery(cQTotPrd)	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQTotPrd),cTmpTotPrd)	
		
		If !(cTmpTotPrd)->(EOF())
			If !EMPTY((cTmpTotPrd)->ZWJQTDAVA)
				nRet	:=	(cTmpTotPrd)->ZWJQTDAVA
			Else
				nRet	:=	(cTmpTotPrd)->ZWJQTDCNF
			EndIf
			
			//If nSldPrdArm >= nPrdQtde
				//nRet := nPrdQtde
			//EndIf		
		EndIf
	EndIf
	
	If Select(cTmpTotPrd) > 0
		(cTmpTotPrd)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return nRet
