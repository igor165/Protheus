#Include 'Protheus.ch'
#include 'LOJA901I.ch'

Static cMH8Chave := ""
Static lMH8_NUM 	:= NIL
Static lMH8_MOTIVO 	:= NIL
Static lMH8_ORCAME 	:= NIL

Static lCamposST :=  NIL
Static lAtuLj140 := GetAPOInfo("LOJA140.PRX")[4] >= Ctod("21/02/2018")

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA901I
Função de integracao Protheus e-commerce CiaShop atualiza status do pedido
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LOJA901I()
/*/
//-------------------------------------------------------------------
Function LOJA901I(aParam)

Local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA901I" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A"
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
	
Else
	_cEmp := aParam[1]
	_cFil := aParam[2]
	_lJob :=  .T.
EndIf

If _lJob
	RPCSetType(3)
	RpcSetEnv(_cEmp, _cFil,,,"FAT" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt
lLock := oLJCLocker:GetLock( cName )

	
If lLock
	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If   !lCallStack .AND. !Lj904IntOk(.F., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0005) + STR0003 + DTOC(Date()) + " - " + Time() ) //######### //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	LJ901IASK(_cEmp,_cFil,_lJob)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0005) + STR0003 + DTOC(Date()) + " - " + Time()) //######### //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" )
	EndIf
	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4], STR0005) )	 //###### //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ901IASK
Função de teste integracao Protheus e-commerce CiaShop atualiza status do pedido
@param   	_lJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/09/2016
@obs
@sample Lj900APr()
/*/
//-------------------------------------------------------------------
Function LJ901IASK(_cEmp,_cFil,_lJob)
	
Local oObjJSon := ""
Local cSequenc := ""
Local lSendProc :=  .T. //Envia Status como processado
Local cMsg := "" //mensagem de Processamento

// Retorna JSon contendo os pedidos do dia
oObjJSon := LJI9JSON(_cEmp,_cFil,_lJob,@cSequenc, @lSendProc, .F. )

// se existirem pedidos a serem importados
If !Empty(oObjJSon)
	If !_lJob
		// processamento pedidos ciashop
		Processa( { || lRet := LJI9PCIA(oObjJSon,_lJob,_cFil,cSequenc, lSendProc) }, STR0007 )	// "Aguarde, processando pedidos CiaShop x Protheus."
	Else
		Lj900XLg("LOJA900I ", STR0007)	// "Aguarde, processando pedidos CiaShop x Protheus."
		lRet := LJI9PCIA(oObjJSon,_lJob,_cFil,cSequenc, lSendProc)
	EndIf
Else
	cMsg := STR0026 //"Não existem pedidos CiaShop com atualização de Status a serem processados."
	If !_lJob
		MsgAlert(cMsg)	// "Não existem pedidos CiaShop com atualização de Status a serem processados."
	Else
		Lj900XLg("LOJA900I ", cMsg)	// "Não existem pedidos CiaShop com atualização de Status a serem processados."
	EndIf
EndIf

If _lJob
	RPCClearEnv()
EndIF
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI9PCIA
Função atualiza status do pedido CiaShop x Protheus
@param   	aParam - JSon contendo os pedidos ciaShop, se execução é em job (.t./.f.) e Filial
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LJI9PCIA()
/*/
//-------------------------------------------------------------------
Static Function LJI9PCIA(oObjJSon,_lJob,_cFil,cSeq, lSendProc)

Local nX			:= ""
Local cPedECom 		:= ""
Local cStatus 		:= ""
Local cDscStat		:= ""
Local lRet			:= .f.
Local cCanalOrig	:= ""	// Canal Origem
Local cAliasSC5  	:= GetNextAlias() //Alias a consulta
local cQuery 		:= "" //String de Consulta
Local cMsgTab   	:= STR0019		//"Nesta Versão de Fonte é necessário criar a Tabela MH6 e MH8"
Local lVldMH6   	:= AliasIndic("MH6") 
Local cMsgProc		:= "" //Mensagem de Processamento
Local aPedProc		:= {} //Pedidos Processados com sucesso
Local aFilLoc  := IIF( ExistFunc("LOJX904Loc") , LOJX904Loc(), { {cFilAnt, {}} }) //Locais de Estoque EC
Local lEstLoja :=  Len(aFilLoc) > 1 .OR. ( Len(aFilLoc) = 1 .AND. Len(aFilLoc[1]) > 1 .AND.  Len(aFilLoc[01, 02]) > 0)  
Local cAliasTmp2	:= GetNextAlias()
Local cFilBkp		:= cFilAnt
If !_lJob
	ProcRegua(Len(oObjJSon))
EndIf
	
If !lVldMH6 .And. !_lJob
	MsgStop(cMsgTab)
	Return()	
ElseIf	!lVldMH6 .And. _lJob
	Lj900XLg(cMsgTab)
	Return() 
EndIf

// processa os pedidos CiaShop
For nX := 1 To Len(oObjJSon)
	
	// Desconsidera pedidos que não são MarketPlace
	cCanalOrig	:= AllTrim(Upper(oObjJSon[nX]:sourceChannel))	// "sourceChannel" <> : "Loja"	// "sourceChannel": "Loja",
	// "source": "API" => sourceCHanel = extra/wallmart/cnova e como identificar pedido origem
		
	//Recebe o status do pedido de venda
	cDscStat 	:= Lj900CodPd(oObjJSon[nX]:status)
	
	// se o pedido estiver cancelado ou aprovado		
	If !Empty(cDscStat) 
		// se não estiver rodadand em Job
		cMsgProc := " LOJA901I - " + STR0013+ Padr(AllTrim(Str(oObjJSon[nX]:id)),TamSx3("C5_PEDECOM")[1]) //'Processando pedido CiaShop '
		If !_lJob
			IncProc(cMsgProc)
		Else
			Lj900XLg( cMsgProc, Padr(AllTrim(Str(oObjJSon[nX]:id)),TamSx3("C5_PEDECOM")[1])  )	
		EndIf
		
		// lê o pedido e-commerce e o status do pedido de venda
		cPedECom := AllTrim(Str(oObjJSon[nX]:id))	// "id": 37	-	pedido e-commerce C5_PEDECOM
		cStatus := cDscStat		// "status": "cancelled" ou  "aproved"

		cFilMGU := cFilAnt
		If lEstLoja
			cPedECom := PadL(cPedECom,TamSx3("C5_PEDECOM")[1])	
			//Query para localizar a Filial do Pedido
			//Localiza a Filial para qual foi gerado o Pedido de Venda
			BeginSql alias cAliasTmp2
				SELECT 
					MGU.MGU_FILPED
				FROM %table:MGU% MGU
				WHERE
					MGU.MGU_PEDECO = %exp:cPedECom% AND
					MGU.%NotDel% AND
					MGU.MGU_FILIAL  = %xFilial:MGU%  AND
					MGU.MGU_CONFIR = '1'
					ORDER BY MGU_FILPED				
				
			EndSql	
			(cAliasTmp2)->(DbGoTop())
			If (cAliasTmp2)->(!Eof()) .AND. !Empty((cAliasTmp2)->MGU_FILPED)
				cFilMGU := (cAliasTmp2)->MGU_FILPED
			EndIf
			(cAliasTmp2)->(DbCloseArea())
		EndIf
		
		// Filtra pedido e-commerce
		If Select(cAliasSC5) > 0
		   (cAliasSC5)->(dbCloseArea())
		EndIf
		cPedECom := Padr(LTrim(cPedECom),TamSx3("C5_PEDECOM")[1])	
		cQuery := "SELECT C5_FILIAL, C5_NUM, C5_PEDECOM, C5_STATUS, C5_NOTA, R_E_C_N_O_ AS REGISTRO "
		cQuery += "FROM "+RetSqlName("SC5")
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '"+xFilial("SC5", cFilMGU)+"'"
		cQuery += " AND C5_PEDECOM = '"+cPedECom+"'"
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN",  TCGENQRY(,,cQuery) ,cAliasSC5, .F., .T.)
		(cAliasSC5)->(DbGoTop())
		
		// se o pedido e-commerce existir na base Protheus 
		If (cAliasSC5)->(!Eof())
			// se o pedido no Protheus já estiver com status maior ou igual a 10 ou nota ja emitida
			If (cAliasSC5)->C5_STATUS >= "10" .Or. !Empty((cAliasSC5)->C5_NOTA) .Or. cStatus == "00"
				If Empty((cAliasSC5)->C5_NOTA)					
					// mostra mensagem no console
					cMsgProc := "Não  foi possivel processar o status [" + cDscStat + "] do pedido E-commerce "+AllTrim(cPedECom)+", pois o pedido no Protheus "+(cAliasSC5)->C5_NUM+" esta com o Status de "+Lj900StrPd((cAliasSC5)->C5_STATUS)
				Else
					// mostra mensagem no console
					cMsgProc := "Não  foi possivel processar o status [" + cDscStat + "] do pedido E-commerce "+AllTrim(cPedECom)+" cujo pedido no Protheus "+(cAliasSC5)->C5_NUM+" já esta com o Documento Fiscal emitido." 
				EndIf	
				
				Lj900XLg( cMsgProc, cPedECom  )

				// próximo pedido		
				Loop
			EndIF						
						
			// Grava dados complementares pedido de venda
			If !Empty(cPedECom)
				MH6->(dbSetOrder(1))	// MH6_FILIAL+MH6_PDECOM
				If MH6->(DbSeek(xFilial("MH6",cFilMGU)+cPedECom))
					MH6->(RecLock("MH6",.F.))
				Else
					MH6->(RecLock("MH6",.T.))
					MH6->MH6_FILIAL := xFilial("MH6",cFilMGU)
					MH6->MH6_PDECOM := cPedECom
				EndIf
				MH6->MH6_STATUS := cStatus
				MH6->MH6_CANORI	:= cCanalOrig
				MH6->MH6_RASTRE	:= SC5->C5_RASTR
				MH6->(MsUnLock())
			EndIf
			
			//Configura a filial do Pedido para a rotina de aprovação e cancelamento
			If lEstLoja
				If !Empty(cFilMGU) .AND. cFilMGU <> cFilAnt
					cFilAnt := cFilMGU
				EndIf
			EndIf
			
			// se o pedido estiver cancelado
			If cStatus == "90" // "status": "Cancelado",
				lRet := LJI9PCAN(cPedECom,_lJob,_cFil,cSeq,;
								 cFilBkp)

			// se o pedido estiver aprovado
			Else  // "status": "aproved",
				// Reposiciona pedido de venda Protheus
				SC5->(DbSetOrder(1))	// C5_FILIAL+C5_NUM
				SC5->(DbGoTo((cAliasSC5)->REGISTRO))

				lRet := LJI9PAPR(cPedECom,_lJob,_cFil,cSeq,;
								cStatus, cFilBkp)
			EndIf

			//Restaura a Filial para a filial de processamento
			If lEstLoja .AND. cFilAnt <> cFilBkp
				cFilAnt := cFilBkp
			EndIf
			
			If lRet
				aAdd( aPedProc, oObjJSon[nX]:id)
			// se o pedido de venda foi cancelado (excluido) com sucesso, excluir também AMARRACAO DADADOS NO CIASHOP  
				If cStatus == "90"
				// deleta amarração de dados 
					MH6->(dbSetOrder(1))	// MH6_FILIAL+MH6_PDECOM
					If MH6->(DbSeek(xFilial("MH6",cFilMGU)+cPedECom))
						MH6->(RecLock("MH6",.F.))
						MH6->(DbDelete())
						MH6->(MsUnLock())
					EndIf
				EndIf
			EndIf
			
		// não foi encontrado o pedido e-commerce na base de dados Protheus	
		Else
			// mostra mensagem no console			
			cMsgProc := "Pedido E-commerce "+AllTrim(cPedECom)+" nao encontrado na base de dados Protheus."
			
			// Grava Log
			Lj900XLg( cMsgProc, cPedECom  )
			
			lRet := .T.
		
		EndIf
		
// pedido e-commerce com status diferente de cancelado/aprovado
	Else
		// mostra mensagem console
		cMsgProc := "Pedido E-commerce "+AllTrim(Str(oObjJSon[nX]:id))+", cujo status "+alltrim(oObjJSon[nX]:status)+" desconsiderado."
		Lj900XLg( cMsgProc, AllTrim(Str(oObjJSon[nX]:id))  )
	EndIf
Next nX
//Envia o Status como processado

If lSendProc
	//Envia a confirmação dos pedidos processados
	 LJI9JSON(cEmpAnt,_cFil,_lJob,cSeq, lSendProc, .T., aPedProc )
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI9PCAN
Função de cancelamento pedido de venda e-commerce CiaShop
@param   	aParam -
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LJI9PCAN()
/*/
//-------------------------------------------------------------------
Static Function LJI9PCAN(cPedECom,_lJob,_cFil,cSeq,;
						cFilBkp)
	
	Local lRet 		:= .F.
	Local cStatAnt	:= ""
	Local cWhere 		:= "" //Condicional da query
	Local cAliasTmp  	:= GetNextAlias() //Alias a consulta
	Local cMsgProc		:= "" //Mensagem de Processamento
	Local aAreaSL1      := SL1->(GetArea())
	Local aAreaSC5     := SC5->(GetArea())
	Local cCodMsg		:= "" //Codigo da Mensage
	Local cMsg			:= "" //
	Local cMsgErro		:= ""
	
	PRIVATE lMsErroAuto := .F.
	
	If lCamposST == NIL
		lCamposST := ( SL1->(ColumnPos("L1_ECSTATU") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECSTATU") > 0 ) ) .AND. ;
				    ( SL1->(ColumnPos("L1_ECRASTR") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECRASTR") > 0 ) )
	EndIf
		
	//Condicional para a query
	cWhere := "%"
	cWhere += " C5_FILIAL = '" + xFilial("SC5") + "'"
	cWhere += " AND C5_PEDECOM = '" + cPedECom + "'"
	cWhere += " AND SC5.D_E_L_E_T_ <> '*'"
	cWhere += " AND L1_FILIAL = '" + xFilial("SL1") + "'"
	cWhere += " AND L1_ECFLAG = '1'"
	cWhere += " AND SL1.D_E_L_E_T_ <> '*'"
	cWhere += "%"
	
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT
		C5_FILIAL, C5_NUM, C5_PEDECOM, C5_STATUS, L1_FILIAL, L1_NUM,
		L1_DOCPED, L1_SERPED, SC5.R_E_C_N_O_ AS C5_REGISTR, SL1.R_E_C_N_O_ AS L1_REGISTR 
		FROM %table:SC5% SC5
		INNER JOIN %table:SL1% SL1
		ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )
		WHERE %exp:cWhere%
	EndSql
	
	BEGIN TRANSACTION
		
		//Posiciona no inicio do arquivo
		(cAliasTmp)->(dbGoTop())
		
		// se orçamento e pedido de venda encontrados
		If (cAliasTmp)->(!Eof()) .And. !Empty(cPedECom)
			
			// posiciona orçamento
			SL1->(DbSetOrder(1))	// L1_FILIAL+L1_NUM
			If SL1->(DbSeek((cAliasTmp)->L1_FILIAL +(cAliasTmp)->L1_NUM))
			
				// Verifica se a reserva foi gravada corretamente no item do orçamento
				cAliasTrc := GetNextAlias()
				cQuery := "SELECT DISTINCT C5_FILIAL, C5_NUM, C5_PEDECOM, "
				cQuery += " C6_FILIAL, C6_NUM, C6_PRODUTO, C6_RESERVA, " 
				cQuery += " L1_FILIAL, L1_NUM, L1_PEDRES, " 
				cQuery += " L2_FILIAL, L2_NUM, L2_PRODUTO, L2_RESERVA, L2_ITEM "
				cQuery += "FROM "+RetSqlName("SC5") + " SC5 "
				cQuery += "INNER JOIN "+RetSqlName("SL1")+ " SL1 "
				cQuery += " ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC) "
				cQuery += "INNER JOIN "+RetSqlName("SL2")+ " SL2 "
				cQuery += " ON L2_FILIAL = L1_FILIAL AND L1_NUM = L2_NUM " 
				cQuery += "INNER JOIN "+RetSqlName("SC6")+ " SC6 "
				cQuery += " ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_PRODUTO = L2_PRODUTO " 
				cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5") + "' "
				cQuery += " AND C6_FILIAL = '"+xFilial("SC6") + "' "
				cQuery += " AND L1_FILIAL = '"+xFilial("SL1") + "'"
				cQuery += " AND L2_FILIAL = '"+xFilial("SL2") + "'"
				cQuery += " AND C5_PEDECOM = '"+cPedECom+"' "
				cQuery += " AND L1_ECFLAG = '1' "
				cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
				cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
				cQuery += " AND SL1.D_E_L_E_T_ <> '*' " 
				cQuery += " AND SL2.D_E_L_E_T_ <> '*' " 

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T., "TOPCONN",  TCGENQRY(,,cQuery) ,cAliasTrc, .F., .T.)
				(cAliasTrc)->(DbGoTop())

				While (cAliasTrc)->(!Eof())
					If Empty((cAliasTrc)->L2_RESERVA) 
						If !Empty((cAliasTrc)->C6_RESERVA)	// !Empty((cAliasTrc)->C9_RESERVA) .Or. !Empty((cAliasTrc)->C6_RESERVA)

							// regrava reserva no item do orçamento
							SL2->(DbSetOrder(1))	// L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
							If SL2->(DbSeek((cAliasTrc)->(L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO)))
								SL2->(RecLock("SL2",.F.))
								SL2->L2_RESERVA := (cAliasTrc)->C6_RESERVA	// Iif( !Empty((cAliasTrc)->C9_RESERVA), (cAliasTrc)->C9_RESERVA, (cAliasTrc)->C6_RESERVA )
								SL2->(MsUnLock())
							EndIf
						EndIf 
					EndIf
					(cAliasTrc)->(DbSkip())
				EndDo
				(cAliasTrc)->(DbCloseArea())
			
				// chama função para exclusão do orçamento
				lRet = lj140ExcOrc( _cFil, (cAliasTmp)->(L1_SERPED+L1_DOCPED),,lCamposST, @cMsgErro )
								
				// se a exclusão do orçamento foi feita com sucesso
				If lRet
				
					cCodMsg		:= "03" //Codigo da Mensage
					cMsg		:= "Pedido Protheus " +(cAliasTmp)->C5_NUM+" e pedido E-Commerce "+AllTrim((cAliasTmp)->C5_PEDECOM)+" executada a exclusão do orçamento "+(cAliasTmp)->L1_DOCPED+" com sucesso. "
					// grava o log de alteração e cancelamento pedido de venda
				// se a exclusão do orçamento falhou
				Else

					cCodMsg		:= "04" //Codigo da Mensage
					cMsg		:= "Pedido Protheus "+(cAliasTmp)->C5_NUM+" e pedido E-Commerce "+AllTrim(+(cAliasTmp)->C5_PEDECOM)+" falha na exclusão do orçamento "+(cAliasTmp)->L1_DOCPED+"."
					DisarmTransaction()					
					Break
				EndIf
				
			// orçamento não encontrado
			Else

				cCodMsg		:= "05" //Codigo da Mensage
				cMsg		:= "Pedido Protheus "+SC5->C5_NUM+" e pedido E-Commerce "+AllTrim(SC5->C5_PEDECOM)+" orçamento não encontrado"+(cAliasTmp)->L1_NUM+"."			
				lRet := .F.

			EndIf

		// se orçamento e pedido de venda não encontrados
		Else
			
			cCodMsg		:= "06" //Codigo da Mensage
			cMsg		:= "Pedido Protheus "+SC5->C5_NUM+" e pedido E-Commerce "+AllTrim((cAliasTmp)->C5_PEDECOM)+" numero do pedido no orçamento não encontrado"+(cAliasTmp)->L1_NUM+"."	
			lRet := .F.		
					
		EndIF
		
	END TRANSACTION
	
	If  lRet .AND. lCamposST .AND. !lAtuLj140
		//Se existir o campo de status e ele não estiver sendo atualizado pelo loja140, marca ele como excluído para não ser enviado novamente
		SET DELETED OFF 
			SL1->(DbgoTo((cAliasTmp)->L1_REGISTR))
			SC5->(DbgoTo((cAliasTmp)->C5_REGISTR))
			If SC5->(!Eof()) .AND. SL1->(!Eof())
				RecLock("SL1", .F.)
				SL1->L1_ECSTATU := SC5->C5_STATUS
				SL1->L1_ECRASTR := SC5->C5_RASTR 
				SL1->L1_PEDRES:= SC5->C5_NUM 
				SL1->(MsUnLock())
			EndIf
		SET DELETED ON
		RestArea(aAreaSL1)
		RestArea(aAreaSC5)
	ElseIf !lRet
		Ljx904ErrE({cMsgErro,  cMsg},nil,"LJI9PCAN",cPedECom ,Nil,Nil)
	EndIf

	Lj900XLg(cMsg, cPedECom)
	

	//Inclui na tabela MH8 (Log Status Ped.Canc./Aprov)
	Lj900AGr("SC5",cSeq,(cAliasTmp)->C5_NUM, cPedECom, ;
		(cAliasTmp)->L1_DOCPED,(cAliasTmp)->L1_SERPED, (cAliasTmp)->L1_NUM, "", ;
		(cAliasTmp)->C5_STATUS, "90", cCodMsg,cMsg,;
		cFilBkp)
				
	
	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI9PAPR
Função de aprovação pedido de venda e-commerce CiaShop
@param   	cPedECom	- Codigo do pedido e-commerce
@param   	_lJob 		- Variavel de informação de Funcionamento em job 
@param   	_cFil 		- Variavel de controle de Filial
@param   	cSeq 		- Sequencia para gravação de dados
@param   	cStatus 	- Status do pedido Retornado pelo Jason
@param   	cFilBkp 	- Filial de Origem para gravação do Log
@author  	Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LJI9PAPR(cPedECom,_lJob,_cFil,cSeq,cStatus)
/*/
//-------------------------------------------------------------------
Static Function LJI9PAPR(cPedECom,_lJob,_cFil,cSeq,;
						cStatus, cFilBkp)
	
Local lRet := .T.
Local cWhere 		:= "" //Condicional da query
Local cAliasTmp  	:= GetNextAlias() //Alias a consulta
Local lGerSE1 		:= SuperGetMv("MV_LJECOMS",.T., .F.)
Local aParamRot		:= {} //Parametros da rotina


PRIVATE lMsErroAuto := .F.


If lCamposST == NIL
	lCamposST := ( SL1->(ColumnPos("L1_ECSTATU") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECSTATU") > 0 ) ) .AND. ;
			    ( SL1->(ColumnPos("L1_ECRASTR") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECRASTR") > 0 ) )
EndIf

//Condicional para a query
cWhere := "%"
cWhere += " C5_FILIAL = '" + xFilial("SC5") + "'"
cWhere += " AND C5_PEDECOM = '" + cPedECom + "'"
cWhere += " AND SC5.D_E_L_E_T_ <> '*'"
cWhere += " AND L1_FILIAL = '" + xFilial("SL1") + "'"
cWhere += " AND L1_ECFLAG = '1'"
cWhere += " AND SL1.D_E_L_E_T_ <> '*' "


//Condicional para a query
If lGerSE1	

	cWhere += " AND SE1.E1_FILIAL  = '"  + xFilial("SE1") + "'"
	cWhere += "%"
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT
		C5_FILIAL, C5_NUM, C5_PEDECOM, L1_FILIAL, L1_NUM, C5_CLIENTE, C5_LOJACLI, C5_STATUS, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO,
		L1_DOCPED, L1_SERPED
		FROM %table:SC5% SC5
		INNER JOIN %table:SL1% SL1
		ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )
		INNER JOIN %table:SE1%  SE1
		ON E1_NUM = L1_DOCPED AND E1_PREFIXO = L1_SERPED		
		WHERE %exp:cWhere%
	EndSql	
Else
	cWhere += "%"		
	//Executa a query
	BeginSql alias cAliasTmp
		SELECT
		C5_FILIAL, C5_NUM, C5_PEDECOM, C5_CLIENTE, C5_LOJACLI, C5_STATUS,L1_DOCPED, L1_SERPED, L1_FILIAL, L1_NUM		
		FROM %table:SC5% SC5
		INNER JOIN %table:SL1% SL1
		ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )				
		WHERE %exp:cWhere%
	EndSql
EndIf	

// Inicia trasacao
BEGIN TRANSACTION
	
	// se o pedido de venda e orçamento encontrados
	If (cAliasTmp)->(!Eof()) .And. !Empty(cPedECom)
			
		// Pesquisa título para baixa
		SE1->(DbSetOrder(1))	// E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO	// SE1->(DbSetOrder(2))	// E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If lGerSE1 .And. !SE1->(DbSeek(xFilial("SE1")+(cAliasTmp)->(L1_SERPED+L1_DOCPED+E1_PARCELA+E1_TIPO)))	// SE1->(DbSeek(xFilial("SE1")+(cAliasTmp)->(C5_CLIENTE+C5_LOJACLI+L1_SERPED+L1_DOCPED) ))
						
			lRet := .F.
			//Inclui na tabela MH8 (Log Status Ped.Canc./Aprov)
			aParamRot := { "SE1",cSeq,(cAliasTmp)->C5_NUM, (cAliasTmp)->C5_PEDECOM, ;
				(cAliasTmp)->L1_DOCPED,(cAliasTmp)->L1_SERPED, "", "", ;
				(cAliasTmp)->C5_STATUS, "", "08","Titulo "+(cAliasTmp)->(C5_CLIENTE+C5_LOJACLI+L1_SERPED+L1_DOCPED)+" não encontrado."}
			
		EndIF
			
		If lRet
			
			// chama função de liberação pedido de venda
			lRet := LJI9LSC5((cAliasTmp),_lJob,cSeq,lGerSE1)
			
			// se o pedido de venda liberado com sucesso
			If lRet
			// grava status de aprovado
				SC5->(RECLOCK("SC5",.F.))
				SC5->C5_STATUS := cStatus 
				SC5->(MsUnLock())
				
				//Marca o Status como liberado para não ser enviado novamente por webservice
				SL1->(DbSetOrder(1)) // L1_FILIAL + L1_NUM
				If lCamposST .AND. SL1->(DbSeek((cAliasTmp)->L1_FILIAL+(cAliasTmp)->L1_NUM)) 
					RecLock("SL1", .F.)
					SL1->L1_ECSTATU := cStatus
					SL1->L1_ECRASTR := SC5->C5_RASTR 
					SL1->(MsUnLock())
				EndIf
				
				//Gera os parametros de log para Inclui na tabela MH8 (Log Status Ped.Canc./Aprov)
				aParamRot := {"SC5",cSeq,(cAliasTmp)->C5_NUM	,(cAliasTmp)->C5_PEDECOM		,;
						 (cAliasTmp)->L1_DOCPED,(cAliasTmp)->L1_SERPED,"","",;
						 (cAliasTmp)->C5_STATUS,"","09","Pedido de venda "+(cAliasTmp)->C5_NUM+" com pedido e-commerce "+AllTrim((cAliasTmp)->C5_PEDECOM)+" aprovado e liberado! "}
			
			// pedido de venda não liberado	
			Else

				//Gera os parametros de log para Inclui na tabela MH8 (Log Status Ped.Canc./Aprov)
				aParamRot := {"SC5",cSeq,(cAliasTmp)->C5_NUM, (cAliasTmp)->C5_PEDECOM	,;
							  (cAliasTmp)->L1_DOCPED,(cAliasTmp)->L1_SERPED,"","",;
							  (cAliasTmp)->C5_STATUS,"","10", "Erro na aprovação/liberação do pedido de venda "+(cAliasTmp)->C5_NUM+" com pedido e-commerce "+AllTrim((cAliasTmp)->C5_PEDECOM)+"."}
			EndIf
			
		EndIf
	// pedido de venda e orçamentos não encontrados		
	Else
			
			lRet := .F.
			
			//Gera os parametros de log para para incluir na tabela MH8 (Log Status Ped.Canc./Aprov)
			aParamRot := {"SC5",cSeq,SC5->C5_NUM, cPedECom, ;
						(cAliasTmp)->L1_DOCPED,(cAliasTmp)->L1_SERPED, (cAliasTmp)->L1_NUM, "", ;
						SC5->C5_STATUS, "90", "06","Pedido Protheus "+SC5->C5_NUM+" e pedido E-Commerce "+AllTrim(+SC5->C5_PEDECOM)+" numero do pedido no orçamento não encontrado"+(cAliasTmp)->L1_NUM+"."}
			
	EndIf
		
	// caso ocorram erros 
	If !lRet
		DisarmTransaction()
		Break
	EndIf
	
END TRANSACTION

//Grava o Log do Processamento
//
If  Len(aParamRot) >= 12
	Lj900XLg(aParamRot[12], aParamRot[04])
	Lj900AGr(aParamRot[01], aParamRot[02], aParamRot[03], aParamRot[04],;
			 aParamRot[05], aParamRot[06], aParamRot[07], aParamRot[08],;
			 aParamRot[09], aParamRot[10], aParamRot[11], aParamRot[12],;
			 cFilBkp)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI9JSON
Função de retorno pedido de venda e-commerce CiaShop
@param   	aParam - Codigo da empresa, Filial e se execução é em job (.t./.f.)
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LJI9JSON()
/*/
//-------------------------------------------------------------------
Function LJI9JSON(cEmp_lj,cFil_lj,_lJob,cSequenc, lSendProc, lAtuProc, aPedProc)
	
Local oObjJSon 		:= ""
Local _cUrl			:= ""
Local cRetorno 		:= ""
Local cGetParms 	:= ""
Local nTimeOut 		:= 200	// seguntos
Local aHeadStr 		:= {}	// {"Content-Type: application/json"}
Local cHeaderGet 	:= ""
Local cUpdateAt		:= Left(Dtos(dDataBase),4)+"-"+SubStr(Dtos(dDataBase),5,2)+"-"+Right(Dtos(dDataBase),2)	// "updatedAt": "2015-03-10T11:25:26-03:00"
Local cMsgErro		:= ""
Local nDiasRetr		:= SuperGetMV("MV_LJECDIR",,0)	// Numero de dias a retroceder na data de processamento dos pedidos de venda CiaShop aprovados/cancelados
Local lAlsSLJ		:= SLJ->(ColumnPos("LJ_TOKEN") > 0 )
Local cUrlCiaSh   	:= ""
Local cToken        := ""
Local aUrlToken     := {}  // Retorno da Função para a Url e a String do Token
Local cSeq       	:= ""	//Sequencia de Execução da Rotina
Local dDataIni 		:= Date() //Data Inicial do Job
Local cHoraIni 		:= Time() //Hora Inicial do Job
Local cPostPar		:= "" //Parametros do Post
Local cRetLog		:= ""
Local oNodeProc		:= NIL //Verifica se o Node processado existe
Local lSendCom		:= .f. //Envia comando
Local oResult		:= {}

Default cEmp_lj  := cEmpAnt
Default cFil_lj  := cFilAnt 
Default _lJob    := .F.
Default cSequenc := ""
Default lAtuProc := .F. //Atualiza processado?
Default aPedProc  := {}
                            
If !lAlsSLJ
	cMsgErro := STR0017 + AllTrim(cFil_lj)+"." + chr(13) + chr(10)	// "Tabela SLJ - Identificacao de Lojas com Token inexistente para filial corrente."
Else


	If ExistFunc("LOJX904CUT")
		aUrlToken  	:= LOJX904CUT(cEmp_lj,cFil_lj)
		cUrlCiaSh   := aUrlToken[1]
		cToken      := aUrlToken[2]
	EndIf	
	

	If !Empty(cToken)
		aadd(aHeadStr,"Authorization: Bearer " + cToken)	
		aadd(aHeadStr,"Content-Type: application/json")

		If !lAtuProc		
		// posiciona tabela token filial
	
						
			// Retrocede data de acordo com o número de dias
			If nDiasRetr > 0
				cUpdateAt	:= Left(Dtos(dDataBase-nDiasRetr),4)+"-"+SubStr(Dtos(dDataBase-nDiasRetr),5,2)+"-"+Right(Dtos(dDataBase-nDiasRetr),2)		
			EndIf					
		   
		   cPostPar := "?minupdatedAt=" + cUpdateAt + "&fields=id,createdAt,updatedA,sourcechannel,status,statusProcessed&status[]=PaymentApproved&status[]=Cancelled&statusProcessed=false&limit=250"
	
			
	
			_cUrl := AllTrim(cUrlCiaSh)+"/api/v1/orders/" + cPostPar  //_cUrl := "https://"+AllTrim(SLJ->LJ_URL)+"/api/v1/orders/?minUpdatedAt="+cUpdateAt
			cRetLog  := "Get Method " + _cUrl 
			
			// lê retorno da GET da api
			cRetorno	:=	HttpGet( _cUrl , cGetParms , nTimeOut , aHeadStr , @cHeaderGet )
			cRetLog  +=  CRLF + "Result " + IIF( !Empty(cRetorno), cRetorno, "") + CRLF
			
			lSendCom := .T.
			
		ElseIf Len(aPedProc) > 0
			_cUrl := AllTrim(cUrlCiaSh)+ "/api/v1/orders/statusProcessed"	//Caso o método não exista não faz dar erro de post		

			
			cPostParms := FWJsonSerialize(aPedProc)
			
			cRetLog  :=  "Post Method " + _cUrl  + CRLF + "Post Params " + cPostParms + CRLF
			
			cRetorno	:=	HttpPost( _cUrl , cGetParms , cPostParms, nTimeOut , aHeadStr , @cHeaderGet )
			cRetLog  += CRLF + "Result " + IIF( !Empty(cRetorno), cRetorno, "") + CRLF		
			
			lSendCom := .t.
	
		ElseIf Len(aPedProc) = 0
			cMsgErro := "Não existem pedidos para enviar a confirmação"
			cRetLog  += "Result " + cMsgErro + CRLF			
		EndIf
		
		If lSendCom
		
			// se ocorreu errp no retorno no Get/Post d da api
			If  HTTPGetStatus() <> 200  .AND.  !(HTTPGetStatus() = 404 .AND. lAtuProc)
				cMsgErro := STR0008 + "Status: "+Alltrim(Str(HTTPGetStatus()))	// "Falha na conexão com o e-commerce CiaShop. Verifique a chave de acesso Token e/ou Url cadastrados"
			Else
				If HTTPGetStatus() = 404 .AND. lAtuProc
					cMsgErro := "Método POST " + "/api/v1/orders/statusProcessed"  + " não implementado na loja. Entre em contato com suporte do e-commerce e solicite atualização da loja virtual para habilitar este método que não permite que um pedido que já tenha o status processado na loja seja processado novamente na integração " +  CRLF + "Http Status: "+Alltrim(Str(HTTPGetStatus()))	// "Falha na conexão com o e-commerce CiaShop. Verifique a chave de acesso Token e/ou Url cadastrados"
					cRetLog  += CRLF + cMsgErro
				Else
				
					
					// deseraliza e teste o JSon de retorno
					If ( !lAtuProc  .OR. !Empty(cRetorno) ).AND. !FWJsonDeserialize(cRetorno,@oObjJSon)
						cMsgErro :=  STR0009 + chr(13) + chr(10)	// "Erro no processamento do JSon"
						cRetLog += CRLF + cMsgErro
					Else
						If !lAtuProc  .AND. ValType(oObjJSon) == "A"
							If Len(oObjJSon) == 0
								cMsgErro := STR0027 + dtoc(dDataBase)+"." + chr(13) + chr(10)	// "Não existe(m) pedido(s) com os status de Pagamento Aprovado ou Cancelado para serem processados pelo ERP no dia "
								cRetLog += CRLF + cMsgErro
							Else
	
								lSendProc := .T.
							EndIf
						EndIf
					EndIf
				EndIf
	
			EndIf
		EndIf

	Else
		cMsgErro := STR0011 + AllTrim(cFil_lj)+"." + chr(13) + chr(10)	// "Token não cadastrado para filial corrente "
	EndIf
EndIf

If !Empty(cMsgErro)
	If !lAtuProc .AND. !_lJob
		MsgAlert(cMsgErro)
	EndIf
	
	// Grava Log
	Lj900XLg(cMsgErro)
	
EndIf

If !lAtuProc	
	//Resultado da sincronização
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()
	
	// EC CIASHOP RESULT SINCRONIZACAO
	dbSelectArea("MGM")
	RECLOCK("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC  := "LOJA901I"
	MGM->MGM_SEQ     := cSeq
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni
	MGM->MGM_XMLENV  := "" // cXML
	MGM->MGM_XMLRET  := cRetLog
	MGM->MGM_HORAFI  := Time()
	If Empty(cMsgErro)
		MGM->MGM_RESULT := "1"	// 1=Sucesso;2=Erro
	Else
		MGM->MGM_RESULT  := "2"
	EndIf
	MGM->(MsUnLock())
	
	cSequenc := cSeq
Else
	MGM->(DbSetOrder(1)) //MGM_FILIAL + MGM_SERVIC + MGM_SEQ
	If MGM->(DbSeek( xFilial("MGM") + PadR( "LOJA901I" , TamSx3("MGM_SERVIC")[1]) + cSequenc))
		RecLock("MGM", .F.)
		MGM->MGM_XMLRET  := MGM->MGM_XMLRET + cRetLog
		MGM->(MsUnLock())
	EndIf
EndIf
Return(oObjJSon)

//-------------------------------------------------------------------
/*/{Protheus.doc} LJI9LSC5
Função de liberação do pedido de venda na aprovação do pedido de venda e-commerce CiaShop
@param   	cAliasTmp - Alias com as informações do pedido
@param   	_lJob 	  - variavel para saber se a rotina esta rodando em job
@param   	cSeq 	  - Numero de controlde de sequencia
@param   	lGerSE1   - Controle de geração de financeiro.
@author  	Varejo
@version 	P11.8
@since   	07/08/2016
@obs
@sample LJI9LSC5()
/*/
//-------------------------------------------------------------------
Static Function LJI9LSC5(cAliasTmp,_lJob,cSeq,lGerSE1)
	
Local lRet := .T.
Local aCabec := {}
Local cLogPath :=  SuperGetMV("MV_LOGPATH",,"LOGS")
Local nVlrLiber := 0
Local aRegSC6   := {}

Private lMsErroAuto := .F.

Aadd(aCabec,{"C5_FILIAL",(cAliasTmp)->C5_FILIAL,NIL })
aadd(aCabec,{"C5_NUM"   ,(cAliasTmp)->C5_NUM,Nil})

SC6->(DbSetOrder(1))	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SC6->(DbSeek(xFilial("SC6")+(cAliasTmp)->C5_NUM))

nValTot := 0

While !SC6->(Eof()) .AND. (cAliasTmp)->C5_FILIAL + (cAliasTmp)->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
	nValTot += SC6->C6_VALOR
	
	dbSelectArea("SF4")
	dBSetOrder(1)
	MsSeek( xFilial("SF4") + SC6->C6_TES )
	
	If SC5->(RecLock("SC5",.F.))
		nQtdLib := Iif(SC6->C6_QTDLIB ==0,SC6->C6_QTDVEN,SC6->C6_QTDLIB)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recalcula a Quantidade Liberada                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC6->(RecLock("SC6",.F.)) //Forca a atualizacao do Buffer no Top
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Libera por Item de Pedido                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			SC6->C6_QTDLIB := Iif(SC6->C6_QTDLIB ==0,SC6->C6_QTDVEN,SC6->C6_QTDLIB) // caso a quantidade liberada esteja 0 replicamos para poder realizar a liberação
			SC9->(DbSetOrder(1))
			If SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
				nVlrLiber := SC6->C6_VALOR
				aadd(aRegSC6,SC6->(RecNo()))
				dbSelectArea("SC5")
				dbSetOrder(1)
				dbSeek(xFilial("SC5") + SC6->C6_NUM )
				//Caso possuir o chamo a função de validação de caberacio do pedido de venda
				MaAvalSC5("SC5",3,.F.,.F.,,,,,,SC9->C9_PEDIDO,aRegSC6,.T.,.F.,@nVlrLiber)		
				If lGerSE1
					// A liberação do credito é forçada pois o pagamento já foi realizado. Vide loja861			
					RecLock("SC9",.F.)
					SC9->C9_BLCRED	:= " "
					SC9->(MsUnlock())										
				EndIf
			Else						
				//Liberação do Credito/estoque do pedido de venda mais informações ver fatxfun 
				MaLibDoFat(SC6->(RecNo()),nQtdLib,.T.,.T.,.F.,.F.,.F.,.F.)	
			EndIf 											
			
		End Transaction
	EndIf
	
	SC5->(MsUnLock())
	SC6->(MsUnLock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o Flag do Pedido de Venda                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SC6->(dbSkip())
End

//---------------------------------------------------------------------------
//     Verifica se existe bloqueio de crédito ou estoque, se existir desbloqueia
//---------------------------------------------------------------------------
MaLiberOk( { SC6->C6_NUM } )
SC5->(DbSeek(xFilial("SC5")+(cAliasTmp)->C5_NUM))
If !lMsErroAuto
	Lj900XLg(STR0014, (cAliasTmp)->C5_PEDECOM)	// "Liberação com sucesso! "
Else
	Lj900XLg(STR0015, (cAliasTmp)->C5_PEDECOM)		// "Erro na LIBERAÇÃO!"
	MostraErro(cLogPath+(cAliasTmp)->C5_PEDECOM)
	lRet := .F.
EndIf

If lRet
	// grava o log de alteração e cancelamento pedido de venda
	Lj900XLg("Status do pedido Protheus" +SC5->C5_NUM+" e pedido E-Commerce "+(cAliasTmp)->C5_PEDECOM+" aprovado e liberado para faturamento. ",(cAliasTmp)->C5_PEDECOM)
Else
	// grava o log de alteração e cancelamento pedido de venda
	Lj900XLg("Alteração de status e exclusão do pedido Protheus "+SC5->C5_NUM+" e pedido E-Commerce "+(cAliasTmp)->C5_PEDECOM+" não puderam ser aprovado e liberado para faturamento. ",(cAliasTmp)->C5_PEDECOM)
	
	DisarmTransaction()	
	
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900AGr
Grava os dados enviados
@param   	cAlias - Alias da Consulta
@param   	cSeq- Execução em Job - Default .f.
@param   	nVlrNorm- Valor do Produto
@param   	nVlrDesc - Valor do Desconto
@param   	cVarDes - Descricao da Variante
@param   	cVarVal - Valor da Variante
@param   	cVarDes2 - Descricao da 2 variante
@param   	cVarVal2 - Valor da 2 variante
@param   	cImgFile - Arquivo de Imagem
@param   	cTitulo - Titulo
@param   	cVarAtiva- Variavel ativa
@param		cMotErr - Motivo do Erro
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs
@sample Lj900AGr(cAlias,cSeq,cPedProt, cPedEcom,;
		cDocPed, cSerPed, cNumOrc, cProd, ;
		cStaProt, cStatCiaSh, cMotErr,;
		cDescMot )
/*/
//-------------------------------------------------------------------
Static Function Lj900AGr(cAlias,cSeq,cPedProt, cPedEcom,;
		cDocPed, cSerPed, cNumOrc, cProd, ;
		cStaProt, cStatCiaSh, cMotErr, cDescMot,;
		cFilBkp )
		
Local lAlsMH8		:= AliasInDic("MH8")
Local cFilAnt2		:= cFilAnt



If lAlsMH8
	If Empty(cMH8Chave)
		cMH8Chave := FwX2Unico('MH8')
	EndIf	
	If lMH8_NUM = NIL 
		lMH8_NUM := MH8->(ColumnPos("MH8_NUM")) > 0
	EndIf
	If  lMH8_MOTIVO = NIL
		lMH8_MOTIVO := MH8->(ColumnPos("MH8_MOTIVO")) > 0
	EndIf
	If lMH8_ORCAME = NIL
		lMH8_ORCAME := MH8->(ColumnPos("MH8_ORCAME")) > 0
	EndIf
	
	If !Empty(cFilBkp) .AND.  cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	EndIf
	
	If !Empty(cMH8Chave) .And.  !"MH8_NUM" $ cMH8Chave
		cSeq := GETSXENUM("MH8","MH8_SEQ")
		CONFIRMSX8()		
		MH8->(DbSetOrder(1))
		While MH8->(DbSeek(xFilial("MH8") + cSeq ))
			cSeq := GETSXENUM("MH8","MH8_SEQ")
			CONFIRMSX8()				
		End 		 		
	EndIf
	
		RecLock("MH8", .T.)
		MH8->MH8_FILIAL  	:= xFilial("MH8")
		MH8->MH8_SEQ     	:= cSeq
		MH8->MH8_PEDECO	:= cPedEcom
		MH8->MH8_DOCPED	:= cDocPed
		MH8->MH8_SERPED	:= cSerPed
		MH8->MH8_PRODUT	:= cProd
		MH8->MH8_STAPRO	:= cStaProt
		MH8->MH8_STACIA	:= cStatCiaSh
		MH8->MH8_DESMOT	:= cDescMot
		If lMH8_NUM
			MH8->MH8_NUM		:= cPedProt
		EndIf	
		If lMH8_MOTIVO
			MH8->MH8_MOTIVO	:= cMotErr
		EndIf
		If lMH8_ORCAME
			MH8->MH8_ORCAME	:= cNumOrc
		EndIf
		MH8->(MsUnLock())
		
		If !Empty(cFilBkp) .AND.  cFilBkp <> cFilAnt2
			cFilAnt := cFilAnt2
		EndIf
Else 
	Lj900XLg(STR0018 + AllTrim(_cFil) + ".")	// "Tabela MH8 - EC CIASHOP LOG STA.PED.CAN.APR inexistente para filial corrente."
EndIf
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CodPd
      Recebe o Status como String e gera o codigo   
@param   	cStatus - Descritivo do Status para ser Retornado o Codigo.
@author  	Varejo
@version 	P11.8
@since   	11/04/2017
@obs
@sample Lj900CodPd(cStatus)
/*/
//-------------------------------------------------------------------
Static Function Lj900CodPd(cStatus)
Local cRet 		  := ""
Local cStatusPed  := SuperGetMv("MV_LJECST1",.F., "30")

Default cStatus := ""
/*/ 
-1=Volta passo
05=Em analise
10=Pagamento confirmado
15=Embalado
21=Parcialmente enviado
30=Enviado
90=cancelado
91=Devolvido
/*/
If !Empty(cStatus)
	cStatus := AllTrim(Upper(cStatus))
	Do Case
		Case cStatus == "CANCELLED" //CANCELADO
			cRet := "90"
		Case cStatus == "DELIVERED" // Entregue
			cRet := "30"
		Case cStatus == "PARTIALLYSHIPPED" //Parcialmente Enviado
			cRet := "30"
		Case cStatus == "SHIPPED"  //Enviado
			cRet := "30"
		Case cStatus == "PACKAGED" //Epacotado
			cRet := AllTrim(cStatusPed)
		Case cStatus == "PAYMENTAPPROVED" //Pagamento Aprovado
			cRet := "10"
		Case cStatus == "SENTTOANALYSIS" //Em analise
			cRet := "00"
		Case cStatus == "CONFIRMED"  //CONFIRMADO
			cRet := "00"
		Case cStatus == "RESERVED"  //Reservado
			cRet := "00"						
		Otherwise
			cRet := ""
	EndCase	
EndIf

Return(cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900StrPd
      Recebe o codigo de Status e gera o codigo   
@param   	cStatus - Codigo do Erro
@author  	Varejo
@version 	P11.8
@since   	11/04/2017
@obs
@sample Lj900StrPd(cStatus)
/*/
//-------------------------------------------------------------------
Static Function Lj900StrPd(cStatus)
Local cRet		:= ""

Default cStatus := ""

If !Empty(cStatus)
	Do Case
		Case cStatus == "90" 
			cRet := STR0021  //"Cancelado"
		Case cStatus == "30" 
			cRet := STR0022 //"Enviado"		
		Case cStatus == "15" 
			cRet := STR0023 //"Empacotado"
		Case cStatus == "10" 
			cRet := STR0024 //"Pagamento Aprovado"		
		Case cStatus == "00"  
			cRet := STR0025 //"Pedido Gerado"								
		Otherwise
			cRet := ""
	EndCase
EndIf
	
Return(cRet)