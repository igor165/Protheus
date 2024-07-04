#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSIE78  � Autor � Valdemar Roberto   � Data � 02/03/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de integracao com o adapter EAI para recebimento de ���
���          � e envio de dados da GNRE                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSIE78(cExp01,nExp01,cExp02)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Variavel com conteudo xml para envio/recebimento  ���
���          � nExp01 - Tipo de transacao (Envio/Recebimento)             ���
���          � cExp02 - Tipo de mensagem (Business Type, WhoIs, Etc)      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRet - Array contendo o resultado da execucao e a mensagem ���
���          �        XML de retorn                                       ���
���          � aRet[1] - (Boolean) Indica resultado da execu��o da fun��o ���
���          � aRet[2] - (Caracter) Mensagem XML para envio  s            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE78                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSIE78(cXML,nTypeTrans,cTypeMessage,cVersion)
Local lRet     := .T.
Local cXMLRet  := ""
Local cMsgRet  := "TransportDocument"
Local aVetGNRE := TMSAE78Sta("aVetGNRE")
Local aEAIRET  := {}
Local aResult  := {}

Private oDTClass := Nil

default cVersion := "2.000"

If nTypeTrans == TRANS_RECEIVE

	If cTypeMessage == EAI_MESSAGE_RESPONSE
		cXMLRet    := cXML
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '2.000'
	EndIf

ElseIf nTypeTrans == TRANS_SEND

	Begin Transaction

		aEAIRET := TmA250Clas(aVetGNRE[01],aVetGNRE[02],aVetGNRE[03],aVetGNRE[04],aVetGNRE[05],aVetGNRE[06],aVetGNRE[07],aVetGNRE[08],aVetGNRE[09],;
							  aVetGNRE[10],aVetGNRE[11],aVetGNRE[12],aVetGNRE[13],aVetGNRE[14],aVetGNRE[15],aVetGNRE[16],aVetGNRE[17],aVetGNRE[18],;
							  aVetGNRE[19],aVetGNRE[20],aVetGNRE[21],aVetGNRE[22],aVetGNRE[23],aVetGNRE[24])
  
		oDTClass:cVersion := cVersion
		aResult := oDTClass:Send()
		AAdd(aResult,oDTClass:cEntityName)

	End Transaction

EndIf

Return aResult
