// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 11     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "OFIOR210.CH"
#Include "PROTHEUS.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR210 ³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estatistica de Venda por Ordem de Vendedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OFIOR210void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Verificar Indexacao com vendedor                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ BRUNO        ³18/11/98³XXXXXX³Tratamento dos impostos para localizaco-³±±
±±³              ³        ³      ³es no exterior.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Viviani      ³19/11/98³18137 ³Acerto do MV_PAR09 e MV_PAR08 que esta- ³±±
±±³              ³        ³      ³vam invertidos em cDupli e cEstoq       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Viviani      ³25/11/98³Melhor³Acrescimo do xMoeda p/ conversao.       ³±±
±±³ Edson        ³30/03/99³xxxxxx³Passar tamanho na SetPrint.             ³±±
±±³ Marcello     ³26/08/00³oooooo³Impressao de casas decimais de acordo   ³±±
±±³              ³        ³      ³com a moeda selecionada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Manoel       ³Agost/08³      ³Criacao do Anual Veiculos               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OFIOR210()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt  := ""
Local titulo := OemToAnsi(STR0001)	//"Faturamento por Vendedor"
Local cDesc1 := OemToAnsi(STR0002)	//"Este relatorio emite a relacao de faturamento. Podera ser"
Local cDesc2 := OemToAnsi(STR0003)	//"emitido por ordem de Cliente ou por Valor (Ranking).     "
Local cDesc3 := OemToAnsi(STR0004)	//"Se no TES estiver gera duplicata (N), nao sera computado."
Local CbCont,cabec1,cabec2,wnrel
Local tamanho:="M"
Local limite :=132
Local cString:="SF2"
Local lContinua := .T.
Local cMoeda,nMoeda
Local cNFiscal

PRIVATE aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog:="OFIOR210"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="OFR210"
ValidPerg()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("OFR210",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// A partir da data                      ³
//³ mv_par02        	// Ate a data                            ³
//³ mv_par03        	// Do Vendedor                           ³
//³ mv_par04         // Ao Vendedor                              ³
//³ mv_par05         // Por Codigo ou valor                      ³
//³ mv_par06         // Moeda                                    ³
//³ mv_par07         // Inclui Devolu‡„o                         ³
//³ mv_par08         // TES Qto Faturamento                      ³
//³ mv_par09         // TES Qto Estoque                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel  := "OFIOR210"            //Nome Default do relatorio em Disco
wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If Mv_Par12 == 3 // Anual-Veic
	If Year(Mv_Par01) != Year(Mv_Par02)
		MsgStop('Quando o parametro 12 (Tipo de relatorio) estiver com Anual - Veiculos'+Chr(10)+Chr(13)+;
					'nao podera ser informado periodo com Ano Inicial diferente de Ano Final!')
		return
	Endif
Endif

If nLastKey==27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| C580Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C580IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR210			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C580Imp(lEnd,WnRel,cString)
LOCAL I
Local titulo := OemToAnsi(STR0001)		//"Faturamento por Vendedor"
Local cDesc1 := OemToAnsi(STR0002)		//"Este relatorio emite a relacao de faturamento. Podera ser"
Local cDesc2 := OemToAnsi(STR0003)		//"emitido por ordem de Cliente ou por Valor (Ranking).     "
Local cDesc3 := OemToAnsi(STR0004)		//"Se no TES estiver gera duplicata (N), nao sera computado."
Local CbCont,cabec1,cabec2
Local tamanho:="M"
Local limite :=132
Local lContinua := .T.
Local aCampos := {}
Local aTam	  := {}
Local nAg1:=0,nAg2:=0,nAg3:=0,nRank:=0,cVend,cDepto,cSitVei,nQtdVen, cPrefix
Local nMoeda, cMoeda:="", nValor1, nValor2, nValor3
Local cEstoq := If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
Local cDupli := If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
Local cPtvdSX5 := ""

Private nQtVeiNAc := 0
Private nTotVeiNAc := 0
Private nTotVNAc := 0
Private nTotVN1Ac := 0
Private nQtVeiUAc := 0
Private nTotVeiUAc := 0
Private nTotVUAc := 0
Private nTotVU1Ac := 0


Private aTamVal:= { 16, 2 }

Private nDecs:=msdecimais(mv_par06)

nTipo:=IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       :=80
m_pag    :=1
nMoeda := mv_par06
cMoeda := GetMv("MV_MOEDA"+LTrim(STR(nMoeda)))

IF mv_par05 = 1
	titulo := OemToAnsi(STR0007)+cMoeda	//"FATURAMENTO POR VENDEDOR  (CODIGO) - "
Else
	titulo := OemToAnsi(STR0008)+cMoeda	//"FATURAMENTO POR VENDEDOR  (RANKING) - "
EndIF

cabec1 := "     "+OemToAnsi(STR0009)	//"CODIGO   NOME DO VENDEDOR                 QTDADE         FATURAMENTO          VALOR DA                 VALOR  RANKING"
cabec2 := "     "+OemToAnsi(STR0010)	//"                                                           SEM ICM           MERCADORIA                TOTAL         "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria array para gerar arquivo de trabalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("F2_VEND1")
AADD(aCampos,{ "TB_VEND"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_EMISSAO")
AADD(aCampos,{ "TB_EMISSAO","D",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_VALFAT")
AADD(aCampos,{ "TB_VALOR1 ","N",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_VALFAT")
AADD(aCampos,{ "TB_VALOR2 ","N",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_VALFAT")
AADD(aCampos,{ "TB_VALOR3 ","N",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_DOC")
AADD(aCampos,{ "TB_DOC    ","C",aTam[1],aTam[2] } )
AADD(aCampos,{ "TB_DEPTO  ","C",2,0} )
AADD(aCampos,{ "TB_QTDVEN ","N",6,0} )
AADD(aCampos,{ "TB_PREFIXO","C",3,0} )
AADD(aCampos,{ "TB_ESTVEI","C",1,0} )

cNomArq1 := CriaTrab(NIL, .F.)
cNomArq2 := CriaTrab(NIL, .F.)
cNomArq3 := CriaTrab(NIL, .F.)
oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aCampos
oObjTempTable:AddIndex(cNomArq1, {"TB_PREFIXO","TB_DEPTO","TB_ESTVEI","TB_VEND","TB_EMISSAO"} )
oObjTempTable:AddIndex(cNomArq2, {"TB_PREFIXO","TB_DEPTO","TB_ESTVEI","TB_VALOR3"} )
oObjTempTable:AddIndex(cNomArq3, {"TB_PREFIXO","TB_DEPTO","TB_ESTVEI","TB_QTDVEN"} )
oObjTempTable:CreateTable(.t.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para gerar arquivo de Trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

GeraTrab(cEstoq,cDupli)

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VV0_DEPTO")
	If !Empty(SX3->X3_F3)
		cPtvdSX5 := AllTrim(SX3->X3_F3)
	Else
		cPtvdSX5 := "76"
	EndIf
Else
	cPtvdSX5 := "76"
EndIf	

dbSelectArea("TRB")
SetRegua(LastRec())
If ( MV_PAR05 = 2 )
	dbSetOrder(2)
Elseif ( MV_PAR05 = 3 )
	dbSetOrder(3)
Else
	dbSetOrder(1)
EndIF
dbGoBottom()
cNFiscal := TB_DOC
cDepto  := ""
cSitVei  := ""
cPrefix := ""
nQtdVen := 0
nTQtVen := 0
nSQtVen := 0
nTotDepto := 0
nTotDepto1:= 0
nTotDepto2:= 0
nTotDepto3:= 0
nTotal1 := 0
nTotal2 := 0
nTotal3 := 0
nNumero := 0
cSitVei := ""
nCont   := 0
nQtVeiN := 0
nQtVeiU := 0
nQtVeiN := 0
nQtVeiU := 0
nTotVeiU := 0
nTotVeiN := 0
nTotVN  := 0
nTotVU  := 0
nTotVN1  := 0
nTotVU1  := 0
nAchou   := 0
if mv_par10==5 .and. mv_par11==1
	mv_par10:= 6
endif

If Mv_Par12 != 3 // Analitico ou Sintetico

	While !Bof()
		
		IF lEnd
			@Prow()+1,001 PSAY STR0012		//"CANCELADO PELO OPERADOR"
			Exit
		Endif
		IncRegua()
		if mv_par10 == 6 .and.TB_PREFIXO != "VEI"
			DBSkip(-1)
			loop
		elseif ((mv_par10 == 1) .and. (TB_PREFIXO != "VEI" .or. (TB_PREFIXO == "VEI" .and. (!(TB_ESTVEI  $ "02"))))).or.;
			((mv_par10 == 2) .and. (TB_PREFIXO != "VEI" .or. (TB_PREFIXO == "VEI" .and. (TB_ESTVEI  != "1") ))).or.;
			(mv_par10 == 3 .and. TB_PREFIXO != "BAL").or.;
			(mv_par10 == 4 .and. TB_PREFIXO != "OFI")
			DBSkip(-1)
			loop
		endif
		//	If li > 63
		If li > 47
			li := 1
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li++
			@ li++,0 PSAY "Periodo: "+Dtoc(Mv_Par01) + " ate' " + Dtoc(Mv_Par02)
			li++
		EndIF
		cVend := TB_VEND
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ‚ venda sem vendedor                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if cPrefix != TB_PREFIXO
			cSitVei := ""
			if cPrefix == "VEI"
				if nCont == 1
					IF cSitVei == "0"
						if nQtVeiN # 0
							@ li,005 PSAY "Total Veiculos Novos:     "+transform(nQtVeiN,"99999999")+"    "+transform(nTotVeiN, "@E 99,999,999.99")+"    "+transform(nTotVN, "@E 99,999,999.99")+"    "+transform(nTotVN1, "@E 99,999,999.99")
							nQtVeiNAc += nQtVeiN
							nTotVeiNAc += nTotVeiN
							nTotVNAc += nTotVN
							nTotVN1Ac += nTotVN1
						endif
					Else
						if nQtVeiU # 0
							@ li,005 PSAY "Total Veiculos Usados:    "+transform(nQtVeiU,"99999999")+"    "+transform(nTotVeiU, "@E 99,999,999.99")+"    "+transform(nTotVU, "@E 99,999,999.99")+"    "+transform(nTotVU1, "@E 99,999,999.99")
							nQtVeiUAc += nQtVeiU
							nTotVeiUAc += nTotVeiU
							nTotVUAc += nTotVU
							nTotVU1Ac += nTotVU1
							
						endif
					Endif
					nQtVeiU  := 0
					nQtVeiN  := 0
					nTotVeiU := 0
					nTotVeiN := 0
					nTotVN   := 0
					nTotVU   := 0
					nTotVN1  := 0
					nTotVU1  := 0
					li++
				Endif
			Endif
			if nAchou == 1
				@ li,000 PSay ""
				@ li,pcol() PSAY space(3)+"  Total Sub-Depto:          "+transform(nSQtVen,"99999999")+"    "+transform(nTotal1, "@E 99,999,999.99")+"    "+transform(nTotal2, "@E 99,999,999.99")+"    "+transform(nTotal3, "@E 99,999,999.99")
				li++
				nTotal1 := 0
				nTotal2 := 0
				nTotal3 := 0
				nSQtVen := 0
				nNumero := 0
				@ li,000 PSay ""
				Li++
				@ li,pcol() PSAY "  T o t a l  d o  D e p t o :  "+transform(nTotDepto,"99999999")+"    "+transform(nTotDepto1, "@E 99,999,999.99")+"    "+transform(nTotDepto2, "@E 99,999,999.99")+"    "+transform(nTotDepto3, "@E 99,999,999.99")
				nTotDepto  := 0
				nTotDepto1 := 0
				nTotDepto2 := 0
				nTotDepto3 := 0
				li++
				if nQtVeiNAc + nQtVeiUAc != 0
					@ li++,0 PSAY "  Total de Veiculos Novos   :  "+transform(nQtVeiNAc,"99999999")+"    "+transform(nTotVeiNAc, "@E 99,999,999.99")+"    "+transform(nTotVNAc, "@E 99,999,999.99")+"    "+transform(nTotVN1Ac, "@E 99,999,999.99")
					@ li++,0 PSAY "  Total de Veiculos Usados  :  "+transform(nQtVeiUAc,"99999999")+"    "+transform(nTotVeiUAc, "@E 99,999,999.99")+"    "+transform(nTotVUAc, "@E 99,999,999.99")+"    "+transform(nTotVU1Ac, "@E 99,999,999.99")
					nQtVeiNAc := 0
					nQtVeiUAc := 0
					li++
				endif
			Endif
			li++
			if TRB->TB_PREFIXO == "BAL"
				cDescPref := "B A L C A O"
			Elseif TRB->TB_PREFIXO == "OFI"
				cDescPref := "O F I C I N A"
			Elseif TRB->TB_PREFIXO == "VEI"
				cDescPref := "V E I C U L O S"
			Else
				cDescPref := "O U T R O S"
			Endif
			
			@ li,000 PSay ""
			@ li,000 PSay TRB->TB_PREFIXO+"  -  "+cDescPref
			nRank := 0
			li++
			cDepto := "1"
			
		Endif
		
		if cDepto <> TB_DEPTO //.or. cPrefix != TB_PREFIXO
			if cDepto <> "1"
				if cPrefix == "VEI"
					if nCont == 1
						IF cSitVei == "0"
							if nQtVeiN # 0
								@ li,005 PSAY "Total Veiculos Novos:     "+transform(nQtVeiN,"99999999")+"    "+transform(nTotVeiN, "@E 99,999,999.99")+"    "+transform(nTotVN, "@E 99,999,999.99")+"    "+transform(nTotVN1, "@E 99,999,999.99")
								nQtVeiNAc += nQtVeiN
								nTotVeiNAc += nTotVeiN
								nTotVNAc += nTotVN
								nTotVN1Ac += nTotVN1
								
							endif
						Else
							if nQtVeiU # 0
								@ li,005 PSAY "Total Veiculos Usados:    "+transform(nQtVeiU,"99999999")+"    "+transform(nTotVeiU, "@E 99,999,999.99")+"    "+transform(nTotVU, "@E 99,999,999.99")+"    "+transform(nTotVU1, "@E 99,999,999.99")
								nQtVeiUAc += nQtVeiU
								nTotVeiUAc += nTotVeiU
								nTotVUAc += nTotVU
								nTotVU1Ac += nTotVU1
								
							endif
						Endif
						cSitVei := ""
						nQtVeiU  := 0
						nQtVeiN  := 0
						nTotVeiU := 0
						nTotVeiN := 0
						nTotVN   := 0
						nTotVU   := 0
						nTotVN1  := 0
						nTotVU1  := 0
						li++
					Endif
				Endif
			Endif
			if nNumero == 1
				nAchou := 1
				@ li,000 PSay ""
				@ li,pcol() PSAY space(3)+ "  Total Sub-Depto:          "+transform(nSQtVen,"99999999")+"    "+transform(nTotal1, "@E 99,999,999.99")+"    "+transform(nTotal2, "@E 99,999,999.99")+"    "+transform(nTotal3, "@E 99,999,999.99")
				li++
				nTotal1 := 0
				nTotal2 := 0
				nTotal3 := 0
				nSQtVen := 0
			Endif
	
		If li > 47
			li := 1
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li++
			@ li++,0 PSAY "Periodo: "+Dtoc(Mv_Par01) + " ate' " + Dtoc(Mv_Par02)
			li++
		EndIF
			
			nAchou := 1
			nNumero := 1
			SX5->(DbSeek(xFilial("SX5")+cPtvdSX5+TRB->TB_DEPTO))
			cDesOpe := SX5->X5_DESCRI
			@ li,000 PSay ""
			li++
			@ li,pcol() PSAY space(2)+TB_DEPTO+ "  -  " +cDesOpe
			nRank := 0
			li++
		Endif
		nTotal1 += TB_VALOR1
		nTotal2 += TB_VALOR2
		nTotal3 += TB_VALOR3
		nTotDepto1 += TB_VALOR1
		nTotDepto2 += TB_VALOR2
		nTotDepto3 += TB_VALOR3
		nTQtVen += TRB->TB_QTDVEN
		nSQtVen += TRB->TB_QTDVEN
		nTotDepto += TRB->TB_QTDVEN
		if TB_PREFIXO == "VEI"
			if cSitVei <>  TB_ESTVEI
				if nCont == 1
					IF cSitVei == "0"
						if nQtVeiN # 0
							@ li,005 PSAY "Total Veiculos Novos:     "+transform(nQtVeiN,"99999999")+"    "+transform(nTotVeiN, "@E 99,999,999.99")+"    "+transform(nTotVN, "@E 99,999,999.99")+"    "+transform(nTotVN1, "@E 99,999,999.99")
							nQtVeiNAc += nQtVeiN
							nTotVeiNAc += nTotVeiN
							nTotVNAc += nTotVN
							nTotVN1Ac += nTotVN1
							
							li++
						endif
					Else
						if nQtVeiU # 0
							@ li,005 PSAY "Total Veiculos Usados:    "+transform(nQtVeiU,"99999999")+"    "+transform(nTotVeiU, "@E 99,999,999.99")+"    "+transform(nTotVU, "@E 99,999,999.99")+"    "+transform(nTotVU1, "@E 99,999,999.99")
							li++
							nQtVeiUAc += nQtVeiU
							nTotVeiUAc += nTotVeiU
							nTotVUAc += nTotVU
							nTotVU1Ac += nTotVU1
							
						endif
					Endif
					nQtVeiU  := 0
					nQtVeiN  := 0
					nTotVeiU := 0
					nTotVeiN := 0
					nTotVN   := 0
					nTotVU   := 0
					nTotVN1  := 0
					nTotVU1  := 0
					//               li++
				Endif
			Endif
			nQtVeiN += TRB->TB_QTDVEN
			nQtVeiU += TRB->TB_QTDVEN
			nTotVeiN += TB_VALOR1
			nTotVN += TB_VALOR2
			nTotVN1 += TB_VALOR3
			nTotVeiU += TB_VALOR1
			nTotVU += TB_VALOR2
			nTotVU1 += TB_VALOR3
			
			if cSitVei <>  TB_ESTVEI
				li++
				if TB_ESTVEI == "0"
					@ li,002 PSAY space(3)+"Veiculos Novos"
					nRank := 0
					Li++
				Else
					@ li,002 PSAY space(3)+"Veiculos Usados"
					Li++
					nRank := 0
				Endif
			Endif
			nCont := 1
		Endif
		
		If Mv_Par12 == 1 // Analitico
		
			If !Empty( cVend )
				dbSelectArea("SA3")
				dbSeek(xFilial()+cVend)
				@ li,000 PSay "  "
				@ li,pcol() PSAY space(3)+SA3->A3_COD + " " +substr(SA3->A3_NOME,1,20)
			Else
				@li,410 PSAY space(3)+"******" + " " + STR0013	//"Venda Sem Vendedor"
			Endif
			
			dbSelectArea("TRB")
			@li,pcol()+1 PSAY transform(TRB->TB_QTDVEN, "999999")
			
			@li,pcol()+1 PSAY TB_VALOR1 PicTure tm(TB_VALOR1,16,nDecs)
			@li,pcol()+1 PSAY TB_VALOR2 PicTure tm(TB_VALOR2,16,nDecs)
			@li,pcol()+1 PSAY TB_VALOR3 PicTure tm(TB_VALOR3,16,nDecs)
				
			IF mv_par05 == 2 .or. mv_par05 == 3
				nRank++
				@li,pcol()+1 PSAY nRank	PicTure "9999"
			EndIF
			li++
			
		Endif
		
		nAg1 := nAg1 + TB_VALOR1
		nAg2 := nAg2 + TB_VALOR2
		nAg3 := nAg3 + TB_VALOR3
		
		cNFiscal := TB_DOC
		cDepto	:= TB_DEPTO
		cSitVei	:= TB_ESTVEI
		cPrefix	:= TB_PREFIXO
		
		DbSelectArea("TRB")
		dbSkip(-1)
		
	EndDo
	//IF li != 63//80
	IF li != 47//80
		IF cSitVei == "0"
			if nQtVeiN # 0
				@ li,005 PSAY "Total Veiculos Novos:     "+transform(nQtVeiN,"99999999")+"    "+transform(nTotVeiN, "@E 99,999,999.99")+"    "+transform(nTotVN, "@E 99,999,999.99")+"    "+transform(nTotVN1, "@E 99,999,999.99")
				nQtVeiNAc += nQtVeiN
				nTotVeiNAc += nTotVeiN
				nTotVNAc += nTotVN
				nTotVN1Ac += nTotVN1
				li++
			endif
		else
			if nQtVeiU # 0
				@ li,005 PSAY "Total Veiculos Usados:    "+transform(nQtVeiU,"99999999")+"    "+transform(nTotVeiU, "@E 99,999,999.99")+"    "+transform(nTotVU, "@E 99,999,999.99")+"    "+transform(nTotVU1, "@E 99,999,999.99")
				li++
				nQtVeiUAc += nQtVeiU
				nTotVeiUAc += nTotVeiU
				nTotVUAc += nTotVU
				nTotVU1Ac += nTotVU1
			endif
		endif
		@ li,000 PSay ""
		@ li,pcol() PSAY space(3)+"  Total Sub-Depto:          "+transform(nSQtVen,"99999999")+"    "+transform(nTotal1, "@E 99,999,999.99")+"    "+transform(nTotal2, "@E 99,999,999.99")+"    "+transform(nTotal3, "@E 99,999,999.99")
		li++
		@ li,000 PSay ""
		li++
		@ li,0 PSAY "  T o t a l  d o  D e p t o :  "+transform(nTotDepto,"99999999")+"    "+transform(nTotDepto1, "@E 99,999,999.99")+"    "+transform(nTotDepto2, "@E 99,999,999.99")+"    "+transform(nTotDepto3, "@E 99,999,999.99")
		li++
	Endif
	nTotal1 := 0
	nTotal2 := 0
	nTotal3 := 0
	nSQtVen := 0
	
	//IF li != 63//80
	IF li != 47//80
		//IF li != 220//80
		li++
		@li,  0 PSAY STR0014+space(17)+transform(nTQtVen,"99999999")		//"T O T A L --->"
		// @li, pcol()+1 PSAY space(1)
		@li, pcol()+1 PSAY nAg1 PicTure tm(nAg1,16,nDecs)
		@li, pcol()+1 PSAY nAg2 PicTure tm(nAg2,16,nDecs)
		@li, pcol()+1 PSAY nAg3 PicTure tm(nAg3,16,nDecs)
		//	roda(cbcont,cbtxt)
	Else
		li := 1
		li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		li++
		@li,  0 PSAY STR0014+space(17)+transform(nTQtVen,"99999999")		//"T O T A L --->"
		// @li, pcol()+1 PSAY space(1)
		@li, pcol()+1 PSAY nAg1 PicTure tm(nAg1,16,nDecs)
		@li, pcol()+1 PSAY nAg2 PicTure tm(nAg2,16,nDecs)
		@li, pcol()+1 PSAY nAg3 PicTure tm(nAg3,16,nDecs)
		//	roda(cbcont,cbtxt)
	EndIF

Else  // Anual


//	Cabec1 := "Vendedor             Estado    Janeiro       Fevereiro         Marco           Abril            Maio           Junho           Julho           Agosto         Setembro        Outubro         Novembro        Dezembro   "
//	Cabec2 := "-------------------- ------ --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- --------------- ---------------"
	cabec1 := ""
	cabec2 := ""
	//			  xxxxxxxxxxxxxxxxxxxx Usados 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99 999 9999,999.99
	//			  1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
 	//                  10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
   aVetImp := {}
   // 1o Elemento - Prefixo
   // 2o Elemento - Filial (Depto)
   // 3o Elemento - Estado do Veiculo // Novo ou Usado
   // 4o Elemento - Vendedor
   // 5o Elemento - Qtd Jan
   // 6o Elemento - Vlr Jan
   // 7o Elemento - Qtd Fev
   // 8o Elemento - Vlr Fev
   // 9o Elemento - Qtd Mar
   //10o Elemento - Vlr Mar
   //11o Elemento - Qtd Abr
   //12o Elemento - Vlr Abr
   //13o Elemento - Qtd Mai
   //14o Elemento - Vlr Mai
   //15o Elemento - Qtd Jun
   //16o Elemento - Vlr Jun
   //17o Elemento - Qtd Jul
   //18o Elemento - Vlr Jul
   //19o Elemento - Qtd Ago
   //20o Elemento - Vlr Ago
   //21o Elemento - Qtd Set
   //22o Elemento - Vlr Set
   //23o Elemento - Qtd Out
   //24o Elemento - Vlr Out
   //25o Elemento - Qtd Nov
   //26o Elemento - Vlr Nov
   //27o Elemento - Qtd Dez
   //28o Elemento - Vlr Dez

   nVal01n := nVal02n := nVal03n := nVal04n := nVal05n := nVal06n := nVal07n := nVal08n := nVal09n := nVal10n := nVal11n := nVal12n := 0
   nQtd01n := nQtd02n := nQtd03n := nQtd04n := nQtd05n := nQtd06n := nQtd07n := nQtd08n := nQtd09n := nQtd10n := nQtd11n := nQtd12n := 0
   nTVal01n:= nTVal02n:= nTVal03n:= nTVal04n:= nTVal05n:= nTVal06n:= nTVal07n:= nTVal08n:= nTVal09n:= nTVal10n:= nTVal11n:= nTVal12n:= 0
   nTQtd01n:= nTQtd02n:= nTQtd03n:= nTQtd04n:= nTQtd05n:= nTQtd06n:= nTQtd07n:= nTQtd08n:= nTQtd09n:= nTQtd10n:= nTQtd11n:= nTQtd12n:= 0
   nVal01u := nVal02u := nVal03u := nVal04u := nVal05u := nVal06u := nVal07u := nVal08u := nVal09u := nVal10u := nVal11u := nVal12u := 0
   nQtd01u := nQtd02u := nQtd03u := nQtd04u := nQtd05u := nQtd06u := nQtd07u := nQtd08u := nQtd09u := nQtd10u := nQtd11u := nQtd12u := 0
   nTVal01u:= nTVal02u:= nTVal03u:= nTVal04u:= nTVal05u:= nTVal06u:= nTVal07u:= nTVal08u:= nTVal09u:= nTVal10u:= nTVal11u:= nTVal12u:= 0
   nTQtd01u:= nTQtd02u:= nTQtd03u:= nTQtd04u:= nTQtd05u:= nTQtd06u:= nTQtd07u:= nTQtd08u:= nTQtd09u:= nTQtd10u:= nTQtd11u:= nTQtd12u:= 0

	limite       := 220
	tamanho      := "G"
	nTipo        := 15

   DbSelectArea("TRB")
   DbGotop()
   
   While !eof()
            
			nPos := aScan(aVetImp,{|x| x[2]+x[3]+x[4] == TB_DEPTO+TB_ESTVEI+TB_VEND})
      	If nPos == 0
      		aadd(aVetImp,{TB_PREFIXO,TB_DEPTO,TB_ESTVEI,TB_VEND,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
      		nPos := Len(avetImp)
      	Endif

      	FS_GrvAnual()
      	
			DbSkip()
					
   Enddo

	lPriVez := .t.

	SX5->(DbSeek(xFilial("SX5")+cPtvdSX5+aVetImp[1,2]))
	cDepto  := ""
	nTotImp := len(aVetImp)

   For i = 1 to ntotImp   
   
		If li > 47
		
			li := 1
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li++
			@ li++,0 PSAY "Periodo: "+Dtoc(Mv_Par01) + " ate' " + Dtoc(Mv_Par02)
			li++

			SX5->(DbSeek(xFilial("SX5")+cPtvdSX5+aVetImp[i,2]))
			cDepto  := aVetImp[i,2] + " - " + SX5->X5_DESCRI
			li++
			@ li,0 PSAY cDepto
			li++       
			@ li++,0 PSAY "Vendedor             EstVei     Janeiro       Fevereiro         Marco           Abril            Maio           Junho           Julho           Agosto         Setembro        Outubro         Novembro        Dezembro   "
			@ li++,0 PSAY "--------------------+------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------"		
		EndIF

		If Left(cDepto,2) != aVetImp[i,2] .and. !lPriVez
			@ li++,0 PSAY "--------------------+------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------"		
			@ li++,0 PSAY "  Sub-Total Veiculos Novos |"+transform(nQtd01n,"@E 999")+" "+transform(nVal01n,"@E 9999,999.99")+"|"+transform(nQtd02n,"@E 999")+" "+transform(nVal02n,"@E 9999,999.99")+"|"+transform(nQtd03n,"@E 999")+" "+transform(nVal03n,"@E 9999,999.99")+"|"+;
						transform(nQtd04n,"@E 999")+" "+transform(nVal04n,"@E 9999,999.99")+"|"+transform(nQtd05n,"@E 999")+" "+transform(nVal05n,"@E 9999,999.99")+"|"+transform(nQtd06n,"@E 999")+" "+transform(nVal06n,"@E 9999,999.99")+"|"+transform(nQtd07n,"@E 999")+" "+transform(nVal07n,"@E 9999,999.99")+"|"+transform(nQtd08n,"@E 999")+" "+transform(nVal08n,"@E 9999,999.99")+"|"+;
						transform(nQtd09n,"@E 999")+" "+transform(nVal09n,"@E 9999,999.99")+"|"+transform(nQtd10n,"@E 999")+" "+transform(nVal10n,"@E 9999,999.99")+"|"+transform(nQtd11n,"@E 999")+" "+transform(nVal11n,"@E 9999,999.99")+"|"+transform(nQtd12n,"@E 999")+" "+transform(nVal12n,"@E 9999,999.99")
			@ li++,0 PSAY "  Sub-Total Veiculos Usados|"+transform(nQtd01u,"@E 999")+" "+transform(nVal01u,"@E 9999,999.99")+"|"+transform(nQtd02u,"@E 999")+" "+transform(nVal02u,"@E 9999,999.99")+"|"+transform(nQtd03u,"@E 999")+" "+transform(nVal03u,"@E 9999,999.99")+"|"+;
						transform(nQtd04u,"@E 999")+" "+transform(nVal04u,"@E 9999,999.99")+"|"+transform(nQtd05u,"@E 999")+" "+transform(nVal05u,"@E 9999,999.99")+"|"+transform(nQtd06u,"@E 999")+" "+transform(nVal06u,"@E 9999,999.99")+"|"+transform(nQtd07u,"@E 999")+" "+transform(nVal07u,"@E 9999,999.99")+"|"+transform(nQtd08u,"@E 999")+" "+transform(nVal08u,"@E 9999,999.99")+"|"+;
						transform(nQtd09u,"@E 999")+" "+transform(nVal09u,"@E 9999,999.99")+"|"+transform(nQtd10u,"@E 999")+" "+transform(nVal10u,"@E 9999,999.99")+"|"+transform(nQtd11u,"@E 999")+" "+transform(nVal11u,"@E 9999,999.99")+"|"+transform(nQtd12u,"@E 999")+" "+transform(nVal12u,"@E 9999,999.99")
			@ li++,0 PSAY "---------------------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------"		

			SX5->(DbSeek(xFilial("SX5")+cPtvdSX5+aVetImp[i,2]))
			cDepto  := aVetImp[i,2] + " - " + SX5->X5_DESCRI
			li++
			@ li,0 PSAY cDepto
			li++       
			@ li++,0 PSAY "Vendedor             EstVei     Janeiro       Fevereiro         Marco           Abril            Maio           Junho           Julho           Agosto         Setembro        Outubro         Novembro        Dezembro   "
			@ li++,0 PSAY "--------------------+------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------"		
		   nVal01n := nVal02n := nVal03n := nVal04n := nVal05n := nVal06n := nVal07n := nVal08n := nVal09n := nVal10n := nVal11n := nVal12n := 0
		   nQtd01n := nQtd02n := nQtd03n := nQtd04n := nQtd05n := nQtd06n := nQtd07n := nQtd08n := nQtd09n := nQtd10n := nQtd11n := nQtd12n := 0
		   nVal01u := nVal02u := nVal03u := nVal04u := nVal05u := nVal06u := nVal07u := nVal08u := nVal09u := nVal10u := nVal11u := nVal12u := 0
		   nQtd01u := nQtd02u := nQtd03u := nQtd04u := nQtd05u := nQtd06u := nQtd07u := nQtd08u := nQtd09u := nQtd10u := nQtd11u := nQtd12u := 0
		Endif

		lPriVez := .f.

		If aVetImp[i,3] == "0" // Novos
			cVarSoma := "n"
		Else // Usados
			cVarSoma := "u"
		Endif

	   nVal01&cVarSoma += aVetImp[i,06]
	   nVal02&cVarSoma += aVetImp[i,08]
	   nVal03&cVarSoma += aVetImp[i,10]
	   nVal04&cVarSoma += aVetImp[i,12]
	   nVal05&cVarSoma += aVetImp[i,14]
	   nVal06&cVarSoma += aVetImp[i,16]
	   nVal07&cVarSoma += aVetImp[i,18]
	   nVal08&cVarSoma += aVetImp[i,20]
	   nVal09&cVarSoma += aVetImp[i,22]
	   nVal10&cVarSoma += aVetImp[i,24]
	   nVal11&cVarSoma += aVetImp[i,26]
	   nVal12&cVarSoma += aVetImp[i,28]
	   nQtd01&cVarSoma += aVetImp[i,05]
	   nQtd02&cVarSoma += aVetImp[i,07]
	   nQtd03&cVarSoma += aVetImp[i,09]
	   nQtd04&cVarSoma += aVetImp[i,11]
	   nQtd05&cVarSoma += aVetImp[i,13]
	   nQtd06&cVarSoma += aVetImp[i,15]
	   nQtd07&cVarSoma += aVetImp[i,17]
	   nQtd08&cVarSoma += aVetImp[i,19]
	   nQtd09&cVarSoma += aVetImp[i,21]
	   nQtd10&cVarSoma += aVetImp[i,23]
	   nQtd11&cVarSoma += aVetImp[i,25]
	   nQtd12&cVarSoma += aVetImp[i,27]

	   nTVal01&cVarSoma += aVetImp[i,06]
	   nTVal02&cVarSoma += aVetImp[i,08]
	   nTVal03&cVarSoma += aVetImp[i,10]
	   nTVal04&cVarSoma += aVetImp[i,12]
	   nTVal05&cVarSoma += aVetImp[i,14]
	   nTVal06&cVarSoma += aVetImp[i,16]
	   nTVal07&cVarSoma += aVetImp[i,18]
	   nTVal08&cVarSoma += aVetImp[i,20]
	   nTVal09&cVarSoma += aVetImp[i,22]
	   nTVal10&cVarSoma += aVetImp[i,24]
	   nTVal11&cVarSoma += aVetImp[i,26]
	   nTVal12&cVarSoma += aVetImp[i,28]
	   nTQtd01&cVarSoma += aVetImp[i,05]
	   nTQtd02&cVarSoma += aVetImp[i,07]
	   nTQtd03&cVarSoma += aVetImp[i,09]
	   nTQtd04&cVarSoma += aVetImp[i,11]
	   nTQtd05&cVarSoma += aVetImp[i,13]
	   nTQtd06&cVarSoma += aVetImp[i,15]
	   nTQtd07&cVarSoma += aVetImp[i,17]
	   nTQtd08&cVarSoma += aVetImp[i,19]
	   nTQtd09&cVarSoma += aVetImp[i,21]
	   nTQtd10&cVarSoma += aVetImp[i,23]
	   nTQtd11&cVarSoma += aVetImp[i,25]
	   nTQtd12&cVarSoma += aVetImp[i,27]

		SA3->(DbSeek(xFilial("SA3")+aVetImp[i,4]))
		cVend   := aVetImp[i,4] + " - " +Left(SA3->A3_NOME,11)
	   cEstVei := If(aVetImp[i,3]=="0","Novos ","Usados")

		@ li++,0 PSAY cVend+"|"+cEstVei+"|"+transform(aVetImp[i,05],"@E 999")+" "+transform(aVetImp[i,06],"@E 9999,999.99")+"|"+transform(aVetImp[i,07],"@E 999")+" "+transform(aVetImp[i,08],"@E 9999,999.99")+"|"+transform(aVetImp[i,09],"@E 999")+" "+transform(aVetImp[i,10],"@E 9999,999.99")+"|"+;
							transform(aVetImp[i,11],"@E 999")+" "+transform(aVetImp[i,12],"@E 9999,999.99")+"|"+transform(aVetImp[i,13],"@E 999")+" "+transform(aVetImp[i,14],"@E 9999,999.99")+"|"+transform(aVetImp[i,15],"@E 999")+" "+transform(aVetImp[i,16],"@E 9999,999.99")+"|"+transform(aVetImp[i,17],"@E 999")+" "+transform(aVetImp[i,18],"@E 9999,999.99")+"|"+transform(aVetImp[i,19],"@E 999")+" "+transform(aVetImp[i,20],"@E 9999,999.99")+"|"+;
							transform(aVetImp[i,21],"@E 999")+" "+transform(aVetImp[i,22],"@E 9999,999.99")+"|"+transform(aVetImp[i,23],"@E 999")+" "+transform(aVetImp[i,24],"@E 9999,999.99")+"|"+transform(aVetImp[i,25],"@E 999")+" "+transform(aVetImp[i,26],"@E 9999,999.99")+"|"+transform(aVetImp[i,27],"@E 999")+" "+transform(aVetImp[i,28],"@E 9999,999.99")
   
   Next

	@ li++,0 PSAY "  Sub-Total Veiculos Novos |"+transform(nQtd01n,"@E 999")+" "+transform(nVal01n,"@E 9999,999.99")+"|"+transform(nQtd02n,"@E 999")+" "+transform(nVal02n,"@E 9999,999.99")+"|"+transform(nQtd03n,"@E 999")+" "+transform(nVal03n,"@E 9999,999.99")+"|"+;
					transform(nQtd04n,"@E 999")+" "+transform(nVal04n,"@E 9999,999.99")+"|"+transform(nQtd05n,"@E 999")+" "+transform(nVal05n,"@E 9999,999.99")+"|"+transform(nQtd06n,"@E 999")+" "+transform(nVal06n,"@E 9999,999.99")+"|"+transform(nQtd07n,"@E 999")+" "+transform(nVal07n,"@E 9999,999.99")+"|"+transform(nQtd08n,"@E 999")+" "+transform(nVal08n,"@E 9999,999.99")+"|"+;
					transform(nQtd09n,"@E 999")+" "+transform(nVal09n,"@E 9999,999.99")+"|"+transform(nQtd10n,"@E 999")+" "+transform(nVal10n,"@E 9999,999.99")+"|"+transform(nQtd11n,"@E 999")+" "+transform(nVal11n,"@E 9999,999.99")+"|"+transform(nQtd12n,"@E 999")+" "+transform(nVal12n,"@E 9999,999.99")
	@ li++,0 PSAY "  Sub-Total Veiculos Usados "+transform(nQtd01u,"@E 999")+" "+transform(nVal01u,"@E 9999,999.99")+"|"+transform(nQtd02u,"@E 999")+" "+transform(nVal02u,"@E 9999,999.99")+"|"+transform(nQtd03u,"@E 999")+" "+transform(nVal03u,"@E 9999,999.99")+"|"+;
					transform(nQtd04u,"@E 999")+" "+transform(nVal04u,"@E 9999,999.99")+"|"+transform(nQtd05u,"@E 999")+" "+transform(nVal05u,"@E 9999,999.99")+"|"+transform(nQtd06u,"@E 999")+" "+transform(nVal06u,"@E 9999,999.99")+"|"+transform(nQtd07u,"@E 999")+" "+transform(nVal07u,"@E 9999,999.99")+"|"+transform(nQtd08u,"@E 999")+" "+transform(nVal08u,"@E 9999,999.99")+"|"+;
					transform(nQtd09u,"@E 999")+" "+transform(nVal09u,"@E 9999,999.99")+"|"+transform(nQtd10u,"@E 999")+" "+transform(nVal10u,"@E 9999,999.99")+"|"+transform(nQtd11u,"@E 999")+" "+transform(nVal11u,"@E 9999,999.99")+"|"+transform(nQtd12u,"@E 999")+" "+transform(nVal12u,"@E 9999,999.99")
   li++
	@ li++,0 PSAY "      Total Veiculos Novos |"+transform(nTQtd01n,"@E 999")+" "+transform(nTVal01n,"@E 9999,999.99")+"|"+transform(nTQtd02n,"@E 999")+" "+transform(nTVal02n,"@E 9999,999.99")+"|"+transform(nTQtd03n,"@E 999")+" "+transform(nTVal03n,"@E 9999,999.99")+"|"+;
							transform(nTQtd04n,"@E 999")+" "+transform(nTVal04n,"@E 9999,999.99")+"|"+transform(nTQtd05n,"@E 999")+" "+transform(nTVal05n,"@E 9999,999.99")+"|"+transform(nTQtd06n,"@E 999")+" "+transform(nTVal06n,"@E 9999,999.99")+"|"+transform(nTQtd07n,"@E 999")+" "+transform(nTVal07n,"@E 9999,999.99")+"|"+transform(nTQtd08n,"@E 999")+" "+transform(nTVal08n,"@E 9999,999.99")+"|"+;
							transform(nTQtd09n,"@E 999")+" "+transform(nTVal09n,"@E 9999,999.99")+"|"+transform(nTQtd10n,"@E 999")+" "+transform(nTVal10n,"@E 9999,999.99")+"|"+transform(nTQtd11n,"@E 999")+" "+transform(nTVal11n,"@E 9999,999.99")+"|"+transform(nTQtd12n,"@E 999")+" "+transform(nTVal12n,"@E 9999,999.99")
	@ li++,0 PSAY "      Total Veiculos Usados|"+transform(nTQtd01u,"@E 999")+" "+transform(nTVal01u,"@E 9999,999.99")+"|"+transform(nTQtd02u,"@E 999")+" "+transform(nTVal02u,"@E 9999,999.99")+"|"+transform(nTQtd03u,"@E 999")+" "+transform(nTVal03u,"@E 9999,999.99")+"|"+;
							transform(nTQtd04u,"@E 999")+" "+transform(nTVal04u,"@E 9999,999.99")+"|"+transform(nTQtd05u,"@E 999")+" "+transform(nTVal05u,"@E 9999,999.99")+"|"+transform(nTQtd06u,"@E 999")+" "+transform(nTVal06u,"@E 9999,999.99")+"|"+transform(nTQtd07u,"@E 999")+" "+transform(nTVal07u,"@E 9999,999.99")+"|"+transform(nTQtd08u,"@E 999")+" "+transform(nTVal08u,"@E 9999,999.99")+"|"+;
							transform(nTQtd09u,"@E 999")+" "+transform(nTVal09u,"@E 9999,999.99")+"|"+transform(nTQtd10u,"@E 999")+" "+transform(nTVal10u,"@E 9999,999.99")+"|"+transform(nTQtd11u,"@E 999")+" "+transform(nTVal11u,"@E 9999,999.99")+"|"+transform(nTQtd12u,"@E 999")+" "+transform(nTVal12u,"@E 9999,999.99")

   li := li + 3

	// Impressao do Resumo por Vendedor
   aVetImp := {}
   // 4o Elemento - Vendedor
   // 3o Elemento - Estado do Veiculo // Novo ou Usado
   // 5o Elemento - Qtd Jan
   // 6o Elemento - Vlr Jan
   DbSelectArea("TRB")
   DbGotop()
   
   While !eof()
            
			nPos := aScan(aVetImp,{|x| x[1]+x[2] == TB_VEND+TB_ESTVEI})
      	If nPos == 0
      		aadd(aVetImp,{TB_VEND,TB_ESTVEI,TB_QTDVEN,TB_VALOR2})
      	Else
      		avetImp[nPos,3] += TB_QTDVEN
      		avetImp[nPos,4] += TB_VALOR2
      	Endif
      	
			DbSkip()
					
   Enddo

   nTotImp := Len(avetImp)

	If !(li+3 > 47)
		@ li++,0 PSAY "Vendedor             EstVei  Qtd        Valor "
		@ li++,0 PSAY "--------------------+------+-----------------"
	Endif
   
   For i = 1 to ntotImp   
   
		If li > 47
			li := 1
			li := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			li++
			@ li++,0 PSAY "Vendedor             EstVei  Qtd        Valor "
			@ li++,0 PSAY "--------------------+------+-----------------"
		Endif

		SA3->(DbSeek(xFilial("SA3")+aVetImp[i,1]))
		cVend   := aVetImp[i,1] + " - " +Left(SA3->A3_NOME,11)
	   cEstVei := If(aVetImp[i,2]=="0","Novos ","Usados")

		@ li++,0 PSAY cVend+"|"+cEstVei+"|"+transform(aVetImp[i,03],"@E 99999")+" "+transform(aVetImp[i,04],"@E 9999,999.99")
   
   Next

   li := li + 3

	@ li++,0 PSAY "TOTAL NO PERIODO"
	@ li++,0 PSAY "----------------"
	li++
	@ li++,0 PSAY "                  QUANTIDADE           VALOR"
	@ li++,0 PSAY "Veiculos Novos          "+transform(nTQtd01n+nTQtd02n+nTQtd03n+nTQtd04n+nTQtd05n+nTQtd06n+nTQtd07n+nTQtd08n+nTQtd09n+nTQtd10n+nTQtd11n+nTQtd12n,"@E 99999")+"   "+transform(nTVal01n+nTVal02n+nTVal03n+nTVal04n+nTVal05n+nTVal06n+nTVal07n+nTVal08n+nTVal09n+nTVal10n+nTVal11n+nTVal12n,"@E 99,999,999.99")
	@ li++,0 PSAY "Veiculos Usados         "+transform(nTQtd01u+nTQtd02u+nTQtd03u+nTQtd04u+nTQtd05u+nTQtd06u+nTQtd07u+nTQtd08u+nTQtd09u+nTQtd10u+nTQtd11u+nTQtd12u,"@E 99999")+"   "+transform(nTVal01u+nTVal02u+nTVal03u+nTVal04u+nTVal05u+nTVal06u+nTVal07u+nTVal08u+nTVal09u+nTVal10u+nTVal11u+nTVal12u,"@E 99,999,999.99")

 	nQtdCon := nTQtd01n+nTQtd02n+nTQtd03n+nTQtd04n+nTQtd05n+nTQtd06n+nTQtd07n+nTQtd08n+nTQtd09n+nTQtd10n+nTQtd11n+nTQtd12n+nTQtd01u+nTQtd02u+nTQtd03u+nTQtd04u+nTQtd05u+nTQtd06u+nTQtd07u+nTQtd08u+nTQtd09u+nTQtd10u+nTQtd11u+nTQtd12u
	nTotCon := nTVal01n+nTVal02n+nTVal03n+nTVal04n+nTVal05n+nTVal06n+nTVal07n+nTVal08n+nTVal09n+nTVal10n+nTVal11n+nTVal12n+nTVal01u+nTVal02u+nTVal03u+nTVal04u+nTVal05u+nTVal06u+nTVal07u+nTVal08u+nTVal09u+nTVal10u+nTVal11u+nTVal12u

	@ li++,0 PSAY "Consolidado             "+transform(nQtdCon,"@E 99999")+"   "+transform(nTotCon,"@E 99,999,999.99")

   
Endif	

oObjTempTable:CloseTable()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF2")
Set Filter To
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GeraTrab  ³ Autor ³ Wagner Xavier         ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho para emissao de Estat.de Fatur.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTrab(cEstoq,cDupli)
Local nContador,nTOTAL,nVALICM,nVALIPI,nSoma, NY
//Local nVendedor:= Fa440CntVen()
Local nVendedor:= 1
Local cVendedor:= ""
Local aVend    := {}
Local cVend    := ""
Local cDepto   := ""
Local cSitVei  := ""
Local cPrefix  := ""
Local nQtdVen  := ""
Local aImpostos:= {}
Local nImpos	:=0.00
Local lContinua:= .F.
Local nMoedNF	 :=	1
Local nTaxa		:=	0
Private cCampImp
dbSelectArea("SD2")
dbSetOrder(5)
dbSeek(xFilial("SD2")+Dtos(MV_PAR01),.T.)
SetRegua(SD2->(LastRec())+SD1->(LastRec()))

If Mv_Par12 != 3 // Analitico ou Sintetico

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Faturamento                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdVen := 0
	nSoma   := 0
	While ( !Eof() .And. xFilial("SD2")  == SD2->D2_FILIAL .And.;
		SD2->D2_EMISSAO <= MV_PAR02 )
		IncRegua()
		nTOTAL :=0
		nSoma  :=0
		nVALICM:=0
		nVALIPI:=0
		
		If ( !SD2->D2_TIPO $ "DB" )
			dbSelectArea("SF2")
			dbSetOrder(1)
			lContinua := dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF2")+SD2->D2_TES)
			nTaxa		:=	IIf(Type("SF2->F2_TXMOEDA")=="U",0,SF2->F2_TXMOEDA)
			nMoedNF	:=	IIF(Type("SF2->F2_MOEDA")  =="U",1,SF2->F2_MOEDA)
			dbSelectArea("SD2")
			If (SF4->F4_DUPLIC=="S" .and. SF4->F4_ESTOQUE=="N" .and. Alltrim(SF4->F4_ATUATF)#"S")
				dbSelectArea("VS1")
				dbSetOrder(3)
				dbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
				dbSelectArea("VEC")
				dbSetOrder(4)
				dbSeek(xFilial("VEC")+SF2->F2_DOC+SF2->F2_SERIE)
				
				cEstoq := If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
				cDupli := If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
				IF ( SF2->F2_DESPESA + SF2->F2_FRETE + SF2->F2_SEGURO ) <> 0
					cEstoq := "SN"
					cDupli := "SN"
				Endif
				If ( Alltrim(VS1->VS1_NOROUT)=="2" ).and. (Alltrim(VEC->VEC_GRUITE) <> "SRVC" )
					cEstoq := "SN"
					cDupli := "SN"
				Endif
			Endif
			If lContinua .And. AvalTes(SD2->D2_TES,cEstoq,cDupli) .and. SF4->F4_ATUATF # "S"
				
				nSoma += SD2->D2_DESPESA + SD2->D2_VALFRE + SD2->D2_SEGURO
				IF  nSoma <> 0
					nTotal += nSoma
				Endif
				
				If SF4->F4_DUPLIC=="S"
					If cPaisLoc	==	"BRA"
						nVALICM += xMoeda(SD2->D2_VALICM,1,mv_par06,SD2->D2_EMISSAO,nDecs+1)
						nVALIPI += xMoeda(SD2->D2_VALIPI,1,mv_par06,SD2->D2_EMISSAO,nDecs+1)
					Endif
					nTotal	+=	xMoeda(SD2->D2_TOTAL,nMoedNF,mv_par06,SD2->D2_EMISSAO,nDecs+1,nTaxa)
				Endif
				If ( nTotal <> 0 )
					cVendedor := "1"
					For nContador := 1 To nVendedor
						dbSelectArea("VS1")
						dbSetOrder(3)
						dbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
						DbSelectArea( "VOO" )
						DbSetOrder(4)
						DbSeek( xFilial("VOO") + SF2->F2_DOC+SF2->F2_SERIE)
						
						if SF2->F2_PREFORI == "VEI"
							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+SD2->D2_COD)
							
							DBSELECTAREA("VV1")
							DBSETORDER(1)
							if DBSEEK(XFILIAL("VV1")+SB1->B1_CODITE)
								//Silvania 14/03/06
								DBSelectArea("VV0")
								DbSetOrder(4)
								DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
								if VV0->VV0_TIPFAT $ "02"
									cEstVei := "Veiculos Novos"
									cSitVei := "0"
								Else
									cEstVei := "Veiculos Usados"
									cSitVei := "1"
								Endif
							Endif
						Endif
						
						
						/*
						if VV1->VV1_ESTVEI == "0"
						cEstVei := "Veiculos Novos"
						cSitVei := "0"
						Else
						cEstVei := "Veiculos Usados"
						cSitVei := "1"
						Endif
						Endif
						Endif
						*/
						dbSelectArea("TRB")
						dbSetOrder(1)
						//					cVend  := SF2->(FieldGet( FieldPos("F2_VEND"+cVendedor)))
						cVend  := SF2->(FieldGet( FieldPos("F2_VEND"+cVendedor)))
						If SF2->F2_PREFORI == "VEI"
							DBSelectArea("VV0")
							DbSetOrder(4)
							DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
							If Type("VV0_DEPTO") != "U"
								cDepto := VV0->VV0_DEPTO
							else
								cDepto := VS1->VS1_DEPTO
							endif
						Elseif SF2->F2_PREFORI == "BAL"
							cDepto := VS1->VS1_DEPTO
						Elseif SF2->F2_PREFORI == "OFI"
							cDepto := VOO->VOO_DEPTO
						Endif
						DBSelectArea("TRB")
						cPrefix:= SF2->F2_PREFORI
						If cVend >= mv_par03 .And. cVend <= mv_par04
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se vendedor em branco, considera apenas 1 vez        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(cVend) .and. nContador > 1
								Loop
							Endif
							nQtdVen+= 1
							
							If ( aScan(aVend,cVend)==0 )
								Aadd(aVend,cVend)
							EndIf
							if cPrefix == "VEI"
								If (dbSeek( cPrefix+cDepto+cSitVei+cVend ))
									RecLock("TRB",.F.)
								Else
									RecLock("TRB",.T.)
								EndIF
							Else
								If (dbSeek( cPrefix+cDepto+""+cVend ))
									RecLock("TRB",.F.)
								Else
									RecLock("TRB",.T.)
								EndIF
							Endif
							Replace TB_VEND    With cVend
							Replace TB_DEPTO   With cDEPTO
							if cPrefix == "VEI"
								Replace TB_ESTVEI  With cSitVei
							Else
								Replace TB_ESTVEI  With ""
							Endif
							Replace TB_QTDVEN  With TB_QTDVEN+1
							Replace TB_EMISSAO With SF2->F2_EMISSAO
							Replace TB_VALOR2  With TB_VALOR2+IIF(SF2->F2_TIPO == "P",0,nTOTAL)
							If ( cPaisLoc=="BRA" )
								Replace TB_VALOR1  With TB_VALOR1+(nTOTAL-nVALICM)
								Replace TB_VALOR3  With TB_VALOR3+IIF(SF2->F2_TIPO == "P",0,nTotal)+nVALIPI
							Else
								Replace TB_VALOR1  With TB_VALOR1+nTOTAL
								Replace TB_VALOR3  With TB_VALOR3+IIF(SF2->F2_TIPO == "P",0,nTotal)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Pesquiso pelas caracteristicas de cada imposto               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aImpostos:=TesImpInf(SD2->D2_TES)
								For nY:=1 to Len(aImpostos)
									cCampImp:="SD2->"+(aImpostos[nY][2])
									nImpos	:=	xMoeda(&cCampImp.,nMoedNF,mv_par06,SD2->D2_EMISSAO,nDecs+1,nTaxa)
									If ( aImpostos[nY][3]=="1" )
										Replace TB_VALOR3  With TB_VALOR3 + nImpos
									Else
										Replace TB_VALOR1  With TB_VALOR1 - nImpos
									EndIf
								Next
							EndIf
							Replace TB_DOC	    With SF2->F2_DOC
							Replace TB_PREFIXO With SF2->F2_PREFORI
							MsUnlock()
						Endif
					Next nContador
				EndIf
			EndIf
		EndIf
		dbSelectArea("SD2")
		dbSkip()
		If lContinua .And. ( xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA!=;
			SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA )
			For nContador := 1 To Len(aVend)
				dbSelectArea("TRB")
				dbSetOrder(1)
				if cPrefix == "VEI"
					If dbSeek(cPrefix+cDepto+cSitVei+aVend[1])
						RecLock("TRB",.F.)
						TRB->TB_VALOR3 += xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_FRETAUT,nMoedNF,mv_par06,SF2->F2_EMISSAO,nDecs+1,nTaxa)
						MsUnLock()
					Endif
				Else
					If dbSeek(cPrefix+cDepto+""+aVend[1])
						RecLock("TRB",.F.)
						TRB->TB_VALOR3 += xMoeda(SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_FRETAUT,nMoedNF,mv_par06,SF2->F2_EMISSAO,nDecs+1,nTaxa)
						MsUnLock()
					Endif
				Endif
			Next nContador
			aVend := {}
		EndIf
		dbSelectArea("SD2")
	EndDo
	
Else // Anual - Veiculo

	//////////////////////////////////////////
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Faturamento                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdVen := 0
	nSoma   := 0
	While ( !Eof() .And. xFilial("SD2")  == SD2->D2_FILIAL .And.	SD2->D2_EMISSAO <= MV_PAR02 )
	
		IncRegua()
	
		nTOTAL :=0
		nSoma  :=0
		nVALICM:=0
		nVALIPI:=0
		
		If ( !SD2->D2_TIPO $ "DB" )
			dbSelectArea("SF2")
			dbSetOrder(1)
			lContinua := dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF2")+SD2->D2_TES)

			If SF2->F2_PREFORI == "VEI"
				nTaxa		:=	IIf(Type("SF2->F2_TXMOEDA")=="U",0,SF2->F2_TXMOEDA)
				nMoedNF	:=	IIF(Type("SF2->F2_MOEDA")  =="U",1,SF2->F2_MOEDA)
				dbSelectArea("SD2")
		
				If (SF4->F4_DUPLIC=="S" .and. SF4->F4_ESTOQUE=="N" .and. Alltrim(SF4->F4_ATUATF)#"S")
					cEstoq := If( (MV_PAR09 == 1),"S",If( (MV_PAR09 == 2),"N","SN" ) )
					cDupli := If( (MV_PAR08 == 1),"S",If( (MV_PAR08 == 2),"N","SN" ) )
					IF ( SF2->F2_DESPESA + SF2->F2_FRETE + SF2->F2_SEGURO ) <> 0
						cEstoq := "SN"
						cDupli := "SN"
					Endif
				Endif
			Else 
				lContinua := .f.
			Endif	
	
			If lContinua .And. AvalTes(SD2->D2_TES,cEstoq,cDupli) .and. SF4->F4_ATUATF # "S"
				
				nSoma += SD2->D2_DESPESA + SD2->D2_VALFRE + SD2->D2_SEGURO
				IF  nSoma <> 0
					nTotal += nSoma
				Endif
				
				If SF4->F4_DUPLIC=="S"
					If cPaisLoc	==	"BRA"
						nVALICM += xMoeda(SD2->D2_VALICM,1,mv_par06,SD2->D2_EMISSAO,nDecs+1)
						nVALIPI += xMoeda(SD2->D2_VALIPI,1,mv_par06,SD2->D2_EMISSAO,nDecs+1)
					Endif
					nTotal	+=	xMoeda(SD2->D2_TOTAL,nMoedNF,mv_par06,SD2->D2_EMISSAO,nDecs+1,nTaxa)
				Endif
				
				If ( nTotal <> 0 )
					cVendedor := "1"
					For nContador := 1 To nVendedor
						dbSelectArea("VS1")
						dbSetOrder(3)
						dbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
						DbSelectArea( "VOO" )
						DbSetOrder(4)
						DbSeek( xFilial("VOO") + SF2->F2_DOC+SF2->F2_SERIE)
						
						DBSELECTAREA("VV1")
						DBSETORDER(1)
						if DBSEEK(XFILIAL("VV1")+SD2->D2_COD)
							//Silvania 14/03/06
							DBSelectArea("VV0")
							DbSetOrder(4)
							DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
							if VV0->VV0_TIPFAT $ "02"
								cEstVei := "Veiculos Novos"
								cSitVei := "0"
							Else
								cEstVei := "Veiculos Usados"
								cSitVei := "1"
							Endif
						Endif
						
						dbSelectArea("TRB")
						dbSetOrder(1)
						cVend  := SF2->(FieldGet( FieldPos("F2_VEND"+cVendedor)))
	
						DBSelectArea("VV0")
						DbSetOrder(4)
						DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
						If Type("VV0_DEPTO") != "U"
							cDepto := VV0->VV0_DEPTO
						else
							cDepto := VS1->VS1_DEPTO
						endif
						
						DBSelectArea("TRB")
						
						cPrefix := SF2->F2_PREFORI
						cAnoMes := Left(Dtos(SF2->F2_EMISSAO),6)
						
						If cVend >= mv_par03 .And. cVend <= mv_par04
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Se vendedor em branco, considera apenas 1 vez        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If Empty(cVend) .and. nContador > 1
								Loop
							Endif
							nQtdVen+= 1
							
							If ( aScan(aVend,cVend)==0 )
								Aadd(aVend,cVend)
							EndIf

							If (dbSeek( cPrefix+cDepto+cSitVei+cVend+cAnoMes))
								RecLock("TRB",.F.)
							Else
								RecLock("TRB",.T.)
							Endif
							Replace TB_VEND    With cVend
							Replace TB_DEPTO   With cDEPTO
							Replace TB_ESTVEI  With cSitVei
							Replace TB_QTDVEN  With TB_QTDVEN+1
							Replace TB_EMISSAO With Ctod("01/"+StrZero(month(SF2->F2_EMISSAO),2)+"/"+StrZero(Year(SF2->F2_EMISSAO),2))//SF2->F2_EMISSAO
							Replace TB_VALOR2  With TB_VALOR2+IIF(SF2->F2_TIPO == "P",0,nTOTAL)
							If ( cPaisLoc=="BRA" )
								Replace TB_VALOR1  With TB_VALOR1+(nTOTAL-nVALICM)
								Replace TB_VALOR3  With TB_VALOR3+IIF(SF2->F2_TIPO == "P",0,nTotal)+nVALIPI
							Else
								Replace TB_VALOR1  With TB_VALOR1+nTOTAL
								Replace TB_VALOR3  With TB_VALOR3+IIF(SF2->F2_TIPO == "P",0,nTotal)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Pesquiso pelas caracteristicas de cada imposto               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aImpostos:=TesImpInf(SD2->D2_TES)
								For nY:=1 to Len(aImpostos)
									cCampImp:="SD2->"+(aImpostos[nY][2])
									nImpos	:=	xMoeda(&cCampImp.,nMoedNF,mv_par06,SD2->D2_EMISSAO,nDecs+1,nTaxa)
									If ( aImpostos[nY][3]=="1" )
										Replace TB_VALOR3  With TB_VALOR3 + nImpos
									Else
										Replace TB_VALOR1  With TB_VALOR1 - nImpos
									EndIf
								Next
							EndIf
							Replace TB_DOC	    With SF2->F2_DOC
							Replace TB_PREFIXO With SF2->F2_PREFORI
							MsUnlock()
						Endif
					Next nContador
				EndIf
			EndIf
		EndIf
		dbSelectArea("SD2")
		dbSkip()
		If lContinua .And. ( xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA!=;
			SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA )
			aVend := {}
		EndIf
		dbSelectArea("SD2")
	EndDo
	//////////////////////////////////////////
Endif

If Mv_Par12 != 3 // Analitico ou Sintetico

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Devolucao                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( MV_PAR07 == 1 )
		dbSelectArea("SD1")
		dbSetOrder(6)
		dbSeek(xFilial("SD1")+Dtos(MV_PAR01),.T.)
		While ( !Eof() .And. xFilial("SD1")  == SD1->D1_FILIAL .And.;
			SD1->D1_DTDIGIT <= MV_PAR02 )
			IncRegua()
			nTOTAL :=0
			nSoma  :=0
			nVALICM:=0
			nVALIPI:=0
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF1")+SD1->D1_TES)
			
			
			If cPaisLoc == "BRA"
				dbSelectArea("SD1")
				//			If AvalTes(D1_TES,cEstoq,cDupli)
				If ( SD1->D1_TIPO $ "D" )
					if SF4->F4_OPEMOV == "09"
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						nVALICM := xMoeda(SD1->D1_VALICM,1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						nVALIPI := xMoeda(SD1->D1_VALIPI,1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						nTOTAL  := xMoeda((SD1->D1_TOTAL - SD1->D1_VALDESC),1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						cVendedor := "1"
						dbSelectArea("SF2")
						dbSetOrder(1)
						If ( dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI) )
							if SF2->F2_PREFORI == "BAL"
								dbSelectArea("VS1")
								dbSetOrder(3)
								dbSeek(xFilial("VS1")+SD1->D1_NFORI+SD1->D1_SERIORI)
								cDEPTO := VS1->VS1_DEPTO
							Else
								DbSelectArea( "VOO" )
								DbSetOrder(4)
								DbSeek( xFilial("VOO") + SF2->F2_DOC+SF2->F2_SERIE)
								cDepto := VOO->VOO_DEPTO
							Endif
							For nContador := 1 TO nVendedor
								dbSelectArea("TRB")
								dbSetOrder(1)
								cVend := SF2->(FieldGet(FieldPos("F2_VEND"+cVendedor)))
								cVendedor := Soma1(cVendedor,1)
								If cVend >= MV_PAR03 .And. cVend <= MV_PAR04
									If Empty(cVend) .and. nContador > 1
										Loop
									EndIf
									If ( aScan(aVend,cVend) == 0 )
										AADD(aVend,cVend)
									EndIf
									If nTOTAL > 0
										If (dbSeek(SF2->F2_PREFORI+cDepto+""+cVend ))
											RecLock("TRB",.F.)
										Else
											RecLock("TRB",.T.)
										EndIf
										Replace TB_VEND    With cVend
										Replace TB_DEPTO   With cDEPTO
										Replace TB_QTDVEN  With TB_QTDVEN+1
										Replace TB_EMISSAO With SF1->F1_EMISSAO
										Replace TB_VALOR2  With TB_VALOR2-nTOTAL
										Replace TB_VALOR1  With TB_VALOR1-(nTOTAL-nVALICM)
										Replace TB_VALOR3  With TB_VALOR3-nTOTAL-nVALIPI
										Replace TB_DOC	    With SF1->F1_DOC
										Replace TB_PREFIXO With SF2->F2_PREFORI
										MsUnlock()
									EndIf
								Endif
							Next nContador
						EndIf
					EndIf
				EndIf
			Else
				If AvalTes(SD1->D1_TES,cEstoq,cDupli)
					If ( SD1->D1_TIPO $ "D" )
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						nTaxa		:=	IIf(Type("SF1->F1_TXMOEDA")=="U",0,SF1->F1_TXMOEDA)
						nMoedNF	:=	IIF(Type("SF1->F1_MOEDA")  =="U",1,SF1->F1_MOEDA)
						
						nTOTAL  := xMoeda((SD1->D1_TOTAL - SD1->D1_VALDESC),nMoedNF,mv_par06,SD1->D1_DTDIGIT,nDecs+1,nTaxa)
						cVendedor := "1"
						For nContador := 1 TO 1
							dbSelectArea("TRB")
							dbSetOrder(1)
							cVend := SF1->(FieldGet(FieldPos("F1_VEND"+cVendedor)))
							cVendedor := Soma1(cVendedor,1)
							If cVend >= MV_PAR03 .And. cVend <= MV_PAR04
								If Empty(cVend) .and. nContador > 1
									Loop
								EndIf
								If ( aScan(aVend,cVend) == 0 )
									AADD(aVend,cVend)
								EndIf
								If nTOTAL > 0
									If (dbSeek( cDepto+cVend ))
										RecLock("TRB",.F.)
									Else
										RecLock("TRB",.T.)
									EndIf
									Replace TB_VEND    With cVend
									Replace TB_EMISSAO With SF1->F1_EMISSAO
									Replace TB_DEPTO   With cDEPTO
									Replace TB_QTDVEN  With TB_QTDVEN+1
									Replace TB_VALOR2  With TB_VALOR2-nTOTAL
									Replace TB_VALOR1  With TB_VALOR1-nTOTAL
									Replace TB_VALOR3  With TB_VALOR3-nTotal
									//								MsUnlock()
									//								nSavF3 := recno()
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Pesquiso pelas caracteristicas de cada imposto               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aImpostos:=TesImpInf(SD1->D1_TES)
									For nY:=1 to Len(aImpostos)
										cCampImp:="SD1->"+(aImpostos[nY][2])
										nImpos	:=	xMoeda(&cCampImp.,nMoedNF,mv_par06,SD1->D1_DTDIGIT,nDecs+1,nTaxa)
										DbSelectArea("TRB")
										If ( aImpostos[nY][3]=="1" )
											Replace TB_VALOR3  With TB_VALOR3 - nImpos
										Else
											Replace TB_VALOR1  With TB_VALOR1 + nImpos
										EndIf
									Next nY
									Replace TB_DOC	    With SF1->F1_DOC
									Replace TB_PREFIXO With SF2->F2_PREFORI
								Endif
								MsUnlock()
							EndIf
						Next nContador
					EndIf
				Endif
			Endif
			dbSelectArea("SD1")
			dbSkip()
			If ( SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==;
				xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )
				FOR nContador := 1 TO Len(aVend)
					dbSelectArea("TRB")
					dbSetOrder(1)
					cVend := aVend[nContador]
					//dbSeek( cVend )
					dbSeek(SF2->F2_PREFORI+cDepto+""+cVend)
					RecLock("TRB",.F.)
					If ( cPaisLoc=="BRA")
						Replace TB_VALOR3  With TB_VALOR3-xMoeda(SF1->F1_FRETE-SF1->F1_DESPESA-SF1->F1_ICMSRET,1,mv_par06,SF1->F1_DTDIGIT,nDecs+1)
					Else
						Replace TB_VALOR3  With TB_VALOR3-xMoeda(IIf(Type("SF1->F1_FRETINC")#"U".And.SF1->F1_FRETINC<> "S",;
						SF1->F1_FRETE,0);
						+SF1->F1_DESPESA,nMoedNF,mv_par06,SF1->F1_DTDIGIT,nDecs+1,nTaxa)
					EndIf
					MsUnlock()
				Next nContador
				aVend:={}
			EndIf
			dbSelectArea("SD1")
		EndDo
	EndIf
     
Else // Anual
             
	// Manoel (11/08/2008) - Entendo que nao esta lendo devolucao para Veiculos
   return .t.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Devolucao                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( MV_PAR07 == 1 )
		dbSelectArea("SD1")
		dbSetOrder(6)
		dbSeek(xFilial("SD1")+Dtos(MV_PAR01),.T.)
		While ( !Eof() .And. xFilial("SD1")  == SD1->D1_FILIAL .And.;
			SD1->D1_DTDIGIT <= MV_PAR02 )
			IncRegua()
			nTOTAL :=0
			nSoma  :=0
			nVALICM:=0
			nVALIPI:=0
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF1")+SD1->D1_TES)
			
			
			If cPaisLoc == "BRA"
				dbSelectArea("SD1")
				If ( SD1->D1_TIPO $ "D" )
					if SF4->F4_OPEMOV == "09"
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						nVALICM := xMoeda(SD1->D1_VALICM,1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						nVALIPI := xMoeda(SD1->D1_VALIPI,1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						nTOTAL  := xMoeda((SD1->D1_TOTAL - SD1->D1_VALDESC),1,mv_par06,SD1->D1_DTDIGIT,nDecs+1)
						cVendedor := "1"
						dbSelectArea("SF2")
						dbSetOrder(1)
						If ( dbSeek(xFilial()+SD1->D1_NFORI+SD1->D1_SERIORI) )
							if SF2->F2_PREFORI == "BAL"
								dbSelectArea("VS1")
								dbSetOrder(3)
								dbSeek(xFilial("VS1")+SD1->D1_NFORI+SD1->D1_SERIORI)
								cDEPTO := VS1->VS1_DEPTO
							Else
								DbSelectArea( "VOO" )
								DbSetOrder(4)
								DbSeek( xFilial("VOO") + SF2->F2_DOC+SF2->F2_SERIE)
								cDepto := VOO->VOO_DEPTO
							Endif
							cAnoMes := Left(Dtos(SF1->F1_EMISSAO),6)
							For nContador := 1 TO nVendedor
							
								dbSelectArea("TRB")
								dbSetOrder(1)
								cVend := SF2->(FieldGet(FieldPos("F2_VEND"+cVendedor)))
								cVendedor := Soma1(cVendedor,1)                          

								If cVend >= MV_PAR03 .And. cVend <= MV_PAR04
									If Empty(cVend) .and. nContador > 1
										Loop
									EndIf
									If ( aScan(aVend,cVend) == 0 )
										AADD(aVend,cVend)
									EndIf
									If nTOTAL > 0
										If (dbSeek(SF2->F2_PREFORI+cDepto+""+cVend+cAnoMes ))
											RecLock("TRB",.F.)
										Else
											RecLock("TRB",.T.)
										EndIf
										Replace TB_VEND    With cVend
										Replace TB_DEPTO   With cDEPTO
										Replace TB_QTDVEN  With TB_QTDVEN+1
										Replace TB_EMISSAO With Ctod("01/"+StrZero(month(SF1->F1_EMISSAO),2)+"/"+StrZero(Year(SF1->F1_EMISSAO),2))
										Replace TB_VALOR2  With TB_VALOR2-nTOTAL
										Replace TB_VALOR1  With TB_VALOR1-(nTOTAL-nVALICM)
										Replace TB_VALOR3  With TB_VALOR3-nTOTAL-nVALIPI
										Replace TB_DOC	    With SF1->F1_DOC
										Replace TB_PREFIXO With SF2->F2_PREFORI
										MsUnlock()
									EndIf
								Endif
							Next nContador
						EndIf
					EndIf
				EndIf
			Else
				If AvalTes(SD1->D1_TES,cEstoq,cDupli)
					If ( SD1->D1_TIPO $ "D" )
						dbSelectArea("SF1")
						dbSetOrder(1)
						dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
						nTaxa		:=	IIf(Type("SF1->F1_TXMOEDA")=="U",0,SF1->F1_TXMOEDA)
						nMoedNF	:=	IIF(Type("SF1->F1_MOEDA")  =="U",1,SF1->F1_MOEDA)
						
						nTOTAL  := xMoeda((SD1->D1_TOTAL - SD1->D1_VALDESC),nMoedNF,mv_par06,SD1->D1_DTDIGIT,nDecs+1,nTaxa)
						cVendedor := "1"
						cAnoMes := Left(Dtos(SF1->F1_EMISSAO),6)
						For nContador := 1 TO 1
							dbSelectArea("TRB")
							dbSetOrder(1)
							cVend := SF1->(FieldGet(FieldPos("F1_VEND"+cVendedor+cAnoMes)))
							cVendedor := Soma1(cVendedor,1)
							If cVend >= MV_PAR03 .And. cVend <= MV_PAR04
								If Empty(cVend) .and. nContador > 1
									Loop
								EndIf
								If ( aScan(aVend,cVend) == 0 )
									AADD(aVend,cVend)
								EndIf
								If nTOTAL > 0
									If (dbSeek( cDepto+cVend ))
										RecLock("TRB",.F.)
									Else
										RecLock("TRB",.T.)
									EndIf
									Replace TB_VEND    With cVend
									Replace TB_EMISSAO With Ctod("01/"+StrZero(month(SF1->F1_EMISSAO),2)+"/"+StrZero(Year(SF1->F1_EMISSAO),2))
									Replace TB_DEPTO   With cDEPTO
									Replace TB_QTDVEN  With TB_QTDVEN+1
									Replace TB_VALOR2  With TB_VALOR2-nTOTAL
									Replace TB_VALOR1  With TB_VALOR1-nTOTAL
									Replace TB_VALOR3  With TB_VALOR3-nTotal
									//								MsUnlock()
									//								nSavF3 := recno()
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Pesquiso pelas caracteristicas de cada imposto               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aImpostos:=TesImpInf(SD1->D1_TES)
									For nY:=1 to Len(aImpostos)
										cCampImp:="SD1->"+(aImpostos[nY][2])
										nImpos	:=	xMoeda(&cCampImp.,nMoedNF,mv_par06,SD1->D1_DTDIGIT,nDecs+1,nTaxa)
										DbSelectArea("TRB")
										If ( aImpostos[nY][3]=="1" )
											Replace TB_VALOR3  With TB_VALOR3 - nImpos
										Else
											Replace TB_VALOR1  With TB_VALOR1 + nImpos
										EndIf
									Next nY
									Replace TB_DOC	    With SF1->F1_DOC
									Replace TB_PREFIXO With SF2->F2_PREFORI
								Endif
								MsUnlock()
							EndIf
						Next nContador
					EndIf
				Endif
			Endif
			dbSelectArea("SD1")
			dbSkip()
			If ( SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==;
				xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA )
				aVend:={}
			EndIf
			dbSelectArea("SD1")
		EndDo
	EndIf

Endif

Return .T.

Static Function ValidPerg
local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
//cPerg := PADR(cPerg,6)
cPerg := PADR(cPerg,LEN(SX1->X1_GRUPO))
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Apartir da Data ","","","mv_ch1","D",8,0,1,"G","","mv_par1","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate a Data      ","","","mv_ch2","D",8,0,1,"G","","mv_par2","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Vendedor     ","","","mv_ch3","C",6,0,1,"G","","mv_par3","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
aAdd(aRegs,{cPerg,"04","Ate Vendedor    ","","","mv_ch4","C",6,0,1,"G","","mv_par4","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
aAdd(aRegs,{cPerg,"05","Lista por       ","","","mv_ch5","N",1,0,1,"C","","mv_par5","Vendedor","","","","","Ranking p/ Vlr","","","","","Ranking p/ Qtd","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Qual Moeda      ","","","mv_ch6","N",1,0,1,"C","","mv_par6","1-Moeda","","","","","2-Moeda","","","","","3-Moeda","","","","","4-Moeda","","","","","5-Moeda","","","","",""})
aAdd(aRegs,{cPerg,"07","Inclui Devolucao","","","mv_ch7","N",1,0,1,"C","","mv_par7","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Tes Faturamento ","","","mv_ch8","N",1,0,1,"C","","mv_par8","Gera Financeiro","","","","","Nao Gera","","","","","Considera Ambos","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Tes Estoque     ","","","mv_ch9","N",1,0,1,"C","","mv_par9","Novimenta","","","","","Nao Movimenta","","","","","Considera Ambos","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Departamento    ","","","mv_chA","N",1,0,1,"C","","mv_par10","Veic.Novos","","","","","Veic.Usados","","","","","Pecas","","","","","Oficina","","","","","Nenhuma das Ant.","","","","",""})
aAdd(aRegs,{cPerg,"11","Departamento    ","","","mv_chB","N",1,0,1,"C","","mv_par11","Todos os Vei.","","","","","Todos","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Tipo Relatorio  ","","","mv_chC","N",1,0,1,"C","","mv_par12","Analitico","","","","","Sintetico","","","","","Anual - Veiculos","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	lSk := dbSeek(cPerg+aRegs[i,2])
	RecLock("SX1",!lSk)
	For j:=1 to FCount()
		If j <= Len(aRegs[i])
			if !lSk .or. !(FieldName(j) $ "X1_CNT01.X1_CNT02.X1_CNT03.X1_CNT04.X1_CNT05.X1_PRESEL")
				&(FieldName(j)) := aRegs[i,j]
			endif
		Endif
	Next
	MsUnlock()
Next
dbSelectArea(_sAlias)
Return

                             
/////////////////////////////
Static Function FS_GrvAnual()
      	
If Month(TB_EMISSAO) == 01
	aVetImp[nPos,05] += TB_QTDVEN
	aVetImp[nPos,06] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 02
	aVetImp[nPos,07] += TB_QTDVEN
	aVetImp[nPos,08] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 03
	aVetImp[nPos,09] += TB_QTDVEN      		
	aVetImp[nPos,10] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 04
	aVetImp[nPos,11] += TB_QTDVEN      		
	aVetImp[nPos,12] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 05
	aVetImp[nPos,13] += TB_QTDVEN      		
	aVetImp[nPos,14] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 06
	aVetImp[nPos,15] += TB_QTDVEN      		
	aVetImp[nPos,16] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 07
	aVetImp[nPos,17] += TB_QTDVEN      		
	aVetImp[nPos,18] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 08
	aVetImp[nPos,19] += TB_QTDVEN      		
	aVetImp[nPos,20] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 09
	aVetImp[nPos,21] += TB_QTDVEN      		
	aVetImp[nPos,22] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 10
	aVetImp[nPos,23] += TB_QTDVEN      		
	aVetImp[nPos,24] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 11
	aVetImp[nPos,25] += TB_QTDVEN      		
	aVetImp[nPos,26] += TB_VALOR2      		
ElseIf Month(TB_EMISSAO) == 12
	aVetImp[nPos,27] += TB_QTDVEN      		
	aVetImp[nPos,28] += TB_VALOR2      		
Endif

Return
