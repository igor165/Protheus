#Include 'Protheus.ch'
#Include 'GPEA091.ch'

Static __aSeqLogFunc
Static __cChaveProc
Static __lTemRFT

/*/{Protheus.doc} GPEA091
//	Tela para Consulta de Memória de Cálculo do Funcionário.
	De acordo com o funcinário selecionado no browse, exibe lista, em ordem cronológica, dos logs disponíveis para consulta.
@author esther.viveiro
@since 06/01/2018
@version P12
@param nRotina, numeric, Identifica a rotina que está chamando a tela a fim de preparar filtro dos logs. 1 = GPEA090; 2 = GPEM040; 3 = GPEM030
/*/
Function GPEA091(nRotina)
Local cFilFunc	:= SRA->RA_FILIAL
Local cMat		:= SRA->RA_MAT
Local cFuncDet	:= ""
Local cMensagem	:= ""
Local cRot		:= ""
Local cWhere	:= "%%"
Local cAliasRFT	:= GetNextAlias()

Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local lOfuscaNom	:= .F.
Local aFldRot 		:= {'RA_NOME'}
Local aFldOfusca 	:= {}
Local lOfuscaNom	:= .F.

Local aArea 		:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aBrowse		:= {}

Local bLDblClick	:= {|| fViewLog(aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07])} //Processo, Periodo, Nr.Pagto, Roteiro, Data, Hora

Local oDlg,oScroll,oSay,oSay1

DEFAULT __lTemRFT := ChkFile('RFT')

If __lTemRFT
	If nRotina == 2 //Rescisao
		cRot := fGetCalcRot('4')
		cWhere := "%AND RFT_ROTEIR = '"+cRot+"'%"
	ElseIf nRotina == 3 //Ferias
		cRot := fGetCalcRot('3')
		cWhere := "%AND RFT_ROTEIR = '"+cRot+"'%"
	EndIf

	BeginSql alias cAliasRFT
		SELECT * FROM %table:RFT% RFT
			WHERE RFT_FILIAL = %exp:cFilFunc% AND RFT_MAT = %exp:cMat%
			AND RFT.%notDel%
			%exp:cWhere%
		ORDER BY RFT_DATA DESC, RFT_HORA DESC
	EndSql

	//Protecao de Dados Sensiveis
	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
			lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
	EndIf

	If (cAliasRFT)->(!EoF())
		While (cAliasRFT)->(!EoF())
			aAdd(aBrowse,{(cAliasRFT)->RFT_FILIAL,(cAliasRFT)->RFT_PROCES,(cAliasRFT)->RFT_PERIOD,(cAliasRFT)->RFT_SEMANA,(cAliasRFT)->RFT_ROTEIR,DtoC(StoD((cAliasRFT)->RFT_DATA)),(cAliasRFT)->RFT_HORA})
			(cAliasRFT)->(DbSkip())
		EndDo

		cFuncDet := OemToAnsi(STR0012) + cMat + " - " + If(lOfuscaNom, Replicate('*',15),SRA->RA_NOME) + Space(10)

		aAdvSize := MsAdvSize(.F.)
		aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

		DEFINE FONT oFont NAME "Arial" SIZE 0,-13
		DEFINE FONT oFont2 NAME "Arial" SIZE 0,-12
		DEFINE MSDIALOG oDlg FROM 0,0 TO aAdvSize[6]*0.60,aAdvSize[5]*0.5 PIXEL TITLE OemToAnsi(STR0016)

		oScroll:= TScrollBox():New(oDlg,aObjSize[1,1]+05,aObjSize[1,1]+05,aObjSize[1,3]*0.08,aObjSize[1,4]*0.49,.T.,.T.,.T.)
		oSay1 := TSay():New( aObjSize[1,1]+05, aObjSize[1,1]+05, {|| cFuncDet } ,oScroll,,,,,,.T.,,, aObjSize[1,1]+200, aObjSize[1,1]) //detalhe funcionario
		oSay1:oFont:= oFont

		oBrowse := TWBrowse():New((aObjSize[1,3]*0.08)+05,aObjSize[1,1]+05,aObjSize[1,4]*0.49, aObjSize[1,3]*0.52,,{OemToAnsi(STR0015),OemToAnsi(STR0005),OemToAnsi(STR0018),OemToAnsi(STR0004),OemToAnsi(STR0006),OemToAnsi(STR0002),OemToAnsi(STR0020),''},{},oDlg,,,,,bLDblClick,,oFont2,,,,,.F.,,.T.,,.F.,,, )

		// Define vetor para a browse
		oBrowse:SetArray(aBrowse)
		oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAt,04],aBrowse[oBrowse:nAt,05],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07]}}

		// ativa diálogo centralizado
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		cMensagem := OemToAnsi(STR0017) + CRLF
		cMensagem += OemToAnsi(STR0012) + cMat + " - " + If(lOfuscaNom, Replicate('*',15),SRA->RA_NOME)
		Help("",1,OemToAnsi(STR0019), Nil,cMensagem, 1, 0 )
	EndIf

	(cAliasRFT)->(DBCloseArea())
	RestArea(aArea)
Else
	cMensagem := CRLF +  OemToAnsi(STR0026) + CRLF
	cMensagem += OemToAnsi(STR0027) + CRLF + OemToAnsi(STR0028)
	Help("",1,OemToAnsi(STR0029), Nil,cMensagem, 1, 0 )
EndIf
Return


/*/{Protheus.doc} fViewLog
//Tela para exibição do log do cálculo selecionado.
@author esther.viveiro
@since 06/01/2018
@version P12
@param cProcesso	, characters, código do Processo do cálculo
@param cPeriodo		, characters, código do Período do cálculo
@param cSemana		, characters, Número de Pagamento do período do cálculo
@param cRoteiro		, characters, código do Roteiro do cálculo
@param cData		, characters, Data de execução do cálculo
@param cHora		, characters, Hora de execução do cálculo
/*/
Function fViewLog(cProcesso, cPeriodo, cSemana, cRoteiro, cData, cHora)
Local cFilFunc	:= SRA->RA_FILIAL
Local cMat		:= SRA->RA_MAT
Local cDFormula	:= ""
Local cSeqAux	:= ""
Local cCabecalho:= ""
Local cFuncDet	:= ""
Local cSitFunc	:= ""

Local aArea 		:= GetArea()
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aBrowseDet	:= {}
Local aLogDet		:= {}

Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T. , .F.}) //[1] Acesso; [2]Ofusca
Local aFldRot 		:= {'RA_NOME', 'RA_ADMISSA'}
Local lOfuscaNom	:= .F.
Local lOfuscaAdm	:= .F.
Local aFldOfusca 	:= {}

Local nX	:= 0
Local nLen	:= 0
Local bChangeDet := {|| oSay2Det:SetText(aLogDet[oBrowseDet:nAt,1])}

Local oDlgDet,oScrollDet,oSayDet,oSay1Det

	//Protecao de Dados Sensiveis
	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0 
			lOfuscaNom	:= FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_ADMISSA" } ) > 0 
			lOfuscaAdm	:= FwProtectedDataUtil():IsFieldInList( "RA_ADMISSA" )
		ENDIF
	EndIf

	cData := DtoS(CtoD(cData))
	DbSelectArea("RFV")
		RFV->(DbSetORder(1)) //Filial + Mat + Processo + Periodo + Semana + Roteiro + Data + Hora
		RFV->(DbSeek(cFilFunc+cMat+cProcesso+cPeriodo+cSemana+cRoteiro+cData+cHora))
		While (RFV->(!EoF()) .AND. RFV->(RFV_FILIAL+RFV_MAT+RFV_PROCES+RFV_PERIOD+RFV_SEMANA+RFV_ROTEIR)+DtoS(RFV->RFV_DATA)+RFV->RFV_HORA == cFilFunc+cMat+cProcesso+cPeriodo+cSemana+cRoteiro+cData+cHora)
			If RFV->RFV_SEQUEN != cSeqAux
				cDFormula := fDesc("RC2",Substr( RFV->RFV_FORMUL, 3 , 7 ),"RC2_DESC",,,2)
				aAdd(aBrowseDet,{RFV->RFV_SEQUEN, AllTrim(cDFormula) , AllTrim(RFV->RFV_FORMUL) })
				cSeqAux := RFV->RFV_SEQUEN
				aAdd(aLogDet,{''})
				nX++
			EndIf
			aLogDet[nX,1] += RFV->RFV_LOG + CRLF
			If Len(aLogDet[nX,1]) > nLen
				nLen := Len(aLogDet[nX,1])
			EndIf
			RFV->(DbSkip())
		EndDo
	RFV->(DbCloseArea())

	nLen := nLen * 0.3
	nLen := Max(500,nLen)

	DbSelectArea("RFT")
		RFT->(DbSetOrder(1)) //Filial + Mat + Processo + Periodo + Semana + Roteiro + Data + Hora
		RFT->(DbSeek(cFilFunc+cMat+cProcesso+cPeriodo+cSemana+cRoteiro+cData+cHora))

		cSitFunc := If(Empty(RFT->RFT_SITFUN),OemToAnsi(STR0007),If(RFT->RFT_SITFUN=="A",OemToAnsi(STR0008),If(RFT->RFT_SITFUN=="F",OemToAnsi(STR0009),If(RFT->RFT_SITFUN=="T",OemToAnsi(STR0010),OemToAnsi(STR0011)))))

		cFuncDet := Space(85) + OemToAnsi(STR0001) + CRLF
		cFuncDet += Replicate(" -",134) + CRLF
		cFuncDet += OemToAnsi(STR0012) + cMat + " - " + If(lOfuscaNom, Replicate('*',15),SRA->RA_NOME) + Space(10)
		cFuncDet += OemToAnsi(STR0013) + If(lOfuscaAdm,Replicate('*',10),DtoC(SRA->RA_ADMISSA)) + Space(10)
		cFuncDet += OemToAnsi(STR0014) + Substr(cSitFunc + Space(10),1,11) + CRLF
		cFuncDet += Replicate(" -",134) + CRLF

		cCabecalho := OemToAnsi(STR0002) + ": " + DtoC(RFT->RFT_DATA) + Space(05) +  RFT->RFT_HORA + CRLF
		cCabecalho += OemToAnsi(STR0022) + RFT->RFT_USER + CRLF
		cCabecalho += OemToAnsi(STR0003) + cPeriodo + Space(5) + " - " + Space(5) + OemToAnsi(STR0004) + ": " + cSemana + Space(5) + " - " + Space(5) + OemToAnsi(STR0005) + ": " + cProcesso + Space(5) + " - " + Space(5) + OemToAnsi(STR0006) + ": " + cRoteiro + CRLF
		cCabecalho += Replicate(" -",134) + CRLF

	RFT->(DbCloseArea())

	aAdvSize := MsAdvSize(.F.)
	aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize := MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont NAME "Arial" SIZE 0,-13
	DEFINE FONT oFont2 NAME "Arial" SIZE 0,-12
	DEFINE MSDIALOG oDlgDet FROM 0,0 TO aAdvSize[6]*0.95,aAdvSize[5]*0.7 PIXEL TITLE OemToAnsi(STR0016)

	oScrollDet:= TScrollBox():New(oDlgDet,aObjSize[1,1]+05,aObjSize[1,1]+05,aObjSize[1,3]*0.19,aObjSize[1,4]*0.69,.T.,.T.,.T.)
	oSay1Det := TSay():New( aObjSize[1,1]+05, aObjSize[1,1]+05, {|| cFuncDet } ,oScrollDet,,,,,,.T.,,, aObjSize[1,1]+550, aObjSize[1,1]+35) //detalhe funcionario
	oSay1Det:oFont:= oFont
	oSayDet := TSay():New( aObjSize[1,1]+40, aObjSize[1,1]+05, {|| cCabecalho } ,oScrollDet,,,,,,.T.,,, aObjSize[1,1]+550, aObjSize[1,1]+40) //cabecalho
	oSayDet:oFont:= oFont

	oBrowseDet := TWBrowse():New((aObjSize[1,3]*0.2)+05,aObjSize[1,1]+05,aObjSize[1,4]*0.20, aObjSize[1,3]*0.72,,{OemToAnsi(STR0023),OemToAnsi(STR0024),OemToAnsi(STR0025)},{20,150,50},oDlgDet,,,,bChangeDet,,,oFont2,,,,,.F.,,.T.,,.F.,,, ) //Sequência ## Descrição ## Fórmula

	// Define vetor para a browse
	oBrowseDet:SetArray(aBrowseDet)
	oBrowseDet:bLine := {||{ aBrowseDet[oBrowseDet:nAt,01],aBrowseDet[oBrowseDet:nAt,02],aBrowseDet[oBrowseDet:nAt,03]}}

	oScroll2Det:= TScrollBox():New(oDlgDet,(aObjSize[1,3]*0.20)+05,(aObjSize[1,4]*0.2)+10,aObjSize[1,3]*0.72,aObjSize[1,4]*0.485,.T.,.T.,.T.)
	oSay2Det := TSay():New( aObjSize[1,1]+05, aObjSize[1,1]+05,  ,oScroll2Det,,,,,,.T.,,, aObjSize[1,1]+550, aObjSize[1,1]+nLen) //Log da Formula
	oSay2Det:oFont:= oFont

	// ativa diálogo centralizado
	ACTIVATE MSDIALOG oDlgDet CENTERED

	RestArea(aArea)
Return


/*/{Protheus.doc} fGrvLogFun
//	Realiza gravação do Log do Cálculo do Funcionário.
	Cada chamada da função gera uma linha de log na tabela RFV (Memória de Cálculo do Funcionário)
	A cada cálculo é gerado um registro na tabela RVT (Cabeçalho Memória de Cálculo do Funcionário)
@author esther.viveiro
@since 06/01/2018
@version P12
@param cRoteiro	, characters	, código do Roteiro do cálculo
@param cPeriodo	, characters	, código do Período do cálculo
@param cSemana	, characters	, Número de Pagamento do período do cálculo
@param cFormula	, characters	, código de identificação da Fórmula calculada
@param aLogFun	, array			, informação do log
/*/
Function fGrvLogFun(cRoteiro, cPeriodo, cSemana, cFormula, aLogFun)
Local aArea	:= GetArea()
Local nPos	:= 0 //posicao do funcionario no aSeqLogFunc
Local nX	:= 0
Local nLen := Len(aLogFun)
Local cMemo	:= ""

DEFAULT __aSeqLogFunc 	:= {}
DEFAULT __cChaveProc	:= DtoS(date()) + time()
DEFAULT __lTemRFT 		:= ChkFile('RFT')

	If __lTemRFT .AND. nLen > 4 //considera apenas logs com informacao
		nPos := aScan(__aSeqLogFunc, { |x| x[1]+x[3] == SRA->RA_FILIAL+SRA->RA_MAT+cRoteiro })

		If nPos > 0
			__aSeqLogFunc[nPos,2] := StrZero(Val(__aSeqLogFunc[nPos,2])+1,4)
		Else
			//GRAVA TABELA PRINCIPAL
			DbSelectArea("RFT")
			RecLock("RFT",.T.)
			RFT->RFT_FILIAL	:= SRA->RA_FILIAL
			RFT->RFT_MAT	:= SRA->RA_MAT
			RFT->RFT_PROCES	:= SRA->RA_PROCES
			RFT->RFT_PERIOD	:= cPeriodo
			RFT->RFT_SEMANA	:= cSemana
			RFT->RFT_ROTEIR	:= cRoteiro
			RFT->RFT_DATA	:= stod(substr(__cChaveProc,1,8))
			RFT->RFT_HORA	:= substr(__cChaveProc,9)
			RFT->RFT_SITFUN	:= SRA->RA_SITFOLH
			RFT->RFT_USER	:= Substr(cUsuario,7,15)
			RFT->(MsUnlock())
			RFT->(DbCloseArea())

			aAdd(__aSeqLogFunc, {SRA->RA_FILIAL+SRA->RA_MAT, "0001", cRoteiro})
			nPos := Len(__aSeqLogFunc)
		EndIf

		DbSelectArea("RFV")
		For nX := 1 to nLen
			cMemo += aLogFun[nX] + CRLF
		Next nX

		RecLock("RFV",.T.)
		RFV->RFV_FILIAL	:= SRA->RA_FILIAL
		RFV->RFV_MAT	:= SRA->RA_MAT
		RFV->RFV_PROCES	:= SRA->RA_PROCES
		RFV->RFV_PERIOD	:= cPeriodo
		RFV->RFV_SEMANA	:= cSemana
		RFV->RFV_ROTEIR	:= cRoteiro
		RFV->RFV_SEQUEN	:= __aSeqLogFunc[nPos,2] //necessario array para controlar a sequencia de calculo, para manter a ordenação da gravação do log
		RFV->RFV_FORMUL	:= cFormula
		RFV->RFV_LINHA	:= StrZero(1,5)
		RFV->RFV_LOG	:= cMemo
		RFV->RFV_DATA	:= stod(substr(__cChaveProc,1,8))
		RFV->RFV_HORA	:= substr(__cChaveProc,9)
		RFV->(MsUnlock())

		RFV->(DbCloseArea())
	EndIf
RestArea(aArea)
Return


/*/{Protheus.doc} fGrvLogTot
//	Realiza gravação do Log final do cálculo.
	Apresenta informações gerais do cálculo realizado.
@author esther.viveiro
@since 06/01/2018
@version P12
@param aLogTot, array, informações do Log:
aLogTot{
	[01] - filial - caracters
	[02] - processo - caracters
	[03] - periodo - caracters
	[04] - semana - caracters
	[05] - roteiro - caracters
	[06] - data inicial - date
	[07] - hora inicial - caracters, 99:99:99
	[08] - data final - date
	[09] - hora final - caracters, 99:99:99
	[10] - total processados - numeric
	[11] - total calculados - numeric
	[12] - total nao calculados - numeric
	[13] - log{} - array
}
/*/
Function fGrvLogTot(aLogTot)
Local cMemo	:= ""
Local nX	:= 0

DEFAULT __lTemRFT 		:= ChkFile('RFT')

//IRA FAZER A GRAVAÇÃO DOS CAMPOS NA RFW. SERÁ CHAMADA AO FIM DE CADA CALCULO DE ROTEIRO.
//IRA GRAVAR AS INFORMAÇOES JÁ EXISTENTES NO LOG ATUAL.
If __lTemRFT
//Gravar os campos na tabela RFW
	For nX := 1 to Len(aLogTot[1,14])
		//trata linhas do Log
		cMemo += aLogTot[1,14,nX] + chr(13)+chr(10)
	Next nX

	DbSelectArea("RFW")
	RecLock("RFW",.T.)
	RFW->RFW_FILIAL	:= xFilial("RCH", aLogTot[1,1])
	RFW->RFW_PROCES	:= aLogTot[1,02]
	RFW->RFW_PERIOD	:= aLogTot[1,03]
	RFW->RFW_SEMANA	:= aLogTot[1,04]
	RFW->RFW_ROTEIR	:= aLogTot[1,05]
	RFW->RFW_DTINI	:= aLogTot[1,06]
	RFW->RFW_HRINI	:= aLogTot[1,07]
	RFW->RFW_DTFIM	:= aLogTot[1,08]
	RFW->RFW_HRFIM	:= aLogTot[1,09]
	RFW->RFW_TEMPO	:= aLogTot[1,10]
	RFW->RFW_TOTPRC	:= aLogTot[1,11]
	RFW->RFW_TOTCAL	:= aLogTot[1,12]
	RFW->RFW_TOTNC	:= aLogTot[1,13]
	RFW->RFW_LOG	:= cMemo
	RFW->RFW_USER	:= Substr(cUsuario,7,15)
	RFW->(DbCloseArea())
EndIf
Return


/*/{Protheus.doc} fAddMemLog
//Adiciona registros no MNEMONICO aMenLog desde que esteja ativado o Mnemonico P_LMEMCALC
@author flavio.scorrea
@since 06/01/2018
@version P12
@param cMsg, characters, Mensagem a ser gravada
@param nTipo, numeric, Tipo de Log 1=Funcionario;2=Parametros do sistema
@param nNivel, numeric, Nivel de identação do Log
/*/
Function fAddMemLog(cMsg,nTipo,nNivel)
Local nI		:= 1
Local nFator	:= 3

DEFAULT nTipo 		:= 1
DEFAULT nNivel 		:= 0
DEFAULT __lTemRFT 	:= ChkFile('RFT')

If !__lTemRFT
	Return .T.
EndIf

If nNivel > 0
	nNivel--
EndIf

If Type("P_LMEMCALC") <> "U" .And. P_LMEMCALC
	If nTipo == 1
		If nNivel == 0
			AADD(aMenLog,"")
		EndIf
		AADD(aMenLog,space(nNivel*nFator)+cMsg)
	ElseIf nTipo == 2
		If Type("__aMVLog") <> "U" .And. Len(__aMVLog) > 0
			AADD(aMenLog, OemToAnsi(STR0020)) //"Parâmetros utilizados no cálculo :"
			For nI := 1 to Len(__aMVLog)
				AADD(aMenLog,__aMVLog[nI][1] + " : " + __aMVLog[nI][2])
			Next nI
		EndIf
	EndIf
EndIf
Return .T.


/*/{Protheus.doc} fMemCalc
//Verifica se executa memoria de calculo
@author flavio.scorrea
@since 06/01/2018
@version P12
/*/
Function fMemCalc()
Local aArea := GetArea()
Local lRet	:= .F.

DEFAULT __lTemRFT := ChkFile('RFT')

If !__lTemRFT
	Return .F.
EndIf

If Type("P_LMEMCALC") == "U"
	RstMnemonicos()
	SetMnemonicos(xFilial("RCA"),NIL,.T.,"P_LMEMCALC")
EndIf

lRet := Type("P_LMEMCALC") <> "U" .And. P_LMEMCALC

RestArea(aArea)

Return lRet

/*/{Protheus.doc} fSetMemCalc
//Inicializa staticas do calculo
@author flavio.scorrea
@since 06/01/2018
@version P12
/*/
Function fSetMemCalc(dDtInicio,cTimeInicio)

DEFAULT dDtInicio   := date()
DEFAULT cTimeInicio := Time()

__aSeqLogFunc := {}
__cChaveProc	:= dtos(dDtInicio) + cTimeInicio

Return


/*/{Protheus.doc} fDelLog
//Realiza a deleção dos registros de log nas tabelas RFT,RFV,RFW.
Será sempre deletados os registros referentes a 2 períodos anteriores ao período em fechamento, mantendo assim apenas 3 períodos disponíveis para consulta: 2 fechados + 1 em aberto.
@author esther.viveiro
@since 15/01/2018
@version P12
@param cFilLog, caracters, Filial do Periodo Fechado
@param cProcLog, caracters, Processo do Periodo Fechado
@param cPerLog, caracters, Periodo Fechado
@param cSemLog, caracters, Semana do Periodo Fechado
@param cRotLog, caracters, Roteiro do Periodo Fechado
/*/
Function fDelLog(cFilLog,cProcLog, cPerLog, cSemLog, cRotLog)
Local cQuery	:= ""
Local cAliasRFT := ""
Local cAliasRFV := ""
Local cAliasRFW := ""

DEFAULT __lTemRFT 	:= ChkFile('RFT')

If __lTemRFT

	cAliasRFT := InitSqlName("RFT")
	cAliasRFV := InitSqlName("RFV")
	cAliasRFW := InitSqlName("RFW")

	cMes := Substr(cPerLog,5,2)
	cAno := Substr(cPerLog,1,4)
	If cMes == "01"
		cMes := "11"
		cAno := cValToChar(Val(cAno) - 1)
	ElseIf cMes == "02"
		cMes := "12"
		cAno := cValToChar(Val(cAno) - 1)
	Else
		cMes := StrZero(Val(cMes) - 2,2)
	EndIf
	cPerLog := cAno + cMes

	//Apaga log funcionário - RFV
	cQuery := "DELETE FROM " + cAliasRFV + " "
	cQuery += "WHERE RFV_FILIAL  LIKE '" + RTrim(cFilLog) + "%'"
	cQuery += "  AND RFV_PROCES  = '" + cProcLog + "'"
	cQuery += "  AND RFV_PERIOD <= '" + cPerLog  + "'"
	cQuery += "  AND RFV_SEMANA  = '" + cSemLog  + "'"
	cQuery += "  AND RFV_ROTEIR  = '" + cRotLog  + "'"
	TcSqlExec(cQuery)
	TcRefresh(cAliasRFW)

	//Apaga cabeçalho log - RFT
	cQuery := "DELETE FROM " + cAliasRFT + " "
	cQuery += "WHERE RFT_FILIAL  LIKE '" + RTrim(cFilLog) + "%'"
	cQuery += "  AND RFT_PROCES  = '" + cProcLog + "'"
	cQuery += "  AND RFT_PERIOD <= '" + cPerLog  + "'"
	cQuery += "  AND RFT_SEMANA  = '" + cSemLog  + "'"
	cQuery += "  AND RFT_ROTEIR  = '" + cRotLog  + "'"
	TcSqlExec(cQuery)
	TcRefresh(cAliasRFW)

/* A SER IMPLEMENTADO MAIS PRA FRENTE
	//Apaga log periodo - RFW
	cQuery := "DELETE FROM " + cAliasRFW + " "
	cQuery += "WHERE RFW_FILIAL  = '" + cFilLog + "'"
	cQuery += "  AND RFW_PROCES  = '" + cProcLog + "'"
	cQuery += "  AND RFW_PERIOD <= '" + cPerLog  + "'"
	cQuery += "  AND RFW_SEMANA  = '" + cSemLog  + "'"
	cQuery += "  AND RFW_ROTEIR  = '" + cRotLog  + "'"
	TcSqlExec(cQuery)
	TcRefresh(cAliasRFW)
*/
	EndIf
Return
