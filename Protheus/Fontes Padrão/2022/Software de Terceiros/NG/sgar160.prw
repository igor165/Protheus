#INCLUDE "SGAR160.ch"
#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAR160  � Autor � Felipe Nathan Welter  � Data � 09/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio das Ordens dos Planos de Simulacao                ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SigaSGA                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAR160()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM( )

Local cString := "TBN"
Local cDesc1  := STR0001 //"Relatorio das Ordens dos Planos de Simula��o."
Local cDesc2  := STR0002 //"Atraves dos parametros o usuario podera efetuar a selecao desejada."
Local cDesc3  := ""
Local wnRel   := "SGAR160"

Private aReturn  := { STR0003, 1,STR0004, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := PadR( "SGR160", 10 )
Private Titulo   := STR0005 //"Relatorio das Ordens de Simula��o"
Private Tamanho  := "M"
Private aPerg :={}

//�������������������������������������������Ŀ
//� Variaveis utilizadas para parametros      �
//� MV_PAR01     // De Plano Simulacao ?      �
//� MV_PAR02     // Ate Plano Simulacao ?     �
//� MV_PAR03     // De Data Prev. ?           �
//� MV_PAR04     // Ate Data Prev. ?          �
//� MV_PAR05     // Ordens Terminadas ?       �
//� MV_PAR06     // Situacao ?                �
//� MV_PAR07     // Mostrar CheckLists ?      �
//���������������������������������������������

Pergunte(cPerg,.F.)

//�������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT     �
//���������������������������������������������
wnRel := SetPrint(cString,wnRel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey = 27
	Set Filter To
	dbSelectArea("TBN")
	NGRETURNPRM(aNGBEGINPRM)
	Return
EndIf

SetDefault(aReturn,cString)

RptStatus({|lEnd| R160Imp(@lEnd,wnRel,Titulo,Tamanho)},Titulo)

dbSelectArea("TBN")
//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK)                          �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R160Imp  � Autor � Felipe Nathan Welter  � Data � 09/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada do Relatorio.                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R160Imp(lEnd,wnRel,Titulo,Tamanho)
Local cRodaTxt := ""
Local nCntImpr := 0

Local cCodPla := ""
Local cCodChk := ""
Local lPrint  := .F.

Private li := 80 ,m_pag := 1
Private NomeProg := "SGAR160"
Private Cabec1   := " "
Private Cabec2   := " "
Private Inclui   := .T.

//��������������������������������������������������������������Ŀ
//� Verifica se deve comprimir ou nao                            �
//����������������������������������������������������������������
nTipo  := IIf(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos                                          �
//����������������������������������������������������������������
//          1         2         3         4         5         6         7         8         9         0         1         2         3
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//
//Plano de Simula��o: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//    Data........:  99/99/9999      Situacao: XXXXXXXXXX      Terminado: XXX
//        Data Inicial:  99/99/9999      Plano Inicial: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//        Data Final..:  99/99/9999      Plano Final..: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//
//        Ordem XXXXXX
//           Data Prev.:   99/99/9999       Data Real.:   99/99/9999       Data Final.:  99/99/9999
//
//           CheckList: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//              XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Informar   Resposta: XXX
//              XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Marcar
//              XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Informar   Resposta: XXX
//
//           CheckList: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//              XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   Informar   Resposta: XXX
//

//��������������������������������������������������������������Ŀ
//� Define o indice de leitura do arquivo de Ordens de Simulacao �
//����������������������������������������������������������������
dbSelectArea("TBN")
dbSetOrder(02)
dbSeek(xFilial("TBN")+MV_PAR01,.T.)
SetRegua(LastRec())

While TBN->(!Eof()) .And. TBN->TBN_CODPLA <= MV_PAR02

	If lEnd
		@ Prow()+1,001 PSay STR0027 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	IncRegua()


	If TBN->TBN_DATINP < MV_PAR03 .Or. TBN->TBN_DATINP > MV_PAR04
		dbSelectArea("TBN")
		dbSkip()
		Loop
	EndIf

	If MV_PAR05 != 1 .And. Val(TBN->TBN_TERMIN) == 1
		dbSelectArea("TBN")
		dbSkip()
		Loop
	EndIf

	If MV_PAR06 != 4 .And. Val(TBN->TBN_SITUAC) != MV_PAR06
		dbSelectArea("TBN")
		dbSkip()
		Loop
	EndIf


	dbSelectArea("TBM")
	dbSetOrder(01)
	If dbSeek(xFilial("TBM")+TBN->TBN_CODPLA)

		If TBN->TBN_CODPLA != cCodPla

			lPrint := .T.

			SomaLinha()
			@ Li,000 PSay STR0028+": "+TBN->TBN_CODPLA //"Plano de Simula��o"
			@ Li,027 PSay "- "+TBM->TBM_DESPLA
			cCodPla := TBN->TBN_CODPLA

			SomaLinha()
			@ Li,004 PSay STR0029+Replicate(".",12-Len(STR0029))+": "+DTOC(TBM->TBM_DATPLA) //"Data"###"Data"
			@ Li,035 PSay STR0030+": "+NGRETSX3BOX('TBM_SITUAC',TBM->TBM_SITUAC) //"Situacao"
			@ Li,061 PSay STR0031+": "+NGRETSX3BOX('TBM_TERMI',TBM->TBM_SITUAC) //"Terminado"

			SomaLinha()
			@ Li,004 PSay STR0032+Replicate(".",12-Len(STR0032))+": "+DTOC(TBM->TBM_DATINI) //"Data Inicial"###"Data Inicial"
			@ Li,035 PSay STR0033+Replicate(".",13-Len(STR0033))+": "+TBM->TBM_PLAINI //"Plano Inicial"###"Plano Inicial"
			@ Li,061 PSay "- "+SubStr(NGSEEK("TBB",TBM->TBM_PLAINI,1,"TBB_DESPLA"),1,40)

			SomaLinha()
			@ Li,004 PSay STR0034+Replicate(".",12-Len(STR0034))+": "+DTOC(TBM->TBM_DATFIM) //"Data Cancel."###"Data Cancel."
			@ Li,035 PSay STR0035+Replicate(".",13-Len(STR0035))+": "+TBM->TBM_PLAFIM //"Plano Final"###"Plano Final"
			@ Li,061 PSay "- "+SubStr(NGSEEK("TBB",TBM->TBM_PLAFIM,1,"TBB_DESPLA"),1,40)

			SomaLinha()
		EndIf

		SomaLinha()
		@ Li,008 PSay STR0036+Space(01)+TBN->TBN_CODORD //"Ordem"

		SomaLinha()
		@ Li,008 PSay AllTrim(NGRETTITULO("TBN_DATINP"))+":"
		@ Li,022 PSay TBN->TBN_DATINP Picture '99/99/9999'
		@ Li,039 PSay AllTrim(NGRETTITULO("TBN_DATINR"))+":"
		@ Li,053 PSay TBN->TBN_DATINR Picture '99/99/9999'
		@ Li,070 PSay AllTrim(NGRETTITULO("TBN_DATFIN"))+":"
		@ Li,084 PSay TBN->TBN_DATFIN Picture '99/99/9999'

		SomaLinha()
		//Impressao dos CheckList's
		If MV_PAR07 == 1
			dbSelectArea("TBQ")
			dbSetOrder(01)
			dbSeek(xFilial("TBQ")+TBN->TBN_CODORD+TBN->TBN_CODPLA,.T.)
			While TBQ->(!Eof()) .And. TBQ->TBQ_FILIAL == xFilial("TBQ") .And.;
					TBQ->TBQ_ORDEM == TBN->TBN_CODORD .And. TBQ->TBQ_PLANO == TBN->TBN_CODPLA

				cCodChk := ""
				dbSelectArea("TBR")
				dbSetOrder(01)
				dbSeek(xFilial("TBR")+TBQ->TBQ_ORDEM+TBQ->TBQ_PLANO+TBQ->TBQ_CHKLIS,.T.)
				While TBR->(!Eof()) .And. TBR->TBR_FILIAL == xFilial("TBR") .And.;
						TBR->TBR_ORDEM == TBQ->TBQ_ORDEM .And. TBR->TBR_PLANO == TBQ->TBQ_PLANO .And. TBR->TBR_CHKLIS == TBQ->TBQ_CHKLIS

					If TBR->TBR_CHKLIS != cCodChk
						SomaLinha()
						@ Li,011 PSay STR0037+": "+TBR->TBR_CHKLIS+" - "+SubStr(NGSEEK("TBD",TBR->TBR_CHKLIS,1,"TBD_DESCHK"),1,60) //"CheckList"
						cCodChk := TBR->TBR_CHKLIS
					EndIf

					SomaLinha()
					dbSelectArea("TBE")
					dbSetOrder(01)
					If dbSeek(xFilial("TBE")+TBR->TBR_CHKLIS+TBR->TBR_OPCAO)
						@ Li,014 PSay TBR->TBR_OPCAO+" - "+SubStr(TBE->TBE_DESOPC,1,40)
						@ Li,075 PSay NGRETSX3BOX("TBE_TIPRES",TBE->TBE_TIPRES)
						If TBE->TBE_TIPRES == "2"
							@ Li,086 PSay STR0038+": "+TBR->TBR_RESPOS //"Resposta"
						EndIf
					EndIf

					dbSelectArea("TBR")
					dbSkip()
				EndDo

				If !Empty(cCodChk)
					SomaLinha()
				EndIf

				dbSelectArea("TBQ")
				dbSkip()
			EndDo
		EndIf

	EndIf

	dbSelectArea("TBN")
	dbSkip()
End

Roda(nCntImpr,cRodaTxt,Tamanho)

//��������������������������������������������������������������Ŀ
//� Devolve a condicao original do arquivo principal             �
//����������������������������������������������������������������
RetIndex("TBN")
Set Filter To

If !lPrint
	MsgInfo(STR0039) //"N�o h� nada para imprimir no relat�rio."
	Return .F.
Endif

Set device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SomaLinha � Autor � Felipe Nathan Welter  � Data � 09/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Incrementa Linha e Controla Salto de Pagina                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       �SGAR160                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SomaLinha()
Local nVerif := If(nTIPO==15,75,58)
Li++
If Li > nVerif .And. Li <> 81
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Somalinha()
EndIf
If Li == 81
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf
Return .T.