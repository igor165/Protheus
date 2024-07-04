#Include "TmsA350.ch"
#Include "protheus.ch"
#Include "FwMvcDef.ch"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

Static lTM350KMO  := ExistBlock('TM350KMO')
Static lTM350GRV  := ExistBlock('TM350GRV')
Static lTM350VLD  := ExistBlock('TM350VLD')
Static lTMA350EST := ExistBlock('TMA350EST')
Static lTM350KMA  := ExistBlock('TM350KMA')
Static lTM350TKM  := ExistBlock('TM350TKM')
Static lTM350MNT  := ExistBlock('TM350MNT')
Static cTmsRdpU   := SuperGetMV( 'MV_TMSRDPU',.F., 'N' )   //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static lTmsRdpU   := !Empty(cTmsRdpU) .And. cTmsRdpU <> 'N'
Static cTMS3GFE   := SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
Static lMVITMSDMD := SuperGetMv("MV_ITMSDMD",.F.,.F.) //Parametro que indica se a Gestão de Demandas está ativa ou não.
Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Static lAuto350	  := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA350  ³ Autor ³ Alex Egydio           ³ Data ³27.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Operacoes de Transporte                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350(cTop350,cBot350,nInd350)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350(cTop350,cBot350,nInd350,cSerTms,cTipTra, aCabDTW, nOpcAuto)

Local aCores	:= {}
Local cFilMbrow	:= ""
Local cFilMbrPE	:= ""
Local lPainel	:= .F.
Local aRotBckp	:= {}

Private cCadastro	:= STR0001 //'Operacoes de Transporte'
Private aDadosDTW	:= {}
Private lMsHelpAuto	:= .F.

DEFAULT cTop350 := ""
DEFAULT cBot350 := ""
DEFAULT nInd350 := 2
DEFAULT cSerTms := ""
DEFAULT cTipTra := ""

Default aCabDTW := {}
Default nOpcAuto := 0

lAuto350 := Len(aCabDTW) > 0 .And. nOpcAuto <> 0

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

If lAuto350 .AND. Type("aRotina") <> "U"
	aRotBckp	:= AClone(aRotina)
	FwFreeArray(aRotina)
EndIf

If Type("aRotina") == "U"
	Private aRotina := MenuD350()
EndIf

aCores := Tmsa350Cor()

DbSelectArea("DTW")
DbSetOrder(nInd350)

If !Empty(cSerTms+cTipTra)
	//-- Criado 02 novos parametros para executar filtro no MBrowse permitindo selecionar os indices para Pesquisa.
	cFilMbrow := "DTW_FILIAL == '" + xFilial("DTW") + "' .And. DTW_SERTMS == '" + cSerTms + "' .And. DTW_TIPTRA == '" + cTipTra + "'"
	cTop350 := Nil
	cBot350 := Nil
EndIf

If ExistBlock("TM350FIL")
	cFilMbrPE := ExecBlock("TM350FIL",.F.,.F.)
	If Valtype(cFilMbrPE) == "C" .And. !Empty(cFilMbrPE)
		cFilMbrow += " " + cFilMbrPE
	EndIf
EndIf

If lPainel
	If (at("(",aPanAgeTMS[6])>0)
		&(aPanAgeTMS[6])
	Else
		&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
	Endif
ElseIf lAuto350
	
	lMsHelpAuto := .T.
	aDadosDTW := aClone(aCabDTW)
	
	MBrowseAuto(nOpcAuto,aDadosDTW,"DTW")

	If Len(aRotBckp) > 0
		aRotina	:= AClone(aRotBckp)
	EndIf
Else
	mBrowse( 6,1,22,75,"DTW", , , , , ,aCores,cTop350,cBot350,,,,,,,,,,cFilMbrow)
EndIf

RetIndex("DTW")

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Mnt³ Autor ³ Alex Egydio           ³ Data ³27.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao nas operacoes de transporte                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Mnt( cAlias, nReg, nOpcx )

Local aAreaDTW		:= DTW->( GetArea() )
Local cFilOri		:= DTW->DTW_FILORI
Local cViagem		:= DTW->DTW_VIAGEM
Local cAtivChg		:= SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtivSai		:= SuperGetMV('MV_ATIVSAI',,'')
Local cAtivRDP		:= SuperGetMv('MV_ATIVRDP',,'')
Local cAtivRta		:= SuperGetMV('MV_ATIVRTA',,'')
Local cAtivRtp		:= SuperGetMV('MV_ATIVRTP',,'')
Local lContVei		:= SuperGetMV('MV_CONTVEI',,.T.) // Verifica se o sistema Controla Motoristas / Veiculos
Local lMostra		:= SuperGetMV('MV_KMVEIOP',,.F.) // Valida se mostra a Tela de apontamento MANUAL de Chegada/Saida de Viagens
Local lAlianca		:= TMSAlianca() //-- Utiliza Alianca
Local oEnch
Local aAltera		:= {}
Local bVerViagem 	:= {|| TmsA350Viag() }
Local aButtons		:= { {"CARGA"  , bVerViagem , "Viagem - <F4 >" , "Viagem" } }
Local nOpca			:= 0
Local aObjects		:= {}
Local aInfo			:= {}
Local lSaida		:= ( DTW->DTW_ATIVID == cAtivSai )
Local cLockKeyVG    := "OCORXOPER" + DTQ->DTQ_VIAGEM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes do parametro "MV_PCANOP" :                                ³
//³ 0 = Cancelar as Operacoes Anteriores.                            ³
//³ 1 = Perguntar se as Operacoes Anteriores deverao ser canceladas. ³
//³ 2 = Nao Cancelar as Operacoes Anteriores                         ³
//³ 3 = Apontamento Obrigatorio das Operacoes Anteriores             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPCanOp		:= GetMv('MV_PCANOP',,1) // Opcoes para o cancelamento de operacoes de transportes.
Local lCancelaDTW	:= .F.
Local lEventual		:= .F.
Local lTMSOPdg		:= AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local aMsgErr 		:= {}
Local lKmObrig		:= SuperGetMv('MV_KMOBRIG',,.T.) // Obriga informar a Quilometragem do veiculo
Local lRet			:= .T.
Local cEncRepom		:= SuperGetMV('MV_ENREPOM',,"1")   //-- Encerra Repom pela Ocorrencia = 2 / Rotina de Encerramento = 1
Local lFrotaProp	:= .F.
Local nCheSai		:= 0
Local lRetCHE		:= .T.
Local nOpcao		:= 9
Local cFilAti		:= ""
Local lContinua		:= .T.
Local lEsporad		:= .F. //-- Apontamento esporádico
Local nCount		:= 1
Local aEsporad		:= {}
Local cSequen		:= CriaVar("DTW_SEQUEN")
Local lRestAlter	:= Altera
Local nCntFor		:= 0
Local lMDFe		:= DTX->(FieldPos("DTX_TIPMAN")) > 0
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
Local lTMS3GFE    := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local lIntGFE     := .F.
Local aAreaDUP    := {}
Local aAreaDA4    := {}
Local oStructDTW  := NIL
Local aFldsDTW    := {}
Local nI          := 0
Local aMDFe       := {}
Local lMDFEAUT    := SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático
Local cAtvSaiCli  := SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cFilBack    := cFilAnt
Local aAreaSM0    := SM0->(GetArea())
Local aFldsDTWNot := {"DTW_SYSDAT", "DTW_SYSHOR"}
Local cFilUF      := ''			
Local lDTW        := .T.
Local lMTRANS     := .F.
Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0
Local aRet		  	:= {}
Local nPCodCli	  	:= 0
Local nPLojCli	  	:= 0
Local nPSequen	  	:= 0
Local cCodLojCli	:= ""
Local lMntTms   	:= (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
//Variáveis SIGAMNT necessárias para garantir controle de transação com banco Oracle
Local cTRBF      	:= GetNextAlias()
Local cTRBS      	:= GetNextAlias()
Local CTRBEixo   	:= GetNextAlias()
Local cAtvSaiApo    := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local lVgeAtvApo    := .F.

Local lEncViag := SuperGetMv("MV_ENCVIAG",.F.,"2") == "1"	//-- Define se devera encerrar a viagem com ocorrencia para todos documentos.
Local lEncerra := .T.
Local aAreaDTQ := {}
Local lPagBem  := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Private aPosObj		:= {}
Private aTela[0][0]
Private aGets[0]
Private oDlgEsp
Private aSetKey		:= {}

If lAuto350 .AND. FwIsInCallStack("TMSA144SUB") .AND. FwIsInCallStack("MAWNDBROWSE") .AND. !FwIsInCallStack("TMSA350")
	lAuto350 := .F.
EndIf

If Type("aRotina") == "U"
	Private aRotina := MenuD350()
EndIf

If Type("cCadastro") == "U"
	Private cCadastro := STR0001 //'Operacoes de Transporte'
EndIf

cAlias := "DTW"

INCLUI := .F.

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If nOpcx <> 2
	If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,DTW->DTW_VIAGEM,)
		Return .F.
	EndIf
EndIf

If nOpcx == 3 //-- Apontar
	If Empty(DTW->DTW_VIAGEM)
		Help("",1,"TMSA35033") //"Não existem registros para efetuar o apontamento/estorno das operacoes."
		RestArea( aAreaDTW )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf
	/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
	If !SoftLock("DTW")
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf

	/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
	DTQ->(DbSetOrder(2))
	If DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))
		If !SoftLock("DTQ")
			RestArea( aAreaDTW )
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( Nil )
		EndIf
	EndIf

	If DTW->DTW_STATUS <> StrZero(1,Len(DTW->DTW_SERTMS)) //-- Em Aberto
		Help("",1,"TMSA35016") //"Manutencao permitida somente para operacoes em aberto."
		RestArea( aAreaDTW )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf

	If DTW->DTW_SERTMS == StrZero(2, Len(DTW->DTW_SERTMS)) .And. DTW->DTW_TIPTRA == StrZero(2, Len(DTW->DTW_TIPTRA)) .And.;
		Empty(cAtivRTA)
		Help('',1,'TMSA35011') //O Parametro MV_ATIVRTA esta Vazio ...
		RestArea( aAreaDTW )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf

	If DTW->DTW_SERTMS == StrZero(2, Len(DTW->DTW_SERTMS)) .And. DTW->DTW_TIPTRA == StrZero(3, Len(DTW->DTW_TIPTRA)) .And.;
		Empty(cAtivRTP)
		Help('',1,'TMSA35013') //O Parametro MV_ATIVRTP esta Vazio ...
		RestArea( aAreaDTW )
		MsUnLockAll()
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf

	If DTW->DTW_ATIVID == cAtivRDP
		DF7->(DbSetOrder(2))
		If !DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help('',1,'TMSA35024') //-- 'A retirada do reboque nao foi lancada!'
			Return( .F. )
		EndIf
	EndIf

	//Validação férias motorista
	If (DTW->DTW_ATIVID == cAtivSai .Or. DTW->DTW_ATIVID == cAtvSaiCli .Or. DTW->DTW_ATIVID == cAtvSaiApo)
		aAreaDUP  := DUP->(GetArea())
		aAreaDA4  := DA4->(GetArea())
		DUP->(dbSetOrder(2)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+
		If DUP->(MsSeek(xFilial('DUP') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ))
			While DUP->(!EOF()) .AND. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == xFilial("DUD")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
				DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD
				If DA4->(DbSeek(xFilial("DA4") + DUP->DUP_CODMOT ))
					lContinua := TMSVldFunc(DA4->DA4_MAT, DA4->DA4_FILBAS)
				EndIf
				If !lContinua
					Return( .F. )
				EndIf
				DUP->(dbSkip())
			EndDo
		EndIf
		RestArea(aAreaDUP)
		RestArea(aAreaDA4)
	EndIf

	If DTW->DTW_ATIVID == cAtivSai .Or. DTW->DTW_ATIVID == cAtvSaiCli .Or. DTW->DTW_ATIVID == cAtvSaiApo
		lContinua	:= VldLoteVge(cFilOri , cViagem )
	ElseIf DTW->DTW_ATIVID == cAtvChgCli .Or. DTW->DTW_ATIVID == cAtvChgApo
		lContinua	:= VldLoteVge(cFilOri , cViagem, cAtvChgCli, DTW->DTW_CODCLI, DTW->DTW_LOJCLI )
	EndIf

	If !lContinua
		Return( .F. )
	EndIf

	//---- Verifica se o Manifesto está autorizado
	If lMDFe .And. (DTW->DTW_ATIVID == cAtivSai .Or. DTW->DTW_ATIVID == cAtvSaiCli .Or. DTW->DTW_ATIVID == cAtvSaiApo)

		If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
			lMdfeAut:= TMA190Srv(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
		EndIf

		If lMDFEAUT //--Manifesto Automático
			// Verifica se possui manifestos com cancelamento não transmitidos.
			If A210VCnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.T.,,DTW->DTW_FILATI)
				Return .F.
			EndIf
			
			//--Se for Viagem de Entrega ou Transferencia, Faz o Encerramento MDFe para Chegada de Viagem de entrega. 
			If DTQ->DTQ_SERTMS <> "1" .And. SuperGetMV("MV_MDFEENC",,0) == 1
				//-- Encerra manifesto
				If DTW->(ColumnPos("DTW_UFATIV")) > 0 .AND. (DTW->DTW_ATIVID == cAtvSaiCli	.Or. DTW->DTW_ATIVID == cAtvSaiApo)
					cFilUF := 	DTW->DTW_UFATIV

					If !Empty(cAtvSaiApo) .And. ExistFunc('TM350AtvPA')
						lVgeAtvApo := TM350AtvPA(cFilOri, cViagem )  //Verifica se existe a operação de saida de apoio na Viagem
					EndIf
					If lVgeAtvApo
						lDTW   :=	TMA350DTW(cFilOri,cViagem,,cAtvSaiApo,cFilUF)  
					Else
						lDTW   :=	TMA350DTW(cFilOri,cViagem,,cAtvSaiCli,cFilUF)  
					EndIf					
				EndIf
				
				If lDTW .Or. DTW->DTW_ATIVID == cAtivSai
				
					aMDFe := {} 
					DTX->(DbSetOrder(5)) //--DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI                                                                                                                     
					DTX->(MsSeek(xFilial("DTX") +  DTW->(DTW_FILORI+DTW_VIAGEM) ))
					Do While DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ DTW->(DTW_FILORI+DTW_VIAGEM)						
						If DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STFMDF <> '2' //--Eletronico e não Encerrado
							If lDTW .And. !Empty(cFilUF) .And.;
								( ;
								(DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)).And. DTX->DTX_FILDCA == cFilAnt  ); //--Transferencia e Descarga na filial 
								.Or.;
								lUfAtiv .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And.  DTX->DTX_UFATIV == cFilUF ; //--Viagem de entrega Chegada em filial 
								)  
								
								lMTRANS := .T.
									 
							ElseIf M->DTW_ATIVID == cAtivSai .And. ((DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)).And. DTX->DTX_FILDCA == cFilAnt  ); //--Transferencia e Descarga na filial 
									.Or. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))) //--Viagem de entrega Chegada em filial 
									
								lMTRANS := .T.
								
							EndIf	
							
							If lMTRANS	
								Aadd(aMDFe ,Array(6))
								aMDFe[Len(aMDFe),1] := DTX->DTX_FILMAN //-- Filial Manif
								aMDFe[Len(aMDFe),2] := DTX->DTX_MANIFE //-- Manif. Inicial
								aMDFe[Len(aMDFe),3] := DTX->DTX_MANIFE //-- Manif. final
								aMDFe[Len(aMDFe),4] := DTX->DTX_SERMAN //-- Serie Manif.
								aMDFe[Len(aMDFe),5] := DTX->DTX_VIAGEM //-- VIAGEM
								If lUfAtiv
									aMDFe[Len(aMDFe),6] := DTX->DTX_UFATIV  //-- UF Atividade
								Else
									aMDFe[Len(aMDFe),6] := ''
								EndIf								
							EndIf
						EndIf
						lMTRANS := .F.
						DTX->(DbSkip())
					EndDo
				EndIf

				If !Empty(aMDFe) 
					//-- Alterar o conteudo da variavel cFilAnt													
					cFilAnt := Posicione('SM0',1,cEmpAnt+aMDFe[Len(aMDFe),1],'FWCODFIL()')

						lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto	
					
					//--Restaura o conteudo da variavel cFilAnt 											         
					cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
					RestArea(aAreaSM0)
				EndIf

			EndIf

			If lContinua
				RegToMemory("DTQ",.F.)
				lContinua := Tmsa144GMC( .F., 3, .F.) // Gera o manifesto, se houver documentos não manifestados
			EndIf

			If lContinua

				aMDFe := {}
				DTX->(DbSetOrder(5)) //-- DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI
				DTX->(MsSeek(xFilial("DTX") +  DTQ->(DTQ_FILORI+DTQ_VIAGEM) ))
				Do While DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ DTQ->(DTQ_FILORI+DTQ_VIAGEM)
					If DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STIMDF <> '2' //--Eletronico, não autorizado
						Aadd(aMDFe ,Array(6))
						aMDFe[Len(aMDFe),1] := DTX->DTX_FILMAN //-- Filial Manif
						aMDFe[Len(aMDFe),2] := DTX->DTX_MANIFE //-- Manif. Inicial
						aMDFe[Len(aMDFe),3] := DTX->DTX_MANIFE //-- Manif. final
						aMDFe[Len(aMDFe),4] := DTX->DTX_SERMAN //-- Serie Manif.
						aMDFe[Len(aMDFe),5] := DTX->DTX_VIAGEM //-- VIAGEM
						If lUfAtiv 							
							aMDFe[Len(aMDFe),6] := DTX->DTX_UFATIV  //-- UF Atividade
						Else
							aMDFe[Len(aMDFe),6] := ''	
						EndIf
					EndIf

					DTX->(DbSkip())
				EndDo

				If !Empty(aMDFe)
					lContinua := TmsMDFeAut(aMDFe, 1) //-- Envia o Manifesto
				EndIf
			EndIf
		EndIf

		DTX->(DbSetOrder(3))
		DTX->( DbSeek( cSeek := xFilial('DTX') + DTQ->(DTQ_FILORI + DTQ_VIAGEM) ))
		Do While !DTX->(Eof()) .And. DTX->(DTX_FILIAL + DTX_FILORI + DTX_VIAGEM) == cSeek
			If DTX->DTX_TIPMAN == '2'
				If DTX->DTX_IDIMDF <> '100' .And. Empty(DTX->DTX_CTGMDF)
					If lDTX_SERMAN
						Help('',1,'TMSA35032',, DTX->(DTX_FILMAN+" - "+DTX_MANIFE+" - "+DTX_SERMAN)  ,4,1)
					Else
						Help('',1,'TMSA35032',, DTX->(DTX_FILMAN+" - "+DTX_MANIFE)  ,4,1)
					EndIf
					RestArea( aAreaDTW )
					MsUnLockAll()
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( .F. )
				EndIf
			EndIf       
			DTX->(dbSkip())
		EndDo
	EndIf
	nOpcx := aRotina[ nOpcx, 4 ]

	If lContVei
		If	(DTW->DTW_ATIVID == cAtivChg .And. IIf(DTQ->DTQ_TIPTRA=='2' .Or. DTQ->DTQ_TIPTRA=='3',  DTQ->DTQ_FILORI == cFilAnt, .T.)  ) .Or. ;
			(DTW->DTW_ATIVID == cAtivSai)  .Or. ;
			(DTW->DTW_ATIVID == cAtvChgCli).Or. ;
			(DTW->DTW_ATIVID == cAtvSaiCli).Or. ;
			(DTW->DTW_ATIVID == cAtivRta)  .Or. ;    
			(DTW->DTW_ATIVID == cAtivRtp)  .Or. ;
			(DTW->DTW_ATIVID == cAtivRDP)  .Or. ;
			(DTW->DTW_ATIVID == cAtvChgApo) .Or. ;
			(DTW->DTW_ATIVID == cAtvSaiApo)
			Help("", 1,'TMSA35008',,Tabela("L3", DTW->DTW_ATIVID, .F.),5,1)// "Esta operacao e apontada pela rotina de movimento de veiculos/motoristas."
			RestArea( aAreaDTW )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( nOpcA )
		EndIf
	EndIf

	If (!Empty(DTW->DTW_FILATI) .And. DTW->DTW_FILATI <> cFilAnt)
		If lAlianca //Se utiliza alianca verifica o destino da viagem
			DVL->( DbSetOrder(1) )
			If !( DVL->( MsSeek( xFilial("DVL") + DTW->DTW_FILATI ) ) .And. DTW->DTW_FILORI == cFilAnt )//Se o Destino for filial de alianca permite encerrar a viagem na origem
				Help('',1, 'TMSA35009') //O Apontamento Nao sera efetuado pois a Filial de Atividade desta Operacao e diferente da Filial Atual ...
				RestArea( aAreaDTW )
				MsUnLockAll()
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( .F. )
			EndIf
		Else
			If (ExistBlock('TM350CHGE'))
				lRetCHE := ExecBlock('TM350CHGE',.F.,.F., {DTW->DTW_FILORI, DTW->DTW_VIAGEM, DTW->DTW_CATOPE, DTW->DTW_ATIVID}) //Ponto de entrada para habilitar ou desabilitar a chegada eventual.
			EndIf
			If(lRetCHE)
				If	DTW->DTW_ATIVID == cAtivChg .And. ;
					DTW->DTW_CATOPE <> StrZero(2,Len(DTW->DTW_CATOPE)) .And. ; //-- Eventual
					MsgYesNo(STR0029, STR0018)//"A Filial de Atividade da chegada é diferente da Filial atual, deseja efetuar a chegada nesta filial ?"###"Atencao"
					lEventual := .T.
				Else
					Help('',1, 'TMSA35009') //O Apontamento Nao sera efetuado pois a Filial de Atividade desta Operacao e diferente da Filial Atual ...
					RestArea( aAreaDTW )
					MsUnLockAll()
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Return( .F. )
				EndIf
			 Else
				Help('',1, 'TMSA35009') //O Apontamento Nao sera efetuado pois a Filial de Atividade desta Operacao e diferente da Filial Atual ...
				RestArea( aAreaDTW )
				MsUnLockAll()
				//-- Limpa marcas dos agendamentos
				//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
				If !IsInCallStack("TMSAF76")
					TMSALimAge(StrZero(ThreadId(),20))
				EndIf
				Return( .F. )
			EndIf
		EndIf
	EndIf

	// Verifica se existem operacoes em aberto de chegada/saida.
	If !TMSA350VOp(DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_SEQUEN,cAtivChg,cAtivSai,@nCheSai,cAtvChgCli,cAtvSaiCli,cAtvChgApo,cAtvSaiApo )  
		If nCheSai == 1 .OR. nCheSai == 2 .OR. nCheSai == 3 .OR. nCheSai == 4
			If nCheSai == 1
			    Help("",1,"TMSA35015")	 // "Existem operacoes de chegada/saida","anteriores em aberto."
			ElseIf nCheSai == 2
				Help("", 1, "TMSA35037") // Não é possível apontar a operação de Saída de Cliente sem o apontamento da operação de Chegada em Cliente.
			ElseIf nCheSai == 3
				Help("", 1, "TMSA35040") // Não é possível apontar a operação de Chegada em Cliente sem o apontamento da operação de Saída de Cliente.
			Else
				aRet := A350RetDTW(cFilOri, cViagem, "4", "2")
				If Len(aRet) > 0
					nPCodCli := aScan(aRet[1], { |x| x[1] == "DTW_CODCLI" })
					nPLojCli := aScan(aRet[1], { |x| x[1] == "DTW_LOJCLI" })
					nPSequen := aScan(aRet[1], { |x| x[1] == "DTW_SEQUEN" })
					If nPCodCli > 0 .AND. nPLojCli > 0
						cCodLojCli := aRet[1, nPCodCli][2] + "/" + aRet[1, nPLojCli][2] + " (Sequencia " + aRet[1, nPSequen][2] + ")."
					EndIf
					aRet := {}
					aSize(aRet, 0)
				EndIf		
				Help("", 1, "TMSA35041",, cCodLojCli, 4, 1) // Apontamento de Chegada de Viagem não permitido pois existe uma Chegada de Cliente efetuada sem que a Saída do mesmo cliente tenha sido apontada. Favor verificar os apontamentos do cliente xxxxxx/xx (Sequencia xxx).
			EndIf
			RestArea( aAreaDTW )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( .F. )
		EndIf
		Do Case
		Case nPCanOp == 0 						// Cancelar as Operacoes Anteriores.
				nOpcao := 1

		Case nPCanOp == 1						// Perguntar se as Operacoes Anteriores deverao ser canceladas.
			If MsgYesNo(STR0019, STR0018)		// "Existem operacoes anteriores 'em aberto'. Deseja cancelar essas operacoes ?"###"Atencao"
				nOpcao := 1
			Else
			EndIf

		Case nPCanOp == 3 						// Apontamento Obrigatorio das Operacoes anteriores
			Help("",1,"TMSA35018") 		   		// "Existem Operacoes Anteriores em Aberto; Favor aponta-las"
			RestArea( aAreaDTW )
			MsUnLockAll()
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Return( .F. )
		EndCase
	EndIf

	RestArea( aAreaDTW )

	AAdd( aAltera, 'DTW_DATINI' )
	AAdd( aAltera, 'DTW_HORINI' )
	AAdd( aAltera, 'DTW_DATREA' )
	AAdd( aAltera, 'DTW_HORREA' )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Existem Campos de Usuario no SX3                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStructDTW := FWFormStruct(1, "DTW")
	aFldsDTW := oStructDTW:aFields
	For nI := 1 To Len(aFldsDTW)
		If GetSX3Cache(aFldsDTW[nI][3], "X3_PROPRI") == "U" .AND. aScan(aFldsDTWNot, {|x| x == aFldsDTW[nI][3]}) = 0
			aAdd(aAltera, aFldsDTW[nI][3])
		EndIf
	Next

	FreeObj(oStructDTW)

	aSize(aFldsDTW, 0)
	aFldsDTW := Nil
Else

	nOpcx := aRotina[ nOpcx, 4 ]

	If nOpcx == 6
		If MsgYesNo(STR0042,STR0043) //-- Deseja incluir nova atividade? , Apontamento Esporadico

			INCLUI := .T.
			ALTERA := .F.

			AAdd( aAltera, 'DTW_ATIVID' )
			AAdd( aAltera, 'DTW_DATPRE' )
			AAdd( aAltera, 'DTW_HORPRE' )
			AAdd( aAltera, 'DTW_DATINI' )
			AAdd( aAltera, 'DTW_HORINI' )
			AAdd( aAltera, 'DTW_DATREA' )
			AAdd( aAltera, 'DTW_HORREA' )

			oStructDTW := FWFormStruct(1, "DTW")
			aFldsDTW := oStructDTW:aFields
			For nI := 1 To Len(aFldsDTW)
				If GetSX3Cache(aFldsDTW[nI][3], "X3_PROPRI") == "U" .AND. aScan(aFldsDTWNot, {|x| x == aFldsDTW[nI][3]}) = 0
					aAdd(aAltera, aFldsDTW[nI][3])
				EndIf
			Next

			FreeObj(oStructDTW)

			aSize(aFldsDTW, 0)
			aFldsDTW := Nil

			For nCount := 1 To DTW->( FCount() )

				Aadd( aEsporad , { "M->" + AllTrim(DTW->(FieldName(nCount) ) )  , &("DTW->" +  AllTrim(DTW->( FieldName(nCount) ) ) ) } )

			Next nCount

			lEsporad  := .T.
		Else
			lContinua := .F.
		EndIf

	EndIf
EndIf

If lContinua .And. lEsporad
	//-- Verifica status da viagem
	lContinua := TMA350VEsp(DTW->DTW_FILORI,DTW->DTW_VIAGEM,,.T.)
EndIf

If nOpcx == 2 .And. Empty(DTW->DTW_VIAGEM)
	lContinua := .F.
EndIf

If !LockByName(cLockKeyVG,.T.,.F.)
	Help('',1,"TMSA350LOCK1",,"Registro sendo utilizado por outro usuário.",3,1)
	lContinua := .F.
EndIf

If lContinua
	//-- Configura variaveis da Enchoice
	RegToMemory(cAlias,lEsporad)
	If lEsporad
		//-- Atribui para as variaveis de memoria os mesmos valores do registro posicionado
		For nCount := 1 To Len(aEsporad)
			&(aEsporad[nCount,1]) := aEsporad[nCount,2]
		Next nCount

		cSequen := Soma1(M->DTW_SEQUEN)

		While !TMA350VEsp(M->DTW_FILORI,M->DTW_VIAGEM,cSequen)
			cSequen := Soma1(cSequen)
		EndDo

		M->DTW_SEQUEN	:= cSequen
		M->DTW_STATUS 	:= StrZero(1,Len(DTW->DTW_STATUS)) //-- Em aberto
		M->DTW_CATOPE 	:= StrZero(2,Len(DTW->DTW_CATOPE)) //-- Eventual
		M->DTW_ATIVID 	:= CriaVar("DTW_ATIVID")
	EndIf

	If nOpcx == 3 .Or. (nOpcx == 6 .And. lEsporad)
		M->DTW_DATINI	:= CriaVar("DTW_DATINI")
		M->DTW_HORINI	:= CriaVar("DTW_HORINI")
		M->DTW_DATREA	:= CriaVar("DTW_DATREA")
		M->DTW_HORREA	:= CriaVar("DTW_HORREA")
	EndIf

	If ExistBlock("TM350INI")
		ExecBlock("TM350INI",.F.,.F.,{nOpcx})
	EndIf

	aFldsDTW := {}
	oStructDTW := FWFormStruct(1, "DTW")
	For nI := 1 To Len(oStructDTW:aFields)
		If aScan(aFldsDTWNot, {|x| x == oStructDTW:aFields[nI][3]}) = 0
			aAdd(aFldsDTW, oStructDTW:aFields[nI][3])
		EndIf
	Next

	FreeObj(oStructDTW)

	aSize(aFldsDTWNot, 0)
	aFldsDTWNot := Nil
	If !lAuto350
		//-- Inicializa Teclas de Atalhos
		AAdd(aSetKey, { VK_F4 ,  bVerViagem } )
		TmsKeyOn(aSetKey)

		//-- Calcula as dimensoes dos objetos
		aSize  := MsAdvSize( .T. )

		AAdd( aObjects, { 100, 100,.T.,.T. } )

		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj:= MsObjSize( aInfo, aObjects,.T. )

		DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
			//-- Monta a Enchoice
			SetEnch("")
			oEnch := MsMGet():New( cAlias, nReg, Iif(lEsporad,3,nOpcx),,,,aFldsDTW, aPosObj[1], aAltera, 3, , , , , ,.T. )

		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1,if(Obrigatorio(aGets,aTela).And.A350TudOk(nOpcx,lEsporad),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons )
	Else
		If EnchAuto(cAlias,aDadosDTW,,nOpcx,aFldsDTW,{|| Obrigatorio(aGets,aTela)},{|| A350TudOk(nOpcx,lEsporad)},aDadosDTW,nOpcx)
			nOpca:=1
		Endif
	EndIf

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

	//Cria as tabelas temporárias do SIGAMNT para garantir Disarm Transaction
	If lMntTms .And. FindFunction("MNTCTemp")
		MNTCTemp({cTRBF,cTRBS,CTRBEixo})
	EndIf
	If	nOpca == 1 .And. (nOpcx == 3 .Or. lEsporad)
		Begin Transaction
			If(nOpcao == 1)
				TMSA350COp(DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_SEQUEN)
			EndIf
			If !lAuto350
				//-- Se o Parametro MV_CONTVEI estiver desabilitado e o parametro MV_KMVEIOP estiver habilitado,
				//-- a Operacao de Chegada de Viagem, Saida de Viagem, Retorno de Aeroporto e Retorno de Porto, sera' apontada manualmente
				If !lContVei .And. lKmObrig .And. lMostra .And. !Empty(M->DTW_DATREA) .And. validAtivid(M->DTW_ATIVID) .And. ApontaKm(M->DTW_FILORI,M->DTW_VIAGEM,@lSaida)
					lRet := TMSA350Km(M->DTW_FILORI,M->DTW_VIAGEM,lSaida,lKmObrig,M->DTW_DATREA,M->DTW_HORREA,,,{cTRBS,cTRBF,CTRBEixo})
				EndIf
			EndIf

			//-- Se nao encontrou Atividade de Chegada/Saida 'Prevista' com status 'Em Aberto' no DTW,
			//-- grava operacao de chegada/Saida 'Eventual'
			cFilAti:= M->DTW_FILATI

			If lRet .And. lEventual
				TM350Event(DTW->DTW_FILORI,DTW->DTW_VIAGEM,@cFilAti)
				If Empty(cFilAti)
					cFilAti:= M->DTW_FILATI
				EndIf
			EndIf

			If lRet .And. lEsporad
				RecLock('DTW',.T.)
				For nCntFor := 1 To DTW->( FCount() )
					If FieldName( nCntFor ) == 'DTW_FILIAL'
						FieldPut( nCntFor, xFilial('DTW') )
					Else
						FieldPut( nCntFor, M->&( Eval( {|x| FieldName(x) },nCntFor ) ) )
					EndIf
				Next
				If DTW->(ColumnPos("DTW_SYSDAT")) > 0
					M->DTW_SYSDAT := DToS(Date())
				EndIf
				If DTW->(ColumnPos("DTW_SYSHOR")) > 0
					M->DTW_SYSHOR := StrTran(Time(), ":", "")
				EndIf
				DTW->( MsUnLock() )
			EndIf

			If lRet .And. (nOpcx == 3 .Or. (lEsporad .And. !Empty(M->DTW_DATREA)))
				lRet := TMSA350Grv(nOpcx, cFilOri, cViagem,,,,,,, lEventual,,{cTRBS,cTRBF,CTRBEixo})
				//-- Cancela as operacoes anteriores em aberto.
				If lRet .And. lCancelaDTW
					TMSA350COp(cFilOri,cViagem,M->DTW_SEQUEN)
				EndIf
			EndIf

			//-- Verifica se deve encerrar a viagem automaticamente
			If lRet .And. !lSaida
				aAreaDTQ := DTQ->(GetArea())
				DTQ->(DbSetOrder(2))
				DTQ->(DbSeek(xFilial("DTQ") + DTW->DTW_FILORI + DTW->DTW_VIAGEM))

				If DTQ->(ColumnPos("DTQ_CODAUT")) > 0
					lEncerra := TMSA360Aut(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA340",lEncViag)
				Else
					lEncerra := lEncViag
				EndIf

				If FindFunction("TMSA360Enc")
					If lEncerra .And. !IsInCallStack("TMSAE81") .And. TMSA360Enc(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
						If (IsInCallStack("TMSAF76") .And. DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS))) .Or. (!IsInCallStack("TMSAF76") .And. DTQ->DTQ_STATUS <> StrZero(3,Len(DTQ->DTQ_STATUS)))
							TMSA340Grv(.T.)
						EndIf
					EndIf
				EndIf
				RestArea(aAreaDTQ)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³Quando o controle de veiculos NAO estiver   ³
			//³ativo, a abertura do controle de viagem com ³
			//³a Operadora de Frotas ira ocorrer no momento³
			//³do apontamento da Operacao de Saida de via_ ³
			//³gem. Quando o controle de veiculos estiver  ³
			//³ativo, a abertura do controle de viagem sera³
			//³realizada atraves do fechamento da viagem.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//operacoes repom para saida de viagem
			If lRet .And. !lContVei .And. lTMSOPdg .And. ((M->DTW_ATIVID == cAtivSai .And. cFilAti == M->DTW_FILORI) .Or. cAtvSaiCli == M->DTW_ATIVID )
				DTR->(DbSetOrder(1))
				If DTR->(MsSeek(xFilial('DTR')+ M->(DTW_FILORI+DTW_VIAGEM))) .And. !Empty(DTR->DTR_CODOPE)
					lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
					If ( lFrotaProp .Or. DTR->DTR_CODOPE == '02' ) .And. (M->DTW_ATIVID == cAtivSai .And. cFilAti == M->DTW_FILORI)
						CursorWait()
						MsgRun( STR0031,; //-- "Emissao do Controle de Viagem na Operadora"
						STR0030,; //-- 'Aguarde...'
						{|| lRet := TMA310Oper( DTR->DTR_CODOPE, M->DTW_FILORI, M->DTW_VIAGEM, @aMsgErr, nOpcx, DTR->DTR_CODVEI )} )
						CursorArrow()
						If !lRet .And. !Empty( aMsgErr )
							TmsMsgErr( aMsgErr )
							//-- Exclui ou atualiza os registros de entradas e saidas de veiculo.
							DUV->( DbSetOrder(1) )
							If M->DTW_ATIVID == cAtivSai // Saida de Viagem
								DUV->( MsSeek( cSeek := xFilial("DUV")+M->DTW_FILORI + M->DTW_VIAGEM ) )
								Do While !DUV->(Eof()) .And. DUV->( DUV_FILIAL + DUV->DUV_FILORI + DUV->DUV_VIAGEM ) == cSeek
									RecLock("DUV", .F.)
									DUV->(dbDelete())
									DUV->(MsUnLock())
									DUV->(dbSkip())
								EndDo
							ElseIf M->DTW_ATIVID == cAtivChg // Chegada de Viagem
								DUV->( MsSeek( cSeek := xFilial("DUV") + M->DTW_FILORI + DTW->DTW_VIAGEM ) )
								Do While !DUV->( Eof() ) .And. DUV->( DUV_FILIAL + DUV->DUV_FILORI + DUV->DUV_VIAGEM ) == cSeek
									If DUV->DUV_FILENT == cFilAnt
										RecLock("DUV", .F.)
										DUV->DUV_FILENT := CriaVar("DUV_FILENT", .F.)
										DUV->(MsUnLock())
									EndIf
									DUV->(dbSkip())
								EndDo
							EndIf
						EndIf
					ElseIf DTR->DTR_CODOPE == '03' .And. lPagBem .And. (M->DTW_ATIVID == cAtivSai .And. cFilAti == M->DTW_FILORI) //PAGBEM
						lRet 	:= A350VgPGBe(M->DTW_FILORI, M->DTW_VIAGEM)//Chama Método para Liberar a Viagem na PAGBEM.  	
					ElseIf cAtvSaiCli == M->DTW_ATIVID .And. !lFrotaProp .And. DTR->DTR_CODOPE == '01' .And. !SuperGetMv("MV_ENREPOM",,"1") $ "1|2"
						lRet	:= A350RepDoc( M->DTW_FILORI , M->DTW_VIAGEM , M->DTW_ATIVID, M->DTW_CODCLI , M->DTW_LOJCLI ) 
					EndIf
				EndIf
			EndIf

			//Utilizando o Parametro para encerrar a Repom na Operacao de Ocorrencia
			//operacoes repom para apontamento de chegada da viagem
			If lRet .And. cEncRepom == '2' .And. !lRestRepom // Encerramento da Repom é pela Operacoes de Ocorrencia
				DTQ->(DbSetOrder(2))
				DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
				If lRet .And. !lContVei .And. lTMSOPdg .And. (M->DTW_ATIVID == cAtivChg .And. cFilAti == DTQ->DTQ_FILDES)
					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR')+ M->(DTW_FILORI+DTW_VIAGEM))) .And. DTR->DTR_CODOPE == '01'
						lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
						CursorWait()
						MsgRun( If( !lFrotaProp,STR0036, STR0037 ) ,; //-- 'Quitacao do Contrato junto a Operadora de Frotas...' ## 'Baixa da Viagem junto a Operadora de Frotas...'
						STR0030,; //-- 'Aguarde...'
						{|| lRet := TMA340Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, lFrotaProp, nOpcx )} )
						CursorArrow()
						If !lRet .And. !Empty( aMsgErr )
							TmsMsgErr( aMsgErr )
						EndIf
					EndIf
				EndIf
			EndIf

			//---- Integração Viagem TMS x GFE
			If lRet .And. nOpcx == 3
				If DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA))
					If DTQ->DTQ_SERTMS == "3"  //Redespacho
						If lTMSRDPU  ////--- Integração pelo Novo Modelo parametro lTMSRDPU
							lIntGFE:= (cTmsRdpU == 'S' .And. M->DTW_ATIVID == cAtivSai) .Or. (cTmsRdpU == 'C' .And. M->DTW_ATIVID == cAtivChg)
						EndIf
						//-- Apontamento das ocorrencias informativas para doc. de redespacho.
						If M->DTW_ATIVID == cAtivChg
							lRet:= TMSA350Red(nOpcx)
						EndIf
					EndIf
				ElseIf lTMS3GFE
					lIntGFE:= (cTMS3GFE == 'S' .And. M->DTW_ATIVID == cAtivSai) .Or. (cTMS3GFE == 'C' .And. M->DTW_ATIVID == cAtivChg)
				EndIf
				If lIntGFE .And. lRet
					lRet:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., .F.)
				EndIf
			EndIf
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction

    EndIf
	RestArea( aAreaDTW )

	//Deleta as tabelas temporárias relacionadas ao SIGAMNT
	If lMntTms .And. FindFunction("MNTDTemp")
		MNTDTemp()
	EndIf
	MsUnLockAll()

	//--Destrava o uso da rotina para a viagem posicionada
	UnLockByName(cLockKeyVG,.T.,.F.)

	If !lEventual .And. nOpca == 1
		If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
			lMdfeAut:= TMA190Srv(cFilOri,cViagem)
		EndIf

		aMDFe := {}
		DTQ->(DbSetOrder(2))
		If lRet .And. lMDFEAUT .And. DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))
			//+--------------------------------------------------------------------------------------------------
			//-- Faz o Encerramento MDFe para Chegada de Viagem.
			//+--------------------------------------------------------------------------------------------------
			If (SuperGetMV("MV_MDFEENC",,0) == 0) .And. (M->DTW_ATIVID == cAtivChg .Or. DTW->DTW_ATIVID == cAtvChgCli .Or. DTW->DTW_ATIVID == cAtvChgApo)
           		//-- Encerra manifesto
           		If DTW->(ColumnPos("DTW_UFATIV")) > 0 .AND. (DTW->DTW_ATIVID == cAtvChgCli	.Or. DTW->DTW_ATIVID == cAtvChgApo)  
           			cFilUF := 	DTW->DTW_UFATIV			
					lDTW :=	TMA350DTW(cFilOri,cViagem,cAtvChgCli,,cFilUF)						
				EndIf
				If lDTW .Or. M->DTW_ATIVID == cAtivChg
					aMDFe := RetMDFEVet(cFilOri,cViagem,cFilUF,DTW->DTW_ATIVID,DTQ->DTQ_SERTMS,lDTW)
				EndIf
			//+--------------------------------------------------------------------------------------------------
			//-- Faz o Encerramento MDFe para Chegada de Viagem.
			//+--------------------------------------------------------------------------------------------------
			ElseIf (SuperGetMV("MV_MDFEENC",,0) == 1) .And. (M->DTW_ATIVID == cAtivSai .Or. DTW->DTW_ATIVID == cAtvSaiCli .Or. DTW->DTW_ATIVID == cAtvSaiApo)
           		//-- Encerra manifesto
           		If DTW->(ColumnPos("DTW_UFATIV")) > 0 .AND. (DTW->DTW_ATIVID == cAtvSaiCli	.Or. DTW->DTW_ATIVID == cAtvSaiApo)  
           			cFilUF := 	DTW->DTW_UFATIV	
					lDTW :=	TMA350DTW(cFilOri,cViagem,cAtvSaiCli,,cFilUF)
				EndIf
				If lDTW .Or. M->DTW_ATIVID == cAtivSai
					aMDFe := RetMDFEVet(cFilOri,cViagem,cFilUF,DTW->DTW_ATIVID,DTQ->DTQ_SERTMS,lDTW)
				EndIf
			EndIf
			If !Empty(aMDFe) 
				//-- Alterar o conteudo da variavel cFilAnt													
				cFilAnt := Posicione('SM0',1,cEmpAnt+aMDFe[Len(aMDFe),1],'FWCODFIL()')														
				lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto
				//--Restaura o conteudo da variavel cFilAnt 													         
				cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
				RestArea(aAreaSM0)
				RestArea(aAreaDTW)
			EndIf
       EndIf

	EndIf
	
	//-- Atualiza o Status dos Documentos de Redespacho
	If nOpcx == 3
		TMSA350Sta( cFilOri, cViagem)
	EndIf

	If lTM350MNT
		ExecBlock("TM350MNT",.F.,.F.,{Iif (nOpca == 1, lRet, .F.), nOPcx, DTW->DTW_ATIVID, DTW->DTW_SERTMS, cFilOri, cViagem})
	EndIf

EndIf

TMSFimRot()

Altera := lRestAlter

Return( nOpca )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Leg³ Autor ³ Alex Egydio           ³ Data ³28.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status das operacoes de transporte      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Texto da legenda.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Leg( cTxtLeg )
Local aStatus := {	{ 'BR_VERDE'    , STR0010 },;		//'Em Aberto'
					{ 'BR_VERMELHO' , STR0013 },;		//'Encerrado'
					{ 'BR_PRETO'    , STR0011 }}		//'Cancelado'

Default cTxtLeg := STR0012

BrwLegenda( STR0001, cTxtLeg , aStatus )			//'Status'

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Grv³ Autor ³Robson Alves           ³ Data ³24.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua gravacao dos apontamentos das operacoes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Grv(ExpC1,ExpC2,ExpC3,ExpD1,ExpC4)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao Selecionada                                  ³±±
±±³          ³ ExpC1 = Filial da viagem.                                  ³±±
±±³          ³ ExpC2 = Codigo da viagem.                                  ³±±
±±³          ³ ExpC3 = Atividade.                                         ³±±
±±³          ³ ExpD1 = Data Inicio.                                       ³±±
±±³          ³ ExpC4 = Hora Inicio.                                       ³±±
±±³          ³ ExpD2 = Data Realizado.                                    ³±±
±±³          ³ ExpC5 = Hora Realizado.  								  ³±±
±±³ 		 aTrbEst = Array possuindo as tabelas temporárias de 		  ³±±
±±³ 		 		  estrutura do bem (SIGAMNT).						  ³±±
±±³					 [1] tabela temporaria do pai da estrutura - cTRBS    ³±±
±±³					 [2] tabela temporaria do pai da estrutura - cTRBF    ³±±
±±³					 [3] tabela temporaria do eixo suspenso    - CTRBEixo ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Grv(nOpcx, cFilOri, cViagem, cAtividade, dDatIni, cHorIni, dDatRea, cHorRea, lRecursivo, lEvent , cIdMPos , aTrbEst )

Local lRet      := .T.
Local cAtivChg  := SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtivSai  := SuperGetMV('MV_ATIVSAI',,'') //-- Atividade de Saida de Viagem
Local cAtivDca  := SuperGetMV('MV_ATIVDCA',,'') //-- Atividade de Descarregamento
Local cAtivRDP  := SuperGetMv('MV_ATIVRDP',,'') //-- Atividade de Saida para retirada do Reboque
Local cAtivRTP  := SuperGetMv('MV_ATIVRTP',,'') //-- Atividade de Retorno do Porto
Local cAtivDES  := SuperGetMv('MV_ATIVDES',,'') //-- Atividade de Descanso do Motorista
Local cAtivREF  := SuperGetMv('MV_ATIVREF',,'') //-- Atividade de Refeição do Motorista
Local lContVei  := SuperGetMV('MV_CONTVEI',,.T.)//-- Controla Motoristas / Veiculos ?
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local bCampo    := {|x| FieldName(x) }
Local nCntFor   := 0
Local cSeek     := ""
Local cAliasQry := ""
Local cQuery    := ""
Local aDocImp   := {}
Local cFilAtu   := cFilAnt
Local cFilAli   := ""
Local lDestAli  := .F.
Local lDocBlq   := .F. //-- Obtem os Documentos Nao Bloqueados.
Local aDoc      := {}
Local lAchouDUD := .F.
Local nA        := 0
Local cStatus   := "'" + StrZero(4,Len(DUD->DUD_STATUS)) + "','" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
Local lAptJor   := SuperGetMv("MV_CONTJOR",,.F.) .And. AliasInDic('DEW') //-- Apontamento da jornada de trabalho do motorista
Local cUltSeq   := DTW->(DTW_SEQUEN)
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local cTmsErp	:= SuperGetMv("MV_TMSERP",,'0')

//-- Integração MNT
Local lMntTms   := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local cAtivIsp  := ( SuperGetMv('MV_ATIVISP',,''))
Local cCodBem   := ""
Local nCntBem   := 0
Local cBemRb1   := ""
Local nCntRb1   := 0
Local cBemRb2   := ""
Local nCntRb2   := 0
Local cBemRb3   := ""
Local nCntRb3	  := 0
Local dData     := CToD("")
Local cHora     := ""
Local aFolder   := {}
Local cSerIsp   := (SuperGetMV('MV_SERISP',,'' ))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes se o a versao usada é igual ou superior ³
//³que versão 10 Release 11.5                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lR5        := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao    := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lExeIntMnt := ((nVersao == 11 .And. lR5) .Or. nVersao > 11) //-- Verificação de Release .5 do Protheus 11
Local lIDMPos    := DTW->(FieldPos('DTW_IDMPOS')) > 0
Local cIteDTR    := ""
Local cCodMot    := ""
//--- Integração TMS X ERP DATASUL
Local cAdapter 	 := "TMSA350" //--Rotina que deve estar cadastrada no adapter
Local AEAIRET	 := {}

Local aAreaDTW   := {}
Local cCodCli    := ""
Local cLojCli    := ""
Local cCatOpe    := ""
Local cAtvSaiApo := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local lVgeAtvApo := .F.

Local lTMSIntChk := TableIndic("DM0") .And. SuperGetMV("MV_TMAPCKL",,.F.) .And. ExistFunc("TMSIntChk")
Local lIntChkSai := SuperGetMV("MV_TMINTEV",,"") == "2"
Local aSaiApoio  := {}
Local aDocsChk   := {}
Local aRetEnv    := {}
Local aMsgChk    := {}
Local aReenvC	 := {}

Local nRecDN5    := 0

Default lRecursivo := .F.
Default lEvent     := .F. //--Chegada Eventual
Default aTrbEst    := {}  //Variável criada para integração junto ao SIGAMNT

If !Empty(cAtividade)
	RegToMemory("DTW", .F.)
EndIf

If lRet .And. lTM350VLD
	lRet := ExecBlock('TM350VLD',.F.,.F.,{cFilOri, cViagem, nOpcx})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

If lRet
	If nOpcx == 3 .Or. nOpcx == 6 //-- Apontamento ou Apontamento esporádico

		DEFAULT cAtividade := M->DTW_ATIVID
		DEFAULT dDatIni    := M->DTW_DATINI
		DEFAULT cHorIni    := M->DTW_HORINI
		DEFAULT dDatRea    := M->DTW_DATREA
		DEFAULT cHorRea    := M->DTW_HORREA
		If lIDMPos
			DEFAULT cIdMPos	:= M->DTW_IDMPOS
		EndIf

		If cAtividade == cAtivSai
			// Se for viagem de entrega, verifica se existe algum documento de reentrega nao impresso
			DTQ->(DbSetOrder(2))
			If DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem)) .And. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))
				aDocImp := {}
				cAliasQry := GetNextAlias()
				cQuery := "SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE "
				cQuery += " FROM " + RetSqlName("DUD") + " DUD "
				cQuery += "WHERE DUD_FILIAL = '" + xFilial("DUD")  + "' "
				cQuery += "  AND DUD_FILORI = '" + DTQ->DTQ_FILORI + "' "
				cQuery += "  AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
				cQuery += "  AND DUD.D_E_L_E_T_ = ' '"
				cQuery += "  AND EXISTS (SELECT 1 FROM " + RetSqlName("DT6") + " DT6 " // Alterado para usar subquery para reduzir tempo de exec.
				cQuery += "WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
				cQuery += "  AND DT6_FILDCO = DUD_FILDOC "
				cQuery += "  AND DT6_DOCDCO = DUD_DOC "
				cQuery += "  AND DT6_SERDCO = DUD_SERIE "
				cQuery += "  AND DT6_DOCTMS IN ('7','D') "
				cQuery += "  AND DT6_FIMP   = '" + StrZero(0,Len(DT6->DT6_FIMP)) + "' "
				cQuery += "  AND DT6.D_E_L_E_T_ = ' ')"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				While (cAliasQry)->(!Eof())
					AAdd(aDocImp,{ STR0016 + ": " +(cAliasQry)->DUD_FILDOC+"/"+(cAliasQry)->DUD_DOC+"/"+(cAliasQry)->DUD_SERIE+STR0023 ,,}) //"Conhecimento: "###" nao foi impresso."
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
				DbSelectArea("DTW")
				If Len(aDocImp) > 0
					TmsMsgErr(aDocImp)
					lRet := .F.
				EndIf
			EndIf
			If lRet
				TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)
			EndIf
			//-- Atualiza a Data Inicio na Viagem.
			DTQ->( dbSetOrder( 2 ) )
			If DTQ->( MsSeek( xFilial('DTQ') + M->DTW_FILORI + M->DTW_VIAGEM ) )
				RecLock( "DTQ", .F. )
				DTQ->DTQ_DATINI := dDatRea
				DTQ->DTQ_HORINI := cHorRea
				MsUnlock()
			EndIf

		ElseIf (cAtividade == cAtvSaiCli .Or. cAtividade == cAtvSaiApo)

			cQuery := "SELECT DTW_STATUS "
			cQuery += "FROM " + RetSqlName("DTW") + " "
			cQuery += "WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
			cQuery += "AND DTW_FILORI = '" + cFilOri + "' "
			cQuery += "AND DTW_VIAGEM = '" + cViagem + "' "
			cQuery += "AND DTW_CODCLI = '" + M->DTW_CODCLI + "' "
			cQuery += "AND DTW_LOJCLI = '" + M->DTW_LOJCLI + "' "
			cQuery += "AND DTW_SEQUEN < '" + M->DTW_SEQUEN + "' "
			If !Empty(cAtvSaiApo)
				cQuery += "AND DTW_ATIVID IN ('" + cAtvChgCli + "','" + cAtvChgApo+ "')"
			Else
				cQuery += "AND DTW_ATIVID = '" + cAtvChgCli + "' "
			EndIf	
			cQuery += "AND D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY DTW_SEQUEN DESC"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
			If (cAliasQry)->(!Eof())
				If (cAliasQry)->DTW_STATUS $ "1,9"
					lRet := .F.
					Help("", 1, "TMSA35037") // Não é possível apontar a operação de Saída de Cliente sem o apontamento da operação de Chegada em Cliente.
		        EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())

		ElseIf (cAtividade == cAtvChgCli .Or. cAtividade == cAtvChgApo)

			If !A350DTWVal(cFilOri, cViagem)
				lRet := .F.
				Help("", 1, "TMSA35040") // Não é possível apontar a operação de Chegada em Cliente sem o apontamento da operação de Saída de Cliente.
			EndIf
			
		EndIf

		If lRet
			If !Empty( dDatRea ) .And. !Empty( cHorRea )
				If	cAtividade == cAtivChg .Or. cAtividade == cAtivSai .Or. cAtividade == cAtivDca .Or. cAtividade == cAtvSaiCli .Or. cAtividade == cAtvSaiApo
					//-- Verifica se a atividade da chegada de viagem eh alianca.
					If	cAtividade == cAtivChg
						cFilAli := Posicione("DVL",1,xFilial("DVL")+M->DTW_FILATI,"DVL_FILALI")
						If !Empty(cFilAli) .And. TmsAlianca()
							cFilAtu  := cFilAli
							lDestAli := .T.
						EndIf
						TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)

						EndIf
					lRet := TMSMovViag(cFilOri,cViagem,cAtividade,,,,,cFilAtu,lDestAli)
				EndIf
				M->DTW_STATUS := StrZero(2, Len(DTW->DTW_STATUS))
			EndIf
		EndIf

		//--O tratamento abaixo aplica-se somente quando o apontamento
		//--da operacao nao se tratar da categoria "Eventual".
		//--O tratamento para operacoes da categoria "Eventual" eh realizado
		//--atraves da funcao "TM350Event()"
		If !lEvent
			If lRet
				M->DTW_ATIVID := cAtividade
				M->DTW_DATINI := dDatIni
				M->DTW_HORINI := cHorIni
				M->DTW_DATREA := dDatRea
				M->DTW_HORREA := cHorRea

				If !lDestAli //-- Atividade na filial destino parceiro (alianca).
					M->DTW_FILATI := cFilAnt
				EndIf

				If DTW->(FieldPos('DTW_FILATU')) > 0
					M->DTW_FILATU := M->DTW_FILATI
				EndIf

				If lIDMPos
					M->DTW_IDMPOS := cIDMPos
				EndIf

				If DTW->(ColumnPos("DTW_SYSDAT")) > 0
					M->DTW_SYSDAT := DToS(Date())
				EndIf
				If DTW->(ColumnPos("DTW_SYSHOR")) > 0
					M->DTW_SYSHOR := StrTran(Time(), ":", "")
				EndIf

				RecLock('DTW',.F.)
				For nCntFor := 1 To DTW->( FCount() )
					If FieldName( nCntFor ) == 'DTW_FILIAL'
						FieldPut( nCntFor, xFilial('DTW') )
					Else
						FieldPut( nCntFor, M->&( Eval( bCampo,nCntFor ) ) )
					EndIf
				Next

				DTW->( MsUnLock() )

				If lMVITMSDMD
					If cAtividade == cAtivSai
						If FindFunction("PlnDmdTran") .And. TableInDic("DL9") // Suavização
							PlnDmdTran(TVgGetPlnD(M->DTW_FILORI,M->DTW_VIAGEM),  '7') // Planejamento de Demandas = "Em Trânsito"
						EndIf
					EndIf
				Endif

			EndIf
			//-- Atividade de Saida para retirada do Reboque
			If M->DTW_ATIVID == cAtivRDP
				DF7->(DbSetOrder(2)) //DF7_FILIAL+DF7_FILORI+DF7_VIAGEM
				If DF7->(MsSeek(xFilial('DF7') + M->(DTW_FILORI+DTW_VIAGEM)))
					RecLock('DF7',.F.)
					DF7->DF7_STATUS := StrZero(2,Len(DF7->DF7_STATUS))
					MsUnLock()
					If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
						DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
						If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILDTR+DF7_VGEDTR) + cAtivSai))
							If !lRecursivo
								TMSA350Grv(3, DF7->DF7_FILDTR, DF7->DF7_VGEDTR, cAtivSai, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
							EndIf
						EndIf
					EndIf
				EndIf
				//-- Atualizar status do 2o.cavalo para em viagem.
				TMSStatVei(cFilOri,cViagem,nOpcx,cAtivSai,1)
			EndIf
			//-- Atividade de Saida de Viagem
			If M->DTW_ATIVID == cAtivSai
				DF7->(DbSetOrder(3)) //DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
				If DF7->(MsSeek(xFilial('DF7') + M->(DTW_FILORI+DTW_VIAGEM)))
					DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILORI+DF7_VIAGEM) + cAtivRDP))
						If !lRecursivo
							TMSA350Grv(3, DF7->DF7_FILORI, DF7->DF7_VIAGEM, cAtivRDP, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Atividade de Retorno do Porto
			If M->DTW_ATIVID == cAtivRTP
				DF7->(DbSetOrder(3))  //DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
				If DF7->(MsSeek(xFilial('DF7') + M->(DTW_FILORI+DTW_VIAGEM)))
					DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILORI+DF7_VIAGEM) + cAtivChg))
						If !lRecursivo
							TMSA350Grv(3, DF7->DF7_FILORI, DF7->DF7_VIAGEM, cAtivChg, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
						EndIf
					EndIf
				EndIf
				//-- Atualizar status do 1o.cavalo para em filial.
				TMSStatVei(cFilOri,cViagem,nOpcx,cAtivChg,1)
			EndIf
			//-- Atividade de Chegada de Viagem
			If M->DTW_ATIVID == cAtivChg
				DF7->(DbSetOrder(2)) //DF7_FILIAL+DF7_FILORI+DF7_VIAGEM
				If DF7->(MsSeek(xFilial('DF7') + M->(DTW_FILORI+DTW_VIAGEM)))
					If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
						DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
						If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILDTR+DF7_VGEDTR) + cAtivRTP))
							If !lRecursivo
								TMSA350Grv(3, DF7->DF7_FILDTR, DF7->DF7_VGEDTR, cAtivRTP, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
							EndIf
						EndIf
					EndIf
				EndIf
				//-- Atualiza a Data Fim na Viagem.
				DTQ->( dbSetOrder( 2 ) )
				If DTQ->( MsSeek( xFilial('DTQ') + M->DTW_FILORI + M->DTW_VIAGEM ) )
					RecLock( "DTQ", .F. )
					DTQ->DTQ_DATFIM := dDatRea
					DTQ->DTQ_HORFIM := cHorRea
					MsUnlock()
				EndIf
				
				TM350OcoAt(cFilOri, cViagem, nOpcx)
			EndIf
			//-- Atividade da Inspecao de Veiculos
			If lMntTms
				If M->DTW_ATIVID == cAtivIsp
					lRet := TMSIntMnt( "1", cSerIsp, M->DTW_FILORI, M->DTW_VIAGEM, , ,@aFolder)
					If lRet
						TmsMntGrOs( "1",cSerIsp, @aFolder )
					Else
						DisarmTransaction()
					EndIf
				EndIf
			EndIf
			If lAptJor .And. lRet
				If M->DTW_ATIVID == cAtivREF .Or. M->DTW_ATIVID == cAtivDES .Or. M->DTW_ATIVID == cAtivChg .Or. M->DTW_ATIVID == cAtivSai
					//-- Apontamento do motorista
					TMSA350Apt(cFilOri, cViagem, nOpcx, M->DTW_ATIVID, dDatIni, cHorIni, dDatRea, cHorRea )

				ElseIf M->DTW_ATIVID == cAtivDca //-- Descarregamento
					
					//-- Apontamento do motorista
					TMSA350Apt(cFilOri, cViagem, nOpcx, M->DTW_ATIVID, dDatIni, cHorIni, dDatRea, cHorRea )
					
					//-- Atualiza tempo de espera da jornada de trabalho para o caso do tempo da jornada ter excedido.
					cIteDTR := Posicione('DTR',1,xFilial('DTR')+cFilOri+cViagem,'DTR_ITEM')
					cCodMot := Posicione('DUP',1,xFilial('DUP')+cFilOri+cViagem+cIteDTR,'DUP_CODMOT')
					AO35AtuSal( cCodMot, dDatIni )
				EndIf
			EndIf

		EndIf
		If Empty( dDatRea ) .And. Empty( cHorRea )
			// Nao chama novamente a tela de inclusao.
			MBRCHGLoop()
		EndIf

		// Envia Mensagem de apontamento de Operação se a atividade apontada for de saída da viagem
		// E se o TMS estiver integrado com o ERp Datasul
		DTQ->( dbSetOrder( 2 ) )
		If DTQ->( MsSeek( xFilial('DTQ') + M->DTW_FILORI + M->DTW_VIAGEM ) ) .And. DTQ->DTQ_SERTMS <> '1'
			If lRet .And. cTmsErp == '1' .And. M->DTW_ATIVID == cAtivSai .And. FwHasEAI(cAdapter,.T.,,.T.)
				AEAIRET:= FwIntegDef(cAdapter,,,,cAdapter) // Chama Adapter + função IntegDef abaixo para envio de mensagem unica
				If !(lRet := IIf(ValType(aEAIRET) == "U",.F.,aEAIRET[1]))
					Help("", 1,'TMSA35035',, CHR(10)+CHR(13)+CHR(13) + CHR(10) +aEAIRET[2],4,1)// 'Falha na Integração'
				EndIf
			EndIf
		EndIf

	ElseIf nOpcx == 5 //-- Estorno

		DEFAULT cAtividade := DTW->DTW_ATIVID
		DEFAULT dDatIni    := DTW->DTW_DATINI
		DEFAULT cHorIni    := DTW->DTW_HORINI
		DEFAULT dDatRea    := DTW->DTW_DATREA
		DEFAULT cHorRea    := DTW->DTW_HORREA

		If lRet .And. AliasInDic("DN1")
			lRet := VldColEnt( nOpcx, cAtividade, cFilOri, cViagem, @nRecDN5 )
		EndIf
		
		lVgeAtvApo:= .F.			
		If lRet
			If !Empty(cAtvSaiApo)
				If ExistFunc('TM350AtvPA')
					lVgeAtvApo := TM350AtvPA(cFilOri, cViagem )  //Verifica se existe a operação de saida de apoio na Viagem
				EndIf
			EndIf

			//-- Exclui a operacao eventual
			If	DTW->DTW_FILATI == cFilAnt .And. DTW->DTW_CATOPE == StrZero(2,Len(DTW->DTW_CATOPE))

				//-- Deletar a operacao de Chegada de Viagem Eventual e a operacao de Saida de Viagem Eventual
				If cAtividade == cAtivChg
					If Empty( aDoc )
						TMSVerMov( cFilOri, cViagem,,,, lDocBlq , @aDoc, .F. , .T. )
					EndIf

					DUD->(DbSetOrder(1)) //DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM

					For nA := 1 To Len( aDoc )
						//-- Caso exista o Doc na filial atual.
						lAchouDUD := DUD->( MsSeek(xFilial("DUD") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] + cFilAtu ) )

						If lAchouDUD .And. !Empty(DUD->DUD_VIAGEM) .And. (DUD->DUD_VIAGEM <> cViagem) .And. !(DUD->DUD_STATUS $ cStatus)
							Help("", 1,'TMSA35026',, DUD->(DUD_VIAGEM+" - "+DUD_FILDOC+"-"+DUD_DOC+"/"+DUD_SERIE)  ,4,1)// 'Ja existe outra Viagem registrada para esse Documento!'
							lRet := .F.
							Exit
						EndIf
					Next

					If lRet
						// Estorna movimento
						TMSMovViag( cFilOri, cViagem, cAtividade , , , 5 )

						RecLock('DTW',.F.)
						DTW->(DbDelete())
						MsUnLock()
						//-- Apaga no DTW a operacao de Saida de Viagem Eventual.
						DTW->(dbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
						If DTW->(MsSeek(cSeek := xFilial("DTW") + cFilOri + cViagem + cAtivSai + cFilAnt))
							//-- Varre o DTW para apagar a Saida de Viagem Eventual. Isto porque, ao estornar uma
							//-- Chegada de Viagem 'Eventual' na Filial Origem, o sistema tem que ignorar a
							//-- Saida de Viagem 'Prevista', e apagar somente a Saida de Viagem 'Eventual'
							Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI) == cSeek
								If ( DTW->DTW_CATOPE == StrZero(2,Len(DTW->DTW_CATOPE)) .And. DTW->(DTW_SEQUEN) > cUltSeq ) // Saida de viagem 'Eventual'
									RecLock('DTW',.F.)
									DTW->(DbDelete())
									MsUnLock()
								EndIf
								DTW->(dbSkip())
							EndDo
						EndIf
						TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)
					EndIf
				ElseIf cAtividade == cAtivSai

					RecLock('DTW',.F.)
					DTW->DTW_DATINI := Ctod('')
					DTW->DTW_HORINI := Space(Len(DTW->DTW_HORINI))
					DTW->DTW_DATREA := Ctod('')
					DTW->DTW_HORREA := Space(Len(DTW->DTW_HORREA))
					If DTW->(ColumnPos("DTW_SYSDAT")) > 0
						DTW->DTW_SYSDAT := Ctod('')
					EndIf
					If DTW->(ColumnPos("DTW_SYSHOR")) > 0
						DTW->DTW_SYSHOR := Space(Len(DTW->DTW_SYSHOR))
					EndIf
					DTW->DTW_STATUS := StrZero(1, Len(DTW->DTW_STATUS))
					If lIDMPos
						DTW->DTW_IDMPOS := Space(Len(DTW->DTW_IDMPOS))
					EndIf
					MsUnLock()

					// Altera o Status da Viagem para Chegada em Filial
					DTQ->(DbSetOrder(1))
					DTQ->(MsSeek(xFilial('DTQ') + cViagem ))
					RecLock("DTQ", .F.)
					DTQ->DTQ_STATUS := StrZero( 4, Len( DTQ->DTQ_STATUS ) ) //-- Chegada em Filial
					MsUnLock()

					//Altera o Status dos documentos que foram incluídos
					DUD->(DbSetOrder(2))
					DUD->(MsSeek(xFilial('DUD') + cFilOri + cViagem ))
					While DUD->(!Bof()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) ==  xFilial("DTW") + cFilOri + cViagem
						If ( DUD->DUD_DOCTRF == "1" )
							RecLock("DUD", .F.)
							DUD->DUD_STATUS := StrZero(3,Len(DUD->DUD_STATUS)) //-- Carregado
							MsUnLock()
							//Altera o Status da DT6 para documentos que foram incluídos
							DT6->(DbSetOrder(1))
							DT6->(MsSeek(xFilial('DT6') + DUD->DUD_FIlDOC + DUD->DUD_DOC + DUD->DUD_SERIE ))
							RecLock("DT6", .F.)
							DT6->DT6_STATUS := StrZero(2,Len(DT6->DT6_STATUS)) //-- Carregado
							MsUnLock()
						EndIf
						DUD->(dbSkip())
					EndDo
					TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)

				ElseIf (cAtividade == cAtvSaiCli .Or. cAtividade == cAtvSaiApo) .AND. DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS))  
					// Realiza o estorno da operação de Saida de Cliente.
					lRet := A350EstSaC(cFilOri, cViagem) 

				ElseIf (cAtividade == cAtvChgCli .Or. cAtividade == cAtvChgApo)
					//Lógica criada a fim de verificar se a atividade de Saída de Cliente está apontada.
					//Caso esteja, não será permitido o estorno da atividade de Chegada de Cliente.
					cCodCli := DTW->DTW_CODCLI
					cLojCli := DTW->DTW_LOJCLI
					cCatOpe := DTW->DTW_CATOPE
					aAreaDTW := DTW->( GetArea() )
					DTW->(dbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					DTW->(MsSeek(cSeek := xFilial("DTW") + cFilOri + cViagem + Iif(lVgeAtvApo,cAtvSaiApo,cAtvSaiCli) + cFilAnt))
					
					Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM + DTW_ATIVID + DTW_FILATI) == cSeek
						If DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS)) .And. DTW->DTW_CODCLI == cCodCli .And. DTW->DTW_LOJCLI == cLojCli .And. DTW->DTW_CATOPE == cCatOpe 
							Help("", 1, "TMSA35039", , STR0067 + " " + AllTrim(cCodCli) + "/" + AllTrim(cLojCli) + " " + STR0068, 4, 1) // TMSA35039 - Estorno de chegada em cliente não permitido. // O estorno de chegada no cliente "XXXXXX/99" não pode ser efetuado, pois a saída deste mesmo cliente está apontada.
							lRet := .F.
							Exit
						EndIf
						DTW->(dbSkip())
					EndDo
					RestArea(aAreaDTW)

					If lRet
						RecLock('DTW',.F.)
						DTW->DTW_DATINI := Ctod('')
						DTW->DTW_HORINI := Space(Len(DTW->DTW_HORINI))
						DTW->DTW_DATREA := Ctod('')
						DTW->DTW_HORREA := Space(Len(DTW->DTW_HORREA))
						If DTW->(ColumnPos("DTW_SYSDAT")) > 0
							DTW->DTW_SYSDAT := Ctod('')
						EndIf
						If DTW->(ColumnPos("DTW_SYSHOR")) > 0
							DTW->DTW_SYSHOR := Space(Len(DTW->DTW_SYSHOR))
						EndIf
						DTW->DTW_STATUS := StrZero(1, Len(DTW->DTW_STATUS))
						DTW->DTW_IDMPOS := Space(Len(DTW->DTW_IDMPOS))

						MsUnLock()

						// Altera o Status da Viagem para Viagem em Trânsito
						DTQ->(DbSetOrder(1))
						DTQ->(MsSeek(xFilial('DTQ') + cViagem ))
						RecLock("DTQ", .F.)
						DTQ->DTQ_STATUS := StrZero( 2, Len( DTQ->DTQ_STATUS ) ) //-- Viagem em Trânsito
						MsUnLock()
					EndIf
				EndIf

			//-- Deixa a operacao prevista em aberto
			Else
				IF cAtividade == cAtivChg
					If Empty( aDoc )
						TMSVerMov( cFilOri, cViagem,,,, lDocBlq , @aDoc, .F. , .T. )
					EndIf

					DUD->( DbSetOrder(1) )

					For nA := 1 To Len( aDoc )
						//-- Caso exista o Doc na filial atual.
						lAchouDUD := DUD->( MsSeek(xFilial("DUD") + aDoc[nA][1] + aDoc[nA][2] + aDoc[nA][3] + cFilAtu ) )

						If lAchouDUD .And. !Empty(DUD->DUD_VIAGEM) .And. (DUD->DUD_VIAGEM <> cViagem) .And. !(DUD->DUD_STATUS $ cStatus)
							Help("", 1,'TMSA35026',, DUD->(DUD_VIAGEM+" - "+DUD_FILDOC+"-"+DUD_DOC+"/"+DUD_SERIE)  ,4,1)// 'Ja existe outra Viagem registrada para esse Documento!'
							lRet := .F.
							Exit
						EndIf
					Next
					If lRet
						TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)
					EndIf
				ElseIf (cAtividade == cAtvSaiCli .Or. cAtividade == cAtvSaiApo) .AND. DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS))
					// Realiza o estorno da operação de Saida de Cliente.
					lRet := A350EstSaC(cFilOri, cViagem)
					
				ElseIf (cAtividade == cAtvChgCli .Or. cAtividade == cAtvChgApo)
					//Lógica criada a fim de verificar se a atividade de Saída de Cliente está apontada.
					//Caso esteja, não será permitido o estorno da atividade de Chegada de Cliente.
					cCodCli := DTW->DTW_CODCLI
					cLojCli := DTW->DTW_LOJCLI
					cCatOpe := DTW->DTW_CATOPE
					aAreaDTW := DTW->( GetArea() )
					DTW->(dbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					DTW->(MsSeek(cSeek := xFilial("DTW") + cFilOri + cViagem + Iif(lVgeAtvApo,cAtvSaiApo,cAtvSaiCli) + cFilAnt))
					
					Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM + DTW_ATIVID + DTW_FILATI) == cSeek
						If DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS)) .And. DTW->DTW_CODCLI == cCodCli .And. DTW->DTW_LOJCLI == cLojCli .And. DTW->DTW_CATOPE == cCatOpe
							Help("", 1, "TMSA35039", , STR0067 + " " + AllTrim(cCodCli) + "/" + AllTrim(cLojCli) + " " + STR0068, 4, 1) // TMSA35039 - Estorno de chegada em cliente não permitido. // O estorno de chegada no cliente "XXXXXX/99" não pode ser efetuado, pois a saída deste mesmo cliente está apontada.
							lRet := .F.
							Exit
						EndIf
						DTW->(dbSkip())
					EndDo
					RestArea(aAreaDTW)				
				EndIf
				If lRet
					RecLock('DTW',.F.)
					DTW->DTW_DATINI := Ctod('')
					DTW->DTW_HORINI := Space(Len(DTW->DTW_HORINI))
					DTW->DTW_DATREA := Ctod('')
					DTW->DTW_HORREA := Space(Len(DTW->DTW_HORREA))
					If DTW->(ColumnPos("DTW_SYSDAT")) > 0
						DTW->DTW_SYSDAT := Ctod('')
					EndIf
					If DTW->(ColumnPos("DTW_SYSHOR")) > 0
						DTW->DTW_SYSHOR := Space(Len(DTW->DTW_SYSHOR))
					EndIf
					DTW->DTW_STATUS := StrZero(1, Len(DTW->DTW_STATUS))
					If DTW->(FieldPos('DTW_FILATU')) > 0
						DTW->DTW_FILATU := DTW->DTW_FILORI
					EndIf
					If lIDMPos
						DTW->DTW_IDMPOS := Space(Len(DTW->DTW_IDMPOS))
					EndIf
					MsUnLock()

					//-- Limpa a Data Inicio e Fim e Hora Inicio e Fim da Viagem.
					DTQ->(DbSetOrder(1))
					DTQ->(MsSeek(xFilial('DTQ') + cViagem ))
					RecLock("DTQ", .F.)
					If cAtividade == cAtivSai
						DTQ->DTQ_DATINI := Ctod("")
						DTQ->DTQ_HORINI := Space( Len( DTQ->DTQ_HORINI ) )
					ElseIf cAtividade == cAtivChg
						DTQ->DTQ_DATFIM := Ctod("")
						DTQ->DTQ_HORFIM := Space( Len( DTQ->DTQ_HORFIM ) )
					EndIf
					MsUnLock()
					iF ExistFunc("TMSOcoAut")
						TMSOcoAut(cFilOri, cViagem, nOpcx)
					Endif
					If cAtividade == cAtivSai .Or. cAtividade == cAtivChg
						//-- Verifica se a atividade da chegada de viagem eh alianca.
						If	cAtividade == cAtivChg
							cFilAli := Posicione("DVL",1,xFilial("DVL")+DTW->DTW_FILATI,"DVL_FILALI")
							If !Empty(cFilAli)
								cFilAtu := cFilAli
							EndIf
						ElseIf cAtividade == cAtivSai
							TMSStatVei(cFilOri,cViagem,nOpcx,cAtividade)
						EndIf
						// Estorna movimento
						TMSMovViag( cFilOri, cViagem, cAtividade,,,5,,cFilAtu)
						//-- Estorno das ocorrencias informativas para doc. de redespacho.
						If cAtivChg == cAtividade .And. DTQ->DTQ_SERTMS == "3" .And. DTQ->DTQ_TIPVIA == "5"
							lRet:= TMSA350Red(nOpcx)
							If !lRet
								DisarmTransaction()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			//-- Se o parametro MV_CONTVEI estiver desabilitado
			If !lContVei
				//-- Atualiza DUV (Registro de Entrada / Saida de Veiculos)
				DUV->(dbSetOrder(1))
				If cAtividade == cAtivSai// Saida de Viagem
					DUV->(MsSeek(cSeek := xFilial("DUV")+DTW->DTW_FILORI+DTW->DTW_VIAGEM))
					Do While !DUV->(Eof()) .And. DUV->(DUV_FILIAL+DUV->DUV_FILORI+DUV->DUV_VIAGEM) == cSeek
						If !Empty(DUV->DUV_FILSAI) .And. DUV->DUV_FILSAI == cFilAnt
							If lMntTms
								cCodBem := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODVEI,"DA3_CODBEM")		// Bem Dai
								If !Empty(cCodBem)
									nCntBem := Posicione("ST9",1,xFilial("ST9")+cCodBem,"T9_POSCONT")			// Contador Bem Pai
								EndIf
								If !Empty(DUV->DUV_CODRB1)
									cBemRb1 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB1,"DA3_CODBEM")	//Bem Filho1
									If !Empty(cBemRb1)
										nCntRb1 := Posicione("ST9",1,xFilial("ST9")+cBemRb1,"T9_POSCONT")		//Contador Bem Filho1
									EndIf
								EndIf
								If !Empty(DUV->DUV_CODRB2)
									cBemRb2 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB2,"DA3_CODBEM")	//Bem Filho2
									If !Empty(cBemRb2)
										nCntRb2 := Posicione("ST9",1,xFilial("ST9")+cBemRb2,"T9_POSCONT")		//Bem Filho2
									EndIf
								EndIf
								If lTercRbq
									If !Empty(DUV->DUV_CODRB3)
										cBemRb3 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB3,"DA3_CODBEM")	//Bem Filho3
										If !Empty(cBemRb3)
											nCntRb3 := Posicione("ST9",1,xFilial("ST9")+cBemRb3,"T9_POSCONT")		//Contador Bem Filho3
										EndIf
									EndIf
								EndIf
								cHora := Left(DUV->DUV_HORSAI,2) + ":" + SubStr(DUV->DUV_HORSAI,3,2)			// Hora da Movimentação
								dData := DUV->DUV_DATSAI														// Data da Movimentação
								//-- Funcao para Desmontar a Estrutura - Integracao TMS X MNT (Manutencao de Ativos)
								If TMSAtuMnt(DUV->DUV_CODVEI,DUV->DUV_CODRB1,DUV->DUV_CODRB2,nCntBem,nCntRb1,nCntRb2,2,dData,cHora,.T.,Iif(lTercRbq,DUV->DUV_CODRB3,.F.),Iif(lTercRbq,nCntRb3,.F.),aTrbEst)
									RecLock("DUV", .F.)
									DUV->(dbDelete())
									DUV->(MsUnLock())
								Else
									DisarmTransaction()
								EndIf
							Else
								RecLock("DUV", .F.)
								DUV->(dbDelete())
								DUV->(MsUnLock())
							EndIf
						EndIf
						DUV->(dbSkip())
					EndDo
				ElseIf cAtividade == cAtivChg // Chegada de Viagem
					DUV->(dbSetOrder(1))
					DUV->(MsSeek(cSeek := xFilial("DUV")+DTW->DTW_FILORI+DTW->DTW_VIAGEM))
					// Atualiza DUV (Registro de Entrada / Saida de Veiculos)
					Do While !DUV->(Eof()) .And. DUV->(DUV_FILIAL+DUV->DUV_FILORI+DUV->DUV_VIAGEM) == cSeek
						If !Empty(DUV->DUV_FILENT)
							If lMntTms
								cCodBem := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODVEI,"DA3_CODBEM")
								If !Empty(cCodBem)
									nCntBem := Posicione("ST9",1,xFilial("ST9")+cCodBem,"T9_POSCONT")
								EndIf
								If !Empty(DUV->DUV_CODRB1)
									cBemRb1 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB1,"DA3_CODBEM")
									If !Empty(cBemRb1)
										nCntRb1 := Posicione("ST9",1,xFilial("ST9")+cBemRb1,"T9_POSCONT")
									Endif
								EndIf
								If !Empty(DUV->DUV_CODRB2)
									cBemRb2 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB2,"DA3_CODBEM")
									If !Empty(cBemRb2)
										nCntRb2 := Posicione("ST9",1,xFilial("ST9")+cBemRb2,"T9_POSCONT")
									EndIf
								EndIf
								If lTercRbq
									If !Empty(DUV->DUV_CODRB3)
										cBemRb3 := Posicione("DA3",1,xFilial("DA3")+DUV->DUV_CODRB3,"DA3_CODBEM")
										If !Empty(cBemRb3)
											nCntRb3 := Posicione("ST9",1,xFilial("ST9")+cBemRb3,"T9_POSCONT")
										EndIf
									EndIf
								EndIf
								cHora := Left(DUV->DUV_HORENT,2) + ":" + SubStr(DUV->DUV_HORENT,3,2)
								dData := DUV->DUV_DATENT
								//-- Funcao para Montar a Estrutura - Integracao TMS X MNT (Manutencao de Ativos)
								If TMSAtuMnt(DUV->DUV_CODVEI,DUV->DUV_CODRB1,DUV->DUV_CODRB2,nCntBem,nCntRb1,nCntRb2,1,@dData,@cHora,.T.,Iif(lTercRbq,DUV->DUV_CODRB3,.F.),Iif(lTercRbq,nCntRb3,.F.),aTrbEst)
									RecLock("DUV", .F.)
									DUV->DUV_FILENT := CriaVar("DUV_FILENT", .F.)
									DUV->DUV_ODOENT := 0
									DUV->(MsUnLock())
								Else
									DisarmTransaction()
								EndIf
							Else
								RecLock("DUV", .F.)
								DUV->DUV_FILENT := CriaVar("DUV_FILENT", .F.)
								DUV->DUV_ODOENT := 0
								DUV->(MsUnLock())
							EndIf
						EndIf
						DUV->(dbSkip())
					EndDo
				EndIf
			EndIf
			//-- Atividade de Saida para retirada do Reboque
			If DTW->DTW_ATIVID == cAtivRDP
				DF7->(DbSetOrder(2)) //DF7_FILIAL+DF7_FILORI+DF7_VIAGEM
				If DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
					RecLock('DF7',.F.)
					DF7->DF7_STATUS := StrZero(1,Len(DF7->DF7_STATUS))
					MsUnLock()

					If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
						DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
						If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILDTR+DF7_VGEDTR) + cAtivSai))
							If !lRecursivo
								TMSA350Grv(5, DF7->DF7_FILDTR, DF7->DF7_VGEDTR, cAtivSai, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Atividade de Saida de Viagem
			If DTW->DTW_ATIVID == cAtivSai
				DF7->(DbSetOrder(3)) //DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
				If DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
					DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILORI+DF7_VIAGEM) + cAtivRDP))
						If !lRecursivo
							TMSA350Grv(5, DF7->DF7_FILORI, DF7->DF7_VIAGEM, cAtivRDP, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Atividade de Retorno do Porto
			If DTW->DTW_ATIVID == cAtivRTP
				DF7->(DbSetOrder(3))  //DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
				If DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
					DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
					If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILORI+DF7_VIAGEM) + cAtivChg))
						If !lRecursivo
							TMSA350Grv(5, DF7->DF7_FILORI, DF7->DF7_VIAGEM, cAtivChg, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Atividade de Chegada de Viagem
			If DTW->DTW_ATIVID == cAtivChg
				DF7->(DbSetOrder(2)) //DF7_FILIAL+DF7_FILORI+DF7_VIAGEM
				If DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
					If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
						DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
						If DTW->(MsSeek(xFilial('DTW') + DF7->(DF7_FILDTR+DF7_VGEDTR) + cAtivRTP))
							If !lRecursivo
								TMSA350Grv(5, DF7->DF7_FILDTR, DF7->DF7_VGEDTR, cAtivRTP, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""), .T.,,,aTrbEst)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//-- Atividade da Inspecao de Veiculos
			If DTW->DTW_ATIVID == cAtivIsp
				If lExeIntMnt
					If lMntTms
						TmsMntEsOs('1',DTW->DTW_FILORI,DTW->DTW_VIAGEM)
					EndIf
				EndIf
			EndIf

			//Estorna apontamento do motorista
			If lAptJor
				If cAtividade == cAtivREF .Or.  cAtividade == cAtivDES .Or.  cAtividade == cAtivChg .Or.  cAtividade == cAtivSai
					//-- Apontamento do motorista
					TMSA350Apt(cFilOri, cViagem, nOpcx,  cAtividade, dDatIni, cHorIni, dDatRea, cHorRea )

				ElseIf cAtividade == cAtivDca //-- Descarregamento
					
					//-- Apontamento do motorista
					TMSA350Apt(cFilOri, cViagem, nOpcx,  cAtividade, dDatIni, cHorIni, dDatRea, cHorRea )
					
					//-- Atualiza tempo de espera da jornada de trabalho para o caso do tempo da jornada ter excedido.
					cIteDTR := Posicione('DTR',1,xFilial('DTR')+cFilOri+cViagem,'DTR_ITEM')
					cCodMot := Posicione('DUP',1,xFilial('DUP')+cFilOri+cViagem+cIteDTR,'DUP_CODMOT')
					AO35AtuSal( cCodMot, dDatIni )
				EndIf
			EndIf

		EndIf
		DTQ->( dbSetOrder( 2 ) )
		If DTQ->( MsSeek( xFilial('DTQ') + DTW->DTW_FILORI + DTW->DTW_VIAGEM ) ) .And. DTQ->DTQ_SERTMS <> '1'
			If lRet .And. cTmsErp == '1' .And. cAtividade == cAtivSai .And. FwHasEAI(cAdapter,.T.,,.T.)
				AEAIRET:= FwIntegDef(cAdapter,,,,cAdapter) // Chama Adapter + função IntegDef abaixo para envio de mensagem unica
				If !(lRet := IIf(ValType(aEAIRET) == "U",.F.,aEAIRET[1]))
					Help("", 1,'TMSA35035',, CHR(10)+CHR(13)+CHR(13) + CHR(10) +aEAIRET[2],4,1)// 'Falha na Integração'
				EndIf
			EndIf
		EndIf
	EndIf

	If lTMSIntChk	//-- Existe Check List configurado e existe a função de busca de documentos
		If (lIntChkSai .And. cAtividade == cAtivSai ) .Or. cAtividade == cAtvSaiApo .Or. cAtividade == cAtvSaiCli //a integração é no apontamento de saida da viagem ou complementar no apontamento de saida de celinte ou ponto de apoio
			DTQ->(DbSetOrder(2))
			If DTQ->(MsSeek(xFilial("DTQ") + cFilOri + cViagem)) .And. (DTQ->DTQ_SERTMS == "1" .Or. DTQ->DTQ_SERTMS == "3")
				If cAtividade == cAtvSaiApo .Or. cAtividade == cAtvSaiCli
					aSaiApoio := DTW->( {DTW_CODCLI,DTW_LOJCLI} )
				Else
					aSaiApoio := {}
				EndIf
				If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA)) .Or. DTQ->DTQ_TIPTRA == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario ou Rodoviario Internacional
					//-- Busca os documentos da viagem
					aDocsChk := TMSLstChk( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, , , , , aSaiApoio )
					//--Apontamento da Operação.
					If nOpcx == 3
						//-- Envia Check List
						aMsgChk := {}
						aRetEnv := TMSEnvChk( Aclone(aDocsChk), DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgChk, @aReenvC, Len(aSaiApoio) > 0 )
		
						If !Empty(aMsgChk)
							TmsMsgErr( aMsgChk, , , .T., AClone(aReenvC) )
						EndIf
						FwFreeArray(aMsgChk)
						FwFreeArray(aDocsChk)
						FwFreeArray(aReenvC)
					EndIf
					//-- Estorno da Operação
					If nOpcx == 5
						EstDocChk( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, Len(aSaiApoio) > 0 )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If AliasInDic("DN1") .And. FindFunction( "TM310PrcOp" )
		TM310PrcOp(nOpcx,cAtividade)
	EndIf

EndIf

If lRet .And. lTM350GRV
	lRet := ExecBlock('TM350GRV',.F.,.F.,{cFilOri, cViagem, nOpcx, cAtividade})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Est³ Autor ³ Alex Egydio           ³ Data ³20.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorno de operacoes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Est( cAlias, nReg, nOpcx, lViagem )

Local aAreaDTW	  	:= DTW->( GetArea() )
Local cFilOri	  	:= DTW->DTW_FILORI
Local cViagem	  	:= DTW->DTW_VIAGEM
Local cAtividade  	:= DTW->DTW_ATIVID
Local cStatus	  	:= StrZero( 2, Len( DTW->DTW_STATUS ) )				//-- Somente operacoes encerradas serao estornadas
Local nOpca		  	:= 0
Local cAtivChg	  	:= GetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtivSai	  	:= GetMV('MV_ATIVSAI',,'') //-- Atividade de Saida de Viagem
Local cAtivDca	  	:= GetMV('MV_ATIVDCA',,'') //-- Atividade de Descarregamento
Local cAtivRta	  	:= GetMV('MV_ATIVRTA',,'') //-- Atividade de retorno do aeroporto
Local cAtivRtp	  	:= GetMV('MV_ATIVRTP',,'') //-- Atividade de Retorno do Porto
Local cAtivCHP    	:= GetMv('MV_ATIVCHP',,'') //-- Atividade de Chegada do reboque no destino
Local lContVei    	:= GetMV('MV_CONTVEI',,.T.)//-- Controla Motoristas / Veiculos ?
Local lEncerrada 	:= .T.
Local lVgeInter   	:= .F.
Local lTMSOPdg    	:= AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local aMsgErr     	:= {}
Local cEncRepom  	:= SuperGetMV('MV_ENREPOM',,"1")  //-- Encerra Repom pela Ocorrencia = 2 / Rotina de Encerramento = 1
Local nPCanOp     	:= SuperGetMv('MV_PCANOP',,1) // Opcoes para o cancelamento de operacoes de transportes.
Local lEventual   	:= .F.
Local lChgEvent   	:= .F.
Local lRet        	:= .T.
Local lFrotaProp	:= .F.
Local cFilDes		:= ""
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()
Local lTMS3GFE       := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local lIntGFE		:= .F.
Local cLockKeyVG    := "OCORXOPER"+DTQ->DTQ_VIAGEM
Local lContinua     := .T.
Local aAreaSM0	:= SM0->(GetArea())
Local cFilBack	:= cFilAnt	
Local lMDFEAUT	:= SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático
Local oStructDTW	:= Nil
Local aFldsDTW		:= {}
Local aFldsDTWNot	:= {"DTW_SYSDAT", "DTW_SYSHOR"}
Local nI			:= 0
Local nMdfeExc      := SuperGetMv("MV_MDFEEXC", .F., 0   ) //-- Prazo em horas para cancelamento do MDF-e autorizado
Local nHoras		:= 0
Local lUFAtiv     	:= DTX->(ColumnPos("DTX_UFATIV")) > 0
Local lIdDTW        := DTW->(ColumnPos("DTW_IDDTW")) > 0
Local lMntTms   	:= (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
//Variáveis SIGAMNT necessárias para garantir controle de transação com banco Oracle
Local cTRBF      	:= GetNextAlias()
Local cTRBS      	:= GetNextAlias()
Local CTRBEixo   	:= GetNextAlias()
Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local cAtvSaiApo    := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local lDTX_SERMAN 	:= DTX->(FieldPos("DTX_SERMAN")) > 0
Local lPagBem  		:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

If ValType(lViagem) == "L"
	lVgeInter := lViagem
EndIf

If Type("aRotina") == "U"
	Private aRotina := MenuD350()
EndIf

If Type("cCadastro") == "U"
	Private cCadastro := STR0001 //'Operacoes de Transporte'
EndIf

nOpcx := aRotina[ nOpcx, 4 ]

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,DTY->DTY_VIAGEM,)
	Return .F.
EndIf

If Empty(DTW->DTW_VIAGEM)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help("",1,"TMSA35033") //"Não existem registros para efetuar o apontamento/estorno das operacoes."
	RestArea( aAreaDTW )
	MsUnLockAll()
	Return( .F. )
EndIf

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
If !SoftLock("DTW")
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Return( Nil )
EndIf

/* Verifica se o registro n„o est  em uso por outra esta‡„o. */
DTQ->(DbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA
If DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem))
	If !SoftLock("DTQ")
		RestArea( aAreaDTW )
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( Nil )
	EndIf
EndIf

If DTW->DTW_STATUS <> StrZero(2,Len(DTW->DTW_SERTMS)) //-- Encerrada
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help("",1,"TMSA35017") // "Manutencao permitida somente para operacoes encerradas"
	RestArea( aAreaDTW )
	MsUnLockAll()
	Return( .F. )
EndIf

If ! TMSChkViag( cFilOri, cViagem, .F., .F., .F.,,,,,,,,, lEncerrada )
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	RestArea( aAreaDTW )
	MsUnLockAll()
	Return( .F. )
EndIf


If ( !Empty(DTW->DTW_FILATI) .And. DTW->DTW_FILATI <> cFilAnt ) .And. ;
	!( DTW->DTW_FILORI == cFilAnt .And. !Empty(Posicione("DVL",1,xFilial("DVL")+DTW->DTW_FILATI,"DVL_FILALI")) ) //-- filial parceiro (alianca)
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
	Help('',1,'TMSA35010') //O Estorno Nao sera Efetuado pois a Filial de Atividade desta Operacao e diferente da Filial Atual.
	RestArea( aAreaDTW )
	MsUnLockAll()
	Return( .F. )
EndIf

If	DUD->(FieldPos('DUD_FILATU'))>0 .And. DTW->DTW_ATIVID == cAtivChg
	DbSelectArea ("DUD")
	If DTW->DTW_SERTMS == StrZero(2, Len(DTW->DTW_SERTMS)) .And. TmsA350Doc(cFilOri,cViagem,cAtivChg,Tabela('L3',cAtivChg,.F.))
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		RestArea( aAreaDTW )
		MsUnLockAll()
		Return( .F. )
	EndIf
EndIf

If DTW->DTW_ATIVID == cAtivCHP
	DF7->(DbSetOrder(2)) //DF7_FILIAL+DF7_FILORI+DF7_VIAGEM
	If DF7->(MsSeek(xFilial('DF7') + DTW->(DTW_FILORI+DTW_VIAGEM)))
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help('',1,'TMSA35025') //-- 'Existe lancamento para retirada do reboque no porto para esta viagem'
		Return( .F. )
	EndIf
EndIf

If lTMA350EST
	lRet := ExecBlock('TMA350EST',.F.,.F.,{nOpcx})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf

	If !lRet
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Return( .F. )
	EndIf
EndIf

If DTW->DTW_ATIVID == cAtivSai .AND. TableIndic("DM0") .And. SuperGetMV("MV_TMAPCKL",,.F.) .And. SuperGetMV("MV_TMINTEV",,"") == "2" .And. ExistFunc("TMSIntChk") .AND. ExistFunc("TMHVerFin")
	lRet := TMHVerFin( cFilOri, cViagem )
	If !lRet
		Help( "", 1, 'TMSA350Grv', , STR0077, 1, 0, , , , , , { STR0078 } ) //STR0077 "Não é possivel estornar apontamento, esta viagem já possui documentos entregues apontados pelo Aplicativo Meu Checklist." STR0078 "Caso seja necessario estornar o apontamento, será necessario excluir o Checklist pelo portal do Aplicativo Meu Checklist."
		Return( .F. )
	EndIf
EndIf

If	DTW->(DTW_FILIAL+DTW_FILORI+DTW->DTW_VIAGEM+DTW_STATUS) == xFilial('DTW')+cFilOri+cViagem+cStatus

	If	DTW->DTW_STATUS != StrZero( 2, Len( DTW->DTW_STATUS ) )	//-- Diferente de encerrado
		//-- Limpa marcas dos agendamentos
		//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
		If !IsInCallStack("TMSAF76")
			TMSALimAge(StrZero(ThreadId(),20))
		EndIf
		Help("", 1, 'TMSA35001')	//-- Somente operacoes com status encerrado serao estornados.
		RestArea( aAreaDTW )
		MsUnLockAll()
		Return( .F. )
	EndIf

	//Nao e permitido estornar operacoes anteriores as operacoes ja encerradas, se suas atividades
	//estiverem contidas nos parametros de chegada, saida e descarregamento
	If DTW->DTW_ATIVID == cAtivChg .Or. DTW->DTW_ATIVID == cAtivSai .Or. DTW->DTW_ATIVID == cAtivDca
		If TMA350VlEst(DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_SEQUEN,cAtivChg,cAtivSai,cAtivDca)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			RestArea( aAreaDTW )
			Help("",1,"TMSA35023") //"Existem operacoes posteriores encerradas, o estorno nao sera realizado"
			MsUnLockAll()
			Return( .F. )
		EndIf
	EndIf

	If lContVei
		If !lVgeInter .And. ((DTW->DTW_ATIVID == cAtivChg .And. DTQ->DTQ_SERTMS <> '2' .And. DTQ->DTQ_TIPTRA <> '2') .Or.;
			(DTW->DTW_ATIVID == cAtivChg .And. DTQ->DTQ_FILORI == cFilAnt) .Or.;
			(DTW->DTW_ATIVID == cAtivSai ) .Or. ;
			(DTW->DTW_ATIVID == cAtivRta ) .Or. ;
			(DTW->DTW_ATIVID == cAtivRtp ))
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help("", 1,'TMSA35008',,Tabela("L3", DTW->DTW_ATIVID, .F.),5,1)// "Esta operação é apontada pela rotina de movimento de veículos/motoristas."
			RestArea( aAreaDTW )
			MsUnLockAll()
			Return( .F. )
		EndIf
	EndIf

	If lIdDTW .And. ExistFunc("TM351VldEC") .And.  (DTW->DTW_ATIVID == cAtvChgCli .Or. DTW->DTW_ATIVID == cAtvChgApo) //Chegada em Cliente
		If !TM351VldEC(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTW->DTW_IDDTW)  
			RestArea( aAreaDTW )
			MsUnLockAll()
			Return( .F. )
		EndIf		
	EndIf

	If !DTW->DTW_ATIVID $ "(" + cAtvSaiCli + "," + cAtvChgCli + "," + cAtvSaiApo + "," + cAtvChgApo + ")"  
		If !TMSA350Oco(cFilOri,cViagem)
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			
			If DTW->DTW_ATIVID == cAtivChg
				If !MsgYesNo(STR0065, STR0066)	//"Existem documentos na viagem com ocorrências informadas. Deseja continuar?" "Estorno de Operações"
					RestArea( aAreaDTW )
					MsUnLockAll()
					Return .F.
				EndIf
			ElseIf DTW->DTW_ATIVID == cAtivSai	
				Help("", 1,'TMSA35014') //"Existem documentos na viagem com ocorrencias informadas"
				RestArea( aAreaDTW )
				MsUnLockAll()
				Return( .F. )
			EndIf
		EndIf
	EndIf
	//-- Lock para Estorno da Operação
	If !LockByName(cLockKeyVG,.T.,.F.)
		Help('',1,"TMSA350LOCK2",,"Registro sendo utilizado por outro usuário.",3,1)
		Return .F.
	EndIf
	
	If !lContinua
		//-- Libera lock da rotina pela viagem posicionada
		UnLockByName(cLockKeyVG,.T.,.F.)
		Return .F.
	EndIf 

	If !lVgeInter
		
		oStructDTW := FWFormStruct(1, "DTW")
		For nI := 1 To Len(oStructDTW:aFields)
			If aScan(aFldsDTWNot, {|x| x == oStructDTW:aFields[nI][3]}) = 0
				aAdd(aFldsDTW, oStructDTW:aFields[nI][3])
			EndIf
		Next

		FreeObj(oStructDTW)

		aSize(aFldsDTWNot, 0)
		aFldsDTWNot := Nil

		nOpca := AxVisual( 'DTW', DTW->(Recno()), 2, aFldsDTW)

		aSize(aFldsDTW, 0)
		aFldsDTW := Nil
	Else
		nOpca := 1
	EndIf

	//Cria as tabelas temporárias do SIGAMNT para garantir Disarm Transaction
	If lMntTms .And. FindFunction("MNTCTemp")
		MNTCTemp({cTRBF,cTRBS,CTRBEixo})
	EndIf
	Begin Transaction
		If nOpca == 1

			//-- Reativa a operacao de chegada em filial (Origem) quando for estorno de chegada eventual.
			If cAtividade == cAtivChg .And. ; //-- Chegada de Viagem
				DTW->DTW_SERTMS <> StrZero(2,Len(DTW->DTW_SERTMS)) .And. ; //-- Diferente de Transporte (Coleta/Entrega)
				DTW->DTW_CATOPE == StrZero(2,Len(DTW->DTW_CATOPE)) //-- Eventual
				aArea := DTW->(GetArea())
				lEventual:= .T.
				//-- Para Coleta/Entrega devera ser atualizada a filial destino da viagem.
				DTQ->(DbSetOrder(2))
				If DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
					cFilDes:= DTQ->DTQ_FILDES
					RecLock("DTQ",.F.)
					DTQ->DTQ_FILDES := DTQ->DTQ_FILORI
					MsUnlock()
				EndIf
				DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
				If DTW->(MsSeek(xFilial("DTW")+cFilOri+cViagem+cAtividade+cFilOri))
					RecLock('DTW',.F.)
					DTW->DTW_DATREA := CriaVar('DTW_DATREA', .F.)
					DTW->DTW_HORREA := CriaVar('DTW_HORREA', .F.)
					DTW->DTW_STATUS := StrZero(1,Len(DTW->DTW_STATUS))	//-- Aberto
					MsUnLock()
				EndIf
				RestArea( aArea )
			EndIf

			//-- Verificar se trata-se de chegada eventual antes de estornar / excluir apontamento atual.
			lChgEvent := DTW->DTW_ATIVID == cAtivChg .And. DTW->DTW_CATOPE == StrZero(2,Len(DTW->DTW_CATOPE)) //-- Eventual

			//-- Estorna operacao posicionada
			lRet := TMSA350Grv( nOpcx, cFilOri, cViagem ,,,,,,,,,{cTRBS,cTRBF,CTRBEixo})

			If lMVITMSDMD
				If cAtividade == cAtivSai
					If FindFunction("PlnDmdTran") .And. TableInDic("DL9")  // Suavização
						PlnDmdTran(TVgGetPlnD(DTW->DTW_FILORI,DTW->DTW_VIAGEM),  '3') // Planejamento de Demandas = "Em Viagem"
					EndIf
				EndIf
			Endif

			//-- Estorna operacoes anteriores se canceladas conforme parametro MV_PCANOP ou Chegada Eventual.
			If lRet .AND. (nPCanOp == 0 .Or. nPCanOp == 1 .Or. lEventual)
				cQuery := " SELECT DTW_STATUS, R_E_C_N_O_ DTWRECNO "
				cQuery += " FROM " + RetSqlName("DTW")
				cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
				cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
				cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
				If lChgEvent
					//-- Para chegada eventual registro atual foi excluido, posicionando no DTW anterior.
					cQuery += "	  AND DTW_SEQUEN <= '" + DTW->DTW_SEQUEN + "' "
				Else
					cQuery += "	  AND DTW_SEQUEN <  '" + DTW->DTW_SEQUEN + "' "
				EndIf
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY DTW_SEQUEN DESC"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				While (cAliasQry)->(!Eof())
					If (cAliasQry)->DTW_STATUS == StrZero(9,Len(DTW->DTW_STATUS))
						DTW->(dbGoto((cAliasQry)->DTWRECNO))
						lRet := TMSA350Grv( 5, cFilOri, cViagem ,,,,,,,,,{cTRBS,cTRBF,CTRBEixo})
					EndIf
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
				RestArea( aAreaDTW )
			EndIf

			//--- Chama integração TMS x GFE
			If lRet
				If DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA))  //Redespacho
					lIntGFE:= (cTMSRDPU == 'S' .And. DTW->DTW_ATIVID == cAtivSai) .Or. (cTMSRDPU == 'C' .And. DTW->DTW_ATIVID == cAtivChg)
				ElseIf lTMS3GFE
					lIntGFE:= (cTMS3GFE == 'S' .And. DTW->DTW_ATIVID == cAtivSai) .Or. (cTMS3GFE == 'C' .And. DTW->DTW_ATIVID == cAtivChg)
				EndIf
				If lIntGFE .And. lRet
					lRet:= Tms3GfeInt(cFilOri, cViagem, .F., .T.)
				EndIf
			EndIf
			If lRet .And. cEncRepom == '2' .And. !lRestRepom // Encerramento da Repom é pela Ocorrencia entao estorna pela Ocorrencia
				DTQ->(DbSetOrder(2))
				DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem))
				If !lContVei .And. lTMSOPdg .And. (DTW->DTW_ATIVID == cAtivChg .And. (Iif(lEventual .And. !Empty(cFilDes), DTW->DTW_FILATI == cFilDes, DTW->DTW_FILATI == DTQ->DTQ_FILDES)) )
					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR')+ cFilOri + cViagem)) .And. DTR->DTR_CODOPE == '01'
						lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
						CursorWait()
						MsgRun( If( !lFrotaProp, STR0036,STR0037 ) ,; //-- 'Quitacao do Contrato junto a Operadora de Frotas...' ## 'Baixa da Viagem junto a Operadora de Frotas...'
								  STR0030,; //-- 'Aguarde...'
						{|| lRet := TMA340Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, lFrotaProp, 5 )} ) // 5--Estorno
						CursorArrow()
						If !lRet .And. !Empty( aMsgErr )
							TmsMsgErr( aMsgErr )
						EndIf
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³Quando o controle de veiculos NAO estiver   ³
			//³ativo, o estorno do controle de viagem com  ³
			//³a Operadora de Frotas ira ocorrer no momento³
			//³do estorno da Operacao de Saida de viagem   ³
			//³Quando o controle de veiculos estiver ativo,³
			//³o estorno do controle de viagem sera        ³
			//³realizado atraves do estorno do fechamento  ³
			//³da viagem.                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. !lContVei .And. lTMSOPdg .And. (DTW->DTW_ATIVID == cAtivSai .And. DTW->DTW_FILATI == DTW->DTW_FILORI)
				DTR->(DbSetOrder(1))
				If DTR->(MsSeek(xFilial('DTR')+ cFilOri + cViagem)) .And. !Empty(DTR->DTR_CODOPE)
					lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
					If lFrotaProp .Or. DTR->DTR_CODOPE == '02'
						CursorWait()
						MsgRun( STR0032,; //-- "Estorno do Controle de Viagem na Operadora"
								STR0030,; //-- 'Aguarde...'
								{|| lRet := TMA310Oper( DTR->DTR_CODOPE, cFilOri, cViagem, @aMsgErr, 5 )} )
						CursorArrow()

						If !lRet .And. !Empty( aMsgErr )
							TmsMsgErr( aMsgErr )
						EndIf
					ElseIf DTR->DTR_CODOPE == '03' .And. lPagBem 
						lRet := A350VgPGBe(DTW->DTW_FILORI, DTW->DTW_VIAGEM)//Chama Método para Bloquear a Viagem na PAGBEM.
					EndIf
				EndIf
			EndIf
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction

	//-- Tratamento de estorno da operação de chegada da viagem com geração do novo manifesto eletrônico
	If lRet
		If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
			lMdfeAut:= TMA190Srv(cFilOri,cViagem)
		EndIf
		
		//-- ESTORNO do Manifesto Automático: 
		If lMDFEAUT 
			// Verifica se possui manifestos com cancelamento não transmitidos.
			If A210VCnMan(cFilOri,cViagem,,.T.,,DTW->DTW_FILATI)
				Return .F.
			EndIf			
				
			//-- No ESTORNO da Chegada, gera novo(s) manifesto(s)
			If DTW->DTW_ATIVID == cAtivChg		
				//-- Estorna operacoes anteriores se canceladas Chegada Eventual.			
				cQuery := " SELECT DTW_FILATI, R_E_C_N_O_ DTWRECNO "
				cQuery += " FROM " + RetSqlName("DTW")
				cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
				cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
				cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
				If lChgEvent
					//-- Para chegada eventual registro atual foi excluido, posicionando no DTW anterior.
					cQuery += "	  AND DTW_SEQUEN <= '" + DTW->DTW_SEQUEN + "' "
				Else
					cQuery += "	  AND DTW_SEQUEN <  '" + DTW->DTW_SEQUEN + "' "
				EndIf
				cQuery += "   AND DTW_ATIVID = '"+cAtivSai+"' "
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY DTW_SEQUEN DESC"
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				If (cAliasQry)->(!Eof())
					DTW->(dbGoto((cAliasQry)->DTWRECNO))			 
					//-- Altera o conteudo da variavel cFilAnt para filial de Origem do manifesto.													
					cFilAnt := Posicione('SM0',1,cEmpAnt+(cAliasQry)->DTW_FILATI,'FWCODFIL()')
				EndIf
				(cAliasQry)->(DbCloseArea())	
											
				If cFilAnt != cFilBack
					RegToMemory("DTQ",.F.)	
					TmsLimpDUD(cFilOri,cViagem,,cFilBack)//--Limpa a DUD				
					lContinua := Tmsa144GMC( .F., 3, .F.,cFilBack) // Gera o manifesto, se houver documentos não manifestados na filial da ultima saida
				Else
					lContinua := .F.
				EndIf
			EndIf
				
			If lContinua	
				aMDFE := {}		
				DTX->(DbSetOrder(5)) //-- DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI                                                                                                                     
				DTX->(MsSeek(xFilial("DTX") +  DTQ->(DTQ_FILORI+DTQ_VIAGEM) ))	
				Do WHile DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ DTQ->(DTQ_FILORI+DTQ_VIAGEM)
						
					//-- Considera apenas os manifestos gerados na filial em que se estorna a Saída
					If DTW->DTW_ATIVID == cAtivSai .And. DTX->DTX_FILMAN != DTW->DTW_FILATI
						DTX->(DbSkip())
					EndIf

					//-- Conta a qtde de horas desde a emissão do MDF-e
					nHoras := Round(SubtHoras( DTX->DTX_DATMAN, ;
											SubStr(DTX->DTX_HORMAN,1,2) + ":" + SubStr(DTX->DTX_HORMAN,3,2) , ;
											Date(), 		  SubStr(Time(),1,2)		  + ":" + SubStr(Time(),4,2) ),2) //Prazo em Horas

					//-- No ESTORNO da Saida, 
					//-- Se estiver dentro do prazo para cancelamento, ou rejeitado ou não transmitido, exclui e transmite cancelamento
					If DTW->DTW_ATIVID == cAtivSai .And.;		
					   DTX->DTX_TIPMAN  <> '2' .Or.  DTX->DTX_STIMDF == '0' .Or. DTX->DTX_STIMDF == '3' .Or. nHoras <=  nMdfeExc 
						// Salva Variaveis de ambiente
						cfunOld := FunName()
						SaveInter()

						RegToMemory("DTQ",.F.)
						SetFunName("TMSA190")
						aRotina := {	{ ""  ,"", 0, 1 },;
										{ ""  ,"", 0, 2 },;
										{ ""  ,"", 0, 3 },;
										{ ""  ,"", 0, 4 },;
										{ ""  ,"", 0, 5 } }

						//-- Exclui o MDF-e
						lContinua := TmsA190Mnt("DTX", DTX->(Recno()), 5, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,,.F.,,.T.)

						//-- Restaura variáveis de ambiente
						RestInter()
						SetFunName(cfunOld)

					Else
						//-- No ESTORNO da Saida, 
						//-- Se já passou do prazo para cancelamento do MDF-e, encerra-o
						If DTW->DTW_ATIVID == cAtivSai  .Or.;
						   (DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STIMDF <> '2') //--Eletronico, não autorizado
							Aadd(aMDFe ,Array(6))
							aMDFe[Len(aMDFe),1] := DTX->DTX_FILMAN //-- Filial Manif
							aMDFe[Len(aMDFe),2] := DTX->DTX_MANIFE //-- Manif. Inicial
							aMDFe[Len(aMDFe),3] := DTX->DTX_MANIFE //-- Manif. final
							aMDFe[Len(aMDFe),4] := DTX->DTX_SERMAN //-- Serie Manif.
							aMDFe[Len(aMDFe),5] := DTX->DTX_VIAGEM //-- VIAGEM
							If lUFAtiv
								aMDFe[Len(aMDFe),6] := DTX->DTX_UFATIV  //-- UFDES
							Else
								aMDFe[Len(aMDFe),6] := ''
							EndIf
						EndIf
					EndIf
			
					DTX->(DbSkip())
				EndDo		
					
				If !Empty(aMDFe)
					//-- Estorno de saída
					If DTW->DTW_ATIVID == cAtivSai 
						lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto   
						If lContinua
							TmsLimpDUD(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,aMdfe)	//--Limpar a DUD
						EndIf 								         
					Else
						lContinua := TmsMDFeAut(aMDFe, 1)	//-- Envia o Manifesto					
					EndIf
				EndIf
			Else							
				DTX->(DbSetOrder(3))
				DTX->( DbSeek( cSeek := xFilial('DTX') + DTQ->(DTQ_FILORI + DTQ_VIAGEM) ))
				Do While !DTX->(Eof()) .And. DTX->(DTX_FILIAL + DTX_FILORI + DTX_VIAGEM) == cSeek
					If DTX->DTX_TIPMAN == '2'
						If DTX->DTX_IDIMDF <> '100' .And. Empty(DTX->DTX_CTGMDF)
							If lDTX_SERMAN
								Help('',1,'TMSA35032',, DTX->(DTX_FILMAN+" - "+DTX_MANIFE+" - "+DTX_SERMAN)  ,4,1) //--MDF-e não autorizado ou não enviado.
							Else
								Help('',1,'TMSA35032',, DTX->(DTX_FILMAN+" - "+DTX_MANIFE)  ,4,1) //--MDF-e não autorizado ou não enviado.
							EndIf								
						EndIf
					EndIf       
					DTX->(dbSkip())
				EndDo	
			EndIf		 
			//--Altera o conteudo da variavel cFilAnt para a filial logada									         
			cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
			RestArea(aAreaSM0)
			RestArea( aAreaDTW )			
		EndIf
	EndIf 
	//Deleta as tabelas temporárias relacionadas ao SIGAMNT
	If lMntTms .And. FindFunction("MNTDTemp")
		MNTDTemp()
	EndIf

	//-- Libera lock da rotina pela viagem posicionada
	UnLockByName(cLockKeyVG,.T.,.F.)

Else
	Help("", 1,'TMSA35004',, STR0026 + cViagem,5,11) 	//"Nao ha operacoes encerradas para esta viagem"###"Viagem: "
EndIf

RestArea( aAreaDTW )

MsUnLockAll()

//-- Atualiza o Status dos Documentos de Redespacho
TMSA350Sta( cFilOri, cViagem)

TMSFimRot()
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Vld³ Autor ³Robson Alves           ³ Data ³12.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de campos.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Vld()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Vld()

Local lRet      := .T.
Local aAreaDTW  := DTW->( GetArea() )
Local aAreaDTQ  := DTQ->( GetArea() )
Local cCampo    := ReadVar()
Local lMntTms   := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local lTercRbq  := DUV->(ColumnPos("DUV_ODOSR3")) > 0
Local dDatAnt   := Nil
Local cHorAnt   := Nil

If cCampo == "M->DTW_HORINI" .Or. cCampo == "M->DTW_DATINI"

	If !Empty(M->DTW_HORINI)

		lRet := .F.
		while(Empty(dDatAnt) .Or. Empty(cHorAnt) .And. !lRet)

			//-- Posiciona a sequencia anterior da operacao
			DTW->(DbSetOrder(1))
			DTW->(dbSkip(-1))

			//-- Primeira operacao
			If (DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) <> xFilial("DTW") + M->DTW_FILORI + M->DTW_VIAGEM) .Or. DTW->(Bof())
				DTQ->(DbSetOrder(2))
				DTQ->(MsSeek(xFilial("DTQ") + M->DTW_FILORI + M->DTW_VIAGEM))

				dDatAnt := DTQ->DTQ_DATGER
				cHorAnt := DTQ->DTQ_HORGER

				//-- Garante que nao fique em loop infinito
				If Empty(dDatAnt) .Or. Empty(cHorAnt)
					lRet := .T.
				Endif
			Else
				//-- Caso data ou hora estejam em branco significa que a operacao foi cancelada
				If !Empty(DTW->DTW_DATREA) .And. !Empty(DTW->DTW_HORREA)
					dDatAnt := DTW->DTW_DATREA
					cHorAnt := DTW->DTW_HORREA
				EndIf
			EndIf
		EndDo

		//-- Verifica se eh uma hora valida e se data e hora sao maiores que do apontamento anterior
		lRet := AtVldHora(M->DTW_HORINI) .And. ValDatHor(M->DTW_DATINI, M->DTW_HORINI, dDatAnt, cHorAnt)

		If lRet .And. !Empty(M->DTW_HORREA)
			lRet := ValDatHor(M->DTW_DATREA,M->DTW_HORREA,M->DTW_DATINI,M->DTW_HORINI)
		EndIf
	EndIf

ElseIf cCampo == "M->DTW_HORREA" .Or. cCampo == "M->DTW_DATREA"

	If !Empty(M->DTW_HORREA)

		lRet := AtVldHora(M->DTW_HORREA) .And. ValDatHor(M->DTW_DATREA,M->DTW_HORREA,M->DTW_DATINI,M->DTW_HORINI)

		If lRet

			lRet := .F.
			while(Empty(dDatAnt) .Or. Empty(cHorAnt) .And. !lRet)

				//-- Posiciona a sequencia anterior da operacao
				DTW->(DbSetOrder(1))
				DTW->(dbSkip(-1))

				//-- Primeira operacao
				If (DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) <> xFilial("DTW") + M->DTW_FILORI + M->DTW_VIAGEM) .Or. DTW->(Bof())
					DTQ->(DbSetOrder(2))
					DTQ->(MsSeek(xFilial("DTQ") + M->DTW_FILORI + M->DTW_VIAGEM))

					dDatAnt := DTQ->DTQ_DATGER
					cHorAnt := DTQ->DTQ_HORGER

					//-- Garante que nao fique em loop infinito
					If Empty(dDatAnt) .Or. Empty(cHorAnt)
						lRet := .T.
					Endif
				Else
					//-- Caso data ou hora estejam em branco significa que a operacao foi cancelada
					If !Empty(DTW->DTW_DATREA) .And. !Empty(DTW->DTW_HORREA)
						dDatAnt := DTW->DTW_DATREA
						cHorAnt := DTW->DTW_HORREA
					EndIf
				EndIf
			EndDo

			//-- Verifica se eh uma hora valida e se data e hora sao maiores que do apontamento anterior
			lRet := ValDatHor(M->DTW_DATREA, M->DTW_HORREA, dDatAnt, cHorAnt, , STR0073, STR0074, , ,,.T.)

		EndIf
	EndIf

ElseIf cCampo == 'M->DUV_ODOENT'

	lRet := TMSVOdoEnt(aCols[n,GDFieldPos("DTR_CODVEI")],M->DUV_ODOENT,0,.F.,,dDataBase)

ElseIf cCampo == 'M->DUV_ODOER1'

	If Empty(aCols[n,GDFieldPos("DTR_CODRB1")]) .And. M->DUV_ODOER1 <> 0
		Help("",1,"TMSA35022") //"Reboque não informado."
		lRet := .F.
	ElseIf lMntTms // Integração ativa
		If M->DUV_ODOER1 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB1")],"T9_TEMCONT") == "P" // controlado pelo pai da estrutura
				Help("",1,"TMSA35027")	//"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOER1 := 0
			EndIf
		EndIf
	Else
		lRet := TMSVOdoEnt(aCols[n,GDFieldPos("DTR_CODRB1")],M->DUV_ODOER1,1,.F.,,dDataBase)
	EndIf

ElseIf cCampo == 'M->DUV_ODOER2'

	If Empty(aCols[n,GDFieldPos("DTR_CODRB2")]) .And. M->DUV_ODOER2 <> 0
		Help("",1,"TMSA35022")	//"Reboque não informado."
		lRet := .F.
	ElseIf lMntTms
		If M->DUV_ODOER2 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB2")],"T9_TEMCONT") == "P"
				Help("",1,"TMSA35027") //"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOER2 := 0
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := TMSVOdoEnt(aCols[n,GDFieldPos("DTR_CODRB2")],M->DUV_ODOER2,2,.F.,,dDataBase)
	EndIf

ElseIf cCampo == 'M->DUV_ODOER3' .And. lTercRbq

	If Empty(aCols[n,GDFieldPos("DTR_CODRB3")]) .And. M->DUV_ODOER3 <> 0
		Help("",1,"TMSA35022")	//"Reboque não informado."
		lRet := .F.
	ElseIf lMntTms
		If M->DUV_ODOER3 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB3")],"T9_TEMCONT") == "P"
				Help("",1,"TMSA35027") //"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOER3 := 0
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := TMSVOdoEnt(aCols[n,GDFieldPos("DTR_CODRB3")],M->DUV_ODOER3,3,.F.,,dDataBase)
	EndIf
ElseIf cCampo == 'M->DUV_ODOSAI'

	lRet := TMSVOdoSai(aCols[n,GDFieldPos("DTR_CODVEI")],M->DUV_ODOSAI,0,,,dDataBase)

ElseIf cCampo == 'M->DUV_ODOSR1'

	If Empty(aCols[n,GDFieldPos("DTR_CODRB1")]) .And. M->DUV_ODOSR1 <> 0
		Help("",1,"TMSA35022") //"Reboque não informado."
		lRet := .F.
	ElseIf lMntTms
		If M->DUV_ODOSR1 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB1")],"T9_TEMCONT") == "P"
				Help("",1,"TMSA35027") //"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOSR1 := 0
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := TMSVOdoSai(aCols[n,GDFieldPos("DTR_CODRB1")],M->DUV_ODOSR1,1,,,dDataBase)
	EndIf

ElseIf cCampo == 'M->DUV_ODOSR2'

	If Empty(aCols[n,GDFieldPos("DTR_CODRB2")]) .And. M->DUV_ODOSR2 <> 0
			Help("",1,"TMSA35022") //"Reboque não informado."
			lRet := .F.
	ElseIf lMntTms
		If M->DUV_ODOSR2 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB2")],"T9_TEMCONT") == "P"
				Help("",1,"TMSA35027") //"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOSR2 := 0
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := TMSVOdoSai(aCols[n,GDFieldPos("DTR_CODRB2")],M->DUV_ODOSR2,2,,,dDataBase)
	EndIf

ElseIf cCampo == 'M->DUV_ODOSR3' .And. lTercRbq

 	If Empty(aCols[n,GDFieldPos("DTR_CODRB3")]) .And. M->DUV_ODOSR3 <> 0
			Help("",1,"TMSA35022") //"Reboque não informado."
			lRet := .F.
	ElseIf lMntTms
		If M->DUV_ODOSR3 <> 0
			If Posicione("ST9",1,xFilial("ST9")+aCols[n,GDFieldPos("DTR_CODRB3")],"T9_TEMCONT") == "P"
				Help("",1,"TMSA35027") //"Reboque (Bem) Controlador pelo Pai da Estrutura."
				lRet := .F.
				M->DUV_ODOSR3 := 0
			EndIf
		EndIf
	EndIf
	If lRet
		lRet := TMSVOdoSai(aCols[n,GDFieldPos("DTR_CODRB3")],M->DUV_ODOSR3,3,,,dDataBase)
	EndIf
EndIf

RestArea( aAreaDTW )
RestArea( aAreaDTQ )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A350TudOk ³ Autor ³Rodrigo A Sartorio     ³ Data ³27.11.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao geral da Tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A350TudOk(nOpcx)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A350TudOk(nOpcx,lEsporad)
Local lRet 			:= .T.
Local cAtivRef		:= SuperGetMv('MV_ATIVREF',,"")  //-- Atividade de Refeicao
Local cAtivDes		:= SuperGetMV('MV_ATIVDES',,"")  //-- Atividade de Descanso

Local dDatAnt   := Nil
Local cHorAnt   := Nil
Local aAreaDTW  := {}

Default lEsporad := .F.

If ExistBlock('TMA350TOK')
	lRet := ExecBlock('TMA350TOk',.F.,.F.,{nOpcx})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

If lEsporad

	If M->DTW_ATIVID == cAtivRef
		lRet := .T.
	ElseIf M->DTW_ATIVID == cAtivDes
		lRet := .T.
	Else
		lRet := .F.
		Help('',1,'TMSA35030') //-- O apontamento esporádico só é permitido para atividades de descanso e/ou refeição.
	EndIf

 	If lRet
 	   //-- Valida apontamento entre as datas previstas da viagem
 		lRet := TMA350VEsp(M->DTW_FILORI,M->DTW_VIAGEM,,, M->DTW_DATPRE, M->DTW_HORPRE )

 	EndIf


EndIf

//-- Verifica se eh uma hora valida e se data e hora sao maiores que do apontamento anterior
If lRet
	aAreaDTW := DTW->(GetArea())

	lRet := .F.
	while(Empty(dDatAnt) .Or. Empty(cHorAnt) .And. !lRet)
	
		//-- Posiciona a sequencia anterior da operacao
		DTW->(DbSetOrder(1))
		DTW->(dbSkip(-1))
		
		//-- Primeira operacao
		If (DTW->(DTW_FILIAL + DTW_FILORI + DTW_VIAGEM) <> xFilial("DTW") + M->DTW_FILORI + M->DTW_VIAGEM) .Or. DTW->(Bof())
			DTQ->(DbSetOrder(2))
			DTQ->(MsSeek(xFilial("DTQ") + M->DTW_FILORI + M->DTW_VIAGEM))
		
			dDatAnt := DTQ->DTQ_DATGER
			cHorAnt := DTQ->DTQ_HORGER
		
			//-- Garante que nao fique em loop infinito
			If Empty(dDatAnt) .Or. Empty(cHorAnt)
				lRet := .T.
			Endif
		Else
			//-- Caso data ou hora estejam em branco significa que a operacao foi cancelada
			If !Empty(DTW->DTW_DATREA) .And. !Empty(DTW->DTW_HORREA)
				dDatAnt := DTW->DTW_DATREA
				cHorAnt := DTW->DTW_HORREA
			EndIf
		EndIf
	EndDo
	
	lRet := ValDatHor(M->DTW_DATREA, M->DTW_HORREA, dDatAnt, cHorAnt, , STR0073, STR0074, , ,,.T.)

	RestArea(aAreaDTW)
EndIf

If lRet .And. ( Empty(M->DTW_DATINI) .Or. Empty(M->DTW_HORINI) )
	Help('',1,'TMSA35012') // OBRIGATORIO o preenchimento dos campos de data e hora inicial
	lRet:=.F.
EndIf


Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Km    ³ Autor ³Patricia A. Salomao    ³ Data ³14.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Se o parametro MV_CONTVEI estiver desabilitado, o apontamento  ³±±
±±³          ³de Chegada/Saida de Viagens e' feito manualmente.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA350Km()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Filial Origem da Viagem                                ³±±
±±³          ³ExpC2 - Numero da Viagem                                       ³±±
±±³          ³ExpL3 - E saida de veiculo? Sim(T) Nao(F)                      ³±±
±±³          ³ExpL4 - E obrigatorio informar a quilometragem? Sim(T) Nao(F)  ³±±
±±³          ³ExpD5 - Data de Saida da Viagem                                ³±±
±±³          ³ExpC6 - Hora de Saida da Viagem                                ³±±
±±³          ³ExpD7 - Data de Entrada da Viagem                              ³±±
±±³          ³ExpC8 - Hora de Entrada da Viagem                              ³±±
±±³ 		 aTrbEst = Array possuindo as tabelas temporárias de 		 	 ³±±
±±³ 		 		  estrutura do bem (SIGAMNT).						  	 ³±±
±±³					 [1] tabela temporaria do pai da estrutura - cTRBS    	 ³±±
±±³					 [2] tabela temporaria do pai da estrutura - cTRBF    	 ³±±
±±³					 [3] tabela temporaria do eixo suspenso    - CTRBEixo 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA350 / TMSA430                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Km(cFilOri,cViagem,lSaida,lKmObrig,dDatSai,cHorSai,dDatEnt,cHorEnt,aTrbEst)

//-- Verifica se esta' sendo apontado a Saida de Viagem
Local cSeek      := cModVei    := cModRB1    := cModRB2 :=  cModRB3 := ''
Local nOpca      := nPosCodVei := nPosCodRB1 := nPosCodRB2 := nPosCodRB3 := 0
Local aTam       := {}
Local aAlter     := {}
Local aArea      := GetArea()
Local aAreaDTR   := {}
Local nX         := 0
Local oDlg       := {}
Local nPosOdoRb1 := 0
Local nPosOdoRb2 := 0
Local nPosOdoRb3 := 0
Local nOdoSai    := 0
Local nOdoSR1    := 0
Local nOdoSR2    := 0
Local nOdoSR3	   := 0
Local lRet       := lKmObrig
Local aRet       := {}
Local nUsado     := 0
Local nPosOdoSai := 0
Local nPosOdoSb1 := 0
Local nPosOdoSb2 := 0
Local nPosOdoSb3 := 0
Local cAtivRTP   := SuperGetMv('MV_ATIVRTP',,'')
Local lMostraDTR :=	.T.
Local lMostraRB  :=	.T.
Local lObrig     := .T. //-- utilizado pelo PE TM350OBB
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0

//--Integracao MNT
Local lMntTms    := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local cAtivChg   := GetMV('MV_ATIVCHG',,'')
Local nAcao      := 1
Local dData      := CToD("")
Local cHora      := ""

Default cFilOri  := ""
Default cViagem  := ""
Default lSaida   := .T.
Default lKmObrig := .F.
Default dDatSai  := dDataBase
Default cHorSai  := Left(StrTran(Time(),":",""),4)
Default dDatEnt  := dDatSai
Default cHorEnt  := cHorSai
Default aTrbEst  := {} //Variável criada para integração junto ao SIGAMNT

Private oGet

//-- Salva as variaveis utilizadas na GetDados Anterior.
SaveInter()

aCols   := {}
aHeader := {}

//-- Montagem do aHeader
aTam:=TamSX3("DTR_CODVEI")	//-- Codigo do Veiculo
AAdd(aHeader,{RetTitle("DTR_CODVEI"),"DTR_CODVEI"	,PesqPict("DTR","DTR_CODVEI",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
aTam:=TamSX3("DTR_MODVEI")	//-- Descricao do Veiculo
AAdd(aHeader,{RetTitle("DTR_MODVEI"),"DTR_MODVEI"	,PesqPict("DTR","DTR_MODVEI",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
aTam:=TamSX3("DTR_CODRB1")	//-- Codigo do 1o.Reboque
AAdd(aHeader,{RetTitle("DTR_CODRB1"),"DTR_CODRB1"	,PesqPict("DTR","DTR_CODRB1",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
aTam:=TamSX3("DTR_MODRB1")	//-- Descricao do 1o.Reboque
AAdd(aHeader,{RetTitle("DTR_MODRB1"),"DTR_MODRB1"	,PesqPict("DTR","DTR_MODRB1",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
aTam:=TamSX3("DTR_CODRB2") //-- Codigo do 2o.Reboque
AAdd(aHeader,{RetTitle("DTR_CODRB2"),"DTR_CODRB2"	,PesqPict("DTR","DTR_CODRB2",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
aTam:=TamSX3("DTR_MODRB2")	//-- Descricao do 2o.Reboque
AAdd(aHeader,{RetTitle("DTR_MODRB2"),"DTR_MODRB2"	,PesqPict("DTR","DTR_MODRB2",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
If lTercRbq
	aTam:=TamSX3("DTR_CODRB3") //-- Codigo do 3o.Reboque
	AAdd(aHeader,{RetTitle("DTR_CODRB3"),"DTR_CODRB3"	,PesqPict("DTR","DTR_CODRB3",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
	aTam:=TamSX3("DTR_MODRB3")	//-- Descricao do 3o.Reboque
	AAdd(aHeader,{RetTitle("DTR_MODRB3"),"DTR_MODRB3"	,PesqPict("DTR","DTR_MODRB3",atam[1]),aTam[1],aTam[2],"",USADO, "C" ,"DTR"," "})
EndIf
If !lSaida
	aTam:=TamSX3("DUV_ODOENT")	//-- Odometro de Chegada
	AAdd(aHeader,{RetTitle("DUV_ODOENT"),"DUV_ODOENT"	,PesqPict("DUV","DUV_ODOENT"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOENT", "X3_USADO"), "N" ,"DUV"," "})
	AAdd(aAlter, "DUV_ODOENT")

	aTam:=TamSX3("DUV_ODOER1")	//-- Odometro de Entrada Reboque 1
	AAdd(aHeader,{RetTitle("DUV_ODOER1"),"DUV_ODOER1"	,PesqPict("DUV","DUV_ODOER1"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOER1", "X3_USADO"), "N" ,"DUV"," "})
	AAdd(aAlter, "DUV_ODOER1")

	aTam:=TamSX3("DUV_ODOER2")	//-- Odometro de Entrada Reboque 2
	AAdd(aHeader,{RetTitle("DUV_ODOER2"),"DUV_ODOER2",PesqPict("DUV","DUV_ODOER2"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOER2", "X3_USADO"), "N" ,"DUV"," "})
	AAdd(aAlter, "DUV_ODOER2")
	If lTercRbq
		aTam:=TamSX3("DUV_ODOER3")  //-- Odometro de Entrada Reboque 3
		AAdd(aHeader,{RetTitle("DUV_ODOER3"),"DUV_ODOER3",PesqPict("DUV","DUV_ODOER3"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOER3", "X3_USADO"), "N" ,"DUV"," "})
		AAdd(aAlter, "DUV_ODOER3")
	EndIf
Else
	AAdd(aAlter, "DUV_ODOSAI")
	AAdd(aAlter, "DUV_ODOSR1")
	AAdd(aAlter, "DUV_ODOSR2")
	If lTercRbq
		AAdd(aAlter, "DUV_ODOSR3")
	EndIf
EndIf
aTam:=TamSX3("DUV_ODOSAI")	//-- Odometro de Saida
AAdd(aHeader,{RetTitle("DUV_ODOSAI"),"DUV_ODOSAI"	,PesqPict("DUV","DUV_ODOSAI"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOSAI", "X3_USADO"), "N" ,"DUV"," "})

aTam:=TamSX3("DUV_ODOSR1")	//-- Odometro de Saida Reboque 1
AAdd(aHeader,{RetTitle("DUV_ODOSR1"),"DUV_ODOSR1"	,PesqPict("DUV","DUV_ODOSR1"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOSR1", "X3_USADO"), "N" ,"DUV"," "})

aTam:=TamSX3("DUV_ODOSR2")	//-- Odometro de Saida Reboque 2
AAdd(aHeader,{RetTitle("DUV_ODOSR2"),"DUV_ODOSR2",PesqPict("DUV","DUV_ODOSR2"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOSR2", "X3_USADO"), "N" ,"DUV"," "})

If lTercRbq
	aTam:=TamSX3("DUV_ODOSR3")	//-- Odometro de Saida Reboque 3
	AAdd(aHeader,{RetTitle("DUV_ODOSR3"),"DUV_ODOSR3",PesqPict("DUV","DUV_ODOSR3"),aTam[1],aTam[2],"Tmsa350Vld()",GetSX3Cache("DUV_ODOSR3", "X3_USADO"), "N" ,"DUV"," "})
EndIf

If lTM350KMO
	aRet := ExecBlock('TM350KMO',.F.,.F.,{aClone(aHeader), lSaida})
	If	ValType(aRet) <> 'A'
		aRet := aClone(aHeader)
	EndIf
	aHeader := aClone(aRet)
EndIf

nUsado := Len(aHeader)

nPosCodVei := GdFieldPos("DTR_CODVEI",aHeader)
nPosDCodVe := GdFieldPos("DTR_MODVEI",aHeader)	//-- Descricao do Veiculo

nPosCodRB1 := GdFieldPos("DTR_CODRB1",aHeader)
nPosDCodB1 := GdFieldPos("DTR_MODRB1",aHeader)	//-- Descricao do 1o.Reboque

nPosCodRB2 := GdFieldPos("DTR_CODRB2",aHeader)
nPosDCodB2 := GdFieldPos("DTR_MODRB2",aHeader)	//-- Descricao do 2o.Reboque

If lTercRbq
	nPosCodRB3 := GdFieldPos("DTR_CODRB3",aHeader)
	nPosDCodB3 := GdFieldPos("DTR_MODRB3",aHeader)	//-- Descricao do 3o.Reboque
EndIf
nPosOdomet := GdFieldPos(IIf(lSaida,'DUV_ODOSAI','DUV_ODOENT'),aHeader)
nPosOdoRb1 := GdFieldPos(IIf(lSaida,'DUV_ODOSR1','DUV_ODOER1'),aHeader)
nPosOdoRb2 := GdFieldPos(IIf(lSaida,'DUV_ODOSR2','DUV_ODOER2'),aHeader)
If lTercRbq
	nPosOdoRb3 := GdFieldPos(IIf(lSaida,'DUV_ODOSR3','DUV_ODOER3'),aHeader)
EndIf

If !lSaida
	nPosOdoSai := GdFieldPos('DUV_ODOSAI',aHeader)  //-- Odometro de Saida
	nPosOdoSb1 := GdFieldPos('DUV_ODOSR1',aHeader)	//-- Odometro de Saida Reboque 1
	nPosOdoSb2 := GdFieldPos('DUV_ODOSR2',aHeader)	//-- Odometro de Saida Reboque 2
	If lTercRbq
		nPosOdoSb3 := GdFieldPos('DUV_ODOSR3',aHeader)	//-- Odometro de Saida Reboque 3
	EndIf
EndIf

//-- Montagem do aCols

//-- Se Atividade for Retorno do Porto, verifica se existe o registro do Retorno de Reboque
If DTW->DTW_ATIVID == cAtivRTP
	DF7->(DbSetOrder(3)) //DF7_FILIAL+DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI
	If DF7->(MsSeek(xFilial('DF7') + M->(DTW_FILORI+DTW_VIAGEM)))
		If DF7->DF7_STATUS == '1'
			lMostraDTR:= .F.
		EndIf
	Else
			lMostraRB := .F.
	EndIf
EndIf

DTR->(DbSetOrder(1))
DTR->(MsSeek(cSeek := xFilial('DTR')+cFilOri+cViagem))
aAreaDTR := DTR->(GetArea())
Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM)==cSeek
   cModVei := Posicione("DA3",1,xFilial("DA3") + DTR->DTR_CODVEI,"DA3_DESC")

	If lMostraRB
		If lMostraDTR
			cModRB1 := Posicione("DA3",1,xFilial("DA3") + DTR->DTR_CODRB1,"DA3_DESC")
			cModRB2 := Posicione("DA3",1,xFilial("DA3") + DTR->DTR_CODRB2,"DA3_DESC")
			If lTercRbq
				cModRB3 := Posicione("DA3",1,xFilial("DA3") + DTR->DTR_CODRB3,"DA3_DESC")
			EndIf
		Else
			cModRB1 := Posicione("DA3",1,xFilial("DA3") + DF7->DF7_CODRB1,"DA3_DESC")
			cModRB2 := Posicione("DA3",1,xFilial("DA3") + DF7->DF7_CODRB2,"DA3_DESC")
			If lTercRbq
				cModRB3 := Posicione("DA3",1,xFilial("DA3") + DF7->DF7_CODRB3,"DA3_DESC")
			EndIf
		EndIf
	EndIf
	If lSaida
		If DUV->(FieldPos("DUV_ODOSR1")) > 0
			AAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),nPosCodVei]:= DTR->DTR_CODVEI
			aCols[Len(aCols),nPosDCodVe]:= cModVei
			If lMostraRB
				If lMostraDTR
					aCols[Len(aCols),nPosCodRB1]:= DTR->DTR_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DTR->DTR_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DTR->DTR_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				Else
					aCols[Len(aCols),nPosCodRB1]:= DF7->DF7_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DF7->DF7_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DF7->DF7_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				EndIf
			EndIf
			aCols[Len(aCols),nPosOdomet]:= 0
			aCols[Len(aCols),nPosOdoRb1]:= 0
			aCols[Len(aCols),nPosOdoRb2]:= 0
			If lTercRbq
				aCols[Len(aCols),nPosOdoRb3]:= 0
			EndIf
			aCols[Len(aCols),nUsado+1]:= .F.
		Else
			AAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),nPosCodVei]:= DTR->DTR_CODVEI
			aCols[Len(aCols),nPosDCodVe]:= cModVei
			If lMostraRB
				If lMostraDTR
					aCols[Len(aCols),nPosCodRB1]:= DTR->DTR_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DTR->DTR_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DTR->DTR_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				Else
					aCols[Len(aCols),nPosCodRB1]:= DF7->DF7_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DF7->DF7_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DF7->DF7_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				EndIf
			EndIf
			aCols[Len(aCols),nPosOdomet]:= 0
			aCols[Len(aCols),nUsado+1]:= .F.
		EndIf
	Else
		DUV->(DbSetOrder(2)) // Tabela de Registros Entradas/Saidas de Veiculos
		DUV->(MsSeek(xFilial('DUV')+ DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI ))
		Do While !DUV->(Eof()) .And. xFilial('DUV')+DUV->DUV_FILORI+DUV->DUV_VIAGEM+;
			DUV->DUV_CODVEI == DTR->DTR_FILIAL+DTR->DTR_FILORI+DTR->DTR_VIAGEM+DTR->DTR_CODVEI
				nOdoSai := DUV->DUV_ODOSAI
				nOdoSR1 := DUV->DUV_ODOSR1
				nOdoSR2 := DUV->DUV_ODOSR2
				If lTercRbq
					nOdoSR3 := DUV->DUV_ODOSR3
				EndIf
			DUV->(dbSkip())
		EndDo
		If DUV->(FieldPos("DUV_ODOSR1")) > 0
			AAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),nPosCodVei]:= DTR->DTR_CODVEI
			aCols[Len(aCols),nPosDCodVe]:= cModVei
			If lMostraRB
				If lMostraDTR
					aCols[Len(aCols),nPosCodRB1]:= DTR->DTR_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DTR->DTR_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DTR->DTR_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				Else
					aCols[Len(aCols),nPosCodRB1]:= DF7->DF7_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DF7->DF7_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DF7->DF7_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				EndIf
			EndIf
			aCols[Len(aCols),nPosOdomet]:= 0
			aCols[Len(aCols),nPosOdoRb1]:= 0
			aCols[Len(aCols),nPosOdoRb2]:= 0
			If lTercRbq
				aCols[Len(aCols),nPosOdoRb3]:= 0
			EndIf
			aCols[Len(aCols),nPosOdoSai]:= nOdoSai //-- Odometro de Saida
			aCols[Len(aCols),nPosOdoSb1]:= nOdoSR1 //-- Odometro de Saida Reboque 1
			aCols[Len(aCols),nPosOdoSb2]:= nOdoSR2 //-- Odometro de Saida Reboque 2
			If lTercRbq
				aCols[Len(aCols),nPosOdoSb3]:= nOdoSR3 //-- Odometro de Saida Reboque 3
			EndIf
			aCols[Len(aCols),nUsado+1]:= .F.
		Else
			AAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),nPosCodVei]:= DTR->DTR_CODVEI
			aCols[Len(aCols),nPosDCodVe]:= cModVei
			If lMostraRB
				If lMostraDTR
					aCols[Len(aCols),nPosCodRB1]:= DTR->DTR_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DTR->DTR_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DTR->DTR_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				Else
					aCols[Len(aCols),nPosCodRB1]:= DF7->DF7_CODRB1
					aCols[Len(aCols),nPosDCodB1]:= cModRB1
					aCols[Len(aCols),nPosCodRB2]:= DF7->DF7_CODRB2
					aCols[Len(aCols),nPosDCodB2]:= cModRB2
					If lTercRbq
						aCols[Len(aCols),nPosCodRB3]:= DF7->DF7_CODRB3
						aCols[Len(aCols),nPosDCodB3]:= cModRB3
					EndIf
				EndIf
			EndIf
			aCols[Len(aCols),nPosOdomet]:= 0       //-- Odometro de Entrada
			aCols[Len(aCols),nPosOdoSai]:= nOdoSai //-- Odometro de Saida
			aCols[Len(aCols),nUsado+1]:= .F.
		EndIf
	EndIf
	DTR->(dbSkip())
EndDo
RestArea(aAreaDTR)

If lTM350KMA
	aRet := ExecBlock('TM350KMA',.F.,.F.,{aClone(aAlter), lSaida})
	If	ValType(aRet) <> 'A'
		aRet := aClone(aAlter)
	EndIf
	aAlter := aClone(aRet)
EndIf

If  ExistBlock("TM350OBB")
	lObrig := ExecBlock("TM350OBB",.F.,.F.,{aCols})
EndIf

If !Empty(aCols) .And. lObrig
	DEFINE MSDIALOG oDlg TITLE STR0022 From 9,0 To 28,80 OF oMainWnd //"Informe a Quilometragem do Veiculo"

		oGet := MSGetDados():New(35,3,142,314, 3,'AllwaysTrue','AllwaysTrue' ,,.F.,aAlter)

		oGet:oBrowse:bAdd := { || .F. }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||Iif(oGet:TudoOk() .And. TMSA350KmOk(lSaida), (nOpca := 1,oDlg:End()), nOpca :=0 )},{||nOpca:=0,If(MsgYesNo(STR0033,STR0018),Nil,oDlg:End() )}) //"O preenchimento da quilometragem é obrigatória. Deseja retornar e preencher os valores corretamente?"###"Atencao"
EndIf

If nOpca == 1 .And. lObrig
	For nX :=1 To Len(aCols)
		If lTercRbq
			TMSA430DUV(lSaida, cFilOri, cViagem, aCols[nX][nPosCodVei], aCols[nX][nPosCodRB1],;
					  aCols[nX][nPosCodRB2], aCols[nX][nPosOdomet], cFilAnt, dDatEnt, cHorEnt, dDatSai, cHorSai,Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],""),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],""),aCols[nX][nPosCodRB3],Iif(nPosOdoRB3 > 0,aCols[nX][nPosOdoRB3],""))
		Else
			TMSA430DUV(lSaida, cFilOri, cViagem, aCols[nX][nPosCodVei], aCols[nX][nPosCodRB1],;
					  aCols[nX][nPosCodRB2], aCols[nX][nPosOdomet], cFilAnt, dDatEnt, cHorEnt, dDatSai, cHorSai,Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],""),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],""))
		EndIf

		If lMntTms
			If DTW->DTW_ATIVID == cAtivChg .Or. DTW->DTW_FILATI <> DTW->DTW_FILORI
				//-- Desmonsta a Estrutura
				nAcao := 2
			Else
				//-- Monta Estrutura do Bem
				nAcao := 1
			EndIf
			If nAcao == 1
				cHora := Left(DUV->DUV_HORSAI,2) + ":" + SubStr(DUV->DUV_HORSAI,3,2)
				dData := DUV->DUV_DATSAI
				//-- Atualizar o Odometro - Integracao TMS X MNT (Manutencao de Ativos)
				If lTercRbq
					If	!TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,dData,cHora,,aCols[nX][nPosCodRB3],Iif(nPosOdoRB3 > 0,aCols[nX][nPosOdoRB3],0),aTrbEst)
						lRet := .F.
					EndIf
				Else
					If	!TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,dData,cHora,,,,aTrbEst)
						lRet := .F.
					EndIf
				EndIf
			EndIf
			//-- Caso o apontamento de chegada seja na filial de destino da viagem, a estrutura do bem sera desmontada
			If nAcao == 2 .And. ;
				DTW->DTW_ATIVID == cAtivChg .And. ;
				DTW->DTW_FILATI == Posicione("DTQ",2,xFilial("DTQ")+DTW->DTW_FILORI+DTW->DTW_VIAGEM,"DTQ_FILDES")
				//-- Desmonta Estrutura do Bem
				cHora := Left(DUV->DUV_HORENT,2) + ":" + SubStr(DUV->DUV_HORENT,3,2)
				dData := DUV->DUV_DATENT

				If lTercRbq
				//-- Atualizar o Odometro - Integracao TMS X MNT (Manutencao de Ativos)
					If !TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,dData,cHora,,aCols[nX][nPosCodRB3],Iif(nPosOdoRB3 > 0,aCols[nX][nPosOdoRB3],0),aTrbEst)
						lRet := .F.
					EndIf
				Else
					If !TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,dData,cHora,,,,aTrbEst)
						lRet := .F.
					EndIf
				EndIf
				If lRet
					//-- Verifica necessidade de manutenção preventiva
					nAcao := 3
					If lTercRbq
						If	!TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,,,,aCols[nX][nPosCodRB3],Iif(nPosOdoRB3 > 0,aCols[nX][nPosOdoRB3],0),aTrbEst)
							lRet := .F.
						EndIf
					Else
						If	!TMSAtuMnt(aCols[nX][nPosCodVei],aCols[nX][nPosCodRB1],aCols[nX][nPosCodRB2],aCols[nX][nPosOdomet],Iif(nPosOdoRB1 > 0,aCols[nX][nPosOdoRB1],0),Iif(nPosOdoRB2 > 0,aCols[nX][nPosOdoRB2],0),nAcao,,,,,,aTrbEst)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
Else
	If lKmObrig .And. lObrig
		Help("",1,"TMSA35020") //"Favor Informar a Quilometragem do Veiculo"
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

//-- Restaura GetDados Anterior
RestInter()

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„ot   ³TMSA350KmOk  ³ Autor ³Patricia A. Salomao    ³ Data ³14.06.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³TudoOk() da Tela de Apontamento de Chegada / Saida de Viagens  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA350KmOk(ExpL1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Saida ou Chegada de Viagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA350                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350KmOk(lSaida)

Local lRet   :=  .T.
Local cCampo :=  ''

Default lSaida := .T.

cCampo := IIf(lSaida,'DUV_ODOSAI','DUV_ODOENT')

If Empty(GdFieldGet(cCampo,n))
	Help('',1,'OBRIGAT2',,RetTitle(cCampo),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
	Return( .F. )
EndIf

If lTM350TKM
	lRet := ExecBlock('TM350TKM',.F.,.F.,{lSaida,GdFieldGet(cCampo,n)})
	If	ValType(lRet) <> 'L'
		lRet := .T.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA350Doc³ Autor ³ Alex Egydio           ³ Data ³28.09.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se incluiu na viagem documentos gerados na filial ³±±
±±³          ³ atual                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de origem da viagem                         ³±±
±±³          ³ ExpC2 - Codigo da viagem                                   ³±±
±±³          ³ ExpC3 - Codigo da atividade                                ³±±
±±³          ³ ExpC4 - Descricao da atividade                             ³±±
±±³          ³ ExpL1 - .T. = Apresenta help                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA350Doc(cFilOri,cViagem,cCodAti,cDesAti,lHelp)

Local aArea     := GetArea()
Local cAliasNew := ''
Local cQuery    := ''
Local lRet      := .F.
Local cSerTms   := StrZero(2,Len(DUD->DUD_SERTMS))
Local cTipTra   := StrZero(2,Len(DUD->DUD_TIPTRA))
Local cAtivChg  := GetMV('MV_ATIVCHG',,'')

DEFAULT cCodAti := ''
DEFAULT cDesAti := ''
DEFAULT lHelp   := .T.

DUD->(DbSetOrder(2))
DUD->( MsSeek(xFilial('DUD')+cFilOri+DTW->DTW_VIAGEM) )

If DTW->DTW_CATOPE == StrZero(2,Len(DTW->DTW_CATOPE)) .And.; //--EVENTUAL
	cCodAti == cAtivChg .And. cFilOri == DTW->DTW_FILATI

	//--ESTORNO DE CHEGADA EVENTUAL: Chegada eventual ocorrida na filial de
	//--origem da viagem.
	//--Buscar todos documentos (DUD) da mesma filial de
	//--origem da viagem, verificando o campo DUD_DOCTRF pois se no documento
	//--estiver com 1 significa que o DUD não foi incluido na origem da viagem.
	//--Caso exista algum documento com o status diferente de "2-EM TRANSITO"
	//--nao deve permitir o estorno do apontamento da operacao.

	cQuery := " SELECT COUNT(DUD_DOC) DUD_DOC "
	cQuery += " From " + RetSqlTab('DUD')
	cQuery += " Where DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery += " AND DUD_FILORI = '"+DTW->DTW_FILATI+"'"
	cQuery += " AND DUD_VIAGEM = '"+cViagem+"'"
	cQuery += " AND DUD_DOCTRF = '1' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	If (cAliasNew)->DUD_DOC > 0
		lRet := .T.
	EndIf
	(cAliasNew)->(DbCloseArea())

Else

	//--ESTORNO DE UM APONTAMENTO NORMAL
	cQuery := " SELECT COUNT(DUD_FILATU) DUD_COUNT"
	cQuery += " FROM " + RetSqlTab('DUD')
	cQuery += " WHERE DUD_FILIAL = '"+xFilial("DUD")+"'"
	cQuery += "   AND DUD_FILORI = '"+cFilOri+"'"
	cQuery += "   AND DUD_VIAGEM = '"+cViagem+"'"
	cQuery += "   AND DUD_FILATU = '"+cFilAnt+"'"
	cQuery += "   AND (( DUD_SERTMS = '"  + cSerTms + "' AND DUD_TIPTRA <> '" + cTipTra + "') "
	cQuery += "     OR ( DUD_SERTMS <> '" + cSerTms + "' AND DUD_TIPTRA  = '" + cTipTra + "') "
	cQuery += "     OR ( DUD_SERTMS <> '" + cSerTms + "' AND DUD_TIPTRA <> '" + cTipTra + "'))"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	cAliasNew := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	If	(cAliasNew)->DUD_COUNT > 0
		lRet := .T.
	EndIf

	(cAliasNew)->(DbCloseArea())
EndIf

If	lRet .And. lHelp
	Help("",1,"TMSA35021",,cCodAti + ' - ' + cDesAti + CHR(13) + CHR(10) + STR0021 + cViagem + CHR(13) + CHR(10) + STR0020 + cFilAnt,1,12) //"A operacao "###" nao sera estornada pois a viagem "###"contem documentos gerados na filial"
EndIf

RestArea(aArea)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA350Oco  ³ Autor ³Eduardo de Souza       ³ Data ³ 23/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe ocorrencia para o docto da viagem.         ³±±
±±³          ³ Quando informada uma ocorrencia para o documento, o status    ³±±
±±³          ³ do docto sera cancelado, encerrado ou sera bloqueado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Oco(ExpC1,ExpC2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                         ³±±
±±³          ³ ExpC2 - Viagem                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350/TMSA430                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Oco(cFilOri,cViagem)

Local lRet      := .T.
Local cQuery    := ""
Local cAliasTRB := ""
Local cStatus   := "'" + StrZero(4,Len(DUD->DUD_STATUS)) + "','" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
Local cNoDocBlq := "'" + StrZero(2,Len(DUD->DUD_STATUS)) + "','" + StrZero(3,Len(DUD->DUD_STATUS)) + "'"

cAliasTRB := GetNextAlias()
cQuery := " SELECT SUM(NREGDUD) NREGDUD FROM ( "
cQuery += " SELECT COUNT(DUD_FILIAL) NREGDUD "
cQuery += "   FROM "
cQuery += RetSqlName("DUD") + " DUD, "
cQuery += RetSqlName("DT6") + " DT6  "
cQuery += "   WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD.DUD_FILORI   = '" + cFilOri + "' "
cQuery += "   AND DUD.DUD_VIAGEM   = '" + cViagem + "' "
cQuery += "   AND DUD.DUD_SERTMS   <> '" + StrZero(2,Len(DUD->DUD_SERTMS)) + "' "
cQuery += "   AND DUD.DUD_STATUS IN ( " + cStatus + " ) "
If DUD->(ColumnPos("DUD_DTRNPR")) > 0
	cQuery += "	AND DUD.DUD_DTRNPR = ' ' "
EndIf
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery += "   AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
cQuery += "   AND DT6.DT6_DOC    = DUD.DUD_DOC "
cQuery += "   AND DT6.DT6_SERIE  = DUD.DUD_SERIE "
cQuery += "   AND DT6.DT6_BLQDOC IN ( " + cNoDocBlq + " ) "
cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
cQuery += " UNION ALL "
cQuery += " SELECT COUNT(DUD_FILIAL) NREGDUD  "
cQuery += "   FROM "
cQuery += RetSqlName("DUD") + " DUD, "
cQuery += RetSqlName("DT6") + " DT6  "
cQuery += "   WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD.DUD_FILORI   = '" + cFilOri + "' "
cQuery += "   AND DUD.DUD_VIAGEM   = '" + cViagem + "' "
cQuery += "   AND DUD.DUD_SERTMS   <> '" + StrZero(2,Len(DUD->DUD_SERTMS)) + "' "
cQuery += "   AND DUD.DUD_STATUS NOT IN ( " + cStatus + " ) "

If DUD->(ColumnPos("DUD_DTRNPR")) > 0
	cQuery += "	AND DUD.DUD_DTRNPR = ' ' "
EndIf

cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery += "   AND DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6.DT6_FILDOC = DUD.DUD_FILDOC "
cQuery += "   AND DT6.DT6_DOC    = DUD.DUD_DOC "
cQuery += "   AND DT6.DT6_SERIE  = DUD.DUD_SERIE "
cQuery += "   AND DT6.DT6_BLQDOC = '" + StrZero(1,Len(DT6->DT6_BLQDOC)) + "' "
cQuery += "   AND DT6.D_E_L_E_T_ = ' ' ) DUDDT6 "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTRB, .F., .T.)
If (cAliasTRB)->(!Eof())
	If (cAliasTRB)->NREGDUD > 0
		lRet := .F.
	EndIf
EndIf
(cAliasTRB)->(DbCloseArea())

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA350COp  ³ Autor ³Eduardo de Souza       ³ Data ³ 06/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancela as operacoes anteriores a sequencia atual.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350COp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350COp(cFilOri,cViagem,cSeqAte)
Local aAreaDTW := DTW->(GetArea())
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()

cQuery := " SELECT DTW_STATUS, R_E_C_N_O_ DTWRECNO "
cQuery += " FROM " + RetSqlName("DTW")
cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DTW_SEQUEN < '" + DTW->DTW_SEQUEN + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DTW_SEQUEN DESC"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	//-- Cancelada as operacoes anteriores em aberto.
	If (cAliasQry)->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS))
		DTW->(dbGoto((cAliasQry)->DTWRECNO))
		RecLock('DTW',.F.)
		DTW->DTW_DATINI := dDataBase
		DTW->DTW_HORINI := StrTran(Left(Time(),5),":","")
		DTW->DTW_DATREA := dDataBase
		DTW->DTW_HORREA := StrTran(Left(Time(),5),":","")
		DTW->DTW_STATUS := StrZero(9, Len(DTW->DTW_STATUS))
		If ColumnPos("DTW_SYSDAT") > 0
			DTW->DTW_SYSDAT := dDataBase
		EndIf
		If ColumnPos("DTW_SYSHOR") > 0
			DTW->DTW_SYSHOR := StrTran(Time(), ":", "")
		EndIf
		DTW->( MsUnLock() )
	EndIf
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
RestArea( aAreaDTW )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA350VOp  ³ Autor ³Eduardo de Souza       ³ Data ³ 06/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida as operacoes anteriores                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350VOp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                         ³±±
±±³          ³ ExpC2 - Viagem                                                ³±±
±±³          ³ ExpC3 - Sequencia                                             ³±±
±±³          ³ ExpL1 - Atividade de Chegada / Saida                          ³±±
±±³          ³ ExpC4 - Atividade de Chegada                                  ³±±
±±³          ³ ExpC5 - Atividade de Saida                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA350VOp(cFilOri,cViagem,cSequen,cAtivChg,cAtivSai,nCheSai,cAtvChgCli,cAtvSaiCli,cAtvChgApo,cAtvSaiApo)
Local aArea        := GetArea()
Local cQuery       := ""
Local lRet         := .T.
Local cAliasQry    := GetNextAlias()

Default cAtivChg   := ""
Default cAtivSai   := ""
Default cAtvChgCli := ""
Default cAtvSaiCli := ""
Default cAtvChgApo := ""
Default cAtvSaiApo := ""

cQuery := " SELECT DTW_ATIVID, DTW_FILATI "
cQuery += " FROM " + RetSqlName("DTW")
cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DTW_SEQUEN < '" + cSequen + "' "
cQuery += "   AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof())
	lRet := .F.
EndIf
DbSelectArea ("DUD")
DUD->( DbSetOrder(2) )
DbSeek(xFilial("DUD") + cFilOri + cViagem)
While (cAliasQry)->(!Eof())
	If (  ((cAliasQry)->(DTW_ATIVID) == Iif (Valtype(cAtivChg) != "C", AllTrim(STR(cAtivChg)), cAtivChg)   ;
	.Or.   (cAliasQry)->(DTW_ATIVID) == Iif (Valtype(cAtivSai) != "C", AllTrim(STR(cAtivSai)), cAtivSai) ) ;
	.And. ((cAliasQry)->(DTW_FILATI) == DUD->DUD_FILATU) )
		nCheSai := 1
	EndIf
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

If (DTW->DTW_ATIVID == cAtvSaiCli .Or. DTW->DTW_ATIVID == cAtvSaiApo)  .AND. (lRet .Or. nCheSai == 0)
	cQuery := "SELECT DTW_STATUS "
	cQuery += "FROM " + RetSqlName("DTW") + " "
	cQuery += "WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQuery += "AND DTW_FILORI = '" + cFilOri + "' "
	cQuery += "AND DTW_VIAGEM = '" + cViagem + "' "
	cQuery += "AND DTW_CODCLI = '" + DTW->DTW_CODCLI + "' "
	cQuery += "AND DTW_LOJCLI = '" + DTW->DTW_LOJCLI + "' "
	cQuery += "AND DTW_SEQUEN < '" + DTW->DTW_SEQUEN + "'"
	If !Empty(cAtvChgApo)
		cQuery += "AND DTW_ATIVID IN ('" + cAtvChgApo + "','" + cAtvChgCli+ "')"   
	Else
		cQuery += "AND DTW_ATIVID = '" + cAtvChgCli + "' "
	EndIf	
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DTW_SEQUEN DESC"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->DTW_STATUS == StrZero(1,Len(DTW->DTW_STATUS)) .Or. (cAliasQry)->DTW_STATUS == StrZero(9,Len(DTW->DTW_STATUS)) //1-Em Aberto, 9-Cancelado
		lRet := .F.
		nCheSai := 2
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

If (DTW->DTW_ATIVID == cAtvChgCli .Or. DTW->DTW_ATIVID == cAtvChgApo) .AND. nCheSai == 0

	If !A350DTWVal(cFilOri, cViagem)
		lRet := .F.
		nCheSai := 3
	EndIf

ElseIf DTW->DTW_ATIVID == cAtivChg .AND. nCheSai == 0 .AND. TMSA350Ret(cFilOri, cViagem)

	If !TMSVgTotTr(cFilOri, cViagem)
		lRet := .F.
		nCheSai := 4
	EndIf
	
EndIf

RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA350Viag³ Autor ³ Rodolfo Rosseto      ³ Data ³ 14/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA350Viag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA350Viag()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsVisViag(DTW->DTW_FILORI,DTW->DTW_VIAGEM,DTW->DTW_SERTMS,DTW->DTW_TIPTRA)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMA350VlEst³ Autor ³ Rodolfo Rosseto      ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida operacoes no estorno da viagem                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA350VlEst(ExpC1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial Origem da Viagem                            ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpC3 = Sequencia da Operacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA350VlEst(cFilOri,cViagem,cSequen,cAtivChg,cAtivSai,cAtivDca)

Local aArea     := GetArea()
Local lRet      := .F.
Local cAliasNew := ''
Local cQuery    := ''

cAliasNew:=GetNextAlias()
cQuery := " SELECT COUNT(DTW_FILIAL) CNT "
cQuery += " FROM " + RetSqlName("DTW")
cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DTW_SEQUEN > '" + cSequen + "' "
cQuery += "   AND DTW_ATIVID IN ('" + cAtivChg + "','" + cAtivSai + "','" + cAtivDca + "')"
cQuery += "   AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
cQuery += "   AND D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
If	(cAliasNew)->CNT > 0
	lRet := .T.
EndIf

DbSelectArea(cAliasNew)
DbCloseArea()

RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TM350Event ³ Autor ³ Eduardo de Souza     ³ Data ³ 31/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Chegada Eventual                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM350Event(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial Origem da Viagem                            ³±±
±±³          ³ ExpC2 = Viagem                                 			  ³±±
±±³          ³ ExpC3 = Filial Atividade da Chegada Eventual   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TM350Event(cFilOri,cViagem,cFilAti)

Local cAtivChg  := GetMV('MV_ATIVCHG',,'')
Local cAtivCan  := ''
Local aCab      := {}
Local nSequen   := 0
Local lGrvOk    := .T.
Local aAreaDTW  := DTW->(GetArea())
Local lUFAtiv   := DTW->(ColumnPos("DTW_UFATIV")) > 0
Local lIdDTW	:= DTW->(ColumnPos("DTW_IDDTW")) > 0
Local cIdDTW	:= ""

Default cFilAti := ""

//-- Obtem a sequencia anterior da atividade, somente para Viagem de Transferencia.
If DTW->DTW_SERTMS == StrZero(2,Len(DTW->DTW_SERTMS))
  If DTW->DTW_ATIVID == cAtivChg
  	  DTW->(dbSkip(-1))
  EndIf
EndIf

nSequen := 0
nSequen := Soma1(DTW->DTW_SEQUEN)
RecLock('DTW',.F.)
DTW->DTW_SEQUEN := nSequen
DTW->( MsUnLock() )
//-- Permitir a chegada/saida de uma viagem em uma filial nao prevista
DTW->(DbSetOrder(3)) //DTQ_FILIAL+DTQ_SERTMS+DTQ_TIPTRA+DTQ_FILORI+DTQ_VIAGEM
DTW->(DbSeek(xFilial('DTW') + cFilOri + cViagem + StrZero(1,Len(DTW->DTW_STATUS)),.T.))
nSequenOri	:= Soma1(nSequen)
nSequen 	:= Soma1(Soma1(nSequen))

//-- Gera Operacao de Chegada de Viagem Eventual
If DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_STATUS) == xFilial('DTW')+cFilOri+cViagem+StrZero(1,Len(DTW->DTW_STATUS))
	AAdd(aCab, {'DTW_FILIAL', xFilial('DTW')})
	AAdd(aCab, {'DTW_SEQUEN', nSequenOri})
	AAdd(aCab, {'DTW_TIPOPE', StrZero(2,Len(DTW->DTW_TIPOPE))})
	AAdd(aCab, {'DTW_DATPRE', dDataBase})
	AAdd(aCab, {'DTW_HORPRE', StrTran(Left(Time(),5),':','')})
	AAdd(aCab, {'DTW_DATINI', M->DTW_DATINI})
	AAdd(aCab, {'DTW_HORINI', M->DTW_HORINI})
	AAdd(aCab, {'DTW_DATREA', M->DTW_DATREA})
	AAdd(aCab, {'DTW_HORREA', M->DTW_HORREA})
	AAdd(aCab, {'DTW_ATIVID', GetMv('MV_ATIVCHG',,'')})
	AAdd(aCab, {'DTW_STATUS', StrZero(2,Len(DTW->DTW_STATUS))})
	AAdd(aCab, {'DTW_FILATI', cFilAnt})
	AAdd(aCab, {'DTW_FILATU', cFilAnt})
	AAdd(aCab, {'DTW_CATOPE', StrZero(2,Len(DTW->DTW_CATOPE))})
	
	If DTW->(ColumnPos("DTW_SYSDAT")) > 0
		AAdd(aCab, {'DTW_SYSDAT', dDataBase})
	EndIf
	If DTW->(ColumnPos("DTW_SYSHOR")) > 0
		AAdd(aCab, {'DTW_SYSHOR', StrTran(Time(), ":", "")})
	EndIf
	If lUFAtiv 
		Aadd( aCab, { 'DTW_UFATIV'	, DTW->DTW_UFATIV	, Nil } )
	EndIf
	
	If lIdDTW .And. ExistFunc("Tm351IdDTW")
		cIdDTW := Tm351IdDTW(cFilOri, cViagem)
		Aadd( aCab, { 'DTW_IDDTW'	,  cIdDTW	, Nil } )
	EndIf
	DbSelectArea("DTW")
	TmsCopyReg(aCab)
	cFilAti:= cFilAnt
EndIf
//-- Gera Operacao de Saida de Viagem Eventual
//-- A operacao de Saida de Viagem 'Eventual', sera' criada pela funcao TMSCriaDTW(), e nao atraves da funcao TMSA350Grv().
//-- Isto e' feito porque a funcao TMSA350Grv() executa a TMSMovViag(), que deixaria a operacao de 'Saida
//-- de Viagem Eventual' com Status 'Baixado' e a Viagem com Status 'Em Transito'; Sendo que o correto,
//-- e' gerar uma operacao de 'Chegada de Viagem Eventual' com Status 'Baixado' e uma Operacao de
//-- 'Saida de Viagem Eventual' com Status 'Em Aberto'; Ao apontar a Saida de Viagem, no Movto. de Veiculos/
//-- motorista, a Operacao de 'Saida de Viagem Eventual' ficara' com Status 'Baixado' e a Viagem com Status
//-- 'Em Transito'
If DTW->DTW_SERTMS == StrZero(2,Len(DTW->DTW_SERTMS)) //-- Transporte
	nSequenOri := Soma1(nSequenOri)
	aCab := {}
	AAdd( aCab, { 'DTW_FILORI'	, DTW->DTW_FILORI					, Nil } )
	AAdd( aCab, { 'DTW_VIAGEM'	, DTW->DTW_VIAGEM					, Nil } )
	AAdd( aCab, { 'DTW_SEQUEN'	, nSequenOri						, Nil } )
	AAdd( aCab, { 'DTW_DATPRE'	, dDataBase							, Nil } )
	AAdd( aCab, { 'DTW_HORPRE'	, StrTran(Left(Time(),5),':','')	, Nil } )
	AAdd( aCab, { 'DTW_DATINI'	, Ctod("")							, Nil } )
	AAdd( aCab, { 'DTW_HORINI'	, ""								, Nil } )
	AAdd( aCab, { 'DTW_DATREA'	, Ctod("")							, Nil } )
	AAdd( aCab, { 'DTW_HORREA'	, ""								, Nil } )
	AAdd( aCab, { 'DTW_SERVIC'	, DTW->DTW_SERVIC					, Nil } )
	AAdd( aCab, { 'DTW_TAREFA'	, DTW->DTW_TAREFA					, Nil } )
	AAdd( aCab, { 'DTW_ATIVID'	, GetMv("MV_ATIVSAI")				, Nil } )
	AAdd( aCab, { 'DTW_FILATI'	, cFilAnt							, Nil } )
	AAdd( aCab, { 'DTW_FILATU'	, cFilAnt							, Nil } )
	AAdd( aCab, { 'DTW_SERTMS'	, DTW->DTW_SERTMS					, Nil } )
	AAdd( aCab, { 'DTW_TIPTRA'	, DTW->DTW_TIPTRA					, Nil } )
	AAdd( aCab, { 'DTW_STATUS'	, StrZero(1,Len(DTW->DTW_STATUS))	, Nil } ) // Aberto
	AAdd( aCab, { 'DTW_TIPOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Tipo de Operacao == "Transporte"
	AAdd( aCab, { 'DTW_CATOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Categoria da operacao 2=Eventual.
	If DTW->(ColumnPos("DTW_SYSDAT")) > 0
		AAdd(aCab, {'DTW_SYSDAT', dDataBase})
	EndIf
	If DTW->(ColumnPos("DTW_SYSHOR")) > 0
		AAdd(aCab, {'DTW_SYSHOR', StrTran(Time(), ":", "")})
	EndIf
	If lUFAtiv 
		Aadd( aCab, { 'DTW_UFATIV'	, DTW->DTW_UFATIV	, Nil } )
	EndIf								
	If lIdDTW .And. ExistFunc("Tm351IdDTW")
		cIdDTW := Tm351IdDTW(cFilOri, cViagem)
		Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW	, Nil } )
	EndIf								
	lGrvOk := TMSCriaDTW( aCab )
Else
	//-- Para Coleta/Entrega devera ser atualizada a filial destino da viagem.
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("DTQ")+cFilOri+cViagem))
		RecLock("DTQ",.F.)
		DTQ->DTQ_FILDES := cFilAnt
		MsUnlock()
	EndIf

	//MLOG-3117 - Seja Viagem de Entrega ou de Coleta, o correto a se cancelar eh a proxima atividade,
	//e nao a anterior a que esta sendo apontada de forma Eventual.
	cAtivCan := cAtivChg

	DTW->(DbSetOrder(4)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI
	If DTW->(DbSeek(xFilial("DTW") + cFilOri + cViagem + cAtivCan + cFilOri))
		RecLock('DTW',.F.)
		DTW->DTW_DATREA := dDataBase
		DTW->DTW_HORREA := StrTran(Left(Time(),5),":","")
		DTW->DTW_STATUS := StrZero(9, Len(DTW->DTW_STATUS))
		DTW->( MsUnLock() )
	EndIf
EndIf

RestArea(aAreaDTW)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA350_V  ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ TMSA350.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub 	                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350_V()
Local nRet := 20061002 // 02 de outubro de 2006
Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuD350  ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MenuD350()
Local lAptJor	  := SuperGetMv("MV_CONTJOR",,.F.) //-- Apontamento da jornada de trabalho do motorista
Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cAtvChgApo  := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

Private aRotina	:=	{}

aAdd( aRotina, { STR0002 ,'TMSXPesqui',0,1,0,.F.} )	//-- 'Pesquisar'
aAdd( aRotina, { STR0003 ,'TmsA350Mnt',0,2,0,Nil} )	//-- 'Visualizar'
aAdd( aRotina, { STR0004 ,'TmsA350Mnt',0,3,0,Nil} )	//-- 'Apontar'
aAdd( aRotina, { STR0005 ,'TmsA350Est',0,5,0,Nil} )	//-- 'Estornar'
If lAptJor
	aAdd( aRotina, { STR0043 ,'TmsA350Mnt',0,6,0,Nil} )	//-- 'Esporádico'
EndIf
aAdd( aRotina, { STR0006 ,'TmsA350Leg',0,7,0,.F.} )	//-- 'Legenda'

If TableInDic("DLT") .And. ExistFunc('TMSA351Vis') .And. (!Empty(cAtvChgCli) .Or. !Empty(cAtvChgApo))
	aAdd( aRotina, { STR0069 ,'TmsA351Vis',0,8,0,.F.} )	//-- 'Documentos'
EndIf	

If ExistBlock("TMA350MNU")
	ExecBlock("TMA350MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Red³ Autor ³Andre Godoi	        ³ Data ³13.12.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o Apontamento e Estorno de Oorrencias para          ³±±
±±³			 ³ documentos de redespacho, ocorrencia Informativa     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Red()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 -> Opcao para apontamento de ociorrencia ou estorno. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA350Red(nOpcx,lRotAuto)

Local aArea     	:= GetArea()
Local aDUD     		:= DUD->(GetArea())
Local cQuery    	:= ""
Local cAliasQry 	:= GetNextAlias()
Local cOcorBx   	:= SuperGetMv('MV_OCORRDP',,"")
Local lEncViag  	:= SuperGetMv("MV_ENCVIAG",.F.,"2") == "1" //-- Define se devera encerrar a viagem com ocorrencia para todos documentos.
Local lTmsGfe		:= SuperGetMV( 'MV_TMSGFE',, .F. ) .And. (DFV->(FieldPos("DFV_UFORI")) > 0)
Local lRet			:= .T.
Local aRedesp		:= {}
Local nCount		:= 0
Local aAreaAnt	:= {}
Local aCab			:= {}
Local aItens		:= {}
Local aChaveDocs	:= {}	// Armazena a chave dos documentos apontados
Local lCmpDFV		:= DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0

Default lRotAuto  := .F.

Private lMsErroAuto := .F.

//-- Apontamento de Ocorrencia
If nOpcx == 3

	//-- Seleciona todos os Doc. de Redespacho da Viagem.
	cQuery	:= "SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE, DUD_SERTMS, DUD_NUMRED, DFT_CODFOR, DFT_LOJFOR, DUD_FILORI "
	cQuery	+= "  FROM " + RetSqlName("DUD") + " DUD "

	cQuery 	+= "  JOIN " + RetSQLName("DFV") + " DFV "
	cQuery	+= "    ON DFV.DFV_FILIAL	= '" + xFilial("DFV")  + "' "
	cQuery	+= "   AND DFV.DFV_FILDOC	= DUD.DUD_FILDOC "
	cQuery	+= "   AND DFV.DFV_DOC		= DUD.DUD_DOC "
	cQuery	+= "   AND DFV.DFV_SERIE	= DUD.DUD_SERIE "
	cQuery	+= "   AND DFV.DFV_STATUS 	<>'" + StrZero(9,Len(DFV->DFV_STATUS)) + "'"
	cQuery 	+= "   AND DFV.D_E_L_E_T_ 	= ' '"

	cQuery 	+= "  JOIN " + RetSQLName("DFT") + " DFT "
	cQuery	+= "    ON DFT.DFT_FILIAL	= '" + xFilial("DFT")  + "' "
	If lCmpDFV
		cQuery	+= "   AND DFT.DFT_FILORI	= DFV.DFV_FILORI "
	EndIf
	cQuery	+= "   AND DFT.DFT_NUMRED	= DFV.DFV_NUMRED "
	cQuery	+= "   AND DFT.DFT_CODFOR	= DFV.DFV_CODFOR "
	cQuery	+= "   AND DFT.DFT_LOJFOR	= DFV.DFV_LOJFOR "
	cQuery += "   AND DFT.D_E_L_E_T_ 	= ' '"

	cQuery	+= " WHERE DUD.DUD_FILIAL	= '" + xFilial("DUD")  + "' "
	cQuery	+= "   AND DUD.DUD_FILORI 	= '" + DTQ->DTQ_FILORI + "' "
	cQuery	+= "   AND DUD.DUD_VIAGEM 	= '" + DTQ->DTQ_VIAGEM + "' "
	cQuery	+= "   AND DUD.DUD_STATUS 	<>'" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"
	cQuery 	+= "   AND DUD.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof()) .And. (lRotAuto .Or. (!lRotAuto .And. MsgYesNo(STR0041, STR0018 )) ) //--"Deseja apontar as ocorrências para os documentos de redespacho desta viagem ?."###"Atencao"


		While (cAliasQry)->(!Eof())
			//--Documentos da viagem que serão atualizados
			AAdd(aChaveDocs, {(cAliasQry)->DUD_FILDOC, (cAliasQry)->DUD_DOC, (cAliasQry)->DUD_SERIE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM})
			//--- Quando a integracao do TMS x GFE esta ativa, as ocorrencias serao realizadas pela Baixa do Redespacho TMSAR05
			If lTmsGfe .And. !lTmsRDPU .And. Posicione('SA2',1,xFilial('SA2')+(cAliasQry)->DFT_CODFOR+(cAliasQry)->DFT_LOJFOR,'A2_PAGGFE')  == "1" //Sim
				//-- Pode haver mais de um Redespacho na viagem
				If lCmpDFV
					If Ascan(aRedesp,(cAliasQry)->DUD_FILORI + (cAliasQry)->DUD_NUMRED ) == 0
						AAdd(aRedesp,(cAliasQry)->DUD_FILORI + (cAliasQry)->DUD_NUMRED )
					EndIf
				Else
					If Ascan(aRedesp,(cAliasQry)->DUD_NUMRED ) == 0
						AAdd(aRedesp, (cAliasQry)->DUD_NUMRED )
					EndIf
				EndIf
			Else

				//-- Cabecalho da Ocorrencia
				AAdd(aCab,{'DUA_FILORI',DTQ->DTQ_FILORI,Nil})
				AAdd(aCab,{'DUA_VIAGEM',DTQ->DTQ_VIAGEM,Nil})

				//-- Itens da Ocorrencia
				AAdd(aItens,{;
				{'DUA_DATOCO', dDataBase								, Nil},;
				{'DUA_HOROCO', Strtran(Left(Time(),5),":","")	, Nil},;
				{'DUA_CODOCO', cOcorBx									, Nil},;
				{'DUA_SERTMS', StrZero(3,Len(DUD->DUD_SERTMS)) , Nil},;
				{'DUA_FILDOC', (cAliasQry)->DUD_FILDOC				, Nil},;
				{'DUA_DOC'   , (cAliasQry)->DUD_DOC					, Nil},;
				{'DUA_SERIE' , (cAliasQry)->DUD_SERIE				, Nil}})
			EndIf

			(cAliasQry)->(dbSkip())

		EndDo
		(cAliasQry)->(DbCloseArea())

		If Len(aRedesp) > 0
			For nCount:= 1 to Len(aRedesp)
				If lCmpDFV
					DFT->(DbSetOrder(2))
				Else
					DFT->(DbSetOrder(1))
				EndIf
				If	DFT->( MsSeek( xFilial('DFT') + aRedesp[nCount] ) )
					aAreaAnt:= GetArea()
					lRet:= TMSAR05Bax('DFT',DFT->(RECNO()),,.T.,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
					RestArea(aAreaAnt)
					If lEncViag .And. DTQ->DTQ_STATUS <> StrZero(3,Len(DTQ->DTQ_STATUS)) .And. lRet
						lRet:= TMSA340Grv(.T.)
					EndIf
				EndIf
			Next nCount

		ElseIf !Empty(aItens)
			MsExecAuto({|a,b,c,d|Tmsa360(a,b,c,d)},aCab,aItens,{},3)
			If !lMsErroAuto
				Aviso(STR0018, STR0040, {"Ok"})
			Else
				lRet:= .F.
			EndIf
			If lEncViag .And. DTQ->DTQ_STATUS <> StrZero(3,Len(DTQ->DTQ_STATUS)) .And. !lMsErroAuto
				TMSA340Grv(.T.)
			EndIf
		EndIf

		//Altera o Status dos documentos que foram apontados para "Encerrado" (DUD_STATUS=4)
		If lRet .AND. Len(aChaveDocs) > 0
			For nCount := 1 To Len(aChaveDocs)

				DUD->(DbSetOrder(1)) // DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
				DUD->(dbSeek(xFilial('DUD') + aChaveDocs[nCount][1] + aChaveDocs[nCount][2] + aChaveDocs[nCount][3] + aChaveDocs[nCount][4] + aChaveDocs[nCount][5]))
				While !DUD->(Eof()) .AND. DUD->DUD_FILIAL == xFilial('DUD') .AND. ;
					   DUD->DUD_FILDOC	== aChaveDocs[nCount][1] .AND. ;
					   DUD->DUD_DOC	    == aChaveDocs[nCount][2] .AND. ;
					   DUD->DUD_SERIE	== aChaveDocs[nCount][3] .AND. ;
					   DUD->DUD_FILORI	== aChaveDocs[nCount][4] .AND. ;
					   DUD->DUD_VIAGEM	== aChaveDocs[nCount][5]

					RecLock("DUD", .F.)
						DUD->DUD_STATUS := StrZero(4,Len(DUD->DUD_STATUS)) //-- Encerrado
					MsUnLock()

					DUD->(dbSkip())
				EndDo
			Next
		EndIf
	EndIf
ElseIf nOpcx == 5 //-- Estorno

   //-- Seleciona todos os apontamentos para os Doc do Redespacho.
	cQuery	:= "SELECT 	DUA.DUA_FILOCO, DUA.DUA_NUMOCO, DUA.DUA_FILORI, DUA.DUA_VIAGEM, "
	cQuery	+= " 		DUA.DUA_SEQOCO, DUA.DUA_DATOCO, DUA.DUA_HOROCO, DUA.DUA_CODOCO, DUA.DUA_SERTMS, "
	cQuery	+= " 		DUA.DUA_FILDOC, DUA.DUA_DOC,    DUA.DUA_SERIE,  DUA.DUA_QTDOCO, DUA.DUA_PESOCO, DFV.DFV_NUMRED "
	cQuery	+= "  FROM " + RetSqlName("DUD") + " DUD "

	cQuery 	+= "  JOIN " + RetSQLName("DFV") + " DFV "
	cQuery	+= "    ON DFV.DFV_FILDOC	= DUD.DUD_FILDOC "
	cQuery	+= "   AND DFV.DFV_DOC		= DUD.DUD_DOC "
	cQuery	+= "   AND DFV.DFV_SERIE	= DUD.DUD_SERIE "
	cQuery 	+= "   AND DFV.D_E_L_E_T_ 	= ' '"

	cQuery 	+= "  JOIN " + RetSQLName("DUA") + " DUA "
	cQuery	+= "    ON DUA.DUA_FILDOC	= DFV.DFV_FILDOC "
	cQuery	+= "   AND DUA.DUA_DOC		= DFV.DFV_DOC "
	cQuery	+= "   AND DUA.DUA_SERIE	= DFV.DFV_SERIE "
	cQuery	+= "   AND DUA.DUA_CODOCO	= '" + cOcorBx + "' "
	cQuery 	+= "   AND DUA.D_E_L_E_T_ 	= ' '"

	cQuery	+= " WHERE DUA.DUA_FILIAL	= '" + xFilial("DUA")  + "' "
	cQuery	+= "   AND DUD.DUD_FILORI 	= '" + DTQ->DTQ_FILORI + "' "
	cQuery	+= "   AND DUD.DUD_VIAGEM 	= '" + DTQ->DTQ_VIAGEM + "' "
	cQuery 	+= "   AND DUD.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof()) .And. Iif(lTMSRDPU,.T. ,MsgYesNo(STR0038, STR0018 ) ) //"Deseja estornar as ocorrências para os documentos de redespacho desta viagem ?."###"Atencao"

		//-- Cabecalho da Ocorrencia
		AAdd(aCab,{"DUA_FILOCO",(cAliasQry)->DUA_FILOCO,Nil})
		AAdd(aCab,{"DUA_NUMOCO",(cAliasQry)->DUA_NUMOCO,Nil})
		AAdd(aCab,{"DUA_FILORI",(cAliasQry)->DUA_FILORI,Nil})
		AAdd(aCab,{"DUA_VIAGEM",(cAliasQry)->DUA_VIAGEM,Nil})

		While (cAliasQry)->(!Eof())

			//-- Itens da Ocorrencia
			AAdd(aItens,{	{"DUA_SEQOCO", (cAliasQry)->DUA_SEQOCO , Nil},;
							{"DUA_ESTOCO", StrZero( 1, TamSX3('DUA_ESTOCO')[1]), Nil},;
							{"DUA_DATOCO", (cAliasQry)->DUA_DATOCO , Nil},;
							{"DUA_HOROCO", (cAliasQry)->DUA_HOROCO , Nil},;
							{"DUA_CODOCO", (cAliasQry)->DUA_CODOCO , Nil},;
							{"DUA_SERTMS", (cAliasQry)->DUA_SERTMS , Nil},;
							{"DUA_FILDOC", (cAliasQry)->DUA_FILDOC , Nil},;
							{"DUA_DOC"   , (cAliasQry)->DUA_DOC    , Nil},;
							{"DUA_SERIE" , (cAliasQry)->DUA_SERIE  , Nil},;
							{"DUA_QTDOCO", (cAliasQry)->DUA_QTDOCO , Nil},;
							{"DUA_PESOCO", (cAliasQry)->DUA_PESOCO , Nil}})
			//--Documentos a serem estornados
			AAdd(aChaveDocs, {(cAliasQry)->DUA_FILDOC, (cAliasQry)->DUA_DOC, (cAliasQry)->DUA_SERIE, (cAliasQry)->DUA_FILORI, (cAliasQry)->DUA_VIAGEM})

			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

		If !Empty(aItens)
			MsExecAuto({|a,b,c,d|Tmsa360(a,b,c,d)},aCab,aItens,{},6)
			If !lMsErroAuto
				Aviso(STR0018, STR0039, {"Ok"})
				//Altera o Status dos documentos que foram estornados para "Em Transito" (DUD_STATUS=2)
				If lRet .AND. Len(aChaveDocs) > 0
					For nCount := 1 To Len(aChaveDocs)

						DUD->(DbSetOrder(1)) // DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
						DUD->(dbSeek(xFilial('DUD') + aChaveDocs[nCount][1] + aChaveDocs[nCount][2] + aChaveDocs[nCount][3] + aChaveDocs[nCount][4] + aChaveDocs[nCount][5]))
						While !DUD->(Eof()) .AND. DUD->DUD_FILIAL == xFilial('DUD') .AND. ;
							   DUD->DUD_FILDOC	== aChaveDocs[nCount][1] .AND. ;
							   DUD->DUD_DOC	    == aChaveDocs[nCount][2] .AND. ;
							   DUD->DUD_SERIE	== aChaveDocs[nCount][3] .AND. ;
							   DUD->DUD_FILORI	== aChaveDocs[nCount][4] .AND. ;
							   DUD->DUD_VIAGEM	== aChaveDocs[nCount][5]

							RecLock("DUD", .F.)
								DUD->DUD_STATUS := StrZero(2,Len(DUD->DUD_STATUS)) //-- Em Transito
							MsUnLock()

							DUD->(dbSkip())
						EndDo
					Next
				EndIf
			EndIf
		EndIf

	EndIf
EndIf

If lMsErroAuto
	MostraErro()
	lRet:= .F.
EndIf

RestArea(aArea)
RestArea(aDUD)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA350Sta³ Autor ³Andre Godoi	       	³ Data ³13.12.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Status da tabela DFT, de acordo som os doc. da  ³±±
±±³			 ³ tabela filha DFV											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Sta()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA350Sta( cFilOri, cViagem)
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local lCmpDFV   := DFV->(ColumnPos("DFV_FILORI")) > 0 .And. DFV->(ColumnPos("DFV_TIPVEI")) > 0
Local cSeekRed  := ""
Local nIndRed   := 1
Local cQuery    := ""
Local lRetInd   := FindFunction("TMSRetInd")

Default cFilOri := ""
Default cViagem := ""

	cQuery := " SELECT "
	cQuery += " 	COUNT(DFV_DOC) INDICADO, 0 ENTREGUE, 0 ABERTO, DFV_NUMRED "
	If lCmpDFV
		cQuery += " , DFV_FILORI "
	EndIf
	cQuery += " 	FROM " + RetSqlName("DFV") + " DFV "
	cQuery += " INNER JOIN " + RetSqlName("DUD") + " DUD ON DUD.DUD_FILIAL='" + xFilial("DUD") + "'"
	cQuery += " 	AND DUD.DUD_FILDOC = DFV.DFV_FILDOC"
	cQuery += " 	AND DUD.DUD_DOC    = DFV.DFV_DOC"
	cQuery += " 	AND DUD.DUD_SERIE  = DFV.DFV_SERIE"
	cQuery += " 	AND DUD.DUD_FILORI ='" + cFilOri + "' "
	cQuery += " 	AND DUD.DUD_VIAGEM ='" + cViagem + "' "
	cQuery += " 	AND DUD.D_E_L_E_T_ = ' '"
	cQuery += " WHERE "
	cQuery += "	  	DFV.DFV_FILIAL = '" + xFilial("DFV") + "' "
	cQuery += " AND  	DFV.DFV_STATUS = '2' "
	cQuery += " AND	DFV.D_E_L_E_T_ = ' ' "
	If lCmpDFV
		cQuery += "	GROUP BY DFV_FILORI, DFV_NUMRED "
	Else
		cQuery += "	GROUP BY DFV_NUMRED "
	EndIf
	cQuery += " UNION ALL "
	cQuery += " SELECT "
	cQuery += " 	0 INDICADO ,COUNT(DFV_DOC) ENTREGUE, 0 ABERTO, DFV_NUMRED "
	If lCmpDFV
		cQuery += " , DFV_FILORI "
	EndIf
	cQuery += " 	FROM " + RetSqlName("DFV") + " DFV "
	cQuery += " INNER JOIN " + RetSqlName("DUD") + " DUD ON DUD.DUD_FILIAL='" + xFilial("DUD") + "'"
	cQuery += " 	AND DUD.DUD_FILDOC = DFV.DFV_FILDOC"
	cQuery += " 	AND DUD.DUD_DOC    = DFV.DFV_DOC"
	cQuery += " 	AND DUD.DUD_SERIE  = DFV.DFV_SERIE"
	cQuery += " 	AND DUD.DUD_FILORI ='" + cFilOri + "' "
	cQuery += " 	AND DUD.DUD_VIAGEM ='" + cViagem + "' "
	cQuery += " 	AND DUD.D_E_L_E_T_ =' '"
	cQuery += " WHERE "
	cQuery += "  	  	DFV.DFV_FILIAL = '" + xFilial("DFV") + "' "
	cQuery += " AND	DFV.DFV_STATUS = '3' "
	cQuery += " AND	DFV.D_E_L_E_T_ = ' ' "
	If lCmpDFV
		cQuery += "	GROUP BY DFV_FILORI, DFV_NUMRED "
	Else
		cQuery += "	GROUP BY DFV_NUMRED "
	EndIf
	cQuery += " UNION ALL "
	cQuery += " SELECT "
	cQuery += " 	0 INDICADO , 0 ENTREGUE, COUNT(DFV_DOC) ABERTO, DFV_NUMRED "
	If lCmpDFV
		cQuery += " , DFV_FILORI "
	EndIf
	cQuery += " 	FROM " + RetSqlName("DFV") + " DFV "
	cQuery += " INNER JOIN " + RetSqlName("DUD") + " DUD ON DUD.DUD_FILIAL='" + xFilial("DUD") + "'"
	cQuery += " 	AND DUD.DUD_FILDOC = DFV.DFV_FILDOC"
	cQuery += " 	AND DUD.DUD_DOC    = DFV.DFV_DOC"
	cQuery += " 	AND DUD.DUD_SERIE  = DFV.DFV_SERIE"
	cQuery += " 	AND DUD.DUD_FILORI ='" + cFilOri + "' "
	cQuery += " 	AND DUD.DUD_VIAGEM ='" + cViagem + "' "
	cQuery += " 	AND DUD.D_E_L_E_T_ = ' '"
	cQuery += " WHERE "
	cQuery += "  	  	DFV.DFV_FILIAL = '" + xFilial("DFV") + "' "
	cQuery += " AND	DFV.DFV_STATUS = '1' "
	cQuery += " AND	DFV.D_E_L_E_T_ = ' ' "
	If lCmpDFV
		cQuery += "	GROUP BY DFV_FILORI, DFV_NUMRED "
	Else
		cQuery += "	GROUP BY DFV_NUMRED "
	EndIf

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->(!Eof())
		If lRetInd
			cSeekRed:= TMSRetInd('DFT',(cAliasQry)->DFV_NUMRED,Iif(lCmpDFV,(cAliasQry)->DFV_FILORI,''),@nIndRed)
		Else
			cSeekRed:= (cAliasQry)->DFV_NUMRED
		EndIf

		DFT->(DbSetOrder(nIndRed))
		If DFT->(DbSeek( xFilial("DFT") + cSeekRed ))
			RecLock('DFT', .F.)
			If DFT->DFT_QTDDOC == (cAliasQry)->INDICADO
				DFT->DFT_STATUS := StrZero( 2, Len( DFT->DFT_STATUS ) )
			ElseIf DFT->DFT_QTDDOC == (cAliasQry)->ENTREGUE
				DFT->DFT_STATUS := StrZero( 3, Len( DFT->DFT_STATUS ) )
			ElseIf DFT->DFT_QTDDOC == (cAliasQry)->ABERTO
				DFT->DFT_STATUS := StrZero( 1, Len( DFT->DFT_STATUS ) )
			EndIf
			MsUnLock()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSStatVei³ Autor ³ Richard Anderson      ³ Data ³17.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o status do veiculo                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSStatVei()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function TMSStatVei(cFilOri,cViagem,nOpcx,cAtivid,nVeic)

Local nCnt     := 0
Local cSeekDTR := ''
Local cCodVei  := ''
Local cAtivChg := SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtivSai := SuperGetMV('MV_ATIVSAI',,'') //-- Atividade de Saida de Viagem
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0

Local aAreaDA3 := DA3->(GetArea())
Local aAreaDTR := DTR->(GetArea())
Local aPrev    := {}
Local aSeqSai  := {}

Local lCont := .T.

Default nVeic  := 4

DA3->(dbSetOrder(1))
DTR->(dbSetOrder(1))
DTR->(dbSeek(cSeekDTR := xFilial('DTR')+cFilOri+cViagem))

While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cSeekDTR
	For nCnt := 1 To nVeic
		//-- Chegada porto: Atualizar status do 1o. cavalo para em filial somente sem data final.
		//-- Saida   porto: Atualizar status do 2o. cavalo para em viagem somente sem data final.
		If nVeic == 1
			If (cAtivid == cAtivSai .And. DTR->DTR_ITEM == '01' .Or. ;
				cAtivid == cAtivChg .And. DTR->DTR_ITEM <> '01')
				Exit
			EndIf
		EndIf
		//-- Alterar Status veiculo e reboques.
		cCodVei:= ''
		If nCnt == 1
			cCodVei := DTR->DTR_CODVEI
		ElseIf nCnt == 2 .And. !Empty(DTR->DTR_CODRB1)
			cCodVei := DTR->DTR_CODRB1
		ElseIf nCnt == 3 .And. !Empty(DTR->DTR_CODRB2)
			cCodVei := DTR->DTR_CODRB2
		ElseIf nCnt == 4 .And. lTercRbq
			If !Empty(DTR->DTR_CODRB3)
				cCodVei := DTR->DTR_CODRB3
			EndIf
		EndIf
		lCont := .T.
		If Empty(cCodVei)
			lCont := .F.
			Exit
		Else
			If !DA3->(dbSeek(xFilial('DA3')+cCodVei))
				Aviso(STR0018, STR0071 + Alltrim(cCodVei) + STR0072, {"Ok"})	//-- "Atenção " ## "Veículo " ## " não encontrado."
				lCont := .F.
				Exit
			EndIf
		EndIf
		If lCont .And. nOpcx == 3 //-- Apontamento
			If cAtivid == cAtivSai
				RecLock("DA3",.F.)
				DA3->DA3_STATUS := "3"  // Em Viagem
				DA3->DA3_FILVGA := cFilOri
				DA3->DA3_NUMVGA := cViagem
				DA3->DA3_FILATU := CriaVar("DA3_FILATU",.F.)
				//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora do Apontamento. Atualizar dados de previsão.
				If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
					aPrev := TMSA350Prv('S', cFilOri, cViagem, cAtivChg)
					If !Empty(M->DTW_DATREA) .And. !Empty(M->DTW_HORREA)
						DA3->DA3_DATSTS := M->DTW_DATREA
						DA3->DA3_HORSTS := M->DTW_HORREA
					Else
						//Caso estas variaveis estejam vazias, indica que a rotina de Apontamentos está sendo chamada pela rotina de Movimentações.
						//Então, atualizar Data e Hora do Status do Veículo para a Data e Hora Corrente.
						DA3->DA3_DATSTS := dDataBase
						DA3->DA3_HORSTS := StrTran(Left(Time(),5),':','')
					EndIf
					If !Empty(aPrev)
						DA3->DA3_FILPRV := aPrev[1]
						DA3->DA3_DATPRV := StoD(aPrev[2])
						DA3->DA3_HORPRV := aPrev[3]
					EndIf
				EndIf
				MsUnLock()
			ElseIf cAtivid == cAtivChg
				RecLock("DA3",.F.)
				DA3->DA3_STATUS := "2"  // Em Filial
				DA3->DA3_FILVGA := ''
				DA3->DA3_NUMVGA := ''
				DA3->DA3_FILATU := cFilAnt
				//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora do Apontamento. Atualizar dados de previsão.
				If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
					If !Empty(M->DTW_DATREA) .And. !Empty(M->DTW_HORREA)
						DA3->DA3_DATSTS := M->DTW_DATREA
						DA3->DA3_HORSTS := M->DTW_HORREA
					EndIf
					DA3->DA3_FILPRV := ''
					DA3->DA3_DATPRV := StoD('')
					DA3->DA3_HORPRV := ''
				EndIf
				MsUnLock()
			EndIf
		ElseIf lCont .And. nOpcx == 5 //-- Estorno
			If cAtivid == cAtivSai
				RecLock("DA3",.F.)
				DA3->DA3_STATUS := "2"  // Em Filial
				DA3->DA3_FILVGA := ''
				DA3->DA3_NUMVGA := ''
				DA3->DA3_FILATU := cFilAnt
				//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora Corrente. Atualizar dados de previsão.
				If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
					aSeqSai := T350DHStat(.F.,cFilOri, cViagem, cAtivSai, cCodVei, nCnt , DTW->DTW_SERTMS)  
					If !Empty(aSeqSai) 
						aPrev := T350DHStat(.T.,cFilOri, cViagem, cAtivChg, cCodVei, nCnt, DTW->DTW_SERTMS)
						If aSeqSai[1] == DTW->DTW_SEQUEN
							DA3->DA3_DATSTS := If( !Empty(aPrev), StoD(aPrev[1]), StoD('') )	//dDataBase
							DA3->DA3_HORSTS := If( !Empty(aPrev), aPrev[2], '')					//StrTran(Left(Time(),5),':','')
							DA3->DA3_FILPRV := ''
							DA3->DA3_DATPRV := StoD('')
							DA3->DA3_HORPRV := ''
						EndIf
					EndIf
				EndIf
				MsUnLock()
			ElseIf cAtivid == cAtivChg
				RecLock("DA3",.F.)
				DA3->DA3_STATUS := "3"  // Em Viagem
				DA3->DA3_FILVGA := cFilOri
				DA3->DA3_NUMVGA := cViagem
				DA3->DA3_FILATU := CriaVar("DA3_FILATU",.F.)
				//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora Corrente. Atualizar dados de previsão.
				If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
					aPrev := TMSA350Prv('C', cFilOri, cViagem, cAtivSai)
					If !Empty(aPrev)
						DA3->DA3_DATSTS := StoD(aPrev[4])
						DA3->DA3_HORSTS := aPrev[5]
					EndIf
					DA3->DA3_FILPRV := DTW->DTW_FILATI
					DA3->DA3_DATPRV := DTW->DTW_DATPRE
					DA3->DA3_HORPRV := DTW->DTW_HORPRE
				EndIf
				MsUnLock()
			EndIf
		EndIf
	Next nCnt
	DTR->(dbSkip())
EndDo

RestArea(aAreaDA3)
RestArea(aAreaDTR)

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMA350VEsp³ Autor ³ Caio Murakami        ³ Data ³ 23/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida apontamento esporádio                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA350VEsp(ExpC1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial Origem da Viagem                            ³±±
±±³          ³ ExpC2 = Viagem                                 			  ³±±
±±³          ³ ExpC3 = Sequencia da Operacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA350VEsp(cFilOri,cViagem,cSequen, lVldVge , dDatPre , cHorPre )
Local lRet 			:= .T.
Local aAreaDTW    	:= {}
Local dDatDe		:= CToD("")
Local cHorDe		:= ""
Local dDatAte		:= CToD("")
Local cHorAte		:= ""

Default lVldVge 	:= .F. //-- Valida viagem
Default cSequen	:= ""

If lVldVge

   lRet := TMSChkViag(cFilOri, cViagem, .F., .F., .F., .F., .F., .F., .F., .F., .F., , .F., .T., .F., .F., .F., .F., ,  )

Else

	aAreaDTW    := DTW->( GetArea() )
	If !Empty(cSequen)
		DTW->( dbSetOrder(1) )
		If DTW->( MsSeek( xFilial("DTW") + cFilOri + cViagem + cSequen ) )
			lRet := .F.
		EndIf

	Else
		DTW->( dbSetOrder(1) )
		If DTW->( MsSeek( xFilial("DTW") + cFilOri + cViagem  ) )
	  		dDatDe := DTW->DTW_DATPRE
			cHorDe := DTW->DTW_HORPRE

			DTW->( dbSeek( xFilial('DTW') + cFilOri + cViagem + 'z', .T. ) )
			DTW->( dbSkip(-1) )
			If DTW->( !Eof() ) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == xFilial("DTW") + cFilOri + cViagem
			   dDatAte 	:= DTW->DTW_DATPRE
				cHorAte 	:= DTW->DTW_HORPRE
			Else
			   dDatAte 	:= dDatDe
				cHorAte 	:= dHorDe
			EndIf
		   If !(DtoS(dDatPre) + cHorPre >= DtoS(dDatDe)+cHorDe .And. DtoS(dDatPre) + cHorPre <= DToS(dDatAte) + cHorAte)
		   	lRet := .F.
		   	Help('',1,'TMSA35031') //-- Apontamento esporádico deve estar entre a primeira data prevista e última prevista dessa viagem.
		   EndIf
		EndIf

	EndIf
	RestArea(aAreaDTW)

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA350Apt³ Autor ³ Caio Murakami        ³ Data ³07.02.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza apontamento de refeicao e descanso			    	  ´±±
±±³ 			 ³	para a jornada do motorista										  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA350Apt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function TMSA350Apt(cFilOri, cViagem, nOpcx, cAtivid, dDatIni, cHorIni, dDatRea, cHorRea )
Local aArea			:= GetArea()
Local aAreaDTR 		:= DTR->( GetArea() )
Local aAreaDUP		:= DUP->( GetArea() )
Local cChaveDUP		:= ""
Local aCodMot		:= {}
Local aCab			:= {}
Local aItens		:= {}
Local aItemDEW   	:= {}
Local nCount		:= 0
Local nAux			:= 0
Local cAptJor  		:= ""
Local lFimApont		:= .F.
Local lAponta		:= .T.
Local dData	  		:= dDatIni
Local cHora			:= cHorIni
Local cAtivDes		:= GetMv('MV_ATIVDES',,'')
Local cAtivRef		:= GetMv('MV_ATIVREF',,'')
Local cAtivChg   	:= GetMV('MV_ATIVCHG',,'')
Local cAtivSai   	:= GetMV('MV_ATIVSAI',,'')
Local cAtivDca		:= GetMV('MV_ATIVDCA',,'')
Local nI			:= 0
Local aErro			:= {}
Local lRet			:= .T.
Local dIniVge     := CToD("")
Local cQuery      := ""
Local cAliasQry   := ""
Local lCont       := .T.

//-- Busca motoristas da viagem
DUP->( dbSetOrder(1) ) //-- DUP_FILIAL+DUP_FILORI+DUP_VIAGEM
If DUP->( MsSeek( cChaveDUP := xFilial("DUP") + cFilOri + cViagem ))
	While DUP->( !Eof() ) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == cChaveDUP
   	Aadd( aCodMot , DUP->DUP_CODMOT )
   	DUP->( dbSkip() )
	EndDo
EndIf

If nOpcx <> 5

	If !Empty(cHorRea)
		lFimApont 	:= .T.
	EndIf

	If lFimApont
		//-- Descanso
		If cAtivid == cAtivDes
			cAptJor := "ID" //-- Inicio Descanso
		//-- Refeicao
		ElseIf cAtivid == cAtivRef
			cAptJor := "IR" //-- Inicio Refeicao
		//-- Espera
		ElseIf cAtivid == cAtivDca
			cAptJor := "IE" //-- Fim Refeicao
		ElseIf cAtivid == cAtivChg
		 	cAptJor := "FV" //-- Fim Viagem
		ElseIf cAtivid == cAtivSai
		   cAptJor := "IV" //-- Inicio Viagem
		EndIf
	Else
		//-- Descanso
		If cAtivid == cAtivDes
			cAptJor := "ID" //-- Fim Descanso
		//-- Refeicao
		ElseIf cAtivid == cAtivRef
			cAptJor := "IR" //-- Fim Refeicao
		//-- Espera
		ElseIf cAtivid == cAtivDca
			cAptJor := "IE" //-- Fim Refeicao
		ElseIf cAtivid == cAtivChg
		 	lAponta := .F.
		ElseIf cAtivid == cAtivSai
		   lAponta := .F.
		EndIf
	EndIf

EndIf

If lAponta
	If cAtivid == cAtivChg
		cAliasQry := GetNextAlias()
	   	cQuery := " SELECT MAX(DTW_DATREA) DTW_DATREA "
	   	cQuery += "  FROM " + RetSQLName("DTW")
	   	cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
	   	cQuery += "   AND DTW_FILORI = '" + cFilOri  + "' "
	   	cQuery += "   AND DTW_VIAGEM = '" + cViagem  + "' "
	   	cQuery += "   AND DTW_ATIVID = '" + cAtivSai + "' "
	   	cQuery += "   AND D_E_L_E_T_ = ' ' "
	   	cQuery := ChangeQuery(cQuery)
	   	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.)
	   	If (cAliasQry)->(!Eof())
	   		dIniVge := SToD((cAliasQry)->DTW_DATREA)
		EndIf
		(cAliasQry)->(dbCloseArea())
		RestArea(aArea)
	EndIf

	For nCount := 1 To Len(aCodMot)
		aCab 		:= {}
		aItens	:= {}

		If nOpcx <> 5

			DA4->( dbSetOrder(1) )
			If DA4->( MsSeek( xFilial("DA4") + aCodMot[nCount] ) )
				Aadd( aCab, {"DA4_COD", aCodMot[nCount], Nil } )

				aItemDEW 	:= {}
				dData 		:= dDatIni
				cHora	  	:= cHorIni

				AO35SetVar( Iif(!Empty(dIniVge),dIniVge,dData), dDataBase )

				For nI := 1 To 2
					DEW->( dbSetOrder(1) )
					If !DEW->( MsSeek( xFilial("DEW") + aCodMot[nCount] + cAptJor + DtoS(dData) + cHora ) )

						Aadd( aItemDEW, {"DEW_APTJOR", cAptJor 	, Nil } )
						Aadd( aItemDEW, {"DEW_DATAPT", dData 	, Nil } )
						Aadd( aItemDEW, {"DEW_HORAPT", cHora	, Nil } )
						Aadd( aItemDEW, {"DEW_FILORI", cFilOri 	, Nil } )
						Aadd( aItemDEW, {"DEW_VIAGEM", cViagem 	, Nil } )
						Aadd( aItemDEW, {"DEW_TIPAPT", "1" 		, Nil } ) //-- Apontamento automatico
						Aadd(aItens,aClone(aItemDEW))

					EndIf

					If lFimApont .And. ( cAtivid == cAtivDes .Or. cAtivid == cAtivRef .Or. cAtivid == cAtivDca )
						aItemDEW 	:= {}
						dData		:= dDatRea
						cHora		:= cHorRea

						//-- Descanso
						If cAtivid == cAtivDes
							cAptJor := "FD"

						//-- Refeicao
						ElseIf cAtivid == cAtivRef
							cAptJor := "FR"
						
						//-- Espera
						ElseIf cAtivid == cAtivDca
							cAptJor	:= "FE"
						EndIf
					Else
						Exit
					EndIf
				Next nI

				If Len(aItens) > 0
					TMSMdlAuto( aCab , aItens , 4 , "TMSAO35" , "OMSA040_DA4" , "MdGridDEW" , "DA4" , "DEW",, STR0044 ) //-- "Controle de Jornada de Trabalho"
				EndIf

			EndIf
		Else
			lAponta := .T.
			DEW->( dbSetOrder(1) ) //-- DEW_FILIAL+DEW_CODMOT+DEW_APTJOR+DTOS(DEW_DATAPT)+DEW_HORAPT
			nAux    := 1

			DA4->( DbSetOrder( 1 ) )
			DA4->( DbSeek( xFilial( 'DA4' ) + aCodMot[nCount] ) )

			AO35SetVar( dDatRea, dDataBase )

			oModel := FwLoadModel( 'TMSAO35' )
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()

			While lAponta

				dData := dDatIni
				cHora	:= cHorIni

				If cAtivid == cAtivChg
					cAptJor 	:= "FV" //-- Fim Refeicao
					lAponta	:= .F.
				ElseIf cAtivid == cAtivSai
					cAptJor 	:= "IV" //-- Inicio Viagem
					lAponta	:= .F.
				EndIf

				If lAponta
					//-- Descanso
					If cAtivid == cAtivDes
						If nAux == 1
							cAptJor 	:= "FD" //-- Fim Descanso
							dData 		:= dDatRea
							cHora		:= cHorRea
						Else
							cAptJor 	:= "ID" //-- Inicio Descanso
							lAponta 	:= .F.
							dData		:= dDatIni
							cHora   	:= cHorIni
						EndIf
						//-- Refeicao
					ElseIf cAtivid == cAtivRef
						If nAux == 1
							cAptJor 	:= "FR" //-- Fim Refeicao
							dData 	:= dDatRea
							cHora		:= cHorRea
						Else
							cAptJor 	:= "IR" //-- Inicio Refeicao
							lAponta 	:= .F.
							dData		:= dDatIni
							cHora   	:= cHorIni
						EndIf
					ElseIf cAtivid == cAtivDca
						If nAux == 1
							cAptJor 	:= "FE" //-- Fim Espera
							dData 		:= dDatRea
							cHora		:= cHorRea
						Else
							cAptJor 	:= "IE" //-- Inicio Espera
							lAponta 	:= .F.
							dData		:= dDatIni
							cHora   	:= cHorIni
						EndIf
					EndIf
				EndIf

				If oModel:GetModel( 'MdGridDEW' ):SeekLine( {  {"DEW_APTJOR", cAptJor  }  } )
					lRet := oModel:GetModel( 'MdGridDEW' ):DeleteLine()
				Else
					lCont := .F.
				EndIf

				nAux++
			EndDo

			If lCont
				lRet := oModel:VldData()
				If lRet
					lRet := oModel:CommitData()
				EndIf
				If !lRet
					aErro := oModel:GetErrorMessage()

					AutoGrLog( 'STR0061' + ' [' + AllToChar( aErro[1] ) + ']' ) //-- "Id do formulário de origem:"
					AutoGrLog( 'STR0062' + ' [' + AllToChar( aErro[2] ) + ']' )  //-- "Id do campo de origem: "
					AutoGrLog( 'STR0063' + ' [' + AllToChar( aErro[3] ) + ']' )  //-- "Id do formulário de erro: "
					AutoGrLog( 'STR0064' + ' [' + AllToChar( aErro[4] ) + ']' )  //-- "Id do campo de erro: "
					AutoGrLog( 'STR0065' + ' [' + AllToChar( aErro[5] ) + ']' )  //-- "Id do erro: "
					AutoGrLog( 'STR0066' + ' [' + AllToChar( aErro[6] ) + ']' )  //-- "Mensagem do erro: "
					AutoGrLog( 'STR0067' + ' [' + AllToChar( aErro[7] ) + ']' )  //-- "Mensagem da solução: "
					AutoGrLog( 'STR0068' + ' [' + AllToChar( aErro[8] ) + ']' )  //-- "Valor atribuído: "
					AutoGrLog( 'STR0069' + ' [' + AllToChar( aErro[9] ) + ']' )  //-- "Valor anterior: "

					MostraErro()
				EndIf
			EndIf
			// Desativamos o Model
			oModel:DeActivate()

		EndIf
	Next nCount

EndIf


RestArea( aAreaDUP )
RestArea( aAreaDTR )
RestArea( aArea    )
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa350Cor³ Autor ³ Leandro Paulino       ³ Data ³30/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Legenda do Browser                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Tmsa350Cor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa350Cor()
Local aCores := {}

	AAdd(aCores,{"DTW_STATUS=='1'","BR_VERDE"		})	//-- Em Aberto
	AAdd(aCores,{"DTW_STATUS=='2'","BR_VERMELHO"	})	//-- Encerrado
	AAdd(aCores,{"DTW_STATUS=='9'","BR_PRETO"		})	//-- Cancelado

Return aCores

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDTWCli
Grava DTW por cliente dos documentos não previstos na viagem
@type function
@author Rafael Souza
@version 12
@since 10/05/2017
@return
/*/
//-------------------------------------------------------------------------------------------------
Function TmsDTWCli(cFilOri, cViagem, cRota, cCodCli, cLojaCli , lAptRealiz , cUfAtiv )

Local aAreaDA8		:= DA8->( GetArea() )
Local aAreaDC5		:= DC5->( GetArea() )
Local aAreaDC6		:= DC6->( GetArea() )
Local aAreaDTW   	:= DTW->(GetArea())
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')
Local cAtvSaiApo    := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local cSeekDC5		:= ''
Local lContinua		:= .T.
Local lIncSerCli	:= .F.
Local aCab       	:= {}
Local aServCli		:= {}
Local aCabDTW		:= {}
Local nB         	:= 0
Local lGrvOk    	:= .T.
Local cRet       	:= ""
Local cQuery     	:= ""
Local cQueryDTW		:= ""
Local cAliasNew		:= ""
Local cSeqEnt		:= ""
Local lRotaAut		:= FindFunction("F11RotRote") .AND. F11RotRote(DTQ->DTQ_ROTA)
Local nTamRotGer	:= 0
Local aRotGeral		:= {}
Local lUFAtiv   	:= DTW->(ColumnPos("DTW_UFATIV")) > 0
Local cIdDTW		:= ""
Local lIdDTW		:= DTW->(ColumnPos("DTW_IDDTW")) > 0 
Local lcriaDLT		:= .F. 
Local cOpeDoc		:= ""
Local lAtvApoio     := .F.

Default cFilOri 	:= ""
Default cViagem 	:= ""
Default cRota	  	:= ""
Default cCodCli 	:= ""
Default cLojaCli	:= ""
Default lAptRealiz	:= .T. //-- Aponta trabalho realizado
Default cUfAtiv		:= ""

If lRotaAut .And. AliasIndic('DJG')
	aRotGeral 	:= TMF10RtVge(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, , , ,2 )
	lRotaAut 	:= (nTamRotGer := Len(aRotGeral)) > 0
EndIf

If DA8->( MsSeek( xFilial( 'DA8' ) + cRota ,.F. ) )
	If	DC5->( MsSeek( cSeekDC5 := xFilial('DC5') + DA8->DA8_SERVIC, .F.) )

		While lContinua .And. DC5->( !Eof() .And. (DC5_FILIAL + DC5_SERVIC == cSeekDC5) )
			DC6->( MsSeek( xFilial("DC6") + DC5->DC5_TAREFA, .F.) )
			While lContinua .And. DC6->( !Eof() .And. DC6->DC6_TAREFA == DC5->DC5_TAREFA )
				//-- Se a atividade é do cliente, liga a flag
				If DC6->DC6_ATIVID == cAtvChgCli .Or. DC6->DC6_ATIVID == cAtvSaiCli
					lIncSerCli := .T.
				Else
					lIncSerCli := .F.
				EndIf

                If DC6->DC6_ATIVID == cAtvChgApo .OR. DC6->DC6_ATIVID == cAtvSaiApo
                    lAtvApoio := .T.
                EndIf

				//-- Todo o intervalo de atividades entre chegada e saída do cliente será guardado para geração da DTW
				If lIncSerCli
					Aadd(aServCli, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,cCodCli,cLojaCli,Posicione('SA1',1,FwxFilial('SA1')+cCodCli+cLojaCli,"A1_NOME") , cUfAtiv	})
				EndIf
				DC6->(dbSkip())
			EndDo
			DC5->(dbSkip())
		EndDo
	Else
		Help(' ', 1, 'TMSA31002',,STR0008 + DA8->DA8_SERVIC,5,11) //-- Servico nao encontrado (DC5). //'Servico : '
		lContinua := .F.
	EndIf
EndIf

If !Empty(DUD->DUD_DTRNPR) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) //Em Transito

    If lAtvApoio
        cAliasNew := GetNextAlias()
        cQuery := 	"SELECT DTW.DTW_IDDTW "
        cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
        cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
        cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
        cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
        cQuery += 	"AND DTW.DTW_ATIVID = '" + cAtvChgApo + "' "
        cQuery += 	"AND DTW.DTW_STATUS = '2' "
        cQuery += 	"AND DTW.D_E_L_E_T_ = ' ' "
        cQuery +=   "ORDER BY DTW.DTW_IDDTW DESC"
        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

        If (cAliasNew)->(!Eof()) .AND. ExistFunc("Tmsa351DLT")
			cOpeDoc	:= "2"  //Emissão
			
			aSize(aCabDTW,0)
			Aadd( aCabDTW, { 'DTW_FILORI'	, cFilOri	, Nil } )
			Aadd( aCabDTW, { 'DTW_VIAGEM'	, cViagem	, Nil } ) 
			Aadd( aCabDTW, { 'DTW_IDDTW'	, (cAliasNew)->DTW_IDDTW		, Nil } )  
	        
			Tmsa351DLT(aCabDTW, 4, cFilOri, cViagem, (cAliasNew)->DTW_IDDTW, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "2", cOpeDoc)
		EndIf
        (cAliasNew)->(dbCloseArea())
    EndIf

	For nB := 1 To Len( aServCli )
		//-- Define a sequencia na DTW
		cAliasNew := GetNextAlias()
		cQueryDTW	:= "  SELECT MAX(DTW_SEQUEN) MAXSEQ "
		cQueryDTW	+= "  FROM  " + RetSqlName("DTW") + " DTW "
		cQueryDTW	+= "  WHERE DTW.DTW_FILIAL = '"+ FwxFilial("DTW") +"' "
		cQueryDTW	+= "  AND DTW.DTW_FILORI = '"+ cFilOri +"' "
		cQueryDTW	+= "  AND DTW.DTW_VIAGEM = '"+ cViagem +"' "
		cQueryDTW += "  AND DTW.DTW_STATUS = '2'"
		cQueryDTW	+= "  AND DTW.D_E_L_E_T_ = ' '"

		cQueryDTW := ChangeQuery(cQueryDTW)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryDTW),cAliasNew,.T.,.T.)

		If (cAliasNew)->(!Eof())
			cSeqEnt := (cAliasNew)->MAXSEQ
		EndIf

		(cAliasNew)->(dbCloseArea())

		cSeqEnt:= Soma1(cSeqEnt)
		cRet   := cSeqEnt

		aCab := {}
		If lIdDTW .And. ExistFunc("Tm351IdDTW") 
			cIdDTW	:= Tm351IdDTW( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM	)
		EndIf
		If 	aServCli[nB, 3] == cAtvChgCli
			Aadd( aCab, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
			Aadd( aCab, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } )
			Aadd( aCab, { 'DTW_SEQUEN'	, cRet				, Nil } )
			Aadd( aCab, { 'DTW_DATPRE'	, dDataBase			, Nil } )
			Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(Time(),5),':',''), Nil } )
						
			If lAptRealiz
				Aadd( aCab, { 'DTW_DATINI'	, dDataBase			, Nil } )
				Aadd( aCab, { 'DTW_HORINI'	, StrTran(Left(Time(),5),':','')	, Nil } )
				Aadd( aCab, { 'DTW_DATREA'	, dDataBase			, Nil } )
				Aadd( aCab, { 'DTW_HORREA'	, StrTran(Left(Time(),5),':','')	, Nil } )
				Aadd( aCab, { 'DTW_STATUS'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) //-- 2 = Encerrada
				
				If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .And. DTW->(ColumnPos("DTW_SYSHOR")) > 0
					AAdd(aCab, {'DTW_SYSDAT', dDataBase})
					AAdd(aCab, {'DTW_SYSHOR', StrTran(Time(), ":", "")})
				EndIf

			Else
				Aadd( aCab, { 'DTW_DATINI'	, Ctod('')			, Nil } )
				Aadd( aCab, { 'DTW_HORINI'	, ''				, Nil } )
				Aadd( aCab, { 'DTW_DATREA'	, Ctod('')			, Nil } )
				Aadd( aCab, { 'DTW_HORREA'	, ''				, Nil } )
				Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,Len(DTW->DTW_STATUS))	, Nil } ) //-- 1 = Em Aberto
			EndIf

			Aadd( aCab, { 'DTW_SERVIC'	, aServCli[nB, 1]	, Nil } )
			Aadd( aCab, { 'DTW_TAREFA'	, aServCli[nB, 2]	, Nil } )
			Aadd( aCab, { 'DTW_ATIVID'	, aServCli[nB, 3]	, Nil } )
			Aadd( aCab, { 'DTW_FILATI'	, aServCli[nB, 5]	, Nil } )
			Aadd( aCab, { 'DTW_CODCLI'	, aServCli[nB, 6]	, Nil } )
			Aadd( aCab, { 'DTW_LOJCLI'	, aServCli[nB, 7]	, Nil } )
			Aadd( aCab, { 'DTW_NOMCLI'	, aServCli[nB, 8]	, Nil } )
			Aadd( aCab, { 'DTW_SERTMS'	, DTQ->DTQ_SERTMS	, Nil } )
			Aadd( aCab, { 'DTW_TIPTRA'	, DTQ->DTQ_TIPTRA	, Nil } )			
			Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Tipo de Operacao == "Transporte"
			AAdd( aCab, { 'DTW_CATOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Categoria da operacao 2=Eventual.
			
			If lUfAtiv
				Aadd(aCab , { "DTW_UFATIV" , aServCli[nB, 9] , Nil }  )
			EndIf
			
			If lIdDTW .And. TableInDic("DLT")
				Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW	    , Nil } )
				lcriaDLT := .T. 
			EndIf
		Else
			Aadd( aCab, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
			Aadd( aCab, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } )
			Aadd( aCab, { 'DTW_SEQUEN'	, cRet				, Nil } )
			Aadd( aCab, { 'DTW_DATPRE'	, dDataBase			, Nil } )
			Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(Time(),5),':',''), Nil } )
			Aadd( aCab, { 'DTW_DATREA'	, Ctod('')			, Nil } )
			Aadd( aCab, { 'DTW_HORREA'	, ''				, Nil } )
			Aadd( aCab, { 'DTW_SERVIC'	, aServCli[nB, 1]	, Nil } )
			Aadd( aCab, { 'DTW_TAREFA'	, aServCli[nB, 2]	, Nil } )
			Aadd( aCab, { 'DTW_ATIVID'	, aServCli[nB, 3]	, Nil } )
			Aadd( aCab, { 'DTW_FILATI'	, aServCli[nB, 5]	, Nil } )
			Aadd( aCab, { 'DTW_CODCLI'	, aServCli[nB, 6]	, Nil } )
			Aadd( aCab, { 'DTW_LOJCLI'	, aServCli[nB, 7]	, Nil } )
			Aadd( aCab, { 'DTW_NOMCLI'	, aServCli[nB, 8]	, Nil } )
			Aadd( aCab, { 'DTW_SERTMS'	, DTQ->DTQ_SERTMS	, Nil } )
			Aadd( aCab, { 'DTW_TIPTRA'	, DTQ->DTQ_TIPTRA	, Nil } )
			Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,Len(DTW->DTW_STATUS))	, Nil } )
			Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Tipo de Operacao == "Transporte"
			AAdd( aCab, { 'DTW_CATOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Categoria da operacao 2=Eventual.
			
			If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .And. DTW->(ColumnPos("DTW_SYSHOR")) > 0
				AAdd(aCab, {'DTW_SYSDAT', CToD("")})
				AAdd(aCab, {'DTW_SYSHOR', ""})
			EndIf

			If lUfAtiv
				Aadd(aCab , { "DTW_UFATIV" , aServCli[nB, 9] , Nil }  )
			EndIf

			If lIdDTW
				Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW	     , Nil } )
		    EndIf
		EndIf
		
		//-- Ordena vetor de acordo com dicionário de dados
		aCabDTW	:= aClone( FwVetByDic( aClone(aCab) ,"DTW") ) 

		//-- Cria a DTW
		    lGrvOk := TMSCriaDTW( aCabDTW )

		//-- Cria DLT 
		If lGrvOk .And. ExistFunc("Tmsa351DLT") .And. lcriaDLT
			If DT6->DT6_SERIE == "COL"
				cOpeDoc	:= "3"
			ElseIf (cCodCli + cLojaCli == DT6->DT6_CLIREM + DT6->DT6_LOJREM) .Or. (cCodCli + cLojaCli == DT6->DT6_CLIEXP + DT6->DT6_LOJEXP)
				cOpeDoc	:= "2"  //Emissão
			Else
				cOpeDoc	:= "1"	//Entrega
			EndIf 
			aSize(aCabDTW,0)
			Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
			Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
			Aadd( aCabDTW, { 'DTW_IDDTW'	, cIdDTW			, Nil } )  
	        
			If aServCli[nB, 3] == cAtvChgCli
				Tmsa351DLT(aCabDTW, 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cIdDTW, DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE, "2", cOpeDoc)
			EndIf	
		EndIf 
		//-- Limpa arrays
		aSize(aCab,0)
		aSize(aCabDTW,0)

	Next nB
EndIf

//-- Limpa array
aSize(aServCli,0)

RestArea( aAreaDC6 )
RestArea( aAreaDC5 )
RestArea( aAreaDA8 )
RestArea( aAreaDTW )

Return

//==========================================================================================
/*/{Protheus.doc} IntegDef(cXml, cTypeTrans, cTypeMessage)
FUNÇÃO DE ENVIO DE MENSAGEM UNICA - Apontamento de Operações
@class
@author Paulo Henrique Corrêa Cardoso
@version    1.0
@since      26/11/15
@return     aRet //Indica se a mensagem foi processada com sucesso/Xml de retorno da funcao
@Param  	cXml
@Param		nTypeTrans
@Param     cTypemessage
@sample
/*/
//==========================================================================================
Static Function IntegDef( cXML, cTypeTrans, cTypeMessage, cVersion )

Local aRet := {}		// Recebe o Retorno

aRet := TMSI350(cXml, cTypeTrans, cTypeMessage, cVersion)


Return aRet

//==========================================================================================
/*/{Protheus.doc} Previsao(cFilOri, cViagem)
Busca dos dados de previsão da próxima Operação de Chegada.
@class
@author Aluizio Fernando Habizenreuter
@version    1.0
@since      01/08/18
@return     aRet //Retorna a Filial, Data e Hora Previstas da próxima chegada.
@sample
/*/
//==========================================================================================
Function TMSA350Prv(cTpAtiv, cFilOri, cViagem, cAtiv)
Local cQueryDTW := ""
Local aAreaDTW  := DTW->(GetArea())
Local cAliasDTW := GetNextAlias()
Local aRet := {}

cQueryDTW := " SELECT DTW.DTW_FILATI, DTW.DTW_DATPRE, DTW.DTW_HORPRE, DTW.DTW_DATREA, DTW.DTW_HORREA "
cQueryDTW +=   " FROM " + RetSqlName("DTW") + " DTW "
cQueryDTW +=  " WHERE DTW.DTW_FILIAL = '"+ xFilial("DTW") +"' "
cQueryDTW +=    " AND DTW.DTW_FILORI = '"+ cFilOri  +"' "
cQueryDTW +=    " AND DTW.DTW_VIAGEM = '"+ cViagem  +"' "
cQueryDTW +=    " AND DTW.DTW_ATIVID = '"+ cAtiv +"' "
cQueryDTW +=    " AND DTW.D_E_L_E_T_ = ' '"
If cTpAtiv == "S"
	cQueryDTW +=    " AND DTW.DTW_STATUS = '1'" //Para apontamento de Saída, considerar somente operações de Chegada Pendentes, ordenado pela sequencia crescente.
	cQueryDTW +=  " ORDER BY DTW.DTW_SEQUEN "
Else
	cQueryDTW +=    " AND DTW.DTW_STATUS = '2'" //Para estorno de apontamento de Chegada, considerar somente operações de Saída Encerradas, ordenado pela sequencia decrescente.
	cQueryDTW +=  " ORDER BY DTW.DTW_SEQUEN DESC"
EndIf

cQueryDTW := ChangeQuery(cQueryDTW)
dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryDTW),cAliasDTW,.T.,.T.)

If (cAliasDTW)->(!Eof())
	AAdd(aRet,(cAliasDTW)->DTW_FILATI)
	AAdd(aRet,(cAliasDTW)->DTW_DATPRE)
	AAdd(aRet,(cAliasDTW)->DTW_HORPRE)
	AAdd(aRet,(cAliasDTW)->DTW_DATREA)
	AAdd(aRet,(cAliasDTW)->DTW_HORREA)
EndIf

(cAliasDTW)->(dbCloseArea())

RestArea(aAreaDTW)

Return aRet

//==========================================================================================
/*/{Protheus.doc} Previsao(cFilOri, cViagem)
.
@class
@author 	 Alex Amaral
@version    1.0
@since      30/10/18
@return     lRet //Retorna a Filial pendente para mesma UF.
@sample
/*/
//==========================================================================================

Static Function TMA350DTW(cFilOri,cViagem,cAtvChgCli,cAtvSaiCli,cFilUF)

Local lRet      := .T.
Local cQuery    := ''
Local cAliasDTW := GetNextAlias()
Local lUFAtiv   := DTW->(ColumnPos("DTW_UFATIV")) > 0

Default cFilUF     := ''
Default cAtvChgCli := ''
Default cAtvSaiCli := ''


		cQuery := " SELECT 1 "
		cQuery += " FROM " + RetSqlName("DTW")
		cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' " 		
		If !Empty(cAtvChgCli) 
			cQuery += "   AND DTW_ATIVID = '" + cAtvChgCli + "'"
		Else 
			cQuery += "   AND DTW_ATIVID = '" + cAtvSaiCli + "'"
		EndIf
		cQuery += "   AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
		If lUFAtiv
			cQuery += "   AND DTW_UFATIV = '" + cFilUF + "' "
		EndIf	
		cQuery += "   AND D_E_L_E_T_ = '' "		
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDTW,.F.,.T.)

		If (cAliasDTW)->(!Eof()) 
			lRet := .F.			
		EndIf
				
DbSelectArea(cAliasDTW)
DbCloseArea()

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMA350VlEst³ Autor ³ Rodolfo Rosseto      ³ Data ³ 03/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida operacoes no estorno da viagem                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA350VlEst(ExpC1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial Origem da Viagem                            ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpC3 = Sequencia da Operacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TM350OcoAt(cFilOri, cViagem, nOpcx)
Local lRet      := .F.
Local cAliasNew := ''
Local cQuery    := ''
Local cAtvChg	:= SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtChCli  := SuperGetMV('MV_ATVCHGC',,'') //-- Atividade de Chegada de Viagem Cliente

Default cFilOri := ""
Default cViagem := ""
Default nOpcx   := 3

If ExistFunc('TMSOcoAut')
	cAliasNew:=GetNextAlias()
	cQuery := " SELECT DTW_STATUS, MAX(R_E_C_N_O_) DTWRECNO "
	cQuery += " FROM " + RetSqlName("DTW")
	cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
	cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND (DTW_ATIVID = '" + cAtvChg +"' "
	cQuery += "  OR DTW_ATIVID = '" + cAtChCli +"') "
	If nOpcx == 3
		cQuery += " AND DTW_STATUS = '" + StrZero(1,Len(DTW->DTW_STATUS)) + "' "
	Else
		cQuery += " AND DTW_STATUS = '" + StrZero(2,Len(DTW->DTW_STATUS)) + "' "
	EndIf
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " GROUP BY DTW_STATUS "
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	
	If (cAliasNew)->DTWRECNO == 0
		TMSOcoAut(cFilOri, cViagem, nOpcx)
	EndIf

	(cAliasNew)->( DbCloseArea() )
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} T350DHStat
Função para buscar a última viagem do veículo para 
atualizar a data e hora de status do veículo
@author  ana.olegini
@since   16/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T350DHStat(lOrder, cFilOri, cViagem, cAtiv, cCodVei, nCnt, cSerDTW)
	Local aAreaDTW    := DTW->(GetArea())
	Local aRetorno	  := {}                                                             
	Local cQueryTMP	  := ""
	Local cAliasTMP   := GetNextAlias()	

	Default lOrder  := .F.
	Default cFilOri := ""
	Default cViagem := ""
	Default cAtiv   := ""
	Default cCodVei := ""
	Default nCnt    := 0
	Default cSerDTW := "" 

	If Type("cSerTms") == "U" .And. !Empty(cSerDTW)
		cSerTms:= cSerDTW
	EndIf

	cQueryTMP := " SELECT DTW.DTW_VIAGEM, DTW.DTW_SEQUEN, DTW.DTW_DATREA , DTW.DTW_HORREA, DTW.DTW_SERTMS "
	cQueryTMP +=   " FROM " + RetSqlName("DTR") + " DTR "
  	cQueryTMP +=  " INNER JOIN " + RetSqlName("DTW") + " DTW " 
	cQueryTMP +=     " ON DTW.D_E_L_E_T_ = '' "
	cQueryTMP +=    " AND DTW.DTW_FILIAL = '" + FWxFilial("DTW") + "'"
	cQueryTMP +=    " AND DTW.DTW_FILORI = DTR.DTR_FILORI "
    cQueryTMP +=    " AND DTW.DTW_VIAGEM = DTR.DTR_VIAGEM "
	cQueryTMP +=    " AND DTW.DTW_ATIVID = '" + cAtiv + "'"
	cQueryTMP +=  " INNER JOIN " + RetSqlName("DTQ") + " DTQ " 
	cQueryTMP +=     " ON DTQ.D_E_L_E_T_ = '' "
	cQueryTMP +=    " AND DTQ.DTQ_FILIAL = '" + FWxFilial("DTQ") + "'"
	cQueryTMP +=    " AND DTQ.DTQ_FILORI = DTR.DTR_FILORI "
	cQueryTMP +=    " AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM "
	If lOrder
		cQueryTMP +=    " AND DTQ.DTQ_STATUS = '3' "	
	EndIf
	cQueryTMP +=  " WHERE DTR.D_E_L_E_T_ = '' "
	cQueryTMP +=    " AND DTR.DTR_FILIAL = '" + FWxFilial("DTR") + "'"
	cQueryTMP +=    " AND DTR.DTR_FILORI = '" + cFilOri + "'"
	
	IF nCnt = 1
		cQueryTMP +=    " AND DTR.DTR_CODVEI = '" + cCodVei + "'"	
	ElseIf nCnt == 2
		cQueryTMP +=    " AND DTR.DTR_CODRB1 = '" + cCodVei + "'"
	ElseIf nCnt == 3
		cQueryTMP +=    " AND DTR.DTR_CODRB2 = '" + cCodVei + "'"
	ElseIf nCnt == 4 
		cQueryTMP +=    " AND DTR.DTR_CODRB3 = '" + cCodVei + "'"
	EndIf
	
	If cSerTms != '3' .OR. !lOrder
		cQueryTMP +=    " AND DTR.DTR_VIAGEM = '" + cViagem + "'"
	Else
		cQueryTMP +=    " AND DTR.DTR_VIAGEM <> '" + cViagem + "'"
	EndIf
	
	If lOrder
		cQueryTMP +=  " ORDER BY DTW.DTW_DATREA DESC, DTW.DTW_HORREA DESC, DTW.DTW_VIAGEM DESC, DTW.DTW_SEQUEN DESC"
	Else
		cQueryTMP +=  " ORDER BY DTW.DTW_DATREA DESC, DTW.DTW_HORREA DESC, DTW.DTW_VIAGEM DESC, DTW.DTW_SEQUEN ASC"
	Endif
	cQueryTMP := ChangeQuery(cQueryTMP)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryTMP),cAliasTMP,.T.,.T.)
	
	If (cAliasTMP)->(!Eof())
		If lOrder
			AAdd( aRetorno, (cAliasTMP)->DTW_DATREA ) 
			AAdd( aRetorno, (cAliasTMP)->DTW_HORREA )
		Else 
			AAdd( aRetorno, (cAliasTMP)->DTW_SEQUEN ) 
		EndIf
	EndIf
	(cAliasTMP)->(dbCloseArea())
	RestArea(aAreaDTW)
	
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLoteVge
Valida se existem lotes de nota fiscal com o campo DTP_VIAGEM preenchido e que não estão na viagem

@author Caio Murakami
@since 19/11/2018
@version 1.0	
/*/
//-------------------------------------------------------------------
Function VldLoteVge(cFilOri , cViagem, cAtiv, cCliRem, cLojRem )
Local lRet			:= .T. 
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()
Local cAuxDoc		:= ""
Local cAuxLote		:= ""
Local cMsgFim		:= ""
Local aAuxLote		:= {}
Local nX			:= 1 
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cCliLot		:= ""
Local lVgeAtvApo    := .F.

Default cFilOri		:= ""
Default cViagem		:= ""
Default cAtiv		:= ""
Default cCliRem		:= ""
Default	cLojRem		:= ""
Default cFilOri     := ""
Default cViagem     := ""

//Verifica se a Viagem está configurada com atividades de Ponto de Apoio
lVgeAtvApo := TM350AtvPA(cFilOri, cViagem )  

cQuery	:= " SELECT DT6_FILDOC  FILDOC , DT6_DOC  DOC , DT6_SERIE  SERIE , DT6_CLIREM CLIREM, DT6_LOJREM LOJREM, DTP_LOTNFC  LOTE , 'DT6'  TIPO "
cQuery	+= " FROM " + RetSQLName("DTP") + " DTP "
cQuery	+= " 	INNER  JOIN " + RetSQLName("DT6") + " DT6 "
cQuery	+= " 		ON DT6_FILIAL 	= '" + xFilial("DT6") 	+ "' "
cQuery	+= "		AND DT6_FILORI	= DTP_FILORI "
cQuery	+= "		AND DT6_LOTNFC	= DTP_LOTNFC "
cQuery	+= "		AND DT6.D_E_L_E_T_ = ' ' "
cQuery	+= "		AND DT6_DOC NOT IN ( "
cQuery	+= "		SELECT DUD_DOC FROM " + RetSQlName("DUD") + " DUD "
cQuery	+= "			WHERE DUD_FILIAL 	= '" + xFilial("DUD") 	+ "' "
cQuery	+= "			AND DUD_FILORI 		= DTP_FILORI "
cQuery	+= "			AND DUD_VIAGEM		= DTP_VIAGEM "
cQuery	+= "			AND DUD.D_E_L_E_T_ 	= ' ' "
cQuery	+= "		) "
cQuery	+= " WHERE DTP_FILIAL 		= '" + xFilial("DTP") 	+ "' "
cQuery	+= " 	AND DTP_FILORI		= '" + cFilOri			+ "' "
cQuery	+= " 	AND DTP_VIAGEM 		= '" + cViagem			+ "' "
cQuery  += "    AND DTP_TIPLOT      <> '5' "
cQuery	+= " 	AND DTP.D_E_L_E_T_ 	= ' ' "
cQuery	+= " UNION ALL "
cQuery	+= " SELECT ''  FILDOC , DTC_NUMNFC  DOC , DTC_SERNFC  SERIE , DTC_CLIREM CLIREM, DTC_LOJREM LOJREM, DTP_LOTNFC  LOTE, 'DTC'  TIPO  "
cQuery	+= " FROM " + RetSQLName("DTP") + " DTP "
cQuery	+= " 	INNER  JOIN " + RetSQLName("DTC") + " DTC "
cQuery	+= " 		ON DTC_FILIAL 	= '" + xFilial("DTC") 	+ "' "
cQuery	+= "		AND DTC_FILORI	= DTP_FILORI "
cQuery	+= "		AND DTC_LOTNFC	= DTP_LOTNFC "
cQuery	+= "		AND DTC_FILDOC 	= '' "
cQuery	+= "		AND DTC_DOC		= '' "
cQuery	+= "		AND DTC_SERIE	= '' "
cQuery	+= "		AND DTC.D_E_L_E_T_ = ' ' "
cQuery	+= " WHERE DTP_FILIAL 		= '" + xFilial("DTP") 	+ "' "
cQuery	+= " 	AND DTP_FILORI		= '" + cFilOri			+ "' "
cQuery	+= " 	AND DTP_VIAGEM 		= '" + cViagem			+ "' "
cQuery  += "    AND DTP_TIPLOT      <> '5' "
cQuery	+= "	AND DTP.D_E_L_E_T_  = ' ' "
cQuery	+= " UNION ALL "
cQuery	+= " SELECT '' FILDOC , ''  DOC , ''  SERIE , '' CLIREM, '' LOJREM, DTP_LOTNFC  LOTE, 'DTP'  TIPO  "
cQuery	+= " FROM " + RetSQLName("DTP") + " DTP "
cQuery	+= " WHERE DTP_FILIAL 		= '" + xFilial("DTP") 	+ "' "
cQuery	+= " 	AND DTP_FILORI		= '" + cFilOri			+ "' "
cQuery	+= " 	AND DTP_VIAGEM 		= '" + cViagem			+ "' "
cQuery	+= "	AND DTP_STATUS		= '1' " //-- Em Aberto
cQuery  += "    AND DTP_TIPLOT      <> '5' "
cQuery	+= "	AND DTP.D_E_L_E_T_  = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

cAuxDoc	:= CHR(13)+CHR(10) + CHR(13)+CHR(10) + RetTitle("DT6_FILDOC") + " / " + RetTitle("DT6_DOC") + " / " + RetTitle("DT6_SERIE")  + ": "

If !Empty(cCliRem) .And. cAtiv == cAtvChgCli 
	While (cAliasQry)->(!Eof()) 
		If cCliRem + cLojRem != (cAliasQry)->CLIREM + (cAliasQry)->LOJREM
			If aScan(aAuxLote , {|x| x == (cAliasQry)->LOTE  } ) == 0 
				Aadd(aAuxLote , (cAliasQry)->LOTE )
			EndIf

			If (cAliasQry)->TIPO == "DT6"
				cAuxDoc 	+= CHR(13)+CHR(10) + (cAliasQry)->FILDOC + " / " + (cAliasQry)->DOC + " / " + (cAliasQry)->SERIE
			EndIf 

			lRet		:= .F. 		
		EndIf
		(cAliasQry)->( dbSkip() ) 
	EndDo
ElseIf !Empty(cCliRem) .And. IsInCallStack("TMSA050VLD") 
	While (cAliasQry)->(!Eof()) 
		If cCliRem + cLojRem != (cAliasQry)->CLIREM + (cAliasQry)->LOJREM .And. (cAliasQry)->TIPO == "DTC"
			If aScan(aAuxLote , {|x| x == (cAliasQry)->LOTE  } ) == 0 
				Aadd(aAuxLote , (cAliasQry)->LOTE )
			EndIf

			cCliLot	+= CHR(13)+CHR(10) +  (cAliasQry)->CLIREM + " / " + (cAliasQry)->LOJREM  

			lRet := .F. 		
		EndIf
		(cAliasQry)->( dbSkip() ) 
	EndDo
Else
	While (cAliasQry)->(!Eof()) 
		
		If aScan(aAuxLote , {|x| x == (cAliasQry)->LOTE  } ) == 0 
			Aadd(aAuxLote , (cAliasQry)->LOTE )
		EndIf

		cAuxDoc 	+= CHR(13)+CHR(10) + (cAliasQry)->FILDOC + " / "  + (cAliasQry)->DOC + " / " + (cAliasQry)->SERIE

		lRet		:= .F. 		
		(cAliasQry)->( dbSkip() )
	EndDo
EndIf 

If Len(aAuxLote) > 0
	cAuxLote	:= CHR(13)+CHR(10) + CHR(13)+CHR(10) + RetTitle("DTP_LOTNFC") + ": "
EndIf

For nX := 1 To Len(aAuxLote)
	cAuxLote	+= CHR(13)+CHR(10)
	cAuxLote	+= aAuxLote[nX]
Next nX

If !lRet 
	If IsInCallStack("TMSA050VLD") 
		If !lVgeAtvApo
			cMsgFim := cCliLot + cAuxLote
			Help("",1,"TMSA050D9",, cMsgFim, 2, 0 ) //-- Nos lotes vinculados a uma viagem que está em trânsito, só é permitido um único cliente Remetente".
		Else
			lRet:= .T. //Viagem com Atividade de Apoio é permitido a digitacao de varios clientes Remetentes 
		EndIf
	Else
		cMsgFim	:= cAuxLote + cAuxDoc 
		Help("",1,"TMSA35038",, cMsgFim, 2, 0 ) /*-- Não é possivel prosseguir com apontamento; pois existem conhecimentos de transporte e/ou notas fiscais cujo lote está vinculado a viagem e/ou lotes vazios vinculados a viagem. É necessário que todos os documentos vinculados a essa viagem estejam carregados.     */ 
	EndIf
EndIf

(cAliasQry)->(dbCloseArea())


RestArea(aArea)
Return lRet

//==========================================================================================
/*/{Protheus.doc} TMSA350Ope
Retorna a ultima atividade de operação apontada.
@author 	arume.alexandre
@version    1.0
@since      22/11/18
@return     cRet: Codigo da atividade
@param  	cFilOri: Codigo da Filial de Origem
@param		cViagem: Codigo da Viagem
/*/
//==========================================================================================
Function TMSA350Ope(cFilOri, cViagem)

	Local cQuery 	:= ""
	Local cAlias	:= ""
	Local cRet		:= ""

	Default cFilOri := ""
	Default cViagem := ""

	cQuery := "SELECT DTW_ATIVID "
	cQuery += "FROM " + RetSqlName("DTW") + " DTW "
	cQuery += "WHERE DTW.DTW_FILIAL = '"+ FwxFilial("DTW") +"' "
	cQuery += "AND DTW.DTW_FILORI = '"+ cFilOri +"' "
	cQuery += "AND DTW.DTW_VIAGEM = '"+ cViagem +"' "
	cQuery += "AND DTW.DTW_STATUS = '2' "
	cQuery += "AND DTW.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DTW_SEQUEN DESC"
	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.T.,.T.)
	If (cAlias)->(!Eof())
		cRet := (cAlias)->DTW_ATIVID
	EndIf
	(cAlias)->(dbCloseArea())

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} A350RetDTW
Função para retornar apontamentos

@author Caio Murakami
@since 19/11/2018
@version 1.0	
*/
//-------------------------------------------------------------------
Function A350RetDTW( cFilOri, cViagem , cTipo , cStatus , aCpoRet, cAtivid )
Local aRet		:= {} 
Local cAliasQry	:= ""
Local cQuery	:= ""
Local nCount	:= 1
Local aArea		:= GetArea()
Local lViaEnc	:= .F.

Default cFilOri	:= ""
Default cViagem	:= ""
Default cTipo	:= "" //-- 1=Todos;2=Ultima sequencia;3=Ultima sequencia baseada nos campos de data/hora do sistema;4=Ultima sequencia apontada cronologicamente
Default cStatus	:= "" //-- 1=Em Aberto;2=Encerrado;3=Cancelado
Default aCpoRet	:= { "DTW_FILORI" , "DTW_VIAGEM" , "DTW_SEQUEN" , "DTW_DATINI" , "DTW_HORINI" , "DTW_DATREA",;
					"DTW_HORREA" , "DTW_ATIVID" , "DTW_FILATU" , "DTW_CODCLI" , "DTW_LOJCLI" }
Default cAtivid := ""					

If Len(aCpoRet) > 0 

	cAliasQry	:= GetNextAlias()
	cQuery		:= " SELECT "

	For nCount := 1 To Len(aCpoRet)
		cQuery	+= " " + aCpoRet[nCount] + " " 

		If nCount <> Len(aCpoRet)
			cQuery	+= ","
		EndIf

	Next nCount

	cQuery	+= " FROM " + RetSQLName("DTW") + " DTW "
	cQuery	+= " WHERE "
	cQuery	+= " DTW_FILIAL 	= '" + xFilial("DTW") + "' "
	cQuery	+= " AND DTW_FILORI = '" + cFilOri + "' "
	cQuery	+= " AND DTW_VIAGEM = '" + cViagem + "' "

	If !Empty(cStatus)
	DbSelectArea("DTQ")
		DTQ->( DbSetOrder(2) ) // DTQ_FILIAL, DTQ_FILORI, DTQ_VIAGEM, DTQ_ROTA
		If DTQ->( DbSeek( xFilial("DTQ") + cFilOri + cViagem ) )
			lViaEnc := DTQ->DTQ_STATUS == "3"
		EndIf

		If lViaEnc
			cQuery	+= " AND DTW_STATUS IN ('" + cStatus + "', '9')"
		Else
			cQuery	+= " AND DTW_STATUS = '" + cStatus + "' "
		EndIf
	Else
		cQuery	+= " AND DTW_STATUS <> '" + StrZero(9, Len(DTW->DTW_STATUS)) + "' "
	EndIf

	If !Empty(cAtivid)
		cQuery	+= " AND DTW_ATIVID = '" + cAtivid + "' "	
	EndIf

 	cQuery	+= " AND DTW.D_E_L_E_T_ = '' "

	If cTipo == "1" //-- Todos
		cQuery	+= " ORDER BY DTW_SEQUEN "
	ElseIf cTipo == "2" //-- Ultima sequencia
		cQuery	+= " ORDER BY DTW_DATREA DESC , DTW_HORREA DESC "
	ElseIf cTipo == "3" //-- Ultima sequencia baseada nos campos de data e hora gravadas do sistema.
		If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .AND. DTW->(ColumnPos("DTW_SYSHOR")) > 0
			cQuery += " ORDER BY DTW_SYSDAT DESC , DTW_SYSHOR DESC "
		Else
			cQuery += " ORDER BY DTW_DATREA DESC , DTW_HORREA, DTW_SEQUEN DESC "
		EndIf
	ElseIf cTipo == "4" //-- Ultima sequencia apontada cronologicamente.
		cQuery += " ORDER BY DTW_DATREA DESC , DTW_HORREA DESC "
		If DTW->(ColumnPos("DTW_SYSDAT")) > 0 .AND. DTW->(ColumnPos("DTW_SYSHOR")) > 0
			cQuery += ", DTW_SYSDAT DESC , DTW_SYSHOR DESC "
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	While (cAliasQry)->( !Eof() )
		Aadd( aRet , {} )

		For nCount := 1 To Len(aCpoRet)
			Aadd( aRet[Len(aRet)] , { aCpoRet[nCount] , (cAliasQry)->&(aCpoRet[nCount]) } )
		Next nCount

		If cTipo == "2" //-- Ultima sequencia
			Exit
		EndIf
		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

EndIf

RestArea(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A350DTWVal
Função para validar se é possivel apontar a operação de Chegada em Cliente.

@author arume.alexandre
@since 21/02/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function A350DTWVal(cFilOri, cViagem)

	Local lRet			:= .T.
	Local cQuery		:= ""
	Local cAliasQry		:= ""
	Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC', , '') // Atividade de Saída do cliente
	Local lIdDTW		:= DTW->(ColumnPos("DTW_IDDTW")) > 0

	If lIdDTW

		cQuery := "SELECT DTW.DTW_ATIVID "
		cQuery += "FROM " + RetSqlName("DTW") + " DTW "
		cQuery += "WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += "AND DTW.DTW_FILORI = '" + cFilOri + "' "
		cQuery += "AND DTW.DTW_VIAGEM = '" + cViagem + "' "
		cQuery += "AND DTW.DTW_STATUS = '1' "
		cQuery += "AND DTW.D_E_L_E_T_ = ' ' "
		cQuery += "AND EXISTS ("
		cQuery += "SELECT 1 FROM " + RetSqlName("DTW") + " DTW2 "
		cQuery += "WHERE DTW2.DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += "AND DTW2.DTW_FILORI = '" + cFilOri + "' "
		cQuery += "AND DTW2.DTW_VIAGEM = '" + cViagem + "' "
		cQuery += "AND DTW2.DTW_CODCLI = DTW.DTW_CODCLI "
		cQuery += "AND DTW2.DTW_LOJCLI = DTW.DTW_LOJCLI "
		cQuery += "AND DTW2.DTW_STATUS = '2' "
		cQuery += "AND DTW2.DTW_IDDTW = " 
        
        If "POSTGRES" $ Upper(TCGetDB())
            cQuery += "(SELECT DTW_IDDTW "
            cQuery += "FROM " + RetSqlName("DTW") + " "
            cQuery += "WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
            cQuery += "AND DTW_FILORI = '" + cFilOri + "' "
            cQuery += "AND DTW_VIAGEM = '" + cViagem + "' "
            cQuery += "AND DTW_IDDTW < DTW.DTW_IDDTW "
            cQuery += "ORDER BY DTW_IDDTW DESC limit 1) "
        Else
            cQuery += "(DTW.DTW_IDDTW-1) "
        EndIf
		cQuery += "AND D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		While (cAliasQry)->(!Eof())
			If (cAliasQry)->DTW_ATIVID == cAtvSaiCli
				lRet := .F.
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A350EstSaC
Função para realizar o estorno da operação de Saida de Cliente.

@author arume.alexandre
@since 06/03/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Function A350EstSaC(cFilOri, cViagem)

	Local lRet		:= .T.
    Local lIdDTW    := DTW->(ColumnPos("DTW_IDDTW")) > 0
	Local aDoc		:= {}
	Local nI		:= 0
	Local aAreaDUD	:= {}
	Local aAreaDT5	:= {}
	Local aAreaDT6	:= {}

    // Verifica se existe o campo IDDTW.
    If !lIdDTW
        Help("", 1, "TMSA35036") // Não é possível estornar a operação de Saída de Cliente.
		Return .F.
    EndIf

	// Verifica se a viagem esta totalmente em transito, ou seja, a ultima operação apontada é saída de cliente.
	If ExistFunc("TMSVgTotTr") .AND. TMSVgTotTr(cFilOri, cViagem)
		// Verifica se a operação é a última apontada cronologicamente.
		If ExistFunc("TMSOperUlt") .AND. TMSOperUlt(cFilOri, cViagem)
			If ExistFunc("TM351DocSq")
				// Retornar os documentos incluídos em uma determinada sequencia.
				aDoc := TM351DocSq(cFilOri, cViagem, DTW->DTW_IDDTW)

				If Len(aDoc) > 0
					aAreaDUD := DUD->(GetArea())
					aAreaDT5 := DT5->(GetArea())
					aAreaDT6 := DT6->(GetArea())
					DUD->(dbSetOrder(1)) // DUD_FILIAL+DUD_FILDOC+DUD_DOC+DUD_SERIE+DUD_FILORI+DUD_VIAGEM
					DT5->(dbSetOrder(4)) // DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
					DT6->(dbSetOrder(1)) // DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					For nI := 1 To Len(aDoc)
						If DUD->(MsSeek(xFilial("DUD")+aDoc[nI][1]+aDoc[nI][2]+aDoc[nI][3]+cFilOri+cViagem))
							If DT5->(MsSeek(xFilial('DT5')+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE))) // Atualiza status da Solicitacao de Coleta
								If DT5->DT5_STATUS <> StrZero(4,Len(DT5->DT5_STATUS)) .And. ; // Encerrada
									DT5->DT5_STATUS <> StrZero(5,Len(DT5->DT5_STATUS)) // Documento Informado
									RecLock("DT5", .F.)
									DT5->DT5_STATUS := StrZero(2,Len(DT5->DT5_STATUS)) // Indicada para Coleta
									MsUnLock()
								EndIf
								If DUD->DUD_STATUS <> StrZero(4,Len(DUD->DUD_STATUS)) // Encerrado
									RecLock("DUD", .F.)
									DUD->DUD_STATUS := StrZero(1,Len(DUD->DUD_STATUS)) // Em Aberto
									MsUnLock()
								EndIf
							ElseIf DUD->DUD_STATUS != StrZero(2,Len(DUD->DUD_STATUS)) .Or. ; // Em Transito
								(!Empty(DUD->DUD_FILFEC) .And. DUD->DUD_FILFEC <> cFilAnt)
								DUD->(DbSkip())
								Loop
							EndIf

							// Atualiza status de movimentos de viagens de transporte ou entrega
							If DTQ->DTQ_SERTMS <> StrZero(1,Len(DTQ->DTQ_SERTMS))
								RecLock("DUD", .F.)
								DUD->DUD_STATUS := StrZero(3,Len(DUD->DUD_STATUS)) // Carregado
								MsUnLock()
							EndIf

							If DT6->(MsSeek(xFilial('DT6')+DUD->( DUD_FILDOC + DUD_DOC + DUD_SERIE ) ) )
								RecLock("DT6", .F.)
								If DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) // Viagem Coleta
									DT6->DT6_STATUS := StrZero(1,Len(DTQ->DTQ_STATUS)) // Em Aberto
								ElseIf DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) // Viagem Transporte
									DT6->DT6_STATUS := StrZero(2,Len(DTQ->DTQ_STATUS)) // Carregado
								ElseIf DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) // Viagem Entrega
									DT6->DT6_STATUS := StrZero( 6, Len(DT6->DT6_STATUS) ) // Indicado para Entrega						
								EndIf
								DT6->DT6_ULTEMB := CriaVar("DT6_ULTEMB",.F.)
								MsUnLock()
							EndIf
						EndIf
					Next
					RestArea(aAreaDT6)
					RestArea(aAreaDT5)
					RestArea(aAreaDUD)
				EndIf

				RecLock('DTW',.F.)
				DTW->DTW_DATREA := CriaVar('DTW_DATREA', .F.)
				DTW->DTW_HORREA := CriaVar('DTW_HORREA', .F.)
				DTW->DTW_STATUS := StrZero(1,Len(DTW->DTW_STATUS))	//-- Aberto
				MsUnLock()
			EndIf
		Else
			Help("", 1, "TMSA35042") //Só é possível estornar uma operação de saída de cliente se não houverem outras operações apontadas posteriormente a esta.
			lRet := .F.
		EndIf
	Else
		Help("", 1, "TMSA35042") // Só é possível estornar uma operação de saída de cliente se não houverem outras operações apontadas posteriormente a esta.
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA350Ret
Função para verificar se a viagem é de retirada.

@author arume.alexandre
@since 09/08/2019
@version 1.0	
/*/
//-------------------------------------------------------------------
Static Function TMSA350Ret(cFilOri, cViagem)

    Local lRet          := .F.
    Local cQuery        := ""
    Local cAlias        := ""
    Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'') // Atividade de Chegada em Cliente
    Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'') // Atividade de Saída do Cliente
    Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'') // Atividade de Chegada no Ponto de Apoio
    Local cAtvSaiApo    := SuperGetMv('MV_ATVSAPA',,'') // Atividade de Saida do Ponto de Apoio

    cQuery := "SELECT DTW_ATIVID "
    cQuery += "FROM " + RetSqlName("DTW") + " "
    cQuery += "WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
    cQuery += "AND DTW_FILORI = '" + cFilOri + "' "
    cQuery += "AND DTW_VIAGEM = '" + cViagem + "' "
    cQuery += "AND DTW_ATIVID IN ('" + cAtvChgCli + "', '" + cAtvSaiCli + "', '" + cAtvChgApo + "', '" + cAtvSaiApo + "') "
    cQuery += "AND D_E_L_E_T_= ' ' "
    cQuery := ChangeQuery(cQuery)
    cAlias := GetNextAlias()
    DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAlias, .F., .T.)
    If (cAlias)->(!Eof()) 
        lRet := .T.
    EndIf  
    (cAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tm350Apoio
Função que valida o Apontamento de Chegada de Apoio
@author	Katia
@version	1.0
@since		29/08/2019
/*/
//-------------------------------------------------------------------
Function Tm350Apoio(cFilOri,cViagem)
Local lRet       := .T.
Local cAtvSaiApo := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local nPosAtv    := 0
Local aRet       := {}

Default cFilOri  := ""
Default cViagem  := ""

If !Empty(cAtvSaiApo) .And. !Empty(cAtvChgApo)
	lRet:= TM350AtvPA(cFilOri, cViagem, cAtvSaiApo, cAtvChgApo)
	If lRet
		aRet := A350RetDTW(cFilOri, cViagem, "4", "2")
		//--- Retorno em ordem decrescente, portanto o primeiro registro é o ultimo apontamento

		If  Len(aRet) > 0
			nPosAtv:= aScan(aRet[1], { |x| x[1] == "DTW_ATIVID" })
			If nPosAtv > 0
				If !aRet[1, nPosAtv][2] == cAtvChgApo 
 					//Esta viagem foi configurada com Ponto de Apoio, portanto para que seja possível incluir novos documentos 
					//é obrigatório o apontamento da Chegada no Ponto de Apoio
				    Help("",1,"TMSA35043") 
					lRet := .F.
				EndIf
			EndIf
		EndIf
		aRet := {}
		aSize(aRet, 0)	
	Else	
		lRet:= .T.  //Viagem não tem atividade de chegada/saida de apoio		
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TM350AtvPA
Função que verifica se a viagem tem atividade de Ponto de Apoio
@author	Katia
@version	1.0
@since		01/09/2019
/*/
//-------------------------------------------------------------------
Function TM350AtvPA(cFilOri, cViagem, cAtvSaiApo, cAtvChgApo)
Local lRet       := .F.
Local aRet       := {}
Local aArea      := {}

Default cFilOri    := ""
Default cViagem    := ""
Default cAtvSaiApo := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Default cAtvChgApo := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

If !Empty(cAtvSaiApo) .And. !Empty(cAtvChgApo)
	aArea := GetArea()
	aRet  := A350RetDTW(cFilOri, cViagem, "1", "", , cAtvSaiApo)  //Verifica se existe a operação de saida de apoio
	If Len(aRet) > 0
		lRet:= .T.
		aSize(aRet, 0)	
		aRet := Nil
	EndIf
	RestArea(aArea)
EndIf

Return lRet

/*/{Protheus.doc} RetMDFEVet()
	Gera vetor que será utilizado para transmissão do envio ou encerramento do MDF-e
	@type  Static Function
	@author Tiago dos Santos
	@since 05/02/2020
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RetMDFEVet(cFilOri,cViagem,cFilUF,cCodAtiv,cSerTMS,lDTW)
Local aResult		:= {}
Local lMTRANS		:= .F.
Local cAtivChg		:= SuperGetMV('MV_ATIVCHG',,'') //-- Atividade de Chegada de Viagem
Local cAtivSai		:= SuperGetMV('MV_ATIVSAI',,'')
Local lUFAtiv   	:= DTW->(ColumnPos("DTW_UFATIV")) > 0

Default cFilUF	:= " "

			DTX->(DbSetOrder(5)) //--DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI                                                                                                                     
			DTX->(MsSeek(xFilial("DTX") +  cFilOri + cViagem))
			Do While DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ cFilOri+ cViagem
				If DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STFMDF <> '2' //--Eletronico e não Encerrado
					If lDTW .And. !Empty(cFilUF) .And.;
						( ;
						(cSERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)).And. DTX->DTX_FILDCA == cFilAnt  ); //--Transferencia
						.Or.;
						(cSERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And.  DTX->DTX_UFATIV == cFilUF ); //--Viagem de entrega
						)
						lMTRANS := .T.
					ElseIf (cCodAtiv == cAtivChg .Or. cCodAtiv == cAtivSai) .And. ((cSERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTX->DTX_FILDCA == cFilAnt  ); //--Transferencia e Descarga na filial 
							.Or. cSERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS))) //--Viagem de entrega Chegada em filial 
						lMTRANS := .T.
					EndIf
					
					If lMTRANS	
						Aadd(aResult ,Array(6))
						aResult[Len(aResult),1] := DTX->DTX_FILMAN //-- Filial Manif
						aResult[Len(aResult),2] := DTX->DTX_MANIFE //-- Manif. Inicial
						aResult[Len(aResult),3] := DTX->DTX_MANIFE //-- Manif. final
						aResult[Len(aResult),4] := DTX->DTX_SERMAN //-- Serie Manif.
						aResult[Len(aResult),5] := DTX->DTX_VIAGEM //-- VIAGEM
						If lUfAtiv 							
							aResult[Len(aResult),6] := DTX->DTX_UFATIV  //-- UF Atividade
						Else
							aResult[Len(aResult),6] := ''	
						EndIf								
					EndIf
				EndIf
				lMTRANS := .F.
				DTX->(DbSkip())
			EndDo

Return aResult

/*/-----------------------------------------------------------
{Protheus.doc} EstDocChk()
Estorna documentos do check-list
Uso: TMSA350
@author Caio Murakami
@since 04/05/2020
-----------------------------------------------------------
/*/
Static Function EstDocChk( cFilOri, cViagem, lSaiApoio )
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAliasQry		:= ""

Default cFilOri		:= ""
Default cViagem		:= "" 
DEFAULT lSaiApoio   := .F.

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT DM0_IDINTG "
cQuery	+= " FROM " + RetSqlName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSqlName("DM0") + " DM0 "
cQuery	+= " 	ON DM0_FILIAL 		= '" + xFilial("DM0") + "' "
cQuery	+= " 	AND DM0_FILDOC		= DUD_FILDOC  "
cQuery	+= " 	AND DM0_DOC			= DUD_DOC "
cQuery	+= " 	AND DM0_SERIE		= DUD_SERIE "
If lSaiApoio
	cQuery	+= " 	AND DM0_STATUS		= '" + StrZero(3,Len(DM0->DM0_STATUS)) + "' "
EndIf
cQuery	+= " 	AND DM0.D_E_L_E_T_ 	= '' "
cQuery	+= " WHERE DUD_FILIAL		= '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI		= '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM		= '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ 	= '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	//-- Envia o estorno do Check List
	TMSCanChk( (cAliasQry)->DM0_IDINTG , cFilOri , cViagem  )
			
	(cAliasQry)->( dbSkip() )
EndDo
	
(cAliasQry)->( dbCloseArea() )


RestArea( aArea )
Return
/*/-----------------------------------------------------------
{Protheus.doc} A350RepDoc()
Adiciona Documentos na REPOM
Uso: TMSA350
@author Caio Murakami
@since 11/11/2020
-----------------------------------------------------------
/*/
Static Function A350RepDoc( cFilOri , cViagem , cAtiv, cCodCli , cLojCli  )
Local lRet			:= .T. 
Local cQuery		:= ""
Local cAliasQry		:= GetNextAlias()
Local cEncRepom		:= SuperGetMV('MV_ENREPOM',,"1")   //-- Encerra Repom pela Ocorrencia = 2 / Rotina de Encerramento = 1
Local aRet			:= {} 
Local nPosIdDtw		:= 0 
Local nCount		:= 1 
Local nPCodCli		:= 0 
Local nPLojCli		:= 0 
Local cIdDTW		:= ""
Local aCabec		:= { "DTW_FILORI" , "DTW_VIAGEM" , "DTW_SEQUEN" , "DTW_DATINI" , "DTW_HORINI" , "DTW_DATREA",;
						"DTW_HORREA" , "DTW_ATIVID" , "DTW_FILATU" , "DTW_CODCLI" , "DTW_LOJCLI" , "DTW_IDDTW"}

Default cFilOri		:= ""
Default cViagem		:= ""
Default cAtiv		:= ""
Default cCodCli		:= ""
Default cLojCli		:= ""

If cEncRepom $ '3/4'

	aRet := A350RetDTW(cFilOri, cViagem, "4", "2", aCabec , SuperGetMv('MV_ATVCHGC',,'') )

	If Len(aRet) > 0
		
		For nCount := 1 To Len(aRet)
			nPCodCli := aScan(aRet[1], { |x| x[1] == "DTW_CODCLI" })
			nPLojCli := aScan(aRet[1], { |x| x[1] == "DTW_LOJCLI" })
			nPosIdDTW := aScan(aRet[1], { |x| x[1] == "DTW_IDDTW" })

			If aRet[nCount][nPCodCli][2] + aRet[nCount][nPLojCli][2] == cCodCli + cLojCli 
				cIdDTW	:= aRet[nCount][nPosIdDTW][2]
				lRet	:= .T. 
				Exit
			Else 
				lRet	:= .F. 
			EndIf
		Next nCount 
		
		If lRet
			cQuery	:= " SELECT * FROM " + RetSQLName("DLT") + " DLT "
			cQuery	+= " 	WHERE DLT_FILIAL 	= '" + xFilial("DLT") + "' "
			cQuery	+= "	AND DLT_FILORI 		= '" + cFilOri  + "' "
			cQuery	+= "	AND DLT_VIAGEM		= '" + cVIagem  + "' "
			cQuery	+= "	AND DLT_IDDTW		= '" + cIdDTW	+ "' "
			cQuery	+= " 	AND DLT_ORIGEM		= '2' "
			cQuery	+= "	AND DLT.D_E_L_E_T_ = '' "

			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

			While (cAliasQry)->(!Eof() ) .And. lRet 
				lRet	:= TmsRepDoc( cFilOri , cViagem , (cAliasQry)->DLT_FILDOC , (cAliasQry)->DLT_DOC , (cAliasQry)->DLT_SERIE ) 
				(cAliasQry)->(dbSkip())
			EndDo 
		EndIf 

	EndIf 
EndIf 

Return lRet 

/*{Protheus.doc} ApontaKm
Verifica se será apontada a quilometragem de saída e chegada do veículo
@type Static Function
@author Valdemar Roberto Mognon
@since 19/02/2021
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function ApontaKm(cFilOri,cViagem,lSaida)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDTW := ""
Local aAreas    := {GetArea()}
Local nQtdReg   := 0
Local nQtdAbe   := 0
Local nQtdEnc   := 0
Local cAtivChg  := SuperGetMV('MV_ATIVCHG',,'') // Atividade de Chegada de Viagem
Local cAtivSai  := SuperGetMV('MV_ATIVSAI',,'')
Local cAtvChgCli:= SuperGetMv('MV_ATVCHGC',,'') // Atividade de Chegada em Cliente
Local cAtvSaiCli:= SuperGetMv('MV_ATVSAIC',,'') // Atividade de Saída do Cliente
Local cAtivRta  := SuperGetMv('MV_ATIVRTA',,'') // Atividade de retorno do aeroporto
Local cAtivRtp  := SuperGetMv('MV_ATIVRTP',,'') // Atividade de Retorno do Porto
Local cAtvSaiApo:= SuperGetMv('MV_ATVSAPA',,'') // Atividade de Saida do Ponto de Apoio
Local cAtvChgApo:= SuperGetMv('MV_ATVCHPA',,'') // Atividade de Chegada no Ponto de Apoio
Default cFilOri := ""
Default cViagem := ""

If !Empty(cFilOri) .And. !Empty(cViagem)
	cAliasDTW := GetNextAlias()
	cQuery := "SELECT COUNT(DTW_FILORI) QTDREG "
	cQuery += "  FROM " + RetSqlName("DTW") + " DTW "
	cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW")  + "' "
	cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "
 
	cQuery += "   AND (DTW_ATIVID = '" +  cAtivChg + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtivSai + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtvChgCli + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiCli + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtivRta + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtivRtp + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiApo + "' "
	cQuery += "   Or DTW_ATIVID = '" +  cAtvChgApo + "') "

	cQuery += "   AND DTW_STATUS <> '9' "
	cQuery += "   AND DTW.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDTW,.F.,.T.)
	If (cAliasDTW)->(!Eof())
		nQtdReg := (cAliasDTW)->QTDREG
	EndIf
	(cAliasDTW)->(DbCloseArea())

	If nQtdReg > 0
		cAliasDTW := GetNextAlias()
		cQuery := "SELECT COUNT(DTW_FILORI) QTDABE, 0 QTDENC "
		cQuery += "  FROM " + RetSqlName("DTW") + " DTW "
		cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW")  + "' "
		cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "

		cQuery += "   AND (DTW_ATIVID = '" +  cAtivChg + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivSai + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvChgCli + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiCli + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivRta + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivRtp + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiApo + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvChgApo + "') "

		cQuery += "   AND DTW_STATUS = '1' "
		cQuery += "   AND DTW.D_E_L_E_T_ = ' '"
		cQuery += "UNION ALL "
		cQuery += "SELECT 0 QTDABE, COUNT(DTW_FILORI) QTDENC "
		cQuery += "  FROM " + RetSqlName("DTW") + " DTW "
		cQuery += " WHERE DTW_FILIAL = '" + xFilial("DTW")  + "' "
		cQuery += "   AND DTW_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DTW_VIAGEM = '" + cViagem + "' "

		cQuery += "   AND (DTW_ATIVID = '" +  cAtivChg + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivSai + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvChgCli + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiCli + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivRta + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtivRtp + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvSaiApo + "' "
		cQuery += "   Or DTW_ATIVID = '" +  cAtvChgApo + "') "

		cQuery += "   AND DTW_STATUS = '2' "
		cQuery += "   AND DTW.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDTW,.F.,.T.)
		While (cAliasDTW)->(!Eof())
			nQtdAbe += (cAliasDTW)->QTDABE
			nQtdEnc += (cAliasDTW)->QTDENC
			(cAliasDTW)->(DbSkip())
		EndDo
		(cAliasDTW)->(DbCloseArea())
	
		If nQtdAbe == nQtdReg .And. nQtdEnc == 0
			lSaida := .T.
		ElseIf nQtdReg == nQtdEnc + 1
			lSaida := .F.
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet


Static Function MenuDef()
Private aRotina := MenuD350()
Return (aRotina)


/*{Protheus.doc} TMSFimRot
Atualiza processos no final da Rotina de Operações
@type Static Function
@author Katia
@since 26/04/2021
@version 12.1.33
*/
Static Function TMSFimRot()

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf
//-- Atualiza Browse Vge Mod3
If IsInCallStack("TMSAF60") .And. FindFunction("TF60AtuBrw")
	TF60AtuBrw(0)
EndIf

Return


/*/{Protheus.doc} validAtivid
	(long_description

	@type  Static Function
	@author fabio marchiori sampaio
	@since 31/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function validAtivid(cAtivid)

Local cAtivChg  := SuperGetMV('MV_ATIVCHG',,'') // Atividade de Chegada de Viagem
Local cAtivSai  := SuperGetMV('MV_ATIVSAI',,'')
Local cAtvChgCli:= SuperGetMv('MV_ATVCHGC',,'') // Atividade de Chegada em Cliente
Local cAtvSaiCli:= SuperGetMv('MV_ATVSAIC',,'') // Atividade de Saída do Cliente
Local cAtivRta  := SuperGetMv('MV_ATIVRTA',,'') // Atividade de retorno do aeroporto
Local cAtivRtp  := SuperGetMv('MV_ATIVRTP',,'') // Atividade de Retorno do Porto
Local cAtvSaiApo:= SuperGetMv('MV_ATVSAPA',,'') // Atividade de Saida do Ponto de Apoio
Local cAtvChgApo:= SuperGetMv('MV_ATVCHPA',,'') // Atividade de Chegada no Ponto de Apoio
Local lRet      := .F.

Default cAtivid := ''

If (cAtivid == cAtivChg .Or. cAtivid == cAtivSai .Or. cAtivid == cAtvChgCli .Or.;
   cAtivid == cAtvSaiCli .Or. cAtivid == cAtivRta  .Or. cAtivid == cAtivRtp .Or. ;
   cAtivid == cAtvSaiApo .Or. cAtivid == cAtvChgApo)
	lRet  := .T.
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} A350VgPGBe()
Libera / Bloqueia Viagem na PAGBEM.
METHOD PutLibViagem -> Libera Viagem 
METHOD PutUnlockVge -> Desbloqueia uma viagem bloqueada anteriormente 
METHOD PutBlqViagem -> Bloqueia uma Viagem 
@author Rafael 
@since 17/02/2022
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function A350VgPGBe(cFilOri,cViagem)

Local aArea 		:= GetArea()
Local aAreaDTR      := DTR->(GetArea())
Local lRet			:= .F. 
Local aRet			:= {}
Local oPagBem		:= Nil
Local cIdViagem		:= ""
Local cSitFrete		:= ""

Default cFilOri := ""
Default cViagem	:= ""

oPagBem := TMSBCAPagBem():New()
oPagBem:Auth()

aPagBem	:= oPagBem:IsTokenActive()

DTR->( DbSetOrder(1) ) //-- DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
If DTR->( MsSeek( xFilial("DTR") + cFilOri + cViagem ) )
	cIdViagem := AllTrim(DTR->DTR_PRCTRA)
	
	If aPagBem[1] .AND. !Empty( cIdViagem )

		oPagBem:GetTravel(cIdViagem)
		cSitFrete:= oPagBem:SitFrete

		If cSitFrete == "Frete_AguardandoLiberacao"
			aRet := oPagBem:PutLibViagem(cIdViagem) //-> Libera a Viagem na PAGBEM 
		ElseIf cSitFrete == "Frete_Bloqueado" 
			aRet := oPagBem:PutUnlockVge(cIdViagem) //-> Desbloqueia uma Viagem bloqueada anteriormente na PAGBEM. 
		ElseIf cSitFrete == "Frete_EmViagem" 
			aRet := oPagBem:PutBlqViagem(cIdViagem) //-> Bloqueia Viagem na PAGBEM no estorno do apontamento de saída
		EndIf 
		If Len(aRet) > 0		
			If aRet[1] == .F. 
				cMsg := DecodeUTF8(aRet[3])
				Help( "", 1, "Integração TMS x PAGBEM", ,cMsg, 1, 0 ) //"Integração TMS x PAGBEM"
				lRet := .F.
			Else
				lRet := .T. 
			EndIf
		EndIf 

	EndIf
EndIf  

oPagBem:Destroy()
FwFreeArray(aRet)

RestArea( aAreaDTR )
RestArea(aArea)

Return lRet 

 /*{Protheus.doc} VldColEnt
Valida envio e estorno da integração com coleta/entrega
@author Carlos Alberto Gomes Junior
@since 13/07/2022
*/
Static Function VldColEnt( nOpcx, cAtividade, cFilOri, cViagem, nRecDN5 )
Local lOk        := .T.
Local aAreas     := { DTQ->(GetArea()), GetArea() }
Local aStatusVia := {}
Local aViagens   := {}
Local cAtivSai   := SuperGetMV("MV_ATIVSAI",,"")	//-- Atividade de Saida de Viagem
Local oColEnt AS Object
Local aStruct    := {}
Local nCntFor2   := 0
Local nRegistro  := 0

	DEFAULT nOpcx      := 0
	DEFAULT cAtividade := ""
	DEFAULT nRecDN5    := 0

	If nOpcx == 5 .And. cAtividade == cAtivSai //-- Estorno de Saída de Viagem
		oColEnt := TMSBCACOLENT():New("DN1")
		If oColEnt:DbGetToken()
			DN1->(DbGoTo(oColEnt:config_recno))
			If DN1->DN1_ENVREG == "2" //-- Saída do veículo
				DN5->(DbSetOrder(3))
				DTQ->(DbSetOrder(2))

				aViagens := VgaPrincial( cFilOri, cViagem )
				DTQ->(DbSeek(xFilial("DTQ") + aViagens[1,1] + aViagens[1,2]))

				//-- Inicializa a estrutura
				aStruct   := TMSMntStru(DN1->DN1_CODFON,.T.)

				//-- Localiza primeiro registro da estrutura
				For nCntFor2 := 1 To Len(aStruct)
					//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
					If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor2,1] + aStruct[nCntFor2,2]}) == 0) .And. ;
														aStruct[nCntFor2,10] == "2" .And. Empty(aStruct[nCntFor2,6])
						Exit
					EndIf
				Next nCntFor2

				If ExisteDN5(aStruct[nCntFor2,1],aStruct[nCntFor2,2],PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)),{"1","2","3","6"},@nRegistro)
					DN5->(DbGoTo(nRegistro))
					If DN5->DN5_STATUS == "1"
						If (aStatusVia := TMSAC30GDV(DN5->DN5_IDEXT,,.F.))[1]
							If aStatusVia[2] != "AGUARDANDO_DESPACHO"
								Help(" ", , STR0075, , STR0076 + aStatusVia[2], 2, 1)
								lOk := .F.
							EndIf
						EndIf
					EndIf
					nRecDN5 := DN5->(RecNo())
				EndIf

			EndIf
		EndIf
	EndIf
	
	FwFreeObj(oColEnt)
	AEval( aAreas, {|aArea| RestArea(aArea), FwFreeArray(aArea) })
	FwFreeArray(aAreas)
	FwFreeArray(aStatusVia)
	FwFreeArray(aViagens)

Return lOk

/*{Protheus.doc} TM310PrcOp
Processa envio e estorno da integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 11/05/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TM310PrcOp(nOpcx,cAtividade)
Local lOk        := .T.
Local lCont      := .F.
Local aAreaCol   := {}
Local aStatusVia := {}
Local aLayout    := {}
Local aStruct    := {}
Local aAreaDN5   := {}
Local cSequen    := ""
Local cAliasDN5  := ""
Local cQuery     := ""
Local cAtivSai   := SuperGetMV("MV_ATIVSAI",,"")	//-- Atividade de Saida de Viagem
Local cAtvSaiCli := SuperGetMv("MV_ATVSAIC",,"")	//-- Atividade de Saída do cliente
Local cAtvSaiApo := SuperGetMv("MV_ATVSAPA",,"")	//-- Atividade de Saida do Ponto de Apoio
Local nCntFor2   := 0
Local oColEnt
Local aViagens   := {}
Local aAreaDTQ   := {}
Local aColigada  := {}
Local nCntFor1   := 0
Local nColFec    := 0
Local nColTra    := 0
Local nRegistro  := 0
Local lPrimeiro  := .T.
Local cSeekDN5   := ""

Default nOpcx      := 0
Default cAtividade := ""

//-- Mapa do vetor aStruct
//-- 01 - Código da fonte
//-- 02 - Código do registro
//-- 03 - Alias do registro
//-- 04 - Indice do registro
//-- 05 - Prioridade de envio
//-- 06 - Registro do qual o alias do registro é dependente
//-- 07 - Comando de posicionamento no alias de dependência
//-- 08 - Condição de repetição (loop) dos registros
//-- 09 - Condição de uso do registro do alias de dependência
//-- 10 - Indica se o registro já foi processado
//-- 11 - Fonte do registro adicional
//-- 12 - Registro adicional

If nOpcx == 5	//-- Estorno
	aAreaCol := {DUP->(GetArea()),DN5->(GetArea()),DN4->(GetArea()),DN1->(GetArea()),GetArea()}
	If cAtividade == cAtivSai .Or. cAtividade == cAtvSaiApo .Or. cAtividade == cAtvSaiCli
		oColEnt := TMSBCACOLENT():New("DN1")
		If oColEnt:DbGetToken()
			DN1->(DbGoTo(oColEnt:config_recno))
			If DN1->DN1_ENVREG == "2"	//-- Saída do veículo
				//-- Define Viagens
				aAreaDTQ  := DTQ->(GetArea())
				aViagens  := VgaPrincial(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
				aColigada := VgaColigada(aViagens[1,1],aViagens[1,2],.F.)
				RestArea(aAreaDTQ)

				//-- Verifica se nenhuma das viagens coligadas está com status diferente de fechada
				nColTra := 0
				For nCntFor1 := 1 To Len(aColigada)
					If aColigada[nCntFor1,1] + aColigada[nCntFor1,2] != DTQ->(DTQ_FILORI + DTQ_VIAGEM) .And. aColigada[nCntFor1,5] != StrZero(5,Len(DTQ->DTQ_STATUS))
						nColTra ++
					EndIf
				Next nCntFor1

				If nColTra == 0
					//-- Inicializa a estrutura
					aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
		
					//-- Localiza primeiro registro da estrutura
					For nCntFor2 := 1 To Len(aStruct)
						//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
						If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor2,1] + aStruct[nCntFor2,2]}) == 0) .And. ;
															aStruct[nCntFor2,10] == "2" .And. Empty(aStruct[nCntFor2,6])
							Exit
						EndIf
					Next nCntFor2

					If ExisteDN5(aStruct[nCntFor2,1],aStruct[nCntFor2,2],PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)),{"1","2","3","7"},@nRegistro)
						DN5->(DbGoTo(nRegistro))
						lCont := .T.
						If DN5->DN5_STATUS == "1" .And. !Empty(DN5->DN5_IDEXT)
							If (aStatusVia := TMSAC30GDV(DN5->DN5_IDEXT,,.F.))[1]
								If aStatusVia[2] != "AGUARDANDO_DESPACHO"
									Help(" ", , STR0075, , STR0076 + aStatusVia[2], 2, 1)
									lOk := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		 
		If lOk .And. lCont
			If Empty(DN5->DN5_IDEXT) .Or. TMSAC30ExA(AllTrim(DN5->DN5_IDEXT))
				cAliasDN5 := GetNextAlias()
				cQuery := "SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
				cQuery += "  FROM " + RetSqlName("DN5") + " DN5 "
				cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
				cQuery += "   AND DN5.DN5_CODFON = '" + aStruct[nCntFor2,1] + "' "
				cQuery += "   AND DN5.DN5_PROCES = '" + PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)) + "' "
				cQuery += "   AND DN5.DN5_STATUS NOT IN ('5','6') "
				cQuery += "   AND DN5.D_E_L_E_T_ = ' ' "
		
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)
		
				DN4->(DbSetOrder(1))
		
				While (cAliasDN5)->(!Eof())
					//-- Estorna registro na DN5
					DN5->(DbGoTo((cAliasDN5)->REGISTRO))
					RecLock("DN5",.F.)
					DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
					DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
					DN5->(MsUnLock())

					//-- Estorna registro na DN4
					DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
					RecLock("DN4",.F.)
	                DN4->DN4_IDEXT  := ""
	                DN4->DN4_STATUS := '2'
					DN4->(MsUnLock())

					If lPrimeiro
						DNC->(DbSetOrder(1))
						If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
							Reclock("DNC",.F.)
							DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
							DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
							DNC->DNC_DATULT := dDataBase
							DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
							DNC->(MsUnlock())
						EndIf
						lPrimeiro := .F.
					EndIf
		
					(cAliasDN5)->(DbSkip())
				EndDo

				(cAliasDN5)->(DbCloseArea())
			Else

				DisarmTransaction()
			EndIf
		EndIf
	EndIf
	AEval(aAreaCol,{|x,y| RestArea(x),FwFreeArray(x)})
	
ElseIf nOpcx == 3 .Or. nOpcx == 4	//-- Inclusão e Alteração
	If cAtividade == cAtivSai .Or. cAtividade == cAtvSaiApo .Or. cAtividade == cAtvSaiCli
		oColEnt  := TMSBCACOLENT():New("DN1")
		If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
			DN1->(DbGoTo(oColEnt:config_recno))
			If DN1->DN1_ENVREG == "2"	//-- Saída do veículo
				//-- Define Viagens
				aAreaDTQ  := DTQ->(GetArea())
				aViagens  := VgaPrincial(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
				aColigada := VgaColigada(aViagens[1,1],aViagens[1,2],.F.)
	
				//-- Verifica se todas as viagens coligadas estão fechadas
				nColFec := 0
				For nCntFor1 := 1 To Len(aColigada)
					If aColigada[nCntFor1,1] + aColigada[nCntFor1,2] != DTQ->(DTQ_FILORI + DTQ_VIAGEM) .And. aColigada[nCntFor1,5] != StrZero(2,Len(DTQ->DTQ_STATUS))
						nColFec ++
					EndIf
				Next nCntFor1
		
				If nColFec == 0
					DTQ->(DbSetOrder(2))
					For nCntFor1 := 1 To Len(aColigada)
						//Posiciona na viagem Coligada
						DTQ->(MsSeek(xFilial("DTQ")+aColigada[nCntFor1,1] + aColigada[nCntFor1,2]))

						//-- Inicializa a estrutura
						aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
						TMSSetVar("aStruct",aStruct)
		
						//-- Define o processo
						TMSSetVar("cProcesso",aViagens[1,1] + aViagens[1,2])

						//-- Inicializa o localizador
						TMSSetVar("aLocaliza",{})
		
						DUP->(DbSetOrder(1))
						If DUP->(DbSeek(xFilial("DUP") + aViagens[1,1] + aViagens[1,2] )) .And. !Empty(BscIDMot(DUP->DUP_CODMOT,DN1->DN1_CODFON,))
							aAreaCol := {}
							Aadd(aAreaCol,GetArea())
							Aadd(aAreaCol,DN1->(GetArea()))
							For nCntFor2 := 1 To Len(aStruct)
								Aadd(aAreaCol,(aStruct[nCntFor2,3])->(GetArea()))
								If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor2,1] +  aStruct[nCntFor2,2]}) == 0) .And. aStruct[nCntFor2,10] == "2"	//-- Não é adicional de ninguém e ainda não foi processado
									aLayout := BscLayout(aStruct[nCntFor2,1],aStruct[nCntFor2,2])
									If !Empty(aLayout)
										If Empty(aStruct[nCntFor2,6])
											//-- Localiza a sequencia no caso de viagem coligada
											If Len(aColigada) > 1
												aAreaDN5 := DN5->(GetArea())
												DN5->(DbSetOrder(3))
												DN5->(DbSeek(cSeekDN5 := xFilial("DN5") + aStruct[nCntFor2,1] + aStruct[nCntFor2,2] + aViagens[1,1] + aViagens[1,2]))
												Do While !DN5->(Eof()) .And. cSeekDN5 == DN5->(DN5_FILIAL+DN5_CODFON+DN5_CODREG+RTrim(DN5_PROCES))
													cSequen := DN5->DN5_SEQUEN
													DN5->(DbSkip())
												EndDo
												RestArea(aAreaDN5)
											EndIf
											//-- Inicia a gravação dos registros
											MontaReg(Aclone(aLayout),nCntFor2,aColigada[nCntFor1,1] + aColigada[nCntFor1,2] == aViagens[1,1] + aViagens[1,2],cSequen,.T.)
											TMSCtrLoop(Aclone(aLayout),nCntFor2)
										EndIf
									EndIf
								EndIf
								aStruct := TMSGetVar("aStruct")
							Next nCntFor2
							AEval(aAreaCol,{|x,y| RestArea(x),FwFreeArray(x)})
						EndIf
					Next nCntFor1
				EndIf

				RestArea(aAreaDTQ)
				FwFreeArray(aAreaDTQ)
			EndIf
		EndIf
	EndIf
EndIf

Return lOk
