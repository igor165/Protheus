#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSP020.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSP020   � Autor � Henry Fila            � Data � 27/04/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 2 Padrao 1: Quantidade ���
���          �de usuarios incluidos e excluidos no periodo                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �PLSP020()                                                     ���
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


Function PLSP020()

Local aArea       := GetArea()
Local aAreaBD5    := BD5->(GetArea())
Local cAliasBD5   := "BD5"
Local aRet        := {} 
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,2)
Local dDataIni    := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim    := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nGuiaCon	  := 0
Local nGuiaSer	  := 0
Local nGuiaInt    := 0
Local nGuiaConMes := 0
Local nGuiaSerMes := 0
Local nGuiaIntMes := 0




//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              D I A R I O                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de consultas no dia                                                �
//��������������������������������������������������������������������������
cAliasBD5 := GetNextAlias()
BeginSql Alias cAliasBD5
SELECT count(*) NGUIACON
	FROM %Table:BD5% BD5 
	WHERE BD5_FILIAL = %xFilial:BD5% AND BD5_TIPGUI = %Exp:"01"% AND BD5_DTDIGI = %Exp:Dtos(dDataBase)% AND BD5.%NotDel% 
EndSql
nGuiaCon := (cAliasBD5)->NGUIACON
(cAliasBD5)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�Numero de Servicos no dia                                               �
//��������������������������������������������������������������������������
cAliasBD5 := GetNextAlias()
BeginSql Alias cAliasBD5
SELECT count(*) NGUIACON
	FROM %Table:BD5% BD5 
	WHERE BD5_FILIAL = %xFilial:BD5% AND BD5_TIPGUI = %Exp:"02"% AND BD5_DTDIGI = %Exp:Dtos(dDataBase)% AND BD5.%NotDel% 
EndSql
nGuiaSer := (cAliasBD5)->NGUIACON
(cAliasBD5)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�Numero de Internacoes no dia                                            �
//��������������������������������������������������������������������������
cAliasBE4 := GetNextAlias()
BeginSql Alias cAliasBE4
SELECT count(*) NGUIACON
	FROM %Table:BE4% BE4 
	WHERE BE4_FILIAL = %xFilial:BE4% AND BE4_DATPRO = %Exp:Dtos(dDataBase)% AND BE4.%NotDel% 
EndSql
nGuiaInt := (cAliasBE4)->NGUIACON
(cAliasBE4)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              M E N S A L                               �
//�                                                                        �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Numero de consultas no mes                                                �
//��������������������������������������������������������������������������
cAliasBD5 := GetNextAlias()
BeginSql Alias cAliasBD5
SELECT count(*) NGUIACON
	FROM %Table:BD5% BD5 
	WHERE BD5_FILIAL = %xFilial:BD5% AND BD5_TIPGUI = %Exp:"01"% AND BD5_DTDIGI >= %Exp:Dtos(dDataIni)% AND BD5_DTDIGI <= %Exp:Dtos(dDataFim)% AND BD5.%NotDel% 
EndSql
nGuiaConMes := (cAliasBD5)->NGUIACON
(cAliasBD5)->(DbCloseArea())


//������������������������������������������������������������������������Ŀ
//�Numero de servicos no mes                                                �
//��������������������������������������������������������������������������
cAliasBD5 := GetNextAlias()
BeginSql Alias cAliasBD5
SELECT count(*) NGUIACON
	FROM %Table:BD5% BD5 
	WHERE BD5_FILIAL = %xFilial:BD5% AND BD5_TIPGUI = %Exp:"02"% AND BD5_DTDIGI >= %Exp:Dtos(dDataIni)% AND BD5_DTDIGI <= %Exp:Dtos(dDataFim)% AND BD5.%NotDel% 
EndSql
nGuiaSerMes := (cAliasBD5)->NGUIACON
(cAliasBD5)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�Numero de Internacoes no mes                                            �
//��������������������������������������������������������������������������
cAliasBE4 := GetNextAlias()
BeginSql Alias cAliasBE4
SELECT count(*) NGUIACON
	FROM %Table:BE4% BE4 
	WHERE BE4_FILIAL = %xFilial:BE4% AND BE4_DATPRO >= %Exp:Dtos(dDataIni)% AND BE4_DATPRO <= %Exp:Dtos(dDataFim)% AND BE4.%NotDel% 
EndSql
nGuiaIntMes := (cAliasBE4)->NGUIACON
(cAliasBE4)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
Aadd( aRet, { STR0001, { ;																	 
			{ STR0003, Transform(nGuiaCon  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nGuiaSer  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;
			{ STR0005, Transform(nGuiaInt  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 


Aadd( aRet, { STR0002, { ;																	 
			{ STR0003, Transform(nGuiaConMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nGuiaSerMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;
			{ STR0005, Transform(nGuiaIntMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 
                
//������������������������������������������������������������������������Ŀ
//�Restaura areas                                                          �
//��������������������������������������������������������������������������
RestArea(aAreaBD5)
RestArea(aArea)


Return aRet
                   