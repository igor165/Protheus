#INCLUDE "PROTHEUS.CH"

// ********************************
// Controle de multiplas moedas  *
// ********************************
Static lMultMoed := .T.
Static __lVldIndice := Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcSD�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo de depreciacao diferenciado: Soma de Digitos         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/

Function ATFCalcSD(dDataCalc, dINDEPR, nPeriodos, cPeriodo, aTaxaMes)
Local nTaxa	:= 0
Local nSD	:= nPeriodos * (nPeriodos + 1) / 2  // = 1+2+3+...+nPeriodos
Local nPC	:= 0
Local i		:= 0

cPeriodo := Iif( Empty(cPeriodo),"0",cPeriodo)
//����������������������������������������������������������������������Ŀ
//�F�rmula                                                               �
//�                                                                      �
//�[ ( nPeriodos - PC ) + 1 ] / SD                                       �
//�                                                                      �
//�Onde                                                                  �
//�                                                                      �
//�n = Periodo (em meses ou anos)                                        �
//�PC = Periodo de Calculo (1 para a 1 depreciacao, 2 para a segunda ...)�
//�SD = Soma dos Digitos ( 5 -> 1+2+3+4+5 = 15 )                         �
//������������������������������������������������������������������������

If cPeriodo == "0" // Mensal
	nPc := ( (Year(dDataCalc) * 12 + Month(dDataCalc) ) - ( Year(dINDEPR) * 12 + Month (dINDEPR) ) ) + 1
Else // Anual
	nPc := ( Year(dDataCalc) - Year( dINDEPR ) ) + 1
EndIf

nTaxa	:= ( ( nPeriodos - nPc ) + 1 ) / nSD

For i := 1  To Len(aTaxaMes)
	aTaxaMes[i] := nTaxa
Next i


Return nTaxa


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcRS�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo de depreciacao diferenciado: Reducao de Saldos      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ATFCalcRS(nVlSalv, nVorig, nPeriodos, nDepAcm, aTaxaMes)

Local nTaxa		:= 0
Local i			:= 0

If nVlSalv + nDepAcm  >= nVorig
	nTaxa := 0
Else
	nTaxa := 1 - ( ( nVlSalv / nVorig ) ** (1/nPeriodos ) )
Endif

For i := 1  To Len(aTaxaMes)
	aTaxaMes[i] := nTaxa
Next i

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcVR�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao pela razao entre as unidades ���
���          � produzidas no mes pelas produzidas no ano                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function ATFCalcVR(nVlrPeriodo, nVlrRef, aTaxaMes)

//Local nTaxa := ( (nVlrPeriodo / nVlrRef ) * 12 ) /100
Local nTaxa := nVlrPeriodo / nVlrRef
Local i			:= 0

For i := 1  To Len(aTaxaMes)
	aTaxaMes[i] := nTaxa
Next i

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcSA�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao pelo metodo de soma dos anos ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFCalcSA( nPeriodos, aTaxaMes,dDataCalc,dIndepr )

Local i		:= 0
Local nTaxa := 0
Local nAno 	:= 0

Default dIndepr := SN3->N3_DINDEPR

nAno := Year(dDataCalc) - Year(dIndepr)

If Month(dDataCalc) < Month(dIndepr)
	nAno --
EndIf

nPeriodos := nPeriodos / 12

//nTaxa := (((nPeriodos - nAno) / (( nPeriodos * ( nPeriodos + 1)) / 2))/12)/100
nTaxa := (((nPeriodos - nAno) / (( nPeriodos * ( nPeriodos + 1)) / 2))/12)

For i := 1  To Len(aTaxaMes)
	aTaxaMes[i] := nTaxa
Next i

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcQC�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao pelo metodo linear (quotas   ���
���          � constantes)                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFCalcQC( cPeriodo, aTaxaMes)
Local i

Local nTaxa := 0
Default cPeriodo := ""

cPeriodo := Iif( Empty(cPeriodo),"0",cPeriodo)

For i := 1 to Len(aTaxaMes)
	nTaxa := aTaxaMes[i] / 100
	If cPeriodo == "0" // Mensal
		nTaxa := nTaxa / 12
	EndIf
	aTaxaMes[i] := nTaxa
Next i

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcEX�Autor  �Microsiga           � Data �  18/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao de exaustao pela razao 	  ���
���          � entre as unidades produzidas no mes pelas produzidas no ano���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFCalcEX(nVlrPer,nVlrRef,aTxDepr)
Local nTaxa := nVlrPer / nVlrRef
Local nI		:= 0
Default nVlrPer	:= 0
Default nVlrRef	:= 0
Default aTxDepr := {0,0,0,0,0}

If  nVlrPer > 0 .and. nVlrRef > 0
	nTaxa := nVlrPer / nVlrRef
	For nI := 1  To Len(aTxDepr)
		aTxDepr[nI] := nTaxa
	Next nI
EndIf
Return




/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FCalcAVP � Autor � Mauricio Pequim Jr.   � Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de calculo de ajuste a valor presente (AVP)         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FCalcAVP(ExpC1,ExpC2,ExpN3,ExpD4,ExpD5,ExpN6,ExpC7,ExpC8)  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01=Tipo Processo (C,A)						                 ���
���          � 			[C] - Constituicao						              ���
���          � 			[A] - Ajuste/Apropriacao				              ���
���          � ExpN02=Taxa AVP		                                      ���
���          � ExpC03=Codigo do Indice (tabela de Indices)	              ���
���          � ExpN04=Valor do Indice				                          ���
���          � ExpC05=Periodicidade da Taxa		                          ���
���          � ExpD06=Data do processo				                          ���
���          � ExpN07=Vlr Presente (referencia(retornada por essa funcao))���
���          � ExpN08=Vlr AVP      (referencia(retornada por essa funcao))���
���          � ExpD09=Data Realizacao do Bem (N1->N1_DTAVP)               ���
���          � ExpD10=Indica se o per�odo a ser considerado � cheio       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//AVP
*/
Function AFCalcAVP(cTipoProc,nTaxa,cCodInd,nValItem,cPeriodo,dDtProc,nValVP,nValAVP,dDataFin,lPerCheio)

Local lRet := .F.
Local nDias := 1			//Diario
Local nDiasAVP := 0
Local nValAvpAnt := 0
Local dDataINI	:= dDatabase
Local nDecimais := TamSX3("FNF_VALOR")[2]

DEFAULT cTipoProc	:= ""
DEFAULT nTaxa		:= 0
DEFAULT cCodInd	:= ""
DEFAULT nValItem	:= 0
DEFAULT cPeriodo	:= ""
DEFAULT dDtProc	:= dDataBase
DEFAULT nValVp		:= 0
DEFAULT nValAVp	:= 0
DEFAULT dDataFin	:= dDataBase
DEFAULT lPerCheio := .F.

chkFile("FNF")
chkFile("FIT")


If !Empty(cCodInd) .And. Empty(nTaxa)
	nTaxa := AtfRetInd(cCodInd,dDtProc)	 
EndIf 

If Empty(cPeriodo)
	cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + cCodInd )
EndIf

IF !Empty(cTipoProc)	.and.	;
	( nTaxa > 0 )
	
	//Se nao for constituicao
	//Posiciono o arquivo de movimentos no registro de constituicao ativo (TABELA FNF - TIPO 1 - STATUS 1)
	//A Variacao neste caso sera calculada pela diferenca entre
	//Valor Presente Atual - Valor Presente Anterior.
	//No caso de constituicao, nao havera o calculo de ajuste, mas de constituicao
	//C = Constituicao
	If cTipoProc == "C"
	
		//Posiciono o alias para buscar o valor original do titulo
		nValBem 		:= nValItem
		nValAvpAnt	:= nValItem
		dDataIni		:= dDtProc
	
	ElseIf cTipoProc == "A"
		nValBem		:= FNF->FNF_BASE
		nValAvpAnt	:= FNF->(FNF_AVPVLP + FNF_ACMAVP)
		dDataIni		:= If(dDtProc > SN1->N1_DTAVP, SN1->N1_DTAVP , dDtProc )
	Endif

	//Conversao da Taxa do periodo inicial para dias
	If nTaxa	> 0
		
		DO CASE
			CASE cPeriodo = "1"	//Diario
				nDias := 1
			CASE cPeriodo = "2"	//Mensal
				nDias := 30
			CASE cPeriodo = "3"	//Trimestra
				nDias := 90
			CASE cPeriodo = "4"	//Semestral
				nDias := 180
			CASE cPeriodo = "5"	//Anual
				nDias := IIF(lPerCheio,360,365) 
			OTHERWISE
				nDias := 0
		ENDCASE
		
		//Converto a Taxa informada para taxa diaria
		nIndDia := (1+(nTaxa/100))**(1/nDias) //Taxa equivalente
		
		//Calculo o numero de dias para AVP
		nDiasAvp := AtfDiasAvp(dDataIni,dDataFin,lPerCheio)
		
		//Valor Presente
		nValVP	:= nValBem / (nIndDia**nDiasAVP)
		
		//Valor do Ajuste Valor Presente
		//Se for Constituicao AVP = Valor do titulo - Valor presente na data de emissao
		//Se for processo de Ajuste AVP = Valor presente na data de processo - Valor AVP anterior (FIM ou FIP)
		If cTipoProc == "C"
			nValAVP	:= nValBem - nValVP
		Else
			nValAVP	:= nValVP - nValAvpAnt
		Endif
		
		nValAvp := Round(NoRound(nValAVP,nDecimais+1),nDecimais)
		
		lRet := .T.
		
	Endif
	
Endif

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AFCalcTx  � Autor � Alvaro Camillo Neto    � Data � 22/02/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina que calcula taxa de AVP a partir dos dados de valor       ���
             presente planejado,valor total e datas de AVP
�������������������������������������������������������������������������Ĵ��
//AVP
*/
Function AFCalcTx(cCodInd,nValBem,nValAVP,dDataIni,dDataFin)

Local nTaxa    := 0
Local cPeriodo := ""
Local nDias    := 0
Local nVP      := nValBem - nValAVP 

chkFile("FNF")
chkFile("FIT")

cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + cCodInd )

DO CASE
	CASE cPeriodo = "1"	//Diario
		nDias := 1
	CASE cPeriodo = "2"	//Mensal
		nDias := 30
	CASE cPeriodo = "3"	//Trimestral
		nDias := 90
	CASE cPeriodo = "4"	//Semestral
		nDias := 180
	CASE cPeriodo = "5"	//Anual
		nDias := 365
	OTHERWISE
		nDias := 0
ENDCASE

//Calculo o numero de dias para AVP
nDiasAvp := AnoBissexto(dDataIni,dDataFin)

nFatorExp := 1/nDiasAVP 

nIndDia := ( ( nValBem / nVP  ) ** nFatorExp ) - 1
		
//Converto a Taxa diaria para taxa informada
nTaxa := ( ( 1 + nIndDia)**nDias ) - 1

nTaxa := nTaxa * 100

Return nTaxa

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AnoBissexto � Autor � Mauricio Pequim Jr.� Data � 16/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o numero de Anos Bissextos num periodo de datas   ���
���          � retirando do numero de dias um dia para cada ano bissexto  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AnoBissexto(dDataIni,dDataFin)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD01= Data inicial do periodo                            ���
���          � ExpD02= Data final do periodo    			                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//AVP
*/
Static Function AnoBissexto(dDataIni,dDataFin)

Local nDias := dDataFin - dDataIni
Local nAnos	:= Year(dDataFin) - Year(dDataIni)
Local nX		:= 0
Local nYear	:= Year(dDataIni)

For nX := 1 to nAnos
	If (nYear % 4 = 0 .And. nYear % 100 <> 0) .Or. (nYear % 400 = 0)
		nDias -= 1
	EndIf
	nYear++
Next

Return nDias

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AFSumAvpBx� Autor � Mauricio Pequim Jr.   � Data � 31/10/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a soma dos registros Tipo 10 e Tipo 14 de mesmo tipo���
���          �  de saldo																  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AFSumAvpBx(cCBase,cItem,cTpSaldo,aVlrAtual)					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01= Codigo base do bem                                 ���
���          � ExpC02= Item do bem              			                 ���
���          � ExpC03= Tipo do saldo do tipo de bem                       ���
���          � ExpA04= Array contendo os valores a serem demonstrados na  ���
���          � 			tela de baixa do bem										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//AVP
*/
Function AFSumAvpBx(cCBase,cItem,cTpSaldo,aReg14)

Local aArea		:= GetArea()
Local nRecSN3	:= SN3->(RECNO())
Local lRet		:= .F.

DEFAULT cCbase := ""
DEFAULT cItem	:= ""
DEFAULT cTpSaldo := ""
DEFAULT aReg14	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )

If Type("aVlrAtual") != "A"
	aVlrAtual	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Endif

dbSelectArea("SN3")
SN3->(DBSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
If SN3->(MsSeek( xFilial("SN3")+cCBase+cItem+"14"+"0"+cTpSaldo ))

	lRet := .T.

	aVlrAtual[1] += Iif(SN1->N1_PATRIM # "C", SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1, SN3->N3_VORIG1+SN3->N3_AMPLIA1)
	aReg14[1]	 += Iif(SN1->N1_PATRIM # "C", SN3->N3_VORIG1+SN3->N3_VRCACM1+SN3->N3_AMPLIA1, SN3->N3_VORIG1+SN3->N3_AMPLIA1)

	//********************************
	// Controle de multiplas moedas  *
	//********************************
	If lMultMoed
		AtfMultMoe(,,{|x| if(x=1,.F.,aVlrAtual[x] += SN3->(&( "N3_VORIG"+Alltrim(Str(x)) )+&(If(x>9,"N3_AMPLI","N3_AMPLIA")+Alltrim(Str(x))) ) ) })
		AtfMultMoe(,,{|x| if(x=1,.F.,aReg14[x] += SN3->(&( "N3_VORIG"+Alltrim(Str(x)) )+&(If(x>9,"N3_AMPLI","N3_AMPLIA")+Alltrim(Str(x))) ) ) })
	Else
		aVlrAtual[2] += SN3->N3_VORIG2+SN3->N3_AMPLIA2
		aVlrAtual[3] += SN3->N3_VORIG3+SN3->N3_AMPLIA3
		aVlrAtual[4] += SN3->N3_VORIG4+SN3->N3_AMPLIA4
		aVlrAtual[5] += SN3->N3_VORIG5+SN3->N3_AMPLIA5
		
		aReg14[2] += SN3->N3_VORIG2+SN3->N3_AMPLIA2
		aReg14[3] += SN3->N3_VORIG3+SN3->N3_AMPLIA3
		aReg14[4] += SN3->N3_VORIG4+SN3->N3_AMPLIA4
		aReg14[5] += SN3->N3_VORIG5+SN3->N3_AMPLIA5

	EndIf
Endif

RestArea(aArea)

SN3->(dbGoTo(nRecSN3))

Return lRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AFVerTp14 � Autor � Mauricio Pequim Jr.   � Data � 31/10/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se existe tipo 14 ativo                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AFVerTp14(cCBase,cItem,cTpSaldo)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01= Codigo base do bem                                 ���
���          � ExpC02= Item do bem              			                 ���
���          � ExpC03= Tipo do saldo do tipo de bem                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//AVP
*/
Function AFVerTp14(cCBase,cItem,cTpSaldo)

Local aArea		:= GetArea()
Local nRecSN3	:= SN3->(RECNO())
Local lRet		:= .F.

DEFAULT cCbase := ""
DEFAULT cItem	:= ""
DEFAULT cTpSaldo := ""

dbSelectArea("SN3")
SN3->(DBSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
If SN3->(MsSeek( xFilial("SN3")+cCBase+cItem+"14"+"0"+cTpSaldo ))

	lRet := .T.

Endif

RestArea(aArea)

SN3->(dbGoTo(nRecSN3))

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalcIn		�Autor  �Renan Guedes    � Data �  03/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao por �ndice					    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFCalcIn(aTxDepr,cCalcInd,dDataCalc)

Local aAreaFNI := {}
Local aArea    :=GetArea()
Local nX       := 0

Default cCalcInd  := SN3->N3_CODIND
Default dDataCalc := dDataBase

dbSelectArea("SN3")

If __lVldIndice == Nil
	__lVldIndice := .T.
EndIf

//Valida a exist�ncia das tabelas de �ndice
If __lVldIndice
	dbSelectArea("FNI")
	aAreaFNI := FNI->(GetArea())
	FNI->(dbSetOrder(1))		//FNI_FILIAL+FNI_CODIND
	//Verificando se o tipo de indice e informado (1) ou Calculado (2). Caso o tipo de indice seja vazio
	If FNI->(DbSeek( xFilial("FNI") + cCalcInd ))
		If FNI->FNI_MSBLQL != '1' //Bloqueado
			IF FNI->FNI_TIPO == '2'//tipo calculado
				AFDepCurva(@aTxDepr,FNI->FNI_CODIND,dDataCalc)
			Else
				AtfCalInfo(@aTxDepr,FNI->FNI_CODIND,dDataCalc)
			Endif
		Else
			For nX := 1 To Len(aTxDepr)
				aTxDepr[nX] := 0
			Next nX
		EndIf
	Endif
	RestArea(aAreaFNI)
EndIf



RestArea(aArea)
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � ATFCalInFo		�Autor  �Jandir Deodato � Data �  10/10/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � Calcula a taxa de depreciacao por �ndice Tipo 1(informado)  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AtfCalInfo(aTxDepr,cCalcInd,dDataCalc)
Local aAreaFNT			:= {}
Local aAreaFNI			:=FNI->(GetArea())
Local cTipo			:= ""
Local aTaxas			:= {}
Local dDataIni			:= CTOD("")
Local dDataFim			:= CTOD("")
Local dDataTax			:= CTOD("")
Local nRecTax			:= 0
Local nTaxa			:= 0
Local nFator			:= 0
Local nAno				:= 0
Local nDias			:= 0
Local nX				:= 0
Local aArea			:= GetArea()

Default aTxDepr 		:= {0,0,0,0,0}
Default cCalcInd  	:= SN3->N3_CODIND
Default dDataCalc 	:= dDataBase

//Pesquisa o cadastro do �ndice
If FNI->(MsSeek( xFilial("FNI") + cCalcInd ))
	cTipo := AllTrim(FNI->FNI_PERIOD)
	//Verifica se o �ndice est� desbloqueado
	If FNI->FNI_MSBLQL == "2"
			
		dbSelectArea("FNT")
		aAreaFNT := FNT->(GetArea())
			
		Do Case
			//Tipo 1 - di�ria
			Case cTipo == "1"
				//Guarda a data inicial e final do m�s para o range de datas
				dDataIni 	:= DTOS(FirstDay(dDataCalc))
				dDataFim 	:= DTOS(LastDay(dDataCalc))
				//Quantidade de dias do mes
				nDias		:= Day(STOD(dDataFim))
				//Fator de multiplica��o do tipo do �ndice
				nFator		:= nDias			
				//Data inicial de busca pelas taxas
				dDataTax	:= dDataIni

				FNT->(dbSetOrder(2))		//FNT_FILIAL+DTOS(FNT_DATA)+FNT_CODIND+FNT_REVIS
				For nX := 1 To nDias
					//Procura a taxa de cada dia do mes
					If FNT->(MsSeek( FNI->FNI_FILIAL + dDataTax + FNI->FNI_CODIND ))	
						//Procura a �ltima revis�o
						While FNT->(!EoF()) .And. (FNT->FNT_FILIAL == FNI->FNI_FILIAL) .And. (FNT->FNT_DATA == STOD(dDataTax)) .And. (FNT->FNT_CODIND == FNI->FNI_CODIND) 			
							//Verifica se a taxa � v�lida
							If (FNT->FNT_MSBLQL == "2") .And. (FNT->FNT_STATUS = "1")
								//Guarda a posi��o atual para restaurar posteriormente
								nRecTax := FNT->(Recno())
							EndIf
							FNT->(dbSkip())
						EndDo
						//Verifica se encontrou taxa v�lida e adiciona ao array
						If nRecTax > 0
							FNT->(dbGoTo(nRecTax))							
							//Adicona os dados da taxa ao array							
							AADD( aTaxas, {AllTrim(FNT->FNT_DATA) , AllTrim(FNT->FNT_REVIS) , FNT->FNT_TAXA , FNT->(Recno())} )							
						EndIf						
					EndIf
					//Soma 1 dia a data para pesquisar a proxima taxa
					dDataTax := Soma1(dDataTax)
				Next nX
				
			//Tipos 2 - mensal | 3- trimestral | 4 - semestral | 5 - anual
			Case cTipo $ "2|3|4|5|"				
				//Ano do c�lculo
				nAno := Year(dDataCalc)				
				If cTipo == "2"
					//Guarda a data inicial do m�s para a pesquisa
					dDataIni 	:= DTOS(FirstDay(dDataCalc))
					dDataFim 	:= DTOS(LastDay(dDataCalc))
					//Quantidade de dias do mes
					nDias := 30		//Adequa��o ao c�lculo padr�o
					//Fator de multiplica��o do tipo do �ndice
					nFator		:= 30
				ElseIf cTipo == "3"									
					If 		(Month(dDataCalc) >= 1) .And. (Month(dDataCalc) <= 3)		//Primeiro trimestre
						//Quantidade de dias do mes
						nDias := 90
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0101")))
					ElseIf (Month(dDataCalc) >= 4) .And. (Month(dDataCalc) <= 6)		//Segundo trimestre
						//Quantidade de dias do mes
						nDias := 90
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0401")))
					ElseIf (Month(dDataCalc) >= 7) .And. (Month(dDataCalc) <= 9)		//Terceiro trimestre
						//Quantidade de dias do mes
						nDias := 90
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0701")))
					ElseIf (Month(dDataCalc) >= 10) .And. (Month(dDataCalc) <= 12)	//Quarto trimestre
						//Quantidade de dias do mes
						nDias := 90
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"1001")))
					EndIf
					//Fator de multiplica��o do tipo do �ndice
					nFator		:= 30
				ElseIf cTipo == "4"
					If 		(Month(dDataCalc) >= 1) .And. (Month(dDataCalc) <= 6)		//Primeiro semestre
						//Quantidade de dias do mes
						nDias := 180
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0101")))
					ElseIf	(Month(dDataCalc) >= 7) .And. (Month(dDataCalc) <= 12)		//Segundo semestre
						//Quantidade de dias do mes
						nDias := 180
						//Guarda a data inicial do m�s para a pesquisa
						dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0701")))
					EndIf
					//Fator de multiplica��o do tipo do �ndice
					nFator		:= 30
				ElseIf cTipo == "5"		
					//Quantidade de dias do mes
					nDias := 365
					//Guarda a data inicial do m�s para a pesquisa
					dDataIni 	:= DTOS(FirstDay(STOD(cValToChar(nAno)+"0101")))
					//Fator de multiplica��o do tipo do �ndice
					nFator := 30				
				EndIf				
							
				FNT->(dbSetOrder(2))		//FNT_FILIAL+DTOS(FNT_DATA)+FNT_CODIND+FNT_REVIS				
				//Procura a taxa do mes
				If FNT->(MsSeek( FNI->FNI_FILIAL + dDataIni + FNI->FNI_CODIND ))
					//Procura a �ltima revis�o
					While FNT->(!EoF()) .And. (FNT->FNT_FILIAL == FNI->FNI_FILIAL) .And. (FNT->FNT_DATA == STOD(dDataIni)) .And. (FNT->FNT_CODIND == FNI->FNI_CODIND) 			
						//Verifica se a taxa � v�lida
						If (FNT->FNT_MSBLQL == "2")  .And. (FNT->FNT_STATUS = "1")
							//Guarda a posi��o atual para restaurar posteriormente
							nRecTax := FNT->(Recno())
						EndIf
						FNT->(dbSkip())
					EndDo
					//Verifica se encontrou taxa v�lida e adiciona ao array
					If nRecTax > 0
						FNT->(dbGoTo(nRecTax))							
						//Adicona os dados da taxa ao array							
						AADD( aTaxas, {AllTrim(FNT->FNT_DATA) , AllTrim(FNT->FNT_REVIS) , FNT->FNT_TAXA , FNT->(Recno())} )							
					EndIf
				EndIf
		EndCase
		RestArea(aAreaFNT)
	EndIf
EndIf

//Se encontrou �ndice e taxas...
If Len(aTaxas) > 0
	//Soma as taxas
	For nX := 1 To Len(aTaxas)
		nTaxa += aTaxas[nX,3]	
	Next nX
	//Calcula a m�dia aritm�tica da taxa
	Do Case
		Case cTipo == "1"
			nTaxa := (nTaxa / nFator)
		Otherwise
			nTaxa := (nTaxa / nDias) * nFator
	EndCase
	//Atualiza array da taxa de deprecia��o
	For nX := 1 To Len(aTxDepr)
		aTxDepr[nX] := nTaxa
	Next nX
EndIf	
RestArea(aAreaFNI)
RestArea(aARea)	
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AtfDiasAvp  � Autor � Mauricio Pequim Jr.� Data � 16/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o numero de dias para AVP  num periodo de datas   ���
���          � para periodo cheio                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AtfDiasAvp(dDataIni,dDataFin)							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD01= Data inicial do periodo                            ���
���          � ExpD02= Data final do periodo    			              ���
���          � ExpL03= Considera periodo cheio ou padr�o	              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//PRV
*/
Function AtfDiasAvp(dDataIni,dDataFin,lPerCheio)

Local nMonthIni	:= 0	
Local nMonthFin	:= 0
Local nMonthYear:= 0
Local nPerAux	:= 0
Local nDiasAvp	:= 0

Default dDataIni := dDataBase
Default dDataFin := dDataBase
Default lPerCheio := .F.

If lPerCheio
	//Regra de calculo para achar o numero de meses
	//Data Inicial = 01/02/12
	//Data Final   = 30/06/13
	//nPerAux = ((Mes Final + 1) - Mes Inicial) + ((Ano Final - Ano Inicial) * 12)
	//nPerAux = ((6 + 1) - 2) + ((2013 - 2012) * 12)
	//nPerAux = ((7) - 2) + ((1) * 12)
	//nPerAux = (5) + (12)
	//nPerAux = 17 meses

	nMonthIni  := Month(dDataIni)							//Mes data inicial
	nMonthFin  := Month(dDataFin)+1					  		//Mes data final + 1
	nMonthYear := (Year(dDataFin) - Year(dDataIni)) * 12	//diferen�a entre o ano inicial e o final 
															//(para cada ano, somo 12 meses)
	nPerAux  := (nMonthFin - nMonthIni) + nMonthYear
	nDiasAvp := nPerAux*30
Else	
	nDiasAvp := AnoBissexto(dDataIni,dDataFin)
Endif

Return nDiasAvp
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    � AFDepCurva		�Autor  �Alvaro Camillo Neto   �  10/10/12���
�������������������������������������������������������������������������͹��
���Desc.     � Busca a Curva do mes da baixa						        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AFDepCurva(aTxDepr,cIndice,dDataCalc)
Local aArea    := GetArea()
Local aAreaFNI := FNI->(GetArea())
Local cQuery   := ""
Local cTab     := GetNextAlias()
Local nIndTot  := 0
Local aAreaFNT := FNT->(GetArea())
Local nX       := 0
Local nTaxa    := 0
Local cRev     := AFXIndRev(cIndice)

dDataCalc := FirstDay(dDataCalc)
FNI->(dbSetOrder(1)) //FNI_FILIAL+FNI_CODIND+FNI_REVIS
FNT->(dbSetOrder(3))//FNT_FILIAL+FNT_CODIND+DTOS(FNT_DATA)+FNT_REVIS

FNI->(dbSeek(xFilial("FNI") + cIndice + cRev))

// Somat�rio total da curva de trafego
cQuery   += " SELECT "
cQuery   += " SUM(FNT_TAXA) TOTTAXA"
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_DATA >= '"+DTOS(dDataCalc)+"' AND "
cQuery   += " FNT_DATA <= '"+DTOS(LastDay(FNI->FNI_CURVFI))+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND  "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)
If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->TOTTAXA > 0
	nIndTot:= (cTab)->TOTTAXA
Endif


// Indice de demanda do per�odo atual
cQuery   := " SELECT "
cQuery   += " FNT_TAXA "
cQuery   += " FROM " + RetSQLTab("FNT")
cQuery   += " WHERE "
cQuery   += " FNT_FILIAL = '"+xFilial("FNT")+"' AND "
cQuery   += " FNT_CODIND = '"+cIndice+"' AND "
cQuery   += " FNT_MSBLQL = '2' AND "
cQuery   += " FNT_STATUS = '1'  AND "
cQuery   += " FNT_DATA = '"+DTOS(dDataCalc)+"'  AND "
cQuery   += " D_E_L_E_T_ = ' ' "
cQuery   := ChangeQuery(cQuery)
If Select(cTab)>0
	(cTab)->(dbCloseArea())
EndIf
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)

If (cTab)->(!EOF()) .And. nIndTot > 0
	nTaxa := (cTab)->FNT_TAXA/nIndTot
EndIf

For nX := 1 to Len(aTxDepr)
	aTxDepr[nX] := nTaxa
Next nX

(cTab)->(dbCloseArea())
RestArea(aAreaFNT)
RestArea(aAreaFNI)
RestArea(aArea)
Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CalcTaxa   � Autor � Vinicius S Barreira   � Data � 02/03/95 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Localiza a taxa dentro da string N3_DEPREC                   ���
���������������������������������������������������������������������������Ĵ��
���Utilizacao� CalcTaxa( N3_DEPREC )                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Sigaatf                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CalcTaxa( cString )

Local nPonteiro := 1
Local nLaco := 0
Local cChar := ""
Local nPosicao := 0
//������������������������������������������������������������������������Ŀ
//� Localiza onde inicia o mes corrente na string                          �
//��������������������������������������������������������������������������
For nLaco := 1 to Len( cString )
    If nPonteiro == Month( dDataBase )
        nPosicao := nLaco
        Exit
    Endif
    If Subst( cString, nLaco , 1 ) == ","
        nPonteiro ++
    Endif
Next nLaco
//������������������������������������������������������������������������Ŀ
//� Continua a partir de onde parou, porem agora carrega a matriz cChar    �
//��������������������������������������������������������������������������
For nLaco := nPosicao to Len( cString )
    If Subst( cString, nLaco , 1 ) == ","
        Exit
    Endif
    cChar += Subst( cString, nLaco , 1 )
Next nLaco

Return Val ( Alltrim(cChar) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetDepPer �Autor  �Marcos S. Lobo      � Data �  06/16/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a depreciacao de um bem no periodo.	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - INSTRUCAO NORMATIVA 086 (MATA950) - LIVROS FISCAIS    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function RetDepPer(cBaseATF,cItemATF,cTipoATF,dDTAtfIni,dDtAtfFim)

Local aReaOri		:= GetArea()
Local nOrdSN3 		:= SN3->(IndexOrd())
Local nRecSN3 		:= SN3->(Recno())
Local nOrdSN4 		:= SN4->(IndexOrd())
Local nRecSN4		:= SN4->(Recno())
Local nDeprecAtf 	:= 0

Local dUltDepr		:= GetMV("MV_ULTDEPR")
Local cFilSN4		:= ""
Local cFilSN3		:= ""

Local cQuery		:= ""
Local cAliasQry		:= ""
Local aTamSN4		:= {}

DEFAULT dDTAtfIni	:= CTOD("  /  /  ")
DEFAULT dDTAtfFim	:= dUltDepr

dbSelectArea("SN3")
cFilSN3 := xFilial("SN3")
If SN3->(SN3->N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO) <> cFilSN3+cBaseAtf+cItemATF+cTipoATF
	dbSetOrder(1)
	If !dbSeek(cFilSN3+cBaseAtf+cItemATF+cTipoATF,.F.)
		SN4->(dbSetOrder(nOrdSN4))
		SN4->(dbGoTo(nRecSN4))
		SN3->(dbSetOrder(nOrdSN3))
		SN3->(dbGoTo(nRecSN3))
		RestArea(aReaOri)
		Return(nDeprecAtf)
	EndIf
Endif

If dDtAtfFim <= SN3->N3_DINDEPR

	/// SE A DATA FINAL FOR MENOR QUE O DIA DO INICIO DE DEPRECIA��O - AINDA NAO HOUVE DEPRECIA��O
	nDeprecAtf := 0

//�������������������������������������������������������������Ŀ
//� BOPS 00000150232 - DATA 15/07/2008                          �
//� A condi��o abaixo est� coerente, mas est� sujeita aos casos:�
//� 1. N�o execucao da virada anual do ativo:                   �
//�    - Neste caso o campo N3_VRDBALx n�o � zerado e continua  �
//�      acumulando o valor junto com o N3_VRDACMx. Com isso    �
//�      o retorno seria zerado ou incorreto.                   �
//�                                                             �
//� 2. Bens com apenas 1 exercicio de utiliza��o e que foram    �
//�    baixados:                                                �
//�    - Neste caso novamente o N3_VRDACMx e o N3_VRDBALx ter�o �
//�      o mesmo valor, causando um retorno incorreto.          �
//���������������������������������������������������������������
/*
ElseIf SN3->N3_DINDEPR >= dDtAtfIni .AND. dDtAtfFim == CTOD("31/12/"+STRZERO(YEAR(dUltDepr)-1,4))

	/// SE ESTA SOLICITANDO TUDO AT� O EXERC. ANTERIOR
	nDeprecAtf := SN3->N3_VRDACM1 - SN3->N3_VRDBAL1		/// DEPRECIA��O ACUMULADA - DEPREC. ACUM. DO EXERCICIO.
*/
ElseIf SN3->N3_DINDEPR >= dDTAtfIni .AND. dDtATfFim >= dUltDepr
	/// SE A DEPRECIACAO COMECOU DEPOIS DA DATA DE INICIO
	/// E DATA FINAL � MAIOR QUE A ULTIMA DATA DE DEPRECIACAO
	nDeprecAtf := SN3->N3_VRDACM1						/// DEPRECIACAO ACUMULADA

Else

	//�������������������������������������������������������������Ŀ
	//� BOPS 00000150232 - DATA 15/07/2008                          �
	//� 1. Para compensar perda da condicao N3_VRDACMx - N3_VRDBALx �
	//�    foi implementado o retorno do valor da depreciacao do    �
	//�    periodo atraves de query de sele��o das movimenta��es    �
	//�    pelo SN4.                                                �
	//�                                                             �
	//� 2. Efetuada correcao da avaliacao do campo N4_OCORR, pois   �
	//�    com as novas implementacoes do ativo, eram desconsidera- �
	//�    das as ocorrencias de depreciacao 07/08/10/11/12         �
	//���������������������������������������������������������������

	cAliasQry 	:= GetNextAlias()
	aTamSN4		:= TAMSX3("N4_VLROC1")

	cQuery := "SELECT SUM(SN4.N4_VLROC1) N4_VLROC1 FROM "+RetSqlName("SN4")+" SN4 "
	cQuery += " WHERE"
	cQuery += " SN4.N4_FILIAL = '"	+xFilial("SN4")+"' AND "
	cQuery += " SN4.N4_CBASE = '"	+cBaseAtf+"' AND "
	cQuery += " SN4.N4_ITEM = '"	+cItemAtf+"' AND "
	cQuery += " SN4.N4_TIPO = '"	+cTipoAtf+"' AND "
	cQuery += " SN4.N4_DATA >= '"	+DTOS(dDTAtfIni)+"' AND "
	cQuery += " SN4.N4_DATA <= '"	+DTOS(dDTAtfFim)+"' AND "
	cQuery += " SN4.N4_OCORR IN ('06','07','08','10','11','12') AND "
	cQuery += " SN4.N4_TIPOCNT = '4' AND "
	cQuery += " SN4.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)

	If Select(cAliasQry) > 0
		dbSelectArea(cAliasQry)
		dbCloseArea()
	Endif

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	TcSetField(cAliasQry,"N4_VLROC1","N",aTamSN4[1],aTamSN4[2])

	dbSelectArea(cAliasQry)
	dbGotop()

	While (cAliasQry)->(!Eof())
		nDeprecAtf := (cAliasQry)->N4_VLROC1
		(cAliasQry)->(DbSkip())
	End

	If Select(cAliasQry) > 0
		dbSelectArea(cAliasQry)
		dbCloseArea()
	Endif

EndIf

SN4->(dbSetOrder(nOrdSN4))
SN4->(dbGoTo(nRecSN4))
SN3->(dbSetOrder(nOrdSN3))
SN3->(dbGoTo(nRecSN3))
RestArea(aReaOri)

Return(nDeprecAtf)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFator  �Autor  �Norberto M Melo     � Data �  21/08/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GetFator( cConta )
Local nGetFator := 1
Local aArea

Default cConta := ''
aArea := GetArea()

	DBSelectArea( "CT1" )
	if CtbInUse()
		CT1->( DbSetOrder(1) )
		if CT1->( MsSeek( xFilial("CT1") + cConta ) )
			nGetFator := if( CT1->CT1_NORMAL == "1", 1, -1 )
        endif
	else
		SI1->( DbSetOrder(1) )
		if SI1->( MsSeek( xFilial("SI1") + cConta ) )
			nGetFator := if( SI1->I1_NORMAL == "1", 1, -1 )
        endif
	endif

RestArea(aArea)

Return ( nGetFator )

/*
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AFatorCalc � Autor � Marcelo Akama         � Data � 29/07/09 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o fator de depreciacao em funcao do modo de calculo  ���
���          � (Mensal ou Anual), tratando os bens que precisam de calculo  ���
���          � proporcional de acordo com o parametro MV_TIPDEPR            ���
����������������������������������������������������������������������������Ĵ��
���Atualizado � Autor � Fernando Radu Muscalu         	   � Data � 02/06/11 ���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao adaptada para suportar passagem dos parametros 		 ���
���da         �essenciais de cada metodo de depreciacao, sem haver   		 ���
���Atualizacao�necessidade de estar com o arquivo SN3 posicionado            ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Gen�rico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/


/*Parametros.
//���������������������������������������������������Ŀ
//�aTxDepr = array com as taxas de deprecia��o do Bem.�
//�dInDepr  = Data inicio da deprecia��o.             �
//�dDataCalc = Data do Calculo Mensal.                �
//�cTipDepr = Tipo de Deprecia��o.                    �
//�cCalcDep = Deprecia��o Mensal ou Anual.            �
//�lFull =                                            �
//�nAtfdTp0 = Data da Deprecia��o.                    �
//�aParam = array com os dados de depreciacao		  �
//�    				  								  �
//�Mapeamento do conteudo de aParam					  �
//�aParam[1] - N3_VORIG1							  �
//�aParam[2] - N3_VRDACM1							  �
//�aParam[3] - N3_TPDEPR							  �
//�aParam[4] - N3_VMXDEPR							  �
//�aParam[5] - N3_PERDEPR							  �
//�aParam[6] - N3_VLSALV1							  �
//�aParam[7] - N3_PRODMES							  �
//�aParam[8] - N3_PRODANO							  �
//�													  �
//�����������������������������������������������������
ENDDOC*/
Function AFatorCalc(aTxDepr, dInDepr, dDataCalc, cTipDepr, cCalcDep, lFull, aParam)

Local cMetodo	:= ""

Local nVlSalv1	:= 0
Local nVMxDepr	:= 0
Local nPeriodos := 0

Local nX		:= 0
Local nTaxa		:= 0
Local nFator	:= 0
Local nTaxaMes	:= 0
Local nFatorMes	:= 0

Local aFatorDep := {}
Local aIntParam	:= {}
Local cTpdpbx	:= Iif(SUPERGETMV('MV_ATFDPBX')=="1", "1", "0")
Local lAtvTra	:= .F.

Default cTipDepr 	:= AllTrim(GetMv("MV_TIPDEPR"))
Default cCalcDep	:= GetNewPar("MV_CALCDEP",'0')
Default lFull 		:= .F.
Default aParam		:= {}

//Alterado por Fernando Radu Muscalu em 01/06/11
If Len(aParam) > 0 //.and. len(aParam) == 9
	aIntParam := aClone(aParam)
Else
	aIntParam 		:= array(9)
	aIntParam[1]	:= SN3->N3_VORIG1
	aIntParam[2]	:= SN3->N3_VRDACM1
	aIntParam[3]	:= SN3->N3_TPDEPR
	aIntParam[4]	:= SN3->N3_VMXDEPR
	aIntParam[5]	:= SN3->N3_PERDEPR
	aIntParam[6]	:= SN3->N3_VLSALV1
	aIntParam[7]	:= SN3->N3_PRODMES
	aIntParam[8]	:= SN3->N3_PRODANO
	aIntParam[9]	:= SN3->N3_FIMDEPR
Endif

cMetodo		:= aIntParam[3]
nVlSalv1	:= aIntParam[6]
nVMxDepr	:= aIntParam[4]
nPeriodos 	:= aIntParam[5]
nVlrPer		:= aIntParam[7]
nVlrRef		:= aIntParam[8]

//Regra para validar se o ativo veio de transferencia e j� foi depreciado na baixa
If !Empty(SN3->N3_ATVORIG) .And.  cTpdpbx == '1' 
	lAtvTra	:= .T.
EndIf

Do Case
	Case cMetodo == "2" // Reducao de Saldos
		ATFCalcRS(nVlSalv1, aIntParam[1], nPeriodos, aIntParam[2], @aTxDepr)
	Case cMetodo == "3" // Soma dos Anos
		ATFCalcSA( nPeriodos, @aTxDepr,dDataCalc)
	Case cMetodo $ "4|5|8|9|" // Unidades Produzidas, Horas Trabalhadas, Exaustao Linear e Exaustao Residual
		ATFCalcVR(nVlrPer, nVlrRef, @aTxDepr)
		//TaxPUnidad( SN3->N3_PRODMES,SN3->N3_PRODANO )
	Case cMetodo == "6" // Soma dos Digitos
		ATFCalcSD(dDataCalc, dInDepr, nPeriodos, cCalcDep, @aTxDepr)
	Case cMetodo == "A"	//C�lculo por �ndice
		ATFCalcIn(@aTxDepr)
	Otherwise // cMetodo=="1" (Linear) | cMetodo=="7" (Linear c/ Vl Max de Depreciacao)
		ATFCalcQC(cCalcDep, @aTxDepr)
EndCase
For nX := 1 to Len(aTxDepr)
	nTaxa := aTxDepr[nX]

	If cCalcDep == '0' // Mensal
		If !lFull 
			If (MesAnoAtf(dInDepr) == MesAnoAtf(dDataBase) )  	//VALIDACAO SE EST� NO MES DE INICIO DEPRECIA��O PARA CALCULO DE ACORDO COM TIPDEPR E DATA DE BLOQUEIO
				If  (!Empty(SN1->N1_DTBLOQ) ) //MES DE AQUISI��O + DATA DE BLOQUEIO LEVA EM CONTA DATA DE BLOQUEIO NO CALCULO PROPORCIONAL
					If(SN1->N1_DTBLOQ > dInDepr .OR. cTipDepr == '1')				
						nFator := ( LastDay(dDataCalc) - SN1->N1_DTBLOQ ) / Day(LastDay(dDataCalc))
					Else 	
						nFator := ( LastDay(dDataCalc) - dInDepr + 1 ) / Day(LastDay(dDataCalc))
					EndIf
				ElseIf cTipDepr == '0' .Or. lAtvTra	// SEM DATA DE BLOQUEIO E PARAMETRO CALCULO PROPORCIONAL = CALCULA LEVANDO EM CONTA DATA DE INICIO DE DEPRECIA��O DO BEM
					nFator := ( LastDay(dDataCalc) - dInDepr + 1 ) / Day(LastDay(dDataCalc))
				Else 						//SEM DATA DE BLOQUEIO PARAMETRO MES CHEIO CALCULA DE ACORDO COM TAXA TOTAL DO MES 
					nFator := 1
				EndIf
			Else // FORA DO MES DE INICIO DE DEPRECIA��O N�O LEVA EM CONTA MV_TIPDEPR
				If (!Empty(SN1->N1_DTBLOQ))	.And. ((SN1->N1_DTBLOQ)>=FirstDay(dDatabase)) 
					nFator := ( LastDay(dDataCalc) - SN1->N1_DTBLOQ ) / Day(LastDay(dDataCalc))
				Else
					nFator := 1
				EndIf
			EndIf
		Else
			nFator := 1
		EndIf
		AADD( aFatorDep, nTaxa * nFator )
	ElseIf cCalcDep=='1' // Anual
		nTaxaMes := nTaxa / 12
		If Year(dInDepr)==Year(dDataCalc) .And. !lFull
			nFatorMes := IIf( cTipDepr $ "4|5|8|9|", 1, ( LastDay(dInDepr) - dInDepr + 1 ) / Day(LastDay(dInDepr)) )
			nFator := ( Month(dDataCalc) - Month(dInDepr) ) / 12
		Else
			nFatorMes := 0
			nFator := 1
		EndIf
		AADD( aFatorDep, (nTaxa * nFator) + (nTaxaMes * nFatorMes) )
	EndIf
Next nX

Return aFatorDep

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A010AtuTxR�Autor  � Marcelo Akama      � Data �  21/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza as taxas de depreciacao com taxa regulamentada    ���
���Desc.     �Fun��o Movida a partir da rotina atfa010 em 22/08/17        ���	 
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
���Parametros�ExpC1 : Codigo Taxa Regulamentada -> Retorno para o gatilho ���
���          �ExpN1 : Taxa                                                ���
���          �ExpN1 : Linha                                               ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A010AtuTxR(cTaxa, nTaxa, nLin)
	Local aArea		:=GetArea()
	Local aAreaSNH 
	Local nGet		:= IIf(Type("oFolder")=="O",oFolder:nOption,1)
	Local aPos := If(lMultMoed, AtfMultPos(aHeader,"N3_TXDEPR") , Array(5) ) // Controle de multiplas moedas  
	Local nX, nIni, nFim

	If (Type("aCols") == "A") .And. (Type("aHeader") == "A") .And. (nGet > 0) .and. !Empty(cTaxa)
		aAreaSNH	:=SNH->(GetArea())
		If nTaxa == nil
			dbSelectArea("SNH")
			SNH->(dbSetOrder(1))
			If !empty(cTaxa) .and. SNH->(dbSeek(xFilial("SNH")+cTaxa))
				nTaxa := SNH->NH_TAXA
			Else
				nTaxa := 0
			EndIf
		EndIf
		If nGet == 1
			nPos1:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR1"})
			nPos2:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR2"})
			nPos3:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR3"})
			nPos4:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR4"})
			nPos5:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR5"})
			If nLin == nil
				nIni := 1
				nFim := len(aCols)
			Else
				nIni := nLin
				nFim := nLin
			EndIf
			
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			For nX := nIni to nFim
				If lMultMoed
					AtfMultMoe(,, {|x| aCols[nX,aPos[x]]	:= nTaxa } )			
				Else
					aPos[1]:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR1"})
					aPos[2]:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR2"})
					aPos[3]:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR3"})
					aPos[4]:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR4"})
					aPos[5]:=aScan(aHeader,{|x| AllTrim(x[2]) == "N3_TXDEPR5"})
					aCols[nX,aPos[1]]:=nTaxa
					aCols[nX,aPos[2]]:=nTaxa
					aCols[nX,aPos[3]]:=nTaxa
					aCols[nX,aPos[4]]:=nTaxa
					aCols[nX,aPos[5]]:=nTaxa
				EndIf
			Next
			If Type("oGet") == "O"
				oGet:oBrowse:Refresh()
			EndIf
		EndIf
		RestArea(aAreaSNH)
	EndIf

	RestArea(aArea)
Return cTaxa

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF010LoadR�Autor  �Jair Ribeiro        � Data �  04/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega array de rateio						              ���
���          � Movida a partir do ATFA010                                 ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF010LoadR(aRateio,cCodRat,nLin)
	AF012LoadR(@aRateio,cCodRat,nLin)
Return


