#include "FINR570.CH"
#Include "PROTHEUS.CH"
#DEFINE CRLF CHR(13)+CHR(10)

/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR570  � Autor � Daniel Tadashi Batori � Data � 31.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da rela��o de Caixinhas				                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR570(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Function FINR570()

If TRepInUse()
	MPReport("FINR570","SET",STR0007,STR0002+CRLF+STR0003+STR0004,{STR0008})
Else
	Return FINR570R3() // Executa vers�o anterior do fonte
Endif

Return






/*
---------------------------------------------------------- RELEASE 3 ---------------------------------------------
*/








/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR570R3� Autor � Leonardo Ruben        � Data � 04.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Emiss�o da rela��o de Caixinhas                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINR570R3(void)                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FINR570R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbCont,cabec1,cabec2,cabec3,wnrel
LOCAL tamanho:="M"
LOCAL limite :=132
LOCAL titulo:=OemToAnsi(STR0001)  //"Relacao de Caixinhas"
LOCAL cDesc1:=OemToAnsi(STR0002)  //"Emissao do Cadastro de Caixinhas"
LOCAL cDesc2:=OemToAnsi(STR0003)  //"Ira imprimir os dados dos caixinhas de acordo"
LOCAL cDesc3:=OemToAnsi(STR0004)  //"de acordo com a configuracao do usuario."

PRIVATE aReturn := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 2, 2, 1, "" ,1 }  //"Zebrado"###"Administracao"
PRIVATE aLinha:= { }
PRIVATE nomeprog:="FINR570",nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������

cbcont   := 0
cabec1   := OemToAnsi(STR0007)  // "RELACAO COMPLETA DO CADASTRO DE CAIXINHAS"
cabec2   := Replicate("-",limite)
cabec3   := " "
cString  := "SET"
aOrd     := {OemToAnsi(STR0008)}  //" Por Codigo         "
wnrel    := "FINR570"

Private AParDef := {}
wnrel:=SetPrint(cString,wnrel,"ParamDef(cAlias)",@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,Tamanho)

If nLastKey = 27
   DbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| R070Imp(@lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)},Titulo)

If aReturn[5] = 1
   Set Printer TO
   dbCommitAll()
   ourspool(wnrel)
Endif

MS_FLUSH()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R070IMP  � Autor � Leonardo Ruben        � Data � 04.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINR570                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R070Imp(lEnd,Cabec1,Cabec2,Cabec3,limite,tamanho,cbCont,wnrel)
LOCAL cbtxt    := SPACE(10)
li       :=80
m_pag    :=1

dbSelectArea("SET")
dbGoTop()
//��������������������������������������������������������������Ŀ
//� Monta Array para identificacao dos campos dos arquivos       �
//����������������������������������������������������������������
if Len(aReturn) > 8
	Mont_Dic(cString)
else
	Mont_Array(cString)
endif

ImpCadast(Cabec1,Cabec2,Cabec3,NomeProg,Tamanho,Limite,cString,@lEnd)

IF li != 80
	roda(cbcont,cbtxt,"M")
EndIF

dbSelectArea("SET")
DbClearFilter()
dbSetOrder(1)

Return
