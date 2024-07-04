#include 'totvs.ch'
#include 'fileio.ch'
#include 'fwmvcdef.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#define ARQUIVO_LOG	"job_plssiptot.log"
#DEFINE MV_PLCENDB	GetNewPar("MV_PLCENDB",.F.)
#DEFINE BANCO			Alltrim(Upper(TCGetDb()))
#DEFINE SOMALISTA	01
#DEFINE ITEMA1		02
#DEFINE ITEMA		03
#DEFINE ITEMB		04
#DEFINE ITENSCS		05
#DEFINE ITEMC		06
#DEFINE ITEMC3		07
#DEFINE ITEMC10		08
#DEFINE ITEMC101	09
#DEFINE ITEMD		10
#DEFINE ITEMG		11
#DEFINE ITEMH		12
#DEFINE ITENSI3		13
#DEFINE EGRPINT		14//E11..E15
#DEFINE EREGINT		15//E21..E23
#DEFINE ITEME1		16//E1
#DEFINE ITEME2		17//E2
#DEFINE ITEME		18//E
#DEFINE ITEMF		19
#DEFINE SUBITENSFS	20
#DEFINE SUBITENSFX	21
#DEFINE SUBITENSI3	22
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

#DEFINE ITENSIS		23
#DEFINE ITEMI		24
#DEFINE ITENSF1		25
#DEFINE ITENSF2		26
#DEFINE ITENSF3		27
#DEFINE ITENSF4		28
#DEFINE ITENSF5		29
#DEFINE ITENSF11	30
#DEFINE ITENSF12	31
#DEFINE ITENSF13	32
#DEFINE ITENSF14	33
#DEFINE ITENSF34	34
#DEFINE ITEPARTO	35
#DEFINE ITECIRUR	36
#DEFINE ITEPEDIA	37

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPTOT

Funcao criada como job para gerenciar os jobs de totalizacao / finalizacao da carga inicial do SIP na Central

@author timoteo.bega
@since 13/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIPTOT(cEmpAnt,cFilAnt,cCodOpe,cDataRef,lSoTotaliza,lAuto)
	Local aFuncTotais		:= {}
	Local nFor				:= 0
	Local nArquivo			:= 0
	Local cCodObr			:= ""
	Local cAnoCmp			:= ""
	Local cCodCmp			:= ""
	Local cChvCom			:= ""
	Local cTriRec			:= ""
	Local cPLSSIPTOTSMF		:= "PLSSIPTOT_"+cDataRef+".SMF"
	Local lMV_PLCENDB		:= .F.
	Default cCodOpe			:= ""
	Default cDataRef		:= ""
	Default lSoTotaliza		:= .F.
	Default lAuto			:= .F.
	PRIVATE __cError 		:= ""
	PRIVATE __cCallStk 		:= ""

	If !lAuto
		RpcSetType(3)
		RpcSetEnv(cEmpAnt,cFilAnt,,,'PLS')
	EndIf
	lMV_PLCENDB	:= MV_PLCENDB
	cTriRec := DataTrimestre(cDataRef)
	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT Inicio. Operadora: " + cCodOpe + " Data Ref.: " + cDataRef
	PlsLogFil(cMsg,ARQUIVO_LOG)

	// bBlock := ErrorBlock( { |e| ChecErro(e) } )
	// BEGIN SEQUENCE
	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT Limpando semaforos"
	PlsLogFil(cMsg,ARQUIVO_LOG)

	FErase(cPLSSIPTOTSMF)
	cMsg := "[" + cTriRec + "] "+CENDTHRL("I") + " PLSSIPTOT PodeTotalizar - Limpando o arquivo: B3QTOB3L"+cTriRec+"1.SMF"
	PlsLogFil(cMsg,ARQUIVO_LOG)
	FErase("B3QTOB3L"+cTriRec+"1.SMF")
	FErase("B3QTOB3L"+cTriRec+"2.SMF")
	FErase("B3QTOB3L"+cTriRec+"3.SMF")
	FErase("B3QTOB3L"+cTriRec+"4.SMF")
	FErase("B3QTOB3L"+cTriRec+"5.SMF")
	FErase(cPLSSIPTOTSMF)
	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT PodeTotalizar - Aguardando 1 minuto para continuar"
	PlsLogFil(cMsg,ARQUIVO_LOG)
	Sleep(30000)
	LocalizaCompromisso(cTriRec,@cCodObr,@cAnoCmp,@cCodCmp,cCodOpe)
	cCodObri := cCodObr
	cCodComp := cCodCmp
	cAnoComp := cAnoCmp

	aJOBs := {"PLSIPDES(11)S","PLSIPDES(11)I","PLSIPDES(21)S","PLSIPDES(21)I","PLSIPDES(31)S","PLSIPDES(31)I","PLSIPACU(00)","PLSIPACU(10)","PLSIPACU(20)","PLSIPREE(10)","PLSIPREE(20)","PLSIPREE(30)","PLSIPEXP(10)","PLSIPEXP(20)","PLSIPEXP(30)","PLSIPEXP(40)","PLSIPEXP(50)","PLSIPEXP(60)"}
	cTriRec := DataTrimestre(cDataRef)
	CENNEXTJOB(cCodOpe,cCodObri,cAnoComp,cCodComp,cTriRec,"1",aJOBs,600000)

	cMsg := "[" + cTriRec + "] "+CENDTHRL("I") + " PLSSIPTOT executando... "
	PlsLogFil(cMsg,ARQUIVO_LOG)

	//abrir semaforo
	nArquivo := Semaforo('A',0,cPLSSIPTOTSMF,cTriRec)

	If nArquivo > 0

		If !lSoTotaliza//Quando .T. nao inicia nenhum job PLB3QTOB3L

			For nFor := 1 TO 5

				If nFor == 1
					cOpcao := 'A'//consulta
				ElseIf nFor == 2
					cOpcao := 'S1'//servico no trimestre de ocorrencia
				ElseIf nFor == 3
					cOpcao := 'S2'//servico diferente do trimestre de ocorrencia
				ElseIf nFor == 4
					cOpcao := 'I1'//internacao trimestre de reconhecimento igual de ocorrencia
				Else
					cOpcao := 'I2'//internacao trimestre de reconhecimento diferente de ocorrencia
				EndIf

				PtInternal(1,'Iniciando job PLB3QTOB3L ' + cOpcao + ' ' + AllTrim(Str(nFor)) + '/5' )
				PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT[" + cOpcao + "] Inicio",ARQUIVO_LOG)
				StartJob("PLB3QTOB3L",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cCodOpe,cDataRef,cOpcao)
				PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT[" + cOpcao + "] Termino",ARQUIVO_LOG)
				Sleep(2000)

			Next nFor

			PodeTotalizar(cTriRec)//vou aguardar os jobs PLB3QTOB3L para iniciar os totalizadores

		EndIf//If !lSoTotaliza

		dbSelectArea("B3A")
		If LocalizaCompromisso(cTriRec,@cCodObr,@cAnoCmp,@cCodCmp,cCodOpe)
			cChvCom :=  cCodOpe+cCodObr+cAnoCmp+cCodCmp
			CriaItensF(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec)//Crios os itens Fs,
			IniciaClassificacao(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,lMV_PLCENDB)//Tenta atribuir item sem classificacao a uma classificacao
			PodeFinalizar("CENSIPCLA",cTriRec)
			OutrosAtendimentos(cCodOpe,cCodObr,cAnoCmp,cCodCmp,'H')
		EndIf

		//{Funcao,job,possui dependencia?}

		aAdd(aFuncTotais,{"SomaLista",	1,SOMALISTA	,""})
		aAdd(aFuncTotais,{"ItemA1",		1,ITEMA1	,""})
		aAdd(aFuncTotais,{"ItemA",		1,ITEMA		,"ItemA1,ItemA2"})
		aAdd(aFuncTotais,{"ItemB",		1,ITEMB		,""})

		aAdd(aFuncTotais,{"ItemD",		2,ITEMD		,""})
		aAdd(aFuncTotais,{"ItemH",		2,ITEMH		,""})
		aAdd(aFuncTotais,{"ItensI3",	2,ITENSI3	,""})
		aAdd(aFuncTotais,{"ItensE12",	2,ITECIRUR	,""})
		aAdd(aFuncTotais,{"ItensE13",	2,ITEPARTO	,""})
		aAdd(aFuncTotais,{"ItensE14",	2,ITEPEDIA	,""})
		aAdd(aFuncTotais,{"EGrpInt",	2,EGRPINT	,""})//E11..E15 (12)
		aAdd(aFuncTotais,{"ERegInt",	2,EREGINT	,""})//E21..E23
		aAdd(aFuncTotais,{"ItemE1",		2,ITEME1	,"EGrpInt,ERegInt"})//E1
		aAdd(aFuncTotais,{"ItemE2",		2,ITEME2	,""})//E2
		aAdd(aFuncTotais,{"ItemE",		2,ITEME		,""})//E (16)
		aAdd(aFuncTotais,{"ItemG",		2,ITEMG		,""})

		aAdd(aFuncTotais,{"ItensCS",	3,ITENSCS	,""})
		aAdd(aFuncTotais,{"ItemC",		3,ITEMC		,""})
		aAdd(aFuncTotais,{"ItemC3",		3,ITEMC3	,""})
		aAdd(aFuncTotais,{"ItemC10",	3,ITEMC10	,""})
		aAdd(aFuncTotais,{"ItemC101",	3,ITEMC101	,""})
		aAdd(aFuncTotais,{"ItemF",		3,ITEMF		,""})
		aAdd(aFuncTotais,{"ItensF1",	3,ITENSF1	,""})
		aAdd(aFuncTotais,{"ItensF2",	3,ITENSF2	,""})
		aAdd(aFuncTotais,{"ItensF3",	3,ITENSF3	,""})
		aAdd(aFuncTotais,{"ItensF4",	3,ITENSF4	,""})
		aAdd(aFuncTotais,{"ItensF5",	3,ITENSF5	,""})
		aAdd(aFuncTotais,{"ItensF11",	3,ITENSF11	,""})
		aAdd(aFuncTotais,{"ItensF12",	3,ITENSF12	,""})
		aAdd(aFuncTotais,{"ItensF13",	3,ITENSF13	,""})
		aAdd(aFuncTotais,{"ItensF14",	3,ITENSF14	,""})
		aAdd(aFuncTotais,{"ItensF34",	3,ITENSF34	,""})
		aAdd(aFuncTotais,{"SubItensFS",	3,SUBITENSFS,""})
		aAdd(aFuncTotais,{"SubItensFX",	3,SUBITENSFX,""})
		aAdd(aFuncTotais,{"SubItensI3",	3,SUBITENSI3,""})
		aAdd(aFuncTotais,{"ItensIS",	3,ITENSIS	,""})
		aAdd(aFuncTotais,{"ItemI",		3,ITEMI		,""})

		For nFor := 1 TO 3

			StartJob("PLJSIPTOT",GetEnvServer(),.F.,cEmpAnt,cFilAnt,aFuncTotais,nFor,cCodOpe,cDataRef)

		Next nFor

		//Fecha semaforo
		nArquivo := Semaforo('F',nArquivo,cPLSSIPTOTSMF,cTriRec)

	Else
		cMsg := "[" + cTriRec + "] " + CENDTHRL("W") + " PLSSIPTOT Nao foi possivel iniciar a totalizacao do SIP. Verifique o arquivo de semaforo " + cPLSSIPTOTSMF
		PlsLogFil(cMsg,ARQUIVO_LOG)
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
	EndIf

	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT Termino. Operadora: " + cCodOpe + " Data Ref.: " + cDataRef
	PlsLogFil(cMsg,ARQUIVO_LOG)

	// RECOVER
	// 	disarmTransaction()

	// END SEQUENCE
	// ErrorBlock(bBlock)

	If !Empty(cChvCom)
		cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT Aguardando PLSSNTDESP " + cChvCom
		PtInternal(1,cMsg)
		PlsLogFil(cMsg,ARQUIVO_LOG)
		Sleep(30000)//Espero para iniciar todos os PLJSIPTOT
		PLSSNTDESP(cChvCom,.T.)//Vou limpar a sintetizacao
	Else
		cMsg := "[" + cTriRec + "] " + CENDTHRL("W") + " PLSSIPTOT Nao chamou PLSSNTDESP " + cChvCom
		PtInternal(1,cMsg)
		PlsLogFil(cMsg,ARQUIVO_LOG)
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variaveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e		Referencia ao erro
@param nThread	Numero da thread em execucao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e)

	__cError := e:Description
	__cCallStk := e:ErrorStack

	PlsLogFil(CENDTHRL("E") + " Totalizacao: " + __cError + " CallStack: " + __cCallStk ,ARQUIVO_LOG)

	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLB3QTOB3L

Funcao criada como job para mover os itens de detalhes da B3Q para a B3L

@author timoteo.bega
@since 16/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLB3QTOB3L(cEmp,cFil,cCodOpe,cDataRef,cOpcao)
	Local nCont			:= 0
	Local nArquivo		:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 0
	Local nRegSel		:= 0
	Local cCodObr		:= ""
	Local cAnoCmp		:= ""
	Local cCodCmp		:= ""
	Local cTriRec		:= ""
	Local cAlias		:= GetNextAlias()
	Local cWhr			:= ""
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= .F.
	Private lB3L_EVDRES	:= .t.
	Private lB3Q_EVDRES	:= .f.
	Private lB3L_CLASSH := .f. //B3L->(fieldpos("B3L_CLASSH")) > 0
	Private lB3Q_CLASSH := .f. //B3Q->(fieldpos("B3Q_CLASSH")) > 0
	Default cCodOpe		:= ""
	Default cDataRef	:= ""
	Default cOpcao		:= ""

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		cTriRec := DataTrimestre(cDataRef)
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT [" + cOpcao + "] PLB3QTOB3L Job " + cNomJob + " - Inicio",ARQUIVO_LOG)
		If cOpcao == 'A'
			cArquivo := 'B3QTOB3L'+cTriRec+'1.SMF'
			nThread := 1
		ElseIf cOpcao == 'S1'
			cArquivo := 'B3QTOB3L'+cTriRec+'2.SMF'
			nThread := 2
		ElseIf cOpcao == 'S2'
			cArquivo := 'B3QTOB3L'+cTriRec+'3.SMF'
			nThread := 3
		ElseIf cOpcao == 'I1'
			cArquivo := 'B3QTOB3L'+cTriRec+'4.SMF'
			nThread := 4
		Else
			cArquivo := 'B3QTOB3L'+cTriRec+'5.SMF'
			nThread := 5
		EndIf

		cNomJob := CENNOMJOB(nThread,nQuinzena,"TRBB3Q")[1]
		cDesJob := CENNOMJOB(nThread,nQuinzena,"TRBB3Q")[2]

		lMV_PLCENDB	:= MV_PLCENDB

		lB3L_EVDRES := 	B3L->(FieldPos("B3L_EVDRES")) > 0
		lB3L_CLASSH := B3L->(fieldpos("B3L_CLASSH")) > 0
		lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0
		dbSelectArea("B3A")

		If LocalizaCompromisso(cTriRec,@cCodObr,@cAnoCmp,@cCodCmp,cCodOpe)
			cDatExe := DTOS(dDataBase)
			cHorExe	:= Time()
			CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

			nArquivo := Semaforo('A',0,cArquivo,cTriRec)
			If CarregaB3Q(cAlias,cOpcao,cCodOpe,cCodObr,cAnoCmp,cDataRef,cTriRec,@cWhr,.T.)
				nRegSel := (cAlias)->Total
				(cAlias)->(dbCloseArea())
			EndIf

			If CarregaB3Q(cAlias,cOpcao,cCodOpe,cCodObr,cAnoCmp,cDataRef,cTriRec,@cWhr,.F.)
				PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT[" + cOpcao + "]PLB3QTOB3L Achou dados para processar",ARQUIVO_LOG)
				dbSelectArea("B3L")

				While !(cAlias)->(Eof())
					nCont++

					CpB3QTOB3L(cAlias)
					DeletaB3Q(cAlias,cTriRec,cWhr)

					(cAlias)->(dbSkip())
					If nCont == 1 .OR. nCont % 1000 == 0
						PtInternal(1,"["+cOpcao+"] " + AllTrim(Str(nCont))+' registros inseridos')
						aB3L := GetArea()
						cObs := AllTrim(Str(nCont)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
						RestArea(aB3L)
					EndIf//If nCont % 500 == 0

				EndDo

			Else
				cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT[" + cOpcao + "]PLB3QTOB3L Nao localizou dados para copiar."
				PlsLogFil(cMsg,ARQUIVO_LOG)
			EndIf

			(cAlias)->(dbCloseArea())
			Semaforo('F',nArquivo,cArquivo,cTriRec)
		Else
			cMsg := "[" + cTriRec + "] "+CENDTHRL("E") + " PLSSIPTOT[" + cOpcao + "]PLB3QTOB3L Nao localizou compromisso para o trimestre: " + cTriRec
			PlsLogFil(cMsg,ARQUIVO_LOG)
		EndIf//If !LocalizaCompromisso

		cObs := cNomJob + " concluido!"
		CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT[" + cOpcao + "]PLB3QTOB3L Termino",ARQUIVO_LOG)
		RECOVER
		disarmTransaction()
	END SEQUENCE
	ErrorBlock(bBlock)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIPTOT

Funcao criada como job para chamar a execucao das consultas totalizadoras

@author timoteo.bega
@since 13/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLJSIPTOT(cEmp,cFil,aFunc,nInd,cCodOpe,cDataRef,lAuto)
	Local nFor			:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 0
	Local cAlias		:= "TRBTOT"
	Local cCodObr		:= ""
	Local cAnoCmp		:= ""
	Local cCodCmp		:= ""
	Local cTriRec		:= ""
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= .F.
	Default cCodOpe		:= ""
	Default cDataRef	:= ""
	Default nInd		:= 1
	Default lAuto		:= .F.

	nThread := nInd
	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias)[2]

	PRIVATE __cError := ""
	PRIVATE __cCallStk := ""
	If !lAuto
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE

		cTriRec := DataTrimestre(cDataRef)
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nInd)) + "] Job " + cNomJob + " - Inicio",ARQUIVO_LOG)
		lMV_PLCENDB	:= MV_PLCENDB
		B3L->(dbSetOrder(1))

		If LocalizaCompromisso(cTriRec,@cCodObr,@cAnoCmp,@cCodCmp,cCodOpe)

			cDatExe := DTOS(dDataBase)
			cHorExe	:= Time()
			CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

			PodeEvoluir(cTriRec)
			EvoluiInternacao(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec)

			For nFor := 1 TO Len(aFunc)

				PtInternal(1,'Totalizando ' + aFunc[nFor,1])

				If aFunc[nFor,2] == nInd//Todas funcoes do indice/job

					PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nInd)) + "] " + aFunc[nFor,1] + " Inicio",ARQUIVO_LOG)
					CENTITESIP(aFunc[nFor,3],cCodOpe,cCodObr,cAnoCmp,cCodCmp,cDataRef,aFunc[nFor,1],lMV_PLCENDB)//Totaliza ITEns do SIP
					PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nInd)) + "] " + aFunc[nFor,1] +  " Termino",ARQUIVO_LOG)
					cObs := AllTrim(Str(nFor)) + " registros processados de " + AllTrim(Str(Len(aFunc))) + " lidos"
					CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)

				EndIf//If aFunc[nFor,2] == nInd

			Next nFor

			cObs := cNomJob + " concluido!"
			CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

		Else
			PlsLogFil("[" + cTriRec + "] " + CENDTHRL("W") + " PLJSIPTOT [" + AllTrim(Str(nInd)) + "] Compromisso nao encontrado",ARQUIVO_LOG)
		EndIf//If !LocalizaCompromisso

		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nInd)) + "] Termino",ARQUIVO_LOG)
		cObs := cNomJob + " concluido!"
		CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

		RECOVER
		disarmTransaction()

	END SEQUENCE
	ErrorBlock(bBlock)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Funcao criada para retornar a consulta totalizadora a ser executada

@author timoteob.bega
@since 13/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(nConsulta,cCodOpe,cCodObr,cAnoCmp,cCdComp,cDataRef)
	Local cConsulta		:= ""
	Local cListaCampos	:= ""
	Local cDataInicio	:= ""
	Local cDataTermino	:= ""
	Local cAmbulator	:= " AND B3L_REGINT = ' ' AND B3L_GRPINT = ' ' "
	Local cItensF		:= " AND B3L_CID <> ' ' AND B3L_EVDEIN <> ' ' AND B3L_GRPINT <> ' ' AND B3L_REGINT <> ' ' "
	Local aTotItens		:= {ITEMA,ITEMA1,ITEMB,ITEMC,ITEMC10,ITEMD,ITEMF,ITENSF1,ITENSF2,ITENSF3,ITENSF4,ITENSF5,;
		,ITENSF11,ITENSF12,ITENSF13,ITENSF14,ITENSF34,ITEMI,ITEME,ITEME1,ITEME2,ITEPARTO,ITECIRUR,ITEPEDIA}
	Local aItensFs		:= {ITEMF,SUBITENSFS,SUBITENSFX,ITENSF1,ITENSF2,ITENSF3,ITENSF4,ITENSF5,ITENSF11,ITENSF12,ITENSF13,ITENSF14,ITENSF34}
	Local nPosF			:= 0
	Local lItemContado	:= nConsulta >= ITENSF1 .Or. nConsulta == EGRPINT .OR. nConsulta == EREGINT .OR. nConsulta == ITEMG .OR. nConsulta >= ITEMF .And. nConsulta <= SUBITENSFX

	Default nConsulta	:= SOMALISTA
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAnoCmp		:= ""
	Default cCdComp		:= ""
	Default cDataRef	:= DTOS(dDataBase)

	cSoma := "SUM(B3L_QTDEVE) B3L_QTDEVE, SUM(B3L_VLREVE) B3L_VLREVE, "
	cListaCampos := "B3L_CODOPE,B3L_CODOBR,B3L_ANOCMP,B3L_CDCOMP,B3L_UF,B3L_TRIREC,B3L_TRIOCO,B3L_FORCON "

	nPosF := aScan(aItensFs,{ |x| x == nConsulta})
	If nPosF > 0
		cListaCampos += ", B3L_GRPINT, B3L_REGINT "
	EndIf

	lTotal := aScan(aTotItens,{|x| x == nConsulta}) > 0
	If lTotal
		cListaCampos := StrTran(cListaCampos,"B3L_CLAAMB,","")
		If nConsulta == ITEPARTO .Or. nConsulta == ITECIRUR .Or. nConsulta == ITEPEDIA
			cListaCampos += ",B3L_CLAINT "
		Else
			cListaCampos := StrTran(cListaCampos,"B3L_CLAINT,","")
		EndIf
	Else
		//Para internacao eu agrupo pelo claint
		If nConsulta == EGRPINT .OR. nConsulta == EREGINT .OR. nConsulta == ITEME .OR. nConsulta == ITEME1 .OR. nConsulta == ITEME2;
				.OR. nConsulta == SUBITENSFX .OR. nConsulta == ITEPARTO;
				.OR. nConsulta == ITENSF1 .OR. nConsulta == ITENSF2 .OR. nConsulta == ITENSF3 .OR. nConsulta == ITENSF4 .OR. nConsulta == ITENSF5 ;
				.OR. nConsulta == ITENSF11 .OR. nConsulta == ITENSF12 .OR. nConsulta == ITENSF13 .OR. nConsulta == ITENSF14 .OR. nConsulta == ITENSF34
			cListaCampos += ",B3L_CLAINT "
		Else
			cListaCampos += ",B3L_CLAAMB,B3L_CLAINT "
		EndIf
	EndIf

	If nConsulta == EGRPINT
		cCampos := StrTran(cListaCampos,"B3L_CLAINT","B3L_GRPINT B3L_CLAINT")
	ElseIf nConsulta == EREGINT
		cCampos := StrTran(cListaCampos,"B3L_CLAINT","B3L_GRPINT, B3L_REGINT B3L_CLAINT")
	EndIf

	If lItemContado
		cSoma := "COUNT(DISTINCT B3L_EVDEIN "+IIf(nConsulta == ITENSF3,"||B3L_CLAINT","")+") B3L_QTDEVE, SUM(B3L_VLREVE) B3L_VLREVE, "
	EndIf

	cConsulta := "SELECT " + cSoma
	If nConsulta == EGRPINT .OR. nConsulta == EREGINT
		cConsulta += cCampos
	Else
		cConsulta += cListaCampos
	EndIf
	cConsulta += "FROM " + RetSqlName("B3L") + " "
	If BANCO == "MSSQL7"
		cConsulta += " WITH (NOLOCK) "
	EndIf
	If nConsulta == ITEMC3 .Or. nConsulta == ITEMC101

		If nConsulta == ITEMC3//mulheres De 25 a 59 anos
			cDataInicio := STOD(cDataRef)-(59*365)
			cDataTermino := STOD(cDataRef)-(25*365)
		ElseIf  nConsulta == ITEMC101//mulheres De 50 a 69 anos
			cDataInicio := STOD(cDataRef)-(69*365)
			cDataTermino := STOD(cDataRef)-(50*365)
		EndIf

		cDataInicio	:= DTOS(cDataInicio)
		cDataTermino := DTOS(cDataTermino)

		cConsulta += "INNER JOIN " + RetSqlName("B3K") + " ON B3K_FILIAL='" + xFilial("B3K") + "' AND B3K_MATRIC = B3L_MATRIC AND B3K_SEXO='3' AND
		cConsulta += "  B3K_DATNAS BETWEEN '" + cDataInicio + "' AND '" + cDataTermino + "' AND " + RetSqlName("B3K") + ".D_E_L_E_T_=' ' "

	EndIf

	cConsulta += " WHERE "
	cConsulta += " B3L_FILIAL='" + xFilial("B3L") + "' "
	cConsulta += " AND B3L_CODOPE='" + cCodOpe + "' "
	cConsulta += " AND B3L_CODOBR='" + cCodObr + "' "
	cConsulta += " AND B3L_ANOCMP='" + cAnoCmp + "' "
	cConsulta += " AND B3L_CDCOMP='" + cCdComp + "' "

	If nConsulta == SOMALISTA
		cConsulta += "AND B3L_CLAAMB IN ('A11','A12','A13','A14','A15','A16','A17','A18','A19','A110',"+;
			"'A111','A112','A113','A114','A115','A116','A117','A118','A119','A120','A121','A122','A123','A124','A125',"+;
			"'A2',"+;
			"'B1','B2','B3','B4','B5','B6',"+;
			"'D1','D2','D3','D4','D5','D6') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAAMB = B3L_CLAINT) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMA1
		cConsulta += "AND B3L_CLAAMB LIKE 'A1%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT LIKE 'A1%') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMA
		cConsulta += "AND B3L_CLAAMB IN ('A1','A2') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT IN ('A1','A2') ) "
		cConsulta += " AND B3L_MATRIC=B3L_EVEDES "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMB
		cConsulta += "AND B3L_CLAAMB LIKE 'B%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT LIKE 'B%' ) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITENSCS
		cConsulta += "AND B3L_CLAAMB IN ('C1','C2','C4','C5','C6','C7','C8','C9','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT IN ('C1','C2','C4','C5','C6','C7','C8','C9','C11','C12','C13','C14','C15','C16','C17','C18','C19','C20') ) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMC
		cConsulta += "AND B3L_CLAAMB LIKE 'C%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT LIKE 'C%') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMC3
		cConsulta += "AND B3L_CLAAMB = 'C3' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT = 'C3') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMC10
		cConsulta += "AND B3L_CLAAMB LIKE 'C10%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT LIKE 'C10%') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMC101
		cConsulta += "AND B3L_CLAAMB = 'C101' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT='C101') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMD
		cConsulta += "AND B3L_CLAAMB LIKE 'D%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT LIKE 'D%') "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMG
		cConsulta += "AND ( B3L_CLAAMB IN ('E131','E132','E133') "
		cConsulta += "OR B3L_CLAINT IN ('E131','E132','E133') ) "
		cConsulta += " AND B3L_EVDEIN <> ' ' AND B3L_CODEVE IN ('31309127','31309054','31309208') "

	ElseIf nConsulta == ITEMH
		cConsulta += "AND ( B3L_CLAAMB = 'H' AND (B3L_CLAINT = ' ' OR B3L_CLAINT = 'H') ) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITENSI3
		cConsulta += "AND B3L_CLAAMB IN ('I31','I32','I33') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAINT IN ('I31','I32','I33')) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITECIRUR//E12
		cConsulta += "AND B3L_CLAINT BETWEEN 'E121' AND 'E127' "//Grupo/Tipo de internacao cirurgica
		cConsulta += "AND B3L_GRPINT = '2' "

	ElseIf nConsulta == ITEPARTO//E13
		cConsulta += " AND (B3L_CLAINT IN ('E131','E132','E133') "//Grupo/Tipo de internacao obstetrica
		cConsulta += " OR B3L_CLAAMB IN ('E131','E132','E133') ) "
		cConsulta += " AND B3L_EVDEIN <> ' ' AND B3L_CODEVE IN ('31309127','31309054','31309208') "

	ElseIf nConsulta == ITEPEDIA//E14
		cConsulta += "AND B3L_CLAINT IN ('E141','E142','E1421') AND B3L_GRPINT = '4' "//Grupo/Tipo de internacao pediatrica

	ElseIf nConsulta == EGRPINT//E11..E15
		cConsulta += "AND B3L_GRPINT IN ('1','2','3','4','5') "//Clinica, Cirurgica, Obstetrica, Pediatrica, Psiquiatrica
		cConsulta += "AND B3L_REGINT IN ('1','2','3') "//1-Hospitalar, 2-Hospital Dia, 3-Domiciliar

	ElseIf nConsulta == EREGINT//E21..E23
		cConsulta += "AND B3L_GRPINT IN ('1','2','3','4','5') "//Clinica, Cirurgica, Obstetrica, Pediatrica, Psiquiatrica
		cConsulta += "AND B3L_REGINT IN ('1','2','3') "//1-Hospitalar, 2-Hospital Dia, 3-Domiciliar

	ElseIf nConsulta == ITEME1//E1 - Tipo de Internacao
		cConsulta += "AND B3L_CLAINT IN ('E11','E12','E13','E14','E15') "
		cConsulta += "AND B3L_CLAAMB = B3L_CLAINT "
		cConsulta += "AND B3L_MATRIC = B3L_EVEDES "

	ElseIf nConsulta == ITEME2//E2 - Regime de Internacao
		cConsulta += "AND B3L_CLAINT IN ('E21','E22','E23') "
		cConsulta += "AND B3L_CLAAMB = B3L_CLAINT "
		cConsulta += "AND B3L_MATRIC = B3L_EVEDES "

	ElseIf nConsulta == ITEME//E
		cConsulta += "AND B3L_CLAINT IN ('E1') "
		cConsulta += "AND B3L_CLAAMB = B3L_CLAINT "

	ElseIf nConsulta == ITEMF
		cConsulta += "AND B3L_CLAINT like 'F%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF1
		cConsulta += "AND B3L_CLAINT LIKE 'F1%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF2
		cConsulta += "AND B3L_CLAINT LIKE 'F2%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF3
		cConsulta += "AND B3L_CLAINT LIKE 'F3%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF4
		cConsulta += "AND B3L_CLAINT LIKE 'F4%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF5
		cConsulta += "AND B3L_CLAINT LIKE 'F5%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF11
		cConsulta += "AND B3L_CLAINT LIKE 'F11%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF12
		cConsulta += "AND B3L_CLAINT LIKE 'F12%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF13
		cConsulta += "AND B3L_CLAINT LIKE 'F13%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF14
		cConsulta += "AND B3L_CLAINT LIKE 'F14%' "
		cConsulta += cItensF

	ElseIf nConsulta == ITENSF34
		cConsulta += "AND B3L_CLAINT LIKE 'F34%' "
		cConsulta += cItensF

	ElseIf nConsulta == SUBITENSFS
		cConsulta += "AND B3L_CLAINT IN ('F31','F32','F33') "
		cConsulta += cItensF

	ElseIf nConsulta == SUBITENSFX
		cConsulta += "AND B3L_CLAINT IN ('F111','F121','F131','F141','F341') "
		cConsulta += cItensF

	ElseIf nConsulta == SUBITENSI3
		cConsulta += "AND B3L_CLAAMB IN ('I31','I32','I33') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAAMB = B3L_CLAINT) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITENSIS
		cConsulta += "AND B3L_CLAAMB IN ('I1','I2','I3','I4','I5','I6','I7','I8','I9','I10','I11') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAAMB = B3L_CLAINT) "
		cConsulta += cAmbulator

	ElseIf nConsulta == ITEMI
		cConsulta += "AND B3L_CLAAMB LIKE 'I%' "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAAMB = B3L_CLAINT) "
		cConsulta += cAmbulator

	ElseIf nConsulta == SUBITENSFX
		cConsulta += "AND B3L_CLAAMB IN ('F111','F121','F131','F141','F341') "
		cConsulta += "AND (B3L_CLAINT = ' ' OR B3L_CLAAMB = B3L_CLAINT) "

	Else
		cConsulta += " AND B3L_CODOPE='999999' "//Para nao retornar registros

	EndIf

	If nConsulta <> ITEMA .AND. nConsulta <> ITEME .AND. nConsulta <> ITEME1 .AND. nConsulta <> ITEME2
		cConsulta += " AND B3L_MATRIC<>B3L_EVEDES "
	EndIf

	If lItemContado
		cConsulta += " AND (B3L_QTDEVE > 0 OR B3L_VLREVE > 0) "
	EndIf

	cConsulta += " AND " + RetSqlName("B3L") + ".D_E_L_E_T_=' ' "
	If nConsulta == EGRPINT
		cListaCampos := StrTran(cListaCampos,"B3L_CLAINT","B3L_GRPINT, B3L_REGINT")
	ElseIf nConsulta == EREGINT
		cListaCampos := StrTran(cListaCampos,"B3L_CLAINT","B3L_GRPINT, B3L_REGINT")
	EndIf
	cConsulta += " GROUP BY	" + cListaCampos

Return cConsulta

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Totaliza Itens do SIP

Funcao criada para executar as querys de totalizacao dos itens dos SIP

@author timoteo.bega
@since 13/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CENTITESIP(nConsulta,cCodOpe,cCodObr,cAnoCmp,cCodCmp,cDataRef,cFunCons,lMV_PLCENDB)
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()
	Local cTriRec := ""
	Default nConsulta	:= 0
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAnoCmp		:= ""
	Default cCodCmp		:= ""
	Default cDataRef	:= ""
	Default lMV_PLCENDB	:= MV_PLCENDB
	cTriRec := cAnoCmp + SubStr(cCodCmp,2,2)
	B3L->(dbSetOrder(1))
	cConsulta := RetornaConsulta(nConsulta,cCodOpe,cCodObr,cAnoCmp,cCodCmp,cDataRef)
	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " Consulta [" + AllTrim(Str(nConsulta)) + "][" + cFunCons + "] " + cConsulta,ARQUIVO_LOG)
	If CriaArea(cConsulta,cNomeArea,nConsulta,cFunCons,lMV_PLCENDB,cTriRec )

		While !(cNomeArea)->(Eof())

			GravaB3L(cNomeArea,nConsulta)//cGrpInt,cRegInt,nNasViv
			DelClassInf()
			(cNomeArea)->(dbSkip())

		EndDo

	EndIf

	(cNomeArea)->(dbCloseArea())

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsereDespesa

Funcao criada para incluir registros totalizadores da tabela de despesas B3L da Central de Obrigacoes

@param cNomeArea		Nome da area de trabalho corrente
@param nConsulta		Numero da consulta executadada
@param cGrpInt			Codigo do grupo de internacao
@param cRegInt			Codigo da segmentacao
@param nNasViv			Quantidade nascidos vivos

@return lRetorno	Retorna .T. se incluiu o registro senao retorna .F.

@author timoteo.bega
@since 11/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function GravaB3L(cNomeArea,nConsulta,cGrpInt,cRegInt,nNasViv)
	Local cChaveTotal	:= ""
	Local cItem			:= ""
	Local lInclui		:= .F.
	Local aItensFs		:= {ITEMF,SUBITENSFS,SUBITENSFX,ITENSF1,ITENSF2,ITENSF3,ITENSF4,ITENSF5,ITENSF11,ITENSF12,ITENSF13,ITENSF14,ITENSF34}
	Local cSegmen		:= ""
	Default cNomeArea	:= ""
	Default nConsulta	:= 0
	Default	cGrpInt		:= ""
	Default cRegInt		:= ""
	Default	nNasViv		:= 0

	nPosF := aScan(aItensFs,{ |x| x == nConsulta})
	If nPosF > 0
		cGrpInt := (cNomeArea)->B3L_GRPINT
		cRegInt := (cNomeArea)->B3L_REGINT
	EndIf

	If nConsulta == ITEMA1//ItemA1 A1%
		cItem := "A1"
	ElseIf nConsulta == ITEMA//ItemA (A1+A2)
		cItem := "A"
	ElseIf nConsulta == ITEMB//ItemB B%
		cItem := "B"
	ElseIf nConsulta == ITEMC//ItemC C%
		cItem := "C"
	ElseIf nConsulta == ITEMC10//ItemC C%
		cItem := "C10"
	ElseIf nConsulta == ITEMC101//ItemC C%
		cItem := "C101"
	ElseIf nConsulta == ITEMD//ItemD D%
		cItem := "D"
	ElseIf nConsulta == ITEME//ItemE
		cItem := "E"
	ElseIf nConsulta == ITEME1//ItemE1
		cItem := "E1"
	ElseIf nConsulta == ITEME2//ItemE2
		cItem := "E2"
	ElseIf nConsulta == ITEPARTO
		If Len((cNomeArea)->B3L_CLAINT) < 4
			cItem := "E132"
		Else
			cItem := (cNomeArea)->B3L_CLAINT
		EndIf
	ElseIf nConsulta == ITECIRUR
		cItem := (cNomeArea)->B3L_CLAINT
	ElseIf nConsulta == ITEPEDIA
		cItem := (cNomeArea)->B3L_CLAINT
	ElseIf nConsulta == EGRPINT//Grupo/Tipo de Internacao 1-Clinica, 2-Cirurgica, 3-Obstetrica, 4-Pediatrica, 5-Psiquiatrica
		cItem := 'E1' + (cNomeArea)->B3L_CLAINT
	ElseIf nConsulta == EREGINT//Regime de Interncao 1-Hospitalar, 2-Hospital-dia, 2.1-Hospital-dia mental, 3-Psiquiatrica
		cItem := 'E2' + (cNomeArea)->B3L_CLAINT
	ElseIf nConsulta == ITEMF
		cItem := "F"
	ElseIf nConsulta == ITENSF1
		cItem := "F1"
	ElseIf nConsulta == ITENSF2
		cItem := "F2"
	ElseIf nConsulta == ITENSF3
		cItem := "F3"
	ElseIf nConsulta == ITENSF4
		cItem := "F4"
	ElseIf nConsulta == ITENSF5
		cItem := "F5"
	ElseIf nConsulta == ITENSF11
		cItem := "F11"
	ElseIf nConsulta == ITENSF12
		cItem := "F12"
	ElseIf nConsulta == ITENSF13
		cItem := "F13"
	ElseIf nConsulta == ITENSF14
		cItem := "F14"
	ElseIf nConsulta == ITENSF34
		cItem := "F34"
	ElseIf nConsulta == ITEMG
		cItem := "G"
	ElseIf nConsulta == ITEMH
		cItem := "H"
	ElseIf nConsulta == ITEMI//ItemI I%
		cItem := "I"
	Else
		cItem := IIf(Empty((cNomeArea)->B3L_CLAINT),(cNomeArea)->B3L_CLAAMB,(cNomeArea)->B3L_CLAINT)
	EndIf

	cChaveTotal := AllTrim((cNomeArea)->B3L_TRIREC+(cNomeArea)->B3L_TRIOCO+(cNomeArea)->B3L_UF+cItem)

	lInclui := !ExisteTotal(cNomeArea,cItem,cChaveTotal)
	cSegmen := AjustaSeg(cItem)
	If RecLock("B3L",lInclui)
		If lInclui
			B3L->B3L_FILIAL := xFilial('B3L')
			B3L->B3L_CODOPE := (cNomeArea)->B3L_CODOPE
			B3L->B3L_CODOBR := (cNomeArea)->B3L_CODOBR
			B3L->B3L_ANOCMP := (cNomeArea)->B3L_ANOCMP
			B3L->B3L_CDCOMP := (cNomeArea)->B3L_CDCOMP
			B3L->B3L_MATRIC := AllTrim(cChaveTotal)
			B3L->B3L_EVEDES := AllTrim(cChaveTotal)
			B3L->B3L_EVDEIN := ''
			B3L->B3L_UF	 	:= (cNomeArea)->B3L_UF
			B3L->B3L_TRIREC := (cNomeArea)->B3L_TRIREC
			B3L->B3L_TRIOCO := (cNomeArea)->B3L_TRIOCO
			B3L->B3L_CDTPTB := ''
			B3L->B3L_CODEVE := ''
			B3L->B3L_DATEVE := CTOD('')
			B3L->B3L_QTDEVE := (cNomeArea)->B3L_QTDEVE
			B3L->B3L_VLREVE := (cNomeArea)->B3L_VLREVE
			B3L->B3L_CLAAMB := cItem
			B3L->B3L_CLAINT := cItem
			B3L->B3L_GRPINT := cGrpInt
			B3L->B3L_REGINT := cRegInt
			B3L->B3L_CID	 := ''
			B3L->B3L_DATINT := CTOD('')
			B3L->B3L_HORINT := ''
			B3L->B3L_DATALT := CTOD('')
			B3L->B3L_HORALT := ''
			B3L->B3L_DENREG := ''
			B3L->B3L_FORCON := (cNomeArea)->B3L_FORCON
			B3L->B3L_SEGMEN := cSegmen
			B3L->B3L_NASVIV := nNasViv
		Else
			B3L->B3L_QTDEVE += (cNomeArea)->B3L_QTDEVE
			B3L->B3L_VLREVE += (cNomeArea)->B3L_VLREVE
		EndIf
		B3L->B3L_STATUS := '1' //1-Nao validado
		B3L->(msUnLock())
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf
Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo	Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author timoteo.bega
@since 14/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo,cArquivo,cTriRec)
	Default cArquivo	:= 'PLSSIPTOT.SMF'
	Default nArquivo	:= 0
	Default cOpcao	:= 'A'
	Default cTriRec := SubStr(cArquivo,9,6)

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo
			cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT PodeTotalizar - Abrindo o semaforo: " + cArquivo
			PlsLogFil(cMsg,ARQUIVO_LOG)
			If !File(cArquivo)
				cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT PodeTotalizar - O semaforo nao existe: " + cArquivo
				PlsLogFil(cMsg,ARQUIVO_LOG)
				nArquivo := FCreate(cArquivo,0,,.F.)
			EndIf

			FOpen(cArquivo, FO_READWRITE)

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo
			cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT PodeTotalizar - Fechando o semaforo: " + cArquivo
			PlsLogFil(cMsg,ARQUIVO_LOG)
			FClose(nArquivo)
			FErase(cArquivo)

	EndCase

Return nArquivo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaArea

Funcao criada para criar e abrir uma area de trabalho baseada em consulta ao BD

@param cConsulta		Consulta a ser executada
@param cNomeArea		Nome do alias a ser criado

@return lRetorno		Indica se a area foi criada ou nao

@author timoteo.bega
@since 14/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaArea(cConsulta,cNomeArea,nConsulta,cFunCons,lMV_PLCENDB,cTriRec)
	Local lRetorno		:= .F.
	Default cConsulta	:= ""
	Default cNomeArea	:= ""
	Default nConsulta	:= 0
	Default cFunCons	:= ""
	Default lMV_PLCENDB	:= MV_PLCENDB

	If !Empty(cConsulta) .And. !Empty(cNomeArea)

		cConsulta := ChangeQuery(cConsulta)
		cConsulta := InsereNoLock(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cNomeArea,.F.,.T.)

		If !(cNomeArea)->(Eof())
			lRetorno := .T.
		EndIf

		If lMV_PLCENDB
			PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " CRIAAREA Consulta [" + AllTrim(Str(nConsulta)) + "][" + cFunCons + "] " + cConsulta,ARQUIVO_LOG)
		EndIf

	EndIf

Return lRetorno

Static Function LocalizaCompromisso(cDataReal,cCodObri,cAnoComp,cCodComp,cRegANS)
	Local lRetorno		:= .T.
	Default cDataReal:= DTOS(dDataBase)
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default cRegANS	:= '000000'

	B3A->(dbSetOrder(2))//B3A_FILIAL + B3A_CODOPE + B3A_TIPO
	If B3A->(msSeek(xFilial("B3A")+cRegANS+'1')) .And. B3A->B3A_ATIVO = '1'
		cCodObri := B3A->B3A_CODIGO
	Else
		lRetorno := .F.
	EndIf

	B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO
	If lRetorno .And. B3D->(msSeek(xFilial('B3D')+cRegANS+cCodObri+Left(cDataReal,4)+"0"+Right(cDataReal,2)))
		cAnoComp := B3D->B3D_ANO
		cCodComp := B3D->B3D_CODIGO
	Else
		lRetorno := .F.
	EndIf

Return lRetorno
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
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaB3Q

Funcao criada para carregar os registros da tabela B3Q na area de traballho cAlias

@param cAlias		Nome da area de trabalho a ser criada

@return lRetorno	Retorna .T. se criou ou .F. se nao criou a area de trabalho

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaB3Q(cAlias,cOpcao,cRegANS,cCodObri,cAnoComp,cDataRef,cTriRec,cWhr,lTotal)
	Local lRetorno		:= .T.
	Local cSql			:= ""
	Default cAlias		:= GetNextAlias()
	Default cOpcao		:= 'A'
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cDataRef	:= ""
	Default cTriRec		:= ""
	Default cWhr		:= ""
	Default lTotal		:= .F.

	If lTotal

		cSql := "SELECT COUNT(1) Total FROM " + RetSqlName("B3Q") + " "

	Else
		cSoma := " SUM(B3Q_QTDEVE) B3Q_QTDEVE, SUM(B3Q_VLREVE) B3Q_VLREVE, MAX(B3Q_UF) B3Q_UF, "
		cSoma += " '" + AllTrim(cTriRec) + "' B3Q_TRIREC, MAX(B3Q_TRIOCO) B3Q_TRIOCO, MAX(B3Q_GRPINT) B3Q_GRPINT,"
		cSoma += " MAX(B3Q_REGINT) B3Q_REGINT, MAX(B3Q_CID) B3Q_CID, MAX(B3Q_DATINT) B3Q_DATINT, "
		cSoma += " MAX(B3Q_HORINT) B3Q_HORINT, MAX(B3Q_DATALT) B3Q_DATALT, MAX(B3Q_HORALT) B3Q_HORALT, "
		cSoma += " MAX(B3Q_DENREG) B3Q_DENREG, MAX(B3Q_FORCON) B3Q_FORCON, MAX(B3Q_SEGMEN) B3Q_SEGMEN, "
		cSoma += " MAX(B3Q_NASVIV) B3Q_NASVIV, "
		cListaCampos := " B3Q_FILIAL,B3Q_CODOPE,B3Q_CODOBR,B3Q_ANOCMP,B3Q_CDCOMP,B3Q_EVEDES, "
		cListaCampos += " B3Q_MATRIC,B3Q_CDTPTB,B3Q_CODEVE,B3Q_CLAAMB,B3Q_CLAINT,B3Q_FORCON, "
		cListaCampos += " B3Q_SEGMEN,B3Q_DATEVE,B3Q_EVDEIN "
		If lB3Q_EVDRES
			cListaCampos += ", B3Q_EVDRES "
		EndIf
		if lB3Q_CLASSH

			IIF(SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",clistaCampos += ", UTL_RAW.cast_to_varchar2(B3Q_CLASSH) B3Q_CLASSH",cListaCampos += ", CAST(B3Q_CLASSH AS VARCHAR(1000)) B3Q_CLASSH")

		endif

		cSql := "SELECT " + cSoma + cListaCampos + " FROM " + RetSqlName("B3Q") + " "

	EndIf
	If BANCO == "MSSQL7"
		cSql += " WITH (NOLOCK) "
	EndIf
	cWhr := " WHERE "
	cWhr += " B3Q_FILIAL = '" + xFilial("B3Q") + "' "
	cWhr += " AND B3Q_CODOPE = '" + cRegANS + "' "
	cWhr += " AND B3Q_CODOBR = '" + cCodObri + "' "
	cWhr += " AND B3Q_ANOCMP = '" + cAnoComp + "' "
	cWhr += " AND B3Q_TRIREC = '" + cTriRec + "' "
	If cOpcao == 'A'//consulta
		cWhr += " AND B3Q_EVDEIN = ' ' "
		cWhr += " AND B3Q_CLAAMB BETWEEN 'A' AND 'AZ' "
	ElseIf cOpcao == 'S1'//servico no trimestre de ocorrencia
		cWhr += " AND B3Q_EVDEIN = ' ' "
		cWhr += " AND B3Q_TRIOCO = '" + cTriRec + "' "
		cWhr += " AND (B3Q_CLAAMB = ' ' OR B3Q_CLAAMB >= 'B') "
	ElseIf cOpcao == 'S2'//servico no trimestre de ocorrncia diferente
		cWhr += " AND B3Q_EVDEIN = ' ' "
		cWhr += " AND B3Q_TRIOCO <> '" + cTriRec + "' "
		cWhr += " AND (B3Q_CLAAMB = ' ' OR B3Q_CLAAMB >= 'B') "
	ElseIf cOpcao == 'I1'//internacao no trimestre de reconhecimento
		cWhr += " AND B3Q_EVDEIN <> ' ' "
		cWhr += " AND B3Q_TRIOCO = '" + cTriRec + "' "
	ElseIf cOpcao == 'I2'//internacao fora do trimestre de reconhecimento
		cWhr += " AND B3Q_EVDEIN <> ' '  "
		cWhr += " AND B3Q_TRIOCO <> '" + cTriRec + "' "
	Else
		cWhr += "AND R_E_C_N_O_=-1 "//opcao invalida
	EndIf
	cWhr += "AND D_E_L_E_T_ = ' ' "

	cSql += cWhr

	If !lTotal
		If lB3Q_CLASSH
			cSql += " GROUP BY " + substr(cListaCampos, 1, len(cListaCampos)-10)
		Else
			cSql += " GROUP BY " + cListaCampos
		EndIf
	EndIf

	cSql := ChangeQuery(cSql)
	cSql := InsereNoLock(cSql)

	PLSLOGFIL("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + cOpcao + "] " + cSql,ARQUIVO_LOG)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)//TRBFIM
	PLSLOGFIL("[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + cOpcao + "] Fim query CarregaB3Q " + cOpcao,ARQUIVO_LOG)

	If (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

Return lRetorno

Static Function InsereNoLock(cSql)
	Default cSql := ""

	cSql := StrTran(cSql," WITH "," WITH (NOLOCK) ")

Return cSql

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeTotalizar

Funcao criada para fazer aguardar o termino da carga da B3Q para B3L e liberar os jobs de totais

@author timoteo.bega
@since 16/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeTotalizar(cTriRec)
	Local nFor			:= 0
	Local nTempo		:= 0
	Local nArquivo		:= 0
	Local cSemaforo	:= 'B3QTOB3L'
	Local lContinua	:= .F.
	Local cArquivo		:= ""

	Sleep(30000)//Aguardo 30 segundos para os jobs anteriores iniciarem
	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PodeTotalizar Inicio "
	PlsLogFil(cMsg,ARQUIVO_LOG)

	While !lContinua

		lContinua := .T.//Inicialmente libero para continuar

		For nFor := 1 TO 5//Vou procurar um dos 5 semaforos

			cArquivo := cSemaforo+cTriRec+AllTrim(Str(nFor))+'.SMF' //Se encontrou algum dos semaforos nao deixo continuar
			cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nFor)) + "] PodeTotalizar - Tentando abrir o arquivo: " + cArquivo
			PlsLogFil(cMsg,ARQUIVO_LOG)
			If File(cArquivo)
				cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nFor)) + "] PodeTotalizar - O arquivo existe: " + cArquivo
				PlsLogFil(cMsg,ARQUIVO_LOG)
				nArquivo := FOpen(cArquivo,FO_READWRITE)
				If nArquivo == -1
					lContinua := .F.
					cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nFor)) + "] PodeTotalizar - Semaforo fechado: " + cArquivo
					PlsLogFil(cMsg,ARQUIVO_LOG)
					Exit
				Else
					cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nFor)) + "] PodeTotalizar - Semaforo aberto: " + cArquivo
					PlsLogFil(cMsg,ARQUIVO_LOG)
					FClose(nArquivo)
				EndIf
			Else
				cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT [" + AllTrim(Str(nFor)) + "] PodeTotalizar - O arquivo nao existe: " + cArquivo
				PlsLogFil(cMsg,ARQUIVO_LOG)
			EndIf//If File(cArquivo)

		Next nFor

		If !lContinua
			cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT PodeTotalizar - Vou esperar 1 min: " + cArquivo
			PlsLogFil(cMsg,ARQUIVO_LOG)
			nTempo += 60000
			Sleep(60000)//Aguardo um minuto
			PtInternal(1,'Aguardando a ' + AllTrim(Str(nTempo/60000)) + ' minuto(s) ' )
		EndIf

	EndDo

	cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " PLJSIPTOT PodeTotalizar Fim "
	PlsLogFil(cMsg,ARQUIVO_LOG)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeFinalizar

Funcao criada para fazer aguardar o termino da carga da B3Q para B3L e liberar o job PLSIPTOT

@param	Nome do job que precisa aguardar ser concluido

@author timoteo.bega
@since 03/04/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeFinalizar(cJob,cTriRec)
	Local aInfo		:= GetUserInfoArray()
	Local nTempo	:= 0
	Local nFor		:= 0
	Local lContinua := .F.
	Local cMsg		:= 'Aguardando a ' + AllTrim(Str(nTempo/60000)) + ' minuto(s) para PLSSIPTOT '
	Local aJobs		:= {"PLSIPDES","PLSIPEXP","PLSIPREE","PLSIPACU"}
	Default	cJob	:= "CENSIPCLA"
	Default	cTriRec	:= ""

	PtInternal(1,cMsg)

	While !lContinua

		For nFor := 1 TO Len(aJobs)

			cJob := aJobs[nFor]

			If aScan(aInfo,{ |x| AllTrim(x[5]) == cJob }) == 0
				lContinua := .T.
			Else
				lContinua := .F.
				nTempo += 60000
				Sleep(60000)//Aguardo 1 minuto
				PtInternal(1,cMsg)
				PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + cJob + cMsg,ARQUIVO_LOG)
				aInfo	:= GetUserInfoArray()
			EndIf

		Next nFor

	EndDo

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CpB3QTOB3L

Funcao criada para gravar registros na tabela B3L

@param	cAlias	area de trabalho corrente onde se le os dados

@author timoteo.bega
@since 16/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CpB3QTOB3L(cAliTrb)
	Local lInclui := ""
	Local lRetorno := ""
	Default cAliTrb := ""

	lInclui := !B3L->(msSeek( xFilial("B3F")+(cAliTrb)->(B3Q_CODOPE+B3Q_CODOBR+B3Q_ANOCMP+B3Q_CDCOMP+B3Q_EVEDES+B3Q_MATRIC+B3Q_CDTPTB+B3Q_CODEVE+B3Q_CLAAMB+B3Q_CLAINT+B3Q_FORCON+B3Q_SEGMEN+B3Q_DATEVE)))

	If RecLock("B3L",lInclui)
		If lInclui
			B3L->B3L_FILIAL := xFilial("B3F")
			B3L->B3L_CODOPE := (cAliTrb)->B3Q_CODOPE
			B3L->B3L_CODOBR := (cAliTrb)->B3Q_CODOBR
			B3L->B3L_ANOCMP := (cAliTrb)->B3Q_ANOCMP
			B3L->B3L_CDCOMP := (cAliTrb)->B3Q_CDCOMP
			B3L->B3L_EVEDES := (cAliTrb)->B3Q_EVEDES
			B3L->B3L_MATRIC := (cAliTrb)->B3Q_MATRIC
			B3L->B3L_CDTPTB := (cAliTrb)->B3Q_CDTPTB
			B3L->B3L_CODEVE := (cAliTrb)->B3Q_CODEVE
			B3L->B3L_CLAAMB := (cAliTrb)->B3Q_CLAAMB
			B3L->B3L_CLAINT := (cAliTrb)->B3Q_CLAINT
			B3L->B3L_FORCON := (cAliTrb)->B3Q_FORCON
			B3L->B3L_SEGMEN := (cAliTrb)->B3Q_SEGMEN
			B3L->B3L_DATEVE := STOD((cAliTrb)->B3Q_DATEVE)
			B3L->B3L_TRIREC := (cAliTrb)->B3Q_TRIREC
			B3L->B3L_TRIOCO := (cAliTrb)->B3Q_TRIOCO
			B3L->B3L_UF 	:= (cAliTrb)->B3Q_UF
			B3L->B3L_QTDEVE := (cAliTrb)->B3Q_QTDEVE
			B3L->B3L_VLREVE := (cAliTrb)->B3Q_VLREVE
			B3L->B3L_GRPINT := (cAliTrb)->B3Q_GRPINT
			B3L->B3L_REGINT := (cAliTrb)->B3Q_REGINT
			B3L->B3L_CID 	:= (cAliTrb)->B3Q_CID
			B3L->B3L_DTINVL := STOD(Space(8))
			B3L->B3L_HRINVL := Space(8)
			B3L->B3L_DTTEVL := STOD(Space(8))
			B3L->B3L_HRTEVL := Space(8)
			B3L->B3L_DTINSI := STOD(Space(8))
			B3L->B3L_HRINSI := Space(8)
			B3L->B3L_DATINT := STOD(Iif( !Empty((cAliTrb)->B3Q_DATINT),(cAliTrb)->B3Q_DATINT,Space(8) ) )
			B3L->B3L_HORINT := (cAliTrb)->B3Q_HORINT
			B3L->B3L_DATALT := STOD(Iif( !Empty((cAliTrb)->B3Q_DATALT),(cAliTrb)->B3Q_DATALT,Space(8) ) )
			B3L->B3L_HORALT := (cAliTrb)->B3Q_HORALT
			B3L->B3L_DENREG := (cAliTrb)->B3Q_DENREG
			B3L->B3L_EVDEIN := (cAliTrb)->B3Q_EVDEIN
			B3L->B3L_NASVIV := (cAliTrb)->B3Q_NASVIV
			If lB3L_EVDRES .And. lB3Q_EVDRES
				B3L->B3L_EVDRES := (cAliTrb)->B3Q_EVDRES
			EndIf
			if lB3L_CLASSH .and. lB3Q_CLASSH
				B3L->B3L_CLASSH := (cAliTrb)->B3Q_CLASSH
			endif
		Else
			B3L->B3L_QTDEVE += (cAliTrb)->B3Q_QTDEVE
			B3L->B3L_VLREVE += (cAliTrb)->B3Q_VLREVE
		EndIf
		B3L->B3L_STATUS := '1'
		B3L->(msUnLock())
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletaB3Q

Funcao criada para deletar o registro que acabou de ser copiado para a B3L

@param	cAlias	area de trabalho corrente onde se le os dados

@author everton.mateus
@since 04/10/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function DeletaB3Q(cAlias, cTriRec, cWhr)
	Local cSql := ""
	Local lDeletou := .F.

	cSql := " DELETE FROM " + RetSqlName("B3Q")
	cSql += cWhr
	cSql += " AND B3Q_EVEDES = '" + (cAlias)->B3Q_EVEDES + "' "
	cSql += " AND B3Q_MATRIC = '" + (cAlias)->B3Q_MATRIC + "' "
	cSql += " AND B3Q_CDTPTB = '" + (cAlias)->B3Q_CDTPTB + "' "
	cSql += " AND B3Q_CODEVE = '" + (cAlias)->B3Q_CODEVE + "' "
	cSql += " AND B3Q_CLAAMB = '" + (cAlias)->B3Q_CLAAMB + "' "
	cSql += " AND B3Q_CLAINT = '" + (cAlias)->B3Q_CLAINT + "' "
	cSql += " AND B3Q_FORCON = '" + (cAlias)->B3Q_FORCON + "' "
	cSql += " AND B3Q_SEGMEN = '" + (cAlias)->B3Q_SEGMEN + "' "
	cSql += " AND B3Q_DATEVE = '" + (cAlias)->B3Q_DATEVE + "' "
	cSql += " AND B3Q_EVDEIN = '" + (cAlias)->B3Q_EVDEIN + "' "

	lDeletou := TCSQLEXEC(cSql) >= 0
	If lDeletou
		If SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			TCSQLEXEC("COMMIT")
		EndIf
	Else
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("E") + " Erro ao DeletaB3Q " + TCSQLError(),ARQUIVO_LOG)
	EndIf

Return lDeletou
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENPOSCMP

Funcao criada para retornar a posicao do campo no array de estrutura

@param	aEstruB3L	array com a estrutura da tabela
@param	cCampo		campo a ser pesquisado na estrutura

@author timoteo.bega
@since 19/09/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CENPOSCMP(aEstru,cCampo)
	Local nPos := 0
	Default aEstru := {}
	Default cCampo := ""

	nPos := ascan(aEstru,{|x| x[1] == cCampo})

Return nPos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteTotal

Funcao criada para verificar se ja existe um registro totalizador baseado na chave

@author timoteo.bega
@since 19/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteTotal(cNomeArea,cItem,cChaveTotal)
	Local cSql 			:= ""
	Local lRetorno			:= .F.
	Default cNomeArea	:= ""
	Default cItem			:= ""
	Default cChaveTotal	:= ""

	cSql := " SELECT R_E_C_N_O_ REC "
	cSql += " FROM " + RetSqlName("B3L") + " "
	cSql += " WHERE "
	cSql += " B3L_FILIAL='"+xFilial("B3L")+"' "
	cSql += " AND B3L_CODOPE = '"+(cNomeArea)->B3L_CODOPE+"' "
	cSql += " AND B3L_CODOBR = '"+(cNomeArea)->B3L_CODOBR+"' "
	cSql += " AND B3L_ANOCMP = '"+(cNomeArea)->B3L_ANOCMP+"' "
	cSql += " AND B3L_CDCOMP = '"+(cNomeArea)->B3L_CDCOMP+"' "
	cSql += " AND B3L_EVEDES = '"+PADR(cChaveTotal,46,' ')+"' "
	cSql += " AND B3L_MATRIC = '"+PADR(cChaveTotal,18,' ')+"' "
	cSql += " AND B3L_CDTPTB = '"+Space(2)+"' "
	cSql += " AND B3L_CODEVE = '"+Space(16)+"' "
	cSql += " AND B3L_CLAAMB = '"+PADR(cItem,7,' ')+"' "
	cSql += " AND B3L_CLAINT = '"+PADR(cItem,7,' ')+"' "
	cSql += " AND B3L_FORCON = '"+(cNomeArea)->B3L_FORCON+"' "
	cSql += " AND B3L_SEGMEN = '"+AjustaSeg(cItem) +"' "
	cSql += " AND B3L_DATEVE = '"+Space(8)+"' "
	cSql += " AND B3L_EVDEIN = '"+Space(46)+"' "
	cSql += " AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBE",.F.,.T.)

	If !TRBE->(Eof())
		lRetorno := .T.
		B3L->(dbGoto(TRBE->REC))
	EndIf
	TRBE->(dbCloseArea())

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeEvoluir

Funcao criada para fazer o job aguardar os jobs de importacao concluirem e dar sequencia na totalizacao

@author timoteo.bega
@since 19/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeEvoluir(cTriRec)
	Local aInfo := GetUserInfoArray()

	If aScan(aInfo,{ |x| AllTrim(x[5]) == "PLSIPDES" }) > 0

		Sleep(60000)
		PodeTotalizar(cTriRec)

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EvoluiInternacao

Funcao criada para evoluir uma internacao de para obstetrica

@author timoteo.bega
@since 19/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function EvoluiInternacao(cRegANS,cCodObr,cAnoCmp,cCdComp,cTriRec)
	Local cSql			:= ""
	Default cRegANS	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCdComp	:= ""
	Default cTriRec	:= ""

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT EvoluiInternacao Inicio",ARQUIVO_LOG)
	PtInternal(1,'Evoluindo internacao ' + cAnoCmp +'-'+ cCdComp)

	//Listo todas as internacoes que estao ligadas com internacoes que tem parto e nao sao obstetricas
	cSql := "UPDATE " + RetSqlName("B3Q") + " SET B3Q_GRPINT='3' WHERE B3Q_FILIAL = '" + xFilial("B3Q") + "' AND B3Q_CODOPE = '"+ cRegANS +"' AND B3Q_CODOBR = '"+ cCodObr +"' AND B3Q_ANOCMP = '"+ cAnoCmp +"' AND B3Q_CDCOMP = '"+ cCdComp +"' AND B3Q_EVEDES <> B3Q_MATRIC "
	cSql += "AND B3Q_GRPINT <> '3' AND D_E_L_E_T_ = ' ' AND B3Q_EVDEIN IN "
	//Listo todas as internacoes que tem parto
	cSql += "(SELECT DISTINCT B3Q_EVDEIN FROM " + RetSqlName("B3Q") + " WHERE B3Q_FILIAL = '  ' AND B3Q_CODOPE = '" + cRegANS + "' AND B3Q_CODOBR = '" + cCodObr + "' AND B3Q_ANOCMP = '" + cAnoCmp + "' AND B3Q_CDCOMP = '" + cCdComp + "' AND B3Q_EVEDES <> B3Q_MATRIC AND B3Q_EVDEIN <> ' ' "
	cSql += "AND (B3Q_CLAAMB IN ('E131', 'E132', 'E133') OR B3Q_CLAINT IN ('E131', 'E132', 'E133')) AND D_E_L_E_T_ = ' ')"

	If TCSQLEXEC(cSql) < 0
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("E") + " Erro ao EvoluiInternacao " + TCSQLError(),ARQUIVO_LOG)
	Else
		TCSQLEXEC("COMMIT")
	EndIf
	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " EvoluiInternacao Termino",ARQUIVO_LOG)

	InternacaoEvolui(cRegANS,cCodObr,cAnoCmp,cCdComp,cTriRec)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InternacaoEvolui

Funcao criada para evoluir uma internacao de para obstetrica

@author timoteo.bega
@since 19/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function InternacaoEvolui(cRegANS,cCodObr,cAnoCmp,cCdComp,cTriRec)
	Local cSql			:= ""
	Default cRegANS	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCdComp	:= ""
	Default cTriRec	:= ""

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " InternacaoEvolui Inicio",ARQUIVO_LOG)

	//Listo todas as internacoes que estao ligadas com internacoes que tem parto e nao sao obstetricas
	cSql := " UPDATE " + RetSqlName("B3L") + " "
	cSql += " 	SET B3L_GRPINT='3' "
	cSql += " WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
	cSql += " 	AND B3L_CODOPE = '"+ cRegANS +"' "
	cSql += " 	AND B3L_CODOBR = '"+ cCodObr +"' "
	cSql += " 	AND B3L_ANOCMP = '"+ cAnoCmp +"' "
	cSql += " 	AND B3L_CDCOMP = '"+ cCdComp +"' "
	cSql += " 	AND B3L_EVEDES <> B3L_MATRIC "
	cSql += " 	AND B3L_GRPINT <> '3' "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql += " 	AND B3L_EVDEIN IN "
	//Listo todas as internacoes que tem parto
	cSql += " 	( "
	cSql += " 		SELECT DISTINCT B3L_EVDEIN "
	cSql += " 		FROM " + RetSqlName("B3L") + " "
	cSql += " 		WHERE "
	cSql += " 			B3L_FILIAL = '" + xFilial("B3L") + "' "
	cSql += " 			AND B3L_CODOPE = '" + cRegANS + "' "
	cSql += " 			AND B3L_CODOBR = '" + cCodObr + "' "
	cSql += " 			AND B3L_ANOCMP = '" + cAnoCmp + "' "
	cSql += " 			AND B3L_CDCOMP = '" + cCdComp + "' "
	cSql += " 			AND B3L_EVEDES <> B3L_MATRIC "
	cSql += " 			AND B3L_EVDEIN <> ' ' "
	cSql += " 			AND ( "
	cSql += " 					B3L_CLAAMB IN ('E131', 'E132', 'E133') "
	cSql += " 					OR B3L_CLAINT IN ('E131', 'E132', 'E133')"
	cSql += " 			) "
	cSql += " 			AND D_E_L_E_T_ = ' '"
	cSql += " 	) "
	If TCSQLEXEC(cSql) < 0
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("E") + " Erro InternacaoEvolui " + TCSQLError(),ARQUIVO_LOG)
	Else
		TCSQLEXEC("COMMIT")
	EndIf

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " InternacaoEvolui Termino",ARQUIVO_LOG)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaItensF

Funcao criada para gravar a classificacao dos itens Fs baseado no CID

@author timoteo.bega
@since 19/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaItensF(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec)
	Local cSql			:= ""
	Local aItens		:= {}
	Local nFor			:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 1
	Local lQryInter		:= .F.
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs		:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cTriRec	:= ""

	cNomJob := CENNOMJOB(nThread,nQuinzena,"TRBCLA",lQryInter)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,"TRBCLA",lQryInter)[2]
	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " CriaItensF Inicio",ARQUIVO_LOG)

	aAdd(aItens,{"F1"	," B3L_CID BETWEEN 'C00' AND 'D4899' "})
	aAdd(aItens,{"F11"	," (B3L_CID LIKE 'C50%' OR B3L_CID LIKE 'D05%') "})
	aAdd(aItens,{"F12"	," (B3L_CID LIKE 'C53%' OR B3L_CID LIKE 'D06%') "})
	aAdd(aItens,{"F13"	," B3L_CID BETWEEN 'C18' AND 'C2099' "})
	aAdd(aItens,{"F14"	," B3L_CID = 'C61' "})
	aAdd(aItens,{"F2"	," B3L_CID BETWEEN 'E10' AND 'E1499' "})
	aAdd(aItens,{"F3"	," B3L_CID BETWEEN 'I00' AND 'I9999' "})
	aAdd(aItens,{"F31"	," B3L_CID BETWEEN 'I21' AND 'I2299' "})
	aAdd(aItens,{"F32"	," B3L_CID BETWEEN 'I10' AND 'I1599' "})
	aAdd(aItens,{"F33"	," B3L_CID = 'I500' "})
	aAdd(aItens,{"F34"	," B3L_CID BETWEEN 'I60' AND 'I6999' "})
	aAdd(aItens,{"F341"	," B3L_CID = 'I64' "})
	aAdd(aItens,{"F4"	," B3L_CID BETWEEN 'J00' AND 'J9999' AND B3L_GRPINT <>'4' "})
	aAdd(aItens,{"F41"	," B3L_CID LIKE 'J44%' "})
	aAdd(aItens,{"F5"	," B3L_CID BETWEEN 'V01' AND 'Y9899' "})

	For nFor := 1 TO Len(aItens)
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " Classificando itens " + aItens[nFor,1] + " inicio: " + aItens[nFor,2],ARQUIVO_LOG)
		cObs := " Classificando itens " + aItens[nFor,1]
		CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		PtInternal(1,cObs)
		cSql := "UPDATE "
		cSql += " " + RetSqlName("B3L") + " "
		cSql += " SET "
		cSql += "  B3L_CLAAMB = '" + aItens[nFor,1] + "' "
		cSql += " ,B3L_CLAINT = '" + aItens[nFor,1] + "' "
		cSql += " WHERE "
		cSql += " B3L_FILIAL='" + xFilial("B3L") + "' "
		cSql += " AND B3L_CODOPE='" + cCodOpe + "' "
		cSql += " AND B3L_CODOBR='" + cCodObr + "' "
		cSql += " AND B3L_ANOCMP='" + cAnoCmp + "' "
		cSql += " AND B3L_CDCOMP='" + cCodCmp + "' "
		cSql += " AND B3L_EVEDES <> B3L_MATRIC "
		cSql += " AND B3L_EVDEIN <> ' ' "
		cSql += " AND B3L_GRPINT <> ' ' "
		cSql += " AND B3L_REGINT <> ' ' "
		cSql += " AND " + aItens[nFor,2]
		cSql += " AND D_E_L_E_T_ = ' ' "

		If TCSQLEXEC(cSql) < 0
			PlsLogFil("[" + cTriRec + "] " + CENDTHRL("E") + " Classificando itens " + aItens[nFor,1] + " erro:" + TCSQLError(),ARQUIVO_LOG)
		Else
			TCSQLEXEC("COMMIT")
		EndIf
		PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " Classificando itens " + aItens[nFor,1] + " fim. " + cSql,ARQUIVO_LOG)
	Next nFor
	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " CriaItensF Termino",ARQUIVO_LOG)
	cObs := cNomJob + " concluido!"
	CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ItemSemClassificacao

Procura itens que nao possuem classificacao

@author timoteo.bega
@since 30/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ItemSemClassificacao(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cMesOco,cTriRec)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local aItem		:= {}
	Local cCampos	:= "B3L_FILIAL,B3L_CODOPE,B3L_CODOBR,B3L_ANOCMP,B3L_CDCOMP,B3L_EVEDES,B3L_MATRIC,B3L_CDTPTB,B3L_CODEVE,B3L_CLAAMB,B3L_CLAINT,B3L_FORCON,B3L_SEGMEN,B3L_DATEVE, B3L_QTDEVE, B3L_VLREVE"
	Local lAtualiza	:= .F.
	Local nItens	:= 0
	Local nThread	:= 0
	Local nQuinzena	:= 1
	Local cNomJob	:= ""
	Local cDesJob	:= ""
	Local cObs		:= ""
	Local cDatExe	:= ""
	Local cHorExe	:= ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cMesOco	:= ""
	Default cTriRec	:= ""

	cNomJob := CENNOMJOB(nThread,nQuinzena,"CLA"+cMesOco,.F.,cMesOco)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,"CLA"+cMesOco,.F.,cMesOco)[2]

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " ItemSemClassificacao; Trimestre de Ocorrencia: "+cMesOco+"; Inicio",ARQUIVO_LOG)
	PtInternal(1,'Itens sem classificacao ' + cMesOco)

	cSql := " SELECT " +cCampos+ " , R_E_C_N_O_ RECS "
	cSql += " FROM " + RetSqlName("B3L") + " "
	cSql += " WHERE 1=1 "
	cSql += " AND B3L_FILIAL = '" + xFilial("B3L") + "' "
	cSql += " AND B3L_CODOPE = '" + cCodOpe + "' "
	cSql += " AND B3L_CODOBR = '" + cCodObr + "' "
	cSql += " AND B3L_ANOCMP = '" + cAnoCmp + "' "
	cSql += " AND B3L_CDCOMP = '" + cCodCmp + "' "
	cSql += " AND SUBSTRING(B3L_DATEVE,1,6) = '" + cMesOco + "' "
	cSql += " AND B3L_CLAAMB = ' ' "
	cSql += " AND B3L_EVDEIN = ' ' "
	cSql += " AND B3L_EVEDES <> B3L_MATRIC "
	cSql += " AND D_E_L_E_T_=' '"

	If CriaArea(cSql,cAliTrb,1,"ItemSemClassificacao",lMV_PLCENDB,cTriRec)

		B3L->(dbSetOrder(1))
		While !(cAliTrb)->(Eof())

			aItem := RetornaItem(cCodOpe,cCodObr,cAnoCmp,cCodCmp,AllTrim((cAliTrb)->B3L_MATRIC),(cAliTrb)->B3L_DATEVE,lMV_PLCENDB)

			//Atualiza itens sem classificacao com classificacao encontrada
			If !Empty(aItem[1])
				If B3L->(msSeek((cAliTrb)->(B3L_FILIAL+B3L_CODOPE+B3L_CODOBR+B3L_ANOCMP+B3L_CDCOMP+B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+B3L_DATEVE)))
					lAtualiza := .F.//Ja tenho a chave entao somente atualizo o registro existente e deleto o registro sem classificacao
				Else
					lAtualiza := .T.//Nao tenho a chave posso atualizar o registro sem classificacao
				EndIf

				AtualizaItens(cCodOpe,cCodObr,cAnoCmp,cCodCmp,AllTrim((cAliTrb)->B3L_MATRIC),(cAliTrb)->B3L_DATEVE,aItem,lAtualiza,(cAliTrb)->RECS,cAliTrb,lMV_PLCENDB)
			EndIf

			nItens++
			(cAliTrb)->(dbSkip())
			If nItens == 1 .OR. nItens % 1000 == 0
				PtInternal(1,'[ItemSemClassificacao - ' + cMesOco + '] ' + AllTrim(Str(nItens)) + ' itens classificados')
				cObs := AllTrim(Str(nItens)) + " registros processados"
				CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
			EndIf
		EndDo

	EndIf

	(cAliTrb)->(dbCloseArea())

	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " ItemSemClassificacao; Trimestre de Ocorrencia: "+cMesOco+"; Termino",ARQUIVO_LOG)
	PtInternal(1,'Itens sem classificacao ' + cMesOco + ' concluido!')
	LimpaArray(aItem)
	cObs := cNomJob + " concluido!"
	CENMANTB3V(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaItem

Retorna classificacao encontrada para determinado compromisso, matricula e data de evento

Regra
	1 - Se existir uma despesa apenas de consulta vincular a essa despesa
	2 - Se existir uma despesa de consulta e outro honorario vincular a essa despesa ao outro honorario
	3 - Se existir uma despesa de consulta e mais de 1 honorario vincular a despesa ao honorario de maior valor

@author timoteo.bega
@since 30/03/2018
/*/
//--------------------------------------------------------------------------------------------------
/* procura e retorna item de classificacao */
Static Function RetornaItem(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cMatric,cDatEve,lMV_PLCENDB)
	Local cSql			:= ""
	Local cAliTrb		:= GetNextAlias()
	Local cItem			:= ""
	Local aItem			:= {}
	Local nItem			:= 0
	Local nFor			:= 0
	Local nRecCom		:= 0
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cMatric	:= ""
	Default cDatEve	:= ""
	Default lMV_PLCENDB	:= MV_PLCENDB

	//Vou retornar todos os itens em ordem decrescente de valor para a matricula e data de evento
	cSql := " SELECT B3L_CLAAMB, "
	cSql += " SUM(B3L_VLREVE) B3L_VLREVE, "
	cSql += " MAX(R_E_C_N_O_) RECC "
	cSql += " FROM " + RetSqlName("B3L") + " "
	cSql += " WHERE "
	cSql += " B3L_FILIAL='" + xFilial("B3L") + "' "
	cSql += " AND B3L_MATRIC='" + cMatric + "' "
	cSql += " AND B3L_DATEVE='" + cDatEve + "' "
	cSql += " AND B3L_CODOPE='" + cCodOpe + "' "
	cSql += " AND B3L_CODOBR='" + cCodObr + "' "
	cSql += " AND B3L_ANOCMP='" + cAnoCmp + "' "
	cSql += " AND B3L_CDCOMP='" + cCodCmp + "' "
	cSql += " AND B3L_CLAAMB <> ' ' "
	cSql += " AND B3L_EVDEIN = ' ' "
	cSql += " AND D_E_L_E_T_=' ' "
	cSql += " GROUP BY B3L_CLAAMB, R_E_C_N_O_ ORDER BY B3L_VLREVE DESC"

	If CriaArea(cSql,cAliTrb,1,"RetornaItem",lMV_PLCENDB,cAnoCmp+SubStr(cCodCmp,2,2) )

		While !(cAliTrb)->(Eof())

			aAdd(aItem,{AllTrim((cAliTrb)->B3L_CLAAMB),(cAliTrb)->B3L_VLREVE,(cAliTrb)->RECC})
			(cAliTrb)->(dbSkip())

		EndDo

	EndIf

	(cAliTrb)->(dbCloseArea())

	If Len(aItem) > 0

		//Verifico se existe item diferente de A
		nItem := aScan(aItem,{ |x| SubStr(x[1],1,1) <> 'A'})

		If nItem > 0//Tenho item diferente de A, vou retornar o de maior valor

			For nFor := 1 TO Len(aItem)

				If SubStr(aItem[nFor,1],1,1) <> 'A'

					cItem := aItem[nFor,1]
					nRecCom := aItem[nFor,3]
					Exit

				EndIf

			Next nFor

		Else//Nao tenho item diferente de A, vou retornar o primeiro item da matriz

			cItem := aItem[1,1]
			nRecCom := aItem[1,3]

		EndIf

	EndIf

Return {cItem,nRecCom}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaItens

Atualiza itens sem classificacao para o compromisso, matricula e data com a classificacao passada em cItem

@author timoteo.bega
@since 30/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaItens(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cMatric,cDatEve,aItem,lAtualiza,nRecno,cAliTrb,lMV_PLCENDB)
	Local cSql	:= ""
	Local cMsg	:= ""
	Local cTriRec := ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cMatric	:= ""
	Default cDatEve	:= ""
	Default aItem	:= {}
	Default lAtualiza:= ""
	Default nRecno	:= 0
	Default cAliTrb	:= ""
	Default lMV_PLCENDB	:= MV_PLCENDB
	cTriRec := cAnoCmp + SubStr(cCodCmp,2,2)
	If Len(aItem) >= 2

		If !lAtualiza//Ja tenho a chave entao somente atualizo o registro existente e deleto o registro sem classificacao
			cSql := "UPDATE " + RetSqlName("B3L") + " SET B3L_VLREVE = B3L_VLREVE + " + AllTrim(Str((cAliTrb)->B3L_VLREVE)) + " WHERE R_E_C_N_O_ = " + AllTrim(Str(aItem[2]))
			If TCSQLEXEC(cSql) >= 0

				cSql := "DELETE FROM " + RetSqlName("B3L") + " WHERE R_E_C_N_O_ = " + AllTrim(Str(nRecno))
				If TCSQLEXEC(cSql) < 0
					cMsg := "[" + cTriRec + "] " + CENDTHRL("E") + " AtualizaItens; Instrucao: "+cSql+"; Mensagem: " + TCSQLError()
				EndIf

			Else
				cMsg := "[" + cTriRec + "] " + CENDTHRL("E") + " AtualizaItens; Instrucao: "+cSql+"; Mensagem: " + TCSQLError()
			EndIf

		Else//Nao tenho a chave posso atualizar o registro sem classificacao

			cSql := " UPDATE " + RetSqlName("B3L") + " SET B3L_CLAAMB = '" + AllTrim(aItem[1]) + "' "
			cSql += " WHERE R_E_C_N_O_ = " + AllTrim(Str(aItem[2]))
			If TCSQLEXEC(cSql) < 0
				cMsg := "[" + cTriRec + "] " + CENDTHRL("E") + " AtualizaItens; Instrucao: UPDATE; Mensagem: " + TCSQLError()
			EndIf

		EndIf

		If !Empty(cMsg)
			PlsLogFil(cMsg,ARQUIVO_LOG)
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OutrosAtendimentos

Funcao criada para atualizar para outros atendimentos (cOutros) despesas nao classificadas

@author timoteo.bega
@since 06/04/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function OutrosAtendimentos(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cOutros)
	Local cSql		:= ""
	Local cTriRec	:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cOutros	:= "H"

	dbSelectArea("B3L")

	cTriRec := cAnoCmp + SubStr(cCodCmp,2,2)

	PtInternal(1,'OutrosAtendimentos - Inicio')
	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT OutrosAtendimentos - Inicio",ARQUIVO_LOG)
	BEGIN TRANSACTION

		cSql := " UPDATE " + RetSqlName("B3L") + " SET B3L_CLAAMB='" + cOutros + "', B3L_CLAINT='" + cOutros + "' "
		if B3L->(fieldpos("B3L_CLASSH")) > 0 .and. cOutros == "H"
			//Comentario para check-in da nova alteracao.
			IIF(SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",cSql += ", B3L_CLASSH = UTL_RAW.cast_to_raw('Evento sem classificacao, movido para outras despesas') ", IIF(SubStr(Alltrim(Upper(TCGetDb())),1,6) == "POSTGRES",cSql += ", B3L_CLASSH = CAST('Evento sem classificacao, movido para outras despesas' AS BYTEA) ", cSql += ", B3L_CLASSH = CAST('Evento sem classificacao, movido para outras despesas' AS VARBINARY(1000)) ") )
		endif
		cSql += " WHERE B3L_FILIAL='" + xFilial("B3L") + "' "
		cSql += " AND B3L_CODOPE = '" + cCodOpe + "' "
		cSql += " AND B3L_CODOBR = '" + cCodObr + "' "
		cSql += " AND B3L_ANOCMP = '" + cAnoCmp + "' "
		cSql += " AND B3L_CDCOMP = '" + cCodCmp + "' "
		cSql += " AND B3L_CLAAMB = ' ' "
		cSql += " AND B3L_CLAINT = ' ' "
		cSql += " AND D_E_L_E_T_ = ' ' "

		TCSQLEXEC(cSql)
		TCSQLEXEC("COMMIT")

	END TRANSACTION

	PtInternal(1,'OutrosAtendimentos - Termino')
	PlsLogFil("[" + cTriRec + "] " + CENDTHRL("I") + " PLSSIPTOT OutrosAtendimentos - Termino",ARQUIVO_LOG)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaArray

Funcao criada para limpar array

@param	aTemp	Array a ser limpo

@author timoteob.bega
@since 09/08/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaArray(aTemp)
	Local nForArr	:= 0

	If Len(aTemp) > 0

		For nForArr := 1 TO Len(aTemp)
			aDel(aTemp,nForArr)
		Next nForArr

		ASize(aTemp,0)
		aTemp := {}

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IniciaClassificacao

Funcao criada para iniciar os jobs por mes de ocorrencia de classificacao de itens nao classificados

@author timoteob.bega
@since 27/07/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaClassificacao(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cTriRec,lMV_PLCENDB)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default cTriRec	:= ""
	Default lMV_PLCENDB	:= MV_PLCENDB

	PtInternal(1,'Iniciando itens sem classificacao ')

	cSql := " SELECT SUBSTRING(B3L_DATEVE,1,6) MESOCO, COUNT(1) QTDE "
	cSql += " FROM " + RetSqlName("B3L")  + " "
	cSql += " WHERE B3L_FILIAL='" + xFilial("B3L") + "' "
	cSql += " AND B3L_CODOPE = '" + cCodOpe + "' "
	cSql += " AND B3L_CODOBR = '" + cCodObr + "' "
	cSql += " AND B3L_ANOCMP = '" + cAnoCmp + "' "
	cSql += " AND B3L_CDCOMP = '" + cCodCmp + "' "
	cSql += " AND B3L_CLAAMB = ' ' "
	cSql += " AND B3L_EVDEIN = ' ' "
	cSql += " AND B3L_EVEDES <> B3L_MATRIC "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY  SUBSTRING(B3L_DATEVE,1,6) ORDER BY 2 DESC"

	If CriaArea(cSql,cAliTrb,1,"",lMV_PLCENDB,cTriRec)

		While !(cAliTrb)->(Eof())

			StartJob("CENSIPCLA",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cCodOpe,cCodObr,cAnoCmp,cCodCmp,(cAliTrb)->MESOCO,cTriRec)
			(cAliTrb)->(dbSkip())
			Sleep(2000)//Aguardo 2 segundos para lancar o proximo job

		EndDo

		(cAliTrb)->(dbCloseArea())

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENSIPCLA

Jod de classificacao de despesas nao classificadas

@author timoteob.bega
@since 27/07/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENSIPCLA(cEmpAnt,cFilAnt,cCodOpe,cCodObr,cAnoCmp,cCodCmp,cMesOco,cTriRec)
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCodCmp	:= ""
	Default	cMesOco	:= ""
	Default cTriRec	:= ""

	RpcSetType(3)
	RpcSetEnv(cEmpAnt,cFilAnt,,,'Environment')

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " CENSIPCLA " + cMesOco + " Inicio "
		PlsLogFil(cMsg,ARQUIVO_LOG)

		ItemSemClassificacao(cCodOpe,cCodObr,cAnoCmp,cCodCmp,cMesOco,cTriRec)//Tenta atribuir item sem classificacao a uma classificacao

		cMsg := "[" + cTriRec + "] " + CENDTHRL("I") + " CENSIPCLA " + cMesOco + " Termino "
		PlsLogFil(cMsg,ARQUIVO_LOG)
	END SEQUENCE
	ErrorBlock(bBlock)
Return
