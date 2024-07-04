#INCLUDE "ctbr513.ch"
#Include "Protheus.ch"

// 17/08/2009 -- Filial com mais de 2 caracteres
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR513      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Este relatorio imprime a declaracao de imprimir			  ���
���          �  o Demonstrativo de saldo do CUFIN						  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�26/06/15�PCREQ-4256�Se elimina la funcion CTR513SX1() la  ���
���            �        �          �cual realiza modificacion a SX1 por   ���
���            �        �          �motivo de adecuacion a fuentes a nueva���
���            �        �          �estructura de SX para Version 12.     ���
���Jonathan Glz�09/10/15�PCREQ-4261�Merge v12.1.8                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBR513()
Local  nomeprog:="CTBR513"
Local cPerg:= "CTR513"
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

aArea:=GetArea()
dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
RestArea(aArea)


cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DO SALDO DO CUFIN"
cDesc:=	OemToAnsi(STR0002) +; //"Este programa ir� imprimir o Demonstrativo"
			 	OemToAnsi(STR0003) //"de saldo do CUFIN"

aDescCab:={} 
Aadd(aDescCab,".          " + STR0004 +"  " + Alltrim(Str(year(dDataFim))) + "       ." ) //"SALDO CUFIN"
Aadd(aDescCab,".          " +"TASA DE ACTUALIZACION "+ Alltrim(Str(MV_PAR06)) + "       ." ) //"TASA DE ACTUALIZACION " 
CtbR511(.T.,aPerg,"CTBR513",cTitulo,cDesc,nomeprog,cPerg,aDescCab)  
Return()                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTR513V      �Autor �  Paulo Augusto       �Data� 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para atualizar a pergunta 6 da variacao             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function CTR513V()
Local nTaxaCor:=0 
Local nTaxaAtu:=0
Local nTaxaAnt:=0
Local cMesAtu:= ""
Local cAnoAtu:= ""
Local cMesIn:= ""
Local cAnoIn:= ""
Local aArea:=Getarea()
Local dDataFim:=dDatabase

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
nTaxaCor:=Noround(nTaxaAtu/nTaxaAnt,4)
MV_PAR06:=nTaxaCor
      
RestArea(aArea)

Return
