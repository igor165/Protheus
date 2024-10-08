#Include "QIPR130.ch"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPR130  � Autor � Marcelo Pimentel      � Data � 27.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Produto X Fluxograma Geral                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIPR130(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/05/00�------�Retirada da funcao de ajuste do sx1       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIPR130()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL cDesc1		:=STR0001	//"Serao relacionados os Produtos associados"
LOCAL cDesc2		:=STR0002	//"ao Fluxograma Geral."
LOCAL cDesc3		:=""
LOCAL cString		:="QP6" 
LOCAL cTitulo		:=STR0003 	//"Produto X Fluxograma Geral"

PRIVATE ctamanho	:="M"
PRIVATE cPerg		:= "QPR130"
PRIVATE aReturn	:= { STR0004, 1,STR0005, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "QIPR130",nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
wnrel := "QIPR130"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QPR130",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Produto De              	           �
//� mv_par02             // Produto Ate                          �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R130Imp(@lEnd,wnrel,cString,cTitulo)},cTitulo)
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R130IMP  � Autor � Marcelo Pimentel      � Data � 27.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR130			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R130Imp(lEnd,wnrel,cString,cTitulo)
Local cBtXT
Local cbCont:=00
Local cKey
Local cNomArq1
Local Cabec1:=""
Local Cabec2:=""
Local cCond:=""
Local nMVCOMP := GetMV("MV_COMP")
//		    				012345678901234567890123456789012345678901234567890123456789012345678901234567890
// 						   		 1			  2			3			 4			  5			6			 7			  8
//							XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXX XXXXXXXXXXXXXX
Cabec1:= "PRODUTO                                                  FLUXOGRAMA GERAL"
Cabec2:= ""

cbtxt := SPACE(10)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
li       := 80
m_pag    := 1
nTipo 	:= IIF(aReturn[04]==1,15,18)

dbSelectArea("QP6")
cKey:=IndexKey()
cCond := 'QP6_PRODUT >= "' + mv_par01 + '"'
cCond += '.And. QP6_PRODUT <= "' + mv_par02 + '"'
cNomArq1 := CriaTrab(NIL,.F.)
IndRegua("QP6",cNomArq1,cKey,,cCond,STR0007)		//"Selecionando Registros..."
nIndex := RetIndex("QP6")

dbSetOrder(nIndex+1)
dbGoTop()

SetRegua(RecCount())
While !Eof() .And. QP6_FILIAL == xFilial("QP6")
	If lEnd
		@PROW()+1,001 PSAY STR0008	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	IncRegua()
	If Li > 60
		cabec(cTitulo,cabec1,cabec2,nomeprog,ctamanho,nMVCOMP)
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Posiciona em Registros de outros arquivos                    �
	//����������������������������������������������������������������
	If QQ3->(dbSeek(xFilial("QQ3")+QP6->QP6_FLUXO))
		@Li,00 PSAY AllTrim(QP6->QP6_PRODUT)+" "+QP6->QP6_DESCPO
		@Li,57 PSAY AllTrim(QQ3->QQ3_CODIGO)+" "+Subs(QQ3->QQ3_DESCRI,1,15)
		Li++		
	EndIf
	dbSkip()
EndDo

If Li != 80
	roda(CbCont,cbtxt)
EnDif
//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("QP6")
cNomArq1 += OrdBagExt()
RetIndex("QP6")
Set Filter To
Ferase(cNomArq1)

Set device to Screen

If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return .T.