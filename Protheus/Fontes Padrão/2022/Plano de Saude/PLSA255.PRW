
Function PLSA255

AxCadastro("BBB","Cadastro Tipos Lancamentos Debitos/Creditos","PLSA255Del()")

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � PLSA255Del � Autor � Angelo Sperandio      � Data � 19.03.07 ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Validacao de exclusao                                        ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function PLSA255Del()

LOCAL lRet		:= .T.
LOCAL aChaves 	:= {}

If  ! empty(BBB->BBB_FILIAL) .and. ! empty(xFilial("BGQ"))
    aadd(aChaves,{"BGQ","BGQ_FILIAL",BBB->BBB_FILIAL,"BGQ_CODLAN",BBB->BBB_CODSER})
    aadd(aChaves,{"BBC","BBC_FILIAL",BBB->BBB_FILIAL,"BBC_CODSER",BBB->BBB_CODSER})
    aadd(aChaves,{"BFF","BFF_FILIAL",BBB->BBB_FILIAL,"BFF_CODTAB",BBB->BBB_CODSER})
    aadd(aChaves,{"BCD","BCD_FILIAL",BBB->BBB_FILIAL,"BCD_CODPAG",BBB->BBB_CODSER})
    aadd(aChaves,{"BCE","BCE_FILIAL",BBB->BBB_FILIAL,"BCE_CODPAG",BBB->BBB_CODSER})
Else
    aadd(aChaves,{"BGQ","BGQ_CODLAN",BBB->BBB_CODSER})
    aadd(aChaves,{"BBC","BBC_CODSER",BBB->BBB_CODSER})
    aadd(aChaves,{"BFF","BFF_CODTAB",BBB->BBB_CODSER})
    aadd(aChaves,{"BCD","BCD_CODPAG",BBB->BBB_CODSER})
    aadd(aChaves,{"BCE","BCE_CODPAG",BBB->BBB_CODSER})
Endif    

lRet := PLSCHKDEL(aChaves)

Return(lRet)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � MenuDef � Autor � Henry Fila             � Data � 02/04/07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Atualizacao do menu funcional                              ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � MenuDef()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Static Function MenuDef()

Return StaticCall(MATXATU,MENUDEF)
