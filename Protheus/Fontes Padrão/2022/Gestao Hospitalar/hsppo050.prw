#INCLUDE "PROTHEUS.CH"
#include "msgraphi.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �HSPPO050  � Autor � Rogerio Tabosa        � Data � 16/04/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 2 Padrao 3: Quantidade ���
���          �de Atendimentos realizados no dia (DataBase)                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �HSPPO050()                                                    ���
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


Function HSPPO050()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local cAliasRC1	:= "GCY"
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
//Local aTabela	:= {}  

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
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE = %Exp:DTOS(dDataBase)% 
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntD := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbD := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAD := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())


//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              M E N S A L                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de Atendimentos cancelados por mes                               �
//��������������������������������������������������������������������������
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDataFim)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAM := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())

//aTabela := {  { "Dia",{ "Pronto Atendimento" , "Ambulatorio", "Interna��o" }  , {   {STR(nAtePAD),STR(nAteAmbD),STR(nAteIntD) }}  }  , { "Mes", { "Pronto Atendimento" , "Ambulatorio", "Interna��o"  } , {   {STR(nAtePAM),STR(nAteAmbM),STR(nAteIntM) } }  },{ "Ano",{  "Pronto Atendimento" , "Ambulatorio", "Interna��o" }  , {   {STR(nAtePAA),STR(nAteAmbA),STR(nAteIntA) }  }  } }
//aRetPanel := {  GRP_PIE, { "", {|| ONCLICKG}, {"Pronto Atendimento" , "Ambulatorio","Interna��o"} , {nAtePA,nAteAmb,nAteInt}  } , { "Atendimentos", {|| ONCLICKT},  aTabela  }     } 

Aadd( aEixoX, "Pronto Atendimento" )
Aadd( aEixoX, "Ambulatorio" )
Aadd( aEixoX, "Interna��o" )
Aadd( aValores, nAtePAD)
Aadd( aValores, nAteAmbD)
Aadd( aValores, nAteIntD)
        
aRetPanel := 	{GRP_PIE,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aAreaGCY)
RestArea(aArea)

Return aRetPanel  


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �HSPPO051  � Autor � Rogerio Tabosa        � Data � 16/04/2009 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 2 Padrao 3: Quantidade ���
���          �de Atendimentos realizados no mes corrente                    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �HSPPO051()                                                    ���
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

Function HSPPO051()

Local aArea		:= GetArea()
Local aAreaGCY	:= GCY->(GetArea())
Local cAliasRC1	:= "GCY"
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
Local nAteIntM	:= 0 //Tipo 0
Local nAtePAM	:= 0 //Tipo 2
Local aEixoX    := {}
Local aValores  := {}  
Local aRetPanel := {}  
//Local aTabela	:= {}  

//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              M E N S A L                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de Atendimentos cancelados por mes                               �
//��������������������������������������������������������������������������
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIni)% AND %Exp:DTOS(dDataFim)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteIntM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmbM := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePAM := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())


/*������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              A N U A L                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de Atendimentos cancelados por mes                               �
//��������������������������������������������������������������������������
cAliasRC1 := GetNextAlias()

BeginSql alias cAliasRC1
 SELECT Count(GCY.GCY_ATENDI) QTD, GCY.GCY_ATENDI TIPO
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
 AND GCY.GCY_DATATE BETWEEN %Exp:DTOS(dDataIniA)% AND %Exp:DTOS(dDataFimA)%
 GROUP BY GCY.GCY_ATENDI
EndSql
 
While !(cAliasRC1)->(EOF())
	If (cAliasRC1)->TIPO == "0"
		nAteInt := nAteIntA := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "1"
		nAteAmb := nAteAmbA := (cAliasRC1)->QTD
	ElseIf (cAliasRC1)->TIPO == "2"
		nAtePA := nAtePAA := (cAliasRC1)->QTD
	EndIf
	(cAliasRC1)->(DbSkip())
End
(cAliasRC1)->(DbCloseArea())
   */ 


//aRetPanel := {  GRP_PIE, { "", {|| ONCLICKG}, {"Pronto Atendimento" , "Ambulatorio","Interna��o"} , {nAtePA,nAteAmb,nAteInt}  } , { "Atendimentos", {|| ONCLICKT},  aTabela  }     } 

Aadd( aEixoX, "Pronto Atendimento" )
Aadd( aEixoX, "Ambulatorio" )
Aadd( aEixoX, "Interna��o" )
Aadd( aValores, nAtePAM)
Aadd( aValores, nAteAmbM)
Aadd( aValores, nAteIntM)
        
aRetPanel := 	{GRP_PIE,;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}
        
RestArea(aAreaGCY)
RestArea(aArea)

Return aRetPanel
                   