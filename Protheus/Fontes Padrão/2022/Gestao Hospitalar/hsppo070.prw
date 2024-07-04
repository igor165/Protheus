#INCLUDE "PROTHEUS.CH"
#include "msgraphi.ch"
#INCLUDE "TOPCONN.CH" 

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �HSPPO070  � Autor � Rogerio Tabosa        � Data � 17/04/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 2 Padrao 3: Top 5      ���
���          �de guias glosadas  no Lote                                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �HSPPO070()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {{cCombo1,{cText1,cValor,nColorValor,cClick},..},..} ���
���          � cCombo1     = Detalhes                                       ���
���          � cText1      = Texto da Coluna                         		���
���          � cValor      = Valor a ser exibido (string)                   ���
���          � nColorValor = Cor do Valor no formato RGB (opcional)         ���
���          � cClick      = Funcao executada no click do valor (opcional)  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDI                                                      ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/


Function HSPPO070()

Local aArea		:= GetArea()
Local cAliasRC1	:= "GE0"
//Local cCodLocI	:= "  "
//Local cCodLocF	:= "ZZ"
//Local aRet		:= {} 
Local cMes		:= StrZero(Month(dDataBase),2)
Local cAno		:= Substr(DTOC(dDataBase),7,2)
Local dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Local dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
//Local dDataIniA	:= CTOD("01/01/"+cAno)
//Local dDataFimA := CTOD("31/12/"+cAno)
Local nAteAmbM	:= 0 //Tipo 1
Local nAteAmbD	:= 0

Local nAteIntM	:= 0 //Tipo 0
Local nAteIntD	:= 0
Local nAtePAM	:= 0 //Tipo 2
Local nAtePAD	:= 0
Local nAteAmb	:= 0 
Local nAtePA	:= 0
Local nAteInt	:= 0
Local aEixoX    := {}
Local aValores  := {}  
Local aRetPanel := {}
Local cCodCon	:= ""   
Local aConvTot	:= {}
Local nSomaTot	:= 0
Local i			:= 0
Local cSqlTmp 	:= ""

//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              D I A R I O                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de Atendimentos cancelados por mes                               �
//��������������������������������������������������������������������������
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT SUM(GE0_VLGLOI) TOTGLOSA , GE0_CODCON, GA9_NREDUZ
 FROM %table:GE0% GE0
 	JOIN %table:GA9% GA9 
 	ON GA9_CODCON=GE0_CODCON AND GA9.GA9_FILIAL = %xFilial:GA9% AND GA9.%NotDel%
	WHERE GE0.GE0_FILIAL = %xFilial:GE0% AND GE0.%NotDel%                          
	AND GE0.GE0_DATREC BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDataFim)%
	GROUP BY GE0_CODCON, GA9_NREDUZ
EndSql

While !(cAliasRC1)->(EOF())  
	Aadd(aConvTot, {(cAliasRC1)->GE0_CODCON + "-" + (cAliasRC1)->GA9_NREDUZ , (cAliasRC1)->TOTGLOSA})
	(cAliasRC1)->(DbSkip())
End 
(cAliasRC1)->(DbCloseArea())

 
If Len(aConvTot) > 0 
	aSort(aConvTot,,,{|x,y| x[2] > y[2]})
EndIf 
 
For i := 1 to IIf(Len(aConvTot) > 5,5, Len(aConvTot))
	Aadd( aEixoX, aConvTot[i,1] )	
	Aadd( aValores, Round(aConvTot[i,2],2))
Next i  

aRetPanel := 	{GRP_BAR,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aArea)

Return aRetPanel  