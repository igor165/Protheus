#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio:= "2.4"

Static __oSt01_1		//Query para filtrar os roteiros que foram pagos por semana
Static __oSt01_2		//Query para filtrar os roteiros que foram pagos por data de pagamento
Static __oSt01_3		//Query para filtrar os roteiros que foram pagos quando houver pagamento complementar
Static __oSt01_4		//Query para filtrar os roteiros que foram pagos por benef�cio
Static __oSt02_1	 	//Query para filtrar as verbas de folha que foram pagas por semana
Static __oSt02_2	 	//Query para filtrar as verbas de folha que foram pagas por data de pagamento
Static __oSt02_3	 	//Query para filtrar os roteiros que foram pagos quando houver pagamento complementar
Static __oSt02_4		//Query para filtrar as verbas do roteiro BOP por benef�cio
Static __oSt03		 	//Query para filtrar roteiro 132 anterior a dezembro
Static __oSt04		 	//Query para filtrar o c�lculo de plano de sa�de
Static __oSt07		 	//Query para verificar os dias trabalhados do contrato intermitente
Static __oSt08		 	//Query para verificar as convoca��es do contrato intermitente
Static __oSt09		 	//Query para filtrar as verbas calculadas no diss�dio
Static __oSt10		 	//Query para verificar os lan�amentos de m�ltiplos v�nculos
Static __oSt13		 	//Query para filtrar os registros da C9V do CPF que est� em processamento
Static __oSt14		 	//Query para filtrar os registros da SRA do CPF que est� em processamento
Static __oSt15		 	//Query para verificar se houve retifica��o de afastamento no per�odo
Static __oSt16		 	//Query para verificar aux�lio doen�a (Verba ID 1420) pago em determinado intervalo
Static __oSt17		 	//Query para verificar quais per�odos foram calculados no diss�dio
Static __oSt18		 	//Query para verificar se h� f�rias calculadas no periodo
Static __oSt19		 	//Query para filtrar as verbas de f�rias calculadas com pagamento no per�odo
Static aTabS037		:= {}	//Tabela S037
Static lR8DatAlt	:= SR8->(ColumnPos('R8_DATALT')) > 0
Static lParcial		:= .F.
Static lGeraRat  	:= SuperGetMv("MV_RATESOC",, .T.)
Static lVerRJ5		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .T.) .And. !lParcial .And. lGeraRat)
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .And. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F. )
Static oHash

/*/{Protheus.doc} GPEM036A
@Author   Alessandro Santos
@Since    18/03/2019
@Version  1.0
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1200
/*/
Function GPEM036A()
Return()

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fNew1200()     �Autor�  Marcia Moura     � Data �10/07/2014�
�����������������������������������������������������������������������Ĵ
�Descri��o �Gera o registro de Folha                             �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM034                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �Nil															�
�����������������������������������������������������������������������Ĵ
�Parametros�Nil															�
������������������������������������������������������������������������� */

Function fNew1200(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lRelat, aLogsErr, aLogsPrc, lS1202, lS1207)

Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())

Local aFilInTaf 	:= {}
Local aIncons		:= {}
Local cFilEnv 		:= ""
Local nI			:= 0
Local aFilInativ	:= {}
Local cFilInativ	:= ""

Private cSRDRot	  	:= GetNextAlias()
Private cSRDAlias 	:= GetNextAlias()
Private cSRDAut		:= GetNextAlias()
Private cSRDTabRJ	:= GetNextAlias()
Private cSRDTabRH	:= GetNextAlias()
Private cSRAAlias 	:= GetNextAlias()
Private cSRAAliasC 	:= GetNextAlias()
Private cSRAAliasMV := GetNextAlias()
Private cSRACPF 	:= "QRYSRACPF"
Private cSRAEmp 	:= "QRYSRAEMP"
Private oTmpCPF		:= Nil
Private oTmpEmp		:= Nil
Private oTmpTable	:= Nil
Private oTmpTabl2	:= Nil
Private oTmpTabRJ	:= Nil
Private oTmpTabRH	:= Nil
Private oTmpFER		:= Nil
Private cOldCic 	:= ''

Private aEvtRemun 	:= {}
Private aIdeEven 	:= {}
Private aIdeTrabal 	:= {}
Private aProcJud 	:= {}
Private aInfMV	 	:= {}
Private aRemOutEmp 	:= {}
Private aInfCompl 	:= {}
Private aInfInter 	:= {}
Private aDmDev	 	:= {}
Private aInfPerApur	:= {}
Private aEstLotApur	:= {}
Private aRemPerApur	:= {}
Private aItRemApur 	:= {}
Private aInfSauCole	:= {}
Private aDetOper 	:= {}
Private aDetPlano 	:= {}
Private aInfAgNoc 	:= {}
Private aInfTrabInt	:= {}
Private aInfPerAnt 	:= {}
Private aIdeADCAnt 	:= {}
Private aIdePer 	:= {}
Private aEstLotAnt 	:= {}
Private aRemPerAnt 	:= {}
Private aItRemAnt 	:= {}
Private aAgNocAnt 	:= {}
Private aComplCont 	:= {}
Private aRelIncons 	:= {}
Private aFornPLA	:= {}
Private aFuncDem  	:= {}
Private aSucVinc	:= {}
Private aDiasConv	:= {}
Private lFornPLA	:= .T.
Private lTemRJJ		:= ChkFile("RJJ")

Private cXml      := ""
Private lUnicaTag := .T.
Private cCabPart1 := ""
Private cCabRAZ   := ""
Private cCabPart2 := ""

Private aCC      := {}
Private aEstb    := {}
Private aSM0     := FWLoadSM0(.T.)

Private cFilLocCTT 	:= ''
Private cQrySt	   	:= ""
Private lRobo		:= IsBlind()

Private nDecHor		:= TamSX3("RD_HORAS")[2]
Private nDecVal		:= TamSX3("RD_VALOR")[2]
Private nTamCC		:= TamSX3("RD_CC")[1]
Private nTamHor		:= TamSX3("RD_HORAS")[1]
Private nTamMat		:= TamSX3("RD_MAT")[1]
Private nTamRot		:= TamSX3("RD_ROTEIR")[1]
Private nTamVal		:= TamSX3("RD_VALOR")[1]
Private nTamVb		:= TamSX3("RD_PD")[1]
Private nTamConvc	:= TamSX3("V7_CONVC")[1]
Private nTamNumId	:= TamSX3("RD_NUMID")[1]
Private nTamSem		:= TamSX3("RD_SEMANA")[1]

Private cLayoutGC	:= ""
Private lTemEmp		:= .F.
Private lTemGC		:= .F.
Private nIniEmp 	:= 0
Private nTamEmp		:= 0
Private cEvento		:= "S1200"
Private cTpFolha	:= IIF(lIndic13, "2", "1") //Tipo de folha 1 = Mensal / 2 = 13 Salario

Default lS1202		:= .F.
Default lS1207		:= .F.

If !lMiddleware
	cLayoutGC	:= FWSM0Layout(cEmpAnt)
	lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
	lTemGC		:= fIsCorpManage( FWGrpCompany() )
	nIniEmp 	:= At("E", cLayoutGC)
	nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))
	fGp23Cons(aFilInTaf, aArrayFil,@cFilEnv, @aFilInativ)

	If Empty(cFilEnv)
		cFilEnv:= cFilAnt
	EndIf

	If Empty(aFilInTaf)
		MsgAlert( STR0065 + CRLF + STR0066 )//"N�o foi encontrada a filial de refer�ncia do TAF para a importa��o das informa��es."##"� necess�rio que seja inclu�do no cadastro de complemento de empresa a filial de destino para a importa��o das informa��es."
		Return .F.
	EndIf

	If LEN(aFilInativ) > 0

		FOR nI := 1 TO LEN(aFilInativ)
			cFilInativ += aFilInativ[nI] + ", "
		NEXT nI

		MsgAlert("A(s) filial(is) " + cFilInativ + STR0072)
		Return .F.
	EndIf
EndIf

If lRobo
	Processa({|lEnd| Faz1200(cCompete, cTpFolha, aArrayFil, aFilInTaf, cFilEnv, aIncons, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lRelat, .F., aLogsErr, aLogsPrc, lS1202, lS1207)})
Else
	Proc2BarGauge( {|lEnd| Faz1200(cCompete, cTpFolha, aArrayFil, aFilInTaf, cFilEnv, aIncons, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lRelat, .T., aLogsErr, aLogsPrc, lS1202, lS1207)}, If(!lS1202,If(!lS1207,"Evento S-1200","Evento S-1207"), "Evento S-1202"), NIL , NIL , .T. , .T. , .F. , .F. )
EndIf

__oSt01_1 	:= Nil
__oSt01_2 	:= Nil
__oSt01_3 	:= Nil
__oSt01_4 	:= Nil
__oSt02_1 	:= Nil
__oSt02_2 	:= Nil
__oSt02_3 	:= Nil
__oSt02_4 	:= Nil
__oSt03 	:= Nil
__oSt04 	:= Nil
__oSt07 	:= Nil
__oSt08 	:= Nil
__oSt09 	:= Nil
__oSt10 	:= Nil
__oSt13 	:= Nil
__oSt14 	:= Nil
__oSt15 	:= Nil
__oSt16 	:= Nil
__oSt17 	:= Nil
aTabS037	:= Nil

If ValType(oHash) == "O"
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil
EndIf
RestArea(aArea)
RestArea(aAreaSM0)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Faz1200       �Autor �Oswaldo Leite    � Data �  01/06/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria layout 1200 do e-social                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Faz1200(cCompete, cTpFolha, aArrayFil, aFilInTaf, cFilEnv, aIncons, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lRelat, lNewProgres, aLogsErr, aLogsPrc, lS1202 , lS1207)
Local cQuery        := ''
Local cQueryCont    := ''
Local cQueryMV      := ''
Local nI            := 0
Local nJ            := 0
Local nX            := 0
Local cOldCic       := ''
Local cOldNome      := ''
Local cOldProces	:= ""
Local cCPF			:= ""
Local cStatus       := " "
Local cStatC91      := "-1"
Local cRecibo       := ""
Local cPerApur		:= ""
Local lAbriuXml     := .F.
Local cBkpFil       := cFilAnt
Local nOpc          := 3
Local cMsgErro      := ""
Local cTrabSemVinc  := "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'
Local lTrabSemVinc  := .F.
Local cBkpFilEnv	:= ""
Local cVersaoEnv	:= ""
Local cFilQry		:= ""
Local cFilRes		:= ""
Local cMatRes		:= ""
Local cOldFil		:= ""
Local cOldFilEnv	:= ""
Local cArqTemp		:= ""
Local cIndTemp		:= ""
Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
Local cTpRes		:= ""
Local cPerResCmp	:= ""
Local lComplTSV		:= .F.
Local lGeraRes		:= .F.
Local aResCompl		:= {}
Local aAreaC9V		:= {}
Local aLogDiss		:= {}
Local aContdmDev	:= {}
Local aStatC91      := {}
Local cOldOcorr     := ""
Local cUltCic     	:= ""
Local aEmp_1200		:= {0, 0, 0, 0} //1 - Integrados TCV; 2 - Nao Integrados TCV; 3 - Integrados TSV; 4 - Nao Integrados TSV
Local lPagAuto		:= SuperGetMV("MV_PERAUT", Nil, .F.)
Local nVldOpcoes	:= 0
Local lTem132		:= .F.
Local cDtIni 		:= SubStr(cCompete,3,4)+"01"
Local cDtFim 		:= SubStr(cCompete,3,4)+"12"
Local cJoinRCxRY	:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY	:= FWJoinFilial( "SRD", "SRY" )
Local nCont			:= 0
Local l2300MV  		:= .F.
Local lOut2300 		:= .F.
Local lExiste2300	:= .F.
Local lComplCont	:= .F.
Local lCPFDepOk		:= .T.
Local lRAZOk		:= .T.
Local lRJ5Ok		:= .T.
Local aDepAgreg		:= {}
Local aRJ5CC		:= {}
Local cOptSimp		:= ""
Local aTabInss		:= {}
Local cEmp			:= ""
Local cEmpOld		:= ""
Local cTafKey		:= ""
Local cNomeTCPF		:= ""
Local cNomeTEmp		:= ""
Local lAfastado		:= .F.
Local nPosEmp		:= 0
Local aCpfDesp		:= {}
Local aFilInAux 	:= {}
Local lFilAux		:= .F.
Local lDissMV  		:= .F.
Local cPer1200		:= SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)
Local lRetXml  		:= .F.

Local nHrInicio
Local nHrFim

Local nAuxTot		:= 0
Local lGera1200		:= .T.

Local lPgtCompl		:= .F.
Local aPeriodo		:= {}
Local nContData		:= 0
Local aCodHash		:= {}

Local lAdmPubl	 	:= .F.
Local aInfoC	 	:= {}
Local aDados	 	:= {}
Local aErros	 	:= {}
Local cTpInsc		:= ""
Local cNrInsc		:= ""
Local cChaveMid	 	:= ""
Local cStatMid   	:= "-1"
Local cStatNew		:= ""
Local cOperNew		:= ""
Local cRetfNew		:= ""
Local cRecibAnt		:= ""
Local cKeyMid		:= ""
Local cIdXml		:= ""
Local lNovoRJE		:= .T.
Local nRecEvt		:= 0
Local cVersMw		:= ""
Local cGpeAmbe		:= ""
Local cTimeIni		:= Time()
Local nTotRec		:= 0
Local aLogPeric		:= {}
Local nRegPeric		:= 0
Local aArrayFil2	:= {}
Local nZ			:= 0
Local nW			:= 0
Local lAjudaComp	:= .F.
Local dDtPgto		:= cToD("//")
Local cKeyProc		:= ""
Local lTemFer		:= .F.
Local cPdFer		:= ""
Local nF			:= 0
Local nY			:= 0
Local aColumns		:= {}
Local cTSV			:= fCatTrabEFD("TSV")
Local nNumFer		:= 0
Local cNumFer		:= ""
Local cDtPgtoFer	:= ""
Local cCatS1202	    := "308|311|313"
Local nNumBen		:= 0
Local cNumBen		:= ""
Local cCodBen		:= ""
Local cEvtLog		:= ""
Local cExcLog		:= ""
Local cBolsistas	:= fCatTrabEFD("BOL")
Local cFilVal       := ""

Private lDtPgto		:= .F.
Private aDadosRAZ   := {}
Private lVerRHH		:= SuperGetMV("MV_ESOCDIS", Nil, .T. )
Private nQtdeFol	:= 1
Private aCodFol		:= {}
Private aCodDmDev	:= {}
Private lMsgDiss	:= .F.
Private aDadosFer	:= {}
Private lGeraMat 	:= .F.
Private nQtdeMV		:= 1
Private lGera1202   := .F.
Private lGera1207   := .F.

Default aCheck		:= {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .T., .T., .F., .F.}
Default cOpcTab		:= "0"
Default cCPFDe		:= ""
Default cCPFAte		:= ""
Default cExpFiltro	:= ""
Default lNewProgres	:= .F.
Default lS1202		:= .F.
Default lS1207		:= .F.
lGera1202 := lS1202
lGera1207 := lS1207

If lGera1207
	cEvento := "S1207"
	cEvtLog := OemToAnsi(STR0219) //"Registro S-1207 do Benefici�rio:"
	cExcLog := OemToAnsi(STR0220) //"Registro de exclus�o S-1207 do Benefici�rio:"
ElseIf lGera1202
	cEvento := "S1202"
	cEvtLog := OemToAnsi(STR0218) //"Registro S-1202 do Funcion�rio:"
	cExcLog := OemToAnsi(STR0217) //"Registro de exclus�o S-1202 do Funcion�rio:"
Else
	cEvtLog := OemToAnsi(STR0021) //"Registro S-1200 do Funcion�rio:"
	cExcLog := OemToAnsi(STR0047) //"Registro de exclus�o S-1200 do Funcion�rio:"
EndIf

lAfastado := aCheck[12]

cArqTemp := CriaTrab(NIL,.F.)
cIndTemp := "RV_FILIAL+RV_CODCOM_"
IndRegua( "SRV", cArqTemp, cIndTemp )

If FindFunction("fVersEsoc")
	fVersEsoc( "S2300", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersaoEnv, Nil, @cVersMw, , @cGpeAmbe )
Else
	cVersaoEnv := '2.2'
EndIf

If SRA->(ColumnPos("RA_DESCEP")) > 0 .And. cVersaoEnv >= "9.0.00"
	lGeraMat := .T.
EndIf

aCC		:= fGM23CTT()//extrai lista de c.custo da filial conectada "xfilial(CTT)" ...
aEstb	:= fGM23SM0(,.T.) //extrai lista de filiais da SM0

//Hora Inicial
nHrInicio := Seconds()

If lAglut
	If !lMiddleware
		For nI := 1 To Len(aFilInTaf)
			For nX := 1 To Len(aFilInTaf[nI, 3])
				cFilQry += aFilInTaf[nI, 3, nX]
			Next nX
		Next nI
	Else
		For nI := 1 To Len(aArrayFil)
			cFilQry += aArrayFil[nI]
		Next nI
	EndIf
	cFilQry := fSqlIn(cFilQry, FwSizeFilial())
EndIf

If !Fp_CodFol(@aCodFol, xFilial('SRV'))
	Return(.F.)
EndIf
oHash := HMNew()
HMSet( oHash,xFilial('SRV'),aClone(aCodFol) )

//Grava quais s�o as ra�zes de CNPJ's selecionadas para processamento
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

	//Query para filtrar os CPFs de acordo com o filtro da rotina
	fQryCPF(cFilQry, aFilInTaf, nI, cCPFDe, cCPFAte, cExpFiltro, .T., cPer1200, aArrayFil)
	cNomeTCPF := oTmpCPF:GetRealName()

	If lAglut
		//Query para filtrar os CNPJs de acordo com o filtro da rotina
		fQryEmp()
		cNomeTEmp := oTmpEmp:GetRealName()
	EndIf

	//Query para filtrar as matriculas que possuem c�lculo da folha de acordo com os CPFs filtrados
	cQuery := "SELECT SRA.RA_CIC, SRA.RA_NOME, SRA.RA_FILIAL, SRA.RA_PROCES, SRA.RA_MAT, SRA.RA_CATFUNC, SRA.RA_DEMISSA,  SRA.RA_PIS, SRA.RA_CATEFD, SRA.RA_TPPREVI, SRA.RA_EAPOSEN "
	If lAglut
		cQuery += ", EMP.CNPJ as CNPJ "
	EndIf
	cQuery += "FROM " + RetSqlName('SRA') + " SRA "
	If lAglut
		cQuery += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
		cQuery += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
	Else
		If !lMiddleware
			cQuery += "WHERE SRA.RA_FILIAL IN (" + StrTran(fGM23Fil(aFilInTaf, nI)[1], "%", "") + ")"
		Else
			cQuery += "WHERE SRA.RA_FILIAL IN ('" + aArrayFil[nI] + "')"
		EndIf
		cQuery += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
	EndIf
	cQuery += "AND SRA.RA_CC <> ' ' "
	If lGera1207
		cQuery += "AND ( SRA.RA_CATFUNC = '9' OR SRA.RA_EAPOSEN = '1' ) "
	EndIf
	If !lExcLote
		cQuery += "AND EXISTS ("
		If cOpcTab == "1"
			cQuery += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT "
			cQuery += "FROM " + RetSqlName('SRC') + " SRC "
			cQuery += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
			cQuery += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND "
			cQuery += 	"SRC.RC_MAT = SRA.RA_MAT AND "
			If lGera1207
				cQuery += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
				cQuery += 	"SRY.RY_TIPO = 'O' AND "
			Else
				If cTpFolha == "1"
					cQuery += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
				Else
					cQuery += 	"SRC.RC_PERIODO >= '" + cDtIni + "' AND "
					cQuery += 	"SRC.RC_PERIODO <= '" + cDtFim + "' AND "
					cQuery += 	"SRY.RY_TIPO = '6' AND "
				EndIf
			EndIf
			cQuery += 	"SRC.D_E_L_E_T_ = ' ' AND "
			cQuery += 	"SRY.RY_TIPO != 'K' "
			cQuery += "GROUP BY SRC.RC_FILIAL,SRC.RC_MAT "
			cQuery += "UNION "
		EndIf
		cQuery += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT "
		cQuery += "FROM " + RetSqlName('SRD') + " SRD "
		cQuery += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
		cQuery += "WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND "
		cQuery += 	"SRD.RD_MAT = SRA.RA_MAT AND "
		If !lGera1207
			If cTpFolha == "1"
				cQuery += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
			Else
				cQuery += 	"SRD.RD_PERIODO >= '" + cDtIni + "' AND "
				cQuery += 	"SRD.RD_PERIODO <= '" + cDtFim + "' AND "
				cQuery += 	"SRY.RY_TIPO = '6' AND "
			EndIf
		else
			If cTpFolha == "1"
				cQuery += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
				cQuery += 	"SRY.RY_TIPO = 'O' AND "
			Endif
		Endif
		cQuery += 	"SRD.RD_EMPRESA = '  ' AND "
		cQuery += 	"SRD.D_E_L_E_T_ = ' ' AND "
		cQuery += 	"SRY.RY_TIPO != 'K' "
		cQuery += "GROUP BY SRD.RD_FILIAL, SRD.RD_MAT) "
	EndIf
	cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
	If !lAglut
		cQuery += "ORDER BY SRA.RA_CIC, SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME"
	Else
		cQuery += "ORDER BY SRA.RA_CIC, CNPJ"
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSRAAlias,.T.,.T.)

	If !lRobo
		//Query para filtrar as matriculas que possuem c�lculo da folha de acordo com os CPFs filtrados
		cQueryCont := "SELECT COUNT(*) as TOTAL "
		cQueryCont += "FROM " + RetSqlName('SRA') + " SRA "
		If lAglut
			cQueryCont += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
			cQueryCont += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		Else
			If !lMiddleware
				cQueryCont += "WHERE SRA.RA_FILIAL IN (" + StrTran(fGM23Fil(aFilInTaf, nI)[1], "%", "") + ")"
			Else
				cQueryCont += "WHERE SRA.RA_FILIAL IN ('" + aArrayFil[nI] + "')"
			EndIf
			cQueryCont += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		EndIf
		cQueryCont += "AND SRA.RA_CC <> ' ' "
		If lGera1207
			cQuery += "AND ( SRA.RA_CATFUNC = '9' OR SRA.RA_EAPOSEN = '1' ) "
		Else
			cQuery += "AND ( SRA.RA_CATFUNC <> '9' AND SRA.RA_EAPOSEN <> '1' ) "
		EndIf
		If !lExcLote
			cQueryCont += "AND EXISTS ("
			If cOpcTab == "1"
				cQueryCont += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT "
				cQueryCont += "FROM " + RetSqlName('SRC') + " SRC "
				cQueryCont += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
				cQueryCont += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND "
				cQueryCont += 	"SRC.RC_MAT = SRA.RA_MAT AND "
				If !lGera1207
					If cTpFolha == "1"
						cQueryCont += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
					Else
						cQueryCont += 	"SRC.RC_PERIODO >= '" + cDtIni + "' AND "
						cQueryCont += 	"SRC.RC_PERIODO <= '" + cDtFim + "' AND "
						cQueryCont += 	"SRY.RY_TIPO = '6' AND "
					EndIf
				Else
					If cTpFolha == "1"
						cQueryCont += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
						cQueryCont += 	"SRY.RY_TIPO = 'O' AND "
					Endif
				Endif
				cQueryCont += 	"SRC.D_E_L_E_T_ = ' ' AND "
				cQueryCont += 	"SRY.RY_TIPO != 'K' "
				cQueryCont += "GROUP BY SRC.RC_FILIAL,SRC.RC_MAT "
				cQueryCont += "UNION "
			EndIf
			cQueryCont += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT "
			cQueryCont += "FROM " + RetSqlName('SRD') + " SRD "
			cQueryCont += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
			cQueryCont += "WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND "
			cQueryCont += 	"SRD.RD_MAT = SRA.RA_MAT AND "
			If !lGera1207
				If cTpFolha == "1"
					cQueryCont += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
				Else
					cQueryCont += 	"SRD.RD_PERIODO >= '" + cDtIni + "' AND "
					cQueryCont += 	"SRD.RD_PERIODO <= '" + cDtFim + "' AND "
					cQueryCont += 	"SRY.RY_TIPO = '6' AND "
				EndIf
			else
				If cTpFolha == "1"
					cQueryCont += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
					cQueryCont += 	"SRY.RY_TIPO = 'O' AND "
				Endif
			Endif
			cQueryCont += 	"SRD.RD_EMPRESA = '  ' AND "
			cQueryCont += 	"SRD.D_E_L_E_T_ = ' ' AND "
			cQueryCont += 	"SRY.RY_TIPO != 'K' "
			cQueryCont += "GROUP BY SRD.RD_FILIAL, SRD.RD_MAT) "
		EndIf
		cQueryCont += "AND SRA.D_E_L_E_T_ = ' ' "
		cQueryCont := ChangeQuery(cQueryCont)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCont),	cSRAAliasC,.T.,.T.)

		If (cSRAAliasC)->( !EoF() )
			nTotRec := (cSRAAliasC)->TOTAL
			If !lNewProgres
				GPProcRegua(nTotRec)
			Else
				BarGauge1Set(nTotRec)
			EndIf
		EndIf
		(cSRAAliasC)->( dbCloseArea() )
	EndIf

	If lAglut
		//Query para verificar quantas matriculas de um mesmo CPF possuem c�lculo da folha de acordo com os CPFs filtrados
		cQueryMV := "SELECT SRA.RA_CIC, "
		cQueryMV += "EMP.CNPJ as CNPJ, "
		cQueryMV += " COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
		cQueryMV += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
		cQueryMV += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		cQueryMV += "AND SRA.RA_CC <> ' ' "
		If !lExcLote
			cQueryMV += "AND EXISTS ("
			If cOpcTab == "1"
				cQueryMV += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT "
				cQueryMV += "FROM " + RetSqlName('SRC') + " SRC "
				cQueryMV += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
				cQueryMV += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND "
				cQueryMV += 	"SRC.RC_MAT = SRA.RA_MAT AND "
				If !lGera1207
					If cTpFolha == "1"
						cQueryMV += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
					Else
						cQueryMV += 	"((SRC.RC_PERIODO >= '" + cDtIni + "' AND "
						cQueryMV += 	"SRC.RC_PERIODO <= '" + cDtFim + "' AND "
						cQueryMV += 	"SRY.RY_TIPO = '6') OR "
						cQueryMV += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND SRY.RY_TIPO = '9') AND "
					EndIf
				else
					If cTpFolha == "1"
						cQueryMV += 	"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
						cQueryMV += 	"SRY.RY_TIPO = 'O' AND "
					Endif
				Endif
				cQueryMV += 	"SRC.D_E_L_E_T_ = ' ' AND "
				cQueryMV += 	"SRY.RY_TIPO != 'K'
				cQueryMV += "GROUP BY SRC.RC_FILIAL,SRC.RC_MAT "
				cQueryMV += "UNION "
			EndIf
			cQueryMV += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT "
			cQueryMV += "FROM " + RetSqlName('SRD') + " SRD "
			cQueryMV += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
			cQueryMV += "WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND "
			cQueryMV += 	"SRD.RD_MAT = SRA.RA_MAT AND "
			If !lGera1207
				If cTpFolha == "1"
					cQueryMV += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
				Else
					cQueryMV += 	"((SRD.RD_PERIODO >= '" + cDtIni + "' AND "
					cQueryMV += 	"SRD.RD_PERIODO <= '" + cDtFim + "' AND "
					cQueryMV += 	"SRY.RY_TIPO = '6') OR "
					cQueryMV += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND SRY.RY_TIPO = '9') AND "
				EndIf
			else
				If cTpFolha == "1"
					cQueryMV += 	"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
					cQueryMV += 	"SRY.RY_TIPO = 'O' AND "
				Endif
			Endif
			cQueryMV += 	"SRD.RD_EMPRESA = '  ' AND "
			cQueryMV += 	"SRD.D_E_L_E_T_ = ' ' AND "
			cQueryMV += 	"SRY.RY_TIPO != 'K' "
			cQueryMV += "GROUP BY SRD.RD_FILIAL, SRD.RD_MAT) "
		EndIf
		cQueryMV += "AND SRA.D_E_L_E_T_ = ' ' "
		cQueryMV += "GROUP BY SRA.RA_CIC, CNPJ "
		cQueryMV += "ORDER BY SRA.RA_CIC, CNPJ"
		cQueryMV := ChangeQuery(cQueryMV)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryMV),cSRAAliasMV,.T.,.T.)
		nQtdeFol := (cSRAAliasMV)->CONT
		nQtdeMV := nQtdeFol
	EndIf

	While (cSRAAlias)->(!Eof())

		lMsgDiss 	:= .F.
		nContData 	:= 0
		lPgtCompl 	:= .F.
		lTemFer		:= .F.
		aDadosFer	:= {}
		cNumBen		:= ""
		nNumBen		:= 0

		If cVersaoEnv < "9.0.00" .And. Empty((cSRAAlias)->RA_PIS) .And. !((cSRAAlias)->RA_CATEFD $ ("901*903*904"))
			aAdd(aLogsErr, Alltrim((cSRAAlias)->RA_CIC) +"-" + Alltrim((cSRAAlias)->RA_NOME) + OemToAnsi(STR0214) ) //" Funcion�rio sem PIS cadastrado - Campo Obrigat�rio"
			aAdd(aLogsErr, "" )
			(cSRAAlias)->(DBSkip())
			Loop
		EndIf

		If cVersaoEnv >= "9.0.00" .And. !lGera1207

			If lS1202 .And. aCheck[1] .And. aCheck[14] .And. fCatEstat(.F., (cSRAAlias)->RA_TPPREVI, (cSRAAlias)->RA_CATEFD, cCompete,cContrib, cTpFolha )
					(cSRAAlias)->(DBSkip())
					Loop
			ElseIf !lS1202  .And. aCheck[1] .And. aCheck[14] .And. fCatEstat(.T., (cSRAAlias)->RA_TPPREVI, (cSRAAlias)->RA_CATEFD, cCompete,cContrib,cTpFolha )
					(cSRAAlias)->(DBSkip())
					Loop
			Endif

			If lS1202 .And. !(aCheck[1] .And. aCheck[14]) .And. fCatEstat(.F., (cSRAAlias)->RA_TPPREVI, (cSRAAlias)->RA_CATEFD, cCompete, cContrib,cTpFolha)
				aAdd(aLogsOk, Alltrim((cSRAAlias)->RA_CIC) +"-" + Alltrim((cSRAAlias)->RA_NOME) + OemToAnsi(STR0215) ) //" Este trabalhador tem a categoria e tipo de regime previdenci�rio� n�o compat�vel com o evento S-1200/S-1202.
				aAdd(aLogsOk, OemToAnsi(STR0216))																		//Favor verificar a regra�REGRA_COMPATIB_REGIME_PREV. Nas pr�ximas atualiza��es o evento n�o ser� gerado."
				aAdd(aLogsOk, "")
			ElseIf !lS1202  .And. !(aCheck[1] .And. aCheck[14]) .And. fCatEstat(.T., (cSRAAlias)->RA_TPPREVI, (cSRAAlias)->RA_CATEFD, cCompete, cContrib, cTpFolha)
				aAdd(aLogsOk, Alltrim((cSRAAlias)->RA_CIC) +"-" + Alltrim((cSRAAlias)->RA_NOME) + OemToAnsi(STR0215)) //" Este trabalhador tem a categoria e tipo de regime previdenci�rio� n�o compat�vel com o evento S-1200/S-1202.
				aAdd(aLogsOk, OemToAnsi(STR0216)) 																	  //Favor verificar a regra�REGRA_COMPATIB_REGIME_PREV. Nas pr�ximas atualiza��es o evento n�o ser� gerado."
				aAdd(aLogsOk, "")
			Endif
		Endif

		IF !(cSRAAlias)->RA_PROCES == cOldProces
			cOldProces := (cSRAAlias)->RA_PROCES
			aPeriodo := {}
		ENDIF

		//Realiza pesquisa no cadastro de per�odos para verificar se h� per�odo com pagamento complementar
		IF EMPTY(aPeriodo) .OR.  aScan(aPeriodo, {|x| x[7] == (cSRAAlias)->RA_PROCES}) == 0
			fRetPerComp(SubStr(cCompete, 1, 2), SubStr(cCompete, 3, 4), xFilial(("RCH"), (cSRAAlias)->RA_FILIAL), (cSRAAlias)->RA_PROCES, If((cSRAAlias)->RA_CATFUNC $ "P*A", fGetCalcRot("9"), fGetRotOrdinar()), NIL, NIL, @aPeriodo)
		ENDIF
		//Defina se ser� eliminada a quebra de semana ou por data de pagamento ao montar a query das verbas
		IF !EMPTY(aPeriodo)
			FOR nJ := 1 TO LEN(aPeriodo)
				nContData := 0
				FOR nX := 1 TO LEN(aPeriodo)
					IF aPeriodo[nJ, 9] == aPeriodo[nX, 9]
						nContData++
					ENDIF
				NEXT nX
				IF nContData > 1
					Exit
				ENDIF
			NEXT nJ
			lPgtCompl := (aScan(aPeriodo, {|x| x[12] == "1" }) > 0 .AND. nContData > 1)
		ENDIF

		dbSelectArea( "SRA" )
		SRA->(dbSetOrder(1))
		SRA->( Dbseek( (cSRAAlias)->(RA_FILIAL) + (cSRAAlias)->(RA_MAT) ) )

		//Verifica qual a data de pagamento do roteiro 132 nos casos de funcion�rios com rescis�o calculada em dezembro
		If !Empty(SRA->RA_DEMISSA) .And. SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. (Empty(dDtPgto) .Or. cKeyProc <> xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES)
			dDtPgto 	:= fGetDtPgto(SRA->RA_FILIAL, SRA->RA_PROCES, AnoMes(SRA->RA_DEMISSA), "01", "132")
			cKeyProc	:= xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES
		EndIf

		If Empty(cEmp)
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cSRAAlias)->RA_FILIAL } ) ) > 0
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
				cEmpOld := cEmp
			EndIf
		EndIf

		If lAglut .And. ((cSRAAlias)->RA_CIC != (cSRAAliasMV)->RA_CIC .Or.;
			((cSRAAlias)->RA_CIC == (cSRAAliasMV)->RA_CIC .And. cEmp != cEmpOld)) //Se o CPF for o mesmo, por�m, a empresa � diferente
			(cSRAAliasMV)->( dbSkip() )
			nQtdeFol := (cSRAAliasMV)->CONT
			nQtdeMV := nQtdeFol
		EndIf

		cFilAnt := (cSRAAlias)->RA_FILIAL
		If lMiddleware
			fPosFil( cEmpAnt, cFilAnt )
		EndIf

		If !lIntTAF .And. (lMiddleware .And. Empty(fXMLInfos()))
			(cSRAAlias)->( dbSkip() )
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cSRAAlias)->RA_FILIAL } ) ) > 0
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
			EndIf
			Loop
		EndIf

		//Verifica filial centralizadora do envio
		If cOldFilEnv != cFilAnt
			aTabInss   := {}
			cOldFilEnv := cFilAnt
			RstaCodFol()
			aCodHash := {}
			If HMGet(oHash,xFilial('SRV', (cSRAAlias)->RA_FILIAL),@aCodHash)
				aCodFol := aCodHash
			Else
				If !Fp_CodFol(@aCodFol, xFilial('SRV', (cSRAAlias)->RA_FILIAL))
					Return(.F.)
				EndIf
				HMSet( oHash,xFilial('SRV', (cSRAAlias)->RA_FILIAL),aClone(aCodFol) )
			EndIf

			cOptSimp := fOptSimp((cSRAAlias)->RA_FILIAL, cCompete)
			If cOptSimp == "1"
				fInssEmp( (cSRAAlias)->RA_FILIAL, @aTabInss, Nil, cPer1200 )
			EndIf
			If !lMiddleware
				lFilAux := .F.
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

		//Se P_ESOCMV for .T., relacionamento 1 x 1 e (raiz do CNPJ do funcion�rio com m�ltiplo v�nculo n�o estiver selecionada ou
		//Funcion�rio n�o tem m�ltiplo v�nculo no per�odo e filial n�o est� seleciona) pula para o pr�ximo registro
		If lAglut .And. cFilEnv == (cSRAAlias)->RA_FILIAL .And. (( nW := aScan(aArrayFil2, {|x| x[3] == cEmp }) ) == 0 .Or.;
		( nW := aScan(aArrayFil2, {|x| x[1] + x[2] == cEmpAnt + (cSRAAlias)->RA_FILIAL })) == 0 .And. (cSRAAliasMV)->CONT == 1 .And.;
		(cSRAAliasMV)->RA_CIC == (cSRAAlias)->RA_CIC .And. (cSRAAliasMV)->CNPJ == cEmp)
			(cSRAAlias)->( dbSkip() )
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cSRAAlias)->RA_FILIAL } ) ) > 0
				cEmpOld := cEmp
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
			EndIf
			Loop
		EndIf

		cCPF := AllTrim((cSRAAlias)->(RA_CIC)) + ";" + Iif(lMiddleware, Alltrim(SRA->RA_CODUNIC), SRA->RA_CODUNIC)

		//Tratamento para n�o gerar valores dos demitidos no m�s.
		cFilRes  	:= (cSRAAlias)->(RA_FILIAL)
		cMatRes  	:= (cSRAAlias)->(RA_MAT)
		cTpRes	 	:= ""
		lGeraRes 	:= .F.
		lTem132	 	:= .F.
		l2300MV  	:= .F.
		lOut2300 	:= .F.
		lExiste2300	:= .F.
		lComplCont	:= .F.
		aResCompl	:= {}
		lDissMV  	:= .F.

		If !lExcLote .And. cTpFolha == "1"
			//cTpRes - tipo de rescis�o
			//0 = N�o � complementar ou � uma complementar no mesmo mes n�o deve ser levada no S-1200 (DBSkip)
			//1 = Complementar com pgto de PLR ou outras verbas levar no S-1200, <tpAcConv> == "F"
			//2 = Complementar com pgto de Diss�dio levar no S-1200, <tpAcConv> == "A"
			fGetRes( cFilRes, cMatRes, cCompete, Nil, .T., If(cVersaoEnv >= "9.0.00", @cTpRes, Nil), Nil, @aResCompl,,,,,cVersaoEnv)

			//Na vers�o S-1.0 o evento S-1200 � gerado para TSV com rescis�o no per�odo, por isso o registro deixa de ser desprezado
			If (cVersaoEnv < "9.0.00" .Or. (cVersaoEnv >= "9.0.00" .And. (!(SRA->RA_CATEFD $ cTSV) .Or. SRA->RA_CATEFD = "721") .And. ;
			   !(lGera1202 .And. SRA->RA_VIEMRAI $ "30|31|35"))) .And. aScan(aResCompl, { |x| x[1] $ "0|3" } ) > 0
				aAdd( aFuncDem, { SRA->RA_FILIAL, SRA->RA_CIC, SRA->RA_NOME } )
				(cSRAAlias)->(DBSkip())
				Loop
			//Se n�o houver rescis�o calculada e o per�odo de gera��o for superior a data de demiss�o despreza o registro
			// cCompete MMAAAA, ex. 082019
			// RA_DEMISSA AAAAMMDD, ex. 20200115
			// Para comparar 201908 < 202001
			ElseIf (Empty(aResCompl) .And. !Empty((cSRAAlias)->RA_DEMISSA) .And.  Substr(cCompete, 3, 4) + Substr(cCompete, 1, 2) > Substr((cSRAAlias)->RA_DEMISSA, 1, 4) + Substr((cSRAAlias)->RA_DEMISSA, 5, 2))  .And. !fBscPLR(cPer1200)
				(cSRAAlias)->(DBSkip())
				Loop
			ElseIf aScan(aResCompl, { |x| x[1] $ "1|2" } ) > 0
				lGeraRes := SRA->RA_CATEFD $ "101|102|103|104|105|107|108|111|201|202|301|302|303|305|306|307|308|309|"
			Endif

			//Define se o S-1200 ser� "Quebrado" pela semana ou pela data de pagamento
			lDtPgto := (lPagAuto .And. (SRA->RA_CATEFD $ cContrib .Or. SRA->RA_CATEFD $ cBolsistas) .And. !lGeraRes ) .Or. (lGeraRes .And. Len(aResCompl) > 1 .And. !(aScan(aResCompl, { |x| x[1] <> "1" } ) > 0))
		ElseIf !lExcLote .And. cTpFolha == "2"
			If !Empty(SRA->RA_DEMISSA) .And. !(SRA->RA_RESCRAI $ "30/31") .And. AnoMes(SRA->RA_DEMISSA) <= cPer1200 .And. !(SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. SRA->RA_DEMISSA >= dDtPgto)
				aAdd( aFuncDem, { SRA->RA_FILIAL, SRA->RA_CIC, SRA->RA_NOME } )
				aAdd(aLogsErr, SRA->RA_CIC+"-" + Alltrim(SRA->RA_NOME) + OemToAnsi(STR0211) ) //" Funcion�rio possui rescis�o e os dados ja constam no evento S-2299/S-2399."
				(cSRAAlias)->(DBSkip())
				Loop
			EndIf
		EndIf

		//� considerado TRABALHADOR SEM VINCULO(TSV) funcionarios que atendem a faixa abaixo.
		//TSV nunca dever�o ter duas ou mais matriculas. Sempre dever�o ter uma unica matricula em uma unica filial. Ou seja, a query inicial da SRA agrupada teria sempre 1 unico registro
		//para este tipo de funcionario. Sendo assim, tratamos:
		If cVersaoEnv >= "9.0" .And. lGera1207 .And. (SRA->RA_CATFUNC == "9" .Or. SRA->RA_EAPOSEN == "1" )
			If !lMiddleware
				cCPF := AllTrim(SRA->RA_CIC)
				cStat2 := TAFGetStat( "S-2400", cCPF )
			EndIf
		ElseIf SRA->RA_CATEFD $ cTSV
			lTrabSemVinc := .T.
			If !lMiddleware
				If !lGeraMat
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					cStat2  := TAFGetStat( "S-2300", cCPF, Nil, Nil, Nil, cPer1200, .T.)
				Else
					cCPF := AllTrim( SRA->RA_CIC ) + ";" + If(SRA->RA_DESCEP == "1", SRA->RA_CODUNIC,"")  + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					cStat2  := TAFGetStat( "S-2300", cCPF, Nil, Nil, Nil, cPer1200, .T.)
				EndIf
			Else
				If lGeraMat .And. SRA->RA_DESCEP == "1"
					cCPF := SRA->RA_CODUNIC
				Else
					cCPF := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
				EndIf
				If lMiddleware
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
				EndIf
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
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
				cStat2 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStat2 )

				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cCPF, 40, " ")
				cStatMid 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatMid )
			EndIf
			lComplTSV := .F.
			If cStat2 == "-1" .Or. (!lMiddleware .And. cStat2 != "-1" .And. C9V->C9V_NOMEVE == "TAUTO") .Or. cStat2 == "-2"
				If (AllTrim( SRA->RA_CATEFD ) $ cCatTSV) .Or. (!lMiddleware .And. cStat2 != "-1" .And. C9V->C9V_NOMEVE == "TAUTO")
					If Empty(fGM26Fun(SRA->RA_CODFUNC, SRA->RA_FILIAL)[2]) .Or. Empty(SRA->RA_NASC) .Or. Empty(SRA->RA_NOME) .Or. Empty(SRA->RA_CATEFD)
						If !lExcLote
							aAdd(aLogsErr, OemToAnsi(STR0046) + OemToAnsi(STR0021) + (cSRAAlias)->(RA_CIC) + " - " + ALLTRIM((cSRAAlias)->(RA_NOME)) + OemToAnsi(STR0034) ) //"[FALHA] "##"Registro S-1200 do Funcion�rio: "##" (TSV) Verifique o preenchimento dos campos: RJ_CODCBO, RA_NOME, RA_NASC e RA_CATEFD"
							aAdd(aLogsErr, "" )
							aEmp_1200[4]++ //Inclui TSV nao integrado
						EndIf
						If lRelat
							aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0034) } )//" (TSV) Verifique o preenchimento dos campos: RJ_CODCBO, RA_NOME, RA_NASC e RA_CATEFD"
						EndIf
						(cSRAAlias)->(DBSkip())
						Loop
					EndIf

					//Tratamento para verificar se envia informa��es complementares quando existe m�ltiplo v�nculo
					lComplTSV := fVrfTrbVnc(SRA->RA_CIC, cTrabSemVinc, CToD("01/" + Substr(cCompete, 1, 2) + "/" + Substr(cCompete, 3, 4)), @lOut2300, (cSRAAlias)->RA_FILIAL, aFilInTaf, @lComplCont, @lExiste2300, lAdmPubl, cTpInsc, cNrInsc)
					//Se n�o achou C9V nessa filial, somente h� o pagamento de folha de um v�nculo mas achou C9V de outra filial, trata como MV
					If nQtdeFol == 1 .And. !lComplTSV .And. lOut2300
						l2300MV := .T.
					EndIf
				ElseIf 	!(AllTrim( SRA->RA_CATEFD ) $  (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU"))) .And. cStat2 == "-2"
					aAdd(aLogsErr, OemToAnsi(STR0046) + If(!lGera1202,OemToAnsi(STR0021) ,OemToAnsi(STR0218)) + (cSRAAlias)->(RA_CIC) + " - " + ALLTRIM((cSRAAlias)->(RA_NOME)) + OemToAnsi(STR0213) ) //"[FALHA] "##"Registro S-1200 do Funcion�rio: "##" (TSV) Verifique o preenchimento dos campos: RJ_CODCBO, RA_NOME, RA_NASC e RA_CATEFD"
					aAdd(aLogsErr, "" )
					aEmp_1200[4]++ //Inclui TSV nao integrado
					If lRelat
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0213) } )//" Categoria n�o permite o envio do evento em data posterior ao desligamento "
					Endif
					(cSRAAlias)->(DBSkip())
					Loop
				Else
					If !lMiddleware
						aAdd(aLogsErr, OemToAnsi(STR0045) +"("+ (cSRAAlias)->RA_CIC +")-" + Alltrim((cSRAAlias)->RA_NOME) + " no TAF.") //##" "[FALHA] N�o foi possivel encontrar o registro do Funcion�rio
					Else
						aAdd(aLogsErr, OemToAnsi(STR0045) +"("+ (cSRAAlias)->RA_CIC +")-" + Alltrim((cSRAAlias)->RA_NOME) + " no Middleware.") //##" "[FALHA] N�o foi possivel encontrar o registro do Funcion�rio
					EndIf
					aAdd(aLogsErr, "" )
					aEmp_1200[4]++ //Inclui TSV nao integrado
					If lRelat
						If !lMiddleware
							aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0045) + " no TAF"} )//"N�o foi possivel encontrar o registro do Funcion�rio"
						Else
							aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0045) + " no Middleware"} )//"N�o foi possivel encontrar o registro do Funcion�rio"
						EndIf
					EndIf
					(cSRAAlias)->(DBSkip())
					Loop
				Endif
			EndIf
		Else
			lTrabSemVinc := .F.
			If !lMiddleware
				cStatus := TAFGetStat( "S-2100", cCPF )
				cStat1  := TAFGetStat( "S-2200", cCPF )
			Else
				If lMiddleware
					fPosFil( cEmpAnt, SRA->RA_FILIAL )
				EndIf
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
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
				cStatus		:= "-1"
				cStat1 		:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStat1 )
			EndIf

			If cStatus  == "-1"	.and. cStat1 == "-1"
				If !lMiddleware
					aAdd(aLogsErr, OemToAnsi(STR0045) +"("+ (cSRAAlias)->RA_CIC +")-" + Alltrim((cSRAAlias)->RA_NOME) + " no TAF.") //##" "[FALHA] N�o foi possivel encontrar o registro do Funcion�rio
				Else
					aAdd(aLogsErr, OemToAnsi(STR0045) +"("+ (cSRAAlias)->RA_CIC +")-" + Alltrim((cSRAAlias)->RA_NOME) + " no Middleware.") //##" "[FALHA] N�o foi possivel encontrar o registro do Funcion�rio
				EndIf
				aAdd(aLogsErr, "" )
				aEmp_1200[2]++ //Inclui TCV nao integrado
				If lRelat
					If !lMiddleware
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0045) + " no TAF"} )//"N�o foi possivel encontrar o registro do Funcion�rio"
					Else
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0045) + " no Middleware"} )//"N�o foi possivel encontrar o registro do Funcion�rio"
					EndIf
				EndIf
				(cSRAAlias)->(DBSkip())
				Loop
			EndIf
		EndIf

		If !lRobo
			If !lNewProgres
				GPIncProc("CPF: " + Transform(SRA->RA_CIC, "@R 999.999.999-99") + " | Funcion�rio: " + SRA->RA_FILIAL + SRA->RA_MAT )
			Else
				IncPrcG1Time("CPF: " + Transform(SRA->RA_CIC, "@R 999.999.999-99") + " | Funcion�rio: " + SRA->RA_FILIAL + SRA->RA_MAT, nTotRec, cTimeIni, .T., 1, 1, .T.)
			EndIf
		EndIf

		If !lAglut .Or. nQtdeFol == 1 .Or. SRA->RA_CIC != cOldCic .Or. cEmp != cEmpOld
			cStatNew := ""
			cOperNew := ""
			cRetfNew := ""
			cRecibAnt:= ""
			cKeyMid	 := ""
			nRecEvt	 := 0
			lNovoRJE := .T.
			aStatC91 := fVerStat( If(lGera1207,3,1), @cFilEnv, Iif(cTpFolha == "1", cPer1200, SubStr(cPer1200, 1, 4)), aClone(aFilInTaf), cTpFolha, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @cRecibAnt, @lNovoRJE, @cKeyMid, lAdmPubl, cTpInsc, cNrInsc, ,lGera1202 )
			cStatC91 := aStatC91[1]
			cRecibo  := aStatC91[2]
		EndIf

		/*
		�������������������������������������������������
		���������������������������������������������Ŀ��
		��� Exclusao em lote dos registros            ���
		����������������������������������������������ٱ�
		�������������������������������������������������*/
		If lExcLote
			cPerApur := SubStr(cCompete, 3, 4) + If(cTpFolha == "1", "-" + Substr(cCompete, 1, 2), "" ) // No 13� enviar apenas o ano
			cXml	 := ""
			If cStatC91 $ "4"
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aDados	 := {}
				InExc3000(@cXml, If(!lGera1202,If(lGera1207,'S-1207','S-1200'),'S-1202'), cRecibo, SRA->RA_CIC, SRA->RA_PIS, .T., cTpFolha, cPerApur, Nil, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
				GrvTxtArq(alltrim(cXml), "S3000", SRA->RA_CIC)
				If !lMiddleware
					aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
				ElseIf Empty(aErros)
					aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecibo, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
					If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
						aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na grava��o do registro na tabela RJE"
					Else
						fExcRJO( cFilEnv, cTpFolha, StrTran(cPerApur, "-", ""), SRA->RA_CIC, "S-1200" )
					EndIf
				EndIf
				If Len( aErros ) > 0
					cMsgErro := ''
					FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
					FormText(@cMsgErro)
					aErros[1] := cMsgErro
					aAdd(aLogsErr, OemToAnsi(STR0046) + cExcLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0029) ) //"[FALHA] "##"Registro de exclusao S-xxxx: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
					aAdd(aLogsErr, "" )
					aAdd(aLogsErr, aErros[1] )
					If lTrabSemVinc
						aEmp_1200[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1200[2]++ //Inclui TCV nao integrado
					EndIf
				Else
					If !lMiddleware
						aAdd(aLogsOk, cExcLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0049) ) //##"Registro de exclusao S-xxxx: "##" Integrado com TAF."
					Else
						aAdd(aLogsOk, OemToAnsi(STR0047) + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0165) ) //##"Registro de exclusao S-1200 do Funcion�rio: "##" Integrado com Middleware."
					EndIf
					aAdd(aLogsOk, "" )
					If lTrabSemVinc
						aEmp_1200[3]++ //Inclui TSV integrado
					Else
						aEmp_1200[1]++ //Inclui TCV integrado
					EndIf
				Endif
			ElseIf cStatC91 $ "2/6"
				aAdd(aLogsErr, OemToAnsi(STR0046) + cExcLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0028) ) //"[FALHA] "##"Registro de exclusao S-xxxx: "##" desprezado pois est� aguardando retorno do governo."
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf cStatC91 == "9"
				aAdd(aLogsErr, OemToAnsi(STR0148) + cExcLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0166) ) //"[AVISO] "##"Registro de exclusao S-xxxx: "##" desprezado pois h� evento de exclus�o pendente para transmiss�o."
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf cStatC91 != "-1"
				aAdd(aLogsErr, OemToAnsi(STR0148) + cExcLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0150) ) //"[AVISO] "##"Registro de exclusao S-xxxx: "##" desprezado pois n�o foi transmitido."
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			Else
				aAdd(aLogsErr, OemToAnsi(STR0148) + cEvtLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0151) ) //"[AVISO] "##"Registro S-xxxx do Funcion�rio: "##" n�o foi encontrado. A exclus�o n�o poder� ser realizada."
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			EndIf
			(cSRAAlias)->(DBSkip())
			Loop
		EndIf

		If !lRelat
			nVldOpcoes := fVldOpcoes(aCheck, cStatC91)

			If nVldOpcoes == 1
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, cEvtLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0026) ) //##"Registro S-xxxx: "##"  n�o foi sobrescrito."
					aAdd(aLogsErr, "" )
					If lTrabSemVinc
						aEmp_1200[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1200[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cSRAAlias)->(DBSkip())
				Loop
			ElseIf nVldOpcoes == 2
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, cEvtLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0027) ) //##"Registro S-xxxx: "##" n�o foi retificado."
					aAdd(aLogsErr, "" )
					If lTrabSemVinc
						aEmp_1200[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1200[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cSRAAlias)->(DBSkip())
				Loop
			ElseIf nVldOpcoes == 3
				If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
					aAdd(aCpfDesp, SRA->RA_CIC)
					aAdd(aLogsErr, cEvtLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0028) ) //##"Registro S-xxxx: "##" desprezado pois est� aguardando retorno do governo."
					aAdd(aLogsErr, "" )
					If lTrabSemVinc
						aEmp_1200[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1200[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf
				(cSRAAlias)->(DBSkip())
				Loop
			ElseIf cStatC91 == "9"
				aAdd(aLogsErr, cEvtLog + SRA->RA_CIC + " - " + AllTrim(SRA->RA_NOME) + OemToAnsi(STR0166) ) //##"Registro S-1200 do Funcion�rio: "##" desprezado pois h� evento de exclus�o pendente para transmiss�o."
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
				(cSRAAlias)->(DBSkip())
				Loop
			Endif
		EndIf

		//refaz variaveis abaixo com base na filial posicionada
		cFilLocCTT := FWxFilial("CTT")

		If (!lDtPgto .And. __oSt01_1 == Nil) .Or. (lDtPgto .And. __oSt01_2 == Nil) .OR. (lPgtCompl .AND. __oSt01_3 == Nil) .Or. (lGera1207 .And. __oSt01_4 == Nil)
			IF lPgtCompl
				__oSt01_3 := FWPreparedStatement():New()
				cQrySt 	  := "SELECT SRD.RD_ROTEIR "
			ElseIf lGera1207
				__oSt01_4 := FWPreparedStatement():New()
				cQrySt	  := "SELECT SRD.RD_ROTEIR, SRD.RD_NRBEN "
			ElseIf !lDtPgto
				__oSt01_1 := FWPreparedStatement():New()
				cQrySt 	  := "SELECT SRD.RD_ROTEIR, SRD.RD_SEMANA "
			Else
				__oSt01_2 := FWPreparedStatement():New()
				cQrySt	  := "SELECT SRD.RD_ROTEIR, SRD.RD_DATPGT "
			EndIf
			cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
			cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
			cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
			cQrySt += 		"SRD.RD_MAT = ? AND "
			cQrySt += 		"SRD.RD_PERIODO = '" + cPer1200 + "' AND "
			cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
			cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
			cQrySt += 		"SRY.RY_TIPO != 'K' AND "
			cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
			If cOpcTab == "1"
				cQrySt += "UNION "
				IF lPgtCompl
					cQrySt += "SELECT SRC.RC_ROTEIR "
				ElseIf lGera1207
					cQrySt += "SELECT SRC.RC_ROTEIR, SRC.RC_NRBEN "
				ElseIf !lDtPgto
					cQrySt += "SELECT SRC.RC_ROTEIR, SRC.RC_SEMANA "
				Else
					cQrySt += "SELECT SRC.RC_ROTEIR, SRC.RC_DATA "
				EndIf
				cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
				cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
				cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
				cQrySt += 		"SRC.RC_MAT = ? AND "
				cQrySt += 		"SRC.RC_PERIODO = '" + cPer1200 + "' AND "
				cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
				cQrySt += 		"SRY.RY_TIPO != 'K' AND "
				cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
			Else
				If lPgtCompl
					cQrySt += "GROUP BY SRD.RD_ROTEIR "
				ElseIf lGera1207
					cQrySt += "GROUP BY SRD.RD_ROTEIR, SRD.RD_NRBEN "
				ElseIf !lDtPgto
					cQrySt += "GROUP BY SRD.RD_ROTEIR, SRD.RD_SEMANA "
				Else
					cQrySt += "GROUP BY SRD.RD_ROTEIR, SRD.RD_DATPGT "
				EndIf
			EndIf
			cQrySt := ChangeQuery(cQrySt)
			If lPgtCompl
				__oSt01_3:SetQuery(cQrySt)
			ElseIf lGera1207
				__oSt01_4:SetQuery(cQrySt)
			ElseIf !lDtPgto
				__oSt01_1:SetQuery(cQrySt)
			Else
				__oSt01_2:SetQuery(cQrySt)
			EndIf
		EndIf

		IF lPgtCompl
			__oSt01_3:SetString(1, (cSRAAlias)->RA_FILIAL)
			__oSt01_3:SetString(2, (cSRAAlias)->RA_MAT)
			If cOpcTab == "1"
				__oSt01_3:SetString(3, (cSRAAlias)->RA_FILIAL)
				__oSt01_3:SetString(4, (cSRAAlias)->RA_MAT)
			EndIf
		ELSE
			If lGera1207
				__oSt01_4:SetString(1, (cSRAAlias)->RA_FILIAL)
				__oSt01_4:SetString(2, (cSRAAlias)->RA_MAT)
				If cOpcTab == "1"
					__oSt01_4:SetString(3, (cSRAAlias)->RA_FILIAL)
					__oSt01_4:SetString(4, (cSRAAlias)->RA_MAT)
				EndIf
			ElseIf !lDtPgto
				__oSt01_1:SetString(1, (cSRAAlias)->RA_FILIAL)
				__oSt01_1:SetString(2, (cSRAAlias)->RA_MAT)
				If cOpcTab == "1"
					__oSt01_1:SetString(3, (cSRAAlias)->RA_FILIAL)
					__oSt01_1:SetString(4, (cSRAAlias)->RA_MAT)
				EndIf
			Else
				__oSt01_2:SetString(1, (cSRAAlias)->RA_FILIAL)
				__oSt01_2:SetString(2, (cSRAAlias)->RA_MAT)
				If cOpcTab == "1"
					__oSt01_2:SetString(3, (cSRAAlias)->RA_FILIAL)
					__oSt01_2:SetString(4, (cSRAAlias)->RA_MAT)
				EndIf
			EndIf
		ENDIF
		If lPgtCompl
			cQrySt := __oSt01_3:getFixQuery()
		ElseIf lGera1207
			cQrySt := __oSt01_4:getFixQuery()
		ElseIf !lDtPgto
			cQrySt := __oSt01_1:getFixQuery()
		Else
			cQrySt := __oSt01_2:getFixQuery()
		EndIf
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cSRDRot,.T.,.T.)

		If ((cSRDRot)->(!Eof()) .Or. (SubStr(cCompete, 1, 2) == "12" .And. cTpFolha == "2" .And. !lTem132 )) .And.;
		 	( !lAglut .Or. nQtdeFol == 1 .Or. (cSRAAlias)->(RA_CIC) != cOldCic .Or. cEmp != cEmpOld )
			cOldCic		:= (cSRAAlias)->RA_CIC
			cEmpOld		:= cEmp
			cOldNome 	:= SRA->RA_NOME
			cOldFil 	:= SRA->RA_FILIAL
			cOldOcorr 	:= SRA->RA_OCORREN
			lAbriuXml 	:= .T.
			aLogDiss	:= {}
			aContdmDev	:= {}
			lCPFDepOk	:= .T.
			lRAZOk		:= .T.
			lRJ5Ok		:= .T.
			lFornPLA	:= .T.
			aFornPLA	:= {}
			aDepAgreg	:= {}
			aRJ5CC		:= {}
			aCodDmDev	:= {}
			aDados		:= {}
			aErros		:= {}

			If !lRelat
				aEvtRemun 	:= {}
				aIdeEven 	:= {}
				aIdeTrabal 	:= {}
				aProcJud 	:= {}
				aInfMV	 	:= {}
				aRemOutEmp 	:= {}
				aInfCompl 	:= {}
				aInfInter 	:= {}
				aDmDev	 	:= {}
				aInfPerApur	:= {}
				aEstLotApur	:= {}
				aRemPerApur	:= {}
				aItRemApur 	:= {}
				aInfSauCole	:= {}
				aDetOper 	:= {}
				aDetPlano 	:= {}
				aInfAgNoc 	:= {}
				aInfTrabInt	:= {}
				aInfPerAnt 	:= {}
				aIdeADCAnt 	:= {}
				aIdePer 	:= {}
				aEstLotAnt 	:= {}
				aRemPerAnt 	:= {}
				aItRemAnt 	:= {}
				aAgNocAnt 	:= {}
				aComplCont	:= {}
			EndIf
			AbreXML(cCompete, cTpFolha, lTrabSemVinc, lComplTSV, aEstb, cOpcTab, cTrabSemVinc, nQtdeFol, cVersaoEnv, aPeriodo)
		ElseIf Empty(aInfCompl) .And. (cSRAAlias)->(RA_CIC) == cOldCic .And. cEmp == cEmpOld
			If lComplTSV
				// Preenche o array aInfCompl
				setInfCmpl(@aInfCompl)
			EndIf
		EndIf

		If (cSRDRot)->(!Eof())
			IncProc("Filial: " + SRA->RA_FILIAL + " Matricula: " + SRA->RA_MAT )

			lAjudaComp := Iif(!lAfastado, fAjuComp((cSRDRot)->RD_ROTEIR, (cSRAAlias)->RA_FILIAL, SRA->RA_MAT, cPer1200), .F.)

			If aScan( aContdmDev, { |x| x[1] == cFilEnv + ";" + SRA->RA_FILIAL+SRA->RA_MAT  } ) == 0
				aAdd( aContdmDev, { cFilEnv + ";" + SRA->RA_FILIAL+SRA->RA_MAT} )
			EndIf

			nAuxTot 	:= 0

			cCodBen := If(lGera1207, (cSRDRot)->RD_NRBEN, "")

			While (cSRDRot)->(!Eof())

				lGera1200 	:= .T.

				If SubStr(cCompete, 1, 2) == "12" .And. ((cTpFolha == "2" .And. ((cSRDRot)->RD_ROTEIR != "132" .Or. fGetTipoRot( (cSRDRot)->RD_ROTEIR ) != "6")) .Or. cTpFolha != "2" .And. ((cSRDRot)->RD_ROTEIR == "132" .Or. fGetTipoRot( (cSRDRot)->RD_ROTEIR ) == "6"))
					(cSRDRot)->( dbSkip() )
					LOOP
				EndIf

				If SubStr(cCompete, 1, 2) == "12" .And. cTpFolha == "2" .And. ((cSRDRot)->RD_ROTEIR == "132" .Or. fGetTipoRot( (cSRDRot)->RD_ROTEIR ) == "6")
					lTem132	:= .T.
				EndIf

				IF !lAjudaComp .And. !lAfastado .And. !lGeraRes .And. cTpFolha == "1" .And. ( (cSRDRot)->RD_ROTEIR == "FOL" .Or. fGetTipoRot( (cSRDRot)->RD_ROTEIR ) $ "1|5" )
					SRD->( dbSetOrder(1) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
					IF SRD->( dbSeek( (cSRAAlias)->RA_FILIAL + SRA->RA_MAT + cPer1200 ) )
						While SRD->( !EoF() ) .And. SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PERIODO == (cSRAAlias)->RA_FILIAL + SRA->RA_MAT + cPer1200
							If SRD->RD_ROTEIR == (cSRDRot)->RD_ROTEIR .And. SRD->RD_PD $ (aCodFol[13,1]+"/"+aCodFol[14,1]+"/"+aCodFol[17,1]+"/"+aCodFol[108,1]+"/"+aCodFol[219,1]+"/"+aCodFol[337,1]+"/"+aCodFol[338,1])
								nAuxTot += SRD->RD_VALOR
								Exit
							EndIf
							SRD->( dbSkip() )
						EndDo
					EndIf
					If nAuxTot == 0 .And. cOpcTab == "1"
						SRC->( dbSetOrder(4) )//RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD
						IF SRC->( dbSeek( (cSRAAlias)->RA_FILIAL + SRA->RA_MAT + cPer1200 ) )
							While SRC->( !EoF() ) .And. SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PERIODO == (cSRAAlias)->RA_FILIAL + SRA->RA_MAT + cPer1200
								If SRC->RC_ROTEIR == (cSRDRot)->RD_ROTEIR .And. SRC->RC_PD $ (aCodFol[13,1]+"/"+aCodFol[14,1]+"/"+aCodFol[17,1]+"/"+aCodFol[108,1]+"/"+aCodFol[219,1]+"/"+aCodFol[337,1]+"/"+aCodFol[338,1])
									nAuxTot += SRC->RC_VALOR
									Exit
								EndIf
								SRC->( dbSkip() )
							EndDo
						EndIf
					EndIf
					If nAuxTot == 0
						lGera1200 := .F.
						If lRelat
							aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0075) } )//"Funcion�rio foi desprezado pois est� sem movimento"
						EndIf
						(cSRDRot)->( dbSkip() )
						Loop
					EndIf
				EndIf

				If Select( cSRDAlias ) > 0
					(cSRDAlias)->( dbCloseArea() )
				EndIf

				If Select( cSRDAut ) > 0
					(cSRDAut)->( dbCloseArea() )
				EndIf

				If Select( cSRDTabRJ ) > 0
					(cSRDTabRJ)->( dbCloseArea() )
				EndIf

				If Select( cSRDTabRH ) > 0
					(cSRDTabRH)->( dbCloseArea() )
				EndIf

				If (!lDtPgto .And. __oSt02_1 == Nil) .Or. (lDtPgto .And. __oSt02_2 == Nil) .OR. (lPgtCompl .AND. __oSt02_3 == Nil) .Or. (lGera1207 .And. __oSt02_4 == Nil)
					IF lPgtCompl
						__oSt02_3 := FWPreparedStatement():New()
					ElseIf lGera1207
						__oSt02_4 := FWPreparedStatement():New()
					ElseIf !lDtPgto
						__oSt02_1 := FWPreparedStatement():New()
					Else
						__oSt02_2 := FWPreparedStatement():New()
					EndIf
					cQrySt := "SELECT SRD.RD_FILIAL,SRD.RD_MAT,SRD.RD_DATARQ,SRD.RD_CC,SRD.RD_PD,SRD.RD_PERIODO,SRD.RD_ROTEIR,SUM(SRD.RD_HORAS) RD_HORAS,SUM(SRD.RD_VALOR) RD_VALOR,MAX(SRD.RD_DATPGT) RD_DATPGT, MAX(SRD.R_E_C_N_O_) RECNO,'SRD' AS TAB, SRD.RD_SEMANA, SRD.RD_NUMID" + If(lGera1207, ", SRD.RD_NRBEN ", " ")
					cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
					cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
					cQrySt += 		"SRD.RD_MAT = ? AND "
					cQrySt += 		"SRD.RD_PERIODO = '" + cPer1200 +  "' AND "
					cQrySt += 		"SRD.RD_ROTEIR = ? AND "
					IF !lPgtCompl
						If lGera1207
							cQrySt += 	"SRD.RD_NRBEN = ? AND "
						ElseIf !lDtPgto
							cQrySt += 	"SRD.RD_SEMANA = ? AND "
						Else
							cQrySt += 	"SRD.RD_DATPGT = ? AND "
						EndIf
					ENDIF
					cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
					cQrySt += 		"SRD.D_E_L_E_T_ = ' ' "
					cQrySt += "GROUP BY RD_FILIAL, RD_MAT, RD_DATARQ, RD_CC, RD_PD, RD_PERIODO, RD_ROTEIR, RD_SEMANA, RD_NUMID" + If(lGera1207, ", RD_NRBEN ", " ")
					If cOpcTab == "1"
						cQrySt += "UNION ALL "
						cQrySt += "SELECT SRC.RC_FILIAL,SRC.RC_MAT,SRC.RC_PERIODO,SRC.RC_CC,SRC.RC_PD,SRC.RC_PERIODO,SRC.RC_ROTEIR,SUM(SRC.RC_HORAS) RD_HORAS,SUM(SRC.RC_VALOR) RD_VALOR,MAX(SRC.RC_DATA) RD_DATPGT, MAX(SRC.R_E_C_N_O_) RECNO,'SRC' AS TAB, SRC.RC_SEMANA, SRC.RC_NUMID" + If(lGera1207, ", SRC.RC_NRBEN ", " ")
						cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
						cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
						cQrySt += 		"SRC.RC_MAT = ? AND "
						cQrySt += 		"SRC.RC_PERIODO = '" + cPer1200 +  "' AND "
						cQrySt += 		"SRC.RC_ROTEIR = ? AND "
						IF !lPgtCompl
							If lGera1207
								cQrySt += 	"SRC.RC_NRBEN = ? AND "
							ElseIf !lDtPgto
								cQrySt += 	"SRC.RC_SEMANA = ? AND "
							Else
								cQrySt += 	"SRC.RC_DATA = ? AND "
							EndIf
						ENDIF
						cQrySt += 		"SRC.D_E_L_E_T_ = ' ' "
						cQrySt += "GROUP BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_CC, RC_PD, RC_PERIODO, RC_ROTEIR, RC_SEMANA, RC_NUMID" + If(lGera1207, ", RC_NRBEN ", " ")
					EndIf
					cQrySt += "ORDER BY 1, 2, 3, 4, 5 "
					cQrySt := ChangeQuery(cQrySt)
					IF lPgtCompl
						__oSt02_3:SetQuery(cQrySt)
					ElseIf lGera1207
						__oSt02_4:SetQuery(cQrySt)
					ElseIf !lDtPgto
						__oSt02_1:SetQuery(cQrySt)
					Else
						__oSt02_2:SetQuery(cQrySt)
					EndIf
				EndIf

				IF lPgtCompl
					__oSt02_3:SetString(1, (cSRAAlias)->RA_FILIAL)
					__oSt02_3:SetString(2, (cSRAAlias)->RA_MAT)
					__oSt02_3:SetString(3, (cSRDRot)->RD_ROTEIR)

					If cOpcTab == "1"
						__oSt02_3:SetString(4, (cSRAAlias)->RA_FILIAL)
						__oSt02_3:SetString(5, (cSRAAlias)->RA_MAT)
						__oSt02_3:SetString(6, (cSRDRot)->RD_ROTEIR)
					EndIf
				ELSE
					If lGera1207
						__oSt02_4:SetString(1, (cSRAAlias)->RA_FILIAL)
						__oSt02_4:SetString(2, (cSRAAlias)->RA_MAT)
						__oSt02_4:SetString(3, (cSRDRot)->RD_ROTEIR)
						__oSt02_4:SetString(4, (cSRDRot)->RD_NRBEN)

						If cOpcTab == "1"
							__oSt02_4:SetString(5, (cSRAAlias)->RA_FILIAL)
							__oSt02_4:SetString(6, (cSRAAlias)->RA_MAT)
							__oSt02_4:SetString(7, (cSRDRot)->RD_ROTEIR)
							__oSt02_4:SetString(8, (cSRDRot)->RD_NRBEN)
						EndIf
					ElseIf !lDtPgto
						__oSt02_1:SetString(1, (cSRAAlias)->RA_FILIAL)
						__oSt02_1:SetString(2, (cSRAAlias)->RA_MAT)
						__oSt02_1:SetString(3, (cSRDRot)->RD_ROTEIR)
						__oSt02_1:SetString(4, (cSRDRot)->RD_SEMANA)

						If cOpcTab == "1"
							__oSt02_1:SetString(5, (cSRAAlias)->RA_FILIAL)
							__oSt02_1:SetString(6, (cSRAAlias)->RA_MAT)
							__oSt02_1:SetString(7, (cSRDRot)->RD_ROTEIR)
							__oSt02_1:SetString(8, (cSRDRot)->RD_SEMANA)
						EndIf
					Else
						__oSt02_2:SetString(1, (cSRAAlias)->RA_FILIAL)
						__oSt02_2:SetString(2, (cSRAAlias)->RA_MAT)
						__oSt02_2:SetString(3, (cSRDRot)->RD_ROTEIR)
						__oSt02_2:SetString(4, (cSRDRot)->RD_DATPGT)
						If cOpcTab == "1"
							__oSt02_2:SetString(5, (cSRAAlias)->RA_FILIAL)
							__oSt02_2:SetString(6, (cSRAAlias)->RA_MAT)
							__oSt02_2:SetString(7, (cSRDRot)->RD_ROTEIR)
							__oSt02_2:SetString(8, (cSRDRot)->RD_DATPGT)
						EndIf
					EndIf
				ENDIF
				IF lPgtCompl
					cQrySt := __oSt02_3:getFixQuery()
				ElseIf lGera1207
					cQrySt := __oSt02_4:getFixQuery()
				ElseIf !lDtPgto
					cQrySt := __oSt02_1:getFixQuery()
				Else
					cQrySt := __oSt02_2:getFixQuery()
				EndIf
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),If(!lPagAuto, cSRDAlias, cSRDAut),.T.,.T.)

				If lGera1207 //Verifica quantidade de benef�cios processados p/compor dmDev
					If (cSRDRot)->RD_NRBEN <> cCodBen
						nNumBen ++
						If nNumBen >= 1
							cNumBen := cValToChar(nNumBen)
						EndIf
					EndIf
				Else
					If lPagAuto
						fCriaTmp(cSRDAlias, cSRDAut)
					EndIf

					If lVerRJ5
						fVerRJ5A(cSRDAlias, cSRDTabRJ, cPer1200, @lRJ5Ok, @aRJ5CC)
					EndIf

					If !lGeraRat
						fGerRatA(cSRDAlias, cSRDTabRJ, cPer1200)
					EndIf
				EndIf

				If !lVerRJ5 .Or. (lVerRJ5 .And. lRJ5Ok)
					CorpoXML(cOpcTab, cCompete, lGeraRes, aResCompl, @aLogDiss, aEstb, lComplTSV, cTpFolha, Nil, @lCPFDepOk, @aDepAgreg, cOptSimp, aTabInss, @lRJ5Ok, @aRJ5CC, @lRAZOk, lRelat, lComplCont, lExiste2300, @lDissMV, @aErros, @aLogPeric,, cTpRes, cNumBen )
				EndIf

				If Select(cSRDAlias) > 0
					(cSRDAlias)->(dbCloseArea())
				EndIf
				If oTmpTable <> Nil
					oTmpTable:Delete()
					oTmpTable := Nil
				EndIf
				If oTmpTabRJ <> Nil
					oTmpTabRJ:Delete()
					oTmpTabRJ := Nil
				EndIf
				__oSt02_1 := Nil
				__oSt02_2 := Nil
				__oSt02_3 := Nil
				__oSt02_4 := Nil

				(cSRDRot)->(dbSkip())
				Loop
			EndDo
		EndIf

		(cSRDRot)->(DbCloseArea())

		//Se for o leiaute S1.0 cria tabela tempor�ria com cada recibo de f�rias
		If cVersaoEnv >= "9.0.00" .And. Len(aPeriodo) > 0 .And. !(SubStr(cCompete, 1, 2) == "12" .And. cTpFolha == "2" )
			aDadosFer := fm036GetFer((cSRAAlias)->RA_FILIAL, (cSRAAlias)->RA_MAT, dtos(aPeriodo[1,5]), dtos(aPeriodo[1,6]), SRA->RA_CATEFD, @cPdFer)
			If len(aDadosFer) > 0
				lTemFer 	:= .T.
				nNumFer 	:= 0
				cNumFer		:= ""
				cDtPgtoFer  := ""
				//Cria tabela tempor�ria para cada periodo de f�rias para executar a corpoXML
				For nY := 1 to len(aDadosFer)
					//Adiciona as colunas da tabela tempor�ria
					If Len(aColumns) == 0
						aAdd( aColumns, { "RD_FILIAL"	,"C",FwGetTamFilial,0 })
						aAdd( aColumns, { "RD_MAT"		,"C",nTamMat,0})
						aAdd( aColumns, { "RD_DATARQ"	,"C",6,0})
						aAdd( aColumns, { "RD_CC"		,"C",nTamCC,})
						aAdd( aColumns, { "RD_CCBKP"	,"C",nTamCC,0})
						aAdd( aColumns, { "RD_PD"		,"C",nTamVb,0})
						aAdd( aColumns, { "RD_PERIODO"	,"C",6,0})
						aAdd( aColumns, { "RD_ROTEIR"	,"C",nTamRot,0})
						aAdd( aColumns, { "RD_HORAS"	,"N",nTamHor,nDecHor})
						aAdd( aColumns, { "RD_VALOR"	,"N",nTamVal,nDecVal})
						aAdd( aColumns, { "RD_DATPGT"	,"C",8,0})
						aAdd( aColumns, { "RECNO"		,"N",200,0})
						aAdd( aColumns, { "TAB"			,"C",3,0})
						aAdd( aColumns, { "RD_SEMANA"	,"C", 2, 0})
						aAdd( aColumns, { "RD_NUMID"	,"C", nTamNumId, 0})
					EndIf

					oTmpFER := FWTemporaryTable():New(cSRDAlias)
					oTmpFER:SetFields( aColumns )
					oTmpFER:Create()

					//Adicionando os dados das f�rias na tabela temporaria
					For nF := 1 to len(aDadosFer[nY,6])
						If RecLock(cSRDAlias, .T.)
							(cSRDAlias)->RD_FILIAL	:= (cSRAAlias)->RA_FILIAL
							(cSRDAlias)->RD_MAT 	:= (cSRAAlias)->RA_MAT
							(cSRDAlias)->RD_DATARQ 	:= aDadosFer[nY,6,nF,1]
							(cSRDAlias)->RD_CC 		:= aDadosFer[nY,6,nF,2]
							(cSRDAlias)->RD_CCBKP	:= (cSRDAlias)->RD_CCBKP
							(cSRDAlias)->RD_PD 		:= aDadosFer[nY,6,nF,3]
							(cSRDAlias)->RD_PERIODO := aDadosFer[nY,6,nF,4]
							(cSRDAlias)->RD_ROTEIR 	:= aDadosFer[nY,6,nF,5]
							(cSRDAlias)->RD_HORAS 	:= aDadosFer[nY,6,nF,6]
							(cSRDAlias)->RD_VALOR 	:= aDadosFer[nY,6,nF,7]
							(cSRDAlias)->RD_DATPGT 	:= aDadosFer[nY,6,nF,8]
							(cSRDAlias)->RECNO 		:= aDadosFer[nY,6,nF,9]
							(cSRDAlias)->TAB 		:= aDadosFer[nY,6,nF,10]
							(cSRDAlias)->RD_SEMANA 	:= aDadosFer[nY,6,nF,11]
							(cSRDAlias)->RD_NUMID 	:= aDadosFer[nY,6,nF,12]
							(cSRDAlias)->(MsUnLock())
						EndIf
					Next nF

					(cSRDAlias)->(dbGoTop())

					If lVerRJ5
						fVerRJ5A(cSRDAlias, cSRDTabRJ, cPer1200, @lRJ5Ok, @aRJ5CC)
					EndIf
					If !lGeraRat
						fGerRatA(cSRDAlias, cSRDTabRJ, cPer1200)
					EndIf

					//Verifica se a data de pagamento das f�rias � igual ao �ltimo registro processado
					If !Empty(cDtPgtoFer) .And. cDtPgtoFer == aDadosFer[nY,5]
						nNumFer ++
						If nNumFer >= 1
							cNumFer := cValToChar(nNumFer)
						EndIf
					EndIf

					If !lVerRJ5 .Or. (lVerRJ5 .And. lRJ5Ok)
						CorpoXML(cOpcTab, cCompete, lGeraRes, aResCompl, @aLogDiss, aEstb, lComplTSV, cTpFolha, Nil, @lCPFDepOk, @aDepAgreg, cOptSimp, aTabInss, @lRJ5Ok, @aRJ5CC, @lRAZOk, lRelat, lComplCont, lExiste2300, @lDissMV, @aErros, @aLogPeric, lTemFer,,cNumFer)
					EndIf

					cDtPgtoFer := aDadosFer[nY,5] //Guarda a data de pagamento das f�rias

					//Deleta a tabela tempor�ria
					oTmpFER:Delete()
					oTmpFER := Nil

					If lVerRJ5 .Or. !lGeraRat
						oTmpTabRJ:Delete()
						oTmpTabRJ := Nil
					EndIf

				Next nX
			EndIf
		EndIf

		If SubStr(cCompete, 1, 2) == "12" .And. cTpFolha == "2" .And. !lTem132
			cOldCic		:= (cSRAAlias)->RA_CIC
			cOldNome 	:= SRA->RA_NOME
			If Select( cSRDAlias ) > 0
				(cSRDAlias)->( dbCloseArea() )
			EndIf
			If Select( cSRDTabRJ ) > 0
				(cSRDTabRJ)->( dbCloseArea() )
			EndIf

			If __oSt03 == Nil
				__oSt03 := FWPreparedStatement():New()
				cQrySt := "SELECT SRD.RD_FILIAL,SRD.RD_MAT,SRD.RD_DATARQ,SRD.RD_CC,SRD.RD_PD,SRD.RD_PERIODO,SRD.RD_ROTEIR,SUM(SRD.RD_HORAS) RD_HORAS,SUM(SRD.RD_VALOR) RD_VALOR,MAX(SRD.RD_DATPGT) RD_DATPGT, MAX(SRD.R_E_C_N_O_) RECNO,'SRD' AS TAB, SRD.RD_SEMANA "
				cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
				cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
				cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
				cQrySt += 		"SRD.RD_MAT = ? AND "
				cQrySt += 		"SRD.RD_PERIODO >= '" + cDtIni + "' AND "
				cQrySt += 		"SRD.RD_PERIODO <= '" + cDtFim + "' AND "
				cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
				cQrySt += 		"SRY.RY_TIPO = '6' AND "
				cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
				cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
				cQrySt += "GROUP BY RD_FILIAL, RD_MAT, RD_DATARQ, RD_CC, RD_PD, RD_PERIODO, RD_ROTEIR, RD_SEMANA "
				If cOpcTab == "1"
					cQrySt += "UNION ALL "
					cQrySt += "SELECT SRC.RC_FILIAL,SRC.RC_MAT,SRC.RC_PERIODO,SRC.RC_CC,SRC.RC_PD,SRC.RC_PERIODO,SRC.RC_ROTEIR,SUM(SRC.RC_HORAS) RD_HORAS,SUM(SRC.RC_VALOR) RD_VALOR,MAX(SRC.RC_DATA) RD_DATPGT, MAX(SRC.R_E_C_N_O_) RECNO,'SRC' AS TAB, SRC.RC_SEMANA "
					cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
					cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
					cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
					cQrySt += 		"SRC.RC_MAT = ? AND "
					cQrySt += 		"SRC.RC_PERIODO >= '" + cDtIni + "' AND "
					cQrySt += 		"SRC.RC_PERIODO <= '" + cDtFim + "' AND "
					cQrySt += 		"SRY.RY_TIPO = '6' AND "
					cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
					cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
					cQrySt += "GROUP BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_CC, RC_PD, RC_PERIODO, RC_ROTEIR, RC_SEMANA "
				EndIf
				cQrySt += "ORDER BY 1, 2, 3, 4, 5 "
				cQrySt := ChangeQuery(cQrySt)
				__oSt03:SetQuery(cQrySt)
			EndIf
			__oSt03:SetString(1, (cSRAAlias)->RA_FILIAL)
			__oSt03:SetString(2, (cSRAAlias)->RA_MAT)
			If cOpcTab == "1"
				__oSt03:SetString(3, (cSRAAlias)->RA_FILIAL)
				__oSt03:SetString(4, (cSRAAlias)->RA_MAT)
			EndIf
			cQrySt := __oSt03:getFixQuery()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cSRDAlias,.T.,.T.)

			If lVerRJ5 .And. lRJ5Ok
				fVerRJ5A(cSRDAlias, cSRDTabRJ, cPer1200, @lRJ5Ok, @aRJ5CC)
			EndIf

			If !lGeraRat
				fGerRatA(cSRDAlias, cSRDTabRJ, cPer1200)
			EndIf

			If (cSRDAlias)->( !EoF() )
				If !lAbriuXml
					lAbriuXml := .T.
					AbreXML(cCompete, cTpFolha, lTrabSemVinc, lComplTSV, aEstb, cOpcTab, cTrabSemVinc,nQtdeFol)
				EndIf
				If !lVerRJ5 .Or. (lVerRJ5 .And. lRJ5Ok)
					CorpoXML(cOpcTab, cCompete, lGeraRes, aResCompl, @aLogDiss, aEstb, lComplTSV, cTpFolha, lTem132, Nil, Nil, cOptSimp, aTabInss, @lRJ5Ok, @aRJ5CC, Nil, lRelat, lComplCont, lExiste2300, Nil, @aErros)
				EndIf
			EndIf
			(cSRDAlias)->(dbCloseArea())
		EndIf

		(cSRAAlias)->(DBSkip())
		lVerdDmDev := !lTrabSemVinc .Or. ( lTrabSemVinc .And. aScan( aCodDmDev, { |x| x[2] != 1 } ) == 0 )

		If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cSRAAlias)->RA_FILIAL } ) ) > 0
			cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
		EndIf

		If lAbriuXml .And. (cSRAAlias)->(!Eof())
			If !lRelat .And. lGera1200 .And. lRAZOk .And. lVerdDmDev .And. (!lVerRJ5 .Or. (lVerRJ5 .And. lRJ5Ok)) .And. ( !lAglut .Or. nQtdeFol == 1 .Or. (cSRAAlias)->(RA_CIC) != cOldCic .Or. (cEmp != cEmpOld) ) .And. (IIF(cVersaoEnv >= "2.6.00", lCPFDepOk, .T. ))
				cBkpFilEnv	:= cFilEnv
				//Para multiplo vinculo, envia o XML para a matriz
				If lAglut
					If Len(aContdmDev) > 1
						cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
						For nZ := 1 to Len(aContdmDev)
							If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
								cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1200)
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
				Begin Transaction
					lRetXml := fXml1200( @cXml, cRetfNew, cRecibo, cTpFolha, (SubStr(cCompete, 3, 4) + If(cTpFolha == "1", "-" + Substr(cCompete, 1, 2), "" )), cIdXml, cVersMw, @aErros, cPer1200, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cGpeAmbe,cVersaoEnv)
					lAbriuXml := .F.
					If lRetXml
						If !lMiddleware .And. cStatC91 $ "4"
							cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
						EndIf

						cXml := Iif(lRobo, FwNoAccent(cXml), cXml)

						If !lMiddleware
							cTafKey := cEvento + cPer1200 + cTpFolha + cOldCic
							SM0->(dbSeek( cEmpAnt + cFilEnv ))
							aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", cEvento, , "", , , , "GPE", , "", If(nQtdeFol > 1 .Or. l2300MV .Or. lDissMV, "MV", "") )
						Else
							aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1200", (SubStr(cCompete, 3, 4) + Iif(cTpFolha == "1", Substr(cCompete, 1, 2), "" )), cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, cRecibo } )
							If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
								aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na grava��o do registro na tabela RJE"
								DisarmTransaction()
							EndIf
						EndIf
					ElseIf lMiddleware
						DisarmTransaction()
					EndIf
				End Transaction

				GrvTxtArq(Alltrim(FwNoAccent(cXml)), cEvento, cOldCic)

				If Len( aErros ) > 0
					cMsgErro := ''
					If !lMiddleware
						FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
						FormText(@cMsgErro)
					Else
						For nCont := 1 To Len(aErros)
							cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
						Next nCont
					EndIf
					aErros[1] := cMsgErro
					aAdd(aLogsErr, cEvtLog + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-xxxx "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
					aAdd(aLogsErr, "" )
					aAdd(aLogsErr, aErros[1] )
					If lTrabSemVinc
						aEmp_1200[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1200[2]++ //Inclui TCV nao integrado
					EndIf
				Else
					If !lMiddleware
						aAdd(aLogsOk, cEvtLog + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0049) ) //##"Registro S-xxxx "##" Integrado com TAF."
					Else
						aAdd(aLogsOk, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0165) ) //##"Registro S-1200 do Funcion�rio: "##" Integrado com Middleware."
					EndIf
					If lMsgDiss
						aAdd(aLogsOk, OemToAnsi(STR0177) + OemToAnsi(STR0178) ) //##""Valores de diss�dio anteriores ao per�odo selecionado foram integrados."
						aAdd(aLogsOk, OemToAnsi(STR0179) ) //##"Caso a integra��o seja indevida consulte orienta��o em https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018603231"
					EndIf
					aAdd(aLogsOk, "" )
					If lTrabSemVinc
						aEmp_1200[3]++ //Inclui TSV integrado
					Else
						aEmp_1200[1]++ //Inclui TCV integrado
					EndIf
				Endif
				If !Empty(aLogDiss)
					For nCont := 1 To Len(aLogDiss)
						aAdd(aLogsOk, aLogDiss[nCont] )
					Next nCont
					aAdd(aLogsOk, "" )
				EndIf
				cFilEnv	:= cBkpFilEnv
				If !lCPFDepOk
					For nCont := 1 To Len(aDepAgreg)
						aAdd(aLogsOk, aDepAgreg[nCont] )
					Next nCont
					aAdd(aLogsOk, "" )
				EndIf
			ElseIf cVersaoEnv >= "2.6.00" .AND. !lCPFDepOk
				For nCont := 1 To Len(aDepAgreg)
					aAdd(aLogsErr, aDepAgreg[nCont] )
				Next nCont
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf !lVerdDmDev
				aAdd(aLogsErr, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
				aAdd(aLogsErr, OemToAnsi(STR0057) )//"Trabalhador sem v�nculo possui mais de um recibo de pagamento com o mesmo identificador"
				aAdd(aLogsErr, OemToAnsi(STR0058) )//"Ser� necess�rio efetuar a ativa��o do par�metro MV_PERAUT atrav�s do m�dulo Configurador"
				aAdd(aLogsErr, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=415710563" )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf lVerRJ5 .And. !lRJ5Ok
				aAdd(aLogsErr, If(!lGera1202,OemToAnsi(STR0021) ,OemToAnsi(STR0218)) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
				aAdd(aLogsErr, OemToAnsi(STR0068) )//"O(s) centro(s) de custo abaixo n�o possuem relacionamento na tabela RJ5 - Relacionamentos CTT:"
				For nCont := 1 To Len(aRJ5CC)
					aAdd(aLogsErr, aRJ5CC[nCont] )
				Next nCont
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			ElseIf !lRAZOk
				aAdd(aLogsErr, If(!lGera1202,OemToAnsi(STR0021) ,OemToAnsi(STR0218)) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
				aAdd(aLogsErr, OemToAnsi(STR0073) )//"Existem registros duplicados encontrados nas tabelas RAW/RAZ, por favor acesse a "
				aAdd(aLogsErr, OemToAnsi(STR0074) )//rotina de M�ltiplos v�nculos e realize as devidas corre��es. Mais informa��es em: http://tdn.totvs.com/x/cUClGw.
				aAdd(aLogsErr, "" )
			ElseIf lRelat .And. !lVerdDmDev
				aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0057) + " " + OemToAnsi(STR0058) + " " + OemToAnsi(STR0053) + "http://tdn.totvs.com/x/Yz3HG"} )//"Trabalhador sem v�nculo possui mais de um recibo de pagamento com o mesmo identificador"##"Ser� necess�rio efetuar a ativa��o do par�metro MV_PERAUT atrav�s do m�dulo Configurador"##"Para mais informa��es, consulte a documenta��o dispon�vel em: "
			ElseIf lRelat .And. lVerRJ5 .And. !lRJ5Ok
				aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0068)} )//"O(s) centro(s) de custo abaixo n�o possuem relacionamento na tabela RJ5 - Relacionamentos CTT:"
				For nCont := 1 To Len(aRJ5CC)
					aAdd(aLogsErr, aRJ5CC[nCont] )
					aAdd( aRelIncons, { cOldFil, cOldCic, aRJ5CC[nCont]} )
				Next nCont
			ElseIf lRelat .And. !lRAZOk
				aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0073) + OemToAnsi(STR0074)} )//"Existem registros duplicados encontrados nas tabelas RAW/RAZ, por favor acesse a "##"rotina de M�ltiplos v�nculos e realize as devidas corre��es. Mais informa��es em: http://tdn.totvs.com/x/cUClGw."
			EndIf
		EndIf
	End

	If lAbriuXml .And. !lExcLote
		If !lRelat .And. lGera1200 .And. lVerdDmDev .And. (!lVerRJ5 .Or. (lVerRJ5 .And. lRJ5Ok)) .And. (IIF(cVersaoEnv >= "2.6.00", lCPFDepOk, .T. )) .AND. lFornPLA
			lAbriuXml := .F.
			//Para multiplo vinculo, envia o XML para a matriz
			If lAglut
				If Len(aContdmDev) > 1
					cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
					For nZ := 1 to Len(aContdmDev)
						If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
							cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1200)
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
			Begin Transaction
				lRetXml := fXml1200( @cXml, cRetfNew, cRecibo, cTpFolha, (SubStr(cCompete, 3, 4) + If(cTpFolha == "1", "-" + Substr(cCompete, 1, 2), "" )), cIdXml, cVersMw, @aErros, cPer1200, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cGpeAmbe, cVersaoEnv, aInfoC)
				If lRetXml
					If !lMiddleware .And. cStatC91 $ "4"
						cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
					EndIf

					cXml := Iif(lRobo, FwNoAccent(cXml), cXml)

					If !lMiddleware
						cTafKey := cEvento + cPer1200 + cTpFolha + cOldCic
						SM0->(dbSeek( cEmpAnt + cFilEnv ))
					    aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", cEvento, , "", , , , "GPE", , "", If(nQtdeFol > 1 .Or. l2300MV .Or. lDissMV, "MV", "") )
					Else
						aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1200", (SubStr(cCompete, 3, 4) + Iif(cTpFolha == "1", Substr(cCompete, 1, 2), "" )), cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, Nil, cRecibo } )
						If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
							aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na grava��o do registro na tabela RJE"
							DisarmTransaction()
						EndIf
					EndIf
				ElseIf lMiddleware
					DisarmTransaction()
				EndIf
			End Transaction

			GrvTxtArq(Alltrim(FwNoAccent(cXml)), cEvento, cOldCic)

			If Len( aErros ) > 0
				cMsgErro := ''
				If !lMiddleware
					FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
					FormText(@cMsgErro)
				Else
					For nCont := 1 To Len(aErros)
						cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
					Next nCont
				EndIf
				aErros[1] := cMsgErro
				aAdd(aLogsErr, cEvtLog + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-xxxx "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
				aAdd(aLogsErr, "" )
				aAdd(aLogsErr, aErros[1] )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			Else
				If !lMiddleware
					aAdd(aLogsOk, cEvtLog + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0049) ) //##"Registro S-xxxx "##" Integrado com TAF."
				Else
					aAdd(aLogsOk, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0165) ) //##"Registro S-1200 do Funcion�rio: "##" Integrado com Middleware."
				EndIf

				If lMsgDiss
					aAdd(aLogsOk, OemToAnsi(STR0177) + OemToAnsi(STR0178) ) //##""Valores de diss�dio anteriores ao per�odo selecionado foram integrados."
					aAdd(aLogsOk, OemToAnsi(STR0179) ) //##"Caso a integra��o seja indevida consulte orienta��o em https://centraldeatendimento.totvs.com/hc/pt-br/articles/360018603231"
				EndIf

				aAdd(aLogsOk, "" )
				If lTrabSemVinc
					aEmp_1200[3]++ //Inclui TSV integrado
				Else
					aEmp_1200[1]++ //Inclui TCV integrado
				EndIf
			Endif
			If !Empty(aLogDiss)
				For nCont := 1 To Len(aLogDiss)
					aAdd(aLogsOk, aLogDiss[nCont] )
				Next nCont
				aAdd(aLogsOk, "" )
			EndIf
			If !lCPFDepOk
				For nCont := 1 To Len(aDepAgreg)
					aAdd(aLogsOk, aDepAgreg[nCont] )
				Next nCont
				aAdd(aLogsOk, "" )
			EndIf

			If Len(aLogPeric) > 0
				For nRegPeric := 1 To Len(aLogPeric)
					aAdd(aLogsOk, aLogPeric[nRegPeric] )
				Next nRegPeric
				aAdd(aLogsOk, "" )
			EndIf

		ELSEIF cVersaoEnv >= "2.6.00" .AND. !lCPFDepOk
			For nCont := 1 To Len(aDepAgreg)
				aAdd(aLogsErr, aDepAgreg[nCont] )
			Next nCont
			aAdd(aLogsErr, "" )
			If lTrabSemVinc
				aEmp_1200[4]++ //Inclui TSV nao integrado
			Else
				aEmp_1200[2]++ //Inclui TCV nao integrado
			EndIf
		ElseIf !lVerdDmDev
			aAdd(aLogsErr, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
			aAdd(aLogsErr, OemToAnsi(STR0057) )//"Trabalhador sem v�nculo possui mais de um recibo de pagamento com o mesmo identificador"
			aAdd(aLogsErr, OemToAnsi(STR0058) )//"Ser� necess�rio efetuar a ativa��o do par�metro MV_PERAUT atrav�s do m�dulo Configurador"
			aAdd(aLogsErr, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=415710563" )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
			aAdd(aLogsErr, "" )
			If lTrabSemVinc
				aEmp_1200[4]++ //Inclui TSV nao integrado
			Else
				aEmp_1200[2]++ //Inclui TCV nao integrado
			EndIf
		ElseIf lVerRJ5 .And. !lRJ5Ok
			aAdd(aLogsErr, If(!lGera1202,OemToAnsi(STR0021) ,OemToAnsi(STR0218)) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
			aAdd(aLogsErr, OemToAnsi(STR0068) )//"O(s) centro(s) de custo abaixo n�o possuem relacionamento na tabela RJ5 - Relacionamentos CTT:"
			For nCont := 1 To Len(aRJ5CC)
				aAdd(aLogsErr, aRJ5CC[nCont] )
			Next nCont
			aAdd(aLogsErr, "" )
			If lTrabSemVinc
				aEmp_1200[4]++ //Inclui TSV nao integrado
			Else
				aEmp_1200[2]++ //Inclui TCV nao integrado
			EndIf
		ElseIf !lRAZOk
			aAdd(aLogsErr, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) ) //##"Registro S-1200 do Funcion�rio: "##" n�o foi integrado devido ao(s) erro(s) abaixo: "
			aAdd(aLogsErr, OemToAnsi(STR0073) )//"Existem registros duplicados encontrados nas tabelas RAW/RAZ, por favor acesse a "
			aAdd(aLogsErr, OemToAnsi(STR0074) )//rotina de M�ltiplos v�nculos e realize as devidas corre��es. Mais informa��es em: http://tdn.totvs.com/x/cUClGw.
			aAdd(aLogsErr, "" )
		ElseIf lRelat .And. !lVerdDmDev
			aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0057) + " " + OemToAnsi(STR0058) + " " + OemToAnsi(STR0053) + "http://tdn.totvs.com/x/Yz3HG"} )//"Trabalhador sem v�nculo possui mais de um recibo de pagamento com o mesmo identificador"##"Ser� necess�rio efetuar a ativa��o do par�metro MV_PERAUT atrav�s do m�dulo Configurador"##"Para mais informa��es, consulte a documenta��o dispon�vel em: "
		ElseIf lRelat .And. lVerRJ5 .And. !lRJ5Ok
			aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0068)} )//"O(s) centro(s) de custo abaixo n�o possuem relacionamento na tabela RJ5 - Relacionamentos CTT:"
			For nCont := 1 To Len(aRJ5CC)
				aAdd(aLogsErr, aRJ5CC[nCont] )
				aAdd( aRelIncons, { cOldFil, cOldCic, aRJ5CC[nCont]} )
			Next nCont
		ElseIf lRelat .And. !lRAZOk
			aAdd( aRelIncons, { cOldFil, cOldCic, OemToAnsi(STR0073) + OemToAnsi(STR0074)} )//"Existem registros duplicados encontrados nas tabelas RAW/RAZ, por favor acesse a "##rotina de M�ltiplos v�nculos e realize as devidas corre��es. Mais informa��es em: http://tdn.totvs.com/x/cUClGw.
		ElseIf !lFornPLA
			If Len(aFornPLA)> 0
				aAdd(aLogsErr, OemToAnsi(STR0021) + cOldCic + " - " + AllTrim(cOldNome) + OemToAnsi(STR0029) )
				For nCont := 1 To Len(aFornPLA)
					aAdd(aLogsErr, " - " + aFornPLA[nCont,4] )
					aAdd(aLogsErr, " - " + aFornPLA[nCont,5] )
				Next nCont
				aAdd(aLogsErr, "" )
				If lTrabSemVinc
					aEmp_1200[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1200[2]++ //Inclui TCV nao integrado
				EndIf
			EndIf
		EndIf
	EndIf

	(cSRAAlias)->(DBCloseArea())
	If lAglut
		(cSRAAliasMV)->(DBCloseArea())
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

cFilAnt := cBkpFil // Mantem cFilAnt conectado no sistema

dbSelectArea('SRV')
dbClearFilter()
RetIndex("SRV")
FErase(cArqTemp+OrdBagExt())

If !lRelat
	aAdd(aLogsPrc, OemToAnsi(STR0039) + cValToChar(aEmp_1200[1]) ) 	//"Trabalhadores com v�nculo integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0040) + cValToChar(aEmp_1200[2]) )	//"Trabalhadores com v�nculo n�o Integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0041) + cValToChar(aEmp_1200[3]) )	//"Trabalhadores sem v�nculo integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0042) + cValToChar(aEmp_1200[4]) )	//"Trabalhadores sem v�nculo n�o Integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0043) + cValToChar( aEmp_1200[1] + aEmp_1200[3] ) )	//"Total de registros integrados: "
	aAdd(aLogsPrc, OemToAnsi(STR0044) + cValToChar(aEmp_1200[2] + aEmp_1200[4]) )	//"Total de registros n�o integrados: "

	aAdd(aLogsPrc,"")
	aAdd(aLogsPrc, Replicate("-",132) )
	aAdd(aLogsPrc, OemToAnsi(STR0069)+": " +  SecsToTime(nHrInicio))				//Inicio Processamento:
	nHrFim 	:= SecsToTime(Seconds())
	aAdd(aLogsPrc,+OemToAnsi(STR0070)+":    " + nHrFim)							//Fim Processamento:
	aAdd(aLogsPrc,"")
	aAdd(aLogsPrc,OemToAnsi(STR0071+": " + SecsToTime(Seconds() - nHrInicio)))		//Duracao do Processamento
Else
	fGeraRelat( cCompete )
EndIf

aEvtRemun 	:= {}
aIdeEven 	:= {}
aIdeTrabal 	:= {}
aProcJud 	:= {}
aInfMV	 	:= {}
aRemOutEmp 	:= {}
aInfCompl 	:= {}
aInfInter 	:= {}
aDmDev	 	:= {}
aInfPerApur	:= {}
aEstLotApur	:= {}
aRemPerApur	:= {}
aItRemApur 	:= {}
aInfSauCole	:= {}
aDetOper 	:= {}
aDetPlano 	:= {}
aInfAgNoc 	:= {}
aInfTrabInt	:= {}
aInfPerAnt 	:= {}
aIdeADCAnt 	:= {}
aIdePer 	:= {}
aEstLotAnt 	:= {}
aRemPerAnt 	:= {}
aItRemAnt 	:= {}
aAgNocAnt 	:= {}
aComplCont	:= {}
aRelIncons	:= {}
aFuncDem 	:= {}

return

/*/{Protheus.doc} AbreXML
Cria tags de abertura do layout 1200 e-social
@author Oswaldo Leite
@since 01/06/2017
@return NIL,
@param cCompete, characters, Compet�ncia
@param cTpFolha, characters, Tipo de folha: Folha ou 13�
@param lTrabSemVinc, logical, Indica se � trabalhador com v�nculo ou n�o
@param lComplTSV, logical,
@param aEstb, array, Informa��es do estabelecimento
@param aCompTSV, array,
@param cTrabSemVinc, characters, Categorias sem v�nculo
@param nQtdeFol, integer, Quantidade de folhas
@example
(examples)
@see (links_or_references)
/*/
Static Function AbreXML(cCompete, cTpFolha, lTrabSemVinc, lComplTSV, aEstb, cOpcTab, cTrabSemVinc,nQtdeFol, cVersEnv, aPeriodo)

	Local cNomTrab	:= ""
	Local cNomAux	:= ""
	Local cPerApur	:= ""
	Local nDiasInt	:= 0
	Local aProcRJJ	:= {}
	Local aVinculoT	:= ""

	DEFAULT lComplTSV 	:= .F.
	DEFAULT aEstb		:= {}
	DEFAULT cOpcTab		:= "01"
	DEFAULT nQtdeFol	:= 1
	DEFAULT cVersEnv	:= ""
	Default aPeriodo	:= {}

	aDadosRAZ := {}
	lUnicaTag := .T.

	cXml := ''

	//Para localizarmos os dados da RAZ(que s�o listados no cabe�alho do XML aonde nao tenho SRD ainda) seria necessario re-fazer a mesma pesquisa duas vezes,
	//entao aproveitamos a unica pesquisa efetuada para verificar se h� dados da Raz
	//mantendo o cabe�alho quebrado em variaveis ...e no final do programa concatenamos tudo. Desta forma evitramso duplicar a pesquisa que j� era lenta
	cCabPart1 := ""
	cCabRAZ   := ""
	cCabPart2 := ""

	cPerApur := SubStr(cCompete, 3, 4) + If(cTpFolha == "1", "-" + Substr(cCompete, 1, 2), "" ) // No 13� enviar apenas o ano

	aAdd( aEvtRemun, { (cSRAAlias)->RA_CIC, SRA->RA_NOME } )//<evtRemun>
	aAdd( aIdeEven, { "1", Nil, cTpFolha, cPerApur, Nil, Nil, Nil, (cSRAAlias)->RA_CIC } )//<ideEvento> -> <indRetif>, <nrRecibo>, <indApuracao>, <perApur>, <tpAmb>, <procEmi>, <verProc>
	aAdd( aIdeTrabal, { (cSRAAlias)->RA_CIC, If((cVersEnv >= "9.0.00" .Or. Empty(SRA->RA_PIS) .And. SRA->RA_CATEFD $ "901|903|904"), Nil, AllTrim(SRA->RA_PIS)) } )//<ideTrabalhador> -> <cpfTrab>, <nisTrab>

	If !lGera1202
		If lTemRJJ
				aProcRJJ := fBuscaRJJ( (cSRAAlias)->RA_CIC, SubStr(cCompete, 3, 4)+SubStr(cCompete, 1, 2) )
				If !Empty(aProcRJJ)
					aAdd( aProcJud, { aClone(aProcRJJ), (cSRAAlias)->RA_CIC } )//<procJudTrab> -> <cpfTrab>
				EndIf
			EndIf
		Endif
		If !lTrabSemVinc
			If !lGera1202
			If SRA->RA_CATEFD == '111'
				nDiasInt := fDiasInter(SRA->RA_FILIAL,SRA->RA_MAT,cCompete, cOpcTab)
				If nDiasInt > 0 .Or. cVersEnv >= "9.0.00"
					aAdd( aInfInter, { nDiasInt, (cSRAAlias)->RA_CIC } )//<infoInterm> -> <qtdDiasInterm>
					If cVersEnv	>= "9.0.00" .And. Len(aPeriodo) > 0
						aDiasConv := fDiasConv(aPeriodo[1,5], aPeriodo[1,6], SubStr(cCompete, 3, 4) + Substr(cCompete, 1, 2))
					EndIf
				EndIf
			Endif
		Endif
	Else
		If lComplTSV
			setInfCmpl(@aInfCompl) //<infoComplem> -> <nmTrab>, <dtNascto>
		EndIf
	EndIf

	//Pesquisa os dados de sucessao de vinculo
	//trecho deve ser liberado e validado quando <remunSuc> for S - Tratamento futuro
	If cVersEnv	>= "2.6.00" .And. cVersEnv < "9.00.00"
		aVinculoT 	:= fGM23Vinc(SRA->RA_FILIAL, SRA->RA_MAT, cVersEnv)
		If Len(aVinculoT) > 0 //<sucessaoVinc> -> <tpInsc>, <nrInsc>, <matricAnt>, <dtAdm>, <observacao>
			aAdd( aSucVinc, { aVinculoT[1,13], aVinculoT[1,4], aVinculoT[1,5], dtos(aVinculoT[1,6]), aVinculoT[1,7], (cSRAAlias)->RA_CIC } )
		EndIf
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CorpoXml       �Autor �Oswaldo Leite    � Data �  01/06/17  ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria tags das diversas filiais aonde achamos cpf do funcion.���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CorpoXML(cOpcTab, cCompete, lGeraRes, aResCompl, aLogDiss, aEstb, lComplTSV, cTpFolha, lTem132, lCPFDepOk, aDepAgreg, cOptSimp, aTabInss, lRJ5Ok, aErrosRJ5, lRAZOk, lRelat, lComplCont, lExiste2300, lDissMV , aErros, aLogPeric, lFer, cTpRes, cNumFer)

	Local cVerIndSimples := ''
	Local cCCAnt        := ''
	Local nPosLot       := 0
	Local lAbriuTagLote := .F.
	Local cTpInscr      := ''
	Local cInscr        := ''
	Local cIdTbRub      := ''
	Local adadosRHS     := {}
	Local nW            := 0
	Local nC            := 0
	Local aLstDeps      := {}
	Local cOcorren		:= ""
	Local cBolsistas    := '901|902|903|904|905|'
	Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'
	Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
	Local cVersaoEnv   	:= ""
	Local cBusca		:= ""
	Local lCarrDep		:= .F.
	Local lGeraCod      := .F.
	Local nPercRub		:= 0
	Local dDatEfeito	:= CTOD("//")
	Local lAbriu21		:= .F.
	Local lFechou21		:= .F.
	Local lAbriu20		:= .F.
	Local lAbriu19		:= .F.
	Local cTpRotBkp		:= fGetTipoRot( (cSRDAlias)->RD_ROTEIR )
	Local cPerAnt		:= ""
	Local cRHHAlias		:= GetNextAlias()
	Local cRHHFilAnt	:= ""
	Local cDataCor		:= ""
	Local cDataRHH		:= ""
	Local cDscAc		:= ""
	Local cTpAco		:= ""
	Local cPerRef		:= ""
	Local aIdeAdc		:= {}
	Local lFirstAnt		:= .T.
	Local lGeraPer 		:= .F.
	Local lGerouAnt		:= .F.
	Local lFechPer		:= .F.
	Local lGeraEstLot	:= .F.
	Local lFechEstLot 	:= .F.
	Local lTemVerbas	:= .F.
	Local cMatricula	:= Iif( SRA->RA_CATEFD $ (cBolsistas + cContrib), "", SRA->RA_CODUNIC )//Nao envia matricula para essas categorias
	Local aVbDiss		:= {}
	Local cDissNumId	:= ""
	Local cPerDiss		:= ""
	Local cPerIni		:= ""
	Local cPerFim		:= ""
	Local lTemDiss		:= .F.
	Local nParDiss		:= 1
	Local cDtPgto		:= ""
	Local aConvocs		:= {}
	Local lVerDINSS		:= .T.
	Local lGerDINSS		:= .F.
	Local cVerbBus		:= ""
	Local aAreaSRV		:= {}
	Local aCompTSV		:= {}
	Local lGeraVbDis	:= .F.
	Local lPagPost		:= .F.
	Local cCodigoVb		:= ""
	Local nHorasVb		:= 0
	Local nValorVb		:= 0
	Local aRetifAfas	:= {}
	Local aAuxDoenca	:= {}
	Local cPdCod0021	:= aCodFol[21,1]
	Local cPdCod0022	:= aCodFol[22,1]
	Local cPdCod1655	:= If( Len(aCodFol) >= 1655, aCodFol[1655,1], "   " )
	Local aNomes		:= {}
	Local aTabInss2		:= {}
	Local cPerDoeAnt	:= ""
	Local cDmDev		:= ""
	Local cBkpDmDev		:= ""
	Local nPosDmDev		:= 0
	Local nContRes		:= 0
	Local nTotVezes		:= 0
	Local nFilRHH		:= 0
	Local cCodFol
	Local cCodFil
	Local cCodNat
	Local cCodINCCP
	Local cCodINCIRF
	Local cCodINCFGT
	Local cIncINS
	Local cIncIRF
	Local cIncFGT
	Local cTpCod
	Local cCodPerc
	Local aRegRaz		:= {}
	Local nPosItRem		:= 0
	Local nPosDetOper	:= 0
	Local nPosDetPla	:= 0
	Local aTransfFun 	:= {}
	Local nContTrf		:= 0
	Local lPrimIdT		:= .T.
	Local cIdeRubr		:= ""
	Local cChaveS1005	:= ""
	Local lMesAnt		:= .F.
	Local cNumId		:= ""
	Local cMatAnt		:= ""
	Local cIdsPerIns	:= ""
	Local nPosRaz		:= 0
	Local nPosEstb		:= 0
	Local cNrInsc		:= ""
	Local nTam			:= 0
	Local cCatEFDTSV	:= fCatTrabEFD("TSV")
	Local lRVIncop		:= SRV->(ColumnPos("RV_INCOP"))> 0
	Local lRVTetop 		:= SRV->(ColumnPos("RV_TETOP"))> 0
	Local cIncop		:= ""
	Local cTetoP 		:= ""
	Local aDissidio		:= {}
	Local nD			:= 0
	Local nPosDis		:= 0
	Local cBkpPerDis	:= ""
	Local cDtAco		:= ""
	Local cNrBen		:= ""
	Local lAchouRHH		:= .F.
	Local nPosMat		:= 1
	Local nSeekSRK		:= 1
	Local cFilSRK		:= ""
	Local cMatSRK		:= ""
	Local cClasTrib		:= ""
	Local cErr			:= ""
	Local cnatAtiv		:= ""
	Local aVinc			:= {}
	Local lInfoAg		:= .F.

	DEFAULT cOpcTab		:= "0"
	DEFAULT lGeraRes	:= .F.
	DEFAULT aResCompl	:= {}
	DEFAULT aLogDiss	:= {}
	DEFAULT lComplTSV	:= .F.
	DEFAULT aEstb		:= {}
	DEFAULT cTpFolha	:= "1"
	DEFAULT lTem132		:= .T.
	DEFAULT lCPFDepOk	:= .T.
	DEFAULT aDepAgreg	:= {}
	DEFAULT cOptSimp	:= "2"
	DEFAULT aTabInss	:= {}
	DEFAULT lRJ5Ok		:= .T.
	DEFAULT aErrosRJ5	:= {}
	DEFAULT lDissMV		:= .F.
	DEFAULT aErros		:= {}
	Default aLogPeric	:= {}
	Default lFer		:= .F.
	Default cTpRes		:= ""
	Default cNumFer		:= ""

	If FindFunction("fVersEsoc")
		If !lGera1202
			fVersEsoc( "S1200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersaoEnv )
		Else
			fVersEsoc( "S1202", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersaoEnv )
		Endif
	Else
		cVersaoEnv := '2.2'
	EndIf

	If lGeraMat .And. (SRA->RA_DESCEP == "1") .And. SRA->RA_CATEFD $ (cCatEFDTSV)
		cMatricula := SRA->RA_CODUNIC
	EndIf

	If !lMiddleware
		If !Empty(cMatricula)
			cMatricula := StrTran(cMatricula, "&","&#38;" )
		EndIf
	EndIf

	lPagPost := ( !lGeraRes .And. !Empty(SRA->RA_DEMISSA) .And. (SubStr(cCompete,3,4) + SubStr(cCompete,1,2)) > AnoMes(SRA->RA_DEMISSA) )

	If lFer
		cDtPgto := (cSRDAlias)->RD_DATPGT
	ElseIf !lDtPgto
		cDtPgto := fVerDtPgto( (cSRDAlias)->RD_DATPGT, (cSRDAlias)->TAB, (cSRDAlias)->RECNO )
	Else
		cDtPgto := (cSRDAlias)->RD_DATPGT
	EndIf

	IF SRA->RA_CATEFD $ cCatTSV .And. ( lComplTSV .Or. (!lExiste2300 .And. lComplCont) )
		nPos := aScan(aEstb, {|x| AllTrim(x[1]) == AllTrim(SRA->RA_FILIAL)})
		If FindFunction("TAF050ClassTrib") .And. nPos > 0
			cClasTrib := TAF050ClassTrib(aEstb[nPos][5]+aEstb[nPos][1], @cErr)
		Endif

		IF nPos > 0 .And. Len(aEstb[nPos]) >= 6 .And. aEstb[nPos][6]
			aCompTSV := {fGM26Fun(SRA->RA_CODFUNC, SRA->RA_FILIAL)[2], '2',"" }
		ELSE
			aCompTSV := {fGM26Fun(SRA->RA_CODFUNC, SRA->RA_FILIAL)[2], NIL, If(!Empty(cClasTrib), cClasTrib,"") } //infoComplCont {"codCBO", "natAtividade" }
		ENDIF
	ENDIF

	If SRA->RA_CATEFD $ fCatTrabEFD("CES") //401|410 verifica categOrig p/ gerar <infoAgNocivo>
		aVinc := fGM23Vinc(SRA->RA_FILIAL, SRA->RA_MAT, cVersaoEnv)
		If Len(aVinc) > 0 .And. !Empty(aVinc[1][10]) //RFZ_CATEG
			lInfoAg := ( AllTrim(aVinc[1][10]) $ (fCatTrabEFD("TCV") + fCatTrabEFD("AVU") + fCatTrabEFD("AGE") + "731|734|738|") )
		EndIf
	EndIf

	//[ PODEM SER N REGISTROS ]
	If lAglut .And. (SRA->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1)//MultV
		If cVersaoEnv >= "9.0.00"
		  	If (ANOMES(SRA->RA_DEMISSA) == SubStr(cCompete,3,4) + SubStr(cCompete,1,2)) .And. ;
			  ((cSRDAlias)->RD_ROTEIR $ "FOL*AUT" .And. (SRA->RA_CATEFD $ (cCatEFDTSV) .And. SRA->RA_CATEFD <> "721")  .Or.;
			  (lGera1202 .And. SRA->RA_VIEMRAI $ "30|31|35" ))
				cDmDev := "R" + cEmpAnt + Alltrim((cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_MAT + If(cTpRes == "3", "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
				nQtdeMV -= 1
			Else
				If nQtdeMV == 1
					cDmDev := (cSRDAlias)->RD_FILIAL + cDtPgto + (cSRDAlias)->RD_PERIODO + (cSRDAlias)->RD_ROTEIR
				Else
					cDmDev := (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + SubStr( cDtPgto, 3 ) + SubStr( (cSRDAlias)->RD_PERIODO, 3 ) + (cSRDAlias)->RD_ROTEIR
				Endif
			Endif
		Else
			cDmDev := (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + SubStr( cDtPgto, 3 ) + SubStr( (cSRDAlias)->RD_PERIODO, 3 ) + (cSRDAlias)->RD_ROTEIR
		Endif
		If Len(cDmDev) > 30
			cDmDev := (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + SubStr( cDtPgto, 7 ) + fGetTipoRot( (cSRDRot)->RD_ROTEIR )
		EndIf
	Else
		// Para TSV diferente de 721 e com rescis�o no m�s o cDmDev ser� gerado nos moldes da rescis�o
		If cVersaoEnv >= "9.0.00" .And. (ANOMES(SRA->RA_DEMISSA) == SubStr(cCompete,3,4) + SubStr(cCompete,1,2)) .And. ;
		 ((cSRDAlias)->RD_ROTEIR $ "FOL*AUT" .And. (SRA->RA_CATEFD $ (cCatEFDTSV) .And. SRA->RA_CATEFD <> "721") .Or. (lGera1202 .And. SRA->RA_VIEMRAI $ "30|31|35") )
			cDmDev := "R" + cEmpAnt + Alltrim((cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_MAT + If(cTpRes == "3", "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
		Else
			cDmDev := (cSRDAlias)->RD_FILIAL + cDtPgto + (cSRDAlias)->RD_PERIODO + (cSRDAlias)->RD_ROTEIR + cNumFer
		EndIf
		If (nPosDmDev := aScan(aCodDmDev, { |x| x[1] == cDmDev }) ) == 0
			aAdd(aCodDmDev, { cDmDev, 1 })
		Else
			aCodDmDev[nPosDmDev, 2] += 1
		EndIf
	EndIf

	If lGera1207
		cNrBen := (cSRDAlias)->RD_NRBEN
		If aScan(aDmDev, { |x| x[1]+x[2]+x[3] == cDmDev + cNrBen + SRA->RA_CIC } ) == 0
			aAdd( aDmDev, { cDmDev, cNrBen, SRA->RA_CIC, SRA->RA_MAT, SRA->RA_FILIAL } )//<dmDev>
		EndIf
	ElseIf aScan(aDmDev, { |x| x[1]+x[2]+x[3] == cDmDev+SRA->RA_CATEFD+SRA->RA_CIC } ) == 0
		aAdd( aDmDev, { cDmDev, SRA->RA_CATEFD, SRA->RA_CIC, SRA->RA_MAT, SRA->RA_FILIAL } )//<dmDev>
	EndIf

	If !lGeraRes .Or. (Len(aResCompl) > 1 .And. lDtPgto .And. !(aScan(aResCompl, { |x| x[1] <> "1" } ) > 0))
		nTotVezes := 1
	Else
		nTotVezes := Len(aResCompl)
	EndIf

	For nContRes := 1 To nTotVezes
		If !lGeraRes
			If !lPagPost
				If aScan(aInfPerApur, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD) }) == 0
					aAdd( aInfPerApur, { SRA->RA_CIC, cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD) } )//<infoPerApur>
				EndIf
			Else
				cPerRef	:= SubStr(cCompete,3,4) + "-" + SubStr(cCompete,1,2)
				cTpAco	:= "F"
				If aScan(aInfPerAnt, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
					aAdd( aInfPerAnt, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<infoPerAnt>
				EndIf
				If aScan(aIdeADCAnt, { |x| x[2]+x[5]+x[6]+x[7]+x[8] == cTpAco+OemToAnsi(STR0035)+"N"+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
					aAdd( aIdeADCAnt, { "", cTpAco, Nil, Nil, OemToAnsi(STR0035), "N", SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<ideADC> //STR0035 = "Pagamento PLR / Outras verbas devidas"
				EndIf
				If aScan(aIdePer, { |x| x[1]+x[2]+x[3] == cPerRef+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco }) == 0
					aAdd( aIdePer, { cPerRef, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco } )//<idePeriodo>
				EndIf
			EndIf
		Else
			cCCAnt	:= ""
			cPerAnt	:= ""
			If aResCompl[nContRes, 1] == "1"
				If !lAbriu19
					If aScan(aInfPerAnt, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
						aAdd( aInfPerAnt, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<infoPerAnt>
					EndIf
				EndIf
				cPerRef	:= aResCompl[nContRes, 2]
				cTpAco 	:= "F"
				If aScan(aIdeADCAnt, { |x| x[2]+x[5]+x[6]+x[7]+x[8] == cTpAco+OemToAnsi(STR0035)+"N"+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
					aAdd( aIdeADCAnt, { "", cTpAco, "", "", OemToAnsi(STR0035), "N", SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<ideADC> //STR0035 = "Pagamento PLR / Outras verbas devidas"
				EndIf
				If aScan(aIdePer, { |x| x[1]+x[2]+x[3] == cPerRef+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco }) == 0
					aAdd( aIdePer, { cPerRef, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco } )//<idePeriodo>
				EndIf
				lAbriu21 := .T.
				lAbriu20 := .T.
				lAbriu19 := .T.
				lTemDiss := .F.
			ElseIf aResCompl[nContRes, 1] == "2"
				cDscAc := fGetDscAc(.T., cTpRotBkp, cCompete, @dDatEfeito)
				cTpAco := fGetTpAc(.T., cTpRotBkp, cCompete, @cDataCor, @cDataRHH)
				If !Empty(cDscAc) .And. !Empty(cTpAco)
					cPerRef	:= aResCompl[nContRes, 2]
					If !lAbriu19
						If aScan(aInfPerAnt, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
							aAdd( aInfPerAnt, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<infoPerAnt>
						EndIf
					EndIf
					If aScan(aIdeADCAnt, { |x| If(cVersaoEnv < "9.0.0", x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] == cDataCor+cTpAco+SubStr(cCompete,3,4) + "-" + SubStr(cCompete,1,2)+dToS(dDatEfeito)+cDscAc+"N"+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD, x[1]+x[2]+x[5]+x[6]+x[7]+x[8] = cDataCor+cTpAco+cDscAc+"N"+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD )}) == 0
						aAdd( aIdeADCAnt, { cDataCor, cTpAco, If(cVersaoEnv < "9.0.00", SubStr(cCompete,3,4) + "-" + SubStr(cCompete,1,2), Nil), If(cVersaoEnv < "9.0.00", dToS(dDatEfeito), Nil), cDscAc, "N", SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<ideADC>
					EndIf
					If aScan(aIdePer, { |x| x[1]+x[2]+x[3] == cPerRef+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco }) == 0
						aAdd( aIdePer, { cPerRef, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco } )//<idePeriodo>
					EndIf
					lAbriu21 := .T.
					lAbriu20 := .T.
					lAbriu19 := .T.
				Endif
				lTemDiss := .T.
			Endif
		Endif

		If lGeraRes .And. !lDtPgto
			If Select( cSRDAlias ) > 0
				(cSRDAlias)->( dbCloseArea() )
			EndIf
			fGerRes(cSRDAlias, aResCompl[nContRes, 3], (SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)), @lRJ5Ok, @aErrosRJ5)
		EndIf

		SRV->(DbSetOrder(0))
		While (cSRDAlias)->(!Eof())
			//Para competencia anterior a Dezembro, despreza todas as verbas do roteiro 132 que n�o seja a do l�quido (Id 0021)
			If !lGeraRes .And. ( SubStr(cCompete, 1, 2) != "12" .And. ( (cSRDAlias)->RD_ROTEIR == "132" .Or. fGetTipoRot( (cSRDAlias)->RD_ROTEIR ) == "6" ) ) .And. (cSRDAlias)->RD_PD != cPdCod0021
				(cSRDAlias)->( dbSkip() )
				Loop
			EndIf

			cCodigoVb := (cSRDAlias)->RD_PD
			nHorasVb  := (cSRDAlias)->RD_HORAS
			nValorVb  := (cSRDAlias)->RD_VALOR
			cNrBen	  := If(lGera1207, (cSRDAlias)->RD_NRBEN, "")

			//Com o indice "RV_FILIAL+RV_CODCOM_", efetua pesquisa com o c�digo do RD_PD no cadastro de verbas
			//para verificar se essa verba foi configurada onde a diferen�a do diss�dio ser� gerada de outra verba.
			//Ex: processamento da verba 900, cujo cadastro da verba 001 na SRV possui o campo RV_CODCOM_ com 900.
			//	  Isso significa que a diferen�a de diss�dio da verba 001 ser� gerada na verba 900.
			//	  A verba 001 ser� gerada normalmente, mas a verba 900 N�O por se tratar de uma verba de diss�dio e n�o ser�
			//    gerada no <remunPerApur> pois ser� gerado no <remunPerAnt>, onde os valores de diss�dio s�o exibidos.
			If lVerRHH .And. cTpFolha == "1" .And. SRV->( dbSeek( xFilial("SRV", (cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_PD ) )
				lTemDiss 	:= .T.
				lGeraVbDis	:= .F.
				If !lGeraRes
					If (cSRDAlias)->TAB == "SRC"
						SRC->( dbGoTo( (cSRDAlias)->RECNO ) )
						cDissNumId	:= SRC->RC_NUMID
					Else
						SRD->( dbGoTo( (cSRDAlias)->RECNO ) )
						cDissNumId	:= SRD->RD_NUMID
					EndIf
					aAdd( aVbDiss, { (cSRDAlias)->RD_PD, If( !Empty(cDissNumId), cDissNumId, "") } )
				EndIf

				//Quando for rescis�o complementar por diss�dio, considera verba de diferen�a de diss�dio se o numid estiver em branco
				//que significa que a verba � referente a diferen�a de diss�dio do c�lculo da rescis�o; verba com numid preenchido
				//s�o verbas originadas do c�lculo do diss�dio referente per�odos anteriores e ser�o desprezadas nesse trecho
				If lGeraRes .And. aResCompl[nContRes, 1] == "2"
					nHorasVb	:= 0
					nValorVb	:= 0
					SRR->( dbSetOrder(5) )//RR_FILIAL+RR_MAT+DTOS(RR_DATAPAG)+RR_PD
					If SRR->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATPGT + (cSRDAlias)->RD_PD ) )
						While SRR->( !EoF() .And. SRR->RR_FILIAL + SRR->RR_MAT + dToS(SRR->RR_DATAPAG) + SRR->RR_PD == (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATPGT + (cSRDAlias)->RD_PD )
							If SRR->RR_TIPO3 == "R" .And. Empty(SRR->RR_NUMID)
								//Caso o N�mero de Id esteja em branco e a verba tenha origem G pesquisa na tabela SRK para validar se trata-se de diss�dio.
								If SRR->RR_TIPO2 == "G"
									cNumId := fNumId(SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_PD)
									If !Empty(cNumId)
										aAdd( aVbDiss, { SRR->RR_PD, cNumId } )
									Else
										nHorasVb	+= SRR->RR_HORAS
										nValorVb	+= SRR->RR_VALOR
										lGeraVbDis	:= .T.
									EndIf
								Else
									nHorasVb	+= SRR->RR_HORAS
									nValorVb	+= SRR->RR_VALOR
									lGeraVbDis	:= .T.
								EndIf
							EndIf
							If !Empty(SRR->RR_NUMID)
								aAdd( aVbDiss, { SRR->RR_PD, SRR->RR_NUMID } )
							EndIf
							SRR->( dbSkip() )
						EndDo
					EndIf
				EndIf

				If !lGeraVbDis
					If lRelat
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0076) + (cSRDAlias)->RD_PD + OemToAnsi(STR0077) + SRV->RV_COD + OemToAnsi(STR0078) } )//"Verba "##" desprezada do grupo infoPerApur (Remunera��o no per�odo de apura��o) pois est� cadastrada no campo Verba P.Diss (RV_CODCOM) da verba "##". Dessa forma, a diferen�a de diss�dio ser� gerada no grupo infoPerAnt (Remunera��o em Per�odos Anteriores)"
					EndIf
					(cSRDAlias)->( dbSkip() )
					Loop
				EndIf
			EndIf

			If cCCAnt <> (cSRDAlias)->RD_CC
				cTpInscr	:= ""
				cInscr		:= ""
				cCCAnt 		:= (cSRDAlias)->RD_CC
				aNomes		:= {}

				fEstabELot((cSRDAlias)->RD_FILIAL, (cSRDAlias)->RD_CC, @cTpInscr, @cInscr, @cBusca, Iif(lVerRJ5, (cSRDAlias)->RD_CCBKP, ""), cCompete, @cChaveS1005)

				//apesar de manual indicar Loop, para Protheus sempre 1 unico registro!!!
				If lGeraRes .Or. lPagPost
					If Len(aResCompl) > 0 .And. aResCompl[nContRes, 1] == "2"
						If aScan(aEstLotAnt, { |x| x[1]+x[2]+x[3]+x[5]+x[6] == cTpInscr+cInscr+cBusca+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef }) == 0
							aAdd( aEstLotAnt, { cTpInscr, cInscr, cBusca, Nil, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef, cChaveS1005 } )//<ideEstabLot>
						EndIf
					Else
						If aScan(aEstLotAnt, { |x| x[1]+x[2]+x[3]+x[5]+x[6] == cTpInscr+cInscr+cBusca+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef }) == 0
							aAdd( aEstLotAnt, { cTpInscr, cInscr, cBusca, Nil, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef, cChaveS1005 } )//<ideEstabLot>
						EndIf
					EndIf
				Else
					If aScan(aEstLotApur, { |x| x[1]+x[2]+x[3]+x[5]+x[6] == cTpInscr+cInscr+cBusca+SRA->RA_CIC+cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD) }) == 0
						aAdd( aEstLotApur, { cTpInscr, cInscr, cBusca, Nil, SRA->RA_CIC, cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD), cChaveS1005 } )//<ideEstabLot>
					EndIf
				EndIf

				dbselectarea('CTT')
				DbsetOrder(1)
				CTT->(DBSeek( xFilial("CTT",(cSRDAlias)->(RD_FILIAL)) + (cSRDAlias)->RD_CC )  )

				cVerIndSimples := ''
				If cOptSimp == "1"
					cVerIndSimples := aTabInss[31, 1]
				EndIf

				// [ PODEM SER N REGISTROS ]
				If lGeraRes .Or. lPagPost
					If Len(aResCompl) > 0 .And. aResCompl[nContRes, 1] == "2"
						If aScan(aRemPerAnt, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca }) == 0
							aAdd( aRemPerAnt, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca } )//<remunPerAnt>
						EndIf
					Else
						If aScan(aRemPerAnt, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca }) == 0
							aAdd( aRemPerAnt, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca } )//<remunPerAnt>
						EndIf
					EndIf
				Else
					If aScan(aRemPerApur, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD)+cTpInscr+cInscr+cBusca }) == 0
						aAdd( aRemPerApur, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD)+cTpInscr+cInscr+cBusca  } )//<remunPerApur>
					EndIf
				EndIf
				lAbriuTagLote := .T.
				lCarrDep := .F.
				If (SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/") .Or. lInfoAg) .And. !lGera1202 .And. !lGera1207
					cOcorren := fGrauExp()
					If lGeraRes .Or. lPagPost
						If Len(aResCompl) > 0 .And. aResCompl[nContRes, 1] == "2"
							If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
								aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
							EndIf
						Else
							If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
								aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
							EndIf
						EndIf
					Else
						If aScan( aInfAgNoc, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
							aAdd( aInfAgNoc, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
						EndIf
					EndIf
				EndIf
			endif

			//Para competencia anterior a Dezembro com a op��o de gera��o de Ref. 13� com "Sim", troca a verba do l�quido do roteiro 132 pela verba da 1� parcela (Id 0022)
			If !lGeraRes .And. ( SubStr(cCompete, 1, 2) != "12" .And. ( (cSRDAlias)->RD_ROTEIR == "132" .Or. fGetTipoRot( (cSRDAlias)->RD_ROTEIR ) == "6" ) )
				cCodigoVb := cPdCod0022
			EndIf
			// Posiciona na verba em trabalho
			cCodFol 	:= ""
			cCodFil 	:= ""
			cCodNat 	:= ""
			cCodINCCP 	:= ""
			cCodINCIRF 	:= ""
			cCodINCFGT 	:= ""
			cIncINS		:= ""
			cIncIRF		:= ""
			cIncFGT		:= ""
			cCodPerc 	:= 0
			cTpCod 		:= ""
			cInCop		:= ""
			cTetoP		:= ""
			cIdsPerIns	:= "0036/1281/1282/1290/1685/1684/1632/1440/1643/1291/1633/1441/1644/1316/1318/1317/1683/1680/1300/1319/0673/0672/1697/1696/1292/1634/1442/1645/1293/1646/1320/1322/1321/1323/1695/1692/1304/1306/1305/1307/1693/1694/1423/1339/0039"

			cCodFol 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_CODFOL' )
			cCodFil 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_FILIAL' )
			cCodNat 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_NATUREZ' )
			cCodINCCP 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_INCCP' )
			cCodINCIRF 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_INCIRF' )
			cCodINCFGT 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_INCFGTS' )
			cIncINS 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_INSS' )
			cIncIRF 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_IR' )
			cIncFGT 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_FGTS' )
			cCodPerc 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_PERC' )
			cTpCod 		:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_TIPOCOD' )
			If cVersaoEnv >= "9.0"
				If lRVIncop
					cInCop 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_INCOP' )
				Endif
				If lRVTetop
					cTetoP 	:= RetValSrv( cCodigoVb, (cSRDAlias)->(RD_FILIAL), 'RV_TETOP' )
				Endif
			Endif
			//Se for rescis�o de um bolsista despreza as verbas que tem incid�ncia diferente de 00 e 01 para INSS ou 00 para FGTS
			//Este condi��o j� existe na gera��o do evento S-2399
			If cVersaoEnv >= '9,0,00' .And. (SRA->RA_CATEFD $ cBolsistas) .And. (!(cCodINCCP  $ '00|01') .Or. cCodINCFGT  <> '00') .And. ;
			(ANOMES(SRA->RA_DEMISSA) == SubStr(cCompete,3,4) + SubStr(cCompete,1,2)) .And. (cSRDAlias)->RD_ROTEIR == "FOL"
				(cSRDAlias)->( dbSkip() )
			 	Loop
			Endif

			//Tratamento espec�fico para Semanalistas
			If SRA->RA_TIPOPGT == "S"
				//Tratamento espec�fico para as verbas de Base/Desconto IR M�s Anterior para considerar o valor gerado na primeira semana,
				//pois a verba era gerada em todas as semanas de pagamento, mesmo se n�o houvesse pagamento
				If cCodFol $ "0106/0107"
					SRD->( dbSetOrder(2) )//RD_FILIAL+RD_CC+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ
					If SRD->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATARQ + (cSRDAlias)->RD_PD + "01" ) )
						nHorasVb  := SRD->RD_HORAS
						nValorVb  := SRD->RD_VALOR
					Else
						SRC->( dbSetOrder(1) )//RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ
						If SRC->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_PD + (cSRDAlias)->RD_CC + "01" ) )
							nHorasVb  := SRC->RC_HORAS
							nValorVb  := SRC->RC_VALOR
						EndIf
					EndIf
				//Tratamento espec�fico para verba de Base IR M�s para considerar o valor gerado na �ltima semana,
				//pois a verba � gerada com valor acumulado a cada semana
				ElseIf cCodFol == "0015"
					SRD->( dbSetOrder(2) )//RD_FILIAL+RD_CC+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ
					If SRD->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATARQ + (cSRDAlias)->RD_PD + (cSRDAlias)->RD_SEMANA ) )
						While SRD->( !EoF() .And. SRD->RD_FILIAL + SRD->RD_CC + SRD->RD_MAT + SRD->RD_DATARQ + SRD->RD_PD + SRD->RD_SEMANA == (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATARQ + (cSRDAlias)->RD_PD + (cSRDAlias)->RD_SEMANA)
							nHorasVb  := SRD->RD_HORAS
							nValorVb  := SRD->RD_VALOR
							SRD->( dbSkip() )
						EndDo
					EndIf
					SRC->( dbSetOrder(1) )//RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ
					If SRC->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_PD + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_SEMANA ) )
						While SRC->( !EoF() .And. SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD + SRC->RC_CC == (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_PD + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_SEMANA .And. SRC->RC_PERIODO == (SubStr(cCompete,3,4) + SubStr(cCompete,1,2)) )
							nHorasVb  := SRC->RC_HORAS
							nValorVb  := SRC->RC_VALOR
							SRC->( dbSkip() )
						EndDo
					EndIf
				EndIf
			EndIf

			If SRA->RA_OCORREN $ '  |01|05' .And. cCodFol $ cIdsPerIns .And. SRA->RA_MAT <> cMatAnt
				aAdd(aLogPeric, OemToAnsi(STR0208) + SRA->RA_MAT + '-' + Alltrim(SRA->RA_NOME))//"Funcion�rio : "##"
				aAdd(aLogPeric, OemToAnsi(STR0209))	//" possui valores referentes a periculosidade ou insalubridade, mas n�o esta exposto a agentes nocivos."
				aAdd(aLogPeric, OemToAnsi(STR0210))	//"Consulte o preenchimento do campo Ocorr�ncia (RA_OCORREN)."
				cMatAnt := SRA->RA_MAT
			EndIf

			If !Empty(xFilial("SRV",(cSRDAlias)->(RD_FILIAL)))
				lGeraCod := .T.
			EndIf
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
					If Empty(cIdeRubr)
						aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Aten��o"##"N�o ser� poss�vel efetuar a integra��o. O identificador de tabela de rubrica do c�digo: "##" n�o est� cadastrado."
						Return .F.
					EndIf
				EndIf
				cIdTbRub := cIdeRubr
			EndIf

			//------------------------
			//| Entra no fluxo caso:
			//| Seja vers�o 2.2, Trabalhador com Vinculo ou
			//| Trabalhador sem Vinculo seja Bolsitas ou Contribuinte Individual com Inc CP iguais aos valores
			//-------------------------------------------------------------------------------------------------
			If ( cVersaoEnv == '2.2' ) .OR.;
				( cVersaoEnv == '2.3' .AND. !((SRA->RA_CATEFD $ (cBolsistas + cContrib)) .AND. (cCodNat $ '1409|4050|4051|1009'))) .OR.;
				( cVersaoEnv >= '2.4' .AND. !((SRA->RA_CATEFD $ (cBolsistas + cContrib)) .AND. (cCodINCCP  $ '25|26|51')))

				if If(cVersaoEnv >= "9.0.00" ,.T., cCodNat <> "9213") .and. (VAL(cCodINCCP ) <> 23 .AND. VAL(cCodINCCP ) <> 24 .AND. VAL(cCodINCCP ) <> 61) .AND.;
				(( cVersaoEnv < "2.6.00" .And. !(SubStr(cCodINCIRF, 1, 2) $ '31|32|33|34|35|51|52|53|54|55|81|82|83') ) .OR. ;
				( cVersaoEnv >= "2.6.00" .And. cVersaoEnv < "9.0.00" .And. !(fRetTpIRF( cCodINCIRF ) $ "D|I|J") ) .OR. ;
				(cVersaoEnv >= "9.0.00" .And. !(cCodNat $ '1801*9220' .And. ((cTpFolha == "1" .And. SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= "202107") .OR. (cTpFolha == "2" .And. SubStr(cCompete, 3, 4) >= "2021"))))) .AND.;
				cCodFol != "0126"
					SRR->( dbSetOrder(5) )//RR_FILIAL+RR_MAT+DTOS(RR_DATAPAG)+RR_PD
					If cCodINCIRF != "46" .Or. cCodINCIRF == "46" .And. !SRR->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + (cSRDAlias)->RD_DATPGT + cCodigoVb ) )
						//[ PODEM SER N REGISTROS ]  itensRemun
						nPercRub := (cCodPerc - 100)
						If lDtPgto .And. cCodFol == "0044"
							cBkpDmDev 	:= cDmDev
							cDtPgto 	:= fVerDtPgto( (cSRDAlias)->RD_DATPGT, (cSRDAlias)->TAB, (cSRDAlias)->RECNO )
							If lAglut .And. (SRA->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1)//MultV
								cDmDev := (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + SubStr( cDtPgto, 3 ) + SubStr( (cSRDAlias)->RD_PERIODO, 3 ) + (cSRDAlias)->RD_ROTEIR
								If Len(cDmDev) > 30
									cDmDev := (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT + SubStr( cDtPgto, 7 ) + fGetTipoRot( (cSRDRot)->RD_ROTEIR )
								EndIf
							Else
								cDmDev := (cSRDAlias)->RD_FILIAL + cDtPgto + (cSRDAlias)->RD_PERIODO + (cSRDAlias)->RD_ROTEIR
							EndIf
						EndIf
						If lGeraRes .Or. lPagPost
							If Len(aResCompl) > 0 .And. aResCompl[nContRes, 1] == "2"
								If (nPosItRem := aScan(aItRemAnt, { |x| x[1]+x[2]+x[7]+x[8] == cCodigoVb+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula })) == 0
									aAdd( aItRemAnt, { cCodigoVb, cIdTbRub, Str(nHorasVb), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil ,Str(nValorVb), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+cCodigoVb),cInCop, cTetoP  } )//<itensRemun>
								Else
									aItRemAnt[nPosItRem, 3] := Str( Val(aItRemAnt[nPosItRem, 3]) + nHorasVb )
									aItRemAnt[nPosItRem, 6] := Str( Val(aItRemAnt[nPosItRem, 6]) + nValorVb )
								EndIf
							Else
								If (nPosItRem := aScan(aItRemAnt, { |x| x[1]+x[2]+x[7]+x[8] == cCodigoVb+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula })) == 0
									aAdd( aItRemAnt, { cCodigoVb, cIdTbRub, Str(nHorasVb), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil ,Str(nValorVb), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+cCodigoVb),cInCop, cTetoP  } )//<itensRemun>
								Else
									aItRemAnt[nPosItRem, 3] := Str( Val(aItRemAnt[nPosItRem, 3]) + nHorasVb )
									aItRemAnt[nPosItRem, 6] := Str( Val(aItRemAnt[nPosItRem, 6]) + nValorVb )
								EndIf
							EndIf
						Else
							If lMiddleware .And. cCodFol == "0072"
								nHorasVb := Ceiling(nHorasVb)   //Arredonda a quantidade de dias para cima
							Endif
							If (nPosItRem := aScan(aItRemApur, { |x| x[1]+x[2]+x[7]+x[8] == cCodigoVb+cIdTbRub+SRA->RA_CIC+cDmDev+If(lGera1207,cNrBen,SRA->RA_CATEFD)+cTpInscr+cInscr+cBusca+cMatricula })) == 0
								aAdd( aItRemApur, { cCodigoVb, cIdTbRub, Str(nHorasVb), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil ,Str(nValorVb), SRA->RA_CIC, cDmDev+ If(lGera1207,cNrBen,SRA->RA_CATEFD) +cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+cCodigoVb) ,cInCop, cTetoP, cCodFol } )//<itensRemun>
							Else
								aItRemApur[nPosItRem, 3] := Str( Val(aItRemApur[nPosItRem, 3]) + nHorasVb )
								aItRemApur[nPosItRem, 6] := Str( Val(aItRemApur[nPosItRem, 6]) + nValorVb )
							EndIf
						EndIf
						If lDtPgto .And. cCodFol == "0044"
							cDmDev := cBkpDmDev
						EndIf
					EndIf
				ElseIf lRelat .And. ( If(cVersaoEnv >= "9.0.00" ,.F., cCodNat <> "9213") .Or. Val(cCodINCCP ) == 23 .Or. Val(cCodINCCP ) == 24 .Or. Val(cCodINCCP ) == 61 )
					aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, STR0076 + cCodigoVb + OemToAnsi(STR0080) } )//"Verba "##" desprezada devido incid�ncia CP ser 23, 24 ou 61 ou devido natureza ser 9213"
				ElseIf lRelat .And. SubStr(cCodINCIRF, 1, 2) $ '31|32|33|34|35|51|52|53|54|55|81|82|83'
					aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, STR0076 + cCodigoVb + OemToAnsi(STR0081) } )//"Verba "##" desprezada do evento S-1200 devido incid�ncia eSocial para IRRF (campo cd. Inc.IRRF) ser 31, 32, 33, 34, 35, 51, 52, 53, 54, 55, 81, 82 ou 83. Dessa forma, a rubrica somente ser� gerada no evento S-1210"
				ElseIf lRelat .And. cVersaoEnv >= "9.0.00" .And. cCodNat $ '1801*9220' .And. ((cTpFolha == "1" .And. SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= "202107") .OR. (cTpFolha == "2" .And. SubStr(cCompete, 3, 4) >= "2021"))
					aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, STR0076 + cCodigoVb + OemToAnsi(STR0212) } )//"Verba "##" desprezada devido natureza ser 1801 ou 9220.
				EndIf
			ElseIf lRelat .And. cVersaoEnv >= '2.4' .AND. ((SRA->RA_CATEFD $ (cBolsistas + cContrib)) .AND. (cCodINCCP  $ '25|26|51'))
				aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, STR0076 + cCodigoVb + OemToAnsi(STR0082) } )//"Verba "##" desprezada devido c�digo de incid�ncia CP ser 25, 26 ou 51"
			EndIf

			//Para competencia de Dezembro com a op��o de gera��o de Ref. 13� com "Sim" e funcion�rio com pagamento integral da 2� parcela anterior a Dezembro, duplica a gera��o da rubrica do liquido do roteiro 132 (Id 0021) para a rubrica do Id 1655
			If ( SubStr(cCompete, 1, 2) == "12" .And. cTpFolha == "2" .And. !lTem132 .And. ( (cSRDAlias)->RD_ROTEIR == "132" .Or. fGetTipoRot( (cSRDAlias)->RD_ROTEIR ) == "6" ) ) .And. (cSRDAlias)->RD_PD == cPdCod0021
				If !Empty(cPdCod1655)
					nPercRub := (cCodPerc - 100)
					If lGeraRes .Or. lPagPost
						If (nPosItRem := aScan(aItRemAnt, { |x| x[1]+x[2]+x[7]+x[8] == cPdCod1655+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula })) == 0
							aAdd( aItRemAnt, { cPdCod1655, cIdTbRub, Str(nHorasVb), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil ,Str(nValorVb), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+cPdCod1655),cInCop, cTetoP } )//<itensRemun>
						Else
							aItRemAnt[nPosItRem, 3] := Str( Val(aItRemAnt[nPosItRem, 3]) + nHorasVb )
							aItRemAnt[nPosItRem, 6] := Str( Val(aItRemAnt[nPosItRem, 6]) + nValorVb )
						EndIf
					Else
						If (nPosItRem := aScan(aItRemApur, { |x| x[1]+x[2]+x[7]+x[8] == cPdCod1655+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula })) == 0
							aAdd( aItRemApur, { cPdCod1655, cIdTbRub, Str(nHorasVb), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil ,Str(nValorVb), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+cPdCod1655) ,cInCop, cTetoP, cCodFol} )//<itensRemun>
						Else
							aItRemApur[nPosItRem, 3] := Str( Val(aItRemApur[nPosItRem, 3]) + nHorasVb )
							aItRemApur[nPosItRem, 6] := Str( Val(aItRemApur[nPosItRem, 6]) + nValorVb )
						EndIf
					EndIf
				Else
					aAdd( aLogDiss, OemToAnsi(STR0046) + OemToAnsi(STR0052) )//"[FALHA] "##"Necess�rio possuir verba para o Id de c�lculo 1655 - 13� integral pago antes de Dezembro"
					aAdd( aLogDiss, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=435110991" )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
					If lRelat
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0052) + OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=435110991" } )//"Necess�rio possuir verba para o Id de c�lculo 1655 - 13� integral pago antes de Dezembro"##"Para mais informa��es, consulte a documenta��o dispon�vel em: "
					EndIf
				EndIf
			EndIf

			If (cVersaoEnv >= "2.6.00" .Or. cCodNat == "9219" .Or. lRelat) .And. !lCarrDep .And. cVersaoEnv < "9.0.00"

				//-----------------
				//| Plano de Saude
				//| Se a verba corrente tiver natureza de rubrica '9219' de plano de saude ou a vers�o do eSocial for maior ou igual que a 2.6
				//| Entra na tabela RHR - Plano de Saude, localiza o registro do funcion�rio
				//| Verifica se o registro foi integrado com a folha, se sim: alimenta array
				//---------------------------------------------------------------------------
				adadosRHS := fGetAssMed( (cSRDAlias)->RD_FILIAL, (cSRDAlias)->RD_MAT ,cVersaoEnv,(cSRDAlias)->RD_PERIODO, cOpcTab, @lCPFDepOk, @aNomes)
				If !lCPFDepOk
					aAdd(aDepAgreg, OemToAnsi(STR0067) + OemToAnsi(STR0021) + (cSRAAlias)->RA_CIC  + " - " + Alltrim((cSRAAlias)->RA_NOME) )//"[Aten��o] Registro S-1200 do Funcion�rio: "##"

					aAdd(aDepAgreg, OemToAnsi(STR0055))//"O(s) dependente(s)/agregado(s) de plano de sa�de abaixo n�o tem CPF cadastrado:"
					If lRelat
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0055) } )//"O(s) dependente(s)/agregado(s) de plano de sa�de abaixo n�o tem CPF cadastrado:"
					EndIf
					For nC := 1 To Len(aNomes)
						aAdd(aDepAgreg, aNomes[nC])
						If lRelat
							aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, aNomes[nC] } )
						EndIf
					Next nC
					aAdd(aDepAgreg, OemToAnsi(STR0056))//"Verifique as tabelas SRB - Dependentes e RHM - Agregados"
					If lRelat
						aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0056) } )//"Verifique as tabelas SRB - Dependentes e RHM - Agregados"
					EndIf
				EndIf
				lCarrDep := .T.
			EndIf

			//------------------------------
			//| Verba de Multiplos Vinculos
			//| Se a verba corrente, tiver seu ID de Calculo igual a 0288 ou 0289
			//| realizar� a procura dos multiplos v�nculos do funcion�rio
			//------------------------------------------------------------

			//acha a partir de um unico registro da SRD mesmo
			//teoricamente a ARZ estar� em uma unica combinacao cic\matricula\filial ...assim que houver em uma pegams os daods pois nao havera em outra cic\matricula\filial
			If AllTrim( cCodFol ) $ "0288|0289|0290|0291"  .And. Len(aDadosRAZ) == 0
				DBSelectArea("RAZ")
				RAZ->(DbSetOrder(1))
				If  ( RAZ->( dbSeek( (cSRDAlias)->RD_FILIAL + (cSRDAlias)->RD_MAT ) ) )
					aDadosRAZ := GetMulVin((cSRDAlias)->RD_FILIAL , (cSRDAlias)->RD_MAT, SubStr(cCompete,3,4) + SubStr(cCompete,1,2), If( AllTrim( cCodFol ) $ "0288|0289", "1", "2" ), SRA->RA_CIC)

					If Len(aDadosRAZ) > 0  .And. lUnicaTag
						lUnicaTag := .F.

						//Se novo c�lculo (P_MULTV = .T.) busca a informa��o da tag <IndMV> considerando Filial + Matr�cula
						If lNewMV
							nPosRaz := aScan(aDadosRAZ, {|x| x[1] + x[2] == SRA->RA_FILIAL + SRA->RA_MAT})
							If nPosRaz > 0
								aAdd( aInfMV, { aDadosRAZ[nPosRaz,5], SRA->RA_CIC } )//<infoMV>
							Else
								aAdd( aInfMV, { aDadosRAZ[1,5], SRA->RA_CIC } )//<infoMV>
							EndIf
						Else
							aAdd( aInfMV, { aDadosRAZ[1,5], SRA->RA_CIC } )//<infoMV>
						EndIf

						//Se for o novo c�lculo (P_MULTV = .T.) retira do array aDadosRaz o registro de mesmo n�mero de CNPJ da filial em processamento
						If lNewMV
							nPosEstb	:= aScan(aEstb, {|x| x[5] + x[1] == cEmpAnt + ALLTRIM(SRA->RA_FILIAL)})
							If nPosEstb > 0
								cNrInsc		:= aEstb[nPosEstb,2]
								nPosRaz		:= aScan(aDadosRAZ, {|x| x[10] == cNrInsc})
								If nPosRaz > 0
									nTam := Len(aDadosRAZ)
									ADEL( aDadosRAZ, nPosRaz )
									ASIZE( aDadosRAZ, nTam - 1 )
								EndIf
							EndIf
						EndIf

						For nC := 1 to Len(aDadosRAZ)
							IF aScan(aRegRaz, {|x| x ==  aDadosRAZ[nC,10] + aDadosRAZ[nC,12]}) == 0
								aAdd(aRegRaz, aDadosRAZ[nC,10] + aDadosRAZ[nC,12])
							ELSE
								lRAZOk := .F.
							ENDIF
							//loop de ate 10 registros
							aAdd( aRemOutEmp, { aDadosRAZ[nC,9], aDadosRAZ[nC,10], IIF(!EMPTY(aDadosRAZ[nC,12]), aDadosRAZ[nC,12], SRA->RA_CATEFD), AllTrim( Transform(aDadosRAZ[nC,11], "@E 999999999.99") ), SRA->RA_CIC } )//<remunOutrEmpr>
						Next

					EndIf

				EndIf
			EndIf

			(cSRDAlias)->(DbSkip())

			If (cSRDAlias)->(!Eof())  .And. cCCAnt <> (cSRDAlias)->RD_CC
				If Len(aDadosRHS) > 0 .And. !lGeraRes
					//[ PODEM SER N REGISTROS ]
					If aScan( aInfSauCole, { |x| x[1]+x[2] == cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
						aAdd( aInfSauCole, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoSaudeColet>
					EndIf

					For nW := 1 To Len(aDadosRHS)		//regra do GPEM026C

						//[ PODEM SER N REGISTROS ]
						If (nPosDetOper := aScan( aDetOper, { |x| x[1]+x[2]+x[4]+x[5] == aDadosRHS[nW,6]+aDadosRHS[nW,7]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )) == 0
							aAdd( aDetOper, { aDadosRHS[nW,6], aDadosRHS[nW,7], Iif(!lMiddleware, AllTrim( Transform(aDadosRHS[nW,8],"@E 999999999.99") ), Str(aDadosRHS[nW,8])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula, aDadosRHS[nW,3] } )//<detOper>
						Else
							If !lMiddleware
								aDetOper[nPosDetOper, 3] := AllTrim( Transform(Val(aDetOper[nPosDetOper, 3]) + aDadosRHS[nW,8],"@E 999999999.99") )
							Else
								aDetOper[nPosDetOper, 3] := Str( Val(aDetOper[nPosDetOper, 3]) + aDadosRHS[nW,8] )
							EndIf
						EndIf

						If Len(aDadosRHS[nW,9]) > 0

							aLstDeps := aDadosRHS[nW,9]

							For nc := 1 to Len(aLstDeps)
								If cVersaoEnv >= '2.4'
									If (nPosDetPla := aScan( aDetPlano, { |x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == aLstDeps[nc][5]+aLstDeps[nc][1]+aLstDeps[nc][2]+aLstDeps[nc][3]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6] } )) == 0
										aAdd( aDetPlano, { aLstDeps[nc][5], aLstDeps[nc][1], aLstDeps[nc][2], aLstDeps[nc][3], Iif(!lMiddleware, AllTrim( Transform(aLstDeps[nc][4],"@E 999999999.99") ), Str(aLstDeps[nc][4])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6], aLstDeps[nc][6] } )//<detPlano>
									Else
										If !lMiddleware
											aDetPlano[nPosDetPla, 5] := AllTrim( Transform(Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4],"@E 999999999.99") )
										Else
											aDetPlano[nPosDetPla, 5] := Str( Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4] )
										EndIf
									EndIf
								Else
									If (nPosDetPla := aScan( aDetPlano, { |x| x[2]+x[3]+x[4]+x[6]+x[7] == aLstDeps[nc][1]+aLstDeps[nc][2]+aLstDeps[nc][3]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6] } )) == 0
										aAdd( aDetPlano, { Nil, aLstDeps[nc][1], aLstDeps[nc][2], aLstDeps[nc][3], Iif(!lMiddleware, AllTrim( Transform(aLstDeps[nc][4],"@E 999999999.99") ), Str(aLstDeps[nc][4])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6], aLstDeps[nc][6] } )//<detPlano>
									Else
										If !lMiddleware
											aDetPlano[nPosDetPla, 5] := AllTrim( Transform(Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4],"@E 999999999.99") )
										Else
											aDetPlano[nPosDetPla, 5] := Str( Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4] )
										EndIf
									EndIf
								EndIf
							Next
						EndIf

					Next

					adadosRHS := {}
				EndIf

				If SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/") .Or. lInfoAg
					cOcorren := fGrauExp()
					If lGeraRes .Or. lPagPost
						If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
							aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
						EndIf
					Else
						If aScan( aInfAgNoc, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
							aAdd( aInfAgNoc, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
						EndIf
					EndIf
				EndIf

				If SRA->RA_CATEFD == '111' .And. cVersaoEnv < "9.0.00"
					aConvocs := fBuscaConv(SRA->RA_FILIAL,SRA->RA_MAT, cCompete, cCCAnt, cOpcTab)
					If !Empty(aConvocs)
						If aScan( aInfTrabInt, { |x| x[2]+x[3] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
							aAdd( aInfTrabInt, { aConvocs, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoTrabInterm>
						EndIf
					EndIf
				Endif

				lAbriuTagLote := .F.
			Endif

		EndDo

		If lAbriuTagLote
			If Len(aDadosRHS) > 0
				//[ PODEM SER N REGISTROS ]
				If aScan( aInfSauCole, { |x| x[1]+x[2] == cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
					aAdd( aInfSauCole, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoSaudeColet>
				EndIf

				For nW := 1 To Len(aDadosRHS)		//regra do GPEM026C

					//[ PODEM SER N REGISTROS ]
					If (nPosDetOper := aScan( aDetOper, { |x| x[1]+x[2]+x[4]+x[5] == aDadosRHS[nW,6]+aDadosRHS[nW,7]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )) == 0
						aAdd( aDetOper, { aDadosRHS[nW,6],aDadosRHS[nW,7], Iif(!lMiddleware, AllTrim( Transform(aDadosRHS[nW,8],"@E 999999999.99") ), Str(aDadosRHS[nW,8])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula, aDadosRHS[nW,3] } )//<detOper>
					Else
						If !lMiddleware
							aDetOper[nPosDetOper, 3] := AllTrim( Transform(Val(aDetOper[nPosDetOper, 3]) + aDadosRHS[nW,8],"@E 999999999.99") )
						Else
							aDetOper[nPosDetOper, 3] := Str( Val(aDetOper[nPosDetOper, 3]) + aDadosRHS[nW,8] )
						EndIf
					EndIf

					If Len(aDadosRHS[nW,9]) > 0

						aLstDeps := aDadosRHS[nW,9]

						For nc := 1 to Len(aLstDeps)
							If cVersaoEnv >= '2.4'
								If (nPosDetPla := aScan( aDetPlano, { |x| x[1]+x[2]+x[3]+x[4]+x[6]+x[7] == aLstDeps[nc][5]+aLstDeps[nc][1]+aLstDeps[nc][2]+aLstDeps[nc][3]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6] } )) == 0
									aAdd( aDetPlano, { aLstDeps[nc][5],aLstDeps[nc][1],aLstDeps[nc][2],aLstDeps[nc][3], Iif(!lMiddleware, AllTrim( Transform(aLstDeps[nc][4],"@E 999999999.99") ), Str(aLstDeps[nc][4])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6], aLstDeps[nc][6] } )//<detPlano>
								Else
									If !lMiddleware
										aDetPlano[nPosDetPla, 5] := AllTrim( Transform(Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4],"@E 999999999.99") )
									Else
										aDetPlano[nPosDetPla, 5] := Str( Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4] )
									EndIf
								EndIf
							Else
								If (nPosDetPla := aScan( aDetPlano, { |x| x[2]+x[3]+x[4]+x[6]+x[7] == aLstDeps[nc][1]+aLstDeps[nc][2]+aLstDeps[nc][3]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6] } )) == 0
									aAdd( aDetPlano, { Nil, aLstDeps[nc][1], aLstDeps[nc][2], aLstDeps[nc][3], Iif(!lMiddleware, AllTrim( Transform(aLstDeps[nc][4],"@E 999999999.99") ), Str(aLstDeps[nc][4])), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula+aDadosRHS[nW,6], aLstDeps[nc][6] } )//<detPlano>
								Else
									If !lMiddleware
										aDetPlano[nPosDetPla, 5] := AllTrim( Transform(Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4],"@E 999999999.99") )
									Else
										aDetPlano[nPosDetPla, 5] := Str( Val(aDetPlano[nPosDetPla, 5]) + aLstDeps[nc][4] )
									EndIf
								EndIf
							EndIf
						Next
					EndIf

				Next

				adadosRHS := {}
			EndIf

			If SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/") .Or. lInfoAg
				cOcorren := fGrauExp()
				If lGeraRes .And. lAbriu21
					If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
						aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
					EndIf
				Else
					If aScan( aInfAgNoc, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
						aAdd( aInfAgNoc, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
					EndIf
				EndIf
			EndIf

			If SRA->RA_CATEFD == '111' .And. cVersaoEnv < "9.0.00"
				aConvocs := fBuscaConv(SRA->RA_FILIAL,SRA->RA_MAT, cCompete, cCCAnt, cOpcTab)
				If !Empty(aConvocs)
					If aScan( aInfTrabInt, { |x| x[2]+x[3] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } ) == 0
						aAdd( aInfTrabInt, { aConvocs, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpInscr+cInscr+cBusca+cMatricula } )//<infoTrabInterm>
					EndIf
				EndIf
			Endif

			lAbriuTagLote := .F.
		EndIf

		If lGeraRes .And. lAbriu21
			lFechou21 := .T.
		Endif

		//Realiza busca por convers�o de afastamento do tipo licensa sa�de para acidente de trabalho, quando existe, envia valores retroativos referente aos valores pagos a t�tulo de licensa sa�de (ID 1420) / OBS: Processado apenas no roteiro de folha
		If !lGeraRes .And. lR8DatAlt .And. cTpRotBkp == "1"
			aRetifAfas := fRetifAfas(SRA->RA_FILIAL, SRA->RA_MAT, cCompete)
			If !Empty(aRetifAfas)
				aAuxDoenca := fBusAuxDoe( SRA->RA_FILIAL, SRA->RA_MAT, aRetifAfas[1], aRetifAfas[2], cCompete )
				If !Empty(aAuxDoenca)
					cTpAco := "E"
					If aScan(aInfPerAnt, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
						aAdd( aInfPerAnt, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<infoPerAnt>
					EndIf
					If aScan(aIdeADCAnt, { |x| x[1]+x[2]+x[4]+x[5]+x[6]+x[7]+x[8] == aRetifAfas[3]+cTpAco+aRetifAfas[4]+aRetifAfas[5]+"N"+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
						aAdd( aIdeADCAnt, { aRetifAfas[3], cTpAco, Nil, If(cVersaoEnv < "9.0.00", aRetifAfas[4], Nil), aRetifAfas[5], "N", SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<ideADC>
					EndIf
					fEstabELot(SRA->RA_FILIAL, aAuxDoenca[1][3], @cTpInscr, @cInscr, @cBusca, Iif(lVerRJ5, aAuxDoenca[1][5], ""), cCompete, @cChaveS1005)
					For nC := 1 to Len(aAuxDoenca)
						cPerRef	:= SUBSTR(aAuxDoenca[nC][4],1,4) + "-" + SUBSTR(aAuxDoenca[nC][4],5,2)
						If aScan(aIdePer, { |x| x[1]+x[2]+x[3] == cPerRef+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco }) == 0
							aAdd( aIdePer, { cPerRef, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco } )//<idePeriodo>
						EndIf
						If aScan(aEstLotAnt, { |x| x[1]+x[2]+x[3]+x[5]+x[6] == cTpInscr+cInscr+cBusca+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef }) == 0
							aAdd( aEstLotAnt, { cTpInscr, cInscr, cBusca, Nil, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef, cChaveS1005 } )//<ideEstabLot>
						EndIf

						If cOptSimp == "1"
							If cPerDoeAnt != aAuxDoenca[nC][4] .And. fInssEmp( SRA->RA_FILIAL, @aTabInss2, Nil, aAuxDoenca[nC][4] )
								cPerDoeAnt 	   := aAuxDoenca[nC][4]
								cVerIndSimples := aTabInss2[31, 1]
							EndIf
						EndIf

						If aScan(aRemPerAnt, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef+cTpInscr+cInscr+cBusca }) == 0
							aAdd( aRemPerAnt, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef+cTpInscr+cInscr+cBusca } )//<remunPerAnt>
						EndIf
						If (nPosItRem := aScan(aItRemAnt, { |x| x[1]+x[2]+x[7]+x[8] == RetValSrv( '1432', SRA->RA_FILIAL, 'RV_COD', 2 )+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula })) == 0
							aAdd( aItRemAnt, { RetValSrv( '1432', SRA->RA_FILIAL, 'RV_COD', 2 ), cIdTbRub, aAuxDoenca[nC][2], Nil, Nil, Str( aAuxDoenca[nC][1] ), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+aRetifAfas[3]+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (xFilial("SRV", SRA->RA_FILIAL)+RetValSrv( '1432', SRA->RA_FILIAL, 'RV_COD', 2 )),cInCop, cTetoP } )//<itensRemun>
						Else
							aItRemAnt[nPosItRem, 3] := Str( Val(aItRemAnt[nPosItRem, 3] + aAuxDoenca[nC][2] ) )
							aItRemAnt[nPosItRem, 6] := Str( Val(aItRemAnt[nPosItRem, 6]) + aAuxDoenca[nC][1] )
						EndIf
					Next
				Endif
			Endif
		Endif

		//Informacoes complementares exclusiva para as categorias TSV desobrigadas do vinculo inicial
		If SRA->RA_CATEFD $ cCatTSV .And. ( Len(aCompTSV) > 0 .Or. (!lExiste2300 .And. lComplCont) )
			If aScan( aComplCont, { |x| x[4]+x[5] == SRA->RA_CIC+cdmDev+SRA->RA_CATEFD } ) == 0
				cnatAtiv := aCompTSV[2]
				If !Empty(aCompTSV[3])
					If (cTpInscr=="3"  .And. aCompTSV[3] $ "21|22" ) .Or. aCompTSV[3] $ "06|07|08"
						cnatAtiv := "2"
					Endif
				Endif
				aAdd( aComplCont, { aCompTSV[1], cnatAtiv,Nil, SRA->RA_CIC, cdmDev+SRA->RA_CATEFD } ) //<infoComplCont>
			EndIf
		Endif

		If !lGeraRes .Or. (lGeraRes .And. aResCompl[nContRes, 1] == "2")
			RHH->( dbSetOrder(1) )//RHH_FILIAL+RHH_MAT+RHH_MESANO+RHH_DATA+RHH_VB+RHH_CC+RHH_ITEM+RHH_CLVL+RHH_SEMANA+RHH_SEQ+RHH_ROTEIR
			If lVerRHH .And. ((!lGeraRes .And. cTpRotBkp == "1" .And. lTemDiss) .Or. (lGeraRes .And. lTemDiss))
				If Len(aVbDiss) > 0
					cBkpPerDis	:= ""
					aDissidio 	:= {}

					fTransfAll( @aTransfFun,,,.T.)
					nSeekSRK := len(aTransfFun)

					If nSeekSRK > 0
						cFilSRK	:= aTransfFun[nSeekSRK,10]
						cMatSRK := aTransfFun[nSeekSRK,11]
					Else
						cFilSRK	:= SRA->RA_FILIAL
						cMatSRK := SRA->RA_MAT
					EndIf

					For nC := 1 To Len(aVbDiss)

						If len(aDissidio) > 0 .And. Empty(aVbDiss[nC,2])
							nPosDis := aScan(aDissidio, { |x| x[1] == substr(cCompete,3,4)+substr(cCompete,1,2)})
						EndIf

						//Se o houver NUMID preenchido pesquisa na SRK, caso contr�rio considera a compet�ncia
						If !Empty(aVbDiss[nC,2])
							SRK->( dbSetOrder(1) )
							If SRK->( dbSeek( cFilSRK + cMatSRK ) )
								While SRK->( !EoF() .And. SRK->RK_FILIAL+SRK->RK_MAT == cFilSRK + cMatSRK )
									If ( (Empty(SRK->RK_NUMID) .And. SRK->RK_MESDISS == SubStr(aVbDiss[nC, 2], 5, 2 ) + SubStr(aVbDiss[nC, 2], 1, 4 )) .Or. (!Empty(SRK->RK_NUMID) .And. AllTrim(SRK->RK_NUMID) == AllTrim(aVbDiss[nC, 2])) )
										cPerDiss := SRK->RK_PERINI
										//Verifica se a compet�ncia j� foi inclu�da pois deve incluir apenas se n�o estiver no array
										If !Empty(cPerDiss) .And. (cPerDiss $ cBkpPerDis)
											SRK->( dbSkip() )
											Loop
										ElseIf !Empty(cPerDiss)
											aAdd(aDissidio,{SRK->RK_PERINI, SRK->RK_PARCELA})
											cBkpPerDis += cPerDiss + "*/"
											Exit
										EndIf
									EndIf
									SRK->( dbSkip() )
								EndDo
							EndIf
						ElseIf nPosDis == 0
							aAdd(aDissidio,{substr(cCompete,3,4)+substr(cCompete,1,2), nParDiss})
							cBkpPerDis += substr(cCompete,3,4)+substr(cCompete,1,2) + "*/"
						EndIf
					Next nC
				Else
					aAdd(aDissidio,{substr(cCompete,3,4)+substr(cCompete,1,2), nParDiss})
				EndIf

				If Len(aDissidio) > 0
					For nD := 1 to Len(aDissidio)
						cPerDiss 	:= aDissidio[nD, 1]
						nParDiss 	:= aDissidio[nD, 2]
						lFirstAnt	:= .T.
						lAbriu20	:= .F.
						nPosMat		:= 1
						lAchouRHH	:= .F.

						If !Empty(cPerDiss)
							lAchouRHH := fPesqRHH( SRA->RA_FILIAL, SRA->RA_MAT, @cPerDiss, @cPerIni, @cPerFim, @lMesAnt)
							/// Caso n�o encontre a RHH verifica se o houve transfer�ncia e os dados est�o na origem
							If !lAchouRHH
								cPerDiss 	:= aDissidio[nD, 1] //Ajusta o valor da vari�vel para nova pesquisa pois � alterada pela fPesqRHH
								If Len(aTransfFun) > 0
									For nContTrf := 1 To Len(aTransfFun)
										nPosMat := nContTrf
										//Caso a transf�ncia tenha ocorrido em per�do posterior ao diss�dio
										//significa que j� est� posicionado no registro correto para pesquisa dos dados
										If aTransfFun[nContTrf, 12] >= cPerDiss
											Exit
										EndIf
									Next nContTrf
									lAchouRHH := fPesqRHH( aTransfFun[nPosMat, 8], aTransfFun[nPosMat, 9], @cPerDiss, @cPerIni, @cPerFim, @lMesAnt)
								EndIf
							EndIf
						EndIf

						//Se enontrou o registro na RHH segue o processamento
						If lAchouRHH .And. Empty(aLogDiss)
							cDscAc 		:= fGetDscAc(,,,@dDatEfeito)
							cTpAco 		:= fGetTpAc()
							cCCAnt 		:= ""
							If !Empty(cDscAc) .And. !Empty(cTpAco)
								aAdd( aIdeAdc, { dToS(RHH->RHH_DTACOR), cTpAco, SubStr(cCompete,3,4) + "-" + SubStr(cCompete,1,2), dToS(dDatEfeito), cDscAc, "N" } )
								If Empty(aTransfFun) .Or. aScan(aTransfFun, { |x| x[12] >= cPerIni .And. x[12] <= SubStr(cCompete,3,4) + SubStr(cCompete,1,2) .And. (x[1] != x[4] .Or. x[8] != x[10]) .And. fVldRaiz(x[8], x[10]) }) == 0//Periodo, Empresa, Filial, Mesma raiz de CNPJ
									If __oSt09 == Nil
										__oSt09 := FWPreparedStatement():New()
										cQrySt := "SELECT RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA,RHH.RHH_VB,RHH.RHH_CC,SUM(RHH.RHH_VALOR) AS RHH_VALOR "
										cQrySt += "FROM " + RetSqlName('RHH') + " RHH "
										cQrySt += "WHERE RHH.RHH_FILIAL = ? AND "
										cQrySt += 		"RHH.RHH_MAT = ? AND "
										cQrySt += 		"RHH.RHH_MESANO = ? AND "
										cQrySt += 		"RHH.RHH_COMPL_ = 'S' AND "
										cQrySt += 		"RHH.D_E_L_E_T_ = ' ' "
										cQrySt += "GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC "
										cQrySt += "ORDER BY 1, 2, 3, 4, 6, 5"
										cQrySt := ChangeQuery(cQrySt)
										__oSt09:SetQuery(cQrySt)
									EndIf
									__oSt09:SetString(1, SRA->RA_FILIAL)
									__oSt09:SetString(2, SRA->RA_MAT)
									__oSt09:SetString(3, cPerDiss)
									cQrySt := __oSt09:getFixQuery()
								Else
									cQrySt := "SELECT RHH.RHH_FILIAL,RHH.RHH_MAT,RHH.RHH_MESANO,RHH.RHH_DATA,RHH.RHH_VB,RHH.RHH_CC,SUM(RHH.RHH_VALOR) AS RHH_VALOR "
									cQrySt += "FROM " + RetSqlName('RHH') + " RHH "
									cQrySt += "WHERE ("
									cQrySt += 			"(RHH.RHH_FILIAL = '" + SRA->RA_FILIAL + "' AND "
									cQrySt += 			"RHH.RHH_MAT = '" + SRA->RA_MAT + "') OR "
									For nContTrf := 1 To Len(aTransfFun)
										cQrySt += 		"(RHH.RHH_FILIAL = '" + aTransfFun[nContTrf, 8] + "' AND "
										cQrySt += 		"RHH.RHH_MAT = '" + aTransfFun[nContTrf, 9] + "')"
										If nContTrf < Len(aTransfFun)
											cQrySt += 	" OR "
										EndIf
									Next nContTrf
									cQrySt += 		") AND RHH.RHH_MESANO = '" + cPerDiss + "' AND "
									cQrySt += 		"RHH.RHH_COMPL_ = 'S' AND "
									cQrySt += 		"RHH.D_E_L_E_T_ = ' ' "
									cQrySt += "GROUP BY RHH_FILIAL, RHH_MAT, RHH_MESANO, RHH_DATA, RHH_VB, RHH_CC "
									cQrySt += "ORDER BY 1, 2, 3, 4, 6, 5"
									cQrySt := ChangeQuery(cQrySt)
								EndIf
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cRHHAlias,.T.,.T.)

								If lVerRJ5
									fVerRJ5B(cRHHAlias, cSRDTabRH, (SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)), @lRJ5Ok, @aErrosRJ5)
								EndIf

								If !lGeraRat
									fGerRatB(cRHHAlias, cSRDTabRH, (SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)))
								EndIf

								While (cRHHAlias)->(!Eof())
									If cPerAnt <> (cRHHAlias)->RHH_DATA
										cPerAnt 	:= (cRHHAlias)->RHH_DATA
										cCCAnt		:= ""
										If lFechPer
											lFechPer 	:= .F.
										EndIf
										lGeraPer 	:= .T.
										lTemVerbas	:= .F.
										lVerDINSS	:= .T.
										lGerDINSS	:= .F.
									EndIf
									If cCCAnt <> (cRHHAlias)->RHH_CC
										cTpInscr	:= ""
										cInscr		:= ""
										cCCAnt 		:= (cRHHAlias)->RHH_CC
										lFechEstLot	:= .F.
										lGeraEstLot	:= .T.
										lTemVerbas	:= .F.
										lVerDINSS	:= .T.
										lGerDINSS	:= .F.

										fEstabELot((cRHHAlias)->RHH_FILIAL,(cRHHAlias)->RHH_CC,@cTpInscr,@cInscr,@cBusca, Iif(lVerRJ5, (cRHHAlias)->RHH_CCBKP, ""), cCompete, @cChaveS1005)

										dbselectarea('CTT')
										DbsetOrder(1)
										CTT->(DBSeek( xFilial("CTT", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC )  )

										cVerIndSimples := ''
										If cOptSimp == "1"
											cVerIndSimples := aTabInss[31, 1]
										EndIf

									endif

									If !((cRHHAlias)->RHH_VB == "000" .Or. (cRHHAlias)->RHH_VALOR <= 0.00)
										lTemVerbas	:= .T.
										If cRHHFilAnt <> (cRHHAlias)->RHH_FILIAL
											cRHHFilAnt 	:= (cRHHAlias)->RHH_FILIAL
											nFilRHH		+= 1
										EndIf
										If lFirstAnt
											lFirstAnt	:= .F.
											lGerouAnt	:= .T.
											If !lAbriu19
												If aScan(aInfPerAnt, { |x| x[1]+x[2] == SRA->RA_CIC+cDmDev+SRA->RA_CATEFD }) == 0
													aAdd( aInfPerAnt, { SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<infoPerAnt>
												EndIf
												lAbriu19 := .T.
											Endif
											If !lAbriu20
												If aScan(aIdeADCAnt, { |x| If(cVersaoEnv < "9.0.0", x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] = aIdeAdc[nD,1]+aIdeAdc[nD,2]+aIdeAdc[nD,3]+aIdeAdc[nD,4]+aIdeAdc[nD,5]+aIdeAdc[nD,6]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD, x[1]+x[2]+x[5]+x[6]+x[7]+x[8] = aIdeAdc[nD,1]+aIdeAdc[nD,2]+aIdeAdc[nD,5]+aIdeAdc[nD,6]+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD) }) == 0
													aAdd( aIdeADCAnt, { aIdeAdc[nD,1], aIdeAdc[nD,2], If(cVersaoEnv < "9.0.0", aIdeAdc[nD,3], ""), If(cVersaoEnv < "9.0.0", aIdeAdc[nD,4], ""), aIdeAdc[nD,5], aIdeAdc[nD,6], SRA->RA_CIC, cDmDev+SRA->RA_CATEFD } )//<ideADC>
												EndIf
												lAbriu20 := .T.
												cDtAco	 := aIdeAdc[nD,1]
												cTpAco	 := aIdeAdc[nD,2]
											Endif
										EndIf
										If lGeraPer
											lFechPer	:= .T.
											lGeraPer 	:= .F.
											cPerRef		:= SubStr((cRHHAlias)->RHH_DATA,1,4) + "-" + SubStr((cRHHAlias)->RHH_DATA,5,2)
											If aScan(aIdePer, { |x| x[1]+x[2]+x[3] == cPerRef+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco }) == 0
												aAdd( aIdePer, { cPerRef, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco } )//<idePeriodo>
											EndIf
										EndIf
										If lGeraEstLot
											lFechEstLot := .T.
											lGeraEstLot	:= .F.
											If aScan(aEstLotAnt, { |x| x[1]+x[2]+x[3]+x[5]+x[6] == cTpInscr+cInscr+cBusca+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef }) == 0
												aAdd( aEstLotAnt, { cTpInscr, cInscr, cBusca, Nil, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef, cChaveS1005 } )//<ideEstabLot>
											EndIf
											If Len(aResCompl) > 0 .And. aResCompl[nContRes, 1] == "2"
												If aScan(aRemPerAnt, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca }) == 0
													aAdd( aRemPerAnt, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDataCor+cTpAco+cPerRef+cTpInscr+cInscr+cBusca } )//<remunPerAnt>
												EndIf
											Else
												If aScan(aRemPerAnt, { |x| x[1]+x[2]+x[3]+x[4] == cMatricula+cVerIndSimples+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca }) == 0
													aAdd( aRemPerAnt, { cMatricula, cVerIndSimples, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca } )//<remunPerAnt>
												EndIf
											EndIf
										EndIf

										// Posiciona na verba em trabalho
										cCodFol 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_CODFOL' )
										cCodFil 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_FILIAL' )
										cCodNat 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_NATUREZ' )
										cCodINCCP 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_INCCP' )
										cCodINCIRF 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_INCIRF' )
										cCodINCFGT 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_INCFGTS' )
										cIncINS 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_INSS' )
										cIncIRF 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_IR' )
										cIncFGT 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_FGTS' )
										cCodPerc 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_PERC' )
										cTpCod 		:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_TIPOCOD' )
										nValor 		:= (cRHHAlias)->RHH_VALOR
										If  cVersEnvio >= "9.0"
											If lRVIncop
												cInCop 	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_INCOP' )
											Endif
											If lRVTetop
												cTetoP	:= RetValSrv( (cRHHAlias)->RHH_VB, (cRHHAlias)->RHH_FILIAL, 'RV_TETOP' )
											Endif
										Endif

										If !Empty(xFilial("SRV",cCodFil))
											lGeraCod := .T.
										EndIf
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
												If Empty(cIdeRubr)
													aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Aten��o"##"N�o ser� poss�vel efetuar a integra��o. O identificador de tabela de rubrica do c�digo: "##" n�o est� cadastrado."
													Return .F.
												EndIf
											EndIf
											cIdTbRub := cIdeRubr
										EndIf

										If ( cVersaoEnv == '2.2' ) .OR.;
											( cVersaoEnv == '2.3' .AND. !((SRA->RA_CATEFD $ (cBolsistas + cContrib)) .AND. (cCodNat $ '1409|4050|4051|1009'))) .OR.;
											( cVersaoEnv >= '2.4' .AND. !((SRA->RA_CATEFD $ (cBolsistas + cContrib)) .AND. (cCodINCCP $ '25|26|51')))
											if If(cVersaoEnv >= "9.0.00" ,.T., cCodNat <> "9213") .and. (VAL(cCodINCCP) <> 23 .AND. VAL(cCodINCCP) <> 24 .AND. VAL(cCodINCCP) <> 61);
											.AND. (( cVersaoEnv < "2.6.00" .And. !(SUBSTR(cCodINCIRF, 1, 2) $ '31|32|33|34|35|51|52|53|54|55|81|82|83') ) .OR. ;
											( cVersaoEnv >= "2.6.00" .And. !(fRetTpIRF(cCodINCIRF) $ "D|I|J") ))
												//[ PODEM SER N REGISTROS ]  itensRemun
												If cCodFol $ "0064/0065" .And. lVerDINSS
													lVerDINSS := .F.
													aAreaSRV := SRV->( GetArea() )
													cVerbBus := ""
													SRV->( dbSetOrder(2) )
													If cCodFol == "0064"
														If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0065" ) )
															cVerbBus := SRV->RV_COD
														EndIf
													ElseIf cCodFol == "0065"
														If SRV->( dbSeek( xFilial("SRV", (cRHHAlias)->RHH_FILIAL ) + "0064" ) )
															cVerbBus := SRV->RV_COD
														EndIf
													EndIf
													RHH->( dbSetOrder(1) )
													If !Empty(cVerbBus) .And. RHH->( dbSeek( (cRHHAlias)->RHH_FILIAL + (cRHHAlias)->RHH_MAT + (cRHHAlias)->RHH_MESANO + (cRHHAlias)->RHH_DATA + cVerbBus + Iif(lVerRJ5, (cRHHAlias)->RHH_CCBKP, (cRHHAlias)->RHH_CC) ) )
														If (cRHHAlias)->RHH_VALOR + RHH->RHH_VALOR > 0
															lGerDINSS := .T.
															If (cRHHAlias)->RHH_VALOR < 0 .Or. RHH->RHH_VALOR < 0
																nValor 	  := ((cRHHAlias)->RHH_VALOR + RHH->RHH_VALOR)
															EndIf
														EndIf
													Else
														If (cRHHAlias)->RHH_VALOR > 0
															lGerDINSS := .T.
														Endif
													EndIf
													RestArea(aAreaSRV)
												EndIf
												If !(cCodFol $ "0064/0065") .Or. (cCodFol $ "0064/0065" .And. lGerDINSS)
													nPercRub := (cCodPerc - 100)
													If (nPosItRem := aScan(aItRemAnt, { |x| x[1]+x[2]+x[7]+x[8] == (cRHHAlias)->RHH_VB+cIdTbRub+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula })) == 0
														aAdd( aItRemAnt, { (cRHHAlias)->RHH_VB, cIdTbRub, Str( 0 ), Iif((cCodPerc - 100) < 0, 0, Transform(nPercRub,"@E 999.99")), Nil, Str( NoRound( nValor / nParDiss, 2 ) ), SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula, cCodNat, cCodINCCP, cCodINCIRF, cCodINCFGT, cIncINS, cIncIRF, cIncFGT, cTpCod, (cCodFil+(cRHHAlias)->RHH_VB), cInCop, cTetoP  } )//<itensRemun>
													Else
														aItRemAnt[nPosItRem, 6] := Str( Val(aItRemAnt[nPosItRem, 6]) + NoRound( nValor / nParDiss, 2 ) )
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf

									(cRHHAlias)->( dbSkip() )
									If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. cPerAnt <> (cRHHAlias)->RHH_DATA .And. lFechPer
										If SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
											cOcorren := fGrauExp()
											If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula  } ) == 0
												aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
											EndIf
										EndIf
										lFechPer := .F.
										Loop
									Endif
									If (cRHHAlias)->(!Eof()) .And. lTemVerbas .And. cCCAnt <> (cRHHAlias)->RHH_CC .And. cPerAnt == (cRHHAlias)->RHH_DATA .And. lFechEstLot
										If SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
											cOcorren := fGrauExp()
											If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula  } ) == 0
												aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
											EndIf
										EndIf
										lFechEstLot := .F.
									Endif
								EndDo

								If Len(aItRemAnt) > 0 .And. lMesAnt
									lMsgDiss := .T.
								EndIf

								If nFilRHH > 1
									lDissMV := .T.
								EndIf

								If lGeraRat
									(cRHHAlias)->( dbCloseArea() )
								Else
									oTmpTabl2:Delete()
									oTmpTabRH:Delete()
									oTmpTabl2 := Nil
									oTmpTabRH := Nil
								EndIf
								If lTemVerbas
									If SRA->RA_CATEFD $ (fCatTrabEFD("TCV")+fCatTrabEFD("AGE")+fCatTrabEFD("AVU")+"738/731/734/")
										cOcorren := fGrauExp()
										If aScan( aAgNocAnt, { |x| x[1]+x[2]+x[3] == cOcorren+SRA->RA_CIC+cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula  } ) == 0
											aAdd( aAgNocAnt, { cOcorren, SRA->RA_CIC, cDmDev+SRA->RA_CATEFD+cDtAco+cTpAco+cPerRef+cTpInscr+cInscr+cBusca+cMatricula } )//<infoAgNocivo>
										EndIf
									EndIf
								EndIf
							ElseIf Empty(aLogDiss)
								aAdd( aLogDiss, OemToAnsi(STR0046) + OemToAnsi(STR0036) )//"[FALHA] "##"Preenchimento incorreto das tabelas S050/S126. As informa��es de diss�dio n�o foram geradas."
								If lRelat
									aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0036) } )//"Preenchimento incorreto das tabelas S050/S126. As informa��es de diss�dio n�o foram geradas."
								EndIf
								If Empty(cDscAc)
									aAdd( aLogDiss, OemToAnsi(STR0059) + DtoC(RHH->RHH_DTACOR) + OemToAnsi(STR0060) + RHH->RHH_SINDIC + OemToAnsi(STR0061) )//"Data de Acordo __/__/__, para o sindicato __, n�o tem descri��o do acordo preenchida na tabela S126."
									If lRelat
										aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0059) + DtoC(RHH->RHH_DTACOR) + OemToAnsi(STR0060) + RHH->RHH_SINDIC + OemToAnsi(STR0061) } )//"Data de Acordo __/__/__, para o sindicato __, n�o tem descri��o do acordo preenchida na tabela S126."
									EndIF
								EndIf
								If Empty(cTpAco)
									aAdd( aLogDiss, OemToAnsi(STR0062) + RHH->RHH_TPOAUM + OemToAnsi(STR0063) )//"O tipo de aumento ___ n�o tem Tipo de Acordo eSocial cadastrado na tabela S050."
									If lRelat
										aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0062) + RHH->RHH_TPOAUM + OemToAnsi(STR0063) } )//"O tipo de aumento ___ n�o tem Tipo de Acordo eSocial cadastrado na tabela S050."
									EndIf
								EndIf
								aAdd( aLogDiss, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=379299221" )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
								If lRelat
									aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=379299221" } )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
								EndIf
							EndIf
						ElseIf Empty(aLogDiss)
							aAdd( aLogDiss, OemToAnsi(STR0064) )//"N�o h� diss�dio calculado no per�odo, confira a configura��o das verbas."
							aAdd( aLogDiss, OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=392501017" )//"Para mais informa��es, consulte a documenta��o dispon�vel em: "
							If lRelat
								aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0064) + " " + OemToAnsi(STR0053) + "http://tdn.totvs.com/pages/viewpage.action?pageId=392501017" } )//"N�o h� diss�dio calculado no per�odo, confira a configura��o das verbas."##"Para mais informa��es, consulte a documenta��o dispon�vel em: "
							EndIf
						EndIf
					Next nD
				EndIf
			EndIf
		EndIf
	Next nContRes

return

/*/{Protheus.doc} fVerDtPgto
Fun��o que verifica a data de pagamento do roteiro
@author Allyson
@since 17/08/2018
@version 1.0
@param cTabela	- Data de Pagamento da verba
@param cTabela	- Tabela da verba
@param cRecno	- Recno da verba
@return cDtPgt	- Data de pagamento do roteiro
/*/
Function fVerDtPgto( cData, cTabela, cRecno, cAliasBusc )

Local cDtPgt 		:= cData
Local cNumPag		:= ""
Local cPd			:= ""
Local cPeriodo		:= ""
Local cRoteiro		:= ""
Local cTpRot		:= ""
Local lAchou		:= .F.
Local lTabSRD		:= .F.
Local nRchIndex		:= 0

Default cAliasBusc	:= cSRDAlias

If (cAliasBusc)->TAB == "SRC"
	SRC->( dbGoTo( (cAliasBusc)->RECNO ) )
	cPeriodo	:= SRC->RC_PERIODO
	cNumPag		:= SRC->RC_SEMANA
	cRoteiro	:= SRC->RC_ROTEIR
	cTpRot 		:= fGetTipoRot( SRC->RC_ROTEIR )
Else
	SRD->( dbGoTo( (cAliasBusc)->RECNO ) )
	cPeriodo	:= SRD->RD_PERIODO
	cNumPag		:= SRD->RD_SEMANA
	cRoteiro	:= SRD->RD_ROTEIR
	cTpRot 		:= fGetTipoRot( SRD->RD_ROTEIR )
	lTabSRD		:= .T.
EndIf

If cTpRot $ "1/2/5/6/9/F"//FOL|ADI|131|132|AUT/PLR
	If cTpRot == "1"//FOL
		cPd := aCodFol[318, 1]//Salario do Mes
	ElseIf cTpRot == "2"//ADI
		cPd := aCodFol[006, 1]//Pagto do Adiantamento
	ElseIf cTpRot == "5"//131
		cPd := aCodFol[022, 1]//1� Parc. 13� Sal.
	ElseIf cTpRot == "6"//132
		cPd := aCodFol[024, 1]//Parcela Final 13� Sal
	ElseIf cTpRot == "9"//AUT
		cPd := aCodFol[221, 1]//Base Inss Aut./Pro-Labore
	ElseIf cTpRot == "F"//PLR
		cPd := aCodFol[151, 1]//Distribui��o de Lucros
	EndIf
	//Faz a pesquisa na SRC/SRD pela verba de pagamento do roteiro para buscar a data
	If !Empty(cPd)
		If lTabSRD
			SRD->( dbSetOrder(1) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
			IF SRD->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo + cPd + cNumPag) )
				While SRD->( !EoF() ) .And. SRA->RA_FILIAL + SRA->RA_MAT + SRD->RD_PERIODO + SRD->RD_PD + SRD->RD_SEMANA == SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo + cPd + cNumPag
					If SRD->RD_ROTEIR == cRoteiro
						cDtPgt 	:= dToS(SRD->RD_DATPGT)
						lAchou	:= .T.
						Exit
					EndIf
					SRD->( dbSkip() )
				EndDo
			EndIf
		Else
			SRC->( dbSetOrder(4) )//RC_FILIAL+RC_MAT+RC_PERIODO+RC_ROTEIR+RC_SEMANA+RC_PD
			IF SRC->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cPeriodo + cRoteiro + cNumPag + cPd ) )
				cDtPgt 	:= dToS(SRC->RC_DATA)
				lAchou	:= .T.
			EndIf
		EndIf
	EndIf
EndIf

//Se n�o encontrar a data no acumulado, busca a data pelo cadastro do periodo
If !lAchou
	nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
	RCH->( dbSetOrder(nRchIndex) )
	If RCH->( dbSeek( xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES + cPeriodo + cNumPag + cRoteiro ) )
		cDtPgt := dToS(RCH->RCH_DTPAGO)
	EndIf
EndIf

Return cDtPgt

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fGetAssMed   �Baseado em Copia GPEM026C � Data �  25/05/17  ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtem os valores de Assistencia Medica                      ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM026C                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fGetAssMed( cFil, cMat, cVersao, cPer, cOpcTab, lCPFDepOk, aDepAgreg, cdmDev )
	Local cGetAlias  	:= ""
	Local aDados     	:= {}
	Local aLstDeps   	:= {}
	Local nPos		 	:= 0
	Local nX		 	:= 0
	Local cFilRCC		:= xFilial('RCC', cFil)

	Default cFil		:= ""
	Default cMat	 	:= ""
	Default cVersao	 	:= ""
	Default cPer	 	:= ""
	Default cOpcTab	 	:= "0"
	Default lCPFDepOk	:= .T.
	Default aDepAgreg	:= {}
	Default cdmDev		:= ""

	cGetAlias  := GetNextAlias()

	If __oSt04 == Nil
		__oSt04 := FWPreparedStatement():New()
		cQrySt := "SELECT RHS_FILIAL,RHS_MAT,RHS_CODFOR,RHS_PD,RHS_CODIGO,RHS_COMPPG,RHS_TPFORN,RHS_ORIGEM,SUM(RHS_VLRFUN) TOTAL,RCC_CONTEU "
		cQrySt += "FROM " + RetSqlName('RHS') + " RHS "
		cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHS_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
		cQrySt += "WHERE RHS_FILIAL = ? AND "
		cQrySt += 		"RHS_MAT = ? AND "
		cQrySt += 		"RCC_FILIAL = ? AND "
		cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHS_FILIAL) AND "
		cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHS.RHS_TPFORN = '1' THEN 'S016' WHEN RHS.RHS_TPFORN = '2' THEN 'S017' END ) AND "
		cQrySt += 		"RHS_COMPPG = '" + cPer + "' AND "
		cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"RHS.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHS_FILIAL, RHS_MAT, RHS_CODFOR, RHS_PD, RHS_CODIGO, RHS_COMPPG, RHS_TPFORN, RHS_ORIGEM, RCC_CONTEU "
		cQrySt += "UNION ALL "
		cQrySt += "SELECT RHP_FILIAL,RHP_MAT,RHP_CODFOR,RHP_PD,RHP_CODIGO,RHP_COMPPG,RHP_TPFORN,RHP_ORIGEM,SUM(RHP_VLRFUN) TOTAL,RCC_CONTEU "
		cQrySt += "FROM " + RetSqlName('RHP') + " RHP "
		cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHP_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
		cQrySt += "WHERE RHP_FILIAL = ? AND "
		cQrySt += 		"RHP_MAT = ? AND "
		cQrySt += 		"RCC_FILIAL = ? AND "
		cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHP_FILIAL) AND "
		cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHP.RHP_TPFORN = '1' THEN 'S016' WHEN RHP.RHP_TPFORN = '2' THEN 'S017' END ) AND "
		cQrySt += 		"RHP_COMPPG = '" + cPer + "' AND "
		cQrySt += 		"RHP_TPLAN != '2' AND "
		cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"RHP.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHP_FILIAL, RHP_MAT, RHP_CODFOR, RHP_PD, RHP_CODIGO, RHP_COMPPG, RHP_TPFORN, RHP_ORIGEM, RCC_CONTEU "
		If cOpcTab == "1"
			cQrySt += "UNION ALL "
			cQrySt += "SELECT RHR_FILIAL,RHR_MAT,RHR_CODFOR,RHR_PD,RHR_CODIGO,RHR_COMPPG,RHR_TPFORN,RHR_ORIGEM,SUM(RHR_VLRFUN) TOTAL,RCC_CONTEU "
			cQrySt += "FROM " + RetSqlName('RHR') + " RHR "
			cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHR_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
			cQrySt += "WHERE RHR_FILIAL = ? AND "
			cQrySt += 		"RHR_MAT = ? AND "
			cQrySt += 		"RCC_FILIAL = ? AND "
			cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHR_FILIAL) AND "
			cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHR.RHR_TPFORN = '1' THEN 'S016' WHEN RHR.RHR_TPFORN = '2' THEN 'S017' END ) AND "
			cQrySt += 		"RHR_COMPPG = '" + cPer + "' AND "
			cQrySt += 		"RHR_TPLAN != '3' AND "
			cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
			cQrySt += 		"RHR.D_E_L_E_T_ = ' ' "
			cQrySt += "GROUP BY RHR_FILIAL, RHR_MAT, RHR_CODFOR, RHR_PD, RHR_CODIGO, RHR_COMPPG, RHR_TPFORN, RHR_ORIGEM, RCC_CONTEU "
		EndIf
		cQrySt := ChangeQuery(cQrySt)
		__oSt04:SetQuery(cQrySt)
	EndIf
	__oSt04:SetString(1, cFil)
	__oSt04:SetString(2, cMat)
	__oSt04:SetString(3, cFilRCC)
	__oSt04:SetString(4, cFil)
	__oSt04:SetString(5, cMat)
	__oSt04:SetString(6, cFilRCC)
	If cOpcTab == "1"
		__oSt04:SetString(7, cFil)
		__oSt04:SetString(8, cMat)
		__oSt04:SetString(9, cFilRCC)
	EndIf
	cQrySt := __oSt04:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cGetAlias,.T.,.T.)

	While ( (cGetAlias)->( !Eof() ) )

		aLstDeps := {}
		If (cGetAlias)->RHS_ORIGEM == "2"
			If SRB->( dbSeek( (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + (cGetAlias)->RHS_CODIGO ) )
				aAdd( aLstDeps, { SRB->RB_CIC, fSubst(SRB->RB_NOME), dToS(SRB->RB_DTNASC), (cGetAlias)->TOTAL, fTpDep(Alltrim(SRB->RB_TPDEP), cVersao), SRB->RB_COD, (cGetAlias)->RHS_ORIGEM} )
				If cVersao >= "2.5.00" .And. Empty(SRB->RB_CIC)
					lCPFDepOk := .F.
					If aScan(aDepAgreg, { |x| x == fSubst(SRB->RB_NOME) }) == 0
						aAdd( aDepAgreg, fSubst(SRB->RB_NOME) )
					EndIf
				EndIf
			EndIf
		ElseIf (cGetAlias)->RHS_ORIGEM == "3"
			RHM->( dbSetOrder(1) )
			If RHM->( dbSeek( (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + (cGetAlias)->RHS_TPFORN + (cGetAlias)->RHS_CODFOR + (cGetAlias)->RHS_CODIGO ) )
				aAdd( aLstDeps, { RHM->RHM_CPF, fSubst(RHM->RHM_NOME), dToS(RHM->RHM_DTNASC), (cGetAlias)->TOTAL, fTpDep(Alltrim("13"), cVersao), RHM->RHM_CODIGO, (cGetAlias)->RHS_ORIGEM} )
				If cVersao >= "2.5.00" .And. Empty(RHM->RHM_CPF)
					lCPFDepOk := .F.
					If aScan(aDepAgreg, { |x| x == fSubst(RHM->RHM_NOME) }) == 0
						aAdd( aDepAgreg, fSubst(RHM->RHM_NOME) )
					EndIf
				EndIf
			EndIf
		EndIf

		nPos := ascan(aDados,{|X| X[6] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 )  }) //busca apenas pelo CNPJ
		If nPos == 0
			aAdd(aDados, { 	(cGetAlias)->RHS_FILIAL ,;					//Filial da RHS - Plano de Saude
										(cGetAlias)->RHS_MAT		,; 	//Matric da RHS - Plano de Saude
										(cGetAlias)->RHS_CODFOR	,; 		//CodFor da RHS - Plano de Saude
										(cGetAlias)->RHS_PD		,; 		//Verba  da RHS - Plano de Saude
										(cGetAlias)->RHS_CODIGO	,; 		//Depend da RHS - Plano de Saude
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),;  //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168, 6 )  ,; //ANS Fornecedor
										Iif( (cGetAlias)->RHS_ORIGEM == "1", (cGetAlias)->TOTAL, 0)	 ,;//Valor Titular
										aLstDeps ,;						//Soma GastaRHS - Plano de Saude
										cdmDev}) 						//Identificador do dmDev (utilizado no S-1210)
		Else
			If aDados[nPos,7] == Substr( (cGetAlias)->RCC_CONTEU, 168, 6 )
				If Empty((cGetAlias)->RHS_CODIGO) .Or. (cGetAlias)->RHS_ORIGEM == "1"
					aDados[nPos,8] += (cGetAlias)->TOTAL
				EndIf
				For nX := 1 to Len(aLstDeps)
					nPos2 := ascan(aDados[nPos,9], {|X| X[7]+X[6] == aLstDeps[nX,7] + aLstDeps[nX,6] })
					If nPos2 == 0
						AAdd ( aDados[nPos,9], aLstDeps[nX] )
					Else
						aDados[nPos,9,nPos2,4] += aLstDeps[nX,4]
					EndIf
				Next
			ElseIf ascan(aFornPLA,{|X| X[3] == aDados[nPos,6]}) == 0 //se o codigo ANS for diferente, mas o CNPJ o mesmo, inclui mensagem de incorformidade
				lFornPLA:= .F.
				//"Fornecedor de Plano de Sa�de "##" possui dois c�digos ANS informados."##"Verifique os cadastros de Fornecedores de Plano de Sa�de (S016) e Odontol�gico (S107). "
				aAdd( aFornPLA, { SRA->RA_FILIAL, SRA->RA_CIC,aDados[nPos,6], OemToAnsi(STR0152) + aDados[nPos,6] + OemToAnsi(STR0153) , OemToAnsi(STR0154) } )
			EndIf
		EndIf

		( cGetAlias )->(DbSkip())
	EndDo
	( cGetAlias )->( dbCloseArea() )

Return aDados

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �GetMulVin       �Autor �Copia GPEM026C � Data �  25/05/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtem os Valores de Multiplos Vinculos do Funcionario       ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GPEM026C                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GetMulVin( cFil, cMat, cPer, cTipo, cCIC )

Local cGetAlias  := ""
Local aDados 	 := {}
Local cPerIn	 := fSqlIN( cPer+SubStr(cPer, 1, 4)+"13", 6 )

Default cCIC	:= ""

If lNewMV .And. (RAZ->(ColumnPos("RAZ_CIC")) == 0 .Or. Empty(cCIC ))
	lNewMV := .F.
EndIf

	cGetAlias  := GetNextAlias()

	If __oSt10 == Nil
		__oSt10 := FWPreparedStatement():New()
		If lNewMV
			cQrySt := "SELECT RAW_FILIAL,RAW_MAT,RAW_FOLMES,RAW_TPFOL,RAW_TPREC,RAW_PROCES,RAW_SEMANA,RAW_ROTEIR,RAZ_TPINS,RAZ_INSCR,RAZ_VALOR,RAZ_CATEG, RAZ_CIC "
		Else
			cQrySt := "SELECT RAW_FILIAL,RAW_MAT,RAW_FOLMES,RAW_TPFOL,RAW_TPREC,RAW_PROCES,RAW_SEMANA,RAW_ROTEIR,RAZ_TPINS,RAZ_INSCR,RAZ_VALOR,RAZ_CATEG "
		EndIf
		cQrySt += "FROM " + RetSqlName('RAW') + " AW "
		cQrySt += "JOIN " + RetSqlName('RAZ') + " AZ ON "
		cQrySt += 		"AW.RAW_FILIAL = AZ.RAZ_FILIAL AND "
		cQrySt += 		"AW.RAW_MAT = AZ.RAZ_MAT AND "
		cQrySt += 		"AW.RAW_FOLMES = AZ.RAZ_FOLMES AND "
		cQrySt += 		"AW.RAW_TPFOL = AZ.RAZ_TPFOL "
		If lNewMV
			cQrySt += "WHERE ((AW.RAW_FILIAL = ? AND "
			cQrySt += 		"AW.RAW_MAT = ?) OR AZ.RAZ_CIC = ?) AND "
		Else
			cQrySt += "WHERE AW.RAW_FILIAL = ? AND "
			cQrySt += 		"AW.RAW_MAT = ? AND "
		EndIf
		cQrySt += 		"RAW_FOLMES IN (" + cPerIn + ") AND "
		cQrySt += 		"AW.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"AZ.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt10:SetQuery(cQrySt)
	EndIf
	__oSt10:SetString(1, cFil)
	__oSt10:SetString(2, cMat)
	If lNewMV
		__oSt10:SetString(3, cCIC)
	EndIf
	cQrySt := __oSt10:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cGetAlias,.T.,.T.)

	While ( (cGetAlias)->( !Eof() ) )
		If cTipo == "1" .And. (cGetAlias)->RAW_ROTEIR != "132" .Or. cTipo == "2" .And. (cGetAlias)->RAW_ROTEIR == "132"

			If lNewMV
			  	If aScan(aDados, {|x| x[9]+x[10]+x[13] == (cGetAlias)->RAZ_TPINS + (cGetAlias)->RAZ_INSCR + (cGetAlias)->RAZ_CIC }) == 0
					aAdd(aDados, { 	(cGetAlias)->RAW_FILIAL ,;	//Filial Funcionario
										(cGetAlias)->RAW_MAT		,; //Matricula Funcionario
										(cGetAlias)->RAW_FOLMES	,; //Periodo de Apuracao
										(cGetAlias)->RAW_TPFOL	,; //Tipo da Folha
										(cGetAlias)->RAW_TPREC	,; //Tipo de Recolhimento
										(cGetAlias)->RAW_PROCES	,; //Codigo do Processo
										(cGetAlias)->RAW_SEMANA	,; //Numero de pagemento
										(cGetAlias)->RAW_ROTEIR	,; //Roteiro
										(cGetAlias)->RAZ_TPINS	,; //Tipo de Inscricao (CNPJ / CPF)
										(cGetAlias)->RAZ_INSCR	,; //Valor da Inscricao (N CPF ou CNPJ)
										(cGetAlias)->RAZ_VALOR	,; //Valor Pago
										(cGetAlias)->RAZ_CATEG	,; //Categoria eSocial
										(cGetAlias)->RAZ_CIC	}) //CPF do funcion�rio
				Endif
			Else
				aAdd(aDados, { 	(cGetAlias)->RAW_FILIAL ,;	//Filial Funcionario
									(cGetAlias)->RAW_MAT		,; //Matricula Funcionario
									(cGetAlias)->RAW_FOLMES	,; //Periodo de Apuracao
									(cGetAlias)->RAW_TPFOL	,; //Tipo da Folha
									(cGetAlias)->RAW_TPREC	,; //Tipo de Recolhimento
									(cGetAlias)->RAW_PROCES	,; //Codigo do Processo
									(cGetAlias)->RAW_SEMANA	,; //Numero de pagemento
									(cGetAlias)->RAW_ROTEIR	,; //Roteiro
									(cGetAlias)->RAZ_TPINS	,; //Tipo de Inscricao (CNPJ / CPF)
									(cGetAlias)->RAZ_INSCR	,; //Valor da Inscricao (N CPF ou CNPJ)
									(cGetAlias)->RAZ_VALOR	,; //Valor Pago
									(cGetAlias)->RAZ_CATEG	}) //Categoria eSocial
			EndIf
		EndIf
		DbSkip()
	EndDo

	( cGetAlias )->( dbCloseArea() )

Return aDados

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � FormText()     �Autor�  Oswaldo L        � Data �20/06/2017�
�����������������������������������������������������������������������Ĵ
�Descri��o �Fromata texto para relatorio                                �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM036                                                    �
�����������������������������������������������������������������������Ĵ
� Retorno  �Nil															�
�����������������������������������������������������������������������Ĵ
�Parametros�Nil															�
������������������������������������������������������������������������� */
Function FormText(cTexto)
Local nPos     := 1
Local nQtd     := 0
Local nTam     := Len(cTexto)
Local cTxtFrmt := ''

For nPos := 1 to nTam
	cTxtFrmt += substr (cTexto, nPos, 1)
	nQtd += 1

	If (nQtd >= 130 .And. substr(cTexto, nPos, 1) == " ") .Or. substr(cTexto, nPos, 1) == "."
		cTxtFrmt += Chr(13) + Chr(10)
		nQtd     := 0
	EndIf
next
cTexto := cTxtFrmt
return

/*/{Protheus.doc} fTpDep(aDependent,lVer23)
Fun��o que retorna a string xml do tipo de dependente
@type  Function
@author Eduardo
@since 08/09/2017
@version 1.0
@param aDependent, array, array com o dependente
@param lVer23, boolean, Checagem da vers�o do esocial
@return cXml,String, retorno do tipo de dependente tratando as duas vers�es do eSocial.
/*/
static function fTpDep(cDependent,cVersEnvio)
Local cDep:= ""

Default cVersEnvio := "2.4"
If cVersEnvio >= "2.4"
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '04'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '06'
	elseif val(cDependent)==09
		cDep := '09'
	elseif val(cDependent)==10
		cDep := '10'
	elseif val(cDependent)==11
		cDep := '11'
	elseif val(cDependent)==12
		cDep := '12'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
Else
	if val(cDependent)<03
		cDep := cDependent
	elseif val(cDependent)==03 .or. val(cDependent) ==05
		cDep := '03'
	elseif val(cDependent)==04
		cDep := '08'
	elseif val(cDependent)>=06 .and. val(cDependent) <=08
		cDep := '04'
	elseif val(cDependent)==09
		cDep := '05'
	elseif val(cDependent)==10
		cDep := '06'
	elseif val(cDependent)==11
		cDep := '07'
	elseif val(cDependent)==12
		cDep := '15'
	elseif val(cDependent)==13
		cDep := '99'
	Endif
EndIF
Return cDep

/*/{Protheus.doc} fBscRes()
Fun��o respons�vel por verificar se o funcion�rio possui rescis�o calculada no per�odo
@type function
@author Claudinei Soares
@since 30/05/2018
@version 1.0
@param cFilRes 		= Filial a ser pesquisada na tabela SRG
@param cMatRes 		= Matr�cula a ser pesquisada na tabela SRG
@param cCompete 	= Per�odo informado na gera��o do evento
@param dDtRes 		= Data da rescis�o (utilizada no S-1210
@param l1200 		= Se a fun��o foi chamada pelo evento S-1200
@param cTpRes 		= Tipo da rescis�o para tratamento no S-1200
                 	  (0 = Rescis�o normal ou complemententar no mesmo mes, 1 = Complementar sem ser por diss�dio, 2 = Complementar por diss�dio)
@param cPerResCmp	= Per�odo da Rescis�o complementar, utilizado na tag <perRef>
@param aResCompl	= Guarda os tipos de rescis�o e data de demiss�o
@return lRet, L�gico, Retorno da fun��o, se verdadeiro o funcion�rio possui rescis�o no per�odo
/*/

Function fBscRes(cFilRes, cMatRes, cCompete, dDtRes, l1200, cTpRes, cPerResCmp, aResCompl )

Local cGerac		:= ""
Local cDemis		:= ""
Local cHomom		:= ""
Local lRet			:= .F.
Local aArea			:= GetArea()
Local cComp			:= SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)

Default cTpRes		:= ""
Default cPerResCmp	:= ""
Default dDtRes		:= cTod("//")
Default l1200		:= .F.
Default aResCompl	:= {}

dbSelectArea("SRG")
SRG->( dbSetOrder(1) )
SRG->(dbGoTop())

If SRG->( dbSeek( cFilRes + cMatRes ) )
	While SRG->( !Eof() .And. SRG->RG_FILIAL == cFilRes .And. SRG->RG_MAT == cMatRes )
		cGerac := AnoMes(SRG->RG_DTGERAR)
		cDemis := AnoMes(SRG->RG_DATADEM)
		cHomom := AnoMes(SRG->RG_DATAHOM)

		If SRG->RG_EFETIVA == "S" .And. (cGerac == cComp .Or. !l1200 .And. cHomom == cComp)
			If l1200
				If cDemis == cGerac
					cTpRes := "0" //Rescis�o Normal ou Complementar no mesmo m�s
				Else
					cTpRes := SRG->RG_RESCDIS
				Endif
				cPerResCmp := SUBSTR(cDemis,1,4) + "-" + SUBSTR(cDemis,5,2)
				aAdd( aResCompl, { cTpRes, cPerResCmp, SRG->RG_DTGERAR } )
			Else
				If !(cGerac > cDemis .And. SRG->RG_RESCDIS $ "1/2")
					lRet 		:= .T.
					dDtRes		:= SRG->RG_DATAHOM
					cPerResCmp 	:= AnoMes(SRG->RG_DATADEM)
					cTpRes 		:= SRG->RG_RESCDIS
				EndIf
				Exit
			Endif
		Endif
		SRG->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return( lRet )

/*/{Protheus.doc} fGetRes()
Fun��o respons�vel por verificar se o funcion�rio possui rescis�o calculada no per�odo
@type function
@author Claudinei Soares
@since 30/05/2018
@version 1.0
@param cFilRes 		= Filial a ser pesquisada na tabela SRG
@param cMatRes 		= Matr�cula a ser pesquisada na tabela SRG
@param cCompete 	= Per�odo informado na gera��o do evento
@param dDtRes 		= Data da rescis�o (utilizada no S-1210
@param l1200 		= Se a fun��o foi chamada pelo evento S-1200
@param cTpRes 		= Tipo da rescis�o para tratamento no S-1200
                 	  (0 = Rescis�o normal ou complemententar no mesmo mes, 1 = Complementar sem ser por diss�dio, 2 = Complementar por diss�dio)
@param cPerResCmp	= Per�odo da Rescis�o complementar, utilizado na tag <perRef>
@param aResCompl	= Guarda os tipos de rescis�o e data de demiss�o
@param cSemRes		= Semana da Rescis�o
@param cRecResc		= Recibo do S-2299/S-2399
@param cCatTSV		= Categorias TSV
@return lRet, L�gico, Retorno da fun��o, se verdadeiro o funcion�rio possui rescis�o no per�odo
/*/

Function fGetRes(cFilRes, cMatRes, cCompete, dDtRes, l1200, cTpRes, cPerResCmp, aResCompl, cSemRes, cRecResc, cCatTSV, lResComp, cVersEnv, lResTSV)

Local cGerac		:= ""
Local cDemis		:= ""
Local cHomom		:= ""
Local lRet			:= .F.
Local aArea			:= GetArea()
Local cComp			:= SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cKey			:= ""
Local cNrInsc		:= ""
Local cStatus		:= "-1"
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local lGerDem		:= .F. //Vari�vel que verifica se a data de gera��o � menor que a data da demiss�o na rescis�o original
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"
Local lExit			:= .F.

Default cTpRes		:= ""
Default cPerResCmp	:= ""
Default dDtRes		:= cTod("//")
Default l1200		:= .F.
Default aResCompl	:= {}
Default cSemRes		:= "01"
Default cRecResc	:= ""
Default cCatTSV		:= fCatTrabEFD("TSV")
Default lResComp	:= .F.
Default cVersEnv	:= ""
Default lResTSV		:= .F.

dbSelectArea("SRG")
SRG->( dbSetOrder(1) )
SRG->(dbGoTop())

If SRG->( dbSeek( cFilRes + cMatRes ) )
	While SRG->( !Eof() .And. SRG->RG_FILIAL == cFilRes .And. SRG->RG_MAT == cMatRes )
		cGerac	:= AnoMes(SRG->RG_DTGERAR)
		cDemis	:= AnoMes(SRG->RG_DATADEM)
		cHomom	:= AnoMes(SRG->RG_DATAHOM)
		lGerDem	:= (cGerac <= cComp .And. SRG->RG_RESCDIS == "0" .And. cHomom == cComp .And. cDemis == cComp)

		If SRG->RG_EFETIVA == "S" .And. ((cGerac == cComp .Or. !l1200 .And. cHomom == cComp) .Or. (l1200 .And. lGerDem)) .And. cDemis <= cComp
			If cDemis == cGerac
				cTpRes := "0" //Rescis�o Normal ou Complementar no mesmo m�s
			Else
				cTpRes := SRG->RG_RESCDIS
			Endif
			cPerResCmp := SUBSTR(cDemis,1,4) + "-" + SUBSTR(cDemis,5,2)
			aAdd( aResCompl, { cTpRes, cPerResCmp, SRG->RG_DTGERAR } )

			//Ajuste cPerResCmp para n�o conter - (Tra�o)
			If !l1200 .And. lExit
				cPerResCmp 	:= AnoMes(SRG->RG_DATADEM)
			EndIf

			If !l1200 .And. !lExit
				If !(cGerac > cDemis .And. SRG->RG_RESCDIS $ "1/2")
					lRet 		:= .T.
					dDtRes		:= SRG->RG_DATAHOM
					cPerResCmp 	:= AnoMes(SRG->RG_DATADEM)
					cTpRes 		:= SRG->RG_RESCDIS
					cSemRes 	:= SRG->RG_SEMANA
					If lMiddleware
						If SRA->RA_CATEFD $ cCatTSV .And. (cVersEnv < "9.0" .Or. !lGeraMat)
							cKey := AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
						Else
							cKey := SRA->RA_CODUNIC
						EndIf
						If lMiddleware
							fPosFil( cEmpAnt, SRA->RA_FILIAL )
						EndIf
						aInfoC   := fXMLInfos()
						If Len(aInfoC) >= 4
							cTpInsc  := aInfoC[1]
							lAdmPubl := aInfoC[4]
							cNrInsc  := aInfoC[2]
						EndIf
						If SRA->RA_CATEFD $ cCatTSV
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cKey, 36, " ")
						Else
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr(cKey, 36, " ")
						EndIf
						cStatus 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStatus, Nil, Nil, Nil, @cRecResc )
					EndIf
				ElseIf SRG->RG_RESCDIS == "1"
					lResComp := .T.
				EndIf
				lExit := .T.
			Endif
		Endif

		SRG->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return( lRet )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FSubst        � Autor � Cristina Ogura   � Data � 17/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que substitui os caracteres especiais por espacos   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FSubst()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � GPEM610                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function FSubst(cTexto)

Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""
Local nTamTxt := Len(cTexto)
Local j
Local nPos

// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u","","","","","";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin

/*/{Protheus.doc} fGetTpAc
Fun��o que retorna o tipo do acordo coletivo cadastrado na tabela S050 com base no tipo de aumento (campo RHH_TPOAUM)
@author Allyson
@since 29/06/2018
@version 1.0
@return cTipo - Tipo do acordo coletivo
/*/
Function fGetTpAc(lPosiciona, cTpRotBkp, cCompete, cDataCor, cData, lGpm040)

Local aArea		:= GetArea()
Local aTab		:= {}
Local cTipo 	:= ""
Local nPos  	:= 0
Local lRet		:= .F.

Default lPosiciona	:= .F.
Default cTpRotBkp	:= ""
Default cCompete	:= ""
Default cDataCor	:= ""
Default cData		:= ""
Default lGpm040		:= .F.

If lPosiciona
	DbSelectArea("RHH")
	RHH->( dbSetOrder(1) )//RHH_FILIAL+RHH_MAT+RHH_MESANO+RHH_DATA+RHH_VB+RHH_CC+RHH_ITEM+RHH_CLVL+RHH_SEMANA+RHH_SEQ+RHH_ROTEIR
	If ( lGpm040 .Or. lVerRHH ) .And. cTpRotBkp == "1" .And. fPesqRHH( SRA->RA_FILIAL, SRA->RA_MAT, SubStr(cCompete,3,4) + SubStr(cCompete,1,2) )
		lRet := .T.
		cDataCor := dToS(RHH->RHH_DTACOR)
		cData := SubStr(RHH->RHH_DATA,1,4) + "-" + SubStr(RHH->RHH_DATA,5,2)
	Endif
	RestArea(aArea)
EndIf

If !lPosiciona .Or. lRet
	fCarrTab( @aTab, "S050", Nil, .T., Nil, .T., RHH->RHH_FILIAL )

	If ( nPos := aScan( aTab, { |x| x[2] == RHH->RHH_FILIAL .And. x[5] == RHH->RHH_TPOAUM } ) ) > 0
		cTipo := aTab[nPos, 6]
	EndIf

	If nPos == 0
		If ( nPos := aScan( aTab, { |x| x[2] == Space(FwSizeFilial()) .And. x[5] == RHH->RHH_TPOAUM } ) ) > 0
			cTipo := aTab[nPos, 6]
		EndIf
	EndIf
Endif

Return cTipo

/*/{Protheus.doc} fGetDscAc
Fun��o que retorna a descri��o do acordo coletivo cadastrado na tabela S126 com base no sindicato e dato do acordo (campos RHH_SINDIC e RHH_DTACOR)
@author Allyson
@since 29/06/2018
@version 1.0
@return cDesc - Descri��o do acordo coletivo
/*/
Function fGetDscAc(lPosiciona, cTpRotBkp, cCompete, dDtEfeito, lGpm040)

Local aArea	:= GetArea()
Local aTab	:= {}
Local cDesc := ""
Local nPos  := 0
Local lRet	:= .F.

Default lPosiciona	:= .F.
Default cTpRotBkp	:= ""
Default cCompete	:= ""
Default dDtEfeito	:= CTOD("//")
Default lGpm040		:= .F.

If lPosiciona
	DbSelectArea("RHH")
	RHH->( dbSetOrder(1) )//RHH_FILIAL+RHH_MAT+RHH_MESANO+RHH_DATA+RHH_VB+RHH_CC+RHH_ITEM+RHH_CLVL+RHH_SEMANA+RHH_SEQ+RHH_ROTEIR
	If ( lGpm040 .Or. lVerRHH ) .And. cTpRotBkp == "1" .And. fPesqRHH( SRA->RA_FILIAL, SRA->RA_MAT, SubStr(cCompete,3,4) + SubStr(cCompete,1,2) )
		lRet := .T.
	Endif
	RestArea(aArea)
EndIf

If !lPosiciona .Or. lRet
	fCarrTab( @aTab, "S126", Nil, .T., Nil, .T., RHH->RHH_FILIAL )

	If ( nPos := aScan( aTab, { |x| x[2] == RHH->RHH_FILIAL .And. x[5] == RHH->RHH_SINDIC .And. x[6] == RHH->RHH_DTACOR } ) ) > 0
		cDesc := AllTrim( aTab[nPos, 7] )

		//Se possuir o novo campo data efeito acordo leva ele para a tag dtEfAcConv sen�o leva a data do acordo
		If Len(aTab[nPos]) > 7 .And.  !Empty(aTab[nPos,8])
			dDtEfeito := aTab[nPos, 8]
		Else
			dDtEfeito := aTab[nPos, 6]
		Endif
	EndIf

	If nPos == 0
		If ( nPos := aScan( aTab, { |x| x[2] == Space(FwSizeFilial()) .And. x[5] == RHH->RHH_SINDIC .And. x[6] == RHH->RHH_DTACOR } ) ) > 0
			cDesc := AllTrim( aTab[nPos, 7] )
			//Se possuir o novo campo data efeito acordo leva ele para a tag dtEfAcConv sen�o leva a data do acordo
			If Len(aTab[nPos]) > 7 .And.  !Empty(aTab[nPos,8])
				dDtEfeito := aTab[nPos, 8]
			Else
				dDtEfeito := aTab[nPos, 6]
			Endif
		EndIf
	EndIf
Endif

Return cDesc

/*/{Protheus.doc} fVldMatriz
Fun��o que verifica a filial que foi configurada como matriz no TAF
@author Allyson
@since 10/07/2018
@version 1.0
@return cMatriz - C�digo da Matriz
/*/
Function fVldMatriz( cFilEnv, cPeriodo )

Local aAreaSM0		:= SM0->( GetArea() )
Local aMatriz		:= {}
Local cMatriz		:= cFilEnv
Local nFilEmp		:= 0

Default cFilEnv		:= cFilAnt
Default cPeriodo 	:= AnoMes(dDatabase)

If !lMiddleware
	dbSelectArea("SM0")
	dbSetOrder(1)
	If dbSeek( cEmpAnt + cFilEnv )
		aMatriz := TAFGFilMatriz()
		If !Empty(aMatriz)
			cMatriz := aMatriz[2]
		EndIf
	EndIf
Else
	fPosFil( cEmpAnt, cFilEnv )
	If fVld1000( cPeriodo )
		If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == AllTrim(RJ9->RJ9_NRINSC) }) ) > 0
			cMatriz := aSM0[nFilEmp, 2]
		EndIf
	EndIf
EndIf

RestArea(aAreaSM0)

Return cMatriz

/*/{Protheus.doc} fVerStat
Fun��o que verifica a filial que foi configurada como matriz no TAF
@author Allyson
@since 12/07/2018
@version 1.0
@param nTipo 	 - Tabela a ser verificada (1=C91/2=T3P/3=T62)
@param cPeriodo	 - Per�odo de busca do registro
@param aFilInTaf - Configura��o de integra��o das filiais
@return cStatus  - Status do registro da C91/T3P/T62, se encontrado
@return cTipo  	 - Tipo do registro
/*/
Function fVerStat( nTipo, cFilEnv, cPeriodo, aFilInTaf, cTipo, cStatNew, cOperNew, cRetfNew, nRecEvt, cRecibAnt, lNovoRJE, cKeyMid, lAdmPubl, cTpInsc, cNrInsc, cVersEnv,lGera1202 )

Local aAreaC9V	:= {}
Local aIdsC9V	:= {}
Local cAliasC9V	:= GetNextAlias()
Local cFilBkp	:= cFilEnv
Local cFilTAF	:= ""
Local cFilInt	:= ""
Local cStatus	:= "-1"
Local cRecibo	:= ""
Local nCont		:= 0
Local nOrdC91	:= 0
Local nOrdT3P	:= 0
Local cCodEmp	:= ""

Local cChaveMid	:= ""
Local cMatriz	:= ""
Local cOperEvt	:= ""
Local cRetfEvt	:= ""
Local cEvento 	:= "S1200"

Default cTipo		:= "1"
Default cStatNew 	:= "1"
Default cOperNew	:= ""
Default cRetfNew	:= ""
Default nRecEvt 	:= 0
Default cRecibAnt	:= ""
Default lNovoRJE	:= .T.
Default cKeyMid		:= ""
Default lAdmPubl	:= .T.
Default cTpInsc		:= ""
Default cNrInsc		:= ""
Default cVersEnv	:= ""
Default lGera1202   := .F.

If lGera1202
	cEvento := "S1202"
Endif

If !lMiddleware
	aAreaC9V	:= C9V->( GetArea() )
EndIf

If cTipo == "2"
	cPeriodo := SubStr(cPeriodo, 1, 4) + Space(2)
EndIf
//Busca os ID's da C9V vinculados ao CPF
If !lMiddleware
	If __oSt13 == Nil
		__oSt13 := FWPreparedStatement():New()
		If nTipo == 3//S-1207
			cQrySt := "SELECT V73_FILIAL, V73_ID "
			cQrySt += "FROM " + RetSqlName('V73') + " V73 "
			cQrySt += "WHERE V73_CPFBEN = ? AND "
			cQrySt += 		"V73.D_E_L_E_T_ = ' ' "
		Else
			cQrySt := "SELECT C9V_FILIAL, C9V_ID "
			cQrySt += "FROM " + RetSqlName('C9V') + " C9V "
			cQrySt += "WHERE C9V_CPF = ? AND "
			cQrySt += 		"C9V.D_E_L_E_T_ = ' ' "
		EndIf
		cQrySt := ChangeQuery(cQrySt)
		__oSt13:SetQuery(cQrySt)
	EndIf
	__oSt13:SetString(1, SRA->RA_CIC)
	cQrySt := __oSt13:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasC9V,.T.,.T.)

	While (cAliasC9V)->( !EoF() )
		aAdd( aIdsC9V, If(nTipo == 3, { (cAliasC9V)->V73_FILIAL, (cAliasC9V)->V73_ID }, { (cAliasC9V)->C9V_FILIAL, (cAliasC9V)->C9V_ID } ) )
		(cAliasC9V)->( dbSkip() )
	EndDo
	(cAliasC9V)->( dbCloseArea() )
EndIf

//Caso seja multiplo vinculo, procura primeiro o registro na matriz, gravado no CPF
If lMiddleware .Or. (lAglut .And. (SRA->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1 ) )
	If !lMiddleware
		cFilTAF := fVldMatriz(cFilEnv)
		nOrdC91 := RetOrder( "C91", "C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NIS+C91_NOMEVE+C91_ATIVO", .T. )
		nOrdT3P := RetOrder( "T3P", "T3P_FILIAL+T3P_INDAPU+T3P_PERAPU+T3P_CPF+T3P_ATIVO", .T. )
		If nTipo == 1 .And. nOrdC91 > 0
			cFilInt := FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( cFilTAF ) , , "C91", .T.)
			C91->( dbSetOrder(nOrdC91) )
			If C91->( dbSeek( cFilInt + cTipo + cPeriodo + SRA->RA_CIC + Left(SRA->RA_PIS, 11) + cEvento + "1" ) )
				cStatus := C91->C91_STATUS
				cRecibo := C91->C91_PROTUL
			EndIf
		ElseIf nTipo == 2 .And. nOrdT3P > 0
			cFilInt := FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( cFilEnv ) , , "T3P", .T.)
			T3P->( dbSetOrder(nOrdT3P) )

			If ( cVersEnv >= "9.0" .And. T3P->( dbSeek( cFilInt + " " + cPeriodo + SRA->RA_CIC + "1" ) ) ) .Or.;
			T3P->( dbSeek( cFilInt + "1" + cPeriodo + SRA->RA_CIC + "1" ) )
				cStatus := T3P->T3P_STATUS
				cRecibo := T3P->T3P_PROTUL
			EndIf
		EndIf
	Else
		If nTipo == 1
			cKeyMid		:= cPeriodo + cTipo + SRA->RA_CIC
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1200" + Padr(cKeyMid, fTamRJEKey(), " ") + cPeriodo
		Else
			cKeyMid		:= cPeriodo + "1" + SRA->RA_CIC
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1210" + Padr(cKeyMid, fTamRJEKey(), " ") + cPeriodo
		EndIf
		cStatus 	:= "-1"

		If nQtdeFol > 1
			cMatriz := fVldMatriz(cFilEnv, cPeriodo)
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibo, @cRecibAnt, .T., cMatriz, .T. )
			If cStatus != "-1"
				cFilEnv := cMatriz
			EndIf
		EndIf
		If cStatus == "-1"
			cFilEnv := cFilBkp
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibo, @cRecibAnt, .T., cFilEnv, .T. )
		EndIf

		If cStatus $ "1/3"
			cOperNew 	:= cOperEvt
			cRetfNew	:= cRetfEvt
			cStatNew	:= "1"
			lNovoRJE	:= .F.
		//Evento diferente de exclus�o transmitido, ir� gerar uma retifica��o
		ElseIf cStatus == "4"
			cOperNew 	:= "A"
			cRetfNew	:= "2"
			cStatNew	:=  "1"
			lNovoRJE	:= .T.
		//Ser� tratado como inclus�o
		Else
			cOperNew 	:= "I"
			cRetfNew	:= "1"
			cStatNew	:= "1"
			lNovoRJE	:= .T.
		EndIf
		If cRetfNew == "2"
			If cStatus != "4"
				cRecibo 	:= cRecibAnt
			EndIf
		EndIf
	EndIf
EndIf
//Se n�o encontrar, procura na C91/T3P pelos ID's do funcionario
If !lMiddleware .And. cStatus == "-1"
	If lTemGC .And. lTemEmp
		cCodEmp	:= SubStr(cFilEnv, nIniEmp, nTamEmp)
	EndIf
	For nCont := 1 To Len(aIdsC9V)
		If lTemGC .And. lTemEmp
			If SubStr(aIdsC9V[nCont, 1], nIniEmp, nTamEmp) != cCodEmp
				Loop
			EndIf
		EndIf
		If nTipo == 1
			cFilInt := FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( aIdsC9V[nCont, 1] ) , , "C91", .T.)
			If !fVldRaiz( cFilInt, cFilEnv )
				Loop
			EndIf
			C91->( dbSetOrder(2) )
			If C91->( dbSeek( cFilInt + cTipo + cPeriodo + aIdsC9V[nCont, 2] + cEvento + "1" ) )
				C9V->( dbSetOrder(2) )
				If C9V->( dbSeek( C91->C91_FILIAL + C91->C91_TRABAL + "1" ) ) .And. C9V->C9V_CPF == SRA->RA_CIC
					cStatus := C91->C91_STATUS
					cRecibo := C91->C91_PROTUL
					Exit
				EndIf
			EndIf
		ElseIf nTipo == 2
			cFilInt := FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( aIdsC9V[nCont, 1] ) , , "T3P", .T.)
			If !fVldRaiz( cFilInt, cFilEnv )
				Loop
			EndIf
			T3P->( dbSetOrder(2) )
			If ( cVersEnv >= "9.0" .And. T3P->( dbSeek( cFilInt + " " + cPeriodo + aIdsC9V[nCont, 2] + "1" ) ) ) .Or.;
			T3P->( dbSeek( cFilInt + "1" + cPeriodo + aIdsC9V[nCont, 2] + "1" ) ) //2.5
				C9V->( dbSetOrder(2) )
				If C9V->( dbSeek( T3P->T3P_FILIAL + T3P->T3P_BENEFI + "1" ) ) .And. C9V->C9V_CPF == SRA->RA_CIC
					cStatus := T3P->T3P_STATUS
					cRecibo := T3P->T3P_PROTUL
					Exit
				EndIf
			EndIf
		ElseIf nTipo == 3
			cFilInt := FTafGetFil( AllTrim( cEmpAnt ) + AllTrim( aIdsC9V[nCont, 1] ) , , "T62", .T.)
			If !fVldRaiz( cFilInt, cFilEnv )
				Loop
			EndIf
			T62->( dbSetOrder(2) ) //T62_FILIAL+T62_INDAPU+T62_PERAPU+T62_CPF+T62_ATIVO
			If T62->( dbSeek( cFilInt + cTipo + cPeriodo + SRA->RA_CIC + "1" ) )
				cStatus := T62->T62_STATUS
				cRecibo := T62->T62_PROTUL
				Exit
			EndIf
		EndIf
	Next nCont
EndIf

If !lMiddleware
	RestArea( aAreaC9V )
EndIf

Return {cStatus, cRecibo}

/*/{Protheus.doc} fVldRaiz
Fun��o que verifica se a raiz do CNPJ � diferente para pesquisa nas tabelas C91/T3P
@author Allyson
@since 28/03/2019
@version 1.0
@param cFilInt 	 - Filial a ser pesquisa
@param cPeriodo	 - Filial de integra��o
/*/
Static Function fVldRaiz( cFilInt, cFilEnv )

Local lRet 		:= .T.
Local nPos1 	:= 0
Local nPos2 	:= 0

If cFilInt != cFilEnv
	nPos1	:= aScan( aEstb, { |x| x[1] == AllTrim(cFilInt) } )
	nPos2	:= aScan( aEstb, { |x| x[1] == AllTrim(cFilEnv) } )
	If nPos1 > 0 .And. nPos2 > 0 .And. SubStr(aEstb[nPos1, 2], 1, 8) != SubStr(aEstb[nPos2, 2], 1, 8)
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fDiasInter
Fun��o respons�vel por buscar a quantidades de dias trabalhados pelo
funcion�rio com contrato intermitente
@author  Rafael Reis
@since   24/08/18
@version 1
/*/
//-------------------------------------------------------------------
Static Function fDiasInter(cFil, cMat, cCompete, cOpcTab)
Local cAliasTmp		:= GetNextAlias()
Local cJoinRDxRV	:= FWJoinFilial( "SRD", "SRV" )
Local cJoinRDxV7	:= FWJoinFilial( "SRD", "SV7" )
Local cJoinRCxRV	:= FWJoinFilial( "SRC", "SRV" )
Local cJoinRCxV7	:= FWJoinFilial( "SRC", "SV7" )
Local nQtdDias		:= 0

If __oSt07 == Nil
	__oSt07 := FWPreparedStatement():New()
	cQrySt := "SELECT RD_PD, RD_VALOR, RD_TIPO1, RD_HORAS, RD_CONVOC, RV_CODFOL, V7_HRSDIA "
	cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
	cQrySt += "INNER JOIN " + RetSqlName('SRV') + " SRV ON " + cJoinRDxRV + " AND SRD.RD_PD = SRV.RV_COD "
	cQrySt += "INNER JOIN " + RetSqlName('SV7') + " SV7 ON " + cJoinRDxV7 + " AND SRD.RD_CONVOC = SV7.V7_COD AND SRD.RD_MAT = SV7.V7_MAT "
	cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
	cQrySt += 		"SRD.RD_MAT = ? AND "
	cQrySt += 		"SRD.RD_PERIODO = '" + Substr(cCompete,3,4) + Substr(cCompete,1,2) + "' AND "
	cQrySt += 		"SRV.RV_CODFOL = '0032' AND "
	cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
	cQrySt += 		"SRV.D_E_L_E_T_ = ' ' AND "
	cQrySt += 		"SV7.D_E_L_E_T_ = ' ' "
	If cOpcTab == "1"
		cQrySt += "UNION ALL "
		cQrySt += "SELECT RC_PD, RC_VALOR, RC_TIPO1, RC_HORAS, RC_CONVOC, RV_CODFOL, V7_HRSDIA "
		cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
		cQrySt += "INNER JOIN " + RetSqlName('SRV') + " SRV ON " + cJoinRCxRV + " AND SRC.RC_PD = SRV.RV_COD "
		cQrySt += "INNER JOIN " + RetSqlName('SV7') + " SV7 ON " + cJoinRCxV7 + " AND SRC.RC_CONVOC = SV7.V7_COD AND SRC.RC_MAT = SV7.V7_MAT "
		cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
		cQrySt += 		"SRC.RC_MAT = ? AND "
		cQrySt += 		"SRC.RC_PERIODO = '" + Substr(cCompete,3,4) + Substr(cCompete,1,2) + "' AND "
		cQrySt += 		"SRV.RV_CODFOL = '0032' AND "
		cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"SRV.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"SV7.D_E_L_E_T_ = ' ' "
	EndIf
	cQrySt := ChangeQuery(cQrySt)
	__oSt07:SetQuery(cQrySt)
EndIf
__oSt07:SetString(1, cFil)
__oSt07:SetString(2, cMat)
If cOpcTab == "1"
	__oSt07:SetString(3, cFil)
	__oSt07:SetString(4, cMat)
EndIf
cQrySt := __oSt07:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	nQtdDias += (cAliasTmp)->RD_HORAS / (cAliasTmp)->V7_HRSDIA
	(cAliasTmp)->(DbSkip())
EndDo
(cAliasTmp)->(DbCloseArea())

Return Int(nQtdDias)

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscaConv
Fun��o respons�vel por buscar o c�digo do e-social das convoca��es de
um funcion�rio em determinada compet�ncia (Usado no evento S-1200)
@author  Rafael Reis
@since   27/08/18
@version 1
/*/
//-------------------------------------------------------------------
Static Function fBuscaConv(cFil,cMat,cCompete,cCC,cOpcTab)
Local cAliasTmp		:= GetNextAlias()
Local cJoinSRD		:= FWJoinFilial( "SRD", "SV7" )
Local cJoinSRC		:= FWJoinFilial( "SRC", "SV7" )
Local aConvocs		:= {}

If __oSt08 == Nil
	__oSt08 := FWPreparedStatement():New()
	cQrySt := "SELECT DISTINCT RD_CONVOC, V7_CONVC "
	cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
	cQrySt += "INNER JOIN " + RetSqlName('SV7') + " SV7 ON " + cJoinSRD + " AND SRD.RD_CONVOC = SV7.V7_COD AND SRD.RD_MAT = SV7.V7_MAT "
	cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
	cQrySt += 		"SRD.RD_MAT = ? AND "
	cQrySt += 		"SRD.RD_PERIODO = '" + Substr(cCompete,3,4) + Substr(cCompete,1,2) + "' AND "
	cQrySt += 		"SRD.RD_CC = '" + cCC + "' AND "
	cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
	cQrySt += 		"SV7.V7_CONVC <> '" + Space(nTamConvc) + "' AND "
	cQrySt += 		"SV7.D_E_L_E_T_ = ' ' "
	If cOpcTab == "1"
		cQrySt += "UNION ALL "
		cQrySt += "SELECT DISTINCT RC_CONVOC AS RD_CONVOC, V7_CONVC AS V7_CONVC"
		cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
		cQrySt += "INNER JOIN " + RetSqlName('SV7') + " SV7 ON " + cJoinSRC + " AND SRC.RC_CONVOC = SV7.V7_COD AND SRC.RC_MAT = SV7.V7_MAT "
		cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
		cQrySt += 		"SRC.RC_MAT = ? AND "
		cQrySt += 		"SRC.RC_PERIODO = '" + Substr(cCompete,3,4) + Substr(cCompete,1,2) + "' AND "
		cQrySt += 		"SRC.RC_CC = '" + cCC + "' AND "
		cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"SV7.V7_CONVC <> '" + Space(nTamConvc) + "' AND "
		cQrySt += 		"SV7.D_E_L_E_T_ = ' ' "
	EndIf
	cQrySt := ChangeQuery(cQrySt)
	__oSt08:SetQuery(cQrySt)
EndIf
__oSt08:SetString(1, cFil)
__oSt08:SetString(2, cMat)
If cOpcTab == "1"
	__oSt08:SetString(3, cFil)
	__oSt08:SetString(4, cMat)
EndIf
cQrySt := __oSt08:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasTmp,.T.,.T.)

While !(cAliasTmp)->(Eof())
	Aadd(aConvocs, Alltrim((cAliasTmp)->V7_CONVC))
	(cAliasTmp)->(DbSkip())
EndDo
(cAliasTmp)->(DbCloseArea())

Return aConvocs

Static function fVrfTrbVnc(cCpf, cTrabSemVinc, dCompete, lOutS2300, cFilFunc, aFilInTaf, lComplTSV, lExiste2300, lAdmPubl, cTpInsc, cNrInsc)

	Local lAnytrbVnc 	:= .F.
	Local lCmplemTSV	:= .F.
	Local lReturn		:= .F.
	Local cAliasNSRA 	:= GetNextAlias()
	Local cBkpFil		:= cFilAnt
	Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
	Local cFilOld		:= ""
	Local cRaizFunc		:= ""
	Local nPosEmp		:= 0
	Local nPosFunc		:= 0
	Local nX			:= 0

	Local cChaveMid	 	:= ""
	Local cStatMid   	:= ""

	//Query para buscar informacoes Trabalhadores
	If __oSt14 == Nil
		__oSt14 := FWPreparedStatement():New()
		cQrySt := "SELECT SRA.RA_FILIAL,SRA.RA_MAT,SRA.RA_CIC,SRA.RA_CATEFD,SRA.RA_ADMISSA,SRA.RA_DEMISSA,SRA.RA_CODUNIC,SRA.RA_SITFOLH "
		cQrySt += "FROM " + RetSqlName('SRA') + " SRA "
		cQrySt += "WHERE SRA.RA_CIC = ? AND "
		cQrySt += 		"SRA.D_E_L_E_T_ = ' ' "
		cQrySt += "ORDER BY SRA.RA_CATEFD "
		cQrySt := ChangeQuery(cQrySt)
		__oSt14:SetQuery(cQrySt)
	EndIf
	__oSt14:SetString(1, cCpf)
	cQrySt := __oSt14:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasNSRA,.T.,.T.)

	TCSetField( cAliasNSRA, "RA_ADMISSA", "D", 8, 0 )
	TCSetField( cAliasNSRA, "RA_DEMISSA", "D", 8, 0 )

	If ( nPosFunc := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + cFilFunc } ) ) > 0
		cRaizFunc := SubStr(aSM0[nPosFunc, 18], 1, 8)
	EndIf

	WHILE (cAliasNSRA)->(!EOF()) .AND. !lExiste2300
		If (cAliasNSRA)->RA_FILIAL != cFilOld
			cFilOld := (cAliasNSRA)->RA_FILIAL
			If !lMiddleware
				For nX := 1 To Len(aFilInTaf)
					If aScan( aFilInTaf[nX, 3], { |x| x == (cAliasNSRA)->RA_FILIAL } ) > 0
						cFilAnt := aFilInTaf[nX, 2]
						Exit
					EndIf
				Next nX
			Else
				cFilAnt := (cAliasNSRA)->RA_FILIAL
			EndIf
		EndIf
		IF (cAliasNSRA)->RA_CATEFD $ cTrabSemVinc
			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasNSRA)->RA_FILIAL } ) ) > 0 .And. cRaizFunc != SubStr(aSM0[nPosEmp, 18], 1, 8)
				(cAliasNSRA)->(dbSkip())
				Loop
			EndIf
			If !lMiddleware
				//Se n�o houver v�nculo, verifica se existe o S-2300
				cStat2  := TAFGetStat("S-2300", AllTrim( (cAliasNSRA)->RA_CIC ) + ";" + AllTrim( (cAliasNSRA)->RA_CATEFD ) + ";" + DTOS( (cAliasNSRA)->RA_ADMISSA),,(cAliasNSRA)->RA_FILIAL, Nil, AnoMes(dCompete), .T.)
			Else
				cCPF 	:= AllTrim( (cAliasNSRA)->RA_CIC ) + AllTrim( (cAliasNSRA)->RA_CATEFD ) + DTOS( (cAliasNSRA)->RA_ADMISSA )
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
				cStat2 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStat2 )

				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2399" + Padr(cCPF, 40, " ")
				cStatMid 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatMid )
				If cStatMid == "4" .And. !Empty((cAliasNSRA)->RA_DEMISSA) .And. AnoMes(dCompete) > AnoMes((cAliasNSRA)->RA_DEMISSA)
					cStat2 := "-2"
				EndIf
			EndIf
			//Se n�o houver o S-2300
			IF cStat2 == "-1" .Or. (!lMiddleware .And. cStat2 != "-1" .And. C9V->C9V_NOMEVE == "TAUTO") .Or. cStat2 == "-2" .Or.;
			 (!lMiddleware .And. (cStat2 != "-1" .And. cStat2 != "4") .And. !C9V->C9V_NOMEVE == "TAUTO")
				//Se a categoria est� contida em alguma de TSV e n�o existe registro desse cpf com categoria de v�nculo, dever� preencher o complemento.
				IF (AllTrim((cAliasNSRA)->RA_CATEFD ) $ cCatTSV)
					lComplTSV := .T.
				ENDIF
			Else
				lExiste2300 := .T.
				If (cAliasNSRA)->RA_FILIAL != cFilAnt
					lOutS2300 := .T.
				EndIf
			ENDIF

			IF !lAnytrbVnc .Or. Empty(aInfCompl)
				lCmplemTSV := .T.
			ENDIF
		ELSE
			lAnytrbVnc := .T.

			//Verifica se n�o existe S-2200
			If !lMiddleware
				IF TAFGetStat( "S-2200", AllTrim((cAliasNSRA)->(RA_CIC)) + ";" + ALLTRIM((cAliasNSRA)->(RA_CODUNIC)), Nil, Nil, Nil, AnoMes(dCompete), .T. ) $ "-1/-2"
					lCmplemTSV := .T.
				ENDIF
			Else
				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr((cAliasNSRA)->RA_CODUNIC, 40, " ")
				cStat2 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStat2 )

				cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2299" + Padr((cAliasNSRA)->RA_CODUNIC, 40, " ")
				cStatMid 	:= "-1"
				//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
				GetInfRJE( 2, cChaveMid, @cStatMid )
				If cStatMid == "4" .And. !Empty((cAliasNSRA)->RA_DEMISSA) .And. AnoMes(dCompete) > AnoMes((cAliasNSRA)->RA_DEMISSA)
					cStat2 := "-2"
				EndIf
				If cStat2 $ "-1/-2"
					lCmplemTSV := .T.
				EndIf
			EndIf

		ENDIF
		(cAliasNSRA)->(dbSkip())
	END

	(cAliasNSRA)->(dbCloseArea())

	//Se n�o existe S-2300 OU S-2200
	IF lComplTSV .AND. lCmplemTSV .AND. !lExiste2300
		lReturn :=  .T.
	EndIf

	cFilAnt := cBkpFil

return lReturn

/*/{Protheus.doc} fGrauExp
Fun��o que retorna valor para a tag <grauExp>
@author Allyson
@since 14/09/2018
@version 1.0
@return cCod  - C�digo de grau de exposi��o
/*/
Static Function fGrauExp()

Local cCod := "1"

If AllTrim(SRA->RA_OCORREN) $ "02#03#04#06#07#08"
	If AllTrim(SRA->RA_OCORREN) $ "02#06"
		cCod := "2"
	ElseIf AllTrim(SRA->RA_OCORREN) $ "03#07"
		cCod := "3"
	Else
		cCod := "4"
	EndIf
EndIf

Return cCod

//-------------------------------------------------------------------
/*/{Protheus.doc} fRetifAfas
Fun��o responspavel por buscar se houve retifica��o de afastamento
de licensa sa�de para acidente de trabalho
@author  Rafael Reis
@since   17/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function fRetifAfas(cFil, cMat, cCompete)
Local aArea	:= GetArea()
Local cAliasTmp		:= GetNextAlias()
Local cFilSR8		:= xFilial('SR8',cFil)
Local aReturn		:= {}

If __oSt15 == Nil
	__oSt15 := FWPreparedStatement():New()
	cQrySt := "SELECT R8_DATAINI, R8_DATAFIM , R8_DATALT, R8_DTER, R8_OBSAFAS "
	cQrySt += "FROM " + RetSqlName('SR8') + " SR8 "
	cQrySt += "WHERE R8_FILIAL = ? AND "
	cQrySt += 		"R8_MAT = ? AND "
	cQrySt += 		"SUBSTRING(R8_DATALT,1,6) = '" + Substr(cCompete,3,4) + Substr(cCompete,1,2) + "' AND "
	cQrySt += 		"SR8.D_E_L_E_T_ = ' ' "
	cQrySt := ChangeQuery(cQrySt)
	__oSt15:SetQuery(cQrySt)
EndIf
__oSt15:SetString(1, cFilSR8)
__oSt15:SetString(2, cMat)
cQrySt := __oSt15:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasTmp,.T.,.T.)

If (cAliasTmp)->(!Eof())
	aReturn := { SubStr((cAliasTmp)->R8_DATAINI,1,6), Substr((cAliasTmp)->R8_DATAFIM,1,6), (cAliasTmp)->R8_DATALT, (cAliasTmp)->R8_DTER, IF(Empty(Alltrim((cAliasTmp)->R8_OBSAFAS)), 'Convers�o de Licen�a Sa�de em Acidente de Trabalho', Alltrim((cAliasTmp)->R8_OBSAFAS) ) }
Endif
(cAliasTmp)->(dbCloseArea())

RestArea(aArea)
Return aReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} fBusAuxDoe
Fun��o respons�vel por buscar aux�lio doen�a (Verba ID 1420) pago a
funcion�rio em determinado intervalo
@author  Rafael Reis
@since   17/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function fBusAuxDoe(cFil, cMat, cCompPiso, cCompTeto, cCompete)
Local aArea	:= GetArea()
Local cAliasTmp		:= GetNextAlias()
Local cJoinRDxRV	:= FWJoinFilial( "SRD", "SRV" )
Local aReturn		:= {}
Local cCCAnt	 	:= ""
Local cCCRJ5	 	:= ""
Local lFilT 	 	:= .F.
Local aRH5Filt	 := {}

If lVerRJ5
	lFilT := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
	aRH5Filt := fRJ5Filt()
Endif

If __oSt16 == Nil
	__oSt16 := FWPreparedStatement():New()
	cQrySt := "SELECT SRD.RD_MAT, SUM(SRD.RD_VALOR) as RD_VALOR, SUM(SRD.RD_HORAS) AS RD_HORAS, SRD.RD_CC, SRD.RD_PERIODO "
	cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
	cQrySt += "JOIN " + RetSqlName('SRV') + " SRV ON " + cJoinRDxRV + " AND SRD.RD_PD = SRV.RV_COD "
	cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
	cQrySt += 		"SRD.RD_MAT = ? AND "
	cQrySt += 		"SRD.RD_PERIODO BETWEEN '" + cCompPiso + "' AND '" + cCompTeto + "' AND "
	cQrySt += 		"SRV.RV_CODFOL = '1420' AND "
	cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
	cQrySt += 		"SRV.D_E_L_E_T_ = ' ' "
	cQrySt += "GROUP BY SRD.RD_MAT, SRD.RD_CC, SRD.RD_PERIODO"
	cQrySt := ChangeQuery(cQrySt)
	__oSt16:SetQuery(cQrySt)
EndIf
__oSt16:SetString(1, cFil)
__oSt16:SetString(2, cMat)
cQrySt := __oSt16:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasTmp,.T.,.T.)

While (cAliasTmp)->(!EoF())
	If lVerRJ5
		If cCCAnt != (cAliasTmp)->RD_CC
			cCCAnt := (cAliasTmp)->RD_CC
			cCCRJ5 := ""
			If !lFilT
				RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
				If RJ5->( dbSeek( xFilial("RJ5", cFil) + (cAliasTmp)->RD_CC) )
					While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_CC == (cAliasTmp)->RD_CC
						If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
							cCCRJ5 := RJ5->RJ5_COD
						EndIf
						RJ5->( dbSkip() )
					EndDo
				EndIf
			Else
				RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
				RJ5->(dbGotop())
				If Len(aRH5Filt) > 0
					If RJ5->( dbSeek( xFilial("RJ5", cFil) + (cAliasTmp)->RD_CC + cFil)  )
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_CC == (cAliasTmp)->RD_CC .And.;
							IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == cFil, .T.)
							If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
								cCCRJ5 := RJ5->RJ5_COD
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
				Endif
				If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
					If RJ5->( dbSeek( xFilial("RJ5", cFil) + (cAliasTmp)->RD_CC )  )
						While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5",cFil) .And. RJ5->RJ5_CC == (cAliasTmp)->RD_CC .And.;
							IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == cFil, .T.)
							If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
								cCCRJ5 := RJ5->RJ5_COD
							EndIf
							RJ5->( dbSkip() )
						EndDo
					EndIf
				Endif
			Endif
		EndIf
	ElseIf !lGeraRat
		cCCRJ5 := SRA->RA_CC
	Else
		cCCRJ5 := (cAliasTmp)->RD_CC
	EndIf

	Aadd(aReturn, { (cAliasTmp)->RD_VALOR, (cAliasTmp)->RD_HORAS, cCCRJ5, (cAliasTmp)->RD_PERIODO, (cAliasTmp)->RD_CC })
	(cAliasTmp)->(DbSkip())
End
(cAliasTmp)->(DbCloseArea())

RestArea(aArea)
Return aReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} fEstabELot
Fun��o respons�vel por buscar identifca��o do estabelecimento e
lota��o, retornando nos par�metros passados por refer�ncia ( cTpInscr
, cInscr e codLotacao)
@author  Rafael Reis
@since   17/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function fEstabELot(cFil, cCentroC, cTpInscr, cInscr, codLotacao, cCCOrig, cCompete, cChaveS1005)
	Local cFilLocCTT := FWxFilial("CTT", cFil)
	Local cFilLocRJ5 := ""
	Local cFilTrb	 := ""
	Local nPosLot 	 := 0
	Local nPosEstb 	 := 0
	Local cCEIObra 	 := ""
	Local cCAEPF 	 := ""

	//Vari�veis private aEstb e aCC declaradas no in�cio da Faz1200

	If !lVerRJ5
		If !Empty(cCentroC) .AND. Len(aCC) > 0
			nPosLot := aScan(aCC,{|x| x[1] == cFilLocCTT .AND. x[2] == cCentroC })
			If nPosLot > 0
				//CTT->CTT_TPLOT == "01" .And. CTT->CTT_TIPO2 == "4" .And. CTT->CTT_CLASSE == "2"
				If aCC[nPosLot,6] == "01" .And. aCC[nPosLot,3] == "4" .And. aCC[nPosLot,8] == "2"
					cTpInscr	:= aCC[nPosLot,3]
					cInscr		:= aCC[nPosLot,4]
					cChaveS1005	:= xFilial("CTT", SRA->RA_FILIAL)+cInscr
				EndIf
			EndIf
		Endif
	Else
		RJ5->( dbSetOrder(5) )//RJ5_FILIAL+RJ5_COD+RJ5_CC+RJ5_INI
		If RJ5->( dbSeek( xFilial("RJ5", cFil) + cCentroC + cCCOrig ) )
			While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", cFil) .And. RJ5->RJ5_COD == cCentroC .And. RJ5->RJ5_CC == cCCOrig
				If SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2) >= RJ5->RJ5_INI
					cTpInscr	:= RJ5->RJ5_TPIO
					cInscr  	:= RJ5->RJ5_NIO
					cChaveS1005	:= xFilial("RJ5", SRA->RA_FILIAL)+cInscr
				EndIf
				RJ5->( dbSkip() )
			EndDo
		EndIf
	EndIf

	If Empty(cTpInscr) .OR. Empty(cInscr)
		If fBuscaOBRA( cFil, @cCEIObra )
			cTpInscr 	:= "4" // Tipo da inscricao (1CNPJ/2CPF/3CAEPF/4CNO)
			cInscr 	 	:= cCEIObra // Codigo da inscricao
			cChaveS1005	:= SRA->RA_FILIAL+cInscr
		Elseif fBuscaCAEPF( cFil, @cCAEPF )
			cTpInscr := "3"
			cInscr	 := cCAEPF
			cChaveS1005	:= SRA->RA_FILIAL+cInscr
		Else
			nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(cFil)})
			If nPosEstb > 0
				cTpInscr	:= aEstb[nPosEstb,3]
				cInscr		:= aEstb[nPosEstb,2]
				cChaveS1005	:= SRA->RA_FILIAL+cInscr
			EndIf
		EndIf
	Endif

	cCentroC := StrTran(cCentroC, "&", "&amp;")

	If !lVerRJ5
		cFilTrb		:= cFilLocCTT
	Else
		cFilLocRJ5 	:= FWxFilial("RJ5", cFil)
		cFilTrb		:= cFilLocRJ5
	EndIf

	If  lMiddleware .Or. !Empty(cFilTrb)
		codLotacao := cFilTrb + cCentroC
	Else
		codLotacao	:= cCentroC
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOpcoes
Fun��o respons�vel por validar o status do evento com as op��es
de gera��o selecionadas
@author  Rafael Reis
@since   05/11/2018
@params
aCheck - Array com op��es selecionadas (GPEM034)
cStatus - Status a ser validado
@return
0 - Nenhum problema encontrado.
1 - Registro n�o foi sobrescrito.
2 - Registro n�o foi retificado.
3 - Desprezado pois est� aguardando retorno do governo.
@version 1
/*/
//-------------------------------------------------------------------
Function fVldOpcoes(aCheck,cStatus)
Local lCheck06 := aCheck[6]//Sobrescrever status branco ou 0 (n�o validados ou n�o transmitidos)
Local lCheck07 := aCheck[7]//Sobrescrever status 1 (inconsist�ncia encontrada pelo TAF)
Local lCheck08 := aCheck[8]//Sobrescrever status 3 (inconsist�ncia encontrada pelo RET)
Local lCheck09 := aCheck[9]//Sobrescrever status 7 (exclu�do com sucesso no RET)
Local lCheck10 := aCheck[10]//Retificar status 4 (trasmitido e retornado pelo RET)
Local lReturn  := 0

If cStatus $ " /0/1/3/7"
	If !(cStatus $ " /0" .And. lCheck06 .Or. cStatus $ "1" .And. Iif(!lMiddleware, lCheck07, lCheck06) .Or. cStatus $ "3" .And. lCheck08 .Or. cStatus $ "7" .And. lCheck09)
		lReturn := 1
	EndIf
ElseIf cStatus $ "4"
	If !lCheck10
		lReturn := 2
	EndIf
ElseIf cStatus $ "2/6"
	lReturn := 3
EndIf

Return lReturn

/*/{Protheus.doc} fOptSimp()
Fun��o respons�vel por verificar se a filial � optante pelo Simples atrav�s de consulta a tabela S037
@type function
@author allyson.mesashi
@since 10/01/2019
@version 1.0
@param cFilFun		= Filial a ser pesquisada
@param cCompete 	= Competencia ser pesquisada
@return cSimples, Caracter, 1=Optante do simples;2=N�o optante
/*/
Static Function fOptSimp(cFilFun, cCompete)

Local cSimples	:= ""
Local dDataRef  := cToD( "01/" + SubStr( cCompete, 1, 2 ) + "/" + SubStr( cCompete, 3, 4 ) )
Local lAchou	:= .F.
Local nPosTab	:= 0

If Empty(aTabS037)
	fCarrTab( @aTabS037, "S037", dDataRef, .T. )
EndIf

//--Verifica se Existe a Tabela Cadastrada
If ( nPosTab := Ascan(aTabS037,{ |x| x[2] == cFilFun .And. x[3] == MesAno(dDataRef) })) > 0
	lAchou := .T.
ElseIf ( nPosTab := Ascan(aTabS037,{ |x| x[2] == Space(FwGetTamFilial).And. x[3] == MesAno(dDataRef) })) > 0
	lAchou := .T.
Elseif ( nPosTab := Ascan(aTabS037,{ |x| x[2] == cFilFun .And. x[3] == Space(6) })) > 0
	lAchou := .T.
Elseif ( nPosTab := Ascan(aTabS037,{ |x| x[2] == Space(FwGetTamFilial) .And. x[3] == Space(6) })) > 0
	lAchou := .T.
EndIf

If lAchou
	cSimples := aTabS037[nPosTab, 11]
EndIf

Return cSimples

/*/{Protheus.doc} fCriaTmp()
Fun��o que aglutina as verbas do alias cSRDAUT para o alias cSRDAlias
@type function
@author allyson.mesashi
@since 17/01/2019
@version 1.0
@param cSRDAlias	= Alias da tabela tempor�ria principal
@param cSRDAut		= Alias da tabela tempor�ria auxiliar
/*/
Static Function fCriaTmp(cSRDAlias, cSRDAut)
Local aColumns	 := {}
Local lNovo		 := .F.

aAdd( aColumns, { "RD_FILIAL"	,"C",FwGetTamFilial,0 })
aAdd( aColumns, { "RD_MAT"		,"C",nTamMat,0})
aAdd( aColumns, { "RD_DATARQ"	,"C",6,0})
aAdd( aColumns, { "RD_CC"		,"C",nTamCC,})
aAdd( aColumns, { "RD_PD"		,"C",nTamVb,0})
aAdd( aColumns, { "RD_PERIODO"	,"C",6,0})
aAdd( aColumns, { "RD_ROTEIR"	,"C",nTamRot,0})
aAdd( aColumns, { "RD_HORAS"	,"N",nTamHor,nDecHor})
aAdd( aColumns, { "RD_VALOR"	,"N",nTamVal,nDecVal})
aAdd( aColumns, { "RD_DATPGT"	,"C",8,0})
aAdd( aColumns, { "RECNO"		,"N",200,0})
aAdd( aColumns, { "TAB"			,"C",3,0})
aAdd( aColumns, { "RD_SEMANA"	, "C", 2, 0})

oTmpTable := FWTemporaryTable():New(cSRDAlias)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR" } )
oTmpTable:Create()

While (cSRDAut)->(!Eof())
	lNovo	:= (cSRDAlias)->( !dbSeek( (cSRDAut)->RD_FILIAL+(cSRDAut)->RD_MAT+(cSRDAut)->RD_PERIODO+(cSRDAut)->RD_CC+(cSRDAut)->RD_PD+(cSRDAut)->RD_ROTEIR ) )
	If RecLock(cSRDAlias, lNovo)
		If lNovo
			(cSRDAlias)->RD_FILIAL 	:= (cSRDAut)->RD_FILIAL
			(cSRDAlias)->RD_MAT 	:= (cSRDAut)->RD_MAT
			(cSRDAlias)->RD_DATARQ 	:= (cSRDAut)->RD_DATARQ
			(cSRDAlias)->RD_CC		:= (cSRDAut)->RD_CC
			(cSRDAlias)->RD_PD		:= (cSRDAut)->RD_PD
			(cSRDAlias)->RD_PERIODO	:= (cSRDAut)->RD_PERIODO
			(cSRDAlias)->RD_ROTEIR	:= (cSRDAut)->RD_ROTEIR
			(cSRDAlias)->RD_DATPGT	:= (cSRDAut)->RD_DATPGT
			(cSRDAlias)->RECNO		:= (cSRDAut)->RECNO
			(cSRDAlias)->TAB		:= (cSRDAut)->TAB
			(cSRDAlias)->RD_SEMANA	:= (cSRDAut)->RD_SEMANA
		EndIf
		(cSRDAlias)->RD_HORAS	+= (cSRDAut)->RD_HORAS
		(cSRDAlias)->RD_VALOR	+= (cSRDAut)->RD_VALOR

		(cSRDAlias)->(MsUnLock())
	EndIf
	(cSRDAut)->(DbSkip())
EndDo

(cSRDAut)->( dbCloseArea() )
(cSRDAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fVerRJ5A()
Fun��o que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca � efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
in�cio de validade diferente, o que impossibilita o "Inner Join" na query dos lan�amentos
@type function
@author allyson.mesashi
@since 03/04/2019
@version 1.0
@param cSRDAlias	= Alias da tabela tempor�ria principal
@param cSRDRJ5		= Alias da tabela tempor�ria auxiliar
@param cPeriod		= Per�odo para verifica��o da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que n�o foram encontrados
/*/
Static Function fVerRJ5A(cSRDAlias, cSRDRJ5, cPeriod, lRJ5Ok, aErrosRJ5)
	Local aColumns	 := {}
	Local cKeyAux	 := ""
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local lNovo		 := .F.
	Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
	Local aRH5Filt	 := {}

	aAdd( aColumns, { "RD_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RD_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RD_DATARQ"	,"C",6,0})
	aAdd( aColumns, { "RD_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RD_PD"		,"C",nTamVb,0})
	aAdd( aColumns, { "RD_PERIODO"	,"C",6,0})
	aAdd( aColumns, { "RD_ROTEIR"	,"C",nTamRot,0})
	aAdd( aColumns, { "RD_HORAS"	,"N",nTamHor,nDecHor})
	aAdd( aColumns, { "RD_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RD_DATPGT"	,"C",8,0})
	aAdd( aColumns, { "RECNO"		,"N",200,0})
	aAdd( aColumns, { "TAB"			,"C",3,0})
	aAdd( aColumns, { "RD_CCBKP"	,"C",nTamCC,0})
	If !lDtPgto
		aAdd( aColumns, { "RD_SEMANA"	,"C",nTamSem,0})
	EndIf

	//Cria uma tabela tempor�ria auxiliar
	oTmpTabRJ := FWTemporaryTable():New(cSRDRJ5)
	oTmpTabRJ:SetFields( aColumns )
	If !lDtPgto
		oTmpTabRJ:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_SEMANA" } )
	Else
		oTmpTabRJ:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR" } )
	EndIf
	oTmpTabRJ:Create()

	If lFilT
		aRH5Filt := fRJ5Filt()
	Endif
	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela tempor�ria auxiliar
	While (cSRDAlias)->(!Eof())
		lNovo	:= (cSRDRJ5)->( !dbSeek( (cSRDAlias)->RD_FILIAL+(cSRDAlias)->RD_MAT+(cSRDAlias)->RD_PERIODO+(cSRDAlias)->RD_CC+(cSRDAlias)->RD_PD+(cSRDAlias)->RD_ROTEIR ) )
		If RecLock(cSRDRJ5, lNovo)
			If lNovo
				(cSRDRJ5)->RD_FILIAL 	:= (cSRDAlias)->RD_FILIAL
				(cSRDRJ5)->RD_MAT 		:= (cSRDAlias)->RD_MAT
				(cSRDRJ5)->RD_DATARQ 	:= (cSRDAlias)->RD_DATARQ

				If cCCAnt != (cSRDAlias)->RD_CC
					cCCAnt := (cSRDAlias)->RD_CC
					cCCRJ5 := ""
					If !lFilT
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_CC) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRDAlias)->RD_FILIAL) .And. RJ5->RJ5_CC == (cSRDAlias)->RD_CC
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					Else   //Controle de Lota��es com tabelas compartilhadas e campo RJ5_FILT com a Filial do Funcionario
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						RJ5->(dbGotop())
						If Len(aRH5Filt) > 0
							If RJ5->( dbSeek( xFilial("RJ5", (cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_CC + (cSRDAlias)->RD_FILIAL)  )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRDAlias)->RD_FILIAL) .And. RJ5->RJ5_CC == (cSRDAlias)->RD_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cSRDAlias)->RD_FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						Endif
						If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
							If RJ5->( dbSeek( xFilial("RJ5", (cSRDAlias)->RD_FILIAL) + (cSRDAlias)->RD_CC )  )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cSRDAlias)->RD_FILIAL) .And. RJ5->RJ5_CC == (cSRDAlias)->RD_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cSRDAlias)->RD_FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						Endif
					Endif

					If Empty(cCCRJ5)
						lRJ5Ok 	:= .F.
						If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
							aAdd( aErrosRJ5, cCCAnt )
						EndIf
					EndIf
				EndIf

				(cSRDRJ5)->RD_CC 		:= cCCRJ5
				(cSRDRJ5)->RD_PD		:= (cSRDAlias)->RD_PD
				(cSRDRJ5)->RD_PERIODO	:= (cSRDAlias)->RD_PERIODO
				(cSRDRJ5)->RD_ROTEIR	:= (cSRDAlias)->RD_ROTEIR
				(cSRDRJ5)->RD_DATPGT	:= (cSRDAlias)->RD_DATPGT
				(cSRDRJ5)->RECNO		:= (cSRDAlias)->RECNO
				(cSRDRJ5)->TAB			:= (cSRDAlias)->TAB
				(cSRDRJ5)->RD_CCBKP		:= cCCAnt
				If !lDtPgto
					(cSRDRJ5)->RD_SEMANA := (cSRDAlias)->RD_SEMANA
				EndIf
			EndIf
			(cSRDRJ5)->RD_HORAS		+= (cSRDAlias)->RD_HORAS
			(cSRDRJ5)->RD_VALOR		+= (cSRDAlias)->RD_VALOR

			(cSRDRJ5)->(MsUnlock())
		EndIf
		(cSRDAlias)->(DbSkip())
	EndDo

	(cSRDAlias)->( dbCloseArea() )
	(cSRDRJ5)->( dbGoTop() )

	//Cria uma tabela tempor�ria com o mesmo alias da query da SRD/SRC
	oTmpTable := FWTemporaryTable():New(cSRDAlias)
	oTmpTable:SetFields( aColumns )
	If !lDtPgto
		oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_SEMANA" } )
	Else
		oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR" } )
	EndIf
	oTmpTable:Create()

	//Percorre a tabela tempor�rio auxiliar gravando o resultado na tabela tempor�ria com o mesmo alias da query da SRD/SRC
	While (cSRDRJ5)->(!Eof())
		lNovo	:= (cSRDAlias)->( !dbSeek( (cSRDRJ5)->RD_FILIAL+(cSRDRJ5)->RD_MAT+(cSRDRJ5)->RD_PERIODO+(cSRDRJ5)->RD_CC+(cSRDRJ5)->RD_PD+(cSRDRJ5)->RD_ROTEIR ) )
		If RecLock(cSRDAlias, lNovo)
			If lNovo
				(cSRDAlias)->RD_FILIAL 	:= (cSRDRJ5)->RD_FILIAL
				(cSRDAlias)->RD_MAT 	:= (cSRDRJ5)->RD_MAT
				(cSRDAlias)->RD_DATARQ 	:= (cSRDRJ5)->RD_DATARQ
				(cSRDAlias)->RD_CC		:= (cSRDRJ5)->RD_CC
				(cSRDAlias)->RD_PD		:= (cSRDRJ5)->RD_PD
				(cSRDAlias)->RD_PERIODO	:= (cSRDRJ5)->RD_PERIODO
				(cSRDAlias)->RD_ROTEIR	:= (cSRDRJ5)->RD_ROTEIR
				(cSRDAlias)->RD_DATPGT	:= (cSRDRJ5)->RD_DATPGT
				(cSRDAlias)->RECNO		:= (cSRDRJ5)->RECNO
				(cSRDAlias)->TAB		:= (cSRDRJ5)->TAB
				(cSRDAlias)->RD_CCBKP	:= (cSRDRJ5)->RD_CCBKP
				If !lDtPgto
					(cSRDAlias)->RD_SEMANA	:= (cSRDRJ5)->RD_SEMANA
				EndIf
			EndIf
			(cSRDAlias)->RD_HORAS	+= (cSRDRJ5)->RD_HORAS
			(cSRDAlias)->RD_VALOR	+= (cSRDRJ5)->RD_VALOR

			(cSRDAlias)->(MsUnlock())
		EndIf
		(cSRDRJ5)->(DbSkip())
	EndDo

	(cSRDAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fVerRJ5B()
Fun��o que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca � efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
in�cio de validade diferente, o que impossibilita o "Inner Join" na query dos lan�amentos
@type function
@author allyson.mesashi
@since 03/04/2019
@version 1.0
@param cRHHAlias	= Alias da tabela tempor�ria principal
@param cRHHRJ5		= Alias da tabela tempor�ria auxiliar
@param cPeriod		= Per�odo para verifica��o da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que n�o foram encontrados
/*/
Static Function fVerRJ5B(cRHHAlias, cRHHRJ5, cPeriod, lRJ5Ok, aErrosRJ5)
	Local aColumns	 := {}
	Local cKeyAux	 := ""
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local lNovo		 := .F.
	Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
	Local aRH5Filt	 := {}

	aAdd( aColumns, { "RHH_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RHH_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RHH_MESANO"	,"C",6,0})
	aAdd( aColumns, { "RHH_DATA"	,"C",6,})
	aAdd( aColumns, { "RHH_VB"		,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RHH_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RHH_CCBKP"	,"C",nTamCC,0})

	//Cria uma tabela tempor�ria auxiliar
	oTmpTabRH := FWTemporaryTable():New(cRHHRJ5)
	oTmpTabRH:SetFields( aColumns )
	oTmpTabRH:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabRH:Create()

	If lFilT
		aRH5Filt := fRJ5Filt()
	Endif

	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela tempor�ria auxiliar
	While (cRHHAlias)->(!Eof())
		lNovo	:= (cRHHRJ5)->( !dbSeek( (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO+(cRHHAlias)->RHH_DATA+(cRHHAlias)->RHH_CC+(cRHHAlias)->RHH_VB ) )
		If RecLock(cRHHRJ5, lNovo)
			If lNovo
				(cRHHRJ5)->RHH_FILIAL 	:= (cRHHAlias)->RHH_FILIAL
				(cRHHRJ5)->RHH_MAT 		:= (cRHHAlias)->RHH_MAT
				(cRHHRJ5)->RHH_MESANO 	:= (cRHHAlias)->RHH_MESANO
				(cRHHRJ5)->RHH_DATA 	:= (cRHHAlias)->RHH_DATA
				(cRHHRJ5)->RHH_VB 		:= (cRHHAlias)->RHH_VB

				If cCCAnt != (cRHHAlias)->RHH_CC
					cCCAnt := (cRHHAlias)->RHH_CC
					cCCRJ5 := ""

					If !lFilT
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
						EndIf
					Else //Controle de Lota��es com tabelas compartilhadas e campo RJ5_FILT com a Filial do Funcionario
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						RJ5->(dbGotop())
						If Len(aRH5Filt) > 0
							If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC + (cRHHAlias)->RHH_FILIAL)  )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cRHHAlias)->RHH_FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							EndIf
						Endif
						If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
							If RJ5->( dbSeek( xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) + (cRHHAlias)->RHH_CC) )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRHHAlias)->RHH_FILIAL) .And. RJ5->RJ5_CC == (cRHHAlias)->RHH_CC .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cRHHAlias)->RHH_FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
							Endif
						Endif
					Endif

					If Empty(cCCRJ5)
						lRJ5Ok 	:= .F.
						If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
							aAdd( aErrosRJ5, cCCAnt )
						EndIf
					EndIf
				EndIf

				(cRHHRJ5)->RHH_CC 		:= cCCRJ5
				(cRHHRJ5)->RHH_CCBKP	:= cCCAnt
			EndIf
			(cRHHRJ5)->RHH_VALOR	+= (cRHHAlias)->RHH_VALOR

			(cRHHRJ5)->(MsUnlock())
		EndIf
		(cRHHAlias)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbCloseArea() )
	(cRHHRJ5)->( dbGoTop() )

	//Cria uma tabela tempor�ria com o mesmo alias da query da SRD/SRC
	oTmpTabl2 := FWTemporaryTable():New(cRHHAlias)
	oTmpTabl2:SetFields( aColumns )
	oTmpTabl2:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabl2:Create()

	//Percorre a tabela tempor�rio auxiliar gravando o resultado na tabela tempor�ria com o mesmo alias da query da SRD/SRC
	While (cRHHRJ5)->(!Eof())
		lNovo	:= (cRHHAlias)->( !dbSeek( (cRHHRJ5)->RHH_FILIAL+(cRHHRJ5)->RHH_MAT+(cRHHRJ5)->RHH_MESANO+(cRHHRJ5)->RHH_DATA+(cRHHRJ5)->RHH_CC+(cRHHRJ5)->RHH_VB ) )
		If RecLock(cRHHAlias, lNovo)
			If lNovo
				(cRHHAlias)->RHH_FILIAL := (cRHHRJ5)->RHH_FILIAL
				(cRHHAlias)->RHH_MAT 	:= (cRHHRJ5)->RHH_MAT
				(cRHHAlias)->RHH_MESANO := (cRHHRJ5)->RHH_MESANO
				(cRHHAlias)->RHH_DATA	:= (cRHHRJ5)->RHH_DATA
				(cRHHAlias)->RHH_VB		:= (cRHHRJ5)->RHH_VB
				(cRHHAlias)->RHH_CC		:= (cRHHRJ5)->RHH_CC
				(cRHHAlias)->RHH_CCBKP	:= (cRHHRJ5)->RHH_CCBKP
			EndIf
			(cRHHAlias)->RHH_VALOR	+= (cRHHRJ5)->RHH_VALOR

			(cRHHAlias)->(MsUnlock())
		EndIf
		(cRHHRJ5)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fGerRatA()
Fun��o que substitui o centro de custo do movimento pelo centro de custo do cadastro
@type function
@author allyson.mesashi
@since 25/07/2019
@version 1.0
@param cSRDAlias	= Alias da tabela tempor�ria principal
@param cSRDRJ5		= Alias da tabela tempor�ria auxiliar
@param cPeriod		= Per�odo para verifica��o da validade
/*/
Static Function fGerRatA(cSRDAlias, cSRDRJ5, cPeriod)
	Local aColumns	 := {}
	Local cCCAnt	 := ""
	Local cCCRA	 	 := ""
	Local lNovo		 := .F.

	aAdd( aColumns, { "RD_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RD_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RD_DATARQ"	,"C",6,0})
	aAdd( aColumns, { "RD_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RD_PD"		,"C",nTamVb,0})
	aAdd( aColumns, { "RD_PERIODO"	,"C",6,0})
	aAdd( aColumns, { "RD_ROTEIR"	,"C",nTamRot,0})
	aAdd( aColumns, { "RD_HORAS"	,"N",nTamHor,nDecHor})
	aAdd( aColumns, { "RD_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RD_DATPGT"	,"C",8,0})
	aAdd( aColumns, { "RECNO"		,"N",200,0})
	aAdd( aColumns, { "TAB"			,"C",3,0})
	aAdd( aColumns, { "RD_CCBKP"	,"C",nTamCC,0})
	If !lDtPgto
		aAdd( aColumns, { "RD_SEMANA"	,"C",nTamSem,0})
	EndIf
	aAdd( aColumns, { "RD_NUMID"	,"C",nTamNumId,0})

	//Cria uma tabela tempor�ria auxiliar
	oTmpTabRJ := FWTemporaryTable():New(cSRDRJ5)
	oTmpTabRJ:SetFields( aColumns )
	If !lDtPgto
		oTmpTabRJ:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_SEMANA", "RD_NUMID" } )
	Else
		oTmpTabRJ:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_NUMID" } )
	EndIf
	oTmpTabRJ:Create()

	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela tempor�ria auxiliar
	While (cSRDAlias)->(!Eof())
		lNovo	:= (cSRDRJ5)->( !dbSeek( (cSRDAlias)->RD_FILIAL+(cSRDAlias)->RD_MAT+(cSRDAlias)->RD_PERIODO+(cSRDAlias)->RD_CC+(cSRDAlias)->RD_PD+(cSRDAlias)->RD_ROTEIR+(cSRDAlias)->RD_NUMID ) )
		If RecLock(cSRDRJ5, lNovo)
			If lNovo
				(cSRDRJ5)->RD_FILIAL 	:= (cSRDAlias)->RD_FILIAL
				(cSRDRJ5)->RD_MAT 		:= (cSRDAlias)->RD_MAT
				(cSRDRJ5)->RD_DATARQ 	:= (cSRDAlias)->RD_DATARQ

				If cCCAnt != (cSRDAlias)->RD_CC
					cCCAnt := (cSRDAlias)->RD_CC
					cCCRA  := SRA->RA_CC
				EndIf

				(cSRDRJ5)->RD_CC 		:= cCCRA
				(cSRDRJ5)->RD_PD		:= (cSRDAlias)->RD_PD
				(cSRDRJ5)->RD_PERIODO	:= (cSRDAlias)->RD_PERIODO
				(cSRDRJ5)->RD_ROTEIR	:= (cSRDAlias)->RD_ROTEIR
				(cSRDRJ5)->RD_DATPGT	:= (cSRDAlias)->RD_DATPGT
				(cSRDRJ5)->RECNO		:= (cSRDAlias)->RECNO
				(cSRDRJ5)->TAB			:= (cSRDAlias)->TAB
				(cSRDRJ5)->RD_CCBKP		:= cCCAnt
				If !lDtPgto
					(cSRDRJ5)->RD_SEMANA := (cSRDAlias)->RD_SEMANA
				EndIf
				(cSRDRJ5)->RD_NUMID		:= (cSRDAlias)->RD_NUMID
			EndIf
			(cSRDRJ5)->RD_HORAS		+= (cSRDAlias)->RD_HORAS
			(cSRDRJ5)->RD_VALOR		+= (cSRDAlias)->RD_VALOR

			(cSRDRJ5)->(MsUnlock())
		EndIf
		(cSRDAlias)->(DbSkip())
	EndDo

	(cSRDAlias)->( dbCloseArea() )
	(cSRDRJ5)->( dbGoTop() )

	//Cria uma tabela tempor�ria com o mesmo alias da query da SRD/SRC
	oTmpTable := FWTemporaryTable():New(cSRDAlias)
	oTmpTable:SetFields( aColumns )
	If !lDtPgto
		oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_SEMANA", "RD_NUMID" } )
	Else
		oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR", "RD_NUMID" } )
	EndIf
	oTmpTable:Create()

	//Percorre a tabela tempor�rio auxiliar gravando o resultado na tabela tempor�ria com o mesmo alias da query da SRD/SRC
	While (cSRDRJ5)->(!Eof())
		lNovo	:= (cSRDAlias)->( !dbSeek( (cSRDRJ5)->RD_FILIAL+(cSRDRJ5)->RD_MAT+(cSRDRJ5)->RD_PERIODO+(cSRDRJ5)->RD_CC+(cSRDRJ5)->RD_PD+(cSRDRJ5)->RD_ROTEIR+(cSRDRJ5)->RD_NUMID ) )
		If RecLock(cSRDAlias, lNovo)
			If lNovo
				(cSRDAlias)->RD_FILIAL 	:= (cSRDRJ5)->RD_FILIAL
				(cSRDAlias)->RD_MAT 	:= (cSRDRJ5)->RD_MAT
				(cSRDAlias)->RD_DATARQ 	:= (cSRDRJ5)->RD_DATARQ
				(cSRDAlias)->RD_CC		:= (cSRDRJ5)->RD_CC
				(cSRDAlias)->RD_PD		:= (cSRDRJ5)->RD_PD
				(cSRDAlias)->RD_PERIODO	:= (cSRDRJ5)->RD_PERIODO
				(cSRDAlias)->RD_ROTEIR	:= (cSRDRJ5)->RD_ROTEIR
				(cSRDAlias)->RD_DATPGT	:= (cSRDRJ5)->RD_DATPGT
				(cSRDAlias)->RECNO		:= (cSRDRJ5)->RECNO
				(cSRDAlias)->TAB		:= (cSRDRJ5)->TAB
				(cSRDAlias)->RD_CCBKP	:= (cSRDRJ5)->RD_CCBKP
				If !lDtPgto
					(cSRDAlias)->RD_SEMANA	:= (cSRDRJ5)->RD_SEMANA
				EndIf
				(cSRDAlias)->RD_NUMID	:= (cSRDRJ5)->RD_NUMID
			EndIf
			(cSRDAlias)->RD_HORAS	+= (cSRDRJ5)->RD_HORAS
			(cSRDAlias)->RD_VALOR	+= (cSRDRJ5)->RD_VALOR

			(cSRDAlias)->(MsUnlock())
		EndIf
		(cSRDRJ5)->(DbSkip())
	EndDo

	(cSRDAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fGerRatB()
Fun��o que substitui o centro de custo do movimento pelo centro de custo do cadastro
@type function
@author allyson.mesashi
@since 25/07/2019
@version 1.0
@param cRHHAlias	= Alias da tabela tempor�ria principal
@param cRHHRJ5		= Alias da tabela tempor�ria auxiliar
@param cPeriod		= Per�odo para verifica��o da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que n�o foram encontrados
/*/
Function fGerRatB(cRHHAlias, cRHHRJ5, cPeriod)

	Local aColumns	 := {}
	Local cCCAnt	 := ""
	Local cCCRA	 	 := ""
	Local lNovo		 := .F.

	aAdd( aColumns, { "RHH_FILIAL"	,"C",FwGetTamFilial,0 })
	aAdd( aColumns, { "RHH_MAT"		,"C",nTamMat,0})
	aAdd( aColumns, { "RHH_MESANO"	,"C",6,0})
	aAdd( aColumns, { "RHH_DATA"	,"C",6,})
	aAdd( aColumns, { "RHH_VB"		,"C",nTamVb,0})
	aAdd( aColumns, { "RHH_CC"		,"C",nTamCC,0})
	aAdd( aColumns, { "RHH_VALOR"	,"N",nTamVal,nDecVal})
	aAdd( aColumns, { "RHH_CCBKP"	,"C",nTamCC,0})

	//Cria uma tabela tempor�ria auxiliar
	oTmpTabRH := FWTemporaryTable():New(cRHHRJ5)
	oTmpTabRH:SetFields( aColumns )
	oTmpTabRH:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabRH:Create()

	//Percorre o resultado da query da SRD/SRC e verifica o relacionamento na RJ5, efetuando troca do RD_CC por RJ5_COD
	//gravando o resultado na tabela tempor�ria auxiliar
	While (cRHHAlias)->(!Eof())
		lNovo	:= (cRHHRJ5)->( !dbSeek( (cRHHAlias)->RHH_FILIAL+(cRHHAlias)->RHH_MAT+(cRHHAlias)->RHH_MESANO+(cRHHAlias)->RHH_DATA+(cRHHAlias)->RHH_CC+(cRHHAlias)->RHH_VB ) )
		If RecLock(cRHHRJ5, lNovo)
			If lNovo
				(cRHHRJ5)->RHH_FILIAL 	:= (cRHHAlias)->RHH_FILIAL
				(cRHHRJ5)->RHH_MAT 		:= (cRHHAlias)->RHH_MAT
				(cRHHRJ5)->RHH_MESANO 	:= (cRHHAlias)->RHH_MESANO
				(cRHHRJ5)->RHH_DATA 	:= (cRHHAlias)->RHH_DATA
				(cRHHRJ5)->RHH_VB 		:= (cRHHAlias)->RHH_VB

				If cCCAnt != (cRHHAlias)->RHH_CC
					cCCAnt := (cRHHAlias)->RHH_CC
					cCCRA  := SRA->RA_CC
				EndIf

				(cRHHRJ5)->RHH_CC 		:= cCCRA
				(cRHHRJ5)->RHH_CCBKP	:= cCCAnt
			EndIf
			(cRHHRJ5)->RHH_VALOR	+= (cRHHAlias)->RHH_VALOR

			(cRHHRJ5)->(MsUnlock())
		EndIf
		(cRHHAlias)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbCloseArea() )
	(cRHHRJ5)->( dbGoTop() )

	//Cria uma tabela tempor�ria com o mesmo alias da query da SRD/SRC
	oTmpTabl2 := FWTemporaryTable():New(cRHHAlias)
	oTmpTabl2:SetFields( aColumns )
	oTmpTabl2:AddIndex( "IND", { "RHH_FILIAL", "RHH_MAT", "RHH_MESANO", "RHH_DATA", "RHH_CC", "RHH_VB" } )
	oTmpTabl2:Create()

	//Percorre a tabela tempor�rio auxiliar gravando o resultado na tabela tempor�ria com o mesmo alias da query da SRD/SRC
	While (cRHHRJ5)->(!Eof())
		lNovo	:= (cRHHAlias)->( !dbSeek( (cRHHRJ5)->RHH_FILIAL+(cRHHRJ5)->RHH_MAT+(cRHHRJ5)->RHH_MESANO+(cRHHRJ5)->RHH_DATA+(cRHHRJ5)->RHH_CC+(cRHHRJ5)->RHH_VB ) )
		If RecLock(cRHHAlias, lNovo)
			If lNovo
				(cRHHAlias)->RHH_FILIAL := (cRHHRJ5)->RHH_FILIAL
				(cRHHAlias)->RHH_MAT 	:= (cRHHRJ5)->RHH_MAT
				(cRHHAlias)->RHH_MESANO := (cRHHRJ5)->RHH_MESANO
				(cRHHAlias)->RHH_DATA	:= (cRHHRJ5)->RHH_DATA
				(cRHHAlias)->RHH_VB		:= (cRHHRJ5)->RHH_VB
				(cRHHAlias)->RHH_CC		:= (cRHHRJ5)->RHH_CC
				(cRHHAlias)->RHH_CCBKP	:= (cRHHRJ5)->RHH_CCBKP
			EndIf
			(cRHHAlias)->RHH_VALOR	+= (cRHHRJ5)->RHH_VALOR

			(cRHHAlias)->(MsUnlock())
		EndIf
		(cRHHRJ5)->(DbSkip())
	EndDo

	(cRHHAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fGerRes()
Fun��o que gera as verbas da rescis�o complementar
@type function
@author allyson.mesashi
@since 07/02/2019
@version 1.0
@param cSRDAlias	= Alias da tabela tempor�ria principal
@param dDtGerar		= Data de Gera��o da Rescis�o
/*/
Static Function fGerRes(cSRDAlias, dDtGerar, cPeriod, lRJ5Ok, aErrosRJ5)
Local aColumns	 := {}
Local lNovo		 := .F.
Local cCCAnt	 := ""
Local cCCRJ5	 := ""
Local cRot 		 := If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"), fGetRotOrdinar())
Local lFilT 	 := .F.
Local aRH5Filt	 := {}
Local cPdLiqRes	 := RetValSRV('0126', SRA->RA_FILIAL, "RV_COD", 2)

If lVerRJ5
	lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
	aRH5Filt := fRJ5Filt()
Endif

aAdd( aColumns, { "RD_FILIAL"	,"C",FwGetTamFilial,0 })
aAdd( aColumns, { "RD_MAT"		,"C",nTamMat,0})
aAdd( aColumns, { "RD_DATARQ"	,"C",6,0})
aAdd( aColumns, { "RD_CC"		,"C",nTamCC,0})
aAdd( aColumns, { "RD_PD"		,"C",nTamVb,0})
aAdd( aColumns, { "RD_PERIODO"	,"C",6,0})
aAdd( aColumns, { "RD_ROTEIR"	,"C",nTamRot,0})
aAdd( aColumns, { "RD_HORAS"	,"N",nTamHor,nDecHor})
aAdd( aColumns, { "RD_VALOR"	,"N",nTamVal,nDecVal})
aAdd( aColumns, { "RD_DATPGT"	,"C",8,0})
aAdd( aColumns, { "RECNO"		,"N",200,0})
aAdd( aColumns, { "TAB"			,"C",3,0})
aAdd( aColumns, { "RD_CCBKP"	,"C",nTamCC,0})
aAdd( aColumns, { "RD_SEMANA"	,"C", 2, 0})

oTmpTable := FWTemporaryTable():New( cSRDAlias )
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "IND", { "RD_FILIAL", "RD_MAT", "RD_PERIODO", "RD_CC", "RD_PD", "RD_ROTEIR" } )
oTmpTable:Create()

SRR->( dbSetOrder(1) )
If SRR->( dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "R" + dToS(dDtGerar) ) )
	While SRR->(!Eof() .And. SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3 + dToS(SRR->RR_DATA) == SRA->RA_FILIAL + SRA->RA_MAT + "R" + dToS(dDtGerar))
		If SRR->RR_PD <> cPdLiqRes
			lNovo	:= (cSRDAlias)->( !dbSeek( SRR->RR_FILIAL+SRR->RR_MAT+SRR->RR_PERIODO+SRR->RR_CC+SRR->RR_PD+cRot ) )
			If RecLock(cSRDAlias, lNovo)
				If lNovo
					(cSRDAlias)->RD_FILIAL 	:= SRR->RR_FILIAL
					(cSRDAlias)->RD_MAT 	:= SRR->RR_MAT
					(cSRDAlias)->RD_DATARQ 	:= SRR->RR_PERIODO

					If lVerRJ5
						If cCCAnt != SRR->RR_CC
							cCCAnt := SRR->RR_CC
							cCCRJ5 := ""

							If !lFilT
								RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
								If RJ5->( dbSeek( xFilial("RJ5", SRR->RR_FILIAL) + SRR->RR_CC ) )
									While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRR->RR_FILIAL) .And. RJ5->RJ5_CC == SRR->RR_CC
										If cPeriod >= RJ5->RJ5_INI
											cCCRJ5 := RJ5->RJ5_COD
										EndIf
										RJ5->( dbSkip() )
									EndDo
								EndIf
							Else
								RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
								RJ5->(dbGotop())
								If Len(aRH5Filt) > 0
									If RJ5->( dbSeek( xFilial("RJ5", SRR->RR_FILIAL) + SRR->RR_CC + SRR->RR_FILIAL)  )
										While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRR->RR_FILIAL) .And. RJ5->RJ5_CC == SRR->RR_CC .And.;
											IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == SRR->RR_FILIAL, .T.)
											If cPeriod >= RJ5->RJ5_INI
												cCCRJ5 := RJ5->RJ5_COD
											EndIf
											RJ5->( dbSkip() )
										EndDo
									EndIf
								Endif
								If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
									If RJ5->( dbSeek( xFilial("RJ5", SRR->RR_FILIAL) + SRR->RR_CC ) )
										While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", SRR->RR_FILIAL) .And. RJ5->RJ5_CC == SRR->RR_CC .And.;
											IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT ==SRR->RR_FILIAL, .T.)
											If cPeriod >= RJ5->RJ5_INI
												cCCRJ5 := RJ5->RJ5_COD
											EndIf
											RJ5->( dbSkip() )
										EndDo
									Endif
								EndIf
							Endif

							If Empty(cCCRJ5)
								lRJ5Ok 	:= .F.
								If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
									aAdd( aErrosRJ5, cCCAnt )
								EndIf
							EndIf
						EndIf
					Else
						cCCAnt := SRR->RR_CC
						cCCRJ5 := SRR->RR_CC
					EndIf

					(cSRDAlias)->RD_CC		:= cCCRJ5
					(cSRDAlias)->RD_PD		:= SRR->RR_PD
					(cSRDAlias)->RD_PERIODO	:= SRR->RR_PERIODO
					(cSRDAlias)->RD_ROTEIR	:= cRot
					(cSRDAlias)->RD_DATPGT	:= dToS(SRR->RR_DATAPAG)
					(cSRDAlias)->RECNO		:= SRR->( Recno() )
					(cSRDAlias)->TAB		:= "SRR"
					(cSRDAlias)->RD_CCBKP	:= cCCAnt
				EndIf
				(cSRDAlias)->RD_HORAS	+= SRR->RR_HORAS
				(cSRDAlias)->RD_VALOR	+= SRR->RR_VALOR

				(cSRDAlias)->(MsUnLock())
			EndIf
		EndIf
		SRR->(DbSkip())
	EndDo
EndIf

(cSRDAlias)->( dbGoTop() )

Return

/*/{Protheus.doc} fQryCPF()
Fun��o que guarda os CPFs que ser�o processados nos eventos S-1200/S-1210 em uma tabela f�sica tempor�ria para utiliza��o na query dos funcion�rios que ser�o processados
@type function
@author allyson.mesashi
@since 11/04/2019
@version 1.0
/*/
Function fQryCPF(cFilQry, aFilInTaf, nI, cCPFDe, cCPFAte, cExpFiltro, l1200, cPeriodo, aArrayFil)

Local aColumns  := {}
Local cAliasQ   := GetNextAlias()
Local cQuery    := ""

aAdd( aColumns, { "RA_CIC"		,"C",11,0})

oTmpCPF := FWTemporaryTable():New(cSRACPF)
oTmpCPF:SetFields( aColumns )
oTmpCPF:Create()

cQuery := "SELECT SRA.RA_CIC FROM " + RetSqlName('SRA') + " SRA "
If lAglut .Or. !l1200
    cQuery += "WHERE SRA.RA_FILIAL IN (" + cFilQry + ") "
ElseIf !lMiddleware
    cQuery += "WHERE SRA.RA_FILIAL IN (" + StrTran(fGM23Fil(aFilInTaf, nI)[1], "%", "") + ") "
Else
    cQuery += "WHERE SRA.RA_FILIAL IN ('" + aArrayFil[nI] + "') "
EndIf
If !Empty(cCPFDe) .And. !Empty(cCPFAte)
    cQuery += "AND SRA.RA_CIC >= '" + cCPFDe + "' AND SRA.RA_CIC <= '" + cCPFAte + "' "
EndIf

If !l1200 .And. lAglut
	cQuery += "AND NOT(SRA.RA_RESCRAI IN ('30','31') AND SUBSTRING(SRA.RA_DEMISSA,1,6) < '" + cPeriodo + "') "
ElseIf (l1200 .Or. lAglut)
	cQuery += "AND NOT(SRA.RA_RESCRAI IN ('30','31') AND SRA.RA_DEMISSA <= '" + DToS(lastDay(SToD(cPeriodo + "01"))) + "') "
EndIf
If !Empty(cExpFiltro)
    cExpFiltro 	:= GPEParSQL(fPrepExpIn(cExpFiltro))
    cQuery 		+= "AND ( " + cExpFiltro + ") "
EndIf
cQuery += "AND SRA.RA_CIC <> ' ' "
cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
cQuery += "GROUP BY SRA.RA_CIC "
cQuery += "ORDER BY SRA.RA_CIC"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ,.T.,.T.)

While (cAliasQ)->(!Eof())
	If RecLock(cSRACPF, .T.)
		(cSRACPF)->RA_CIC := (cAliasQ)->RA_CIC
		(cSRACPF)->(MsUnLock())
	EndIf
	(cAliasQ)->(DbSkip())
EndDo

(cAliasQ)->( dbCloseArea() )

Return

/*/{Protheus.doc} fQryEmp()
Fun��o que guarda os CNPJ's que ser�o processados nos eventos S-1200/S-1210 em uma tabela f�sica tempor�ria para utiliza��o na query dos funcion�rios que ser�o processados
@type function
@author allyson.mesashi
@since 06/06/2019
@version 1.0
/*/
Function fQryEmp()

Local aColumns  := {}
Local nCont		:= 1

Aadd(aColumns, {"FILIAL", "C", FwSizeFilial()		, 0})
Aadd(aColumns, {"CNPJ"	, "C", 8 , 0})

oTmpEmp := FWTemporaryTable():New(cSRAEmp)
oTmpEmp:SetFields( aColumns )
oTmpEmp:Create()

For nCont := 1 To Len(aSM0)
	If aSM0[nCont, 1] == cEmpAnt .And. RecLock(cSRAEmp, .T.)
		(cSRAEmp)->FILIAL 	:= aSM0[nCont, 2]
		(cSRAEmp)->CNPJ 	:= SUBSTR(aSM0[nCont, 18],1,8)

		(cSRAEmp)->(MsUnLock())
	EndIf
Next nCont

Return

/*/{Protheus.doc} fPesqRHH()
Fun��o que verifica se encontrou c�lculo na tabela RHH
@type function
@author allyson.mesashi
@since 26/06/2019
@version 1.0
@param cFilRHH		= C�digo da filial
@param cMatRHH		= C�digo da matr�cula
@param cPerRHH		= Per�odo de busca na RHH
@param cPerIni		= Per�odo inicial de c�lculo do diss�dio na RHH
@param cPerFim		= Per�odo final de c�lculo do diss�dio na RHH
@return lAchou		= Indica se encontrou c�lculo na RHH
/*/
Static Function fPesqRHH( cFilRHH, cMatRHH, cPerRHH, cPerIni, cPerFim, lMesAnt)

Local cLimPesq	:= ""
Local cMesDiss	:= ""
Local lAchou	:= .F.
Local cRHHAlias	:= ""

DEFAULT cFilRHH	:= ""
DEFAULT cMatRHH	:= ""
DEFAULT cPerRHH	:= ""
DEFAULT cPerIni	:= ""
DEFAULT cPerFim	:= ""
DEFAULT lMesAnt	:= .F.

lAchou 	:= RHH->( dbSeek( cFilRHH + cMatRHH + cPerRHH ) )

If !lAchou
	cMesDiss := StrZero( Val( fDesc( "RCE", SRA->RA_SINDICA, "RCE_MESDIS", Nil, SRA->RA_FILIAL ) ), 2 )
	If !Empty(cMesDiss)
		If SubStr(cPerRHH, 5, 2) < cMesDiss
			cLimPesq := AnoMes( YearSub( sToD(SubStr(cPerRHH, 1, 4)+cMesDiss+"01"), 1 ) )
		Else
			cLimPesq := SubStr(cPerRHH, 1, 4) + cMesDiss
		EndIf
	Else
		cLimPesq := AnoMes( YearSub( sToD(cPerRHH+"01"), 1 ) )
	EndIf

	cPerRHH := SubMesAno(cPerRHH)

	While cPerRHH >= cLimPesq
		lAchou 	:= RHH->( dbSeek( cFilRHH + cMatRHH + cPerRHH ) )
		If lAchou
			lMesAnt := .T.
			Exit
		EndIf
		cPerRHH := SubMesAno(cPerRHH)
	EndDo
EndIf

If lAchou
	cRHHAlias	:= GetNextAlias()
	cPerIni		:= RHH->RHH_DATA
	If __oSt17 == Nil
		__oSt17 := FWPreparedStatement():New()
		cQrySt := "SELECT RHH.RHH_DATA "
		cQrySt += "FROM " + RetSqlName('RHH') + " RHH "
		cQrySt += "WHERE RHH.RHH_FILIAL = ? AND "
		cQrySt += 		"RHH.RHH_MAT = ? AND "
		cQrySt += 		"RHH.RHH_MESANO = ? AND "
		cQrySt += 		"RHH.RHH_VB = '000' AND "
		cQrySt += 		"RHH.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHH_DATA "
		cQrySt += "ORDER BY 1"
		cQrySt := ChangeQuery(cQrySt)
		__oSt17:SetQuery(cQrySt)
	EndIf
	__oSt17:SetString(1, cFilRHH)
	__oSt17:SetString(2, cMatRHH)
	__oSt17:SetString(3, cPerRHH)
	cQrySt := __oSt17:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cRHHAlias,.T.,.T.)
	While (cRHHAlias)->( !EoF() )
		cPerFim		:= (cRHHAlias)->RHH_DATA
		(cRHHAlias)->( dbSkip() )
	EndDo
	(cRHHAlias)->( dbCloseArea() )
EndIf

Return lAchou

/*/{Protheus.doc} fXml1200
Fun��o que monta o XML do evento S-1200 atrav�s da estrutura abaixo dos arrays de controle:

aEvtRemun <evtRemun>
	|
	-> aIdeEven <ideEvento> -> Relaciona com aEvtRemun por RA_CIC
	|
	-> aIdeTrabal <ideTrabalhador> -> Relaciona com aEvtRemun por RA_CIC
		|
		-> aInfMV <infoMV> -> Relaciona com aIdeTrabal por <cpfTrab>
			|
			-> aRemOutEmp <remunOutrEmpr> -> Relaciona com aInfMV por <cpfTrab>
		|
		-> aInfCompl <infoComplem> -> Relaciona com aIdeTrabal por <cpfTrab>
		|
		-> aProcJud <procJudTrab> -> Relaciona com aIdeTrabal por <cpfTrab>
		|
		-> aInfInter <infoInterm> -> Relaciona com aIdeTrabal por <cpfTrab>
	|
	-> aDmDev -> Algutina por <ideDmDev> e <codCateg>
		|
		-> aInfPerApur <infoPerApur> -> Relaciona com aDmDev por <ideDmDev> + <codCateg>
			|
			-> aEstLotApur <ideEstabLot> -> Relaciona com aInfPerApur por <ideDmDev> + <codCateg>
				|
				-> aRemPerApur <remunPerApur> -> Relaciona com aEstLotApur por <ideDmDev> + <codCateg> e <tpInsc> + <nrInsc> + <codLotacao>
					|
					-> aItRemApur <itensRemun> -> Relaciona com aRemPerApur por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
					|
					-> aInfSauCole <infoSaudeColet> -> Relaciona com aRemPerApur por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
						|
						-> aDetOper <detOper> -> Relaciona com aInfSauCole por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
							|
							-> aDetPlano <detPlano> -> Relaciona com aDetOper por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao>, <matricula> e <cnpjOper>
					|
					-> aInfAgNoc <infoAgNocivo> -> Relaciona com aRemPerApur por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
					|
					-> aInfTrabInt <infoTrabInterm> -> Relaciona com aRemPerApur por <ideDmDev> + <codCateg>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
		|
		-> aInfPerAnt <infoPerAnt> -> Relaciona com aDmDev por <ideDmDev> + <codCateg
			|
			->_ aIdeADCAnt <ideADC> -> Relaciona com aInfPerAnt por <ideDmDev> + <codCateg>
				|
				-> aIdePer <idePeriodo> -> Relaciona com aIdeADC por <ideDmDev> + <codCateg> + <dtAcConv> + <tpAcConv>
					|
					-> aEstLotAnt <ideEstabLot> -> Relaciona com aDmDev por <ideDmDev> + <codCateg>, <dtAcConv> + <tpAcConv> e <perRef>
						|
						-> aRemPerAnt <remunPerAnt> -> Relaciona com aEstLotAnt por <ideDmDev> + <codCateg>, <dtAcConv>, <tpAcConv>, <perRef> e <tpInsc> + <nrInsc> + <codLotacao>
							|
							-> aItRemAnt <itensRemun> -> Relaciona com aRemPerAnt por <ideDmDev> + <codCateg>, <dtAcConv>, <tpAcConv>, <perRef>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
							|
							-> aAgNocAnt <infoAgNocivo> -> Relaciona com aRemPerAnt por <ideDmDev> + <codCateg>, <dtAcConv>, <tpAcConv>, <perRef>, <tpInsc> + <nrInsc> + <codLotacao> e <matricula>
		|
		-> aComplCont <infoComplCont> -> Relaciona com aDmDev por <ideDmDev> + <codCateg>

@author Allyson
@since 25/06/2019
@version 1.0
@param cXML 		- String com o XML do evento S-1200
/*/
Static Function fXml1200( cXML, cRetfNew, cRecibXML, cTpFolha, cPerApur, cIdXml, cVersMw, aErros, cPeriodo, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cGpeAmbe, cVersEnv, aInfoC)

Local cChaveMid		:= "-1"
Local cStatus		:= "-1"
Local lS1000		:= .T.

Local lRet			:= .T.
Local nCntEvRem		:= 0
Local nCntIdEve		:= 0
Local nCntIdTrab	:= 0
Local nCntInfMV		:= 0
Local nCntRemOE		:= 0
Local nCntInfCom	:= 0
Local nCntPrcJud	:= 0
Local nCntInfInt	:= 0
Local nCntDmDev		:= 0
Local nCntInfApu	:= 0
Local nCntEstApu	:= 0
Local nCntRemApu	:= 0
Local nCntIteApu	:= 0
Local nCntInfSau	:= 0
Local nCntDetOpe	:= 0
Local nCntDetPla	:= 0
Local nCntAgNoc		:= 0
Local nCntTraInt	:= 0
Local nCntInfAnt	:= 0
Local nCntIdeAdc	:= 0
Local nCntIdePer	:= 0
Local nCntEstAnt	:= 0
Local nCntRemAnt	:= 0
Local nCntIteAnt	:= 0
Local nCntNocAnt	:= 0
Local nCntComCon	:= 0
Local nCntSucVin	:= 0

Default cRetfNew	:= "1"
Default cRecibXML	:= ""
Default cTpFolha	:= ""
Default cPerApur	:= ""
Default cIdXml		:= ""
Default cVersMw		:= ""
Default aErros		:= {}
Default cPerApur	:= AnoMes(dDatabase)
Default cFilEnv		:= ""
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc		:= ""
Default cGpeAmbe	:= "2"
Default cVersEnv	:= ""
Default aInfoC		:= IIf(!lMiddleware, {}, fXMLInfos())

If !lMiddleware
	S1200A01(@cXml, .F.)//<eSocial>
Else
	cXml += "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtRemun/v" + cVersMw + "'>"
	fPosFil( cEmpAnt, cFilEnv )
	lS1000 := fVld1000( cPeriodo, @cStatus )
	If !lS1000
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX n�o localizado na base de dados"
			Case cStatus == "1" // nao enviado para o governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX n�o transmitido para o governo"
			Case cStatus == "2" // enviado e aguardando retorno do governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
			Case cStatus == "3" // enviado e retornado com erro
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
		EndCase
		Return .F.
	ElseIf !Empty(aEvtRemun)
		fExcRJO( cFilEnv, cTpFolha, StrTran(cPerApur, "-", ""), aEvtRemun[1, 1], "S-1200" )
	EndIf
EndIf

For nCntEvRem := 1 To Len(aEvtRemun)
	If !lMiddleware
		S1200A02(@cXml, {}, .F., lGera1202, lGera1207)//<evtRemun>
	Else
		cXML += "<evtRemun Id='" + cIdXml + "'>"//<evtRemun>
	EndIf
	For nCntIdEve := 1 To Len(aIdeEven)
		If aIdeEven[nCntIdEve, 8] == aEvtRemun[nCntEvRem, 1]//aEvtRemun -> aIdeEven | RA_CIC
			If !lMiddleware
				S1200A03(@cXml, aIdeEven[nCntIdEve], .T.)//<ideEvento>
			Else
				fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), cTpFolha, cPerApur, cGpeAmbe, 1, "12" }, If(Len(aInfoC) == 5 .And. aInfoC[5] $ "21*22",cVersEnv,Nil) )//<ideEvento>
				fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
			EndIf
		EndIf
	Next nCntIdEve
	For nCntIdTrab := 1 To Len(aIdeTrabal)
		If aIdeTrabal[nCntIdTrab, 1] == aEvtRemun[nCntEvRem, 1]//aEvtRemun -> aIdeTrabal | cpfTrab
			If(lGera1207, S1210A05(@cXml, aIdeTrabal[nCntIdTrab], .F.), S1200A05(@cXml, aIdeTrabal[nCntIdTrab], .F.) )//<ideBenef> ou <ideTrabalhador>
			If !lGera1202 .And. !lGera1207
				For nCntInfMV := 1 To Len(aInfMV)
					If aInfMV[nCntInfMV, 2] == aIdeTrabal[nCntIdTrab, 1]//aIdeTrabal -> aInfMV | cpfTrab
						S1200A06(@cXml, aInfMV[nCntInfMV], .F.)//<infoMV>
						For nCntRemOE := 1 To Len(aRemOutEmp)
							If aRemOutEmp[nCntRemOE, 5] == aInfMV[nCntInfMV, 2]//aInfMV -> aRemOutEmp | cpfTrab
								S1200A07(@cXml, aRemOutEmp[nCntRemOE], .T.)//<remunOutrEmpr>
							EndIf
						Next nCntRemOE
						S1200F06(@cXml)//<infoMV>
					EndIf
				Next nCntInfMV
			Endif
			For nCntInfCom := 1 To Len(aInfCompl)
				If aInfCompl[nCntInfCom, 3] == aIdeTrabal[nCntIdTrab, 1]//aIdeTrabal -> aInfCompl | cpfTrab
					S1200A08(@cXml, aInfCompl[nCntInfCom], If(cVersEnv >= "9.0.00", .F., .T.))//<infoComplem>
					For nCntSucVin := 1 To Len(aSucVinc)
						If aSucVinc[nCntSucVin, 6] == aIdeTrabal[nCntIdTrab, 1]//aInfCompl -> sucessaoVinc | cpfTrab
							S1200A26(@cXml, aSucVinc[nCntSucVin, 1])//<sucessaoVinc>
						EndIf
					Next nCntSucVin
					If cVersEnv >= "9.0.00"
						S1200F08(@cXml)//</infoComplem>
					EndIf
				EndIf
			Next nCntInfCom
			If !lGera1202 .And. !lGera1207
				For nCntPrcJud := 1 To Len(aProcJud)
					If aProcJud[nCntPrcJud, 6] == aIdeTrabal[nCntIdTrab, 1]//aIdeTrabal -> procJudTrab | cpfTrab
						S1200A25(@cXml, aProcJud[nCntPrcJud, 1])//<procJudTrab>
					EndIf
				Next nCntInfInt
				For nCntInfInt := 1 To Len(aInfInter)
					If aInfInter[nCntInfInt, 2] == aIdeTrabal[nCntIdTrab, 1]//aIdeTrabal -> aInfInter | cpfTrab
						If cVersEnv >= "9.0.00" .And. len(aDiasConv) > 0
							S1200A27(@cXml, aDiasConv, .T.)//<infoInterm>
						ElseIf cVersEnv < "9.0.00"
							S1200A23(@cXml, aInfInter[nCntInfInt, 1], .T.)//<infoInterm>
						EndIf
					EndIf
				Next nCntInfInt
			Endif
			If(lGera1207, S1210F05(@cXml), S1200F05(@cXml) )//<ideBenef> ou <ideTrabalhador>
		EndIf
	Next nCntIdTrab
	For nCntDmDev := 1 To Len(aDmDev)
		If aDmDev[nCntDmDev, 3] == aEvtRemun[nCntEvRem, 1] .And. (aScan( aItRemApur, { |x| aDmDev[nCntDmDev, 1] $ x[8] } ) > 0 .Or. aScan( aItRemAnt, { |x| aDmDev[nCntDmDev, 1] $ x[8] } ) > 0)//aEvtRemun -> aDmDev | RA_CIC
			S1200A10(@cXml, aDmDev[nCntDmDev], .F., lGera1207 )//<dmDev>
			For nCntInfApu := 1 To Len(aInfPerApur)
				If aInfPerApur[nCntInfApu, 1] == aDmDev[nCntDmDev, 3] .And. aInfPerApur[nCntInfApu, 2] == aDmDev[nCntDmDev, 1]+aDmDev[nCntDmDev, 2]//aDmDev -> aInfPerApur | ideDmDev + codCateg
					S1200A11(@cXml)//<infoPerApur>
					For nCntEstApu := 1 To Len(aEstLotApur)
						If aEstLotApur[nCntEstApu, 5] == aInfPerApur[nCntInfApu, 1] .And. aEstLotApur[nCntEstApu, 6] == aInfPerApur[nCntInfApu, 2]//aInfPerApur -> aEstLotApur | ideDmDev + codCateg
							S1200A12(@cXml, aEstLotApur[nCntEstApu], .F., lGera1202 .Or. lGera1207)//<ideEstabLot>
							If lMiddleware
								fValPred(aEstLotApur[nCntEstApu, 7], "S1005", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
								fValPred(aEstLotApur[nCntEstApu, 3], "S1020", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
							EndIf
							For nCntRemApu := 1 To Len(aRemPerApur)
								If aRemPerApur[nCntRemApu, 3] == aEstLotApur[nCntEstApu, 5] .And. aRemPerApur[nCntRemApu, 4] == aEstLotApur[nCntEstApu, 6]+aEstLotApur[nCntEstApu, 1]+aEstLotApur[nCntEstApu, 2]+aEstLotApur[nCntEstApu, 3]//ideEstabLot -> aRemPerApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao
									If(!lGera1207, S1200A13(@cXml, aRemPerApur[nCntRemApu], "remunPerApur", .F.,lGera1202), )//<remunPerApur>
									For nCntIteApu := 1 To Len(aItRemApur)
										If aItRemApur[nCntIteApu, 7] == aRemPerApur[nCntRemApu, 3] .And. aItRemApur[nCntIteApu, 8] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aItRemApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
											S1200A14(@cXml, aItRemApur[nCntIteApu], .T., cVersEnv, cPerApur)//<itensRemun>
											If lMiddleware
												fValPred(aItRemApur[nCntIteApu, 17], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
												If Len(aItRemApur[nCntIteApu]) < 20 .Or. (Len(aItRemApur[nCntIteApu]) >= 20 .And. !(aItRemApur[nCntIteApu, 20] $ "0288*0289"))
													If (aItRemApur[nCntIteApu, 9] == "9901" .And. aItRemApur[nCntIteApu, 16] == "3") .Or. (aItRemApur[nCntIteApu, 9] == "9201" .And. aItRemApur[nCntIteApu, 10] $ "31/32") .Or. (aItRemApur[nCntIteApu, 9] == "1409" .And. aItRemApur[nCntIteApu, 10] == "51") .Or. (aItRemApur[nCntIteApu, 9] == "4050" .And. aItRemApur[nCntIteApu, 10] == "21") .Or. (aItRemApur[nCntIteApu, 9] == "4051" .And. aItRemApur[nCntIteApu, 10] == "22") .Or. (aItRemApur[nCntIteApu, 9] == "9902" .And. aItRemApur[nCntIteApu, 16] == "3") .Or. (aItRemApur[nCntIteApu, 9] == "9904" .And. aItRemApur[nCntIteApu, 16] == "3") .Or. (aItRemApur[nCntIteApu, 9] == "9908" .And. aItRemApur[nCntIteApu, 16] == "3")
														fGrvRJO(cFilEnv, cTpFolha, StrTran(cPerApur, "-", ""), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], If(empty(aRemPerApur[nCntRemApu, 1]), SRA->RA_CODUNIC, aRemPerApur[nCntRemApu, 1]), aDmDev[nCntDmDev, 2], aEstLotApur[nCntEstApu, 1], aEstLotApur[nCntEstApu, 2], alltrim(aEstLotApur[nCntEstApu, 3]), aItRemApur[nCntIteApu, 9], aItRemApur[nCntIteApu, 16], aItRemApur[nCntIteApu, 10], aItRemApur[nCntIteApu, 12], aItRemApur[nCntIteApu, 11], Val(aItRemApur[nCntIteApu, 6]), "S-1200", , , , aItRemApur[nCntIteApu, 18], aItRemApur[nCntIteApu, 19])
													EndIf
												EndIf
											EndIf
										EndIf
									Next nCntIteApu
									For nCntInfSau := 1 To Len(aInfSauCole)
										If aInfSauCole[nCntInfSau, 1] == aRemPerApur[nCntRemApu, 3] .And. aInfSauCole[nCntInfSau, 2] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aItRemApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
											S1200A15(@cXml, .F.)//<infoSaudeColet>
											For nCntDetOpe := 1 To Len(aDetOper)
												If aDetOper[nCntDetOpe, 4] == aInfSauCole[nCntInfSau, 1] .And. aDetOper[nCntDetOpe, 5] == aInfSauCole[nCntInfSau, 2]//aInfSauCole -> aDetOper | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
													S1200A16(@cXml, aDetOper[nCntDetOpe], .F.)//<detOper>
													For nCntDetPla := 1 To Len(aDetPlano)
														If aDetPlano[nCntDetPla, 6] == aDetOper[nCntDetOpe, 4] .And. aDetPlano[nCntDetPla, 7] == aDetOper[nCntDetOpe, 5]+aDetOper[nCntDetOpe, 1]//aDetOper -> aDetPlano | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula + cnpjOper
															S1200A17(@cXml, aDetPlano[nCntDetPla], .T.)//<detPlano>
														EndIf
													Next nCntDetPla
													S1200F16(@cXml)//<detOper>
												EndIf
											Next nCntDetOpe
											S1200F15(@cXml)//<infoSaudeColet>
										EndIf
									Next nCntInfSau
									If !lGera1202
										For nCntAgNoc := 1 To Len(aInfAgNoc)
											If aInfAgNoc[nCntAgNoc, 2] == aRemPerApur[nCntRemApu, 3] .And. aInfAgNoc[nCntAgNoc, 3] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aInfAgNoc | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
												S1200A18(@cXml, aInfAgNoc[nCntAgNoc], .T.)//<infoAgNocivo>
											EndIf
										Next nCntAgNoc
										For nCntTraInt := 1 To Len(aInfTrabInt)
											If aInfTrabInt[nCntTraInt, 2] == aRemPerApur[nCntRemApu, 3] .And. aInfTrabInt[nCntTraInt, 3] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aInfTrabInt | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
												S1200A24(@cXml, aInfTrabInt[nCntTraInt, 1], .T.)//<infoTrabInterm>
											EndIf
										Next nCntTraInt
									Endif
									If(!lGera1207, S1200F13(@cXml, "remunPerApur"), )//<remunPerApur>
								EndIf
							Next nCntRemApu
							S1200F12(@cXml,lGera1202 .Or. lGera1207)//<ideEstabLot>
						EndIf
					Next nCntEstApu
					S1200F11(@cXml)//<infoPerApur>
				EndIf
			Next nCntInfApu
			For nCntInfAnt := 1 To Len(aInfPerAnt)
				If aInfPerAnt[nCntInfAnt, 1] == aDmDev[nCntDmDev, 3] .And. aInfPerAnt[nCntInfAnt, 2] == aDmDev[nCntDmDev, 1]+aDmDev[nCntDmDev, 2]//aDmDev -> aInfPerAnt | ideDmDev + codCateg
					S1200A19(@cXml, .F.)//<infoPerAnt>
					If !lGera1202  // Tratamento periodos anteriores sera tratado na sucessao de vinculos
						For nCntIdeAdc := 1 To Len(aIdeADCAnt)
							If aIdeADCAnt[nCntIdeAdc, 7] == aInfPerAnt[nCntInfAnt, 1] .And. aIdeADCAnt[nCntIdeAdc, 8] == aInfPerAnt[nCntInfAnt, 2]//aInfPerAnt -> aIdeADCAnt | ideDmDev + codCateg
								S1200A20(@cXml, aIdeADCAnt[nCntIdeAdc], .F.)//<ideADC>
								For nCntIdePer := 1 To Len(aIdePer)
									If aIdePer[nCntIdePer, 2] == aIdeADCAnt[nCntIdeAdc, 7] .And. aIdePer[nCntIdePer, 3] == aIdeADCAnt[nCntIdeAdc, 8]+aIdeADCAnt[nCntIdeAdc, 1]+aIdeADCAnt[nCntIdeAdc, 2]//aIdeADCAnt -> aIdePer | ideDmDev + codCateg + tpAcConv
										S1200A21(@cXml, aIdePer[nCntIdePer], .F.)//<idePeriodo>
										For nCntEstAnt := 1 To Len(aEstLotAnt)
											If aEstLotAnt[nCntEstAnt, 5] == aIdePer[nCntIdePer, 2] .And. aEstLotAnt[nCntEstAnt, 6] == aIdePer[nCntIdePer, 3]+aIdePer[nCntIdePer, 1] ;//aIdePer -> aEstLotAnt | ideDmDev + codCateg + tpAcConv + perRef
											.And. aScan(aItRemAnt, {|x| aEstLotAnt[nCntEstAnt,6]+aEstLotAnt[nCntEstAnt,1]+aEstLotAnt[nCntEstAnt,2]+aEstLotAnt[nCntEstAnt,3] $ x[8] }) > 0 //gerar apenas quando houver rubrica
												S1200A12(@cXml, aEstLotAnt[nCntEstAnt], .F.)//<ideEstabLot>
												If lMiddleware
													fValPred(aEstLotAnt[nCntEstAnt, 7], "S1005", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
													fValPred(aEstLotAnt[nCntEstAnt, 3], "S1020", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
												EndIf
												For nCntRemAnt := 1 To Len(aRemPerAnt)
													If aRemPerAnt[nCntRemAnt, 3] == aEstLotAnt[nCntEstAnt, 5] .And. aRemPerAnt[nCntRemAnt, 4] == aEstLotAnt[nCntEstAnt, 6]+aEstLotAnt[nCntEstAnt, 1]+aEstLotAnt[nCntEstAnt, 2]+aEstLotAnt[nCntEstAnt, 3]//aEstLotAnt -> aRemPerAnt | ideDmDev + codCateg + tpAcConv + perRef + tpInsc + nrInsc + codLotacao
														S1200A13(@cXml, aRemPerAnt[nCntRemAnt], "remunPerAnt", .F.,lGera1202)//<remunPerAnt>
														For nCntIteAnt := 1 To Len(aItRemAnt)
															If aItRemAnt[nCntIteAnt, 7] == aRemPerAnt[nCntRemAnt, 3] .And. aItRemAnt[nCntIteAnt, 8] == aRemPerAnt[nCntRemAnt, 4]+aRemPerAnt[nCntRemAnt, 1]//aRemPerAnt -> aItRemAnt | ideDmDev + codCateg + tpAcConv + perRef + tpInsc + nrInsc + codLotacao + matricula
																S1200A14(@cXml, aItRemAnt[nCntIteAnt], .T.,cVersEnv, cPerApur)//<itensRemun>
																If lMiddleware
																	fValPred(aItRemAnt[nCntIteAnt, 17], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
																	If (aItRemAnt[nCntIteAnt, 9] == "9901" .And. aItRemAnt[nCntIteAnt, 16] == "3") .Or. (aItRemAnt[nCntIteAnt, 9] == "9201" .And. aItRemAnt[nCntIteAnt, 10] $ "31/32") .Or. (aItRemAnt[nCntIteAnt, 9] == "1409" .And. aItRemAnt[nCntIteAnt, 10] == "51") .Or. (aItRemAnt[nCntIteAnt, 9] == "4050" .And. aItRemAnt[nCntIteAnt, 10] == "21") .Or. (aItRemAnt[nCntIteAnt, 9] == "4051" .And. aItRemAnt[nCntIteAnt, 10] == "22") .Or. (aItRemAnt[nCntIteAnt, 9] == "9902" .And. aItRemAnt[nCntIteAnt, 16] == "3") .Or. (aItRemAnt[nCntIteAnt, 9] == "9904" .And. aItRemAnt[nCntIteAnt, 16] == "3") .Or. (aItRemAnt[nCntIteAnt, 9] == "9908" .And. aItRemAnt[nCntIteAnt, 16] == "3")
																		fGrvRJO(cFilEnv, cTpFolha, StrTran(cPerApur, "-", ""), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], If(empty(aRemPerAnt[nCntRemAnt, 1]), SRA->RA_CODUNIC, aRemPerAnt[nCntRemAnt, 1]), aDmDev[nCntDmDev, 2], aEstLotAnt[nCntEstAnt, 1], aEstLotAnt[nCntEstAnt, 2], alltrim(aEstLotAnt[nCntEstAnt, 3]), aItRemAnt[nCntIteAnt, 9], aItRemAnt[nCntIteAnt, 16], aItRemAnt[nCntIteAnt, 10], aItRemAnt[nCntIteAnt, 12], aItRemAnt[nCntIteAnt, 11], Val(aItRemAnt[nCntIteAnt, 6]), "S-1200", , , , aItRemAnt[nCntIteAnt, 18], aItRemAnt[nCntIteAnt, 19])
																	EndIf
																EndIf
															EndIf
														Next nCntIteAnt
														For nCntNocAnt := 1 To Len(aAgNocAnt)
															If aAgNocAnt[nCntNocAnt, 2] == aRemPerAnt[nCntRemAnt, 3] .And. aAgNocAnt[nCntNocAnt, 3] == aRemPerAnt[nCntRemAnt, 4]+aRemPerAnt[nCntRemAnt, 1]//aRemPerAnt -> aItRemAnt | ideDmDev + codCateg + dTAco + tpAcConv + perRef + tpInsc + nrInsc + codLotacao + matricula
																S1200A18(@cXml, aAgNocAnt[nCntNocAnt], .T.)//<infoAgNocivo>
															EndIf
														Next nCntNocAnt
														S1200F13(@cXml, "remunPerAnt")//<remunPerAnt>
													EndIf
												Next nCntRemAnt
												S1200F12(@cXml)//<ideEstabLot>
											EndIf
										Next nCntEstAnt
										S1200F21(@cXml)//<idePeriodo>
									EndIf
								Next nCntIdePer
								S1200F20(@cXml)//<ideADC>
							EndIf
						Next nCntIdeAdc
					Endif
					S1200F19(@cXml)//<infoPerAnt>
				EndIf
			Next nCntInfAnt
			If !lGera1202 .And. !lGera1207
				For nCntComCon := 1 To Len(aComplCont)
					If aComplCont[nCntComCon, 4] == aDmDev[nCntDmDev, 3] .And. aComplCont[nCntComCon, 5] == aDmDev[nCntDmDev, 1]+aDmDev[nCntDmDev, 2]//aDmDev -> aComplCont | ideDmDev + codCateg
						S1210A25(@cXml, aComplCont[nCntComCon], .T.)//<infoComplCont>
					EndIf
				Next nCntComCon
			Endif
			S1200F10(@cXml)//<dmDev>
		EndIf
	Next nCntDmDev
	S1200F02(@cXml, lGera1202, lGera1207)//<evtRemun>
Next nCntEvRem

S1200F01(@cXml)//<eSocial>

If lMiddleware .And. !Empty(aErros)
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} fGeraRelat
Fun��o que gera o relat�rio em Excel
@author Allyson
@since 27/06/2019
@version 1.0
/*/
Static Function fGeraRelat(cCompete)

Local aAuxDep		:= {}
Local cArquivo  	:= "RELATORIO_PERIODICOS_"+cCompete+".xls"
Local cDefPath		:= GetSrvProfString( "StartPath", "\system\" )
Local cPath     	:= ""
Local lFirstMv		:= .T.
Local nCntAuxDep	:= 0
Local nCntEvRem		:= 0
Local nCntInfMV		:= 0
Local nCntRemOE		:= 0
Local nCntDmDev		:= 0
Local nCntInfApu	:= 0
Local nCntEstApu	:= 0
Local nCntRemApu	:= 0
Local nCntIteApu	:= 0
Local nCntInfSau	:= 0
Local nCntDetOpe	:= 0
Local nCntDetPla	:= 0
Local nCntInfAnt	:= 0
Local nCntIdeAdc	:= 0
Local nCntIdePer	:= 0
Local nCntEstAnt	:= 0
Local nCntRemAnt	:= 0
Local nCntIteAnt	:= 0
Local nCntFDem		:= 0
Local nCntIncons	:= 0
Local oExcelApp 	:= Nil
Local oExcel

If !IsBlind()
	cPath	:= cGetFile( OemToAnsi(STR0083) + "|*.*", OemToAnsi(STR0084), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )//"Diret�rio"##"Selecione um diret�rio para a gera��o do relat�rio"
Else
	cPath	:= cDefPath
EndIf

oExcel  := FWMSExcel():New()

cAba1   := OemToAnsi(STR0085)//"Demonstrativo Verbas"
cAba2   := OemToAnsi(STR0086)//"Dem. Plano de Sa�de"
cAba3   := OemToAnsi(STR0087)//"MV - Outras Empresas"
cAba4   := OemToAnsi(STR0088)//"Dem. Meses Anteriores-PLR"
cAba5   := OemToAnsi(STR0089)//"S-2299-S-2399"
cAba6   := OemToAnsi(STR0090)//"Inconsist�ncias"
cAba7   := OemToAnsi(STR0091)//"Legenda"

cTabela1 := OemToAnsi(STR0085)//"Demonstrativo Verbas"
cTabela2 := OemToAnsi(STR0092)//"Demonstrativo Plano de Sa�de"
cTabela3 := OemToAnsi(STR0087)//"MV - Outras Empresas"
cTabela4 := OemToAnsi(STR0093)//"Demonstrativo Meses Anteriores / Complementar PLR"
cTabela5 := OemToAnsi(STR0094)//"S-2299 / S-2399"
cTabela6 := OemToAnsi(STR0090)//"Inconsist�ncias"
cTabela7 := OemToAnsi(STR0091)//"Legenda"

// Cria��o de nova aba
oExcel:AddworkSheet(cAba1)
oExcel:AddworkSheet(cAba2)
oExcel:AddworkSheet(cAba3)
oExcel:AddworkSheet(cAba4)
oExcel:AddworkSheet(cAba5)
oExcel:AddworkSheet(cAba6)
oExcel:AddworkSheet(cAba7)

// Cria��o de tabela
oExcel:AddTable(cAba1, cTabela1)
oExcel:AddTable(cAba2, cTabela2)
oExcel:AddTable(cAba3, cTabela3)
oExcel:AddTable(cAba4, cTabela4)
oExcel:AddTable(cAba5, cTabela5)
oExcel:AddTable(cAba6, cTabela6)
oExcel:AddTable(cAba7, cTabela7)

// Cria��o de colunas
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcion�rio"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0100) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. Inscri��o)"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0101) ,1,1,.F.)//"Lota��o"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matr�cula eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0103) ,1,1,.F.)//"Ind. Simples"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0104) ,1,1,.F.)//"Verba"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0105) ,1,1,.F.)//"Tipo da Verba"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0106) ,1,3,.F.)//"Valor"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0107) ,1,1,.F.)//"Natureza"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0108) ,1,1,.F.)//"Incid�ncia INSS eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0109) ,1,1,.F.)//"Incid�ncia IRFF eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0110) ,1,1,.F.)//"Incid�ncia FGTS eSocial"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0111) ,1,1,.F.)//"Incid�ncia INSS Folha"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0112) ,1,1,.F.)//"Incid�ncia IRRF Folha"
oExcel:AddColumn(cAba1, cTabela1, OemToAnsi(STR0113) ,1,1,.F.)//"Incid�ncia FGTS Folha"

oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcion�rio"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0100) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. Inscri��o)"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0101) ,1,1,.F.)//"Lota��o"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matr�cula eSocial"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0114) ,1,1,.F.)//"C�d. Fornecedor"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0115) ,1,1,.F.)//"CNPJ Operadora"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0116) ,1,1,.F.)//"ANS Operadora"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0117) ,1,3,.F.)//"Valor Titular"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0118) ,1,1,.F.)//"C�d. Dependente"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0119) ,1,1,.F.)//"Tipo Dependente"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0120) ,1,1,.F.)//"Nome Dependente"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0121) ,1,1,.F.)//"CPF Dependente"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0122) ,1,1,.F.)//"Data Nascto. Dependente"
oExcel:AddColumn(cAba2, cTabela2, OemToAnsi(STR0123) ,1,3,.F.)//"Valor Dependente"

oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcion�rio"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matr�cula eSocial"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0124) ,1,1,.F.)//"Tipo de Recolhimento"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0125) ,1,1,.F.)//"Empresa (Tipo - Nr. Inscri��o)"
oExcel:AddColumn(cAba3, cTabela3, OemToAnsi(STR0126) ,1,3,.F.)//"Valor Remunera��o"

oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcion�rio"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0098) ,1,1,.F.)//"Categoria eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0127) ,1,1,.F.)//"Data do Acordo"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0128) ,1,1,.F.)//"Tipo do Acordo"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0129) ,1,1,.F.)//"Compet�ncia do Acordo"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0130) ,1,1,.F.)//"Data de Efeito"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0131) ,1,1,.F.)//"Per�odo de Refer�ncia"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0100) ,1,1,.F.)//"Estabelecimento (Tipo - Nr. Inscri��o)"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0101) ,1,1,.F.)//"Lota��o"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matr�cula eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0103) ,1,1,.F.)//"Ind. Simples"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0104) ,1,1,.F.)//"Verba"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0105) ,1,1,.F.)//"Tipo da Verba"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0106) ,1,3,.F.)//"Valor"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0107) ,1,1,.F.)//"Natureza"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0108) ,1,1,.F.)//"Incid�ncia INSS eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0109) ,1,1,.F.)//"Incid�ncia IRFF eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0110) ,1,1,.F.)//"Incid�ncia FGTS eSocial"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0111) ,1,1,.F.)//"Incid�ncia INSS Folha"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0112) ,1,1,.F.)//"Incid�ncia IRRF Folha"
oExcel:AddColumn(cAba4, cTabela4, OemToAnsi(STR0113) ,1,1,.F.)//"Incid�ncia FGTS Folha"

oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba5, cTabela5, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcion�rio"

oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcion�rio"
oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcion�rio"
oExcel:AddColumn(cAba6, cTabela6, OemToAnsi(STR0132) ,1,1,.F.)//"Inconsist�ncias"

oExcel:AddColumn(cAba7, cTabela7, OemToAnsi(STR0133) ,1,1,.F.)//"Tipo"
oExcel:AddColumn(cAba7, cTabela7, OemToAnsi(STR0106) ,1,1,.F.)//"Valor"

//Gera��o das informa��es
For nCntEvRem := 1 To Len(aEvtRemun)
	lFirstMv	:= .T.
	For nCntDmDev := 1 To Len(aDmDev)
		If aDmDev[nCntDmDev, 3] == aEvtRemun[nCntEvRem, 1]//aEvtRemun -> aDmDev | RA_CIC
			For nCntInfApu := 1 To Len(aInfPerApur)
				If aInfPerApur[nCntInfApu, 1] == aDmDev[nCntDmDev, 3] .And. aInfPerApur[nCntInfApu, 2] == aDmDev[nCntDmDev, 1]+aDmDev[nCntDmDev, 2]//aDmDev -> aInfPerApur | ideDmDev + codCateg
					For nCntEstApu := 1 To Len(aEstLotApur)
						If aEstLotApur[nCntEstApu, 5] == aInfPerApur[nCntInfApu, 1] .And. aEstLotApur[nCntEstApu, 6] == aInfPerApur[nCntInfApu, 2]//aInfPerApur -> aEstLotApur | ideDmDev + codCateg
							For nCntRemApu := 1 To Len(aRemPerApur)
								If aRemPerApur[nCntRemApu, 3] == aEstLotApur[nCntEstApu, 5] .And. aRemPerApur[nCntRemApu, 4] == aEstLotApur[nCntEstApu, 6]+aEstLotApur[nCntEstApu, 1]+aEstLotApur[nCntEstApu, 2]+aEstLotApur[nCntEstApu, 3]//ideEstabLot -> aRemPerApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao
									If lFirstMv
										lFirstMv	:= .F.
										For nCntInfMV := 1 To Len(aInfMV)
											If aInfMV[nCntInfMV, 2] == aEvtRemun[nCntEvRem, 1]//aEvtRemun -> aInfMV | cpfTrab
												For nCntRemOE := 1 To Len(aRemOutEmp)
													If aRemOutEmp[nCntRemOE, 5] == aInfMV[nCntInfMV, 2]//aInfMV -> aRemOutEmp | cpfTrab
														oExcel:AddRow(cAba3, cTabela3, { SubStr(aDmDev[nCntDmDev, 1], 1, FwGetTamFilial), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], aDmDev[nCntDmDev, 4]+" - "+aRemPerApur[nCntRemApu, 1], aRemOutEmp[nCntRemOE, 3], aInfMV[nCntInfMV, 1], aRemOutEmp[nCntRemOE, 1] + " - " + aRemOutEmp[nCntRemOE, 2], Val(aRemOutEmp[nCntRemOE, 4]) } )
													EndIf
												Next nCntRemOE
											EndIf
										Next nCntInfMV
									EndIf
									For nCntIteApu := 1 To Len(aItRemApur)
										If aItRemApur[nCntIteApu, 7] == aRemPerApur[nCntRemApu, 3] .And. aItRemApur[nCntIteApu, 8] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aItRemApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
											oExcel:AddRow(cAba1, cTabela1, { aDmDev[nCntDmDev, 5], aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], aDmDev[nCntDmDev, 2], aDmDev[nCntDmDev, 1], aEstLotApur[nCntEstApu, 1]+" - "+aEstLotApur[nCntEstApu, 2], aEstLotApur[nCntEstApu, 3], aDmDev[nCntDmDev, 4]+" - "+aRemPerApur[nCntRemApu, 1], aRemPerApur[nCntRemApu, 2], aItRemApur[nCntIteApu, 1], aItRemApur[nCntIteApu, 16], Val(aItRemApur[nCntIteApu, 6]), aItRemApur[nCntIteApu, 9], aItRemApur[nCntIteApu, 10], aItRemApur[nCntIteApu, 11], aItRemApur[nCntIteApu, 12], aItRemApur[nCntIteApu, 13], aItRemApur[nCntIteApu, 14], aItRemApur[nCntIteApu, 15] } )
										EndIf
									Next nCntIteApu
									For nCntInfSau := 1 To Len(aInfSauCole)
										If aInfSauCole[nCntInfSau, 1] == aRemPerApur[nCntRemApu, 3] .And. aInfSauCole[nCntInfSau, 2] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1]//remunPerApur -> aItRemApur | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
											For nCntDetOpe := 1 To Len(aDetOper)
												If aDetOper[nCntDetOpe, 4] == aInfSauCole[nCntInfSau, 1] .And. aDetOper[nCntDetOpe, 5] == aInfSauCole[nCntInfSau, 2]//aInfSauCole -> aDetOper | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula
													If aScan( aItRemApur, { |x| x[7] == aRemPerApur[nCntRemApu, 3] .And. x[8] == aRemPerApur[nCntRemApu, 4]+aRemPerApur[nCntRemApu, 1] .And. x[9] == "9219"  } ) > 0
														For nCntDetPla := 1 To Len(aDetPlano)
															If aDetPlano[nCntDetPla, 6] == aDetOper[nCntDetOpe, 4] .And. aDetPlano[nCntDetPla, 7] == aDetOper[nCntDetOpe, 5]+aDetOper[nCntDetOpe, 1]//aDetOper -> aDetPlano | ideDmDev + codCateg + tpInsc + nrInsc + codLotacao + matricula + cnpjOper
																aAdd( aAuxDep, { SubStr(aDmDev[nCntDmDev, 1], 1, FwGetTamFilial), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], aDmDev[nCntDmDev, 2], aDmDev[nCntDmDev, 1], aEstLotApur[nCntEstApu, 1]+" - "+aEstLotApur[nCntEstApu, 2], aEstLotApur[nCntEstApu, 3], aDmDev[nCntDmDev, 4]+" - "+aRemPerApur[nCntRemApu, 1], aDetOper[nCntDetOpe, 6], aDetOper[nCntDetOpe, 1], aDetOper[nCntDetOpe, 2], Val(aDetOper[nCntDetOpe, 3]), aDetPlano[nCntDetPla, 8], aDetPlano[nCntDetPla, 1], aDetPlano[nCntDetPla, 3], aDetPlano[nCntDetPla, 2], dToC(sToD(aDetPlano[nCntDetPla, 4])), Val(aDetPlano[nCntDetPla, 5]) } )
															EndIf
														Next nCntDetPla
														If Empty(aAuxDep)
															aAdd( aAuxDep, { SubStr(aDmDev[nCntDmDev, 1], 1, FwGetTamFilial), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], aDmDev[nCntDmDev, 2], aDmDev[nCntDmDev, 1], aEstLotApur[nCntEstApu, 1]+" - "+aEstLotApur[nCntEstApu, 2], aEstLotApur[nCntEstApu, 3], aDmDev[nCntDmDev, 4]+" - "+aRemPerApur[nCntRemApu, 1], aDetOper[nCntDetOpe, 6], aDetOper[nCntDetOpe, 1], aDetOper[nCntDetOpe, 2], Val(aDetOper[nCntDetOpe, 3]), "", "", "", "", "", "" } )
														EndIf
														For nCntAuxDep := 1 To Len(aAuxDep)
															oExcel:AddRow(cAba2, cTabela2, aAuxDep[nCntAuxDep] )
														Next nCntAuxDep
														aAuxDep := {}
													Else
														aAdd( aRelIncons, { SubStr(aDmDev[nCntDmDev, 1], 1, FwGetTamFilial), aEvtRemun[nCntEvRem, 1], OemToAnsi(STR0079) } )//"Houve c�lculo de plano de sa�de, no entanto a(s) verba(s) est�(�o) sem natureza 9219"
													EndIf
												EndIf
											Next nCntDetOpe
										EndIf
									Next nCntInfSau
								EndIf
							Next nCntRemApu
						EndIf
					Next nCntEstApu
				EndIf
			Next nCntInfApu
			For nCntInfAnt := 1 To Len(aInfPerAnt)
				If aInfPerAnt[nCntInfAnt, 1] == aDmDev[nCntDmDev, 3] .And. aInfPerAnt[nCntInfAnt, 2] == aDmDev[nCntDmDev, 1]+aDmDev[nCntDmDev, 2]//aDmDev -> aInfPerAnt | ideDmDev + codCateg
					For nCntIdeAdc := 1 To Len(aIdeADCAnt)
						If aIdeADCAnt[nCntIdeAdc, 7] == aInfPerAnt[nCntInfAnt, 1] .And. aIdeADCAnt[nCntIdeAdc, 8] == aInfPerAnt[nCntInfAnt, 2]//aInfPerAnt -> aIdeADCAnt | ideDmDev + codCateg
							For nCntIdePer := 1 To Len(aIdePer)
								If aIdePer[nCntIdePer, 2] == aIdeADCAnt[nCntIdeAdc, 7] .And. aIdePer[nCntIdePer, 3] == aIdeADCAnt[nCntIdeAdc, 8]+aIdeADCAnt[nCntIdeAdc, 1]+aIdeADCAnt[nCntIdeAdc, 2]//aIdeADCAnt -> aIdePer | ideDmDev + codCateg + tpAcConv
									For nCntEstAnt := 1 To Len(aEstLotAnt)
										If aEstLotAnt[nCntEstAnt, 5] == aIdePer[nCntIdePer, 2] .And. aEstLotAnt[nCntEstAnt, 6] == aIdePer[nCntIdePer, 3]+aIdePer[nCntIdePer, 1]//aIdePer -> aEstLotAnt | ideDmDev + codCateg + tpAcConv + perRef
											For nCntRemAnt := 1 To Len(aRemPerAnt)
												If aRemPerAnt[nCntRemAnt, 3] == aEstLotAnt[nCntEstAnt, 5] .And. aRemPerAnt[nCntRemAnt, 4] == aEstLotAnt[nCntEstAnt, 6]+aEstLotAnt[nCntEstAnt, 1]+aEstLotAnt[nCntEstAnt, 2]+aEstLotAnt[nCntEstAnt, 3]//aEstLotAnt -> aRemPerAnt | ideDmDev + codCateg + tpAcConv + perRef + tpInsc + nrInsc + codLotacao
													For nCntIteAnt := 1 To Len(aItRemAnt)
														If aItRemAnt[nCntIteAnt, 7] == aRemPerAnt[nCntRemAnt, 3] .And. aItRemAnt[nCntIteAnt, 8] == aRemPerAnt[nCntRemAnt, 4]+aRemPerAnt[nCntRemAnt, 1]//aRemPerAnt -> aItRemAnt | ideDmDev + codCateg + tpAcConv + perRef + tpInsc + nrInsc + codLotacao + matricula
															oExcel:AddRow(cAba4, cTabela4, { SubStr(aDmDev[nCntDmDev, 1], 1, FwGetTamFilial), aEvtRemun[nCntEvRem, 1], aEvtRemun[nCntEvRem, 2], aDmDev[nCntDmDev, 2], aDmDev[nCntDmDev, 1], Iif( ValType(aIdeADCAnt[nCntIdeAdc, 1]) == "C", dToC( sToD(aIdeADCAnt[nCntIdeAdc, 1]) ), ""), aIdeADCAnt[nCntIdeAdc, 2], aIdeADCAnt[nCntIdeAdc, 3], Iif( ValType(aIdeADCAnt[nCntIdeAdc, 4]) == "C", dToC( sToD(aIdeADCAnt[nCntIdeAdc, 1]) ), ""), aIdePer[nCntIdePer, 1], aEstLotAnt[nCntEstAnt, 1]+" - "+aEstLotAnt[nCntEstAnt, 2], aEstLotAnt[nCntEstAnt, 3], aDmDev[nCntDmDev, 4]+" - "+aRemPerAnt[nCntRemAnt, 1], aRemPerAnt[nCntRemAnt, 2], aItRemAnt[nCntIteAnt, 1], aItRemAnt[nCntIteAnt, 16], Val(aItRemAnt[nCntIteAnt, 6]), aItRemAnt[nCntIteAnt, 9], aItRemAnt[nCntIteAnt, 10], aItRemAnt[nCntIteAnt, 11], aItRemAnt[nCntIteAnt, 12], aItRemAnt[nCntIteAnt, 13], aItRemAnt[nCntIteAnt, 14], aItRemAnt[nCntIteAnt, 15] } )
														EndIf
													Next nCntIteAnt
												EndIf
											Next nCntRemAnt
										EndIf
									Next nCntEstAnt
								EndIf
							Next nCntIdePer
						EndIf
					Next nCntIdeAdc
				EndIf
			Next nCntInfAnt
		EndIf
	Next nCntDmDev
Next nCntEvRem

For nCntFDem := 1 To Len(aFuncDem)
	oExcel:AddRow(cAba5, cTabela5, { aFuncDem[nCntFDem, 1], aFuncDem[nCntFDem, 2], aFuncDem[nCntFDem, 3] } )
Next nCntFDem

For nCntIncons := 1 To Len(aRelIncons)
	oExcel:AddRow(cAba6, cTabela6, { aRelIncons[nCntIncons, 1], aRelIncons[nCntIncons, 2], aRelIncons[nCntIncons, 3] } )
Next nCntIncons

oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0134), OemToAnsi(STR0139) } )//"Tipos de Estabelecimento"##"1-CNPJ | 2-CPF | 3-CAEPF | 4-CNO | 5-CGC"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0135), OemToAnsi(STR0140) } )//"Indicador Simples"##"1-Contribui��o Substitu�da Integralmente | 2-Contribui��o n�o substitu�da | 3-Contribui��o n�o substitu�da concomitante com contribui��o substitu�da"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0136), OemToAnsi(STR0141) } )//"Tipo da Verba"##"1-Provento | 2-Desconto | 3-Base (Provento) | 4-Base (Desconto)"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0137), OemToAnsi(STR0142) } )//"Tipos de Dependente"##"01-C�njuge | 02-Companheiro(a) com o(a) qual tenha filho ou viva h� mais de 5 (cinco) anos ou possua Declara��o de Uni�o Est�vel | 03-Filho(a) ou enteado(a) | 04-Filho(a) ou enteado(a), universit�rio(a) ou cursando escola t�cnica de 2� grau"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0137), OemToAnsi(STR0143) } )//"Tipos de Dependente"##"06-Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial | 07-Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, universit�rio(a) ou cursando escola t�cnica de 2� grau, do(a) qual detenha a guarda judicial"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0137), OemToAnsi(STR0144) } )//"Tipos de Dependente"##"09-Pais, av�s e bisav�s | 10-Menor pobre do qual detenha a guarda judicial | 11-A pessoa absolutamente incapaz, da qual seja tutor ou curador | 12-Ex-c�njuge | 99-Agregado/Outros"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0138), OemToAnsi(STR0145) } )//"Indicativo de Tipo de Recolhimento MV"##"1-O declarante aplica a al�quota de desconto do segurado sobre a remunera��o por ele informada (o percentual da al�quota ser� obtido considerando a remunera��o total do trabalhador)"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0138), OemToAnsi(STR0146) } )//"Indicativo de Tipo de Recolhimento MV"##"2-O declarante aplica a al�quota de desconto do segurado sobre a diferen�a entre o limite m�ximo do sal�rio de contribui��o e a remunera��o de outra(s) empresa(s) para as quais o trabalhador informou que houve o desconto"
oExcel:AddRow(cAba7, cTabela7, { OemToAnsi(STR0138), OemToAnsi(STR0147) } )//"Indicativo de Tipo de Recolhimento MV"##"3- O declarante n�o realiza desconto do segurado, uma vez que houve desconto sobre o limite m�ximo de sal�rio de contribui��o em outra(s) empresa(s)"

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

/*/{Protheus.doc} fNumId()
Fun��o que busca NumID na SRK
@type function
@author lidio.oliveira
@since 12/12/2019
@version 1.0
@param cChave		= Filial + Matr�cula + Verba
@param cDataMin		= Data de m�nima de pesquisa
@return cNumId		= Retorna NumID
/*/
Static Function fNumId( cChave, cDataMin)

Local cNumId	:= ""
Local aArea		:= GetArea()

DEFAULT cChave		:= ""
DEFAULT cDataMin	:= ""

dbSelectArea( "SRK" )
SRK->(dbSetOrder(1))
If SRK->( Dbseek( cChave ) )
	If !Empty(SRK->RK_NUMID) .And. !Empty(SRK->RK_MESDISS)
		cNumId := SRK->RK_NUMID
	EndIf
EndIf

RestArea(aArea)

Return cNumId

/*/{Protheus.doc} fBuscaRJJ
Pesquisa os processos cadastrados para o funcion�rio na tabela RJJ
@type      	Static Function
@author Allyson Mesashi
@since 04/03/2020
@version	1.0
@param cCPF			= CPF do funcion�rio
@return aProc		= Processo do Funcion�rio
/*/
Static Function fBuscaRJJ( cCPF, cPeriodo )

Local aProc		:= {}

RJJ->( dbSetOrder(2) )
If RJJ->( dbSeek( cCPF ) )
	While RJJ->( !EoF() ) .And. RJJ->RJJ_CPF == cCPF
		If RJJ->RJJ_COMPET <= cPeriodo
			If aScan( aProc, { |x| x[1]+x[2]+x[3] } ) == 0
				aAdd( aProc, { RJJ->RJJ_TP, RJJ->RJJ_NRPROC, RJJ->RJJ_CSUSP }  )
			EndIf
		EndIf
		RJJ->( dbSkip() )
	EnddO
EndIf

Return aProc

//------------------------------------------------------------------
/*/{Protheus.doc} fAjuComp
Funcao que retorna se algumas das verbas do roteiro tem natureza de ajuda compensatoria

@author		Silvio C. Stecca
@since		27/07/2020
@version	1.0
@obs

Alteracoes Realizadas desde a Estruturacao Inicial
Data         Programador          Motivo
/*/
//------------------------------------------------------------------
Static Function fAjuComp(cRoteiro, cFilRot, cMatRot, cPer1200)

	Local lRet		:= .F.
	Local cQryRot	:= ""
	Local cArqRot	:= GetNextAlias()

	cQryRot := "SELECT RV_NATUREZ"																	+ CRLF
	cQryRot += "FROM " + RetSqlName('SRC') + " RC"													+ CRLF
	cQryRot += "LEFT JOIN " + RetSqlName('SRV') + " RV ON RV_COD = RC_PD AND RV.D_E_L_E_T_ = ' '"	+ CRLF
	cQryRot += "WHERE"																				+ CRLF
	cQryRot += "RC_ROTEIR = '" + cRoteiro + "'"														+ CRLF
	cQryRot += "AND RC_FILIAL = '" + cFilRot + "'"													+ CRLF
	cQryRot += "AND RC_MAT = '" + cMatRot + "'"														+ CRLF
	cQryRot += "AND RC_PERIODO = '" + cPer1200 + "'"												+ CRLF
	cQryRot += "AND RC.D_E_L_E_T_ = ' '"															+ CRLF
	cQryRot += "UNION"																				+ CRLF
	cQryRot += "SELECT DISTINCT RV_NATUREZ"															+ CRLF
	cQryRot += "FROM " + RetSqlName('SRD') + " RD"													+ CRLF
	cQryRot += "LEFT JOIN " + RetSqlName('SRV') + " RV ON RV_COD = RD_PD AND RV.D_E_L_E_T_ = ' '"	+ CRLF
	cQryRot += "WHERE"																				+ CRLF
	cQryRot += "RD_ROTEIR = '" + cRoteiro + "'"														+ CRLF
	cQryRot += "AND RD_FILIAL = '" + cFilRot + "'"													+ CRLF
	cQryRot += "AND RD_MAT = '" + cMatRot + "'"														+ CRLF
	cQryRot += "AND RD_PERIODO = '" + cPer1200 + "'"												+ CRLF
	cQryRot += "AND RD.D_E_L_E_T_ = ' '"															+ CRLF

	cQryRot := ChangeQuery(cQryRot)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQryRot), cArqRot, .T., .T.)

	dbSelectArea(cArqRot)
	dbGoTop()

	Do While (cArqRot)->(!Eof())
		If (cArqRot)->RV_NATUREZ == "1619"
			lRet :=  .T.
			Exit
		EndIf

		(cArqRot)->(dbSkip())
	EndDo

	If Select(cArqRot) > 0
		(cArqRot)->(dbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} fRJ5Filt
Pesquisa as lota��es com campo da filial do trabalhador preenchidos
@type      	Static Function
@author Silvia Taguti
@since 04/11/2020
@version	1.0
@return aRJ5Fil
/*/

Static Function fRJ5Filt()
Local aAreaRJ5   	:= RJ5->(GetArea())
Local aRJ5Fil   := {}
Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0

RJ5->(dbSetOrder(7))
RJ5->(dbGotop())

	While RJ5->(!Eof()) .AND. RJ5->RJ5_FILIAL == XFILIAL('RJ5')
		If lFilT .And. !Empty(RJ5->RJ5_FILT)
			AADD(aRJ5Fil,{RJ5->RJ5_FILIAL, RJ5->RJ5_CC, RJ5->RJ5_FILT, RJ5->RJ5_COD, RJ5->RJ5_INI})
		Endif
		RJ5->(dbSkip())
	EndDo

RJ5->(dbGotop())

RestArea(aAreaRJ5)

Return aRJ5Fil

/*/{Protheus.doc} fGetDtPgto
Retorna a data de pagamento do cadastro de per�odos
@type      	Static Function
@author lidio.oliveira
@since 05/01/2021
@version	1.0
@param cFilPesq		= Filial de Pesquisa
@param cProc		= C�digo do processo
@param cPeriodo		= Pe�odo de pequisa no formato (AAAAMM)
@param cSemana		= Semana
@param cRot			= Roteiro para ser pesquisado
@return dDtPgto		= Data de pagamento no cadastro de per�odos
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

//-------------------------------------------------------------------
/*/{Protheus.doc} fDiasConv()
Fun��o que retorna os dias de convoca��o no mes da rescisao
@type function
@author lidio oliveira
@since 26/04/2021
@version 1.0
@param dDataDe		= Data Inicial do Periodo
@param dDataMin		= Data Final do Periodo/Data Rescis�o
@return aDiasConv	= Retorna array com todos os dias de convoca��o
/*/
//-------------------------------------------------------------------
Static Function fDiasConv(dDataDe, dDataAte, cAnoMes)

Local aConvoc 		:= {}
Local nDiaConv 		:= 0
Local aDiasConv 	:= {}
Local nC			:= 0
Local nInt 			:= 0

Default dDataDe 	:= Ctod("")
Default dDataAte 	:= Ctod("")
Default cAnoMes		:= ""

Private lContrInt	:= If(SRC->(ColumnPos( 'RC_CONVOC' )) > 0,.T.,.F.)
Private VAL_SALMIN	:= 0
Private cProcesso	:= SRA->RA_PROCES

	nPosTab := fPosTab("S003", cAnoMes,">=", 4, cAnoMes,"<=", 5)

	If nPosTab > 0
		VAL_SALMIN := fTabela("S003", nPosTab, 6)
	EndIf

	aConvoc := BuscaConv(dDataDe, dDataAte)

	If Len(aConvoc) > 0
		For nC := 1 to Len(aConvoc)
			nDiaConv := Day(aConvoc[nC,2])
			aAdd( aDiasConv, StrZero(nDiaConv,2) )
			If aConvoc[nC,5] > 0
				For nInt:= 1 to aConvoc[nC,5]
					If nDiaConv+1 <= Day(aConvoc[nC,3])
						nDiaConv := nDiaConv+1
						aAdd( aDiasConv, StrZero(nDiaConv,2) )
					Endif
				Next nY
			Endif
		Next nx
	Endif

Return aDiasConv

/*/{Protheus.doc} fm036GetFer
Fun��o respons�vel por pesquisar e gerar os dados de ferias nas tabelas SRH e SRR para geracao do evento S-1200
@Author.....: Lidio Oliveira
@Since......: 29/04/2021
@Version....: 1.0
@Param......: (char) - cFilFun - Filial do funcionario para a pesquisa nas tabelas SRH e SRR
@Param......: (char) - cMatFun - Matricula do funcionario para a pesquisa
@Param......: (char) - cDtPesqI - Per�odo inicial de pesquisa
@Param......: (char) - cDtPesqF - Per�odo final de pesquisa
@Param......: (char) - cCateg - Categoria do funcionario
@Param......: (char) - cPdFer - string para armazenamento das verbas de ferias avaliadas
@Return.....: (array) - aFer - Array de retorno com os dados de ferias do funcionario
/*/
Static Function fm036GetFer( cFilFun, cMatFun, cDtPesqI, cDtPesqF, cCateg, cPdFer)

Local cAliasSRH	:= "QSRH"
Local nNumReg	:= 0
Local aFer		:= {}
Local nPos		:= 0

If ( Select( cAliasSRH ) > 0 )
	( cAliasSRH )->( dbCloseArea() )
EndIf

If __oSt18 == Nil
	__oSt18 := FWPreparedStatement():New()
	cQrySt := "SELECT Count(*) AS NUMREG "
	cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
	cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
	cQrySt += 		"SRH.RH_MAT = ? AND "
	cQrySt += 		"SRH.RH_DTRECIB BETWEEN ? AND ? AND "
	cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
	cQrySt := ChangeQuery(cQrySt)
	__oSt18:SetQuery(cQrySt)
EndIf
__oSt18:SetString(1, cFilFun)
__oSt18:SetString(2, cMatFun)
__oSt18:SetString(3, cDtPesqI)
__oSt18:SetString(4, cDtPesqF)
cQrySt := __oSt18:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

nNumReg := (cAliasSRH)->NUMREG
( cAliasSRH )->( dbCloseArea() )

If nNumReg > 0
	If __oSt19 == Nil
		__oSt19 := FWPreparedStatement():New()
		cQrySt := "SELECT RH_FILIAL,RH_MAT,RH_PROCES,RH_PERIODO,RH_ROTEIR,RH_DTRECIB,RH_DFERIAS,RH_DATAINI,RH_DTRECIB "
		cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
		cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
		cQrySt += 		"SRH.RH_MAT = ? AND "
		cQrySt += 		"SRH.RH_DTRECIB BETWEEN ? AND ? AND "
		cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt19:SetQuery(cQrySt)
	EndIf
	__oSt19:SetString(1, cFilFun)
	__oSt19:SetString(2, cMatFun)
	__oSt19:SetString(3, cDtPesqI)
	__oSt19:SetString(4, cDtPesqF)
	cQrySt := __oSt19:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

	DbSelectArea("SRR")
	DbSetOrder(RetOrder("SRR","RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC"))

	While (cAliasSRH)->(!Eof())

		aAdd( aFer, { cFilFun, cMatFun, SRA->RA_CIC, (cAliasSRH)->(RH_DATAINI), (cAliasSRH)->(RH_DTRECIB), {}} )

		If SRR->( DbSeek( (cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->(RH_DATAINI) ) )

			nPos := Len(aFer)

			While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA) == (cAliasSRH)->RH_FILIAL+(cAliasSRH)->RH_MAT+"F"+(cAliasSRH)->RH_DATAINI )

				//N�o inclui a verba de l�quido no array de f�rias.
				If RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_CODFOL' ) == "0102"
					SRR->(DbSkip())
					Loop
				EndIf

				aAdd(aFer[nPos,6],{ SRR->RR_PERIODO, SRR->RR_CC, SRR->RR_PD, SRR->RR_PERIODO, SRR->RR_ROTEIR, SRR->RR_HORAS, SRR->RR_VALOR, dtos(SRR->RR_DATAPAG), 0, "FER", "01", SRR->RR_NUMID})

				SRR->(DbSkip())
			EndDo

		EndIf

		(cAliasSRH)->(DbSkip())
	EndDo

EndIf

Return( aFer )

/*/{Protheus.doc} fBuscaPLR
Verifica se dados de PLR foram gerados/informado pelo pr�prio roteiro de PLR
@author raquel.andrade
@since 03/09/2021
/*/
Function fBscPLR(cCompete)
Local aVerbasFunc 	:= {}
Local aPeriodo		:= {}
Local aVerbaPLR		:= {}
Local lRet			:= .F.
Private cProcesso	:= (cSRAAlias)->RA_PROCES

Default cCompete	:= ""

fRetPerComp(SubStr(cCompete, 5, 2), SubStr(cCompete, 1, 4), xFilial(("RCH"), (cSRAAlias)->RA_FILIAL), (cSRAAlias)->RA_PROCES, fGetCalcRot("F"), NIL, NIL, @aPeriodo)

If Len(aPeriodo) > 0
	aAdd(aVerbaPLR, {aCodFol[151,1]}) // Distribui��o de Lucros
	aAdd(aVerbaPLR, {aCodFol[152,1]}) // Imposto de Renda Distrib. Lucros
	aAdd(aVerbaPLR, {aCodFol[835,1]}) // Base IRF PLR
	aAdd(aVerbaPLR, {aCodFol[836,1]}) // L�quido PLR
	aAdd(aVerbaPLR, {aCodFol[300,1]}) // Deduc.Dependente Distr. Lucro
	aAdd(aVerbaPLR, {aCodFol[1328,1]}) // Imposto de Renda Distrib. Lucros
	aVerbasFunc := RetornaVerbasFunc((cSRAAlias)->RA_FILIAL, (cSRAAlias)->RA_MAT, '','' , aVerbaPLR, aPeriodo, aPeriodo , Nil, Nil , .T., Nil , Nil ,)
EndIf

//Possui verbas de PLR
If Len(aVerbasFunc) > 0
	lRet := .T.
EndIf

Return lRet
/*/{Protheus.doc} setInfCmpl
Adiciona informa��es da tag infoComplem no array aInfCompl
@author martins.marcio
@since 22/11/2021
/*/
Function setInfCmpl(aInfCompl)
	Local cNomAux := Iif(!Empty(AllTrim(SRA->RA_NOMECMP)), SubStr(SRA->RA_NOMECMP, 1, 60), AllTrim(SRA->RA_NOME) )
	Local cNomTrab := FSubst(cNomAux)
	cNomTrab := IIf(lMiddleware,AllTrim(cNomTrab),cNomTrab)
	aAdd( aInfCompl, { cNomTrab, SRA->RA_NASC, (cSRAAlias)->RA_CIC } )//<infoComplem> -> <nmTrab>, <dtNascto>
Return

/*/{Protheus.doc} fCatEstat
Verifica se a categoria e o Regime de Previdencia s�o de estatutarios
@author Silvia Taguti
@since 14/03/2022
/*/
Function fCatEstat(lS1202, cTpPrevi, cCatefd, cCompEst,cContrib, cTpFolha)

Local lRet 		 := .F.
Local cPer1202		:= SubStr(cCompEst, 3, 4) + SubStr(cCompEst, 1, 2)
Local cCatS1200     := "101|102|103|104|105|106|107|108|111|"

Default lS1202	 := .F.
Default cTpPrevi := ""
Default cCatefd  := ""
Default cCompEst := ""
Default cContrib := ""
Default cTpFolha := "1"

If lS1202
  	If ((cTpPrevi= "2" .And. cCatefd $ "301|302|303|304|306|307|309|310|312|401|410") .Or. cCatefd $ "308|311|313" .OR.;
		(cCatefd == "305" .AND. If(cTpFolha=="1", cPer1202 >= "202204", SubStr(cPer1202, 1, 4) >= "2022")))
		lRet := .T.
	Endif
Else
	 If ((cTpPrevi $ "1*3* " .And. cCatefd $ cCatS1200 + "301|302|303|304|306|307|309|310|312|401|410") .Or.;
		cCatefd $ fCatTrabEFD("AVU")+"501|" +cContrib+fCatTrabEFD("BOL") .Or.(cCatefd=="305" .And. If(cTpFolha=="1",cPer1202 <"202204",SubStr(cPer1202,1,4) <"2022")))
		lRet := .T.
	Endif
Endif

Return lRet
