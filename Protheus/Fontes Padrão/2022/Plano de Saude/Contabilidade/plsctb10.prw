//
// cadastrar CH no atusx
//

#define STR0001 "Contabilizacao Off-Line de Comissoes"
#define STR0002 "Este programa tem como objetivo gerar os lancamentos contabeis off-line"
#define STR0003 "das comissoes calculadas."

#INCLUDE "PLSCTB10.CH"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

static lautoSt := .F.

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ���
���Funcao    � PLSCTB10� Autor � Angelo Sperandio                � Data � 11.08.06 ����
����������������������������������������������������������������������������������Ĵ���
���Descricao � Contabilizacao de Comissoes                                         ����
����������������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSCTB10()                                                          ����
����������������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                                   ����
����������������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                                        ����
����������������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                                ����
����������������������������������������������������������������������������������Ĵ���
���          �      �             �                                                ����
�����������������������������������������������������������������������������������ٱ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
/*/

Function PLSCTB10(lAuto)

//�������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                    �
//���������������������������������������������������������������������������
Local   nOpca     := 0
Local   aSays     := {}
Local   aButtons  := {}
Private cCadastro := STR0001 //"Contabilizacao Off-Line de Comissoes"
Private cPerg     := PADR("PLSC10",LEN(SX1->X1_GRUPO))

default lAuto := .F.

lautoSt := lAuto

If !lAuto .AND. ( BXQ->(FieldPos("BXQ_LAGER")) == 0 .or. BXQ->(FieldPos("BXQ_LAPAG")) == 0 .or. BXQ->(FieldPos("BXQ_REFERE")) == 0 )
	msgalert("Faltam campos para o correto processamento desta rotina. � necess�rio executar os procedimentos descritos no boletim t�cnico referente ao bops 112958.")
	Return
EndIf
//�������������������������������������������������������������������������Ŀ
//� Atualiza parametros                                                     �
//���������������������������������������������������������������������������
Pergunte(cPerg,.F.)
//�������������������������������������������������������������������������Ŀ
//� Monta texto para janela de processamento                                �
//���������������������������������������������������������������������������
aAdd(aSays,STR0002) //"Este programa tem como objetivo gerar os lancamentos contabeis off-line"
aAdd(aSays,STR0003) //"das comissoes calculadas."
//�������������������������������������������������������������������������Ŀ
//� Monta botoes para janela de processamento                               �
//���������������������������������������������������������������������������
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
aAdd(aButtons, { 2,.T.,{|| FechaBatch() }} )
//�������������������������������������������������������������������������Ŀ
//� Exibe janela de processamento                                           �
//���������������������������������������������������������������������������
If !lAuto
	FormBatch(cCadastro,aSays,aButtons)
endif
//�������������������������������������������������������������������������Ŀ
//� Processa Contabilizacao das Guias                                       �
//���������������������������������������������������������������������������
If !lAuto .AND. nOpca == 1
	Processa({|lEnd| PlsCtb10Proc()})
else
	PlsCtb10Proc()
EndIf
//�������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                           �
//���������������������������������������������������������������������������
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PlsCtb10Proc � Autor � Angelo Sperandio  � Data � 11.08.06 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Contabilizacao de Comissoes                                ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function PlsCtb10Proc(lEnd)

//�������������������������������������������������������������������������Ŀ
//� Incializa variaveis                                                     �
//���������������������������������������������������������������������������
Local   cArquivo   := ""
Local   nHdlPrv    := 0
Local   nTotLanc   := 0
Local   cNameBXQ   := RetSQLName("BXQ")
Local   cCodPro
Local   cVerPro
Local   cMatAnt
Local   nProc
Local   cCodOpe
Local   cMesRef
Local   cAnoRef
Local   cLote	   := Space(4)
Local   lDigita
Local   lAglut
Local   nSeparaPor
Local   lConGer
Local   lConPag
Local   lCanc      := .F.
Local   cSql
Local   cSql1
Local 	aFlagCTB := {}
Local 	lUsaFlag := GetNewPar("MV_CTBFLAG",.F.)
Private lCabecalho := .F.
//�������������������������������������������������������������������������Ŀ
//� Atualiza variaveis com o conteudo dos parametros informados no pergunte �
//���������������������������������������������������������������������������
lDigita    := (mv_par01 == 1)
lAglut     := (mv_par02 == 1)
nSeparaPor := mv_par03
cCodOpe    := mv_par04
cMesRef    := mv_par05
cAnoRef    := mv_par06
nProc      := mv_par07

If lautoSt
	lDigita    := .F.
	lAglut     := .T.
	nSeparaPor := 1
	cCodOpe    := "0001"
	cMesRef    := "01"
	cAnoRef    := "2021"
	nProc      := 1
endif
//�������������������������������������������������������������������������Ŀ
//� Monta parte da query                                                    �
//���������������������������������������������������������������������������
cSql1 := " FROM " + cNameBXQ
cSql1 += " WHERE BXQ_FILIAL = '" + xFilial("BXQ") + "' "
cSql1 +=       " AND BXQ_ANO    = '" + cAnoRef        + "' "
cSql1 +=       " AND BXQ_MES    = '" + cMesRef        + "' "
cSql1 +=       " AND BXQ_CODINT = '" + cCodOpe        + "' "
cSql1 +=       " AND (BXQ_LAGER = ' ' OR BXQ_LAPAG = ' ') "
If      nProc == 1  // Geracao
	cSql1 += " AND BXQ_REFERE =  '1' "
ElseIf  nProc == 2  // Pagamento
	cSql1 += " AND BXQ_DTGER  <> '" + Space(TamSX3("BXQ_DTGER")[1]) + "' "
Endif
cSql1 +=       " AND D_E_L_E_T_ = ' ' "
//�������������������������������������������������������������������������Ŀ
//� Seleciona registros para processamento ...                              �
//���������������������������������������������������������������������������
cSql := " SELECT COUNT(*) QTD " + cSql1
PLSQuery(cSql,"BXQQRY")
ProcRegua(BXQQRY->QTD)
BXQQRY->(dbCloseArea())
//�������������������������������������������������������������������������Ŀ
//� Seleciona registros para processamento ...                              �
//���������������������������������������������������������������������������
cSql := " SELECT R_E_C_N_O_ BXQ_RECNO, BXQ_PAGCOM, BXQ_REFERE, BXQ_DTGER "
cSql += cSql1
cSql += " ORDER BY BXQ_FILIAL, BXQ_CODINT, BXQ_CODEMP, BXQ_NUMCON, BXQ_SUBCON, BXQ_MATRIC, BXQ_TIPREG, BXQ_DIGITO, BXQ_PREFIX, BXQ_NUM, BXQ_PARC, BXQ_TIPO"
PLSQuery(cSql,"BXQQRY")
//�������������������������������������������������������������������������Ŀ
//� Verifica o N�mero do Lote                                               �
//���������������������������������������������������������������������������
cLote := LoteCont("PLS")
//�������������������������������������������������������������������������Ŀ
//� Seleciona indices                                                       �
//���������������������������������������������������������������������������
BA3->(dbSetOrder(1))
BA1->(dbSetOrder(2))
BI3->(dbSetOrder(1))
BQC->(dbSetOrder(1))
BT6->(DbSetOrder(1))
SE1->(DbSetOrder(1))
//�������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                    �
//���������������������������������������������������������������������������
BXQ->(dbGoTo(BXQQRY->BXQ_RECNO))
cMatAnt := BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)
//�������������������������������������������������������������������������Ŀ
//� Processa BXQ-Comissoes                                                  �
//���������������������������������������������������������������������������
While ! BXQQRY->(Eof())
	//����������������������������������������������������������������������Ŀ
	//� Movimenta regua                                                      �
	//������������������������������������������������������������������������
	IncProc()
	lConGer := .F.
	lConPag := .F.
	//����������������������������������������������������������������������Ŀ
	//� Posiciona BXQ                                                        �
	//������������������������������������������������������������������������
	BXQ->(dbGoTo(BXQQRY->BXQ_RECNO))
	//����������������������������������������������������������������������Ŀ
	//� Grava rodape - por Usuario                                           �
	//������������������������������������������������������������������������
	If !lAutoSt .AND. lCabecalho .and. nTotLanc > 0 .and. nSeparaPor == 1 .and. ;
		cMatAnt <> BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)
		PLSCA100(cArquivo,@nHdlPrv,cLote,@nTotLanc,lDigita,lAglut)
	EndIf
	
	//Verifica se o titulo esta baixdo por cancelamento                    
	If  BXQ->(BXQ_PREFIX+BXQ_NUM+BXQ_PARC+BXQ_TIPO) <> SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

		if SE1->(msSeek(xFilial("SE1") + BXQ->(BXQ_PREFIX+BXQ_NUM+BXQ_PARC+BXQ_TIPO)))
			lCanc := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)[3]
		EndIf

	Endif
	
	//����������������������������������������������������������������������Ŀ
	//� Posiciona BA3-Familia                                                �
	//������������������������������������������������������������������������
	If  BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC) <> BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
		BA3->(msSeek(xFilial("BA3") + BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC)))
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Posiciona BA1-Usuario                                                �
	//������������������������������������������������������������������������
	If  BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG) <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
		BA1->(msSeek(xFilial("BA1")+BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)))
	Endif
	//���������������������������������������������������������������������Ŀ
	//� Identifica codigo do produto a ser posicionado                      �
	//�����������������������������������������������������������������������
	If  ! empty(BA1->BA1_CODPLA)
		cCodPro := BA1->BA1_CODPLA
		cVerPro := BA1->BA1_VERSAO
	Else
		cCodPro := BA3->BA3_CODPLA
		cVerPro := BA3->BA3_VERSAO
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Posiciona BI3-Produto Saude                                          �
	//������������������������������������������������������������������������
	If  BA1->BA1_CODINT+cCodPro+cVerPro <> BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
		BI3->(msSeek(xFilial("BI3") + BA1->BA1_CODINT + cCodPro + cVerPro))
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Posiciona BQC-Subcontrato                                            �
	//� Posiciona BT6-Subcontrato x Produto                                  �
	//������������������������������������������������������������������������
	If  BA3->BA3_TIPOUS = "2" // Contrato Pessoa Juridica
		BQC->(msSeek(xFilial("BQC") + BA3->(BA3_CODINT + BA3_CODEMP + ;
		BA3_CONEMP + BA3_VERCON + ;
		BA3_SUBCON + BA3_VERSUB)))
		BT6->(msSeek(xFilial("BT6") + BA3->(BA3_CODINT + BA3_CODEMP + ;
		BA3_CONEMP + BA3_VERCON + ;
		BA3_SUBCON + BA3_VERSUB + ;
		cCodPro    + cVerPro)))
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Contabiliza a comissao                                               �
	//������������������������������������������������������������������������
	If !lAutoSt .AND. ! lCabecalho
		PlsCtbCabec(@nHdlPrv,@cArquivo,,cLote)
	EndIf
	If  nProc == 1 .or. nProc == 3
		If lUsaFlag
			aAdd(aFlagCTB,{"BXQ_LAGER","S","BXQ",BXQ->(Recno()),0,0,0})
		EndIf
		If  empty(BXQ->BXQ_LAGER)
			nTotLanc += DetProva(nHdlPrv,"9BT","PLSCTB10",cLote,,,,,,,,@aFlagCTB, PLSRACTL("9BT"))
			lConGer := .T.
		Endif
	Endif
	If  nProc == 2 .or. nProc == 3
		If lUsaFlag
			aAdd(aFlagCTB,{"BXQ_LAPAG","S","BXQ",BXQ->(Recno()),0,0,0})
		EndIf
		If  empty(BXQ->BXQ_LAPAG)
			If  lCanc
				nTotLanc += DetProva(nHdlPrv,"9BX","PLSCTB10",cLote,,,,,,,,@aFlagCTB, PLSRACTL("9BX"))
			Else
				nTotLanc += DetProva(nHdlPrv,"9BU","PLSCTB10",cLote,,,,,,,,@aFlagCTB, PLSRACTL("9BU"))
			Endif
			lConPag := .T.
		Endif
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Atualiza flag de lancamento contabil                                 �
	//������������������������������������������������������������������������
	If  lConGer .or. lConPag
		BXQ->(Reclock("BXQ",.F.))
		If  lConGer
			BXQ->BXQ_LAGER := "S"
		Endif
		If  lConPag
			BXQ->BXQ_LAPAG := "S"
		Endif
		BXQ->(msUnlock())
	Endif
	//����������������������������������������������������������������������Ŀ
	//� Inicializa variaveis                                                 �
	//������������������������������������������������������������������������
	cMatAnt := BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)
	//����������������������������������������������������������������������Ŀ
	//� Acessa proximo registro                                              �
	//������������������������������������������������������������������������
	BXQQRY->(dbSkip())
Enddo
//�������������������������������������������������������������������������Ŀ
//� Grava rodape                                                            �
//���������������������������������������������������������������������������
If !lAutoSt .ANd. lCabecalho .and. nTotLanc > 0
	PLSCA100(cArquivo,@nHdlPrv,cLote,@nTotLanc,lDigita,lAglut)
EndIf
//�������������������������������������������������������������������������Ŀ
//� Fecha area de trabalho                                                  �
//���������������������������������������������������������������������������
BXQQRY->(dbCloseArea())
//�������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                           �
//���������������������������������������������������������������������������
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    �PlsCtbCabec� Autor � Angelo Sperandio     � Data � 11.08.06 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Grava lancamento contabeis                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function PlsCtbCabec(nHdlPrv,cArquivo,lCriar,cLote)

lCriar     := If(lCriar=NIL,.F.,lCriar)
nHdlPrv    := HeadProva(cLote,"PLSCTB05",Substr(cUsuario,7,6),@cArquivo,lCriar)
lCabecalho := .T.

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao    � PLSCA100� Autor � Angelo Sperandio     � Data � 11.08.06 ���
��������������������������������������������������������������������������Ĵ��
��� Descricao � Grava lancamento contabeis                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function PLSCA100(cArquivo,nHdlPrv,cLote,nTotal,lDigita,lAglut)

//�������������������������������������������������������������������������Ŀ
//� Grava rodape                                                            �
//���������������������������������������������������������������������������
If !lAutoSt .AND. nHdlPrv > 0
	RodaProva(nHdlPrv,nTotal)
	//���������������������������������������������������������������������Ŀ
	//� Envia para Lan?amento Cont�bil 							            �
	//�����������������������������������������������������������������������
	cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	lCabecalho := .F.
	nHdlPrv    := 0
	nTotal     := 0
EndIf

Return
