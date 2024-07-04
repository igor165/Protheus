#INCLUDE "OFIOR200.CH"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR200 ³ Autor ³ Eveli Morasco         ³ Data ³ 31/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Resumo das entradas e saidas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³18/12/97³13695A³Ajuste no saldo final de acordo c/a moeda.³±±
±±³Rodrigo Sar.³01/04/98³13615A³Inclusao da Perg. mv_par10                ³±±
±±³Rodrigo Sar.³22/07/98³15188A³Inclusao de tratamento poder terceiros    ³±±
±±³Edson   M.  ³17/11/98³xxxxxx³Substituicao do Gotop por Seeek no SB1.   ³±±
±±³Patricia Sal³04/01/00³xxxxxx³Inclusao Perg. Almoxarifado Ate.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR200
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho  := "G"
LOCAL titulo   := STR0001	//"Resumo das Entradas e Saidas"
LOCAL cDesc1   := STR0002	//"Este programa mostra um resumo ,por tipo de material ,de todas  as  suas"
LOCAL cDesc2   := STR0003	//"entradas e saidas. A coluna SALDO INICIAL  e' o  resultado da  soma  das"
LOCAL cDesc3   := STR0004	//"outras colunas do relatorio e nao o saldo inicial cadastrado no estoque."
LOCAL cString  := "SB1"
LOCAL wnrel := "OFIOR200"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn:= { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 1, 2, 1, "",1 }			//"Zebrado"###"Administracao"
PRIVATE nLastKey := 0 ,cPerg := "OFR200"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Almoxarifado De                              ³
//³ mv_par02     // Almoxarifado Ate                             ³
//³ mv_par03     // Tipo inicial                                 ³
//³ mv_par04     // Tipo final                                   ³
//³ mv_par05     // Produto inicial                              ³
//³ mv_par06     // Produto Final                                ³
//³ mv_par07     // Emissao de                                   ³
//³ mv_par08     // Emissao ate                                  ³
//³ mv_par09     // moeda selecionada ( 1 a 5 )                  ³
//³ mv_par10     // Saldo a considerar : Atual / Fechamento      ³
//³ mv_par11     // Considera Saldo MOD: Sim / Nao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey = 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C320Imp(@lEnd,wnRel,cString,tamanho,titulo)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C320IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 12.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR200  		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C320Imp(lEnd,WnRel,cString,tamanho,titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := ""
LOCAL nCntImpr := 0
LOCAL lContinua := .T. ,cMoeda ,lPassou:=.F.,lTotal:=.F.,cCampo
LOCAL nTotComp,nTotCons,nTotProc,nTotTrans,nTotProd,nTotEnTerc,nTotSaTerc
LOCAL nTotVend,nTotSaldo,nTotSant,nTotOutr,nTotDevVen,nTotDevCom
LOCAL cGruAnt
LOCAL nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nSaiTerc
LOCAL nReqTrans,nProducao,nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs
LOCAL nValor := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona o simbolo da moeda escolhida ao titulo            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMoeda := LTrim(Str(mv_par09))
cMoeda := IIF(cMoeda=="0","1",cMoeda)
If Type("NewHead")#"U"
	NewHead += STR0007+AllTrim(GetMv("MV_SIMB"+cMoeda))		//" EM "
Else
	Titulo  += STR0007+AllTrim(GetMv("MV_SIMB"+cMoeda))	   //" EM "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec1 := STR0008		//"TIPO            SALDO          COMPRAS    MOVIMENTACOES      REQUISICOES   TRANSFERENCIAS         PRODUCAO           VENDAS       TRANSF. P/     DEVOLUCAO DE     DEVOLUCAO DE  ENTRADA PODER  SAIDA PODER        SALDO"
Cabec2 := STR0009 +Iif(mv_par10 == 1,STR0010,Iif(mv_par10 == 2,STR0011,STR0012))    //"              INICIAL                          INTERNAS    PARA PRODUCAO                                                           PROCESSO            VENDAS          COMPRAS    TERCEIROS      TERCEIROS"###"        ATUAL"###"DO FECHAMENTO"###" DO MOVIMENTO"

******************      12   9,999,999,999.99 9,999,999,999.99 9,999,999,999.99 9,999,999,999.99 9999,999,999.99 9,999,999,999.99 9,999,999,999.99 9,999,999,999.99 9,999,999,999.99 9,999,999,999.99 999,999,999.99 999,999,999.99 9,999,999,999.99
******************      0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
******************      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
// Posicoes (000,005,022,039,056,073,089,106,123,140,157,174,189,204)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redireciona as ordens a serem lidas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(5)

dbSelectArea("SD2")
dbSetOrder(1)

dbSelectArea("SD3")
dbSetOrder(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para controlar cursor de progressao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial())
SetRegua(LastRec())

Store 0 TO nTotComp,nTotCons,nTotProc,nTotTrans,nTotProd,nTotEnTerc,nTotSaTerc
Store 0 TO nTotVend,nTotSaldo,nTotSant,nTotOutr,nTotDevVen,nTotDevCom

While lContinua .And. !EOF() .And. B1_FILIAL == xFilial()
	
	If B1_GRUPO < mv_par03 .Or. B1_GRUPO > mv_par04
		dbSkip()
		Loop
	EndIf
	If B1_COD < mv_par05 .Or. B1_COD > mv_par06
		dbSkip()
		Loop
	EndIf
	cGruAnt := B1_GRUPO
	Store 0 TO 	nSalant,nCompras,nReqCons,nReqProd,nEntrTerc,nSaiTerc
	Store 0 TO 	nReqTrans,nProducao,nVendas,nSaldoAtu,nReqOutr,nDevVendas,nDevComprs
	lPassou := .F.
	
	While !EOF() .And. B1_FILIAL+B1_GRUPO == xFilial()+cGruAnt
		
		If lEnd
			@ PROW()+1,001 PSay STR0013	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf
		
		If B1_COD < mv_par05 .Or. B1_COD > mv_par06
			dbSkip()
			Loop
		EndIf
		
		IncRegua()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Saldo final e inicial dos almoxarifados                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial()+SB1->B1_COD)
		While !EOF() .And. B2_FILIAL == xFilial() .And. B2_COD == SB1->B1_COD
			
			If B2_LOCAL < mv_par01 .Or. B2_LOCAL > mv_par02
				dbSkip()
				Loop
			EndIf
			
			IF mv_par10==1
				nSaldoAtu := nSaldoAtu + &("B2_VATU"+cMoeda)
			Elseif mv_par10 == 2
				nSaldoAtu := nSaldoAtu + &("B2_VFIM"+cMoeda)
			Else
				aSaldoAtu	:= CalcEst(SB2->B2_COD,SB2->B2_LOCAL,mv_par08+1)
				nSaldoAtu 	:= nSaldoAtu + aSaldoAtu[mv_par09+1]
			EndIF
			dbSkip()
		EndDo
		
		lPassou := IIF(nSaldoAtu > 0,.t.,lPassou)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa as Entradas de um determinado produto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD1")
		dbSetOrder(5)
		dbSeek(xFilial()+SB1->B1_COD+mv_par01,.t.)
		While !Eof() .And. D1_FILIAL+D1_COD == xFilial()+SB1->B1_COD
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If D1_LOCAL > mv_par02 .or. D1_LOCAL < mv_par01
				dbSkip()
				Loop
			Endif
			
			If D1_ORIGLAN == "LF"
				dbSkip()
				Loop
			EndIf
			
			If D1_DTDIGIT < mv_par07 .Or. D1_DTDIGIT > mv_par08
				dbSkip()
				Loop
			EndIf
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD1->D1_TES)
			dbSelectArea("SD1")
			
			If SF4->F4_ESTOQUE == "S"
				nValor := &("D1_CUSTO"+IIF(mv_par09 == 1," ",cMoeda))
				dbSelectArea("SD1")
				If SF4->F4_PODER3 == "N"
					If SD1->D1_TIPO == "D"
						nDevVendas  += nValor
					Else
						nCompras += nValor
					EndIf
				Else
					nEntrTerc += nValor
				EndIf
				lPassou := .T.
			EndIf
			dbSkip()
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa requisicoes                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD3")
		dbSetOrder(3)
		dbSeek(xFilial()+SB1->B1_COD+mv_par01,.t.)
		While !Eof() .And. D3_FILIAL+D3_COD == xFilial()+SB1->B1_COD
			
			If D3_EMISSAO < mv_par07 .Or. D3_EMISSAO > mv_par08 .Or. D3_ESTORNO == "S"
				dbSkip()
				Loop
			EndIf
			If D3_LOCAL > mv_par02  .or. D3_LOCAL < mv_par01
				dbSkip()
				Loop
			Endif
			IF mv_par09 == 1
				nValor := D3_CUSTO1
			ElseIf mv_par09 == 2
				nValor := D3_CUSTO2
			ElseIf mv_par09 == 3
				nValor := D3_CUSTO3
			ElseIf mv_par09 == 4
				nValor := D3_CUSTO4
			ElseIf mv_par09 == 5
				nValor := D3_CUSTO5
			EndIf
			
			If D3_TM > "500"
				nValor := nValor*-1
			EndIf
			
			If Substr(D3_CF,1,2) == "PR"
				nProducao += nValor
			ElseIf D3_CF$"RE4/DE4"
				nReqTrans += nValor
			ElseIf Empty(D3_OP) .And. Substr(D3_CF,3,1) != "3"
				nReqCons += nValor
			ElseIf !Empty(D3_OP)
				nReqProd += nValor
			Else
				nReqOutr += nValor
			EndIf
			lPassou := .T.
			dbSkip()
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pesquisa Vendas                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SD2")
		dbSetOrder(6)
		dbSeek(xFilial()+SB1->B1_COD+mv_par01,.t.)
		While !Eof() .And. D2_FILIAL+D2_COD == xFilial()+SB1->B1_COD
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If D2_ORIGLAN == "LF"
				dbSkip()
				Loop
			EndIf
			If D2_LOCAL > mv_par02 .or. D2_LOCAL < mv_par01
				dbSkip()
				Loop
			Endif
			If D2_EMISSAO < mv_par07 .Or. D2_EMISSAO > mv_par08
				dbSkip()
				Loop
			EndIf
			
			dbSelectArea("SF4")
			dbSeek(xFilial()+SD2->D2_TES)
			dbSelectArea("SD2")
			If SF4->F4_ESTOQUE == "S"
				nValor := &("D2_CUSTO"+cMoeda)
				dbSelectArea("SD2")
				If SF4->F4_PODER3 == "N"
					If SD2->D2_TIPO == "D"
						nDevComprs += nValor
					Else
						nVendas  += nValor
					EndIf
				Else
					nSaiTerc += nValor 
				EndIf
				lPassou := .T.
			EndIf
			dbSkip()
		EndDo
		dbSelectArea("SB1")
		dbSkip()
	EndDo
	If lPassou
		lTotal:=.T.
		If li > 55
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		li++
		nSalant := nSaldoAtu-nCompras-nReqProd-nReqCons-nProducao+nVendas-nReqTrans-nReqOutr-nDevVendas+nDevComprs-nEntrTerc+nSaiTerc
		// Posicoes (000,005,022,039,056,073,089,106,123,140,157,174,189,204)
	   
	   @ li,000 PSay ""
		@ li,pcol() PSay cGruAnt
		@ li,pcol()+3 PSay nSalant   Picture TM(nSalant,12)
		@ li,pcol()+1 PSay nCompras  Picture TM(nCompras,12)
		@ li,pcol()+1 PSay nReqCons  Picture TM(nReqCons,12)
		@ li,pcol()+1 PSay nReqProd  Picture TM(nReqProd,12)
		@ li,pcol()+1 PSay nReqTrans Picture TM(nReqTrans,12)
		@ li,pcol()+1 PSay nProducao Picture TM(nProducao,12)
		@ li,pcol()+1 PSay nVendas   Picture TM(nVendas,14)
		@ li,pcol()+1 PSay nReqOutr  Picture TM(nReqOutr,14)
		@ li,pcol()+1 PSay nDevVendas Picture TM(nDevVendas,14)
		@ li,pcol()+1 PSay nDevComprs Picture TM(nDevComprs,14)
		@ li,pcol()+1 PSay nEntrTerc Picture TM(nCompras,14)
		@ li,pcol()+1 PSay nSaiTerc Picture TM(nVendas,14)
		@ li,pcol()+1 PSay nSaldoAtu Picture TM(nSaldoAtu,16)
		nTotSant  += nSalant
		nTotComp  += nCompras
		nTotCons  += nReqCons
		nTotProc  += nReqProd
		nTotTrans += nReqTrans
		nTotProd  += nProducao
		nTotVend  += nVendas           '
		nTotEnTerc+= nEntrTerc
		nTotSaTerc+= nSaiTerc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve somar custo da Mao de Obra no Saldo Final   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	!(Substr(SB2->B2_COD,1,3) == "MOD" .And. mv_par11 == 2)
			nTotSaldo += nSaldoAtu
		EndIf
		nTotOutr  += nReqOutr
		nTotDevVen+= nDevVendas
		nTotDevCom+= nDevComprs
	EndIf
	dbSelectArea("SB1")
EndDo

If lTotal
	li++;li++
	If li > 55
		Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIf
   
	@ li,001 PSay STR0014	//"TOT.:"
	@ li,pcol()+1 PSay nTotSant  PicTure tm(nTotSant ,12)
	@ li,pcol()+1 PSay nTotComp  PicTure tm(nTotComp ,12)
	@ li,pcol()+1 PSay nTotCons  PicTure tm(nTotCons ,12)
	@ li,pcol()+1 PSay nTotProc  PicTure tm(nTotProc ,12)
	@ li,pcol()+1 PSay nTotTrans PicTure tm(nTotTrans,12)
	@ li,pcol()+1 PSay nTotProd  PicTure tm(nTotProd ,12)
	@ li,pcol()+1 PSay nTotVend  PicTure tm(nTotVend ,14)
	@ li,pcol()+1 PSay nTotOutr  PicTure tm(nTotOutr ,14)
	@ li,pcol()+1 PSay nTotDevVen PicTure tm(nTotDevVen,14)
	@ li,pcol()+1 PSay nTotDevCom PicTure tm(nTotDevCom,14)
	@ li,pcol()+1 PSay nTotEnTerc Picture TM(nTotComp,14)
	@ li,pcol()+1 PSay nTotSaTerc Picture TM(nTotVend,14)
	@ li,pcol()+1 PSay nTotSaldo PicTure tm(nTotSaldo,16)
EndIf

If li != 80
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restauras as ordens principais dos arquivos envolvidos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)
dbSelectArea("SD2")
dbSetOrder(1)
dbSelectArea("SD3")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbSetOrder(1)
Set Filter To

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
