#INCLUDE "pmsa430.ch"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA430  � Autor � Edson Maricate        � Data � 10/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de manutencao das consultas gerenciais a projetos.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PMSA430()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSA430()

If AMIIn(44) .And. !PMSBLKINT()
	axCadastro("AJ8",STR0001) //"Consulta Gerencial de Projetos"
EndIf

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Pma430Vld� Autor �Edson Maricate          � Data � 11/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao do codigo da tarefa digitada.                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA430                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pma430Vld(cAlias)
Local lRet 		:= .F.
Local aArea		:= GetArea()
Local aAreaAF8	:= AF8->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAFC	:= AFC->(GetArea())

AF8->(dbSetOrder(1))
If AF8->(dbSeek(xFilial()+M->AJ8_PROJPM))
	Do Case
		Case (cAlias == "AF9")
			AF9->(dbSetOrder(1))
			If AF9->(dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+M->AJ8_TASKPM))
				lRet := .T.
			EndIf

		Case (cAlias == "AFC")
			AFC->(dbSetOrder(1))
			If AFC->(dbSeek(xFilial()+AF8->AF8_PROJET+AF8->AF8_REVISA+M->AJ8_EDTPMS))
				lRet := .T.
			EndIf
	EndCase
	
	If !lRet
		HELP("   ",1,"REGNOIS")
	EndIf
Else
	HELP("   ",1,"REGNOIS")
EndIf	

RestArea(aAreaAF8)
RestArea(aAreaAF9)
RestArea(aAreaAFC)
RestArea(aArea)

Return lRet

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �Pma430AF9Vld� Autor �                        � Data � ??/??/?? ���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao .                                                    ���
����������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA430                                                        ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function Pma430AF9Vld()
Return M->AJ8_TIPO=="2".And.PmsSetF3("AF9",2,M->AJ8_PROJPMS)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �Pma430AFCVld� Autor �                        � Data � ??/??/??���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao .                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA430                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Pma430AFCVld()
Return M->AJ8_TIPO=="2".And.PmsSetF3("AFC",2,M->AJ8_PROJPMS)

Static Function MenuDef()

Return StaticCall(MATXATU,MENUDEF)
