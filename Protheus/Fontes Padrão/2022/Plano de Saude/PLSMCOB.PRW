#INCLUDE "PLSMCOB.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"

#DEFINE nBFQ_CODLAN		1		// Definido tambem no PLSMFPG
#DEFINE nBFQ_DEBCRE		2
#DEFINE nBFQ_DESCRI		3
#DEFINE nBFQ_CALRAT		4
#DEFINE nBFQ_INCIR		5
#DEFINE nBFQ_REGCIR		6
#DEFINE nBFQ_RELBFR		7		// Alias Relacionados com o BFR
#Define PLSVALOR "@E 99,999,999,999.99"

Static _aBfr	:= {}
Static nPerAns	:= 0
Static cSeqAns	:= 0
Static _cAnoIni	:= ""
Static _cAnoFim	:= ""

Static nUsrTxf	:= 0	// Numero de Usuarios Taxa de Adesao Fixa
Static nLidTxf	:= 0	// Numero de Usuarios Lidos Taxa Fixa
Static nVlrTxf	:= 0	// Valor Cobranca Taxa fixa
Static nCobTxf	:= 0	// Valor Cobrado Taxa fixa

Static nUsrFix	:= 0	// Numero de Usuarios Valor Fixo Contrato
Static nLidFix	:= 0	// Numero de Usuarios Lidos Valor Fixo Contrato
Static nVlrFix	:= 0	// Valor Cobranca do contrato
Static nCobFix	:= 0	// Valor Cobrado do contrato

Static aBED 	:= {}	// Identificacao do Usuario
Static aBDH 	:= {}	// Co-Participacao
Static aBHX 	:= {}
Static aBF3 	:= {}	// Valor de Agravo

Static lVerNiv			// Ponto de Entrada para verificacao do nivel de cobranca

Static cNumEnd := CriaVar("BA3_NUMERO") 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALCONT ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de cobranca de uma familia.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Na versao 6.09 para traz ela tinha o nome de PLVALCONT     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³05.03.02³ 7.10 ³  Novas Funcionalidades                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
[1]  - (C)redito (D)ebito
[2]  - Valor
[3]  - Codigo do Lancamento (C 03)
[4]  - Codigo do evento
[5]  - Descricao Evento
[6]  - Cargo (uso generico)
[7]  - Matricula do usuario
[8]  - Nome do usuario
[9]  - Indice valido ou totalizador
[10] - Sexo do usuario
[11] - Grau de Parentesco
[12] - Numero do registro do Usuario (Recno do BA1)
[13] - Codigo da Faixa do lancamento utilizada
[14] - Nivel da faixa etaria utilizada
[ 1 - Valor Produto Produto/Plano (BB3)
2 - Valor Produto Empresa  (BTN)
3 - Valor Adesao  Produto (BRY)
4 - Valor Adesao  Empresa (BR6)
5 - Aumentos ANS Nivel Operadora Cabecalho (BH9)
6 - Aumentos ANS Nivel Operadora Itens (BTX)
7 - Valor dos opcionais Cabecalho (BT3)
8 - Valor dos opcionais Itens (BCB) ]
9 - Valor da Coparticipacao
[15] - Tipo de Usuario
[16] - Cliente do Lancamento
[1] Codigo do Cliente
[2] Loja do Cliente
[3] Codigo do Fornecedor
[4] Loja do Fornecedor
[5] Valor a Faturar  //Por Enquanto usado somente na Co-participacao
/*/
Function PLSVALCONT(cMatric,cAno,cMes,lDetalhado,_nTipo,lFaturamento,cModal,lMsg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis genericas...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL pMoeda := "@E 999,999,999.99"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBA3 := BA3->(IndexOrd())
LOCAL nRecBA3 := BA3->(Recno())
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL nRecBA1 := BA1->(Recno())
LOCAL nOrdBI3 := BI3->(IndexOrd())
LOCAL nRecBI3 := BI3->(Recno())
LOCAL bRest   := { || BA3->(DbSetOrder(nOrdBA3)), BA3->(DbGoTo(nRecBA3)), ;
BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRecBA1)), ;
BI3->(DbSetOrder(nOrdBI3)), BI3->(DbGoTo(nRecBI3)) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defino variavies de retorno...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nRet   := 0
LOCAL aAux
LOCAL aRet   := {}
LOCAL nAux
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defino variavies de apoio...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cTipoGru
LOCAL cForPag 	:= ""
LOCAL _cNivel	:= ""
LOCAL cRdmake
Local aUsr		:= {}, nUsr := 0
Local aValor	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja especificado obtem o valor na DataBase...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cAno       	:= PLSSTRANO(dDataBase,.T.)
DEFAULT cMes       	:= PLSSTRMES(dDataBase)
DEFAULT lDetalhado 	:= .F.
DEFAULT _nTipo     	:= 0 	// Defino que o Padrao sera a cobranca por Familia
							// 1 seria Cobranca por usuario
							
DEFAULT lFaturamento := .F.
DEFAULT lMsg		 := .T.

If ! lFaturamento
	nUsrTxf	:= 0
	nLidTxf	:= 0
	nVlrTxf	:= 0
	nCobTxf	:= 0

	nUsrFix	:= 0
	nLidFix	:= 0
	nVlrFix	:= 0
	nCobFix	:= 0
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no arquivo de contratos...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA3->(DbSetOrder(1))   
If 	BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC) <> xFilial("BA3")+Left(cMatric,14)
 	If ! BA3->(MsSeek(xFilial("BA3")+Left(cMatric,14)))
       Eval(bRest)
       Return(IF(lDetalhado,aRet,nRet))
    Endif   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no produto...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BI3->(DbSetOrder(1))
If  xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) <> BI3->(BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO) .And. ;
    ! BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
	Eval(bRest)
	Return(IF(lDetalhado,aRet,nRet))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no grupo/empresa...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BG9->(DbSetOrder(1))

If BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP) .And. ;
   ! BG9->(MsSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
	Eval(bRest)
	Return(IF(lDetalhado,aRet,nRet))
Else
	cTipoGru := BG9->BG9_TIPO
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for pessoa juridica posiciono no contrato da empresa...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoGru == "2"
	BT5->(DbSetOrder(1))
	If BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) == xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON) .And. ;
	   ! BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)))
	   Eval(bRest)
	   Return(IF(lDetalhado,aRet,nRet))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for pessoa juridica posiciono no sub-contrato da empresa...      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BQC->(DbSetOrder(1))
	If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) .And. ;
	    ! BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
		Eval(bRest)
		Return(IF(lDetalhado,aRet,nRet))
	Endif

	If ! Empty(BQC->BQC_CODBLO)
		If ! lFaturamento .And. lMsg
			MsgStop(STR0001) //"O Contrato esta bloqueado, cobranca nao pode ser gerada."
		Endif
		Eval(bRest)
		Return(IF(lDetalhado,aRet,nRet))
	Endif
	
	If BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO) <> ;
    	xFilial("BT6")+BA3->(BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO) ;
	    .And. ! BT6->(MsSeek(	xFilial("BT6") + BA3->BA3_CODINT +;
					BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON+;
					BA3->BA3_VERSUB + BA3->BA3_CODPLA + BA3->BA3_VERSAO))
	    Eval(bRest)
	    Return(IF(lDetalhado,aRet,nRet))
	Endif    
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se esta pedindo um valor de cobranca apos a inclusao contr.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cAno+cMes < Subs(dtos(BA3->BA3_DATBAS),1,6)
	Eval(bRest)
	If ! lFaturamento .And. lMsg
		MsgStop(STR0002) //"O Mes/Ano Informado e inferior ao mes do contrato."
	Endif
	Return(IF(lDetalhado,aRet,nRet))
Endif

cForPag	:= BA3->BA3_FORPAG
_cNivel := "3" //Nivel de cobranca sempre na familia
cRdmake := If(BA3->(FieldPos("BA3_ROTINA"))==0,"",BA3->BA3_ROTINA)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja encontrado a forma de pagto aborto...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cForPag) .Or. Empty(cRdmake)
	Eval(bRest)
	Return(IF(lDetalhado,aRet,nRet))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se composicao ja esta calculada...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BM1->(DbSetOrder(1))
If (lFaturamento .Or. ! BM1->(MsSeek(xFilial("BM1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+cAno+cMes))))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Starta a funcao definida...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Upper(cRdmake) = "PLSVLRFIX"		// Rotinas de Calculo Padrao
	
		If nUsrFix = 0 
	
			aUsr := PLQTUSEMP(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,;
			        		BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,cForPag)
        	
        	For nUsr := 1 To Len(aUsr)
				nUsrFix	+= aUsr[nUsr][3]
			Next                           
			
			BWD->(DbSeek(xFilial("BWD") + BA3->BA3_CODINT + BA3->BA3_CODEMP +;
					BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB +;
					BA3->BA3_CODPLA + BA3->BA3_VERSAO + cForPag))
			
			nLidFix	:= 0
			nVlrFix := BWD->BWD_VALOR
			nCobFix := 0
		Endif

		aAux := PlsVlrFix(cAno,cMes,_nTipo,_cNivel, cForPag, , lFaturamento, cModal,;
						nUsrFix,@nLidFix,nVlrFix,@nCobFix)
	Else
		aAux := ExecBlock(cRdmake,.F.,.F.,{cAno,cMes,_nTipo,_cNivel, cForPag, lFaturamento, cModal })
	Endif
	
	For nAux := 1 To Len(aAux)
		aadd(aRet,aAux[nAux])
	Next
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca a composicao de cobranca calculada...                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ! BM1->(Eof()) .And. BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES) == xFilial("BM1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAno+cMes
        aadd(aRet,{	BM1->BM1_TIPO,;
					BM1->BM1_VALOR,;
					BM1->BM1_CODTIP,;
					AllTrim(BM1->BM1_CODEVE),;
					AllTrim(BM1->BM1_DESEVE),;
					BM1->BM1_CARGO,;
					BM1->BM1_MATUSU,;
					BM1->BM1_NOMUSR,;
					IF(BM1->BM1_LTOTAL=="0",.T.,.F.),;
					BM1->BM1_SEXO,;
					BM1->BM1_GRAUPA,;
					0,;		// Filler
					BM1->BM1_CODFAI,;
					BM1->BM1_NIVFAI,;
					BM1->BM1_TIPUSU,;
					BM1->BM1_ALIAS,;
					BM1->BM1_ORIGEM,;
					BM1->BM1_BASEIR })
		BM1->(DbSkip())
	Enddo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula totais...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval(aRet,{|x| IF(x[9],nRet := IF(x[1]=="1",nRet-x[2],nRet+x[2]),nil) })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRest)

If ! lFaturamento
	aValor := {}
	For nAux := 1 To Len(aRet)
		If aRet[nAux][2] > 0
			aadd(aValor,aRet[nAux])
		Endif
	Next
	aRet := AClone(aValor)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(IF(lDetalhado,aRet,nRet))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVALCOB  ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de cobranca de uma familia.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ Na versao 6.09 para traz ela tinha o nome de PLVALCOB      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³08.03.02³ 7.10 ³  Novas Funcionalidades                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVALCOB(cAno,cMes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lDetalhado
LOCAL aValor
LOCAL oDlg
LOCAL nRegBA1 := BA1->(Recno())
LOCAL nOrdBA1 := BA1->(IndexOrd())
LOCAL bRest   := { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRegBA1)) }
LOCAL oTree
LOCAL nInd
LOCAL nAux
LOCAL cQuebra := ""
LOCAL bOK     := { || oDlg:End() }
LOCAL oGrupo
LOCAL oSay
LOCAL oSayTot
LOCAL bMatric := { || BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) }
LOCAL cMatric := Eval(bMatric)
LOCAL nTotCre := 0
LOCAL nTotDeb := 0
LOCAL nTotal  := 0
LOCAL cTipo
LOCAL aButtons := { 	{"RELATORIO",{|| PLHISMOV(cMatric,"(BD6->BD6_VLRTPF > 0 .And. BD6->BD6_FASE $ '2,3,4' .And. BD6->BD6_SITUAC = '1')","(BE4->BE4_VLRPF > 0 .And. BE4->BE4_FASE $ '2,3,4' .And. BE4->BE4_SITUAC = '1')",.T.) },STR0003},; //"Movimentacao da Co-Participacao - <F4>"
						{"PROJETPMS",{|| PLHISREA(cMatric, cAno, cMes,;
						BA1->BA1_CONEMP, BA1->BA1_VERCON, BA1->BA1_SUBCON, BA1->BA1_VERSUB) },STR0004} } //"Historico de Reajustes Familia - <F5>"
LOCAL cBmp
LOCAL cLastCargo := "00"
Local aAglutina	 := {}, nItem, nAglutina, nPosAglu
Local cOperadora := ""
Local cEmpresa   := ""
Local cNumero	 := ""
Local cLblMatric := ""

DEFAULT cAno := ""
DEFAULT cMes := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca dados dos parametros pelo usuario...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cAno) .Or. Empty(cMes)
	If ! Pergunte("PLA730",.T.)
		Return
	Endif
	
	cAno       	:= mv_par01
	cMes		:= mv_par02
else
	mv_par03 	:= 2	
Endif
lDetalhado := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa funcao que retornara composicao de cobranca...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aValor := PLSVALCONT(Eval(bMatric),cAno,cMes,lDetalhado)
If mv_par03 = 1
	aAglutina := AClone(aValor)
	aValor := {}
	For nItem := 1 To Len(aAglutina)
		If aAglutina[nItem][2] # 0
			Aadd(aValor, AClone(aAglutina[nItem]))
			If ! Empty(aAglutina[nItem][3])
				For nAglutina := nItem + 1 To Len(aAglutina)
					If (nPosAglu := (Ascan(aAglutina, {|x| 	x[1] == aAglutina[nItem][1] .And.;
															aAglutina[nItem][2] > 0 .And.;
															x[3] == aAglutina[nItem][3] .And.;
															x[7] == aAglutina[nItem][7] }, nAglutina ))) > 0
						aValor[Len(aValor)][2] += aAglutina[nAglutina][2]
						aAglutina[nAglutina][2] := 0
					Endif
				Next
			Endif
		Endif 
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata uma possivel nao-conformidade na rotina...                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aValor)
	eval(bRest)
	Return
Else
	aEval(aValor, { |x| IF(x[9],If(x[1]=="2",nTotCre := nTotCre + x[2],nTotDeb := nTotDeb + x[2]),nil) })
	If nTotDeb >= nTotCre
		cTipo  := "D"
		nTotal := nTotDeb - nTotCre
	Else
		cTipo  := "C"
		nTotal := nTotCre - nTotDeb
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona nos arquivos utilizados...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbSetOrder(2))
BA1->(MsSeek(xFilial("BA1")+Eval(bMatric)))

BA0->(DbSetOrder(1))
BA0->(MsSeek(xFilial("BA0")+BA1->BA1_CODINT))

BG9->(DbSetOrder(1))
BG9->(MsSeek(xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP)))

If BG9->BG9_TIPO == "2"
	BT5->(DbSetOrder(1))
	BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))
Endif

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dialogo com usuario...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0007+cAno+" / "+cMes   FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault() //"Composicao de Cobranca  -   "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta says...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cOperadora := TransForm(BA1->BA1_CODINT,"@R !.!!!")+ "  -  "+subs(BA0->BA0_NOMINT,1,35)
@ 016, 208 GROUP oGrupo TO 032, 350 PIXEL OF oDlg LABEL STR0008  COLOR CLR_HBLUE, CLR_HRED //" Operadora "
PLSSAYESP(022,215,{ || cOperadora },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

cEmpresa := TransForm(BA1->BA1_CODEMP,"!!!!")+ "  -  "+subs(BG9->BG9_DESCRI,1,36)
@ 036, 208 GROUP oGrupo TO 052, 350 PIXEL OF oDlg LABEL STR0009  COLOR CLR_HBLUE, CLR_HRED //" Grupo Empresa "
PLSSAYESP(042,215,{ || cEmpresa },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")
			
cNumero := If(BG9->BG9_TIPO=="2", TransForm(BA1->BA1_CONEMP,"!!!!"), BA3->BA3_NUMCON)
@ 056, 208 GROUP oGrupo TO 072, 275 PIXEL OF oDlg LABEL If(BG9->BG9_TIPO=="2",STR0010,STR0011)  COLOR CLR_HBLUE, CLR_HRED //" Contrato Empresa "###"Numero Contrato"
PLSSAYESP(062, 215, { || cNumero },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

cLblMatric := BA1->BA1_MATRIC
@ 056, 277 GROUP oGrupo TO 072, 350 PIXEL OF oDlg LABEL STR0012  COLOR CLR_HBLUE, CLR_HRED //" Matricula "
PLSSAYESP(062,285,{ || cLblMatric },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto tree...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTree := DbTree():New(018,005,195,200,oDlg,nil,nil,.T.,nil)
oTree:BuildTrb(100, 2)
oTree:BeginUpdate()
oTree:SetEnable()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados da composicao de cobranca...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nInd := 1 To Len(aValor)
	If aValor[nInd,2] = 0
		Loop
	Endif
	
	cQuebra := aValor[nInd, 7]
	oTree:AddTree(TransForm(aValor[nInd,7],__cPictUsr)+"   "+aValor[nInd,8]+Space(100),Nil,"BMPGROUP","BMPGROUP",nil,nil,"")
	For nAux := nInd To Len(aValor)
		If aValor[nAux,2] = 0
			Loop
		Endif

		If cQuebra <> aValor[nAux,7]
			Exit
		Else
			cBmp := IF(aValor[nAux,9],"LJPRECO","PRECO")

			cLastCargo := StrZero(Val(cLastCargo)+1,2)
			
			If Empty(aValor[nAux,4])
				cTexto := AllTrim(aValor[nAux,5])
			Else
				cTexto := AllTrim(aValor[nAux,5]) + " [" + AllTrim(aValor[nAux,4])+"] "
			Endif

			If ! Empty(aValor[nAux,6])
				cTexto += " - " + AllTrim(aValor[nAux,6])
			Endif
						
			cTexto += " - "
			oTree:AddTree(cTexto + AllTrim(TransForm(aValor[nAux,2],PLSVALOR)),Nil,cBmp,cBmp,nil,nil,cLastCargo)

  			oTree:TreeSeek(cLastCargo)
  			oTree:TreeSeek("")
  			oTree:EndTree()
		Endif
	Next
	oTree:EndTree()
	nInd := nAux-1
Next
oTree:EndUpdate()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta totalizadores...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 175, 208 GROUP oGrupo TO 192, 245 PIXEL OF oDlg LABEL STR0013 COLOR CLR_HBLUE, CLR_HRED //" Creditos "
PLSSAYESP(182,209,{ || TransForm(nTotCre,PLSVALOR)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 250 GROUP oGrupo TO 192, 285 PIXEL OF oDlg LABEL STR0014  COLOR CLR_HBLUE, CLR_HRED //" Debitos "
PLSSAYESP(182,249,{ || TransForm(nTotDeb,PLSVALOR)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 290 GROUP oGrupo TO 192, 350 PIXEL OF oDlg LABEL STR0015  COLOR CLR_HBLUE, CLR_HBLUE //" TOTAL "
PLSSAYESP(182,290,{ || TransForm(nTotal,PLSVALOR)+" - ("+cTipo+")"  },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")
ACTIVATE DIALOG oDlg ON INIT Eval( { || oTree:TreeSeek(cLastCargo), oTree:Refresh(), EnchoiceBar(oDlg,bOK,bOK,.F.,aButtons) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRest)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSISTAXAD ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna .T. se a taxa de adesao ja foi cobrada...          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSISTAXAD(cCodInt,cCodEmp,cMatric,cTipReg,lPosic)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet := .F.
LOCAL aRet
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define parametros default...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lPosic := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona primeiro no usuario...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPosic
	BA1->(DbSetOrder(2))
	BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
Endif

lRet := ( BA1->BA1_CBTXAD == "1" )
aRet := {lRet,BA1->BA1_VLTXAD}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRTXAD ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de taxa de adesao para um usuario...       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRTXAD(cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cAno,cMes,aRet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cForPag := "", aAux := {}, aUsr, nUsr, _cNivel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja foi cobrada a taxa de adesao...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCobTx := PLSISTAXAD(cCodInt,cCodEmp,cMatric,cTipReg)

If ! aCobTx[1]
	nValor := 0
	aEval(aRet,{ |x| nValor := nValor + If( (x[3]=="101" .And. x[1] == "1" .And. x[7] == cCodInt+cCodEmp+cMatric+cTipReg+cDigito .And. x[9] ),x[2],0)})
	
	cForPag := BA3->BA3_FORCTX
	If ! Empty(BA3->BA3_NIVFTX)
		_cNivel := BA3->BA3_NIVFTX
	Else
		cTipoGru := BG9->BG9_TIPO
		
		BJL->(DbSetOrder(1))
		If BJL->(MsSeek(xFilial("BJL")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_FORCTX)))
			cForPag  := BJL->BJL_CODFOR
			_cNivel  := "3" // Familia
		Endif
		
		If Empty(_cNivel)
			If cTipoGru == "2"
				BTK->(DbSetOrder(1))
				If BTK->(MsSeek(xFilial("BTK")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORCTX)))
					cForPag := BTK->BTK_CODFOR
					_cNivel  := "2" // Grupo/Empresa
				Endif
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja pessoa fisica (branco) ou nao exista na empresa...        ³
		//³ procuro no produto saude...                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(_cNivel)
			BJ9->(DbSetOrder(1))
			If BJ9->(MsSeek(xFilial("BJ9")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORCTX)))
				cForPag := BJ9->BJ9_CODFOR
				_cNivel  := "1" // Produto
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja encontrado a forma de pagto aborto...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(_cNivel)
		Return({.F.,0})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciono no cadastro da forma selecionada...                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BJ0->(DbSetOrder(1))
	
	If ! BJ0->(MsSeek(xFilial("BJ0")+cForPag+_cNivel))
		Return({.F.,0})
	Else
		cRdmake := AllTrim(BJ0->BJ0_ROTINA)
	Endif
	
	If Upper(cRdmake) = "PLSTXPAD"	// Rotinas Padroes
		aAux := PlsTxPad(cCodInt,cCodEmp,cMatric,cTipReg,aCobTx,_cNivel,nValor)
	ElseIf Upper(cRdmake) = "PLSTXFIX"	// Rotinas Padroes
		If 	Left(Dtos(BQC->BQC_DATCON), 6) = Left(Dtos(BA1->BA1_DATINC), 6) .And.;
			cAno + cMes = Left(Dtos(BQC->BQC_DATCON), 6)
	        If nUsrTxf = 0 
	        	aUsr := PLQTUSEMP(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,;
	        	BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,cForPag,;
	        	"BA3_FORCTX")
	        	For nUsr := 1 To Len(aUsr)
					nUsrTxf	+= aUsr[nUsr][3]
				Next                           
				BWD->(DbSeek(xFilial("BWD") + BA3->BA3_CODINT + BA3->BA3_CODEMP +;
				BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB +;
				BA3->BA3_CODPLA + BA3->BA3_VERSAO + cForPag))
				nVlrTxf := BWD->BWD_VALOR
				nCobTxF := 0
				nLidTxf	:= 0
			Endif
			nLidTxf	++
			aAux := PlsTxFix(aCobTx,cForPag,nUsrTxf,nLidTxf,nVlrTxF,@nCobTxF)
		Endif
	Else
		aAux := ExecBlock(cRdmake,.F.,.F.,{cCodInt,cCodEmp,cMatric,cTipReg,aCobTx,_cNivel,nValor})
	Endif
	
	If Empty(aAux)
		aAux := {.F.,0,0,0}
	Endif
Else
	aAux := {.F.,0,0,0}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({aAux[1],aAux[2],aAux[3],aAux[4]})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRCBID ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de cobranca de identificacao...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRCBID(cCodInt,cCodEmp,cMatric,cTipReg,cDigito,cConEmp,cVerCon,cSubCon,cVerSub,lCarrega)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aValor := {}, nPos, cSql, cArea := Alias()

If lCarrega         
	aBed := {}
	cSql := "SELECT * FROM " + RetSqlName("BED") + " WHERE BED_FILIAL = '" +;
			xFilial("BED") + "' AND BED_CODINT = '" + cCodInt + "' AND " +;
			"BED_CODEMP = '" + cCodEmp + "' AND " +;
			"BED_CONEMP = '" + cConEmp + "' AND BED_VERCON = '" + cVerCon + "' AND " +;
			"BED_SUBCON = '" + cSubCon + "' AND BED_VERSUB = '" + cVerSub + "' AND "
	If ! Empty(cMatric)
		cSql += "BED_MATRIC = '" + cMatric + "' AND "
	Endif
	cSql += "BED_VALOR > 0 AND BED_COBRAR = '1' AND BED_FATUR = '0' AND D_E_L_E_T_ = ' '"
	PlsQuery(cSql,"BEDQRY")
Endif

If lCarrega
	While ! BEDQRY->(Eof())
        nPos := Ascan(aValor, {|x| 	x[1] = cCodEmp .And. x[2] = BEDQRY->BED_MATRIC .And.;
        							x[3] = BEDQRY->BED_TIPREG .And.;
        							x[4] = BEDQRY->BED_DIGITO .And. x[5] = cConEmp .And.;
        							x[6] = cVerCon .And. x[7] = cSubCon .And.;
        							x[8] = cVerSub .And. x[9] = BEDQRY->BED_CDIDEN })
   	    If nPos = 0
 			Aadd(aBed, { cCodEmp, BEDQRY->BED_MATRIC, BEDQRY->BED_TIPREG, BEDQRY->BED_DIGITO,;
 			cConEmp, cVerCon, cSubCon, cVerSub, BEDQRY->BED_CDIDEN, BEDQRY->BED_VALOR })
	   	Else
     		aBed[nPos][10] += BEDQRY->BED_VALOR
		Endif
		
		BEDQRY->(DbSkip())
	Enddo
	aBed := ASort(aBed,,, { |x,y| 	x[2] < y[2] .And. x[3] < y[3] })
	BEDQRY->(DbCloseArea())
	DbSelectArea(cArea)
Else
	nPos := Ascan(aBed, { |x| x[2] = cMatric .And. x[3] = cTipReg})
	If nPos > 0
		For nPos := nPos To Len(aBed)
			If aBed[nPos][2] = cMatric .And. aBed[nPos][3] = cTipReg
				Aadd(aValor, { aBed[nPos][9], aBed[nPos][10] })
			Endif
		Next
	Endif
Endif

Return(aValor)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRCVBL ³ Autor ³ Antonio de Padua  ³ Data ³ 30.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de via de boleto...                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRCVBL(cMatricFam)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nValor    := 0

BEE->(DbSetOrder(1))
If BEE->(MsSeek(xFilial("BEE")+cMatricFam+"0"))
	While ! BEE->(Eof()) .And. BEE->(BEE_FILIAL+BEE_CODINT+BEE_CODEMP+BEE_MATRIC+BEE_FATUR) == ;
		xFilial("BEE")+cMatricFam+"0"
		
		nValor := nValor + BEE->BEE_VALOR
		
		BEE->(DbSkip())
	Enddo
Endif

Return(nValor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRRANS ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o valor de reajuste da ANS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRRANS(cCodInt,cCodEmp,cMatric,cTipReg,cAno,cMes,dDataInc,aRet,cConEmp,;
cVerCon,cSubCon,cVerSub,cTipoGru,cNome,cNomeEve,cSexo,cGrauPar,nRecBA1,cTipUsu,;
cDigito,dDatRea,aBfq)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nInd
LOCAL cSQL
LOCAL cCodLan    := "105"
LOCAL nVlrDeb    := 0
LOCAL nVlrCre    := 0
LOCAL nVlrBase   := 0
LOCAL cMatricUsr := cCodInt+cCodEmp+cMatric+cTipReg+cDigito
LOCAL cBH9Name   := RetSQLName("BH9")
LOCAL cBTXName   := RetSQLName("BTX")
LOCAL cBM1Name   := RetSQLName("BM1")
LOCAL lFound     := .F.
LOCAL nRet
Local lCalc 	 := .F.
Local nBfr 		 := nCodBfr := 0
Local nCodBfr
If nPerAns = 0
	Return 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura por itens que fazem parte do valor base para reajuste       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBfr := RetPosBfr(cCodInt, cCodLan)

nVlrBase := 0
For nCodBfr := 1 To Len(_aBfr[nBfr][2])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelo valor base...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDeb  := 0
	nVlrCre  := 0
	aEval(aRet,{ |x| nVlrCre := nVlrCre + If( (x[3]==_aBfr[nBfr][2][nCodBfr] .And. x[1] == "1" .And. cMatricUsr = x[7] .And. x[9] ),x[2],0), ;
	nVlrDeb := nVlrDeb + If( (x[3]==_aBfr[nBfr][2][nCodBfr] .And. x[1] == "2" .And. cMatricUsr = x[7] .And. x[9] ),x[2],0)  })
	If nVlrCre > nVlrDeb
		nVlrBase += (nVlrCre - nVlrDeb)
	Else
		nVlrBase += (nVlrDeb - nVlrCre)
	Endif
Next                                                                     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Agora ja com o valor base vou calcular de acordo com regras...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVlrBase > 0 .And. nPerAns > 0
	nRet := CalcANS(dDatRea,nVlrBase,cAno,cMes,nPerAns)
	If nRet > 0
		aadd(aRet,{aBfq[nBFQ_DEBCRE],;
		nRet,;
		aBfq[nBFQ_CODLAN],;
		cSeqAns,;
		cNomeEve,;
		AllTrim(Str(nPerAns)) + " %",;
		cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
		cNome,;
		.T.,;
		cSexo,;
		cGrauPar,;
		nRecBA1,;
		"",;
		"5",;
		cTipUsu,;
		"BFQ",;
		"101",;
		PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nRet),;
		0.00 })
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CalcANS    ³ Autor ³ Tulio Cesar       ³ Data ³ 11.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o reajuste ANS...                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcANS(dDatRea,nVlrBase,cAno,cMes,nPerAns)
LOCAL cAnoFim
LOCAL cMesFim
LOCAL cAnoIni
LOCAL cMesIni
LOCAL nRes
LOCAL lReaj
//LOCAL nReaj
LOCAL nRea  := 0

//Primeiro tratamento...
cAnoFim := Subs(_cAnoFim,1,4)
cMesFim := Subs(_cAnoFim,5,2)

cAnoIni := Subs(dtos(dDatRea),1,4)
cMesIni := Subs(dtos(dDatRea),5,2)

nRes    := PLSDIFANOS(cAnoIni,cMesIni,cAnoFim,cMesFim,"M")

If cAno + cMes > cAnoFim + cMesFim .Or. nRes < 12
	Return(0)
Endif

//Segundo tratamento...
cAnoFim := cAno
cMesFim := cMes

cAnoIni := Subs(dtos(dDatRea),1,4)
cMesIni := Subs(dtos(dDatRea),5,2)

nRes    := PLSDIFANOS(cAnoIni,cMesIni,cAnoFim,cMesFim,"M")

If nRes >= 12 .And. Month(dDatRea) = Val(cMes)
	nRea :=((nVlrBase*nPerAns)/100)
	lReaj:= .T.
Endif

Return(nRea)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSBA3CBNV  ³ Autor ³ Padua             ³ Data ³ 07.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atender When do X3 do Campo BA3_COBNIV                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSBA3CBNV()
LOCAL lFlag := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o Codigo da empresa foi preenchido...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(M->BA3_CODEMP)
	if BG9->BG9_TIPO == "1"
		M->BA3_COBNIV :=  "1"
		lFlag:= .F.
	Else
		lFlag:= .T.
	Endif
Else
	lFlag:= .F.
Endif

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSAVERNIV  ³ Autor ³ Padua             ³ Data ³ 02.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Esta funcao ira tratar o nivel de cobranca do usuario      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodInt - Codigo da Instituicao                            ³±±
±±³          ³ cCodEmp - Codigo da Empresa                                ³±±
±±³          ³ cMat    - Matricula do Usuarios                            ³±±
±±³          ³ cTipCon - F = Fisica, J = Juridica                         ³±±
±±³          ³ cNumCon - Numero do Contrato                               ³±±
±±³          ³ cVerCon - Versao do Contrato                               ³±±
±±³          ³ cSubCon - Sub Contrato                                     ³±±
±±³          ³ cVerSub - Versao do Sub-Contrato                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[01] - Codigo do Cliente                               ³±±
±±³          ³ aRet[02] - Loja do Cliente                                 ³±±
±±³          ³ aRet[03] - Nome do Cliente                                 ³±±
±±³          ³ aRet[04] - Endereco 										  ³±±
±±³          ³ aRet[05] - Municipio 		    						  ³±±
±±³          ³ aRet[06] - Estado    			    					  ³±±
±±³          ³ aRet[07] - Natureza 										  ³±±
±±³          ³ aRet[08] - Bairro 										  ³±±
±±³          ³ aRet[09] - Estado 										  ³±±
±±³          ³ aRet[10] - CEP 						    				  ³±±
±±³          ³ aRet[11] - Telefone 										  ³±±
±±³          ³ aRet[12] - CGC 							    			  ³±±
±±³          ³ aRet[13] - Inscricao Estadual  				    		  ³±±
±±³          ³ aRet[14] - Tipo da Cobranca (2 - Aberta,1 - Fechada)		  ³±±
±±³          ³ aRet[15] - Tipo da Empresa  (1 - Fisica,2 - Juridica)	  ³±±
±±³          ³ aRet[16] - Dia do Vencimento                            	  ³±±
±±³          ³ aRet[17] - Tipo (1 - Cliente, 2 - Fornecedor)           	  ³±±
±±³          ³ aRet[18] - Nivel(6/Operadora(Intercambio)5Usuario/4Familia ³±±
±±³          ³                  /3SubCon/2Contr/1Empresa)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
Function PLSAVERNIV(cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub,_nTipFam,_cTipReg,lHelp,cEmpSQL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSql := ""
LOCAL aCliFor := {{	"ZZZZZZ",	"ZZ","","",	"",	"",	"",	"",	"",	"",	"",	"",	"",	" ",;
					" ", 0, "1", 	"1", " "}}
Local aArea   := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se e uma cobranca que vai ate o nivel de usuario...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT  _nTipFam := 0 // Default pois e para Familia
//1 para usuario
DEFAULT  _cTipReg := ""
DEFAULT  lHelp    := .T.
DEFAULT cEmpSQL	  := SM0->M0_CODIGO

If lVerNiv = Nil
	lVerNiv := ExistBlock("PLSVRNIV", .F., .F., )
Endif

If lVerNiv
	aCliFor[1] := ExecBlock("PLSVRNIV", .F., .F., { cCodInt,cCodEmp,cNumCon,cVerCon,;
	cSubCon,cVerSub,cMat,_cTipReg })
	If ValType(aCliFor[1]) = "A"
		Return aCliFor
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sql de leitura das tabelas...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cTipCon $ "J,2"
	if _nTipFam == 0
		//cSql += " SELECT BA3_CODINT, BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, "
		//cSql += " BG9_TIPO,BG9_CODCLI, BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR,"
		//cSql += " BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA, BT5_VENCTO, BT5_CODFOR, BT5_LOJFOR,"
		//cSql += " BQC_COBNIV, BQC_CODCLI, BQC_LOJA, BQC_VENCTO, BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI "
		//cSql += " FROM "+RetSqlName("BA3")+", "+RetSqlName("BG9")+" ,"+RetSqlName("BT5")+" ,"+RetSqlName("BQC")
		//cSql += " WHERE  BA3_FILIAL = '"+xFilial("BA3")+"' AND BG9_FILIAL ='"+xFilial("BG9")+"' AND " //INSERIDO
		//cSql += " BT5_FILIAL='"+xFilial("BT5")+"' AND BQC_FILIAL='"+xFilial("BQC")+"' AND " //INSERIDO
		//cSql += " BA3_CODEMP = BG9_CODIGO AND BA3_CODINT = BG9_CODINT AND "
		//cSql += " BA3_CODINT = BT5_CODINT AND BA3_CODEMP = BT5_CODIGO AND BA3_CONEMP = BT5_NUMCON AND "
		//cSql += " BA3_VERCON = BT5_VERSAO AND BA3_CODINT+BA3_CODEMP = BQC_CODIGO  AND BA3_CONEMP = BQC_NUMCON "
		//cSql += " AND BA3_VERCON = BQC_VERCON AND BA3_SUBCON = BQC_SUBCON AND BA3_VERSUB = BQC_VERSUB "
		//cSql += " AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' '"
		//cSql += " AND "+RetSqlName("BT5")+".D_E_L_E_T_ = ' ' AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' '"
		//cSql += " AND BA3_CODINT = '"+cCodInt+"' And BA3_CODEMP = '"+cCodEmp+"' And BA3_MATRIC = '"+cMat+"'"
		
		//otimizacao ORACLE
		cSql := " SELECT BA3_CODINT, BA1_CODINT, BA1_CODCLI, BA1_LOJA, BA1_COBNIV, BA1_VENCTO, BA1_CODFOR, BA1_LOJFOR,"
		cSql += "        BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR,  BG9_TIPO,BG9_CODCLI,"
		cSql += "        BG9_LOJA,   BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR,"
		cSql += "        BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA,   BT5_VENCTO, BT5_CODFOR, BT5_LOJFOR,"
		cSql += "        BQC_COBNIV, BQC_CODCLI, BQC_LOJA,   BQC_VENCTO, BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI"
		cSql += " FROM   "+RetFullName("BG9",cEmpSQL)+","+RetFullName("BT5",cEmpSQL)+","+RetFullName("BQC",cEmpSQL)+","+RetFullName("BA3",cEmpSQL)+","+RetFullName("BA1",cEmpSQL)
		cSql += " WHERE  BA3_FILIAL = BA1_FILIAL"
		cSql += " AND    BA3_CODINT = BA1_CODINT"
		cSql += " AND    BA3_CODEMP = BA1_CODEMP"
		cSql += " AND    BA3_MATRIC = BA1_MATRIC"
		cSql += " AND    BQC_FILIAL = BA3_FILIAL"
		cSql += " AND    BQC_CODIGO = BA3_CODINT || BA3_CODEMP"
		cSql += " AND    BQC_NUMCON = BA3_CONEMP"
		cSql += " AND    BQC_VERCON = BA3_VERCON"
		cSql += " AND    BQC_SUBCON = BA3_SUBCON"
		cSql += " AND    BQC_VERSUB = BA3_VERSUB"
		cSql += " AND    BT5_FILIAL = BQC_FILIAL"
		cSql += " AND    BT5_CODINT = BQC_CODINT"
		cSql += " AND    BT5_CODIGO = BQC_CODEMP"
		cSql += " AND    BT5_NUMCON = BQC_NUMCON"
		cSql += " AND    BT5_VERSAO = BQC_VERCON"
		cSql += " AND    BG9_FILIAL = BT5_FILIAL"
		cSql += " AND    BG9_CODINT = BT5_CODINT"
		cSql += " AND    BG9_CODIGO = BT5_CODIGO"
		cSql += " AND    "+RetFullName("BG9",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BT5",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BQC",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BA3",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BA1",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    BA1_FILIAL = '"+xFilial("BA1")+"'"
		cSql += " AND    BA1_CODINT = '"+cCodInt+"'"
		cSql += " AND    BA1_CODEMP = '"+cCodEmp+"'"
		cSql += " AND    BA1_MATRIC = '"+cMat+"'"
		
	Else
		//cSql += " SELECT BA3_CODINT, BA1_CODINT, BA1_CODCLI, BA1_LOJA, BA1_COBNIV, BA1_VENCTO, BA1_CODFOR, BA1_LOJFOR, "
		//CSql += " BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, "
		//cSql += " BG9_TIPO,BG9_CODCLI, BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR, "
		//cSql += " BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA, BT5_VENCTO, BT5_CODFOR, BT5_LOJFOR, "
		//cSql += " BQC_COBNIV, BQC_CODCLI, BQC_LOJA, BQC_VENCTO, BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI "
		//cSql += " FROM "+RetSqlName("BA1")+","+RetSqlName("BA3")+", "+RetSqlName("BG9")+", "+RetSqlName("BT5")+" ,"+RetSqlName("BQC")
		
		//cSql += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' AND " //INSERIDO 
		//cSql += " BA1_CODEMP = BA3_CODEMP AND BA1_CODINT = BA3_CODINT AND BA1_MATRIC = BA3_MATRIC AND"
		//cSql += " BA3_FILIAL = '"+xFilial("BA3")+"' AND " //INSERIDO 
		//cSql += " BA3_CODEMP = BG9_CODIGO AND BA3_CODINT = BG9_CODINT AND "
		//cSql += " BA3_CODINT = BT5_CODINT AND BA3_CODEMP = BT5_CODIGO AND BA3_CONEMP = BT5_NUMCON   AND BA3_VERCON = BT5_VERSAO "
		
		//cSql += " BG9_FILIAL ='"+xFilial("BG9")+"' AND BT5_FILIAL='"+xFilial("BT5")+"' AND "// INSERIDO
		//cSql += " BQC_FILIAL = '"+xFilial("BQC")+"' AND " //INSERIDO
		//cSql += " AND BA3_CODINT+BA3_CODEMP = BQC_CODIGO  AND BA3_CONEMP = BQC_NUMCON  AND BA3_VERCON = BQC_VERCON "
		//cSql += " AND BA3_SUBCON = BQC_SUBCON AND BA3_VERSUB = BQC_VERSUB "
		//cSql += " AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' '"
		//cSql += " AND "+RetSqlName("BT5")+".D_E_L_E_T_ = ' ' AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' ' AND "+RetSqlName("BA1")+".D_E_L_E_T_ = ' '"
		//cSql += " AND BA1_CODINT = '"+cCodInt+"' And BA1_CODEMP = '"+cCodEmp+"' And BA1_MATRIC = '"+cMat+"' And BA1_TIPREG = '"+_cTipReg+"'"  
		                   
		//otimizacao ORACLE
		cSql := " SELECT BA3_CODINT, BA1_CODINT, BA1_CODCLI, BA1_LOJA, BA1_COBNIV, BA1_VENCTO, BA1_CODFOR, BA1_LOJFOR,"
		cSql += "        BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR,  BG9_TIPO,BG9_CODCLI,"
		cSql += "        BG9_LOJA,   BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR,"
		cSql += "        BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA,   BT5_VENCTO, BT5_CODFOR, BT5_LOJFOR,"
		cSql += "        BQC_COBNIV, BQC_CODCLI, BQC_LOJA,   BQC_VENCTO, BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI"
		cSql += " FROM   "+RetFullName("BG9",cEmpSQL)+","+RetFullName("BT5",cEmpSQL)+","+RetFullName("BQC",cEmpSQL)+","+RetFullName("BA3",cEmpSQL)+","+RetFullName("BA1",cEmpSQL)
		cSql += " WHERE  BA3_FILIAL = BA1_FILIAL"
		cSql += " AND    BA3_CODINT = BA1_CODINT"
		cSql += " AND    BA3_CODEMP = BA1_CODEMP"
		cSql += " AND    BA3_MATRIC = BA1_MATRIC"
		cSql += " AND    BQC_FILIAL = BA3_FILIAL"
		cSql += " AND    BQC_CODIGO = BA3_CODINT || BA3_CODEMP"
		cSql += " AND    BQC_NUMCON = BA3_CONEMP"
		cSql += " AND    BQC_VERCON = BA3_VERCON"
		cSql += " AND    BQC_SUBCON = BA3_SUBCON"
		cSql += " AND    BQC_VERSUB = BA3_VERSUB"
		cSql += " AND    BT5_FILIAL = BQC_FILIAL"
		cSql += " AND    BT5_CODINT = BQC_CODINT"
		cSql += " AND    BT5_CODIGO = BQC_CODEMP"
		cSql += " AND    BT5_NUMCON = BQC_NUMCON"
		cSql += " AND    BT5_VERSAO = BQC_VERCON"
		cSql += " AND    BG9_FILIAL = BT5_FILIAL"
		cSql += " AND    BG9_CODINT = BT5_CODINT"
		cSql += " AND    BG9_CODIGO = BT5_CODIGO"
		cSql += " AND    "+RetFullName("BG9",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BT5",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BQC",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BA3",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    "+RetFullName("BA1",cEmpSQL)+".D_E_L_E_T_ = ' '
		cSql += " AND    BA1_FILIAL = '"+xFilial("BA1")+"'"
		cSql += " AND    BA1_CODINT = '"+cCodInt+"'"
		cSql += " AND    BA1_CODEMP = '"+cCodEmp+"'"
		cSql += " AND    BA1_MATRIC = '"+cMat+"'"
		cSql += " AND    BA1_TIPREG = '"+_cTipReg+"'"
				
	Endif
Else
	if _nTipFam == 0
		cSql += " SELECT BA3_CODINT, BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, "
		cSql += " BG9_TIPO,BG9_CODCLI,BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR"
		cSql += " BA3_LOJA FROM "+RetFullName("BA3",cEmpSQL)+","+RetFullName("BG9",cEmpSQL)
		cSql += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' AND BG9_FILIAL ='"+xFilial("BG9")+ "' " // INSERIDO
		cSql += " AND BA3_CODEMP = BG9_CODIGO AND BA3_CODINT = BG9_CODINT "
		cSql += " AND "+RetFullName("BA3",cEmpSQL)+".D_E_L_E_T_ = ' ' AND "+RetFullName("BG9",cEmpSQL)+".D_E_L_E_T_ = ' '"
		cSql += " AND BA3_CODINT = '"+cCodInt+"' And BA3_CODEMP = '"+cCodEmp+"' And BA3_MATRIC = '"+cMat+"'"
	Else
		cSql += " SELECT BA3_CODINT, BA1_CODINT, BA1_CODCLI, BA1_LOJA, BA1_COBNIV, BA1_VENCTO, BA1_CODFOR, BA1_LOJFOR, "
		cSql += " BA3_CODCLI, BA3_LOJA, BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, "
		cSql += " BG9_TIPO, BG9_CODCLI, BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_CODFOR"
		cSql += " BA3_LOJA FROM "+RetFullName("BA3",cEmpSQL)+","+RetFullName("BG9",cEmpSQL)+", "+RetFullName("BA1",cEmpSQL)
		cSql += " WHERE BA1_FILIAL = '"+xFilial("BA1")+"' AND BA3_FILIAL = '"+xFilial("BA3")+"' AND BG9_FILIAL ='"+xFilial("BG9")+ "' " // INSERIDO
		cSql += " AND BA3_CODEMP = BG9_CODIGO AND BA3_CODINT = BG9_CODINT AND "
		cSql += " BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC"
		cSql += " AND "+RetFullName("BA3",cEmpSQL)+".D_E_L_E_T_ = ' ' AND "+RetFullName("BG9",cEmpSQL)+".D_E_L_E_T_ = ' ' AND "+RetFullName("BA1",cEmpSQL)+".D_E_L_E_T_ = ' '"
		cSql += " AND BA1_CODINT = '"+cCodInt+"' And BA1_CODEMP = '"+cCodEmp+"' And BA1_MATRIC = '"+cMat+"' And BA1_TIPREG = '"+_cTipReg+"'"
	Endif
Endif
PlsQuery (cSql,"TrbVNV")

if TrbVNV->(EOF())
	If lHelp
		//Help("",1,"PLSAVNSQL")
	Endif
	TrbVNV->(DbCloseArea())
	RestArea(aArea)
	Return(aCliFor)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz as Verificacoes de Niveis de acordo com o tipo de contrato...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cTipCon $ "F,1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso a cobranca esteja no nivel da Familia...                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if _nTipFam == 1 .And. TrbVNV->BA1_COBNIV == "1"  .And. (!Empty(TrbVNV->BA1_CODCLI) .OR. !Empty(TrbVNV->BA1_CODFOR)) // Usuario
		if !Empty(TrbVNV->BA1_CODCLI)
			aCliFor := PLSAPGEND(TrbVNV->BA1_CODCLI,TrbVNV->BA1_LOJA,"1",TrbVNV->BG9_TIPO,TrbVNV->BA1_VENCTO,"5",,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Else
			aCliFor := PLSARCEND(TrbVNV->BA1_CODFOR,TrbVNV->BA1_LOJFOR,"1",TrbVNV->BG9_TIPO,TrbVNV->BA1_VENCTO,"5")
		Endif
	Elseif TrbVNV->BA3_COBNIV == "1"  .And. (!Empty(TrbVNV->BA3_CODCLI) .OR. !Empty(TrbVNV->BA3_CODFOR)) // Familia
		if !Empty(TrbVNV->BA3_CODCLI)
			aCliFor := PLSAPGEND(TrbVNV->BA3_CODCLI,TrbVNV->BA3_LOJA,"2",TrbVNV->BG9_TIPO,TrbVNV->BA3_VENCTO,"4",,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Else
			aCliFor := PLSARCEND(TrbVNV->BA3_CODFOR,TrbVNV->BA3_LOJFOR,"2",TrbVNV->BG9_TIPO,TrbVNV->BA3_VENCTO,"4")
		Endif
	Else
		If lHelp
			//Help("",1,"PLSVNPFI")
		Endif
		TrbVNV->(DbCloseArea())
		RestArea(aArea)
		Return(aCliFor)
	Endif
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e intercambio eventual...                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If TrbVNV->BT5_INTERC == "1" .And. AllTrim(TrbVNV->BT5_TIPOIN) == GetNewPar("MV_PLSCDIE","1")// Eventual
		BA0->(DbSetOrder(1))
		BA1->(DbSetOrder(2))
		If _cTipReg # Nil .And. 	BA1->(MsSeek(xFilial("BA1") + cCodInt + cCodEmp +;
									cMat + _cTipReg))
			BA0->(MsSeek(xFilial("BA0") + BA1->BA1_OPERES))
		Else
			BA0->(MsSeek(xFilial("BA0") + TrbVNV->BA3_CODINT))
		Endif
		BA1->(DbSetOrder(1))
		
		If BA0->BA0_TIPVEN == "1"
			aCliFor := PLSAPGEND(BA0->BA0_CODCLI,BA0->BA0_LOJCLI,"1",TrbVNV->BG9_TIPO,BA0->BA0_VENCTO,"4",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Else
			aCliFor := PLSAPGEND(BA0->BA0_CODCLI,BA0->BA0_LOJCLI,"1",TrbVNV->BG9_TIPO,Day(dDataBase)+BA0->BA0_VENCTO,"4",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a cobranca esteja no nivel da Familia...                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if     _nTipFam == 1 .And. TrbVNV->BA1_COBNIV == "1"  .And. (!Empty(TrbVNV->BA1_CODCLI) .Or. !Empty(TrbVNV->BA1_CODFOR)) // Usuario
			if !Empty(TrbVNV->BA1_CODCLI)
				aCliFor := PLSAPGEND(TrbVNV->BA1_CODCLI,TrbVNV->BA1_LOJA,"1",TrbVNV->BG9_TIPO,TrbVNV->BA1_VENCTO,"5",TrbVNV->BQC_GRATUI,,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
			Else
				aCliFor := PLSARCEND(TrbVNV->BA1_CODFOR,TrbVNV->BA1_LOJFOR,"1",TrbVNV->BG9_TIPO,TrbVNV->BA1_VENCTO,"5",TrbVNV->BQC_GRATUI)
			Endif
		Elseif TrbVNV->BA3_COBNIV == "1"  .And. (!Empty(TrbVNV->BA3_CODCLI) .Or. !Empty(TrbVNV->BA3_CODFOR)) // Familia
			if !Empty(TrbVNV->BA3_CODCLI)
				aCliFor := PLSAPGEND(TrbVNV->BA3_CODCLI,TrbVNV->BA3_LOJA,if(_nTipFam == 1,"1","2"),TrbVNV->BG9_TIPO,TrbVNV->BA3_VENCTO,"4",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
			Else
				aCliFor := PLSARCEND(TrbVNV->BA3_CODFOR,TrbVNV->BA3_LOJFOR,if(_nTipFam == 1,"1","2"),TrbVNV->BG9_TIPO,TrbVNV->BA3_VENCTO,"4",TrbVNV->BQC_GRATUI)
			Endif
		Elseif TrbVNV->BQC_COBNIV == "1"  .And. (!Empty(TrbVNV->BQC_CODCLI) .OR. !Empty(TrbVNV->BQC_CODFOR)) //Sub-Conbtrato
			if !Empty(TrbVNV->BQC_CODCLI)
				aCliFor := PLSAPGEND(TrbVNV->BQC_CODCLI,TrbVNV->BQC_LOJA,'',TrbVNV->BG9_TIPO,TrbVNV->BQC_VENCTO,"3",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
			Else
				aCliFor := PLSARCEND(TrbVNV->BQC_CODFOR,TrbVNV->BQC_LOJFOR,'',TrbVNV->BG9_TIPO,TrbVNV->BQC_VENCTO,"3",TrbVNV->BQC_GRATUI)
			Endif
		Elseif TrbVNV->BT5_COBNIV == "1" .And. (!Empty(TrbVNV->BT5_CODCLI) .Or. !Empty(TrbVNV->BT5_CODFOR)) //Contrato
			if !Empty(TrbVNV->BT5_CODCLI)
				aCliFor := PLSAPGEND(TrbVNV->BT5_CODCLI,TrbVNV->BT5_LOJA,'',TrbVNV->BG9_TIPO,TrbVNV->BT5_VENCTO,"2",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
			Else
				aCliFor := PLSARCEND(TrbVNV->BT5_CODFOR,TrbVNV->BT5_LOJFOR,'',TrbVNV->BG9_TIPO,TrbVNV->BT5_VENCTO,"2",TrbVNV->BQC_GRATUI)
			Endif
		Elseif (!Empty(TrbVNV->BG9_CODCLI) .Or. !Empty(TrbVNV->BG9_CODFOR))   //Empresa
			if !Empty(TrbVNV->BG9_CODCLI)
				aCliFor := PLSAPGEND(TrbVNV->BG9_CODCLI,TrbVNV->BG9_LOJA,'',TrbVNV->BG9_TIPO,TrbVNV->BG9_VENCTO,"1",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
			Else
				aCliFor := PLSARCEND(TrbVNV->BG9_CODFOR,TrbVNV->BG9_LOJA,'',TrbVNV->BG9_TIPO,TrbVNV->BG9_VENCTO,"1",TrbVNV->BQC_GRATUI)
			Endif
		Endif
	Endif

	If 	TrbVNV->BT5_INTERC == "1" .And. AllTrim(TrbVNV->BT5_TIPOIN) <> GetNewPar("MV_PLSCDIE","1") .And.;
		aCliFor[1][1] == "ZZZZZZ"
		BA0->(DbSetOrder(1))
		BA1->(DbSetOrder(2))
		If _cTipReg # Nil .And. 	BA1->(MsSeek(xFilial("BA1") + cCodInt + cCodEmp +;
									cMat + _cTipReg))
			BA0->(MsSeek(xFilial("BA0") + BA1->BA1_OPERES))
		Else
			BA0->(MsSeek(xFilial("BA0") + TrbVNV->BA3_CODINT))
		Endif
		BA1->(DbSetOrder(1))
		
		If BA0->BA0_TIPVEN == "1"
			aCliFor := PLSAPGEND(BA0->BA0_CODCLI,BA0->BA0_LOJCLI,"1",TrbVNV->BG9_TIPO,BA0->BA0_VENCTO,"4",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Else
			aCliFor := PLSAPGEND(BA0->BA0_CODCLI,BA0->BA0_LOJCLI,"1",TrbVNV->BG9_TIPO,Day(dDataBase)+BA0->BA0_VENCTO,"4",TrbVNV->BQC_GRATUI,,,,,cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub)
		Endif
	Endif
Endif
TrbVNV->(DbCloseArea())
RestArea(aArea)
Return(aCliFor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSAPGEND   ³ Autor ³ Padua             ³ Data ³ 02.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados dos Clientes                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSAPGEND(	cCodCli, cLoja, cCobTip,cTipoEmp,nDiaVencto,_cNivel,;
				    cGratuito, cCondPag, cTpVcPP, nVencCO, cTpVcCO,cCodInt,;
				    cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub,cMdFatPt)
LOCAL aRet    := {}
LOCAL aAreaSA1		:= SA1->(GetArea())
LOCAL aAreaBQC		:= BQC->(GetArea())
LOCAL aAreaBA3		:= BA3->(GetArea())
LOCAL aAreaBA1		:= BA1->(GetArea())

LOCAL cTit	  := GetNewPar("MV_PLCDTIT","T")
LOCAL cEnd	  := GetNewPar("MV_PLSEND","")

DEFAULT cGratuito 	:= '0'
DEFAULT cTpVcPP 	:= ''
DEFAULT nVencCO		:= 0
DEFAULT cTpVcCO		:= ''
DEFAULT cCodInt		:= ''
DEFAULT cCodEmp		:= ''
DEFAULT cMat		:= ''
DEFAULT cTipCon		:= ''
DEFAULT cNumCon		:= ''
DEFAULT cVerCon		:= ''
DEFAULT cSubCon		:= ''
DEFAULT cVerSub		:= ''
DEFAULT cMdFatPt	:= ''
DEFAULT _cNivel     := '4'
DEFAULT nDiaVencto  := '0'

If SA1->(MsSeek(xFilial("SA1")+cCodCli+cLoja))
	aadd (aRet, {SA1->A1_COD,; //1
	SA1->A1_LOJA,;       		//2
	SA1->A1_NOME,;              //3
	SA1->A1_END,;               //4
	SA1->A1_MUN,;               //5
	SA1->A1_EST,;               //6
	SA1->A1_NATUREZ,;           //7
	SA1->A1_BAIRRO,;            //8
	SA1->A1_ESTADO,;            //9
	SA1->A1_CEP,;			    //10
	SA1->A1_DDD+SA1->A1_TEL,;   //11
	SA1->A1_CGC,;               //12
	SA1->A1_INSCR,;             //13
	cCobTip,;                   //14
	cTipoEmp,;                  //15
	nDiaVencto,;                //16
	"1",;                       //17
	_cNivel,;                   //18
	cGratuito,;                 //19
	cCondPag,;                  //20
	'',;                        //21
	'',;                        //22
	'',;                        //23
	'',;                        //24
	'',;                        //25
	'',;                        //26
	'',;                        //27
	cTpVcPP,;                   //28
	nVencCO,;                   //29      
	cTpVcCO,;                   //30       
	'',;                   		//31  Sempre criando em branco por isso foi retirado o CriaVar("BA3_NUMERO")  para aumento de performance
	SA1->A1_COD_MUN,;			//32
	cMdFatPt,;		            //33
    {}})						//34             
    
Else	
	aadd (aRet,;
	{"ZZZZZZ",;
	"ZZ",;
	"",;
	"",;
	"",;                
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	cCobTip,;
	cTipoEmp,;
	nDiaVencto,;
	"1",;
	_cNivel,;
	cGratuito,;
	cCondPag,;
	'',;
	'',;
	'',;
	'',;
	'',;
	'',;
	'',;
	cTpVcPP,;
	nVencCO,;
	cTpVcCO,;                   //30
	'',;                	   //31  Sempre criando em branco por isso foi retirado o CriaVar("BA3_NUMERO")  para aumento de performance
	'',;                        //32
	cMdFatPt,; 	               	//33
	{}})						//34
	
Endif

If aRet[1,1] <> "ZZZZZZ" 
	Do Case
		 Case _cNivel == '3' 
		 	BQC->(DbSetOrder(1))
		 	If	BQC->(DbSeek(xFilial("BQC")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub)) .AND.;
		 		BQC->BQC_ENDCOB = "2"
		 		aRet[1,4] := BQC->BQC_LOGRAD
		 		aRet[1,5] := BQC->BQC_MUN
		 		aRet[1,6] := BQC->BQC_ESTADO
		 		aRet[1,8] := BQC->BQC_BAIRRO
		 		aRet[1,10]:= BQC->BQC_CEP
		 		aRet[1,11]:= BQC->BQC_TEL
	 			aRet[1,31]:= BQC->BQC_NUMERO
		 		aRet[1,32]:= BQC->BQC_CODMUN
		 	EndIf
	   	 Case BA3->(DbSeek(xFilial("BA3")+cCodInt+cCodEmp+cMat+cNumCon+cVerCon+cSubCon+cVerSub))
	   	 	If 	BA3->BA3_ENDCOB = "2" .And.;
	   	 		BA1->(DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMat+AllTrim(cTit)))
	   	 		If Alltrim(cEnd) == "1"
		   	 		aRet[1,4] := BA1->BA1_ENDERE
	   	 		Else
	   	 			aRet[1,4] := SA1->A1_END //BA3->BA3_END
	   	 		Endif
		 		aRet[1,5] := BA1->BA1_MUNICI
		 		aRet[1,6] := BA1->BA1_ESTADO
		 		aRet[1,8] := BA1->BA1_BAIRRO
		 		aRet[1,10]:= BA1->BA1_CEPUSR
		 		aRet[1,11]:= BA1->(BA1_DDD+BA1_TELEFO)	   
		 		aRet[1,31]:= BA1->BA1_NR_END
		 		aRet[1,32]:= BA1->BA1_CODMUN	 		
	   	 	ElseIf BA3->BA3_ENDCOB = "3"  
		   	 	aRet[1,4] := BA3->BA3_END
		 		aRet[1,5] := BA3->BA3_MUN
		 		aRet[1,6] := BA3->BA3_ESTADO
		 		aRet[1,8] := BA3->BA3_BAIRRO
		 		aRet[1,10]:= BA3->BA3_CEP
		 		aRet[1,11]:= ""   
		 		aRet[1,31]:= BA3->BA3_NUMERO
		 		aRet[1,32]:= BA3->BA3_CODMUN	 		
	   	    EndIf
	EndCase 
Endif
	

RestArea(aAreaSA1)
RestArea(aAreaBQC)
RestArea(aAreaBA3)
RestArea(aAreaBA1) 

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSARCEND   ³ Autor ³ Padua             ³ Data ³ 24.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados dos Fornecedores                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSARCEND(cCodFor, cLoja, cCobTip,cTipoEmp,nDiaVencto,_cNivel, cGratuito, cCodPag)
LOCAL aRet    := {}
LOCAL aAreaSA2		:= SA2->(GetArea())


DEFAULT cGratuito := "0"

SA2->(DbSetOrder(1))
if SA2->(MsSeek(xFilial("SA2")+cCodFor+cLoja))
	aadd (aRet, {SA2->A2_COD,;
	SA2->A2_LOJA,;
	SA2->A2_NOME,;
	SA2->A2_END,;
	SA2->A2_MUN,;
	SA2->A2_EST,;
	SA2->A2_NATUREZ,;
	SA2->A2_BAIRRO,;
	SA2->A2_ESTADO,;
	SA2->A2_CEP,;
	SA2->A2_TEL,;
	SA2->A2_CGC,;
	SA2->A2_INSCR,;
	cCobTip,;
	cTipoEmp,;
	nDiaVencto,;
	"2",;
	_cNivel,;
	cGratuito,;
	cCodPag})
Else	
	aadd (aRet,;
	{"ZZZZZZ",;
	"ZZ",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	cCobTip,;
	cTipoEmp,;
	nDiaVencto,;
	"1",;
	_cNivel,;
	cGratuito,;
	cCodPag})
Endif
RestArea(aAreaSA2) 
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLAUEM  ³ Autor ³ Antonio de Padua  ³ Data ³ 23.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o percentual de Aumento de empresa...              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLAUEM(cCodInt,cCodEmp,cMatric,cTipReg,cAno,cMes,dDataInc,aRet,cConEmp,;
cVerCon,cTipoGru,cNome,cNomeEve,cSexo,cGrauPar,nRecBA1,cTipUsu,cDigito,cSubCon,;
cVerSub,cAliasBA1,aBfq)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nInd
LOCAL cSQL
LOCAL cCodLan    	:= "106"
LOCAL nVlrDeb    	:= 0
LOCAL nVlrCre    	:= 0
LOCAL nVlrBase   	:= 0
LOCAL cMatricUsr 	:= cCodInt+cCodEmp+cMatric+cTipReg+cDigito
LOCAL lFound     	:= .F.
LOCAL nRet    		:= nLoop := 0
LOCAL nPerPad		:= 0
Local nTotal 	 	:= 0
Local cForma		:= ""
Local nBfr 		    := nCodBfr := 0
Local nCodBfr
Local lReajuste     := .F.

nBfr := RetPosBfr(cCodInt, cCodLan)

For nCodBfr := 1 To Len(_aBfr[nBfr][2])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelo valor base...                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDeb  := 0
	nVlrCre  := 0
	
/* Novo Tratamento Reajuste
	nRet	 := 0
	nPerPad  := 0
	For nLoop := 1 To Len(aRet)
		If 	aRet[nLoop][3]==_aBfr[nBfr][2][nCodBfr] .And.;
			cMatricUsr = aRet[nLoop][7] .And. aRet[nLoop][9] .And.;
			ValType(aRet[nLoop][19]) = "N" .And. aRet[nLoop][19] > 0	// Reajuste
			nPerPad := aRet[nLoop][19]
			If aRet[nLoop][1] = "1"
				nVlrDeb += aRet[nLoop][2]
			ElseIf aRet[nLoop][1] = "2"
				nVlrCre += aRet[nLoop][2]
			Endif
			nRet += Round((aRet[nLoop][2] * nPerPad) / 100, 2)
			aRet[nLoop][2] -= Round((aRet[nLoop][2] * nPerPad) / 100, 2)
		Endif
	Next
*/

	aEval(aRet,{ |x| nVlrCre := nVlrCre + If( (x[3]==_aBfr[nBfr][2][nCodBfr] .And. x[1] == "1" .And. cMatricUsr = x[7] .And. x[9] ),x[2],0), ;
	nVlrDeb := nVlrDeb + If( (x[3]==_aBfr[nBfr][2][nCodBfr] .And. x[1] == "2" .And. cMatricUsr = x[7] .And. x[9] ),x[2],0)  })
	
	If nVlrCre > nVlrDeb
		nVlrBase := (nVlrCre - nVlrDeb)
	Else
		nVlrBase := (nVlrDeb - nVlrCre)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Agora ja com o valor base vou calcular de acordo com regras...      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/* Novo Tratamento Reajuste
	If nPerPad > 0 .And. nVlrBase > 0 .And. nRet > 0
		aadd(aRet,{aBfq[nBFQ_DEBCRE],;
		nRet,;
		aBfq[nBFQ_CODLAN],;
		_aBfr[nBfr][2][nCodBfr],;
		cNomeEve,;
		AllTrim(Str(nPerPad)) + " %",;
		cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
		cNome,;
		.T.,;
		cSexo,;
		cGrauPar,;
		0,;
		"",;
		"6",;
		cTipUsu,;
		"BFQ",;
		_aBfr[nBfr][2][nCodBfr],;
		PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nRet),;
		0.00})
	Endif
*/
	/*  ------------ Função PlsRetRej não compilada no RPO -------------------
	
	lReajuste := PlsRetRej(	aRet, cCodInt, cCodEmp, cConEmp, cVerCon, cSubCon,;
							cVerSub, BA3->BA3_MATRIC, cTipReg, cDigito, cNome,;
							cSexo, cGrauPar, cTipUsu, BA3->BA3_CODPLA,;
							BA3->BA3_VERSAO, cAno, cMes, cAliasBA1, @nVlrBase,;
							_aBfr[nBfr][2][nCodBfr], dDataInc, @nTotal, @nPerPad,;
							@cForma)
	*/
	If lReajuste .And. nVlrBase > 0
		nRet := CalcAuEmp(dDataInc,nVlrBase,cAno,cMes,cForma,nPerPad)
		If nRet > 0
			nTotal += nRet
			aadd(aRet,{aBfq[nBFQ_DEBCRE],;
			nRet,;
			aBfq[nBFQ_CODLAN],;
			_aBfr[nBfr][2][nCodBfr],;
			cNomeEve,;
			AllTrim(Str(nPerPad)) + " %",;
			cCodInt+cCodEmp+cMatric+cTipReg+cDigito,;
			cNome,;
			.T.,;
			cSexo,;
			cGrauPar,;
			0,;
			"",;
			"6",;
			cTipUsu,;
			"BFQ",;
			_aBfr[nBfr][2][nCodBfr],;
			PlsBaseIR(aBfq[nBFQ_INCIR], aBfq[nBFQ_REGCIR], nRet),;
			0.00 })
		Endif

	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nTotal)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CalcAuEmp  ³ Autor ³ Antonio de Padua  ³ Data ³ 23.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o reajuste de Empresas...                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcAuEmp(dDataInc,nVlrBase,cAno,cMes,cForma,nPerPad)

LOCAL cAnoFim
LOCAL cMesFim
LOCAL cAnoIni
LOCAL cMesIni
LOCAL nRes
LOCAL lReaj
//LOCAL nReaj
LOCAL nRea  := 0

if cForma == "2"
	//Verifico os meses (caso nao seja incondicional)
	cAnoFim := cAno
	cMesFim := cMes
	
	cAnoIni := Subs(dtos(dDataInc),1,4)
	cMesIni := Subs(dtos(dDataInc),5,2)
		
	nRes    := PLSDIFANOS(cAnoIni,cMesIni,cAnoFim,cMesFim,"M")
	
	If nRes < 12
		Return(0)
   	Endif
Endif
nRea  := 0
If cAno + cMes >= Left(dtos(dDataInc),6)	// Nao incluo reajuste negociado no mes da
	nRea := ((nVlrBase*nPerPad)/100)		// inclusao do usuario
	lReaj:= .T.
Endif

Return(nRea)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLRAGR  ³ Autor ³ Antonio de Padua  ³ Data ³ 01.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de Agravo do Usuario...                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRAGR(cCodint,cCodEmp,cMatric,cTipReg,cMes,cAno,lCarrega)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nValor := 0, dData
Local aArea  := GetArea()

DEFAULT lCarrega := .F.

If lCarrega
	aBf3 := {}
	cSql := "SELECT * FROM " + RetSqlName("BF3") + " BF3, " +;
			RetSqlName("BA1") + " BA1 WHERE BF3_FILIAL = '" +;
			xFilial("BF3") + "' AND BF3_CODINT = '" + cCodInt + "' AND " +;
			"BF3_CODEMP = '" + cCodEmp + "' AND BF3_PAGAGR = '1' AND " +;
			"BA1_CODINT = BF3_CODINT AND BA1_CODEMP = BF3_CODEMP AND " +;
			"BA1_MATRIC = BF3_MATRIC AND BA1_TIPREG = BF3_TIPREG AND "
//			"BF3_CONEMP = '" + cConEmp + "' AND BF3_VERCON = '" + cVerCon + "' AND " +;
//			"BF3_SUBCON = '" + cSubCon + "' AND BF3_VERSUB = '" + cVerSub + "' AND "
//    	   	x[4] = cConEmp .And. x[5] = cVerCon .And. x[6] = cSubCon .And. x[7] = cVerSub
	If ! Empty(cMatric)
		cSql += "BF3_MATRIC = '" + cMatric + "' AND "
	Endif
	cSql += "BF3.D_E_L_E_T_ = ' '"
	PlsQuery(cSql,"BF3QRY")

	While ! BF3QRY->(Eof())
		dData := BF3QRY->BA1_DATINC
		If BF3QRY->BF3_UNAGR = "4"	// Anos
			dData := Ctod(Left(Dtoc(dData), 6) + Str(Year(dData) + BF3QRY->BF3_MESAGR, 4))
		ElseIf BF3QRY->BF3_UNAGR = "3"	// Meses
			dData := SomaMeses(dData,BF3QRY->BF3_MESAGR)
		ElseIf BF3QRY->BF3_UNAGR = "2"	// Dias
			dData += BF3QRY->BF3_MESAGR
		ElseIf BF3QRY->BF3_UNAGR = "1"	// Horas
			SomaDiaHor(@dData, "24:00", BF3QRY->BF3_MESAGR)
		Endif
		nValor := 0
		if StrZero(Year(dData),4)+StrZero(Month(dData),2) >= cAno+cMes
			nValor := BF3QRY->BF3_VALAGR
		Endif
		
		If nValor > 0
       		nPos := Ascan(aBF3, {|x| 	x[1] = cCodEmp .And. x[2] = cMatric .And.;
	        							x[3] = BF3QRY->BF3_TIPREG })
	   	    If nPos = 0
 				Aadd(aBF3, { cCodEmp, cMatric, BF3QRY->BF3_TIPREG, nValor })
		   	Else
    	 		aBF3[nPos][4] += nValor
			Endif
		Endif
		
		BF3QRY->(DbSkip())
	Enddo
	aBF3 := ASort(aBF3,,, { |x,y| 	x[2] < y[2] .And. x[3] < y[3] })
	BF3QRY->(DbCloseArea())
	RestArea(aArea)
Else
	nPos := Ascan(aBF3, { |x| x[2] = cMatric .And. x[3] = cTipReg})
	nValor := 0
	If nPos > 0
		nValor := aBF3[nPos][4]
	Endif
Endif	
	
Return(nValor)

Static Function SomaMeses(_dData,nNumMes)
Local i
nMes := Month(_dData)
nAno := Year(_dData)
nDia := Day(_dData)
For I := 1 to nNumMes
	if nMes < 12
		nMes := nMes + 1
	Else
		nMes := 1
		nAno := nAno +1
	Endif
Next
_dData := ctod(StrZero(nDia,2)+"/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))
if Day(_dData)  == 0 //Data Invalida
	if nDia > 28
		While Day(_dData) == 0
			nDia := nDia - 1
			_dData := ctod(StrZero(nDia,2)+"/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))
		Enddo
	Endif
Endif
Return(_dData)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSVLROPC  ³ Autor ³ Antonio de Padua  ³ Data ³ 14.11.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor do Opcional um usuario...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLROPC(cCodInt,cCodEmp,cMatric,cTipReg,cCodPla,cVerPla,cCodPro,cVerPro)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cForPag := BA3->BA3_FORCOP, _cNivel := ""

cTipoGru := BG9->BG9_TIPO

If ! Empty(BA3->BA3_NIVFOP)
	_cNivel := BA3->BA3_NIVFOP
Else
	BYX->(DbSetOrder(1))
	If BYX->(MsSeek(xFilial("BYX")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cTipReg+cCodPro+cVerPro+cForPag))
		_cNivel  := "4" // Familia
	Endif

	BK0->(DbSetOrder(1))
	If 	Empty(_cNivel) .And.;
		BK0->(MsSeek(xFilial("BK0")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cCodPro+cVerPro+cForPag))
		_cNivel  := "3" // Familia
	Endif

	If Empty(_cNivel)
		If cTipoGru == "2"
			BJW->(DbSetOrder(1))
			If BJW->(MsSeek(xFilial("BJW")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)+cCodPro+cVerPro+cForPag))
				_cNivel  := "2" // Grupo/Empresa
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso seja pessoa fisica (branco) ou nao exista na empresa...        ³
	//³ procuro no produto saude...                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(_cNivel)
		BJY->(DbSetOrder(1))
		If BJY->(MsSeek(xFilial("BJY")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+cCodPro+cVerPro+cForPag))
			_cNivel  := "1" // Produto
		Endif
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso nao seja encontrado a forma de pagto aborto...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cForPag)
	Return({.F.,0})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciono no cadastro da forma selecionada...                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BJ0->(DbSetOrder(1))

If ! BJ0->(MsSeek(xFilial("BJ0")+cForPag+_cNivel))
	Return({.F.,0})
Else
	cRdmake := AllTrim(BJ0->BJ0_ROTINA)
Endif

If cRdmake = "PLVLROPC"
	aAux := PlVlrOpc(cCodInt,cCodEmp,cMatric,cTipReg,_cNivel,cCodPla,cVerPla,cCodPro,cVerPro,cForPag)
Else
	aAux := ExecBlock(cRdmake,.F.,.F.,{cCodInt,cCodEmp,cMatric,cTipReg,_cNivel,cCodPla,cVerPla,cCodPro,cVerPro,cForPag})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({aAux[1],aAux[2],aAux[3],aAux[4],aAux[5]})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCOBPrd  ³ Autor ³Wagner Mobile Costa³ Data ³ 08.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a forma de cobranca de um produto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCOBPrd(cCodInt, cCodPla, cVersao, cForPag, cFaiFam)

Local aRet := {}, cSql
Local aArea := GetArea()

cFaiFam := If(Empty(cFaiFam), "0", cFaiFam)

If cFaiFam = "2"	// Ambos
	cSQL := "SELECT * FROM " + BB3->(RetSQLName("BB3"))+" WHERE "
	cSQL += "BB3_FILIAL = '"+xFilial("BB3")+"' AND "
	cSQL += "BB3_CODIGO = '"+cCodInt+cCodPla+"' AND BB3_VERSAO = '"+cVersao+"' AND "
	cSQL += "BB3_FAIFAM = '1' AND BB3_CODFOR = '" + cForPag + "' AND D_E_L_E_T_= ' ' "
	cSQL += "ORDER BY BB3_TIPUSR DESC, BB3_SEXO DESC "
		
	PLSQuery(cSQL,"TrbBB3")
	If Eof()
		TrbBB3->( DbCloseArea() )
		RestArea(aArea)
		cSQL := "SELECT * FROM " + BB3->(RetSQLName("BB3"))+" WHERE "
		cSQL += "BB3_FILIAL = '"+xFilial("BB3")+"' AND "
		cSQL += "BB3_CODIGO = '"+cCodInt+cCodPla+"' AND BB3_VERSAO = '"+cVersao+"' AND "
		cSQL += "BB3_FAIFAM = '0' AND BB3_CODFOR = '" + cForPag + "' AND "
		cSQL += "BB3_TABVLD = ' ' AND D_E_L_E_T_= ' ' "
		cSQL += "ORDER BY BB3_TIPUSR DESC, BB3_SEXO DESC "
		
		PLSQuery(cSQL,"TrbBB3")
	Endif
Else
	cSQL := "SELECT * FROM " + BB3->(RetSQLName("BB3"))+" WHERE "
	cSQL += "BB3_FILIAL = '"+xFilial("BB3")+"' AND "
	cSQL += "BB3_CODIGO = '"+cCodInt+cCodPla+"' AND BB3_VERSAO = '"+cVersao+"' AND "
	cSQL += "BB3_FAIFAM = '" + cFaiFam + "' AND BB3_CODFOR = '" + cForPag + "' AND "
	cSQL += "BB3_TABVLD = ' ' AND D_E_L_E_T_= ' ' "
	cSQL += "ORDER BY BB3_TIPUSR DESC, BB3_SEXO DESC "
		
	PLSQuery(cSQL,"TrbBB3")
Endif
	
While ! Eof()
	Aadd(aRet, { 	BB3_TIPUSR, BB3_SEXO, BB3_IDAINI, BB3_IDAFIN, BB3_VALFAI,;
					BB3_FAIFAM, BB3_QTDMIN, BB3_QTDMAX,BB3_CODFAI })
	DbSkip()
EndDo
TrbBB3->( DbCloseArea() )
RestArea(aArea)
Return aRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLHISREA   ³ Autor ³Wagner Mobile Costa³ Data ³ 23.09.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta historico reajuste para a familia                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLHISREA(cMatric, cAno, cMes, cCONEMP, cVERCON, cSUBCON, cVERSUB)

Local cArea := Alias()
Local aArea := GetArea()

aDadBM1 := {}
aCabBM1 := {}

BM1->(DbSetOrder(3))
cSQL := "SELECT * FROM "+RetSQLName("BM1")+" WHERE "
cSQL += "BM1_FILIAL = '"+xFilial("BM1")+"' AND "
cSQL += "BM1_CODINT + BM1_CODEMP + BM1_MATRIC = '"+cMatric+"' AND "
cSQL += "BM1_ANO + BM1_MES <= '"+cAno+cMes+"' AND "
cSQL += "BM1_CONEMP = '"+cConEmp+"' AND "
cSQL += "BM1_VERCON = '"+cVerCon+"' AND "
cSQL += "BM1_SUBCON = '"+cSubCon+"' AND "
cSQL += "BM1_VERSUB = '"+cVerSub+"' AND "
cSQL += "BM1_CODTIP IN ('105','106') AND D_E_L_E_T_ = ' ' "
cSQL += "ORDER BY " + BM1->(IndexKey())

BM1->(DbSetOrder(1))
BM1->(PLSQuery(cSQL,"BM1QRY"))

Store Header "BM1" TO aCabBM1 For AllTrim(X3_CAMPO) $ "BM1_MATUSU,BM1_NOMUSR,BM1_MES,BM1_ANO,BM1_VALOR,BM1_CODTIP,BM1_CODEVE,BM1_DESEVE"
Store COLS "BM1QRY" TO aDadBM1 FROM aCabBM1 While ! BM1QRY->(Eof())

If Len(aDadBM1) = 0
	Store COLS Blank "BM1" TO aDadBM1 FROM aCabBM1
Endif
BM1QRY->(DbCloseArea())
RestArea(aArea)

DEFINE MSDIALOG oUsr TITLE STR0017 FROM 000,000 TO 320,635 OF oMainWnd PIXEL //"Historico de Reajustes"

oGetBM1 := TPLSBrw():New(005,007,310,140,nil  ,oUsr,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBM1  ,aDadBM1,.F.      ,"BM1" ,K_Visualizar,STR0018,nil,nil,nil,nil) //"Usuarios Selecionados"

oSBtn2 := SBUTTON():Create(oUsr)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "oSBtn2"
oSBtn2:nLeft := 8
oSBtn2:nTop := 290
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.

oSBtn2:bAction := { || oUsr:End() }
oSBtn2:nType := 1		// Ok

oSBtn3 := SBUTTON():Create(oUsr)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "oSBtn3"
oSBtn3:nLeft := 570
oSBtn3:nTop := 295
oSBtn3:nWidth := 52
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:bAction := { || oUsr:End() }
oSBtn3:nType := 2

ACTIVATE MSDIALOG oUsr CENTERED

If ! Empty(cArea)
	DbSelectArea(cArea)
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RetPosBfr  ³ Autor ³Wagner Mobile Costa³ Data ³ 12.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna posicao do array para reajuste                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetPosBfr(cCodInt,cCodLan)

Local nBfr
Local aArea := GetArea()

nBfr := Ascan(_aBfr, { |x| x[1] = cCodInt + cCodLan })
If nBfr = 0
	cSQL := "SELECT BFR_LANREC FROM "+RetSQLName("BFR")+" WHERE "
	cSQL += "BFR_FILIAL = '"+xFilial("BFR")+"' AND "
	cSQL += "BFR_CODINT = '"+cCodInt+"' AND "
	cSQL += "BFR_CODLAN = '"+cCodLan+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' ORDER BY BFR_FILIAL,BFR_CODINT,BFR_CODLAN,BFR_SEQUEN,BFR_LANREC"
	Aadd(_aBfr, { cCodInt + cCodLan, { } })
	nBfr := Len(_aBfr)

	BFR->(PLSQuery(cSQL,"PLSVLRBSE"))
	If ! PLSVLRBSE->(Eof())
		While ! PLSVLRBSE->(Eof())
			Aadd(_aBfr[nBfr][2], PLSVLRBSE->BFR_LANREC)
			PLSVLRBSE->(DbSkip())
		EndDo
	Endif
	PLSVLRBSE->(DbCloseArea())
	RestArea(aArea)
Endif

Return nBfr

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ZeraVlrFix ³ Autor ³Wagner Mobile Costa³ Data ³ 15.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Zera a contagem da cobranca de valor fixo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ZeraVlrFix

nUsrTxf	:= 0
nLidTxf	:= 0
nVlrTxf	:= 0
nCobTxf	:= 0

nUsrFix	:= 0
nLidFix	:= 0
nVlrFix	:= 0
nCobFix	:= 0

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCobGrp  ³ Autor ³Wagner Mobile Costa³ Data ³ 05.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o valor de cobranca de um grupo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCobGrp(cAno,cMes,nTipo,cCodInt,cNumero,cPrefix,cNumTit,cParcel,cTipTit)
LOCAL lDetalhado	:= .f.
LOCAL aValor  		:= {}
LOCAL oDlg			:= nil
LOCAL oTree			:= nil
LOCAL nInd			:= 0
LOCAL nAux			:= 0
LOCAL cQuebra 		:= ""
LOCAL bOK     		:= { || oDlg:End() }
LOCAL oGrupo		:= nil
LOCAL oSay			:= nil
LOCAL oSayTot		:= nil
LOCAL nTotCre 		:= 0
LOCAL nTotDeb 		:= 0
LOCAL nTotal  		:= 0
LOCAL cTipo			:= ''
LOCAL cBmp			:= ''
LOCAL cLastCargo 	:= "00"
Local aAglutina	 	:= {}, nItem, nAglutina, nPosAglu
Local cFiltro	 	:= ""
Local cArea		 	:= Alias()
Local lContador	 	:= .F.
Local aIrrf			:= {}
Local nBaseIr	 	:= nIrrf := 0
Local nTam		 	:= 20	

DEFAULT cCodInt := ""
DEFAULT cAno  	:= ""
DEFAULT cMes  	:= ""
DEFAULT nTipo 	:= 1	// 1 seria Cobranca por empresa
						// 2 seria Cobranca por contrato
						// 3 seria Cobranca por Sub-Contrato
						// 4 seria Filtro de uma cobranca   
DEFAULT cPrefix := ''
DEFAULT cNumTit	:= ''
DEFAULT cParcel := ''
DEFAULT cTipTit	:= ''

//Busca dados dos parametros pelo usuario...                          
If nTipo < 4 .and. ( Empty(cAno) .Or. Empty(cMes) )

	If ! Pergunte("PLA730",.T.)
		Return
	Endif
	
	cAno	:= mv_par01
	cMes	:= mv_par02
else
	mv_par03 := 2	
Endif

lDetalhado := .T.
	
cFiltro := 	" SELECT BM1_CODINT,BM1_CODEMP,BM1_CONEMP,BM1_VERCON,BM1_SUBCON,BM1_VERSUB,BM1_TIPO,BM1_VALOR,BM1_CODTIP,BM1_CODEVE, "
cFiltro += 	"        BM1_DESEVE,BM1_CARGO,BM1_MATUSU,BM1_NOMUSR,BM1_LTOTAL,BM1_SEXO,BM1_GRAUPA,BM1_CODFAI,BM1_NIVFAI,BM1_TIPUSU, "
cFiltro += 	"        BM1_ALIAS,BM1_ORIGEM,BM1_BASEIR,BM1_MATRIC,BM1_VERSUB, "
cFiltro += 	"        BM1_BASEIR,BM1_PREFIX,BM1_NUMTIT,BM1_PARCEL,BM1_TIPTIT,BM1_CARGO,BM1_BASEIR "
cFiltro += 	"  FROM " + RetSqlName("BM1")
cFiltro += 	"  WHERE BM1_FILIAL = '" + xFilial("BM1") + "' AND "

If nTipo = 1

	cFiltro += 	" BM1_CODINT = '" + BG9->BG9_CODINT + "' AND "
	cFiltro += 	" BM1_CODEMP = '" + BG9->BG9_CODIGO + "' AND "
	
	cCodInt := BG9->BG9_CODINT
	
ElseIf nTipo = 2
	
	cFiltro += 	"BM1_CODINT = '" + BT5->BT5_CODINT + "' AND "
	cFiltro += 	"BM1_CODEMP = '" + BT5->BT5_CODIGO + "' AND "
	cFiltro += 	"BM1_CONEMP = '" + BT5->BT5_NUMCON + "' AND "
	cFiltro += 	"BM1_VERCON = '" + BT5->BT5_VERSAO + "' AND "
	
	BG9->(DbSetOrder(1))
	BG9->(MsSeek(xFilial("BG9")+BT5->BT5_CODINT + BT5->BT5_CODIGO ))
	
	cCodInt := BT5->BT5_CODINT
	
ElseIf nTipo = 3

	BG9->(DbSetOrder(1))
	BG9->(MsSeek(xFilial("BG9")+BQC->BQC_CODIGO))

	BT5->(DbSetOrder(1))
	BT5->(MsSeek(xFilial("BT5")+BQC->BQC_CODIGO+BQC->BQC_NUMCON+BQC->BQC_VERCON))
	
	cFiltro += 	"BM1_CODINT = '" + Left(BQC->BQC_CODIGO, 4) + "' AND "
	cFiltro += 	"BM1_CODEMP = '" + Right(BQC->BQC_CODIGO, 4) + "' AND "
	cFiltro += 	"BM1_CONEMP = '" + BQC->BQC_NUMCON + "' AND "
	cFiltro += 	"BM1_VERCON = '" + BQC->BQC_VERCON + "' AND "
	cFiltro += 	"BM1_SUBCON = '" + BQC->BQC_SUBCON + "' AND "
	cFiltro += 	"BM1_VERSUB = '" + BQC->BQC_VERSUB + "' AND "
	
	cCodInt := Left(BQC->BQC_CODIGO, 4)
	
ElseIf nTipo = 4 .AND. Empty(cNumTit)
	
	cFiltro += 	"BM1_CODINT = '" + cCodInt + "' AND "
	cFiltro += 	"BM1_PLNUCO = '" + cNumero + "' AND "
	cFiltro += 	"BM1_INTERC = '0' AND "
	
ElseIf nTipo = 5 .AND. Empty(cNumTit)
	
	cFiltro += 	"BM1_CODINT = '" + cCodInt + "' AND "
	cFiltro += 	"BM1_PLNUCO = '" + cNumero + "' AND "
	cFiltro += 	"BM1_INTERC = '1' AND "
	
Endif

If nTipo < 4 .AND. Empty(cNumTit)

	cFiltro += 	"BM1_ANO = '" + cAno + "' AND BM1_MES = '" + cMes + "' AND "
	cFiltro += 	"BM1_LTOTAL = '0' AND D_E_L_E_T_ = ' ' "
				
Elseif Empty(cNumTit)
	
	cFiltro += 	"BM1_LTOTAL = '0' AND D_E_L_E_T_ = ' '"
	
Endif  

If ! Empty(cNumTit)
	cFiltro += "BM1_PREFIX = '" + cPrefix + "' AND " 
	cFiltro += "BM1_NUMTIT = '" + cNumTit + "' AND "
	cFiltro += "BM1_PREFIX = '" + cPrefix + "' AND "
	cFiltro += "BM1_TIPTIT = '" + cTipTit + "' AND "
	cFiltro += "BM1_LTOTAL = '0' AND D_E_L_E_T_ = ' '"	
Endif

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cFiltro)),"BM1QRY",.f.,.t.)

if ! BM1QRY->(eof())
	plsTField("BM1QRY",.f.,{ "BM1_VALOR","BM1_BASEIR"} )
endIf	

SE1->( dbSetOrder(1) )
while !BM1QRY->(eof())

	BQC->( MsSeek(xFilial("BQC") + BM1QRY->(BM1_CODINT+BM1_CODEMP+BM1_CONEMP+BM1_VERCON+BM1_SUBCON+BM1_VERSUB) ) )

	aadd(aValor,{	BM1QRY->BM1_TIPO,;	
					BM1QRY->BM1_VALOR,;
					BM1QRY->BM1_CODTIP,;
					AllTrim(BM1QRY->BM1_CODEVE),;
					AllTrim(BM1QRY->BM1_DESEVE),;
					BM1QRY->BM1_CARGO,;
					BM1QRY->BM1_MATUSU,;
					BM1QRY->BM1_NOMUSR,;
					IF(BM1QRY->BM1_LTOTAL=="0",.T.,.F.),;
					BM1QRY->BM1_SEXO,;
					BM1QRY->BM1_GRAUPA,;
					0,;					// Filler
					BM1QRY->BM1_CODFAI,;
					BM1QRY->BM1_NIVFAI,;
					BM1QRY->BM1_TIPUSU,;
					BM1QRY->BM1_ALIAS,;
					BM1QRY->BM1_ORIGEM,;
					BM1QRY->BM1_BASEIR,;
					BM1QRY->BM1_CONEMP,; 									//19
					Iif(Empty(BM1QRY->BM1_CONEMP),BM1QRY->BM1_CODINT,BM1QRY->BM1_VERCON),; //20
					Iif(Empty(BM1QRY->BM1_CONEMP),BM1QRY->BM1_CODEMP,BM1QRY->BM1_SUBCON),; //21
					Iif(Empty(BM1QRY->BM1_CONEMP),BM1QRY->BM1_MATRIC,BM1QRY->BM1_VERSUB),; //22
					AllTrim(BQC->BQC_DESCRI),;
					BM1QRY->BM1_CODEMP,;
					0,;
					BM1QRY->BM1_BASEIR,;
					BM1QRY->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT),;
					BM1QRY->BM1_CARGO })
		
	If BM1QRY->BM1_BASEIR > 0
	
		nPos := Ascan(aIrrf, { |x|	x[1] = BM1QRY->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) })
		
		If nPos = 0
			
			SE1->(MsSeek(xFilial("SE1") + BM1QRY->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT)))
	
			Aadd(aIrrf, { BM1QRY->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT), BM1QRY->BM1_BASEIR, SE1->E1_IRRF })
	
		Else
			aIrrf[nPos][2] += BM1QRY->BM1_BASEIR
		Endif
											
	Endif
	
BM1QRY->(DbSkip())
EndDo

BM1QRY->(DbCloseArea())

If Len(aValor) = 0
	MsgStop(STR0019) //"Cobranca nao gerada para o mes informado !."
	Return
Endif

//Executa funcao que retornara composicao de cobranca...              
aAglutina := AClone(aValor)
aValor := {}

For nItem := 1 To Len(aAglutina)

	If aAglutina[nItem][3] = "101" .Or. aAglutina[nItem][3] = "118"

		lContador := .T.

		nPos := Ascan(aValor, { |x| 	x[1]  = aAglutina[nItem][1] .And.;
										x[3]  = aAglutina[nItem][3] .And.;
										x[4]  = aAglutina[nItem][4] .And.;
										x[13] = aAglutina[nItem][13] .And.;
										x[19] = aAglutina[nItem][19] .And.;
										x[20] = aAglutina[nItem][20] .And.;
										x[21] = aAglutina[nItem][21] .And.;
										x[22] = aAglutina[nItem][22] .And.;
										x[24] = aAglutina[nItem][24] .And.;
										x[27] = aAglutina[nItem][27] })
	Else
	
		nPos := Ascan(aValor, { |x| 	x[1] = aAglutina[nItem][1] .And.;
										x[3] = aAglutina[nItem][3] .And.;
										x[4] = aAglutina[nItem][4] .And.;
										x[19] = aAglutina[nItem][19] .And.;
										x[20] = aAglutina[nItem][20] .And.;
										x[21] = aAglutina[nItem][21] .And.;
										x[22] = aAglutina[nItem][22] .And.;
										x[24] = aAglutina[nItem][24] .And.;
										x[27] = aAglutina[nItem][27]  })
		lContador := .F.
	Endif
	
	If nPos = 0
		Aadd(aValor, AClone(aAglutina[nItem]))
		nPos := Len(aValor)
	Else
		aValor[nPos][2] += aAglutina[nItem][2]
	Endif 
	
	If lContador
		aValor[nPos][25] ++
	Endif
	
Next

aValor := ASort(aValor,,, { |x,y| 	x[27] + x[24] + x[19] + x[20] + x[21] + x[22] + x[3] + x[13] <;
									y[27] + y[24] + y[19] + y[20] + y[21] + y[22] + y[3] + y[13] })

//Trata uma possivel nao-conformidade na rotina...                    
If Empty(aValor)
	eval(bRest)
	Return
Else

	aEval(aValor, { |x| IF(x[9],If(x[1]=="2",nTotCre := nTotCre + x[2],nTotDeb := nTotDeb + x[2]),nil) })

	If nTotDeb >= nTotCre
		cTipo  := "D" //"Debito"
		nTotal := nTotDeb - nTotCre
	Else
		cTipo  := "C" //"Credito"
		nTotal := nTotCre - nTotDeb
	Endif
	
Endif

BA0->(DbSetOrder(1))
BA0->(MsSeek(xFilial("BA0")+cCodInt))

DEFINE MSDIALOG oDlg TITLE STR0020 + If(nTipo < 4, "  -   "+cAno+" / "+cMes, "")   FROM 008.2,010.3 TO 036.4,100.3 OF GetWndDefault() //"Composicao de Cobranca"

//Monta says...                                                       
@ 016+nTam, 208 GROUP oGrupo TO 032+nTam, 350 PIXEL OF oDlg LABEL STR0008  COLOR CLR_HBLUE, CLR_HRED //" Operadora "

PLSSAYESP(022+nTam,215,{ || TransForm(cCodInt,"@R !.!!!")+ "  -  "+subs(BA0->BA0_NOMINT,1,35) },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")
			
If nTipo > 3

	@ 036+nTam, 208 GROUP oGrupo TO 052+nTam, 350 PIXEL OF oDlg LABEL STR0021  COLOR CLR_HBLUE, CLR_HRED //" Fatura "
	
	PLSSAYESP(042+nTam,215,{ || cNumero },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
Else
	
	@ 036+nTam, 208 GROUP oGrupo TO 052+nTam, 350 PIXEL OF oDlg LABEL STR0009  COLOR CLR_HBLUE, CLR_HRED //" Grupo Empresa "
	
	PLSSAYESP(042+nTam,215,{ || TransForm(cCodInt,"!!!!")+ "  -  "+subs(BG9->BG9_DESCRI,1,36) },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
Endif
	
If nTipo > 1 .And. nTipo < 4
	
	@ 056+nTam, 208 GROUP oGrupo TO 072+nTam, 275 PIXEL OF oDlg LABEL STR0011  COLOR CLR_HBLUE, CLR_HRED //"Numero Contrato"
	
	PLSSAYESP(062+nTam, 215, { || BT5->BT5_NUMCON + " - " + BT5->BT5_VERSAO },;
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
Endif

If nTipo > 2 .And. nTipo < 4
	
	@ 056+nTam, 277 GROUP oGrupo TO 072+nTam, 350 PIXEL OF oDlg LABEL STR0022  COLOR CLR_HBLUE, CLR_HRED //" Sub-Contrato "
	
	PLSSAYESP(062+nTam,285,{ || BQC->BQC_SUBCON + STR0023 + BQC->BQC_VERSUB },; //" - Versao "
				150,;
				006,;
				oDlg,;
				AdvFont,;
				CLR_HBLUE,;
				"oSay")
Endif
	
//Monta objeto tree...                                                
oTree := DbTree():New(018+nTam,005,195,200,oDlg,nil,nil,.T.,nil)
oTree:BuildTrb(100, 2)
oTree:BeginUpdate()
oTree:SetEnable()

//Monta dados da composicao de cobranca...                            
For nInd := 1 To Len(aValor)

	cQuebra := 	aValor[nInd, 19] + aValor[nInd, 20] + aValor[nInd, 21] +;
				aValor[nInd, 22] + aValor[nInd, 24] + aValor[nInd, 27]

    If nTipo = 1 .Or. nTipo > 3			// Por Empresa ou por fatura 

        If !Empty(aValor[nInd, 19])

			cTexto  := 	aValor[nInd, 19] + "." + aValor[nInd, 20] + "." + aValor[nInd, 21] + "." +;
						aValor[nInd, 22] + STR0024 +; //" - Titulo "
						Subs(aValor[nInd, 27], Len(BM1->BM1_PREFIX) + 1, Len(BM1->BM1_NUMTIT)) + " - "
		Else 
			cTexto  := 	aValor[nInd, 20] + "." + aValor[nInd, 21] + "." + aValor[nInd, 22] + STR0024 +; //" - Titulo "
						Subs(aValor[nInd, 27], Len(BM1->BM1_PREFIX) + 1, Len(BM1->BM1_NUMTIT)) + " - "
		EndIf
						
	ElseIf nTipo = 2					// Por Sub-Contrato
		
		cTexto  := 	aValor[nInd, 21] + "." + aValor[nInd, 22] + STR0024 +; //" - Titulo "
					Subs(aValor[nInd, 27], Len(BM1->BM1_PREFIX) + 1, Len(BM1->BM1_NUMTIT)) + " - "
	Else
		cTexto  := STR0029 + Subs(aValor[nInd, 27], Len(BM1->BM1_PREFIX) + 1, Len(BM1->BM1_NUMTIT)) + " - " //"Titulo "
	Endif
	
	oTree:AddTree(	Left(cTexto + aValor[nInd, 23] + Space(100),100),Nil,"BMPGROUP","BMPGROUP",nil,nil,"")
	
	For nAux := nInd To Len(aValor)
		
		If cQuebra <> 	aValor[nAux, 19] + aValor[nAux, 20] + aValor[nAux, 21] +;
						aValor[nAux, 22] + aValor[nAux, 24] + aValor[nAux, 27]
			Exit
		Else
			cBmp := IF(aValor[nAux,9],"LJPRECO","PRECO")
	
			cLastCargo := StrZero(Val(cLastCargo)+1,2)
			
			If Empty(aValor[nAux,4])
				cTexto := AllTrim(aValor[nAux,5])
			Else
				cTexto := AllTrim(aValor[nAux,5]) + " [" + AllTrim(aValor[nAux,4])+"] "
			Endif
	
			// Mensalidade e Mensalidade retroativa
			If aValor[nAux,3] = "101" .Or. aValor[nAux,3] = "118"
				cTexto += STR0025 + AllTrim(Str(aValor[nAux,25])) //" - Usuarios "
			Endif
			
			If ! Empty(aValor[nAux,6])
				cTexto += " - " + AllTrim(aValor[nAux,6])
			Endif
						
			cTexto += " - "
			oTree:AddTreeItem(cTexto + AllTrim(TransForm(aValor[nAux,2],PLSVALOR)),cBmp,cBmp,cLastCargo)
			oTree:TreeSeek(cLastCargo)
			
		Endif
	Next
	
	oTree:EndTree()
	nInd := nAux-1

	If 	nInd = Len(aValor) .Or. Right(cQuebra, Len(aValor[nInd + 1, 27])) <> aValor[nInd + 1, 27]
	
		nAux := If(nInd = Len(aValor), nInd, nInd + 1)
		nPos := Ascan(aIrrf, { |x| x[1] = aValor[nInd, 27] })
									
		If nPos > 0
			nBaseIR := aIrrf[nPos][2]
			nIRRF := aIrrf[nPos][3]
		Else
			nBaseIR := 0
			nIRRF := 0
		Endif

		If nIRRF > 0
		
			oTree:AddTree(STR0026+Space(100),Nil,"BMPGROUP","BMPGROUP",nil,nil,"") //"Demonstracao do IR"
			cBmp := "PRECO"
			cLastCargo := StrZero(Val(cLastCargo)+1,2)
			oTree:AddTreeItem(STR0027 + AllTrim(TransForm(nBaseIr,PLSVALOR)),"PRODUTO","PRODUTO",cLastCargo) //"Base - "
			oTree:TreeSeek(cLastCargo)
			oTree:TreeSeek("")
	
			cLastCargo := StrZero(Val(cLastCargo)+1,2)
			oTree:AddTreeItem(STR0028 + AllTrim(TransForm(nIRRF,PLSVALOR)),"LJPRECO","LJPRECO",cLastCargo) //"Valor - "
			oTree:TreeSeek(cLastCargo)
			oTree:TreeSeek("")
			nTotCre += nIrrf
			nTotal -= nIrrf
			
		Endif
		
	Endif
	
Next

oTree:EndTree()

oTree:EndUpdate()

//Monta totalizadores...                                              ³
@ 175, 208 GROUP oGrupo TO 192, 245 PIXEL OF oDlg LABEL STR0013 COLOR CLR_HBLUE, CLR_HRED //" Creditos "

PLSSAYESP(182,209,{ || TransForm(nTotCre,PLSVALOR)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 250 GROUP oGrupo TO 192, 285 PIXEL OF oDlg LABEL STR0014  COLOR CLR_HBLUE, CLR_HRED //" Debitos "

PLSSAYESP(182,249,;
			{ || TransForm(nTotDeb,PLSVALOR)},;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

@ 175, 290 GROUP oGrupo TO 192, 350 PIXEL OF oDlg LABEL STR0015  COLOR CLR_HBLUE, CLR_HBLUE //" TOTAL "

PLSSAYESP(182,290,;
			{ || TransForm(nTotal,PLSVALOR)+" - ("+cTipo+")"  },;
			150,;
			006,;
			oDlg,;
			AdvFont,;
			CLR_HBLUE,;
			"oSay")

ACTIVATE DIALOG oDlg ON INIT Eval( { || oTree:TreeSeek(cLastCargo), oTree:Refresh(), EnchoiceBar(oDlg,bOK,bOK,.F.) } )

Return
