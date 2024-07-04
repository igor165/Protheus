#INCLUDE "CNTA260.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#INCLUDE "GCTXDEF.CH"

//-- alteração para permitir carregar model
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE DEF_SVIGE "05" //Vigente

Static xCompet	:= ""
Static lCN260OBRIG	:= ExistBlock("CN260OBRIG")

/*/{Protheus.doc} CNTA260
Rotina responsavel pela execucao das medicoes de contratos do tipo automatico
@author Marcelo Custodio
@since 28/07/2006
@return lRet, ${return_description}
@param cCodEmp, characters, Codigo da Empresa
@param cCodFil, characters, Codigo da Filial
@param cInterval, characters, Intervalo entre as execucoes(HH:MM)
@type function
/*/
Main Function CNTA260(cCodEmp,cCodFil,cInterval)
	Local lRet 		:= .T.
	Local cEmpCod	:= ""
	Local cFilCod	:= ""	
	Default cCodEmp	:= IIF(Type('cEmpAnt') != 'U',cEmpAnt,"")
	Default cCodFil	:= IIF(Type('cFilAnt') != 'U',cFilAnt,"")
	Default cInterval	:= ""			//Mantido para compatibilidade com versões anteriores.
	
	PRIVATE lMsErroAuto := .F.
	
	//-- Verifica se a rotina e executada atraves de um JOB
	If GetRemoteType() == -1		  //-- Execucao por JOB
		If ValType(cCodEmp) == "A"
			cEmpCod := cCodEmp[1]
			cFilCod := cCodEmp[2]
		Else
			cEmpCod := cCodEmp
			cFilCod := cCodFil
		Endif	
	
		If Empty(cEmpCod) .Or. Empty(cFilCod)
			lRet := .F.
			C260LogMsg('CNTA260 ERROR - Param Error')
		Else
			RpcSetType(3)
			RpcSetEnv(cEmpCod,cFilCod,,,"GCT","CNTA260",{'CN9','CNA','CNB','CND','CNE'})			
			lRet := !CN260Exc(.T.)
			RpcClearEnv()
		EndIf
	ElseIf( Aviso("CNTA260", STR0015,{STR0017, STR0016}) == 1 )//-- Execucao por Menu					
		Processa( {|| CN260Exc(.F.) } )
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    CN260Exc Autor Marcelo Custodio      Data28.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao Executa medicoes pendentes para os contratos automaticos  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   CN260Exc(lExp01)                                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ParametroslExp01 - Executado pelo job                               ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN260Exc(lJob)	
	Local dData    := IIF(lJob,Date(),dDataBase)//Data Atual
	Local cTxLog   := ""//Texto do log
	Local lFail    := .F.
	Local lQuery   := .F.
	Local cArqTrb
	Local nX         := 0	
	Local aQuebraThr := {}	
	Local nThreads   := SuperGetMv('MV_CT260TH',.F.,0) //parametro utilizado para informar o numero de threads para o processamento.
	Local lCnta121   := GetNewPar('MV_CT26021',	.F.) //Parametro diz se deve usar exclusivamente o CNTA121 ou nao
	Local aErros	:= {}
	Local aMedicao	:= {}
	local cMsgErro	:= ""
	Local nLinha	:= 0
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile	:= .T.

	//Valida se o sistema foi atualizado   	
	If !lCnta121

		//Gera historico                       	
		cTxLog := STR0018+" - "+DTOC(dData)+" - "+time()+CHR(13)+CHR(10)//"Log de execucao das medicoes automaticas"
		cTxLog += Replicate("-",128)+CHR(13)+CHR(10)		
	
		C260LogMsg(STR0001)//"Verificando medições pendentes"
		C260LogMsg(STR0002 + time())

		If !lJob
			CN240SVld(.T.) // Ativar a variavel estatica para validar acesso de usuário			
			IncProc(STR0001 + " - " + DTOC(dData))
		EndIf
			
		cArqTrb := GetQryTrb(dData, .F., .T.)
		
		If nThreads > 0			
			aQuebraThr := CN260QtdThr(cArqTrb,nThreads)
			ExecByThread(aQuebraThr[1], aQuebraThr[2], .F., @cTxLog, lJob)
		Else
			CN9->(DbSetOrder(1))			
			
			While !(cArqTrb)->(Eof())				
				lQuery := .T.
				
				aMedicao := GetArrCtr(cArqTrb)//Transforma a posicao atual de <cArqTrb> em um array
				
				IncEEncMed(aMedicao, aErros, @cTxLog, lJob)//Inclui e encerra a medicao				
		
				(cArqTrb)->(dbSkip())
			EndDo
		EndIf		
		(cArqTrb)->(dbCloseArea())
	
		If(Len(aErros) == 0)			
			C260LogMsg(STR0013 + time())			
			cTxLog += STR0013 + time()
		Else
			C260LogMsg(STR0014)
			If !lJob			
				nLinha := 3 //Posicao que contem o numero do contrato
				for nX:= nLinha to Len(aErros)
					cMsgErro += SUBSTR(AllTrim(aErros[nlinha][1]), 17, 15) + " / "
					nX := nLinha + 9
					nLinha := nLinha + 9
				Next nX	

				Help(" ",1,"A260VLDDATA",, STR0004+": " + SUBSTR(cMsgErro, 1, Len(cMsgErro)-2 ) + Chr(13)+Chr(10)+Chr(13)+Chr(10) + STR0024 + Chr(13) + Chr(10) + STR0025,1,1)
				FwFreeArray(aErros)
			EndIf
			lFail := .T.
			cTxLog += STR0014
		EndIf
				
		//Executa ponto de entrada apos a gravacao da medição automática
		If ExistBlock("CNT260GRV")
			ExecBlock("CNT260GRV",.F.,.F.)
		EndIf
		
		If lQuery		
			//Executa gravacao do arquivo de historico		
			MemoWrite(Criatrab(,.f.)+".LOG",cTxLog)
			
			//Emite alerta com o log do processamento		
			MEnviaMail("041",{cTxLog})
		EndIf	
	EndIf
	
	//-- Incluir medição automatica de contratos recorrentes pela rotina CNTA121
	CN260Exc121(lJob, lCnta121)
Return lFail

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    CN260Exc_121 Autor Marcelo Custodio      Data28.07.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao Executa medicoes pendentes para os contratos automaticos  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   CN260Exc_121(lExp01)                                          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ParametroslExp01 - Executado pelo job                               ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador Data   BOPS  Motivo da Alteracao                    ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±                                                               ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CN260Exc121(lJob, lProcTdsMd)
	Local aArea			:= GetArea()
	Local aSaveLines	:= FwSaveRows()
	Local oModel 		:= Nil
	Local cTxLog   		:= ""//Texto do log
	Local cArqTrb
	Local cCompet		:= ""
	Local lContinua	:= .T.
	Local lFail    	:= .F.
	Local lQuery 	:= .F.
	Local dData    	:= If(lJob,date(),dDataBase)//Data Atual
	Local cQuebra	:= ""	
	Local nLinha	:= 0
	Local oMedIndex	:= THashMap():New()
	Local aMedicoes	:= {}
	Local aMedTheads:= {}
	Local nPlanPos	:= 0
	Local aTabStruct:= {}
	Local nX		:= 0
	Local oTemp		:= Nil
	Local aQuebraThr:= {}
	Local nThreads  := SuperGetMv('MV_CT260TH',.F.,0) //parametro utilizado para informar o numero de threads para o processamento.

	Default lProcTdsMd	:= SuperGetMv('MV_CT26021',.F., .F.) //Parametro diz se deve usar exclusivamente o CNTA121 ou nao

	//-- Gera historico
	cTxLog := STR0018+" - "+DTOC(dData)+" - "+time()+CHR(13)+CHR(10)//"Log de execucao das medicoes automaticas"
	cTxLog += Replicate("-",128)+CHR(13)+CHR(10)

	//-- Valida se o sistema foi atualizado
	If lContinua
		C260LogMsg(STR0001)//"Verificando medições pendentes"
		C260LogMsg(STR0002 + time())
		
		If !lJob
			ProcRegua(3)//Consulta/Processa/Concluir
			IncProc(STR0001 + " - " + DTOC(dData))
		EndIf

		cArqTrb := GetQryTrb( dData, .T., lProcTdsMd)//Filtra parcelas de contratos automaticos pendentes para a data atual

		aTabStruct := (cArqTrb)->(DbStruct())
		for nX := 1 to Len(aTabStruct)
			aAdd(aTabStruct[nX], (cArqTrb)->(FieldPos(aTabStruct[nX,1])) )
		next nX
		
		While !(cArqTrb)->(Eof())
			If !lQuery
				lQuery := .T.
			EndIf
			
			If (AllTrim((cArqTrb)->CNF_CONTRA) == "RECORRENTE")
				//-- Quando possui recorrente não possui CNF, ela é obtida da data da próxima medição que esta na CNA.
				cCompet	:= GetCompDt(Stod((cArqTrb)->CNF_COMPET))
			Else
				cCompet	:= AllTrim((cArqTrb)->CNF_COMPET)
			EndIf
			
			cQuebra := (cArqTrb)->( CN9_FILIAL + CN9_NUMERO ) + cCompet

			If oMedIndex:Get(cQuebra, @nLinha)
				oTemp := aMedicoes[nLinha]				
				
				nPlanPos := aScan(oTemp["planilhas"], {|x| AllTrim(x) == AllTrim((cArqTrb)->CNA_NUMERO) })

				If !(nPlanPos > 0)
					aAdd(oTemp["planilhas"], AllTrim((cArqTrb)->CNA_NUMERO))
				EndIf			
			Else
				oTemp := GetObjJs(cArqTrb, aTabStruct) //Obtem um objeto Json com os dados
				oTemp["compet"] := cCompet
				aAdd(oTemp["planilhas"], AllTrim((cArqTrb)->CNA_NUMERO))
				aAdd(aMedicoes, oTemp)			
				oMedIndex:Set(cQuebra, Len(aMedicoes))
			EndIf		
			(cArqTrb)->(dbSkip())		
		EndDo
		(cArqTrb)->(dbCloseArea())		

		If !Empty(aMedicoes)
			If !lJob
				IncProc(STR0026)//Inserindo/Encerrando medições.
			EndIf

			If nThreads > 0 .And. !FwIsInCallStack("CNTA260JOB")
				aMedTheads := ConvJsToC(aMedicoes) /*Essa conversão é necessaria puramente pq a função StartJob não aceita objetos*/
				aQuebraThr := CN260QtdThr(/**/,nThreads, aMedTheads)
				ExecByThread(aQuebraThr[1], aQuebraThr[2], .T.,/*cTxtLog*/, lJob)
			Else //Nesse caso, processa tudo na thread corrente				
				oModel := FWLoadModel("CNTA121")
				IncEnc121(oModel, aMedicoes, lJob)
			EndIf

			aEval(aMedicoes, {|x| FreeObj(x) })
			FwFreeArray(aMedicoes)

			If !lJob
				IncProc(STR0027)//"Processo concluido"
			EndIf			
		EndIf
	Else
		C260LogMsg(STR0014)
		
		If !lJob
			Aviso("CNTA260",STR0014,{"Ok"})
		EndIf
		lFail := .T.
		cTxLog += STR0014
	EndIf

	If lQuery		
		MemoWrite(Criatrab(,.f.)+".LOG",cTxLog)//--  Executa gravacao do arquivo de historico		
		MEnviaMail("041",{cTxLog})//-- Emite alerta com o log do processamento
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)

	oMedIndex:Clean()
	FreeObj(oMedIndex)
	FwFreeArray(aTabStruct)
Return lFail

//-------------------------------------------------------------------
/*/{Protheus.doc} A260GComp()
Função para recuperar a variavel estatica xCompet
@author rogerio.melonio
@since 01/09/2015
/*/
//-------------------------------------------------------------------
Function A260GComp()
Return xCompet

//-------------------------------------------------------------------
/*/{Protheus.doc} A260SComp()
Função para Atribuir na variavel estatica xCompet
@author rogerio.melonio
@since 01/09/2015
/*/
//-------------------------------------------------------------------
Function A260SComp(cValue)
xCompet := cValue
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CN260QtdThr()
Funcao utilizada para calcular a quantidade de threads a serem 
executadas em paralelo.
@author janaina.jesus
@since 21/06/2018
@version 1.0
@return aThreads
/*/
//-------------------------------------------------------------------
Static Function CN260QtdThr(cArqTrb,nThreads, aContratos as array)
Local aAreaAnt   := GetArea()
Local aThreads   := {}
Local nX         := 0
Local nInicio    := 0
Local nRegProc   := 0
Default aContratos := {}

If Empty(aContratos) .And. Select(cArqTrb) > 0
	//-- Carrega Array com os contratos
	Do While (cArqTrb)->(!Eof())
		aAdd(aContratos, GetArrCtr(cArqTrb))
		
		(cArqTrb)->(dbSkip())			
	EndDo
EndIf

nThreads := Min(nThreads,40)//-- Verifica Limite Maximo de 40 Threads

//-- Analisa a quantidade de Threads X nRegistros
If Len(aContratos) == 0
	aThreads := {}
ElseIf Len(aContratos) < nThreads
	aThreads := ARRAY(1)			// Processa somente em uma thread
Else
	aThreads := ARRAY(nThreads)		// Processa com o numero de threads informada
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Calcula o registro original de cada thread e    
//aciona thread gerando arquivo de fila.          
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:=1 to Len(aThreads)

	aThreads[nX]:={"","",1}
    
	// Registro inicial para processamento
	nInicio  := IIf( nX == 1 , 1 , aThreads[nX-1,3]+1 )

	// Quantidade de registros a processar
	nRegProc += IIf( nX == Len(aThreads) , Len(aContratos) - nRegProc, Int(Len(aContratos)/Len(aThreads)) )
	
	aThreads[nX,1] := nInicio
	aThreads[nX,2] := nRegProc
	aThreads[nX,3] := nRegProc

Next nX

RestArea(aAreaAnt)
Return {aThreads,aContratos}

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA260JOB()
Funcao utilizada realizar gerar/encerrar medições por JOB (PERFORMANCE)
@author Janaina.Jesus
@since 21/06/2018
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function CNTA260JOB(aThread,aContratos,cJobFile,cThread,cArqTrb, aParams)
Local nI         := 0
Local cEmp       := aParams[1]
Local cFil       := aParams[2]
Local xData      := aParams[3]
Local cTxLog     := aParams[6]
Local lJob       := aParams[9]
Local lCNTA121   := aParams[10]
Local cUID   	 := aParams[11]
Local aErros:= {}
Local oModel:= Nil
Local oTemp	:= Nil
Local nTotalEnc := 0
PRIVATE lMsErroAuto := .F.

// Apaga arquivo ja existente
If File(cJobFile)
	fErase(cJobFile)
EndIf

// Criacao do arquivo de controle de jobs
nHd1 := MSFCreate(cJobFile)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue("cGlb"+cEmp+cFil+cThread, "1" )
GlbUnLock()

// Seta job para nao consumir licensas
RpcSetType(3) 

// Seta job para empresa filial desejada
RpcSetEnv( cEmp, cFil,,,'GCT')

//Restaura a DataBase
dDatabase:= xData

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue("cGlb"+cEmp+cFil+cThread, "2" )
GlbUnLock()

C260LogMsg(dtoc(Date()) + " " + Time()+" Inicio do job de geração de medições CNTA260 " + cJobFile)

If lCNTA121
	oModel := FWLoadModel("CNTA121")
EndIf

C260LogMsg("Thread:"+ cThread + " - "+ STR0028 +" "+ cValToChar(aThread[1]) + " "+ STR0029 +" "+ cValToChar(aThread[2])  )

For nI := aThread[1] to aThread[2]
	lQuery    := .T.

	If lCNTA121
		oTemp := JsonObject():New()

		FWJsonDeserialize( aContratos[nI] , @oTemp )

		IncEnc121(oModel, {oTemp}, lJob)

		FreeObj(oTemp)
	Else
		IncEEncMed(aContratos[nI], aErros, @cTxLog, lJob)
	EndIf

Next nI

// STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("cGlb"+cEmp+cFil+cThread,"3")
GlbUnLock()

VarBeginT(cUID,"nEncThread")
VarGetXD(cUID,"nEncThread",@nTotalEnc)
nTotalEnc++
VarSetXD(cUID,"nEncThread",nTotalEnc)
VarEndT(cUID,"nEncThread")
C260LogMsg(cUID +" Thread Id: "+ cThread +". Valor de nEncThread = "+ cValToChar(nTotalEnc))

// Fecha arquivo de controle
fClose(nHd1)

C260LogMsg(STR0013 + time())

cTxLog += STR0013 + time()

If ExistBlock("CNT260GRV")
	ExecBlock("CNT260GRV",.F.,.F.)//Executa ponto de entrada apos a gravacao da medição automática
EndIf

If lQuery
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Executa gravacao do arquivo de historico         
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MemoWrite(Criatrab(,.f.)+".LOG",cTxLog)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Emite alerta com o log do processamento          
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MEnviaMail("041",{cTxLog})
EndIf

If !lCNTA121/*Nesse cenário, apenas as medições de contratos recorrentes serão geradas pelo CNTA121, as demais via CNTA120*/	
	CN260Exc121(lJob)//-- Incluir medição automatica de contratos recorrentes pela rotina CNTA121
EndIf

Return

/*/{Protheus.doc} GetQryTrb
 Gera uma consulta com as medicoes pendentes, executa e retorna um alias com o resultado.
@author philipe.pompeu
@since 22/07/2019
@return cArqTrb, retorna um alias com o resultado da consulta
@param dEndDate, date, descricao
@param lRecorre, logical, descricao
@param lNaoRecorr, logical, descricao
/*/
Static Function GetQryTrb(dEndDate,lRecorre, lNaoRecorr)
	Local cQuery   := ""
	Local cArqTrb := ""
	Local nDias    := GetNewPar( "MV_MEDDIAS", 0 )//Parametro que armazena a quantidade de dias de busca
	Local dDataI   := dEndDate-nDias//Data de inicio
	Local cCnt260Fil:= 0
	Local lGS		:= ExistFunc("TecMdAtQry")
	Default lRecorre	:= .F.	
	Default lNaoRecorr	:= .T.
	Default dEndDate	:= IIF(IsBlind(),Date(),dDataBase)
	
	//Filtra parcelas de contratos automaticos
	//pendentes para a data atual
	cArqTrb	:= CriaTrab( nil, .F. )	
	cQuery := "SELECT * FROM ("
	If(lNaoRecorr)		
		cQuery += "SELECT DISTINCT CNF.CNF_COMPET,CNF.CNF_CONTRA,CNF.CNF_REVISA,CNA.CNA_NUMERO,CNF.CNF_PARCEL,CN9.CN9_FILIAL,CN9.CN9_NUMERO,"
		cQuery += "(CASE WHEN CNL.CNL_MEDAUT = '0' THEN CN1.CN1_MEDAUT ELSE CNL.CNL_MEDAUT END) MEDAUT"
		cQuery += " FROM " + RetSQLName("CNF") + " CNF" 
		
		//Join CNF x CN9(Contratos)
		cQuery += " INNER JOIN "+ RetSQLName("CN9") +" CN9 ON(CN9.CN9_FILIAL = '"+ xFilial("CN9") +"'" 
		cQuery += " AND CNF.CNF_CONTRA = CN9.CN9_NUMERO AND CNF.CNF_REVISA = CN9.CN9_REVISA AND CN9.D_E_L_E_T_ = ' ')" 
		
		//Join CN9 x CN1(Tipo de Contrato)
		cQuery += " INNER JOIN "+RetSQLName("CN1") +" CN1 ON(CN1.CN1_FILIAL = '"+ xFilial("CN1") +"' AND CN9.CN9_TPCTO  = CN1.CN1_CODIGO AND CN1.D_E_L_E_T_ = ' ')"
		
		//Join CNF x CNA(Planilhas de Contratos)
		cQuery += " INNER JOIN "+ RetSQLName("CNA") + " CNA ON(CNA.CNA_FILIAL = '"+ xFilial("CNA") +"'"
		cQuery += " AND CNF.CNF_NUMERO = CNA.CNA_CRONOG AND CNF.CNF_CONTRA = CNA.CNA_CONTRA AND CNF.CNF_REVISA = CNA.CNA_REVISA AND CNA.D_E_L_E_T_ = ' ')" 
		
		//Join CNA x CNL(Tipo de Planilha)
		cQuery += " INNER JOIN "+ RetSQLName("CNL") +" CNL ON(CNF.CNF_FILIAL = '"+ xFilial("CNF") +"' AND CNA.CNA_TIPPLA = CNL.CNL_CODIGO AND CNL.D_E_L_E_T_ = ' ')"
		
		//Join CN9 x CPD(Permissoes do Contrato)
		cQuery += " INNER JOIN "+ RetSQLName("CPD") +" CPD ON(CPD.CPD_FILIAL = '"+ xFilial("CPD") +"' AND CPD.CPD_CONTRA = CN9.CN9_NUMERO AND CPD.CPD_NUMPLA = CNA.CNA_NUMERO AND CPD_FILAUT = '"+ cFilAnt +"' AND CPD.D_E_L_E_T_ = ' ')"
		
		//Filtros
		cQuery += " WHERE CN9.CN9_SITUAC = '"+ DEF_SVIGE +"'"
		cQuery += " AND CN9.CN9_REVATU = '"+ Space(Len(CN9->CN9_REVATU)) +"'"
		cQuery += " AND CNF.CNF_PRUMED >= '"+ DTOS(dDataI) +"'"
		cQuery += " AND CNF.CNF_PRUMED <= '"+ DTOS(dEndDate) +"'"
		cQuery += " AND CNF.CNF_SALDO  > 0"
		cQuery += " AND CNA.CNA_SALDO  > 0"		
		cQuery += " AND CNF.D_E_L_E_T_ = ' '"
		
		If(!FwIsInCallStack("CN260Exc121"))			
			cQuery += " AND CNL.CNL_PLSERV <> '1'"//Nao deve considerar planilhas de servico pelo CNTA120
		EndIf
		
		//Ponto de Entrada para utilização de Filtros específicos
		If ExistBlock("CNT260FIL")
			cCnt260Fil := ExecBlock("CNT260FIL",.F.,.F.)
			If ValType(cCnt260Fil) == "C" .And. !Empty(cCnt260Fil)
				cQuery += " AND "+ cCnt260Fil
			EndIf
		EndIf
	EndIf
	
	If(lRecorre .And. lNaoRecorr)
		cQuery += " UNION "
	EndIf
	
	If(lRecorre)
		cQuery += " SELECT CNA.CNA_PROMED AS CNF_COMPET,'RECORRENTE' AS CNF_CONTRA,CN9.CN9_REVISA AS CNF_REVISA,CNA.CNA_NUMERO,CNA.CNA_PROPAR AS CNF_PARCEL,CN9.CN9_FILIAL,CN9.CN9_NUMERO, "
		cQuery += " ( CASE WHEN CNL.CNL_MEDAUT = '0' THEN CN1.CN1_MEDAUT ELSE CNL.CNL_MEDAUT END)  MEDAUT "
		cQuery += " FROM " + RetSQLName("CNA") + " CNA"		 
		cQuery += " INNER JOIN "+ RetSQLName("CN9") +" CN9 ON(CN9.CN9_FILIAL = '"+ xFilial("CN9") +"' AND CNA.CNA_CONTRA = CN9.CN9_NUMERO AND CNA.CNA_REVISA = CN9.CN9_REVISA AND CN9.D_E_L_E_T_ = ' ')"
		cQuery += " INNER JOIN "+ RetSQLName("CN1") +" CN1 ON(CN1.CN1_FILIAL = '"+ xFilial("CN1") +"' AND CN1.CN1_CODIGO = CN9.CN9_TPCTO AND CN1.D_E_L_E_T_ = ' ')" 
		cQuery += " INNER JOIN "+ RetSQLName("CNL") +" CNL ON(CNL.CNL_FILIAL = '"+ xFilial("CNL") +"' AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA AND CNL.D_E_L_E_T_ = ' ')"		
		cQuery += " INNER JOIN "+ RetSQLName("CPD") +" CPD ON(CPD.CPD_FILIAL = '"+ xFilial("CPD") +"' AND CPD.CPD_CONTRA = CN9.CN9_NUMERO AND CPD.CPD_NUMPLA = CNA.CNA_NUMERO AND CPD_FILAUT = '"+ cFilAnt +"' AND CPD.D_E_L_E_T_ = ' ')"
		
		cQuery += " WHERE "
		cQuery += " CNA.CNA_FILIAL = '" + xFilial("CNA") +"'"	
		
		cQuery += " AND CNA.CNA_PERIOD <> ' '"
		cQuery += " AND CNA.CNA_PROMED >= '" + DTOS(dDataI)+ "'"
		cQuery += " AND CNA.CNA_PROMED <= '" + DTOS(dEndDate) + "'"
		cQuery += " AND CNA.D_E_L_E_T_ = ' '  "
		cQuery += " AND CN9.CN9_SITUAC = '"+ DEF_SVIGE +"'"
		cQuery += " AND CN9.CN9_REVATU = '"+ Space(Len(CN9->CN9_REVATU)) +"'"//Não carrega contratos em revisão...
	EndIf

	cQuery += ") CN9 "
	cQuery += " WHERE MEDAUT = '1'"

	If lGs
		cQuery := TecMdAtQry(cQuery)
	EndIf

	cQuery += " ORDER BY CN9_FILIAL, CN9_NUMERO, CNF_REVISA, CNA_NUMERO"

	cQuery		:= ChangeQuery( cQuery )

	C260LogMsg(cQuery, "DEBUG")/*Caso precise imprimir mensagens de DEBUG, incluir chave FWLOGMSG_DEBUG=1 no ambiente*/

	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )	
Return cArqTrb

/*/{Protheus.doc} MdJaGerada
	Valida se a medicao da <cParcel> ja foi realizada.
@author philipe.pompeu
@since 22/07/2019
@return lReturn, se <cParcel> foi gerada retorna verdadeiro
@param cContra, caractere, numero do contrato
@param cPlan, caractere, planilha do contrato
@param cParcel, caractere, parcela da planilha
/*/
Static Function MdJaGerada(cContra As char, cRevisa As char, cPlan As char, cParcel As char, cCompet As char, cNumMed As char) As Logical
	Local lReturn := .F.
	Local cUmAlias:= GetNextAlias()
	Local cSitEnc := PadR('E', Len(CND->CND_SITUAC))
	Default cNumMed := ""
	
	BeginSQL Alias cUmAlias
		SELECT CND.CND_NUMMED, CND.CND_COMPET, CND.CND_NUMERO, CND.R_E_C_N_O_ RECMED
		FROM 	%Table:CND% CND
		WHERE	CND.CND_FILIAL = %xFilial:CND% 
				AND CND.CND_CONTRA = %Exp:cContra%
				AND CND.CND_REVISA = %Exp:cRevisa% 
				AND CND.CND_NUMERO = %Exp:cPlan% 
				AND	CND.CND_PARCEL = %Exp:cParcel%
				AND	CND.CND_DTFIM = %Exp:Space(8)% 
				AND CND.%NotDel%
				
		UNION
		
		SELECT CXN.CXN_NUMMED,CND.CND_COMPET,CXN.CXN_NUMPLA CND_NUMERO ,CND.R_E_C_N_O_ RECMED 
		FROM 	%Table:CXN% CXN
		
		INNER JOIN %Table:CND% CND ON(
		CND.CND_FILIAL = %xFilial:CND% 
		AND CND.CND_NUMMED = CXN.CXN_NUMMED 
		AND CND.CND_CONTRA = CXN.CXN_CONTRA 
		AND CND.CND_REVISA = CXN.CXN_REVISA		 
		AND CND.%NotDel%)
		
		WHERE	CXN.CXN_FILIAL = %xFilial:CXN% 
				AND CXN.CXN_CONTRA = %Exp:cContra%
				AND CXN.CXN_REVISA = %Exp:cRevisa%				
				AND	CXN.CXN_PARCEL = %Exp:cParcel%
				AND	CXN.CXN_NUMPLA = %Exp:cPlan%
				AND CND.CND_SITUAC <> %Exp:cSitEnc%
				AND CXN.%NotDel%
	EndSQL
		
	If (lReturn := (cUmAlias)->(!EOF()))
		//Substitui medicao para encerramento	
		cCompet := (cUmAlias)->CND_COMPET
		cPlan 	:= (cUmAlias)->CND_NUMERO
		cNumMed := (cUmAlias)->CND_NUMMED
		CND->(DbGoTo((cUmAlias)->RECMED))
	EndIf	
	(cUmAlias)->(dbCloseArea())
Return lReturn

/*/{Protheus.doc} GetArrCtr
	Preenche um vetor com suas posicoes padronizadas p/ ser usado nas funcoes CNTA260JOB e CN260Exc
@author philipe.pompeu
@since 01/10/2019
@return aUmContrato, uma vetor preenchido com dados da medicao
@param cUmAlias, caractere, um alias com a consulta
/*/
Static Function GetArrCtr(cUmAlias As Char)
	Local aUmContrato := {}	

	If(Select(cUmAlias) > 0)
		aAdd(aUmContrato,(cUmAlias)->CNF_COMPET)
		aAdd(aUmContrato,(cUmAlias)->CNF_CONTRA)
		aAdd(aUmContrato,(cUmAlias)->CNF_REVISA)		
		aAdd(aUmContrato,(cUmAlias)->CNA_NUMERO)
		aAdd(aUmContrato,(cUmAlias)->CNF_PARCEL)
		aAdd(aUmContrato,(cUmAlias)->CN9_FILIAL)
		aAdd(aUmContrato,(cUmAlias)->CN9_NUMERO)
		aAdd(aUmContrato,(cUmAlias)->MEDAUT)
	EndIf
Return aUmContrato

/*/{Protheus.doc} IncEEncMed
	Dado <aMedicao>, inclui e encerra via CNTA120.
<aMedicao> deve ser gerado pela funcao GetArrCtr p/ ter suas posicoes padronizadas.
@author philipe.pompeu
@since 01/10/2019
@return Nil, valor nulo
@param aMedicao, array, descricao
@param aErros, array, descricao
@param cTxLog, characters, descricao
@param lJob, logical, descricao
/*/
Static Function IncEEncMed(aMedicao, aErros, cTxLog, lJob)
	Local lMedPend := (GetNewPar("MV_MEDPEND","1") == "1")//Parametro que informa se a rotina busca por medicoes pendentes
	Local aCab     := {}//Cabecalho
	Local aItem    := {}//Itens
	Local cNum     := ""
	Local nStack   := GetSX8Len()	
	Local lIncluiMed:= .T.
	Local lEncerra	:= .T.	
	Local cContra	:= ""
	Local cRevisa	:= ""
	Local cCompet	:= ""
	Local cPlan		:= ""
	Local cParcel	:= ""
	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	
	If(Len(aMedicao) >= 7)
		cContra := aMedicao[7]
		cRevisa	:= aMedicao[3]
		cCompet	:= aMedicao[1]
		cPlan	:= aMedicao[4]
		cParcel	:= aMedicao[5]		
		lMsErroAuto := .F.		
		lIncluiMed	:= .T.
		lEncerra	:= .T.
		
		If(MdJaGerada(cContra, cRevisa, @cPlan, cParcel, @cCompet, @cNum))//Se a mediçao já foi gerada
			lIncluiMed	:= .F.
			lEncerra	:= lMedPend
		EndIf
		
		If(lIncluiMed .Or. lEncerra)						
			aCab := {}
			aAdd(aCab,{"CND_CONTRA",cContra,NIL})
			aAdd(aCab,{"CND_REVISA",cRevisa,NIL})
			aAdd(aCab,{"CND_PARCEL",cParcel,NIL})
			aAdd(aCab,{"CND_COMPET",cCompet,NIL})
			aAdd(aCab,{"CND_NUMERO",cPlan,NIL})
			cNum := IIF(lIncluiMed, CriaVar("CND_NUMMED"), cNum)
			aAdd(aCab,{"CND_NUMMED",cNum,NIL})
			
			If(lIncluiMed)//Se deve incluir uma nova medicao
				C260LogMsg(STR0003 + " - " + aCab[5,2])
				C260LogMsg(STR0004 + " - " + cContra)
				C260LogMsg(STR0005 + " - " + cPlan)
				C260LogMsg(STR0006 + " - " + aCab[3,2])

				If !lJob				
					IncProc(STR0003 + " - " + aCab[5,2])
				EndIf
				cTxLog += STR0004+" - "+ cContra	 +CHR(13)+CHR(10)
				cTxLog += STR0022+" - "+ aMedicao[6] +CHR(13)+CHR(10)
				cTxLog += STR0005+" - "+ cPlan 		 +CHR(13)+CHR(10)
				
				MSExecAuto({|x,y|CNTA120(x,y,3,.F.)},aCab, aItem)//Executa rotina automatica para gerar as medicoes
				If !lMsErroAuto											
					cTxLog += STR0019+" - "+aCab[6,2]+CHR(13)+CHR(10)//"Medicao gerada com sucesso"
					cTxLog += STR0006+" - "+aCab[3,2]+CHR(13)+CHR(10)						
					C260LogMsg(STR0007+aCab[5,2]+STR0008)
				Else
					aEval(GetAutoGrLog(),{|x|cTxLog += x + CHR(13)+CHR(10), aAdd(aErros,{x})})
					//Retorna controle de numeracao                    					
					While GetSX8Len() > nStack
						RollBackSX8()
					EndDo
					
					lEncerra := .F.
				EndIf										
			EndIf
		
			If lEncerra //Se deve prosseguir p/ encerrar a medicao(nova ou nao)
				C260LogMsg(STR0010 + aCab[5,2])
				
				If !lJob
					IncProc(STR0010 + aCab[5,2])
				EndIf
																		
				MSExecAuto({|x,y|CNTA120(x,y,6,.F.)},aCab,aItem) //Executa rotina automatica para encerrar as medicoes
				If (!lMsErroAuto)						
					cTxLog += PadC(STR0020 + "["+  aCab[5,2] +"]", 128,"-") +CHR(13)+CHR(10)//"Medicao encerrada com sucesso"						
					C260LogMsg(STR0007+aCab[5,2]+STR0011)					
				Else
					cTxLog += PadC(STR0012,128,"-") + CHR(13) + CHR(10)			
					aAdd(aErros,{ STR0004 +": "+ cContra + " "+ STR0006 +": " + cCompet })
					aEval(GetAutoGrLog(),{|x|cTxLog += x + CHR(13)+CHR(10), aAdd(aErros,{x})})								
					
					C260LogMsg(STR0012+aCab[5,2])					
				EndIf
			EndIf			
		EndIf				
	EndIf	
Return Nil

/*/{Protheus.doc} GetCompDt
	Dado <dCompet> retorna a competencia no formato MM/AAAA
@author philipe.pompeu
@since 28/10/2019
@return cCompet, competencia de dCompet
@param dCompet, data
/*/
Static Function GetCompDt(dCompet)
	Local cCompet := ""
	cCompet := StrZero( Month( dCompet ), 2 ) + "/" + CValToChar( Year( dCompet ) )
Return cCompet

/*/{Protheus.doc} GetObjJs
	Retorna um JsonObject com os dados da linha atual de <cAlias>
@author philipe.pompeu
@since 18/08/2021
@param cAlias, caractere, alias aberto com a consulta
@param aTabStruct, vetor, estrutura física de <cAlias>
@return oResult, objeto, instância de JsonObject
/*/
Static Function GetObjJs(cAlias as char,aTabStruct as array)
	Local oResult := JsonObject():New()
	Local nX	:= 0
	Local cCampo:= ""
	Local xValue:= 0

	for nX := 1 to Len(aTabStruct) //Armazena todos os campos
		cCampo := aTabStruct[nX,1]		
		xValue := (cAlias)->(FieldGet( aTail(aTabStruct[nX]) ))		
		oResult[cCampo] := xValue
	next nX

	oResult["planilhas"]:= {} //Campo p/ armazenar todas as planilhas
	oResult["compet"]	:= ""
Return oResult

/*/{Protheus.doc} ConvJsToC
	Serializa a lista <aToBeConv> p/ um vetor
@author philipe.pompeu
@since 18/08/2021
@param aToBeConv, vetor, registros à serem serializados
@return aResult, vetor, lista de objetos já serializados
/*/
Static Function ConvJsToC(aToBeConv as array)
	Local aResult := {}
	Local nX := 0

	for nX := 1 to Len(aToBeConv)
		aAdd(aResult, FwJsonSerialize(aToBeConv[nX]))
	next nX
Return aResult

/*/{Protheus.doc} IncEnc121
	Inclui e encerra as medições em <aMedicoes> via CNTA121
@author philipe.pompeu
@since 18/08/2021
@param oModel	, objeto, instância de MPFormModel do CNTA121
@param aMedicoes, vetor, lista de objetos à serem processados
@param lJob		, lógico, se a execução é oriunda de um job
@return lFail, lógico, se houve falha no processo
/*/
Static Function IncEnc121(oModel, aMedicoes, lJob)
	Local aArea			:= GetArea()
	Local aSaveLines	:= FwSaveRows()	
	Local oModelCND		:= Nil
	Local oModelCNE		:= Nil
	Local oModelCXN		:= Nil
	Local cTxLog   		:= ""//Texto do log
	Local cHelp			:= ""
	Local cTxPlan		:= ""
	Local cContrato 	:= ""
	Local cCompet		:= ""
	Local cPlan			:= ""
	Local lContinua	:= .T.
	Local lFail    	:= .F.
	Local nStack	:= 0	
	Local lIncluiMed:= .T.
	Local lEncerra	:= .T.
	Local lMedPend 	:= (GetNewPar("MV_MEDPEND","1") == "1")//Parametro que informa se a rotina busca por medicoes pendentes
	Local nLinha	:= 0	
	Local oMedicao	:= Nil
	Local nX	:= 0
	Local nY	:= 0
	Local cErro := ""

	GCTGsMdZer(/*cContra*/, /*cRevisa*/, /*cPlan*/, /*cItCNB*/, /*cCompet*/, /*laMedZero*/, .T.)//Reinicializa variáveis estáticas do SIGATEC(GS)

	//-- Valida se o sistema foi atualizado
	If lContinua
		nStack 	:= GetSX8Len()	
		
		CN9->(DbSetOrder(1))		

		for nX := 1 to Len(aMedicoes)
			oMedicao := aMedicoes[nX]

			lIncluiMed	:= .T.
			lEncerra	:= .T.
			lContinua	:= .T.			
			
			cContrato	:= oMedicao["CN9_NUMERO"]
			cCompet		:= oMedicao["compet"]

			GCTGsMdZer(cContrato, oMedicao["CNF_REVISA"], /*cPlan*/, /*cItCNB*/, cCompet , .F.)

			for nY := 1 to Len(oMedicao["planilhas"])
				cPlan := oMedicao["planilhas", nY]
				If(MdJaGerada(cContrato, oMedicao["CNF_REVISA"], @cPlan, oMedicao["CNF_PARCEL"], @cCompet))//Se a mediçao já foi gerada
					lIncluiMed	:= .F.
					lEncerra	:= lMedPend .And. (AllTrim(CND->CND_SITUAC) != 'E')
					Exit
				EndIf			
			next nY

			If(lIncluiMed .Or. lEncerra)
				CN9->(DbSeek(oMedicao["CN9_FILIAL"]+cContrato))//Posiciona no contrato corrente
				
				A260SComp(cCompet)
				
				If(lIncluiMed)
					oModel:SetOperation(MODEL_OPERATION_INSERT)
				Else
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
				EndIf
		
				If (lContinua := oModel:Activate())
					oModelCND := oModel:GetModel("CNDMASTER")
					oModelCXN := oModel:GetModel("CXNDETAIL")
					oModelCNE := oModel:GetModel("CNEDETAIL")
					oModelCND:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
					oModelCXN:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
					oModelCNE:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})
					
					If(lIncluiMed)
						If (lContinua := oModelCND:SetValue("CND_CONTRA",cContrato))
							oModelCND:SetValue("CND_REVISA"	,CnGetRevVg(cContrato))
							oModelCND:SetValue("CND_COMPET"	,cCompet)							
							CN121Carga(oMedicao["CNF_CONTRA"], oMedicao["CNF_REVISA"])
						EndIf				
					EndIf
				EndIf
				
				If(lContinua)					
					for nY := 1 to Len(oMedicao["planilhas"]) //Marca todas as planilhas da consulta
						cPlan := oMedicao["planilhas", nY]

						nLinha := MTFindMVC(oModelCXN,{{"CXN_NUMPLA",cPlan}})
				
						If nLinha > 0
							oModelCXN:GoLine(nLinha)
							If(!oModelCXN:GetValue("CXN_CHECK"))
								lContinua := oModelCXN:SetValue("CXN_CHECK" , .T. )
								//- Ponto de Entrada para preenchimento de campos obrigatorios customizados
								If lCN260OBRIG
									ExecBlock("CN260OBRIG",.F.,.F.,{oModel})
								EndIf
								cTxPlan += STR0005+" - "+cPlan+CHR(13)+CHR(10)
								If lContinua .And. GCTGsMvZer()
									lContinua := CNEGsMdZer(oModelCNE, cPlan, cCompet, @cTxPlan, oModelCXN)//GS: verifica se deve gerar medição zerada.
								EndIf
							Else
								lContinua := .T.					
							EndIf
						EndIf											
					next nY				
				EndIf
					
				If(lContinua)					
					If (lContinua := oModel:VldData())
						lContinua := oModel:CommitData()//Commit na medição						
					EndIf
				EndIf
				
				If lContinua
					C260LogMsg(STR0030 + " " + cContrato + " " + STR0031 )//Medicao do contrato XXXX inserida com sucesso
				ElseIf (oModel:HasErrorMessage())
					cErro 	:= cContrato+" - "+cPlan+": "+ STR0032 +" ("+ oModel:GetErrorMessage()[6] + ")"
					C260LogMsg(cErro)
					cHelp	+= cErro + CRLF
				EndIf				
				oModel:DeActivate()
				
				If lContinua .And. lEncerra
					
					While ( GetSX8Len() > nStack )
						ConfirmSX8() //-- Retorna controle de numeracao
					EndDo
			
					cTxLog += STR0019+" - "+CND->CND_NUMMED+CHR(13)+CHR(10)//"Medicao gerada com sucesso"
					cTxLog += STR0004+" - "+cContrato+CHR(13)+CHR(10)					
					cTxLog += STR0022+" - "+oMedicao["CN9_FILIAL"]+CHR(13)+CHR(10)
					cTxLog += 	cTxPlan
					cTxLog += STR0006+" - "+cCompet+CHR(13)+CHR(10)
			
					cTxPlan:= ""

					C260LogMsg(STR0019+" - " + CND->CND_NUMMED)
					C260LogMsg(STR0004+" - " + cContrato)
					C260LogMsg(STR0006+" - " + cCompet)
					C260LogMsg(STR0007+cCompet+STR0008)
			
					// Rotina de encerramento de medição
					lContinua := CN121Encerr()

					If lContinua
						lContinua := CND->(AllTrim(CND_SITUAC) == "E")
					EndIf
			
					If lContinua
						C260LogMsg(STR0033+" - " + CND->CND_NUMMED)
						C260LogMsg(STR0004+" - " + cContrato)		
					Else
						C260LogMsg(STR0030+" "+ cContrato + " " + STR0034) //Medicao do Contrato XXXX falhou no encerramento
					EndIf
				ElseIf(!lContinua)
					While GetSX8Len() > nStack
						RollBackSX8()
					EndDo			
					
					cTxLog += STR0004+" - "+cContrato+CHR(13)+CHR(10)
					cTxLog += STR0022+" - "+oMedicao["CN9_FILIAL"]+CHR(13)+CHR(10)
					cTxLog += STR0005+" - "+oMedicao["CNA_NUMERO"]+CHR(13)+CHR(10)
					cTxLog += STR0006+" - "+cCompet+CHR(13)+CHR(10)
					cTxLog += Replicate("-",128)+CHR(13)+CHR(10)
					C260LogMsg(STR0009 + cCompet+":"+cHelp)
				EndIf
			EndIf
		next nX			
	Else
		C260LogMsg(STR0014)		
		If !lJob		
			Aviso("CNTA260",STR0014,{"Ok"})
		EndIf
		lFail := .T.
		cTxLog += STR0014
	EndIf

	If !Empty(cHelp)
		//- Mostra Help contendo os cotratros com falha
		Help(" ",1,"A260VLDDATA",,cHelp + "Medição não será gerada para estes contratos.",1,1)
	EndIf

	//-- Executa ponto de entrada apos a gravacao da medição automática
	If ExistBlock("CNT260GRV")
		ExecBlock("CNT260GRV",.F.,.F.)
	EndIf

	GCTGsMdZer(/*cContra*/, /*cRevisa*/, /*cPlan*/, /*cItCNB*/, /*cCompet*/, /*laMedZero*/, .T.)//Reinicializa variáveis estáticas do SIGATEC(GS)

	FWRestRows(aSaveLines)
	RestArea(aArea)
Return lFail

/*/{Protheus.doc} ExecByThread
	Realiza a execução das medições automáticas utilizando threads
@author philipe.pompeu
@since 18/08/2021
@param aThreads		, vetor, posições p/ particionar <aContratos>
@param aContratos	, vetor, lista de medições à serem incluidas
@param lCNTA121		, lógico, se a execução deve ser realizada via CNTA121
@param cTxLog		, caractere, variável p/ armazenar erros
@param lJob			, lógico, se a execução é oriunda de um job
@return Nil, Nulo
/*/
Static Function ExecByThread(aThreads as array, aContratos  as array, lCNTA121 as logical, cTxLog as char, lJob as Logical)
	Local nX 		 := 0
	Local cJobFile   := ""
	Local cJobAux    := ""
	Local cStartPath := GetSrvProfString("Startpath","")
	Local lMedPend 	 := (GetNewPar("MV_MEDPEND","1") == "1")//Parametro que informa se a rotina busca por medicoes pendentes
	Local aParams    := {}
	Local nStack 	:= GetSX8Len()
	Local cUID		:= "CN260"+cEmpAnt+cFilAnt
	Local nLenThread:= 0
	Local nStart	:= Seconds()
	Default lCNTA121 := .F.
	Default cTxLog	:= ""
	Default lJob	:= .F.

	nLenThread := Len(aThreads)
	If nLenThread > 0 .And. Len(aThreads[1]) > 0

		VarSetUID(cUID, .T.)
		VarSetXD(cUID,"nEncThread",0)

		ProcRegua(nLenThread)		
		For nX:= 1 To nLenThread
			IncProc(STR0041+ " "+ cValToChar(nX) + "/" + cValToChar(nLenThread))

			cJobFile:= cStartPath + CriaTrab(Nil,.F.)+".job"// Informacoes do semaforo
					
			// Inicializa variavel global de controle de thread
			cJobAux:="cGlb"+cEmpAnt+cFilAnt+StrZero(nX,2)
			PutGlbValue(cJobAux,"0")

			GlbUnLock()
			
			aParams:= { cEmpAnt		,;	//1 
						cFilAnt		,;	//2
						dDataBase	,;	//3
						lMedPend	,;	//4
						nStack		,;	//5
						cTxLog		,;	//6
						0			,;	//7
						0			,;	//8
						lJob		,;	//9
						lCNTA121	,; //10
						cUID}		   //11

			StartJob("CNTA260JOB",GetEnvServer(),.F.,aThreads[nX],aContratos,cJobFile,StrZero(nX,2), "",aParams)
			
			Sleep(1000 * 60) //Intervalo de 1m entre o inicio de cada thread p/ reduzir o processamento concomitante e evitar deadlocks
		Next nX		

		If (!IsBlind())
			If MsgYesNo(STR0040, STR0039) //"Deseja aguardar o fim do processamento?"
				FwMsgRun(Nil,{|x| CN260Loader(x, nLenThread, cUID, nStart) },Nil, STR0036) //Processando				
			EndIf			
		EndIf

		For nX:= 1 To nLenThread			
			cJobAux:="cGlb"+cEmpAnt+cFilAnt+StrZero(nX,2)
			ClearGlbValue(cJobAux)			
		Next nX		
	EndIf
Return Nil

/*/{Protheus.doc} C260LogMsg
	Imprime log no console
@author philipe.pompeu
@since 20/08/2021
@param cMensagem	, caractere, texto à ser enviado p/ o Log
@param cTipo		, caractere, tipo do Log
@return Nil, Nulo
/*/
Function C260LogMsg(cMensagem, cTipo)
	Default cTipo := "INFO"

	FwLogMsg(cTipo, , "", "CNTA260", "", "01", cMensagem, 0, -1, {})
Return

/*/{Protheus.doc} CN260Loader
	Exibe um loader enquanto aguarda o encerramento de todas as threads iniciadas.
@author philipe.pompeu
@since 15/10/2021
@param oSay	, objeto, instância da classe TSay
@return Nil, Nulo
/*/
Function CN260Loader(oSay, nLenThread, cUID, nStart)
	Local cTempo	:= ""
	Local nTotalEnc	:= 0
	Default nStart	:= Seconds()

	While (nTotalEnc < nLenThread)		
		Sleep(1000 * 60) //Aguarda 1 minuto

		VarGetXD(cUID,"nEncThread",@nTotalEnc)
		C260LogMsg(cUID + ": valor de nEncThread = "+ cValToChar(nTotalEnc))
		
		cTempo := cValToChar(Int(((Seconds() - nStart) / 60))) + STR0038 //Minuto(s)		
		
		oSay:SetText(STR0037 + cTempo ) //"Ainda há registros, aguarde. Tempo decorrido: "
		ProcessMessage()			
	EndDo
Return Nil

/*/{Protheus.doc} GCTIncTit
	Job p/ realizar inclusão de um título à receber numa thread distinta a de encerramento da medição.
Essa funcionalidade surgiu da necessidade de chamar o FINA040 de fora da transação, pois a função cA100Incl não pode ser chamada
dentro de uma transação sem o risco de gerar deadlocks(reclocked)
@author philipe.pompeu
@since 15/12/2021
@param aEmpFil, vetor
@param aRotAuto, vetor
@param aRatSevSez, vetor
@param aFKF, vetor
@param aFKG, vetor
@return Nil, Nulo
/*/
Function GCTIncTit(aEmpFil, aRotAuto, aRatSevSez, aFKF, aFKG)
	Local lResult := nil

	C260LogMsg("Inicio Job GCTIncTit: processa título em thread distinta.")

	RpcSetType(3) // Seta job para nao consumir licensas	
	RpcSetEnv( aEmpFil[1], aEmpFil[2],,,'GCT')// Seta job para empresa filial desejada
	
	C260LogMsg("CNMedTitE1(CNTA121): Chamada via Job(GCTIncTit)")
	lResult := CNMedTitE1(aRotAuto, aRatSevSez, aFKF, aFKG)

	C260LogMsg("CNMedTitE1(CNTA121): operacao " + IIF(lResult, "ok", "falhou"))

	FwFreeArray(aEmpFil)
	FwFreeArray(aRotAuto)
	FwFreeArray(aRatSevSez)
	FwFreeArray(aFKF)
	FwFreeArray(aFKG)

	RpcClearEnv()
Return lResult

/*/{Protheus.doc} GCTGsMdZer
	Encapsula a chamada à função <TecGsMdZer> do SIGATEC: 
confere se existe alocação no período do posto para medição automática ficar com o valor zerado
@author philipe.pompeu
@since 09/05/2022
@param cContra	, caractere, numero do contrato
@param cRevisa	, caractere, revisao
@param cPlan	, caractere, numero da planilha
@param cItCNB	, caractere, item da planilha
@param cCompet	, caractere, competência
@param lLimpArray, lógico, se limpa a variável estática
@return lResult, lógico, resultado da chamada a função <TecGsMdZer>
/*/
Static Function GCTGsMdZer(cContra, cRevisa, cPlan, cItCNB, cCompet, laMedZero, lLimpArray)
	Local lResult := .F.
	Local lAuto := .T.
	Default laMedZero := .T.
	Default lLimpArray := .F.

	If GCTGsMvZer()
		lResult := TecGsMdZer(cContra, cRevisa, cPlan, cItCNB, lAuto, cCompet, laMedZero, lLimpArray )
	Endif
Return lResult

/*/{Protheus.doc} CNEGsMdZer
	Chama a função <GCTGsMdZer> p/ cada item presente em <oModelCNE>
@author philipe.pompeu
@since 09/05/2022
@param oModelCNE, objeto, instância de FwFormGrid
@param cPlan	, caractere, numero da planilha
@param cCompet	, caractere, competência
@param cTxPlan	, caractere, variável que o log será armazenado
@return lContinua, lógico, se deve prosseguir com o processamento
/*/
Static Function CNEGsMdZer(oModelCNE, cPlan, cCompet, cTxPlan, oModelCXN)
	Local lContinua := .T.
	Local nZ	:= 0
	Local lCXNMdZero := .F.

	For nZ := 1 to oModelCNE:Length()
		oModelCNE:GoLine(nZ)

		lCXNMdZero := GCTGsMdZer(oModelCNE:GetValue("CNE_CONTRA"),;
								 oModelCNE:GetValue("CNE_REVISA"),;
								 cPlan, oModelCNE:GetValue("CNE_ITEM"), cCompet)
		If lCXNMdZero
			If lContinua := oModelCNE:SetValue("CNE_QUANT" , 0 )				
				cTxPlan += I18N(STR0042, {oModelCNE:GetValue("CNE_ITEM")}) + CHR(13)+CHR(10)//Item: #1, com a quantidade zerada.
			Endif
		EndIf

		If lContinua .And. oModelCNE:Length() == nZ .And. CxnZeroWhe() .And. lCXNMdZero//Se for a ultima linha e todos itens da CNE estão zerados
			lContinua := oModelCXN:SetValue("CXN_ZERO" , "1" )
		EndIf
	Next nZ
Return lContinua
