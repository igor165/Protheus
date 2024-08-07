#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSP010.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PLSP010   � Autor � Henry Fila            � Data � 27/04/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array para Painel de Gestao Tipo 2 Padrao 1: Quantidade ���
���          �de usuarios incluidos e excluidos no periodo                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �PLSP010()                                                     ���
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


Function PLSP010()

Local aArea       := GetArea()
Local aAreaBA1    := BA1->(GetArea())
Local cAliasBA1   := "BA1"
Local aRet        := {} 
Local cMes        := StrZero(Month(dDataBase),2)
Local cAno        := Substr(DTOC(dDataBase),7,2)
Local dDataIni    := CTOD("01/"+cMes+"/"+cAno)
Local dDataFim    := CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Local nUsrBlo	  := 0
Local nUsrInc	  := 0
Local nUsrBloMes  := 0
Local nUsrIncMes  := 0

//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              D I A R I O                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de pedidos no dia                                                �
//��������������������������������������������������������������������������
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT count(*) NUSRBLO
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATBLO = %Exp:Dtos(dDataBase)% AND BA1.%NotDel% 
EndSql
nUsrBlo := (cAliasBA1)->NUSRBLO
(cAliasBA1)->(DbCloseArea())


//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              D I A R I O                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de pedidos no dia                                                �
//��������������������������������������������������������������������������
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT count(*) NUSRINC
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATINC = %Exp:Dtos(dDataBase)% AND BA1.%NotDel% 
EndSql
nUsrInc := (cAliasBA1)->NUSRINC
(cAliasBA1)->(DbCloseArea())


//������������������������������������������������������������������������Ŀ
//�                                                                        �
//�                              M E N S A L                               �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Numero de usuarios bloqueados no mes                                    �
//��������������������������������������������������������������������������
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT Count(*) NUSRBLOMES 
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATBLO >= %Exp:Dtos(dDataIni)% AND BA1_DATBLO <= %Exp:Dtos(dDataFim)% AND BA1.%NotDel% 
EndSql
nUsrBloMes := (cAliasBA1)->NUSRBLOMES
(cAliasBA1)->(DbCloseArea())


//������������������������������������������������������������������������Ŀ
//�Numero de usuarios incluidos no mes                                     �
//��������������������������������������������������������������������������
cAliasBA1 := GetNextAlias()
BeginSql Alias cAliasBA1
SELECT Count(*) NUSRINCMES
	FROM %Table:BA1% BA1 
	WHERE BA1_FILIAL = %xFilial:BA1% AND BA1_DATINC >= %Exp:Dtos(dDataIni)% AND BA1_DATINC <= %Exp:Dtos(dDataFim)% AND BA1.%NotDel% 
EndSql
nUsrIncMes := (cAliasBA1)->NUSRINCMES
(cAliasBA1)->(DbCloseArea())
	

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao                                      �
//��������������������������������������������������������������������������
Aadd( aRet, { STR0001, { ;																	 
			{ STR0003, Transform(nUsrBlo  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nUsrInc  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 


Aadd( aRet, { STR0002, { ;																	 
			{ STR0003, Transform(nUsrBloMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } },;	 
			{ STR0004, Transform(nUsrIncMes  ,"@R 999,999,999.99"),CLR_BLUE,{ || } } } } ) 


                
//������������������������������������������������������������������������Ŀ
//�Restaura areas                                                          �
//��������������������������������������������������������������������������
RestArea(aAreaBA1)
RestArea(aArea)


Return aRet
                   