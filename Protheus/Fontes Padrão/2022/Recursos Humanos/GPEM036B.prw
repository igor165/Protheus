#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio:= "2.4"

Static __oSt05_1	 	//Query para filtrar as verbas de folha que foram pagas de funcionários ativos
Static __oSt05_2	 	//Query para filtrar as verbas de folha que foram pagas de funcionários demitidos
Static __oSt06		 	//Query para filtrar roteiro 132 anterior a dezembro
Static __oSt09		 	//Query para filtrar as verbas calculadas no dissídio
Static __oSt10		 	//Query para verificar os lançamentos de múltiplos vínculos
Static __oSt11		 	//Query para verificar se houve cálculo de férias com pagamento no período
Static __oSt12		 	//Query para filtrar as verbas de férias calculadas com pagamento no período
Static __oSt13		 	//Query para filtrar os registros da C9V do CPF que está em processamento
Static __oSt17_1	 	//Query para verificar quantidade de matriculas no periodo
Static __oSt17_2	 	//Query para verificar quantidade de matriculas no periodo filtrando por data de pagamento
Static __oSt18		 	//Query para verificar férias pagas em período anterior, de matrículas transferidas
Static __oSt19		 	//Query para verificar registros destino da SRH/SRR de matrículas transferidas
Static aTabS073		:= {}	//Tabela S073
Static oHash
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .And. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM036B
@Author   Alessandro Santos
@Since    18/03/2019
@Version  1.0
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1211
/*/
Function GPEM036B()
Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fNew1210()     ³Autor³  Marcia Moura     ³ Data ³02/06/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gera o registro de Folha / Pagamentos                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM034                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Nil															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nil															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

Function fNew1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, aLogsErr, aLogsPrc, lRelat)

Local lRet 		:= .T.
Local aAreaSM0	:= SM0->(GetArea())

Private lRobo	:= IsBlind()

If lRobo
	Processa({|lEnd| lRet := NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, .F., aLogsErr, aLogsPrc, lRelat)})
Else
	Proc2BarGauge({|lEnd| lRet := NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, .T., aLogsErr, aLogsPrc, lRelat)}, "Evento S-1210", NIL , NIL , .T. , .T. , .F. , .F. )
EndIf

__oSt05_1 	:= Nil
__oSt05_2 	:= Nil
__oSt06 	:= Nil
__oSt09 	:= Nil
__oSt10 	:= Nil
__oSt11 	:= Nil
__oSt12 	:= Nil
__oSt13 	:= Nil
__oSt17_1 	:= Nil
__oSt17_2 	:= Nil
__oSt18 	:= Nil
__oSt19 	:= Nil
aTabS073 	:= Nil
If ValType(oHash) == "O"
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil
EndIf

RestArea(aAreaSM0)

Return lRet

/*/{Protheus.doc} NewProc1210
Processamento das rubricas de IRRF com data de pagamento dentro da competência selecionada
@author Allyson
@since 19/06/2018
@version 2.0
@param cCompete 	- Competência da geração do evento
@param cPerIni 		- Período inicial da geração do evento
@param cPerFim 		- Período final da geração do evento
@param aArrayFil 	- Filiais selecionadas para processamento
@param lRetific 	- Indica se é retificação
@param lIndic13 	- Indica se é referente a 13º salário
@param aLogsOk 		- Log de ocorrências do processamento
@param cOpcTab 		- Indica se o período em aberto será considerado (0=Não|1=Sim)
@param aCheck 		- Checkbox da tela de geração dos períodicos
@param cCPFDe 		- CPF inicial para filtro
@param cCPFAte 		- CPF final para filtro
@param lExcLote		- Indicativo de exclusão em lote
@param cExpFiltro	- Expressão de filtro na tabela SRA
@param lNewProgres	- Indicativo de execução do robô
@param aLogsErr 	- Log de ocorrências de erro do processamento
@param aLogsProc 	- Log de ocorrências do resumo do processamento
@param lRelat 		- Indica se é geração do relatório em Excel

@return NIL

/*/
Static Function NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lNewProgres, aLogsErr, aLogsPrc, lRelat)

Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aBkpFer		:= {}
Local aContdmDev	:= {}
Local aCpfDesp		:= {}
Local aFilInTaf		:= {}
Local aFilInAux 	:= {}
Local aRotADI		:= fGetRotTipo("2")
Local aRotFOL		:= fGetRotTipo("1")
Local aTabIR		:= {}
Local aTabIRRF		:= {}
Local aVbFer		:= {}
Local aStatT3P		:= {}
Local aFilInativ	:= {}

Local cFilInativ	:= ""
Local cAliasQSRA	:= "SRAQRY"
Local cAliasQC		:= "SRACON"
Local cAliasQMV		:= "SRAQMV"
Local cAliasSRA		:= "SRA"
Local cAliasSRX		:= GetNextAlias()
Local cAno			:= substr(cCompete,3,4)
Local cBkpFil		:= cFilAnt
Local cBkpFilEnv	:= ""
Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
Local cCPF			:= ""
Local cCpfOld		:= ""
Local cDtIni		:= ""
Local cDtFim		:= ""
Local cDtGerRes		:= ""
Local cDtPesqI		:= substr(cCompete,3,4)+ substr(cCompete,1,2)+"01"
Local cDtPesqF		:= substr(cCompete,3,4)+ substr(cCompete,1,2)+"31"
Local cFilEnv		:= ""
Local cFilProc		:= ""
Local cFilPreTrf	:= ""
Local cFilx			:= ""
Local cideDmDev		:= ""
Local cIdeRubr		:= ""
Local cIdTbRub		:= ''
Local cJoinRCxRY	:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY	:= FWJoinFilial( "SRD", "SRY" )
Local cLastRot		:= ""
Local cLstCPF		:= ''
Local cMes			:= substr(cCompete,1,2)
Local cMsgErro		:= ""
Local cNome			:= ""
Local cNomeTCPF		:= ""
Local cNomeTEmp		:= ""
Local cOldFil		:= ""
Local cOldFilEnv	:= ""
Local cOldOcorr		:= ""
Local cPD			:= ""
Local cPdCod0021	:= ""
Local cPdCod546		:= ""
Local cPdCod0151	:= ""
Local cPDLiq		:= ""
Local cPer			:= ""
Local cPer1210		:= SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)
Local cPer132		:= ""
Local cPeriodo		:= ""
Local cPerOld		:= ""
Local cPerOld1		:= ""
Local cPerRes		:= ""
Local cQuery		:= ""
Local cQueryCont	:= ""
Local cQueryMV		:= ""
Local cRecResc		:= ""
Local cRoteiro		:= ""
Local cSemRes		:= ""
Local cSRHFil		:= ""
Local cSRHMat		:= ""
Local cSRHCodUni	:= ""
Local cStat1		:= ''
Local cStatT3P		:= "-1"
Local cTpPgto		:= "1"
Local cTpRes		:= ""
Local cTpRot		:= ""
Local cRecibo		:= ""
Local cTSV			:= fCatTrabEFD("TSV")
Local cXml			:= ""
Local cSitFolh		:= ""
Local cEmp			:= ""
Local cEmpOld		:= ""
Local cTafKey		:= ""
Local cTpFolha		:= IIF(lIndic13, "2", "1")
Local cUltTpRes		:= ""

Local dDcgIni		:= SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )
Local dDtPgt		:= DDATABASE
Local dDtRes		:= cToD("//")
Local dDtPgtRR		:= cToD("//")

Local lAchou063		:= .F.
Local lAfast		:= .F.
Local lFilAux		:= .F.
Local lGeraCod		:= .F.
Local lRes			:= .F.
Local lRetXml		:= .F.
Local lTem132		:= .F.
Local lTSV			:= .F.
Local lPgtRes		:= .T.
Local lPrimIdT		:= .T.
Local lResidExt		:= .F.
Local lResComPLR	:= .F.
Local lResOriCom	:= .F.
Local lDtPgto		:= .F.

Local nVldOpcoes	:= 0
Local nCntFer		:= 0
Local nCont			:= 0
Local nContRot		:= 0
Local nI			:= 0
Local nPdetPGtoAt	:= 0
Local nPdetPGtoFl	:= 0
Local nPosEmp		:= 0
Local nQtdeFolMV	:= 0
Local nValor		:= 0
Local nVlrDep		:= 0
Local nX			:= 0
Local nx1			:= 0
Local nHrInicio
Local nHrFim

Local aEmp_1210		:= {0, 0, 0, 0} //1 - Integrados TCV; 2 - Nao Integrados TCV; 3 - Integrados TSV; 4 - Nao Integrados TSV
Local aRGE1210 		:= {}
Local aResCompl		:= {}

Local nContRes		:= 0
Local dlastDate		:= cToD("")
Local lGera546		:= .T.
Local lVer546		:= .T.
Local aCodHash		:= {}
Local cCodFol
Local cTipoCod
Local cCodINCIRF
Local cCodAdiant
Local cCodFil

Local lAdmPubl	 	:= .F.
Local aInfoC	 	:= {}
Local aDados	 	:= {}
Local aErros	 	:= {}
Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cChaveMid	 	:= ""
Local cStatNew		:= ""
Local cOperNew		:= ""
Local cRetfNew		:= ""
Local cRecibAnt		:= ""
Local cKeyMid		:= ""
Local cIdXml		:= ""
Local lNovoRJE		:= .T.
Local nRecEvt		:= 0
Local cVersMw		:= ""
Local nTotRec		:= 0
Local cTimeIni		:= Time()
Local aArrayFil2	:= {}
Local nZ			:= 0
Local nW			:= 0
Local cFilTransf	:= ""
Local dDtPgto		:= cToD("//")
Local cKeyProc		:= ""
Local cTrabSemVinc  := "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
Local lTemMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local lGeraMat		:= .F.
Local lResTSV		:= .F.
Local l3GRescMes	:= .F.
Local nQtdMesAnt	:= 1
Local lTercGrp		:= .F.
Local lPesFisica	:= .F.
Local cVerbas		:= ""
Local cStatC91		:= "-1"
Local aStatC91		:= {}
Local cNumFer		:= ""
Local cBkpDtFer		:= ""
Local nNumFer		:= 0
Local lOrig1202		:= ( ChkFile("T61") .And. T61->(ColumnPos("T61_ORGSUC")) > 0 ) .And. ( ChkFile("V6V") .And. V6V->(ColumnPos("V6V_TPINSC")) > 0 )
Local lOrig1207		:= SuperGetMv("MV_OPESOC", Nil, .F.) .And. SRC->(ColumnPos("RC_NRBEN")) > 0 .And. ( ChkFile("T61") .And. T61->(ColumnPos("T61_ORGSUC")) > 0 ) .And. ( ChkFile("V6V") .And. V6V->(ColumnPos("V6V_TPINSC")) > 0 )
Local lCatEst		:= .F.
Local aDmDevBop		:= {}
Local nDm			:= 0
Local lTemNrBen		:= SRD->(ColumnPos("RD_NRBEN")) > 0 .And. SRC->(ColumnPos("RC_NRBEN")) > 0
Local nRetFer       := 1
Local cFilVal       := ""
Local lAchouSRG		:= .F.
Local lCodCorr		:= .F.

Private aCodFol		:= {}
Private aCodBenef	:= {}
Private aDetPgtoFl	:= {}
Private aideBenef	:= {}
Private aInfoPgto	:= {}
Private aDetPgtoAt 	:= {}
Private aPgtoAnt 	:= {}
Private aRetFer		:= {}
Private aRetPensao	:= {}
Private aLogCIC		:= {}
Private aRetPgtoTot	:= {}
Private detPgtoFer	:= {}
Private aRelIncons	:= {}
Private aEstb		:= fGM23SM0(,.T.) //extrai lista de filiais da SM0
Private aSM0     	:= FWLoadSM0(.T.)
Private nQtdeFol	:= 1
Private lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
Private lTemGC		:= fIsCorpManage( FWGrpCompany() )
Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
Private nIniEmp 	:= At("E", cLayoutGC)
Private nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))

Private cSRACPF 	:= "QRYSRACPF"
Private cSRAEmp 	:= "QRYSRAEMP"
Private oTmpCPF		:= Nil
Private oTmpEmp		:= Nil

Default aCheck		:= {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .T.}
Default cOpcTab		:= "0"
Default cCPFDe		:= ""
Default cCPFAte		:= ""
Default cExpFiltro	:= ""
Default lNewProgres	:= .F.

Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, Nil, @cVersMw ), .T.)

lAfast	:= aCheck[13]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Carrega Tabela de IRRF                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTabIR 	 := {}
aTabIRRF := {}
fCarrTab( @aTabIRRF, "S002",  )
For nX := 1 To Len(aTabIRRF)
	If aTabIRRF[nX][1] == "S002"
		If aTabIRRF[nX][5] <= cAno+cMes .And. aTabIRRF[nX][6] >= cAno+cMes
			aAdd(aTabIR, aTabIRRF[nX][20])
		EndIf
	EndIf
Next nX

If !lMiddleware
	fGp23Cons(@aFilInTaf, aArrayFil, @cFilEnv, @aFilInativ)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	If Empty(aFilInTaf)
		MsgAlert( STR0065 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do TAF para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
		Return .F.
	EndIf

	If LEN(aFilInativ) > 0

		FOR nI := 1 TO LEN(aFilInativ)
			cFilInativ += aFilInativ[nI] + ", "
		NEXT nI

		MsgAlert( "A(s) filial(is) " + cFilInativ + STR0072)
		Return .F.
	EndIf
EndIf

If !Empty(cFilEnv)
	lPesFisica	:= fGM36PFisica(cFilEnv)
Endif
//Hora Inicial
nHrInicio := Seconds()

If lAglut
	If !lMiddleware
		For nI := 1 To Len(aFilInTaf)
			For nX := 1 to len(aFilInTaf[nI,3])
				cFilProc += aFilInTaf[nI,3,nX]
			Next
		Next nI  //
	Else
		For nI := 1 To Len(aArrayFil)
			cFilProc += aArrayFil[nI]
		Next nI
	EndIf
	cFilProc := fSQLIn(cFilProc, FwSizeFilial())
EndIf

aStru := SRD->(dbStruct())

If !Fp_CodFol(@aCodFol, xFilial('SRV'))
	Return(.F.)
EndIf

cVerbas :="'" + ACODFOL[44,1] + "','" + ACODFOL[106,1] + "','" + ACODFOL[107,1] + "'"

oHash := HMNew()
HMSet( oHash,xFilial('SRV'),aClone(aCodFol) )

//Grava quais são as raízes de CNPJ's selecionadas para processamento
If lAglut .And. !Empty(aArrayFil)
	For nZ := 1 to Len(aArrayFil)
		If (nW := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + aArrayFil[nZ] } )) > 0
			aAdd(aArrayFil2, {aSM0[nW, 1], aSM0[nW, 2], SubStr(aSM0[nW, 18], 1, 8)})
		EndIf
	Next nZ
EndIf

For nI := 1 To Len(aArrayFil)
	//Quando aglutina, somente executa o For uma vez pois processa todas as filiais de uma vez
	If lAglut .And. nI > 1
		Exit
	EndIf
	If !lAglut
		If !lMiddleware
			cFilProc := StrTran(fGM23Fil(aFilInTaf, nI)[1], "%", "")
		Else
			cFilProc := "'" + aArrayFil[nI] + "'"
		EndIf
	EndIf
	If Select( cAliasQSRA ) > 0
		(cAliasQSRA)->( dbCloseArea() )
	EndIf

	//Query para filtrar os CPFs de acordo com o filtro da rotina
	fQryCPF(cFilProc, aFilInTaf, nI, cCPFDe, cCPFAte, cExpFiltro, .F., cPer1210, aArrayFil )
	cNomeTCPF := oTmpCPF:GetRealName()

	If lAglut
		//Query para filtrar os CNPJs de acordo com o filtro da rotina
		fQryEmp()
		cNomeTEmp := oTmpEmp:GetRealName()
	EndIf

	//Query para filtrar as matriculas que possuem cálculo da folha de acordo com os CPFs filtrados
	cQuery := "SELECT SRA.RA_CIC, SRA.RA_FILIAL RC_FILIAL, SRA.RA_MAT RC_MAT, SRA.RA_PIS, SRA.RA_NOMECMP, SRA.RA_OCORREN, SRA.RA_NOME, SRA.RA_CATEFD, "
	cQuery += "SRA.RA_SINDICA, SRA.RA_CODUNIC, SRA.RA_DEPIR, SRA.RA_PROCES, SRA.RA_ADMISSA, SRA.RA_RESEXT, SRA.RA_CODRET, SRA.RA_DEMISSA, SRA.RA_TPPREVI, SRA.RA_CATFUNC, SRA.RA_EAPOSEN, SRA.R_E_C_N_O_ AS RECNO "
	If lOrig1207
		cQuery += ", RA_DTENTRA "
	EndIf
	If lAglut
		cQuery += ", EMP.CNPJ as CNPJ "
	EndIf
	cQuery += "FROM " + RetSqlName('SRA') + " SRA "
	If lAglut
		cQuery += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
		cQuery += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
	Else
		cQuery += "WHERE SRA.RA_FILIAL IN (" + cFilProc + ") "
		cQuery += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
	EndIf
	cQuery += "AND SRA.RA_CC <> ' ' "
	If !lExcLote
		cQuery += "AND EXISTS ("
		If cOpcTab == "1"
			cQuery += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQuery += "UNION "
		EndIf
		cQuery += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
		cQuery += "UNION "
		cQuery += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
	EndIf
	cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
	If !lAglut
		cQuery += "ORDER BY SRA.RA_CIC, SRA.RA_FILIAL, SRA.RA_MAT"
	Else
		cQuery += "ORDER BY SRA.RA_CIC, CNPJ"
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQSRA,.T.,.T.)

	If !lRobo
		//Query para filtrar as matriculas que possuem cálculo da folha de acordo com os CPFs filtrados
		cQueryCont := "SELECT COUNT(*) AS TOTAL "
		cQueryCont += "FROM " + RetSqlName('SRA') + " SRA "
		If lAglut
			cQueryCont += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
			cQueryCont += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		Else
			cQueryCont += "WHERE SRA.RA_FILIAL IN (" + cFilProc + ") "
			cQueryCont += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		EndIf
		cQueryCont += "AND SRA.RA_CC <> ' ' "
		If !lExcLote
			cQueryCont += "AND EXISTS ("
			If cOpcTab == "1"
				cQueryCont += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
				cQueryCont += "UNION "
			EndIf
			cQueryCont += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQueryCont += "UNION "
			cQueryCont += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
		EndIf
		cQueryCont += "AND SRA.D_E_L_E_T_ = ' ' "
		cQueryCont := ChangeQuery(cQueryCont)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCont),cAliasQC,.T.,.T.)

		If (cAliasQC)->( !EoF() )
			nTotRec := (cAliasQC)->TOTAL
			If !lNewProgres
				GPProcRegua(nTotRec)
			Else
				BarGauge1Set(nTotRec)
			EndIf
		EndIf
		(cAliasQC)->( dbCloseArea() )
	EndIf

	If lAglut
		//Query para verificar quantas matriculas de um mesmo CPF possuem cálculo da folha de acordo com os CPFs filtrados
		cQueryMV := "SELECT SRA.RA_CIC, "
		cQueryMV += "EMP.CNPJ as CNPJ, "
		cQueryMV += " COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
		cQueryMV += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
		cQueryMV += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		cQueryMV += "AND SRA.RA_CC <> ' ' "
		If !lExcLote
			cQueryMV += "AND EXISTS ("
			If cOpcTab == "1"
				cQueryMV += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
				cQueryMV += "UNION "
			EndIf
			cQueryMV += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQueryMV += "UNION "
			cQueryMV += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
		EndIf

		cQueryMV += "AND SRA.D_E_L_E_T_ = ' ' "
		cQueryMV += "GROUP BY SRA.RA_CIC, CNPJ "
		cQueryMV += "ORDER BY SRA.RA_CIC, CNPJ"
		cQueryMV := ChangeQuery(cQueryMV)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryMV),cAliasQMV,.T.,.T.)
		nQtdeFol := (cAliasQMV)->CONT
	EndIf

	While (cAliasQSRA)->(!EOF())
		(cAliasSRA) ->( dbGoTo( (cAliasQSRA)->RECNO ) )
		lTercGrp := .F.
		//Identifica se o funcionário é residente no exterior
		lResidExt := If( cVersEnvio >= "9.1", ( cPer1210 >= "202303" .And. (cAliasSRA)->RA_CODRET == "0473" ), .F. )
		aRGE1210 := {}


		If cVersEnvio < "9.0.00" .And. Empty((cAliasQSRA)->RA_PIS) .And. !((cAliasQSRA)->RA_CATEFD $ ("901*903*904"))
			aAdd(aLogsErr, Alltrim((cAliasQSRA)->RA_CIC) +"-" + Alltrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0214) ) //" Funcionário sem PIS cadastrado - Campo Obrigatório"
			aAdd(aLogsErr, "" )
			(cAliasQSRA)->(DBSkip())
			Loop
		EndIf
		cTpPgto := "1"
		If cVersEnvio >= "9.0.00"
			If lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
				cTpPgto := "5"
			ElseIf lOrig1202
		   		lCatEst := fTpPgtoEst((cAliasQSRA)->RA_TPPREVI, (cAliasQSRA)->RA_CATEFD, cCompete,cTpFolha)
				If lCatEst
					cTpPgto := "4"
				Endif
			EndIf
		Endif


		If Empty(cEmp)
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
				cEmpOld := cEmp
			EndIf
		EndIf

		If	lAglut .And. ((cAliasQSRA)->RA_CIC != (cAliasQMV)->RA_CIC .OR.;
			((cAliasQSRA)->RA_CIC == (cAliasQMV)->RA_CIC .AND. cEmp != cEmpOld)) //Se o CPF for o mesmo, porém, a empresa é diferente
			(cAliasQMV)->( dbSkip() )
			nQtdeFol := (cAliasQMV)->CONT
		EndIf

		cSRHFil		:= cFilPreTrf := (cAliasSRA)->RA_FILIAL
		cSRHMat		:= (cAliasSRA)->RA_MAT
		cSRHCodUni	:= Iif((cAliasSRA)->RA_CATEFD $ cTrabSemVinc, "", (cAliasSRA)->RA_CODUNIC)

		If fFerPreTrf(@cSRHFil, @cSRHMat, cDtPesqF )
			(cAliasQSRA)->( dbSkip() )
			Loop
		EndIf

		cFilAnt := (cAliasSRA)->RA_FILIAL
		If lMiddleware
			fPosFil( cEmpAnt, cFilAnt )
		EndIf

		If !lIntTAF .And. (lMiddleware .And. Empty(fXMLInfos()))
			(cAliasQSRA)->( dbSkip() )
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
			EndIf
			Loop
		EndIf

		//Verifica filial centralizadora do envio
		If cOldFilEnv != cFilAnt
			cOldFilEnv := cFilAnt
			If !lExcLote
				RstaCodFol()
				aCodHash := {}
				If HMGet(oHash,xFilial('SRV', (cAliasSRA)->RA_FILIAL),@aCodHash)
					aCodFol := aCodHash
				Else
					If !Fp_CodFol(@aCodFol, xFilial('SRV', (cAliasSRA)->RA_FILIAL))
						Return(.F.)
					EndIf
					HMSet( oHash,xFilial('SRV', (cAliasSRA)->RA_FILIAL),aClone(aCodFol) )
				EndIf
				cPdCod0021 	:= aCodFol[21,1]
				cPdCod546	:= aCodFol[546,1]
				cPdCod0151	:= aCodFol[151,1]
			Endif
			If !lMiddleware
				lFilAux		:= .F.
				For nX := 1 To Len(aFilInTaf)
					If aScan( aFilInTaf[nX, 3], { |x| x == cFilAnt } ) > 0
						cFilEnv := aFilInTaf[nX, 2]
						lFilAux	:= .T.
						Exit
					EndIf
				Next nX
				If !lFilAux
					fGp23Cons(aFilInAux, {cFilAnt})
					For nX := 1 To Len(aFilInAux)
						If aScan( aFilInAux[nX, 3], { |x| x == cFilAnt } ) > 0
							cFilEnv := aFilInAux[nX, 2]
							Exit
						EndIf
					Next nX
				EndIf
			Else
				cFilEnv := cFilAnt
			EndIf
		EndIf

		//Se P_ESOCMV for .T., relacionamento 1 x 1 e (raiz do CNPJ do funcionário com múltiplo vínculo não estiver selecionada ou
		//Funcionário não tem múltiplo vínculo no período e filial não está seleciona) pula para o próximo registro
		If lAglut .And. cFilEnv == (cAliasQSRA)->RC_FILIAL .And. (( nW := aScan(aArrayFil2, {|x| x[3] == cEmp }) ) == 0 .Or.;
		( nW := aScan(aArrayFil2, {|x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL })) == 0) .And. (cAliasQMV)->CONT == 1 .And.;
		(cAliasQMV)->RA_CIC == (cAliasQSRA)->RA_CIC .And. (cAliasQMV)->CNPJ == cEmp
			(cAliasQSRA)->( dbSkip() )
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
				cEmpOld := cEmp
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
			EndIf
			Loop
		EndIf

		If !lRobo
			If !lNewProgres
				GPIncProc( "CPF: " + Transform((cAliasSRA)->RA_CIC, "@R 999.999.999-99") + " | Funcionário: " + (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT )
			Else
				IncPrcG1Time("CPF: " + Transform((cAliasSRA)->RA_CIC, "@R 999.999.999-99") + " | Funcionário: " + (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT, nTotRec, cTimeIni, .T., 1, 1, .T.)
			EndIf
		EndIf

		aResCompl	:= {}
		lDtPgto		:= .F.
		lResComPLR  := .F.
		cCPF    	:= (cAliasSRA)->RA_CIC
		cFil   		:= (cAliasSRA)->RA_FILIAL
		cMat   		:= (cAliasSRA)->RA_MAT
		cProcAtu    := (cAliasSRA)->RA_PROCES
		cMes   		:= Left(cCompete,2)
		cAno   		:= Right(cCompete,4)
		cCat 		:= (cAliasSRA)->RA_CATEFD
		cSitFolh	:= (cAliasSRA)->RA_SITFOLH
		cPerRes		:= ""
		cSemRes		:= ""
		dDtRes		:= cToD("//")
		cTpRes		:= ""
		cUltTpRes	:= ""
		cDtGerRes	:= ""
		cRecResc	:= ""
		lResTSV		:= .F.
		lRes 		:= fGetRes(cFil, cMat, cCompete, @dDtRes, Nil, @cTpRes, @cPerRes, @aResCompl, @cSemRes, @cRecResc, cTSV, @lResComPLR, cVersEnvio, @lResTSV )
		cStat1		:= ""
		lPgtRes		:= .T.
		lTem132	 	:= .F.
		nContRes 	:= 0
		dlastDate	:= cToD("//")
		cLastRot	:= ""
		cPerOld		:= ""
		cPerOld1	:= ""
		nQtdeFolMV	:= 0
		lGera546	:= .T.
		lVer546		:= .T.
		lResOriCom	:= .F.
		cFilTransf	:= fFilTransf(cMat, cPer1210)
		l3GRescMes	:= .F.
		aBkpFer		:= {}

		//Define se o recibo será gerado usando a data de pagamento da verba quando há mais de uma rescisão complementar.
		lDtPgto := (lResComPLR .And. Len(aResCompl) > 1 .And. !(aScan(aResCompl, { |x| x[1] <> "1" } ) > 0))

		If lMiddleware
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If Len(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
				cIdXml   := aInfoC[3]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
		EndIf

		If cVersEnvio >= "9.0" .And. lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
			cStat1  := TAFGetStat( "S-2400", AllTrim((cAliasSRA)->(RA_CIC)) )
			lTSV 	:= cCat $ cTSV
		ElseIf cCat $ cTSV
			If !( cCat $ cCatTSV )
				If cVersEnvio >= "9.0" .And. lTemMat //controle chave 2300
					lGeraMat := ( SRA->RA_DESCEP == "1" )
				EndIf
				If !lMiddleware
					If cVersEnvio >= "9.0"
						cLstCPF := AllTrim( SRA->RA_CIC ) + ";" + If(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					Else
						cLstCPF := AllTrim( (cAliasSRA)->(RA_CIC) ) + ";" + AllTrim( (cAliasSRA)->(RA_CATEFD) ) + ";" + AllTrim( dToS((cAliasSRA)->(RA_ADMISSA)) )
					EndIf
					cStat1  := TAFGetStat( "S-2300", cLstCPF )
				Else
					cLstCPF := If( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cLstCPF, 40, " ")
					cStat1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStat1 )
				EndIf
			EndIf
			lTSV := .T.
		Else
			If !lMiddleware
				cLstCPF := AllTrim((cAliasSRA)->(RA_CIC)) + ";" + Iif(lMiddleware,Alltrim((cAliasSRA)->(RA_CODUNIC)),SRA->RA_CODUNIC)
				cStat1  := TAFGetStat( "S-2200", cLstCPF )
			Else
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStat1 		:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStat1 )
			EndIf
			lTSV := .F.
		Endif
		If cStat1 == "-1"
			If !(cSitFolh == "D" .And. !lRes) .And. aScan(aLogsErr, {|X| "Funcionário("+(cAliasSRA)->RA_CIC+")" $ X}) == 0
				If !lMiddleware
					aAdd(aLogsErr,"[FALHA] Não foi possivel encontrar o registro do Funcionário ("+(cAliasSRA)->RA_CIC+")-"+Alltrim((cAliasSRA)->RA_NOME)+ " no TAF.") //##" ao integrar funcionario "
				Else
					aAdd(aLogsErr,"[FALHA] Não foi possivel encontrar o registro do Funcionário ("+(cAliasSRA)->RA_CIC+")-"+Alltrim((cAliasSRA)->RA_NOME)+ " no Middleware.") //##" ao integrar funcionario "
				EndIf
				aAdd(aLogsErr, "" )
			EndIf

			If lTSV
				aEmp_1210[4]++ //Inclui TSV nao integrado
			Else
				aEmp_1210[2]++ //Inclui TCV nao integrado
			EndIf

			If lRelat
				aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0206) } )//"Não foi possivel encontrar o registro do Funcionário"
			EndIf

			(cAliasQSRA)->(DBSkip())
			Loop
		EndIf

		If !lAglut .Or. nQtdeFol == 1 .Or. SRA->RA_CIC != cCpfOld .Or. cEmp != cEmpOld
			cStatNew := ""
			cOperNew := ""
			cRetfNew := ""
			cRecibAnt:= ""
			cKeyMid	 := ""
			nRecEvt	 := 0
			lNovoRJE := .T.
			aStatT3P := fVerStat( 2, cFilEnv, cPer1210, aClone(aFilInTaf), Nil, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @cRecibAnt, @lNovoRJE, @cKeyMid, lAdmPubl, cTpInsc, cNrInsc, cVersEnvio )
			cStatT3P := aStatT3P[1]
			cRecibo  := If( cVersEnvio >= "9.0", PadR(aStatT3P[2], 23), aStatT3P[2]) //23 digitos
			aStatC91 := fVerStat( 1, cFilEnv, cPer1210, aClone(aFilInTaf), cTpFolha, , , , , , , ,lAdmPubl, cTpInsc, cNrInsc, cVersEnvio )
			cStatC91 := aStatC91[1]
		EndIf

		/*
		±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
		±±³ Exclusao em lote dos registros            ³±±
		±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
		±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
		If lExcLote
			If cStatT3P $ "4"
				cXml := ""
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aDados	 := {}
				InExc3000(@cXml,'S-1210',cRecibo,(cAliasQSRA)->RA_CIC,(cAliasQSRA)->RA_PIS,.T.,"1",cAno+"-"+cMes, (cAliasQSRA)->RA_CATEFD, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
				GrvTxtArq(alltrim(cXml), "S3000", (cAliasQSRA)->RA_CIC)
				If !lMiddleware
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
				ElseIf Empty(aErros)
					aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecibo, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
					If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
						aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
					EndIf
				EndIf
				If Len( aErros ) > 0
					cMsgErro := ''
					FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
					FormText(@cMsgErro)
					aErros[1] := cMsgErro
					aAdd(aLogsErr, OemToAnsi(STR0046) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0029) ) //"[FALHA] "##"Registro de exclusao S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
					aAdd(aLogsErr, "" )
					aAdd(aLogsErr, aErros[1] )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				Else
					If !lMiddleware
						aAdd(aLogsOk, OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0049) ) //##"Registro de exclusao S-1210 do Funcionário: "##" Integrado com TAF."
					Else
						aAdd(aLogsOk, OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0165) ) //##"Registro de exclusao S-1210 do Funcionário: "##" Integrado com TAF."
					EndIf
					aAdd(aLogsOk, "" )
					If lTSV
						aEmp_1210[3]++ //Inclui TSV integrado
					Else
						aEmp_1210[1]++ //Inclui TCV integrado
					EndIf
				Endif
			ElseIf cStatT3P $ "2"
				aAdd(aLogsErr, OemToAnsi(STR0046) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0028) ) //"[FALHA] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois está aguardando retorno do governo."
				aAdd(aLogsErr, "" )
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf cStatT3P $ "6|99"
				aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0166) ) //"[AVISO] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois há evento de exclusão pendente para transmissão."
				aAdd(aLogsErr, "" )
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf cStatT3P != "-1"
				aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0150) ) //"[AVISO] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois não foi transmitido."
				aAdd(aLogsErr, "" )
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
			Else
				aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0151) ) //"[AVISO] "##"Registro S-1210 do funcionario "##" não foi encontrado. A exclusão não poderá ser realizada."
				aAdd(aLogsErr, "" )
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
			EndIf

			(cAliasQSRA)->(DBSkip())
			Loop
		EndIf

		If !lRelat
			nVldOpcoes := fVldOpcoes(aCheck, cStatT3P)

			If nVldOpcoes == 1
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0026) ) //##"Registro S-1210 do Funcionário: "##" não foi sobrescrito."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cAliasQSRA)->(DBSkip())
				Loop
			Elseif nVldOpcoes == 2
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0027) ) //##"Registro S-1210 do Funcionário: "##" não foi retificado."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cAliasQSRA)->(DBSkip())
				Loop
			Elseif nVldOpcoes == 3
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0028) ) //##"Registro S-1210 do Funcionário: "##" desprezado pois está aguardando retorno do governo."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cAliasQSRA)->(DBSkip())
				Loop
			ElseIf cStatT3P == "99"
				aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0166) ) //##"Registro S-1210 do Funcionário: "##" desprezado pois há evento de exclusão pendente para transmissão."
				aAdd(aLogsErr, "" )
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
				(cAliasQSRA)->(DBSkip())
				Loop
			Endif
		EndIf

		If Select(cAliasSRX) > 0
			(cAliasSRX)->(dbcloseArea())
		EndIf

		If !lAglut .Or. nQtdeFol == 1 .Or. cCPF <> cCpfOld .Or. cEmp != cEmpOld
			aContdmDev	:= {}
			nVlrDep		:= 0
			cCpfOld		:= cCPF
			cNome  		:= Alltrim((cAliasSRA)->RA_NOME)
			cOldFil 	:= (cAliasSRA)->RA_FILIAL
			cOldOcorr	:= (cAliasSRA)->RA_OCORREN
			cEmpOld		:= cEmp
			If cVersEnvio < "9.0" .And. Len( aTabIR ) > 0//testa se existe dados na tabela
				If aTabIR[1] <> 0 .and. VAL((cAliasSRA)->RA_DEPIR) <> 0
					nVlrDep := VAL((cAliasSRA)->RA_DEPIR) * aTabIR[1]
				Endif
			EndIf
			cXml := ""
			If !lMiddleware
				S1210A01(@cXml)
				S1210A02(@cXml, {})
				S1210A03(@cXml, {"1",,Iif(cVersEnvio >= "9.0", Nil, "1"),cAno+"-"+cMes,,,,,}, .T.)
				S1210A05(@cXml, {(cAliasSRA)->RA_CIC}, .F.)
				If( cVersEnvio < "9.0", S1210A06(@cXml, {nVlrDep}, .T.), Nil )
			EndIf
			aAdd(aideBenef, {(cAliasSRA)->RA_CIC, nvlrDep, (cAliasSRA)->RA_FILIAL})
			aDados		:= {}
			aErros		:= {}
			lPrimIdT	:= .T.
			cIdeRubr	:= ""
			If !lRelat
				aInfoPgto	:= {}
				aDetPgtoFl	:= {}
				aRetFer		:= {}
				aRetPgtoTot	:= {}
				aRetPensao	:= {}
				aLogCIC		:= {}
				aDetPgtoAt 	:= {}
				aPgtoAnt 	:= {}
			EndIf
		Endif

		If (!lRes .And. __oSt05_1 == Nil) .Or. (lRes .And. __oSt05_2 == Nil)
			If !lRes
				__oSt05_1 := FWPreparedStatement():New()
				cQrySt := "SELECT RD_FILIAL,RD_MAT,RD_DATPGT,RD_SEMANA,RD_PD,RD_SEQ,RD_CC,RD_PERIODO,RD_ROTEIR,RD_VALOR,RD_IDCMPL,'SRD' AS TAB,SRD.R_E_C_N_O_ AS RECNO "
				If lTemNrBen
					cQrySt += ", RD_NRBEN "
				EndIf
			Else
				__oSt05_2 := FWPreparedStatement():New()
				cQrySt := "SELECT DISTINCT RD_FILIAL,RD_MAT,RD_DATPGT,RD_SEMANA,RD_PD,RD_SEQ,RD_CC,RD_PERIODO,RD_ROTEIR,RD_VALOR,RD_IDCMPL,'SRD' AS TAB,SRD.R_E_C_N_O_ AS RECNO  "
				If lTemNrBen
					cQrySt += ", RD_NRBEN "
				Endif
			EndIf
			cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
			cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
			cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
			cQrySt += 		"SRD.RD_MAT = ? AND "
			cQrySt += 		"SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
			cQrySt += 		"SRD.RD_TIPO2 != 'K' AND "
			cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
			cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
			cQrySt += 		"SRY.RY_TIPO != 'K' AND "
			cQrySt += 		"SRY.RY_FILIAL = ? AND "
			cQrySt += 		"SRY.D_E_L_E_T_ = ' ' AND "
			cQrySt +=		"SRD.RD_PD NOT IN ("
			cQrySt +=			"SELECT SRR.RR_PD "
			cQrySt +=			"FROM " + RetSqlName('SRR') + " SRR "
			cQrySt +=			"WHERE SRR.RR_FILIAL = ? AND "
			cQrySt +=				"SRR.RR_MAT = ? AND "
			cQrySt +=				"SRR.RR_DATAPAG = SRD.RD_DATPGT  AND "
			If !lRes
				cQrySt +=			"SRR.RR_TIPO3 = 'F'  AND "
			EndIf
			cQrySt +=				"SRR.D_E_L_E_T_ = ' ') "
			If cOpcTab == "1" .Or. lRes
				cQrySt += "UNION "
				If !lRes
					cQrySt += "SELECT RC_FILIAL,RC_MAT,RC_DATA,RC_SEMANA,RC_PD,RC_SEQ,RC_CC,RC_PERIODO,RC_ROTEIR,RC_VALOR,RC_IDCMPL,'SRC' AS TAB,SRC.R_E_C_N_O_ AS RECNO "
					If lTemNrBen
						cQrySt += ", RC_NRBEN AS RD_NRBEN "
					EndIf
				Else
					cQrySt += "SELECT DISTINCT RC_FILIAL AS RD_FILIAL,RC_MAT AS RD_MAT,RC_DATA AS RD_DATPGT,RC_SEMANA AS RD_SEMANA,RC_PD AS RD_PD,RC_SEQ AS RD_SEQ,RC_CC AS RD_CC,RC_PERIODO AS RD_PERIODO,RC_ROTEIR AS RD_ROTEIR,RC_VALOR AS RD_VALOR,RC_IDCMPL AS RD_IDCMPL, 'SRC' AS TAB,SRC.R_E_C_N_O_ AS RECNO "
					If lTemNrBen
						cQrySt += ", RC_NRBEN AS RD_NRBEN "
					EndIf
				EndIf
				cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
				cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
				cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
				cQrySt += 		"SRC.RC_MAT = ? AND "
				cQrySt += 		"SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
				cQrySt += 		"SRC.RC_TIPO2 != 'K' AND "
				cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
				cQrySt += 		"SRY.RY_TIPO != 'K' AND "
				cQrySt += 		"SRY.D_E_L_E_T_ = ' ' AND "
				cQrySt +=		"SRC.RC_PD NOT IN ("
				cQrySt +=			"SELECT SRR.RR_PD "
				cQrySt +=			"FROM " + RetSqlName('SRR') + " SRR "
				cQrySt +=			"WHERE SRR.RR_FILIAL = ? AND "
				cQrySt +=				"SRR.RR_MAT = ? AND "
				cQrySt +=				"SRR.RR_DATAPAG = SRC.RC_DATA AND "
				If !lRes
					cQrySt +=			"SRR.RR_TIPO3 = 'F'  AND "
				EndIf
				cQrySt +=				"SRR.D_E_L_E_T_ = ' ') "
			EndIf
			If lRes
				cQrySt += "UNION ALL "
				cQrySt += "SELECT RR_FILIAL,RR_MAT,RR_DATA,RR_SEMANA,RR_PD,RR_SEQ,RR_CC,RR_PERIODO,RR_ROTEIR,RR_VALOR,RR_IDCMPL,'SRR' AS TAB, SRR.R_E_C_N_O_ AS RECNO "
				If lTemNrBen
					cQrySt += ", '' AS RD_NRBEN "
				Endif
				cQrySt += "FROM " + RetSqlName('SRR') + " SRR "
				cQrySt += "WHERE SRR.RR_FILIAL = ? AND "
				cQrySt += 		"SRR.RR_MAT = ? AND "
				cQrySt += 		"SRR.RR_DATAPAG BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
				cQrySt += 		"SRR.RR_TIPO2 != 'K' AND "
				cQrySt += 		"SRR.RR_TIPO3 != 'F' AND "
				cQrySt += 		"SRR.D_E_L_E_T_ = ' ' "
			EndIf
			If lTemNrBen
				cQrySt += "ORDER BY 1, 2, 8, 9, 3, 14, 5"
			Else
				cQrySt += "ORDER BY 1, 2, 8, 9, 3, 5"
			EndIf
			cQrySt := ChangeQuery(cQrySt)
			If !lRes
				__oSt05_1:SetQuery(cQrySt)
			Else
				__oSt05_2:SetQuery(cQrySt)
			EndIf
		EndIf
		If !lRes
			__oSt05_1:SetString(1, cFil)
			__oSt05_1:SetString(2, cMat)
			__oSt05_1:SetString(3, xFilial("SRY", cFil))
			__oSt05_1:SetString(4, cFil)
			__oSt05_1:SetString(5, cMat)
			If cOpcTab == "1"
				__oSt05_1:SetString(6, cFil)
				__oSt05_1:SetString(7, cMat)
				__oSt05_1:SetString(8, cFil)
				__oSt05_1:SetString(9, cMat)
			EndIf
		Else
			__oSt05_2:SetString(1, cFil)
			__oSt05_2:SetString(2, cMat)
			__oSt05_2:SetString(3, xFilial("SRY", cFil))
			__oSt05_2:SetString(4, cFil)
			__oSt05_2:SetString(5, cMat)
			__oSt05_2:SetString(6, cFil)
			__oSt05_2:SetString(7, cMat)
			__oSt05_2:SetString(8, cFil)
			__oSt05_2:SetString(9, cMat)
			__oSt05_2:SetString(10, cFil)
			__oSt05_2:SetString(11, cMat)
		EndIf
		If !lRes
			cQrySt := __oSt05_1:getFixQuery()
		Else
			cQrySt := __oSt05_2:getFixQuery()
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRX,.T.,.T.)

		For nx1 := 1 To len(aStru)
			If aStru[nX1][2] <> "C" .And. FieldPos(aStru[nX1][1])<>0
				TcSetField(cAliasSRX,aStru[nX1][1],aStru[nX1][2],aStru[nX1][3],aStru[nX1][4])
			EndIf
		Next nX1
		dbSelectArea(cAliasSRX)

		//Verifica qual a data de pagamento do roteiro 132 nos casos de funcionários com rescisão calculada em dezembro
		If !Empty(SRA->RA_DEMISSA) .And. SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. (Empty(dDtPgto) .Or. cKeyProc <> xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES)
			dDtPgto 	:= fGetDtPgto(SRA->RA_FILIAL, SRA->RA_PROCES, AnoMes(SRA->RA_DEMISSA), "01", "132")
			cKeyProc	:= xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES
		EndIf
		aDmDevBop := {}
		If (cAliasSRX)->(!Eof())
			If aScan( aContdmDev, { |x| x[1] == cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } ) == 0
				aAdd( aContdmDev, { cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } )
			EndIf
			While (cAliasSRX)->(!Eof())
				cTpRot := fGetTipoRot( (cAliasSRX)->RD_ROTEIR )

				// DESCONSIDERA OS ID´S DE DESONERAÇÃO
				If !lRobo .And. RetValSrv((cAliasSRX)->RD_PD, (cAliasSRX)->RD_FILIAL, 'RV_CODFOL') $ "0148|0973"
					(cAliasSRX)->(DBSkip())
					Loop
				EndIf

				If lRes
					If !((cAliasSRX)->RD_PERIODO != cCompete .Or. (cAliasSRX)->RD_DATPGT == dDtRes)
						(cAliasSRX)->(DBSkip())
						Loop
					Endif
				Endif

				//Para competencia anterior a Dezembro, despreza todas as verbas do roteiro 132 que não seja a do líquido (Id 0022)
				If ( SubStr(cCompete, 1, 2) != "12" .And. ( (cAliasSRX)->RD_ROTEIR == "132" .Or. cTpRot == "6" ) ) .And. (cAliasSRX)->RD_PD != cPdCod0021
					(cAliasSRX)->( dbSkip() )
					Loop
				EndIf

				If SubStr(cCompete, 1, 2) == "12" .And. ((cAliasSRX)->RD_ROTEIR == "132" .Or. cTpRot == "6")
					lTem132	:= .T.
				EndIf

				//Terceiro grupo, autonomo regime caixa que não gerou S-1200 na competencia. Não gerar o  S-1210
				//Pessoa Juridica 10/05/2021 e Pessoa Juridica 19/07/2021
				If !Empty(dDcgIni) .And. MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, (cAliasSRX)->RD_PERIODO == "202104",(cAliasSRX)->RD_PERIODO == "202106" ).And. !(StrZero(Month(dDtPgt),2) == Substr((cAliasSRX)->RD_PERIODO,5,2)) ;
					.And. nQtdeFol == 1 .And. (cAliasSRA)->RA_CATEFD $ cTrabSemVinc
					nQtd1200 	:= fQtdS1200(cOpcTab, cPer1210)
					If nQtd1200 == 0    // Não houve movimento no S-1200
						lTercGrp	:= .T.
						(cAliasSRX)->( dbSkip() )
						Exit
					Endif
				Endif

				cFilx   	:= (cAliasSRX)->RD_FILIAL
				cPD     	:= (cAliasSRX)->RD_PD
				cCodFol 	:= RetValSrv( cPD, cFilx, 'RV_CODFOL' )
				cTipoCod 	:= RetValSrv( cPD, cFilx, 'RV_TIPOCOD' )
				cCodINCIRF 	:= RetValSrv( cPD, cFilx, 'RV_INCIRF' )
				cCodAdiant 	:= RetValSrv( cPD, cFilx, 'RV_ADIANTA' )
				cCodFil 	:= RetValSrv( cPD, cFilx, 'RV_FILIAL' )
				lAchou063	:= .F.

				//Verifica se a verba é gerada por código correspondente e é do tipo base:
				lCodCorr	:= fCodCorr(xFilial("SRV", cFilx), cPD) .And. cTipoCod $ "3*4"

				//Desprezar verbas geradas no fechamento dos roteiros ADI/FOL, desconto do arredondamento de férias/folha, dedução para férias/abono no S-1200, férias/abono pagos mês anterior ou período superior ao escolhido
				If cCodFol $ "0012/0106/0107/0105/1562/1722/1723/0044/0164/1449/0029/0300/0025/0082/0088/0090/0092/0096/0094/0095/0097/0098/0099/1893" .Or. (cAliasSRX)->RD_PERIODO > SubStr(cCompete,3,4)+SubStr(cCompete,1,2) .Or. lCodCorr;

					If lRes .And. cTpRot == "4"
						dbSelectArea("SRG")
						SRG->( dbSetOrder(1) )
						If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS((cAliasSRX)->RD_DATPGT) ) )
							If AnoMes(SRG->RG_DATAHOM) > cAno+cMes
								lPgtRes := .F.
							EndIf
						EndIf
					EndIf
					(cAliasSRX)->( dbSkip() )
					Loop
				EndIf

				If lRes .And. !(cTpRot $ "4/6") // Se tiver rescisão no mês a data de pagamento será a data de pagamento do roteito para que os ideDmDev fiquem iguais no S-1200 e S-1210
					//Se for a verba de INSS Patronal e for no mesmo período da rescisão, significa que é a verba de desoneração gerada para rescisão
					If cCodFol == "0148" .And. cPerRes+cSemRes == (cAliasSRX)->RD_PERIODO+(cAliasSRX)->RD_SEMANA
						cTpRot  := "4"
						dDtPgt  := (cAliasSRX)->RD_DATPGT
					Else
						dDtPgt  := StoD(fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX))
					EndIf
				Elseif (lRes .And. cTpRot == "4" ) .Or.;      									//Rescisao complementar outro periodo
				   (lResComPLR .And. cTpRot == "1" .And. !Empty((cAliasSRA)->RA_DEMISSA) .And. AnoMes((cAliasSRA)->RA_DEMISSA ) < (cAliasSRX)->RD_PERIODO )

					dbSelectArea("SRG")
					SRG->( dbSetOrder(1) )
					lAchouSRG := SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS((cAliasSRX)->RD_DATPGT) ) )
					If !lAchouSRG
						SRG->( dbSetOrder(2) ) //RG_FILIAL+RG_MAT+RG_ROTEIR+DTOS(RG_DATAHOM)
						lAchouSRG := SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + "RES" + dToS((cAliasSRX)->RD_DATPGT) ) )
					EndIf
					If lAchouSRG
						dDtPgt 		:= SRG->RG_DATAHOM
						cTpRes 		:= SRG->RG_RESCDIS
						If Empty(cUltTpRes)
							cUltTpRes	:= SRG->RG_RESCDIS
							cDtGerRes	:= AnoMes(SRG->RG_DTGERAR)
						ElseIf SRG->RG_RESCDIS != cUltTpRes .And. cUltTpRes == "0" .And. SRG->RG_RESCDIS $ "1|2" .And. AnoMes(SRG->RG_DTGERAR) > cDtGerRes
							cUltTpRes	:= SRG->RG_RESCDIS
							cDtGerRes	:= AnoMes(SRG->RG_DTGERAR)
							lRes		:= .F.
							lResOriCom	:= .T.
						EndIf
						If AnoMes(dDtPgt) > cAno+cMes
							lPgtRes := .F.
							(cAliasSRX)->( dbSkip() )
							Loop
						EndIf
					EndIF
				else
					dDtPgt  := (cAliasSRX)->RD_DATPGT
				EndIf

				cPeriodo	:= (cAliasSRX)->RD_PERIODO
				cRoteiro	:= (cAliasSRX)->RD_ROTEIR
				cPer		:= substr(cPeriodo,1,4)+"-"+substr(cPeriodo,5,2)
				cPer132		:= substr(cPeriodo,1,4)
				dDtPgtRR 	:= dDtPgt
				nValor		:= (cAliasSRX)->RD_VALOR

				If lResOriCom .And. cTpRot == "4"
					If (cAliasSRA)->RA_CATFUNC $ "P*A"
						cTpRot 	:= "9"
						cRoteiro:= fGetCalcRot("9")
					Else
						cTpRot 	:= "1"
						cRoteiro:= fGetRotOrdinar()
					EndIf
				EndIf

				If lVer546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2")
					lGera546	:= lTem546(cFil,cMat,cDtPesqI,cDtPesqF,cPdCod546)
					lVer546 	:= .F.
				EndIf

				If cTipoCod $ "2/4"
					nValor *= (-1)
				EndIf

				cPdLiq := cCodFol

				If cCodFol == "0066"//I.R.
					nValor *= (-1)
					SRD->( dbSetOrder(6) )//RD_FILIAL+RD_MAT+RD_PD+RD_ROTEIR+DTOS(RD_DATPGT)
					SRC->( dbSetOrder(8) )//RC_FILIAL+RC_MAT+RC_PD+RC_ROTEIR+DTOS(RC_DATA)
					For nContRot := 1 To Len(aRotADI)
						If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
							While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PD+SRD->RD_ROTEIR+AnoMes(SRD->RD_DATPGT) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt)
								nValor -= SRD->RD_VALOR
								If nValor <= 0
									(cAliasSRX)->( dbSkip() )
									lAchou063 := .T.
									Exit
								EndIf
								SRD->( dbSkip() )
							EndDo
						EndIf
						If !lAchou063 .And. SRC->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
							While SRC->( !EoF() ) .And. SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PD+SRC->RC_ROTEIR+AnoMes(SRC->RC_DATA) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt)
								nValor -= SRC->RC_VALOR
								If nValor <= 0
									(cAliasSRX)->( dbSkip() )
									lAchou063 := .T.
									Exit
								EndIf
								SRC->( dbSkip() )
							EndDo
						EndIf
					Next nCont
					If !lAchou063
						For nContRot := 1 To Len(aRotFOL)
							If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
								While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PD+SRD->RD_ROTEIR+AnoMes(SRD->RD_DATPGT) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt)
									nValor -= SRD->RD_VALOR
									If nValor <= 0
										(cAliasSRX)->( dbSkip() )
										lAchou063 := .T.
										Exit
									EndIf
									SRD->( dbSkip() )
								EndDo
							EndIf
							If !lAchou063 .And. SRC->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
								While SRC->( !EoF() ) .And. SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PD+SRC->RC_ROTEIR+AnoMes(SRC->RC_DATA) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt)
									nValor -= SRC->RC_VALOR
									If nValor <= 0
										(cAliasSRX)->( dbSkip() )
										lAchou063 := .T.
										Exit
									EndIf
									SRC->( dbSkip() )
								EndDo
							EndIf
						Next nCont
					EndIf
					If lAchou063
						Loop
					EndIf
					nValor *= (-1)
				EndIf

				If lRes .And. (cTpRot $ "1/2/5/9/F" .Or. (cTpRot == "6" .And. !(SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. SRA->RA_DEMISSA >= dDtPgto .Or. (SRA->RA_DEMISSA < dDtPgto .And. cStatC91 <> "-1")))) .And. cPerRes == cPeriodo .Or. cTpRot == "4"

					// Empresa do 3o grupo possui rescisão no mês que inicia a obrigatoriedade do envio de periódicos
					If !Empty(dDcgIni) .And. MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, (cPeriodo == "202105" .And. MesAno(SRA->RA_DEMISSA) == "202105" .And. SRA->RA_DEMISSA < CtoD("10/05/2021") ), (cPeriodo == "202107" .And. MesAno(SRA->RA_DEMISSA) == "202107" .And. SRA->RA_DEMISSA < CtoD("19/07/2021")))
						l3GRescMes := .T.
					EndIf
					IF ( !Empty(dDcgIni) .And. (MesAno(MonthSum(dDcgIni, IIF(Month(dDcgIni) == 3, 1,2)  )) == cPeriodo) .Or. ( MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, cPeriodo <= "202104",cPeriodo <= "202106" ) ) ) .Or. l3GRescMes
						cTpPgto := "9"

						IF cTpRot == "4"
							dbSelectArea("SRG")
							SRG->( dbSetOrder(1) )
							If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS(dDtPgt) ) )
								dDtPgt := SRG->RG_DATAHOM
							EndIF
						ENDIF
					ELSE
						If lTSV
							If cVersEnvio < "9.0.00" .Or. SRA->RA_CATEFD == "721"
								cTpPgto := "3"
							Else
								cTpPgto := "1"
								If cVersEnvio >= "9.0.00" .And. lOrig1202 .And. lCatEst
									cTpPgto := "4"
								Endif
							EndIf
						Else
							cTpPgto := "2"
						Endif
					ENDIF

					If cTpRot == "4"
						If dDtPgt != dlastDate .Or. (cTpRot != cLastRot .And. Left(cideDmDev, 1) != "R")
							If cTpRes == "3" .And. Empty(nContRes)
								++nContRes
							EndIf
							cideDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA", (cAliasSRA)->RA_FILIAL)) + (cAliasSRA)->RA_MAT + If(cTpRes == "3", "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
						EndIf
					Else
						//O ADI deve ser gerado com o cTpPgto 2 e o ID da DmDev deve ficar igual ao que foi gerado para o ADI no desligamento
						cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
					EndIf
					cLastRot  := cTpRot
					dlastDate := dDtPgt
				Else
					If ( !Empty(dDcgIni) .And. (MesAno(MonthSum(dDcgIni, IIF(Month(dDcgIni) == 3, 1,2)  )) == cPeriodo  .Or. ( MesAno(dDcgIni) == "201904" .And.  If(!lPesFisica, cPeriodo <= "202104", cPeriodo <= "202106") ))  .And. !(StrZero(Month(dDtPgt),2) == Substr(cPeriodo,5,2)) )
						cTpPgto := "9"
					Else
						cTpPgto := "1"
						If cVersEnvio >= "9.0.00"
							If lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
								cTpPgto := "5"
							ElseIf lOrig1202 .And. lCatEst
					   			cTpPgto := "4"
							EndIf
						Endif
					EndIf
					//Verifica se mes anterior ocorreu pagamento como Multv. Funcionario demitido e admitido no mesmo periodo. Regime Caixa
					If lAglut .And. nQtdeFol == 1 .And. If( cTpRot == "1", cPeriodo < MesAno(dDtPgt), .T.) .And. cPeriodo != cPerOld1
						cPerOld1	:= cPeriodo
						nQtdMesAnt	:= fQtdS1200(cOpcTab, cPeriodo)
					Endif

					If lAglut .And. ((cAliasSRA)->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1 .Or. (nQtdeFol >= 1 .And. nQtdeFol < nQtdMesAnt) ) //MultV
						If nQtdeFol > 1 .And. cPeriodo != cPerOld
							cPerOld	 	:= cPeriodo
							nQtdeFolMV 	:= fQtdeFolMV(cOpcTab, cPeriodo, cDtPesqI, cDtPesqF)
						EndIf
						If (cAliasSRA)->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFolMV > 1 .AND. !lResComPLR
							If cVersEnvio >= "9.0.00" .And. nQtdeFol == 1
								cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
							Else
								cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 3 ) + SubStr( cPeriodo, 3 ) + cRoteiro
							EndIf
							If Len(cideDmDev) > 30
								cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 7 ) + fGetTipoRot( cRoteiro )
							EndIf
						ElseIf lResComPLR .And. !lDtPgto
							cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX), 3, 7) + SubStr(cPeriodo, 3) + cRoteiro
						ElseIf nQtdeFol < nQtdMesAnt
							cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 3 ) + SubStr( cPeriodo, 3 ) + cRoteiro
						Else
							cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
						EndIf
					ElseIf lResComPLR .And. !lDtPgto
						cideDmDev := cFilx + fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX) + cPeriodo + cRoteiro
					Else
						cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
					EndIf
				Endif

				// Tratamento cideDmDev para roteiro BOP
				If cVersEnvio >= "9.0.00" .And. lOrig1207 .And. cRoteiro == "BOP" .And. cPdLiq == "0047" .And. cTpRot == "O"
					If (nDm := aScan( aDmDevBop, { |x| x[1] == cideDmDev } )) == 0
						aAdd(aDmDevBop, {cideDmDev, "1"})
					Else
						cideDmDev += aDmDevBop[nDm][2]
						aDmDevBop[nDm][2] := Soma1(aDmDevBop[nDm][2])
					EndIf
				EndIf

				If cVersEnvio < "9.0" .Or. cTpPgto <> "9"
					nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == dtos(dDtPgt) .And. x[2] == cTpPgto .And. x[5] == (cAliasSRA)->RA_CIC } )
					If nPInfoPgto == 0
						If Left(cideDmDev, 1) == "R"
							dbSelectArea("SRG")
							SRG->( dbSetOrder(1) )
							If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS(dDtPgt) ) )
								dDtPgtRR := SRG->RG_DATAHOM
							EndIF
						EndIf
						aAdd( aInfoPgto, { dtos(dDtPgt), cTpPgto ,If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
					EndIf
					nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
					If nPdetPGtoFl == 0
						aAdd( adetPgtoFl, { If(cTpPgto $ "2/3" .Or. (cRoteiro == "RES" .Or. cTpRot == "4"),If(cVersEnvio >= "9.0", cPer, Iif(!lMiddleware, "", Nil)), If(SubStr(cCompete, 1, 2) == "12" .And. (cRoteiro == "132" .Or. cTpRot == "6"), cPer132, cPer)), cideDmDev, Iif(cVersEnvio < "9.0", "S", Nil), 0, Iif(lMiddleware .And. (cTpPgto $ "2/3" .Or. cRoteiro == "RES" .Or. cTpRot == "4"), cRecResc, Nil), "N", dToS(dDtPgt) + cTpPgto, (cAliasSRA)->RA_CIC, (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_CODUNIC, (cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_FILIAL } )
					EndIf
				EndIf

				nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dtos(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
				If nPdetPGtoFl > 0
					If cPdLiq == "0126" .Or. (!(cTpPgto $ "2/3") .And. cPdLiq == "0303") .Or. (cPdLiq == "0021" .And. (cRoteiro == "132" .Or. cTpRot == "6")) .Or. (cPdLiq == "0678" .And. (cRoteiro == "131" .Or. cTpRot == "5"))
						adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
						lPgtRes := .F.
					Elseif ((lGera546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2")) .Or. !(cRoteiro == "ADI" .Or. cTpRot == "2")) .And. ((cPdLiq == "0047" .And. cTpRot != "N" ) .Or. cPdLiq == "0836" .Or. ( cPdLiq == "0546" .And. (cRoteiro == "ADI" .Or. cTpRot == "2") ) ) //proteger, pois pode ter iniciado e varrer dentre os registros SRD´s que nao sejam 0047
						adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
						If cPdLiq == "0836"
							lPgtRes := .F.
						EndIf
					Elseif !lGera546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2") .And. cCodAdiant == "S" .And. cPdLiq != "0151" .And. (cRoteiro == "ADI" .Or. cTpRot == "2")
						If cTipoCod  == '1'
							adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
						ElseIf cTipoCod  == '2'
							adetPgtoFl[nPdetPGtoFl, 4] -= (cAliasSRX)->RD_VALOR
						EndIf
						lPgtRes := .F.
					ElseIf lRes .And. (cRoteiro == "RES" .Or. cTpRot == "4") .And. AnoMes(dDtRes) > cAno+cMes
						lPgtRes := .F.
					EndIf
					If !Empty((cAliasSRX)->RD_IDCMPL)
						adetPgtoFl[nPdetPGtoFl, 6] := "S"
					EndIf
				EndIf

				If cVersEnvio < "9.0"

					If !Empty(xFilial("SRV"))
						lGeraCod := .T.
					EndIf

					If !( !Empty(dDcgIni) .And. ( ( MesAno(MonthSum(dDcgIni,IIF(Month(dDcgIni) == 3, 1,2) )) == cPeriodo)  .Or. ( MesAno(dDcgIni) == "201904" .And.   If(!lPesFisica, cPeriodo <= "202104", cPeriodo <= "202106" )) ) .And. !(StrZero(Month(dDtPgt),2) == Substr(cPeriodo,5,2)) ) .And.;
						( cCodINCIRF $ '31|32|33|34|35|51|52|53|54|55|81|82|83' )
						If Left(cideDmDev, 1) == "R" .And. nContRes > 1
							aEval( aRetPgtoTot, { |x| If(x[1] == cPd .And. Left(x[7], 1) == "R", nValor -= x[6], Nil) }  )
							If cTipoCod $ "2/4" .And. Abs(nValor) <= 0 .Or. !(cTipoCod $ "2/4") .And. nValor <= 0
								(cAliasSRX)->(dbSkip())
								Loop
							EndIf
						EndIf
						nPos := aScan(aRetPgtoTot, {|x| x[1] == cPd .And. x[7] == cideDmDev .And. x[9] == (cAliasSRA)->RA_CIC })
						If lGeraCod
							cIdTbRub := cCodFil
						Else
							If cVersEnvio >= "2.3"
								cIdTbRub := cEmpAnt
							Else
								cIdTbRub := ""
							EndIf
						EndIf

						If lMiddleware
							If lPrimIdT
								lPrimIdT  := .F.
								cIdeRubr := fGetIdRJF( cCodFil, cIdTbRub )
								If Empty(cIdeRubr) .And. aScan(aErros, { |x| x == OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) }) == 0
									aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
								EndIf
							EndIf
							cIdTbRub := cIdeRubr
						EndIf

						If nPos == 0
							Aadd (aRetPgtoTot, {cPd, cIdTbRub, Nil, Nil, Nil, nValor, cideDmDev, (cCodFil+cPd), (cAliasSRA)->RA_CIC} )
						else
							If lRes .And. RetValSrv( aRetPgtoTot[nPos,1], cFilx, 'RV_CODFOL' ) $ "0066|0071" .And. Left(aRetPgtoTot[nPos,7],1) = "R"
								aRetPgtoTot[nPos,6] := nValor
							Else
								aRetPgtoTot[nPos,6] += nValor
							Endif
						Endif

						If (VAL(cCodINCIRF ) >=  51 .And. VAL(cCodINCIRF ) <= 55)
							fBenefic( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, dDtPgt, cPd, nValor, cideDmDev, cPeriodo )
						EndIf

					EndIf

					//Verifica se o pagamento eh referente a periodos anteriores com base na data da Carga Inicial
					//A competencia deve ser 2 meses apos o periodo da carga inicial (inicio da obrigatoriedade)
					//------------------------------------------------------------------------
					//OBS.: Esse dado sera gerado somente no primeiro mes para empresas que trabalham em regime caixa.
					//Então futuramente deve ser retirado da rotina evitar validacoes desnecessarias e melhor performance
					//------------------------------------------------------------------------
					//Exemplo: 	Carga inicial = 201803 ## Folha de pagamento = 201804 com data de pagamento = 05/05/2018
					//			Entao para geracao é informado 05/2018 que refere-se a competencia 201804 e atende a condicao abaixo.
					//------------------------------------------------------------------------
					If ( !Empty(dDcgIni) .And. ( (MesAno(MonthSum(dDcgIni,IIF(Month(dDcgIni) == 3, 1,2) )) == cPeriodo) .Or. ( MesAno(dDcgIni) == "201904" .And.  If(!lPesFisica, cPeriodo <= "202104", cPeriodo <= "202106" )) ).And. !(StrZero(Month(dDtPgt),2) == Substr(cPeriodo,5,2)) .Or. l3GRescMes)
						If cCodINCIRF  $ '00|01|09|11|12|13|14|15|31|32|33|34|35|41|42|43|44|46|47|51|52|53|54|55|61|62|63|64|70|71|72|73|74|75|76|77|78|79|81|82|83|91|92|93|94|95'

							If lGeraCod
								cIdTbRub := cCodFil
							Else
								If cVersEnvio >= "2.3"
									cIdTbRub := cEmpAnt
								Else
									cIdTbRub := ""
								EndIf
							EndIf

							nPdetPGtoAt := aScan( aDetPgtoAt, { |x| x[3] == dToS(dDtPgt) + "9" .And. x[1] == cCat} )
							If nPdetPGtoAt == 0
								aAdd( aDetPgtoAt, { cCat, "N", dToS(dDtPgt) + "9" } )
							EndIf

							nPos := aScan( aPgtoAnt, {|X| x[7] == dToS(dDtPgt) + "9" .And. x[5] == SubStr(cCodINCIRF, 1, 2) })
							If nPos > 0
								aPgtoAnt[nPos, 6] += nValor
							Else
								aAdd( aPgtoAnt, { Nil, Nil, Nil, Nil, SubStr(cCodINCIRF, 1, 2), nValor, dToS(dDtPgt) + "9" } )
							EndIf

						EndIf
					EndIf

				EndIf //2.5

				(cAliasSRX)->(dbSkip())
			EndDo//cAliasSRX
		EndIf

		If cVersEnvio < "9.0" .Or. cTpPgto <> "9"
			If SubStr(cCompete, 1, 2) == "12" .And. !lTem132
				cDtIni := SubStr(cCompete,3,4)+"0101"
				cDtFim := SubStr(cCompete,3,4)+"1130"
				If Select( cAliasSRX ) > 0
					(cAliasSRX)->( dbCloseArea() )
				EndIf

				If __oSt06 == Nil
					__oSt06 := FWPreparedStatement():New()
					cQrySt := "SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_SEMANA, SRD.RD_PD, SRD.RD_SEQ, SRD.RD_CC, SRD.RD_PERIODO, SRD.RD_ROTEIR, SRD.RD_VALOR, 'SRD' AS TAB, SRD.R_E_C_N_O_  AS RECNO "
					cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
					cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRy + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
					cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
					cQrySt += 		"SRD.RD_MAT = ? AND "
					cQrySt += 		"SRD.RD_DATPGT BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
					cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
					cQrySt += 		"SRY.RY_TIPO = '6' AND "
					cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
					cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
					If cOpcTab == "1"
						cQrySt += "UNION ALL "
						cQrySt += "SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_DATA, SRC.RC_SEMANA, SRC.RC_PD, SRC.RC_SEQ, SRC.RC_CC, SRC.RC_PERIODO, SRC.RC_ROTEIR, SRC.RC_VALOR, 'SRC' AS TAB, SRC.R_E_C_N_O_  AS RECNO "
						cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
						cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
						cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
						cQrySt += 		"SRC.RC_MAT = ? AND "
						cQrySt += 		"SRC.RC_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
						cQrySt += 		"SRY.RY_TIPO = '6' AND "
						cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
						cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
					EndIf
					cQrySt += "ORDER BY 1, 2, 8, 9, 3, 5"
					cQrySt := ChangeQuery(cQrySt)
					__oSt06:SetQuery(cQrySt)
				EndIf
				__oSt06:SetString(1, cFil)
				__oSt06:SetString(2, cMat)
				If cOpcTab == "1"
					__oSt06:SetString(3, cFil)
					__oSt06:SetString(4, cMat)
				EndIf
				cQrySt := __oSt06:getFixQuery()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRX,.T.,.T.)

				TCSetField( cAliasSRX, "RD_DATPGT", "D", 8, 0 )

				If (cAliasSRX)->(!Eof())
					If aScan( aContdmDev, { |x| x[1] == cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } ) == 0
						aAdd( aContdmDev, { cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } )
					EndIf
					While (cAliasSRX)->(!Eof())
						cFilx   	:= (cAliasSRX)->RD_FILIAL
						cPD     	:= (cAliasSRX)->RD_PD
						dDtPgt  	:= sToD(SubStr(cCompete,3,4)+"1201")
						cPeriodo	:= (cAliasSRX)->RD_PERIODO
						cRoteiro	:= (cAliasSRX)->RD_ROTEIR
						cPer		:= substr(cPeriodo,1,4)

						cCodFol 	:= RetValSrv( cPD, cFilx, 'RV_CODFOL' )
						cTipoCod 	:= RetValSrv( cPD, cFilx, 'RV_TIPOCOD' )
						cCodINCIRF 	:= RetValSrv( cPD, cFilx, 'RV_INCIRF' )
						cCodAdiant 	:= RetValSrv( cPD, cFilx, 'RV_ADIANTA' )
						cCodFil 	:= RetValSrv( cPD, cFilx, 'RV_FILIAL' )

						nValor	:= (cAliasSRX)->RD_VALOR
						If cTipoCod $ "2/4"
							nValor *= (-1)
						EndIf

						cPdLiq := cCodFol

						cideDmDev := cFilx + dtos((cAliasSRX)->RD_DATPGT) + cPeriodo + cRoteiro

						nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == dtos(dDtPgt) .And. x[2] == cTpPgto .And. x[5] == (cAliasSRA)->RA_CIC } )
						If nPInfoPgto == 0
							aAdd( aInfoPgto, { dtos(dDtPgt), cTpPgto ,If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
						EndIf

						nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
						If nPdetPGtoFl == 0
							aAdd( adetPgtoFl, { cPer, cideDmDev, Iif(cVersEnvio < "9.0", "S", Nil), 0, Nil, "N", dToS(dDtPgt) + cTpPgto, (cAliasSRA)->RA_CIC, (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_CODUNIC, (cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_FILIAL } )
						EndIf

						If cVersEnvio < "9.0" .And. cCodINCIRF $ '31|32|33|34|35|51|52|53|54|55|81|82|83'
							nPos := aScan(aRetPgtoTot, {|x| x[1] == cPd .And. x[7] == cideDmDev .And. x[9] == (cAliasSRA)->RA_CIC })
							If lGeraCod
								cIdTbRub := cCodFil
							Else
								If cVersEnvio >= "2.3"
									cIdTbRub := cEmpAnt
								Else
									cIdTbRub := ""
								EndIf
							EndIf

							If lMiddleware
								If lPrimIdT
									lPrimIdT  := .F.
									cIdeRubr := fGetIdRJF( cCodFil, cIdTbRub )
									If Empty(cIdeRubr) .And. aScan(aErros, { |x| x == OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) }) == 0
										aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
									EndIf
								EndIf
								cIdTbRub := cIdeRubr
							EndIf

							If nPos == 0
								Aadd (aRetPgtoTot, {cPd, cIdTbRub, Nil, Nil, Nil, nValor, cideDmDev, (cCodFil+cPd), (cAliasSRA)->RA_CIC} )
							else
								aRetPgtoTot[nPos,6] += nValor
							Endif

							If (VAL(cCodINCIRF ) >=  51 .AND. VAL(cCodINCIRF ) <= 55)
								fBenefic( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, dDtPgt, cPd, nValor, cideDmDev, cPeriodo )
							EndIf
						EndIf

						(cAliasSRX)->(dbSkip())
					EndDo
				EndIf
			EndIf

			//Para funcionarios que não possuem a categoria de contrato intermitente
			If (cAliasSRA)->RA_CATEFD <> "111"
				//Tratamento para buscar os valores de ferias
				aBkpFer := fm036GetFer( cSRHFil, cSRHMat, cDtPesqI, cDtPesqF, (cAliasSRA)->RA_CATEFD, @aVbFer, @aErros, cFilPreTrf )
			Endif

			//Zera as variáveis
			cNumFer 	:= ""
			cBkpDtFer	:= ""
			nNumFer 	:= 0

			For nCntFer := 1 To Len(aBkpFer)
				If cVersEnvio >= "9.0"
					nRetFer := nCntFer
					If !lRes
						aAdd( aRetFer, aClone( aBkpFer[nCntFer] ) )
						//Verifica se a data de pagamento das férias é igual
						If !Empty(cBkpDtFer) .And. cBkpDtFer == aBkpFer[nCntFer, 6]
							nNumFer ++
							If nNumFer >= 1
								cNumFer := cValToChar(nNumFer)
							EndIf
						EndIf

						If lAglut .And. (SRA->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1)//MultV
							If nQtdeFol == 1
								cideDmDev := cSRHFil + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer
							Else
								cideDmDev := cSRHFil + cSRHMat + SubStr( aBkpFer[nCntFer, 6], 3 ) + SubStr( aBkpFer[nCntFer, 12], 3 )  + "FER" + cNumFer
							EndIf
							If Len(cideDmDev) > 30
								cideDmDev := cSRHFil + SRA->RA_MAT + SubStr( aBkpFer[nCntFer, 6], 7 ) + "FER" + cNumFer
							EndIf
						Else
							cideDmDev := cSRHFil + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer
						EndIf

						nRetFer := Len(aRetFer)
						aAdd( aRetFer[nRetFer], cideDmDev)
						aRetFer[nRetFer][12] := substr(aBkpFer[nCntFer, 6],1,4) + "-" + substr(aBkpFer[nCntFer, 6],5,2)
						nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == aBkpFer[nCntFer, 6] .And. x[2] == ctpPgto .And. x[5] == (cAliasSRA)->RA_CIC } )
						If nPInfoPgto == 0
							aAdd( aInfoPgto, { aBkpFer[nCntFer, 6], ctpPgto, Nil, Nil, (cAliasSRA)->RA_CIC } )
						EndIf
						cBkpDtFer := aBkpFer[nCntFer, 6]
					EndIf
				Else
					aAdd( aRetFer, aClone( aBkpFer[nCntFer] ) )
					nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == aBkpFer[nCntFer, 6] .And. x[2] == "7" .And. x[5] == (cAliasSRA)->RA_CIC } )
					If nPInfoPgto == 0
						aAdd( aInfoPgto, { aBkpFer[nCntFer, 6], "7", If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
					EndIf
				EndIf
			Next

			//Se for residente no exterior busca alimenta o array aRGE1210 com os dados da tabela RGE
			If lResidExt
				aRGE1210 := fGetRGE( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, cCompete)
			Endif
		EndIf

		(cAliasQSRA)->( dbSkip() )
		(cAliasSRA)->( dbGoTo( (cAliasQSRA)->RECNO ) )

		If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
			cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
		EndIf

		If (cAliasQSRA)->(!Eof())
			If !lRelat .And. ( !lAglut .Or. nQtdeFol == 1 .Or. cCPF <> AllTrim((cAliasSRA)->RA_CIC) .Or. (cEmp != cEmpOld) ) .And. !lTercGrp
				If (Empty(aLogCIC) .OR. cVersEnvio <> "2.5.00")
					lRetXml := fXml1210(@cXml, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibo, cIdXml, cVersMw, @aErros, cPer1210, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCPF, nVlrDep)
					If lRetXml
						If !lMiddleware .And. cStatT3P $ "4"
							cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
						EndIf
						cBkpFilEnv	:= cFilEnv
						If lAglut
							If Len(aContdmDev) > 1
								cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
								For nZ := 1 to Len(aContdmDev)
									If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
										cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1210)
										EXIT
									ElseIf nZ == Len(aContdmDev)
										cFilEnv := cFilAnt := SubStr( aContdmDev[nZ,1], 1, FwSizeFilial() )
										EXIT
									EndIf
									cFilVal := Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
								Next nZ
							ElseIf !Empty(aContdmDev)
								cFilEnv := cFilAnt := SubStr( aContdmDev[1,1], 1, FwSizeFilial() )
							EndIf
						EndIf
						If !lMiddleware
							cTafKey := "S1210" + cPeriodo + cTpFolha + cCPF
							SM0->(dbSeek( cEmpAnt + cFilEnv ))
							aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S1210", , "", , , , "GPE", , "", If(nQtdeFol > 1, "MV", ""),,,,,,,cSRHCodUni )
						Else
							aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1210", cPer1210, cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, cRecibo } )
							If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
								aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
							EndIf
						EndIf
						If Len( aErros ) > 0
							If !lMiddleware
								FeSoc2Err( aErros[1], @cMsgErro)
							Else
								For nCont := 1 To Len(aErros)
									cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
								Next nCont
							EndIf
							aAdd(aLogsErr, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029) ) //##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
							aAdd(aLogsErr, "" )
							aAdd(aLogsErr, cMsgErro)
							If lTSV
								aEmp_1210[4]++ //Inclui TSV nao integrado
							Else
								aEmp_1210[2]++ //Inclui TCV nao integrado
							EndIf
						Else
							If !lMiddleware
								aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0049) ) //##"Registro S-1210 do Funcionário: "##" Integrado com TAF."
							Else
								aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0165) ) //##"Registro S-1210 do Funcionário: "##" Integrado com Middleware."
							EndIf
							aAdd(aLogsOk, "" )
							If lTSV
								aEmp_1210[3]++ //Inclui TSV integrado
							Else
								aEmp_1210[1]++ //Inclui TCV integrado
							EndIf
						Endif
						cFilEnv		:= cBkpFilEnv
						aInfoPgto	:= {}
						aRetFer		:= {}
						GrvTxtArq(alltrim(cXml), "S1210", cCPF)
					Else
						//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
						aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
						aAdd(aLogsErr, OemToAnsi(STR0180))
						aAdd(aLogsErr, "" )
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
				Else
					If !Empty(aLogCIC) .AND. cVersEnvio == "2.5.00"
						//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
						aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
						aAdd(aLogsErr, OemToAnsi(STR0149))
						aAdd(aLogsErr, "" )
					EndIf
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
			ElseIf lRelat .And. !Empty(aLogCIC)
				aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(STR0149)} )//" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
			EndIf
		EndIf
	EndDo //SRA

	If !lExcLote .And. ( !Empty(aInfoPgto) .Or. !Empty(aRetFer) )
		If !lRelat
			If (Empty(aLogCIC) .OR. cVersEnvio <> "2.5.00")
				lRetXml := fXml1210(@cXml, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibo, cIdXml, cVersMw, @aErros, cPer1210, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCPF, nVlrDep)
				If lRetXml
					If !lMiddleware .And. cStatT3P $ "4"
						cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
					EndIf
					If lAglut
						If Len(aContdmDev) > 1
							cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
							For nZ := 1 to Len(aContdmDev)
								If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
									cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1210)
									EXIT
								ElseIf nZ == Len(aContdmDev)
									cFilEnv := cFilAnt := SubStr( aContdmDev[nZ,1], 1, FwSizeFilial() )
									EXIT
								EndIf
								cFilVal := Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
							Next nZ
						ElseIf !Empty(aContdmDev)
							cFilEnv := cFilAnt := SubStr( aContdmDev[1,1], 1, FwSizeFilial() )
						EndIf
					EndIf

					If !lMiddleware
						cTafKey := "S1210" + cPeriodo + cTpFolha + cCPF
						SM0->(dbSeek( cEmpAnt + cFilEnv ))
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S1210", , "", , , , "GPE", , "", If(nQtdeFol > 1, "MV", "") ,,,,,,,cSRHCodUni )
					Else
						aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1210", cPer1210, cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, Nil, cRecibo } )
						If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
							aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
						EndIf
					EndIf
					If Len( aErros ) > 0
						If !lMiddleware
							FeSoc2Err( aErros[1], @cMsgErro)
						Else
							For nCont := 1 To Len(aErros)
								cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
							Next nCont
						EndIf
						aAdd(aLogsErr, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029) ) //##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
						aAdd(aLogsErr, "" )
						aAdd(aLogsErr, cMsgErro)
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					Else
						If !lMiddleware
							aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0049) ) //##"Registro S-1210 do Funcionário: "##" Integrado com TAF."
						Else
							aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0165) ) //##"Registro S-1210 do Funcionário: "##" Integrado com Middleware."
						EndIf
						aAdd(aLogsOk, "" )
						If lTSV
							aEmp_1210[3]++ //Inclui TSV integrado
						Else
							aEmp_1210[1]++ //Inclui TCV integrado
						EndIf
					Endif
					GrvTxtArq(alltrim(cXml), "S1210", cCPF)
				Else
					//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
					aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
					aAdd(aLogsErr, OemToAnsi(STR0180))
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
			Else
				If !Empty(aLogCIC) .AND. cVersEnvio == "2.5.00"
					//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
					aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
					aAdd(aLogsErr, OemToAnsi(STR0149))
					aAdd(aLogsErr, "" )
				EndIf
				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf
			EndIf
			aInfoPgto	:= {}
			aRetFer		:= {}
		ElseIf lRelat .And. !Empty(aLogCIC)
			aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(STR0149)} )//" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
		EndIf
	EndIf

	(cAliasQSRA)->(dbCloseArea())
	If lAglut
		(cAliasQMV)->(dbCloseArea())
	EndIf
	IF oTmpCPF <> NIL
		oTmpCPF:Delete()
		oTmpCPF := Nil
	ENDIF
	If oTmpEmp <> NIL
		oTmpEmp:Delete()
		oTmpEmp := Nil
	EndIf
Next nI

cFilAnt := cBkpFil

RestArea(aArea)
RestArea(aAreaSM0)

If !lRelat
	aAdd(aLogsPrc, OemToAnsi(STR0039) + cValToChar(aEmp_1210[1]) ) 	//"Trabalhadores com vínculo integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0040) + cValToChar(aEmp_1210[2]) )	//"Trabalhadores com vínculo não Integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0041) + cValToChar(aEmp_1210[3]) )	//"Trabalhadores sem vínculo integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0042) + cValToChar(aEmp_1210[4]) )	//"Trabalhadores sem vínculo não Integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0043) + cValToChar( aEmp_1210[1] + aEmp_1210[3] ) )	//"Total de registros integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0044) + cValToChar(aEmp_1210[2] + aEmp_1210[4]) )	//"Total de registros não integrados: "

	aAdd(aLogsPrc,"")
	aAdd(aLogsPrc, Replicate("-",132) )
	aAdd(aLogsPrc, OemToAnsi(STR0069)+": " +  SecsToTime(nHrInicio))				//Inicio Processamento:
	nHrFim 	:= SecsToTime(Seconds())
	aAdd(aLogsPrc,+OemToAnsi(STR0070)+":    " + nHrFim)							//Fim Processamento:
	aAdd(aLogsPrc,"")
	aAdd(aLogsPrc,OemToAnsi(STR0071+": " + SecsToTime(Seconds() - nHrInicio)))		//Duracao do Processamento
Else
	fGeraRelat( cCompete, lAfast )
EndIf

aInfoPgto	:= {}
aDetPgtoFl	:= {}
aRetFer		:= {}
aRetPgtoTot	:= {}
aRetPensao	:= {}
aLogCIC		:= {}
aDetPgtoAt 	:= {}
aPgtoAnt 	:= {}

Return .T.

/*/{Protheus.doc} fXml1210
Função que monta o XML do evento S-1210 através da estrutura abaixo dos arrays de controle:
v2.5
aInfoPgto <InfoPgto> -> Aglutina por <dtPgto> e <tpPgto>
	|
	->	aDetPgtoAt <detPgtoAnt> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> aPgtoAnt <infoPgtoAnt> -> Relaciona com aDetPgtoAt por <dtPgto> e <tpPgto>
			|
			-> aRetPensao <penAlim>	-> Relaciona com aPgtoAnt por <codRubr> + <dtPgto> e <tpPgto>
	|
	->	aDetPgtoFl <detPgtoFl> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> aRetPgtoTot <retPgtoTot>	-> Relaciona com aDetPgtoFl por <ideDmDev>
			|
			-> aRetPensao <penAlim>	-> Relaciona com aRetPgtoTot por <codRubr> + <ideDmDev>
	|
	->	aRetFer <detPgtoFer> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> Gera <detRubrFer> pelos itens de aRetFer[XXX, 7]
			|
			-> aRetPensao <penAlim>	-> Relaciona com detRubrFer por <codRubr> + <ideDmDev>
vS-1.0: aInfoPgto relaciona com detPgtoFl -> um grupo <infoPgto> por idmDev
@author Allyson
@since 19/06/2018
@version 1.0
@param cXML 		- String com o XML do evento S-1210
@param lRes 		-
@param lPgtRes 		-
@param aRGE1210		-
@param lAfast		- Indica se gera o evento para funcionários sem valores
@param cCompete		- Competência informada na geração do evento
@return lGerouXML	- Indica se foi gerado informações de pagamento no XML
/*/
Static Function fXml1210( cXML, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibXML, cIdXml, cVersMw, aErros, cPeriodo, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCpfBenef, nVlrDep )

Local cStatus		:= "-1"
Local cPaisExt		:= ""
Local lS1000		:= .T.
Local nCntInfPgFl	:= 0
Local nCntDetPgAt	:= 0
Local nCntDetPgTo	:= 0
Local nCntRetPgAt 	:= 0
Local nCntRetPgTo 	:= 0
Local nCntRetPens 	:= 0
Local nCntRetFer 	:= 0
Local nCntRubFer 	:= 0
Local lFirstInfo	:= .F.
Local lGerouInfo	:= .F.
Local lGerouDetP	:= .F.
Local lGerouXML		:= .F.
Local lGerarRGE		:= .F.

Local lNGeraInPgt 	:= .F.
Local nPosInfo		:= 1
Local nPosDet		:= 1

Default lRes 		:= .F.
Default lPgtRes		:= .T.
Default aRGE1210	:= {}
Default cCompete	:= ""
Default cRetfNew	:= "1"
Default cRecibXML	:= ""
Default cIdXml		:= ""
Default cVersMw		:= ""
Default aErros		:= {}
Default cFilEnv		:= ""
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc		:= ""
Default cCpfBenef	:= ""
Default nVlrDep		:= 0

If lMiddleware
	cXml += "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtPgtos/v" + cVersMw + "'>"
	fPosFil( cEmpAnt, cFilEnv )
	lS1000 := fVld1000( cPeriodo, @cStatus )
	If !lS1000
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
			Case cStatus == "1" // nao enviado para o governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
			Case cStatus == "2" // enviado e aguardando retorno do governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
			Case cStatus == "3" // enviado e retornado com erro
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
		EndCase
		Return .F.
	EndIf
	cXML += "<evtPgtos Id='" + cIdXml + "'>"//<evtPgtos>
	fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Iif(cVersEnvio >= "9.0", Nil, "1"), (SubStr(cPeriodo, 1, 4) + "-" + SubStr(cPeriodo, 5, 2)), 1, 1, "12" } )//<ideEvento>
	fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
	S1210A05(@cXml, {cCpfBenef}, .F.)
	If(cVersEnvio < "9.0", S1210A06(@cXml, {nVlrDep}, .T.), Nil)
EndIf

If cVersEnvio >= "9.1" .And. Len(aRGE1210) > 0
	cPaisExt := aRGE1210[1,1]
	lGerarRGE := (cPaisExt != "105")
EndIf

For nCntInfPgFl	:= 1 To Len(aInfoPgto)
	If cVersEnvio >= "9.0"
		If !( aInfoPgto[nCntInfPgFl, 2] $ "7|9" )
			For nCntDetPgto := 1 To Len(adetPgtoFl)
				If (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 ) .And. (!lRes .Or. (lRes .And. adetPgtoFl[nCntDetPgto, 4] != 0))
					S1210A30(@cXml, { aInfoPgto[nCntInfPgFl][1], aInfoPgto[nCntInfPgFl][2], adetPgtoFl[nCntDetPgto][1], adetPgtoFl[nCntDetPgto][2],adetPgtoFl[nCntDetPgto][4], If(lGerarRGE, cPaisExt, Nil) }, .F.) //infoPgto S-1.0~
					lGerouXML := .T.
					If lGerarRGE
						S1210A18(@cXml, { aRGE1210[1,2], aRGE1210[1,3], aRGE1210[1,12] }, .F.)//infoPgtoExt
						S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9], aRGE1210[1,10], aRGE1210[1,11] }, .T.)//endExt
						S1210F18(@cXml)//infoPgtoExt
					EndIf
					S1210F07(@cXml)//infoPgto
				EndIf
			Next nCntDetPgto
			For nCntRetFer := 1 To Len(aRetFer)
				If aInfoPgto[nCntInfPgFl, 1] == aRetFer[nCntRetFer, 6]
					S1210A30(@cXml, { aInfoPgto[nCntInfPgFl][1], aInfoPgto[nCntInfPgFl][2], aRetFer[nCntRetFer][12], aRetFer[nCntRetFer][13], aRetFer[nCntRetFer][5], If(lGerarRGE, cPaisExt, Nil) }, .F.)
					lGerouXML := .T.
					If lGerarRGE
						S1210A18(@cXml, { aRGE1210[1,2], aRGE1210[1,3], aRGE1210[1,12] }, .F.)//infoPgtoExt
						S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9], aRGE1210[1,10], aRGE1210[1,11] }, .T.)//endExt
						S1210F18(@cXml)//infoPgtoExt
					EndIf
					S1210F07(@cXml)//infoPgto
				EndIf
			Next
		EndIf
	Else
		lFirstInfo	:= .T.
		lGerouInfo	:= .F.
		If aInfoPgto[nCntInfPgFl, 2] == "9"//Pagamento Anterior
			For nCntDetPgAt	:= 1 To Len(aDetPgtoAt)
				If aDetPgtoAt[nCntDetPgAt, 3] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2] //infoPgto -> aDetPgtoAt | dtPgto + tpPgto
					If lFirstInfo
						lFirstInfo	:= .F.
						lGerouInfo	:= .T.
						lGerouDetP	:= .T.
						S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
						S1210A15(@cXml, aDetPgtoAt[nCntDetPgAt], .F., cVersEnvio)//detPgtoAnt
					EndIf
					For nCntRetPgAt	:= 1 To Len(aPgtoAnt)
						If aDetPgtoAt[nCntDetPgAt, 3] == aPgtoAnt[nCntRetPgAt, 7] .And. Iif( ValType(aPgtoAnt[nCntRetPgAt, 3]) == "N", Abs(aPgtoAnt[nCntRetPgAt, 3]) > 0, Abs(aPgtoAnt[nCntRetPgAt, 6]) > 0 )//aDetPgtoAt -> aPgtoAnt | dtPgto + tpPgto
							S1210A24(@cXml, aPgtoAnt[nCntRetPgAt], .F.)//infoPgtoAnt
							For nCntRetPens	:= 1 To Len(aRetPensao)
								If aPgtoAnt[nCntRetPgAt, 1] == aRetPensao[nCntRetPens, 1] .And. aPgtoAnt[nCntRetPgAt, 7] == aRetPensao[nCntRetPens, 6]//aPgtoAnt -> aRetPensao | codRubr + dtPgto + tpPgto
									S1210A10(@cXml, {aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2],aRetPensao[nCntRetPens, 3],aRetPensao[nCntRetPens, 5]}, .T.)//penAlim
								EndIf
							Next nCntRetPens
							S1210F24(@cXml)//infoPgtoAnt
						EndIf
					Next nCntRetPgAt
				EndIf
			Next nCntDetPgAt
			If lGerouDetP
				S1210F15(@cXml)//detPgtoAnt
			EndIf
		ElseIf aInfoPgto[nCntInfPgFl, 2] == "7"//Ferias
			lGerouInfo	:= .T.
			S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
			If Len(aRGE1210) > 0
				S1210A17(@cXml, .F.)//idePgtoExt
				S1210A18(@cXml, { aRGE1210[1,1], aRGE1210[1,2], aRGE1210[1,3] }, .T.)//idePais
				S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9] }, .T.)//endExt
			Endif
			For nCntRetFer := 1 To Len(aRetFer)
				If aInfoPgto[nCntInfPgFl, 1] == aRetFer[nCntRetFer, 6]//infoPgto -> aRetFer | dtPgto
					S1210A21(@cXml, { aRetFer[nCntRetFer, 1], aRetFer[nCntRetFer, 2], aRetFer[nCntRetFer, 3], aRetFer[nCntRetFer, 4], aRetFer[nCntRetFer, 5] }, .F.)//detPgtoFer
					For nCntRubFer := 1 To Len(aRetFer[nCntRetFer, 7])
						S1210A22(@cXml, aRetFer[nCntRetFer, 7, nCntRubFer], .F.)//detRubrFer
						If lMiddleware
							fValPred(aRetFer[nCntRetFer, 7, nCntRubFer, 7], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
						EndIf
						For nCntRetPens	:= 1 To Len(aRetPensao)
							If aRetFer[nCntRetFer, 7, nCntRubFer, 1] == aRetPensao[nCntRetPens, 1] .And. aRetFer[nCntRetFer, 2]+aRetFer[nCntRetFer, 6]+"7" == aRetPensao[nCntRetPens, 6]//aRetFer -> aRetPensao | codRubr + matricula + dtPgto + tpPgto
								S1210A23(@cXml, { aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2], aRetPensao[nCntRetPens, 3], aRetFer[nCntRetFer, 7, nCntRubFer, 6] }, .T.)//penAlim
							EndIf
						Next nCntRetPens
						S1210F22(@cXml)//detRubrFer
					Next nCntRubFer
					S1210F21(@cXml)//detPgtoFer
				EndIf
			Next nCntRetFer
		Else
			For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
				If (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 .Or. aScan( aRetPgtoTot, { |x| x[7] == adetPgtoFl[nCntDetPgTo, 2] } ) > 0 ) //infoPgto -> detPgtoFl | dtPgto + tpPgto
					If !lGerouInfo
						lGerouInfo	:= .T.
						lGerarRGE	:= .T.
						S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
					Endif
					S1210A08(@cXml, adetPgtoFl[nCntDetPgTo], .F., cVersEnvio)//detPgtoFl

					For nCntRetPgTo	:= 1 To Len(aRetPgtoTot)
						If adetPgtoFl[nCntDetPgTo, 2] == aRetPgtoTot[nCntRetPgTo, 7]//detPgtoFl -> retPgtoTot | ideDmDev
							S1210A09(@cXml, aRetPgtoTot[nCntRetPgTo], .F.)//retPgtoTot
							If lMiddleware
								fValPred(aRetPgtoTot[nCntRetPgTo, 8], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
							EndIf
							For nCntRetPens	:= 1 To Len(aRetPensao)
								If aRetPgtoTot[nCntRetPgTo, 1] == aRetPensao[nCntRetPens, 1] .And. aRetPgtoTot[nCntRetPgTo, 7] == aRetPensao[nCntRetPens, 6]//retPgtoTot -> aRetPensao | codRubr + ideDmDev
									S1210A10(@cXml, {aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2],aRetPensao[nCntRetPens, 3],aRetPensao[nCntRetPens, 5]}, .T.)//penAlim
								EndIf
							Next nCntRetPens
							S1210F09(@cXml)//retPgtoTot
						EndIf
					Next nCntRetPgTo

					S1210F08(@cXml)//detPgtoFl
					If Len(aRGE1210) > 0 .And. lGerarRGE
						S1210A17(@cXml, .F.)//idePgtoExt
						S1210A18(@cXml, { aRGE1210[1,1], aRGE1210[1,2], aRGE1210[1,3] }, .T.)//idePais
						S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9] }, .T.)//endExt
						lGerarRGE := .F.
					EndIf
				EndIf
			Next nCntDetPgTo
		EndIf
		If lGerouInfo
			lGerouXML := .T.
			If Len(aRGE1210) > 0
				S1210F17(@cXml)//idePgtoExt
			Endif
			S1210F07(@cXml)//infoPgto
		EndIf
	EndIf //2.5
Next nCntInfPgFl

IF lRes
	For nCntInfPgFl	:= 1 To Len(aInfoPgto)
		For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
			IF (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .AND. (LEN(adetPgtoFl[nCntDetPgTo][2]) > 0 .AND. Left(adetPgtoFl[nCntDetPgTo][2],1) == "R")

				IF adetPgtoFl[nCntDetPgTo, 4] == 0
					nPosInfo := nCntInfPgFl
					nPosDet := nCntDetPgTo
				ELSE
					lNGeraInPgt := .T.
				ENDIF

			ENDIF
		NEXT nCntDetPgTo
	NEXT nCntInfPgFl
ENDIF

IF (!lGerouXML .Or. (lRes .And. !lNGeraInPgt )) .And. lAfast .And. LEN(aInfoPgto) > 0 .And. LEN(adetPgtoFl) > 0 .And. lPgtRes

	adetPgtoFl[nPosDet,4] := 0
	If cVersEnvio >= "9.0"
		If !lGerouXML
			S1210A30(@cXml, { aInfoPgto[nPosInfo][1], aInfoPgto[nPosInfo][2], adetPgtoFl[nPosDet][1], adetPgtoFl[nPosDet][2],adetPgtoFl[nPosDet][4] }, .T.) //infoPgto S-1.0
		EndIf
	Else
		S1210A07(@cXml, aInfoPgto[nPosInfo], .F., cVersEnvio)//infoPgto
		S1210A08(@cXml, adetPgtoFl[nPosDet], .F., cVersEnvio)//detPgtoFl
		S1210F08(@cXml)//detPgtoFl
		S1210F07(@cXml)//infoPgto
	EndIf

	lGerouXML := .T.
ENDIF

S1210F05(@cXml)//ideBenef
S1210F02(@cXml)//evtPgtos
S1210F01(@cXml)//eSocial

If lMiddleware .And. lGerouXML .And. !Empty(aErros)
	lGerouXML := .F.
EndIf

Return lGerouXML

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBenefici   ³ autor ³ Marcia Moura        ³ Data ³ 02/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega array com informacoes do cadastro de beneficiarios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBenefic(cFilFun, cMatFun, dDataCalc, cCodVerba, nRdValor, cId, cPeriodo)
Local cAlias := ALIAS()
Local cMesAnoCalc := ""
Local nPos   := 0

Default cId	 := ""
Default cPeriodo := ""

//Para regime caixa, é necessário verificar o período do cálculo pois o pagamento ocorre no mês seguinte
If !Empty(cPeriodo)
	cMesAnoCalc := cPeriodo
Else
	cMesAnoCalc := AnoMes(dDataCalc)
EndIf

dbSelectArea( "SRQ" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com dados do cadastro de beneficiarios	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek( cFilFun + cMatFun )

	While SRQ->RQ_FILIAL + SRQ->RQ_MAT == cFilFun + cMatFun

		If SRQ->(FieldPos('RQ_DTINI')) > 0 .and. SRQ->(FieldPos('RQ_DTFIM')) > 0 .and.;
			(!Empty(SRQ->RQ_DTINI) .or. !Empty(SRQ->RQ_DTFIM))

			If (!Empty(SRQ->RQ_DTINI) .and. cMesAnoCalc < AnoMes(SRQ->RQ_DTINI)) .or.;
	 		   (!Empty(SRQ->RQ_DTFIM) .and. cMesAnoCalc > AnoMes(SRQ->RQ_DTFIM))
				dbSkip()
				Loop
			EndIf
		EndIf

		If cCodVerba $ (SRQ->RQ_VERBADT+"/"+SRQ->RQ_VERBFOL+"/"+SRQ->RQ_VERBFER+"/"+SRQ->RQ_VERB131+"/"+SRQ->RQ_VERB132+"/"+SRQ->RQ_VERBPLR+"/"+SRQ->RQ_VERBDFE+"/"+SRQ->RQ_VERBRRA)
			nPos := ascan(aRetPensao,{|X| X[1] == cCodVerba .And. X[2] == dToS( SRQ->RQ_NASC ) .And. X[3] == SRQ->RQ_NOME .And. X[4] == SRQ->RQ_CIC .And. X[6] == cId .And. x[7] == SRA->RA_CIC })
			If nPos == 0
				Aadd (aRetPensao, { cCodVerba, Iif( !lMiddleware .Or. !Empty(SRQ->RQ_NASC), dToS(SRQ->RQ_NASC), Nil), SRQ->RQ_NOME, SRQ->RQ_CIC, nRdValor, cId, SRA->RA_CIC, SRQ->RQ_ORDEM })
				If Empty(SRQ->RQ_CIC)
					aAdd(aLogCIC, SRQ->RQ_NOME)
				EndIf
			else
				aRetPensao[nPos,5] += nRdValor
			Endif

		EndIf

		dbSkip()
	EndDo
EndIf
dbSelectArea( cAlias )

Return .T.

/*/{Protheus.doc} fm036GetFer
Função responsável por pesquisar e gerar os dados de ferias nas tabelas SRH e SRR para geracao do evento S-1210
@Author.....: Marcelo Silveira
@Since......: 08/05/2018
@Version....: 1.0
@Param......: (char) - cFilFun - Filial do funcionario para a pesquisa nas tabelas SRH e SRR
@Param......: (char) - cMatFun - Matricula do funcionario para a pesquisa
@Param......: (char) - cDtPesqI - Data inicial do período para a pesquisa
@Param......: (char) - cDtPesqF - Data final do período para a pesquisa
@Param......: (char) - cCateg - Categoria do funcionario
@Param......: (array) - aVbFer - Array de referencia para armazenamento das verbas de ferias avaliadas
@Param......: (array) - aErros - Retorno de possíveis erros na geração do evento
@Param......: (char) - cFilPreTrf - Filial de origem do funcionario para posicionamento da SRV
@Return.....: (array) - aFer - Array de retorno com os dados de ferias do funcionario
/*/
Static Function fm036GetFer( cFilFun, cMatFun, cDtPesqI, cDtPesqF, cCateg, aVbFer, aErros, cFilPreTrf )

Local cAliasSRH	:= "QSRH"
Local cIdPdv	:= ""
Local nNumReg	:= 0
Local nPercRub	:= 0
Local nVbFer	:= 0
Local nPosFerPd	:= 0
Local aFer		:= {}
Local aFerPd	:= {}
Local lGeraCod	:= .F.
Local cIdTbRub	:= ""
Local lPrimIdT	:= .T.
Local cIdeRubr	:= ""

DEFAULT aErros	:= {}

If ( Select( cAliasSRH ) > 0 )
	( cAliasSRH )->( dbCloseArea() )
EndIf

If __oSt11 == Nil
	__oSt11 := FWPreparedStatement():New()
	cQrySt := "SELECT Count(*) AS NUMREG "
	cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
	cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
	cQrySt += 		"SRH.RH_MAT = ? AND "
	cQrySt += 		"SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
	cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
	cQrySt := ChangeQuery(cQrySt)
	__oSt11:SetQuery(cQrySt)
EndIf
__oSt11:SetString(1, cFilFun)
__oSt11:SetString(2, cMatFun)
cQrySt := __oSt11:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

nNumReg := (cAliasSRH)->NUMREG
( cAliasSRH )->( dbCloseArea() )

If nNumReg > 0
	If __oSt12 == Nil
		__oSt12 := FWPreparedStatement():New()
		cQrySt := "SELECT RH_FILIAL,RH_MAT,RH_PROCES,RH_PERIODO,RH_ROTEIR,RH_DTRECIB,RH_DFERIAS,RH_DATAINI,RH_DTRECIB "
		cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
		cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
		cQrySt += 		"SRH.RH_MAT = ? AND "
		cQrySt += 		"SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
		cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt12:SetQuery(cQrySt)
	EndIf
	__oSt12:SetString(1, cFilFun)
	__oSt12:SetString(2, cMatFun)
	cQrySt := __oSt12:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

	DbSelectArea("SRR")
	DbSetOrder(RetOrder("SRR","RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC"))

	While (cAliasSRH)->(!Eof())

		//			  codCateg,	matricula,	dtIniGoz,					qtDias,						vrLiq,	Data pagamento (recibo)
		aAdd( aFer, { cCateg, SRA->RA_CODUNIC, (cAliasSRH)->(RH_DATAINI), (cAliasSRH)->(RH_DFERIAS),	0,	(cAliasSRH)->(RH_DTRECIB), {}, SRA->RA_CIC, SRA->RA_FILIAL, SRA->RA_MAT + " - " + SRA->RA_CODUNIC, SRA->RA_NOMECMP, (cAliasSRH)->RH_PERIODO } )

		If SRR->( DbSeek( (cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->(RH_DATAINI) ) )

			While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA) == (cAliasSRH)->RH_FILIAL+(cAliasSRH)->RH_MAT+"F"+(cAliasSRH)->RH_DATAINI )

				nVbFer := aScan( aVbFer, { |x| x[1] == SRR->RR_PD })

				//Tratamento para evitar o uso da PosSrv devido desempenho
				PosSrv( SRR->RR_PD, cFilPreTrf )
				If nVbFer > 0
					nPercRub 	:= aVbFer[nVbFer,2]
					cIncIRF 	:= aVbFer[nVbFer,3]
					cIdPdv 		:= aVbFer[nVbFer,4]
				Else
					aAdd( aVbFer, { SRR->RR_PD, SRV->RV_PERC, SRV->RV_INCIRF, SRV->RV_CODFOL } )
					nPercRub 	:= SRV->RV_PERC - 100
					cIncIRF  	:= SRV->RV_INCIRF
					cIdPdv 		:= SRV->RV_CODFOL
				EndIf

				If cVersEnvio >= "9.0"
					If cIdPdv $ "102|0102" //Liquido de Ferias para gerar a Tag <vrLiq>
						aFer[Len(aFer),5] += SRR->RR_VALOR
					EndIf
				Else
					cIncIRF 	:= SubStr(cIncIRF, 1, 2)
					If !Empty(xFilial("SRV"))
						lGeraCod := .T.
					EndIf
					If lGeraCod
						cIdTbRub := SRV->RV_FILIAL
					Else
						If cVersEnvio >= "2.3"
							cIdTbRub := cEmpAnt
						Else
							cIdTbRub := ""
						EndIf
					EndIf

					If lMiddleware
						If lPrimIdT
							lPrimIdT  := .F.
							cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdTbRub )
							If Empty(cIdeRubr) .And. aScan(aErros, { |x| x == OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) }) == 0
								aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
							EndIf
						EndIf
						cIdTbRub := cIdeRubr
					EndIf

					nPosFerPd := aScan( aFerPd, { |x| x[1] == SRR->RR_PD} )
					If nPosFerPd > 0
						If cIncIRF $ "00|01|09|13|33|43|46|53|63|75|93" .And. !(cIdPdv $ "102|0102")
							aFerPd[nPosFerPd][3] += SRR->RR_HORAS
							aFerPd[nPosFerPd][6] += SRR->RR_VALOR

							If cIncIRF == "53"
								fBenefic( (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, stod((cAliasSRH)->RH_DTRECIB), SRR->RR_PD, SRR->RR_VALOR, SRA->RA_CODUNIC + (cAliasSRH)->RH_DTRECIB + "7" , cPeriodo)
							EndIf
						Endif

						If cIdPdv $ "102|0102"
							aFerPd[nPosFerPd][5] += SRR->RR_VALOR
						Endif
					Else
						If cIncIRF $ "00|01|09|13|33|43|46|53|63|75|93" .And. !(cIdPdv $ "102|0102")
							//				codRubr, 	ideTabRubr, 	qtdRubr, 			fatorRubr, 												vrUnit, 	  vrRubr
							aAdd( aFerPd, { SRR->RR_PD, cIdTbRub, SRR->RR_HORAS, If( nPercRub < 0, 0, Transform(nPercRub,"@E 999.99")), /*nao enviar*/,SRR->RR_VALOR, (SRV->RV_FILIAL+SRR->RR_PD) } )
							If cIncIRF == "53"
								fBenefic( (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, stod((cAliasSRH)->RH_DTRECIB), SRR->RR_PD, SRR->RR_VALOR, SRA->RA_CODUNIC + (cAliasSRH)->RH_DTRECIB + "7", cPeriodo )
							EndIf
						EndIf

						If cIdPdv $ "102|0102" //Liquido de Ferias para gerar a Tag <vrLiq>
							aFer[Len(aFer),5] += SRR->RR_VALOR
						EndIf
					Endif
				EndIf

				SRR->(DbSkip())
			EndDo

		EndIf

		If Len( aFerPd ) > 0
			aFer[Len(aFer)][7] := aClone(aFerPd)
			aFerPd := Array(0)
		EndIf

		(cAliasSRH)->(DbSkip())
	EndDo

EndIf

Return( aFer )

/*/{Protheus.doc} fGetRGE()
Função responsável por verificar histórico do contrato de trabalho
de residentes no exterior, gravação do array axxx com os dados da tabela RGE para o evento S-1210
@type function
@author Claudinei Soares
@since 22/11/2018
@version 1.1
@param cFilRGE		= Filial a ser pesquisada na tabela RGE
@param cMatRGE 		= Matrícula a ser pesquisada na tabela RGE
@param cCompete 	= Período informado na geração do evento servirá como base para buscar a vigência do contrato
@return aRGE, Array, Retorno da função, campos da RGE que serão enviados no XML
/*/

Function fGetRGE(cFilRGE, cMatRGE, cCompete)

Local cUltimoD		:= STRZERO(f_UltDia(CTOD( "01/"+SUBSTR(cCompete,1,2)+"/"+SUBSTR(cCompete,3,4) )),2)
Local cIndNif		:= ""

Local dIniContr		:= CTOD("//")
Local dFimContr		:= CTOD("//")
Local dCompIni 		:= CTOD( "01/"+SUBSTR(cCompete,1,2)+"/"+SUBSTR(cCompete,3,4) )
Local dCompFim 		:= CTOD( cUltimoD +"/"+ SUBSTR(cCompete,1,2) +"/"+ SUBSTR(cCompete,3,4) )

Local aArea			:= GetArea()
Local aItensRGE		:= {}

dbSelectArea("RGE")
RGE->( dbSetOrder(2) )
RGE->(dbGoTop())

If RGE->( dbSeek( cFilRGE + cMatRGE ) )
	While RGE->( !Eof() .And. RGE->RGE_FILIAL == cFilRGE .And. RGE->RGE_MAT == cMatRGE )
		dIniContr := RGE->RGE_DATAIN
		dFimContr := RGE->RGE_DATAFI

		If dIniContr <= dCompIni .And. (dFimContr >= dCompFim .Or. Empty(dFimContr))

			cIndNif := ( If(RGE->RGE_PAEXNI == "2", "3", IIF (RGE->RGE_BEDINI=="2","1",IF(RGE->RGE_BEDINI=="1","2",""))))

			aAdd(aItensRGE, {	Alltrim(RGE->RGE_CODPAI)	,;	//Código do Pais		- TAG <paisResidExt> do S-1210
								Alltrim(cIndNif)			,;	//Indicativo do NIF		- TAG <indNIF>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_CODNIF), Alltrim(RGE->RGE_CODNIF), Nil),;	//Código do NIF			- TAG <nifBenef>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_LOGRAD), Alltrim(RGE->RGE_LOGRAD), Nil),;	//Logradouro 			- TAG <endDscLograd>	do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_NUMERO), Alltrim(RGE->RGE_NUMERO), Nil),;	//Número do Endereço	- TAG <endNrLograd>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_COMPL),  Alltrim(RGE->RGE_COMPL),  Nil),;	//Complemento Endereço	- TAG <endComplem>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_BAIRRO), Alltrim(RGE->RGE_BAIRRO), Nil),;	//Bairro				- TAG <endBairro>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_CIDADE), Alltrim(RGE->RGE_CIDADE), Nil),;	//Cidade				- TAG <endCidade>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_ESTPRO), Alltrim(RGE->RGE_ESTPRO), Nil),;	//Estado			- TAG <endEstado>
								If(!lMiddleware .Or. !Empty(RGE->RGE_CODPOS), Alltrim(RGE->RGE_CODPOS), Nil),;	//Cód Postal (CEP)	- TAG <endCodPostal>
								If(!lMiddleware .Or. !Empty(RGE->RGE_TELEFO), Alltrim(RGE->RGE_TELEFO), Nil),;	//Telefone			- TAG <telef>
								AllTrim(RGE->RGE_FRMTRB) })														//Forma Tributação	- TAG <frmTribut>

			Exit
		Endif

		RGE->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return( aItensRGE )

/*/{Protheus.doc} fQtdeFolMV()
Função que verifica a quantidade matriculas no Periodo de acordo com o filtro por data de pagamento
@type function
@author allyson.mesashi
@since 27/02/2019
@version 1.0
@param cOpcTab		= Indica se considerada a tabela SRC
@param cFilProc		= Filiais para busca
@param cPeriodo		= Periodo de busca
@param cDtPesqI		= Data de pagamento inicial
@param cDtPesqF		= Data de pagamento final
@return nQtde		= Quantidade de matriculas no periodo
/*/
Static Function fQtdeFolMV(cOpcTab, cPeriodo, cDtPesqI, cDtPesqF)

Local aArea		:= GetArea()
Local cAliasMV	:= GetNextAlias()
Local cJoinRCxRY:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY:= FWJoinFilial( "SRD", "SRY" )
Local cQrySt	:= ""
Local nParam	:= 0
Local nQtde		:= 1

If __oSt17_2 == Nil
	__oSt17_2 := FWPreparedStatement():New()
	cQrySt := "SELECT SRA.RA_CIC, COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
	IF lTemGC .And. lTemEmp
		cQrySt += "WHERE SUBSTRING(SRA.RA_FILIAL, " + cValToChar(nIniEmp) + ", " + cValToChar(nTamEmp) + ") = ? AND "
	Else
		cQrySt += "WHERE "
	EndIf
	cQrySt += "SRA.RA_CIC >= ? AND SRA.RA_CIC <= ? "
	cQrySt += "AND SRA.RA_CC <> ' ' "
	If cOpcTab == "1"
		cQrySt += "AND EXISTS (SELECT DISTINCT SRC.RC_FILIAL, SRC.RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_PERIODO = ? AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
		cQrySt += "UNION "
		cQrySt += "SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	Else
		cQrySt += "AND EXISTS (SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	EndIf
	cQrySt += "AND SRA.D_E_L_E_T_ = ' ' "
	cQrySt += "GROUP BY SRA.RA_CIC "
	cQrySt := ChangeQuery(cQrySt)
	__oSt17_2:SetQuery(cQrySt)
EndIf
IF lTemGC .And. lTemEmp
	__oSt17_2:SetString(++nParam, SubString(SRA->RA_FILIAL, nIniEmp, nTamEmp) )
EndIf
__oSt17_2:SetString(++nParam, SRA->RA_CIC)
__oSt17_2:SetString(++nParam, SRA->RA_CIC)
__oSt17_2:SetString(++nParam, cPeriodo)
If cOpcTab == "1"
	__oSt17_2:SetString(++nParam, cPeriodo)
EndIf
cQrySt := __oSt17_2:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasMV,.T.,.T.)
nQtde := (cAliasMV)->CONT

(cAliasMV)->( dbCloseArea() )

RestArea(aArea)
Return nQtde

/*/{Protheus.doc} lTem546
//Checa se tem a verba de ID 0546
@author flavio.scorrea
@since 06/05/2019
/*/
Static Function lTem546(cFilFun,cMatFun,dData1,dData2,cPd)
Local lRet		:= .F.
Local cAliasTmp	:= GetNextAlias()

BeginSQL Alias cAliasTmp
	SELECT RC_PD
	FROM %Table:SRC% SRC
	WHERE RC_FILIAL = %Exp:cFilFun%
	AND RC_MAT = %Exp:cMatFun%
	AND RC_DATA BETWEEN %Exp:dData1% AND %Exp:dData2%
	AND SRC.%NotDel%
	AND RC_PD = %Exp:cPd%
	UNION
	SELECT RD_PD AS RC_PD
	FROM %Table:SRD% SRD
	WHERE RD_FILIAL = %Exp:cFilFun%
	AND RD_MAT = %Exp:cMatFun%
	AND RD_DATPGT BETWEEN %Exp:dData1% AND %Exp:dData2%
	AND SRD.%NotDel%
	AND RD_PD = %Exp:cPd%
EndSQL
lRet := !(cAliasTmp)->(Eof())
(cAliasTmp)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} fFerPreTrf
Verifica SRE para transferência posterior às férias no período da consulta à SRH, SRR
	@type	Function
	@author	isabel.noguti
	@since	13/01/2020
	@version 1.0
	@param	cSRHFil, char, Filial a ser consultada na SRH
	@param	cSRHMat, char, Matricula a ser consultada na SRH
	@param	cDtPesq, char, Data final do período
	@return	lRet, logic, Matrícula destino possui SRH no período, transferida da matrícula de origem
/*/
Static Function fFerPreTrf( cSRHFil, cSRHMat, cDtPesq )
	Local cAliasSRE	:= GetNextAlias()
	Local cQrySt	:= ""
	Local lRet		:= .F.

	If __oSt18 == Nil
		__oSt18 := FWPreparedStatement():New()
		cQrySt := "SELECT COUNT(*) QTD FROM "
		cQrySt += RetSqlName('SRH') + " SRH INNER JOIN " + RetSqlName('SRE') + " SRE ON SRH.RH_FILIAL = SRE.RE_FILIALP AND SRH.RH_MAT = SRE.RE_MATP "
		cQrySt += "WHERE SRE.RE_FILIALP = ? AND SRE.RE_MATP = ? "
		cQrySt += "AND SRH.RH_DTRECIB <= ? AND SRE.RE_DATA > ? "
		cQrySt += "AND (SRE.RE_FILIALD <> SRE.RE_FILIALP OR SRE.RE_MATD <> SRE.RE_MATP) "
		cQrySt += "AND SRH.D_E_L_E_T_ = ' ' AND SRE.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt18:SetQuery(cQrySt)
	EndIf
	__oSt18:SetString(1, cSRHFil)
	__oSt18:SetString(2, cSRHMat)
	__oSt18:SetString(3, cDtPesq)
	__oSt18:SetString(4, cDtPesq)
	cQrySt := __oSt18:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRE,.T.,.T.)

	If (cAliasSRE)->QTD > 0
		lRet := .T.
	EndIf
	(cAliasSRE)->(DbCloseArea())

	If !lRet .And. SRA->RA_SITFOLH == "D" .And. SRA->RA_RESCRAI $ "30|31"
		If __oSt19 == Nil
			__oSt19 := FWPreparedStatement():New()
			cQrySt := "SELECT SRE.RE_FILIALP, SRE.RE_MATP FROM "
			cQrySt += RetSqlName('SRH') + " SRH INNER JOIN " + RetSqlName('SRE') + " SRE ON SRH.RH_FILIAL = SRE.RE_FILIALP AND SRH.RH_MAT = SRE.RE_MATP "
			cQrySt += "WHERE SRE.RE_FILIALD = ? AND SRE.RE_MATD = ? "
			cQrySt += "AND SRH.RH_DTRECIB <= ? AND SRE.RE_DATA > ? "
			cQrySt += "AND SRH.D_E_L_E_T_ = ' ' AND SRE.D_E_L_E_T_ = ' ' "
			cQrySt += "ORDER BY SRE.RE_DATA DESC "
			cQrySt := ChangeQuery(cQrySt)
			__oSt19:SetQuery(cQrySt)
		EndIf
		__oSt19:SetString(1, cSRHFil)
		__oSt19:SetString(2, cSRHMat)
		__oSt19:SetString(3, cDtPesq)
		__oSt19:SetString(4, cDtPesq)
		cQrySt := __oSt19:getFixQuery()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRE,.T.,.T.)

		If !(cAliasSRE)->(Eof())
			cSRHFil := (cAliasSRE)->RE_FILIALP
			cSRHMat := (cAliasSRE)->RE_MATP
			Iif( nQtdeFol > 1, nQtdeFol --, nQtdeFol )
		EndIf
		(cAliasSRE)->(DbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} fGeraRelat
Função que gera o relatório em Excel
@author Allyson
@since 08/05/2020
@version 1.0
/*/
Static Function fGeraRelat(cCompete, lAfast)

Local cArquivo  	:= "RELATORIO_PERIODICOS_1210_"+cCompete+".xls"
Local cDefPath		:= GetSrvProfString( "StartPath", "\system\" )
Local cPath     	:= ""
Local nCntIdeBen	:= 0
Local nCntInfPgFl	:= 0
Local nCntDetPgTo	:= 0
Local nCntRetPgTo 	:= 0
Local nCntRetPens 	:= 0
Local nCntRetFer 	:= 0
Local nCntRubFer 	:= 0
Local nCntIncons	:= 0
Local oExcelApp 	:= Nil
Local oExcel

If !IsBlind()
	cPath	:= cGetFile( OemToAnsi(STR0083) + "|*.*", OemToAnsi(STR0084), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )//"Diretório"##"Selecione um diretório para a geração do relatório"
Else
	cPath	:= cDefPath
EndIf

oExcel  := FWMSExcel():New()

cAba1   := OemToAnsi(STR0181)//"Pagamentos"
cAba2   := OemToAnsi(STR0182)//"Rubricas"
cAba3   := OemToAnsi(STR0183)//"Pensão Aliment."
cAba4   := OemToAnsi(STR0185)//"Férias"
cAba5   := OemToAnsi(STR0186)//"Pensão Férias"
cAba6   := OemToAnsi(STR0090)//"Inconsistências"
cAba7   := OemToAnsi(STR0091)//"Legenda"

cTabela1 := OemToAnsi(STR0181)//"Pagamentos"
cTabela2 := OemToAnsi(STR0182)//"Rubricas"
cTabela3 := OemToAnsi(STR0184)//"Pensão Alimentícia"
cTabela4 := OemToAnsi(STR0185)//"Férias"
cTabela5 := OemToAnsi(STR0186)//"Pensão Férias"
cTabela6 := OemToAnsi(STR0090)//"Inconsistências"
cTabela7 := OemToAnsi(STR0091)//"Legenda"

// Criação de nova aba
oExcel:AddworkSheet(cAba1)
oExcel:AddworkSheet(cAba2)
oExcel:AddworkSheet(cAba3)
oExcel:AddworkSheet(cAba4)
oExcel:AddworkSheet(cAba5)
oExcel:AddworkSheet(cAba6)
oExcel:AddworkSheet(cAba7)

// Criação de tabela
oExcel:AddTable(cAba1, cTabela1)
oExcel:AddTable(cAba2, cTabela2)
oExcel:AddTable(cAba3, cTabela3)
oExcel:AddTable(cAba4, cTabela4)
oExcel:AddTable(cAba5, cTabela5)
oExcel:AddTable(cAba6, cTabela6)
oExcel:AddTable(cAba7, cTabela7)

// Criação de colunas
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0188) ,1,1,.F.)//"Tipo do Pagamento"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0189) ,1,1,.F.)//"Mês de referência"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0190) ,1,3,.F.)//"Valor líquido"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0194) ,1,3,.F.)//"Valor dependentes"

oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0188) ,1,1,.F.)//"Tipo do Pagamento"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0189) ,1,1,.F.)//"Mês de referência"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0191) ,1,1,.F.)//"Rubrica"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0192) ,1,1,.F.)//"Descrição"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0193) ,1,3,.F.)//"Valor"

oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0188) ,1,1,.F.)//"Tipo do Pagamento"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0189) ,1,1,.F.)//"Mês de referência"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0195) ,1,1,.F.)//"CPF do beneficiário"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0196) ,1,1,.F.)//"Data de Nascimento"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0197) ,1,1,.F.)//"Nome do beneficiário"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0198) ,1,3,.F.)//"Valor da pensão"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0199) ,1,1,.F.)//"Código GPE"

oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0200) ,1,1,.F.)//"Inicio Gozo"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0201) ,1,1,.F.)//"Qtde de dias"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0202) ,1,3,.F.)//"Valor líquido"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0191) ,1,1,.F.)//"Rubrica"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0192) ,1,1,.F.)//"Descrição"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0193) ,1,3,.F.)//"Valor"

oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0200) ,1,1,.F.)//"Início Gozo"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0201) ,1,1,.F.)//"Qtde de dias"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0195) ,1,1,.F.)//"CPF do beneficiário"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0196) ,1,1,.F.)//"Data de Nascimento"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0197) ,1,1,.F.)//"Nome do beneficiário"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0198) ,1,3,.F.)//"Valor da pensão"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0199) ,1,1,.F.)//"Código GPE"

oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0132) ,1,1,.F.)//"Inconsistências"

oExcel:AddColumn(cAba7, cTabela7, OemToAnsi(STR0133) ,1,1,.F.)//"Tipo"
oExcel:AddColumn(cAba7, cTabela7, OemToAnsi(STR0106) ,1,1,.F.)//"Valor"

//Geração das informações
For nCntIdeBen := 1 To Len(aIdeBenef)
	lGerouInfo := .F.
	For nCntInfPgFl	:= 1 To Len(aInfoPgto)
		If aInfoPgto[nCntInfPgFl, 5] == aIdeBenef[nCntIdeBen, 1]//aIdeBenef -> aInfoPgto | CPF
			If aInfoPgto[nCntInfPgFl, 2] == "7"//Ferias
				For nCntRetFer := 1 To Len(aRetFer)
					If aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 5] == aRetFer[nCntRetFer, 6] + aRetFer[nCntRetFer, 8]//infoPgto -> aRetFer | dtPgto + CPF
						lGerouInfo := .T.
						For nCntRubFer := 1 To Len(aRetFer[nCntRetFer, 7])
							oExcel:AddRow(cAba4, cTabela4, { aRetFer[nCntRetFer, 9], aRetFer[nCntRetFer, 10], aRetFer[nCntRetFer, 8], aRetFer[nCntRetFer, 11], aRetFer[nCntRetFer, 1], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), dToC(sToD(aRetFer[nCntRetFer, 3])), aRetFer[nCntRetFer, 4], aRetFer[nCntRetFer, 5], aRetFer[nCntRetFer, 7, nCntRubFer, 1], RetValSrv( aRetFer[nCntRetFer, 7, nCntRubFer, 1], aRetFer[nCntRetFer, 9], 'RV_DESC' ), Abs(aRetFer[nCntRetFer, 7, nCntRubFer, 6]) } )
							For nCntRetPens	:= 1 To Len(aRetPensao)
								If aRetFer[nCntRetFer, 8] == aRetPensao[nCntRetPens, 7] .And. aRetFer[nCntRetFer, 7, nCntRubFer, 1] == aRetPensao[nCntRetPens, 1] .And. aRetFer[nCntRetFer, 2]+aRetFer[nCntRetFer, 6]+"7" == aRetPensao[nCntRetPens, 6]//aRetFer -> aRetPensao | codRubr + matricula + dtPgto + tpPgto + CPF
									oExcel:AddRow(cAba5, cTabela5, { aRetFer[nCntRetFer, 9], aRetFer[nCntRetFer, 10], aRetFer[nCntRetFer, 8], aRetFer[nCntRetFer, 11], aRetFer[nCntRetFer, 1], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), dToC(sToD(aRetFer[nCntRetFer, 3])), aRetFer[nCntRetFer, 4], aRetPensao[nCntRetPens, 4], dToC(sToD(aRetPensao[nCntRetPens, 2])), aRetPensao[nCntRetPens, 3], Abs(aRetFer[nCntRetFer, 7, nCntRubFer, 6]), aRetPensao[nCntRetPens, 8] } )
								EndIf
							Next nCntRetPens
						Next nCntRubFer
					EndIf
				Next nCntRetFer
			Else
				For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
					If (adetPgtoFl[nCntDetPgTo, 7] + adetPgtoFl[nCntDetPgTo, 8] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2] + aInfoPgto[nCntInfPgFl, 5]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 .Or. aScan( aRetPgtoTot, { |x| x[7] == adetPgtoFl[nCntDetPgTo, 2] .And. x[9] == adetPgtoFl[nCntDetPgTo, 8] } ) > 0 ) //infoPgto -> detPgtoFl | dtPgto + tpPgto + CPF
						lGerouInfo := .T.
						oExcel:AddRow(cAba1, cTabela1, { adetPgtoFl[nCntDetPgTo, 11], adetPgtoFl[nCntDetPgTo, 9], adetPgtoFl[nCntDetPgTo, 8], adetPgtoFl[nCntDetPgTo, 10], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), adetPgtoFl[nCntDetPgTo, 2], aInfoPgto[nCntInfPgFl, 2], adetPgtoFl[nCntDetPgTo, 1], adetPgtoFl[nCntDetPgTo, 4], aIdeBenef[nCntIdeBen, 2] } )
						For nCntRetPgTo	:= 1 To Len(aRetPgtoTot)
							If adetPgtoFl[nCntDetPgTo, 2] + adetPgtoFl[nCntDetPgTo, 8] == aRetPgtoTot[nCntRetPgTo, 7] + aRetPgtoTot[nCntRetPgTo, 9]//detPgtoFl -> retPgtoTot | ideDmDev + CPF
								oExcel:AddRow(cAba2, cTabela2, { adetPgtoFl[nCntDetPgTo, 11], adetPgtoFl[nCntDetPgTo, 9], adetPgtoFl[nCntDetPgTo, 8], adetPgtoFl[nCntDetPgTo, 10], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), adetPgtoFl[nCntDetPgTo, 2], aInfoPgto[nCntInfPgFl, 2], adetPgtoFl[nCntDetPgTo, 1], aRetPgtoTot[nCntRetPgTo, 1], RetValSrv( aRetPgtoTot[nCntRetPgTo, 1], adetPgtoFl[nCntDetPgTo, 11], 'RV_DESC' ), Abs(aRetPgtoTot[nCntRetPgTo, 6]) } )
								For nCntRetPens	:= 1 To Len(aRetPensao)
									If aRetPgtoTot[nCntRetPgTo, 9] == aRetPensao[nCntRetPens, 7] .And. aRetPgtoTot[nCntRetPgTo, 1] == aRetPensao[nCntRetPens, 1] .And. aRetPgtoTot[nCntRetPgTo, 7] == aRetPensao[nCntRetPens, 6]//retPgtoTot -> aRetPensao | codRubr + ideDmDev + CPF
										oExcel:AddRow(cAba3, cTabela3, { adetPgtoFl[nCntDetPgTo, 11], adetPgtoFl[nCntDetPgTo, 9], adetPgtoFl[nCntDetPgTo, 8], adetPgtoFl[nCntDetPgTo, 10], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), adetPgtoFl[nCntDetPgTo, 2], aInfoPgto[nCntInfPgFl, 2], adetPgtoFl[nCntDetPgTo, 1], aRetPensao[nCntRetPens, 4], dToC(sToD(aRetPensao[nCntRetPens, 2])), aRetPensao[nCntRetPens, 3], Abs(aRetPgtoTot[nCntRetPgTo, 6]), aRetPensao[nCntRetPens, 8] } )
									EndIf
								Next nCntRetPens
							EndIf
						Next nCntRetPgTo
					EndIf
				Next nCntDetPgTo
			EndIf
		EndIf
	Next nCntInfPgFl
	If !lGerouInfo
		aAdd( aRelIncons, { aIdeBenef[nCntIdeBen, 3], aIdeBenef[nCntIdeBen, 1], OemToAnsi(STR0207) } )//"Funcionário foi desprezado pois está sem movimento"
	EndIf
Next nCntIdeBen

For nCntIncons := 1 To Len(aRelIncons)
	oExcel:AddRow(cAba6, cTabela6, { aRelIncons[nCntIncons, 1], aRelIncons[nCntIncons, 2], aRelIncons[nCntIncons, 3] } )
Next nCntIncons

oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0203), OemToAnsi(STR0204)+OemToAnsi(STR0205) } )//"Tipos de Pagamento"##'1-Pagamento de remuneração, conforme apurado em {dmDev} do S-1200 | 2-Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2299 | 3-Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2399 | 5-Pagamento de remuneração conforme apurado em {dmDev} do S-1202'##'6-Pagamento de Benefícios Previdenciários, conforme apurado em {dmDev} do S-1207 | 7-Recibo de férias | 9-Pagamento relativo a competências anteriores ao início de obrigatoriedade dos eventos periódicos para o contribuinte'

If !Empty(oExcel:aWorkSheet)
    oExcel:Activate() //ATIVA O EXCEL
    oExcel:GetXMLFile(cArquivo)

    If !IsBlind()
		CpyS2T(cDefPath+cArquivo, cPath)
		If ApOleClient( "MSExcel" )
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
			oExcelApp:SetVisible(.T.)
		EndIf
	EndIf
EndIf

Return

/*/
{Protheus.doc} fFilTransf
Função que busca por transferencias no periodo do 1210

@author		Silvio C. Stecca
@since		21/08/2020
@version	1.0

/*/
Static Function fFilTransf(cMatFun, cPer1210)

	Local cFilTransf	:= ""
	Local cArqSRE		:= GetNextAlias()

	BeginSQL Alias cArqSRE
		SELECT DISTINCT RE_FILIALD
		FROM %Table:SRE% SRE
		WHERE RE_MATP = %Exp:cMatFun%
		AND SUBSTRING(RE_DATA, 1, 6) = %Exp:cPer1210%
		AND SRE.%NotDel%
	EndSQL

	dbSelectArea(cArqSRE)

	If (cArqSRE)->(!EOF())
		While (cArqSRE)->(!EOF())

			cFilTransf := (cArqSRE)->RE_FILIALD

			dbSelectArea(cArqSRE)
			dbSkip()
		EndDo
	EndIf

	If Select(cArqSRE) > 0
		(cArqSRE)->(dbCloseArea())
	EndIf

Return cFilTransf

/*/{Protheus.doc} fGetDtPgto
Retorna a data de pagamento do cadastro de períodos
@type      	Static Function
@author lidio.oliveira
@since 05/01/2021
@version	1.0
@param cFilPesq		= Filial de Pesquisa
@param cProc		= Código do processo
@param cPeriodo		= Peíodo de pequisa no formato (AAAAMM)
@param cSemana		= Semana
@param cRot			= Roteiro para ser pesquisado
@return dDtPgto		= Data de pagamento no cadastro de períodos
/*/

Static Function fGetDtPgto(cFilPesq, cProc, cPeriodo, cSemana, cRot)

	Local aAreaRCH  := RCH->(GetArea())
	Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
	Local dDtPgto	:= cToD("//")

	Default cFilPesq	:= ""
	Default cProc		:= ""
	Default cPeriodo	:= ""
	Default cSemana		:= ""
	Default cRot		:= ""

	RCH->( dbSetOrder(nRchIndex) )

	If RCH->( dbSeek( xFilial("RCH", cFilPesq) + cProc + cPeriodo  + cSemana + cRot ) )
		dDtPgto := RCH->RCH_DTPAGO
	EndIf

	RestArea(aAreaRCH)

Return dDtPgto
/*/{Protheus.doc} fQtdS1200()
Função que verifica se houve movimento no Periodo
@type function
@author staguti
@since 24/06/2021
@version 1.0
@param cOpcTab		= Indica se considerada a tabela SRC
@param cFilProc		= Filiais para busca
@param cPeriodo		= Periodo de busca
@return nQtde		= Quantidade de matriculas no periodo
/*/
Static Function fQtdS1200(cOpcTab, cPeriodo)

Local aArea		:= GetArea()
Local cAliasPer	:= GetNextAlias()
Local cJoinRCxRY:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY:= FWJoinFilial( "SRD", "SRY" )
Local cQrySt	:= ""
Local nParam	:= 0
Local nQtde		:= 1

If __oSt17_1 == Nil
	__oSt17_1 := FWPreparedStatement():New()
	cQrySt := "SELECT SRA.RA_CIC, COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
	IF lTemGC .And. lTemEmp
		cQrySt += "WHERE SUBSTRING(SRA.RA_FILIAL, " + cValToChar(nIniEmp) + ", " + cValToChar(nTamEmp) + ") = ? AND "
	Else
		cQrySt += "WHERE "
	EndIf
	cQrySt += "SRA.RA_CIC >= ? AND SRA.RA_CIC <= ? "
	cQrySt += "AND SRA.RA_CC <> ' ' "
	If cOpcTab == "1"
		cQrySt += "AND EXISTS (SELECT DISTINCT SRC.RC_FILIAL, SRC.RC_MAT FROM " + RetSqlName('SRC')
		cQrySt += " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY
		cQrySt += " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
		cQrySt += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_PERIODO = ? AND  SRC.RC_TIPO2 != 'K' AND SRC.D_E_L_E_T_ = ' ' "
		cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
		cQrySt += "UNION "
		cQrySt += "SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY
		cQrySt += " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
		cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	Else
		cQrySt += "AND EXISTS (SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD')
		cQrySt += " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND "
		cQrySt += "SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
		cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	EndIf
	cQrySt += "AND SRA.D_E_L_E_T_ = ' ' "
	cQrySt += "GROUP BY SRA.RA_CIC "
	cQrySt := ChangeQuery(cQrySt)
	__oSt17_1:SetQuery(cQrySt)
EndIf
IF lTemGC .And. lTemEmp
	__oSt17_1:SetString(++nParam, SubString(SRA->RA_FILIAL, nIniEmp, nTamEmp) )
EndIf
__oSt17_1:SetString(++nParam, SRA->RA_CIC)
__oSt17_1:SetString(++nParam, SRA->RA_CIC)
__oSt17_1:SetString(++nParam, cPeriodo)
If cOpcTab == "1"
	__oSt17_1:SetString(++nParam, cPeriodo)
EndIf
cQrySt := __oSt17_1:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasPer,.T.,.T.)
nQtde := (cAliasPer)->CONT

(cAliasPer)->( dbCloseArea() )

RestArea(aArea)
Return nQtde

/*/{Protheus.doc} fGM36PFisica()
Função que verifica se a filial esta cadastrada como pessoa fisica
@type function
@author staguti
@since 10/08/2021
@version 1.0
@param cFilEnv= Filial Centralizadora
/*/
Function fGM36PFisica(cFilEnv)
	Local aArea			:= GetArea()
	Local lPFisica		:= .F.
	Local aInfo	 	 	:= {}

	Default cFilEnv	    := cFilAnt

	fInfo(@aInfo,cFilEnv)

	If Len(aInfo) > 0
		If aInfo[28] == 3 .Or. Alltrim(aInfo[12]) == "1"  //M0_TPINSC //M0_PRODRUR
			lPFisica := .T.
		Endif
	Endif

	RestArea(aArea)

Return lPFisica

/*/{Protheus.doc} fCatEstat
Verifica se a categoria e o Regime de Previdencia são de estatutarios
@author Silvia Taguti
@since 14/03/2022
/*/
Function fTpPgtoEst(cTpPrevi, cCatefd, cCompEst,cTpFolha)

Local lRet 		 := .F.
Local cPer1202		:= SubStr(cCompEst, 3, 4) + SubStr(cCompEst, 1, 2)
Local cCatS1200     := "101|102|103|104|105|106|107|108|111|"
Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'

Default cTpPrevi := ""
Default cCatefd  := ""
Default cCompEst := ""
Default cTpFolha := "1"


	If ((cTpPrevi= "2" .And. cCatefd $ "301|302|303|304|306|307|309|310|312|401|410") .Or. cCatefd $ "308|311|313" .OR.;
		(cCatefd == "305" .AND. If(cTpFolha=="1", cPer1202 >= "202204", SubStr(cPer1202, 1, 4) >= "2022")))
		lRet := .T.
	Endif

Return lRet

/*/{Protheus.doc} fCodCorr
Verifica se a verba é gerada a partir do código correspodente
@author lidio.oliveira
@since 12/09/2022
/*/
Static Function fCodCorr(cFilSRV, cPD)

	Local aArea		:= GetArea()
	Local aAreaSRV	:= GetArea("SRV")
	Local cAlias	:= GetNextAlias()
	Local lRet		:= .F.

	BeginSql alias cAlias
		SELECT SRV.RV_COD,SRV.RV_CODCORR
		FROM %table:SRV% SRV
		WHERE SRV.RV_FILIAL = %exp:cFilSRV%
			AND SRV.RV_CODCORR =  %exp:cPD%
			AND SRV.%NotDel%
	EndSql

	While (cAlias)->( !Eof() )
		lRet		:=.T.
		Exit
	EndDo

	(cAlias)->(DbCloseArea())

	RestArea( aAreaSRV )
	RestArea( aArea )

Return lRet
