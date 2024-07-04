#INCLUDE "ACDR010.CH" 
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACDR010  � Autor � Anderson Rodrigues    � Data � 17/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Pick-List de Vendas/Ordem de Producao (Localizacao Fisica  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAACD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDR010()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt   := SPACE(10)
cbcont  := 0
Li      := 80
m_pag   := 1

cabec1  := STR0007 //"PRODUTO         DESCRICAO                      UM LOTE       SUB-LOTE LOCALIZACAO     NUMERO DE SERIE      QUANTIDADE     DT VALIDADE   POTENCIA"
cabec2  := ""
//                     123456789012345 123456789012345678901234567890 12 1234567890 123456   123456789012345 12345678901234567890 12345678901234 1234567890    123456789012
//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14
//                     012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//�������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                          �
//���������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01    De  Ordem de Producao                            �
//� mv_par02    Ate Ordem de Producao                            �
//� mv_par03    De  Data de entrega                              �
//� mv_par04    Ate Data de entrega                              �
//� mv_par05    Qtd p/ impressao 1 - Original 2 - Saldo          �
//� mv_par06    Considera OPs 1- Firmes 2- Previstas 3- Ambas    �
//� mv_par07    Considera Empenho 1 - Somente com Lotes          �
//�                               2 - Sem Lotes                  �
//�                               3 - Ambos                      �
//����������������������������������������������������������������

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � R010ImpOP� Autor � Anderson Rodrigues    � Data � 17/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Chamada do Relatorio para Pick-List da Ordem de Producao   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function R010ImpOP(lEnd,tamanho,titulo,wnRel)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cChave,cCompara
LOCAL cCodAnt  := ""
LOCAL nPos     := 0
LOCAL aRecDC   := {}
PRIVATE cOpAnt := Space(11)

//��������������������������������������������������������������Ŀ
//� Coloca areas nas Ordens Corretas                             �
//����������������������������������������������������������������

SB1->(DbSetOrder(1))
SD4->(DbSetOrder(2))
SDC->(DbSetOrder(2))
SC2->(DbSetOrder(1))

//��������������������������������������������������������������Ŀ
//� Monta filtro e indice da IndRegua                            �
//����������������������������������������������������������������
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

//��������������������������������������������������������Ŀ
//� Verifica o numero de registros validos para a SetRegua �
//����������������������������������������������������������
dbGoTop()
SetRegua(LastRec())

cChaveAnt := "????????????????"

While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se o usuario interrompeu o relatorio                �
	//����������������������������������������������������������������

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

	//��������������������������������������������������������������Ŀ
	//� Lista o cabecalho da Ordem de Producao                       �
	//����������������������������������������������������������������
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
				//��������������������������������������������������������������Ŀ
				//� Lista o detalhe da ordem de producao                         �
				//����������������������������������������������������������������				
				cChave:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
				cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE)"
			Elseif !Rastro(SD4->D4_COD)
				//��������������������������������������������������������������Ŀ
				//� Lista o detalhe da ordem de producao                         �
				//����������������������������������������������������������������
				cChave:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT
				cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT)"
			EndIf
			//��������������������������������������������������������������Ŀ
			//� Varre composicao do empenho                                  �
			//����������������������������������������������������������������
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
					//��������������������������������������������������������������Ŀ
					//�Lista quantidade de acordo com o parametro selecionado        �
					//����������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CabecOP  � Autor �Anderson Rodrigues     � Data � 17/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Imprime o cabecalho do relatorio por Ordem de Producao     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR010	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � DetalheOP� Autor �Anderson Rodrigues     � Data � 17/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Imprime o detalhe da Ordem de Producao                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
