#Include "PROTHEUS.ch"
#Include "APDM040.CH"

/*/{Protheus.doc} APDM040
@type function
@author Eduardo Ferreira
@since 06/04/2016
@version 1.0
@description Rotina de processamento dos cálculos de Resultados de Metas
/*/
Function APDM040()

	Local aSays			:= {}
	Local aButtons		:= {}
	Local cPerg			:= "APDM040"
	Local nOpca
	Local oDlg
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	Local aArea			:= GetArea()

	Private cCadastro 	:= OemToAnsi(STR0034)	//"Cálculo de Metas"
	Private nSavRec		:= 0

	Pergunte("APDM040",.F.)

	/*
	Monta dimensões dos objetos
	*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 35	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 55	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*25), (((aObjSize[1,4])/100)*29.6) }	//1,3 Vertical /1,4 Horizontal

	SetaPilha()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],20 TO aAdvSize[6]-50,600  OF oMainWnd PIXEL

	@ aGdCoord[1]+20,aGdCoord[2]+4 Say OemToAnsi( STR0035 ) Size 290,07 Pixel Font oFont Color CLR_BLUE //"Esta rotina tem como objetivo efetuar o Cálculo de Metas, com base no critério"
	@ aGdCoord[1]+32,aGdCoord[2]+4 Say OemToAnsi( STR0036 ) Size 290,07 Pixel Font oFont Color CLR_BLUE //"estabelecido em 'Parâmetros'."

	aButtons	:=	{;
		{STR0029  ,{ || SetFunName("APDM032"), Pergunte("APDM040",.T. ), SetFunName("APDM040") },STR0015,STR0015};
		}

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , { || nOpca 	:= 1, oDlg:End() } , { || nOpca 	:= 0 , oDlg:End() } , NIL , aButtons )

	SetaPilha()

	/*
	Variaveis utilizadas para Parâmetros
	*/
	If nOpca == 1
		Processa({|lEnd| APDM040Proc(),OemToAnsi(STR0034)}) //"Cálculo de Metas"
	EndIf

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} APDM040Proc
@type function
@author Eduardo Ferreira
@since 24/06/2016
@version 1.0
@description Processamento dos cálculos
/*/
Static Function APDM040Proc()

	Local nRound		:= SuperGetMV("MV_APDARRM", .F. , 4,  )
	Local nResult		:= 0
	Local nIndex		:= 0
	Local nMaxTot		:= 0
	Local nValorPes		:= 0
	Local nPercent		:= 0
	Local nx			:= 0
	Local cIndex		:= ""

	Local cRDJStsNOT	:= "'4/6'" //Status da RDJ que nao serao calculados
	Local aProcessados	:= {}
	Local aZerados		:= {}
	Local aPendHist		:= {}
	Local aLog			:= {}
	Local aStru			:= {}
	Local aStrPRDV		:= {"RDJ_FILIAL","RDJ_CODOBJ","RDJ_PERIOD","RDJ_CODPAR","RDJ_CODDOR","RDV_VERATU","RDV_STATUS","RD0_NOME","RBL_VALOR"}
	Local lReprocessa	:= (mv_par05 == 1)
	Local lContinua		:= .T.
	Local aLstIndices := {}
	Private oTmpPRDV

	//Atualiza parâmetros com Range para transformar em filtro de query
	//MakeSqlExpr("APDM040")

	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,STR0022 + DtoC(Date()) + " / " + Time()) //"Data/Hora de Início do Processamento: "
	aAdd(aLog,"----------------------------------------------------------------------")
	aAdd(aLog,"-------------")
	aAdd(aLog,STR0023) //"Parâmetros: "
	aAdd(aLog,"-------------")
	aAdd(aLog,STR0024 + MV_PAR01 + " - " + Posicione("RDU",1,xFilial("RDU")+MV_PAR01,"RDU_DESC")) //"Período: " | |
	aAdd(aLog,STR0025 + IIF(Empty(mv_par01),"''","'"+mv_par03+"' à '"+mv_par04+"'")) //"Matrícula(s): "
	aAdd(aLog,STR0026 + Iif(lReprocessa,STR0027,STR0028)) //"Reprocessa?: " / "Sim" / "Não"
	aAdd(aLog," ")


	//Seleção das Areas
	dbSelectArea("RDU")
	dbSelectArea("RDJ")
	dbSelectArea("RBL")
	dbSelectArea("RDV")
	RDU->(dbSetOrder(1))
	RDV->(dbSetOrder(3))
	RDJ->(dbSetOrder(1))
	RBL->(dbSetOrder(1))



	// Verifica se periodo foi finalizado
	If dbSeek(xFilial("RDU")+MV_PAR01)
		If RDU->RDU_FIMRES >= date()
			lContinua := .F.
			help("APDM040P",   ,"RDU_FIMRES"      ,STR0007, STR0039,1,0,,,,,) //"Período" #//"O Período informado ainda encontra-se aberto para Manutenção dos Resultados das Metas. (Campo RDU_FIMRES)"
		Endif
	EndIf

	if lContinua


		If Select("PRDV") > 0
			dbSelectArea("PRDV")
			dbCloseArea()
		Endif

		If oTmpPRDV <> Nil
			oTmpPRDV:Delete()
			Freeobj(oTmpPRDV)
		EndIf



		//=======================================================================
		// Busca das informações dos campos a serem buscados
		//=======================================================================
		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 to Len(aStrPRDV)
			If MsSeek(aStrPRDV[nX],.F.)
				If(aStrPRDV[nX]=="RBL_VALOR")
					aAdd(aStru,{"TOTMAX", SX3->X3_TIPO, SX3->X3_TAMANHO + 10, SX3->X3_DECIMAL })
				Else
					aAdd(aStru,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL })
				EndIf
			Endif
		Next
		//=======================================================================
		//Criação do arquivo temporário para facilitar a busca do Valor Maximo de atingimento
		//=======================================================================

		AAdd( aLstIndices, {"RDJ_FILIAL","RDJ_PERIOD","RDJ_CODOBJ","RDJ_CODPAR"})

		oTmpPRDV := RhCriaTrab('PRDV', aStru, aLstIndices)

		FazQuery(lReprocessa)



		PRDV->( dbSetOrder( 1 ) )
		PRDV->(dbGoTop())

		If RDV->(dbSeek(xFilial("RDV")+mv_par01+mv_par02))
			While !RDV->(Eof()) .And.  RDV->(RDV_FILIAL + RDV_CODPER + RDV_CODOBJ)==(xFilial("RDV") + mv_par01 + mv_par02)

				If RDV->RDV_STATUS <> "3"
					aAdd(aPendHist , {RDV->RDV_FILIAL,RDV->RDV_CODPAR,POSICIONE('RD0',1,XFILIAL('RD0')+RDV->RDV_CODPAR,'RD0_NOME'),RDV->RDV_CODDOR})
				Else
					If RDJ->(DbSeek(xFilial("RDJ")+ RDV->RDV_CODPAR+RDV->RDV_CODOBJ+RDV->RDV_CODPER)) .And. !Empty(RDJ->RDJ_ITESAT) .And. !Empty(RDJ->RDJ_ESCATG)
						While RDJ->(RDJ_FILIAL+RDJ_CODPAR+RDJ_CODOBJ+RDJ_PERIOD)== (xFilial("RDJ")+ RDV->RDV_CODPAR+RDV->RDV_CODOBJ+RDV->RDV_CODPER)
							If !(RDJ->RDJ_STATUS $ cRDJStsNOT) .And. (RDJ->RDJ_VERITM ==  RDV->RDV_VERATU)

								//Váriaveis de controle
								nPercent	:= 0
								nMaxTot		:= 0
								nValorPes	:= 0
								nResult		:= 0

								//Busca do peso correspondente
								If !Empty(RDJ->RDJ_ESCREA).And. !Empty(RDJ->RDJ_ITESCR)
									If RBL->(MsSeek(xFilial("RBL")+RDJ->RDJ_ESCREA+RDJ->RDJ_ITESCR))
										nValorPes	:= RBL->RBL_VALOR
									EndIf
								EndIF

								//Busca dados do percentual correspondente
								If !Empty(RDJ->RDJ_ESCATG).And. !Empty(RDJ->RDJ_ITESAT)
									If RBL->(MsSeek(xFilial("RBL")+RDJ->RDJ_ESCATG+RDJ->RDJ_ITESAT))
										nPercent	:= RBL->RBL_VALOR
									EndIf
								EndIF

								//Busca os dados de Pontuação Maxima do Participante posicionado
								if PRDV->(DbSeek(xFilial("RDJ")+RDJ->RDJ_PERIOD+RDJ->RDJ_CODOBJ+RDJ->RDJ_CODPAR))
									nMaxTot	:= PRDV->TOTMAX
								EndIf

								//Só realizará o calculo se houver valor de totalizador
								if nMaxTot > 0
									nResult:= Round((Round((nValorPes * nPercent),nRound) / nMaxTot) * 100,nRound)
								EndIf

								RecLock("RDJ",.F.)
								RDJ->RDJ_RESULT := nResult
								RDJ->RDJ_DTCALC := date()
								RDJ->(MsUnlock())
								aAdd(aProcessados,{RDV->RDV_FILIAL, RDV->RDV_CODPAR, POSICIONE('RD0',1,XFILIAL('RD0')+RDV->RDV_CODPAR,'RD0_NOME'),RDJ->RDJ_ITOBJ+'-'+RDJ->RDJ_ITEM})
							EndIf
							RDJ->(dbSkip())
						EndDo
					Else
						aAdd(aZerados,{RDV->RDV_FILIAL, RDV->RDV_CODPAR, POSICIONE('RD0',1,XFILIAL('RD0')+RDV->RDV_CODPAR,'RD0_NOME'), ""})
					EndIf
				EndIf

				RDV->(dbSkip())
			EndDo
		EndIf

		PRDV->(dbCloseArea())

		aAdd(aLog,"-------------")
		aAdd(aLog,STR0018) //"Resumo: "
		aAdd(aLog,"-------------")
		aAdd(aLog,STR0019 + AllTrim(Str(Len(aProcessados)))) //"Registros Processados com Sucesso: "
		aAdd(aLog,STR0020 + AllTrim(Str(Len(aPendHist)))) 	 //"Registros Não Processados: "
		aAdd(aLog," ")
		aAdd(aLog,"----------------------------------------------------------------------")
		aAdd(aLog,STR0021 + DtoC(Date()) + " / " + Time()) //"Data/Hora de Término do Processamento: "
		aAdd(aLog,"----------------------------------------------------------------------")

		GravaLog(aLog,aProcessados,aPendHist,aZerados)
	EndIf

	If Select("PRDV") > 0
		dbSelectArea("PRDV")
		dbCloseArea()
	Endif

	If oTmpPRDV <> Nil
		oTmpPRDV:Delete()
		Freeobj(oTmpPRDV)
	EndIf


Return Nil




/*/{Protheus.doc} GravaLog

@type function
@author Jorge Heitor
@since 08/04/2016
@version 1.0
@description Apresenta LOG (Resumo) e permite visualizar Log Completo dos dados processados

/*/
Static Function GravaLog(aLog,aProcessados,aPendHist,aZerados)

	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca
	Local oDlg1
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aGDCoord		:= {}
	Local aArea			:= GetArea()
	Local cLog			:= ""
	Local cNameArq		:= "Log_"+DTOS(date())
	Local cArq			:= GetSrvProfString("Startpath", "") + cNameArq + ".txt"
	Local nHandle		:= fCreate(cArq)
	Local x
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RD0_NOME"} ), {} )
	Local lOfusca		:= Len(aFldRel) > 0

	Private cCadastro 	:= OemToAnsi(STR0037) //"Processamento Concluído"

	If nHandle < 0

		MsgStop(STR0038) //"_GravaLog - Não foi possivel criar o arquivo de Log."

	EndIf

	cLog := STR0017 + CRLF //"Processo concluído! Clique em 'Confirmar' para mais detalhes."
	cLog += CRLF

	For x := 1 To Len(aLog)

		cLog += aLog[x] + CRLF
		FWrite(nHandle,aLog[x]+CRLF)

	Next x

	FWrite(nHandle,CRLF)
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,STR0010 + CRLF) //"REGISTROS PROCESSADOS COM SUCESSO"
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,CRLF)
	FWrite(nHandle,PadR(STR0012,10) + PadR(STR0013,10) + ' ' + PadR(STR0014,35) + PadR(STR0016,60) + CRLF) //"Filial" | "Cód.Partic" | "Nome" | "Meta(s)"
	FWrite(nHandle,Replicate("-",9) + " " + Replicate("-",10) + " " + Replicate("-",34) + " " + Replicate("-",59) + " " + CRLF)

	For x := 1 To Len(aProcessados)

		FWrite(nHandle,PadR(aProcessados[x][1],10) + PadR(aProcessados[x][2],11) + If(lOfusca, Replicate('*',35), PadR(aProcessados[x][3],35) ) + PadR(aProcessados[x][4],60) + CRLF)

	Next x

	FWrite(nHandle,CRLF)
	FWrite(nHandle,CRLF)
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,STR0011 + CRLF) //"REGISTROS NÃO PROCESSADOS - SEM RESULTADO INFORMADO PELO GESTOR"
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,CRLF)
	FWrite(nHandle,PadR(STR0012,10) + PadR(STR0013,10) + ' ' + PadR(STR0014,35) + PadR(STR0016,60) + CRLF) //"Filial" | "Matrícula" | "Nome" | "Meta(s)"
	FWrite(nHandle,Replicate("-",9) + " " + Replicate("-",10) + " " + Replicate("-",34) + " " + Replicate("-",59) + " " + CRLF)

	For x := 1 To Len(aZerados)

		FWrite(nHandle,PadR(aZerados[x][1],10) + PadR(aZerados[x][2],11) + If(lOfusca, Replicate('*',35), PadR(aZerados[x][3],35) ) + PadR(aZerados[x][4],60) + CRLF)

	Next x


	FWrite(nHandle,CRLF)
	FWrite(nHandle,CRLF)
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,STR0031 + CRLF) //"REGISTROS NÃO PROCESSADOS - SEM FINALIZAÇÃO PARA HISTÓRICO"
	FWrite(nHandle,Replicate("-",115) + CRLF)
	FWrite(nHandle,CRLF)
	FWrite(nHandle,PadR(STR0012,10) + PadR(STR0013,10) + ' ' + PadR(STR0014,35) + PadR(STR0032,60) + CRLF) //"Filial" | "Cód. Participante" | "Nome" | "Avaliador"
	FWrite(nHandle,Replicate("-",9) + " " + Replicate("-",10) + " " + Replicate("-",34) + " " + Replicate("-",59) + " " + CRLF)

	For x := 1 To Len(aPendHist)

		FWrite(nHandle,PadR(aPendHist[x][1],10) + PadR(aPendHist[x][2],11) + If(lOfusca, Replicate('*',35), PadR(aPendHist[x][3],35) ) + PadR(aPendHist[x][4],60) + CRLF)

	Next x
	FClose(nHandle)

	/*
	Monta dimensões dos objetos
	*/
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]		:= (aAdvSize[5]/100) * 35	//horizontal
	aAdvSize[6]		:= (aAdvSize[6]/100) * 55	//Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*25), (((aObjSize[1,4])/100)*29.6) }	//1,3 Vertical /1,4 Horizontal

	SetaPilha()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg1 TITLE cCadastro FROM  aAdvSize[7],20 TO aAdvSize[6]-50,600  OF oMainWnd PIXEL

	@ aGdCoord[1]+7,aGdCoord[2]	GROUP oGroup1 TO (aGdCoord[3]*1.9)+5,aGdCoord[4]+5  LABEL "" OF oDlg1 PIXEL
	oGroup1:oFont:=oFont
	@ aGdCoord[1],aGdCoord[2] Get oGet Var cLog Memo Size 273,173 OF oGroup1 Pixel

	aButtons	:=	{}

	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar( oDlg1 , { || nOpca 	:= 1, oDlg1:End() } , { || nOpca 	:= 0 , oDlg1:End() } , NIL , aButtons )

	SetaPilha()

	/*
	Variaveis utilizadas para Parâmetros
	*/
	If nOpca == 1
		AbreLog(cArq)
	EndIf
	Delete File(cArq)

	RestArea(aArea)

Return Nil


/*/{Protheus.doc} APDM040P

@type function
@author Jorge Heitor
@since 07/04/2016
@version 1.0
@description Validações específicas para constatar se o período informado no parâmetro pode ser utilizado para o Cálculo de Metas

/*/
Static Function AbreLog(cArquivo)

	Local cNomeArq	:= Iif(SubStr(cArquivo,1,1) $ "\", SubsTr(cArquivo, RAT("\",cArquivo) ,Len(cArquivo)),cArquivo)
	Local cDirLocal	:= GetTempPath()

	If CpyS2T(cArquivo,cDirLocal)
		ShellExecute("Open",cDirLocal + cNomeArq, "", "C:\", 3 )
	Else
		MsgStop(STR0008 + cNomeArq + STR0009) // "Falha na cópia do arquivo " | " para visualização. O arquivo estará disponível na pasta '\SYSTEM\' do Servidor."
	Endif

Return Nil

/*/{Protheus.doc} FazQuery

@type function
@author Oswaldo Leite
@since 20/04/2017
@version 1.0
@description Popula arquivo temporario

/*/

Static function FazQuery(lReprocessa)
Local cQrAlias := GetNextAlias()
Local aStrPRDV := {"RDJ_FILIAL","RDJ_CODOBJ","RDJ_PERIOD","RDJ_CODPAR","RDJ_CODDOR","RDV_VERATU","RDV_STATUS","RD0_NOME","RBL_VALOR" }
Local nX       := 0
Local cCmp1    := "PRDV->TOTMAX"
Local cCmp2    := ''

If  !Empty(MV_PAR04)

	If !lReprocessa

			BeginSql alias cQrAlias

				SELECT RDJ.RDJ_FILIAL,
				       RDJ.RDJ_CODOBJ,
				       RDJ.RDJ_PERIOD,
				       RDJ.RDJ_CODPAR,
			           RDJ.RDJ_CODDOR,
			           RDV.RDV_VERATU,
			           RDV.RDV_STATUS,
			           RD0.RD0_NOME,
			           SUM(RBL.RBL_VALOR)* 100 AS TOTMAX
				       FROM  %table:RDJ% RDJ

				       INNER JOIN  %table:RD0% RD0
				        ON	(RD0.RD0_CODIGO = RDJ.RDJ_CODPAR)

				       INNER JOIN  %table:RDV% RDV
				       	ON (RDJ.RDJ_CODOBJ = RDV.RDV_CODOBJ AND
				       		RDJ.RDJ_PERIOD = RDV.RDV_CODPER AND
				       		RDJ.RDJ_CODDOR = RDV.RDV_CODDOR AND
				       		RDJ.RDJ_CODPAR = RDV.RDV_CODPAR AND
				       		RDJ.RDJ_VERITM = RDV.RDV_VERATU )

				        INNER JOIN  %table:RBL% RBL
				         ON (	RDJ.RDJ_FILIAL = RBL.RBL_FILIAL AND
				                RDJ.RDJ_ESCREA = RBL.RBL_ESCALA AND
				                RDJ.RDJ_ITESCR = RBL.RBL_ITEM )

				  WHERE RDV.%notDel% AND
				        RDJ.%notDel% AND
				        RBL.%notDel% AND
				        RDV.RDV_FILIAL = %exp:(FwxFilial("RDV"))% AND
				        RDJ.RDJ_FILIAL = %exp:(FwxFilial("RDJ"))% AND
				        RBL.RBL_FILIAL = %exp:(FwxFilial("RBL"))%

	     		AND RD0.RD0_CODIGO BETWEEN  %exp:( IIF(Empty(MV_PAR03),"",MV_PAR03)  )%  AND   %exp:( MV_PAR04 )%
				AND  RDJ_DTCALC = ''

				//Monta condições para o filtro e o valor maximo de pontuação
				AND RDV.RDV_CODPER = %exp:(mv_par01)%
				AND RDV.RDV_CODOBJ = %exp:(mv_par02)%

				AND	RDJ.RDJ_STATUS NOT IN ('4','6')
				AND RDV.RDV_STATUS = '3'

				GROUP BY	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME
				ORDER BY 	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME

		EndSql
	Else

		BeginSql alias cQrAlias

			SELECT RDJ.RDJ_FILIAL,
				       RDJ.RDJ_CODOBJ,
				       RDJ.RDJ_PERIOD,
				       RDJ.RDJ_CODPAR,
			           RDJ.RDJ_CODDOR,
			           RDV.RDV_VERATU,
			           RDV.RDV_STATUS,
			           RD0.RD0_NOME,
			           SUM(RBL.RBL_VALOR)* 100 AS TOTMAX
				       FROM  %table:RDJ% RDJ

				       INNER JOIN  %table:RD0% RD0
				        ON	(RD0.RD0_CODIGO = RDJ.RDJ_CODPAR)

				       INNER JOIN  %table:RDV% RDV
				       	ON (RDJ.RDJ_CODOBJ = RDV.RDV_CODOBJ AND
				       		RDJ.RDJ_PERIOD = RDV.RDV_CODPER AND
				       		RDJ.RDJ_CODDOR = RDV.RDV_CODDOR AND
				       		RDJ.RDJ_CODPAR = RDV.RDV_CODPAR AND
				       		RDJ.RDJ_VERITM = RDV.RDV_VERATU )

				        INNER JOIN  %table:RBL% RBL
				         ON (	RDJ.RDJ_FILIAL = RBL.RBL_FILIAL AND
				                RDJ.RDJ_ESCREA = RBL.RBL_ESCALA AND
				                RDJ.RDJ_ITESCR = RBL.RBL_ITEM )

				  WHERE RDV.%notDel% AND
				        RDJ.%notDel% AND
				        RBL.%notDel% AND
				        RDV.RDV_FILIAL = %exp:(FwxFilial("RDV"))% AND
				        RDJ.RDJ_FILIAL = %exp:(FwxFilial("RDJ"))% AND
				        RBL.RBL_FILIAL = %exp:(FwxFilial("RBL"))%

	     		AND RD0.RD0_CODIGO BETWEEN  %exp:( IIF(Empty(MV_PAR03),"",MV_PAR03)  )%  AND   %exp:( MV_PAR04 )%

				//Monta condições para o filtro e o valor maximo de pontuação
				AND RDV.RDV_CODPER = %exp:(mv_par01)%
				AND RDV.RDV_CODOBJ = %exp:(mv_par02)%

				AND	RDJ.RDJ_STATUS NOT IN ('4','6')
				AND RDV.RDV_STATUS = '3'

				GROUP BY	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME
				ORDER BY 	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME

		EndSql
	EndIf
Else

	If !lReprocessa

		BeginSql alias cQrAlias

			SELECT RDJ.RDJ_FILIAL,
				       RDJ.RDJ_CODOBJ,
				       RDJ.RDJ_PERIOD,
				       RDJ.RDJ_CODPAR,
			           RDJ.RDJ_CODDOR,
			           RDV.RDV_VERATU,
			           RDV.RDV_STATUS,
			           RD0.RD0_NOME,
			           SUM(RBL.RBL_VALOR)* 100 AS TOTMAX
				       FROM  %table:RDJ% RDJ

				       INNER JOIN  %table:RD0% RD0
				        ON	(RD0.RD0_CODIGO = RDJ.RDJ_CODPAR)

				       INNER JOIN  %table:RDV% RDV
				       	ON (RDJ.RDJ_CODOBJ = RDV.RDV_CODOBJ AND
				       		RDJ.RDJ_PERIOD = RDV.RDV_CODPER AND
				       		RDJ.RDJ_CODDOR = RDV.RDV_CODDOR AND
				       		RDJ.RDJ_CODPAR = RDV.RDV_CODPAR AND
				       		RDJ.RDJ_VERITM = RDV.RDV_VERATU )

				        INNER JOIN  %table:RBL% RBL
				         ON (	RDJ.RDJ_FILIAL = RBL.RBL_FILIAL AND
				                RDJ.RDJ_ESCREA = RBL.RBL_ESCALA AND
				                RDJ.RDJ_ITESCR = RBL.RBL_ITEM )

				  WHERE RDV.%notDel% AND
				        RDJ.%notDel% AND
				        RBL.%notDel% AND
				        RDV.RDV_FILIAL = %exp:(FwxFilial("RDV"))% AND
				        RDJ.RDJ_FILIAL = %exp:(FwxFilial("RDJ"))% AND
				        RBL.RBL_FILIAL = %exp:(FwxFilial("RBL"))%

				//Monta condições para o filtro e o valor maximo de pontuação
				AND RDV.RDV_CODPER = %exp:(mv_par01)%
				AND RDV.RDV_CODOBJ = %exp:(mv_par02)%

				AND	RDJ.RDJ_STATUS NOT IN ('4','6')
				AND  RDV.RDV_STATUS = '3'
				AND  RDJ.RDJ_DTCALC = ''

				GROUP BY	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME
				ORDER BY 	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME

		EndSql
	Else

		BeginSql alias cQrAlias

				SELECT RDJ.RDJ_FILIAL,
				       RDJ.RDJ_CODOBJ,
				       RDJ.RDJ_PERIOD,
				       RDJ.RDJ_CODPAR,
			           RDJ.RDJ_CODDOR,
			           RDV.RDV_VERATU,
			           RDV.RDV_STATUS,
			           RD0.RD0_NOME,
			           SUM(RBL.RBL_VALOR)* 100 AS TOTMAX
				       FROM  %table:RDJ% RDJ

				       INNER JOIN  %table:RD0% RD0
				        ON	(RD0.RD0_CODIGO = RDJ.RDJ_CODPAR)

				       INNER JOIN  %table:RDV% RDV
				       	ON (RDJ.RDJ_CODOBJ = RDV.RDV_CODOBJ AND
				       		RDJ.RDJ_PERIOD = RDV.RDV_CODPER AND
				       		RDJ.RDJ_CODDOR = RDV.RDV_CODDOR AND
				       		RDJ.RDJ_CODPAR = RDV.RDV_CODPAR AND
				       		RDJ.RDJ_VERITM = RDV.RDV_VERATU )

				        INNER JOIN  %table:RBL% RBL
				         ON (	RDJ.RDJ_FILIAL = RBL.RBL_FILIAL AND
				                RDJ.RDJ_ESCREA = RBL.RBL_ESCALA AND
				                RDJ.RDJ_ITESCR = RBL.RBL_ITEM )

				  WHERE RDV.%notDel% AND
				        RDJ.%notDel% AND
				        RBL.%notDel% AND
				        RDV.RDV_FILIAL = %exp:(FwxFilial("RDV"))% AND
				        RDJ.RDJ_FILIAL = %exp:(FwxFilial("RDJ"))% AND
				        RBL.RBL_FILIAL = %exp:(FwxFilial("RBL"))%

				//Monta condições para o filtro e o valor maximo de pontuação
				AND RDV.RDV_CODPER = %exp:(mv_par01)%
				AND RDV.RDV_CODOBJ = %exp:(mv_par02)%

				AND	RDJ.RDJ_STATUS NOT IN ('4','6')
				AND RDV.RDV_STATUS = '3'

				GROUP BY	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME
				ORDER BY 	RDJ.RDJ_FILIAL,RDJ.RDJ_CODOBJ,RDJ.RDJ_PERIOD,RDJ.RDJ_CODPAR,RDJ.RDJ_CODDOR,RDV.RDV_VERATU,RDV.RDV_STATUS,RD0.RD0_NOME

		EndSql
	EndIf
EndIf


dbSelectArea("SX3")
dbSetOrder(2)

While (cQrAlias)->(!Eof())

	reclock('PRDV',.T.)
	For nX := 1 to LEN (aStrPRDV)
		If SX3->( MsSeek(aStrPRDV[nX] , .F.) )

			If aStrPRDV[nX] == "RBL_VALOR"
			    cCmp1    := "PRDV->TOTMAX"
			    cCmp2 := "(cQrAlias)->(TOTMAX)"
				&cCmp1 := &cCmp2
			Else
			    cCmp1    := "PRDV->" + SX3->X3_CAMPO
			    cCmp2    := "(cQrAlias)->(" + SX3->X3_CAMPO + ")"
				&cCmp1 := &cCmp2
			EndIf

		EndIf
	Next
	MsUnLock()

	(cQrAlias)->(DBSkip())
End

(cQrAlias)->(DBCloseArea())

return
