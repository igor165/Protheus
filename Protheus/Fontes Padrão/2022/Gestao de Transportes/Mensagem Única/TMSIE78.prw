#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSIE78  ³ Autor ³ Valdemar Roberto   ³ Data ³ 02/03/2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de integracao com o adapter EAI para recebimento de ³±±
±±³          ³ e envio de dados da GNRE                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSIE78(cExp01,nExp01,cExp02)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 - Variavel com conteudo xml para envio/recebimento  ³±±
±±³          ³ nExp01 - Tipo de transacao (Envio/Recebimento)             ³±±
±±³          ³ cExp02 - Tipo de mensagem (Business Type, WhoIs, Etc)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºRetorno   ³ aRet - Array contendo o resultado da execucao e a mensagem º±±
±±º          ³        XML de retorn                                       º±±
±±º          ³ aRet[1] - (Boolean) Indica resultado da execução da função º±±
±±º          ³ aRet[2] - (Caracter) Mensagem XML para envio  s            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAE78                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
