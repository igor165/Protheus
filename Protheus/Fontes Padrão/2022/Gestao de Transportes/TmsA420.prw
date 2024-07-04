#include "TMSA420.ch"
Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Programa  � TMSA420  � Autor �Richard Anderson       � Data �16.05.2002  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Tipos de Embalagem                                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA420(ExpA1,ExpN1)                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array Contendo os Campos (Rot. Automatica)           ���
���          � ExpN1 - Opcao Selecionada (Rot. Automatica)                  ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                          ���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaTMS - Gestao de Transporte                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
FUNCTION TMSA420(aRotAuto, nOpcAuto)

Private l420Auto := (Valtype(aRotAuto) == "A")                                   
    
If l420Auto
	Private aRotina := {{ Nil, "TMSA420Inc", 0, 3 },; // Inclusao
						 { Nil, "TMSA420Inc", 0, 4 },; // Alteracao
						 { Nil, "TMSA420Inc", 0, 5 }}  // Exclusao
						 
    Private lMsHelpAuto := .T.						 
EndIf                    

If l420Auto
	MsRotAuto(nOpcAuto,aRotAuto,'DUJ')
Else
	AxCadastro("DUJ",STR0001) //"Tipos de Embalagem"
EndIf	

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TMSA420Inc� Autor � Patricia A. Salomao   � Data � 04.12.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Manutencao do Arquivo DUJ (Tipos de Embalagem),  ���
���          � Disparada por rotina automatica                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA420Inc(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do Arquivo.                                  ���
���          � ExpC2 = Registro.                                          ���
���          � ExpC3 = Opcao Selecionada.                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSA420                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function TMSA420Inc(cAlias,nReg,nOpc)

l420Auto := If (Type("l420Auto") == "U", .F., l420Auto)

If l420Auto
	Begin Transaction
        If nOpc == 5
        	AxDeleta(cAlias,nReg,nOpc)
        Else
        	AxIncluiAuto(cAlias,,,nOpc,nReg)	
		EndIf	
	End Transaction
EndIf
                   
Return Nil