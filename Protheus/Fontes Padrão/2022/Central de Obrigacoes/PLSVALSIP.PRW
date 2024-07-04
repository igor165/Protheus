#include 'totvs.ch'
#INCLUDE "Fwlibversion.ch"

#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_valida_sip.log"
#DEFINE MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)
#DEFINE MV_STATISS	GetNewPar("MV_STATISS",.F.)
#DEFINE BANCO		Alltrim(Upper(TCGetDb()))
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"
#DEFINE OBR_SIP 		"1"

#DEFINE FINALIZADO	"6"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALSIP

Funcao criada para ser o job de validacao das despesas do SIP na Central de Obrigacoes

@author timoteo.bega
@since 20/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALSIP(dData,cTpData,cRegANS,cTpProc)
	Local cDataRef		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cCodCmp		:= ""
	Local aDatRef		:= {}
	Local nDatas		:= 0
	Local lPLSIPVLED	:= .f.
	Local lPLJSIPTOT	:= .f.
	Default dData		:= dDataBase
	Default cTpData		:= ""
	Default cRegANS		:= mv_par03
	Default cTpProc		:= "1,2,3"

	PlsLogFil(CENDTHRL("I") + " Inicio do schedule PLSVALSIP",ARQUIVO_LOG)

	aInfo := GetUserInfoArray()
	lPLSIPVLED := aScan(aInfo,{ |x| AllTrim(x[5]) == "PLSIPVLED" }) == 0
	lPLJSIPTOT := aScan(aInfo,{ |x| AllTrim(x[5]) == "PLJSIPTOT" }) == 0

	If lPLSIPVLED .And. lPLJSIPTOT

		//bBlock := ErrorBlock( { |e| ChecErro(e) } )
		//BEGIN SEQUENCE

		aDatRef := GetDatRef(cRegANS)//Posso ter mais de um compromisso para validar
		If len(aDatRef) == 0
			PlsLogFil(CENDTHRL("W") + " Sem dados de despesas na B3L para validar",ARQUIVO_LOG)
		EndIf
		For nDatas := 1 TO Len(aDatRef)

			cDataRef := aDatRef[nDatas]
			//Preciso identificar todos os registros / compromissos de SIP pendentes de validacao
			If LocalizaCompromisso(cDataRef,@cCodObri,@cAnoComp,@cCodCmp,cRegANS)
				//Primeiro vou limpar so registros totalizadores
				PlsLogFil(CENDTHRL("I")+"["+cAnoComp+cCodObri+"]"+"Limpando totalizadores" ,ARQUIVO_LOG)
				CENDELTOT(cRegANS,cCodObri,cAnoComp,cCodCmp,'')
				//Vou processar a totalização - nao existe mais job de totalizacao
				PlsLogFil(CENDTHRL("I")+"["+cAnoComp+cCodObri+"]"+"Recriando totalizadores" ,ARQUIVO_LOG)
				PLSSIPTOT(cEmpAnt,cFilAnt,cRegANS,cDataRef,.T.)
				//Inicio de fato a validacao dos registros
				PlsLogFil(CENDTHRL("I")+"["+cAnoComp+cCodObri+"]"+"Executanto validação" ,ARQUIVO_LOG)
				PLSSIPVAL(cDataRef,cRegANS,cTpProc,0)
			Else
				cMsg := CENDTHRL("E") + "Não foi possivel localizar o compromisso. Operadora:"+cRegANS+";Data:"+cDataRef
				PlsLogFil(cMsg,ARQUIVO_LOG)
			EndIf//LocalizaCompromisso

		Next nDatas

		//END SEQUENCE

		//ErrorBlock(bBlock)

	Else
		Sleep(300000)//Aguardo 5 minutos
	Endif
	PlsLogFil(CENDTHRL("I") + " Fim do schedule PLSVALSIP",ARQUIVO_LOG)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLMSIPVAL

Funcao criada para carregar os jobs de sentetizacao referente ao SIP para a central de obrigacoes (B3L)

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLMSIPVAL(lAuto)
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo	:= 'Validaçoes Central de Obrigações'
	Local cDesc1	:= 'Esta rotina fará as validações para o '
	Local cDesc2	:= 'núcleo de informações e obrigações.'
	Local cDesc3	:= ""
	Local lOk		:= .T.
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Beneficiarios; 2=Eventos x Despesa
	Local lOk       := .F.
	//Métricas - FwMetrics
	Local lLibSupFw		:= FWLibVersion() >= "20200727"
	Local lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
	Local lHabMetric	:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

	Default lAuto   := .F.

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Pergunte('PLSVALSIP',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	IIF(!lAuto,FormBatch( Titulo, aSay, aButton, , 200, 450 ),"")

	If nOpc == 2 .Or. lAuto

		cDataRef	:= IIF(!lAuto,Iif(!Empty(mv_par01),DTOS(mv_par01),""),"20450319")
		cRegANS		:= IIF(!lAuto,mv_par03,"417505")
		cTipProc	:= IIF(!lAuto,AllTrim(mv_par04),"1")
		cTriRec		:= DataTrimestre(cDataRef)

		If !Empty(cDataRef) .Or. !Empty(cRegANS) .Or. !Empty(cTipProc)

			if lHabMetric .and. lLibSupFw .and. lVrsAppSw
				FWMetrics():addMetrics("Validações - SIP", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
			endif
			Processa( { || lOk := PLSSIPVAL(cDataRef,cRegANS,cTipProc) },'Aguarde','Processando...',.F.)
			lOk:=.T.
		Else
			MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
			Pergunte('PLSVALSIP',.T.,Titulo,.F.)
		EndIf

	EndIf

Return lOk
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se todas perguntas foram respondidas

@return lRet	Verdadeiro (.T.) se todas as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual a data de referencia ?" + CRLF
	EndIf

	If Empty(mv_par02)
		lRet := .F.
		cMsg += "Qual a operadora padrao ?" + CRLF
	EndIf

	If Empty(mv_par03)
		lRet := .F.
		cMsg += "Tipo de processamento ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPVAL

Funcao de importacao de eventos x despesas do PLS para o NIO - B3L

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProd		1-Produtos, 2-Beneficiario, 3-Despesas
@param lVlSemCom    .T. Permite validar sem compromisso .F. Não permite

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIPVAL(cDataRef,cRegANS,cTipProc,nRecno,cCodPro,lVlSemCom)

	Local nArquivo    := 0 //handle do arquivo/semaforo
	Local nFor        := 0
	Local lContinua   := .T. //Indica se deve .T. ou nao .F. continuar
	Local aThreads    := {}
	Local aTipProc    := {}
	Local aEmpresas   := {}
	Local aJOBs       := {}
	Default cDataRef  := DTOS(dDataBase)
	Default cRegANS   := '000000'
	Default cTipProc  := '1,2,3'
	Default nRecno    := 0
	Default lVlSemCom := .F.
	Default cCodPro   := "000000"

	aTipProc := StrTokArr(cTipProc,',')
	For nFor := 1 TO Len(aTipProc)
		AdicionaThreads(aThreads,Val(aTipProc[nFor]))
	Next nFor

	//abrir semaforo
	nArquivo := Semaforo('A',0)

	//Se abriu o semaforo e carregou os beneficiarios do PLS
	If nArquivo <= 0
		lContinua := .F.
	EndIf

	PlsLogFil(CENDTHRL("I") + " Inicio execucao dos jobs PLSSIPVAL",ARQUIVO_LOG)

	//Validacao dos produtos
	If lContinua .And. '1' $ cTipProc
		StartJob("PLSIPVLPR",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cRegANS,,,,lVlSemCom)
	EndIf

	//Validacao dos beneficiarios
	If lContinua .And. '2' $ cTipProc

		If nRecno = 0
			aEmpresas := ListaEmpresa(cRegANS)
			For nFor := 1 TO Len(aEmpresas)
				StartJob("PLSIPVLBN",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cRegANS,aEmpresas[nFor],,,.T.)
				aAdd(aJOBs, "B" + aEmpresas[nFor] + "(01)" )
				Sleep(1000)

			Next nFor
		Else
			PLSIPVLBN(cEmpAnt,cFilAnt,nil,DTOS(dDataBase),cRegANS,"",nRecno,"1",.F.)
		EndIf

	EndIf

	//Validacao dos eventos x despesa
	If lContinua .And. '3' $ cTipProc

		If MV_PLCENDB

			StartJob("PLSIPVLED",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cRegANS,0,0,"1",{})

		Else

			aRange := ListaRanges(cRegANS,cDataRef)
			If Len(aRange) > 0

				For nFor := 1 TO Len(aRange)
					StartJob("PLSIPVLED",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aThreads,cDataRef,cRegANS,aRange[nFor,1],aRange[nFor,2],AllTrim(Str(nFor))/*cTriOco*/,aJOBs)
					Sleep(2000)
				Next nFor

			EndIf

		EndIf

	EndIf

	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

	PlsLogFil(CENDTHRL("I") + " Termino execucao dos jobs PLSSIPVAL",ARQUIVO_LOG)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AdicionaThreads

Funcao criada para alimentar de forma padronizada a matriz de threads

@param aThreads		Matriz com as informacoes referente as threads
@param nTipProc		Tipo de processamento a ser realizado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AdicionaThreads(aThreads,nTipProc)
	Default aThreads	:= {}
	Default nTipProc	:= 0

	aAdd(aThreads,{;
		{2},;								//01-
		"JobSIP"+StrZero(nTipProc,2),;		//02-
		"Nao",;								//03-
		nTipProc,;							//04-
		0,;									//05-
		Time(),;							//06-
		"",;								//07-
		"",;								//08-
		"JobSIPSta"+StrZero(nTipProc,2),;	//09-
		"BR_VERDE",;						//10-
		"JobSIPPerc"+StrZero(nTipProc,2),;	//11-
		Nil,;								//12-
		"JobSIPProc"+StrZero(nTipProc,2),;	//13-
		"JobSIPEvPr"+StrZero(nTipProc,2),;	//14-
		0,;									//15-
		"JobSIPEvDs"+StrZero(nTipProc,2),;	//16-
		0,;									//17-
		"Normal",;							//18-
		0,;									//19-
		0,;									//20-
		.F.,;								//21-
		{},;								//22-
		})

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPVLPR

Funcao criada para validar os registros de produtos da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPVLPR(cEmp,cFil,aThreads,cDataRef,cRegANS,nRecno,lJob,cTipoVal,lVlSemCom)

	Local lRetorno    := .T.
	Local cCodObri    := ""
	Local cAnoComp    := ""
	Local cCodComp    := ""
	Local cAlias      := "TRBPRO"
	Local aCritProd   := {}
	Local aDescSolu   := {}
	Local nThread     := 0
	Local nQuinzena   := 1
	Local nRegSel     := 0
	Local nRegPro     := 0
	Local cNomJob     := ""
	Local cDesJob     := ""
	Local cNomPrc     := ""
	Local cObs        := ""
	Local cDatExe     := ""
	Local cHorExe     := ""
	Local lMV_PLCENDB := .F.
	Default cEmp      := ""
	Default cFil      := ""
	Default aThreads  := {}
	Default cDataRef  := DTOS(dDataBase)
	Default cRegANS   := ""
	Default nRecno    := 0
	Default lJob      := .T.
	Default lVlSemCom := .F.

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	PlsLogFil(CENDTHRL("I") + " Inicio PLSIPVLPR",ARQUIVO_LOG)
	lMV_PLCENDB	:= MV_PLCENDB
	PtInternal(1,AllTrim("PLSIPVLPR: " + " validando produtos"))

	aAdd(aDescSolu,{"Segmentacao do produto nao informada"					,"Informe a segmentacao do produto"				})
	aAdd(aDescSolu,{"Segmentacao do produto informada e invalida"			,"Altere a segmentacao informada no produto"	})
	aAdd(aDescSolu,{"Forma de contratacao do produto nao informada"			,"Informe a forma de contratacao do produto"	})
	aAdd(aDescSolu,{"Forma de contratacao do produto informada e invalida"	,"Altere a forma de contratacao do produto"		})

	aAdd(aCritProd,{"P001","","PSegVazia",aDescSolu[1,1],aDescSolu[1,2]})
	aAdd(aCritProd,{"P002","","PSegValid",aDescSolu[2,1],aDescSolu[2,2]})
	aAdd(aCritProd,{"P003","","PForVazia",aDescSolu[3,1],aDescSolu[3,2]})
	aAdd(aCritProd,{"P004","","PForValid",aDescSolu[4,1],aDescSolu[4,2]})

	If CarregaDados(cAlias,cDataRef,cRegANS,,nRecno)

		If LocalizaCompromisso(cDataRef,@cCodObri,@cAnoComp,@cCodComp,cRegANS,lVlSemCom)

			cTriRec	:= DataTrimestre(cDataRef)
			cNomJob := CENNOMJOB(nThread,nQuinzena,"PLSVLDPRO",.F.)[1]
			cDesJob := CENNOMJOB(nThread,nQuinzena,"PLSVLDPRO",.F.)[2]

			cDatExe := DTOS(dDataBase)
			cHorExe	:= Time()
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

			While !TRBPRO->(Eof())

				B3J->(dbGoTo(TRBPRO->R_E_C_N_O_))
				PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritProd,"B3J",TRBPRO->R_E_C_N_O_,{},nil,"1",{},B3J->B3J_CODIGO,B3J->B3J_DESCRI,"1",B3J->(B3J_CODOPE+B3J_CODIGO))
				TRBPRO->(dbSkip())
				cObs := AllTrim(Str(nRegPro)) + " produtos processados"
				CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)

			EndDo //!TRBPRO->(Eof())

			CENSTACOMP(cRegANS,cCodObri,cAnoComp,cCodComp)

			cObs := cNomJob + " concluído!"
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)
		Else
			cMsg := CENDTHRL("E") + "PLSIPVLPR. Não foi possivel localizar o compromisso. Operadora:"+cRegANS+";Data:"+cDataRef
			PlsLogFil(cMsg,ARQUIVO_LOG)
		EndIf//LocalizaCompromisso
	Else
		cMsg := CENDTHRL("I") + "PLSIPVLPR. Não localizou produtos para validar. Operadora:"+cRegANS+";Data:"+cDataRef
		PlsLogFil(cMsg,ARQUIVO_LOG)
	EndIf //CarregaDados()

	TRBPRO->(dbCloseArea())

	PlsLogFil(CENDTHRL("I") + " Termino PLSIPVLPR",ARQUIVO_LOG)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPVLBN

Funcao criada para validar os registros de beneficiarios da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cEmpresa		Codigo do grupo empresa

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPVLBN(cEmp,cFil,aThreads,cDataRef,cRegANS,;
		cEmpresa,nRecno,cObri, lJob)
	Local lRetorno		:= .T.
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= "TRBBEN"
	Local cMsg		 	:= ""
	Local aCritBen		:= {}
	Local aDescSolu		:= {}
	Local aAtuCob		:= {}
	Local nContador		:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 1
	Local nRegSel		:= 0
	Local nRegPro		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cNomPrc		:= ""
	Local cObs		:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= .F.
	Default cEmp 		:= ""
	Default cFil		:= ""
	Default aThreads	:= {}
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default cEmpresa	:= ""
	Default nRecno		:= 0
	Default cObri		:= "1"
	Default lJob		:= .T.


	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	lMV_PLCENDB	:= MV_PLCENDB
	PlsLogFil(CENDTHRL("I") + " Inicio PLSIPVLBN" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)

	PtInternal(1,AllTrim("PLSIPVLBN " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]","") + ": " + " validando beneficiarios"))

	aAdd(aDescSolu,{"Data de nascimento do beneficiario nao informada"			,"Informe a data de nascimento do beneficiario"	})
	aAdd(aDescSolu,{"Data de inclusao / adesão do beneficiario não informada"	,"Informe a data de inclusão / adesao do beneficiario"	})
	aAdd(aDescSolu,{"UF do beneficiario não informada"							,"Informe uma UF válida para o beneficiario (NC, AC, AL, AM, AP, BA, CE, DF, ES, GO, MA, MG, MS, PA, PB, PE, PI, PR, RJ, RN, RO, RR, RS, SC, SE, SP ou TO)"})
	aAdd(aDescSolu,{"UF informado é invalida."									,"Informe uma UF válida para o beneficiario (NC, AC, AL, AM, AP, BA, CE, DF, ES, GO, MA, MG, MS, PA, PB, PE, PI, PR, RJ, RN, RO, RR, RS, SC, SE, SP ou TO)"})
	aAdd(aDescSolu,{"Produto do beneficiario nao informado"						,"Informe um produto para o beneficiario"	})
	aAdd(aDescSolu,{"Produto do beneficiario informado está invalido."		,"Atualize o cadastro do Produto/Plano"	})
	aAdd(aDescSolu,{"Produto do beneficiario informado não existe na central ."		,"Atualize o cadastro do Produto/Plano"	})

	aAdd(aCritBen,{"B082","","BProVazia"	,aDescSolu[5,1],aDescSolu[5,2],.F.,""})
	aAdd(aCritBen,{"B083","","BProValid"	,aDescSolu[6,1],aDescSolu[6,2],.F.,""})
	aAdd(aCritBen,{"B084","","BDtNscVazia"	,aDescSolu[1,1],aDescSolu[1,2],.F.,""})
	aAdd(aCritBen,{"B085","","BDtIncVazia"	,aDescSolu[2,1],aDescSolu[2,2],.F.,""})
	aAdd(aCritBen,{"B086","","BUFVazia"		,aDescSolu[3,1],aDescSolu[3,2],.F.,""})
	aAdd(aCritBen,{"B087","","BUFValid"		,aDescSolu[4,1],aDescSolu[4,2],.F.,""})
	aAdd(aCritBen,{"B089","","BProExist"	,aDescSolu[7,1],aDescSolu[7,2],.F.,""})

	If CarregaDados(cAlias,cDataRef,cRegANS,cEmpresa,nRecno,0)

		If LocalizaCompromisso(cDataRef,@cCodObri,@cAnoComp,@cCodComp,cRegANS)

			If lJob

				cNomAux	:= Iif(Empty(cEmpresa),"00000000",cEmpresa)
				cTriRec	:= DataTrimestre(cDataRef)
				cNomJob := CENNOMJOB(nThread,nQuinzena,"B"+cNomAux,.F.,cNomAux)[1]
				cDesJob := CENNOMJOB(nThread,nQuinzena,"B"+cNomAux,.F.,cNomAux)[2]

				cDatExe := DTOS(dDataBase)
				cHorExe	:= Time()
				CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

			EndIf

			While !TRBBEN->(Eof())

				nContador++
				B3K->(dbGoTo(TRBBEN->R_E_C_N_O_))
				PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
					"B3K",TRBBEN->R_E_C_N_O_,@aAtuCob,nil,"1",;
					{},B3K->B3K_MATRIC,B3K->B3K_NOMBEN,cObri,B3K->B3K_CODCCO+B3K->B3K_MATRIC)

				TRBBEN->(dbSkip())

				If nContador % 100 == 0 .Or. nContador == 1
					PtInternal(1,AllTrim("PLSIPVLBN " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					If lJob
						cObs := AllTrim(Str(nContador)) + " beneficiários processados"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					Endif
				EndIf

			EndDo //!TRBBEN->(Eof())

			If lJob
				CENSTACOMP(cRegANS,cCodObri,cAnoComp,cCodComp)
				cObs := cNomJob + " concluído!"
				CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)
			EndIf
		Else
			cMsg := "Não localizou obrigação do SIP ativa para a operadora informada:" + cRegANS
			If !lJob
				msgAlert(cMsg)
			EndIf
			PlsLogFil(CENDTHRL("I") + " " + cMsg,ARQUIVO_LOG)
		EndIf
		//Se houve alguma atualização de cobertura, marco para resintetizar os beneficiários dos compromissos
		If Len(aAtuCob) > 0
			AtuCompBen(cRegANS,cCodObri,aAtuCob[1][1],aAtuCob[1][2])
		EndIf
	Else
		cMsg := "Não localizou dados para validar"
		If !lJob
			msgAlert(cMsg)
		EndIf
		PlsLogFil(CENDTHRL("I") + " " + cMsg,ARQUIVO_LOG)
	EndIf //CarregaDados()

	TRBBEN->(dbCloseArea())

	PlsLogFil(CENDTHRL("I") + " Termino PLSIPVLBN" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuCompBen

Marca para resintetizar os beneficiários dos compromissos

@param cCodOpe		Numero de registro da operadora na ANS
@param cCodObri		Chave da obrigacao
@param cTriInc		Trimestre de inclusao
@param cTriBlo		Trimestre de bloqueio

@return lRet		retorno logico indicando se a operação ocorreu com sucesso

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtuCompBen(cCodOpe,cCodObri,cTriInc,cTriBlo)
	Local lRet	:= .T.
	Local cSql	:= ""
	Local nRet := 0
	Local cAnoInc := Left(cTriInc,4)
	Local cObrInc := "0" + RIGHT(cTriInc,2)
	Local cAnoBlo := Left(cTriBlo,4)
	Local cObrBlo := "0" + RIGHT(cTriBlo,2)

	cSql := " UPDATE " + RetSqlName('B3D') + " SET B3D_SNTBEN='1' "
	cSql += " WHERE "
	cSql += "	B3D_FILIAL = '" + xFilial('B3D') + "' "
	cSql += "	AND B3D_CODOPE = '" + cCodOpe + "' "
	cSql += "	AND B3D_CDOBRI = '" + TRBCOM->B3D_CDOBRI + "' "
	cSql += "	AND B3D_ANO  BETWEEN '" + cAnoInc + "' AND '" + cAnoBlo + "' "
	cSql += "	AND B3D_CODIGO  BETWEEN '" + cObrInc + "' AND '" + cObrBlo + "' "
	cSql += "	AND B3D_STATUS < '6' "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPVLED

Funcao criada para validar os registros de beneficiarios da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param nRecIni		Limite inferior do range de recnos
@param nRecFim		Limite superior do range de recnos
@param cThread		Numero da thread em execucao

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPVLED(cEmp,cFil,aThreads,cDataRef,cRegANS,nRecIni,nRecFim,cThread,aJOBs,lJob)
	Local lRetorno		:= .T.
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= "TRBDES"
	Local aCritBen		:= {}
	Local aCritTot		:= {}
	Local aDescSolu		:= {}
	Local nContador		:= 0
	Local lValido		:= .T.
	Local nQuinzena		:= 1
	Local nRegSel		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cNomPrc		:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= .F.

	Private __cError	:= ""
	Private __cCallStk	:= ""

	Default cEmp 		:= ""
	Default cFil		:= ""
	Default aThreads	:= {}
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default nRecIni		:= 0
	Default nRecFim		:= 0
	Default cThread		:= "1"
	Default aJOBs		:= {}
	Default lJob		:= .T.


	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	lMV_PLCENDB	:= MV_PLCENDB
	PlsLogFil(CENDTHRL("I") + " Inicio PLSIPVLED(" + cThread + ")",ARQUIVO_LOG)
	PtInternal(1,AllTrim("PLSIPVLED(" + AllTrim(cThread) + "): " + " validando despesas "))
	/* 100 posicoes
	aAdd(aDescSolu,{"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"})
	*/

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE

		aAdd(aDescSolu,/*001*/{"Trimestre de reconhecimento do evento x despesa nao informado"											,"Informe o trimestre de reconhecimento do evento x despesa"})
		aAdd(aDescSolu,/*002*/{"Trimestre de ocorrencia do evento x despesa nao informado"												,"Informe o trimestre de ocorrencia do evento x despesa"})
		aAdd(aDescSolu,/*003*/{"Matricula do beneficiario nao informada"																,"Informe a matricula do beneficiario para o evento x despesa"})
		aAdd(aDescSolu,/*004*/{"Chave de origem da despesa nao informada"																,"Informe a chave de origem do evento x despesa"})
		aAdd(aDescSolu,/*005*/{"Tipo de tabela para evento x despesa nao informado"														,"Informe o tipo de tabela do evento x despesa"})
		aAdd(aDescSolu,/*006*/{"Codigo de procedimento para evento x despesa nao informado"												,"Informe o codigo de procedimento do evento x despesa"})
		aAdd(aDescSolu,/*007*/{"Data de realizacao do evento x despesa nao informado"													,"Informe a data de realizacao do evento x despesa"})
		aAdd(aDescSolu,/*008*/{"Quantidade realizada do evento x despesa nao informado"													,"Informe a quantidade realizada do evento x despesa"})
		aAdd(aDescSolu,/*009*/{"Valor de pagamento do evento x despesa nao informado ou informado como zero"							,"Informe um valor de pagamento maior que zero para o evento x despesa"})
		aAdd(aDescSolu,/*010*/{"Classificacao ambulatorial do evento x despesa nao informado"											,"Informe uma classificacao ambulatorial ou de internacao para o evento x despesa"})
		aAdd(aDescSolu,/*011*/{"Classificacao de internacao do evento x despesa nao informado"											,"Informe uma classificacao ambulatorial ou de internacao para o evento x despesa"})
		aAdd(aDescSolu,/*012*/{"Grupo de internacao do evento x despesa nao informado ou invalido"										,"Informe um grupo de internacao para o evento x despesa de internacao"})
		aAdd(aDescSolu,/*013*/{"Regime de internacao do evento x despesa nao informado ou invalido"										,"Informe um regime de atendimento para o evento x despesa de internacao"})
		aAdd(aDescSolu,/*014*/{"Beneficiario informado invalido no cadastro de beneficiario"											,"Atualize o cadastro do beneficiário informado no evento x despesa para que fique com status Valido "})
		aAdd(aDescSolu,/*015*/{"Beneficiario informado nao encontrado na tabela de beneficiario"										,"Informe um beneficiario existente e valido no cadastro de beneficiario para o evento x despesa"})
		aAdd(aDescSolu,/*016*/{"Produto informado invalido no cadastro de produto"														,"O codigo do produto / plano informado no evento x despesa nao esta valido no cadastro de produto / plano"})
		aAdd(aDescSolu,/*017*/{"Produto informado nao encontrado no cadastro de produto"												,"Informe um produto / plano existente e valido no cadastro de beneficiario para o evento x despesa"})
		aAdd(aDescSolu,/*018*/{"O somatorio dos itens 1-Cons. Amb. e 2-Cons. PS nao correspondem ao total do item A-Cons. Med."			,"Verifique os itens 1-Cons. Amb. e 2-Cons. PS para encontrar a diferenca em relacao ao item A-Cons. Med."})
		aAdd(aDescSolu,/*019*/{"Vlr. item B-Out. Aten. Amb. nao deve se restringir a soma dos itens 1 a 5 considere outros itens B"		,"O valor do item B-Out. Aten. Amb. deve ser maior que a soma dos itens de 1 a 5. Verifique outros itens B"})
		aAdd(aDescSolu,/*020*/{"Total de despesa liq. (item IV) do grupo E1-Tipo Int. deve corresponder a soma dos itens E11-E15"		,"Verifique os itens E11 a E15 que devem corresponder ao item E-Internacoes"})
		aAdd(aDescSolu,/*021*/{"Beneficiario informado p/ internacao do grupo 3-Obstetrica deve ser do sexo feminino"					,"Informe um beneficiario do sexo feminino para o evento x despesa"})
		aAdd(aDescSolu,/*022*/{"Guia com procedimento de parto (normal / cesario) nao classificada no grupo 3-Obstetrica"				,"Classifique a guia com procedimento de parto no grupo 3-Obstetrica"})
		aAdd(aDescSolu,/*023*/{"Beneficiario informado para evento x despesa do grupo C50, C53, D05 e D06 deve ser do sexo feminino"	,"Informe um beneficiario do sexo feminino para o evento x despesa"})
		aAdd(aDescSolu,/*024*/{"Beneficiario informado para evento x despesa do grupo C61 deve ser do sexo masculino"					,"Informe um beneficiario do sexo masculino para o evento x despesa"})
		aAdd(aDescSolu,/*025*/{"Dente ou regiao nao encontrado para o evento x despesa odontologico"									,"Informe um dente x regiao para o evento x despesa odontologico"})
		aAdd(aDescSolu,/*026*/{"O somatorio dos itens E21..E23 devem corresponder ao total do item E2-Regime de Internação"				,"Verifique o que compoe os itens E21, E22 e E23 que devem corresponder ao total do item E2-Regime de Internação"})
		aAdd(aDescSolu,/*027*/{"O item A-Consultas nao pode ser menor do que a somatoria dos subitens A11 ate A125"						,"Verifique o que compoe os itens A11 ate A125 que deve ser menor ou igual ao item A-Consultas"})
		aAdd(aDescSolu,/*028*/{"O item C-Exames nao pode ser menor do que a somatoria dos subitens C1 ate C20"							,"Verifique o que compoe os itens C1 ate C20 que deve ser menor ou igual ao item C-Exames"})
		aAdd(aDescSolu,/*029*/{"O item C10-Mamografia nao pode ser menor que o subitem C101 Mamografia de 50 a 69 anos"					,"Verifique o que compoe o item C101 que deve ser menor ou igual ao item C10-Mamografia"})
		aAdd(aDescSolu,/*030*/{"O evento não possui estado informado"																	,"Informe o estado onde foi executado o evento"})
		aAdd(aDescSolu,/*031*/{"O beneficiário informado para o evento C101 deve ser do sexo feminino e ter entre 50 e 69 anos no momento do exame."			,"Informe um beneficiário com idade válida"})
		aAdd(aDescSolu,/*032*/{"O beneficiário informado para o evento C101 deve ser do sexo feminino."									,"Informe um beneficiário com sexo válido"})
		aAdd(aDescSolu,/*033*/{"Registro de subitem (filho) encontrado sem registro de item (pai) "										,"Verifique os dados na origem da despesa ou transforme este registro em outras despesas"})
		aAdd(aDescSolu,/*034*/{"Procedimento de parto sem vinculo com internacao"														,"Vincule a despesa a uma internacao"})
		aAdd(aDescSolu,/*035*/{"UF informada na depesa ou registro é inválida"															,"Informe uma UF valida na origem do evento x despesa"})
		aAdd(aDescSolu,/*036*/{"Trimestre de ocorrencia posterior ao trimestre de reconhecimento"										,"Informe uma data dentro do periodo do trimestre para o evento x despesa"})
		aAdd(aDescSolu,/*037*/{"Evento x Despesa classificado como internação mas não possui interanção/grupo/regime"					,"Informe a internação/grupo/regime para o evento x despesa"})
		aAdd(aDescSolu,/*038*/{"Beneficiário vinculado a despesa ainda não foi validado"												,"Aguarde a validação do beneficiário vinculado que ainda não foi validado"})

		aAdd(aCritBen,{"E001","","ETriRecVaz"	,aDescSolu[01,1],aDescSolu[01,2],.F.})
		aAdd(aCritBen,{"E002","","ETriOcoVaz"	,aDescSolu[02,1],aDescSolu[02,2],.F.})
		aAdd(aCritBen,{"E003","","EMatriVaz"	,aDescSolu[03,1],aDescSolu[03,2],.F.})
		aAdd(aCritBen,{"E004","","EChavVazia"	,aDescSolu[04,1],aDescSolu[04,2],.F.})
		aAdd(aCritBen,{"E005","","ETipTabVaz"	,aDescSolu[05,1],aDescSolu[05,2],.F.})
		aAdd(aCritBen,{"E006","","ECodProVaz"	,aDescSolu[06,1],aDescSolu[06,2],.F.})
		aAdd(aCritBen,{"E007","","EDatRelVaz"	,aDescSolu[07,1],aDescSolu[07,2],.F.})
		aAdd(aCritBen,{"E008","","EQtdRelVaz"	,aDescSolu[08,1],aDescSolu[08,2],.F.})
		aAdd(aCritBen,{"E010","","EClasVazia"	,aDescSolu[10,1],aDescSolu[10,2],.F.})
		aAdd(aCritBen,{"E011","","EClasVazia"	,aDescSolu[11,1],aDescSolu[11,2],.F.})
		aAdd(aCritBen,{"E012","","EGrpIntVaz"	,aDescSolu[12,1],aDescSolu[12,2],.F.})
		aAdd(aCritBen,{"E013","","ERegAteVaz"	,aDescSolu[13,1],aDescSolu[13,2],.F.})
		aAdd(aCritBen,{"E014","","EBenValido"	,aDescSolu[14,1],aDescSolu[14,2],.F.})
		aAdd(aCritBen,{"E015","","EBenExiste"	,aDescSolu[15,1],aDescSolu[15,2],.F.})
		aAdd(aCritBen,{"E016","","EProValido"	,aDescSolu[16,1],aDescSolu[16,2],.F.})
		aAdd(aCritBen,{"E017","","EProExiste"	,aDescSolu[17,1],aDescSolu[17,2],.F.})
		aAdd(aCritBen,{"E021","","EBenefFemi"	,aDescSolu[21,1],aDescSolu[21,2],.F.})
		aAdd(aCritBen,{"E022","","EGuiParObs"	,aDescSolu[22,1],aDescSolu[22,2],.F.})
		aAdd(aCritBen,{"E023","","EBenFemiC5"	,aDescSolu[23,1],aDescSolu[23,2],.F.})
		aAdd(aCritBen,{"E024","","EBenefMasc"	,aDescSolu[24,1],aDescSolu[24,2],.F.})
		//		aAdd(aCritBen,{"E030","","EEstVazio"	,aDescSolu[30,1],aDescSolu[30,2],.F.})
		aAdd(aCritBen,{"E031","","EBeFem5069"	,aDescSolu[31,1],aDescSolu[31,2],.F.})
		aAdd(aCritBen,{"E034","","EParSemInt"	,aDescSolu[34,1],aDescSolu[34,2],.F.})
		aAdd(aCritBen,{"E035","","SIPUFInval"	,aDescSolu[35,1],aDescSolu[35,2],.F.})
		aAdd(aCritBen,{"E036","","SIPTriInva"	,aDescSolu[36,1],aDescSolu[36,2],.F.})
		aAdd(aCritBen,{"E037","","EItemSVin"	,aDescSolu[37,1],aDescSolu[37,2],.F.})
		//Criticas totalizadoras
		aAdd(aCritTot,{"E018","","ESomaItem1"	,aDescSolu[18,1],aDescSolu[18,2],.T.})/*01*/
		aAdd(aCritTot,{"E019","","ESomaItemB"	,aDescSolu[19,1],aDescSolu[19,2],.T.})/*02*/
		aAdd(aCritTot,{"E020","","ETotalIteE"	,aDescSolu[20,1],aDescSolu[20,2],.T.})/*03*/
		aAdd(aCritTot,{"E026","","ESomIteEX"	,aDescSolu[26,1],aDescSolu[26,2],.T.})/*04*/
		aAdd(aCritTot,{"E027","","ESomIteA1"	,aDescSolu[27,1],aDescSolu[27,2],.T.})/*05*/
		aAdd(aCritTot,{"E028","","ESomIteCs"	,aDescSolu[28,1],aDescSolu[28,2],.T.})/*06*/
		aAdd(aCritTot,{"E029","","ESomMamo"		,aDescSolu[29,1],aDescSolu[29,2],.T.})/*07*/
		aAdd(aCritTot,{"E033","","ESubSemItem"	,aDescSolu[33,1],aDescSolu[33,2],.T.})/*08*/
		aAdd(aCritTot,{"E035","","SIPUFInval"	,aDescSolu[35,1],aDescSolu[35,2],.T.})/*09*///Como ja totalizei posso ter totais com UF invalido
		aAdd(aCritTot,{"E036","","SIPTriInva"	,aDescSolu[36,1],aDescSolu[36,2],.T.})/*10*/
		aAdd(aCritTot,{"E000","","AllwaysTrue"	,aDescSolu[26,1],aDescSolu[26,2],.T.})/*11*/

		If LocalizaCompromisso(cDataRef,@cCodObri,@cAnoComp,@cCodComp,cRegANS)

			cTriRec	:= DataTrimestre(cDataRef)
			cNomJob := CENNOMJOB(1,nQuinzena,"VLD"+cThread,.F.,cThread)[1]
			cDesJob := CENNOMJOB(1,nQuinzena,"VLD"+cThread,.F.,cThread)[2]
			cDatExe := DTOS(dDataBase)
			cHorExe	:= Time()
			cObs := "Iniciando validação de despesas"
			If nRecIni > 0 .And. nRecFim > 0
				cObs += " de " + AllTrim(Str(nRecIni)) + " ate " + AllTrim(Str(nRecFim))
			EndIf

			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

			If Len(aJOBs) > 0//Vou esperar validar beneficiarios
				CENNEXTJOB(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",aJOBs,900000)
			EndIf

			VerificaCriticaBenef(cRegANS,cCodObri,cAnoComp,cCodComp)

			If CarregaDados(cAlias,cDataRef,cRegANS,"",nRecIni,nRecFim,cTriRec)
				nContador:= 0

				While !TRBDES->(Eof())

					nContador++
					B3L->(dbGoTo(TRBDES->R_E_C_N_O_))
					lValido := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,"B3L",TRBDES->R_E_C_N_O_,{},nil,"1",{},B3L->B3L_EVEDES,"","1",B3L->(B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+;
						B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)+B3L_EVDEIN))

					If nContador % 1000 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIPVLED(" + cThread + ") " + cTriRec + " : " + AllTrim(Str(nContador)) + " registros detalhes validados"))
						cObs := AllTrim(Str(nContador)) + " registros processados "
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					TRBDES->(dbSkip())

				EndDo //!TRBDES->(Eof())

				TRBDES->(dbCloseArea())

			Else
				PlsLogFil(CENDTHRL("I") + " Nenhum dado encontrado para validar - CarregaDados",ARQUIVO_LOG)
			EndIf //CarregaDados()

			//ValidaTotais(cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,nRecIni,nRecFim,aCritTot,cThread)

			CENSTACOMP(cRegANS,cCodObri,cAnoComp,cCodComp)
			cObs := cNomJob + " concluído!"
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

		Else
			PlsLogFil(CENDTHRL("I") + " Nenhum compromisso encontrado para a data " + cDataRef,ARQUIVO_LOG)
		EndIf //LocalizaCompromisso

	END SEQUENCE
	ErrorBlock(bBlock)

	PlsLogFil(CENDTHRL("I") + " Termino PLSIPVLED(" + cThread + ")",ARQUIVO_LOG)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} NOMEFUNCTION

Funcao criada para capturar um erro que ocorreu durante o processo

@param e	Referencia ao erro encontrado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e)

	__cError := e:Description
	__cCallStk := e:ErrorStack

	PlsLogFil(CENDTHRL("E") + " Erro durante a validação. Erro: " + __cError + " CallStack: " + __cCallStk ,ARQUIVO_LOG)
	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LocalizaCompromisso

Funcao criada para alimetar as variaveis referente a chave do compromisso se este for encontrado

@param cDataReal	Data de realizacao ou database
@param cCodObri		Chave do obrigacao
@param cAnoComp		Ano do compromisso
@param cCodComp		Codigo do compromisso
@param cRegANS		Numero de registro da operadora na ANS

@return lRetorno	Retorna Verdadeiro (.T.) se localizou ou Falso (.F.) caso nao encontre

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function LocalizaCompromisso(cDataRef,cCodObri,cAnoComp,cCodComp,cRegANS,lVlSemCom)

	Local lRetorno    := .T.
	Local cAliasN     := getNextAlias()
	Local cSql        := ""
	Local cDataReal   := ""
	Default cDataRef  := DTOS(dDataBase)
	Default cCodObri  := ""
	Default cAnoComp  := ""
	Default cCodComp  := ""
	Default cRegANS   := '000000'
	Default lVlSemCom := .F.

	cDataReal := DataTrimestre(cDataRef)

	cSql := "SELECT B3A_CODIGO, B3D_ANO, B3D_CODIGO, B3A.R_E_C_N_O_ B3ARECNO, B3D.R_E_C_N_O_ B3DRECNO "
	cSQL += " FROM "
	cSQL += " " + RetSqlName("B3A") + " B3A, "
	cSQL += " " + RetSqlName("B3D") + " B3D  "
	cSQL += " WHERE "
	cSQL += " B3A_FILIAL = '" + xFilial("B3A") + "' "
	cSQL += " AND B3A_CODOPE = '" + cRegANS + "' "
	If !lVlSemCom // Quando permitido validar sem compromisso
		cSQL += " AND B3A_TIPO = '" + OBR_SIP + "' "
		cSQL += " AND B3D_CODIGO = '0" + Right(cDataReal,2) + "' "  //Essa data é obtida utilizando os trimestres. Dessa forma, não pode ser considerado pelo SIB.
	EndIf
	cSQL += " AND B3A_ATIVO = '1' "
	cSQL += " AND B3D_FILIAL = B3A_FILIAL "
	cSQL += " AND B3D_CODOPE = B3A_CODOPE "
	cSQL += " AND B3D_CDOBRI = B3A_CODIGO "
	cSQL += " AND B3D_ANO = '" + Left(cDataReal,4) + "' "
	cSQL += " AND B3D_STATUS <> '" + FINALIZADO + "' "
	cSQL += " AND B3A.D_E_L_E_T_ = ' '"
	cSQL += " AND B3D.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY B3D_CDOBRI, B3D_CODIGO"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	PlsLogFil(CENDTHRL("I") + " LocalizaCompromisso: " + cSQL,ARQUIVO_LOG)

	If (cAliasN)->(Eof())
		lRetorno := .F.
	Else
		cCodObri := (cAliasN)->B3A_CODIGO
		cAnoComp := (cAliasN)->B3D_ANO
		cCodComp := (cAliasN)->B3D_CODIGO
	EndIf

	B3A->(dbGoTo((cAliasN)->(B3ARECNO) ) )
	B3D->(dbGoTo((cAliasN)->(B3DRECNO) ) )
	(cAliasN)->(dbCloseArea())

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo		Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo)
	Local cArquivo		:= 'job_eventodespesa.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FCreate(cArquivo)

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados

Funcao cria a area de trabalho TRBXXX com as informacoes de produtos, beneficiarios ou despesas a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cEmpresa		Codigo do grupo empresa
@param nRecIni		Limite inferior do range de recnos
@param nRecFim		Limite superior do range de recnos

@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaDados(cAlias,cDataRef,cRegANS,cEmpresa,nRecIni,nRecFim,cTriRec)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= '000000'
	Default cEmpresa	:= ""
	Default nRecIni		:= 0
	Default nRecFim		:= 0
	Default cTriRec		:= ""

	If cAlias == "TRBPRO"

		cSql := " SELECT R_E_C_N_O_ FROM " + RetSqlName("B3J") + " "
		cSql += " WHERE "

		If nRecIni > 0
			cSql += " R_E_C_N_O_ = " + AllTrim(Str(nRecIni)) + " "
		Else
			cSql += " B3J_FILIAL = '" + xFilial("B3J") + "' "
			cSql += " AND B3J_CODOPE = '" + cRegANS + "' "
			cSql += " AND B3J_STATUS <> '2' "
			cSql += " AND D_E_L_E_T_ = ' '"
		EndIf

	ElseIf cAlias == "TRBBEN"

		cSql := " SELECT R_E_C_N_O_ FROM " + RetSqlName("B3K") + " "
		If nRecIni > 0
			cSql += "WHERE R_E_C_N_O_ = " + AllTrim(Str(nRecIni)) + " "
		Else
			cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' AND B3K_CODOPE = '" + cRegANS + "' "
			If !Empty(cEmpresa)
				cSql += "AND SUBSTRING(B3K_MATRIC,1,8) = '" + AllTrim(cEmpresa) + "' "
			EndIf
			cSql += "AND B3K_STATUS <> '2' AND D_E_L_E_T_ = ' '"
		EndIf

	ElseIf cAlias == "TRBDES"

		cSql := " SELECT B3L.R_E_C_N_O_,B3L_EVEDES,B3L_MATRIC,B3L_CDTPTB,B3L_CODEVE,B3L_CLAAMB,B3L_CLAINT,B3L_FORCON,B3L_SEGMEN,B3L_DATEVE,B3L_EVDEIN "
		cSql += " FROM "
		cSql += RetSqlName("B3L") + " B3L "
		cSql += " WHERE "
		cSql += " 	B3L_FILIAL = '" + xFilial("B3L") + "' "
		cSql += " 	AND B3L_CODOPE = '" + cRegANS + "' "
		If !Empty(cTriRec)
			cSql += " AND B3L_TRIREC = '" + cTriRec + "' "
		EndIf
		cSql += " 	AND B3L_STATUS <> '2' "
		cSql += " 	AND B3L_EVEDES <> B3L_MATRIC "
		cSql += " 	AND B3L.D_E_L_E_T_ = ' ' "

		If nRecIni > 0
			cSql += "AND R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRecIni)) + " AND " + AllTrim(Str(nRecFim)) + " "
		EndIf

	ElseIf cAlias == "TRBTOT"

		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3L") + " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
		cSql += "AND B3L_CODOPE = '" + cRegANS + "' AND B3L_STATUS <> '2' AND B3L_EVEDES = B3L_MATRIC AND D_E_L_E_T_ = ' '"
		If nRecIni > 0
			cSql += "AND R_E_C_N_O_ BETWEEN " + AllTrim(Str(nRecIni)) + " AND " + AllTrim(Str(nRecFim)) + " "
		EndIf

	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	If cAlias == "TRBBEN"
		PlsLogFil(CENDTHRL("I") + " " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)
	ElseIf cAlias == "TRBDES"
		PlsLogFil(CENDTHRL("I") + " " + cAlias + "(" + AllTrim(Str(nRecIni)) + "/" + AllTrim(Str(nRecFim)) + "): " + cSql,ARQUIVO_LOG)
	ElseIf cAlias == "TRBPRO"
		PlsLogFil(CENDTHRL("I") + " " + cAlias + "(" + cRegANS + "): " + cSql,ARQUIVO_LOG)
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPRTV

Funcao criada para retornar a lista de rotinas / jobs de validacao

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - Produtos / Plano
	2 - Beneficiarios
	3 - Eventos X Despesas

@return cDados		Lista de opcoes selecionadas no F3 separadas por virgula

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIPRTV(cDado)
	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local nFor		:= 0
	Local nOpc		:= 0
	Local bOK		:= { || nOpc := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Default cDado	:= ''

	aAdd(aConjunto,{'1','Produtos / Planos'	,.F.})
	aAdd(aConjunto,{'2','Beneficiarios'		,.F.})
	aAdd(aConjunto,{'3','Eventos x Despesas',.F.})

	DEFINE MSDIALOG oDlg TITLE 'Conjuntos a processar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT 'Selecione o(s) conjunto(s) a serem processados' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

	If nOpc == 1

		cDado := ""
		For nFor := 1 To Len(aConjunto)
			If aConjunto[nFor,3]
				cDado += aConjunto[nFor,1]+","
			Endif
		Next

	Endif

	//Tira a virgula do final
	If Subs(cDado,Len(cDado),1) == ","
		cDado := Subs(cDado,1,Len(cDado)-1)
	EndIf

Return nOpc == 1
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ListaEmpresa

Funcao criada para retornar a lista de empresas encontradas na tabela de beneficiarios

@param cRegANS		Numero de registro da operadora na ANS

@return aEmpresas	Matriz com o codigo das empresas encontradas

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function ListaEmpresa(cRegANS)
	Local aEmpresas := {}
	Local cSql		:= ""
	Default cRegANS	:= ""

	cSql := "SELECT DISTINCT SUBSTRING(B3K_MATRIC,1,8) B3K_MATRIC  FROM " + RetSqlName("B3K") + " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += "AND B3K_CODOPE = '" + cRegANS + "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEMP",.F.,.T.)

	If !TEMP->(Eof())

		While !TEMP->(Eof())

			aAdd(aEmpresas,TEMP->B3K_MATRIC)
			TEMP->(dbSkip())

		EndDo

	EndIf

	TEMP->(dbCloseArea())

Return aEmpresas

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaTotais

Funcao criada para validar os registros totalizadores de despesa

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cCodObri		Chave da obrigacao
@param cAnoComp		Ano do compromisso
@param cCodComp		Chave do compromisso
@param nRecIni		Limite inferior do range de recnos
@param nRecFim		Limite superior do range de recnos
@param aCritTot		Matriz de criticas totalizadoras
@param cThread		Numero da thread em execucao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaTotais(cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,nRecIni,nRecFim,aCritTot,cThread)
	Local nContador		:= 0
	Local cItem			:= ""
	Local cAlias		:= "TRBTOT"
	Local aCriAux		:= {}
	Local lValido	:= .F.
	Local cSubItens	:= "E121,E122,E123,E124,E125,E126,E127,E131,E132,E141,E142"
	Default cDataRef	:= ""
	Default cRegANS	:= ""
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default nRecIni	:= 0
	Default nRecFim	:= 0
	Default aCritTot	:= {}
	Default cThread	:= "0"

	PlsLogFil(CENDTHRL("I") + " ValidaTotais Inicio RecIni: " + AllTrim(Str(nRecIni)) + " - RecFim: " + AllTrim(Str(nRecFim)),ARQUIVO_LOG)

	If CarregaDados(cAlias,cDataRef,cRegANS,"",nRecIni,nRecFim,cThread)

		While !TRBTOT->(Eof())

			nContador++
			B3L->(dbGoTo(TRBTOT->R_E_C_N_O_))
			cItem := AllTrim(B3L->B3L_CLAAMB)

			//Para todos os registros preciso validar E035, E036
			aCriAux := {aCritTot[9]}//UF INVALIDO
			lValido := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCriAux,"B3L",B3L->(Recno()),{},nil,"1",{},B3L->B3L_EVEDES,"","1",;
				B3L->(B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)+B3L_EVDEIN))
			aCriAux := {aCritTot[10]}//TRIOCO INVALIDO
			lValido := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCriAux,"B3L",B3L->(Recno()),{},nil,"1",{},B3L->B3L_EVEDES,"","1",;
				B3L->(B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)+B3L_EVDEIN))

			If cItem == "A"//Validar o item A - critica E018
				aCriAux := {aCritTot[1]}
			ElseIf cItem == "B"//Validar o item B - critica E019
				aCriAux := {aCritTot[2]}
			ElseIf cItem $ "E11,E12,E13,E14,E15"//Validar o itens E11..E15 - critica E020
				aCriAux := {aCritTot[3]}
			ElseIf cItem $ "E1,E2,E3"//Validar os itens E1,E2 e E3 - critica E026
				aCriAux := {aCritTot[4]}
			ElseIf cItem == "A1"//Validar o item A1 - critica E027
				aCriAux := {aCritTot[5]}
			ElseIf cItem == "C"//Validar o item C - critica E028
				aCriAux := {aCritTot[6]}
			ElseIf cItem == "C10"//Validar o item C - critica E029
				aCriAux := {aCritTot[7]}
			ElseIf cItem $ cSubItens//Validar subitem sem item
				aCriAux := {aCritTot[8]}
			Else
				aCriAux := {aCritTot[11]}
			EndIf

			If Len(aCriAux) > 0
				lValido := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCriAux,"B3L",B3L->(Recno()),{},nil,"1",{},B3L->B3L_EVEDES,"","1",;
					B3L->(B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)+B3L_EVDEIN))
			EndIf

			If nContador % 100 == 0 .Or. nContador == 1
				PtInternal(1,AllTrim("PLSIPVLED(" + cThread + "): " + AllTrim(Str(nContador)) + " registros totalizadores validados"))
			EndIf

			TRBTOT->(dbSkip())

		EndDo

		TRBTOT->(dbCloseArea())

	EndIf

	PlsLogFil(CENDTHRL("I") + " ValidaTotais Termino RecIni: " + AllTrim(Str(nRecIni)) + " - RecFim: " + AllTrim(Str(nRecFim)),ARQUIVO_LOG)

Return

/*
Funcao criada para definir o pergunte do schedule
*/
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P","PLSVALSIP",,aOrdem,""}

Return aParam

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataTrimestre

Funcao criada para transformar a data em trimestre valido para o SIP

@param cData	Data (AAAAMMDD) que sera transformata em trimestre (AAAAMM) ou AAAAMMDD inicial ou final do trimestre
@param nOpc		Tipo de retorno
	1 - monto o retorno da data AAAAMMDD inicial
	2 - monto o retorno da data AAAAMMDD final
	3 - default - monto o retorno do trimestre AAAAMM

@return cTrimestre	Retorno o trimestre identificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function DataTrimestre(cData,cOpc)
	Local nTrimestre	:= 1
	Local nAscan		:= 0
	Local cTrimestre	:= ""
	Local aPeriodos	:= {}
	Default cData		:= DTOS(dDataBase)
	Default cOpc		:= ""// "" - AAAADD, "1" - AAAAMMDD inicial, "2" - AAAAMMDD final

	aAdd(aPeriodos,{"01","02","03"})
	aAdd(aPeriodos,{"04","05","06"})
	aAdd(aPeriodos,{"07","08","09"})
	aAdd(aPeriodos,{"10","11","12"})

	//Identifico o trimestre que pertence a data
	nAscan := Ascan( aPeriodos,{|x| x[1] == Substr(cData,5,2) .Or. x[2] == Substr(cData,5,2) .Or. x[3] == Substr(cData,5,2)})
	If nAscan > 0//Devo proteger nTrimestre de receber zero
		nTrimestre := nAscan
	EndIf

	If cOpc == "1"//monto o retorno da data AAAAMMDD inicial

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,1]
		cTrimestre += "01"

	ElseIf cOpc == "2"//monto o retorno da data AAAAMMDD final

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,3]
		If nTrimestre == 1
			If SubStr(cTrimestre,5,2) == "02"
				If Val(SubStr(cTrimestre,1,4)) % 4 == 0
					cTrimestre += "29"
				Else
					cTrimestre += "28"
				EndIf
			Else
				cTrimestre += "31"
			EndIf
		Else
			If SubStr(cTrimestre,5,2) $ "04,06,09,10"
				cTrimestre += "30"
			Else
				cTrimestre += "31"
			EndIf
		EndIf

	Else//monto o retorno do trimestre AAAAMM
		cTrimestre := Substr(cData,1,4)+PADL(Alltrim(Str(nTrimestre)),2,"0")
	EndIf

Return cTrimestre

//Chamadas de funcoes para retirar os warnings de compilacao
SchedDef()
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DataTrimestre

Funcao criada para retornar as datas de referencia dos trimestres / compromissos encontrados
na tabela de eventos x despesas com registros para validar

@author timoteo.bega
@since 20/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetDatRef(cCodOpe)
	Local cMesDia 	:= ""
	Local cTri			:= ""
	Local cSql			:= ""
	Local cDataRef		:= ""
	Local cNArea	:= GetNextAlias()
	Local aRet		:= {}
	Default cCodOpe	:= ""

	cSql := "SELECT DISTINCT B3L_FILIAL,B3L_CODOPE,B3L_CODOBR,B3L_ANOCMP,B3L_CDCOMP, B3D_REFERE "
	cSql += "FROM " + RetSqlName('B3L') + " B3L, " + RetSqlName('B3D') + " B3D "
	cSql += "WHERE B3L_FILIAL = B3D_FILIAL AND B3L_CODOPE = B3D_CODOPE AND B3L_CODOBR = B3D_CDOBRI AND B3L_ANOCMP = B3D_ANO AND B3L_CDCOMP = B3D_CODIGO "
	cSql += "AND B3L_FILIAL='" + xFilial("B3L") + "' "
	cSql += "AND B3L_CODOPE='" + cCodOpe + "' AND B3L_STATUS <> '2' AND B3L.D_E_L_E_T_=' ' AND B3D.D_E_L_E_T_=' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNArea,.F.,.T.)

	If !(cNArea)->(Eof())

		While !(cNArea)->(Eof())

			cTri := SubStr((cNArea)->B3D_REFERE,1,1)

			If cTri == "1"
				cMesDia := "0331"
			ElseIf cTri == "2"
				cMesDia := "0630"
			ElseIf cTri == "3"
				cMesDia := "0930"
			Else
				cMesDia := "1231"
			EndIf

			cDataRef := AllTrim((cNArea)->B3L_ANOCMP) + cMesDia

			aAdd(aRet,cDataRef)
			(cNArea)->(dbSkip())

		EndDo

	EndIf

	(cNArea)->(dbCloseArea())

Return aRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerificaCriticaBenef

Funcao criada para marcar as despesas com status 1 para ser novamente validada pois teve alteracao
no beneficiario

@author timoteo.bega
@since 20/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function VerificaCriticaBenef(cRegANS,cCodObri,cAnoComp,cCodComp)
	Local lRet			:= .T.
	Local cSql			:= ""
	Default cRegANS	:= ""
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""

	cSql := " UPDATE " + RetSqlName('B3L') + " SET B3L_STATUS = '1' "
	cSql += " WHERE B3L_FILIAL='" + xFilial("B3L") + "' "
	cSql += " AND B3L_CODOPE='" + cRegANS + "' AND B3L_CODOBR='" + cCodObri + "' "
	cSql += " AND B3L_ANOCMP='" + cAnoComp + "' AND B3L_CDCOMP='" + cCodComp + "' "
	cSql += " AND B3L_STATUS='2' "
	cSql += " AND B3L_MATRIC IN ( "
	cSql += " 	SELECT B3K_MATRIC FROM " + RetSqlName('B3K') + " "
	cSql += " 		WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += " 		AND B3K_CODOPE = '" + cRegANS + "' "
	cSql += " 		AND B3K_STATUS = '1' "
	cSql += " 		AND D_E_L_E_T_ = ' ' ) "

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		nRet := TCSQLEXEC("COMMIT")
	Endif

	lRet := nRet >= 0

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ListaRanges

Retorna 10 ranges de registros de despesas para validar para bancos MSSQL
/*/
//--------------------------------------------------------------------------------------------------
Function ListaRanges(cRegANS,cDataRef)
	Local cSql		:= ""
	Local nInicio	:= 0
	Local nTermino	:= 0
	Local aLista	:= {}
	Local cAliTrb	:= GetNextAlias()
	Local cTriRec	:= DataTrimestre(cDataRef)

	cSql += " SELECT MIN(RECNO) RECINI "
	cSql += " 	,MAX(RECNO) RECFIM "
	cSql += " 	,PARTE "
	cSql += " FROM ( "
	cSql += " 	SELECT B3L.R_E_C_N_O_ RECNO "
	cSql += " 		,NTILE(10) OVER ( "
	cSql += " 			ORDER BY B3L.R_E_C_N_O_ "
	cSql += " 			) PARTE "
	cSql += " 	FROM " + RetSqlName("B3L") + " B3L "
	cSql += " 	WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
	cSql += " 		AND B3L_CODOPE = '" + cRegANS + "' "
	cSql += " 		AND B3L_TRIREC = '" + cTriRec + "' "
	cSql += " 		AND B3L_STATUS <> '2' "
	cSql += " 		AND B3L_EVEDES <> B3L_MATRIC "
	cSql += " 		AND B3L.D_E_L_E_T_ = ' ' "
	cSql += " 	) SUB "
	cSql += " GROUP BY PARTE "
	cSql += " ORDER BY PARTE "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

	While !(cAliTrb)->(Eof())

		nInicio := (cAliTrb)->RECINI
		nTermino := (cAliTrb)->RECFIM
		aAdd( aLista , {nInicio,nTermino} )
		(cAliTrb)->(DbSkip())
	EndDo

	(cAliTrb)->(dbCloseArea())

Return aLista

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENSTACOMP

Atualiza o status do compromisso para o status informado
/*/
//--------------------------------------------------------------------------------------------------
Function CENSTACOMP(cCodOpe,cCodObr,cAno,cCodComp,cStaCmp)
	Local cStComp		:= ""//Status do compromisso
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAno		:= ""
	Default cCodComp	:= ""
	Default cStaCmp		:= ""

	If !Empty(cStaCmp)//Caso queira atualizar o status passado em cStaCmp

		cStComp := cStaCmp

	Else

		//Verifico se o compromisso possui criticas.
		B3F->(dbSetOrder(3))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
		If B3F->(msSeek(xFilial('B3F')+cCodOpe+cCodObr+cAno+cCodComp+"1"))
			cStComp := '2'
		Else
			cStComp := '3'
		EndIf

	EndIf

	B3D->(dbSetOrder(1))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
	If B3D->(msSeek(xFilial('B3D')+cCodOpe+cCodObr+cAno+cCodComp))
		If B3D->B3D_STATUS != "6" .And. B3D->B3D_STATUS <> cStComp//somente se o status for diferente de 6-finalizado e for diferente do novo status = cStComp, para evitar reclock desnecessario
			Reclock("B3D",.F.)
			B3D->B3D_STATUS := cStComp//2=Criticado
			MsUnlock()
		EndIf
	EndIf

Return
