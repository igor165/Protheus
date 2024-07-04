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
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбдддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSCTB10Ё Autor Ё Angelo Sperandio                Ё Data Ё 11.08.06 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддадддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Contabilizacao de Comissoes                                         Ё╠╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSCTB10()                                                          Ё╠╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                                   Ё╠╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                                        Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбдддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                                Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддедддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё          Ё      Ё             Ё                                                Ё╠╠╠
╠╠юддддддддддаддддддадддддддддддддадддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSCTB10(lAuto)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local   nOpca     := 0
Local   aSays     := {}
Local   aButtons  := {}
Private cCadastro := STR0001 //"Contabilizacao Off-Line de Comissoes"
Private cPerg     := PADR("PLSC10",LEN(SX1->X1_GRUPO))

default lAuto := .F.

lautoSt := lAuto

If !lAuto .AND. ( BXQ->(FieldPos("BXQ_LAGER")) == 0 .or. BXQ->(FieldPos("BXQ_LAPAG")) == 0 .or. BXQ->(FieldPos("BXQ_REFERE")) == 0 )
	msgalert("Faltam campos para o correto processamento desta rotina. и necessАrio executar os procedimentos descritos no boletim tИcnico referente ao bops 112958.")
	Return
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza parametros                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdd(aSays,STR0002) //"Este programa tem como objetivo gerar os lancamentos contabeis off-line"
aAdd(aSays,STR0003) //"das comissoes calculadas."
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(), FechaBatch(), nOpca:=0 ) }} )
aAdd(aButtons, { 2,.T.,{|| FechaBatch() }} )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto
	FormBatch(cCadastro,aSays,aButtons)
endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa Contabilizacao das Guias                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAuto .AND. nOpca == 1
	Processa({|lEnd| PlsCtb10Proc()})
else
	PlsCtb10Proc()
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PlsCtb10Proc Ё Autor Ё Angelo Sperandio  Ё Data Ё 11.08.06 Ё╠╠╠
╠╠цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Contabilizacao de Comissoes                                Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function PlsCtb10Proc(lEnd)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Incializa variaveis                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza variaveis com o conteudo dos parametros informados no pergunte Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta parte da query                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona registros para processamento ...                              Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT COUNT(*) QTD " + cSql1
PLSQuery(cSql,"BXQQRY")
ProcRegua(BXQQRY->QTD)
BXQQRY->(dbCloseArea())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona registros para processamento ...                              Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT R_E_C_N_O_ BXQ_RECNO, BXQ_PAGCOM, BXQ_REFERE, BXQ_DTGER "
cSql += cSql1
cSql += " ORDER BY BXQ_FILIAL, BXQ_CODINT, BXQ_CODEMP, BXQ_NUMCON, BXQ_SUBCON, BXQ_MATRIC, BXQ_TIPREG, BXQ_DIGITO, BXQ_PREFIX, BXQ_NUM, BXQ_PARC, BXQ_TIPO"
PLSQuery(cSql,"BXQQRY")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o Nёmero do Lote                                               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cLote := LoteCont("PLS")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona indices                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(dbSetOrder(1))
BA1->(dbSetOrder(2))
BI3->(dbSetOrder(1))
BQC->(dbSetOrder(1))
BT6->(DbSetOrder(1))
SE1->(DbSetOrder(1))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BXQ->(dbGoTo(BXQQRY->BXQ_RECNO))
cMatAnt := BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa BXQ-Comissoes                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! BXQQRY->(Eof())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Movimenta regua                                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IncProc()
	lConGer := .F.
	lConPag := .F.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona BXQ                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BXQ->(dbGoTo(BXQQRY->BXQ_RECNO))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava rodape - por Usuario                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona BA3-Familia                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC) <> BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
		BA3->(msSeek(xFilial("BA3") + BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC)))
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona BA1-Usuario                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG) <> BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
		BA1->(msSeek(xFilial("BA1")+BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)))
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Identifica codigo do produto a ser posicionado                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  ! empty(BA1->BA1_CODPLA)
		cCodPro := BA1->BA1_CODPLA
		cVerPro := BA1->BA1_VERSAO
	Else
		cCodPro := BA3->BA3_CODPLA
		cVerPro := BA3->BA3_VERSAO
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona BI3-Produto Saude                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  BA1->BA1_CODINT+cCodPro+cVerPro <> BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
		BI3->(msSeek(xFilial("BI3") + BA1->BA1_CODINT + cCodPro + cVerPro))
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona BQC-Subcontrato                                            Ё
	//Ё Posiciona BT6-Subcontrato x Produto                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  BA3->BA3_TIPOUS = "2" // Contrato Pessoa Juridica
		BQC->(msSeek(xFilial("BQC") + BA3->(BA3_CODINT + BA3_CODEMP + ;
		BA3_CONEMP + BA3_VERCON + ;
		BA3_SUBCON + BA3_VERSUB)))
		BT6->(msSeek(xFilial("BT6") + BA3->(BA3_CODINT + BA3_CODEMP + ;
		BA3_CONEMP + BA3_VERCON + ;
		BA3_SUBCON + BA3_VERSUB + ;
		cCodPro    + cVerPro)))
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Contabiliza a comissao                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza flag de lancamento contabil                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa variaveis                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMatAnt := BXQ->(BXQ_CODINT+BXQ_CODEMP+BXQ_MATRIC+BXQ_TIPREG)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Acessa proximo registro                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BXQQRY->(dbSkip())
Enddo
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava rodape                                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .ANd. lCabecalho .and. nTotLanc > 0
	PLSCA100(cArquivo,@nHdlPrv,cLote,@nTotLanc,lDigita,lAglut)
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha area de trabalho                                                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BXQQRY->(dbCloseArea())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Funcao    ЁPlsCtbCabecЁ Autor Ё Angelo Sperandio     Ё Data Ё 11.08.06 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descricao Ё Grava lancamento contabeis                                 Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function PlsCtbCabec(nHdlPrv,cArquivo,lCriar,cLote)

lCriar     := If(lCriar=NIL,.F.,lCriar)
nHdlPrv    := HeadProva(cLote,"PLSCTB05",Substr(cUsuario,7,6),@cArquivo,lCriar)
lCabecalho := .T.

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Funcao    Ё PLSCA100Ё Autor Ё Angelo Sperandio     Ё Data Ё 11.08.06 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descricao Ё Grava lancamento contabeis                                 Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function PLSCA100(cArquivo,nHdlPrv,cLote,nTotal,lDigita,lAglut)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava rodape                                                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. nHdlPrv > 0
	RodaProva(nHdlPrv,nTotal)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia para Lan?amento Cont═bil 							            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
	lCabecalho := .F.
	nHdlPrv    := 0
	nTotal     := 0
EndIf

Return
