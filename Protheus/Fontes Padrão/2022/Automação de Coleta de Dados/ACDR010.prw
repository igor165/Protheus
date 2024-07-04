#INCLUDE "ACDR010.CH" 
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDR010  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pick-List de Vendas/Ordem de Producao (Localizacao Fisica  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDR010()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL tamanho:="G"
LOCAL cDesc1 :=STR0001 //"Este relatorio tem o objetivo de facilitar a retirada de materiais"
LOCAL cDesc2 :=STR0002 //"apos a Criacao de uma OP caso consumam materiais que utilizam o"
LOCAL cDesc3 :=STR0003 //"controle de Localizacao Fisica"
LOCAL cString:="SC9"
PRIVATE cbCont,cabec1,cabec2,cbtxt
PRIVATE cPerg  :="ACDR01"
PRIVATE aReturn := {STR0004,1,STR0005, 2, 2, 1, "",0 }	 //"Zebrado"###"Administracao"
PRIVATE nomeprog:="ACDR010",nLastKey := 0
PRIVATE li:=80, limite:=132, lRodape:=.F.
PRIVATE wnrel := "ACDR010"
PRIVATE titulo:= STR0006 //"Pick-List Localizacao Fisica por Ordem de Producao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt   := SPACE(10)
cbcont  := 0
Li      := 80
m_pag   := 1

cabec1  := STR0007 //"PRODUTO         DESCRICAO                      UM LOTE       SUB-LOTE LOCALIZACAO     NUMERO DE SERIE      QUANTIDADE     DT VALIDADE   POTENCIA"
cabec2  := ""
//                     123456789012345 123456789012345678901234567890 12 1234567890 123456   123456789012345 12345678901234567890 12345678901234 1234567890    123456789012
//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01    De  Ordem de Producao                            ³
//³ mv_par02    Ate Ordem de Producao                            ³
//³ mv_par03    De  Data de entrega                              ³
//³ mv_par04    Ate Data de entrega                              ³
//³ mv_par05    Qtd p/ impressao 1 - Original 2 - Saldo          ³
//³ mv_par06    Considera OPs 1- Firmes 2- Previstas 3- Ambas    ³
//³ mv_par07    Considera Empenho 1 - Somente com Lotes          ³
//³                               2 - Sem Lotes                  ³
//³                               3 - Ambos                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)

pergunte( cPerg,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

RptStatus({|lEnd|R010ImpOP(@lEnd,tamanho,titulo,wnRel,cString)},titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ R010ImpOP³ Autor ³ Anderson Rodrigues    ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Chamada do Relatorio para Pick-List da Ordem de Producao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R010ImpOP(lEnd,tamanho,titulo,wnRel)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave,cCompara
LOCAL cCodAnt  := ""
LOCAL nPos     := 0
LOCAL aRecDC   := {}
PRIVATE cOpAnt := Space(11)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coloca areas nas Ordens Corretas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SB1->(DbSetOrder(1))
SD4->(DbSetOrder(2))
SDC->(DbSetOrder(2))
SC2->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro e indice da IndRegua                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex:= SC2->(IndexKey())

cExpres:='C2_FILIAL=="'+xFilial("SC2")+'".And.'
cExpres+='C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD>="'+mv_par01+'".And.'
cExpres+='C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD<="'+mv_par02+'".And.'
cExpres+='DTOS(C2_DATPRF)>="'+DTOS(mv_par03)+'".And.'
cExpres+='DTOS(C2_DATPRF)<="'+DTOS(mv_par04)+'"'

cSC2ntx := CriaTrab(,.F.)
IndRegua("SC2", cSC2ntx, cIndex,,cExpres,STR0008) //"Selecionando Registros ..."
nIndex := RetIndex("SC2")
dbSetIndex(cSC2ntx+OrdBagExt())
dbSetOrder( nIndex+1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero de registros validos para a SetRegua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbGoTop()
SetRegua(LastRec())

cChaveAnt := "????????????????"

While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o usuario interrompeu o relatorio                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lAbortPrint
		@Prow()+1,001 PSAY STR0009 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If !MtrAvalOp(mv_par06)
		DbSkip()
		Loop
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lista o cabecalho da Ordem de Producao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CabecOP(Tamanho)

	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial("SD4")+cOPAnt))
	While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+cOpAnt
		If mv_par07 == 1 .and. Empty(SD4->D4_LOTECTL+SD4->D4_NUMLOTE)
			SD4->(DbSkip())
			Loop
		Elseif mv_par07 == 2 .and. ! Empty(SD4->D4_LOTECTL+SD4->D4_NUMLOTE)
			SD4->(DbSkip())
			Loop
		EndIf
		If SD4->D4_COD # cCodAnt //.and. Localiza(cCodAnt) // Pula linha quando muda o Produto
			Li++
		EndIf
		If Localiza(SD4->D4_COD)
			SDC->(DbSetOrder(2))
			If Rastro(SD4->D4_COD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lista o detalhe da ordem de producao                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				cChave:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
				cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE)"
			Elseif !Rastro(SD4->D4_COD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Lista o detalhe da ordem de producao                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChave:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT
				cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT)"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Varre composicao do empenho                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SDC->(DbSeek(cChave))
				Do While ! SDC->(Eof()) .And. cChave == &(cCompara)
					nPos:= Ascan(aRecDC,{|x| x[1] == SDC->(RECNO())})
					If nPos > 0
						SDC->(DbSkip())
						Loop
					EndIf
					CabecOP(Tamanho)
					DetalheOP(Tamanho)
					@ Li,50 PSAY SDC->DC_LOTECTL Picture PesqPict("SDC","DC_LOTECTL",10)
					@ Li,61 PSAY SDC->DC_NUMLOTE Picture PesqPict("SDC","DC_NUMLOTE",6)
					@ Li,70 PSAY SDC->DC_LOCALIZ Picture PesqPict("SDC","DC_LOCALIZ",15)
					@ Li,86 PSAY SDC->DC_NUMSERI Picture PesqPict("SDC","DC_NUMSERI",20)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Lista quantidade de acordo com o parametro selecionado        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par05 == 1
						@ Li,106 PSAY SDC->DC_QTDORIG Picture PesqPictQt("DC_QTDORIG",14)
					Else
						@ Li,106 PSAY SDC->DC_QUANT Picture PesqPictQt("DC_QTDORIG",14)
					EndIf
					@ li,124 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
					@ li,138 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
					Li++
					aadd(aRecDC,{SDC->(RECNO())})
					SDC->(DbSkip())
				EndDo
			Else
				CabecOP(Tamanho)
				DetalheOP(Tamanho)
				@ Li,106 PSAY SD4->D4_QUANT Picture PesqPictQt("DC_QTDORIG",14)
				Li++
			EndIf
		Else
			CabecOP(Tamanho)
			DetalheOP(Tamanho)
			@ Li,106 PSAY SD4->D4_QUANT   Picture PesqPictQt("DC_QTDORIG",14)
			@ li,124 PSAY SD4->D4_DTVALID Picture PesqPict("SD4","D4_DTVALID",10)
			@ li,138 PSAY SD4->D4_POTENCI Picture PesqPictQt("D4_POTENCI", 14)
			Li++
		EndIf
		cCodAnt:= SD4->D4_COD
		SD4->(DbSkip())
	EndDo
	SC2->(DbSkip())
EndDo

If Li != 80
	roda(cbcont,cbtxt,tamanho)
EndIf

dbSelectArea("SC2")
RetIndex("SC2")
Ferase(cSC2ntx+OrdBagExt())

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CabecOP  ³ Autor ³Anderson Rodrigues     ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime o cabecalho do relatorio por Ordem de Producao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR010	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CabecOP(Tamanho)
Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
If Li > 55 .Or. SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD != cOpAnt
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,18)
	@ Li, 00 PSAY STR0010+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD //"ORDEM DE PRODUCAO: "
	Li+=2
	SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
	@ Li, 00 PSAY STR0011+SC2->C2_PRODUTO+" - "+SB1->B1_DESC //"PRODUTO..........: "
	Li+=2
	@ Li, 00 PSAY STR0012 //"DATA PREV. INICIO: "
	@ Li, 19 PSAY SC2->C2_DATPRI
	Li+=2
	@ Li, 00 PSAY STR0013 //"DATA PREV. ENTREG: "
	@ Li, 19 PSAY SC2->C2_DATPRF
	Li+=2
	@ Li, 00 PSAY STR0014+Transform(SC2->C2_QUANT,PesqPictQt("C2_QUANT",14)) //"QUANTIDADE.......: "
	Li+=2
	@ Li, 00 PSAY STR0015+SC2->C2_OBS //"OBSERVACAO.......: "
	Li+=2
	@ Li,00 PSAY __PrtThinLine()
	Li+=2
	cOPAnt:=SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD
EndIf
RestArea(aAreaSB1)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ DetalheOP³ Autor ³Anderson Rodrigues     ³ Data ³ 17/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime o detalhe da Ordem de Producao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ACDR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DetalheOP(Tamanho)
Local cAlias:=Alias()
DbSelectArea("SB1")
SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD))
@ Li,00 PSAY SD4->D4_COD			Picture PesqPict("SD4","D4_COD",Tamsx3("B1_COD")[1])
@ Li,16 PSAY Left(SB1->B1_DESC,30)	Picture PesqPict("SB1","B1_DESC",30)
@ Li,47 PSAY SB1->B1_UM				Picture PesqPict("SB1","B1_UM",2)
If !Localiza(SD4->D4_COD)
	@ Li,50 PSAY SD4->D4_LOTECTL	Picture PesqPict("SD4","D4_LOTECTL",10)
	@ Li,61 PSAY SD4->D4_NUMLOTE	Picture PesqPict("SD4","D4_NUMLOTE",6)
EndIf
DbSelectArea(cAlias)
Return
