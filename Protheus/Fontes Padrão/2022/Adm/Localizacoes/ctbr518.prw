#INCLUDE "ctbr518.ch"
#Include "Protheus.ch"


// 17/08/2009 -- Filial com mais de 2 caracteres
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR518      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Este relatorio imprime a declaracao de pagtos provisorios  ���
���          � do IMPAC                                                   ���
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

Function CTBR518()
Local  nomeprog:="CTBR518"
Local cPerg:= "CTR518"
Local ApERG:={}
Local aArea:={}
Local dDataFim:=dDatabase

Pergunte( CPERG, .T. )
AaDD(aPerg,MV_PAR01)
AaDD(aPerg,MV_PAR02)
AaDD(aPerg,MV_PAR03)
AaDD(aPerg,MV_PAR04)
AaDD(aPerg,MV_PAR05)
AaDD(aPerg,MV_PAR06)

cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DE CALCULO PROVISORIO  DE IMPAC"
cDesc:=	OemToAnsi(STR0002) +; //"Este programa ir� imprimir o Demonstrativo"
			 	OemToAnsi(STR0003) //"de Calculo de Pagamentos Provisorios do IMPAC"

aArea:=GetArea()
dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
RestArea(aArea)


aDescCab:={} 
Aadd(aDescCab,".          " + STR0004 ) //"CALCULO DE PAGAMENTOS PROVISORIOS DO IMPAC      ."
Aadd(aDescCab,	".          " + STR0005 + Alltrim(Str(year(dDataFim))) +" / "+ "FATOR DE ACTUALIZACION: " +Alltrim(STR(MV_PAR06))+ "       ." ) //"EXERCICIO "

                                    
CtbR511(.T.,aPerg,"CTBR518",cTitulo,cDesc,nomeprog,cPerg,aDescCab)  
Return()                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTR518V      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao da pergunta 06 ref. a taxa do periodo contabil ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CTR518V()
Local nTaxaCor:=0 
Local nTaxaAtu:=0
Local nTaxaAnt:=0
Local cMesAtu:= ""
Local cAnoAtu:= ""
Local cMesIn:= ""
Local cAnoIn:= ""
Local aArea:=Getarea() 
Local dDataFim:=dDataBase 


dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
dIni:=CTG->CTG_DTINI
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
If Month(dIni) ==1               
	cMesIn:= StrZero(12,2,0)
	cAnoIn:= Str(Year(dIni)-1,4,0) 
Else
	cMesIn:= StrZero(Month(dIni)-1,2,0)
	cAnoIn:= Str(Year(dIni),4,0) 
EndIf	
cMesAtu:= StrZero(Month(dDataFim),2,0) 
cAnoAtu:= Str(Year(dDataFim),4,0) 

DbSelectArea("SIE")   

If DbSeek( xFilial("SIE")+cAnoAtu +cMesAtu) 
	nTaxaAtu:=SIE->IE_INDICE
EndIf
If DbSeek( xFilial("SIE")+cAnoIn +cMesIn)
	nTaxaAnt:=SIE->IE_INDICE
EndIf
nTaxaCor:= NoRound(nTaxaAtu /  nTaxaAnt,4)

MV_PAR06:=nTaxaCor
      
RestArea(aArea)
