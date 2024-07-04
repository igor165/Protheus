#INCLUDE "Protheus.ch"
#INCLUDE "Msgraphi.ch"
#INCLUDE "GCTPgOn03.ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �GCTPgOn03 � Autor �Marcos V. Ferreira     � Data � 19/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao Tipo 5: Valor de contratos A Pagar/A Receber ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Array  = {bClick,aCabec,aValores)                            ���
���          � bClick = Bloco de codigo para execucao duplo-click no Browse ���
���          � aCabec = Array contendo o cabecalho             		        ���
���          � aValores = Array contendo os valores da lista                ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SIGAGCT                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/        
Function GCTPgOn03()

Local aRet     := {}
Local aCabec   := {}
Local aItens   := {}
Local cTipo    := ""
Local cStatus  := ""
Local cDescri  := ""
Local cAlias   := CriaTrab(Nil,.F.)
Local cPerg      := 'GCTPGON03'

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Contrato de                           �
//� mv_par02            // Contrato ate                          �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(cPerg)

//������������������������������������������������������������Ŀ
//�Converte os parametros do tipo range, para um range cheio,  �
//�caso o conteudo do parametro esteja vazio                   �
//��������������������������������������������������������������
FullRange(cPerg)

//������������������������������������������������������������������������Ŀ
//� Contratos a pagar e a receber                                          �
//��������������������������������������������������������������������������
BeginSql Alias cAlias

	SELECT SUM(CN9_SALDO) SALDO, CN9_SITUAC, CN1_ESPCTR
	
	FROM %table:CN9% CN9, %table:CN1% CN1
	
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND 
		  CN1.CN1_FILIAL = %xFilial:CN1% AND 
		  CN9.CN9_TPCTO = CN1.CN1_CODIGO AND
	      CN9_SITUAC IN ('01','05','06') AND 
		  CN9_NUMERO >= %Exp:mv_par01%	AND
		  CN9_NUMERO <= %Exp:mv_par02%	AND
   		  CN9.%NotDel% AND
   		  CN1.%NotDel%
   		
   GROUP BY CN9_SITUAC, CN1_ESPCTR

EndSql

//������������������������������������������������������������������������Ŀ
//�Preenche array do Painel de Gestao tipo 5 - Browse                      �
//��������������������������������������������������������������������������
aCabec := {STR0001,STR0002,STR0003,STR0004}  // ##"Tipo do Contrato"##"Status"##"Situacao"##"Saldo"

dbSelectArea(cAlias)

Do While !Eof()
	If (cAlias)->CN9_SITUAC == "01"
		cStatus := STR0005 //"Cancelado"
	ElseIf (cAlias)->CN9_SITUAC == "05"
		cStatus := STR0006 //"Vigente"
	ElseIf (cAlias)->CN9_SITUAC == "06"
		cStatus := STR0007 //"Paralisado"
	EndIf
	If (cAlias)->CN1_ESPCTR == "1"
		cTipo   := STR0008 //"Compras"
		cDescri := STR0009 //"A Pagar"
	ElseIf (cAlias)->CN1_ESPCTR == "2"
		cTipo   := STR0010 //"Vendas"   
		cDescri := STR0011 //"A Receber"
	EndIf
	
	// Adiciona itens no Painel de Gestao
	Aadd(aItens, {cTipo,cStatus,cDescri,TransForm((cAlias)->SALDO,"@E 999,999,999.99") } )

	dbskip()
EndDo

// Retorno para o objeto do Painel Tipo 5
aRet   := { /*{|x| bClick }*/ , aCabec , IIf(Empty(aItens),{{"","","",""}},aItens) }
(cAlias)->(DbCloseArea())

Return aRet
