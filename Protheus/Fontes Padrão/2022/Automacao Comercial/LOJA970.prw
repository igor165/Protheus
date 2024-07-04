#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA970.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA970   � Autor � Thiago Honorato    � Data �  08/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro dos botoes de pagamentos (Forma / Condicao)       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - Interface Touch screen                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LOJA970
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Private cString := "SLD"

dbSelectArea("SLD")
dbSetOrder(1)

AxCadastro(cString,STR0001,,"LOJ970Valid()")//"Cadastro de  bot�es de pagamento (Forma / Condi��o)"

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �LOJ970Valid� Autor � Thiago Honorato    � Data �  08/10/06   ���
��������������������������������������������������������������������������͹��
���Descricao � Validacao da inclusao e/ou alteracao do cadastro dos botoes ���
���          � de pagamento                                                ���
���          � So' sera' valido o preenchimento do campo forma de pagamento���
���          � ou condica de pagamento, nunca os dois simultaneamente.     ���
��������������������������������������������������������������������������͹��
���Uso       � SIGALOJA - Interface Touch screen                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function LOJ970Valid()
Local lRet 		:= .T.	// Retorno da funcao
Local nCount	:= 0	// Controla loop
Local nMais		:= 0	// Controla o quantidade de caracter '+'	

If INCLUI .OR. ALTERA
	DbSelectArea("SLD")
	DbSetOrder(1)
	If ((!Empty(M->LD_FORMA) .AND. !Empty(M->LD_COND)) .OR. (Empty(M->LD_FORMA) .AND. Empty(M->LD_COND)))
		MsgStop(STR0002) //"Deve-se optar pelo preenchimento da forma de pagamento ou condi��o de pagamento"
		lRet := .F.
	Endif
EndIf
// Verifica o preenchimento do campo Texto Botao
If !Empty(M->LD_TEXTO)
	// Verifica se o ultimo caracter eh o caracter '+'
	If SubStr(M->LD_TEXTO,Len(AllTrim(M->LD_TEXTO)),1) == '+'
		MsgStop( STR0003 + CHR(10) + ;		//"O final do texto n�o pode conter quebra de linha."  
				 STR0004 )					//"Verifique o conte�do da coluna Texto bot�o!"
		lRet := .F.
	Else	
		// verifica se o caracter '+' aparece mais de duas vezes dentro de uma string.
		For nCount := 1 to Len(M->LD_TEXTO)
			If SubStr(M->LD_TEXTO,nCount,1) == '+'
				nMais ++					
			Endif
            If nMais > 2
				MsgStop( STR0005 + CHR(10) + ;		//"Quantidade de quebra de linhas inv�lido(m�ximo 3 linhas)." 
						 STR0004 )					//"Verifique o conte�do da coluna Texto bot�o!"
				lRet := .F.			
				Exit
            Endif
		Next nCount
	Endif
Endif

Return lRet