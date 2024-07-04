#INCLUDE "INKEY.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA040M.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA040M � Autor � MOHANAD ODEH          � Data � 15/04/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � CADASTRO E MANUTENCAO DE VERBAS                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���PROGRAMADOR � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gpea040M()
Local aArea			:= GetArea()
Local aAreaSRV		:= SRV->(GetArea())
Local aAreaRCM  	:= RCM->(GetArea())

Private lImpPD		:= .F.
Private aRotina

Begin Sequence

	IF ( lImpPD := MsgNoYes(	OemToAnsi(	STR0002 + ;	//"O Sistema ira Atualizar todas as Verbas Padroes de sua Base de Dados."
											CRLF	+ ;
											Iif (cPaisLoc =="PAR",STR0005,STR0003) + ;	//"Faca um Backup (SRV/RCM) antes de Iniciar o Processo de Atualizacao."/"Faca um Backup (SRV) antes de Iniciar o Processo de Atualizacao."
											CRLF	+ ;
											CRLF	+ ;
											STR0004   ;	//"Confirma a Atualizacao das Verbas?"
					   					 ),;
				 				OemToAnsi( STR0001 ) ;	//"Aten��o!"
							);
		)
		IF cPaisLoc =="PAR"
			MsAguarde( { || Gpea40PMDel() } )
		EndIf
		MsAguarde( { || Gpea040MDel() } )

	EndIf

	// CHAMADA AO PROGRAMA DE CADASTRO DE VERBAS
	aRotina := FWLOADMENU('GPEA040')
	GPEA040()

End Sequence

// RESTAURA OS DADOS DE ENTRADA
RestArea(aAreaRCM)
RestArea(aAreaSRV)
RestArea(aArea)

Return(NIL)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea040MDel  �Autor�  MOHANAD ODEH        � Data �24/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar Todas as Verbas                                     �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpea040MDel()                                               �
�����������������������������������������������������������������������Ĵ
�Parametros�NIL                                                         �
�����������������������������������������������������������������������Ĵ
�Uso       �GPEA040M()	                                                �
�������������������������������������������������������������������������*/
STATIC FUNCTION Gpea040MDel()

SRV->(DbGoTop())
While SRV->(!Eof())
	IF SRV->(RecLock("SRV",.F.,.F.))
		SRV->(dbDelete())
		SRV->(MsUnLock())
	EndIF
	SRV->(DbSkip())
EndDo

Return(NIL)

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea40PMDel  �Autor�  MOHANAD ODEH        � Data �24/06/2011�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar Todas as Verbas                                     �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpea40PMDel()                                               �
�����������������������������������������������������������������������Ĵ
�Parametros�NIL                                                         �
�����������������������������������������������������������������������Ĵ
�Uso       �GPEA040M()	                                                �
�������������������������������������������������������������������������*/
STATIC FUNCTION Gpea40PMDel()

RCM->(DbGoTop())
While RCM->(!Eof())
	IF RCM->(RecLock("RCM",.F.,.F.))
		RCM->(dbDelete())
		RCM->(MsUnLock())
	EndIF
	RCM->(DbSkip())
EndDo

Return(NIL)
