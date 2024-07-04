#INCLUDE "GCTPgOn01.ch"
#INCLUDE "protheus.ch"
#INCLUDE "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GCTPgOn01� Autor � Marcos V. Ferreira    � Data � 14/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo 2           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GCTPgOn01()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �{{cCombo1,{cText1, cValor, nColorValor, bClick},{...},},    ���
���          �{cCombo2, {cText2, cValor, nColorValor, bClick},...}}       ���
���          �                                                            ���
���          �cCombo1 = Item da Selecao                                   ���
���          �cText1 = Texto da Coluna                                    ���
���          �cValor = Valor a ser exibido (string) ja com a picture aplic���
���          �nColorValor = Cor do Valor no Formato RGB (Opcional)        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAGCT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  GCTPgOn01()

Local aRet       := {}
Local cAtivos    := GetNextAlias()	
Local cInativos  := GetNextAlias()	
Local cEncerrado := GetNextAlias()	
Local cTexto01   := STR0001 //"Ativos"
Local cTexto02   := STR0002 //"Inativos"
Local cTexto03   := STR0003 //"Encerrados"
Local cPerg      := 'GCTPGON01'

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
//�ATIVOS                                                                  �
//��������������������������������������������������������������������������
BeginSql Alias cAtivos

	SELECT COUNT(*) ATIVOS
	
	FROM %table:CN9% CN9
	
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND 
		  CN9_SITUAC = '05' AND
		  CN9_NUMERO >= %Exp:mv_par01%	AND
		  CN9_NUMERO <= %Exp:mv_par02%	AND
   		  CN9.%NotDel%

EndSql

// Preenche array do Painel de Gestao tipo 2 - Padrao 1
Aadd( aRet, { cTexto01 , { 	{STR0004, AllTrim(StrZero((cAtivos)->ATIVOS,8)),CLR_BLUE	, /*{ || bClick }*/ } } }  )
(cAtivos)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�INATIVOS												                   �
//��������������������������������������������������������������������������

BeginSql Alias cInativos

	SELECT COUNT(*) INATIVOS
	
	FROM %table:CN9% CN9
	
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND 
		  CN9_SITUAC IN ('02','03','04','06','07') AND
		  CN9_NUMERO >= %Exp:mv_par01%	AND
		  CN9_NUMERO <= %Exp:mv_par02%	AND
   		  CN9.%NotDel%

EndSql

// Preenche array do Painel de Gestao tipo 2 - Padrao 1
Aadd( aRet, { cTexto02 , { 	{STR0004, AllTrim(StrZero((cInativos)->INATIVOS,8)),CLR_BLUE	, /*{ || bClick }*/ } } }  )
(cInativos)->(DbCloseArea())

//������������������������������������������������������������������������Ŀ
//�ENCERRADOS                                                              �
//��������������������������������������������������������������������������
BeginSql Alias cEncerrado

	SELECT COUNT(*) ENCERRADOS
	
	FROM %table:CN9% CN9
	
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND 
		  CN9_SITUAC = '08' AND
		  CN9_NUMERO >= %Exp:mv_par01%	AND
		  CN9_NUMERO <= %Exp:mv_par02%	AND
   		  CN9.%NotDel%

EndSql

// Preenche array do Painel de Gestao tipo 2 - Padrao 1
Aadd( aRet, { cTexto03 , { 	{STR0004, AllTrim(StrZero((cEncerrado)->ENCERRADOS,8)),CLR_BLUE	, /*{ || bClick }*/ } } }  )
(cEncerrado)->(DbCloseArea())

Return aRet
