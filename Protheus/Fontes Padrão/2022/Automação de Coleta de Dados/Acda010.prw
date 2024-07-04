#INCLUDE "Acda010.ch" 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDA010  � Autor � Nilton Pereira        � Data � 05/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Operadores                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA010
Local aButtons:={}

//���������������������������������������������������������������Ŀ
//� Ponto de entrada para inserir botoes na enchoicebar da Rotina �
//�����������������������������������������������������������������
If ExistBlock("ACD010BUT")
	aButtons := ExecBlock("ACD010BUT",.F.,.F.)
	If ValType(aButtons) # "A"
		aButtons := {}
	EndIf
EndIf
  
AxCadastro("CB1",STR0001, "ACDA010DEL()",,,,,,,,,aButtons) //"Cadastro de operadores"

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDA010DEL � Autor � Nilton Pereira       � Data � 05/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de validacao da exclusao do Operador                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1 -> Validacao OK                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � ACDA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA010DEL()
Local aAreaAnt := GetArea()
Local aAreaCBH := CBH->(GetArea())
Local aAreaSH6 := SH6->(GetArea())
Local aAreaCBB := CBB->(GetArea())

Local lRet     := .T.
Local cFilSH6  := xFilial("SH6")
Local cFilCBB  := xFilial("CBB")

Local cAliasTmp	:= ""
Local cQuery    := "" 

CBH->(DbSetOrder(4)) // CBH_FILIAL+CBH_OPERAD+CBH_DTINV+CBH_HRINV

If CBH->(MsSeek(xFilial("CBH")+CB1->CB1_CODOPE))
	lRet   := .F.
	cTexto := STR0005 // "Operador possui registros de Monitoramento de Producao na tabela CBH."
EndIf

If lRet

	cAliasTmp := GetNextAlias()

	cQuery 	:= "SELECT SH6.H6_OPERADO FROM "+ RetSqlName("SH6")+" SH6 "
	cQuery 	+= "WHERE SH6.H6_FILIAL	= '" + cFilSH6    + "' AND "
	cQuery 	+= "SH6.H6_OPERADO = '" + CB1->CB1_CODOPE + "' AND "
	cQuery 	+= "SH6.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	If !(cAliasTmp)->(Eof())
		lRet   := .F.
		cTexto := STR0006 // "Operador possui apontamentos de producao na tabela SH6."
	EndIf
	
	(cAliasTmp)->(DbCloseArea())

EndIf

If lRet

	cAliasTmp := GetNextAlias()

	cQuery 	:= "SELECT CBB.CBB_USU FROM "+ RetSqlName("CBB")+" CBB "
	cQuery 	+= "WHERE CBB.CBB_FILIAL	= '" + cFilCBB    + "' AND "
	cQuery 	+= "CBB.CBB_USU = '" + CB1->CB1_CODOPE + "' AND "
	cQuery 	+= "CBB.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	If !(cAliasTmp)->(Eof())
		lRet   := .F.
		cTexto :=  STR0010 //Operador possui inventario cadastrado na tabela CBB
	EndIf
	
	(cAliasTmp)->(DbCloseArea())

EndIf

If !lRet
	Aviso(STR0007,cTexto + STR0008,{STR0009}) //"Exclusao nao permitida" ## " Exclua primeiramente esses registros antes de excluir o operador!" ## "OK"
EndIf

RestArea(aAreaSH6)
RestArea(aAreaCBH)
RestArea(aAreaCBB)
RestArea(aAreaAnt)

Return lRet
