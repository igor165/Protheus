#Include "Protheus.Ch"
#Include "PCOXLOAD.Ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PCO7LOAD      ºAutor  ³Kazoolo             º Data ³ 20/07/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para carregar os dados nas tabelas de Fase, Eventos e    º±±
±±º			 ³ Amarracao entre Fase e Eventos ("AMO","AMQ" e "AMR").           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³  Lógico - lRet                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCODefLoad()

	MsgRun(STR0024,STR0025,{|| PcoProcLoad()})

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PcoProcLoad   ºAutor  ³Kazoolo             º Data ³ 13/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para chamada das funcoes para popular as tabelas de 	   º±±
±±º			 ³ fases orcamentarias          								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³  			                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoProcLoad()

Local cSinc :=  SuperGetMV("MV_PCOSINC",.T.,"1")
local lCtPcox 	:= ExistBlock("PCOXCAN") //P.E. para retirada da verificação
local lRet		:=.T.

//------------------------------------------------------------Para uso com o release 12.1.17-------------------------------------------------
// Alteração dos CAMPOS abaixo  da tabela AMG  (x3_USADO)

PCOPICTU() //Ajusta X3_PICTURE dos campos virtuais AKD_VAL1, AKD_VAL2, AKD_VAL3, AKD_VAL4, AKD_VAL5.
//------------------------------------------------------------Para uso com o release 12.1.17-------------------------------------------------

DbSelectArea('AL3')

If AL3->(FieldPos("AL3_CONFIG")) == 0 .OR. TamSX3("AKA_CHAVE")[1] < 150 // Verifica o campo AL3_CONFIG PCO.PRW v.07/07/2005
	Aviso(STR0019,STR0026,{STR0027},2)	 //"Atencao!"###"Foram detectadas atualizações importantes na estrutura do SIGAPCO. Para utilização correta do módulo, contate o administrador do sistema."###"Finalizar"
	Final(STR0028) //"Atualizações no SIGAPCO. Contate o Administrador do Sistema"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Funcao para popular a tabela de processos AK8.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoChkAK8()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Popula a AKL e AKM  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A160Popula()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Ajuste no campo AKA_CHAVE pois estava truncando c 80 posic.  ³
	//³  alterado pco.prw para aumentar para 150                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoAjstBlq()
	If cSinc =="2"
		PcoSincCO("CT1",4)
	   ElseIf cSinc =="3"
		PcoSincCO("CTT",4)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Elimina os registros referente a lancamentos de bloqueio que por  ³
	//³  alguma anormalidade nao foram aproveitados pela                   ³
	//³  funcao pcodetlan() ou por queda do sistema no momento da          ³
	//³  gravacao dos lancamentos normais.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoChkBlq()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verica se existe campo AKG_ENTIDA na tabela AKG e em caso  ³
	//³  positivo se estiver em branco popula com "2"controle total.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoAjstEntd()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Retira o status bloqueado (AL1_STATUS)quando reprocessamento de cubo  ³
	//³  gerencial por qq motivo nao terminar normalmente                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoChkCubo()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Verifica se as tabelas AMO, AMQ e AMR existem no dicionario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCtPcox
		lRet:= ExecBlock("PCOXCAN")
	EndIf
	If lRet
		If AliasInDic("AMO") .And. AliasInDic("AMQ") .And. AliasInDic("AMR")
			PcoChkAmq()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Verifica se as tabelas AMG, AMH e AMI existem no dicionario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If AliasInDic("AMG") .And. AliasInDic("AMH") .And. AliasInDic("AMI")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Verifica se já existe fases padroes cadastradas  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("AMG")
			DbSetOrder(1)
			If !AMG->(DbSeek(xFilial("AMG")+"001"))
	   			PcoChkAmg()
	 		EndIf
	 	EndIf
	EndIf

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PcoChkAmq     ºAutor  ³Kazoolo             º Data ³ 13/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para gravacao das fases com seus respectivos eventos.	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 					                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoChkAmq()

Local alEvento	:= {}
Local alFase	:= {}
Local alItFaEv	:= {}
Local alRecAMQ	:= {}
Local alRecAMO	:= {}
Local alRecAMR	:= {}
Local nlI		:= 0
Local nlJ		:= 0

Pco007Ar(@alEvento,@alFase,@alItFaEv)

	For nlI := 1 to Len(alEvento)
	dbSelectArea("AMQ")
	dbSetOrder(1)
		If !dbSeek(xFilial("AMQ")+alEvento[nlI][1])
			RecLock("AMQ",.T.)
		Else
			RecLock("AMQ",.F.)
		EndIf
		AMQ->AMQ_FILIAL	:= xFilial("AMQ")
		AMQ->AMQ_EVENT 	:= alEvento[nlI][1]
		AMQ->AMQ_DESCRI	:= alEvento[nlI][2]
		MsUnlock()
		aAdd(alRecAMQ,AMQ->(RecNo()))
	Next nlI

	For nlI := 1 to Len(alFase)
		dbSelectArea("AMO")
		dbSetOrder(1)
		If !dbSeek(xFilial("AMO")+alFase[nlI][1])
			RecLock("AMO",.T.)
		Else
			RecLock("AMO",.F.)
		EndIf
		AMO->AMO_FILIAL	:= xFilial("AMO")
		AMO->AMO_FASE 	:= alFase[nlI][1]
		AMO->AMO_DESCRI	:= alFase[nlI][2]
		AMO->AMO_CORBRW	:= alFase[nlI][3]
		AMO->AMO_MSG	:= alFase[nlI][4]
		MsUnlock()
		aAdd(alRecAMO,AMO->(RecNo()))
	Next nlI

	For nlI := 1 to Len(alFase)
		For nlJ := 1 To Len(alItFaEv)
			If alFase[nlI][1] == alItFaEv[nlJ][1]
				dbSelectArea("AMR")
				dbSetOrder(1)
				If !dbSeek(xFilial("AMR")+alFase[nlI][1]+alItFaEv[nlJ][2])
					RecLock("AMR",.T.)
					AMR->AMR_FILIAL	:= xFilial("AMR")
					AMR->AMR_FASE 	:= alFase[nlI][1]
					AMR->AMR_EVENT 	:= alItFaEv[nlJ][2]
					AMR->AMR_PERMIT	:= alItFaEv[nlJ][4]
				Else
					RecLock("AMR",.F.)
					AMR->AMR_FILIAL	:= xFilial("AMR")
					AMR->AMR_FASE 	:= alFase[nlI][1]
					AMR->AMR_EVENT 	:= alItFaEv[nlJ][2]
				EndIf
				MSMM(,TamSx3("AMR_MSG")[1],, alItFaEv[nlI][5],1,,,"AMR","AMR_MSG")
				MsUnlock()
				aAdd(alRecAMR,AMR->(RecNo()))
			EndIf
		Next nlJ
	Next nlI

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PcoVldFE     ºAutor  ³Kazoolo              º Data ³ 13/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validacao das fases.								   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ clCodFas,clCodEv, clEvent									   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Lógico - llOk	                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVldFE(clCodFas,clCodEv, clEvent)

	Local llOk		:= .F.
	Local alEvent	:= {}
	Local alFase	:= {}
	Local alItFaEv	:= {}

	Pco007Ar(@alEvent,@alFase,@alItFaEv)

	If !Empty(clCodEv)
		If clEvent == 2
			If aScan(alEvent,{|x| x[1] == clCodEv}) == 0
				DbSelectArea("AMR")
				DbSetOrder(2)
				If !DbSeek(xFilial("AMR")+clCodEv)
					llOk := .T.
				Else
					Aviso(STR0019,STR0021,{STR0020})
				EndIf
			Else
				Aviso(STR0019,STR0022,{STR0020})
			EndIf
		Else
			If	aScan(alItFaEv,{|x| x[2] == clCodEv .And. x[1] == clCodFas }) == 0	.Or. Empty(clCodFas)
				llOk	:= .T.
			Else
				Aviso(STR0019,STR0021,{STR0020})
			EndIf
		EndIf
	ELse
		llOk	:= .T.
	EndIf

Return(llOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ Pco007Ar      ºAutor  ³Kazoolo              º Data ³ 13/09/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para preenchimento do array com os eventos e acoes 	   º±±
±±º			 ³ padroes do sistema								   			   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaPco                                                     	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ alEvento,alFase,alItFaEv  									   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ 					                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco007Ar(alEvento,alFase,alItFaEv)

	aAdd(alEvento,	{"0001",STR0001})
	aAdd(alEvento,	{"0002",STR0002})
	aAdd(alEvento,	{"0003",STR0003})
	aAdd(alEvento,	{"0004",STR0004})
	aAdd(alEvento,	{"0005",STR0005})
	aAdd(alEvento,	{"0006",STR0006})
	aAdd(alEvento,	{"0007",STR0007})
	aAdd(alEvento,	{"0008",STR0008})
	aAdd(alEvento,	{"0009",STR0009})
	aAdd(alEvento,	{"0010",STR0010})
	aAdd(alEvento,	{"0011",STR0011})
	aAdd(alEvento,	{"0012",STR0012})
	aAdd(alEvento,	{"0013",STR0013})
	aAdd(alEvento,	{"0014",STR0014})
	aAdd(alEvento,	{"0015",STR0015})
	aAdd(alEvento,	{"0016",STR0016})
	aAdd(alEvento,	{"0017",STR0017})
	aAdd(alEvento,	{"0018",STR0018})
	aAdd(alEvento,	{"0019",STR0029})
	aAdd(alEvento,	{"0020",STR0030})

	aAdd(alFase,	{"001","PLANEJAMENTO","8",STR0031}) // "Ação não permitida!" STR0031
	aAdd(alItFaEv,	{"001","0001",STR0001	,"1",""})
	aAdd(alItFaEv,	{"001","0002",STR0002	,"1",""})
	aAdd(alItFaEv,	{"001","0003",STR0003	,"1",""})
	aAdd(alItFaEv,	{"001","0004",STR0004	,"1",""})
	aAdd(alItFaEv,	{"001","0005",STR0005	,"1",""})
	aAdd(alItFaEv,	{"001","0006",STR0006	,"1",""})
	aAdd(alItFaEv,	{"001","0007",STR0007	,"1",""})
	aAdd(alItFaEv,	{"001","0008",STR0008	,"1",""})
	aAdd(alItFaEv,	{"001","0009",STR0009	,"1",""})
	aAdd(alItFaEv,	{"001","0010",STR0010	,"1",""})
	aAdd(alItFaEv,	{"001","0011",STR0011	,"1",""})
	aAdd(alItFaEv,	{"001","0012",STR0012	,"1",""})
	aAdd(alItFaEv,	{"001","0013",STR0013	,"1",""})
	aAdd(alItFaEv,	{"001","0014",STR0014	,"1",""})
	aAdd(alItFaEv,	{"001","0015",STR0015	,"1",""})
	aAdd(alItFaEv,	{"001","0016",STR0016	,"1",""})
	aAdd(alItFaEv,	{"001","0017",STR0017	,"1",""})
	aAdd(alItFaEv,	{"001","0018",STR0018	,"1",""})
	aAdd(alItFaEv,	{"001","0019",STR0029	,"1",""})
	aAdd(alItFaEv,	{"001","0020",STR0030	,"1",""})

	aAdd(alFase,	{"002","EXECUCAO","2",STR0031}) // "Ação não permitida!"
	aAdd(alItFaEv,	{"002","0001",STR0001	,"2",""})
	aAdd(alItFaEv,	{"002","0002",STR0002	,"2",""})
	aAdd(alItFaEv,	{"002","0003",STR0003	,"2",""})
	aAdd(alItFaEv,	{"002","0004",STR0004	,"2",""})
	aAdd(alItFaEv,	{"002","0005",STR0005	,"2",""})
	aAdd(alItFaEv,	{"002","0006",STR0006	,"2",""})
	aAdd(alItFaEv,	{"002","0007",STR0007	,"2",""})
	aAdd(alItFaEv,	{"002","0008",STR0008	,"2",""})
	aAdd(alItFaEv,	{"002","0009",STR0009	,"2",""})
	aAdd(alItFaEv,	{"002","0010",STR0010	,"2",""})
	aAdd(alItFaEv,	{"002","0011",STR0011	,"2",""})
	aAdd(alItFaEv,	{"002","0012",STR0012	,"2",""})
	aAdd(alItFaEv,	{"002","0013",STR0013	,"2",""})
	aAdd(alItFaEv,	{"002","0014",STR0014	,"2",""})
	aAdd(alItFaEv,	{"002","0015",STR0015	,"2",""})
	aAdd(alItFaEv,	{"002","0016",STR0016	,"2",""})
	aAdd(alItFaEv,	{"002","0017",STR0017	,"2",""})
	aAdd(alItFaEv,	{"002","0018",STR0018	,"2",""})
	aAdd(alItFaEv,	{"002","0019",STR0029	,"2",""})
	aAdd(alItFaEv,	{"002","0020",STR0030	,"2",""})

	aAdd(alFase,	{"003","REVISAO","1",STR0031}) // "Ação não permitida!"
	aAdd(alItFaEv,	{"003","0001",STR0001	,"2",""})
	aAdd(alItFaEv,	{"003","0002",STR0002	,"2",""})
	aAdd(alItFaEv,	{"003","0003",STR0003	,"2",""})
	aAdd(alItFaEv,	{"003","0004",STR0004	,"2",""})
	aAdd(alItFaEv,	{"003","0005",STR0005	,"2",""})
	aAdd(alItFaEv,	{"003","0006",STR0006	,"2",""})
	aAdd(alItFaEv,	{"003","0007",STR0007	,"2",""})
	aAdd(alItFaEv,	{"003","0008",STR0008	,"2",""})
	aAdd(alItFaEv,	{"003","0009",STR0009	,"2",""})
	aAdd(alItFaEv,	{"003","0010",STR0010	,"2",""})
	aAdd(alItFaEv,	{"003","0011",STR0011	,"2",""})
	aAdd(alItFaEv,	{"003","0012",STR0012	,"2",""})
	aAdd(alItFaEv,	{"003","0013",STR0013	,"2",""})
	aAdd(alItFaEv,	{"003","0014",STR0014	,"2",""})
	aAdd(alItFaEv,	{"003","0015",STR0015	,"2",""})
	aAdd(alItFaEv,	{"003","0016",STR0016	,"2",""})
	aAdd(alItFaEv,	{"003","0017",STR0017	,"2",""})
	aAdd(alItFaEv,	{"003","0018",STR0018	,"2",""})
	aAdd(alItFaEv,	{"003","0019",STR0029	,"2",""})
	aAdd(alItFaEv,	{"003","0020",STR0030	,"2",""})

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO5ARRPAD³ Autor ³ Luiz Enrique	     	³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno Por Referencia dos Arrays das Fases e Acoes Padroes. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCO5ARRPAD (aFases,aAcoes)

//					|AMG           |COR| |MEMO Principal        |
aAdd(aFases,	{STR0573,"1",STR0519,"01"}) //"Criacao"#"Operacao nao permitida."
aAdd(aFases,	{STR0574,"2",STR0519,"02"}) //"Elaboracao"#"Operacao nao permitida."
aAdd(aFases,	{STR0575,"3",STR0519,"03"}) //"Finalizado"#"Operacao nao permitida."

// A  T  E  N  C  A  O
//INCLUSOES DE NOVAS ACOES, SOMENTE NO FINAL DOS ARRAY.

//					|AMI							 							  |AMH-Permissoes: 1=Sim, 2=Nao|
aAdd(aAcoes,	{"0001",STR0520,"1","1","2"}) //"Permitir Planejar"
aAdd(aAcoes,	{"0002",STR0521,"1","2","2"}) //"Definir Estrutura de Planejamento"
aAdd(aAcoes,	{"0003",STR0522,"2","1","2"}) //"Incluir Distribuicao de Entidades"
aAdd(aAcoes,	{"0004",STR0523,"2","1","2"}) //"Alterar Distribuicao de Entidades"
aAdd(aAcoes,	{"0005",STR0524,"2","1","2"}) //"Excluir Distribuicao de Entidades"
aAdd(aAcoes,	{"0006",STR0525,"2","1","2"}) //"Definir Valores da Distribuicao"
aAdd(aAcoes,	{"0007",STR0526,"2","1","2"}) //"Permite Reajuste de Valor"
aAdd(aAcoes,	{"0008",STR0527,"2","1","1"}) //"Controla Restricao de Conta Orcamentaria"
aAdd(aAcoes,	{"0009",STR0528,"2","1","1"}) //"Controla Restricao de Centro de Custo"
aAdd(aAcoes,	{"0010",STR0529,"2","1","1"}) //"Controla Resticao de Item Contabil"
aAdd(aAcoes,	{"0011",STR0530,"2","1","1"}) //"Controla Restricao de Classe de Valor"
aAdd(aAcoes,	{"0012",STR0531,"2","1","2"}) //"Permite Gerar variacao de Movimento"
aAdd(aAcoes,	{"0013",STR0532,"2","1","2"}) //"Permite Gerar Outras Variacoes"
aAdd(aAcoes,	{"0014",STR0533,"2","2","2"}) //"Permite Revisao"
aAdd(aAcoes,	{"0015",STR0534,"2","1","2"}) //"Permite Simulacao"
aAdd(aAcoes,	{"0016",STR0535,"2","2","1"}) //"Gera Planilha Orcamentaria"
aAdd(aAcoes,	{"0017",STR0536,"1","2","2"}) //"Permite limite de Valor"

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoChkAmg ³ Autor ³ Luiz Enrique	        ³ Data ³ 22/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para carregar dados iniciais nas tabelas AMI,AMG,AMH  ³±±
±±³			 ³ do Modulo de Monitor do Planejamento Orcamentario.			³±±
±±³			 ³ AMI: Tabela das ACOES;										³±±
±±³			 ³ AMG: Tabela das FASES;										³±±
±±³			 ³ AMH: Tabela das ACOES X FASES.								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PcoChkAmg()

	Local nAc
	Local nAf
	Local aAcoes:= {}
	Local aFases:= {}

	//Inclui ACOES Pre-Definidas
	PCO5ARRPAD (@aFases,@aAcoes)

	AMI->(dbSetOrder(1)) //Filial + Cod Evento

	For nAc:= 1 To Len(aAcoes)

		If !AMI->(DbSeek(xFilial()+aAcoes[nAc,1]))
	 		AMI->(RecLock("AMI",.T.))
	 	Else
	 		Loop
	 	Endif
		AMI->AMI_FILIAL := xFilial("AMI")
		AMI->AMI_CODEVT := Strzero(nAc,4)	//GetSx8Num('AMI','AMI_CODEVT')
		AMI->AMI_DESCRI := Upper(aAcoes[nAc,2])
		AMI->(MsUnlock())

	Next

	//Inclui FASES Pre-Definidas

	AMG->(dbSetOrder(1)) //Filial + Cod. Fase

	For nAc:= 1 To Len(aFases)

		If !AMG->(DbSeek(xFilial()+aFases[nAc,4]))
	 		AMG->(RecLock("AMG",.T.))
	 	Else
	 		Loop
	 	Endif
		AMG->AMG_FILIAL := xFilial("AMG")
		AMG->AMG_COD := aFases[nAc,4]//GetSx8Num('AMG','AMG_COD')
		AMG->AMG_DESCRI := Upper(aFases[nAc,1])
		AMG->AMG_CORBRW := aFases[nAc,2]
		AMG->(MsUnlock())

	Next

	//Inclui AMARRACAO ACAO x FASES Pre-Definidas

	AMI->(dbSetOrder(1)) //ACOES:			Filial + Cod Evento
	AMG->(dbSetOrder(1)) //FASES:			Filial + Cod. Fase
	AMH->(dbSetOrder(1)) //AMARRACAO:	Filial + Codigos da Fase + Codigo da Acao

	For nAc:= 1 To Len(aAcoes)

		//Posiciona em ACAO
		AMI->(DbSeek(xFilial()+aAcoes[nAc,1]))

		For nAF:= 1 To Len(aFases)

			//Posiciona em FASES
			AMG->(DbSeek(xFilial()+aFases[nAf,4]))

			If !AMH->(DbSeek(xFilial()+AMG->AMG_COD+AMI->AMI_CODEVT))
		 		AMH->(RecLock("AMH",.T.))
		 	Else
		 		Loop
		 	Endif
			AMH->AMH_FILIAL := xFilial("AMH")
			AMH->AMH_CODFAS := AMG->AMG_COD
			AMH->AMH_CODEVT := AMI->AMI_CODEVT
			AMH->AMH_PERMIT	:= aAcoes[nAc,nAF+2]
			AMH->(MsUnlock())

		Next
	Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAjstBlqºAutor  ³Paulo Carnelossi    º Data ³  15/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajuste no campo AKA_CHAVE pois estava truncando c 80 posic. º±±
±±º          ³alterado pco.prw para aumentar para 150                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAjstBlq()
Local aArea := GetArea()
Local aAreaAKA := AKA->(GetArea())

dbSelectArea("AKA")
If dbSeek(xFilial("AKA")+"000002"+"01") .And. ;
	Alltrim(AKA->AKA_CHAVE) != "xFilial('SE2')+M->E2_FILIAL+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA"
	RecLock("AKA", .F.)
	AKA_CHAVE := "xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA"
	MsUnLock()
EndIf

RestArea(aAreaAKA)
RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoAjstEntd ºAutor  ³Paulo Carnelossi  º Data ³  20/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verica se existe campo AKG_ENTIDA na tabela AKG e em caso  º±±
±±º          ³ positivo se estiver em branco popula com "2"controle total º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PcoAjstEntd()
Local aArea := GetArea()
Local cQuery



cQuery := " SELECT R_E_C_N_O_ "
cQuery += " FROM " + RetSQLName("AKG") + " AKG "
cQuery += "  WHERE "
cQuery	+=	" AKG_FILIAL='"+xFilial('AKG')+"' AND "
cQuery += "  AKG_ENTIDA = ' ' AND"
cQuery	+=	" D_E_L_E_T_= ' ' "

cQuery	:=	ChangeQuery(cQuery)

DbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )
DbSelectArea("QRYTRB")
DbGoTop()

While !Eof()

	dbSelectArea("AKG")
	DbGoto(QRYTRB->R_E_C_N_O_)
	RecLock("AKG", .F.)
	AKG->AKG_ENTIDA := "2"
	MsUnLock()

	dbSelectArea("QRYTRB")
	QRYTRB->(dbSkip())

End

dbSelectArea("QRYTRB")
DbCloseArea()


RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOChkAK8³ Autor ³ Edson Maricate         ³ Data ³ 12-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para popular a tabela de processos AK8.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoChkAK8()

Local nx
Local aProcess	:= {}
Local aItens	:= {}
Local aBlq		:= {}
Local aRecAK8	:= {}
Local aRecAKA	:= {}
Local aRecAKB	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array contendo os processos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aProcess,	{"000001",STR0032,"FINA040"}) // OK //"CONTAS A RECEBER"
aAdd(aItens,	{"000001","01",STR0033,"SE1",1}) // "Inclusao de titulos a receber"
aAdd(aItens,	{"000001","02",STR0034,"SE1",1}) // "Inclusao de titulos a receber - titulos Tipo RA"
aAdd(aItens,	{"000001","03",STR0035,"SE1",1}) // "Geracao do titulo por desdobramento "
aAdd(aItens,	{"000001","04",STR0036,"SEV",2}) // "Rateio multi naturezas "
aAdd(aItens,	{"000001","05",STR0040,"SEZ",4}) // "Rateio C.Custo multi naturezas "
aAdd(aItens,	{"000001","06",STR0279,"SE1",1}) // "Retencao de IRRF"
aAdd(aItens,	{"000001","07",STR0280,"SE1",1}) // "Retencao de INSS"
aAdd(aItens,	{"000001","08",STR0281,"SE1",1}) // "Retencao de ISS"
aAdd(aItens,	{"000001","09",STR0282,"SE1",1}) // "Retencao de COFINS"
aAdd(aItens,	{"000001","10",STR0283,"SE1",1}) // "Retencao de PIS"
aAdd(aItens,	{"000001","11",STR0284,"SE1",1}) // "Retencao de CSLL"
aAdd(aItens,	{"000001","12",STR0285,"SE2",1}) // "Pagamento de IRRF"
aAdd(aItens,	{"000001","13",STR0286,"SE2",1}) // "Pagamento de ISS"

aAdd(aBlq,	{"000001","01",STR0033,"xFilial('SE1')+M->E1_PREFIXO+M->E1_NUM+M->E1_PARCELA+M->E1_TIPO","SE1"}) // "Inclusao de titulos a receber"
aAdd(aBlq,	{"000001","02",STR0034,"xFilial('SE1')+M->E1_PREFIXO+M->E1_NUM+M->E1_PARCELA+M->E1_TIPO","SE1"}) // "Inclusao de titulos a receber - titulos Tipo RA"

aAdd(aProcess,	{"000002",STR0037,"FINA050"}) // OK //"CONTAS A PAGAR"
aAdd(aItens,	{"000002","01",STR0038,"SE2",1}) // "Inclusao de titulos a pagar"
aAdd(aItens,	{"000002","02",STR0039,"SE2",1}) // "Inclusao de titulos a pagar - titulos Tipo PA"
aAdd(aItens,	{"000002","03",STR0035,"SE2",1}) // "Geracao do titulo por desdobramento "
aAdd(aItens,	{"000002","04",STR0036,"SEV",2}) // "Rateio multi naturezas "
aAdd(aItens,	{"000002","05",STR0040,"SEZ",4}) // "Rateio C.Custo multi naturezas "
aAdd(aItens,	{"000002","06",STR0285,"SE2",1}) // "Pagamento de IRRF"
aAdd(aItens,	{"000002","07",STR0287,"SE2",1}) // "Pagamento de INSS"
aAdd(aItens,	{"000002","08",STR0288,"SE2",1}) // "Pagamento de SEST/SENAT"
aAdd(aItens,	{"000002","09",STR0286,"SE2",1}) // "Pagamento de ISS"
aAdd(aItens,	{"000002","10",STR0289,"SE2",1}) // "Pagamento de PIS"
aAdd(aItens,	{"000002","11",STR0290,"SE2",1}) // "Pagamento de COFINS"
aAdd(aItens,	{"000002","12",STR0291,"SE2",1}) // "Pagamento de CSLL"

aAdd(aBlq,	{"000002","01",STR0038,"xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA","SE2"}) //"Inclusao de titulos a pagar"
aAdd(aBlq,	{"000002","02",STR0039,"xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA","SE2"}) //"Inclusao de titulos a pagar (PA)"
aAdd(aBlq,	{"000002","03",STR0035,"xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA","SE2"}) //"Geração de Título por Desdobramento"

aAdd(aProcess,	{"000003",STR0041,"FINA060"}) //"TRANSFERENCIAS - FINANCEIRO"
aAdd(aItens,	{"000003","01",STR0042,"SE1",1}) //"Transferencia para carteira"
aAdd(aItens,	{"000003","02",STR0043,"SE1",1}) //"Transferencia para contas a receber simples"
aAdd(aItens,	{"000003","03",STR0044,"SE1",1}) //"Transferencia para contas a receber descontada"
aAdd(aItens,	{"000003","04",STR0045,"SE1",1}) //"Transferencia para contas a receber caucionada"
aAdd(aItens,	{"000003","05",STR0046,"SE1",1}) //"Transferencia para contas a receber vinculada"
aAdd(aItens,	{"000003","06",STR0047,"SE1",1}) //"Transferencia para contas a receber advogado"
aAdd(aItens,	{"000003","07",STR0048,"SE1",1}) //"Transferencia para contas a receber judicial"
aAdd(aItens,	{"000003","08",STR0049,"SE1",1}) //"Bordero carteira"
aAdd(aItens,	{"000003","09",STR0050,"SE1",1}) //"Bordero contas a receber simples"
aAdd(aItens,	{"000003","10",STR0051,"SE1",1}) //"Bordero contas a receber descontada"
aAdd(aItens,	{"000003","11",STR0052,"SE1",1}) //"Bordero contas a receber caucionada"
aAdd(aItens,	{"000003","12",STR0053,"SE1",1}) //"Bordero contas a receber vinculada"
aAdd(aItens,	{"000003","13",STR0054,"SE1",1}) //"Bordero contas a receber advogado"
aAdd(aItens,	{"000003","14",STR0055,"SE1",1}) //"Bordero contas a receber judicial"
aAdd(aItens,	{"000003","15",STR0056,"SE1",1}) //"Cancelamento de bordero"
aAdd(aItens,	{"000003","16",STR0057,"SE1",1}) //"Transferencia para contas a receber caucionada descontada"
aAdd(aItens,	{"000003","17",STR0058,"SE1",1}) //"Bordero para contas a receber caucionada descontada"

aAdd(aProcess,{"000004",STR0059,STR0060}) //"BAIXAS A RECEBER"###"FINA070"
aAdd(aItens,	{"000004","01",STR0061,"SE5",2}) //"Baixas a receber - carteira"
aAdd(aItens,	{"000004","02",STR0062,"SE5",2}) //"Baixas a receber - contas a receber simples"
aAdd(aItens,	{"000004","03",STR0063,"SE5",2}) //"Baixas a receber - contas a receber descontada"
aAdd(aItens,	{"000004","04",STR0064,"SE5",2}) //"Baixas a receber - contas a receber vinculada"
aAdd(aItens,	{"000004","05",STR0065,"SE5",2}) //"Baixas a receber - contas a receber advogado"
aAdd(aItens,	{"000004","06",STR0066,"SE5",2}) //"Baixas a receber - contas a receber judicial"
aAdd(aItens,	{"000004","07",STR0067,"SE5",2}) //"Cancelamento de baixas a receber"
aAdd(aItens,	{"000004","08",STR0068,"SE5",2}) //"Baixa do tiulo contas a areceber caucionada descontada"
aAdd(aItens,	{"000004","09",STR0443,"SEV",2}) //"Baixas a Receber com Rateio multi naturezas"
aAdd(aItens,	{"000004","10",STR0444,"SEZ",4}) //"Baixas a Receber com Rateio C.Custo multi naturezas"

aAdd(aBlq,	{"000004","01",STR0062,"''","SE5"}) //"Baixas a receber - contas a receber simples"
aAdd(aProcess,{"000005",STR0069,STR0070}) //"BAIXAS A PAGAR"###"FINA080"
aAdd(aItens,	{"000005","01",STR0069,"SE5",2,.T.,,"1"}) //"Baixas a pagar"
aAdd(aItens,	{"000005","02",STR0071,"SE5",2}) //"Calncelamento de baixas a pagar"
aAdd(aItens,	{"000005","03",STR0445,"SEV",2}) //"Baixas a Pagar com Rateio multi naturezas"
aAdd(aItens,	{"000005","04",STR0446,"SEZ",4}) //"Baixas a Pagar com Rateio C.Custo multi naturezas"

aAdd(aBlq,	{"000005","01",STR0069,"''","SE5"}) //"Baixas a pagar"

aAdd(aProcess,{"000006",STR0072,"FINA090"}) //"BAIXAS A PAGAR AUTOMATICA"
aAdd(aItens,	{"000006","01",STR0073,"SE5",2}) //"Baixas por bordero de pagamento"
aAdd(aItens,	{"000006","02",STR0445,"SEV",2}) //"Baixas a Pagar com Rateio multi naturezas"
aAdd(aItens,	{"000006","03",STR0446,"SEZ",4}) //"Baixas a Pagar com Rateio C.Custo multi naturezas"

aAdd(aBlq,	{"000006","01",STR0073,"xFilial('SE2')+M->E2_PREFIXO+M->E2_NUM+M->E2_PARCELA+M->E2_TIPO+M->E2_FORNECE+M->E2_LOJA","SE2"}) //"Baixas por bordero de pagamento"

aAdd(aProcess,{"000007",STR0074,"FINA100"}) //"MOVIMENTACAO BANCARIA"
aAdd(aItens,	{"000007","01",STR0075,"SE5",1}) //"Transferencia bancaria - Origem"
aAdd(aItens,	{"000007","02",STR0076,"SE5",1}) //"Transferencia bancaria - Destino"
aAdd(aItens,	{"000007","03",STR0077,"SE5",1})//"Movimento bancario a pagar"
aAdd(aItens,	{"000007","04",STR0079,"SE5",1}) //"Movimento bancario a receber"
aAdd(aItens,	{"000007","05",STR0081,"CV4",1}) //"Rateio de movimento bancario a pagar"
aAdd(aItens,	{"000007","06",STR0083,"CV4",1}) //"Rateio de movimento bancario a receber"
aAdd(aItens,	{"000007","07",STR0078,"SE5",1}) //"Cancelamento de movimento bancario a pagar"
aAdd(aItens,	{"000007","08",STR0080,"SE5",1}) //"Cancelamento de movimento bancario a receber"
aAdd(aItens,	{"000007","09",STR0082,"CV4",1}) //"Cancelamento de rateio de movimento bancario a pagar"
aAdd(aItens,	{"000007","10",STR0084,"CV4",1}) //"Cancelamento de rateio de movimento bancario a receber"
aAdd(aItens,	{"000007","11",STR0475,"SE5",1}) //"Despesas de movimentacao bancaria"

aAdd(aBlq,	{"000007","03",STR0077,"''","SE5"}) //"Movimento bancario a pagar"
aAdd(aBlq,	{"000007","05",STR0081,"xFilial('CV4')+DTOS(dDataBase)+cSeqCv4+StrZero(n, Len(CV4->CV4_ITSEQ))","CV4"}) //"Movimento bancario a pagar rateado"

aAdd(aProcess,	{"000008",STR0085+"/"+STR0323,"FINA171"}) //"APLICACOES FINANCEIRAS"###"EMPRESTIMOS"
aAdd(aItens,	{"000008","01",STR0164,"SEH",1})  //"Atualização de aplicação financeira"
aAdd(aBlq,	{"000008","01",STR0086,"xFilial('SEH')+M->EH_NUMERO","SEH"}) //"Inclusao de aplicacao financeira"

aAdd(aProcess,{"000009",STR0087+"/"+STR0323,"FINA181"}) //"RESGATE DE APLICACOES"###"EMPRESTIMOS"
//aplicacoes
aAdd(aItens,	{"000009","01",STR0088		,"SEH",1}) //"Restage de aplicacao financeira"
aAdd(aItens,	{"000009","02",STR0324		,"SEI",1}) //"Baixa Valor do Principal (inclusao)"
aAdd(aItens,	{"000009","03",STR0325		,"SEI",1}) //"Valor dos Juros (inclusao)"
aAdd(aItens,	{"000009","04",STR0326		,"SEI",1}) //"Baixa do Valor do Resgate (inclusao)"
aAdd(aItens,	{"000009","05",STR0327		,"SEI",1}) //"Valor do IRF (inclusao)"
aAdd(aItens,	{"000009","06",STR0328		,"SEI",1}) //"Valor do IOF (inclusao)"
aAdd(aItens,	{"000009","07",STR0329		,"SEI",1}) //"Valor do SWAP (inclusao)"
aAdd(aItens,	{"000009","08",STR0330		,"SEI",1}) //"Valor do IRF s/ SWAP (inclusao)"
aAdd(aItens,	{"000009","09",STR0331		,"SEI",1}) //"Valor de despesas (inclusao)"
aAdd(aItens,	{"000009","10",STR0332		,"SEI",1}) //"Valor do Credito (inclusao)"
aAdd(aItens,	{"000009","11",STR0333		,"SEI",1}) //"Apropriacao do IRF (inclusao)"
aAdd(aItens,	{"000009","12",STR0334		,"SEI",1}) //"Apropriacao do IOF (inclusao)"
aAdd(aItens,	{"000009","13",STR0335		,"SEI",1}) //"Apropriacao do IRF s/ SWAP(inclusao)"
aAdd(aItens,	{"000009","14",STR0336		,"SEI",1}) //"Apropriacao de despesas (inclusao)"
aAdd(aItens,	{"000009","15",STR0337		,"SEI",1}) //"Apropriacao dos Juros (inclusao)"
aAdd(aItens,	{"000009","16",STR0338		,"SEI",1}) //"Baixa Valor do Principal (estorno)"
aAdd(aItens,	{"000009","17",STR0339		,"SEI",1}) //"Valor dos Juros (estorno)"
aAdd(aItens,	{"000009","18",STR0340		,"SEI",1}) //"Baixa do Valor do Resgate (estorno)"
aAdd(aItens,	{"000009","19",STR0341		,"SEI",1}) //"Valor do IRF (estorno)"
aAdd(aItens,	{"000009","20",STR0342		,"SEI",1}) //"Valor do IOF (estorno)"
aAdd(aItens,	{"000009","21",STR0343		,"SEI",1}) //"Valor do SWAP (estorno)"
aAdd(aItens,	{"000009","22",STR0344		,"SEI",1}) //"Valor do IRF s/ SWAP (estorno)"
aAdd(aItens,	{"000009","23",STR0345		,"SEI",1}) //"Valor de despesas (estorno)"
aAdd(aItens,	{"000009","24",STR0346		,"SEI",1}) //"Valor do Credito (estorno)"
aAdd(aItens,	{"000009","25",STR0347		,"SEI",1})  //"Apropriacao do IRF (estorno)"
aAdd(aItens,	{"000009","26",STR0348		,"SEI",1}) //"Apropriacao do IOF (estorno)"
aAdd(aItens,	{"000009","27",STR0349		,"SEI",1}) //"Apropriacao do IRF s/ SWAP(estorno)"
aAdd(aItens,	{"000009","28",STR0350		,"SEI",1}) //"Apropriacao de despesas (estorno)"
aAdd(aItens,	{"000009","29",STR0351		,"SEI",1}) //"Apropriacao dos Juros (estorno)"
//emprestimos
aAdd(aItens,	{"000009","30",STR0352		,"SEH",1}) //"Resgate de Emprestimos  (alteracao)"
aAdd(aItens,	{"000009","31",STR0353		,"SEI",1}) //"Valor  dos Juros (inclusao)"
aAdd(aItens,	{"000009","32",STR0354		,"SEI",1}) //"Variacao Cambial a Longo Prazo (inclusao)"
aAdd(aItens,	{"000009","33",STR0355		,"SEI",1}) //"Variacao Cambial a Curto Prazo (inclusao)"
aAdd(aItens,	{"000009","34",STR0356		,"SEI",1}) //"Variacao Cambial dos Juros (inclusao)"
aAdd(aItens,	{"000009","35",STR0357		,"SEI",1}) //"Baixa do Longo Prazo (inclusao)"
aAdd(aItens,	{"000009","36",STR0358		,"SEI",1}) //"Baixa do Curto Prazo (inclusao)"
aAdd(aItens,	{"000009","37",STR0359		,"SEI",1}) //"Baixa do Juro (inclusao)"
aAdd(aItens,	{"000009","38",STR0360		,"SEI",1}) //"Pagto do Valor do IRF (inclusao)"
aAdd(aItens,	{"000009","39",STR0361		,"SEI",1}) //"Pagto das Despesas (inclusao)"
aAdd(aItens,	{"000009","40",STR0362		,"SEI",1}) //"Pagto do GAP (inclusao)"
aAdd(aItens,	{"000009","41",STR0363		,"SEI",1}) //"Valor do Debito (inclusao)"
aAdd(aItens,	{"000009","42",STR0364		,"SEI",1}) //"Apropriacao dos Juros (inclusao)"
aAdd(aItens,	{"000009","43",STR0365		,"SEI",1}) //"Apropriacao Var.Cambial a Longo Prazo (inclusao)"
aAdd(aItens,	{"000009","44",STR0366		,"SEI",1}) //"Apropriacao Var.Cambial a Curto Prazo (inclusao)"
aAdd(aItens,	{"000009","45",STR0367		,"SEI",1}) //"Apropriacao Var.Cambial dos Juros (inclusao)"
aAdd(aItens,	{"000009","46",STR0368		,"SEI",1}) //"Valor  dos Juros (estorno)"
aAdd(aItens,	{"000009","47",STR0369		,"SEI",1}) //"Variacao Cambial a Longo Prazo (estorno)"
aAdd(aItens,	{"000009","48",STR0370		,"SEI",1}) //"Variacao Cambial a Curto Prazo (estorno)"
aAdd(aItens,	{"000009","49",STR0371		,"SEI",1}) //"Variacao Cambial dos Juros (estorno)"
aAdd(aItens,	{"000009","50",STR0372		,"SEI",1}) //"Baixa do Longo Prazo (estorno)"
aAdd(aItens,	{"000009","51",STR0373		,"SEI",1}) //"Baixa do Curto Prazo (estorno)"
aAdd(aItens,	{"000009","52",STR0374		,"SEI",1}) //"Baixa do Juro (estorno)"
aAdd(aItens,	{"000009","53",STR0375		,"SEI",1}) //"Pagto do Valor do IRF (estorno)"
aAdd(aItens,	{"000009","54",STR0376		,"SEI",1})  //"Pagto das Despesas (estorno)"
aAdd(aItens,	{"000009","55",STR0377		,"SEI",1}) //"Pagto do GAP (estorno)"
aAdd(aItens,	{"000009","56",STR0378 		,"SEI",1}) //"Valor do Debito (estorno)"
aAdd(aItens,	{"000009","57",STR0379		,"SEI",1}) //"Apropriacao dos Juros (estorno)"
aAdd(aItens,	{"000009","58",STR0380		,"SEI",1}) //"Apropriacao Var.Cambial a Longo Prazo (estorno)"
aAdd(aItens,	{"000009","59",STR0381		,"SEI",1}) //"Apropriacao Var.Cambial a Curto Prazo (estorno)"
aAdd(aItens,	{"000009","60",STR0382		,"SEI",1}) //"Apropriacao Var.Cambial dos Juros (estorno)"

aAdd(aProcess,{"000010",STR0402,"FINA182"})  //"APROPRIACAO DE APLICACOES/EMPRESTIMO"
//EMPRESTIMO
aAdd(aItens,	{"000010","01",STR0089,"SEH",1}) //"Apropriacao de emprestimo"
aAdd(aItens,	{"000010","02",STR0387+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao do IRF"##(inclusao)
aAdd(aItens,	{"000010","03",STR0388+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao do IOF"##(inclusao)
aAdd(aItens,	{"000010","04",STR0389+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao de taxas"##(inclusao)
aAdd(aItens,	{"000010","05",STR0390+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao dos Juros "##(inclusao)
aAdd(aItens,	{"000010","06",STR0391+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial a Longo Prazo"##(inclusao)
aAdd(aItens,	{"000010","07",STR0392+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial a Curto Prazo"##(inclusao)
aAdd(aItens,	{"000010","08",STR0393+" ("+STR0303+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial dos Juros"##(inclusao)
aAdd(aItens,	{"000010","09",STR0387+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao do IRF"##(estorno)
aAdd(aItens,	{"000010","10",STR0388+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao do IOF"
aAdd(aItens,	{"000010","11",STR0389+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao de taxas"
aAdd(aItens,	{"000010","12",STR0390+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao dos Juros "
aAdd(aItens,	{"000010","13",STR0391+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial a Longo Prazo"
aAdd(aItens,	{"000010","14",STR0392+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial a Curto Prazo"
aAdd(aItens,	{"000010","15",STR0393+" ("+STR0403+")","SEI",1}) //"Emprest.-Apropriacao Var.Cambial dos Juros"
//APLICACAO
aAdd(aItens,	{"000010","16",STR0394,"SEH",1}) //"Apropriacao de aplicacao"
aAdd(aItens,	{"000010","17",STR0395+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao do IRF"##(inclusao)
aAdd(aItens,	{"000010","18",STR0396+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao do IOF"##(inclusao)
aAdd(aItens,	{"000010","19",STR0397+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao de Taxas"##(inclusao)
aAdd(aItens,	{"000010","20",STR0398+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao dos Juros "##(inclusao)
aAdd(aItens,	{"000010","21",STR0399+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial a Longo Prazo"	##(inclusao)
aAdd(aItens,	{"000010","22",STR0400+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial a Curto Prazo"##(inclusao)
aAdd(aItens,	{"000010","23",STR0401+" ("+STR0303+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial dos Juros"##(inclusao)
aAdd(aItens,	{"000010","24",STR0395+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao do IRF"##(estorno)
aAdd(aItens,	{"000010","25",STR0396+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao do IOF"##(estorno)
aAdd(aItens,	{"000010","26",STR0397+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao de Taxas"##(estorno)
aAdd(aItens,	{"000010","27",STR0398+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao dos Juros "##(estorno)
aAdd(aItens,	{"000010","28",STR0399+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial a Longo Prazo"	##(estorno)
aAdd(aItens,	{"000010","29",STR0400+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial a Curto Prazo"##(estorno)
aAdd(aItens,	{"000010","30",STR0401+" ("+STR0403+")","SEI",1}) //"Aplic.-Apropriacao Var.Cambial dos Juros"##(estorno)


aAdd(aProcess,{"000011",STR0090,"FINA183"}) //"APROPRIACAO DE APLICACAO POR COTAS"
aAdd(aItens,	{"000011","01",STR0091		,"SEH",1}) //"Apropriacao de aplicacao por cotas"
aAdd(aItens,	{"000011","02",STR0383		,"SEI",1}) //"Valor do IR (inclusao)"
aAdd(aItens,	{"000011","03",STR0384		,"SEI",1}) //"Valor do Rendimento na Retencao IR (inclusao) "
aAdd(aItens,	{"000011","04",STR0385		,"SEI",1}) //"Valor do IR (estorno)"
aAdd(aItens,	{"000011","05",STR0386		,"SEI",1}) //"Valor do Rendimento na Retencao IR (estorno)"

aAdd(aProcess,{"000012",STR0312,"FINA110"}) //"BAIXAS A RECEBER AUTOMATICA"
aAdd(aItens,	{"000012","01",STR0313,"SE5",2}) //"Baixas por bordero de recebimento"

aAdd(aProcess,{"000014",STR0092,"FINA280"}) //"FATURAS A RECEBER"
aAdd(aItens,	{"000014","01",STR0093,"SE1",1}) //"Geracao de faturas a receber"
aAdd(aItens,	{"000014","02",STR0094,"SE1",1}) //"Baixa Titulo a Receber ref. Fatura"

aAdd(aProcess,{"000015",STR0095,"FINA290"}) //"FATURAS A PAGAR"
aAdd(aItens,	{"000015","01",STR0096,"SE2",1}) //"Geracao de faturas a pagar"
aAdd(aItens,	{"000015","02",STR0097,"SE2",1}) //"Baixa Titulo a Pagar ref. Fatura"

aAdd(aProcess,{"000016",STR0098,"FINA330"}) //"COMPENSACAO CR"
aAdd(aItens,	{"000016","01",STR0404,"SE1",1})  //"Titulo Principal"
aAdd(aItens,	{"000016","02",STR0405,"SE1",1})  //"Titulo Compensado"
aAdd(aItens,	{"000016","03",STR0406,"SE5",2})  //"Baixa Titulo Principal"
aAdd(aItens,	{"000016","04",STR0407,"SE5",2})  //"Baixa Titulo Compensado"
aAdd(aItens,	{"000016","05",STR0408,"SE5",2})  //"Canc.Baixa Titulo Principal"
aAdd(aItens,	{"000016","06",STR0409,"SE5",2})  //"Canc.Baixa Titulo Compensado"

aAdd(aProcess,{"000017",STR0099,"FINA340"}) //"COMPENSACAO CP"
aAdd(aItens,	{"000017","01",STR0404,"SE2",6})  //"Titulo Principal"
aAdd(aItens,	{"000017","02",STR0405,"SE2",6})  //"Titulo Compensado"
aAdd(aItens,	{"000017","03",STR0406,"SE5",2})  //"Baixa Titulo Principal"
aAdd(aItens,	{"000017","04",STR0407,"SE5",2})  //"Baixa Titulo Compensado"
aAdd(aItens,	{"000017","05",STR0408,"SE5",2})  //"Canc.Baixa Titulo Principal"
aAdd(aItens,	{"000017","06",STR0409,"SE5",2})  //"Canc.Baixa Titulo Compensado"

aAdd(aProcess,{"000018",STR0100,"FINA450"}) //"COMPENSACAO ENTRE CARTEIRAS"
aAdd(aItens,	{"000018","01",STR0570,"SE2",1}) //"Compensacao de carteiras - PAGAR"
aAdd(aItens,	{"000018","02",STR0571,"SE1",1}) //"Compensacao de carteiras - RECEBER"

aAdd(aProcess,{"000019",STR0103,"FINA350"}) //"VARIACAO MONETARIA"
aAdd(aItens,	{"000019","01",STR0104,"SE2",1}) //"Compensacao monetaria de contas a pagar"
aAdd(aItens,	{"000019","02",STR0105,"SE1",1}) //"Compensacao monetaria de contas a receber"

aAdd(aProcess,{"000020",STR0106,"FINA430"}) //"RETORNO DE COMUNICACAO BANCARIA A PAGAR"
aAdd(aItens,	{"000020","01",STR0106,"SE2",1}) //"Retorno de comunicacao bancaria a pagar"

If CV4->(FieldPos("CV4_ITSEQ")) > 0
	aAdd(aProcess,{"000021",STR0037+"-"+Upper(STR0260),"FINA050"}) //"CONTAS A PAGAR - RATEIO"//"Rateio"
	aAdd(aItens,	{"000021","01",STR0038+"-"+STR0260,"CV4",1}) //"Inclusao de titulos a pagar"//"Rateio"

	aAdd(aBlq,	{"000021","01",STR0038+"-"+STR0260,"xFilial('CV4')+DTOS(dDataBase)+cSeqCv4+StrZero(n, Len(CV4->CV4_ITSEQ))","CV4"}) //"Inclusao de titulos a pagar"//"Rateio"
EndIf

aAdd(aProcess,{"000022",STR0314,"FINA300"})  //"RETORNO DE COMUNICACAO BANCARIA (SISPAG)"
aAdd(aItens,	{"000022","01",STR0315,"SE5",2})  //"Baixas/comunicacao bancaria(SISPAG)"
aAdd(aItens,	{"000022","02",STR0315,"SE2",1})  //"Baixas/comunicacao bancaria(SISPAG)"

aAdd(aProcess,{"000023",STR0316,"FINA241"})  //"BORDERO DE PAGAMENTOS"
aAdd(aItens,	{"000023","01",STR0317,"SE2",1})  //"Bordero de Pagamentos-Titulo Original"
aAdd(aItens,	{"000023","02",STR0318,"SE5",2})  //"Bordero de Pagamentos-Baixa Ref.Impostos"
aAdd(aItens,	{"000023","03",STR0319,"SE2",1})  //"Bordero de Pagamentos-Inclusao Ref. PIS"
aAdd(aItens,	{"000023","04",STR0320,"SE2",1})  //"Bordero de Pagamentos-Inclusao Ref. COFINS"
aAdd(aItens,	{"000023","05",STR0321,"SE2",1})  //"Bordero de Pagamentos-Inclusao Ref. CSLL"
aAdd(aItens,	{"000023","06",STR0322,"SE2",1})   //"Bordero de Pagamentos-Inclusao Ref. IRRF"

aAdd(aProcess,{"000024", STR0569, "FINA091"}) //"Baixas a Pagar Automática Multi-Filiais"
aAdd(aItens,	{"000024", "01", STR0073, "SE5", 2}) //"Baixas por bordero de pagamento"

aAdd(aProcess,{"000050",STR0107,"MATA125"})  //OK //"CONTRATO DE PARCERIA"
aAdd(aItens,	{"000050","01",STR0108,"SC3",1}) //"Inclusao de contrato"
aAdd(aBlq,	{"000050","01",STR0108,"xFilial('SC3')+cA125Num+GDFieldGet('C3_ITEM')",'SC3', "1", "1"})

aAdd(aProcess,{"000051",STR0109,"MATA110"}) //OK //"SOLICITACAO DE COMPRAS"
aAdd(aItens,	{"000051","01",STR0110,"SC1",1}) //"Inclusao de solicitacao de compras"
aAdd(aItens,	{"000051","02",STR0111,"SC1",1}) //"Aprovacao de solicitacao de compras"
aAdd(aItens,	{"000051","03",STR0553,"SCX",1}) //"Rateio por CC na cotacao"
aAdd(aItens,	{"000051","04",STR0579,"SC1",1}) //"Inclusao de solicitacao de compras por ponto de pedido"

aAdd(aBlq,	{"000051","01",STR0110,"xFilial('SC1')+cA110Num+GDFieldGet('C1_ITEM')",'SC1', "1", "1"})
aAdd(aBlq,	{"000051","02",STR0111,"xFilial('SC1')+SC1->C1_NUM + SC1->C1_ITEM",'SC1', "1", "1"})
aAdd(aBlq,	{"000051","03",STR0553,"xFilial('SCX')+SC8->(C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO)+SCX->CX_ITEM","SCX", "1", "1"}) //"Rateio por CC na cotação"

aAdd(aProcess,{"000052",STR0112,"MATA121"}) //OK //"PEDIDO DE COMPRAS"
aAdd(aItens,	{"000052","01",STR0113,"SC7",1}) //"Inclusao de pedido de compras - ITENS"
aAdd(aItens,	{"000052","02",STR0292,"SC8",1}) //"Inclusao de pedido de compras por cotacao"
aAdd(aItens,	{"000052","03",STR0115,"SC7",3}) //"Inclusao de pedido de compras - TOTAL"
aAdd(aItens,	{"000052","05",STR0165,"SC1",1})  //"Baixa da Solicitação de Compras - ITENS"
aAdd(aItens,	{"000052","06",STR0166,"SC1",1})  //"Estorno da baixa da Solicitação de Compras- ITENS"
aAdd(aItens,	{"000052","07",STR0492,"SC7",1})  //"Pedido de Compras por Edital"

aAdd(aItens,	{"000052","08",STR0513,"SCH",1})  //"Pedido de Compras - Rateio por CC"

aAdd(aBlq,	{"000052","01",STR0113,STR0117,"SC7", "1", "1"}) //"Inclusao de pedido de compras - ITENS"###"xFilial('SC7')+cA120Num+GDFieldGet('C7_ITEM')"
aAdd(aBlq,	{"000052","02",STR0292,"SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO)","SC8", "1", "1"}) //"Inclusao de pedido de compras por cotacao"
aAdd(aBlq,	{"000052","03",STR0115,STR0118,"SC7", "1", "1"}) //"Inclusao de pedido de compras - TOTAL"###"xFilial('SC7')+cA120Forn+cA120Loj+cA120Num"
aAdd(aBlq,	{"000052","07",STR0492,"xFilial('SC7')+cA120Num+GDFieldGet('C7_ITEM')","SC7", "1", "1"}) //"Pedido de Compras por Edital"

aAdd(aBlq,	{"000052","08",STR0513,"xFilial('SCH')+cA120Num+cA120Forn+cA120Loj+GdFieldGet('C7_ITEM',nOrigN,NIL,aOrigHeader,aOrigAcols)+GdFieldGet('CH_ITEM',_nLinhaR)","SCH", "1", "1"}) //"Pedido de Compras - Rateio por CC"


aAdd(aProcess,{"000053",STR0119,"MATA122"}) //OK //"AUTORIZACAO DE ENTREGA"

aAdd(aItens,	{"000053","01",STR0120,"SC7",1}) //"Inclusao de autorizacao de entrega - ITENS"
aAdd(aItens,	{"000053","02",STR0293,"SC8",1}) //"Inclusao de autorizacao de entrega por cotacao "
aAdd(aItens,	{"000053","03",STR0122,"SC7",3}) //"Inclusao de autorizacao de entrega - TOTAL"
aAdd(aItens,	{"000053","04",STR0514,"SCH",1})  //"Autorizacao de Entrega - Rateio por CC"

aAdd(aBlq,	{"000053","01",STR0120,STR0117,"SC7"}) //"Inclusao de autorizacao de entrega - ITENS"###"xFilial('SC7')+cA120Num+GDFieldGet('C7_ITEM')"
aAdd(aBlq,	{"000053","03",STR0122,STR0118,"SC7"}) //"Inclusao de autorizacao de entrega - TOTAL"###"xFilial('SC7')+cA120Forn+cA120Loj+cA120Num"
aAdd(aBlq,	{"000053","04",STR0514,"xFilial('SCH')+cA120Num+cA120Forn+cA120Loj+GdFieldGet('C7_ITEM',nOrigN,NIL,aOrigHeader,aOrigAcols)+GdFieldGet('CH_ITEM',_nLinhaR)","SCH", "1", "1"}) //"Autorizacao de Entrega - Rateio por CC"


aAdd(aProcess,{"000054",STR0124,"MATA103"})  //OK //"DOCUMENTO DE ENTRADA"
aAdd(aItens,	{"000054","01",STR0125,"SD1",1}) //"Inclusao de Documento de Entrada - ITENS"
aAdd(aItens,	{"000054","03",STR0127,"SF1",1}) //"Inclusao de Documento de Entrada - TOTAL"
aAdd(aItens,	{"000054","05",STR0129,"SD1",1}) //"Inclusao de devolucao de vendas - ITENS"
aAdd(aItens,	{"000054","07",STR0131,"SD1",1}) //"Inclusao de beneficiamento - ITENS"
aAdd(aItens,	{"000054","09",STR0133,"SDE",1}) //"Inclusao de Documento de Entrada - Rateio por CC"
aAdd(aItens,	{"000054","10",STR0134,"SDE",1}) //"Inclusao de devolucao de vendas - Rateio por CC"
aAdd(aItens,	{"000054","11",STR0135,"SDE",1}) //"Inclusao de beneficiamento  - Rateio por CC"
aAdd(aItens,	{"000054","15",STR0167,"SC7",1})  //"Baixa do Pedido de Compras - ITENS"
aAdd(aItens,	{"000054","16",STR0168,"SC7",1}) //"Estorno da Baixa do Pedido de Compras - ITENS"
aAdd(aItens,	{"000054","17",STR0169,"SC7",3})  //"Baixa do Pedido de Compras - TOTAL"
aAdd(aItens,	{"000054","18",STR0196,"SC7",3}) //"Estorno da Baixa do Pedido de Compras - TOTAL"
aAdd(aItens,	{"000054","19",STR0275,"SF1",1}) //'Inclusao de devolucao de vendas - TOTAL'
aAdd(aItens,	{"000054","20",STR0276,"SF1",1}) //'Inclusao de beneficiamento - TOTAL'

aAdd(aBlq,	{"000054","01",STR0125,"xFilial('SD1')+cNFiscal+cSerie+cA100For+cLoja+GdFieldGet('D1_COD')+GdFieldGet('D1_ITEM')","SD1", "1", "1"}) //"Inclusao de Documento de Entrada - ITENS"
aAdd(aBlq,	{"000054","03",STR0127,"xFilial('SF1')+cNFiscal+cSerie+cA100For+cLoja+cTipo","SF1", "1", "1"}) //"Inclusao de Documento de Entrada - TOTAL"
aAdd(aBlq,	{"000054","05",STR0129,"xFilial('SD1')+cNFiscal+cSerie+cA100For+cLoja+GdFieldGet('D1_COD')+GdFieldGet('D1_ITEM')"  ,"SD1", "1", "1"}) //"Inclusao de devolucao de vendas - ITENS"
aAdd(aBlq,	{"000054","07",STR0131,"xFilial('SD1')+cNFiscal+cSerie+cA100For+cLoja+GdFieldGet('D1_COD')+GdFieldGet('D1_ITEM')"  ,"SD1", "1", "1"}) //"Inclusao de beneficiemnto - ITENS"
aAdd(aBlq,	{"000054","09",STR0133,"xFilial('SDE')+cNFiscal+cSerie+cA100For+cLoja+cItNfEntr+GdFieldGet('DE_ITEM')","SDE", "1", "1"}) //"Inclusao de Documento de Entrada - Rateio por CC"
aAdd(aBlq,	{"000054","10",STR0134,"xFilial('SDE')+cNFiscal+cSerie+cA100For+cLoja+cItNfEntr+GdFieldGet('DE_ITEM')","SDE", "1", "1"}) //"Inclusao de devolucao de vendas - Rateio por CC"
aAdd(aBlq,	{"000054","11",STR0135,"xFilial('SDE')+cNFiscal+cSerie+cA100For+cLoja+cItNfEntr+GdFieldGet('DE_ITEM')","SDE", "1", "1"}) //"Inclusao de beneficiamento  - Rateio por CC"
aAdd(aBlq,	{"000054","19",STR0275,"xFilial('SF1')+cNFiscal+cSerie+cA100For+cLoja+cTipo","SF1", "1", "1"}) //'Inclusao de devolucao de vendas - TOTAL'
aAdd(aBlq,	{"000054","20",STR0276,"xFilial('SF1')+cNFiscal+cSerie+cA100For+cLoja+cTipo","SF1", "1", "1"}) //'Inclusao de beneficiamento - TOTAL'

aAdd(aProcess,{"000055",STR0139,"MATA097"}) //OK //"LIBERACAO DE PEDIDO DE COMPRAS"
aAdd(aItens,	{"000055","01",STR0435,"SC7",1}) //"ITENS"
aAdd(aItens,	{"000055","02",STR0436,"SC7",3}) //"TOTAL"

aAdd(aBlq,	{"000055","01",STR0435,"xFilial('SC7')+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM","SC7"}) //"Itens"###"xFilial('SC7')+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM"
aAdd(aBlq,	{"000055","02",STR0436,STR0140,"SC7"}) //"Total"###"xFilial('SC7')+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM"

aAdd(aProcess	,{"000056",STR0306,"MATA235"}) //'Eliminacao de residuos'
aAdd(aItens		,{"000056","01",STR0109,"SC1",1})  //'Solicitacao de compras'
aAdd(aItens		,{"000056","02",STR0112,"SC7",1}) //'Pedido de compras'
aAdd(aItens		,{"000056","03",STR0119,"SC7",1})  //'Autorizacao de entrega'
aAdd(aItens		,{"000056","04",STR0572,"SCH",1})  //"Pedido de Compras - Rateio por CC"

aAdd(aProcess	,{"000057",STR0453,"MATA185"}) //"Encerramento de Pré-Requisição"
aAdd(aItens		,{"000057","01",STR0453,"SCQ",1})  //"Encerramento de Pré-Requisição"

aAdd(aProcess,	{"000080",STR0170,"RSPA100"}) //OK //"LIBERACAO DE PEDIDO DE COMPRAS" //"Cadastro de vagas para contratacao"
aAdd(aItens,	{"000080","01",STR0171,"SQS",1})  //"Inclusao de vaga"

aAdd(aBlq,	{"000080","01",STR0172,"xFilial('SQS')+M->QS_VAGA","SQS"})  //"Inclusao de vagas"

aAdd(aProcess,	{"000082",STR0266,"CTBA105"})//"Contabilizacao"
aAdd(aItens,	{"000082","01",STR0267,"CT2",1})//"Itens - Contabilizacao"
aAdd(aItens,	{"000082","02",STR0433,"CT2",1})//"Efetivação de Pré-Lançamento"

aAdd(aProcess,	{"000083",STR0267,"CSAA090"})  //"Quadro de Funcionarios"
aAdd(aItens,	{"000083","01",STR0269,"RBD",1}) //"Quadro de Funcionarios - Inclusao por Funcao"
aAdd(aItens,	{"000083","02",STR0270,"RB8",1}) //"Quadro de Funcionarios - Inclusao por CC"

aAdd(aBlq,	{"000083","01",STR0269,"xFilial('RBD')+SI3->I3_CUSTO+cAnoMes+GDFieldGet('RBD_FUNCAO')","RBD"})  //"Quadro de Funcionarios - Inclusao por Funcao"
aAdd(aBlq,	{"000083","02",STR0270,"xFilial('RB8')+SI3->I3_CUSTO+cAnoMes","RB8"}) //"Quadro de Funcionarios - Inclusao por CC"

aAdd(aProcess,	{"000084",STR0271,"GPEA010"})  //"Cadastro de Funcionarios"
aAdd(aItens,	{"000084","01",STR0272,"SRA",1})  //"Cadastro de Funcionarios - Inclusao Folha (GPE)"
aAdd(aItens,	{"000084","02",STR0273,"SRA",1})  //"Cadastro de Funcionarios - Inclusao por Admissao (RSP)"
aAdd(aItens,	{"000084","03",STR0297,"SRA",1})  //"Alteracao (GPE)"
aAdd(aItens,	{"000084","04",STR0298,"SR3",1})  //"Alteracao Salarial (GPE)"

aAdd(aBlq,	{"000084","01",STR0272,"xFilial('SRA')+M->RA_MAT","SRA"})  //"Cadastro de Funcionarios - Inclusao Folha (GPE)"
aAdd(aBlq,	{"000084","02",STR0273,"xFilial('SRA')+M->RA_MAT","SRA"})  //"Cadastro de Funcionarios - Inclusao por Admissao (RSP)"
aAdd(aBlq,	{"000084","03",STR0297,"xFilial('SRA')+M->RA_MAT","SRA"})  //"Alteracao (GPE)"
aAdd(aBlq,	{"000084","04",STR0298,"xFilial('SRA')+M->RA_MAT+Dtos(M->RA_DATAALT)+M->RA_TIPOALT+'000'","SR3"})  //"Alteracao Salarial (GPE)"


aAdd(aProcess,	{"000085",STR0277,"GPEM120"})	//"Fechamento mensal da folha"
aAdd(aItens,	{"000085","01",STR0278,"SRD",1,.F.})  //"Verba ???"

aAdd(aProcess,	{"000086",STR0299,"GPEA180"}) // 'Transferencia de funcionarios'
aAdd(aItens,	{"000086","01",STR0300		,"SRA",2})  //'Saida'
aAdd(aItens,	{"000086","02",STR0301	,"SRA",2}) // 'Entrada'

aAdd(aBlq,	{"000086","01",STR0300,"xFilial('SRA')+SRA->RA_CC+SRA->RA_MAT","SRA"}) //"Saida "
aAdd(aBlq,	{"000086","02",STR0301,"xFilial('SRA')+SRA->RA_CC+SRA->RA_MAT","SRA"})// 'Entrada'

aAdd(aProcess,	{"000087",STR0302,"GPER200"})  //'Reajuste Salarial'
aAdd(aItens,	{"000087","01",STR0303		,"SR3",1})  //'Inclusao'

aAdd(aProcess,	{"000088",STR0304,"GPCR001"})   //'Dissidio retroativo'
aAdd(aItens,	{"000088","01",STR0305	,"SR3",1})  //'Inclusao de alteracao salarial'

aAdd(aProcess,	{"000089",STR0410,"GPEM030"})   //"Calculo de Ferias"
aAdd(aItens,	{"000089","01",STR0411,"SRR",1})  //"Inclusao de calculo de ferias"

aAdd(aProcess,	{"000090",STR0412,"GPEM040"})   //"Calculo de Rescisao"
aAdd(aItens,	{"000090","01",STR0413,"SRR",1})  //"Inclusao de calculo de rescisao"

aAdd(aProcess,	{"000091",STR0419,"GPEA070"})    //"Provisao de Ferias/13.Salario"
aAdd(aItens,	{"000091","01",STR0420,"SRT",1})  //"Inclusao de Provisao de Ferias/13.Salario"

aAdd(aProcess,	{"000092",STR0423,"GPEM660"})  //"Movimentacao de Titulos (RC1)"
aAdd(aItens,	{"000092","01",STR0424,"RC1",1})  //"Inclusao de Movimentacao de Titulos (RC1)"

aAdd(aProcess,{"000100",STR0141,"MATA410"})//OK //"PEDIDO DE VENDAS"
aAdd(aItens,	{"000100","01",STR0142,"SC6",1}) //"Inclusao de pedido de vendas - ITENS"
aAdd(aItens,	{"000100","02",STR0143,"SC6",1}) //"Exclusao de pedido de vendas - ITENS"
aAdd(aItens,	{"000100","03",STR0144,"SC5",1}) //"Inclusao de pedido de vendas - TOTAL"
aAdd(aItens,	{"000100","04",STR0145,"SC5",1}) //"Exclusao de pedido de vendas - TOTAL"

aAdd(aProcess,{"000101",STR0146,"MATA461"}) //OK //"NOTA FISCAL DE SAIDA"
aAdd(aItens,	{"000101","01",STR0147,"SD2",1}) //"Inclusao de Documento de Saida - ITENS"
aAdd(aItens,	{"000101","02",STR0148,"SF2",1}) //"Inclusao de Documento de Saida - TOTAL"
aAdd(aItens,	{"000101","03",STR0563,"AGH",1}) //"Inclusao de Rateios de Documento de Saida - ITENS"

aAdd(aProcess,{"000103",STR0434,"MATA440"}) //OK //"LIBERACAO DE PEDIDO DE VENDAS"
aAdd(aItens,	{"000103","01",STR0435,"SC6",1}) //"ITENS"
aAdd(aItens,	{"000103","02",STR0436,"SC5",1}) //"TOTAL"

aAdd(aProcess,{"000104",STR0468,"MATA530"}) //OK //"PAGAMENTO DA COMISSAO DE VENDEDORES"
aAdd(aItens,	{"000104","01",STR0469,"SE3",3}) //"PAGAMENTO DE COMISSAO"

aAdd(aProcess,{"000150",STR0274,"MATA105"})  //OK //"Solicitacao ao armazem"
aAdd(aItens,	{"000150","01",STR0274,"SCP",1}) //"Solicitacao ao armazem"

aAdd(aBlq	,	{"000150","01",STR0274,'xFilial("SCP")+ca105Num+GDFieldGet("CP_ITEM")+dTOS(dA105Data)',"SCP"}) //"Solicitacao ao armazem"

aAdd(aProcess,{"000151",STR0152,"MATA240"})  //OK //"MOVIMENTOS INTERNOS"
aAdd(aItens, 	{"000151","01",STR0153,"SD3",3}) //"Entrada no estoque - movimentos internos"
aAdd(aItens, 	{"000151","02",STR0154,"SD3",3}) //"Saida do estoque - movimentos internos"

aAdd(aBlq, 		{"000151","01",STR0153,'xFilial("SD3")+If(l240,M->D3_DOC+M->D3_TM+M->D3_COD+"01",cDocumento+cTM+GDFieldGet("D3_COD")+StrZero(n,2))',"SD3"}) //"Entrada no estoque - movimentos internos"
aAdd(aBlq, 		{"000151","02",STR0154,'xFilial("SD3")+If(l240,M->D3_DOC+M->D3_TM+M->D3_COD+"01",cDocumento+cTM+GDFieldGet("D3_COD")+StrZero(n,2))',"SD3"}) //"Saida do estoque - movimentos internos"

aAdd(aProcess,{"000152",STR0155,"MATA250"}) //OK //"PRODUCAO"
aAdd(aItens,	{"000152","01",STR0156,"SD3",3}) //"Entrada no estoque - producao"
aAdd(aItens,	{"000152","02",STR0157,"SD3",3}) //"Saida do estoque - producao"

aAdd(aProcess,{"000153",STR0158,"MATA340"}) //OK //"ACERTO DO INVENTARIO"
aAdd(aItens,	{"000153","01",STR0159,"SD3",3}) //"Entrada - Acerto de inventario "
aAdd(aItens,	{"000153","02",STR0160,"SD3",3}) //"Saida - Acerto de inventario"

aAdd(aProcess,{"000154",STR0307,"ATFA010"})  //"INCLUSAO ATIVO FIXO"
aAdd(aItens,	{"000154","01",STR0308,"SN1",1})   //"Cadastro de Ativo Imobilizado"
aAdd(aItens,	{"000154","02",STR0309,"SN3",1})   //"Saldos e Valores do Ativo"
aAdd(aItens,	{"000154","03",STR0310,"SN4",1})   //"Movimentacoes do Ativo Fixo"

aAdd(aBlq,	{"000154","01",STR0308	,"xFilial('SN1')+M->N1_CBASE+M->N1_ITEM","SN1", "1", "1"})  //"Cadastro de Ativo Imobilizado"
aAdd(aBlq,	{"000154","02",STR0309	,"xFilial('SN3')+M->N1_CBASE+M->N1_ITEM+GDFieldGet('N3_TIPO')+StrZero(n, 10)","SN3", "1", "1"})  //"Saldos e Valores do Ativo"

aAdd(aProcess,{"000155",STR0311,"FATA050"})  //"Metas de Vendas - Faturamento"
aAdd(aItens,	{"000155","01",STR0311,"SCT",1}) //"Metas de Vendas - Faturamento"

aAdd(aProcess,{"000250",STR0161,"MATA953"}) //"APURACAO DE ICMS"
//aAdd(aItens,	{"000250","01",STR0161+"-"+STR0163,"SE2",1}) //"Apuracao de ICMS "##"Normal"
//aAdd(aItens,	{"000250","02",STR0161+"-"+STR0164,"SE2",1}) //"Apuracao de ICMS "##"Substituicao tributaria proprio estado"
//aAdd(aItens,	{"000250","03",STR0161+"-"+STR0165,"SE2",1}) //"Apuracao de ICMS "##"Substituicao tributaria outros estados"
//aAdd(aItens,	{"000250","04",STR0161+"-"+STR0166,"SE2",1}) //"Apuracao de ICMS "##"Incentivo Fiscal"

aAdd(aProcess,{"000251",STR0162,"MATA955"}) //"APURACAO DE IPI"
aAdd(aItens,	{"000251","01",STR0162,"SE2",1}) //"Apuracao de IPI"

aAdd(aProcess,{"000252",STR0163,"PCOA100"}) //"PLANILHA ORCAMENTARIA"
aAdd(aItens,	{"000252","01",STR0173,"AK2",1})  //"Itens - Atualização da Planilha "
aAdd(aItens,	{"000252","02",STR0174,"AK2",1})  //"Itens - Revisão da Planilha "
aAdd(aItens,	{"000252","03",STR0175,"AK2",1})  //"Itens - Simulação da Planilha"
aAdd(aItens,	{"000252","04",STR0263,"AK2",1})  //"Itens - Finalizacao Revisão da Planilha"

aAdd(aProcess,{"000255",STR0294,"PCOA330"})  //"Importacao CTB"
aAdd(aItens,	{"000255","01",STR0295,"CQ3",1})   //"Saldo Contas Contabeis por CC"
aAdd(aItens,	{"000255","02",STR0296,"CQ1",1})  //"Saldo Contas Contabeis"
aAdd(aItens,	{"000255","03",STR0421,"CQ5",1})   //"Saldo Contas Contabeis por It.Contabil"
aAdd(aItens,	{"000255","04",STR0422,"CQ7",1})   //"Saldo Contas Contabeis por Cl.Valor"

aAdd(aItens,	{"000255","05",STR0512,"CVY",1})   //"Saldo Contas Contabeis por Outras entidades"

aAdd(aProcess,{"000300", STR0176,"MATA467N"}) //"NOTA DE SAIDA MANUAL E DE BENDEFICIAMENTO A CLIENTE"
aAdd(aItens,	{"000300","01",STR0177, "SD2", 1})  //"Inclusao de Nota de Saida Manual - ITENS"
aAdd(aItens,	{"000300","03",STR0179,"SF2",1}) //"Inclusao de Nota de Saida Manual - TOTAL"
aAdd(aItens,	{"000300","05",STR0181, "SD2", 1})  //"Inclusao de Nota de Benefic. a Cliente - ITENS"
aAdd(aItens,	{"000300","07",STR0183,"SF2",1}) //"Inclusao de Nota de Benefic. a Cliente - TOTAL"

aAdd(aProcess,{"000301", STR0185,"MATA462N"}) //"REMITO DE SAIDA MANUAL E DE BENDEFICIAMENTO A CLIENTE"
aAdd(aItens,	{"000301","01",STR0186,"SD2",1})  //"Inclusao de Remito de Saida Manual - ITENS"
aAdd(aItens,	{"000301","02",STR0187,"SD2",1}) //"Exclusao de Remito de Saida Manual - ITENS"
aAdd(aItens,	{"000301","03",STR0188,"SF2",1}) //"Inclusao de Remito de Saida Manual - TOTAL"
aAdd(aItens,	{"000301","04",STR0189,"SF2",1}) //"Exclusao de Remito de Saida Manual - TOTAL"
aAdd(aItens,	{"000301","05",STR0190,"SD2",1})  //"Inclusao de Remito de Benefic. a Cliente - ITENS"
aAdd(aItens,	{"000301","06",STR0191,"SD2",1}) //"Exclusao de Remito de Benefic. a Cliente - ITENS"
aAdd(aItens,	{"000301","07",STR0192,"SF2",1}) //"Inclusao de Remito de Benefic. a Cliente - TOTAL"
aAdd(aItens,	{"000301","08",STR0193,"SF2",1}) //"Exclusao de Remito de Benefic. a Cliente - TOTAL"

aAdd(aProcess,{"000302", STR0194,"MATA462DN"}) //"REMITO DE DEVOLUCAO (FATURAMENTO)"
aAdd(aItens,	{"000302","01",STR0195,"SD1",1})  //"Inclusao de Remito de devolucao (Faturamento) - ITENS"
aAdd(aItens,	{"000302","02",STR0196,"SD1",1}) //"Exclusao de Remito de devolucao (Faturamento) - ITENS"
aAdd(aItens,	{"000302","03",STR0197,"SF1",1}) //"Inclusao de Remito de devolucao (Faturamento) - TOTAL"
aAdd(aItens,	{"000302","04",STR0198,"SF1",1}) //"Exclusao de Remito de devolucao (Faturamento) - TOTAL"

aAdd(aProcess,{"000303", STR0261,"MATA462R"})//"REMITO DE RETORNO SIMBOLICO (FATURAMENTO)"
aAdd(aItens,	{"000303","01",STR0199,"SD1",1})  //"Inclusao de Remito de Retorno Simbolico (Faturamento) - ITENS"
aAdd(aItens,	{"000303","02",STR0200,"SD1",1}) //"Exclusao de Remito de Retorno Simbolico (Faturamento) - ITENS"
aAdd(aItens,	{"000303","03",STR0201,"SF1",1}) //"Inclusao de Remito de Retorno Simbolico (Faturamento) - TOTAL"
aAdd(aItens,	{"000303","04",STR0202,"SF1",1}) //"Exclusao de Remito de Retorno Simbolico (Faturamento) - TOTAL"

aAdd(aProcess,{"000304", STR0203,"MATA462TN"}) //"REMITO DE TRANSFERENCIA"
aAdd(aItens,	{"000304","01",STR0204,"SD1",1})  //"Inclusao de Remito de Transferencia (Entrada) - ITENS"
aAdd(aItens,	{"000304","02",STR0205,"SD1",1}) //"Exclusao de Remito de Transferencia (Entrada) - ITENS"
aAdd(aItens,	{"000304","03",STR0206,"SF1",1}) //"Inclusao de Remito de Transferencia (Entrada) - TOTAL"
aAdd(aItens,	{"000304","04",STR0207,"SF1",1}) //"Exclusao de Remito de Transferencia (Entrada) - TOTAL"
aAdd(aItens,	{"000304","05",STR0208,"SD2",1})  //"Inclusao de Remito de Transferencia (Saida) - ITENS"
aAdd(aItens,	{"000304","06",STR0209,"SD2",1}) //"Exclusao de Remito de Transferencia (Saida) - ITENS"
aAdd(aItens,	{"000304","07",STR0210,"SF2",1}) //"Inclusao de Remito de Transferencia (Saida) - TOTAL"
aAdd(aItens,	{"000304","08",STR0211,"SF2",1}) //"Exclusao de Remito de Transferencia (Saida) - TOTAL"

aAdd(aProcess,{"000305", STR0212,"MATA102DN"}) //"REMITO DE DEVOLUCAO (COMPRAS)"
aAdd(aItens,	{"000305","01",STR0213,"SD2",1})  //"Inclusao de Remito de Devolucao (Compras) - ITENS"
aAdd(aItens,	{"000305","02",STR0214,"SD2",1}) //"Exclusao de Remito de Devolucao (Compras) - ITENS"
aAdd(aItens,	{"000305","03",STR0215,"SF2",1}) //"Inclusao de Remito de Devolucao (Compras) - TOTAL"
aAdd(aItens,	{"000305","04",STR0216,"SF2",1}) //"Exclusao de Remito de Devolucao (Compras) - TOTAL"

aAdd(aProcess,{"000306", STR0262,"MATA101N"})//"NOTA DE ENTRADA MANUAL"
aAdd(aItens,	{"000306","01",STR0217,"SD1",1})  //"Inclusao de Nota Entrada Normal (Compras) - ITENS"
aAdd(aItens,	{"000306","03",STR0218,"SF1",1}) //"Inclusao de Nota Entrada Normal (Compras) - TOTAL"
aAdd(aItens,	{"000306","05",STR0219,"SD1",1})  //"Inclusao de Nota Entrada Beneficiamento (Compras) - ITENS"
aAdd(aItens,	{"000306","06",STR0220,"SD1",1}) //"Exclusao de Nota Entrada Beneficiamento (Compras) - ITENS"
aAdd(aItens,	{"000306","07",STR0221,"SF1",1}) //"Inclusao de Nota Entrada Beneficiamento (Compras) - TOTAL"
aAdd(aItens,	{"000306","08",STR0222,"SF1",1}) //"Exclusao de Nota Entrada Beneficiamento (Compras) - TOTAL"
aAdd(aItens,	{"000306","09",STR0223,"SD1",1})  //"Inclusao de Nota Entrada Desp.Importacao (Compras) - ITENS"
aAdd(aItens,	{"000306","10",STR0224,"SD1",1}) //"Exclusao de Nota Entrada Desp.Importacao (Compras) - ITENS"
aAdd(aItens,	{"000306","11",STR0225,"SF1",1}) //"Inclusao de Nota Entrada Desp.Importacao (Compras) - TOTAL"
aAdd(aItens,	{"000306","12",STR0226,"SF1",1}) //"Exclusao de Nota Entrada Desp.Importacao (Compras) - TOTAL"
aAdd(aItens,	{"000306","13",STR0227,"SD1",1})  //"Inclusao de Nota Entrada Conhecimento Frete (Compras) - ITENS"
aAdd(aItens,	{"000306","14",STR0228,"SD1",1}) //"Exclusao de Nota Entrada Conhecimento Frete (Compras) - ITENS"
aAdd(aItens,	{"000306","15",STR0229,"SF1",1}) //"Inclusao de Nota Entrada Conhecimento Frete (Compras) - TOTAL"
aAdd(aItens,	{"000306","16",STR0260,"SF1",1}) //"Exclusao de Nota Entrada Conhecimento Frete (Compras) - TOTAL"

If cPaisLoc $ "MEX|COL|PER"
	aAdd(aBlq,	{"000306", "01", STR0125, "xFilial('SD1')+cNFiscal+cSerie+cA100For+cLoja+GdFieldGet('D1_COD')+GdFieldGet('D1_ITEM')", "SD1", "1", "1"}) //"Inclusao de Documento de Entrada - ITENS"
EndIf

aAdd(aProcess,{"000307", STR0230,"MATA102N"}) //"REMITO DE ENTRADA MANUAL E DE BENEFICIAMENTO A CLIENTE"
aAdd(aItens,	{"000307","01",STR0231,"SD1",1})  //"Inclusao de Remito de Entrada Manual - ITENS"
aAdd(aItens,	{"000307","02",STR0232,"SD1",1}) //"Exclusao de Remito de Entrada Manual - ITENS"
aAdd(aItens,	{"000307","03",STR0233,"SF1",1}) //"Inclusao de Remito de Entrada Manual - TOTAL"
aAdd(aItens,	{"000307","04",STR0234,"SF1",1}) //"Exclusao de Remito de Entrada Manual - TOTAL"
aAdd(aItens,	{"000307","05",STR0190,"SD1",1})  //"Inclusao de Remito de Benefic. a Cliente - ITENS"
aAdd(aItens,	{"000307","06",STR0191,"SD1",1}) //"Exclusao de Remito de Benefic. a Cliente - ITENS"
aAdd(aItens,	{"000307","07",STR0192,"SF1",1}) //"Inclusao de Remito de Benefic. a Cliente - TOTAL"
aAdd(aItens,	{"000307","08",STR0193,"SF1",1}) //"Exclusao de Remito de Benefic. a Cliente - TOTAL"

If cPaisLoc $ "MEX|COL|PER|EQU"
	aAdd(aBlq,	{"000307", "01", STR0125, "xFilial('SD1')+cNFiscal+cSerie+cA100For+cLoja+GdFieldGet('D1_COD')+GdFieldGet('D1_ITEM')", "SD1", "1", "1"}) //"Inclusao de Documento de Entrada - ITENS"
EndIf

aAdd(aProcess,{"000308", STR0235,"MATA465N"}) //"NOTA DE DEBITO A CLIENTE"
aAdd(aItens,	{"000308","01",STR0236,"SD2",1})  //"Inclusao de Nota de Debito a Cliente - ITENS"
aAdd(aItens,	{"000308","03",STR0238,"SF2",1}) //"Inclusao de Nota de Debito a Cliente - TOTAL"

aAdd(aProcess,{"000309", STR0240,"MATA465N"}) //"NOTA DE CREDITO A CLIENTE"
aAdd(aItens,	{"000309","01",STR0241,"SD1",1})  //"Inclusao de Nota de Credito a Cliente - ITENS"
aAdd(aItens,	{"000309","03",STR0243,"SF1",1}) //"Inclusao de Nota de Credito a Cliente - TOTAL"

aAdd(aProcess,{"000310", STR0245,"MATA466N"}) //"NOTA DE DEBITO A FORNECEDOR"
aAdd(aItens,	{"000310","01",STR0246,"SD1",1})  //"Inclusao de Nota de Debito a Fornecedor - ITENS"
aAdd(aItens,	{"000310","03",STR0248,"SF1",1}) //"Inclusao de Nota de Debito a Fornecedor - TOTAL"

aAdd(aProcess,{"000311", STR0250,"MATA466N"}) //"NOTA DE CREDITO A FORNECEDOR"
aAdd(aItens,	{"000311","01",STR0251,"SD1",1})  //"Inclusao de Nota Propria - ITENS"
aAdd(aItens,	{"000311","02",STR0252,"SF1",1}) //"Inclusao de Nota Propria - TOTAL"
aAdd(aItens,	{"000311","03",STR0470,"SD2",1})  //"Inclusao de Nota emitida pelo Fornecedor - ITENS"
aAdd(aItens,	{"000311","04",STR0471,"SF2",1}) //"Inclusao de Nota emitida pelo Fornecedor - TOTAL"


aAdd(aProcess,{"000312", STR0253,"MATA466N"}) //"RECIBO DE SERVICOS (COMPRAS)"
aAdd(aItens,	{"000312","01",STR0254,"SD1",1})  //"Inclusao de Recibo de Servicos (Compras) - ITENS"
aAdd(aItens,	{"000312","02",STR0255,"SD1",1}) //"Exclusao de Recibo de Servicos (Compras) - ITENS"
aAdd(aItens,	{"000312","03",STR0256,"SF1",1}) //"Inclusao de Recibo de Servicos (Compras) - TOTAL"
aAdd(aItens,	{"000312","04",STR0257,"SF1",1}) //"Exclusao de Recibo de Servicos (Compras) - TOTAL"

aAdd(aProcess,{"000313", STR0447,"FINA085A"}) //"ORDENS DE PAGAMENTO"
aAdd(aItens,	{"000313","01",STR0448,"SEK",1}) //"Ordens de Pagamento - Baixa de Titulo"
aAdd(aItens,	{"000313","02",STR0449,"SEK",1}) //"Ordens de Pagamento - Pagamento Antecipado"
aAdd(aItens,	{"000313","03",STR0450,"SEK",1}) //"Ordens de Pagamento - Cheque de Terceiros"
aAdd(aItens,	{"000313","04",STR0451,"SEK",1}) //"Ordens de Pagamento - Cheque Proprio"
aAdd(aItens,	{"000313","05",STR0452,"SEK",1}) //"Ordens de Pagamento - Geracao de Retencao"

aAdd(aProcess,{"000314", "RECALCULO DO CUSTO MEDIO","MATA330"}) //"RECALCULO DO CUSTO MEDIO"
aAdd(aItens,	{"000314","01","CUSTO DE ENTRADAS","SD1",1}) //cPadrao = 641/682/681
aAdd(aItens,	{"000314","02","CUSTO DE MOVIMENTOS INTERNOS","SD3",1}) //cPadrao = 666/670/672/668/679/680
aAdd(aItens,	{"000314","03","CUSTO DE SAIDAS","SD2",1}) //cPadrao = 678/
// Lançamento do CTB 667 e 669 nao estao sendo tratados

aAdd(aProcess,{"000340", STR0518,"FINA761"}) //"Documento Hábil"
aAdd(aItens,	{"000340","01",STR0516,"FV0",1}) //"Inclusão do Documento Hábil"
aAdd(aItens,	{"000340","02",STR0517,"FV0",1}) //"Realização do Documento Hábil"

aAdd(aProcess,{"000350", STR0258,"PMSA110"})  //"Geracao de projeto"
aAdd(aItens,	{"000350","01",STR0259,"AF9",1}) //"Geracao de tarefas"
aAdd(aItens,	{"000350","02","Historico da revisão de Tarefas","AF9",1}) //"Historico da revisão de Tarefas","AF9"

aAdd(aProcess,{"000351", STR0414	,"PMSA200"})  //"Mudanca de fase do projeto"
aAdd(aItens,	{"000351","01",STR0415	,"AFC",1}) //"EDT Principal"
aAdd(aItens,	{"000351","02",STR0416	,"AF9",1}) //"Tarefas      "
aAdd(aItens,	{"000351","03",STR0417	,"AFA",1}) //"Produtos e recursos"
aAdd(aItens,	{"000351","04",STR0418	,"AFB",1}) //"Despesas"

aAdd(aBlq,	{"000351","01",STR0415,"AFC->(AFC_FILIAL+AFC_PROJET+AFC_REVISA+AFC_EDT+AFC_ORDEM)","AFC"}) //"EDT Principal"
aAdd(aBlq,	{"000351","02",STR0416,"AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA+AF9_ORDEM)","AF9"}) //"Tarefas"
aAdd(aBlq,	{"000351","03",STR0417,"AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA+AFA_ITEM+AFA_PRODUT+AFA_RECURS)","AFA"}) //"Produtos e recursos"
aAdd(aBlq,	{"000351","04",STR0418,"AFB->(AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA+AFB_ITEM)","AFB"}) //"Despesas"

aAdd(aProcess,{"000354",STR0425,"CNTA300"})//"PLANILHA DE CONTRATO"
aAdd(aItens,{"000354","01",STR0426,"CNA",1})//"Inclusão de Planilha - Total"
aAdd(aItens,{"000354","02",STR0427,"CNB",1})//"Inclusão de Planilha - Itens"
aAdd(aItens,{"000354","03",STR0537,"CNA",1})//"Aprovação Revisão de Planilha - Total"
aAdd(aItens,{"000354","04",STR0538,"CNB",1})//"Aprovação Revisão de Planilha - Itens"
aAdd(aItens,{"000354","05",STR0539,"CNA",1})//"Aprovação Revisão de Planilha - Total"
aAdd(aItens,{"000354","06",STR0540,"CNB",1})//"Aprovação Revisão de Planilha - Itens"
aAdd(aItens,{"000354","07",STR0541,"CNA",1})//"Aprovação Revisão de Planilha - Total"
aAdd(aItens,{"000354","08",STR0542,"CNB",3})//"Aprovação Revisão de Planilha - Itens"
aAdd(aItens,{"000354","09",STR0580,"CNZ",1})//Rateio dos Itens da Planilha - Inclusão
aAdd(aItens,{"000354","10",STR0581,"CNZ",1})//Rateio dos Itens da Planilha - Revisão

If FindFunction("CtrChvPco")	
	aAdd(aBlq,{"000354","01",STR0426,"CtrChvPco('000354', '01')","CNA", "1", "1"})//"Inclusão de Planilha - Total"
	aAdd(aBlq,{"000354","02",STR0427,"CtrChvPco('000354', '02')","CNB", "1", "1"})//"Inclusão de Planilha - Items"
	aAdd(aBlq,{"000354","03",STR0543,"CtrChvPco('000354', '03')","CNA", "1", "1"})//"Revisão de Planilha - Total"
	aAdd(aBlq,{"000354","04",STR0544,"CtrChvPco('000354', '04')","CNB", "1", "1"})//"Revisão de Planilha - Items"
	
	aAdd(aBlq,{"000354","09",STR0580,"CtrChvPco('000354', '09')","CNZ", "1", "1"})//Rateio dos Itens da Planilha - Inclusão
	aAdd(aBlq,{"000354","10",STR0581,"CtrChvPco('000354', '10')","CNZ", "1", "1"})//Rateio dos Itens da Planilha - Revisão
Else
	aAdd(aBlq,{"000354","01",STR0426,"xFilial('CNA')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')","CNA", "1", "1"})//"Inclusão de Planilha - Total"
	aAdd(aBlq,{"000354","02",STR0427,"xFilial('CNB')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')+FWFLDGET('CNB_ITEM')","CNB", "1", "1"})//"Inclusão de Planilha - Items"
	aAdd(aBlq,{"000354","03",STR0543,"xFilial('CNA')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')","CNA", "1", "1"})////"Revisão de Planilha - Total"
	aAdd(aBlq,{"000354","04",STR0544,"xFilial('CNB')+FWFLDGET('CN9_NUMERO')+FWFLDGET('CN9_REVISA')+FWFLDGET('CNA_NUMERO')+FWFLDGET('CNB_ITEM')","CNB", "1", "1"})//"Revisão de Planilha - Items"
EndIf

aAdd(aProcess,{"000355",STR0428,"CNTA120"})//"MEDIÇÃO DE CONTATO"
aAdd(aItens,	{"000355","01",STR0429,"CND",1})													//"Medição de Contrato - Total"
aAdd(aItens,	{"000355","02",STR0430,"CNE",1})													//"Medição de Contrato - Items"
aAdd(aItens,	{"000355","03",STR0493,"CND",1})//"Encerramento da Medição"
aAdd(aItens,	{"000355","04",STR0494,"CNE",1})//"Encer. Medição: Itens Contrato"

aAdd(aItens,	{"000355","05",STR0495,"CNZ",2})//"Encer. Medição: Rateio Itens Contrato s/ Planilha"
aAdd(aItens,	{"000355","06",STR0496,"CNZ",2})//"Encer. Medição: Rateio Itens Contrato c/ Planilha"

aAdd( aBlq , {"000355","01",STR0429,"CN121Chave('000355','01')" , "CND" , "1" , "1" } )	//-- "Medição de Contrato - Total"
aAdd( aBlq , {"000355","02",STR0430,"CN121Chave('000355','02')" , "CNE" , "1" , "1" } )	//-- "Medição de Contrato - Items"

aAdd( aBlq , {"000355","03",STR0493,"CN121Chave('000355','03')" , "CND" , "1" , "1" } )	//-- "Encerramento da medição"
aAdd( aBlq , {"000355","04",STR0494,"CN121Chave('000355','04')" , "CNE" , "1" , "1" } )	//-- "Encer. Medição: Itens Contrato"

aAdd( aBlq , {"000355","05",STR0430,"CN121Chave('000355','05')" , "CNZ" , "1" , "1" } )	//-- "Encer. Medição: Rateio Itens Contrato s/ Planilha"
aAdd( aBlq , {"000355","06",STR0430,"CN121Chave('000355','06')" , "CNZ" , "1" , "1" } )	//-- "Encer. Medição: Rateio Itens Contrato c/ Planilha"

aAdd(aProcess,{"000356",STR0431,"PCOA530"}) //"Liberacao de Solicitacao de Contingencia"
aAdd(aItens,{"000356","01",STR0432 + STR0431,"ALJ",1}) //"Lancamento de Contingencia"
aAdd(aItens,{"000356","02",STR0545 + STR0431,"ALJ",1}) //"Empenho de Contingencia"

aAdd(aProcess,{"000357",STR0437,"CNTA300"})//"Cronograma do Contrato"
aAdd(aItens,{"000357","01",STR0438,"CNF",2})//"Cronograma Financeiro"
//ordem 2: CNS_FILIAL+CNS_CONTRA+CNS_REVISA+CNS_CRONOG+CNS_PARCEL+CNS_PLANI+CNS_ITEM
aAdd(aItens,{"000357","02",STR0497,"CNS",1}) //"Cronograma Fisico - Proporcionalidade do item de contrato"
aAdd(aItens,{"000357","03",STR0546,"CNF",2}) //"Cronograma Financeiro - Aprovação Revisao"
aAdd(aItens,{"000357","04",STR0547,"CNF",1}) //"Paralisação do Contrato - Cronograma Financeiro"
aAdd(aItens,{"000357","05",STR0548,"CNF",3} )//"Finalização/Cancelamento do Contrato do Contrato - Cronograma Financeiro"

aAdd(aBlq,{"000357","01",STR0438,"xFilial('CNF')+FWFLDGET('CNF_CONTRA')+FWFLDGET('CNF_REVISA')+FWFLDGET('CNF_NUMERO')+FWFLDGET('CNF_COMPET')","CNF", "1", "1"})//Cronograma Financeiro
aAdd(aBlq,{"000357","03",STR0549,"xFilial('CNF')+FWFLDGET('CNF_CONTRA')+FWFLDGET('CNF_REVISA')+FWFLDGET('CNF_NUMERO')+FWFLDGET('CNF_COMPET')","CNF", "1", "1"})//"Cronograma Financeiro - Aprovação Revisao"

aAdd(aProcess,{"000358",STR0439,"PCOXPNJ"})//"Planejamento orcamentario"
aAdd(aItens,{"000358","01",STR0515,"ALY",1})//"Movimentos de planejamento"


aAdd(aProcess,{"000359",STR0440,"FINA550"})  //"Caixinha"
aAdd(aItens,{"000359","01",STR0441,"SET",1})  //"Inclusao Caixinha"
aAdd(aItens,{"000359","02",STR0442,"SEU",1}) //"Inclusao Movimento Caixinha"
aAdd(aItens,{"000359","03",STR0467,"SEU",1}) //"Reposição Caixinha"

aAdd(aBlq,{"000359","01",STR0441,"xFilial('SET')+M->ET_CODIGO","SET", "1", "2", "3"})//"Inclusao Caixinha"
aAdd(aBlq,{"000359","02",STR0442,"xFilial('SEU')+M->EU_NUM","SEU", "1", "2", "3"})  //"Inclusao Movimento Caixinha"
aAdd(aBlq,{"000359","03",STR0467,"xFilial('SEU')+M->EU_NUM","SEU", "1", "2", "3"})  //"Reposição Caixinha"

If cPaisLoc $ "ARG|CHI|PAR|URU|BOL"
	aAdd(aProcess,{"000360",STR0459,"FINA089"}) //"Baixas de Cheques e Transferencias"
	aAdd(aItens,	{"000360","01",STR0454,"SE5",1}) //"Baixa dos títulos recebidos do Banco"
	aAdd(aItens,	{"000360","02",STR0455,"SE5",1}) //"Rejeitar cheque"
	aAdd(aItens,	{"000360","03",STR0456,"SE5",1}) //"Cancelar rejeição de cheque"
	aAdd(aItens,	{"000360","04",STR0457,"SE5",1}) //"Cancelar entrada de cheque"
	aAdd(aItens,	{"000360","05",STR0458,"SE5",1}) //"Credenciar cheques automaticamente"
EndIf

If cPaisLoc == "ARG"
	aAdd(aProcess, {"000361",STR0460,"FINA087A"}) //'Recibos de Cobranza'
	aAdd(aItens,	{"000361","01" ,STR0461,"SEL",1}) // Recibos de Cobranza - Cheque
	aAdd(aItens,	{"000361","02" ,STR0462,"SEL",1}) // Recibos de Cobranza - Recebimento Antecipado
	aAdd(aItens,	{"000361","03" ,STR0463,"SEL",1}) // Recibos de Cobranza - Geracao de Retencao
	aAdd(aItens,	{"000361","04" ,STR0464,"SEL",1}) // Recibos de Cobranza - En Efectivo
	aAdd(aItens,	{"000361","05" ,STR0465,"SEL",1}) // Recibos de Cobranza - Deposito
	aAdd(aItens,	{"000361","06" ,STR0466,"SEL",1}) // Recibos de Cobranza - Transferencia Bancaria (TB)
	aAdd(aItens,	{"000361","07" ,STR0504,"SEL",1}) // Recibos de Cobranza - Estorno de Cheque
	aAdd(aItens,	{"000361","08" ,STR0505,"SEL",1}) // Recibos de Cobranza - Estorno de Recebimento Antecipado
	aAdd(aItens,	{"000361","09" ,STR0506,"SEL",1}) // Recibos de Cobranza - Estorno de Geracao de Retencao
	aAdd(aItens,	{"000361","10" ,STR0507,"SEL",1}) // Recibos de Cobranza - Estorno de En Efectivo
	aAdd(aItens,	{"000361","11" ,STR0508,"SEL",1}) // Recibos de Cobranza - Estorno de Deposito
EndIf

aAdd(aProcess,{"000362",STR0472,"MATA468N"}) //"Geração de Notas (Faturamento)"
aAdd(aItens,	{"000362","01",STR0473,"SD2",1}) //"Geração de Notas (Faturamento) - ITENS"
aAdd(aItens,	{"000362","02",STR0474,"SF2",1}) //"Geração de Notas (Faturamento) - TOTAL"

aAdd(aProcess,{"000374",STR0484,"ATFA350"}) 	 //"Simulação de Depreciação"
aAdd(aItens,	{"000374","01",STR0485,"SNS",1}) //"Movimentos de Simulação: Bens"
aAdd(aItens,	{"000374","02",STR0486,"SNS",1}) //"Movimentos de Simulação: Modificadores de Aquisição"
aAdd(aItens,	{"000374","03",STR0487,"SNS",1}) //"Movimentos de Simulação: Modificadores de Baixa"

//23/07/2010
//Depreciação de Ativo
aAdd(aProcess,	{"000363",STR0476,"ATFA050"}) 		// "Cálculo da Depreciação"
aAdd(aItens,	{"000363","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000364",STR0477,"ATFA070"}) 		// "Descalculo de Depreciação"
aAdd(aItens,	{"000364","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000365",STR0478,"ATFA171"}) 		// "Depreciação Acelerada"
aAdd(aItens,	{"000365","01",STR0503,"SN4",4}) 	//"Conta do Bem"

//Transferencia de Ativos
aAdd(aProcess,	{"000366",STR0480,"ATFA250"}) 		// "Aquisição de Transferencia"
aAdd(aItens,	{"000366","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000368",STR0479,"ATFA060"}) 		// "Transferencia de Ativos"
aAdd(aItens,	{"000368","01",STR0500,"SN3",4}) 	//"Transferencia Contábil"
aAdd(aItens,	{"000368","02",STR0501,"SN3",4}) 	//"Transferencia Filial - Origem"
aAdd(aItens,	{"000368","03",STR0502,"SN3",4}) 	//"Transferencia Filial - Destino"

//Ampliação
aAdd(aProcess,	{"000369",STR0481,"ATFA150"}) 		// "Ampliação"
aAdd(aItens,	{"000369","01",STR0503,"SN4",4}) 	//"Conta do Bem"

//Baixa
aAdd(aProcess,	{"000370",STR0490,"ATFA036"}) 		// "Baixa com Cálculo de Depreciação"
aAdd(aItens,	{"000370","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000371",STR0482,"ATFA036"}) 		// "Baixa sem Calculo de depreciação"
aAdd(aItens,	{"000371","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000372",STR0483,"ATFA040"}) 		// "Baixa de Adiantamento com Calculo de depreciação"
aAdd(aItens,	{"000372","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,	{"000373",STR0491,"ATFA045"}) 		// ""Baixa de Adiantamento sem Calculo de depreciação"
aAdd(aItens,	{"000373","01",STR0503,"SN4",4}) 	//"Conta do Bem"

aAdd(aProcess,{"000375",STR0488,"PCOA009"}) 	 //"Importação de arquivos"
aAdd(aItens,	{"000375","01",STR0489,"AMJ",1}) //"Importação de arquivos XML"
aAdd(aProcess,	{"000376",STR0498,"MATA120"})//"Rateio PC"

aAdd(aItens,	{"000376","01",STR0499,"SCH",1})//"Rateio Pedido de Compra"
aAdd(aBlq,		{"000376","01",STR0499,"xFilial('SCH')+cA120Num+cA120Forn+cA120Loj+GdFieldGet('C7_ITEM',nOrigN,NIL,aOrigHeader,aOrigAcols)+GdFieldGet('CH_ITEM',_nLinhaR)","SCH"})//"Rateio Pedido de Compra"

If RA2->(FieldPos("RA2_CC")) > 0

	aAdd(aProcess,	{"000377",STR0509,"TRMA050"})//"Registro de Treinamento"
	aAdd(aItens,	{"000377","01",STR0510,"RA2",1,,,"1"}) //"Inclusão de Treinamento"

	aAdd(aBlq,		{"000377","01",STR0510,"xFilial('RA2')+cCod+GdFieldGet('RA2_CURSO')+GdFieldGet('RA2_TURMA')+GdFieldGet('RA2_CC')","RA2", "1", "2"})//"Inclusão de Treinamento"
	aAdd(aBlq,		{"000377","02",STR0511,"xFilial('RA8')+cCod+GdFieldGet('RA8_SEQ')","RA8", "1", "2"})//"Inclusão de Planejamento Treinamento"

Endif


//-- NOta de empenho
aAdd(aProcess,{"000400",STR0550,"GCPA400"}) //'Nota de Empenho'
aAdd(aItens,	{"000400","01",STR0551,"CX1",1}) //"Inclusão NE"
aAdd(aItens,	{"000400","02",STR0552,"CX1",1}) //"Exclusão NE"

//Integração com Reserve
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array contendo os processos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aProcess,	{"000401",STR0554,"PCOXRES"}) //"Pedido de Viagem"
aAdd(aItens,	{"000401","01",STR0555,"FO6",1}) //"Antes do autorizador ser notificado"
aAdd(aItens,	{"000401","02",STR0556,"FO6",1}) //"Após o autorizador ser notificado"
aAdd(aItens,	{"000401","03",STR0557,"FO6",1}) //"Antes da autorização do pedido."
aAdd(aItens,	{"000401","04",STR0558,"FO6",1}) //"Após a autorização do pedido."
aAdd(aItens,	{"000401","05",STR0562,"FO6",1}) //"Antes da emissão do pedido."
aAdd(aItens,	{"000401","06",STR0560,"FO6",1}) //"Após a emissão do pedido."
aAdd(aItens,	{"000401","07",STR0561,"FO6",1}) //"Após o cancelamento do pedido."

aAdd(aBlq,	{"000401","01",STR0555,"xFilial('FO6')+M->FO6_IDRESE","FO6"}) //"Antes do autorizador ser notificado"
aAdd(aBlq,	{"000401","03",STR0557,"xFilial('FO6')+M->FO6_IDRESE","FO6"}) //"Antes da autorização do pedido."
aAdd(aBlq,	{"000401","05",STR0562,"xFilial('FO6')+M->FO6_IDRESE","FO6"}) //"Antes da emissão do pedido."

/* RESERVA DE CODIGOS DE LANCAMENTOS A SER UTILIZADO EM RELEASE FUTURO ESTA NA PASTA INOVACAO 12.1.15
aAdd(aProcess, {"000405",STR0564,"LOJXFUNC"}) //"NOTA FISCAL DE SAÍDA (LOJA)"
aAdd(aItens,   {"000405","01",STR0565,"SD2",3}) //"Inclusao de Documento de Saida (Loja) - ITENS"
aAdd(aItens,   {"000405","02",STR0566,"SF2",1}) //"Inclusao de Documento de Saida (Loja) - TOTAL"

aAdd(aBlq,     {"000405","01",STR0567,"xFilial('SF2')+M->F2_DOC+M->F2_SERIE+M->F2_CLIENTE+M->F2_LOJA","SF2"}) //"Inclusao de Documento de Saida (Loja)"
 */
For nx := 1 to Len(aProcess)
	dbSelectArea("AK8")
	dbSetOrder(1)
	If !dbSeek(xFilial()+aProcess[nx][1])
		RecLock("AK8",.T.)
		AK8->AK8_VISUAL	:= "2"
	Else
		RecLock("AK8",.F.)
	EndIf
	AK8->AK8_FILIAL	:= xFilial("AK8")
	AK8->AK8_CODIGO := aProcess[nx][1]
	AK8->AK8_DESCRI	:= aProcess[nx][2]
	AK8->AK8_FUNCAO := aProcess[nx][3]
	MsUnlock()
	aAdd(aRecAK8,AK8->(RecNo()))
Next nx

For nx := 1 to Len(aItens)
	dbSelectArea("AK8")
	dbSetOrder(1)
	MsSeek(xFilial()+aItens[nx,1])

	dbSelectArea("AKB")
	dbSetOrder(1)
	If !dbSeek(xFilial()+aItens[nx,1]+aItens[nx,2])
		RecLock("AKB",.T.)
		AKB->AKB_CFGON			:= "2"
	Else
		If Len(aItens[nX]) < 6 .Or. aItens[nX,6]
			RecLock("AKB",.F.)
		Else
			aAdd(aRecAKB,AKB->(RecNo()))
			Loop
		Endif
	EndIf
	AKB->AKB_FILIAL		:= xFilial("AKB")
	AKB->AKB_PROCES		:= aItens[nx,1]
	AKB->AKB_ITEM			:= aItens[nx,2]
	AKB->AKB_DESCRI		:= AllTrim(AK8->AK8_DESCRI)+" - "+aItens[nx,3]
	AKB->AKB_ENTIDA		:= aItens[nx,4]
	AKB->AKB_INDICE		:= aItens[nx,5]
	If (AKB->(FieldPos("AKB_ESTORN")) # 0 ) .And. Len(aItens[nx])== 8
		AKB->AKB_ESTORN := aItens[nx,8]
	EndIf
	MsUnlock()
	aAdd(aRecAKB,AKB->(RecNo()))
Next nx


For nx := 1 to Len(aBlq)
	dbSelectArea("AK8")
	dbSetOrder(1)
	MsSeek(xFilial()+aBlq[nx,1])

	dbSelectArea("AKA")
	dbSetOrder(1)
	If !dbSeek(xFilial()+aBlq[nx,1]+aBlq[nx,2])
		RecLock("AKA",.T.)
		AKA->AKA_CFGON			:= "2"
	Else
		RecLock("AKA",.F.)
	EndIf
	AKA->AKA_FILIAL		:= xFilial("AKA")
	AKA->AKA_PROCES	:= aBlq[nx][1]
	AKA->AKA_ITEM		:= aBlq[nx][2]
	AKA->AKA_DESCRI		:= AllTrim(AK8->AK8_DESCRI)+" - "+aBlq[nx][3]
	AKA->AKA_CHAVE		:= aBlq[nx][4]
	AKA->AKA_ENTIDA	:= aBlq[nx][5]
	If Len(aBlq[nx]) > 5
		If 	(AKA->(FieldPos("AKA_GRADE")) > 0 ) .And. ;
			(AKA->(FieldPos("AKA_VLDBLQ")) > 0 )
			AKA->AKA_GRADE	:= aBlq[nx][6]
			If Empty(AKA->AKA_VLDBLQ)
				AKA->AKA_VLDBLQ	:= aBlq[nx][7]
			EndIf
        EndIf
	EndIf
	MsUnlock()
	aAdd(aRecAKA,AKA->(RecNo()))
Next nx

If !File("CHKLCT.PCO") .And. !(cPaisLoc $ "MEX|COL|PER|EQU")
	dbSelectArea("AK8")
	dbSetOrder(1)
	dbSeek(xFilial())
	While !Eof() .And. xFilial() == AK8->AK8_FILIAL
		If AK8->AK8_CODIGO <= "900000" .And. aScan(aRecAK8,AK8->(RecNo())) <= 0
			RecLock("AK8",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		dbSkip()
	End
	dbSelectArea("AKB")
	dbSetOrder(1)
	dbSeek(xFilial())
	While !Eof() .And. xFilial() == AKB->AKB_FILIAL
		If AKB->AKB_PROCES <= "900000" .And. aScan(aRecAKB,AKB->(RecNo())) <= 0
			RecLock("AKB",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		dbSkip()
	End
	dbSelectArea("AKA")
	dbSetOrder(1)
	dbSeek(xFilial())
	While !Eof() .And. xFilial() == AKA->AKA_FILIAL
		If AKA->AKA_PROCES <= "900000" .And. aScan(aRecAKA,AKA->(RecNo())) <= 0
			RecLock("AKA",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
		dbSkip()
	End
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoChkCuboºAutor  ³Paulo Carnelossi    º Data ³  19/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Implementacao da funcao PcoChkCubo() que objetiva retirar o º±±
±±º          ³status bloqueado (AL1_STATUS)quando reprocessamento de cubo º±±
±±º          ³gerencial por qq motivo nao terminar normalmente            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoChkCubo()
Local	aArea     := GetArea()
Local	aAreaAL1  := AL1->(GetArea())
Local 	cQuery    := ""
Local lQuery := ( TcGetDb() # "AS/400" .and. TCGetDB()!="SYBASE")

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	If AL1->(FieldPos("AL1_STATUS")) > 0

		dbSelectArea("AL1")
		dbSetOrder(1)

		If lQuery
			cQuery 	:= "  SELECT R_E_C_N_O_ REG_AUX "
			cQuery 	+= "  FROM " + RetSQLName("AL1") + " " + "AL1"
			cQuery 	+= "  WHERE "
			cQuery 	+= "  AL1_FILIAL = '"+xFilial("AL1")+"' "
			cQuery 	+= "  AND AL1_STATUS <> '1' "
			cQuery 	+= "  AND D_E_L_E_T_ <> '*' "
			cQuery 	+= "  ORDER BY  " + SqlOrder(AL1->(IndexKey()))
			cQuery := ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "AL1_QRY", .T., .T. )
			AL1_QRY->(dbGoTop())

			While AL1_QRY->(!Eof())

				dbSelectArea("AL1")
				dbGoto(AL1_QRY->REG_AUX)

				If AL1_STATUS <> '1' .And. MsRLock()    //se conseguir travar atualiza status, senao eh pq esta reprocessando
					//AL1->AL1_STATUS := "1"
					PcoCubeStatus("1")
					MsUnLock()
				EndIf

				dbSelectArea("AL1_QRY")
				AL1_QRY->(dbSkip())

			End

			//apos processar query fecha o alias correspondente
			dbSelectArea("AL1_QRY")
			DbCloseArea()

			dbSelectArea("AL1")

		Else

			dbSeek(xFilial("AL1"))

			While AL1->(!Eof() .And. AL1_FILIAL ==xFilial("AL1"))
				If MsRLock()  //se conseguir travar atualiza status, senao eh pq esta reprocessando
					AL1->AL1_STATUS := "1"
					MsUnLock()
				EndIf
				dbSelectArea("AL1")
				AL1->(dbSkip())
			End

		EndIf

	EndIf

EndIf

RestArea(aAreaAL1)
RestArea(aArea)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCOPICTU

Ajusta X3_PICTURE dos campos virtuais AKD_VAL1, AKD_VAL2, AKD_VAL3, AKD_VAL4, AKD_VAL,
pois a picture a ser utilizada é cadastrada na classe(pcoa020) e utilizada na PCOA050
onde para cada item é chamada função PCOPLANCEL que define picture que será exibida de
acordo com a classe.
Este função foi alinhada o uso com o p.o e squad até que tenha uma opção para atualizar via
atusx a picture do campo virtual como branco.
@since 06/08/2018
@version MP12.1.17

/*/
//-----------------------------------------------------------------------------------------
Static Function PCOPICTU()
	Local aRelease := StrTokArr(GetRpoRelease(), '.') //Release do RPO
	Local cFuncao  := 'EngSX3' //Rotina a ser executada ENGSX3
	Local aDados := {}

	//Compondo função que será executada
	If (Len(aRelease) == 03)
		//Exemplo: EngSX3117 (Release 12.1.17)
		cFuncao += aRelease[02] + cValToChar(Val(aRelease[03]))
		//Verifica se a função está compilada no RPO
		If (FindFunction(cFuncao))

			aAdd( aDados, { { 'AKD_VAL1' }, { { 'X3_PICTURE', '', '@E 9999999999999999'} } } )
			aAdd( aDados, { { 'AKD_VAL2' }, { { 'X3_PICTURE', '', '@E 9999999999999999'} } } )
			aAdd( aDados, { { 'AKD_VAL3' }, { { 'X3_PICTURE', '', '@E 9999999999999999'} } } )
			aAdd( aDados, { { 'AKD_VAL4' }, { { 'X3_PICTURE', '', '@E 9999999999999999'} } } )
			aAdd( aDados, { { 'AKD_VAL5' }, { { 'X3_PICTURE', '', '@E 9999999999999999'} } } )

			&cFuncao.(aDados)

		EndIf
	EndIf
Return
