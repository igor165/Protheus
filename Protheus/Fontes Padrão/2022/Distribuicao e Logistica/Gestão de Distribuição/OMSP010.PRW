#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSP010.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �OMSPGOL01 � Autor � Marco Bianchi         � Data � 15/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 4: Alocacao da Frota.  ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �OMSP010()                                                     ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {cText1,nPosIni,nPosFim,{cValor,cLegenda,nColorValor,���
���          � cClick,nPos},{cValor,cLegenda,nColorValor,cClick,nPos}}      ���
���          � cText1      = Texto da Barra                         		���
���          � nPosIni     = Valor Inicial                      		    ���
���          � nPosFim     = Valor Final                                    ���
���          � cValor      = Valor a ser exibido                            ���
���          � cLegenda    = Nome da Legenda                                ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)         ���
���          � cClick      = Funcao executada no click do valor (opcional)  ���
���          � nPos        = Valor da Barra                                 ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDI                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/


Function OMSP010()

Local aArea       := GetArea()
Local aAreaDA3    := DA3->(GetArea())
Local aAreaDAK    := DAK->(GetArea())
Local aAreaDAN    := DAN->(GetArea())
Local cAliasQry   := "DAN"
Local aRet        := {} 
Local aPesos      := {}
Local aOcupacao   := {}
Local aHorasDia   := {}
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,2)
Local dPerIni     := CTOD("01/"+cMes+"/"+cAno)
Local dPerFim     := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nHrsOcup	  := 0
Local nHrsTotais  := 0
Local nOcupPeso   := 0
Local nOcupTempo  := 0
Local nI          := 0
Local nPos        := 0 
Local nQtdVeic    := 0
Local cData       := ""
Local dDataIni    := CTOD("  /  /  ")
Local dDataFim    := CTOD("  /  /  ")
Local cHoraIni    := ""
Local cHoraFim    := ""
Local dAuxIni     := CTOD("  /  /  ")
Local dAuxFim     := CTOD("  /  /  ")
Local cAuxIni     := ""
Local cAuxFim     := ""
Local cMensagem1  := ""
Local cMensagem2  := ""
Local bWhile   
Local lQuery      := .F.
Local cIndex	  := ""
Local cChave	  := ""


#IFNDEF TOP
	Local nPeso       := 0
	Local nCapacidade := 0
#ENDIF

#IFDEF TOP

	//������������������������������������������������������������������������Ŀ
	//�Query para calcular total dos pesos carregados no mes e total da        �
	//�capacidade de todos os veiculos.                                        �
	//��������������������������������������������������������������������������
	cAliasQry := GetNextAlias()
	lQuery    := .T.
	BeginSql Alias cAliasQry
	SELECT SUM(DA3_CAPACN) CAPACIDADE,CASE WHEN SUM(DAK_PESO) IS NULL THEN 0 ELSE SUM(DAK_PESO) END PESO 
		FROM %Table:DA3% DA3
		LEFT JOIN %Table:DAK% DAK ON DAK_FILIAL = %xFilial:DAK% AND DA3_COD = DAK_CAMINH AND DAK_DATA >= %Exp:Dtos(dPerIni)% AND DAK_DATA <= %Exp:Dtos(dPerFim)% AND DAK.%NotDel%
		WHERE DA3_FILIAL = %xFilial:DA3% AND DA3.%NotDel% 
	EndSql

	//������������������������������������������������������������������������Ŀ
	//�Calcula % de ocupacao por Peso.                                         �
	//��������������������������������������������������������������������������
	nOcupPeso   := IIf ((cAliasQry)->Capacidade > 0,Round ((((cAliasQry)->Peso * 100) / (cAliasQry)->Capacidade),0),0)
	(cAliasQry)->(DbCloseArea())				


	//������������������������������������������������������������������������Ŀ
	//�Query para calcular quantidade da caminoes.                             �
	//��������������������������������������������������������������������������
	BeginSql Alias cAliasQry
	SELECT COUNT(*) QTDVEIC FROM  %Table:DA3% DA3 WHERE DA3.%NotDel%
	EndSql
	nQtdVeic := (cAliasQry)->QTDVEIC           
	(cAliasQry)->(DbCloseArea())
	
	//������������������������������������������������������������������������Ŀ
	//�Query para Filtrar as alocacoes dentro do mes.                          �
	//��������������������������������������������������������������������������
	BeginSql Alias cAliasQry
	
	Column DAN_DATINI as Date
	Column DAN_DATFIM as Date
	
	SELECT DAN_CODVEI,DAN_DATINI,DAN_HORINI,DAN_DATFIM,DAN_HORFIM FROM %Table:DAN% DAN
		WHERE DAN_FILIAL = %xFilial:DAN% AND DAN_TPALOC = '1'
		AND ( (DAN_DATINI >= %Exp:Dtos(dPerIni)% AND DAN_DATINI <= %Exp:Dtos(dDataBase)%) 
		OR (DAN_DATFIM >= %Exp:Dtos(dPerIni)% AND DAN_DATFIM <= %Exp:Dtos(dDataBase)%)) 
		AND DAN.%NotDel%
	EndSql

	bWhile := {|| !Eof() }
	
#ELSE 

	//������������������������������������������������������������������������Ŀ
	//�Calcula pesos das movimentacoes do mes                                  �
	//��������������������������������������������������������������������������
	dbSelectArea("DAK")		// Cabecalho das Cargas
	dbSetOrder(2)			// Data
	MsSeek(xFilial("DAK")+DTOS(dPerIni),.T.)
	While !Eof() .And. DAK_DATA <= dPerFim
	
		If Empty(DAK_CAMINH)
			dbSelectArea("DAK")
			dbSkip()
			Loop
		EndIf
		
		// Posiciona Cadastro de Veiculos
		dbSelectArea("DA3")
		dbSetOrder(1)
		dbSeek(xFilial("DA3")+DAK->DAK_CAMINH)
		
		nPos := aScan(aPesos,{|x| x[1] == DAK->DAK_CAMINH })
		If nPos == 0
			AADD(aPesos,{DAK->DAK_CAMINH,DAK->DAK_PESO,DA3_CAPACN})
		Else
			aPesos[nPos,2] += DAK->DAK_PESO
		 	aPesos[nPos,3] += DA3_CAPACN
		EndIf
		
		dbSelectArea("DAK")
		dbSkip()
	
	EndDo
	
	//������������������������������������������������������������������������Ŀ
	//�Inclui os veiculos que nao possuem movimentacao no mes                  �
	//��������������������������������������������������������������������������
	dbSelectArea("DA3")
	dbSetOrder(1)
	dbGoTop()
	While !Eof()
		nQtdVeic++
		nPos := aScan(aPesos,{|x| x[1] == DA3_COD }) 
		If nPos ==  0
			AADD(aPesos,{DA3_COD,0,DA3_CAPACN})
		EndIf
		dbSelectArea("DA3")
		dbSkip()
	EndDo
	
	//������������������������������������������������������������������������Ŀ
	//�Calcula % de ocupacao por Peso                                          �
	//��������������������������������������������������������������������������
	For nPos := 1 to Len(aPesos)
		nPeso       += aPesos[nPos,2]
		nCapacidade += aPesos[nPos,3]
	Next	
	nOcupPeso   := IIf(nCapacidade > 0,Round ( ((nPeso * 100) / nCapacidade),0),0)
	
	//������������������������������������������������������������������������Ŀ
	//�Calcula numero de horas alocadas por dia+veiculo.                       �
	//��������������������������������������������������������������������������
	cIndex	  := CriaTrab(nil,.f.)
	cChave	  := "DAN_FILIAL+DTOS(DAN_DATINI)+DTOS(DAN_DATFIM)"
	IndRegua("DAN",cIndex,cChave,,,)	
	dbGoTop()
	MsSeek(xFilial("DAN")+DTOS(dPerIni),.T.)
	bWhile := {|| !Eof() .And. ( (DAN_DATINI >= dPerIni .And. DAN_DATINI <= dDataBase ) .Or. (DAN_DATFIM >= dPerIni .And. DAN_DATFIM <= dDataBase))}
	
#ENDIF


//������������������������������������������������������������������������Ŀ
//�Calcula numero de horas alocadas por dia+veiculo.                       �
//��������������������������������������������������������������������������
While Eval(bWhile)
	
	If !lQuery
		If DAN_TPALOC <> '1'	
			dbSkip()	
			Loop
		EndIF
	EndIF
	
	dDataIni := DAN_DATINI
	dDataFim := DAN_DATFIM
	cHoraIni := DAN_HORINI
	cHoraFim := DAN_HORFIM
	
	If dDataIni < dPerIni
		dDataIni := dPerIni
		cHoraIni := "00:00"
	EndIf
	If dDataFim > dDataBase
		dDataFim := dDataBAse
		cHoraFim := '24:00'
	EndIf
	
	
	If dDataIni == dDataFim
		GravaHora(dDataIni,dDataFim,cHoraIni,cHoraFim,@aOcupacao,DAN_CODVEI)
	Else
		dAuxIni := dDataIni
		dAuxFim := dDataIni
		cAuxIni := cHoraIni
		cAuxFim := '24:00'
		While dAuxFim <= dDataFim
			GravaHora(dAuxIni,dAuxFim,cAuxIni,cAuxFim,@aOcupacao,DAN_CODVEI)
			
			dAuxIni++
			dAuxFim++
			If dAuxFim == dDataFim
				cAuxIni := '00:00'
				cAuxFim := cHoraFim
			Else
				cAuxIni := '00:00'
				cAuxFim := '24:00'
			EndIf
		EndDo
		
	EndIf
	
	dbSelectArea(cAliasQry)
	dbSkip()
	
EndDo


//������������������������������������������������������������������������Ŀ
//�Ordena por Data+Veiculo                                                 �
//��������������������������������������������������������������������������
aSort(aOcupacao,,,{|x,y| x[1] < y[1]})

//������������������������������������������������������������������������Ŀ
//�Cria array com maior hora trabalhada por dia                            �
//��������������������������������������������������������������������������
For nI := 1 to Len(aOcupacao)
	cData := Substr(aOcupacao[nI,1],1,8)
	nPos  := aScan(aHorasDia,{|x| x[1] == cData })
	If  nPos == 0
		AADD(aHorasDia,{cData,aOcupacao[nI,2],aOcupacao[nI,2] * nQtdVeic})
	Else
		If aOcupacao[nI,2] > aHorasDia[nPos,2]
			aHorasDia[nPos,3] := (aOcupacao[nI,2] * nQtdVeic)	// Maior numero de horas trabalhadas no dia
		EndIf
		aHorasDia[nPos,2] += aOcupacao[nI,2]					// Somatoria das horas trabalhadas de todos os veiculos no dia
	EndIf
Next

//������������������������������������������������������������������������Ŀ
//�Calcula % de ocupacao                                                   �
//��������������������������������������������������������������������������
For nI := 1 to Len(aHorasDia)
	nHrsOcup   += aHorasDia[nI,2]
	nHrsTotais += aHorasDia[nI,3]
Next
nOcupTempo := Round( ((nHrsOcup * 100) / nHrsTotais),0)

//������������������������������������������������������������������������Ŀ
//�Monta mensagens apresentadas ao clicar no percentual                    �
//��������������������������������������������������������������������������
cMensagem1  := "'"+STR0004 + "'+chr(13)+chr(10)+"	// "Calculo (% do Peso alocado em relacao a capacidade total)  "
cMensagem1  += "chr(13)+chr(10)+"
cMensagem1  += "'"+STR0005 + "'+chr(13)+chr(10)+"	// "Peso Alocado: Somatoria dos pesos alocados de todos os veiculos dentro do mes. "
cMensagem1  += "'"+STR0006 + "'+chr(13)+chr(10)+"	// "Capacidade: Somatoria das Capacidades Nominais de todos os veiculos. "
cMensagem1  += "'"+STR0007 + "'+chr(13)+chr(10)+"	// "Periodo Considerado:  Mes corrente. "
cMensagem1  += "'"+STR0008+"'"						// "Resultado %: (Peso Alocado * 100) / Capacidade"

cMensagem2  := "'"+STR0009 + "'+chr(13)+chr(10)+"	// "Calculo (% alocacao dos veiculos ) "
cMensagem2  += "chr(13)+chr(10)+"
cMensagem2  += "'"+STR0010 + "'+chr(13)+chr(10)+"	// "Qtd Horas alocadas: Somatoria das horas alocadas de todos os veiculos por dia. "
cMensagem2  += "'"+STR0011 + "'+chr(13)+chr(10)+"	// "Qtd Horas Ideal: Maior hora de trabalho de veiculo no dia, multiplicado pelo numero de veiculos. "
cMensagem2  += "'"+STR0012 + "'+chr(13)+chr(10)+"	// "Periodo Considerado:  Inicio do mes corrente ate Data Base. "
cMensagem2  += "'"+STR0013+"'"						// "Resultado %: (Qtd Horas alocadas * 100) / Qtd Horas Ideal"

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
aRet :=	{ STR0001,0,100,;		// "Ocupacao de Frota"
			{{AllTrim(Str(nOcupPeso))+" %",STR0002,CLR_RED ,"{ || MsgInfo("+cMensagem1+") }",nOcupPeso},;	// "% Por Peso"
			{AllTrim(Str(nOcupTempo))+" %",STR0003,CLR_BLUE,"{ || MsgInfo("+cMensagem2+") }",nOcupTempo}}}	// "% Por Ocupacao"

     
//������������������������������������������������������������������������Ŀ
//�Restaura areas                                                          �
//��������������������������������������������������������������������������
#IFDEF TOP
	(cAliasQry)->(DbCloseArea())
#ELSE
	dbSelectArea("DAN")
	RetIndex( "DAN" )
	FErase (cIndex+OrdBagExt())
	dbSetOrder(1)
#ENDIF

RestArea(aAreaDAN)
RestArea(aAreaDA3)
RestArea(aAreaDAK)
RestArea(aArea)

Return aRet



/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GravaHora � Autor � Marco Bianchi         � Data � 16/01/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Grava numero de horas por dia+veiculo.                        ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �GravaHora()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1: Data Inicial                                          ���
���          � ExpD2: Data Final                                            ���
���          � ExpC3: Hora Inicial                                          ���
���          � ExpC4: Hora Final                                            ���
���          � ExpA5: Array com horas por dia+veiculo                       ���
���          � ExpC6: Codigo do Veiculo                                     ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function GravaHora(dDataIni,dDataFim,cHoraIni,cHoraFim,aOcupacao,cVeiculo)

Local nPos   := 0
Local nHoras := 0

nHoras := SubtHoras(dDataIni,cHoraIni,dDataFim,cHoraFim)
nPos := aScan(aOcupacao,{|x| x[1] == DTOS(dDataIni)+cVeiculo })
If nPos == 0	
	AADD(aOcupacao,{ DTOS(dDataIni)+cVeiculo,nHoras})
Else
	aOcupacao[nPos][2] += nHoras
EndIf

Return