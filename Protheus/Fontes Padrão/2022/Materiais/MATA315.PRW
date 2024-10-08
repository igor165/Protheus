#INCLUDE "MATA315.ch"
#include "PROTHEUS.ch"

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MATA315  � Autor � Daniel Leme           � Data � 12.01.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Itens de Precifica��o                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA315()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Function MATA315()

AxCadastro("SAV",OemToAnsi(STR0001),'MATA315Vdel()',"MATA315TOK()",/*aRotAdic*/,/*bPre*/,/*bOK*/,{|| MATA315Grv(IIf(INCLUI,3,IIF(ALTERA,4,5))) }) //"Itens de Precifica��o"

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MATA315VDel� Autor � Daniel Leme          � Data � 12.01.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA315VDel()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Function MATA315VDel()
Local lRet 	:= .T.
Local cQuery	:= ""
Local cAlias	:= "TMPSAW"

cQuery:= " SELECT * FROM "+RetSqlName('SAW')+" SAW "
cQuery+= " WHERE AW_FILIAL = '"+xFilial('SAW') +"' "
cQuery+= " AND AW_CODPRC = '"+SAV->AV_CODPRC+"'" 
cQuery+= " AND SAW.D_E_L_E_T_ =' ' "

cQuery:= ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

If !(cAlias)->(EOF())
	lRet := .F.
EndIf

If ! lRet
	Help( " ", 1, STR0013,, STR0014, 1, 0 )//"ATEN��O" ## "Este item esta relacionado ao cadastro de Categoria X Itens Prec"
EndIf

(cAlias)->(dbCloseArea())
/*
// Exemplo para PE 
If lRet
	If ExistBlock( "MATA315Del" )
		lRet := ExecBlock( "MATA315Del", .F., .F. )
		If ValType(lRet) != "L"
			lRet := .F.
		EndIf
	EndIf
EndIf
*/
Return(lRet)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MATA315TOK  � Autor � Daniel Leme           � Data � 12.01.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao Geral                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA315TOK()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Function MATA315TOK()
Local lRet := .T.

If lRet .And. INCLUI .And. M->AV_TIPO == "3" //-- F�rmula
	lRet := !Empty(M->AV_FORMUL)
EndIf

/*
// Exemplo para PE 
If lRet
	If ExistBlock( "MATA315TOK" )
		lRet := ExecBlock( "MATA315TOK", .F., .F. )
	EndIf
	If ValType(lRet) != "L"
		lRet := .F.
	EndIf
EndIf
*/
Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MATA315Grv  � Autor � Daniel Leme           � Data � 12.01.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Complemento da Grava��o do cadastro                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA315Grv()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function MATA315Grv(nOpc)
Local aArea	:= GetArea()
Local lRet	:= .T.

/*
//-- Exemplo de Ponto de Entrada apos a gravacao dos dados
If ExistBlock("MATA315GRV")
	ExecBlock("MATA315GRV",.F.,.F.,{nOpc})
EndIf
*/
RestArea(aArea)

Return lRet



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MATA315Cmb� Autor � Daniel Leme           � Data � 12.01.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Complemento da Grava��o do cadastro                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATA315Cmb()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Caracter                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Function MATA315Cmb( lRetArray, lIntPv )
Local cRet := ""
Local aVet := {}

Default lRetArray := .F.
Default lIntPv		:= .F.

If lRetArray .And. lIntPv
	aAdd(aVet,"C5_FRETE")
	aAdd(aVet,"C5_FRETEAUT")
	aAdd(aVet,"C5_SEGURO")
	aAdd(aVet,"C5_DESPESA")
	aAdd(aVet,"C6_COMIS1")
	aAdd(aVet,"C6_COMIS2")
	aAdd(aVet,"C6_COMIS3")
	aAdd(aVet,"C6_COMIS4")
	aAdd(aVet,"C6_COMIS5")
Else
	aAdd(aVet,STR0002) //"0=N�o Utiliza"
	aAdd(aVet,STR0003) //"1=Frete"
	aAdd(aVet,STR0004) //"2=Frete Auton."
	aAdd(aVet,STR0005) //"3=Seguro"
	aAdd(aVet,STR0006) //"4=Despesa"
	aAdd(aVet,STR0007) //"5=Comiss�o 1"
	aAdd(aVet,STR0008) //"6=Comiss�o 2"
	aAdd(aVet,STR0009) //"7=Comiss�o 3"
	aAdd(aVet,STR0010) //"8=Comiss�o 4"
	aAdd(aVet,STR0011) //"9=Comiss�o 5"
EndIf

If !lRetArray
	aEval( aVet, {|x| cRet += x + ";" } )
	cRet := Left( cRet, Len( cRet )-1 )
EndIf

Return Iif( lRetArray, aVet, cRet )