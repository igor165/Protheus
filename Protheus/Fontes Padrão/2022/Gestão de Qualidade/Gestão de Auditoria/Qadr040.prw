#Include "QADR040.CH"
#Include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QADR040   �Autor  �Telso Carneiro      � Data �  16/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Emiss�o da Rela��o de Auditores                            ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QADR040()
LOCAL titulo  	:= OemToAnsi(STR0001)  //"Relacao de Auditores"                    
LOCAL cDesc1	:= OemToAnsi(STR0002)  //"Emissao do Cadastro de Auditores"
LOCAL cDesc2	:= OemToAnsi(STR0003)  //"Ira imprimir os dados dos auditores     "
LOCAL cDesc3	:= OemToAnsi(STR0004)  //"de acordo com a configuracao do usuario."
LOCAL nomeprog	:= "QADR040"
Local aOrd      := {OemToAnsi(STR0008),OemToAnsi(STR0009)}  //" Por Codigo "###" Alfabetica"

If TRepInUse()
	
	//��������������������������������������������������������������Ŀ
	//� Monta indice temporario com filtro                           �
	//����������������������������������������������������������������
	cIndice := CriaTrab("",.F.)
	
	DbSelectArea("QAA")
	cKey 	:= IndexKey()
	cFiltro := Qa_FilSitF() + " .and. QAA_AUDIT == '1'"
	
	IndRegua("QAA",cIndice,cKey,,cFiltro,"")
	
	DbSelectArea("QAA")
	DbGoTop()
	
	MPReport(nomeprog,"QAA",titulo,cDesc1+cDesc2+cDesc3,aOrd)
Else
	Return QADR040R3()	// Executa vers�o anterior do fonte
Endif                


DbSelectArea("QAA")
RetIndex("QAA")
DbClearFilter()
DbSetOrder(1)

fErase(cIndice+OrdBagExt())

Return               

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR040R3� Autor � Robson Ramiro A. Olive� Data � 11.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da Rela��o de Auditores                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADR040(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Robson Ramiro �15/05/02� Meta �Alteracao do alias da familia QU para QA���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QADR040R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbCont,cabec1,cabec2,cabec3,wnrel
LOCAL tamanho := "M"
LOCAL limite  := 132
LOCAL titulo  := OemToAnsi(STR0001)  //"Relacao de Auditores"
LOCAL cDesc1  := OemToAnsi(STR0002)  //"Emissao do Cadastro de Auditores"
LOCAL cDesc2  := OemToAnsi(STR0003)  //"Ira imprimir os dados dos auditores     "
LOCAL cDesc3  := OemToAnsi(STR0004)  //"de acordo com a configuracao do usuario."
LOCAL aOrd    := {}

PRIVATE aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha   := { }
PRIVATE nomeprog := "QADR040", nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������

cbcont   := 0
cabec1   := OemToAnsi(STR0007)  //"RELACAO COMPLETA DO CADASTRO DE AUDITORES"
cabec2   := Replicate("-",limite)
cabec3   := " "
cString  := "QAA"

aOrd     := {OemToAnsi(STR0008),OemToAnsi(STR0009)}  //" Por Codigo "###" Alfabetica"

wnrel    := "QADR040"

Private AParDef := {}

wnrel := SetPrint(cString,wnrel,"ParamDef(cAlias)",@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,tamanho)

If nLastKey = 27
    Set Filter To
    Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
    Return
Endif

RptStatus({|lEnd| R040Imp(@lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)},Titulo)

Return
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R040IMP  � Autor � Robson Ramiro A. Olive� Data � 11.04.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function R040Imp(lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)

Local cKey, cFiltro, cIndice

li    := 80
m_pag := 1
cbtxt := SPACE(10)

//��������������������������������������������������������������Ŀ
//� Monta indice temporario com filtro                           �
//����������������������������������������������������������������

cIndice := CriaTrab("",.F.)

DbSelectArea("QAA")
cKey 	:= IndexKey()
cFiltro := Qa_FilSitF() + " .and. QAA_AUDIT == '1'"

IndRegua("QAA",cIndice,cKey,,cFiltro,"")

DbSelectArea("QAA")
DbGoTop()

//��������������������������������������������������������������Ŀ
//� Monta Array para identificacao dos campos dos arquivos       �
//����������������������������������������������������������������

If Len(aReturn) > 8
	Mont_Dic(cString)
Else
	Mont_Array(cString)
Endif

ImpCadast(Cabec1,Cabec2,Cabec3,NomeProg,Tamanho,Limite,cString,@lEnd)

If li != 80
	Roda(cbcont,cbtxt,"M")
Endif

DbSelectArea("QAA")
RetIndex("QAA")
Set Filter To
DbSetOrder(1)

fErase(cIndice+OrdBagExt())

If aReturn[5] = 1
	Set Printer To 
	DbCommitAll()
	OurSpool(wnrel)
Endif

Ms_Flush()

Return Nil