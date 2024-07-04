#INCLUDE "ctbr516.ch"
#Include "Protheus.ch"

// 17/08/2009 -- Filial com mais de 2 caracteres
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR518      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Este relatorio imprime a declaracao de "DEMONSTRATIVO DO   ���
���          � COEFICIENTE DE UTILIDADE"                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�26/06/15�PCREQ-4256�Se elimina la funcion fCriaSx1() la   ���
���            �        �          �cual realiza modificacion a SX1 por   ���
���            �        �          �motivo de adecuacion a fuentes a nueva���
���            �        �          �estructura de SX para Version 12.     ���
���Jonathan Glz�09/10/15�PCREQ-4261�Merge v12.1.8                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR516()

Local  nomeprog:="CTBR516"
Local cPerg:= "CTR516"
Local ApERG:={}
Local aArea:={}
Local dDataFim:=dDatabase

Pergunte( CPERG, .T. )
AaDD(aPerg,MV_PAR01)
AaDD(aPerg,MV_PAR02)
AaDD(aPerg,MV_PAR03)
AaDD(aPerg,MV_PAR04)
AaDD(aPerg,MV_PAR05)
AaDD(aPerg,1)
cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DO COEFICIENTE DE UTILIDADE"
cDesc:=	OemToAnsi(STR0002) +; //"Este programa ir� imprimir o Demonstrativo"
			 	OemToAnsi(STR0003) //"do Coficiente de Utilidade"
             
aDescCab:={}
aArea:=GetArea()
dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
RestArea(aArea)

Aadd(aDescCab,".          " + STR0004+ Alltrim(Str(year(dDataFim))) + "       ." ) //"COEFICIENTE DE UTILIDADE PARA "
Aadd(aDescCab,	".               ." )


CtbR511(.T.,aPerg,"CTBR516",cTitulo,cDesc,nomeprog,cPerg,aDescCab)  
Return()                         
